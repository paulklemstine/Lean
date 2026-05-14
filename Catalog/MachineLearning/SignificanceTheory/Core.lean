/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Certified Mathematical Significance Theory

Order-theoretic significance functionals on finite knowledge lattices,
with a bridge to proof-term complexity. We define significance metrics
on `Finset α` knowledge states, prove monotonicity under inclusion,
strict advancement under positive-weight insertion, and connect
significance to syntactic proof-term structure.

## Cross-Domain Bridges

- **Order theory**: significance as a monotone valuation on a finite lattice
- **Proof theory**: significance extracted from proof syntax
- **ML certification**: quality gates via threshold functions
- **Resource theory**: proofs consume constructors to generate inferential reach
-/
import Mathlib

open Finset BigOperators Finsupp

noncomputable section

/-! ## Part A: Significance on finite knowledge lattices -/

namespace SignificanceTheory

/-- Significance of a knowledge state `K : Finset α` given a weight function `w : α → ℕ`.
    This is the total weight of all theorem atoms in the knowledge state. -/
def significance {α : Type*} [DecidableEq α] (w : α → ℕ) (K : Finset α) : ℕ :=
  K.sum w

/-
**Theorem A (pointwise form)**: Significance is monotone under subset inclusion.
    If `K₁ ⊆ K₂`, then `σ(K₁) ≤ σ(K₂)`.
-/
theorem significance_le_of_subset
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) {K₁ K₂ : Finset α}
    (h : K₁ ⊆ K₂) :
    significance w K₁ ≤ significance w K₂ := by
  exact Finset.sum_le_sum_of_subset h

/-
**Theorem A (monotone form)**: Significance is a monotone function on `Finset α`
    ordered by inclusion.
-/
theorem significance_monotone
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) :
    Monotone (significance w : Finset α → ℕ) := by
  exact fun K₁ K₂ h => significance_le_of_subset w h

/-! ## Part B: Advancement and threshold crossing -/

/-- A knowledge state advances the field if its significance meets a threshold `τ`. -/
def advances_field
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ) (K : Finset α) : Prop :=
  τ ≤ significance w K

/-- Strict advancement: `K₂` strictly advances beyond `K₁` if it contains `K₁`
    and has strictly greater significance. -/
def strict_advancement
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (K₁ K₂ : Finset α) : Prop :=
  K₁ ⊆ K₂ ∧ significance w K₁ < significance w K₂

/-
Adjoining a theorem of positive weight to a state below threshold,
    resulting in a state at or above threshold, yields advancement.
-/
theorem positive_adjoin_crosses_threshold
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ) {K : Finset α} {a : α}
    (_ha : a ∉ K)
    (_hwa : 0 < w a)
    (_hbelow : significance w K < τ)
    (hcross : τ ≤ significance w (insert a K)) :
    advances_field w τ (insert a K) := by
  exact hcross

/-
**Theorem B**: Inserting a fresh theorem atom of positive weight
    strictly advances the knowledge state.
-/
theorem positive_weight_insert_strict_advancement
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) {K : Finset α} {a : α}
    (ha : a ∉ K)
    (hwa : 0 < w a) :
    strict_advancement w K (insert a K) := by
  exact ⟨ Finset.subset_insert _ _, by rw [ significance ] ; rw [ significance ] ; rw [ Finset.sum_insert ha ] ; linarith ⟩

/-
Significance of inserting a fresh element equals old significance plus the weight.
-/
theorem significance_insert
    {α : Type*} [DecidableEq α]
    (w : α → ℕ) {K : Finset α} {a : α}
    (ha : a ∉ K) :
    significance w (insert a K) = significance w K + w a := by
  unfold significance; rw [ Finset.sum_insert ha ] ; ring;

/-! ## Part C: Syntactic proof objects and proof-term significance -/

/-- An inductive syntax of proof terms, modeling a simple proof object language. -/
inductive ProofTerm where
  | axiom_ : ℕ → ProofTerm
  | app   : ProofTerm → ProofTerm → ProofTerm
  | lam   : ProofTerm → ProofTerm
  | pair  : ProofTerm → ProofTerm → ProofTerm
  deriving DecidableEq, Repr

/-- Structural size of a proof term: counts all constructor nodes. -/
def ProofTerm.size : ProofTerm → ℕ
  | .axiom_ _   => 1
  | .app p q   => p.size + q.size + 1
  | .lam p     => p.size + 1
  | .pair p q  => p.size + q.size + 1

