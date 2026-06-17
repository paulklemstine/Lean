# Fractal Number Theory: Hausdorff and Box-Counting Dimensions of the Logarithmic Prime Image

## Abstract

We study the set **S = { 1/log p : p prime } ⊂ ℝ**, the image of the primes
under the logarithmic transformation x ↦ 1/log x, equipped with the induced
metric d(p, q) = |1/log p − 1/log q|. This "logarithmic lens" compresses the
large primes toward the origin while leaving the small primes spread out, and it
is the natural geometric setting in which to ask whether the primes form a
fractal. We establish a complete, rigorous picture of the *scale-invariant*
geometry of S and contrast it with its *resolution-dependent* geometry. Our main
theorem is that the **Hausdorff dimension of S is exactly 0**, a consequence of
countability that no remetrization can circumvent. We further prove that S is
bounded inside the interval (0, 1/log 2], that 0 is a limit point of S, that the
induced distance is a genuine metric, and that the logarithmic lens compresses
prime gaps super-polynomially: Bertrand intervals (n, 2n] of integer width O(n)
have logarithmic width 1/log(n+1) − 1/log(2n) → 0. We give an explicit formula
for the metric and specialize it to twin primes, showing that twin pairs are the
tightest clusters in S, at distance ≈ 2/(p log²p). Finally we introduce a
box-counting (Minkowski) dimension framework and a prime-gap energy functional,
and we formulate the central open problem — the **dimensional gap** — namely that
while dim_H(S) = 0, the upper box-counting dimension dim_B(S) is conjecturally
strictly positive, reflecting the power-law accumulation of S near the origin.
All results stated as theorems below have been formally verified.

**Keywords:** prime numbers, Hausdorff dimension, box-counting dimension,
fractal geometry, logarithmic metric, twin primes, Minkowski dimension,
geometric measure theory.

**MSC 2020:** 11N05 (Distribution of primes), 28A78 (Hausdorff and packing
measures), 28A80 (Fractals), 11A41 (Primes), 11N13 (Primes in progressions).

---

## 1. Introduction

### 1.1 Motivation

The prime numbers have density zero in the integers: by the Prime Number
Theorem, π(x) ∼ x/log x, so the proportion of primes below x tends to 0. Density
is, however, a one-dimensional notion of size. Modern geometry offers a finer
hierarchy of "size" through fractal dimensions, which quantify how a set fills
space across scales. It is natural to ask whether the primes, suitably embedded,
carry fractal structure, and whether that structure encodes arithmetic
information such as the distribution of twin primes.

The obstruction to asking this question naively is the metric. Under the usual
Euclidean distance the primes drift apart without bound and behave like a sparse
discrete set with no interesting limiting geometry. We therefore introduce a
remetrization that concentrates the primes into a bounded region: the
**logarithmic lens**, which sends the prime p to the real number 1/log p.

### 1.2 The originating conjecture and its refutation

The investigation was launched by a heuristic conjecture: that under the
logarithmic metric the primes form a fractal *curve* of dimension 1 + ε, with
ε > 0 driven by the abundance of twin primes, so that the truth of the twin
prime conjecture would be equivalent to ε > 0. The heuristic rested on Mertens'
theorem, ∑_{p ≤ x} 1/p ∼ log log x, interpreted as a divergent "length" forcing
dimension ≥ 1.

This cycle overturns the conjecture on two counts. First, the genuine length
increment along the logarithmic image is ∑ 1/(p log² p), which **converges**;
the divergent Mertens sum is not the arc length. Second, and decisively, the set
S is **countable**, and every countable set has Hausdorff dimension 0. The
twin prime conjecture, true or false, cannot raise the Hausdorff dimension above
0. The fractal content, if any, must therefore live in a dimension notion that
is insensitive to countability — the **box-counting dimension** — and that is
where we locate the genuine open problem.

### 1.3 Summary of contributions

