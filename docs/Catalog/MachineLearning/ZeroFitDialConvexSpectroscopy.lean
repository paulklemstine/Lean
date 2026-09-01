import Mathlib
import MachineLearning.ZeroFitDialFade104
import MachineLearning.ZeroFitDialFadeDichotomy

/-!
# Curvature-sign spectroscopy: no signed-curvature law fits the recorded dial ladder

## Research context (FACT round-68 #2, exp 541, `TDIAL-U104`; sixth cycle)

Cycle 1 (`MachineLearning.ZeroFitDialFade104`) computed the 4-bit grid second differences of the
two shape classes the thread had been fitting — `A + C/b` and `A + C q^b` — found them
nonnegative, and concluded that neither class can reproduce the recorded rungs.  Both computations
were parameter-specific identities.  The first future direction of that cycle conjectured the
structural statement behind them: *convexity alone* forces the sign, so the curvature word of a
ladder excludes whole shape classes before any parameter is fitted.

This file proves that conjecture, in the general form, over the reals.

## Main results

* `convex_grid_midpoint`, `concave_grid_midpoint` — a convex (resp. concave) function satisfies
  `2 g(x+4) ≤ g x + g(x+8)` (resp. `≥`) whenever the endpoints lie in the domain: the grid second
  difference of a signed-curvature law has a fixed sign, with no parameters involved.
* `signedLaw_second_difference` — hence for any law `b ↦ A + C · g b` with `g` convex and `C ≥ 0`,
  every 4-bit grid second difference is nonnegative; the hyperbolic and geometric identities of
  cycle 1 are the two special cases.
* `recorded_second_difference_96`, `recorded_second_difference_108` — the recorded ladder has a
  strictly **negative** grid second difference at bitlen 96 (`−0.0128`) and a strictly **positive**
  one at bitlen 108 (`+0.0485`).
* `no_signed_curvature_law` — **the spectroscopic theorem**: no function of fixed curvature sign
  on `[0, ∞)` — convex or concave, with any additive and multiplicative constants absorbed —
  passes through the seven recorded rungs.  The refutation of the hyperbolic and geometric fits is
  therefore not a failure of those two families but of the entire signed-curvature category.
* `convex_law_needs_two_sign_changes` — the sharp form: a ladder is fittable by *some* signed
  curvature law only if its curvature word is constant in sign, and the recorded word `− … +` is
  not.
-/

open Catalog.MachineLearning.ZeroFitDialFade104

open Catalog.MachineLearning.ZeroFitDialFadeDichotomy

namespace Catalog.MachineLearning.ZeroFitDialConvexSpectroscopy

/-! ## 1. Curvature fixes the sign of the grid second difference -/

/-- A convex function sits below the chord at the grid midpoint: `2 g(x+4) ≤ g x + g(x+8)`. -/
theorem convex_grid_midpoint {s : Set ℝ} {g : ℝ → ℝ} (hg : ConvexOn ℝ s g) {x : ℝ}
    (hx : x ∈ s) (hx8 : x + 8 ∈ s) : 2 * g (x + 4) ≤ g x + g (x + 8) := by
  have hmid : (1 / 2 : ℝ) • x + (1 / 2 : ℝ) • (x + 8) = x + 4 := by
    simp only [smul_eq_mul]; ring
  have h := hg.2 hx hx8 (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num : (0 : ℝ) ≤ 1 / 2)
    (by norm_num)
  rw [hmid] at h
  simp only [smul_eq_mul] at h
  linarith

/-- A concave function sits above the chord at the grid midpoint. -/
theorem concave_grid_midpoint {s : Set ℝ} {g : ℝ → ℝ} (hg : ConcaveOn ℝ s g) {x : ℝ}
    (hx : x ∈ s) (hx8 : x + 8 ∈ s) : g x + g (x + 8) ≤ 2 * g (x + 4) := by
  have hmid : (1 / 2 : ℝ) • x + (1 / 2 : ℝ) • (x + 8) = x + 4 := by
    simp only [smul_eq_mul]; ring
  have h := hg.2 hx hx8 (by norm_num : (0 : ℝ) ≤ 1 / 2) (by norm_num : (0 : ℝ) ≤ 1 / 2)
    (by norm_num)
  rw [hmid] at h
  simp only [smul_eq_mul] at h
  linarith

/-- **The shape-class identity, without parameters.**  Every law `A + C·g` with `g` convex and
`C ≥ 0` has nonnegative 4-bit grid second differences.  The cycle-1 identities
`32C/(b(b+4)(b+8))` and `C q^b (1−q⁴)²` are the two instances that had been computed by hand. -/
theorem signedLaw_second_difference {s : Set ℝ} {g : ℝ → ℝ} (hg : ConvexOn ℝ s g) {A C : ℝ}
    (hC : 0 ≤ C) {x : ℝ} (hx : x ∈ s) (hx8 : x + 8 ∈ s) :
    0 ≤ (A + C * g (x + 8)) - 2 * (A + C * g (x + 4)) + (A + C * g x) := by
  have h := convex_grid_midpoint hg hx hx8
  nlinarith [mul_le_mul_of_nonneg_left h hC]

