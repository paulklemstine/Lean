# Future Directions: Proto-Brauer–Manin Obstructions for Cubic Surfaces

## Synthesis

The five theorems proved in this cycle establish the cubic obstruction profile as a formally verified mathematical object that unifies congruence obstructions, adelic compatibility, and computational search complexity around the equation x³ + y³ + z³ = k. The natural next steps fall into two categories: *deepening* the obstruction theory toward genuine Brauer–Manin machinery (Directions 1–2), and *broadening* the framework to new equations, new domains, and new computational applications (Directions 3–5). All five directions are connected by the central insight that finite-level adelic conditions are both mathematically meaningful and computationally tractable — a combination that makes the three-cubes problem a uniquely fertile laboratory for formally verified arithmetic geometry.

---

## Direction 1: Chinese Remainder Factorization of the Obstruction Profile

**Conjecture:** The cubic obstruction profile factors over coprime moduli: for gcd(m, n) = 1, we have m·n ∈ 𝒪(k) if and only if m ∈ 𝒪(k) or n ∈ 𝒪(k). Equivalently, solvability modulo m·n (with m, n coprime) is equivalent to simultaneous solvability modulo m and modulo n.

**Test:** Formalize the CRT isomorphism ZMod(m·n) ≅ ZMod(m) × ZMod(n) for coprime m, n, and prove that the cubic equation decomposes accordingly. Verify computationally for all coprime pairs (m, n) with m, n ≤ 100.

**Impact:** This would reduce the obstruction profile to prime power levels, mirroring the factorization of adelic conditions by places. It transforms 𝒪(k) from an unstructured set into a product of local components — exactly the architecture of the Brauer–Manin obstruction.

**Catalog References:** `Algebra/SumThreeCubes/BrauerManin.lean` (cubic_solution_mod_downward_closed, obstruction_upward_closed)

**Proof Strategy:** Use `ZMod.chineseRemainder` from Mathlib to construct the isomorphism, then transport the cubic equation through it. The forward direction (solution mod m·n implies solutions mod m and mod n) is already proved by downward closure. The reverse direction requires constructing a joint solution via CRT.

**Domain Bridges:** Connects to signal processing (CRT-based algorithms), cryptography (CRT in RSA), and algebraic number theory (idele class groups).

**Lineage:** Direct extension of Theorems 3 and 5 from the current cycle.

**Ambition:** Solid extension — mathematically standard but formally nontrivial due to CRT type-level handling in Lean.

---

## Direction 2: Explicit Brauer Classes at the Bad Prime 3

**Conjecture:** There exists an explicit Azumaya algebra A on the cubic surface X_k whose evaluation at the 3-adic place recovers the mod 9 obstruction. Specifically, the invariant map inv₃(A(P₃)) for a 3-adic point P₃ should distinguish k ≡ 4, 5 (mod 9) from admissible residue classes.

**Test:** Construct a cyclic algebra (a/k, ζ₃)₃ for suitable a and show that its local evaluation at p = 3 vanishes if and only if the mod 9 test passes. This requires formalizing cyclic algebras over local fields and their invariant maps.

**Impact:** This would be the first formal construction of a Brauer–Manin obstruction class for an explicit Diophantine equation. It would bridge the gap between our finite-level proto-Brauer formalism and genuine cohomological obstruction theory.

**Catalog References:** `Algebra/SumThreeCubes/BrauerManin.lean` (nine_mem_CubicObstructionProfile_of_eq_four_or_five_mod_nine, mod_nine_obstruction_controls_all_three_power_levels)

**Proof Strategy:** Define cyclic algebras as central simple algebras with a specified cyclic splitting field. Use the explicit description of Br(ℚ₃) via local class field theory. The key computation is the Hilbert symbol evaluation.

**Domain Bridges:** Connects to K-theory, étale cohomology, and the Langlands program (local-global compatibility).

**Lineage:** Builds on Theorem 5 (3-adic tower) as the motivating computation.

**Ambition:** Grand challenge — requires formalizing substantial algebraic infrastructure not yet in Mathlib. The key insight is that cyclic algebras provide a concrete, computable entry point to Brauer groups without requiring full étale cohomology.

**Why now?** Mathlib's growing coverage of local fields and central simple algebras makes this increasingly feasible, and the explicit computability of the three-cubes example provides a concrete target that can guide the formalization effort.

---

## Direction 3: Generalization to Diagonal Cubic Forms and Norm Equations

**Conjecture:** The obstruction profile framework generalizes to equations of the form ax³ + by³ + cz³ = k for fixed nonzero a, b, c ∈ ℤ. The "bad primes" are determined by the primes dividing abc and 3, and the obstruction profile factors accordingly.

**Test:** Implement the obstruction checker for general (a, b, c, k) and compute profiles for families like x³ + y³ + 2z³ = k, comparing the obstruction landscape to the diagonal case.

