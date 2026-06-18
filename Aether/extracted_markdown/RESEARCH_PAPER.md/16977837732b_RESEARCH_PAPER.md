# EML Fixed-Point Theorem: Contraction Mapping Analysis of Exp-Log Iterations

## Abstract

We establish a complete contraction mapping theory for the EML (Exponential-Multiplicative-Logarithmic) operator $f(x) = e^a \cdot \log(bx + c)$. We prove that this operator is a strict contraction on intervals $[L, U]$ whenever the explicit parameter condition $e^a \cdot b < bL + c$ holds, with contraction constant $\rho = e^a \cdot b / (bL + c)$. From this, we derive: (1) uniqueness of fixed points in the invariant interval; (2) geometric convergence of iterates at rate $O(\rho^n)$; (3) a comparison principle showing that fixed points increase monotonically with the exponential parameter $a$; and (4) multiplicative composition of contraction rates for cascaded EML operators. All results are formally verified in Lean 4 with the Mathlib library, providing machine-checked mathematical certainty. The theory connects abstract contraction mapping principles from metric space topology to the concrete analytic structure of exponential-logarithmic functions, with applications to certified iterative algorithms and stable neural architectures.

**Keywords:** contraction mapping, fixed-point theorem, exp-log operator, convergence rate, formal verification

## 1. Introduction

The study of iterative fixed-point schemes is a cornerstone of computational mathematics, with applications spanning numerical analysis, optimization, and dynamical systems. The Banach fixed-point theorem provides the foundational framework: if a function $f: X \to X$ on a complete metric space satisfies $d(f(x), f(y)) \leq \rho \cdot d(x, y)$ for some $\rho < 1$, then $f$ has a unique fixed point, and iterates of any starting point converge to it geometrically.

While the abstract theory is well-established, applying it to specific function classes requires deriving explicit contraction conditions from the function's analytic properties. In this paper, we carry out this program for the **EML operator**:

$$f(x) = e^a \cdot \log(bx + c)$$

where $a, b, c \in \mathbb{R}$ with $b > 0$ and $bx + c > 0$. These operators arise in:

- **Signal processing**: Log-domain computations with exponential scaling
- **Neural networks**: Activation functions combining exp and log for gradient stability
- **Iterative algorithms**: Fixed-point iterations for transcendental equations
- **Information theory**: Entropy-related computations with log-exp structure

### 1.1 Main Contributions

Our contributions are:

1. **Explicit contraction constants** (Theorem 3.2): The Lipschitz constant on $[L, U]$ is exactly $\rho = e^a \cdot b / (bL + c)$, derived from the mean value inequality and the monotone decay of the EML derivative.

2. **Fixed-point uniqueness** (Theorem 3.3): Under the contraction condition $e^a \cdot b < bL + c$, the EML operator has at most one fixed point in $[L, U]$.

3. **Geometric convergence** (Theorem 4.1): Iterates satisfy $\|x_n - x^*\| \leq \rho^n \cdot \|x_0 - x^*\|$ with convergence to zero (Theorem 4.2).

4. **Comparison principle** (Theorem 5.1): Fixed points are monotone increasing in the parameter $a$.

5. **Composition law** (Theorem 5.2): Cascaded EML operators compose their contraction rates multiplicatively.

6. **Self-mapping criterion** (Theorem 3.4): Explicit conditions for the EML operator to map $[L, U]$ into itself.

All results are formally verified in Lean 4 using the Mathlib library, building on existing catalog results for abstract contraction mappings.

### 1.2 Relation to Existing Work

This work extends two lines of prior formalized results:

- **`contraction_convergence_rate`** (Algebra/SpectralArithmetic/Core.lean): An abstract convergence rate theorem for contractions parameterized by a constant $k < 1$. We specialize this by computing $k$ explicitly from the EML parameters.

- **`contraction_fixed_point_unique`** (Computation/MetaOracleFiveQuestions.lean): An abstract uniqueness theorem for metric space contractions. We derive the contraction property from the analytic structure of exp and log.

- **`contraction_composition_rate`** (Algebra/SpectralArithmetic/Core.lean): The multiplicative composition law for abstract contractions, which we instantiate for EML operators.

## 2. Definitions

### 2.1 The EML Operator

**Definition 2.1** (EML Function). For parameters $a, b, c \in \mathbb{R}$, the EML operator is:
$$\text{emlFun}(a, b, c)(x) = e^a \cdot \log(bx + c)$$

