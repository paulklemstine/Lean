# Future Directions — The Differential Calculus of Combinatorial Species, III

## Synthesis

This cycle (`Catalog/Speculative/AutoResearch/SpeciesTaylorTower.lean`) closes three of the
falsifiable targets left open by the Taylor-calculus cycle and, in doing so, makes the
"species are exponential generating functions" dictionary functorial under *all three*
classical lifts of differentiation to Joyal's core groupoid of finite sets — the additive
shift derivative `d/dX`, the multiplicative Euler operator `θ = X·d/dX`, and the binomial
Leibniz convolution governing products.

Building directly on the catalog foundation
(`Catalog/Applications/CombinatorialSpecies.lean`: `egf_injective`, `egf_mul`,
`EGF_derivativeSpecies`, `EGF_pointedSpecies`, `egf_card_prodSpecies`) and the first Taylor
cycle (`Catalog/Speculative/AutoResearch/SpeciesTaylorCalculus.lean`: `species_maclaurin`,
`EGF_iterate_derivative`, `coeffSeq_iterate_derivative`), the new file proves:

- `species_taylor_reconstruction` — `egf (fun k => coeff₀ (derivativeFun^[k] (F.EGF))) = F.EGF`:
  a species *is* the formal Taylor series of its own derivative tower; the tower-at-origin
  map (`species_maclaurin`) is the exact algebraic inverse of `egf` on counting data.
- `coeffSeq_iterate_pointed` — `(F^{•k})[n] = n^k · F[n]`: iterated pointing weights the
  `n`-th count by the `k`-th power, marking `k` ordered repeatable distinguished labels.
- `EGF_iterate_pointed` — `(F^{•k}).EGF = (X·d/dX)^[k] (F.EGF)`: iterated pointing is the
  `k`-fold Euler operator on the EGF.
- `derivativeFun_iterate_mul` — `(f·g)^{(k)} = Σ_{i≤k} C(k,i)·f^{(i)}·g^{(k-i)}`: the higher
  Leibniz (binomial) rule on `ℚ⟦X⟧`, the Faà-di-Bruno backbone.
- `EGF_higher_leibniz` — the species-level shadow of the higher Leibniz rule, transporting
  each tower entry of a structural product through `EGF_iterate_derivative`.

## Results Summary

Five new theorems, zero `sorry` on main results, all depending only on the standard axioms
`propext, Classical.choice, Quot.sound`. The reconstruction theorem realises the EGF as a
*two-sided* inverse pair with the tower-at-origin map; iterated pointing and the higher
Leibniz rule complete the EGF dictionary for the two remaining standard operators of the
differential calculus of species. Together with the earlier cycles, the EGF is now known to
intertwine every operator of `(ℕ → ℚ, +, ⋆, d/dX, θ)` with its analytic counterpart on
`ℚ⟦X⟧`, as a bijection respecting all of them simultaneously.

## Research Directions

### 1. The exponential formula `EGF(E ∘ G) = exp(EGF G)` for composition

Composition (substitution / plethysm) `F ∘ G` is still the one major species operation
absent from the formalized dictionary, and its flagship instance `F = E` (the species of
sets) is the celebrated exponential formula: assembling a set of `G`-structures over a
partition of the labels has EGF `exp(EGF G)` whenever `G` carries no structure on the empty
set. The falsifiable target is `(setSpecies.comp G).EGF = (PowerSeries.exp ℚ).comp (G.EGF)`
under the hypothesis `G.coeffSeq 0 = 0`. **The key insight is** that with
`species_taylor_reconstruction` and `species_maclaurin` in hand both sides can be compared
*coefficient-by-coefficient against the derivative tower* — the constant term of the `k`-fold
derivative — rather than by constructing the natural isomorphism of structure sets, turning
the partition-indexed Bell/Faà-di-Bruno sum into a finite extraction at each coefficient.
**Why now?** `EGF_setSpecies` pins the `E ↔ exp` half, `card_prodSpecies` provides the
cardinality-count template, and `derivativeFun_iterate_mul` already supplies the binomial
machinery that the chain rule iterates; the only genuinely new lemma is `card_compSpecies`, a
cardinality count over set partitions structurally analogous to the proven product count.

### 2. The Stirling bridge between the additive and multiplicative derivative towers

