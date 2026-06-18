# The Code-Size Sandwich: Sphere-Packing and Gilbert–Varshamov Bounds over Finite-Group Alphabets

## Abstract

We develop, from first principles and over an arbitrary finite additive-group
alphabet, the two classical elementary bounds that trap the maximum size of a
block error-correcting code from above and below. Working in the combinatorial
"Library of Babel" model — words are functions from a finite index type to a
finite group, and distance is the Hamming metric — we prove (i) the exact
Hamming-sphere count *C(n, k)(q − 1)ᵏ*; (ii) the closed-form ball-volume formula
*V(t) = Σ_{i≤t} C(n, i)(q − 1)ⁱ*; (iii) the translation invariance of ball
cardinality; (iv) the **sphere-packing (Hamming) upper bound** *|C| · V(t) ≤ qⁿ*
for codes of minimum distance ≥ 2t + 1; (v) the **Gilbert–Varshamov lower bound**
*qⁿ ≤ |C| · V(d − 1)* for codes maximal at minimum distance *d*; and (vi) their
combination, the **code-size sandwich** *|C| · V(t) ≤ qⁿ ≤ |C| · V(2t)* for a
maximal (2t + 1)-code. The conceptual core is a **packing/covering duality**: both
bounds are a single cardinality comparison on a family of equal-volume balls,
differentiated only by whether the balls are pairwise *disjoint* (forced by large
minimum distance) or *covering* (forced by maximality). The entire development
rests on the elementary identity that Hamming distance is the cardinality of a
disagreement set, requires no analytic machinery, and treats the upper and lower
bounds as exact mirror images.

**Keywords:** error-correcting codes, Hamming bound, sphere-packing bound,
Gilbert–Varshamov bound, minimum distance, Hamming metric, packing and covering,
perfect codes.

---

## 1. Introduction

The fundamental quantity of combinatorial coding theory is *A_q(n, d)*, the maximum
number of words of length *n* over a *q*-symbol alphabet such that every two of
them are at Hamming distance at least *d*. Determining *A_q(n, d)* exactly is, in
general, intractable; the practical theory instead proceeds by *bounds* that
bracket it. Two of the most basic and most important are:

- the **sphere-packing (Hamming) bound**, an *upper* bound obtained by packing
  disjoint balls into the ambient space; and
- the **Gilbert–Varshamov (GV) bound**, a *lower* bound obtained because a
  *maximal* separated set must cover the ambient space.

These two bounds were the starting point of the subject in the late 1940s and early
1950s (Hamming 1950; Gilbert 1952; Varshamov 1957), and the still-unclosed gap
between them remains a central organizing problem of the field.

This paper presents a self-contained, fully rigorous treatment of both bounds and
their combination, deliberately stated at a level of generality — an arbitrary
finite additive-group alphabet — that exposes the structural symmetry between them.
Our thesis is methodological as well as mathematical: **the upper and lower bounds
are not two separate theorems but two instances of one counting principle**, the
difference being entirely captured by the dichotomy *disjoint* versus *covering*.

### 1.1 The "Library of Babel" model

Throughout, fix:

- a finite index type *ι* with *n := |ι|* (the *coordinates*, or *positions*);
- a finite additive abelian group *G* with *q := |G|* (the *alphabet*); the group
  structure is used only for the translation-symmetry argument.

A **word** is a function *x : ι → G*. The set of all words has cardinality *qⁿ*.
A **code** is a finite set of words, *C ⊆ (ι → G)*, formally a `Finset`.

---

## 2. Definitions

**Definition 2.1 (Hamming distance).** For words *x, y : ι → G*, the *Hamming
distance* is the number of coordinates at which they differ,
*hammingDist(x, y) := |{ i ∈ ι : x i ≠ y i }|.* Equivalently it is the *Hamming
weight* (number of nonzero coordinates) of *x − y*. It is a metric: nonnegative,
symmetric, zero iff *x = y*, and satisfies the **triangle inequality**
*hammingDist(x, z) ≤ hammingDist(x, y) + hammingDist(y, z)*. The key structural
fact we exploit relentlessly is that **the distance is literally a finite-set
cardinality**, which makes every distance argument a `Finset`-counting argument.

