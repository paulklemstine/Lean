# The Exponential-Convolution Ring of Counting Sequences

### A Bundled Ring Isomorphism Realizing the Species–EGF Bridge

**Abstract.** We develop the algebraic backbone of Joyal's theory of
combinatorial species in its enumerative shadow. The exponential generating
function (EGF) `egf(a) = ∑ₙ (aₙ/n!) Xⁿ` is classically known to convert the
disjoint-union (sum) of species into the sum of power series and the structural
Day-convolution product into the Cauchy product. We promote these scattered
homomorphism identities into a single structural statement: the set of counting
sequences `ℕ → ℚ`, equipped with pointwise addition and the *binomial
(exponential) convolution* as multiplication, forms a commutative ring, and the
EGF is a *ring isomorphism* onto the ring `ℚ⟦X⟧` of formal power series over the
rationals. We isolate a subtle instance-diamond obstruction — the pointwise `Pi`
multiplication already present on `ℕ → ℚ` — and resolve it with a one-field
structure wrapper `ConvSeq`. From the bundled isomorphism we read off, with no
index manipulation, the commutative-semiring axioms of binomial convolution
(commutativity, associativity, the unit laws, distributivity), the power law
`egf(a⋆ᵏ) = (egf a)ᵏ`, and the classification of every `n!`-counted species as
having EGF `1/(1−X)`. We further record the differential layer: the derivative
species maps to the formal derivative `d/dX`, the pointed species to `X·d/dX`,
and the species product rule descends to a Leibniz identity on binomial
convolutions. All results have been formally verified.

---

## 1. Introduction

A *combinatorial species* in the sense of Joyal is a functor from the groupoid of
finite sets and bijections to the category of finite sets. Concretely, a species
`F` assigns to each finite label set a finite set of *structures* and acts
functorially under relabelling. Its enumerative content is the *counting
sequence* `n ↦ |F[n]|`, where `F[n]` denotes the structures on an `n`-element
label set, and its analytic avatar is the **exponential generating function**

> `EGF(F) = ∑ₙ (|F[n]| / n!) Xⁿ ∈ ℚ⟦X⟧`.

The species formalism is valuable precisely because the elementary operations on
species — sum, product, composition, derivative — correspond to elementary
operations on EGFs. The foundational layer of this correspondence is well
established. This paper concerns its *structural* consolidation: rather than a
list of independent homomorphism lemmas, we exhibit the EGF as a single bundled
ring isomorphism, and harvest the consequences.

The contribution is threefold:

1. **A ring structure on counting sequences** (`ConvSeq`) under pointwise
   addition and binomial convolution, defined by transport across the EGF
   bijection, together with the identification of the transported operations.
2. **The EGF as a ring isomorphism** `egfRingEquiv : ConvSeq ≃+* ℚ⟦X⟧`, from
   which the semiring axioms of binomial convolution and the power law follow as
   corollaries of the ambient ring axioms.
3. **A consolidated dictionary** including inversion (the EGF is a bijection with
   explicit inverse), the differential layer (derivative, pointing, Leibniz), and
   the classification of factorial-counted species.

---

## 2. The EGF and binomial convolution

Throughout, a *counting sequence* is a function `a : ℕ → ℚ`. We use the field of
rationals to permit division by factorials; combinatorial counts are recovered as
the integer values of these sequences.

**Definition 2.1 (EGF).** The exponential generating function of `a : ℕ → ℚ` is
the formal power series
> `egf(a) := ∑ₙ (aₙ / n!) Xⁿ`,
i.e. the series whose `n`-th coefficient is `aₙ / n!`.

**Definition 2.2 (Binomial convolution).** The binomial (exponential)
convolution of `a, b : ℕ → ℚ` is
> `(a ⋆ b)ₙ := ∑_{i + j = n} C(n, i) · aᵢ · bⱼ`,
the sum taken over the antidiagonal `{(i, j) : i + j = n}`, with `C(n, i)` the
binomial coefficient.

The combinatorial meaning of `⋆` is the *structural product* of species: a
combined structure on `n` labels is a subset `S ⊆ [n]`, an `A`-structure on `S`,
and a `B`-structure on the complement `[n] ∖ S`. Summing over subsets grouped by
size `i = |S|` (there are `C(n, i)` of size `i`) yields Definition 2.2.

