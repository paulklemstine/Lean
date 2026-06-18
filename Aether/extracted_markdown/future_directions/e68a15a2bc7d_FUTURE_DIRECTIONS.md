# Future Directions: Taxicab Numbers and Cube Decomposition Theory

## Synthesis

This research cycle established a concrete bridge between two-cube and three-cube representations through the Three-Cube Inversion Principle: if c³ - n = a³ + b³, then n = (-a)³ + (-b)³ + c³. Applied to 1729, this principle explains *why* the nontrivial representation (-7)³ + (-5)³ + 13³ = 1729 exists — the overshoot 13³ - 1729 = 468 = 7³ + 5³ is itself a sum of two cubes. The prime factorization 1729 = 7 · 13 · 19 participates in all cube decompositions, with factors appearing as cube bases, algebraic components, and Korselt divisors simultaneously.

The most promising cross-domain connection is between the inversion principle and the density theory of sums of three cubes. The classical conjecture (supported by extensive computation) is that every admissible integer (not ≡ 4, 5 mod 9) has a three-cube representation. The inversion principle offers a *constructive* approach: rather than searching the full three-dimensional space of triples, one can systematically search for overshoots c³ - n that happen to be sums of two cubes. This connects the three-cube problem to the well-studied density of sums of two cubes, which is known to be Θ(N^{2/3} / √(log N)) up to N.

