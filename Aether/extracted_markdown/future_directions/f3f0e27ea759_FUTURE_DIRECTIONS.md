# Future Research Directions

## Synthesis

This research cycle established the first formal verification of the core algebraic framework underlying fully homomorphic encryption—the noise management argument that transforms "somewhat homomorphic" into "fully homomorphic" encryption through bootstrapping. Our formalization captures the essential mathematical content of Gentry's 2009 breakthrough and the BGV leveled scheme in a hierarchy of structures (`NoiseBoundedHE → CorrectHE → BootstrappableHE`), proving 12 theorems including the central result that refreshed circuit evaluation preserves validity for circuits of arbitrary depth.

The most promising cross-domain connection is between our noise-bounded encryption framework and the existing tropical homomorphic encryption work in the Catalog (`Cryptography/TropicalHomomorphic.lean`). Tropical semirings provide a concrete, well-understood algebraic setting where the noise axioms can be instantiated, and the idempotence of the tropical min operation provides a natural bootstrapping mechanism (min of a ciphertext with itself resets noise). This connection suggests a broader program: identifying which algebraic structures naturally support bootstrapping.

The highest breakthrough potential lies in Direction 1 (Concrete LWE Instantiation), because it would bridge the gap between our abstract algebraic framework and the concrete cryptographic constructions used in practice. If successful, it would provide the first end-to-end formally verified FHE scheme, from lattice hardness assumptions through noise management to circuit evaluation correctness.

---

### Direction 1: Concrete LWE Instantiation of the Noise-Bounded Framework

**Conjecture**: The Ring-LWE-based BGV scheme, with ciphertexts as elements of Z_q[X]/(X^n + 1) and noise measured as the infinity norm of the error polynomial, satisfies all axioms of `NoiseBoundedHE` with `freshNoise = B` (the error bound), `maxNoise = q/2`, and noise growth `noise_add(c₁, c₂) ≤ noise(c₁) + noise(c₂)` and `noise_mul(c₁, c₂) ≤ n · noise(c₁) · noise(c₂)` where n is the ring dimension.

**Test**: Define the Ring-LWE encryption scheme concretely in Lean 4 using `ZMod q` and polynomial quotient rings. Verify that the noise axioms hold by proving the noise growth bounds for polynomial addition and multiplication in the quotient ring Z_q[X]/(X^n + 1). The factor of n in multiplicative noise growth comes from the expansion of the product modulo X^n + 1.

**Impact**: If true, this provides the first formally verified concrete FHE instantiation, bridging abstract noise management with real cryptographic constructions. It would also establish the precise relationship between ring dimension n, modulus q, and achievable circuit depth. If the noise bounds are tighter than expected, it could suggest parameter improvements for practical implementations.

**Catalog References**: `Cryptography/FHE/Defs.lean`, `Cryptography/FHE/Theorems.lean`, `Cryptography/LWE/Defs.lean`

**Proof Strategy**: 
1. Define `Rq := (ZMod q)[X] / (X^n + 1)` using Mathlib's polynomial quotient machinery.
2. Define encryption as `Enc(m) = (a, a·s + e + (q/p)·m)` for random `a`, secret `s`, small error `e`.
3. Prove noise growth bounds using submultiplicativity of the infinity norm on `Rq`.
4. Construct an instance of `NoiseBoundedHE` and verify all axioms.
5. For bootstrapping, prove that the decryption circuit has multiplicative depth O(log n · log q).

**Domain Bridges**: Cryptography <-> Algebra (polynomial ring theory), Cryptography <-> Computation (circuit complexity of decryption)

**Lineage**: Builds on the `NoiseBoundedHE` and `CorrectHE` structures defined in this cycle, and the LWE definitions in `Cryptography/LWE/Defs.lean`.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Bootstrapping as a Natural FHE Instance

**Conjecture**: The tropical encryption scheme defined in `TropicalHomomorphic.lean` satisfies the axioms of `BootstrappableHE` with `bNoise = 0` (due to the idempotence of min), making it a "perfect" bootstrappable scheme—but one where the security guarantee is trivially broken (by the `deterministic_tropical_order_leak` theorem). This provides a formal proof that algebraic bootstrapping capability and cryptographic security are independent properties.

**Test**: Construct a concrete instance of `BootstrappableHE` from `TropicalEncScheme`, where the refresh operation is defined as `refresh(c) = cmin(c, c)` (exploiting min idempotence). Verify all axioms hold. Then formally prove that no `TropicalEncScheme` instance can satisfy IND-CPA security (because ciphertext order reveals plaintext order).

**Impact**: This would provide a clean, constructive example showing that the bootstrapping framework is satisfiable (ruling out vacuous truth concerns about our main theorems) while simultaneously demonstrating that bootstrapping alone is insufficient for security. It would clarify the separation between the algebraic correctness theory (our framework) and the computational hardness theory (security reductions).

**Catalog References**: `Cryptography/TropicalHomomorphic.lean`, `Cryptography/FHE/Defs.lean`, `Cryptography/TropicalPostQuantum.lean`

**Proof Strategy**:
1. Define a noise function on `TropicalEncScheme.Cipher` (e.g., the encoding offset).
2. Show `cmin(c, c) = c` implies refresh noise is 0.
3. Construct the `BootstrappableHE` instance.
4. Formalize IND-CPA security and prove tropical schemes cannot satisfy it.

**Domain Bridges**: Cryptography <-> Tropical geometry (semiring structure), Cryptography <-> Logic (independence of algebraic and computational properties)

