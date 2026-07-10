# Quantitative Invariants of the Zero-Dimensional Persistent Homology of the Prime Point Cloud

## Abstract

We study the zero-dimensional persistent homology of the *prime point cloud*,
the configuration that places the $n$-th prime $p_n$ on the real line. Using the
Vietoris–Rips filtration, we show that the entire barcode of this cloud is
determined by the sequence of prime gaps $g_i = p_{i+1} - p_i$, and we compute two
of its principal quantitative invariants in closed form. First, the *total
persistence* — the sum of the lengths of the finite $H_0$ bars — telescopes, for
any strictly increasing point cloud, to the difference between the last and first
points; specialised to the primes it becomes the exact identity
$\mathrm{TP}(n) = p_n - 2$, equivalently the sum of the first $n$ prime gaps.
Second, the zeroth *Betti number* at scale $\varepsilon$ is the descending
staircase $b_0(\varepsilon, n) = 1 + \#\{\, i < n : g_i > \varepsilon \,\}$, so
that every downward step of the Betti curve is triggered by exactly one prime gap
crossing the threshold. As a corollary, the cloud is connected ($b_0 = 1$)
precisely when $\varepsilon$ dominates every internal gap, identifying the global
merge scale with the maximal gap. The proof of the staircase formula proceeds
through a single-linkage *component-root* map, establishing that the count is a
genuine topological invariant rather than a definitional restatement. We
discuss how these exact formulas transport classical questions about prime gaps —
the Prime Number Theorem, the Hardy–Littlewood conjectures, and the twin prime
conjecture — into statements about topological invariants, and we outline the
higher-dimensional and distributional continuations.

**Keywords.** persistent homology, prime gaps, Vietoris–Rips filtration, total
persistence, Betti number, single-linkage clustering, barcode, merge tree.

---

## 1. Introduction

Topological data analysis studies the "shape" of finite metric data through
*persistent homology*, which records how homological features appear and disappear
as a scale parameter increases. Applied to a finite point cloud, the
zero-dimensional part of this theory tracks connected components; its output is a
*barcode*, a multiset of intervals whose lengths measure how long clusters persist
before merging.

We apply this machinery to one of the oldest objects in mathematics: the sequence
of prime numbers, viewed as a point cloud on the real line. Concretely, define the
point map
$$
P : \mathbb{N} \to \mathbb{R}, \qquad P(n) = p_{n},
$$
where $p_n$ denotes the $n$-th prime (with the convention $p_0 = 2$). The
resulting configuration $\{P(0), P(1), \dots\} = \{2, 3, 5, 7, 11, \dots\}$ is the
**prime point cloud**. Our goal is to describe its zero-dimensional persistent
homology exactly.

The central phenomenon is that all of this topology is governed by the prime gaps
$$
g_i \;=\; p_{i+1} - p_i \;=\; P(i+1) - P(i).
$$
Because the points lie on a line and are strictly increasing, the Vietoris–Rips
filtration collapses to an elementary combinatorial object: two consecutive points
merge exactly at the scale equal to their gap. Consequently the barcode's finite
bars are precisely the gaps, and every scalar summary of the barcode is a summary
of the gap sequence. We make this precise for the two most important scalar
invariants — total persistence and the Betti number — and obtain closed forms.

**Contributions.** For a general strictly increasing cloud $p : \mathbb{N} \to
\mathbb{R}$ we prove:

1. **(Telescoping total persistence.)** The total persistence of the first $n$
   finite bars equals $p(n) - p(0)$ (Theorem 3.2).
2. **(Betti staircase.)** The number of $\varepsilon$-connected components among
   the first $n+1$ points equals $1 + \#\{\, i < n : g_i > \varepsilon \,\}$
   (Theorem 4.7), where $g_i = p(i+1) - p(i)$.
3. **(Global merge criterion.)** $b_0(\varepsilon, n) = 1$ if and only if
   $\varepsilon \ge g_i$ for all $i < n$ (Theorem 4.8).

Specialising to the primes yields the arithmetic identities

* $\mathrm{TP}(n) = p_n - 2$ (Corollary 3.4), equivalently
  $\mathrm{TP}(n) = \sum_{i<n} g_i$ (Corollary 3.5);
* $b_0(\varepsilon, n) = 1 + \#\{\, i < n : g_i > \varepsilon \,\}$
  (Corollary 4.9).