**Definition 2.2 (Hamming ball).** For a centre *x : ι → G* and radius *t ∈ ℕ*, the
*closed Hamming ball* is
*hammingBall(x, t) := { y : ι → G | hammingDist(x, y) ≤ t },*
the set of words obtainable from *x* by altering at most *t* coordinates.

**Definition 2.3 (Minimum distance / separation).** A code *C* is *d-separated*
(has *minimum distance at least d*) if
*∀ x, y ∈ C, x ≠ y ⟹ d ≤ hammingDist(x, y).*

**Definition 2.4 (Maximality).** A code *C* is *maximal* for minimum distance *d*,
written *IsMaximal(C, d)*, if it is *d*-separated and no word can be added while
preserving *d*-separation:
*∀ w : ι → G, w ∉ C ⟹ (∃ c ∈ C, hammingDist(w, c) < d).*
Equivalently: every word outside *C* is within distance *d − 1* of some codeword.

**Definition 2.5 (Ball volume).** Because all balls of a fixed radius are
equinumerous (Theorem 3.2 below), we write *V(t)* for the common cardinality
*|hammingBall(x, t)|*, independent of the centre *x*.

---

## 3. Structural lemmas: symmetry and exact volume

The whole edifice stands on three counting/symmetry results.

### 3.1 Translation invariance

**Theorem 3.1 (Distance is translation-invariant).** For all words *x, y, c*,
*hammingDist(x + c, y + c) = hammingDist(x, y).*

*Proof.* Coordinatewise, *(x + c) i = (y + c) i* iff *x i = y i*, so the
disagreement sets of *(x + c, y + c)* and of *(x, y)* are identical; their
cardinalities therefore coincide. ∎

**Theorem 3.2 (Ball cardinality is centre-independent).** For every centre *x* and
radius *t*, *|hammingBall(x, t)| = |hammingBall(0, t)|.*

*Proof.* The translation map *y ↦ y − x* is a bijection of the word space. By
Theorem 3.1 it carries *hammingBall(x, t)* onto *hammingBall(0, t)*: indeed
*hammingDist(x, y) = hammingDist(0, y − x)*. Being a bijection (its inverse is
*z ↦ z + x*) it is injective, and the image of the ball about *x* is exactly the
ball about *0*. Cardinality is preserved under injective images, giving the
claim. ∎

This is the structural workhorse: it lets us replace the volume of *any* ball by
the single number *V(t) := |hammingBall(0, t)|*, which we now compute in closed
form.

### 3.2 Exact sphere count

**Theorem 3.3 (Hamming-sphere count).** The number of words at Hamming distance
*exactly* *k* from the origin is
*|{ y : hammingDist(0, y) = k }| = C(n, k) · (q − 1)ᵏ,*
where *n = |ι|*, *q = |G|*, and *C(n, k)* is the binomial coefficient.

*Proof sketch.* A word *y* has *hammingDist(0, y) = k* iff its support
*supp(y) := { i : y i ≠ 0 }* has size exactly *k*. Partition the sphere by support:
for each *k*-element subset *T ⊆ ι*, the words with support *exactly T* are in
bijection with the functions *T → (G ∖ {0})* (assign to each coordinate of *T* a
nonzero symbol, and 0 elsewhere), of which there are *(q − 1)ᵏ*. There are
*C(n, k)* such subsets *T*, and the corresponding word-classes are pairwise
disjoint, so the sphere decomposes as a disjoint union over the size-*k* subsets:
*|sphere(k)| = Σ_{|T| = k} (q − 1)ᵏ = C(n, k) · (q − 1)ᵏ.* The formal proof realizes
each step as a `Finset.card_bij` / `Finset.card_biUnion` computation. ∎

### 3.3 Closed-form ball volume

