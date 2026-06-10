# Categorical Semantics of Affine Σ-Protocol Extraction

**Abstract.** We develop a categorical framework for understanding witness extraction in affine Σ-protocols over finite fields. We show that the extraction map — which recovers a secret witness from two accepting transcripts at distinct challenges — is a natural section of a transcript-forming functor, and that this perspective yields three novel theorems: (1) extraction is the unique natural section satisfying a universal property, (2) extraction commutes with morphisms of affine witness systems (naturality), and (3) extractability is closed under sequential protocol composition. We prove that the categorical notion of "natural extraction" is equivalent to the classical algebraic condition of extraction rank (injectivity of the coefficient matrix's column map). All results are formally verified in Lean 4 with the Mathlib library, building on the `AffineSigmaExtraction` catalog. Computational experiments over small finite fields confirm the theorems and explore conjectural extensions.

---

## 1. Introduction

### 1.1 Motivation

Σ-protocols are the workhorses of zero-knowledge cryptography. The *special soundness* property — asserting that a witness can be extracted from two accepting transcripts with the same commitment but distinct challenges — is the foundation of their security guarantees. For affine Σ-protocols, where the verifier's acceptance equation is linear (or affine) in the witness and response, extraction reduces to solving a linear system over a finite field.

Despite the uniformity of this algebraic structure, extraction proofs in the literature are typically given on a protocol-by-protocol basis. Each new protocol variant requires a new (albeit similar) extraction argument. This raises a natural question: *is there a structural principle that explains why extraction works uniformly across all affine Σ-protocols?*

### 1.2 Contributions

We answer this question affirmatively by showing that extraction is a *categorical phenomenon*. Our main contributions are:

1. **Definitions.** We introduce `AffineWitnessSystem`, `AffineWitnessMorphism`, and related structures that organize affine Σ-protocols into a category (§3).

2. **Section Theorem** (Theorem 1). The extraction formula `(c₁ - c₂)⁻¹ · (z₁ - z₂)` recovers the matrix image `M·w` from valid transcripts. This is the section identity: extraction ∘ transcript = image (§4).

3. **Naturality Theorem** (Theorem 2). Extraction commutes with morphisms of affine witness systems. If `(φ, ψ)` is a morphism with `M₂·φ = ψ·M₁`, then `ψ · extract(z₁,z₂) = extract(ψ·z₁, ψ·z₂)` (§5).

4. **Composition Theorem** (Theorem 3). If systems `S₁` and `S₂` both have natural extraction, their composite `S₂ ∘ S₁` does too. The composite extractor is constructed explicitly (§6).

5. **Equivalence Theorem** (Theorem 4). Natural extraction is equivalent to extraction rank (injectivity of `M.mulVec`), certifying faithfulness of the categorical semantics (§7).

6. **Uniqueness Theorem** (Theorem 5). The image-level extraction section is unique on realizable transcripts (§7).

7. **Formal Verification.** All theorems are proved in Lean 4 with no `sorry` and only standard axioms (`propext`, `Classical.choice`, `Quot.sound`) (§9).

### 1.3 Related Work

The algebraic theory of Σ-protocol extraction has a long history, beginning with Schnorr's identification scheme and the Fiat-Shamir heuristic. Cramer's thesis systematically developed the linear-algebraic view. Maurer's abstract framework for Σ-protocols introduced algebraic generalizations but did not adopt categorical language. Concurrent work on "categorical cryptography" (Broadbent, Karvonen, and others) has explored monoidal categories for composable security, but has not specifically addressed the extraction/section structure we develop here.

Our work is most closely related to the `AffineSigmaExtraction` catalog, which formalizes the matrix-algebraic extraction theory. We reinterpret its results categorically and extend them with composition and naturality theorems.

---

## 2. Preliminaries

### 2.1 Notation

- `q` is a prime, `𝔽_q = ℤ/qℤ` the field with `q` elements.
- `𝔽_q^n` denotes the space `Fin n → 𝔽_q` of `n`-dimensional vectors.
- `M : 𝔽_q^{m×n}` is a matrix; `M·w` denotes matrix-vector multiplication.
- `c` denotes a challenge in `𝔽_q`; `t` denotes a commitment vector.

### 2.2 Affine Σ-Protocol Extraction

In an affine Σ-protocol with coefficient matrix `M`, the prover's response satisfies:

$$z = t + c \cdot M \cdot w$$

where `w ∈ 𝔽_q^n` is the witness, `t ∈ 𝔽_q^m` is the commitment randomness, and `c ∈ 𝔽_q` is the challenge.

Given two accepting transcripts `(z₁, c₁)` and `(z₂, c₂)` with `c₁ ≠ c₂` and the same commitment:

$$M \cdot w = (c_1 - c_2)^{-1} \cdot (z_1 - z_2)$$

This recovers `M·w`. If `M` has *extraction rank* (i.e., `M·(−)` is injective), then `w` is uniquely determined.

---

## 3. Definitions

### 3.1 Affine Witness System

**Definition 3.1.** An *affine witness system* over `𝔽_q` with parameters `(n, m)` is a matrix `M ∈ 𝔽_q^{m×n}`. The associated structures are:

- *Witness space*: `W = 𝔽_q^n`
- *Response space*: `R = 𝔽_q^m`
- *Transcript map*: `T(t, w, c) = t + c · M·w`
- *Extraction map*: `E(z₁, z₂, c₁, c₂) = (c₁-c₂)⁻¹ · (z₁ - z₂)`

```
structure AffineWitnessSystem (q : ℕ) [NeZero q] (n m : ℕ) where
  M : Matrix (Fin m) (Fin n) (ZMod q)
```

### 3.2 Morphisms

**Definition 3.2.** A *morphism* `(φ, ψ) : S₁ → S₂` between affine witness systems consists of matrices `φ ∈ 𝔽_q^{n₂×n₁}` and `ψ ∈ 𝔽_q^{m₂×m₁}` satisfying `M₂ · φ = ψ · M₁`.

This commutativity ensures that mapping a witness through `φ` and forming a transcript with `S₂` equals forming a transcript with `S₁` and mapping through `ψ`:

$$\psi \cdot T_{S_1}(t, w, c) = T_{S_2}(\psi \cdot t, \phi \cdot w, c)$$

### 3.3 Composition

**Definition 3.3.** The *composite* of `S₁ = (n, m₁, M₁)` and `S₂ = (m₁, m₂, M₂)` is `S₂ ∘ S₁ = (n, m₂, M₂ · M₁)`.

### 3.4 Extraction Predicates

**Definition 3.4.** System `S` has *extraction rank* if `M·(−)` is injective. It has *natural extraction* if there exists a function `ε` such that for all `t, w, c₁ ≠ c₂`:

$$\varepsilon(T(t, w, c_1), T(t, w, c_2), c_1, c_2) = w$$

---

## 4. Theorem 1: Extraction as a Section

**Theorem 4.1** (Section Property). *For any affine witness system `S`, commitment `t`, witness `w`, and distinct challenges `c₁ ≠ c₂`:*

$$E(T(t, w, c_1), T(t, w, c_2), c_1, c_2) = M \cdot w$$

*Proof sketch.* Expand definitions:

$$E(T(t,w,c_1), T(t,w,c_2), c_1, c_2)$$
$$= (c_1-c_2)^{-1} \cdot ((t + c_1 \cdot M \cdot w) - (t + c_2 \cdot M \cdot w))$$
$$= (c_1-c_2)^{-1} \cdot (c_1 - c_2) \cdot M \cdot w$$
$$= M \cdot w$$

The cancellation uses `(c₁-c₂)⁻¹ · (c₁-c₂) = 1` in the field `𝔽_q`.  ∎

This theorem says that extraction is a *section* (left inverse) of the transcript map at the image level.

---

## 5. Theorem 2: Naturality

**Theorem 5.1** (Naturality). *For any morphism `(φ, ψ) : S₁ → S₂` and any `z₁, z₂, c₁, c₂`:*

$$\psi \cdot E_{S_1}(z_1, z_2, c_1, c_2) = E_{S_2}(\psi \cdot z_1, \psi \cdot z_2, c_1, c_2)$$

*Proof sketch.* Both sides equal `(c₁-c₂)⁻¹ · ψ · (z₁ - z₂)`, using linearity of matrix-vector multiplication:

- LHS: `ψ · ((c₁-c₂)⁻¹ · (z₁-z₂))` = `(c₁-c₂)⁻¹ · ψ · (z₁-z₂)` (by `mulVec_smul`)
- RHS: `(c₁-c₂)⁻¹ · (ψ·z₁ - ψ·z₂)` = `(c₁-c₂)⁻¹ · ψ · (z₁-z₂)` (by `mulVec_sub`)  ∎

**Corollary 5.2.** *For valid transcripts arising from witness `w`, the naturality square commutes with the commutativity condition:*

$$\psi \cdot E_{S_1}(T_{S_1}(t,w,c_1), T_{S_1}(t,w,c_2)) = M_2 \cdot \phi \cdot w$$

This says: extracting from `S₁`-transcripts and mapping through `ψ` gives the same result as mapping the witness through `φ` and computing the `S₂`-image. This is special soundness expressed as a naturality condition.

---

## 6. Theorem 3: Compositional Extraction

**Theorem 6.1** (Composition). *If `S₁` and `S₂` both have natural extraction, then `S₂ ∘ S₁` has natural extraction.*

*Proof.* Let `ε₁, ε₂` be the extractors for `S₁, S₂`. Define:

$$\varepsilon_{\text{comp}}(z_1, z_2, c_1, c_2) = \varepsilon_1(\varepsilon_2(z_1, z_2, c_1, c_2), \mathbf{0}, 1, 0)$$

**Correctness.** Given valid composite transcripts `z_i = t + c_i · (M_2 · M_1) · w`:

1. These are valid `S₂`-transcripts for witness `M₁·w` and commitment `t`:
   $$z_i = t + c_i \cdot M_2 \cdot (M_1 \cdot w)$$

2. So `ε₂(z₁, z₂, c₁, c₂) = M₁ · w`.

3. Construct synthetic `S₁`-transcripts: `T_{S_1}(0, w, 1) = M_1 \cdot w` and `T_{S_1}(0, w, 0) = 0`.

4. So `ε₁(M₁·w, 0, 1, 0) = w`.

The key step uses `1 ≠ 0` in `𝔽_q` (valid since `q` is prime, hence `q ≥ 2`).  ∎

**Remark.** This theorem is not easily visible from the classical matrix-algebraic perspective. While `extraction_rank_comp` (injectivity of `(M₂·M₁)·(−)`) follows trivially from composition of injective functions, the *explicit construction of the composite extractor* — which factors through the individual extractors via synthetic transcripts — is a genuinely new contribution enabled by the categorical viewpoint.

---

## 7. Equivalence and Uniqueness

**Theorem 7.1** (Equivalence). *An affine witness system has natural extraction if and only if it has extraction rank.*

*Proof sketch.*

(⇒) If `ε` is a natural extractor and `M·w₁ = M·w₂`, then for any distinct `c₁ ≠ c₂` (e.g., 0 and 1), the transcripts for `w₁` and `w₂` are identical. So `w₁ = ε(...) = w₂`.

(⇐) If `M·(−)` is injective, let `g` be a left inverse (exists by `Function.Injective.hasLeftInverse`). Define `ε(z₁,z₂,c₁,c₂) = g(E(z₁,z₂,c₁,c₂))`. By the Section Theorem, on valid transcripts `E(...)  = M·w`, so `ε(...) = g(M·w) = w`.  ∎

**Theorem 7.2** (Uniqueness). *Any two image-level extraction sections agree on all realizable transcript pairs.*

This follows immediately: both sections compute `M·w` on valid transcripts, so they agree there.

---

## 8. Categorical Infrastructure

### 8.1 The Category of Affine Witness Systems

The category `AffWitSys(q)` has:
- **Objects**: pairs `(n, m, M)` where `M ∈ 𝔽_q^{m×n}`
- **Morphisms**: pairs `(φ, ψ)` with `M₂ · φ = ψ · M₁`
- **Identity**: `(I_n, I_m)`
- **Composition**: `(g.φ · f.φ, g.ψ · f.ψ)`

We verify associativity and identity laws formally. The composition proof uses `Matrix.mul_assoc` and the commutativity conditions of the composed morphisms.

### 8.2 Dependent Family Interpretation

We define `RealizableTranscriptPair` bundling two responses, two challenges, a witness, and proofs of realizability. The coherent elimination theorem states that extraction recovers `M·w` from any realizable pair. The fiber uniqueness theorem states that if two realizable pairs have the same `(z₁, z₂, c₁, c₂)` and the system has extraction rank, then they have the same witness.

This connects to type-theoretic semantics: the dependent family of witnesses indexed by their matrix images has contractible fibers, so elimination is coherent and unique.

---

## 9. Formal Verification

All definitions and theorems are formalized in Lean 4 with Mathlib. The file `Pythagorean/CategoricalExtraction.lean` contains:

| Theorem | Lines | Proof Technique |
|---------|-------|----------------|
| `extraction_is_section` | ~5 | `simp`, `inv_mul_cancel₀` |
| `extraction_naturality` | ~5 | `convert`, `simp`, `mulVec_sub` |
| `natural_extraction_comp` | ~15 | `use`, `convert`, `congr_arg`, `simp` |
| `hasNaturalExtraction_iff_extractionRank` | ~12 | `constructor`, `Function.invFun`, `simp` |
| `extraction_section_unique` | ~3 | `▸ rfl` rewriting |
| `extraction_rank_comp` | ~5 | `Function.Injective.comp`, `simp` |
| `coherent_elimination` | ~4 | `convert`, `extraction_is_section` |
| `fiber_uniqueness` | ~4 | `coherent_elimination`, `aesop` |
| `mulVec_comm` | ~3 | `congr_arg`, `norm_num` |
| `transcript_comm` | ~4 | `simp`, `rw` |

Axioms used: `propext`, `Classical.choice`, `Quot.sound` (standard).

---

## 10. Computational Experiments

### 10.1 Section Property Verification

We verified the section property for all witness systems with `M ∈ 𝔽_q^{m×n}` for `q ∈ {3, 5, 7}`, `n ≤ 3`, `m ≤ 4`, and all possible witnesses, commitments, and challenge pairs. In all cases, extraction correctly recovers `M·w`.

### 10.2 Naturality Verification

For systems over `𝔽_5` with `n = m = 2`, we tested all 12,500 input combinations and found zero naturality violations.

### 10.3 Compositional Extraction

We tested 20 random compositions over `𝔽_7` with dimensions up to 6. In all cases where both components had extraction rank, the composite also had extraction rank, confirming `extraction_rank_comp`.

### 10.4 Semantic Rigidity

Over `𝔽_3` with the Schnorr system, we enumerated all 54 realizable input patterns and confirmed that the canonical extractor is the unique function satisfying the section identity on realizable inputs.

---

## 11. Applications

### 11.1 Protocol Design

The framework provides an automatic verification pipeline: given a coefficient matrix `M`, compute its rank to determine extraction feasibility. This replaces ad hoc soundness proofs with a single linear-algebraic check.

### 11.2 Modular Protocol Composition

The Composition Theorem enables modular protocol design. Complex protocols can be built from simple, verified components:
- Layer 1: Encode witness (expansion, `M₁` tall matrix)
- Layer 2: Mix responses (permutation/rotation, `M₂` invertible)
- Layer 3: Compress (projection, `M₃` wide matrix)

If each layer has extraction rank, the pipeline does too.

### 11.3 Security Analysis

Morphisms that fail the commutativity condition `M₂·φ = ψ·M₁` are automatically flagged as potentially extraction-breaking. This provides a systematic approach to identifying transformations that compromise security.

---

## 12. Discussion and Future Work

### 12.1 Limitations

The current framework addresses only *affine* Σ-protocols with deterministic extraction. Extensions to polynomial protocols, multi-round protocols, and probabilistic extraction require additional categorical structure (e.g., monoidal categories, enrichment).

### 12.2 Future Directions

1. **Monoidal structure**: AND-composition of protocols as tensor products in `AffWitSys(q)`.
2. **Sheaf-theoretic extraction**: local-to-global extraction for protocols over distributed systems.
3. **Adjunctions**: characterizing the commitment/extraction interface as an adjunction.
4. **Non-affine protocols**: extending to polynomial acceptance conditions via algebraic geometry.
5. **Computational soundness**: connecting the categorical framework to computational security reductions.

---

## References

1. S. Eilenberg, S. Mac Lane. "General theory of natural equivalences." *Trans. AMS*, 1945.
2. C.-P. Schnorr. "Efficient signature generation by smart cards." *J. Cryptology*, 1991.
3. R. Cramer. "Modular design of secure yet practical cryptographic protocols." PhD thesis, Amsterdam, 1997.
4. U. Maurer. "Unifying zero-knowledge proofs of knowledge." *AFRICACRYPT*, 2009.
5. D. Chaum, T.P. Pedersen. "Wallet databases with observers." *CRYPTO*, 1992.
6. T. Okamoto. "Provably secure and practical identification schemes and corresponding signature schemes." *CRYPTO*, 1992.
7. The Mathlib Community. "Mathlib: a unified library of mathematics formalized." 2020–2024.
