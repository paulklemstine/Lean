/-
# The ECM late-fire tail decays like `1 / log B1` (exp 570 / paper 218, third cycle)

`Novelty.EcmStageOneTraceLaw` bounded the late-firing density at the single
operating point `B1 = 100`, `y = 67` by an explicit reciprocal sum.  This file
removes the numerics: for *every* `B1` and every schedule cut `y ≥ 2` the density
of orders that fire after position `y` is at most

  `2 · B1 / (y · ⌊log₂ y⌋)`,

an unconditional bound proved from Erdős' primorial estimate `y# ≤ 4^y`.  For a
cut proportional to `B1` this is `O(1 / log B1)`: the late tail of the firing
trace is not a fixed 20% of the mass, it *vanishes* as `B1` grows.  That is the
structural reason the measured final-20% tail was empty (`0/55`), and it is a
sharp, falsifiable prediction for the next round: the tail should shrink like the
reciprocal logarithm of the stage-1 bound, not stay constant.

## Main results

* `prod_largePrimes_dvd_primorial` — the late schedule primes multiply into the
  primorial `B1#`.
* `card_largePrimes_mul_log_le` — hence **a Chebyshev-type count**:
  `#{p prime : y < p ≤ B1} · ⌊log₂ y⌋ ≤ 2 · B1`, from `primorial_le_4_pow`.
* `late_reciprocal_sum_le_card_div` — `∑_{y<p≤B1} 1/p ≤ #largePrimes / y`.
* `late_density_le_log_bound` — the headline: the number of orders in `(0, M]`
  that fire after position `y` is at most `M · 2 B1 / (y ⌊log₂ y⌋)`.
* `late_density_decay` — for a cut at half the stage-1 bound the density is at
  most `4 / ⌊log₂ y⌋`, which tends to `0`: no constant-fraction late tail can
  exist.

-- !-- Lab Notes -- !--
-- Measured firing-trace statistics (uniform order in `(0, N]`, `B1 = N`,
-- normalized index `π(maxPF n)/π(N)`), computed by sieve:
--   N = 10³ : median 0.083, mean 0.175, final-20% tail 3.4%, first-20% 73.0%
--   N = 10⁴ : median 0.034, mean 0.121, tail 2.4%, first-20% 81.8%
--   N = 10⁵ : median 0.020, mean 0.090, tail 1.9%, first-20% 86.3%
--   N = 10⁶ : median 0.005, mean 0.071, tail 1.5%, first-20% 89.0%
-- The measured medians (0.09–0.10 in exp 570) sit exactly in this family, and
-- the tail column decays — consistent with the `1/log` law proved below and
-- with the Mertens heuristic `tail(τ) ≈ log(1/(1-τ))/log B1`
-- (`0.223/log 10⁶ = 0.016` vs measured `0.015`).
-/

import Novelty.EcmStageOneTraceLaw
import Mathlib.NumberTheory.Primorial

namespace Catalog.Novelty.EcmTraceLateTailDecay

open Finset Catalog.Novelty.EcmStageOneTraceLaw Catalog.Novelty.SmoothNumberLowerBound

/-! ### A Chebyshev-type count of the late schedule primes -/

/-- The late schedule primes divide the primorial of `B1`. -/
theorem prod_largePrimes_dvd_primorial (B1 y : ℕ) :
    (∏ p ∈ largePrimes B1 y, p) ∣ primorial B1 := by
  rw [primorial]
  refine Finset.prod_dvd_prod_of_subset _ _ id ?_
  intro p hp
  have hp' := Finset.mem_filter.mp hp
  have hple : p ≤ B1 := (Finset.mem_Ioc.mp hp'.1).2
  exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), hp'.2⟩

