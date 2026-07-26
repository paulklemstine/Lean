/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Uncertainty Principle Is a Fourier Thing: an analytic core

The Heisenberg uncertainty principle `Δx · Δp ≥ ħ/2` is often presented as a law of
physics.  It is not: it is a **theorem of Fourier analysis**.  The sharpest qualitative
form is the statement that a function and its transform cannot *both* be concentrated on
a small set — for the extreme case of *compact / finite–measure* support this is the
Benedicks–Amrein–Berthier phenomenon.

The mission's conjecture is that this is not special to the Fourier transform: **every**
invertible integral transform whose image consists of *holomorphic* functions inherits its
own uncertainty principle.  This is exactly what happens:

* the Fourier transform of an `L¹` function of *compact support* extends to an **entire**
  function of the complex frequency variable (Paley–Wiener);
* the Laplace transform of a function supported on `[a, ∞)` is **holomorphic on a right
  half–plane**;
* the Mellin transform is holomorphic on a vertical strip;

and in each case the transform lives on an *open, connected* domain `U ⊆ ℂ`.  The engine
behind every uncertainty principle is then a single fact from complex analysis:

> **A holomorphic function on a connected open set that vanishes on a "large" subset
> (a nonempty open set, or — for the whole plane — a set of positive measure) vanishes
> identically.**

This file isolates that engine and derives the transform uncertainty principles from it.

## Main results

* `TransformUncertainty.eqOn_zero_of_vanishes_on_open` : a function analytic on a
  preconnected set `U` that is `0` on a nonempty open `W ⊆ U` is `0` on all of `U`.
  This is the uncertainty principle valid for *any* transform (`U = ℂ` for Fourier,
  a half–plane for Laplace, a strip for Mellin): the transform cannot vanish on an open
  set — in particular it cannot be supported on the complement of one — unless it is `0`.
* `TransformUncertainty.entire_hasCompactSupport_eq_zero` : an **entire** function with
  **compact support** is identically zero.  This is the Fourier uncertainty principle in
  its cleanest form: a compactly supported signal cannot have a compactly supported
  (Fourier) transform.
* `TransformUncertainty.entire_zeroSet_measure_zero` : the zero set of a nonzero entire
  function has Lebesgue measure zero (its zeros are isolated, hence countable).
* `TransformUncertainty.entire_support_measure_top` : consequently the support of a nonzero
  entire function has *infinite* measure.
* `TransformUncertainty.entire_eq_zero_of_zeroSet_pos_measure` : the Benedicks–Amrein–Berthier
  form — an entire function vanishing on a positive–measure set is `0`.
* `TransformUncertainty.entire_of_finite_support_eq_zero` : the measure–theoretic
  uncertainty principle — an entire function whose support has finite measure is `0`.

## Worked transforms

The abstract engine is instantiated on concrete transforms:

* **Fourier / sinc.**  `sin` and `cos` (the building blocks of the sinc function, itself the
  Fourier transform of the box `𝟙_{[-1,1]}`) are entire; their zeros are null and their supports
  have infinite measure (`sin_zeroSet_measure_zero`, `sin_support_measure_top`, …).
* **Gaussian.**  `z ↦ exp(-z²)` (the fixed point of the Fourier transform) is entire and nowhere
  zero, so its support is all of `ℂ` — the equality case (`gaussian_support_eq_univ`).
* **Laplace / Mellin.**  A holomorphic function on the right half-plane, resp. a vertical strip
  (the domains of holomorphy of the Laplace and Mellin transforms), that vanishes on a nonempty
  open subset vanishes identically (`laplace_uncertainty`, `strip_uncertainty`).
-/
import Mathlib

open Complex Filter Topology MeasureTheory Set Function

namespace TransformUncertainty

/-- **Identity principle, restated.** If `f` is analytic on a preconnected set `U` and
vanishes on a nonempty open set `W ⊆ U`, then `f` vanishes on all of `U`.

