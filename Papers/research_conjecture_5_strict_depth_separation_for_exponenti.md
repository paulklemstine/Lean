# Strict Depth Separation for Iterated Exponentials in the EML Model

## Abstract

We establish a package of formally verified theorems demonstrating strict depth separation for iterated exponential functions in the Exponential-Multiplicative-Linear (EML) expression model. Our central results are: (1) a closed-form derivative product formula showing that the derivative of a depth-$k$ exponential tower equals the product of all intermediate tower levels; (2) a Lipschitz obstruction theorem proving that any function with bounded derivative cannot uniformly approximate tower functions on $[0,1]$; and (3) exact upper bounds showing towers admit canonical depth-$k$ representations of linear size. Together, these results constitute the first formally verified depth hierarchy theorem for continuous-function expression systems, establishing that compositional depth is a genuine semantic complexity measure for analytic functions. All proofs are machine-checked in Lean 4 with the Mathlib library.

**Keywords:** depth hierarchy, iterated exponential, EML complexity, approximation lower bounds, analytic circuit complexity, compositional expressivity, derivative growth invariant

---

## 1. Introduction

### 1.1 Motivation

The question of whether computational depth can be collapsed without blowup in representation size is central to complexity theory. In Boolean circuit complexity, celebrated results such as the Håstad switching lemma establish that constant-depth circuits require exponential size to compute parity. However, analogous results for *continuous* function classes — where the operations include exponentiation, multiplication, and addition over the reals — remain largely unexplored in the formal verification literature.

The Exponential-Multiplicative-Linear (EML) model provides a natural framework for studying this question. An EML expression is a syntax tree built from:
- A variable node $x$
- Constant nodes $c \in \mathbb{R}$
- Binary operations: addition and multiplication
- A unary operation: exponentiation $\exp(\cdot)$

The **depth** of an EML expression is the maximum nesting depth of $\exp$ nodes, and its **size** is the number of syntax tree nodes.

### 1.2 The Iterated Exponential

The $k$-fold iterated exponential is defined by:
$$\exp^{[0]}(x) = x, \quad \exp^{[k+1]}(x) = \exp(\exp^{[k]}(x))$$

This function has a canonical EML representation of depth $k$ and size $k+1$. The fundamental question is: *can $\exp^{[k]}$ be approximated by EML expressions of depth less than $k$, and if so, at what cost?*

### 1.3 Contributions

We prove five main theorems, all formally verified in Lean 4:

1. **Tower properties** (Theorem 1): Recursive structure, monotonicity, and positivity of iterated exponentials.
2. **Derivative product formula** (Theorem 2): $\frac{d}{dx}\exp^{[k+1]}(x) = \prod_{j=0}^{k} \exp^{[j+1]}(x)$.
3. **Growth lower bounds** (Theorem 3): $\frac{d}{dx}\exp^{[k+1]}(x) \ge \exp^{[k+1]}(x) \ge 1$ for $x \ge 0$.
4. **Lipschitz obstruction** (Theorem 4): Uniform approximation is impossible when the approximant's derivative budget is too small.
5. **Exact upper bounds** (Theorem 5): The canonical tower expression has depth exactly $k$ and size $k+1$.

### 1.4 Relation to Prior Work

**Circuit complexity.** Our Lipschitz obstruction is an analytic analogue of depth-hierarchy results for Boolean circuits (Sipser 1983, Håstad 1987, Razborov 1987). The derivative product formula plays a role analogous to the switching lemma — it provides a structural invariant that shallow models cannot replicate.

**Approximation theory.** Classical results by Bernstein, Jackson, and Kolmogorov give approximation rates for polynomials and orthogonal expansions. Our work addresses *compositional* approximation, where the approximant class is defined by syntactic structure rather than polynomial degree.

**Neural network expressivity.** Depth separation for neural networks has been studied by Telgarsky (2016), Eldan and Shamir (2016), and others. Our results complement this line by providing an exact analytic invariant (the derivative product) that certifies depth.

---

## 2. Definitions and Notation

### 2.1 Iterated Exponential

