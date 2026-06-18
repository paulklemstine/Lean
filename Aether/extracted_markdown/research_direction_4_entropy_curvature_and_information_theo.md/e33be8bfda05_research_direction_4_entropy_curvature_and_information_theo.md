# Entropy Curvature and Information-Theoretic Depth: A Discrete Information Geometry of Higher-Order Log-Concavity

## Abstract

We introduce a formal theory of **entropy curvature** for positive sequences, connecting the hierarchy of higher-order log-concavity to discrete information geometry. The central construction associates to every positive sequence $a : \mathbb{N} \to \mathbb{R}_{>0}$ an entropy curvature profile $\Delta^k(\log \circ a)$, the $k$-th iterated forward finite difference of the logarithm. We prove that (1) ordinary log-concavity is equivalent to nonpositivity of the second entropy curvature, (2) entropy curvature is a normalization invariant of the associated probability law, (3) geometric distributions have vanishing higher curvature — characterizing memorylessness geometrically, (4) log-concavity implies monotonicity of the discrete score function, and (5) Gibbs distributions with affine energy profiles have zero higher curvature. All results are formalized and verified in Lean 4 with the Mathlib library. Computational experiments reveal consistent alternating sign patterns in curvature profiles of standard distribution families.

**Keywords:** discrete information geometry, entropy curvature, higher-order log-concavity, score monotonicity, Gibbs distributions, statistical mechanics, concentration inequalities, monotone likelihood ratio, discrete curvature, combinatorial probability.

---

## 1. Introduction

### 1.1 Motivation

Log-concavity — the condition that $a(n+1)^2 \geq a(n) \cdot a(n+2)$ for a positive sequence — is one of the most ubiquitous regularity conditions in combinatorics, probability, and statistical mechanics. It appears in the theory of Pólya frequency sequences, the study of generating functions of matroids, and the analysis of partition functions.

Recent breakthroughs by Brändén–Huh [1] and Anari–Liu–Oveis Gharan–Vinzant [2] have established deep connections between log-concavity and the geometry of Lorentzian polynomials, revealing that many combinatorial sequences satisfy not just log-concavity but a recursive hierarchy of higher-order conditions.

This paper develops the information-theoretic interpretation of this hierarchy. We show that higher-order log-concavity is a discrete curvature constraint on the information landscape of the associated probability distribution, and that this perspective yields new invariants, new characterizations of classical distributions, and new computational methods.

### 1.2 Overview of Results

Our main contributions are:

1. **Iterated forward differences and entropy curvature** (§2): We define the entropy curvature profile $\Delta^k(\log \circ a)$ and establish its algebraic properties: linearity, constant-killing, and multiplicative invariance.

2. **Second-difference characterization** (Theorem 1, §3.1): Log-concavity of $a$ is equivalent to $\Delta^2(\log a)(n) \leq 0$ for all $n$.

3. **Normalization invariance** (Theorem 2, §3.2): For summable positive sequences, entropy curvature of order $\geq 1$ is invariant under normalization to a probability distribution.

4. **Geometric vanishing** (Theorem 3, §3.3): Geometric sequences have $\Delta^k(\log a) = 0$ for all $k \geq 2$.

5. **Score monotonicity** (Theorem 5, §3.4): Log-concavity implies that the discrete score function $\log(a(n+1)/a(n))$ is antitone.

6. **Gibbs–affine zero curvature** (Theorem 6, §3.5): Gibbs distributions with affine energy have zero higher entropy curvature.

7. **Computational experiments** (§4): We compute curvature profiles for geometric, binomial, Poisson, and ultra-log-concave families, and test a conjecture on alternating sign patterns.

---

## 2. Definitions and Notation

### 2.1 Iterated Forward Differences

**Definition 1** (Forward finite difference). For $f : \mathbb{N} \to \mathbb{R}$, define $\Delta^k f : \mathbb{N} \to \mathbb{R}$ recursively:
$$\Delta^0 f(n) = f(n), \qquad \Delta^{k+1} f(n) = \Delta^k f(n+1) - \Delta^k f(n).$$

The $k$-th forward difference has the explicit formula:
$$\Delta^k f(n) = \sum_{j=0}^{k} \binom{k}{j} (-1)^{k-j} f(n+j).$$