This is the general uncertainty principle for holomorphic transforms: the transform cannot
be zero on *any* open set (e.g. the interior of the complement of a compact support) unless
it is identically zero.  Instantiating `U` gives the Fourier (`U = univ`), Laplace
(`U` a half–plane) and Mellin (`U` a strip) versions. -/
theorem eqOn_zero_of_vanishes_on_open {f : ℂ → ℂ} {U W : Set ℂ}
    (hf : AnalyticOnNhd ℂ f U) (hU : IsPreconnected U)
    (hW : IsOpen W) (hWU : W ⊆ U) (hWne : W.Nonempty) (hfW : EqOn f 0 W) :
    EqOn f 0 U := by
  obtain ⟨z₀, hz₀⟩ := hWne
  exact hf.eqOn_zero_of_preconnected_of_eventuallyEq_zero hU (hWU hz₀)
    (Filter.eventually_of_mem (hW.mem_nhds hz₀) fun x hx => hfW hx)

/-- **The Fourier uncertainty principle (compact–support form).** An entire function with
compact support is identically zero: a compactly supported signal cannot have a compactly
supported transform.  (For the Fourier transform of a compactly supported `L¹` function,
which is entire by Paley–Wiener, this says the transform is never compactly supported
unless the signal is `0`.) -/
theorem entire_hasCompactSupport_eq_zero {f : ℂ → ℂ}
    (hf : AnalyticOnNhd ℂ f univ) (hc : HasCompactSupport f) : f = 0 := by
  -- On the open complement of the (compact) support, `f` vanishes.
  have hfW : EqOn f 0 (tsupport f)ᶜ := fun x hx => image_eq_zero_of_notMem_tsupport hx
  -- That complement is nonempty: otherwise `tsupport f = univ` would be compact, but `ℂ` is not.
  have hWne : (tsupport f)ᶜ.Nonempty := by
    refine Set.nonempty_compl.2 fun h => ?_
    have hcpt := hc.isCompact
    rw [h] at hcpt
    exact (noncompact_univ ℂ) hcpt
  have hEq : EqOn f 0 univ :=
    eqOn_zero_of_vanishes_on_open hf isPreconnected_univ
      (isOpen_compl_iff.mpr (isClosed_tsupport f)) (subset_univ _) hWne hfW
  funext x
  simpa using hEq (mem_univ x)

/-- The zero set of a nonzero entire function is closed and discrete, hence countable, hence
of Lebesgue measure zero.  This is the quantitative heart of the uncertainty principle: the
transform of a nonzero signal can vanish only on a *null* set. -/
theorem entire_zeroSet_measure_zero {f : ℂ → ℂ}
    (hf : AnalyticOnNhd ℂ f univ) (hne : f ≠ 0) :
    volume {z : ℂ | f z = 0} = 0 := by
  set S := {z : ℂ | f z = 0} with hSdef
  obtain ⟨x, hx⟩ : ∃ x, f x ≠ 0 := Function.ne_iff.mp hne
  -- The nonzero set is codiscrete, so `S` is discrete.
  have hcodiscrete : Sᶜ ∈ Filter.codiscrete ℂ := by
    have h := hf.preimage_zero_mem_codiscrete hx
    simpa [hSdef, Set.preimage, Set.compl_setOf] using h
  have hdiscrete : IsDiscrete S := by
    have := isDiscrete_of_codiscreteWithin (U := univ) (s := S) (by simpa using hcodiscrete)
    simpa using this
  -- `S` is closed since `f` is continuous.
  have hcontinuous : Continuous f := (Complex.analyticOnNhd_univ_iff_differentiable.mp hf).continuous
  have hSclosed : IsClosed S := isClosed_eq hcontinuous continuous_const
  -- A closed discrete subset of the second–countable (Lindelöf) space `ℂ` is countable.
  have hScountable : S.Countable := hSclosed.isLindelof.countable hdiscrete.to_subtype
  exact hScountable.measure_zero volume

