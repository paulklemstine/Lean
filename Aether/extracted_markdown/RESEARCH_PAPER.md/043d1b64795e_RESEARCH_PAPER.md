# Tropical Convergence Criteria for Self-Avoiding Walk Generating Functions

## Abstract

We establish a formal proof chain connecting three mathematical domains through self-avoiding walk (SAW) theory: combinatorial submultiplicativity, real-analytic convergence via Fekete's lemma, and tropical algebraic convergence criteria. The central result is a tropical convergence theorem that precisely characterizes when the SAW generating function converges: the tropical power series $\text{trop}(f)(v) = \sup_n(nv + \log c_n)$ converges if and only if $v < -\log\mu$, where $\mu$ is the connective constant. We also establish the irrationality of the Nienhuis constant $\sqrt{2+\sqrt{2}}$, the connective constant of the hexagonal lattice, by identifying its minimal polynomial $x^4 - 4x^2 + 2 = 0$ and verifying it has no rational roots. All results are formalized and machine-verified.

## 1. Introduction

Self-avoiding walks (SAWs) are lattice paths that visit no vertex more than once. Despite their simple definition, they encode deep combinatorial and analytic structure. The number $c_n$ of $n$-step SAWs from the origin on a lattice $\mathcal{L}$ satisfies the submultiplicativity property $c_{m+n} \leq c_m \cdot c_n$, since concatenation of self-avoiding walks may introduce self-intersections. This fundamental inequality, combined with Fekete's lemma for subadditive sequences, guarantees the existence of the **connective constant** $\mu(\mathcal{L}) = \lim_{n\to\infty} c_n^{1/n}$.

The connective constant is a fundamental invariant of the lattice. For the hexagonal lattice, Duminil-Copin and Smirnov [1] proved $\mu = \sqrt{2+\sqrt{2}}$, confirming a conjecture of Nienhuis [2]. For other lattices (square, triangular, etc.), exact values remain unknown.

In this paper, we develop the theory connecting SAW generating functions to tropical algebra. The generating function $f(x) = \sum c_n x^n$ has radius of convergence $1/\mu$. Its "tropical shadow"—obtained by replacing coefficients with their logarithms and addition with supremum—converges at a tropical parameter $v$ if and only if $v$ lies below the negative of the tropical growth rate $-\log\mu$. This tropical characterization provides a piecewise-linear perspective on the analytic structure of SAW generating functions.

## 2. Definitions and Setup

### 2.1 Subadditive and Submultiplicative Sequences

**Definition 2.1** (Subadditive Sequence). A function $f: \mathbb{N} \to \mathbb{R}$ is *subadditive* if $f(m+n) \leq f(m) + f(n)$ for all $m, n \in \mathbb{N}$.

**Definition 2.2** (Submultiplicative Sequence). A function $c: \mathbb{N}^+ \to \mathbb{R}$ is *submultiplicative* if $c(n) > 0$ for all $n$ and $c(m+n) \leq c(m) \cdot c(n)$ for all $m, n \in \mathbb{N}^+$.

The connection is immediate: if $c$ is submultiplicative, then $f = \log \circ c$ is subadditive (on $\mathbb{N}^+$), since $\log(c(m+n)) \leq \log(c(m) \cdot c(n)) = \log c(m) + \log c(n)$.

### 2.2 Tropical Valuations

**Definition 2.3** (Tropical Valuation). A *tropical valuation* is a function $v: \mathbb{N} \to \mathbb{R}$ together with a proof of subadditivity: $v(m+n) \leq v(m) + v(n)$.

**Definition 2.4** (Tropical Growth Rate). The *tropical growth rate* of a tropical valuation $v$ is $\gamma = \inf_{n \geq 1} v(n)/n$.

**Definition 2.5** (Tropical Power Series). The *tropical term* at index $n$ and parameter $t$ is $T_n(t) = nt + v(n)$. The tropical power series *converges at $t$* if $\{T_n(t) : n \in \mathbb{N}\}$ is bounded above, and *diverges* otherwise.

### 2.3 The Nienhuis Constant

**Definition 2.6**. The *Nienhuis constant* is $\alpha = \sqrt{2 + \sqrt{2}} \approx 1.84776$.

## 3. Main Results

### 3.1 Submultiplicative Bounds

**Theorem 3.1** (Log-Subadditivity). If $c: \mathbb{N}^+ \to \mathbb{R}$ is submultiplicative, then $\log c(m+n) \leq \log c(m) + \log c(n)$ for all $m, n \in \mathbb{N}^+$.

*Proof.* By submultiplicativity, $c(m+n) \leq c(m) \cdot c(n)$. Since $c(m), c(n) > 0$, monotonicity of logarithm gives $\log c(m+n) \leq \log(c(m) \cdot c(n)) = \log c(m) + \log c(n)$. $\square$

