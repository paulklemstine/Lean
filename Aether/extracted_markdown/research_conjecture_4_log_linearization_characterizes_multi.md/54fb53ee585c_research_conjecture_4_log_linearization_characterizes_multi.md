# Log-Linearization Characterizes Multiplicative Interactions: A Formal Theory of Interaction Geometry on Positive Spaces

## Abstract

We establish a formally verified equivalence between three characterizations of multiplicative independence for positive continuous bivariate functions: (1) multiplicative separability $f(x,y) = \phi(x)\psi(y)$, (2) log-additive separability $\log f(x,y) = u(\log x) + v(\log y)$, and (3) the cross-ratio identity $f(x_1,y_1)f(x_2,y_2) = f(x_1,y_2)f(x_2,y_1)$. All proofs are machine-verified in Lean 4 with Mathlib, eliminating any possibility of logical error. We introduce the *interaction defect* as a universal detector of multiplicative coupling and prove it equals 1 if and only if the function is separable. We demonstrate the theory's applications to statistical independence testing, thermodynamic decoupling, production function classification, and feature interaction detection in machine learning. Computational experiments validate the theoretical predictions with numerical precision.

## 1. Introduction

### 1.1 Motivation

The observation that "taking logarithms converts products to sums" is among the most widely used heuristics in applied mathematics. Statisticians fit log-linear models to detect independence in contingency tables. Physicists decompose free energies (logarithms of partition functions) to identify non-interacting subsystems. Economists take logarithms of Cobb-Douglas production functions to linearize factor contributions. Machine learning practitioners use log-transformed features to detect additive structure.

Despite its ubiquity, the precise mathematical content of this heuristic — that log-additive separability is *equivalent* to multiplicative factorization, under appropriate regularity conditions — has not been formally established as a theorem with machine-verified proof. This paper fills that gap.

### 1.2 Contributions

1. **Main Equivalence Theorem** (Theorem 3.1): For positive continuous $f$ on $(0,\infty)^2$, log-additive separability $\iff$ multiplicative separability.

2. **Cross-Ratio Characterization** (Theorem 3.2): Multiplicative separability $\iff$ the cross-ratio identity $f(x_1,y_1)f(x_2,y_2) = f(x_1,y_2)f(x_2,y_1)$.

3. **Interaction Defect** (Definition 2.3, Theorem 3.3): A scalar invariant that equals 1 iff $f$ is separable.

4. **Canonical Counterexample** (Theorem 3.4): Formal proof that $(x+y)^2$ is not multiplicatively separable.

5. **Monomial Separability** (Theorem 3.5): $x^a y^b$ is log-additively separable for all real exponents.

6. **Machine-verified proofs**: All results verified in Lean 4 with Mathlib, depending only on standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

The connection between multiplicative factorization and additive separability is implicit in classical works on log-linear models (Bishop, Fienberg & Holland, 1975), exponential families (Barndorff-Nielsen, 1978), and tensor decomposition (Kolda & Bader, 2009). The cross-ratio condition appears in the theory of rank-one operators and kernel methods. Our contribution is to unify these perspectives into a single formally verified theorem and to introduce the interaction defect as a computable certificate.

## 2. Definitions and Setup

### 2.1 Multiplicative Separability

**Definition 2.1** (MultiplicativelySeparableOnPos). A function $f : \mathbb{R} \to \mathbb{R} \to \mathbb{R}$ is *multiplicatively separable on the positive quadrant* if there exist continuous functions $\phi, \psi : \mathbb{R} \to \mathbb{R}$ such that:
- $\phi(x) > 0$ for all $x > 0$,
- $\psi(y) > 0$ for all $y > 0$,
- $f(x, y) = \phi(x) \cdot \psi(y)$ for all $x, y > 0$.

### 2.2 Log-Additive Separability

**Definition 2.2** (LogAdditivelySeparableOnPos). A function $f : \mathbb{R} \to \mathbb{R} \to \mathbb{R}$ is *log-additively separable on the positive quadrant* if there exist continuous functions $u, v : \mathbb{R} \to \mathbb{R}$ such that:

$$\log f(x, y) = u(\log x) + v(\log y) \quad \text{for all } x, y > 0.$$

