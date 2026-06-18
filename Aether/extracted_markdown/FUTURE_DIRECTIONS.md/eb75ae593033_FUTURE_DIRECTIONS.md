# Future Directions: The Teaching Dimension Bridge

## Synthesis

The Teaching Dimension Bridge opens a systematic connection between three mathematical domains that were previously studied in isolation: circuit complexity (sandwich certificates), computational learning theory (teaching dimension, VC-dimension), and combinatorial optimization (hitting sets, transversals). The central theorem — that every teaching set is a hitting set, yielding minHit ≤ TD — was formalized and machine-verified, along with eleven additional theorems establishing the structural properties of hitting sets and their relationship to learning-theoretic quantities.

The directions below build outward from this foundation in three ways: (1) resolving the monotone certificate conjecture that naturally emerges from the bridge, (2) exploiting the SAT encoding to compute certificates that exceed human capability, and (3) extending the bridge to non-monotone circuits and geometric structures. Each direction is falsifiable, computationally testable, and connected to specific catalog theorems.

---

## Direction 1: Monotone Certificate Gap Bound (Revised from Falsified Conjecture)

**Original Conjecture (FALSIFIED):** For monotone concept classes, minHit = teachingDim. **Disproven:** computational experiments show that for monotone threshold functions with target = all false, minHit = 1 but teachingDim = n for n ≥ 2.

**Revised Conjecture:** For monotone concept classes of size m, the gap satisfies teachingDim - minHit ≤ O(log m). That is, the separation cost grows at most logarithmically in the class size.

**Test:** Enumerate all monotone Boolean functions on Fin n for n = 3, 4, 5, 6. For each choice of target function t, compute both minHittingSetCard and teachingDim by brute force. If they differ for any instance, the conjecture is falsified. For n = 6 there are 7,828,354 monotone functions (Dedekind number), so the test requires restricting to representative subclasses (threshold functions, edge-inclusion functions).

**Impact:** If true, this collapses two distinct notions of certificate complexity into one, massively simplifying the theory. If false, the counterexample reveals structural information about how monotone functions organize that is invisible to both communities separately.

**Catalog References:**
- `Pythagorean/TeachingDimensionBridge.lean` — `teachingDim_ge_minHittingSetCard`, `monotoneCertificateConjecture`
- `Pythagorean/SandwichDefs.lean` — `MonoCircuitProfile`, `CertifiedSandwichFamily`

**Proof Strategy:** For the positive direction, show that any minimum hitting set for a monotone class automatically separates all concept pairs. The key lemma would be: if two monotone functions f, g agree on a minimum hitting set S but differ at some point x, then removing an element of S and adding x preserves the hitting property while reducing the number of agreement pairs — contradicting minimality.

**Domain Bridges:** Learning Theory × Order Theory × Circuit Complexity

**Lineage:** Extends `teachingDim_ge_minHittingSetCard` and `monotoneCertificateConjecture` from the current work.

**Ambition:** Solid extension — directly builds on the core theorem with a clear proof strategy.

---

## Direction 2: SAT-Computed Circuit Lower Bounds

**Conjecture:** For triangle detection on n = 10 vertices, the minimum complete sandwich family has size ≤ 50, and a SAT solver can find it within 24 hours of compute time.

**Test:** Implement the SAT encoding of the minimum transversal problem for the circuit-refutation hypergraph on 10 vertices. Use iterative deepening: solve for k = 1, 2, ..., 50 until satisfiable. Use a state-of-the-art SAT solver (CaDiCaL, Kissat). Record: (1) the minimum k for which the formula is satisfiable, (2) the running time, (3) the structure of the optimal certificate. If the solver times out at k = 50, the conjecture is falsified (either the minimum is larger or the problem is computationally harder than predicted).

**Impact:** This would produce the first computationally-discovered circuit lower bound certificates beyond hand-constructed examples. It would demonstrate that the SAT reduction is practically useful, not just theoretically interesting.

**Catalog References:**
- `Pythagorean/SandwichGraph.lean` — `verify_sandwich_complete_of_finite_check`, `triangle_sandwich_equivalence`
- `Pythagorean/SandwichTheorems.lean` — `sandwich_is_transversal`

**Proof Strategy:** The SAT encoding uses variables x_G for each graph G on n vertices, completeness clauses (one per circuit), and a sequential counter for the cardinality bound. Correctness follows from the bijection between satisfying assignments and valid sandwich families. The main engineering challenge is handling the 2^(n choose 2) = 2^45 potential graphs efficiently, likely requiring symmetry-breaking constraints.

**Domain Bridges:** Circuit Complexity × SAT Solving × Combinatorial Optimization

**Lineage:** Builds on `hitting_set_empty_iff`, `exists_hitting_set_of_card_le`, and the SAT encoding in `algorithms.py`.

