# The Exact Two-Point Correlation Function of the Open One-Dimensional Ising Chain: Closed Form, Exponential Decay, and the Spectral-Gap Correlation Length

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Statistical Mechanics / Mathematical Physics

---

## Abstract

We give a complete, self-contained derivation of the exact endpoint two-point spin correlation function of the open (free-boundary) one-dimensional Ising model, working directly from the finite sum over spin configurations rather than from any limiting or thermodynamic-limit argument. For a chain of $n$ nearest-neighbor bonds with coupling $J$ at inverse temperature $\beta$, we prove the closed form for the *unnormalized* signed configuration sum,
$$\mathrm{corrNum}(\beta,J,n) = 2\,\big(2\sinh(\beta J)\big)^{n},$$
and dividing by the partition function $Z = 2\,(2\cosh(\beta J))^n$ we obtain the headline identity
$$\langle\sigma_0\,\sigma_n\rangle = \big(\tanh(\beta J)\big)^{n}.$$
For positive temperature and coupling ($\beta, J > 0$) we recast this as a pure exponential, $\langle\sigma_0\sigma_n\rangle = e^{-g n}$, where the **spectral gap** $g = \log\coth(\beta J) = \log\cosh(\beta J) - \log\sinh(\beta J)$ is exactly the logarithm of the ratio of transfer-matrix eigenvalues; the reciprocal $\xi = 1/g$ is the correlation length. We prove $g>0$ for all positive temperatures and deduce $\langle\sigma_0\sigma_n\rangle \to 0$ as $n\to\infty$, i.e. the absence of long-range order in one dimension at every positive temperature. The argument rests on a transfer recursion obtained by peeling site $0$, driven by two single-bond identities: an **even** sum giving $2\cosh$ (governing the partition function) and an **odd**, signed sum giving $2\sinh$ (governing the correlation). We contrast these results with the two-dimensional Onsager critical temperature $T_c = 2/\ln(1+\sqrt2)$ and the Peierls low-temperature ordering threshold. All principal results are formalized and machine-checked.

**Keywords:** Ising model, two-point correlation function, correlation length, spectral gap, transfer matrix, hyperbolic tangent, exponential decay, long-range order, statistical mechanics.

---

## 1. Introduction

The Ising model is the canonical microscopic model of cooperative phenomena in statistical mechanics. Introduced by Lenz and solved in one dimension by Ising (1924), it consists of two-state spins on a lattice with a nearest-neighbor interaction favoring alignment. Its one-dimensional version is exactly solvable and famously exhibits **no** spontaneous magnetization at any positive temperature; its two-dimensional version, solved exactly by Onsager (1944), exhibits a genuine phase transition at the critical temperature
$$T_c = \frac{2}{\ln\left(1+\sqrt 2\right)}, \qquad \text{equivalently} \qquad \sinh(2\beta_c J) = 1, \quad e^{2\beta_c J} = 1 + \sqrt 2.$$

The decisive observable distinguishing an ordered from a disordered phase is the **two-point correlation function** $\langle\sigma_a\sigma_b\rangle$, which measures statistical dependence between distant spins. Long-range order is the statement that $\langle\sigma_0\sigma_n\rangle$ does not vanish as $n\to\infty$.

This paper presents a rigorous, elementary, and fully formalized derivation of the exact endpoint correlation function of the **open** one-dimensional chain, obtained directly from the configuration sum. We avoid all generating-function shortcuts; the only inputs are two single-bond summation identities and induction on chain length. The result, $\langle\sigma_0\sigma_n\rangle = (\tanh\beta J)^n$, is then shown to encode, by pure algebra, every qualitative feature of the 1D model: exponential decay, the identification of the correlation length with the inverse transfer-matrix spectral gap, and the absence of long-range order. We close by situating these facts against the 2D Onsager and Peierls results, with which our development shares a project context.

### 1.1 Contributions

