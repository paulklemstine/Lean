# Future Directions — Combinatorial Species → Tropical Valuation Profiles

This cycle established the first concrete *Applications → Tropical* bridge: reading the
`p`-adic valuation of the integer EGF coefficients of a combinatorial species as a **tropical
(min-plus) valuation profile** in `ℕ∞`, and transporting the species sum/product laws into
tropical coefficientwise-minimum and min-plus-convolution lower bounds
(`Catalog/Bridges/SpeciesTropicalValuation.lean`,
`Catalog/Bridges/SpeciesTropicalProfileCertificate.lean`).

Key proved facts this cycle:
- `valProfile_add_ge` — sum law gives a tropical coefficientwise-min lower bound.
- `valProfile_binConvInt_ge` — product law gives a tropical min-plus-convolution lower bound.
- `valProfile_prodSpecies_ge` — the bound applied to the structural Day-convolution product,
  via the catalog `CombinatorialSpecies.card_prodSpecies`.
- `tropLB_le_valProfile` — soundness of a fully structural species-expression → tropical
  certificate pipeline.
- `valProfile_linearOrder_monotone` — a growth/divisibility certificate for `v_p(n!)`.

The conjectures below are derived directly from these findings.

---

## Conjecture 1 — Exactness of the convolution bound at "valuation-isolated" indices

**Statement.** For a prime `p`, if the antidiagonal infimum defining
`valProfile_binConvInt_ge` is attained at a *unique* index `q = (i, j)` (strictly below all
others), then the convolution bound is an **equality**:
`valProfile p (binConvInt a b) n = emultiplicity p (C(n,i)) + valProfile p a i + valProfile p b j`.

**The key insight is...** the ultrametric inequality `v_p(x+y) ≥ min(v_p x, v_p y)` is an
*equality* whenever the two valuations differ; lifting this "unique minimizer ⇒ equality"
principle from binary sums to the finite antidiagonal sum turns the one-sided tropical bound
into a tight tropical *evaluation*, making the profile exactly computable from the syntax tree
at such indices.

**Why now?** We already have `inf_emultiplicity_le_sum` and the per-term factorization
`emultiplicity_mul`; the only missing lemma is the strict-minimizer refinement of
`min_le_emultiplicity_add`, which Mathlib states for binary sums and which extends to finite
sums by the same induction used in `inf_emultiplicity_le_sum`.

---

## Conjecture 2 — A Legendre-type closed form for the linear-order profile certificate

**Statement.** The certificate `tropLB p e` for any `+`/`·`-combination of the set species `E`
and the linear-order species `L` is computable in closed form via Legendre's formula
`v_p(n!) = (n - s_p(n))/(p - 1)` (with `s_p` the base-`p` digit sum), giving an `O(log n)`
algorithm for the whole tropical profile certificate of such expressions.

**The key insight is...** the only nonconstant base profile in the syntax is `v_p(n!)`, and
both tropical operations (`min`, min-plus `inf`-convolution) preserve closed-form
computability; so the entire certificate collapses to digit-sum arithmetic rather than an
explicit factorial computation.

**Why now?** Mathlib already contains Legendre's formula (`Nat.Prime.factorial_…` /
`sub_one_mul_padicValNat_factorial`) and our `valProfile_linearOrder_monotone` shows the base
case behaves; wiring these into `tropLB` is a direct continuation.

---

## Conjecture 3 — Functorial transfer to the catalog's ultrametric seminorm objects

**Statement.** The assignment `a ↦ (n ↦ p^{-valProfile p a n})` extends to a functor from the
min-plus valuation profiles of this cycle into the `UltraNormObj` ultrametric seminorm
objects of `Bridges/CategoricalTropicalUltrametric.lean`, sending the sum/convolution bounds
to the `norm_add`/`norm_mul` ultrametric axioms.

**The key insight is...** valuation reconstruction is a quantitative functor (the stated
thesis of the categorical tropical–ultrametric file); our coefficientwise inequalities are
exactly the numerical content its `norm_add` axiom abstracts, so the bridge should be a
literal instance rather than an analogy.

**Why now?** Both endpoints now exist in the catalog — the profile bounds here and the
`UltraNormObj`/`TropHom`/`UltraHom` interface there — so the connecting functor can be
formalized without building new foundations.

---

## Conjecture 4 — Tropical profiles separate non-isomorphic species

**Statement.** There exist species expressions `e₁, e₂` with equal EGFs over `ℚ` but distinct
tropical valuation profiles at some prime `p`, so the family `{tropLB p · }ₚ` is a strictly
finer invariant than the rational EGF on the image of the pipeline.

**The key insight is...** the EGF forgets denominators' prime content, while the integer
profile retains `v_p` of the `C(n,i)` factors in the binomial convolution; the binomial
coefficients' valuations (Kummer's theorem) are exactly the information the rational EGF
divides away.

**Why now?** `egf_injective` (catalog) pins down when EGFs coincide, and Kummer's theorem is
in Mathlib (`Nat.Prime.…choose`), so a concrete separating pair is within reach as a finite
`decide`/`#eval` search over small `SpExpr`.

---

## Conjecture 5 — Cryptographic divisibility certificates from species growth

**Statement.** For species whose counting sequence grows factorially (e.g. iterated products
of `L`), the monotone profile certificate `valProfile_monotone_of_dvd` yields a *guaranteed
minimum `p`-adic depth* `v_p(a_n) ≥ c·n - o(n)`, certifying that such coefficients are highly
divisible — a structural source of high-valuation integers usable in non-archimedean /
lattice-style constructions.

**The key insight is...** the divisibility chain `a_n ∣ a_{n+1}` makes the profile monotone,
and Legendre growth `v_p(n!) ∼ n/(p-1)` then forces linear-in-`n` valuation depth, turning a
combinatorial growth statement into a quantitative cryptographic divisibility guarantee.

**Why now?** The depth machinery of `Computation/PadicValuationDepth.lean` is the natural
consumer of such bounds, and this cycle supplies the missing producer (a certified lower bound
on valuation depth coming from species structure).
