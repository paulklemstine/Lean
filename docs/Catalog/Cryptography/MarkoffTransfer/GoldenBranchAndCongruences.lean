import Cryptography.MarkoffTransfer.SilverBranchTransfer

/-!
# Cycle 4: The Golden Branch, and Congruence Invariants of the Whole Surface

Cycle 3 classified the Markoff fibre over the smallest entry `x = 2` and identified it with
the Berggren silver spine.  This file completes the picture for the two lowest fibres and
extracts the congruence invariants that the tree method yields for *all* positive integer
points of the Markoff surface.

## Main results

* `markoff_min_one_classification` — **exactness of the golden branch**: every ordered
  Markoff triple with smallest entry `1` is a pair of consecutive odd-index Fibonacci
  numbers `(1, s n, s (n+1))`.
* `markoff_isCoprime_of_pos` — every positive integer point of the Markoff surface is
  pairwise coprime (the tree theorem `markoff_reach` upgrades the tree invariant
  `MReach.isCoprime` to the whole surface).
* `markoff_not_dvd_three` — no coordinate of a positive Markoff triple is divisible by `3`.
* `markoff_at_most_one_even` — at most one coordinate is even.
* `markoff_fibre_max_determines` — inside a fixed fibre, the largest entry determines the
  triple; the open uniqueness conjecture is exactly the statement that the fibre itself is
  determined.
-/

namespace MarkoffTransfer

/-! ## Exactness of the golden branch -/

/-- **Exactness of the golden branch.**  Every ordered Markoff triple whose smallest entry
is `1` consists of two consecutive terms of the golden spine `1, 1, 2, 5, 13, 34, …`. -/
theorem markoff_min_one_classification :
    ∀ N : ℕ, ∀ y z : ℤ, z ≤ (N : ℤ) → 1 ≤ y → y ≤ z → IsMarkoff 1 y z →
      ∃ n : ℕ, y = markoffSpine n ∧ z = markoffSpine (n + 1) := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro y z hzN hy hyz hM
    rcases eq_or_lt_of_le hyz with hyeq | hylt
    · -- `y = z` forces the root `(1,1,1)`
      subst hyeq
      obtain ⟨_, h2⟩ := markoff_eq_one_of_top_eq_mid hM one_pos hy
      exact ⟨0, by simp [h2], by simp [h2]⟩
    · have hz : 0 < z := by omega
      set w := vieta 1 y z with hw
      have hwy : w ≤ y := markoff_descent_le hM one_pos hy hylt
      have hwpos : 0 < w := markoff_vieta_pos hM one_pos hz
      have hMw : IsMarkoff 1 y w := markoff_vieta hM
      have hzeq : z = 3 * y - w := by rw [hw]; unfold vieta; ring
      have hNpos : 1 ≤ N := by
        have h1 : (1 : ℤ) ≤ (N : ℤ) := by omega
        exact_mod_cast h1
      obtain ⟨n, hn1, hn2⟩ :=
        ih (N - 1) (by omega) w y (by omega) hwpos hwy (hMw.swap₂₃)
      refine ⟨n + 1, hn2, ?_⟩
      rw [hzeq, hn1, hn2, markoffSpine_rec n]

/-- The golden branch, in existential form: a positive integer `z` is the top of an ordered
Markoff triple with smallest entry `1` exactly when it is a golden-spine term. -/
theorem markoff_min_one_iff {z : ℤ} (hz : 1 ≤ z) :
    (∃ y : ℤ, 1 ≤ y ∧ y ≤ z ∧ IsMarkoff 1 y z) ↔ ∃ n : ℕ, z = markoffSpine (n + 1) := by
  constructor
  · rintro ⟨y, hy, hyz, hM⟩
    obtain ⟨n, _, hn2⟩ := markoff_min_one_classification z.toNat y z (by omega) hy hyz hM
    exact ⟨n, hn2⟩
  · rintro ⟨n, rfl⟩
    exact ⟨markoffSpine n, markoffSpine_pos n, (markoffSpine_pos_and_mono n).2,
      markoffSpine_isMarkoff n⟩

