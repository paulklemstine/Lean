/-
# Translation invariants of finite Cayley-graph observables

Finite groups carry a canonical network geometry through their Cayley graphs.  This
chapter isolates an exact mechanism behind the empirical regularities studied in
*Learning the Graphical Nature of Symmetries*: left translation preserves not only
adjacency, but the full local incidence data used by degree, triangle, and
square-based statistics.

The principal result, `commonNeighborEquivDifference`, states that the common
neighbours of an ordered pair `(a,b)` are in bijection with those of
`(1,a⁻¹b)`.  Thus every common-neighbour statistic factors through the group
difference `a⁻¹b`.  The degree theorem is its one-vertex analogue.  A second
layer proves that these equivalences commute with adjacency, so the induced graph
on a common neighbourhood is preserved as well; this controls edges among common
neighbours, a basic four-cycle observable.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Seven falsifiable targets were ranked by impact:
  (1) all rooted finite-radius observables factor through group differences;
  (2) square-clustering profiles are constant on translation orbits;
  (3) pairwise common-neighbour counts depend only on `a⁻¹b`;
  (4) induced common-neighbour graphs depend only on `a⁻¹b`;
  (5) degree is constant; (6) triangle counts are translation invariant; and
  (7) inversion should identify the profiles at `g` and `g⁻¹`.  Targets (1),
  (2), and a spectral extension of (4) are the boldest because they bridge group
  actions, local graph geometry, and spectral data.
Experiment (Experimenter): The external signal was the census of 131,406 Cayley
  graphs and its square-clustering observations.  Rather than reproduce finite
  tabulation, the experiment attacked the symmetry forcing those observations.
  Explicit maps `x ↦ c*x` and `x ↦ a⁻¹*x` were tested on neighbour and common-
  neighbour subtypes.  They are inverse bijections and preserve adjacency.
Analysis (Analyst): Targets (3)--(5) survive in stronger, cardinality-free form:
  explicit equivalences exist before finiteness is assumed.  The common mechanism
  is cancellation in `(c*a)⁻¹(c*b)=a⁻¹b`; consequently pair observables live on
  relative group elements rather than on ordered vertex pairs.
Critique (Critic): No converse is claimed: regular degree or uniform local counts
  do not characterize Cayley graphs.  The identity-free and symmetry assumptions
  on the connection set are essential to obtain a simple undirected graph.  The
  boundary between counts and spectra is also explicit: adjacency preservation of
  the induced common-neighbour graph is proved, while spectral consequences need
  a separately chosen matrix model.
Synthesis (PI): The resulting hierarchy runs from translation automorphisms, to
  neighbour equivalences, to pair-difference common-neighbour equivalences, and
  finally to induced-subgraph isomorphisms.  This gives exact algebraic reasons
  for several local network regularities and a reusable bridge from finite-group
  algebra to graph observables.
Generalization: the same construction extends to every finite incidence pattern
  defined solely by adjacency and equality, and more broadly to relational Cayley
  structures.  A spectral extension can transport adjacency matrices through the
  resulting permutation similarities.
Boundary: arbitrary vertex-transitive graphs retain orbit invariance but need not
  possess the canonical difference coordinate `a⁻¹b`; regular graphs alone can have
  several inequivalent common-neighbour profiles.
-/

import Novelty.UphoMultiplicability.Sabidussi

open UphoMultiplicability

namespace LearningGraphicalSymmetries

variable {H : Type*} [Group H]
variable (S : Set H) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S) (h1 : (1 : H) ∉ S)

local notation "Γ" => cayleyGraph H S hsymm h1