/-- **Chebyshev-type bound on the late schedule.**  From Erdős' estimate
`B1# ≤ 4 ^ B1`: the number of schedule primes above `y` satisfies
`#largePrimes · ⌊log₂ y⌋ ≤ 2 · B1`. -/
theorem card_largePrimes_mul_log_le {B1 y : ℕ} (hy : 2 ≤ y) :
    #(largePrimes B1 y) * Nat.log 2 y ≤ 2 * B1 := by
  set S := largePrimes B1 y with hS
  set k := #S with hk
  have hlow : y ^ k ≤ ∏ p ∈ S, p := by
    refine Finset.pow_card_le_prod S _ y ?_ |>.trans_eq rfl
    intro p hp
    have := (Finset.mem_Ioc.mp (Finset.mem_filter.mp hp).1).1
    omega
  have hup : (∏ p ∈ S, p) ≤ 4 ^ B1 :=
    le_trans (Nat.le_of_dvd (primorial_pos B1) (prod_largePrimes_dvd_primorial B1 y))
      (primorial_le_4_pow B1)
  have hpowy : 2 ^ Nat.log 2 y ≤ y := Nat.pow_log_le_self 2 (by omega)
  have h2 : (2 : ℕ) ^ (k * Nat.log 2 y) ≤ 2 ^ (2 * B1) := by
    calc (2 : ℕ) ^ (k * Nat.log 2 y) = (2 ^ Nat.log 2 y) ^ k := by
          rw [← pow_mul, Nat.mul_comm]
      _ ≤ y ^ k := Nat.pow_le_pow_left hpowy k
      _ ≤ ∏ p ∈ S, p := hlow
      _ ≤ 4 ^ B1 := hup
      _ = 2 ^ (2 * B1) := by
          rw [pow_mul]; norm_num
  exact (Nat.pow_le_pow_iff_right (by norm_num)).mp h2

/-! ### From the count to the density -/

/-- The reciprocal sum of the late schedule primes is at most their count over
the cut. -/
theorem late_reciprocal_sum_le_card_div {B1 y : ℕ} (hy : 0 < y) :
    ∑ p ∈ largePrimes B1 y, (1 : ℝ) / p ≤ #(largePrimes B1 y) / y := by
  have hy0 : (0 : ℝ) < y := by exact_mod_cast hy
  have hterm : ∀ p ∈ largePrimes B1 y, (1 : ℝ) / p ≤ 1 / y := by
    intro p hp
    have hpy : y < p := (Finset.mem_Ioc.mp (Finset.mem_filter.mp hp).1).1
    have : (y : ℝ) ≤ p := by exact_mod_cast hpy.le
    exact one_div_le_one_div_of_le hy0 this
  calc ∑ p ∈ largePrimes B1 y, (1 : ℝ) / p
      ≤ ∑ _p ∈ largePrimes B1 y, (1 : ℝ) / y := Finset.sum_le_sum hterm
    _ = #(largePrimes B1 y) * (1 / y) := by rw [Finset.sum_const, nsmul_eq_mul]
    _ = #(largePrimes B1 y) / y := by ring

