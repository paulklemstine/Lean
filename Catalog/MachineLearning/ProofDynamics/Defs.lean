import Mathlib

/-!
# Proof Dynamics: Definitions

A formal theory of proof refinement, descent, and normal forms.

We model proofs as syntactic sketch trees over a theorem-label type `α`.
Each proof sketch carries a multi-dimensional complexity measure, and local
simplification moves (refinement steps) strictly reduce complexity while
preserving semantic content. This creates a well-founded descent system
whose fixed points are *normal-form proofs* — the simplest reachable
explanations of a given theorem.

## Main Definitions

- `ProofComplexity` — multi-component complexity vector (length, depth, lemmaCount)
- `ProofSketch α` — inductive proof-tree syntax over theorem labels
- `RefinementStep` — local simplification relation on proof sketches
- `NormalForm` — irreducible proof sketch (no outgoing refinement)
- `sem` — semantic function extracting the theorem label a sketch establishes
- `normalize` — executable greedy normalization function

## Cross-Domain Connections

The complexity score serves as a discrete Lyapunov function / energy,
turning refinement trajectories into dissipative dynamical systems on a
proof-energy landscape. Normal forms are ground states.
-/

universe u

/-! ## Proof Complexity -/

/-- Multi-component complexity measure for proof sketches.
    Records length (total node count), depth (tree height),
    and lemmaCount (number of lemma nodes). -/
structure ProofComplexity where
  length : ℕ
  depth  : ℕ
  lemmaCount : ℕ
  deriving DecidableEq, Repr

namespace ProofComplexity

/-- Scalar complexity: sum of all components. -/
def score (c : ProofComplexity) : ℕ :=
  c.length + c.depth + c.lemmaCount

/-- Lexicographic order on complexity triples: first by length,
    then depth, then lemmaCount. This is strictly finer than
    scalar score comparison. -/
def Lex (c₁ c₂ : ProofComplexity) : Prop :=
  c₁.length < c₂.length ∨
  (c₁.length = c₂.length ∧ c₁.depth < c₂.depth) ∨
  (c₁.length = c₂.length ∧ c₁.depth = c₂.depth ∧ c₁.lemmaCount < c₂.lemmaCount)

instance : DecidableRel Lex := by
  intro a b
  simp only [Lex]
  infer_instance

end ProofComplexity

/-! ## Proof Sketch Syntax -/

/-- A syntactic proof object over theorem labels of type `α`.

- `axiom_ a` — invokes axiom/assumption `a` directly
- `lemma_ a p` — proves `a` using sub-proof `p`
- `trans p q` — transitivity: chain proof `p` then `q`
- `cases_ p q` — case split: prove via `p` and `q`
- `redundant p` — a redundant wrapper around `p` (can be dropped)
- `duplicate p` — a duplicated copy of `p` (can be deduplicated)
-/
inductive ProofSketch (α : Type u) where
  | axiom_    : α → ProofSketch α
  | lemma_    : α → ProofSketch α → ProofSketch α
  | trans     : ProofSketch α → ProofSketch α → ProofSketch α
  | cases_    : ProofSketch α → ProofSketch α → ProofSketch α
  | redundant : ProofSketch α → ProofSketch α
  | duplicate : ProofSketch α → ProofSketch α
  deriving Repr

namespace ProofSketch

variable {α : Type u}

/-! ### Size, depth, lemma count -/

/-- Total number of nodes in the proof tree. -/
def size : ProofSketch α → ℕ
  | .axiom_ _      => 1
  | .lemma_ _ p    => 1 + p.size
  | .trans p q     => 1 + p.size + q.size
  | .cases_ p q    => 1 + p.size + q.size
  | .redundant p   => 1 + p.size
  | .duplicate p   => 1 + p.size

/-- Tree depth (longest root-to-leaf path). -/
def depth : ProofSketch α → ℕ
  | .axiom_ _      => 0
  | .lemma_ _ p    => 1 + p.depth
  | .trans p q     => 1 + max p.depth q.depth
  | .cases_ p q    => 1 + max p.depth q.depth
  | .redundant p   => 1 + p.depth
  | .duplicate p   => 1 + p.depth

/-- Number of lemma-nodes in the tree. -/
def lcount : ProofSketch α → ℕ
  | .axiom_ _      => 0
  | .lemma_ _ p    => 1 + p.lcount
  | .trans p q     => p.lcount + q.lcount
  | .cases_ p q    => p.lcount + q.lcount
  | .redundant p   => p.lcount
  | .duplicate p   => p.lcount

/-- Full multi-component complexity of a proof sketch. -/
def complexity (p : ProofSketch α) : ProofComplexity :=
  { length := p.size, depth := p.depth, lemmaCount := p.lcount }

/-- Scalar score = sum of all complexity components. -/
def score (p : ProofSketch α) : ℕ := p.complexity.score

/-! ### Semantics -/

/-- Semantic function: extracts the theorem label that a proof sketch establishes.

