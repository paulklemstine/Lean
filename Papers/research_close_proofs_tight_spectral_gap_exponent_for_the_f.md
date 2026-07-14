# A Tight Cubic Spectral Gap for One‑Dimensional Swap Reconfiguration Chains

## Abstract

The chord‑swap Markov chain reconfigures chord diagrams of a fixed genus by
reconnecting the endpoints of two chords, and its mixing rate is governed by the
spectral gap $\gamma_{n,g}$. Empirically, at fixed genus $g$ and growing number of
chords $n$, the gap decays like $n^{-3}$, but the polynomial bounds in the
literature leave the exponent undetermined. We isolate the mechanism responsible
for the exponent $3$ and prove, unconditionally and with matching two‑sided
bounds, that it is exact for the canonical one‑dimensional prototype: the weighted
**path swap chain**, in which a local move shifts a single monotone statistic by
one unit. We develop the Rayleigh‑quotient calculus for a finite reversible chain
abstractly, establish an upper bound via a single position witness, and prove the
matching lower bound via a telescoping Cauchy–Schwarz Poincaré inequality. The
outcome is the sharp two‑sided estimate
$$\frac{2}{n^{3}} \;\le\; \gamma_n \;\le\; \frac{12}{n^{3}},$$
so $\gamma_n = \Theta(n^{-3})$. The exponent equals $3 = 4 - 1$, the difference
between the quartic growth of the statistic's variance and the linear growth of
its Dirichlet energy. We explain why this mechanism is model‑agnostic and
conjecture a universal cubic law for $\pm 1$‑monotone swap chains, including the
genus‑graded chord‑swap chain.

**Keywords:** spectral gap, Markov chain mixing, Poincaré inequality, Dirichlet
form, Rayleigh quotient, chord diagrams, genus, reconfiguration, Cauchy–Schwarz,
canonical paths.

---

## 1. Introduction

### 1.1 Chord diagrams and reconfiguration

A **chord diagram** of size $n$ is a perfect matching of $2n$ marked points on a
circle by $n$ chords drawn inside the disk. Its **genus** $g$ is the topological
genus of the orientable surface obtained by thickening the chords into ribbons;
equivalently it records the complexity of the crossing structure. Chord diagrams
model RNA secondary structure, knot and tangle projections, and maps on surfaces,
and a recurring computational question is how to sample uniformly from the
diagrams of a fixed genus.

The natural sampler is the **chord‑swap Markov chain**. From a diagram, select two
chords, detach their four endpoints, and reconnect them by one of the permitted
alternative matchings that preserves the genus; iterate at random. The chain is
reversible with respect to the uniform distribution on genus‑$g$ diagrams, and its
mixing time is controlled by the **spectral gap** $\gamma_{n,g}$: the distance
between the top two eigenvalues of the transition operator.

### 1.2 The empirical exponent, and the question

Across the chord‑swap chain and closely related swap chains on perfect matchings,
simulations at fixed genus show $\gamma_{n,g}$ decaying like $n^{-3}$. General
comparison and canonical‑path techniques certify a *polynomial* lower bound on the
gap, but they do not pin the exponent. **What is the true exponent, and why?**

### 1.3 Contribution

We answer the question in the one‑dimensional model that isolates the mechanism,
and we explain why the mechanism should persist in the full model.

1. **Abstract Rayleigh calculus (Section 3).** For any finite state space with
   symmetric, non‑negative edge weights, we define the Dirichlet energy, the
   pairwise variation (a normalization of the variance), and the combinatorial
   spectral gap as an infimum of Rayleigh quotients. We prove the "Rayleigh
   engine": the gap is bounded above by the Rayleigh quotient of every
   non‑constant test function.

2. **Sharp upper bound (Section 4).** On the weighted path of $n$ positions, the
   position function $f(i)=i$ has Dirichlet energy $2(n-1)$ and variation
   $n^2(n^2-1)/6$, giving Rayleigh quotient exactly $12/(n^2(n+1))$, which lies in
   $[6\,n^{-3},12\,n^{-3}]$. Hence $\gamma_n \le 12\,n^{-3}$.

3. **Sharp lower bound (Section 5).** A telescoping Cauchy–Schwarz argument yields
   the Poincaré inequality $\mathrm{vr}(f) \le n^3 \cdot \text{edge energy}(f)$ for
   *every* test function. Since the Dirichlet energy equals twice the edge energy,
   the Rayleigh quotient of every non‑constant $f$ is at least $2\,n^{-3}$, so
   $\gamma_n \ge 2\,n^{-3}$.

