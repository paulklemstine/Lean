# Tropical Contraction Theory for the Collatz Iteration: A Formally Verified Framework

## Abstract

We develop a rigorous tropical (min-plus) contraction framework for the Collatz iteration, lifting the standard map $n \mapsto n/2$ (even) or $n \mapsto 3n+1$ (odd) to logarithmic coordinates where it becomes a discounted Bellman operator on the complete metric space of bounded functions $\mathbb{N} \to_b \mathbb{R}$. We prove that both Collatz branches are isometries in log-coordinates, that the min-plus envelope is nonexpansive, and that discounting yields a genuine contraction mapping with factor $\gamma < 1$. By the Banach fixed-point theorem, the operator admits a unique fixed point — the tropical value function — and Picard iteration converges to it geometrically. We establish a conditional convergence architecture: logarithmic contraction with ratio $c < 1$ implies strict arithmetic descent, which combined with finite verification yields convergence of all orbits to 1. All results are machine-verified in Lean 4 with Mathlib.

**Keywords:** Collatz conjecture, tropical geometry, Bellman equation, contraction mapping, formal verification, dynamical systems

---

## 1. Introduction

The Collatz conjecture asserts that the iteration
$$
T(n) = \begin{cases} n/2 & \text{if } n \equiv 0 \pmod{2} \\ 3n+1 & \text{if } n \equiv 1 \pmod{2} \end{cases}
$$
eventually reaches 1 for every positive integer $n$. Despite extensive computational verification (up to $\sim 10^{20}$) and partial theoretical results — notably Terras (1976) on density-one convergence and Tao (2019) on almost-all convergence in a logarithmic density sense — the conjecture remains open.

This paper develops a new structural framework based on tropical (min-plus) algebra and the Banach contraction principle. The central observation is that in logarithmic coordinates, the Collatz branches become *isometric translations*, and the dynamics of choosing between branches can be encoded as a *min-plus Bellman operator*. With discounting, this operator contracts the sup-norm, yielding a unique fixed point by Banach's theorem.

The framework produces a clean conditional reduction: if a logarithmic contraction condition holds above a finite threshold, the Collatz conjecture follows. All results are formalized in Lean 4.

### 1.1 Overview of Results

The results are organized across two formal modules:

- **`Catalog/Computation/CollatzTropical.lean`**: Collatz map definitions, arithmetic contraction lemmas, logarithmic branch analysis, conditional convergence theorems, and the architectural reduction from log-contraction to orbit convergence.
- **`Catalog/Computation/CollatzTropicalContraction.lean`**: Branch isometries, min-plus contraction algebra, Bellman operator construction on $\ell^\infty(\mathbb{N})$, contraction mapping property, fixed-point existence/uniqueness, and Picard iteration convergence.

### 1.2 Related Work

**Terras (1976)** showed that a density-one set of integers eventually reaches a value smaller than their starting point. **Korec (1994)** extended this to show orbits grow slower than $n^c$ for any $c > \log_2 3$. **Tao (2019)** proved that almost all Collatz orbits attain almost-bounded values, using logarithmic density and entropy methods. **Conway (1972)** showed that generalized Collatz systems are Turing-complete, implying the conjecture cannot be resolved by purely local methods.

Our framework complements these by providing an *operator-theoretic* structure: rather than analyzing individual orbits, we study the Collatz dynamics as a contraction on function space.

---

## 2. Definitions and Basic Properties

### 2.1 The Collatz Map

We define the standard Collatz map and its accelerated variant:

**Definition 2.1** (Collatz Map). For $n \in \mathbb{N}$,
$$T(n) = \begin{cases} n/2 & n \equiv 0 \pmod{2} \\ 3n+1 & n \equiv 1 \pmod{2} \end{cases}$$

**Definition 2.2** (Accelerated Odd Map). $T_{\text{odd}}(n) = \lfloor(3n+1)/2\rfloor$.

See `CollatzTropical.collatz` and `CollatzTropical.collatzOdd` in `Catalog/Computation/CollatzTropical.lean`.

**Theorem 2.3** (Fundamental Cycle). The sequence $1 \to 4 \to 2 \to 1$ is a 3-cycle of $T$, and 1 is not a fixed point.