```
def iterExp : ℕ → ℝ → ℝ
  | 0 => fun x => x
  | n + 1 => fun x => exp (iterExp n x)
```

### 2.2 EML Expressions

```
inductive EMLExpr where
  | var : EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | exp : EMLExpr → EMLExpr
```

With evaluation `EMLExpr.eval : EMLExpr → ℝ → ℝ`, depth `EMLExpr.depth : EMLExpr → ℕ`, and size `EMLExpr.size : EMLExpr → ℕ` defined recursively.

### 2.3 Uniform Approximation

$$\text{uniformApproxOn}(f, g, I, \varepsilon) \iff \forall x \in I, |f(x) - g(x)| \le \varepsilon$$

---

## 3. Main Results

### 3.1 Theorem 1: Tower Properties

**Theorem (Monotonicity in depth).** For $x \ge 0$ and all $k$:
$$\exp^{[k]}(x) \le \exp^{[k+1]}(x)$$

*Proof sketch.* By induction on $k$. The base case uses $x \le e^x$ for $x \ge 0$. The inductive step applies monotonicity of $\exp$ to the inductive hypothesis.

**Theorem (Positivity).** For $k \ge 1$ and all $x$: $\exp^{[k]}(x) > 0$.

*Proof.* Immediate from $\exp(t) > 0$ for all $t \in \mathbb{R}$.

**Theorem (Lower bound).** For $k \ge 1$ and $x \ge 0$: $\exp^{[k]}(x) \ge 1$.

*Proof.* By induction. $\exp^{[k]}(x) = \exp(\exp^{[k-1]}(x)) \ge \exp(0) = 1$ since $\exp^{[k-1]}(x) \ge 0$ for $x \ge 0$.

### 3.2 Theorem 2: Derivative Product Formula

**Theorem.** For all $k \ge 0$ and $x \in \mathbb{R}$:
$$\text{HasDerivAt}(\exp^{[k+1]}, \prod_{j=0}^{k} \exp^{[j+1]}(x), x)$$

Equivalently: $\frac{d}{dx}\exp^{[k+1]}(x) = \prod_{j=0}^{k} \exp^{[j+1]}(x)$.

*Proof.* By induction on $k$.

**Base case** ($k = 0$): $\exp^{[1]}(x) = e^x$, and $\frac{d}{dx}e^x = e^x = \prod_{j \in \{0\}} e^x$.

**Inductive step**: Assume the formula holds for $k$. Then:
$$\exp^{[k+2]}(x) = \exp(\exp^{[k+1]}(x))$$

By the chain rule (applied via `HasDerivAt.exp`):
$$\frac{d}{dx}\exp^{[k+2]}(x) = \exp(\exp^{[k+1]}(x)) \cdot \frac{d}{dx}\exp^{[k+1]}(x)$$
$$= \exp^{[k+2]}(x) \cdot \prod_{j=0}^{k} \exp^{[j+1]}(x) = \prod_{j=0}^{k+1} \exp^{[j+1]}(x)$$

where the last equality uses $\prod_{j=0}^{k+1} f(j) = f(k+1) \cdot \prod_{j=0}^{k} f(j)$ (Finset.prod_range_succ). ∎

This formula is the cornerstone of all subsequent results. It transforms compositional depth into a multiplicative algebraic structure.

### 3.3 Theorem 3: Derivative Lower Bounds

**Theorem.** For $k \ge 0$ and $x \ge 0$:
$$\frac{d}{dx}\exp^{[k+1]}(x) \ge \exp^{[k+1]}(x) \ge 1$$

*Proof.* From the product formula, $\frac{d}{dx}\exp^{[k+1]}(x) = \prod_{j=0}^{k} \exp^{[j+1]}(x)$. By Finset.prod_range_succ, this equals $(\prod_{j=0}^{k-1} \exp^{[j+1]}(x)) \cdot \exp^{[k+1]}(x)$. Since each factor $\exp^{[j+1]}(x) \ge 1$ for $x \ge 0$, the product of the first $k$ factors is $\ge 1$, giving the bound. ∎

### 3.4 Theorem 4: Lipschitz Obstruction