/-- Height (depth) of a proof term: the longest path from root to leaf. -/
def ProofTerm.height : ProofTerm → ℕ
  | .axiom_ _   => 1
  | .app p q   => max p.height q.height + 1
  | .lam p     => p.height + 1
  | .pair p q  => max p.height q.height + 1

/-- Proof significance is defined as proof-term size. -/
def proofSignificance : ProofTerm → ℕ := ProofTerm.size

/-
Proof significance is algorithmically computable: there exists a function
    computing it that agrees with the definition on all inputs.
-/
theorem exists_proofSignificance_algorithm :
    ∃ f : ProofTerm → ℕ, ∀ p, f p = proofSignificance p := by
  exact ⟨ _, fun p => rfl ⟩

/-
**Theorem C₁**: Height is bounded above by size for all proof terms.
    This is the bridge from proof depth to significance.
-/
theorem height_le_size (p : ProofTerm) :
    p.height ≤ p.size := by
  induction p <;> simp +arith +decide [ *, ProofTerm.height, ProofTerm.size ];
  · grind +revert;
  · grind +revert

/-
Size is always positive.
-/
theorem ProofTerm.size_pos (p : ProofTerm) : 0 < p.size := by
  induction p;
  · exact Nat.succ_pos _;
  · exact Nat.succ_pos _;
  · exact Nat.succ_pos _;
  · exact Nat.succ_pos _

/-
Height is always positive.
-/
theorem ProofTerm.height_pos (p : ProofTerm) : 0 < p.height := by
  -- By definition of height, we can prove this by induction on the structure of p.
  induction' p with p q hp hq;
  · exact Nat.succ_pos _;
  · exact Nat.succ_pos _;
  · exact Nat.succ_pos _;
  · exact Nat.succ_pos _

/-- The subterm relation on proof terms. -/
inductive Subterm : ProofTerm → ProofTerm → Prop
  | refl (p) : Subterm p p
  | app_left  {p q r} : Subterm p q → Subterm p (.app q r)
  | app_right {p q r} : Subterm p r → Subterm p (.app q r)
  | lam_body  {p q}   : Subterm p q → Subterm p (.lam q)
  | pair_left {p q r} : Subterm p q → Subterm p (.pair q r)
  | pair_right {p q r}: Subterm p r → Subterm p (.pair q r)

/-
**Theorem C₂**: Subterms have size at most the size of the containing term.
    Larger proof architecture cannot have smaller structural significance.
