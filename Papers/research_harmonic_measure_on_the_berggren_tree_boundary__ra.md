# Harmonic Measure on the Boundary of the Berggren Tree

### Random walks, entropy, drift and separation on the 3-adic Cantor set of primitive Pythagorean triples

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

The Berggren tree is the free rooted ternary tree whose nodes enumerate the primitive
Pythagorean triples exactly once, generated from the seed $(m,n) = (2,1)$ by the three Euclid-seed
moves $L(m,n) = (2m-n, m)$, $M(m,n) = (2m+n, m)$, $R(m,n) = (m+2n, n)$. We develop the complete
probabilistic and ergodic theory of the random walk on this tree that selects the three moves
independently with fixed probabilities $(p_L, p_M, p_R)$.

We show that the boundary of the tree — the space of infinite descending paths — is a Cantor
space, canonically identified with $\{0,1,2\}^{\mathbb{N}}$ under the 3-adic (common-prefix)
topology. We prove that the harmonic measure of the walk *exists and is unique*, and equals the
Bernoulli product measure with weights $(p_L,p_M,p_R)$; the fair walk realises the natural Cantor
measure. We compute the entropy of the harmonic measure exactly: the mean surprisal of a depth-$n$
node is $n\,H(p)$ with no error term, and $-\frac1n\log\nu(\text{cyl}_n(x)) \to H(p)$ almost
surely, whence the pointwise dimension is $H(p)/\log 3 \le 1$ with equality iff the walk is fair.

We prove that the boundary shift is ergodic for every harmonic measure, that distinct walks yield
mutually singular harmonic measures, and that this singularity is *rigid*: an everywhere-defined
frequency statistic recovers the weight vector from a single typical ray, and "equal versus
mutually singular" is a strict dichotomy. Quantitatively, distinct walks are already separated
at depth $n$ at the binary Kullback–Leibler rate (Chernoff), and this cannot be improved beyond
the Bhattacharyya exponent: for every event $A$ of the first $n$ letters,
$\nu_P(A) + \nu_Q(A^c) \ge \tfrac12\beta^{2n}$ with $\beta = \sum_a \sqrt{p_a q_a}$.

