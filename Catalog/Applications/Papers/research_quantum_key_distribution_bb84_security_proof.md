# Information-Theoretic Security of BB84: The ~11% QBER Threshold, Privacy Amplification, and Optimal Two-Universal Hashing

**Author:** Aristotle
**Date:** 2026-06-23
**Domain:** Cryptography

## Abstract

We present a self-contained, formally verified development of the information-theoretic core of the BB84 quantum key distribution protocol. Three pillars are established. First, modeling the canonical intercept–resend attack, we prove that full interception induces a quantum bit error rate (QBER) of exactly $1/4$, independent of the encoding basis. Second, defining the one-way Shor–Preskill secret-key rate $r(Q) = 1 - 2H_2(Q)$, we prove it is strictly decreasing on $[0, 1/2]$, vanishes at a *unique* critical QBER $p^\star$, and bracket $p^\star \in (1/16, 1/8)$ — straddling the textbook $\approx 11\%$ — via two *integer* inequalities ($7^7 < 2^{20}$ and $2^{56} < 15^{15}$) that certify the transcendental endpoints without floating-point arithmetic. Because $1/4 > p^\star$, the strongest naive attack is always detectable. Third, for privacy amplification we prove a Cauchy–Schwarz "leftover-hash" bound converting a collision-probability (min-entropy) guarantee into a statistical-distance-to-uniform bound that is *exponentially small* in the entropy gap, and we prove that the GF(2) inner-product (random-parity) hash family is *optimally two-universal*: for any two distinct inputs exactly half of all seeds collide, with the $k$-bit generalization giving collision probability exactly $2^{-k}$. A complementary pigeonhole result shows no deterministic compression can be injective, explaining why privacy amplification must be randomized. All results are machine-checked.

## 1. Introduction

Classical key-exchange protocols derive security from computational assumptions — the presumed intractability of factoring, discrete logarithms, or lattice problems. Quantum key distribution (QKD), introduced by Bennett and Brassard in 1984 (the **BB84** protocol), replaces computational assumptions with the laws of quantum mechanics: the no-cloning theorem and the disturbance induced by measuring in a conjugate basis. An eavesdropper cannot extract information about the transmitted bits without introducing detectable errors.

The security analysis of BB84 reduces, after the quantum layer is accounted for, to three quantitative facts about *classical* information theory and combinatorics:

1. **Attack cost.** A concrete eavesdropping strategy must induce a quantifiable error rate.
2. **A sharp threshold.** There is a critical QBER below which secret key can be distilled and above which it cannot, and this threshold is a single well-defined number (~11% for one-way post-processing).
3. **Privacy amplification.** Given a raw key with bounded eavesdropper information, a randomly chosen universal hash function produces a final key whose leakage is exponentially small.

This paper formalizes all three. We work with `Real.binEntropy`, the natural-logarithm (nats) binary entropy, so the textbook bit-valued rate $1 - 2H_2(Q)$ becomes $\log 2 - 2\,\text{binEntropy}(Q)$; the two differ only by the factor $\log 2 > 0$ and hence share the same sign and the same zero.

## 2. Preliminaries and Definitions

### 2.1 Binary entropy and the secret-key rate

For $Q \in [0,1]$ the binary entropy in bits is $H_2(Q) = -Q\log_2 Q - (1-Q)\log_2(1-Q)$. We use its natural-log counterpart $\text{binEntropy}(Q)$, which satisfies $\text{binEntropy}(1/2) = \log 2$ and is strictly increasing on $[0, 1/2]$ and continuous on $[0,1]$.

**Definition 2.1 (Secret-key rate, `secureKeyRate`).** The asymptotic one-way BB84 secret-key fraction, in nats, is
$$\texttt{secureKeyRate}(Q) := \log 2 - 2\,\text{binEntropy}(Q).$$
Dividing by $\log 2$ recovers the Shor–Preskill rate $1 - 2H_2(Q)$ in bits. Positivity is the condition for distillable secret key.

### 2.2 The protocol model

We model only what matters for the error rate. Bases are Boolean (`false` = rectilinear, `true` = diagonal). After *sifting*, Alice and Bob retain rounds with a common basis.

**Definition 2.2 (Conditional Bob error, `bobErrorProb`).** Given Alice/Bob common basis $a$ and Eve's measurement basis $e$,
$$\texttt{bobErrorProb}(a, e) := \begin{cases} 0 & e = a,\\ 1/2 & e \neq a. \end{cases}$$
If Eve guesses the basis she resends faithfully; otherwise the resent qubit is in the conjugate basis and Bob's outcome is uniformly random.