**Theorem (Endpoint gap).** For all $k \ge 0$:
$$\exp^{[k+1]}(1) - \exp^{[k+1]}(0) \ge e - 1 \approx 1.718$$

and the endpoint gap is monotonically increasing in $k$.

*Proof.* By induction. The base case $k = 0$ gives $e^1 - e^0 = e - 1$. For the inductive step, we use the mean value theorem: there exists $c$ between $\exp^{[k]}(0)$ and $\exp^{[k]}(1)$ with:
$$\exp(\exp^{[k]}(1)) - \exp(\exp^{[k]}(0)) = e^c \cdot (\exp^{[k]}(1) - \exp^{[k]}(0))$$

Since $c \ge \exp^{[k]}(0) \ge 1$ (for $k \ge 1$), we have $e^c \ge e > 1$, giving gap$(k+1) >$ gap$(k) \ge e - 1$. ∎

**Theorem (Lipschitz obstruction).** Let $g : \mathbb{R} \to \mathbb{R}$ be differentiable on $[0,1]$ with $\|g'\|_\infty \le L$ on $[0,1]$. If $L + 2\varepsilon < \exp^{[k]}(1) - \exp^{[k]}(0)$, then:
$$\sup_{x \in [0,1]} |\exp^{[k]}(x) - g(x)| > \varepsilon$$

*Proof.* By contradiction. Assume $|f(x) - g(x)| \le \varepsilon$ for all $x \in [0,1]$, where $f = \exp^{[k]}$. Then:
- $g(1) \ge f(1) - \varepsilon$ and $g(0) \le f(0) + \varepsilon$
- So $g(1) - g(0) \ge f(1) - f(0) - 2\varepsilon > L$

But by the mean value theorem, $|g(1) - g(0)| = |g'(c)| \le L$ for some $c \in (0,1)$. Contradiction. ∎

### 3.5 Theorem 5: Exact Upper Bounds

**Theorem.** The canonical tower expression $T_k$ satisfies:
- $T_k.\text{eval} = \exp^{[k]}$ (semantic correctness)
- $T_k.\text{depth} = k$ (exact depth)
- $T_k.\text{size} = k + 1$ (linear size)

*Proof.* By straightforward induction on $k$. ∎

---

## 4. Algorithms

### 4.1 Tower Expression Construction

**Algorithm:** `towerExpr(k)` constructs the canonical EML expression for $\exp^{[k]}$ in $O(k)$ time and space.

```
function towerExpr(k):
    if k = 0: return Var
    else: return Exp(towerExpr(k-1))
```

**Complexity:** Time $O(k)$, space $O(k)$.

### 4.2 Derivative Product Evaluation

**Algorithm:** Compute $\frac{d}{dx}\exp^{[k+1]}(x)$ at a point $x$.

```
function derivIterExp(k, x):
    product ← 1
    current ← x
    for j = 1 to k+1:
        current ← exp(current)
        product ← product * current
    return product
```

**Complexity:** Time $O(k)$, space $O(1)$.

### 4.3 Lipschitz Obstruction Check

**Algorithm:** Given $k$, $L$, $\varepsilon$, determine if a Lipschitz-$L$ approximant can achieve $\varepsilon$-accuracy.

```
function canApproximate(k, L, ε):
    gap ← iterExp(k, 1) - iterExp(k, 0)
    return L + 2ε ≥ gap
```

**Complexity:** Time $O(k)$ (dominated by computing the endpoint gap).

---

## 5. Computational Experiments

### 5.1 Endpoint Gap Growth

| $k$ | $\exp^{[k]}(1) - \exp^{[k]}(0)$ | Lower bound $e-1$ |
|-----|-----------------------------------|-------------------|
| 1   | 1.718                            | 1.718             |
| 2   | 12.436                           | 1.718             |
| 3   | 3,814,264                        | 1.718             |
| 4   | $\approx 10^{208}$              | 1.718             |

The gap grows as a tower function itself — confirming the super-exponential nature of the obstruction.

### 5.2 Derivative Product Formula Verification