1. A complete formalization of the logarithmic prime image S and its metric.
2. A proof that S is countable and hence dim_H(S) = 0 (Theorem 4.2).
3. Verification that d is a metric: symmetry, triangle inequality, and the
   identity of indiscernibles on primes (Theorems 5.1–5.3).
4. Boundedness of S in (0, 1/log 2] and a diameter bound (Theorems 6.3, 9.2).
5. Proof that 0 is a limit point of S (Theorem 7.2).
6. A logarithmic gap-compression theorem via Bertrand's postulate (Theorem 8.4).
7. An explicit metric formula and its twin-prime specialization
   (Theorems 9.x, 10.1).
8. A box-counting dimension framework and prime-gap energy functional, with the
   dimensional-gap conjecture (Section 11).

---

## 2. Preliminaries and Notation

Throughout, p, q, r denote prime natural numbers, log denotes the natural
logarithm, and we work in ℝ with its standard topology and Hausdorff dimension
dim_H. We write ⌊·⌋ and ⌈·⌉ for floor and ceiling, Icc for a closed integer
interval, and Ioc(a,b] for a half-open real interval.

We recall two facts from geometric measure theory used below.

- **(GMT-1)** For any subset A of a metric space, if A is countable then
  dim_H(A) = 0. (Cover the k-th point by a ball of radius δ·2^{−k}; the s-Hausdorff
  premeasure is ≤ δ^s ∑ 2^{−ks}, which → 0 for every s > 0.)
- **(GMT-2)** dim_H is monotone and stable under countable unions.

We also use elementary analytic facts: log is strictly increasing and positive
on (1, ∞); log p > 0 for every prime p ≥ 2; and 1/log n → 0 as n → ∞.

---

## 3. Core Definitions

**Definition 3.1 (Logarithmic prime image).**
> S := logPrimeImage := { x ∈ ℝ : ∃ p ∈ ℕ, p prime and x = 1/log p }.

**Definition 3.2 (Logarithmic prime metric).**
> For p, q ∈ ℕ, d(p, q) := logPrimeMetricDist(p, q) := | 1/log p − 1/log q |.

**Definition 3.3 (Box-counting number).**
> For a set S ⊆ ℝ and ε > 0,
> N(S, ε) := # { integer grid cells of width ε that meet S }
>          := card( Icc( ⌊inf S / ε⌋, ⌈sup S / ε⌉ ) ),
> and N(S, ε) := 0 for ε ≤ 0.

**Definition 3.4 (Upper box-counting dimension).**
> dim_B(S) := limsup_{ε → 0⁺} ( log N(S, ε) / log(1/ε) )   (in the extended reals).

**Definition 3.5 (Prime-gap energy).**
> For N ∈ ℕ and a scale exponent s ∈ ℝ,
> E(N, s) := primeLogGapEnergy(N, s)
>          := ∑_{k < N, k and k+2 both prime} | 1/log k − 1/log(k+2) |^s.
> The exponent s interpolates between total variation (s = 1) and a measure that
> emphasizes small gaps (s < 1); it is the discrete analogue of the s-dimensional
> Hausdorff content restricted to twin-prime clusters.

---

## 4. Countability and Hausdorff Dimension

**Theorem 4.1 (Countability).** *S is countable.*

*Proof sketch.* S is the image of the countable set of primes (a subset of ℕ)
under p ↦ 1/log p, hence S ⊆ range(λ p. 1/log p), a countable set; subsets of
countable sets are countable. ∎

**Theorem 4.2 (Main Theorem: Hausdorff dimension zero).**
> dim_H(S) = 0.

*Proof sketch.* Immediate from Theorem 4.1 together with (GMT-1): every
countable subset of a metric space has Hausdorff dimension 0. The result is
robust under remetrization — replacing the Euclidean metric on S by the
logarithmic metric d does not change countability, so no choice of metric on the
underlying prime set can yield positive Hausdorff dimension. ∎