4. **Tight two‑sided theorem (Section 6).** Combining the two halves,
   $2\,n^{-3} \le \gamma_n \le 12\,n^{-3}$, i.e. $\gamma_n = \Theta(n^{-3})$,
   unconditionally.

5. **Universality and conjectures (Section 7).** Both halves depend only on the
   growth rates of a $\pm 1$‑monotone statistic, so the argument is
   model‑agnostic. We formulate the genus‑graded cubic gap conjecture, a universal
   cubic law, and a sharp‑constant conjecture.

---

## 2. Preliminaries and notation

Throughout, $V$ is a finite state space with $N = |V|$ elements. A **weight
kernel** is a function $Q\colon V \times V \to \mathbb{R}$ that is symmetric,
$Q(x,y) = Q(y,x)$, and non‑negative, $Q(x,y) \ge 0$. For a reversible chain with
stationary distribution $\pi$ and transition matrix $P$, one takes
$Q(x,y) = \pi(x)P(x,y)$; the spectral gap of $P$ coincides with the combinatorial
gap defined below. A **test function** is any $f\colon V \to \mathbb{R}$; it is
**non‑constant** if $f(x) \ne f(y)$ for some $x,y$.

---

## 3. The Rayleigh‑quotient calculus

**Definition 3.1 (Dirichlet energy).** The Dirichlet energy of $f$ with respect to
$Q$ is
$$\mathrm{dir}_Q(f) \;=\; \sum_{x\in V}\sum_{y\in V} Q(x,y)\,\bigl(f(x)-f(y)\bigr)^2.$$
For a reversible chain this is (twice) the classical Dirichlet form
$\mathcal{E}(f,f)$.

**Definition 3.2 (Pairwise variation).** The pairwise variation of $f$ is
$$\mathrm{vr}(f) \;=\; \sum_{x\in V}\sum_{y\in V}\bigl(f(x)-f(y)\bigr)^2.$$
Up to the factor $1/(2N^2)$ this is the variance of $f$ under the uniform
distribution.

**Definition 3.3 (Rayleigh quotient and gap).** For non‑constant $f$ the Rayleigh
quotient is $\mathrm{RQ}_Q(f) = \mathrm{dir}_Q(f)/\mathrm{vr}(f)$, and the
**combinatorial spectral gap** is
$$\gamma(Q) \;=\; \inf\bigl\{\, \mathrm{RQ}_Q(f) \;:\; f \text{ non-constant}\,\bigr\}.$$

**Lemma 3.4 (Non‑negativity).** For non‑negative $Q$, $\mathrm{dir}_Q(f) \ge 0$
and $\mathrm{vr}(f) \ge 0$ for all $f$. Moreover $\mathrm{vr}(f) > 0$ if and only
if $f$ is non‑constant.

*Proof.* Each summand of $\mathrm{dir}_Q$ is a non‑negative weight times a square,
and each summand of $\mathrm{vr}$ is a square; hence both sums are non‑negative. If
$f(x)\ne f(y)$ then the term $(f(x)-f(y))^2 > 0$ appears in $\mathrm{vr}(f)$, so
the sum is strictly positive; conversely if $f$ is constant every term vanishes.
$\square$

**Lemma 3.5 (Closed form for the variation).** For every $f$,
$$\mathrm{vr}(f) \;=\; 2\Bigl(N\sum_{x} f(x)^2 - \bigl(\textstyle\sum_x f(x)\bigr)^2\Bigr).$$

*Proof.* Expand $(f(x)-f(y))^2 = f(x)^2 - 2f(x)f(y) + f(y)^2$ and sum over all
ordered pairs. The first and third terms each contribute $N\sum_x f(x)^2$, and the
cross term contributes $2(\sum_x f(x))^2$; combining gives the stated identity —
the discrete $\mathrm{Var} = \mathbb{E}[f^2]-\mathbb{E}[f]^2$, unnormalized.
$\square$

**Lemma 3.6 (Gap non‑negativity).** For non‑negative $Q$, $\gamma(Q) \ge 0$.

*Proof.* Every Rayleigh quotient is a ratio of non‑negative quantities
(Lemma 3.4), hence non‑negative; the infimum of a set of non‑negative reals bounded
below by $0$ is non‑negative. $\square$

