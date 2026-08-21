/-
# The Poisson window, and the comparison of *binomial* versus *Poisson* brackets

Third cycle on top of `Shared.UnimodalArgmaxBracketing` (abstract theory of the two
bracketing degrees) and `Shared.UnimodalArgmaxBinomial` (the binomial instance).

The Poisson weights `poissonWeight lam k = lam ^ k / k!` form a strictly log-concave
window on `[0, n]`, and they are a **threshold window with threshold exactly `lam`**:
the rise criterion is the strikingly simple `k + 1 < lam`.  Consequently the two
bracketing degrees are `⌈lam⌉₊ - 1` and `⌊lam⌋₊`, and the explicit comparison of the
two degrees is: *the gap is `1` iff `lam` is a positive integer* — the classical
"Poisson mode is `⌊lam⌋`, with a tie at `lam - 1` for integral `lam`".

The final result is a genuine **cross-instance comparison**: for the binomial window
with success weight `p = lam / n` (so that the expected number of successes is
`lam`), the two bracketing degrees of the *binomial* window and those of the
*Poisson* window differ by at most one, in a completely explicit way
(`poisson_binomial_bracket_comparison`).  Both statements are instances of the same
abstract lemma `ThresholdWindow.brackets_step`, applied to two thresholds that differ
by less than one (`lam` versus `lam + lam / n`).
-/
import Mathlib
import Shared.UnimodalArgmaxBracketing
import Shared.UnimodalArgmaxBinomial

namespace Shared
namespace UnimodalArgmaxBracketing

/-! ## The Poisson weights -/

/-- The (unnormalised) Poisson weight `lam ^ k / k!`. -/
noncomputable def poissonWeight (lam : ℝ) (k : ℕ) : ℝ := lam ^ k / (Nat.factorial k : ℝ)

variable {lam : ℝ} {n : ℕ}

theorem poissonWeight_pos (hlam : 0 < lam) (k : ℕ) : 0 < poissonWeight lam k := by
  have hf : (0 : ℝ) < (k.factorial : ℝ) := by exact_mod_cast k.factorial_pos
  unfold poissonWeight
  positivity

/-- Strict log-concavity of the Poisson weights, from `(k+1)!² < k! (k+2)!`. -/
theorem poissonWeight_strictLogConcaveOn (hlam : 0 < lam) :
    StrictLogConcaveOn n (poissonWeight lam) := by
  refine ⟨fun k _ => poissonWeight_pos hlam k, fun k _ => ?_⟩
  have hfactNat : ((k + 1).factorial) ^ 2 < k.factorial * (k + 2).factorial := by
    have h1 : (k + 1).factorial = (k + 1) * k.factorial := rfl
    have h2 : (k + 2).factorial = (k + 2) * ((k + 1) * k.factorial) := rfl
    rw [h1, h2]
    have hk : 0 < k.factorial := k.factorial_pos
    nlinarith [hk]
  have hfact : ((k + 1).factorial : ℝ) ^ 2 < (k.factorial : ℝ) * ((k + 2).factorial : ℝ) := by
    exact_mod_cast hfactNat
  have hfk : (0 : ℝ) < (k.factorial : ℝ) := by exact_mod_cast k.factorial_pos
  have hfk1 : (0 : ℝ) < ((k + 1).factorial : ℝ) := by exact_mod_cast (k + 1).factorial_pos
  have hfk2 : (0 : ℝ) < ((k + 2).factorial : ℝ) := by exact_mod_cast (k + 2).factorial_pos
  unfold poissonWeight
  rw [div_mul_div_comm, div_pow, div_lt_div_iff₀ (by positivity) (by positivity)]
  have hpow : lam ^ k * lam ^ (k + 2) = (lam ^ (k + 1)) ^ 2 := by ring
  rw [hpow]
  exact mul_lt_mul_of_pos_left hfact (by positivity)

/-- **The Poisson rise criterion.**  The weights rise strictly at `k` iff `k+1 < lam`:
the threshold *is* the parameter. -/
theorem poissonWeight_lt_succ_iff (hlam : 0 < lam) (k : ℕ) :
    poissonWeight lam k < poissonWeight lam (k + 1) ↔ ((k : ℝ) + 1) < lam := by
  have hf : (0 : ℝ) < (k.factorial : ℝ) := by exact_mod_cast k.factorial_pos
  have hfs : (((k + 1).factorial : ℕ) : ℝ) = ((k : ℝ) + 1) * (k.factorial : ℝ) := by
    rw [Nat.factorial_succ]; push_cast; ring
  have hp : (0 : ℝ) < lam ^ k := pow_pos hlam k
  have key : (poissonWeight lam k < poissonWeight lam (k + 1)) ↔
      (((k : ℝ) + 1) * lam ^ k < lam * lam ^ k) := by
    unfold poissonWeight
    rw [hfs, pow_succ, div_lt_div_iff₀ hf (by positivity)]
    constructor <;> intro h <;> nlinarith
  rw [key, mul_lt_mul_iff_of_pos_right hp]

/-- The weak Poisson rise criterion. -/
theorem poissonWeight_le_succ_iff (hlam : 0 < lam) (k : ℕ) :
    poissonWeight lam k ≤ poissonWeight lam (k + 1) ↔ ((k : ℝ) + 1) ≤ lam := by
  have hf : (0 : ℝ) < (k.factorial : ℝ) := by exact_mod_cast k.factorial_pos
  have hfs : (((k + 1).factorial : ℕ) : ℝ) = ((k : ℝ) + 1) * (k.factorial : ℝ) := by
    rw [Nat.factorial_succ]; push_cast; ring
  have hp : (0 : ℝ) < lam ^ k := pow_pos hlam k
  have key : (poissonWeight lam k ≤ poissonWeight lam (k + 1)) ↔
      (((k : ℝ) + 1) * lam ^ k ≤ lam * lam ^ k) := by
    unfold poissonWeight
    rw [hfs, pow_succ, div_le_div_iff₀ hf (by positivity)]
    constructor <;> intro h <;> nlinarith
  rw [key, mul_le_mul_iff_of_pos_right hp]