**Definition 2.3 (Intercept–resend QBER, `interceptResendQBER`).** Averaging over Eve's uniformly random basis,
$$\texttt{interceptResendQBER}(a) := \sum_{e \in \{\text{false}, \text{true}\}} \tfrac{1}{2}\,\texttt{bobErrorProb}(a, e).$$

### 2.3 Hash families

**Definition 2.4 (Bit vectors, `BitVec2`).** $\texttt{BitVec2}(n) := \mathrm{Fin}\,n \to \mathbb{Z}/2\mathbb{Z}$, i.e. length-$n$ vectors over GF(2).

**Definition 2.5 (Inner-product hash, `innerHash`).** For seed $a$ and input $x$,
$$\texttt{innerHash}(a, x) := \sum_{i=1}^{n} a_i\, x_i \in \mathbb{Z}/2\mathbb{Z}.$$
This is a random-parity hash: the seed selects a subset of coordinates and the output is their parity.

**Definition 2.6 (Standard basis vector, `e`).** $e_j$ is the vector with a $1$ at index $j$ and $0$ elsewhere.

## 3. The Intercept–Resend Attack: QBER = 1/4

**Theorem 3.1 (`interceptResendQBER_eq`).** For every basis $a$, $\texttt{interceptResendQBER}(a) = 1/4$.

*Proof sketch.* Expand the two-term Boolean sum. When $e = a$ the error term is $0$; when $e \neq a$ it is $1/2$. Each occurs with weight $1/2$, so the total is $\tfrac12\cdot 0 + \tfrac12\cdot\tfrac12 = \tfrac14$. Case analysis on $a \in \{\text{false}, \text{true}\}$ shows the value is basis-independent. $\square$

This is a genuine finite expectation (over `Bool`), not a definitional constant. Its significance, realized in Section 4, is that $1/4$ exceeds the security threshold, so full interception is always detectable.

## 4. The Secret-Key Rate and the ~11% Threshold

### 4.1 The secure condition and monotonicity

**Theorem 4.1 (`secureKeyRate_pos_iff`).** For all $Q$,
$$0 < \texttt{secureKeyRate}(Q) \iff \text{binEntropy}(Q) < \tfrac{\log 2}{2}.$$

*Proof sketch.* Immediate from Definition 2.1 by linear rearrangement: $\log 2 - 2\,\text{binEntropy}(Q) > 0 \iff \text{binEntropy}(Q) < (\log 2)/2$. $\square$

**Theorem 4.2 (`secureKeyRate_strictAntiOn`).** $\texttt{secureKeyRate}$ is strictly decreasing (strictly antitone) on $[0, 1/2]$.

*Proof sketch.* $\texttt{secureKeyRate}(Q) = \log 2 - 2\,\text{binEntropy}(Q)$ is an affine, orientation-reversing function of $\text{binEntropy}$, which is strictly increasing on $[0, 1/2]$. Composing a strictly increasing function with multiplication by $-2$ yields a strictly decreasing function. $\square$

Strict monotonicity is the engine of uniqueness: the rate crosses zero at most once.

### 4.2 Integer-certified brackets

The transcendental endpoints are certified by elementary integer arithmetic after clearing logarithms.

**Lemma 4.3 (`binEntropy_one_eighth_gt`).** $\tfrac{\log 2}{2} < \text{binEntropy}(1/8)$.

*Proof sketch.* Writing out $\text{binEntropy}(1/8) = \tfrac18\log 8 + \tfrac78\log\tfrac87$ and comparing with $(\log 2)/2$, clearing denominators and exponentiating reduces the inequality to $7^7 < 2^{20}$, i.e. $823{,}543 < 1{,}048{,}576$, which holds. $\square$

**Lemma 4.4 (`binEntropy_one_sixteenth_lt`).** $\text{binEntropy}(1/16) < \tfrac{\log 2}{2}$.

*Proof sketch.* Expanding $\text{binEntropy}(1/16) = \tfrac{1}{16}\log 16 + \tfrac{15}{16}\log\tfrac{16}{15}$ and clearing logarithms reduces the inequality to $2^{56} < 15^{15}$, which holds. $\square$

**Lemma 4.5 (`binEntropy_one_quarter_gt`).** $\tfrac{\log 2}{2} < \text{binEntropy}(1/4)$.

*Proof sketch.* Expanding $\text{binEntropy}(1/4)$ and simplifying reduces the comparison to an elementary positivity fact ($3 < 4$ after logarithm manipulation), using $\log 4 = 2\log 2$. $\square$

### 4.3 Existence, uniqueness, and the intercept–resend corollary

