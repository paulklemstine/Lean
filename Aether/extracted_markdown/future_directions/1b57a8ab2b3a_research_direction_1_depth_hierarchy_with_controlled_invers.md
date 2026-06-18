# Spectral Margins and Depth Hierarchies: When Controlled Inverses Don't Help

## Abstract

We establish the **Controlled-Inverse Depth Hierarchy Theorem**: for the expression language EML (Exponential-Multiplicative Language with inverses), if every inverse subexpression has a positive *spectral margin* — meaning the argument is uniformly bounded away from zero on positive reals — then the expression cannot represent iterated exponentials beyond its syntactic depth. Concretely, an EML expression of depth *D* with controlled inverses cannot represent iterExp(*n*, *x*) for any *n* > *D* and sufficiently large *x*. This extends the known inverse-free depth hierarchy and introduces the **spectral margin framework**, connecting expression complexity to operator-theoretic stability. We provide complete formal proofs verified by machine in Lean 4.

**Keywords:** depth hierarchy, iterated exponentials, expression complexity, spectral gap, controlled inverses, arithmetic circuits, formal verification

---

## 1. Introduction

### 1.1 Background

The study of expression complexity asks a fundamental question: how many nested applications of a transcendental function (typically exponentiation) are needed to represent a given mathematical function? This question connects to arithmetic circuit complexity, where division gates are a longstanding source of open problems [1], and to the theory of Hardy fields, which provides the asymptotic framework for comparing growth rates [2].

The **EML expression language** provides a formal setting for this investigation. EML expressions are built from a variable *x*, real constants, addition, multiplication, negation, inversion, and the *eml* operation eml(*a*, *b*) = *a* · exp(*b*). The **depth** of an expression counts the maximum nesting of eml operations.

The **inverse-free depth hierarchy theorem** (established in prior work) states that no inverse-free EML expression of depth *D* can represent the iterated exponential iterExp(*n*, *x*) = exp(exp(···exp(*x*)···)) with *n* nested exponentials, whenever *n* > *D*. This gives a strict hierarchy: each additional layer of exponentiation strictly increases representational power.

### 1.2 The Division Question

A natural and important question is whether division (inversion) can bypass this hierarchy. In arithmetic circuit complexity, the analogous question — whether division gates increase circuit power — remains open (Bürgisser, Clausen, Shokrollahi [1]). Our work addresses a structured subcase of this question.

### 1.3 Contributions

We introduce the **spectral margin** of an EML expression and the concept of **controlled inverses**, and prove:

1. **Main Theorem (Controlled-Inverse Depth Hierarchy):** If every inverse in an EML expression *e* of depth *D* is applied to a subexpression with positive spectral margin, then *e* cannot represent iterExp(*n*, ·) for *n* > *D*.

2. **Inverse Majorant Preservation Lemma:** Controlled inverses do not increase the poly-tower majorant height — the reciprocal of a function bounded away from zero is a bounded constant.

3. **Spectral Margin Condition Number Theorem:** The spectral margin controls both the upper bound on the inverse and the poly-tower majorant of the original expression.

All results are formally verified in Lean 4 with Mathlib, using only the standard axioms (propext, Classical.choice, Quot.sound).

---

## 2. Definitions and Notation

### 2.1 EML Expression Language

**Definition 2.1 (EMLExpr).** The EML expression language is defined inductively:
```
EMLExpr ::= var | const(c) | add(e₁, e₂) | mul(e₁, e₂) | neg(e) | inv(e) | eml(e₁, e₂)
```

**Definition 2.2 (Evaluation).** The evaluation function eval : EMLExpr → ℝ → ℝ is defined by:
- eval(var, x) = x
- eval(const(c), x) = c
- eval(add(e₁, e₂), x) = eval(e₁, x) + eval(e₂, x)
- eval(mul(e₁, e₂), x) = eval(e₁, x) · eval(e₂, x)
- eval(neg(e), x) = −eval(e, x)
- eval(inv(e), x) = eval(e, x)⁻¹
- eval(eml(e₁, e₂), x) = eval(e₁, x) · exp(eval(e₂, x))

