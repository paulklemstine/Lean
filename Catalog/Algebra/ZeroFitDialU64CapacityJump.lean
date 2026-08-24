import Mathlib
import Algebra.ZeroFitDialU72Parity
import Algebra.ZeroFitDialParityCapacity
import Algebra.ZeroFitDialU64Replication
import Algebra.ZeroFitDialU64MedianCapacity

/-!
# The dial capacity staircase and its phase transition

## Research context

Fourth cycle on the `U64B-DIAL-HOLDS-COUNT-PARITY` record (exp 543).  Conjecture **D3**
of the thread proposed that the count-parity verdict is a *capacity* phenomenon: define
the dial capacity

  `K(ρ, γ) = max { k : k·ρ² ≤ 1 + (k-1)γ }`

from the interpolating law `correlated_family_capacity`, and the conjecture is that the
bitlen at which the verdict flips is the bitlen at which `K` steps from `2` to `3`.  D3
was stated without a closed form for `K` and without any proof that `K` is even
well-defined — a priori the admissible family sizes need not form an initial segment.
This file supplies the missing structure and turns the numerical claim
`K(0.641, 0.1) = 2`, `K(0.641, 0.2) = 3` into theorems.

## Main results

* `dial_admissible_iff_threshold` — for `k ≥ 2` a `k`-family is admissible at reading `ρ`
  exactly when the mutual correlation clears the **threshold**
  `dialThreshold ρ k = (k·ρ² - 1)/(k - 1)`.  Capacity is therefore a threshold condition
  in `γ`, not merely an inequality.
* `dialThreshold_strictMono` — for a sub-unit reading `ρ² < 1` the thresholds are strictly
  increasing in `k`.  Hence `dial_admissible_of_le`: the admissible sizes form an initial
  segment and `K(ρ, γ)` is well defined.
* `dial_admissible_iff_le_floor` — the closed form conjectured in D3:
  for `γ < ρ² ` and `γ ≤ 1`, a `k`-family is admissible iff `k ≤ ⌊(1-γ)/(ρ²-γ)⌋`.
* `capacity_phase_transition` — the sharp transition.  Below `dialThreshold ρ k` **no**
  `γ`-family of size `k` can read `ρ`, in *any* ambient dimension; exactly at
  `dialThreshold ρ k` one exists, in dimension `k+1`.  So the threshold is not an artefact
  of the bound: it is the true boundary of the realisable region.
* `u64b_threshold_three`, `u64b_threshold_four` — at the replicated reading `0.641` the
  thresholds are `0.1163215` and `0.214508` exactly.  The first coincides with the pair
  floor of `u64b_triple_correlation_floor`, which is thereby re-derived as a phase
  boundary rather than as a Cauchy–Schwarz by-product.
* `u64b_capacity_exactly_two_at_gamma_tenth`,
  `u64b_capacity_exactly_three_at_gamma_fifth` — the two cells of D3 are proved: at
  `γ = 0.1` a pair reads the dial but no triple can, and at `γ = 0.2` a triple reads the
  dial but no quadruple can.  The capacity really does step from `2` to `3` as `γ` crosses
  the interval `[0.1163215, 0.214508)`.
* `u64b_capacity_jump_window` — the crossing window, stated as a chain of strict
  inequalities on the thresholds.

## Scientific payload

D3's mechanism is confirmed *as algebra*: the capacity is a staircase in `γ` with
explicitly computable risers, and the recorded cell sits one riser below the value at
which a third statistic becomes admissible.  What the algebra cannot decide is whether the
measured mutual correlation `γ_b` of the trailing-zero and popcount statistics actually
crosses `0.1163215` at the observed flip bitlen; that is now a single one-parameter
measurement, which is exactly the shape of test the thread wanted.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU64CapacityJump

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialParityCapacity
open Catalog.Algebra.ZeroFitDialU64Replication
open Catalog.Algebra.ZeroFitDialU64MedianCapacity

/-! ## 1. Admissibility and the threshold -/

/-- A family size `k` is *admissible* at reading `rho` and mutual correlation `gamma` when
the interpolating capacity law permits it. -/
def DialAdmissible (rho gamma : ℝ) (k : ℕ) : Prop :=
  (k : ℝ) * rho ^ 2 ≤ 1 + ((k : ℝ) - 1) * gamma

