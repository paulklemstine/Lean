/-
# The central binomial sandwich: the calibration defect decays at exactly `r^(-1/2)`

Conjecture **D1** of the previous cycle's `FUTURE_DIRECTIONS.md` asked for the missing
Stirling ingredient behind the seed-ensemble rate estimates: `Probability.SeedQuotaBinomial`
proved the crude half `C(2r,r)^2·(3r+1) ≤ 16^r` of the central binomial estimate
(`SeedQuota.centralBinom_sq_mul_le`), and the conjecture named the matching lower bound
`16^r ≤ C(2r,r)^2·(4r+1)` as the one missing ingredient.  This file proves it, and draws
the three consequences the thread needs.

Main results.

* `SeedStirling.centralBinom_sq_mul_ge` — `16^r ≤ C(2r,r)^2·(4r+1)`, by induction through the
  recursion `(r+1)·C(2r+2,r+1) = 2(2r+1)·C(2r,r)`; the induction closes with the *exact*
  polynomial slack `1` in `(2r+1)^2(4r+5) - 4(r+1)^2(4r+1) = 1`, so the constant `4` cannot be
  lowered by this argument.
* `SeedStirling.four_pow_le_centralBinom_mul_sqrt` / `centralBinom_mul_sqrt_le` — the sandwich
  in square-root form: `4^r/√(4r+1) ≤ C(2r,r) ≤ 4^r/√(3r+1)`.
* **The calibration defect is pinned on both sides.**  `SeedStirling.defect_ge` and
  `defect_le` give `1/(2√(4r+1)) ≤ defect r ≤ 1/(2√(3r+1))`, and
  `SeedStirling.defect_sqrt_bracket` turns this into
  `1/(2√5) ≤ defect r · √r ≤ 1/(2√3)` for `r ≥ 1`.  The previous cycle proved only that the
  even-ensemble calibration defect *tends to zero*; the lower bound shows the `r^(-1/2)` rate
  is exact, so the defect is never `o(r^(-1/2))`: an even ensemble's bias decays, but never
  faster than the square root.
* `SeedStirling.not_summable_defect` — consequently the defects are **not summable**: no
  weighted average over even ensemble sizes has finite total bias.  Parity cannot be repaired
  by aggregating even ensembles.
* `SeedStirling.condorcet_rate_stirling` — the rate bound with the square root put in:
  `1 - rungProb (2r+1)(r+1) p ≤ 2·p(1-p)·(4p(1-p))^r/((2p-1)√(3r+4))`, a strict improvement on
  `SeedCondorcetRate.condorcet_rate` by the factor `√(3r+4)` (up to the `p`-dependent constant).
* **D1's numerical half is refuted, not proved.**  `SeedStirling.no_sharp_route_certifies_47`:
  *no* upper bound that dominates the sharpened rate can certify `1 %` at `47` seeds at the
  measured `p = 2/3`, because the sharpened rate itself already exceeds `1/100` there
  (`SeedSharpRate.net48_sharp_47_insufficient`), while the truth does not
  (`SeedExactCrossing.miss_47_le_one_percent`).  Sharper Stirling constants therefore cannot
  close the `47`-versus-`49` gap; only a genuinely different summation can.
-/

import Mathlib
import Probability.SeedQuotaBinomial
import Probability.SeedCondorcetLadder
import Probability.SeedCondorcetConvergence
import Probability.SeedSharpRate
import Probability.SeedExactCrossing

namespace SeedStirling

open SeedQuota

/-! ## 1.  The lower half of the central binomial sandwich -/

