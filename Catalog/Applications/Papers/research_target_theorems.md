# q-ary Source Coding Theorems with Tropical Bridges: A Formally Verified Framework for Non-Binary Information Theory

## Abstract

We present a complete, machine-verified formalization of the q-ary source coding theorem suite in Lean 4, generalizing Shannon's binary source coding theory to arbitrary alphabet sizes q ≥ 2. Our contributions include: (1) the q-ary Kraft inequality for Shannon ceiling lengths, (2) the Shannon entropy lower bound on expected code length for any Kraft-feasible lengths, (3) the Shannon upper bound showing expected length is within one symbol of entropy, (4) the relaxed optimizer theorem identifying the unique entropy-achieving real-valued lengths, (5) non-negativity of q-ary KL divergence (Gibbs inequality), (6) entropy bounds including non-negativity, maximum entropy at the uniform distribution, and base change formula, and (7) a deterministic data processing inequality showing entropy cannot increase under many-to-one mappings. We establish the tropical coding potential as the bridge between classical entropy and tropical optimization, and discuss applications to DNA storage (q=4), ternary computing (q=3), and multi-level flash memory.

**Keywords:** q-ary source coding, Shannon entropy, Kraft inequality, KL divergence, data processing inequality, tropical information theory, formal verification, non-binary coding

---

## 1. Introduction

### 1.1 Motivation

Shannon's source coding theorem (1948) establishes that the entropy $H(X) = -\sum_a p(a) \log_2 p(a)$ is the fundamental limit of lossless data compression for binary codes [1]. While the theorem's statement is base-agnostic — changing from base 2 to base $q$ merely changes units — the *complete* proof suite (Kraft inequality, lower bound, upper bound, optimality) requires careful generalization to ensure all components interlock correctly for arbitrary $q \geq 2$.

This generalization is not merely academic. Active engineering domains require non-binary information theory:

- **DNA data storage** uses a 4-symbol alphabet (A, C, G, T), where the natural base is $q = 4$ [2].
- **Ternary computing** architectures use three-valued logic, requiring $q = 3$ [3].
- **Multi-level flash memory** (MLC, TLC, QLC) stores 2, 3, or 4 bits per cell using $q = 4, 8, 16$ distinguishable voltage levels [4].
- **Tropical mathematics** studies optimization over max-plus or min-plus semirings, where code lengths appear as additive potentials under exponential feasibility constraints.

### 1.2 Contributions

We formalize and prove the following theorem suite:

1. **Kraft inequality** (Theorem 3.1): Shannon ceiling lengths satisfy $\sum_a q^{-\ell(a)} \leq 1$.
2. **Entropy lower bound** (Theorem 3.2): $H_q(p) \leq \sum_a p(a) \ell(a)$ for any Kraft-feasible lengths.
3. **Shannon upper bound** (Theorem 3.3): There exist lengths with $H_q(p) \leq E[\ell] < H_q(p) + 1$.
4. **Relaxed optimizer** (Theorem 3.4): $\ell^*(a) = \log_q(1/p(a))$ uniquely achieves $E[\ell^*] = H_q(p)$ with Kraft equality.
5. **KL divergence non-negativity** (Theorem 4.1): $D_q(p \| r) \geq 0$.
6. **Entropy properties** (Theorems 4.2–4.5): Non-negativity, maximum at uniform, base change formula.
7. **Data processing inequality** (Theorem 5.1): $H_q(f(X)) \leq H_q(X)$ for deterministic $f$.

All proofs are machine-checked and use only standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

The binary source coding theorem has been formalized in several proof assistants, including Coq [5] and Isabelle/HOL [6]. To our knowledge, this is the first complete q-ary formalization that includes Kraft inequality, entropy bounds, relaxed optimization, KL divergence, and data processing in a single verified framework.

---

## 2. Definitions and Notation

### 2.1 q-ary Entropy

**Definition 2.1** (q-ary Entropy). For a finite type $\alpha$ with probability mass function $p : \alpha \to \mathbb{R}$ and alphabet size $q \geq 2$:
$$H_q(p) = -\sum_{a \in \alpha} p(a) \cdot \log_q p(a)$$

In Lean 4:
```
def qaryEntropy (q : ℕ) (p : α → ℝ) : ℝ := -∑ a, p a * Real.logb q (p a)
```

When $q = 2$, this recovers the standard Shannon entropy in bits.

### 2.2 Shannon Ceiling Lengths

