# Future Directions: Code-Based Cryptography

## Synthesis

This research cycle established a formal foundation for the McEliece cryptosystem, proving decryption correctness, IND-CPA security under the Goppa Code Distinguishing assumption, and quantum resistance via Grover's lower bound. The multi-hybrid telescope lemma proved here is a general-purpose tool applicable to any cryptographic game-hopping argument, and connects to the hybrid telescope bounds already present in the Catalog's LWE security proofs (`Cryptography/Security.lean`). The permutation invariance of Hamming weight, while conceptually simple, required a careful bijection argument and is a necessary structural result for any code-based cryptographic formalization.

The most promising cross-domain connection is between **coding theory** and **lattice-based cryptography**. Both the McEliece system and LWE-based systems (already formalized in the Catalog) can be viewed through the lens of "structured noise plus linear algebra." The GCD assumption for codes mirrors the decisional LWE assumption for lattices: both ask whether a structured matrix is distinguishable from a random one. A unifying framework could yield shared proof infrastructure and potentially new cryptographic constructions.

The highest breakthrough potential lies in Direction 1 (Algebraic Goppa Code Distinguishing), because resolving — or making progress on — the computational hardness of GCD would have direct implications for the security guarantees of the NIST-standardized McEliece parameters.

---

### Direction 1: Algebraic Goppa Code Distinguishing via Filtration Rank

**Conjecture**: For binary Goppa codes Γ(L, g) with irreducible g of degree t over GF(2^m) and |L| = n = 2^m, the parity-check matrix H has a filtration structure (induced by powers of g) that no random matrix possesses, yet detecting this filtration requires solving a problem at least as hard as the Syndrome Decoding Problem (which is NP-complete).

**Test**: For small parameters (m = 4, n = 16, t = 2), enumerate all binary [16, k, ≥5] codes and compute what fraction admit a filtration by squarefree polynomial ideals. If the fraction is negligibly small (< 1/2^10), this supports the conjecture that the filtration is a distinguishing feature that is hard to detect without the secret key.

**Impact**: If true, this provides a structural explanation for why GCD is hard and connects code-based hardness to ideal-theoretic invariants in commutative algebra. If false (many random codes admit similar filtrations), it would suggest that current GCD-based security proofs may need strengthening.

**Catalog References**: `Cryptography/McEliece/Defs.lean` (GoppaParams, LinearCode), `Cryptography/McEliece/Security.lean` (mcEliece_indcpa_from_gcd)

**Proof Strategy**: Define a filtration rank invariant for parity-check matrices over GF(2). Show that Goppa codes have filtration rank exactly t (from the degree of g). Then reduce detecting filtration rank to syndrome decoding, using the known NP-completeness of the latter. Key lemma: the filtration rank of a uniformly random matrix is 0 with high probability.

**Domain Bridges**: commutative_algebra (filtrations, ideal theory) ↔ coding_theory (parity-check structure) ↔ complexity_theory (NP-hardness)

**Lineage**: Builds on the GCD assumption formalized in this cycle's mcEliece_indcpa_from_gcd theorem. Extends the algebraic approach of Faugère-Otmani-Perret-Tillich (2013) on distinguishing Goppa codes.

**Ambition**: grand_challenge

---

### Direction 2: Unified Game-Hopping Framework for Code and Lattice Cryptography

**Conjecture**: The multi-hybrid telescope lemma (proved in this cycle for arbitrary game sequences) can be instantiated to simultaneously derive IND-CPA security for both McEliece (under GCD) and Dual-Regev (under LWE), using a shared proof kernel that factors through an abstract "structured-vs-random matrix" distinguishing game.

**Test**: Formalize an abstract `MatrixDistinguishing` structure parameterized by the matrix distribution and the noise model. Instantiate it for (a) GCD with GF(2) Goppa matrices and additive errors, and (b) LWE with ZMod q matrices and Gaussian errors. If both instantiations produce valid IND-CPA reductions via the same abstract theorem, the conjecture is confirmed.

**Impact**: This would unify two major families of post-quantum cryptography under a single formal framework, reducing duplicated proof effort and potentially revealing new intermediate constructions.

**Catalog References**: `Cryptography/Security.lean` (hybrid_telescope_bound, dualRegev_cpa_security_of_lwe), `Cryptography/McEliece/Security.lean` (multi_hybrid_bound, mcEliece_indcpa_from_gcd)

**Proof Strategy**: Define a typeclass `MatrixDistinguishingAssumption` with fields for the matrix distribution, noise distribution, and distinguishing advantage. Prove an abstract IND-CPA theorem parameterized by this typeclass. Then provide instances for GCD and LWE. The key lemma is showing that "random matrix ⟹ ciphertext indistinguishable from uniform" holds in both settings.

**Domain Bridges**: lattice_cryptography (LWE, Dual-Regev) ↔ code_cryptography (McEliece, GCD) ↔ category_theory (abstract cryptographic games as functors)

**Lineage**: Builds on multi_hybrid_bound from this cycle and hybrid_telescope_bound from Catalog's Cryptography/Security.lean.

**Ambition**: extension

---

### Direction 3: Tight Quantum ISD Lower Bounds via Polynomial Method