/-- **The missing Stirling ingredient**: `16^r ≤ C(2r,r)^2·(4r+1)`, equivalently
`4^r/√(4r+1) ≤ C(2r,r)`.  Proved by induction through
`(r+1)·C(2r+2,r+1) = 2(2r+1)·C(2r,r)`; the inductive step reduces to
`16(r+1)^2(4r+1) ≤ 4(2r+1)^2(4r+5)`, whose two sides differ by exactly `4`. -/
theorem centralBinom_sq_mul_ge (r : ℕ) : 16 ^ r ≤ (Nat.centralBinom r) ^ 2 * (4 * r + 1) := by
  induction r with
  | zero => simp [Nat.centralBinom]
  | succ r ih =>
      have hrec : (r + 1) * Nat.centralBinom (r + 1) = 2 * (2 * r + 1) * Nat.centralBinom r :=
        Nat.succ_mul_centralBinom_succ r
      have hsq : ((r + 1) * Nat.centralBinom (r + 1)) ^ 2
          = (2 * (2 * r + 1)) ^ 2 * (Nat.centralBinom r) ^ 2 := by
        rw [hrec]; ring
      have hR : (r + 1) ^ 2 * ((Nat.centralBinom (r + 1)) ^ 2 * (4 * (r + 1) + 1))
          = (2 * (2 * r + 1)) ^ 2 * (Nat.centralBinom r) ^ 2 * (4 * r + 5) := by
        calc (r + 1) ^ 2 * ((Nat.centralBinom (r + 1)) ^ 2 * (4 * (r + 1) + 1))
            = ((r + 1) * Nat.centralBinom (r + 1)) ^ 2 * (4 * r + 5) := by ring
          _ = (2 * (2 * r + 1)) ^ 2 * (Nat.centralBinom r) ^ 2 * (4 * r + 5) := by rw [hsq]
      have hkey : (r + 1) ^ 2 * 16 ^ (r + 1)
          ≤ (r + 1) ^ 2 * ((Nat.centralBinom (r + 1)) ^ 2 * (4 * (r + 1) + 1)) := by
        rw [hR]
        calc (r + 1) ^ 2 * 16 ^ (r + 1) = ((r + 1) ^ 2 * 16) * 16 ^ r := by ring
          _ ≤ ((r + 1) ^ 2 * 16) * ((Nat.centralBinom r) ^ 2 * (4 * r + 1)) :=
              Nat.mul_le_mul_left _ ih
          _ = ((r + 1) ^ 2 * 16 * (4 * r + 1)) * (Nat.centralBinom r) ^ 2 := by ring
          _ ≤ ((2 * (2 * r + 1)) ^ 2 * (4 * r + 5)) * (Nat.centralBinom r) ^ 2 :=
              Nat.mul_le_mul_right _ (by nlinarith)
          _ = (2 * (2 * r + 1)) ^ 2 * (Nat.centralBinom r) ^ 2 * (4 * r + 5) := by ring
      exact Nat.le_of_mul_le_mul_left hkey (by positivity)

private theorem four_pow_sq (r : ℕ) : ((4:ℝ) ^ r) ^ 2 = (16:ℝ) ^ r := by
  rw [← pow_mul, show r * 2 = 2 * r from Nat.mul_comm r 2, pow_mul]
  norm_num

/-- **Square-root form, lower half**: `4^r ≤ C(2r,r)·√(4r+1)`. -/
theorem four_pow_le_centralBinom_mul_sqrt (r : ℕ) :
    (4:ℝ) ^ r ≤ (Nat.centralBinom r : ℝ) * Real.sqrt (4 * r + 1) := by
  have harg : (0:ℝ) ≤ 4 * r + 1 := by positivity
  have hs : Real.sqrt (4 * r + 1) ^ 2 = 4 * r + 1 := Real.sq_sqrt harg
  have hnn : (0:ℝ) ≤ (Nat.centralBinom r : ℝ) * Real.sqrt (4 * r + 1) := by positivity
  refine le_of_pow_le_pow_left₀ two_ne_zero hnn ?_
  have hnat : (16:ℕ) ^ r ≤ (Nat.centralBinom r) ^ 2 * (4 * r + 1) := centralBinom_sq_mul_ge r
  have hcast : ((16:ℕ) ^ r : ℝ) ≤ (((Nat.centralBinom r) ^ 2 * (4 * r + 1) : ℕ) : ℝ) := by
    exact_mod_cast hnat
  push_cast at hcast
  calc ((4:ℝ) ^ r) ^ 2 = (16:ℝ) ^ r := four_pow_sq r
    _ ≤ (Nat.centralBinom r : ℝ) ^ 2 * (4 * r + 1) := hcast
    _ = ((Nat.centralBinom r : ℝ) * Real.sqrt (4 * r + 1)) ^ 2 := by rw [mul_pow, hs]

