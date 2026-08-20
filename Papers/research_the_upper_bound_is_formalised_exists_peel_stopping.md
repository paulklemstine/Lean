# Peeling Profiles: Rigidity, Stability, and the Universal Family of Extremal Dilation Peelings

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

A *peeling process* is the abstract skeleton shared by a wide family of
geometric and combinatorial arguments: one removes successive layers from an
object and records the residual content. The data reduces to a nonincreasing
nonnegative sequence $s_0 \ge s_1 \ge \cdots \ge 0$, whose successive
differences $g_k = s_k - s_{k+1}$ are the layer contents. The classical upper
bound is a pigeonhole statement: within any window of $N$ steps there is a
step with $g_k \le \rho_N := (s_0 - s_N)/N$.

This paper develops the sharpness theory of that bound in four directions and
closes it with a complete geometric classification of the extremisers.

1. **Rigidity.** We prove a four-way equivalence: every layer being at most
   the average, every layer being exactly the average, the profile being
   exactly affine on the window, and the layer contents being invariant under
   the cyclic shift of $\mathbb{Z}/N$, are all the same condition. More
   generally, invariance of the layer contents under *any* pretransitive group
   action on the window forces extremality; and conversely extremality is
   equivalent to invariance under the full symmetric group of the window.
2. **Stability.** If every layer satisfies $g_k \le (1+\varepsilon)\rho_N$,
   then the profile lies uniformly within $\varepsilon (s_0 - s_N)$ of the
   affine one. The estimate is linear in $\varepsilon$, dimension-free, and
   degenerates to rigidity at $\varepsilon = 0$.
3. **A variational description.** With layer energy $E_N = \sum_{k<N} g_k^2$
   and budget $A_N = s_0 - s_N$, the exact identity
   $E_N - A_N^2/N = \sum_{k<N} (g_k - A_N/N)^2$ shows $E_N \ge A_N^2/N$ with
   equality precisely at the extremisers, giving an independent proof of
   rigidity and identifying the extremal peelings as the minimisers of a
   quadratic energy.
4. **The universal matching family.** For every dimension $d \ge 1$, every
   $N \ge 1$ and *every* measurable star-shaped body $K \subseteq
   \mathbb{R}^d$ of finite volume, the dilates $c_k K$ with
   $c_k = (1 - k/N)^{1/d}$ peel $K$ into $N$ layers of equal volume
   $\mathrm{vol}(K)/N$; every layer is invariant under the entire linear
   symmetry group of $K$; and conversely any dilation peeling all of whose
   layers have volume at most $\mathrm{vol}(K)/N$ must be this one. The
   dilation factors depend on $d$ and $N$ only, never on $K$. Balls, with
   symmetry group $O(d)$, are the special case.

We also record a boundary-concentration estimate: the outermost equal-volume
shell of $B(0,R) \subseteq \mathbb{R}^d$ carries a $1/N$ fraction of the
volume but has thickness at most $R/(d(N-1))$, so high-dimensional
equal-volume peelings collapse onto the boundary sphere. The result is that
the extremisers of a purely arithmetic bound are classified by pairs $(K, G)$
with $K$ a star-shaped body and $G$ a group of linear symmetries of $K$.

**Keywords:** peeling process, pigeonhole bound, rigidity, stability,
equal-volume shells, star-shaped body, dilation, concentration of measure,
equivariance.

---

## 1. Introduction

### 1.1 The bound and the question

Many arguments in geometry, combinatorics and theoretical computer science
share a common core. One decomposes an object into successive layers, tracks a
monotone quantity — volume, measure, cardinality, entropy, potential — and
then invokes an averaging argument to locate a layer that is cheap. The
canonical instance is: *if a total of $A$ is removed in $N$ steps, some step
removes at most $A/N$.*

The argument is used to find thin slabs in decompositions of convex bodies, to
find sparse levels in filtrations of graphs, to select cheap recursion depths
in divide-and-conquer algorithms, and to locate good stopping times in
iterative geometric constructions. Its virtue is that it requires nothing of
the object being peeled.

Precisely because it requires nothing, it says nothing about tightness. The
natural questions are:

- *(Sharpness.)* Is the constant $1$ in $g_k \le \rho_N$ optimal, or does the
  monotone structure of a peeling force something better?
- *(Rigidity.)* If the bound is saturated, what does the peeling look like?
- *(Stability.)* If the bound is nearly saturated, is the peeling nearly
  extremal?
- *(Realisation.)* Do the extremal profiles occur as actual geometric
  decompositions, or are they combinatorial fictions?

This paper answers all four. The short version: the constant is optimal, the
extremisers are exactly the affine profiles, extremality is *equivalent* to a
transitive symmetry on the layers, the stability estimate is linear, and the
geometric extremisers are the equal-volume dilation peelings of arbitrary
star-shaped bodies.

### 1.2 Organisation

Section 2 sets up peeling profiles and proves the upper bound with its error
control and density refinements. Section 3 proves the rigidity theorem and its
group-theoretic reformulations. Section 4 proves stability. Section 5 gives
the variational (energy) description. Section 6 constructs the geometric
matching family for balls and proves rigidity there. Section 7 proves the
boundary-concentration estimate. Section 8 removes the ball and proves
universality for star-shaped bodies. Section 9 discusses algorithms and
applications, and Section 10 lists open directions.

---

## 2. Peeling profiles and the upper bound

### 2.1 Definitions

**Definition 2.1 (peeling profile).** A *peeling profile* is a function
$s : \mathbb{N} \to \mathbb{R}$ that is antitone ($s_j \le s_i$ whenever
$i \le j$) and nonnegative ($s_k \ge 0$ for all $k$). We interpret $s_k$ as
the residual content after $k$ peeling steps.

**Definition 2.2 (layer content, budget, rate).** For a peeling profile $s$
and $k, N \in \mathbb{N}$ define
$$g_k \;=\; s_k - s_{k+1} \quad (\text{the } k\text{-th layer content}),$$
$$A_N \;=\; s_0 - s_N \quad (\text{the budget of the window } [0,N)),$$
$$\rho_N \;=\; A_N / N \quad (\text{the average rate}),$$
with the convention $\rho_0 = 0$. Antitonicity gives $g_k \ge 0$ and
$A_N \ge 0$, hence $\rho_N \ge 0$.

