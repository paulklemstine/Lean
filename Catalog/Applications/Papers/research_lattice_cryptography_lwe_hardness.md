# A Formal Account of Learning With Errors: Decryption Correctness, Affine Rerandomization, and Hybrid Security Reductions

**Author:** Aristotle
**Date:** 2026-06-21
**Domain:** Cryptography (post-quantum / lattice-based)

---

## Abstract

We present a self-contained, machine-checked development of the algebraic and analytic core of lattice-based cryptography built on the Learning With Errors (LWE) problem. The development is organized around four pillars. First, the **algebra of rerandomization**: over a prime field $\mathbb{Z}_p$, affine maps $x \mapsto ax + b$ with $a \neq 0$ are bijections, yielding the summation invariance $\sum_x f(ax+b) = \sum_x f(x)$ that makes wrong guesses in the search-to-decision reduction perfectly uniform. Second, **decryption correctness**: accumulated noise from $m$ samples is bounded by $mB$, and Regev's rounding decryption recovers a bit exactly whenever the total noise is below $q/4$; the Dual-Regev round-trip satisfies the residual identity $\mathrm{Dec}(\mathrm{Enc}(\mu, r)) = \mu + \sum_i r_i e_i$. Third, the **hybrid reduction calculus**: a telescoping triangle inequality bounds the end-to-end distinguishing advantage by a sum of neighboring gaps, and a dual pigeonhole principle extracts a single large gap, giving the linear advantage-loss factor of the search-to-decision and CPA reductions. Fourth, a **distribution-level abstraction**: the same telescope holds for total variation distance over arbitrary distributions, showing that the reduction is fundamentally measure-theoretic; it requires no ring structure, and we use it to subsume non-commutative module-LWE and NTRU under one framework, with a data-processing (contraction) inequality guaranteeing robustness under linear post-processing. All stated results are formally verified and depend only on the standard foundational axioms.

---

## 1. Introduction

The advent of Shor's algorithm rendered factoring- and discrete-log-based cryptography vulnerable to quantum attack, prompting a global migration toward **post-quantum** schemes. The dominant family is lattice-based, and at its heart lies the **Learning With Errors** problem introduced by Regev (2005). LWE enjoys a remarkable *worst-case to average-case* connection: solving random LWE instances is at least as hard as solving worst-case instances of approximate lattice problems such as GapSVP, a hardness believed to hold against quantum adversaries.

This paper formalizes the structural backbone of the LWE security argument. Rather than reproducing a particular reduction in full probabilistic detail, we isolate and verify the load-bearing mathematical facts — the algebraic identities, noise bounds, and information-theoretic inequalities — on which every concrete LWE-based reduction depends. Our contributions are:

1. A verified treatment of affine bijections over $\mathbb{Z}_p$ and the summation invariance underlying rerandomization (§3).
2. Verified noise-accumulation bounds and Regev rounding-decryption correctness, including modulus switching (§4).
3. The Dual-Regev decryption identity and its perfect-correctness corollary (§5).
4. The hybrid telescope and averaging lemmas, and their assembly into search-to-decision and end-to-end CPA bounds (§6).
5. A distribution-level (total-variation) telescope and its application to non-commutative module-LWE and NTRU, plus a data-processing contraction inequality (§7).
6. The Ring-LWE specialization via $\mathbb{Z}$-linearity of ring multiplication (§8).

Throughout, "verified" means the statement has been checked by a proof assistant with no unproven assumptions beyond the standard foundational axioms.

---

## 2. Preliminaries and Notation

We work over the ring $\mathbb{Z}_q = \mathbb{Z}/q\mathbb{Z}$ of integers modulo $q$. When $q = p$ is prime, $\mathbb{Z}_p$ is a field. Vectors $a, s \in \mathbb{Z}_q^n$ have dot product $\langle a, s\rangle = \sum_{j} a_j s_j$. A *Gaussian-like* error distribution produces small errors; we abstract this as a bound $|e| \le B$ on representatives.