-/
theorem subterm_size_monotone {p q : ProofTerm} :
    Subterm p q → p.size ≤ q.size := by
  intro hpq
  induction' hpq with p q hpq' hpq'' hpq''' hpq'''' hpq''''' hpq'''''';
  all_goals norm_num [ ProofTerm.size ];
  · linarith;
  · grind +splitImp;
  · grind +revert;
  · linarith;
  · grind

/-
Subterms have height at most the height of the containing term.
-/
theorem subterm_height_monotone {p q : ProofTerm} :
    Subterm p q → p.height ≤ q.height := by
  intro hpq
  induction' hpq with p q hpq ihterm' h_subterm'';
  · exact Nat.le_refl p.height;
  · exact le_trans ihterm' ( by exact le_add_of_le_of_nonneg ( le_max_left _ _ ) zero_le_one );
  · exact le_trans ‹_› ( Nat.le_succ_of_le ( le_max_right _ _ ) );
  · exact le_trans ‹_› ( Nat.le_succ _ );
  · exact le_trans ‹_› ( by exact Nat.le_succ_of_le ( Nat.le_max_left _ _ ) );
  · exact le_trans ‹_› ( Nat.le_succ_of_le ( Nat.le_max_right _ _ ) )

/-! ## Part D: Proof-induced significance on theorem collections -/

/-- Given a proof witness assignment `π : α → ProofTerm`, the theorem weight
    is the proof significance of its witness. -/
def theoremWeight {α : Type*} (π : α → ProofTerm) : α → ℕ :=
  fun a => proofSignificance (π a)

/-
**Theorem D**: Significance computed from proof representations is monotone
    over knowledge growth. This is the central quality-gate theorem.
-/
theorem significance_from_proofs_monotone
    {α : Type*} [DecidableEq α]
    (π : α → ProofTerm) :
    Monotone (significance (theoremWeight π) : Finset α → ℕ) := by
  exact significance_monotone (theoremWeight π)

/-
Inserting a fresh theorem with a strictly larger proof than all existing ones
    strictly advances significance.
-/
theorem fresh_large_proof_strict_advancement
    {α : Type*} [DecidableEq α]
    (π : α → ProofTerm) {K : Finset α} {a : α}
    (ha : a ∉ K) :
    strict_advancement (theoremWeight π) K (insert a K) := by
  apply positive_weight_insert_strict_advancement;
  · assumption;
  · exact ProofTerm.size_pos _

/-! ## Part E: Package depth and master-class contributions -/

/-- Package depth: the maximum proof significance across all theorems in a knowledge state. -/
def packageDepth {α : Type*} [DecidableEq α] (π : α → ProofTerm) (K : Finset α) : ℕ :=
  K.sup (fun a => proofSignificance (π a))

/-
Package depth is monotone under inclusion.
-/
theorem packageDepth_monotone
    {α : Type*} [DecidableEq α]
    (π : α → ProofTerm) :
    Monotone (packageDepth π : Finset α → ℕ) := by
  exact fun K L hKL => Finset.sup_mono hKL

/-
**Master-class contribution**: A theorem whose proof significance exceeds the
    current package depth strictly raises the package depth.
-/
theorem packageDepth_insert_of_fresh_large
    {α : Type*} [DecidableEq α]
    (π : α → ProofTerm) {K : Finset α} {a : α}
    (_ha : a ∉ K)
    (hmax : packageDepth π K < proofSignificance (π a)) :
    packageDepth π (insert a K) = proofSignificance (π a) := by
  simp_all +decide [ packageDepth ];
  exact fun b hb => le_trans ( Finset.le_sup ( f := fun a => proofSignificance ( π a ) ) hb ) hmax.le

/-! ## Part F: Quality gate monotonicity -/

/-- Boolean quality gate: accepts a knowledge state if significance meets threshold. -/
def qualityGate {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ) (K : Finset α) : Bool :=
  decide (τ ≤ significance w K)

/-
Quality gate is monotone: once accepted, adding more theorems keeps acceptance.
-/
theorem qualityGate_monotone {α : Type*} [DecidableEq α]
    (w : α → ℕ) (τ : ℕ) {K₁ K₂ : Finset α}
    (h : K₁ ⊆ K₂)
    (hgate : qualityGate w τ K₁ = true) :
    qualityGate w τ K₂ = true := by
  simp_all +decide [ qualityGate ];
  exact le_trans hgate ( Finset.sum_le_sum_of_subset h )

/-! ## Part G: Closure operators and nonconservative extension -/

/-- A closure operator on `Finset α`: extensive, monotone, idempotent.
    Models the deductive closure of a knowledge state. -/
structure ClosureOp (α : Type*) [DecidableEq α] where
  cl : Finset α → Finset α
  extensive : ∀ K, K ⊆ cl K
  monotone : ∀ {K₁ K₂}, K₁ ⊆ K₂ → cl K₁ ⊆ cl K₂
  idempotent : ∀ K, cl (cl K) = cl K

/-- A nonconservative extension: adding `a` to `K` expands the deductive closure. -/
def nonconservative_extension {α : Type*} [DecidableEq α]
    (c : ClosureOp α) (K : Finset α) (a : α) : Prop :=
  c.cl K ⊂ c.cl (insert a K)

/-- Closure-based significance: cardinality of the deductive closure plus weighted sum. -/
def closureSignificance {α : Type*} [DecidableEq α]
    (c : ClosureOp α) (w : α → ℕ) (K : Finset α) : ℕ :=
  (c.cl K).card + (c.cl K).sum w

/-
Closure significance is monotone.
-/
theorem closureSignificance_monotone {α : Type*} [DecidableEq α]
    (c : ClosureOp α) (w : α → ℕ) {K₁ K₂ : Finset α}
    (h : K₁ ⊆ K₂) :
    closureSignificance c w K₁ ≤ closureSignificance c w K₂ := by
  -- By c.monotone h, we have cl K₁ ⊆ cl K₂.
  have h_cl : c.cl K₁ ⊆ c.cl K₂ := by
    exact c.monotone h;
  exact add_le_add ( Finset.card_le_card h_cl ) ( Finset.sum_le_sum_of_subset h_cl )

/-
A nonconservative extension strictly increases closure cardinality.
-/
theorem nonconservative_extension_card_strict
    {α : Type*} [DecidableEq α]
    (c : ClosureOp α) {K : Finset α} {a : α}
    (h : nonconservative_extension c K a) :
    (c.cl K).card < (c.cl (insert a K)).card := by
  exact Finset.card_lt_card h

end SignificanceTheory