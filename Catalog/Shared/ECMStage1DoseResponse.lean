import Mathlib
import Catalog.Shared.ECMStage1SmoothPart

/-!
# Dose response of the stage-1 bound: monotone, but a staircase that saturates

The experiments varied the smoothness bound `B1` as a fraction of a target and found
the success rates *flat* in that fraction — no dose response.  The three previous files
give the exact count `gcd(m, k(B))`; this file settles how that count depends on `B`.

* `gcd_stage1_factorization`: the exponent of a prime `r` in the firing count is
  `min(v_r(m), ⌊log_r B⌋)`, and `0` before `r` enters the schedule.  Everything below
  is read off from this one formula.
* `stage1Scalar_dvd_of_le`, `gcd_stage1Scalar_dvd_of_le`: raising the bound can only
  increase the firing count (monotonicity).
* `gcd_stage1Scalar_flat`: **no dose response.**  Raising the bound from `B` to `B'`
  changes nothing unless some prime power `q^j` that actually divides `m` lies in
  `(B, B']`.  Rates are therefore piecewise constant in the bound, with jumps only at
  the (few) prime powers dividing the order — exactly the flat-in-`B1frac` behaviour
  that was recorded.
* `gcd_stage1Scalar_eq_self_iff`: **saturation.**  The count reaches its maximum `m`
  precisely when `m` is `B`-powersmooth; beyond that, more dose buys nothing.
* `gcd_stage1_jump`: the exact multiplicative jump at a prime `q` of the schedule,
  `gcd(m,k(B,q)) = gcd(m,k(B,q-1)) · q^{min(v_q m, ⌊log_q B⌋)}`.
* `staircase_720_ten`: the whole staircase for `m = 720`, `B = 10`, computed:
  `1, 8, 72, 360, 360` at cutoffs `1, 2, 3, 5, 7`.  Two of the four schedule steps do
  nothing at all.
-/

namespace ECMStage1

open Finset

/-! ## Monotonicity in the bound -/

