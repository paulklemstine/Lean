import Cryptography.FHE.BootstrapScheduling

/-!
# Concrete parameters, and the bridge to the catalog's depth predicate

This file connects the quantitative machinery of `NoiseGauge`, `NoiseGrowth`,
`NoiseDichotomy` and `BootstrapScheduling` back to the qualitative depth
bookkeeping already present in `Cryptography.FHE.RingLWE`, and instantiates it
on concrete numbers.

* `iterNoise_one_eq_noiseAfterDepth` — the catalog's `noiseAfterDepth B d = B^(2^d)`
  is exactly the relinearization-free noise iteration at expansion factor `1`.
* `supportsDepth_iff_iterNoise_lt` — the catalog's `SupportsDepth` predicate is
  exactly the statement that the iterated noise is below the threshold.
* `stable_parameters` / `unstable_parameters` — the two sides of the dichotomy
  on concrete numbers (`D = 1/5` versus `D = 3/10` at `γ = 1`).
* `three_levels_between_bootstraps` — for `B = 2`, `T = 65535` exactly three
  multiplication levels fit between bootstraps, and
* `depth_ten_needs_four_bootstraps` — consequently any correct schedule
  reaching multiplicative depth `10` performs at least four bootstraps, which
  the uniform schedule attains.
-/

namespace FHENoise

noncomputable section

/-! ## 1. Bridge to the catalog depth predicate -/

/-- The catalog's conservative depth-`d` noise `B^(2^d)` is the `d`-fold squaring
iteration with expansion factor `1`. -/
theorem iterNoise_one_eq_noiseAfterDepth (B d : ℕ) :
    iterNoise 1 d (B : ℝ) = (RingLWEFHE.noiseAfterDepth B d : ℝ) := by
  have h := gamma_iterNoise 1 (B : ℝ) d
  simp only [one_mul] at h
  rw [h, RingLWEFHE.noiseAfterDepth]
  push_cast
  ring

/-- The catalog's `SupportsDepth` is precisely "the iterated noise is below the
decoding threshold". -/
theorem supportsDepth_iff_iterNoise_lt (B T d : ℕ) :
    RingLWEFHE.SupportsDepth B T d ↔ iterNoise 1 d (B : ℝ) < (T : ℝ) := by
  rw [iterNoise_one_eq_noiseAfterDepth, RingLWEFHE.SupportsDepth]
  exact_mod_cast Iff.rfl

/-! ## 2. The dichotomy on concrete numbers -/

/-- With normalized expansion factor `γ = 1` and relinearization surcharge
`D = 1/5` we are inside the stable regime `4γD ≤ 1`: an invariant noise budget
exists and the scheme needs no bootstrapping at any depth. -/
theorem stable_parameters : ∃ Q, InvariantBudget 1 (1 / 5 : ℝ) Q := by
  rw [noiseStep_dichotomy one_pos (by norm_num)]
  norm_num

/-- Pushing the surcharge to `D = 3/10` crosses the threshold `4γD > 1`: no
invariant budget exists and, whatever the decoding radius `T`, the noise of a
purely levelled evaluation exceeds it at some finite depth. -/
theorem unstable_parameters :
    (¬ ∃ Q, InvariantBudget 1 (3 / 10 : ℝ) Q) ∧
      ∀ T x : ℝ, ∃ d : ℕ, T < iterD 1 (3 / 10 : ℝ) d x := by
  constructor
  · rw [noiseStep_dichotomy one_pos (by norm_num)]
    norm_num
  · intro T x
    exact exists_depth_exceeding (gamma := 1) (D := (3 / 10 : ℝ)) (x := x)
      one_pos (by norm_num) T

/-! ## 3. A concrete bootstrapping schedule -/

private lemma iterD_two_three : iterD 1 0 3 (2 : ℝ) = 256 := by
  norm_num [iterD, noiseStep]

private lemma iterD_two_four : iterD 1 0 4 (2 : ℝ) = 65536 := by
  norm_num [iterD, noiseStep]

/-- **Exactly three levels fit between bootstraps** for a fresh noise level `2`
and decoding radius `65535`: depth three is safe, depth four is not. -/
theorem three_levels_between_bootstraps :
    iterD 1 0 3 (2 : ℝ) ≤ 65535 ∧ (65535 : ℝ) < iterD 1 0 4 (2 : ℝ) := by
  rw [iterD_two_three, iterD_two_four]
  norm_num

/-- **A concrete scheduling lower bound.**  With those parameters, every safe
bootstrapping schedule that reaches multiplicative depth `10` performs at least
four bootstraps — and the uniform schedule `[3,3,3,3]` achieves depth `12 ≥ 10`
with exactly four. -/
theorem depth_ten_needs_four_bootstraps
    (sch : List ℕ) (hsafe : Schedule.Safe 1 0 2 65535 sch)
    (hd : 10 ≤ Schedule.depth sch) :
    4 ≤ Schedule.bootstraps sch := by
  have hL : (65535 : ℝ) < iterD 1 0 (3 + 1) 2 := by
    rw [show (3 + 1) = 4 from rfl, iterD_two_four]; norm_num
  have hbound := Schedule.depth_le_smul (gamma := 1) (D := 0) (Bmin := 2) (T := 65535)
    (le_refl 1) (le_refl 0) (by norm_num) hL hsafe
  simp only [Schedule.bootstraps] at *
  omega

/-- The uniform schedule matching the previous lower bound. -/
theorem uniform_schedule_attains :
    Schedule.Safe 1 0 2 65535 [3, 3, 3, 3] ∧
      Schedule.depth [3, 3, 3, 3] = 12 ∧ Schedule.bootstraps [3, 3, 3, 3] = 4 := by
  refine ⟨?_, by simp [Schedule.depth], by simp [Schedule.bootstraps]⟩
  intro n hn
  have : n = 3 := by fin_cases hn <;> rfl
  subst this
  rw [iterD_two_three]
  norm_num

end

end FHENoise