The staircase formula is proved through a single-linkage component-root map
(Section 4), which certifies that $b_0$ counts genuine connected components.

---

## 2. Preliminaries

### 2.1 Point clouds on the line and the Vietoris–Rips filtration

Let $p : \mathbb{N} \to \mathbb{R}$ be **strictly increasing**, so that
$p(0) < p(1) < p(2) < \cdots$. For a finite index range $\{0, 1, \dots, n\}$ the
associated point cloud is $\{p(0), \dots, p(n)\} \subset \mathbb{R}$ with the
Euclidean metric $d(x, y) = |x - y|$.

For a scale $\varepsilon \ge 0$, the **Vietoris–Rips complex** $\mathrm{VR}_\varepsilon$
has the points as vertices and connects two of them by an edge whenever their
distance is at most $\varepsilon$. As $\varepsilon$ increases the complexes are
nested, $\mathrm{VR}_{\varepsilon} \subseteq \mathrm{VR}_{\varepsilon'}$ for
$\varepsilon \le \varepsilon'$, giving a *filtration*. Its zeroth homology
$H_0(\mathrm{VR}_\varepsilon)$ is the free module on the set of connected
components; the induced maps make $\varepsilon \mapsto H_0(\mathrm{VR}_\varepsilon)$
a **persistence module**.

### 2.2 Gaps and the collapse to one dimension

Define the **gap sequence** $g_i = p(i+1) - p(i) > 0$. On the line the graph
structure of $\mathrm{VR}_\varepsilon$ restricted to $\{p(0), \dots, p(n)\}$ is a
disjoint union of paths: the edge between consecutive points $p(i)$ and $p(i+1)$ is
present exactly when $g_i \le \varepsilon$. Two points $p(a)$ and $p(b)$ with
$a \le b$ are in the same component if and only if *every* intervening gap is small,
$$
p(a) \sim_\varepsilon p(b) \iff g_i \le \varepsilon \ \text{ for all } a \le i < b .
$$
This equivalence is the technical engine behind everything that follows.

### 2.3 The barcode

Starting from $\varepsilon = 0$, all $n+1$ points are distinct components, so
$n+1$ bars are born at scale $0$. As $\varepsilon$ increases past a gap $g_i$, the
edge $(p(i), p(i+1))$ appears and merges two components into one, killing exactly
one bar at scale $g_i$. Hence the $H_0$ barcode over $\{0, \dots, n\}$ consists of

* $n$ **finite bars** $[0, g_i)$, one for each gap $g_i$, $i < n$; and
* one **essential bar** $[0, \infty)$ for the surviving component.

The **death scale** of the finite bar associated with index $i$ is exactly the gap
$g_i$. We record the specialisation to the primes as a naming convention: for the
prime cloud the $i$-th death scale equals the $i$-th prime gap.

---

## 3. Total persistence

### 3.1 Definition

**Definition 3.1 (Total persistence).** The **total persistence** of the first
$n$ finite $H_0$ bars of a cloud $p$ is the sum of their lengths,
$$
\mathrm{TP}(p, n) \;=\; \sum_{i=0}^{n-1} \bigl(p(i+1) - p(i)\bigr)
\;=\; \sum_{i=0}^{n-1} g_i .
$$

### 3.2 The telescoping identity

**Theorem 3.2 (Telescoping total persistence).** For every strictly increasing
$p : \mathbb{N} \to \mathbb{R}$ and every $n \in \mathbb{N}$,
$$
\mathrm{TP}(p, n) \;=\; p(n) - p(0).
$$

*Proof.* The sum $\sum_{i=0}^{n-1} \bigl(p(i+1) - p(i)\bigr)$ telescopes: writing
out the terms, each $+p(i+1)$ cancels the $-p(i+1)$ of the next summand, leaving
only $p(n) - p(0)$. $\qquad\blacksquare$

The identity holds with no hypotheses beyond well-definedness; strict monotonicity
merely guarantees that the summands are the genuine (positive) bar lengths.

### 3.3 The prime specialisation

Recall the prime cloud $P(n) = p_n$ with $P(0) = p_0 = 2$.

**Corollary 3.3 (Base point).** $P(0) = 2$.

**Corollary 3.4 (Total persistence of the prime barcode).** For every $n$,
$$
\mathrm{TP}(P, n) \;=\; p_n - 2 .
$$

*Proof.* Apply Theorem 3.2 to $P$ and use $P(0) = 2$. $\qquad\blacksquare$

**Corollary 3.5 (Gap-sum form).** Equivalently,
$$
\mathrm{TP}(P, n) \;=\; \sum_{i=0}^{n-1} g_i ,
$$
the sum of the first $n$ prime gaps.

*Proof.* Immediate from Definition 3.1, since each death scale equals the
corresponding prime gap. $\qquad\blacksquare$

### 3.4 Interpretation

Corollary 3.4 states that a quantity defined purely through the persistence module
— the aggregate length of all finite $H_0$ bars — coincides *exactly* with the
elementary arithmetic quantity $p_n - 2$. In particular the growth rate of total
persistence is dictated by the Prime Number Theorem: since $p_n \sim n \log n$,
$$
\mathrm{TP}(P, n) \sim n \log n \qquad (n \to \infty),
$$
so aggregate topological persistence of the prime cloud grows like $n \log n$.
This is one of the future directions made rigorous by the exact identity: the
asymptotics of a topological invariant reduce to the classical expansion of $p_n$.

---

## 4. The Betti number as a component count

We now fix a scale $\varepsilon \ge 0$ and count connected components exactly. The
subtlety is that connectivity of far-apart points is transitive through chains of
small gaps, so a careful *single-linkage* argument is required.

### 4.1 Runs and roots

**Definition 4.1 (Left run).** For indices $k \le i$ we say $k$ **left-runs to**
$i$ at scale $\varepsilon$, written $\mathrm{leftRun}(p, \varepsilon, i, k)$, if
$$
k \le i \quad\text{and}\quad p(j+1) - p(j) \le \varepsilon
\ \text{ for all } k \le j < i .
$$
Equivalently, $k$ reaches $i$ through a chain of consecutive edges each of length
$\le \varepsilon$.

**Definition 4.2 (Component root).** The **root** of $i$ at scale $\varepsilon$ is
the least index that left-runs to $i$,
$$
\mathrm{root}(p, \varepsilon, i) \;=\; \min \{\, k : \mathrm{leftRun}(p, \varepsilon, i, k) \,\}.
$$
It is the single-linkage representative of the component of $p(i)$: the leftmost
point connected to $p(i)$ by a chain of $\le \varepsilon$ edges.

**Lemma 4.3 (Well-definedness).** Every $i$ left-runs to itself, so the defining
set is nonempty and $\mathrm{root}(p, \varepsilon, i) \le i$.

*Proof.* The condition $\mathrm{leftRun}(p, \varepsilon, i, i)$ is vacuous (there
are no indices $j$ with $i \le j < i$), hence true; therefore the infimum is over a
nonempty set of naturals and is at most $i$. $\qquad\blacksquare$

**Lemma 4.4 (The root is a run).** $\mathrm{leftRun}\bigl(p, \varepsilon, i,
\mathrm{root}(p, \varepsilon, i)\bigr)$ holds.

*Proof.* The least element of a nonempty set of naturals belongs to it.
$\qquad\blacksquare$

### 4.2 Starts

**Definition 4.5 (Component start).** An index $r$ is a **start** at scale
$\varepsilon$ if
$$
r = 0 \quad\text{or}\quad p(r) - p(r-1) > \varepsilon,
$$
i.e. it is the first point or the gap immediately to its left exceeds
$\varepsilon$.

**Lemma 4.6 (Roots are exactly starts).**
For all $i$, $\mathrm{root}(p, \varepsilon, i)$ is a start; and every start $r$ is
its own root, $\mathrm{root}(p, \varepsilon, r) = r$.

*Proof.* Let $r = \mathrm{root}(p, \varepsilon, i)$. If $r = 0$ it is a start.
Otherwise, by minimality $r - 1$ does not left-run to $i$; since $r$ does, the only
possible obstruction is the single edge $(p(r-1), p(r))$, whence
$p(r) - p(r-1) > \varepsilon$ and $r$ is a start.

Conversely let $r$ be a start. By Lemma 4.3, $\mathrm{root}(p, \varepsilon, r) \le
r$. If it were strictly smaller, some $k < r$ would left-run to $r$, forcing in
particular $p(r) - p(r-1) \le \varepsilon$ and $r \ne 0$ — contradicting that $r$
is a start. Hence $\mathrm{root}(p, \varepsilon, r) = r$. $\qquad\blacksquare$

### 4.3 The staircase formula

**Definition 4.7 (Betti number).** The **zeroth Betti number** at scale
$\varepsilon$ over the first $n+1$ points is the number of distinct roots,
$$
b_0(p, \varepsilon, n) \;=\; \bigl|\, \{\, \mathrm{root}(p, \varepsilon, i) : 0 \le i \le n \,\} \,\bigr| .
$$
This equals the number of $\varepsilon$-connected components, since two indices
lie in the same component iff they share a root.

**Theorem 4.7 (Betti staircase).** For every strictly increasing $p$, every
$\varepsilon \ge 0$, and every $n$,
$$
b_0(p, \varepsilon, n) \;=\; 1 + \bigl|\{\, i : 0 \le i < n,\ p(i+1) - p(i) > \varepsilon \,\}\bigr| .
$$

*Proof.* By Lemma 4.6 the image of the root map over $\{0, \dots, n\}$ equals the
set of starts in $\{0, \dots, n\}$. The starts are $0$ together with those $r$ with
$1 \le r \le n$ and $p(r) - p(r-1) > \varepsilon$. Re-indexing $r = i+1$ puts the
latter in bijection with $\{ i : 0 \le i < n,\ g_i > \varepsilon \}$. Since $0$ is
not of the form $i+1$, the count is $1 + \#\{ i < n : g_i > \varepsilon \}$.
$\qquad\blacksquare$

Thus $b_0$, as a function of $\varepsilon$, is a right-continuous, non-increasing
step function: it starts at $n+1$ when $\varepsilon = 0$ (assuming all gaps
positive) and decreases by one each time $\varepsilon$ crosses a gap value, until
it reaches $1$.

**Theorem 4.8 (Global merge criterion).** $b_0(p, \varepsilon, n) = 1$ if and only
if $p(i+1) - p(i) \le \varepsilon$ for all $i < n$.

*Proof.* By Theorem 4.7, $b_0 = 1$ iff the set $\{ i < n : g_i > \varepsilon \}$ is
empty, i.e. iff $g_i \le \varepsilon$ for all $i < n$. $\qquad\blacksquare$

Equivalently, the smallest scale at which the whole cloud becomes a single
component — the **global merge scale** — is $\max_{i<n} g_i$.

### 4.4 The prime specialisation

**Corollary 4.9 (Betti number of the prime cloud).** For the prime cloud,
$$
b_0(P, \varepsilon, n) \;=\; 1 + \bigl|\{\, i < n : g_i > \varepsilon \,\}\bigr|,
$$
where $g_i = p_{i+1} - p_i$ is the $i$-th prime gap. In particular the prime cloud
is $\varepsilon$-connected on its first $n+1$ points iff $\varepsilon$ is at least
the maximal gap $\max_{i<n} g_i$.

*Proof.* Specialise Theorems 4.7 and 4.8 to $p = P$, using that the $i$-th death
scale is the $i$-th prime gap. $\qquad\blacksquare$

---

## 5. Algorithms

The formulas above are directly computable. We record two algorithms; both run in
time linear in $n$ once the primes are available.

### 5.1 Barcode and total persistence

**Algorithm (Prime barcode).** Given $n$, generate the primes
$p_0, \dots, p_n$, form the gaps $g_i = p_{i+1} - p_i$ for $i < n$, and output the
multiset of finite bars $\{[0, g_i)\}$ together with the essential bar
$[0, \infty)$. The total persistence is the running sum of the $g_i$, which equals
$p_n - 2$ by Corollary 3.4 — providing a self-check.

Complexity: $O(n)$ arithmetic operations after prime generation; the total
persistence needs only the endpoints $p_n$ and $p_0$.

### 5.2 Betti curve

**Algorithm (Betti curve).** Given $n$ and a scale $\varepsilon$, compute
$b_0(\varepsilon, n) = 1 + \#\{ i < n : g_i > \varepsilon \}$ by a single pass over
the gaps. To obtain the whole curve, sort the gap values; the curve is the
descending staircase whose jumps occur at the sorted gap values with multiplicity.

Complexity: $O(n)$ for a single $\varepsilon$; $O(n \log n)$ to produce the full
staircase (dominated by the sort).

---

## 6. Applications and interpretation

**Total persistence and the Prime Number Theorem.** Corollary 3.4 gives
$\mathrm{TP}(P, n) = p_n - 2$, so the growth of aggregate persistence is
*identically* the growth of $p_n$. The Prime Number Theorem, $p_n \sim n \log n$,
therefore yields $\mathrm{TP}(P, n) \sim n \log n$, and finer expansions of $p_n$
(e.g. $p_n = n\log n + n\log\log n - n + o(n)$) translate directly into finer
asymptotics of total persistence.

**Betti curve and gap statistics.** Corollary 4.9 identifies the Betti curve with
the (complementary) cumulative histogram of the prime gaps. Any statistical law for
the gaps becomes a law for the shape of this staircase; conversely the staircase is
a faithful topological encoding of the gap distribution.

**Merge tree and record gaps.** By Theorem 4.8 the global merge scale is the
maximal gap, and more generally the internal node heights of the single-linkage
merge tree are the successive record gaps. Maximal-gap records — a classical object
of computation — are exactly the branch heights of the prime merge tree.

**Bar lengths and the twin prime / Hardy–Littlewood conjectures.** Since each
finite bar has length equal to a prime gap, a bar of length $2$ is a twin-prime
pair. The twin prime conjecture is thus the statement that bars of length $2$
recur in the barcode indefinitely; the Hardy–Littlewood conjectures predict the
asymptotic frequency of each even bar length.

---

## 7. Discussion and future work

The results above turn the qualitative slogan "the barcode of the primes is
governed by their gaps" into exact quantitative identities. Several natural
directions extend them.

1. **Total persistence obeys the Prime Number Theorem.** The normalized total
   persistence satisfies $(p_n - 2)/(n \log n) \to 1$, with the sharper expansion
   $p_n - 2 = n\log n + n\log\log n - n + o(n)$. Because total persistence is
   *identically* $p_n - 2$, this asymptotic reduces entirely to the classical
   expansion of $p_n$.

2. **A universal Betti staircase profile.** Under the rescaling
   $\varepsilon \mapsto \varepsilon / \log p_n$, the normalized step function
   $\varepsilon \mapsto b_0(\varepsilon, n)$ should converge to a deterministic
   limiting curve as $n \to \infty$, whose shape is the complementary distribution
   function of normalized prime gaps.

3. **Bar-length histogram and Hardy–Littlewood.** For each even $g$, the
   asymptotic density among the first $N$ bars of those with death scale exactly
   $g$ should equal the Hardy–Littlewood singular series for gap $g$; the
   bar-length histogram is literally the prime-gap histogram.

4. **Higher-dimensional prime clouds carry loops.** The consecutive-pair embedding
   $p_n \mapsto (p_n, p_{n+1})$ lifts the primes to a curve in the plane whose
   first persistent homology $H_1$ is conjecturally non-trivial, with cycle birth
   and death scales controlled by consecutive triples of gaps. Correlations
   between neighbouring gaps — invisible to the one-dimensional cloud, whose $H_1$
   vanishes — become geometric loops.

5. **The merge tree as a self-similar random-like tree.** The single-linkage merge
   tree of the primes, whose internal heights are the record gaps, should be, after
   normalization, statistically indistinguishable from the merge tree of a Poisson
   process with slowly varying intensity $1/\log x$ — a precise formulation of the
   heuristic that primes behave like random numbers of density $1/\log x$.

The unifying theme is a dictionary: total persistence $\leftrightarrow$ $p_n - 2$;
Betti curve $\leftrightarrow$ gap histogram; global merge scale $\leftrightarrow$
maximal gap; bar lengths $\leftrightarrow$ prime gaps. Through it, the deepest
open questions of analytic number theory become questions about the shape of a
point cloud, and the tools of topological data analysis become instruments for
studying the primes.

---

## 8. Conclusion

The zero-dimensional persistent homology of the prime point cloud is completely
determined by the prime gap sequence. Its total persistence over the first $n$
bars telescopes to $p_n - 2$, equivalently the sum of the first $n$ gaps; its
Betti number at scale $\varepsilon$ is the descending staircase
$1 + \#\{ i < n : g_i > \varepsilon\}$; and its global merge scale is the maximal
gap. These are exact identities, proved for arbitrary strictly increasing clouds
and specialised to the primes, with the Betti formula resting on a genuine
single-linkage component-root argument. They constitute a precise dictionary
between topological invariants and prime-gap arithmetic, and a springboard for
transporting the asymptotic and distributional theory of prime gaps into
topology.