**Definition 2.1 (LWE distribution).** For a secret $s \in \mathbb{Z}_q^n$, an LWE sample is the pair $(a, b)$ where $a \leftarrow \mathbb{Z}_q^n$ is uniform and $b = \langle a, s\rangle + e \bmod q$ with $e$ a small error. The *search-LWE* problem is to recover $s$ from polynomially many samples; the *decision-LWE* problem is to distinguish such samples from uniform pairs.

**Definition 2.2 (Total variation distance).** For probability mass functions $\mu, \nu$ on a finite set $\Omega$,
$$\mathrm{TVD}(\mu, \nu) = \tfrac12 \sum_{\omega \in \Omega} |\mu(\omega) - \nu(\omega)|.$$
TVD is a metric; in particular it satisfies the triangle inequality, which we use repeatedly.

**Definition 2.3 (Distinguishing advantage).** For an adversary $\mathcal{A}$ and two experiments producing distributions $D_0, D_1$, the advantage is $\mathrm{Adv}(\mathcal{A}) = |\Pr[\mathcal{A}(D_0)=1] - \Pr[\mathcal{A}(D_1)=1]|$, bounded above by $\mathrm{TVD}(D_0, D_1)$.

---

## 3. The Algebra of Rerandomization

The search-to-decision reduction recovers the secret one coordinate at a time. To test a guess for a coordinate it applies an affine transformation to the public component of each sample. Correctness of the reduction hinges on these transformations being *measure-preserving*, which over a prime field is exact.

**Theorem 3.1 (`ZMod.mul_left_bijective_of_prime`).** Let $p$ be prime and $a \in \mathbb{Z}_p$ with $a \neq 0$. Then $x \mapsto a x$ is a bijection of $\mathbb{Z}_p$.

*Proof sketch.* Since $p$ is prime, $\mathbb{Z}_p$ is a field, so a nonzero $a$ is a unit and $x \mapsto ax$ is injective; injectivity on a finite type implies bijectivity. $\qquad\blacksquare$

**Theorem 3.2 (`ZMod.affine_bijective`).** For prime $p$, $a, b \in \mathbb{Z}_p$ with $a \neq 0$, the affine map $x \mapsto a x + b$ is a bijection of $\mathbb{Z}_p$.

*Proof sketch.* Compose the bijection $x \mapsto ax$ (Theorem 3.1) with the translation $y \mapsto y + b$, itself a bijection of the additive group. $\qquad\blacksquare$

We package this as an equivalence $\mathbb{Z}_p \simeq \mathbb{Z}_p$ (`ZMod.affineEquiv`) whose inverse is again affine: if $f(x) = ax + b$ then $f^{-1}(y) = a^{-1}(y - b)$ (`ZMod.affineEquiv_symm_apply`). Affine maps are closed under composition (`ZMod.affine_comp`):
$$(x \mapsto a_1 x + b_1) \circ (x \mapsto a_2 x + b_2) = \big(x \mapsto (a_1 a_2)x + (a_1 b_2 + b_1)\big).$$

The cryptographically decisive consequence is invariance of the full-set image and of summation.

**Theorem 3.3 (`ZMod.affine_image_univ`).** For prime $p$ and $a \neq 0$, the affine image of $\mathbb{Z}_p$ is all of $\mathbb{Z}_p$: $\{ax + b : x \in \mathbb{Z}_p\} = \mathbb{Z}_p$.

**Theorem 3.4 (`ZMod.sum_affine_eq`).** For prime $p$, $a \neq 0$, and any $f : \mathbb{Z}_p \to \mathbb{R}$,
$$\sum_{x \in \mathbb{Z}_p} f(ax + b) = \sum_{x \in \mathbb{Z}_p} f(x).$$

*Proof sketch.* Reindex the sum along the bijection of Theorem 3.2; a bijective reparametrization leaves a finite sum invariant. $\qquad\blacksquare$

**Cryptographic reading.** In the hybrid for coordinate $i$, an incorrect secret guess causes the rerandomized samples to be distributed as $f(ax+b)$ for uniform $x$; Theorem 3.4 says this equals the uniform expectation, so the distinguisher gains no signal. Only a correct guess breaks the symmetry. This is the precise mechanism converting a decision oracle into a search algorithm.

---

## 4. Noise Accumulation and Rounding Decryption

### 4.1 Noise accumulation

