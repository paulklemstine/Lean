import Mathlib
import Shared.ECMStage1OrderCompletion
import Bridges.ECMSelfDestructionWall

/-!
# The exact location of the ECM wall, and the powersmoothness driver

`Bridges.ECMSelfDestructionWall` proved that the wall exists (`B ≥ hasseUpper p` kills
everything) and that it cannot switch on before a prime of the Hasse window.  The
numerics of experiment 486-full showed that the prime bound is *not* tight: for
`p = 101` the window is `[80, 124]`, its largest prime is `113`, but the wall sits at
`B* = 121 = 11²`.  This file explains that discrepancy by computing the threshold
exactly.

* `maxPrimePow n` — the largest prime power exactly dividing `n`; `powersmooth_iff`
  identifies `B`-powersmoothness with `maxPrimePow n ≤ B`.
* `windowMaxPP p = sup over the window of maxPrimePow` and
  `allDegenerate_iff_windowMaxPP_le`: **the wall is exactly at `B = windowMaxPP p`**,
  an `IsLeast` statement (`isLeast_wall`).  It is a prime *power*, not a prime,
  which is why `11² = 121` beats `113` at `p = 101` (`wall_101_exact_sandwich`).
* `firingCount p B` — the number of Hasse-window orders that stage 1 kills at bound
  `B`.  `firingCount_eq_powersmoothCount` is the positive replacement of the refuted
  H2b: the driver is *powersmoothness across the whole `4√p` window*, i.e. the
  distribution of `maxPrimePow` on the window, and nothing coarser.
  `firingCount_mono`, `firingCount_le_card`, `firingCount_eq_card_iff` describe the
  saturation of this count at the wall.
-/

namespace ECMWall

open Finset ECMStage1

/-! ## The largest prime power exactly dividing `n` -/

/-- The largest prime power exactly dividing `n` (`0` for `n ≤ 1`). -/
def maxPrimePow (n : ℕ) : ℕ := n.primeFactors.sup (fun q => q ^ n.factorization q)

/-- Powersmoothness is exactly a bound on `maxPrimePow`. -/
theorem powersmooth_iff_maxPrimePow_le {n B : ℕ} : Powersmooth B n ↔ maxPrimePow n ≤ B := by
  rw [maxPrimePow, Finset.sup_le_iff]
  rfl

/-- For `n ≥ 2` the largest prime power divisor is at least `2`. -/
theorem two_le_maxPrimePow {n : ℕ} (hn : 2 ≤ n) : 2 ≤ maxPrimePow n := by
  have hn0 : n ≠ 0 := by omega
  obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd (by omega : n ≠ 1)
  have hmem : r ∈ n.primeFactors := Nat.mem_primeFactors.mpr ⟨hr, hrd, hn0⟩
  have hpos : 0 < n.factorization r := hr.factorization_pos_of_dvd hn0 hrd
  have hle : r ^ n.factorization r ≤ maxPrimePow n := Finset.le_sup (f := fun q => q ^ n.factorization q) hmem
  calc 2 ≤ r := hr.two_le
    _ = r ^ 1 := (pow_one r).symm
    _ ≤ r ^ n.factorization r := Nat.pow_le_pow_right hr.pos hpos
    _ ≤ maxPrimePow n := hle

/-! ## The exact threshold -/

/-- The largest prime power appearing anywhere in the Hasse window at `p`. -/
def windowMaxPP (p : ℕ) : ℕ := (hasseWindow p).sup maxPrimePow

/-- **The wall is exactly at `windowMaxPP p`.**  Every order in the window dies at
bound `B` if and only if `B` is at least the largest prime power occurring in the
window.  The threshold is a prime *power*: this is the correction to the naive
"largest prime of the window" guess. -/
theorem allDegenerate_iff_windowMaxPP_le {p B : ℕ} (hB : B ≠ 0) :
    AllDegenerate p B ↔ windowMaxPP p ≤ B := by
  constructor
  · intro h
    rw [windowMaxPP, Finset.sup_le_iff]
    intro n hn
    rcases eq_or_ne n 0 with rfl | hn0
    · simp [maxPrimePow]
    · exact powersmooth_iff_maxPrimePow_le.mp ((dvd_stage1Scalar_iff hn0 hB).mp (h n hn hn0))
  · intro h n hn hn0
    have : maxPrimePow n ≤ B :=
      le_trans (Finset.le_sup (f := maxPrimePow) hn) h
    exact (dvd_stage1Scalar_iff hn0 hB).mpr (powersmooth_iff_maxPrimePow_le.mpr this)

