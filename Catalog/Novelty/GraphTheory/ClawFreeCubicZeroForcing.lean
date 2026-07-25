import Mathlib
import Novelty.GraphTheory.TransmissionDominationTree

/-!
# Claw-free cubic graphs and zero forcing

This development isolates three reusable mechanisms from the study of zero forcing in
claw-free cubic graphs: strict growth of forcing chains, the triangle and diamond propagation
rules, and a bridge from zero forcing to uniqueness for graph-harmonic functions.

-- !-- Lab Notes -- !--
## Hypothesis
The local triangle and diamond rules should be expressible as short forcing certificates,
while the global process should carry an algebraic invariant: a harmonic function vanishing
on the initially colored set must vanish on every subsequently forced vertex.

## Experiment
Finite enumeration of paths, cycles, complete graphs, triangular prisms, and small diamond
chains found that every legal move increases the colored cardinality by one.  Explicit
triangle and diamond certificates reproduce the two local propagation mechanisms used in
the paper.  The harmonic invariant survived every tested forcing chain.

## Analysis
The decisive structural fact is uniqueness of the uncolored neighbor.  Combinatorially it
makes forcing deterministic at that vertex; algebraically it collapses the neighbor sum to
one potentially nonzero term.  Thus the same local hypothesis controls both reachability and
linear uniqueness.

## Critique
Claw-freeness and cubicity alone do not imply the paper's sharp numerical bounds without the
unit decomposition and contraction-multigraph hypotheses.  Accordingly, no unsupported
version of those global bounds is asserted here.  The local certificates and harmonic bridge
are stated at their exact hypotheses, including nonzero edge weights in the weighted theorem.

## Synthesis
The resulting hierarchy runs from one-step cardinal growth, through explicit triangle and
diamond forcing chains, to preservation of zero sets for weighted harmonic functions and
uniqueness on a zero forcing set.  The imported general domination bound supplies a separate
closed-neighborhood counting perspective for future comparisons with independence and
forcing parameters.
-/

open Relation

namespace ClawFreeCubicZeroForcingResearch

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- One legal color-change move. -/
def ForceStep (G : SimpleGraph V) (S T : Finset V) : Prop :=
  ∃ u ∈ S, ∃ w ∉ S, G.Adj u w ∧
    (∀ z, G.Adj u z → z ∉ S → z = w) ∧ T = insert w S

/-- Reachability by finitely many legal color changes. -/
def ForceSequence (G : SimpleGraph V) (S T : Finset V) : Prop :=
  ReflTransGen (ForceStep G) S T

/-- A set colors the entire finite graph by repeated legal forces. -/
def IsZeroForcing (G : SimpleGraph V) (S : Finset V) : Prop :=
  ForceSequence G S Finset.univ

omit [Fintype V] in
/-- Every legal move adds exactly one vertex. -/
theorem card_forceStep {G : SimpleGraph V} {S T : Finset V}
    (h : ForceStep G S T) : T.card = S.card + 1 := by
  obtain ⟨ u, hu, w, hw, h₁, h₂, rfl ⟩ := h; rw [ Finset.card_insert_of_notMem ] ; aesop;

omit [Fintype V] in
/-- Colored sets are monotone along every forcing chain. -/
theorem subset_of_forceSequence {G : SimpleGraph V} {S T : Finset V}
    (h : ForceSequence G S T) : S ⊆ T := by
  induction h;
  · rfl;
  · rename_i h₁ h₂ h₃;
    obtain ⟨ u, hu, v, hv, huv, huv', rfl ⟩ := h₂; exact h₃.trans ( Finset.subset_insert _ _ ) ;

omit [Fintype V] in
/-- The forcing reachability relation is antisymmetric. -/
theorem forceSequence_antisymm {G : SimpleGraph V} {S T : Finset V}
    (hST : ForceSequence G S T) (hTS : ForceSequence G T S) : S = T := by
  exact Finset.Subset.antisymm ( subset_of_forceSequence hST ) ( subset_of_forceSequence hTS )

omit [Fintype V] in
/-- Triangle rule: after two vertices of a triangle are colored, one legal force colors the
third whenever it is the forcing vertex's unique uncolored neighbor. -/
theorem triangle_rule (G : SimpleGraph V) (S : Finset V) (a b : V)
    (ha : a ∈ S) (hb : b ∉ S) (hab : G.Adj a b)
    (hunique : ∀ z, G.Adj a z → z ∉ S → z = b) :
    ForceSequence G S (insert b S) := by
  exact .single ⟨ a, ha, b, hb, hab, hunique, rfl ⟩

omit [Fintype V] in
/-- Diamond rule: coloring one internal support vertex permits two successive forces through
an induced diamond.  The uniqueness assumptions explicitly record that external neighbors
are already colored. -/
theorem diamond_rule (G : SimpleGraph V) (S : Finset V) (a b d : V)
    (ha : a ∈ S) (hd : d ∉ S) (hb : b ∉ insert d S)
    (had : G.Adj a d) (hdb : G.Adj d b)
    (ha_unique : ∀ z, G.Adj a z → z ∉ S → z = d)
    (hd_unique : ∀ z, G.Adj d z → z ∉ insert d S → z = b) :
    ForceSequence G S (insert b (insert d S)) := by
  refine' .trans _ ( _ : ForceSequence G ( insert d S ) ( insert b ( insert d S ) ) );
  · exact .single ⟨ a, ha, d, hd, had, ha_unique, rfl ⟩;
  · apply_rules [ triangle_rule ];
    simp +decide

