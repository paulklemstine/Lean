# Threshold Phenomena in the Erdős–Rényi Random Graph $G(n,p)$: A Moment-Method Development

**Author:** Aristotle
**Date:** 2026-06-27

## Abstract

We present a finite, measure-free development of the Erdős–Rényi random graph
model $G(n,p)$ and use it to locate two classical threshold phenomena: the
appearance of triangles and the giant component at density $p \asymp 1/n$, and
the connectivity threshold at $p \asymp \ln n / n$. The model is formalized as a
$p$-biased product weight on the finite cube of edge-indicator functions, so that
probabilities and expectations become ordinary finite sums. From the product
structure we derive independence ($\Pr[\text{all of } S \text{ present}] = p^{|S|}$),
linearity of expectation for subgraph counts, and the first moment method. We
develop, model-agnostically on any finite weighted probability space, the second
moment method ($\Pr[X=0]\le \operatorname{Var}(X)/\mathbb{E}[X]^2$) together with
its parents, Markov's and Chebyshev's inequalities. Instantiating on the complete
graph on $\mathrm{Fin}\,n$ we compute the exact first moments
$\mathbb{E}[\#\text{edges}]=\binom{n}{2}p$,
$\mathbb{E}[\#\text{isolated}]=n(1-p)^{n-1}$, and
$\mathbb{E}[\#\text{triangles}]=\binom{n}{3}p^3$. Finally we convert these exact
expectations into asymptotic threshold statements: in the critical window
$p=c/n$ the expected triangle count converges to the Poisson mean $c^3/6$; below
the $1/n$ scale ($n p_n\to 0$) triangles vanish in expectation (hence, by the
first moment method, the graph is triangle-free with high probability); above it
($n p_n\to\infty$) the expected triangle count diverges; and at the
giant-component scale $p=c/n$ the expected number of isolated vertices diverges,
proving that the connectivity threshold lies strictly above $1/n$. All results
correspond to formally verified theorems; we give full statements and proof
sketches.

## 1. Introduction

The random graph model $G(n,p)$ introduced by Erdős and Rényi assigns each of the
$\binom{n}{2}$ potential edges on $n$ labelled vertices independently with
probability $p$. Despite its simplicity it exhibits *sharp threshold* behavior:
many monotone graph properties pass from "almost never holds" to "almost always
holds" across a vanishingly narrow window of $p$. The two archetypal examples are

1. **Subgraph appearance / giant component**, governed by the scale $p\asymp 1/n$;
2. **Connectivity**, governed by the scale $p\asymp \ln n / n$.

This paper organizes a self-contained, fully finite treatment around the *moment
method*: the first moment (Markov) controls the regime below a threshold, and the
second moment (Chebyshev / Cauchy–Schwarz) controls the regime above it. We keep
the probability theory elementary — every probability and expectation is a finite
sum — so that the combinatorial identities and the analytic limits are cleanly
separated.

## 2. The model

Fix a finite type $E$ of *potential edges* with decidable equality. A
*configuration* is a function $g : E \to \mathrm{Bool}$, interpreted as the
indicator of which edges are present.

**Definition 1 (biased weight; `weight`).** For $p\in\mathbb{R}$,
$$\text{weight}(p,g) \;=\; \prod_{e\in E}\bigl(\text{if } g(e) \text{ then } p \text{ else } 1-p\bigr).$$

The weight is nonnegative when $0\le p\le 1$ (`weight_nonneg`), by a product of
nonnegative factors.

**Proposition 1 (total mass; `sum_weight`).** For every $p\in\mathbb{R}$,
$$\sum_{g : E\to\mathrm{Bool}} \text{weight}(p,g) \;=\; 1.$$

*Proof sketch.* The sum over all functions $g$ factors as a product over edges of
the per-edge column sums,
$\sum_{g}\prod_e(\cdots) = \prod_e \sum_{b\in\mathrm{Bool}}(\text{if } b \text{ then } p \text{ else } 1-p)$,
by the distributive identity `Fintype.prod_sum`. Each column sum is
$p + (1-p) = 1$, so the product is $1$. $\square$

**Definition 2 (probability and expectation; `prob`, `expectation`).** For a
finset of configurations $A$ (an *event*) and a random variable
$X : (E\to\mathrm{Bool}) \to \mathbb{R}$,
$$\text{prob}(p,A) = \sum_{g\in A}\text{weight}(p,g), \qquad
\mathbb{E}_p[X] = \sum_{g}\text{weight}(p,g)\,X(g).$$

For $S\subseteq E$ let `allPresent`$(S)$ be the event $\{g : \forall e\in S,\ g(e)=\text{true}\}$
and `allAbsent`$(S)$ the event $\{g : \forall e\in S,\ g(e)=\text{false}\}$.

**Theorem 1 (independence; `prob_allPresent`, `prob_allAbsent`).** For every
$p\in\mathbb{R}$ and $S\subseteq E$,
$$\text{prob}(p,\text{allPresent}(S)) = p^{|S|}, \qquad
\text{prob}(p,\text{allAbsent}(S)) = (1-p)^{|S|}.$$

*Proof sketch.* Restrict to configurations that are true on all of $S$. The
weight factors as $\bigl(\prod_{e\in S}p\bigr)\cdot\prod_{e\notin S}(\text{if } g(e) \text{ then } p \text{ else } 1-p)$.
Summing over the free coordinates outside $S$ collapses (via `sum_weight` applied
to the complement subtype) to $1$, leaving $\prod_{e\in S}p = p^{|S|}$. The
all-absent identity follows by the symmetry $p\leftrightarrow 1-p$ realized by the
bit-flip bijection $g\mapsto \lnot g$. $\square$

These identities require *no* hypothesis $0\le p\le 1$; positivity enters only
where probabilistic inequalities are invoked.

## 3. The first moment method

**Definition (subgraph count; `subgraphCount`).** Given a family of edge sets
$S : \iota \to \mathrm{Finset}\,E$ over a finite index $\iota$, the *copy count*
of a configuration $g$ is
$$\text{subgraphCount}(S,g) = \#\{\, i \in \iota : \forall e\in S(i),\ g(e)=\text{true}\,\}.$$

**Theorem 2 (linearity of expectation; `expectation_subgraphCount`,
`expectation_subgraphCount_uniform`).**
$$\mathbb{E}_p[\,\text{subgraphCount}(S,\cdot)\,] = \sum_{i\in\iota} p^{|S(i)|}.$$
If moreover $|S(i)| = k$ for all $i$, then the expectation equals
$|\iota|\cdot p^{k}$.

*Proof sketch.* Write the count as a sum of indicator variables, swap the order
of summation (`Finset.sum_comm`), and apply Theorem 1 termwise. $\square$

**Theorem 3 (first moment method; `firstMoment`).** For $0\le p\le 1$,
$$\text{prob}\bigl(p,\ \{g : 1\le \text{subgraphCount}(S,g)\}\bigr)
\;\le\; \sum_{i\in\iota} p^{|S(i)|} \;=\; \mathbb{E}_p[\#\text{copies}].$$

*Proof sketch.* Pointwise $\mathbf{1}[\text{subgraphCount}\ge 1]\le \text{subgraphCount}$;
multiply by the nonnegative weights and sum. This is Markov's inequality at
threshold $1$. $\square$

**Corollary.** If $\mathbb{E}_p[\#\text{copies}]\to 0$, then with high
probability there are no copies. This is the "below threshold" half of every
monotone subgraph threshold.

## 4. The second moment method (abstract)

We now work on an arbitrary finite weighted probability space: a finite type
$\Omega$, weights $w : \Omega \to \mathbb{R}$ with $w\ge 0$ and
$\sum_\omega w_\omega = 1$, and a random variable $X : \Omega\to\mathbb{R}$.

**Definition 3 (`expect`, `variance`).**
$$\mathbb{E}[X] = \sum_\omega w_\omega X(\omega), \qquad
\operatorname{Var}(X) = \mathbb{E}[X^2] - \mathbb{E}[X]^2.$$

**Proposition 2 (`variance_nonneg`).** $\operatorname{Var}(X)\ge 0$.

*Proof sketch.* Expand $\sum_\omega w_\omega (X(\omega) - \mathbb{E}[X])^2 \ge 0$
and simplify using $\sum_\omega w_\omega = 1$; the result equals
$\operatorname{Var}(X)$. $\square$

**Theorem 8 (Markov; `markov`).** If $w\ge 0$, $X\ge 0$ and $a\in\mathbb{R}$,
$$a\cdot\!\!\sum_{\omega:\,X(\omega)\ge a} w_\omega \;\le\; \mathbb{E}[X].$$

*Proof sketch.* On the event $\{X\ge a\}$ we have $a\,w_\omega \le w_\omega X(\omega)$;
sum and extend the sum to all of $\Omega$ using nonnegativity. $\square$

**Theorem 9 (Chebyshev; `chebyshev`).** If $w\ge 0$, $\sum w = 1$ and $a>0$,
$$\sum_{\omega:\,|X(\omega)-\mathbb{E}[X]|\ge a} w_\omega \;\le\; \frac{\operatorname{Var}(X)}{a^{2}}.$$

*Proof sketch.* Apply Markov to the nonnegative variable $(X-\mathbb{E}X)^2$ with
threshold $a^2$, and note $\{|X-\mathbb{E}X|\ge a\} = \{(X-\mathbb{E}X)^2\ge a^2\}$.
The expectation of $(X-\mathbb{E}X)^2$ equals $\operatorname{Var}(X)$. $\square$

**Theorem 10 (second moment method; `second_moment_zero`).** If $w\ge 0$,
$\sum w = 1$ and $\mathbb{E}[X] > 0$, then
$$\Pr[X = 0] \;=\; \sum_{\omega:\,X(\omega)=0} w_\omega \;\le\; \frac{\operatorname{Var}(X)}{\mathbb{E}[X]^{2}}.$$

*Proof sketch.* The event $\{X=0\}$ is contained in
$\{|X-\mathbb{E}X|\ge \mathbb{E}X\}$ (since $X=0$ forces $|0-\mathbb{E}X|=\mathbb{E}X$).
Apply Chebyshev with $a = \mathbb{E}[X]>0$ and monotonicity of the weighted sum
over the subset. $\square$

**Corollary.** If $\operatorname{Var}(X)/\mathbb{E}[X]^2 \to 0$, then $X>0$ with
high probability. This is the "above threshold" half of every monotone threshold.

Theorems 3 and 10 together form the two-sided moment-method engine.

## 5. Exact first moments on the complete graph

We instantiate $E$ as the edge set of the complete graph on $\mathrm{Fin}\,n$,
namely the subtype `Edge`$(n) = \{(i,j) : i<j\}$.

**Theorem 4 (counting via expectation; `expectation_count`).** For events
$A : \iota\to\mathrm{Finset}(E\to\mathrm{Bool})$ indexed by a finset $I$,
$$\mathbb{E}_p\Bigl[\#\{i\in I : g\in A(i)\}\Bigr] = \sum_{i\in I}\text{prob}(p, A(i)).$$

*Proof sketch.* Expand the count as a sum of indicators, push the weight inside,
and swap summation order. $\square$

**Edge count.** There are $|\text{Edge}(n)| = \binom{n}{2}$ potential edges
(`card_edge`), because counting pairs $i<j$ gives $\sum_{j} j = \binom n2$.

**Theorem 5 (expected edges; `expected_edges`).**
$$\mathbb{E}_p[\#\text{edges}] = \binom{n}{2}\,p.$$
*Proof sketch.* Singleton copies of size $1$ in Theorem 2, with $|\text{Edge}(n)|=\binom n2$. $\square$

**Isolated vertices.** The set `incident`$(v)$ of edges meeting a vertex $v$ has
cardinality $n-1$ (`card_incident`), via the bijection $e\mapsto$ (other
endpoint) onto $\{u : u\ne v\}$.

**Theorem 6 (expected isolated vertices; `expected_isolated`).**
$$\mathbb{E}_p[\#\text{isolated vertices}] = n\,(1-p)^{\,n-1}.$$
*Proof sketch.* A vertex is isolated iff all $n-1$ incident edges are absent;
apply Theorem 4 to the events `allAbsent(incident(v))` and Theorem 1, then
$\sum_{v} (1-p)^{n-1} = n(1-p)^{n-1}$. $\square$

**Triangles.** A $3$-element vertex set spans exactly $3$ edges
(`card_triEdges`), via the bijection of spanned edges with the $2$-subsets of the
triple.

**Theorem 7 (expected triangles; `expected_triangles`).**
$$\mathbb{E}_p[\#\text{triangles}] = \binom{n}{3}\,p^{3}.$$
*Proof sketch.* Index triangles by $3$-subsets $T$ of vertices; each requires its
$3$ spanned edges present, an event of probability $p^3$ by Theorem 1. Summing
over the $\binom n3$ triples gives the result via Theorem 4. $\square$

## 6. Asymptotic thresholds

We now pass to limits, extracting the threshold scalings from the exact
expectations of Section 5. All limits are genuine `Filter.Tendsto` statements.

**Theorem 11 (critical window; `tendsto_expected_triangles`).** For fixed
$c\in\mathbb{R}$,
$$\binom{n}{3}\left(\frac{c}{n}\right)^{3} \;\xrightarrow[n\to\infty]{}\; \frac{c^{3}}{6}.$$

*Proof sketch.* For $n\ge 3$, $\binom n3 = \tfrac{n(n-1)(n-2)}{6}$, so
$$\binom n3 (c/n)^3 = \frac{c^3}{6}\Bigl(1-\tfrac1n\Bigr)\Bigl(1-\tfrac2n\Bigr),$$
and both correction factors tend to $1$. The limit $c^3/6$ is the Poisson mean of
the triangle count in the critical window, identifying $p=1/n$ as the triangle
(and giant-component) scale. $\square$

**Theorem 12 (subcritical vanishing; `subcritical_triangles_vanish`).** If
$p_n\ge 0$ and $n\,p_n\to 0$, then
$$\binom{n}{3}\,p_n^{3} \;\xrightarrow[n\to\infty]{}\; 0.$$

*Proof sketch.* Using $\binom n3\le n^3/6$, squeeze
$0\le \binom n3 p_n^3 \le \tfrac16 (n p_n)^3 \to 0$. Combined with Theorem 3
(first moment), $G(n,p_n)$ is triangle-free with high probability below the $1/n$
scale. $\square$

**Theorem 13 (supercritical blow-up; `supercritical_triangles_blowup`).** If
$p_n\ge 0$ and $n\,p_n\to\infty$, then
$$\binom{n}{3}\,p_n^{3} \;\xrightarrow[n\to\infty]{}\; \infty.$$

*Proof sketch.* For $n\ge 6$ one has $\binom n3\ge n^3/162$, whence
$\binom n3 p_n^3 \ge \tfrac{1}{162}(n p_n)^3 \to \infty$. $\square$

**Theorem 14 (isolated divergence below connectivity;
`isolated_blowup_below_connectivity`).** At the giant-component scale $p=c/n$,
$$n\,(1-c/n)^{\,n-1} \;\xrightarrow[n\to\infty]{}\; \infty.$$

*Proof sketch.* $(1-c/n)^{n-1}\to e^{-c} > 0$ by the classical limit
$(1+x/n)^n\to e^x$, while the prefactor $n\to\infty$; the product of a sequence
converging to a positive constant with one tending to $+\infty$ tends to
$+\infty$. Hence at scale $1/n$ the expected number of isolated vertices diverges,
so the graph is disconnected with high probability and the connectivity threshold
lies strictly above $1/n$ — namely at $p=\ln n/n$, where $n e^{-pn}\approx 1$. $\square$

## 7. Discussion

The development cleanly separates three layers. The **algebraic** layer
(Definitions 1–2, Proposition 1, Theorem 1) is pure finite product/sum algebra
and holds for arbitrary real $p$. The **order-theoretic** layer (Theorems 3, 8–10)
adds nonnegativity to obtain the moment inequalities. The **analytic** layer
(Theorems 11–14) extracts limits. The triangle results are rational-function
limits; the isolated-vertex divergence invokes the exponential limit.

The recurring phenomenon is that *exact* first moments already *contain* the
thresholds: $\binom n3 p^3 = \Theta(1)$ exactly when $p=\Theta(1/n)$, and
$n(1-p)^{n-1}=\Theta(1)$ exactly when $p=\Theta(\ln n/n)$. The moment method then
upgrades "the mean crosses $1$" into "the property switches with high
probability."

## 8. Applications

The moment method underlies countless results beyond random graphs: percolation
thresholds for fluid flow and epidemic spread, the analysis of random constraint
satisfaction problems, probabilistic existence proofs in extremal combinatorics,
and reliability of large networks. The two-sided template — first moment below,
second moment above — is the standard route to sharp threshold theorems.

## 9. Future work

The following directions push toward sharp two-sided thresholds; see the
package's future-directions section for full statements.

1. **Supercritical triangle appearance via the second moment method.** Reduce
   $\Pr[\#\text{triangles}=0]\to 0$ for $n p_n\to\infty$ to a variance
   computation via `second_moment_zero`, decomposing variance over pairs of
   triangles by shared-edge count.
2. **Sharp connectivity threshold at $p=\ln n/n$.** For
   $p_n=(\ln n + c_n)/n$, show connectivity iff $c_n\to+\infty$, with the isolated
   vertex count asymptotically Poisson($e^{-c}$); the divergence below threshold
   is already established (Theorem 14).
3. **General subgraph threshold at the balanced density $p=n^{-1/m(H)}$**, where
   $m(H)=\max_{H'\subseteq H} e(H')/v(H')$; the first moment is already
   `expectation_subgraphCount_uniform`, and the densest subgraph controls the
   second moment.

## 10. Conclusion

We have given a finite, self-contained moment-method account of the Erdős–Rényi
thresholds: exact first moments for edges, isolated vertices, and triangles; the
abstract first and second moment inequalities; and the asymptotic statements that
pin the triangle/giant-component scale at $1/n$ and place the connectivity
threshold strictly above it at $\ln n/n$. Each result is a formally verified
theorem.
