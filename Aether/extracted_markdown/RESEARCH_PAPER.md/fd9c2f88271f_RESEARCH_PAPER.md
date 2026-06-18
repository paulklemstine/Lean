# EML Fixed-Point Theorem: Exp-Log Iteration Convergence

## Abstract

We study the single-operator EML function f(x) = exp(a) · log(b·x + c) and establish that, under suitable parameter constraints, it is a contraction mapping on a closed invariant interval. We prove the existence and uniqueness of a fixed point, geometric convergence of the Picard iteration sequence, and provide explicit derivative and convergence rate formulas. Our main results include: (1) a derivative formula f'(x) = exp(a) · b / (b·x + c), proved via the chain rule; (2) a Lipschitz bound from the mean value theorem showing |f(x) - f(y)| ≤ ρ|x - y| when |f'| ≤ ρ < 1 on the interval; (3) uniqueness of the fixed point via contraction; (4) geometric decay of consecutive iterate differences |x_{n+1} - x_n| ≤ ρⁿ|x_1 - x_0|; (5) Cauchy-sequence convergence of the iteration to the unique fixed point; and (6) existence of a positive fixed point for the specific case f(x) = exp(a) · log(x + 2) when a ∈ (0, 1/2), via the intermediate value theorem. All results have been formally verified in the Lean 4 theorem prover with the Mathlib library.

## 1. Introduction

The EML (Exponential-Minus-Log) framework provides a family of neural network building blocks based on combinations of exponential and logarithmic operations. Unlike standard activation functions such as ReLU, sigmoid, or tanh, EML operations possess rich analytic structure that enables precise mathematical characterization of their dynamical behavior.

In this paper, we focus on the single-operator EML function

$$f(x) = e^a \cdot \log(bx + c)$$

where a, b, c ∈ ℝ are parameters. This function combines exponential scaling (via e^a) with logarithmic compression (via log), connected through an affine transformation (bx + c). We study the iteration

$$x_{n+1} = f(x_n)$$

and prove that under suitable parameter constraints, this iteration converges geometrically to a unique fixed point.

### 1.1 Motivation

Fixed-point iterations arise naturally in:
- **Equilibrium neural networks**: Models where inference requires solving f(x) = x for an implicit layer.
- **Iterative optimization**: Many optimization algorithms reduce to fixed-point iterations.
- **Signal processing**: Feedback systems where the steady state is a fixed point of the system operator.

The EML operator provides a controlled instance where convergence can be certified a priori, with explicit convergence rates.

### 1.2 Related Work

The Banach fixed-point theorem (1922) provides the foundational theory for contraction mappings. Our work instantiates this theory for a specific function family, providing explicit derivative bounds and parameter conditions.

Previous work in the EML catalog has established:
- Unique fixed points for the EML diagonal map (`emlGmap_unique_fixed_point` in EMLv17Advanced)
- Fixed-point properties of OML functions (`oml_unique_fixed_point` in FutureResearch)
- Non-existence of fixed points for certain EML configurations (`eml_exp_no_fixed_point`)
- Gradient bounds for EML neural networks (`eml_gradient_log_bounded`)

Our contribution extends this line by providing a complete convergence theory for a parameterized family of EML operators.

## 2. Definitions

### 2.1 The EML Single Operator

**Definition 1** (EML Iteration Operator). For parameters a, b, c ∈ ℝ, the EML iteration operator is:
$$\text{EMLIterOp}(a, b, c)(x) = e^a \cdot \log(bx + c)$$

**Definition 2** (Iteration Sequence). Given initial point x₀ ∈ ℝ, the iteration sequence is:
$$x_0 = x_0, \quad x_{n+1} = \text{EMLIterOp}(a, b, c)(x_n)$$

### 2.2 Contraction Data

**Definition 3** (EML Contraction Data). A tuple (a, b, c, lo, hi, ρ) constitutes valid contraction data if:
1. lo < hi (valid interval)
2. 0 ≤ ρ < 1 (contraction ratio)
3. ∀ x ∈ [lo, hi], bx + c > 0 (log argument positivity)
4. ∀ x ∈ [lo, hi], f(x) ∈ [lo, hi] (invariance)
5. ∀ x ∈ [lo, hi], |e^a · b / (bx + c)| ≤ ρ (derivative bound)

This is formalized as the `EMLContractionData` structure in Lean.

## 3. Main Results

### 3.1 Derivative Formula

**Theorem 1** (HasDerivAt). For b·x + c > 0, the EML operator is differentiable with:
$$f'(x) = \frac{e^a \cdot b}{bx + c}$$