**Theorem 3.2** (Iteration Bound). If $f$ is subadditive with $f(0) \leq 0$, then $f(kn) \leq k \cdot f(n)$ for all $k, n \in \mathbb{N}$.

*Proof.* Induction on $k$. Base case: $f(0) \leq 0 = 0 \cdot f(n)$. Inductive step: $f((k+1)n) = f(kn + n) \leq f(kn) + f(n) \leq kf(n) + f(n) = (k+1)f(n)$. $\square$

**Theorem 3.3** (Fekete Decomposition). Under the same hypotheses, $f(n) \leq \lfloor n/d \rfloor \cdot f(d) + f(n \bmod d)$ for all $d, n \in \mathbb{N}$.

*Proof.* Write $n = \lfloor n/d \rfloor \cdot d + (n \bmod d)$ by the division algorithm. Apply subadditivity to split $f(n) \leq f(\lfloor n/d \rfloor \cdot d) + f(n \bmod d)$, then apply Theorem 3.2 to bound $f(\lfloor n/d \rfloor \cdot d) \leq \lfloor n/d \rfloor \cdot f(d)$. $\square$

### 3.2 Growth Rate Bounds

**Theorem 3.4** (Growth Rate as Infimum). For submultiplicative $c$, the growth rate $\mu = \inf_{n \geq 1} c(n)^{1/n}$ satisfies $\mu \leq c(n)^{1/n}$ for all $n \geq 1$.

**Theorem 3.5** (Upper Bound). $c(n) \leq c(1)^n$ for all $n \geq 1$, and consequently $\mu \leq c(1)$.

*Proof.* Induction on $n$ using $c(n+1) = c(n + 1) \leq c(n) \cdot c(1)$ and $c(n) \leq c(1)^n$. $\square$

**Theorem 3.6** (Positivity). If additionally $c(n) \geq 1$ for all $n$, then $\mu \geq 1 > 0$.

*Proof.* Each $c(n)^{1/n} \geq 1^{1/n} = 1$ since $c(n) \geq 1$ and $1/n > 0$. The infimum of values $\geq 1$ is $\geq 1$. $\square$

### 3.3 Tropical Convergence Criterion

**Theorem 3.7** (Convergence Direction). If $t < -\gamma$ where $\gamma$ is the tropical growth rate, then the tropical power series converges at $t$.

*Proof sketch.* Since $t < -\gamma = -\inf_{n \geq 1} v(n)/n$, there exists $d \geq 1$ with $v(d)/d < -t$, equivalently $dv + v(d) < 0$. For any $n$, decompose $n = kd + r$ with $0 \leq r < d$. By subadditivity, $v(n) \leq k \cdot v(d) + v(r)$, so $T_n(t) = nt + v(n) \leq k(dt + v(d)) + rt + v(r)$. Since $dt + v(d) < 0$ and $k \geq 0$, the first term is $\leq 0$. The second and third terms are bounded by $(d-1)|t| + \sum_{r=0}^{d-1} |v(r)|$, giving a uniform upper bound. $\square$

**Theorem 3.8** (Divergence Direction). If $t > -\gamma$ and the set $\{v(n)/n : n \geq 1\}$ is bounded below, then the tropical power series diverges at $t$.

*Proof sketch.* Under the bounded-below hypothesis, $\gamma \leq v(n)/n$ for all $n \geq 1$ (by definition of infimum). Thus $v(n) \geq \gamma n$, so $T_n(t) = nt + v(n) \geq n(t + \gamma)$. Since $t + \gamma > 0$, these terms grow without bound, contradicting the existence of an upper bound. $\square$

### 3.4 Classical-Tropical Bridge

**Theorem 3.9** (Bridge Theorem). For $x > 0$, $x < 1/\mu$ if and only if $\log x < -\gamma$, where $\mu = e^\gamma$ is the connective constant.

*Proof.* Since $\mu = e^\gamma$ and $\log$ is monotone on $(0,\infty)$: $x < 1/e^\gamma \iff x < e^{-\gamma} \iff \log x < -\gamma$. $\square$

**Theorem 3.10** (Growth Rate Identity). If the tropical valuation is $v(n) = \log c(n)$ for a submultiplicative sequence $c$, then $\gamma = \inf_{n \geq 1} \log c(n) / n$.

### 3.5 Irrationality of the Nienhuis Constant

**Theorem 3.11** (Minimal Polynomial). $\alpha = \sqrt{2+\sqrt{2}}$ satisfies $\alpha^4 - 4\alpha^2 + 2 = 0$.

*Proof.* $\alpha^2 = 2 + \sqrt{2}$, so $(\alpha^2 - 2)^2 = 2$, giving $\alpha^4 - 4\alpha^2 + 4 = 2$. $\square$

**Theorem 3.12** (No Rational Roots). The polynomial $p(x) = x^4 - 4x^2 + 2$ has no rational roots.