**Lemma 2.3 (telescoping).** $\sum_{k=0}^{N-1} g_k = A_N$, and consequently
$N\rho_N = A_N$ for $N \ge 1$ (and also for $N = 0$, both sides being $0$).

*Proof.* Immediate telescoping of $\sum_{k<N} (s_k - s_{k+1})$. $\square$

Lemma 2.3 is the only structural input to everything in Sections 2–5.

### 2.2 The stopping-time bound

**Theorem 2.4 (existence of a good stopping time).** Let $s$ be a peeling
profile and $N \ge 1$. Then there exists $k < N$ with $g_k \le \rho_N$.

*Proof sketch.* By Lemma 2.3, $\sum_{k<N} g_k = A_N = \sum_{k<N} \rho_N$. A
finite family of reals whose sum is at most the sum of a constant family must
contain a member at most that constant; otherwise the strict inequalities
would sum to a strict inequality. $\square$

The value of Theorem 2.4 is that the hypothesis is minimal: only monotonicity
and nonnegativity are used, and nonnegativity is used only to make $\rho_N$
meaningful as a rate.

### 2.3 The affine estimate and its error

**Definition 2.5 (affine estimate).** For $N \ge 1$ set
$\ell_k \;=\; s_0 - k \rho_N$ for $k \in \mathbb{N}$.

Then $\ell_0 = s_0$ and $\ell_N = s_N$ by Lemma 2.3: the affine estimate
interpolates the profile at the two endpoints of the window.

**Lemma 2.6 (error representation).** For all $k$,
$$s_k - \ell_k \;=\; \sum_{j<k} (\rho_N - g_j),$$
and $\sum_{j<N} (\rho_N - g_j) = 0$, whence for $k \le N$,
$$\sum_{j=k}^{N-1} (\rho_N - g_j) \;=\; -(s_k - \ell_k).$$

*Proof sketch.* Expand the sum using Lemma 2.3 and the definition of $\ell_k$;
the second display follows by splitting the full-window sum at $k$. $\square$

**Theorem 2.7 (two-sided error bound).** For $0 \le k \le N$,
$$|s_k - \ell_k| \;\le\; \max(k,\, N-k)\,\rho_N .$$

*Proof sketch.* By Lemma 2.6 and $g_j \ge 0$, the forward sum gives
$s_k - \ell_k \le k\rho_N$. The tail form of Lemma 2.6, with the same bound
applied to $\sum_{j=k}^{N-1}(\rho_N - g_j) \le (N-k)\rho_N$, gives
$s_k - \ell_k \ge -(N-k)\rho_N$. Take the larger coefficient. $\square$

The bound is sharp at both ends: for the profile $s = (A, 0, 0, \dots)$ with
window $N$, one has $s_k - \ell_k = -k\rho_N$ for $1 \le k \le N$, matching
the backward half for small $k$.

**Proposition 2.8 (hypothesis-free error bound).** For $0 \le k \le N$,
$|s_k - \ell_k| \le A_N$: the affine estimate never errs by more than the
whole budget.

*Proof sketch.* Both $s_k$ and $\ell_k$ lie in the interval $[s_N, s_0]$ of
length $A_N$: for $s_k$ by antitonicity, for $\ell_k$ because $k\rho_N$ ranges
over $[0, A_N]$ as $k$ ranges over $[0,N]$. $\square$

### 2.4 Density of good stopping times

Theorem 2.4 produces one good step; in fact most steps are good.

**Theorem 2.9 (Markov bound for peelings).** For any threshold $t \in
\mathbb{R}$,
$$\#\{k < N : g_k \ge t\} \cdot t \;\le\; A_N .$$

*Proof sketch.* Let $S = \{k<N : g_k \ge t\}$. Then
$|S|\,t \le \sum_{k \in S} g_k \le \sum_{k<N} g_k = A_N$, the middle
inequality because the omitted layers are nonnegative. $\square$

**Corollary 2.10 (density in units of the rate).** If $N \ge 1$, $A_N > 0$ and
$c > 0$, then
$$\#\{k < N : g_k \ge c\,\rho_N\} \;\le\; \frac{N}{c}.$$

Thus at most half of the steps have a layer of at least twice the average, at
most a tenth of at least ten times the average, and so on. Good stopping times
are not rare events.

### 2.5 Stable windows

In practice one often wants not a single good step but a *run* of good steps.
This is obtained by applying Theorem 2.4 to a coarsened profile.

**Definition 2.11 (block profile).** For $J \ge 1$ define the *block profile*
of stride $J$ by $s^{(J)}_k = s_{Jk}$. It is again antitone and nonnegative.

**Theorem 2.12 (stable window).** Let $J \ge 0$ and $M \ge 1$. There exists a
block index $b < M$ such that
$$g_{Jb + j} \;\le\; \frac{s_0 - s_{JM}}{M} \qquad \text{for every } j < J .$$

*Proof sketch.* Apply Theorem 2.4 to $s^{(J)}$ over a window of $M$ steps: some
block $b$ satisfies $s_{Jb} - s_{J(b+1)} \le (s_0 - s_{JM})/M$. For any $j<J$,
monotonicity gives $s_{Jb+j} \le s_{Jb}$ and $s_{J(b+1)} \le s_{Jb+j+1}$, so
$g_{Jb+j} = s_{Jb+j} - s_{Jb+j+1} \le s_{Jb} - s_{J(b+1)}$. $\square$

Since $J$ consecutive layers each of content at most $(s_0 - s_{JM})/M$ is a
strong statement when $J$ is large, Theorem 2.12 is the form in which the
pigeonhole peeling bound is usually applied to multiscale constructions.

---

## 3. Rigidity: equality forces symmetry

### 3.1 The four-way equivalence

**Theorem 3.1 (rigidity of the peeling bound).** Let $s$ be a peeling profile
and $N \ge 1$. The following are equivalent.

