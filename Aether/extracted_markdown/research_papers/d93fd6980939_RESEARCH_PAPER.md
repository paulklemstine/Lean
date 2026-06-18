# The Analytic Bridge for Combinatorial Species: Sum, Product, Inversion, Differentiation, and Pointing

## Abstract

We develop a self-contained, fully rigorous account of the classical correspondence,
due to Joyal, between *combinatorial species* and *exponential generating functions*
(EGFs), and we extend it from a merely algebraic correspondence into a *differential*
and *bijective* one. Working over the rationals `ℚ`, we model a counting sequence as a
function `a : ℕ → ℚ`, its EGF as the formal power series `egf(a) = Σₙ (aₙ/n!) Xⁿ`, and a
combinatorial species (in skeletal form) as a family of finite structure types together
with a symmetric-group action encoding relabelling. We prove four families of results.
**(I) Homomorphism.** `egf` carries the disjoint-union (sum) of species to addition of
series (`egf_add`) and the Day-convolution (structural) product of species to
multiplication of series (`egf_mul`), the latter resting on the cardinality identity
`card_prodSpecies` that the structural product realizes the binomial convolution; it sends
the species of sets to `exp` and the species of linear orders to `1/(1−X)`. **(II)
Inversion.** `egf` is a *bijection* `(ℕ → ℚ) ≃ ℚ⟦X⟧` with the explicit two-sided inverse
`seqOf(f)ₙ = n!·[Xⁿ]f`; hence the EGF is a *complete invariant* for labelled enumeration
(`Species.EGF_inj`). **(III) Differentiation and pointing.** The derivative species
`F'[n] = F[n+1]` maps to the formal derivative `d/dX` (`egf_seqDeriv`), and the pointed
species `F^•[n] = n·F[n]` maps to `X·d/dX` (`egf_seqPoint`). **(IV) Leibniz.** The
structural product rule `(F·G)' = F'·G + F·G'` holds at the level of counting sequences
(`binConv_leibniz`), obtained by transporting the analytic product rule across the
bijective bridge with no index manipulation. We give proof sketches for all results,
algorithms realizing them numerically, applications to classical enumeration and to random
generation, and a programme of future directions (substitution/plethysm, cycle-index
series and Pólya theory, the `λ`-ring/`RingHom` structure, and a skeletal-to-genuine
categorical comparison).

**Keywords.** combinatorial species, exponential generating function, binomial convolution,
Day convolution, analytic functor, formal power series, formal derivative, complete
invariant, Leibniz rule, enumerative combinatorics.

---

## 1. Introduction

Enumerative combinatorics asks: in how many ways can one impose a given kind of structure
on a finite set of `n` labelled elements? The answer is a sequence of nonnegative integers
`(aₙ)_{n≥0}`. Generating-function methods encode such a sequence as a single analytic
object whose algebraic manipulations mirror combinatorial constructions. For *labelled*
structures the appropriate encoding is the **exponential generating function**

```
EGF(a)(X) = Σ_{n≥0} (aₙ / n!) Xⁿ.
```

André Joyal's theory of **species** (1981) reorganizes this machinery conceptually: a
species is a functor from the groupoid of finite sets and bijections to the category of
finite sets, and its EGF is the associated *analytic functor's* exponential generating
function. In this language, natural categorical operations on species — sum, product,
substitution, derivative — correspond to natural operations on power series — sum, product,
plethystic composition, formal derivative.

This paper formalizes the foundational rungs of that correspondence and sharpens them.
Beyond the standard homomorphism laws (sum and product), we establish three structural
facts that are often left informal:

1. The EGF is not merely structure-preserving but *bijective*, with an explicit inverse —
   so it loses no enumerative information (a *complete invariant*).
2. The EGF intertwines the combinatorial derivative (adjoining a ghost label) with the
   analytic formal derivative, and the pointing operation with `X·d/dX`.