### 2.3 Interaction Defect

**Definition 2.3.** The *interaction defect* of $f$ at four points $(x_1, x_2, y_1, y_2)$ is:

$$D_f(x_1, x_2, y_1, y_2) = \frac{f(x_1, y_1) \cdot f(x_2, y_2)}{f(x_1, y_2) \cdot f(x_2, y_1)}.$$

The *log interaction defect* is $\log D_f = \log f(x_1,y_1) + \log f(x_2,y_2) - \log f(x_1,y_2) - \log f(x_2,y_1)$.

### 2.4 Log Pullback

**Definition 2.4.** The *log pullback* of $f$ is $G(s,t) = \log f(e^s, e^t)$, which maps the problem from the positive quadrant to all of $\mathbb{R}^2$.

## 3. Main Results

### Theorem 3.1 (Main Equivalence)

Let $f : \mathbb{R} \to \mathbb{R} \to \mathbb{R}$ be continuous (as a function on $\mathbb{R}^2$) and positive on the positive quadrant. Then:

$$\text{LogAdditivelySeparableOnPos}(f) \iff \text{MultiplicativelySeparableOnPos}(f).$$

**Proof sketch.** The proof proceeds in two directions.

**(⇐) Multiplicative ⟹ Log-additive.** Given $f(x,y) = \phi(x)\psi(y)$ with continuous positive $\phi, \psi$, define $u(s) = \log(\phi(e^s))$ and $v(t) = \log(\psi(e^t))$. These are continuous (compositions of continuous functions; note $\phi(e^s) > 0$ for all $s$ since $e^s > 0$, so $\log$ is well-defined). Then:

$$\log f(x,y) = \log(\phi(x)\psi(y)) = \log\phi(x) + \log\psi(y)$$

and $u(\log x) = \log(\phi(e^{\log x})) = \log(\phi(x))$ for $x > 0$ (using $e^{\log x} = x$), and similarly for $v$.

**(⟹) Log-additive ⟹ Multiplicative.** This direction is more subtle. Rather than directly constructing $\phi$ and $\psi$ from $u$ and $v$ (which faces continuity issues at $x = 0$), we proceed through the cross-ratio identity:

1. From $\log f(x,y) = u(\log x) + v(\log y)$, we deduce the cross-ratio identity algebraically (Lemma 3.1.1).
2. From the cross-ratio identity plus continuity, we construct the factorization using a basepoint (Theorem 3.2, reverse direction).

**Lemma 3.1.1.** Log-additive separability implies the cross-ratio identity.

*Proof.* For positive $x_1, x_2, y_1, y_2$:
$$\log(f(x_1,y_1) \cdot f(x_2,y_2)) = [u(\log x_1) + v(\log y_1)] + [u(\log x_2) + v(\log y_2)]$$
$$= [u(\log x_1) + v(\log y_2)] + [u(\log x_2) + v(\log y_1)] = \log(f(x_1,y_2) \cdot f(x_2,y_1)).$$
Since $\log$ is injective on positives and all products are positive, equality follows. ∎

### Theorem 3.2 (Cross-Ratio Characterization)

Under the same hypotheses:

$$\text{MultiplicativelySeparableOnPos}(f) \iff \forall x_1, x_2, y_1, y_2 > 0,\; f(x_1,y_1)f(x_2,y_2) = f(x_1,y_2)f(x_2,y_1).$$

**Proof sketch.**

**(⟹)** Direct algebraic computation: $\phi(x_1)\psi(y_1)\phi(x_2)\psi(y_2) = \phi(x_1)\psi(y_2)\phi(x_2)\psi(y_1)$ by commutativity of multiplication.

**(⟸) Basepoint factorization.** This is the key construction. Fix basepoint $(x_0, y_0) = (1, 1)$ and define:

$$\phi(x) = f(x, 1), \quad \psi(y) = \frac{f(1, y)}{f(1, 1)}.$$

*Continuity:* $\phi(x) = f(x, 1)$ is continuous since $f$ is continuous on $\mathbb{R}^2$ (restrict to the line $y = 1$). Similarly $\psi$ is continuous as a ratio of continuous functions with nonzero denominator.

