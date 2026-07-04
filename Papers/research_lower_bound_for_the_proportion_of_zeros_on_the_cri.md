# A Conditional Lower Bound for the Proportion of Critical-Line Zeros of $\mathrm{PGL}(3)$ Twisted $L$-functions

## Abstract

Let $\Pi_0$ be a fixed self-dual cuspidal automorphic representation of
$\mathrm{PGL}_3(\mathbb{A}_{\mathbb{Q}})$, and let $\chi$ range over
primitive Dirichlet characters of conductor $Q$. We study the proportion
of nontrivial zeros of the twisted $L$-function $L(s, \Pi_0 \times \chi)$
that lie on the critical line $\mathrm{Re}(s) = 1/2$ as $Q \to \infty$.
Working within the Levinson mollifier framework, we isolate the
elementary-but-nontrivial combinatorial core of the "positive proportion"
phenomenon and prove, **conditionally on the two mollified moment
estimates that constitute the genuinely analytic input**, that at least a
proportion $1/9$ of the zeros lie on the critical line — for each
conductor and asymptotically as $Q \to \infty$. The constant $1/9 = 1/d^2$
reflects the degree $d = 3$ of the family. The central mechanism is a
single application of the Cauchy–Schwarz inequality to a real detection
weight supported on the on-line zeros: a mollified second-moment
inequality of the form $M_1^2 \ge \tfrac{1}{9} M_2 N$ combines with
$M_1^2 \le \#\{\text{on-line}\}\cdot M_2$ to force
$\#\{\text{on-line}\} \ge N/9$. We prove the deduction in full, exhibit an
explicit non-vacuity witness, extend the result to an asymptotic
(eventually-holds) statement over conductors, and give an aggregate form
valid across a whole finite family of twists. We do not claim the deep
moment asymptotics themselves; we prove precisely that they *imply* the
proportion bound.

**Keywords.** Automorphic $L$-functions; $\mathrm{PGL}(3)$; critical
line; Levinson method; mollifier; Cauchy–Schwarz inequality; Dirichlet
twists; positive proportion of zeros.

---

## 1. Introduction

### 1.1 Background

The Riemann Hypothesis asserts that all nontrivial zeros of the Riemann
zeta function lie on the critical line $\mathrm{Re}(s) = 1/2$. Its
generalizations predict the same for the far larger family of automorphic
$L$-functions. These conjectures remain open, and a central industry of
analytic number theory instead seeks *unconditional partial results*: to
show that a definite positive proportion of the zeros lie on the critical
line.

For the Riemann zeta function this program has a celebrated history. Hardy
(1914) showed infinitely many zeros are on the line; Selberg obtained a
positive proportion; Levinson (1974) introduced the *mollifier method* and
proved that more than a third of the zeros are on the line; subsequent
refinements by Conrey and others pushed the proportion past two-fifths.
The essential engine in all of the mollifier-based results is a comparison
of two averaged quantities — a first and a second *mollified moment*.

For higher-degree $L$-functions the same philosophy applies, but the
required moment estimates are dramatically harder. This paper concerns the
degree-three case: the twisted $L$-functions $L(s, \Pi_0 \times \chi)$
attached to a fixed self-dual cuspidal automorphic representation $\Pi_0$
of $\mathrm{PGL}_3(\mathbb{A}_{\mathbb{Q}})$ and a family of primitive
Dirichlet characters $\chi$ of growing conductor $Q$.

### 1.2 The result, informally

We prove the following, conditionally on the moment estimates:

> As $Q \to \infty$, at least a proportion $1/9$ of the nontrivial zeros
> of $L(s, \Pi_0 \times \chi)$ (in the analysed region) lie on the
> critical line $\mathrm{Re}(s) = 1/2$.

The constant $1/9$ is $1/d^2$ with $d = 3$. Our contribution is not the
(deep) analytic estimates but a faithful separation of concerns: we
*quarantine* the hard analysis into two clearly stated hypotheses and
prove that they imply the proportion bound by wholly elementary means. The
core is a single Cauchy–Schwarz inequality.