/-- The Poisson weights form a threshold window with threshold `lam`, as soon as the
window `[0, n]` is long enough to contain the peak. -/
theorem poissonWeight_thresholdWindow (hlam : 0 < lam) (hn : lam < (n : ℝ) + 1) :
    ThresholdWindow n (poissonWeight lam) lam :=
  ⟨hlam, hn, fun k _ => poissonWeight_lt_succ_iff hlam k,
    fun k _ => poissonWeight_le_succ_iff hlam k⟩

/-- **The lower bracketing degree of the Poisson window is `⌈lam⌉₊ - 1`.** -/
theorem poissonWeight_firstArgmax (hlam : 0 < lam) (hn : lam < (n : ℝ) + 1) :
    firstArgmax n (poissonWeight lam) = ⌈lam⌉₊ - 1 :=
  (poissonWeight_thresholdWindow hlam hn).firstArgmax_eq

/-- **The upper bracketing degree of the Poisson window is `⌊lam⌋₊`.** -/
theorem poissonWeight_lastArgmax (hlam : 0 < lam) (hn : lam < (n : ℝ) + 1) :
    lastArgmax n (poissonWeight lam) = ⌊lam⌋₊ :=
  (poissonWeight_thresholdWindow hlam hn).lastArgmax_eq

/-- **The explicit comparison of the two Poisson bracketing degrees**: the gap is `1`
exactly when the intensity `lam` is an integer. -/
theorem poissonWeight_bracket_gap (hlam : 0 < lam) (hn : lam < (n : ℝ) + 1) :
    lastArgmax n (poissonWeight lam) = firstArgmax n (poissonWeight lam) + 1 ↔
      ∃ m : ℕ, (m : ℝ) = lam :=
  (poissonWeight_thresholdWindow hlam hn).bracket_gap

/-- The maximiser set of the Poisson window is the interval between its two
bracketing degrees. -/
theorem poissonWeight_argmax_eq_Icc (hlam : 0 < lam) (hn : lam < (n : ℝ) + 1) {k : ℕ}
    (hk : k ≤ n) :
    poissonWeight lam k = poissonWeight lam (⌈lam⌉₊ - 1) ↔ (⌈lam⌉₊ - 1 ≤ k ∧ k ≤ ⌊lam⌋₊) := by
  have h := argmax_eq_Icc (poissonWeight_strictLogConcaveOn (n := n) hlam) hk
  rw [poissonWeight_firstArgmax hlam hn, poissonWeight_lastArgmax hlam hn] at h
  exact h

/-! ## Binomial versus Poisson: the two bracketing degrees differ by at most one -/

/-- With `p = lam / n` and `q = 1 - lam / n` the binomial mode parameter is
`lam + lam / n`. -/
theorem modeParameter_of_poisson_scaling (hlam : 0 < lam) (hn : lam < (n : ℝ)) :
    modeParameter n (lam / (n : ℝ)) (1 - lam / (n : ℝ)) = lam + lam / (n : ℝ) := by
  have hnpos : (0 : ℝ) < (n : ℝ) := lt_trans hlam hn
  have hsum : lam / (n : ℝ) + (1 - lam / (n : ℝ)) = 1 := by ring
  rw [modeParameter, hsum, div_one]
  field_simp

/-- **Cross-instance comparison of bracketing degrees.**  For the binomial window with
`n` trials and success weight `lam / n` — the classical Poisson scaling — each
bracketing degree agrees with the corresponding Poisson bracketing degree up to one
unit, and the binomial degree is never smaller.  The proof is one application of the
abstract staircase lemma to the thresholds `lam` and `lam + lam/n`. -/
theorem poisson_binomial_bracket_comparison (hlam : 0 < lam) (hn : lam < (n : ℝ)) :
    lastArgmax n (poissonWeight lam)
        ≤ lastArgmax n (binomialWeight n (lam / (n : ℝ)) (1 - lam / (n : ℝ))) ∧
      lastArgmax n (binomialWeight n (lam / (n : ℝ)) (1 - lam / (n : ℝ)))
        ≤ lastArgmax n (poissonWeight lam) + 1 := by
  have hnpos : (0 : ℝ) < (n : ℝ) := lt_trans hlam hn
  have hp : (0 : ℝ) < lam / (n : ℝ) := by positivity
  have hq : (0 : ℝ) < 1 - lam / (n : ℝ) := by
    have : lam / (n : ℝ) < 1 := (div_lt_one hnpos).2 hn
    linarith
  have hratio : lam / (n : ℝ) < 1 := (div_lt_one hnpos).2 hn
  have hPois : ThresholdWindow n (poissonWeight lam) lam :=
    poissonWeight_thresholdWindow hlam (by linarith)
  have hBin : ThresholdWindow n (binomialWeight n (lam / (n : ℝ)) (1 - lam / (n : ℝ)))
      (lam + lam / (n : ℝ)) := by
    have := binomialWeight_thresholdWindow (n := n) hp hq
    rwa [modeParameter_of_poisson_scaling hlam hn] at this
  refine ⟨(ThresholdWindow.brackets_mono hPois hBin (by linarith [hp])).2,
    (ThresholdWindow.brackets_step hPois hBin (by linarith)).2⟩

end UnimodalArgmaxBracketing
end Shared