# A Measure-Free Formalization of Erdős–Rényi Threshold Phenomena via the First and Second Moment Methods

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Novelty (Random Graphs / Probabilistic Combinatorics)

---

## Abstract

We present a self-contained, fully finite, measure-theory-free formalization of
the Erdős–Rényi random graph model $G(n,p)$ and of the threshold phenomena that
characterize it. The development rests on a single elementary idea: the
$p$-biased product law on the finite Boolean cube of edge configurations, for
which all probabilities and expectations are ordinary finite sums. From this we
derive, as exact identities, that the law is a probability measure, that edge
events are independent ($\mathbb{P}(\text{all of } S \text{ present}) = p^{|S|}$
and dually $(1-p)^{|S|}$ for absence), and the linearity of expectation for
arbitrary indexed families of subgraph copies. These yield the **first moment
method**: the probability that at least one copy of a structure appears is at
most its expected count. On the analytic side we instantiate the model on the
complete graph over $\mathrm{Fin}\,n$ and compute the exact expected numbers of
edges $\binom{n}{2}p$, isolated vertices $n(1-p)^{n-1}$, and triangles
$\binom{n}{3}p^{3}$. We then prove the threshold behavior: the triangle count's
mean converges to the Poisson constant $c^3/6$ at the critical window $p = c/n$;
it vanishes below the scale $p = 1/n$ (when $np_n \to 0$) and diverges above it
(when $np_n \to \infty$); and the expected number of isolated vertices diverges
at every giant-component scale $p = c/n$, exhibiting the genuine gap between the
giant-component threshold $1/n$ and the connectivity threshold $\ln n / n$.
Finally we develop, on an abstract finite weighted probability space, the
**second moment method** — variance nonnegativity, Markov's inequality,
Chebyshev's inequality, and the bound $\mathbb{P}(X=0) \le
\mathrm{Var}\,X/(\mathbb{E}X)^2$ — supplying the "above threshold" half of the
threshold method. All results are formalized and machine-checked.

---

## 1. Introduction

The theory of random graphs, initiated by Erdős and Rényi in a sequence of
papers beginning in 1959, studies the typical structure of a graph chosen at
random. In the binomial model $G(n,p)$ one fixes $n$ labelled vertices and
includes each of the $\binom{n}{2}$ potential edges independently with
probability $p$. The defining discovery of the subject is that monotone
structural properties — containing a triangle, possessing a giant component,
being connected — appear not gradually but at **sharp thresholds**: critical
densities $p^*(n)$ such that the property holds with probability tending to $1$
above the threshold and to $0$ below it.

The two foundational techniques for locating thresholds are the **first moment
method** (if the expected number of witnesses to a property tends to $0$, the
property fails with high probability) and the **second moment method** (if the
expected count grows and its variance is controlled, the property holds with
high probability). These methods, together with exact expectation computations,
suffice to pin down the most celebrated thresholds:

- the **subgraph thresholds**, e.g. triangles at $p = 1/n$ and, more generally,
  the clique $K_r$ at $p = n^{-2/(r-1)}$;
- the **giant-component transition** at $p = 1/n$; and
- the **connectivity threshold** at $p = \ln n / n$, governed by the
  disappearance of isolated vertices.

This paper formalizes the model and the moment methods in a deliberately
elementary way, avoiding measure theory entirely. Because the configuration
space $E \to \mathrm{Bool}$ is finite, every probability is a finite sum and
every expectation a finite weighted sum; all the classical identities become
pure finite-sum algebra. We then apply the machinery to obtain exact
expectations and the asymptotic threshold statements above.

### Contributions

1. A measure-free model of $G(n,p)$ as a $p$-biased product weight on
   $E \to \mathrm{Bool}$, with proofs that it is a probability law and that edge
   events are independent (§3).
2. Linearity of expectation for subgraph counts and the first moment inequality
   (§3).
3. Exact expected counts of edges, isolated vertices, and triangles on the
   complete graph over $\mathrm{Fin}\,n$ (§4).
4. The triangle threshold: convergence to the Poisson mean $c^3/6$ at $p=c/n$,
   subcritical vanishing, and supercritical blow-up; plus the isolated-vertex
   blow-up separating the giant-component scale from connectivity (§5).
5. The second moment method on an abstract finite weighted probability space:
   variance nonnegativity, Markov, Chebyshev, and the $\mathbb{P}(X=0)$ bound
   (§6).
