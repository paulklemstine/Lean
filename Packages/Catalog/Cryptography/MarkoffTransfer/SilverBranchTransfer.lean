import Cryptography.MarkoffTransfer.SpineObstruction
import Cryptography.MarkoffTransfer.UniquenessAndNonlinearity

/-!
# Cycle 3: A Genuine Berggren → Markoff Transfer — the Silver Branch

Cycles 1–2 showed that the *global* transfer conjectured in the mission statement fails
(ternary vs binary branching, silver vs golden growth, linear vs quadratic moves).  This
file exhibits the transfer that **does** exist, and proves it is exact.

Iterating the hyperbolic Berggren generator `B` from the root pair `(2,1)` produces the
Pythagorean triples with hypotenuses

  `bHyp : 5, 29, 169, 985, 5741, …`   (`bHyp (n+2) = 6 · bHyp (n+1) - bHyp n`).

The Markoff triples whose smallest entry is `2` are

  `(2,5,29), (2,29,169), (2,169,985), …`

driven by exactly the same recursion, because the Vieta move over the fixed coordinate
`x = 2` is `z ↦ 6y - z`.  So the Berggren *silver spine* is literally a Markoff branch.

## Main results

* `markoffFiberMat_det`, `markoffFiberMat_trace` — over a fixed smallest coordinate `x`
  the Vieta dynamics **is** linear: it is the `SL₂(ℤ)` matrix of trace `3x`, hyperbolic for
  `x ≥ 1`.  This is the fibrewise remnant of the Berggren Lorentz linearity.
* `markoffFiber_trace_two_eq_berggrenSpine` — for `x = 2` that matrix has the silver
  characteristic polynomial `X² - 6X + 1` of the catalog generator `M₂`.
* `bHyp_isMarkoff` — **transfer theorem**: consecutive Berggren silver-spine hypotenuses
  form a Markoff triple with smallest entry `2`.
* `markoff_min_two_classification` — **exactness**: *every* ordered Markoff triple with
  smallest entry `2` arises this way.
* `berggren_hyp_iff_markoff_two` — the resulting bijection between the Berggren silver
  spine and the Markoff `x = 2` branch.
-/

namespace MarkoffTransfer

open Polynomial

/-! ## Fibrewise linearity of the Vieta dynamics -/

/-- Over a fixed smallest coordinate `x`, the Vieta move `(y, z) ↦ (z, 3xz - y)` is linear. -/
def markoffFiberMat (x : ℚ) : Matrix (Fin 2) (Fin 2) ℚ := !![0, -1; 1, 3 * x]

theorem markoffFiberMat_det (x : ℚ) : (markoffFiberMat x).det = 1 := by
  simp [markoffFiberMat, Matrix.det_fin_two]

theorem markoffFiberMat_trace (x : ℚ) : Matrix.trace (markoffFiberMat x) = 3 * x := by
  simp [markoffFiberMat, Matrix.trace_fin_two]

/-- The fibre matrix is hyperbolic (`|trace| > 2`) as soon as `x ≥ 1`: every Markoff branch
grows exponentially. -/
theorem markoffFiberMat_hyperbolic {x : ℚ} (hx : 1 ≤ x) :
    2 < Matrix.trace (markoffFiberMat x) := by
  rw [markoffFiberMat_trace]; linarith

theorem markoffFiberMat_charpoly (x : ℚ) :
    (markoffFiberMat x).charpoly = X ^ 2 - C (3 * x) * X + 1 := by
  rw [Matrix.charpoly_fin_two, markoffFiberMat_trace, markoffFiberMat_det]
  simp

/-- **The silver coincidence.**  The Markoff fibre over `x = 2` has the same characteristic
polynomial `X² - 6X + 1` as the Berggren spine — the hyperbolic factor of the catalog's
`M₂.charpoly`. -/
theorem markoffFiber_trace_two_eq_berggrenSpine :
    (markoffFiberMat 2).charpoly = berggrenSpineMat.charpoly := by
  rw [markoffFiberMat_charpoly, berggrenSpineMat_charpoly]
  norm_num [map_ofNat]

/-! ## Growth of the Berggren silver spine -/

theorem bHyp_bounds : ∀ n : ℕ, 5 ≤ bHyp n ∧ bHyp n < bHyp (n + 1) := by
  intro n
  induction n with
  | zero => rw [bHyp_zero]; exact ⟨le_refl 5, by rw [bHyp_one]; norm_num⟩
  | succ n ih =>
      obtain ⟨h1, h2⟩ := ih
      have hrec := bHyp_rec n
      have he : bHyp (n + 1 + 1) = bHyp (n + 2) := rfl
      rw [he]
      exact ⟨by omega, by omega⟩

theorem bHyp_ge_five (n : ℕ) : 5 ≤ bHyp n := (bHyp_bounds n).1

theorem bHyp_lt_succ (n : ℕ) : bHyp n < bHyp (n + 1) := (bHyp_bounds n).2

theorem bHyp_strictMono : StrictMono bHyp := strictMono_nat_of_lt_succ bHyp_lt_succ