The connection to Carmichael numbers (1729 - 1 = 12³ satisfies Korselt's criterion) suggests a deeper investigation of when n - 1 being a perfect cube interacts with the cube decomposition structure of n itself.

---

### Direction 1: Inversion-Accessible Density

**Conjecture**: The density of integers n ≤ N that have at least one "inversion-accessible" three-cube representation (i.e., there exists c with c³ - n = a³ + b³ for positive a, b) is Ω(N^{2/3} / √(log N)). Specifically, the set of n that are inversion-accessible should have positive lower density within the admissible integers (those not ≡ 4, 5 mod 9).

**Test**: For N = 10⁶, compute the number of n ≤ N such that there exists c ≤ N^{1/3} + N^{1/3} with c³ - n a sum of two positive cubes. Compare this count to N^{2/3} / √(log N). If the ratio stabilizes, the conjecture gains evidence; if it decays to 0, the conjecture is refuted.

**Impact**: If true, this would provide a constructive lower bound on the density of integers representable as sums of three cubes, complementing the probabilistic heuristics of Heath-Brown. If false, it would demonstrate that the inversion principle captures only a thin subset of three-cube representations, and most representations require genuinely three-dimensional search.

**Catalog References**: `Algebra/CubeResidues.lean`, `MachineLearning/NumberTheory/SumThreeCubes/Basic.lean`

**Proof Strategy**: First, establish that the set of sums of two positive cubes up to M has cardinality Θ(M^{2/3} / √(log M)) (a classical result of Hooley). Then, for each such sum S = a³ + b³, the numbers n = c³ - S for various c contribute to the inversion-accessible set. Counting these contributions requires sieve methods to handle overlaps. The key lemma would be: for most sums S of two cubes, there exist Ω(S^{1/3}) values of c with c³ - S in [1, N].

**Domain Bridges**: Number Theory (density of cube sums) ↔ Analytic Number Theory (sieve methods) ↔ Computational Mathematics (large-scale enumeration)

**Lineage**: Builds on this cycle's inversion principle formalization and the existing `SumThreeCubesRep` infrastructure.

**Ambition**: grand_challenge

---

### Direction 2: Prime Factor Participation in Cube Decompositions

**Conjecture**: For every taxicab number n = p₁ · p₂ · ... · pₖ (with all primes ≡ 1 mod 6), at least one prime factor of n appears as the absolute value of a component in some nontrivial three-cube representation of n. Formally: if n has taxicab order ≥ 2 and all prime factors are ≡ 1 (mod 6), then there exist x, y, z with x³ + y³ + z³ = n, xyz ≠ 0, and some pᵢ divides xyz.

**Test**: Check the next several taxicab numbers: 4104 = 2³ · 3³ · 19 (fails the mod-6 condition), 13832 = 2³ · 1729, 20683 = 23 · 29 · 31. For each, find nontrivial three-cube representations and check prime factor participation. The conjecture predicts participation for numbers with all primes ≡ 1 mod 6; failures for other numbers would help refine the condition.

**Impact**: If true, this would reveal a deep connection between multiplicative structure (prime factorization) and additive structure (cube decompositions) that goes beyond the known results. It would suggest that taxicab numbers have a "rigid" cube decomposition structure controlled by their factorization.

**Catalog References**: `MachineLearning/NumberTheory/Taxicab/Basic.lean` (taxicab_factorization, three_cube_1729_computation)

**Proof Strategy**: Start with computational verification for all taxicab numbers up to 10⁶. For the theoretical direction, use the algebraic identity a³ + b³ = (a+b)(a²-ab+b²) to connect two-cube factorizations to the prime structure. The inversion principle then transfers this to three-cube representations. The key difficulty is showing that the overshoot c³ - n factors in a way that forces prime factor involvement.

**Domain Bridges**: Algebraic Number Theory (factorization in ℤ[ω]) ↔ Diophantine Geometry (rational points on cubic surfaces) ↔ Computational Number Theory (enumeration)

**Lineage**: Directly extends this cycle's observation that 7 and 13 appear in (-7)³ + (-5)³ + 13³ = 1729 = 7 · 13 · 19.

**Ambition**: grand_challenge

---

### Direction 3: Carmichael-Taxicab Intersection

**Conjecture**: There are only finitely many numbers that are simultaneously Carmichael numbers and taxicab numbers. Specifically, 1729 is the only number that is both a Carmichael number and the smallest sum of two cubes in two ways.

**Test**: Enumerate Carmichael numbers up to 10⁹ and check which have at least 2 representations as sums of two positive cubes. If any are found beyond 1729, the uniqueness conjecture is refuted. If none are found in this range, it provides computational support.

**Impact**: If 1729 is unique in this intersection, it would explain why this particular number has attracted so much attention — it sits at the confluence of two rare properties. If there are others, it would open a new family of arithmetically distinguished numbers with rich structure.

**Catalog References**: `MachineLearning/NumberTheory/Taxicab/Basic.lean` (korselt_1729, carmichael_cube_connection)

**Proof Strategy**: For the finiteness direction: Carmichael numbers with k prime factors grow at least as C · (log n)^{k-1}, while the density of taxicab numbers among integers up to N is O(N^{2/3} / log N). Show that these growth rates are incompatible for large n. For the infiniteness direction (to refute): construct parametric families using the theory of Carmichael numbers with prescribed factorization patterns.

**Domain Bridges**: Analytic Number Theory (Carmichael number density) ↔ Additive Number Theory (Waring's problem for cubes) ↔ Algebraic Number Theory (norms in cubic fields)

**Lineage**: Builds on this cycle's Korselt verification and the connection 1729 - 1 = 12³.

**Ambition**: extension

---

### Direction 4: Generalized Inversion and Higher-Dimensional Cube Representations

**Conjecture**: Every admissible integer n (not ≡ 4, 5 mod 9) has a representation as a sum of four cubes where all cubes are nonzero and at most one is positive. That is, n = (-a)³ + (-b)³ + (-c)³ + d³ for positive a, b, c, d. This "deep overshoot" principle would reduce four-cube representations to three-cube decompositions of overshoots.

**Test**: For n = 33 (which was only recently shown to be a sum of three cubes: 33 = 8866128975287528³ + (-8778405442862239)³ + (-2736111468807040)³), check whether 33 has a four-cube representation with three negative cubes and one positive cube, with cubes of absolute value ≤ 10⁶. More tractably, verify the conjecture for all admissible n ≤ 1000.

**Impact**: If true, this would provide a hierarchical decomposition: k-cube representations reduce to (k-1)-cube decompositions of overshoots, giving a recursive structure to the general Waring problem for cubes. This could lead to new constructive proofs of cube representability.

**Catalog References**: `MachineLearning/NumberTheory/SumThreeCubes/Basic.lean` (SumThreeCubesRep, cube_is_sum_of_three_cubes)

**Proof Strategy**: Formalize the generalized inversion principle: if d³ - n = a³ + b³ + c³ (sum of three positive cubes), then n = (-a)³ + (-b)³ + (-c)³ + d³. Show that for any n, the set {d³ - n : d ∈ ℤ₊} contains a positive sum of three cubes by combining known density results for sums of three cubes with the distribution of c³ - n values.

**Domain Bridges**: Waring's Problem (k-cube representations) ↔ Recursive Decomposition (inversion towers) ↔ Density Theory (how often overshoots decompose)

**Lineage**: Directly generalizes this cycle's inversion principle from two-cube overshoots to three-cube overshoots.

**Ambition**: extension

---

### Direction 5: Taxicab Numbers and Representation by Binary Cubic Forms

**Conjecture**: Every taxicab number n with all prime factors ≡ 1 (mod 6) is representable by the binary cubic form x³ + y³ in at least two essentially different ways over ℤ[ω] (where ω = e^{2πi/3}), and the number of representations is controlled by the class number of ℚ(∛n).

**Test**: For the known taxicab numbers 1729, 4104, 13832, 20683, ..., compute the factorization in ℤ[ω] and count the essentially distinct representations. Verify whether the count matches predictions from the class group of the relevant cubic field.

**Impact**: This would connect the elementary number-theoretic property (taxicab) to deep algebraic number theory (class groups of cubic fields), potentially explaining why taxicab numbers are rare and predicting their distribution.

**Catalog References**: `Algebra/CubeResidues.lean`, `Cryptography/BerggrenDiophantineLattice.lean`

**Proof Strategy**: Use the factorization a³ + b³ = (a + b)(a + ωb)(a + ω²b) in ℤ[ω] to translate two-cube representations into ideal factorizations. The number of essentially distinct factorizations is related to the class number. Formalize the connection between ideal class groups and representation counts.

**Domain Bridges**: Algebraic Number Theory (Eisenstein integers ℤ[ω]) ↔ Class Field Theory (class numbers of cubic fields) ↔ Additive Combinatorics (representation functions)

**Lineage**: Builds on this cycle's algebraic factorization analysis (cube_sum_factor, taxicab_factor_rep1/2).

**Ambition**: grand_challenge
