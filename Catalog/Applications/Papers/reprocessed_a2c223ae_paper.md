# Summary of changes for run 8da44027-791c-473f-a5b6-23eb9b6d0be2
## Investigation Complete: The Conjecture is FALSE

I conducted a thorough investigation of the conjecture that tropRank(M_n) = Ω(n) for the Berggren tree matrix construction. The conjecture is **decisively false**, with n = 4 as the smallest counterexample (with nonempty S(n)).

### Files Created

1. **`Bridges/BerggrenTropicalRank.lean`** — Formal machine-verified disproof (compiles with zero `sorry`):
   - Defines the three Berggren matrices A, B, C over ℤ
   - **`pyth_leg_4_unique`**: Proves that if a² + 16 = c² with a > 0, then a = 3, c = 5
   - **`unique_ppt_with_leg_4`**: Any primitive Pythagorean triple with 4 as a leg is (3,4,5) or (4,3,5)
   - **`conjecture_false_at_4`**: For ANY function tropRank satisfying tropRank(k) ≤ k (the basic row bound), tropRank(1) ≠ Ω(4) = 2. Since S(4) has exactly one element, M_4 has 1 row, making the conjecture impossible.
   - Verified additional counterexamples: n = 9 (|S| = 1, Ω = 2), n = 105 (|S| = 4, Ω = 3)
   - Extensive documentation of the true relationship

2. **`Bridges/BerggrenTropicalRankComputation.lean`** — Computational exploration (compiles clean):
   - Enumerates all primitive Pythagorean triples with n as a leg for n ≤ 1000
   - Finds 32 counterexamples where |S(n)| < Ω(n) just in [2, 100]
   - Finds counterexamples in both directions (|S| < Ω AND |S| > Ω)
   - **Key statistic**: Of 749 values with S(n) ≠ ∅ in [2, 1000], only 417 (55.7%) match Ω(n)
   - Computationally verifies the correct formula |S(n)| = 2^(ω(n)-1) for all odd squarefree n ≤ 300

3. **`Bridges/BERGGREN_TROPICAL_REPORT.md`** — Comprehensive research report

### Why the Conjecture Fails

Three independent structural reasons:

1. **Wrong counting function**: For odd n, |S(n)| = 2^(ω(n)-1) where ω counts *distinct* primes, not Ω which counts with multiplicity. The conjecture coincidentally works for primes (both = 1) and semiprimes (both = 2), but diverges exponentially for ω ≥ 3.

2. **Prime powers are invisible**: For n = p^a (a ≥ 2), |S(n)| = 1 regardless of a, because the coprimality condition in primitive triples forces all powers of p to one factor. So Ω(p^a) = a but |S(p^a)| = 1.

3. **Dimensional obstruction**: Tropical rank ≤ min(rows, cols). Since M_n has at most 9 columns (flattened 3×3 matrices) or 3 columns (triples), tropRank is capped at 9 (or 3) regardless of Ω(n).

### What Relationship Does Hold

The Berggren tree genuinely encodes information about the *squarefree kernel* of factorization through ω(n), but is structurally blind to prime multiplicities. This is a fundamental limitation, not a gap in the proof.