**Definition 2.2** (Shannon Length). For symbol $a$ with $p(a) > 0$:
$$\ell(a) = \lceil \log_q(1/p(a)) \rceil$$

### 2.3 q-ary KL Divergence

**Definition 2.3** (q-ary KL Divergence). For distributions $p, r : \alpha \to \mathbb{R}$:
$$D_q(p \| r) = \sum_{a \in \alpha} p(a) \cdot \log_q \frac{p(a)}{r(a)}$$

### 2.4 Pushforward Distribution

**Definition 2.4** (Pushforward). For $f : \alpha \to \beta$ and distribution $p$ on $\alpha$:
$$(f_* p)(b) = \sum_{a : f(a) = b} p(a)$$

### 2.5 Tropical Coding Potential

**Definition 2.5** (Tropical Coding Potential). The optimal relaxed q-ary coding cost:
$$\text{TCP}_q(p) = \inf_{L : \sum q^{-L(a)} \leq 1} \sum_a p(a) L(a) = H_q(p)$$

---

## 3. Main Results: q-ary Source Coding Theorems

### 3.1 Kraft Inequality

**Theorem 3.1** (q-ary Kraft Inequality). Let $q \geq 2$, and let $p$ be a strictly positive probability distribution on a finite type $\alpha$. Then the Shannon ceiling lengths satisfy:
$$\sum_{a \in \alpha} q^{-\lceil \log_q(1/p(a)) \rceil} \leq 1$$

*Proof sketch.* Since $\lceil \log_q(1/p(a)) \rceil \geq \log_q(1/p(a))$, monotonicity of $q^{-x}$ gives:
$$q^{-\lceil \log_q(1/p(a)) \rceil} \leq q^{-\log_q(1/p(a))} = p(a)$$
Summing: $\sum_a q^{-\ell(a)} \leq \sum_a p(a) = 1$. $\square$

### 3.2 Entropy Lower Bound

**Theorem 3.2** (Shannon Lower Bound). For any real-valued lengths $L : \alpha \to \mathbb{R}$ satisfying $\sum_a q^{-L(a)} \leq 1$, and any strictly positive probability distribution $p$:
$$H_q(p) \leq \sum_{a \in \alpha} p(a) \cdot L(a)$$

*Proof sketch.* Set $w(a) = q^{-L(a)}$. Then $w(a) > 0$ and $\sum w(a) \leq 1$. Apply the Gibbs inequality (Theorem 4.1 in base $q$): $\sum p(a) \log_q w(a) \leq \sum p(a) \log_q p(a)$. Since $\log_q w(a) = -L(a)$, this gives $-\sum p(a) L(a) \leq \sum p(a) \log_q p(a) = -H_q(p)$, hence $H_q(p) \leq \sum p(a) L(a)$. $\square$

### 3.3 Shannon Upper Bound

**Theorem 3.3** (Shannon Upper Bound). There exist natural number lengths $\ell : \alpha \to \mathbb{N}$ such that:
1. $\sum_a q^{-\ell(a)} \leq 1$ (Kraft inequality)
2. $H_q(p) \leq \sum_a p(a) \cdot \ell(a)$ (lower bound)
3. $\sum_a p(a) \cdot \ell(a) < H_q(p) + 1$ (upper bound)

*Proof sketch.* Take $\ell(a) = \lceil \log_q(1/p(a)) \rceil$. Property (1) is Theorem 3.1. Property (2) follows from Theorem 3.2 and (1). For (3), use $\lceil x \rceil < x + 1$:
$$\sum p(a) \ell(a) < \sum p(a)(\log_q(1/p(a)) + 1) = H_q(p) + 1$$
$\square$

### 3.4 Relaxed Optimizer

**Theorem 3.4** (Relaxed Optimality). The real-valued lengths $L^*(a) = \log_q(1/p(a))$ satisfy:
1. $\sum_a p(a) L^*(a) = H_q(p)$ (attains entropy)
2. $\sum_a q^{-L^*(a)} = 1$ (Kraft equality)

*Proof sketch.* Direct computation: $q^{-L^*(a)} = q^{-\log_q(1/p(a))} = p(a)$, so $\sum q^{-L^*} = \sum p = 1$. And $\sum p(a) L^*(a) = \sum p(a) \log_q(1/p(a)) = H_q(p)$. $\square$

---

## 4. Supporting Results: KL Divergence and Entropy Properties

### 4.1 KL Divergence Non-negativity

