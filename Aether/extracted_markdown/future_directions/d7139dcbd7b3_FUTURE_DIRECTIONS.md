# FUTURE_DIRECTIONS.md

## Synthesis

This cycle established four foundational theorems for RSA cryptography in Lean 4, all proved completely without sorry. The work covers the full algebraic pipeline: totient computation for RSA moduli (`rsa_totient_pq`), decryption correctness via Euler's theorem (`rsa_decryption_correctness`), the unconditional Fermat's little theorem (`fermat_little_zmod`), and existence of decryption exponents (`rsa_key_existence`). Together these formalize the core mathematical justification for why RSA works.

The key structural insight is that Mathlib's `ZMod` infrastructure, combined with `Nat.totient` and coprimality, provides a clean algebraic setting for cryptographic proofs. The `ZMod.pow_totient` lemma and `Nat.ModEq.pow_totient` bridge the gap between abstract algebra and modular arithmetic. The Fermat's little theorem proof collapsed to a single `norm_num` call after introducing the `Fact (Nat.Prime p)` instance, revealing that Mathlib's finite field machinery handles this automatically.

A notable gap remains: RSA decryption correctness currently requires `gcd(m, n) = 1`. The general case (arbitrary m) requires the Chinese Remainder Theorem applied to `ZMod (p * q) ≃ ZMod p × ZMod q`, which Mathlib supports but requires more careful orchestration. This is the most important next step.

## Results Summary

- `rsa_totient_pq`: proved — φ(pq) = (p-1)(q-1) for distinct primes, the identity enabling RSA key generation
- `rsa_decryption_correctness`: proved — m^(ed) ≡ m (mod n) for coprime m, the core RSA correctness theorem
- `fermat_little_zmod`: proved — a^p ≡ a (mod p) unconditionally, Fermat's little theorem in ZMod form
- `rsa_key_existence`: proved — existence of RSA decryption exponent d given coprime encryption exponent e

## Research Directions

### Direction 1: Full RSA Correctness Without Coprimality
**Hypothesis**: For distinct primes p, q and n = p*q, if ed ≡ 1 (mod φ(n)), then m^(ed) ≡ m (mod n) for ALL m ∈ ℕ, not just those coprime to n.
**Test**: Prove this using CRT: decompose ZMod (p*q) ≃ ZMod p × ZMod q, apply Fermat's little theorem in each component, then recombine. The key step is showing m^(ed) ≡ m (mod p) and m^(ed) ≡ m (mod q) separately, even when p | m.
**Why now**: We already have `fermat_little_zmod` (unconditional Fermat) and `rsa_decryption_correctness` (coprime case). Mathlib has `ZMod.chineseRemainder` and the ring equivalence. Combining these three pieces should close the full result.
**If true**: Completes the RSA correctness story — no caveat about coprimality needed.
**If false**: Would indicate a subtle issue with the CRT decomposition in Lean's type system (unlikely mathematically, but possible formally).

### Direction 2: Discrete Logarithm Game-Based Security
**Hypothesis**: One can formalize the discrete log assumption as a game-based security definition in Lean 4, and prove basic reductions (e.g., CDH implies DL hardness).
**Test**: Define `DLogAdvantage` as a function from adversaries to ℝ, axiomatize the DLog assumption, and prove that any CDH solver yields a DLog solver with related advantage.
**Why now**: The `ZMod` and `Units` infrastructure used in this cycle provides the algebraic setting for group-based cryptography. The key insight is that game-based definitions can be modeled as propositions about functions ℕ → ℝ (advantage as a function of security parameter).
**If true**: Opens formalization of Diffie-Hellman, ElGamal, and signature scheme security.
**If false**: Would reveal limitations of Lean's type system for probabilistic reasoning without a measure-theoretic foundation.

### Direction 3: Totient Lower Bounds for Cryptographic Key Sizes
**Hypothesis**: For n = pq with p, q prime and p, q > 2^k, we have φ(n) > 2^(2k-2), providing a quantitative security guarantee.
**Test**: Prove φ(pq) = (p-1)(q-1) ≥ (2^k - 1)^2 > 2^(2k-2) using `rsa_totient_pq` and arithmetic bounds.
**Why now**: `rsa_totient_pq` gives the exact formula. The key insight is that lower bounds on φ(n) translate directly to lower bounds on the number of possible decryption exponents, which is the combinatorial basis of RSA security.
**If true**: Provides the first formalized quantitative security bound for RSA key sizes.
**If false**: Would indicate the bound is too tight (unlikely — it's a standard estimate).

### Direction 4: Carmichael Function and Optimal RSA Exponents
**Hypothesis**: The Carmichael function λ(pq) = lcm(p-1, q-1) divides φ(pq) and provides a tighter period for modular exponentiation, yielding smaller valid decryption exponents.
**Test**: Define λ(n) = lcm of (p-1) for prime factors p of n, prove λ(n) | φ(n), and show m^(kλ(n)+1) ≡ m (mod n) for all m coprime to n.
**Why now**: The entry point theory in `CarmichaelComposite.lean` (already in the catalog) provides the Fibonacci-specific version. The key insight is that generalizing from Fibonacci entry points to the Carmichael function unifies the number-theoretic and cryptographic perspectives.
**If true**: Enables formalization of optimized RSA implementations that use λ(n) instead of φ(n).
**If false**: Would indicate subtleties in the non-coprime case that require CRT (connects to Direction 1).

### Direction 5: Homomorphic Properties of RSA
**Hypothesis**: RSA encryption is multiplicatively homomorphic: E(m₁) · E(m₂) = E(m₁ · m₂) where E(m) = m^e mod n.
**Test**: Prove (m₁^e * m₂^e : ZMod n) = ((m₁ * m₂)^e : ZMod n) using ring properties of ZMod n.
**Why now**: The `ZMod` ring structure used throughout this cycle means this should follow from `mul_pow` in a commutative ring. The key insight is that homomorphic encryption properties are just ring homomorphism facts in disguise.
**If true**: First step toward formalizing fully homomorphic encryption theory.
**If false**: Cannot fail — it's a ring identity. But stating it cleanly with the right types is the real challenge.
