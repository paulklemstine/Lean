/-
# Tropical Factor-Rank-1 Equivalence

This file establishes the foundational bridge between three characterizations of
rank-1 structure in tropical (min-plus) linear algebra:

1. **Min-plus factor rank ≤ 1**: A matrix A factors as A(i,j) = U(i,0) + V(0,j)
   through a single intermediate index.
2. **Additive separability**: A(i,j) = p(i) + q(j) for potential functions p, q.
3. **Tropical 2×2 minor vanishing**: A(i,j) + A(i',j') = A(i,j') + A(i',j) for all indices.

The equivalence of these three conditions is the first formal bridge between
tropical linear algebra, Monge-type discrete geometry, and discrete potential
theory (cohomological exactness on the complete bipartite grid).

## Main results

* `minPlusFactorRankLE_one_iff_additivelySeparable` — min-plus rank ≤ 1 ↔ additive separability
* `additivelySeparable_iff_tropicalRankOneMinorCondition` — separability ↔ 2×2 minor vanishing
* `minPlusFactorRankLE_one_iff_minorCondition` — the flagship synthesis
* `additive_separable_of_minorCondition` — basepoint reconstruction of potentials
* `additive_decomposition_unique_up_to_constant` — gauge uniqueness (up to additive constant)
* `maxPlusFactorRankLE_one_iff_minorCondition` — max-plus dual via negation

## Cross-domain significance

- **Discrete Hodge theory**: The minor condition is exactness of a 1-cocycle on the grid graph.
- **Monge arrays / optimization**: Equality in the Monge relation gives exact separability.
- **Machine learning**: Tropical rank-1 matrices model exact additive cost decompositions.
- **Mathematical physics**: The 2×2 identity is a discrete zero-curvature equation.
- **Category theory**: Separability is a tropical analogue of tensor rank 1.
-/

import Mathlib

open Finset

/-! ## Definitions -/

/-- A matrix `A` has min-plus factor rank ≤ `k` if it can be written as
    `A(i,j) = inf_t (U(i,t) + V(t,j))` for factor matrices `U`, `V`
    with intermediate dimension `k`. For `k = 0`, `Fin 0` is empty and
    `sInf ∅ = 0` in `ℝ` (by convention), so only the zero matrix qualifies. -/
