# Future Directions: Taxicab Numbers and Sums of Three Cubes

## Synthesis

This research cycle established a bridge between the taxicab number theory and the sums-of-three-cubes problem by discovering and formally verifying that 1729 = (−5)³ + (−7)³ + 13³. The key insight is that the three-cube representation is completely disjoint from both two-cube representations ({−5,−7,13} ∩ {1,9,10,12} = ∅), suggesting that the "cube structure" of a number can decompose into independent representational layers. The connection to Carmichael numbers (1729 = 7 × 13 × 19, with 13 appearing in both the factorization and the three-cube witness) opens a potential bridge between pseudoprimality and additive number theory.

The most promising cross-domain connection is between the Korselt criterion for Carmichael numbers and cube-sum representability. Since Korselt's criterion requires (p−1) | (n−1) for each prime factor p of n, and since for 1729 we have n−1 = 1728 = 12³, the cube structure of n−1 may constrain or enable three-cube representations of n. This direction has the highest breakthrough potential because Carmichael numbers are well-studied from a pseudoprimality perspective but their additive-combinatorial properties are almost unexplored.

The formalization infrastructure (definitions of `CubeTripleWitness`, `TaxicabOrder`, the general `cube_summand_triple_bound`) provides a reusable toolkit for future investigations of any taxicab or three-cube problem.

---

### Direction 1: Three-Cube Representations of All Taxicab Numbers

**Conjecture**: Every taxicab number Ta(2) — an integer with at least two essentially distinct representations as a sum of two positive cubes — also has a nontrivial representation as a sum of three nonzero integer cubes.

**Test**: Compute three-cube representations for Ta(2) values: 4104 = 2³ + 16³ = 9³ + 15³, 13832 = 2³ + 24³ = 18³ + 20³, 20683, 32832, 39312, 40033. For each, search for (x, y, z) with xyz ≠ 0 and x³ + y³ + z³ = n within |x|, |y|, |z| ≤ 1000. If any Ta(2) number fails, examine whether it is ≡ 4 or 5 (mod 9) — if so, the conjecture needs refinement.

**Impact**: If true, this establishes taxicab numbers as a natural infinite family within the representable set for three cubes, providing structural examples for the Mordell conjecture (every n ≢ 4,5 mod 9 is representable). If false, the counterexample would identify a rare arithmetic obstruction beyond the mod-9 condition.

**Catalog References**: `Computation/TaxicabThreeCubes.lean` (three_cube_rep_1729, no_positive_three_cube_1729), `Algebra/SumThreeCubes/Defs.lean` (SumThreeCubesRep, OnCubicSurface)

**Proof Strategy**: For each candidate n = Ta(2), first verify n ≢ 4,5 (mod 9). Then use the bounded search with x ≤ ∛(n/3) for the smallest summand. Formalize the solutions as `CubeTripleWitness n` structures. If the search fails for some n, attempt to prove non-representability using local obstructions from `Algebra/SumThreeCubes/LocalObstruction.lean`.

**Domain Bridges**: Number Theory (taxicab classification) ↔ Diophantine Geometry (cubic surface theory) ↔ Computation (bounded search algorithms)

**Lineage**: Builds on three_cube_rep_1729 and the CubeTripleWitness definition from this cycle.

**Ambition**: extension

---

### Direction 2: Carmichael Numbers as Sums of Three Cubes

**Conjecture**: Every Carmichael number C with C ≢ 4, 5 (mod 9) has a nontrivial representation as a sum of three nonzero integer cubes, and moreover at least one summand is a prime factor of C.

**Test**: The first few Carmichael numbers are 561, 1105, 1729, 2465, 2821, 6601, 8911. Check: 561 = 3 × 11 × 17 (561 mod 9 = 3, admissible). Search for x³ + y³ + z³ = 561. For 1729, we already have (−5, −7, 13) where 13 | 1729. Check whether this "factor-as-summand" pattern extends to other Carmichael numbers.

