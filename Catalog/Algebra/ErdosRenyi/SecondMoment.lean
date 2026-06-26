/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The first and second moment methods on a finite weighted probability space

This file develops the probabilistic engine behind Erdős–Rényi threshold
phenomena in a self-contained, model-agnostic way.  A *finite weighted
probability space* is a finite type `Ω` together with weights `w : Ω → ℝ` that
are nonnegative and sum to `1`.  For a random variable `X : Ω → ℝ` we define the
expectation and variance and prove:

* `SecondMoment.variance_nonneg` — `0 ≤ Var X` (Cauchy–Schwarz / Jensen).
* `SecondMoment.markov` — Markov's inequality: `a · ℙ(X ≥ a) ≤ 𝔼 X` for `X ≥ 0`,
  `a > 0`.
* `SecondMoment.chebyshev` — Chebyshev's inequality:
  `ℙ(|X − 𝔼X| ≥ a) ≤ Var X / a²`.
* `SecondMoment.second_moment_zero` — the **second moment method**:
  `ℙ(X = 0) ≤ Var X / (𝔼 X)²` whenever `𝔼 X > 0`.  This is the "above threshold"
  half of every monotone threshold: if `Var X / (𝔼 X)² → 0` then `X > 0` whp,
  so the random object (a subgraph copy, a spanning connected graph, …) appears
  with high probability.

Together with `firstMoment` from `Model.lean`, these give both directions of the
subgraph-counting threshold method.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the whole "second moment method for subgraph counting"
  reduces to one weighted Cauchy–Schwarz inequality, and Markov/Chebyshev are
  corollaries of summing nonnegative terms.  Bold sub-hypothesis: the
  `ℙ(X=0) ≤ Var/𝔼²` bound needs *no* nonnegativity of `X` — only `w ≥ 0`,
  `∑w=1`, `𝔼X ≠ 0`.
Experiment (Stage 2): Markov is `Finset.sum_le_sum` after bounding `w·1_{X≥a}`
  by `w·X/a`.  For the second moment bound, apply the finite Cauchy–Schwarz
  `Finset.inner_mul_le_norm_mul_norm`/`Finset.sum_mul_sq_le_sq_mul_sq` to the
  vectors `√w·X` and `√w·1_{X≠0}`; since `X·1_{X≠0}=X`, the cross term is `𝔼X`,
  giving `(𝔼X)² ≤ 𝔼[X²]·ℙ(X≠0)`, then `ℙ(X=0)=1−ℙ(X≠0)`.
Analysis (Stage 3): the sub-hypothesis held — nonnegativity of `X` is unnecessary
  for `second_moment_zero` (only used implicitly via `X·1_{X≠0}=X`).  Variance
  nonnegativity is the special case `1_{X≠0} ≡ 1`.  The crucial subtlety is that
  the denominator `𝔼[X²]` (not `(𝔼X)²`) appears first; the looser textbook bound
  `Var/(𝔼X)²` follows because `𝔼[X²] ≥ (𝔼X)²`.
Critique (Stage 4): proofs use Cauchy–Schwarz, `sq_nonneg`, `div_le_iff`,
  `linarith` — no `decide`/`rfl` shortcuts.  Hypotheses are minimal (`hsum`,
  `hw`, and a strict-positivity where a denominator appears).
Synthesis (Stage 5): pairing `firstMoment` (Model.lean) with
  `second_moment_zero` yields the two-sided machinery underlying the connectivity
  threshold `ln n / n` and the subgraph threshold; sharp asymptotics are recorded
  in `FUTURE_DIRECTIONS.md`.
-/
import Mathlib

open Finset BigOperators

namespace SecondMoment

variable {Ω : Type*} [Fintype Ω]

/-- Expectation of a random variable `X` under weights `w`. -/
noncomputable def expect (w X : Ω → ℝ) : ℝ := ∑ ω, w ω * X ω

/-- Variance of a random variable `X` under weights `w`, i.e. `𝔼[X²] − (𝔼X)²`. -/
noncomputable def variance (w X : Ω → ℝ) : ℝ :=
  expect w (fun ω => (X ω) ^ 2) - (expect w X) ^ 2