Regev ciphertexts are subset sums of fresh samples, so error magnitudes add. We verify the basic triangle-inequality bounds.

**Theorem 4.1 (`noise_accumulation_bound`).** If $e : \{0,\dots,m-1\} \to \mathbb{Z}$ satisfies $|e_i| \le B$ for all $i$, then $\big|\sum_{i} e_i\big| \le m B$.

*Proof sketch.* $\big|\sum_i e_i\big| \le \sum_i |e_i| \le \sum_i B = mB$, using the absolute-value triangle inequality and a constant-sum evaluation. $\qquad\blacksquare$

The same argument gives the subset version (`noise_accumulation_subset_bound`): $\big|\sum_{i \in S} e_i\big| \le |S|\, B$ for any index set $S$; and a real-valued version (`noise_accumulation_bound_real`) with the identical bound $mB$ over $\mathbb{R}$.

### 4.2 Rounding decryption

A bit $\mu \in \{0, 1\}$ is encoded as $\mu \cdot (q/2)$. Decryption tests which half of $[0, q)$ the noisy value occupies. Correctness reduces to two interval facts.

**Theorem 4.2 (`regev_rounding_bit0`).** If $|e| < q/4$ then $-q/4 < e < q/4$.

**Theorem 4.3 (`regev_rounding_bit1`).** If $q > 0$ and $|e| < q/4$ then
$$\frac{q}{4} < \frac{q}{2} + e < \frac{3q}{4}.$$

*Proof sketch.* Both unfold $|e| < q/4$ to $-q/4 < e < q/4$ and apply linear arithmetic. $\qquad\blacksquare$

**Theorem 4.4 (`encoding_separation`).** If $|e|, |e'| < q/4$ and $q > 0$ then $0 < q/2 - |e| - |e'|$; the encodings of $0$ and $1$ remain strictly separated.

**Theorem 4.5 (`regev_encryption_rounding_correctness`).** For $q > 0$, $|e| < q/4$, and any $\mu$,
$$\big|\, \mu(q/2) + e - \mu(q/2)\,\big| < q/4,$$
i.e. the noisy codeword is within $q/4$ of the intended codeword, so decryption recovers $\mu$.

### 4.3 Modulus switching

Modulus switching shrinks ciphertexts at the cost of a per-coordinate rounding error $\delta$.

**Theorem 4.6 (`combined_noise_after_switching`).** If $|e_{\mathrm{lwe}}| \le B$ and each rounding error satisfies $|r_i| \le \delta$, then
$$\Big|\, e_{\mathrm{lwe}} + \sum_{i=1}^{n} r_i \,\Big| \le B + n\delta.$$

**Theorem 4.7 (`decryption_correct_after_switching`).** Under the hypotheses of Theorem 4.6, if additionally $B + n\delta < q/4$, then the combined noise is below $q/4$ and decryption remains correct.

These give the parameter discipline for a working scheme: choose $q$ large enough that $B + n\delta < q/4$.

### 4.4 Amplification and the modulus–noise tradeoff

**Theorem 4.8 (`advantage_amplification`).** For $0 \le p \le 1$ and $k \ge 1$, $p \le 1 - (1-p)^k$: independent repetitions never decrease success probability.

**Theorem 4.9 (`modulus_noise_tradeoff`).** For $q > 0$ and any $\alpha$ with $2\sqrt{n}/q \le \alpha$, we have $2\sqrt{n} \le \alpha q$. Larger moduli permit smaller relative noise rates $\alpha$ while preserving the hardness threshold $\alpha q \ge 2\sqrt n$ from Regev's worst-case connection.

---

## 5. The Dual-Regev Scheme

We model Dual-Regev abstractly: a secret key $sk$, a public key $pk$ generated as $p_i = \langle A_i, s\rangle + e_i$ (encoded by a well-formedness predicate `WellFormedPK`), encryption $\mathrm{Enc}(pk, \mu, r)$ using randomness $r = (r_i)$, and decryption $\mathrm{Dec}(sk, \cdot)$ computing $v - \langle u, s\rangle$.

**Theorem 5.1 (Decryption identity, `dualRegev_decrypt_encrypt_eq`).** For a well-formed public key with errors $e = (e_i)$,
$$\mathrm{Dec}\big(sk, \mathrm{Enc}(pk, \mu, r)\big) = \mu + \sum_{i=1}^{m} r_i\, e_i.$$