**Theorem 4.6 (Threshold existence, `exists_threshold`).** There exists $p^\star \in (1/16,\, 1/8) = (6.25\%,\, 12.5\%)$ with $\texttt{secureKeyRate}(p^\star) = 0$.

*Proof sketch.* By Lemmas 4.3–4.4, $\text{binEntropy}(1/16) < (\log 2)/2 < \text{binEntropy}(1/8)$. Since $\text{binEntropy}$ is continuous, the Intermediate Value Theorem on $(1/16, 1/8)$ yields a point $p^\star$ with $\text{binEntropy}(p^\star) = (\log 2)/2$, equivalently $\texttt{secureKeyRate}(p^\star) = 0$. $\square$

The true root of $H_2(p) = 1/2$ is $p^\star \approx 0.1100$, the canonical $\approx 11\%$ BB84 threshold.

**Theorem 4.7 (Threshold uniqueness, `threshold_unique`).** If $p, q \in [0, 1/2]$ both satisfy $\texttt{secureKeyRate} = 0$, then $p = q$.

*Proof sketch.* A strictly antitone function (Theorem 4.2) is injective; two preimages of $0$ coincide. $\square$

**Theorem 4.8 (`secureKeyRate_one_quarter_neg`).** $\texttt{secureKeyRate}(1/4) < 0$.

*Proof sketch.* By Lemma 4.5, $\text{binEntropy}(1/4) > (\log 2)/2$, so $2\,\text{binEntropy}(1/4) > \log 2$ and $\texttt{secureKeyRate}(1/4) = \log 2 - 2\,\text{binEntropy}(1/4) < 0$. $\square$

**Corollary 4.9 (`interceptResend_insecure`).** For every basis $a$, $\texttt{secureKeyRate}(\texttt{interceptResendQBER}(a)) < 0$.

*Proof sketch.* Substitute Theorem 3.1 ($\texttt{interceptResendQBER}(a) = 1/4$) into Theorem 4.8. $\square$

**Corollary 4.10 (`threshold_lt_interceptResend`).** For any $p \in (1/16, 1/8)$ and any basis $a$, $p < \texttt{interceptResendQBER}(a) = 1/4$.

*Proof sketch.* $p < 1/8 < 1/4$. $\square$

Together, Corollaries 4.9–4.10 say the intercept–resend QBER lies strictly above the (unique) threshold, so the strongest naive attack always drives the key rate negative and is detectable.

## 5. Privacy Amplification

### 5.1 The leftover-hash core

**Theorem 5.1 (`statDist_le_collision`).** Let $M > 0$ and let $p : \mathrm{Fin}\,M \to \mathbb{R}$ satisfy $\sum_i p_i = 1$. Then
$$\sum_{i=1}^{M} \left|p_i - \tfrac1M\right| \;\le\; \sqrt{\,M\sum_{i=1}^{M} p_i^2 - 1\,}.$$

*Proof sketch.* Let $d_i = p_i - 1/M$. Then $\sum_i d_i = 0$ and $\sum_i d_i^2 = \sum_i p_i^2 - 1/M$ (the cross term vanishes because $\sum_i p_i = 1$). Cauchy–Schwarz against the all-ones vector gives $\left(\sum_i |d_i|\right)^2 \le M \sum_i d_i^2 = M\sum_i p_i^2 - 1$. Taking square roots (the right side is nonnegative) yields the claim. Nonnegativity of $p$ is never used: this is a pure Cauchy–Schwarz fact about any vector summing to $1$. $\square$

The left side is twice the total-variation distance to uniform; the quantity $\sum_i p_i^2$ is the **collision probability**, whose smallness is equivalent to large min-entropy.

### 5.2 Exponential decay

**Theorem 5.2 (`privacyAmplification_exp_bound`).** Let the output have $\ell$ bits ($M = 2^\ell$) and let $p : \mathrm{Fin}(2^\ell) \to \mathbb{R}$ with $\sum_i p_i = 1$ and collision probability $\sum_i p_i^2 \le 2^{-k}$. Then
$$\sum_{i} \left| p_i - 2^{-\ell} \right| \;\le\; \sqrt{2^{\,\ell - k}}.$$

*Proof sketch.* Apply Theorem 5.1 with $M = 2^\ell$: the bound is $\sqrt{2^\ell \sum_i p_i^2 - 1}$. Using $\sum_i p_i^2 \le 2^{-k}$ and dropping the $-1$ (monotonicity of $\sqrt{\cdot}$) gives $\sqrt{2^\ell \cdot 2^{-k}} = \sqrt{2^{\ell-k}}$. $\square$

