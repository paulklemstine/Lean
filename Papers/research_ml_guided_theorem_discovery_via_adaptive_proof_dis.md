# Exact Realizability of Finite Concepts by Single-Neuron Networks with Polynomial Read-outs

## Abstract

We study the exact representational power of a minimal learning architecture: an
injective feature map followed by a univariate polynomial read-out, computing
$N(x) = p(\Phi(x))$. Whereas classical universality results establish only
*approximation* of target functions, we prove an *exact* interpolation theorem.
For any injective feature map $\Phi$ and any finite set of distinct inputs
$x_1,\dots,x_n$ carrying an arbitrary binary labeling $y_i \in \{-1,+1\}$, there
exists a polynomial read-out $p$ of degree at most $n-1$ such that
$N(x_i) = y_i$ for every $i$. Consequently the classifier is exactly correct,
$\operatorname{sign} N(x_i) = y_i$, and enjoys a *fixed output margin*
$\lvert N(x_i)\rvert = 1$. The proof reduces exact realizability to classical
Lagrange interpolation, using injectivity of $\Phi$ precisely to guarantee that
the interpolation nodes are distinct. We then analyze the consequences of this
statement for the geometry of learned concepts: because the output margin is a
constant, all remaining robustness is governed by the *feature separation
modulus*, and the minimal read-out degree required to realize a specific concept
is controlled by the number of label sign changes in feature order. We formalize
these observations as a research program, state three precise conjectures
(input-space margin bounds, an alternation-count degree law, and stability of
exactness under feature drift), and provide algorithms, numerical experiments,
and applications to expressivity, certified robustness, and model compression.

**Keywords.** exact interpolation, injective feature map, polynomial read-out,
single-neuron network, Lagrange interpolation, classification margin, feature
separation, expressivity, certified robustness, model compression.

---

## 1. Introduction

The theoretical backbone of neural learning is the family of *universal
approximation* theorems: sufficiently large networks approximate continuous
target functions to arbitrary accuracy in a suitable norm. These results are
foundational, but they are statements about *approximation*, and approximation
carries an intrinsic gap. On a finite dataset — the only regime a practitioner
ever actually operates in — an approximator may still misclassify some points or
place them arbitrarily close to the decision boundary.

This paper isolates and proves a complementary, sharper phenomenon: *exact
realizability* of finite concepts. We consider the two-stage architecture
$$
N(x) \;=\; p\big(\Phi(x)\big),
$$
where $\Phi$ is an **injective feature map** and $p$ is a univariate polynomial
**read-out**. The word "single-neuron" refers to the minimality of the decision
stage: the feature map produces a scalar signature and a single polynomial
read-out converts it to a score. We show that on any finite set of distinct
inputs, this architecture reproduces *any* binary labeling exactly, with a fixed
output margin.

Two features of the result deserve emphasis. First, the hypothesis on $\Phi$ is
extremely mild — merely that it does not collapse distinct inputs. Second, the
conclusion is unusually strong — not "small error" but *zero error* with a
*guaranteed unit margin*. The apparent paradox dissolves once one sees the
mechanism: injectivity converts distinct inputs into distinct interpolation
nodes, and exact interpolation through distinct nodes is a solved classical
problem.

The deeper contribution is interpretive. Since the output margin is *constant* by
construction, it cannot be the locus of a model's robustness. We argue that the
entire robustness budget is relocated to the geometry of the feature map — its
*separation modulus* — and that the true representational cost of a concept is a
combinatorial invariant, its *alternation count* in feature order. We turn these
observations into a precise research program.

### 1.1 Contributions

- **(Main theorem, §3).** Exact realizability: every finite binary concept on
  distinct inputs is realized *exactly*, with fixed output margin $1$, by a
  polynomial read-out over any injective feature map.
- **(Degree bound, §3).** Degree $n-1$ always suffices for $n$ points, via an
  explicit Lagrange construction.
