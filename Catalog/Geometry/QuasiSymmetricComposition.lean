/-
  Composition theory for set-local distortion of Hausdorff dimension
  ==================================================================

  This file *deepens* the set-local distortion theory developed in
  `Geometry.FractalDimension`, which built the set-local theory of how
  Lipschitz / antilipschitz / Hölder maps distort Hausdorff dimension on a fixed
  subset `s`.  That file proved single-map invariance and the two-sided Hölder
  (quasi-symmetric flavoured) distortion estimate.  The missing piece, and the
  natural next step in the fractal-topology programme, is the **closure of these
  classes under composition** and the resulting **multiplicative behaviour of the
  distortion exponents**.

  Why composition matters: quasi-symmetric maps, iterated function systems and
  their conjugacies are all built by *chaining* good maps on nested pieces.  A
  distortion theory that does not compose is not usable for fractals.  Here we
  show the set-local antilipschitz class is closed under composition and
  restriction, that global antilipschitz maps restrict to it, and — the main
  result — that the composite of two set-local bi-Hölder maps obeys the
  *product-exponent* two-sided distortion bound, with bi-Lipschitz invariance
  as the exponent-one corollary.

  To keep the file self-contained (so the proofs verify standalone), the few
  prerequisite definitions/lemmas from `Geometry.FractalDimension` are reproduced
  verbatim at the top, in the namespace `QuasiSymmetricDistortion`; the genuinely
  new contributions follow under the `### New: composition` headings.
-/
import Mathlib

open Set Function
open scoped ENNReal NNReal

namespace QuasiSymmetricDistortion

variable {X Y Z : Type*}

/-! ## Prerequisites (reproduced from `Geometry.FractalDimension`) -/

/-- If `g` is a left inverse of `f` on `s` that is Lipschitz on the image `f '' s`,
then the image cannot have smaller Hausdorff dimension than `s`. -/
theorem le_dimH_image_of_lipschitzOn_leftInverse
    [EMetricSpace X] [EMetricSpace Y]
    {f : X → Y} {g : Y → X} {s : Set X} {K : ℝ≥0}
    (hg : LipschitzOnWith K g (f '' s)) (hgf : ∀ x ∈ s, g (f x) = x) :
    dimH s ≤ dimH (f '' s) := by
  have hgimg : g '' (f '' s) = s := by
    apply Set.Subset.antisymm
    · rintro _ ⟨_, ⟨x, hx, rfl⟩, rfl⟩
      rw [hgf x hx]; exact hx
    · intro x hx
      exact ⟨f x, ⟨x, hx, rfl⟩, hgf x hx⟩
  calc dimH s = dimH (g '' (f '' s)) := by rw [hgimg]
    _ ≤ dimH (f '' s) := hg.dimH_image_le

/-- `AntilipschitzOnWith K f s` means that on the set `s`, the map `f` does not contract
distances by more than a factor `K`: `edist x y ≤ K * edist (f x) (f y)` for `x, y ∈ s`. -/
def AntilipschitzOnWith [EMetricSpace X] [EMetricSpace Y]
    (K : ℝ≥0) (f : X → Y) (s : Set X) : Prop :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → edist x y ≤ K * edist (f x) (f y)

/-- A set-local antilipschitz map is injective on the set. -/
theorem AntilipschitzOnWith.injOn [EMetricSpace X] [EMetricSpace Y]
    {K : ℝ≥0} {f : X → Y} {s : Set X} (hf : AntilipschitzOnWith K f s) :
    InjOn f s := by
  intro x hx y hy hxy
  have h := hf hx hy
  rw [hxy, edist_self, mul_zero] at h
  simpa using h

