# Future Directions: Parametric Families on Cubic Surfaces

## Synthesis

The formalization of the diagonal collapse family as a certified parametric family on the cubic surface X_k : x³ + y³ + z³ = k opens five interconnected research directions. Together, they trace a path from a single algebraic identity to a comprehensive formal theory connecting algebraic geometry, analytic number theory, sieve methods, and computational complexity. The unifying theme is that *verified parametric curves on arithmetic surfaces* form a new mathematical object whose properties — density, symmetry, divisibility structure, growth rates — can be studied both formally and computationally. Each direction below builds directly on the machinery established in `Algebra/SumThreeCubes/ParametricFamilies.lean` and the computational experiments in `demo.py` and `algorithms.py`.

---

## Direction 1: Asymptotic Density of Binary Cubic Value Sets

**Conjecture:** Let V(N) = #{k ∈ [1,N] : ∃ a,b ∈ ℤ, k = 3ab(a+b)}. Then V(N) ~ c·N^(2/3) for an explicit constant c > 0 computable from the S₃ orbit structure and local density corrections.

**The key insight is** that the monotonicity theorem (`diagonalCubic_lt_of_lt_of_pos`) guarantees each column of the parameter grid contributes distinct values, converting a counting problem into a lattice point geometry problem.

**Why now?** The formal proof of injectivity on positive parameters provides the first machine-verified foundation for the column-counting argument. Without this, the heuristic N^(2/3) bound remains informal.

**Test:** Compute V(N)/N^(2/3) for N = 10^4, 10^5, 10^6, 10^7 using the symmetry-reduced enumeration algorithm from `algorithms.py`. Fit the ratio with a power-law model V(N) = c·N^α and verify α ≈ 2/3 with c ≈ 0.35 ± 0.05. The conjecture is falsified if α deviates by more than 0.05 from 2/3 at scale N = 10^7.

**Impact:** A rigorous proof of V(N) ≥ c·N^(2/3) would be the first formal density theorem for a binary cubic value set, bridging lattice point counting to additive number theory. It would immediately give a constructive lower bound on the density of integers representable as sums of three cubes.

**Catalog References:** `Algebra/SumThreeCubes/ParametricFamilies.lean` — `diagonalCubic_lt_of_lt_of_pos`, `diagonalCubic_injective_right_on_pos` (monotonicity and injectivity foundations).

**Proof Strategy:** Formalize the lattice point counting argument: the map (a,b) ↦ 3ab(a+b) on [1,B]² is injective along columns by the monotonicity theorem. Count injective fibers to get V(N) ≥ B² = Ω(N^(2/3)). For the upper bound, use Fourier-analytic techniques (exponential sums over binary cubic forms).

**Domain Bridges:** Analytic number theory (exponential sum estimates), arithmetic geometry (rational point counting on varieties), combinatorics (distinct value sets of polynomial maps).

**Lineage:** Extends `diagonalCubic_lt_of_lt_of_pos` from a pointwise comparison to an asymptotic statement. Builds on the Davenport-Heilbronn tradition of counting polynomial values.

**Ambition:** Grand challenge — would resolve a question implicit in the Hooley-Wooley program on cubic forms.

---

## Direction 2: Classification of Rational Curves on X_k and New Parametric Families

**Conjecture:** The cubic surface X_k contains at least three essentially distinct families of rational curves definable over ℤ, each producing a different binary form whose value set captures a non-trivial fraction of representable integers. The union of these value sets has strictly higher density than any single family.

**The key insight is** that the `ThreeCubeParamFamily` structure provides a uniform interface: any new rational curve on X_k can be encoded as an instance, enabling automated comparison of value sets across families.

**Why now?** The `diagonalCollapseFamily` establishes the pattern — with one working instance, the framework is validated and ready for new entries. The 27-lines theorem guarantees that many more rational curves exist on cubic surfaces.

**Test:** Enumerate rational curves on X_k arising from linear sections ax + by + cz = 0 for small integer coefficients (|a|, |b|, |c| ≤ 5). For each, extract the parametric identity, compute the value set up to B = 200, and measure the size of the symmetric difference with the diagonal collapse value set.

**Impact:** Multiple certified families would transform the theory from a case study to a classification program. Each new family instantiates `ThreeCubeParamFamily` and extends the constructively representable locus.

**Catalog References:** `Algebra/SumThreeCubes/ParametricFamilies.lean` — `ThreeCubeParamFamily` (the structure to instantiate), `diagonalCollapse_from_hyperplane_section` (the geometric mechanism to generalize).

**Proof Strategy:** For each linear section ax + by + cz = 0, substitute z = −(ax+by)/c (clearing denominators), expand x³+y³+z³, and extract the resulting binary form. Verify the identity with `ring`. Prove the new family is "essentially distinct" by showing its value set contains elements not in the diagonal family.

**Domain Bridges:** Algebraic geometry (line configurations on cubic surfaces, 27 lines), computational algebra (Gröbner basis methods for curve extraction), representation theory (S₃ vs larger symmetry groups).

**Lineage:** Directly extends `diagonalCollapseFamily` to a multi-family framework. The 27-lines theorem provides the geometric ceiling.

**Ambition:** Solid extension — concrete and achievable within current infrastructure.

---

## Direction 3: Sieve-Theoretic Lower Bounds via Pairwise Coprimality

**Conjecture:** For the diagonal collapse family restricted to primitive pairs (gcd(a,b) = 1), the pairwise coprimality of a, b, a+b implies that the value F(a,b) = −3ab(a+b) has a "typical" number of prime factors equal to 3 log log N + O(√(log log N)), where N = |F(a,b)|.

