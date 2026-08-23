/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Catalog.Physics.InfoFreeWerewolf.FiniteParity

/-!
# The parity-corrected asymptotic expansion (capstone)

This file packages the results of `Asymptotics.lean` and `FiniteParity.lean` into the
single statement that the Phase A mission conjectured:

> For every fixed wolf count `k`, the information-free village win probabilities have two
> distinct asymptotic expansions according to the parity of the initial population, with a
> common leading limit but different first-order corrections.

Writing `n` for the initial population and `k` for the number of wolves (so the village
starts with `v = n - k` villagers), the two expansions proved here are

* `n` even:  `villageWin (n - k) k = 1 - k·√(2/π)·n^{-1/2} + o(n^{-1/2})`,
* `n` odd :  `villageWin (n - k) k = 1 - k·√(π/2)·n^{-1/2} + o(n^{-1/2})`,

with the **same** leading term `1` and first-order coefficients whose ratio is exactly
`π/2`, independently of `k`.

## Main results

* `parityCoeff` : the parity-dependent first-order coefficient `k·√(2/π)` / `k·√(π/2)`.
* `villageWin_expansion_even` / `villageWin_expansion_odd` : the two expansions, stated as
  convergence of the rescaled defect `√n · (1 - villageWin (n-k) k)`.
* `parityCoeff_ne` : for `k ≥ 1` the two first-order coefficients are different, so the two
  expansions are genuinely distinct.
* `parityCoeff_ratio` : their ratio is `π/2`, uniformly in `k`.
* `village_parity_dichotomy` : the full conjecture in one statement — common leading limit,
  distinct first-order coefficients with ratio `π/2`, and (consequently) no single
  parity-blind `n^{-1/2}` expansion.
* `village_parity_dichotomy_finite` : the non-asymptotic shadow of the dichotomy at
  **every** finite population, for one wolf.
-/

namespace InfoFreeWerewolf

open Filter Topology Real

/-- The first-order coefficient in the `n^{-1/2}` expansion of the village win probability,
as a function of the wolf count `k` and the parity of the population
(`true` = even population, `false` = odd population). -/
noncomputable def parityCoeff (k : ℕ) (even : Bool) : ℝ :=
  if even then (k : ℝ) * Real.sqrt (2 / π) else (k : ℝ) * Real.sqrt (π / 2)

theorem parityCoeff_even (k : ℕ) : parityCoeff k true = (k : ℝ) * Real.sqrt (2 / π) := rfl

theorem parityCoeff_odd (k : ℕ) : parityCoeff k false = (k : ℝ) * Real.sqrt (π / 2) := rfl

/-! ### The two expansions -/

/-- **Even-population expansion.**  Along even populations `n = 2m`, the rescaled defect
`√n · (1 - villageWin)` converges to `k·√(2/π)`; equivalently
`villageWin = 1 - k√(2/π)·n^{-1/2} + o(n^{-1/2})`. -/
theorem villageWin_expansion_even (k : ℕ) :
    Tendsto (fun m : ℕ =>
        Real.sqrt (2 * (m : ℝ)) * (1 - ((villageWin (2 * m - k) k : ℚ) : ℝ))) atTop
      (𝓝 (parityCoeff k true)) := by
  have h := tendsto_scaled_failProb_even_pop k
  refine h.congr fun m => ?_
  rw [villageWin]
  push_cast
  ring

/-- **Odd-population expansion.**  Along odd populations `n = 2m+1`, the rescaled defect
converges instead to `k·√(π/2)`. -/
theorem villageWin_expansion_odd (k : ℕ) :
    Tendsto (fun m : ℕ =>
        Real.sqrt (2 * (m : ℝ) + 1) * (1 - ((villageWin (2 * m + 1 - k) k : ℚ) : ℝ))) atTop
      (𝓝 (parityCoeff k false)) := by
  have h := tendsto_scaled_failProb_odd_pop k
  refine h.congr fun m => ?_
  rw [villageWin]
  push_cast
  ring

/-! ### The coefficients are genuinely different -/