/-- **Square-root form, upper half**: `C(2r,r)·√(3r+1) ≤ 4^r`, the catalog's
`SeedQuota.centralBinom_sq_mul_le` put in the same shape. -/
theorem centralBinom_mul_sqrt_le (r : ℕ) :
    (Nat.centralBinom r : ℝ) * Real.sqrt (3 * r + 1) ≤ (4:ℝ) ^ r := by
  have harg : (0:ℝ) ≤ 3 * r + 1 := by positivity
  have hs : Real.sqrt (3 * r + 1) ^ 2 = 3 * r + 1 := Real.sq_sqrt harg
  have hnn : (0:ℝ) ≤ (4:ℝ) ^ r := by positivity
  refine le_of_pow_le_pow_left₀ two_ne_zero hnn ?_
  have hnat : (Nat.centralBinom r) ^ 2 * (3 * r + 1) ≤ (16:ℕ) ^ r := centralBinom_sq_mul_le r
  have hcast : (((Nat.centralBinom r) ^ 2 * (3 * r + 1) : ℕ) : ℝ) ≤ ((16:ℕ) ^ r : ℝ) := by
    exact_mod_cast hnat
  push_cast at hcast
  calc ((Nat.centralBinom r : ℝ) * Real.sqrt (3 * r + 1)) ^ 2
      = (Nat.centralBinom r : ℝ) ^ 2 * (3 * r + 1) := by rw [mul_pow, hs]
    _ ≤ (16:ℝ) ^ r := hcast
    _ = ((4:ℝ) ^ r) ^ 2 := (four_pow_sq r).symm

/-! ## 2.  The calibration defect, pinned on both sides -/

private theorem two_pow_odd (r : ℕ) : (2:ℝ) ^ (2 * r + 1) = 2 * 4 ^ r := by
  rw [pow_succ, pow_mul]
  norm_num
  ring

private theorem defect_eq (r : ℕ) : defect r = (Nat.centralBinom r : ℝ) / (2 * 4 ^ r) := by
  unfold defect
  rw [two_pow_odd]
  rfl

/-- **Lower bound on the calibration defect.**  An even ensemble of `2r` seeds is off the
coin flip by at least `1/(2√(4r+1))` at each of its two central rungs. -/
theorem defect_ge (r : ℕ) : 1 / (2 * Real.sqrt (4 * r + 1)) ≤ defect r := by
  have harg : (0:ℝ) < 4 * r + 1 := by positivity
  have hsp : 0 < Real.sqrt (4 * r + 1) := Real.sqrt_pos.2 harg
  have h4 : (0:ℝ) < 4 ^ r := by positivity
  rw [defect_eq, div_le_div_iff₀ (by positivity) (by positivity)]
  have hkey := four_pow_le_centralBinom_mul_sqrt r
  nlinarith [hkey, hsp, h4]

/-- **Upper bound on the calibration defect**, the square-root form of the catalog bound. -/
theorem defect_le (r : ℕ) : defect r ≤ 1 / (2 * Real.sqrt (3 * r + 1)) := by
  have harg : (0:ℝ) < 3 * r + 1 := by positivity
  have hsp : 0 < Real.sqrt (3 * r + 1) := Real.sqrt_pos.2 harg
  have h4 : (0:ℝ) < 4 ^ r := by positivity
  rw [defect_eq, div_le_div_iff₀ (by positivity) (by positivity)]
  have hkey := centralBinom_mul_sqrt_le r
  nlinarith [hkey, hsp, h4]

