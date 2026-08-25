import Mathlib
import Shared.MoonshineJExpansion

/-!
# Widening the verified window of the `j`-expansion

Third research cycle.  `Shared.MoonshineJExpansion` verified the head of the
`q`-expansion of `j = E₄³/Δ` to eight terms.  This file widens the kernel-checked
window to twelve terms and abstracts the uniqueness argument, so that the window
can be widened again by changing two numerals.

* `MoonshineJWindow.agree_of_deltaPart_mul` — **uniqueness at an arbitrary
  window**: two power series whose products with (possibly differently
  truncated) eta products both reproduce `E₄³` modulo `q^N` agree modulo `q^N`.
  This replaces the ad-hoc `N = 8` argument by a statement that scales.
* `MoonshineJWindow.E4_cube_agree_delta_mul_j12` — the verified identity
  `E₄³ ≡ (∏_{k≤11}(1-q^k)^24) · J₁₂ (mod q¹²)`.
* `MoonshineJWindow.j_coefficients_window` — consequently *every* solution of
  `Δ/q · f = E₄³` has the twelve tabulated coefficients, extending the moonshine
  head data to `c(10) = 22567393309593600`.
* `MoonshineJWindow.tau_values_twelve` — the first twelve Ramanujan tau values,
  and `tau_hecke_nine`, `tau_hecke_ten`, `tau_hecke_twelve` the Hecke relations
  `τ(9) = τ(3)² - 3¹¹`, `τ(10) = τ(2)τ(5)`, `τ(12) = τ(3)τ(4)` on them.
* `MoonshineJWindow.mckay_level_6` — the McKay decomposition of `c(6)`.
-/

namespace MoonshineJWindow

open Finset PowerSeries MoonshineJ

/-! ## 1. Uniqueness at an arbitrary window -/

