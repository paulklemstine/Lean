# Future Research Directions

## Synthesis

This research cycle established a formalized foundation for code-based cryptography through the McEliece cryptosystem, proving 30+ theorems covering Goppa code parameters, the Berlekamp-McEliece-van Tilborg hardness reduction, Information Set Decoding work factor bounds, and post-quantum security parameter verification. The most unexpected discovery was the clean formal equivalence between syndrome decoding and closest vector finding (Theorem `sdp_is_cvp_hamming`), which reveals that code-based and lattice-based cryptography are not merely analogous but formally isomorphic when restricted to binary structures.

The deepest result is the choose lower bound `C(n,t) ≥ (n/t)^t`, proved via the product representation of binomial coefficients. This bound, combined with the verified parameter sets for mceliece8192128 and mceliece6960119, provides machine-checked evidence that McEliece achieves 256-bit post-quantum security with concrete parameters.

The most promising cross-domain connection is the Hamming-Euclidean bridge (`binary_embedding_norm_eq_weight`), which shows that Hamming weight exactly equals squared Euclidean norm under binary embedding. This opens a path to transferring lattice reduction techniques (LLL, BKZ) to code-based problems and vice versa—potentially yielding new attacks or new hardness proofs by translating between metric spaces.

---

### Direction 1: Tight ISD Bounds and the BJMM Algorithm

**Conjecture**: The BJMM Information Set Decoding algorithm achieves work factor at most 2^(0.0953n) for codes of rate 1/2, and this exponent is optimal among ISD-type algorithms. Formally, for n-bit codes with t = n/2 - o(n) errors, the ISD work factor W satisfies log₂(W)/n → c where c ≈ 0.0953.

**Test**: Formalize the BJMM collision-finding step (using representations) and prove that the expected number of iterations satisfies the bound W ≤ 2^(cn) for explicit constant c. Compare with the naive ISD bound C(n,t)/C(n-k,t) proved in this cycle.

**Impact**: If proved, this gives the tightest known formal security bound for McEliece. If the optimality claim fails, it suggests room for better attacks—a finding of immense cryptographic importance.

**Catalog References**: `Cryptography/McEliece/Security.lean` (choose_lower_bound, isd_work_factor_exponential_growth), `Catalog/Catalog/Cryptography/LWE/HardnessReduction.lean` (hybrid argument techniques)

**Proof Strategy**: Decompose into (a) the birthday paradox for finding collisions among partial solutions, (b) the representation technique that trades memory for time, and (c) the Stern/Dumer tree structure. The key lemma is that the number of representations of a weight-p/2 vector as a sum of two weight-p/4 vectors is C(k/2, p/4)².

**Domain Bridges**: Code-based ISD ↔ Lattice sieving algorithms (both use nearest-neighbor search in high-dimensional spaces)

**Lineage**: Extends choose_lower_bound and isd_work_factor_exponential_growth from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Wild Goppa Codes and Enhanced Minimum Distance

**Conjecture**: Wild Goppa codes (where the Goppa polynomial g(x) is a perfect p-th power, g(x) = h(x)^p over GF(p^m)) have minimum distance at least (p+1)t + 1, a factor of (p+1)/2 better than the standard 2t+1 bound for ordinary binary Goppa codes. This enhanced distance comes from the deeper algebraic structure of the alternant matrix.

**Test**: Formalize the definition of wild Goppa codes over GF(2^m) with g(x) = h(x)² (the simplest wild case, p=2). Prove that the parity-check matrix has rank at most n - 2·deg(h), giving dimension ≥ n - 2·deg(h) versus the naive n - deg(g) = n - 2·deg(h). Then prove the enhanced minimum distance d ≥ 3·deg(h) + 1 by analyzing the kernel of the alternant map.

**Impact**: Wild Goppa codes allow smaller parameters for the same security level, directly reducing McEliece key sizes by a factor of approximately (p+1)/2. This is one of the most promising directions for practical McEliece optimization.

**Catalog References**: `Cryptography/McEliece/Defs.lean` (GoppaCodeParams, goppa_error_correction), `Cryptography/McEliece/Hardness.lean` (goppa_min_dist_ge_3)

**Proof Strategy**: Define the wild Goppa code as the kernel of the enhanced alternant matrix A = (α_j^i / g(α_j)) for i = 0, ..., pt-1. Prove that g(x) = h(x)^p implies certain linear dependencies among rows, reducing the effective rank. The minimum distance proof uses the fact that low-weight codewords would imply that h(x) has too many roots.

**Domain Bridges**: Algebraic geometry codes (AG codes) ↔ Goppa codes (Goppa codes are a special case of one-point AG codes on the projective line)

**Lineage**: Extends goppa_error_correction and goppa_min_dist_ge_3 from this cycle.

**Ambition**: extension

---

### Direction 3: Formal Distinguishing Reduction for McEliece

**Conjecture**: There exists a formal polynomial-time reduction from the problem of distinguishing a scrambled Goppa code generator matrix from a random binary matrix to the problem of decoding the Goppa code. Specifically, if A is an algorithm that distinguishes Goppa from random with advantage ε, then there exists a decoder B that decodes with probability at least ε/n.