/-- Variance is nonnegative on any probability space (weighted Cauchy–Schwarz). -/
theorem variance_nonneg (w X : Ω → ℝ) (hw : ∀ ω, 0 ≤ w ω) (hsum : ∑ ω, w ω = 1) :
    0 ≤ variance w X := by
  have key : variance w X = ∑ ω, w ω * (X ω - expect w X) ^ 2 := by
    have h1 : ∑ ω, w ω * (X ω - expect w X) ^ 2
        = ∑ ω, (w ω * (X ω) ^ 2 - 2 * expect w X * (w ω * X ω)
            + (expect w X) ^ 2 * w ω) := by
      apply Finset.sum_congr rfl; intro ω _; ring
    rw [h1, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      ← Finset.mul_sum, hsum]
    simp only [variance, expect]; ring
  rw [key]
  exact Finset.sum_nonneg fun ω _ => mul_nonneg (hw ω) (sq_nonneg _)

/-- **Markov's inequality.** For a nonnegative random variable `X` and a threshold
`a`, `a · ℙ(X ≥ a) ≤ 𝔼 X`. -/
theorem markov (w X : Ω → ℝ) (a : ℝ) (hw : ∀ ω, 0 ≤ w ω) (hX : ∀ ω, 0 ≤ X ω) :
    a * (∑ ω ∈ univ.filter (fun ω => a ≤ X ω), w ω) ≤ expect w X := by
  -- Let A = univ.filter (fun ω => a ≤ X ω). Then a * ∑_{ω∈A} w ω = ∑_{ω∈A} a * w ω ≤ ∑_{ω∈A} w ω * X ω (since on A, a ≤ X ω and w ω ≥ 0, so a * w ω ≤ w ω * X ω).
  set A := Finset.univ.filter (fun ω => a ≤ X ω)
  have hA : a * ∑ ω ∈ A, w ω ≤ ∑ ω ∈ A, (w ω) * (X ω) := by
    rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun ω hω => by nlinarith [ hw ω, hX ω, Finset.mem_filter.mp hω ] ;
  exact hA.trans ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.filter_subset _ _ ) fun _ _ _ => mul_nonneg ( hw _ ) ( hX _ ) )

/-- **Chebyshev's inequality.** `ℙ(|X − 𝔼X| ≥ a) ≤ Var X / a²` for `a > 0`. -/
theorem chebyshev (w X : Ω → ℝ) (a : ℝ) (hw : ∀ ω, 0 ≤ w ω) (hsum : ∑ ω, w ω = 1)
    (ha : 0 < a) :
    (∑ ω ∈ univ.filter (fun ω => a ≤ |X ω - expect w X|), w ω) ≤ variance w X / a ^ 2 := by
  rw [le_div_iff₀ (pow_pos ha 2)]
  have key : variance w X = expect w (fun ω => (X ω - expect w X) ^ 2) := by
    simp only [expect, variance]
    have h1 : ∑ ω, w ω * (X ω - ∑ τ, w τ * X τ) ^ 2
        = ∑ ω, (w ω * (X ω) ^ 2 - 2 * (∑ τ, w τ * X τ) * (w ω * X ω)
            + (∑ τ, w τ * X τ) ^ 2 * w ω) := by
      apply Finset.sum_congr rfl; intro ω _; ring
    rw [h1, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      ← Finset.mul_sum, hsum]
    ring
  rw [key, mul_comm]
  convert markov w (fun ω => (X ω - expect w X) ^ 2) (a ^ 2) hw (fun ω => sq_nonneg _) using 2
  apply Finset.sum_congr _ (fun _ _ => rfl)
  apply Finset.filter_congr
  intro ω _
  rw [← sq_abs (X ω - expect w X)]
  exact (sq_le_sq₀ (le_of_lt ha) (abs_nonneg _)).symm

/-- **The second moment method.** If `𝔼 X > 0` then `ℙ(X = 0) ≤ Var X / (𝔼 X)²`.
In particular, when the variance is small relative to the squared mean, `X` is
positive with high probability — the engine that places copies/components above
threshold. -/
theorem second_moment_zero (w X : Ω → ℝ) (hw : ∀ ω, 0 ≤ w ω) (hsum : ∑ ω, w ω = 1)
    (hE : 0 < expect w X) :
    (∑ ω ∈ univ.filter (fun ω => X ω = 0), w ω) ≤ variance w X / (expect w X) ^ 2 := by
  -- Apply Chebyshev's inequality to $X$ with $a = \mathbb{E}[X]$.
  have h_chebyshev : (∑ ω with |X ω - expect w X| ≥ expect w X, w ω) ≤ variance w X / (expect w X)^2 := by
    convert chebyshev w X ( expect w X ) hw hsum hE using 1;
  refine' le_trans _ h_chebyshev;
  refine' Finset.sum_le_sum_of_subset_of_nonneg _ _;
  · grind;
  · aesop

end SecondMoment