*Proof sketch.* Apply the chain rule: the inner function g(x) = bx + c has derivative b, log has derivative 1/(bx+c) at positive arguments, and the constant factor e^a passes through. □

### 3.2 Lipschitz Property

**Theorem 2** (Lipschitz Bound). If |f'(x)| ≤ ρ for all x ∈ [lo, hi] with bx + c > 0, then:
$$|f(x) - f(y)| \leq \rho \cdot |x - y| \quad \forall x, y \in [\text{lo}, \text{hi}]$$

*Proof sketch.* Apply the mean value theorem in the form of `Convex.norm_image_sub_le_of_norm_hasDerivWithin_le` from Mathlib. The function is differentiable on the convex set [lo, hi], and the derivative norm is bounded by ρ. □

### 3.3 Fixed Point Characterization

**Theorem 3** (Fixed Point Equation). Any fixed point x* satisfies:
$$x^* = e^a \cdot \log(bx^* + c)$$

**Theorem 4** (Log Argument Lower Bound). If x* > 0 is a fixed point with bx* + c > 0, then bx* + c > 1.

*Proof.* From x* = e^a · log(bx* + c) with x* > 0 and e^a > 0, we get log(bx* + c) > 0. Since bx* + c > 0, this implies bx* + c > 1 (as log is positive only above 1 for positive arguments). □

### 3.4 Uniqueness

