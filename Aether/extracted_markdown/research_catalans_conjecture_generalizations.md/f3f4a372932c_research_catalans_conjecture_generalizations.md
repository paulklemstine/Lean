# Formalized Theory of Exponential Diophantine Equations and Pillai's Conjecture

## Abstract

We develop a formal framework for exponential Diophantine equations of Pillai type, focusing on the equation $x^a - y^b = k$ where $x, y, a, b \geq 2$. We introduce the `ExpDiophEq` structure for general exponential Diophantine equations and prove a suite of results: (1) perfect powers $b^e$ with $b, e \geq 2$ are always $\geq 4$; (2) gaps between consecutive $e$-th powers grow without bound; (3) for fixed equal exponents, the Pillai equation has finitely many solutions; (4) complete classification of $x^2 - y^2 = k$ for small $k$; (5) structural factorization and uniqueness results. All theorems are machine-verified with no sorry axioms. We formalize Pillai's conjecture as a precise mathematical statement and state a testable prediction for $k = 2$.

**Keywords**: Pillai's conjecture, Catalan's conjecture, exponential Diophantine equations, perfect powers, formal verification

## 1. Introduction

### 1.1 Background

Catalan's conjecture (proved by Mihailescu in 2002 [1]) states that the only consecutive perfect powers are 8 = 2³ and 9 = 3². Pillai's conjecture [2] generalizes this: for every positive integer $k$, the equation
$$x^a - y^b = k, \quad x, y, a, b \geq 2$$
has only finitely many solutions. Despite being a natural extension of Catalan's conjecture, Pillai's conjecture remains open. It is implied by the ABC conjecture [3].

### 1.2 Contributions

We contribute:

1. **Formal definitions**: `IsNatPerfectPower`, `PillaiSolution`, and the novel `ExpDiophEq` framework for general exponential Diophantine equations.

2. **Growth bounds**: We prove that gaps between consecutive $e$-th powers grow without bound (Theorem `gaps_grow_unbounded`) and establish the binomial lower bound $(b+1)^e \geq b^e + e \cdot b^{e-1}$ (Theorem `perfectPower_gap_growth`).

3. **Finiteness for equal exponents**: For fixed $e \geq 2$ and $k \geq 1$, we prove that $x^e = y^e + k$ has finitely many solutions with $x, y \geq 2$ (Theorem `pillai_equal_exp_bounded`).

4. **Small-k classification**: Complete resolution of $x^2 - y^2 = k$ for $k = 1, 2, 3, 5$.

5. **Structural results**: Factorization of square differences, base uniqueness for $e$-th powers, exponent bounds, and the trichotomy for perfect powers.

## 2. Definitions

### 2.1 Perfect Powers

**Definition 2.1** (IsNatPerfectPower). A natural number $n$ is a *perfect power* if $n = b^e$ for some $b \geq 2$ and $e \geq 2$.

This is more restrictive than some definitions in the literature (which may allow $b = 0, 1$ or $e = 1$). Our choice ensures that perfect powers are $\geq 4$ (Theorem 3.1).

### 2.2 Pillai Solutions

**Definition 2.2** (PillaiSolution). A *Pillai solution for gap $k$* is a tuple $(x, a, y, b) \in \mathbb{N}^4$ satisfying:
- $x \geq 2$, $a \geq 2$, $y \geq 2$, $b \geq 2$
- $x^a = y^b + k$

### 2.3 Exponential Diophantine Equations

**Definition 2.3** (ExpDiophEq). An *exponential Diophantine equation system* consists of:
- A number of terms $n$
- Integer coefficients $c_1, \ldots, c_n$
- Minimum exponent $e_{\min} \geq 2$ and minimum base $b_{\min} \geq 2$

A *solution* assigns bases $x_i \geq b_{\min}$ and exponents $e_i \geq e_{\min}$ to each term such that
$$\sum_{i=1}^{n} c_i \cdot x_i^{e_i} = 0.$$

This framework unifies Pillai's equation ($c_1 = 1, c_2 = -1$, with an additional constant $k$), Fermat's equation ($x^n + y^n = z^n$), and more general systems.

## 3. Perfect Power Bounds

**Theorem 3.1** (perfectPower_ge_four). If $n$ is a perfect power, then $n \geq 4$.

*Proof sketch*. If $n = b^e$ with $b \geq 2, e \geq 2$, then $n \geq 2^2 = 4$.

**Theorem 3.2** (perfectPower_trichotomy). For any $b$ and $e \geq 2$:
$$b^e = 0 \quad \text{or} \quad b^e = 1 \quad \text{or} \quad b^e \geq 4.$$

**Theorem 3.3** (perfectPower_base_unique). If $b_1^e = b_2^e$ for $e \geq 1$, then $b_1 = b_2$.

