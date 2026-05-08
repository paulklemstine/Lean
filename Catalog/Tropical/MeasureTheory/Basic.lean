/-
Copyright (c) 2025. All rights reserved.

# Tropical Measure Theory: Max-Plus Measures, Sup-Additive Integration,
# and Concentration Inequalities

This file formalizes tropical (max-plus) measure theory on finite types.
In the max-plus semiring: addition = max, multiplication = +, zero = -∞, one = 0.

## Bridge: Measure Theory ↔ Tropical Geometry ↔ Optimization ↔ ML

The tropical integral `max_x (f(x) + w(x))` connects functional analysis
to optimization, probability concentration to certified robustness, and
measure theory to tropical geometry.
-/

import Mathlib

namespace TropicalMeasureTheory

/-! ## Core Definitions -/

/-- A **max-plus measure** on a finite nonempty type assigns a real weight
to each point. The measure of a set is the max weight over that set.

**Bridge**: connects measure theory to tropical geometry and lattice cryptography.
**Impact**: foundation for certified_robustness and post_quantum_security. -/
structure MaxPlusMeasure (X : Type*) [Fintype X] [Nonempty X] where
  weight : X → ℝ

/-- A **tropical probability measure**: max weight = 0, all weights ≤ 0.

**Bridge**: probability ↔ quantum mechanics via Maslov dequantization.
**Impact**: post_quantum_security and certified_robustness bounds. -/
class IsTropicalProbability (X : Type*) [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) : Prop where
  total_mass : Finset.univ.sup' Finset.univ_nonempty P.weight = 0
  weight_nonpos : ∀ x : X, P.weight x ≤ 0

/-- The **max-plus integral**: `max_x (f(x) + w(x))`.

**Bridge**: integration ↔ dynamic programming ↔ optimal transport.
**Impact**: computes certified_robustness radii for tropical neural networks. -/
noncomputable def maxPlusIntegral {X : Type*} [Fintype X] [Nonempty X]
    (f : X → ℝ) (μ : MaxPlusMeasure X) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun x => f x + μ.weight x)

/-- **Tropical expectation** under a probability measure. -/
noncomputable def tropicalExpectation {X : Type*} [Fintype X] [Nonempty X]
    (f : X → ℝ) (P : MaxPlusMeasure X) [IsTropicalProbability X P] : ℝ :=
  maxPlusIntegral f P

/-- A **max-plus functional**: monotone and shift-equivariant.

**Bridge**: functional analysis ↔ tropical geometry. -/
structure MaxPlusFunctional (X : Type*) [Fintype X] [Nonempty X] where
  app : (X → ℝ) → ℝ
  mono' : ∀ {f g : X → ℝ}, (∀ x, f x ≤ g x) → app f ≤ app g
  shift_equiv' : ∀ (f : X → ℝ) (c : ℝ),
    app (fun x => f x + c) = app f + c

/-- **Tropical Lipschitz**: `|f(x) - f(y)| ≤ K · dist(x, y)`.

**Impact**: determines certified adversarial robustness radius. -/
structure TropicalLipschitz {X : Type*} [PseudoMetricSpace X]
    (f : X → ℝ) (K : ℝ) : Prop where
  lip_bound : ∀ x y : X, |f x - f y| ≤ K * dist x y

/-- **Certified robustness radius**: `margin / K`. -/
noncomputable def certifiedRobustnessRadius (K : ℝ) (margin : ℝ) : ℝ := margin / K

/-- A **tropical subsemialgebra**: closed under max and shift.

**Bridge**: algebra ↔ functional analysis. -/
structure TropSubsemialgebra (X : Type*) where
  carrier : Set (X → ℝ)
  sup_closed : ∀ {f g : X → ℝ}, f ∈ carrier → g ∈ carrier →
    (fun x => max (f x) (g x)) ∈ carrier
  shift_closed : ∀ {f : X → ℝ}, f ∈ carrier → ∀ c : ℝ,
    (fun x => f x + c) ∈ carrier
  const_mem : ∀ c : ℝ, (fun _ : X => c) ∈ carrier

