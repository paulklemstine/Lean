import Tropical.DependentFibers.Corners
import Tropical.FreeWitnessTropicalShadow

/-!
# Genuinely dependent fibre families at every nontrivial finite cardinality

This file formalises and proves the thread's main claim.

**Conjecture 1 (witness form).**  For a degree-`n` tropical polynomial the family of
fibres `x ↦ fiber n c x` is a family of finite sets; the question is whether the
witnesses can always be arranged so the family is *genuinely dependent*, i.e. **not**
pointwise equivalent (fibrewise bijective) to a family that does not vary.

We prove three things.

1. `fiber_family_not_pointwise_constant`: for **every** degree `n ≥ 1` and **every**
   coefficient vector `c`, the fibre family is not pointwise equivalent to a constant
   family.  The proof is not a genericity argument: `Corners.exists_corner` produces a
   tie at an explicit point of the tropical line.

2. `dependent_solutions_at_every_cardinality`: for every `n ≥ 2` and every prescribed
   cardinality `k` with `2 ≤ k ≤ n + 1` there is a coefficient vector realising two
   fibres of unequal cardinality `k` and `1`.  So the phenomenon occurs *at every
   nontrivial finite cardinality* the degree allows, and `k ≤ n + 1` is exactly the
   available range by `fiber_card_le`.  The witnesses are the explicit *step
   polynomials* `stepCoeff k`.

3. A contrast with the catalog: the min-plus **divisor** aggregate family of
   `Tropical.FreeWitnessTropicalShadow` *is* constant — its argmin fibre is `{1}` for
   every `N` (`divisorArgmin_eq_one`), matching the catalog's
   `FreeWitnessShadow.tropicalAggregate_eq_trop_one`.  So constancy is not an artefact
   of tropicalisation as such: it is special to aggregation over a divisor lattice,
   and fails for the polynomial fibre family in the sharpest possible way.
-/

namespace TropicalDependentFibers

open Finset

/-! ## 1. Families of finite sets, pointwise equivalence, constancy -/