/-- For at least one wolf, the even- and odd-population first-order coefficients differ. -/
theorem parityCoeff_ne (k : ℕ) (hk : 1 ≤ k) : parityCoeff k true ≠ parityCoeff k false :=
  ne_of_lt (parity_gap k hk)

/-- The ratio of the two coefficients is exactly `π/2`, for every positive wolf count:
the parity correction is a *universal* multiplicative constant, independent of `k`. -/
theorem parityCoeff_ratio (k : ℕ) (hk : 1 ≤ k) :
    parityCoeff k false / parityCoeff k true = π / 2 := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  rw [parityCoeff_even, parityCoeff_odd, mul_div_mul_left _ _ (ne_of_gt hkR)]
  exact parity_constant_ratio

/-! ### The conjecture, in one statement -/

/-- **Parity-corrected asymptotics for the information-free game.**

For every wolf count `k ≥ 1`:

1. both parity subsequences of the village win probability converge to the *same* leading
   value `1`;
2. the rescaled first-order defects converge to `parityCoeff k true` and
   `parityCoeff k false` respectively;
3. these two coefficients are *different*, with ratio exactly `π/2` regardless of `k`;
4. consequently no single (parity-blind) `n^{-1/2}` scaling limit exists.

Item (4) is what rules out the previously proposed single quadratic scaling. -/
theorem village_parity_dichotomy (k : ℕ) (hk : 1 ≤ k) :
    (Tendsto (fun m : ℕ => ((villageWin (2 * m - k) k : ℚ) : ℝ)) atTop (𝓝 1) ∧
      Tendsto (fun m : ℕ => ((villageWin (2 * m + 1 - k) k : ℚ) : ℝ)) atTop (𝓝 1)) ∧
    (Tendsto (fun m : ℕ =>
        Real.sqrt (2 * (m : ℝ)) * (1 - ((villageWin (2 * m - k) k : ℚ) : ℝ))) atTop
        (𝓝 (parityCoeff k true)) ∧
      Tendsto (fun m : ℕ =>
        Real.sqrt (2 * (m : ℝ) + 1) * (1 - ((villageWin (2 * m + 1 - k) k : ℚ) : ℝ))) atTop
        (𝓝 (parityCoeff k false))) ∧
    parityCoeff k true ≠ parityCoeff k false ∧
    parityCoeff k false / parityCoeff k true = π / 2 ∧
    ¬ ∃ L : ℝ, Tendsto (fun n : ℕ => Real.sqrt (n : ℝ) * ((failProb (n - k) k : ℚ) : ℝ))
        atTop (𝓝 L) :=
  ⟨⟨tendsto_villageWin_even_pop k, tendsto_villageWin_odd_pop k⟩,
    ⟨villageWin_expansion_even k, villageWin_expansion_odd k⟩,
    parityCoeff_ne k hk, parityCoeff_ratio k hk, not_tendsto_scaled_failProb k hk⟩

/-- **The finite-population shadow of the dichotomy** (one wolf).  The parity trace is not
merely asymptotic: for *every* population the quantity `n · (wolf-win probability)²` lies
strictly below `1` when `n` is even and at or above `1` when `n` is odd.  The separator `1`
is exactly the geometric mean of the two limiting values `2/π` and `π/2`. -/
theorem village_parity_dichotomy_finite (m : ℕ) :
    2 * (m : ℚ) * (1 - villageWin (2 * m - 1) 1) ^ 2 < 1 ∧
      1 ≤ (2 * (m : ℚ) + 1) * (1 - villageWin (2 * m) 1) ^ 2 := by
  constructor
  · have h := failProb_sq_parity_even m
    rw [villageWin]; ring_nf; ring_nf at h; exact h
  · have h := failProb_sq_parity_odd m
    rw [villageWin]; ring_nf; ring_nf at h; exact h

/-- The separator of `village_parity_dichotomy_finite` really is the geometric mean of the
two asymptotic constants: `(2/π)·(π/2) = 1`. -/
theorem parity_constants_geometric_mean : (2 / π) * (π / 2) = 1 := by
  have := Real.pi_ne_zero
  field_simp

end InfoFreeWerewolf