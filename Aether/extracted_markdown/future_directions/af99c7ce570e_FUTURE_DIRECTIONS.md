# Future Directions — Units, Localness, and the Differential Ring of Combinatorial Species

## Synthesis

The catalog had already upgraded the exponential generating function (EGF) from a transform to a
genuine **isomorphism of commutative rings** `egfRingEquiv : ExpRing ≃+* ℚ⟦X⟧`
(`Catalog/Speculative/AutoResearch/SpeciesExponentialRing.lean`, building on
`Catalog/Applications/CombinatorialSpecies.lean`). The new file
`Catalog/Speculative/AutoResearch/SpeciesDifferentialUnits.lean` cashes that isomorphism in: it
harvests two structural theories of `ℚ⟦X⟧` — the **unit/local theory** and the **differential
theory** — as combinatorial facts about species, and binds them with one explicit example.

The local strand proves that a counting sequence is invertible under the binomial-convolution
(structural) product **iff** its empty-set count `a 0` is nonzero
(`isUnit_iff_constCoeff_ne_zero`), and that the binomial-convolution (Hurwitz) ring is a genuine
**local ring** (`instIsLocalRing`). Both descend through `egfRingEquiv` from
`PowerSeries.isUnit_iff_constantCoeff` and the locality of `ℚ⟦X⟧`, with the dictionary entry
"empty-set count = constant coefficient". The differential strand proves that the shift
`a ↦ a(·+1)` (Joyal's derivative species) is a **derivation**: its Leibniz rule
`shift (a·b) = shift a · b + a · shift b` (`shift_mul`) is *forced* by
`PowerSeries.derivativeFun_mul`, not recomputed combinatorially, and it is packaged as the additive
endomorphism `shiftHom`. The two strands meet at `binConv_one_signed` / `isUnit_setSpecies`: the
species of sets `E` (constant-one sequence, EGF `exp`) is a unit whose explicit
binomial-convolution inverse is the **signed-sets** species `n ↦ (-1)ⁿ` (EGF `exp(-X)`), because
`exp(X)·exp(-X) = 1` — the analytic shadow of the inclusion–exclusion identity
`∑ᵢ C(n,i)(-1)^{n-i} = [n = 0]`.

A methodological lesson carried forward: never manipulate `binConv`/`deltaSeq` directly inside
`ExpRing` proofs (the transported ring's `*`/`1` are not always defeq-friendly for
`exact`/`rw`); instead push everything through `egfRingEquiv` with `map_mul`, `map_add`,
`isUnit_map_iff`, where the homomorphism laws make the algebra transparent. With that discipline,
`shift_mul` collapses to a single `ring` identity in `ℚ⟦X⟧` after `derivativeFun_mul`.

## Results Summary

All results compile with no `sorry` and depend only on the standard axioms `propext`,
`Classical.choice`, `Quot.sound`.

* `ExpRing.isUnit_iff_constCoeff_ne_zero` — a counting sequence is a unit for the binomial
  convolution iff its empty-set count is nonzero.
* `ExpRing.instIsLocalRing` — the binomial-convolution (Hurwitz) ring is a local ring.
* `ExpRing.shift_mul` — the Leibniz rule for the structural product; the shift is a derivation.
* `ExpRing.shiftHom` — the shift bundled as an additive group endomorphism (derivation backbone).
* `ExpRing.binConv_one_signed` / `ExpRing.isUnit_setSpecies` — the species of sets is a unit, with
  the signed-sets species `n ↦ (-1)ⁿ` as its explicit binomial-convolution inverse.

## Research Directions

### 1. The maximal ideal and the recursive (Neumann) inverse of a species

Now that `ExpRing` is known to be local, name its maximal ideal explicitly and turn the abstract
invertibility criterion into an *algorithm*. The conjecture is that
`IsLocalRing.maximalIdeal ExpRing` is exactly `{a | a 0 = 0}` (species with no empty-set structure),
and that the inverse of a unit `a` is computed by the binomial-convolution Neumann recursion
`b 0 = (a 0)⁻¹`, `b n = -(a 0)⁻¹ · ∑_{i<n} C(n,i) · a(n-i) · b i`, which should be provably equal to
the explicit inverse from `isUnit_iff_constCoeff_ne_zero`. The key insight is that
`IsLocalRing.maximalIdeal` commutes with `RingEquiv`, so the maximal-ideal identity is the
`egfRingEquiv`-preimage of `{f | constantCoeff f = 0}` and the whole valuation theory descends from
the power-series side with *no new combinatorics*. Why now? `instIsLocalRing` and
`isUnit_iff_constCoeff_ne_zero` are already in place, so the ideal identity is a one-line transport
and the recursion is `PowerSeries.invOfUnit` read through the inverse transform `egfInv`.

### 2. Bundling the shift as a genuine `Derivation` and the species exp/log ODE

`shift_mul` and `shiftHom` give the Leibniz law and additivity, but the shift is not yet Mathlib's
`Derivation`. The conjecture is that, after equipping `ExpRing` with its transported `ℚ`-algebra
structure, the shift upgrades to a `Derivation ℚ ExpRing ExpRing`, that `egfRingEquiv` becomes an
isomorphism of *differential* `ℚ`-algebras intertwining it with `derivativeFun`, and that the
species of sets satisfies the fixed-point ODE `shift oneSeq = oneSeq` (i.e. `D(exp) = exp`). The key
insight is that once the shift is a bona fide derivation, every classical species identity
expressible through `d/dX` becomes a corollary of the differential isomorphism rather than a bespoke
proof. Why now? `shift_mul`, `shiftHom`, and `egfRingEquiv` already exist; the only missing
ingredient is the transported `Algebra ℚ ExpRing` instance, after which the `Derivation` fields are
exactly the additivity and Leibniz lemmas already proved.

### 3. The logarithmic derivative and connected/derangement-style recurrences

With the shift a derivation and units characterised, define the **logarithmic derivative**
`logDeriv a = shift a · a⁻¹` of a unit species `a` (well-defined precisely when `a 0 ≠ 0`). The
conjecture is that `logDeriv` is additive on the *multiplicative* monoid of units
(`logDeriv (a·b) = logDeriv a + logDeriv b`) — the species analogue of `(fg)'/(fg) = f'/f + g'/g` —
and that for the species of sets `logDeriv oneSeq = oneSeq`, recovering the exponential-formula
relation "labelled structures = exp(connected structures)" at the level of counting sequences. The
key insight is that the logarithmic derivative converts the *multiplicative* unit theory of
Direction 1 into the *additive* derivation theory of Direction 2, so recurrences for derangements
and other "connected-component" species become linear identities. Why now? Both halves —
`shift_mul` and `isUnit_iff_constCoeff_ne_zero` — are proved, so `logDeriv` is definable today and
its homomorphism law is `shift_mul` plus `mul_inv` bookkeeping transported through `egfRingEquiv`.

### 4. Higher shifts, Hasse derivatives, and a species Taylor theorem

The shift iterates to `a ↦ a(·+k)`, the `k`-fold derivative species, already studied analytically in
`SpeciesTaylorCalculus.lean`. The conjecture is that these assemble into a **Hasse-derivative**
calculus on `ExpRing`, intertwined by `egfRingEquiv` with Mathlib's `PowerSeries.hasseDeriv`,
yielding a divided-power Taylor expansion `a = ∑_k (a k) · X^{[k]}` where `X^{[k]}` is the species of
a distinguished `k`-set, together with a *graded Leibniz rule* generalising `shift_mul`. The key
insight is that the divided-power structure of `ℚ⟦X⟧` is the correct combinatorial home for
"choosing `k` distinguished labels", so the binomial coefficients pervading species enumeration are
exactly Hasse-derivative coefficients in disguise. Why now? The single-step derivation `shift_mul`
is proved and Mathlib has `hasseDeriv` with its Leibniz rule, so the iteration is a clean induction
transported across the isomorphism, reusing the `egf_seqDeriv_iterate` tower already in the catalog.

### 5. The substitution product, the maximal ideal, and the exponential formula

The two monoidal operations formalised (sum and product) are two thirds of Joyal's calculus; the
third is **substitution** `F ∘ G` ("an `F`-structure of `G`-structures"). The conjecture is that the
EGF remains a homomorphism for substitution, `EGF(F ∘ G) = EGF(F) ∘ EGF(G)` whenever `G` has no
constant term, with the **exponential formula** `EGF(E ∘ G) = exp(EGF G)` as flagship case — and,
crucially, that "no constant term" is *precisely* membership in the maximal ideal `{a | a 0 = 0}`
identified in Direction 1. The key insight is that substitution appears in `ExpRing` as a second,
non-linear composition intertwined by `egfRingEquiv` with `PowerSeries.comp`, so the unit theory and
the substitution theory are two faces of the same local-ring structure. Why now? The ring
isomorphism supplies the dictionary in both directions, Mathlib has a usable formal-composition API,
and the only genuinely new combinatorial content is a single partition-cardinality lemma analogous
to the product law `egf_mul`.
