import Mathlib
import Novelty.OptimalTransport.Kantorovich
import Novelty.OptimalTransport.Brenier

/-!
# Bridging Brenier and Kantorovich: the monotone permutation plan is optimal

This file connects the two developments of this directory:

* `Novelty.OptimalTransport.Kantorovich` — the Kantorovich transport polytope and
  cost (`IsTransportPlan`, `transportCost`);
* `Novelty.OptimalTransport.Brenier` — the discrete Brenier theorem
  (`brenier_monotone_optimal`, `quadraticMatchingCost`).

A permutation `σ` induces the **permutation coupling** `permPlan σ`
(`π i j = 1` iff `j = σ i`), a genuine Kantorovich transport plan between the
uniform marginals `(1,…,1)`.  Its transport cost is the matching cost
`∑ i, c i (σ i)`.  Specializing to the quadratic ground cost
`c i j = (x i - y j)^2` and invoking Brenier, we obtain:

* `perm_quadratic_optimal` — among permutation couplings, the identity (monotone)
  coupling minimizes the quadratic Kantorovich transport cost, provided the point
  clouds are sorted the same way.

This is the Kantorovich-side restatement of Brenier's theorem (optimal transport
*map* = monotone map), realized inside the transportation polytope.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Brenier's "monotone matching is optimal" must be
expressible directly as optimality of a *transport plan* (the permutation matrix)
in the Kantorovich polytope.  Experiment (Experimenter): define `permPlan`, show it
is a Kantorovich `IsTransportPlan` for uniform marginals, compute its
`transportCost` as `∑ i, c i (σ i)`, and reduce optimality to
`brenier_monotone_optimal`.  Analysis (Analyst): the column-marginal computation is
exactly where the permutation/bijectivity is used (each target receives mass `1`
from a unique source).  Critique (Critic): optimality is proven only against the
permutation couplings, not the full polytope; closing that gap is Birkhoff–von
Neumann, which is absent from Mathlib and recorded as a future direction.
-- !-- end Lab Notes -- !--
-/

namespace Novelty.OptimalTransport

open scoped BigOperators

variable {n : ℕ}

/-- The permutation coupling: all mass at source `i` is sent to target `σ i`. -/
def permPlan (σ : Equiv.Perm (Fin n)) : Fin n → Fin n → ℝ :=
  fun i j => if j = σ i then 1 else 0

/-- The permutation coupling is a Kantorovich transport plan between uniform
marginals `(1,…,1)`. -/
theorem permPlan_isTransportPlan (σ : Equiv.Perm (Fin n)) :
    IsTransportPlan (fun _ => 1) (fun _ => 1) (permPlan σ) := by
  refine ⟨?_, ?_, ?_⟩
  · intro i j; simp only [permPlan]; split <;> norm_num
  · intro i; simp [permPlan]
  · intro j; simp only [permPlan]
    rw [Finset.sum_eq_single (σ.symm j)]
    · simp
    · intro i _ hi
      rw [if_neg]
      intro hj; exact hi (by rw [hj, σ.symm_apply_apply])
    · simp

/-- The transport cost of a permutation coupling is the matching cost
`∑ i, c i (σ i)`. -/
theorem transportCost_permPlan (c : Fin n → Fin n → ℝ) (σ : Equiv.Perm (Fin n)) :
    transportCost c (permPlan σ) = ∑ i, c i (σ i) := by
  simp [transportCost, permPlan]

/-- **Brenier inside the Kantorovich polytope.** For the quadratic ground cost
`c i j = (x i - y j)^2`, if the source `x` and target `y` are sorted the same way
(`Monovary x y`), then among all permutation couplings the identity (monotone)
coupling minimizes the Kantorovich transport cost. -/
theorem perm_quadratic_optimal (x y : Fin n → ℝ) (h : Monovary x y)
    (σ : Equiv.Perm (Fin n)) :
    transportCost (fun i j => (x i - y j) ^ 2) (permPlan (Equiv.refl _)) ≤
      transportCost (fun i j => (x i - y j) ^ 2) (permPlan σ) := by
  rw [transportCost_permPlan, transportCost_permPlan]
  simpa [quadraticMatchingCost] using brenier_monotone_optimal x y h σ

end Novelty.OptimalTransport