/-- Two families of finite index sets are **pointwise equivalent** when their fibres
are in bijection at every point. -/
def PointwiseEquiv (F G : ℚ → Finset ℕ) : Prop :=
  ∀ x : ℚ, Nonempty ({i // i ∈ F x} ≃ {i // i ∈ G x})

/-- A family is **constant** when all its fibres are literally the same finite set. -/
def IsConstantFamily (G : ℚ → Finset ℕ) : Prop := ∃ T : Finset ℕ, ∀ x : ℚ, G x = T

theorem card_eq_of_pointwiseEquiv {F G : ℚ → Finset ℕ} (h : PointwiseEquiv F G) (x : ℚ) :
    (F x).card = (G x).card := by
  obtain ⟨e⟩ := h x
  simpa using Fintype.card_congr e

/-- Pointwise equivalence is reflexive; in particular a constant family is pointwise
equivalent to itself, so the notion is not vacuous. -/
theorem pointwiseEquiv_refl (F : ℚ → Finset ℕ) : PointwiseEquiv F F := fun _ => ⟨Equiv.refl _⟩

/-- **Main theorem (Conjecture 1, witness form).**  For every degree `n ≥ 1` and every
coefficient vector, the fibre family of a tropical polynomial is *genuinely dependent*:
it is not pointwise equivalent to any constant family.  Corners are unavoidable. -/
theorem fiber_family_not_pointwise_constant {n : ℕ} (hn : 1 ≤ n) (c : ℕ → ℚ) :
    ¬ ∃ G : ℚ → Finset ℕ, IsConstantFamily G ∧ PointwiseEquiv (fiber n c) G := by
  rintro ⟨G, ⟨T, hT⟩, hequiv⟩
  obtain ⟨x, hx, hy⟩ := exists_corner hn c
  have h1 : (fiber n c x).card = T.card := by
    rw [card_eq_of_pointwiseEquiv hequiv x, hT x]
  have h2 : (fiber n c (x + 1)).card = T.card := by
    rw [card_eq_of_pointwiseEquiv hequiv (x + 1), hT (x + 1)]
  rw [hy] at h2
  simp only [Finset.card_singleton] at h2
  omega

/-! ## 2. Step polynomials: every admissible cardinality is realised -/

/-- The **step polynomial** of width `k`: the first `k` monomials are free, the rest
are penalised.  Its Newton polygon has a single lower edge of lattice length `k - 1`. -/
def stepCoeff (k : ℕ) : ℕ → ℚ := fun i => if i < k then 0 else 1

theorem stepCoeff_nonneg (k i : ℕ) : 0 ≤ stepCoeff k i := by
  unfold stepCoeff; split <;> norm_num

theorem stepCoeff_eq_zero_iff {k i : ℕ} : stepCoeff k i = 0 ↔ i < k := by
  unfold stepCoeff
  split <;> simp_all

/-- At the origin the step polynomial has a fibre of cardinality exactly `k`: all `k`
free monomials tie. -/
theorem fiber_stepCoeff_zero {n k : ℕ} (hk1 : 1 ≤ k) (hkn : k ≤ n + 1) :
    fiber n (stepCoeff k) 0 = range k := by
  ext i
  rw [mem_fiber_iff, mem_range]
  constructor
  · rintro ⟨_, hmin⟩
    have h0 := hmin 0 (Nat.zero_le n)
    have hz : stepCoeff k 0 = 0 := stepCoeff_eq_zero_iff.mpr hk1
    simp only [Nat.cast_zero, add_zero, mul_zero, hz] at h0
    have : stepCoeff k i = 0 := le_antisymm h0 (stepCoeff_nonneg k i)
    exact stepCoeff_eq_zero_iff.mp this
  · intro hik
    refine ⟨by omega, fun j _ => ?_⟩
    have hi : stepCoeff k i = 0 := stepCoeff_eq_zero_iff.mpr hik
    have hj : 0 ≤ stepCoeff k j := stepCoeff_nonneg k j
    simp only [mul_zero, add_zero, hi]
    exact hj

/-- At `x = 1` the step polynomial has a singleton fibre: the constant monomial wins
alone.  (Any `x > 0` would do; `1` keeps the arithmetic concrete.) -/
theorem fiber_stepCoeff_one {n k : ℕ} (hk1 : 1 ≤ k) :
    fiber n (stepCoeff k) 1 = {0} := by
  have hz : stepCoeff k 0 = 0 := stepCoeff_eq_zero_iff.mpr hk1
  have h0 : (0 : ℕ) ∈ fiber n (stepCoeff k) 1 := by
    refine mem_fiber_iff.mpr ⟨Nat.zero_le n, fun j _ => ?_⟩
    have hj : 0 ≤ stepCoeff k j := stepCoeff_nonneg k j
    have hjc : (0 : ℚ) ≤ (j : ℚ) := Nat.cast_nonneg j
    simp only [Nat.cast_zero, add_zero, mul_one, hz]
    linarith
  refine Finset.eq_singleton_iff_unique_mem.mpr ⟨h0, fun y hy => ?_⟩
  by_contra hy0
  obtain ⟨_, hmin⟩ := mem_fiber_iff.mp hy
  have h := hmin 0 (Nat.zero_le n)
  have hyc : (1 : ℚ) ≤ (y : ℚ) := by
    exact_mod_cast Nat.one_le_iff_ne_zero.mpr hy0
  have hyw : 0 ≤ stepCoeff k y := stepCoeff_nonneg k y
  simp only [Nat.cast_zero, add_zero, mul_one, hz] at h
  linarith

/-- **Dependent solutions at every nontrivial finite cardinality.**  For every `k` with
`2 ≤ k ≤ n + 1` there is a degree-`n` tropical polynomial whose fibre family has a
fibre of cardinality exactly `k` and a fibre of cardinality `1`.  The range
`k ≤ n + 1` is optimal by `fiber_card_le`; the constraints already force `n ≥ 1`, and
for the thread's range `n ≥ 2` at least the two values `k = 2, 3` are available
(`two_distinct_multiplicities`). -/
theorem dependent_solutions_at_every_cardinality {n k : ℕ} (hk : 2 ≤ k)
    (hkn : k ≤ n + 1) :
    ∃ c : ℕ → ℚ, ∃ x y : ℚ,
      (fiber n c x).card = k ∧ (fiber n c y).card = 1 ∧
        (fiber n c x).card ≠ (fiber n c y).card := by
  refine ⟨stepCoeff k, 0, 1, ?_, ?_, ?_⟩
  · rw [fiber_stepCoeff_zero (by omega) hkn, Finset.card_range]
  · rw [fiber_stepCoeff_one (n := n) (by omega), Finset.card_singleton]
  · rw [fiber_stepCoeff_zero (by omega) hkn, fiber_stepCoeff_one (n := n) (by omega)]
    simp only [Finset.card_range, Finset.card_singleton]
    omega

/-- Corollary: the witnessing family of the previous theorem is itself not pointwise
equivalent to a constant family — the two unequal fibres obstruct every candidate
bijection. -/
theorem step_family_not_pointwise_constant {n k : ℕ} (hk : 2 ≤ k) (hkn : k ≤ n + 1) :
    ¬ ∃ G : ℚ → Finset ℕ, IsConstantFamily G ∧ PointwiseEquiv (fiber n (stepCoeff k)) G := by
  rintro ⟨G, ⟨T, hT⟩, hequiv⟩
  have h0 : (fiber n (stepCoeff k) 0).card = T.card := by
    rw [card_eq_of_pointwiseEquiv hequiv 0, hT 0]
  have h1 : (fiber n (stepCoeff k) 1).card = T.card := by
    rw [card_eq_of_pointwiseEquiv hequiv 1, hT 1]
  rw [fiber_stepCoeff_zero (by omega) hkn, Finset.card_range] at h0
  rw [fiber_stepCoeff_one (n := n) (by omega), Finset.card_singleton] at h1
  omega

/-- **At least two distinct nontrivial multiplicities occur once `n ≥ 2`.**  Degree `2`
is the first degree at which the multiplicity spectrum itself is nondegenerate: both
`2` and `3` are realised, each together with a singleton fibre. -/
theorem two_distinct_multiplicities {n : ℕ} (hn : 2 ≤ n) :
    ∃ c₁ c₂ : ℕ → ℚ, ∃ x₁ x₂ y : ℚ,
      (fiber n c₁ x₁).card = 2 ∧ (fiber n c₂ x₂).card = 3 ∧
        (fiber n c₁ y).card = 1 ∧ (fiber n c₂ y).card = 1 := by
  refine ⟨stepCoeff 2, stepCoeff 3, 0, 0, 1, ?_, ?_, ?_, ?_⟩
  · rw [fiber_stepCoeff_zero (n := n) (by omega) (by omega), Finset.card_range]
  · rw [fiber_stepCoeff_zero (n := n) (by omega) (by omega), Finset.card_range]
  · rw [fiber_stepCoeff_one (n := n) (by omega), Finset.card_singleton]
  · rw [fiber_stepCoeff_one (n := n) (by omega), Finset.card_singleton]

/-- The maximal cardinality `n + 1` is realised, and it is the largest possible value:
the totally degenerate polynomial `stepCoeff (n+1)` saturates `fiber_card_le`. -/
theorem max_fiber_card_realised (n : ℕ) :
    (fiber n (stepCoeff (n + 1)) 0).card = n + 1 ∧
      ∀ (c : ℕ → ℚ) (x : ℚ), (fiber n c x).card ≤ n + 1 := by
  refine ⟨?_, fun c x => fiber_card_le n c x⟩
  rw [fiber_stepCoeff_zero (by omega) (le_refl (n + 1)), Finset.card_range]

/-! ## 3. Contrast with the catalog: the divisor argmin family *is* constant -/

/-- The argmin fibre of a weight over the divisor lattice of `N`: the divisors
realising the min-plus aggregate of `Tropical.FreeWitnessTropicalShadow`. -/
def divisorArgmin (w : ℕ → ℕ) (N : ℕ) : Finset ℕ :=
  N.divisors.filter fun d => ∀ e ∈ N.divisors, w d ≤ w e

/-- For a strictly monotone weight the divisor argmin fibre is `{1}` at every `N ≠ 0`:
the min-plus divisor aggregate only ever sees the bottom of the divisor lattice. -/
theorem divisorArgmin_eq_one {w : ℕ → ℕ} (hmono : StrictMono w) {N : ℕ} (hN : N ≠ 0) :
    divisorArgmin w N = {1} := by
  have h1 : (1 : ℕ) ∈ divisorArgmin w N := by
    rw [divisorArgmin, mem_filter]
    refine ⟨Nat.one_mem_divisors.mpr hN, fun e he => ?_⟩
    exact hmono.monotone (Nat.pos_of_mem_divisors he)
  refine Finset.eq_singleton_iff_unique_mem.mpr ⟨h1, fun d hd => ?_⟩
  rw [divisorArgmin, mem_filter] at hd
  have hle : w d ≤ w 1 := hd.2 1 (Nat.one_mem_divisors.mpr hN)
  have hd1 : d ≤ 1 := hmono.le_iff_le.mp hle
  have hdpos : 1 ≤ d := Nat.pos_of_mem_divisors hd.1
  omega

/-- Hence the divisor argmin family has constant fibre cardinality `1`: the catalog's
tropical divisor aggregate is a constant family, in sharp contrast with
`fiber_family_not_pointwise_constant`. -/
theorem divisorArgmin_card_constant {w : ℕ → ℕ} (hmono : StrictMono w) {N : ℕ} (hN : N ≠ 0) :
    (divisorArgmin w N).card = 1 := by
  rw [divisorArgmin_eq_one hmono hN, Finset.card_singleton]

/-- Compatibility with the catalog: every element of the divisor argmin fibre computes
the catalog's min-plus aggregate `FreeWitnessShadow.tropicalAggregate`. -/
theorem trop_argmin_eq_tropicalAggregate {w : ℕ → ℕ} (hmono : StrictMono w) {N : ℕ}
    (hN : N ≠ 0) {d : ℕ} (hd : d ∈ divisorArgmin w N) :
    Tropical.trop ((w d : ℕ) : WithTop ℕ) = FreeWitnessShadow.tropicalAggregate w N := by
  rw [FreeWitnessShadow.tropicalAggregate_eq_trop_one hmono.monotone hN]
  rw [divisorArgmin_eq_one hmono hN, Finset.mem_singleton] at hd
  rw [hd]

end TropicalDependentFibers