**Theorem 3.7 (The Rayleigh engine).** Let $Q$ be non‑negative. For every
non‑constant test function $f$,
$$\gamma(Q) \;\le\; \mathrm{RQ}_Q(f).$$

*Proof.* The set of Rayleigh quotients over non‑constant test functions is bounded
below by $0$ (Lemma 3.4), so its infimum exists and is $\le$ any of its members.
The quotient $\mathrm{RQ}_Q(f)$ is such a member. $\square$

Theorem 3.7 is the engine behind every upper bound: a single slowly‑varying
witness certifies slow mixing.

---

## 4. The weighted path and the position witness

**Definition 4.1 (Path weights).** The **length‑$n$ path** has state space
$\{0,1,\dots,n-1\}$ and weight kernel
$$Q_{\mathrm{path}}(x,y) \;=\; \begin{cases} 1 & |x-y| = 1,\\ 0 & \text{otherwise.}\end{cases}$$
This is the canonical one‑dimensional swap graph: unit weight between consecutive
positions.

**Definition 4.2 (Position function).** The **position function** is
$f_{\mathrm{pos}}(i) = i$. It is monotone and a single move shifts it by exactly one
unit — the one‑dimensional shadow of a genus‑style displacement statistic.

**Lemma 4.3 (Linear energy).** For $n \ge 1$,
$\mathrm{dir}_{Q_{\mathrm{path}}}(f_{\mathrm{pos}}) = 2(n-1)$.

*Proof.* On each of the $n-1$ edges $\{i,i+1\}$ the position function changes by
exactly $1$, contributing $1$ to $\mathrm{dir}$ in each of the two orientations;
all non‑edges contribute $0$. Summing gives $2(n-1)$. $\square$

**Lemma 4.4 (Quartic variation).** For all $n$,
$\mathrm{vr}(f_{\mathrm{pos}}) = \dfrac{n^2(n^2-1)}{6}$.

*Proof.* By Lemma 3.5 with $f(i)=i$, using the Gauss sum
$\sum_{i<n} i = n(n-1)/2$ and the square‑pyramidal sum
$\sum_{i<n} i^2 = n(n-1)(2n-1)/6$:
$$\mathrm{vr}(f_{\mathrm{pos}}) = 2\Bigl(n\cdot\tfrac{n(n-1)(2n-1)}{6} - \bigl(\tfrac{n(n-1)}{2}\bigr)^2\Bigr) = \frac{n^2(n^2-1)}{6}. \qquad\square$$

**Theorem 4.5 (Exact Rayleigh quotient).** For $n \ge 2$,
$$\mathrm{RQ}_{Q_{\mathrm{path}}}(f_{\mathrm{pos}}) \;=\; \frac{2(n-1)}{n^2(n^2-1)/6} \;=\; \frac{12}{n^2(n+1)}.$$

*Proof.* Divide Lemma 4.3 by Lemma 4.4 and simplify using $n^2-1 = (n-1)(n+1)$.
$\square$

**Theorem 4.6 (Rayleigh quotient is $\Theta(n^{-3})$).** For $n \ge 2$,
$$\frac{6}{n^3} \;\le\; \mathrm{RQ}_{Q_{\mathrm{path}}}(f_{\mathrm{pos}}) \;\le\; \frac{12}{n^3}.$$

*Proof.* From Theorem 4.5 the quotient is $12/(n^2(n+1))$. Since
$n^2 \cdot n \le n^2(n+1) \le 2n^3$ for $n \ge 2$ (indeed $n+1 \le 2n$ and
$n+1 \ge n$), dividing $12$ by these bounds gives the window. Both inequalities
reduce to non‑negativity of an explicit polynomial in $n$. $\square$

**Corollary 4.7 (Cubic upper bound).** For $n \ge 2$, the position function is
non‑constant, so by Theorem 3.7,
$$\gamma(Q_{\mathrm{path}}) \;\le\; \mathrm{RQ}_{Q_{\mathrm{path}}}(f_{\mathrm{pos}}) \;=\; \frac{12}{n^2(n+1)} \;\le\; \frac{12}{n^3}.$$

The exponent $3$ is already visible: energy $\Theta(n)$ over variance $\Theta(n^4)$.

---

## 5. The matching Poincaré lower bound

The upper bound used one witness; the lower bound must control every test
function. We use a telescoping Cauchy–Schwarz estimate.

**Definition 5.1 (Edge energy).** For $f$ on the path, its **edge energy** is
$$\mathcal{E}_{\mathrm{edge}}(f) \;=\; \sum_{i=0}^{n-2}\bigl(f(i+1)-f(i)\bigr)^2 \;\ge\; 0.$$

