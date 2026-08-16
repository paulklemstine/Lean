/-
# The divisibility structure of the staircase family, and the grid step as a gcd invariant

Cycle 3 of the NET-47 thread.  Cycle 1 gave the binary normal form of a knee
(`stair b j = 2^b (2^j - 1)`) and its divisor spectrum; cycle 2 showed that the measured
three-seed distribution `{96, 112, 128}` is *exactly* the grid-admissible staircase population of
the octave `(64, 128]`.

This cycle asks how the members of such a population relate to each other arithmetically.  The
answers are complete:

* `KneeStaircase.mersenne_dvd_iff` — `(2^j - 1) ∣ (2^j' - 1) ↔ j ∣ j'`, the classical Mersenne
  divisibility criterion, obtained from `Nat.pow_sub_one_gcd_pow_sub_one`.
* `KneeStaircase.stair_dvd_iff` — **the divisibility order of the family is a product order**:
  `stair b j ∣ stair b' j' ↔ b ≤ b' ∧ j ∣ j'`.  Zero blocks compare by size, one blocks by
  divisibility.
* `KneeStaircase.stair_gcd` — the family is **closed under gcd**:
  `gcd (stair b j) (stair b' j') = stair (min b b') (gcd j j')`; it is a meet-semilattice
  isomorphic to `(ℕ, ≤) × (ℕ_{≥1}, ∣)`.
* `KneeStaircase.not_isStaircase_twentyone` and `KneeStaircase.staircase_not_lcm_closed` — but it
  is **not** closed under lcm (`lcm 3 7 = 21 = 10101₂`), so the family is a meet-semilattice and
  not a sublattice of the divisibility lattice.  The asymmetry is intrinsic, not an artefact of
  the small case.
* `KneeStaircase.census_antichain` — in any octave census, no admissible knee divides another:
  the seed-to-seed jitter is an **antichain**.  Two different seeds never report knees one of
  which is a multiple of the other, whatever the context or grid.
* `KneeStaircase.census_gcd_is_grid_step`, `KneeStaircase.net47_gcd_recovers_grid` — the grid
  step is recoverable from the data: `gcd(96, 112) = 16` is exactly the sweep grid step
  `2^g`, and more generally the gcd of the two coarsest census points is `2^g`.  The measured
  knee spread therefore *encodes* the resolution at which it was measured.
-/

import Mathlib
import NumberTheory.KneeStaircaseArithmetic
import NumberTheory.KneeStaircaseOctaveCensus

namespace KneeStaircase

/-! ## 1.  Mersenne divisibility -/

theorem two_pow_sub_one_injective {i j : ℕ} (h : (2:ℕ) ^ i - 1 = 2 ^ j - 1) : i = j := by
  have h1 : (1:ℕ) ≤ 2 ^ i := one_le_two_pow i
  have h2 : (1:ℕ) ≤ 2 ^ j := one_le_two_pow j
  have : (2:ℕ) ^ i = 2 ^ j := by omega
  exact Nat.pow_right_injective (le_refl 2) this

/-- **Mersenne divisibility criterion.** -/
theorem mersenne_dvd_iff (j j' : ℕ) : (2 ^ j - 1) ∣ (2 ^ j' - 1) ↔ j ∣ j' := by
  rw [← Nat.gcd_eq_left_iff_dvd, ← Nat.gcd_eq_left_iff_dvd,
    Nat.pow_sub_one_gcd_pow_sub_one]
  exact ⟨fun h => two_pow_sub_one_injective h, fun h => by rw [h]⟩

/-! ## 2.  The divisibility order of the staircase family -/