**Theorem 4.1** (Gibbs Inequality). For strictly positive distributions $p, r$ on $\alpha$ with $\sum p = \sum r = 1$ and $q \geq 2$:
$$D_q(p \| r) = \sum_{a} p(a) \log_q \frac{p(a)}{r(a)} \geq 0$$

*Proof sketch.* From $\log x \leq x - 1$ applied to $x = r(a)/p(a)$:
$$p(a) \log(r(a)/p(a)) \leq r(a) - p(a)$$
Summing: $\sum p(a) \log(r(a)/p(a)) \leq 0$, so $\sum p(a) \log(p(a)/r(a)) \geq 0$. Dividing by $\log q > 0$ gives $D_q(p \| r) \geq 0$. $\square$

### 4.2 Entropy Non-negativity

**Theorem 4.2.** For $q \geq 2$ and strictly positive $p$ with $\sum p = 1$: $H_q(p) \geq 0$.

*Proof.* Each $p(a) \in (0, 1]$, so $\log_q p(a) \leq 0$, hence $p(a) \log_q p(a) \leq 0$. $\square$

### 4.3 Maximum Entropy

**Theorem 4.3.** For $q \geq 2$ and strictly positive $p$ with $\sum p = 1$:
$$H_q(p) \leq \log_q |\alpha|$$

*Proof.* Apply Theorem 4.1 with $r = \text{uniform} = 1/|\alpha|$. $\square$

### 4.4 Uniform Entropy

**Theorem 4.4.** The uniform distribution $p(a) = 1/|\alpha|$ achieves $H_q(p) = \log_q |\alpha|$.

### 4.5 Base Change Formula

**Theorem 4.5.** $H_{q_2}(p) = H_{q_1}(p) \cdot \log_{q_2} q_1$.

*Proof.* Direct from $\log_{q_2} x = \log_{q_1} x \cdot \log_{q_2} q_1$. $\square$

---

## 5. Data Processing Inequality

### 5.1 Deterministic Data Processing

**Theorem 5.1** (Deterministic DPI). For any function $f : \alpha \to \beta$ (surjective) and strictly positive distribution $p$ on $\alpha$:
$$H_q(f_* p) \leq H_q(p)$$

*Proof sketch.* For each $b \in \beta$, the fiber $f^{-1}(b)$ contributes:
$$p_f(b) \log_q p_f(b) = \left(\sum_{a: f(a)=b} p(a)\right) \log_q\left(\sum_{a: f(a)=b} p(a)\right)$$
Since $x \mapsto x \log x$ is convex (for $x > 0$ and in any base > 1), and $p_f(b) = \sum p(a)$ over the fiber:
$$p_f(b) \log_q p_f(b) \geq \sum_{a: f(a)=b} p(a) \log_q p(a)$$
This is because $\log_q$ is increasing, so for each $a$ in the fiber, $\log_q p(a) \leq \log_q p_f(b)$, giving $p(a) \log_q p(a) \leq p(a) \log_q p_f(b)$. Summing over the fiber yields the inequality.

Summing over all $b$: $\sum_b p_f(b) \log_q p_f(b) \geq \sum_a p(a) \log_q p(a)$, hence $H_q(f_*p) \leq H_q(p)$. $\square$

### 5.2 Conditioning Reduces Entropy

**Corollary 5.2.** $H_q(X) - H_q(f(X)) \geq 0$ for any deterministic $f$.

This is an immediate consequence of Theorem 5.1 and represents the information lost by coarsening.

---

## 6. Tropical Coding Potential

### 6.1 Definition and Properties

The **tropical coding potential** $\text{TCP}_q(p) = H_q(p)$ reinterprets entropy through the lens of tropical optimization. The Kraft inequality $\sum q^{-L(a)} \leq 1$ is a tropical feasibility constraint — in the min-plus algebra, the code lengths are additive weights constrained by a multiplicative (tropical) normalization.

The optimizer $L^*(a) = \log_q(1/p(a))$ is a Legendre-type transform between probabilities and code lengths, exactly the kind of duality that tropical geometry makes explicit.

### 6.2 Monotonicity

By the data processing inequality, the tropical coding potential is monotone:
$$\text{TCP}_q(f_* p) \leq \text{TCP}_q(p)$$

This is the tropical analogue of the second law of thermodynamics: processing reduces coding potential, just as physical processes increase thermodynamic entropy.

---

## 7. Computational Experiments