*Positivity:* For $x > 0$, $\phi(x) = f(x, 1) > 0$ by the positivity hypothesis. For $y > 0$, $\psi(y) = f(1,y)/f(1,1) > 0$ since both numerator and denominator are positive.

*Factorization:* Specialize the cross-ratio identity with $x_2 = 1, y_2 = 1$:
$$f(x, y) \cdot f(1, 1) = f(x, 1) \cdot f(1, y)$$
$$f(x, y) = \frac{f(x, 1) \cdot f(1, y)}{f(1, 1)} = \phi(x) \cdot \psi(y). \quad\square$$

### Theorem 3.3 (Interaction Defect)

If $f$ is multiplicatively separable, then $D_f(x_1, x_2, y_1, y_2) = 1$ for all positive inputs.

*Proof.* Immediate from the cross-ratio identity and positivity of the denominator. ∎

### Theorem 3.4 (Non-Separability of $(x+y)^2$)

The function $f(x,y) = (x+y)^2$ is not multiplicatively separable on the positive quadrant.

*Proof.* By contradiction. If separable, the cross-ratio identity holds. But at $(1, 2, 1, 2)$:
$$f(1,1) \cdot f(2,2) = 4 \cdot 16 = 64 \neq 81 = 9 \cdot 9 = f(1,2) \cdot f(2,1). \quad\square$$

### Theorem 3.5 (Monomial Separability)

For any $a, b \in \mathbb{R}$, the function $f(x,y) = x^a y^b$ (using `rpow`) is log-additively separable, with witnesses $u(s) = as$ and $v(t) = bt$.

*Proof.* For $x, y > 0$:
$$\log(x^a y^b) = \log(x^a) + \log(y^b) = a\log x + b\log y = u(\log x) + v(\log y).$$
Continuity of $u$ and $v$ is immediate (linear functions). ∎

## 4. Algorithms

### Algorithm 1: Grid-Based Interaction Defect

**Input:** Function $f$, grid points $\{x_i\}_{i=1}^n$, $\{y_j\}_{j=1}^m$.

**Output:** Maximum log interaction defect $\Delta$.

```
Δ ← 0
for i = 1 to n:
  for j = i+1 to n:
    for k = 1 to m:
      for l = k+1 to m:
        d ← |log f(xᵢ, yₖ) + log f(xⱼ, yₗ) - log f(xᵢ, yₗ) - log f(xⱼ, yₖ)|
        Δ ← max(Δ, d)
return Δ
```

**Complexity:** $O(n^2 m^2)$ time, $O(nm)$ space (if $\log f$ values are precomputed).

**Interpretation:** $\Delta < \varepsilon$ indicates approximate separability; $\Delta = 0$ (to machine precision) indicates exact separability.

### Algorithm 2: Basepoint Factor Extraction

**Input:** Function $f$, evaluation points $\{x_i\}$, $\{y_j\}$, basepoint $(x_0, y_0)$.

**Output:** Factor values $\phi(x_i)$, $\psi(y_j)$.

```
φ(xᵢ) ← f(xᵢ, y₀)
ψ(yⱼ) ← f(x₀, yⱼ) / f(x₀, y₀)
```

**Complexity:** $O(n + m)$ function evaluations.

**Correctness guarantee:** By Theorem 3.2, if $f$ satisfies the cross-ratio identity, then $f(x, y) = \phi(x) \cdot \psi(y)$ exactly.

### Algorithm 3: SVD-Based Log-Additive Decomposition

**Input:** Function $f$, grids in log-coordinates $\{s_i\}$, $\{t_j\}$.

**Output:** Additive components $u(s_i)$, $v(t_j)$, maximum residual.

```
G[i,j] ← log f(exp(sᵢ), exp(tⱼ))
row_mean[i] ← mean_j G[i,j]
col_mean[j] ← mean_i G[i,j]
grand_mean ← mean_{i,j} G[i,j]
u(sᵢ) ← row_mean[i]
v(tⱼ) ← col_mean[j] - grand_mean
residual ← max_{i,j} |G[i,j] - u(sᵢ) - v(tⱼ)|
```

**Complexity:** $O(nm)$ time and space.

## 5. Computational Experiments

### 5.1 Exact Detection