3. The combinatorial Leibniz rule follows *for free* from the analytic one by transport
   across the bijection.

All statements are theorems with complete proofs; the proof sketches below indicate the
key steps and the precise auxiliary facts they invoke.

### 1.1 Conventions

We work over the field `ℚ`. Formal power series in one variable over `ℚ` are written
`ℚ⟦X⟧`, with `[Xⁿ]f` (or `coeff n f`) denoting the coefficient of `Xⁿ` in `f`. A *counting
sequence* is a function `a : ℕ → ℚ` (we allow rational values for algebraic convenience;
genuine counting sequences are `ℕ`-valued and are cast into `ℚ`). We write `n!` for the
factorial and `C(n, i) = n!/(i!·(n−i)!)` for the binomial coefficient.

---

## 2. Generating functions of counting sequences

### 2.1 Definition

**Definition 2.1 (EGF).** For `a : ℕ → ℚ`, the *exponential generating function* is
```
egf(a) := Σ_{n≥0} (aₙ / n!) Xⁿ  ∈ ℚ⟦X⟧,
```
i.e. the power series whose `n`-th coefficient is `aₙ / n!`.

**Lemma 2.2 (coefficient extraction, `coeff_egf`).** For all `n`,
`[Xⁿ] egf(a) = aₙ / n!`.

*Proof sketch.* Immediate from the definition of `egf` as the series with prescribed
coefficients (`PowerSeries.coeff_mk`). ∎

Lemma 2.2 is the workhorse of the entire paper: every subsequent identity is verified by
comparing coefficients and reducing to Lemma 2.2.

### 2.2 The binomial convolution

**Definition 2.3 (binomial convolution, `binConv`).** For `a, b : ℕ → ℚ`,
```
(a ⋆ b)ₙ := Σ_{i + j = n} C(n, i) · aᵢ · bⱼ,
```
the sum being over the antidiagonal `{(i,j) : i + j = n}`.

This is the *exponential* (or *binomial*) convolution, the labelled analogue of the Cauchy
product; it is the counting sequence of the structural product of species (Section 5).

---

## 3. The homomorphism laws

### 3.1 Sum

**Theorem 3.1 (Sum law, `egf_add`).** For all `a, b : ℕ → ℚ`,
```
egf(λ n, aₙ + bₙ) = egf(a) + egf(b).
```

*Proof sketch.* Compare coefficients: by Lemma 2.2 both sides have `n`-th coefficient
`(aₙ + bₙ)/n!`, which splits additively as `aₙ/n! + bₙ/n!`. ∎

### 3.2 Product

**Theorem 3.2 (Product law, `egf_mul`).** For all `a, b : ℕ → ℚ`,
```
egf(a ⋆ b) = egf(a) · egf(b).
```

*Proof sketch.* The `n`-th coefficient of the right-hand side is the Cauchy product
`Σ_{i+j=n} (aᵢ/i!)(bⱼ/j!)`. The `n`-th coefficient of the left-hand side is
`(1/n!)·Σ_{i+j=n} C(n,i)·aᵢ·bⱼ`. Equality follows term by term from the factorial identity
`C(n,i) = n!/(i!·j!)` (with `j = n−i`), i.e. `C(n,i)·i!·j! = n!`
(`Nat.choose_mul_factorial_mul_factorial`). The formal proof distributes `1/n!` across the
antidiagonal sum and rewrites `C(n,i)` via `Nat.cast_choose`, taking care that
`j = n − i` on the antidiagonal. ∎

Theorem 3.2 is the analytic heart of the theory: the exponential normalization turns the
combinatorially natural binomial convolution into ordinary series multiplication.

### 3.3 Two fundamental species (as sequences)

**Theorem 3.3 (Sets ↔ `exp`, `egf_const_one`).** The constant-one sequence
`a ≡ 1` (one structure on every label set — the species `E` of sets) has
```
egf(λ n, 1) = exp(X) = Σ_{n≥0} Xⁿ/n!.
```