1. A self-contained, induction-based proof of the closed form $\mathrm{corrNum}(\beta,J,n) = 2(2\sinh\beta J)^n$ for the unnormalized signed configuration sum (Theorem `corrNum_closed`).
2. The exact correlation function $\langle\sigma_0\sigma_n\rangle = (\tanh\beta J)^n$ (Theorem `corr_eq_tanh_pow`).
3. The exponential-decay representation $\langle\sigma_0\sigma_n\rangle = e^{-g n}$ with $g$ the transfer-matrix spectral gap (Theorem `corr_eq_exp_neg_gap`), together with strict positivity of the gap at all positive temperatures (Theorem `spectralGap_pos`).
4. The asymptotic vanishing of correlations, $\langle\sigma_0\sigma_n\rangle\to 0$ (Theorem `corr_tendsto_zero`), establishing the absence of 1D long-range order.
5. An explicit identification of *why* the partition function is governed by the even (cosh) single-bond sum while the correlation is governed by the odd (sinh) sum, and how their ratio reproduces the eigenvalue ratio $\lambda_-/\lambda_+ = \tanh\beta J$ of the transfer matrix.

---

## 2. Setup and Definitions

### 2.1 Configurations and spins

We model a chain of $n$ bonds, hence $n+1$ sites indexed $0,1,\dots,n$. A **configuration** is a function $s\colon \{0,\dots,n\} \to \{\mathrm{true},\mathrm{false}\}$ assigning a Boolean to each site. The **spin value** of a Boolean is
$$\mathrm{sp}(b) = \begin{cases} +1 & b = \mathrm{true},\\ -1 & b = \mathrm{false}.\end{cases}$$
A basic identity we use repeatedly is that a spin squares to one:
$$\mathrm{sp}(b)^2 = 1 \qquad \text{for all } b. \tag{$\star$}$$
(In the formalization this is `sp_mul_self`.)

### 2.2 Boltzmann weight, partition function, correlation

For coupling $J\in\mathbb R$ and inverse temperature $\beta\in\mathbb R$, the **Boltzmann weight** of a configuration $s$ on a chain of $n$ bonds is the product of the nearest-neighbor edge factors:
$$\mathrm{weight}(\beta,J,n,s) = \prod_{i=0}^{n-1} \exp\!\big(\beta J\,\mathrm{sp}(s_i)\,\mathrm{sp}(s_{i+1})\big).$$

The **free-boundary partition function** is the sum of weights over all $2^{n+1}$ configurations:
$$Z(\beta,J,n) = \sum_{s} \mathrm{weight}(\beta,J,n,s).$$

The **unnormalized endpoint correlation** (the signed configuration sum) is
$$\mathrm{corrNum}(\beta,J,n) = \sum_{s} \mathrm{sp}(s_0)\,\mathrm{sp}(s_n)\,\mathrm{weight}(\beta,J,n,s),$$
and the **normalized two-point correlation** is the ratio
$$\langle\sigma_0\sigma_n\rangle = \mathrm{corr}(\beta,J,n) = \frac{\mathrm{corrNum}(\beta,J,n)}{Z(\beta,J,n)}.$$

### 2.3 Spectral gap and correlation length

We define the **spectral gap**
$$g(\beta,J) = \log\cosh(\beta J) - \log\sinh(\beta J) = \log\coth(\beta J),$$
and the **correlation length** $\xi(\beta,J) = 1/g(\beta,J)$. As we shall see, $g$ is exactly $\log(\lambda_+/\lambda_-)$ where $\lambda_\pm = 2\cosh(\beta J),\,2\sinh(\beta J)$ are the transfer-matrix eigenvalues.

---

## 3. Single-Bond Identities

The entire derivation pivots on two elementary identities for summing a single spin against a fixed neighbor $y$. Their distinction — one even, one odd — is the conceptual core of the paper.

**Lemma 3.1 (Even single-bond sum, `sum_bool_exp`).** For any $c\in\mathbb R$ and any neighbor spin $y$,
$$\sum_{b\in\{\pm1\}} \exp\!\big(c\,\mathrm{sp}(b)\,\mathrm{sp}(y)\big) = 2\cosh(c).$$

*Proof sketch.* Expanding over the two values $b=\pm1$ gives $\exp(c\,\mathrm{sp}(y)) + \exp(-c\,\mathrm{sp}(y))$. Using $\mathrm{sp}(y)=\pm1$ and $(\star)$, both cases collapse to $e^{c}+e^{-c} = 2\cosh c$ by the parity (evenness) of $\cosh$. The neighbor $y$ disappears entirely. $\square$