/-! ## The transfer theorem -/

/-- **Transfer theorem.**  Consecutive hypotenuses along the Berggren silver spine form a
Markoff triple with smallest entry `2`. -/
theorem bHyp_isMarkoff : ∀ n : ℕ, IsMarkoff 2 (bHyp n) (bHyp (n + 1)) := by
  intro n
  induction n with
  | zero =>
      rw [isMarkoff_iff, bHyp_zero, bHyp_one]; norm_num
  | succ n ih =>
      have h := markoff_vieta (ih.swap₂₃)
      have hv : vieta 2 (bHyp (n + 1)) (bHyp n) = bHyp (n + 2) := by
        rw [bHyp_rec n]; unfold vieta; ring
      rwa [hv] at h

/-! ## Exactness: the `x = 2` fibre is exactly the silver spine -/

/-- The only Markoff triple of the form `(1, 2, y)` with `2 ≤ y` is `(1, 2, 5)`. -/
theorem markoff_one_two {y : ℤ} (h : IsMarkoff 2 y 1) (hy : 2 ≤ y) : y = 5 := by
  rw [isMarkoff_iff] at h
  have hfac : (y - 5) * (y - 1) = 0 := by nlinarith [h]
  rcases mul_eq_zero.mp hfac with h₁ | h₁ <;> omega

/-- **Exactness of the transfer.**  Every ordered Markoff triple whose smallest entry is `2`
is a pair of consecutive Berggren silver-spine hypotenuses. -/
theorem markoff_min_two_classification :
    ∀ N : ℕ, ∀ y z : ℤ, z ≤ (N : ℤ) → 2 ≤ y → y ≤ z → IsMarkoff 2 y z →
      ∃ n : ℕ, y = bHyp n ∧ z = bHyp (n + 1) := by
  intro N
  induction N using Nat.strong_induction_on with
  | _ N ih =>
    intro y z hzN hy hyz hM
    -- the top entry is strict
    have hylt : y < z := by
      rcases lt_or_eq_of_le hyz with h | h
      · exact h
      · subst h
        obtain ⟨h1, _⟩ := markoff_eq_one_of_top_eq_mid hM (by norm_num) hy
        omega
    have hz : 0 < z := by omega
    set w := vieta 2 y z with hw
    have hwy : w ≤ y := markoff_descent_le hM (by norm_num) hy hylt
    have hwpos : 0 < w := markoff_vieta_pos hM (by norm_num) hz
    have hMw : IsMarkoff 2 y w := markoff_vieta hM
    have hzeq : z = 6 * y - w := by rw [hw]; unfold vieta; ring
    rcases eq_or_lt_of_le (show (1 : ℤ) ≤ w by omega) with hw1 | hw1
    · -- `w = 1`: we are at the bottom of the fibre, `(y, z) = (5, 29)`
      have hw1' : w = 1 := hw1.symm
      have hy5 : y = 5 := markoff_one_two (by rwa [hw1'] at hMw) hy
      refine ⟨0, by rw [bHyp_zero, hy5], ?_⟩
      rw [bHyp_one, hzeq, hy5, hw1']
      norm_num
    · -- `w ≥ 2`: descend inside the fibre
      have hw2 : 2 ≤ w := by omega
      have hNpos : 1 ≤ N := by
        have : (1 : ℤ) ≤ (N : ℤ) := by omega
        exact_mod_cast this
      obtain ⟨n, hn1, hn2⟩ :=
        ih (N - 1) (by omega) w y (by omega) hw2 hwy ((hMw.swap₂₃))
      refine ⟨n + 1, hn2, ?_⟩
      rw [hzeq, hn1, hn2, bHyp_rec n]

/-- **The Berggren silver spine and the Markoff `x = 2` branch coincide.** -/
theorem berggren_hyp_iff_markoff_two {z : ℤ} :
    (∃ n : ℕ, z = bHyp (n + 1)) ↔ ∃ y : ℤ, 2 ≤ y ∧ y ≤ z ∧ IsMarkoff 2 y z := by
  constructor
  · rintro ⟨n, rfl⟩
    exact ⟨bHyp n, by linarith [bHyp_ge_five n], le_of_lt (bHyp_lt_succ n), bHyp_isMarkoff n⟩
  · rintro ⟨y, hy, hyz, hM⟩
    obtain ⟨n, _, hn2⟩ := markoff_min_two_classification z.toNat y z (by omega) hy hyz hM
    exact ⟨n, hn2⟩

/-- The transfer map `n ↦ (2, bHyp n, bHyp (n+1))` is injective, so the Berggren silver
spine is in bijection with the Markoff `x = 2` branch. -/
theorem bHyp_transfer_injective :
    Function.Injective (fun n : ℕ => ((2 : ℤ), bHyp n, bHyp (n + 1))) := by
  intro m n h
  have : bHyp m = bHyp n := congrArg (fun t => t.2.1) h
  exact bHyp_strictMono.injective this

end MarkoffTransfer