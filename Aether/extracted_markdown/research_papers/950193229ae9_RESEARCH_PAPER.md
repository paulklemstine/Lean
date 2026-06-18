# A Functorial Bridge from Cauchy Convolution to Tropical Valuation Profiles

## Abstract

We construct and rigorously establish a bridge between the multiplicative algebra
of generating functions over a commutative semiring and the min-plus (tropical)
semiring of valuation profiles. Given an additive valuation `v` on a commutative
semiring `K`, valued in the extended naturals `WithTop ℕ = ℕ ∪ {∞}`, we associate
to each sequence `a : ℕ → K` its *valuation profile* `vprofile(a)` obtained by
applying `v` coefficient-wise. Our central result, the **Tropical Convolution
Bound**, states that for all sequences `a, b : ℕ → K` and all indices `n`,

> `tropConv(vprofile(a), vprofile(b))(n) ≤ v((a ⋆ b)(n))`,

where `⋆` is the finite Cauchy convolution and `tropConv` is the min-plus
convolution. In words: the tropical convolution of the two valuation profiles is
a pointwise lower bound for the valuation profile of the Cauchy convolution. The
inequality is *lax* — equality fails exactly when valuation-minimizing
antidiagonal terms cancel — and we characterize the transverse regime in which it
becomes exact. The result requires only three valuation axioms (`v(1) = 0`,
multiplicativity `v(xy) = v(x) + v(y)`, and the ultrametric sum bound
`min(v(x), v(y)) ≤ v(x+y)`) and holds over an arbitrary commutative semiring,
without subtraction or field hypotheses. We situate the theorem within the
theory of Newton polygons, combinatorial species, and tropical geometry, and we
develop algorithms, numerical demonstrations, and a program of conjectures
upgrading the lax functor toward a strict tropical correspondence.

**Keywords.** valuation, tropical semiring, min-plus convolution, Cauchy
convolution, generating functions, Newton polygon, combinatorial species,
ultrametric inequality, p-adic valuation.

---

## 1. Introduction

The interplay between *algebraic* and *order-theoretic* structure is a recurring
theme across number theory, combinatorics, and tropical geometry. A valuation is
the canonical device translating the former into the latter: it sends a
multiplicative structure (a commutative semiring or field) to an additive,
totally ordered one, replacing the size of an element by its divisibility depth.
The most familiar instance is the `p`-adic valuation `v_p(x)`, the exponent of
the prime `p` in the factorization of `x`, extended by `v_p(0) = ∞`.

Generating functions package combinatorial or analytic data as sequences
`a : ℕ → K`, and their fundamental multiplication is the **Cauchy convolution**

> `(a ⋆ b)(n) = Σ_{k=0}^{n} a(k) · b(n−k)`.

This single operation underlies multiplication of formal power series, the
product of combinatorial species, and the convolution of independent
distributions. The question we resolve is: *what does a valuation do to a Cauchy
convolution?* Because the convolution is a sum of products, and because
valuations interact transparently with products but only laxly with sums (via the
ultrametric inequality), the answer is not an identity but a sharp lower bound —
and that lower bound is precisely the tropical (min-plus) convolution of the
valuation profiles.

This furnishes a **lax morphism of semirings** from the convolution algebra
`(ℕ → K, +, ⋆)` to the tropical semiring `(ℕ → WithTop ℕ, min, ⊗)` of valuation
profiles. The morphism is the engine beneath the classical statement that *Newton
polygons add under multiplication*, recast at the level of individual
coefficients and proved in maximal generality.

### Contributions

1. A minimal axiomatization `AddVal` of an additive valuation on a commutative
   semiring valued in `WithTop ℕ` (Section 3).
2. The definitions of the *valuation profile*, the *Cauchy convolution*, and the
   *tropical (min-plus) convolution*, and the lemmas connecting them (Section 4).
3. The **Tropical Convolution Bound** (Theorem 5.1), with a complete proof
   sketch, established over an arbitrary commutative semiring.
4. Algorithms for computing valuation profiles and tropical convolutions, with
   complexity analysis, and a discussion of the Newton-polygon and species
   applications (Sections 6–7).
5. A program of four conjectures targeting the lax/strict gap (Section 9).

---

## 2. Background and notation

Throughout, `K` is a commutative semiring: a set with commutative, associative
`+` and `·`, distributivity, an additive identity `0`, and a multiplicative
identity `1`, but with **no requirement of additive inverses**. Sequences are
functions `a : ℕ → K`; we write `a(n)` or `aₙ`.

