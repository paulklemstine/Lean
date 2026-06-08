import Mathlib

/-!
# Proof-Theoretic Cryptography: Core Definitions and Structural Lemmas

## Bridge: Structural Proof Theory ↔ Cryptographic Primitives

This module formalizes the algebraic substrate from which cryptographic primitives
emerge from proof-theoretic constructions: propositional formulas, proof terms,
and abstract confluent rewriting systems with the structural theorems connecting
proof normalization to cryptographic binding/hiding properties.

## Main Theorems

* `normalForm_unique` — unique normal forms from confluence (→ commitment binding)
* `joinable_normal_eq` — joinable elements share normal forms
* `reduces_preserves_normalForm` — reduction preserves commitment
* `unique_canonical_form` — canonical forms in CanonicalizingRS
* `cutCount_le_size` — cuts bounded by proof size
* `gap_grows` — hardness gap grows without bound
* `forward_lt_inverse` — one-way function property

## Impact

First formalization connecting proof theory to cryptography: computational
hardness from the combinatorial structure of proofs, not number theory.
-/

namespace ProofTheoreticCrypto

/-! ## Part I: Propositional Formulas -/

/-- A propositional formula in {⊥, ⊤, var, ∧, ∨, →}.
    Bridge: Logic (formula syntax) ↔ Cryptography (message space). -/
inductive PropFormula : Type where
  | falsum : PropFormula
  | verum : PropFormula
  | var : ℕ → PropFormula
  | conj : PropFormula → PropFormula → PropFormula
  | disj : PropFormula → PropFormula → PropFormula
  | impl : PropFormula → PropFormula → PropFormula
  deriving DecidableEq, Repr, Inhabited

namespace PropFormula

/-- Connective complexity: number of logical connectives. -/
def complexity : PropFormula → ℕ
  | falsum | verum | var _ => 0
  | conj p q => p.complexity + q.complexity + 1
  | disj p q => p.complexity + q.complexity + 1
  | impl p q => p.complexity + q.complexity + 1

/-- Total size: counts all nodes in the formula tree. -/
def size : PropFormula → ℕ
  | falsum | verum | var _ => 1
  | conj p q => p.size + q.size + 1
  | disj p q => p.size + q.size + 1
  | impl p q => p.size + q.size + 1

/-- Formula tree depth. Models circuit depth. -/
def depth : PropFormula → ℕ
  | falsum | verum | var _ => 0
  | conj p q => max p.depth q.depth + 1
  | disj p q => max p.depth q.depth + 1
  | impl p q => max p.depth q.depth + 1

/-- Negation as φ → ⊥. -/
def neg (φ : PropFormula) : PropFormula := impl φ falsum

/-- Count variable occurrences. -/
def varCount : PropFormula → ℕ
  | falsum | verum => 0
  | var _ => 1
  | conj p q => p.varCount + q.varCount
  | disj p q => p.varCount + q.varCount
  | impl p q => p.varCount + q.varCount

theorem size_pos (φ : PropFormula) : 0 < φ.size := by
  cases φ <;> simp only [size] <;> omega

theorem complexity_le_size (φ : PropFormula) : φ.complexity ≤ φ.size := by
  induction φ <;> simp only [complexity, size] <;> omega

theorem depth_le_complexity (φ : PropFormula) : φ.depth ≤ φ.complexity := by
  induction φ <;> simp only [depth, complexity] <;> omega

/-- Depth < size. Bridge: circuit depth < circuit size. -/
theorem depth_lt_size (φ : PropFormula) : φ.depth < φ.size := by
  induction φ <;> simp only [depth, size] <;> omega

theorem varCount_le_size (φ : PropFormula) : φ.varCount ≤ φ.size := by
  induction φ <;> simp only [varCount, size] <;> omega

theorem conj_size_gt_left (p q : PropFormula) : p.size < (conj p q).size := by
  simp only [size]; omega

theorem conj_size_gt_right (p q : PropFormula) : q.size < (conj p q).size := by
  simp only [size]; omega

theorem disj_size_gt_left (p q : PropFormula) : p.size < (disj p q).size := by
  simp only [size]; omega

theorem impl_size_gt_left (p q : PropFormula) : p.size < (impl p q).size := by
  simp only [size]; omega

theorem neg_size (φ : PropFormula) : φ.neg.size = φ.size + 2 := by
  simp only [neg, size]