**Lemma 3.2 (Odd single-bond sum, `sum_bool_sp_exp`).** For any $c\in\mathbb R$ and any neighbor spin $y$,
$$\sum_{b\in\{\pm1\}} \mathrm{sp}(b)\,\exp\!\big(c\,\mathrm{sp}(b)\,\mathrm{sp}(y)\big) = 2\,\mathrm{sp}(y)\,\sinh(c).$$

*Proof sketch.* Expanding gives $\exp(c\,\mathrm{sp}(y)) - \exp(-c\,\mathrm{sp}(y))$. By the oddness of $\sinh$ and $\mathrm{sp}(y)=\pm1$, this equals $2\,\mathrm{sp}(y)\sinh(c)$. Crucially the result *retains* a factor $\mathrm{sp}(y)$: the sign of the summed spin is transmitted to its neighbor. $\square$

The contrast is the whole story. The even sum forgets the neighbor and yields $\cosh$; it will build the partition function. The odd sum remembers the neighbor and yields $\sinh$; it will build the correlation, propagating the endpoint sign bond by bond.

---

## 4. The Partition Function (re-derived self-contained)

### 4.1 Peeling a spin

**Lemma 4.1 (Weight factorization, `weight_cons`).** Prepending a spin $b$ to a configuration $t$ on $n$ bonds gives a configuration on $n+1$ bonds whose weight factorizes:
$$\mathrm{weight}(\beta,J,n+1,\ b\!:\!t) = \exp\!\big(\beta J\,\mathrm{sp}(b)\,\mathrm{sp}(t_0)\big)\cdot \mathrm{weight}(\beta,J,n,t).$$

*Proof sketch.* The new chain has one extra bond, between the prepended spin $b$ and the old site $0$; all other bonds are unchanged. Pull the first factor out of the product. $\square$

### 4.2 Transfer recursion and closed form

**Theorem 4.2 (Partition recursion, `Zfree_succ`).**
$$Z(\beta,J,n+1) = \big(2\cosh(\beta J)\big)\,Z(\beta,J,n).$$

*Proof sketch.* Re-index the sum over configurations on $n+1$ bonds as a sum over $(b,t)$, with $b$ the prepended spin and $t$ the rest. Use Lemma 4.1 and exchange the order of summation. The inner sum over $b$ is exactly the even single-bond sum (Lemma 3.1) with $c = \beta J$ and $y = t_0$, contributing $2\cosh(\beta J)$ independent of $t$; factoring it out leaves $Z(\beta,J,n)$. $\square$

**Theorem 4.3 (Partition closed form, `Zfree_closed`).** For all $n\ge 0$,
$$Z(\beta,J,n) = 2\,\big(2\cosh(\beta J)\big)^{n}.$$

*Proof sketch.* Induction. Base case $n=0$: a single site, no bonds, two configurations, each weight $1$, so $Z = 2$. Inductive step: apply Theorem 4.2 and the hypothesis. $\square$

**Theorem 4.4 (Positivity, `Zfree_pos`).** $Z(\beta,J,n) > 0$ for all $n$, since $\cosh > 0$ everywhere. This guarantees the normalized correlation is well defined.

---

## 5. The Two-Point Correlation Function

### 5.1 Signed transfer recursion

**Theorem 5.1 (Correlation recursion, `corrNum_succ`).**
$$\mathrm{corrNum}(\beta,J,n+1) = \big(2\sinh(\beta J)\big)\,\mathrm{corrNum}(\beta,J,n).$$

