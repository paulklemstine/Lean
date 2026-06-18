# Future Directions: Certified Probabilistic Complexity Theory

This document outlines breakthrough research opportunities opened by the formalization of streaming interactive verification for matrix products over finite fields.

---

## 1. Exact Acceptance Probability for Rank-Deficient Discrepancies

**Hypothesis:** When the discrepancy matrix `D = K - A*B` has rank `r`, the acceptance set `{v | D.mulVec v = 0}` has cardinality exactly `q^(p - r)`, giving acceptance probability `q^{-r}`.

**Proof Strategy:**
- Formalize the rank-nullity theorem for finite-dimensional vector spaces over `ZMod q`.
- Show `ker(D.mulVec)` is a subspace of dimension `p - r`.
- Use `Module.card_eq_pow_finrank` (already used in FreivaldsBridge) to compute the kernel cardinality.
- The rank-1 case (single discrepant row) already gives the `1/q` bound; the general case refines to `q^{-r}`.

**Cross-Domain Connections:**
- Error-correcting codes: the kernel structure mirrors the dual code of the row space.
- Quantum error correction: syndrome measurement is analogous to mulVec evaluation.

**Actionable Next Step:** Prove `card_ker_mulVecLin` for `Matrix.mulVecLin` using the existing `finrank_ker_dotLin` infrastructure, then derive the exact probability as a corollary.

---

## 2. Verified Sum-Check Protocol over `ZMod q`

**Hypothesis:** The sum-check protocol for verifying `∑_{x ∈ {0,1}^n} f(x) = v` can be formalized as an interactive protocol with `n` rounds, each reducing to a univariate polynomial evaluation, with soundness error at most `n·d/q` where `d` is the individual degree.

**Proof Strategy:**
- Define a `SumCheckRound` structure analogous to `StreamingVerifier`.
- Formalize the round reduction: prover sends a univariate polynomial `g_i`, verifier checks `g_i(0) + g_i(1) = claimed_sum`, then replaces the claimed sum with `g_i(r_i)` for a random challenge `r_i`.
- Use the Schwartz-Zippel lemma (already formalized in `RootBound.lean`) for each round's soundness.
- Apply a union bound over `n` rounds.

**Cross-Domain Connections:**
- Interactive proofs: sum-check is the engine of IP = PSPACE.
- SNARKs/STARKs: modern zero-knowledge proofs compile the sum-check protocol into non-interactive form.
- Counting complexity: #P-hardness reductions use sum-check as the verification backbone.

**Actionable Next Step:** Define `SumCheckProtocol` structure with `n` rounds, prove single-round soundness using `card_roots_le_natDegree_filter`, then compose rounds with a union bound.

---

## 3. Generalization to Polynomial Identity Testing (PIT)

**Hypothesis:** The kernel-counting lemma generalizes from linear forms to multivariate polynomials: for a nonzero polynomial `f ∈ F_q[x_1,...,x_p]` of total degree `d`, the set `{r ∈ F_q^p | f(r) = 0}` has cardinality at most `d · q^{p-1}`.

**Proof Strategy:**
- The univariate case is already formalized (`card_roots_le_natDegree_filter`).
- For the multivariate case, use induction on the number of variables:
  - Fix all but one variable; the resulting univariate polynomial has degree ≤ `d`.
  - Apply the univariate bound and sum over assignments to the other variables.
- This is the full Schwartz-Zippel lemma.

**Cross-Domain Connections:**
- Algebraic circuit complexity: PIT is equivalent to circuit lower bounds (Kabanets-Impagliazzo).
- Derandomization: deterministic PIT would imply `BPP = P`.
- Cryptography: polynomial commitments rely on the Schwartz-Zippel bound for binding.

**Actionable Next Step:** Formalize multivariate polynomials over `ZMod q` using `MvPolynomial`, prove the Schwartz-Zippel lemma by induction on the number of variables, then derive Freivalds as a corollary for degree-1 polynomials.

---

## 4. Streaming Fingerprinting for Equality and Frequency Moments

**Hypothesis:** The streaming verifier architecture extends to fingerprinting: given a stream of elements, maintain a compressed fingerprint such that two streams have equal fingerprints iff they represent the same multiset, with error probability ≤ `1/q`.

**Proof Strategy:**
- Define a stream fingerprint as `∑_i a_i · r^i mod q` for a random `r ∈ ZMod q`.
- The equality test reduces to polynomial identity testing: two streams differ iff the difference polynomial is nonzero.
- Apply the univariate root bound to get soundness.
- For frequency moments (`F_k = ∑ f_i^k`), formalize AMS sketches using the same kernel-counting infrastructure.

**Cross-Domain Connections:**
- Database verification: fingerprinting enables sublinear-space database comparison.
- Network monitoring: streaming algorithms detect anomalies in packet flows.
- Communication complexity: fingerprinting gives efficient one-way protocols.

**Actionable Next Step:** Define `StreamFingerprint` structure, prove correctness of the polynomial fingerprinting scheme, then derive the error bound from `card_roots_le_natDegree_filter`.

---

## 5. Finite Affine Geometry and Hyperplane Counting

**Hypothesis:** The acceptance set `{r | dotProduct v r = 0}` for a nonzero `v` is an affine hyperplane in `F_q^p`, and the soundness bound is a statement about the fraction of points on a hyperplane in a finite affine space.

**Proof Strategy:**
- Formalize affine hyperplanes in `F_q^p` as cosets of codimension-1 subspaces.
- Show the zero set of a nonzero linear functional is a hyperplane.
- Prove the hyperplane has exactly `q^{p-1}` points (already done via `card_ker_dotLin`).
- Generalize to affine subspaces of arbitrary codimension.

**Cross-Domain Connections:**
- Finite geometry: incidence bounds (Szemerédi-Trotter over finite fields).
- Coding theory: Reed-Solomon codes are evaluations on affine lines.
- Combinatorics: Kakeya-type problems over finite fields (Dvir's theorem).

**Actionable Next Step:** Define `AffineHyperplane` in terms of `LinearMap.ker` and a translation vector, prove the cardinality theorem, then connect to the existing Dvir formalization in the codebase (`Catalog/EML/PolynomialMethod/Dvir.lean`).

---

## Summary Priority Matrix

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Exact probability | Medium | High | rank-nullity for matrices |
| 2. Sum-check protocol | Hard | Very High | multivariate polynomial eval |
| 3. Schwartz-Zippel | Medium-Hard | Very High | MvPolynomial infrastructure |
| 4. Stream fingerprinting | Medium | High | univariate root bound |
| 5. Finite geometry | Medium | Medium | linear algebra over ZMod |

**Recommended order:** 4 → 1 → 3 → 5 → 2 (increasing difficulty, each building on the previous).
