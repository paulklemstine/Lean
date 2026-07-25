import Mathlib

/-!
# Lipschitz Ball Inclusion in Margin Cells and Intrinsic Radius Bounds

This file proves that certified robustness balls, determined by a local margin and
a Lipschitz constant, are contained in the entire margin cell of the predicted class,
even when the competing label set is infinite. We then derive Chebyshev-radius lower
bounds for decision cells.

## Main definitions

* `marginCell` — the set of points where class `i` strictly dominates all competitors
* `inscribedRadiusAt` — the supremum of radii of closed balls centered at `x` in a set

## Main results

* `lipschitz_lower_bound` — a Lipschitz function's value at `y` is bounded below by its
  value at `x` minus `K * dist x y`
* `ball_subset_marginCell_of_pairwise_lipschitz` — the open ball of radius `γ / K`
  around `x` is contained in the margin cell
* `exists_pos_ball_subset_marginCell` — existential version
* `closedBall_subset_marginCell_of_lt` — closed balls of radius `< γ/K` are in the cell
* `certifiedRadius_le_inscribedRadiusAt_marginCell` — the certified radius `γ / K` is
  a lower bound on the inscribed radius when the set is bounded above

## Key insight

The proof does not require finiteness of the label set `ι`. If the hypotheses provide
a uniform margin `γ` and pairwise Lipschitz bound `K` for every competitor, the geometry
is infinitary for free.
-/

open Metric Set

noncomputable section

/-! ### Definitions -/

/-- The margin cell of class `i`: the set of points where the score of `i` strictly
    exceeds the score of every other class. This is a generalized weighted Voronoi region. -/
def marginCell {X ι : Type*} (s : ι → X → ℝ) (i : ι) : Set X :=
  {y | ∀ j, j ≠ i → s i y > s j y}

/-- The inscribed radius of a set `A` at a point `x`: the supremum of radii `r ≥ 0`
    such that `closedBall x r ⊆ A`. -/
def inscribedRadiusAt {X : Type*} [PseudoMetricSpace X] (A : Set X) (x : X) : ℝ :=
  sSup {r : ℝ | 0 ≤ r ∧ Metric.closedBall x r ⊆ A}

/-! ### Core lemma: Lipschitz lower bound -/

/-- If `f` is `K`-Lipschitz, then `f y ≥ f x - K * dist x y`.
    This is the key perturbation inequality. -/
theorem lipschitz_lower_bound
    {X : Type*} [PseudoMetricSpace X]
    (f : X → ℝ) (K : NNReal) (x y : X)
    (hlip : LipschitzWith K f) :
    f x - (K : ℝ) * dist x y ≤ f y := by
  have := hlip.dist_le_mul x y; norm_num at *; linarith [abs_le.mp this]

/-! ### Membership lemma -/

/-- The center `x` itself belongs to the margin cell when the margin is positive. -/
theorem center_mem_marginCell
    {X ι : Type*}
    (s : ι → X → ℝ) (i : ι) (x : X) (γ : ℝ)
    (hγ : 0 < γ)
    (hmargin : ∀ j, j ≠ i → γ ≤ s i x - s j x) :
    x ∈ marginCell s i := by
  exact fun j hj => by linarith [hmargin j hj]

/-! ### Theorem A: Ball inclusion in margin cell -/

/-- **Ball inclusion theorem.** If every pairwise score gap `s i · - s j ·` is `K`-Lipschitz,
    and the gap at `x` is at least `γ` for every competitor `j ≠ i`, then the open ball
    of radius `γ / K` around `x` lies entirely in the margin cell of class `i`.

    This holds for arbitrary (possibly infinite) label sets `ι`. -/