/-- **The `r^(-1/2)` rate is exact.**  For every `r ≥ 1` the defect times `√r` lies in the
fixed window `[1/(2√5), 1/(2√3)]` — the previous cycle's `defect_tendsto_zero` is therefore
sharp in order: the bias of an even ensemble decays like `r^(-1/2)` and never faster.
(The true limit `1/(2√π) ≈ 0.2821` lies inside the window `[0.2236, 0.2887]`.) -/
theorem defect_sqrt_bracket {r : ℕ} (hr : 1 ≤ r) :
    1 / (2 * Real.sqrt 5) ≤ defect r * Real.sqrt r ∧
      defect r * Real.sqrt r ≤ 1 / (2 * Real.sqrt 3) := by
  have hr0 : (1:ℝ) ≤ (r : ℝ) := by exact_mod_cast hr
  have hrpos : (0:ℝ) < (r : ℝ) := by linarith
  have hsr : 0 < Real.sqrt r := Real.sqrt_pos.2 hrpos
  have hsr2 : Real.sqrt r ^ 2 = (r : ℝ) := Real.sq_sqrt hrpos.le
  have h5 : (0:ℝ) < Real.sqrt 5 := Real.sqrt_pos.2 (by norm_num)
  have h5sq : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num)
  have h3 : (0:ℝ) < Real.sqrt 3 := Real.sqrt_pos.2 (by norm_num)
  have h3sq : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have h4r : 0 < Real.sqrt (4 * r + 1) := Real.sqrt_pos.2 (by positivity)
  have h3r : 0 < Real.sqrt (3 * r + 1) := Real.sqrt_pos.2 (by positivity)
  constructor
  · -- `√(4r+1) ≤ √5·√r`, so the lower bound `1/(2√(4r+1))` beats `1/(2√5·√r)`
    have hle : Real.sqrt (4 * r + 1) ≤ Real.sqrt 5 * Real.sqrt r := by
      rw [← Real.sqrt_mul (by norm_num)]
      exact Real.sqrt_le_sqrt (by linarith)
    have hstep : 1 / (2 * (Real.sqrt 5 * Real.sqrt r)) ≤ 1 / (2 * Real.sqrt (4 * r + 1)) := by
      apply one_div_le_one_div_of_le (by positivity)
      linarith
    have hmul := mul_le_mul_of_nonneg_right (hstep.trans (defect_ge r)) hsr.le
    have hval : 1 / (2 * (Real.sqrt 5 * Real.sqrt r)) * Real.sqrt r = 1 / (2 * Real.sqrt 5) := by
      field_simp
    linarith [hmul, hval.symm.le, hval.le]
  · -- `√3·√r ≤ √(3r+1)`, so the upper bound `1/(2√(3r+1))` beats `1/(2√3·√r)`
    have hle : Real.sqrt 3 * Real.sqrt r ≤ Real.sqrt (3 * r + 1) := by
      rw [← Real.sqrt_mul (by norm_num)]
      exact Real.sqrt_le_sqrt (by linarith)
    have hstep : 1 / (2 * Real.sqrt (3 * r + 1)) ≤ 1 / (2 * (Real.sqrt 3 * Real.sqrt r)) := by
      apply one_div_le_one_div_of_le (by positivity)
      linarith
    have hmul := mul_le_mul_of_nonneg_right ((defect_le r).trans hstep) hsr.le
    have hval : 1 / (2 * (Real.sqrt 3 * Real.sqrt r)) * Real.sqrt r = 1 / (2 * Real.sqrt 3) := by
      field_simp
    linarith [hmul, hval.symm.le, hval.le]