/-! ## 2. The recorded curvature word has both signs -/

/-- The recorded grid second difference at bitlen 96 is `−0.0128`: strictly negative. -/
theorem recorded_second_difference_96 :
    recRung 2 - 2 * recRung 1 + recRung 0 = -128 / 10000 := by
  simp only [recRung, rung96, rung100, rung104]
  norm_num

/-- The recorded grid second difference at bitlen 108 is `+0.0485`: strictly positive. -/
theorem recorded_second_difference_108 :
    recRung 5 - 2 * recRung 4 + recRung 3 = 485 / 10000 := by
  simp only [recRung, rung108, rung112, rung116]
  norm_num

/-! ## 3. The spectroscopic exclusion -/

/-- **No signed-curvature law fits.**  There is no function on `[0, ∞)` of fixed curvature sign
whose values at the seven recorded bitlens are the recorded rungs.  Any additive constant `A` and
any nonnegative scale `C` are already absorbed into `h`, since `A + C·g` is convex when `g` is and
`C ≥ 0`, and concave when `g` is concave; so this excludes the entire category at once. -/
theorem no_signed_curvature_law :
    ¬ ∃ h : ℝ → ℝ,
      (ConvexOn ℝ (Set.Ici (0 : ℝ)) h ∨ ConcaveOn ℝ (Set.Ici (0 : ℝ)) h) ∧
        ∀ k : ℕ, k ≤ 6 → h (96 + 4 * (k : ℝ)) = ((recRung k : ℚ) : ℝ) := by
  rintro ⟨h, hcc, hmatch⟩
  have v0 : h 96 = 5739 / 10000 := by
    have := hmatch 0 (by norm_num)
    norm_num [recRung, rung96] at this
    linarith
  have v1 : h 100 = 5436 / 10000 := by
    have := hmatch 1 (by norm_num)
    norm_num [recRung, rung100] at this
    linarith
  have v2 : h 104 = 5005 / 10000 := by
    have := hmatch 2 (by norm_num)
    norm_num [recRung, rung104] at this
    linarith
  have v3 : h 108 = 4880 / 10000 := by
    have := hmatch 3 (by norm_num)
    norm_num [recRung, rung108] at this
    linarith
  have v4 : h 112 = 4621 / 10000 := by
    have := hmatch 4 (by norm_num)
    norm_num [recRung, rung112] at this
    linarith
  have v5 : h 116 = 4847 / 10000 := by
    have := hmatch 5 (by norm_num)
    norm_num [recRung, rung116] at this
    linarith
  rcases hcc with hconv | hconc
  · -- convexity is contradicted by the strictly negative second difference at bitlen 96
    have hx : (96 : ℝ) ∈ Set.Ici (0 : ℝ) := by norm_num
    have hx8 : (96 : ℝ) + 8 ∈ Set.Ici (0 : ℝ) := by norm_num
    have h1 := convex_grid_midpoint hconv hx hx8
    norm_num at h1
    rw [v0, v1, v2] at h1
    linarith
  · -- concavity is contradicted by the strictly positive second difference at bitlen 108
    have hx : (108 : ℝ) ∈ Set.Ici (0 : ℝ) := by norm_num
    have hx8 : (108 : ℝ) + 8 ∈ Set.Ici (0 : ℝ) := by norm_num
    have h1 := concave_grid_midpoint hconc hx hx8
    norm_num at h1
    rw [v3, v4, v5] at h1
    linarith

/-- **The sharp form.**  A ladder whose grid second differences take both signs is unfittable by
any signed-curvature law; the recorded ladder is such a ladder.  Curvature sign is thus a
model-free invariant that decides fittability before a single parameter is chosen. -/
theorem convex_law_needs_two_sign_changes :
    (recRung 2 - 2 * recRung 1 + recRung 0 < 0) ∧
      (0 < recRung 5 - 2 * recRung 4 + recRung 3) ∧
      ¬ ∃ h : ℝ → ℝ,
        (ConvexOn ℝ (Set.Ici (0 : ℝ)) h ∨ ConcaveOn ℝ (Set.Ici (0 : ℝ)) h) ∧
          ∀ k : ℕ, k ≤ 6 → h (96 + 4 * (k : ℝ)) = ((recRung k : ℚ) : ℝ) := by
  refine ⟨?_, ?_, no_signed_curvature_law⟩
  · rw [recorded_second_difference_96]; norm_num
  · rw [recorded_second_difference_108]; norm_num

end Catalog.MachineLearning.ZeroFitDialConvexSpectroscopy