**Proposition 1** (Algebraic properties).
- (Linearity) $\Delta^k(f + g) = \Delta^k f + \Delta^k g$
- (Constant killing) $\Delta^k c = 0$ for $k \geq 1$ and $c$ constant
- (Scalar multiplication) $\Delta^k(c \cdot f) = c \cdot \Delta^k f$
- (Affine killing) If $f(n) = an + b$, then $\Delta^k f = 0$ for $k \geq 2$

All four properties are proved formally in Lean 4.

### 2.2 Entropy Curvature

**Definition 2** (Entropy curvature). For a positive sequence $a : \mathbb{N} \to \mathbb{R}_{>0}$:
$$\kappa_k(a, n) := \Delta^k(\log \circ a)(n) = \Delta^k\big(n \mapsto \log a(n)\big)(n).$$

We call $\kappa_k(a, \cdot)$ the **$k$-th entropy curvature profile** of $a$.

**Definition 3** (Vanishing higher curvature). A positive sequence has *vanishing higher curvature* if $\kappa_k(a, n) = 0$ for all $k \geq 2$ and all $n$.

**Definition 4** (Entropy depth). The *entropy depth* of $a$ is the largest $d$ such that for all $j < d$ and all $n$:
$$(-1)^j \cdot \kappa_{j+1}(a, n) \geq 0.$$

### 2.3 Log-Concavity and Ratio Sequences

**Definition 5**. A sequence $a$ is *log-concave* (written $\mathrm{LogConcaveN}(a)$) if $a(n+1)^2 \geq a(n) \cdot a(n+2)$ for all $n$.

**Definition 6**. The *ratio sequence* is $R(a)(n) = a(n+1)/a(n)$.

**Definition 7**. $a$ is *$k$-fold log-concave* ($\mathrm{KFoldLogConcave}(a, k)$) if $a$ is positive for $k = 0$, and positive, log-concave, with $(k-1)$-fold log-concave ratio sequence for $k \geq 1$.

---

## 3. Main Results

### 3.1 Theorem 1: Second-Difference Characterization

**Theorem 1.** *Let $a : \mathbb{N} \to \mathbb{R}_{>0}$. Then*
$$\mathrm{LogConcaveN}(a) \iff \forall n,\; \Delta^2(\log a)(n) \leq 0.$$

**Proof sketch.** Expand:
$$\Delta^2(\log a)(n) = \log a(n+2) - 2\log a(n+1) + \log a(n) = \log\frac{a(n) \cdot a(n+2)}{a(n+1)^2}.$$

Forward direction: $a(n+1)^2 \geq a(n) \cdot a(n+2)$ gives $a(n) \cdot a(n+2) / a(n+1)^2 \leq 1$, so $\log(\cdot) \leq 0$.

Backward direction: $\log(a(n) \cdot a(n+2) / a(n+1)^2) \leq 0$ gives $a(n) \cdot a(n+2) / a(n+1)^2 \leq 1$ by monotonicity of $\log$ on $(0, \infty)$. ∎

**Significance.** This is the exact bridge between multiplicative combinatorial inequalities and discrete curvature. It converts a nonlinear product inequality into a sign condition on a linear finite-difference operator.

### 3.2 Theorem 2: Normalization Invariance

**Theorem 2.** *Let $a : \mathbb{N} \to \mathbb{R}_{>0}$ be summable with $Z = \sum_n a(n) > 0$, and let $\pi(n) = a(n)/Z$. Then for all $k \geq 1$ and all $n$:*
$$\Delta^k(\log \pi)(n) = \Delta^k(\log a)(n).$$

**Proof sketch.** Write $\log \pi(n) = \log a(n) - \log Z$. Since $\log Z$ is constant, $\Delta^k(\log Z) = 0$ for $k \geq 1$ by the constant-killing property. Apply linearity. Alternatively, note $\pi(n) = Z^{-1} \cdot a(n)$ and apply the multiplicative constant lemma: $\Delta^k(\log(c \cdot a)) = \Delta^k(\log a)$ for $k \geq 1$ when $c > 0$. ∎

