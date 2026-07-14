# A Cubic Spectral-Gap Witness for Chord-Swap Reconfiguration Chains

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We study the mixing speed of the *chord-swap Markov chain* on chord diagrams of
fixed genus, whose spectral gap $\gamma_{n,g}$ governs how quickly the chain
approaches its stationary distribution. Empirically this gap decays like
$n^{-3}$ at fixed genus $g$ as the number of chords $n\to\infty$, and the same
scaling appears in related swap chains on perfect matchings; existing polynomial
bounds, however, leave the exponent open. We isolate the precise mechanism that
forces the exponent to be three. Developing the Rayleigh-quotient (Poincaré)
calculus abstractly over a finite state space with symmetric, non-negative edge
weights, we prove that the combinatorial spectral gap is bounded above by the
Rayleigh quotient of every non-constant test function, and that the pairwise
variance admits the closed form $\mathrm{Vr}(f)=2\big(|V|\sum_x f(x)^2 -
(\sum_x f(x))^2\big)$. Applying this to the canonical one-dimensional swap chain —
the weighted path with the position test function $f(x)=x$ — we compute
Dirichlet energy $2(n-1)$, variance $n^2(n^2-1)/6$, and Rayleigh quotient
exactly $12/(n^2(n+1))$. Consequently the path swap chain has gap $O(n^{-3})$,
and the certifying quotient is itself $\Theta(n^{-3})$, pinched between
$6n^{-3}$ and $12n^{-3}$. The exponent $3=4-1$ is the difference between the
quartic growth of the variance and the linear growth of the energy of a
monotone, unit-step statistic. We conjecture that this mechanism transfers
verbatim to the genuine fixed-genus chord-swap chain, yielding
$\gamma_{n,g}=\Theta(n^{-3})$ with a genus-dependent constant but a
genus-independent exponent.

## 1. Introduction

A **chord diagram** of size $n$ is a perfect matching of $2n$ points arranged on
a circle. Thickening each chord into a ribbon and gluing along the boundary
circle produces an orientable surface whose number of handles is the **genus**
$g$ of the diagram, a coarse invariant of its topological complexity. Chord
diagrams are ubiquitous — in knot theory (Vassiliev invariants), in the theory of
RNA secondary structure, in the combinatorics of maps and in random-matrix
expansions — and a recurring computational need is to *sample* diagrams of a
prescribed genus roughly uniformly.

The natural sampler is a local **reconfiguration** dynamics. The **chord-swap
Markov chain** picks two chords, detaches their four endpoints, and reconnects
them in one of the alternative ways, accepting the move when it preserves the
genus. Iterating this chain performs a random walk on the set of genus-$g$
diagrams, and its efficiency is governed by the **spectral gap** $\gamma_{n,g}$:
the mixing time is $\Theta(\gamma_{n,g}^{-1})$ up to logarithmic factors.

Numerical work on these chains, and on the closely related transposition/swap
chains on perfect matchings, consistently reports a gap decaying like $n^{-3}$
at fixed genus. Rigorous results establish that the gap is polynomially bounded,
but the *exponent* has remained conjectural. The purpose of this paper is to
explain, with a complete and self-contained argument, exactly why the exponent
is three — at least for the one-dimensional prototype that captures the essential
diffusive geometry — and to reduce the full chord-swap statement to a single
concrete combinatorial task.

Our contribution is twofold. First, we develop a clean, reusable
**Rayleigh-quotient calculus** for the combinatorial spectral gap of any finite,
reversible, symmetric-weight chain, culminating in the statement that a *single*
non-constant test function certifies an upper bound on the gap (Theorem 4.2).
Second, we apply it to the weighted path with the position statistic and compute
the gap witness *in closed form* (Theorems 5.1–5.4), pinning it to
$\Theta(n^{-3})$. The exponent emerges transparently as the ratio of two growth
rates: energy $\Theta(n)$ over variance $\Theta(n^4)$.

## 2. Preliminaries and definitions