1. $g_k \le \rho_N$ for all $k < N$;
2. $g_k = \rho_N$ for all $k < N$;
3. $s_k = s_0 - k\rho_N$ for all $k \le N$;
4. $g_k = g_{(k+1) \bmod N}$ for all $k < N$.

*Proof sketch.*
$(1) \Rightarrow (2)$: the quantities $\rho_N - g_k$, $k < N$, are nonnegative
by hypothesis and sum to $0$ by Lemma 2.3; a finite sum of nonnegative reals
vanishes only if every term vanishes.
$(2) \Rightarrow (3)$: induction on $k$, the inductive step being
$s_{k+1} = s_k - g_k = (s_0 - k\rho_N) - \rho_N$.
$(3) \Rightarrow (1)$: subtracting consecutive instances of (3) gives
$g_k = \rho_N$ exactly, hence (1).
$(2) \Rightarrow (4)$: both sides equal $\rho_N$, the index $(k+1)\bmod N$
being $< N$.
$(4) \Rightarrow (2)$: clause (4) says the gap function is invariant under the
cyclic successor map on $\{0,\dots,N-1\}$; iterating from $0$ shows
$g_k = g_0$ for all $k<N$. Then $N g_0 = A_N$ by Lemma 2.3, so
$g_0 = \rho_N$. $\square$

The equivalence upgrades an inequality into a classification: the extremisers
of the pigeonhole bound over a window are exactly the affine (equipartition)
profiles, and equally exactly the cyclically symmetric ones.

**Remark 3.2.** Clause (4) is the conceptual pivot of this paper. It states
that extremality is *not* an analytic condition but a symmetry condition, and
therefore that it can be verified — or engineered — by exhibiting a group
action rather than by estimating anything.

### 3.2 Symmetry implies extremality

Write $\gamma : \{0,\dots,N-1\} \to \mathbb{R}$, $\gamma(i) = g_i$, for the
gap function of the window.

**Theorem 3.3 (symmetry forces extremality).** Let $N \ge 1$ and let a group
$G$ act on the window $\{0,\dots,N-1\}$ pretransitively (for all $i,j$ there
is $\sigma \in G$ with $\sigma \cdot i = j$). Suppose the layer contents are
$G$-invariant: $\gamma(\sigma \cdot i) = \gamma(i)$ for all $\sigma \in G$,
$i$. Then $\gamma \equiv \rho_N$, and consequently $s_k = s_0 - k\rho_N$ for
all $k \le N$.

*Proof sketch.* Pretransitivity and invariance force $\gamma$ to be constant,
$\gamma \equiv \gamma(0)$. Summing over the window and applying Lemma 2.3
gives $N\gamma(0) = A_N$, i.e. $\gamma(0) = \rho_N$. The affine conclusion is
then clause (3) of Theorem 3.1. $\square$

**Corollary 3.4 (a single $N$-cycle suffices).** Let $\sigma$ be an $N$-cycle
on the window (for instance the successor map $i \mapsto i+1 \bmod N$). The
cyclic group $\langle \sigma \rangle$ acts pretransitively — the $m$-th power
of the successor map is translation by $m$, and translation by $j - i$ carries
$i$ to $j$. Hence if the layer contents are invariant under $\sigma$ alone,
the profile is affine on the window.

**Theorem 3.5 (extremality is maximal symmetry).** For $N \ge 1$ the following
are equivalent:
$$g_k \le \rho_N \text{ for all } k<N \qquad \Longleftrightarrow \qquad
\gamma(\sigma \cdot i) = \gamma(i) \text{ for all } \sigma \in \mathrm{Sym}(N),\ i .$$

*Proof sketch.* ($\Rightarrow$) By Theorem 3.1 the gap function is the constant
$\rho_N$, which is invariant under every permutation. ($\Leftarrow$) The
symmetric group acts pretransitively (via transpositions), so Theorem 3.3
applies and gives equality, hence in particular the inequality. $\square$

Combining Corollary 3.4 with Theorem 3.5: invariance under a *single* $N$-cycle
already implies invariance under the *full* symmetric group of the window.
There is no intermediate regime.

---

## 4. Stability

Rigidity is an all-or-nothing statement. Applications require the perturbative
version.

**Theorem 4.1 (stability of the peeling bound).** Let $s$ be a peeling
profile, $N \ge 1$, $\varepsilon \ge 0$, and suppose
$$g_j \;\le\; (1+\varepsilon)\,\rho_N \qquad \text{for all } j < N .$$
Then for every $k \le N$,
$$|s_k - \ell_k| \;\le\; \varepsilon\, A_N .$$

*Proof sketch.* The hypothesis is equivalent to the one-sided deviation bound
$\rho_N - g_j \ge -\varepsilon\rho_N$ for $j<N$. Summing over $j<k$ and using
Lemma 2.6 gives
$s_k - \ell_k \ge -k\varepsilon\rho_N \ge -N\varepsilon\rho_N =
-\varepsilon A_N$. Summing over $k \le j < N$ and using the tail form of
Lemma 2.6 gives $-(s_k - \ell_k) \ge -(N-k)\varepsilon\rho_N \ge
-\varepsilon A_N$, i.e. $s_k - \ell_k \le \varepsilon A_N$. $\square$

**Remark 4.2.** Three features are worth noting. The bound is *linear* in
$\varepsilon$; it is *uniform* in $k$; and it involves no dependence on $N$
beyond the budget. At $\varepsilon = 0$ it reproduces clause (3) of
Theorem 3.1, so Theorem 4.1 strictly contains rigidity. In this sense the
extremal set is not merely rigid but *quantitatively* rigid: distance to
extremality in the sup-norm is controlled by the multiplicative slack in the
defining inequality.

**Theorem 4.3 (geometric stability for ball peelings).** Fix $d \ge 1$,
$N \ge 1$, $R \ge 0$ and $\varepsilon \ge 0$. Let $r_0 \ge r_1 \ge \cdots$ be
nonnegative radii with $r_0 = R$, $r_N = 0$, and suppose every shell satisfies
$$\mathrm{vol}\,B(0,r_j) - \mathrm{vol}\,B(0,r_{j+1}) \;\le\;
(1+\varepsilon)\,\frac{\mathrm{vol}\,B(0,R)}{N}, \qquad j<N.$$
Then for every $k \le N$,
$$\Bigl|\,\mathrm{vol}\,B(0,r_k) - \mathrm{vol}\,B(0,R)\left(1 - \tfrac{k}{N}\right)\Bigr|
\;\le\; \varepsilon\, \mathrm{vol}\,B(0,R).$$