`EGF_iterate_derivative` realises the shift tower `d/dX` and `EGF_iterate_pointed` realises
the Euler tower `θ = X·d/dX`; the two are linked by the classical operator identity
`θ^k = Σ_j S(k,j) · X^j · (d/dX)^j` with Stirling numbers of the second kind `S(k,j)`. The
falsifiable target is the power-series identity
`(fun s => X * s.derivativeFun)^[k] f = Σ j ∈ range (k+1), (S(k,j) : ℚ) • (X^j * derivativeFun^[j] f)`,
and its species shadow
`(Species.pointed^[k] F).EGF = Σ j ∈ range (k+1), (S(k,j) : ℚ) • (X^j * (Species.derivative^[j] F).EGF)`.
**The key insight is** that `coeffSeq_iterate_pointed` already proves the coefficient identity
`n^k = Σ_j S(k,j) · n^{\underline j}` in disguise — the moment weighting `n^k` is the Stirling
transform of the falling-factorial weighting `n!/(n-j)!` produced by the shift tower — so the
operator identity is forced coefficientwise rather than proved by operator algebra. **Why
now?** Both towers are now formalized as `Function.iterate` objects with clean `k=1` bridges,
`Nat.stirlingSecond` is available in Mathlib, and the proof reduces to the same Pascal-style
induction already executed for `derivativeFun_iterate_mul`.

### 3. Reconstruction as a genuine bijection / order-isomorphism of the tower functor

`species_taylor_reconstruction` shows the tower-at-origin map is a left inverse of `egf` on
species data; the natural upgrade packages the whole correspondence
`a ↦ (k ↦ coeff₀ (derivativeFun^[k] (egf a)))` as a bundled `Equiv` (indeed an additive
isomorphism) on `ℕ → ℚ`, with `egf_bijective` giving the analytic half. The falsifiable
target is `Function.Bijective (fun a k => PowerSeries.coeff 0 (derivativeFun^[k] (egf a)))`
together with the round-trip `(this map) = id` on counting sequences. **The key insight is**
that, because `egf` is already a bijection and `species_maclaurin` exhibits the tower-at-origin
map as its inverse, the Taylor "tower" is not an analytic limit but a *finite* algebraic
inversion at each coefficient — the discrete 1-truncated core groupoid makes every Taylor
coefficient literally computable. **Why now?** `species_maclaurin` supplies the per-coefficient
extraction and `egf_injective`/`egf_surjective` are in the catalog, so the remaining work is a
single `Function.LeftInverse`/`RightInverse` assembly with no new mathematics.

### 4. Homotopy invariance of the entire differential tower under species isomorphism

`Catalog/Applications/SpeciesHomotopyCardinality.lean` shows the EGF is a
groupoid-cardinality invariant; the three towers built this cycle should each respect that
invariance. The falsifiable targets are the single-step preservation lemmas
`Species.Iso F G → Species.Iso F.derivative G.derivative` and
`Species.Iso F G → Species.Iso F.pointed G.pointed`, upgraded to `derivative^[k]` and
`pointed^[k]` by `coeffSeq_iterate_derivative` and `coeffSeq_iterate_pointed` respectively, so
that isomorphic species have isomorphic Taylor *and* Euler towers (hence equal tower EGFs).
**The key insight is** that both `Species.derivative` (built from
`Equiv.Perm.viaEmbeddingHom (Fin.castSuccEmb)`) and `Species.pointed` (built from
`Equiv.prodCongr`) are equivariant lifts, so they descend to the localization that inverts
relabelling equivalences — the whole differential calculus is a functor on the *homotopy
category* of species, not merely the skeletal one. **Why now?** The `act` field and the
homotopy-cardinality theorem are in place, the two operators are now iterated cleanly, and the
`k`-fold case reduces to the `k=1` case, so only the single-step iso-preservation lemmas are
missing to make the entire calculus homotopy-invariant.

### 5. A bivariate Taylor / mixed-partial calculus for two-sort species

The single-sort tower extracts `F[k] = coeff₀ (derivativeFun^[k] (F.EGF))`; the natural
generalization is a two-sort (or weighted) species `F(X, Y)` with two commuting derivative
operators `∂_X, ∂_Y` and the mixed Maclaurin extraction
`coeff₀ (∂_X^[j] ∂_Y^[k] (F.EGF)) = F[j, k]`, together with a Clairaut commutation
`∂_X ∘ ∂_Y = ∂_Y ∘ ∂_X`. The falsifiable target is `Function.Commute` of the two ghost-point
operators on `ℚ⟦X, Y⟧` (or `MvPowerSeries`) plus the bivariate analogue of
`species_maclaurin`. **The key insight is** that adding a second ghost point to a different
sort commutes with the first because the two `Fin.castSuccEmb` lifts act on disjoint label
sorts — so Clairaut's theorem for species is a *combinatorial* statement about independent
ghost insertions, provable by the same `Function.iterate` bookkeeping rather than by analysis.
**Why now?** `MvPowerSeries` and its formal derivatives are in Mathlib, the single-sort
ghost-point construction (`Species.derivative`) is the template, and `species_maclaurin`
plus `coeffSeq_iterate_derivative` give the one-sort base cases that the bivariate induction
factors through.