/-- The minimal mutual correlation at which a family of size `k` can read `rho`. -/
noncomputable def dialThreshold (rho : ℝ) (k : ℕ) : ℝ :=
  ((k : ℝ) * rho ^ 2 - 1) / ((k : ℝ) - 1)

lemma one_lt_cast_of_two_le {k : ℕ} (hk : 2 ≤ k) : (1 : ℝ) < (k : ℝ) := by
  have : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  linarith

/-- **Capacity is a threshold condition.**  For `k ≥ 2` the family size `k` is admissible
precisely when `gamma` clears `dialThreshold rho k`. -/
theorem dial_admissible_iff_threshold {rho gamma : ℝ} {k : ℕ} (hk : 2 ≤ k) :
    DialAdmissible rho gamma k ↔ dialThreshold rho k ≤ gamma := by
  have hpos : (0 : ℝ) < (k : ℝ) - 1 := by linarith [one_lt_cast_of_two_le hk]
  rw [DialAdmissible, dialThreshold, div_le_iff₀ hpos]
  constructor <;> intro h <;> linarith

/-- **The thresholds strictly increase with family size** whenever the reading is sub-unit.
This is what makes the capacity a well-defined staircase. -/
theorem dialThreshold_strictMono {rho : ℝ} (hrho : rho ^ 2 < 1) {j k : ℕ}
    (hj : 2 ≤ j) (hjk : j < k) : dialThreshold rho j < dialThreshold rho k := by
  have hjR : (1 : ℝ) < (j : ℝ) := one_lt_cast_of_two_le hj
  have hjkR : (j : ℝ) < (k : ℝ) := by exact_mod_cast hjk
  have hj1 : (0 : ℝ) < (j : ℝ) - 1 := by linarith
  have hk1 : (0 : ℝ) < (k : ℝ) - 1 := by linarith
  rw [dialThreshold, dialThreshold, div_lt_div_iff₀ hj1 hk1]
  nlinarith [hjkR, hrho]

/-- Admissible family sizes form an initial segment, so the dial capacity
`K(ρ, γ) = max {k : admissible}` is well defined. -/
theorem dial_admissible_of_le {rho gamma : ℝ} (hrho : rho ^ 2 < 1) {j k : ℕ}
    (hj : 2 ≤ j) (hjk : j ≤ k) (h : DialAdmissible rho gamma k) :
    DialAdmissible rho gamma j := by
  rcases eq_or_lt_of_le hjk with rfl | hlt
  · exact h
  · have hk : 2 ≤ k := le_trans hj (le_of_lt hlt)
    rw [dial_admissible_iff_threshold hj]
    exact le_trans (le_of_lt (dialThreshold_strictMono hrho hj hlt))
      ((dial_admissible_iff_threshold hk).mp h)

/-- **The closed form of the dial capacity** conjectured in D3: below the reading level,
admissibility of `k` is the arithmetic condition `k ≤ ⌊(1-γ)/(ρ²-γ)⌋`. -/
theorem dial_admissible_iff_le_floor {rho gamma : ℝ} {k : ℕ}
    (hlt : gamma < rho ^ 2) (hg1 : gamma ≤ 1) :
    DialAdmissible rho gamma k ↔ k ≤ ⌊(1 - gamma) / (rho ^ 2 - gamma)⌋₊ := by
  have hden : (0 : ℝ) < rho ^ 2 - gamma := by linarith
  have hnum : (0 : ℝ) ≤ 1 - gamma := by linarith
  have hquot : (0 : ℝ) ≤ (1 - gamma) / (rho ^ 2 - gamma) := div_nonneg hnum (le_of_lt hden)
  rw [Nat.le_floor_iff hquot, le_div_iff₀ hden, DialAdmissible]
  constructor <;> intro h <;> nlinarith [h]

/-! ## 2. The phase transition -/

