/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Universal Approximation via Standard ML Activations

This file is a research contribution to the **EML (Exponential–Multiplicative–Logarithmic)
universal approximation** programme. The single-feature density theorem of
`EML.ExponentialPolynomialDensity` (`EMLExpFeature.adjoin_singleton_dense`) shows that
*any* injective continuous feature `g : C(X, ℝ)`, on a compact space `X`, generates a
uniformly dense subalgebra of `C(X, ℝ)`. That file instantiated the feature with the
exponential `exp`.

Here we observe that the *standard activation functions of machine learning* —
the **logistic sigmoid** `σ(x) = 1/(1+e^{-x})`, the **softplus** `s(x) = log(1+e^x)`,
the hyperbolic tangent **tanh**, and **arctan** — are all *strictly monotone* and hence
injective on ℝ. Consequently a *single neuron* with any of these activations, followed by
an arbitrary polynomial read-out, is a universal approximator on every compact domain.

This unifies the classical "one hidden unit + polynomial read-out is universal" folklore
across the usual activation zoo, deriving each instance from one strict-monotonicity fact.

## Main results

* `injective_comp` — composition of injective continuous maps stays injective.
* `activation_feature_dense` / `activation_feature_approx` — a single injective activation
  composed with an injective feature is universal (and its ε-form).
* `strictMono_feature_dense` — the convenient strict-monotone interface.
* `sigmoidCM`, `softplusCM`, `tanhCM`, `arctanCM` — the activation functions as elements
  of `C(ℝ, ℝ)`, with strict monotonicity / injectivity lemmas.
* `sigmoid_dense_Icc`, `softplus_dense_Icc`, `tanh_dense_Icc`, `arctan_dense_Icc` — density
  of single-activation networks on a compact interval `[a, b]`.
* `activation_dense_Icc` — the uniform statement for an arbitrary strictly monotone
  continuous activation.

-- !-- Lab Notes -- !--
HYPOTHESIS (A1). The `exp`-specific density result of `ExponentialPolynomialDensity` is an
artefact of `exp` being injective, not of any special analytic property of `exp`. Every
strictly monotone continuous activation should therefore be universal as a single feature.

EXPERIMENT. We isolate `injective_comp` (injective ∘ injective = injective) and feed it to
`EMLExpFeature.adjoin_singleton_dense`. Strict monotonicity ⇒ injectivity via
`StrictMono.injective`, so each activation reduces to a one-line monotonicity check.
OUTCOME: A1 confirmed for sigmoid, softplus, tanh, arctan.

INSIGHT. The universal-approximation content sits entirely in *injectivity of the feature*.
Activation choice (sigmoid vs softplus vs tanh vs arctan) is irrelevant to density; it only
affects quantitative approximation rates, which are outside the scope of point-separation.

FAILURE ANALYSIS. `tanh` has no packaged `StrictMono` lemma in Mathlib v4.28.0; we derive
it from `Real.arsinh`-style monotonicity of `sinh` together with positivity of `cosh`.
-/
import Mathlib
import EML.ExponentialPolynomialDensity

noncomputable section

open ContinuousMap Real Topology
open EMLExpFeature

namespace EMLActivation

/-! ## Section 1: General activation density from injectivity -/

variable {X : Type*} [TopologicalSpace X]

/-- Composition of injective continuous maps is injective. -/
theorem injective_comp (σ : C(ℝ, ℝ)) (hσ : Function.Injective σ)
    (g : C(X, ℝ)) (hg : Function.Injective g) :
    Function.Injective (σ.comp g) := by
  intro x y h
  exact hg (hσ (by simpa [ContinuousMap.comp_apply] using h))

variable [CompactSpace X]

/-- **Single activation universal approximation.**
For compact `X`, any injective continuous activation `σ` composed with any injective
feature `g` generates a uniformly dense subalgebra of `C(X, ℝ)`. -/
theorem activation_feature_dense (σ : C(ℝ, ℝ)) (hσ : Function.Injective σ)
    (g : C(X, ℝ)) (hg : Function.Injective g) :
    (Algebra.adjoin ℝ {σ.comp g}).topologicalClosure = ⊤ :=
  EMLExpFeature.adjoin_singleton_dense _ (injective_comp σ hσ g hg)