*Proof sketch.* As in Theorem 4.2, re-index the configuration sum on $n+1$ bonds by the prepended spin $b$ and the remainder $t$, and use the weight factorization (Lemma 4.1). The observable contributes $\mathrm{sp}(b)\cdot\mathrm{sp}(s_{n+1})$; the endpoint factor $\mathrm{sp}(s_{n+1}) = \mathrm{sp}(t_n)$ is unaffected by the prepend, while $\mathrm{sp}(b)$ multiplies the Boltzmann factor. The inner sum over $b$ is therefore the *odd* single-bond sum (Lemma 3.2) with $c = \beta J$ and $y = t_0$, contributing $2\,\mathrm{sp}(t_0)\sinh(\beta J)$. The surviving $\mathrm{sp}(t_0)$ reconstitutes precisely the observable $\mathrm{sp}(t_0)\,\mathrm{sp}(t_n)$ of the shorter chain, leaving $2\sinh(\beta J)\cdot\mathrm{corrNum}(\beta,J,n)$. $\square$

The contrast with Theorem 4.2 is the technical heart: $Z$ recurses with the *even* factor $2\cosh$, while $\mathrm{corrNum}$ recurses with the *odd* factor $2\sinh$. The endpoint sign is carried down the chain by the residual $\mathrm{sp}(t_0)$ that the odd identity refuses to discard.

### 5.2 Closed form and the headline identity

**Theorem 5.2 (Unnormalized closed form, `corrNum_closed`).** For all $n\ge 0$,
$$\mathrm{corrNum}(\beta,J,n) = 2\,\big(2\sinh(\beta J)\big)^{n}.$$

*Proof sketch.* Induction on $n$. Base case $n=0$: a single site, observable $\mathrm{sp}(s_0)^2 = 1$ by $(\star)$, summed over two configurations gives $2$. Inductive step: Theorem 5.1. $\square$

**Theorem 5.3 (Exact correlation, `corr_eq_tanh_pow`).** For all $n\ge 0$,
$$\langle\sigma_0\sigma_n\rangle = \big(\tanh(\beta J)\big)^{n}.$$

*Proof sketch.* Divide Theorem 5.2 by Theorem 4.3. The factors of $2$ cancel, and
$$\frac{2(2\sinh\beta J)^n}{2(2\cosh\beta J)^n} = \left(\frac{\sinh\beta J}{\cosh\beta J}\right)^n = (\tanh\beta J)^n.$$
Positivity of $Z$ (Theorem 4.4) makes the division legitimate. $\square$

This is the central result. It is exact for every $\beta, J, n$, with no thermodynamic-limit or approximation.

---

## 6. Exponential Decay, Spectral Gap, and Absence of Order

We now restrict to the physical regime $\beta, J > 0$.

**Lemma 6.1 ($\tanh\beta J \in (0,1)$).** For $\beta, J > 0$ we have $0 < \tanh(\beta J) < 1$, since $\beta J > 0$, $\sinh(\beta J) > 0$, and $\sinh < \cosh$ on the positive axis.

**Theorem 6.2 (Exponential decay form, `corr_eq_exp_neg_gap`).** For $\beta, J > 0$,
$$\langle\sigma_0\sigma_n\rangle = \exp\!\big(-g(\beta,J)\,n\big), \qquad g(\beta,J) = \log\cosh(\beta J) - \log\sinh(\beta J) = \log\coth(\beta J).$$

*Proof sketch.* By Theorem 5.3, $\langle\sigma_0\sigma_n\rangle = (\tanh\beta J)^n$. Write $\tanh\beta J = e^{\log\tanh\beta J}$ (valid since $\tanh\beta J>0$ by Lemma 6.1), so the $n$-th power equals $e^{n\log\tanh\beta J}$. Finally $\log\tanh\beta J = \log\sinh\beta J - \log\cosh\beta J = -g(\beta,J)$. $\square$

**Theorem 6.3 (Positive gap, `spectralGap_pos`).** For $\beta, J > 0$, $g(\beta,J) > 0$.

*Proof sketch.* Since $0 < \sinh(\beta J) < \cosh(\beta J)$, we have $\coth(\beta J) > 1$, so $g = \log\coth(\beta J) > 0$. Equivalently, $\tanh\beta J < 1$ from Lemma 6.1. $\square$

The reciprocal $\xi = 1/g$ is the **correlation length**: correlations decay as $e^{-n/\xi}$. The name "spectral gap" reflects that $g = \log\big((2\cosh\beta J)/(2\sinh\beta J)\big) = \log(\lambda_+/\lambda_-)$, the logarithm of the ratio of transfer-matrix eigenvalues.

