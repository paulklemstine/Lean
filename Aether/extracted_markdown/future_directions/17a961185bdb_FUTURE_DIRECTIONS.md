# Future Directions: Fractal Topology via Lattice-Theoretic Dimension

## 1. Krull Dimension vs. Lebesgue Covering Dimension

For metrizable separable spaces, the small inductive dimension, large inductive dimension, and Lebesgue covering dimension all coincide. The topological Krull dimension of the open set lattice (as formalized here) captures the nesting depth of open sets. A natural question is whether this agrees with the Lebesgue covering dimension for compact metrizable spaces.

**Conjecture**: For compact metrizable spaces, `topKrullDim X` equals the Lebesgue covering dimension (suitably formalized as the minimum order of finite open refinements minus one).

The key insight is that both dimensions measure "how many open sets must overlap" — Krull dimension via chain length, covering dimension via point multiplicity. The formal bridge would require formalizing refinement of covers and connecting chain length in Opens(X) to the minimum covering order.

**Why now?** The `opensOrderIso` infrastructure and the covering multiplicity invariance (`pointMultiplicity_eq_of_homeo`) provide the exact tools needed to formalize both sides of this equivalence.

## 2. Dimension of Fractal-Like Quotient Spaces

The Cantor set, Sierpiński triangle, and similar fractals can be constructed as quotient spaces of metric spaces under iterated function systems. The topological Krull dimension of these quotients should reflect their fractal complexity, but in a purely topological way (unlike Hausdorff dimension which depends on the metric).

**Conjecture**: For a self-similar fractal F with open set condition and similarity ratio r with N pieces, the topological Krull dimension `topKrullDim F` is finite and satisfies `topKrullDim F ≤ ⌈log(N)/log(1/r)⌉`.

The key insight is that the iterated function system structure gives a recursive decomposition of the open set lattice, bounding chain lengths by the recursion depth times the branching factor.

**Why now?** The product dimension bounds (`topKrullDim_le_prod_left/right`) show that our framework handles dimensional products correctly. Extending to quotients would require formalizing IFS quotient constructions and their open set lattices.

## 3. Spectral Dimension of the Open Set Frame

The lattice of open sets of a topological space is a frame (complete Heyting algebra). The spectrum of a frame is a sober space. The dimension of the spectrum of Opens(X) should recover information about X.

**Conjecture**: For a sober space X, the topological Krull dimension of X equals the Krull dimension of the spectrum of the frame Opens(X) (i.e., `topKrullDim X = topKrullDim (Spec(Opens(X)))`).

The key insight is that for sober spaces, the unit of the adjunction between Top and Frames is an isomorphism, so X ≅ Spec(Opens(X)) and the result follows from `topKrullDim_eq_of_homeo`. For non-sober spaces, the soberification could introduce new open sets that increase chain length.

**Why now?** Mathlib has developing locale/frame theory. The opensEquivSet result for discrete spaces suggests that frame-theoretic properties of Opens(X) are tractable in Lean. Formalizing the Spec construction for frames would unlock a rich connection to algebraic geometry (where Krull dimension of rings connects to dimension of schemes via Spec).

## 4. Dimension and Continuous Maps Between Non-Homeomorphic Spaces

Our `topKrullDim_le_of_openEmbedding` shows that open embeddings give dimension inequalities. For general continuous surjections, the relationship is more subtle — the dimension can go up or down.

**Conjecture**: If f : X → Y is a continuous closed surjection with fibers of topological Krull dimension ≤ k, then `topKrullDim X ≤ topKrullDim Y + k + 1` (a "fiber dimension formula" analogous to the one for algebraic varieties).

The key insight is that a chain of open sets in X can be projected to Y, but the fibers contribute at most k additional levels of nesting. This would generalize the product bound (where projection has constant fibers).

**Why now?** The open embedding monotonicity and product bounds provide the base cases. The fiber dimension formula would bridge to algebraic geometry's dimension theory of morphisms, connecting our topological Krull dimension to the scheme-theoretic Krull dimension via the Zariski topology.

## 5. Computability of Topological Krull Dimension for Finite Spaces

For finite topological spaces (equivalently, finite preorders), the topological Krull dimension is computable — it equals the length of the longest chain in the specialization preorder. This connects to combinatorial topology and finite topological data analysis.

**Conjecture**: For a finite T₀ space X with n points, `topKrullDim X` equals the height of the specialization order (longest chain minus 1), and this can be computed in O(n²) time. Moreover, the dimension determines the homotopy type of the associated simplicial complex up to the (dim+1)-skeleton.

The key insight is that for finite spaces, Opens(X) is isomorphic to the lattice of downsets of the specialization preorder, and the Krull dimension of a finite distributive lattice equals the height of its poset of join-irreducibles (by Birkhoff's representation theorem).

**Why now?** The `topKrullDim_discrete` result shows that for discrete (= antichain) finite spaces, the dimension matches the power set lattice dimension. Extending to general finite topologies would connect to the active area of computational topology using finite models, and the decidability would allow `#eval`-based verification of examples.
