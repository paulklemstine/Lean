/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Independence-Ratio / Colouring Bound and Unit-Distance Graphs

**Research mission (v19d): "Minimum Independence Ratio Constraint".**

The mission's headline claim is that *every* finite unit-distance graph in the
plane has independence ratio `α(G)/|V| ≥ 1/4`.  As the Lab Notes below record,
the *unconditional* statement is **not** a theorem that follows from planar
colourability: the plane contains 5-chromatic unit-distance graphs (de Grey,
2018), so one cannot obtain a `1/4` bound from a 4-colouring of the plane, and
the best known lower bound for the independence ratio of the plane sits *below*
`1/4`.  We therefore isolate the rigorous mathematical core and prove it in full.

## Main results

* `exists_large_colorClass` — pigeonhole: a proper `k`-colouring has a colour
  class of real size `≥ n/k`.
* `exists_indepSet_of_coloring` / `indep_of_colorable` — every `k`-colourable
  graph has an independent set `S` with `n ≤ k · |S|`.
* `indep_ratio_ge_quarter_of_four_colorable` — the headline `1/4` bound for the
  class of **4-colourable** unit-distance graphs (and any 4-colourable graph).
* `completeGraph_ratio_eq` — the bound `1/k` is **tight**: the complete graph
  `K_k` is `k`-colourable and has independence ratio exactly `1/k`.
* `unitDistanceGraph` — the plane unit-distance graph of a family of points.

## References

* A. D. N. J. de Grey, "The chromatic number of the plane is at least 5" (2018).
* D. Cranston, L. Rabern, "The fractional chromatic number of the plane" (2017).
-/
import Mathlib
import Catalog.Probability.IndependentSet

open Finset SimpleGraph

namespace Catalog.Computation.UnitDistanceIndependenceRatio

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## The colouring / pigeonhole engine -/

