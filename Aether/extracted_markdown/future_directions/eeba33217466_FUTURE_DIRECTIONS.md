# Future Directions — Units, Localness, and the Differential Ring of Combinatorial Species

## Synthesis

The catalog established the exponential generating function (EGF) as an **isomorphism of
commutative rings** `egfRingEquiv : ExpRing ≃+* ℚ⟦X⟧`, identifying the binomial-convolution
(Hurwitz) ring of counting sequences with formal power series over `ℚ`
(`Catalog/Speculative/AutoResearch/SpeciesExponentialRing.lean`, building on
`Catalog/Applications/CombinatorialSpecies.lean`). The point of an *isomorphism* — as opposed to a
mere pair of homomorphism laws — is that it transports structure in both directions essentially for
free. The new file `Catalog/Speculative/AutoResearch/SpeciesDifferentialUnits.lean` exploits exactly
this, harvesting two structural theories of `ℚ⟦X⟧` as combinatorial facts about species and tying
them together with one concrete, fully explicit example.

Two strands are developed. The **local structure**: a species/counting sequence is invertible under
the structural product **iff** its empty-set count `a 0` is nonzero
(`isUnit_iff_constCoeff_ne_zero`), and the binomial-convolution ring is a genuine **local ring**
(`instIsLocalRing`), both transported through `egfRingEquiv` from
`PowerSeries.isUnit_iff_constantCoeff` and the locality of `ℚ⟦X⟧`. The **differential structure**:
the shift operator `a ↦ a(·+1)` is a *derivation* of the binomial convolution — its Leibniz rule
`(F·G)′ = F′·G + F·G′` (`shift_mul`) is *forced* by `PowerSeries.derivativeFun_mul` through the
isomorphism, not proved by a separate combinatorial computation. The two strands meet at
`binConv_one_signed`/`isUnit_setSpecies`: the species of sets `E` (constant-one sequence, EGF `exp`)
is a unit, and its explicit inverse is the **signed-sets** species `n ↦ (-1)ⁿ` (EGF `exp(-X)`),
because `exp(X)·exp(-X) = 1` — the analytic shadow of the inclusion–exclusion identity
`∑ᵢ C(n,i)(-1)^{n-i} = [n = 0]`.

A recurring methodological lesson recorded in the Lab Notebook: `ExpRing` is a type synonym
`def ExpRing := ℕ → ℚ`, and the ring's `*`/`1` (built by `Function.Injective.commRing`) are *not*
defeq-transparent to `binConv`/`deltaSeq` for `exact`/`apply`/`rw`; one must bridge that gap with
`convert` or by transporting through `egfRingEquiv`. This is a structural fact about transported ring
instances that any successor file in this thread will have to respect.

## Results Summary

All results compile with no `sorry` and depend only on the standard axioms `propext`,
`Classical.choice`, `Quot.sound`.

* `ExpRing.isUnit_iff_constCoeff_ne_zero` — a counting sequence is a unit for the binomial
  convolution iff its empty-set count is nonzero.
* `ExpRing.instIsLocalRing` — the binomial-convolution (Hurwitz) ring is a local ring.
* `ExpRing.shift_mul` — the Leibniz rule for the structural product; the shift is a derivation.
* `ExpRing.shiftHom` — the shift bundled as an additive group endomorphism (derivation backbone).
* `binConv_one_signed` / `ExpRing.isUnit_setSpecies` — the species of sets is a unit, with the
  signed-sets species `n ↦ (-1)ⁿ` as its explicit binomial-convolution inverse.

## Research Directions

### 1. The maximal ideal and the recursive (Neumann) inverse of a species

