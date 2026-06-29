# The Taylor Calculus of Combinatorial Species: Iterated Differentiation, Maclaurin Reconstruction, Moment Towers, and the Higher Leibniz Rule

## Abstract

We develop, and machine-verify, the higher-order differential calculus of
Joyal's combinatorial species through the exponential generating function (EGF)
bridge. Working over the formal power series ring `ℚ⟦X⟧`, we establish that the
EGF transform `egf(a) = Σ_n (a_n/n!)Xⁿ` is a bijection between counting sequences
`ℕ → ℚ` and power series, and that under it Joyal's derivative species `F′[n] =
F[n+1]` and pointed species `F•[n] = [n] × F[n]` correspond to the formal
derivative `d/dX` and the Euler operator `θ = X·d/dX` respectively. Our main
contributions iterate these first-order bridges into full towers. We prove
(i) the *Taylor tower* identities `F^{(k)}[n] = F[n+k]` and `EGF(F^{(k)}) =
(d/dX)^k EGF(F)`; (ii) the *species Maclaurin theorem*, that the constant term of
the `k`-fold formal derivative of `EGF(F)` equals the un-normalised count `F[k]`,
the exponential `1/n!` normalisation exactly cancelling the `k!` of an ordinary
Taylor expansion; (iii) the *Taylor reconstruction theorem*, that every power
series equals the EGF of the sequence of constant-terms of its own derivative
tower — an exact, coefficientwise-finite algebraic inversion rather than an
analytic limit; (iv) the *moment tower* `(F^{•k})[n] = nᵏ·F[n]` with EGF shadow
`(X·d/dX)^k`; and (v) the *higher (binomial) Leibniz rule* on `ℚ⟦X⟧`. All results
are formalized with no `sorry` and depend only on the standard foundational
axioms. We give proof sketches, algorithms realising each identity numerically,
and a discussion of the composition / exponential-formula extension that remains
open.

**Keywords.** Combinatorial species, exponential generating functions, formal
power series, Taylor expansion, Faà di Bruno, Euler operator, analytic functors,
groupoid cardinality.

---

## 1. Introduction

Joyal's theory of combinatorial species reframes enumerative combinatorics as
the study of functors from the groupoid of finite sets to finite sets. Each
species `F` packages, for every label-count `n`, the finite set `F[n]` of
`F`-structures on an `n`-element label set, together with the relabelling action
of the symmetric group. The associated exponential generating function (EGF)
linearises this categorical data into `ℚ⟦X⟧`, and the central theorems of the
theory state that algebraic operations on species — sum, product, derivative,
pointing, composition — correspond to algebraic operations on EGFs.

The first-order layer of this dictionary (sum ↔ sum, Day-convolution product ↔
Cauchy product, derivative ↔ `d/dX`, pointing ↔ `X·d/dX`) is classical. This
paper concerns the *higher-order* layer: what happens when these operators are
iterated. We show that iteration produces three coherent towers — the derivative
(Taylor) tower, the pointing (moment) tower, and the binomial Leibniz tower — and
that the derivative tower is, remarkably, *invertible*: a power series is
reconstructed exactly from the constant terms of its iterated derivatives. The
reconstruction is finite at each coefficient and purely algebraic, in sharp
contrast to the analytic Taylor theorem it formally resembles.

All statements below have been formally verified. We present them with full
mathematical statements and proof sketches; the verified development is the
source of truth and the prose paraphrases it faithfully.

The novelty of the present work is twofold. First, while the first-order
bridges (derivative ↔ `d/dX`, pointing ↔ `X·d/dX`) are folklore, their
*iterates* are usually handled informally; here every tower is proved by a clean
`Function.iterate` induction whose inductive step is a single application of the
corresponding first-order bridge, so the higher-order theory is reduced to the
first-order theory in a structurally transparent way. Second, the Taylor
reconstruction theorem isolates a phenomenon that the analytic analogy obscures:
because the underlying data are discrete and `egf` is a bona fide bijection, the
Taylor tower is *invertible* with no convergence hypothesis, a statement that has
no classical analytic counterpart for general smooth functions.

---

## 2. Definitions

### 2.1 Counting sequences and the EGF transform

A **counting sequence** is a function `a : ℕ → ℚ`. Its **exponential generating
function** is the formal power series

> `egf(a) := Σ_n (a_n / n!) Xⁿ ∈ ℚ⟦X⟧`,  i.e. `coeff_n(egf a) = a_n / n!`.

Define the **inverse transform** `seqOf(f)_n := n! · coeff_n(f)`.

### 2.2 Binomial convolution

The **binomial (exponential) convolution** of `a, b : ℕ → ℚ` is

> `(a ⋆ b)_n := Σ_{i+j=n} C(n,i) · a_i · b_j`,

written `binConv a b`. Its rig unit is `binConvOne_n = [n = 0]` (1 at `n=0`, else
0).

### 2.3 Species

A **species** (skeletal form) is a structure consisting of:
- a family `obj : ℕ → Type` of finite types (`F[n] := obj n`),
- a finiteness instance for each `obj n`,
- a relabelling action `act_n : Perm(Fin n) →* Perm(obj n)`.

Its **counting sequence** is `F.coeffSeq(n) := card(F[n])` and its **EGF** is
`F.EGF := egf(n ↦ (F.coeffSeq n : ℚ))`.

Two basic species: the **species of sets** `E` with `E[n] = Unit` (so
`coeffSeq = 1` constantly), and the **species of linear orders** `L` with
`L[n] = Perm(Fin n)` (so `coeffSeq(n) = n!`).

### 2.4 Differential operators on species

- **Derivative species** `F′`: `obj n = F.obj(n+1)`, action lifted along
  `Fin.castSuccEmb` (relabel the `n` real points, fix the ghost). Hence
  `F′.coeffSeq(n) = F.coeffSeq(n+1)`.
- **Pointed species** `F•`: `obj n = Fin n × F.obj n`, diagonal action. Hence
  `F•.coeffSeq(n) = n · F.coeffSeq(n)`.

On power series we use Mathlib's formal derivative `derivativeFun` with
`coeff_n(derivativeFun f) = (n+1)·coeff_{n+1}(f)`, and the Euler operator
`θ(f) = X · derivativeFun(f)`.

---

## 3. The first-order dictionary

These results, on which the towers are built, are formally verified.

**Proposition 3.1 (Coefficient and inversion).** `coeff_n(egf a) = a_n/n!`;
`seqOf(egf a) = a` and `egf(seqOf f) = f`. Hence `egf` is a **bijection**
`(ℕ → ℚ) ≃ ℚ⟦X⟧` with inverse `seqOf`, and in particular `egf` is injective.
*Sketch.* Both composites are checked coefficientwise; `n! ≠ 0` in `ℚ` lets
`field_simp` clear denominators. ∎

**Proposition 3.2 (Sum and product).** `egf(a + b) = egf a + egf b` and
`egf(a ⋆ b) = egf a · egf b`. *Sketch.* Additivity is coefficientwise. For the
product, expand the Cauchy product `coeff_n(egf a · egf b) = Σ_{i+j=n}
(a_i/i!)(b_j/j!)` and use `C(n,i) = n!/(i!j!)` to match `coeff_n(egf(a ⋆ b)) =
(Σ_{i+j=n} C(n,i)a_ib_j)/n!`. ∎

**Proposition 3.3 (Generating functions of `E` and `L`).** `E.EGF = exp ℚ` and
`(1−X)·L.EGF = 1` (so `L.EGF = 1/(1−X)`). *Sketch.* `E.EGF = egf(1) = Σ Xⁿ/n! =
exp`; for `L`, `egf(n ↦ n!) = Σ Xⁿ = 1/(1−X)`. ∎

**Proposition 3.4 (Derivative and pointing bridges).**
`egf(n ↦ a_{n+1}) = derivativeFun(egf a)` and `egf(n ↦ n·a_n) = X ·
derivativeFun(egf a)`. Consequently `EGF(F′) = derivativeFun(F.EGF)` and
`EGF(F•) = X · derivativeFun(F.EGF)`. *Sketch.* Coefficientwise:
`coeff_n(derivativeFun(egf a)) = (n+1)·a_{n+1}/(n+1)! = a_{n+1}/n!`; the pointing
case splits at `n=0` using `coeff_n(X·g)`. ∎

**Proposition 3.5 (First-order Leibniz).** `seqDeriv(a ⋆ b) = seqDeriv a ⋆ b +
a ⋆ seqDeriv b`, where `seqDeriv(a)_n = a_{n+1}`. *Sketch.* Apply `egf_injective`
to `derivativeFun_mul` after translating both sides with Prop. 3.2 and 3.4. ∎

Proposition 3.5 exemplifies a recurring proof pattern in the development: a
*structural* combinatorial identity (here the species product rule `(F·G)′ ≅
F′·G + F·G′`) is proved with no index manipulation whatsoever by transporting the
corresponding *analytic* identity (`derivativeFun_mul`) across the injective EGF
bridge. Injectivity of `egf` upgrades every true power-series identity whose two
sides are images of counting sequences into a true combinatorial identity. This
is the lever that makes the higher towers cheap to establish once the first-order
bridges are in place.

---

## 4. The derivative (Taylor) tower

We now iterate Prop. 3.4. Write `g^[k]` for the `k`-fold iterate of a function
`g`, and `F^{(k)} := derivative^[k] F`.

**Theorem 4.1 (Iterated sequence-shift bridge).** For every `a : ℕ → ℚ` and `k`,

> `egf(n ↦ a_{n+k}) = derivativeFun^[k](egf a)`.

*Sketch.* Induction on `k`, generalising over `a`. The step rewrites `a_{n+(k+1)}
= (shift a)_{n+k}`, applies the inductive hypothesis to `shift a`, and closes with
the `k=1` bridge `egf_derivative` and `Function.iterate_succ_apply`. ∎

**Theorem 4.2 (Higher derivative species count).** `F^{(k)}.coeffSeq(n) =
F.coeffSeq(n+k)`. *Sketch.* Induction on `k`, generalising `n`; the step exposes
the outer `derivative` via `iterate_succ_apply'`, applies `coeffSeq_derivative`,
and uses the hypothesis at `n+1`. ∎

