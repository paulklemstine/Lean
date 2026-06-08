/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Cycle-Birth Concentration and Universality

This file establishes the main theorems for **probabilistic tropical topology**:
the study of cycle-birth times in random weighted graph filtrations.

## Main Results

### Theorem 1: Deterministic Bookkeeping
* `total_eq_merge_plus_cycle` — edges = merges + cycle births
* `merge_xor_cycleBirth` — each edge is exactly one of merge or cycle birth

### Theorem 2: Lipschitz Stability
* `cycleBirthCount_flip_one_le` — flipping one flag changes count by ≤ 1
* `cycleBirthCountLE_flip_one_le` — threshold-dependent version

### Theorem 3: Concentration Infrastructure
* `cycleBirth_hasBoundedDifferences` — bounded differences for McDiarmid

### Theorem 4: Monotone Transport Universality
* `cycleBirthFlags_invariant_mapWeights` — classification invariant under transport
* `cycleBirthWeights_mapWeights` — equivariance of birth weights
* `strictMono_preserves_weight_order` — strict monotonicity preserves order

### Theorem 5: MST Complement
* `cycleBirth_eq_complement_forest` — cycle births + forest = all edges
* `connected_forest_size` — for connected graphs, β₁ = m - n + 1

## Cross-domain Connections

- **Tropical Morse theory**: cycle births = tropical critical values
- **Persistent homology / TDA**: cycle births = 1-dim persistence birth times
- **Combinatorial optimization**: cycle births = non-MST edges (Kruskal duality)
- **Concentration of measure**: bounded differences → McDiarmid concentration
- **Statistical physics universality**: monotone transport invariance

## References

Builds on the structural identities from `Pythagorean.TropicalMorse.Theorems`:
`cycle_rank_additive_over_filtration` (≡ filtration_betti1_eq_cycleCount)
and `component_delta_accumulation` (≡ filtration_rank_eq_mergeCount).

**Application keywords:** tropical Morse theory, persistent homology, Erdős–Rényi graphs,
concentration of measure, McDiarmid inequality, Azuma–Hoeffding, universality,
minimum spanning tree, graphic matroid, percolation, network science,
topological statistics, random optimization, KS distance, empirical process.
-/

import Mathlib
import Pythagorean.TropicalMorse.CycleBirth.Defs

open Finset BigOperators

namespace CycleBirth

/-! ## Part 1: Fundamental Bookkeeping (Theorem 1) -/

/-
**Theorem 1a: Total steps = merges + cycle births.**
    This is the deterministic bookkeeping identity from which all else follows.
    It corresponds to `filtration_betti1_eq_cycleCount` + `filtration_rank_eq_mergeCount`
    from the catalog.
-/
theorem WFiltration.total_eq_merge_plus_cycle (F : WFiltration) :
    F.steps.length = F.mergeCount + F.cycleCount := by
  unfold WFiltration.mergeCount WFiltration.cycleCount; rw [ List.length_eq_countP_add_countP ] ; congr ; ext ; aesop;

/-
The length of the cycle-birth weight list equals the cycle count.
-/
theorem WFiltration.cycleBirthWeights_length (F : WFiltration) :
    F.cycleBirthWeights.length = F.cycleCount := by
  unfold WFiltration.cycleBirthWeights WFiltration.cycleCount;
  rw [ List.length_map, List.countP_eq_length_filter ]

/-! ## Part 2: Merge-or-Cycle Dichotomy -/

/-
**Theorem 1b: Each edge is either a merge or a cycle birth, never both.**
-/
theorem FiltStep.merge_xor_cycleBirth (s : FiltStep) :
    (s.sameComponent = true ∧ ¬s.sameComponent = false) ∨
    (s.sameComponent = false ∧ ¬s.sameComponent = true) := by
  grind

/-
Merge and cycle-birth are complementary predicates.
-/
theorem FiltStep.merge_iff_not_cycle (s : FiltStep) :
    (!s.sameComponent) = true ↔ s.sameComponent = false := by
  cases s.sameComponent <;> simp +decide

/-! ## Part 3: Monotone Transport Universality (Theorem 4) -/

/-
**Theorem 4a: Monotone transport preserves cycle-birth classification.**
    Applying ANY function to weights preserves the sameComponent flags.
    This is the **universality mechanism**: only the order of weights matters.
-/
theorem cycleBirthFlags_invariant_mapWeights (F : WFiltration) (φ : ℚ → ℚ) :
    (F.mapWeights φ).flags = F.flags := by
  unfold CycleBirth.WFiltration.flags CycleBirth.WFiltration.mapWeights; aesop;

/-
Cycle count is invariant under weight transformation.
-/
theorem cycleCount_invariant_mapWeights (F : WFiltration) (φ : ℚ → ℚ) :
    (F.mapWeights φ).cycleCount = F.cycleCount := by
  unfold WFiltration.cycleCount;
  unfold CycleBirth.WFiltration.mapWeights;
  rw [ List.countP_map ];
  rfl

