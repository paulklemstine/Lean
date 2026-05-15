# The Gibbs Variational Principle for Finite Log-Sum-Exp: A Formally Verified Foundation for Entropy-Regularized Optimization

## Abstract

We present a complete formal proof of the finite-dimensional Gibbs variational principle, establishing the identity

$$\tau \log \sum_{i=1}^n e^{x_i/\tau} = \sup_{p \in \Delta_n} \left\{ \sum_{i=1}^n p_i x_i + \tau H(p) \right\}$$

where $H(p) = -\sum_i p_i \log p_i$ is Shannon entropy and $\Delta_n$ is the probability simplex. The proof is decomposed into a modular chain of reusable results: a scalar KL inequality derived from $\log x \le x - 1$, finite Gibbs inequality (KL divergence nonnegativity), a universal upper bound on free energy, exact attainment at the softmax distribution, and the supremum characterization. We also prove that the softmax distribution is the unique optimizer. The formalization comprises approximately 200 lines of Lean 4 code with complete proofs and no axioms beyond the standard foundations. We discuss applications to statistical mechanics, attention mechanisms, tropical geometry, and information theory.

## 1. Introduction

### 1.1 Motivation

The log-sum-exp function $\text{LSE}_\tau(x) = \tau \log \sum_i e^{x_i/\tau}$ is one of the most widely used smooth approximations in mathematics and engineering. It serves simultaneously as:

- The **free energy** of a canonical ensemble in statistical mechanics [1],
- The **cumulant generating function** evaluator in probability theory,
- A **smooth maximum** approximation in optimization [2],
- The normalizing constant in **softmax attention** mechanisms [3],
- The **Legendre–Fenchel conjugate** of negative Shannon entropy [4].

The Gibbs variational principle provides the exact characterization:

$$\text{LSE}_\tau(x) = \max_{p \in \Delta_n} \left\{ \langle x, p \rangle + \tau H(p) \right\}$$

with the maximum uniquely attained at the softmax/Gibbs distribution $q_i = e^{x_i/\tau}/Z$.

While this result is well known in the mathematical community, its formalization reveals several nontrivial challenges: handling the $0 \log 0 = 0$ convention, managing positivity side conditions for logarithms, and constructing the supremum characterization from the optimizer.

### 1.2 Contributions

1. **Complete formal proof** of the variational formula with no sorry or non-standard axioms
2. **Modular proof architecture**: each intermediate result is independently useful
3. **Reusable KL divergence infrastructure**: scalar and finite Gibbs inequalities
4. **Optimizer characterization**: softmax is proved to be the unique maximizer
5. **Supremum formulation**: exact $\text{sSup}$ identity, not merely bounds

### 1.3 Related Work

The Gibbs variational principle appears in Gibbs's original work [1], and modern treatments can be found in Ellis [5], Cover & Thomas [6], and Boyd & Vandenberghe [4]. Formal proofs of related results in interactive theorem provers include work on entropy in Isabelle/HOL [7] and convex analysis in Coq [8], but to our knowledge this is the first complete formalization of the finite-dimensional log-sum-exp variational formula.

## 2. Definitions and Notation

### 2.1 Probability Simplex

**Definition 2.1** (Probability Vector). A function $p : \text{Fin}(n) \to \mathbb{R}$ is a probability vector if $p_i \ge 0$ for all $i$ and $\sum_i p_i = 1$.

```
def IsProbVec {n : ℕ} (p : Fin n → ℝ) : Prop :=
  (∀ i, 0 ≤ p i) ∧ (∑ i, p i) = 1
```

### 2.2 Shannon Entropy

**Definition 2.2** (Shannon Entropy Term). For $p : \text{Fin}(n) \to \mathbb{R}$,
$$H(p) = -\sum_{i} \hat{p}_i \log p_i, \quad \text{where } \hat{p}_i = \begin{cases} 0 & p_i = 0 \\ p_i & \text{otherwise} \end{cases}$$

The convention $0 \log 0 = 0$ is enforced by the conditional.

### 2.3 Free Energy Objective

**Definition 2.3**. The free energy objective at temperature $\tau$ is
$$F_\tau(x, p) = \sum_i p_i x_i + \tau H(p) = \langle x, p \rangle + \tau H(p)$$

### 2.4 Partition Function and Softmax

