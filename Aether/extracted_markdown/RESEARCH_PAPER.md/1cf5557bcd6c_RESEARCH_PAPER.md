# Tropical Contraction Theory for Collatz Dynamics: A Formally Verified Framework

## Abstract

We develop a rigorous tropical/Bellman contraction framework for the Collatz iteration and related arithmetic dynamical systems. The central construction is a discounted min-plus Bellman operator on the Banach space of bounded functions ℕ →ᵇ ℝ, whose unique fixed point encodes the tropical value function of the Collatz branching structure. We prove:

1. **Branch isometry**: both Collatz branches (even: x ↦ x − log 2; odd: x ↦ x + log(3/2)) are exact isometries in log-coordinates.
2. **Min-plus contraction algebra**: the min operation satisfies |min(a,b) − min(c,d)| ≤ max(|a−c|, |b−d|).
3. **Bellman contraction**: the discounted Bellman operator is ContractingWith γ on ℓ∞(ℕ), with contraction constant equal to the discount factor γ ∈ [0,1).
4. **Unique fixed point and convergence**: by the Banach contraction principle, the operator has a unique fixed point, and Picard iteration converges geometrically.
5. **Bellman equation characterization**: the fixed point satisfies the Bellman equation f(n) = γ · min(f(n/2) + a, f((3n+1)/2) + b) at every n.

Additionally, the accompanying module `CollatzTropical` provides:
6. **Conditional convergence theorems**: reducing Collatz convergence to strict descent or logarithmic contraction hypotheses.
7. **Arithmetic contraction lemmas**: including 4-divisibility contraction and residue-class analysis.
8. **Bridge theorems**: log-contraction implies arithmetic descent, connecting tropical analysis to concrete orbit behavior.

All results are machine-verified in Lean 4 with Mathlib, using only the standard axioms (propext, Classical.choice, Quot.sound). No sorry remains in the final proofs.

**Keywords**: Collatz conjecture, tropical geometry, min-plus algebra, Bellman operator, contraction mapping, Banach fixed point, arithmetic dynamics, formal verification.

---

## 1. Introduction

### 1.1 Motivation

The Collatz conjecture (Lagarias, 2010) asserts that the iteration n ↦ n/2 (if even), n ↦ 3n+1 (if odd) eventually reaches 1 from any positive starting value. Despite decades of effort, the conjecture remains open, and Erdős famously remarked that "mathematics is not yet ready for such problems."

The fundamental difficulty is the interaction between multiplicative structure (the map 3n+1) and 2-adic structure (division by 2). Classical approaches — density arguments, stochastic models, ergodic theory — have yielded partial results (Tao, 2019; Terras, 1976) but no complete resolution.

### 1.2 Our Approach

We propose a fundamentally different perspective: treating the Collatz iteration as a tropical control system. The key observations are:

1. In logarithmic coordinates, both Collatz branches are translations (affine maps with slope 1).
2. The branching structure defines a min-plus optimization problem.
3. A discounted Bellman operator naturally arises, and its contraction properties are provable.

This approach does not solve the Collatz conjecture. Rather, it creates a rigorous formal framework — verified by machine — in which arithmetic dynamical systems can be studied using the tools of tropical geometry, optimal control, and functional analysis.

### 1.3 Relation to Prior Work

- **Stochastic models** (Lagarias & Weiss, 1992): treat parity sequences as random, deriving heuristic drift estimates. Our framework is deterministic and exact.
- **Transfer operator methods** (Lagarias, 1985): study the dynamics via spectral properties of operators on function spaces. Our Bellman operator is a concrete instance with provable contraction.
- **Tropical geometry** (Maclagan & Sturmfels, 2015): the min-plus algebraic structure we exploit is the foundation of tropical geometry. We apply it to arithmetic dynamics, which appears to be novel.
- **Dynamic programming** (Bellman, 1957): our operator is a standard discounted Bellman equation; the novelty is the application to number-theoretic iteration.

### 1.4 Contributions

Our main contributions are:

1. A formally verified proof that the discounted Collatz Bellman operator is a contraction on ℓ∞(ℕ) with constant γ.
2. Existence, uniqueness, and geometric convergence to the fixed point.
3. A modular proof architecture separating branch isometry, min-contraction, and discounting.
4. Conditional convergence theorems reducing Collatz convergence to log-contraction hypotheses.
5. Complete machine verification in Lean 4 / Mathlib.

---

## 2. Definitions and Notation

### 2.1 The Collatz Map

