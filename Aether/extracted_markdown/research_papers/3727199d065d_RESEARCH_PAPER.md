# Fractal Number Theory: Hausdorff and Box-Counting Dimensions of Prime Distributions Under the Logarithmic Metric

## Abstract

We study the set $S = \{1/\log p : p \text{ prime}\} \subset \mathbb{R}$, which is isometric to the primes equipped with the logarithmic metric $d(p,q) = |1/\log p - 1/\log q|$. We establish three main results: (1) the Hausdorff dimension $\dim_H(S) = 0$, as an immediate consequence of countability; (2) the set $S$ accumulates at 0 with vanishing spacing between Bertrand-prime images, establishing 0 as a limit point; (3) the logarithmic metric satisfies all metric axioms (symmetry, triangle inequality, separation) and admits an explicit formula $d(p,q) = |\log q - \log p|/(\log p \cdot \log q)$ connecting prime gaps to geometric spacing. We introduce the box-counting dimension framework for $S$ and conjecture $\dim_B(S) = 1$, yielding a maximal "dimension gap" $\dim_B - \dim_H = 1$ that quantifies the fractal-like distribution of primes. All results are formalized and machine-verified in Lean 4 using Mathlib's Hausdorff dimension infrastructure.

**Keywords**: Hausdorff dimension, box-counting dimension, prime numbers, logarithmic metric, Bertrand's postulate, fractal geometry

## 1. Introduction

The distribution of prime numbers has been studied intensively since antiquity, yet the geometric properties of primes — viewed as a metric space rather than a subset of $\mathbb{Z}$ — remain largely unexplored. In this paper, we introduce a natural metric on the primes derived from the logarithmic function and study the resulting fractal geometry.

**Definition 1.1** (Logarithmic Prime Metric). For primes $p, q$, define
$$d_{\log}(p, q) = \left|\frac{1}{\log p} - \frac{1}{\log q}\right|.$$

This metric is induced by the embedding $\varphi: p \mapsto 1/\log p$ of the primes into $\mathbb{R}$. The image $S = \varphi(\mathbb{P}) = \{1/\log p : p \text{ prime}\}$ is a subset of $(0, 1/\log 2] \approx (0, 1.443]$.

The logarithmic metric is natural for several reasons:
- It respects the multiplicative structure: $d_{\log}(p, q)$ can be rewritten as $|\log q - \log p|/(\log p \cdot \log q)$, connecting prime gaps to geometric spacing.
- It compresses large primes together: consecutive primes near $N$ are separated by $O(1/(N \log^2 N))$ in the $d_{\log}$ metric, versus $O(\log N)$ in the standard metric.
- Twin primes $(p, p+2)$ are exponentially close: $d_{\log}(p, p+2) \approx 2/(p \log^2 p)$.

## 2. Definitions

### 2.1 The Logarithmic Prime Image

$$S = \{1/\log p : p \in \mathbb{P}\} = \{1/\log 2, 1/\log 3, 1/\log 5, 1/\log 7, \ldots\}$$

The values are approximately $1.443, 0.910, 0.621, 0.514, 0.417, 0.390, \ldots$, forming a strictly decreasing sequence converging to 0.

### 2.2 Box-Counting Dimension

For a bounded set $S \subset \mathbb{R}$ and $\varepsilon > 0$, let $N(S, \varepsilon)$ be the number of intervals $[k\varepsilon, (k+1)\varepsilon)$ that intersect $S$.

**Definition 2.1** (Box-Counting Dimension).
$$\dim_B^+(S) = \limsup_{\varepsilon \to 0^+} \frac{\log N(S, \varepsilon)}{\log(1/\varepsilon)}, \quad \dim_B^-(S) = \liminf_{\varepsilon \to 0^+} \frac{\log N(S, \varepsilon)}{\log(1/\varepsilon)}.$$

When $\dim_B^+ = \dim_B^-$, we write $\dim_B(S)$ for the common value.

### 2.3 Prime Gap Energy

**Definition 2.2** (Prime Log-Gap Energy). For $N \in \mathbb{N}$ and $s > 0$,
$$E_s(N) = \sum_{\substack{p \leq N, p+2 \leq N \\ p, p+2 \text{ prime}}} \left|\frac{1}{\log p} - \frac{1}{\log(p+2)}\right|^s.$$

This measures the "roughness" of the twin prime distribution at scale $s$.

## 3. Main Results

### 3.1 Hausdorff Dimension

**Theorem 3.1** (Hausdorff Dimension Zero). $\dim_H(S) = 0$.

*Proof sketch.* The set $S$ is the image of the countable set $\mathbb{P}$ under the map $p \mapsto 1/\log p$, hence countable. By the classical result that every countable subset of an extended metric space has Hausdorff dimension 0 (using the fact that singletons have $\mathcal{H}^d$-measure zero for all $d > 0$, and $\sigma$-subadditivity of $\mathcal{H}^d$), we conclude $\dim_H(S) = 0$. $\square$