The domain is $\{x \in \mathbb{R} : bx + c > 0\}$.

**Definition 2.2** (EML Iteration). For $n \in \mathbb{N}$, define:
$$\text{emlIterate}(a, b, c, 0)(x) = x, \quad \text{emlIterate}(a, b, c, n+1)(x) = f(\text{emlIterate}(a, b, c, n)(x))$$

### 2.2 Contraction Condition

**Definition 2.3** (Contraction Constant). On an interval $[L, U]$ with $bL + c > 0$, the contraction constant is:
$$\rho = e^a \cdot \frac{b}{bL + c}$$

The **contraction condition** is $\rho < 1$, equivalently $e^a \cdot b < bL + c$.

## 3. Lipschitz Analysis and Contraction

### 3.1 Derivative Structure

**Theorem 3.1** (EML Derivative). If $bx + c \neq 0$, then:
$$f'(x) = e^a \cdot \frac{b}{bx + c}$$

Moreover, $f'$ has the following properties:

**(a) Positivity**: If $b > 0$ and $bx + c > 0$, then $f'(x) > 0$.

**(b) Monotone decrease**: If $b > 0$ and $x \leq y$ with $bx + c > 0$, then $f'(y) \leq f'(x)$.

*Proof sketch*. Part (a) follows from positivity of exp, $b$, and $bx+c$. Part (b) follows from $bx+c \leq by+c$ and monotonicity of division by a positive increasing denominator. □

The monotone decrease of $f'$ is the key structural property: it means the worst-case Lipschitz constant is attained at the left endpoint of any interval.

### 3.2 Lipschitz Bound

**Theorem 3.2** (EML Lipschitz Bound). Let $b > 0$, $L \leq U$, and $bL + c > 0$. For all $x, y \in [L, U]$:
$$|f(y) - f(x)| \leq \frac{e^a \cdot b}{bL + c} \cdot |y - x|$$