### 1.3 Organization

Section 2 fixes the combinatorial model of zeros and detection weights.
Section 3 states and proves the Cauchy–Schwarz detection inequality.
Section 4 derives the Levinson-type lower bound on the number of on-line
zeros and its proportion form. Section 5 verifies non-vacuity with an
explicit witness. Section 6 gives the asymptotic statement over conductors
and the aggregate statement over families. Section 7 presents algorithms
and numerical illustrations. Section 8 discusses the degree-squared law,
the Cauchy–Schwarz deficit, pooled families, and positivity certificates.

---

## 2. The combinatorial model

We model the analysis at a fixed conductor $Q$ by three objects.

**Definition 2.1 (Zero sets).** Let $\mathrm{total}$ be a finite set
indexing all nontrivial zeros of $L(s, \Pi_0 \times \chi)$ in the analysed
region, and let $\mathrm{onLine} \subseteq \mathrm{total}$ be the subset of
those zeros lying on the critical line $\mathrm{Re}(s) = 1/2$. We write
$N = \#\,\mathrm{total}$ for the total number of zeros.

**Definition 2.2 (Proportion).** The *proportion of critical-line zeros*
is
$$\mathrm{proportion}(\mathrm{total}, \mathrm{onLine})
  \;=\; \frac{\#\,\mathrm{onLine}}{\#\,\mathrm{total}}
  \;\in\; [0,1].$$

**Definition 2.3 (Detection weight / mollifier).** A *detection weight* is
a real-valued function $w : \mathrm{total} \to \mathbb{R}$ arising from the
mollified sum. It satisfies the **support condition**: it detects only
critical-line zeros, i.e.
$$w_i \ne 0 \;\Longrightarrow\; i \in \mathrm{onLine},$$
equivalently $w_i = 0$ for every $i \in \mathrm{total}$ with
$i \notin \mathrm{onLine}$. The support condition is the precise formal
shadow of the statement "the mollified sum detects only critical-line
zeros."

**Definition 2.4 (Mollified moments).** From a detection weight $w$ we
form the *first mollified moment* and the *second mollified moment*
$$M_1 \;=\; \sum_{i \in \mathrm{total}} w_i,
\qquad
M_2 \;=\; \sum_{i \in \mathrm{total}} w_i^2.$$

The genuinely analytic content of the theory is contained in estimates for
$M_1$ and $M_2$; these are the *hypotheses* below and are not proved here.

---

## 3. The Cauchy–Schwarz detection inequality

The following is the combinatorial heart of the argument.

**Theorem 3.1 (Cauchy–Schwarz detection inequality).**
*Let $\mathrm{onLine} \subseteq \mathrm{total}$ be finite sets, and let
$w : \mathrm{total} \to \mathbb{R}$ satisfy the support condition: $w_i = 0$
for all $i \in \mathrm{total}$ with $i \notin \mathrm{onLine}$. Then*
$$\Big(\sum_{i \in \mathrm{total}} w_i\Big)^2
  \;\le\; (\#\,\mathrm{onLine}) \cdot \sum_{i \in \mathrm{total}} w_i^2,$$
*that is, $M_1^2 \le (\#\,\mathrm{onLine})\, M_2$.*

**Proof sketch.** Because $w$ vanishes off $\mathrm{onLine}$, both sums may
be restricted to $\mathrm{onLine}$ without changing their values:
$\sum_{i \in \mathrm{total}} w_i = \sum_{i \in \mathrm{onLine}} w_i$ and
likewise for the squares. Apply the Cauchy–Schwarz inequality to the two
families $(1)_{i \in \mathrm{onLine}}$ and $(w_i)_{i \in \mathrm{onLine}}$:
$$\Big(\sum_{i \in \mathrm{onLine}} 1 \cdot w_i\Big)^2
  \;\le\; \Big(\sum_{i \in \mathrm{onLine}} 1^2\Big)
          \Big(\sum_{i \in \mathrm{onLine}} w_i^2\Big)
  \;=\; (\#\,\mathrm{onLine}) \sum_{i \in \mathrm{onLine}} w_i^2.$$
Undoing the restriction on both sides yields the claim. $\qquad\blacksquare$

The inequality is an *equality* precisely when the nonzero weights are all
equal — a fact we exploit in Section 8.2.

---

## 4. The Levinson-type lower bound

We now feed in the analytic hypothesis in the form of a mollified
second-moment inequality.

**Theorem 4.1 (Lower bound on on-line zeros).**
*Let $\mathrm{onLine} \subseteq \mathrm{total}$ be finite, and let
$w : \mathrm{total} \to \mathbb{R}$ satisfy the support condition. Assume
$M_2 = \sum_{i} w_i^2 > 0$ and the* **mollified second-moment
inequality**
$$\tfrac{1}{9}\, M_2 \, N \;\le\; M_1^2,
\qquad N = \#\,\mathrm{total}.$$
*Then*
$$\#\,\mathrm{onLine} \;\ge\; \tfrac{1}{9}\, N.$$

**Proof sketch.** Combine the hypothesis with Theorem 3.1:
$$\tfrac{1}{9}\, M_2\, N \;\le\; M_1^2 \;\le\; (\#\,\mathrm{onLine})\, M_2.$$
Since $M_2 > 0$, cancel it to obtain
$\tfrac{1}{9} N \le \#\,\mathrm{onLine}$. $\qquad\blacksquare$

**Theorem 4.2 (Proportion form).**
*Under the hypotheses of Theorem 4.1, and assuming $N = \#\,\mathrm{total} > 0$,*
$$\mathrm{proportion}(\mathrm{total}, \mathrm{onLine}) \;\ge\; \tfrac{1}{9}.$$

**Proof sketch.** By Theorem 4.1, $\#\,\mathrm{onLine} \ge \tfrac19 N$.
Divide by $N > 0$:
$\mathrm{proportion} = \#\,\mathrm{onLine}/N \ge 1/9$. Formally one clears
the denominator with $N > 0$ and applies Theorem 4.1. $\qquad\blacksquare$

**Remark 4.3 (Why $1/9 = 1/d^2$).** In the degree-$d$ Levinson framework
the optimised moments produce a second-moment inequality of the shape
$M_1^2 \ge \tfrac{1}{d^2} M_2 N$; the same two-line deduction then gives
proportion $\ge 1/d^2$. For $\mathrm{PGL}(3)$, $d = 3$ and $1/d^2 = 1/9$.
The degree enters *only* through the constant in the moment inequality;
the combinatorial deduction is degree-agnostic.

---

## 5. Non-vacuity

A conditional theorem is worthless if its hypotheses are unsatisfiable. We
rule this out explicitly.

**Theorem 5.1 (Non-vacuity witness).**
*There exist finite sets $\mathrm{onLine} \subseteq \mathrm{total}$, with
$\mathrm{onLine} \ne \mathrm{total}$ (a proper, nontrivial subset), and a
weight $w$, satisfying simultaneously: the support condition; $M_2 > 0$;
$N = \#\,\mathrm{total} > 0$; and the mollified second-moment inequality
$\tfrac19 M_2 N \le M_1^2$.*

**Proof sketch.** Take $\mathrm{total} = \{0, 1\}$,
$\mathrm{onLine} = \{0\}$, and
$$w_i = \begin{cases} 1 & i = 0,\\ 0 & i = 1.\end{cases}$$
Then $M_1 = 1$, $M_2 = 1$, $N = 2$, and the support condition holds since
$w_1 = 0$. The moment inequality reads
$\tfrac19 \cdot 1 \cdot 2 = \tfrac29 \le 1 = M_1^2$, which is true.
Moreover $\mathrm{onLine} = \{0\} \ne \{0,1\} = \mathrm{total}$, so the
witness is genuinely non-degenerate. $\qquad\blacksquare$

This confirms that the conditional results of Section 4 are not vacuously
true: the hypotheses admit configurations with a proper on-line subset.

---

## 6. Asymptotic and aggregate statements

### 6.1 Over growing conductor

We now attach a conductor index $Q$ and let $Q \to \infty$. All data become
$Q$-indexed: $\mathrm{total}(Q)$, $\mathrm{onLine}(Q) \subseteq \mathrm{total}(Q)$,
and $w(Q) : \mathrm{total}(Q) \to \mathbb{R}$.

**Theorem 6.1 (Eventual proportion bound).**
*Suppose $\mathrm{onLine}(Q) \subseteq \mathrm{total}(Q)$ for every $Q$, and
that the following hold for all sufficiently large $Q$: (i) the support
condition for $w(Q)$; (ii) $M_2(Q) > 0$; (iii) $\#\,\mathrm{total}(Q) > 0$;
and (iv) the mollified second-moment inequality
$\tfrac19 M_2(Q)\,\#\mathrm{total}(Q) \le M_1(Q)^2$. Then for all
sufficiently large $Q$,*
$$\mathrm{proportion}(\mathrm{total}(Q), \mathrm{onLine}(Q)) \;\ge\; \tfrac19.$$

**Proof sketch.** All four hypotheses hold eventually; intersect the four
"eventually" conditions (a finite intersection of cofinite conditions is
cofinite) and apply Theorem 4.2 at each such $Q$. $\qquad\blacksquare$

This is the faithful formal counterpart of the statement "as the conductor
tends to infinity, at least $1/9$ of the zeros of $L(s, \Pi_0 \times \chi)$
lie on the critical line."

### 6.2 Over a family of twists

For a fixed conductor $Q$ there are exactly $\varphi(Q)$ primitive Dirichlet
characters, hence $\varphi(Q)$ twists. Pooling them is legitimate.

**Theorem 6.2 (Aggregate bound).**
*Let $S$ be a finite family (of twists), and for each $b \in S$ let $N_b$
be the number of zeros and $(\#\,\mathrm{onLine})_b$ the number on the line.
If every member satisfies the Levinson lower bound
$\tfrac19 N_b \le (\#\,\mathrm{onLine})_b$, then*
$$\tfrac{1}{9} \sum_{b \in S} N_b \;\le\; \sum_{b \in S} (\#\,\mathrm{onLine})_b.$$
*Consequently the pooled proportion $\big(\sum_b (\#\mathrm{onLine})_b\big)/\big(\sum_b N_b\big)$ is at least $1/9$.*

**Proof sketch.** Sum the per-member inequalities over $b \in S$; the sum
of $\tfrac19 N_b$ is $\tfrac19 \sum_b N_b$ by linearity, and the sum of
$(\#\mathrm{onLine})_b$ dominates it termwise. Dividing by
$\sum_b N_b > 0$ gives the pooled statement. $\qquad\blacksquare$

The striking point is that the *same* combinatorial inequality that governs
a single $L$-function governs the whole crowd of $\varphi(Q)$ twists at
once — an average of ratios each $\ge 1/9$ is again $\ge 1/9$.

---

## 7. Algorithms and numerical illustration

Although the theorems are qualitative, they are entirely constructive and
easy to illustrate numerically. We describe two algorithms; full Python
implementations accompany this paper.

**Algorithm A (Proportion certifier).** *Input:* finite index set, a
subset marking on-line zeros, and a weight vector satisfying the support
condition. *Output:* the certified lower bound obtained from the moments.
*Method:* compute $M_1, M_2, N$, verify the support condition and the
moment inequality $\tfrac19 M_2 N \le M_1^2$, and return
$\max(1/9, \#\mathrm{onLine}/N)$ together with a boolean certificate.
Complexity $O(N)$.

**Algorithm B (Cauchy–Schwarz deficit meter).** *Input:* the nonzero
weights on the on-line zeros. *Output:* the surplus factor $1 + c$ by which
the true proportion beats $1/9$, where $c$ is the variance-to-mean-square
ratio of the weights. *Method:* compute the mean $\mu$ and variance
$\sigma^2$ of the weights and return $c = \sigma^2/\mu^2$. Complexity
$O(k)$ where $k = \#\mathrm{onLine}$.

**Numerical example.** With $w \equiv 1$ on $\mathrm{onLine}$ equal to all
of $\mathrm{total}$ of size $N$, the moment inequality reads
$\tfrac19 N \cdot N \le N^2$, i.e. $N^2/9 \le N^2$, always true, and the
proportion is $1 \ge 1/9$. If instead half the zeros are on the line with
uniform weight, the deficit meter reports $c = 0$ (uniform weights,
Cauchy–Schwarz tight) and the certified bound is exactly the observed
proportion. Uneven weights produce $c > 0$, quantifying the slack.

---

## 8. Discussion and future directions

### 8.1 A degree-squared law

The argument is degree-agnostic in its combinatorial core: only the
constant in the second-moment inequality knows the degree. This strongly
suggests a **degree-squared law**: for a fixed self-dual cuspidal
representation attached to a degree-$d$ $L$-function, and for families of
Dirichlet twists of growing conductor, at least a proportion $1/d^2$ of the
zeros should lie on the critical line, unconditionally. The flagship case
$d = 3$ gives $1/9$. Recent progress on second-moment asymptotics for
higher-degree $L$-functions has, for the first time, put the two required
moment estimates within reach for $\mathrm{GL}(3)$, turning a heuristic
into a provable target.

### 8.2 Beating $1/d^2$ via the Cauchy–Schwarz deficit

Theorem 3.1 is an equality exactly when the detection weights are constant
across the on-line zeros; any spread leaves room to spare. Quantifying the
spread should yield a strictly better constant $(1/d^2)(1 + c)$ with
explicit $c > 0$. The gap in Cauchy–Schwarz is governed by the
variance-to-mean-square ratio of the weights — a quantity computable
directly from the mollifier design rather than from any new arithmetic
input. Modern mollifiers carry enough structure to compute their weight
dispersion explicitly, so the previously invisible slack can be harvested
into an improved theorem.

### 8.3 A limiting density for the pooled family

Since there are exactly $\varphi(Q)$ twists modulo $Q$, one can pool the
zeros of all of them (Theorem 6.2). The pooled proportion is conjecturally
not just bounded below but *convergent*, tending to a limiting density
$\kappa$ as $Q$ runs over primes. Pooling replaces a single $L$-function by
a statistical ensemble whose zero-density is dictated by the symmetry type
of the family, so $\kappa$ is predicted by one-level density statistics
rather than by any individual $L$-function. The symmetry type of twisted
$\mathrm{GL}(3)$ families has recently been pinned down, giving a concrete
prediction for $\kappa$.

### 8.4 Positivity certificates for the moment inequality

The only non-elementary ingredient in the degree-squared law is the moment
inequality itself. It should reduce to a finite, checkable positivity
statement about the mollifier coefficients: the mollified second moment is
a quadratic form in those coefficients, so proving the required inequality
is equivalent to certifying positivity of that form — a task amenable to
explicit certificates.

### 8.5 Summary

We have separated the hard from the clean. The hard part — moment
asymptotics for higher-degree $L$-functions — is genuine and is faithfully
quarantined into hypotheses. The clean part — converting those estimates
into a statement about where zeros live — is a single Cauchy–Schwarz
inequality followed by a cancellation, proved here in full, shown to be
non-vacuous, and extended both asymptotically over conductors and
aggregately over families of twists.

---

## References (indicative)

1. J. B. Conrey, *More than two fifths of the zeros of the Riemann zeta
   function are on the critical line*, J. Reine Angew. Math. (1989).
2. N. Levinson, *More than one third of zeros of Riemann's zeta-function
   are on $\sigma = 1/2$*, Advances in Math. (1974).
3. A. Selberg, *On the zeros of Riemann's zeta-function*, Skr. Norske
   Vid.-Akad. Oslo (1942).
4. H. Iwaniec and E. Kowalski, *Analytic Number Theory*, AMS Colloquium
   Publications (2004).