def MinPlusFactorRankLE (k : ℕ) {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∃ U : Fin n → Fin k → ℝ, ∃ V : Fin k → Fin m → ℝ,
    ∀ i j, A i j = sInf (Set.range (fun t : Fin k => U i t + V t j))

/-- A matrix `A` is additively separable if it factors as `A(i,j) = p(i) + q(j)`
    for potential functions `p` and `q`. This is the tropical analogue of
    (multiplicative) rank 1. -/
def AdditivelySeparable {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∃ p : Fin n → ℝ, ∃ q : Fin m → ℝ, ∀ i j, A i j = p i + q j

/-- The tropical 2×2 minor condition: all 2×2 "tropical minors" vanish, i.e.,
    `A(i,j) + A(i',j') = A(i,j') + A(i',j)` for all index quadruples.
    This is the vanishing of the discrete mixed second difference
    `δ²A(i,i',j,j') := A(i,j) + A(i',j') - A(i,j') - A(i',j) = 0`. -/
def TropicalRankOneMinorCondition {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∀ i i' j j', A i j + A i' j' = A i j' + A i' j

/-- Max-plus factor rank ≤ `k`: `A(i,j) = sup_t (U(i,t) + V(t,j))`. -/
def MaxPlusFactorRankLE (k : ℕ) {n m : ℕ} (A : Fin n → Fin m → ℝ) : Prop :=
  ∃ U : Fin n → Fin k → ℝ, ∃ V : Fin k → Fin m → ℝ,
    ∀ i j, A i j = sSup (Set.range (fun t : Fin k => U i t + V t j))

/-- The discrete mixed second difference (curvature defect). -/
def delta₂ {n m : ℕ} (A : Fin n → Fin m → ℝ) (i i' : Fin n) (j j' : Fin m) : ℝ :=
  A i j + A i' j' - A i j' - A i' j

/-! ## Helper lemmas -/

/-- Every element of `Fin 1` equals `0`. -/
lemma fin1_eq_zero (t : Fin 1) : t = 0 := Fin.ext (by omega)

/-- The infimum of a singleton range `{f 0}` over `Fin 1` equals `f 0`. -/
lemma sInf_range_fin_one (f : Fin 1 → ℝ) :
    sInf (Set.range f) = f 0 := by
  have : Set.range f = {f 0} := by
    ext x; simp only [Set.mem_range, Set.mem_singleton_iff]
    constructor
    · rintro ⟨t, rfl⟩; congr 1; exact fin1_eq_zero t
    · rintro rfl; exact ⟨0, rfl⟩
  rw [this, csInf_singleton]

/-- The supremum of a singleton range `{f 0}` over `Fin 1` equals `f 0`. -/
lemma sSup_range_fin_one (f : Fin 1 → ℝ) :
    sSup (Set.range f) = f 0 := by
  have : Set.range f = {f 0} := by
    ext x; simp only [Set.mem_range, Set.mem_singleton_iff]
    constructor
    · rintro ⟨t, rfl⟩; congr 1; exact fin1_eq_zero t
    · rintro rfl; exact ⟨0, rfl⟩
  rw [this, csSup_singleton]

/-- The minor condition holds for any additively separable form. -/
lemma minorCondition_of_additive
    {n m : ℕ} {p : Fin n → ℝ} {q : Fin m → ℝ} :
    TropicalRankOneMinorCondition (fun i j => p i + q j) := by
  intro i i' j j'
  ring

/-- `delta₂ = 0` iff the minor condition holds at those indices. -/
lemma delta₂_eq_zero_iff {n m : ℕ} (A : Fin n → Fin m → ℝ)
    (i i' : Fin n) (j j' : Fin m) :
    delta₂ A i i' j j' = 0 ↔ A i j + A i' j' = A i j' + A i' j := by
  unfold delta₂; constructor <;> intro h <;> linarith

/-- The minor condition is equivalent to vanishing of all `delta₂` values. -/
lemma tropicalRankOneMinorCondition_iff_delta₂_zero {n m : ℕ}
    (A : Fin n → Fin m → ℝ) :
    TropicalRankOneMinorCondition A ↔ ∀ i i' j j', delta₂ A i i' j j' = 0 := by
  unfold TropicalRankOneMinorCondition
  constructor
  · intro h i i' j j'; rw [delta₂_eq_zero_iff]; exact h i i' j j'
  · intro h i i' j j'; rw [← delta₂_eq_zero_iff]; exact h i i' j j'

/-! ## Direction 1: Additive separability implies the minor condition -/

theorem minorCondition_of_additivelySeparable
    {n m : ℕ} (A : Fin n → Fin m → ℝ)
    (hA : AdditivelySeparable A) :
    TropicalRankOneMinorCondition A := by
  obtain ⟨p, q, hpq⟩ := hA
  intro i i' j j'
  simp only [hpq]
  ring

/-! ## Direction 2: Minor condition implies additive separability (basepoint reconstruction) -/

/-- **Basepoint Reconstruction Theorem**: Given the tropical 2×2 minor condition
    and a choice of base row `i₀` and base column `j₀`, we can reconstruct
    explicit potentials `p(i) = A(i, j₀)` and `q(j) = A(i₀, j) - A(i₀, j₀)`
    such that `A(i,j) = p(i) + q(j)`.

    This is the tropical analogue of "vanishing curl implies gradient potential"
    on the rectangular discrete grid `Fin n × Fin m`. -/
theorem additive_separable_of_minorCondition
    {n m : ℕ} [NeZero n] [NeZero m]
    (A : Fin n → Fin m → ℝ)
    (hA : TropicalRankOneMinorCondition A) :
    ∃ i0 : Fin n, ∃ j0 : Fin m,
      let p : Fin n → ℝ := fun i => A i j0
      let q : Fin m → ℝ := fun j => A i0 j - A i0 j0
      ∀ i j, A i j = p i + q j := by
  refine ⟨0, 0, fun i j => ?_⟩
  have h := hA i 0 j 0
  linarith

/-! ## The main equivalence: separability ↔ minor condition -/

/-- **Tropical Rank-One Structure Theorem**: A matrix `A : Fin n → Fin m → ℝ`
    (with nonempty index sets) is additively separable if and only if
    all 2×2 tropical minors vanish. -/
theorem additivelySeparable_iff_tropicalRankOneMinorCondition
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ) :
    AdditivelySeparable A ↔ TropicalRankOneMinorCondition A := by
  constructor
  · exact minorCondition_of_additivelySeparable A
  · intro hA
    obtain ⟨i0, j0, h⟩ := additive_separable_of_minorCondition A hA
    exact ⟨fun i => A i j0, fun j => A i0 j - A i0 j0, h⟩

/-! ## Min-plus rank ≤ 1 ↔ additive separability -/

/-- Min-plus factor rank ≤ 1 is exactly additive separability:
    the `sInf` over a singleton `Fin 1` collapses to a direct sum. -/
theorem minPlusFactorRankLE_one_iff_additivelySeparable
    {n m : ℕ} (A : Fin n → Fin m → ℝ) :
    MinPlusFactorRankLE 1 A ↔ AdditivelySeparable A := by
  constructor
  · rintro ⟨U, V, hUV⟩
    refine ⟨fun i => U i 0, fun j => V 0 j, fun i j => ?_⟩
    rw [hUV i j, sInf_range_fin_one]
  · rintro ⟨p, q, hpq⟩
    refine ⟨fun i _ => p i, fun _ j => q j, fun i j => ?_⟩
    rw [sInf_range_fin_one, hpq]

/-! ## Flagship synthesis: min-plus rank ≤ 1 ↔ minor condition -/

/-- **Flagship Theorem**: For nonempty finite index sets, min-plus factor rank ≤ 1
    is equivalent to the tropical 2×2 minor condition. This unifies tropical
    linear algebra, Monge geometry, and discrete potential theory. -/
theorem minPlusFactorRankLE_one_iff_minorCondition
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ) :
    MinPlusFactorRankLE 1 A ↔ TropicalRankOneMinorCondition A := by
  rw [minPlusFactorRankLE_one_iff_additivelySeparable,
      additivelySeparable_iff_tropicalRankOneMinorCondition]

/-! ## Gauge uniqueness -/

/-- **Gauge Uniqueness**: If `A(i,j) = p(i) + q(j) = p'(i) + q'(j)`, then
    `p'` and `p` differ by a constant `c`, and `q'` and `q` differ by `-c`.
    This is the gauge symmetry of tropical rank-1 factorization: the
    decomposition is unique up to the 1-dimensional family of shifts
    `(p + c, q - c)`. -/
theorem additive_decomposition_unique_up_to_constant
    {n m : ℕ} [NeZero n] [NeZero m]
    {A : Fin n → Fin m → ℝ}
    {p p' : Fin n → ℝ} {q q' : Fin m → ℝ}
    (h : ∀ i j, A i j = p i + q j)
    (h' : ∀ i j, A i j = p' i + q' j) :
    ∃ c : ℝ, (∀ i, p' i = p i + c) ∧ ∀ j, q' j = q j - c := by
  refine ⟨p' 0 - p 0, fun i => ?_, fun j => ?_⟩
  · have h1 := h i 0
    have h2 := h' i 0
    have h3 := h 0 0
    have h4 := h' 0 0
    linarith
  · have h1 := h 0 j
    have h2 := h' 0 j
    linarith

/-! ## Row-difference invariance -/

/-- Additive separability implies that row differences are independent of column:
    `A(i,j) - A(i',j)` depends only on `i, i'`, not on `j`. -/
theorem row_diff_constant_of_additivelySeparable
    {n m : ℕ} (A : Fin n → Fin m → ℝ)
    (hA : AdditivelySeparable A) :
    ∀ i i' : Fin n, ∀ j j' : Fin m,
      A i j - A i' j = A i j' - A i' j' := by
  obtain ⟨p, q, hpq⟩ := hA
  intro i i' j j'
  simp only [hpq]
  ring

/-! ## Max-plus duality -/

/-- **Min-max duality**: `min a b = -(max (-a) (-b))`.
    This is the fundamental negation symmetry between min-plus and max-plus algebras. -/
theorem min_max_duality' (a b : ℝ) : min a b = -(max (-a) (-b)) := by
  simp [min_def, max_def]; split_ifs <;> linarith

/-- Negating a matrix preserves the tropical minor condition.
    This is because the minor identity `A(i,j) + A(i',j') = A(i,j') + A(i',j)`
    is invariant under `A ↦ -A`. -/
theorem tropicalRankOneMinorCondition_neg
    {n m : ℕ} (A : Fin n → Fin m → ℝ)
    (hA : TropicalRankOneMinorCondition A) :
    TropicalRankOneMinorCondition (fun i j => -A i j) := by
  intro i i' j j'
  have := hA i i' j j'
  linarith

/-- If `A` is additively separable, then so is `-A`. -/
theorem additivelySeparable_neg
    {n m : ℕ} (A : Fin n → Fin m → ℝ)
    (hA : AdditivelySeparable A) :
    AdditivelySeparable (fun i j => -A i j) := by
  obtain ⟨p, q, hpq⟩ := hA
  exact ⟨fun i => -p i, fun j => -q j, fun i j => by simp [hpq i j]; ring⟩

/-- Max-plus factor rank ≤ 1 is exactly additive separability. -/
theorem maxPlusFactorRankLE_one_iff_additivelySeparable
    {n m : ℕ} (A : Fin n → Fin m → ℝ) :
    MaxPlusFactorRankLE 1 A ↔ AdditivelySeparable A := by
  constructor
  · rintro ⟨U, V, hUV⟩
    refine ⟨fun i => U i 0, fun j => V 0 j, fun i j => ?_⟩
    rw [hUV i j, sSup_range_fin_one]
  · rintro ⟨p, q, hpq⟩
    refine ⟨fun i _ => p i, fun _ j => q j, fun i j => ?_⟩
    rw [sSup_range_fin_one, hpq]

/-- **Max-Plus Rank-One Theorem**: For nonempty finite index sets, max-plus factor
    rank ≤ 1 is equivalent to the tropical 2×2 minor condition.
    This is the dual of the min-plus flagship theorem, obtained via negation. -/
theorem maxPlusFactorRankLE_one_iff_minorCondition
    {n m : ℕ} [NeZero n] [NeZero m] (A : Fin n → Fin m → ℝ) :
    MaxPlusFactorRankLE 1 A ↔ TropicalRankOneMinorCondition A := by
  rw [maxPlusFactorRankLE_one_iff_additivelySeparable,
      additivelySeparable_iff_tropicalRankOneMinorCondition]

/-! ## Min-plus and max-plus agree at rank 1 -/

/-- At rank 1, min-plus and max-plus factorizations coincide: a matrix has
    min-plus rank ≤ 1 iff it has max-plus rank ≤ 1. This is because both
    reduce to additive separability when there is only one intermediate index. -/
theorem minPlusFactorRankLE_one_iff_maxPlusFactorRankLE_one
    {n m : ℕ} (A : Fin n → Fin m → ℝ) :
    MinPlusFactorRankLE 1 A ↔ MaxPlusFactorRankLE 1 A := by
  rw [minPlusFactorRankLE_one_iff_additivelySeparable,
      maxPlusFactorRankLE_one_iff_additivelySeparable]