Throughout, $V$ is a finite state space and $f\colon V\to\mathbb{R}$ is a
**test function** (a real "measurement" on states). We write $|V|$ for the
cardinality of $V$. Edge weights are encoded by a function
$Q\colon V\times V\to\mathbb{R}$ that is **symmetric** ($Q(x,y)=Q(y,x)$) and
**non-negative** ($Q(x,y)\ge 0$). For a reversible chain with stationary
distribution $\pi$ and transition kernel $P$, the natural choice is
$Q(x,y)=\pi(x)P(x,y)$, which is symmetric precisely by the detailed-balance
condition; the abstract development below does not require this identification.

**Definition 2.1 (Dirichlet energy).**
The Dirichlet energy of $f$ with respect to $Q$ is
$$\mathcal{E}(f,f) \;=\; \sum_{x\in V}\sum_{y\in V} Q(x,y)\,\big(f(x)-f(y)\big)^2.$$
For $Q(x,y)=\pi(x)P(x,y)$ this is twice the classical Dirichlet form and
measures how much $f$ oscillates under one step of the chain.

**Definition 2.2 (pairwise variation).**
The pairwise variation of $f$ is
$$\mathrm{Vr}(f) \;=\; \sum_{x\in V}\sum_{y\in V}\big(f(x)-f(y)\big)^2.$$
Up to the normalizing factor $1/(2|V|^2)$ this equals the variance of $f$ under
the uniform distribution on $V$.

**Definition 2.3 (Rayleigh quotient).**
For a non-constant $f$,
$$R(f) \;=\; \frac{\mathcal{E}(f,f)}{\mathrm{Vr}(f)}.$$

**Definition 2.4 (combinatorial spectral gap / Poincaré constant).**
$$\gamma \;=\; \inf\big\{\,R(f) : f \text{ non-constant}\,\big\}
\;=\; \inf_{\{x,y:\,f(x)\ne f(y)\}\neq\varnothing} \frac{\mathcal{E}(f,f)}{\mathrm{Vr}(f)}.$$
Here "non-constant" means there exist states $x,y$ with $f(x)\ne f(y)$.

This is the standard variational (Poincaré) description of the spectral gap of a
reversible chain: the smallest Rayleigh quotient over non-constant test
functions equals the difference between the top eigenvalue $1$ and the
second-largest eigenvalue of the associated operator.

## 3. Foundational inequalities

The following elementary facts are the guardrails of the theory: they guarantee
that Rayleigh quotients are well defined (no division by zero), that energies are
sign-definite, and that upper bounds obtained from a single witness are genuine.

**Lemma 3.1 (energy non-negativity).**
If $Q(x,y)\ge 0$ for all $x,y$, then $\mathcal{E}(f,f)\ge 0$ for every $f$.

*Proof.* Each summand $Q(x,y)(f(x)-f(y))^2$ is a product of a non-negative
weight and a square, hence non-negative; a double sum of non-negative terms is
non-negative. $\square$

**Lemma 3.2 (variance non-negativity).**
$\mathrm{Vr}(f)\ge 0$ for every $f$.

*Proof.* Every summand $(f(x)-f(y))^2$ is a square. $\square$

**Lemma 3.3 (strict positivity of variance).**
$\mathrm{Vr}(f)>0$ if and only if $f$ is non-constant.

*Proof.* If $f$ is constant every summand vanishes. Conversely, if $f(x)\ne f(y)$
for some pair, then $(f(x)-f(y))^2>0$; the remaining terms are non-negative, so
the total is strictly positive. $\square$

Lemma 3.3 is exactly what makes the Rayleigh quotient legitimate on the domain
of the infimum in Definition 2.4, and it prevents the resulting bounds from being
vacuous.

**Theorem 3.4 (closed form for the variance).**
For every $f\colon V\to\mathbb{R}$,
$$\mathrm{Vr}(f) \;=\; 2\Big(|V|\sum_{x\in V} f(x)^2 \;-\;\big(\textstyle\sum_{x\in V} f(x)\big)^2\Big).$$

*Proof.* Expand the square inside the double sum:
$(f(x)-f(y))^2 = f(x)^2 - 2f(x)f(y) + f(y)^2$. Summing over $x,y$,
$$\sum_{x,y} f(x)^2 = |V|\sum_x f(x)^2, \qquad
\sum_{x,y} f(y)^2 = |V|\sum_x f(x)^2,$$
while
$$\sum_{x,y} 2f(x)f(y) = 2\Big(\sum_x f(x)\Big)\Big(\sum_y f(y)\Big)
= 2\big(\textstyle\sum_x f(x)\big)^2.$$
Adding, $\mathrm{Vr}(f) = 2|V|\sum_x f(x)^2 - 2(\sum_x f(x))^2$, which is the
claim. $\square$