For `axiom_ a` and `lemma_ a _`, the label is `a`.
For `trans p q`, `cases_ p q`, `redundant p`, `duplicate p`,
the semantic content is inherited from the first/inner sub-proof.

This is a simplification — in a full system, `trans` would compose
theorems — but it suffices for our refinement-invariance results. -/
def sem : ProofSketch α → α
  | .axiom_ a      => a
  | .lemma_ a _    => a
  | .trans p _     => p.sem
  | .cases_ p _    => p.sem
  | .redundant p   => p.sem
  | .duplicate p   => p.sem

end ProofSketch

/-! ## Refinement Steps -/

/-- Local simplification moves on proof sketches. Each constructor
    represents a semantics-preserving transformation that strictly
    reduces complexity.

- `dropRedundant` — remove a `redundant` wrapper
- `dropDuplicate` — remove a `duplicate` wrapper
- `flattenRedundantRedundant` — `redundant (redundant p) ↦ redundant p`
- `flattenDuplicateDuplicate` — `duplicate (duplicate p) ↦ duplicate p`
- `simplifyLemmaRedundant` — `lemma_ a (redundant p) ↦ lemma_ a p`
- `simplifyLemmaLeaf` — `lemma_ a (axiom_ b) ↦ axiom_ a`
    (a lemma whose sub-proof is a single axiom collapses to an axiom)
-/
inductive RefinementStep : ProofSketch α → ProofSketch α → Prop where
  | dropRedundant (p : ProofSketch α) :
      RefinementStep (.redundant p) p
  | dropDuplicate (p : ProofSketch α) :
      RefinementStep (.duplicate p) p
  | flattenRedundantRedundant (p : ProofSketch α) :
      RefinementStep (.redundant (.redundant p)) (.redundant p)
  | flattenDuplicateDuplicate (p : ProofSketch α) :
      RefinementStep (.duplicate (.duplicate p)) (.duplicate p)
  | simplifyLemmaRedundant (a : α) (p : ProofSketch α) :
      RefinementStep (.lemma_ a (.redundant p)) (.lemma_ a p)
  | simplifyLemmaLeaf (a b : α) :
      RefinementStep (.lemma_ a (.axiom_ b)) (.axiom_ a)

/-! ## Normal Form -/

/-- A proof `p` is in normal form with respect to relation `step`
    if no further step can be applied to it. -/
def NormalForm {P : Type _} (step : P → P → Prop) (p : P) : Prop :=
  ∀ q, ¬ step p q

/-! ## Refinement Closure -/

/-- The reflexive-transitive closure of a step relation. -/
abbrev Refines {P : Type _} (step : P → P → Prop) : P → P → Prop :=
  Relation.ReflTransGen step

/-! ## Concrete Theorem Labels for Examples -/

/-- Example theorem labels for concrete refinement demonstrations. -/
inductive TheoremLabel where
  | IrrationalSqrt2
  | EvenPlusEvenEven
  | DvdTrans
  | ParityLemma
  deriving DecidableEq, Repr

/-! ## Executable Normalization -/

/-- One-step greedy simplification. Returns `none` if already in normal form,
    or `some q` where `q` is the result of one simplification step. -/
def ProofSketch.stepOnce : ProofSketch α → Option (ProofSketch α)
  | .redundant p   => some p
  | .duplicate p   => some p
  | .lemma_ a (.redundant p) => some (.lemma_ a p)
  | .lemma_ a (.axiom_ _)    => some (.axiom_ a)
  | .lemma_ a p    =>
    match p.stepOnce with
    | some p' => some (.lemma_ a p')
    | none    => none
  | .trans p q     =>
    match p.stepOnce with
    | some p' => some (.trans p' q)
    | none    =>
      match q.stepOnce with
      | some q' => some (.trans p q')
      | none    => none
  | .cases_ p q    =>
    match p.stepOnce with
    | some p' => some (.cases_ p' q)
    | none    =>
      match q.stepOnce with
      | some q' => some (.cases_ p q')
      | none    => none
  | .axiom_ _      => none

/-- Greedy normalization: iterate `stepOnce` until fixpoint.
    Uses fuel to ensure termination (bounded by initial size). -/
def ProofSketch.normalizeFuel : ℕ → ProofSketch α → ProofSketch α
  | 0, p     => p
  | n+1, p   =>
    match p.stepOnce with
    | none    => p
    | some p' => normalizeFuel n p'

/-- Normalize a proof sketch using size as fuel bound. -/
def ProofSketch.normalize (p : ProofSketch α) : ProofSketch α :=
  p.normalizeFuel (p.size * 2)

/-! ## Energy Drop -/

/-- The energy drop between two proof states, measured as an integer
    difference of their complexity scores. Positive when refinement
    decreases complexity. -/
def energyDrop {P : Type _} (E : P → ℕ) (p q : P) : ℤ :=
  Int.ofNat (E p) - Int.ofNat (E q)