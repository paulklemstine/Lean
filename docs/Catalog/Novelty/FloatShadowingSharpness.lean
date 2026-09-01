import Mathlib
import Novelty.FloatBackwardErrorHorner
import Novelty.FloatPseudoOrbitShadowing

/-!
# Nonautonomous shadowing bounds and their sharpness

Third cycle of the programme.  Two questions left open by the previous cycles
are settled here.

1. *Is the uniform Lipschitz constant necessary?*  No: `variable_shadowing`
   replaces `L` by the observed, step-dependent local expansion factors `L n`,
   producing the a-posteriori error recursion `E 0 = 0`,
   `E (n+1) = δ + L n · E n`.  Specialising to a constant sequence recovers the
   geometric bound (`errBound_const`), so the nonautonomous statement is a
   strict refinement.

2. *Is the exponential growth of the forward bound an artifact of the proof?*
   No: `finite_shadowing_sharp` exhibits, for every `L ≥ 0` and `δ ≥ 0`, an
   `L`-Lipschitz map and a `δ`-pseudo-orbit for which the distance to the true
   orbit **equals** `δ (1 + L + ⋯ + L^{n-1})` at every step.  Hence the forward
   shadowing theorem of the first cycle cannot be improved, and the improvement
   obtained in the second cycle (`expanding_backward_shadowing`) genuinely
   requires moving the initial condition.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the geometric factor in forward shadowing is exactly
attained by the linear map `z ↦ L z` driven by a constant defect `δ`, so no
proof technique can remove it while keeping the initial point fixed.
Experiment (Experimenter): the witness is the affine recursion
`x_{n+1} = L xₙ + δ` started at `0`, whose true orbit is identically `0`; the
distance is the geometric sum, verified by induction (`sharpWitness_eq`).
Analysis (Analyst): the three cycles now separate cleanly:
semantics (`O(u)` defect) → forward dynamics (`O(u · Lⁿ)`, sharp) →
backward dynamics under expansivity (`O(u)`, uniform in n).
Critique (Critic): the sharpness witness is an honest pseudo-orbit — its defect
is exactly `δ` at every step, not merely bounded by `δ` — and the map is exactly
`L`-Lipschitz, so no slack is hidden in the hypotheses.
-- !-- End Lab Notes -- !--
-/

namespace Novelty.FloatBackwardError

open scoped BigOperators

