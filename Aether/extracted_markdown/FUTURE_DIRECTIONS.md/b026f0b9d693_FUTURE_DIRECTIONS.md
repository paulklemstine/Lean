# Future Directions: Langlands Correspondence for GL₂ over ℚ

## Synthesis

This research cycle formalized the algebraic skeleton of the Langlands correspondence for GL₂ over ℚ, establishing machine-verified proofs of the Hecke eigenvalue recursion, the Ramanujan-Petersson discriminant criterion, the Hasse bound on elliptic curve point counts, and the prime power determination theorem. The key structures — `HeckeEigenform`, `EichlerShimuraDatum`, `GaloisRepDatum`, and `ModularGaloisCorrespondence` — provide a foundation for extending the formalization in multiple directions.

The most promising cross-domain connection emerging from this cycle is the **bridge between tropical Hecke operators** (already present in the Catalog via `TropicalLanglands.lean` and `TropicalHeckeCrystalDuality.lean`) **and classical Hecke eigenvalue theory**. The tropical Hecke operator T acts by `T f(g) = max_x {f(x) + K(x,g)}` (replacing sum with max, product with sum), and tropical eigenforms satisfy `T f = c + f` (additive shift). Our classical `HeckeEigenform` structure, with its multiplicative eigenvalue equation `T_p f = a_p · f`, is the "de-tropicalization" of this. A formal bridge between the two would connect number theory to optimization, giving new proof strategies for both sides.

The cycle also revealed a gap: the full multiplicity-one theorem (Hecke eigenvalues at primes determine all coefficients) requires handling bad primes, where the Hecke recursion does not apply. This points toward formalizing the local Langlands correspondence at ramified primes — a significant but tractable extension that would close the gap and connect to the p-adic Langlands program.

---

### Direction 1: Tropical Hecke-Classical Hecke Bridge

**Conjecture**: There exists a deformation parameter t such that the tropical Hecke operator (t → 0) and the classical Hecke operator (t → 1) are connected by a family of "Maslov dequantization" operators, and the tropical eigenvalue of a dequantized eigenform converges to the logarithm of the classical Hecke eigenvalue.

Formally: for a Hecke eigenform f with eigenvalue a_p at prime p, define the tropical limit f_trop(q) = lim_{t→0} t · log(f(q^{1/t})). Then f_trop is a tropical eigenform for the tropical Hecke operator T_p^trop with eigenvalue log(|a_p|).

**Test**: Compute tropical Hecke eigenvalues for the Ramanujan τ function at primes p = 2, 3, 5, 7, 11. Verify that log|τ(p)| matches the tropical eigenvalue computed directly from the tropicalized q-expansion.

**Impact**: If true, this would provide a new route to proving Ramanujan-type bounds: tropical eigenvalues are constrained by the geometry of the tropical modular curve, and dequantization would transfer these constraints to the classical setting. If false, the failure mode would illuminate where the tropicalization loses arithmetic information.

**Catalog References**: `Bridges/TropicalLanglands.lean` (IsTropChar, tropFourier, TropHeckeOp, IsTropEigenform), `Bridges/TropicalHeckeCrystalDuality.lean`, `Bridges/LanglandsGL2Defs.lean` (HeckeEigenform, SatisfiesRamanujanBound)

**Proof Strategy**:
1. Define a one-parameter family of "t-Hecke operators" interpolating between max-plus (t=0) and sum-product (t=1).
2. Prove that t-eigenforms exist for all t > 0 using a fixed-point argument.
3. Show convergence as t → 0 using the Maslov dequantization framework.
4. Transfer the tropical eigenvalue bound to a classical bound via semicontinuity.

**Domain Bridges**: NumberTheory <-> Tropical, Algebra <-> Optimization