*Formal reference:* `collatz_cycle` in `Catalog/Computation/CollatzTropical.lean`.

### 2.2 Logarithmic Potential

**Definition 2.4** (Log-Potential). The *tropical coordinate* of $n$ is $\phi(n) = \log n$.

See `CollatzTropical.logPotential` in `Catalog/Computation/CollatzTropical.lean`.

### 2.3 Branch Maps in Log-Coordinates

**Definition 2.5** (Branch Maps).
- Even branch: $\beta_E(x) = x - \log 2$
- Odd branch: $\beta_O(x) = x + \log 3 - \log 2$

See `CollatzTropicalContraction.branchEven` and `CollatzTropicalContraction.branchOdd` in `Catalog/Computation/CollatzTropicalContraction.lean`.

---

## 3. Branch Isometry and Nonexpansiveness

### 3.1 Isometry of Individual Branches

**Theorem 3.1** (Branch Isometry). Both Collatz branches are isometries in log-coordinates:
$$d(\beta_E(x), \beta_E(y)) = d(x, y), \quad d(\beta_O(x), \beta_O(y)) = d(x, y)$$

*Proof sketch.* Both branches are translations by constants ($-\log 2$ and $\log(3/2)$ respectively). Translations are isometries in any normed space. $\square$

*Formal reference:* `collatz_branchEven_isometry` and `collatz_branchOdd_isometry` in `Catalog/Computation/CollatzTropicalContraction.lean`.

**Corollary 3.2** (Nonexpansiveness). For any branch $b \in \{E, O\}$ and any $x, y \in \mathbb{R}$:
$$d(\beta_b(x), \beta_b(y)) \leq d(x, y)$$

*Formal reference:* `collatz_branch_nonexpansive` in `Catalog/Computation/CollatzTropicalContraction.lean`.

### 3.2 Logarithmic Branch Analysis

**Theorem 3.3** (Even Branch Identity). For $n \geq 2$ even:
$$\phi(T(n)) = \phi(n) - \log 2$$

This is *exact*, not an inequality.

*Formal reference:* `collatz_log_even` in `Catalog/Computation/CollatzTropical.lean`.

**Theorem 3.4** (Odd Branch Majorization). For $n \geq 1$ odd:
$$\phi(T(n)) \leq \phi(n) + \log 4$$

*Formal reference:* `collatz_log_odd_upper_coarse` in `Catalog/Computation/CollatzTropical.lean`.

**Theorem 3.5** (Two-Step Bound). For $n \geq 1$ odd:
$$\phi(T(T(n))) \leq \phi(n) + \log 2$$

*Proof sketch.* Two Collatz steps from an odd number yield $(3n+1)/2 \leq 2n$. Taking logarithms: $\log((3n+1)/2) \leq \log(2n) = \log n + \log 2$. $\square$

*Formal reference:* `collatz_two_step_log_bound` in `Catalog/Computation/CollatzTropical.lean`.

---

## 4. Arithmetic Contraction Lemmas

### 4.1 The 4-Divisibility Contraction

**Theorem 4.1** (Strict Contraction under 4-Divisibility). For $n \geq 2$, if $4 \mid (3n+1)$, then $(3n+1)/4 < n$.

*Formal reference:* `odd_branch_contracts_if_four_dvd` in `Catalog/Computation/CollatzTropical.lean`.

**Theorem 4.2** (Favorable Residue Class). If $n \equiv 1 \pmod{4}$, then $4 \mid (3n+1)$.

*Proof sketch.* $3 \cdot 1 + 1 = 4 \equiv 0 \pmod{4}$, and reducing $3n + 1 \pmod{4}$ for $n \equiv 1$ gives 0. $\square$

*Formal reference:* `four_dvd_of_one_mod_four` in `Catalog/Computation/CollatzTropical.lean`.

### 4.2 Coarse Growth Bound

**Theorem 4.3** (Accelerated Map Growth). For $n \geq 1$: $T_{\text{odd}}(n) \leq 2n$.

*Formal reference:* `collatzOdd_le_two_mul` in `Catalog/Computation/CollatzTropical.lean`.

---

## 5. Min-Plus Contraction Algebra