/-- A convenient crude form of the lower bound: `defect r ≥ 1/(4(r+1))`. -/
theorem defect_ge_inv (r : ℕ) : 1 / (4 * ((r : ℝ) + 1)) ≤ defect r := by
  have hrpos : (0:ℝ) < (r : ℝ) + 1 := by positivity
  have h4r : 0 < Real.sqrt (4 * r + 1) := Real.sqrt_pos.2 (by positivity)
  have hle : Real.sqrt (4 * r + 1) ≤ 2 * ((r : ℝ) + 1) := by
    have h2 : Real.sqrt (4 * r + 1) ≤ Real.sqrt ((2 * ((r : ℝ) + 1)) ^ 2) := by
      apply Real.sqrt_le_sqrt
      nlinarith [Nat.cast_nonneg (α := ℝ) r]
    rwa [Real.sqrt_sq (by positivity)] at h2
  refine le_trans ?_ (defect_ge r)
  apply one_div_le_one_div_of_le (by positivity)
  linarith

/-- **The defects are not summable.**  Since `defect r ≍ r^(-1/2)`, the total calibration bias
of the even ensembles diverges: averaging over even ensemble sizes cannot repair the parity
obstruction, however many sizes are pooled. -/
theorem not_summable_defect : ¬ Summable defect := by
  intro hs
  have hcomp : Summable (fun r : ℕ => 1 / (4 * ((r : ℝ) + 1))) :=
    Summable.of_nonneg_of_le (fun r => by positivity) (fun r => defect_ge_inv r) hs
  have hmul : Summable (fun r : ℕ => (1 / (4 * ((r : ℝ) + 1))) * 4) := hcomp.mul_right 4
  have hone : Summable (fun r : ℕ => 1 / ((r : ℝ) + 1)) := by
    refine hmul.congr (fun r => ?_)
    field_simp
  have h2 : Summable (fun n : ℕ => 1 / (n : ℝ)) := by
    rw [← summable_nat_add_iff 1]
    refine hone.congr (fun r => ?_)
    push_cast
    ring
  exact Real.not_summable_one_div_natCast h2

/-! ## 3.  The rate bound with the square root put in -/

/-- The odd central coefficient is half of the next even one: `2·C(2r+1,r) = C(2r+2,r+1)`. -/
theorem two_mul_choose_odd (r : ℕ) : 2 * ((2 * r + 1).choose r) = Nat.centralBinom (r + 1) := by
  have hsymm : (2 * r + 1).choose (r + 1) = (2 * r + 1).choose r := by
    have h := Nat.choose_symm (show r ≤ 2 * r + 1 by omega)
    rw [show 2 * r + 1 - r = r + 1 by omega] at h
    exact h
  have hpascal : (2 * r + 2).choose (r + 1) = (2 * r + 1).choose r + (2 * r + 1).choose (r + 1) :=
    Nat.choose_succ_succ (2 * r + 1) r
  have hc : Nat.centralBinom (r + 1) = (2 * r + 2).choose (r + 1) := by
    have hidx : 2 * (r + 1) = 2 * r + 2 := by ring
    unfold Nat.centralBinom
    rw [hidx]
  rw [hc, hpascal, hsymm]
  ring

/-- `C(2r+1,r)·√(3r+4) ≤ 2·4^r`: the square-root estimate for the odd central coefficient. -/
theorem choose_odd_mul_sqrt_le (r : ℕ) :
    ((2 * r + 1).choose r : ℝ) * Real.sqrt (3 * r + 4) ≤ 2 * 4 ^ r := by
  have hbase := centralBinom_mul_sqrt_le (r + 1)
  have hcast : (Nat.centralBinom (r + 1) : ℝ) = 2 * ((2 * r + 1).choose r : ℝ) := by
    have := two_mul_choose_odd r
    exact_mod_cast this.symm
  have harg : (3 : ℝ) * ((r : ℝ) + 1) + 1 = 3 * r + 4 := by ring
  rw [hcast] at hbase
  push_cast at hbase
  rw [harg] at hbase
  have hpow : (4:ℝ) ^ (r + 1) = 4 * 4 ^ r := by rw [pow_succ]; ring
  rw [hpow] at hbase
  linarith

