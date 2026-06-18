# Future Directions: Artin's Conjecture on Primitive Roots

## Synthesis

This cycle established a rigorous framework for studying Artin's conjecture through three interconnected lenses: **index theory**, **safe prime analysis**, and **quadratic residue connections**. The primitive root index — defined as (p−1)/ord(u) — provides a quantitative measure of "how far" an element is from being a primitive root, transforming the binary primitive-root question into a continuous invariant. The safe prime criterion (Theorem: non-trivial non-squares are primitive roots for safe primes p = 2q+1) demonstrates that for primes with minimal factorization of p−1, the primitive root question reduces entirely to a quadratic residuosity check. The theorem that primitive roots are always quadratic non-residues reveals a deep structural constraint connecting Artin's conjecture to the distribution of quadratic residues.

The most promising cross-domain connection is between the **index distribution** of a given candidate across primes and **analytic number theory**. The index of 2 modulo p encodes the full factorization structure of ord_p(2), and its distribution over primes is intimately connected to Chebotarev's density theorem applied to specific Galois extensions. This bridge between the algebraic (index theory in cyclic groups) and the analytic (prime distribution in number fields) is where breakthrough potential is highest. On the computational side, the algorithms developed here scale to 10⁶ primes efficiently, providing a solid foundation for empirical investigation of the more refined conjectures proposed below.

The results connect to the broader Catalog through the primitive root density theorem (`Catalog/Algebra/ArtinPrimitiveRoot.lean`), the Euler totient properties used throughout Mathlib, and the infinite primes result. Future work should leverage the cryptographic applications in `Catalog/Cryptography/` (primitive roots underpin Diffie-Hellman) and the algebraic structure theory in `Catalog/Algebra/`.

---

### Direction 1: Index Distribution Conjecture and Chebotarev Connection

**Conjecture**: For any Artin candidate a and positive integer k, define N_k(a, x) = |{p ≤ x prime : idx_p(a) = k}|. Then for each fixed k, the limit δ_k(a) = lim_{x→∞} N_k(a, x)/π(x) exists and equals C_Artin · ∏_{q|k, q prime} (correction factor involving q). Specifically, for a = 2: δ₁(2) = C_Artin ≈ 0.3740, δ₂(2) ≈ 0.2394, δ₃(2) ≈ 0.0529.

**Test**: Compute the index distribution of 2 modulo all primes up to 10⁸. For each index value k ∈ {1, 2, 3, 4, 6, 8, 12}, estimate the density N_k(2, 10⁸)/π(10⁸) and compare against the predicted values. The conjecture is falsified if any density deviates from the prediction by more than 3σ (where σ comes from the central limit theorem for prime-counting functions).

**Impact**: If true, this completely characterizes the distribution of multiplicative orders of a fixed base across primes — a far stronger result than Artin's conjecture itself. It would provide a complete probabilistic model for ord_p(a), answering questions about "typical" behavior of discrete logarithms that are central to cryptographic security analysis. If false, the specific k where it fails would reveal unexpected arithmetic structure in the factorization of ord_p(a).

**Catalog References**: `Catalog/Algebra/ArtinConjecture.lean` (primRootIndex definition, index_mul_order theorem), `Catalog/Algebra/ArtinPrimitiveRoot.lean` (primitive_root_density_pos)

**Proof Strategy**: 
1. Express N_k(a, x) using Chebotarev's density theorem for the splitting field of x^k - a over ℚ.
2. Formalize the Galois group computation: for a = 2 and k prime, the relevant extension is ℚ(ζ_k, 2^{1/k})/ℚ with Galois group ≅ (ℤ/kℤ)× ⋉ ℤ/kℤ.
3. Apply effective Chebotarev (conditional on GRH) to get the density.
4. Prove the product formula for general k by multiplicativity of the index decomposition.

**Domain Bridges**: NumberTheory <-> Algebra, Algebra <-> Cryptography