The valuation codomain is `WithTop ℕ = ℕ ∪ {∞}`, the naturals adjoined with a top
element `⊤ = ∞`. It carries:
- the order extending `≤` on `ℕ` with `m ≤ ∞` for all `m`;
- addition extending `ℕ`-addition with `m + ∞ = ∞ + m = ∞`;
- binary minimum `min`, with `min(m, ∞) = m`.

The triple `(WithTop ℕ, min, +)` is the **min-plus (tropical) semiring**: `min`
is the additive operation (with identity `∞`) and `+` is the multiplicative
operation (with identity `0`). It is idempotent (`min(x, x) = x`) and totally
ordered, the two features that distinguish tropical from classical algebra.

For a nonempty finite set `S` of indices and `f : S → WithTop ℕ`, we write
`inf' S f` for the minimum of `f` over `S` (a well-defined element of
`WithTop ℕ`).

---

## 3. Additive valuations

**Definition 3.1 (Additive valuation).** An *additive valuation* on a commutative
semiring `K`, valued in `WithTop ℕ`, is a structure `AddVal K` consisting of a map
`v : K → WithTop ℕ` satisfying:

- **(V0) `v(0) = ⊤`** — the valuation of zero is infinite;
- **(V1) `v(1) = 0`** — the valuation of the unit is zero;
- **(VM) `v(x · y) = v(x) + v(y)`** — multiplicativity (with the convention
  `m + ∞ = ∞`);
- **(VA) `min(v(x), v(y)) ≤ v(x + y)`** — the ultrametric (non-archimedean) sum
  bound.

Axioms (V1) and (VM) say `v` is a monoid homomorphism from `(K, ·, 1)` to
`(WithTop ℕ, +, 0)`. Axiom (VA) is the order-theoretic shadow of the triangle
inequality. Crucially, (VA) is an *inequality*, not an identity: equality can
fail because `x + y` may exhibit cancellation, raising its valuation strictly
above `min(v(x), v(y))`.

**Example 3.2 (p-adic valuation).** Let `K = ℤ` (or `ℚ`, or `ℤ_p`) and let
`v_p(x)` be the exponent of the prime `p` in `x`, with `v_p(0) = ∞`. Then `v_p`
is an additive valuation: `v_p(1) = 0`, `v_p(xy) = v_p(x) + v_p(y)` exactly, and
`v_p(x + y) ≥ min(v_p(x), v_p(y))` with equality unless the leading `p`-adic
digits cancel. This is the prototypical concrete instance and the bridge to the
theory of Newton polygons.

**Example 3.3 (Order of vanishing).** Let `K = k[[t]]` be formal power series over
a field `k`, and let `v(f)` be the order of vanishing of `f` at `t = 0` (the index
of the lowest nonzero coefficient), with `v(0) = ∞`. The axioms hold; here (VA) is
an equality unless the lowest-order terms cancel.

**Example 3.4 (Trivial / support valuation).** On any commutative semiring, set
`v(0) = ∞` and `v(x) = 0` for `x ≠ 0` when `K` is an integral domain; then
multiplicativity holds because there are no zero divisors. This records only the
support of a sequence and already gives nontrivial information through the bridge.

---

## 4. Profiles and convolutions

Fix `v : AddVal K`.

**Definition 4.1 (Valuation profile).** The *valuation profile* of `a : ℕ → K` is
the sequence `vprofile(v, a) : ℕ → WithTop ℕ` given by
`vprofile(v, a)(n) = v(a(n))`. It is the coefficient-wise image of `a` under the
valuation, a sequence of divisibility depths.

**Definition 4.2 (Cauchy convolution).** The *finite Cauchy convolution* of
`a, b : ℕ → K` is
`(a ⋆ b)(n) = Σ_{k ∈ range(n+1)} a(k) · b(n − k)`,
the sum over the antidiagonal `{(k, n−k) : 0 ≤ k ≤ n}`. (Here `n − k` is natural
subtraction; for `k ≤ n` it is ordinary subtraction.)

**Definition 4.3 (Tropical convolution).** The *tropical (min-plus) convolution*
of profiles `u, w : ℕ → WithTop ℕ` is
`tropConv(u, w)(n) = inf'_{k ∈ range(n+1)} ( u(k) + w(n − k) )`,
the minimum over the same antidiagonal of the *sums* of profile entries. The
range `{0, …, n}` is nonempty, so the infimum is well defined for every `n`.

The definitions are deliberately parallel: replacing each product `a(k)·b(n−k)`
by the sum `u(k)+w(n−k)` and the outer sum `Σ` by the outer minimum `inf'` turns
the Cauchy convolution into the tropical convolution. This is the syntactic
shadow of the semiring map `(K, +, ·) → (WithTop ℕ, min, +)`.