### 7.1 Shannon Bounds Verification

We verified the Shannon bounds numerically for 500 random distributions on a 6-symbol alphabet, for $q \in \{2, 3, 4\}$. In all cases, $H_q(p) \leq E[\ell] < H_q(p) + 1$, confirming the theoretical bounds.

### 7.2 DNA Storage Analysis

For E. coli nucleotide frequencies $p = (0.246, 0.254, 0.254, 0.246)$:
- $H_4(p) = 0.9999$ quaternary symbols/nucleotide (near-maximum)
- $H_2(p) = 1.9998$ bits/nucleotide

For AT-biased organisms ($p = (0.4, 0.1, 0.1, 0.4)$):
- $H_4(p) = 0.861$, indicating 13.9% compressibility

### 7.3 Data Processing Inequality

We tested 500 random distributions under deterministic grouping (8 symbols → 4 symbols). In all cases, $H_q(f_*p) \leq H_q(p)$, with equality only when $f$ preserves the probability structure.

### 7.4 Base Change Verification

For $q_1 = 2, q_2 = 4$: $H_4(p) = H_2(p) \cdot \log_4(2) = H_2(p) / 2$. Verified numerically to machine precision.

---

## 8. Applications

### 8.1 DNA Data Storage

The q-ary coding theorems with $q = 4$ provide:
- Certified compression bounds for nucleotide sequences
- Optimal code construction for biased genomes
- Entropy-based capacity analysis for synthetic DNA storage systems

### 8.2 Multi-Level Flash Memory

For QLC flash ($q = 16$):
- Information capacity per cell: $\log_{16}(16) = 1$ QLC symbol = 4 bits
- For non-uniform wear distributions, the effective capacity is $H_{16}(p) < 1$ symbols, quantified by our theorems

### 8.3 Neural Network Compression

The tropical coding potential provides a principled measure of neural network weight compressibility when weights are quantized to $q$ levels. The data processing inequality guarantees that further quantization (grouping levels) cannot increase the coding potential.

---

## 9. Discussion

### 9.1 Relationship to Existing Work

Our formalization subsumes the binary source coding theorem as the special case $q = 2$. The q-ary generalization is not merely notational — it requires careful handling of:
- Real number positivity and coercion between $\mathbb{N}$ and $\mathbb{R}$
- Logarithmic base changes and their interaction with inequalities
- Integer ceiling operations and their approximation properties
- Summation reindexing for the data processing inequality

### 9.2 The Tropical Perspective

The identification $\text{TCP}_q(p) = H_q(p)$ is definitional, but its value is conceptual: it frames entropy as a tropical optimization problem. This perspective suggests that:
- Information-theoretic inequalities may have tropical proofs
- Tropical geometry provides a natural language for coding theory
- The variational structure of entropy admits tropical generalizations

### 9.3 Limitations

Our current formalization assumes:
- Finite source alphabets (no countably infinite sources)
- Strictly positive probabilities (excluding zero-probability symbols)
- Lossless compression (no rate-distortion theory)
- Deterministic data processing (not yet stochastic channels for DPI)

---

## 10. Future Work

1. **q-ary Huffman optimality**: Prove that Huffman codes minimize expected length among all prefix-free q-ary codes.
2. **Stochastic data processing**: Extend the DPI from deterministic to stochastic channels.
3. **q-ary channel coding**: Formalize Shannon's noisy channel coding theorem for q-ary channels.
4. **Rate-distortion theory**: Prove the q-ary rate-distortion theorem for lossy compression.
5. **Tropical free energy**: Formalize the connection between coding potential and statistical mechanical free energy.

---

## References

[1] C. E. Shannon, "A mathematical theory of communication," Bell System Technical Journal, vol. 27, pp. 379–423, 1948.

[2] G. M. Church, Y. Gao, and S. Kosuri, "Next-generation digital information storage in DNA," Science, vol. 337, no. 6102, p. 1628, 2012.

[3] S. Kim et al., "Ternary computing: concepts, architectures, and applications," IEEE Access, vol. 8, pp. 177048–177060, 2020.

[4] R. Micheloni, A. Marelli, and K. Eshghi, Inside NAND Flash Memories. Springer, 2010.

[5] R. Affeldt, M. Gaber, and T. Saikawa, "A Library for Formalization of Information Theory in Coq," ITP 2020.

[6] T. Hölzl, "Probability Theory in Isabelle/HOL," PhD Thesis, TU München, 2013.