**Lineage**: Builds on primRootIndex definition and index_mul_order from this cycle. Extends Hooley's conditional framework with finer-grained distributional information.

**Ambition**: grand_challenge

---

### Direction 2: Safe Prime Density and Artin's Conjecture

**Conjecture**: Define SP(x) = |{p ≤ x : p = 2q+1, p and q prime}|. If SP(x) → ∞ (the twin prime-like conjecture for safe primes), then for any Artin candidate a with a ≢ ±1 (mod 8), the set {p safe prime : a is a primitive root mod p} is infinite.

**Test**: 
1. Enumerate safe primes up to 10⁹ and verify that every non-trivial non-square below each safe prime is a primitive root (extending the safe_prime_nonsquare_primroot theorem).
2. For a = 2, compute the fraction of safe primes where 2 is a primitive root. By our theorem, this requires only checking that 2 is a non-square mod p, which happens iff p ≡ ±3 (mod 8) by quadratic reciprocity. Count and verify.

**Impact**: This would provide a conditional proof of Artin's conjecture under a weaker hypothesis than GRH — merely assuming infinitely many safe primes exist. Since the safe prime conjecture is widely believed and has strong computational support, this would be a significant advance. The failure case would mean that the quadratic residuosity of fixed integers has unexpected correlations across safe primes.

**Catalog References**: `Catalog/Algebra/ArtinConjecture.lean` (SafePrimeWitness, safe_prime_nonsquare_primroot, safe_prime_order_options)

**Proof Strategy**:
1. Formalize the connection: for safe prime p = 2q+1, 2 is a primitive root mod p iff 2 is a non-square mod p iff p ≡ 3 or 5 (mod 8).
2. Prove that among safe primes, the residue classes mod 8 are equidistributed (under the safe prime conjecture).
3. Conclude that at least 1/2 of safe primes have 2 as a primitive root.
4. Generalize to other Artin candidates using quadratic reciprocity.

**Domain Bridges**: NumberTheory <-> Algebra, Algebra <-> Cryptography

**Lineage**: Direct extension of safe_prime_nonsquare_primroot from this cycle. Builds on the safe prime witness structure.

**Ambition**: extension

---

### Direction 3: Elliptic Curve Primitive Root Conjecture

**Conjecture**: Let E be an elliptic curve over ℚ with positive rank, and let P ∈ E(ℚ) be a point of infinite order. Define the "elliptic Artin set" A_E(P) = {p prime of good reduction : the reduction P̄ generates E(𝔽_p)}. Then A_E(P) is infinite, and has positive natural density.

**Test**: Take the curve E: y² = x³ - x (conductor 32) with P = (0,0) being a torsion point — this should NOT satisfy the conjecture. Instead take E: y² = x³ + 1 with P = (2, 3) (a point of infinite order, rank 1). Compute |E(𝔽_p)| and ord(P̄) for primes p < 10⁵ and estimate the density of primes where ord(P̄) = |E(𝔽_p)|.

**Impact**: This is the elliptic analog of Artin's conjecture, proposed by Lang and Trotter. If formalized conditionally (under GRH for Dedekind zeta functions of division fields), it would be a major contribution to arithmetic geometry. The expected density involves an infinite product analogous to the Artin constant but over the division fields of E, connecting group theory, algebraic geometry, and analytic number theory.

**Catalog References**: `Catalog/Algebra/ArtinConjecture.lean` (framework for primitive root index and density), `Catalog/Cryptography/` (elliptic curve infrastructure if available)

**Proof Strategy**:
1. Define the elliptic primitive root index: idx_p(P) = |E(𝔽_p)| / ord(P̄ mod p).
2. Prove the analog of primroot_iff_index_one: P̄ generates E(𝔽_p) iff idx_p(P) = 1.
3. Express the density using Chebotarev for the division fields Q(E[n])/Q.
4. Compute the Galois groups of division fields (they embed into GL₂(ℤ/nℤ) by the Galois representation on torsion).
5. Apply the inclusion-exclusion sieve as in Hooley's proof.

