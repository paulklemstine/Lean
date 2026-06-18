# Future Directions: MPS Min-Cut Principle

## Conjecture 1: Tree Tensor Network Subtree-Cut Principle

**Statement.** For a tree tensor network state on a tree graph T with n leaves, the integrated information rank (minimum flattening rank over all nontrivial bipartitions of the leaves) equals the minimum bond dimension over all single-edge cuts of T. Equivalently, the minimum is always achieved by a bipartition induced by removing a single edge of the tree.

**Test.** Generate random tree tensor network states on binary trees with 8–16 leaves and bond dimensions in {2, 3, 4, 5}. For each instance, enumerate all 2^n − 2 nontrivial bipartitions, compute flattening ranks, and compare the global minimum with the minimum over the n−1 single-edge cuts of the tree. A single instance where a non-tree-edge bipartition achieves strictly smaller rank falsifies the conjecture.

**Impact.** If true, this would generalize the 1D min-cut principle to all tree tensor networks, establishing that tree-structured entanglement is always controlled by local (edge) bottlenecks. This would have immediate applications to MERA (multi-scale entanglement renormalization ansatz) and hierarchical tensor decompositions in machine learning.

---

## Conjecture 2: PEPS Min-Cut Obstruction

**Statement.** For 2D Projected Entangled Pair States (PEPS) on an m × m square lattice, the min-cut principle *fails* generically: there exist bond-generic PEPS states for which the minimum flattening rank over all bipartitions is strictly less than the minimum single-edge-cut bond dimension. Moreover, the failure ratio grows polynomially in m.

**Test.** Construct random PEPS on 3×3 and 4×4 grids with uniform bond dimension D ∈ {2, 3}. Compute flattening ranks for all nontrivial bipartitions (feasible for small grids) and compare with single-edge cuts. If the minimum over all bipartitions equals the minimum edge bond dimension for all instances, the conjecture is falsified. If failures are found, measure the failure ratio min_bipartition/min_edge and check for polynomial growth in m.

**Impact.** This would sharply delineate which tensor network geometries admit min-cut principles (trees and paths) from those that don't (grids and higher-dimensional structures). This has direct implications for understanding why PEPS simulation is computationally harder than MPS simulation.

---

## Conjecture 3: Quantitative Strictness Gap for Noncontiguous Cuts

**Statement.** For a bond-generic MPS on n sites with uniform bond dimension D, every noncontiguous bipartition S satisfies flatRank(ψ, S) ≥ D², where D is the minimum bond dimension. That is, noncontiguous cuts are not just as good as contiguous cuts — they are *quadratically worse*, because they cross at least two edges and the rank factorizes multiplicatively through both bonds.

**Test.** Generate random MPS with n = 6, d = 3, uniform D ∈ {2, 3, 4} across all internal bonds. For each noncontiguous bipartition S (which crosses at least 2 edges), compute flatRank(ψ, S) and check whether it is ≥ D². Run 1000 trials per configuration. A single instance with flatRank(ψ, S) < D² for a noncontiguous S falsifies the conjecture.

**Impact.** If true, this would provide a quantitative separation between contiguous and noncontiguous entanglement on chains, suggesting that 1D quantum states have a much richer entanglement hierarchy than the simple min-cut principle indicates. This connects to tensor rank lower bounds in algebraic complexity theory.

---

## Conjecture 4: Min-Cut Principle for Causal Graphical Models

**Statement.** The min-cut principle extends beyond quantum states to classical causal models. For any Bayesian network structured as a chain X₁ → X₂ → ⋯ → Xₙ, the "integrated information" (minimum mutual information across all bipartitions) equals the minimum single-bond mutual information I(Xₖ; Xₖ₊₁). The chain's Markov structure forces all correlations through sequential bonds, analogous to the MPS bond structure.

**Test.** Sample random conditional probability tables for chain-structured Bayesian networks with n = 5–8 nodes and |Xᵢ| ∈ {2, 3, 4}. Compute mutual information I(X_S; X_{S^c}) for all nontrivial bipartitions S and compare the minimum with min_k I(Xₖ; Xₖ₊₁). Numerical equality (within tolerance) confirms; a strict gap falsifies.

**Impact.** This would establish a bridge between quantum entanglement theory and classical information theory / causal inference. It would show that the min-cut principle is not a quantum phenomenon but a *structural* consequence of chain topology, with applications to information integration in neuroscience (IIT) and network coding.

---

## Conjecture 5: Formal Verification of the Transfer Matrix Rank Equality

**Statement.** For an MPS in left-canonical form up to bond k, the flattening rank across the prefix cut {0, …, k−1} equals exactly the bond dimension D_k. This requires formalizing the transfer matrix formalism in Lean 4: defining left-canonical MPS, showing that the transfer matrix from the left block has full column rank, and concluding that the flattening matrix has rank D_k.

**Test.** Formalize the definition of left-canonical MPS tensors (each A_i satisfies Σ_s A_i^s† A_i^s = I) in Lean 4. State the theorem flatRank(ψ, {0,…,k-1}) = D_k under the left-canonical hypothesis. Attempt to prove it using Mathlib's linear algebra API. Success = a sorry-free proof compiles. Failure = identification of specific missing Mathlib infrastructure.

**Impact.** This would complete the formal verification of the full MPS min-cut principle with equality (not just inequality). Combined with the existing combinatorial proofs, it would give a completely machine-verified theorem connecting quantum entanglement, tensor rank, and graph combinatorics — the first such result in the formal verification literature.