/-- The a-posteriori error recursion driven by the observed local expansion
factors: `E 0 = 0`, `E (n+1) = δ + L n · E n`. -/
def errBound (δ : ℝ) (L : ℕ → ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => δ + L n * errBound δ L n

lemma errBound_nonneg {δ : ℝ} {L : ℕ → ℝ} (hδ : 0 ≤ δ) (hL : ∀ n, 0 ≤ L n) :
    ∀ n, 0 ≤ errBound δ L n := by
  intro n
  induction n with
  | zero => simp [errBound]
  | succ n ih =>
      have := mul_nonneg (hL n) ih
      simp only [errBound]
      linarith

/-- For a constant expansion factor the recursion is the geometric sum, so the
nonautonomous bound refines the geometric one of `finite_shadowing`. -/
lemma errBound_const (δ L : ℝ) (n : ℕ) :
    errBound δ (fun _ => L) n = δ * ∑ k ∈ Finset.range n, L ^ k := by
  induction n with
  | zero => simp [errBound]
  | succ n ih =>
      have hgeom : (∑ k ∈ Finset.range (n + 1), L ^ k)
          = L * (∑ k ∈ Finset.range n, L ^ k) + 1 := geom_sum_succ
      simp only [errBound, ih, hgeom]
      ring

/-- **Nonautonomous (a-posteriori) shadowing.**  Only the local expansion factor
`L n` of `f` *at the observed point* `x n` is required; the shadowing error is
governed by the explicit recursion `errBound`. -/
theorem variable_shadowing {f : ℝ → ℝ} {δ : ℝ} {L : ℕ → ℝ} {S : Set ℝ}
    (hL : ∀ n, 0 ≤ L n) {x : ℕ → ℝ} {N : ℕ}
    (hLip : ∀ n < N, ∀ b ∈ S, |f (x n) - f b| ≤ L n * |x n - b|)
    (hy : ∀ n ≤ N, trueOrbit f (x 0) n ∈ S)
    (hpo : IsPseudoOrbit f δ x N) :
    ∀ n ≤ N, |x n - trueOrbit f (x 0) n| ≤ errBound δ L n := by
  intro n
  induction n with
  | zero => intro _; simp [trueOrbit, errBound]
  | succ n ih =>
      intro hn
      have hnN : n ≤ N := Nat.le_of_succ_le hn
      have hprev := ih hnN
      have hstep : |x (n + 1) - f (x n)| ≤ δ := hpo n hn
      have hlip : |f (x n) - f (trueOrbit f (x 0) n)| ≤ L n * |x n - trueOrbit f (x 0) n| :=
        hLip n hn _ (hy n hnN)
      have htri : |x (n + 1) - trueOrbit f (x 0) (n + 1)|
          ≤ |x (n + 1) - f (x n)| + |f (x n) - f (trueOrbit f (x 0) n)| := by
        have hsplit : x (n + 1) - trueOrbit f (x 0) (n + 1)
            = (x (n + 1) - f (x n)) + (f (x n) - f (trueOrbit f (x 0) n)) := by
          simp [trueOrbit]
        rw [hsplit]
        exact abs_add_le _ _
      have hmul : L n * |x n - trueOrbit f (x 0) n| ≤ L n * errBound δ L n :=
        mul_le_mul_of_nonneg_left hprev (hL n)
      simp only [errBound]
      linarith

/-! ### Sharpness of the forward shadowing bound -/

/-- The extremal pseudo-orbit `x₀ = 0`, `x_{n+1} = L xₙ + δ`. -/
def sharpWitness (L δ : ℝ) : ℕ → ℝ
  | 0 => 0
  | n + 1 => L * sharpWitness L δ n + δ

lemma sharpWitness_eq (L δ : ℝ) (n : ℕ) :
    sharpWitness L δ n = δ * ∑ k ∈ Finset.range n, L ^ k := by
  induction n with
  | zero => simp [sharpWitness]
  | succ n ih =>
      have hgeom : (∑ k ∈ Finset.range (n + 1), L ^ k)
          = L * (∑ k ∈ Finset.range n, L ^ k) + 1 := geom_sum_succ
      simp only [sharpWitness, ih, hgeom]
      ring

/-- **The forward shadowing bound is attained.**  For every `L ≥ 0` and every
`δ ≥ 0` there is an exactly `L`-Lipschitz map and a pseudo-orbit whose local
defect is exactly `δ` at each step, whose distance from the true orbit through
the same initial point equals `δ (1 + L + ⋯ + L^{n-1})` for every `n`.  Hence
`finite_shadowing` is optimal. -/
theorem finite_shadowing_sharp (L δ : ℝ) (hL : 0 ≤ L) (hδ : 0 ≤ δ) :
    ∃ (f : ℝ → ℝ) (x : ℕ → ℝ),
      (∀ a b : ℝ, |f a - f b| = L * |a - b|) ∧
      (∀ n : ℕ, |x (n + 1) - f (x n)| = δ) ∧
      (∀ n : ℕ, |x n - trueOrbit f (x 0) n| = δ * ∑ k ∈ Finset.range n, L ^ k) := by
  refine ⟨fun z => L * z, sharpWitness L δ, ?_, ?_, ?_⟩
  · intro a b
    rw [show L * a - L * b = L * (a - b) by ring, abs_mul, abs_of_nonneg hL]
  · intro n
    have : sharpWitness L δ (n + 1) - L * sharpWitness L δ n = δ := by
      simp [sharpWitness]
    rw [this, abs_of_nonneg hδ]
  · intro n
    have hzero : ∀ m : ℕ, trueOrbit (fun z => L * z) (sharpWitness L δ 0) m = 0 := by
      intro m
      induction m with
      | zero => simp [trueOrbit, sharpWitness]
      | succ m ih => simp [trueOrbit, ih]
    rw [hzero n, sub_zero, sharpWitness_eq]
    have hsum : (0:ℝ) ≤ ∑ k ∈ Finset.range n, L ^ k :=
      Finset.sum_nonneg fun k _ => by positivity
    exact abs_of_nonneg (mul_nonneg hδ hsum)

/-- Consequence for floating-point executions: the exponential factor in the
first-cycle bound is not an artifact of the arithmetic model.  Even an *exact*
implementation whose only error is a constant defect `δ` per step is displaced
from the true orbit by exactly `δ (Lⁿ-1)/(L-1)`. -/
theorem forward_bound_not_improvable (L δ : ℝ) (hL : 1 < L) (hδ : 0 < δ) (n : ℕ) :
    ∃ (f : ℝ → ℝ) (x : ℕ → ℝ),
      (∀ a b : ℝ, |f a - f b| = L * |a - b|) ∧
      (∀ m : ℕ, |x (m + 1) - f (x m)| = δ) ∧
      |x n - trueOrbit f (x 0) n| = δ * ((L ^ n - 1) / (L - 1)) := by
  obtain ⟨f, x, h1, h2, h3⟩ := finite_shadowing_sharp L δ (by linarith) (le_of_lt hδ)
  refine ⟨f, x, h1, h2, ?_⟩
  rw [h3 n, geom_sum_eq (by linarith) n]

/-! ### The a-posteriori bound for a binary64 logistic execution -/

lemma errBound_mono_delta {δ₁ δ₂ : ℝ} {L : ℕ → ℝ} (hL : ∀ n, 0 ≤ L n)
    (h : δ₁ ≤ δ₂) : ∀ n, errBound δ₁ L n ≤ errBound δ₂ L n := by
  intro n
  induction n with
  | zero => simp [errBound]
  | succ n ih =>
      have := mul_le_mul_of_nonneg_left ih (hL n)
      simp only [errBound]
      linarith

/-- The local expansion factor of the logistic map at an observed point of
`[0,1]`, valid against all comparison points of `[0,1]`. -/
lemma logistic_local_lipschitz {a : ℝ} (ha : a ∈ Set.Icc (0:ℝ) 1) :
    ∀ b ∈ Set.Icc (0:ℝ) 1,
      |logistic a - logistic b| ≤ 4 * max a (1 - a) * |a - b| := by
  rintro b ⟨hb0, hb1⟩
  obtain ⟨ha0, ha1⟩ := ha
  have hfac : logistic a - logistic b = (a - b) * (4 * (1 - a - b)) := by
    simp [logistic]; ring
  rw [hfac, abs_mul]
  have hle : |4 * (1 - a - b)| ≤ 4 * max a (1 - a) := by
    rw [abs_le]
    constructor
    · have : a ≤ max a (1 - a) := le_max_left _ _
      linarith
    · have : 1 - a ≤ max a (1 - a) := le_max_right _ _
      linarith
  have hnn : (0:ℝ) ≤ |a - b| := abs_nonneg _
  calc |a - b| * |4 * (1 - a - b)| ≤ |a - b| * (4 * max a (1 - a)) :=
        mul_le_mul_of_nonneg_left hle hnn
    _ = 4 * max a (1 - a) * |a - b| := by ring

/-- **A-posteriori shadowing certificate for a binary64 logistic execution.**
The exponential factor of `logistic_binary64_shadowing` is replaced by the
product of the *observed* local expansion factors `4 · max(xₖ, 1 - xₖ) ∈ [2,4]`,
a quantity computable from the execution itself. -/
theorem logistic_aposteriori_shadowing (M : RoundingModel)
    (hu : M.u ≤ (2:ℝ) ^ (-53 : ℤ)) (x₀ : ℝ) (hx₀ : x₀ ∈ Set.Icc (0:ℝ) 1) (N : ℕ)
    (hstay : ∀ n ≤ N, flOrbit M logisticCoeffs x₀ n ∈ Set.Icc (0:ℝ) 1) :
    ∀ n ≤ N, |flOrbit M logisticCoeffs x₀ n - trueOrbit logistic x₀ n|
      ≤ errBound ((2:ℝ) ^ (-46 : ℤ))
          (fun k => 4 * max (flOrbit M logisticCoeffs x₀ k)
            (1 - flOrbit M logisticCoeffs x₀ k)) n := by
  set x := flOrbit M logisticCoeffs x₀ with hxdef
  set L : ℕ → ℝ := fun k => 4 * max (x k) (1 - x k) with hLdef
  have hx0 : x 0 = x₀ := rfl
  have hL : ∀ n, 0 ≤ L n := by
    intro n
    have h1 : x n ≤ max (x n) (1 - x n) := le_max_left _ _
    have h2 : 1 - x n ≤ max (x n) (1 - x n) := le_max_right _ _
    simp only [hLdef]
    linarith
  have hmag : ∀ n ≤ N, |x n| ≤ 1 := by
    intro n hn
    obtain ⟨h0, h1⟩ := hstay n hn
    rw [abs_of_nonneg h0]; exact h1
  have hpo := flOrbit_isPseudoOrbit M logisticCoeffs x₀ 1 N hmag
  have hfun : (fun z => hornerR logisticCoeffs z) = logistic := by
    funext z; exact hornerR_logisticCoeffs z
  rw [hfun] at hpo
  have hy : ∀ n ≤ N, trueOrbit logistic (x 0) n ∈ Set.Icc (0:ℝ) 1 := by
    intro n _
    rw [hx0]
    exact trueOrbit_logistic_mem hx₀ n
  have hLip : ∀ n < N, ∀ b ∈ Set.Icc (0:ℝ) 1,
      |logistic (x n) - logistic b| ≤ L n * |x n - b| := by
    intro n hn b hb
    exact logistic_local_lipschitz (hstay n (le_of_lt hn)) b hb
  have hmain := variable_shadowing hL hLip hy hpo
  intro n hn
  refine (hmain n hn).trans ?_
  exact errBound_mono_delta hL (binary64_defect_bound M.u_nonneg hu) n

end Novelty.FloatBackwardError