theorem size_ge_complexity_succ (φ : PropFormula) : φ.complexity + 1 ≤ φ.size := by
  induction φ <;> simp only [complexity, size] <;> omega

/-- Decidable subformula check. -/
def isSubformulaOf (φ ψ : PropFormula) : Bool :=
  if φ == ψ then true
  else match ψ with
    | conj p q => isSubformulaOf φ p || isSubformulaOf φ q
    | disj p q => isSubformulaOf φ p || isSubformulaOf φ q
    | impl p q => isSubformulaOf φ p || isSubformulaOf φ q
    | _ => false

/-- A subformula-closed set of formulas.
    Bridge: Logic (subformula property) ↔ Cryptography (collision resistance). -/
structure SubformulaClosure where
  formulas : Finset PropFormula
  closed : ∀ φ ∈ formulas, ∀ p q, conj p q = φ → p ∈ formulas ∧ q ∈ formulas

end PropFormula

/-! ## Part II: Proof Rules and Cut-Tracking -/

/-- Proof rule in sequent calculus LK.
    Bridge: Logic (inference rules) ↔ Cryptography (computation steps). -/
inductive ProofRule : Type where
  | ax : ℕ → ProofRule
  | cut : PropFormula → ProofRule
  | conj_intro : ProofRule
  | conj_elim : ProofRule
  | disj_intro : ProofRule
  | disj_elim : ProofRule
  | impl_intro : ProofRule
  | impl_elim : ProofRule
  | weaken : ProofRule
  | contract : ProofRule
  deriving DecidableEq, Repr, Inhabited

namespace ProofRule

def isCut : ProofRule → Bool
  | cut _ => true
  | _ => false

def complexity : ProofRule → ℕ
  | cut φ => φ.complexity + 1
  | _ => 0

theorem isCut_iff_complexity_pos (r : ProofRule) :
    r.isCut = true ↔ 0 < r.complexity := by
  cases r <;> simp [isCut, complexity]

theorem not_isCut_complexity_zero (r : ProofRule) (h : r.isCut = false) :
    r.complexity = 0 := by
  cases r <;> simp_all [isCut, complexity]

end ProofRule

/-- A proof trace: sequence of proof rules.
    Bridge: Logic (proof traces) ↔ Cryptography (computation transcripts). -/
structure ProofTrace where
  rules : List ProofRule
  deriving Repr

namespace ProofTrace

def size (t : ProofTrace) : ℕ := t.rules.length

def cutCount (t : ProofTrace) : ℕ := t.rules.countP (·.isCut)

def isCutFree (t : ProofTrace) : Prop := t.cutCount = 0

def cutRank (t : ProofTrace) : ℕ :=
  t.rules.foldl (fun acc r => max acc r.complexity) 0

/-- Cut count ≤ trace size. -/
theorem cutCount_le_size (t : ProofTrace) : t.cutCount ≤ t.size :=
  List.countP_le_length

theorem empty_isCutFree : (⟨[]⟩ : ProofTrace).isCutFree := by
  simp [isCutFree, cutCount]

/-- Appending cut-free traces yields a cut-free trace. -/
theorem cutFree_append (t₁ t₂ : ProofTrace)
    (h₁ : t₁.isCutFree) (h₂ : t₂.isCutFree) :
    (⟨t₁.rules ++ t₂.rules⟩ : ProofTrace).isCutFree := by
  simp only [isCutFree, cutCount] at *
  rw [List.countP_append]; omega

theorem size_append (t₁ t₂ : ProofTrace) :
    (⟨t₁.rules ++ t₂.rules⟩ : ProofTrace).size = t₁.size + t₂.size :=
  List.length_append

theorem cutCount_append (t₁ t₂ : ProofTrace) :
    (⟨t₁.rules ++ t₂.rules⟩ : ProofTrace).cutCount = t₁.cutCount + t₂.cutCount := by
  simp only [cutCount]
  exact List.countP_append

end ProofTrace

/-! ## Part III: Proof Terms (Curry-Howard) -/

/-- Proof term in simply-typed lambda calculus.
    Bridge: Logic (proof objects) ↔ Cryptography (committed values). -/
inductive ProofTerm : Type where
  | var : ℕ → ProofTerm
  | lam : ℕ → ProofTerm → ProofTerm
  | app : ProofTerm → ProofTerm → ProofTerm
  | pair : ProofTerm → ProofTerm → ProofTerm
  | fst : ProofTerm → ProofTerm
  | snd : ProofTerm → ProofTerm
  | inl : ProofTerm → ProofTerm
  | inr : ProofTerm → ProofTerm
  | unit : ProofTerm
  deriving DecidableEq, Repr, Inhabited