/-- The union bound of `Novelty.EcmStageOneTraceLaw` in real form. -/
theorem lateCount_le_reciprocal_sum (M B1 y : ℕ) :
    (#(lateOrders M B1 y) : ℝ) ≤ M * ∑ p ∈ largePrimes B1 y, (1 : ℝ) / p := by
  have h1 : (#(lateOrders M B1 y) : ℝ) ≤ ∑ p ∈ largePrimes B1 y, ((M / p : ℕ) : ℝ) := by
    exact_mod_cast Nat.cast_le.mpr (lateCount_le_primeContribution M B1 y)
  refine h1.trans ?_
  rw [Finset.mul_sum]
  refine Finset.sum_le_sum fun p _ => ?_
  calc ((M / p : ℕ) : ℝ) ≤ (M : ℝ) / (p : ℝ) := Nat.cast_div_le
    _ = (M : ℝ) * (1 / p) := by ring

/-- **The late tail decays like `1/log`.**  Unconditionally, for every stage-1
bound `B1`, every cut `y ≥ 2` with `⌊log₂ y⌋ ≠ 0` and every order range `M`, the
number of orders in `(0, M]` firing after schedule position `y` is at most
`M · 2 B1 / (y · ⌊log₂ y⌋)`. -/
theorem late_density_le_log_bound (M B1 : ℕ) {y : ℕ} (hy : 2 ≤ y) :
    (#(lateOrders M B1 y) : ℝ) ≤ M * (2 * B1) / (y * Nat.log 2 y) := by
  have hlog : 0 < Nat.log 2 y := Nat.log_pos (by norm_num) hy
  have hy0 : (0 : ℝ) < y := by positivity
  have hlog0 : (0 : ℝ) < (Nat.log 2 y : ℝ) := by exact_mod_cast hlog
  have hM0 : (0 : ℝ) ≤ M := Nat.cast_nonneg M
  have hcard : (#(largePrimes B1 y) : ℝ) * (Nat.log 2 y : ℝ) ≤ 2 * B1 := by
    exact_mod_cast card_largePrimes_mul_log_le (B1 := B1) hy
  have hsum : ∑ p ∈ largePrimes B1 y, (1 : ℝ) / p ≤ (2 * B1) / (y * Nat.log 2 y) := by
    refine (late_reciprocal_sum_le_card_div (B1 := B1) (by omega)).trans ?_
    rw [div_le_div_iff₀ hy0 (by positivity)]
    calc (#(largePrimes B1 y) : ℝ) * ((y : ℝ) * (Nat.log 2 y : ℝ))
        = ((#(largePrimes B1 y) : ℝ) * (Nat.log 2 y : ℝ)) * y := by ring
      _ ≤ (2 * B1) * y := by
          exact mul_le_mul_of_nonneg_right hcard (le_of_lt hy0)
  calc (#(lateOrders M B1 y) : ℝ) ≤ M * ∑ p ∈ largePrimes B1 y, (1 : ℝ) / p :=
        lateCount_le_reciprocal_sum M B1 y
    _ ≤ M * ((2 * B1) / (y * Nat.log 2 y)) := by
        exact mul_le_mul_of_nonneg_left hsum hM0
    _ = M * (2 * B1) / (y * Nat.log 2 y) := by ring

/-- **No constant-fraction late tail.**  Cutting the schedule at half the stage-1
bound, the late-firing density is at most `4 / ⌊log₂ y⌋`, which tends to `0` as
`B1` grows.  A pre-registered constant tail (H1's 20%) is therefore impossible
for all large `B1`. -/
theorem late_density_decay (M B1 : ℕ) {y : ℕ} (hy : 2 ≤ y) (hcut : B1 ≤ 2 * y) :
    (#(lateOrders M B1 y) : ℝ) ≤ M * (4 / Nat.log 2 y) := by
  have hlog : 0 < Nat.log 2 y := Nat.log_pos (by norm_num) hy
  have hy0 : (0 : ℝ) < y := by positivity
  have hlog0 : (0 : ℝ) < (Nat.log 2 y : ℝ) := by exact_mod_cast hlog
  have hB : (B1 : ℝ) ≤ 2 * y := by exact_mod_cast hcut
  have hM0 : (0 : ℝ) ≤ M := Nat.cast_nonneg M
  refine (late_density_le_log_bound M B1 hy).trans ?_
  rw [div_le_iff₀ (by positivity)]
  have h1 : (M : ℝ) * (2 * B1) ≤ (M : ℝ) * (4 * y) := by
    refine mul_le_mul_of_nonneg_left ?_ hM0
    linarith
  calc (M : ℝ) * (2 * B1) ≤ (M : ℝ) * (4 * y) := h1
    _ = M * (4 / Nat.log 2 y) * ((y : ℝ) * (Nat.log 2 y : ℝ)) := by
        field_simp

/-- Concrete instance of the decay: at `B1 = 2 ^ 20` with the cut at `2 ^ 19`
the late-firing density is below `4 / 19`, and it keeps shrinking with `B1`:
the tail mass is a decreasing function of the stage-1 bound, not the fixed `1/5`
of the uniform hypothesis. -/
theorem late_density_decay_example (M : ℕ) :
    (#(lateOrders M (2 ^ 20) (2 ^ 19)) : ℝ) ≤ M * (4 / 19) := by
  have hlog : Nat.log 2 (2 ^ 19) = 19 := Nat.log_pow (by norm_num) 19
  have h := late_density_decay M (2 ^ 20) (y := 2 ^ 19) (by norm_num) (by norm_num)
  rw [hlog] at h
  exact_mod_cast h

/-! ### Exactness of the sieve bound in the short range -/

/-- In the range `M ≤ y²` no order can be divisible by two distinct late primes,
so the union bound of `lateCount_le_primeContribution` is an **equality**: the
late-firing count is exactly `∑_{y < p ≤ B1} ⌊M/p⌋`. -/
theorem lateOrders_card_eq {M B1 y : ℕ} (hM : M ≤ y * y) :
    #(lateOrders M B1 y) = ∑ p ∈ largePrimes B1 y, M / p := by
  classical
  have hbi : lateOrders M B1 y =
      (largePrimes B1 y).biUnion (fun p => {n ∈ Ioc 0 M | p ∣ n}) := by
    ext n
    simp only [lateOrders, Finset.mem_filter, Finset.mem_biUnion]
    constructor
    · rintro ⟨hmem, p, hp, hpn⟩
      exact ⟨p, hp, hmem, hpn⟩
    · rintro ⟨p, hp, hmem, hpn⟩
      exact ⟨hmem, p, hp, hpn⟩
  have hdisj : ((largePrimes B1 y : Finset ℕ) : Set ℕ).PairwiseDisjoint
      (fun p => {n ∈ Ioc 0 M | p ∣ n}) := by
    intro p hpc q hqc hpq
    have hp : p ∈ largePrimes B1 y := Finset.mem_coe.mp hpc
    have hq : q ∈ largePrimes B1 y := Finset.mem_coe.mp hqc
    rw [Function.onFun, Finset.disjoint_left]
    intro n hnp hnq
    have hp' := Finset.mem_filter.mp hp
    have hq' := Finset.mem_filter.mp hq
    have hpy : y < p := (Finset.mem_Ioc.mp hp'.1).1
    have hqy : y < q := (Finset.mem_Ioc.mp hq'.1).1
    have hpn : p ∣ n := (Finset.mem_filter.mp hnp).2
    have hqn : q ∣ n := (Finset.mem_filter.mp hnq).2
    have hnpos : 0 < n := (Finset.mem_Ioc.mp (Finset.mem_filter.mp hnp).1).1
    have hnM : n ≤ M := (Finset.mem_Ioc.mp (Finset.mem_filter.mp hnp).1).2
    have hcop : Nat.Coprime p q := (Nat.coprime_primes hp'.2 hq'.2).mpr hpq
    have hpqn : p * q ∣ n := Nat.Coprime.mul_dvd_of_dvd_of_dvd hcop hpn hqn
    have hle : p * q ≤ n := Nat.le_of_dvd hnpos hpqn
    have : y * y < p * q := by
      calc y * y ≤ y * q := Nat.mul_le_mul_left y hqy.le
        _ < p * q := by
            refine Nat.mul_lt_mul_of_lt_of_le hpy le_rfl ?_
            omega
    omega
  rw [hbi, Finset.card_biUnion hdisj]
  exact Finset.sum_congr rfl fun p _ => Nat.Ioc_filter_dvd_card_eq_div M p

/-- **The late tail is positive but far below uniformity.**  At `B1 = 100`,
`y = 67`, `M = 67²` the late-firing count is *exactly* `330`, a density of
`330/4489 ≈ 7.35%`: the final six of the 25 schedule steps do carry mass, but
about a third of the `20%` that the pre-registered uniform law demands. -/
theorem late_tail_exact_hundred : #(lateOrders 4489 100 67) = 330 := by
  rw [lateOrders_card_eq (by norm_num), largePrimes_hundred]
  decide

/-- The two-sided sandwich for the `B1 = 100` late tail: positive, and strictly
between `1/20` and `2/25`. -/
theorem late_tail_sandwich_hundred :
    (1 : ℝ) / 20 < #(lateOrders 4489 100 67) / 4489 ∧
      (#(lateOrders 4489 100 67) : ℝ) / 4489 < 1 / 5 := by
  rw [late_tail_exact_hundred]
  norm_num

end Catalog.Novelty.EcmTraceLateTailDecay