*Proof sketch.* Both sides have `n`-th coefficient `1/n!` (Lemma 2.2 on the left;
`PowerSeries.coeff_exp` on the right, noting `algebraMap ℚ ℚ = id`). ∎

**Theorem 3.4 (Linear orders ↔ `1/(1−X)`, `egf_linearOrderSpecies`).** The factorial
sequence `aₙ = n!` (the species `L` of linear orders, since there are `n!` orderings of `n`
labels) satisfies
```
(1 − X) · egf(λ n, n!) = 1,
```
i.e. `egf(L) = 1/(1−X)`.

*Proof sketch.* Here `egf(λ n, n!) = Σₙ (n!/n!) Xⁿ = Σₙ Xⁿ`, the geometric series. Multiply
by `(1 − X)` and compare coefficients: the constant term is `1`, and for `n ≥ 1` the
coefficient telescopes to `1 − 1 = 0`. ∎

---

## 4. Species as functors on the groupoid of finite sets

**Definition 4.1 (Species, skeletal form).** A *combinatorial species* `F` consists of:
- a family `obj : ℕ → Type` with each `F[n] := obj(n)` finite (the set of `F`-structures
  on a fixed `n`-element label set);
- for each `n`, a monoid homomorphism `act(n) : Perm(Fin n) → Perm(F[n])` encoding the
  functorial action of relabelling (the symmetric group `Sₙ`) on structures.

The `act` field records that `F` is a genuine functor on the *core groupoid* of finite
sets, not merely a sequence of cardinalities. (It is not used by the EGF theorems, which
see only cardinalities; it becomes load-bearing for the cycle-index/Pólya refinement —
see Section 9.)

**Definition 4.2 (counting sequence and EGF of a species).**
```
F.coeffSeq(n) := |F[n]|  (the cardinality, in ℕ),
F.EGF := egf(λ n, (F.coeffSeq n : ℚ)).
```

**Definition 4.3 (two basic species).**
- The *species of sets* `E` (`setSpecies`): `E[n] := Unit` for all `n`, with trivial
  action. Then `E.coeffSeq(n) = 1`.
- The *species of linear orders* `L` (`linearOrderSpecies`): `L[n] := Perm(Fin n)`, with
  `act` the regular (left-translation) action. Then `L.coeffSeq(n) = n!`
  (`Fintype.card_perm`).

**Corollary 4.4 (`EGF_setSpecies`).** `E.EGF = exp`. *Proof.* `E.coeffSeq ≡ 1`, then apply
Theorem 3.3. ∎

---

## 5. The structural product and the bridge theorem

The *structural product* (Day convolution) of two structure families `A, B : ℕ → Type` is
```
(A · B)[n] := Σ_{S ⊆ {1,…,n}} A[|S|] × B[n − |S|],
```
the disjoint union, over subsets `S` of the label set, of pairs consisting of an
`A`-structure on `S` and a `B`-structure on its complement.

**Theorem 5.1 (cardinality of the product, `card_prodSpecies`).** For families `A, B` with
finite values,
```
| Σ_{S : Finset(Fin n)} A[|S|] × B[n − |S|] |  =  Σ_{i + j = n} C(n, i) · |A[i]| · |B[j]|.
```

*Proof sketch.* Compute the cardinality of the sigma-type as a sum over subsets `S`
(`Fintype.card_sigma`, `Fintype.card_prod`), giving `Σ_{S} |A[|S|]|·|B[n−|S|]|`. Group the
subsets by their cardinality `k`: the universe of subsets is the disjoint union over
`k ∈ {0,…,n}` of the size-`k` subsets, and there are `C(n,k)` of those
(`Finset.powersetCard`, with disjointness across distinct `k`). Re-indexing the resulting
double sum as an antidiagonal sum yields the binomial convolution. ∎