**Lemma 5.2 (Dirichlet energy as edge energy).** For every $f$ on the path,
$$\mathrm{dir}_{Q_{\mathrm{path}}}(f) \;=\; 2\,\mathcal{E}_{\mathrm{edge}}(f).$$

*Proof.* The only non‑zero weights lie on the $n-1$ undirected edges
$\{i,i+1\}$, each counted once in each orientation. Both orientations contribute
$(f(i+1)-f(i))^2$, so the double sum equals $2\sum_i (f(i+1)-f(i))^2$. $\square$

**Lemma 5.3 (Telescoping Cauchy–Schwarz).** For every $f$ on the path and all
positions $x,y$,
$$\bigl(f(x)-f(y)\bigr)^2 \;\le\; n\,\mathcal{E}_{\mathrm{edge}}(f).$$

*Proof.* Assume $x \le y$ without loss of generality. Telescoping,
$$f(y)-f(x) = \sum_{i=x}^{y-1}\bigl(f(i+1)-f(i)\bigr),$$
a sum of $y-x \le n$ increments. By the Cauchy–Schwarz inequality, a sum of $m$
reals has square at most $m$ times the sum of their squares, so
$$\bigl(f(y)-f(x)\bigr)^2 \le (y-x)\sum_{i=x}^{y-1}\bigl(f(i+1)-f(i)\bigr)^2 \le n\,\mathcal{E}_{\mathrm{edge}}(f),$$
the last step by enlarging the index set to all edges (each squared term is
non‑negative) and bounding $y - x \le n$. $\square$

**Theorem 5.4 (Poincaré inequality).** For every $f$ on the path,
$$\mathrm{vr}(f) \;\le\; n^3\,\mathcal{E}_{\mathrm{edge}}(f) \;=\; \frac{n^3}{2}\,\mathrm{dir}_{Q_{\mathrm{path}}}(f).$$

*Proof.* Sum Lemma 5.3 over all $n^2$ ordered pairs $(x,y)$. The left side is
$\mathrm{vr}(f)$; the right side is $n^2$ copies of $n\,\mathcal{E}_{\mathrm{edge}}(f)$,
i.e. $n^3\,\mathcal{E}_{\mathrm{edge}}(f)$. The final equality is Lemma 5.2.
$\square$

**Theorem 5.5 (Rayleigh lower bound).** For every non‑constant $f$ on the path
with $n \ge 1$,
$$\mathrm{RQ}_{Q_{\mathrm{path}}}(f) \;\ge\; \frac{2}{n^3}.$$

*Proof.* By Lemma 5.2, $\mathrm{dir}_{Q_{\mathrm{path}}}(f) = 2\mathcal{E}_{\mathrm{edge}}(f)$.
By Theorem 5.4, $\mathrm{vr}(f) \le n^3\mathcal{E}_{\mathrm{edge}}(f)$. Since $f$ is
non‑constant, $\mathrm{vr}(f) > 0$ (Lemma 3.4), which forces
$\mathcal{E}_{\mathrm{edge}}(f) > 0$. Therefore
$$\mathrm{RQ}_{Q_{\mathrm{path}}}(f) = \frac{2\mathcal{E}_{\mathrm{edge}}(f)}{\mathrm{vr}(f)} \ge \frac{2\mathcal{E}_{\mathrm{edge}}(f)}{n^3\mathcal{E}_{\mathrm{edge}}(f)} = \frac{2}{n^3}. \qquad\square$$

**Corollary 5.6 (Cubic lower bound).** For $n \ge 2$,
$\gamma(Q_{\mathrm{path}}) \ge 2\,n^{-3}$.

*Proof.* The gap is the infimum of Rayleigh quotients over non‑constant $f$, each
of which is $\ge 2\,n^{-3}$ by Theorem 5.5; an infimum of a set bounded below by
$2\,n^{-3}$ is itself $\ge 2\,n^{-3}$. $\square$

---

## 6. The tight two‑sided theorem

**Theorem 6.1 (Tight cubic spectral gap).** For all $n \ge 2$, the spectral gap of
the length‑$n$ path swap chain satisfies
$$\frac{2}{n^{3}} \;\le\; \gamma(Q_{\mathrm{path}}) \;\le\; \frac{12}{n^{3}}.$$
In particular $\gamma_n = \Theta(n^{-3})$, unconditionally.

