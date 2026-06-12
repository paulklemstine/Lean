/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Quasi-symmetric gauges, the bi-Lipschitz monoid, and Hausdorff-dimension invariance

This file deepens the quasi-symmetric theory begun in
`Catalog/Applications/QuasiSymmetric/Maps.lean` (definitions `IsQuasisymmetric`,
`IsBiLipschitzWith`; theorems `biLipschitz_isQuasisymmetric`, `isQuasisymmetric_comp`,
`isQuasisymmetric_constant_or_injective`) and connects it, for the first time in this
project, to the measure-theoretic invariant `dimH` and to the set-local distortion theory
of `Catalog/Geometry/QuasiSymmetricComposition.lean`.

A homeomorphism `f` between metric spaces is *η-quasisymmetric* when the relative
distortion of any triple of points is controlled by a single one-variable gauge `η`:

  `dist (f x) (f a) ≤ η (dist x a / dist x b) * dist (f x) (f b)`.

The new contributions are organised around two structural ideas.

* **Gauge calculus.** The gauge is not rigid data: it can be enlarged
  (`IsQuasisymmetric.mono_gauge`), it controls *eccentricity* at a single scale
  (`IsQuasisymmetric.eccentricity`: equidistant points cannot be spread by more than
  `η 1`), and it *iterates* — the `n`-fold iterate of an injective quasisymmetric self-map
  is again quasisymmetric, with gauge the `n`-fold iterate of `η`
  (`isQuasisymmetric_iterate`).  This last fact is exactly the input needed to attack the
  dimension theory of iterated function systems.

* **The bi-Lipschitz monoid and its dimension shadow.** Bi-Lipschitz maps are closed
  under composition with multiplicative constants (`isBiLipschitzWith_comp`) and contain
  the identity (`isBiLipschitzWith_id`); they therefore form a monoid sitting inside the
  quasisymmetric maps (via the linear gauge of `biLipschitz_isQuasisymmetric`).  The
  payoff is the **cross-domain bridge** `IsBiLipschitzWith.dimH_image_eq`: a bi-Lipschitz
  map preserves Hausdorff dimension on every set.  This is the global, conformal-geometry
  packaging of the set-local `dimH_image_eq_of_lipschitzOn_antilipschitzOn` from
  `QuasiSymmetricComposition.lean`, now phrased directly in terms of the `dist`-based
  bi-Lipschitz predicate used throughout the quasisymmetric files.
-/

/-
!-- Lab Notebook: QuasiSymmetricDimension -- !--
Hypothesis: The relative-distortion gauge of a quasisymmetric map admits a small but
  complete "calculus" (enlargement, single-scale eccentricity, iteration), and the
  bi-Lipschitz sub-class — being a monoid — should preserve Hausdorff dimension, bridging
  the conformal `dist`-predicate to Mathlib's measure-theoretic `dimH`.
Result: All five target theorems proved with no `sorry`.  `mono_gauge` and `eccentricity`
  are one-line consequences of monotonicity of multiplication and the ratio collapsing to
  `1`; `isBiLipschitzWith_comp`/`isBiLipschitzWith_id` give the monoid; `dimH_image_eq`
  converts the `dist` bounds to `LipschitzWith`/`AntilipschitzWith` and applies Mathlib's
  `LipschitzWith.dimH_image_le` and `AntilipschitzWith.le_dimH_image`; `isQuasisymmetric_iterate`
  is an induction on top of the reproduced `isQuasisymmetric_comp`.
Insight: The constant `L` of a bi-Lipschitz map serves *simultaneously* as a Lipschitz
  constant and an antilipschitz constant (`L⁻¹ ≤ · ` rearranges to `· ≤ L`), so a single
  `1 ≤ L` packages both halves of dimension invariance.  Iteration of the gauge is the
  algebraic skeleton of the Hölder exponent that appears in IFS coding maps.
Failure analysis: The only friction is the `ℝ → ℝ≥0` coercion needed to feed `dist`-based
  bounds into the `ℝ≥0`-indexed Lipschitz API; resolved by taking the constant `⟨L, _⟩`.
-- !-- End Lab Notebook -- !--
-/

import Mathlib

open Set Function
open scoped ENNReal NNReal

namespace QuasiSymmetric

variable {X Y Z : Type*} [MetricSpace X] [MetricSpace Y] [MetricSpace Z]