**Theorem 5.2 (product bridge, `egf_card_prodSpecies`).** With the same hypotheses,
```
egf(λ n, |(A·B)[n]|) = egf(λ n, |A[n]|) · egf(λ n, |B[n]|).
```

*Proof sketch.* By Theorem 5.1 the left-hand sequence equals the binomial convolution
`(|A| ⋆ |B|)` (after casting `ℕ → ℚ`); apply Theorem 3.2 (`egf_mul`). ∎

Theorem 5.2 is the precise statement that the EGF realizes the analytic functor: it turns
the Day-convolution product of species into the ordinary product of power series.

---

## 6. Inversion: the EGF is a bijection

The EGF is usually presented as a *homomorphism*. We show it is in fact an *isomorphism of
sets* with an explicit inverse, hence loses no information.

**Definition 6.1 (inverse map, `seqOf`).** For `f ∈ ℚ⟦X⟧`,
```
seqOf(f)(n) := n! · [Xⁿ] f.
```

**Lemma 6.2 (`seqOf_egf`).** `seqOf(egf(a)) = a`.
*Proof sketch.* By Lemmas 2.2 and Def. 6.1, `seqOf(egf(a))(n) = n!·(aₙ/n!) = aₙ`, using
`n! ≠ 0` (`Nat.factorial_ne_zero`) to cancel. ∎

**Lemma 6.3 (`egf_seqOf`).** `egf(seqOf(f)) = f`.
*Proof sketch.* Compare coefficients: `[Xⁿ] egf(seqOf f) = seqOf(f)(n)/n! = (n!·[Xⁿ]f)/n! =
[Xⁿ]f`. ∎

**Theorem 6.4 (bijectivity, `egf_injective`, `egf_surjective`, `egf_bijective`).** The map
`egf : (ℕ → ℚ) → ℚ⟦X⟧` is injective, surjective, and hence bijective.

*Proof sketch.* Injectivity: if `egf(a) = egf(b)` apply `seqOf` and use Lemma 6.2.
Surjectivity: for any `f`, `egf(seqOf f) = f` by Lemma 6.3. ∎

**Definition/Theorem 6.5 (the EGF equivalence, `egfEquiv`).** The data
`(egf, seqOf)` with Lemmas 6.2–6.3 assemble into an equivalence of types
```
egfEquiv : (ℕ → ℚ) ≃ ℚ⟦X⟧.
```

**Theorem 6.6 (complete invariant, `Species.EGF_inj`).** For species `F, G`,
```
F.EGF = G.EGF  ⟺  F.coeffSeq = G.coeffSeq.
```

*Proof sketch.* (⇒) Apply `egf_injective` to obtain equality of the `ℚ`-valued sequences,
then cast back to `ℕ` (the cardinalities are natural numbers, and the cast `ℕ → ℚ` is
injective). (⇐) If the counting sequences agree, the EGFs are equal by definition. ∎

Theorem 6.6 is the *labelled complete-invariance* statement: the EGF determines, and is
determined by, the full counting sequence of a species.

**Remarks on the rig unit and zero.**
- **Zero (`egf_zero`).** `egf(λ n, 0) = 0`, since every coefficient is `0/n! = 0`.
- **Unit (`egf_binConvOne`).** Define `binConvOne(n) := 1` if `n = 0`, else `0` (the
  sequence `(1,0,0,…)`, the unit `1` of the species rig: one structure on the empty set,
  none otherwise). Then `egf(binConvOne) = 1`, because only the `n = 0` term survives,
  contributing `1/0! = 1`.

Together with Theorems 3.1 and 3.2, these say `egf` preserves `0`, `1`, `+`, and `⋆` — it
is a rig homomorphism — and by Theorem 6.4 a bijective one.

---

## 7. Differentiation and pointing

**Definition 7.1 (derivative sequence/species, `seqDeriv`).**
```
seqDeriv(a)(n) := a(n + 1).
```
Combinatorially this is the *derivative species* `F'[n] := F[n + 1]`: an `F'`-structure on
`n` labels is an `F`-structure on `n + 1` labels with a distinguished adjoined "ghost"
label.

