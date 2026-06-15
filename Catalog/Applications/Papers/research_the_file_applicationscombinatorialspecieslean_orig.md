# The Taylor / Maclaurin Calculus of Combinatorial Species

## Abstract

We develop the full *Taylor tower* of Joyal's combinatorial species and prove a
reconstruction theorem identifying it with the iterated formal derivative of the
exponential generating function (EGF). Building on the established EGF
dictionary for the monoidal operations on species (disjoint union and
Day-convolution product) and on the first-order differential bridge relating the
derivative species `F′[n] = F[n+1]` to the formal derivative of the EGF, we
iterate the construction. We show that the `k`-fold derivative species satisfies
`F⁽ᵏ⁾[n] = F[n+k]`, that its value on the empty label set recovers the counting
sequence coefficient-by-coefficient (`F⁽ᵏ⁾[0] = F[k]`), and that on the analytic
side the EGF of `F⁽ᵏ⁾` is the `k`-fold formal derivative of `F`'s EGF. The
central result, the **species Maclaurin reconstruction**, states that the
constant term of the `k`-fold formal derivative of `F`'s EGF equals the
*un-normalised* count `F[k]`, with no factorial correction: the exponential
normalisation `1/n!` of the EGF exactly cancels the `k!` that an ordinary
Maclaurin expansion introduces. All results are formalised and machine-checked,
depending only on the standard foundational axioms. The development reduces, via
the injectivity of the EGF transform, to assembling the first-order bridges
under `Function.iterate` inductions.

**Keywords.** combinatorial species, exponential generating functions,
analytic functors, derivative species, Taylor series, formal power series,
enumerative combinatorics, formalized mathematics.

---

## 1. Introduction

### 1.1 Background

A *combinatorial species* in the sense of Joyal (1981) is a functor from the
groupoid of finite sets and bijections to the category of finite sets. Informal-
ly, a species `F` is a rule that, to each finite label set, assigns a finite set
of "`F`-structures," compatibly with relabelling. The fundamental enumerative
invariant of a species is its **exponential generating function** (EGF). Joyal's
theory provides a precise dictionary translating combinatorial constructions on
species into algebraic operations on EGFs: disjoint union becomes addition,
Day-convolution product becomes the Cauchy product, the species of sets `E`
becomes `exp`, and so on.

Within this dictionary sits a *differential calculus*. The **derivative
species** `F′`, defined by `F′[n] = F[n+1]`, corresponds to formal
differentiation of the EGF, and the **pointed species** `F•[n] = [n] × F[n]`
corresponds to the Euler operator `X·d/dX`. These are the species-theoretic
counterparts of the rules of calculus, and they underpin the proofs of central
enumeration results such as the exponential formula and Cayley's tree-counting
formula.

### 1.2 Contribution

This paper iterates the first-order differential bridge into the complete
**Taylor tower** of a species and proves a reconstruction theorem. Concretely,
we establish five results:

1. **`egf_seqDeriv_iterate`** — the `k`-fold shift `a ↦ a(·+k)` of counting
   sequences is intertwined with the `k`-fold formal derivative on `ℚ⟦X⟧`.
2. **`coeffSeq_iterate_derivative`** — `F⁽ᵏ⁾[n] = F[n+k]`.
3. **`taylor_coeffSeq`** — `F⁽ᵏ⁾[0] = F[k]` (Taylor evaluation at the origin).
4. **`EGF_iterate_derivative`** — `(F⁽ᵏ⁾).EGF` is the `k`-fold formal
   derivative of `F.EGF`.
5. **`species_maclaurin`** — the constant term of the `k`-fold formal
   derivative of `F.EGF` equals `F[k]` (Maclaurin reconstruction, no factorial).

The thread tying these together is the *injectivity* of the EGF transform:
because no enumerative information is lost in passing to the EGF, structural
identities of species whose analytic shadow is a true power-series identity
become automatic, and the Taylor tower reduces to a clean induction whose
inductive step is a single application of the already-established `k = 1` bridge.

---

## 2. Definitions