**Theorem 3.4 (Ball-volume formula).** For every radius *t*,
*V(t) = Σ_{i = 0}^{t} C(n, i) · (q − 1)ⁱ.*

*Proof.* The closed ball of radius *t* is the disjoint union of the spheres of
radii *0, 1, …, t*. By Theorem 3.3 the *i*-th sphere has *C(n, i)(q − 1)ⁱ* words;
summing the disjoint pieces gives the stated total. ∎

---

## 4. The upper bound: sphere-packing

### 4.1 Packing disjointness

**Lemma 4.1 (Packing disjointness).** If *C* has minimum distance at least
*2t + 1*, then the radius-*t* balls about distinct codewords are pairwise disjoint:
for *c ≠ c′* in *C*, *hammingBall(c, t) ∩ hammingBall(c′, t) = ∅.*

*Proof.* Suppose a word *y* lay in both balls, so *hammingDist(c, y) ≤ t* and
*hammingDist(c′, y) ≤ t*. By the triangle inequality and symmetry,
*hammingDist(c, c′) ≤ hammingDist(c, y) + hammingDist(y, c′) ≤ t + t = 2t,*
contradicting *2t + 1 ≤ hammingDist(c, c′)*. Hence no such *y* exists. ∎

### 4.2 The Hamming bound

**Theorem 4.2 (Sphere-packing / Hamming bound).** If *C* has minimum distance at
least *2t + 1*, then *|C| · V(t) ≤ qⁿ.*

*Proof.* Consider the union *S := ⋃_{c ∈ C} hammingBall(c, t)*. By Lemma 4.1 this
union is disjoint, so its cardinality is the sum of the ball cardinalities; by
Theorem 3.2 every ball has cardinality *V(t)*; thus *|S| = |C| · V(t)*. Since *S*
is a subset of the whole word space, *|S| ≤ qⁿ*, giving *|C| · V(t) ≤ qⁿ*. ∎

**Corollary 4.3 (Closed-form Hamming bound).** With the same hypotheses,
*|C| · ( Σ_{i=0}^{t} C(n, i)(q − 1)ⁱ ) ≤ qⁿ.*

*Proof.* Substitute Theorem 3.4 into Theorem 4.2 and rewrite *|ι → G| = qⁿ*. ∎

---

## 5. The lower bound: Gilbert–Varshamov

The upper bound used disjointness. The lower bound is its exact dual: it uses
*covering*. The pivot is the elementary but powerful observation that maximality is
precisely a covering condition.

### 5.1 Maximal codes cover the space

**Lemma 5.1 (Covering lemma).** If *IsMaximal(C, d)*, then the radius-(*d − 1*)
balls about the codewords cover the whole word space:
*⋃_{c ∈ C} hammingBall(c, d − 1) = (ι → G),*
i.e. every word is within Hamming distance *d − 1* of some codeword.

*Proof.* Let *w* be any word. If *w ∈ C*, then *w ∈ hammingBall(w, d − 1)* trivially
(distance 0). If *w ∉ C*, maximality (Definition 2.4) yields a codeword *c ∈ C* with
*hammingDist(w, c) < d*, i.e. *hammingDist(c, w) ≤ d − 1*, so *w ∈ hammingBall(c,
d − 1)*. In either case *w* lies in one of the balls. ∎

This is the precise logical content of "no further word can be added": the obstacle
to adding a word *w* is exactly that *w* is already too close (within *d − 1*) to an
existing codeword, which is to say that *w* is already covered.

### 5.2 The Gilbert–Varshamov bound

**Theorem 5.2 (Gilbert–Varshamov bound).** If *IsMaximal(C, d)*, then
*qⁿ ≤ |C| · V(d − 1).*

*Proof.* By Lemma 5.1 the radius-(*d − 1*) balls cover the whole space, so
*qⁿ = |⋃_{c ∈ C} hammingBall(c, d − 1)|.* The cardinality of a union is at most the
sum of the cardinalities (subadditivity, with equality only when disjoint), and by
Theorem 3.2 every ball has cardinality *V(d − 1)*; hence
*qⁿ ≤ Σ_{c ∈ C} |hammingBall(c, d − 1)| = |C| · V(d − 1).* ∎