**Theorem 4.3 (Taylor evaluation at the origin).** `F^{(k)}.coeffSeq(0) =
F.coeffSeq(k)`. *Sketch.* Specialise Thm 4.2 at `n=0` and simplify `0+k=k`. ∎

**Theorem 4.4 (EGF of the derivative tower).** `EGF(F^{(k)}) =
derivativeFun^[k](F.EGF)`. *Sketch.* Induction on `k` using `EGF_derivativeSpecies`
on the outer factor. ∎

**Theorem 4.5 (Species Maclaurin reconstruction).** For every species `F` and
every `k`,

> `coeff_0( derivativeFun^[k](F.EGF) ) = F.coeffSeq(k)`.

That is, the constant term of the `k`-fold formal derivative of the EGF recovers
the *un-normalised* count `F[k]`. *Sketch.* By Thm 4.4 the constant term equals
`coeff_0(EGF(F^{(k)})) = F^{(k)}.coeffSeq(0)/0! = F.coeffSeq(k)` using Thm 4.3 and
`coeff_0(egf b) = b_0`. ∎

**Remark (why the exponential normalisation).** An ordinary Taylor expansion
returns `f^{(k)}(0)/k!`; the `1/n!` weighting in the EGF cancels exactly this
`k!`, so the EGF — not the ordinary GF — is the unique normalisation for which
Taylor extraction yields raw counts. This is the structural reason the
exponential convention is canonical for labelled enumeration.