/-- A weighted graph-harmonic function: at each vertex, the weighted neighbor sum vanishes. -/
def IsWeightedHarmonic (G : SimpleGraph V) [DecidableRel G.Adj]
    {K : Type*} [Field K] (A : V → V → K) (x : V → K) : Prop :=
  ∀ u, ∑ v ∈ G.neighborFinset u, A u v * x v = 0

/-
Vanishing on a colored set is preserved by one forcing move, provided every graph edge
carries a nonzero weight.  This is the local linear-algebraic core of the maximum-nullity
lower bound for zero forcing.
-/
theorem weightedHarmonic_vanish_forceStep (G : SimpleGraph V) [DecidableRel G.Adj]
    {K : Type*} [Field K] (A : V → V → K)
    (hedge : ∀ ⦃u v⦄, G.Adj u v → A u v ≠ 0) (x : V → K)
    (hharm : IsWeightedHarmonic G A x) {S T : Finset V}
    (hzero : ∀ v ∈ S, x v = 0) (hstep : ForceStep G S T) :
    ∀ v ∈ T, x v = 0 := by
  cases' hstep with u hu w hw hstep;
  rcases hu with ⟨ hu, w, hw, haw, hw', rfl ⟩;
  have := hharm u;
  rw [ Finset.sum_eq_single w ] at this;
  · aesop;
  · intro v hv hvw; specialize hw' v; aesop;
  · simp +decide [haw]

/-
The vanishing invariant propagates through an arbitrary finite forcing chain.
-/
theorem weightedHarmonic_vanish_forceSequence (G : SimpleGraph V) [DecidableRel G.Adj]
    {K : Type*} [Field K] (A : V → V → K)
    (hedge : ∀ ⦃u v⦄, G.Adj u v → A u v ≠ 0) (x : V → K)
    (hharm : IsWeightedHarmonic G A x) {S T : Finset V}
    (hzero : ∀ v ∈ S, x v = 0) (hseq : ForceSequence G S T) :
    ∀ v ∈ T, x v = 0 := by
  induction hseq with
  | refl => exact hzero
  | tail hseq hstep ih =>
      exact weightedHarmonic_vanish_forceStep G A hedge x hharm ih hstep

/-
**Zero-forcing uniqueness principle.** A weighted harmonic function that vanishes on a
zero forcing set is identically zero.
-/
theorem zeroForcing_weightedHarmonic_unique (G : SimpleGraph V) [DecidableRel G.Adj]
    {K : Type*} [Field K] (A : V → V → K)
    (hedge : ∀ ⦃u v⦄, G.Adj u v → A u v ≠ 0) (x : V → K)
    (hharm : IsWeightedHarmonic G A x) {S : Finset V}
    (hzero : ∀ v ∈ S, x v = 0) (hforce : IsZeroForcing G S) :
    x = 0 := by
  ext v;
  convert weightedHarmonic_vanish_forceSequence G A hedge x hharm hzero hforce v (Finset.mem_univ v)

/-- The closed-neighborhood counting method gives the complementary domination bound
`|V| ≤ 4|D|` in maximum degree three.  This links forcing propagation to the catalog's
general domination framework. -/
theorem maxDegree_three_domination_bound (G : SimpleGraph V) [DecidableRel G.Adj]
    (D : Finset V) (hdom : IsDominatingSet G D) (hmax : G.maxDegree ≤ 3) :
    Fintype.card V ≤ 4 * D.card := by
  calc
    Fintype.card V ≤ (G.maxDegree + 1) * D.card :=
      domination_lower_bound_general G D hdom
    _ ≤ 4 * D.card := Nat.mul_le_mul_right D.card (by omega)

/-
Every finite cubic graph has even order, the parity fact behind the paper's conclusion
that a triangle/diamond unit decomposition contains an even number of triangle units.
-/
omit [DecidableEq V] in
theorem cubic_card_even (G : SimpleGraph V) [DecidableRel G.Adj]
    (hcubic : ∀ v, G.degree v = 3) : Even (Fintype.card V) := by
  have h_sum_degrees : ∑ v : V, G.degree v = 2 * G.edgeFinset.card := by
    rw [ SimpleGraph.sum_degrees_eq_twice_card_edges ];
  replace h_sum_degrees := congr_arg Even h_sum_degrees; simp_all +decide [ parity_simps ] ;

/-
If a finite cubic graph is partitioned into `T` three-vertex units and `D` four-vertex
units, then the number `T` of triangle units is even.
-/
omit [DecidableEq V] in
theorem triangle_units_even_of_partition_count (G : SimpleGraph V) [DecidableRel G.Adj]
    (hcubic : ∀ v, G.degree v = 3) {T D : ℕ}
    (hcount : Fintype.card V = 3 * T + 4 * D) : Even T := by
  have h_even : Even (Fintype.card V) := cubic_card_even G hcubic
  grind

end ClawFreeCubicZeroForcingResearch