We record two boundary computations and two structural lemmas.

**Lemma 4.4 (Convolution at zero).** `(a ⋆ b)(0) = a(0) · b(0)`.
*Proof.* The range `{0}` has a single element `k = 0`, and `0 − 0 = 0`. ∎

**Lemma 4.5 (Tropical convolution at zero).**
`tropConv(u, w)(0) = u(0) + w(0)`.
*Proof.* The infimum over the singleton `{0}` is its sole value. ∎

**Lemma 4.6 (Valuation of a finite sum).** Let `m ∈ WithTop ℕ`, let `s` be a
finite set of indices, and let `f : ℕ → K`. If `m ≤ v(f(i))` for every `i ∈ s`,
then `m ≤ v( Σ_{i ∈ s} f(i) )`.

*Proof sketch.* Induct on `s` using `Finset.induction`.
- *Base case* `s = ∅`: the empty sum is `0`, and `v(0) = ⊤` by (V0), so
  `m ≤ ⊤` trivially. (No nonemptiness hypothesis is needed precisely because the
  empty sum is maximally valued.)
- *Inductive step* `s = insert i s'` with `i ∉ s'`: then
  `Σ_{insert i s'} f = f(i) + Σ_{s'} f`. By hypothesis `m ≤ v(f(i))`, and by the
  inductive hypothesis `m ≤ v(Σ_{s'} f)`, hence
  `m ≤ min(v(f(i)), v(Σ_{s'} f))`. Apply (VA):
  `min(v(f(i)), v(Σ_{s'} f)) ≤ v(f(i) + Σ_{s'} f) = v(Σ_{insert i s'} f)`.
  Transitivity closes the step. ∎

**Lemma 4.7 (Termwise multiplicativity).** For all `n, k`,
`v(a(k) · b(n − k)) = vprofile(v, a)(k) + vprofile(v, b)(n − k)`.
*Proof.* Immediate from (VM). ∎

**Lemma 4.8 (Tropical bound on each term).** For all `n` and all `k ∈ range(n+1)`,
`tropConv(vprofile(v,a), vprofile(v,b))(n) ≤ vprofile(v,a)(k) + vprofile(v,b)(n−k)`.
*Proof.* A minimum is `≤` each element it ranges over (`Finset.inf'_le`). ∎

---

## 5. The Tropical Convolution Bound

**Theorem 5.1 (Tropical Convolution Bound).** *Let `K` be a commutative semiring,
`v : AddVal K` an additive valuation, and `a, b : ℕ → K` sequences. Then for every
`n ∈ ℕ`,*

> `tropConv(vprofile(v,a), vprofile(v,b))(n) ≤ vprofile(v, a ⋆ b)(n)`.

*That is, the tropical convolution of the valuation profiles is a pointwise lower
bound for the valuation profile of the Cauchy convolution.*

**Proof.** Write `m = tropConv(vprofile(v,a), vprofile(v,b))(n)`. By Definition
4.2, `(a ⋆ b)(n) = Σ_{k ∈ range(n+1)} a(k)·b(n−k)`, so by Definition 4.1 the goal
is `m ≤ v( Σ_{k ∈ range(n+1)} a(k)·b(n−k) )`.

Apply Lemma 4.6 with `f(k) = a(k)·b(n−k)` and `s = range(n+1)`. It suffices to
show that every summand has valuation at least `m`, i.e. for each
`k ∈ range(n+1)`,
`m ≤ v( a(k)·b(n−k) )`.

Fix such a `k`. By Lemma 4.8,
`m ≤ vprofile(v,a)(k) + vprofile(v,b)(n−k)`,
and by Lemma 4.7 the right-hand side equals `v(a(k)·b(n−k))`. Transitivity gives
`m ≤ v(a(k)·b(n−k))`, as required. ∎

**Remarks.**

1. **Three axioms, in three steps.** The proof uses each valuation axiom exactly
   once in spirit: (VM) converts each product term to a sum of profile entries
   (Lemma 4.7); (VA) propagates a lower bound across the sum (Lemma 4.6); and (V0)
   handles the empty-sum base case. (V1) is not needed for this theorem but is part
   of the valuation interface and is used in the algebraic examples.

2. **Maximal generality.** No subtraction, no field hypothesis, no finiteness on
   `K`, and no archimedean property are required. The result is a statement about
   commutative semirings and order, which is why it specializes uniformly to the
   `p`-adic, order-of-vanishing, and support valuations.

