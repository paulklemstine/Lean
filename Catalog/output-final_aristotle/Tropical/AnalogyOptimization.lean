/-
Copyright (c) 2025. All rights reserved.

# Making a Good Analogy as a Tropical Optimization Problem

"Can we formalize *making a good analogy* as an optimization problem?"  Yes: a
pool of candidate analogies each carries a *cost* (its distortion), and the best
analogy is the one of minimum cost.  Minimisation over a finite pool is exactly
addition in the **tropical (min-plus) semiring**: the tropical sum of the
candidate scores equals the optimal (minimal) cost.  This file makes that
identification precise.

## Main results

* `best_analogy_attained`      — the optimum over a nonempty finite pool exists.
* `tropicalScore_eq_inf`       — the tropical sum of candidate scores is their infimum.
* `tropicalScore_le`           — the tropical optimum lower-bounds every candidate.
* `tropicalScore_attained`     — the tropical optimum is achieved by some candidate.
* `tropicalScore_isBest`       — **the tropical sum is the best analogy's cost**:
  it is achieved and it lower-bounds all candidates.
-/
import Mathlib

namespace TropicalAnalogy

open scoped Tropical
open Finset

variable {ι : Type*}

/-
**The optimization has a solution.**  Over a nonempty finite pool of
candidate analogies with real costs, there is a candidate whose cost is minimal
— the best analogy.
-/
theorem best_analogy_attained (s : Finset ι) (cost : ι → ℝ) (hs : s.Nonempty) :
    ∃ i ∈ s, ∀ j ∈ s, cost i ≤ cost j := by
  exact Finset.exists_min_image _ _ hs

/-- The **tropical score** of a pool of candidate analogies: aggregate the
per-candidate costs using tropical addition (which is `min`).  Costs live in
`WithTop ℝ`, with `⊤` modelling an infeasible candidate. -/
noncomputable def tropicalScore (s : Finset ι) (cost : ι → WithTop ℝ) :
    Tropical (WithTop ℝ) :=
  ∑ i ∈ s, Tropical.trop (cost i)

/-
The tropical score equals the infimum of the candidate costs: aggregating
by tropical addition literally computes the minimum.
-/
theorem tropicalScore_eq_inf (s : Finset ι) (cost : ι → WithTop ℝ) :
    Tropical.untrop (tropicalScore s cost) = s.inf cost := by
  convert Finset.untrop_sum' s ( fun i => Tropical.trop ( cost i ) )

/-
The tropical optimum is a lower bound on every candidate's cost.
-/
theorem tropicalScore_le (s : Finset ι) (cost : ι → WithTop ℝ)
    {j : ι} (hj : j ∈ s) :
    Tropical.untrop (tropicalScore s cost) ≤ cost j := by
  convert Finset.inf_le hj;
  convert tropicalScore_eq_inf s cost

/-
Over a nonempty pool, the tropical optimum is actually attained by some
candidate analogy.
-/
theorem tropicalScore_attained (s : Finset ι) (cost : ι → WithTop ℝ)
    (hs : s.Nonempty) :
    ∃ i ∈ s, Tropical.untrop (tropicalScore s cost) = cost i := by
  have h_coe : ∃ i ∈ s, ∀ j ∈ s, s.inf cost = cost i ∧ cost i ≤ cost j := by
    obtain ⟨ i, hi, h ⟩ := Finset.exists_mem_eq_inf' hs cost;
    exact ⟨ i, hi, fun j hj => ⟨ by rw [ Finset.inf'_eq_inf ] at h; aesop, h ▸ Finset.inf'_le _ hj ⟩ ⟩;
  exact h_coe.imp fun x hx => ⟨ hx.1, tropicalScore_eq_inf s cost ▸ hx.2 _ hx.1 |>.1 ⟩

/-
**The tropical sum is exactly the best analogy's cost.**  Over a nonempty
finite pool, the tropical score is achieved by some candidate and lower-bounds
all candidates — so "making the best analogy" is solved by a single tropical
sum.
-/
theorem tropicalScore_isBest (s : Finset ι) (cost : ι → WithTop ℝ)
    (hs : s.Nonempty) :
    (∃ i ∈ s, Tropical.untrop (tropicalScore s cost) = cost i) ∧
      (∀ j ∈ s, Tropical.untrop (tropicalScore s cost) ≤ cost j) := by
  exact ⟨ tropicalScore_attained s cost hs, fun j hj => tropicalScore_le s cost hj ⟩

end TropicalAnalogy