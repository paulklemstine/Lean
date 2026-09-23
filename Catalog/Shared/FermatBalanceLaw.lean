import Shared.FermatGapLocality

/-!
# The balance-ratio law for Fermat's method

The gap-local identity `fermatSteps_eq` says the cost of Fermat's method on
`N = p·q` is `(p+q)/2 - √N` (up to the `⌊·⌋+1` boundary term).  This file turns
that identity into the **scaling law in the balance ratio** `r = q/p`, which is
what a measured cost grid at fixed `p` actually exhibits, and it verifies the
law against an exact, formally computed grid row.

## Main results

* `fermat_cost_p_units` : in units of `p`, the cost depends *only* on the
  balance ratio: `(p + rp)/2 - √(p·rp) = p·(√r - 1)²/2`.
* `fermat_cost_ratio_law` : as a fraction of the cofactor-linear limit
  `(q-p)/2 = p(r-1)/2`, the cost is `(√r - 1)/(√r + 1)` — a quantity that tends
  to `1` only as `r → ∞`, so Fermat never quite reaches the cofactor-linear
  cost.
* `fermatSteps_two_mul_add_two_le` : the corresponding sharp `ℕ` statement,
  `2·steps + 2 ≤ q - p`.
* `grid_row_p101` : the six exact iteration counts of the balance-ratio grid at
  `p = 101`, `r ≈ 2, 4, 8, 16, 32, 64`, each derived from the identity — the
  formal replication of the measured row
  `352 → 100282`-style scaling, here `10, 51, 169, 455, 1102, 2476`, whose
  `p`-unit values `0.099 … 24.515` match `(√r - 1)²/2`.
-/

namespace FermatGapLocality

/-! ### The law in real variables -/

/-- **Cost in `p`-units depends only on the balance ratio.**  Writing `q = r·p`,
the AM–GM gap that Fermat's method must traverse is `p·(√r - 1)²/2`.  At
`r = 2, 4, 16, 64` this gives `0.0858…, 0.5, 4.5, 24.5`. -/
theorem fermat_cost_p_units {p r : ℝ} (hp : 0 < p) (hr : 0 ≤ r) :
    (p + r * p) / 2 - Real.sqrt (p * (r * p)) = p * (Real.sqrt r - 1) ^ 2 / 2 := by
  have hsr : Real.sqrt r ^ 2 = r := Real.sq_sqrt hr
  have hrw : p * (r * p) = r * (p * p) := by ring
  have hsqrt : Real.sqrt (p * (r * p)) = Real.sqrt r * p := by
    rw [hrw, Real.sqrt_mul hr, Real.sqrt_mul_self hp.le]
  rw [hsqrt]
  nlinarith [hsr]

/-- **Fraction of the cofactor-linear limit.**  The cofactor-linear cost of an
`r`-unbalanced semiprime is `(q-p)/2 = p(r-1)/2`; Fermat pays exactly the
fraction `(√r - 1)/(√r + 1)` of it.  At `r = 64` this is `7/9 = 0.777…`. -/
theorem fermat_cost_ratio_law {p r : ℝ} (hp : 0 < p) (hr : 1 < r) :
    ((p + r * p) / 2 - Real.sqrt (p * (r * p))) / ((r * p - p) / 2)
      = (Real.sqrt r - 1) / (Real.sqrt r + 1) := by
  have hr0 : (0:ℝ) ≤ r := by linarith
  have hsr : Real.sqrt r ^ 2 = r := Real.sq_sqrt hr0
  have hsr1 : 1 < Real.sqrt r := by
    nlinarith [Real.sqrt_nonneg r, hsr]
  have hnum := fermat_cost_p_units hp hr0
  have hden : (r * p - p) / 2 = p * (Real.sqrt r - 1) * (Real.sqrt r + 1) / 2 := by
    nlinarith [hsr]
  have h1 : Real.sqrt r - 1 ≠ 0 := by nlinarith
  have h2 : Real.sqrt r + 1 ≠ 0 := by nlinarith [Real.sqrt_nonneg r]
  rw [hnum, hden]
  field_simp

/-- The `p`-unit law is exact at `r = 64`: the cost is `24.5 · p`. -/
theorem fermat_cost_p_units_64 {p : ℝ} (hp : 0 < p) :
    (p + 64 * p) / 2 - Real.sqrt (p * (64 * p)) = 24.5 * p := by
  have h := fermat_cost_p_units hp (by norm_num : (0:ℝ) ≤ 64)
  have h64 : Real.sqrt 64 = 8 := by
    rw [show (64:ℝ) = 8 ^ 2 by norm_num, Real.sqrt_sq (by norm_num : (0:ℝ) ≤ 8)]
  rw [h, h64]
  ring

/-! ### The sharp `ℕ` bound: Fermat never reaches the cofactor-linear cost -/