/-! ## Congruence invariants of the whole surface -/

/-- Pairwise coprimality holds for **every** positive point of the Markoff surface, not just
for the tree nodes: the tree theorem transports the invariant everywhere. -/
theorem markoff_isCoprime_of_pos {x y z : ℤ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hM : IsMarkoff x y z) : IsCoprime x y ∧ IsCoprime y z ∧ IsCoprime x z :=
  (markoff_reach hx hy hz hM).isCoprime

/-- A common divisor of two coordinates of a positive Markoff triple is a unit. -/
theorem markoff_no_common_factor {x y z d : ℤ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hM : IsMarkoff x y z) (hdx : d ∣ x) (hdy : d ∣ y) : d = 1 ∨ d = -1 := by
  have hco := (markoff_isCoprime_of_pos hx hy hz hM).1
  have : IsUnit d := hco.isUnit_of_dvd' hdx hdy
  exact Int.isUnit_iff.mp this

/-- **No coordinate of a positive Markoff triple is divisible by `3`.** -/
theorem markoff_not_dvd_three {x y z : ℤ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hM : IsMarkoff x y z) : ¬ (3 : ℤ) ∣ x := by
  intro hdx
  rw [isMarkoff_iff] at hM
  -- `3 ∣ x` forces `3 ∣ y² + z²`, hence `3 ∣ y` and `3 ∣ z`
  obtain ⟨k, hk⟩ := hdx
  have hyz3 : (3 : ℤ) ∣ y ^ 2 + z ^ 2 := by
    refine ⟨3 * k * y * z - 3 * k ^ 2, ?_⟩
    subst hk
    linear_combination hM
  have hmod : ((y : ZMod 3)) ^ 2 + ((z : ZMod 3)) ^ 2 = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (y ^ 2 + z ^ 2) 3).mpr hyz3
    push_cast at this
    exact this
  have hy3 : ((y : ZMod 3)) = 0 ∧ ((z : ZMod 3)) = 0 := by
    revert hmod
    generalize ((y : ZMod 3)) = a
    generalize ((z : ZMod 3)) = b
    revert a b
    decide
  have hdy : (3 : ℤ) ∣ y := (ZMod.intCast_zmod_eq_zero_iff_dvd y 3).mp hy3.1
  have hdz : (3 : ℤ) ∣ z := (ZMod.intCast_zmod_eq_zero_iff_dvd z 3).mp hy3.2
  have hco := (markoff_isCoprime_of_pos hx hy hz (isMarkoff_iff.mpr hM)).2.1
  have : IsUnit (3 : ℤ) := hco.isUnit_of_dvd' hdy hdz
  rw [Int.isUnit_iff] at this
  omega

/-- **At most one coordinate of a positive Markoff triple is even.** -/
theorem markoff_at_most_one_even {x y z : ℤ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hM : IsMarkoff x y z) : ¬ ((2 : ℤ) ∣ x ∧ (2 : ℤ) ∣ y) := by
  rintro ⟨hdx, hdy⟩
  rcases markoff_no_common_factor hx hy hz hM hdx hdy with h | h <;> omega

/-! ## Where the uniqueness conjecture really lives -/

/-- Inside a fixed fibre (fixed smallest entry) the largest entry determines the triple.
Together with `markoff_uniqueness_iff_min_determined`, the open Markoff uniqueness
conjecture is precisely the statement that the maximum determines the *fibre*. -/
theorem markoff_fibre_max_determines {x y y' z : ℤ} (hx : 0 < x) (hy : 0 < y)
    (hyz : y ≤ z) (hyz' : y' ≤ z) (hM : IsMarkoff x y z) (hM' : IsMarkoff x y' z) : y = y' :=
  markoff_middle_unique hM hM' hx hyz hyz' hy

end MarkoffTransfer