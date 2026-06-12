/-
# Parametric Continuity of Self-Consistent Timelines

This module realizes **Direction 1** of the seed `FUTURE_DIRECTIONS` on *Novikov
self-consistency as fixed-point theory*: it proves that a continuously-varying family
of contractions has a continuously-varying fixed point. Read physically, a
self-consistent timeline (a fixed point of the time-travel map `f_t`) deforms
*continuously* as the boundary data `t` varies — there are no spontaneous jumps
between causal solutions, and over an interval the self-consistent solutions trace
out a genuine path.

The whole development is a topological harvest of a single algebraic seed: the
quantitative stability estimate

  `dist (xstar s) (xstar t) ≤ dist (F s (xstar t)) (F t (xstar t)) / (1 - K)`

from `ParametricFixedPoint.contraction_fixedPoint_stability`
(`MachineLearning.FixedPoint.Parametric`). Where that file extracted *Lipschitz*
dependence from a *Lipschitz* parameterization, here we extract *continuous*
dependence from a merely *continuous* parameterization — strictly weaker hypotheses,
yet enough for the homotopy-theoretic conclusions (connectedness, paths).

## Main Results

- `tendsto_parametric_fixedPoint` : the filter-level engine — wherever the family
  converges at the *reference* fixed point, the fixed-point map converges.
- `continuous_parametric_fixedPoint` : pointwise-continuous parameter dependence
  ⇒ continuous fixed-point map (the core Novikov-timeline continuity theorem).
- `isConnected_range_parametric_fixedPoint` : over a connected parameter space the
  set of self-consistent solutions is connected — no isolated timelines.
- `parametric_fixedPoint_path` : over `[0,1]` the self-consistent solutions form a
  genuine `Path` from `xstar 0` to `xstar 1`.

## Catalog synthesis

* Built directly on `ParametricFixedPoint.contraction_fixedPoint_stability`
  (`MachineLearning.FixedPoint.Parametric`); `lipschitz_parametric_fixedPoint`
  there is the metric/quantitative companion of `continuous_parametric_fixedPoint`
  here.
* Complements `MachineLearning.FixedPoint.Core` (`exists_unique_fixedPoint_of_contraction`):
  existence/uniqueness of each timeline is upgraded to *continuity of the assignment*
  `t ↦ timeline t`.
* The connectedness/path results bridge into the Novikov-consistency language of
  `Bridges.TemporalFixedPointSemantics` (`NovikovConsistent`, `loopClosure`): the
  closed set of consistent histories varies without tearing.
-/

import Mathlib
import MachineLearning.FixedPoint.Core
import MachineLearning.FixedPoint.Parametric

open Filter Topology Metric Set Function

namespace ParametricFixedPoint

/-
!-- Lab Notebook: tendsto_parametric_fixedPoint -- !--
!-- Hypothesis: If the family converges at the *single* reference point `xstar t₀` -- !--
!--   (i.e. `F t (xstar t₀) → xstar t₀` along a filter `l`), the whole fixed-point -- !--
!--   map converges, `xstar → xstar t₀`. -- !--
!-- Result: Proved by squeezing `dist (xstar t) (xstar t₀)` between `0` and the -- !--
!--   stability bound `dist (F t (xstar t₀)) (xstar t₀)/(1-K)`, which → 0. -- !--
!-- Insight: Continuity of a fixed point needs control of the dynamics at ONE point -- !--
!--   (the limiting fixed point), not uniformly — the contraction does the rest. -- !--
!-- Failure analysis: Phrasing on a general filter `l` (not just `𝓝 t₀`) makes the -- !--
!--   corollaries — continuity, sequential continuity — uniform instances of one lemma. -- !--
!-- End Lab Notebook -- !--