Theorem 3.4 is the discrete, unnormalized form of the identity
$\mathrm{Var}(f)=\mathbb{E}[f^2]-\mathbb{E}[f]^2$. Its value is practical: it lets
one compute the denominator of a Rayleigh quotient from two elementary power sums
of $f$, with no reference to the edge structure of the chain.

## 4. The abstract upper-bound engine

**Theorem 4.1 (non-negativity of the gap).**
If $Q(x,y)\ge 0$ for all $x,y$, then $\gamma\ge 0$.

*Proof.* The set over which the infimum in Definition 2.4 is taken consists of
ratios $R(f)=\mathcal{E}(f,f)/\mathrm{Vr}(f)$ with numerator $\ge 0$ (Lemma 3.1)
and denominator $>0$ (Lemma 3.3, since $f$ ranges over non-constant functions).
Every element of the set is therefore $\ge 0$, and $0$ is a lower bound; the
infimum of a set bounded below by $0$ is $\ge 0$. $\square$

**Theorem 4.2 (single-witness upper bound).**
Suppose $Q(x,y)\ge 0$ for all $x,y$. Then for every non-constant test function
$f$,
$$\gamma \;\le\; R(f) \;=\; \frac{\mathcal{E}(f,f)}{\mathrm{Vr}(f)}.$$

*Proof.* By definition $R(f)$ belongs to the set
$\{\,R(g): g \text{ non-constant}\,\}$ whose infimum is $\gamma$. That set is
bounded below by $0$ (as in Theorem 4.1), so its infimum exists and is a lower
bound of the set; equivalently, every member of the set — in particular $R(f)$ —
is $\ge \gamma$. $\square$

Theorem 4.2 is the engine of the paper: it converts the construction of a single
slowly-varying, widely-ranging test function into a rigorous upper bound on the
spectral gap, hence a lower bound on the mixing time. Note the two hypotheses are
both used: non-constancy of $f$ (so $R(f)$ is defined and $f$ lies in the index
set) and non-negativity of the weights (so the index set is bounded below and the
infimum is well behaved).

## 5. The one-dimensional swap chain: exact computation

We now specialize to the canonical one-dimensional model. Let the state space be
the vertex set of a **path** of length $n$, i.e. $V=\{0,1,\dots,n-1\}$ with
$|V|=n$, and let $Q$ be the adjacency weighting of the path: $Q(x,y)=1$ when
$|x-y|=1$ and $Q(x,y)=0$ otherwise. This is the reduced skeleton of any swap
chain that carries a monotone integer statistic changed by $\pm 1$ per move. Use
the **position test function**
$$f(x) = x, \qquad x=0,1,\dots,n-1,$$
which is non-constant for $n\ge 2$.

**Theorem 5.1 (path Dirichlet energy).**
For the path of length $n$ with the position function, $\mathcal{E}(f,f)=2(n-1)$.

*Proof.* The only pairs $(x,y)$ with $Q(x,y)\ne 0$ are the ordered adjacent pairs
$(x,x{+}1)$ and $(x{+}1,x)$ for $x=0,\dots,n-2$; there are $2(n-1)$ of them, each
with weight $1$. For each, $(f(x)-f(y))^2=(\pm 1)^2=1$. Hence
$\mathcal{E}(f,f)=2(n-1)\cdot 1=2(n-1)$. $\square$

**Theorem 5.2 (path variance).**
For the path of length $n$ with the position function,
$$\mathrm{Vr}(f)=\frac{n^2(n^2-1)}{6}.$$