*Proof sketch*. By the mean value inequality (Mathlib's `Convex.norm_image_sub_le_of_norm_deriv_le`), it suffices to show that $\|f'(z)\| \leq e^a \cdot b/(bL+c)$ for all $z \in [L, U]$. Since $z \geq L$, we have $bz+c \geq bL+c > 0$, so $f'(z) = e^a \cdot b/(bz+c) \leq e^a \cdot b/(bL+c)$. □

**Remark**. The bound is tight: as $x \to L$ and $y \to L$ with $x \neq y$, the ratio $|f(y)-f(x)|/|y-x|$ approaches $f'(L) = e^a \cdot b/(bL+c)$.

### 3.3 Fixed-Point Uniqueness

**Theorem 3.3** (Unique Fixed Point). If $e^a \cdot b < bL + c$ (contraction condition), then the EML operator has at most one fixed point in $[L, U]$.

*Proof*. Suppose $p, q \in [L, U]$ with $f(p) = p$ and $f(q) = q$. Then:
$$\|p - q\| = \|f(p) - f(q)\| \leq \rho \cdot \|p - q\|$$
Since $\rho < 1$, this implies $\|p - q\| = 0$, hence $p = q$. □

### 3.4 Self-Mapping

**Theorem 3.4** (Invariant Interval). If $b > 0$, $bL + c > 0$, and:
- $L \leq e^a \cdot \log(bL + c)$
- $e^a \cdot \log(bU + c) \leq U$

then $f$ maps $[L, U]$ into itself: for all $x \in [L, U]$, $f(x) \in [L, U]$.

*Proof sketch*. Since $\log$ is monotone increasing and $bx + c$ is linear in $x$ with positive coefficient $b$, we have $\log(bL+c) \leq \log(bx+c) \leq \log(bU+c)$ for $x \in [L, U]$. Multiplying by $e^a > 0$ preserves the inequalities. □

## 4. Convergence

### 4.1 Geometric Rate

**Theorem 4.1** (Convergence Bound). Let $\rho = e^a \cdot b/(bL+c) < 1$, $x^*$ be a fixed point of $f$ in $[L, U]$, and assume all iterates remain in $[L, U]$. Then:
$$\|x_n - x^*\| \leq \rho^n \cdot \|x_0 - x^*\|$$

*Proof*. By induction on $n$. The base case $n = 0$ is trivial. For the inductive step:
$$\|x_{n+1} - x^*\| = \|f(x_n) - f(x^*)\| \leq \rho \cdot \|x_n - x^*\| \leq \rho \cdot \rho^n \cdot \|x_0 - x^*\| = \rho^{n+1} \cdot \|x_0 - x^*\|$$

using the Lipschitz bound at each step. □

### 4.2 Convergence to Fixed Point

**Theorem 4.2** (Convergence). Under the hypotheses of Theorem 4.1:
$$\|x_n - x^*\| \to 0 \quad \text{as } n \to \infty$$

*Proof*. Since $0 \leq \rho < 1$, $\rho^n \to 0$ by `tendsto_pow_atTop_nhds_zero_of_lt_one`. The squeeze theorem (`squeeze_zero`) applied to $0 \leq \|x_n - x^*\| \leq \rho^n \cdot \|x_0 - x^*\|$ completes the proof. □

**Remark on convergence speed.** The number of iterations needed to achieve error $\varepsilon$ is:
$$n \geq \frac{\log(\varepsilon / d_0)}{\log \rho}$$

For $\rho = 0.824$ (the case $a = 0.5, b = 1, c = 1$), achieving 15-digit accuracy from $d_0 = 1.5$ requires approximately $n \geq 15 \cdot \log 10 / |\log 0.824| \approx 178$ iterations. In practice, convergence is faster because the local rate $|f'(x^*)| \approx 0.651$ is smaller than $\rho$.

## 5. Structural Results

### 5.1 Comparison Principle

**Theorem 5.1** (Monotone Parameter Dependence). Let $a_1 \leq a_2$, and suppose both $f_1(x) = e^{a_1} \log(bx+c)$ and $f_2(x) = e^{a_2} \log(bx+c)$ are contractions on $[L, U]$ with $bL + c > 1$. Let $p_1, p_2$ be their respective fixed points in $[L, U]$. Then $p_1 \leq p_2$.

*Proof sketch*. Suppose for contradiction that $p_2 < p_1$. Since $a_1 \leq a_2$ and $\log(bp_1 + c) > 0$ (because $bp_1 + c > bL + c > 1$), we have $f_2(p_1) \geq f_1(p_1) = p_1 > p_2 = f_2(p_2)$. By the Lipschitz bound for $f_2$:

$$f_2(p_1) - p_2 = |f_2(p_1) - f_2(p_2)| \leq \rho_2 \cdot |p_1 - p_2| = \rho_2(p_1 - p_2)$$

Since $\rho_2 < 1$, this gives $f_2(p_1) < p_1$, contradicting $f_2(p_1) \geq p_1$. □

### 5.2 Composition of Contractions

**Theorem 5.2** (Multiplicative Composition). Let $f_1, f_2$ be EML operators with Lipschitz constants $\rho_1, \rho_2$ on $[L, U]$. If both map $[L, U]$ into itself, then the composition $f_1 \circ f_2$ satisfies:
$$\|f_1(f_2(y)) - f_1(f_2(x))\| \leq \rho_1 \cdot \rho_2 \cdot \|y - x\|$$

*Proof*. Direct computation:
$$\|f_1(f_2(y)) - f_1(f_2(x))\| \leq \rho_1 \cdot \|f_2(y) - f_2(x)\| \leq \rho_1 \cdot \rho_2 \cdot \|y - x\|$$

□

**Corollary.** An $n$-layer EML network with per-layer contraction rates $\rho_1, \ldots, \rho_n$ has overall contraction rate $\prod_{i=1}^n \rho_i$. If each $\rho_i < 1$, the product decreases exponentially with depth.

### 5.3 Monotonicity of the EML Operator

**Theorem 5.3** (Monotonicity in $a$). If $a_1 \leq a_2$ and $bx + c > 1$, then:
$$f_{a_1}(x) \leq f_{a_2}(x)$$

This follows from $e^{a_1} \leq e^{a_2}$ and $\log(bx+c) \geq 0$.

## 6. Numerical Examples

### 6.1 Standard Case: $a = 0.5, b = 1, c = 1$

- Contraction constant on $[1, \infty)$: $\rho = e^{0.5}/2 \approx 0.824$
- Fixed point: $x^* \approx 1.531076$
- Local rate: $|f'(x^*)| \approx 0.651$
- From $x_0 = 3$: convergence in $\sim 80$ iterations to 15-digit accuracy

### 6.2 Parameter Sweep: $b = 1, c = 2$

| $a$ | $x^*$ | $\|f'(x^*)\|$ |
|-----|--------|----------------|
| 0.1 | 1.329 | 0.332 |
| 0.3 | 1.803 | 0.355 |
| 0.5 | 2.468 | 0.369 |
| 0.7 | 3.394 | 0.373 |
| 0.9 | 4.666 | 0.369 |

The fixed point increases monotonically with $a$ (Theorem 5.1). The local contraction rate remains remarkably stable around 0.35-0.37.

### 6.3 Three-Layer Composition

Layers: $(a_1, b_1, c_1) = (0.3, 1, 2)$, $(a_2, b_2, c_2) = (0.2, 1, 3)$, $(a_3, b_3, c_3) = (0.1, 1, 4)$.

Individual rates: $\rho_1 = 0.450, \rho_2 = 0.305, \rho_3 = 0.221$.

Product rate: $\rho_1 \rho_2 \rho_3 = 0.030$ — a 97% contraction per iteration of the full network.

## 7. Discussion

### 7.1 Comparison with General Contraction Theory

Our results specialize the Banach fixed-point theorem to the EML function class. The key advance over abstract contraction theory is the derivation of **explicit, computable** contraction constants from the parameters $(a, b, c)$. This transforms the contraction condition from an existential statement ("there exists $\rho < 1$...") to a checkable algebraic inequality ($e^a \cdot b < bL + c$).

### 7.2 Boundary of the Contraction Region

The contraction condition fails when $e^a \cdot b \geq bL + c$. This happens:
- When $a$ is too large (exponential scaling dominates the logarithmic damping)
- When $L$ is too small (the interval includes points where $bx + c$ is close to zero, making $f'$ large)
- When $b$ is large relative to $c$ (the linear growth inside log is insufficiently offset)

At the boundary $e^a \cdot b = bL + c$, the contraction rate is exactly 1, and the operator becomes a non-expanding map. Beyond this boundary, the iteration may diverge.

### 7.3 Applications to Neural Network Design

The multiplicative composition law (Theorem 5.2) suggests a design principle for EML-based neural architectures: each layer should be designed as a contraction, with the per-layer rate $\rho_i$ chosen to balance convergence speed against expressiveness. Smaller $\rho_i$ means faster convergence but potentially less representational power.

The comparison principle (Theorem 5.1) provides interpretability: increasing the exponential parameter $a$ in any layer predictably increases the network's equilibrium output.

## 8. Formal Verification

All theorems in this paper are formally verified in Lean 4 with the Mathlib library. The formalization consists of:

- 11 formally verified theorems with no `sorry` or non-standard axioms
- Key Mathlib dependencies: `Convex.norm_image_sub_le_of_norm_deriv_le` (mean value inequality), `tendsto_pow_atTop_nhds_zero_of_lt_one` (geometric convergence), `squeeze_zero` (sandwich theorem)
- Standard axioms only: `propext`, `Classical.choice`, `Quot.sound`

The formalization bridges abstract catalog results (`contraction_convergence_rate`, `contraction_fixed_point_unique`, `contraction_composition_rate`) to the concrete EML function class.

## 9. Future Work

1. **Multivariate extension**: Generalize to $f(\mathbf{x}) = e^{\mathbf{A}} \cdot \log(\mathbf{B}\mathbf{x} + \mathbf{c})$ with matrix parameters
2. **Optimal parameter selection**: Given a target fixed point, find $(a, b, c)$ minimizing the contraction rate
3. **Complex extension**: Extend to $\mathbb{C}$-valued EML operators with branch cut analysis
4. **Stochastic EML**: Analyze convergence when parameters are perturbed stochastically at each iteration
5. **Power series expansion**: Express the fixed point $x^*$ as a formal power series in $a$

## References

1. Banach, S. "Sur les opérations dans les ensembles abstraits et leur application aux équations intégrales." *Fundamenta Mathematicae* 3 (1922): 133-181.

2. `contraction_convergence_rate`, Catalog: `Algebra/SpectralArithmetic/Core.lean`

3. `contraction_fixed_point_unique`, Catalog: `Computation/MetaOracleFiveQuestions.lean`

4. `contraction_composition_rate`, Catalog: `Algebra/SpectralArithmetic/Core.lean`

5. `emlFun_contraction_unique_fixedPt`, This work: `Applications/EMLFixedPoint.lean`
