# Future Directions: Formalized Cryptographic Security in Lean 4

## Overview

This document outlines 5 concrete research directions opened by our formalization of the Schnorr protocol security theory. Each direction includes a precise theorem target, proposed Lean type signature, proof strategy, and cross-domain connections.

---

## 1. Generic Sigma-to-Fiat–Shamir Compiler Theorem

**Status:** Breakthrough-level

### Precise Statement

Any Sigma protocol satisfying completeness, special soundness, and HVZK admits a secure non-interactive proof system in the finite random oracle model under a forking hypothesis.

### Proposed Lean Signature

```lean
theorem generic_fiat_shamir_compiler
    {Stmt Wit Chal Resp Commit : Type*}
    [Fintype Chal] [DecidableEq Chal]
    (Σ : SigmaProtocolSecurity Stmt Wit Chal Resp Commit)
    (extract : Stmt → Commit → Chal → Resp → Chal → Resp → Wit)
    (h_extract : ∀ stmt com c₁ r₁ c₂ r₂,
      c₁ ≠ c₂ →
      Σ.verify stmt com c₁ r₁ →
      Σ.verify stmt com c₂ r₂ →
      Σ.relation stmt (extract stmt com c₁ r₁ c₂ r₂))
    (H : Stmt → Commit → Chal)
    (A_out₁ A_out₂ : Stmt × Commit × Resp)
    (hsame_com : A_out₁.2.1 = A_out₂.2.1)
    (hsame_stmt : A_out₁.1 = A_out₂.1)
    (hdiff_chal : H A_out₁.1 A_out₁.2.1 ≠ H A_out₂.1 A_out₂.2.1)
    (hacc₁ : Σ.verify A_out₁.1 A_out₁.2.1 (H A_out₁.1 A_out₁.2.1) A_out₁.2.2)
    (hacc₂ : Σ.verify A_out₂.1 A_out₂.2.1 (H A_out₂.1 A_out₂.2.1) A_out₂.2.2) :
    ∃ w, Σ.relation A_out₁.1 w
```

### Proof Strategy

1. From the two accepting runs with same commitment and different challenges, apply the extractor.
2. The extractor produces a witness by `h_extract`.
3. This is purely algebraic — no probability theory needed.

### Cross-Domain Connection

This connects formal algebra to abstract complexity-theoretic cryptography: any secure interactive proof system can be automatically compiled to a secure signature scheme. Links to the theory of interactive proofs (IP = PSPACE) and the PCP theorem.

---

## 2. Machine-Checked Security Reduction: Schnorr Signatures → Discrete Log

**Status:** Breakthrough-level

### Precise Statement

If an adversary can forge Schnorr signatures in the random oracle model with non-negligible probability, then a discrete log solver can be constructed with related advantage.

### Proposed Lean Signature

```lean
/-- A discrete log solver. -/
structure DLogSolver (G : Type*) (q : ℕ) where
  solve : G → G → Option (ZMod q)

/-- A signature forger. -/
structure Forger (G : Type*) (q : ℕ) where
  forge : G → G → (G → G → Bytes → ZMod q) → 
          Option (Bytes × Signature G q)

theorem schnorr_sig_to_dlog_reduction
    {q : ℕ} [Fact q.Prime]
    {G : Type*} [CommGroup G] [Fintype G]
    (g : G) (hg : orderOf g = q)
    (hcard : Fintype.card G = q)
    (F : Forger G q)
    (h_success : ∀ y H, 
      (F.forge g y H).isSome → 
      let ⟨msg, sig⟩ := (F.forge g y H).get
      schnorr_sig_verify g y H msg sig) :
    ∃ S : DLogSolver G q, 
      ∀ y, (S.solve g y).isSome → 
        y = gpow g ((S.solve g y).get)
```

### Proof Strategy

1. Given a forger F, construct a DLog solver by:
   a. Running F with a programmed random oracle H₁
   b. Rewinding and running F again with H₂ that differs at one query
   c. Applying the forking extractor to the two forgeries