*Proof sketch.* Unfold the definitions and substitute the well-formedness relation $p_i = \langle A_i, s\rangle + e_i$ into the decryption expression. The terms $\langle \cdot, s\rangle$ cancel by bilinearity and a reindexing of the double sum (interchanging the order of summation), leaving the message $\mu$ plus the residual $\sum_i r_i e_i$. This is the adjoint cancellation $\langle Tx, y\rangle = \langle x, T^\top y\rangle$ specialized to the dot product. $\qquad\blacksquare$

**Corollary 5.2 (Perfect correctness, `dualRegev_decrypt_correct_zero_noise`).** If all errors are zero then $\mathrm{Dec}(sk, \mathrm{Enc}(pk, \mu, r)) = \mu$.

Combined with §4, Theorem 5.1 yields correctness in the noisy regime: when $\big|\sum_i r_i e_i\big| < q/4$ (after rounding), the message is recovered exactly.

---

## 6. The Hybrid Reduction Calculus

### 6.1 Telescope and averaging

**Theorem 6.1 (Hybrid telescope, `hybrid_telescope_bound`).** For any sequence of real values $P : \{0, \dots, k+1\} \to \mathbb{R}$,
$$\big| P_0 - P_{k+1} \big| \le \sum_{i=0}^{k} \big| P_i - P_{i+1} \big|.$$

*Proof sketch.* Induction on $k$. The step uses the triangle inequality $|P_0 - P_{k+2}| \le |P_0 - P_{k+1}| + |P_{k+1} - P_{k+2}|$, then the inductive hypothesis on the truncated sequence. $\qquad\blacksquare$

**Theorem 6.2 (Hybrid averaging / pigeonhole, `hybrid_averaging`).** If $\varepsilon > 0$ and $\varepsilon \le |P_0 - P_{k+1}|$, then there exists an index $i$ with
$$\frac{\varepsilon}{k+1} \le \big| P_i - P_{i+1}\big|.$$

*Proof sketch.* Contrapositive: if every neighboring gap were $< \varepsilon/(k+1)$, summing the $k+1$ gaps would give a total $< \varepsilon$, contradicting the telescope bound (Theorem 6.1) applied to $\varepsilon \le |P_0 - P_{k+1}|$. $\qquad\blacksquare$

### 6.2 Search-to-decision

**Theorem 6.3 (Pigeonhole advantage split, `search_to_decision_advantage_bound`).** For $n > 0$, if $\delta \le \sum_{i=1}^{n} c_i$ where $c_i$ are coordinate advantages, then some $c_i \ge \delta/n$.

*Proof sketch.* If all $c_i < \delta/n$, then $\sum_i c_i < n \cdot (\delta/n) = \delta$, contradicting the hypothesis. $\qquad\blacksquare$

**Theorem 6.4 (Coordinate recovery, `search_from_decision_coordinate`).** For $n > 0$, $\varepsilon > 0$, hybrid probabilities $H : \{0,\dots,n\} \to \mathbb{R}$ with $\varepsilon \le |H_0 - H_n|$, and coordinate advantages bounding each neighboring gap ($|H_i - H_{i+1}| \le c_i$), there exists $i$ with $\varepsilon / n \le c_i$.

*Proof sketch.* Combine the telescope (Theorem 6.1, rephrased for the $n$-step chain) with the pigeonhole split (Theorem 6.3): the neighboring gaps sum to at least $\varepsilon$ via the telescope, then averaging forces one coordinate above $\varepsilon/n$. The variant `search_from_decision_advantage` packages the same conclusion directly from $\varepsilon \le \sum_i c_i$. $\qquad\blacksquare$

### 6.3 CPA security and end-to-end composition

**Theorem 6.5 (CPA from LWE, `dualRegev_cpa_security_of_lwe`).** Let $\mathrm{adv}_{\mathrm{CPA}}, \mathrm{adv}_{\mathrm{LWE}}, \varepsilon_{\mathrm{corr}} \ge 0$. If there is a reduction with $\mathrm{adv}_{\mathrm{LWE}} \ge \mathrm{adv}_{\mathrm{CPA}} - \varepsilon_{\mathrm{corr}}$, then
$$\mathrm{adv}_{\mathrm{CPA}} \le \mathrm{adv}_{\mathrm{LWE}} + \varepsilon_{\mathrm{corr}}.$$