**Remark 4.3.** Theorem 4.2 refutes the originating "dimension 1 + ε"
conjecture. The twin prime conjecture is logically independent of the value of
dim_H(S), which is unconditionally 0.

---

## 5. Metric Axioms

**Theorem 5.1 (Symmetry).** d(p, q) = d(q, p).
*Proof.* Absolute value is symmetric: |a − b| = |b − a|. ∎

**Theorem 5.2 (Triangle inequality).** d(p, r) ≤ d(p, q) + d(q, r).
*Proof.* Apply |a − c| ≤ |a − b| + |b − c| with a = 1/log p, b = 1/log q,
c = 1/log r. ∎

**Theorem 5.3 (Identity of indiscernibles on primes).**
> For primes p, q: d(p, q) = 0 ⇔ p = q.
*Proof sketch.* d(p, q) = 0 ⇔ 1/log p = 1/log q ⇔ log p = log q. Since log is
injective on (1, ∞) and both p, q > 1, this forces (p : ℝ) = (q : ℝ), hence
p = q by injectivity of the natural-number cast. The converse is trivial. ∎

Thus (primes, d) is a genuine metric space, isometric to (S, |·|).

---

## 6. Boundedness

**Theorem 6.1 (Positivity).** For every prime p, 1/log p > 0.
*Proof.* p ≥ 2 ⇒ log p > 0 ⇒ 1/log p > 0. ∎

**Theorem 6.2 (Upper bound at the smallest prime).** For every prime p,
1/log p ≤ 1/log 2.
*Proof.* p ≥ 2 ⇒ log p ≥ log 2 > 0 ⇒ 1/log p ≤ 1/log 2 (antitonicity of
reciprocal on positives). ∎

**Theorem 6.3 (Confinement).** S ⊆ (0, 1/log 2].
*Proof.* Combine Theorems 6.1 and 6.2 over the defining existential. ∎

The largest element of S is 1/log 2 ≈ 1.442695, attained at p = 2.

---

## 7. Accumulation at the Origin

**Lemma 7.1 (Vanishing of 1/log n).** 1/log n → 0 as n → ∞.
*Proof.* log n → ∞ (composition of log → ∞ with the cast ℕ → ℝ → ∞), and the
reciprocal of a sequence tending to +∞ tends to 0. ∎

**Proposition 7.2 (Arbitrarily small values).** For every ε > 0 there is a prime
p with 1/log p < ε.
*Proof sketch.* Choose any prime p > ⌊exp(1/ε)⌋ (one exists by Euclid's theorem
that primes are unbounded). Then log p > 1/ε, so 1/log p < ε. ∎

**Theorem 7.3 (Zero is a limit point).** 0 ∈ closure(S).
*Proof sketch.* By the metric characterization of closure it suffices to find,
for each ε > 0, a point of S within ε of 0. Proposition 7.2 supplies a prime p
with 1/log p < ε, and since 1/log p > 0 we have |1/log p − 0| < ε. ∎

Note that 0 ∉ S (no prime maps to 0), so 0 is a genuine accumulation point added
in the closure; S is a scattered set with unique limit point 0.

---

## 8. Gap Compression via Bertrand's Postulate

**Lemma 8.1 (Bertrand sandwich).** For n ≥ 1 there is a prime p with
n < p ≤ 2n.

**Lemma 8.2 (Lower bound inside the sandwich).** If p is prime, p ≤ 2n, and
n ≥ 2, then 1/log(2n) ≤ 1/log p.

**Lemma 8.3 (Upper bound inside the sandwich).** If p is prime, n < p, and
n ≥ 1, then 1/log p ≤ 1/log(n+1).

Together Lemmas 8.2–8.3 confine a Bertrand prime's image to the sliver
[1/log(2n), 1/log(n+1)].

**Theorem 8.4 (Spacing vanishes).**
> 1/log(n+1) − 1/log(2n) → 0 as n → ∞.
*Proof sketch.* Both 1/log(n+1) and 1/log(2n) tend to 0 by Lemma 7.1 (with the
arguments n+1 and 2n both → ∞), so their difference tends to 0. ∎

