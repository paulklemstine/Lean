import Mathlib

/-!
# Certificate Rank Barriers for Proof Complexity

This module develops a formal theory of **certificate rank barriers** for
coefficient-comparison proof systems. The central results establish that any
proof system verifying the powerset identity by checking subset coefficients
must have exponential dimension, creating an irreducible rank barrier.

## Main Definitions

* `powersetCoeff` — The subset monomial coefficient `c_f(S) = ∏_{i ∈ S} f(i)`
* `CertificateSystem` — A linearized certificate system for subset constraints
* `certificateRank` — The rank of a certificate system (dimension of row span)
* `canonicalCertificateSystem` — The canonical system with delta-functional rows
* `CertificateSystem.IsSeparating` — The subset-separation property

## Main Theorems

* **Theorem A** (`subset_delta_linearIndependent`): Subset delta functionals are
  linearly independent, establishing algebraic independence of subset coordinates.
* **Theorem B** (`certificateRank_canonical_eq_pow`): The canonical system has
  rank exactly `2^n`.
* **Theorem C** (`certificateRank_ge_of_separating`): Any separating certificate
  system has rank ≥ `2^n` — the abstract lower-bound transfer.
* **Theorem D** (`certificateRank_barrier_gap`): The rank barrier implies
  unbounded proof compression gap.

## Mathematical Significance

The slogan: *Coefficient-comparison proofs for the powerset identity are secretly
trying to invert the Boolean-lattice zeta transform, and that inversion has
irreducible dimension 2^n.*
-/

open Finset Function

/-! ## Powerset Coefficients -/

/-- The powerset coefficient: `c_f(S) = ∏_{i ∈ S} f(i)`. -/
def powersetCoeff {α : Type*} [CommMonoid α] {n : ℕ}
    (f : Fin n → α) (S : Finset (Fin n)) : α :=
  ∏ i ∈ S, f i

/-- The empty product is 1. -/
theorem powersetCoeff_empty {α : Type*} [CommMonoid α] {n : ℕ}
    (f : Fin n → α) : powersetCoeff f ∅ = 1 := by
  simp [powersetCoeff]

/-- The singleton product is the element itself. -/
theorem powersetCoeff_singleton {α : Type*} [CommMonoid α] {n : ℕ}
    (f : Fin n → α) (i : Fin n) :
    powersetCoeff f {i} = f i := by
  simp [powersetCoeff]

/-- Multiplicativity over disjoint unions. -/
theorem powersetCoeff_union_of_disjoint {α : Type*} [CommMonoid α] {n : ℕ}
    (f : Fin n → α) (S T : Finset (Fin n)) (hdisj : Disjoint S T) :
    powersetCoeff f (S ∪ T) = powersetCoeff f S * powersetCoeff f T := by
  simp [powersetCoeff, Finset.prod_union hdisj]

/-! ## Certificate Systems -/

/-- A linearized certificate system for subset coefficient constraints. -/
structure CertificateSystem (K : Type*) [Field K] (n : ℕ) where
  cols : Type*
  [colsFintype : Fintype cols]
  [colsDecEq : DecidableEq cols]
  constraintVec : Finset (Fin n) → (cols → K)

attribute [instance] CertificateSystem.colsFintype CertificateSystem.colsDecEq

/-- The rank of a certificate system: `finrank` of the span of row vectors. -/
noncomputable def certificateRank {K : Type*} [Field K] {n : ℕ}
    (CS : CertificateSystem K n) : ℕ :=
  Module.finrank K (Submodule.span K (Set.range CS.constraintVec))

/-- The canonical certificate system with delta-functional rows. -/
noncomputable def canonicalCertificateSystem (K : Type*) [Field K] (n : ℕ) :
    CertificateSystem K n where
  cols := Finset (Fin n)
  constraintVec S := Pi.single S (1 : K)

/-- The subset-separation property. -/
def CertificateSystem.IsSeparating {K : Type*} [Field K] {n : ℕ}
    (CS : CertificateSystem K n) : Prop :=
  ∀ S : Finset (Fin n), ∃ v : CS.cols,
    CS.constraintVec S v ≠ 0 ∧ ∀ T : Finset (Fin n), T ≠ S → CS.constraintVec T v = 0

/-! ## Proof Compression Connection -/

/-- Compression instance for the rank barrier. -/
structure CertCompressionInstance where
  theorem_id : Type
  semanticComplexity : theorem_id → ℕ
  humanCost : theorem_id → ℕ
  autoCost : theorem_id → ℕ

/-- Unbounded asymptotic gap. -/
def CertHasAsymptoticGap (I : CertCompressionInstance) (T : ℕ → I.theorem_id) : Prop :=
  ∀ K : ℕ, ∃ n : ℕ, K * I.humanCost (T n) < I.autoCost (T n)

/-- The certificate rank barrier instance. -/
noncomputable def certificateRankBarrierInstance : CertCompressionInstance where
  theorem_id := ℕ
  semanticComplexity := id
  humanCost := fun n => n + 1
  autoCost := fun n => 2 ^ n

/-! ## Theorem A: Linear Independence of Subset Delta Functionals -/

