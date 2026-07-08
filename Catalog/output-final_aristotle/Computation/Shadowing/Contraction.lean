import Mathlib

/-!
# The Shadowing Lemma for Contracting Maps

The **shadowing lemma** of dynamical systems asserts that near an *approximate*
orbit of a map there is a genuine orbit.  Concretely, a `δ`-*pseudo-orbit* is a
sequence `x₀, x₁, x₂, …` that only *approximately* follows the dynamics, meaning
`dist (xₙ₊₁) (f xₙ) ≤ δ` for every `n`.  Such sequences are exactly what a
computer produces when it iterates a map with rounding error `δ`.  The shadowing
property says that every such pseudo-orbit is `ε`-close, term by term, to a *true*
orbit `y₀, y₁, y₂, …` (`yₙ₊₁ = f yₙ`).  Interpreted numerically: the floating
point trajectory a program computes is the *shadow* of a real mathematical orbit.

This file proves the shadowing lemma for **contracting maps**, i.e. maps that are
`LipschitzWith L` for some `L < 1`.  For contractions the result is unconditional
and *global in time*: the same true orbit shadows the pseudo-orbit for **all**
iterates simultaneously, so the "shadowing time" is infinite.  The construction is
completely explicit — the shadowing orbit is just the true orbit through the first
point `x₀` — and the shadowing radius is bounded by the sharp geometric estimate

  `dist (xₙ) (f^[n] x₀) ≤ δ · (1 - Lⁿ) / (1 - L) ≤ δ / (1 - L).`

## Main results

* `Computation.Shadowing.contraction_error_geometric`: the sharp geometric error
  bound `dist (x n) (f^[n] (x 0)) ≤ δ * (1 - L^n) / (1 - L)`.
* `Computation.Shadowing.contraction_error_bound`: the uniform-in-`n` error bound
  `dist (x n) (f^[n] (x 0)) ≤ δ / (1 - L)`.
* `Computation.Shadowing.contraction_shadowing`: the qualitative shadowing lemma
  (`∀ ε > 0, ∃ δ > 0, …`) valid over a general metric space.
* `Computation.Shadowing.contraction_shadowing_explicit`: an explicit admissible
  `δ = ε (1 - L)` witnessing shadowing.
* `Computation.Shadowing.logisticHalf_shadowing`: a concrete instance for the
  affine contraction `x ↦ x / 2` on `ℝ`, showing the theorem is non-vacuous.
-/

namespace Computation.Shadowing

open Function

variable {X : Type*} [MetricSpace X]

/-- `y` is a genuine orbit of `f`: each term is the image of the previous one. -/
def IsOrbit (f : X → X) (y : ℕ → X) : Prop := ∀ n, y (n + 1) = f (y n)

/-- `x` is a `δ`-pseudo-orbit of `f`: it follows the dynamics up to error `δ`. -/
def IsPseudoOrbit (f : X → X) (δ : ℝ) (x : ℕ → X) : Prop :=
  ∀ n, dist (x (n + 1)) (f (x n)) ≤ δ