Throughout, `ℚ⟦X⟧` denotes the ring of formal power series in one variable over
the rationals, and `n!` denotes the factorial of `n`.

### 2.1 Counting sequences and their EGF

**Definition 2.1 (EGF of a sequence).** For a counting sequence `a : ℕ → ℚ`,
its *exponential generating function* is the formal power series

> `egf(a) := Σₙ (aₙ / n!) Xⁿ ∈ ℚ⟦X⟧`,

i.e. the power series whose `n`-th coefficient is `aₙ / n!`.

**Definition 2.2 (Formal derivative).** The *formal derivative* on `ℚ⟦X⟧`,
written `D`, sends `f = Σₙ cₙ Xⁿ` to `D f = Σₙ (n+1) c₍ₙ₊₁₎ Xⁿ`. Equivalently,
the `n`-th coefficient of `D f` is `(n+1)` times the `(n+1)`-st coefficient of
`f`. We write `Dᵏ` for the `k`-fold iterate `D ∘ ⋯ ∘ D`.

### 2.2 Species

**Definition 2.3 (Species).** A *combinatorial species* (in skeletal form) is a
triple `F = (obj, fintype, act)` consisting of:

- a family `obj : ℕ → Type` of structure types, where `F[n] := obj n` is the
  type of `F`-structures on an `n`-element label set;
- a proof that each `F[n]` is finite;
- for each `n`, a group homomorphism `act n : Perm(Fin n) → Perm(F[n])` encoding
  the functorial action of relabelling.

The data `act` makes `F` a functor on the core groupoid of finite sets.

**Definition 2.4 (Counting sequence and species EGF).** The *counting sequence*
of a species `F` is `F.coeffSeq n := |F[n]|`, the cardinality of the structure
type at size `n`. The *EGF of `F`* is

> `F.EGF := egf(n ↦ F.coeffSeq n) = Σₙ (|F[n]| / n!) Xⁿ`.

**Examples.** The species of sets `E` has `E[n] = {∗}` (a single structure on
every label set), so `E.coeffSeq n = 1` and `E.EGF = exp = Σ Xⁿ/n!`. The
species of linear orders `L` has `L[n] = Perm(Fin n)`, so `L.coeffSeq n = n!`
and `L.EGF = 1/(1−X)`.

### 2.3 The derivative species

**Definition 2.5 (Derivative species).** The *derivative* of a species `F` is
the species `F′ = F.derivative` with

> `F′[n] := F[n+1]`,

equipped with the relabelling action obtained by lifting a permutation of the
`n` honest labels to a permutation of `Fin (n+1)` that fixes the last "ghost"
point (via the embedding `Fin.castSuccEmb : Fin n ↪ Fin (n+1)`) and applying
`F.act (n+1)`. This makes `F′` a bona fide functor on the core groupoid. Its
counting sequence is `F′.coeffSeq n = F.coeffSeq (n+1)` by definition.

The `k`-fold derivative species is the iterate `F⁽ᵏ⁾ := F.derivative^[k]`.

---

## 3. The first-order bridge (recalled)

The Taylor tower rests on a single first-order identity, which we recall as it
is the inductive step for everything below.

**Proposition 3.1 (Derivative bridge for sequences).** For any `a : ℕ → ℚ`,

> `egf(n ↦ a(n+1)) = D(egf a)`.

*Proof sketch.* Compare `n`-th coefficients. The left side has coefficient
`a(n+1)/n!`. By Definition 2.2 the right side has coefficient
`(n+1)·(coefficient of Xⁿ⁺¹ in egf a) = (n+1)·a(n+1)/(n+1)!`. Since
`(n+1)! = (n+1)·n!`, the two are equal. ∎

**Corollary 3.2 (EGF of the derivative species).** For any species `F`,

> `(F′).EGF = D(F.EGF)`.

*Proof sketch.* `(F′).EGF = egf(n ↦ F.coeffSeq(n+1))` because
`F′.coeffSeq n = F.coeffSeq(n+1)`; apply Proposition 3.1 with
`a = F.coeffSeq`. ∎

