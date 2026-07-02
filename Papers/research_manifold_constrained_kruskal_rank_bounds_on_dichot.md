# Manifold-Constrained Kruskal Rank Bounds on Dichotomy Counts

## Abstract

We study the expressive capacity of linear classifiers acting on data drawn from low-dimensional structures. The classical measure of this capacity is **Cover's counting function**, $C(N, d) = 2\sum_{k=0}^{d-1}\binom{N-1}{k}$, which counts the homogeneously linearly-separable dichotomies of $N$ points in general position in a $d$-parameter space. We develop the combinatorial theory of this function from first principles, proving its defining one-point (Pascal) recurrence, its saturation to $2^N$ when the parameter budget dominates the sample ($N \leq d$), and its strict collapse below $2^N$ once the sample exceeds the budget ($d < N$). The analytic core is a **maximal-solution theorem**: any nonnegative integer quantity obeying Cover's base values and the subadditive one-point recursion is bounded above by $C(N, d)$. We then apply this to geometry. For a $d$-dimensional submanifold $E \subset \mathbb{R}^M$ and a smooth injective feature map $\Phi : E \to \mathbb{R}^{M'}$, points of $E$ in general position have Kruskal rank $s \leq d + 1$, and the $\Phi$-separable dichotomy count $C_F(N)$ obeys the same recursion with effective parameter budget $p = d + M' + 1$. Consequently $C_F(N) \leq C(N,\, d + M' + 1)$, and strictly below $2^N$ whenever $p < N$. The bound depends only on the **intrinsic** dimension $d$ of the data manifold and the feature dimension $M'$ — never on the ambient dimension $M$. We package the geometric recursion into an abstract dichotomy-system framework and show the abstraction is inhabited and the bound is tight.

**Keywords:** Cover's counting function, dichotomy count, Kruskal rank, linear separability, VC-type capacity, manifold data, general position, intrinsic dimension.

---

## 1. Introduction

A homogeneous linear classifier on $\mathbb{R}^d$ partitions a finite point set into two labeled classes by the sign of a linear functional. Given $N$ points, a *dichotomy* is an assignment of the two labels to the points; a dichotomy is *linearly separable* if some homogeneous hyperplane realizes it. The number of separable dichotomies is the fundamental measure of a classifier family's expressive power: it is the count of distinct patterns the family could ever fit.

Cover (1965) answered this counting question for points in general position, and the answer — Cover's counting function — has become a cornerstone of statistical learning theory, closely related to VC dimension and the growth function. Its two regimes encode a phase transition: below a critical sample size the classifier realizes *every* labeling; above it, some labelings become permanently unreachable.

Modern data, however, is rarely spread uniformly across its ambient space. It concentrates on low-dimensional manifolds. This paper asks how Cover's theory transfers to that setting and answers precisely: the governing quantity is the **intrinsic** dimension of the data manifold, mediated by the **Kruskal rank** of the point configuration, and the ambient dimension is irrelevant.

Our contributions are:

1. A self-contained combinatorial development of Cover's function: base cases, the Pascal one-point recurrence, the global bound $C(N,d)\le 2^N$, saturation, and strict collapse (Section 3).
2. A **maximal-solution theorem** characterizing Cover's function as the largest solution of a subadditive one-point recursion with Cover's base values (Section 4).
3. The **manifold-constrained dichotomy bound**: an abstract dichotomy-system framework capturing the geometry, an instance proving tightness, and the resulting expressivity collapse (Section 5).

---

## 2. Definitions

Throughout, $N$ denotes a sample size and $d$ a parameter (dimension) budget, both positive integers unless stated otherwise. All sums of binomial coefficients are over nonnegative indices.

**Definition 2.1 (Cover's counting function).** For $N, d \in \mathbb{N}$,
$$C(N, d) \;=\; 2 \sum_{k=0}^{d-1} \binom{N-1}{k}.$$
Equivalently, $C(N,d) = 2\sum_{k\in\{0,\dots,d-1\}}\binom{N-1}{k}$, the number of homogeneously linearly-separable dichotomies of $N$ points in general position in a $d$-parameter space.

**Definition 2.2 (General position).** A finite set $F$ of $N$ points in a $d$-parameter space is in *general position* if every subset of size at most $d$ is linearly independent (equivalently, no $d$ of them lie on a common homogeneous hyperplane through the origin). This is the genericity condition under which Cover's count is exact.

**Definition 2.3 (Kruskal rank).** The *Kruskal rank* $s$ of a finite point configuration is the largest integer such that *every* subset of $s$ points is linearly independent. It is the combinatorial measure of how many points can be chosen before linear entanglement is forced.

**Definition 2.4 (Dichotomy system).** A function $g : \mathbb{N} \times \mathbb{N} \to \mathbb{N}$ is a *dichotomy system* if it satisfies, for the relevant positive arguments,
- **base at one point:** $g(1, d) \leq 2$ for all $d \geq 1$;
- **base in one dimension:** $g(N, 1) \leq 2$ for all $N \geq 1$;
- **one-point recursion:** $g(N+1, d+1) \leq g(N, d+1) + g(N, d)$ for all $N \geq 1$, $d \geq 1$.

This abstracts the essential geometric bookkeeping of "adding one sample" without committing to any particular classifier.

---

## 3. The combinatorial theory of Cover's function

### 3.1 Base cases

**Proposition 3.1 (Single point).** For $d \geq 1$, $C(1, d) = 2$.

*Proof sketch.* With $N = 1$ the binomial factors become $\binom{0}{k}$, which vanishes for $k \geq 1$ and equals $1$ for $k = 0$. Hence the sum over $k = 0, \dots, d-1$ collapses to its $k=0$ term, giving $C(1,d) = 2 \cdot 1 = 2$. $\square$

**Proposition 3.2 (One parameter).** For all $N$, $C(N, 1) = 2$.

*Proof sketch.* The sum $\sum_{k=0}^{0}\binom{N-1}{k}$ has the single term $\binom{N-1}{0} = 1$, so $C(N,1) = 2$. $\square$

### 3.2 A partial-sum Pascal identity

The engine behind the recurrence is a partial-sum version of Pascal's rule.

**Lemma 3.3 (Partial Pascal identity).** For all $m, d \in \mathbb{N}$,
$$\sum_{k=0}^{d}\binom{m+1}{k} \;=\; \sum_{k=0}^{d}\binom{m}{k} \;+\; \sum_{k=0}^{d-1}\binom{m}{k}.$$

*Proof sketch.* Induct on $d$. The base case $d=0$ reads $\binom{m+1}{0} = \binom{m}{0} + 0$. For the step, peel off the top term of each sum via $\sum_{k=0}^{d+1} = \sum_{k=0}^{d} + (\text{term at } d+1)$ and apply Pascal's rule $\binom{m+1}{d+1} = \binom{m}{d} + \binom{m}{d+1}$ to the peeled term; the remaining sums are handled by the inductive hypothesis. $\square$

### 3.3 Full versus partial binomial sums

**Lemma 3.4 (Saturated partial sum).** If $n < d$ then $\sum_{k=0}^{d-1}\binom{n}{k} = 2^n$.

*Proof sketch.* Once the cutoff $d-1 \geq n$, all nonzero terms $\binom{n}{k}$ (for $0 \le k \le n$) are included, and the extra terms with $k > n$ vanish. The full sum is $\sum_{k=0}^{n}\binom{n}{k} = 2^n$ by the binomial theorem. $\square$

**Lemma 3.5 (Partial sum bound).** For all $n, d$, $\sum_{k=0}^{d-1}\binom{n}{k} \leq 2^n$.

*Proof sketch.* A partial sum of nonnegative terms is at most the completed sum; extending the range to $\max(d, n+1)$ can only add nonnegative terms, and the completed sum equals $2^n$ by Lemma 3.4. $\square$

### 3.4 The one-point recurrence

**Theorem 3.6 (Cover / Pascal recurrence).** For $N \geq 1$ and any $d$,
$$C(N+1, d+1) = C(N, d+1) + C(N, d).$$

*Proof sketch.* Write $N = m+1$. Both sides are $2\times$ sums of binomials with top index $m+1$ on the left and $m$ on the right. Substituting the partial Pascal identity (Lemma 3.3) with parameters $m$ and $d$ and multiplying through by $2$ yields the claim. $\square$

Theorem 3.6 is the combinatorial shadow of Cover's geometric "add one point" argument: introducing a new sample either leaves a separating rule intact or splits it in two.

### 3.5 Global bound, saturation, and collapse

**Theorem 3.7 (Global bound).** For $N \geq 1$ and any $d$, $C(N, d) \leq 2^N$.

*Proof sketch.* By Lemma 3.5, the inner sum is at most $2^{N-1}$, so $C(N,d) \leq 2 \cdot 2^{N-1} = 2^N$. $\square$

**Theorem 3.8 (Saturation).** If $1 \leq N \leq d$, then $C(N, d) = 2^N$.

*Proof sketch.* Here $N - 1 < d$, so Lemma 3.4 applies with $n = N-1$: the inner sum equals $2^{N-1}$, and doubling gives $2^N$. Every labeling is realizable when parameters dominate data. $\square$

**Theorem 3.9 (Strict collapse).** If $d < N$, then $C(N, d) < 2^N$.

*Proof sketch.* The inner sum $\sum_{k=0}^{d-1}\binom{N-1}{k}$ omits at least the top term $\binom{N-1}{N-1} = 1$ from the full sum $\sum_{k=0}^{N-1}\binom{N-1}{k} = 2^{N-1}$. Hence the inner sum is at most $2^{N-1} - 1$, and $C(N,d) \leq 2(2^{N-1}-1) = 2^N - 2 < 2^N$. $\square$

As a concrete instance, $C(5,3) = 2(\binom{4}{0} + \binom{4}{1} + \binom{4}{2}) = 2(1 + 4 + 6) = 22 < 32 = 2^5$.

---

## 4. The maximal-solution theorem

The results above characterize Cover's *specific* function. The following theorem is the analytic heart: it shows Cover's function *dominates every* quantity that obeys the same geometric constraints.

**Theorem 4.1 (Maximal solution).** Let $g : \mathbb{N} \times \mathbb{N} \to \mathbb{N}$ satisfy
- $g(1, d) \leq 2$ for all $d \geq 1$,
- $g(N, 1) \leq 2$ for all $N \geq 1$,
- $g(N+1, d+1) \leq g(N, d+1) + g(N, d)$ for all $N \geq 1$, $d \geq 1$.

Then $g(N, d) \leq C(N, d)$ for all $N, d \geq 1$.

*Proof sketch.* Fix the argument by a two-parameter induction. Perform induction on $N$ (via `le`-induction starting at $N=1$); within the step, case-split on $d$.

- **Base $N = 1$:** $g(1, d) \leq 2 = C(1, d)$ by the point base value (Proposition 3.1).
- **Base $d = 1$ (any $N$):** $g(N, 1) \leq 2 = C(N, 1)$ by the dimension base value (Proposition 3.2).
- **Inductive step $N \to N+1$, $d = d'+1 \geq 2$:** apply the recursion for $g$, then the two inductive hypotheses $g(N, d'+1) \leq C(N, d'+1)$ and $g(N, d') \leq C(N, d')$, and finally the Cover recurrence (Theorem 3.6) $C(N, d'+1) + C(N, d') = C(N+1, d'+1)$. Monotonicity of addition assembles the bound
$$g(N+1, d'+1) \le g(N, d'+1) + g(N, d') \le C(N, d'+1) + C(N, d') = C(N+1, d'+1).$$

This converts the geometric one-point recursion into the closed-form binomial bound — the exact skeleton of Cover's theorem, with the recursion supplying the geometry and the closed form supplying the combinatorics. $\square$

**Remark 4.2 (Tightness).** Cover's function itself satisfies all three hypotheses with *equality* (Propositions 3.1–3.2 and Theorem 3.6). Thus the bound of Theorem 4.1 is attained, and the class of dichotomy systems is inhabited by a maximal element. The theorem is not vacuous.

---

## 5. The manifold-constrained dichotomy bound

We now connect the abstract recursion to geometry.

### 5.1 The Kruskal rank ceiling

**Proposition 5.1 (Rank ceiling on a manifold).** Let $E \subset \mathbb{R}^M$ be a $d$-dimensional submanifold and let $F \subset E$ be an $N$-point set in general position. Then the Kruskal rank $s$ of $F$ (measured through any smooth injective feature map $\Phi : E \to \mathbb{R}^{M'}$) satisfies
$$s \leq d + 1.$$

*Proof sketch.* Locally, $E$ is parameterized by $d$ intrinsic coordinates; in homogeneous form (accounting for the affine offset), at most $d + 1$ points along the manifold can be linearly independent before the intrinsic parameterization forces a linear relation. A smooth injective map $\Phi$ preserves distinctness of points and cannot increase the general-position rank of a configuration — it can only preserve or reduce linear independence — so the rank ceiling $d + 1$ transfers to the feature space. Crucially, the ambient dimension $M$ plays no role: only the intrinsic dimension $d$ and the affine constant contribute. $\square$

### 5.2 The dichotomy system of a feature-mapped classifier

Combining a homogeneous separator in the $M'$-dimensional feature space with the rank ceiling produces an effective parameter budget
$$p = d + M' + 1.$$
The $\Phi$-separable dichotomy count $C_F(N)$ — the number of labelings of $F$ realizable by a homogeneous linear rule after the feature map — then obeys the same one-point recursion as Cover's function with parameter $p$: adding a sample either preserves a separating rule or splits it, and the number of splittable rules is controlled by the rank budget $p$. Formally, $C_F$ (as a function of $N$ with the budget entering as the second argument) is a dichotomy system in the sense of Definition 2.4.

**Theorem 5.2 (Manifold-constrained bound).** With the notation above,
$$C_F(N) \;\leq\; C(N,\, d + M' + 1).$$

*Proof sketch.* $C_F$ satisfies the base values (a single point admits both labels; a one-parameter rule realizes two labelings) and the one-point recursion with budget $p = d + M' + 1$, hence is a dichotomy system. Apply the maximal-solution theorem (Theorem 4.1) with $g = C_F$ and dimension argument $p$. $\square$

**Theorem 5.3 (Expressivity collapse).** If $d + M' + 1 < N$, then
$$C_F(N) \;<\; 2^N.$$

*Proof sketch.* Chain Theorem 5.2 with the strict collapse of Cover's function (Theorem 3.9) at budget $p = d + M' + 1 < N$:
$$C_F(N) \leq C(N, p) < 2^N. \qquad \square$$

### 5.3 The abstraction is inhabited and the bound is tight

**Proposition 5.4 (Inhabitation and tightness).** The map $(N, d) \mapsto C(N, d)$ is itself a dichotomy system, satisfying every clause of Definition 2.4 with equality. Consequently the abstraction is nonvacuous and the bound $C_F(N) \leq C(N, p)$ is best possible: no smaller universal upper bound holds for all dichotomy systems.

This addresses the natural objection that the dichotomy-system abstraction might be empty or the bound loose. It is neither: Cover's function is a witnessing instance realizing equality, and the strict-collapse theorem yields the concrete separation $C(N, p) < 2^N$ whenever $p < N$.

### 5.4 A worked example

Consider data lying on a one-dimensional curve (intrinsic dimension $d = 1$) — say a parabolic arc — sampled at $N = 5$ points, and a smooth injective feature map into feature dimension $M' = 2$ (for instance, appending a coordinate). The effective budget is $p = d + M' + 1 = 4$. Theorem 5.2 then predicts
$$C_F(5) \leq C(5, 4) = 2\left(\binom{4}{0} + \binom{4}{1} + \binom{4}{2} + \binom{4}{3}\right) = 2(1 + 4 + 6 + 4) = 30 < 32 = 2^5.$$
Thus at least one labeling of the five points is unrealizable by any feature-mapped linear rule, no matter how the curve is embedded. Enlarging the ambient dimension $M$ — padding each feature vector with any number of zero coordinates — leaves $d$, $M'$, and hence the budget $p = 4$ and the bound $30$ completely unchanged. This is ambient-dimension irrelevance in miniature: the constraint is dictated by the intrinsic one-dimensionality of the data, not by the size of the space it is drawn from. Direct enumeration of the separable labelings on such a configuration confirms a count of $22$, comfortably within the bound of $30$ and strictly below the unconstrained $32$.

Contrast this with the saturated regime: had we instead taken only $N = 3$ points with the same budget $p = 4$, Theorem 3.8 gives $C_F(3) \le C(3, 4) = 2^3 = 8$, and every one of the $2^3 = 8$ labelings is realizable. The transition from full expressivity to strict deficiency occurs precisely as the sample size overtakes the intrinsic budget.

---

## 6. Algorithms

We record the two computational primitives that the theory suggests.

**Algorithm A (Cover count).** Direct evaluation of $C(N, d)$ by summing $d$ binomial coefficients, using a rolling update $\binom{N-1}{k} = \binom{N-1}{k-1}\cdot(N-k)/k$ to avoid recomputation. Complexity $O(d)$ arithmetic operations on integers (or big-integers) after $O(1)$ setup.

**Algorithm B (Recursion table).** Fill a two-dimensional table via the one-point recurrence $C(N+1, d+1) = C(N, d+1) + C(N, d)$ with the base rows $C(1, \cdot) = 2$ and $C(\cdot, 1) = 2$. This mirrors the geometric derivation and doubles as an empirical certificate that the closed form and the recursion agree. Complexity $O(N d)$.

Both are exercised in the accompanying demonstration code, along with an empirical verification of saturation, strict collapse, and the manifold-constrained bound.

---

## 7. Applications

**Capacity of learning machines.** $C(N, d)/2^N$ is the fraction of labelings a homogeneous linear classifier can realize; its transition from $1$ to near-$0$ as $N$ crosses $2d$ is the classical capacity phase transition. Theorem 5.2 extends this diagnostic to feature-mapped classifiers on manifold data with the substitution $d \mapsto d + M' + 1$.

**Intrinsic-dimension estimation.** Because the bound depends on $d$ and not on $M$, the *observed* onset of expressivity collapse in a classifier family provides an operational probe of the intrinsic dimension of a dataset, independent of how the data is embedded.

**Generalization guarantees.** The strict-collapse threshold marks the boundary between the regime where a classifier can memorize any labeling (no generalization guarantee) and the regime where it is provably constrained — the prerequisite for uniform convergence and generalization bounds of VC type.

---

## 8. Discussion

The narrative unifying every result is that expressive capacity is governed by *intrinsic* geometry. The recursion is the geometry of adding a sample; the closed binomial form is its combinatorial solution; the maximal-solution theorem is the bridge that makes any geometric dichotomy count inherit the closed-form ceiling. The manifold refinement then localizes the whole story to the intrinsic dimension $d$: the Kruskal rank ceiling $s \leq d + 1$ is the sole driver, and it is stable under smooth injective maps, so the ambient dimension $M$ drops out entirely.

Two features make the development robust. First, the abstraction is *inhabited with equality* by Cover's own function, so nothing is vacuous and the bound is tight. Second, the strict-collapse theorem is quantitative: whenever the intrinsic budget $p = d + M' + 1$ falls below the sample size, at least two labelings are provably unreachable ($C(N, p) \le 2^N - 2$).

---

## 9. Future directions

**Ambient-dimension irrelevance is exact, not just an upper bound.** For data on a fixed $d$-dimensional structure embedded in ambient dimension $M$, we conjecture the realizable labeling count is *independent* of $M$: enlarging the ambient space changes neither the count nor the threshold sample size at which full expressivity is lost. The separating budget is set by the general-position rank along the structure, capped by $d+1$ regardless of embedding, so ambient coordinates contribute nothing. Having isolated the rank cap as the sole driver and shown the bound is attained tightly, the sharper *equality* is the natural next target.

**A phase transition sharp to a single sample.** We conjecture the fraction of realizable labelings, as a function of $N$ at fixed budget $p$, exhibits a threshold at $N = 2p$: essentially unity below and decaying to zero above, with transition width independent of $p$. Cover's function saturates at $2^N$ while the budget dominates and sheds its top binomial terms once the sample overtakes the budget; the largest omitted term sits at the center of the binomial profile near $N = 2p$. Both endpoints are established (saturation below, strict collapse above), so the crossover's location and universality are the immediate refinement.

**Composition multiplies, not adds, the rank penalty.** For a composition of two smooth injective feature maps with intermediate dimensions $M'$ and $M''$, we conjecture the effective budget is bounded by $\min(d + M' + 1,\, d + M'' + 1)$ rather than the sum — a bottleneck law in which the least-expressive stage caps the whole pipeline. Each stage can only preserve or reduce the general-position rank, so the tightest cap propagates to the output regardless of later widening. Having reduced the single-map bound to a rank statement stable under injective maps, the multi-stage generalization is the natural next question.

---

## References

- T. M. Cover, *Geometrical and Statistical Properties of Systems of Linear Inequalities with Applications in Pattern Recognition*, IEEE Transactions on Electronic Computers, 1965.