/-- Fermat's cost on `p·q` is strictly below the cofactor-linear limit
`(q-p)/2`: precisely, `2·steps + 2 ≤ q - p`. -/
theorem fermatSteps_two_mul_add_two_le {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hpq : p < q) :
    2 * fermatSteps (p * q) + 2 ≤ q - p := by
  have hkey := fermatSteps_add_start hp hq hp2 hpq
  have hple : p ≤ Nat.sqrt (p * q) := Nat.le_sqrt.mpr (Nat.mul_le_mul_left p hpq.le)
  simp only [fermatStart] at hkey
  have hpodd : Odd p := hp.odd_of_ne_two hp2
  have hqodd : Odd q := hq.odd_of_ne_two (by rintro rfl; have := hp.two_le; omega)
  obtain ⟨j, hj⟩ := hpodd
  obtain ⟨l, hl⟩ := hqodd
  omega

/-- **Exact characterisation of the zero-cost regime.**  Fermat's method halts
without a single increment precisely when the target `(p+q)/2` is only one
above `⌊√N⌋`, i.e. when `((p+q)/2 - 1)² ≤ pq`.  The sufficient condition
`(q-p-2)² ≤ 8p` of `fermatSteps_eq_zero_of_small_gap` is the convenient
gap-shaped form of this inequality. -/
theorem fermatSteps_eq_zero_iff {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp2 : p ≠ 2) (hpq : p < q) :
    fermatSteps (p * q) = 0 ↔ ((p + q) / 2 - 1) * ((p + q) / 2 - 1) ≤ p * q := by
  have key := fermatSteps_add_start hp hq hp2 hpq
  simp only [fermatStart] at key
  constructor
  · intro h0
    have hrw : (p + q) / 2 - 1 = Nat.sqrt (p * q) := by omega
    rw [hrw]
    exact Nat.sqrt_le (p * q)
  · intro hle
    have h1 : (p + q) / 2 - 1 ≤ Nat.sqrt (p * q) := Nat.le_sqrt.mpr hle
    omega

/-! ### Formal replication of a measured grid row -/

private lemma sqrt_val {k N : ℕ} (h1 : k * k ≤ N) (h2 : N < (k + 1) * (k + 1)) :
    Nat.sqrt N = k := by
  have hle : k ≤ Nat.sqrt N := Nat.le_sqrt.mpr h1
  have hlt : Nat.sqrt N < k + 1 := by
    by_contra hcon
    push_neg at hcon
    have hmul : (k + 1) * (k + 1) ≤ Nat.sqrt N * Nat.sqrt N := Nat.mul_le_mul hcon hcon
    have := Nat.sqrt_le N
    omega
  omega

/-- **The balance-ratio grid at `p = 101`, formally computed.**  For the six
primes `q` nearest `2p, 4p, 8p, 16p, 32p, 64p`, Fermat's method takes
`10, 51, 169, 455, 1102, 2476` iterations.  In `p`-units these are
`0.099, 0.505, 1.673, 4.505, 10.911, 24.515`, matching the law
`(√r - 1)²/2` of `fermat_cost_p_units`. -/
theorem grid_row_p101 :
    fermatSteps (101 * 211) = 10 ∧
    fermatSteps (101 * 409) = 51 ∧
    fermatSteps (101 * 809) = 169 ∧
    fermatSteps (101 * 1619) = 455 ∧
    fermatSteps (101 * 3251) = 1102 ∧
    fermatSteps (101 * 6469) = 2476 := by
  have hp : Nat.Prime 101 := by norm_num
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · have h := fermatSteps_eq hp (by norm_num : Nat.Prime 211) (by norm_num) (by norm_num)
    rw [show (101 : ℕ) * 211 = 21311 by norm_num] at h ⊢
    rw [sqrt_val (k := 145) (by norm_num) (by norm_num)] at h
    omega
  · have h := fermatSteps_eq hp (by norm_num : Nat.Prime 409) (by norm_num) (by norm_num)
    rw [show (101 : ℕ) * 409 = 41309 by norm_num] at h ⊢
    rw [sqrt_val (k := 203) (by norm_num) (by norm_num)] at h
    omega
  · have h := fermatSteps_eq hp (by norm_num : Nat.Prime 809) (by norm_num) (by norm_num)
    rw [show (101 : ℕ) * 809 = 81709 by norm_num] at h ⊢
    rw [sqrt_val (k := 285) (by norm_num) (by norm_num)] at h
    omega
  · have h := fermatSteps_eq hp (by norm_num : Nat.Prime 1619) (by norm_num) (by norm_num)
    rw [show (101 : ℕ) * 1619 = 163519 by norm_num] at h ⊢
    rw [sqrt_val (k := 404) (by norm_num) (by norm_num)] at h
    omega
  · have h := fermatSteps_eq hp (by norm_num : Nat.Prime 3251) (by norm_num) (by norm_num)
    rw [show (101 : ℕ) * 3251 = 328351 by norm_num] at h ⊢
    rw [sqrt_val (k := 573) (by norm_num) (by norm_num)] at h
    omega
  · have h := fermatSteps_eq hp (by norm_num : Nat.Prime 6469) (by norm_num) (by norm_num)
    rw [show (101 : ℕ) * 6469 = 653369 by norm_num] at h ⊢
    rw [sqrt_val (k := 808) (by norm_num) (by norm_num)] at h
    omega

end FermatGapLocality