**Theorem 6.4 (No long-range order, `corr_tendsto_zero`).** For $\beta, J > 0$,
$$\lim_{n\to\infty} \langle\sigma_0\sigma_n\rangle = 0.$$

*Proof sketch.* By Theorem 6.2 the correlation is $e^{-g n}$ with $g > 0$ (Theorem 6.3), and $e^{-g n}\to 0$. Equivalently, $|\tanh\beta J| < 1$ forces $(\tanh\beta J)^n \to 0$. $\square$

Thus the open 1D Ising chain has no spontaneous long-range order at any positive temperature: distant spins decorrelate exponentially. As $\beta\to\infty$ (i.e. $T\to 0$), $\tanh\beta J\to 1$, $g\to 0$, and $\xi\to\infty$; order emerges only in the strict zero-temperature limit.

---

## 7. The Transfer Matrix Viewpoint

The recursions of Sections 4–5 are the matrix-element shadows of a single $2\times2$ operator. Writing the transfer matrix in the spin basis,
$$T = \begin{pmatrix} e^{\beta J} & e^{-\beta J} \\ e^{-\beta J} & e^{\beta J} \end{pmatrix},$$
its eigenvalues are $\lambda_+ = e^{\beta J} + e^{-\beta J} = 2\cosh(\beta J)$ (eigenvector $(1,1)$, the symmetric/even mode) and $\lambda_- = e^{\beta J} - e^{-\beta J} = 2\sinh(\beta J)$ (eigenvector $(1,-1)$, the antisymmetric/odd mode). The dictionary is exact:

| Object | Combinatorial origin | Spectral meaning |
|---|---|---|
| $Z = 2(2\cosh\beta J)^n$ | even single-bond sum | dominated by $\lambda_+^n$ |
| $\mathrm{corrNum} = 2(2\sinh\beta J)^n$ | odd single-bond sum | $\propto \lambda_-^n$ |
| $\langle\sigma_0\sigma_n\rangle = (\tanh\beta J)^n$ | ratio of the two | $(\lambda_-/\lambda_+)^n$ |
| $g = \log\coth\beta J$ | $-\log\tanh\beta J$ | $\log(\lambda_+/\lambda_-)$ |

This makes precise the general principle that the partition function is governed by the *largest* eigenvalue, while correlations are governed by the *ratio* of eigenvalues, and the correlation length is the inverse spectral gap. The 1D Ising chain is the cleanest possible illustration: both eigenvalues are elementary hyperbolic functions, and the entire physics is visible.

---

## 8. Algorithms

### 8.1 Brute-force correlation by configuration enumeration

To validate the closed forms one can compute $Z$ and $\mathrm{corrNum}$ directly by enumerating all $2^{n+1}$ configurations.

```
Algorithm BruteForceCorrelation(beta, J, n):
  Z       <- 0
  corrNum <- 0
  for each s in {+1,-1}^(n+1):          # all configurations
      w <- 1
      for i in 0 .. n-1:
          w <- w * exp(beta*J*s[i]*s[i+1])
      Z       <- Z + w
      corrNum <- corrNum + s[0]*s[n]*w
  return corrNum / Z
```
Complexity: $O(n\,2^{n})$ time, $O(1)$ extra space. This is exponential and used only for small-$n$ validation against the closed form $(\tanh\beta J)^n$.

### 8.2 Closed-form evaluation

```
Algorithm ClosedFormCorrelation(beta, J, n):
  return tanh(beta*J)^n
```
Complexity: $O(\log n)$ via fast exponentiation (or $O(1)$ with a `pow`). This is the exact value, identical to the brute-force result up to floating point.

### 8.3 Spectral-gap / correlation length

```
Algorithm SpectralGap(beta, J):
  return log(cosh(beta*J)) - log(sinh(beta*J))     # = log(coth(beta*J))
Algorithm CorrelationLength(beta, J):
  return 1 / SpectralGap(beta, J)
```
Both $O(1)$. The correlation then equals $\exp(-\mathrm{SpectralGap}\cdot n)$.

---

## 9. Applications and Discussion