*Proof sketch.* The volumes $s_k = \mathrm{vol}\,B(0,r_k)$ form a peeling
profile with budget $\mathrm{vol}\,B(0,R)$ (using $r_0 = R$, $r_N = 0$) and
rate $\mathrm{vol}\,B(0,R)/N$; apply Theorem 4.1 and identify the affine
estimate. $\square$

---

## 5. The variational description

Define the **layer energy** of a window by
$$E_N \;=\; \sum_{k<N} g_k^{\,2}.$$

**Theorem 5.1 (energy identity).** For $N \ge 1$,
$$E_N - \frac{A_N^{\,2}}{N} \;=\; \sum_{k<N} \left(g_k - \rho_N\right)^{2}.$$

*Proof sketch.* Expand the right-hand side as
$\sum g_k^2 - 2\rho_N \sum g_k + N\rho_N^2$, substitute $\sum_{k<N} g_k = A_N$
(Lemma 2.3) and $\rho_N = A_N/N$, and simplify. $\square$

**Corollary 5.2 (energy lower bound).** $E_N \ge A_N^2/N$ for every peeling
profile and every $N \ge 1$.

This is the Cauchy–Schwarz inequality for the vector $(g_0,\dots,g_{N-1})$
against the all-ones vector, obtained here by completing the square without
invoking Cauchy–Schwarz.

**Theorem 5.3 (equality case).** $E_N = A_N^2/N$ if and only if $g_k = \rho_N$
for all $k < N$; that is, if and only if the peeling is extremal in the sense
of Theorem 3.1.

*Proof sketch.* By Theorem 5.1 equality is equivalent to the vanishing of a
sum of squares, hence to the vanishing of every term. $\square$

Theorem 5.3 provides a second, independent proof of rigidity, and reframes the
extremisers as the *minimisers of a quadratic energy*. The excess energy
$E_N - A_N^2/N$ is precisely $N$ times the variance of the layer distribution:
it is a natural, computable *defect functional* measuring failure of
extremality. Note that stability (Theorem 4.1) controls the sup-norm defect,
while the energy identity controls the $\ell^2$ defect; the two are
complementary.

**Theorem 5.4 (dual pigeonhole).** For $N \ge 1$ there is also a step $k<N$
with $g_k \ge \rho_N$. Consequently
$$\min_{k<N} g_k \;\le\; \rho_N \;\le\; \max_{k<N} g_k ,$$
with equality throughout precisely in the extremal case.

*Proof sketch.* Same averaging argument as Theorem 2.4, with the inequality
reversed. $\square$

---

## 6. The geometric matching family: equal-volume shells of a ball

We now realise the extremal profiles geometrically. Throughout, $\mathrm{vol}$
denotes Lebesgue measure on $\mathbb{R}^d$ and $B(0,r)$ the open Euclidean
ball.

### 6.1 Volumes and the shell radii

**Lemma 6.1 (scaling).** For $d \ge 1$ and $r \ge 0$,
$\mathrm{vol}\,B(0,r) = r^d\,\mathrm{vol}\,B(0,1)$, and
$\mathrm{vol}\,B(0,1) \in (0,\infty)$. Consequently $r \mapsto
\mathrm{vol}\,B(0,r)$ is strictly increasing on $[0,\infty)$, and in
particular two nonnegative radii with equal ball volumes are equal.

**Definition 6.2 (shell radii).** For $R \ge 0$, $d, N \ge 1$ and
$k \in \mathbb{N}$ set
$$r_k \;=\; R\left(\max\left(0,\, 1 - \tfrac{k}{N}\right)\right)^{1/d}.$$
Then $r_0 = R$, $r_N = 0$, and $k \mapsto r_k$ is antitone and nonnegative.

The truncation by $\max(0,\cdot)$ merely extends the family beyond $k = N$ by
the constant $0$; on the window $0 \le k \le N$ it is inert.

**Definition 6.3 (shell layer).** The $k$-th *shell* of the peeling is
$$S_k \;=\; B(0, r_k) \setminus B(0, r_{k+1}).$$

### 6.2 Equal volumes and $O(d)$-equivariance

**Theorem 6.4 (the shell peeling is an equipartition).** For $d, N \ge 1$,
$R \ge 0$ and $k \le N$,
$$\mathrm{vol}\,B(0,r_k) \;=\; \mathrm{vol}\,B(0,R)\left(1 - \tfrac{k}{N}\right),$$
and for $k < N$,
$$\mathrm{vol}(S_k) \;=\; \frac{\mathrm{vol}\,B(0,R)}{N}.$$
In particular the associated peeling profile
$s_k = \mathrm{vol}\,B(0,r_k)$ is exactly affine on the window and saturates
Theorem 2.4 at every step.

*Proof sketch.* The first display is Lemma 6.1 applied to $r_k$: raising
$R(1-k/N)^{1/d}$ to the $d$-th power returns $R^d(1-k/N)$. The second follows
by subtracting consecutive instances, using that the shells are nested
($r_{k+1} \le r_k$) and of finite measure, so that
$\mathrm{vol}(S_k) = \mathrm{vol}\,B(0,r_k) - \mathrm{vol}\,B(0,r_{k+1})$.
$\square$

**Theorem 6.5 ($O(d)$-equivariance).** For every linear isometry $e$ of
$\mathbb{R}^d$ and every $k$, $e(S_k) = S_k$.

*Proof sketch.* A linear isometry fixes the origin and preserves norms, so
$e(B(0,r)) = B(0,r)$ for every $r$; since $e$ is injective it commutes with set
difference. $\square$

Thus the decomposition $\{S_k\}$ is a family of $O(d)$-invariant sets whose
volumes are all equal; the layer contents are constant, hence invariant under
any action on the index set, in particular under the cyclic shift. By
Corollary 3.4 this recovers extremality by pure symmetry, without recomputing
volumes.