**Remark 5.3 (Why maximality is essential).** The GV inequality is *false* for
arbitrary *d*-separated codes: the singleton code *{0}* is *d*-separated for every
*d*, yet covers only one ball, and *qⁿ ≤ 1 · V(d − 1)* fails as soon as *V(d − 1) <
qⁿ*. Maximality is exactly the hypothesis that upgrades "separated" to "covering",
and it cannot be dropped.

**Corollary 5.4 (Closed-form GV bound).** If *IsMaximal(C, d)*, then
*qⁿ ≤ |C| · ( Σ_{i=0}^{d−1} C(n, i)(q − 1)ⁱ ).*

*Proof.* Substitute Theorem 3.4 into Theorem 5.2. ∎

---

## 6. The code-size sandwich

Combining the two bounds for a single code yields the headline result.

**Theorem 6.1 (Code-size sandwich).** Let *C* be a code that is maximal for minimum
distance *2t + 1* (so it is *(2t + 1)*-separated and maximal). Then
*|C| · V(t) ≤ qⁿ ≤ |C| · V(2t).*

*Proof.* The left inequality is Theorem 4.2 applied with radius *t* (the minimum
distance is exactly *2t + 1 ≥ 2t + 1*). The right inequality is Theorem 5.2 applied
with *d = 2t + 1*, since then *d − 1 = 2t*. ∎

**Corollary 6.2 (Two-sided size estimate).** Under the hypotheses of Theorem 6.1,
*qⁿ / V(2t) ≤ |C| ≤ qⁿ / V(t).* The multiplicative gap between the two estimates is
exactly the volume ratio *V(2t)/V(t)*, which by Theorem 3.4 is the explicit ratio of
two truncated binomial sums.

**Corollary 6.3 (Fully explicit sandwich).** Under the hypotheses of Theorem 6.1,
*|C| · ( Σ_{i=0}^{t} C(n,i)(q−1)ⁱ ) ≤ qⁿ ≤ |C| · ( Σ_{i=0}^{2t} C(n,i)(q−1)ⁱ ).*

This pins the size of an optimal *t*-error-correcting code between two quantities
that depend only on *n*, *q*, and *t*, with no reference to the (generally unknown)
code itself.

---

## 7. The packing/covering duality

The two bounds are structurally identical and differ in exactly one respect. Both
form the family of equal-volume balls *{ hammingBall(c, r) }_{c ∈ C}* and compare
the cardinality of their union *S* to that of the ambient space. The difference:

| | Upper bound (Hamming) | Lower bound (GV) |
|---|---|---|
| Radius | *t* | *d − 1* |
| Geometric fact | balls **disjoint** | balls **cover** |
| Forced by | min distance ≥ 2t + 1 | maximality |
| Cardinality identity | *\|S\| = \|C\| · V(t)* | *\|S\| = qⁿ* |
| Inequality used | *\|S\| ≤ qⁿ* (subset) | *\|S\| ≤ Σ \|balls\|* (subadditivity) |
| Direction | *\|C\| · V(t) ≤ qⁿ* | *qⁿ ≤ \|C\| · V(d−1)* |

The duality is total: *disjoint-and-count* gives the ceiling, *cover-and-count*
gives the floor. Translation invariance (Theorem 3.2) supplies the common volume in
both. This is why the two bounds, historically discovered separately and often
taught as unrelated, are here a single idea applied in two directions.

### 7.1 The meeting point: perfect codes