theorem ball_subset_marginCell_of_pairwise_lipschitz
    {X ι : Type*} [PseudoMetricSpace X]
    (s : ι → X → ℝ) (i : ι) (x : X) (K : NNReal) (γ : ℝ)
    (hK : (K : ℝ) > 0)
    (_hγ : 0 < γ)
    (hlip : ∀ j, j ≠ i → LipschitzWith K (fun y => s i y - s j y))
    (hmargin : ∀ j, j ≠ i → γ ≤ s i x - s j x) :
    Metric.ball x (γ / (K : ℝ)) ⊆ marginCell s i := by
  refine' fun y hy => fun j hj => _
  have := hlip j hj
  have := this.dist_le_mul y x
  nlinarith [abs_le.mp this, hmargin j hj,
    show (dist y x : ℝ) < γ / K from mod_cast hy, mul_div_cancel₀ γ hK.ne']

/-! ### Existential form -/

/-- There exists a positive-radius ball inside the margin cell. -/
theorem exists_pos_ball_subset_marginCell
    {X ι : Type*} [PseudoMetricSpace X]
    (s : ι → X → ℝ) (i : ι) (x : X) (K : NNReal) (γ : ℝ)
    (hK : (K : ℝ) > 0)
    (hγ : 0 < γ)
    (hlip : ∀ j, j ≠ i → LipschitzWith K (fun y => s i y - s j y))
    (hmargin : ∀ j, j ≠ i → γ ≤ s i x - s j x) :
    ∃ r : ℝ, r > 0 ∧ Metric.ball x r ⊆ marginCell s i := by
  exact ⟨γ / (K : ℝ), by positivity,
    ball_subset_marginCell_of_pairwise_lipschitz s i x K γ hK hγ hlip hmargin⟩

/-! ### Closed ball inclusions -/

/-- If an open ball of radius `r` is contained in `A`, then any closed ball of
    strictly smaller radius is also contained. -/
theorem closedBall_subset_of_ball_subset
    {X : Type*} [PseudoMetricSpace X]
    {A : Set X} {x : X} {r : ℝ}
    (h : Metric.ball x r ⊆ A)
    {r' : ℝ} (hr' : r' < r) :
    Metric.closedBall x r' ⊆ A := by
  exact fun y hy => h <| Metric.mem_ball.2 <| lt_of_le_of_lt (Metric.mem_closedBall.1 hy) hr'

/-- **Closed ball inclusion.** For any `r < γ / K`, the closed ball of radius `r`
    is contained in the margin cell. -/
theorem closedBall_subset_marginCell_of_lt
    {X ι : Type*} [PseudoMetricSpace X]
    (s : ι → X → ℝ) (i : ι) (x : X) (K : NNReal) (γ : ℝ)
    (hK : (K : ℝ) > 0)
    (hγ : 0 < γ)
    (hlip : ∀ j, j ≠ i → LipschitzWith K (fun y => s i y - s j y))
    (hmargin : ∀ j, j ≠ i → γ ≤ s i x - s j x)
    {r : ℝ} (hr : r < γ / (K : ℝ)) :
    Metric.closedBall x r ⊆ marginCell s i :=
  closedBall_subset_of_ball_subset
    (ball_subset_marginCell_of_pairwise_lipschitz s i x K γ hK hγ hlip hmargin) hr

/-! ### Theorem B: Inscribed radius lower bound -/

/-
**Inscribed radius lower bound.** When the set of valid inscribed radii is bounded
    above (which holds whenever the margin cell is a proper subset of the space), the
    certified radius `γ / K` is a lower bound on the inscribed radius at `x`.
-/
theorem certifiedRadius_le_inscribedRadiusAt_marginCell
    {X ι : Type*} [PseudoMetricSpace X]
    (s : ι → X → ℝ) (i : ι) (x : X) (K : NNReal) (γ : ℝ)
    (hK : (K : ℝ) > 0)
    (hγ : 0 < γ)
    (hlip : ∀ j, j ≠ i → LipschitzWith K (fun y => s i y - s j y))
    (hmargin : ∀ j, j ≠ i → γ ≤ s i x - s j x)
    (hbdd : BddAbove {r : ℝ | 0 ≤ r ∧ Metric.closedBall x r ⊆ marginCell s i}) :
    γ / (K : ℝ) ≤ inscribedRadiusAt (marginCell s i) x := by
  refine' le_of_forall_pos_le_add fun ε ε0 => _;
  -- Choose $r$ such that $0 \leq r < \gamma / K$ and $r > \gamma / K - \epsilon$.
  obtain ⟨r, hr₀, hr₁⟩ : ∃ r : ℝ, 0 ≤ r ∧ r < γ / (K : ℝ) ∧ r > γ / (K : ℝ) - ε := by
    by_cases h₂ : γ / (K : ℝ) - ε < 0;
    · exact ⟨ 0, le_rfl, by positivity, h₂ ⟩;
    · exact ⟨ γ / K - ε / 2, by linarith, by linarith, by linarith ⟩;
  linarith [ show inscribedRadiusAt ( marginCell s i ) x ≥ r from le_csSup hbdd ⟨ hr₀, closedBall_subset_marginCell_of_lt s i x K γ hK hγ hlip hmargin hr₁.1 ⟩ ]

end