/-- The support of a nonzero entire function has infinite Lebesgue measure: since the zeros
form a null set, the set where `f ≠ 0` is co-null, and `ℂ` has infinite measure. -/
theorem entire_support_measure_top {f : ℂ → ℂ}
    (hf : AnalyticOnNhd ℂ f univ) (hne : f ≠ 0) :
    volume (Function.support f) = ⊤ := by
  have hZ : volume {z : ℂ | f z = 0} = 0 := entire_zeroSet_measure_zero hf hne
  have hsub : (univ : Set ℂ) ⊆ Function.support f ∪ {z : ℂ | f z = 0} := by
    intro z _
    by_cases h : f z = 0
    · exact Or.inr h
    · exact Or.inl (Function.mem_support.mpr h)
  have hle : volume (univ : Set ℂ) ≤ volume (Function.support f) + volume {z : ℂ | f z = 0} :=
    le_trans (measure_mono hsub) (measure_union_le _ _)
  have huniv : volume (univ : Set ℂ) = ⊤ := by simp
  rw [hZ, add_zero, huniv] at hle
  exact top_le_iff.mp hle

/-- **The Benedicks–Amrein–Berthier form.** If an entire function vanishes on a set of
positive Lebesgue measure, it is identically zero.  (For the Fourier transform, whose image on
compactly supported signals is entire, this is the statement that the transform cannot be
supported off a positive–measure set unless the signal is `0`.) -/
theorem entire_eq_zero_of_zeroSet_pos_measure {f : ℂ → ℂ}
    (hf : AnalyticOnNhd ℂ f univ) (hpos : 0 < volume {z : ℂ | f z = 0}) : f = 0 := by
  by_contra hne
  rw [entire_zeroSet_measure_zero hf hne] at hpos
  exact lt_irrefl 0 hpos

/-- **The measure–theoretic uncertainty principle.** An entire function whose support has
*finite* Lebesgue measure is identically zero.  This is the Benedicks–Amrein–Berthier
conclusion for the class of transforms with entire image (Fourier of compactly supported
signals): a signal and its transform cannot both be supported on sets of finite measure. -/
theorem entire_of_finite_support_eq_zero {f : ℂ → ℂ}
    (hf : AnalyticOnNhd ℂ f univ) (hfin : volume (Function.support f) ≠ ⊤) : f = 0 := by
  by_contra hne
  exact hfin (entire_support_measure_top hf hne)

/-! ## Worked transforms -/

/-- The complex sine is entire. -/
theorem sin_entire : AnalyticOnNhd ℂ Complex.sin univ :=
  Complex.analyticOnNhd_univ_iff_differentiable.2 Complex.differentiable_sin

/-- The complex cosine is entire. -/
theorem cos_entire : AnalyticOnNhd ℂ Complex.cos univ :=
  Complex.analyticOnNhd_univ_iff_differentiable.2 Complex.differentiable_cos

/-- `sin` is not the zero function (`sin (π/2) = 1`). -/
theorem sin_ne_zero : Complex.sin ≠ 0 := by
  intro h
  have := congrFun h (Real.pi / 2 : ℂ)
  simp [Complex.sin_pi_div_two] at this

/-- `cos` is not the zero function (`cos 0 = 1`). -/
theorem cos_ne_zero : Complex.cos ≠ 0 := by
  intro h
  have := congrFun h (0 : ℂ)
  simp at this

/-- **Fourier example.**  The zeros of `sin` (equivalently, of the sinc numerator) form a set
of Lebesgue measure zero: the transform vanishes only on a null set. -/
theorem sin_zeroSet_measure_zero : volume {z : ℂ | Complex.sin z = 0} = 0 :=
  entire_zeroSet_measure_zero sin_entire sin_ne_zero

/-- The zeros of `cos` form a set of Lebesgue measure zero. -/
theorem cos_zeroSet_measure_zero : volume {z : ℂ | Complex.cos z = 0} = 0 :=
  entire_zeroSet_measure_zero cos_entire cos_ne_zero

/-- **The sine wave is never compactly (nor finite-measure) supported:** its support has
infinite Lebesgue measure. -/
theorem sin_support_measure_top : volume (Function.support Complex.sin) = ⊤ :=
  entire_support_measure_top sin_entire sin_ne_zero