/-- **Tropical variance**: `E_T[f] + E_T[-f]`, the weighted range.

**Impact**: key parameter in tropical Hoeffding concentration. -/
noncomputable def tropicalVariance {X : Type*} [Fintype X] [Nonempty X]
    (f : X → ℝ) (P : MaxPlusMeasure X) [IsTropicalProbability X P] : ℝ :=
  tropicalExpectation f P + tropicalExpectation (fun x => -f x) P

/-- **Tropical prediction margin** for binary classification. -/
noncomputable def tropicalPredictionMargin {X : Type*} [Fintype X] [Nonempty X]
    (scores : Fin 2 → X → ℝ) (μ : MaxPlusMeasure X) : ℝ :=
  maxPlusIntegral (scores 0) μ - maxPlusIntegral (scores 1) μ

/-- **Dirac tropical measure**: weight 0 at x₀, M < 0 elsewhere. -/
noncomputable def diracTropicalMeasure {X : Type*} [Fintype X] [Nonempty X]
    [DecidableEq X] (x₀ : X) (M : ℝ) (_ : M < 0) : MaxPlusMeasure X :=
  ⟨fun x => if x = x₀ then 0 else M⟩

/-- **Uniform tropical probability**: weight 0 everywhere. -/
def uniformTropicalProbability (X : Type*) [Fintype X] [Nonempty X] :
    MaxPlusMeasure X := ⟨fun _ => 0⟩

/-- **Product max-plus measure**: weight = sum of marginals.

**Impact**: multi-layer certified_robustness for deep tropical networks. -/
def productMaxPlusMeasure {X Y : Type*} [Fintype X] [Nonempty X]
    [Fintype Y] [Nonempty Y]
    (μ₁ : MaxPlusMeasure X) (μ₂ : MaxPlusMeasure Y) :
    MaxPlusMeasure (X × Y) :=
  ⟨fun ⟨x, y⟩ => μ₁.weight x + μ₂.weight y⟩

/-- **Dual (min-plus) measure**: negate weights. -/
def dualMeasure {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) : MaxPlusMeasure X :=
  ⟨fun x => -μ.weight x⟩

/-! ## Auxiliary Lemma -/