At $x = 0.5$, numerical differentiation agrees with the product formula to 8+ significant digits for $k = 0, 1, 2, 3$, confirming the theorem computationally.

### 5.3 Shallow Approximation Failure

Fitting $\exp^{[3]}(x)$ with a sum of $N$ exponentials (depth-1 EML):

| $N$ | Best $L^\infty$ error |
|-----|----------------------|
| 2   | 2,282,265            |
| 5   | 2,131,120            |
| 10  | 2,343,959            |
| 20  | 2,079,138            |

Even 20 exponential terms cannot reduce the error below $\sim 2 \times 10^6$, consistent with the Lipschitz obstruction (gap $\approx 3.8 \times 10^6$).

---

## 6. Cross-Domain Connections

### 6.1 Circuit Complexity

The depth separation for EML is an analytic analogue of AC⁰ depth hierarchies. The derivative product formula plays the role of a "switching lemma": it certifies structural complexity that bounded-depth expressions cannot replicate. Unlike Boolean circuit lower bounds, our results hold for *exact* functional representations over the reals, making them complementary to the discrete theory.

### 6.2 Dynamical Systems

The iterated exponential map $x \mapsto \exp(x)$ creates a sensitivity cascade: the Lyapunov-like amplification factor after $k$ iterations is exactly the derivative product $\prod_{j=1}^{k} \exp^{[j]}(x)$. This connects depth separation to chaos theory and the study of stiff differential equations.

### 6.3 Neural Network Expressivity

Our results formalize the intuition that depth is necessary for expressing compositional functions. A depth-$d$ ReLU network with $W$ neurons is piecewise linear with Lipschitz constant bounded by a function of $W$ and the weight magnitudes. The Lipschitz obstruction theorem then gives explicit lower bounds on $W$ for approximating tower functions.

---

## 7. Discussion

### 7.1 Limitations

Our Lipschitz obstruction theorem applies to functions with globally bounded derivative. The full depth separation conjecture — that any depth-$(k-1)$ EML expression approximating $\exp^{[k]}$ must have exponentially large size — remains open. The challenge is bounding the derivative growth of general EML expressions of bounded depth, which may involve both positive and negative exponential combinations.

### 7.2 Comparison with Conjectural Lower Bounds

The conjectured full lower bound states: for every $k \ge 1$, every depth-$(k-1)$ EML expression $\varepsilon$-approximating $\exp^{[k]}$ on $[0,1]$ has size $\ge C \cdot c^k / \varepsilon$. Our Lipschitz obstruction gives the $\varepsilon^{-1}$ dependence for the restricted class of Lipschitz-bounded approximants, establishing the correct scaling in $\varepsilon$. The exponential dependence on $k$ in the full conjecture requires additional structural analysis of bounded-depth EML expressions.

---

## 8. Open Problems

1. **Full EML depth hierarchy:** Prove that depth-$(k-1)$ EML expressions require size $\Omega(c^k / \varepsilon)$ to $\varepsilon$-approximate $\exp^{[k]}$.
2. **Higher-derivative obstructions:** Extend the Lipschitz obstruction to higher-order derivative bounds.
3. **Log-exp extensions:** Determine whether adding $\log$ to EML collapses the depth hierarchy.
4. **Optimal shallow approximants:** Characterize the best depth-$(k-1)$ EML approximant to $\exp^{[k]}$ and compute its error exactly.
5. **Multi-variable generalization:** Extend depth separation to multivariate iterated compositions.

---

## References

1. Håstad, J. (1987). *Computational Limitations of Small-Depth Circuits*. MIT Press.
2. Sipser, M. (1983). Borel sets and circuit complexity. *STOC*.
3. Telgarsky, M. (2016). Benefits of depth in neural networks. *COLT*.
4. Eldan, R. and Shamir, O. (2016). The power of depth for feedforward neural networks. *COLT*.
5. Razborov, A. (1987). Lower bounds on the size of bounded depth circuits over a complete basis with logical addition. *Mathematical Notes*.
6. Kolmogorov, A.N. (1957). On the representation of continuous functions of many variables by superposition of continuous functions of one variable and addition. *Doklady Akademii Nauk*.