**Ambition:** Grand challenge — computational discovery of new mathematical results.

---

## Direction 3: VC-Dimension Tightness for Circuit-Refutation Hypergraphs

**Conjecture:** The VC-dimension of the circuit-refutation hypergraph for circuits of size ≤ s on n vertices is Θ(s log s), not O(s).

**Test:** For n = 5, 6, 7 and s = 2, 3, ..., 10, compute the VC-dimension of the circuit-refutation hypergraph exactly (by brute-force shattering check). Plot VCdim vs s log s. If the growth is linear in s (not s log s), the conjecture is falsified. If the growth matches s log s (with constant factor between 0.5 and 5), the conjecture is supported.

**Impact:** Resolving the tightness of the s log s bound would determine whether the Sauer-Shelah-based certificate size bounds are essentially optimal or can be improved. An O(s) VC-dimension would imply polynomially better certificate bounds.

**Catalog References:**
- `Pythagorean/TeachingDimensionBridge.lean` — `IsShattered`, `shattered_subset`
- `Pythagorean/SandwichGraph.lean` — `hasTriangleMono`, `graphInstPreorder`

**Proof Strategy:** Lower bound: construct an explicit set of O(s log s) graphs that is shattered by circuits of size ≤ s. This requires showing that for each labeling, there exists a circuit of size ≤ s matching that labeling. Upper bound: use the bit-counting argument (circuits of size s described by O(s log s) bits).

**Domain Bridges:** Circuit Complexity × Combinatorics × Information Theory

**Lineage:** Extends `shattered_realizes_all_subsets` and the VC-dimension definition.

**Ambition:** Grand challenge — resolves an open question about circuit families.

---

## Direction 4: Greedy Approximation for Monotone Circuit Certificates

**Conjecture:** For monotone circuit classes, the greedy hitting set algorithm achieves a 2-approximation (not just O(ln n)).

**Test:** For n = 3, 4, 5 and various circuit size bounds s, compute both the greedy hitting set size and the optimal hitting set size. Compute the ratio greedy/optimal. If the ratio ever exceeds 2.0 for any instance, the conjecture is falsified. If it stays below 2.0 for all tested instances, the conjecture is supported.

**Impact:** A constant-factor approximation would make the greedy algorithm practical for large instances where exact optimization is intractable. The factor 2 would be tight with LP-based rounding for upward-closed set families.

**Catalog References:**
- `Pythagorean/TeachingDimensionBridge.lean` — `exists_hitting_set_of_card_le`, `hitting_set_superset`
- `Pythagorean/SandwichTheorems.lean` — `completeness_mono_certificate`

**Proof Strategy:** Use LP duality. The LP relaxation of the hitting set ILP has a dual that corresponds to fractional packing of hyperedges. For upward-closed families (monotone circuits), show that the LP relaxation has half-integrality, which yields a 2-approximation via rounding. The key lemma is that upward-closed hypergraphs are "ideal" in the polyhedral sense.

**Domain Bridges:** Combinatorial Optimization × Polyhedral Theory × Circuit Complexity

**Lineage:** Extends the greedy bound `exists_hitting_set_of_card_le`.

**Ambition:** Solid extension — well-defined mathematical problem with clear proof approach.

---

## Direction 5: SAT Threshold and the Circuit Lower Bound Frontier

**Conjecture:** The satisfiability threshold of the SAT encoding Φ_{n,s,k} (satisfiable iff a sandwich family of size ≤ k exists) exhibits a sharp phase transition at k = k*(n,s), and k*(n,s) = Θ(s · log(n choose 2 / s)) for the triangle detection problem.

**Test:** For n = 5, 6 and s = 3, 4, ..., 8, use binary search on k to find the threshold k* where the SAT formula transitions from unsatisfiable to satisfiable. Plot k* as a function of s and compare to the predicted functional form. If k* grows faster than s log(n²/s), the conjecture is falsified.

**Impact:** A precise formula for the certificate threshold would quantify exactly how much "evidence" is needed to prove a circuit lower bound. The connection to random SAT phase transitions could import statistical mechanics tools into circuit complexity.

**Catalog References:**
- `Pythagorean/SandwichGraph.lean` — `triangle_lower_bound_from_sandwich`
- `Pythagorean/TeachingDimensionBridge.lean` — `minHittingSetCard_le_card`

**Proof Strategy:** The lower bound on k* uses information-theoretic arguments: log₂|C_s| bits of information are needed to refute all circuits. The upper bound uses the probabilistic method: a random set of the predicted size is a hitting set with positive probability.

**Domain Bridges:** Statistical Physics × Information Theory × Circuit Complexity × SAT Solving

**Lineage:** Connects the SAT encoding correctness to phase transition theory.

**Ambition:** Grand challenge — paradigm-shifting if the phase transition structure is confirmed.