/-- ε-form of `activation_feature_dense`. -/
theorem activation_feature_approx (σ : C(ℝ, ℝ)) (hσ : Function.Injective σ)
    (g : C(X, ℝ)) (hg : Function.Injective g)
    (f : C(X, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ p : Algebra.adjoin ℝ {σ.comp g}, ‖(p : C(X, ℝ)) - f‖ < ε :=
  EMLExpFeature.adjoin_singleton_approx _ (injective_comp σ hσ g hg) f hε

/-- A strictly monotone continuous activation `σ : ℝ → ℝ` is universal as a single feature.
Convenience interface taking the monotonicity and continuity as separate hypotheses. -/
theorem strictMono_feature_dense (σ : ℝ → ℝ) (hmono : StrictMono σ) (hcont : Continuous σ)
    (g : C(X, ℝ)) (hg : Function.Injective g) :
    (Algebra.adjoin ℝ {(⟨σ, hcont⟩ : C(ℝ, ℝ)).comp g}).topologicalClosure = ⊤ :=
  activation_feature_dense ⟨σ, hcont⟩ hmono.injective g hg

/-! ## Section 2: The standard activations as elements of `C(ℝ, ℝ)` -/

/-- The logistic **sigmoid** `σ(x) = 1 / (1 + e^{-x})`. -/
def sigmoid (x : ℝ) : ℝ := 1 / (1 + Real.exp (-x))

theorem continuous_sigmoid : Continuous sigmoid := by
  exact Continuous.div continuous_const ( by continuity ) fun x => by positivity;

theorem strictMono_sigmoid : StrictMono sigmoid := by
  intro x y hxy; unfold sigmoid; rw [ div_lt_div_iff₀ ] <;> linarith [ Real.exp_pos ( -y ), Real.exp_lt_exp.mpr ( neg_lt_neg_iff.mpr hxy ) ] ;

/-- The sigmoid as a continuous map. -/
def sigmoidCM : C(ℝ, ℝ) := ⟨sigmoid, continuous_sigmoid⟩

theorem injective_sigmoid : Function.Injective sigmoid := strictMono_sigmoid.injective

/-- The **softplus** activation `s(x) = log(1 + e^x)`. -/
def softplus (x : ℝ) : ℝ := Real.log (1 + Real.exp x)

theorem continuous_softplus : Continuous softplus := by
  exact Continuous.log ( by exact Continuous.add continuous_const <| Real.continuous_exp ) fun x => by positivity;

theorem strictMono_softplus : StrictMono softplus := by
  exact fun x y hxy => Real.log_lt_log ( by positivity ) ( by gcongr )

/-- The softplus as a continuous map. -/
def softplusCM : C(ℝ, ℝ) := ⟨softplus, continuous_softplus⟩

theorem injective_softplus : Function.Injective softplus := strictMono_softplus.injective

/-
The hyperbolic tangent **tanh** activation.
-/
theorem continuous_tanh : Continuous Real.tanh := by
  rw [ show tanh = fun x => Real.tanh x from funext fun x => rfl ];
  simpa only [ Real.tanh_eq_sinh_div_cosh ] using Real.continuous_sinh.div Real.continuous_cosh fun x => ne_of_gt ( Real.cosh_pos x )

theorem strictMono_tanh : StrictMono Real.tanh := by
  have h_deriv_pos : ∀ x : ℝ, deriv Real.tanh x = 1 / Real.cosh x ^ 2 := by
    intro x; rw [ show tanh = fun x => Real.sinh x / Real.cosh x from funext Real.tanh_eq_sinh_div_cosh ] ; simp +decide [ Real.differentiableAt_sinh, Real.differentiableAt_cosh, ne_of_gt ( Real.cosh_pos _ ) ] ;
    norm_num [ ← sq ];
  exact strictMono_of_deriv_pos fun x => h_deriv_pos x ▸ by positivity;

/-- `tanh` as a continuous map. -/
def tanhCM : C(ℝ, ℝ) := ⟨Real.tanh, continuous_tanh⟩

theorem injective_tanh : Function.Injective Real.tanh := strictMono_tanh.injective

/-- The **arctan** activation. -/
def arctanCM : C(ℝ, ℝ) := ⟨Real.arctan, Real.continuous_arctan⟩

theorem injective_arctan : Function.Injective Real.arctan := Real.arctan_strictMono.injective

/-! ## Section 3: Density on a compact interval `[a, b]` -/

/-- **Sigmoid network universality on `[a, b]`.** -/
theorem sigmoid_dense_Icc (a b : ℝ) :
    (Algebra.adjoin ℝ {sigmoidCM.comp (EMLExpFeature.iccCoord a b)}).topologicalClosure = ⊤ :=
  activation_feature_dense sigmoidCM injective_sigmoid _
    (EMLExpFeature.injective_iccCoord a b)

/-- **Softplus network universality on `[a, b]`.** -/
theorem softplus_dense_Icc (a b : ℝ) :
    (Algebra.adjoin ℝ {softplusCM.comp (EMLExpFeature.iccCoord a b)}).topologicalClosure = ⊤ :=
  activation_feature_dense softplusCM injective_softplus _
    (EMLExpFeature.injective_iccCoord a b)

/-- **Tanh network universality on `[a, b]`.** -/
theorem tanh_dense_Icc (a b : ℝ) :
    (Algebra.adjoin ℝ {tanhCM.comp (EMLExpFeature.iccCoord a b)}).topologicalClosure = ⊤ :=
  activation_feature_dense tanhCM injective_tanh _
    (EMLExpFeature.injective_iccCoord a b)

/-- **Arctan network universality on `[a, b]`.** -/
theorem arctan_dense_Icc (a b : ℝ) :
    (Algebra.adjoin ℝ {arctanCM.comp (EMLExpFeature.iccCoord a b)}).topologicalClosure = ⊤ :=
  activation_feature_dense arctanCM injective_arctan _
    (EMLExpFeature.injective_iccCoord a b)

/-- **Uniform activation universality on `[a, b]`.**
Any strictly monotone continuous activation is universal as a single feature on `[a, b]`. -/
theorem activation_dense_Icc (σ : ℝ → ℝ) (hmono : StrictMono σ) (hcont : Continuous σ)
    (a b : ℝ) :
    (Algebra.adjoin ℝ {(⟨σ, hcont⟩ : C(ℝ, ℝ)).comp (EMLExpFeature.iccCoord a b)}).topologicalClosure = ⊤ :=
  strictMono_feature_dense σ hmono hcont _ (EMLExpFeature.injective_iccCoord a b)

/-! ## Section 4: Sharpness — injectivity is necessary (converse of universality)

-- !-- Lab Notes -- !--
HYPOTHESIS (A2). Injectivity of the activation is not merely sufficient but *necessary*
for single-feature universality: if `σ` collapses two attained feature values, then *no*
polynomial read-out in `σ ∘ g` can tell the corresponding points apart, so the generated
subalgebra fails to separate points.

EXPERIMENT. Every element of `Algebra.adjoin ℝ {h}` is a polynomial in `h`, so it must take
equal values wherever `h` does (`adjoin_singleton_eq_of_eq`, by `Algebra.adjoin_induction`).
Applying this to `h = σ ∘ g` at two points with equal feature value yields the obstruction
(`activation_not_separates`). OUTCOME: A2 confirmed — this is the converse half of the
characterization conjectured as C4 in FUTURE_DIRECTIONS.md.
-/

omit [CompactSpace X] in
/-- Any element of the singleton-generated subalgebra `Algebra.adjoin ℝ {h}` takes equal
values at any two points where the generator `h` agrees. -/
theorem adjoin_singleton_eq_of_eq (h : C(X, ℝ)) {x y : X} (hxy : h x = h y)
    (f : C(X, ℝ)) (hf : f ∈ Algebra.adjoin ℝ {h}) : f x = f y := by
  induction hf using Algebra.adjoin_induction with
  | mem s hs => rw [Set.mem_singleton_iff] at hs; subst hs; exact hxy
  | algebraMap r => rfl
  | add a b _ _ ha hb => simp only [ContinuousMap.coe_add, Pi.add_apply, ha, hb]
  | mul a b _ _ ha hb => simp only [ContinuousMap.coe_mul, Pi.mul_apply, ha, hb]

omit [CompactSpace X] in
/-- **Sharpness / necessity of injectivity.**
If an activation `σ` collapses the two (distinct-point) feature values `g x` and `g y`,
then the subalgebra generated by `σ ∘ g` does **not** separate points. Hence injectivity of
the activation is necessary for the single-feature universality of `activation_feature_dense`. -/
theorem activation_not_separates (σ : C(ℝ, ℝ)) (g : C(X, ℝ)) {x y : X}
    (hxy : x ≠ y) (hσg : σ (g x) = σ (g y)) :
    ¬ (Algebra.adjoin ℝ {σ.comp g}).SeparatesPoints := by
  intro hsep
  obtain ⟨f, ⟨p, hp, rfl⟩, hfxy⟩ := hsep hxy
  exact hfxy (adjoin_singleton_eq_of_eq (σ.comp g)
    (by simpa [ContinuousMap.comp_apply] using hσg) p hp)

end EMLActivation

end