**Filter-level parametric stability.** Let each `F t` be a uniform `K`-contraction
(`K < 1`) with fixed point `xstar t`. If, along a filter `l`, the family evaluated at the
*reference* fixed point converges to it (`F t (xstar t₀) → xstar t₀`), then the
fixed-point map converges, `xstar t → xstar t₀`.
-/
theorem tendsto_parametric_fixedPoint
    {α β : Type*} [MetricSpace α] [TopologicalSpace β]
    (F : β → α → α) (K : ℝ) (hK1 : K < 1)
    (hcontr : ∀ t, ∀ x y, dist (F t x) (F t y) ≤ K * dist x y)
    (xstar : β → α) (hfix : ∀ t, F t (xstar t) = xstar t)
    {l : Filter β} {t₀ : β}
    (hl : Tendsto (fun t => F t (xstar t₀)) l (𝓝 (xstar t₀))) :
    Tendsto xstar l (𝓝 (xstar t₀)) := by
  -- !-- `dist (xstar t) (xstar t₀) ≤ dist (F t (xstar t₀)) (xstar t₀)/(1-K)` by
  --     `contraction_fixedPoint_stability`; the RHS → 0, so squeeze the distance to 0. -- !--
  rw [ Metric.tendsto_nhds ] at *;
  intro ε hε;
  filter_upwards [ hl ( ( 1 - K ) * ε ) ( mul_pos ( sub_pos.mpr hK1 ) hε ) ] with t ht;
  have := ParametricFixedPoint.contraction_fixedPoint_stability ( F t ) ( F t₀ ) K hK1 ( hcontr t ) ( hfix t ) ( hfix t₀ );
  rw [ hfix t₀ ] at this;
  exact this.trans_lt ( by rwa [ div_lt_iff₀' ( sub_pos.mpr hK1 ) ] )

/-
!-- Lab Notebook: continuous_parametric_fixedPoint -- !--
!-- Hypothesis: If each `F t` is a `K`-contraction and `t ↦ F t x` is continuous for -- !--
!--   every fixed `x`, then the self-consistent timeline `t ↦ xstar t` is continuous. -- !--
!-- Result: Pointwise instance of `tendsto_parametric_fixedPoint` at `l = 𝓝 t₀`, with -- !--
!--   the hypothesis `hl` supplied by continuity of `t ↦ F t (xstar t₀)`. -- !--
!-- Insight: Only *separate* continuity in the parameter (one point at a time) is -- !--
!--   required; no joint continuity or Lipschitz constant in `t` is needed. This is -- !--
!--   strictly weaker than the hypotheses of `lipschitz_parametric_fixedPoint`. -- !--
!-- Failure analysis: Trying to prove continuity directly via ε–δ duplicates the -- !--
!--   stability estimate; routing through the filter lemma keeps the proof to two lines. -- !--
!-- End Lab Notebook -- !--

**Continuity of self-consistent timelines (Novikov continuity).** If each `F t` is a
uniform `K`-contraction (`K < 1`) and the family depends continuously on the parameter
(`t ↦ F t x` continuous for each `x`), then the fixed-point map `t ↦ xstar t` is
continuous. Self-consistent solutions deform continuously with the boundary data.
-/
theorem continuous_parametric_fixedPoint
    {α β : Type*} [MetricSpace α] [TopologicalSpace β]
    (F : β → α → α) (K : ℝ) (hK1 : K < 1)
    (hcontr : ∀ t, ∀ x y, dist (F t x) (F t y) ≤ K * dist x y)
    (hcont : ∀ x, Continuous (fun t => F t x))
    (xstar : β → α) (hfix : ∀ t, F t (xstar t) = xstar t) :
    Continuous xstar := by
  -- !-- `continuous_iff_continuousAt`; at `t₀` apply `tendsto_parametric_fixedPoint` with
  --     `l = 𝓝 t₀`, whose hypothesis is `(hcont (xstar t₀)).continuousAt` after rewriting
  --     `F t₀ (xstar t₀) = xstar t₀`. -- !--
  refine' continuous_iff_continuousAt.2 fun t₀ => _;
  refine' tendsto_parametric_fixedPoint F K hK1 hcontr xstar hfix _;
  simpa [ hfix ] using hcont ( xstar t₀ ) |> Continuous.tendsto <| t₀

/-
!-- Lab Notebook: isConnected_range_parametric_fixedPoint -- !--
!-- Hypothesis: Over a connected parameter space the set of self-consistent solutions -- !--
!--   `{xstar t}` is connected — there are no isolated/disconnected timelines. -- !--
!-- Result: Immediate from `continuous_parametric_fixedPoint` + `isConnected_range`. -- !--
!-- Insight: Topological invariants of the parameter space are inherited by the -- !--
!--   solution set; connectivity of "what could happen" forbids causal bifurcations. -- !--
!-- Failure analysis: Stating it for the image rather than a homeomorphism keeps the -- !--
!--   hypotheses minimal (no injectivity of `xstar` is needed). -- !--
!-- End Lab Notebook -- !--

**Connectedness of the solution set.** Over a connected parameter space, the range of
the self-consistent timeline map `xstar` is connected: the family of fixed points has no
isolated branches.
-/
theorem isConnected_range_parametric_fixedPoint
    {α β : Type*} [MetricSpace α] [TopologicalSpace β] [ConnectedSpace β]
    (F : β → α → α) (K : ℝ) (hK1 : K < 1)
    (hcontr : ∀ t, ∀ x y, dist (F t x) (F t y) ≤ K * dist x y)
    (hcont : ∀ x, Continuous (fun t => F t x))
    (xstar : β → α) (hfix : ∀ t, F t (xstar t) = xstar t) :
    IsConnected (Set.range xstar) := by
  -- !-- `isConnected_range` applied to `continuous_parametric_fixedPoint`. -- !--
  apply_rules [ isConnected_range, continuous_parametric_fixedPoint ]

/-
!-- Lab Notebook: parametric_fixedPoint_path -- !--
!-- Hypothesis: Over the interval `[0,1]` the self-consistent solutions assemble into a -- !--
!--   genuine `Path` from the timeline at `t = 0` to the timeline at `t = 1`. -- !--
!-- Result: Package `continuous_parametric_fixedPoint` (restricted to `unitInterval`) -- !--
!-- as a `Path`, with endpoints fixed by `source'`/`target'`. -- !--
!-- Insight: This is the literal homotopy statement of the seed conjecture — the -- !--
!--   one-parameter deformation of consistent timelines is path-connected by construction. -- !--
!-- Failure analysis: Parameterizing by `ℝ` and restricting to `unitInterval` avoids the -- !--
!--   `Fin`/subtype arithmetic friction of an intrinsic `Icc 0 1` formulation. -- !--
!-- End Lab Notebook -- !--

**Self-consistent timelines form a path.** For a continuous one-parameter family of
`K`-contractions on `ℝ`, the fixed points over `[0,1]` constitute a `Path` from
`xstar 0` to `xstar 1` that agrees with `xstar` pointwise. This is the homotopy form of
parametric Novikov consistency.
-/
theorem parametric_fixedPoint_path
    {α : Type*} [MetricSpace α]
    (F : ℝ → α → α) (K : ℝ) (hK1 : K < 1)
    (hcontr : ∀ t, ∀ x y, dist (F t x) (F t y) ≤ K * dist x y)
    (hcont : ∀ x, Continuous (fun t => F t x))
    (xstar : ℝ → α) (hfix : ∀ t, F t (xstar t) = xstar t) :
    ∃ p : Path (xstar 0) (xstar 1), ∀ s : unitInterval, p s = xstar (s : ℝ) := by
  -- !-- Build `Path` from `(continuous_parametric_fixedPoint ...).comp continuous_subtype_val`;
  --     endpoints are `xstar 0`, `xstar 1` since `((0:unitInterval):ℝ) = 0` etc. -- !--
  refine' ⟨ _, _ ⟩;
  refine' ⟨ _, _, _ ⟩;
  exact ⟨ fun s => xstar s, continuous_parametric_fixedPoint F K hK1 hcontr hcont xstar hfix |> Continuous.comp <| continuous_subtype_val ⟩;
  all_goals norm_num

end ParametricFixedPoint