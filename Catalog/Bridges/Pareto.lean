/-
  # Pareto Optimality and the Bach-Style Tradeoff

  Theorem 4: When harmonic variety enters with opposite optimization sign,
  strict counterpoint minimizers are no longer globally optimal. Instead,
  the feasible set exhibits Pareto-optimal points balancing low penalty
  against high harmonic diversity.
-/
import Mathlib
import Bridges.TropicalCounterpoint.Defs
import Bridges.TropicalCounterpoint.Penalties

open Finset BigOperators

/-! ## Pareto dominance -/

/-- Melody `v` Pareto-dominates `w` if it is at least as good on both
    objectives (low cost, high variety) and strictly better on at least one. -/
def paretoDominates {n : ℕ} (u : Melody (n + 1))
    (v w : Melody (n + 1)) : Prop :=
  totalCost u v ≤ totalCost u w ∧
  harmonicVariety u w ≤ harmonicVariety u v ∧
  (totalCost u v < totalCost u w ∨ harmonicVariety u w < harmonicVariety u v)

/-- A melody is Pareto-optimal in a set if no other melody in the set dominates it. -/
def paretoOptimal {n : ℕ} (u : Melody (n + 1))
    (S : Finset (Melody (n + 1))) (v : Melody (n + 1)) : Prop :=
  v ∈ S ∧ ∀ w ∈ S, ¬paretoDominates u w v

/-! ## Pareto dominance is irreflexive -/

theorem paretoDominates_irrefl {n : ℕ} (u : Melody (n + 1)) (v : Melody (n + 1)) :
    ¬paretoDominates u v v := by
  -- Since totalCost u v cannot be less than itself, the third condition is false.
  simp [paretoDominates]

/-! ## Pareto-optimal points always exist -/

/-- Every nonempty finite set contains a Pareto-optimal point.
    Proof: pick cost-minimizer, then variety-maximizer among cost-minimizers. -/