We also use the **injectivity** of `egf`: if `egf a = egf b` then comparing
`n`-th coefficients gives `aₙ/n! = bₙ/n!`, and since `n! ≠ 0` in `ℚ`, `aₙ = bₙ`.
Hence `egf` is one-to-one, and the species EGF determines the counting sequence.

---

## 4. Main results

### 4.1 The Taylor tower for sequences

**Theorem 4.1 (`egf_seqDeriv_iterate`).** For any `a : ℕ → ℚ` and any `k ∈ ℕ`,

> `egf(n ↦ a(n+k)) = Dᵏ(egf a)`.

*Proof sketch.* Induct on `k`, generalising over `a`. The base case `k = 0` is
`egf a = egf a`. For the step, write `a(n + (k+1)) = (a∘(·+1))(n + k)` by
re-associating the addition, so that

`egf(n ↦ a(n+(k+1))) = egf(n ↦ (a∘(·+1))(n+k))`.

The induction hypothesis applied to the shifted sequence `a∘(·+1)` gives
`Dᵏ(egf(a∘(·+1)))`, and Proposition 3.1 rewrites `egf(a∘(·+1)) = D(egf a)`.
Using `Dᵏ(D g) = Dᵏ⁺¹ g` (the inner-peeling form of iterate composition,
`Function.iterate_succ_apply`) closes the step. The crucial technical point is
to generalise over `a`, because the inductive hypothesis is needed at the
*shifted* argument. ∎

### 4.2 The Taylor tower for species

**Theorem 4.2 (`coeffSeq_iterate_derivative`).** For any species `F` and any
`k, n ∈ ℕ`,

> `F⁽ᵏ⁾.coeffSeq n = F.coeffSeq (n + k)`,

i.e. `F⁽ᵏ⁾[n] = F[n+k]`: the `k`-th derivative species builds structures on `n`
honest labels with `k` extra ghost points.

*Proof sketch.* Induct on `k`, generalising over `n`. The base case is trivial.
For the step, expose the *outer* derivative using the outer-peeling form
`F.derivative^[k+1] = (F.derivative^[k]).derivative` (i.e.
`Function.iterate_succ_apply'`). Then
`(F.derivative^[k]).derivative.coeffSeq n = (F.derivative^[k]).coeffSeq (n+1)`
by Definition 2.5, and the induction hypothesis at `n+1` gives
`F.coeffSeq ((n+1) + k) = F.coeffSeq (n + (k+1))`. Generalising over `n` is
essential, since the step invokes the hypothesis at the shifted index `n+1`. ∎

**Theorem 4.3 (`taylor_coeffSeq`, Taylor evaluation at the origin).** For any
species `F` and any `k ∈ ℕ`,

> `F⁽ᵏ⁾.coeffSeq 0 = F.coeffSeq k`,

i.e. `F⁽ᵏ⁾[0] = F[k]`.

*Proof sketch.* Specialise Theorem 4.2 at `n = 0` and simplify `0 + k = k`. ∎

This is the species analogue of Taylor's theorem: the entire counting sequence
of `F` is recovered, one coefficient at a time, by climbing the derivative tower
and evaluating each rung on the empty label set.

### 4.3 The analytic tower

**Theorem 4.4 (`EGF_iterate_derivative`).** For any species `F` and any `k ∈ ℕ`,

> `(F⁽ᵏ⁾).EGF = Dᵏ(F.EGF)`.

*Proof sketch.* Induct on `k`. The base case `k = 0` is definitional. For the
step, rewrite both sides with the outer-peeling iterate identity: the left side
becomes `((F.derivative^[k]).derivative).EGF`, which by Corollary 3.2 equals
`D((F.derivative^[k]).EGF)`; the induction hypothesis rewrites the inner EGF as
`Dᵏ(F.EGF)`, and the right side `Dᵏ⁺¹(F.EGF)` matches after the same peeling. ∎

### 4.4 Maclaurin reconstruction

**Theorem 4.5 (`species_maclaurin`, Maclaurin reconstruction).** For any species
`F` and any `k ∈ ℕ`,

> `coeff₀(Dᵏ(F.EGF)) = F.coeffSeq k`,