/-- **The Condorcet rate with the Stirling square root.**  A strict `√(3r+4)`-improvement of
`SeedCondorcetRate.condorcet_rate`, obtained by feeding the sandwich into the sharpened
rate `SeedSharpRate.condorcet_rate_sharp`. -/
theorem condorcet_rate_stirling (r : ℕ) {p : ℝ} (h : 1/2 < p) (h1 : p ≤ 1) :
    1 - rungProb (2 * r + 1) (r + 1) p
      ≤ 2 * (p * (1 - p)) * (4 * p * (1 - p)) ^ r / ((2 * p - 1) * Real.sqrt (3 * r + 4)) := by
  have hd : (0:ℝ) < 2 * p - 1 := by linarith
  have hq : (0:ℝ) ≤ 1 - p := by linarith
  have hp0 : (0:ℝ) < p := by linarith
  have hs : 0 < Real.sqrt (3 * r + 4) := Real.sqrt_pos.2 (by positivity)
  have hsharp := SeedSharpRate.condorcet_rate_sharp r h h1
  refine hsharp.trans ?_
  have hpq : (0:ℝ) ≤ (p * (1 - p)) ^ (r + 1) := by positivity
  rw [div_le_div_iff₀ hd (by positivity)]
  have hchoose := choose_odd_mul_sqrt_le r
  have hexp : (4 * p * (1 - p)) ^ r = 4 ^ r * (p * (1 - p)) ^ r := by
    rw [show 4 * p * (1 - p) = 4 * (p * (1 - p)) by ring, mul_pow]
  have hkey : ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1) * Real.sqrt (3 * r + 4)
      ≤ 2 * 4 ^ r * (p * (1 - p)) ^ (r + 1) := by
    have := mul_le_mul_of_nonneg_right hchoose hpq
    nlinarith [this]
  calc ((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1) * ((2 * p - 1) * Real.sqrt (3 * r + 4))
      = (((2 * r + 1).choose r : ℝ) * (p * (1 - p)) ^ (r + 1) * Real.sqrt (3 * r + 4))
          * (2 * p - 1) := by ring
    _ ≤ (2 * 4 ^ r * (p * (1 - p)) ^ (r + 1)) * (2 * p - 1) :=
        mul_le_mul_of_nonneg_right hkey hd.le
    _ = 2 * (p * (1 - p)) * (4 * p * (1 - p)) ^ r * (2 * p - 1) := by
        rw [hexp, pow_succ]; ring

/-! ## 4.  D1's numerical half: refuted -/

/-- **No Stirling constant can certify `47` seeds.**  D1 conjectured that a fully explicit
version of the sharpened rate would certify `1 %` at exactly the true crossing `47`
(`SeedExactCrossing.certified_iff_at_least_47`).  It cannot: the sharpened rate *itself*
already exceeds `1/100` at `r = 23`, so every bound that dominates it does too.  The
`47`-versus-`49` gap is a defect of the geometric summation, not of the binomial estimate. -/
theorem no_sharp_route_certifies_47 (B : ℕ → ℝ)
    (hB : ∀ r : ℕ, ((2 * r + 1).choose r : ℝ) * ((2/3 : ℝ) * (1 - 2/3)) ^ (r + 1)
        / (2 * (2/3 : ℝ) - 1) ≤ B r) :
    ¬ (B 23 ≤ 1/100) := by
  intro hcon
  have h := SeedSharpRate.net48_sharp_47_insufficient
  have := hB 23
  linarith

/-- …while the truth at `47` seeds *is* below `1 %`: the two facts together locate the loss
exactly in the summation step. -/
theorem truth_at_47_below_one_percent : 1 - rungProb 47 24 (2/3 : ℝ) ≤ 1/100 :=
  SeedExactCrossing.miss_47_le_one_percent

end SeedStirling