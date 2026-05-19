/-
  # Bellman-Ford Theory for Difference Constraints

  This file develops the theory connecting difference constraint feasibility
  to negative cycles, culminating in a Helly-type theorem for difference
  constraints.

  ## Fully proved results:
  - Telescoping inequality for chains
  - Cycle weight non-negativity (any feasible cycle has non-negative weight)
  - Negative cycle infeasibility
  - Simple cycle length bound (≤ n by pigeonhole)
  - Helly theorem for difference constraints (modulo two foundational lemmas)
-/

import Mathlib
import Tropical.Defs
import Tropical.Convexity
import Tropical.Helly

open Finset TropicalConvexity Set Classical

attribute [local instance] Classical.propDecidable

noncomputable section

namespace TropicalConvexity

/-! ## Walks and cycles -/

/-- Total weight of a constraint list. -/
def walkWeight {n : ℕ} (walk : List (DiffConstraint n)) : ℝ :=
  (walk.map DiffConstraint.weight).sum

/-- Chain property: consecutive constraints link up. -/
def IsChain {n : ℕ} : List (DiffConstraint n) → Prop
  | [] => True
  | [_] => True
  | c₁ :: c₂ :: rest => c₁.tgt = c₂.src ∧ IsChain (c₂ :: rest)

/-- Chain cycle: nonempty chain where last.tgt = head.src. -/
def IsChainCycle {n : ℕ} (walk : List (DiffConstraint n)) : Prop :=
  ∃ (h : walk ≠ []), IsChain walk ∧
    (walk.getLast h).tgt = (walk.head h).src

/-- Source vertices of a walk. -/
def walkSources {n : ℕ} (walk : List (DiffConstraint n)) : List (Fin n) :=
  walk.map DiffConstraint.src

/-- Simple cycle: chain cycle with distinct source vertices. -/
def IsSimpleCycle {n : ℕ} (walk : List (DiffConstraint n)) : Prop :=
  IsChainCycle walk ∧ (walkSources walk).Nodup

/-! ## Core lemmas (fully proved) -/

/-- Telescoping inequality for chains. -/
theorem chain_weight_ge_diff {n : ℕ}
    (walk : List (DiffConstraint n))
    (hchain : IsChain walk)
    (x : Fin n → ℝ)
    (hsat : ∀ c ∈ walk, x ∈ c.toSet) :
    ∀ (h : walk ≠ []),
      x (walk.head h).src - x (walk.getLast h).tgt ≤ walkWeight walk := by
  rcases walk with ( _ | ⟨ c, _ | ⟨ d, l ⟩ ⟩ ) <;> simp_all +decide;
  · simp [walkWeight]; linarith [ hsat.out ];
  · induction' l with l ih generalizing c d <;> unfold walkWeight at * <;>
      simp_all +decide [ IsChain ];
    · unfold DiffConstraint.toSet at hsat;
      linarith [ hsat.1, hsat.2, show x c.src - x c.tgt ≤ c.weight from hsat.1,
                 show x d.src - x d.tgt ≤ d.weight from hsat.2,
                 show x c.tgt = x d.src from congr_arg x hchain ] ;
    · rename_i h; specialize h d l; simp_all +decide [ DiffConstraint.toSet ] ; linarith

/-- Cycle weight non-negativity. -/
theorem cycle_weight_nonneg {n : ℕ}
    (walk : List (DiffConstraint n))
    (hcycle : IsChainCycle walk)
    (x : Fin n → ℝ)
    (hsat : ∀ c ∈ walk, x ∈ c.toSet) :
    0 ≤ walkWeight walk := by
  obtain ⟨hne, hchain, hlast⟩ := hcycle
  have h := chain_weight_ge_diff walk hchain x hsat hne
  rw [hlast] at h; linarith

/-- A negative cycle is infeasible. -/
theorem negCycle_infeasible {n : ℕ}
    (walk : List (DiffConstraint n))
    (hcycle : IsChainCycle walk)
    (hneg : walkWeight walk < 0) :
    ¬ DiffSystem.IsFeasible walk.toFinset := by
  rintro ⟨x, hx⟩
  have := cycle_weight_nonneg walk hcycle x (fun c hc => hx c (List.mem_toFinset.mpr hc))
  linarith

/-- A simple cycle has length ≤ n. -/
theorem simple_cycle_length_le {n : ℕ}
    (walk : List (DiffConstraint n))
    (hsimple : IsSimpleCycle walk) :
    walk.length ≤ n := by
  have hnd : List.Nodup (walk.map DiffConstraint.src) := hsimple.2
  have hcard : (walk.map DiffConstraint.src).toFinset.card ≤ n :=
    le_trans (Finset.card_le_univ _) (by norm_num)
  rwa [List.toFinset_card_of_nodup hnd, List.length_map] at hcard

/-! ## Deep lemmas (graph theory foundations)

The following two lemmas constitute the hard graph-theoretic core of the
Bellman-Ford theorem. They are stated here and used in the main Helly theorem;
their proofs require substantial list manipulation infrastructure.
-/

/-- From any negative cycle, extract a simple negative sub-cycle. -/
theorem extract_simple_negCycle {n : ℕ}
    (walk : List (DiffConstraint n))
    (hcycle : IsChainCycle walk)
    (hneg : walkWeight walk < 0) :
    ∃ walk' : List (DiffConstraint n),
      IsSimpleCycle walk' ∧
      walkWeight walk' < 0 ∧
      (∀ c ∈ walk', c ∈ walk) := by
  sorry

-- Bellman-Ford iteration defined via Finset.inf'
-- (removed explicit definition to avoid elaboration issues)

/-- If no constraints form a negative cycle, the system is feasible.
    Construction: Bellman-Ford iteration converges to a feasible potential. -/
theorem feasible_of_no_negCycle {n : ℕ} [NeZero n]
    (sys : DiffSystem n)
    (hno : ∀ walk : List (DiffConstraint n),
      (∀ c ∈ walk, c ∈ sys) → IsChainCycle walk → 0 ≤ walkWeight walk) :
    sys.IsFeasible := by
  sorry

/-! ## Main Helly theorem for difference constraints -/

/-- **Helly theorem for difference constraints.**
    If every subsystem of size ≤ n is feasible, then the whole system is feasible.

    The proof is complete modulo `extract_simple_negCycle` and
    `feasible_of_no_negCycle` (the two core graph-theoretic lemmas above). -/
theorem helly_diff_constraints_bf
    {n : ℕ} [NeZero n]
    (sys : DiffSystem n)
    (hsmall : ∀ sub : DiffSystem n, sub ⊆ sys → sub.card ≤ n → sub.IsFeasible) :
    sys.IsFeasible := by
  apply feasible_of_no_negCycle
  intro walk hwalksys hcycle
  by_contra hnonneg
  push_neg at hnonneg
  obtain ⟨walk', hsimple, hneg', hsub⟩ := extract_simple_negCycle walk hcycle hnonneg
  have hlen := simple_cycle_length_le walk' hsimple
  have hsubsys : walk'.toFinset ⊆ sys := by
    intro c hc; exact hwalksys c (hsub c (List.mem_toFinset.mp hc))
  have hcard : walk'.toFinset.card ≤ n :=
    le_trans (List.toFinset_card_le walk') hlen
  exact negCycle_infeasible walk' hsimple.1 hneg' (hsmall walk'.toFinset hsubsys hcard)

end TropicalConvexity