Now that `ExpRing` is known to be local, the next step is to name its maximal ideal explicitly and
to turn the abstract invertibility criterion into an *algorithm*. The conjecture is that the maximal
ideal is exactly `{a | a 0 = 0}` (species with no empty-set structure), that `ExpRing` is
`X`-adically complete, and that the inverse of a unit `a` is computed by the binomial-convolution
Neumann recursion `b 0 = (a 0)⁻¹`, `b n = -(a 0)⁻¹ · ∑_{i<n} C(n,i) · a(n-i) · b i`. The key insight
is that `IsLocalRing.maximalIdeal ExpRing` must be the `egfRingEquiv`-preimage of the maximal ideal
`{f | constantCoeff f = 0}` of `ℚ⟦X⟧`, so the entire valuation theory ("index of the first nonzero
term") and the recursion both descend from the power-series side with no new combinatorics. Why now?
`instIsLocalRing` and `isUnit_iff_constCoeff_ne_zero` are already in place, so the maximal-ideal
identity is a one-line transport (`IsLocalRing.maximalIdeal` commutes with `RingEquiv`), and the
recursion is just `PowerSeries.invOfUnit` read through the inverse transform `egfInv`.

### 2. Bundling the shift as a genuine `Derivation` and the species exp/log

`shift_mul` proves the Leibniz law pointwise, but the shift is not yet packaged as Mathlib's
`Derivation`. The conjecture is that, after equipping `ExpRing` with its transported `ℚ`-algebra
structure, the shift upgrades to a `Derivation ℚ ExpRing ExpRing` and that `egfRingEquiv` becomes an
isomorphism of *differential* `ℚ`-algebras intertwining it with `derivativeFun`; as a payoff, the
"logarithmic derivative" `D a · a⁻¹` of a unit species and the exponential `exp` (the species of
sets) satisfy the expected ODE `D(exp) = exp` in `ExpRing`. The key insight is that once the shift is
a bona fide derivation, every classical species identity expressible through `d/dX` (e.g. the
recurrences for derangements `D′ = X·D/(1-X)` style relations) becomes a corollary of the differential
isomorphism rather than a bespoke proof. Why now? `shift_mul`, `shiftHom`, and `egfRingEquiv` already
exist; the only missing ingredient is the transported `Algebra ℚ ExpRing` instance, after which the
`Derivation` fields are precisely the additivity and Leibniz lemmas already proved.

### 3. The substitution product and the exponential formula

The two monoidal operations formalized so far (sum and product) are only two thirds of Joyal's
calculus; the third is **substitution** `F ∘ G` ("an `F`-structure of `G`-structures"), whose
counting law is a partition-indexed sum. The conjecture is that the EGF remains a homomorphism for
substitution, `EGF(F ∘ G) = EGF(F) ∘ EGF(G)` whenever `G` has no constant term, with the
**exponential formula** `EGF(E ∘ G) = exp(EGF G)` as its flagship case — and, crucially, that this
composition makes the *unit* theory of Direction 1 interact with substitution (a species with `G 0 = 0`
is exactly one that can be substituted into). The key insight is that substitution appears in
`ExpRing` as a second, non-linear composition intertwined by `egfRingEquiv` with
`PowerSeries.comp`, so the "no constant term" hypothesis is precisely membership in the maximal ideal
identified in Direction 1. Why now? The ring isomorphism gives the dictionary in both directions and
Mathlib has a usable formal-composition API; the only genuinely new combinatorial content is a single
partition-cardinality lemma analogous to `card_prodSpecies`.

### 4. Higher shifts, Hasse derivatives, and a species Taylor theorem

The shift `a ↦ a(·+1)` iterates to `a ↦ a(·+k)`, the `k`-fold derivative species `F^(k)`. The
conjecture is that these assemble into a **Hasse derivative** calculus on `ExpRing` —
`H_k a = a(·+k)/k!`-style operators — intertwined by `egfRingEquiv` with Mathlib's
`PowerSeries.hasseDeriv`, yielding a Taylor expansion `a = ∑_k (a k) · X^{[k]}` where `X^{[k]}` is the
divided-power basis (the species of a `k`-set). The key insight is that the divided-power structure of
`ℚ⟦X⟧` is the *correct* combinatorial home for "choosing `k` distinguished labels", so the binomial
coefficients that pervade species enumeration are exactly Hasse-derivative coefficients in disguise.
Why now? The single-step shift derivation (`shift_mul`) is proved and Mathlib already has
`hasseDeriv` with its product (Leibniz) rule, so the iteration is a clean induction transported across
the isomorphism rather than a fresh combinatorial development.

### 5. The λ-ring / cycle-index refinement of the unit and derivation theorems

EGFs remember only cardinalities, not the `Sₙ`-action on structures. Refining `coeffSeq` to the
**cycle-index (Frobenius characteristic) series** in symmetric functions promotes `ExpRing` to a
λ-ring, with plethysm as substitution. The conjecture is that both new theorems of this cycle lift:
the unit criterion becomes "invertible in the λ-ring iff the degree-0 part is invertible," and the
shift derivation lifts to the `p₁`-derivative `∂/∂p₁` on symmetric functions, with `egfRingEquiv`
recovered as the principal specialization `p₁ ↦ X, pₖ ↦ 0 (k ≥ 2)`. The key insight is that the
present units/locality and Leibniz results are *shadows* of finer identities living in the ring of
symmetric functions, where the `Sₙ`-equivariant information is retained; the EGF is the lossy
specialization that this direction would refine. Why now? Mathlib's symmetric-function and
power-series libraries have matured enough to express the specialization map, and the explicit
examples already pinned down here (sets ↦ `exp`, signed sets ↦ `exp(-X)`, linear orders ↦ `1/(1-X)`)
give concrete targets to test the refinement against on every example.
