# Persistent Homology of the Prime Point Cloud: The Topology of Arithmetic

## Abstract

We develop the zero-dimensional persistent homology of the point cloud formed by
placing the $n$-th prime $p_n$ at position $p_n \in \mathbb{R}$, filtered by the
Vietoris–Rips scale parameter $\varepsilon$. We prove that this construction is a
genuine persistence module whose entire structure is determined by the sequence
of prime gaps $g_n = p_{n+1} - p_n$. Our main results are: (i) the barcode of the
prime point cloud consists of one infinite bar together with finite bars whose
lengths are exactly the prime gaps (the *bar-length identity*); (ii) the zeroth
Betti number at scale $\varepsilon$ over the first $n$ primes is
$b_0(\varepsilon,n) = 1 + \#\{i < n : g_i > \varepsilon\}$ (the *Betti formula*);
(iii) the first $n$ primes form a single connected component precisely at and
above the *global merge scale* $\max_{i<n} g_i$; (iv) the total persistence of the
first $n$ primes telescopes to $p_n - 2$ (the *total-persistence identity*); and
(v) the barcode contains bars of arbitrarily large length (*unboundedness*),
because prime gaps are unbounded. Together these results establish a precise
dictionary between analytic number theory and topological data analysis: the
Prime Number Theorem becomes the growth law of total persistence, and the
Twin Prime and Hardy–Littlewood conjectures become statements about the
multiplicity and frequency of bar lengths. We give algorithms, numerical
demonstrations, and a program of conjectures extending the correspondence.

---

## 1. Introduction

Persistent homology is the central computational tool of topological data
analysis. Given a finite metric space (a *point cloud*), one builds a nested
family of simplicial complexes — a *filtration* — indexed by a scale parameter,
and records the multiscale birth and death of homological features. The output,
a *barcode* or equivalently a *persistence diagram*, is a stable summary of the
cloud's shape across all scales.

The prime numbers furnish a canonical, deterministic, and inexhaustible point
cloud: place $p_n$ at coordinate $p_n$ on the real line. Although this cloud
lives in one dimension — where only connected components (dimension-zero
homology) can be nontrivial — its persistent homology is far from trivial as an
object of arithmetic, because the merging behavior of the filtration is governed
entirely by the prime gaps, one of the most intensively studied sequences in
number theory.

This paper makes the resulting correspondence precise. We treat the
zero-dimensional persistence of the prime cloud as a mathematical object in its
own right, establish exact formulas for its barcode, Betti numbers, merge scale,
and total persistence, and show how classical facts and conjectures about primes
translate into topological statements.

### Contributions

1. A rigorous definition of the prime point cloud's $H_0$ persistence module and
   its barcode via the elder rule (Sections 2–3).
2. The **bar-length identity**: finite bar lengths equal prime gaps (Theorem 1).
3. The **Betti formula**: an exact finite-scale count of components (Theorem 2).
4. The **global merge scale** as the maximal gap (Theorem 3).
5. The **total-persistence identity** $p_n - 2$ via telescoping (Theorem 4).
6. **Unboundedness** of bar lengths from unbounded prime gaps (Theorem 5).
7. A dictionary translating the Prime Number Theorem, the Twin Prime Conjecture,
   and the Hardy–Littlewood conjectures into topological language (Section 6),
   plus algorithms and numerics (Sections 5, 7).

---

## 2. Definitions

Throughout, $p_1 = 2 < p_2 = 3 < p_3 = 5 < \cdots$ denotes the increasing
enumeration of the primes, and
$$
g_n \;:=\; p_{n+1} - p_n \qquad (n \ge 1)
$$
denotes the $n$-th **prime gap**. We have $g_1 = 1$ and $g_n \ge 2$ for all
$n \ge 2$.

**Definition 2.1 (Prime point cloud).** For $n \ge 1$, the *finite prime point
cloud* of order $n$ is the finite metric subspace
$$
P_n \;=\; \{p_1, p_2, \dots, p_n\} \subset \mathbb{R}
$$
with the Euclidean distance $d(x,y) = |x-y|$ inherited from $\mathbb{R}$. The
*prime point cloud* is the increasing union $P = \bigcup_n P_n$.