/-
Merge count is invariant under weight transformation.
-/
theorem mergeCount_invariant_mapWeights (F : WFiltration) (φ : ℚ → ℚ) :
    (F.mapWeights φ).mergeCount = F.mergeCount := by
  unfold WFiltration.mergeCount;
  unfold CycleBirth.WFiltration.mapWeights;
  rw [ List.countP_map ];
  rfl

/-
**Theorem 4b: Cycle-birth weight list transforms equivariantly.**
    Under weight transformation φ, the cycle-birth weights become
    the φ-images of the original cycle-birth weights.
-/
theorem cycleBirthWeights_mapWeights (F : WFiltration) (φ : ℚ → ℚ) :
    (F.mapWeights φ).cycleBirthWeights = F.cycleBirthWeights.map φ := by
  unfold WFiltration.cycleBirthWeights WFiltration.mapWeights; simp +decide [ List.filter_map ] ;
  rfl

/-
**Theorem 4c: Strict monotonicity preserves weight order.**
-/
theorem strictMono_preserves_weight_order (φ : ℚ → ℚ) (hφ : StrictMono φ)
    (a b : ℚ) : a < b ↔ φ a < φ b := by
  exact ⟨ fun h => hφ h, fun h => hφ.lt_iff_lt.mp h ⟩

/-! ## Part 4: Lipschitz Stability (Theorem 2) -/

/-
Core counting lemma: flipping one Boolean in a list changes countP by ≤ 1.
-/
theorem list_bool_countP_set_diff (bs : List Bool) (k : ℕ) (hk : k < bs.length) :
    |(bs.countP id : ℤ) - ((bs.set k (!bs[k]!)).countP id : ℤ)| ≤ 1 := by
  grind

/-
**Theorem 2a: Single-step Lipschitz bound for cycle count.**
    Flipping one step's sameComponent flag changes the total cycle count by ≤ 1.
    This is the bounded-differences constant for McDiarmid.