where `coeff₀` denotes the constant term (the value at `X = 0`). That is, the
constant term of the `k`-fold formal derivative of the EGF recovers the
*un-normalised* count `F[k]` — with **no factorial correction**.

*Proof sketch.* By Theorem 4.4, `Dᵏ(F.EGF) = (F⁽ᵏ⁾).EGF`, so
`coeff₀(Dᵏ(F.EGF)) = coeff₀((F⁽ᵏ⁾).EGF)`. By Definition 2.1 the constant term of
any EGF `egf(b)` is `b₀/0! = b₀`. Hence
`coeff₀((F⁽ᵏ⁾).EGF) = F⁽ᵏ⁾.coeffSeq 0`, which equals `F.coeffSeq k` by
Theorem 4.3. ∎

**Remark 4.6 (Why the factorials cancel).** For an *ordinary* generating
function `g = Σ cₙ Xⁿ`, the Taylor/Maclaurin formula gives
`coeff₀(Dᵏ g) = k!·c_k`, decorated by the factorial `k!`. For the *exponential*
generating function, however, the coefficient `c_k` is already `a_k/k!`, so the
`k!` produced by `k`-fold differentiation is precisely cancelled, leaving the
bare count `a_k`. This cancellation is exactly why the EGF — and not the
ordinary GF — is the natural transform for the differential calculus of species:
the constant term of the `k`-th derivative reads off the species count directly,
without normalisation.

---

## 5. Worked example

Take the species of linear orders `L`, with `L.coeffSeq n = n!` and EGF
`L.EGF = 1/(1−X)`.

- **Tower formula (Theorem 4.2).** `L⁽ᵏ⁾[n] = L[n+k] = (n+k)!`. For instance,
  `L′[n] = (n+1)!` — a linear order on `n+1` labels with the last singled out.
- **Analytic tower (Theorem 4.4).** The `k`-fold derivative of `1/(1−X)` is
  `k!/(1−X)^{k+1}`, whose `n`-th coefficient is `(n+k)!/n!`; multiplying by `n!`
  (the EGF un-normalisation) recovers `(n+k)!`, matching the tower formula.
- **Maclaurin reconstruction (Theorem 4.5).** The constant term of `Dᵏ(1/(1−X))`
  is `k!` (the value of `k!/(1−X)^{k+1}` at `X = 0`), and indeed
  `L.coeffSeq k = k!`. The factorial that appears here is the *answer*, `L[k] =
  k!`, not an artefact of the normalisation.

A second example: the species of sets `E`, with `E.coeffSeq n = 1` and
`E.EGF = exp`. Differentiating `exp` any number of times returns `exp`, whose
constant term is `1`, and `E.coeffSeq k = 1` for all `k`. The tower of `E` is
the eigen-tower of the differentiation operator, mirroring the fact that `exp`
is its own derivative.

---

## 6. Algorithmic content

The theorems are constructive and yield direct algorithms over exact rational
arithmetic.

**Algorithm A (Maclaurin reconstruction).** Given the first `N+1` EGF
coefficients `c₀, …, c_N` of `F.EGF` (where `cₙ = F[n]/n!`), recover the counts
`F[0], …, F[N]`:

1. Set `g⁽⁰⁾ := (c₀, …, c_N)`.
2. For `j = 1, …, N`: form `g⁽ʲ⁾` by formal differentiation, i.e.
   `g⁽ʲ⁾ₙ = (n+1)·g⁽ʲ⁻¹⁾₍ₙ₊₁₎`, truncating at degree `N−j`.
3. Output `F[k] = g⁽ᵏ⁾₀` for each `k`.

Step 2 is `O(N)` per derivative and there are `N` derivatives, giving `O(N²)`
rational operations. The output is exact.

**Algorithm B (derivative-tower counts).** Given the counting sequence `F[·]`,
the `k`-th derivative species counts are obtained by the shift
`F⁽ᵏ⁾[n] = F[n+k]` (Theorem 4.2), a single table lookup; the corresponding EGF
is recovered by Theorem 4.4 as `Dᵏ(F.EGF)`.