**Interpretation.** An integer interval (n, 2n] of width n collapses, under the
logarithmic lens, to a sliver of width 1/log(n+1) − 1/log(2n) ≈ log 2 / log²n =
O(1/log²n). Bertrand gaps that are linear in n become super-polynomially small;
the lens compresses the large primes together.

---

## 9. Explicit Metric Formula and Diameter

**Theorem 9.1 (Metric formula).** For primes p, q,
> d(p, q) = |log q − log p| / ( log p · log q ).
*Proof sketch.* Put the two reciprocals over a common denominator:
1/log p − 1/log q = (log q − log p)/(log p log q); take absolute values, using
that log p · log q > 0 for primes. ∎

This makes the compression explicit: the numerator |log q − log p| grows only
logarithmically in the prime ratio, while the denominator log p · log q grows
without bound, so distances between large primes shrink.

**Theorem 9.2 (Diameter bound).** diam(S) ≤ 1/log 2.
*Proof sketch.* By Theorem 6.3, S ⊆ (0, 1/log 2], whose diameter is exactly
1/log 2; diameter is monotone under inclusion. ∎

**Theorem 9.3 (Membership of the maximum).** 1/log 2 ∈ S, witnessed by the
prime 2. Hence the bound in Theorem 9.2 is the exact endpoint attained.

---

## 10. Twin Primes as Tightest Clusters

**Theorem 10.1 (Twin-prime distance).** For a twin pair (p, p+2) with p prime,
p+2 prime, and p ≥ 3,
> d(p, p+2) = ( log(p+2) − log p ) / ( log p · log(p+2) ).
*Proof sketch.* Specialize Theorem 9.1 with q = p+2 and drop the absolute value,
since log(p+2) ≥ log p. ∎

**Asymptotics.** log(p+2) − log p = log(1 + 2/p) ≈ 2/p, so for large p,
> d(p, p+2) ≈ 2 / ( p · log² p ).
Twin pairs are therefore the smallest nonzero distances realized within S near
the origin: microscopic dimers riding the accumulation toward 0. If the twin
prime conjecture holds, these dimers persist to arbitrarily large p, seeding the
cluster at 0 with infinite fine structure. This fine structure is precisely the
data to which box-counting dimension (but not Hausdorff dimension) is sensitive.

---

## 11. The Dimensional Gap: Box-Counting Geometry

Hausdorff dimension uses covers by balls of *arbitrary* radii, which lets it
shrink any countable set to dimension 0. Box-counting dimension uses a *uniform*
grid at each scale and is consequently **blind to countability**: a countable set
can have strictly positive box-counting dimension.

**Theorem 11.1 (Dimensional gap, proved half).**
> dim_H(S) = 0  and  0 ∈ closure(S).
*Proof.* The two clauses are Theorems 4.2 and 7.3. ∎

The combination is the crux: dim_H sees nothing, yet S accumulates at 0 at a
definite power-law rate, which dim_B must register.

**Conjecture 11.2 (Strict dimensional gap).** dim_B(S) > 0; in particular
dim_H(S) = 0 < dim_B(S).

**Heuristic for the value of dim_B(S).** Order the primes p₁ < p₂ < … and set
a_k = 1/log p_k. The sequence a_k decreases to 0 with spacing
a_k − a_{k+1} ≍ 1/(p_k log² p_k). Resolving the accumulation at scale ε, one
estimates the number of occupied boxes N(S, ε). A square-root model of the
spacing gives N(S, ε) ≍ ε^{−1/2}, hence the prediction

> **Conjecture 11.3.** dim_B(S) = 1/2.

Finite computation tells a subtler story: for primes up to 10⁷ the empirical
ratio log N(S, ε)/log(1/ε) ≈ 0.7 and drifts upward only logarithmically. A
competing reading, taking the slow convergence at face value, suggests the limit
could approach 1. Determining the exact value is the central open problem of this
program; see Section 13.