The exact 1D correlation function is a workhorse template across the sciences. The transfer-matrix structure — partition function from the dominant eigenvalue, correlations from the eigenvalue ratio, correlation length from the inverse spectral gap — recurs in:

- **Magnetism and critical phenomena**, where $\xi$ governs scattering line-widths and the approach to criticality.
- **Polymer and biomolecular physics**, where helix–coil transitions are 1D Ising-like.
- **Machine learning**, where Boltzmann machines and Hopfield networks are Ising systems and "stored memories" are ordered configurations.
- **Quantum field theory and lattice gauge theory**, where the transfer matrix is the time-evolution operator and the spectral gap is a particle mass.

The headline qualitative lesson — that one dimension forbids order at positive temperature because a single domain wall costs only finite energy while entropy grows with system size — generalizes to the Mermin–Wagner-type intuition that low dimension suppresses order.

**Comparison with two dimensions.** The same nearest-neighbor rule in two dimensions yields, by Onsager's exact solution, a genuine phase transition at $T_c = 2/\ln(1+\sqrt2)$, equivalently the self-dual condition $\sinh(2\beta_c J) = 1$ with $e^{2\beta_c J} = 1+\sqrt2$ and $\beta_c = \tfrac12\log(1+\sqrt2)$. A complementary rigorous lower bound on the ordering temperature comes from the Peierls contour argument, which yields an explicit threshold $\beta_0 = \tfrac12\log 12$; since $1+\sqrt2 < 12$ one has $\beta_c < \beta_0$, consistent with both windows describing the same ordered phase. In one dimension neither phenomenon occurs: there is no contour argument because a single wall is too cheap, and $\xi$ diverges only at $T=0$.

---

## 10. Conclusion

We have derived, from the bare configuration sum and a two-line induction, the exact endpoint two-point correlation function of the open one-dimensional Ising chain, $\langle\sigma_0\sigma_n\rangle = (\tanh\beta J)^n$, together with its exponential-decay representation $e^{-gn}$, the identification of $g = \log\coth(\beta J)$ as the transfer-matrix spectral gap, the strict positivity of the gap at all positive temperatures, and the consequent absence of long-range order. The decisive structural insight is the dichotomy between the *even* single-bond sum ($2\cosh$, building $Z$) and the *odd* single-bond sum ($2\sinh$, building the correlation): their per-bond ratio is exactly $\tanh\beta J = \lambda_-/\lambda_+$, the ratio of transfer-matrix eigenvalues. All principal results are formalized and machine-checked.

---

## 11. Future Directions

- **Combinatorial = spectral partition function (periodic).** For the cyclic chain, prove $Z_{\mathrm{ring}}(\beta,J,n) = (2\cosh\beta J)^n + (2\sinh\beta J)^n$ for $n\ge 1$, matching the transfer-matrix trace.
- **General two-point function.** Generalize the endpoint result to arbitrary sites $a\le b$: $\langle\sigma_a\sigma_b\rangle = (\tanh\beta J)^{b-a}$, establishing bulk translation invariance and equality of connected and full correlations at zero field.
- **Correlation length asymptotics.** Prove $\xi(\beta,J)\sim \tfrac12 e^{2\beta J}$ as $\beta\to\infty$, i.e. $g(\beta,J) = 2e^{-2\beta J}(1+o(1))$.
- **Field-dependent transfer matrix.** With external field $h$, study the largest eigenvalue $\lambda_+ = e^{\beta J}\cosh(\beta h) + \sqrt{e^{2\beta J}\sinh^2(\beta h) + e^{-2\beta J}}$, prove joint real-analyticity of $\log\lambda_+$ in $(\beta,h)$, and $m(\beta,0)=0$.
- **Peierls meets Onsager (2D bridge).** Prove $\beta_c < \tfrac12\log 12$ with $\beta_c = \tfrac12\log(1+\sqrt2)$, i.e. $1+\sqrt2 < 12$, quantitatively relating the Peierls threshold to the Onsager critical point.

---

## References (context)

This development is companion to formalizations of the 2D Onsager critical temperature ($T_c = 2/\ln(1+\sqrt2)$), the transfer-matrix method, and the Peierls argument within the same project. The 1D results above are self-contained and require none of those externally.
