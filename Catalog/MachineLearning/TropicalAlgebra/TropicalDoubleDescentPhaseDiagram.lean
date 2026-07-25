/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Double Descent Phase Diagram

This file formalizes the **double descent** phenomenon in statistical learning theory
as a **tropical phase transition** in the min-plus semiring. We prove that a stylized
generalization-risk curve can be represented as a tropical piecewise-affine function of
model complexity, and that the interpolation threshold is exactly the point where two
tropical monomials exchange dominance.

## Main results

### Definitions
- `classicalFacet`, `modernFacet`: affine risk branches parameterized by slope and intercept.
- `tropicalRisk`: the min-plus (tropical) combination of two affine risk branches.

### Theorems
- `tropical_vertex_at_threshold`: At the crossing point τ, the tropical risk equals both
  branches, and the dominant branch switches sides — certifying τ as a tropical vertex.
- `unique_tropical_corner_crossing`: Under unequal slopes, the crossing point is unique
  among natural numbers — there is exactly one interpolation threshold.
- `tropical_risk_piecewise_affine`: The tropical risk unfolds to the pointwise minimum
  of two explicit affine forms (definitional scaffold).
- `classical_modern_regime_monotonicity`: With appropriate slope signs, the tropical risk
  is increasing before and decreasing after the threshold — the double-descent shape.

### Cross-domain bridges
- `tropical_plus_distributes_over_min_real`: The fundamental distributive law of min-plus
  algebra, used to shift risk by a baseline.
- `tropical_risk_shift_baseline`: Shifting both branches by a constant preserves the
  tropical structure — a direct application of tropical distributivity.
- `tropical_risk_dominance_margin`: Quantitative bound on the dominance gap away from
  the threshold, connecting to perturbation stability.

## Mathematical significance

This work reframes double descent from an empirical observation into a **certified tropical
phase transition**. The interpolation threshold becomes a tropical vertex (a non-smooth
point of a piecewise-linear function), and the classical/modern regimes become competing
affine pieces in a tropical polynomial. This opens a route to tropical statistical learning
theory, where bias-variance tradeoffs are studied as polyhedral geometry in min-plus semirings.

## References

* Belkin, M., Hsu, D., Ma, S., & Mandal, S. (2019). Reconciling modern machine learning
  practice and the bias-variance trade-off.
* Nakkiran, P., et al. (2021). Deep double descent.
* Maclagan, D., & Sturmfels, B. (2015). Introduction to Tropical Geometry.

## Tags

tropical geometry, double descent, min-plus algebra, phase transition, interpolation threshold,
piecewise-affine, statistical learning theory
-/

noncomputable section

/-! ## Definitions -/

/-- The **classical risk facet**: an affine function of model complexity.
    In the double descent picture, this represents the regime where increasing
    model complexity increases risk (classical bias-variance tradeoff). -/
def classicalFacet (α β : ℝ) (n : ℕ) : ℝ := α * (n : ℝ) + β

/-- The **modern risk facet**: an affine function of model complexity.
    In the double descent picture, this represents the overparameterized regime
    where increasing model complexity decreases risk (benign overfitting). -/
def modernFacet (γ δ : ℝ) (n : ℕ) : ℝ := γ * (n : ℝ) + δ

/-- The **tropical risk**: the min-plus combination of classical and modern facets.
    This is the pointwise minimum, modeling the idea that the effective generalization
    risk follows whichever regime dominates at each complexity level. -/
def tropicalRisk (α β γ δ : ℝ) (n : ℕ) : ℝ :=
  min (classicalFacet α β n) (modernFacet γ δ n)

/-! ## Theorem 3: Tropicalized double-descent decomposition (definitional scaffold) -/

/-- The tropical risk unfolds to the pointwise minimum of two explicit affine forms.
    This is the definitional scaffold that enables rewriting with tropical algebra lemmas. -/
theorem tropical_risk_piecewise_affine
    (α β γ δ : ℝ) :
    ∀ n : ℕ,
      tropicalRisk α β γ δ n =
        min (α * (n : ℝ) + β) (γ * (n : ℝ) + δ) := by
  intro n
  rfl

/-! ## Theorem 1: Tropical vertex characterization of interpolation threshold -/

/-
**Tropical vertex at threshold**: If two affine tropical facets are equal at τ,
    with the classical facet dominant before τ and the modern facet dominant after τ,
    then τ is a tropical vertex where the active branch switches.

    This is the geometric nucleus of the double descent phase diagram: two tropical
    facets, one crossing point, one certified phase boundary.