2. Requires formalizing the probabilistic forking lemma over finite oracle spaces.

### Cross-Domain Connection

Bridges formal algebra to provable security. Connects to complexity theory (worst-case to average-case reductions), coding theory (extraction as unique decoding), and the broader program of machine-checked security proofs for deployed protocols.

---

## 3. OR-Composition of Sigma Protocols with HVZK Preserved

### Precise Statement

Given two Sigma protocols Σ₁ and Σ₂, construct a composed protocol proving knowledge of a witness for statement₁ OR statement₂, preserving completeness, special soundness, and HVZK.

### Proposed Lean Signature

```lean
def or_compose 
    (Σ₁ : SigmaProtocolSecurity Stmt₁ Wit₁ Chal Resp₁ Com₁)
    (Σ₂ : SigmaProtocolSecurity Stmt₂ Wit₂ Chal Resp₂ Com₂)
    [Field Chal] :
    SigmaProtocolSecurity 
      (Stmt₁ × Stmt₂) 
      (Wit₁ ⊕ Wit₂) 
      Chal 
      (Resp₁ × Resp₂ × Chal) 
      (Com₁ × Com₂) := sorry

theorem or_compose_completeness
    (Σ₁ : SigmaProtocolSecurity Stmt₁ Wit₁ Chal Resp₁ Com₁)
    (Σ₂ : SigmaProtocolSecurity Stmt₂ Wit₂ Chal Resp₂ Com₂)
    [Field Chal] :
    ∀ stmt wit rand chal,
      (or_compose Σ₁ Σ₂).relation stmt wit →
      (or_compose Σ₁ Σ₂).verify stmt 
        ((or_compose Σ₁ Σ₂).commit wit rand) chal 
        ((or_compose Σ₁ Σ₂).respond wit rand chal)
```

### Proof Strategy

1. The composed protocol splits the challenge c into c₁ + c₂ = c.
2. The prover honestly executes one side and simulates the other.
3. Completeness: the honest side always accepts; the simulated side accepts by simulator_accepts.
4. Special soundness: extracting from two transcripts recovers the witness for at least one statement.
5. HVZK: the simulator simulates both sides.

### Cross-Domain Connection

OR-composition is fundamental to anonymous credentials (proving you have one of several attributes without revealing which). Connects to lattice theory (OR of lattice statements), graph theory (OR of graph isomorphisms), and the theory of NP witness relations.

---

## 4. Exact Challenge-Space Soundness Bounds as Finite Counting Arguments

### Precise Statement

For the Schnorr protocol over a prime-order group, if no discrete log witness exists for statement y, then for any fixed commitment a, at most one challenge c admits a valid response. This gives exact soundness error 1/q.

### Proposed Lean Signature

```lean
theorem schnorr_soundness_exact
    {q : ℕ} [Fact q.Prime]
    {G : Type*} [CommGroup G] [Fintype G]
    (g : G) (hg : orderOf g = q)
    (hcard : Fintype.card G = q)
    (y a : G) (c₁ c₂ : ZMod q) (z₁ z₂ : ZMod q)
    (h₁ : Verify g y ⟨a, c₁, z₁⟩)
    (h₂ : Verify g y ⟨a, c₂, z₂⟩) :
    c₁ = c₂ ∨ ∃ x : ZMod q, y = gpow g x

theorem schnorr_soundness_ratio
    {q : ℕ} [Fact q.Prime]
    {G : Type*} [CommGroup G] [Fintype G]
    (g : G) (hg : orderOf g = q)
    (hcard : Fintype.card G = q)
    (y : G) (hnowit : ¬ ∃ x : ZMod q, y = gpow g x)
    (a : G) :
    (Finset.univ.filter fun c => ∃ z, Verify g y ⟨a, c, z⟩).card ≤ 1
```

### Proof Strategy

1. Suppose two challenges c₁ ≠ c₂ both have valid responses.
2. Apply special soundness to extract a witness x with y = g^x.
3. This contradicts hnowit.
4. By contradiction, at most one challenge works.
5. The soundness error is exactly |{accepting challenges}| / q ≤ 1/q.