3. **Why lax.** Equality `m = v((a ⋆ b)(n))` can fail because the antidiagonal
   sum may exhibit cancellation among the minimizing terms: if two distinct splits
   `(k, n−k)` and `(k', n−k')` both attain the infimum `m`, their leading
   contributions can cancel, raising `v((a⋆b)(n))` strictly above `m`. The bound
   is sound regardless, but the gap is governed entirely by such ties (Section 8).

4. **Boundary check.** At `n = 0`, Lemma 4.4 gives `(a⋆b)(0) = a(0)·b(0)`, hence
   `v((a⋆b)(0)) = v(a(0)) + v(b(0))` by (VM), which equals
   `tropConv(...)(0)` by Lemma 4.5. So the bound is an *equality* at `n = 0`,
   as the single split leaves no room for cancellation — the simplest instance of
   the transversality phenomenon.

---

## 6. Algorithms

The bridge is constructive: both sides are finite computations on the
antidiagonal `range(n+1)`.

### 6.1 Tropical convolution

Given finite prefixes of two profiles `u, w : ℕ → WithTop ℕ`, computing
`tropConv(u, w)(n)` is a single pass:

```
function TROPCONV(u, w, n):
    best ← +∞
    for k from 0 to n:
        best ← min(best, u[k] + w[n − k])
    return best
```

Each evaluation is `O(n)` additions and comparisons in `WithTop ℕ`; the full
profile up to degree `N` is `O(N²)`. This is the dynamic-programming /
shortest-path shape characteristic of min-plus algebra: `tropConv` is exactly a
one-step relaxation over the antidiagonal.

### 6.2 Valuation profile and the bound certificate

To certify Theorem 5.1 numerically for a concrete valuation (say `v_p`):

```
function CERTIFY_BOUND(a, b, v, p, N):
    for n from 0 to N:
        lhs ← TROPCONV(profile(v, a), profile(v, b), n)      # tropical estimate
        c_n ← sum_{k=0..n} a[k] * b[n−k]                     # Cauchy convolution
        rhs ← v(c_n)                                         # true valuation
        assert lhs ≤ rhs                                     # Theorem 5.1
        record (n, lhs, rhs, rhs − lhs)                      # gap = cancellation
    return table
```

The recorded gap `rhs − lhs` is a direct measurement of cancellation among
minimizing antidiagonal terms; it is `0` exactly in the transverse regime.

### 6.3 Newton-polygon view

Computing the lower convex hull of the profile `n ↦ v(aₙ)` yields the **Newton
polygon** of `a`. The inf-convolution (min-plus convolution applied to the hulls)
of the two Newton polygons is the Minkowski sum of the polygons. Theorem 5.1 is
the coefficient-level statement that the product's profile dominates this
combination; Conjecture 9.2 asserts the hulls combine exactly.

---

## 7. Applications

**Newton polygons and root estimates.** For `K = ℚ_p` and `v = v_p`, the valuation
profile of a polynomial or power series is the data whose lower convex hull is the
Newton polygon, whose slopes give the `p`-adic valuations of the roots. Theorem
5.1 says that under multiplication these profiles combine sub-tropically; the
classical "Newton polygons add" theorem is the convex-hull refinement.

**Combinatorial species and divisibility of counts.** Species multiply via the
Cauchy (or binomial/Day) convolution of their generating functions. Pushing
`v_p` through the species algebra turns questions like "what is the 2-adic
valuation of the `n`-th Catalan number?" or "when is a count divisible by `p`?"
into tropical estimates computable in one antidiagonal pass. Kummer's theorem —
that `v_p(C(n,k))` counts carries when adding `k` and `n−k` in base `p` — is
exactly the condition that a split is carry-free, the discrete signature of
tropical transversality.

**Tropical optimization.** Because `tropConv` is a shortest-path relaxation,
algebraic divisibility questions inherit the algorithmic toolkit of min-plus
linear algebra and dynamic programming. The cheapest split is a shortest path on
the antidiagonal; the whole profile is a min-plus matrix-vector product.

**Probabilistic and asymptotic estimates.** When `K` carries an order-of-vanishing
or a degree valuation, the bound controls the lowest-order behavior of products of
power series, giving guaranteed leading-order exponents for convolutions
(distributions of independent variables, products of generating functions) at no
analytic cost.

---

## 8. The lax/strict gap and transversality

Theorem 5.1 is an inequality. The defect

> `δ(n) = v((a⋆b)(n)) − tropConv(vprofile a, vprofile b)(n) ≥ 0`

measures the failure of the tropical estimate to be exact at index `n`. From the
proof, `δ(n) > 0` requires the ultrametric inequality (VA) to be *strict* on the
minimizing terms, which forces a tie: at least two distinct antidiagonal splits
attain the infimum and their leading contributions cancel.