Both algorithms are validated against the closed forms for `E` and `L` in the
accompanying numerical demonstration.

---

## 7. Discussion

### 7.1 The role of injectivity

The proofs are deliberately *computation-free* above the first-order bridge.
Once `egf` is known to be injective (Section 3), every identity whose analytic
shadow is a true power-series identity is automatic. The Taylor tower is the
purest illustration: the entire ladder is the inner-/outer-peeling of a single
`Function.iterate` and the single `k = 1` bridge. No combinatorial natural
isomorphism of structure sets needs to be constructed to obtain the enumerative
consequences.

### 7.2 Homotopical reading

A species is a functor on the *core groupoid* of finite sets, and its EGF is the
analytic shadow of a homotopy quotient. The derivative tower is then the tower of
"add-a-ghost-point" functors, and its value at the empty set is the homotopy-
fixed data at the origin. The Maclaurin reconstruction can be read as the
statement that this groupoid-cardinality data is fully recovered by the formal
differential operators — a discrete, 1-truncated shadow of the Taylor tower of
homotopy theory.

### 7.3 Relation to the broader dictionary

This work sits atop a layered formal development of the species–EGF dictionary:
the monoidal layer (sum and Day-convolution product, with `E ↔ exp` and
`L ↔ 1/(1−X)`); the first-order differential layer (derivative and pointed
species); the ring layer (the binomial convolution ring of counting sequences,
with `egf` a ring isomorphism onto `ℚ⟦X⟧`); and the homotopy layer (groupoid
cardinality). The Taylor tower is the differential layer carried to all orders.

---

## 8. Future work

Several natural extensions remain.

1. **The exponential formula `EGF(E ∘ G) = exp(EGF G)`.** Composition
   (substitution / plethysm) `F ∘ G` is the one major operation still outside
   the formalised dictionary. Its flagship instance `F = E` is the celebrated
   exponential formula: assembling a set of `G`-structures over a partition of
   the labels has EGF `exp(EGF G)` whenever `G` carries no structure on the empty
   set. The partition-indexed sum defining composition is governed by the
   Faà di Bruno / Bell-polynomial expansion, exactly the coefficientwise
   expansion of `exp` applied to a series with zero constant term.

2. **Faà di Bruno for the Taylor tower.** With the composition operation in
   place, the higher derivatives of a composite species should satisfy the
   species-theoretic Faà di Bruno formula, expressing `(F ∘ G)⁽ᵏ⁾` through the
   Bell polynomials in the derivatives of `F` and `G`.

3. **Homotopy invariance.** The relabelling action of a species is recorded but
   not yet load-bearing in the counting. Making it load-bearing via an explicit
   notion of species isomorphism and proving cardinality invariance would upgrade
   the development from a skeletal-counting theory to a genuinely homotopical one,
   in which the EGF is a localisation-invariant of the core groupoid.

4. **Multivariate and weighted species.** Extending the Taylor tower to species
   in several sorts of labels, and to weighted (cycle-index) refinements, would
   connect the calculus to symmetric-function theory and to the cycle-index
   series of Joyal–Bergeron–Labelle–Leroux.

---

## 9. Conclusion

We have formalised and machine-checked the complete Taylor tower of combinatorial
species: the `k`-fold derivative species `F⁽ᵏ⁾[n] = F[n+k]`, its evaluation at the
origin `F⁽ᵏ⁾[0] = F[k]`, the analytic identity `(F⁽ᵏ⁾).EGF = Dᵏ(F.EGF)`, and the
Maclaurin reconstruction `coeff₀(Dᵏ(F.EGF)) = F[k]`. The last of these exhibits
the exponential generating function as the canonical transform for the
differential calculus of species: the exponential normalisation cancels the
factorial of an ordinary Maclaurin expansion, so the raw species count is read
off directly as the constant term of an iterated derivative. The proofs are short
inductions reducing to a single first-order bridge, made possible by the
injectivity of the EGF transform — a vivid demonstration of the principle that,
across the combinatorial–analytic divide, the analytic shadow can prove the
combinatorial identity.