When the entropy gap $k - \ell > 0$, the bound is $2^{-(k-\ell)/2}$, exponentially small. This is the secure regime: extract fewer bits than Eve's residual uncertainty and her distinguishing advantage collapses exponentially.

### 5.3 Randomization is necessary

**Theorem 5.3 (`injective_extractor_impossible`).** Let `State`, `Block` be finite, `State` nonempty, and $|\text{Block}| > 1$. For any $f : \text{State} \to \text{Block} \to \text{State}$, the map $(s, b) \mapsto f(s, b)$ is not injective.

*Proof sketch.* The domain $\text{State} \times \text{Block}$ has cardinality $|\text{State}|\cdot|\text{Block}| > |\text{State}|$, the codomain. By pigeonhole two distinct inputs collide. (Formally reuses a Merkle–Damgård compression-collision lemma.) $\square$

Hence a *fixed* hash cannot be a secure extractor; privacy amplification must select a *random* member of a universal family, whose leakage is controlled by Theorem 5.1.

## 6. Optimal Two-Universal Hashing

### 6.1 Algebraic groundwork

The inner-product hash is bilinear over GF(2). The key lemmas: linearity in the input, $\texttt{innerHash}(a, x - y) = \texttt{innerHash}(a, x) - \texttt{innerHash}(a, y)$ (`innerHash_sub`); linearity in the seed, $\texttt{innerHash}(a + b, d) = \texttt{innerHash}(a, d) + \texttt{innerHash}(b, d)$ (`innerHash_add_left`); coordinate selection, $\texttt{innerHash}(e_j, d) = d_j$ (`innerHash_basis`); and the toggle identity $\texttt{innerHash}(a + e_j, d) = \texttt{innerHash}(a, d) + d_j$ (`innerHash_toggle`). A collision is equivalent to a vanishing inner product with the difference: $\texttt{innerHash}(a, x) = \texttt{innerHash}(a, y) \iff \texttt{innerHash}(a, x - y) = 0$ (`collision_iff`). In characteristic 2, $a + e_j + e_j = a$ (`add_e_add_e`).

### 6.2 The counting involution

**Lemma 6.1 (`card_zero_eq_card_one`).** If $d_j = 1$, then the involution $a \mapsto a + e_j$ is a bijection between $\{a : \texttt{innerHash}(a, d) = 0\}$ and $\{a : \texttt{innerHash}(a, d) = 1\}$, so the two sets are equinumerous.

*Proof sketch.* By `innerHash_toggle`, toggling coordinate $j$ adds $d_j = 1$, flipping the parity of the hash; by `add_e_add_e` the map is its own inverse. $\square$

**Lemma 6.2 (`card_zero_add_card_one`).** $\#\{a : \texttt{innerHash}(a, d) = 0\} + \#\{a : \texttt{innerHash}(a, d) = 1\} = 2^n$.

*Proof sketch.* The two sets partition the $2^n$ seeds (every hash value in $\mathbb{Z}/2\mathbb{Z}$ is $0$ or $1$). $\square$

**Lemma 6.3 (`card_collision_eq_half`).** If $d_j = 1$ then $2\,\#\{a : \texttt{innerHash}(a, d) = 0\} = 2^n$.

*Proof sketch.* Combine Lemmas 6.1 (equal halves) and 6.2 (they sum to $2^n$). $\square$

**Lemma 6.4 (`sub_eq_one_of_ne`).** If $x_j \neq y_j$ in $\mathbb{Z}/2\mathbb{Z}$ then $(x - y)_j = 1$.

*Proof sketch.* In GF(2) the only distinct pair is $\{0, 1\}$, whose difference is $1$. $\square$

### 6.3 Two-universality

**Theorem 6.5 (Two-universality, `two_universal`).** For distinct $x \neq y$,
$$2 \cdot \#\{\, a : \texttt{innerHash}(a, x) = \texttt{innerHash}(a, y)\,\} = 2^n.$$

*Proof sketch.* Since $x \neq y$ they differ at some $j$ (`exists_index_ne`), so $(x-y)_j = 1$ by Lemma 6.4. By `collision_iff`, the collision set equals $\{a : \texttt{innerHash}(a, x - y) = 0\}$, whose doubled cardinality is $2^n$ by Lemma 6.3. $\square$

Equivalently, the collision probability over a uniform seed is exactly $1/2$ — the information-theoretic optimum for a single output bit, so the family is *optimally* two-universal.

**Theorem 6.6 ($k$-row generalization, `two_universal_k`).** For distinct $x \neq y$,
$$2^k \cdot \#\{\, A : \mathrm{Fin}\,k \to \texttt{BitVec2}(n) \mid \forall r,\ \texttt{innerHash}(A_r, x) = \texttt{innerHash}(A_r, y)\,\} = (2^n)^k.$$