/-- The canonical left inverse of a set-local antilipschitz map is Lipschitz on the image. -/
theorem AntilipschitzOnWith.lipschitzOnWith_invFunOn
    [EMetricSpace X] [EMetricSpace Y] [Nonempty X]
    {K : ℝ≥0} {f : X → Y} {s : Set X} (hf : AntilipschitzOnWith K f s) :
    LipschitzOnWith K (invFunOn f s) (f '' s) := by
  rintro _ ⟨x, hx, rfl⟩ _ ⟨y, hy, rfl⟩
  rw [hf.injOn.leftInvOn_invFunOn hx, hf.injOn.leftInvOn_invFunOn hy]
  exact hf hx hy

/-- **Set-local antilipschitz lower bound.** A map that is antilipschitz on `s` cannot send `s`
to an image of strictly smaller Hausdorff dimension: `dimH s ≤ dimH (f '' s)`. -/
theorem AntilipschitzOnWith.le_dimH_image
    [EMetricSpace X] [EMetricSpace Y] [Nonempty X]
    {K : ℝ≥0} {f : X → Y} {s : Set X} (hf : AntilipschitzOnWith K f s) :
    dimH s ≤ dimH (f '' s) :=
  le_dimH_image_of_lipschitzOn_leftInverse hf.lipschitzOnWith_invFunOn
    (fun _ hx => hf.injOn.leftInvOn_invFunOn hx)