### 5.1 The Min-Lipschitz Inequality

**Theorem 5.1** (Min-Plus Nonexpansiveness). For all $a, b, c, d \in \mathbb{R}$:
$$|\min(a,b) - \min(c,d)| \leq \max(|a-c|, |b-d|)$$

This is the algebraic foundation of tropical contraction: the min (tropical addition) operation is 1-Lipschitz in the max-norm.

*Formal reference:* `abs_min_sub_min_le` in `Catalog/Computation/CollatzTropicalContraction.lean`.

---

## 6. The Bellman Operator and Its Contraction Property

### 6.1 Definition

**Definition 6.1** (Discounted Collatz Bellman Operator). For discount factor $\gamma \in [0,1)$, branch costs $a, b \in \mathbb{R}$, and bounded function $f : \mathbb{N} \to \mathbb{R}$:
$$(\mathcal{B}_\gamma f)(n) = \gamma \cdot \min\bigl(f(n/2) + a,\; f((3n+1)/2) + b\bigr)$$

See `CollatzTropicalContraction.collatzBellmanFn` in `Catalog/Computation/CollatzTropicalContraction.lean`.

### 6.2 Pointwise Contraction

**Theorem 6.2** (Pointwise Bound). For $\gamma \geq 0$ and bounded functions $f, g$:
$$|(\mathcal{B}_\gamma f)(n) - (\mathcal{B}_\gamma g)(n)| \leq \gamma \cdot \|f - g\|_\infty$$

*Proof sketch.* Factor out $\gamma$, apply the min-Lipschitz inequality (Theorem 5.1), and bound each component difference by the sup-norm distance. $\square$

*Formal reference:* `collatzBellman_pointwise_bound` in `Catalog/Computation/CollatzTropicalContraction.lean`.

### 6.3 Lifting to Bounded Functions

The operator is lifted to the Banach space $\ell^\infty(\mathbb{N}) = (\mathbb{N} \to_b \mathbb{R})$ of bounded functions with the sup-norm topology.

**Theorem 6.3** (Norm Bound). $\|\mathcal{B}_\gamma f\|_\infty \leq |\gamma| \cdot (\|f\|_\infty + \max(|a|, |b|))$.

*Formal reference:* `abs_min_shifted_le` and the construction `collatzBellmanBCF` in `Catalog/Computation/CollatzTropicalContraction.lean`.

### 6.4 The Contraction Mapping Theorem

**Theorem 6.4** (Bellman Contraction). For $0 \leq \gamma < 1$, the operator $\mathcal{B}_\gamma : \ell^\infty(\mathbb{N}) \to \ell^\infty(\mathbb{N})$ is a contraction mapping with Lipschitz constant $\gamma$:
$$d(\mathcal{B}_\gamma f, \mathcal{B}_\gamma g) \leq \gamma \cdot d(f, g)$$

*Formal reference:* `collatzBellmanBCF_contracting` in `Catalog/Computation/CollatzTropicalContraction.lean`.

---

## 7. Fixed-Point Theorems

### 7.1 Existence and Uniqueness

**Theorem 7.1** (Unique Tropical Value Function). For $0 \leq \gamma < 1$, there exists a unique $f^* \in \ell^\infty(\mathbb{N})$ satisfying the Bellman equation:
$$f^*(n) = \gamma \cdot \min\bigl(f^*(n/2) + a,\; f^*((3n+1)/2) + b\bigr) \quad \forall n$$

*Proof.* Direct application of the Banach fixed-point theorem to the contraction $\mathcal{B}_\gamma$ on the complete metric space $\ell^\infty(\mathbb{N})$. $\square$

*Formal references:* `collatzBellman_unique_fixed_point` and `collatzBellman_fixedPoint_eq` in `Catalog/Computation/CollatzTropicalContraction.lean`.

### 7.2 Picard Iteration Convergence

**Theorem 7.2** (Value Iteration Convergence). For any initial $f_0 \in \ell^\infty(\mathbb{N})$:
$$\mathcal{B}_\gamma^k f_0 \xrightarrow{k \to \infty} f^* \quad \text{in } \|\cdot\|_\infty$$

