# Threshold Phenomena for the Erdős–Rényi Random Graph $G(n,p)$: A Self-Contained Moment-Method Development

**Author:** Aristotle

**Date:** 2026-06-27

## Abstract

We give a fully finite, measure-free development of the moment-method machinery
underlying threshold phenomena for the Erdős–Rényi random graph $G(n,p)$. The
law of $G(n,p)$ is modelled as a $p$-biased product weight on the finite cube of
edge configurations, so that all probabilities and expectations are ordinary
finite sums and the entire theory reduces to identities over finite sets. Within
this framework we prove: (i) the model is a probability measure
($\sum_g \text{weight}(g) = 1$); (ii) edge independence, namely that a fixed set
$S$ of edges is wholly present with probability $p^{|S|}$ and wholly absent with
probability $(1-p)^{|S|}$; (iii) linearity of expectation for subgraph counts,
giving exact first moments $\binom{n}{2}p$ for edges, $\binom{n}{3}p^3$ for
triangles, and $n(1-p)^{n-1}$ for isolated vertices; (iv) the first moment
method, $\mathbb{P}(N \ge 1) \le \mathbb{E}[N]$; and (v) the second moment method
on a finite weighted probability space — variance nonnegativity, Markov's and
Chebyshev's inequalities, and the bound
$\mathbb{P}(X = 0) \le \mathrm{Var}(X)/(\mathbb{E}[X])^2$. We then extract the
asymptotic threshold scalings: the triangle phase transition at $p = 1/n$ (with
the exact Poisson constant $c^3/6$ in the critical window $p = c/n$, plus
sub- and super-critical dichotomy), and the separation of the giant-component
scale $1/n$ from the connectivity scale $\ln n / n$ via the divergence of the
expected isolated-vertex count at the lower scale. We discuss applications to
epidemics, percolation, and network reliability, and record open targets — the
sharp two-sided connectivity limit $e^{-e^{-c}}$ and the branching-process
analysis of the giant component — as directions for future work.

## 1. Introduction

The Erdős–Rényi random graph $G(n,p)$ is the canonical probabilistic object of
combinatorics: $n$ labelled vertices, with each of the $\binom{n}{2}$ potential
edges present independently with probability $p$. Despite its simplicity, it
exhibits the defining feature of large random systems — *threshold phenomena*, in
which a monotone graph property switches from "almost never true" to "almost
always true" as $p$ crosses a critical scale that is often sharp to within lower-
order terms.

Three thresholds are classical:

1. **Subgraph appearance.** For a fixed balanced graph $H$, copies of $H$ appear
   around $p = n^{-1/m(H)}$ where $m(H)$ is the maximum edge-to-vertex density of
   a subgraph of $H$. For triangles this is $p = 1/n$.
2. **The giant component.** At $p = 1/n$ (average degree $1$), the largest
   connected component jumps from logarithmic to linear size.
3. **Connectivity.** At $p = \ln n / n$, the graph becomes connected, with the
   sharp Poisson-type limit $\mathbb{P}(\text{connected}) \to e^{-e^{-c}}$ when
   $p = (\ln n + c)/n$.

The proofs of the *one-sided* halves of these thresholds rest almost entirely on
two elementary tools: the **first moment method** (a vanishing expected count
forces absence) and the **second moment method** (a large, concentrated expected
count forces presence). This paper develops both, together with the exact first
moments and the asymptotic extractions, in a finite, self-contained framework.

Our design choice is deliberate: rather than invoking measure-theoretic
probability, we model the law of $G(n,p)$ as a finite product weight on the cube
of configurations. Every probability is then a finite sum, independence becomes a
factorization of a product over edges, and linearity of expectation is a
rearrangement of a double sum. This keeps the development elementary and modular.

## 2. The model

Fix a finite type $E$ of *potential edges* (later, the ordered pairs $i < j$ of
vertices). A *configuration* is a Boolean function $g : E \to \{\text{true},
\text{false}\}$ recording which edges are present.

**Definition 2.1 (weight).** For $p \in \mathbb{R}$ the $p$-biased weight of a
configuration $g$ is
$$\text{weight}(p, g) = \prod_{e \in E} \big( [\![ g(e) ]\!]\, p + (1 - [\![ g(e) ]\!])\,(1-p)\big) = \prod_{e \in E}\begin{cases} p & g(e)=\text{true},\\ 1-p & g(e)=\text{false}.\end{cases}$$