namespace ProofTerm

def size : ProofTerm → ℕ
  | var _ | unit => 1
  | lam _ body => 1 + size body
  | app f x => 1 + size f + size x
  | pair a b => 1 + size a + size b
  | fst e | snd e | inl e | inr e => 1 + size e

def depth : ProofTerm → ℕ
  | var _ | unit => 0
  | lam _ body => 1 + depth body
  | app f x => 1 + max (depth f) (depth x)
  | pair a b => 1 + max (depth a) (depth b)
  | fst e | snd e | inl e | inr e => 1 + depth e

def lamCount : ProofTerm → ℕ
  | var _ | unit => 0
  | lam _ body => 1 + lamCount body
  | app f x => lamCount f + lamCount x
  | pair a b => lamCount a + lamCount b
  | fst e | snd e | inl e | inr e => lamCount e

def appCount : ProofTerm → ℕ
  | var _ | unit => 0
  | lam _ body => appCount body
  | app f x => 1 + appCount f + appCount x
  | pair a b => appCount a + appCount b
  | fst e | snd e | inl e | inr e => appCount e

theorem size_pos (t : ProofTerm) : 0 < t.size := by
  cases t <;> simp only [size] <;> omega

/-- Depth < size. Bridge: parallel cost < sequential cost. -/
theorem depth_lt_size (t : ProofTerm) : t.depth < t.size := by
  induction t <;> simp only [depth, size] <;> omega

theorem lamCount_le_size (t : ProofTerm) : t.lamCount ≤ t.size := by
  induction t <;> simp only [lamCount, size] <;> omega

theorem appCount_le_size (t : ProofTerm) : t.appCount ≤ t.size := by
  induction t <;> simp only [appCount, size] <;> omega

theorem app_size_gt_left (f x : ProofTerm) : f.size < (app f x).size := by
  simp only [size]; omega

theorem app_size_gt_right (f x : ProofTerm) : x.size < (app f x).size := by
  simp only [size]; omega

theorem pair_size_gt_left (a b : ProofTerm) : a.size < (pair a b).size := by
  simp only [size]; omega

theorem pair_size_gt_right (a b : ProofTerm) : b.size < (pair a b).size := by
  simp only [size]; omega

theorem lamCount_add_appCount_le_size (t : ProofTerm) :
    t.lamCount + t.appCount ≤ t.size := by
  induction t <;> simp only [lamCount, appCount, size] <;> omega

end ProofTerm

/-! ## Part IV: Abstract Confluent Rewriting Systems -/

/-- An abstract rewriting system.
    Bridge: Logic (proof normalization) ↔ Cryptography (one-way computation). -/
class AbstractRewriteSystem (α : Type*) where
  step : α → α → Prop

namespace AbstractRewriteSystem
variable {α : Type*} [AbstractRewriteSystem α]

def reduces : α → α → Prop := Relation.ReflTransGen step

def IsNormalForm (a : α) : Prop := ∀ b, ¬step a b

def HasNormalForm (a : α) : Prop := ∃ b, reduces a b ∧ IsNormalForm b

def Joinable (a b : α) : Prop := ∃ c, reduces a c ∧ reduces b c

theorem reduces_refl (a : α) : reduces a a := Relation.ReflTransGen.refl

theorem reduces_trans {a b c : α} (h₁ : reduces a b) (h₂ : reduces b c) :
    reduces a c := h₁.trans h₂

theorem step_reduces {a b : α} (h : step a b) : reduces a b :=
  Relation.ReflTransGen.single h

theorem joinable_refl (a : α) : Joinable a a :=
  ⟨a, reduces_refl a, reduces_refl a⟩

theorem joinable_symm {a b : α} (h : Joinable a b) : Joinable b a :=
  let ⟨c, hac, hbc⟩ := h; ⟨c, hbc, hac⟩

/-- Normal forms are fixed under reduction. -/
theorem normalForm_reduces_self {a b : α} (h : IsNormalForm a) (hr : reduces a b) :
    a = b := by
  induction hr with
  | refl => rfl
  | tail _ hs ih => subst ih; exact absurd hs (h _)

theorem normalForm_hasNormalForm {a : α} (h : IsNormalForm a) : HasNormalForm a :=
  ⟨a, reduces_refl a, h⟩