**Impact:** Establishes the obstruction profile as a general tool for integral points on affine cubic surfaces, not just the symmetric sum-of-three-cubes specialization. This moves toward a formal theory of integral points on del Pezzo surfaces.

**Catalog References:** `Algebra/SumThreeCubes/BrauerManin.lean` (all theorems generalize with minor modifications)

**Proof Strategy:** Generalize the definitions by parameterizing the equation. The downward closure and upward closure theorems carry over verbatim. The mod 9 analysis requires re-computation of cube residue sums weighted by coefficients.

**Domain Bridges:** Connects to algebraic geometry (del Pezzo surfaces), algebraic number theory (norm equations from cubic fields), and cryptography (lattice problems with cubic constraints).

**Lineage:** Natural generalization of the entire current cycle.

**Ambition:** Solid extension — the key insight is that the formal infrastructure is already equation-agnostic at the level of ZMod ring homomorphisms; only the specific obstruction computations need updating.

**Why now?** The infrastructure built in this cycle makes generalization straightforward, and computational experiments can immediately identify new obstruction phenomena in non-symmetric cubic forms.

---

## Direction 4: Verified Obstruction Engine for Large-Scale Diophantine Search

**Conjecture:** A formally verified obstruction engine can reduce the computational cost of large-scale three-cubes search by 22% (the mod 9 fraction) in theory, and more in practice when combined with higher-modulus tests and search space symmetry.

**Test:** Implement a verified Lean function that, given k and a modulus list, certifies either "obstructed" (with a proof term) or "compatible" (with witness solutions mod each m). Benchmark against existing search infrastructure.

**Impact:** This would be the first *certified* computational front-end for a major Diophantine search program. It creates a template for verified preprocessing in computational number theory.

**Catalog References:** `Algebra/SumThreeCubes/BrauerManin.lean` (obstructionProfile_prunes_search, boundedSearch_implies_empty_obstruction)

**Proof Strategy:** Use `Decidable` instances for finite enumeration in ZMod to make the checker compute in the kernel. Extract the checker via Lean's code generation and interface with external search tools.

**Domain Bridges:** Connects to software verification (certified preprocessing), high-performance computing (search space reduction), and complexity theory (certified pruning as a complexity-theoretic tool).

**Lineage:** Builds directly on Theorem 4 and the `hasCubicSolutionMod` definition.

**Ambition:** Solid extension with practical impact — the key insight is that the formal proof infrastructure already provides the certification mechanism; the engineering challenge is integration with existing search tools.

**Why now?** Active three-cubes search programs (Booker, Sutherland) would benefit immediately from certified preprocessing, and the Lean 4 compiler's performance makes kernel-level computation of modular checks feasible for realistic modulus bounds.

---

## Direction 5: Probabilistic Models and Density Predictions via Local Factors

**Conjecture:** The product of local densities ∏_p σ_p(k), computed from the obstruction profile and cube-residue statistics at each prime, predicts the asymptotic density of representations of k as a sum of three cubes, in agreement with the Hardy–Littlewood heuristic. For k ≡ 4, 5 (mod 9), the factor σ₃(k) = 0, killing the entire product.

**Test:** Compute local densities σ_p(k) for p ≤ 1000 and compare the singular series ∏_p σ_p(k) against empirical representation counts for k ≤ 10⁶ from existing databases.

**Impact:** This bridges the gap between our deterministic obstruction theory and probabilistic number theory, creating a formally grounded framework for *predicting* which values of k are hard to represent. The singular series becomes a quantitative refinement of the binary obstruction profile.

**Catalog References:** `Algebra/SumThreeCubes/BrauerManin.lean` (protoBrauerCompatible_iff_everywhereLocallyAdmissible, nine_mem_CubicObstructionProfile)

**Proof Strategy:** Define local densities as σ_p(k) = lim_{e→∞} p^{-2e} · #{(x,y,z) ∈ (ℤ/p^eℤ)³ : x³+y³+z³ ≡ k (mod p^e)}. Prove the limit exists using Hensel's lemma for p ≥ 5 (good primes). Compute σ₃(k) explicitly using the 3-adic tower analysis.

**Domain Bridges:** Connects to analytic number theory (circle method), probability theory (product measures on adelic spaces), and statistical physics (partition functions as local density products).

**Lineage:** Extends Theorem 5 (3-adic tower) into a quantitative framework.

**Ambition:** Grand challenge — the key insight is that the obstruction profile gives the *qualitative* answer (zero vs. nonzero), while local densities give the *quantitative* answer (how many solutions to expect). Formalizing this connection would be the first verified treatment of the Hardy–Littlewood heuristic for any specific Diophantine equation.

**Why now?** The 3-adic tower theorem provides the crucial local computation at the bad prime, and existing databases of three-cubes solutions provide the empirical data needed to validate the predictions.