/-- The window is nonempty and contains numbers `≥ 2`, so its prime-power supremum is
at least `2`; in particular the wall never sits at `B = 0`. -/
theorem two_le_windowMaxPP {p : ℕ} (hp : 1 ≤ p) : 2 ≤ windowMaxPP p := by
  have hmem : hasseUpper p ∈ hasseWindow p := by
    simp only [hasseWindow, Finset.mem_Icc, hasseLower, hasseUpper]
    omega
  have h2 : 2 ≤ hasseUpper p := by simp only [hasseUpper]; omega
  exact le_trans (two_le_maxPrimePow h2) (Finset.le_sup (f := maxPrimePow) hmem)

/-- **The wall as a least element.**  `windowMaxPP p` is the smallest positive bound at
which every Hasse-window order degenerates. -/
theorem isLeast_wall {p : ℕ} (hp : 1 ≤ p) :
    IsLeast {B | B ≠ 0 ∧ AllDegenerate p B} (windowMaxPP p) := by
  have h2 := two_le_windowMaxPP hp
  refine ⟨⟨by omega, ?_⟩, ?_⟩
  · exact (allDegenerate_iff_windowMaxPP_le (by omega)).mpr le_rfl
  · rintro B ⟨hB0, hB⟩
    exact (allDegenerate_iff_windowMaxPP_le hB0).mp hB

/-- The wall never exceeds the top of the Hasse window. -/
theorem windowMaxPP_le_hasseUpper (p : ℕ) : windowMaxPP p ≤ hasseUpper p := by
  rw [windowMaxPP, Finset.sup_le_iff]
  intro n hn
  simp only [hasseWindow, Finset.mem_Icc] at hn
  rcases eq_or_ne n 0 with rfl | hn0
  · simp [maxPrimePow]
  · refine le_trans ?_ hn.2
    rw [maxPrimePow, Finset.sup_le_iff]
    intro q hq
    exact Nat.le_of_dvd (Nat.pos_of_ne_zero hn0) (Nat.ordProj_dvd n q)