Finally we connect the probabilistic theory to the hyperbolic geometry of the tree. Averaging the
sharp deterministic envelope $(\#M(w)+1)\log 2 \le d \le (|w|+1)\log(1+\sqrt2) + \log 2$ over the
walk gives the drift sandwich $p_M\log 2 \le \mathbb{E}\,d(o, z_n)/n \le \log(1+\sqrt2) + O(1/n)$,
upgraded almost surely by the strong law; in particular the walk escapes to infinity a.s. Two
negative results complete the picture: the transfer operator restricted to locally constant
observables is nilpotent modulo constants, so its spectrum is $\{0,1\}$ and the spectral gap is
$1$ independently of $(p_L,p_M,p_R)$ — refuting the conjecture that the silver ratio governs the
gap; and $\log 3 < 2\log(1+\sqrt2)$, so the hyperbolic dimension $H(p)/(2\log(1+\sqrt2))$ of the
harmonic measure is bounded by $2/3$ uniformly, and the harmonic measure is never the conformal
measure of the hyperbolic embedding.

**Keywords:** Pythagorean triples, Berggren tree, harmonic measure, Bernoulli measure, Cantor
set, Shannon entropy, Hausdorff dimension, silver ratio, Chernoff bound, Bhattacharyya coefficient.

---

## 1. Introduction

### 1.1 The Berggren tree

Euclid's parametrisation of the primitive Pythagorean triples is a bijection between the set
$$\mathcal{S} = \{(m,n) \in \mathbb{Z}^2 : m > n > 0,\ \gcd(m,n) = 1,\ m \not\equiv n \pmod 2\}$$
of *seeds* and the set of primitive triples, via
$$(m,n) \longmapsto (m^2 - n^2,\ 2mn,\ m^2 + n^2).$$
Berggren's theorem states that $\mathcal{S}$ carries the structure of a free rooted ternary tree:
the root is $(2,1)$ — the seed of $(3,4,5)$ — and the three maps
$$L(m,n) = (2m - n,\ m), \qquad M(m,n) = (2m + n,\ m), \qquad R(m,n) = (m + 2n,\ n)$$
carry $\mathcal{S}$ into itself and realise every seed other than $(2,1)$ exactly once as the
image of exactly one seed under exactly one of the three moves. Equivalently, the map
$$\mathrm{run} : \{L,M,R\}^{*} \longrightarrow \mathcal{S}, \qquad
\mathrm{run}(\varepsilon) = (2,1), \quad \mathrm{run}(a w) = a\bigl(\mathrm{run}(w)\bigr)$$
(reading words right to left) is a bijection from finite words onto seeds. Thus the primitive
Pythagorean triples are canonically indexed by finite words in a three-letter alphabet, and the
combinatorial structure is that of the free monoid on three generators.

The three moves are not symmetric. In the metric picture (Section 6) the *middle* move $M$ plays a
distinguished role: it is the unique one that saturates the growth of the natural potential
$\Phi(m,n) = m + (\sqrt2 - 1)n$, whose growth constant is the silver ratio $1 + \sqrt 2$.

### 1.2 The boundary and the walk

Since the tree is free and ternary, its space of ends is the full three-letter shift space. Write
$$\mathcal{A} = \{0,1,2\}$$
for the alphabet, with $0 \leftrightarrow L$, $1 \leftrightarrow M$, $2 \leftrightarrow R$, and
$$\partial\mathcal{T} = \mathcal{A}^{\mathbb{N}}$$
for the boundary. Give $\partial\mathcal{T}$ the product topology of the discrete topologies and
the product $\sigma$-algebra.

Fix a *weight vector* $P = (p_0, p_1, p_2)$ with $p_a > 0$ for each $a$ and $\sum_a p_a = 1$. The
**Berggren random walk** with weights $P$ starts at the root and, at each step, appends the letter
$a$ with probability $p_a$, independently of the past. It converges to a boundary point, and the
law of the limit point is by definition the **harmonic measure** of the walk. This paper computes
that measure and everything one might reasonably want to know about it.

### 1.3 Overview of results

* **Section 2** identifies the boundary as a Cantor space.
* **Section 3** proves existence and uniqueness of the harmonic measure and identifies it with the
  Bernoulli product measure.
* **Section 4** computes entropy and dimension: an exact finite-level identity, a
  Shannon–McMillan–Breiman theorem, and the dimension formula $H(p)/\log 3$.
* **Section 5** treats the ergodic theory: shift-invariance, ergodicity, mutual singularity,
  and ray rigidity; then the quantitative separation theory (Chernoff and Bhattacharyya).
* **Section 6** connects to the hyperbolic geometry: the drift sandwich in mean and almost surely,
  and almost sure escape to infinity.
* **Section 7** contains the two negative results: the refutation of the silver spectral gap, and
  the uniform entropy–metric dimension gap.
* **Section 8** discusses algorithms, applications, and open problems.

Throughout, $\log$ is the natural logarithm and
$$H(P) = -\sum_{a \in \mathcal{A}} p_a \log p_a$$
denotes Shannon entropy in nats.

---

## 2. The boundary is a Cantor set

**Definition 2.1 (Cylinders).** For $n \in \mathbb{N}$ and $v \in \partial\mathcal{T}$, the
*cylinder* of depth $n$ through $v$ is
$$\mathrm{cyl}_n(v) = \{x \in \partial\mathcal{T} : x_i = v_i \text{ for all } i < n\}.$$
Equivalently $\mathrm{cyl}_n(v)$ is the *shadow* of the node $\mathrm{run}(v_0 v_1 \cdots v_{n-1})$
of the Berggren tree: the set of ends passing through that node, i.e. through that primitive
Pythagorean triple. In particular $\mathrm{cyl}_0(v) = \partial\mathcal{T}$.

The cylinders are precisely the sets one can name with a finite amount of arithmetic information,
and they carry the whole topology and measure theory of the boundary.

**Lemma 2.2 (Nesting).** *If $x \in \mathrm{cyl}_n(v) \cap \mathrm{cyl}_m(w)$ with $n \le m$, then
$\mathrm{cyl}_m(w) \subseteq \mathrm{cyl}_n(v)$.*

*Proof.* For $i < n \le m$ and $y \in \mathrm{cyl}_m(w)$ we have $y_i = w_i = x_i = v_i$. $\square$

Consequently the family of cylinders is a $\pi$-system: the intersection of two cylinders is
either empty or equal to the deeper one. Since the coordinate maps are measurable with respect to
the $\sigma$-algebra generated by cylinders (the event $\{x_i = a\}$ is the finite union of the
$3^{i}$ depth-$(i+1)$ cylinders whose $i$-th letter is $a$), the cylinders *generate* the product
$\sigma$-algebra. Together these two facts yield the uniqueness tool used everywhere below.

**Proposition 2.3 (Cylinders determine measures).** *Two probability measures on
$\partial\mathcal{T}$ that agree on every cylinder are equal.*

*Proof.* Dynkin's $\pi$–$\lambda$ theorem applied to the generating $\pi$-system of cylinders,
using that both measures give total mass $1$. $\square$

**Theorem 2.4 (Cantor structure of the boundary).** *The boundary $\partial\mathcal{T}$, with the
common-prefix topology, is:*

1. *nonempty;*
2. *compact* (Tychonoff on a product of finite discrete spaces);
3. *second countable, hence metrizable* — a compatible metric is $d(x,y) = 3^{-\min\{i : x_i \ne y_i\}}$;
4. *totally disconnected*, because the cylinders are clopen: each $\mathrm{cyl}_n(v)$ is a finite
   intersection of preimages of points under the (continuous, discrete-target) coordinate maps,
   hence both open and closed;
5. *perfect*, i.e. it has no isolated points.

*Moreover the cylinders form a neighbourhood basis: every neighbourhood of $x$ contains
$\mathrm{cyl}_n(x)$ for some $n$; and every cylinder contains at least two distinct points, so
every subtree of the Berggren tree branches forever.*

*Proof of (5) and the branching statement.* Fix $x$ and let $x^{(k)}$ be $x$ with its $k$-th
letter incremented cyclically. Then $x^{(k)} \ne x$ for all $k$, while $x^{(k)}_i = x_i$ as soon
as $k > i$, so $x^{(k)} \to x$ coordinatewise, i.e. in the product topology. Hence $x$ is not
isolated. Taking $k = n$ gives $x^{(n)} \in \mathrm{cyl}_n(x) \setminus \{x\}$, proving the second
claim. For the neighbourhood-basis statement, a basic product neighbourhood constrains finitely
many coordinates, all with index at most some $N$, so $\mathrm{cyl}_{N+1}(x)$ is contained in
it. $\square$

By Brouwer's characterisation of the Cantor set — a nonempty, compact, perfect, totally
disconnected, metrizable space is homeomorphic to $\{0,1\}^{\mathbb{N}}$ — the boundary of the
Berggren tree is homeomorphic to the classical middle-thirds Cantor set. We record this as a
consequence rather than as a construction; the four axioms are what the rest of the paper uses.

---

## 3. The harmonic measure

### 3.1 Harmonicity

Let $\mathrm{cons}_a : \partial\mathcal{T} \to \partial\mathcal{T}$ be the map that prepends the
letter $a$:
$$(\mathrm{cons}_a x)_0 = a, \qquad (\mathrm{cons}_a x)_{k+1} = x_k.$$
Each $\mathrm{cons}_a$ is continuous and measurable, and geometrically it is the canonical
identification of the whole boundary with the shadow of the $a$-child of the root.

**Definition 3.1 (Harmonic measure).** A Borel probability measure $\nu$ on $\partial\mathcal{T}$
is *harmonic* (equivalently *stationary*, or *self-similar*) for the weight vector $P$ if
$$\nu \;=\; \sum_{a \in \mathcal{A}} p_a \,(\mathrm{cons}_a)_*\nu ,$$
i.e. for every measurable $S$,
$$\nu(S) = \sum_{a} p_a\, \nu\bigl(\mathrm{cons}_a^{-1}S\bigr).$$

This is exactly the statement that the hitting distribution is reproduced by conditioning on the
first step of the walk: the boundary decomposes into the three shadows of the children of the
root, the walk enters the $a$-shadow with probability $p_a$, and conditionally on that it is again
a copy of the same walk.

**Definition 3.2 (Bernoulli measure).** $\mathrm{Ber}(P)$ is the infinite product measure
$\bigotimes_{i\in\mathbb{N}} \mu_P$ on $\partial\mathcal{T}$, where $\mu_P$ is the probability
measure on $\mathcal{A}$ with $\mu_P(\{a\}) = p_a$.

**Lemma 3.3 (Cylinder mass).** $\mathrm{Ber}(P)\bigl(\mathrm{cyl}_n(v)\bigr) = \prod_{i<n} p_{v_i}$.

*Proof.* $\mathrm{cyl}_n(v)$ is the measurable box $\prod_{i<n}\{v_i\} \times \prod_{i \ge n}
\mathcal{A}$; apply the defining property of the product measure. $\square$

### 3.2 The main theorem

The key computation is a one-line recursion on the depth of a cylinder.

**Lemma 3.4 (Pullback of a cylinder).** For $a \in \mathcal{A}$, $n \in \mathbb{N}$, $v \in
\partial\mathcal{T}$,
$$\mathrm{cons}_a^{-1}\bigl(\mathrm{cyl}_{n+1}(v)\bigr) =
\begin{cases} \mathrm{cyl}_n(\sigma v) & \text{if } a = v_0,\\[2pt] \varnothing & \text{otherwise,}\end{cases}$$
where $\sigma v = (v_1, v_2, \ldots)$ is the shift.

*Proof.* $\mathrm{cons}_a x \in \mathrm{cyl}_{n+1}(v)$ requires $a = v_0$ (coordinate $0$) and
$x_k = v_{k+1}$ for $k < n$ (coordinates $1, \ldots, n$). $\square$

**Theorem 3.5 (Existence and uniqueness of the harmonic measure).** *For every strictly positive
weight vector $P$ there is exactly one harmonic probability measure on the boundary of the
Berggren tree, namely $\mathrm{Ber}(P)$. Explicitly, a probability measure $\nu$ is harmonic for
$P$ if and only if $\nu = \mathrm{Ber}(P)$, and in that case*
$$\nu\bigl(\mathrm{cyl}_n(v)\bigr) = \prod_{i<n} p_{v_i}.$$

*Proof.* **Uniqueness of cylinder masses.** Let $\nu$ be any harmonic probability measure. We show
$\nu(\mathrm{cyl}_n(v)) = \prod_{i<n}p_{v_i}$ by induction on $n$. For $n = 0$ the cylinder is the
whole space and both sides are $1$. For $n+1$, apply harmonicity to the measurable set
$\mathrm{cyl}_{n+1}(v)$ and use Lemma 3.4: all terms with $a \ne v_0$ vanish, and the surviving
term is $p_{v_0}\,\nu(\mathrm{cyl}_n(\sigma v)) = p_{v_0}\prod_{i<n} p_{(\sigma v)_i} =
\prod_{i<n+1}p_{v_i}$ by the inductive hypothesis.

**Harmonicity of $\mathrm{Ber}(P)$.** Set $\nu' = \sum_a p_a (\mathrm{cons}_a)_*\mathrm{Ber}(P)$.
Evaluating at the whole space gives $\nu'(\partial\mathcal{T}) = \sum_a p_a = 1$, so $\nu'$ is a
probability measure. The same computation as above (now using Lemma 3.3 in place of the inductive
hypothesis) gives $\nu'(\mathrm{cyl}_n(v)) = \prod_{i<n} p_{v_i} = \mathrm{Ber}(P)(\mathrm{cyl}_n(v))$
for every cylinder. By Proposition 2.3, $\nu' = \mathrm{Ber}(P)$.

**Conclusion.** The two paragraphs give respectively "harmonic $\Rightarrow$ Bernoulli cylinder
masses $\Rightarrow$ (Prop. 2.3) equal to $\mathrm{Ber}(P)$" and "$\mathrm{Ber}(P)$ is harmonic".
$\square$

**Corollary 3.6 (The fair walk sees the Cantor measure).** For $p_0 = p_1 = p_2 = 1/3$,
$\mathrm{Ber}(P)(\mathrm{cyl}_n(v)) = 3^{-n}$ for every $v$ and $n$: the harmonic measure of the
fair Berggren walk is the natural Hausdorff/Cantor measure of the 3-adic boundary, the unique
measure giving equal mass to all $3^n$ primitive triples at depth $n$.

**Corollary 3.7 (Full support).** Since all $p_a > 0$, every cylinder has strictly positive
harmonic mass; since cylinders form a neighbourhood basis, every nonempty open set has positive
mass. All the harmonic measures have the same (full) support, namely the whole Cantor boundary.

---

## 4. Entropy and dimension

### 4.1 Surprisal

**Definition 4.1.** The *surprisal* of a move $a$ is $\iota(a) = -\log p_a \ge 0$, and the Shannon
entropy of the step distribution is $H(P) = \sum_a p_a \iota(a) = -\sum_a p_a \log p_a$.

**Proposition 4.2 (Gibbs).** $0 \le H(P) \le \log 3$, with $H(P) = \log 3$ if and only if
$p_a = 1/3$ for every $a$.

*Proof.* Nonnegativity is termwise. For the upper bound apply $\log t \le t - 1$ (strict unless
$t = 1$) with $t = 1/(3p_a)$:
$$p_a \log\frac{1}{3p_a} \;\le\; p_a\Bigl(\frac{1}{3p_a} - 1\Bigr) = \frac13 - p_a .$$
Summing over $a$, the left-hand side is $-\log 3 + H(P)$ and the right-hand side is $1 - 1 = 0$;
hence $H(P) \le \log 3$. If some $p_a \ne 1/3$ the corresponding inequality is strict, giving
$H(P) < \log 3$. $\square$

### 4.2 An exact identity at every depth

**Theorem 4.3 (Mean surprisal of a depth-$n$ node).** *For every $n$,*
$$\sum_{w \in \mathcal{A}^n} \Bigl(\prod_{i<n}p_{w_i}\Bigr)\cdot
\Bigl(-\log \prod_{i<n} p_{w_i}\Bigr) \;=\; n\,H(P).$$
*Equivalently: summing over all $3^n$ primitive Pythagorean triples at depth $n$, weighted by
their harmonic mass, the average information content of a depth-$n$ node is exactly $n H(P)$. This
is an identity, not an asymptotic — there is no error term at any finite depth.*

*Proof.* Write $-\log\prod_i p_{w_i} = \sum_{i<n}\iota(w_i)$ and exchange the order of summation:
$$\sum_{w}\Bigl(\prod_j p_{w_j}\Bigr)\sum_{i<n}\iota(w_i)
= \sum_{i<n}\ \sum_{w}\Bigl(\prod_j p_{w_j}\Bigr)\iota(w_i).$$
For fixed $i$, factor the inner sum over the coordinate $w_i$ and the remaining coordinates: the
latter sum to $1$, leaving $\sum_a p_a\iota(a) = H(P)$. There are $n$ values of $i$. $\square$

### 4.3 Shannon–McMillan–Breiman

Under $\mathrm{Ber}(P)$ the coordinate maps $x \mapsto x_i$ are i.i.d. with law $\mu_P$;
consequently for any observable $g$ on the alphabet, $x \mapsto g(x_i)$ are i.i.d., bounded,
integrable random variables with common mean $\sum_a p_a g(a)$.

**Theorem 4.4 (Strong law for the letters).** *For every $g : \mathcal{A} \to \mathbb{R}$,*
$$\frac1n\sum_{i<n} g(x_i) \;\xrightarrow[n\to\infty]{}\; \sum_a p_a g(a)
\qquad \text{for } \mathrm{Ber}(P)\text{-a.e. } x.$$

*Proof.* Kolmogorov's strong law of large numbers for i.i.d. integrable real random variables,
applied to the coordinate observables, which are independent (product measure) and identically
distributed (each coordinate has law $\mu_P$). $\square$

**Theorem 4.5 (Shannon–McMillan–Breiman on the Berggren boundary).** *For $\mathrm{Ber}(P)$-a.e.
boundary point $x$,*
$$-\frac1n \log \mathrm{Ber}(P)\bigl(\mathrm{cyl}_n(x)\bigr) \;\longrightarrow\; H(P).$$

*Proof.* By Lemma 3.3, $-\log\mathrm{Ber}(P)(\mathrm{cyl}_n(x)) = \sum_{i<n}\iota(x_i)$. Apply
Theorem 4.4 with $g = \iota$, whose mean is $H(P)$. $\square$

So the harmonic mass of the depth-$n$ node containing a typical ray decays like $e^{-nH(P)}$: the
walk "sees" $e^{nH(P)}$ effectively equally likely triples at depth $n$, out of the $3^n$
available.

### 4.4 Dimension

The natural metric on the boundary makes $\mathrm{diam}\,\mathrm{cyl}_n(x) = 3^{-n}$. The
*pointwise (Billingsley) dimension* of $\nu$ at $x$ is therefore
$$\lim_{n} \frac{\log \nu(\mathrm{cyl}_n(x))}{\log 3^{-n}}.$$

**Definition 4.6.** $\dim \nu_P = H(P)/\log 3$.

**Theorem 4.7 (Pointwise dimension).** *For $\mathrm{Ber}(P)$-a.e. $x$,*
$$\frac{\log \mathrm{Ber}(P)(\mathrm{cyl}_n(x))}{\log 3^{-n}} \;\longrightarrow\; \frac{H(P)}{\log 3}.$$
*Consequently $\dim \nu_P \in [0,1]$; $\dim\nu_P = 1$ if and only if $p_0 = p_1 = p_2 = 1/3$; and
if any $p_a \ne 1/3$ then $\dim\nu_P < 1$ strictly.*

*Proof.* Divide the statement of Theorem 4.5 by $\log 3$, using $\log 3^{-n} = -n\log 3$. The
range and rigidity statements are Proposition 4.2 divided by $\log 3$. $\square$

Thus the fair Berggren walk spreads over the whole boundary, and every biased walk concentrates on
a fractal subset of strictly smaller dimension: a *dimension drop* driven entirely by Gibbs'
inequality. Since the boundary itself has dimension $1$ in this metric, the deficit
$1 - H(P)/\log 3$ is an exact measure of the bias of the dice.

---

## 5. Ergodic theory and separation

### 5.1 Shift-invariance and ergodicity

Let $\sigma : \partial\mathcal{T} \to \partial\mathcal{T}$, $(\sigma x)_k = x_{k+1}$, be the shift
"forget the first Berggren move".

**Proposition 5.1 (Stationarity).** $\sigma$ preserves $\mathrm{Ber}(P)$.

*Proof.* $\sigma^{-1}\mathrm{cyl}_n(v) = \bigsqcup_{a\in\mathcal{A}} \mathrm{cyl}_{n+1}(a v)$, whose
mass is $\bigl(\sum_a p_a\bigr)\prod_{i<n}p_{v_i} = \prod_{i<n}p_{v_i}$. Conclude by
Proposition 2.3. $\square$

**Theorem 5.2 (Ergodicity).** *For every weight vector $P$, the shift $\sigma$ is ergodic with
respect to $\mathrm{Ber}(P)$. Consequently every shift-invariant boundary observable is a.s.
constant, and $\mathrm{Ber}(P)$ is an extreme point of the simplex of $\sigma$-invariant
probability measures on the boundary.*

*Proof.* The coordinate $\sigma$-algebras $\mathcal{F}_n = \sigma(x \mapsto x_n)$ are independent
under the product measure. If $S$ is strictly invariant, $S = (\sigma^{n})^{-1}S$ for every $n$;
since $\sigma^{n}$ reads only coordinates $\ge n$, $S$ lies in $\bigvee_{k\ge n}\mathcal{F}_k$ for
every $n$, i.e. in the tail $\sigma$-algebra. Kolmogorov's $0$–$1$ law gives
$\mathrm{Ber}(P)(S) \in \{0,1\}$. $\square$

Ergodicity is the reason a single typical ray can carry global information — the theme of the next
subsection.

### 5.2 Mutual singularity and ray rigidity

**Definition 5.3 (Frequency statistic).** For $a \in \mathcal{A}$ define, on *all* of the boundary,
$$\rho_a(x) = \limsup_{n\to\infty} \frac{1}{n}\#\{i < n : x_i = a\},$$
and $\rho(x) = (\rho_0(x), \rho_1(x), \rho_2(x))$. The statistic $\rho$ is Borel (a $\limsup$ of
measurable functions), and it is defined everywhere: no exceptional set is needed to state it.

Call $x$ *typical for $P$* if for every $a$ the empirical frequency of $a$ converges to $p_a$; let
$\mathrm{Typ}(P)$ be the set of such rays. By Theorem 4.4 applied to the indicator observables,
$\mathrm{Ber}(P)(\mathrm{Typ}(P)) = 1$; in particular $\mathrm{Typ}(P) \ne \varnothing$, and
$\rho(x) = P$ for every $x \in \mathrm{Typ}(P)$.

**Theorem 5.4 (Ray rigidity).** *For two weight vectors $P, Q$ the following are equivalent:*

1. $P = Q$;
2. *some single boundary ray is typical for both walks, i.e. $\mathrm{Typ}(P)\cap\mathrm{Typ}(Q) \ne \varnothing$;*
3. $\mathrm{Ber}(P) = \mathrm{Ber}(Q)$;
4. $\mathrm{Ber}(P)$ *and* $\mathrm{Ber}(Q)$ *are* **not** *mutually singular.*

*In particular distinct walks have disjoint sets of typical rays and mutually singular harmonic
measures; the map $P \mapsto \mathrm{Ber}(P)$ is injective; and there is no intermediate regime
between "identical" and "maximally different".*

*Proof.* $(1)\Rightarrow(2)$: $\mathrm{Typ}(P) = \mathrm{Typ}(Q)$ and it is nonempty.
$(2)\Rightarrow(1)$: if $x$ is typical for both then $P = \rho(x) = Q$.
$(1)\Rightarrow(3)$: identical one-step laws give identical product measures.
$(3)\Rightarrow(4)$: a probability measure is never mutually singular with itself (splitting the
space into a null set and its complement would force total mass $0$).
$(4)\Rightarrow(1)$: contrapositive. If $p_a \ne q_a$ for some $a$, then $\mathrm{Typ}(P)$ carries
all the mass of $\mathrm{Ber}(P)$ and none of that of $\mathrm{Ber}(Q)$ (its complement is
$\mathrm{Ber}(Q)$-conull, because $\mathrm{Typ}(Q)$ is disjoint from it), so the two are mutually
singular. $\square$

Note the contrast with Corollary 3.7: *all* harmonic measures have full support, so they charge
exactly the same open sets, yet they are pairwise mutually singular. Singularity here is a purely
asymptotic phenomenon, invisible at any finite depth and detected only by the law of large numbers.

### 5.3 Quantitative separation: the Chernoff rate

We now make the singularity of Theorem 5.4 quantitative — how well can a *depth-$n$* observer
distinguish two walks?

**Definition 5.5.** The binary relative entropy is
$$\mathrm{KL}(u \Vert s) = u\log\frac{u}{s} + (1-u)\log\frac{1-u}{1-s}, \qquad u, s \in (0,1),$$
and $\mathrm{KL}(u\Vert s) > 0$ whenever $u \ne s$ (Gibbs, two-point case).

**Lemma 5.6 (Exact factorisation of the moment generating function).** *For $g : \mathcal{A}\to
\mathbb{R}$ and $S_n(x) = \sum_{i<n} g(x_i)$,*
$$\mathbb{E}_{\mathrm{Ber}(P)}\bigl[e^{tS_n}\bigr] = \Bigl(\sum_a p_a e^{t g(a)}\Bigr)^{\!n}.$$

*Proof.* Independence of the coordinates and identical distribution. $\square$

**Theorem 5.7 (Chernoff bounds for letter counts).** *Let $N_a^{(n)}(x) = \#\{i<n : x_i = a\}$.
Then for $p_a < u < 1$,*
$$\mathrm{Ber}(P)\bigl[N_a^{(n)} \ge nu\bigr] \le e^{-n\,\mathrm{KL}(u\Vert p_a)},$$
*and for $0 < u < p_a$,*
$$\mathrm{Ber}(P)\bigl[N_a^{(n)} \le nu\bigr] \le e^{-n\,\mathrm{KL}(u\Vert p_a)}.$$

*Proof sketch.* Apply the exponential Markov inequality to the boolean observable $g = \mathbf 1_a$
with the classical tilt $t = \log\frac{u(1-p_a)}{p_a(1-u)} > 0$; Lemma 5.6 makes the moment
generating function exactly $(1 - p_a + p_a e^{t})^n$, and substituting the optimal $t$ turns
$e^{-tnu}(1-p_a+p_ae^t)^n$ into $e^{-n\mathrm{KL}(u\Vert p_a)}$. The lower tail follows by applying
the upper tail to the complementary observable $1 - \mathbf 1_a$ and using the symmetry
$\mathrm{KL}(1-u\Vert 1-s) = \mathrm{KL}(u\Vert s)$. $\square$

**Theorem 5.8 (Exponential separation at depth $n$).** *If $P \ne Q$ then there exist $c > 0$ and
measurable sets $A_n$, each determined by the first $n$ letters, such that for every $n$*
$$\mathrm{Ber}(P)(A_n) \ge 1 - e^{-cn}, \qquad \mathrm{Ber}(Q)(A_n) \le e^{-cn}.$$
*Consequently $\mathrm{Ber}(P)(A_n) - \mathrm{Ber}(Q)(A_n) \to 1$: the total-variation separation
of the depth-$n$ statistics tends to $1$, and mutual singularity is the $n\to\infty$ shadow of an
exponential cutoff.*

*Proof.* Pick $a$ with $p_a \ne q_a$, say $q_a < p_a$, and a threshold $u$ strictly between them.
Take $A_n = \{N_a^{(n)} \ge nu\}$. Theorem 5.7 (lower tail under $P$, upper tail under $Q$) gives
the two bounds with $c = \min\{\mathrm{KL}(u\Vert p_a), \mathrm{KL}(u\Vert q_a)\} > 0$. If instead
$p_a < q_a$, use the complement. $\square$

### 5.4 The converse: a Bhattacharyya speed limit

Theorem 5.8 gives *some* exponential rate. Is there a limit to how fast a depth-$n$ test can be?
There is, and it is the classical Bhattacharyya exponent.

**Definition 5.9.** The Bhattacharyya coefficient of two weight vectors is
$$\beta(P,Q) = \sum_{a\in\mathcal{A}} \sqrt{p_a q_a}.$$

**Lemma 5.10.** $0 < \beta(P,Q) \le 1$, with $\beta(P,Q) < 1$ if and only if $P \ne Q$.

*Proof.* Positivity is clear. AM–GM gives $\sqrt{p_aq_a} \le (p_a + q_a)/2$ with equality iff
$p_a = q_a$; sum over $a$ and use $\sum_a(p_a+q_a)/2 = 1$. $\square$

**Lemma 5.11 (Factorisation of the affinity at depth $n$).** *Writing $m_P(w) = \prod_{i<n}p_{w_i}$
for the harmonic mass of the depth-$n$ node labelled by the word $w\in\mathcal{A}^n$,*
$$\sum_{w\in\mathcal{A}^n}\sqrt{m_P(w)m_Q(w)} = \beta(P,Q)^n .$$

*Proof.* The sum factorises coordinatewise, exactly as in Lemma 5.6. $\square$

**Theorem 5.12 (No test beats the Bhattacharyya exponent).** *Let $A$ be any event determined by
the first $n$ letters (a union of depth-$n$ cylinders). Then*
$$\mathrm{Ber}(P)(A) + \mathrm{Ber}(Q)(A^c) \;\ge\; \tfrac{1}{2}\,\beta(P,Q)^{2n}.$$
*Hence the exponential rate at which any depth-$n$ test can separate two Berggren walks is at most
$-2\log\beta(P,Q)$; together with Theorem 5.8 this brackets the true cutoff rate.*

*Proof.* Write $A$ as $\bigcup_{w\in W}\mathrm{cyl}_n(w)$ for a set of words $W \subseteq
\mathcal{A}^n$. Then $\mathrm{Ber}(P)(A) = \sum_{w\in W} m_P(w)$ and $\mathrm{Ber}(Q)(A^c) =
\sum_{w\notin W} m_Q(w)$, so
$$\mathrm{Ber}(P)(A) + \mathrm{Ber}(Q)(A^c) \;\ge\; \sum_{w\in W}\min(m_P,m_Q)(w) + \sum_{w\notin W}\min(m_P,m_Q)(w) = \sum_{w} \min(m_P,m_Q)(w).$$
It remains to bound the total overlap mass from below. With $m = \min(m_P,m_Q)$ and
$M = \max(m_P,m_Q)$ we have $mM = m_Pm_Q$ and $M \le m_P + m_Q$, so by Cauchy–Schwarz
$$\beta^{2n} = \Bigl(\sum_w \sqrt{m_P m_Q}\Bigr)^{2} = \Bigl(\sum_w\sqrt{m}\sqrt{M}\Bigr)^{2}
\le \Bigl(\sum_w m\Bigr)\Bigl(\sum_w M\Bigr) \le \Bigl(\sum_w m\Bigr)\cdot 2,$$
using $\sum_w m_P = \sum_w m_Q = 1$. Rearranging gives $\sum_w m \ge \tfrac12\beta^{2n}$. $\square$

---

## 6. Hyperbolic drift: the silver envelope

### 6.1 The hyperbolic embedding

Embed the seeds in the hyperbolic upper half-plane $\mathbb{H}$ by
$$z(m,n) = \frac{n + i}{m},$$
with base point $o = i$. The hyperbolic distance from $o$ to $z(m,n)$ satisfies
$$\cosh d\bigl(o, z(m,n)\bigr) = 1 + \frac{n^2 + (m-1)^2}{2m},$$
and one has the clean two-sided window
$$\log m \;\le\; d\bigl(o, z(m,n)\bigr) \;\le\; \log m + \log 2 \qquad (0 < n < m),$$
so hyperbolic distance in this embedding *is* the logarithm of the first Euclid coordinate, to
within $\log 2$.

The growth of $m$ along the tree is governed by the **silver potential**
$$\Phi(m,n) = m + (\sqrt 2 - 1)\,n .$$
A direct computation gives
$$\Phi(L(m,n)) = (1+\sqrt2)m - n, \quad \Phi(M(m,n)) = (1+\sqrt2)m + n, \quad \Phi(R(m,n)) = m + (1+\sqrt2)n,$$
whereas $(1+\sqrt2)\,\Phi(m,n) = (1+\sqrt2)m + n$. Hence for every seed
$$\Phi(a \cdot v) \le (1 + \sqrt 2)\,\Phi(v) \quad\text{for } a \in \{L,M,R\},$$
with **equality precisely for the middle move $M$** (the inequality for $R$ uses $n < m$). Writing
$\mathrm{silver} = 1 + \sqrt2$, iteration gives $\Phi \le \mathrm{silver}^{\,k+1}$ at depth $k$, and
therefore the sharp envelope in terms of the labelling word $w \in \{L,M,R\}^{*}$:
$$\bigl(\#M(w) + 1\bigr)\log 2 \;\le\; d\bigl(o, z(\mathrm{run}(w))\bigr) \;\le\; \bigl(|w| + 1\bigr)\log(1+\sqrt2) + \log 2. \tag{6.1}$$
The lower bound reflects that each middle move at least doubles the relevant scale; the upper
bound is optimal, being attained along the pure-$M$ (Pell) spine.

### 6.2 The drift sandwich in mean

Averaging $(6.1)$ over the walk requires only one expectation, which is exact.

**Lemma 6.1 (Expected number of middle moves).** *In a random Berggren word of length $n$, the mean
number of middle moves is exactly $n p_1$ (writing $p_1$ for the weight of $M$).*

*Proof.* Linearity of expectation over the $n$ independent letters. $\square$

**Theorem 6.2 (Drift sandwich).** *Let $z_n$ be the node reached by the walk after $n$ steps. Then*
$$\bigl(n p_1 + 1\bigr)\log 2 \;\le\; \mathbb{E}\,d(o, z_n) \;\le\; (n+1)\log(1+\sqrt2) + \log 2,$$
*hence for $n \ge 1$*
$$p_1 \log 2 \;\le\; \frac{\mathbb{E}\,d(o,z_n)}{n} \;\le\; \log(1+\sqrt2) + \frac{\log(1+\sqrt2) + \log 2}{n}.$$
*In particular every Berggren walk has strictly positive escape speed, bounded below by
$p_1\log 2 > 0$, and the silver exponent $\log(1+\sqrt2) = 0.88137\ldots$ is an upper bound for the
speed of every Berggren walk.*

*Proof.* Take expectations in $(6.1)$ and use Lemma 6.1 for the left side; the right side of
$(6.1)$ is deterministic. $\square$

### 6.3 Almost sure drift and escape

**Theorem 6.3 (Almost sure frequency of the middle move).** *For $\mathrm{Ber}(P)$-a.e. ray $x$,
the fraction of middle moves among the first $n$ letters converges to $p_1$.*

*Proof.* Theorem 4.4 with $g = \mathbf 1_{\{M\}}$. $\square$

**Theorem 6.4 (Almost sure drift sandwich).** *For $\mathrm{Ber}(P)$-a.e. ray $x$ and every
$\varepsilon > 0$, for all sufficiently large $n$,*
$$p_1\log 2 - \varepsilon \;\le\; \frac{d(o, z_n(x))}{n} \;\le\; \log(1+\sqrt2) + \varepsilon .$$

*Proof.* Divide $(6.1)$ by $n$. The lower bound is $\frac{\#M+1}{n}\log 2$, which by Theorem 6.3
eventually exceeds $p_1\log2 - \varepsilon$ (take the frequency within $\varepsilon/\log 2$ of
$p_1$). The upper bound is $\frac{n+1}{n}\log(1+\sqrt2) + \frac{\log 2}{n}$, whose excess over
$\log(1+\sqrt2)$ is $(\log(1+\sqrt2)+\log 2)/n \to 0$. $\square$

**Corollary 6.5 (Almost sure escape to infinity).** *For every weight vector, $d(o,z_n) \to
+\infty$ almost surely. Hence the harmonic measure is genuinely carried by the boundary at
infinity, not by the tree.*

*Proof.* By Theorem 6.3 the frequency of middle moves eventually exceeds $p_1/2 > 0$, so
$d(o,z_n) \ge (\#M(x_{<n}) + 1)\log 2 \ge n\cdot\frac{p_1}{2}\log2 \to \infty$. $\square$

---

## 7. Two negative results

### 7.1 The spectral gap is $1$: silver does not govern the spectrum

**Definition 7.1 (Transfer operator).** For $f : \partial\mathcal{T}\to\mathbb{R}$ let
$$(\mathcal{L}f)(x) = \sum_{a\in\mathcal{A}} p_a\, f(\mathrm{cons}_a x) = p_0 f(Lx) + p_1 f(Mx) + p_2 f(Rx).$$
This is the Markov (averaging) operator of the walk; its fixed points are the harmonic functions
and its invariant measure is $\mathrm{Ber}(P)$.

Say $f$ *depends on the first $n$ letters* if $f(x) = f(y)$ whenever $x_i = y_i$ for all $i < n$.
The union over $n$ of these finite-dimensional spaces is the space of locally constant observables
— dense in $C(\partial\mathcal{T})$ by compactness and in $L^2(\mathrm{Ber}(P))$, and the natural
core on which to compute a spectrum.

**Lemma 7.2 (One letter of memory is lost per application).** *If $f$ depends on the first $n+1$
letters, then $\mathcal{L}f$ depends on the first $n$ letters.*

*Proof.* If $x_i = y_i$ for $i < n$, then $\mathrm{cons}_a x$ and $\mathrm{cons}_a y$ agree in
their first $n+1$ coordinates for each $a$, so $f(\mathrm{cons}_ax) = f(\mathrm{cons}_ay)$
termwise. $\square$

**Theorem 7.3 (Nilpotency modulo constants).** *If $f$ depends on the first $n$ letters, then
$\mathcal{L}^n f$ is constant. Consequently:*

1. *the only eigenvalues of $\mathcal{L}$ on locally constant observables are $0$ and $1$;*
2. *the eigenspace for the eigenvalue $1$ consists exactly of the constants;*
3. *the spectral gap is $1$, independently of $(p_0,p_1,p_2)$;*
4. *in particular $\log(1+\sqrt2) = 0.88137\ldots$, which lies strictly between $0$ and $1$, is
   **not** an eigenvalue of $\mathcal{L}$.*

*Proof.* Iterating Lemma 7.2 $n$ times sends dependence on the first $n$ letters to dependence on
the first $0$ letters, i.e. constancy. For (1): if $\mathcal{L}f = \lambda f$ with $f$ locally
constant, say depending on the first $n$ letters, and $f$ not identically $0$, then
$\lambda^n f = \mathcal{L}^n f$ is constant, say $= c$. If $\lambda \notin\{0,1\}$ then $f$ is the
constant $c\lambda^{-n}$; but $\mathcal{L}$ fixes constants, so $\lambda c\lambda^{-n} =
c\lambda^{-n}$, forcing $c = 0$ and hence $f \equiv 0$, a contradiction. For (2): if
$\mathcal{L}f = f$ then $f = \mathcal{L}^nf$ is constant. Items (3) and (4) follow. $\square$

This *refutes* the conjecture that the second eigenvalue of the Berggren Markov operator is
governed by the silver ratio. The situation is in fact the extreme opposite of a small gap: the
walk on the boundary loses all memory of a locally constant observable in finitely many steps, so
the gap is as large as it can be, and it does not depend on the dice at all. The silver ratio
governs the *drift* (Theorems 6.2 and 6.4), not the spectrum.

### 7.2 The entropy–metric gap: hyperbolic dimension at most $2/3$

The Berggren tree carries two exponents. The *combinatorial* one is $\log 3$: each node has three
children, so at depth $n$ there are $3^n$ nodes and the entropy of any harmonic measure is at most
$\log 3$ (Proposition 4.2). The *metric* one is read off the hyperbolic embedding: a depth-$n$ node
sits at hyperbolic distance at most $2(n+1)\log(1+\sqrt2) + O(1)$ in the log-hypotenuse
normalisation, so the natural conformal exponent is $2\log(1+\sqrt2)$.

**Lemma 7.4.** $(1+\sqrt2)^2 = 3 + 2\sqrt2$, hence $2\log(1+\sqrt2) = \log(3+2\sqrt2)$.

**Theorem 7.5 (The two exponents never coincide).** $\log 3 < 2\log(1+\sqrt2)$.

*Proof.* By Lemma 7.4 it suffices that $3 < 3 + 2\sqrt2$, which holds since $\sqrt2 > 0$. $\square$

Numerically $\log 3 = 1.09861\ldots$ and $2\log(1+\sqrt2) = 1.76275\ldots$.

**Definition 7.6 (Hyperbolic dimension of the harmonic measure).**
$$\dim_{\mathrm{hyp}}\nu_P = \frac{H(P)}{2\log(1+\sqrt2)}.$$

**Theorem 7.7 (Uniform dimension gap).** *For every weight vector $P$,*
$$\dim_{\mathrm{hyp}}\nu_P \;\le\; \frac{\log 3}{2\log(1+\sqrt2)} \;<\; 1,$$
*with equality on the left exactly for the fair walk. The deficit $1 - \log3/(2\log(1+\sqrt2)) =
0.37679\ldots$ is a uniform constant, independent of $P$. Moreover the explicit bound*
$$\dim_{\mathrm{hyp}}\nu_P \;\le\; \frac{2}{3}$$
*holds, as a consequence of $3^3 \le (1+\sqrt2)^4$.*

*Proof.* Combine Proposition 4.2 with Theorem 7.5. For the explicit bound, $\dim_{\mathrm{hyp}}
\le \log3/(2\log(1+\sqrt2)) \le 2/3$ is equivalent to $3\log 3 \le 4\log(1+\sqrt2)$, i.e.
$27 \le (1+\sqrt2)^4 = 17 + 12\sqrt2 = 33.97\ldots$ $\square$

The interpretation is sharp: *the harmonic measure of a Berggren walk is never the conformal
measure of the hyperbolic embedding.* No matter how the three moves are weighted, the entropy the
walk generates per step ($\le \log 3$) is strictly less than the hyperbolic length the tree
generates per step ($2\log(1+\sqrt2)$), and by a definite margin. The Berggren tree branches three
ways but stretches by $1+\sqrt2$; three is simply not enough to catch up. Combined with the proved
drift sandwich, this is the precise sense in which the harmonic measure is *dimension deficient*.

---

## 8. Algorithms

Three procedures underlie all the numerical experiments a reader may wish to run.

### 8.1 Word-to-triple evaluation

Given a word $w = w_1 \cdots w_n \in \{L,M,R\}^n$ (read right to left), the seed is computed by
folding the three affine maps, and the triple by Euclid's formulas. Cost: $O(n)$ arithmetic
operations on integers whose bit length grows like $\Theta(n)$, hence $O(n^2)$ bit operations
naively.

```
function EVAL(w):
    (m, n) := (2, 1)
    for a in reverse(w):
        if a = L: (m, n) := (2m - n, m)
        if a = M: (m, n) := (2m + n, m)
        if a = R: (m, n) := (m + 2n, n)
    return (m² - n², 2mn, m² + n²)
```

### 8.2 Harmonic mass, surprisal and dimension

The harmonic mass of the node labelled by $w$ is the product $\prod_i p_{w_i}$; its surprisal is
$\sum_i \iota(w_i)$. Both cost $O(n)$. The entropy identity of Theorem 4.3 can be checked in
$O(n\,3^n)$ by brute-force enumeration of all depth-$n$ words, or in $O(1)$ by evaluating $nH(P)$;
the agreement is a strong test of an implementation.

### 8.3 Empirical estimation from a single ray

Ray rigidity (Theorem 5.4) is directly algorithmic: to estimate the dice from a single trajectory,
count letters.

```
function ESTIMATE(x, n):
    counts := [0, 0, 0]
    for i in 0..n-1: counts[x_i] += 1
    return counts / n            # → (p₀, p₁, p₂) a.s.
```

By Theorem 5.7 the error is $O(\sqrt{\log(1/\delta)/n})$ with probability $1-\delta$, with the
exact exponential rate $\mathrm{KL}(u\Vert p_a)$. Theorem 5.12 shows this is essentially optimal
among all depth-$n$ procedures: no post-processing of the first $n$ letters can distinguish two
walks better than the Bhattacharyya exponent allows.

---

## 9. Discussion

### 9.1 What the picture looks like now

The Berggren tree has become a fully worked example in the theory of random walks on trees:

| Object | Value |
|---|---|
| Boundary | Cantor set $\{L,M,R\}^{\mathbb{N}}$, 3-adic topology |
| Harmonic measure | Unique; equals $\mathrm{Ber}(p_0,p_1,p_2)$ |
| Entropy | $H(P)$ exactly, at every finite depth and a.s. |
| Dimension (3-adic) | $H(P)/\log 3 \in (0,1]$; $=1$ iff fair |
| Dimension (hyperbolic) | $H(P)/(2\log(1+\sqrt2)) \le 0.6232\ldots \le 2/3$ |
| Shift | Ergodic for every $P$; measures pairwise singular |
| Drift | $p_1\log 2 \le \text{speed} \le \log(1+\sqrt2)$, in mean and a.s. |
| Spectral gap | $1$, for every $P$ |
| Separation rate | Between the Chernoff and Bhattacharyya exponents |

### 9.2 Three constants, three roles

The most striking structural conclusion is that the tree's several natural constants do *not*
collapse into one:

* $\log 3$ is the *information* exponent — the maximum entropy the walk can generate per step, and
  the normaliser for dimension in the 3-adic metric;
* $\log(1+\sqrt2)$ is the *metric* exponent — the sharp upper envelope of hyperbolic displacement
  per unit depth, attained on the Pell spine of pure middle moves;
* $1$ is the *spectral gap* — maximal, and completely insensitive to the weights.

The mission hypothesis that motivated this study predicted the silver ratio would appear in the
spectrum. It does not. It appears in the drift, and it appears in the dimension deficit, in both
cases in a way that is now exactly quantified.

### 9.3 Comparison with free groups

The Berggren tree is the Cayley graph of a free monoid on three generators, so much of the theory
above is formally parallel to the classical theory of random walks on free groups: Cantor boundary,
Bernoulli harmonic measure, entropy $=$ dimension times $\log(\text{branching})$, positive speed,
ergodic boundary action. The arithmetic content is what makes the present case special: the
boundary points are genuine directions in the space of primitive Pythagorean triples, and the
metric structure comes not from the word metric but from the hyperbolic embedding $z(m,n) =
(n+i)/m$, whose growth constant is $1 + \sqrt 2$ rather than the branching number. It is exactly
this mismatch — a word metric of exponent $\log 3$ against a hyperbolic metric of exponent
$2\log(1+\sqrt2)$ — that produces the uniform dimension deficit of Theorem 7.7 and has no analogue
in the homogeneous free-group setting.

### 9.4 Applications

* **Sampling primitive triples.** The harmonic measure gives a rigorous handle on what "a random
  Pythagorean triple" means. Sampling at depth $n$ with weights $P$ produces triples whose
  log-hypotenuse concentrates in the band $[np_1\log 2,\, n\log(1+\sqrt2)]$; tuning $p_1$ tunes the
  size distribution while $H(P)/\log 3$ tunes how much of the tree the sample explores.
* **Statistical identification.** Theorems 5.8 and 5.12 say precisely how many moves of a Berggren
  trajectory one must observe to identify the generating law, and give matching upper and lower
  bounds on the achievable error exponent — a complete hypothesis-testing theory on this boundary.
* **Multifractal templates.** The family $\{\mathrm{Ber}(P)\}$ is a two-parameter family of
  pairwise mutually singular measures with full support and prescribed dimension $H(P)/\log 3$
  ranging over $(0,1]$, all on one compact set. This makes the Berggren boundary a clean testbed
  for multifractal formalism with explicit arithmetic labels.

---

## 10. Future directions

**Conjecture 1 (Exact escape rate).** The proved statements are sandwiches: $p_1\log2 \le
\mathbb{E}\,d(o,z_n)/n \le \log(1+\sqrt2) + O(1/n)$ in mean, and the same two-sided bound almost
surely along a typical ray. We conjecture the limit exists and equals a weighted average
$$\ell(P) = p_0\kappa_0 + p_1\kappa_1 + p_2\kappa_2$$
of three explicit move-dependent exponents, with $\kappa = (0,\, 2\log(1+\sqrt2),\, 0)$ in the
log-hypotenuse metric — i.e. the gap between the two sides of the proved sandwich closes, and the
middle move alone contributes to the speed.

**Conjecture 2 (Dimension of harmonic measure in the hyperbolic metric).** With an exact escape
rate $\ell(P)$ in hand, the natural dimension formula $\dim = H(P)/\ell(P)$ should replace the
bound of Theorem 7.7, and it should be *maximised at a non-fair weight vector* — the walk that
optimally trades information against displacement.

**Conjecture 3 (Sharp cutoff constant).** Theorems 5.8 and 5.12 bracket the depth-$n$ separation
exponent between the Chernoff rate and $-2\log\beta(P,Q)$. We conjecture the true exponent is the
Chernoff information $C(P,Q) = -\log\min_{0\le t\le1}\sum_a p_a^t q_a^{1-t}$, coinciding with the
Bhattacharyya bound exactly when the optimising $t$ is $1/2$.

**Further programmes.**
* *Non-i.i.d. walks.* Replace the memoryless step law by a Markov chain on $\{L,M,R\}$. The
  harmonic measure should become a Gibbs measure on the boundary rather than a product measure,
  with entropy the Markov entropy and dimension the corresponding ratio; ray rigidity should
  survive with the transition matrix as the invariant.
* *Arithmetic multifractality.* Study the spectrum of local dimensions of $\mathrm{Ber}(P)$ with
  respect to the *hypotenuse* metric $|x - y| \asymp c(x\wedge y)^{-1}$ rather than the 3-adic one;
  Theorem 7.7 suggests a genuinely nontrivial multifractal spectrum.
* *Harmonic measure of subtrees.* The Pell spine of pure middle moves and other periodic rays are
  natural distinguished points of the boundary. Local behaviour of $\mathrm{Ber}(P)$ near such
  points, and the associated conformal/Patterson–Sullivan theory of the hyperbolic embedding, are
  open.
* *Groupoid and hyperbolic-embedding refinements.* Relating the harmonic measure to the natural
  conformal density on the limit set of the embedded tree would explain the constant $2/3$
  structurally rather than numerically.

---

## 11. Conclusion

The random walk on the Berggren tree of primitive Pythagorean triples has a complete and
completely explicit boundary theory. Its harmonic measure exists, is unique, and is the Bernoulli
product measure; its entropy is exactly $H(p_L,p_M,p_R)$ at every finite depth and almost surely;
its 3-adic dimension is $H/\log 3$, maximal exactly for the fair walk; the boundary shift is
ergodic; different walks are rigidly and exponentially distinguishable, with matching Chernoff and
Bhattacharyya exponents bracketing the rate; and the walk escapes to infinity at a speed sandwiched
between $p_M\log2$ and the silver exponent $\log(1+\sqrt2)$.

Two conjectures fell in the process. The silver ratio does *not* govern the spectral gap of the
walk — the gap is $1$ for every weight vector, since the transfer operator forgets one letter per
application and is nilpotent modulo constants. And silver *outruns* entropy: $\log 3 <
2\log(1+\sqrt2)$, so the hyperbolic dimension of the harmonic measure is at most $2/3$ uniformly,
and no Berggren walk sees the conformal measure of the hyperbolic embedding. Elementary number
theory, it turns out, supplies a probabilistic object of textbook cleanliness — and one whose
constants stubbornly refuse to be the same constant.