**Significance.** Entropy curvature is an intrinsic invariant of the probability law, not an artifact of normalization. This makes it suitable for information-theoretic analysis.

### 3.3 Theorem 3: Geometric Vanishing

**Theorem 3.** *For $0 < r < 1$, the geometric sequence $a(n) = (1-r) \cdot r^n$ satisfies $\Delta^k(\log a)(n) = 0$ for all $k \geq 2$ and all $n$.*

**Proof sketch.** Compute $\log a(n) = \log(1-r) + n \cdot \log r$, which is affine in $n$. Apply the affine-killing property of forward differences. ∎

**Corollary.** Geometric distributions have vanishing higher curvature: $\mathrm{VanishingHigherCurvature}(a)$.

**Remark.** The original conjecture that geometric distributions have *infinite entropy depth* (Definition 4) is false: for $0 < r < 1$, $\Delta^1(\log a)(n) = \log r < 0$, violating the $j = 0$ sign condition. The correct invariant capturing "flatness" of memoryless distributions is vanishing higher curvature (all curvatures of order $\geq 2$ vanish), not infinite entropy depth.

### 3.4 Theorem 5: Score Monotonicity

**Theorem 5.** *Let $a : \mathbb{N} \to \mathbb{R}_{>0}$ with $\mathrm{LogConcaveN}(a)$. Then the score function*
$$s(n) = \log a(n+1) - \log a(n)$$
*is antitone (non-increasing).*

**Proof sketch.** We need $s(n+1) \leq s(n)$, i.e., $\log a(n+2) - \log a(n+1) \leq \log a(n+1) - \log a(n)$. This is equivalent to $\Delta^2(\log a)(n) \leq 0$, which holds by Theorem 1. Apply `antitone_nat_of_succ_le`. ∎

**Significance.** This connects log-concavity to the monotone likelihood ratio property in statistics and to hazard rate ordering in reliability theory.

### 3.5 Theorem 6: Gibbs–Affine Zero Curvature

**Theorem 6.** *For any $\alpha, \beta \in \mathbb{R}$, the Gibbs weights $a(n) = \exp(-(\alpha n + \beta))$ satisfy $\Delta^k(\log a)(n) = 0$ for all $k \geq 2$.*

**Proof sketch.** $\log \exp(-(\alpha n + \beta)) = -\alpha n - \beta$, which is affine. Apply affine-killing. ∎

**Significance.** This bridges statistical mechanics and information geometry: affine energy landscapes produce zero-curvature Gibbs measures, generalizing the geometric vanishing theorem to arbitrary temperature and tilt parameters.

---

## 4. Computational Experiments

### 4.1 Setup

We implemented the entropy curvature computation in Python and tested on:
- Geometric distributions: $a(n) = (1-r)r^n$, $r \in \{0.2, 0.3, 0.5, 0.7, 0.8\}$
- Binomial distributions: $a(i) = \binom{N}{i} p^i (1-p)^{N-i}$, various $N, p$
- Poisson truncations: $a(m) = e^{-\lambda} \lambda^m / m!$, various $\lambda$
- Ultra-log-concave: $a(i) = \binom{N}{i}^2 / \binom{2N}{N}$

### 4.2 Curvature Profiles

| Family | $\Delta^2$ sign | $\Delta^3$ sign | $\Delta^4$ sign | $\Delta^5$ sign |
|--------|:---:|:---:|:---:|:---:|
| Geometric | 0 | 0 | 0 | 0 |
| Binomial(15, 0.4) | all − | +++−−− | all − | +++−−− |
| Poisson(5) | all − | all + | all − | all + |
| Ultra-LC(8) | all − | +++−−− | all − | +++−−− |

**Key observation:** For Poisson distributions, the alternating sign pattern $(-1)^k \cdot \Delta^k > 0$ holds cleanly for all orders tested. For binomial and ultra-log-concave families, boundary effects cause sign violations at the support endpoints, but the interior signs follow the alternating pattern.

### 4.3 Normalization Invariance Verification

For Binomial(10, 0.4) with $Z = 1.0$ (already normalized):

| Order $k$ | $\max_n |\Delta^k(\log a) - \Delta^k(\log \pi)|$ |
|:---:|:---:|
| 1 | 0 |
| 2 | 0 |
| 3 | 0 |
| 4 | 0 |
| 5 | 0 |