*Formal reference:* `collatzBellman_iterate_converges` in `Catalog/Computation/CollatzTropicalContraction.lean`.

### 7.3 Uniqueness from Contraction (Generic)

**Theorem 7.3** (Unique Fixed Point in Metric Spaces). In any metric space, a contraction mapping has at most one fixed point.

*Formal reference:* `unique_fixed_point_of_contraction` in `Catalog/Computation/CollatzTropical.lean`.

---

## 8. The Architectural Reduction Theorem

### 8.1 From Log-Contraction to Arithmetic Descent

**Theorem 8.1** (Bridge Theorem). Let $T : \mathbb{N} \to \mathbb{N}$ with $T(n) \geq 1$ for $n \geq 1$. If there exists $c < 1$ such that
$$\log T(n) \leq c \cdot \log n \quad \forall n \geq 2,$$
then $T(n) < n$ for all $n \geq 2$.

*Proof sketch.* The hypothesis implies $T(n) \leq n^c$. Since $c < 1$ and $n \geq 2 > 1$, we have $n^c < n$. $\square$

*Formal reference:* `log_contraction_implies_descent` in `Catalog/Computation/CollatzTropical.lean`.

### 8.2 Conditional Convergence

**Theorem 8.2** (Strict Descent Convergence). If $T : \mathbb{N} \to \mathbb{N}$ satisfies $T(n) \geq 1$ for $n \geq 1$ and $T(n) < n$ for $n \geq 2$, then every positive integer eventually reaches 1 under iteration of $T$.

*Proof.* Strong induction on $\mathbb{N}$. For $n = 1$, take $m = 0$. For $n \geq 2$, $T(n) < n$ and $T(n) \geq 1$, so the inductive hypothesis applies. $\square$

*Formal reference:* `convergence_of_strict_descent` in `Catalog/Computation/CollatzTropical.lean`.

**Theorem 8.3** (Eventual Descent Convergence). Let $T, N$ be as above, with $T(n) < n$ for $n \geq N$ and finite verification that all $1 \leq n < N$ reach 1. Then every positive integer reaches 1.

*Formal reference:* `collatz_convergence_of_eventual_descent` in `Catalog/Computation/CollatzTropical.lean`.

### 8.3 The Complete Reduction

**Theorem 8.4** (Architectural Reduction). If there exists an accelerated Collatz operator $T$, a threshold $N$, and a contraction ratio $c < 1$ such that:
1. $T(n) \geq 1$ for $n \geq 1$ (positivity),
2. $\log T(n) \leq c \cdot \log n$ for $n \geq N$ (log-contraction),
3. All $1 \leq n < N$ reach 1 under $T$ (finite verification),

then every positive integer reaches 1 under iteration of $T$.

This composes the bridge theorem (8.1) with eventual descent convergence (8.3) to provide a complete conditional reduction.

*Formal reference:* `collatz_convergence_of_log_contraction` in `Catalog/Computation/CollatzTropical.lean`.

---

## 9. Discussion

### 9.1 Interpretation of the Value Function

The unique fixed point $f^*$ of the Bellman operator is a *tropical value function*: it assigns to each integer $n$ the discounted optimal cost of reaching 1 under the best branch choices. In the Collatz setting, branch choice is deterministic (dictated by parity), but the min-plus formulation allows treating both branches symmetrically and studying the resulting contraction algebraically.

The discount factor $\gamma$ is an artificial regularization parameter. As $\gamma \to 1^-$, the value function should converge to the true Collatz potential (if it exists), but the contraction property degrades ($\gamma \to 1$ destroys strict contraction). Understanding the $\gamma \to 1$ limit is a key open problem. We note that this regularization strategy is standard in dynamic programming: the discounted cost function is always well-defined, while the undiscounted (average-cost) formulation may not converge. The passage from discounted to undiscounted is sometimes possible via Tauberian theorems, which is a promising direction for future work.

The value function $f^*$ has a natural interpretation in terms of *optimal branching strategies*. At each integer $n$, the Bellman equation selects the branch (even or odd) that minimizes the discounted future cost. For the standard Collatz dynamics, this selection is forced by parity, but the tropical formulation generalizes naturally to any Collatz-like system where branch choice is free — such as the "inverse Collatz" problem of constructing orbits that reach a target.

