import Mathlib

/-!
# Discrete Brenier theorem for quadratic cost

Brenier's theorem states that for the quadratic cost the optimal transport map is
the gradient of a convex function — in dimension one, a *monotone* map.  We prove
the finite/discrete avatar of this fact: among all permutation couplings of two
finite point clouds `x, y : Fin n → ℝ`, the quadratic transport cost
`∑ i, (x i - y (σ i))^2` is minimized by the **monotone** matching `σ = id`,
provided `x` and `y` are sorted the same way (`Monovary x y`).

The proof reduces, after expanding the square and using that permutations preserve
`∑ (y ·)^2`, to the rearrangement inequality: a monovarying pair maximizes its
correlation `∑ x i * y i` over all permutations.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Brenier's "optimal map is monotone" should, in the
finite quadratic case, be exactly the rearrangement inequality in disguise.
Experiment (Experimenter): expand `(x i - y (σ i))^2 = x i^2 - 2 x i y(σ i) +
y(σ i)^2`; reindex `∑ y(σ i)^2 = ∑ y i^2` by the permutation; the cost difference
collapses to `2 (∑ x i y i - ∑ x i y(σ i)) ≥ 0`, which is rearrangement.
Analysis (Analyst): the monotonicity hypothesis enters only through `Monovary x y`;
without it the monotone matching need not be optimal (counterexample: `x` increasing,
`y` decreasing — then the *reversing* permutation is optimal), confirming the
hypothesis is load-bearing rather than decorative.
Critique (Critic): we phrase optimality over permutations, the discrete analogue of
optimal *maps*; lifting to all couplings would require Birkhoff–von Neumann, which
is absent from Mathlib and left to future work.
-- !-- end Lab Notes -- !--
-/

namespace Novelty.OptimalTransport

open scoped BigOperators

variable {n : ℕ}

/-- Quadratic transport cost of matching `x i` to `y (σ i)`. -/
def quadraticMatchingCost (x y : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) : ℝ :=
  ∑ i, (x i - y (σ i)) ^ 2

/-
**Discrete Brenier theorem (quadratic cost).** If the source points `x` and the
target points `y` are sorted the same way (`Monovary x y`), then the monotone
matching `σ = id` minimizes the quadratic transport cost among all permutation
couplings.
-/
theorem brenier_monotone_optimal (x y : Fin n → ℝ) (h : Monovary x y)
    (σ : Equiv.Perm (Fin n)) :
    quadraticMatchingCost x y (Equiv.refl _) ≤ quadraticMatchingCost x y σ := by
  unfold quadraticMatchingCost;
  -- Expand the squares and simplify the expression.
  suffices h_suff : ∑ i, x i * y i ≥ ∑ i, x i * y (σ i) by
    simp_all +decide [ sub_sq, Finset.sum_add_distrib, mul_assoc ];
    simpa [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, Equiv.sum_comp σ fun i => y i ^ 2 ] using by linarith;
  simpa [smul_eq_mul] using h.sum_smul_comp_perm_le_sum_smul (σ := σ)

/-- Reformulation: the identity matching realizes the minimal quadratic cost over
all permutations, i.e. it is a global minimizer. -/
theorem brenier_isMinOn (x y : Fin n → ℝ) (h : Monovary x y) :
    ∀ σ : Equiv.Perm (Fin n),
      quadraticMatchingCost x y (Equiv.refl _) ≤ quadraticMatchingCost x y σ :=
  fun σ => brenier_monotone_optimal x y h σ

end Novelty.OptimalTransport