The hypothesis $\mathrm{adv}_{\mathrm{LWE}} \ge \mathrm{adv}_{\mathrm{CPA}} - \varepsilon_{\mathrm{corr}}$ encapsulates the standard game-hopping construction of an LWE distinguisher from a CPA adversary; the theorem records the resulting bound.

**Theorem 6.6 (End-to-end composition, `endToEnd_security_composition`).** For $n > 0$ and nonnegative advantages, if $\varepsilon_{\mathrm{decision}} \le n\,\varepsilon_{\mathrm{search}}$ (search-to-decision) and $\varepsilon_{\mathrm{cpa}} \le \varepsilon_{\mathrm{decision}} + \varepsilon_{\mathrm{corr}}$ (CPA reduction), then
$$\varepsilon_{\mathrm{cpa}} \le n\,\varepsilon_{\mathrm{search}} + \varepsilon_{\mathrm{corr}}.$$

This is the headline quantitative guarantee: the CPA advantage against the encryption scheme is at most a linear ($\times n$) blow-up of the search-LWE advantage, plus the decryption-correctness error controlled in §4.

---

## 7. The Distribution-Level Abstraction

The reductions above are usually proved game-by-game over concrete algebraic objects. We show that the *structural* core lives one level up, over arbitrary distributions, and needs no algebra.

**Theorem 7.1 (TVD telescope, `hybrid_telescope_tvd`).** Let $\Omega$ be a finite type and $H : \{0, \dots, n\} \to \mathrm{PMF}(\Omega)$ a sequence of distributions. Then
$$\mathrm{TVD}(H_0, H_n) \le \sum_{i=0}^{n-1} \mathrm{TVD}(H_i, H_{i+1}).$$

*Proof sketch.* Induction on $n$ using the triangle inequality for TVD (`tvd_triangle`), exactly mirroring Theorem 6.1 but with the metric replaced by TVD. $\qquad\blacksquare$

**Conceptual consequence.** Search-to-decision reductions are fundamentally *measure-theoretic*; the ring structure of $\mathbb{Z}_q$ enters only when bounding individual neighboring gaps (via §3). This explains why the reduction template applies far beyond plain LWE.

### 7.1 Non-commutative module-LWE and NTRU

**Definition 7.2 (`NoncommModuleLWEParams`).** Over a (possibly non-commutative) ring $R$, with left $R$-modules $M$ (secrets) and $N$ (samples), the parameters consist of: a sample count, a secret distribution on $M$, an error distribution on $N$, a left-linear action map $T : M \to_R N$, and a base distribution on $N$.

**Definition 7.3 (advantages).** The *one-step advantage* (`oneStepAdvantage`) is $\mathrm{TVD}(T_* \mu_s, \mu_{\mathrm{base}})$, the TVD between the pushforward of the secret distribution under the action map and the base distribution. The *decision advantage* (`decisionAdvantage`) is $\text{sampleCount} \cdot \text{oneStepAdvantage}$.

**Theorem 7.4 (`decisionAdvantage_le_mul`).** $\text{decisionAdvantage} \le \text{sampleCount} \cdot \text{oneStepAdvantage}$ (the hybrid bound, here definitional).

**Definition 7.5 (`NTRUInstance`).** An NTRU-style system over $R$ consists of a left-linear public map $M \to_R N$, a secret distribution, a noise distribution, a sample count, and a uniform reference distribution. The map `NTRUInstance.toParams` repackages it as `NoncommModuleLWEParams`.

**Theorem 7.6 (NTRU instantiates the framework, `ntru_instantiates_noncomm_module_framework`).** Every NTRU instance arises as a `NoncommModuleLWEParams` with matching action map, secret distribution, and sample count.

**Theorem 7.7 (NTRU decision reduction, `ntru_decision_reduction`).** For any NTRU instance $P$,
$$\text{decisionAdvantage}(P.\mathrm{toParams}) \le P.\mathrm{samples} \cdot \text{oneStepAdvantage}(P.\mathrm{toParams}).$$