/-- Below the threshold no family of the given size exists, in any ambient dimension. -/
theorem no_family_below_threshold {rho gamma : ℝ} {k : ℕ} (hk : 2 ≤ k) (hrho : 0 ≤ rho)
    (hbelow : gamma < dialThreshold rho k) :
    ¬ ∃ (n : ℕ) (u : Fin k → (Fin n → ℝ)) (w : Fin n → ℝ),
        IsGammaFamily u gamma ∧ dot w w = 1 ∧ ∀ i, rho ≤ dot (u i) w := by
  rintro ⟨n, u, w, hu, hw, hread⟩
  have hcap : DialAdmissible rho gamma k :=
    correlated_family_capacity hu hw hrho (le_trans (by norm_num) hk) hread
  exact absurd ((dial_admissible_iff_threshold hk).mp hcap) (not_le.mpr hbelow)

/-- Whenever the reading level is under the equidistant realiser's level, a family of the
given size and mutual correlation exists in dimension `k+1`. -/
theorem exists_family_of_reading_le {rho gamma : ℝ} {k : ℕ} (hg0 : 0 ≤ gamma)
    (hg1 : gamma ≤ 1) (hk : 1 ≤ k) (hrho : 0 ≤ rho)
    (hle : rho ^ 2 ≤ (1 + ((k : ℝ) - 1) * gamma) / (k : ℝ)) :
    ∃ (u : Fin k → (Fin (k + 1) → ℝ)) (w : Fin (k + 1) → ℝ),
      IsGammaFamily u gamma ∧ dot w w = 1 ∧ ∀ i, rho ≤ dot (u i) w := by
  obtain ⟨u, w, h1, h2, h3, h4, -⟩ := capacity_realizable_equidistant hg0 hg1 hk
  refine ⟨u, w, ⟨h1, fun i j hij => le_of_eq (h2 i j hij)⟩, h3, fun i => ?_⟩
  rw [h4 i]
  have hnn : (0 : ℝ) ≤ (1 + ((k : ℝ) - 1) * gamma) / (k : ℝ) := le_trans (sq_nonneg rho) hle
  exact (Real.le_sqrt hrho hnn).mpr hle

/-- **The capacity phase transition.**  For a sub-unit reading `rho` and a family size
`k ≥ 2`, the value `dialThreshold rho k` is exactly the boundary of realisability: strictly
below it no `gamma`-family of size `k` reads `rho` in any dimension, and at it one does. -/
theorem capacity_phase_transition {rho : ℝ} {k : ℕ} (hk : 2 ≤ k) (hrho : 0 ≤ rho)
    (hg0 : 0 ≤ dialThreshold rho k) (hg1 : dialThreshold rho k ≤ 1) :
    (∀ gamma < dialThreshold rho k,
        ¬ ∃ (n : ℕ) (u : Fin k → (Fin n → ℝ)) (w : Fin n → ℝ),
          IsGammaFamily u gamma ∧ dot w w = 1 ∧ ∀ i, rho ≤ dot (u i) w)
      ∧ ∃ (u : Fin k → (Fin (k + 1) → ℝ)) (w : Fin (k + 1) → ℝ),
          IsGammaFamily u (dialThreshold rho k) ∧ dot w w = 1 ∧ ∀ i, rho ≤ dot (u i) w := by
  refine ⟨fun gamma hgamma => no_family_below_threshold hk hrho hgamma, ?_⟩
  have hkR : (1 : ℝ) < (k : ℝ) := one_lt_cast_of_two_le hk
  have hkpos : (0 : ℝ) < (k : ℝ) := by linarith
  refine exists_family_of_reading_le hg0 hg1 (le_trans (by norm_num) hk) hrho ?_
  rw [le_div_iff₀ hkpos]
  have hadm : DialAdmissible rho (dialThreshold rho k) k :=
    (dial_admissible_iff_threshold hk).mpr le_rfl
  rw [DialAdmissible] at hadm
  linarith

/-! ## 3. The recorded cell -/

/-- The replicated pooled reading of the bitlen-64 uniform cell. -/
noncomputable def rho64 : ℝ := 641 / 1000

/-- At the recorded reading, a triple needs mutual correlation at least `0.1163215` —
exactly the floor of `u64b_triple_correlation_floor`. -/
theorem u64b_threshold_three : dialThreshold rho64 3 = 232643 / 2000000 := by
  rw [dialThreshold, rho64]; norm_num