Equality in the sphere-packing bound, *|C| · V(t) = qⁿ*, occurs precisely when the
radius-*t* balls are simultaneously disjoint **and** covering — that is, when they
**tile** (partition) the space. Such codes are the **perfect codes**: every word
lies in exactly one codeword's ball, so nearest-neighbour decoding never
encounters an ambiguous word. For a perfect *(2t + 1)*-code the entire sandwich of
Theorem 6.1 collapses to the single equality *|C| · V(t) = qⁿ = |C| · V(2t)*, which
forces *V(t) = V(2t)* and hence (combinatorially) constrains *t* and the parameters
severely. The classical perfect codes — the Hamming codes (single-error-correcting,
*t = 1*), the binary [23, 12, 7] Golay code and the ternary [11, 6, 5] Golay code
(*t = 3* and *t = 2* respectively) — are the only nontrivial perfect codes over
finite fields, a celebrated rigidity theorem (van Lint, Tietäväinen). They sit
exactly at the point where our two inequalities coincide.

---

## 8. Algorithms

The proofs are constructive enough to yield directly executable procedures, which
we describe abstractly here (and implement in the accompanying demonstration code).

**Algorithm A — Ball-volume evaluation.** Compute *V(t) = Σ_{i=0}^{t}
C(n,i)(q−1)ⁱ* by accumulating binomial terms. Complexity *O(t)* multiplications
with incremental binomial updates, *O(t · M(n))* with naïve factorials.

**Algorithm B — Sandwich evaluation.** Given *(n, q, t)* and a candidate code size
*M*, report the sandwich verdict by comparing *M · V(t)*, *qⁿ*, and *M · V(2t)*.
Complexity dominated by the two volume evaluations, *O(t)*.

**Algorithm C — Greedy maximal code (Gilbert–Varshamov construction).** Enumerate
the word space in any fixed order; greedily insert each word that is at distance
≥ *d* from all already-accepted codewords. The output is a *d*-separated maximal
code, which by Theorem 5.2 satisfies *qⁿ ≤ |C| · V(d − 1)*. Complexity *O(qⁿ · |C|
· n)* in the worst case (each candidate checked against all current codewords). This
algorithm *attains* the GV lower bound, demonstrating that it is not vacuous.

---

## 9. Applications

- **Channel design and benchmarking.** The sandwich gives, for any target
  error-correction radius *t*, both the maximum achievable code size (rate ceiling)
  and a guaranteed-achievable size (rate floor), letting engineers gauge how close a
  proposed code is to optimal before construction.
- **Existence guarantees.** The GV bound certifies that *good codes exist* with size
  at least *qⁿ / V(d − 1)*, underpinning the probabilistic and greedy constructions
  used throughout coding practice (e.g., the existence of long codes meeting the GV
  rate).
- **Deep-space and storage codes.** Perfect and near-perfect codes — the equality
  case of the sandwich — are exactly the codes prized in extreme-reliability
  settings; the Golay code famously protected the Voyager imaging data.
- **Cryptography.** Code-based cryptosystems (McEliece) rely on parameters chosen
  with these bounds to balance decoding hardness against error-correction capacity.

---

## 10. Discussion

The treatment above is deliberately *minimal* in its hypotheses: the alphabet need
only be a finite additive abelian group (the group law is used only to slide balls
in Theorem 3.2), and no field, ring, or linearity of the code is assumed. This is
slightly more general than the usual textbook setting of a finite field alphabet,
and it isolates the precise structural ingredient each bound requires:

- The **sphere-packing bound** needs only the metric (triangle inequality) plus
  translation invariance of volume.
- The **Gilbert–Varshamov bound** needs only the metric plus the *logical* content
  of maximality; volume invariance again supplies the common ball size.

Neither bound needs the ball-volume *formula* (Theorem 3.4) — the abstract volume
*V(·)* suffices — but the formula converts the bounds into the fully explicit
numeric inequalities (Corollaries 4.3, 5.4, 6.3) that practitioners actually use.

The remaining gap between the bounds, *V(2t)/V(t)*, is the quantitative expression
of the central open problem of the field: closing the asymptotic gap between the GV
rate and the sphere-packing rate.

---

## 11. Future work

The following directions extend the present architecture; each is precisely
stateable and can be settled (proved or refuted) within the same combinatorial
framework.