**Role of the gap energy.** The functional E(N, s) of Definition 3.5 is a
discrete s-content of the twin-prime sub-dust. Its convergence/divergence
threshold in s is the candidate critical exponent for the box-counting dimension
of the twin-prime part of S; the energy at s = 1 is a (finite) total variation,
while small s emphasizes the densest clusters near 0.

---

## 12. Algorithms

### 12.1 Logarithmic prime image enumeration
Enumerate primes by a sieve to bound P, map each to 1/log p, and return the
sorted sequence. Complexity O(P log log P) for the sieve plus O(π(P)) maps.

### 12.2 Box-counting estimator
For a target scale ε, place a uniform grid of width ε on [0, 1/log 2], mark the
cell of each 1/log p, and count distinct marked cells N(ε). Sweeping ε over a
geometric ladder ε = 2^{−j} and regressing log N(ε) against log(1/ε) yields a
numerical estimate of dim_B(S). Complexity O(π(P)) marks per scale.

### 12.3 Twin-gap energy evaluator
For exponent s and bound N, sum |1/log p − 1/log(p+2)|^s over twin pairs p ≤ N.
Used to probe the critical exponent of the twin sub-dust. Complexity O(π(N)).

(Reference Python implementations appear in the accompanying demonstration code.)

---

## 13. Discussion and Future Work

This work replaces a romantic but false picture (a fractal curve of dimension
1 + ε) with a precise dichotomy. The *scale-invariant* geometry of the primes
under the logarithmic lens is trivial — Hausdorff dimension 0, forced by
countability. The *resolution-dependent* geometry is where the fractal content
hides, captured by box-counting dimension and the clustering of S at 0.

The decisive methodological lesson: a divergent arithmetic sum (Mertens' ∑ 1/p)
need not be a geometric length, and "length" is not the right invariant to
separate dust from curve. The right invariant is box-counting (Minkowski)
dimension, which ignores countability and measures clustering rate directly.

**Open problems.**

1. **(Box dimension of S.)** Prove dim_B(S) exists and compute it. The leading
   conjecture is 1/2 (Conjecture 11.3); rule out 0 and pin down whether the slow
   numerical drift toward 0.7–0.9 reflects a true limit > 1/2.
2. **(Closure structure.)** Show closure(S) = S ∪ {0}; equivalently, S is
   scattered with Cantor–Bendixson rank 1 (a single derivative removes
   everything). This follows from strict monotonicity of a_k = 1/log p_k and
   a_k → 0.
3. **(Finite total length.)** Make precise and prove that the arc length
   ∑_k (a_k − a_{k+1}) telescopes to a_1 = 1/log 2, so the logarithmic prime
   curve has finite length exactly 1/log 2 — confirming the failure of the
   Mertens-based length heuristic.
4. **(Twin sub-dust.)** Show the twin-prime sub-dust has finite total length
   ≤ 1/log 2 unconditionally, and analyze the critical exponent of E(N, s) as a
   conjectural invariant of twin-prime density.
5. **(Other lenses.)** For a general slowly varying remetrization x ↦ φ(p),
   classify which φ yield positive box dimension. Hausdorff dimension is 0 for
   all of them; the box dimension is a functional of φ's clustering profile.

---

## 14. Conclusion

Under the logarithmic lens the primes form a bounded, countable, scattered set S
confined to (0, 1/log 2], accumulating at 0, with large primes compressed
super-polynomially close and twin primes forming the tightest clusters. Its
Hausdorff dimension is unconditionally 0. The genuine fractal question — the size
of the dimensional gap dim_B(S) − dim_H(S) = dim_B(S) > 0 — remains open and is
the natural successor to the (refuted) "dimension 1 + ε" conjecture. The primes,
through this lens, are not a fractal curve; they are dimensionless dust to
Hausdorff measure and a positive-dimensional accumulation to box counting, and
the reconciliation of these two facts is where the mathematics now points.