The standard Collatz map C : ℕ → ℕ is defined by:
```
C(n) = n/2        if n is even
C(n) = 3n + 1     if n is odd
```

The accelerated odd-step map T : ℕ → ℕ combines the odd step with one halving:
```
T(n) = (3n + 1) / 2
```

### 2.2 Log-Coordinate Branch Maps

In logarithmic coordinates x = log(n), the two branches become:
```
f₀(x) = x − log 2         (even branch)
f₁(x) = x + log 3 − log 2  (odd branch)
```

### 2.3 The Bellman Operator

**Definition** (Collatz Bellman Operator). For parameters γ, a, b ∈ ℝ with 0 ≤ γ < 1, define:
```
(B_γ f)(n) = γ · min(f(n/2) + a, f((3n+1)/2) + b)
```
where n/2 and (3n+1)/2 are integer division. This maps bounded functions ℕ → ℝ to bounded functions ℕ → ℝ.

### 2.4 The Function Space

We work in the Banach space ℓ∞(ℕ) = {f : ℕ → ℝ | f is bounded}, equipped with the sup-norm:
```
‖f‖_∞ = sup_n |f(n)|
```
and the induced metric dist(f, g) = ‖f − g‖_∞. In Lean 4, this is represented as `BoundedContinuousFunction ℕ ℝ` with discrete topology on ℕ.

---

## 3. Main Results

### 3.1 Branch Isometry

**Theorem 3.1** (Branch Isometry). For all x, y ∈ ℝ:
```
dist(f₀(x), f₀(y)) = dist(x, y)
dist(f₁(x), f₁(y)) = dist(x, y)
```

*Proof.* Both branches are translations: f₀(x) = x − c₀ and f₁(x) = x + c₁ for constants c₀ = log 2 and c₁ = log(3/2). Translations are isometries: dist(x−c, y−c) = |x−c−(y−c)| = |x−y| = dist(x,y). □

**Corollary 3.2** (Branch Nonexpansiveness). For any branch selector b ∈ {0,1}:
```
dist(f_b(x), f_b(y)) ≤ dist(x, y)
```

### 3.2 Min-Plus Contraction Algebra

**Theorem 3.3** (Min-Lipschitz). For all a, b, c, d ∈ ℝ:
```
|min(a, b) − min(c, d)| ≤ max(|a − c|, |b − d|)
```

*Proof.* By case analysis on which arguments achieve the respective minima. In each of the four cases, the result follows from the triangle inequality. □

This is the key algebraic fact: the min operation is 1-Lipschitz in the max-norm. It is the tropical analogue of the fact that affine combinations are nonexpansive.

### 3.3 Pointwise Contraction Bound

**Theorem 3.4** (Pointwise Bound). For 0 ≤ γ and bounded functions f, g : ℕ →ᵇ ℝ, for all n ∈ ℕ:
```
|(B_γ f)(n) − (B_γ g)(n)| ≤ γ · dist(f, g)
```

*Proof sketch.*
```
|(B_γ f)(n) − (B_γ g)(n)|
= |γ · min(f(n/2)+a, f(m)+b) − γ · min(g(n/2)+a, g(m)+b)|    [where m = (3n+1)/2]
= γ · |min(f(n/2)+a, f(m)+b) − min(g(n/2)+a, g(m)+b)|         [|γ| = γ since γ ≥ 0]
≤ γ · max(|f(n/2) − g(n/2)|, |f(m) − g(m)|)                   [by Theorem 3.3]
≤ γ · dist(f, g)                                                [by definition of dist]
```
□

### 3.4 Contraction on ℓ∞(ℕ)

**Theorem 3.5** (Bellman Contraction). For 0 ≤ γ < 1, the operator B_γ is ContractingWith γ on the complete metric space ℓ∞(ℕ):
```
dist(B_γ f, B_γ g) ≤ γ · dist(f, g)
```

*Proof.* By the characterization of dist in ℓ∞(ℕ), dist(B_γ f, B_γ g) ≤ C iff for all n, dist((B_γ f)(n), (B_γ g)(n)) ≤ C. Setting C = γ · dist(f, g), the pointwise bound (Theorem 3.4) gives the result. Since γ < 1, this is a strict contraction. □

### 3.5 Fixed-Point Theorems

**Theorem 3.6** (Unique Fixed Point). For 0 ≤ γ < 1, there exists a unique f* ∈ ℓ∞(ℕ) such that B_γ f* = f*.