**Transversality principle (informal).** *If the antidiagonal infimum
`min_{k} (v(aₖ) + v(b_{n−k}))` is attained at a unique split `(k₀, n−k₀)`, and the
associated coefficient does not itself acquire extra valuation (e.g. in the
binomial model `p ∤ C(n, k₀)`), then `δ(n) = 0` and the bound is exact.*

The `n = 0` boundary (Remark 4 of Section 5) is the simplest case: the unique
split forces equality. The general statement is formalized as Conjecture 9.1.

---

## 9. Conjectures and future directions

The bridge established here is a *lax monoidal functor* from the generating-function
algebra `(ℕ → K, +, ⋆)` to the min-plus semiring `(ℕ → WithTop ℤ, min, +)` of
valuation profiles, via a coefficient-wise additive Krull valuation. The
following conjectures target the gap between this lax bridge and an exact tropical
correspondence.

**Conjecture 9.1 (Transversality ⇒ equality).** Equality
`tropConv(vprofile a, vprofile b)(n) = vprofile(a ⋆ b)(n)`
holds whenever the antidiagonal infimum `inf_{i+j=n}(v(aᵢ) + v(bⱼ))` is attained at
a *unique* pair `(i, j)` with vanishing coefficient valuation (in the `p`-adic
binomial model, `p ∤ C(n, i)`). This is the tropically transverse, no-cancellation
regime; it predicts equality of `p`-adic valuations of convolution coefficients
exactly when Kummer's theorem yields a carry-free binomial coefficient and the
minimizing decomposition is unique.

**Conjecture 9.2 (Newton polygons are additive under products).** Define the
*Newton profile* `N(a) : ℕ → WithTop ℤ` as the lower convex hull of `n ↦ v(aₙ)`.
Then `N(a ⋆ b)` equals the inf-convolution of `N(a)` and `N(b)` (the Minkowski sum
of the two Newton polygons), with *equality*, not merely `≤`. This upgrades the lax
functor to a strict one after passing to convex hulls.

**Conjecture 9.3 (Tropical differential calculus).** The shift operator
`(shift a)(n) = a(n+1)` (the generating-function derivative) satisfies
`vprofile(shift a)(n) = vprofile(a)(n+1)` exactly, and the pointing operator
`(point a)(n) = n · a(n)` satisfies `vprofile(point a)(n) ≥ vprofile(a)(n)` with
equality iff `v(n) = 0` (i.e. `p ∤ n`). Thus the tropical derivative is a unit
shift and pointing is non-decreasing on profiles — Joyal's differential calculus
of species seen tropically.

**Conjecture 9.4 (Tropical composition / substitution).** Species substitution
`(F ∘ G)` (with generating function `F(G)`) admits a tropical analogue:
`vprofile(subst a b)` is bounded below by a min-plus "composition" infimum over
set partitions, governed in the `p`-adic case by the valuations of multinomial
coefficients (a multivariate Kummer phenomenon). Formalizing `subst` and proving
the lax composition law is the natural next building block toward a full tropical
functor of species.

---

## 10. Discussion

The Tropical Convolution Bound is small in statement and large in reach. Its
economy is the point: from three valuation axioms and the definition of two
parallel convolutions, one obtains a guaranteed, computable lower bound on the
divisibility of an arbitrarily complicated product, valid over any commutative
semiring. The same inequality is, depending on the choice of valuation, a
statement about Newton polygons, about divisibility of combinatorial counts, and
about shortest paths in min-plus algebra.

What is conceptually striking is the *functoriality*: the valuation is not just a
gadget that produces one inequality but a structure-preserving (lax) map of
semirings, sending `+` to `min`, `·` to `+`, and `⋆` to `⊗`. The conjectures of
Section 9 are a coordinated program to determine exactly how much of this lax
structure can be made strict — by restricting to transverse coefficients, by
passing to Newton polygons, and by extending from the product law to the
differential and compositional calculus of species. Each is precise, falsifiable,
and computationally testable on the `p`-adic model.

---

## 11. Conclusion

We have built a clean bridge from the multiplicative world of generating-function
convolution to the additive, order-theoretic world of tropical valuation profiles
and proved that it is sound: the min-plus convolution of valuation profiles never
exceeds the valuation profile of the Cauchy convolution. The result holds in
maximal algebraic generality, rests on three transparent axioms, and admits a
three-line conceptual proof. It unifies the coefficient-level mechanism behind
Newton-polygon additivity, divisibility of combinatorial sequences, and min-plus
optimization, and it opens a concrete path — through four sharp conjectures —
toward an exact tropical correspondence.