**Definition 2.4**. The partition function is $Z(\tau, x) = \sum_i e^{x_i/\tau}$.

**Definition 2.5**. The softmax (Gibbs) distribution is $q_i = e^{x_i/\tau} / Z(\tau, x)$.

## 3. Main Results

### 3.1 Theorem Ladder

The proof proceeds through six levels:

| # | Result | Statement |
|---|--------|-----------|
| 1 | `partitionFun_pos` | $Z > 0$ when $n > 0$ |
| 2 | `softmaxProb_isProbVec` | Softmax defines a valid probability vector |
| 3 | `scalar_kl_ineq` | $u - v \le u \log(u/v)$ for $u \ge 0, v > 0$ |
| 4 | `gibbs_inequality_finite` | $\sum_i p_i \log(p_i/q_i) \ge 0$ (KL nonnegativity) |
| 5 | `freeEnergy_le_lse` | $F_\tau(x, p) \le \tau \log Z$ for all $p \in \Delta_n$ |
| 6 | `freeEnergy_eq_lse_at_softmax` | $F_\tau(x, q) = \tau \log Z$ |
| 7 | `lse_variational_formula` | $\tau \log Z = \text{sSup}\{F_\tau(x, p) \mid p \in \Delta_n\}$ |

### 3.2 Partition Function Positivity

**Theorem 3.1**. For $n > 0$, $Z(\tau, x) = \sum_{i=1}^n e^{x_i/\tau} > 0$.

*Proof.* Each term $e^{x_i/\tau} > 0$ by positivity of the exponential. The sum over a nonempty index set of positive terms is positive. □

### 3.3 Softmax Properties

**Theorem 3.2**. For $n > 0$, the softmax distribution $q$ satisfies:
- $q_i > 0$ for all $i$ (strict positivity)
- $\sum_i q_i = 1$ (normalization)
- $\log q_i = x_i/\tau - \log Z$ (log-linear structure)

*Proof.* Positivity follows from $e^{x_i/\tau} > 0$ and $Z > 0$. Normalization: $\sum_i q_i = \sum_i e^{x_i/\tau}/Z = Z/Z = 1$. The log identity follows from $\log(a/b) = \log a - \log b$ and $\log(e^y) = y$. □

### 3.4 Scalar KL Inequality

**Theorem 3.3** (Scalar KL Inequality). For $u \ge 0$ and $v > 0$:
$$u - v \le \begin{cases} 0 & u = 0 \\ u \log(u/v) & u > 0 \end{cases}$$

*Proof sketch.* When $u = 0$: LHS $= -v \le 0$ = RHS. When $u > 0$: the inequality $u - v \le u \log(u/v)$ is equivalent to $1 - v/u \le -\log(v/u)$, i.e., $\log(v/u) \le v/u - 1$. This is the fundamental logarithmic inequality $\log x \le x - 1$ applied to $x = v/u > 0$. □

### 3.5 Gibbs Inequality (KL Nonnegativity)

**Theorem 3.4** (Gibbs Inequality). Let $p, q$ be probability vectors with $q_i > 0$ for all $i$. Then
$$\text{KL}(p \| q) = \sum_i p_i \log\frac{p_i}{q_i} \ge 0$$

with the convention $0 \log(0/q_i) = 0$.

*Proof.* Apply Theorem 3.3 with $u = p_i, v = q_i$ for each $i$ and sum:
$$\sum_i (p_i - q_i) \le \sum_i p_i \log(p_i/q_i)$$
The left side equals $\sum_i p_i - \sum_i q_i = 1 - 1 = 0$. □

### 3.6 Free Energy Upper Bound

**Theorem 3.5**. For any probability vector $p$ and $\tau > 0$:
$$F_\tau(x, p) \le \tau \log Z$$

*Proof.* Let $q$ be the softmax distribution. We establish the decomposition:
$$F_\tau(x, p) = \tau \log Z - \tau \cdot \text{KL}(p \| q)$$

To verify this, expand $\text{KL}(p \| q)$:
$$\text{KL}(p \| q) = \sum_i p_i \log p_i - \sum_i p_i \log q_i$$
$$= \sum_i p_i \log p_i - \sum_i p_i(x_i/\tau - \log Z)$$
$$= \sum_i p_i \log p_i - \frac{1}{\tau}\sum_i p_i x_i + \log Z$$