*Proof*. The function $x \mapsto x^e$ is injective on $\mathbb{N}$ for $e \geq 1$.

## 4. Gap Growth

### 4.1 Binomial Lower Bound

**Theorem 4.1** (perfectPower_gap_growth). For $b \geq 2$ and $e \geq 2$:
$$(b+1)^e \geq b^e + e \cdot b^{e-1}.$$

*Proof*. By induction on $e$. The base case $e = 2$ is $(b+1)^2 = b^2 + 2b + 1 \geq b^2 + 2b$. The inductive step uses $(b+1)^{e+1} = (b+1)^e \cdot (b+1) \geq (b^e + e \cdot b^{e-1})(b+1)$.

**Theorem 4.2** (power_gap_lower_bound). For $b \geq 2$ and $e \geq 2$:
$$b^e + b^{e-1} < (b+1)^e.$$

This is a corollary of Theorem 4.1, since $e \cdot b^{e-1} \geq 2 \cdot b^{e-1} > b^{e-1}$.

### 4.2 Unbounded Gap Growth

**Theorem 4.3** (gaps_grow_unbounded). For fixed $e \geq 2$ and any $M$, there exists $b_0$ such that for all $b \geq b_0$:
$$(b+1)^e - b^e > M.$$

*Proof*. By Theorem 4.1, $(b+1)^e - b^e \geq e \cdot b^{e-1}$. Since $e \geq 2$ and $b^{e-1} \to \infty$, the bound eventually exceeds $M$.

## 5. Classification of Square Differences

### 5.1 Factorization

**Theorem 5.1** (sq_diff_factorization). If $x^2 = y^2 + k$ with $x > y$, then $(x - y) \mid k$.

*Proof*. $k = x^2 - y^2 = (x-y)(x+y)$, so $x - y$ divides $k$.

**Theorem 5.2** (sq_diff_upper_bound). If $x^2 = y^2 + k$ with $k > 0$ and $x, y \geq 2$, then $x \leq k + y$.

### 5.2 Small k Classification

**Theorem 5.3** (no_sq_diff_one/two/three). For $x, y \geq 2$:
- $x^2 \neq y^2 + 1$
- $x^2 \neq y^2 + 2$
- $x^2 \neq y^2 + 3$

*Proof*. In each case, $x > y$ so $x \geq y + 1$, giving $x^2 \geq y^2 + 2y + 1 \geq y^2 + 5 > y^2 + 3$.

**Theorem 5.4** (sq_diff_five_unique). If $x^2 = y^2 + 5$ with $x, y \geq 2$, then $x = 3$ and $y = 2$.

*Proof*. From $x \geq y + 1$: $x^2 \geq y^2 + 2y + 1$, so $2y + 1 \leq 5$, giving $y \leq 2$. With $y = 2$: $x^2 = 9$, so $x = 3$.

### 5.3 Consecutive Squares

**Theorem 5.5** (no_consecutive_perfect_squares). If $n \geq 4$ is a perfect square ($n = a^2$ with $a \geq 2$), then $n + 1$ is not a perfect square.

This follows from the impossibility of $b^2 - a^2 = 1$ with $a, b \geq 2$.

## 6. Finiteness Results

### 6.1 Equal Exponent Case

**Theorem 6.1** (pillai_equal_exp_bounded). For fixed $e \geq 2$ and $k \geq 1$, there exists $B$ such that every solution to $x^e = y^e + k$ with $x, y \geq 2$ satisfies $x \leq B$ and $y \leq B$.

*Proof*. By `gaps_grow_unbounded`, there exists $y_0$ such that for $y \geq y_0$, $(y+1)^e - y^e > k$. If $x^e = y^e + k$ with $y \geq y_0$, then since $x > y$ (by `pillai_equal_exp_x_gt_y`), we have $x \geq y + 1$, so $(y+1)^e \leq x^e = y^e + k$, contradicting $(y+1)^e > y^e + k$. Thus $y < y_0$. The bound on $x$ follows from $x \leq y + k$.

### 6.2 Square-Square Case

**Theorem 6.2** (pillai_sq_sq_bounded). For $k \geq 1$, there exists $B$ such that $x^2 = y^2 + k$ with $x, y \geq 2$ implies $x \leq B$.

### 6.3 Consecutive Power Gaps

**Theorem 6.3** (consecutive_power_gap_bounded). For $a \geq 2$ and $k \geq 1$, there exists $B$ such that $(b+1)^a = b^a + k$ with $b \geq 2$ implies $b \leq B$.

### 6.4 Exponent Bounds

**Theorem 6.4** (exponent_bound_from_base). If $x^a \leq k + 4$ with $x \geq 2$ and $a \geq 2$, then $a \leq k + 2$.

*Proof*. If $a \geq k + 3$, then $x^a \geq 2^{k+3} > k + 4$ (provable by induction: $2^n > n + 2$ for $n \geq 3$).