**Conjecture**: The quantum query complexity of Information Set Decoding for a random [n, k, d] code with d = 2t+1 is exactly Θ(√(C(n,t)/C(n-k,t))), matching the Grover lower bound applied to the specific ISD search space — not just the naive √(2^n) bound.

**Test**: Formalize the polynomial method (Beals et al. 2001) for quantum query lower bounds. Apply it to the ISD decision problem: "given a matrix G and target c, does there exist e with wt(e) ≤ t such that c - Ge = 0?" Show the quantum query complexity is at least √S where S is the number of information sets to search.

**Impact**: A tight quantum lower bound would precisely determine McEliece's quantum security level, potentially allowing smaller parameters (and thus smaller keys) while maintaining security guarantees.

**Catalog References**: `Cryptography/McEliece/Security.lean` (quantum_isd_advantage, grover_quadratic_bound, isd_work_factor_exponential)

**Proof Strategy**: Formalize quantum query complexity as a polynomial degree bound. Define the ISD search problem as an oracle function f : {subsets of size k} → {0, 1}. Use the polynomial method to show deg(p) ≥ √(|dom(f)|/|f^{-1}(1)|) for any polynomial p representing a quantum algorithm. Instantiate with ISD parameters.

**Domain Bridges**: quantum_computing (query complexity) ↔ combinatorics (binomial coefficient asymptotics) ↔ coding_theory (ISD algorithms)

**Lineage**: Extends quantum_isd_advantage and grover_quadratic_bound from this cycle. Connects to quantum complexity work by Ambainis (2002) and Beals et al. (2001).

**Ambition**: grand_challenge

---

### Direction 4: Patterson's Algorithm Formalization

**Conjecture**: Patterson's algorithm for decoding binary Goppa codes can be formalized as a deterministic algorithm running in O(n²) field operations over GF(2^m), with a machine-verified correctness proof that it recovers the error vector whenever wt(e) ≤ t.

**Test**: Formalize GF(2^m) arithmetic and polynomial operations in Lean 4. Implement the key step: computing the error locator polynomial σ(x) from the syndrome S(x) via σ²(x) + x ≡ S(x)^{-1} (mod g(x)), followed by root-finding. Verify that the roots of σ correspond to error positions.

**Impact**: This would complete the McEliece formalization by providing a verified decoder, removing the need for the abstract BDDecoder assumption. It would also be the first formalization of Patterson's algorithm in any proof assistant.

**Catalog References**: `Cryptography/McEliece/Defs.lean` (BDDecoder, GoppaCode), `Cryptography/McEliece/Security.lean` (mcEliece_decrypt_correct)

**Proof Strategy**: 
1. Formalize polynomial ring GF(2^m)[x] and the mod operation.
2. Define the syndrome S(x) = Σ cᵢ/(x - αᵢ) mod g(x).
3. Prove: if wt(e) ≤ t, then S(x) = Σ eᵢ/(x - αᵢ) mod g(x).
4. Prove: the Goppa square root equation σ²(x) + x·σ(x) ≡ S(x)^{-1} (mod g(x)) has a unique solution of degree ≤ t/2.
5. Prove: roots of σ are exactly the error positions.

**Domain Bridges**: algebra (polynomial rings, field extensions) ↔ coding_theory (syndrome decoding) ↔ algorithms (root finding)

**Lineage**: Directly extends BDDecoder from this cycle's Defs.lean. Based on Patterson (1975) and classical coding theory.

**Ambition**: extension

---

### Direction 5: Code-Based Signature Schemes via Goppa Codes

**Conjecture**: The Courtois-Finiasz-Sendrier (CFS) signature scheme based on Goppa codes achieves EUF-CMA security under the GCD assumption plus a "complete decoding" assumption, and the expected number of hash-then-decode attempts is C(n,t)/2^(n-k), which is polynomial when t = O(√(n/log n)).

**Test**: Formalize the CFS signature scheme (hash → try to decode → repeat). Prove that the expected iteration count is C(n,t)/2^(n-k) by modeling the syndrome distribution. For parameters n = 2^20, t = 9, verify computationally that C(n,t)/2^(n-k) ≈ 1 and the scheme is practical.

**Impact**: Code-based signatures are a major open problem in post-quantum cryptography. A formal security proof would significantly advance the field and complement the McEliece encryption formalization.

**Catalog References**: `Cryptography/McEliece/Defs.lean` (GoppaCode, GoppaParams), `Cryptography/McEliece/Security.lean` (mcEliece_indcpa_from_gcd, isd_work_factor_exponential)

**Proof Strategy**: Define the CFS signature scheme as a structure with Sign and Verify functions. The security reduction shows: any EUF-CMA forger can be converted to either (a) a GCD distinguisher or (b) a decoder for random codes. Use the multi-hybrid telescope to handle the hash-then-decode loop. The key technical lemma: the fraction of decodable syndromes in a Goppa code is approximately C(n,t)/2^(n-k).

**Domain Bridges**: digital_signatures (EUF-CMA security) ↔ coding_theory (syndrome coverage) ↔ probability_theory (coupon collector variants)

**Lineage**: Extends the GCD assumption and game-hopping infrastructure from this cycle. Based on Courtois-Finiasz-Sendrier (2001).

**Ambition**: extension