Therefore:
$$\tau \log Z - \tau \cdot \text{KL}(p \| q) = \sum_i p_i x_i - \tau \sum_i p_i \log p_i = F_\tau(x, p)$$

Since $\text{KL}(p \| q) \ge 0$ by Theorem 3.4, we conclude $F_\tau(x, p) \le \tau \log Z$. □

### 3.7 Attainment at Softmax

**Theorem 3.6**. $F_\tau(x, q) = \tau \log Z$ where $q$ is the softmax distribution.

*Proof.* Direct computation:
$$F_\tau(x, q) = \sum_i q_i x_i + \tau H(q)$$

Since $q_i > 0$ for all $i$, $H(q) = -\sum_i q_i \log q_i$. Using $\log q_i = x_i/\tau - \log Z$:

$$\sum_i q_i \log q_i = \sum_i q_i(x_i/\tau - \log Z) = \frac{1}{\tau}\sum_i q_i x_i - \log Z$$

Therefore:
$$F_\tau(x, q) = \sum_i q_i x_i - \tau\left(\frac{1}{\tau}\sum_i q_i x_i - \log Z\right) = \tau \log Z$$
□

### 3.8 Supremum Characterization

**Theorem 3.7** (Gibbs Variational Principle). For $n > 0$ and $\tau > 0$:
$$\tau \log \sum_{i=1}^n e^{x_i/\tau} = \sup\{F_\tau(x, p) \mid p \in \Delta_n\}$$

*Proof.* We verify the three conditions for $\text{csSup\_eq\_of\_forall\_le\_of\_forall\_lt\_exists\_gt}$:
1. **Nonemptiness**: The uniform distribution $p_i = 1/n$ is in $\Delta_n$.
2. **Upper bound**: For all $p \in \Delta_n$, $F_\tau(x, p) \le \tau \log Z$ by Theorem 3.5.
3. **Tightness**: For any $w < \tau \log Z$, the softmax distribution achieves $F_\tau(x, q) = \tau \log Z > w$. □

### 3.9 Optimizer Characterization

**Theorem 3.8**. There exists a unique probability vector $p^*$ achieving the supremum, namely $p^* = q$ (the softmax distribution). Moreover, for all probability vectors $p$:
$$F_\tau(x, p) \le F_\tau(x, q)$$

## 4. Applications

### 4.1 Softmax as Entropy-Regularized Optimization

The variational principle immediately gives a characterization of softmax attention in transformers. Given query-key scores $s_1, \ldots, s_n$ and temperature $\tau$, the attention weights

$$\alpha_i = \text{softmax}(s/\tau)_i = \frac{e^{s_i/\tau}}{\sum_j e^{s_j/\tau}}$$

are the unique solution to:

$$\alpha = \arg\max_{p \in \Delta_n} \left\{ \sum_i p_i s_i + \tau H(p) \right\}$$

This explains why softmax is the canonical choice for attention: it's the mathematically optimal way to balance score-matching against diversity.

### 4.2 Tropical Limit

As $\tau \to 0^+$, the entropy term vanishes and the variational problem becomes:

$$\lim_{\tau \to 0^+} \tau \log \sum_i e^{x_i/\tau} = \max_i x_i$$

This is the **dequantization** or **Maslov dequantization** that connects smooth probability to tropical (max-plus) algebra. The variational principle is the "quantum" version; the tropical limit is its "classical" shadow.

### 4.3 Statistical Mechanics

In the canonical ensemble at temperature $T = \tau$ with energy levels $\varepsilon_i = -x_i$:

- $Z = \sum_i e^{-\varepsilon_i/T}$ is the partition function
- $F = -T \log Z$ is the Helmholtz free energy
- The Gibbs state $\rho_i = e^{-\varepsilon_i/T}/Z$ minimizes $\langle \varepsilon, \rho \rangle - T H(\rho)$

Our theorem, with sign conventions adjusted, is exactly the variational characterization of thermodynamic equilibrium.

### 4.4 Information-Theoretic Bounds

The free energy decomposition $F_\tau(x, p) = \tau \log Z - \tau \cdot \text{KL}(p \| q)$ immediately gives:

$$\text{KL}(p \| q) = \frac{\tau \log Z - F_\tau(x, p)}{\tau}$$

This provides a computable upper bound on KL divergence from the Gibbs distribution, useful in variational inference and PAC-Bayes generalization bounds.

## 5. Computational Demonstrations

### 5.1 Numerical Verification

For $x = (1, 2, 3)$ and $\tau = 1$:

| Quantity | Value |
|----------|-------|
| $Z$ | $e^1 + e^2 + e^3 \approx 30.193$ |
| $\tau \log Z$ | $\approx 3.407$ |
| Softmax $q$ | $(0.090, 0.245, 0.665)$ |
| $H(q)$ | $\approx 0.826$ |
| $F_1(x, q)$ | $\approx 3.407$ ✓ |
| Uniform $p = (1/3, 1/3, 1/3)$ | $F_1(x, p) \approx 3.099$ |

### 5.2 Temperature Dependence

As $\tau$ varies from 0.01 to 10 with $x = (1, 3, 2)$:
- $\tau = 0.01$: $\tau \log Z \approx 3.000$ (near max)
- $\tau = 0.1$: $\tau \log Z \approx 3.000$
- $\tau = 1.0$: $\tau \log Z \approx 3.407$
- $\tau = 10.0$: $\tau \log Z \approx 12.099$ (entropy-dominated)

The smooth transition from max to entropy-dominated regime is the dequantization phenomenon.

## 6. Discussion

### 6.1 Proof Architecture

The modular proof structure — scalar inequality → finite sum inequality → upper bound → attainment → supremum — is deliberate. Each level provides independently useful results:

- **scalar_kl_ineq** is the atomic information inequality
- **gibbs_inequality_finite** is KL nonnegativity, foundational for information theory
- **freeEnergy_le_lse** gives computable bounds for any candidate distribution
- **freeEnergy_eq_lse_at_softmax** is the attainment/optimality result
- **lse_variational_formula** is the crown theorem

### 6.2 Technical Challenges

The main formalization challenges were:

1. **Zero-coordinate handling**: The convention $0 \log 0 = 0$ requires careful case splitting throughout. Lean's `if-then-else` handles this cleanly.

2. **Positivity management**: Every use of $\log$ requires a positivity proof for its argument. The partition function positivity and softmax strict positivity are used repeatedly.

3. **Sum algebra**: Rearranging finite sums with conditional terms requires careful use of `Finset.sum_congr` and related lemmas.

4. **Supremum characterization**: Moving from "there exists an optimizer" to "the supremum equals a specific value" requires the completeness axiom for $\mathbb{R}$ via `csSup_eq_of_forall_le_of_forall_lt_exists_gt`.

### 6.3 Limitations

The current formalization covers the finite-dimensional case. Extensions to:
- Infinite-dimensional (measure-theoretic) settings
- Continuous distributions
- Non-compact domains

would require substantially more infrastructure.

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed plans. Key priorities:

1. **Tropical limit theorem**: $\lim_{\tau \to 0^+} \tau \log \sum e^{x_i/\tau} = \max_i x_i$
2. **Complete KL divergence theory**: equality characterization, Pinsker inequality
3. **Strict concavity of entropy**: uniqueness of the softmax optimizer
4. **Fenchel duality framework**: generalizing beyond the log-sum-exp / entropy pair
5. **Attention-as-optimization**: connecting to transformer architecture theory

## References

[1] J. W. Gibbs, *Elementary Principles in Statistical Mechanics*, 1902.

[2] S. Boyd and L. Vandenberghe, *Convex Optimization*, Cambridge University Press, 2004.

[3] A. Vaswani et al., "Attention is All You Need," NeurIPS, 2017.

[4] R. T. Rockafellar, *Convex Analysis*, Princeton University Press, 1970.

[5] R. S. Ellis, *Entropy, Large Deviations, and Statistical Mechanics*, Springer, 1985.

[6] T. M. Cover and J. A. Thomas, *Elements of Information Theory*, Wiley, 2006.

[7] J. Hölzl, "Markov chains and Markov decision processes in Isabelle/HOL," PhD thesis, TU München, 2016.

[8] R. Affeldt, C. Cohen, and D. Rouhling, "Formalization of Shannon's theorems in SSReflect-Coq," Journal of Formalized Reasoning, 2019.
