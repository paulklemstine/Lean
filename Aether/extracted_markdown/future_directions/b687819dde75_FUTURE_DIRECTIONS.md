# Future Directions: Verified Algebraic Decoding Theory

## Synthesis

The five formally verified theorems in this work — the structural BCH bound, unique decoding radius, error locator annihilation, syndrome linear dependence, and Hankel rank bound — form a complete chain from code geometry to decoder correctness. However, they leave the algorithmic heart (Berlekamp-Massey) and several deep structural results (uniqueness of the locator, tight Hankel rank, generalization to non-primitive codes) as open targets for formalization. The directions below are ordered by a combination of tractability and impact: Direction 1 closes the most critical gap (BM verification), Direction 2 establishes the uniqueness that makes decoding well-defined, Direction 3 bridges to modern coding constructions, Direction 4 sharpens the Hankel rank connection, and Direction 5 aims at the grand challenge of verified post-quantum cryptographic primitives.

---

## Direction 1: Verified Berlekamp-Massey Algorithm

**Conjecture:** The Berlekamp-Massey algorithm, when implemented as a pure function in Lean 4 over an arbitrary field K, produces the unique monic polynomial of minimal degree that annihilates any given syndrome prefix of length N. Furthermore, when applied to syndromes from an error pattern of weight t with N ≥ 2t, the output polynomial equals the reversed error locator.

**Test:** Implement `berlekampMassey : (K : Type*) → [Field K] → [DecidableEq K] → ℕ → (ℕ → K) → K[X]` in Lean 4 and verify:
1. The output is monic.
2. The output annihilates the input prefix.
3. The output has minimal degree among all monic annihilators.
4. Applied to syndromes from weight-t errors with N ≥ 2t, it equals `errorLocatorPolyRev`.

Validate computationally by running the Lean function (via `#eval` over `ZMod p` or `GaloisField`) on 1000+ random syndrome sequences and comparing output degree to the known error weight.

**Impact:** This would complete the verified decoding pipeline: encode → corrupt → compute syndromes → BM → locate errors → correct. It would be the first machine-verified algebraic decoder.

**Catalog References:** `Algebra/CodingTheory/Theorems.lean : locator_annihilates_syndromeSeq`, `syndrome_linear_dependence`

**Proof Strategy:** Define BM as a tail-recursive function maintaining the LFSR invariant (C, B, L, m, b). Prove the loop invariant: at step n, C annihilates (S_0, …, S_{n-1}) and has minimal degree among monic annihilators. The key lemma is the discrepancy update: if Δ ≠ 0 and 2L ≤ n, the new C has degree n + 1 − L and still annihilates the extended prefix.

**Domain Bridges:** Coding theory ↔ computational algebra, verified algorithms, shift-register theory

**Lineage:** Builds directly on `locator_annihilates_syndromeSeq` and `syndrome_linear_dependence`

**Ambition:** ★★★★☆ — Substantial but tractable; the algorithm is well-understood and the invariant is standard

---

## Direction 2: Uniqueness of the Error Locator Polynomial

**Conjecture:** For an error pattern e of weight w over a field K with α having distinct powers on Fin n, if Λ is any monic polynomial of degree ≤ w that annihilates the syndrome sequence syndromeSeq(α, e), then Λ = errorLocatorPolyRev(α, e). Equivalently, the error locator is the unique minimal monic annihilator.

**Test:** 
1. Over GF(2^8), for 10,000 random error patterns of weight 1 ≤ w ≤ 16, verify that BM outputs exactly the reversed locator polynomial.
2. For each pattern, enumerate all monic polynomials of degree ≤ w (feasible for w ≤ 3 over small fields) and confirm uniqueness.
3. Attempt formalization: the key step is showing that if Λ ≠ errorLocatorPolyRev and both annihilate the syndrome sequence, then their difference (of degree < w) also annihilates, contradicting the linear independence of w distinct geometric progressions.

**Impact:** This theorem is the mathematical reason decoding is well-defined. Without it, the BM output is merely "some polynomial that works" rather than "the unique correct answer."

**Catalog References:** `Algebra/CodingTheory/Theorems.lean : locator_annihilates_syndromeSeq`, `Algebra/CodingTheory/Defs.lean : errorLocatorPolyRev`

**Proof Strategy:** Assume two distinct monic annihilators Λ₁, Λ₂ of degree ≤ w. Then Λ₁ − Λ₂ is a nonzero polynomial of degree < w that annihilates the syndrome sequence. But syndromeSeq(α, e, k) = Σ_j e_j (α^j)^k, and a nonzero annihilator of degree < w for a sum of w distinct exponentials contradicts the linear independence of {(α^{j₁})^k, …, (α^{jw})^k}_{k≥0}, which follows from the distinctness of α^{j₁}, …, α^{jw} and Vandermonde invertibility.

**Domain Bridges:** Linear algebra (Vandermonde systems), linear recurrence theory, uniqueness of Padé approximants

**Lineage:** Extends `locator_annihilates_syndromeSeq`; the Vandermonde argument mirrors `bch_bound_structural`

**Ambition:** ★★★★☆ — Deep but follows a known proof pattern

---

## Direction 3: Alternant and Goppa Code Generalization

