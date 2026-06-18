# Future Research Directions

## Synthesis

This research cycle established a rigorous formal foundation for the theory of k-automatic sequences: DFAO formalization with generic Fintype state spaces, the decidability reduction for value membership, product and map constructions for algebraic closure, a complete proof of Thue-Morse non-periodicity via period halving, k-kernel closure under subsequence extraction, and exponential growth of uniform morphism iterates.

The most promising cross-domain connection emerging from this cycle is the bridge between automata theory and algebraic structure theory. The periodicity-to-recurrence bridge theorem (eventually periodic sequences satisfy shift recurrences) is a first step, but the deeper connection runs through Christol's theorem: over finite fields, k-automaticity is equivalent to algebraicity of the generating function. Formalizing Christol's theorem would connect our DFAO framework to the algebraic geometry infrastructure already in Mathlib, potentially enabling computational algebraic geometry techniques for automatic sequence problems.

The highest breakthrough potential lies in Direction 1 (Cobham's theorem), which would establish a fundamental rigidity result: if a sequence is simultaneously k-automatic and ℓ-automatic for multiplicatively independent k and ℓ, it must be eventually periodic. This is one of the deepest results in automatic sequence theory and would open the door to formalizing the complete Cobham-Semenov hierarchy.

---

### Direction 1: Cobham's Theorem — Multiplicative Independence Rigidity

**Conjecture**: If a sequence (aₙ) is both k-automatic and ℓ-automatic, where k and ℓ are multiplicatively independent (no integers p, q > 0 with kᵖ = ℓᵍ), then (aₙ) is eventually periodic.

**Test**: Construct explicit examples of sequences that are k-automatic for a specific k and verify they fail to be ℓ-automatic for multiplicatively independent ℓ. Specifically: verify computationally that the Thue-Morse sequence (2-automatic) is not 3-automatic by showing its 3-kernel grows without bound up to exponent 10.

**Impact**: Cobham's theorem is one of the cornerstones of automatic sequence theory. A formal proof would establish the deepest known rigidity result for this class and would enable formalizing the full Cobham-Semenov theorem (the first-order definability version).

**Catalog References**: `Algebra/AutomaticSequences.lean` (DFAO, IsKAutomatic, kKernel, thueMorse_not_eventually_periodic)

**Proof Strategy**: The standard proof (due to Cobham 1972, simplified by Durand 2011) proceeds as follows:
1. Show that a k-automatic sequence that is also ℓ-automatic has syndetic kernel (kernel elements appear with bounded gaps).
2. Use multiplicative independence to show that the set of positions where k-kernel and ℓ-kernel elements agree becomes dense.
3. Conclude eventual periodicity from density and finiteness of both kernels.
Key lemma to formalize: for multiplicatively independent k, ℓ, the set {kᵃ · ℓᵇ : a, b ∈ ℕ} is dense in the positive reals (follows from the irrationality of log(k)/log(ℓ)).

**Domain Bridges**: Automata Theory ↔ Number Theory (multiplicative independence, logarithmic density) ↔ Algebra (eventually periodic sequences, shift recurrences from `eventually_periodic_implies_recurrence`)

**Lineage**: Builds on `thueMorse_not_eventually_periodic` (proving the contrapositive: Thue-Morse is not eventually periodic, hence cannot be both 2-automatic and 3-automatic by Cobham).

**Ambition**: grand_challenge

---

### Direction 2: Christol's Theorem — Algebraicity ↔ Automaticity over Finite Fields

**Conjecture**: A formal power series f(x) = Σ aₙxⁿ over 𝔽_p is algebraic over 𝔽_p(x) if and only if the coefficient sequence (aₙ) is p-automatic.

**Test**: Verify Christol's theorem computationally for the Thue-Morse series over 𝔽₂: confirm that f(x) = Σ t(n)xⁿ satisfies f² + f + x/(1+x)² = 0 in 𝔽₂[[x]] (check agreement of coefficients up to degree 1000). Then formalize the easier direction (p-automatic ⟹ algebraic) using the Cartier operator.

**Impact**: Christol's theorem is the deepest structural result about automatic sequences, connecting automata theory to algebraic geometry. A formalization would create a bridge between the DFAO framework and Mathlib's algebraic geometry infrastructure (polynomial rings, formal power series, algebraic closure).

**Catalog References**: `Algebra/AutomaticSequences.lean` (DFAO, kKernel, IsKAutomatic), Mathlib's `PowerSeries`, `Polynomial`, `ZMod`

**Proof Strategy**:
1. Define the Cartier operator Λₚ on 𝔽_p[[x]]: Λₚ(f)(x) = coefficient of xᵖⁿ⁺ʲ extracted appropriately.
2. Show that the p-kernel of the coefficient sequence corresponds to the orbit of f under Λₚ.
3. (Automatic ⟹ algebraic): Finite kernel ⟹ finite-dimensional vector space of Cartier iterates ⟹ linear dependence ⟹ polynomial relation ⟹ algebraicity.
4. (Algebraic ⟹ automatic): Use the fact that algebraic power series over 𝔽_p satisfy Frobenius equations, which correspond to finite automaton constraints.

**Domain Bridges**: Automata Theory ↔ Algebraic Geometry (formal power series, algebraicity) ↔ Number Theory (Frobenius endomorphism, p-adic analysis)

**Lineage**: Builds on DFAO framework and kKernel closure theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Morphic Decidability — Beyond Uniform Morphisms

**Conjecture**: The zero-in-sequence problem for morphic sequences generated by non-uniform morphisms is decidable. Specifically: given a morphism σ on alphabet {0, ..., k-1} (not necessarily k-uniform), a starting letter a on which σ is prolongable, and a target letter b, it is decidable whether b appears in the fixed point σ^ω(a).

**Test**: Implement a decision procedure for the Fibonacci morphism (0 → 01, 1 → 0) and verify that every letter in {0, 1} appears in the fixed point. Then test on 1000 random non-uniform morphisms over alphabets of size 3-5 with image lengths 1-4, comparing BFS-based heuristic with brute-force search up to 10⁶ iterations.

**Impact**: This is one of the most important open questions in the intersection of automata theory and combinatorics on words. Resolving it (in either direction) would have significant implications for decidability theory and would clarify the exact boundary between decidable and undecidable in sequence theory.

**Catalog References**: `Algebra/AutomaticSequences.lean` (AlphabetMorphism, IsProlongable, MorphicDecidabilityConjecture)

**Proof Strategy**: For the positive direction, a potential approach:
1. Show that the set of letters appearing in σ^ω(a) equals the set of letters reachable in the "letter dependency graph" (directed graph where i → j if j appears in σ(i)).
2. For prolongable morphisms, show that reachability in this graph is decidable (finite graph).
3. The key difficulty is showing that this graph captures exactly the letters in the fixed point — this fails for general morphisms because some letters might be "swallowed" by faster-growing images.

**Domain Bridges**: Automata Theory ↔ Graph Theory (reachability in finite directed graphs) ↔ Combinatorics on Words (fixed points of morphisms)

**Lineage**: Builds on AlphabetMorphism and MorphicDecidabilityConjecture from this cycle, and on `iterate_length_uniform` (uniform case is known decidable).

**Ambition**: extension

---

### Direction 4: Quantitative Kernel Bounds and Minimization

**Conjecture**: For any k-automatic sequence generated by a DFAO with n states, the k-kernel has at most n distinct elements. Moreover, the minimal DFAO is unique up to isomorphism and can be computed in O(n² · k) time.

**Test**: Compute the k-kernel of 100 random DFAOs with 2-20 states and verify that the kernel size never exceeds the number of states. Then implement Myhill-Nerode minimization for DFAOs and verify that minimized DFAOs produce the same sequence.

**Impact**: A formal proof of the kernel bound would establish the tight connection between DFAO state complexity and kernel complexity, and would enable efficient comparison of automatic sequences (two sequences are equal iff their minimal DFAOs are isomorphic).

**Catalog References**: `Algebra/AutomaticSequences.lean` (kKernel, kKernel_closed, DFAO, DFAO.product_eval)

**Proof Strategy**:
1. For each kernel element (n ↦ seq(k^e · n + r)), associate a state: the state reached by the DFAO on the base-k representation of r.
2. Show that two kernel elements with the same associated state are identical sequences.
3. Since there are at most n states, there are at most n distinct kernel elements.
4. For minimization, adapt the Myhill-Nerode theorem: define equivalence of states by output equivalence on all continuations, and show the quotient DFAO is minimal.

**Domain Bridges**: Automata Theory ↔ Algebra (quotient structures, equivalence relations) ↔ Complexity Theory (state complexity, minimization algorithms)

**Lineage**: Builds on kKernel, kKernel_closed, and DFAO framework from this cycle.

**Ambition**: extension

---

### Direction 5: Subword Complexity of Automatic Sequences

**Conjecture**: Every k-automatic sequence has subword complexity p(n) = O(n). More precisely, the number of distinct factors (subwords) of length n in a k-automatic sequence is at most C · n for some constant C depending on the DFAO.

**Test**: Compute the subword complexity function p(n) for the Thue-Morse sequence for n = 1..100 and verify p(n) = 2n + 2 for n ≥ 1 (known result of Brlek 1989). Then compute p(n) for 50 random 2-automatic sequences and verify linear growth.

**Impact**: Subword complexity is a fundamental measure of the "disorder" of a sequence. The linear bound for automatic sequences sits between eventually periodic sequences (bounded complexity) and random sequences (exponential complexity), making automatic sequences the prototypical "medium complexity" class.

**Catalog References**: `Algebra/AutomaticSequences.lean` (DFAO, thueMorse, kKernel)

**Proof Strategy**:
1. Define subword complexity: p(n) = |{seq[i..i+n] : i ≥ 0}| (number of distinct factors of length n).
2. Show that each factor of length n corresponds to a pair (state, suffix), where the state is determined by the prefix and the suffix has length n.
3. Since there are at most |σ| states, p(n) ≤ |σ| · k^n... this is too weak. The correct approach uses the kernel structure.
4. Alternative: use the morphic characterization. For a k-uniform morphism with alphabet size m, each iterate multiplies the number of factors by at most m, giving p(n) ≤ C · n.

**Domain Bridges**: Automata Theory ↔ Combinatorics on Words (subword complexity) ↔ Dynamical Systems (topological entropy, symbolic dynamics)

**Lineage**: Builds on DFAO framework, thueMorse, and kernel theory from this cycle. Connects to `thueMorse_not_eventually_periodic` (non-periodicity implies p(n) → ∞, but the linear bound is much stronger).

**Ambition**: extension