**Theorem 2.3 (Sum law).** For all `a, b`,
> `egf(λ n, aₙ + bₙ) = egf(a) + egf(b)`.

*Proof sketch.* Compare coefficients of `Xⁿ`: the left side is `(aₙ + bₙ)/n!`,
which splits as `aₙ/n! + bₙ/n!`, the coefficient of the right side. ∎

**Theorem 2.4 (Product law).** For all `a, b`,
> `egf(a ⋆ b) = egf(a) · egf(b)`.

*Proof sketch.* The coefficient of `Xⁿ` in the Cauchy product `egf(a)·egf(b)` is
`∑_{i+j=n} (aᵢ/i!)(bⱼ/j!)`. The coefficient of `Xⁿ` in `egf(a⋆b)` is
`(a⋆b)ₙ/n! = ∑_{i+j=n} C(n,i) aᵢ bⱼ / n!`. Using the factorization
`C(n,i) = n!/(i!·j!)` valid for `i + j = n` (equivalently
`Nat.choose_mul_factorial_mul_factorial`), the `n!` cancels and the two sums
agree term by term. ∎

Theorem 2.4 is the keystone: the factorial normalization is designed precisely so
the binomial coefficients in `⋆` are absorbed into the denominators, turning
combinatorial gluing into the Cauchy product.

**Theorem 2.5 (Cardinality of the structural product).** For finite structure
families `A, B : ℕ → Type` with `|A k|, |B k|` finite,
> `|Σ (S : Finset (Fin n)), A[|S|] × B[n − |S|]| = ∑_{i+j=n} C(n,i)·|A i|·|B j|`.

*Proof sketch.* Expand the cardinality of the sigma-type as a sum over subsets
`S ⊆ [n]` of `|A[|S|]|·|B[n−|S|]|`. Partition the powerset by cardinality: the
subsets of size `k` number `C(n,k)` (`Finset.card_powersetCard`). Regrouping the
double sum and reindexing over the antidiagonal yields the binomial convolution.
∎

**Corollary 2.6 (Species–EGF product bridge).** For finite families `A, B`,
> `egf(n ↦ |Σ S, A[|S|]×B[n−|S|]|) = egf(n ↦ |A n|) · egf(n ↦ |B n|)`.

*Proof sketch.* Combine Theorem 2.5 (the count equals the binomial convolution
of the cardinality sequences) with Theorem 2.4 (binomial convolution ↔ Cauchy
product), casting `ℕ → ℚ`. ∎

---

## 3. Inversion: the EGF is a bijection

**Definition 3.1.** The candidate inverse `seqOf : ℚ⟦X⟧ → (ℕ → ℚ)` is
> `seqOf(f)ₙ := n! · [coefficient of Xⁿ in f]`.

**Theorem 3.2.** `seqOf` is a two-sided inverse of `egf`:
> `seqOf(egf(a)) = a` and `egf(seqOf(f)) = f`.

*Proof sketch.* For the first, `seqOf(egf a)ₙ = n! · (aₙ/n!) = aₙ` since
`n! ≠ 0`. For the second, the `n`-th coefficient of `egf(seqOf f)` is
`seqOf(f)ₙ/n! = (n!·[Xⁿ]f)/n! = [Xⁿ]f`. ∎

**Corollary 3.3 (Complete invariance).** `egf` is bijective; in particular it is
injective, so distinct counting sequences have distinct EGFs, and surjective, so
every power series is an EGF. We package this as an equivalence
`egfEquiv : (ℕ → ℚ) ≃ ℚ⟦X⟧` with `invFun = seqOf`.

**Corollary 3.4 (EGF as species invariant).** Two species `F, G` satisfy
`EGF(F) = EGF(G)` if and only if their counting sequences coincide,
`n ↦ |F[n]|` equals `n ↦ |G[n]|`.

Injectivity is the engine of the entire program: every identity proved on the
analytic side transports back to a combinatorial identity. We use this
repeatedly below.

---

## 4. The exponential-convolution ring `ConvSeq`