---

## 5. Taylor reconstruction: invertibility of the tower

Theorem 4.5 extracts coefficients singly. We now assemble them.

**Theorem 5.1 (Analytic Maclaurin extraction).** For every `a : ℕ → ℚ`,
`coeff_0(derivativeFun^[k](egf a)) = a_k`. *Sketch.* Read Thm 4.1 at `coeff 0`:
the left side is `coeff_0(egf(a(·+k))) = a_{0+k}/0! = a_k`. ∎

**Theorem 5.2 (Taylor reconstruction).** For every `f ∈ ℚ⟦X⟧`,

> `egf( k ↦ coeff_0(derivativeFun^[k](f)) ) = f`.

*Sketch.* Write `f = egf(seqOf f)` (Prop. 3.1). By Thm 5.1, `coeff_0(
derivativeFun^[k] f) = (seqOf f)_k`, so the argument sequence is `seqOf f` and the
left side is `egf(seqOf f) = f`. ∎

**Theorem 5.3 (Species Taylor series).** `egf( k ↦ coeff_0(derivativeFun^[k]
(F.EGF)) ) = F.EGF` for every species `F`. *Sketch.* Theorem 5.2 at `f = F.EGF`. ∎

**Discussion.** Theorem 5.2 is the conceptual core. It states that the map
`f ↦ (k ↦ coeff_0(d^k/dX^k f))` is a genuine inverse of `egf`. Because `egf` is a
bijection (Prop. 3.1) and the "differentiate-and-read-constant-term" map agrees
with `seqOf` on every coefficient, the Taylor expansion is an *exact* algebraic
inversion that terminates after `k` differentiations for the `k`-th coefficient.
There is no convergence hypothesis and no limit: the discreteness of the species
data makes the Taylor "series" a finite computation at each coefficient. This is
the precise sense in which differentiation of species is **information-preserving**
— a single derivative discards the head of the sequence, but the full tower,
sampled at the origin, recovers everything.