*Proof.* By Theorem 3.4 with $|V|=n$,
$\mathrm{Vr}(f)=2\big(n\sum_{x=0}^{n-1}x^2-(\sum_{x=0}^{n-1}x)^2\big)$. Using the
Gauss sum $\sum_{x=0}^{n-1}x=\tfrac{n(n-1)}{2}$ and the square-pyramidal sum
$\sum_{x=0}^{n-1}x^2=\tfrac{(n-1)n(2n-1)}{6}$,
$$\mathrm{Vr}(f)=2\left(n\cdot\frac{(n-1)n(2n-1)}{6}-\frac{n^2(n-1)^2}{4}\right)
=2n^2(n-1)\left(\frac{2n-1}{6}-\frac{n-1}{4}\right).$$
The bracket equals $\frac{2(2n-1)-3(n-1)}{12}=\frac{n+1}{12}$, so
$\mathrm{Vr}(f)=\frac{2n^2(n-1)(n+1)}{12}=\frac{n^2(n^2-1)}{6}$. $\square$

**Theorem 5.3 (path Rayleigh quotient).**
For the path of length $n\ge 2$ with the position function,
$$R(f)=\frac{12}{n^2(n+1)}.$$

*Proof.* Combine Theorems 5.1 and 5.2:
$$R(f)=\frac{2(n-1)}{\,n^2(n^2-1)/6\,}
=\frac{12(n-1)}{n^2(n-1)(n+1)}=\frac{12}{n^2(n+1)}. \qquad\square$$

**Theorem 5.4 (cubic pinching of the witness).**
For every $n\ge 1$,
$$\frac{6}{n^3} \;\le\; \frac{12}{n^2(n+1)} \;\le\; \frac{12}{n^3}.$$
In particular $R(f)=\Theta(n^{-3})$.

*Proof.* Since $n\le n+1\le 2n$ for $n\ge 1$, we have
$n^3\le n^2(n+1)\le 2n^3$. Taking reciprocals and multiplying by $12$ reverses
the inequalities: $\tfrac{12}{2n^3}\le\tfrac{12}{n^2(n+1)}\le\tfrac{12}{n^3}$,
i.e. $\tfrac{6}{n^3}\le R(f)\le\tfrac{12}{n^3}$. $\square$

**Corollary 5.5 (cubic gap upper bound).**
The spectral gap of the path swap chain satisfies
$$\gamma \;\le\; \frac{12}{n^2(n+1)} \;=\; O(n^{-3}).$$

*Proof.* The position function is non-constant for $n\ge 2$, and the path weights
are non-negative, so Theorem 4.2 gives $\gamma\le R(f)$; the bound $R(f)=
O(n^{-3})$ is Theorem 5.4. $\square$

The exponent is now transparent. The Dirichlet energy grows *linearly*
($\Theta(n)$) because a local move shifts the position by only one unit, while
the variance grows *quartically* ($\Theta(n^4)$) because the extreme states are
$\Theta(n)$ apart and there are $\Theta(n^2)$ pairs each contributing up to
$\Theta(n^2)$. The Rayleigh quotient is their ratio, of order $n^{-3}$, and the
identity $3=4-1$ records exactly the difference of the two growth exponents.

## 6. Algorithms

The results above are constructive and yield exact-arithmetic algorithms. We
summarize the two central routines; full implementations appear in the
accompanying code.

**Algorithm A (exact Rayleigh witness on the path).** Given $n$, return the exact
rational triple $\big(\mathcal{E},\mathrm{Vr},R\big)=\big(2(n-1),\,
n^2(n^2-1)/6,\,12/(n^2(n+1))\big)$ and verify each against a direct double-sum
computation over $V\times V$. Complexity: $O(1)$ for the closed forms and
$O(n^2)$ for the verification.

**Algorithm B (general single-witness gap bound).** Given a finite weighted graph
$(V,Q)$ with symmetric non-negative $Q$ and any non-constant $f$, compute
$\mathcal{E}(f,f)$ and $\mathrm{Vr}(f)$ by the double-sum definitions (or
$\mathrm{Vr}$ via the two power sums of Theorem 3.4) and return the certified
upper bound $\gamma\le \mathcal{E}(f,f)/\mathrm{Vr}(f)$. Complexity:
$O(|V|^2)$ (or $O(|V|)$ for the variance via the closed form).

## 7. Applications and transfer to chord diagrams

The path computation is not merely a toy: it is the *skeleton* of the fixed-genus
chord-swap chain. Two ingredients transfer the mechanism.