**The key insight is** that the pairwise coprimality theorem (`pairwise_coprime_factors_of_isCoprime`) converts the prime factorization of F(a,b) into a direct sum of independent prime factorizations of a, b, and a+b. This transforms a single sieve problem into three independent sieve problems, making the Selberg sieve directly applicable.

**Why now?** The formal verification of pairwise coprimality provides machine-checked foundations for sieve arguments. Previous sieve-theoretic analyses of binary forms relied on unverified coprimality claims.

**Test:** For B = 500, compute the average number of distinct prime factors ω(|F(a,b)|) for primitive pairs with 1 ≤ a ≤ b ≤ B, and compare with 3 log log N. The conjecture predicts the ratio should approach 1.

**Impact:** First formal connection between certified arithmetic structure of parametric families and probabilistic number theory.

**Catalog References:** `Algebra/SumThreeCubes/ParametricFamilies.lean` — `pairwise_coprime_factors_of_isCoprime`, `prime_dvd_diagonalCubic_of_coprime`.

**Proof Strategy:** Apply the Erdős-Kac theorem separately to a, b, and a+b (each is a "random" integer in an appropriate sense). Use pairwise coprimality to conclude independence. Sum the contributions.

**Domain Bridges:** Probabilistic number theory (Erdős-Kac theorem), sieve theory (Selberg sieve for polynomial sequences), analytic number theory (prime number theorem in arithmetic progressions).

**Lineage:** Directly extends `prime_dvd_diagonalCubic_of_coprime` from a single-prime statement to a statistical claim about all prime factors.

**Ambition:** Grand challenge — connecting formal arithmetic to probabilistic number theory is novel territory.

---

## Direction 4: Complexity-Theoretic Separation of Search Strategies

**Conjecture:** The parametric family reduces the decision problem "is k representable as a sum of three cubes via the diagonal family?" from O(N^(2/3)) operations (brute force over the value set) to O(N^(1/3) log N) operations using the algebraic structure of F(a,b).

**The key insight is** that the equation k = −3ab(a+b) can be rewritten as a cubic equation in b for each fixed a, solvable in O(1) time using the cubic formula or modular arithmetic. This reduces the two-dimensional search to a one-dimensional scan over a.

**Why now?** The formal injectivity theorem (`diagonalCubic_injective_right_on_pos`) proves that the parametric search has no false positives in the positive region, validating the one-dimensional reduction.

**Test:** Implement the cubic-formula-based search and compare wall-clock times against brute-force enumeration for k up to 10^9. Measure empirical scaling exponents.

**Impact:** Establishes a formal complexity separation between structured (parametric) and unstructured (brute-force) Diophantine search, with implications for computational number theory.

**Catalog References:** `Algebra/SumThreeCubes/ParametricFamilies.lean` — `diagonalCubic_injective_right_on_pos` (validates the one-dimensional reduction), `diagonalCubic_lt_of_lt_of_pos` (enables binary search).

**Proof Strategy:** For fixed a, the equation −3ab(a+b) = k becomes 3a²b + 3ab² + k = 0, a quadratic in b solvable by the quadratic formula. Check integrality of roots. Formalize the root computation and integrality criterion.

**Domain Bridges:** Computational complexity theory (algebraic vs combinatorial search), algorithmic number theory (polynomial root finding), parameterized complexity (fixed-parameter tractability of Diophantine search).

**Lineage:** Extends the monotonicity theorems to an algorithmic speedup result.

**Ambition:** Solid extension — achievable with current tools and directly applicable.

---

## Direction 5: Local-Global Interface for Parametric Value Sets

**Conjecture:** The value set V = {−3ab(a+b) : a,b ∈ ℤ} covers all residue classes k mod m that are locally representable by F, for every modulus m coprime to 6. Equivalently, for (m, 6) = 1, the map (a,b) ↦ −3ab(a+b) mod m is surjective onto (ℤ/mℤ)*.

**The key insight is** that the S₃ symmetry and coprimality structure of F should ensure that the image of F mod m is as large as possible, analogous to the Chevalley-Warning theorem for affine varieties.

**Why now?** The formal S₃ invariance theorem (`diagonalCubic_S3_invariant`) and coprimality results provide the algebraic structure needed for modular analysis. The mod-9 obstruction (from the existing catalog) shows that local representability can fail, but the conjecture predicts this only happens at primes dividing 6.

**Test:** For each prime p ≤ 100 with p ∤ 6, compute the image of F mod p. The conjecture predicts full surjectivity. For p | 6 (p = 2, 3), identify the exact image.

**Impact:** Connects the parametric family to the local-global principle (Hasse principle) for cubic surfaces, providing a formal bridge between local obstructions and constructive representability.

**Catalog References:** `Algebra/SumThreeCubes/ParametricFamilies.lean` — `diagonalCubic_S3_invariant`, `three_dvd_diagonalCubic`. Catalog `Algebra/SumThreeCubes/LocalObstruction.lean` — mod-9 obstructions.

**Proof Strategy:** For p ∤ 6, use the fact that the map (a,b) ↦ ab(a+b) mod p is a degree-3 polynomial over 𝔽_p. By the Chevalley-Warning theorem (or direct computation), its image covers 𝔽_p*. Formalize the finite field computation.

**Domain Bridges:** Algebraic geometry (Chevalley-Warning theorem, Hasse principle), finite field combinatorics (Weil bounds on character sums), local-global arithmetic (Brauer-Manin obstruction).

**Lineage:** Connects the parametric value set analysis back to the local-global framework in the existing Catalog.

**Ambition:** Grand challenge — a formal Hasse principle analysis for polynomial value sets would be a significant advance.
