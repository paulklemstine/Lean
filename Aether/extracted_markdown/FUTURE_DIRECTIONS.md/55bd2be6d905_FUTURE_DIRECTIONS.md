# Future Directions: Sierpiński Numbers and Covering Systems

## Synthesis

This research cycle established a rigorous formal framework connecting covering systems, the Chinese Remainder Theorem, and Sierpiński numbers. The central achievement is the **Sierpiński Witness Theorem**: any covering system paired with primes satisfying divisibility and multiplicative order conditions proves a number is Sierpiński. This theorem, together with the **Density Bound** (∑ 1/mᵢ ≥ 1) and **Coverage Periodicity**, provides the foundation for both theoretical analysis and computational verification of Sierpiński numbers.

The most promising cross-domain connection emerging from this work is between **covering systems and algebraic number theory**. The multiplicative order condition (ord_p(2) | mᵢ) ties covering systems directly to the arithmetic of cyclotomic fields and the factorization of Fermat numbers. This bridge connects the combinatorial world of covering systems to deep algebraic structures. Meanwhile, the density bound connects to **analytic number theory** through the probabilistic interpretation of covering multiplicity.

The highest breakthrough potential lies in **Direction 1** (Riesel number theory), which would double the applicability of our framework with minimal additional machinery, and **Direction 3** (constructive bounds on covering system size), which could yield the first formal lower bounds on the size of Sierpiński witnesses.

---

### Direction 1: Riesel Numbers via Covering Systems

**Conjecture**: The covering system framework for Sierpiński numbers transfers directly to Riesel numbers (odd k > 1 with k · 2ⁿ − 1 composite for all n ≥ 1), with the divisibility condition modified to pᵢ | k · 2^(rᵢ) − 1 and the same order condition ord_p(2) | mᵢ. The smallest Riesel number is conjectured to be 509203.

**Test**: Construct a `RieselWitness` structure parallel to `SierpinskiWitness` and verify computationally that 509203 admits a valid witness. Check that the density sum of the witness covering system is ≥ 1 (it must be, by our density bound theorem).

**Impact**: If true, this immediately formalizes a second major class of numbers with guaranteed compositeness, doubling the reach of our framework. The proof of the Riesel witness theorem should be essentially identical to `sierpinski_of_witness`, establishing a deep structural parallel. If the transfer fails, it would reveal an unexpected asymmetry between k · 2ⁿ + 1 and k · 2ⁿ − 1 at the formal level.

**Catalog References**: `Algebra/SierpinskiCovering.lean` (all definitions and theorems from this cycle)

**Proof Strategy**: Define `IsRieselNumber k := Odd k ∧ 1 < k ∧ ∀ n, 0 < n → ¬Nat.Prime (k * 2^n - 1)` and `RieselWitness` with divisibility condition `prime_factor i ∣ k * 2^(residue i) - 1`. The key change is that k · 2ⁿ − 1 involves natural number subtraction, so one must verify k · 2ⁿ > 1 (which follows from k ≥ 3 and n ≥ 1). The periodicity lemma `pow_two_zmod_periodic` transfers unchanged.

**Domain Bridges**: Number Theory (Sierpiński/Riesel) ↔ Combinatorics (covering systems) ↔ Algebra (multiplicative orders in ZMod)

**Lineage**: Direct extension of this cycle's `SierpinskiWitness` and `sierpinski_of_witness`.

**Ambition**: extension

---

### Direction 2: Hough's Minimum Modulus Bound

**Conjecture**: There exists an absolute constant M such that every covering system with distinct moduli has minimum modulus at most M. Hough (2015) proved M ≤ 10^{16}; the true value may be much smaller. Formally: if C is a covering system with all moduli distinct, then min(moduli) ≤ M.

**Test**: Define `DistinctCoveringSystem` (covering system with `Function.Injective modulus`). State the conjecture as `∃ M : ℕ, ∀ C : DistinctCoveringSystem, ∃ i, C.modulus i ≤ M`. Attempt to prove the weaker bound that if all moduli are > N, then the density sum ∑ 1/mᵢ < 1 for sufficiently large N, contradicting the density bound.

**Impact**: Formalizing Hough's result (or even a weaker version) would be a major achievement in formalized number theory. It would settle Erdős's 1950 conjecture in the formal world and demonstrate that formal methods can handle delicate analytic arguments.

**Catalog References**: `Algebra/SierpinskiCovering.lean` (CoveringSystem, covering_density_sum_ge_one)

**Proof Strategy**: The key insight is that ∑_{m > N} 1/m converges to 0 as N → ∞, so if all moduli exceed N, the density sum ∑ 1/mᵢ < s/N where s is the number of classes. Combined with ∑ 1/mᵢ ≥ 1, this gives s > N. But a covering system with s classes using moduli > N must have lcm > N^s, leading to contradictions for large enough N. Hough's actual proof uses a more sophisticated sieve argument.

**Domain Bridges**: Combinatorics (covering systems) ↔ Analysis (harmonic sum bounds) ↔ Sieve Theory