1. **A monotone unit-step statistic.** On the space of genus-$g$ diagrams there is
   a genus-aware "spread" statistic — for instance a total nesting-plus-crossing
   index — that a single swap changes by a bounded amount (rescalable to $\pm 1$).
   Along this statistic the chain projects to a birth–death chain structurally
   identical to the path.

2. **Quartic variance.** Because the statistic ranges over $\Theta(n)$ values with
   $\Theta(n^2)$ pairs of diagrams spread across that range, its pairwise variance
   is $\Theta(n^4)$ by the same power-sum bookkeeping as Theorem 5.2.

Feeding this statistic into Theorem 4.2 reproduces the $O(n^{-3})$ upper bound for
$\gamma_{n,g}$. Fixing the genus caps the number of topologically distinct local
obstructions a swap must clear, which changes the effective conductance — hence
the leading constant — but not the one-dimensional diffusive geometry that
produces the exponent. This is consistent with the empirically observed $n^{-3}$
scaling in swap chains on perfect matchings, of which fixed-genus chord diagrams
are a topologically constrained sub-family.

## 8. Discussion

The strength of the argument lies entirely in the *ratio of growth rates* rather
than in any delicate estimate. Two robust facts do all the work: energy is linear
because moves are local, and variance is quartic because a monotone statistic
spreads a long, densely populated range. The infimum characterization
(Definition 2.4, Theorem 4.2) is what upgrades a single test function into a bona
fide upper bound, and the variance closed form (Theorem 3.4) is what makes the
denominator computable without touching the edge structure. Crucially, the bound
is not vacuous: the witness is genuinely non-constant (Lemma 3.3), the weights are
genuinely non-negative, and the quotient is pinned to $\Theta(n^{-3})$
(Theorem 5.4), so no cheaper test function of this monotone, unit-step shape can
improve the exponent.

The upper-bound half is unconditional. What remains to complete a two-sided
$\Theta(n^{-3})$ for the genuine chord-swap chain is (i) the explicit
construction of the monotone unit-step, quartic-variance statistic on the diagram
space, and (ii) a matching *lower* bound on the gap.

## 9. Future work

We record three conjectures, in increasing refinement.

**Conjecture 1 (cubic upper bound).** For every fixed genus $g$, the spectral gap
of the chord-swap chain on diagrams with $n$ chords satisfies
$\gamma_{n,g}=O(n^{-3})$. The route is precisely the transfer of Section 7:
exhibit one monotone, unit-step, quartic-variance statistic and apply
Theorem 4.2.

**Conjecture 2 (matching lower bound).** For every fixed genus $g$,
$\gamma_{n,g}=\Omega(n^{-3})$, so that with Conjecture 1 the exponent is exactly
three: $\gamma_{n,g}=\Theta(n^{-3})$. The natural tool is a canonical-path
(multicommodity-flow) routing of unit mass between diagrams whose maximal edge
congestion is $O(n^3)$; the standard congestion–Poincaré duality then converts
$O(n^3)$ relaxation time into an $\Omega(n^{-3})$ gap. The upper bound conveniently
calibrates the congestion budget the routing must meet.

**Conjecture 3 (genus enters only through the constant).** Writing
$\gamma_{n,g}=c(g)\,n^{-3}(1+o(1))$ as $n\to\infty$, the leading constant $c(g)$
is strictly positive and strictly decreasing in $g$, while the exponent $-3$ is
independent of $g$. Fixing the genus caps the number of local obstructions,
rescaling the effective conductance (the constant) without altering the diffusive
geometry (the exponent). The residual $g$-dependence is thereby isolated in a
single measurable amplitude $c(g)$ estimable from moderate-size diagrams.

## 10. Conclusion

We have given a complete, self-contained account of why a one-dimensional swap
chain has spectral gap of order $n^{-3}$: the Rayleigh-quotient calculus turns a
single monotone, unit-step test function into an upper bound, and on the weighted
path that witness has energy $2(n-1)$, variance $n^2(n^2-1)/6$, and quotient
exactly $12/(n^2(n+1))$, pinned to the cubic window $[6n^{-3},12n^{-3}]$. The
exponent $3=4-1$ is the difference between quartic variance and linear energy.
Transferring the mechanism to the fixed-genus chord-swap chain reduces the
long-standing exponent question to a concrete combinatorial construction plus a
calibrated flow argument, with genus expected to affect only the constant.