**Theorem 7.2 (derivative law, `egf_seqDeriv`).**
```
egf(seqDeriv a) = (egf a)'   (the formal derivative d/dX).
```

*Proof sketch.* Compare coefficients. On the left, `[Xⁿ] egf(seqDeriv a) = a(n+1)/n!`. On
the right, the formal derivative has `[Xⁿ]` equal to `(n+1)·[Xⁿ⁺¹] egf(a) =
(n+1)·a(n+1)/(n+1)!` (`PowerSeries.coeff_derivativeFun`). Since `(n+1)! = (n+1)·n!`, both
equal `a(n+1)/n!`. ∎

**Definition 7.3 (pointing, `seqPoint`).**
```
seqPoint(a)(n) := n · a(n).
```
Combinatorially this is the *pointed species* `F^•[n] := {1,…,n} × F[n]`: mark one of the
`n` labels as special.

**Theorem 7.4 (pointing law, `egf_seqPoint`).**
```
egf(seqPoint a) = X · (egf a)'.
```

*Proof sketch.* For `n = 0` both sides have vanishing constant term (`X·(…)` kills it, and
`seqPoint(a)(0) = 0`). For `n = m+1`, `[Xⁿ](X·(egf a)') = [Xᵐ](egf a)' = (m+1)·a(m+1)/(m+1)!
= a(m+1)/m!`, matching `[Xⁿ] egf(seqPoint a) = (m+1)·a(m+1)/(m+1)! = a(m+1)/m!`. ∎

Theorems 7.2 and 7.4 upgrade the bridge from algebraic to *differential*: the
combinatorial operations of adjoining and of marking a label are exactly `d/dX` and
`X·d/dX`.

---

## 8. The structural Leibniz rule

**Theorem 8.1 (combinatorial Leibniz, `binConv_leibniz`).** For counting sequences
`a, b`,
```
seqDeriv(a ⋆ b) = (seqDeriv a) ⋆ b + a ⋆ (seqDeriv b),
```
i.e. at the level of species `(F·G)' = F'·G + F·G'`.

*Proof sketch.* Apply the bijective bridge. Both sides are counting sequences; by
injectivity of `egf` (Theorem 6.4) it suffices to prove the identity after applying `egf`.
The left side becomes `egf(seqDeriv(a⋆b)) = (egf(a⋆b))' = (egf a · egf b)'` (Theorems 7.2,
3.2). The right side becomes `egf(seqDeriv a)·egf b + egf a·egf(seqDeriv b) = (egf a)'·egf b
+ egf a·(egf b)'` (Theorems 3.1, 3.2, 7.2). These agree by the analytic product rule
`(fg)' = f'g + fg'` (`PowerSeries.derivativeFun_mul`, reconciling the scalar action `•`
with multiplication via `smul_eq_mul` and commutativity). ∎

Theorem 8.1 exemplifies the central methodological dividend of inversion: a combinatorial
identity about binomial convolutions is proved with *no* index manipulation, by transport
of an analytic identity across the bijection.

---

## 9. Discussion

### 9.1 What the bridge buys

The results assemble into a dictionary:

| Species operation | EGF operation | Theorem |
|---|---|---|
| sum `F + G` | `+` | 3.1 |
| product `F · G` (Day convolution) | `·` | 3.2, 5.2 |
| sets `E` | `exp` | 3.3, 4.4 |
| linear orders `L` | `1/(1−X)` | 3.4 |
| zero / unit | `0` / `1` | §6 |
| derivative `F'` (ghost label) | `d/dX` | 7.2 |
| pointing `F^•` (mark a label) | `X·d/dX` | 7.4 |
| Leibniz `(F·G)' = F'G + FG'` | product rule | 8.1 |
| distinct counts | distinct series (bijection) | 6.4, 6.6 |