/-- **Prime powers, not primes, set the wall.**  If a prime power `r^e` lies in the
window and `B < r^e`, nothing degenerates. -/
theorem not_allDegenerate_of_primePow_in_window {p B r e : ℕ} (hr : r.Prime) (he : 1 ≤ e)
    (hmem : r ^ e ∈ hasseWindow p) (hB : B < r ^ e) : ¬ AllDegenerate p B := by
  intro h
  rcases Nat.eq_zero_or_pos B with rfl | hBpos
  · have h2 : stage1Scalar 0 = 1 := by simp [stage1Scalar, stage1, Nat.log_zero_right]
    have hdvd := h (r ^ e) hmem (by positivity)
    rw [h2] at hdvd
    have : r ^ e ≤ 1 := Nat.le_of_dvd one_pos hdvd
    have : 2 ≤ r ^ e := le_trans hr.two_le (Nat.le_self_pow (by omega) r)
    omega
  · have hle := (allDegenerate_iff_windowMaxPP_le hBpos.ne').mp h
    have hmpp : maxPrimePow (r ^ e) ≤ windowMaxPP p :=
      Finset.le_sup (f := maxPrimePow) hmem
    have hfac : (r ^ e : ℕ).factorization r = e := by
      simp [Nat.Prime.factorization_pow hr]
    have hmemr : r ∈ (r ^ e : ℕ).primeFactors := by
      rw [Nat.primeFactors_prime_pow (by omega) hr]
      simp
    have : r ^ e ≤ maxPrimePow (r ^ e) := by
      have hsup := Finset.le_sup (f := fun q => q ^ (r ^ e : ℕ).factorization q) hmemr
      simp only [hfac] at hsup
      exact hsup
    omega

/-- **The wall at `p = 101`, exactly.**  Nothing degenerates for `B < 121`, because
`121 = 11²` lies in the window `[80,124]`; and everything degenerates at `B = 124`.
The naive "largest prime of the window" guess `113` is *wrong* — the true threshold is
set by a prime power. -/
theorem wall_101_exact_sandwich :
    (∀ B < 121, ¬ AllDegenerate 101 B) ∧ AllDegenerate 101 124 := by
  refine ⟨fun B hB => ?_, allDegenerate_of_hasseUpper_le
    (by simp [hasseUpper, show Nat.sqrt 101 = 10 by norm_num])⟩
  refine not_allDegenerate_of_primePow_in_window (r := 11) (e := 2) (by norm_num) (by norm_num)
    ?_ (by norm_num; omega)
  simp [hasseWindow, hasseLower, hasseUpper, show Nat.sqrt 101 = 10 by norm_num]

/-! ## The firing count across the window -/

open Classical in
/-- How many Hasse-window orders stage 1 kills at bound `B`. -/
noncomputable def firingCount (p B : ℕ) : ℕ :=
  ((hasseWindow p).filter (fun n => n ∣ stage1Scalar B)).card

open Classical in
/-- **The positive form of the refuted H2b.**  The number of window orders that fire is
*exactly* the number of window orders whose largest prime power is at most `B`.  The
driver of stage-1 success is the distribution of `maxPrimePow` across the whole `4√p`
window; `lpf` and `ω` are strictly coarser statistics (see
`lpf_omega_blind_to_firing`). -/
theorem firingCount_eq_powersmoothCount {p B : ℕ} (hB : B ≠ 0) (h0 : (0 : ℕ) ∉ hasseWindow p) :
    firingCount p B = ((hasseWindow p).filter (fun n => maxPrimePow n ≤ B)).card := by
  rw [firingCount]
  congr 1
  refine Finset.filter_congr ?_
  intro n hn
  have hn0 : n ≠ 0 := by rintro rfl; exact h0 hn
  rw [dvd_stage1Scalar_iff hn0 hB, powersmooth_iff_maxPrimePow_le]

/-- For `p ≥ 19` the window consists of positive integers. -/
theorem zero_not_mem_hasseWindow {p : ℕ} (hp : 19 ≤ p) : (0 : ℕ) ∉ hasseWindow p := by
  have hkey := four_sqrt_add_two_lt p hp
  simp only [hasseWindow, Finset.mem_Icc, hasseLower, hasseUpper]
  omega

open Classical in
/-- The firing count is monotone in the smoothness bound: raising `B` can only kill more
orders.  (This is the unconditional skeleton of the measured dose-response curve.) -/
theorem firingCount_mono {p B B' : ℕ} (hp : 19 ≤ p) (hB : B ≠ 0) (hBB : B ≤ B') :
    firingCount p B ≤ firingCount p B' := by
  have hB' : B' ≠ 0 := by omega
  refine Finset.card_le_card ?_
  intro n hn
  rw [Finset.mem_filter] at hn ⊢
  obtain ⟨hnw, hdvd⟩ := hn
  have hn0 : n ≠ 0 := by rintro rfl; exact zero_not_mem_hasseWindow hp hnw
  refine ⟨hnw, ?_⟩
  have hsm : Powersmooth B n := (dvd_stage1Scalar_iff hn0 hB).mp hdvd
  exact (dvd_stage1Scalar_iff hn0 hB').mpr fun r hr => le_trans (hsm r hr) hBB

open Classical in
theorem firingCount_le_card (p B : ℕ) : firingCount p B ≤ (hasseWindow p).card :=
  Finset.card_filter_le _ _

open Classical in
/-- **Saturation at the wall.**  The firing count reaches the size of the whole window
exactly when the wall has been crossed — the moment ECM stops being able to split. -/
theorem firingCount_eq_card_iff {p B : ℕ} (hp : 19 ≤ p) :
    firingCount p B = (hasseWindow p).card ↔ AllDegenerate p B := by
  rw [firingCount]
  constructor
  · intro h n hn _
    have hfe : (hasseWindow p).filter (fun n => n ∣ stage1Scalar B) = hasseWindow p :=
      Finset.eq_of_subset_of_card_le (Finset.filter_subset _ _) (le_of_eq h.symm)
    have hmem : n ∈ (hasseWindow p).filter (fun n => n ∣ stage1Scalar B) := by
      rw [hfe]; exact hn
    exact (Finset.mem_filter.mp hmem).2
  · intro h
    have hfe : (hasseWindow p).filter (fun n => n ∣ stage1Scalar B) = hasseWindow p :=
      Finset.filter_eq_self.mpr fun n hn =>
        h n hn (by rintro rfl; exact zero_not_mem_hasseWindow hp hn)
    rw [hfe]

/-- Consequently, saturation of the firing count is *equivalent* to the smoothness bound
having reached the largest prime power of the window. -/
theorem firingCount_saturates_iff {p B : ℕ} (hp : 19 ≤ p) (hB : B ≠ 0) :
    firingCount p B = (hasseWindow p).card ↔ windowMaxPP p ≤ B :=
  (firingCount_eq_card_iff hp).trans (allDegenerate_iff_windowMaxPP_le hB)

end ECMWall