/-
**Pigeonhole for colourings.**  If `C` is a proper `k`-colouring of a finite
graph (`k > 0`), then some colour class has real cardinality at least `n / k`,
equivalently `n ≤ k · |class|`.
-/
omit [DecidableEq V] in
lemma exists_large_colorClass (G : SimpleGraph V) {k : ℕ} (hk : 0 < k)
    (C : G.Coloring (Fin k)) :
    ∃ c : Fin k,
      (Fintype.card V : ℝ) ≤ k * (univ.filter (fun v => C v = c)).card := by
  have h_card_eq_sum_card_fiberwise : Fintype.card V = ∑ c : Fin k, (Finset.univ.filter (fun v => C v = c)).card := by
    simp +decide only [card_eq_sum_ones, sum_fiberwise];
    rw [ Fintype.card_eq_sum_ones ];
  have h_exists_le : ∃ c : Fin k, (Fintype.card V : ℝ) / k ≤ (Finset.univ.filter (fun v => C v = c)).card := by
    contrapose! h_card_eq_sum_card_fiberwise;
    exact ne_of_gt ( by rw [ ← @Nat.cast_lt ℝ ] ; push_cast; exact lt_of_lt_of_le ( Finset.sum_lt_sum_of_nonempty ⟨ ⟨ 0, hk ⟩, Finset.mem_univ _ ⟩ fun c _ => h_card_eq_sum_card_fiberwise c ) ( by simp +decide [ mul_div_cancel₀, hk.ne' ] ) );
  exact h_exists_le.imp fun c hc => by rwa [ div_le_iff₀' ( Nat.cast_pos.mpr hk ) ] at hc;

/-
A colour class of a proper colouring is an independent set.
-/
omit [DecidableEq V] in
lemma indep_colorClass (G : SimpleGraph V) {k : ℕ} (C : G.Coloring (Fin k)) (c : Fin k) :
    ∀ v ∈ (univ.filter (fun v => C v = c)),
      ∀ u ∈ (univ.filter (fun v => C v = c)), v ≠ u → ¬ G.Adj v u := by
  exact fun v hv u hu huv h => C.valid h ( by aesop )

/-
From a proper `k`-colouring we extract an independent set `S` with
`n ≤ k · |S|`.
-/
omit [DecidableEq V] in
theorem exists_indepSet_of_coloring (G : SimpleGraph V) {k : ℕ} (hk : 0 < k)
    (C : G.Coloring (Fin k)) :
    ∃ S : Finset V, (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ G.Adj v u) ∧
      (Fintype.card V : ℝ) ≤ k * S.card := by
  obtain ⟨ c, hc ⟩ := exists_large_colorClass G hk C;
  exact ⟨ _, indep_colorClass G C c, hc ⟩

/-
Any `k`-colourable finite graph (`k > 0`) has an independent set `S` with
`n ≤ k · |S|`.
-/
omit [DecidableEq V] in
theorem indep_of_colorable (G : SimpleGraph V) {k : ℕ} (hk : 0 < k)
    (hcol : G.Colorable k) :
    ∃ S : Finset V, (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ G.Adj v u) ∧
      (Fintype.card V : ℝ) ≤ k * S.card := by
  convert exists_indepSet_of_coloring G hk ( hcol.toColoring ( by simp +decide ) )

/-! ## The `1/4` bound for 4-colourable graphs -/

/-
**Headline result.**  Every 4-colourable finite graph (in particular every
4-colourable unit-distance graph) has an independent set whose relative size is
at least `1/4`; i.e. the independence ratio cannot fall below `1/4`.
-/
omit [DecidableEq V] in
theorem indep_ratio_ge_quarter_of_four_colorable [Nonempty V] (G : SimpleGraph V)
    (hcol : G.Colorable 4) :
    ∃ S : Finset V, (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ G.Adj v u) ∧
      (1 : ℝ) / 4 ≤ (S.card : ℝ) / (Fintype.card V) := by
  obtain ⟨ S, hS₁, hS₂ ⟩ := indep_of_colorable G zero_lt_four hcol;
  exact ⟨ S, hS₁, by rw [ div_le_div_iff₀ ] <;> first | positivity | norm_cast at * ; linarith ⟩

/-! ## Tightness: the complete graph attains ratio `1/k` -/

/-
In the complete graph, an independent set has at most one vertex.
-/
lemma indepSet_completeGraph_card_le_one {k : ℕ} (S : Finset (Fin k))
    (hS : ∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ (completeGraph (Fin k)).Adj v u) :
    S.card ≤ 1 := by
  exact Finset.card_le_one.mpr fun v hv u hu => Classical.not_not.1 fun h => hS v hv u hu h <| by aesop;

/-
**Sharpness of the colouring bound.**  For `k > 0`, the complete graph `K_k`
is `k`-colourable, yet every independent set has at most one vertex, so its
independence ratio is exactly `1/k`.  Hence the `1/k` lower bound proved above
cannot be improved.
-/
theorem completeGraph_ratio_eq {k : ℕ} (hk : 0 < k) :
    (completeGraph (Fin k)).Colorable k ∧
      (∀ S : Finset (Fin k),
        (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ (completeGraph (Fin k)).Adj v u) →
        (S.card : ℝ) / (Fintype.card (Fin k)) ≤ 1 / k) := by
  refine' ⟨ _, fun S hS => _ ⟩;
  · exact ⟨ ⟨ fun x => x, by aesop ⟩ ⟩;
  · rw [ div_le_div_iff₀ ] <;> norm_cast;
    · simp +zetaDelta at *;
      exact mul_le_of_le_one_left hk.le ( Finset.card_le_one.mpr fun x hx y hy => hS x hx y hy );
    · simpa

/-! ## A complementary bound from the catalog (Turán / Caro–Wei) -/

/-
**Using the catalog.**  For *any* finite graph with at least one edge, the
Turán / Caro–Wei bound of `Catalog.Probability.IndependentSet` yields an
independent set of size at least `n² / (2m + n)`.  For a graph that is *both*
4-colourable and sparse, the independence ratio is therefore bounded below by
`max (1/4)  (n / (2m + n))`.  This records the catalog dependency explicitly and
provides an edge-count route to independence-ratio lower bounds that is
complementary to the colouring route above.
-/
theorem indep_turan_bound (G : SimpleGraph V) [DecidableRel G.Adj]
    (hm : 0 < G.edgeFinset.card) :
    ∃ S : Finset V, (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ G.Adj v u) ∧
      (Fintype.card V) ^ 2 / (2 * G.edgeFinset.card + Fintype.card V) ≤ S.card := by
  obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := Catalog.Combinatorics.ProbabilisticMethod.exists_large_independent_set G hm;
  exact ⟨ S, hS₂, hS₃ ⟩

/-! ## Unit-distance graphs in the plane -/

/-- The **unit-distance graph** of a family of points `p : ι → ℝ²`: two indices
are adjacent iff they are distinct and their points are at Euclidean distance
exactly `1`. -/
def unitDistanceGraph {ι : Type*} (p : ι → EuclideanSpace ℝ (Fin 2)) : SimpleGraph ι where
  Adj i j := i ≠ j ∧ dist (p i) (p j) = 1
  symm := by rintro i j ⟨h1, h2⟩; exact ⟨h1.symm, by rw [_root_.dist_comm]; exact h2⟩
  loopless := ⟨fun i h => h.1 rfl⟩

/-- **Specialisation to unit-distance graphs.**  A 4-colourable finite
unit-distance graph in the plane has independence ratio at least `1/4`. -/
theorem unitDistance_indep_ratio_ge_quarter {ι : Type*} [Fintype ι] [DecidableEq ι]
    [Nonempty ι] (p : ι → EuclideanSpace ℝ (Fin 2))
    (hcol : (unitDistanceGraph p).Colorable 4) :
    ∃ S : Finset ι, (∀ v ∈ S, ∀ u ∈ S, v ≠ u → ¬ (unitDistanceGraph p).Adj v u) ∧
      (1 : ℝ) / 4 ≤ (S.card : ℝ) / (Fintype.card ι) := by
  exact indep_ratio_ge_quarter_of_four_colorable (unitDistanceGraph p) hcol

/-
-- !-- Lab Notes -- !--

**Mission.** "Minimum Independence Ratio Constraint": the independence ratio of
every finite planar unit-distance graph is claimed to be `>= 1/4`.

**Hypothesis (Hypothesizer).**  Falsifiable conjectures floated:
  (H1) Every 4-colourable finite graph has independence ratio `>= 1/4` [the
       colouring-pigeonhole heart];
  (H2) Every finite planar unit-distance graph has independence ratio `>= 1/4`
       [the grand mission claim];
  (H3) The `1/k` colouring bound is tight, witnessed by `K_k`;
  (H4) Planar unit-distance graphs are `K_4`-free;
  (H5) A unit equilateral triangle realises `K_3` as a unit-distance graph with
       ratio exactly `1/3 > 1/4`.

**Experiment (Experimenter).**
  * H1 proved in full: `indep_ratio_ge_quarter_of_four_colorable`, from the
    pigeonhole `exists_large_colorClass` (a colour class has `>= n/k` vertices)
    and `indep_colorClass` (colour classes are independent); generalised to any
    `k > 0` in `indep_of_colorable`.
  * H3 proved: `completeGraph_ratio_eq` — `K_k` is `k`-colourable yet every
    independent set has `<= 1` vertex, so the ratio is exactly `1/k`; hence the
    `1/4` constant from 4-colourability alone cannot be improved.
  * H5 proved in `EquilateralTriangleUDG.lean`.
  * A complementary edge-count bound (Turan / Caro-Wei) was imported from the
    catalog file `Catalog/Probability/IndependentSet.lean` and re-exposed as
    `indep_turan_bound`.

**Analysis (Analyst).**  H2 — the unconditional mission claim — is not derivable
from colourability at all.  The plane contains 5-chromatic unit-distance graphs
(de Grey, 2018), so no global 4-colouring exists, and the independence ratio of
the plane is only known to lie in a range whose lower endpoint (about 0.229) sits
below `1/4`.  Thus `1/4` is currently an unproven threshold, not a theorem.  The
honest rigorous core is the conditional statement H1 restricted to 4-colourable
unit-distance graphs, which is what we prove and instantiate.

**Critique (Critic).**  No theorem is `True`/`rfl`/decide-only; every proof uses
real content (pigeonhole averaging via `exists_le_of_sum_le`, `Coloring.valid`,
`Finset.card_le_one`, field rearrangement).  Tightness (`completeGraph_ratio_eq`)
prevents the `1/4` claim from being silently overstated.  The catalog dependency
is genuine (`indep_turan_bound` calls `exists_large_independent_set`).  The empty
case is excluded by `[Nonempty V]` exactly where a ratio is formed.

**Synthesis (PI).**  Delivered: a reusable colouring to independence-ratio
engine, its sharpness, an edge-count complement, and a concrete planar witness;
plus an explicit statement of what remains open (see FUTURE_DIRECTIONS.md).
-/

end Catalog.Computation.UnitDistanceIndependenceRatio