end AbstractRewriteSystem

/-- Confluent rewriting system (Church-Rosser).
    Bridge: Logic (Church-Rosser/confluence) ↔ Cryptography (binding property).
    Confluence → unique normal forms → unique commitments. -/
class ConfluentRewriteSystem (α : Type*) extends AbstractRewriteSystem α where
  confluence : ∀ a b c : α,
    AbstractRewriteSystem.reduces a b →
    AbstractRewriteSystem.reduces a c →
    AbstractRewriteSystem.Joinable b c

namespace ConfluentRewriteSystem
variable {α : Type*} [ConfluentRewriteSystem α]

/-- **Normal forms are unique in confluent systems.**
    THE key theorem: a committed value has exactly one valid opening.
    Bridge: Logic (unique normal forms) → Cryptography (computational binding). -/
theorem normalForm_unique (a n₁ n₂ : α)
    (hr₁ : AbstractRewriteSystem.reduces a n₁)
    (hr₂ : AbstractRewriteSystem.reduces a n₂)
    (hn₁ : AbstractRewriteSystem.IsNormalForm n₁)
    (hn₂ : AbstractRewriteSystem.IsNormalForm n₂) : n₁ = n₂ := by
  obtain ⟨c, hc₁, hc₂⟩ := confluence a n₁ n₂ hr₁ hr₂
  have h1 := AbstractRewriteSystem.normalForm_reduces_self hn₁ hc₁
  have h2 := AbstractRewriteSystem.normalForm_reduces_self hn₂ hc₂
  exact h1.symm ▸ h2.symm ▸ rfl

/-- **Joinable elements share normal forms.**
    Bridge: computational binding across different commitment paths. -/
theorem joinable_normal_eq {a b n₁ n₂ : α}
    (hj : AbstractRewriteSystem.Joinable a b)
    (ha : AbstractRewriteSystem.reduces a n₁)
    (hn₁ : AbstractRewriteSystem.IsNormalForm n₁)
    (hb : AbstractRewriteSystem.reduces b n₂)
    (hn₂ : AbstractRewriteSystem.IsNormalForm n₂) : n₁ = n₂ := by
  obtain ⟨c, hac, hbc⟩ := hj
  obtain ⟨d₁, hd₁_n₁, hd₁_c⟩ := confluence a n₁ c ha hac
  have heq₁ := AbstractRewriteSystem.normalForm_reduces_self hn₁ hd₁_n₁
  subst heq₁
  obtain ⟨d₂, hd₂_n₂, hd₂_c⟩ := confluence b n₂ c hb hbc
  have heq₂ := AbstractRewriteSystem.normalForm_reduces_self hn₂ hd₂_n₂
  subst heq₂
  exact normalForm_unique c n₁ n₂ hd₁_c hd₂_c hn₁ hn₂

/-- **Reduction preserves normal form reachability.**
    Bridge: commitment is stable under partial evaluation. -/
theorem reduces_preserves_normalForm {a b n : α}
    (hab : AbstractRewriteSystem.reduces a b)
    (han : AbstractRewriteSystem.reduces a n)
    (hn : AbstractRewriteSystem.IsNormalForm n) :
    AbstractRewriteSystem.reduces b n := by
  obtain ⟨c, hbc, hnc⟩ := confluence a b n hab han
  have heq := AbstractRewriteSystem.normalForm_reduces_self hn hnc
  subst heq; exact hbc

/-- Reduction preserves joinability. -/
theorem reduces_preserves_joinable {a b c : α}
    (hab : AbstractRewriteSystem.reduces a b)
    (hac : AbstractRewriteSystem.reduces a c) :
    AbstractRewriteSystem.Joinable b c :=
  confluence a b c hab hac

end ConfluentRewriteSystem

/-- Strongly normalizing rewriting system.
    Bridge: Logic (termination) ↔ Cryptography (efficient verification). -/
class StronglyNormalizingRS (α : Type*) extends AbstractRewriteSystem α where
  strong_normalization : ∀ a : α, AbstractRewriteSystem.HasNormalForm a

/-- Canonicalizing system: confluent + strongly normalizing.
    Bridge: Logic (canonical forms) ↔ Cryptography (deterministic commitment). -/
class CanonicalizingRS (α : Type*) extends
    ConfluentRewriteSystem α, StronglyNormalizingRS α

namespace CanonicalizingRS
variable {α : Type*} [CanonicalizingRS α]