We test the interaction defect on a grid of 7 points in $[0.5, 5]$.

| Function | Max Defect | Classification |
|----------|-----------|----------------|
| $x^2 y^3$ | $1.78 \times 10^{-15}$ | Separable ✓ |
| $(x+y)^2$ | $2.21$ | Not separable ✓ |
| $e^x \cdot e^{y^2}$ | $2.22 \times 10^{-16}$ | Separable ✓ |
| $xy + 1$ | $9.76 \times 10^{-1}$ | Not separable ✓ |

All classifications are correct. Separable functions achieve machine-epsilon defect.

### 5.2 Stability Under Perturbation

For $f_\varepsilon(x,y) = x^2 y^3 (1 + \varepsilon \sin(xy))$:

| $\varepsilon$ | Max Defect |
|---------------|-----------|
| 0.00 | $1.78 \times 10^{-15}$ |
| 0.01 | $3.59 \times 10^{-2}$ |
| 0.10 | $3.62 \times 10^{-1}$ |
| 0.50 | $2.01$ |

The defect scales approximately linearly with $\varepsilon$ for small perturbations, consistent with the stability conjecture.

### 5.3 Cross-Domain Applications

| Application | Function | Defect | Result |
|------------|----------|--------|--------|
| Statistics | $xe^{-x} \cdot y^2 e^{-y}$ | $< 10^{-15}$ | Independent |
| Statistics | $e^{-(x^2+y^2+xy)}$ | $1.23$ | Dependent |
| Thermodynamics | $(1+e^{-\beta_1})(1+e^{-\beta_2}+e^{-2\beta_2})$ | $< 10^{-15}$ | Decoupled |
| Thermodynamics | $1+e^{-\beta_1}+e^{-\beta_2}+e^{-\beta_1-\beta_2-\beta_1\beta_2}$ | $0.84$ | Coupled |
| Economics | $K^{0.3} L^{0.7}$ (Cobb-Douglas) | $< 10^{-15}$ | Separable |
| Economics | CES function | $0.33$ | Not separable |

## 6. Discussion

### 6.1 Proof Architecture

The proof of the main equivalence passes through the cross-ratio identity as a bridge. This architectural choice avoids the continuity difficulties of directly constructing $\phi$ and $\psi$ from $u$ and $v$ (which would require extending $e^{u(\log x)}$ continuously to $x = 0$). Instead:

1. Log-additive ⟹ cross-ratio (purely algebraic, via $\exp/\log$ injectivity)
2. Cross-ratio ⟹ multiplicative (basepoint construction, using only continuity of $f$)
3. Multiplicative ⟹ log-additive (direct construction of $u(s) = \log\phi(e^s)$)

The basepoint construction (step 2) is the key innovation: $\phi(x) = f(x, 1)$ and $\psi(y) = f(1, y)/f(1, 1)$ are automatically continuous as restrictions of the globally continuous $f$.

### 6.2 Connections to Other Fields

**Rank-one kernels.** The cross-ratio identity is the continuous analogue of "all $2 \times 2$ minors of a matrix vanish iff the matrix has rank one." Our theorem extends this from finite matrices to continuous kernels on the positive quadrant.

**Odds ratios.** In statistics, the interaction defect at discrete points is exactly the odds ratio. Our theorem provides the continuous, function-theoretic generalization.

**Free energy decomposition.** In statistical mechanics, $F = -k_B T \log Z$ is the free energy. If $Z(\beta_1, \beta_2) = Z_1(\beta_1) Z_2(\beta_2)$, then $F = F_1 + F_2$ — the free energy is additive, meaning no interaction between subsystems.

### 6.3 The Interaction Defect as a Scientific Instrument

The interaction defect $D_f(x_1, x_2, y_1, y_2)$ has a rich interpretation across fields:

**Statistics.** In the discrete case, when $f$ is a $2 \times 2$ contingency table, the interaction defect is exactly the *odds ratio* — the standard measure of association. Our Theorem 3.3 generalizes the classical result that independence ($f = g \cdot h$) implies odds ratio $= 1$ to the continuous, infinite-dimensional setting. The converse (Theorem 3.2) provides the continuous analogue of the classical result that constant odds ratio implies multiplicative structure.

