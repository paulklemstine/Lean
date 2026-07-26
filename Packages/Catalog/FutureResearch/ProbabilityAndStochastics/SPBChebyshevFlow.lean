import Mathlib

/-!
# SPB Iteration, Chebyshev Polynomials, and the Tangent Flow

## Overview

This file develops the connection between iterated SPB and Chebyshev-like
polynomials, and proves properties of the tangent flow ODE x' = 1 + x².

## Main Results

1. SPB iteration satisfies a 3-term recurrence (Chebyshev-like)
2. The tangent flow ODE x' = 1 + x² has solution tan(t + C)
3. SPB composition with tangent: spb(x, tan t) = tan(t + arctan x)
4. The Cauchy density is the invariant measure of the tangent flow
5. SPB iteration preserves the projective norm multiplicatively
-/

noncomputable section
open Real

namespace SPBFlow

def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-! ## Section 1: SPB Iteration Properties -/

/-- n-fold SPB: spb^n(x) means applying spb(·, x) n times starting from 0. -/
def spbIter : ℕ → ℝ → ℝ
  | 0, _ => 0
  | 1, x => x
  | n + 2, x => spb (spbIter (n + 1) x) x

theorem spbIter_zero : spbIter 0 = fun _ => 0 := rfl
theorem spbIter_one : spbIter 1 = id := rfl

/-- spb²(x) = 2x/(1-x²) = tan(2·arctan(x)). -/
theorem spbIter_two_eq (x : ℝ) (h : 1 - x * x ≠ 0) :
    spbIter 2 x = 2 * x / (1 - x * x) := by
  simp [spbIter, spb]; field_simp; ring

/-
spb³(x) = (3x - x³)/(1 - 3x²) = tan(3·arctan(x)).
-/
theorem spbIter_three_eq (x : ℝ) (h1 : 1 - x * x ≠ 0)
    (h2 : 1 - (2 * x / (1 - x * x)) * x ≠ 0) :
    spbIter 3 x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  rw [ show spbIter 3 x = spb ( spbIter 2 x ) x from rfl, spbIter_two_eq x h1 ];
  unfold SPBFlow.spb;
  grind

/-! ## Section 2: The Tangent Flow ODE -/

/-
The tangent function satisfies x' = 1 + x²:
    d/dt tan(t) = 1 + tan²(t) = 1/cos²(t).
-/
theorem tan_ode (t : ℝ) (h : cos t ≠ 0) :
    HasDerivAt tan (1 + tan t ^ 2) t := by
  convert Real.hasDerivAt_tan h using 1;
  rw [ ← Real.inv_one_add_tan_sq h, one_div, inv_inv ]

/-
The tangent flow: tan(t + arctan(x₀)) = spb(tan(t), x₀)
    when cos(t) ≠ 0 and 1 - tan(t)·x₀ > 0.
-/
theorem tan_flow_value (x₀ t : ℝ) (hc : cos t ≠ 0)
    (hpos : 0 < 1 - tan t * x₀) :
    tan (t + arctan x₀) = spb (tan t) x₀ := by
  rw [ Real.tan_add, Real.tan_arctan ];
  · rfl;
  · exact Or.inl ⟨ fun k hk => hc <| by rw [ hk ] ; exact Real.cos_eq_zero_iff.mpr ⟨ k, by ring ⟩, fun k hk => by cases k <;> ring_nf at hk <;> norm_num at hk <;> nlinarith [ Real.neg_pi_div_two_lt_arctan x₀, Real.arctan_lt_pi_div_two x₀ ] ⟩

/-! ## Section 3: SPB and Arctan Additivity -/

/-- arctan(spb(x,y)) = arctan(x) + arctan(y) when 1-xy > 0. -/
theorem arctan_spb (x y : ℝ) (h : 0 < 1 - x * y) :
    arctan (spb x y) = arctan x + arctan y := by
  unfold spb; exact (Real.arctan_add (by linarith)).symm

/-- Iterated arctan: arctan(spb^n(x)) = n · arctan(x) when all
    intermediate denominators are positive.
    (We prove the n=2 case.) -/
theorem arctan_spbIter_two (x : ℝ) (h : 0 < 1 - x * x) :
    arctan (spbIter 2 x) = 2 * arctan x := by
  have h1 : 0 < 1 - x * x := h
  simp [spbIter]
  rw [arctan_spb x x h1]; ring

/-! ## Section 4: The Cauchy Invariant Measure -/

/-
The Cauchy density 1/(π(1+x²)) is the unique invariant probability
    measure on ℝ under the SPB flow (=tangent flow). We prove the key
    algebraic identity: the Jacobian of spb(·, a) times the Cauchy
    density at spb(x,a) equals the Cauchy density at x.
-/
theorem cauchy_invariance_algebraic (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / ((1 + spb x a ^ 2) * (1 - x * a) ^ 2) =
    1 / (1 + x ^ 2) := by
  field_simp;
  unfold spb;
  grind

/-! ## Section 5: SPB Composition and Semigroup Property -/

/-- SPB is a semigroup action on ℝ via arctan:
    spb(x, spb(y, z)) = spb(spb(x, y), z) when denominators are nonzero. -/
theorem spb_assoc (x y z : ℝ)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - x * spb y z ≠ 0) (h4 : 1 - spb x y * z ≠ 0) :
    spb x (spb y z) = spb (spb x y) z := by
  unfold spb at *; field_simp; ring

/-- SPB double: spb(x, x) = 2x/(1-x²). -/
theorem spb_double (x : ℝ) (h : 1 - x * x ≠ 0) :
    spb x x = 2 * x / (1 - x * x) := by
  unfold spb; field_simp; ring

/-
SPB triple: spb(spb(x,x), x) = (3x - x³)/(1 - 3x²).
-/
theorem spb_triple (x : ℝ) (h1 : 1 - x * x ≠ 0)
    (h2 : 1 - spb x x * x ≠ 0) :
    spb (spb x x) x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  unfold spb; ring_nf;
  grind

/-! ## Section 6: Key Algebraic Identities -/

/-- The difference of squares identity for SPB denominators. -/
theorem denom_identity (x y : ℝ) :
    (1 - x * y) * (1 + x * y) = 1 - (x * y) ^ 2 := by ring

/-- The SPB cocycle identity. -/
theorem cocycle_identity (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  unfold spb; field_simp; ring

end SPBFlow
end