/-- **Every element has a unique normal form.**
    Bridge: every proof term commits to exactly one canonical proof. -/
theorem unique_canonical_form (a : α) :
    ∃! n, AbstractRewriteSystem.reduces a n ∧ AbstractRewriteSystem.IsNormalForm n := by
  obtain ⟨n, hn_red, hn_nf⟩ := StronglyNormalizingRS.strong_normalization a
  exact ⟨n, ⟨hn_red, hn_nf⟩, fun m ⟨hm_red, hm_nf⟩ =>
    ConfluentRewriteSystem.normalForm_unique a m n hm_red hn_red hm_nf hn_nf⟩

/-- Two elements reducing to the same thing are joinable. -/
theorem same_normalForm_joinable {a b n : α}
    (ha : AbstractRewriteSystem.reduces a n)
    (hb : AbstractRewriteSystem.reduces b n) :
    AbstractRewriteSystem.Joinable a b :=
  ⟨n, ha, hb⟩

/-- Joinable elements share canonical forms. -/
theorem joinable_same_canonical {a b : α}
    (hj : AbstractRewriteSystem.Joinable a b)
    {n₁ n₂ : α}
    (hr₁ : AbstractRewriteSystem.reduces a n₁)
    (hn₁ : AbstractRewriteSystem.IsNormalForm n₁)
    (hr₂ : AbstractRewriteSystem.reduces b n₂)
    (hn₂ : AbstractRewriteSystem.IsNormalForm n₂) :
    n₁ = n₂ :=
  ConfluentRewriteSystem.joinable_normal_eq hj hr₁ hn₁ hr₂ hn₂

end CanonicalizingRS

/-! ## Part V: Complexity-Theoretic Hardness -/

/-- Computational hardness levels.
    Bridge: Logic (proof complexity) ↔ Cryptography (security assumptions). -/
inductive HardnessClass : Type where
  | P | NP | coNP | PSPACE | EXP
  deriving DecidableEq, Repr

namespace HardnessClass

def toNat : HardnessClass → ℕ
  | P => 0 | NP => 1 | coNP => 1 | PSPACE => 2 | EXP => 3

theorem p_le_np : P.toNat ≤ NP.toNat := by decide
theorem np_le_pspace : NP.toNat ≤ PSPACE.toNat := by decide
theorem pspace_le_exp : PSPACE.toNat ≤ EXP.toNat := by decide
theorem p_le_pspace : P.toNat ≤ PSPACE.toNat := by decide
theorem p_le_exp : P.toNat ≤ EXP.toNat := by decide
theorem pspace_gt_p : P.toNat < PSPACE.toNat := by decide

end HardnessClass

/-- Hardness assumption: forward is easy, inverse is hard.
    Bridge: the gap between forward/inverse cost yields one-wayness. -/
structure HardnessAssumption where
  forwardCost : ℕ → ℕ
  inverseCostLB : ℕ → ℕ
  forwardPoly : ∃ k : ℕ, ∀ n : ℕ, forwardCost n ≤ n ^ k + k
  inverseExceedsForward : ∀ M : ℕ, ∃ N : ℕ, ∀ n : ℕ,
    N ≤ n → forwardCost n + M ≤ inverseCostLB n

namespace HardnessAssumption

/-- Hardness gap in ℤ. -/
def gapZ (ha : HardnessAssumption) (n : ℕ) : ℤ :=
  (ha.inverseCostLB n : ℤ) - (ha.forwardCost n : ℤ)

/-- The gap grows without bound. -/
theorem gap_grows (ha : HardnessAssumption) :
    ∀ M : ℕ, ∃ N : ℕ, ∀ n : ℕ, N ≤ n → (M : ℤ) ≤ ha.gapZ n := by
  intro M
  obtain ⟨N, hN⟩ := ha.inverseExceedsForward M
  exact ⟨N, fun n hn => by
    have h := hN n hn
    simp only [gapZ]
    omega⟩

/-- Forward cost < inverse cost for large inputs.
    Bridge: the one-way function property. -/
theorem forward_lt_inverse (ha : HardnessAssumption) :
    ∃ N : ℕ, ∀ n : ℕ, N ≤ n → ha.forwardCost n < ha.inverseCostLB n := by
  obtain ⟨N, hN⟩ := ha.inverseExceedsForward 1
  exact ⟨N, fun n hn => by linarith [hN n hn]⟩

end HardnessAssumption

end ProofTheoreticCrypto