### 9.2 Connection to Tao's Work

Tao (2019) proved that for almost all $n$ (in logarithmic density), $\min_{k \leq K} T^k(n) \leq f(n)$ for any $f$ tending to infinity. His approach uses entropy methods and Syracuse random variables. Our framework offers a complementary perspective: rather than probabilistic averaging over orbits, we construct a deterministic potential function on which the dynamics contracts. The two approaches target different aspects of the same problem — Tao's gives almost-everywhere results; ours gives conditional everywhere results.

The connection runs deeper than this superficial complementarity. Tao's Syracuse random variable model treats the Collatz iteration as a random walk in logarithmic coordinates — precisely the setting where our branch maps become isometric translations. The drift of the random walk is $\mathbb{E}[\log(3/4)] = \log(3) - 2\log(2) \approx -0.288$, which is negative, explaining why "most" orbits contract. Our framework makes this drift manifest as the difference between branch costs $a = -\log 2$ and $b = \log(3/2)$ in the Bellman equation.

A potential synthesis would use the tropical value function to define a *corrected* Collatz potential that accounts for the deterministic deviations from random-walk behavior. The orbits that resist contraction — the "hard cases" for the conjecture — correspond to integers where the value function takes unusually large values, i.e., where the optimal discounted cost of reaching 1 is high.

### 9.3 Connection to Dynamical Systems

The tropical Bellman framework connects naturally to several strands of dynamical systems theory:

**Lyapunov functions.** A Lyapunov function for the Collatz map would be a function $V : \mathbb{N} \to \mathbb{R}$ satisfying $V(T(n)) < V(n)$ for all $n \geq 2$. The logarithmic potential $\phi(n) = \log n$ fails as a Lyapunov function because odd steps increase it. The tropical value function $f^*$ is a candidate for a modified Lyapunov function, though in the discounted setting it satisfies $f^*(n) = \gamma \cdot (\text{branch minimum})$ rather than a strict decrease.

**Transfer operators.** The Bellman operator $\mathcal{B}_\gamma$ is closely related to the *transfer operator* (Ruelle operator) of the Collatz system viewed as a piecewise-affine map. Transfer operators encode the statistical mechanics of dynamical systems; their spectral properties determine mixing rates and invariant measures. The contraction of $\mathcal{B}_\gamma$ corresponds to spectral gap in this language.

**Ergodic theory.** The parity sequence of a Collatz orbit — the binary string recording whether each iterate is odd or even — is a symbolic dynamics encoding. The parity exclusion principle (no consecutive 1s) constrains this symbolic sequence to a shift of finite type. The entropy of this constrained shift is $\log \varphi$ where $\varphi = (1+\sqrt{5})/2$ is the golden ratio, which bounds the combinatorial complexity of Collatz orbits.

### 9.4 The Gap: What Remains

The framework reduces the Collatz conjecture to verifying a logarithmic contraction condition. The obstacle is that the standard Collatz map does not satisfy $\log T(n) \leq c \cdot \log n$ for any fixed $c < 1$ (the odd step can increase the logarithm). What is needed is an *accelerated* operator — perhaps the Syracuse map, or a multi-step composition — for which the contraction holds on average or along subsequences. The tropical value function $f^*$ is the natural candidate for constructing such an operator.

Specifically, three approaches to closing the gap emerge from the framework:

1. **Multi-step acceleration.** Instead of the one-step Collatz map, consider the $k$-step iterated map $T^k$. The two-step bound (Theorem 3.5) shows that odd-then-even pairs increase the potential by at most $\log 2$. If one could show that $k$-step blocks have a net potential decrease for sufficiently large $k$, the framework would apply with the accelerated operator $T^k$.

2. **Weighted contraction.** Replace the uniform contraction condition $\log T(n) \leq c \cdot \log n$ with a weighted version: $\phi(T(n)) \leq \phi(n) - \delta$ for some modified potential $\phi$ and some $\delta > 0$. The tropical value function $f^*$ is the natural candidate for $\phi$.

3. **Probabilistic contraction.** Show that the expected potential decrease over a random initial condition is strictly positive. Combined with concentration inequalities, this could yield convergence for all but a density-zero exceptional set — and then finite verification could handle the exceptions.

