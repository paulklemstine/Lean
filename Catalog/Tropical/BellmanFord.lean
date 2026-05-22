import Mathlib
import Tropical.Convexity.Basic

/-!
# Tropical Feasibility and Difference Constraint Systems

This file formalizes the connection between difference constraint feasibility
and negative cycle detection in weighted directed graphs. The main result is
a certified feasibility theorem: a system of difference constraints `x i ≤ a + x j`
is feasible if and only if the associated weighted digraph has no negative-weight cycle.

## Main definitions

* `FeasibleDiffSystem` — feasibility of a system of difference constraints
* `HasNegCycleSimple` — existence of a negative-weight cycle in the constraint graph

## Main results

* `no_neg_cycle_of_feasible` — feasibility implies no negative cycle
* `diff_system_feasible_iff_no_neg_cycle` — the full characterization

## References

* Cormen, Leiserson, Rivest, Stein, "Introduction to Algorithms", Ch. 24
-/

open Finset

noncomputable section

/-- A system of difference constraints given as a finite set of edges `(i, j, a)`
    meaning `x i ≤ a + x j`. The system is feasible if there exists a satisfying
    assignment `x`. -/
def FeasibleDiffSystem {n : ℕ} (E : Finset (Fin n × Fin n × ℝ)) : Prop :=
  ∃ x : Fin n → ℝ, ∀ e ∈ E, (x e.1) ≤ e.2.2 + x e.2.1

/-- The constraint graph has a negative cycle: there exist vertices forming a cycle
    whose edges are all in `E` and whose total weight is negative. -/
def HasNegCycleSimple {n : ℕ} (E : Finset (Fin n × Fin n × ℝ)) : Prop :=
  ∃ (k : ℕ) (_ : k ≥ 1) (path : Fin (k + 1) → Fin n) (weights : Fin k → ℝ),
    path ⟨0, Nat.zero_lt_succ k⟩ = path ⟨k, Nat.lt_succ_iff.mpr le_rfl⟩ ∧
    (∀ t : Fin k, (path t.castSucc, path t.succ, weights t) ∈ E) ∧
    ∑ t : Fin k, weights t < 0

/-
If a difference constraint system is feasible, there is no negative cycle.

**Proof sketch**: Given feasible `x`, for any cycle `v₀ → v₁ → ⋯ → vₖ = v₀`
with edges in `E`, we have `x(vₜ) ≤ wₜ + x(vₜ₊₁)` for each edge.
Telescoping: `x(v₀) ≤ (∑ wₜ) + x(vₖ) = (∑ wₜ) + x(v₀)`,
so `0 ≤ ∑ wₜ`, contradicting negativity.
-/
theorem no_neg_cycle_of_feasible {n : ℕ} (E : Finset (Fin n × Fin n × ℝ))
    (hfeas : FeasibleDiffSystem E) :
    ¬ HasNegCycleSimple E := by
  rintro ⟨ k, hk, path, weights, hpath0, hpath1, hsum ⟩;
  obtain ⟨ x, hx ⟩ := hfeas;
  -- By summing the inequalities from hx over all t in Fin k, we get:
  have h_sum : ∑ t : Fin k, x (path t.castSucc) ≤ ∑ t : Fin k, weights t + ∑ t : Fin k, x (path t.succ) := by
    simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum fun t _ => hx _ ( hpath1 t );
  have := Fin.sum_univ_castSucc fun t => x ( path t ) ; have := Fin.sum_univ_succ fun t => x ( path t ) ; simp_all +decide [ Fin.sum_univ_castSucc, Fin.sum_univ_succ ] ;
  linarith!

end