/-- The complex Gaussian `z ↦ exp(-z²)` (the fixed point of the Fourier transform) is entire. -/
theorem gaussian_entire : AnalyticOnNhd ℂ (fun z : ℂ => Complex.exp (-z ^ 2)) univ :=
  Complex.analyticOnNhd_univ_iff_differentiable.2 (by fun_prop)

/-- **Gaussian example.**  The Gaussian is nowhere zero, so its support is the whole plane:
the equality case of the uncertainty principle (a Gaussian signal has a Gaussian transform,
neither compactly supported). -/
theorem gaussian_support_eq_univ :
    Function.support (fun z : ℂ => Complex.exp (-z ^ 2)) = univ := by
  ext z; simp [Function.mem_support, Complex.exp_ne_zero]

/-- The Gaussian's support has infinite Lebesgue measure. -/
theorem gaussian_support_measure_top :
    volume (Function.support (fun z : ℂ => Complex.exp (-z ^ 2))) = ⊤ := by
  rw [gaussian_support_eq_univ]; simp

/-- The right half-plane `{re > 0}` is preconnected (it is convex). -/
theorem rightHalfPlane_isPreconnected : IsPreconnected {z : ℂ | 0 < z.re} := by
  have hconv : Convex ℝ {z : ℂ | 0 < z.re} := by
    apply convex_halfSpace_gt _ 0
    exact { map_add := by intro x y; simp [Complex.add_re], map_smul := by intro c x; simp }
  exact hconv.isPreconnected

/-- A vertical strip `{a < re < b}` is preconnected (it is convex). -/
theorem strip_isPreconnected (a b : ℝ) :
    IsPreconnected {z : ℂ | a < z.re ∧ z.re < b} := by
  have hlt : Convex ℝ {z : ℂ | a < z.re} := by
    apply convex_halfSpace_gt _ a
    exact { map_add := by intro x y; simp [Complex.add_re], map_smul := by intro c x; simp }
  have hgt : Convex ℝ {z : ℂ | z.re < b} := by
    apply convex_halfSpace_lt _ b
    exact { map_add := by intro x y; simp [Complex.add_re], map_smul := by intro c x; simp }
  have hint : {z : ℂ | a < z.re ∧ z.re < b} = {z : ℂ | a < z.re} ∩ {z : ℂ | z.re < b} := rfl
  rw [hint]
  exact (hlt.inter hgt).isPreconnected

/-- **Laplace uncertainty principle.**  A function holomorphic on the right half-plane
`{re > 0}` (as every Laplace transform of an `L¹` signal supported on `[a, ∞)` is) that
vanishes on a nonempty open subset `W` vanishes on the whole half-plane — hence, by
injectivity of the Laplace transform, the signal is `0`. -/
theorem laplace_uncertainty {f : ℂ → ℂ} {W : Set ℂ}
    (hf : AnalyticOnNhd ℂ f {z : ℂ | 0 < z.re})
    (hW : IsOpen W) (hWU : W ⊆ {z : ℂ | 0 < z.re}) (hWne : W.Nonempty)
    (hfW : EqOn f 0 W) : EqOn f 0 {z : ℂ | 0 < z.re} :=
  eqOn_zero_of_vanishes_on_open hf rightHalfPlane_isPreconnected hW hWU hWne hfW

/-- **Mellin uncertainty principle.**  A function holomorphic on a vertical strip
`{a < re < b}` (as every Mellin transform is on its strip of holomorphy) that vanishes on a
nonempty open subset `W` vanishes on the whole strip. -/
theorem strip_uncertainty {f : ℂ → ℂ} {W : Set ℂ} {a b : ℝ}
    (hf : AnalyticOnNhd ℂ f {z : ℂ | a < z.re ∧ z.re < b})
    (hW : IsOpen W) (hWU : W ⊆ {z : ℂ | a < z.re ∧ z.re < b}) (hWne : W.Nonempty)
    (hfW : EqOn f 0 W) : EqOn f 0 {z : ℂ | a < z.re ∧ z.re < b} :=
  eqOn_zero_of_vanishes_on_open hf (strip_isPreconnected a b) hW hWU hWne hfW

end TransformUncertainty