### 9.5 Formal Verification Methodology

All results in this paper are formalized in Lean 4 using the Mathlib library. The formalization serves two purposes:

1. **Certainty.** Every theorem is machine-checked, eliminating the possibility of logical errors in the proofs. This is particularly important for conditional results where subtle sign errors or off-by-one mistakes could invalidate the reduction.

2. **Composability.** Formally verified lemmas can be composed mechanically. The Architectural Reduction Theorem (Theorem 8.4) is constructed by composing the Bridge Theorem (8.1) with Eventual Descent Convergence (8.3). In informal mathematics, such compositions are error-prone; in the formal setting, they are guaranteed correct by construction.

The formalization effort revealed several subtleties not apparent in the informal treatment. For example, the even branch identity (Theorem 3.3) requires careful handling of the division $n/2$ and its interaction with the logarithm. The `Nat.cast_div` lemma in Mathlib requires an explicit proof that 2 divides $n$, which connects the logical hypothesis ($n$ is even) with the arithmetic operation (exact division). Such details are invisible in pen-and-paper proofs but essential for formal correctness.

---

## 10. Algorithms

### 10.1 Picard Iteration for Value Function Approximation

**Input:** Discount factor $\gamma \in (0,1)$, branch costs $a, b$, iteration count $K$, domain size $N$.

**Output:** Approximate value function $f_K : \{0, \ldots, N-1\} \to \mathbb{R}$.

```
f ← zero function on {0, ..., N-1}
for k = 1 to K:
    for n = 0 to N-1:
        f_new[n] = γ · min(f[n/2] + a, f[(3n+1)/2] + b)
    f ← f_new
return f
```

The convergence rate is geometric: $\|f_K - f^*\|_\infty \leq \gamma^K \cdot \|f_0 - f^*\|_\infty$.

### 10.2 Contraction Rate Verification

For a given Collatz-like map $T$ and candidate contraction ratio $c$, verify:
$$\max_{2 \leq n \leq N} \frac{\log T(n)}{\log n} \leq c$$

If this holds for sufficiently large $N$ and all orbits below $N$ converge, the Architectural Reduction Theorem applies.

---

## 11. Future Work

1. **Sharp contraction thresholds** via real logarithms: replace the integer condition $2j < k$ (odd density $< 1/2$) with the optimal threshold $j/k < \log 2 / \log 3 \approx 0.6309$.

2. **Spectral analysis** of the tropical value function: decompose $f^*$ into eigenmodes of the Bellman operator to extract the dominant contraction rate.

3. **Transfinite orbit measures**: construct ordinal-valued Lyapunov functions below $\varepsilon_0$, connecting to Goodstein-type independence phenomena.

4. **Undiscounted limits**: study the behavior of $f^*_\gamma$ as $\gamma \to 1^-$ and determine whether a limiting potential exists.

5. **Generalized Collatz systems**: extend the framework to Conway's $(m, d, r_0, \ldots, r_{m-1})$ systems, leveraging the GCS encoding for computability-theoretic connections.

---

## References

1. Collatz, L. (1937). Unpublished problem.
2. Conway, J. H. (1972). Unpredictable iterations. *Proc. 1972 Number Theory Conf.*, 49–52.
3. Terras, R. (1976). A stopping time problem on the positive integers. *Acta Arithmetica*, 30(3), 241–252.
4. Korec, I. (1994). A density estimate for the 3x+1 problem. *Math. Slovaca*, 44(1), 85–89.
5. Tao, T. (2019). Almost all orbits of the Collatz map attain almost bounded values. *arXiv:1909.03562*.
6. Banach, S. (1922). Sur les opérations dans les ensembles abstraits et leur application aux équations intégrales. *Fund. Math.*, 3, 133–181.
7. Lagarias, J. C. (2010). *The Ultimate Challenge: The 3x+1 Problem*. AMS.

---

*All theorems referenced in this paper are formally verified in Lean 4 with Mathlib. See `Catalog/Computation/CollatzTropical.lean` and `Catalog/Computation/CollatzTropicalContraction.lean` for complete machine-checked proofs.*