**Test**: Formalize the distinguisher-to-decoder reduction by constructing the decoder B as follows: given a ciphertext c = mG + e, modify one column of the public key and use A to detect the modification. If A can distinguish, the modified column corresponds to an error position. Prove that the advantage loss is at most a factor of n.

**Impact**: This reduction is the formal justification for the McEliece security assumption: if distinguishing is hard, then so is decoding. Without this reduction, the indistinguishability and decoding assumptions are separate, and the cryptosystem requires both to hold.

**Catalog References**: `Cryptography/McEliece/Security.lean` (GoppaDistinguisher, SyndromeDecodingInstance), `Catalog/Catalog/Cryptography/LWE/HardnessReduction.lean` (hybrid argument)

**Proof Strategy**: Use a hybrid argument: define n+1 hybrid distributions where hybrid i has the first i columns from the Goppa code and the remaining n-i columns random. The distinguishing advantage between adjacent hybrids is at least ε/n. Each adjacent pair can be used to extract information about one error position. Accumulating n such extractions gives the full error vector.

**Domain Bridges**: McEliece distinguishing ↔ LWE search-to-decision reduction (both use column-by-column hybrid arguments)

**Lineage**: Extends the SDP/CVP bridge theorem (sdp_is_cvp_hamming) and the GoppaDistinguisher definition from this cycle.

**Ambition**: grand_challenge

---

### Direction 4: Formalized Patterson Decoding Algorithm

**Conjecture**: The Patterson algorithm for binary Goppa codes can be formalized to show that it runs in O(n²) field operations over GF(2^m) and correctly decodes any error pattern of weight at most t.

**Test**: Formalize the three steps of Patterson's algorithm: (1) compute the syndrome polynomial S(x) = Σ (e_j)/(x - α_j) mod g(x); (2) compute the error locator polynomial σ(x) via the key equation S(x)σ(x) ≡ ω(x) mod g(x); (3) find the roots of σ(x) to locate errors. Prove correctness: if wt(e) ≤ t, then the roots of σ(x) are exactly the error positions.

**Impact**: Patterson decoding is the efficient operation that makes McEliece's secret key useful. Without it, the cryptosystem has no efficient decryption. Formalizing it closes the gap between "the problem is hard" and "the authorized party can solve it efficiently."

**Catalog References**: `Cryptography/McEliece/Defs.lean` (GoppaCodeParams, McEliecePublicKey), `Cryptography/McEliece/Security.lean` (goppa_meets_gv_rate)

**Proof Strategy**: The key insight is that for binary Goppa codes, the syndrome polynomial satisfies S(x)² + S(x) ≡ x mod g(x), which allows computing the square root τ(x) = √(S(x)⁻¹ + x) mod g(x). Then σ(x) = τ(x)² + x and ω(x) = τ(x) + x·σ(x). Prove that deg(σ) ≤ t and that σ has exactly wt(e) distinct roots in the support set.

**Domain Bridges**: Patterson algorithm ↔ Berlekamp-Massey algorithm (both solve key equations over finite fields; Patterson is the Goppa-specific optimization)

**Lineage**: Extends goppa_error_correction and error_recovery_gf2 from this cycle.

**Ambition**: extension

---

### Direction 5: Quantum ISD Lower Bounds

**Conjecture**: Any quantum algorithm for Information Set Decoding requires at least Ω(C(n,t)^(1/3)) quantum queries, improving the naive Grover bound of Ω(C(n,t)^(1/2)) for structured quantum search.

**Test**: Formalize the quantum query complexity lower bound using the adversary method (or polynomial method). Show that the structure of the ISD problem—the fact that the search space has combinatorial structure (weight-t vectors) rather than being unstructured—does not help quantum algorithms beyond Grover's speedup. Alternatively, show that Kachigar-Tillich quantum ISD achieves C(n,t)^(1/3) operations, matching the conjectured lower bound.

**Impact**: If quantum ISD is truly limited to O(C(n,t)^(1/2)) rather than O(C(n,t)^(1/3)), then McEliece parameters could be reduced (smaller keys). If the 1/3 exponent is tight, current parameters may need to be increased for long-term security. This directly affects the NIST standardization parameter choices.

**Catalog References**: `Cryptography/McEliece/Security.lean` (postQuantumSecBits, level5_exceeds_256bit_quantum), `Cryptography/McEliece/Bridge.lean` (two_512_lt_768)

**Proof Strategy**: Use the quantum adversary bound framework. Define the relation R ⊆ X × Y where X is the set of codes and Y is the set of decodings. Compute the adversary bound Adv(R) by analyzing the collision structure of weight-t vectors. The key lemma is that the "certificate complexity" of verifying a decoding is O(t) but the "decision tree complexity" is Ω(C(n,t)).

**Domain Bridges**: Quantum query complexity ↔ Classical ISD complexity (understanding the quantum-classical gap for structured search problems)

**Lineage**: Extends postQuantumSecBits and level5_exceeds_256bit_quantum from this cycle.

**Ambition**: grand_challenge