**Lineage**: Builds on `covering_density_sum_ge_one` from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Lower Bounds on Sierpiński Witness Size

**Conjecture**: Any Sierpiński witness for any k must have at least 3 congruence classes. More precisely, if k is Sierpiński, then any covering system witnessing this has size ≥ 3.

**Test**: Prove that a Sierpiński witness with size ≤ 2 leads to a contradiction by case analysis. With 1 class, the modulus is 1, so a single prime p divides k · 2ⁿ + 1 for all n. With 2 classes, the moduli must cover {0, 1, ...}, which constrains the moduli to {1, m} or {2, 2}, etc. Show these cases cannot satisfy all conditions simultaneously for any k.

**Impact**: This would be the first formal lower bound on the combinatorial complexity of Sierpiński witnesses. It connects to the question of how "efficient" a covering system can be — a question with implications for both Sierpiński numbers and the broader theory of covering systems.

**Catalog References**: `Algebra/SierpinskiCovering.lean` (SierpinskiWitness, CoveringSystem)

**Proof Strategy**: Case 1 (size = 1): modulus₀ = 1, so the single prime p₀ divides k · 2ⁿ + 1 for ALL n. But k · 2ⁿ + 1 grows exponentially, so it exceeds p₀ for large n, yet a single prime cannot divide k · 2ⁿ + 1 for all n (consider n = 0 and n = ord_p(2)). Case 2 (size = 2): the covering system has moduli m₁, m₂ with m₁ = 2, m₂ = 2 (the only way two classes cover everything is essentially {even, odd}). Then both primes p₁, p₂ divide appropriate values. Show this is too restrictive.

**Domain Bridges**: Combinatorics (covering system structure) ↔ Number Theory (multiplicative orders)

**Lineage**: Extension of the covering system theory from this cycle.

**Ambition**: extension

---

### Direction 4: Covering Systems and Cyclotomic Polynomials

**Conjecture**: The primes appearing in a Sierpiński witness for k are precisely the prime factors of cyclotomic values Φ_d(2) for various d, where Φ_d is the d-th cyclotomic polynomial. More precisely, the order condition ord_p(2) | m connects the prime p to the factorization of 2^m - 1, which decomposes via cyclotomic polynomials.

**Test**: For the 78557 witness, verify that each prime pᵢ divides Φ_{ord(2,pᵢ)}(2). Compute the cyclotomic polynomial values and check the factorizations match. Formalize the connection between `orderOf (2 : ZMod p)` and cyclotomic polynomial evaluation.

**Impact**: This would bridge covering system theory with the algebraic theory of cyclotomic fields, potentially yielding new constructions of Sierpiński witnesses from cyclotomic data. It could also illuminate why certain primes (like 3, 5, 7, 13, 17) appear repeatedly in covering system constructions.

**Catalog References**: `Algebra/SierpinskiCovering.lean` (SierpinskiWitness, order_dvd_modulus)

**Proof Strategy**: Key lemma: if p is prime and ord_p(2) = d, then p | Φ_d(2). This follows from 2^d ≡ 1 (mod p) and 2^(d/q) ≢ 1 (mod p) for all prime divisors q of d. Formalize `Polynomial.cyclotomic` evaluation and connect to `orderOf (2 : ZMod p)`. Build on Mathlib's existing cyclotomic polynomial theory.

**Domain Bridges**: Covering Systems ↔ Algebraic Number Theory (cyclotomic fields) ↔ Algebra (polynomial evaluation in ZMod)

**Lineage**: Deepens the algebraic foundations of `pow_two_zmod_periodic` from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Computational Elimination of Sierpiński Candidates

**Conjecture**: For each of the five remaining Sierpiński candidates (21181, 22699, 24737, 55459, 67607), there exists n ≤ 10^8 such that k · 2ⁿ + 1 is prime.

**Test**: For each candidate k, run a Proth primality test (which is efficient for numbers of this form: N = k · 2ⁿ + 1 is prime iff a^((N-1)/2) ≡ -1 (mod N) for some a, when 2ⁿ > k). Formalize the Proth primality test and use it to certify any primes found.

**Impact**: Finding primes for all five remaining candidates would *prove* the Selfridge conjecture, resolving a 60+ year open problem. Even eliminating one candidate would be significant. If none are found up to 10^8, this would strengthen the evidence that some might actually be Sierpiński.

**Catalog References**: `Algebra/SierpinskiCovering.lean` (SelfridgeConjecture, selfridge_implies_78557_minimal)

**Proof Strategy**: Implement efficient modular exponentiation for Proth testing. For each prime found, the certificate is simply (k, n, a) where a^((N-1)/2) ≡ -1 (mod N). Formalizing Proth's theorem in Lean would allow machine-verified certificates. The key Mathlib prerequisite is `ZMod.euler_criterion` or Legendre symbol theory.

**Domain Bridges**: Computation (primality testing) ↔ Number Theory (Proth's theorem) ↔ Formal Verification (certified primes)

**Lineage**: Direct continuation of the Selfridge conjecture analysis from this cycle.

**Ambition**: extension