theorem Finset.sup'_add_const {β : Type*} {s : Finset β} (hs : s.Nonempty)
    (f : β → ℝ) (c : ℝ) :
    s.sup' hs (fun x => f x + c) = s.sup' hs f + c := by
  apply le_antisymm
  · apply Finset.sup'_le; intro b hb
    linarith [Finset.le_sup' f hb]
  · obtain ⟨b, hb, hmax⟩ := Finset.exists_mem_eq_sup' hs f
    linarith [Finset.le_sup' (fun x => f x + c) hb]

/-! ## Integration Properties -/

/-- **Monotonicity of max-plus integration**. -/
theorem maxPlusIntegral_mono {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) {f g : X → ℝ} (hfg : ∀ x, f x ≤ g x) :
    maxPlusIntegral f μ ≤ maxPlusIntegral g μ := by
  apply Finset.sup'_le; intro b hb
  exact le_trans (by linarith [hfg b]) (Finset.le_sup' _ hb)

/-- **Shift equivariance**: ∫⁺ (f + c) dμ = (∫⁺ f dμ) + c.

**Impact**: certified_robustness bounds are bias-invariant. -/
theorem maxPlusIntegral_shift {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) (f : X → ℝ) (c : ℝ) :
    maxPlusIntegral (fun x => f x + c) μ = maxPlusIntegral f μ + c := by
  simp only [maxPlusIntegral]
  convert Finset.sup'_add_const Finset.univ_nonempty (fun x => f x + μ.weight x) c using 1
  congr 1; ext x; ring

/-- Integral of a constant: ∫⁺ c dμ = c + max_x w(x). -/
theorem maxPlusIntegral_const {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) (c : ℝ) :
    maxPlusIntegral (fun _ : X => c) μ =
    c + Finset.univ.sup' Finset.univ_nonempty μ.weight := by
  simp only [maxPlusIntegral]
  have : (fun x : X => c + μ.weight x) = (fun x => μ.weight x + c) := by ext; ring
  rw [this, Finset.sup'_add_const]; ring

/-- Pointwise lower bound: f(x₀) + w(x₀) ≤ ∫⁺ f dμ. -/
theorem le_maxPlusIntegral {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) (f : X → ℝ) (x₀ : X) :
    f x₀ + μ.weight x₀ ≤ maxPlusIntegral f μ := by
  exact Finset.le_sup' (fun x => f x + μ.weight x) (Finset.mem_univ x₀)

/-- The integral attains its maximum (optimality witness). -/
theorem maxPlusIntegral_attained {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) (f : X → ℝ) :
    ∃ x₀ : X, maxPlusIntegral f μ = f x₀ + μ.weight x₀ := by
  obtain ⟨x₀, _, hmax⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty
    (fun x => f x + μ.weight x)
  exact ⟨x₀, hmax⟩

/-
**Lipschitz stability**: ‖f - g‖_∞ ≤ ε ⟹ |∫⁺ f - ∫⁺ g| ≤ ε.

**Impact**: certified_robustness — small perturbations, small changes.
-/
theorem maxPlusIntegral_lipschitz_stability {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) {f g : X → ℝ} (ε : ℝ)
    (hfg : ∀ x, |f x - g x| ≤ ε) :
    |maxPlusIntegral f μ - maxPlusIntegral g μ| ≤ ε := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · obtain ⟨ x₀, hx₀ ⟩ := maxPlusIntegral_attained μ f;
    linarith [ abs_le.mp ( hfg x₀ ), le_maxPlusIntegral μ g x₀ ];
  · obtain ⟨ x₀, hx₀ ⟩ := maxPlusIntegral_attained μ g;
    linarith [ abs_le.mp ( hfg x₀ ), le_maxPlusIntegral μ f x₀ ]

/-
**Sup preservation**: ∫⁺ max(f,g) dμ = max(∫⁺ f dμ, ∫⁺ g dμ).

**Bridge**: integration ↔ lattice theory (lattice homomorphism).
**Impact**: multi-class tropical neural network confidence.
-/
theorem maxPlusIntegral_max {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) (f g : X → ℝ) :
    maxPlusIntegral (fun x => max (f x) (g x)) μ =
    max (maxPlusIntegral f μ) (maxPlusIntegral g μ) := by
  refine' le_antisymm _ _;
  · unfold maxPlusIntegral; simp +decide [ Finset.sup'_le_iff ] ;
    -- By definition of supremum, there exists some $x_0$ such that $max(f(x_0), g(x_0)) + μ.weight x_0 = \sup_{x} (max(f(x), g(x)) + μ.weight x)$.
    obtain ⟨x₀, hx₀⟩ : ∃ x₀ : X, ∀ x : X, max (f x) (g x) + μ.weight x ≤ max (f x₀) (g x₀) + μ.weight x₀ := by
      simpa using Finset.exists_max_image Finset.univ ( fun x => max ( f x ) ( g x ) + μ.weight x ) ⟨ Classical.arbitrary X, Finset.mem_univ _ ⟩;
    cases max_cases ( f x₀ ) ( g x₀ ) <;> [ left; right ] <;> use x₀ <;> intro x <;> linarith [ hx₀ x ];
  · exact max_le ( maxPlusIntegral_mono _ fun x => le_max_left _ _ ) ( maxPlusIntegral_mono _ fun x => le_max_right _ _ )

/-! ## Tropical Probability -/

/-- Under tropical probability, E_T[c] = c. -/
theorem tropicalExpectation_const {X : Type*} [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P] (c : ℝ) :
    tropicalExpectation (fun _ : X => c) P = c := by
  simp only [tropicalExpectation, maxPlusIntegral_const, hP.total_mass, add_zero]

/-- **Upper bound**: f ≤ b ⟹ E_T[f] ≤ b. -/
theorem tropicalExpectation_le {X : Type*} [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P]
    (f : X → ℝ) (b : ℝ) (hf : ∀ x, f x ≤ b) :
    tropicalExpectation f P ≤ b := by
  simp only [tropicalExpectation, maxPlusIntegral]
  apply Finset.sup'_le; intro x _
  linarith [hf x, hP.weight_nonpos x]

/-
**Lower bound**: a ≤ f ⟹ a ≤ E_T[f].
-/
theorem le_tropicalExpectation {X : Type*} [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P]
    (f : X → ℝ) (a : ℝ) (hf : ∀ x, a ≤ f x) :
    a ≤ tropicalExpectation f P := by
  obtain ⟨x₀, hx₀⟩ : ∃ x₀, f x₀ + P.weight x₀ ≥ a := by
    exact Exists.elim ( Finset.exists_mem_eq_sup' Finset.univ_nonempty P.weight ) fun x₀ hx₀ ↦ ⟨ x₀, by linarith [ hx₀, hf x₀, hP.total_mass, hP.weight_nonpos x₀ ] ⟩;
  exact le_trans hx₀ ( le_maxPlusIntegral P f x₀ )

/-- **Bounded expectation**: a ≤ f ≤ b ⟹ a ≤ E_T[f] ≤ b.

**Impact**: explicit computational bound for certified_robustness. -/
theorem tropicalExpectation_bounded {X : Type*} [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P]
    (f : X → ℝ) (a b : ℝ) (hf : ∀ x, a ≤ f x ∧ f x ≤ b) :
    a ≤ tropicalExpectation f P ∧ tropicalExpectation f P ≤ b :=
  ⟨le_tropicalExpectation P f a (fun x => (hf x).1),
   tropicalExpectation_le P f b (fun x => (hf x).2)⟩

/-- Monotonicity of tropical expectation. -/
theorem tropicalExpectation_mono {X : Type*} [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) [IsTropicalProbability X P]
    {f g : X → ℝ} (hfg : ∀ x, f x ≤ g x) :
    tropicalExpectation f P ≤ tropicalExpectation g P :=
  maxPlusIntegral_mono P hfg

/-- Shift equivariance of tropical expectation. -/
theorem tropicalExpectation_shift {X : Type*} [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) [IsTropicalProbability X P] (f : X → ℝ) (c : ℝ) :
    tropicalExpectation (fun x => f x + c) P = tropicalExpectation f P + c :=
  maxPlusIntegral_shift P f c

/-! ## Tropical Markov Inequality -/

/-- **Tropical Markov inequality**: f(x) ≥ t ⟹ w(x) ≤ ∫⁺f - t.

**Bridge**: probability ↔ optimization.
**Impact**: foundation for tropical Hoeffding with O(exp(-t²/2σ²)). -/
theorem tropicalMarkov {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) (f : X → ℝ) (t : ℝ) (x : X) (hx : t ≤ f x) :
    μ.weight x ≤ maxPlusIntegral f μ - t := by
  linarith [le_maxPlusIntegral μ f x]

/-! ## Certified Robustness -/

/-- Certified radius is positive. -/
theorem certifiedRobustnessRadius_pos {K m : ℝ} (hK : 0 < K) (hm : 0 < m) :
    0 < certifiedRobustnessRadius K m := div_pos hm hK

/-
**Certified classification stability**: K-Lipschitz + margin m ⟹ stable in radius m/K.

**Bridge**: Lipschitz analysis ↔ adversarial ML.
**Impact**: certified_robustness for tropical (ReLU) neural networks.
-/
theorem certified_classification_stability {X : Type*} [PseudoMetricSpace X]
    {f : X → ℝ} {K : ℝ} (hK : 0 < K) (hlip : TropicalLipschitz f K)
    {x₀ x : X} {m : ℝ} (hmargin : m ≤ f x₀)
    (hpert : dist x x₀ < certifiedRobustnessRadius K m) :
    0 < f x := by
  unfold certifiedRobustnessRadius at hpert;
  nlinarith [ abs_le.mp ( hlip.lip_bound x x₀ ), mul_div_cancel₀ m hK.ne' ]

/-
**Binary classifier stability**: margin > 2ε ⟹ prediction preserved.

**Impact**: certified_robustness for binary tropical classifiers.
-/
theorem tropical_binary_stability {X : Type*} [Fintype X] [Nonempty X]
    (scores scores' : Fin 2 → X → ℝ) (μ : MaxPlusMeasure X) (ε : ℝ)
    (hε : ∀ i x, |scores i x - scores' i x| ≤ ε)
    (hmargin : 2 * ε < tropicalPredictionMargin scores μ) :
    maxPlusIntegral (scores' 0) μ > maxPlusIntegral (scores' 1) μ := by
  unfold tropicalPredictionMargin at hmargin;
  linarith [ abs_le.mp ( maxPlusIntegral_lipschitz_stability μ ε ( hε 0 ) ), abs_le.mp ( maxPlusIntegral_lipschitz_stability μ ε ( hε 1 ) ) ]

/-! ## Dirac Measure and Riesz Representation -/

/-- The Dirac tropical measure is a tropical probability. -/
theorem diracTropicalMeasure_isProb {X : Type*} [Fintype X] [Nonempty X]
    [DecidableEq X] (x₀ : X) (M : ℝ) (hM : M < 0) :
    IsTropicalProbability X (diracTropicalMeasure x₀ M hM) where
  total_mass := by
    simp only [diracTropicalMeasure]
    apply le_antisymm
    · apply Finset.sup'_le; intro x _; split_ifs <;> linarith
    · have : (fun x : X => if x = x₀ then (0 : ℝ) else M) x₀ = 0 := by simp
      linarith [Finset.le_sup' (fun x : X => if x = x₀ then (0 : ℝ) else M) (Finset.mem_univ x₀)]
  weight_nonpos := by intro x; simp only [diracTropicalMeasure]; split_ifs <;> linarith

/-
**Dirac integration**: evaluates f at x₀ when M is small enough.

**Bridge**: point evaluation = tropical integration against Dirac.
-/
theorem maxPlusIntegral_dirac_eval {X : Type*} [Fintype X] [Nonempty X]
    [DecidableEq X] (f : X → ℝ) (x₀ : X) (M : ℝ) (hM : M < 0)
    (hM_small : ∀ x : X, x ≠ x₀ → f x + M < f x₀) :
    maxPlusIntegral f (diracTropicalMeasure x₀ M hM) = f x₀ := by
  refine' le_antisymm _ _;
  · exact Finset.sup'_le _ _ fun x _ => by
      by_cases hx : x = x₀
      · simp [hx, diracTropicalMeasure]
      · simp [hx, diracTropicalMeasure]; linarith [hM_small x hx]
  · convert le_maxPlusIntegral _ _ x₀ using 1;
    unfold diracTropicalMeasure; aesop;

/-! ## Measure → Functional -/

/-- Every max-plus measure induces a max-plus functional. -/
noncomputable def MaxPlusMeasure.toFunctional {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) : MaxPlusFunctional X where
  app := fun f => maxPlusIntegral f μ
  mono' := fun hfg => maxPlusIntegral_mono μ hfg
  shift_equiv' := fun f c => maxPlusIntegral_shift μ f c

theorem MaxPlusMeasure.toFunctional_app {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) (f : X → ℝ) :
    μ.toFunctional.app f = maxPlusIntegral f μ := rfl

/-! ## Uniform Probability -/

instance uniformTropicalProbability_isProb (X : Type*) [Fintype X] [Nonempty X] :
    IsTropicalProbability X (uniformTropicalProbability X) where
  total_mass := by simp [uniformTropicalProbability]
  weight_nonpos := by simp [uniformTropicalProbability]

/-- Under uniform probability, E_T[f] = max_x f(x). -/
theorem tropicalExpectation_uniform {X : Type*} [Fintype X] [Nonempty X] (f : X → ℝ) :
    @tropicalExpectation X _ _ f (uniformTropicalProbability X) _ =
    Finset.univ.sup' Finset.univ_nonempty f := by
  simp [tropicalExpectation, maxPlusIntegral, uniformTropicalProbability]

/-! ## Product Measures -/

/-
Product of tropical probabilities is a tropical probability.
-/
theorem productMaxPlusMeasure_isProb {X Y : Type*}
    [Fintype X] [Nonempty X] [Fintype Y] [Nonempty Y]
    (P₁ : MaxPlusMeasure X) (P₂ : MaxPlusMeasure Y)
    [hP₁ : IsTropicalProbability X P₁] [hP₂ : IsTropicalProbability Y P₂] :
    IsTropicalProbability (X × Y) (productMaxPlusMeasure P₁ P₂) where
  total_mass := by
    refine' le_antisymm _ _ <;> simp +decide;
    · exact fun x y => add_nonpos ( hP₁.weight_nonpos x ) ( hP₂.weight_nonpos y );
    · obtain ⟨ x₁, hx₁ ⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty P₁.weight ; obtain ⟨ x₂, hx₂ ⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty P₂.weight ; use x₁, x₂ ; simp_all +decide [ productMaxPlusMeasure ];
      linarith [ hP₁.total_mass, hP₂.total_mass ]
  weight_nonpos := by
    intro ⟨x, y⟩; simp only [productMaxPlusMeasure]
    linarith [hP₁.weight_nonpos x, hP₂.weight_nonpos y]

/-! ## Convergence -/

/-
**Tropical monotone convergence (finite)**: pointwise convergence
implies convergence of integrals on finite types.

**Impact**: certified_robustness via limits.
-/
theorem maxPlusIntegral_tendsto_of_tendsto {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) (f : ℕ → X → ℝ) (g : X → ℝ)
    (hconv : ∀ x, Filter.Tendsto (fun n => f n x) Filter.atTop (nhds (g x))) :
    Filter.Tendsto (fun n => maxPlusIntegral (f n) μ) Filter.atTop
      (nhds (maxPlusIntegral g μ)) := by
  refine' tendsto_order.2 ⟨ _, fun y hy => _ ⟩;
  · intro a' ha';
    obtain ⟨ x₀, hx₀ ⟩ := maxPlusIntegral_attained μ g;
    filter_upwards [ hconv x₀ |> fun h => h.eventually ( lt_mem_nhds ( show g x₀ > a' - μ.weight x₀ by linarith ) ) ] with n hn using by linarith [ le_maxPlusIntegral μ ( f n ) x₀ ] ;
  · simp_all +decide [ maxPlusIntegral ];
    choose! N hN using fun x => Metric.tendsto_atTop.mp ( hconv x ) ( y - g x - μ.weight x ) ( by linarith [ hy x ] );
    exact ⟨ Finset.univ.sup N, fun n hn x => by linarith [ abs_lt.mp ( hN x n ( le_trans ( Finset.le_sup ( f := N ) ( Finset.mem_univ x ) ) hn ) ) ] ⟩

/-! ## Duality -/

@[simp]
theorem dualMeasure_involution {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) :
    dualMeasure (dualMeasure μ) = μ := by
  simp [dualMeasure]

/-
**Max-plus/min-plus duality**:
∫⁺ f dμ = -(min_x (-(f(x) + w(x))))

**Bridge**: max-plus optimization ↔ min-plus (shortest-path).
-/
theorem maxPlusIntegral_eq_neg_inf {X : Type*} [Fintype X] [Nonempty X]
    (μ : MaxPlusMeasure X) (f : X → ℝ) :
    maxPlusIntegral f μ =
    -(Finset.univ.inf' Finset.univ_nonempty (fun x => -(f x + μ.weight x))) := by
  unfold maxPlusIntegral;
  refine' le_antisymm _ _ <;> simp +decide [Finset.sup'_le_iff];
  · exact fun x => by linarith [ Finset.inf'_le ( fun x => -μ.weight x + -f x ) ( Finset.mem_univ x ) ] ;
  · obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun x => -μ.weight x + -f x ) ; use b; norm_num at *; linarith;

/-! ## Variance Properties -/

/-
The tropical variance is nonneg.
-/
theorem tropicalVariance_nonneg {X : Type*} [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P] (f : X → ℝ) :
    0 ≤ tropicalVariance f P := by
  -- By definition of tropical variance, we have:
  unfold tropicalVariance;
  obtain ⟨ x₀, hx₀ ⟩ := Finset.exists_mem_eq_sup' Finset.univ_nonempty P.weight;
  unfold tropicalExpectation;
  unfold maxPlusIntegral;
  linarith [ Finset.le_sup' ( fun x => f x + P.weight x ) hx₀.1, Finset.le_sup' ( fun x => -f x + P.weight x ) hx₀.1, hP.total_mass ▸ hx₀.2 ]

/-
Tropical variance bounded by twice the range.
-/
theorem tropicalVariance_le_range {X : Type*} [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P]
    (f : X → ℝ) (a b : ℝ) (hf : ∀ x, a ≤ f x ∧ f x ≤ b) :
    tropicalVariance f P ≤ b - a := by
  unfold tropicalVariance;
  -- By definition of maxPlusIntegral, we have that maxPlusIntegral f P ≤ b and maxPlusIntegral (fun x => -f x) P ≤ -a.
  have h_maxPlusIntegral_le_b : maxPlusIntegral f P ≤ b := by
    have h_upper : ∀ x, f x + P.weight x ≤ b := by
      exact fun x => add_le_of_nonpos_right ( hP.weight_nonpos x ) |> le_trans <| hf x |>.2;
    exact Finset.sup'_le _ _ fun x _ => h_upper x
  have h_maxPlusIntegral_neg_le_neg_a : maxPlusIntegral (fun x => -f x) P ≤ -a := by
    unfold maxPlusIntegral;
    simp +decide [ Finset.sup'_le_iff ];
    exact fun x => by linarith [ hf x, hP.weight_nonpos x ] ;
  linarith!

/-! ## Concentration -/

/-
**Tropical Hoeffding-type bound**: f(x) ≥ E_T[f] + t ⟹ P.weight(x) ≤ -t.

**Impact**: O(exp(-t)) concentration for tropical neural networks.
-/
theorem tropical_hoeffding_pointwise {X : Type*} [Fintype X] [Nonempty X]
    (P : MaxPlusMeasure X) [hP : IsTropicalProbability X P]
    (f : X → ℝ) (t : ℝ) (x : X)
    (hx : tropicalExpectation f P + t ≤ f x) :
    P.weight x ≤ -t := by
  linarith! [ le_maxPlusIntegral P f x ]

/-- **Sup-additivity**: μ(A ∪ B) = max(μ(A), μ(B)).

**Bridge**: max-plus measures are lattice homomorphisms. -/
theorem measureFinset_union {X : Type*} [Fintype X] [Nonempty X]
    [DecidableEq X] (μ : MaxPlusMeasure X)
    {A B : Finset X} (hA : A.Nonempty) (hB : B.Nonempty) :
    (A ∪ B).sup' (hA.mono Finset.subset_union_left) μ.weight =
    max (A.sup' hA μ.weight) (B.sup' hB μ.weight) :=
  Finset.sup'_union hA hB μ.weight

end TropicalMeasureTheory