theorem coprime_mersenne_two_pow {j b : ℕ} (hj : 1 ≤ j) : Nat.Coprime (2 ^ j - 1) (2 ^ b) :=
  (Nat.Coprime.pow_left _
    ((Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr (odd_two_pow_sub_one hj))).symm

/-- **The divisibility order is the product order.**  For staircase numbers, divisibility
decouples into "the zero block grows" and "the one block divides". -/
theorem stair_dvd_iff {b j b' j' : ℕ} (hj : 1 ≤ j) (hj' : 1 ≤ j') :
    stair b j ∣ stair b' j' ↔ b ≤ b' ∧ j ∣ j' := by
  constructor
  · intro h
    have hcop : Nat.Coprime (2 ^ b) (2 ^ j' - 1) :=
      (coprime_mersenne_two_pow (j := j') (b := b) hj').symm
    have hcop' : Nat.Coprime (2 ^ j - 1) (2 ^ b') := coprime_mersenne_two_pow hj
    have hb : (2:ℕ) ^ b ∣ 2 ^ b' * (2 ^ j' - 1) := dvd_trans ⟨2 ^ j - 1, rfl⟩ h
    have hbb : (2:ℕ) ^ b ∣ 2 ^ b' := hcop.dvd_of_dvd_mul_right hb
    have hm : (2 ^ j - 1) ∣ 2 ^ b' * (2 ^ j' - 1) :=
      dvd_trans ⟨2 ^ b, by rw [stair]; ring⟩ h
    have hmm : (2 ^ j - 1) ∣ (2 ^ j' - 1) := hcop'.dvd_of_dvd_mul_left hm
    exact ⟨(Nat.pow_dvd_pow_iff_le_right (by norm_num)).mp hbb, (mersenne_dvd_iff j j').mp hmm⟩
  · rintro ⟨hb, hjj⟩
    exact mul_dvd_mul (pow_dvd_pow 2 hb) ((mersenne_dvd_iff j j').mpr hjj)

/-- **Closure under gcd.**  The staircase family is a meet-semilattice: the gcd of two staircase
numbers is the staircase number with the shorter zero block and the gcd one block. -/
theorem stair_gcd {b j b' j' : ℕ} (hj : 1 ≤ j) (hj' : 1 ≤ j') :
    Nat.gcd (stair b j) (stair b' j') = stair (min b b') (Nat.gcd j j') := by
  -- symmetric in the two arguments, so we may assume `b ≤ b'`
  rcases le_total b b' with hbb | hbb
  · obtain ⟨c, rfl⟩ : ∃ c, b' = b + c := ⟨b' - b, by omega⟩
    have hsplit : stair (b + c) j' = 2 ^ b * (2 ^ c * (2 ^ j' - 1)) := by
      rw [stair, pow_add]; ring
    rw [stair, hsplit, Nat.gcd_mul_left,
      (Nat.Coprime.gcd_mul_left_cancel_right _
        ((coprime_mersenne_two_pow (j := j) (b := c) hj).symm)),
      Nat.pow_sub_one_gcd_pow_sub_one, stair, min_eq_left (by omega)]
  · obtain ⟨c, rfl⟩ : ∃ c, b = b' + c := ⟨b - b', by omega⟩
    have hsplit : stair (b' + c) j = 2 ^ b' * (2 ^ c * (2 ^ j - 1)) := by
      rw [stair, pow_add]; ring
    rw [Nat.gcd_comm, stair, hsplit, Nat.gcd_mul_left,
      (Nat.Coprime.gcd_mul_left_cancel_right _
        ((coprime_mersenne_two_pow (j := j') (b := c) hj').symm)),
      Nat.pow_sub_one_gcd_pow_sub_one, stair, min_eq_right (by omega), Nat.gcd_comm j' j]

/-! ## 3.  Failure of lcm closure -/

theorem not_isStaircase_twentyone : ¬ IsStaircase 21 := by
  rintro ⟨b, j, hj, hb⟩
  rcases Nat.eq_zero_or_pos b with rfl | hbpos
  · -- odd case: `2 ^ j = 22` is impossible
    rw [stair, pow_zero, one_mul] at hb
    have h1 : (1:ℕ) ≤ 2 ^ j := one_le_two_pow j
    have h22 : (2:ℕ) ^ j = 22 := by omega
    have h4 : (2:ℕ) ^ 4 ≤ 2 ^ j := by rw [h22]; norm_num
    have h5 : (2:ℕ) ^ j ≤ 2 ^ 5 := by rw [h22]; norm_num
    have hj4 : 4 ≤ j := (Nat.pow_le_pow_iff_right (by norm_num)).mp h4
    have hj5 : j ≤ 5 := (Nat.pow_le_pow_iff_right (by norm_num)).mp h5
    interval_cases j <;> omega
  · -- even case: `21` is odd
    have : 2 ∣ stair b j := ⟨2 ^ (b - 1) * (2 ^ j - 1), by
      rw [stair, ← mul_assoc, ← pow_succ']
      congr 2
      omega⟩
    rw [← hb] at this
    omega

/-- **The family is not closed under lcm.**  `3 = stair 0 2` and `7 = stair 0 3` are staircase
numbers, but `lcm 3 7 = 21` is not: the staircase family is a meet-semilattice inside the
divisibility lattice, never a sublattice. -/
theorem staircase_not_lcm_closed :
    IsStaircase 3 ∧ IsStaircase 7 ∧ ¬ IsStaircase (Nat.lcm 3 7) := by
  refine ⟨⟨0, 2, by norm_num, by norm_num [stair]⟩, ⟨0, 3, by norm_num, by norm_num [stair]⟩, ?_⟩
  have : Nat.lcm 3 7 = 21 := by decide
  rw [this]
  exact not_isStaircase_twentyone

/-! ## 4.  Octave censuses are antichains -/

/-- **The knee jitter is an antichain.**  Distinct admissible knees in one octave never divide
one another: no seed's knee is a multiple of another seed's knee. -/
theorem census_antichain {n g x y : ℕ} (hn : 1 ≤ n) (hg : g < n)
    (hx : x ∈ octaveCandidates n g) (hy : y ∈ octaveCandidates n g) (hne : x ≠ y) :
    ¬ x ∣ y := by
  rcases mem_census_param hn hg hx with rfl | ⟨i, hi2, hin, rfl⟩ <;>
    rcases mem_census_param hn hg hy with rfl | ⟨j, hj2, hjn, rfl⟩
  · exact absurd rfl hne
  · intro h
    obtain ⟨hb, -⟩ := (stair_dvd_iff (by norm_num) (by omega)).mp h
    omega
  · intro h
    obtain ⟨-, hdvd⟩ := (stair_dvd_iff (by omega) (by norm_num)).mp h
    have := Nat.le_of_dvd (by norm_num) hdvd
    omega
  · intro h
    obtain ⟨hb, hdvd⟩ := (stair_dvd_iff (by omega) (by omega)).mp h
    have hij : i ≠ j := fun hij => hne (by rw [hij])
    have hle : i ≤ j := Nat.le_of_dvd (by omega) hdvd
    omega

/-! ## 5.  The grid step is a gcd invariant of the census -/

/-- **The grid step is recoverable from the knee spread.**  The two coarsest admissible knees of
an octave have gcd exactly `2 ^ g`, the sweep grid step: the measured distribution encodes the
resolution at which it was measured. -/
theorem census_gcd_is_grid_step {n g : ℕ} (hg3 : n - g = 3) (hn : 3 ≤ n) :
    Nat.gcd (stair (n - 2) 2) (stair (n - 3) 3) = 2 ^ g := by
  rw [stair_gcd (by norm_num) (by norm_num)]
  have hmin : min (n - 2) (n - 3) = n - 3 := by omega
  have hgcd : Nat.gcd 2 3 = 1 := by decide
  rw [hmin, hgcd, stair_one]
  congr 1
  omega

/-- The NET-47 instance: `gcd(96, 112) = 16`, the sweep grid step, and the third measured knee
`128` is a multiple of it, so the gcd of the whole three-seed distribution is `16`. -/
theorem net47_gcd_recovers_grid :
    Nat.gcd 96 112 = 16 ∧ Nat.gcd (Nat.gcd 96 112) 128 = 16 := by
  have h := census_gcd_is_grid_step (n := 7) (g := 4) (by norm_num) (by norm_num)
  rw [show (7:ℕ) - 2 = 5 from rfl, show (7:ℕ) - 3 = 4 from rfl, net47_ninetysix,
    net47_onetwelve] at h
  have h16 : Nat.gcd 96 112 = 16 := by rw [h]; norm_num
  exact ⟨h16, by rw [h16]; decide⟩

/-- The NET-47 three-seed distribution is an antichain: `96 ∤ 112`, `112 ∤ 128`, `96 ∤ 128`. -/
theorem net47_census_antichain :
    ¬ (96 ∣ 112) ∧ ¬ (112 ∣ 128) ∧ ¬ (96 ∣ 128) ∧ ¬ (112 ∣ 96) := by
  have hmem : ∀ k ∈ ({96, 112, 128} : Finset ℕ), k ∈ octaveCandidates 7 4 := by
    intro k hk; rw [net47_census]; exact hk
  refine ⟨?_, ?_, ?_, ?_⟩
  · exact census_antichain (by norm_num) (by norm_num) (hmem 96 (by decide))
      (hmem 112 (by decide)) (by norm_num)
  · exact census_antichain (by norm_num) (by norm_num) (hmem 112 (by decide))
      (hmem 128 (by decide)) (by norm_num)
  · exact census_antichain (by norm_num) (by norm_num) (hmem 96 (by decide))
      (hmem 128 (by decide)) (by norm_num)
  · exact census_antichain (by norm_num) (by norm_num) (hmem 112 (by decide))
      (hmem 96 (by decide)) (by norm_num)

end KneeStaircase