**(1) Greedy existence — the GV bound is attained.** The GV bound is currently
conditional on *IsMaximal(C, d)*. Discharge that hypothesis unconditionally: for
all *n, q, d* there *exists* a maximal *d*-code, hence a code with *qⁿ ≤ |C|·V(d −
1)*. The key idea is that maximality is an existence statement on the finite subset
lattice — start from ∅ and insert any admissible word until none remain; finiteness
guarantees termination at a maximal code. The missing piece is a single
greedy-termination lemma by well-founded recursion on the number of insertable
words.

**(2) The Plotkin bound via double counting.** Conjecture: if *q·d > (q − 1)·n*
then any *d*-separated code satisfies the integer Plotkin bound *|C|·(q·d − (q −
1)·n) ≤ q·d*. The key idea is a double count of *Σ_{x,y ∈ C} hammingDist(x, y)*:
per coordinate each contributes at most *(1 − 1/q)·|C|²* disagreements, while
separation forces the total to be at least *d·|C|·(|C| − 1)*; comparing the two
pins *|C|*. The per-coordinate decomposition *hammingDist(x, y) = Σ_i [x i ≠ y i]*
is exactly the `Finset.filter`-cardinality identity used throughout.

**(3) Asymptotic rate versus the entropy bound.** With relative distance *δ = d/n*
and rate *R = log_q |C| / n*, the ball-volume formula yields the GV rate *R ≥ 1 −
H_q(δ) − o(1)* and the sphere-packing bound yields the envelope *R ≤ 1 − H_q(δ/2) +
o(1)*, where *H_q* is the *q*-ary entropy. The key idea is that the exact sum
*V(r) = Σ_{k≤r} C(n,k)(q−1)ᵏ* is squeezed between *q^{n·H_q(r/n)}* up to a
polynomial factor, reducing the asymptotics to an entropy estimate of a truncated
binomial sum.

**(4) The Singleton bound and MDS codes.** For any *d*-separated code with *1 ≤ d ≤
n*, *|C| ≤ qⁿ⁻ᵈ⁺¹*, with equality (MDS codes, e.g. Reed–Solomon) iff the
restriction of *C* to any *n − d + 1* coordinates is a bijection. The key idea is
that erasing *d − 1* coordinates cannot collide two codewords (they differ in ≥ *d*
positions), so the projection onto the remaining *n − d + 1* coordinates is
injective — a *metric* hypothesis becomes a *cardinality* statement via injectivity
of a projection. Notably this requires neither group structure nor the ball-volume
formula, and holds without the classical *1 ≤ d* hypothesis.

**(5) Perfect codes and the equality case.** Characterize equality in the
sphere-packing bound: *|C|·V(t) = qⁿ* iff the radius-*t* balls partition the space
(a perfect code). The key idea is that the shared geometric witnesses — disjointness
for the upper bound, covering for the lower — coincide exactly when the balls tile,
collapsing the sandwich to a single value. This amounts to tracking when the
subset/subadditivity inequalities in §4–§5 become equalities.

---

## 12. Conclusion

We have given a unified, elementary, and fully general derivation of the
sphere-packing and Gilbert–Varshamov bounds and their combination into the
code-size sandwich *|C|·V(t) ≤ qⁿ ≤ |C|·V(2t)*. The development makes vivid a
single principle — *count a family of equal-volume balls* — whose two readings,
*disjoint* (packing) and *covering*, produce the upper and lower bounds
respectively. Translation invariance supplies the common ball volume; the
binomial sphere count makes everything explicit; and the equality case identifies
the perfect codes as the exact meeting point of the two halves. The result is a
complete, self-contained account of how tightly reliable communication can be
packed into a finite universe of messages.

---

## References (classical, for context)

- R. W. Hamming, *Error detecting and error correcting codes*, Bell System
  Technical Journal, 1950.
- E. N. Gilbert, *A comparison of signalling alphabets*, Bell System Technical
  Journal, 1952.
- R. R. Varshamov, *Estimate of the number of signals in error correcting codes*,
  1957.
- J. H. van Lint, *Introduction to Coding Theory*, Springer.