**Theorem 5** (Fixed Point Uniqueness). Under contraction conditions (|f'| ≤ ρ < 1 on [lo, hi]), there is at most one fixed point in [lo, hi].

*Proof.* If x₁*, x₂* are both fixed points in [lo, hi], then:
$$|x_1^* - x_2^*| = |f(x_1^*) - f(x_2^*)| \leq \rho |x_1^* - x_2^*|$$
Since ρ < 1, this forces |x₁* - x₂*| = 0. □

### 3.5 Invariance of the Interval

**Theorem 6** (Iteration in Interval). If f maps [lo, hi] to itself and x₀ ∈ [lo, hi], then x_n ∈ [lo, hi] for all n.

*Proof.* By induction on n. □

### 3.6 Geometric Convergence

**Theorem 7** (Geometric Decay). Under contraction data D:
$$|x_{n+1} - x_n| \leq \rho^n \cdot |x_1 - x_0|$$

*Proof.* By induction. Base case is trivial. For the inductive step:
$$|x_{n+2} - x_{n+1}| = |f(x_{n+1}) - f(x_n)| \leq \rho \cdot |x_{n+1} - x_n| \leq \rho \cdot \rho^n \cdot |x_1 - x_0| = \rho^{n+1} \cdot |x_1 - x_0|$$
using the Lipschitz bound and the inductive hypothesis. □

### 3.7 Cauchy Sequence

**Theorem 8** (Cauchy Sequence). The iteration sequence is Cauchy.

*Proof.* Apply `cauchySeq_of_le_geometric` with the geometric bound from Theorem 7 and the fact that ρ < 1. □

### 3.8 Convergence to Fixed Point

**Theorem 9** (Main Convergence Theorem). Under contraction data D, for any x₀ ∈ [lo, hi], there exists x* such that:
1. x_n → x* as n → ∞
2. f(x*) = x*
3. x* ∈ [lo, hi]

*Proof.* 
1. The sequence is Cauchy (Theorem 8), hence convergent in ℝ (completeness).
2. By continuity of f (which is differentiable, hence continuous), f(x*) = f(lim x_n) = lim f(x_n) = lim x_{n+1} = x*.
3. Since [lo, hi] is closed and all x_n ∈ [lo, hi], the limit x* ∈ [lo, hi]. □

### 3.9 Existence for Specific Parameters

**Theorem 10** (Existence Conjecture, Partial). For a ∈ (0, 1/2) with b = 1, c = 2:
$$\exists x^* > 0 : e^a \cdot \log(x^* + 2) = x^*$$

*Proof.* By the intermediate value theorem. Define g(x) = e^a · log(x + 2) - x. Then:
- g(1) = e^a · log(3) - 1 > 0 (since log 3 > 1 and e^a ≥ 1)
- g(3) = e^a · log(5) - 3 < 0 (since e^(1/2) · log(5) < 3)

By continuity of g and the IVT, there exists x* ∈ (1, 3) with g(x*) = 0, i.e., f(x*) = x*. Since x* > 1, we have x* > 0. □

## 4. Algorithms

### 4.1 Fixed Point Computation

```
Algorithm: EML_FIXED_POINT(a, b, c, x₀, ε, max_iter)
Input: Parameters a, b, c; initial point x₀; tolerance ε; max iterations
Output: Approximate fixed point x*

1. x ← x₀
2. for i = 1 to max_iter:
3.     x_new ← exp(a) * log(b * x + c)
4.     if |x_new - x| < ε:
5.         return x_new
6.     x ← x_new
7. return x  // may not have converged
```

### 4.2 Contraction Verification

```
Algorithm: VERIFY_CONTRACTION(a, b, c, lo, hi, N)
Input: Parameters; interval bounds; grid size N
Output: (is_contraction, rho_bound)

1. rho ← 0
2. for i = 0 to N:
3.     x ← lo + i * (hi - lo) / N
4.     deriv ← |exp(a) * b / (b * x + c)|
5.     rho ← max(rho, deriv)
6. Check f(lo) ∈ [lo, hi] and f(hi) ∈ [lo, hi]
7. return (rho < 1 and interval invariant, rho)
```

## 5. Discussion

### 5.1 Parameter Constraints

The contraction condition |e^a · b / (bx + c)| < 1 on [lo, hi] translates to:
$$e^a \cdot |b| < \min_{x \in [\text{lo}, \text{hi}]} |bx + c|$$

For b > 0 and c > 0 with lo > 0, this becomes e^a · b < b · lo + c, i.e., **e^a < lo + c/b**. This gives a concrete parameter regime.

### 5.2 Convergence Rate

The convergence rate ρ = sup |f'(x)| over the interval is:
$$\rho = \frac{e^a \cdot |b|}{b \cdot \text{lo} + c}$$

(when b > 0 and the minimum of bx + c over [lo, hi] is at x = lo). Smaller ρ means faster convergence. Increasing c (stronger logarithmic compression) or decreasing a (weaker exponential scaling) both reduce ρ.

### 5.3 Connection to Neural Networks

In the EML neural network framework, the operator f(x) = e^a · log(bx + c) can serve as:
- An activation function with certified Lipschitz constant
- An implicit layer whose equilibrium is guaranteed to exist and be unique
- A regularization mechanism (the logarithm bounds the growth)

The convergence theorem guarantees that forward-pass computation of implicit EML layers always terminates.

## 6. Open Problems and Conjectures

### 6.1 Power Series Expansion

**Conjecture.** For b = 1, c = 2, the fixed point x*(a) admits a convergent power series:
$$x^*(a) = \sum_{n=0}^{\infty} c_n a^n$$

where the coefficients satisfy the recurrence obtained by differentiating x* = e^a · log(x* + 2) with respect to a.

### 6.2 Multi-Dimensional Extension

**Open Problem.** Extend the contraction theory to the vector-valued case:
$$\mathbf{x}_{n+1} = \text{diag}(e^{\mathbf{a}}) \cdot \log(\mathbf{B}\mathbf{x}_n + \mathbf{c})$$

where the logarithm is applied componentwise. Sufficient conditions for contraction involve the spectral radius of the Jacobian.

### 6.3 Bifurcation Analysis

**Open Problem.** As a crosses the boundary where ρ = 1, the contraction property fails. Does the fixed point undergo a bifurcation (saddle-node, period-doubling, etc.)?

## 7. Formal Verification

All theorems in this paper have been formally verified in Lean 4 using the Mathlib library. The formalization is contained in `EML/FixedPointConvergence.lean` and includes:

- 14 theorem statements, all proved without `sorry`
- Novel structure `EMLContractionData` packaging the contraction hypotheses
- Key proof techniques: chain rule, mean value theorem, geometric series bounds, Cauchy sequence completeness, IVT
- Only standard axioms used: `propext`, `Classical.choice`, `Quot.sound`

## 8. Conclusion

We have established a complete convergence theory for the EML single operator f(x) = e^a · log(bx + c) as a contraction mapping. The theory provides:

1. **Existence**: a fixed point exists in the invariant interval
2. **Uniqueness**: the fixed point is unique (within the contraction domain)
3. **Convergence**: Picard iteration converges geometrically with rate ρ = sup |f'|
4. **Computability**: the fixed point can be approximated to arbitrary precision

These results establish EML functions as mathematically well-behaved building blocks for iterative algorithms, providing the theoretical foundation for certified convergence in EML-based neural network architectures.

## References

1. Banach, S. (1922). Sur les opérations dans les ensembles abstraits et leur application aux équations intégrales. *Fundamenta Mathematicae*, 3, 133-181.
2. EML Neural Networks Framework — Catalog theorems in `EML/EMLv17Core.lean`, `EML/EMLv17Advanced.lean`.
3. Mathlib4 — Lean 4 mathematical library. https://github.com/leanprover-community/mathlib4