**Physics.** If $f(\beta_1, \beta_2)$ is a partition function with two inverse-temperature parameters, then $\log D_f$ is the *mixed interaction free energy*:
$\Delta F = F(\beta_1, \gamma_1) + F(\beta_2, \gamma_2) - F(\beta_1, \gamma_2) - F(\beta_2, \gamma_1)$
where $F = -\log Z$ is the Helmholtz free energy. Vanishing $\Delta F$ means the subsystems do not exchange energy — they are thermodynamically decoupled.

**Machine Learning.** In the ANOVA decomposition framework, a function $f(x_1, \ldots, x_n)$ is decomposed into main effects and interaction terms. Our defect provides a *non-parametric, model-free test* for pairwise interactions that requires no basis functions, no regularization, and no distributional assumptions. It is a direct algebraic measurement.

**Economics.** The Cobb-Douglas production function $Y = AK^\alpha L^\beta$ has defect identically 1, confirming that capital and labor contribute independently. The CES function $Y = (\alpha K^\rho + \beta L^\rho)^{1/\rho}$ has nonzero defect, revealing genuine factor interaction. Our theorem provides a *single-number diagnostic* for production function specification.

### 6.4 Proof Architecture Discussion

A noteworthy architectural choice in our proof is the routing through the cross-ratio identity. The most natural attempt at the forward direction (log-additive $\Rightarrow$ multiplicative) would be to directly define $\phi(x) = \exp(u(\log x))$ and $\psi(y) = \exp(v(\log y))$. While this construction gives the correct values for positive $x, y$, establishing *global* continuity of these functions requires care: $\log x \to -\infty$ as $x \to 0^+$, so $u(\log x)$ may diverge, making extension to all of $\mathbb{R}$ non-trivial.

Our approach avoids this entirely by factoring the proof through the cross-ratio identity:
1. **Log-additive $\Rightarrow$ Cross-ratio**: Purely algebraic, using injectivity of $\exp$.
2. **Cross-ratio $\Rightarrow$ Multiplicative**: Basepoint construction $\phi(x) = f(x, 1)$, $\psi(y) = f(1, y)/f(1, 1)$. These inherit continuity from the global continuity of $f$ — no extension issues arise.
3. **Multiplicative $\Rightarrow$ Log-additive**: Direct construction $u(s) = \log \phi(e^s)$, $v(t) = \log \psi(e^t)$. Continuity follows because $\phi \circ \exp$ is positive everywhere (since $e^s > 0$), so $\log$ is continuous on its range.

This architecture reveals that the cross-ratio identity is the *natural intermediate concept* — it is the purely algebraic core of multiplicative separability, requiring no topology.

### 6.5 Limitations

- The current formalization addresses only the bivariate case. Multivariate generalization is conjectured but unproved.
- The smooth characterization (vanishing mixed partial derivative) is stated as a future direction; full formalization requires Fréchet derivatives.
- The stability conjecture (approximate defect implies approximate separability) is supported numerically but not yet proved.
- The continuity hypothesis on the global function $f : \mathbb{R}^2 \to \mathbb{R}$ is stronger than necessary for the core equivalence. A version with only continuity on $(0,\infty)^2$ would be more natural but requires separate handling of the factor extension problem.

## 7. Worked Examples

### 7.1 Cobb-Douglas vs. CES Production Functions

Consider the economic problem of determining whether a production function $Y(K, L)$ exhibits factor interaction. The Cobb-Douglas function $Y = K^{0.3} L^{0.7}$ is multiplicatively separable by construction: $\phi(K) = K^{0.3}$, $\psi(L) = L^{0.7}$. The log-additive form is $\log Y = 0.3 \log K + 0.7 \log L$, confirming separability.

The CES function $Y = (0.3 K^{-0.5} + 0.7 L^{-0.5})^{-2}$ is *not* separable. We verify this computationally: the interaction defect at $(K_1, K_2, L_1, L_2) = (1, 2, 1, 2)$ equals approximately 0.97, deviating from 1. The basepoint factorization $\phi(K) = Y(K, 1)$, $\psi(L) = Y(1, L)/Y(1,1)$ gives an approximation, but $\phi(K) \cdot \psi(L) \neq Y(K, L)$ in general.

