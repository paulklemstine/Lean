# Future Directions — Tropical Valuation Profiles of Combinatorial Species

Derived from the cycle that produced
`Catalog/Bridges/SpeciesTropicalProfile.lean` and
`Catalog/Bridges/SpeciesTropicalFunctor.lean`, which turn the EGF coefficient machinery of
`Catalog/Applications/CombinatorialSpecies.lean` into a genuine min-plus
`TropicalValuationObject` (`Catalog/Bridges/CategoricalTropicalUltrametric.lean`):
species **sum ↦ `min`**, species (binomial-convolution) **product ↦ `+`**, with support
inclusion inducing tropical order preservation.

Each conjecture below is falsifiable: it is either provable as a Lean theorem or refutable
by an explicit counting-sequence counterexample.

---

## 1. Tropical differentiation: the valuation of the derivative species is a shift

**Conjecture.** For a species `F` with counting sequence `a = F.coeffSeq` and tropical
valuation `firstSupport a = (m : WithTop ℕ)` with `m ≥ 1`, the derivative species `F′`
(`a' n = a (n+1)`) satisfies `firstSupport a' = (m - 1 : WithTop ℕ)`; and if `m = 0` or
`firstSupport a = ⊤` the derivative valuation is `⊤` iff `a` is supported only at `0`.

**The key insight is** that Joyal's differential operator `d/dX`, which `egf_derivative`
already shows acts on the EGF as a coefficient *shift*, must act on the tropical valuation
as a *unit translation* in the min-plus semiring — differentiation lowers the order by one.

**Why now?** `Catalog/Applications/CombinatorialSpecies.lean` already provides
`egf_derivative`, `EGF_derivativeSpecies`, and the `Species.derivative` construction, and
this cycle provides `firstSupport` with its full `Nat.find` characterization API
(`firstSupport_spec`, `firstSupport_eq_of_spec`); composing them is immediate.

---

## 2. Over rings with cancellation the min/+ laws degrade to genuine inequalities

**Conjecture.** Replacing `ℕ`-valued counts by `ℤ`- or `ℚ`-valued sequences (virtual
species / signed species), the equalities `firstSupport_add` and `firstSupport_binConvN`
become only the inequalities `firstSupport (a+b) ≥ min …` and
`firstSupport (a⋆b) ≥ firstSupport a + firstSupport b`, and equality fails *exactly* on the
locus where leading coefficients cancel; this locus is a proper, explicitly describable
subvariety.

**The key insight is** that the *exactness* of the tropical laws proved this cycle is a
shadow of nonnegativity (no cancellation), so the min-plus structure is really an
ultrametric/valuation inequality whose defect measures signed cancellation.

**Why now?** This cycle isolates precisely where nonnegativity is used (the diagonal
positivity lemma `binConvN_pos_at` and `Nat.add_eq_zero`), making the boundary between the
equality and inequality regimes a concrete, testable target.

---

## 3. The tropical support signature classifies species growth more finely than the EGF radius

**Conjecture.** The pair (`firstSupport`, asymptotics of `supportCount a n` as `n → ∞`) is
a strictly finer invariant than the EGF radius of convergence: there exist species with
equal EGF radius but different support-signature growth class, and `supportCount` growth is
monotone under species product (a Cauchy-type lower bound
`supportCount (binConvN a b) n ≥ f (supportCount a, supportCount b)`).

**The key insight is** that recording the *order-theoretic profile* of vanishing
(threshold support counts) rather than the raw analytic coefficients exposes lacunarity
that the radius of convergence cannot see.

**Why now?** `supportCount_mono`, `supportCount_add_le`, and `supportCount_mono_of_subset`
established this cycle give the monotonicity scaffold; only the product growth bound and a
separating example pair remain.

---

## 4. Composition of species induces a min-plus *substitution* law on valuations

**Conjecture.** For the substitution (plethystic composition) `F ∘ G` of species with
`G` having no constant term (`firstSupport G.coeffSeq ≥ 1`), the valuation multiplies:
`firstSupport ((F ∘ G).coeffSeq) = firstSupport F.coeffSeq · firstSupport G.coeffSeq`
in the min-plus sense (tropical product = numerical sum iterated), generalizing the
product law `firstSupport_binConvN`.

**The key insight is** that composition is built from iterated convolutions, and this
cycle showed each convolution *adds* valuations, so composition should *multiply* the
order by the inner valuation — a tropical chain rule.

**Why now?** The product law `firstSupport_binConvN` and the functor `SpeciesExpr.tropVal`
of this cycle give exactly the convolution-additivity primitive needed to bootstrap the
composition case by induction on the outer expression.

---

## 5. Reconstructing an ultrametric species seminorm from the tropical profile

**Conjecture.** The min-plus object `minPlusTrop` built this cycle reconstructs, via the
catalog's valuation-reconstruction functor in
`Catalog/Bridges/CategoricalTropicalUltrametric.lean`, an ultrametric seminorm
`‖F‖ = 2^{-firstSupport F.coeffSeq}` on finite species expressions for which the species
product is submultiplicative and species sum is non-expansive — yielding certified
robustness-style bounds for combinatorial generating data.

**The key insight is** that `valuation reconstruction is a quantitative functor`
(the catalog's core message), and this cycle supplies a *bona fide* tropical valuation
object sourced from enumerative combinatorics, so the reconstruction applies verbatim.

**Why now?** `minPlusTrop : TropicalValuationObject (WithTop ℕ)` and the functor laws
`tropVal_sum`/`tropVal_prod`/`tropVal_le_of_supportSubset` proved this cycle are precisely
the input the catalog's `UltraNormObj`/reconstruction interface consumes.