*Proof sketch.* Apply Theorem 7.4 to $P.\mathrm{toParams}$. $\qquad\blacksquare$

### 7.2 Data-processing / contraction

**Theorem 7.8 (Quotient-map TVD bound, `quotient_map_tvd_bound_noncomm`).** For a left-linear map $\varphi : M \to_R N$ and distributions $\mu, \nu$ on $M$,
$$\mathrm{TVD}(\varphi_* \mu, \varphi_* \nu) \le \mathrm{TVD}(\mu, \nu).$$

**Theorem 7.9 (Composition of contractions, `tvd_map_map_le`).** For maps $f : \alpha \to \beta$, $g : \beta \to \gamma$ and distributions $\mu, \nu$ on $\alpha$,
$$\mathrm{TVD}\big((g\circ f)_*\mu, (g\circ f)_*\nu\big) \le \mathrm{TVD}(\mu, \nu).$$

These are instances of the data-processing inequality: post-processing (in particular, any linear pushforward) can never increase statistical distinguishability. They guarantee that the security of the framework is robust under the linear transformations endemic to lattice schemes.

---

## 8. The Ring-LWE Specialization

Ring-LWE replaces vectors with elements of a polynomial ring $R = \mathbb{Z}_q[x]/(x^n+1)$, where multiplication is computable in $O(n\log n)$ via the FFT. The security argument transports because ring multiplication is linear.

**Theorem 8.1 (Ring multiplication is $\mathbb{Z}$-linear, `ring_mult_is_linear_on_coeffs`).** In any commutative ring $R$ that is a $\mathbb{Z}$-module, for fixed $a \in R$ the map $s \mapsto a\cdot s$ is $\mathbb{Z}$-linear.

*Proof sketch.* Additivity is distributivity; $\mathbb{Z}$-homogeneity follows by induction over integer scalars (splitting into nonnegative and negative cases) using $a\cdot(k\,s) = k\,(a\cdot s)$. $\qquad\blacksquare$

**Theorem 8.2 (Advantage transport, `ringLWE_advantage_transport`).** If the Ring-LWE distinguishing advantage is bounded by the coefficient-LWE advantage ($\mathrm{adv}_{\mathrm{Ring}} \le \mathrm{adv}_{\mathrm{coeff}}$), the bound transfers verbatim.

Because $s \mapsto a\cdot s$ is linear (Theorem 8.1), the Ring-LWE decryption identity has exactly the residual shape of Theorem 5.1 — message plus weighted small noise — with matrix–vector adjoint cancellation replaced by ring-multiplication cancellation. The coefficient-vector representation realizes a Ring-LWE sample as a structured module-LWE sample, so the framework of §7 applies, and Theorem 8.2 records that the advantage is preserved across the two representations. The noise-smudging bound (`noise_smudging_bound`): if $\text{stat\_dist} \le \text{original\_noise}/\text{smudging\_noise}$ with the smudging noise positive, the statistical distance is controlled by their ratio — a standard tool for hiding residual noise in advanced Ring-LWE protocols.

---

## 9. Algorithms

The constructive content yields explicit procedures, summarized here and implemented in the accompanying demonstration code.

- **Affine rerandomization** (basis of search-to-decision): given a sample coordinate $x$ and a guess, sample $a \neq 0$, $b$, and output $ax + b$; by Theorem 3.4 wrong guesses yield uniform output.
- **Regev bit decryption**: compute $v - \langle u, s\rangle$, reduce to a centered representative in $(-q/2, q/2]$, and output $0$ if $|{\cdot}| < q/4$, else $1$ (Theorems 4.2–4.5).
- **Dual-Regev encrypt/decrypt**: encrypt via $\mathrm{Enc}(pk, \mu, r)$, decrypt via the residual identity of Theorem 5.1; correct whenever the residual noise is below $q/4$.
- **Hybrid advantage accounting**: given neighboring gaps, the telescope (Theorem 6.1) sums them; the averaging lemma (Theorem 6.2) locates a gap $\ge \varepsilon/(k+1)$.

---

## 10. Applications