**Definition 2.2 (Vietoris–Rips filtration).** For a scale $\varepsilon \ge 0$,
the Vietoris–Rips complex $\mathrm{VR}_\varepsilon(P_n)$ has vertex set $P_n$ and
a simplex on a subset $\sigma \subseteq P_n$ whenever $\mathrm{diam}(\sigma) \le
\varepsilon$; equivalently an edge joins $p_i, p_j$ iff $|p_i - p_j| \le
\varepsilon$. For $\varepsilon \le \varepsilon'$ the inclusion
$\mathrm{VR}_\varepsilon(P_n) \hookrightarrow \mathrm{VR}_{\varepsilon'}(P_n)$
makes $\{\mathrm{VR}_\varepsilon(P_n)\}_{\varepsilon \ge 0}$ a filtration.

Because the points lie on a line and are sorted, the relevant fact is elementary:

**Lemma 2.3 (Connectivity on a line).** In $\mathrm{VR}_\varepsilon(P_n)$ the
points $p_i$ and $p_{i+1}$ lie in the same connected component iff every gap
between them is $\le \varepsilon$; equivalently the connected components of
$\mathrm{VR}_\varepsilon(P_n)$ are exactly the maximal runs of consecutive primes
$p_a, p_{a+1}, \dots, p_b$ with $g_a, \dots, g_{b-1} \le \varepsilon$.

*Proof.* Adjacent points are connected by an edge iff their gap is $\le
\varepsilon$. Since the points are linearly ordered, a component is an interval of
indices, and it is maximal exactly when the bounding gaps on either side exceed
$\varepsilon$. Any non-adjacent pair within such a run is connected through the
chain of adjacent edges; conversely no edge can bridge a gap $> \varepsilon$. ∎

**Definition 2.4 (Zeroth persistent homology).** Applying the connected-components
functor $H_0(-;\mathbb{F})$ (over a field $\mathbb{F}$) to the filtration yields
the *zeroth persistence module*
$$
\varepsilon \;\longmapsto\; H_0(\mathrm{VR}_\varepsilon(P_n);\mathbb{F}),
$$
with linear maps induced by inclusion. As all points are present at
$\varepsilon = 0$, every homology class is *born* at $\varepsilon = 0$.

**Definition 2.5 (Elder rule and barcode).** When, as $\varepsilon$ increases,
two components merge, the class of the *younger* component (the one containing the
larger-indexed prime) dies and the *older* survives. The oldest class — the
component containing $p_1 = 2$ — never dies. The multiset of birth–death
intervals so obtained is the **barcode**
$$
\mathcal{B}_n \;=\; \{[0,\infty)\} \;\cup\; \{[0, d_i) : i = 1, \dots, n-1\},
$$
where $d_i$ is the death scale of the $i$-th finite class. The associated
**persistence diagram** is the multiset $\{(0, d_i)\}$ together with the point at
infinity.

---

## 3. The barcode: bar lengths are prime gaps

**Theorem 1 (Bar-length identity).** Order the finite bars of $\mathcal{B}_n$ by
the index of the prime that generates them. The finite bar associated with the
prime $p_{i+1}$ has the form $[0, g_i)$; consequently the multiset of finite bar
lengths of $\mathcal{B}_n$ is exactly
$$
\{ g_1, g_2, \dots, g_{n-1} \},
$$
the multiset of the first $n-1$ prime gaps.

*Proof.* By Lemma 2.3 the components of $\mathrm{VR}_\varepsilon(P_n)$ are the
maximal runs bounded by gaps $> \varepsilon$. Consider the class carried by the
component whose oldest member is $p_{i+1}$; its left boundary gap is $g_i$. For
$\varepsilon < g_i$ this class is distinct from the class to its left, and at
$\varepsilon = g_i$ the boundary edge $\{p_i, p_{i+1}\}$ appears, merging the two
runs. By the elder rule the class rooted at $p_{i+1}$ (younger, since $i+1 > i$)
dies exactly at $\varepsilon = g_i$. Its bar is therefore $[0, g_i)$. Ranging over
$i = 1, \dots, n-1$ enumerates all finite classes, since the only class that never
acquires a left boundary gap is the one rooted at $p_1$, which is the infinite
bar. ∎

The barcode is thus a faithful re-encoding of the gap sequence. Every question
about the *lengths* of bars is a question about prime gaps, and conversely.

---

## 4. Betti numbers, merge scale, total persistence, and unboundedness

### 4.1 The Betti formula

**Theorem 2 (Betti formula).** For every $n \ge 1$ and every $\varepsilon \ge 0$,
$$
b_0(\varepsilon, n) \;:=\; \dim H_0(\mathrm{VR}_\varepsilon(P_n);\mathbb{F})
\;=\; 1 + \#\{\, i : 1 \le i \le n-1,\ g_i > \varepsilon \,\}.
$$

*Proof.* By Lemma 2.3 the number of connected components equals the number of
maximal runs, which is one more than the number of *internal boundaries* — i.e.
gaps $g_i$ with $i < n$ satisfying $g_i > \varepsilon$. Equivalently, start with
$n$ components at $\varepsilon^- = 0$; each of the $n-1$ gaps that satisfies
$g_i \le \varepsilon$ has merged its two endpoints, reducing the count by exactly
one and without cycles (the graph is a subforest of a path). Hence
$b_0 = n - \#\{i < n : g_i \le \varepsilon\} = 1 + \#\{i < n : g_i > \varepsilon\}$.
∎

As a function of $\varepsilon$, $b_0(\cdot, n)$ is a right-continuous,
non-increasing step function — the **Betti curve** — that starts at $n$ (for
$\varepsilon < 1$) and decreases by one at each distinct gap value, ending at $1$.

### 4.2 The global merge scale

**Theorem 3 (Global merge scale).** For $n \ge 2$ let
$M_n := \max_{1 \le i \le n-1} g_i$. Then $b_0(\varepsilon, n) = 1$ iff
$\varepsilon \ge M_n$; that is, the first $n$ primes form a single connected
component exactly at and above the scale $M_n$, and more than one component below
it.

*Proof.* Immediate from Theorem 2: the count $\#\{i < n : g_i > \varepsilon\}$ is
zero iff no gap exceeds $\varepsilon$, i.e. iff $\varepsilon \ge \max_i g_i =
M_n$. ∎

Equivalently, $M_n$ is the death scale of the *last* finite bar to die — the
longest finite bar. The infinite bar and one longest finite bar are the two
features that persist to the merge scale.

### 4.3 The total-persistence identity

**Definition 4.1 (Total persistence).** The *total persistence* of $\mathcal{B}_n$
is the sum of the lengths of its finite bars,
$$
\mathrm{TP}(n) \;=\; \sum_{i=1}^{n-1} (\text{length of the } i\text{-th finite bar}).
$$

**Theorem 4 (Total-persistence identity).** For all $n \ge 1$,
$$
\mathrm{TP}(n) \;=\; \sum_{i=1}^{n-1} g_i \;=\; p_n - 2.
$$

*Proof.* By Theorem 1 the $i$-th finite bar has length $g_i = p_{i+1} - p_i$.
Hence
$$
\mathrm{TP}(n) = \sum_{i=1}^{n-1} (p_{i+1} - p_i),
$$
a telescoping sum in which every intermediate term cancels, leaving
$p_n - p_1 = p_n - 2$. ∎

**Corollary 4.2 (Asymptotics).** By the Prime Number Theorem $p_n \sim n \log n$,
so $\mathrm{TP}(n) \sim n \log n$ and the normalized total persistence satisfies
$\mathrm{TP}(n)/(n \log n) \to 1$ as $n \to \infty$.

The total persistence — an aggregate topological invariant — is therefore
identically the $n$-th prime minus two, and its growth law *is* the Prime Number
Theorem.

### 4.4 Unboundedness of bar lengths

**Theorem 5 (Unbounded bars).** The barcode $\mathcal{B} = \bigcup_n \mathcal{B}_n$
contains finite bars of arbitrarily large length. Equivalently, for every
$L > 0$ there exist consecutive primes $p_i, p_{i+1}$ with a bar of length
$g_i > L$.

*Proof.* By Theorem 1 finite bar lengths are prime gaps, so it suffices to show
prime gaps are unbounded. Given any $M \ge 2$, the $M-1$ consecutive integers
$$
M! + 2,\ M! + 3,\ \dots,\ M! + M
$$
are all composite ($M! + k$ is divisible by $k$ for $2 \le k \le M$). Hence there
is a run of at least $M-1$ consecutive composites, forcing some prime gap to
exceed $M-1$. As $M$ is arbitrary, gaps — and therefore bar lengths — are
unbounded. ∎

Thus, unlike point clouds sampled from bounded regions, the prime cloud never
"stabilizes": at every finite scale $\varepsilon$ there remains a pair of
neighboring primes not yet merged. The infinite bar is joined by finite bars that
grow without bound.

---

## 5. Algorithms

We record the elementary algorithms underlying the numerics. All run in linear
time in $n$ once the primes are available; sieving dominates the cost.

### 5.1 Barcode construction

Given the first $n$ primes, the barcode is read directly off the gaps: emit the
infinite bar $[0,\infty)$ for the class of $p_1$, and a finite bar $[0, g_i)$ for
each $i = 1, \dots, n-1$. This is a direct instantiation of Theorem 1 and runs in
$O(n)$ time.

### 5.2 Betti curve evaluation

To evaluate $b_0(\varepsilon, n)$ at a query scale $\varepsilon$, count the gaps
exceeding $\varepsilon$ and add one (Theorem 2). Sorting the gaps once permits
answering all queries by binary search; the full Betti curve is obtained by
sweeping $\varepsilon$ through the sorted distinct gap values.

### 5.3 Total persistence

By Theorem 4 total persistence needs no summation over bars at all: it is
$p_n - 2$, an $O(1)$ read-off once $p_n$ is known. The naive $O(n)$ gap sum is a
useful cross-check.

---

## 6. A dictionary between arithmetic and topology

The results above yield a two-way dictionary. In each row, a statement about
primes is equivalent to a statement about the $H_0$ barcode of the prime cloud.

| Arithmetic | Topology |
|---|---|
| Prime gap $g_i$ | Length of the $i$-th finite bar |
| Twin primes $g_i = 2$ | Bar of length exactly $2$ |
| Bounded gaps (some gap value recurs infinitely) | Some finite bar length occurs with infinite multiplicity |
| Largest gap below $p_n$ | Global merge scale $M_n$ |
| $\sum_{i<n} g_i = p_n - 2$ | Total persistence $= p_n - 2$ |
| Prime Number Theorem $p_n \sim n\log n$ | $\mathrm{TP}(n) \sim n \log n$ |
| Unbounded gaps | Unbounded bar lengths |
| Hardy–Littlewood frequency of gap $g$ | Asymptotic multiplicity of bars of length $g$ |

Two conjectural rows deserve emphasis. The **Twin Prime Conjecture** — that
$g_i = 2$ infinitely often — is exactly the statement that a bar of length $2$
appears infinitely many times in the barcode. The **Hardy–Littlewood
$k$-tuple conjectures** predict, for each even $g$, an asymptotic density of gaps
equal to $g$ governed by a singular series; this is precisely a prediction for the
limiting *bar-length histogram* of the barcode.

---

## 7. Numerical illustration

For the first $10$ primes $2,3,5,7,11,13,17,19,23,29$ the gaps are
$1,2,2,4,2,4,2,4,6$. The finite barcode is therefore
$$
[0,1),\,[0,2),\,[0,2),\,[0,4),\,[0,2),\,[0,4),\,[0,2),\,[0,4),\,[0,6),
$$
together with the infinite bar $[0,\infty)$. The total persistence is
$1+2+2+4+2+4+2+4+6 = 27 = 29 - 2 = p_{10} - 2$, confirming Theorem 4. The global
merge scale is $M_{10} = 6$, the largest gap. The Betti curve takes the values
$b_0(0.5,10) = 10$, $b_0(1,10) = 9$, $b_0(2,10) = 5$, $b_0(4,10) = 2$,
$b_0(6,10) = 1$, a descending staircase reaching $1$ at $\varepsilon = 6$, as
predicted by Theorems 2 and 3. The accompanying computational demonstrations
reproduce these values and verify the identities for the first $10^5$ primes.

---

## 7bis. Stability, robustness, and the prime cloud as a benchmark

A defining virtue of persistent homology is *stability*: small perturbations of a
point cloud, measured in the bottleneck distance between persistence diagrams,
produce only small perturbations of the barcode. For the prime cloud this has a
concrete meaning. Suppose one replaces each prime $p_i$ by an approximate value
$\tilde{p}_i$ with $|\tilde{p}_i - p_i| \le \delta$. The bottleneck distance
between the true and perturbed persistence diagrams is at most $2\delta$, so every
inference drawn from the barcode — the gap multiset, the merge scale, the total
persistence up to an additive $O(n\delta)$ term — is robust to bounded noise. This
makes the prime cloud an unusually clean *benchmark* for topological data
analysis pipelines: the ground-truth barcode is known exactly (Theorem 1), so any
software that computes persistence can be validated against it, and any reported
feature that is not a prime gap is, by Theorem 1, a numerical artifact.

Two structural remarks reinforce this. First, because the underlying complex is a
subforest of a path graph, there are no higher-dimensional cycles at any scale:
$H_k(\mathrm{VR}_\varepsilon(P_n)) = 0$ for all $k \ge 1$. The entire persistent
homology of the one-dimensional prime cloud lives in degree zero, which is why the
gap sequence captures *everything*. Second, the persistence module is *interval
decomposable* in the strongest possible sense: it is a direct sum of one infinite
interval module and $n-1$ interval modules $[0, g_i)$, each a one-dimensional
summand. This is the algebraic content of the barcode and the reason the diagram
is well defined and unique.

## 7ter. Relationship to the gap counting function

Define the *gap counting function* $N(x) = \#\{ i < n : g_i > x \}$, the number of
finite bars of length exceeding $x$. By Theorem 2, $b_0(x, n) = 1 + N(x)$, so the
Betti curve and the gap survival function differ by the constant $1$ contributed
by the infinite bar. The integral of the survival function recovers total
persistence,
$$
\int_0^\infty N(x)\,\mathrm{d}x \;=\; \sum_{i=1}^{n-1} g_i \;=\; p_n - 2,
$$
a continuous restatement of Theorem 4 (the area under the Betti curve, minus the
infinite-bar contribution, is $p_n - 2$). This integral identity is the bridge to
the Future Directions: the *shape* of $N$, once normalized, is conjectured to
converge, and its moments are governed by the analytic theory of prime gaps.

## 8. Discussion

The zero-dimensional persistent homology of the prime point cloud is a fully
solved object: its barcode, Betti curve, merge scale, and total persistence are
all closed-form functions of the prime gaps, and the two subtlest global features
— the growth of total persistence and the unboundedness of bars — reproduce the
Prime Number Theorem and the unboundedness of prime gaps respectively. The value
of the construction is not that it proves new facts about primes in dimension
zero, but that it provides an exact, structure-preserving translation: the
barcode *is* the gap sequence, drawn as a stable topological invariant, and
several of the deepest open problems about primes acquire clean topological
phrasings.

The construction is also a caution and a benchmark for topological data analysis.
Because the ground truth here is known exactly, the prime cloud is an ideal test
case for persistence algorithms and for stability estimates: any numerical
barcode must reproduce the gap sequence, and any claimed feature beyond the gaps
is an artifact.

---

## 9. Future directions

**The barcode length distribution follows the Hardy–Littlewood law.** For each
even $g$, we conjecture that the asymptotic density of $H_0$ bars of death scale
exactly $g$ among the first $N$ bars is proportional to the Hardy–Littlewood
singular series for gap $g$; in particular bars of length $2$, $4$, and $6$ occur
with the classically predicted relative frequencies, and no even length is ever
absent from arbitrarily long windows. A bar of death scale $g$ is exactly a
maximal run whose bounding gap equals $g$, so the bar-length histogram is
literally the prime-gap histogram, transporting the entire analytic theory of gap
distribution into a topological invariant.

**Total persistence grows like $n \log n$.** The total persistence of the first
$n$ bars — equal to $p_n - 2$ — satisfies $p_n - 2 \sim n \log n$, and more
precisely the normalized total persistence $(p_n - 2)/(n \log n) \to 1$. Total
persistence is not an independent analytic quantity but is identically the $n$-th
prime minus two, so the growth rate of aggregate topological persistence is
exactly the Prime Number Theorem in disguise.

**The Betti curve has a universal staircase profile.** Viewed as a function of
the scale $\varepsilon$, the Betti number $b_0(\varepsilon, n) = 1 + \#\{\text{gaps
} \le n \text{ exceeding } \varepsilon\}$ is a right-continuous decreasing step
function whose rescaled profile, under $\varepsilon \mapsto \varepsilon/\log p_n$,
we conjecture converges to a deterministic limiting curve as $n \to \infty$. Each
downward step is triggered by one prime gap crossing $\varepsilon$, so the shape
of the curve is a cumulative count of gaps and its limiting profile encodes the
limiting law of normalized prime gaps.

**Higher-dimensional prime clouds carry genuine loops.** Placing the primes on a
curve in the plane by $p_n \mapsto (p_n, p_{n+1})$ (consecutive-prime pairs)
produces a point cloud in which one-dimensional persistent homology can be
nontrivial. We conjecture that the resulting loops encode correlations between
nearby primes in the spirit of the Hardy–Littlewood conjectures, and that their
persistence statistics distinguish the prime cloud from a random cloud with the
same gap distribution.

---

## References (classical background)

- Prime Number Theorem: $p_n \sim n \log n$.
- Unboundedness of prime gaps via factorial runs $M!+2, \dots, M!+M$.
- Hardy–Littlewood $k$-tuple conjectures on the density of prime gaps.
- Twin Prime Conjecture and bounded-gap results.
- Foundations of persistent homology, barcodes, persistence diagrams, and the
  stability theorem for topological data analysis.