- **(Margin corollary, §3).** The construction yields $\operatorname{sign}
  N(x_i)=y_i$ and $|N(x_i)|=1$, a fixed output margin independent of the labeling.
- **(Geometry program, §5).** Three precise conjectures relating input-space
  robustness, minimal degree, and stability to the feature separation modulus and
  the alternation structure of the labels.
- **(Algorithms and experiments, §6–§7).** Constructive interpolation algorithms
  with complexity analysis, and numerical demonstrations of exactness, margins,
  degree/alternation relationships, and stability under perturbation.

---

## 2. Definitions and setup

Throughout, inputs live in a set $\mathcal{X}$ (a metric space when geometry is
relevant), labels are drawn from $\{-1,+1\}$, and features are real numbers unless
stated otherwise.

**Definition 2.1 (Feature map).** A *feature map* is a function
$\Phi : \mathcal{X} \to \mathbb{R}$. It is *injective* if $x \ne x'$ implies
$\Phi(x) \ne \Phi(x')$.

**Definition 2.2 (Polynomial read-out and network).** A *read-out* is a
polynomial $p \in \mathbb{R}[t]$. The associated *single-neuron network* is the
composition
$$
N(x) = p(\Phi(x)).
$$
The *degree* of the network is $\deg p$.

**Definition 2.3 (Labeled sample).** A *labeled sample* is a finite sequence
$(x_1,y_1),\dots,(x_n,y_n)$ with the $x_i \in \mathcal{X}$ pairwise distinct and
$y_i \in \{-1,+1\}$. Its *feature nodes* are $t_i := \Phi(x_i)$.

**Definition 2.4 (Exact realizability).** A read-out $p$ *exactly realizes* the
labeled sample if $N(x_i) = p(t_i) = y_i$ for all $i$. The labeling is *exactly
realizable* (over $\Phi$) if some read-out realizes it.

**Definition 2.5 (Output margin).** Given a network $N$ and a labeled sample, the
*output margin* is $\min_i \lvert N(x_i)\rvert$. It measures the numerical
separation of the scores from the decision threshold $0$.

**Definition 2.6 (Feature separation modulus).** For a labeled sample with feature
nodes $t_1,\dots,t_n$, the *separation modulus* is
$$
\operatorname{sep}(\Phi) \;=\; \min_{i \ne j} \lvert t_i - t_j\rvert \;>\; 0,
$$
which is positive exactly when $\Phi$ is injective on the sample.

**Definition 2.7 (Alternation count).** Reindex the sample so that the feature
nodes are increasing, $t_{\sigma(1)} < \cdots < t_{\sigma(n)}$. The *alternation
count* $A$ is the number of adjacent index pairs whose labels differ:
$$
A \;=\; \#\{\, k : 1 \le k < n,\ y_{\sigma(k)} \ne y_{\sigma(k+1)} \,\}.
$$

---

## 3. Main results

### 3.1 Exact realizability

**Theorem 3.1 (Exact Realizability Theorem).** *Let $\Phi$ be an injective
feature map and let $(x_1,y_1),\dots,(x_n,y_n)$ be a labeled sample. Then there
exists a polynomial read-out $p$ of degree at most $n-1$ such that*
$$
N(x_i) = p(\Phi(x_i)) = y_i \qquad (1 \le i \le n).
$$

**Proof.** Because the inputs $x_i$ are pairwise distinct and $\Phi$ is injective,
the feature nodes $t_i = \Phi(x_i)$ are pairwise distinct real numbers. Define the
Lagrange basis polynomials
$$
\ell_i(t) \;=\; \prod_{j \ne i} \frac{t - t_j}{t_i - t_j},
$$
each of degree $n-1$; the denominators are nonzero precisely because the nodes are
distinct. By construction $\ell_i(t_i) = 1$ and $\ell_i(t_j) = 0$ for $j \ne i$.
Set
$$
p(t) \;=\; \sum_{i=1}^{n} y_i\, \ell_i(t).
$$
Then $\deg p \le n-1$ and $p(t_k) = \sum_i y_i \ell_i(t_k) = y_k$ for each $k$.
Hence $N(x_k) = p(\Phi(x_k)) = p(t_k) = y_k$. $\qquad\blacksquare$

**Corollary 3.2 (Exact classification with fixed output margin).** *The read-out
$p$ of Theorem 3.1 satisfies $\operatorname{sign} N(x_i) = y_i$ for all $i$, and
the output margin equals $1$:*
$$
\min_i \lvert N(x_i)\rvert = 1.
$$

**Proof.** Immediate from $N(x_i) = y_i \in \{-1,+1\}$: the sign is $y_i$ and the
absolute value is $1$ at every sample point. $\qquad\blacksquare$

Corollary 3.2 is the qualitative heart of the paper. Exactness is not "small
error"; it is *no error together with a guaranteed unit gap* between the classes,
and the gap does not depend on the labeling.

### 3.2 Uniqueness and degree

**Proposition 3.3 (Uniqueness at fixed degree).** *Among polynomials of degree at
most $n-1$, the read-out interpolating a labeled sample with distinct feature
nodes is unique.*

**Proof.** If $p$ and $q$ both interpolate, then $p - q$ has degree at most $n-1$
yet vanishes at the $n$ distinct nodes $t_1,\dots,t_n$; a nonzero polynomial of
degree at most $n-1$ has at most $n-1$ roots, so $p - q = 0$. $\qquad\blacksquare$

**Proposition 3.4 (Sufficiency of degree $n-1$ is worst-case necessary).** *There
exist labelings of $n$ distinct feature nodes for which no read-out of degree less
than $n-1$ exactly realizes the sample.*

**Proof sketch.** Take the strictly alternating labeling $y_{\sigma(k)} =
(-1)^k$ along increasing feature nodes. Any interpolant changes sign between each
adjacent pair, so it has at least $n-1$ real roots (one strictly between each
pair of consecutive nodes with opposite target signs). A polynomial with $n-1$
distinct real roots has degree at least $n-1$; combined with the interpolation
constraints this forces degree exactly $n-1$. $\qquad\blacksquare$

Propositions 3.3–3.4 show that the degree bound of Theorem 3.1 is tight in the
worst case, motivating the finer, concept-dependent analysis in §5.

### 3.3 Robustness is relocated to feature separation

**Observation 3.5.** By Corollary 3.2 the output margin is the *constant* $1$,
independent of $\Phi$, of the sample, and of the labeling. Therefore the output
margin carries no information about how robust the classifier is to input
perturbations. Any quantitative robustness must be a property of the *composition*
$N = p \circ \Phi$ in input space, and — since $p$ is determined by the nodes —
ultimately a property of $\Phi$ and the geometry of the feature nodes. This
motivates the separation modulus $\operatorname{sep}(\Phi)$ of Definition 2.6 as
the natural carrier of robustness, and drives the conjectures of §5.

---

## 4. Discussion: approximation versus exact realizability

Classical universality answers "can the architecture get arbitrarily close to a
target function on a domain?" Exact realizability answers a different and, on
finite data, more operationally relevant question: "can the architecture match a
target *exactly* on the data, with quantified confidence?" The two are logically
independent. An approximator need not interpolate (it may hold a small uniform
error everywhere), and an exact interpolator need not approximate a target well
off the sample (Runge-type oscillation is the classical caution).

The decisive structural insight is the *factorization of difficulty*. Exact
realizability decomposes into (i) a purely combinatorial/algebraic fact —
interpolation through distinct nodes always succeeds — and (ii) a purely geometric
fact — injectivity of $\Phi$ guarantees the nodes are distinct. All of the "work"
of representing an arbitrary concept is discharged by (i), which is free; the only
substantive hypothesis is (ii), which is a statement about the *representation*,
not the classifier. This is why we can, and should, transfer every remaining
quantitative question — robustness, minimal cost, stability — from the read-out to
the geometry of the feature map.

---

## 5. A geometric research program

We record three precise conjectures that convert the qualitative message of
Observation 3.5 into a quantitative theory. Each is stated so that it can be
tested numerically (see §7) and, in principle, proved from the feature map alone.

**Conjecture C1 (Input-space margin is governed by feature separation).** *Let
$\Phi$ be injective and $L$-Lipschitz on a compact metric domain, with a labeled
sample of separation modulus $s = \operatorname{sep}(\Phi)$. Then the largest
achievable input-space classification margin $\rho$ around the sample satisfies*
$$
g(s) \;\le\; \rho \;\le\; \tfrac{1}{2}\,\min_{y_i \ne y_j} \operatorname{dist}(x_i,x_j),
$$
*for a monotone increasing function $g$ depending only on $L$ and the domain.*
The message: the output margin being fixed, robustness is exactly the geometry of
separation. A certificate can be computed from $\Phi$ without inspecting $p$.

**Conjecture C2 (Read-out degree equals one plus the alternation count).** *For a
specific labeling with alternation count $A$ (Definition 2.7), the minimal degree
of a read-out that exactly realizes it equals $A + 1$. In the worst case
$A = n-1$, recovering the sharp bound of Propositions 3.3–3.4.* The message: the
representational cost of a concept is the combinatorial invariant $A$ — its
"wiggle" in feature order — not an architectural parameter. This gives model
compression a *tight, computable target* rather than a heuristic stopping rule.

**Conjecture C3 (Stability of exactness under feature drift).** *If $\Phi$ is
perturbed to $\tilde\Phi$ with $\sup_x \lvert \tilde\Phi(x) - \Phi(x)\rvert <
\tfrac{1}{2}\operatorname{sep}(\Phi)$, then every labeling exactly realizable over
$\Phi$ remains exactly realizable over $\tilde\Phi$, with read-out coefficients
depending continuously on the perturbation.* The message: exactness is an *open*
condition — separation is an inequality with slack — so the small drift of
fine-tuning and quantization deforms the coefficients without destroying
interpolation.

**Heuristic support for C3.** If the perturbation is smaller than half the
separation modulus, the perturbed nodes $\tilde t_i = \tilde\Phi(x_i)$ remain
pairwise distinct (each moves by less than half the minimum gap, so distinct nodes
cannot collide). Distinct nodes yield an invertible Vandermonde system, whose
solution — the read-out coefficients — is a rational, hence continuous, function
of the nodes. This makes C3 highly plausible and indicates the shape of a proof.

---

## 6. Algorithms

We give constructive procedures underlying the results and experiments. Let
$t_1,\dots,t_n$ be the (distinct) feature nodes and $y_1,\dots,y_n$ the labels.

### 6.1 Lagrange read-out construction

Builds the interpolating read-out directly from the Lagrange formula of Theorem
3.1. Evaluating the network at a query $t$ costs $O(n)$ per node, $O(n^2)$ total;
constructing an explicit coefficient vector costs $O(n^2)$ via incremental
polynomial multiplication.

```
Input:  nodes t[1..n] (distinct), labels y[1..n]
Output: read-out p with p(t[i]) = y[i]
1. for i in 1..n:
2.     numerator_i <- product over j != i of (X - t[j])          # symbolic
3.     denom_i     <- product over j != i of (t[i] - t[j])
4.     basis_i     <- numerator_i / denom_i
5. p <- sum over i of y[i] * basis_i
6. return p
```

### 6.2 Newton divided-difference construction (numerically stable, incremental)

Produces the same read-out in the Newton basis, supporting $O(n)$ incremental
updates when a new sample point is appended — the natural primitive for online
concept learning.

```
Input:  nodes t[1..n], labels y[1..n]
Output: divided-difference coefficients c[1..n]
1. c[i] <- y[i] for all i
2. for k in 1..n-1:
3.     for i in n down to k+1:
4.         c[i] <- (c[i] - c[i-1]) / (t[i] - t[i-k])
5. return c        # p(t) = c[1] + c[2](t-t[1]) + c[3](t-t[1])(t-t[2]) + ...
```

### 6.3 Minimal-degree search (alternation-count target)

Computes the alternation count $A$ and attempts a least-squares fit of degree
$A+1$; consistent with Conjecture C2, this typically realizes the labeling
exactly at a degree far below the worst-case $n-1$.

```
Input:  nodes t[1..n], labels y[1..n]
1. sort samples by node value
2. A <- number of adjacent pairs with differing labels
3. for d in 0 .. n-1:
4.     fit polynomial q of degree d minimizing sum (q(t[i]) - y[i])^2
5.     if sign(q(t[i])) == y[i] for all i: return (d, q)   # exact classification
6. return (n-1, Lagrange read-out)                          # guaranteed fallback
```

---

## 7. Numerical experiments

The accompanying programs demonstrate the theory on concrete samples. The
principal findings, all reproducible, are:

1. **Exactness and unit margin.** For random injective feature maps and random
   binary labelings, the Lagrange read-out attains $N(x_i) = y_i$ to machine
   precision and output margin exactly $1$, confirming Theorem 3.1 and
   Corollary 3.2.
2. **Worst-case degree.** For strictly alternating labelings the minimal exact
   degree equals $n-1$, matching Proposition 3.4.
3. **Concept-dependent degree.** For labelings with few sign changes, exact
   classification is achieved at degree $A+1 \ll n-1$, supporting Conjecture C2.
4. **Stability under drift.** Perturbing the feature nodes by less than half the
   separation modulus preserves exact realizability while the read-out
   coefficients vary continuously, supporting Conjecture C3.

---

## 8. Applications

**Expressivity.** Theorem 3.1 shows a minimal architecture already exactly
represents *every* finite binary concept. Expressivity is therefore never the
bottleneck at the level of finite data; the interesting questions are quantitative
(degree, margin, stability), not existential.

**Certified robustness.** Observation 3.5 and Conjecture C1 recast robustness
certification as a computation on the feature map: bound the separation modulus
and Lipschitz constant of $\Phi$, and obtain an input-space margin certificate
without inspecting the read-out. This aligns the output-space universality
viewpoint with the input-space certification viewpoint.

**Model compression and distillation.** Conjecture C2 identifies the honest size
of a learned rule with its alternation count $A$. A distillation target of degree
$A+1$ is provably minimal (if C2 holds), replacing heuristic pruning schedules
with a computable optimum.

**Online and drifting deployment.** The Newton construction (§6.2) supports
incremental updates, and Conjecture C3 guarantees that fine-tuning or quantization
below the separation threshold preserves exactness — a stability guarantee for
production feature extractors.

---

## 9. Future work

The immediate program is to prove C1–C3. Beyond them: (i) extend exact
realizability to multiclass labels and to vector-valued feature maps
$\Phi:\mathcal{X}\to\mathbb{R}^d$ with multivariate read-outs, where the relevant
invariant generalizes the alternation count to a combinatorial complexity of the
labeling in feature space; (ii) quantify the trade-off between exactness on the
sample and generalization off it, controlling Runge-type oscillation via node
geometry; (iii) develop separation-modulus estimators for realistic learned
feature maps so that the robustness certificates of C1 become practical.

---

## 10. Conclusion

A single neuron with a polynomial read-out over any injective feature map exactly
realizes every finite binary concept, with a fixed unit output margin. The proof
is classical interpolation; the significance is a shift of perspective. Because
exactness is free and the output margin is constant, the substantive content of
learning — expressivity, robustness, and compression — migrates to the geometry of
the feature map: its separation modulus and the alternation structure of the
labels. We have made this migration precise through three conjectures and
supporting algorithms and experiments, turning a qualitative universality
statement into a quantitative, geometric, and checkable research program.
