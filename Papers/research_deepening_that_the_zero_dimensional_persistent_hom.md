# The Zero-Dimensional Persistent Homology of the Prime Point Cloud: Unbounded Betti Growth and the Absence of a Global Merge Scale

## Abstract

We study the zero-dimensional persistent homology of the *prime point cloud*, the sequence of prime numbers regarded as a point cloud on the real line. For points on a line the Vietoris–Rips filtration is completely transparent: at resolution $\varepsilon$ two consecutive points belong to the same connected component precisely when the gap between them is at most $\varepsilon$. This yields an exact **Betti staircase** for the zeroth Betti number in terms of the prime gap sequence, and a barcode whose bar lengths are exactly the prime gaps. Building on this finite-$n$ description, we analyze the asymptotics as the number of points $n \to \infty$ at a *fixed* resolution $\varepsilon$. Our central result is that the prime Betti curve $n \mapsto \beta_0(\varepsilon, n)$ tends to $+\infty$ for every fixed $\varepsilon \ge 0$: the prime cloud shatters into arbitrarily many connected components at every scale, and there is no global merge scale at which the infinite prime cloud is connected. The entire phenomenon is driven by a single elementary arithmetic input — the unboundedness of prime gaps, proved via Euclid's factorial construction of arbitrarily long runs of consecutive composites — strengthened to an "infinitely often" statement. We also show the total persistence of the prime barcode diverges. We give complete definitions, statements, and proof sketches, and discuss quantitative refinements and the reinterpretation of the Twin Prime Conjecture as a statement about the shortest bars of the prime barcode.

**Keywords.** persistent homology, zeroth Betti number, prime gaps, Vietoris–Rips filtration, barcode, total persistence, topological data analysis.

---

## 1. Introduction

Topological data analysis (TDA) equips a finite metric space with a multiscale topological summary. Its workhorse, *persistent homology*, records how homological features — connected components ($H_0$), loops ($H_1$), voids ($H_2$), and higher analogues — appear and disappear as a scale parameter $\varepsilon$ increases. The output is a **barcode** or **persistence diagram**, a stable and informative fingerprint of the underlying data that has found applications from structural biology to cosmology to materials science.

The primes $2, 3, 5, 7, 11, \dots$ form perhaps the most studied sequence in mathematics, yet their geometry as a point cloud is rarely examined through the TDA lens. This paper does exactly that in dimension zero, where the theory is completely explicit and connects directly to the classical theory of prime gaps.

Throughout, let $p_i$ denote the $i$-th prime with the convention $p_0 = 2$, $p_1 = 3$, $p_2 = 5$, and so on, and define the **prime point cloud** to be the sequence $P = (p_i)_{i \ge 0}$ regarded as points on the real line $\mathbb{R}$. Our contributions are:

1. A clean statement and use of the **Betti staircase** for $H_0$ of a point cloud on a line, specialized to the primes.
2. An **"infinitely often"** version of the unboundedness of prime gaps, obtained from Euclid's composite-run construction placed arbitrarily far out.
3. The main asymptotic theorem: at every fixed resolution $\varepsilon$, the zeroth Betti number of the prime cloud **tends to infinity** with the number of points, and its component-counting curve is **monotone** in $n$.
4. The **no-global-merge** corollary and the **divergence of total persistence**.

All statements are elementary in their inputs but combine geometry (the line makes $H_0$ transparent) with arithmetic (unbounded gaps) to yield a structural conclusion about the shape of the primes.

---

## 2. Definitions and the zero-dimensional barcode on a line

### 2.1 The Vietoris–Rips filtration and $H_0$

Let $X = \{x_0, \dots, x_{n-1}\} \subset \mathbb{R}$ be a finite set of real points. For a resolution $\varepsilon \ge 0$, form the graph $G_\varepsilon(X)$ on vertex set $X$ with an edge between $x$ and $y$ whenever $|x - y| \le \varepsilon$. The **zeroth Betti number** $\beta_0(\varepsilon)$ is the number of connected components of $G_\varepsilon(X)$; equivalently, it is the rank of the zeroth homology of the Vietoris–Rips complex at scale $\varepsilon$. As $\varepsilon$ increases the graph only gains edges, so components only merge; this monotone merging is precisely what makes $\{G_\varepsilon(X)\}_{\varepsilon \ge 0}$ a *filtration* and its homology a *persistence module*.

### 2.2 The Betti staircase