**Conjecture:** The syndrome annihilation and linear dependence theorems extend to alternant codes defined by evaluation at arbitrary distinct points (not necessarily powers of a primitive root), with syndrome weights replaced by rational evaluation weights. Specifically, for an alternant code with evaluation points β₁, …, βₙ and column multipliers v₁, …, vₙ, the error locator ∏(X − βⱼ) for j ∈ supp(e) annihilates the generalized syndrome sequence s_k = Σ_j eⱼ vⱼ βⱼ^k.

**Test:**
1. Implement alternant code encoding/decoding over GF(2^8) with random evaluation points.
2. Verify that BM applied to alternant syndromes correctly recovers error positions for 1000+ random patterns.
3. Test classical Goppa codes (a special case with v_j = 1/g(β_j) for a Goppa polynomial g) over GF(2^m) for m = 4, 8, 12.

**Impact:** Classical Goppa codes are the basis of the McEliece cryptosystem, a leading candidate for post-quantum public-key encryption. Formally verified decoding of Goppa codes would be a major step toward verified post-quantum cryptography.

**Catalog References:** `Algebra/CodingTheory/Defs.lean : syndromeSeq, errorLocatorPolyRev`, `Algebra/CodingTheory/Theorems.lean : locator_annihilates_syndromeSeq`

**Proof Strategy:** Replace α^i with arbitrary βᵢ and eᵢ with eᵢvᵢ in the existing proofs. The Vandermonde argument generalizes immediately since it only requires distinctness of the evaluation points.

**Domain Bridges:** Coding theory ↔ post-quantum cryptography, algebraic geometry (via Goppa codes from algebraic curves)

**Lineage:** Direct generalization of the BCH/RS framework

**Ambition:** ★★★☆☆ — Conceptually straightforward; the main challenge is managing the additional parameters

---

## Direction 4: Tight Hankel Rank and Finite-Prefix Bounds

**Conjecture:** For an error pattern e of weight w with α having injective powers on Fin n:
1. (Tightness) rank(syndromeHankelMatrix(syndromeSeq(α, e), m)) = w for all m ≥ w, provided the error magnitudes are nonzero and the α^{iⱼ} are pairwise distinct.
2. (Finite prefix) The Berlekamp-Massey degree on the first 2w syndromes equals w.
3. (Detection) The rank profile of nested Hankel matrices (m = 1, 2, 3, …) increases by 1 at each step until m = w, then stabilizes. This profile distinguishes burst errors from random errors.

**Test:**
1. Over GF(2^8), compute Hankel matrices for 10,000 random error patterns and verify rank = weight for m ≥ weight.
2. Compare rank-growth curves for:
   - Random sparse errors (positions uniformly random)
   - Burst errors (consecutive positions)
   - Clustered errors (positions in small groups)
3. Test whether the rank profile classifies error types with >95% accuracy.

**Impact:** Tight Hankel rank transforms the upper bound into an exact characterization, enabling precise error weight estimation from syndrome data alone. The rank profile analysis could enable adaptive decoding strategies and error-pattern-aware channel coding.

**Catalog References:** `Algebra/CodingTheory/Theorems.lean : hankel_rank_le_weight, syndromeHankel_factored`

**Proof Strategy:** For tightness, show that the m×w matrix A = [e_j (α^j)^i] has rank w when all e_j ≠ 0 and the α^j are distinct (its w columns are scalar multiples of distinct Vandermonde columns, hence linearly independent). Then rank(H) = rank(A·B) = rank(A) = w when m ≥ w.

**Domain Bridges:** Structured linear algebra, compressed sensing (exact sparse recovery), system identification (McMillan degree), spectral estimation

**Lineage:** Sharpens `hankel_rank_le_weight`

**Ambition:** ★★★☆☆ — The tightness proof follows directly from Vandermonde independence; the rank profile analysis is empirical

---

## Direction 5 (Grand Challenge): Verified Post-Quantum Decoder Infrastructure

**Conjecture:** A complete, machine-verified RS/Goppa decoder can be extracted from a Lean 4 formalization into executable code (via Lean's compiler or code extraction), with performance sufficient for real-time communication applications, and with a formal certificate chain from the mathematical theorems through the algorithm to the executable binary.

**Test:**
1. Implement RS(255, 223) decoding in pure Lean 4 (without `sorry` or `native_decide`).
2. Benchmark against a C implementation; target within 100× slowdown for the pure Lean version.
3. Use `@[csimp]` to provide optimized implementations with verified equivalence.
4. Integrate with a verified TLS library to create an end-to-end certified communication stack.
5. Extend to McEliece/Niederreiter decoding for post-quantum key encapsulation.

**Impact:** This would demonstrate that formal verification can produce *deployable* cryptographic infrastructure, not just mathematical curiosities. A verified McEliece decoder would be a cornerstone of trustworthy post-quantum security.

**Catalog References:** All theorems in `Algebra/CodingTheory/`

**Proof Strategy:** Build incrementally:
1. Verify BM (Direction 1) → extract pure decoder
2. Verify Goppa extension (Direction 3) → extract McEliece decoder  
3. Optimize via `@[csimp]` lemmas proving equivalence of efficient implementations
4. Compose with verified networking/TLS infrastructure

**Domain Bridges:** Cryptography, verified systems, post-quantum security, trustworthy computing

**Lineage:** Culmination of all directions

**Ambition:** ★★★★★ — Multi-year effort; would be a landmark in verified systems research
