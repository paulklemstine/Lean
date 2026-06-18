# Future Directions: Dream Logic and Paraconsistent Reasoning

## 1. N-valued Paraconsistent Lattices and Their Topological Duals

Belnap's FOUR₂ is the smallest non-trivial paraconsistent bilattice. A natural generalization is the family of 2^n-valued bilattices arising from n independent "information sources," each contributing a classical truth value. The key insight is that these n-source bilattices are isomorphic to products of 2-element lattices, and their consistent fragments should correspond to (n-1)-dimensional simplicial complexes rather than pretopological spaces. Why now? The formalization of FOUR₂ as a `DistribLattice` in this work provides the template for a `Fintype`-parametric construction, and Mathlib's existing simplicial complex API could immediately support the topological side.

Conjecture: For n ≥ 3, the consistent fragment of the 2^n-valued bilattice has a pretopological closure whose iterated application stabilizes in exactly ⌈log₂ n⌉ steps (the "dream depth" of the logic).

## 2. Paraconsistent Fixed Points and Non-Monotone Induction

Classical fixed-point theorems (Knaster-Tarski, Kleene) rely on monotonicity of the operator. Our `nonmonotonicity` theorem shows that consistent credulous consequence is non-monotone, but it still has fixed points — they are just not unique or lattice-theoretic. The key insight is that the set of "stable extensions" of a paraconsistent knowledge base (analogous to Reiter's stable extensions in default logic) can be characterized as the fixed points of a non-monotone operator on the powerset of Belnap valuations, and these form an antichain in the subset ordering. Why now? Mathlib has extensive fixed-point infrastructure (`OrderHom.lfp`, `OrderHom.gfp`) that could be adapted to characterize the structure of these non-monotone fixed points via Zorn's lemma applied to consistent chains.

Conjecture: For any finite knowledge base over Belnap valuations, the number of maximal consistent extensions is either 0 or at least 2 (there is no unique consistent extension when contradictions are present).

## 3. Categorical Semantics: Paraconsistent Topoi

A topos is a category whose internal logic is intuitionistic. Our work shows that paraconsistent logics break explosion, which is valid in any topos. The key insight is that replacing the subobject classifier Ω (a Heyting algebra) with a "paraconsistent classifier" (a De Morgan algebra that is NOT a Heyting algebra) should yield a category where the internal logic is paraconsistent — a "paraconsistent topos." The existence of such categories would give a categorical foundation for dream-like reasoning. Why now? Mathlib has extensive topos infrastructure, and our `Belnap` type with its `DistribLattice` and `neg` involution provides a concrete candidate for the non-Heyting classifier.

Conjecture: There exists a finitely complete category with a Belnap-valued subobject classifier that satisfies all topos axioms except the requirement that Ω be a Heyting algebra, and whose internal logic validates `p ∧ ¬p ≠ ⊥` for some internal proposition p.

## 4. Metric Dream Spaces and Convergence of Belief Revision

Our pretopology `graphPretopology` is non-idempotent, meaning iterated closure discovers new elements. This suggests a natural metric: the "dream distance" d(x, S) = min{n | x ∈ cl^n(S)} measures how many reasoning steps are needed to reach conclusion x from premises S. The key insight is that this dream distance satisfies a weakened triangle inequality (d(x, S) ≤ d(x, cl(S)) + 1 rather than d(x, S) ≤ d(x, T) + d(T, S)) and defines a quasi-metric space whose Cauchy sequences correspond to convergent belief revision processes. Why now? The formalized `graphPretopology` and `graph_not_topology` provide a concrete playground, and Mathlib's `PseudoMetricSpace` infrastructure could be leveraged to study convergence properties.

Conjecture: For any extensive monotone closure operator cl on a countable set, the dream distance defines a quasi-metric whose completion is a compact topological space (the "dream compactification"), and cl is idempotent if and only if the dream distance takes values in {0, 1, ∞}.

## 5. Computational Complexity of Paraconsistent Reasoning

The `consistentlyTrue` predicate asks whether a consistent valuation exists satisfying given constraints — this is a constraint satisfaction problem. The key insight is that the four-valued structure of Belnap makes this problem intermediate between 2-SAT (polynomial) and 3-SAT (NP-complete): checking whether a knowledge base has ANY satisfying Belnap valuation is polynomial (just take the join of all constraints), but checking whether it has a CONSISTENT satisfying valuation is NP-complete (it reduces to NAE-SAT). Why now? The formalization of `satisfiesKB` and `consistentlyTrue` provides the definitional infrastructure, and Lean 4's computational reduction capabilities could enable verified complexity-theoretic reductions.

Conjecture: The problem "given a finite knowledge base kb and variable x, is consistentlyTrue kb x?" is NP-complete, and remains NP-complete even when restricted to knowledge bases where each variable appears in at most 3 constraints.