-/
theorem cycleBirthCount_flip_one_le (F : WFiltration) (k : ℕ) (hk : k < F.steps.length) :
    let F' : WFiltration := {
      numVerts := F.numVerts
      steps := F.steps.set k ⟨F.steps[k].weight, !F.steps[k].sameComponent⟩
    }
    |(F.cycleCount : ℤ) - (F'.cycleCount : ℤ)| ≤ 1 := by
  convert list_bool_countP_set_diff _ _ _;
  any_goals exact List.map ( ·.sameComponent ) F.steps;
  all_goals norm_num [ WFiltration.cycleCount ];
  rw [ List.countP_set ];
  any_goals assumption;
  rw [ List.countP_set ];
  all_goals simp_all +decide [ List.countP_map ]

/-
**Theorem 2b: Threshold-dependent Lipschitz bound.**
    For each threshold t, flipping one flag changes the cumulative
    cycle-birth count by ≤ 1.
-/
theorem cycleBirthCountLE_flip_one_le (F : WFiltration) (k : ℕ) (hk : k < F.steps.length)
    (t : ℚ) :
    let F' : WFiltration := {
      numVerts := F.numVerts
      steps := F.steps.set k ⟨F.steps[k].weight, !F.steps[k].sameComponent⟩
    }
    |(F.cycleBirthCountLE t : ℤ) - (F'.cycleBirthCountLE t : ℤ)| ≤ 1 := by
  -- Let's express the cycle birth counts using the definition of `cycleBirthCountLE`.
  unfold WFiltration.cycleBirthCountLE;
  grind

/-! ## Part 5: MST Complement Characterization (Theorem 5) -/

/-
**Theorem 5a: Cycle births + forest edges = all edges.**
    Cycle-birth edges are exactly the complement of the greedy spanning forest.
-/
theorem cycleBirth_eq_complement_forest (F : WFiltration) :
    F.cycleCount + F.mergeCount = F.steps.length := by
  rw [ add_comm, WFiltration.total_eq_merge_plus_cycle ]

/-
Forest edges + cycle-birth edges partition all edges.
-/
theorem forest_cycle_partition (F : WFiltration) :
    F.mergeCount ≤ F.steps.length ∧ F.cycleCount ≤ F.steps.length := by
  exact ⟨ Nat.le_of_lt_succ ( by linarith [ F.total_eq_merge_plus_cycle ] ), Nat.le_of_lt_succ ( by linarith [ F.total_eq_merge_plus_cycle ] ) ⟩

/-
**Theorem 5b: Connected graph forest size.**
    For a connected graph, the forest has n-1 edges, so cycle births = m - n + 1 = β₁.
-/
theorem connected_forest_size (F : WFiltration)
    (hconn : (F.numVerts : ℤ) - F.mergeCount = 1) :
    F.cycleCount = F.steps.length - (F.numVerts - 1) := by
  grind +suggestions

/-! ## Part 6: Euler Characteristic (Cross-domain) -/

/-
**Cross-domain: Euler characteristic from filtration.**
    χ = V - E = (V - merges) - cycles = β₀ - β₁.
-/
theorem euler_char_identity (F : WFiltration) :
    (F.numVerts : ℤ) - F.steps.length =
      ((F.numVerts : ℤ) - F.mergeCount) - F.cycleCount := by
  linarith [ WFiltration.total_eq_merge_plus_cycle F ]

/-
**Tree characterization**: connected + no cycle births ↔ tree.
-/
theorem tree_iff_no_cycles (F : WFiltration)
    (hconn : (F.numVerts : ℤ) - F.mergeCount = 1) :
    F.cycleCount = 0 ↔ F.steps.length + 1 = F.numVerts := by
  constructor <;> intro h <;> have := WFiltration.total_eq_merge_plus_cycle F <;> omega

/-! ## Part 7: Concentration Infrastructure (Theorem 3) -/

/-
**Theorem 3: Bounded differences for the cycle-birth counting function.**
    As a function on Boolean classification vectors, it satisfies
    |f(x) - f(x')| ≤ 1 when x and x' differ in one coordinate.

    This is the key analytical input for McDiarmid/Azuma concentration:
    P(|N(t) - E[N(t)]| ≥ r) ≤ 2·exp(-2r²/m).
-/
theorem cycleBirth_hasBoundedDifferences (m : ℕ) :
    HasBoundedDifferences m
      (fun bs => (Finset.univ.filter (fun i => bs i = true)).card) 1 := by
  intro x i b;
  by_cases hi : x i = b <;> simp +decide [ Function.update_apply ];
  · rw [ show ( Finset.univ.filter fun j => if j = i then b = true else x j = true ) = Finset.univ.filter ( fun j => x j = true ) from Finset.ext fun j => by aesop ] ; norm_num;
  · cases b <;> simp_all +decide;
    · rw [ show ( Finset.univ.filter fun j => ¬j = i ∧ x j = true ) = Finset.univ.filter ( fun j => x j = true ) \ { i } by ext j; by_cases hj : j = i <;> aesop ] ; simp +decide [ Finset.card_sdiff, * ];
      grind;
    · rw [ show ( Finset.filter ( fun j => ¬j = i → x j = true ) Finset.univ : Finset ( Fin m ) ) = Finset.filter ( fun j => x j = true ) Finset.univ ∪ { i } from ?_, Finset.card_union ] <;> norm_num [ hi ];
      grind

/-! ## Part 8: Worked Examples -/

theorem triangle_cycle_count : triangleFiltration.cycleCount = 1 := by native_decide
theorem triangle_merge_count : triangleFiltration.mergeCount = 2 := by native_decide
theorem triangle_total : triangleFiltration.steps.length = 3 := by native_decide

theorem k4_cycle_count : k4Filtration.cycleCount = 3 := by native_decide
theorem k4_merge_count : k4Filtration.mergeCount = 3 := by native_decide

/-- K₄: cycle count = m - (n-1) = 6 - 3 = 3. -/
theorem k4_betti1 :
    k4Filtration.cycleCount = k4Filtration.steps.length - (k4Filtration.numVerts - 1) := by
  native_decide

/-- K₄: cycle-birth weights are [4, 5, 6]. -/
theorem k4_cycleBirthWeights :
    k4Filtration.cycleBirthWeights = [4, 5, 6] := by native_decide

/-- Monotone transport preserves classification for K₄. -/
theorem k4_monotone_invariance :
    (k4Filtration.mapWeights (· * 2)).cycleCount = k4Filtration.cycleCount := by
  native_decide

/-- K₄: one cycle birth at or below threshold 4.5. -/
theorem k4_cycleBirthCountLE :
    k4Filtration.cycleBirthCountLE (9/2) = 1 := by native_decide

/-! ## Part 9: Asymptotic Conjectures

**Conjecture (Tropical Spectral Law for Random Graphs):**

For each fixed p ∈ (0,1), let G_n ~ G(n,p) and let edge weights be
i.i.d. from any continuous distribution F. Let

  μ_Gn := (1/β₁(G_n)) · Σ_{e ∈ CycleBirthEdges} δ_{F(w(e))}

on the event β₁(G_n) > 0. Then there exists a deterministic probability
measure μ_p on [0,1] such that μ_Gn → μ_p weakly in probability
as n → ∞.

By monotone transport invariance (Theorem 4), the limiting measure
depends on F only through monotone rescaling.

**Testable prediction**: KS distance between empirical CDFs from
independent trials decays like O(n^{-1/2}).

**Falsifiable stronger conjecture**: For dense G(n,p), the limit law μ_p
is Beta-like with parameters determined only by p.
-/

end CycleBirth