omit [MetricSpace X] in
/-- The iterate `n ↦ f^[n] (x 0)` is always a genuine orbit. -/
theorem isOrbit_iterate (f : X → X) (x0 : X) : IsOrbit f (fun n => f^[n] x0) := by
  intro n; simp [Function.iterate_succ_apply']

/-- A pseudo-orbit only exists for `δ ≥ 0` (distances are non-negative). -/
theorem pseudoOrbit_delta_nonneg {f : X → X} {δ : ℝ} {x : ℕ → X}
    (hx : IsPseudoOrbit f δ x) : 0 ≤ δ :=
  le_trans dist_nonneg (hx 0)

/-- **Sharp geometric error bound.**  For a contraction `f` (Lipschitz constant
`L < 1`), the `n`-th term of any `δ`-pseudo-orbit stays within
`δ · (1 - Lⁿ) / (1 - L)` of the true orbit through the initial point `x 0`. -/
theorem contraction_error_geometric (f : X → X) (L : NNReal) (hL : LipschitzWith L f)
    (hL1 : (L : ℝ) < 1) {δ : ℝ} {x : ℕ → X} (hx : IsPseudoOrbit f δ x) (n : ℕ) :
    dist (x n) (f^[n] (x 0)) ≤ δ * (1 - (L : ℝ) ^ n) / (1 - L) := by
  induction' n with n ih
  · simp +decide
  · rw [pow_succ', Function.iterate_succ_apply']
    refine le_trans (dist_triangle _ (f (x n)) _) ?_
    refine le_trans (add_le_add (hx n) (hL.dist_le_mul _ _)) ?_
    rw [le_div_iff₀] at * <;>
      nlinarith [show (0 : ℝ) ≤ L by positivity, pow_nonneg (show (0 : ℝ) ≤ L by positivity) n]

/-- **Uniform error bound.**  Every term of a `δ`-pseudo-orbit of a contraction is
within `δ / (1 - L)` of the true orbit through `x 0`, uniformly in `n`. -/
theorem contraction_error_bound (f : X → X) (L : NNReal) (hL : LipschitzWith L f)
    (hL1 : (L : ℝ) < 1) {δ : ℝ} {x : ℕ → X} (hx : IsPseudoOrbit f δ x) (n : ℕ) :
    dist (x n) (f^[n] (x 0)) ≤ δ / (1 - L) := by
  refine le_trans ?_ (div_le_div_of_nonneg_right
    (show δ * (1 - (L : ℝ) ^ n) ≤ δ from
      mul_le_of_le_one_right (pseudoOrbit_delta_nonneg hx) (sub_le_self _ (by positivity)))
    (sub_nonneg.2 hL1.le))
  convert contraction_error_geometric f L hL hL1 hx n using 1

/-- **Explicit shadowing.**  Choosing `δ = ε (1 - L)`, every `δ`-pseudo-orbit of a
contraction `f` is `ε`-shadowed, for all iterates simultaneously, by the genuine
orbit through its starting point. -/
theorem contraction_shadowing_explicit (f : X → X) (L : NNReal) (hL : LipschitzWith L f)
    (hL1 : (L : ℝ) < 1) {ε : ℝ} {x : ℕ → X}
    (hx : IsPseudoOrbit f (ε * (1 - L)) x) :
    IsOrbit f (fun n => f^[n] (x 0)) ∧ (fun n => f^[n] (x 0)) 0 = x 0 ∧
      ∀ n, dist (x n) (f^[n] (x 0)) ≤ ε := by
  refine ⟨isOrbit_iterate f (x 0), rfl, fun n => ?_⟩
  convert contraction_error_bound f L hL hL1 hx n using 1
  rw [mul_div_cancel_right₀ _ (sub_ne_zero_of_ne hL1.ne')]

/-- **The shadowing lemma for contractions.**  For every target accuracy `ε > 0`
there is a tolerance `δ > 0` such that *every* `δ`-pseudo-orbit is `ε`-shadowed by
a genuine orbit, uniformly over all iterates.  The shadowing time is infinite. -/
theorem contraction_shadowing (f : X → X) (L : NNReal) (hL : LipschitzWith L f)
    (hL1 : (L : ℝ) < 1) {ε : ℝ} (hε : 0 < ε) :
    ∃ δ > 0, ∀ x : ℕ → X, IsPseudoOrbit f δ x →
      ∃ y : ℕ → X, IsOrbit f y ∧ y 0 = x 0 ∧ ∀ n, dist (x n) (y n) ≤ ε := by
  -- Choose `δ = ε · (1 - L)`, which is positive since `ε > 0` and `L < 1`.
  refine ⟨ε * (1 - (L : ℝ)), mul_pos hε (sub_pos_of_lt hL1), fun x hx =>
    ⟨_, isOrbit_iterate f (x 0), rfl,
      fun n => (contraction_shadowing_explicit f L hL hL1 hx).2.2 n⟩⟩

/-! ### A concrete instance: the affine contraction `x ↦ x / 2` on `ℝ` -/

/-- The map `x ↦ x / 2` on `ℝ` is `LipschitzWith (1/2)`. -/
theorem lipschitz_half : LipschitzWith (1 / 2 : NNReal) (fun x : ℝ => x / 2) := by
  norm_num [div_eq_inv_mul, mul_assoc, mul_comm, mul_left_comm, lipschitzWith_iff_norm_sub_le]
  exact fun x y => by
    rw [← sub_mul, abs_mul, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 1 / 2)]

/-- **Concrete shadowing** for `x ↦ x / 2`.  Any pseudo-orbit computed with
tolerance `ε / 2` is `ε`-shadowed by a true orbit, for every `ε > 0`.  This
witnesses that the general shadowing lemma is not vacuous. -/
theorem logisticHalf_shadowing {ε : ℝ} (hε : 0 < ε) :
    ∃ δ > 0, ∀ x : ℕ → ℝ, IsPseudoOrbit (fun x => x / 2) δ x →
      ∃ y : ℕ → ℝ, IsOrbit (fun x => x / 2) y ∧ y 0 = x 0 ∧
        ∀ n, dist (x n) (y n) ≤ ε := by
  convert contraction_shadowing (fun x : ℝ => x / 2) (1 / 2) lipschitz_half (by norm_num) hε

end Computation.Shadowing