**Lineage**: Builds on `tropical_homomorphic_correctness` and `tropical_min_idempotent_bootstrap` from the existing Catalog, and the `BootstrappableHE` structure from this cycle.

**Ambition**: extension

---

### Direction 3: Circuit Complexity Lower Bounds for Bootstrapping

**Conjecture**: For any `BootstrappableHE` scheme where the plaintext space has size ≥ 2 and the noise function is "non-degenerate" (noise of enc(m) depends on m), the bootstrapping circuit (the circuit that homomorphically evaluates decryption) has multiplicative depth at least log₂(log₂(maxNoise/bNoise)). This would formalize the folklore belief that bootstrapping cannot be made "too cheap."

**Test**: Formalize a notion of "bootstrapping circuit" as an `ArithCircuit` that, when evaluated homomorphically on a valid ciphertext and an encrypted secret key, produces a refreshed ciphertext. Prove that if this circuit has depth d, then maxNoise ≥ bNoise^(2^d) (by the exponential noise growth theorem), which gives d ≥ log₂(log₂(maxNoise/bNoise)).

**Impact**: This would establish the first formally verified complexity lower bound for FHE bootstrapping, connecting our noise growth analysis to circuit complexity. It would also provide a formal justification for why practical bootstrapping is expensive.

**Catalog References**: `Cryptography/FHE/Theorems.lean` (specifically `noise_exceeds_any_threshold` and `pow_two_pow_strict_mono`)

**Proof Strategy**:
1. Define a "bootstrapping circuit" predicate: a circuit that, applied homomorphically, converts any valid ciphertext to one with noise ≤ bNoise.
2. Use `noise_exceeds_any_threshold` to show that evaluating a depth-d circuit on a ciphertext with noise B yields noise ≤ B^(2^d).
3. For the bootstrapping circuit to work, its homomorphic evaluation must succeed, so the noise must stay below maxNoise.
4. This gives B^(2^d) ≤ maxNoise, hence d ≥ log₂(log₂(maxNoise/B)).

**Domain Bridges**: Cryptography <-> Computation (circuit complexity), Cryptography <-> EML (complexity measures)

**Lineage**: Directly extends the noise growth analysis from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Multi-Key Homomorphic Encryption Framework

**Conjecture**: The `BootstrappableHE` framework can be extended to a multi-key setting where ciphertexts encrypted under different keys can be combined homomorphically, with the decryption requiring all keys. Formally, there exists a `MultiKeyHE` structure with `hAdd : C sk₁ → C sk₂ → C (sk₁, sk₂)` satisfying analogous correctness and noise bounds, where the noise growth depends on the number of distinct keys involved.

**Test**: Define `MultiKeyHE` extending `BootstrappableHE` with a key-merging operation. Prove that refreshed evaluation over multi-key circuits preserves validity when the number of distinct keys is bounded by some function of the noise parameters. Identify the precise relationship between the number of keys and the achievable circuit depth.

**Impact**: Multi-key FHE is essential for multiparty computation (MPC) applications. Formalizing this would connect our framework to the multiparty CSIDH work already in the Catalog (`Cryptography/CSIFiShAdvanced.lean`).

**Catalog References**: `Cryptography/FHE/Defs.lean`, `Cryptography/CSIFiShAdvanced.lean` (multiparty key exchange), `Cryptography/CommitmentProtocol.lean`

**Proof Strategy**:
1. Parameterize ciphertext type by a set of keys: `C : Finset SK → Type`.
2. Define `hAdd` and `hMul` that merge key sets.
3. Noise grows with `|keys|` factor in multiplication.
4. Prove bootstrapping works when `bNoise^(2 · |keys|) < maxNoise`.

**Domain Bridges**: Cryptography <-> Cryptography (connecting FHE with MPC), Cryptography <-> Computation (distributed computation models)

**Lineage**: Extends the single-key `BootstrappableHE` from this cycle; connects to `multiparty_csidh_correctness` in the Catalog.

**Ambition**: extension

---

### Direction 5: Approximate Arithmetic HE (CKKS Formalization)

**Conjecture**: The CKKS scheme for approximate arithmetic can be formalized as a variant of `NoiseBoundedHE` where the correctness condition is relaxed from `dec(enc(m)) = m` to `|dec(enc(m)) - m| ≤ ε` for some precision parameter ε. The noise management framework extends to this approximate setting with the key modification that the "noise" now includes both the encryption error and the approximation error, and these interact multiplicatively.

**Test**: Define `ApproxHE` with `dec_enc_approx : |dec(enc(m)) - m| ≤ ε`. Prove that after d levels of multiplication, the approximation error is bounded by `ε · (1 + ε)^(2^d) - ε ≈ ε · 2^d` for small ε. Verify this matches known CKKS error bounds.

**Impact**: CKKS is the most practically important FHE scheme for machine learning and scientific computation. Formalizing its error propagation would provide the first verified error bounds for approximate homomorphic computation.

**Catalog References**: `Cryptography/FHE/Defs.lean`, `Cryptography/FHE/Theorems.lean`

**Proof Strategy**:
1. Define `ApproxHE` over ℝ with approximate correctness.
2. Track error and noise separately.
3. Prove error propagation bounds by induction on circuit depth.
4. Show bootstrapping in the approximate setting requires rescaling.

**Domain Bridges**: Cryptography <-> MachineLearning (encrypted inference), Cryptography <-> Physics (numerical precision in encrypted simulation)

**Lineage**: Extends the exact `NoiseBoundedHE` framework from this cycle to the approximate setting.

**Ambition**: extension