*Proof sketch.* Row-wise, each row collides iff $\texttt{innerHash}(A_r, x-y) = 0$. The set of collision matrices is the $k$-fold product of the single-row zero set, so its cardinality is $\big(\#\{a : \texttt{innerHash}(a, x-y) = 0\}\big)^k$. Applying Lemma 6.3 ($2 \cdot \#\{\cdots\} = 2^n$) to each of the $k$ independent rows gives $2^k \cdot (\#\{\cdots\})^k = (2^n)^k$. $\square$

The collision probability for $k$ output bits is exactly $2^{-k}$ — precisely the input the leftover-hash bound (Theorem 5.2) consumes.

## 7. Synthesis: The Security Pipeline

The results compose into one end-to-end argument:

1. **Detection (Sec. 3–4).** Listening costs error. Full intercept–resend imprints QBER $= 1/4$ (Thm 3.1), which exceeds the unique threshold $p^\star \approx 11\%$ (Thms 4.6–4.7), so it always forces the key rate negative (Cor. 4.9).
2. **Distillation budget (Sec. 4).** Below $p^\star$, $\texttt{secureKeyRate}(Q) > 0$ (Thm 4.1); the threshold is sharp (strict monotonicity, Thm 4.2) and integer-certified (Lemmas 4.3–4.4).
3. **Amplification (Sec. 5–6).** A randomly chosen GF(2) parity hash is optimally two-universal (Thm 6.5, 6.6), supplying collision probability $2^{-k}$; the leftover-hash bound (Thm 5.1) then forces statistical distance to uniform down to $2^{-(k-\ell)/2}$ (Thm 5.2). Randomization is mandatory because no deterministic compressor is injective (Thm 5.3).

No step invokes a computational hardness assumption.

## 8. Algorithms

**Algorithm A (Integer-certified threshold bracketing).** To bracket $p^\star$, evaluate the sign of $\texttt{binEntropy}(a/b) - (\log 2)/2$ at rational test points by reducing to an integer power comparison $a^a (b-a)^{b-a} \lessgtr 2^{(\cdots)}$, avoiding floating point. Existence on a sign-change interval follows from IVT; uniqueness from monotonicity.

**Algorithm B (Privacy amplification by random parity).** Sample a seed matrix $A \in (\mathbb{Z}/2)^{k \times n}$ uniformly; output $y = A x \bmod 2$. Two-universality (Thm 6.6) guarantees collision probability $2^{-k}$; the leftover-hash bound certifies statistical distance $\le 2^{-(k-\ell)/2}$ when residual min-entropy exceeds $k$.

**Algorithm C (Intercept–resend simulator).** Average `bobErrorProb` over Eve's basis to recover QBER $= 1/4$, then test it against the threshold via `secureKeyRate`.

## 9. Applications and Discussion

The threshold result quantifies the security margin operators must maintain: measured QBER must stay below $\approx 11\%$ for one-way reconciliation. The exact $1/4$ for intercept–resend gives a clean detectability criterion. The optimal two-universality of random parity hashing justifies the simplest possible privacy-amplification primitive (a random GF(2) linear map), and the exponential leftover-hash bound quantifies exactly how many bits to sacrifice for a target secrecy. The non-injectivity result is a reminder that determinism is fatal here.

## 10. Future Directions

- **Rational tightening of $p^\star$.** Iterating the integer-bracket trick to pin $p^\star$ to width $< 10^{-3}$, e.g. $p^\star \in (0.110, 0.111)$, via nested integer power comparisons.
- **Two-way post-processing.** Modeling advantage distillation, $r_2(Q) = 1 + \log_2(1 - 2Q(1-Q)) - H_2(Q)$, to certify the higher $\approx 20\%$ threshold via the same existence/uniqueness/bracket pipeline.
- **Full leftover-hash regime.** Extending `two_universal` ($\ell = 1$) to random $A \in (\mathbb{Z}/2)^{\ell \times n}$ achieving collision probability exactly $2^{-\ell}$ by tensoring the single-bit involution argument.

## 11. Conclusion

We have formalized the information-theoretic spine of BB84: the $1/4$ intercept–resend fingerprint, a sharp and integer-certified $\approx 11\%$ key-rate threshold with provable uniqueness, an exponentially small privacy-amplification leakage bound, and the optimal two-universality of the random-parity hash family — together with the structural necessity of randomization. Every statement is machine-checked, turning the security promise of BB84 from a hope into a theorem.