---

## 6. The moment tower: iterated pointing

**Theorem 6.1 (Iterated pointing weights by `nᵏ`).**

> `(pointed^[k] F).coeffSeq(n) = nᵏ · F.coeffSeq(n)`.

*Sketch.* Induction on `k`, generalising `n`. The step exposes the outer
`pointed` via `iterate_succ_apply'`, applies `coeffSeq_pointed` (multiply by `n`),
uses the hypothesis, and rearranges with `pow_succ`. ∎

**Theorem 6.2 (EGF of the moment tower).**

> `(pointed^[k] F).EGF = (f ↦ X · derivativeFun f)^[k] (F.EGF)`,

i.e. the EGF of the `k`-fold pointed species is the `k`-fold Euler operator
`θ^k = (X·d/dX)^k` applied to `F.EGF`. *Sketch.* Induction on `k`; the step
rewrites both sides with `iterate_succ_apply'` and applies `EGF_pointedSpecies` to
the outer pointing, then the hypothesis. ∎

**Interpretation.** The weights `nᵏ` are the (raw) **moments** of the counting
sequence; pointing is thus the species-theoretic moment functor, and its analytic
shadow is the iterated Euler operator. The interplay between the derivative tower
(shift) and the moment tower (multiply by `n`) is governed by the Stirling
transform `θᵏ = Σ_j S(k,j) Xʲ (d/dX)ʲ`, connecting moment weighting `nᵏ` to
falling-factorial weighting; making this Stirling bridge formal is a natural next
target (Section 8).

---

## 7. The higher Leibniz rule

**Theorem 7.1 (Higher / binomial Leibniz rule).** For `f, g ∈ ℚ⟦X⟧` and every
`k`,

> `derivativeFun^[k](f · g) = Σ_{i=0}^{k} C(k,i) · derivativeFun^[i](f) ·
> derivativeFun^[k−i](g)`.

*Sketch.* Induction on `k`. The base case is trivial; the step applies the
first-order product rule `derivativeFun_mul` to each summand of the inductive
hypothesis, then recombines the two resulting sums by the Pascal identity
`C(k,i−1) + C(k,i) = C(k+1,i)` via an index split (`Finset.sum_range_succ'`).
Linearity of `derivativeFun` handles the algebra, avoiding antidiagonal
bookkeeping. ∎

**Species reading.** Translating Theorem 7.1 across the EGF bridge with
Theorem 4.1 and Prop. 3.2 yields the *higher product rule for species*:
differentiating a Day convolution `F·G` exactly `k` times distributes the `k`
ghosts between the two factors in every way, weighted by the binomial count of
how to assign which ghost to which factor. The `k=1` case is the classical species
isomorphism `(F·G)′ ≅ F′·G + F·G′` (Prop. 3.5). This is the Faà di Bruno backbone
on which a future formalization of species composition will rest.

---

## 8. Algorithms

Each verified identity has a direct computational realisation over exact
rationals. We summarise three.