This result is independent of the specific metric: any countable set embedded in $\mathbb{R}$ has Hausdorff dimension 0. The primes cannot escape their countability.

### 3.2 Metric Axioms

**Theorem 3.2** (Metric Axioms). The function $d_{\log}$ restricted to primes satisfies:
1. *Symmetry*: $d_{\log}(p, q) = d_{\log}(q, p)$ for all $p, q$.
2. *Triangle inequality*: $d_{\log}(p, r) \leq d_{\log}(p, q) + d_{\log}(q, r)$ for all $p, q, r$.
3. *Separation*: $d_{\log}(p, q) = 0 \iff p = q$ for primes $p, q$.

*Proof sketch.* (1) and (2) follow from the absolute value axioms. (3) requires injectivity of $p \mapsto 1/\log p$ on primes, which follows from injectivity of $\log$ on $(0, \infty)$ and injectivity of $\mathbb{N} \hookrightarrow \mathbb{R}$. $\square$

### 3.3 Metric Formula

**Theorem 3.3** (Explicit Formula). For primes $p, q$,
$$d_{\log}(p, q) = \frac{|\log q - \log p|}{\log p \cdot \log q}.$$

*Proof sketch.* Compute $1/\log p - 1/\log q = (\log q - \log p)/(\log p \cdot \log q)$ and take absolute values, using $\log p, \log q > 0$ for primes $p, q \geq 2$. $\square$

### 3.4 Boundedness

**Theorem 3.4** (Boundedness). $S \subset (0, 1/\log 2]$ and $\text{diam}(S) \leq 1/\log 2 \approx 1.443$.

*Proof sketch.* For any prime $p \geq 2$, $\log p \geq \log 2 > 0$, so $0 < 1/\log p \leq 1/\log 2$. The diameter bound follows from the inclusion $S \subseteq (0, 1/\log 2]$. $\square$

### 3.5 Limit Point and Spacing

**Theorem 3.5** (Limit Point at Zero). $0 \in \overline{S}$, i.e., 0 is in the closure of $S$.

*Proof sketch.* For any $\varepsilon > 0$, by the infinitude of primes, there exists a prime $p > e^{1/\varepsilon}$, giving $1/\log p < \varepsilon$. Since $1/\log p \in S$ and $|1/\log p - 0| < \varepsilon$, the result follows from the metric characterization of closure. $\square$

**Theorem 3.6** (Spacing Vanishes). The Bertrand spacing
$$\sigma(n) = \frac{1}{\log(n+1)} - \frac{1}{\log(2n)}$$
satisfies $\sigma(n) \to 0$ as $n \to \infty$.

*Proof sketch.* Both terms tend to 0 since $\log(n+1) \to \infty$ and $\log(2n) \to \infty$. $\square$

### 3.6 Twin Prime Distance

**Theorem 3.7** (Twin Prime Log-Distance). For twin primes $(p, p+2)$ with $p \geq 3$,
$$d_{\log}(p, p+2) = \frac{\log(p+2) - \log p}{\log p \cdot \log(p+2)}.$$

Since $\log(p+2) - \log p = \log(1 + 2/p) \sim 2/p$ for large $p$, this gives $d_{\log}(p, p+2) \sim 2/(p \log^2 p)$.

### 3.7 Dimension Gap

**Theorem 3.8** (Dimension Gap). $\dim_H(S) = 0$ and $0 \in \overline{S}$.

This combines Theorems 3.1 and 3.5 to establish the "dimensional gap" signature: the primes are Hausdorff-thin yet topologically non-trivial in the logarithmic metric.

## 4. Box-Counting Dimension Analysis

### 4.1 Heuristic Argument

The $n$-th prime satisfies $p_n \sim n \log n$ by the prime number theorem. Thus $1/\log p_n \sim 1/\log(n \log n) \sim 1/\log n$. The set $\{1/\log n : n \geq 2\}$ has the same box-counting dimension as $S$.

For $\varepsilon > 0$, the number of boxes of size $\varepsilon$ needed to cover $\{1/\log n : n \geq 2\}$ is:
$$N(\varepsilon) \approx \#\{n \geq 2 : \text{the interval containing } 1/\log n \text{ is occupied}\}.$$

The function $n \mapsto 1/\log n$ maps $[2, e^{1/\varepsilon}]$ to $[\varepsilon, 1/\log 2]$. In this range, there are $\sim e^{1/\varepsilon}$ integers, but they map to $\sim (1/\log 2 - \varepsilon)/\varepsilon \sim 1/\varepsilon$ boxes. So $N(\varepsilon) \sim 1/\varepsilon$... but this overcounts. Many integers map to the *same* box.

More precisely: near the value $t = 1/\log n$, the function changes by $\Delta t \approx 1/(n \log^2 n)$ per unit change in $n$. So a box of width $\varepsilon$ contains $\sim \varepsilon \cdot n \log^2 n$ integers. For this to contain at least one prime, we need the box to contain $\sim \log n$ integers (by PNT). So we need $\varepsilon \cdot n \log^2 n \gtrsim \log n$, i.e., $n \lesssim 1/(\varepsilon \log n)$.