### 6.3 Rigidity and sharpness for ball peelings

**Theorem 6.6 (rigidity of ball peelings).** Let $d, N \ge 1$, $R \ge 0$, and
let $\rho_0 \ge \rho_1 \ge \cdots \ge 0$ be radii with $\rho_0 = R$,
$\rho_N = 0$, satisfying
$$\mathrm{vol}\,B(0,\rho_k) - \mathrm{vol}\,B(0,\rho_{k+1}) \;\le\;
\frac{\mathrm{vol}\,B(0,R)}{N} \qquad \text{for all } k<N .$$
Then $\rho_k = R(1-k/N)^{1/d}$ for every $k \le N$.

*Proof sketch.* The volumes form a peeling profile of budget
$\mathrm{vol}\,B(0,R)$; the hypothesis is exactly clause (1) of Theorem 3.1,
so clause (3) gives
$\mathrm{vol}\,B(0,\rho_k) = \mathrm{vol}\,B(0,R)(1-k/N) =
\mathrm{vol}\,B(0,r_k)$. Since ball volume is a strictly increasing function
of the radius on $[0,\infty)$ (Lemma 6.1), $\rho_k = r_k$. $\square$

Note the shape of the argument: the *volume* profile is pinned by pure
arithmetic; geometry enters only in the last step, to recover the radius from
the volume.

**Theorem 6.7 (optimality of the constant).** Let $c < 1$. Then no bound of
the form "some shell has volume at most $c\,\mathrm{vol}\,B(0,R)/N$" holds for
all ball peelings: the equal-volume shell family has *every* shell of volume
exactly $\mathrm{vol}\,B(0,R)/N > c\,\mathrm{vol}\,B(0,R)/N$ (for $R>0$).
Equivalently, the constant $1$ in Theorem 2.4 cannot be improved, already
within the class of concentric ball peelings in any fixed dimension.

**Example 6.8.** In the plane ($d=2$) with $R=1$, $N=4$, the radii are
$$1,\quad \sqrt{3}/2 \approx 0.8660,\quad \sqrt{2}/2 \approx 0.7071,\quad
1/2, \quad 0,$$
and the four annuli each have area $\pi/4 \approx 0.7854$. The radii are not
in arithmetic progression; only their squares are. This is the reason
rigidity must be phrased through the *volume* profile rather than the radius
profile, and it is what makes Theorem 6.6 a genuinely dimension-dependent
statement.

### 6.4 Energy minimality of the shell family

**Theorem 6.9 (equal-volume shells minimise shell energy).** Let $d,N \ge 1$,
$R \ge 0$, and let $\rho_0 = R \ge \rho_1 \ge \cdots \ge \rho_N = 0$ be any
nested radii. Then
$$\sum_{k<N} \bigl(\mathrm{vol}\,B(0,\rho_k) - \mathrm{vol}\,B(0,\rho_{k+1})\bigr)^2
\;\ge\; \frac{(\mathrm{vol}\,B(0,R))^2}{N},$$
and the equal-volume shell radii $r_k = R(1-k/N)^{1/d}$ attain the minimum.

*Proof sketch.* Corollary 5.2 applied to the volume profile, whose budget is
$\mathrm{vol}\,B(0,R)$; attainment is Theorem 6.4 plus a direct computation,
$N \cdot (\mathrm{vol}\,B(0,R)/N)^2 = (\mathrm{vol}\,B(0,R))^2/N$. $\square$

---

## 7. Boundary concentration

The shell family has a uniform *volume* profile but a violently non-uniform
*geometric* profile: the shells thin out towards the boundary as the dimension
grows.

**Lemma 7.1 (geometric-sum inequality).** For $d \ge 1$ and $0 \le s \le 1$,
$$(1-s)\, d\, s^{\,d-1} \;\le\; 1 - s^{\,d}.$$

*Proof sketch.* The factorisation $1 - s^d = (1-s)\sum_{i<d} s^i$ holds
identically. Each term of $\sum_{i<d} s^i$ is at least $s^{d-1}$ because
$0 \le s \le 1$ and the exponents run over $0,\dots,d-1$; hence the sum is at
least $d\,s^{d-1}$. Multiply by $1-s \ge 0$. $\square$

**Lemma 7.2 (normalised concentration).** For $d \ge 1$ and $N \ge 2$,
$$1 - \left(1 - \tfrac1N\right)^{1/d} \;\le\; \frac{1}{d\,(N-1)} .$$

*Proof sketch.* Put $t = 1 - 1/N \in [0,1]$ and $s = t^{1/d}$, so $s^d = t$ and
$s \in [0,1]$. Lemma 7.1 gives $(1-s)\,d\,s^{d-1} \le 1 - t = 1/N$. Since
$s^{d} \le s^{d-1}$, we get $(1-s)\,d\,t \le 1/N$, i.e.
$(1-s)\,d\,\frac{N-1}{N} \le \frac1N$, which rearranges to
$1 - s \le \frac{1}{d(N-1)}$. $\square$

**Theorem 7.3 (boundary concentration of equal-volume shells).** For $d \ge 1$,
$N \ge 2$ and $R \ge 0$, the outermost shell of the equal-volume peeling of
$B(0,R) \subseteq \mathbb{R}^d$ has thickness
$$R - r_1 \;=\; R - R\left(1 - \tfrac1N\right)^{1/d} \;\le\; \frac{R}{d\,(N-1)} .$$

*Proof sketch.* Factor $R$ out and apply Lemma 7.2. $\square$

**Interpretation.** The outermost shell carries a full $1/N$ of the volume,
yet occupies a radial band of width $O(R/(dN))$. The discrepancy factor is
exactly the dimension. Numerically: for $d=10$, $N=2$, $R=1$ the true
thickness is $1 - 2^{-1/10} \approx 0.0670$ against the bound $0.1$; for
$d = 100$, $N=2$ it is $\approx 0.0069$ against the bound $0.01$. The bound is
within roughly $30\%$ of the truth in these ranges and has the correct $1/d$
decay, which is exactly what the factorisation in Lemma 7.1 is designed to
capture.

