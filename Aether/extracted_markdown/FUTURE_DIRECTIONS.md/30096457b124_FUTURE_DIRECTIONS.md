# Future Directions: Proof-Theoretic Symbolic Dynamics

## What Was Accomplished

We have formally verified (in Lean 4, with zero `sorry`) the following foundational results:

1. **Walk-Counting Theorem**: The (i,j)-entry of the n-th power of an adjacency matrix counts walks of length n from i to j.
2. **Trace Formula for Closed Walks**: The trace of A^n counts closed walks (cyclic chains) of length n.
3. **Cayley-Hamilton Trace Recurrence**: For any matrix A over a commutative ring, the sequence n ↦ trace(A^n) satisfies a linear recurrence of order at most the matrix dimension, with explicit coefficients given by the characteristic polynomial.
4. **CA Transfer Matrix Linear Recurrence**: For any nearest-neighbor CA, spacetime strip counts (as traces of the transfer matrix) satisfy a linear recurrence, establishing rationality of the strip-counting zeta function.
5. **Additive CA Transfer Relation**: The transfer compatibility for additive CA over finite fields unfolds to a system of linear constraints.

---

## Hypothesis 1: Uniform Aperiodicity for Permutative CA

**Conjecture**: For every right-permutative nearest-neighbor CA rule f over a finite alphabet α, and every height h ≥ 1, the syntactic monoid of the spacetime column language `spacetimeColumnLanguage f h` is aperiodic (contains no nontrivial subgroups).

**Equivalently**: The spacetime column language is star-free, and hence definable in first-order logic with order (FO[<]).

**Test Protocol**:
1. For all binary radius-1 right-permutative rules (there are exactly 48), compute the minimal DFA recognizing the column language for heights h = 2, 3, 4, 5.
2. Compute the syntactic monoid of each language via the transition monoid of the minimal DFA.
3. Check aperiodicity: verify that for every element m of the monoid, m^k = m^{k+1} for some k ≤ |monoid|.
4. A single nontrivial group element in any syntactic monoid would refute the conjecture.

**Impact**: If true, this would establish that permutative CA spacetime languages lie in the lowest complexity class within regular languages. This connects CA dynamics to the Schützenberger-McNaughton-Papert hierarchy and implies that spacetime realizability can be checked by counter-free automata—a profound constraint on the computational structure of reversible CA.

---

## Hypothesis 2: Cyclotomic Period Divisibility for Additive CA

**Conjecture**: For additive CA over GF(p) with characteristic polynomial P(U) = aU^{-1} + b + cU, and fixed iteration count m, the sequence n ↦ log_p |Fix(T^m on (GF(p))^n)| is eventually periodic with period dividing lcm(ord(ζ) : P(ζ)^m = 1 in some extension of GF(p)).

More precisely: the eventual period divides lcm of the multiplicative orders of all roots of irreducible factors of P(X)^m - 1 in GF(p)[X] (after clearing the Laurent denominator).

**Test Protocol**:
1. For p = 2, 3, 5 and small coefficient triples (a, b, c), compute the fixed-point dimension sequence dim ker(T^m - I) for n = 1 to 100 and m = 1 to 5.
2. Factor the polynomial Q(X) = (aX^{-1} + b + cX)^m · X^m - X^m in GF(p)[X] and identify its roots.
3. Compute the lcm of root orders and verify it divides the observed eventual period.
4. A counterexample would require the actual period to not divide the predicted period.

**Impact**: This would give an explicit arithmetic formula for the periodicity of fixed-point counts, reducing a dynamical question to finite-field factorization. It would complete the bridge between CA dynamics and algebraic number theory over finite fields, and provide the basis for efficient algorithms computing fixed-point counts for arbitrarily large ring sizes.

---

## Hypothesis 3: Sofic Spacetime Equivalence

**Conjecture**: A one-dimensional nearest-neighbor CA over a finite alphabet has sofic spacetime subshift if and only if for every height h, the column language is recognized by an automaton whose state count is at most C^h for some constant C depending only on the alphabet size.

**Converse direction refinement**: If the state complexity of the height-h column language automaton grows faster than exponentially in h (e.g., doubly exponential), then the spacetime subshift is not sofic.