**Domain Bridges**: Algebra <-> Geometry, NumberTheory <-> Cryptography

**Lineage**: Extends the index theory framework from this cycle to a 2-dimensional setting. Builds on primRootIndex conceptual framework.

**Ambition**: grand_challenge

---

### Direction 4: Effective Primitive Root Bounds

**Conjecture**: For every Artin candidate a with |a| ≤ 100, there exists an explicit prime p ≤ 10⁶ such that a is a primitive root mod p. More ambitiously: for every Artin candidate a, there exists a primitive root prime p ≤ C · |a|^{12} for an absolute constant C.

**Test**: For each Artin candidate a with |a| ≤ 1000, find the smallest prime p for which a is a primitive root mod p. Plot the relationship between |a| and the smallest primitive root prime. The conjecture predicts polynomial growth; exponential growth would refute it.

**Impact**: Effective bounds are crucial for cryptographic applications where one needs to find a primitive root quickly. Current unconditional results give no explicit bound. Even a conditional result (under GRH) with an explicit polynomial bound would be valuable for algorithmic number theory.

**Catalog References**: `Catalog/Algebra/ArtinConjecture.lean` (primroot_test, exists_prime_not_in_finset), `Catalog/Algebra/ArtinPrimitiveRoot.lean`

**Proof Strategy**:
1. Under GRH, use Hooley's method with explicit error terms from the effective Chebotarev density theorem.
2. Bound the error term in the prime-counting function for the Artin set: |N(a,x) - C·Li(x)| ≤ c·x^{1/2}·log(|a|·x).
3. Show that N(a,x) > 0 for x ≥ C₀·(log|a|)^A for explicit constants C₀, A.
4. For the unconditional case, use Bombieri-Vinogradov as a GRH substitute for "most" moduli.

**Domain Bridges**: NumberTheory <-> Computation, Algebra <-> Cryptography

**Lineage**: Extends exists_primitive_root' (which shows existence for each prime) to the distributional question. Builds on primroot_test for computational verification.

**Ambition**: extension

---

### Direction 5: Primitive Root Index and Cryptographic Security

**Conjecture**: For a random prime p of n bits and base g = 2, the probability that idx_p(2) > k is O(1/k) as k → ∞, uniformly in n. Moreover, the discrete logarithm problem in the subgroup generated by 2 mod p is computationally equivalent to the full DLP in (ℤ/pℤ)× when idx_p(2) = O(log p).

**Test**: 
1. Generate 10,000 random 256-bit primes and compute idx_p(2) for each. Verify the distribution matches the Artin prediction: P(idx = k) ≈ C_k for explicit constants from the index distribution conjecture.
2. For primes where idx_p(2) > 1, implement the Pohlig-Hellman attack on the quotient group and measure whether the reduced DLP is easier.

**Impact**: This directly connects Artin's conjecture to cryptographic security. If the index is almost always 1 (as Artin predicts), then using g = 2 as a Diffie-Hellman base is essentially always secure. If the index can be large with non-negligible probability, it creates a cryptographic vulnerability.

**Catalog References**: `Catalog/Algebra/ArtinConjecture.lean` (primRootIndex, index_dvd_p_minus_one), `Catalog/Cryptography/` (DLP infrastructure)

**Proof Strategy**:
1. Model the index distribution using the random matrix heuristic for the Galois group of ℚ(ζ_n, a^{1/n})/ℚ.
2. Prove concentration inequalities: P(idx_p(a) > k) ≤ ∑_{d>k, d|p-1} 1/d ≤ (log log p)/k.
3. Connect to the Pohlig-Hellman algorithm: show that the DLP reduces to O(idx) subproblems.
4. Prove that when idx = 1, no Pohlig-Hellman decomposition is possible.

**Domain Bridges**: Algebra <-> Cryptography, NumberTheory <-> Computation

**Lineage**: Applies the index theory from this cycle to a concrete application domain. Uses primRootIndex and its divisibility properties.

**Ambition**: extension