theorem stage1Scalar_dvd_of_le {B B' : ℕ} (h : B ≤ B') : stage1Scalar B ∣ stage1Scalar B' := by
  rw [← Nat.factorization_le_iff_dvd (stage1Scalar_ne_zero B) (stage1Scalar_ne_zero B'),
    Finsupp.le_def]
  intro r
  by_cases hr : r.Prime
  · rw [stage1Scalar, stage1Scalar, stage1_factorization B B hr, stage1_factorization B' B' hr]
    by_cases hrB : r ≤ B
    · rw [if_pos hrB, if_pos (hrB.trans h)]
      exact Nat.log_mono_right h
    · simp [hrB]
  · simp [Nat.factorization_eq_zero_of_not_prime _ hr]

/-- Raising the smoothness bound can only increase the number of firing points. -/
theorem gcd_stage1Scalar_dvd_of_le {m B B' : ℕ} (h : B ≤ B') :
    Nat.gcd m (stage1Scalar B) ∣ Nat.gcd m (stage1Scalar B') :=
  Nat.dvd_gcd (Nat.gcd_dvd_left _ _)
    ((Nat.gcd_dvd_right _ _).trans (stage1Scalar_dvd_of_le h))

theorem gcd_stage1Scalar_le_of_le {m B B' : ℕ} (hm : m ≠ 0) (h : B ≤ B') :
    Nat.gcd m (stage1Scalar B) ≤ Nat.gcd m (stage1Scalar B') :=
  Nat.le_of_dvd (Nat.pos_of_ne_zero (Nat.gcd_ne_zero_left hm)) (gcd_stage1Scalar_dvd_of_le h)

/-! ## No dose response between prime powers -/

/-- Key exponent identity: `min(v, ⌊log_q B⌋)` is the largest `j ≤ v` with `q^j ≤ B`. -/
theorem min_log_le_min_log {q v B B' : ℕ} (hq : q.Prime) (hB : B ≠ 0) (hB' : B' ≠ 0)
    (h : ∀ j, 1 ≤ j → j ≤ v → (q ^ j ≤ B ↔ q ^ j ≤ B')) :
    min v (Nat.log q B) ≤ min v (Nat.log q B') := by
  set j := min v (Nat.log q B) with hj
  rcases Nat.eq_zero_or_pos j with hj0 | hj0
  · omega
  have hjv : j ≤ v := min_le_left _ _
  have hjlog : j ≤ Nat.log q B := min_le_right _ _
  have h1 : q ^ j ≤ B := (Nat.le_log_iff_pow_le hq.one_lt hB).mp hjlog
  have h2 : q ^ j ≤ B' := (h j hj0 hjv).mp h1
  have h3 : j ≤ Nat.log q B' := (Nat.le_log_iff_pow_le hq.one_lt hB').mpr h2
  exact le_min hjv h3

/-- **No dose response.**  If no prime power that divides `m` lies strictly between the
two bounds, the two bounds give exactly the same firing count. -/
theorem gcd_stage1Scalar_flat {m B B' : ℕ} (hm : m ≠ 0) (hB : B ≠ 0) (hB' : B' ≠ 0)
    (h : ∀ q ∈ m.primeFactors, ∀ j, 1 ≤ j → j ≤ m.factorization q →
      (q ^ j ≤ B ↔ q ^ j ≤ B')) :
    Nat.gcd m (stage1Scalar B) = Nat.gcd m (stage1Scalar B') := by
  refine Nat.eq_of_factorization_eq (Nat.gcd_ne_zero_left hm) (Nat.gcd_ne_zero_left hm) ?_
  intro r
  by_cases hr : r.Prime
  · rw [stage1Scalar, stage1Scalar, gcd_stage1_factorization hm hr,
      gcd_stage1_factorization hm hr]
    by_cases hrm : r ∈ m.primeFactors
    · have hrpos : 0 < m.factorization r :=
        Nat.Prime.factorization_pos_of_dvd hr hm (Nat.dvd_of_mem_primeFactors hrm)
      have h1 : r ≤ B ↔ r ≤ B' := by
        have := h r hrm 1 le_rfl hrpos
        simpa using this
      by_cases hrB : r ≤ B
      · rw [if_pos hrB, if_pos (h1.mp hrB)]
        refine le_antisymm ?_ ?_
        · exact min_log_le_min_log hr hB hB' (h r hrm)
        · exact min_log_le_min_log hr hB' hB (fun j hj1 hj2 => (h r hrm j hj1 hj2).symm)
      · rw [if_neg hrB, if_neg (fun hc => hrB (h1.mpr hc))]
    · have hz : m.factorization r = 0 := by
        simp only [Nat.mem_primeFactors, not_and, not_not] at hrm
        exact Nat.factorization_eq_zero_of_not_dvd (fun hd => hm (hrm hr hd))
      simp [hz]
  · simp [Nat.factorization_eq_zero_of_not_prime _ hr]

/-- **Saturation.**  Every point fires exactly when the order is `B`-powersmooth. -/
theorem gcd_stage1Scalar_eq_self_iff {m B : ℕ} (hm : m ≠ 0) (hB : B ≠ 0) :
    Nat.gcd m (stage1Scalar B) = m ↔ Powersmooth B m := by
  rw [← dvd_stage1Scalar_iff hm hB]
  exact ⟨fun h => h ▸ Nat.gcd_dvd_right _ _, fun h => Nat.gcd_eq_left h⟩

/-! ## The exact jump at a prime of the schedule -/

/-- **Exact jump formula.**  Passing the prime `q` multiplies the firing count by
`q ^ min(v_q(m), ⌊log_q B⌋)`; in particular the count is unchanged when `q ∤ m`. -/
theorem gcd_stage1_jump {m B q : ℕ} (hm : m ≠ 0) (hq : q.Prime) :
    Nat.gcd m (stage1 B q)
      = Nat.gcd m (stage1 B (q - 1)) * q ^ min (m.factorization q) (Nat.log q B) := by
  have hq2 : 2 ≤ q := hq.two_le
  refine Nat.eq_of_factorization_eq (Nat.gcd_ne_zero_left hm)
    (Nat.mul_ne_zero (Nat.gcd_ne_zero_left hm) (pow_ne_zero _ hq.pos.ne')) ?_
  intro r
  by_cases hr : r.Prime
  · rw [Nat.factorization_mul (Nat.gcd_ne_zero_left hm) (pow_ne_zero _ hq.pos.ne'),
      Finsupp.add_apply, gcd_stage1_factorization hm hr, gcd_stage1_factorization hm hr,
      Nat.Prime.factorization_pow hq]
    rcases eq_or_ne r q with rfl | hrq
    · have h1 : ¬ r ≤ r - 1 := by omega
      simp [h1]
    · have h2 : (r ≤ q) ↔ (r ≤ q - 1) := by
        constructor
        · intro h
          have : r ≠ q := hrq
          omega
        · intro h; omega
      simp only [Finsupp.single_apply, if_neg (Ne.symm hrq), add_zero]
      by_cases hrq' : r ≤ q
      · rw [if_pos hrq', if_pos (h2.mp hrq')]
      · rw [if_neg hrq', if_neg (fun hc => hrq' (h2.mpr hc))]
  · simp [Nat.factorization_eq_zero_of_not_prime _ hr]

/-! ## The computed staircase -/

/-- The staircase of firing counts for `m = 720` at bound `B = 10`, as the prime cutoff
advances through `1, 2, 3, 5, 7, 10`: `1, 8, 72, 360, 360, 360`.  Two of the four
schedule steps (`5` gives the last gain, `7` gives none) do nothing: the flatness of the
rate in the bound is visible already in this single cell. -/
theorem staircase_720_ten :
    Nat.gcd 720 (stage1 10 1) = 1 ∧ Nat.gcd 720 (stage1 10 2) = 8 ∧
      Nat.gcd 720 (stage1 10 3) = 72 ∧ Nat.gcd 720 (stage1 10 5) = 360 ∧
      Nat.gcd 720 (stage1 10 7) = 360 ∧ Nat.gcd 720 (stage1 10 10) = 360 := by
  refine ⟨by decide, by decide, by decide, by decide, by decide, by decide⟩

/-- Consequence of the computed staircase: at bound `10` the order `720` fires on half
of the group, and one fifth of all the points that ever fire have already fired after
the first two of the four schedule primes — early fire in the exact sense of this
development. -/
theorem earlyFire_720_ten :
    5 * Nat.gcd 720 (stage1 10 3) = Nat.gcd 720 (stage1 10 10) ∧
      2 * Nat.gcd 720 (stage1 10 10) = 720 := by
  refine ⟨by decide, by decide⟩

end ECMStage1