**Algorithm A — Maclaurin coefficient extraction.** Given a truncated EGF
`f = (c_0, …, c_N)` (with `c_n` the coefficient of `Xⁿ`), compute the count
`a_k = F[k]` by `k`-fold formal differentiation and reading the constant term.
The formal derivative sends `(c_0, c_1, …) ↦ (c_1, 2c_2, 3c_3, …)`; after `k`
steps the constant term is `k!·c_k`, equal to `a_k`. Complexity: `O(N·k)`
rational operations for one coefficient, `O(N²)` for the whole tower up to `N`.

**Algorithm B — Taylor reconstruction.** Given a power series `f`, recover the
counting sequence `a` by `a_k = coeff_0(d^k/dX^k f)` (Algorithm A) for each `k`,
then verify `egf(a) = f` coefficientwise. Returns the unique sequence whose EGF is
`f`; equivalently `a_k = k!·coeff_k(f) = seqOf(f)_k`. Complexity `O(N²)`.

**Algorithm C — Higher Leibniz convolution.** Given derivative towers
`f^{(i)}` and `g^{(j)}` (as truncated series), assemble `(f·g)^{(k)}` by the
binomial sum `Σ_i C(k,i) f^{(i)} g^{(k−i)}` and compare with the direct `k`-fold
derivative of the product. Complexity `O(k·N²)` for the convolution at order `k`.

---

## 9. Applications and worked examples

- **Sets `E`.** `coeffSeq = 1`, `E.EGF = eˣ`. Maclaurin extraction returns
  `coeff_0(d^k/dX^k eˣ) = 1 = E[k]` for all `k` — the fixed point of
  differentiation made discrete. Reconstruction returns the constant sequence.
- **Linear orders `L`.** `coeffSeq(n) = n!`, `L.EGF = 1/(1−X)`. The `k`-fold
  derivative of `1/(1−X)` is `k!/(1−X)^{k+1}`, whose constant term is `k!`, matching
  `L[k] = k!`. Iterated pointing gives `(L^{•k})[n] = nᵏ·n!`.
- **Derangements `D`.** `D.EGF = e^{−X}/(1−X)`; the Maclaurin tower reproduces the
  subfactorials `1,0,1,2,9,44,…`, illustrating reconstruction for a non-trivial
  sequence.
- **Moments.** For any species, `(F^{•2})[n] = n²·F[n]` realises second moments;
  combining with sums recovers variance-type statistics of label-marking.
- **Products.** For `f = g = eˣ` (`E·E`), `(f·g)^{(k)} = 2ᵏ eˣ`, and the higher
  Leibniz rule expands this as `Σ_i C(k,i) eˣ·eˣ = 2ᵏ eˣ`, a binomial-theorem
  identity made structural.

---

## 10. Related structure

The development sits atop a fuller species dictionary that the present towers
extend.

**The convolution ring.** The counting sequences `ℕ → ℚ` form a commutative ring
under pointwise addition and binomial convolution `⋆`, with unit `binConvOne =
(1,0,0,…)`. The verified facts `binConv_comm`, `binConv_assoc`,
`binConv_one_left/right`, `binConv_add` package this, and the transform `egf`
promotes to a *ring isomorphism* `(ℕ → ℚ, +, ⋆) ≅ (ℚ⟦X⟧, +, ·)`. Thus the
species sum and product literally are the ring operations of formal power series,
and the Leibniz towers of Section 7 are statements about a derivation on this
ring.

**Bijectivity and complete invariance.** `egf` is a bijection with explicit
inverse `seqOf(f)_n = n!·coeff_n(f)` (Prop. 3.1); consequently two species have
the same EGF iff they have the same counting sequence (`Species.EGF_inj`). The
EGF is therefore a *complete invariant* for labelled enumeration, and the
reconstruction theorem (Thm 5.2) is the explicit recipe for inverting it through
the derivative tower rather than through `seqOf` directly.