### Cross-Domain Connection

Connects to information-theoretic security, entropy bounds, and the algebraic structure of error-correcting codes. The "at most one valid opening" property is analogous to minimum distance in coding theory. Also connects to the Schwartz-Zippel lemma (soundness via polynomial identity testing).

---

## 5. Finite Probability Monad for Quantitative Security Analysis

### Precise Statement

Define a formal probability monad over finite types that supports uniform sampling, conditional probability, and statistical distance. Use it to state and prove quantitative security bounds for Schnorr and Fiat-Shamir.

### Proposed Lean Signature

```lean
/-- A finite probability distribution over type α. -/
structure FinDist (α : Type*) [Fintype α] where
  pmf : α → ℚ≥0
  sum_one : ∑ x, pmf x = 1

/-- Uniform distribution over a finite type. -/
def uniform (α : Type*) [Fintype α] [Nonempty α] : FinDist α := sorry

/-- Statistical distance between two distributions. -/
def statDist {α : Type*} [Fintype α] (D₁ D₂ : FinDist α) : ℚ≥0 :=
  (∑ x, |D₁.pmf x - D₂.pmf x|) / 2

/-- Perfect HVZK: statistical distance between real and simulated is zero. -/
theorem schnorr_perfect_hvzk
    {q : ℕ} [Fact q.Prime]
    {G : Type*} [CommGroup G] [Fintype G]
    (g : G) (hg : orderOf g = q)
    (hcard : Fintype.card G = q)
    (x : ZMod q) :
    statDist 
      (realTranscriptDist g x) 
      (simTranscriptDist g (gpow g x)) = 0
```

### Proof Strategy

1. Define `FinDist` as a PMF (probability mass function) with sum = 1.
2. Define real and simulated transcript distributions as pushforwards of the uniform distribution on ZMod q × ZMod q.
3. Use the bijection theorem (`schnorr_hvzk_bijection`) to show the pushforward measures agree.
4. Conclude statistical distance = 0.

### Cross-Domain Connection

This creates infrastructure for all of quantitative cryptography in Lean: security bounds, advantage definitions, reduction-based proofs with exact probability accounting. Connects to measure theory (finite measures as special case), information theory (entropy, mutual information), and complexity theory (BPP, ZPP characterizations). Would enable formalization of the quantitative forking lemma [PS00] and tight security reductions.

---

## Research Team Organization

### Team 1: Algebraic Infrastructure
- Extend gpow API to support multi-generator settings
- Formalize the discrete log assumption as a type class
- Build certified group parameter generation

### Team 2: Sigma Protocol Library
- Formalize Guillou-Quisquater, Okamoto, and Pedersen protocols
- Implement and verify OR/AND/threshold compositions
- Prove generic Fiat-Shamir compiler theorem

### Team 3: Quantitative Security
- Build finite probability monad
- Formalize game-based security definitions
- Prove quantitative forking lemma with exact bounds

### Team 4: Applications
- Formalize Schnorr signature scheme with concrete security
- Verify EdDSA parameter choices
- Connect to elliptic curve group formalizations in Mathlib

---

## Timeline

**Phase 1 (3 months):** Directions 4 and 5 — exact soundness bounds and probability monad. These build directly on the current formalization.

**Phase 2 (6 months):** Direction 3 — OR-composition. Requires extending the abstract interface with extractors.

**Phase 3 (12 months):** Directions 1 and 2 — generic compiler and signature reduction. These are the breakthrough targets requiring the full infrastructure.

## References

[PS00] D. Pointcheval, J. Stern. Security arguments for digital signatures and blind signatures. J. Cryptology, 2000.

[CDS94] R. Cramer, I. Damgård, B. Schoenmakers. Proofs of partial knowledge and simplified design of witness hiding protocols. CRYPTO 1994.

[BPR00] M. Bellare, D. Pointcheval, P. Rogaway. Authenticated key exchange secure against dictionary attacks. EUROCRYPT 2000.
