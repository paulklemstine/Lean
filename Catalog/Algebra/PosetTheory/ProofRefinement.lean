/-
  A Proof-Refinement System over Propositional Logic

  Proof terms are syntactic trees whose nodes are annotated with the
  propositional `Formula`s they assert (from `Logic.Propositional`).  We equip
  them with the combined complexity measure `length + depth + lemma count` (from
  `Learning.TreeComplexity`) and study three refinement transformations:

  1. **removing redundant restatements** — a `restate` node that merely re-asserts
     the formula already proved by its subterm is dropped;
  2. **inlining named trivial lemmas** — a `named` lemma reference is replaced by a
     plain hypothesis node (the lemma's statement), lowering the lemma count;
  3. **merging modus-ponens steps** — a `restate` sitting directly under a `mp`
     node is stripped, merging the two adjacent steps.

  The one-step relation `Reduces` bundles these (with congruence rules so they may
  fire anywhere in the tree).  We prove:

  * `reduces_conclusion`   : every step preserves the proved conclusion;
  * `reduces_semEquiv`     : hence every step preserves semantic equivalence
                             (with the three transformation-specific corollaries
                             `t1_semEquiv`, `t2_semEquiv`, `t3_semEquiv`);
  * `reduces_combined_lt`  : every step strictly decreases the combined measure;
  * `refinement_terminates`: the refinement process terminates (the reverse of
                             `Reduces` is well-founded), via the well-order on `ℕ`.

  Finally, `simplify` is a computational one-pass pipeline realizing all three
  transformations; it preserves the conclusion and does not increase complexity.
  Concrete `#eval`/`decide` examples exhibit the simplification of a nested
  modus-ponens chain.
-/
import Catalog.Logic.ProofTheoryAndLogic.Propositional
import Catalog.Shared.TreeComplexity

namespace Learning.ProofRefinement

open Logic.Propositional

/-- Syntactic proof trees over propositional formulas. -/
inductive ProofTerm where
  /-- A hypothesis / axiom asserting a formula. -/
  | hyp : Formula → ProofTerm
  /-- A named lemma reference, tagged with the formula it proves. -/
  | named : String → Formula → ProofTerm
  /-- Modus ponens producing `concl`, from a proof of an implication and a proof
      of its antecedent. -/
  | mp : Formula → ProofTerm → ProofTerm → ProofTerm
  /-- A (possibly redundant) restatement of a subproof as proving `f`. -/
  | restate : Formula → ProofTerm → ProofTerm
deriving DecidableEq, Repr

namespace ProofTerm

/-- The formula proved by a proof term. -/
def conclusion : ProofTerm → Formula
  | hyp f       => f
  | named _ f   => f
  | mp c _ _    => c
  | restate f _ => f

/-- Number of nodes in the proof tree. -/
def length : ProofTerm → ℕ
  | hyp _       => 1
  | named _ _   => 1
  | mp _ a b    => 1 + length a + length b
  | restate _ p => 1 + length p

/-- Height of the proof tree. -/
def depth : ProofTerm → ℕ
  | hyp _       => 0
  | named _ _   => 0
  | mp _ a b    => 1 + max (depth a) (depth b)
  | restate _ p => 1 + depth p

/-- Number of named-lemma references in the proof tree. -/
def lemmaCount : ProofTerm → ℕ
  | hyp _       => 0
  | named _ _   => 1
  | mp _ a b    => lemmaCount a + lemmaCount b
  | restate _ p => lemmaCount p

/-- The additive part of the measure (`length + lemma count`); it is strictly
monotone under the refinement steps and is what forces termination together with
the non-increasing depth. -/
def weight (p : ProofTerm) : ℕ := length p + lemmaCount p

/-- The combined complexity measure `length + depth + lemma count`. -/
def combinedPT (p : ProofTerm) : ℕ :=
  Learning.TreeComplexity.combined (length p) (depth p) (lemmaCount p)

theorem combinedPT_eq (p : ProofTerm) : combinedPT p = weight p + depth p := by
  simp [combinedPT, weight, Learning.TreeComplexity.combined]
  omega

/-- Semantic equivalence of proof terms: they prove semantically equal
conclusions. -/
def SemEquiv (p q : ProofTerm) : Prop :=
  Formula.SemEq (conclusion p) (conclusion q)

end ProofTerm

open ProofTerm

/-- One step of refinement.  The first four constructors are the three
transformations (modus-ponens merging has an implication-side and an
argument-side variant); the last three are congruence rules letting a step fire
in any subtree. -/
inductive Reduces : ProofTerm → ProofTerm → Prop
  /-- (1) Remove a redundant restatement of an already-proved formula. -/
  | rmRestate (f : Formula) (p : ProofTerm) (h : conclusion p = f) :
      Reduces (restate f p) p
  /-- (2) Inline a named trivial lemma to a plain hypothesis. -/
  | inlineLemma (s : String) (f : Formula) :
      Reduces (named s f) (hyp f)
  /-- (3a) Merge a restatement adjacent to the implication side of a `mp`. -/
  | mergeMPImp (c a : Formula) (pimp pa : ProofTerm) :
      Reduces (mp c (restate a pimp) pa) (mp c pimp pa)
  /-- (3b) Merge a restatement adjacent to the argument side of a `mp`. -/
  | mergeMPArg (c a : Formula) (pimp pa : ProofTerm) :
      Reduces (mp c pimp (restate a pa)) (mp c pimp pa)
  | congMPImp {c : Formula} {p p' q : ProofTerm} :
      Reduces p p' → Reduces (mp c p q) (mp c p' q)
  | congMPArg {c : Formula} {p q q' : ProofTerm} :
      Reduces q q' → Reduces (mp c p q) (mp c p q')
  | congRestate {f : Formula} {p p' : ProofTerm} :
      Reduces p p' → Reduces (restate f p) (restate f p')

/-- Every refinement step preserves the proved conclusion. -/
theorem reduces_conclusion {p q : ProofTerm} (h : Reduces p q) :
    conclusion p = conclusion q := by
  induction h <;> simp_all [conclusion]

/-- Every refinement step preserves semantic equivalence of proof terms. -/
theorem reduces_semEquiv {p q : ProofTerm} (h : Reduces p q) : SemEquiv p q :=
  Formula.semEq_of_eq (reduces_conclusion h)

/-- Transformation (1) preserves semantic equivalence. -/
theorem t1_semEquiv (f : Formula) (p : ProofTerm) (h : conclusion p = f) :
    SemEquiv (restate f p) p :=
  reduces_semEquiv (Reduces.rmRestate f p h)

/-- Transformation (2) preserves semantic equivalence. -/
theorem t2_semEquiv (s : String) (f : Formula) :
    SemEquiv (named s f) (hyp f) :=
  reduces_semEquiv (Reduces.inlineLemma s f)

/-- Transformation (3) preserves semantic equivalence. -/
theorem t3_semEquiv (c a : Formula) (pimp pa : ProofTerm) :
    SemEquiv (mp c (restate a pimp) pa) (mp c pimp pa) :=
  reduces_semEquiv (Reduces.mergeMPImp c a pimp pa)

/-- The additive weight strictly decreases under every refinement step. -/
theorem reduces_weight_lt {p q : ProofTerm} (h : Reduces p q) :
    weight q < weight p := by
  induction h <;> simp_all [weight, length, lemmaCount] <;> omega

/-- The depth does not increase under any refinement step. -/
theorem reduces_depth_le {p q : ProofTerm} (h : Reduces p q) :
    depth q ≤ depth p := by
  induction h <;> simp_all [depth] <;> omega

/-- Every refinement step strictly decreases the combined complexity measure. -/
theorem reduces_combined_lt {p q : ProofTerm} (h : Reduces p q) :
    combinedPT q < combinedPT p := by
  have hw := reduces_weight_lt h
  have hd := reduces_depth_le h
  rw [combinedPT_eq, combinedPT_eq]
  omega

/--
**Termination of the refinement process.**

The reverse of `Reduces` is well-founded: there is no infinite refinement
sequence `p₀ → p₁ → p₂ → …`.  This follows from the well-order on `ℕ` together
with the strict decrease of the combined measure.
-/
theorem refinement_terminates :
    WellFounded (fun q p : ProofTerm => Reduces p q) :=
  Learning.TreeComplexity.terminates combinedPT Reduces
    (fun _ _ h => reduces_combined_lt h)

/-! ### The computational refinement pipeline -/

/-- Strip a single outer restatement (used to merge a restatement adjacent to a
`mp` node). -/
def stripRestate : ProofTerm → ProofTerm
  | restate _ x => x
  | t => t

/-- One bottom-up refinement pass applying all three transformations:
named lemmas are inlined, redundant restatements are removed, and restatements
adjacent to `mp` nodes are merged. -/
def simplify : ProofTerm → ProofTerm
  | hyp f       => hyp f
  | named _ f   => hyp f
  | mp c pimp pa =>
      mp c (stripRestate (simplify pimp)) (stripRestate (simplify pa))
  | restate f p =>
      let p' := simplify p
      if conclusion p' = f then p' else restate f p'

/-- Stripping an outer restatement never changes a `mp`/`hyp`/`named` node's
conclusion, and drops a restatement to its subterm's slot. -/
theorem stripRestate_length_le (p : ProofTerm) :
    length (stripRestate p) ≤ length p := by
  cases p <;> simp [stripRestate, length]

theorem stripRestate_depth_le (p : ProofTerm) :
    depth (stripRestate p) ≤ depth p := by
  cases p <;> simp [stripRestate, depth]

theorem stripRestate_lemmaCount_le (p : ProofTerm) :
    lemmaCount (stripRestate p) ≤ lemmaCount p := by
  cases p <;> simp [stripRestate, lemmaCount]

/-- The pipeline preserves the proved conclusion. -/
theorem simplify_conclusion (p : ProofTerm) :
    conclusion (simplify p) = conclusion p := by
  induction p with
  | hyp f => rfl
  | named s f => rfl
  | mp c pimp pa ihimp iha => simp [simplify, conclusion]
  | restate f p ih =>
      simp only [simplify]
      split
      · rename_i hcond; simpa [conclusion] using hcond
      · simp [conclusion]

/-- The pipeline preserves semantic equivalence. -/
theorem simplify_semEquiv (p : ProofTerm) : SemEquiv (simplify p) p :=
  Formula.semEq_of_eq (simplify_conclusion p)

/-- The pipeline never increases the weight. -/
theorem simplify_weight_le (p : ProofTerm) : weight (simplify p) ≤ weight p := by
  induction p with
  | hyp f => simp [simplify]
  | named s f => simp [simplify, weight, length, lemmaCount]
  | mp c pimp pa ihimp iha =>
      have h1 : weight (stripRestate (simplify pimp)) ≤ weight (simplify pimp) := by
        unfold weight
        have := stripRestate_length_le (simplify pimp)
        have := stripRestate_lemmaCount_le (simplify pimp)
        omega
      have h2 : weight (stripRestate (simplify pa)) ≤ weight (simplify pa) := by
        unfold weight
        have := stripRestate_length_le (simplify pa)
        have := stripRestate_lemmaCount_le (simplify pa)
        omega
      simp only [simplify, weight, length, lemmaCount] at *
      omega
  | restate f p ih =>
      simp only [simplify]
      split
      · simp only [weight, length, lemmaCount] at ih ⊢; omega
      · simp only [weight, length, lemmaCount] at ih ⊢; omega

/-- The pipeline never increases the depth. -/
theorem simplify_depth_le (p : ProofTerm) : depth (simplify p) ≤ depth p := by
  induction p with
  | hyp f => simp [simplify]
  | named s f => simp [simplify, depth]
  | mp c pimp pa ihimp iha =>
      have h1 := stripRestate_depth_le (simplify pimp)
      have h2 := stripRestate_depth_le (simplify pa)
      simp only [simplify, depth] at *
      omega
  | restate f p ih =>
      simp only [simplify]
      split
      · simp only [depth] at ih ⊢; omega
      · simp only [depth] at ih ⊢; omega

/-- The pipeline never increases the combined complexity measure. -/
theorem simplify_combined_le (p : ProofTerm) :
    combinedPT (simplify p) ≤ combinedPT p := by
  have hw := simplify_weight_le p
  have hd := simplify_depth_le p
  rw [combinedPT_eq, combinedPT_eq]
  omega

/-! ### Concrete examples -/

/-- atom `p₀`. -/
def fA : Formula := Formula.atom 0
/-- atom `p₁`. -/
def fB : Formula := Formula.atom 1
/-- atom `p₂`. -/
def fC : Formula := Formula.atom 2
/-- the implication `p₀ → p₁`. -/
def fAB : Formula := Formula.imp fA fB
/-- the implication `p₁ → p₂`. -/
def fBC : Formula := Formula.imp fB fC

/-- Nested redundant restatements of a single hypothesis. -/
def exRestate : ProofTerm := restate fA (restate fA (hyp fA))

example : simplify exRestate = hyp fA := by decide
example : conclusion (simplify exRestate) = conclusion exRestate := by decide
example : combinedPT (simplify exRestate) < combinedPT exRestate := by decide

/-- A modus-ponens step whose implication premise is a redundant restatement. -/
def exMP : ProofTerm := mp fB (restate fAB (hyp fAB)) (hyp fA)

example : simplify exMP = mp fB (hyp fAB) (hyp fA) := by decide
example : conclusion (simplify exMP) = conclusion exMP := by decide
example : combinedPT (simplify exMP) < combinedPT exMP := by decide

/-- A nested modus-ponens chain proving `p₂` from `p₁→p₂`, `p₀→p₁`, `p₀`, with
redundant restatements interspersed at every level. -/
def exChain : ProofTerm :=
  mp fC
    (restate fBC (hyp fBC))
    (restate fB (mp fB (restate fAB (hyp fAB)) (hyp fA)))

example :
    simplify exChain
      = mp fC (hyp fBC) (mp fB (hyp fAB) (hyp fA)) := by decide
example : conclusion (simplify exChain) = conclusion exChain := by decide
example : combinedPT (simplify exChain) < combinedPT exChain := by decide

-- The chain shrinks from a large tree to a compact one:
#eval combinedPT exChain            -- complexity before refinement
#eval combinedPT (simplify exChain) -- complexity after refinement

end Learning.ProofRefinement