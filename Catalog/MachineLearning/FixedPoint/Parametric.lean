/-
# Parametric Fixed-Point Theory

This module extends the quantitative Banach contraction principle developed in
`MachineLearning.FixedPoint.Core` to *parametric* families of contractions.
The unifying engine is a single stability estimate

  `dist xf xg ≤ dist (f xg) (g xg) / (1 - K)`,

from which Lipschitz dependence of the fixed point on a metric parameter,
equivariance under symmetries, and non-autonomous composition rates all follow.

## Main Results

- `contraction_fixedPoint_stability` : the fundamental fixed-point stability bound.
- `lipschitz_parametric_fixedPoint`  : Lipschitz families have Lipschitz fixed-point maps.
- `equivariant_fixedPoint`           : symmetries of a contraction family are inherited
                                        by the fixed point (via uniqueness).
- `iteratedComp_contraction`         : a non-autonomous composition of `n` contractions
                                        contracts with constant `∏ i, K i`.
- `contraction_K_eq_one_no_fixedPoint` : sharpness — at `K = 1` fixed points may fail.

## Catalog synthesis

We build directly on `MachineLearning.FixedPoint.Core`:
* `eq_of_fixedPoints_of_contraction` (uniqueness) powers `equivariant_fixedPoint`;
* `contraction_comp` (two-map composition) is generalized by `iteratedComp_contraction`;
* the stability bound is the missing quantitative companion to the qualitative
  Banach existence theorem `exists_unique_fixedPoint_of_contraction`.
-/

import Mathlib
import MachineLearning.FixedPoint.Core

open Filter Topology Metric Set Function

namespace ParametricFixedPoint

-- !-- Lab Notebook: contraction_fixedPoint_stability -- !--
-- !-- Hypothesis: The distance between fixed points of two maps is controlled by how far -- !--
-- !--   the maps disagree at one of the fixed points, amplified by 1/(1-K). -- !--
-- !-- Result: Proved by a single triangle inequality + the contraction of `f`. -- !--
-- !-- Insight: Only ONE of the two maps need be a contraction; `g` is arbitrary. This is -- !--
-- !--   the quantitative core that all parametric corollaries reduce to. -- !--
-- !-- Failure analysis: A symmetric two-sided hypothesis is unnecessary, and even `0 ≤ K` -- !--
-- !--   is not needed; weakening to a single contraction makes the lemma maximally reusable. -- !--
-- !-- End Lab Notebook -- !--

/-- **Fixed-point stability.** If `f` is a `K`-contraction (`K < 1`) with fixed point
`xf`, and `g` is *any* map with fixed point `xg`, then the two fixed points differ by at
most `dist (f xg) (g xg) / (1 - K)`. This is the quantitative engine of parametric
fixed-point theory. -/
theorem contraction_fixedPoint_stability
    {α : Type*} [MetricSpace α]
    (f g : α → α) (K : ℝ) (hK1 : K < 1)
    (hf : ∀ x y, dist (f x) (f y) ≤ K * dist x y)
    {xf xg : α} (hxf : f xf = xf) (hxg : g xg = xg) :
    dist xf xg ≤ dist (f xg) (g xg) / (1 - K) := by
  -- !-- triangle inequality `dist xf xg ≤ dist (f xf) (f xg) + dist (f xg) (g xg)`,
  --     then absorb the contracted term into the LHS and divide by `1 - K > 0`. -- !--
  have h_triangle : dist xf xg ≤ dist (f xf) (f xg) + dist (f xg) (g xg) := by
    simpa [hxf, hxg] using dist_triangle xf (f xg) xg
  rw [le_div_iff₀] <;> nlinarith [hf xf xg]