Two methodological points stand out. First, the factorial normalization in Def. 2.1 is not
cosmetic: it is exactly what converts the binomial convolution into ordinary multiplication
(Theorem 3.2) and the `aₙ ↦ aₙ₊₁` shift into the formal derivative (Theorem 7.2). Second,
the *explicit* inverse (Def. 6.1) makes inversion elementary — no analytic estimates, no
fixed-point arguments — and that elementary inversion is precisely what powers the
transport proof of the Leibniz rule.

### 9.2 Relationship to analytic functors

In Joyal's framework a species is a functor `B → FinSet` on the groupoid `B` of finite sets
and bijections, and the EGF is the generating function of the associated analytic functor
`Type → Type`, `F(A) = Σₙ F[n] ×_{Sₙ} Aⁿ`. The sum and product laws are the statements that
this assignment is monoidal for the disjoint-union and Day-convolution monoidal structures.
The derivative law is the species-level shadow of the derivative of an analytic functor
(differentiation of data types, in the computer-science reading). Our skeletal model retains
exactly the data needed for the labelled (EGF) theory; the `act` field anticipates the
unlabelled (cycle-index/Pólya) refinement.

---

## 10. Algorithms

The bridge is constructive and yields directly executable algorithms over exact rational
arithmetic.

- **EGF coefficient evaluation.** Given `(aₙ)` and a truncation order `N`, output the list
  `(aₙ/n!)_{n≤N}`. (Realizes Def. 2.1.)
- **Inverse / `seqOf`.** Given series coefficients `(cₙ)`, output `(n!·cₙ)`. (Realizes
  Def. 6.1; together with the previous algorithm it is a verified round-trip,
  Lemmas 6.2–6.3.)
- **Binomial convolution.** Given `(aₙ), (bₙ)` and `N`, output
  `(Σ_{i+j=n} C(n,i) aᵢ bⱼ)_{n≤N}`. (Realizes Def. 2.3; cross-checked against the Cauchy
  product of the EGFs, Theorem 3.2.)
- **Derivative / pointing.** Shift `aₙ ↦ aₙ₊₁` and scale `aₙ ↦ n·aₙ`; cross-check against
  `d/dX` and `X·d/dX` of the EGF (Theorems 7.2, 7.4).
- **Leibniz check.** Verify `seqDeriv(a⋆b) = seqDeriv(a)⋆b + a⋆seqDeriv(b)` coefficientwise
  (Theorem 8.1).

See `demo.py` for reference implementations and worked numerical examples.

---

## 11. Applications

- **Closed-form enumeration.** "Split `n` labels into a left order and a right order" is
  `L · L`, EGF `1/(1−X)²`, coefficients `(n+1)!`. "Partition into an arbitrary number of
  ordered blocks" and similar constructions reduce to series algebra.