This is the quantitative reason why equal-volume ball peelings behave so
differently from the flat arithmetic profile they realise: the profile is
uniform in volume but the geometry collapses onto the boundary sphere. It is
the same phenomenon as the classical concentration of the measure of a
high-dimensional ball near its surface, here derived from a peeling identity.

---

## 8. Universality: arbitrary star-shaped bodies

The ball is the most symmetric body available, so one might reasonably suspect
that the extremality of its shell peeling is an artefact of that symmetry.
This section shows it is not: the construction and its rigidity go through
verbatim for *any* star-shaped body, with the same universal radial profile.

### 8.1 Setup

**Definition 8.1 (star-shaped).** A set $K \subseteq \mathbb{R}^d$ is
*star-shaped about the origin* if $x \in K$ and $0 \le t \le 1$ imply
$tx \in K$.

No convexity, smoothness, boundedness of shape, or symmetry is assumed. We
write $\mathrm{vol}(K)$ for Lebesgue measure and assume throughout that $K$ is
measurable with $\mathrm{vol}(K) < \infty$.

**Lemma 8.2 (scaling for arbitrary bodies).** For $c \ge 0$ and measurable
$K \subseteq \mathbb{R}^d$, $\mathrm{vol}(cK) = c^d\,\mathrm{vol}(K)$; and if
$\mathrm{vol}(K) < \infty$ then $\mathrm{vol}(cK) < \infty$.

*Proof sketch.* This is the scaling law of Haar (Lebesgue) measure on
$\mathbb{R}^d$ under the dilation $x \mapsto cx$, whose Jacobian determinant
is $c^d$. $\square$

**Lemma 8.3 (nesting of dilates).** If $K$ is star-shaped about the origin and
$0 \le a \le b$, then $aK \subseteq bK$.

*Proof sketch.* If $b = 0$ then $a = 0$ and both sides coincide. If $b > 0$,
take a point $ay \in aK$ with $y \in K$. Since $0 \le a/b \le 1$,
star-shapedness gives $(a/b)y \in K$, and $ay = b\bigl((a/b)y\bigr) \in bK$.
Hence $aK \subseteq bK$. $\square$

**Definition 8.4 (universal dilation factors and layers).** For $d, N \ge 1$
and $k \in \mathbb{N}$ set
$$c_k \;=\; \left(\max\left(0,\, 1 - \tfrac{k}{N}\right)\right)^{1/d},
\qquad L_k \;=\; c_k K \setminus c_{k+1} K .$$
Then $c_0 = 1$, $c_N = 0$, and $k \mapsto c_k$ is antitone and nonnegative;
crucially, **$c_k$ depends only on $d$, $N$, $k$ and not at all on $K$.**

### 8.2 The universal theorems

**Theorem 8.5 (equal measures).** For $d, N \ge 1$, measurable $K$ with
$\mathrm{vol}(K) < \infty$ and $k \le N$,
$$\mathrm{vol}(c_k K) \;=\; \mathrm{vol}(K)\left(1 - \tfrac{k}{N}\right),$$
so the associated peeling profile is exactly affine and every layer content
equals $\mathrm{vol}(K)/N$. If moreover $K$ is star-shaped about the origin,
then for $k < N$ the set-theoretic layer satisfies
$$\mathrm{vol}(L_k) \;=\; \frac{\mathrm{vol}(K)}{N}.$$

*Proof sketch.* The first display is Lemma 8.2 with $c = c_k$, since
$c_k^d = 1 - k/N$ for $k \le N$. For the second, star-shapedness gives the
nesting $c_{k+1}K \subseteq c_kK$ (Lemma 8.3), and both dilates have finite
measure (Lemma 8.2), so the measure of the difference is the difference of the
measures, which is $\mathrm{vol}(K)\bigl((1-\tfrac kN) - (1-\tfrac{k+1}{N})\bigr)
= \mathrm{vol}(K)/N$. (When $c_{k+1} = 0$ and $K \ne \emptyset$ the dilate
degenerates to $\{0\}$, which is still measurable, of measure zero.) $\square$

**Theorem 8.6 (universal equivariance).** Let $e$ be a linear isometry of
$\mathbb{R}^d$ with $e(K) = K$. Then $e(L_k) = L_k$ for every $k$.

*Proof sketch.* Linearity gives $e(cK) = c\,e(K) = cK$ for every scalar
$c \ge 0$; injectivity of $e$ lets it commute with set difference. $\square$

Thus the *entire* linear symmetry group of $K$ — the orthogonal group when $K$
is a ball, the dihedral group of order $8$ when $K$ is a square in the plane,
the trivial group for a generic body — acts on the decomposition, preserving
each layer setwise.

**Theorem 8.7 (universal rigidity).** Let $d, N \ge 1$ and let $K$ be
measurable with $0 < \mathrm{vol}(K) < \infty$. Let
$1 = \lambda_0 \ge \lambda_1 \ge \cdots \ge \lambda_N = 0$ be nonnegative
dilation factors such that
$$\mathrm{vol}(\lambda_k K) - \mathrm{vol}(\lambda_{k+1} K) \;\le\;
\frac{\mathrm{vol}(K)}{N} \qquad \text{for all } k < N .$$
Then $\lambda_k = c_k = (1-k/N)^{1/d}$ for every $k \le N$.

*Proof sketch.* The numbers $s_k = \mathrm{vol}(\lambda_k K) =
\lambda_k^d\,\mathrm{vol}(K)$ form a peeling profile with $s_0 =
\mathrm{vol}(K)$, $s_N = 0$, hence budget $\mathrm{vol}(K)$ and rate
$\mathrm{vol}(K)/N$. The hypothesis is clause (1) of Theorem 3.1, so clause (3)
yields $\lambda_k^d\,\mathrm{vol}(K) = \mathrm{vol}(K)(1-k/N)$. Cancelling the
positive factor $\mathrm{vol}(K)$ gives $\lambda_k^d = c_k^d$, and since
$t \mapsto t^d$ is strictly increasing on $[0,\infty)$ (as $d \ge 1$), the
nonnegative $d$-th roots agree. $\square$