6. The general clique generalization $\mathbb{E}[\#K_r] = \binom{n}{r}
   p^{\binom{r}{2}}$ and its subcritical threshold (§7).

---

## 2. Preliminaries and Notation

Throughout, $E$ is a finite type of *potential edges* and a *configuration* is a
function $g : E \to \mathrm{Bool}$, with $g(e) = \mathtt{true}$ meaning edge $e$
is present. For a real parameter $p$ (intended in $[0,1]$) we write $\bar p = 1 -
p$. For a finite set $S$ of edges, $|S|$ denotes its cardinality and $S^c = E
\setminus S$ its complement. We write $\binom{n}{k}$ for binomial coefficients
and $(\cdot)$ atTop limits for the usual $n \to \infty$.

---

## 3. The Model and the First Moment Method

### 3.1 The $p$-biased law

**Definition 3.1 (Weight).** The *weight* of a configuration $g : E \to
\mathrm{Bool}$ at parameter $p$ is

$$ \mathrm{weight}(p, g) \;=\; \prod_{e \in E} \big( g(e)\ ?\ p : 1-p \big), $$

i.e. the product over all potential edges of $p$ for present edges and $1-p$ for
absent edges.

**Proposition 3.2 (Nonnegativity, `weight_nonneg`).** If $0 \le p \le 1$ then
$\mathrm{weight}(p,g) \ge 0$ for every $g$.

*Proof sketch.* Each factor lies in $[0,1]$; a product of nonnegative reals is
nonnegative. $\square$

**Theorem 3.3 (Total mass, `sum_weight`).** For every $p$,

$$ \sum_{g : E \to \mathrm{Bool}} \mathrm{weight}(p, g) \;=\; 1. $$

*Proof sketch.* Sum-of-products over the Boolean cube factors as a product of
column sums (the distributive law `Finset.prod_univ_sum`): summing a function
over all $g : E \to \mathrm{Bool}$ of a product $\prod_e f_e(g(e))$ equals
$\prod_e \sum_{b \in \mathrm{Bool}} f_e(b)$. Here each column sum is $p + (1-p) =
1$, so the whole product is $1$. $\square$

**Definition 3.4 (Probability and expectation).** For an event $A$ (a finite set
of configurations) and a random variable $X : (E \to \mathrm{Bool}) \to
\mathbb{R}$,

$$ \mathrm{prob}(p, A) = \sum_{g \in A} \mathrm{weight}(p, g), \qquad
\mathbb{E}_p[X] = \sum_{g} \mathrm{weight}(p, g)\, X(g). $$

### 3.2 Independence of edge events

**Definition 3.5.** For $S \subseteq E$, let $\mathrm{allPresent}(S) = \{ g :
\forall e \in S,\ g(e) = \mathtt{true}\}$ and $\mathrm{allAbsent}(S) = \{ g :
\forall e \in S,\ g(e) = \mathtt{false}\}$.

**Theorem 3.6 (Independence, `prob_allPresent`).** For every $S \subseteq E$,

$$ \mathrm{prob}\big(p, \mathrm{allPresent}(S)\big) = p^{|S|}. $$

*Proof sketch.* Split the weight product over $S$ and $S^c$. On the event
$\mathrm{allPresent}(S)$ every edge of $S$ is present, contributing $\prod_{e \in
S} p = p^{|S|}$; the remaining factors range over all configurations of $S^c$
and sum to $1$ by Theorem 3.3 applied to the complement type. A bijection
between the relevant configurations and the configurations of $S^c$ makes this
precise. $\square$

**Theorem 3.7 (Dual independence, `prob_allAbsent`).** For every $S \subseteq
E$,

$$ \mathrm{prob}\big(p, \mathrm{allAbsent}(S)\big) = (1-p)^{|S|}. $$

*Proof sketch.* Apply the symmetry $p \leftrightarrow 1-p$ (negating every bit
of $g$) to Theorem 3.6. $\square$

### 3.3 Linearity of expectation and the first moment inequality

**Definition 3.8 (Subgraph count).** Given an indexed family of edge sets $S :
\iota \to \mathcal{P}(E)$ over a finite index $\iota$, the *subgraph count* of a
configuration $g$ is the number of copies present:

$$ \mathrm{subgraphCount}(S, g) = \big| \{ i \in \iota : \forall e \in S_i,\ g(e) = \mathtt{true} \} \big|. $$

**Theorem 3.9 (Linearity of expectation, `expectation_subgraphCount`).**

$$ \mathbb{E}_p\big[\mathrm{subgraphCount}(S, \cdot)\big] = \sum_{i \in \iota} p^{|S_i|}. $$

*Proof sketch.* Write the count as a sum of indicators, $\mathrm{subgraphCount}
= \sum_i \mathbf{1}[\text{copy } i \text{ present}]$, exchange the order of
summation (`Finset.sum_comm`), and apply Theorem 3.6 to each term. $\square$

**Corollary 3.10 (Uniform copies, `expectation_subgraphCount_uniform`).** If
$|S_i| = k$ for all $i$, then $\mathbb{E}_p[\mathrm{subgraphCount}(S,\cdot)] =
|\iota| \cdot p^{k}$.

**Theorem 3.11 (First moment method, `firstMoment`).** For $0 \le p \le 1$,

$$ \mathrm{prob}\big(p,\ \{ g : \mathrm{subgraphCount}(S, g) \ge 1 \}\big) \;\le\; \sum_{i \in \iota} p^{|S_i|}. $$

*Proof sketch.* The indicator $\mathbf{1}[\mathrm{subgraphCount} \ge 1]$ is
pointwise bounded by $\mathrm{subgraphCount}$ itself; multiply by the
nonnegative weights and sum, then invoke Theorem 3.9. This is Markov's
inequality at level $1$. $\square$

A general restatement (`expectation_count`) records that for any finite family
of events $A_i$, the expected number that occur equals $\sum_i
\mathrm{prob}(p, A_i)$.

---

## 4. Exact Expectations on the Complete Graph

We now instantiate $E$ as the edge type of the complete graph on $n$ labelled
vertices.

**Definition 4.1 (Edges).** $\mathrm{Edge}(n) = \{ (i,j) \in \mathrm{Fin}\,n
\times \mathrm{Fin}\,n : i < j \}$, the ordered pairs of distinct vertices.

**Theorem 4.2 (`card_edge`).** $|\mathrm{Edge}(n)| = \binom{n}{2}$.

*Proof sketch.* Count pairs $i < j$: summing $\#\{ i : i < j\} = j$ over $j$
gives $\sum_{j} j = \binom{n}{2}$. $\square$

**Theorem 4.3 (Expected edges, `expected_edges`).**

$$ \mathbb{E}_p[\#\text{edges}] = \binom{n}{2}\, p. $$

*Proof sketch.* Index copies by single edges (each $S_e = \{e\}$, $|S_e| = 1$)
and apply Corollary 3.10 with $k = 1$ and $|\iota| = |\mathrm{Edge}(n)| =
\binom{n}{2}$. $\square$

**Definition 4.4 (Incident edges).** $\mathrm{incident}(v)$ is the set of edges
of $\mathrm{Edge}(n)$ having $v$ as an endpoint.

**Theorem 4.5 (`card_incident`).** $|\mathrm{incident}(v)| = n - 1$.

*Proof sketch.* The map $u \mapsto \{u, v\}$ is a bijection from the other $n-1$
vertices onto the edges at $v$. $\square$

**Theorem 4.6 (Expected isolated vertices, `expected_isolated`).**

$$ \mathbb{E}_p[\#\text{isolated vertices}] = n\,(1 - p)^{\,n-1}. $$

*Proof sketch.* A vertex $v$ is isolated iff all $n-1$ edges of
$\mathrm{incident}(v)$ are absent, which by Theorem 3.7 has probability
$(1-p)^{n-1}$. Sum over the $n$ vertices via `expectation_count`. $\square$

**Definition 4.7 (Spanned edges).** For a vertex set $T$,
$\mathrm{triEdges}(T)$ is the set of edges with both endpoints in $T$.

**Theorem 4.8 (`card_triEdges`).** If $|T| = 3$ then $|\mathrm{triEdges}(T)| =
3$.

*Proof sketch.* The edges spanned by $T$ correspond bijectively to the
$2$-element subsets of $T$, of which there are $\binom{3}{2} = 3$. $\square$

**Theorem 4.9 (Expected triangles, `expected_triangles`).**

$$ \mathbb{E}_p[\#\text{triangles}] = \binom{n}{3}\, p^{3}. $$

*Proof sketch.* Index triangles by $3$-element vertex subsets $T$ (there are
$\binom{n}{3}$). Each demands the $3$ edges of $\mathrm{triEdges}(T)$, present
with probability $p^3$ by Theorems 3.6 and 4.8. Sum via `expectation_count`.
$\square$

---

## 5. Triangle and Isolated-Vertex Thresholds

We now study the asymptotics of the exact expectations as $n \to \infty$.

### 5.1 The critical window for triangles

**Theorem 5.1 (Poisson mean, `tendsto_expected_triangles`).** For every real
$c$,

$$ \binom{n}{3}\left(\frac{c}{n}\right)^{3} \xrightarrow[n\to\infty]{} \frac{c^{3}}{6}. $$

*Proof sketch.* For $n \ge 3$, $\binom{n}{3} = \frac{n(n-1)(n-2)}{6}$, so

$$ \binom{n}{3}\left(\frac{c}{n}\right)^3 = \frac{c^3}{6}\left(1 - \tfrac1n\right)\left(1 - \tfrac2n\right), $$

and each factor $\to 1$. $\square$

The limit $c^3/6$ is exactly the mean of the Poisson distribution that governs
the triangle count in the critical window $p = c/n$; the same expression
transported through `expected_triangles` gives the statement directly for the
$G(n,p)$ expectation (`tendsto_ER_expected_triangles`).

### 5.2 Subcritical and supercritical regimes

**Theorem 5.2 (Subcritical vanishing, `subcritical_triangles_vanish`).** Let
$p_n \ge 0$ with $n\,p_n \to 0$. Then

$$ \binom{n}{3}\,p_n^{3} \xrightarrow[n\to\infty]{} 0. $$

*Proof sketch.* Using $\binom{n}{3} \le n^3/6$, squeeze
$0 \le \binom{n}{3} p_n^3 \le (n p_n)^3 / 6 \to 0$. Combined with the first
moment method (Theorem 3.11), this shows $G(n, p_n)$ is triangle-free with high
probability below the scale $p = 1/n$. $\square$

**Theorem 5.3 (Supercritical blow-up, `supercritical_triangles_blowup`).** Let
$p_n \ge 0$ with $n\,p_n \to \infty$. Then

$$ \binom{n}{3}\,p_n^{3} \xrightarrow[n\to\infty]{} \infty. $$

*Proof sketch.* For $n \ge 6$, $\binom{n}{3} \ge n^3/162$, so
$\binom{n}{3} p_n^3 \ge (n p_n)^3 / 162 \to \infty$. The diverging mean is the
prerequisite for the second moment method to conclude triangles appear with high
probability. $\square$

### 5.3 The connectivity gap

**Theorem 5.4 (Isolated-vertex blow-up, `isolated_blowup_below_connectivity`).**
For every real $c$,

$$ n\,\left(1 - \frac{c}{n}\right)^{\,n-1} \xrightarrow[n\to\infty]{} \infty. $$

*Proof sketch.* The classical limit $(1 - c/n)^{n-1} \to e^{-c}$ (via
$(1 + x/n)^n \to e^x$ and dividing out one factor) gives an expected isolated
count asymptotic to $n\,e^{-c}$, which diverges. $\square$

**Interpretation.** At the giant-component scale $p = c/n$, the expected number
of isolated vertices diverges for every constant $c$. Since a connected graph
admits no isolated vertex, connectivity is impossible at this scale; it must
await the strictly larger density $p = \ln n / n$, where $n(1-p)^{n-1} \approx
n \cdot n^{-1} = 1$ enters the critical window. This formally exhibits the gap
of a factor $\ln n$ between the giant-component threshold $1/n$ and the
connectivity threshold $\ln n / n$. The same statement is recorded directly for
the $G(n,p)$ expectation in `tendsto_ER_expected_isolated`.

---

## 6. The Second Moment Method

To supply the "above threshold" direction in full generality we work on an
abstract finite weighted probability space: a finite type $\Omega$ with weights
$w : \Omega \to \mathbb{R}$ satisfying $w \ge 0$ and $\sum_\omega w_\omega = 1$.
For $X : \Omega \to \mathbb{R}$,

$$ \mathbb{E}[X] = \sum_\omega w_\omega X_\omega, \qquad \mathrm{Var}\,X = \mathbb{E}[X^2] - (\mathbb{E}X)^2. $$

**Theorem 6.1 (Variance nonnegativity, `variance_nonneg`).** $\mathrm{Var}\,X
\ge 0$.

*Proof sketch.* $\mathrm{Var}\,X = \sum_\omega w_\omega (X_\omega -
\mathbb{E}X)^2$, a sum of nonnegative terms (expand the square and use
$\sum w = 1$). This is the Cauchy–Schwarz/Jensen inequality in disguise.
$\square$

**Theorem 6.2 (Markov, `markov`).** If $X \ge 0$ pointwise and $a$ is a
threshold, then

$$ a \cdot \mathrm{prob}\big(X \ge a\big) \le \mathbb{E}[X]. $$

*Proof sketch.* On the event $\{X \ge a\}$, $a\,w_\omega \le w_\omega X_\omega$;
sum over the event and extend the bound to all of $\Omega$ using nonnegativity.
$\square$

**Theorem 6.3 (Chebyshev, `chebyshev`).** For $a > 0$,

$$ \mathrm{prob}\big(|X - \mathbb{E}X| \ge a\big) \le \frac{\mathrm{Var}\,X}{a^{2}}. $$

*Proof sketch.* Apply Markov (Theorem 6.2) to the nonnegative random variable
$(X - \mathbb{E}X)^2$ at level $a^2$, noting $\mathbb{E}[(X-\mathbb{E}X)^2] =
\mathrm{Var}\,X$ and that $|X - \mathbb{E}X| \ge a \iff (X - \mathbb{E}X)^2 \ge
a^2$. $\square$

**Theorem 6.4 (Second moment method, `second_moment_zero`).** If $\mathbb{E}[X]
> 0$ then

$$ \mathrm{prob}\big(X = 0\big) \le \frac{\mathrm{Var}\,X}{(\mathbb{E}X)^{2}}. $$

*Proof sketch.* The event $\{X = 0\}$ is contained in $\{ |X - \mathbb{E}X| \ge
\mathbb{E}X \}$ because $X = 0$ forces $|X - \mathbb{E}X| = \mathbb{E}X$; apply
Chebyshev with $a = \mathbb{E}X$. $\square$

**Threshold corollary (informal).** If $X_n$ counts copies of a structure with
$\mathbb{E}[X_n] \to \infty$ and $\mathrm{Var}(X_n)/(\mathbb{E}X_n)^2 \to 0$,
then $\mathrm{prob}(X_n = 0) \to 0$, i.e. the structure appears with high
probability. Paired with the first moment method (Theorem 3.11), this yields
both directions of every monotone subgraph threshold.

---

## 7. The General Clique Threshold

The triangle results are the $r = 3$ instance of a uniform family over all
clique sizes. A copy of the complete graph $K_r$ occupies an $r$-element vertex
set $T$ and requires all $\binom{r}{2}$ edges spanned by $T$.

**Theorem 7.1 (Expected cliques).** Indexing copies of $K_r$ by $r$-element
vertex subsets,

$$ \mathbb{E}_p[\#K_r] = \binom{n}{r}\, p^{\binom{r}{2}}. $$

*Proof sketch.* There are $\binom{n}{r}$ vertex subsets; each spans
$\binom{r}{2}$ edges, present with probability $p^{\binom{r}{2}}$ by the
independence identity (Theorem 3.6). Linearity of expectation (Theorem 3.9)
sums the contributions. For $r = 3$ this recovers $\binom{n}{3}p^3$. $\square$

**Theorem 7.2 (Subcritical clique vanishing).** If $p_n \ge 0$ and
$n^{r}\,p_n^{\binom{r}{2}} \to 0$, then $\mathbb{E}_p[\#K_r] \to 0$, and hence by
the first moment method $G(n, p_n)$ is $K_r$-free with high probability.

*Proof sketch.* Squeeze $0 \le \binom{n}{r} p_n^{\binom{r}{2}} \le n^{r}
p_n^{\binom{r}{2}} \to 0$ using $\binom{n}{r} \le n^r$. Since $n^r =
\big(n^{2/(r-1)}\big)^{\binom{r}{2}}$, the integer-power hypothesis $n^r
p_n^{\binom{r}{2}} \to 0$ is exactly the classical fractional threshold
$n^{2/(r-1)} p_n \to 0$, i.e. $p_n = o\big(n^{-2/(r-1)}\big)$. $\square$

Thus each clique $K_r$ has appearance threshold $p = n^{-2/(r-1)}$, an ordered
hierarchy in which larger cliques require denser graphs; the triangle threshold
$p = 1/n$ is the case $r = 3$.

---

## 8. Algorithmic and Numerical Aspects

All the expectations above are exact, finite, and directly computable. The
expected counts $\binom{n}{2}p$, $\binom{n}{3}p^3$, $n(1-p)^{n-1}$, and
$\binom{n}{r}p^{\binom{r}{2}}$ are closed forms evaluable in constant time given
binomial coefficients. The threshold predictions are testable by direct Monte
Carlo simulation of $G(n,p)$: sampling each edge independently, counting
triangles or isolated vertices, and comparing the empirical mean to the closed
form validates the linearity-of-expectation identities, while sweeping $p$
across $c/n$ and $\ln n / n$ exhibits the sharp transitions. The companion
`demo.py` performs exactly these computations and comparisons.

---

## 9. Discussion

The formalization is intentionally minimal. By representing $G(n,p)$ as a
$p$-biased product weight on a finite Boolean cube, every probabilistic
statement becomes a finite identity provable by elementary algebra of sums and
products — no $\sigma$-algebras, no integration theory. The two pillars, the
first and second moment methods, are likewise reduced to: a single application
of the distributive law (total mass), a complement-splitting bijection
(independence), summation exchange (linearity), and one weighted Cauchy–Schwarz
inequality (variance, hence Chebyshev and the second moment bound). This economy
makes the development verify in isolation and renders the logical dependencies
transparent.

A notable structural point is that the first moment inequality and linearity of
expectation are stated for *arbitrary* finite indexed families of edge sets.
Consequently the same engine that yields the triangle threshold yields, with no
new probabilistic input, the general clique threshold (§7) and — by changing
only the combinatorial inputs (number of copies and edges per copy) — the
thresholds for arbitrary fixed subgraphs.

---

## 10. Future Directions

The disappearance (first-moment) direction of the clique threshold is fully
established; the matching appearance (second-moment) direction, the
balanced-subgraph generalization, and the cycle thresholds are concrete next
targets, detailed below.

**Second-moment appearance for $K_r$.** Prove the sharp converse: with $0 \le
p_n \le 1$, if $n^r p_n^{\binom{r}{2}} \to \infty$ then $\mathbb{P}(G(n,p_n)
\supseteq K_r) \to 1$. The plan is to bound the variance of the clique-count
$X_r$ by controlling covariances over pairs of $r$-sets sharing $j \ge 2$
vertices, show $\mathrm{Var}(X_r)/\mathbb{E}[X_r]^2 \to 0$, and feed it to
`second_moment_zero`. The dominant overlap is $j = r-1$ (a single shared edge of
difference). Testable first at $r = 3$, where the supercritical mean blow-up is
already proved.

**Balanced-subgraph threshold (Bollobás form).** For a fixed graph $H$ define
$m(H) = \max_{H' \subseteq H,\, v(H')>0} e(H')/v(H')$. Then $\mathbb{E}[\#H] =
\Theta(n^{v(H)} p^{e(H)})$ and the appearance threshold is $p = n^{-1/m(H)}$;
for balanced $H$ the subcritical half follows from the same squeeze with
$n^{v(H)} p^{e(H)}$ in place of $n^r p^{\binom{r}{2}}$. The indexed first-moment
engine already covers any finite family of edge sets, so only the copy count
$\Theta(n^{v(H)})$ and the uniform edge count $e(H)$ need instantiation. $K_r$
is the balanced case $m = (r-1)/2$.

**Cycle thresholds all at $1/n$.** For every fixed $k \ge 3$, $\mathbb{E}[\#C_k]
= \frac{(n)_k}{2k} p^k$ (falling factorial over the dihedral symmetry $2k$), so
the $C_k$ appearance threshold is $p = 1/n$ independent of $k$. Subcritical
half: if $n p_n \to 0$ then $0 \le \frac{(n)_k}{2k} p_n^k \le (n p_n)^k \to 0$.
This instantiates the indexed engine with $f$ ranging over cyclic edge sets. The
critical-window Poisson mean is $c^k/(2k)$ (the triangle constant $c^3/6$ is
$k=3$).

---

## References (background reading)

- P. Erdős and A. Rényi, *On the evolution of random graphs* (1960).
- B. Bollobás, *Random Graphs*.
- N. Alon and J. H. Spencer, *The Probabilistic Method*.
- S. Janson, T. Łuczak, A. Ruciński, *Random Graphs*.