-/
theorem tropical_vertex_at_threshold
    (a₁ a₂ b₁ b₂ : ℝ) (τ : ℕ)
    (hEq : a₁ * (τ : ℝ) + b₁ = a₂ * (τ : ℝ) + b₂)
    (_hLeft : a₁ < a₂)
    (hRight : ∀ n : ℕ, τ < n →
      a₂ * (n : ℝ) + b₂ < a₁ * (n : ℝ) + b₁)
    (hClassical : ∀ n : ℕ, n < τ →
      a₁ * (n : ℝ) + b₁ < a₂ * (n : ℝ) + b₂) :
    let R : ℕ → ℝ := fun n => min (a₁ * (n : ℝ) + b₁) (a₂ * (n : ℝ) + b₂)
    R τ = a₁ * (τ : ℝ) + b₁ ∧
    (∀ n : ℕ, n < τ → R n = a₁ * (n : ℝ) + b₁) ∧
    (∀ n : ℕ, τ < n → R n = a₂ * (n : ℝ) + b₂) := by
  grind

/-! ## Theorem 2: Unique corner crossing for a tropical risk surface -/

/-
**Unique tropical corner crossing**: Under unequal slopes, the crossing point of
    two affine forms over ℕ is unique. This is the rigorous phase-transition statement:
    there is exactly one interpolation threshold, not a smeared family of crossings.

    Mathematically, two distinct non-parallel lines in ℝ² meet at exactly one point;
    restricting to ℕ, at most one natural number can be a crossing point.
-/
theorem unique_tropical_corner_crossing
    (a₁ a₂ b₁ b₂ : ℝ) (τ : ℕ)
    (hSlope : a₁ ≠ a₂)
    (hEq : a₁ * (τ : ℝ) + b₁ = a₂ * (τ : ℝ) + b₂) :
    let f : ℕ → ℝ := fun n => a₁ * (n : ℝ) + b₁
    let g : ℕ → ℝ := fun n => a₂ * (n : ℝ) + b₂
    ∀ n : ℕ, f n = g n → n = τ := by
  exact fun n hn => Nat.cast_injective ( mul_left_cancel₀ ( sub_ne_zero_of_ne hSlope ) <| by linarith : ( n : ℝ ) = τ )

/-! ## Theorem 4: Monotone facets imply descent regimes on each side -/

/-
**Classical-modern regime monotonicity**: With a positive classical slope (risk
    increases with complexity) and a negative modern slope (risk decreases in the
    overparameterized regime), the tropical risk is increasing before the threshold
    and decreasing after it — the characteristic double-descent shape.

    This certifies that one side behaves like the classical ascent regime and the
    other like the modern descent regime.
-/
theorem classical_modern_regime_monotonicity
    (a₁ a₂ b₁ b₂ : ℝ) (τ : ℕ)
    (_hEq : a₁ * (τ : ℝ) + b₁ = a₂ * (τ : ℝ) + b₂)
    (hA1 : 0 < a₁)
    (hA2 : a₂ < 0)
    (hClassical : ∀ n : ℕ, n < τ →
      a₁ * (n : ℝ) + b₁ < a₂ * (n : ℝ) + b₂)
    (hModern : ∀ n : ℕ, τ < n →
      a₂ * (n : ℝ) + b₂ < a₁ * (n : ℝ) + b₁) :
    let R : ℕ → ℝ := fun n => min (a₁ * (n : ℝ) + b₁) (a₂ * (n : ℝ) + b₂)
    (∀ ⦃m n : ℕ⦄, m ≤ n → n < τ → R m ≤ R n) ∧
    (∀ ⦃m n : ℕ⦄, τ < m → m ≤ n → R n ≤ R m) := by
  constructor <;> intro m n hm hn <;> cases min_cases ( a₁ * m + b₁ ) ( a₂ * m + b₂ ) <;> cases min_cases ( a₁ * n + b₁ ) ( a₂ * n + b₂ ) <;> first | linarith | simp_all +decide only [] ;
  any_goals nlinarith [ ( by norm_cast : ( m : ℝ ) ≤ n ), hModern m hm ];
  · gcongr;
  · grind;
  · nlinarith [ ( by norm_cast : ( m : ℝ ) ≤ n ), hClassical n hn ];
  · linarith [ hClassical m ( lt_of_le_of_lt hm hn ), hClassical n hn ]