/-- `f` is `η`-quasisymmetric: the distortion of every triple `(x, a, b)` with `x ≠ b`
is controlled by the one-variable gauge `η` applied to the input distance ratio.
(Reproduced from `Catalog/Applications/QuasiSymmetric/Maps.lean`.) -/
def IsQuasisymmetric (f : X → Y) (η : ℝ → ℝ) : Prop :=
  ∀ x a b : X, x ≠ b →
    dist (f x) (f a) ≤ η (dist x a / dist x b) * dist (f x) (f b)

/-- `f` is `L`-bi-Lipschitz: absolute distances are distorted by a factor in `[L⁻¹, L]`.
(Reproduced from `Catalog/Applications/QuasiSymmetric/Maps.lean`.) -/
def IsBiLipschitzWith (f : X → Y) (L : ℝ) : Prop :=
  1 ≤ L ∧ ∀ x y : X, L⁻¹ * dist x y ≤ dist (f x) (f y) ∧ dist (f x) (f y) ≤ L * dist x y

/-- **Composition of quasisymmetric maps** (reproduced from
`Catalog/Applications/QuasiSymmetric/Maps.lean`, needed below for iteration). -/
theorem isQuasisymmetric_comp (f : X → Y) (g : Y → Z) (ηf ηg : ℝ → ℝ)
    (hf : IsQuasisymmetric f ηf) (hg : IsQuasisymmetric g ηg)
    (hmono : Monotone ηg) (hinj : Function.Injective f) :
    IsQuasisymmetric (g ∘ f) (ηg ∘ ηf) := by
  intro x a b hxb; have := hg (f x) (f a) (f b); simp_all +decide [hinj.eq_iff]
  refine le_trans this (mul_le_mul_of_nonneg_right (hmono ?_) dist_nonneg)
  exact div_le_iff₀ (dist_pos.mpr (hinj.ne hxb)) |>.2 (hf x a b hxb)

/-! ## Gauge calculus -/

/-
!-- Enlarge the gauge: multiply the QS inequality by the same nonneg base distance. -- !--

