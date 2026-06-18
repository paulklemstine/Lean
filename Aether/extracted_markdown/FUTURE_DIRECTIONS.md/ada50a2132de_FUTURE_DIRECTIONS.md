# Future Directions: Belnap Bilattices and Paraconsistent Reasoning

## 1. Product Bilattices and the 2ⁿ-valued Generalization

Belnap's FOUR₂ is isomorphic to Bool × Bool, where the first component tracks "told true" and the second tracks "told false." This generalizes: with n independent information sources, we obtain a 2ⁿ-valued bilattice isomorphic to Boolⁿ. The key insight is that these product bilattices inherit interlacing from their factors, and our verified proof that negation is simultaneously a truth-antitone involution and a knowledge-monotone lattice homomorphism should lift to the product setting via componentwise operations. Why now? The `DistribLattice` instance and the bilattice interaction theorems (`tInf_kLE_monotone_left`, `bneg_kInf_hom`) in our formalization provide the exact template for a `Fintype`-parametric construction using `Pi.instDistribLattice` from Mathlib.

**Conjecture**: For any n ≥ 2, the product bilattice Boolⁿ with componentwise truth and knowledge orderings is an interlaced distributive bilattice, and its consistent fragment (elements with no component equal to (true, true)) forms a sub-bilattice if and only if n ≤ 2.

## 2. Non-Monotone Fixed Points and Stable Extensions

Our `consistent_consequence_nonmonotone` theorem shows that consistent credulous consequence fails monotonicity. Classical fixed-point theorems (Knaster-Tarski, Kleene) require monotonicity, so paraconsistent reasoning needs different tools. The key insight is that while the consistent consequence operator has no least or greatest fixed point in general, its fixed points — the "stable extensions" — form an antichain in the subset ordering, and the number of such stable extensions is constrained by the lattice structure of the underlying bilattice. Why now? Our formalization provides the definitional infrastructure (`BelnapConsistent`, `BelnapSatisfies`, `ConsistentCredulousTruth`) needed to state and prove fixed-point theorems, and Mathlib's Zorn's lemma infrastructure can be applied to maximal consistent chains.

**Conjecture**: For any finite knowledge base over Belnap valuations containing at least one contradictory assignment, the number of maximal consistent extensions is either 0 or at least 2. That is, contradictions always destroy uniqueness of consistent reasoning.

## 3. Dream Distance as a Quasi-Metric

The non-idempotent closure operators arising from Belnap's logic (where iterating "one step of reasoning" discovers new consequences) define a natural quasi-metric: d(x, S) = min{n | x is derivable from S in n steps}. The key insight is that this "dream distance" satisfies d(x, S) ≤ d(x, cl(S)) + 1 — a weakened triangle inequality where the second argument is always a closure — and that this quasi-metric's topology recovers the pretopological structure we formalized. Why now? The verified `DistribLattice` instances provide the algebraic backbone, and Mathlib's `PseudoMetricSpace` and `UniformSpace` APIs could formalize convergence of iterated belief revision.

**Conjecture**: For any extensive closure operator cl on a finite set, cl is idempotent (i.e., defines a genuine topology) if and only if the dream distance function takes values only in {0, 1, ∞}.

## 4. Paraconsistent Type Theory via Belnap-Valued Propositions

In homotopy type theory, propositions are types with at most one element (h-propositions). The key insight is that replacing the proposition classifier Ω (a subobject of the universe) with FOUR₂ yields a "paraconsistent type theory" where the internal logic validates p ∧ ¬p for some p (namely the B-valued propositions), but the theory remains non-trivial because B ⊓ B = B ≠ ⊥. Our verified De Morgan laws (`bneg_deMorgan_inf`, `bneg_deMorgan_sup`) and the proof that negation preserves knowledge ordering (`bneg_kLE_monotone`) are exactly the coherence conditions needed for a well-behaved internal logic. Why now? Mathlib has extensive category theory infrastructure, and our `DistribLattice` instance makes FOUR₂ immediately usable as a truth-value object in categorical logic constructions.

**Conjecture**: There exists a locally cartesian closed category whose subobject classifier is (isomorphic to) FOUR₂ equipped with the truth ordering, and whose internal logic is exactly Belnap's FDE (first-degree entailment).

## 5. Computational Complexity of Consistent Satisfiability

Our `ConsistentCredulousTruth` predicate asks: does there exist a *consistent* Belnap valuation satisfying a knowledge base? The key insight is that unrestricted Belnap satisfiability is trivially polynomial (take the knowledge-join of all constraints), but the consistency requirement (no variable assigned B) transforms it into an NP-complete problem reducible from NAE-SAT (Not-All-Equal Satisfiability). Why now? The formalized definitions provide exact specifications for a verified reduction, and Lean 4's `Decidable` instances make the complexity-theoretic distinction between "any satisfying valuation" (decidable in polynomial time) and "consistent satisfying valuation" (NP-complete) formally expressible.

**Conjecture**: The problem "given a finite set of (variable, value) constraints, does a consistent Belnap valuation satisfying all constraints exist?" is NP-complete, even when each variable appears in at most 3 constraints.