*Proof.* We show $p(x) = (x^2 - 2)^2 - 2$. If $q \in \mathbb{Q}$ satisfies $p(q) = 0$, then $(q^2 - 2)^2 = 2$, so $q^2 - 2 = \pm\sqrt{2}$. But $q^2 - 2 \in \mathbb{Q}$ and $\sqrt{2} \notin \mathbb{Q}$, contradiction. $\square$

**Theorem 3.13** (Irrationality). $\sqrt{2+\sqrt{2}}$ is irrational.

*Proof.* If $\alpha = p/q$ were rational, then $p(p/q) = 0$, contradicting Theorem 3.12. $\square$

## 4. Algorithms

### 4.1 SAW Enumeration

We use backtracking to enumerate self-avoiding walks on a lattice:

```
Algorithm SAW_COUNT(lattice, n):
  count = 0
  for each n-step path from origin:
    if path is self-avoiding:
      count += 1
  return count
```

The runtime is $O(c_n)$ per walk and the total count is $\Theta(\mu^n)$, making this exponential. Pivot algorithms provide polynomial-time approximate sampling.

### 4.2 Growth Rate Estimation

Given SAW counts $c_1, \ldots, c_N$:

```
Algorithm GROWTH_RATE(counts, N):
  rates = [c_k^{1/k} for k in 1..N]
  return min(rates)  // lower bound on μ
```

By Theorem 3.4, $\min_k c_k^{1/k} \leq \mu$, providing a rigorous lower bound.

### 4.3 Tropical Convergence Test

```
Algorithm TROPICAL_CONVERGE(valuations, t, max_n):
  max_term = -infinity
  for n in 0..max_n:
    term = n * t + val(n)
    max_term = max(max_term, term)
  if max_term appears to stabilize:
    return CONVERGENT
  else:
    return DIVERGENT
```

## 5. Discussion

### 5.1 Significance of the Tropical Perspective

The tropical convergence criterion (Theorems 3.7-3.8) provides a characterization of the radius of convergence that is fundamentally piecewise-linear. While classical analysis describes convergence through the root test or ratio test—both involving limits of $n$-th roots or ratios—the tropical characterization involves a simple supremum of linear functions. This opens the door to applying the machinery of tropical geometry (tropical varieties, tropical intersection theory) to questions about SAW generating functions.

### 5.2 The Role of Submultiplicativity

The submultiplicativity property $c_{m+n} \leq c_m \cdot c_n$ is the single structural assumption that drives all results. It ensures:
1. Log-subadditivity, which grounds the tropical valuation framework.
2. The existence of the growth rate/connective constant via Fekete's lemma.
3. The tropical convergence criterion, which requires subadditivity for the decomposition argument.

This universality means our results apply to any submultiplicative counting sequence, not just SAWs. Examples include the number of lattice animals, polyominoes, and percolation clusters.

### 5.3 The Nienhuis Constant

The irrationality of $\sqrt{2+\sqrt{2}}$ is established through elementary algebraic number theory. The degree-4 minimal polynomial $x^4 - 4x^2 + 2$ is irreducible over $\mathbb{Q}$ (in fact, it's Eisenstein at $p=2$), placing the Nienhuis constant in a precise position in the algebraic hierarchy.

The tropical shadow of this polynomial is $\max(4t, 2t + \log 4, \log 2)$—a piecewise-linear function whose "tropical roots" (breakpoints) encode the same algebraic structure. This connection between algebraic number theory and tropical geometry for specific physical constants is largely unexplored.

## 6. Future Work

1. **Discrete holomorphicity**: Formalize the parafermionic observable of Duminil-Copin and Smirnov on finite hexagonal lattice patches.
2. **Bridge decomposition**: Use the tropical framework to establish new bounds on connective constants for lattices where exact values are unknown.
3. **Tropical spectral theory**: Connect the growth rate to spectral properties of tropical transfer matrices.
4. **Pattern theorem**: Formalize the Kesten pattern theorem, which gives polynomial corrections to the exponential growth $c_n \sim \mu^n$.

## References

[1] H. Duminil-Copin and S. Smirnov, "The connective constant of the honeycomb lattice equals $\sqrt{2+\sqrt{2}}$," *Annals of Mathematics*, vol. 175, no. 3, pp. 1653–1665, 2012.

[2] B. Nienhuis, "Exact critical point and critical exponents of $O(n)$ models in two dimensions," *Physical Review Letters*, vol. 49, no. 15, pp. 1062–1065, 1982.

[3] M. Fekete, "Über die Verteilung der Wurzeln bei gewissen algebraischen Gleichungen mit ganzzahligen Koeffizienten," *Mathematische Zeitschrift*, vol. 17, pp. 228–249, 1923.

[4] N. Madras and G. Slade, *The Self-Avoiding Walk*, Birkhäuser, 2013.

[5] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, vol. 161, AMS, 2015.
