# Future Directions: Formal Extremal Geometry

## Hypothesis 1: Exact ES(6) Certification via Order Types

**Conjecture**: A complete enumeration of all realizable rank-3 order types on 17 points, combined with automated cup/cap extraction, can produce a machine-checked proof that ES(6) = 17.

**Test**: Formalize the order-type encoding for finite planar point sets in Lean 4. Enumerate all abstract order types on 16 points (using existing databases) and verify that at least one avoids convex hexagons. Then verify that every order type on 17 points contains a convex 6-gon. The cup/cap infrastructure developed here provides the extraction machinery; what remains is the enumeration and case analysis.

**Impact**: This would be the first fully machine-verified exact value of ES(n) for n ≥ 5, establishing a paradigm for certified extremal combinatorics. The case n = 6 was settled by Szekeres and Peters (2006) using exhaustive computation, but their proof has never been formally verified.

## Hypothesis 2: Oriented-Matroid Lift of the Cups-Caps Theorem

**Conjecture**: The cups-caps counting theorem (Theorem B in our formalization) depends only on rank-3 chirotope axioms and therefore extends to all realizable uniform oriented matroids without Euclidean coordinates.

**Test**: Replace the `orient` function over ℝ × ℝ with an abstract sign oracle `χ : Fin m → Fin m → Fin m → SignType` satisfying the chirotope axioms (antisymmetry, Grassmann–Plücker). Re-prove the cup_all_triples_positive theorem in this abstract setting. If successful, the entire cups-caps bound follows for pseudoline arrangements, not just point configurations.

**Impact**: This would create the first formal bridge between computational geometry and combinatorial topology in a proof assistant. It directly enables formalization of the Folkman–Lawrence topological representation theorem and opens the path to machine-checked proofs about arrangement complexity.

## Hypothesis 3: Witness-Producing Algorithm with O(n²) Complexity

**Conjecture**: The dynamic programming approach underlying the cups-caps proof can be refined into a certified algorithm that, given n points in general position with m ≥ C(2n−4, n−2) + 1, extracts an n-cup, n-cap, or convex n-gon in O(m²) time with a proof certificate.

**Test**: Implement the DP labeling (inc_label, dec_label for each point) as a computable Lean function. Verify that the extraction procedure (following predecessor pointers) produces a valid cup or cap witness. Benchmark against brute-force search on random rational point configurations up to m = 100.

**Impact**: This transforms the existence theorem into a certified extraction algorithm — a key step toward formal computational geometry. The proof certificate can be independently verified, enabling trustworthy geometric computation in safety-critical applications.

## Hypothesis 4: Tight Bounds via the Suk Improvement

**Conjecture**: The Suk (2017) improvement ES(n) ≤ 2^(n+O(n^{2/3} log n)) can be formalized using the same orientation infrastructure, replacing the binomial counting argument with a probabilistic partitioning technique.

**Test**: Formalize Suk's "island" lemma — that any sufficiently large point set contains a large "island" (subset whose convex hull is disjoint from the rest). Prove the recursive bound using this structural lemma. The orientation predicates and convex position definitions from our formalization transfer directly.

**Impact**: This would be a landmark in formal combinatorics — the first machine-checked proof of a result that significantly improves a 80-year-old bound. It would demonstrate that modern combinatorial techniques (not just classical ones) are within reach of formal verification.

## Hypothesis 5: Empty Convex Polygon Threshold

**Conjecture**: The cups-caps infrastructure, augmented with an "emptiness" predicate, can yield a certified existence theorem for empty convex pentagons under cardinality assumptions strictly weaker than the Harborth bound.

**Test**: Define `EmptyConvexPosition p s` requiring that no point of p lies in the interior of the convex hull of the chosen subset. Formalize the Harborth (1978) argument that every set of 10 points in general position contains an empty convex pentagon. The orientation predicates developed here directly express the emptiness condition (a point q is inside triangle abc iff orient(a,b,q), orient(b,c,q), orient(c,a,q) all have the same sign).

**Impact**: The empty convex polygon problem (Erdős–Szekeres variant) is one of the most active areas in discrete geometry. A formal proof of even the pentagon case would be the first machine-checked result in this direction, opening the path toward the celebrated Nicolás–Gerken theorem (empty convex hexagons exist in every sufficiently large point set).