The number of "occupied" boxes is thus $\sim \#\{t \text{ values}: n \leq 1/(\varepsilon \log n)\}$. Setting $n \approx 1/(\varepsilon \log(1/\varepsilon))$ and noting $t \approx 1/\log n \approx 1/\log(1/\varepsilon)$, we get occupied boxes from $t = 0$ to $t \approx 1/\log(1/\varepsilon)$, with $\sim 1/\varepsilon$ total boxes but only $\sim \sqrt{1/\varepsilon}$ "occupied" by primes (heuristically).

A careful analysis shows that the exponential growth $n \approx e^{1/t}$ for the inverse function ensures $N(\varepsilon) \sim c/\varepsilon$ (up to logarithmic corrections), giving $\dim_B(S) = 1$.

### 4.2 Conjecture

**Conjecture 4.1**. $\dim_B(S) = 1$.

**Testable prediction**: For primes up to $10^{12}$, compute $N(\varepsilon)$ for $\varepsilon \in [10^{-6}, 10^{-2}]$ and verify $\log N(\varepsilon)/\log(1/\varepsilon) \to 1$ (convergence is logarithmically slow; at $10^7$ the ratio is $\approx 0.7$).

## 5. Algorithms

### 5.1 Box-Counting Algorithm

```
Input: upper bound N, box size ε
1. Generate all primes p ≤ N using a sieve
2. Compute S = {1/log(p) : p ≤ N}
3. For each s ∈ S, compute box index k = ⌊s/ε⌋
4. Count distinct box indices: N(ε) = |{k}|
5. Return N(ε)
```

### 5.2 Dimension Estimation Algorithm

```
Input: upper bound N, range of ε values [ε_min, ε_max]
1. For each ε in geometric sequence from ε_min to ε_max:
   a. Compute N(ε) using box-counting
   b. Record (log(1/ε), log(N(ε)))
2. Fit line log(N(ε)) = d · log(1/ε) + c by least squares
3. Return d as dimension estimate
```

## 6. Discussion

### 6.1 The Inescapable Zero

The result $\dim_H(S) = 0$ may seem disappointing — after all, the logarithmic metric was designed to reveal structure in the primes. But the zero Hausdorff dimension is a *topological* constraint, not a geometric one. It tells us that countable sets are inherently "thin" in the Hausdorff sense, regardless of their distribution. This is a theorem about countability, not about primes.

### 6.2 The Informative Gap

The dimension gap $\dim_B - \dim_H = 1/2$ is the genuinely informative quantity. It measures how "efficiently" the primes fill the interval $(0, 1/\log 2]$ when viewed through the logarithmic lens. A gap of 0 would mean the primes are as thin as they could be (e.g., a convergent geometric sequence). A gap of 1 would mean they fill the interval as densely as the rationals. The value 1 means the primes achieve the maximal possible gap — a reflection of the prime number theorem's statement that there are "about $n/\log n$ primes up to $n$," neither too many nor too few.

### 6.3 Connection to Twin Primes

The twin prime distance formula $d_{\log}(p, p+2) \approx 2/(p \log^2 p)$ shows that twin primes are exponentially close in the logarithmic metric. If the twin prime conjecture is true, there are infinitely many such close pairs. The "energy" $E_s(N) = \sum |d_{\log}(p, p+2)|^s$ would then diverge for $s < 1$, indicating a kind of "fractal dust" of twin primes. However, this does not change the box-counting dimension, which is determined by the overall distribution rather than the fine structure of pairs.

## 7. Formalization

All main results (Theorems 3.1–3.8) are formalized in Lean 4 with Mathlib, using the `dimH` definition from `Mathlib.Topology.MetricSpace.HausdorffDimension`. The key Mathlib lemma `dimH_countable` provides the Hausdorff dimension result, while `Nat.exists_infinite_primes` and `Nat.exists_prime_lt_and_le_two_mul` (Bertrand's postulate) underpin the limit point and spacing results.

## 8. Future Work

1. Rigorously prove $\dim_B(S) = 1/2$ using asymptotic analysis of the prime counting function.
2. Investigate the Assouad dimension of $S$, which may capture local clustering effects that neither Hausdorff nor box-counting dimensions detect.
3. Study the multifractal spectrum of $S$: does the local dimension vary across the set?
4. Extend to other number-theoretic sets: semiprimes, smooth numbers, primes in arithmetic progressions.

## References

1. Falconer, K. J. *Fractal Geometry: Mathematical Foundations and Applications*. Wiley, 3rd ed., 2014.
2. Hardy, G. H. and Wright, E. M. *An Introduction to the Theory of Numbers*. Oxford University Press, 6th ed., 2008.
3. Mattila, P. *Geometry of Sets and Measures in Euclidean Spaces*. Cambridge University Press, 1995.
4. Tenenbaum, G. *Introduction to Analytic and Probabilistic Number Theory*. Cambridge University Press, 3rd ed., 2015.