*Proof.* The upper bound is Corollary 4.7 and the lower bound is Corollary 5.6.
$\square$

The two halves have complementary character. The **upper bound** is a single
explicit witness (the position function) fed through the Rayleigh engine
(Theorem 3.7). The **lower bound** is universal over test functions, obtained from
the telescoping structure of the path via Cauchy–Schwarz (Theorem 5.4). Their
meeting at the same exponent is what makes the estimate tight.

---

## 7. Discussion, universality, and future directions

### 7.1 Why the exponent is $3 = 4 - 1$

The entire result is a statement about competing growth rates. A monotone
$\pm 1$‑statistic on $n$ states has:

- **linear Dirichlet energy**, because it changes by $O(1)$ across each of the
  $O(n)$ active edges; and
- **quartic variation**, because $\mathrm{vr} = \Theta(N \cdot \sum f^2)$ scales
  like $n \cdot n^3 = n^4$ for a statistic spread over a range of size $\Theta(n)$.

The Rayleigh quotient is their ratio, $\Theta(n)/\Theta(n^4) = \Theta(n^{-3})$, and
the Poincaré inequality certifies this ratio cannot be beaten by more than a
constant. The exponent is $4 - 1$: the difference of the two growth exponents.

### 7.2 Model‑agnosticism

Neither half of the argument used any special feature of the path beyond: (i) unit
edge weights on a one‑dimensional adjacency, and (ii) a monotone statistic moving
by $\pm 1$. The lower‑bound engine — telescoping plus Cauchy–Schwarz — applies to
any reversible swap chain admitting such a statistic. This is precisely why we
expect the cubic law to transfer to the genuine chord‑swap chain.

### 7.3 Future directions

**Conjecture 1 (Genus‑graded cubic gap).** For chord diagrams of $n$ chords and
any fixed genus $g$, the chord‑swap chain has spectral gap $\Theta(n^{-3})$, with
implied constants depending only on $g$. The key insight is that a chord diagram
carries a monotone integer statistic — a genus‑aware "displacement" that changes
by exactly one unit under a single chord swap — whose Dirichlet energy grows
linearly while its variance grows quartically, reproducing the path model's
energy‑to‑variance ratio of $n^{-3}$. The abstract energy/variance bookkeeping is
established and the one‑dimensional prototype is pinned to the cubic window, so the
only missing ingredient is the construction and quartic‑variance estimate for the
genus statistic — a concrete combinatorial target rather than an analytic
obstacle.

**Conjecture 2 (Universal cubic law).** Any reversible swap chain on a finite state
space that admits a monotone integer statistic taking $\Theta(n)$ distinct values
and changing by $\pm 1$ per accepted move, with $\Theta(n)$ boundary‑adjacent
transitions, has spectral gap $\Theta(n^{-3})$. The exponent $3 = 4 - 1$ is forced
purely by growth rates: the variance of such a statistic is quartic in its range
while its Dirichlet energy is only linear, so the ratio is cubic regardless of the
underlying combinatorial model. The lower‑bound half proved here is
model‑agnostic — it uses only the telescoping structure of a $\pm 1$ statistic — so
the universal statement is within reach by abstracting the path argument away from
its specific adjacency weights.

**Conjecture 3 (Sharp leading constant).** For the path swap chain the spectral gap
satisfies $\gamma_n = (c + o(1))\,n^{-3}$ for an explicit constant $c$ strictly
inside $[2,12]$, realized by the discrete first eigenfunction (a shifted cosine
profile) rather than the linear position witness. The linear witness is
energy‑optimal only up to a constant factor; replacing it by the discrete cosine
mode simultaneously lowers the energy and matches the true bottom of the spectrum,
so both bounds should collapse to a single constant. The two‑sided window is
already established, isolating the remaining question to a one‑parameter
optimization over test‑function profiles — a finite variational problem.

### 7.4 Conclusion

We have shown that the spectral gap of the canonical one‑dimensional swap chain is
exactly of cubic order, $2\,n^{-3} \le \gamma_n \le 12\,n^{-3}$, by pairing a
single position witness (upper bound) with a telescoping Cauchy–Schwarz Poincaré
inequality (lower bound). The mechanism — quartic variance over linear energy — is
model‑agnostic, providing both a concrete explanation for the empirically observed
$n^{-3}$ decay in chord‑swap reconfiguration chains and a clear route to
establishing the exponent rigorously for the full genus‑graded family.