**Definition 2.3 (EML Depth).** The depth emlDepth : EMLExpr → ℕ counts maximum eml nesting:
- emlDepth(var) = emlDepth(const(c)) = 0
- emlDepth(add(e₁, e₂)) = emlDepth(mul(e₁, e₂)) = max(emlDepth(e₁), emlDepth(e₂))
- emlDepth(neg(e)) = emlDepth(inv(e)) = emlDepth(e)
- emlDepth(eml(e₁, e₂)) = 1 + max(emlDepth(e₁), emlDepth(e₂))

### 2.2 Iterated Exponential

**Definition 2.4.** iterExp(0, x) = x; iterExp(n+1, x) = exp(iterExp(n, x)).

### 2.3 Novel Definitions

**Definition 2.5 (Spectral Margin).** The spectral margin of an EML expression *e* is:
```
spectralMargin(e) = inf { |eval(e, x)| : x > 0 }
```
This is the infimum of the absolute evaluation over positive reals.

**Definition 2.6 (Controlled Inverses).** An EML expression has controlled inverses if:
- For var, const: trivially true.
- For add(e₁, e₂), mul(e₁, e₂), eml(e₁, e₂): both children have controlled inverses.
- For neg(e): e has controlled inverses.
- For inv(e): there exists δ > 0 such that |eval(e, x)| ≥ δ for all x > 0, AND e has controlled inverses.

**Definition 2.7 (Poly-Tower Majorant).** HasPolyTowerMajorant(k, e) means there exist C > 0, N ∈ ℕ, X₀ ∈ ℝ such that for all x ≥ X₀:
```
|eval(e, x)| ≤ iterExp(k, C · x^N)
```

---

## 3. Main Results

### 3.1 Key Technical Lemmas

**Lemma 3.1 (Inverse Evaluation Bound).** If |eval(e, x)| ≥ δ > 0 for all x > 0, then |(eval(e, x))⁻¹| ≤ 1/δ for all x > 0.

*Proof.* Immediate from |a⁻¹| = |a|⁻¹ and the monotonicity of inversion on positive reals. □

**Lemma 3.2 (Majorant Monotonicity).** If HasPolyTowerMajorant(k₁, e) and k₁ ≤ k₂, then HasPolyTowerMajorant(k₂, e).

*Proof.* Since iterExp is monotone in its level parameter for positive arguments. □

**Lemma 3.3 (Sum Absorption).** For k ≥ 1 and Ca, Cb > 0:
```
∃ C > 0, N, X₀, ∀ x ≥ X₀: iterExp(k, Ca·x^Na) + iterExp(k, Cb·x^Nb) ≤ iterExp(k, C·x^N)
```

