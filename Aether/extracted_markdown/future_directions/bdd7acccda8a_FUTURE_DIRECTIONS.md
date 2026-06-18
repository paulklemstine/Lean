# Future Directions: Tropical Matroid Theory

## 1. Tropical Plücker Relations and Valuated Matroids

The Bergman fan formalization uses the "min achieved twice" characterization of
tropical vanishing. A natural next step is to formalize *valuated matroids*
(Dress–Wenzel), where basis valuations satisfy tropical Plücker relations,
and prove that the Bergman fan of a valuated matroid equals the tropical linear
space defined by these relations.

**The key insight is** that tropical Plücker relations generalize the circuit
vanishing condition by encoding the interaction between *pairs* of bases via
a three-term tropical relation, providing a basis-centric rather than
circuit-centric description of the same geometric object.

**Why now?** Our `CircuitSystem` formalization provides the circuit side; a
parallel `ValuatedMatroid` structure with basis valuations would enable a
formal proof of their equivalence (Speyer's theorem), bridging combinatorial
and algebraic tropical geometry.

## 2. Matroid Polytope and Bergman Fan Duality

The matroid polytope P(M) ⊂ ℝⁿ (convex hull of indicator vectors of bases)
is dual to the Bergman fan in a precise sense: the normal fan of P(M) refines
B(M). Formalizing this would connect our tropical theory to Mathlib's convex
geometry library.

**The key insight is** that the face lattice of the matroid polytope is
isomorphic to the lattice of flats of M, and the Bergman fan is the
order complex of this lattice — so the combinatorics of flats mediates
between the polyhedral and tropical viewpoints.

**Why now?** Mathlib has `Convex` and `Polytope`-adjacent infrastructure.
Our `CircuitSystem` can be extended with a `rank` function to define flats,
and the connection between flat lattice and Bergman fan is a concrete
theorem that would demonstrate the power of the formalization.

## 3. Tropical Intersection Theory on Bergman Fans

The stable intersection of two tropical linear spaces L₁ ∩_st L₂ in ℝⁿ/ℝ·1
corresponds to the direct sum of the underlying matroids (when the intersection
is transversal). Formalizing this would give a first instance of tropical
intersection theory in Lean.

**The key insight is** that transversal intersection of Bergman fans
corresponds to the matroid union operation, and the multiplicity at each
maximal cone equals the product of the local multiplicities — making
intersection theory purely combinatorial in the matroid setting.

**Why now?** Our `BergmanFan` definition and `bergmanFan_circuit_inclusion`
theorem provide the containment machinery. Defining matroid direct sum
(circuit set = minimal elements of C₁ ∪ C₂) and proving B(M₁ ⊕ M₂) =
B(M₁) ∩_st B(M₂) would be a significant formalization milestone.

## 4. Bergman Fan as a Balanced Polyhedral Complex

Our current formalization treats the Bergman fan as a *set* of weight vectors.
The deeper structure is that B(M) is a balanced polyhedral complex of
dimension rank(M) - 1, with each maximal cone corresponding to a maximal
chain of flats. Formalizing balancing (the weighted sum of primitive generators
around each codimension-1 face is zero) would capture the full tropical
geometric structure.

**The key insight is** that the balancing condition on B(M) is equivalent
to the matroid circuit elimination axiom — so our `circuit_antichain` axiom
is secretly encoding a piece of the balancing condition, and adding the
full circuit elimination axiom would give the full balanced fan structure.

**Why now?** Our `CircuitSystem` deliberately omits the circuit elimination
axiom for simplicity. Adding it and proving the induced balancing condition
would demonstrate that the axiom has genuine geometric content beyond being
a "matroid axiom."

## 5. Kapranov's Theorem: Bergman Fan of the Graphic Matroid

For the graphic matroid M(G) of a graph G, Kapranov's theorem identifies
B(M(G)) with the moduli space of tropical curves of genus g(G). Formalizing
this for small examples (cycles, complete graphs) would connect tropical
matroid theory to tropical moduli theory.

**The key insight is** that the Bergman fan of a graphic matroid has a
concrete combinatorial description in terms of spanning trees: a weight
vector w is in B(M(G)) iff for every cycle in G, the minimum-weight edge
in the cycle is not unique — which is precisely our `TropicalVanishes`
condition applied to the graphic matroid's circuits.

**Why now?** Mathlib has `SimpleGraph` with cycle and connectivity
infrastructure. Defining the graphic matroid as a `CircuitSystem` (where
circuits = edge sets of cycles) and proving Kapranov's identification for
small cases would be a compelling application of the theory.