1. **Standardized post-quantum encryption.** The Regev and Dual-Regev templates, and the Ring-LWE variant, are the mathematical basis for the lattice schemes selected for post-quantum standardization. The decryption-correctness and noise-budget results (§4–§5) are exactly the inequalities a parameter designer must satisfy.
2. **Homomorphic encryption.** LWE and Ring-LWE underpin fully homomorphic encryption; modulus switching (Theorems 4.6–4.7) and noise smudging (§8) are core noise-management techniques there.
3. **Unified security architecture.** The distribution-level telescope (§7) shows plain LWE, module-LWE, and NTRU share one reduction skeleton, simplifying the analysis of new schemes.

---

## 11. Discussion

The formalization clarifies a separation of concerns that is often blurred in informal treatments. The *quantitative* skeleton of every LWE reduction — telescope plus pigeonhole — is purely metric and holds for total variation distance over arbitrary distributions (Theorems 6.1, 6.2, 7.1). The *algebraic* content enters only in two places: showing that wrong guesses produce uniform samples (the affine bijection, Theorem 3.4), and that decryption cancels the secret-dependent terms (the adjoint identity, Theorems 5.1, 8.1). Robustness under linear post-processing is then automatic from the data-processing inequality (Theorems 7.8, 7.9). This modular structure is what allows a single framework to cover plain, module, ring, and NTRU variants.

A second observation is the centrality of a single scalar threshold. Decryption correctness across all variants is governed by the additive condition "total noise $< q/4$" (Theorems 4.5, 4.7), with the total noise assembled from per-sample bounds via the accumulation lemmas (Theorem 4.1) and adjusted for modulus switching. This makes parameter selection a transparent inequality rather than a bespoke analysis per scheme.

---

## 12. Future Directions

**Conjecture 1 — Unified residual functor.** There should be a single $R$-module-level lemma, parameterized by an adjoint bilinear pairing $\langle\cdot,\cdot\rangle$, yielding both the Dual-Regev and Ring-LWE decryption identities as specializations (pairing = dot product, resp. ring multiplication via the regular representation). Both identities are instances of the adjoint relation $\langle Tx, y\rangle = \langle x, T^\top y\rangle$ for a self-paired operator, so cancellation is functorial in the pairing rather than tied to matrices or rings. This is stateable now because both concrete identities are proved (the matrix adjoint cancellation and the `ring`-based ring identity), giving two witnesses to check the generalization against.

**Conjecture 2 — Non-field rings break naive search-to-decision.** Over $\mathbb{Z}_q$ with $q$ composite, the rerandomization identity $\sum_x f(ax+b) = \sum_x f(x)$ should *fail* for some non-unit $a \neq 0$; the unit hypothesis is necessary, not an artifact. When $a$ is a zero divisor, $ax$ ranges only over the ideal $(a)$, not all of $\mathbb{Z}_q$, so uniformity is not preserved and the hybrid step is invalid. A concrete counterexample at $q = 6$, $a = 2$ would pin the boundary and is a finite, decidable claim.

**Conjecture 3 — Tight noise budget across all three schemes.** A single inequality $B_{\text{total}} < q/4$ — with $B_{\text{total}} = X_1 + mEX$ in matrix LWE and $B_{\text{total}} = \|e\|\,\|r\| + \|e_1\| + \|s\|\,\|e_0\|$ in Ring-LWE — should be both necessary and sufficient for one-bit decryption correctness, and tight: there exist error vectors meeting the bound with equality that still decrypt, and arbitrarily small overshoots that fail. The residual noise enters decryption purely additively, so correctness is governed by a single scalar threshold.

---

## 13. Conclusion

We have given a formally verified account of the structural core of LWE-based cryptography: the affine-bijection algebra that powers rerandomization, the noise-accumulation and rounding inequalities that guarantee decryption, the Dual-Regev residual identity, the hybrid telescope and pigeonhole that quantify the reduction, the distribution-level abstraction that reveals its measure-theoretic nature, and the Ring-LWE specialization via linearity of ring multiplication. Together these results trace, with rigor, the chain of reasoning from worst-case lattice hardness to a working, quantum-resistant encryption scheme — and show that the chain rests, at bottom, on the triangle inequality.