/-- Left translation gives an explicit equivalence between neighbourhoods. -/
def neighborEquivLeft (c a : H) :
    {x : H // (cayleyGraph H S hsymm h1).Adj a x} ≃ {x : H // (cayleyGraph H S hsymm h1).Adj (c * a) x} where
  toFun x := ⟨c * x, (cayleyLeftMul H S hsymm h1 c).map_rel_iff.mpr x.property⟩
  invFun x := ⟨c⁻¹ * x, by
    have hx := (cayleyLeftMul H S hsymm h1 c⁻¹).map_rel_iff.mpr x.property
    simpa [cayleyLeftMul] using hx⟩
  left_inv x := by ext; simp
  right_inv x := by ext; simp

/-- Common-neighbour configurations are transported by simultaneous left
translation of their two roots. -/
def commonNeighborEquivLeft (c a b : H) :
    {x : H // (cayleyGraph H S hsymm h1).Adj a x ∧ (cayleyGraph H S hsymm h1).Adj b x} ≃
      {x : H // (cayleyGraph H S hsymm h1).Adj (c * a) x ∧ (cayleyGraph H S hsymm h1).Adj (c * b) x} where
  toFun x := ⟨c * x,
    ⟨(cayleyLeftMul H S hsymm h1 c).map_rel_iff.mpr x.property.1,
     (cayleyLeftMul H S hsymm h1 c).map_rel_iff.mpr x.property.2⟩⟩
  invFun x := ⟨c⁻¹ * x, by
    constructor
    · have hx := (cayleyLeftMul H S hsymm h1 c⁻¹).map_rel_iff.mpr x.property.1
      simpa [cayleyLeftMul] using hx
    · have hx := (cayleyLeftMul H S hsymm h1 c⁻¹).map_rel_iff.mpr x.property.2
      simpa [cayleyLeftMul] using hx⟩
  left_inv x := by ext; simp
  right_inv x := by ext; simp

/-- **Pair-difference principle.**  The common neighbourhood of `(a,b)` is
canonically equivalent to that of `(1,a⁻¹b)`. -/
def commonNeighborEquivDifference (a b : H) :
    {x : H // (cayleyGraph H S hsymm h1).Adj a x ∧ (cayleyGraph H S hsymm h1).Adj b x} ≃
      {x : H // (cayleyGraph H S hsymm h1).Adj 1 x ∧ (cayleyGraph H S hsymm h1).Adj (a⁻¹ * b) x} where
  toFun x := ⟨a⁻¹ * x, by
    constructor
    · have hx := (cayleyLeftMul H S hsymm h1 a⁻¹).map_rel_iff.mpr x.property.1
      simpa [cayleyLeftMul] using hx
    · exact (cayleyLeftMul H S hsymm h1 a⁻¹).map_rel_iff.mpr x.property.2⟩
  invFun x := ⟨a * x, by
    constructor
    · have hx := (cayleyLeftMul H S hsymm h1 a).map_rel_iff.mpr x.property.1
      simpa [cayleyLeftMul] using hx
    · have hx := (cayleyLeftMul H S hsymm h1 a).map_rel_iff.mpr x.property.2
      simpa [cayleyLeftMul, mul_assoc] using hx⟩
  left_inv x := by ext; simp
  right_inv x := by ext; simp

/-- Finite Cayley graphs are regular: every vertex has the same degree as the
identity vertex. -/
theorem degree_eq_identity [Fintype H] (a : H) :
    Nat.card {x : H // (cayleyGraph H S hsymm h1).Adj a x} = Nat.card {x : H // (cayleyGraph H S hsymm h1).Adj 1 x} := by
  exact Nat.card_congr (by simpa using neighborEquivLeft S hsymm h1 a⁻¹ a)

/-- The number of common neighbours of two vertices depends only on their group
difference.  This simultaneously controls edgewise triangle completion counts
and the opposite-corner count entering square-clustering statistics. -/
theorem commonNeighbor_card_eq_difference [Fintype H] (a b : H) :
    Nat.card {x : H // (cayleyGraph H S hsymm h1).Adj a x ∧ (cayleyGraph H S hsymm h1).Adj b x} =
      Nat.card {x : H // (cayleyGraph H S hsymm h1).Adj 1 x ∧ (cayleyGraph H S hsymm h1).Adj (a⁻¹ * b) x} := by
  exact Nat.card_congr (commonNeighborEquivDifference S hsymm h1 a b)

/-- Translation of common neighbours preserves their internal adjacency.  Hence
it identifies the entire graph induced by a common neighbourhood, not merely its
cardinality. -/
theorem commonNeighborEquivLeft_map_adj (c a b : H)
    (x y : {z : H // (cayleyGraph H S hsymm h1).Adj a z ∧ (cayleyGraph H S hsymm h1).Adj b z}) :
    (cayleyGraph H S hsymm h1).Adj x y ↔
      (cayleyGraph H S hsymm h1).Adj (commonNeighborEquivLeft S hsymm h1 c a b x)
        (commonNeighborEquivLeft S hsymm h1 c a b y) := by
  exact (cayleyLeftMul H S hsymm h1 c).map_rel_iff.symm

/-- The pair-difference equivalence preserves adjacency among common neighbours,
so all edge-based observables of that induced graph factor through `a⁻¹b`. -/
theorem commonNeighborEquivDifference_map_adj (a b : H)
    (x y : {z : H // (cayleyGraph H S hsymm h1).Adj a z ∧ (cayleyGraph H S hsymm h1).Adj b z}) :
    (cayleyGraph H S hsymm h1).Adj x y ↔
      (cayleyGraph H S hsymm h1).Adj (commonNeighborEquivDifference S hsymm h1 a b x)
        (commonNeighborEquivDifference S hsymm h1 a b y) := by
  exact (cayleyLeftMul H S hsymm h1 a⁻¹).map_rel_iff.symm

/-! ## Concrete examples and API checks -/

/-- Specializing the degree theorem to a finite group gives a concrete equality
for any chosen vertex and connection set. -/
example [Fintype H] (a : H) :
    Nat.card {x : H // (cayleyGraph H S hsymm h1).Adj a x} =
      Nat.card {x : H // (cayleyGraph H S hsymm h1).Adj 1 x} := by
  exact degree_eq_identity S hsymm h1 a

#check commonNeighborEquivDifference
#check commonNeighbor_card_eq_difference
#check UphoMultiplicability.sabidussi

end LearningGraphicalSymmetries