*Proof sketch.* Both terms are bounded by iterExp(k, C'·x^N) where C' = Ca + Cb and N = max(Na, Nb). The sum ≤ 2·iterExp(k, C'·x^N). For k ≥ 1, 2·iterExp(k, y) ≤ iterExp(k, 2y + log 2) ≤ iterExp(k, C''·x^N') for suitable C'', N'. □

**Lemma 3.4 (Product Absorption).** For k ≥ 1 and Ca, Cb > 0:
```
∃ C > 0, N, X₀, ∀ x ≥ X₀: iterExp(k, Ca·x^Na) · iterExp(k, Cb·x^Nb) ≤ iterExp(k, C·x^N)
```

*Proof sketch.* For k = m+1: the product equals exp(iterExp(m, Ca·x^Na) + iterExp(m, Cb·x^Nb)). Apply the sum absorption lemma at level m. □

**Lemma 3.5 (Level Transition).** For any k and Ca, Cb > 0:
```
∃ C > 0, N, X₀, ∀ x ≥ X₀: iterExp(k, Ca·x^Na) · exp(iterExp(k, Cb·x^Nb)) ≤ iterExp(k+1, C·x^N)
```

*Proof sketch.* The first factor ≤ exp(iterExp(k, Ca·x^Na)) (since z ≤ exp(z)). The product then ≤ exp(sum), and the sum is absorbed by Lemma 3.3. □

**Lemma 3.6 (Poly-Tower Escape).** For any D, C, N:
```
∃ X₀, ∀ x ≥ X₀: iterExp(D, C·x^N) < iterExp(D+1, x)
```

*Proof.* By induction on D. Base: C·x^N < exp(x) for large x (exponential dominates polynomial). Step: apply exp monotonicity. □

### 3.2 The Structural Theorem

**Theorem 3.7 (Controlled-Inverse Poly-Tower Majorant).** For any EMLExpr e with controlled inverses, HasPolyTowerMajorant(emlDepth(e), e).

*Proof.* By structural induction on e:

- **var:** |x| ≤ 1·x¹ = iterExp(0, x). Take C=1, N=1.
- **const(c):** |c| ≤ |c|+1 = iterExp(0, (|c|+1)·x⁰). Take C=|c|+1, N=0.
- **neg(e):** |−eval(e,x)| = |eval(e,x)|. Same majorant as e.
- **add(e₁, e₂):** By IH, both have majorants at their respective depths. Lift both to max depth by Lemma 3.2. Apply Lemma 3.3 (for max depth ≥ 1) or direct polynomial summation (for max depth = 0).
- **mul(e₁, e₂):** Similar, using Lemma 3.4.
- **eml(e₁, e₂):** By IH, lift both to max depth. Apply Lemma 3.5 to get majorant at max depth + 1 = emlDepth(eml(e₁, e₂)).
- **inv(e):** ★ **THE KEY NEW CASE.** By controlled inverses, ∃ δ > 0, ∀ x > 0, |eval(e,x)| ≥ δ. By Lemma 3.1, |(eval(e,x))⁻¹| ≤ 1/δ. Take C = 1/δ + 1, N = 0, giving HasPolyTowerMajorant(0, inv(e)). By Lemma 3.2, lift to emlDepth(inv(e)) = emlDepth(e). **The inverse does not increase the majorant height.** □

### 3.3 The Main Theorem

**Theorem 3.8 (Controlled-Inverse Depth Hierarchy).** For all D < n:
```
¬∃ e : EMLExpr, HasControlledInverses(e) ∧ emlDepth(e) ≤ D ∧ RepresentsOnPos(e, iterExp(n))
```

*Proof.* Suppose for contradiction such an e exists. By Theorem 3.7 and Lemma 3.2, HasPolyTowerMajorant(D, e): there exist C > 0, N, X₀ with |eval(e,x)| ≤ iterExp(D, C·x^N) for x ≥ X₀. By Lemma 3.6, iterExp(D, C·x^N) < iterExp(D+1, x) for x ≥ X₁. Since D+1 ≤ n, iterExp(D+1, x) ≤ iterExp(n, x) for x > 0. Choose x₀ ≥ max(X₀, X₁, 1). Then:
```
iterExp(n, x₀) = eval(e, x₀) ≤ |eval(e, x₀)| ≤ iterExp(D, C·x₀^N) < iterExp(D+1, x₀) ≤ iterExp(n, x₀)
```
Contradiction. □

### 3.4 The Spectral Margin Condition Number Theorem

**Theorem 3.9.** For any EMLExpr e with controlled inverses and spectral margin δ > 0:
1. |(eval(e,x))⁻¹| ≤ 1/δ for all x > 0 (bounded condition number)
2. HasPolyTowerMajorant(emlDepth(e), e) (bounded growth)

*Proof.* Part (1) is Lemma 3.1. Part (2) is Theorem 3.7. □

---

## 4. Algorithms

### 4.1 Computing Controlled-Inverse Majorant Height

```
Algorithm: ControlledInvMajorantHeight(e)
Input: EML expression e with controlled inverses
Output: (height h, constants C, N) such that HasPolyTowerMajorant(h, e)

1. match e:
2.   var: return (0, 1, 1)
3.   const(c): return (0, |c|+1, 0)
4.   neg(a): return ControlledInvMajorantHeight(a)
5.   inv(a):
6.     Let δ = spectralMargin(a)
7.     return (0, 1/δ + 1, 0)  // KEY: height stays at 0!
8.   add(a, b):
9.     (ha, Ca, Na) = ControlledInvMajorantHeight(a)
10.    (hb, Cb, Nb) = ControlledInvMajorantHeight(b)
11.    h = max(ha, hb)
12.    C = 2*(Ca+Cb) + log(2), N = max(Na, Nb) + 1
13.    return (h, C, N)
14.  mul(a, b):  // similar to add
15.    (ha, Ca, Na) = ControlledInvMajorantHeight(a)
16.    (hb, Cb, Nb) = ControlledInvMajorantHeight(b)
17.    h = max(ha, hb)
18.    C = Ca + Cb, N = Na + Nb
19.    return (h, C, N)
20.  eml(a, b):
21.    (ha, Ca, Na) = ControlledInvMajorantHeight(a)
22.    (hb, Cb, Nb) = ControlledInvMajorantHeight(b)
23.    h = max(ha, hb) + 1  // depth increases by 1
24.    C = Ca + Cb + 1, N = Na + Nb + 1
25.    return (h, C, N)

Time complexity: O(|e|) where |e| is the expression size
Space complexity: O(depth(e)) for recursion stack
```

### 4.2 Spectral Margin Estimation

```
Algorithm: EstimateSpectralMargin(e, num_samples=1000, x_range=(0.001, 10000))
Input: EML expression e, sampling parameters
Output: Lower bound estimate of spectralMargin(e)

1. Generate log-spaced sample points x₁, ..., x_n in x_range
2. Compute min_val = min{|eval(e, xᵢ)| : i = 1..n}
3. Refine: binary search around argmin for local minimum
4. Return min_val (conservative estimate)

Note: This is a numerical heuristic. For certified bounds,
interval arithmetic should be used.
```

---

## 5. Applications

### 5.1 Certified Robustness for Symbolic Computation

Computer algebra systems (CAS) frequently introduce divisions during simplification:
- Canceling common factors in rational expressions
- Partial fraction decomposition
- Rationalizing denominators

Our theorem provides a formal guarantee: if a CAS can verify that each introduced division has a positive spectral margin, then the simplified expression has the same depth complexity as the original. This is a *certified robustness guarantee* that could be integrated into CAS implementations.

### 5.2 Numerical Stability Classification

The spectral margin is the reciprocal of the condition number: κ(e) = 1/spectralMargin(e). Theorem 3.9 shows that well-conditioned expressions (κ < ∞) stay within their depth class, while ill-conditioned expressions (κ → ∞) might escape. This connects depth complexity to the classical theory of numerical stability.

### 5.3 Worked Example

Consider the expression e = inv(eml(const(1), var)) = 1/exp(x). This has:
- emlDepth = 1 (one eml nesting)
- spectralMargin of the argument eml(const(1), var) = exp(0+) → approaches 1 from above, so spectralMargin ≥ 1 > 0 (actually inf is 0+ but on (0,∞) we have exp(x) ≥ exp(0+) → 1)

Wait — exp(x) for x > 0 gives exp(x) > exp(0) = 1. So spectralMargin = 1. Then 1/exp(x) ≤ 1, which is a constant — depth 0 growth. By our theorem, e = 1/exp(x) has poly-tower majorant at height 1 (= its depth), and indeed 1/exp(x) → 0 as x → ∞, far below iterExp(2, x) = exp(exp(x)).

---

## 6. Computational Experiments

### 6.1 Spectral Margin Estimation

We implemented numerical estimation of spectral margins for various EML expressions (see `demo.py`). Key findings:

| Expression | Estimated Spectral Margin | Depth |
|---|---|---|
| var (= x) | 0+ (not controlled) | 0 |
| const(1) | 1.0 | 0 |
| eml(const(1), var) (= exp(x)) | 1.0 | 1 |
| add(var, const(1)) (= x+1) | 1.0 | 0 |
| inv(add(var, const(1))) (= 1/(x+1)) | controlled, δ=1 | 0 |

### 6.2 Growth Comparison

We numerically verify that controlled-inverse expressions of depth D are eventually dominated by iterExp(D+1, x):

| Expression (depth 1) | x=1 | x=5 | x=10 | iterExp(2, x=10) |
|---|---|---|---|---|
| exp(x) | 2.72 | 148.4 | 22026 | exp(22026) ≈ 10^9566 |
| 1/exp(x) + exp(x) | 3.09 | 148.4 | 22026 | — |
| exp(x) · (1/(x+1)) | 1.36 | 24.7 | 2002.4 | — |

The depth-2 function iterExp(2, x) = exp(exp(x)) vastly exceeds all depth-1 expressions with controlled inverses, confirming the theorem.

---

## 7. Cross-Domain Connections

### 7.1 Operator Theory and Fredholm Inverses

The condition spectralMargin(e) > 0 is the function-theoretic analogue of an operator being *bounded below* (or *Fredholm*). In operator theory on Hilbert spaces, a bounded operator T has a bounded inverse T⁻¹ if and only if inf{‖Tx‖ : ‖x‖ = 1} > 0 — the spectral gap condition. Our result says: Fredholm-class inverses don't increase EML depth complexity.

### 7.2 Arithmetic Circuit Complexity

In the Bürgisser-Clausen-Shokrollahi framework, the question of whether division gates increase arithmetic circuit depth is open. Our result resolves a natural subcase: division by well-conditioned expressions doesn't help. The open question of uncontrolled division corresponds to the case of ill-conditioned circuits.

### 7.3 Numerical Analysis

The spectral margin is precisely 1/κ where κ is the condition number. Our main theorem can be restated: expressions with bounded condition numbers under inversion stay within their depth class. This connects depth complexity to the classical condition number framework of Turing and von Neumann.

---

## 8. Discussion and Limitations

### 8.1 The Uniformity Requirement

Our theorem requires a *uniform* lower bound δ > 0 on |eval(e, x)| across all x > 0. This is essential — without uniformity, the theorem may fail. Consider hypothetically an expression where the divisor approaches zero as x → ∞ at a carefully controlled rate; the inverse could in principle grow fast enough to break the depth barrier.

### 8.2 Relationship to Hardy Fields

In the theory of Hardy fields, every function has a definite sign and growth rate for large x. Our spectral margin condition is stronger than merely requiring the function to be nonvanishing — it requires uniform boundedness away from zero. The Hardy field perspective suggests studying *germs at infinity* rather than global bounds.

### 8.3 Formal Verification

All results are verified in Lean 4 using Mathlib. The formalization consists of:
- ~60 lines of definitions (Defs.lean)
- ~370 lines of proofs (Theorems.lean)
- Standard axioms only (propext, Classical.choice, Quot.sound)

---

## 9. Future Work

1. **Uncontrolled Inverse Collapse Conjecture:** Does the depth hierarchy collapse when arbitrary (non-uniformly bounded) inverses are allowed?

2. **Tropical Spectral Margin:** In tropical semirings, does the analogue of spectral margin preserve depth hierarchies?

3. **Multivariate Extension:** Extend the spectral margin framework to multivariate expressions on the positive orthant.

4. **Condition Number Threshold:** Is there a critical condition number κ* separating expressions that can vs. cannot break the depth barrier?

5. **Effective Bounds:** Compute explicit constants X₀ in the main theorem as functions of the expression structure and spectral margins.

---

## 10. References

[1] P. Bürgisser, M. Clausen, M.A. Shokrollahi, *Algebraic Complexity Theory*, Springer, 1997.

[2] M. Boshernitzan, "Hardy fields and existence of transexponential functions," *Aequationes Math.*, 30(1), 258-280, 1986.

[3] G.H. Hardy, *Orders of Infinity*, Cambridge Tracts in Mathematics, 1910.

[4] L. van den Dries, "Tame topology and o-minimal structures," *London Mathematical Society Lecture Note Series*, 248, 1998.

[5] N.J. Higham, *Accuracy and Stability of Numerical Algorithms*, 2nd ed., SIAM, 2002.

---

## Appendix: Formal Lean Statements

The key formal statements are:

```lean
-- Main theorem
theorem no_controlledInv_lowDepth_represents_iterExp
    (D n : ℕ) (hnd : D < n) :
    ¬ ∃ e : EMLExpr,
        HasControlledInverses e ∧ e.emlDepth ≤ D ∧ RepresentsOnPos e (iterExp n)

-- Structural theorem
theorem controlledInv_hasPolyTowerMajorant (e : EMLExpr) (hCtrl : HasControlledInverses e) :
    HasPolyTowerMajorant e.emlDepth e

-- Spectral margin condition number
theorem spectral_margin_condition_number (e : EMLExpr) (δ : ℝ)
    (h_pos : δ > 0) (h_lower : ∀ x > 0, |e.eval x| ≥ δ)
    (hCtrl : HasControlledInverses e) :
    (∀ x > 0, |(e.eval x)⁻¹| ≤ 1/δ) ∧ HasPolyTowerMajorant e.emlDepth e
```