/-- **Set-local bi-Lipschitz invariance, intrinsic form.** A map that is simultaneously
Lipschitz and antilipschitz on `s` preserves Hausdorff dimension. -/
theorem dimH_image_eq_of_lipschitzOn_antilipschitzOn
    [EMetricSpace X] [EMetricSpace Y] [Nonempty X]
    {Kf Kf' : ℝ≥0} {f : X → Y} {s : Set X}
    (hf : LipschitzOnWith Kf f s) (hf' : AntilipschitzOnWith Kf' f s) :
    dimH (f '' s) = dimH s :=
  le_antisymm hf.dimH_image_le hf'.le_dimH_image

/-- **Two-sided Hölder distortion of Hausdorff dimension.** -/
theorem dimH_image_bounds_of_holderOn_holderOn_inverse
    [EMetricSpace X] [EMetricSpace Y]
    {f : X → Y} {g : Y → X} {s : Set X} {Cf Cg rf rg : ℝ≥0}
    (hf : HolderOnWith Cf rf f s) (hrf : 0 < rf)
    (hg : HolderOnWith Cg rg g (f '' s)) (hrg : 0 < rg)
    (hgf : ∀ x ∈ s, g (f x) = x) :
    dimH (f '' s) ≤ dimH s / rf ∧ dimH s ≤ dimH (f '' s) / rg := by
  have hgimg : g '' (f '' s) = s := by
    apply Set.Subset.antisymm
    · rintro _ ⟨_, ⟨x, hx, rfl⟩, rfl⟩
      rw [hgf x hx]; exact hx
    · intro x hx
      exact ⟨f x, ⟨x, hx, rfl⟩, hgf x hx⟩
  refine ⟨hf.dimH_image_le hrf, ?_⟩
  calc dimH s = dimH (g '' (f '' s)) := by rw [hgimg]
    _ ≤ dimH (f '' s) / rg := hg.dimH_image_le hrg

/-! ## New: composition closure of the set-local antilipschitz class -/

-- !-- Lab Notebook: AntilipschitzOnWith.comp -- !--
-- !-- Hypothesis: Set-local antilipschitz maps should compose with multiplied constants, dual to LipschitzOnWith.comp -- !--
-- !-- Result: Proved by chaining the two antilipschitz inequalities through the image -- !--
-- !-- Insight: The image membership f x ∈ f '' s is automatic; g's bound must be evaluated at points of f '' s -- !--
-- !-- Failure analysis: ENNReal mul-assoc/mono is routine -- !--
-- !-- End Lab Notebook -- !--

-- !-- chain edist x y ≤ Kf·edist(f x)(f y) ≤ Kf·Kg·edist(g f x)(g f y) -- !--
/-- **Composition of set-local antilipschitz maps.** If `f` is antilipschitz on `s` with
constant `Kf` and `g` is antilipschitz on `f '' s` with constant `Kg`, then `g ∘ f` is
antilipschitz on `s` with constant `Kf * Kg`. This is the set-local dual of
`LipschitzOnWith.comp`. -/
theorem AntilipschitzOnWith.comp [EMetricSpace X] [EMetricSpace Y] [EMetricSpace Z]
    {Kg Kf : ℝ≥0} {g : Y → Z} {f : X → Y} {s : Set X}
    (hg : AntilipschitzOnWith Kg g (f '' s)) (hf : AntilipschitzOnWith Kf f s) :
    AntilipschitzOnWith (Kf * Kg) (g ∘ f) s := by
  intro x hx y hy
  calc edist x y ≤ Kf * edist (f x) (f y) := hf hx hy
    _ ≤ Kf * (Kg * edist (g (f x)) (g (f y))) := by
        gcongr; exact hg (Set.mem_image_of_mem f hx) (Set.mem_image_of_mem f hy)
    _ = (Kf * Kg : ℝ≥0) * edist ((g ∘ f) x) ((g ∘ f) y) := by
        simp only [Function.comp_apply]; push_cast; ring

-- !-- a subset inherits the pointwise bound -- !--
/-- **Restriction.** An antilipschitz map on `s` is antilipschitz on any subset `t ⊆ s`. -/
theorem AntilipschitzOnWith.mono [EMetricSpace X] [EMetricSpace Y]
    {K : ℝ≥0} {f : X → Y} {s t : Set X} (hf : AntilipschitzOnWith K f s) (hts : t ⊆ s) :
    AntilipschitzOnWith K f t := by
  exact fun x hx y hy => hf ( hts hx ) ( hts hy )

-- !-- the global pointwise antilipschitz bound holds in particular on s -- !--
/-- **Global ⇒ local.** A globally antilipschitz map is antilipschitz on every set. -/
theorem antilipschitzOnWith_of_antilipschitzWith [EMetricSpace X] [EMetricSpace Y]
    {K : ℝ≥0} {f : X → Y} (hf : AntilipschitzWith K f) (s : Set X) :
    AntilipschitzOnWith K f s := by
  exact fun x hx y hy => hf x y

/-! ## New: Hausdorff dimension invariance under composition of bi-Lipschitz maps -/

-- !-- Lab Notebook: dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn -- !--
-- !-- Hypothesis: A composite of two set-local bi-Lipschitz maps preserves Hausdorff dimension, since the composite is itself bi-Lipschitz on s -- !--
-- !-- Result: Proved by composing the Lipschitz parts (LipschitzOnWith.comp) and the antilipschitz parts (AntilipschitzOnWith.comp), then invoking single-map invariance -- !--
-- !-- Insight: Closure under composition upgrades the single-map theorem to the iterated / conjugacy setting needed for fractals -- !--
-- !-- Failure analysis: the goal collapses directly through the single-map invariance once both composite bounds are supplied -- !--
-- !-- End Lab Notebook -- !--

-- !-- compose Lipschitz upper + antilipschitz lower bounds for g∘f -- !--
/-- **Composite bi-Lipschitz invariance of Hausdorff dimension.** If `f` is bi-Lipschitz on
`s` and `g` is bi-Lipschitz on `f '' s`, then `g ∘ f` preserves Hausdorff dimension on `s`:
`dimH ((g ∘ f) '' s) = dimH s`. -/
theorem dimH_image_comp_eq_of_lipschitzOn_antilipschitzOn
    [EMetricSpace X] [EMetricSpace Y] [EMetricSpace Z] [Nonempty X] [Nonempty Y]
    {Kf Kf' Kg Kg' : ℝ≥0} {f : X → Y} {g : Y → Z} {s : Set X}
    (hfL : LipschitzOnWith Kf f s) (hfA : AntilipschitzOnWith Kf' f s)
    (hgL : LipschitzOnWith Kg g (f '' s)) (hgA : AntilipschitzOnWith Kg' g (f '' s)) :
    dimH ((g ∘ f) '' s) = dimH s := by
  apply dimH_image_eq_of_lipschitzOn_antilipschitzOn;
  convert LipschitzOnWith.comp hgL hfL _ using 1;
  exacts [ Set.mapsTo_image f s, AntilipschitzOnWith.comp hgA hfA ]

/-! ## New: composite quasi-symmetric (bi-Hölder) distortion bound -/

-- !-- Lab Notebook: dimH_image_comp_bounds_of_biholderOn -- !--
-- !-- Hypothesis: Chaining two bi-Hölder maps multiplies the Hölder exponents, so the two-sided dimension distortion bound composes with product exponents -- !--
-- !-- Result: Proved by forming composite forward map g∘f (Hölder exp rg*rf) and composite inverse f'∘g' (Hölder exp rf'*rg'), then feeding them to dimH_image_bounds_of_holderOn_holderOn_inverse -- !--
-- !-- Insight: The exponents are genuinely multiplicative — the dimension shadow of the fact that snowflaking / Hölder conjugation composes; Lipschitz (all exps = 1) recovers exact composite invariance -- !--
-- !-- Failure analysis: the inverse composite's left-inverse identity and the MapsTo conditions for both HolderOnWith.comp applications are the fiddly parts -- !--
-- !-- End Lab Notebook -- !--

-- !-- g∘f Hölder exp rg·rf, inverse f'∘g' Hölder exp rf'·rg'; apply two-sided distortion to the composite pair -- !--
/-- **Composite quasi-symmetric (bi-Hölder) distortion of Hausdorff dimension.** Suppose
`f` is Hölder on `s` with exponent `rf`, with a left inverse `f'` that is Hölder on `f '' s`
with exponent `rf'`; and `g` is Hölder on `f '' s` with exponent `rg`, with a left inverse
`g'` that is Hölder on `g '' (f '' s)` with exponent `rg'`. Then the composite `g ∘ f`
distorts Hausdorff dimension with the *product* exponents:
`dimH ((g ∘ f) '' s) ≤ dimH s / (rg * rf)` and `dimH s ≤ dimH ((g ∘ f) '' s) / (rf' * rg')`.
With all exponents `= 1` this is exact composite invariance. -/
theorem dimH_image_comp_bounds_of_biholderOn
    [EMetricSpace X] [EMetricSpace Y] [EMetricSpace Z]
    {Cf rf Cf' rf' Cg rg Cg' rg' : ℝ≥0}
    {f : X → Y} {f' : Y → X} {g : Y → Z} {g' : Z → Y} {s : Set X}
    (hf : HolderOnWith Cf rf f s) (hrf : 0 < rf)
    (hf' : HolderOnWith Cf' rf' f' (f '' s)) (hrf' : 0 < rf')
    (hgf : ∀ x ∈ s, f' (f x) = x)
    (hg : HolderOnWith Cg rg g (f '' s)) (hrg : 0 < rg)
    (hg' : HolderOnWith Cg' rg' g' (g '' (f '' s))) (hrg' : 0 < rg')
    (hgg : ∀ y ∈ f '' s, g' (g y) = y) :
    dimH ((g ∘ f) '' s) ≤ dimH s / (rg * rf) ∧
      dimH s ≤ dimH ((g ∘ f) '' s) / (rf' * rg') := by
  convert dimH_image_bounds_of_holderOn_holderOn_inverse _ _ _ _ _;
  exact f' ∘ g';
  any_goals positivity;
  exact Cg * Cf ^ ( rg : ℝ );
  exact Cf' * Cg' ^ ( rf' : ℝ );
  · convert hg.comp hf _;
    exact Set.mapsTo_image f s;
  · convert HolderOnWith.comp hf' hg' _ using 1;
    · rw [ Set.image_comp ];
    · exact fun x hx => by aesop;
  · aesop

end QuasiSymmetricDistortion