theorem exists_pareto_optimal {n : ℕ} (u : Melody (n + 1))
    (S : Finset (Melody (n + 1))) (hS : S.Nonempty) :
    ∃ v ∈ S, paretoOptimal u S v := by
  obtain ⟨v_min, hv_min_mem, hv_min⟩ := Finset.exists_min_image S (totalCost u ·) hS
  have hfilter : (S.filter (fun w => totalCost u w = totalCost u v_min)).Nonempty :=
    ⟨v_min, Finset.mem_filter.mpr ⟨hv_min_mem, rfl⟩⟩
  obtain ⟨v, hv_mem', hv_var⟩ := Finset.exists_max_image
    (S.filter (fun w => totalCost u w = totalCost u v_min))
    (harmonicVariety u ·) hfilter
  rw [Finset.mem_filter] at hv_mem'
  refine ⟨v, hv_mem'.1, hv_mem'.1, fun w hw hdom => ?_⟩
  have hcost_w := hv_min w hw
  have hcost_eq : totalCost u w = totalCost u v_min :=
    le_antisymm (by linarith [hdom.1, hv_mem'.2]) hcost_w
  have hw_filter : w ∈ S.filter (fun w => totalCost u w = totalCost u v_min) :=
    Finset.mem_filter.mpr ⟨hw, hcost_eq⟩
  have hvar_w := hv_var w hw_filter
  rcases hdom.2.2 with hlt | hlt
  · linarith [hv_mem'.2]
  · linarith

/-! ## Every point is dominated by or equal to a Pareto-optimal point -/

/-
Every point in S is either Pareto-optimal or weakly dominated by
    some Pareto-optimal point (i.e., there exists a Pareto-optimal point
    with cost ≤ and variety ≥).
-/
theorem exists_pareto_dominating {n : ℕ} (u : Melody (n + 1))
    (S : Finset (Melody (n + 1))) (v : Melody (n + 1)) (hv : v ∈ S) :
    ∃ w ∈ S, paretoOptimal u S w ∧
      totalCost u w ≤ totalCost u v ∧
      harmonicVariety u v ≤ harmonicVariety u w := by
  -- Define the set T of elements in S that are at least as good as v.
  set T := S.filter (fun w => totalCost u w ≤ totalCost u v ∧ harmonicVariety u v ≤ harmonicVariety u w) with hT_def;
  -- T is nonempty (contains v). By exists_pareto_optimal, T has a Pareto-optimal point w' in T with cost ≤ cost v and variety ≥ variety v.
  obtain ⟨w', hw'_in_T, hw'_pareto⟩ : ∃ w' ∈ T, paretoOptimal u T w' := by
    apply exists_pareto_optimal;
    exact ⟨ v, Finset.mem_filter.mpr ⟨ hv, le_rfl, le_rfl ⟩ ⟩;
  refine' ⟨ w', Finset.mem_filter.mp hw'_in_T |>.1, _, Finset.mem_filter.mp hw'_in_T |>.2 ⟩;
  refine' ⟨ Finset.mem_filter.mp hw'_in_T |>.1, fun w hw hw' => _ ⟩;
  exact hw'_pareto.2 w ( Finset.mem_filter.mpr ⟨ hw, by linarith [ hw'.1, Finset.mem_filter.mp hw'_in_T |>.2.1 ], by linarith [ hw'.2.1, Finset.mem_filter.mp hw'_in_T |>.2.2 ] ⟩ ) hw'

/-! ## Pareto incomparability -/

/-- If one melody has zero cost and another has positive cost but higher variety,
    neither Pareto-dominates the other. -/
theorem pareto_incomparable_of_variety_gain {n : ℕ}
    (u : Melody (n + 1))
    (v_strict v_rich : Melody (n + 1))
    (hstrict : FirstSpeciesLegal u v_strict)
    (_hcost : 0 < totalCost u v_rich)
    (hvariety : harmonicVariety u v_strict < harmonicVariety u v_rich) :
    ¬paretoDominates u v_strict v_rich ∧ ¬paretoDominates u v_rich v_strict := by
  unfold paretoDominates
  rw [firstSpecies_iff_zeroCost] at hstrict; aesop

/-! ## Main Pareto tradeoff theorem -/

/-
**Theorem 4 (Pareto Tradeoff)**: If the feasible set contains both a
    legal (zero-cost) melody and a melody with strictly higher variety
    but positive cost, then there exist at least two Pareto-optimal
    points with different characteristics: one with zero cost, and one
    with strictly higher variety than the legal melody.

    This formalizes the "Bach chorales as saddle points" principle:
    richer harmonic configurations are not global cost minima but
    occupy Pareto-optimal positions balancing penalty against diversity.
-/
theorem exists_two_pareto_points {n : ℕ}
    (u : Melody (n + 1))
    (S : Finset (Melody (n + 1)))
    (_hS : S.Nonempty)
    (v_strict : Melody (n + 1))
    (hv_strict_mem : v_strict ∈ S)
    (hstrict : FirstSpeciesLegal u v_strict)
    (v_rich : Melody (n + 1))
    (hv_rich_mem : v_rich ∈ S)
    (_hcost : 0 < totalCost u v_rich)
    (hvariety : harmonicVariety u v_strict < harmonicVariety u v_rich) :
    -- Part 1: there exists a Pareto-optimal zero-cost melody
    (∃ w₁ ∈ S, paretoOptimal u S w₁ ∧ totalCost u w₁ = 0) ∧
    -- Part 2: there exists a Pareto-optimal melody with higher variety
    (∃ w₂ ∈ S, paretoOptimal u S w₂ ∧
      harmonicVariety u v_strict < harmonicVariety u w₂) := by
  constructor;
  · -- By definition of Pareto optimality, there exists a Pareto-optimal point w₁ in S such that totalCost u w₁ ≤ totalCost u v_strict.
    obtain ⟨w₁, hw₁_mem, hw₁_pareto, hw₁_cost⟩ : ∃ w₁ ∈ S, paretoOptimal u S w₁ ∧ totalCost u w₁ ≤ totalCost u v_strict := by
      exact Exists.elim ( exists_pareto_dominating u S v_strict hv_strict_mem ) fun w₁ hw₁ => ⟨ w₁, hw₁.1, hw₁.2.1, hw₁.2.2.1 ⟩;
    exact ⟨ w₁, hw₁_mem, hw₁_pareto, le_antisymm ( hw₁_cost.trans ( by rw [ firstSpecies_iff_zeroCost ] at hstrict; aesop ) ) ( totalCost_nonneg u w₁ ) ⟩;
  · have := exists_pareto_dominating u S v_rich hv_rich_mem;
    exact ⟨ this.choose, this.choose_spec.1, this.choose_spec.2.1, lt_of_lt_of_le hvariety this.choose_spec.2.2.2 ⟩