/-- **Window uniqueness.**  If `deltaPart m · f` and `deltaPart m' · g` both agree
with `E₄³` below degree `N` (and both truncations are long enough), then `f` and
`g` agree below degree `N`.  The eta product being a unit is what makes the
cancellation legitimate. -/
theorem agree_of_deltaPart_mul {N m m' : ℕ} (hm : N ≤ m + 1) (hm' : N ≤ m' + 1)
    (f g : PowerSeries ℤ)
    (hf : AgreeBelow N (E4 ^ 3) (deltaPart m * f))
    (hg : AgreeBelow N (E4 ^ 3) (deltaPart m' * g)) : AgreeBelow N f g := by
  have hswap : AgreeBelow N (deltaPart m' * g) (deltaPart m * g) :=
    (deltaPart_stable hm' hm).mul (AgreeBelow.refl N g)
  exact AgreeBelow.cancel_left (isUnit_deltaPart m) (hf.symm.trans (hg.trans hswap))

/-! ## 2. The twelve-term window -/

/-- The tabulated head of `q · j` to twelve terms. -/
def jT12 : List ℤ :=
  [1, 744, 196884, 21493760, 864299970, 20245856256, 333202640600, 4252023300096,
   44656994071935, 401490886656000, 3176440229784420, 22567393309593600]

/-- The tabulated Ramanujan tau values `τ(1), …, τ(12)`. -/
def tauT12 : List ℤ :=
  [1, -24, 252, -1472, 4830, -6048, -16744, 84480, -113643, -115920, 534612, -370944]

set_option maxRecDepth 400000 in
/-- The kernel-checked truncated identity `E₄³ = (∏(1-q^k)^24) · J` to twelve
terms. -/
theorem list_identity_12 :
    mulT 12 (mulT 12 (e4T 12) (e4T 12)) (e4T 12) = mulT 12 (etaProd 12 11) jT12 := by decide

set_option maxRecDepth 400000 in
/-- The kernel-checked eta product to twelve terms: the first twelve tau values. -/
theorem list_tau_12 : etaProd 12 11 = tauT12 := by decide

/-- The power series attached to the twelve-term table. -/
noncomputable def jSeries12 : PowerSeries ℤ := ser jT12

/-- **The `q`-expansion of `j`, twelve terms.** -/
theorem E4_cube_agree_delta_mul_j12 :
    AgreeBelow 12 (E4 ^ 3) (deltaPart 11 * jSeries12) := by
  have hE : AgreeBelow 12 (ser (mulT 12 (mulT 12 (e4T 12) (e4T 12)) (e4T 12))) (E4 ^ 3) := by
    refine ((agree_mulT 12 _ _).trans (((agree_mulT 12 _ _).trans
      ((agree_e4T 12).mul (agree_e4T 12))).mul (agree_e4T 12))).trans ?_
    rw [pow_succ, pow_two]
  have hD : AgreeBelow 12 (ser (mulT 12 (etaProd 12 11) jT12)) (deltaPart 11 * jSeries12) :=
    (agree_mulT 12 _ _).trans ((agree_etaProd 12 11).mul (AgreeBelow.refl 12 jSeries12))
  rw [list_identity_12] at hE
  exact hE.symm.trans hD

/-- **Twelve verified coefficients.**  Any power series `f` with
`deltaPart m · f = E₄³` (equivalently, the `q`-expansion of `q·j`) has the
tabulated coefficients through degree `11`. -/
theorem j_coefficients_window (f : PowerSeries ℤ) {m : ℕ} (hm : 11 ≤ m)
    (hf : AgreeBelow 12 (E4 ^ 3) (deltaPart m * f)) (n : ℕ) (hn : n < 12) :
    coeff n f = cf jT12 n := by
  have h := agree_of_deltaPart_mul (N := 12) (by omega) (by omega) f jSeries12 hf
    E4_cube_agree_delta_mul_j12
  rw [h n hn, jSeries12, coeff_ser]

/-- The moonshine coefficient `c(10)`, at the edge of the verified window. -/
theorem j_coefficient_ten (f : PowerSeries ℤ) {m : ℕ} (hm : 11 ≤ m)
    (hf : AgreeBelow 12 (E4 ^ 3) (deltaPart m * f)) :
    coeff 11 f = 22567393309593600 := by
  rw [j_coefficients_window f hm hf 11 (by norm_num)]
  decide

/-! ## 3. Tau values and Hecke relations on the wider window -/

/-- **The first twelve Ramanujan tau values.** -/
theorem tau_values_twelve {m : ℕ} (hm : 11 ≤ m) (n : ℕ) (hn : n < 12) :
    coeff n (deltaPart m) = cf tauT12 n := by
  have h1 : AgreeBelow 12 (deltaPart m) (deltaPart 11) := deltaPart_stable (by omega) (by omega)
  have h2 : AgreeBelow 12 (ser (etaProd 12 11)) (deltaPart 11) := agree_etaProd 12 11
  rw [h1 n hn, ← h2 n hn, coeff_ser, list_tau_12]

/-- `τ(9) = τ(3)² - 3¹¹`. -/
theorem tau_hecke_nine {m : ℕ} (hm : 11 ≤ m) :
    coeff 8 (deltaPart m) = coeff 2 (deltaPart m) ^ 2 - 3 ^ 11 := by
  rw [tau_values_twelve hm 2 (by norm_num), tau_values_twelve hm 8 (by norm_num)]
  decide

/-- `τ(10) = τ(2)·τ(5)`. -/
theorem tau_hecke_ten {m : ℕ} (hm : 11 ≤ m) :
    coeff 9 (deltaPart m) = coeff 1 (deltaPart m) * coeff 4 (deltaPart m) := by
  rw [tau_values_twelve hm 1 (by norm_num), tau_values_twelve hm 4 (by norm_num),
    tau_values_twelve hm 9 (by norm_num)]
  decide

/-- `τ(12) = τ(3)·τ(4)`. -/
theorem tau_hecke_twelve {m : ℕ} (hm : 11 ≤ m) :
    coeff 11 (deltaPart m) = coeff 2 (deltaPart m) * coeff 3 (deltaPart m) := by
  rw [tau_values_twelve hm 2 (by norm_num), tau_values_twelve hm 3 (by norm_num),
    tau_values_twelve hm 11 (by norm_num)]
  decide

/-- Ramanujan's congruence `τ(n) ≡ σ₁₁(n) (mod 691)` on the wider window. -/
theorem tau_ramanujan_congruence_twelve {m : ℕ} (hm : 11 ≤ m) (n : ℕ) (hn : n < 12) :
    (691 : ℤ) ∣ (coeff n (deltaPart m) - ((∑ d ∈ (n + 1).divisors, d ^ 11 : ℕ) : ℤ)) := by
  rw [tau_values_twelve hm n hn]
  interval_cases n <;> decide

/-- Lehmer's non-vanishing question on the wider window. -/
theorem tau_ne_zero_below_thirteen {m : ℕ} (hm : 11 ≤ m) (n : ℕ) (hn : n < 12) :
    coeff n (deltaPart m) ≠ 0 := by
  rw [tau_values_twelve hm n hn]
  interval_cases n <;> decide

/-! ## 4. One more McKay level -/

/-- `c(6) = 4252023300096
        = 3·1 + 7·196883 + 6·21296876 + 2·842609326 + 4·19360062527
          + 293553734298 + 3879214937598`. -/
theorem mckay_level_6 :
    cf jT12 7 = 3 * 1 + 7 * 196883 + 6 * 21296876 + 2 * 842609326 + 4 * 19360062527
      + 293553734298 + 3879214937598 := by decide

end MoonshineJWindow