**Lineage**: Builds on `TropicalLanglands.lean` catalog entry and the `HeckeEigenform` structure introduced in this cycle. Extends the tropical-classical bridge initiated in `TropicalHeckeCrystalDuality.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Bad Prime Completion and Local Langlands

**Conjecture**: The `HeckeEigenform` structure can be extended with a "bad prime recursion" field capturing the local behavior at primes p | N: for p | N with exact power p^a || N, the coefficient a(p^r) satisfies a(p^r) = a(p)^r (if a = 1) or a(p^r) = 0 for r ≥ 1 (if a ≥ 2 and f is supercuspidal at p). With this extension, the full multiplicity-one theorem (Hecke eigenvalues at primes determine all coefficients) becomes provable from the structure axioms alone.

**Test**: Formalize the extended `HeckeEigenform` structure and prove the multiplicity-one theorem by strong induction on n using prime factorization. Verify on the conductor-11 curve (p=11 is bad: a(11) = 1, a(11^r) = 1 for all r since 11 || 11).

**Impact**: Closes the gap identified in this cycle. The extended structure would faithfully model the full L-function of a modular form, enabling formalization of the functional equation and the analytic properties needed for the Sato-Tate theorem.

**Catalog References**: `Bridges/LanglandsGL2Defs.lean` (HeckeEigenform, ModularGaloisCorrespondence), `Bridges/LanglandsGL2.lean` (hecke_prime_power_determined)

**Proof Strategy**:
1. Define `HeckeEigenformFull` extending `HeckeEigenform` with `coeff_bad_prime: ∀ p, Nat.Prime p → p ∣ level → ∀ r, coeff (p ^ (r+1)) = coeff p * coeff (p ^ r)`.
2. Prove `full_multiplicity_one: ∀ n ≥ 1, f.coeff n = g.coeff n` by strong induction, factoring n = ∏ p^{v_p(n)} and using `coeff_mul_coprime` plus the prime power determination at both good and bad primes.
3. Use `Nat.factorization` from Mathlib to decompose n.

**Domain Bridges**: NumberTheory <-> Algebra

**Lineage**: Directly extends the `hecke_prime_power_determined` theorem proved in this cycle.

**Ambition**: extension

---

### Direction 3: Galois Representation Irreducibility and the Ramanujan Bound

**Conjecture**: Formalize the implication chain: Eichler-Shimura relation ⟹ Frobenius eigenvalues on a circle ⟹ Galois representation is irreducible ⟹ Ramanujan bound. Specifically, prove that if the 2-dimensional Galois representation ρ_f attached to an eigenform f is irreducible (i.e., has no 1-dimensional subrepresentation), then the Frobenius eigenvalues at each unramified prime are complex conjugates of absolute value p^((k-1)/2), which implies |a_p| ≤ 2p^((k-1)/2).

**Test**: Formalize the `IsIrreducible` predicate for 2-dimensional Galois representations in terms of the Frobenius traces and determinants. Prove that if the representation is irreducible and the determinant is the (k-1)-th power of the cyclotomic character, then the Ramanujan bound holds. Verify that the Ramanujan τ function satisfies the irreducibility criterion.

**Impact**: This would provide a purely algebraic proof of the Ramanujan bound from irreducibility, without invoking the Weil conjectures. The key insight is that irreducibility forces the Frobenius eigenvalues to be algebraic conjugates, and the determinant condition forces them onto a circle.

**Catalog References**: `Bridges/LanglandsGL2Defs.lean` (GaloisRepDatum, SatisfiesRamanujanBound, frobeniusDiscriminant), `Bridges/GaloisNeuralCorrespondence.lean` (WeightSymmetrySet — for the analogy between Galois symmetry and weight symmetry)

**Proof Strategy**:
1. Define `IsIrreducible (ρ : GaloisRepDatum)` as: there is no character χ such that trace(Frob_p) = χ(p) + det(Frob_p)/χ(p) for all good primes.
2. Prove that irreducibility + det = ε^(k-1) implies the Frobenius eigenvalues have absolute value p^((k-1)/2).
3. Derive |a_p| ≤ 2p^((k-1)/2) from the eigenvalue absolute values.

**Domain Bridges**: NumberTheory <-> Algebra, Galois Theory <-> Representation Theory

**Lineage**: Builds on the `ramanujan_iff_discriminant_nonpos` and `trace_det_discriminant` theorems from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: L-function Euler Product Convergence

**Conjecture**: The partial L-function sums L_N(f, s) = Σ_{n≤N} a(n)/n^s converge absolutely for Re(s) > (k+1)/2, and the Euler product representation holds in this half-plane:
$$L(f, s) = \prod_{p \nmid N} (1 - a_p p^{-s} + p^{k-1-2s})^{-1}$$

This can be proved from the Ramanujan bound: |a(n)| ≤ d(n) · n^((k-1)/2) where d(n) is the number of divisors, giving absolute convergence for Re(s) > (k+1)/2.

**Test**: Compute partial L-function sums and partial Euler products for the Ramanujan Δ function at s = 7 (well inside the convergence region). Verify that they agree to at least 6 decimal places for N = 1000.

**Impact**: Formal convergence of the L-function is a prerequisite for the functional equation, which in turn is needed for the analytic properties used in the Sato-Tate theorem and the Birch-Swinnerton-Dyer conjecture.

**Catalog References**: `Bridges/LanglandsGL2Defs.lean` (partialLFunction, localEulerFactor), `Bridges/LanglandsGL2.lean` (discriminant_nonpos_implies_bound)

**Proof Strategy**:
1. Prove the divisor bound |a(n)| ≤ d(n) · n^((k-1)/2) from multiplicativity and the Ramanujan bound at primes.
2. Use the comparison test with Σ d(n)/n^σ for σ > 1 to establish absolute convergence.
3. Prove the Euler product identity by the unique factorization of natural numbers and the multiplicativity of a(n).

**Domain Bridges**: NumberTheory <-> Analysis

**Lineage**: Builds on `l_function_coeff_multiplicative` and `discriminant_nonpos_implies_bound` from this cycle.

**Ambition**: extension

---

### Direction 5: Computational Sato-Tate Verification Engine

**Conjecture**: For any non-CM eigenform f of weight k ≥ 2, the normalized Hecke eigenvalues θ_p = arccos(a_p / (2p^((k-1)/2))) have empirical distribution converging to the Sato-Tate measure (2/π)sin²(θ)dθ. Specifically, the Kolmogorov-Smirnov statistic D_X = sup_θ |F_X(θ) - F_{ST}(θ)| satisfies D_X = O(1/√(π(X))) as X → ∞.

**Test**: Implement a Lean-verified computation pipeline that:
1. Computes τ(p) for primes p ≤ 10^6 using the power series expansion.
2. Forms the normalized angles θ_p.
3. Computes the KS statistic D_X.
4. Verifies D_X < C/√(π(X)) for a certified constant C.

Partial test: For X = 10000, the KS statistic should be below 0.05.

**Impact**: A certified Sato-Tate verification engine would provide the first machine-verified evidence for equidistribution, bridging formal methods and computational number theory. The pipeline could be generalized to test equidistribution for other L-functions.

**Catalog References**: `Bridges/LanglandsGL2Defs.lean` (SatoTateSecondMomentPrediction, SatisfiesRamanujanBound)

**Proof Strategy**:
1. Implement certified computation of τ(n) in Lean using `Nat.strongRec`.
2. Prove correctness of the Sato-Tate moment computation.
3. Use interval arithmetic to bound the KS statistic.
4. Formalize the relationship between moment convergence and distribution convergence.

**Domain Bridges**: NumberTheory <-> Computation, Analysis <-> Statistics

**Lineage**: Builds on the Sato-Tate prediction formalized in `LanglandsGL2Defs.lean` and the Ramanujan bound verification from this cycle.

**Ambition**: extension