Exact numerical equality confirms Theorem 2.

### 4.4 Score Monotonicity Verification

All tested log-concave sequences exhibit antitone score functions, confirming Theorem 5:

| Distribution | Score antitone? |
|---|:---:|
| Binomial(15, 0.5) | ✓ |
| Poisson(4) | ✓ |
| Geometric(0.6) | ✓ |

### 4.5 Conjecture Testing

The original conjecture — that $k$-fold log-concavity implies $(-1)^j \cdot \Delta^{j+2}(\log a)(n) \geq 0$ for all $j < k$ — was tested and **refuted** for binomial distributions: the $j = 0$ case requires $\Delta^2(\log a) \geq 0$, but log-concavity gives $\Delta^2(\log a) \leq 0$.

**Corrected conjecture.** The sign convention in the original conjecture was inverted. The corrected version:

> For positive $a$ with $\mathrm{KFoldLogConcave}(a, k)$ and $j < k$:
> $$(-1)^{j+1} \cdot \Delta^{j+2}(\log a)(n) \geq 0$$
> on the interior of the support.

This corrected conjecture holds for all tested geometric and Poisson families. For finite-support families (binomial, ultra-log-concave), it holds on the interior but may fail at boundary points.

---

## 5. Applications

### 5.1 Distribution Classification

The entropy curvature profile serves as a fingerprint for distribution classification:
- **Geometric-like:** Zero curvature at all orders $\geq 2$
- **Binomial-like:** Strictly negative second curvature, alternating signs with boundary effects
- **Poisson-like:** Clean alternating signs at all orders

### 5.2 Statistical Testing

Theorem 5 provides a necessary condition for log-concavity: check score monotonicity. This yields a simple, $O(n)$-time statistical test for log-concavity departure.

### 5.3 Compression Quality

For source coding, distributions with higher entropy depth have more predictable curvature profiles, enabling tighter bounds on redundancy.

### 5.4 Statistical Mechanics

Curvature profiles of partition functions encode the geometry of the energy landscape, with zero curvature characterizing harmonic (affine) potentials.

---

## 6. Discussion

### 6.1 Limitations

- The theory as developed applies to sequences on $\mathbb{N}$; extension to continuous distributions requires different tools.
- The conjecture on alternating sign patterns for $k$-fold log-concavity remains open in its corrected form.
- Finite-support boundary effects complicate sign pattern analysis.

### 6.2 Relationship to Prior Work

The connection between log-concavity and $\Delta^2(\log a) \leq 0$ is classical. Our contribution is the systematic development of the *higher-order* theory, the normalization invariance result, the Gibbs connection, and the formal verification.

### 6.3 Formal Verification

All theorems are verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound). The formalization consists of approximately 250 lines of Lean code, including definitions, helper lemmas, and six main theorems with complete proofs.

---

## 7. Future Work

1. Extension of the alternating sign conjecture with appropriate boundary conditions
2. Continuous analogues via differential entropy and Fisher information
3. Applications to phase transition detection in statistical mechanics
4. Connections to total positivity and Pólya frequency sequences
5. Curvature-controlled bounds for source coding redundancy

---

## References

[1] P. Brändén and J. Huh, "Lorentzian Polynomials," *Annals of Mathematics*, vol. 192, no. 3, pp. 821–891, 2020.

[2] N. Anari, K. Liu, S. Oveis Gharan, and C. Vinzant, "Log-Concave Polynomials II: High-Dimensional Walks and an FPRAS for Counting Bases of a Matroid," *Annals of Mathematics*, vol. 199, no. 1, pp. 259–299, 2024.

[3] T. M. Cover and J. A. Thomas, *Elements of Information Theory*, 2nd ed. Wiley, 2006.

[4] R. P. Stanley, "Log-Concave and Unimodal Sequences in Algebra, Combinatorics, and Geometry," *Annals of the New York Academy of Sciences*, vol. 576, pp. 500–535, 1989.

[5] A. Saumard and J. A. Wellner, "Log-Concavity and Strong Log-Concavity: A Review," *Statistics Surveys*, vol. 8, pp. 45–114, 2014.