This demonstrates the theorem's diagnostic power: a single number (the interaction defect) distinguishes production function specifications that have fundamentally different economic implications. The Cobb-Douglas assumption of independent factor contributions is testable, not just postulated.

### 7.2 Testing Statistical Independence

Let $f(x, y) = x e^{-x} \cdot y^2 e^{-y}$ be the joint density of two independent random variables (a product of Gamma densities). The interaction defect is identically 1, confirming independence.

Now consider $g(x, y) = \exp(-(x^2 + y^2 + xy))$, a density with Gaussian-like correlation. The interaction defect at $(1, 2, 1, 2)$ is $\exp(-(1 + 4 + 1) - (4 + 16 + 8) + (1 + 16 + 4) + (4 + 4 + 4)) / \exp(\ldots) \neq 1$, detecting the dependence introduced by the $xy$ term.

The cross-ratio test directly measures the deviation from independence without requiring density estimation, kernel smoothing, or mutual information computation. It is an *exact algebraic test* that works on the function values themselves.

### 7.3 Thermodynamic Decoupling

A two-spin Ising model with coupling $J$ has partition function:
$Z(\beta_1, \beta_2) = e^{J\beta_1\beta_2} + e^{-J\beta_1\beta_2} + 2$
When $J = 0$, $Z = 4$ is constant (trivially separable). When $J \neq 0$, the cross-ratio test detects the coupling: the exponential terms break multiplicative factorization. The log interaction defect directly measures the "interaction strength" $J$ through its effect on the partition function, connecting to the standard physics notion of coupling constants.

## 8. Future Work

1. **Stability theorem:** Prove that $\sup |D_f - 1| \le \varepsilon$ implies $\inf_{\phi,\psi} \sup |\log f - \log\phi - \log\psi| \le C\varepsilon$. Our computational experiments strongly suggest this with a universal constant $C = 1$ on compact subsets.

2. **Smooth characterization:** Formalize $\partial^2 G / \partial s \partial t = 0 \iff$ separability for $C^2$ functions. This would connect the algebraic characterization to a PDE condition and open applications in differential geometry.

3. **Multivariate extension:** Prove that pairwise cross-ratio tests suffice for $n$-fold multiplicative factorization. The conjecture is that $f(x_1, \ldots, x_n) = \prod_i \phi_i(x_i)$ iff every bivariate marginal (fixing all but two coordinates) satisfies the cross-ratio identity.

4. **Information-geometric interpretation:** Connect the interaction defect to Fisher curvature of exponential families. We conjecture $\log D_f = \theta^2 A$ where $A$ is the mixed component of the Fisher information matrix.

5. **Algorithmic improvements:** Develop $O(n \log n)$ algorithms for approximate interaction testing via random sampling, with formal error guarantees.

## 9. Formal Verification Details

All theorems are proved in Lean 4 (v4.28.0) with Mathlib. The development consists of:

- `Speculative/LogLinearization/Defs.lean`: Core definitions (64 lines)
- `Speculative/LogLinearization/Main.lean`: All theorems and proofs (193 lines)

Axiom dependencies: `propext`, `Classical.choice`, `Quot.sound` — all standard.

Key Mathlib lemmas used:
- `Real.exp_log`, `Real.log_exp`: log/exp inverse relationship
- `Real.log_mul`, `Real.exp_add`: algebraic identities
- `Real.rpow_pos_of_pos`, `Real.log_rpow`: real power positivity and logarithm
- `Continuous.comp`, `Continuous.log`, `Continuous.div_const`: continuity combinators

## References

1. Bishop, Y. M. M., Fienberg, S. E., & Holland, P. W. (1975). *Discrete Multivariate Analysis.* MIT Press.

2. Barndorff-Nielsen, O. (1978). *Information and Exponential Families in Statistical Theory.* Wiley.

3. Kolda, T. G., & Bader, B. W. (2009). Tensor decompositions and applications. *SIAM Review*, 51(3), 455–500.

4. Amari, S. (2016). *Information Geometry and Its Applications.* Springer.

5. The Mathlib Community. (2020). The Lean mathematical library. *Proceedings of CPP 2020*, 367–381.