**Definition 2.2 (probability and expectation).** The probability of an event
$A$ (a finite set of configurations) is $\mathrm{prob}(p, A) = \sum_{g \in A}
\text{weight}(p, g)$, and the expectation of a random variable
$X : (E \to \text{Bool}) \to \mathbb{R}$ is $\mathbb{E}_p[X] = \sum_g
\text{weight}(p, g)\, X(g)$.

**Lemma 2.3 (nonnegativity).** *If $0 \le p \le 1$ then $\text{weight}(p,g) \ge 0$
for all $g$.*

*Proof sketch.* Each factor is $p \ge 0$ or $1 - p \ge 0$; a product of
nonnegative reals is nonnegative. $\square$

**Theorem 2.4 (the law is a probability measure).**
$$\sum_{g : E \to \text{Bool}} \text{weight}(p,g) = 1.$$

*Proof sketch.* The sum over all Boolean functions of a product over edges
factorizes as a product over edges of the per-edge sum (the distributive law for
sums of products, `Finset.prod_univ_sum`): $\sum_g \prod_e f_e(g(e)) = \prod_e
\sum_{b \in \{\text{true},\text{false}\}} f_e(b)$. Each per-edge fibre sum is
$p + (1-p) = 1$, so the product is $1^{|E|} = 1$. $\square$

In particular $\mathrm{prob}(p, A) \ge 0$ for $0 \le p \le 1$, and the whole
space has probability $1$.

## 3. Independence of edge events

The structural engine of the theory is that disjoint edge events multiply.

**Definition 3.1.** For $S \subseteq E$, let $\mathrm{allPresent}(S) = \{g : g(e)
= \text{true}\ \forall e \in S\}$ and $\mathrm{allAbsent}(S) = \{g : g(e) =
\text{false}\ \forall e \in S\}$.

**Theorem 3.2 (independence, present form).**
$$\mathrm{prob}(p, \mathrm{allPresent}(S)) = p^{|S|}.$$

*Proof sketch.* Partition each edge into the constrained set $S$ and the free
complement $S^c$. The weight of any $g \in \mathrm{allPresent}(S)$ factors as
$\big(\prod_{e \in S} p\big)\cdot \prod_{e \in S^c} (\,\cdot\,)$, where the second
factor ranges freely over configurations of $S^c$. Summing over
$\mathrm{allPresent}(S)$ is therefore a bijection onto all configurations of
$S^c$, whose total weight is $1$ by Theorem 2.4 applied to $S^c$. Hence the sum
equals $p^{|S|} \cdot 1 = p^{|S|}$. $\square$

**Theorem 3.3 (independence, absent form).**
$$\mathrm{prob}(p, \mathrm{allAbsent}(S)) = (1-p)^{|S|}.$$

*Proof sketch.* The bijection $g \mapsto \lnot g$ (flip every edge) maps
$\mathrm{allAbsent}(S)$ to $\mathrm{allPresent}(S)$ and sends $\text{weight}(p,
\cdot)$ to $\text{weight}(1-p, \cdot)$, reducing this to Theorem 3.2 at parameter
$1-p$. $\square$

These two formulas — $p^{|S|}$ and $(1-p)^{|S|}$ — are the only probabilistic
inputs to every first-moment computation below.

## 4. Linearity of expectation and the first moments

**Definition 4.1 (subgraph count).** Given a family of target edge sets
$(S_i)_{i \in \iota}$ indexed by a finite type $\iota$, the *subgraph count* of a
configuration $g$ is the number of indices whose target is wholly present:
$$\mathrm{subgraphCount}(S, g) = \#\{\, i : g(e) = \text{true}\ \forall e \in S_i\,\}.$$

**Theorem 4.2 (linearity of expectation).**
$$\mathbb{E}_p\big[\mathrm{subgraphCount}(S, \cdot)\big] = \sum_{i} p^{|S_i|}.$$

*Proof sketch.* Write the count as a sum of indicators
$\sum_i \mathbf{1}[g \in \mathrm{allPresent}(S_i)]$. By definition of expectation
and Fubini for finite sums, $\mathbb{E}_p[\sum_i \mathbf{1}[\cdots]] = \sum_i
\mathrm{prob}(p, \mathrm{allPresent}(S_i)) = \sum_i p^{|S_i|}$ by Theorem 3.2.
$\square$