### 6.5 Uniqueness

**Theorem 6.5** (pillai_y_determines_x). For fixed exponents $a, b \geq 2$ and gap $k$, if $x_1^a = y^b + k$ and $x_2^a = y^b + k$, then $x_1 = x_2$.

## 7. Pillai's Conjecture

### 7.1 Formal Statement

**Conjecture** (PillaiConjecture). For every $k \geq 1$, there exists $B$ such that every solution to $x^a = y^b + k$ with $x, a, y, b \geq 2$ satisfies $x, y, a, b \leq B$.

### 7.2 Partial Results

Our Theorem 6.1 proves Pillai's conjecture restricted to equal exponents. The full conjecture, where exponents can differ, remains open and is implied by the ABC conjecture.

### 7.3 Testable Prediction

**Conjecture** (PillaiK2Conjecture). The equation $x^a - y^b = 2$ with $x, y, a, b \geq 2$ has the unique solution $(x, a, y, b) = (3, 3, 5, 2)$.

This can be computationally tested: exhaustive search up to $x, y \leq 10^6$ and $a, b \leq 100$ should find no additional solutions.

## 8. Algorithms

### 8.1 Exhaustive Search

We implement an exhaustive search algorithm for Pillai solutions. For each gap $k$:
1. Enumerate all perfect powers $b^e$ up to a bound.
2. Store in a hash table keyed by value.
3. For each power $p$, check if $p - k$ is also a perfect power.

Time complexity: $O(B^{1/2} \cdot \log B)$ where $B$ is the search bound.

### 8.2 Gap Bound Computation

For fixed exponent $e$ and gap $k$, the effective bound $b_0$ (smallest $b$ such that $(b+1)^e - b^e > k$) can be computed by solving $e \cdot b^{e-1} \approx k$, giving $b_0 \approx (k/e)^{1/(e-1)}$.

## 9. Computational Results

| k | Solutions found (up to base 200) |
|---|---|
| 1 | (3,2,2,3) — Catalan's theorem |
| 2 | (3,3,5,2) |
| 3 | (2,7,5,3) |
| 4 | (2,3,2,2), (5,3,11,2), (6,2,2,5) |
| 5 | (2,5,3,3), (3,2,2,2) |
| 6 | none |
| 7 | (2,4,3,2), (2,5,5,2), (2,7,11,2), (2,15,181,2), ... |
| 8 | (2,4,2,3), (4,2,2,3) |
| 9 | (5,2,2,4), (5,2,4,2), (6,2,3,3), (15,2,6,3) |
| 10 | (13,3,3,7) |

## 10. Discussion

### 10.1 The Equal vs. Mixed Exponent Barrier

Our proof of finiteness for equal exponents relies on the monotone growth of gaps between consecutive $e$-th powers. For mixed exponents, this argument fails because $y^b + k$ need not lie between consecutive $a$-th powers in a useful way.

The mixed-exponent case requires fundamentally different techniques, likely involving:
- Baker's theory of linear forms in logarithms
- The ABC conjecture or p-adic methods
- Techniques from the proof of Catalan's conjecture

### 10.2 The ExpDiophEq Framework

Our `ExpDiophEq` structure provides a unified framework for studying:
- Pillai's equation: $x^a - y^b = k$
- Fermat's equation: $x^n + y^n = z^n$
- Generalized Ramanujan-Nagell: $x^2 + D = y^n$
- S-unit equations

This framework could serve as a foundation for formalizing further results in exponential Diophantine equations.

## 11. Future Work

1. **Mixed exponents**: Prove finiteness for $x^a = y^b + k$ when $a \neq b$, possibly using formalized Baker-type bounds.
2. **Effective bounds**: Compute explicit bounds $B(k)$ using linear forms in logarithms.
3. **Connection to ABC**: Formalize the implication ABC ⟹ Pillai.
4. **Higher-dimensional analogs**: Study $x_1^{a_1} + x_2^{a_2} + \cdots + x_n^{a_n} = 0$.

## References

[1] P. Mihailescu, "Primary Cyclotomic Units and a Proof of Catalan's Conjecture," *J. Reine Angew. Math.*, 572 (2004), 167–195.

[2] S.S. Pillai, "On the equation $2^x - 3^y = 2^X + 3^Y$," *Bull. Calcutta Math. Soc.*, 37 (1945), 15–20.

[3] J. Oesterlé, "Nouvelles approches du 'théorème' de Fermat," *Séminaire Bourbaki*, exp. 694 (1988).

[4] T. Shorey and R. Tijdeman, *Exponential Diophantine Equations*, Cambridge University Press, 1986.

[5] Y. Bilu, "Catalan's Conjecture (After Mihailescu)," *Séminaire Bourbaki*, exp. 909 (2003).