Assume without loss of generality that the points are sorted, $x_0 < x_1 < \dots < x_{n-1}$, and write the **gaps** $g_i = x_{i+1} - x_i$ for $0 \le i < n-1$. On a line, two points lie in the same component of $G_\varepsilon(X)$ if and only if every gap between them is $\le \varepsilon$; a component boundary occurs exactly at each gap of size $> \varepsilon$. Counting boundaries gives the fundamental formula, the **Betti staircase**:

$$\boxed{\ \beta_0(\varepsilon, n) = 1 + \#\{\, i < n : g_i > \varepsilon \,\}.\ }$$

Here we index so that $\beta_0(\varepsilon, n)$ refers to the first $n$ points and the count ranges over the $n$ gap-indices under consideration; the "$1+$" accounts for the single component present when no gap exceeds $\varepsilon$. As a function of $\varepsilon$ this is a non-increasing step function (a descending staircase); as a function of $n$ it is non-decreasing.

### 2.3 Barcode and total persistence

For points on a line the $H_0$ barcode is especially simple. Every point is born as its own component at $\varepsilon = 0$; components merge one at a time as $\varepsilon$ passes each gap value. Using the standard convention that when two components merge the younger one dies, each finite bar has length equal to exactly one gap $g_i$, and there is one infinite bar for the component that never dies. The **total persistence** — the sum of the finite bar lengths — telescopes:

$$\mathrm{TP}(n) = \sum_{i=0}^{n-2} g_i = x_{n-1} - x_0.$$

For the prime cloud $P$ with $x_0 = p_0 = 2$, the total persistence over the first $n$ points equals $p_n - 2$ in the indexing used below (aggregating gaps through index $n-1$).

### 2.4 Prime-specific notation

Specializing to $X = \{p_0, \dots, p_{n-1}\}$, the gaps are the **prime gaps**

$$g_i = p_{i+1} - p_i, \qquad i \ge 0,$$

so that the prime Betti staircase reads

$$\beta_0^{P}(\varepsilon, n) = 1 + \#\{\, i < n : p_{i+1} - p_i > \varepsilon \,\}.$$

All of our asymptotic results describe the behavior of this quantity as $n \to \infty$ for fixed $\varepsilon$.

---

## 3. Unboundedness of prime gaps, infinitely often

The topological behavior of the prime cloud is governed entirely by how often prime gaps exceed a fixed threshold. We therefore begin with the arithmetic engine.

### 3.1 The composite-run lemma

**Lemma 1 (Composite run).** *For all integers $N$ and $j$ with $2 \le j \le N$, the number $N! + j$ is composite (not prime).*

*Proof.* Since $2 \le j \le N$, the factor $j$ appears in the product $N! = 1\cdot 2\cdots N$, so $j \mid N!$. Trivially $j \mid j$, hence $j \mid (N! + j)$. Now $1 < j$ and, because $N! \ge 1$, also $j < N! + j$, so $j$ is a divisor of $N! + j$ strictly between $1$ and $N! + j$. Therefore $N! + j$ has a nontrivial divisor and is not prime. $\qquad\blacksquare$

Applying Lemma 1 to $j = 2, 3, \dots, N$ produces the $N-1$ consecutive composite integers $N!+2, N!+3, \dots, N!+N$: a **prime desert** of length $N-1$. Since $N$ is arbitrary, deserts of every length exist.

### 3.2 Unbounded gaps, infinitely often

A single large desert only yields *one* large gap. To feed the asymptotic argument we need large gaps to recur arbitrarily far out.

**Theorem 2 (Unbounded gaps, infinitely often).** *For every bound $B$ and every index $M$ there exists an index $n \ge M$ with $g_n = p_{n+1} - p_n > B$.*

*Proof sketch.* Choose $N$ large enough that both $N > B$ and $N! + 2$ lies beyond the $M$-th prime; concretely $N = B + p_M + 2$ works, using $N \le N!$. Let $n$ be the index of the largest prime below $N! + 2$. Because $N! + 2$ exceeds $p_M$, this index satisfies $n \ge M$. The next prime $p_{n+1}$ cannot lie in the desert $\{N!+2, \dots, N!+N\}$ (all composite by Lemma 1), so $p_{n+1} \ge N! + N + 1$, while $p_n < N! + 2$. Hence

$$g_n = p_{n+1} - p_n > (N! + N + 1) - (N! + 2) = N - 1 \ge B,$$

after a mild adjustment of constants (taking $N$ a little larger absorbs the $-1$). The threshold is exceeded at an index $n \ge M$, as required. $\qquad\blacksquare$

**Corollary 3 (Infinitude of wide gaps).** *For every $c$, the index set $\{\, n : g_n > c \,\}$ is infinite.*

*Proof.* Given any finite bound $a$, Theorem 2 with $B = c$ and $M = a+1$ produces an index $n > a$ with $g_n > c$. Thus the set contains elements larger than any $a$ and is infinite. $\qquad\blacksquare$

---

## 4. Growth of the prime Betti curve

We now translate the arithmetic of Section 3 into topology via the Betti staircase of Section 2.

### 4.1 Monotonicity

**Proposition 4 (Monotonicity in $n$).** *For any point sequence $p$ and any fixed $\varepsilon$, the map $n \mapsto \beta_0(\varepsilon, n)$ is non-decreasing.*

*Proof.* By the Betti staircase, $\beta_0(\varepsilon, n) = 1 + \#\{ i < n : g_i > \varepsilon\}$. Increasing $n$ enlarges the index range $\{i < n\}$, so the counted set can only grow; the count is therefore monotone. $\qquad\blacksquare$

### 4.2 The counting curve is unbounded

**Proposition 5 (Wide-gap counts are unbounded).** *For every threshold $c$ and every target $M$ there exists $n$ with*

$$\#\{\, i < n : g_i > c \,\} \ge M.$$

*Proof sketch.* Induct on $M$. The base case $M = 0$ is trivial. Given an index $n$ realizing count $\ge M$, apply Theorem 2 with bound $c$ and starting index $n$ to obtain a fresh index $m \ge n$ with $g_m > c$. This index is not already counted among $\{i < n\}$, so adjoining it and passing to range $m+1$ increases the count by at least one, giving $\ge M+1$. $\qquad\blacksquare$

### 4.3 Main theorem

**Theorem 6 (Prime Betti curve is unbounded).** *For every resolution $\varepsilon \ge 0$ and every $M$ there exists $n$ with $\beta_0^{P}(\varepsilon, n) \ge M$.*

*Proof sketch.* Let $c = \lceil \varepsilon \rceil$ be an integer upper ceiling of $\varepsilon$. By Proposition 5 there is an $n$ with at least $M$ prime-gap indices $i < n$ satisfying $g_i > c$. Since $g_i > c \ge \varepsilon$, every such index also satisfies the real-valued condition $g_i > \varepsilon$. Hence the set counted by the prime Betti staircase contains at least $M$ indices, so $\beta_0^{P}(\varepsilon, n) \ge 1 + M \ge M$. $\qquad\blacksquare$

**Theorem 7 (Prime shattering / divergence of the Betti curve).** *For every fixed resolution $\varepsilon \ge 0$,*

$$\beta_0^{P}(\varepsilon, n) \xrightarrow[n \to \infty]{} +\infty.$$

*Proof.* The function $n \mapsto \beta_0^{P}(\varepsilon, n)$ is monotone (Proposition 4) and unbounded above (Theorem 6). A monotone, unbounded-above integer sequence tends to $+\infty$. $\qquad\blacksquare$

### 4.4 No global merge scale

For any *finite* point cloud there is a scale $\varepsilon$ (larger than every gap) at which it becomes a single connected blob. The infinite prime cloud has no such scale.

**Corollary 8 (No global merge scale).** *For every resolution $\varepsilon$ there exists $n$ with $\beta_0^{P}(\varepsilon, n) > 1$; equivalently, the infinite prime cloud is not connected at any fixed scale.*

*Proof.* Apply Theorem 6 with $M = 2$ to obtain $n$ with $\beta_0^{P}(\varepsilon, n) \ge 2 > 1$. $\qquad\blacksquare$

---

## 5. Divergence of total persistence

**Theorem 9 (Total persistence diverges).** *The total persistence of the prime barcode over the first $n$ points equals $p_n - 2$, and hence*

$$\mathrm{TP}(n) \xrightarrow[n \to \infty]{} +\infty.$$

*Proof.* By the telescoping identity of Section 2.3, the total persistence is $\sum_{i} g_i = p_n - p_0 = p_n - 2$. The primes are strictly increasing and unbounded (there are infinitely many primes), so $p_n \to \infty$ and therefore $p_n - 2 \to \infty$. $\qquad\blacksquare$

---

## 6. Algorithms

We record the elementary algorithms that make every quantity above computable, so the theory can be checked numerically (see the accompanying demonstrations).

**(A) Betti number at a scale.** Given the first $n$ primes and a resolution $\varepsilon$, compute the gaps $g_i = p_{i+1} - p_i$ and return $1 + \#\{i : g_i > \varepsilon\}$. Linear in $n$.

**(B) Barcode / persistence diagram.** Sort the finite gaps; each gap $g_i$ contributes a bar $[0, g_i)$ (birth at scale $0$, death at scale $g_i$), plus one infinite bar. Sorting is $O(n \log n)$; the bars themselves are read off in $O(n)$.

**(C) Prime-desert search.** To exhibit a gap exceeding a bound $B$ at an index $\ge M$, choose $N = B + p_M + 2$, form the desert $N!+2, \dots, N!+N$, and locate the primes bracketing it. This realizes the constructive content of Theorem 2.

---

## 7. Applications and interpretation

**A worked microcosm of TDA.** In practice, persistent homology is applied to point clouds — protein conformations, galaxy catalogs, sensor coverage, high-dimensional embeddings in machine learning — where no closed form for the barcode exists and one reads it off empirically. The prime cloud is a rare canonical example where the entire $H_0$ barcode is understood *exactly*: bar lengths are prime gaps, the staircase is explicit, and the asymptotics are governed by one arithmetic fact. It is therefore a clean pedagogical and benchmark example for the theory.

**Arithmetic $=$ topology.** The results make precise a slogan: the topological divergence of the prime cloud is *identical* to the arithmetic divergence of prime gaps. Unbounded gaps $\Leftrightarrow$ unbounded $\beta_0$ at every scale $\Leftrightarrow$ no global merge scale. The primes' resistance to being seen as a single blob is a topological restatement of Euclid's deserts.

**A cautionary intuition.** The average prime gap near $x$ is asymptotically $\ln x$, tempting one to imagine the primes eventually "smearing" into one component at any fixed coarse scale. Theorem 7 refutes this: it is the *recurrence of large gaps*, not the average, that controls $H_0$. The average growing to infinity is in fact consistent with — and here reinforces — the shattering.

---

## 8. Discussion and future work

**Rate of shattering.** Theorem 7 gives divergence but not a rate. Heuristics from the Prime Number Theorem predict that for fixed $\varepsilon$ a positive proportion of gaps eventually exceed $\varepsilon$, which would give a *linear* lower bound $\beta_0^{P}(\varepsilon, n) = \Omega(n)$. Even a weak explicit lower bound — for instance via the average gap $p_n / n \sim \ln p_n \to \infty$ — would quantify the shattering and is a natural next target.

**The twin bar and the Twin Prime Conjecture.** The shortest possible finite bar has length $2$, corresponding to a gap $g_i = 2$, i.e. a pair of twin primes. Whether infinitely many length-$2$ bars occur is exactly the Twin Prime Conjecture, recast as a statement about the *smallest* bars of the prime barcode — a dual to the *largest*-gap analysis carried out here. More generally, Zhang–Maynard-type bounded-gap results translate directly into statements about the persistence of short bars.

**Higher dimensions and other embeddings.** Placing the primes on a line makes $H_1$ and above trivial. Embedding the primes in $\mathbb{R}^2$ or higher (e.g., via digit expansions, the Ulam spiral, or residue coordinates) would activate higher persistent homology and pose genuinely new questions about loops and voids in the resulting prime clouds.

**Stability and other arithmetic sequences.** The same $H_0$ analysis applies verbatim to any strictly increasing integer sequence, with the barcode determined by its gap sequence. Comparing the prime barcode with those of sequences of comparable density (e.g. numbers with a bounded number of prime factors) via the bottleneck distance is a promising direction for arithmetic TDA.

---

## 9. Conclusion

Viewed as a point cloud on the line, the primes have a completely computable zero-dimensional persistent homology: the Betti number is a staircase in the prime gaps, and the barcode's bar lengths *are* the prime gaps. The asymptotic story is dominated by a single elementary fact — prime gaps are unbounded, infinitely often, by Euclid's factorial deserts. From it we conclude that at every fixed resolution the prime cloud fractures into arbitrarily many components, that no global scale renders the infinite cloud connected, and that the total persistence diverges. Arithmetic divergence and topological divergence are one and the same. The framework leaves open sharp quantitative rates and a striking reinterpretation of the Twin Prime Conjecture as a statement about the shortest bars of the prime barcode.