**Theorem 8.8 (the matching family, final form).** Let $d, N \ge 1$ and let
$K \subseteq \mathbb{R}^d$ be measurable, star-shaped about the origin, of
finite volume. Then:
1. every layer $L_k$, $k<N$, has volume exactly equal to the peeling rate
   $\mathrm{vol}(K)/N$;
2. every linear isometry preserving $K$ preserves each $L_k$;
3. the peeling profile is exactly affine, $s_k = s_0 - k\,\mathrm{vol}(K)/N$
   for $k \le N$, so the stopping-time bound of Theorem 2.4 is saturated at
   every single step.

Consequently the extremisers of the peeling upper bound realised in Euclidean
geometry are parameterised by pairs $(K, G)$, where $K$ is a star-shaped body
and $G$ is any group of linear symmetries of $K$: the dimension $d$ fixes the
radial profile $(1-k/N)^{1/d}$, and the body is otherwise free.

**Example 8.9 (the square, cross-checking Example 6.8).** Take $d = 2$,
$K = [-1,1]^2$ with $\mathrm{vol}(K) = 4$, and $N = 4$. The dilation factors
are $1, \sqrt3/2, \sqrt2/2, 1/2, 0$ — *identical* to the disc case of
Example 6.8, as the theory predicts, since the factors depend only on $d$ and
$N$. The four layers are square annuli of areas
$4 - 3 = 1$, $3 - 2 = 1$, $2 - 1 = 1$, $1 - 0 = 1$. The symmetry group acting
on the decomposition is the dihedral group of order $8$, not $O(2)$; the
extremality is unaffected.

**Remark 8.10.** The independence of the factors from $K$ is the sharpest form
of the message. The stopping-time bound is a statement about numbers; its
geometric extremisers therefore cannot see anything about a body except its
volume and the dimension. The dilation profile is the unique radial law
compatible with the scaling $\mathrm{vol}(cK) = c^d \mathrm{vol}(K)$ and an
equipartition of volume, and that is why it is universal.

---

## 9. Algorithms and applications

### 9.1 Locating a good stopping time

Theorem 2.4 is constructive: scanning $k = 0, 1, \dots, N-1$ and returning the
first index with $g_k \le \rho_N$ terminates and costs $O(N)$ evaluations of
the profile. Corollary 2.10 shows that a *random* index succeeds with
probability at least $1 - 1/c$ against the relaxed threshold $c\rho_N$, so a
sampling strategy with $O(1)$ evaluations suffices when a constant-factor loss
is tolerable.

A cheaper deterministic shortcut exists for a common special case.

**Theorem 9.1 (monotone peelings need no search).** Suppose the layer contents
are nonincreasing, $g_j \le g_i$ whenever $i \le j$. Then
$$g_{N-1} \;\le\; \rho_N \;\le\; g_0 ,$$
so the *last* step of the window is always an admissible stopping time and the
*first* step is never one (strictly, unless all gaps coincide).

*Proof sketch.* The minimum of $N$ numbers is at most their average and the
maximum is at least their average; monotonicity identifies the minimum as
$g_{N-1}$ and the maximum as $g_0$. $\square$

The practical upshot: the existential search in Theorem 2.4 is only needed for
genuinely oscillating peelings. Many natural peeling processes — those that
remove the heaviest layer available at each step — are monotone, and for them
the answer is $k = N-1$ with no search at all.

### 9.2 Constructing an equal-volume decomposition

Given a dimension $d$, a number of parts $N$ and a star-shaped body $K$
described by a radial function, Theorem 8.5 provides a closed-form
equipartition:
compute $c_k = (1-k/N)^{1/d}$ for $k=0,\dots,N$ and take
$L_k = c_kK \setminus c_{k+1}K$. The cost is $N$ evaluations of a real power;
no integration, no root-finding, no dependence on the shape of $K$.

This is a genuinely useful primitive: volume-balanced radial partitioning of a
region is a standard requirement in adaptive mesh refinement, in importance
sampling with stratified radial strata, in level-of-detail schemes, and in
building balanced nested search structures over spatial data. The theorem says
the optimal strata are always the same, in closed form, whatever the region.

### 9.3 Certifying extremality and measuring the defect

Two computable certificates arise. The *sup-norm defect*
$\max_{k \le N} |s_k - \ell_k|$ is bounded by $\varepsilon A_N$ whenever all
layers obey $g_k \le (1+\varepsilon)\rho_N$ (Theorem 4.1), so measuring the
maximum multiplicative overshoot certifies proximity to the affine profile.
The *energy defect* $E_N - A_N^2/N = \sum_k (g_k - \rho_N)^2$ (Theorem 5.1) is
exactly $N$ times the variance of the layer contents, is zero if and only if
the peeling is extremal, and is a smooth objective — hence usable as a loss
function if one wishes to *optimise* a family of peelings towards
equipartition.

### 9.4 High-dimensional design guidance

Theorem 7.3 is a warning label. If one designs an algorithm that peels a
high-dimensional ball into equal-volume shells and then assumes those shells
are geometrically thick — for example to argue that a discretisation of scale
$\delta$ resolves each shell — the assumption fails badly: the shells have
thickness $O(R/(dN))$. Conversely, if one wants *geometrically* uniform
shells, one must accept wildly unequal volumes, since a shell of thickness
$R/N$ at radius $\approx R$ carries about a $d/N$ fraction of the volume.
Volume uniformity and geometric uniformity are incompatible in high dimensions,
and Theorem 7.3 quantifies the trade-off exactly.

---

## 10. Discussion and future directions

The picture that emerges is a chain of equivalences relating four apparently
unrelated notions attached to a peeling window:

$$\underbrace{g_k \le \rho_N \ \forall k}_{\text{inequality}}
\iff \underbrace{g_k = \rho_N \ \forall k}_{\text{equipartition}}
\iff \underbrace{\text{transitive symmetry of } \gamma}_{\text{group theory}}
\iff \underbrace{E_N = A_N^2/N}_{\text{variational}} ,$$