**The instance-diamond obstruction.** The carrier `ℕ → ℚ` already possesses a
canonical commutative-ring structure: the *pointwise* (`Pi`) ring, with
`(a·b)ₙ = aₙ·bₙ`. The binomial convolution `⋆` is a *different* multiplication on
the same carrier. Declaring `ℕ → ℚ` to be "the convolution ring" via a reducible
type synonym creates an instance diamond — Lean's typeclass resolution cannot
tell which `Mul` is intended, and the transported multiplication fails to be
definitionally equal to `Pi.instMul`. Concretely, an early attempt with
`def ConvSeq := ℕ → ℚ` left the ring isomorphism unable to elaborate.

**Resolution: a structure wrapper.**

**Definition 4.1.** `ConvSeq` is a one-field structure wrapping a counting
sequence:
> `structure ConvSeq where (seq : ℕ → ℚ)`.

Wrapping the carrier in a fresh type removes the diamond: `ConvSeq` carries no
pre-existing ring structure, so the transported one is unambiguous.

**Definition 4.2 (Transport).** Via the trivial bijection `equivSeq : ConvSeq ≃
(ℕ → ℚ)` composed with `egfEquiv` (Corollary 3.3), we obtain
`equiv : ConvSeq ≃ ℚ⟦X⟧`. Transporting the commutative-ring structure of `ℚ⟦X⟧`
across `equiv` (Mathlib's `Equiv.commRing`) endows `ConvSeq` with a commutative
ring structure, and `Equiv.ringEquiv` upgrades `equiv` to a ring isomorphism:
> `egfRingEquiv : ConvSeq ≃+* ℚ⟦X⟧`, with `egfRingEquiv(a) = egf(a.seq)`.

**Theorem 4.3 (Characterization of the transported operations).** The ring
operations transported onto `ConvSeq` are exactly the expected combinatorial
ones, at the level of underlying sequences:
> `(a · b).seq = a.seq ⋆ b.seq` &nbsp;&nbsp; (`mul_seq`)
> `(a + b).seq = λ n, a.seq n + b.seq n` &nbsp;&nbsp; (`add_seq`)
> `(1).seq = binConvOne` &nbsp;&nbsp; (`one_seq`)
> `(0).seq = λ _, 0` &nbsp;&nbsp; (`zero_seq`)
where `binConvOne` is the unit sequence `(1, 0, 0, …)`, i.e. `λ n, if n = 0 then
1 else 0`.

*Proof sketch.* Each is proved by applying `egf_injective` (Corollary 3.3) and
the relevant ring-hom property of `egfRingEquiv`. For multiplication:
`egf((a·b).seq) = egfRingEquiv(a·b) = egfRingEquiv(a)·egfRingEquiv(b) =
egf(a.seq)·egf(b.seq) = egf(a.seq ⋆ b.seq)` by `map_mul` and Theorem 2.4; cancel
`egf` by injectivity. Addition uses `map_add` and Theorem 2.3; the unit uses
`map_one` and `egf(binConvOne) = 1` (Lemma 4.4); zero uses `map_zero` and
`egf(0) = 0`. ∎

**Lemma 4.4 (Unit and zero EGFs).**
> `egf(binConvOne) = 1` and `egf(λ _, 0) = 0`.

*Proof sketch.* For the unit, only the `n = 0` coefficient survives, giving
`1/0! = 1`; all higher coefficients are `0/n! = 0`, so the series is `1`. For
zero, every coefficient is `0/n! = 0`. ∎

---

## 5. The semiring axioms, read off for free

The point of bundling the bridge as a ring isomorphism is that the
otherwise index-heavy laws of binomial convolution become immediate images of the
ambient ring axioms, via `congrArg ConvSeq.seq` applied to the corresponding
identity in `ConvSeq` and rewriting through Theorem 4.3.

**Theorem 5.1 (Commutativity).** `a ⋆ b = b ⋆ a`.
*Proof sketch.* Apply `ConvSeq.seq` to `mul_comm (mk a) (mk b)` and simplify with
`mul_seq`. ∎

**Theorem 5.2 (Associativity).** `(a ⋆ b) ⋆ c = a ⋆ (b ⋆ c)`.
*Proof sketch.* Apply `ConvSeq.seq` to `mul_assoc (mk a) (mk b) (mk c)`. ∎

**Theorem 5.3 (Unit laws).** `binConvOne ⋆ a = a` and `a ⋆ binConvOne = a`.
*Proof sketch.* Apply `ConvSeq.seq` to `one_mul (mk a)` and `mul_one (mk a)`,
rewriting via `mul_seq` and `one_seq`. ∎

**Theorem 5.4 (Distributivity).** `a ⋆ (b + c) = a ⋆ b + a ⋆ c` (and the
right-handed version), where `+` is pointwise.
*Proof sketch.* Apply `ConvSeq.seq` to the ring distributive law `mul_add` (resp.
`add_mul`) in `ConvSeq`. ∎

Each of these is a classical identity whose direct proof requires reindexing sums
and manipulating binomial coefficients; through the isomorphism each is a single
line. This is the methodological dividend of the bundling.

---

## 6. The power law and factorial-counted species

**Definition 6.1 (Iterated convolution).** The `k`-fold binomial convolution
`binConvPow a k` is defined by `binConvPow a 0 = binConvOne` and
`binConvPow a (k+1) = a ⋆ (binConvPow a k)`.

**Theorem 6.2 (Power law).**
> `egf(binConvPow a k) = (egf a)ᵏ`.

*Proof sketch.* Induction on `k`. The base case is Lemma 4.4. The step uses
Theorem 2.4: `egf(a ⋆ binConvPow a k) = egf(a)·egf(binConvPow a k) =
egf(a)·(egf a)ᵏ = (egf a)^{k+1}`. Equivalently, `binConvPow` is the `Monoid.npow`
of `ConvSeq` and the law is `map_pow egfRingEquiv`. ∎

The power law is the algebraic engine behind species composition and the
exponential formula: the term `(egf a)ᵏ / k!` enumerates assemblies of `k`
independent labelled blocks, and summing these strata realizes substitution of
generating functions.

**Theorem 6.3 (Factorial-counted species).** Any species `F` with `|F[n]| = n!`
for all `n` has EGF `1/(1−X)`; equivalently `(1 − X)·EGF(F) = 1`.

*Proof sketch.* The counting sequence is `n ↦ n!`, so `EGF(F) = ∑ₙ (n!/n!) Xⁿ =
∑ₙ Xⁿ`, the geometric series. Multiplying by `(1 − X)` telescopes to `1`: compare
coefficients, where the constant term is `1` and every higher coefficient is
`1 − 1 = 0`. In particular the species of linear orders, with `|L[n]| =
|Perm(Fin n)| = n!`, has EGF `1/(1−X)`. ∎

**Theorem 6.4 (Species of sets ↔ exponential).** The species `E` of sets, with a
unique structure on every label set (`|E[n]| = 1`), has EGF equal to the
exponential series:
> `EGF(E) = ∑ₙ Xⁿ/n! = exp`.

*Proof sketch.* The counting sequence is constantly `1`, so the `n`-th
coefficient is `1/n!`, which is the `n`-th coefficient of `PowerSeries.exp ℚ`
(the image of `1` under `algebraMap ℚ ℚ = id`). ∎

---

## 7. The differential layer

**Definition 7.1 (Derivative sequence).** `(seqDeriv a)ₙ := a_{n+1}`. This is the
counting sequence of the derivative species `F'[n] = F[n+1]`, obtained by
adjoining a distinguished "ghost" label.

**Theorem 7.2 (Derivative law).** `egf(seqDeriv a) = (egf a)'`, the formal
derivative `d/dX`.

*Proof sketch.* Compare coefficients. The `n`-th coefficient of the formal
derivative of `egf a` is `(n+1)·[X^{n+1}](egf a) = (n+1)·a_{n+1}/(n+1)!`, which
equals `a_{n+1}/n!`, the `n`-th coefficient of `egf(seqDeriv a)`. The
`(n+1)! = (n+1)·n!` cancellation is exactly the EGF normalization in action. ∎

**Definition 7.3 (Pointing).** `(seqPoint a)ₙ := n·aₙ`, the counting sequence of
the pointed species `F^•[n] = [n] × F[n]` (mark one of the `n` labels).

**Theorem 7.4 (Pointing law).** `egf(seqPoint a) = X·(egf a)'`.

*Proof sketch.* For `n = 0`, both sides vanish (`X·(…)` has zero constant term).
For `n = m+1`, the coefficient of the right side is the `m`-th coefficient of
`(egf a)'`, namely `a_{m+1}/m!`; the left side gives `(m+1)·a_{m+1}/(m+1)! =
a_{m+1}/m!`. ∎

**Theorem 7.5 (Structural Leibniz rule).** At the level of counting sequences,
> `(a ⋆ b)' = a' ⋆ b + a ⋆ b'` (with `'` = `seqDeriv`).

*Proof sketch.* Apply `egf_injective`. The left side maps to `(egf(a)·egf(b))'`
by Theorems 2.4 and 7.2; the analytic Leibniz rule `derivativeFun_mul` rewrites
this as `(egf a)'·egf(b) + egf(a)·(egf b)'`. The right side maps to the same by
Theorems 2.3, 2.4, 7.2. Cancelling `egf` by injectivity yields the combinatorial
identity. ∎

This exemplifies the transport philosophy: a combinatorial identity that would
require delicate reindexing is obtained by borrowing an analytic theorem and
ferrying it across the injective bridge.

---

## 8. Algorithms

The constructive content of the theory yields directly executable algorithms over
the rationals.

**Algorithm 8.1 (EGF coefficients).** Given a counting sequence `a` and a degree
`N`, output the coefficients `[a₀/0!, a₁/1!, …, a_N/N!]`. Complexity `O(N)`
rational operations after precomputing factorials.

**Algorithm 8.2 (Binomial convolution).** Given truncations of `a, b` to degree
`N`, output `(a ⋆ b)ₙ = ∑_{i=0}^{n} C(n,i) aᵢ b_{n−i}` for `n ≤ N`. Complexity
`O(N²)` with Pascal-triangle reuse of binomial coefficients.

**Algorithm 8.3 (Cauchy product / EGF verification).** Compute the Cauchy product
of two EGF coefficient lists and compare against the EGF of the binomial
convolution; agreement is a numerical witness of Theorem 2.4.

**Algorithm 8.4 (Iterated convolution power).** Compute `binConvPow a k` by
repeated application of Algorithm 8.2, and verify `egf(binConvPow a k) =
(egf a)ᵏ` (Theorem 6.2) by exponentiating the power-series coefficients.

---

## 9. Applications

- **Mechanized enumerative combinatorics.** The ring isomorphism makes
  `map_mul`, `map_add`, `map_one`, `map_pow`, `map_sum` available for species
  computations, eliminating bespoke coefficient arguments.
- **The exponential formula.** Theorems 6.2 and 6.4 together are the algebraic
  substrate of `EGF(E ∘ T) = exp(EGF(T))`, which counts structures partitioned
  into connected components.
- **Differential combinatorics.** The derivative/pointing/Leibniz layer (§7)
  lets one solve combinatorial differential equations by passing to power series.
- **A complete invariant.** Corollary 3.4 reduces "same counts for all sizes" to
  a single algebraic equation between generating functions.

---

## 10. Discussion and future work

The principal lesson is structural economy: by recognizing that the various EGF
homomorphism laws are jointly the axioms of a ring isomorphism, one trades a
growing list of coefficient lemmas for a single object through which all algebra
flows. The instance-diamond analysis (§4) is a reusable design pattern: when a
carrier already bears a canonical algebraic structure, transport an alternative
structure across a bijection into a fresh wrapper type rather than redefining the
carrier.

Several directions extend the dictionary:

1. **Composition of species = substitution of EGFs.** Define `(S ∘ T)` by summing
   over set partitions and prove `egf(S ∘ T) = egf(S) ∘ egf(T)`, with the
   exponential formula `egf(E ∘ T) = exp(egf(T))` as the `S = E` case. The power
   law (Theorem 6.2) is the "`k` identical blocks" stratum of this partition sum.
2. **A named library of EGFs.** Identify the permutation species (`1/(1−X)`), the
   set species (`exp`), the cycle species (`log(1/(1−X))`), and others as a
   catalogue of standard generating functions.
3. **Functorial counts as cardinality invariants.** Certify that the enumerative
   `LSpecies` layer is a faithful shadow of the categorical `Species ≔ Core
   FintypeCat ⥤ Type` layer, via `Fintype.card_congr`.
4. **Higher-order differential identities** building on §7 toward combinatorial
   differential equations and Lagrange inversion.

All results reported here are formally verified and depend only on the standard
foundational axioms (`propext`, `Classical.choice`, `Quot.sound`).