**Impact**: If the factor-as-summand property holds, it would reveal a deep structural connection between the multiplicative properties of Carmichael numbers (pseudoprimality, Korselt's criterion) and their additive cube structure. This would be entirely new territory — no existing literature connects Carmichael numbers to sums of three cubes.

**Catalog References**: `Computation/TaxicabThreeCubes.lean` (taxicab_factorization, taxicab_korselt, three_cube_witness_1729), `Algebra/CubeResidues.lean` (sum_three_cubes_not_four_five_mod_nine)

**Proof Strategy**: First establish that Carmichael numbers satisfy C ≡ 1 (mod p−1) for smallest prime factor p, so C ≡ 1 (mod lcm of (p−1) values). Check admissibility mod 9. For the factor-as-summand claim, set z = p (a prime factor of C) and solve x³ + y³ = C − p³ — this reduces to a two-variable cubic Diophantine equation, analyzable via elliptic curves. Use Mordell-Weil to count rational points on x³ + y³ = C − p³.

**Domain Bridges**: Number Theory (Carmichael pseudoprimes) ↔ Additive Combinatorics (three-cube problem) ↔ Algebraic Geometry (elliptic curves over ℚ)

**Lineage**: Builds on taxicab_korselt and the Carmichael–cube observation from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Near-Miss Cascades and the Geometry of x³ + y³ + z³ = n

**Conjecture**: For n = a³ + 1 (where a is a positive integer), the number of near-misses (triples (x,y,z) where |x³ + y³ + z³ − n| = 1 and max(|x|,|y|,|z|) ≤ 2a) grows at least linearly in a.

**Test**: For a = 12 (n = 1729), we found 3 near-misses of the form (−k, 12, z) with gap 1. For a = 6 (n = 217), a = 10 (n = 1001), a = 20 (n = 8001), count near-misses within the search bound and plot growth rate.

**Impact**: If true, this would provide a quantitative explanation for why numbers of the form a³ + 1 are "easy" targets for three-cube representations — the density of near-misses creates a statistical likelihood of an exact hit. This connects to the heuristic arguments of Heath-Brown about the expected number of representations.

**Catalog References**: `Computation/TaxicabThreeCubes.lean` (euler_cube_identity, three_cube_from_taxicab), `Algebra/SumThreeCubes/ParametricFamilies.lean`

**Proof Strategy**: The near-misses for n = a³ + 1 arise because n − (−k)³ − a³ = 1 + k³, which is exactly one more than a cube. Count the number of k values with 1 ≤ k ≤ a. This is exactly a−1 near-misses (for k = 1, ..., a−1), giving linear growth in a trivially. The deeper question is whether non-trivial near-misses (not from this family) also grow.

**Domain Bridges**: Number Theory (Diophantine approximation) ↔ Geometry (lattice points near cubic surfaces) ↔ Computation (efficient enumeration)

**Lineage**: Builds on the near-miss pattern observed for 1729 in Section 4.2 of the research paper.

**Ambition**: extension

---

### Direction 4: Tropical Geometry of Three-Cube Surfaces

**Conjecture**: The tropical variety of the cubic surface x³ + y³ + z³ = n (viewed over the tropical semiring) has a combinatorial structure that predicts the number of integer solutions within a given search bound up to a bounded multiplicative constant.

**Test**: Compute the tropicalization of x³ + y³ + z³ = 1729 and compare its combinatorial type (number of vertices, edges, and faces of the tropical surface) with the number of integer solutions found by brute-force search within |x|, |y|, |z| ≤ 100. Repeat for n = 33, 42, 4104. Check if the ratio (solutions found)/(tropical complexity) is bounded.

**Impact**: This would provide the first bridge between tropical algebraic geometry and the computational difficulty of the three-cube problem. Tropical methods have been successful in enumerative algebraic geometry but have never been applied to Diophantine problems over ℤ. If the tropical complexity predicts solution counts, it could guide more efficient search algorithms.

**Catalog References**: `Tropical/` (existing tropical semiring infrastructure), `Algebra/SumThreeCubes/LocalGlobal.lean` (local-global framework)

**Proof Strategy**: Define the tropicalization of x³ + y³ + z³ = n as the locus where the minimum of {3v(x), 3v(y), 3v(z)} is achieved at least twice (where v is the valuation). Classify the combinatorial types for different n. Use the Kapranov theorem (tropical varieties as limits of amoebae) to relate the tropical structure to the distribution of integer points.

**Domain Bridges**: Tropical Geometry ↔ Number Theory (three-cube problem) ↔ Computation (search algorithm design)

**Lineage**: New direction inspired by the rich tropical infrastructure in the Catalog and the three-cube problem from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Diophantine Complexity of Taxicab Certificates

**Conjecture**: The bit-length of the smallest nontrivial three-cube representation of a taxicab number Ta(2) = n grows at most polynomially in log(n), specifically O(log²(n)).

**Test**: For each known Ta(2) value up to 10⁶, find the smallest (by max absolute value of coordinates) nontrivial three-cube representation and record log₂(max(|x|,|y|,|z|)) vs log₂(n). Fit a polynomial and check the degree.

**Impact**: If true, this gives an upper bound on the computational difficulty of finding three-cube certificates for taxicab numbers, suggesting that taxicab structure provides "leverage" for the three-cube problem. If false, it would mean that some taxicab numbers require exponentially large coordinates in their three-cube representations, connecting to the surprising difficulty seen for n = 33 and n = 42.

**Catalog References**: `Computation/TaxicabThreeCubes.lean` (cube_summand_triple_bound), `Algebra/SumThreeCubes/Symmetry.lean`

**Proof Strategy**: Use the elliptic curve parametrization: for each z, the curve x³ + y³ = n − z³ has a group structure via Mordell-Weil. The height of the smallest rational point on this curve gives the coordinate bound. If the rank of the curve is positive (which can be checked via BSD heuristics), the Silverman height bound gives polynomial growth. Formalize the height bound using Mathlib's elliptic curve library.

**Domain Bridges**: Computational Complexity ↔ Number Theory (Diophantine certificates) ↔ Algebraic Geometry (heights on elliptic curves)

**Lineage**: Builds on cube_summand_triple_bound and the computational search from this cycle.

**Ambition**: extension