- **The exponential formula (next rung).** The substitution `E ∘ G` ("sets of
  `G`-structures") has EGF `exp(EGF G)`; this is the single most-used identity in labelled
  enumeration and the immediate sequel to the product law (Section 12).
- **Random generation.** Boltzmann samplers draw uniform random labelled objects of a given
  expected size directly from the EGF; the derivative and pointing operations (Theorems
  7.2, 7.4) implement the standard size-targeting (pointing) step.
- **Verified combinatorics.** Because the bridge is a *bijection* (Theorem 6.4), any
  identity proved on either side transfers automatically; the Leibniz rule (Theorem 8.1) is
  a template for deriving combinatorial identities from analytic ones with no manual index
  algebra.

---

## 12. Future directions

**Direction 1 — Substitution (composition) and the exponential formula.** Define species
substitution `(F ∘ G)[n] = Σ_{π ∈ Part(n)} F[π] × ∏_{B∈π} G[B]` over set partitions, and
prove its EGF is the plethystic composition `(EGF F) ∘ (EGF G)` (for `G` with zero constant
term). Specializing `F = E` (sets) yields the **exponential formula**: the EGF of "sets of
`G`-structures" is `exp(EGF G)`. The cardinality computation `card_prodSpecies` already
isolates the only hard step — counting subsets by cardinality — and substitution iterates
it over a partition, so `|(F∘G)[n]|` is a partition-sum of multinomials times `∏|G[B]|`,
which is exactly coefficient extraction for plethystic composition. The partition apparatus
(`Finpartition`, Bell/Stirling numbers) is available, making this the natural next theorem.

**Direction 2 — Cycle-index series and unlabelled enumeration (Pólya theory).** Replace the
EGF (which sees only `|F[n]|`) by the cycle-index series
`Z_F = Σₙ (1/n!) Σ_{σ∈Sₙ} |Fix(F[σ])| · p₁^{c₁(σ)} p₂^{c₂(σ)} ⋯` in symmetric functions, and
prove `Z_{F+G} = Z_F + Z_G`, `Z_{F·G} = Z_F·Z_G`, and that specializing `pₖ ↦ xᵏ` yields the
*ordinary* generating function for unlabelled structures while `p₁ ↦ x, p_{k≥2} ↦ 0`
recovers the EGF. The `act` field is precisely the data the cycle index needs, turning the
currently-decorative functorial structure into a load-bearing invariant and connecting to
the symmetric-function (`MvPolynomial`) library.

**Direction 3 — The Species–EGF map as a `RingHom`/`λ`-ring.** Assemble counting sequences
under `(+, ⋆)` into a commutative semiring and upgrade `egf` to a bundled `RingHom`, proving
`egf 0 = 0`, `egf 1 = 1`, `egf(a+b) = egf a + egf b`, `egf(a⋆b) = egf a·egf b` at once, and
its injectivity (so equal EGFs imply equal counting sequences). The homomorphism axioms are
already proved (Theorems 3.1, 3.2), `egf_zero`/`egf_binConvOne` give unit/zero, and
injectivity is immediate from the explicit inverse (Def. 6.1). Bundling makes the bridge
reusable by `simp`/`ring`-style automation.

**Direction 4 — Derivative and pointing as natural isomorphisms; the differential
structure.** Promote Theorems 7.2, 7.4, and 8.1 to genuine natural isomorphisms of species
(`F'`, `F^•`, and the product rule as a bijection of structure sets), making the species
category a differential one and the bridge a differential ring map. Mathlib's
`PowerSeries.derivativeFun` provides the analytic side for free.

**Direction 5 — Skeletal-to-genuine categorical comparison.** Promote the skeletal `Species`
structure to a genuine functor `FinBij ⥤ FintypeCat` on the groupoid of finite sets and
bijections, and prove the two presentations equivalent (restriction to the skeleton
`{Fin n}` is an equivalence of functor categories), so all EGF theorems transport. The
groupoid of finite sets is equivalent to its skeleton `∐ₙ BSₙ` (one object per cardinality
with automorphism group `Sₙ`), which is exactly the `(obj, act)` data; with mature
`CategoryTheory.Skeleton` and `FintypeCat`, this justifies calling the EGF an *analytic
functor* in the literal categorical sense.

---

## 13. Conclusion

We have formalized the foundational dictionary of combinatorial species and exponential
generating functions and extended it into a bijective and differential correspondence. The
EGF is a homomorphism for sum and product, sends the canonical species to `exp` and
`1/(1−X)`, is a bijection with an explicit inverse (hence a complete invariant), and
intertwines the combinatorial derivative and pointing with `d/dX` and `X·d/dX`; the
combinatorial Leibniz rule then follows by transport. These results turn the
combinatorial–analytic bridge from a heuristic into a precise, invertible, calculus-respecting
equivalence, and lay the groundwork for substitution/plethysm, cycle-index/Pólya theory, and
the full categorical theory of analytic functors.