-- !-- Lab Notebook: lipschitz_parametric_fixedPoint -- !--
-- !-- Hypothesis: If a family `F : β → α → α` is uniformly `L`-Lipschitz in the parameter -- !--
-- !--   and each `F t` is a `K`-contraction, the fixed-point map is `L/(1-K)`-Lipschitz. -- !--
-- !-- Result: One-line corollary of `contraction_fixedPoint_stability`. -- !--
-- !-- Insight: The explicit constant `L/(1-K)` falls out of the stability denominator with -- !--
-- !--   no extra machinery — confirming Direction 1 of the seed FUTURE_DIRECTIONS. -- !--
-- !-- Failure analysis: Stating Lipschitz dependence directly would require redoing the -- !--
-- !--   triangle-inequality argument; routing through stability avoids duplication. -- !--
-- !-- End Lab Notebook -- !--

/-- **Lipschitz parametric Banach theorem (explicit constant).**
Let `F : β → α → α` be a family where each `F t` is a `K`-contraction, the family is
uniformly `L`-Lipschitz in the parameter (`dist (F s x) (F t x) ≤ L * dist s t`), and
`xstar t` is a fixed point of `F t`. Then the fixed-point map is `L/(1-K)`-Lipschitz. -/
theorem lipschitz_parametric_fixedPoint
    {α β : Type*} [MetricSpace α] [PseudoMetricSpace β]
    (F : β → α → α) (K L : ℝ) (hK1 : K < 1)
    (hcontr : ∀ t, ∀ x y, dist (F t x) (F t y) ≤ K * dist x y)
    (hlip : ∀ s t x, dist (F s x) (F t x) ≤ L * dist s t)
    (xstar : β → α) (hfix : ∀ t, F t (xstar t) = xstar t)
    (s t : β) :
    dist (xstar s) (xstar t) ≤ (L / (1 - K)) * dist s t := by
  rw [div_mul_eq_mul_div, le_div_iff₀]
  · have := hlip s t (xstar t)
    have := hcontr s (xstar s) (xstar t)
    have := dist_triangle (xstar s) (F s (xstar t)) (xstar t)
    simp_all +decide [dist_comm]
    nlinarith
  · linarith

-- !-- Lab Notebook: equivariant_fixedPoint -- !--
-- !-- Hypothesis: A symmetry `φ` intertwining two contractions (`φ ∘ f = f' ∘ φ`) maps the -- !--
-- !--   fixed point of `f` to the fixed point of `f'`. -- !--
-- !-- Result: Proved via uniqueness of fixed points (Core.eq_of_fixedPoints_of_contraction). -- !--
-- !-- Insight: Equivariance is *forced* by uniqueness, not built in — symmetries of the -- !--
-- !--   dynamics are automatically inherited by self-consistent solutions. -- !--
-- !-- Failure analysis: A `MulAction` formulation is heavier; the bare intertwining map `φ` -- !--
-- !--   captures the same content and is more reusable. -- !--
-- !-- End Lab Notebook -- !--