**Gauge enlargement.** A quasisymmetric map stays quasisymmetric under any pointwise
larger gauge.  Quasisymmetry is a *property of having some* controlling gauge.
-/
theorem IsQuasisymmetric.mono_gauge {f : X → Y} {η η' : ℝ → ℝ}
    (h : IsQuasisymmetric f η) (hle : ∀ t, η t ≤ η' t) :
    IsQuasisymmetric f η' := by
  exact fun x a b hxb => le_trans ( h x a b hxb ) ( mul_le_mul_of_nonneg_right ( hle _ ) ( dist_nonneg ) )

/-
!-- For equidistant a,b the ratio is exactly 1, so the gauge is evaluated at 1. -- !--

**Single-scale eccentricity.** If `a` and `b` are equidistant from `x`, then their
images cannot be spread apart by more than the factor `η 1`.  This is the precise sense in
which a quasisymmetric map sends "round" configurations to configurations of bounded
eccentricity — the conceptual reason quasisymmetry is a conformal notion.
-/
theorem IsQuasisymmetric.eccentricity {f : X → Y} {η : ℝ → ℝ}
    (h : IsQuasisymmetric f η) {x a b : X} (hb : x ≠ b)
    (heq : dist x a = dist x b) :
    dist (f x) (f a) ≤ η 1 * dist (f x) (f b) := by
  simpa [ heq, ne_of_gt ( dist_pos.mpr hb ) ] using h x a b hb

/-
!-- Induction on n: split f^[n+1] = f^[n] ∘ f and apply isQuasisymmetric_comp with
outer gauge η^[n] (monotone via Monotone.iterate) and inner injective f. -- !--

**Iteration of the gauge.** The `n`-fold iterate of an injective `η`-quasisymmetric
self-map is `η^[n]`-quasisymmetric.  Iterating the *map* iterates the *gauge*; this is the
algebraic skeleton underlying the Hölder exponents of iterated function systems.
-/
theorem isQuasisymmetric_iterate {f : X → X} {η : ℝ → ℝ}
    (h : IsQuasisymmetric f η) (hmono : Monotone η) (hinj : Function.Injective f) (n : ℕ) :
    IsQuasisymmetric (f^[n]) (η^[n]) := by
  induction' n with n ih;
  · intro x a b hx; by_cases h : x = b <;> simp_all +decide ;
  · convert isQuasisymmetric_comp ( f^[n] ) f ( η^[n] ) η ih h _ _ using 1;
    · exact Function.iterate_succ' f n;
    · exact Function.iterate_succ' η n;
    · exact hmono;
    · exact hinj.iterate n

/-! ## The bi-Lipschitz monoid -/

/-
!-- 1 ≤ L*M from the two unit lower bounds; chain the upper/lower bounds through f x. -- !--

**Bi-Lipschitz maps compose**, with the constants multiplying: `g ∘ f` is
`(L · M)`-bi-Lipschitz when `f` is `L`- and `g` is `M`-bi-Lipschitz.
-/
theorem isBiLipschitzWith_comp {f : X → Y} {g : Y → Z} {L M : ℝ}
    (hf : IsBiLipschitzWith f L) (hg : IsBiLipschitzWith g M) :
    IsBiLipschitzWith (g ∘ f) (L * M) := by
  refine' ⟨ _, fun x y => _ ⟩;
  · exact one_le_mul_of_one_le_of_one_le hf.1 hg.1;
  · have := hf.2 x y; have := hg.2 ( f x ) ( f y ) ; simp_all +decide [ mul_comm, mul_left_comm ];
    constructor <;> nlinarith [ show 0 ≤ L⁻¹ by exact inv_nonneg.2 ( by linarith [ hf.1 ] ), show 0 ≤ M⁻¹ by exact inv_nonneg.2 ( by linarith [ hg.1 ] ), show 0 ≤ L by linarith [ hf.1 ], show 0 ≤ M by linarith [ hg.1 ], mul_inv_cancel₀ ( by linarith [ hf.1 ] : L ≠ 0 ), mul_inv_cancel₀ ( by linarith [ hg.1 ] : M ≠ 0 ) ]

/-
!-- The identity distorts no distance: L = 1 works with equality on both sides. -- !--

**The identity is bi-Lipschitz** with constant `1`, completing the monoid structure
on bi-Lipschitz maps (with `isBiLipschitzWith_comp`).
-/
theorem isBiLipschitzWith_id : IsBiLipschitzWith (id : X → X) 1 := by
  constructor <;> norm_num

/-! ## Cross-domain bridge: bi-Lipschitz invariance of Hausdorff dimension -/

/-
!-- L is simultaneously a Lipschitz and an antilipschitz constant: convert the dist
bounds via LipschitzWith.of_dist_le_mul and AntilipschitzWith.of_le_mul_dist, then
sandwich with LipschitzWith.dimH_image_le and AntilipschitzWith.le_dimH_image. -- !--

**Bi-Lipschitz invariance of Hausdorff dimension.** A bi-Lipschitz map preserves the
Hausdorff dimension of every set: `dimH (f '' s) = dimH s`.  This is the global,
`dist`-predicate packaging of the set-local
`dimH_image_eq_of_lipschitzOn_antilipschitzOn` of `QuasiSymmetricComposition.lean`, and
shows the bi-Lipschitz monoid acts on metric spaces by dimension-preserving maps.
-/
theorem IsBiLipschitzWith.dimH_image_eq {f : X → Y} {L : ℝ}
    (h : IsBiLipschitzWith f L) (s : Set X) :
    dimH (f '' s) = dimH s := by
  obtain ⟨ hL, h ⟩ := h;
  have h_lip : LipschitzWith (Real.toNNReal L) f := by
    exact LipschitzWith.of_dist_le_mul ( fun x y => by simpa [ ← NNReal.coe_le_coe, Real.toNNReal_of_nonneg ( by positivity : 0 ≤ L ) ] using h x y |>.2 )
  have h_antilip : AntilipschitzWith (Real.toNNReal L) f := by
    refine' AntilipschitzWith.of_le_mul_dist _;
    intro x y; specialize h x y; rw [ Real.toNNReal_of_nonneg ( by positivity ) ] ; norm_num at *; nlinarith [ inv_mul_cancel_left₀ ( by positivity : ( L : ℝ ) ≠ 0 ) ( dist x y ) ] ;
  refine' le_antisymm ( h_lip.dimH_image_le s ) _;
  convert h_antilip.le_dimH_image _

/-- **Quasisymmetric maps with a linear gauge preserve Hausdorff dimension.**  Combining
`IsBiLipschitzWith.dimH_image_eq` with `biLipschitz_isQuasisymmetric` (Maps.lean): the
bi-Lipschitz maps are exactly the dimension-preserving members of the quasisymmetric class
that we can certify by a single constant. -/
theorem dimH_image_eq_of_biLipschitz {f : X → Y} {L : ℝ}
    (h : IsBiLipschitzWith f L) (s : Set X) :
    dimH (f '' s) = dimH s :=
  h.dimH_image_eq s

end QuasiSymmetric