/-- At the recorded reading, a quadruple needs mutual correlation at least `0.214508`. -/
theorem u64b_threshold_four : dialThreshold rho64 4 = 53627 / 250000 := by
  rw [dialThreshold, rho64]; norm_num

/-- **The crossing window.**  The recorded reading places the capacity riser from `3` to
`4` strictly above `0.2`, and the riser from `2` to `3` strictly above `0.1`: the recorded
mutual correlation must cross `0.1163215` before a third statistic becomes admissible. -/
theorem u64b_capacity_jump_window :
    (1 : ℝ) / 10 < dialThreshold rho64 3 ∧ dialThreshold rho64 3 < (1 : ℝ) / 5 ∧
      (1 : ℝ) / 5 < dialThreshold rho64 4 := by
  refine ⟨?_, ?_, ?_⟩ <;> rw [dialThreshold, rho64] <;> norm_num

/-- **Capacity is exactly two at `γ = 0.1`.**  A pair of statistics with mutual correlation
`0.1` reads the replicated dial value, but no triple can — in any ambient dimension. -/
theorem u64b_capacity_exactly_two_at_gamma_tenth :
    (∃ (u : Fin 2 → (Fin 3 → ℝ)) (w : Fin 3 → ℝ),
        IsGammaFamily u (1 / 10) ∧ dot w w = 1 ∧ ∀ i, rho64 ≤ dot (u i) w) ∧
      ¬ ∃ (n : ℕ) (u : Fin 3 → (Fin n → ℝ)) (w : Fin n → ℝ),
          IsGammaFamily u (1 / 10) ∧ dot w w = 1 ∧ ∀ i, rho64 ≤ dot (u i) w := by
  constructor
  · refine exists_family_of_reading_le (by norm_num) (by norm_num) (by norm_num)
      (by rw [rho64]; norm_num) ?_
    rw [rho64]; norm_num
  · refine no_family_below_threshold (by norm_num) (by rw [rho64]; norm_num) ?_
    rw [u64b_threshold_three]; norm_num

/-- **Capacity is exactly three at `γ = 0.2`.**  A triple of statistics with mutual
correlation `0.2` reads the replicated dial value, but no quadruple can. -/
theorem u64b_capacity_exactly_three_at_gamma_fifth :
    (∃ (u : Fin 3 → (Fin 4 → ℝ)) (w : Fin 4 → ℝ),
        IsGammaFamily u (1 / 5) ∧ dot w w = 1 ∧ ∀ i, rho64 ≤ dot (u i) w) ∧
      ¬ ∃ (n : ℕ) (u : Fin 4 → (Fin n → ℝ)) (w : Fin n → ℝ),
          IsGammaFamily u (1 / 5) ∧ dot w w = 1 ∧ ∀ i, rho64 ≤ dot (u i) w := by
  constructor
  · refine exists_family_of_reading_le (by norm_num) (by norm_num) (by norm_num)
      (by rw [rho64]; norm_num) ?_
    rw [rho64]; norm_num
  · refine no_family_below_threshold (by norm_num) (by rw [rho64]; norm_num) ?_
    rw [u64b_threshold_four]; norm_num

/-- The capacity staircase at the recorded reading, in floor form: at `γ = 0.1` the closed
form of `dial_admissible_iff_le_floor` returns `2`, and at `γ = 0.2` it returns `3`. -/
theorem u64b_capacity_floor_values :
    ⌊(1 - (1 : ℝ) / 10) / (rho64 ^ 2 - 1 / 10)⌋₊ = 2 ∧
      ⌊(1 - (1 : ℝ) / 5) / (rho64 ^ 2 - 1 / 5)⌋₊ = 3 := by
  constructor
  · rw [rho64, show (1 - (1 : ℝ) / 10) / ((641 / 1000 : ℝ) ^ 2 - 1 / 10)
        = 900000 / 310881 by norm_num]
    rw [Nat.floor_eq_iff (by norm_num)]
    norm_num
  · rw [rho64, show (1 - (1 : ℝ) / 5) / ((641 / 1000 : ℝ) ^ 2 - 1 / 5)
        = 800000 / 210881 by norm_num]
    rw [Nat.floor_eq_iff (by norm_num)]
    norm_num

end Catalog.Algebra.ZeroFitDialU64CapacityJump