with the geometric realisation of the common condition being exactly the
family of dilation peelings $c_kK$, $c_k = (1-k/N)^{1/d}$, of star-shaped
bodies, together with their symmetry groups. Stability (Theorem 4.1) makes the
first equivalence quantitative, and boundary concentration (Theorem 7.3)
explains why the geometric realisations look nothing like the flat profiles
they realise.

We close with three directions that the present results make immediately
attackable.

### Conjecture A — Rigidity survives the loss of nesting by dilation

*Statement.* Let $K \subseteq \mathbb{R}^d$ be a convex body containing the
origin and let $K = K_0 \supseteq K_1 \supseteq \cdots \supseteq K_N = \{0\}$
be **arbitrary** convex bodies (not assumed to be dilates of $K$) with
$\mathrm{vol}(K_k) - \mathrm{vol}(K_{k+1}) \le \mathrm{vol}(K)/N$ for every
$k$. Then $\mathrm{vol}(K_k) = (1 - k/N)\mathrm{vol}(K)$ for all $k$, and if
in addition each $K_k$ is homothetic to $K$ the homothety ratios are forced to
be $(1-k/N)^{1/d}$.

*Why it should be tractable.* The rigidity theorem (Theorem 3.1) already
forces the **volume** profile with no geometric input whatsoever; the only
remaining work is to recover the *shape* from the volume, which is where
convexity and Brunn–Minkowski theory should enter. The volume half is already
established here, since Theorem 8.7 derives it for dilation families.

### Conjecture B — The concentration order $1/d$ is exact

*Statement.* For $d \ge 1$ and $N \ge 2$, the thickness of the outermost
equal-volume shell of $B(0,R) \subseteq \mathbb{R}^d$ satisfies
$$\frac{R}{d(N-1)}\left(1 - \frac1N\right) \;\le\;
R - R\left(1-\tfrac1N\right)^{1/d} \;\le\; \frac{R}{d(N-1)},$$
so the upper bound of Theorem 7.3 is tight up to the factor $1 - 1/N$, and the
whole shell decomposition converges, after rescaling by $d$, to the exponential
radial profile $R(1 - e^{-t})$.

*Why it should be tractable.* The factorisation
$1 - s^d = (1-s)\sum_{i<d}s^i$ used in Lemma 7.1 is two-sided: bounding
$\sum_{i<d}s^i$ *above* by $d$ instead of below by $d\,s^{d-1}$ yields the
matching lower bound. The limit statement then follows from the definition of
the exponential once both bounds are in place.

### Conjecture C — Symmetry is necessary, not merely sufficient, in general

*Statement.* Let $s$ be a peeling profile with $A_N > 0$. Then $s$ saturates
the stopping-time bound on the window of length $N$ if and only if there is a
group acting pretransitively on the $N$ steps and leaving the layer contents
invariant; moreover the set of such groups is a full conjugation-closed family
of transitive subgroups of the symmetric group of the window.

*Status.* Theorem 3.5 already establishes the equivalence with invariance
under the full symmetric group, and Corollary 3.4 with invariance under a
single $N$-cycle. What remains is the classification statement: to determine
exactly which transitive subgroups arise as symmetry groups of the layer
structure of a given extremal peeling, and whether every transitive subgroup
is realised by some geometric extremiser $(K, G)$.

### Further questions

- **Weighted and continuous peelings.** Replacing the discrete window by a
  measure on $[0,T]$ and $g_k$ by a density should give a continuous rigidity
  theorem in which the extremisers are the constant-density peelings and the
  energy identity becomes the variance decomposition of a random variable.
- **Non-star-shaped bodies.** For $K$ not star-shaped the dilates are no longer
  nested and the layers $c_kK \setminus c_{k+1}K$ need not partition $K$;
  nonetheless the *volume* identity $\mathrm{vol}(c_kK) = c_k^d\mathrm{vol}(K)$
  survives. What is the correct replacement for the layer decomposition?
- **Anisotropic scalings.** Replacing scalar dilation $c \mapsto cK$ by a
  one-parameter group of linear maps with determinant $\det = 1-k/N$ produces
  the same volume profile but a different, generally non-nested, geometry. The
  extremal set is then presumably parameterised by paths in $SL_d(\mathbb{R})$,
  and the rigidity question becomes one about determinant flows.

---

## Appendix: worked numerical checks

**A.1 The abstract extremiser.** For $N = 4$ and budget $A = 1$, the extremal
profile is $s = (1, 3/4, 1/2, 1/4, 0)$, all gaps $1/4$, energy
$4\cdot(1/4)^2 = 1/4 = A^2/N$. The front-loaded profile $s = (1,0,0,0,0)$ has
gaps $(1,0,0,0)$, minimum gap $0 < 1/4$, energy $1$, and excess energy
$3/4$, which indeed equals
$(3/4)^2 + 3\cdot(1/4)^2 = 0.5625 + 0.1875 = 0.75$, confirming the energy
identity of Theorem 5.1. This example also shows the pigeonhole bound is far
from an equality in general, and that the rigidity theorem genuinely needs the
*uniform* smallness hypothesis.

**A.2 Ball shells in the plane.** $d = 2$, $R = 1$, $N = 4$: radii
$1, 0.8660, 0.7071, 0.5, 0$; annulus areas
$\pi(1 - 0.75) = \pi(0.75-0.5) = \pi(0.5-0.25) = \pi(0.25-0) = \pi/4$.

**A.3 The square.** $d = 2$, $K = [-1,1]^2$, $\mathrm{vol}(K) = 4$, $N = 4$:
factors $1, 0.8660, 0.7071, 0.5, 0$; layer areas $1,1,1,1$. Identical factors
to A.2.

**A.4 Concentration.** $d = 10$, $N = 2$, $R = 1$: true thickness
$1 - 2^{-1/10} \approx 0.06697$, bound $1/(d(N-1)) = 0.1$. $d = 100$, $N = 2$:
thickness $\approx 0.00690$, bound $0.01$. Ratio of truth to bound $\approx
0.67$ and $\approx 0.69$ respectively — consistent with the conjectured sharp
factor $1 - 1/N = 0.5$ lower bound and the exact asymptotic
$1 - (1-1/N)^{1/d} \sim \log\!\bigl(N/(N-1)\bigr)/d$.