/-- **Equivariance of fixed points.** If `φ` intertwines `f` and `f'`
(`φ (f x) = f' (φ x)` for all `x`) and `f'` is a `K`-contraction, then `φ` sends the
fixed point of `f` to the fixed point of `f'`. Symmetries of the family are inherited
by the fixed point. -/
theorem equivariant_fixedPoint
    {α : Type*} [MetricSpace α]
    (f f' φ : α → α) (K : ℝ) (hK0 : 0 ≤ K) (hK1 : K < 1)
    (hf' : ∀ x y, dist (f' x) (f' y) ≤ K * dist x y)
    (hconj : ∀ x, φ (f x) = f' (φ x))
    {x x' : α} (hx : f x = x) (hx' : f' x' = x') :
    φ x = x' := by
  -- !-- `φ x` is a fixed point of `f'` (since `f' (φ x) = φ (f x) = φ x`), so it equals the
  --     unique fixed point `x'` by `eq_of_fixedPoints_of_contraction`. -- !--
  convert eq_of_fixedPoints_of_contraction f' K hK0 hK1 hf' _ hx'
  rw [← hconj, hx]

/-- A non-autonomous composition `g (n-1) ∘ ⋯ ∘ g 0`. -/
def iteratedComp {α : Type*} (g : ℕ → α → α) : ℕ → (α → α)
  | 0 => id
  | (n + 1) => g n ∘ iteratedComp g n

@[simp] theorem iteratedComp_zero {α : Type*} (g : ℕ → α → α) :
    iteratedComp g 0 = id := rfl

@[simp] theorem iteratedComp_succ {α : Type*} (g : ℕ → α → α) (n : ℕ) :
    iteratedComp g (n + 1) = g n ∘ iteratedComp g n := rfl

-- !-- Lab Notebook: iteratedComp_contraction -- !--
-- !-- Hypothesis: Composing `n` maps with individual constants `K i` gives a contraction -- !--
-- !--   with constant `∏ i ∈ range n, K i`. -- !--
-- !-- Result: Proved by induction on `n`, generalizing Core.contraction_comp from 2 maps. -- !--
-- !-- Insight: Non-autonomous (varying-`K`) dynamics contract at the *product* rate; the -- !--
-- !--   stationary `K^n` bound is the special case `K i = K`. -- !--
-- !-- Failure analysis: Using `Fin n → _` index types creates coercion friction; indexing by -- !--
-- !--   `ℕ` with a `Finset.range` product is far smoother for induction. -- !--
-- !-- End Lab Notebook -- !--

/-- **Non-autonomous composition rate.** The composition of `n` maps with individual
contraction constants `K i ≥ 0` is a contraction with constant `∏ i ∈ range n, K i`.
This generalizes the two-map composition lemma `contraction_comp` from the catalog. -/
theorem iteratedComp_contraction
    {α : Type*} [MetricSpace α]
    (g : ℕ → α → α) (K : ℕ → ℝ) (hK0 : ∀ i, 0 ≤ K i)
    (hg : ∀ i x y, dist (g i x) (g i y) ≤ K i * dist x y) :
    ∀ n x y, dist (iteratedComp g n x) (iteratedComp g n y)
      ≤ (∏ i ∈ Finset.range n, K i) * dist x y := by
  intro n
  induction' n with n ih
  · simp +decide [iteratedComp]
  · simp_all +decide [Finset.prod_range_succ]
    exact fun x y => le_trans (hg _ _ _) (by nlinarith [ih x y, hK0 n])

-- !-- Lab Notebook: contraction_K_eq_one_no_fixedPoint -- !--
-- !-- Hypothesis (Critic): The strict bound `K < 1` is essential; at `K = 1` existence fails. -- !--
-- !-- Result: Disproof of the `K = 1` Banach claim via the translation `x ↦ x + 1` on ℝ. -- !--
-- !-- Insight: `x ↦ x+1` is a (non-strict) `1`-Lipschitz isometry with NO fixed point, -- !--
-- !--   pinpointing exactly where the parametric theory degenerates (cf. Direction 2). -- !--
-- !-- Failure analysis: A bounded-domain counterexample would also work but ℝ + translation -- !--
-- !--   is the cleanest witness that the denominator `1-K` cannot be allowed to vanish. -- !--
-- !-- End Lab Notebook -- !--

/-- **Sharpness at `K = 1`.** There is a `1`-Lipschitz self-map of `ℝ`
(`x ↦ x + 1`) with no fixed point. Hence the hypothesis `K < 1` cannot be relaxed to
`K ≤ 1` in any of the existence/stability results above. -/
theorem contraction_K_eq_one_no_fixedPoint :
    ∃ f : ℝ → ℝ, (∀ x y, dist (f x) (f y) ≤ 1 * dist x y) ∧ ¬ ∃ x, f x = x :=
  ⟨fun x => x + 1, fun x y => by norm_num [dist_eq_norm], by norm_num⟩

end ParametricFixedPoint