**Corollary 4.3 (uniform copies).** If $|S_i| = k$ for all $i$ then
$\mathbb{E}_p[\mathrm{subgraphCount}(S, \cdot)] = (\#\iota)\, p^k$.

We instantiate $E$ as the edge type of the complete graph on $\mathrm{Fin}\,n$,
namely the ordered pairs $\mathrm{Edge}(n) = \{(i,j) : i < j\}$.

**Theorem 4.4 (edge count).** $|\mathrm{Edge}(n)| = \binom{n}{2}$.

*Proof sketch.* Counting pairs $i < j$ gives $\sum_{j} \#\{i : i < j\} =
\sum_{j} j = \binom{n}{2}$. $\square$

**Theorem 4.5 (expected edges).** With each potential edge as its own singleton
target,
$$\mathbb{E}_p[\#\text{edges}] = \binom{n}{2}\, p.$$

*Proof sketch.* Corollary 4.3 with $k = 1$ and $\#\iota = |\mathrm{Edge}(n)| =
\binom{n}{2}$ (Theorem 4.4). $\square$

**Theorem 4.6 (general counting form).** For events $(A_i)_{i \in I}$,
$$\mathbb{E}_p\Big[\#\{i \in I : g \in A_i\}\Big] = \sum_{i \in I} \mathrm{prob}(p, A_i).$$

This is linearity of expectation in its rawest form and feeds the next two
results.

**Theorem 4.7 (expected isolated vertices).** A vertex is *isolated* when all
$n-1$ of its incident edges are absent. Each vertex is incident to exactly $n-1$
edges, hence
$$\mathbb{E}_p[\#\text{isolated vertices}] = n\,(1-p)^{n-1}.$$

*Proof sketch.* Apply Theorem 4.6 with $A_v = \mathrm{allAbsent}(\mathrm{incident}(v))$.
By Theorem 3.3 each term is $(1-p)^{|\mathrm{incident}(v)|} = (1-p)^{n-1}$, and
there are $n$ vertices. The incidence count $n-1$ follows from the bijection
between edges at $v$ and the other $n-1$ vertices. $\square$

**Theorem 4.8 (expected triangles).** Triangles are indexed by $3$-element vertex
subsets; each spans exactly $3$ edges, so
$$\mathbb{E}_p[\#\text{triangles}] = \binom{n}{3}\, p^3.$$

*Proof sketch.* Apply Theorem 4.6 with $A_T = \mathrm{allPresent}(\mathrm{triEdges}(T))$
over the $\binom{n}{3}$ triples $T$. By Theorem 3.2 each term is $p^{3}$ because a
$3$-set spans $\binom{3}{2} = 3$ edges. $\square$

## 5. The first moment method

**Theorem 5.1 (first moment method).** For $0 \le p \le 1$,
$$\mathrm{prob}\big(p,\ \{g : \mathrm{subgraphCount}(S,g) \ge 1\}\big) \;\le\; \sum_i p^{|S_i|} = \mathbb{E}_p[\mathrm{subgraphCount}(S,\cdot)].$$

*Proof sketch.* Pointwise, $\mathbf{1}[\,\mathrm{count} \ge 1\,] \le
\mathrm{count}$, since the indicator is $0$ or $1$ and the count is a nonnegative
integer at least as large whenever the indicator fires. Multiply by the
nonnegative weights and sum: the left side is the probability of the event, the
right side is the expectation, evaluated in Theorem 4.2. $\square$

**Consequence.** If $\mathbb{E}_p[N] \to 0$ then $\mathbb{P}(N \ge 1) \to 0$:
below the relevant scale the structure is absent with high probability. This is
the *one-sided* (subcritical) half of every monotone subgraph threshold.

## 6. The second moment method

We work on a finite weighted probability space: a finite type $\Omega$ with
weights $w : \Omega \to \mathbb{R}$ satisfying $w \ge 0$ and $\sum_\omega
w_\omega = 1$. For $X : \Omega \to \mathbb{R}$ define $\mathbb{E}[X] =
\sum_\omega w_\omega X_\omega$ and $\mathrm{Var}(X) = \mathbb{E}[X^2] -
(\mathbb{E}[X])^2$.

**Theorem 6.1 (variance nonnegativity).** $\mathrm{Var}(X) \ge 0$.

*Proof sketch.* Algebra gives $\mathrm{Var}(X) = \sum_\omega w_\omega (X_\omega -
\mathbb{E}[X])^2$ (expand the square and use $\sum_\omega w_\omega = 1$). Each
term is a nonnegative weight times a square, hence the sum is nonnegative. This is
the weighted Cauchy–Schwarz / Jensen inequality in disguise. $\square$

**Theorem 6.2 (Markov's inequality).** If $X \ge 0$ pointwise and $a > 0$ then
$$a\cdot \mathbb{P}(X \ge a) \le \mathbb{E}[X].$$

*Proof sketch.* On the event $\{X \ge a\}$ we have $a\, w_\omega \le w_\omega
X_\omega$; sum over that event and then extend to all of $\Omega$ by adding the
nonnegative remaining terms $w_\omega X_\omega$. $\square$

**Theorem 6.3 (Chebyshev's inequality).** For $a > 0$,
$$\mathbb{P}\big(|X - \mathbb{E}[X]| \ge a\big) \le \frac{\mathrm{Var}(X)}{a^2}.$$

*Proof sketch.* Apply Markov (Theorem 6.2) to the nonnegative variable
$Y = (X - \mathbb{E}[X])^2$ at level $a^2$, noting $\mathbb{E}[Y] =
\mathrm{Var}(X)$ and that $\{|X - \mathbb{E}[X]| \ge a\} = \{Y \ge a^2\}$ because
$t \mapsto t^2$ is monotone on nonnegatives. $\square$

**Theorem 6.4 (second moment method).** If $\mathbb{E}[X] > 0$ then
$$\mathbb{P}(X = 0) \;\le\; \frac{\mathrm{Var}(X)}{(\mathbb{E}[X])^2}.$$

*Proof sketch.* The event $\{X = 0\}$ is contained in $\{|X - \mathbb{E}[X]| \ge
\mathbb{E}[X]\}$ (at $X = 0$ the deviation is exactly $\mathbb{E}[X]$). Apply
Chebyshev with $a = \mathbb{E}[X] > 0$ and bound the probability of the smaller
event by that of the larger. $\square$

**Consequence.** If $\mathbb{E}[X] \to \infty$ and $\mathrm{Var}(X)/(\mathbb{E}[X])^2
\to 0$, then $\mathbb{P}(X = 0) \to 0$: the object appears with high probability.
This is the *supercritical* half. Pairing Theorem 5.1 (absence below threshold)
with Theorem 6.4 (appearance above threshold) yields the two-sided, sharp
threshold method.

## 7. Asymptotic thresholds

We now extract the threshold scalings from the exact first moments.

### 7.1 The triangle threshold at $p = 1/n$

**Theorem 7.1 (critical window).** At density $p = c/n$,
$$\binom{n}{3}\left(\frac{c}{n}\right)^3 \;\xrightarrow[n\to\infty]{}\; \frac{c^3}{6}.$$

*Proof sketch.* For $n \ge 3$, $\binom{n}{3} = \tfrac{n(n-1)(n-2)}{6}$, so the
expression equals $\tfrac{c^3}{6}(1 - \tfrac1n)(1 - \tfrac2n)$, and the two
parenthetical factors tend to $1$. The limit $c^3/6$ is exactly the Poisson mean
of the triangle count in the critical window. $\square$

**Theorem 7.2 (subcritical vanishing).** If $p_n \ge 0$ and $n\,p_n \to 0$ then
$$\binom{n}{3} p_n^3 \to 0.$$

*Proof sketch.* Squeeze: $0 \le \binom{n}{3} p_n^3 \le \tfrac{n^3}{6} p_n^3 =
\tfrac{(n p_n)^3}{6} \to 0$, using $\binom{n}{3} \le n^3/6$. Combined with the
first moment method (Theorem 5.1), this shows $G(n,p_n)$ is triangle-free with
high probability below the $1/n$ scale. $\square$

**Theorem 7.3 (supercritical blow-up).** If $p_n \ge 0$ and $n\,p_n \to \infty$
then
$$\binom{n}{3} p_n^3 \to \infty.$$

*Proof sketch.* For $n \ge 6$, $\binom{n}{3} \ge n^3/162$, hence
$\binom{n}{3} p_n^3 \ge (n p_n)^3 / 162 \to \infty$ by monotone comparison.
$\square$

### 7.2 Connectivity above the giant-component scale

**Theorem 7.4 (isolated-vertex divergence at scale $1/n$).** For every real $c$,
$$n\left(1 - \frac{c}{n}\right)^{n-1} \;\xrightarrow[n\to\infty]{}\; \infty.$$

*Proof sketch.* The classical limit $(1 - c/n)^n \to e^{-c}$ gives
$(1 - c/n)^{n-1} \to e^{-c} > 0$. Multiplying a sequence converging to a positive
constant by $n \to \infty$ diverges to $+\infty$. $\square$

**Interpretation.** At the giant-component scale $p = c/n$ the expected number of
isolated vertices diverges, so $G(n, c/n)$ a.a.s. has isolated vertices and is
therefore disconnected. Connectivity requires the strictly larger density
$\ln n / n$: writing $p = (\ln n + c)/n$ tames the isolated-vertex mean to the
finite limit $e^{-c}$, the balance point of the connectivity threshold. This
cleanly separates the two thresholds $1/n < \ln n / n$.

### 7.3 Transport to the genuine $G(n,p)$ model

The asymptotic statements above are stated in terms of closed-form expectations.
They transport verbatim to the genuine Erdős–Rényi expectations of Section 4: the
expected triangle count $\mathbb{E}_{c/n}[\#\text{triangles}]$ converges to
$c^3/6$ (Theorem 4.8 + Theorem 7.1), and the expected isolated-vertex count
$\mathbb{E}_{c/n}[\#\text{isolated}]$ diverges to $\infty$ (Theorem 4.7 + Theorem
7.4). Thus the threshold scalings are properties of the model itself, not merely
of abstract sequences.

## 8. Algorithms

The development is constructive: every expectation is a computable finite sum.

**Algorithm 8.1 (exact first moments).** Given $n$ and $p$, the exact expected
edge, triangle, and isolated-vertex counts are
$\binom{n}{2}p$, $\binom{n}{3}p^3$, and $n(1-p)^{n-1}$ respectively — $O(1)$
arithmetic after computing binomial coefficients.

**Algorithm 8.2 (Monte-Carlo estimation of thresholds).** Sample $G(n,p)$ by
flipping $\binom{n}{2}$ independent biased coins; count the target structure;
average over trials. Comparing empirical counts to the exact first moments
validates the formulas and visualizes the transition as $p$ sweeps through the
critical scale.

**Algorithm 8.3 (second moment certificate of appearance).** To certify that a
count $X$ is positive with high probability, compute $\mathbb{E}[X]$ and an upper
bound on $\mathrm{Var}(X)$; if $\mathrm{Var}(X)/(\mathbb{E}[X])^2$ is small,
Theorem 6.4 bounds $\mathbb{P}(X = 0)$ from above.

## 9. Applications

- **Epidemiology.** The giant-component threshold at average degree $1$ mirrors
  the epidemic threshold $R_0 = 1$ separating fizzle from outbreak.
- **Percolation and materials.** Connectivity and giant-component thresholds
  model gelation, conduction, and fluid flow through porous media.
- **Network reliability.** The connectivity threshold $\ln n / n$ quantifies the
  edge density needed for a network to remain globally connected under random
  failures.
- **Probabilistic method.** The first moment method underlies existence proofs
  (e.g. Ramsey lower bounds): if the expected number of "bad" structures is
  below $1$, a configuration avoiding all of them exists.

## 10. Discussion and future work

The finite, measure-free model makes the moment method maximally transparent:
independence is product factorization, linearity is sum interchange, and the
threshold extractions are elementary limits. The framework already delivers the
exact first moments and both moment-method inequalities, the full subgraph
threshold dichotomy at $p = 1/n$, and the strict separation of the connectivity
scale $\ln n / n$ from the giant-component scale $1/n$.

Several deeper results remain natural next targets:

- **Sharp connectivity limit.** Proving $\mathbb{P}(G(n,p)\text{ connected}) \to
  e^{-e^{-c}}$ at $p = (\ln n + c)/n$ requires a Poisson limit theorem for the
  isolated-vertex count, supplied with the second-moment variance bound developed
  here.
- **The giant component.** Establishing the linear-size component above $p = 1/n$
  calls for a branching-process coupling of local neighbourhood exploration.
- **General subgraph thresholds.** Extending the triangle analysis to arbitrary
  balanced $H$ at $p = n^{-1/m(H)}$, with explicit second-moment variance
  computations.
- **Monotone thresholds (Bollobás–Thomason).** Every nontrivial monotone graph
  property has a threshold function; a finitary FKG/coupling argument should
  formalize this.

## 11. Conclusion

From two probabilities — present with probability $p^{|S|}$, absent with
probability $(1-p)^{|S|}$ — and the discipline of linearity of expectation, the
entire first layer of Erdős–Rényi threshold theory follows: exact first moments,
the first and second moment methods, the triangle/giant-component scale $1/n$,
and the connectivity scale $\ln n / n$. The abruptness of these transitions, all
traceable to elementary counting, is a paradigm for the study of phase
transitions in large random systems.