**Groupoid-cardinality reading.** The coefficient `coeff_n(F.EGF) =
F.coeffSeq(n)/n!` admits a homotopy-theoretic interpretation: it is the
*action-groupoid cardinality* of the relabelling action of `Perm(Fin n)` on
`F[n]`, the homotopy-theoretic refinement of orbit counting (a quotient form of
the orbit–stabiliser theorem). For the species of sets this is `1/n!` and for
linear orders it is `1`, matching `exp` and `1/(1−X)` coefficientwise. Against
this backdrop the Taylor, moment, and Leibniz towers complete the *differential*
layer of the dictionary, and Section 11.5 conjectures that the derivative functor
respects this groupoid-cardinality invariance.

## 10b. On the absence of factorials in Maclaurin extraction

It is worth dwelling on the precise bookkeeping behind Theorem 4.5, since it is
the technical fulcrum of the paper. Classically, for an ordinary generating
function `G(X) = Σ a_n Xⁿ`, the `k`-th derivative at the origin is
`G^{(k)}(0) = k!·a_k`, so recovering `a_k` requires dividing by `k!`. For the
*exponential* generating function `egf(a) = Σ (a_n/n!) Xⁿ`, the constant term of
`d^k/dX^k` is instead
`coeff_0(d^k/dX^k egf(a)) = k!·coeff_k(egf(a)) = k!·(a_k/k!) = a_k`.
The `k!` produced by `k`-fold differentiation is cancelled exactly by the `1/k!`
planted in the EGF coefficient, leaving the raw count with no residual factor.
No other normalisation of the generating function has this property, which is the
structural reason the exponential convention — and not the ordinary one — is the
canonical transform for labelled species.

---

## 11. Discussion and future work

The results identify three coherent higher-order towers and, most strikingly,
establish that the derivative tower is invertible: Taylor reconstruction (Thm 5.2)
exhibits the exact inverse of Maclaurin extraction (Thm 4.5). The following
directions extend the program; each is stated as a falsifiable target.

1. **The exponential formula `EGF(E ∘ G) = exp(EGF G)`.** Composition (plethysm)
   `F ∘ G` is the major operation still absent from the dictionary; its flagship
   instance is the exponential formula for assemblies of connected structures,
   valid when `G` has no structure on the empty set (`G[0] = 0`). The needed new
   ingredient is a cardinality count over set partitions, structurally analogous
   to the already-proved product count, after which both sides can be compared
   coefficientwise against the derivative tower using the Maclaurin theorem.

2. **The full species Taylor series as an assembly statement.** Theorem 5.2
   already inverts the tower; packaging it as `F.EGF = mk(k ↦ coeff_0(d^k/dX^k
   F.EGF)/k!)` is a one-lemma `PowerSeries.ext` comparison.

3. **The higher Leibniz rule at the species level.** Theorem 7.1 lives on
   `ℚ⟦X⟧`; transporting it to a `Finset`-indexed species isomorphism via the EGF
   bridge and `egf_seqDeriv_iterate` is a direct corollary to be recorded.

4. **Iterated pointing and the Euler powers `(X d/dX)^k`.** Theorems 6.1–6.2 give
   the moment tower; the Stirling-number expansion `θᵏ = Σ_j S(k,j) Xʲ(d/dX)ʲ`
   would connect iterated pointing (`nᵏ`) to the falling-factorial / ordinary-
   derivative towers, unifying the two lifts of `d/dX`.

5. **Homotopy invariance of `d/dX`.** Since the EGF is a groupoid-cardinality
   invariant, the derivative functor should respect species isomorphism: `F ≅ G ⇒
   F^{(k)} ≅ G^{(k)}`. The single missing step is iso-preservation of one
   derivative; the `k`-fold case then follows from Theorem 4.2, making the entire
   differential calculus homotopy-invariant.

---

## 12. Conclusion

We have machine-verified the higher-order differential calculus of combinatorial
species: the derivative (Taylor) tower with its Maclaurin reconstruction and exact
algebraic inversion, the pointing (moment) tower realised as the iterated Euler
operator, and the binomial Leibniz rule. The unifying theme is that, for labelled
structures, differentiation is not lossy: the tower of all derivatives sampled at
the origin reconstructs the counting sequence exactly and finitely. The
exponential normalisation of the EGF is precisely what makes this work, cancelling
the factorial of the classical Taylor theorem and turning an analytic limit into a
discrete identity.