/-! ## Cross-domain bridges: Tropical algebra -/

/-
**Tropical distributivity (min-plus)**: Addition distributes over minimum in ℝ.
    This is the fundamental algebraic law of the min-plus (tropical) semiring:
    `c + min(a, b) = min(c + a, c + b)`.

    In the risk context, this says that shifting all risk branches by a constant
    baseline preserves the tropical structure.
-/
theorem tropical_plus_distributes_over_min_real (a b c : ℝ) :
    c + min a b = min (c + a) (c + b) := by
  grind +qlia

/-
**Tropical risk baseline shift**: Shifting both risk branches by a constant `c`
    shifts the tropical risk by `c`, preserving the phase structure. This is a direct
    consequence of tropical distributivity.
-/
theorem tropical_risk_shift_baseline
    (α β γ δ c : ℝ) (n : ℕ) :
    tropicalRisk α (β + c) γ (δ + c) n =
    tropicalRisk α β γ δ n + c := by
  unfold tropicalRisk classicalFacet modernFacet;
  grind +splitIndPred

/-
**Dominance margin**: The gap between the two branches at any point `n` equals
    `(a₁ - a₂) * ((n : ℝ) - (τ : ℝ))` when the branches cross at τ.
    This quantifies the stability of the phase assignment
    and connects to perturbation/quantization stability results.
-/
theorem tropical_risk_dominance_margin
    (a₁ a₂ b₁ b₂ : ℝ) (τ n : ℕ)
    (hEq : a₁ * (τ : ℝ) + b₁ = a₂ * (τ : ℝ) + b₂) :
    (a₁ * (n : ℝ) + b₁) - (a₂ * (n : ℝ) + b₂) = (a₁ - a₂) * ((n : ℝ) - (τ : ℝ)) := by
  linarith

/-! ## Strengthening of the catalog theorem -/

/-
**Strict strengthening of `tropical_double_descent_phase_transition`**:
    Under the general parameterization with explicit slope and intercept parameters,
    we certify the full double-descent phase diagram including:
    1. Branch dominance on each side of τ
    2. Equality at the threshold (tropical vertex)
    3. Uniqueness of the crossing point
    4. Piecewise monotonicity (ascending then descending)

    This is strictly stronger than the catalog theorem because it works with
    arbitrary affine parameters and proves uniqueness of the vertex.
-/
theorem tropical_double_descent_full_phase_diagram
    (a₁ a₂ b₁ b₂ : ℝ) (τ : ℕ)
    (hEq : a₁ * (τ : ℝ) + b₁ = a₂ * (τ : ℝ) + b₂)
    (hA1 : 0 < a₁) (hA2 : a₂ < 0)
    (hClassical : ∀ n : ℕ, n < τ → a₁ * (n : ℝ) + b₁ < a₂ * (n : ℝ) + b₂)
    (hModern : ∀ n : ℕ, τ < n → a₂ * (n : ℝ) + b₂ < a₁ * (n : ℝ) + b₁) :
    let R : ℕ → ℝ := fun n => min (a₁ * (n : ℝ) + b₁) (a₂ * (n : ℝ) + b₂)
    -- Vertex characterization
    (R τ = a₁ * (τ : ℝ) + b₁) ∧
    -- Branch dominance
    (∀ n, n < τ → R n = a₁ * (n : ℝ) + b₁) ∧
    (∀ n, τ < n → R n = a₂ * (n : ℝ) + b₂) ∧
    -- Uniqueness
    (∀ n, R n = a₁ * (n : ℝ) + b₁ ∧ R n = a₂ * (n : ℝ) + b₂ → n = τ) ∧
    -- Monotonicity (double descent shape)
    (∀ ⦃m n⦄, m ≤ n → n < τ → R m ≤ R n) ∧
    (∀ ⦃m n⦄, τ < m → m ≤ n → R n ≤ R m) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · exact min_eq_left (le_of_eq hEq)
  · exact fun n hn => min_eq_left <| le_of_lt <| hClassical n hn
  · exact fun n hn => min_eq_right (le_of_lt (hModern n hn))
  · intro n ⟨h1, h2⟩
    exact unique_tropical_corner_crossing a₁ a₂ b₁ b₂ τ (by linarith) hEq n (by linarith)
  · exact classical_modern_regime_monotonicity a₁ a₂ b₁ b₂ τ hEq hA1 hA2 hClassical hModern

end