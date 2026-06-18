# Future Directions: Proof Phase Transitions

## 1. Probabilistic Sharp Threshold for Random Implicational Theories

The natural next step is to formalize the actual probabilistic phase transition. Consider the random implicational theory on `Fin n` where each directed edge is included independently with probability `p`. Our monotonicity theorem (theory_extension_monotone) establishes that derivability is a monotone increasing property in the edge set. By Friedgut's sharp threshold theorem for monotone graph properties, the probability that a fixed pair `(0, n-1)` is derivable must transition from near 0 to near 1 within a window of width `o(1)` around some critical probability `p*(n)`.

The key insight is that our `Derivable` predicate is exactly a monotone Boolean function on the Boolean hypercube `{0,1}^{n²}` (indexed by potential edges), and Friedgut's theorem applies to any such function with a coarse threshold.

Why now? We have the monotonicity infrastructure (Theorem 2) and the boundary characterizations (Theorems 1 and 3) already formalized. The remaining piece is formalizing Friedgut's theorem itself, which requires Fourier analysis on the Boolean cube — a significant but tractable formalization target that would have broad applications beyond this project.

## 2. Proof Length Phase Transitions and Resolution Complexity

A deeper conjecture concerns not just derivability but *short* derivability: is there a sharp threshold for the existence of derivations of length ≤ L(n)? Our chain_derivable theorem shows that the chain theory (with n edges) gives a derivation of length exactly n. The conjecture is that in a random theory with edge probability p, the minimum derivation length exhibits a phase transition: below p*, minimum proofs are exponentially long (or nonexistent); above p*, polynomial-length proofs exist with high probability.

The key insight is that this connects our framework to proof complexity theory. The implicational derivation system is equivalent to monotone resolution, and resolution complexity lower bounds are known for random k-CNF. Formalizing this connection would bridge combinatorial proof complexity with the random graph threshold machinery.

Why now? The chain_axiom_critical theorem already demonstrates that minimal-density theories have tight proof structure. Extending this to random theories requires formalizing the relationship between graph diameter and derivation length, which builds directly on our chain theory infrastructure.

## 3. Multi-Conclusion Theories and Hypergraph Phase Transitions

Our framework models single-conclusion implications (a → b). A natural generalization is multi-premise implications: (a₁ ∧ a₂ ∧ ... ∧ aₖ) → b, which correspond to directed hypergraphs. The derivability closure becomes k-uniform hypergraph reachability, and the phase transition behavior should depend on k in a way analogous to the k-SAT threshold phenomenon.

The key insight is that for k ≥ 2, the phase transition should become sharper (the critical window narrows as k increases), mirroring the behavior in random k-SAT where the satisfiability threshold sharpens with clause width. The barrier argument from chain_barrier_closed generalizes to hypergraph barriers, but the analysis becomes substantially more complex.

Why now? The formalized barrier technique (refl_trans_gen_closed + chain_barrier_closed) provides a template for proving non-derivability in richer settings. The generalization to hypergraphs would connect directly to random SAT thresholds, which are among the most actively studied problems in probabilistic combinatorics.

## 4. Thermodynamic Characterization of the Derivability Order

The derivability preorder on atoms, viewed as a partial order on strongly connected components, has a rich combinatorial structure. For random theories at density p, this partial order undergoes a structural phase transition: below criticality, it consists of many small antichains; above criticality, a giant "derivability class" emerges (analogous to the giant component in random graphs). The conjecture is that the entropy of the derivability partial order (measured as log of the number of linear extensions) has a non-analytic point at p*.

The key insight is that the derivability order is a random partial order whose structural properties can be analyzed using the theory of random directed graphs. The emergence of a giant strongly connected component at p = 1/n provides the underlying mechanism for the phase transition in derivability.

Why now? Our framework provides the correct abstraction layer: the ImplTheory/Derivable pair cleanly separates the "theory" (the random object) from the "consequence relation" (the derived structure). This separation is exactly what's needed to apply random graph theory to the study of random formal theories.

## 5. Axiom Criticality Index and Computational Hardness

Our chain_axiom_critical theorem shows that in minimal theories, every axiom has "criticality index" 1 (removing it breaks some derivation). For non-minimal theories, define the criticality index of an axiom as the minimum number of axioms that must be removed (including this one) before some derivation breaks. The conjecture is that for random theories at the critical density, the distribution of criticality indices follows a power law, analogous to the distribution of backbone variables in random SAT instances near the satisfiability threshold.

The key insight is that axiom criticality is the proof-theoretic analogue of the "backbone" concept in constraint satisfaction. Backbone variables are those that take the same value in all satisfying assignments; critical axioms are those that participate in all proofs. The universality of power-law behavior near phase transitions suggests this distribution should be robust across theory ensembles.

Why now? The spanning_critical generalization already provides the conceptual framework for studying criticality beyond chain theories. Formalizing the criticality index and proving basic properties (e.g., monotonicity: adding axioms can only decrease criticality indices of existing axioms) is a natural next step that extends our current infrastructure.
