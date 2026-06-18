# Future Directions: Tropical Matroid Theory

## 1. Geometric Lattice Structure and the Bergman Fan Complex

The flat lattice we formalized is known to be a geometric lattice (atomistic + upper semimodular). We proved submodularity of rank on flats, but did not establish the full semimodular law: if F₁ and F₂ both cover F₁ ∧ F₂, then F₁ ∨ F₂ covers both F₁ and F₂. This covering relation is what makes the flag complex a shellable simplicial complex, which in turn gives the Bergman fan its contractibility properties.

The key insight is that the covering relation in the flat lattice exactly corresponds to the codimension-1 face relations in the Bergman fan, so proving the semimodular covering law would immediately yield that the Bergman fan is a pure simplicial complex of dimension rank(M) - 1.

Why now? We have the lattice of flats with meet = intersection and join = closure(union), rank submodularity on flats, and the circuit-flat avoidance theorem. The covering relation can be characterized via rank: F covers G iff G ⊂ F and eRk(F) = eRk(G) + 1, so the next step requires only connecting our existing rank machinery with the covering relation — no new deep infrastructure needed.

## 2. The Ardila-Klivans Theorem: Bergman Fan = Tropical Linear Space

The central theorem of tropical matroid theory asserts that the support of the Bergman fan (the union of its cones) equals the tropical linear space T(M) defined by the circuit valuations. Our file defines `InTropicalLinearSpace` via the double-minimum condition on circuits. The forward direction (Bergman ⊆ T(M)) follows from our `circuit_flat_avoidance` theorem: a weight vector compatible with a flag of flats must give each circuit a doubly-achieved minimum. The reverse direction (T(M) ⊆ Bergman) requires showing that a vector in T(M) is compatible with some flag, using the fine subdivision of the Bergman fan.

The key insight is that our `circuit_flat_avoidance` theorem is essentially the "forward direction" of Ardila-Klivans in disguise: it says circuits cannot be "unbalanced" relative to flats, which is precisely what forces weight vectors to lie in T(M). Formalizing the full equivalence would require defining the cone structure (which is purely combinatorial: each cone is indexed by a flag of flats and consists of weight vectors constant on each flat in the flag).

Why now? The `tropicalSupport_flat_constant` theorem already connects the flat lattice to tropical support membership. Defining the cones as weight vectors piecewise constant on flags, and showing their union contains T(M), is the natural next step that leverages our existing infrastructure.

## 3. Nested Matroids and Tropical Linear Subspace Characterization

We proved that nested matroids have totally ordered flats. The deeper conjecture is: a matroid M is nested if and only if its Bergman fan is a single simplex (equivalently, if and only if T(M) is a tropical linear subspace closed under tropical scalar multiplication). Furthermore, nested matroids decompose as direct sums of uniform matroids U_{0,n_i}, and this decomposition should correspond to a product structure on the Bergman fan.

The key insight is that the total ordering of flats in a nested matroid means there is essentially one maximal flag, so the Bergman fan is a single maximal cone — a simplex. Conversely, if the Bergman fan is a single simplex, the flag it corresponds to must contain all flats, forcing them to be totally ordered.

Why now? Our `nested_matroid_flat_totalOrder` theorem establishes one direction. Defining the cone associated to a flag (weight vectors piecewise constant on the flag's flats) and showing its dimension equals rank(M) - 1 when the matroid is nested would complete the characterization. The direct sum decomposition theorem for nested matroids (into uniform matroids) is a classical result that should be formalizable using the chain structure we already have.

## 4. Matroid Connectivity and Bergman Fan Topology

Connected matroids (those that cannot be decomposed as direct sums) should have connected Bergman fans. More precisely, the adjacency graph of maximal cones of the Bergman fan is connected if and only if the matroid is connected. This connects the combinatorial notion of matroid connectivity (every pair of elements lies in a common circuit) with the topological connectivity of the Bergman fan.

The key insight is that two maximal cones (flags) are adjacent in the Bergman fan if and only if their flags differ by exactly one flat — this is a "flip" in the flag complex. Matroid connectivity ensures that any two flags can be connected by a sequence of flips, using the circuit exchange property to rearrange flats.

Why now? Our `circuit_flat_avoidance` theorem provides the fundamental tool for relating circuits to flats. To formalize connectivity, one would define matroid connectivity (every pair of elements is in a common circuit), define adjacency of flags (differing by one flat), and prove that circuit exchange allows one to connect any two flags. The circuit infrastructure from Mathlib (`IsCircuit`, `ssubset_indep`, `eq_of_subset_isCircuit`) provides the necessary foundation.

## 5. Valuated Matroids and the Dressian

Our formalization works with the "unvaluated" setting where circuits are just subsets. The natural generalization is to valuated matroids, where each basis gets a valuation p : bases → ℤ satisfying the tropical Plücker relations. The tropical linear space of a valuated matroid is a weighted polyhedral complex, and the Dressian Dr(r, n) parametrizes all valuated matroids of rank r on n elements. A deep theorem of Speyer states that every point of the tropical Grassmannian Trop(Gr(r,n)) gives a valuated matroid, but not conversely — the Dressian is strictly larger than the tropical Grassmannian for r ≥ 3, n ≥ 7.

The key insight is that our `InTropicalLinearSpace` definition generalizes naturally: instead of requiring the minimum of w on each circuit to be achieved twice, one requires the minimum of (w + valuation) to be achieved twice, where the valuation comes from the circuit valuation of the valuated matroid. The circuit-flat avoidance theorem generalizes to a "valued circuit-flat avoidance" where the flat structure is replaced by the initial matroid of the valuation.

Why now? The algebraic infrastructure for tropical semirings exists in this catalog (e.g., `TropicalSemiring.lean`, `MaxPlusAlgebra.lean`). Defining valuated matroids as functions on bases satisfying tropical Plücker relations, and extending our flat lattice and tropical support theorems to the valuated setting, would bridge the gap between the combinatorial matroid theory formalized here and the algebraic tropical geometry that the broader catalog develops.