**Test Protocol**:
1. For all 256 elementary CA rules, compute the minimal DFA for column languages at heights h = 2, 3, 4, 5, 6.
2. Record the number of states in each minimal DFA.
3. Fit growth curves: exponential C^h vs superexponential.
4. For rules known to have sofic spacetime (e.g., additive, permutative), verify exponential growth.
5. Search for nonlinear rules where growth is superexponential—these are candidates for non-sofic spacetime.

**Impact**: This would provide the first computationally testable criterion for soficity of CA spacetime, resolving a fundamental question in symbolic dynamics. It would also give a rigorous meaning to the informal notion that "complex" CA have "complex" spacetime structure.

---

## Hypothesis 4: Zeta Rigidity — Polynomial Recurrence Order Implies Soficity

**Conjecture**: If for every height h, the cyclic strip-counting sequence n ↦ trace(A_h^n) satisfies a linear recurrence whose order is bounded by poly(|α|^h), then the spacetime subshift of the CA is sofic.

**Stronger form**: The recurrence order for height h is bounded by |α|^{O(h)} for sofic spacetime, but grows as |α|^{Ω(h²)} or worse for non-sofic spacetime.

**Test Protocol**:
1. Use the Berlekamp-Massey algorithm to find the minimal-order linear recurrence for trace sequences at various heights.
2. For additive/permutative rules (known sofic): verify order is |α|^{O(h)}.
3. For "complex" rules (Rule 30, Rule 110): test whether the minimal recurrence order grows faster.
4. Plot log(recurrence order) vs h to distinguish polynomial from superpolynomial growth in log(order).

**Impact**: This would establish zeta function rationality degree as a computable invariant that detects soficity. It would connect spectral properties of transfer matrices to topological dynamics, creating a quantitative bridge between linear algebra and symbolic dynamics.

---

## Hypothesis 5: FO-Definability Threshold for Binary CA

**Conjecture**: For binary (alphabet {0,1}) radius-1 CA, the following are equivalent:
1. Every fixed-height strip language is star-free.
2. The CA rule is topologically conjugate to a one-sided permutative rule.
3. The transition monoid of the minimal DFA for height-h strips is aperiodic for all h.

**Refinement**: Among the 256 elementary CA rules, exactly those that are conjugate to left- or right-permutative rules have uniformly star-free strip languages.

**Test Protocol**:
1. Exhaustive computation: for all 256 elementary CA rules and heights h = 2, 3, 4, 5:
   - Build the minimal DFA for the strip language.
   - Compute the syntactic monoid.
   - Test aperiodicity.
2. Classify rules into: (a) uniformly aperiodic, (b) aperiodic up to tested heights but unknown, (c) provably non-aperiodic.
3. Cross-reference with the known classification of permutative elementary rules.
4. Any rule that is non-permutative but has uniformly aperiodic monoids would expand the conjecture; any permutative rule with a non-aperiodic monoid would refute it.

**Impact**: This would give a complete logical-complexity classification of binary CA spacetime, connecting dynamical reversibility to descriptive complexity. It would be the first result establishing that a dynamical property (permutativity) is equivalent to a logical property (first-order definability) for an infinite family of constrained systems.

---

## Prioritized Execution Plan

1. **Immediate (next cycle)**: Hypothesis 2 is the most testable—write GF(p) polynomial factorization code and verify the period formula for p = 2, 3 and all coefficient triples with |a|, |b|, |c| ≤ p-1.

2. **Short-term**: Hypothesis 5 computation—enumerate all 256 elementary rules and compute syntactic monoids for h ≤ 5. This is finite and deterministic.

3. **Medium-term**: Hypothesis 1 proof—if the computation for Hypothesis 5 supports the conjecture, formalize the proof that right-permutativity implies aperiodicity of the syntactic monoid.

4. **Long-term**: Hypothesis 3 and 4—these require either new mathematical ideas or computational evidence from a broader class of CA rules.

---

## Key Technical Dependencies

- **Syntactic monoid computation**: Implement efficient transition monoid algorithms for DFAs with up to ~10^6 states.
- **GF(p) polynomial arithmetic**: Factor polynomials over GF(p) for p up to 7.
- **Sofic shift theory**: Formalize the definition of sofic subshift in Lean 4 and prove basic properties.
- **Minimal DFA construction**: Implement Hopcroft's algorithm for large alphabets (column alphabets can have |α|^h symbols).
