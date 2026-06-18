# Summary of changes for run d7e458ac-6eb9-43e7-8b3b-1905cbf8efa2
## Completed: Symbolic Dynamics as Proof Theory over Finite Algebraic Objects

### Formally Verified Mathematics (Zero Sorry)

Two Lean 4 files with complete machine-checked proofs:

**Direction A — `Speculative/SymbolicDynamics/CASpacetimeAperiodicity.lean`:**
- **`partialConst_iterate_three_eq_two`**: The key algebraic lemma proving that any partial constant function f satisfies f³ = f². This is the aperiodicity condition with uniform exponent bound 2.
- **`partialConst_sq_idempotent`**: f² is idempotent for partial constant functions.
- **`IsAperiodicMonoid.of_surjective`**: Quotients of aperiodic monoids are aperiodic, connecting DFA transition monoids to syntactic monoids.
- **`RightPermutative.existsUnique_right`**: Right-permutative operations have unique solutions.
- **`SpacetimeCompatible.right_determined_of_rightPermutative`**: Compatible columns are uniquely determined except at the last position.
- **Key insight**: The transition monoid of ANY nearest-neighbor CA spacetime column language is aperiodic (m³ = m² for all elements), because each transition function is a partial constant function. By Schützenberger's theorem, this implies every CA spacetime column language is star-free and FO[<]-definable. This is universal — no assumptions on the local rule are needed.

**Direction B — `Speculative/SymbolicDynamics/GCDPeriodicity.lean`:**
- **`pow_eventually_periodic`**: In any finite monoid, power sequences are eventually periodic (pigeonhole principle).
- **`exists_lt_pow_eq_pow_of_finite`**: Pigeonhole for power collisions in finite monoids.
- **`polynomial_mod_pow_eventually_periodic`**: X^n mod Q is eventually periodic over finite fields.
- **`EuclideanDomain.gcd_eq_of_mod_eq'`**: GCD depends only on residue class.
- **`gcd_Xpow_sub_one_eventually_periodic`**: For any nonzero Q over GF(p), gcd(Q, X^n - 1) is eventually periodic in n.
- **`natDegree_gcd_Xpow_sub_one_eventually_periodic`**: The natDegree of the GCD is eventually periodic.
- **Application**: For additive CA over GF(p), log_p|Fix(T_n^m)| is eventually periodic in n, with period controlled by multiplicative orders of roots of the local polynomial.

### Other Deliverables

- **`ARTICLE.md`**: ~2500-word popular science article about the research, written for a general audience.
- **`RESEARCH_PAPER.md`**: ~5000-word technical research paper with full theorem statements, proof sketches, computational experiments, and references.
- **`FUTURE_DIRECTIONS.md`**: Five specific falsifiable hypotheses with precise conjectures, test protocols, and refutation criteria.
- **`demo.py`**: Working demonstrations of both theorems with concrete numerical examples.
- **`algorithms.py`**: Implementations of transition monoid computation, GCD degree sequence computation, and period detection.
- **`applications.py`**: Applications to pattern recognition complexity, cyclic code design, and stream cipher analysis.
- **`PACKAGE.json`**: Valid JSON data package bundling all artifacts.