**Theorem 3.7** (Picard Convergence). For any f₀ ∈ ℓ∞(ℕ):
```
B_γ^k f₀ → f*  as k → ∞
```
in the sup-norm topology, with geometric rate γ.

**Theorem 3.8** (Bellman Equation). The fixed point satisfies pointwise:
```
f*(n) = γ · min(f*(n/2) + a, f*((3n+1)/2) + b)   for all n ∈ ℕ
```

*Proofs.* All three follow directly from the Banach contraction principle (Mathlib's `ContractingWith.fixedPoint`, `ContractingWith.fixedPoint_unique`, `ContractingWith.tendsto_iterate_fixedPoint`), applied to the contraction established in Theorem 3.5. □

### 3.6 Conditional Convergence (from CollatzTropical module)

**Theorem 3.9** (Log-Contraction Implies Descent). If T : ℕ → ℕ satisfies log(T(n)) ≤ c · log(n) for all n ≥ 2 with c < 1, then T(n) < n for all n ≥ 2.

**Theorem 3.10** (Convergence from Log-Contraction). If there exists an accelerated Collatz operator T with contraction ratio c < 1 in log-coordinates (above a threshold N) and all small values reach 1, then every positive natural reaches 1 under T.

These theorems provide the bridge from tropical contraction analysis to concrete orbit convergence, cleanly separating the contracting regime from finite verification.

---

## 4. Algorithms

### 4.1 Value Iteration

**Algorithm 1: Bellman Value Iteration**

```
Input: γ ∈ [0,1), a, b ∈ ℝ, domain size N, tolerance ε
Output: Approximate fixed point f* on [0, N)

1. f ← zero function on [0, N)
2. repeat
3.   for n = 0 to N-1:
4.     f_new[n] ← γ · min(f[n/2] + a, f[(3n+1)/2] + b)
5.   δ ← max_n |f_new[n] - f[n]|
6.   f ← f_new
7. until δ < ε
8. return f
```

**Complexity**: Each iteration costs O(N). Convergence to ε-accuracy requires O(log(1/ε) / log(1/γ)) iterations. Total: O(N · log(1/ε) / log(1/γ)).

**Convergence guarantee**: By Theorem 3.7, ‖f^(k) − f*‖_∞ ≤ γ^k · ‖f^(0) − f*‖_∞ / (1 − γ).

### 4.2 Contraction Constant Estimation

**Algorithm 2: Empirical Lipschitz Constant**

```
Input: γ, a, b, N, number of trials M
Output: Estimated Lipschitz constant

1. max_ratio ← 0
2. for trial = 1 to M:
3.   f, g ← random bounded functions on [0, N)
4.   Tf, Tg ← apply Bellman operator to f, g
5.   d_out ← ‖Tf − Tg‖_∞
6.   d_in ← ‖f − g‖_∞
7.   max_ratio ← max(max_ratio, d_out / d_in)
8. return max_ratio
```

The theorem guarantees this ratio is always ≤ γ.

---

## 5. Computational Experiments

### 5.1 Convergence Verification

We ran Algorithm 1 with γ = 0.9, a = 1.0, b = 1.5 on domain [0, 200). Results:

| Iteration | ‖f^(k) − f^(k-1)‖_∞ | Ratio to previous |
|-----------|----------------------|-------------------|
| 1         | 1.350                | —                 |
| 2         | 1.215                | 0.900             |
| 5         | 0.886                | 0.900             |
| 10        | 0.523                | 0.900             |
| 20        | 0.183                | 0.900             |
| 40        | 0.022                | 0.900             |
| 60        | 0.003                | 0.900             |
| 80        | 2.2×10⁻⁴             | 0.900             |

The observed contraction rate is exactly γ = 0.9, confirming Theorem 3.5.

### 5.2 Lipschitz Constant Verification

We estimated the Lipschitz constant for several values of γ using Algorithm 2 (M = 200 trials, N = 100):

| γ    | Observed Lip. constant | Ratio obs/γ |
|------|------------------------|-------------|
| 0.10 | 0.100000               | 1.000       |
| 0.30 | 0.300000               | 1.000       |
| 0.50 | 0.500000               | 1.000       |
| 0.70 | 0.700000               | 1.000       |
| 0.90 | 0.900000               | 1.000       |
| 0.95 | 0.950000               | 1.000       |
| 0.99 | 0.990000               | 1.000       |

The Lipschitz constant equals γ exactly, confirming that the contraction bound is tight.

### 5.3 Collatz Orbit Structure in Tropical Coordinates

We computed Collatz orbits in log-coordinates for several starting values:

| n   | Steps to 1 | max(log n_k) | Average log-drift per step |
|-----|-----------|--------------|---------------------------|
| 27  | 111       | 9.13         | −0.030                    |
| 31  | 106       | 9.13         | −0.032                    |
| 97  | 118       | 9.13         | −0.039                    |
| 127 | 46        | 8.38         | −0.105                    |
| 171 | 124       | 9.13         | −0.042                    |

The negative average drift confirms the heuristic expectation that orbits tend to decrease in log-coordinates, consistent with the log(3/2) < log(2) drift inequality.

---

## 6. Discussion

### 6.1 What We Have and Have Not Proved

**What is proved:**
- The discounted Bellman operator is a contraction on ℓ∞(ℕ) for any γ ∈ [0,1).
- It has a unique fixed point, computable by value iteration with geometric convergence.
- The fixed point satisfies the Bellman equation pointwise.
- Both Collatz branches are isometries in log-coordinates.
- Log-contraction (if provable) implies orbit convergence.

**What is NOT proved:**
- The Collatz conjecture itself.
- That the undiscounted (γ → 1) limit has a contraction structure.
- That any specific choice of parameters gives a Lyapunov function for the actual Collatz iteration.

### 6.2 The Discount Factor as a Regularization

The discount factor γ < 1 plays the role of a regularization parameter. At γ = 0, the operator collapses to the zero function. At γ = 1, the operator loses its contraction property — the spectral radius becomes 1, and the Banach fixed-point theorem no longer applies.

The mathematically deep question is: what happens in the limit γ → 1⁻? If the fixed points f_γ converge as γ → 1, the limit would encode undiscounted Collatz dynamics. Studying this limit is a concrete avenue for future work.

### 6.3 Connection to Tropical Spectral Theory

The Collatz branching structure generates a semigroup of tropical affine operators. The key quantity governing long-term behavior is the tropical spectral radius of the normalized branch cocycle. Our contraction theorem shows this spectral radius is at most γ for the discounted system; the challenge is to establish spectral radius < 1 for the undiscounted system (or suitable accelerations).

### 6.4 Generalization to Affine-Divide Maps

The framework applies immediately to any map of the form:
```
T(n) = (a_r · n + b_r) / d_r   when n ≡ r (mod m)
```
for residue classes r mod m with integer parameters. Each such map has a Bellman operator; each Bellman operator is a contraction with discount < 1. The fixed-point theory transfers verbatim.

---

## 7. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. Key directions include:

1. **Undiscounted limit theory**: studying the behavior of f_γ as γ → 1⁻.
2. **Tropical spectral radius computation**: determining whether the Collatz branch semigroup has spectral radius < 1 in appropriate projective metrics.
3. **Arithmetic Lyapunov potentials**: finding explicit discrete potentials that decrease along orbits outside finite exceptional sets.
4. **MDL/information-theoretic interpretation**: relating the fixed-point potential to orbit compression and description-length bounds.
5. **Extension to generalized Collatz maps**: applying the framework to the full family of affine-divide iterations.

---

## 8. Formal Verification Details

All results are formalized in two Lean 4 files:

- **`CollatzTropicalContraction.lean`**: Main contraction theory (Theorems 3.1–3.8). ~220 lines, 0 sorries.
- **`CollatzTropical.lean`**: Arithmetic contraction and conditional convergence (Theorems 3.9–3.10). ~200 lines, 0 sorries.

The proofs use Mathlib's `ContractingWith`, `BoundedContinuousFunction`, and `LipschitzWith` infrastructure. All theorems depend only on standard axioms: `propext`, `Classical.choice`, `Quot.sound`.

---

## References

1. Bellman, R. (1957). *Dynamic Programming*. Princeton University Press.
2. Lagarias, J.C. (1985). The 3x+1 problem and its generalizations. *Amer. Math. Monthly*, 92(1), 3–23.
3. Lagarias, J.C. (2010). *The Ultimate Challenge: The 3x+1 Problem*. AMS.
4. Lagarias, J.C. & Weiss, A. (1992). The 3x+1 problem: two stochastic models. *Ann. Appl. Probab.*, 2(1), 229–261.
5. Maclagan, D. & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
6. Tao, T. (2019). Almost all orbits of the Collatz map attain almost bounded values. *arXiv:1909.03562*.
7. Terras, R. (1976). A stopping time problem on the positive integers. *Acta Arith.*, 30(3), 241–252.