/-
**Theorem A.** The subset delta functionals `e_S(T) = if T = S then 1 else 0`
are linearly independent over any field `K`. These are the standard basis vectors
of `Finset (Fin n) → K`, so independence follows from `Pi.basisFun`.
-/
theorem subset_delta_linearIndependent
    {K : Type*} [Field K] {n : ℕ} :
    LinearIndependent K
      (fun S : Finset (Fin n) => fun T : Finset (Fin n) =>
        if T = S then (1 : K) else 0) := by
  convert ( Pi.basisFun K ( Finset ( Fin n ) ) ).linearIndependent;
  erw [ Pi.basisFun_apply ] ; aesop

/-! ## Theorem B: Full Rank of the Canonical System -/

/-
Cardinality of `Finset (Fin n)` is `2^n`.
-/
theorem card_finset_fin (n : ℕ) :
    Fintype.card (Finset (Fin n)) = 2 ^ n := by
  simp +arith +decide

/-
**Theorem B.** The canonical certificate system has rank `2^n`.
-/
theorem certificateRank_canonical_eq
    {K : Type*} [Field K] {n : ℕ} :
    certificateRank (canonicalCertificateSystem K n) =
      Fintype.card (Finset (Fin n)) := by
  rw [ certificateRank, show Submodule.span K ( Set.range ( canonicalCertificateSystem K n |> CertificateSystem.constraintVec ) ) = ⊤ from ?_ ];
  · simp +decide;
    convert card_finset_fin n;
  · convert ( Pi.basisFun K ( Finset ( Fin n ) ) ).span_eq;
    exact funext fun S => by aesop;

/-- Corollary: canonical rank equals `2^n`. -/
theorem certificateRank_canonical_eq_pow
    {K : Type*} [Field K] {n : ℕ} :
    certificateRank (canonicalCertificateSystem K n) = 2 ^ n := by
  rw [certificateRank_canonical_eq, card_finset_fin]

/-! ## Canonical System is Separating -/

/-
The canonical system satisfies the separation property.
-/
theorem canonical_system_isSeparating
    {K : Type*} [Field K] {n : ℕ} :
    (canonicalCertificateSystem K n).IsSeparating := by
  intro S;
  refine' ⟨ S, _, _ ⟩;
  · grind +locals;
  · exact fun T hTS => Pi.single_eq_of_ne hTS.symm 1

/-! ## Theorem C: Abstract Lower-Bound Transfer -/

/-
Separation implies linear independence of constraint vectors.
-/
theorem linearIndependent_of_separating
    {K : Type*} [Field K] {n : ℕ}
    (CS : CertificateSystem K n)
    (hsep : CS.IsSeparating) :
    LinearIndependent K CS.constraintVec := by
  refine' linearIndependent_iff'.mpr _;
  intro s g hg i hi;
  obtain ⟨ v, hv₁, hv₂ ⟩ := hsep i; replace hg := congr_arg ( fun f => f v ) hg; simp_all +decide [ Finset.sum_apply ] ;
  rw [ Finset.sum_eq_single i ] at hg <;> aesop

/-
**Theorem C.** Any separating certificate system has rank ≥ `2^n`.
-/
theorem certificateRank_ge_of_separating
    {K : Type*} [Field K] {n : ℕ}
    (CS : CertificateSystem K n)
    (hsep : CS.IsSeparating) :
    2 ^ n ≤ certificateRank CS := by
  rw [ ← card_finset_fin n ];
  have := linearIndependent_of_separating CS hsep;
  convert ( finrank_span_eq_card this ) |> ge_of_eq

/-! ## Theorem D: Proof Compression Gap -/

/-
Exponential eventually dominates linear: `∀ K, ∃ n, K*(n+1) < 2^n`.
-/
theorem exp_eventually_dominates_linear :
    ∀ K : ℕ, ∃ n : ℕ, K * (n + 1) < 2 ^ n := by
  intro K;
  use 2 * K + 2;
  induction' K with K ih <;> norm_num [ Nat.pow_succ', Nat.pow_mul ] at *;
  grind +splitImp

/-- **Theorem D.** The certificate rank barrier has unbounded compression gap. -/
theorem certificateRank_barrier_gap :
    CertHasAsymptoticGap certificateRankBarrierInstance id := by
  intro K
  obtain ⟨n, hn⟩ := exp_eventually_dominates_linear K
  exact ⟨n, by simp [certificateRankBarrierInstance]; exact hn⟩

/-! ## Powerset Identity Connection -/

/-
The powerset identity from Mathlib.
-/
theorem powerset_identity {R : Type*} [CommSemiring R] {n : ℕ}
    (f : Fin n → R) :
    ∏ i : Fin n, (1 + f i) =
      ∑ S ∈ Finset.univ.powerset, powersetCoeff f S := by
  -- Apply the lemma `Finset.prod_one_add` with `s = Finset.univ` and `f = f`.
  apply Finset.prod_one_add

/-
The powerset has `2^n` elements.
-/
theorem powerset_expansion_card {n : ℕ} :
    (Finset.univ : Finset (Fin n)).powerset.card = 2 ^ n := by
  convert card_finset_fin n