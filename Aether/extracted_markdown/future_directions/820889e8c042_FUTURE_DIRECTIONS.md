# Future Directions — Taylor Reconstruction, Iterated Pointing, and Higher Leibniz for Species

## Synthesis

The species program had, before this cycle, built the exponential-generating-function (EGF)
dictionary for the *monoidal* structure (sum `egf_add`, Day-convolution product `egf_mul` /
`egf_card_prodSpecies`), the *first-order differential* structure (`egf_derivative`,
`EGF_derivativeSpecies`, `EGF_pointedSpecies`, `egf_injective`), the convolution **ring** of
counting sequences (`binConv_assoc`, `binConv_leibniz`, `egf_binConvPow`,
`ConvSeq.egfRingEquiv`), the **bijectivity** of `egf` (`egf_surjective`, `egf_bijective`,
`seqOf`), and the **Taylor tower** of higher derivatives
(`Catalog/Speculative/AutoResearch/SpeciesTaylorCalculus.lean`:
`egf_seqDeriv_iterate`, `coeffSeq_iterate_derivative`, `EGF_iterate_derivative`,
`species_maclaurin`).

This cycle (`Catalog/Speculative/AutoResearch/SpeciesTaylorReconstruction.lean`) closes the
*inverse* of the Taylor tower and opens two adjacent towers. `species_maclaurin` extracted a
single coefficient `F[k] = coeff₀ (derivativeFun^[k] (F.EGF))`; we now invert that extraction,
iterate the *pointing* operator, and prove the *higher* product rule:

- `coeff_zero_iterate_derivativeFun` — `coeff₀ (derivativeFun^[k] (egf a)) = a k`: the analytic,
  species-free form of Maclaurin extraction.
- `taylor_reconstruction` — `egf (fun k => coeff₀ (derivativeFun^[k] f)) = f`: **every** power
  series over `ℚ` is the formal Taylor series of its own derivative tower. Because `egf` is a
  bijection and the tower-at-origin map is its set-theoretic inverse on counting data, this is an
  exact algebraic inversion that terminates at each coefficient — not an analytic limit.
- `species_taylor_series` — the species specialization: `F.EGF` is reconstructed from its own
  derivative tower at the origin.
- `coeffSeq_iterate_pointed` — `(F^{•k})[n] = n^k · F[n]`: iterated pointing is moment weighting.
- `EGF_iterate_pointed` — `(F^{•k}).EGF = (X · d/dX)^[k] (F.EGF)`: the iterated pointed species is
  the `k`-fold Euler operator `θ = X d/dX` on the EGF.
- `derivativeFun_iterate_mul` — the higher (binomial) Leibniz rule
  `(f·g)^{(k)} = Σ_{i≤k} C(k,i) · f^{(i)} · g^{(k-i)}` on `ℚ⟦X⟧`, the Faà-di-Bruno backbone.

## Results Summary

Six new theorems, zero `sorry` on main results, all depending only on the standard axioms
`propext, Classical.choice, Quot.sound`. The derivative tower is now known to be *invertible*
(`taylor_reconstruction` exhibits the inverse of `species_maclaurin`), the *moment* tower
(iterated pointing) is identified with the iterated Euler operator, and the *higher product*
tower (binomial Leibniz) is established on power series. As a side effect, a pre-existing
duplicate-declaration build error in `Catalog/Applications/SpeciesAnalyticBridge.lean`
(`egf_injective` re-declared) was repaired, so the whole species stack now compiles, and a
`lean_lib` entry covering the `Catalog.` module prefix was added to `lakefile.toml`.

## Research Directions

### 1. The Stirling bridge between the moment tower and the derivative tower

`coeffSeq_iterate_pointed` shows iterated pointing weights counts by `n^k` (the moment tower),
while `coeffSeq_iterate_derivative` shows iterated differentiation shifts by `k` (the falling-
factorial / derivative tower). The two should be related coefficientwise by the Stirling numbers
of the second kind: the falsifiable target is the operator identity
`(fun s => X * derivativeFun s)^[k] = Σ_{j ≤ k} S(k,j) • (fun s => X^j) * derivativeFun^[j]`
on `ℚ⟦X⟧`, equivalently `(F^{•k}).EGF = Σ_{j} S(k,j) · X^j · (F.EGF)^{(j)}`, and at the level of
counting sequences `n^k = Σ_{j} S(k,j) · n!/(n-j)!`. **The key insight is** that pointing (`θ =
X d/dX`, multiplicative) and the derivative species (the shift) are the *two* lifts of `d/dX` to
species, and the change of basis between them is exactly the Stirling transform converting moment
weighting `n^k` into falling-factorial weighting; with `EGF_iterate_pointed` and
`EGF_iterate_derivative` both proven, the conjecture reduces to a pure `ℚ⟦X⟧` operator induction.
**Why now?** Both towers are now formalized as `Function.iterate` of named operators with proven
EGF shadows, `Nat.stirlingSecond` (or its `Finset`-partition definition) is in Mathlib, and the
`k=1` case (`θ = X d/dX` with `S(1,1)=1`) is already `EGF_pointedSpecies` — only the Pascal-style
Stirling recurrence step is new.

### 2. The exponential formula `EGF(E ∘ G) = exp(EGF G)`

Composition (substitution / plethysm) `F ∘ G` is still the one major species operation absent
from the dictionary; its flagship instance `F = E` is the exponential formula: assembling a set
of `G`-structures over a partition of the labels has EGF `exp(EGF G)` whenever `G` carries no
structure on the empty set. The falsifiable target is
`(setSpecies.comp G).EGF = PowerSeries.exp ℚ` substituted at `G.EGF`, under `G.coeffSeq 0 = 0`.
**The key insight is** that, with `taylor_reconstruction` in hand, both sides can be compared
*coefficient-by-coefficient* through the derivative tower rather than by constructing the natural
isomorphism of structure sets — the partition-indexed composition sum is governed coefficientwise
by the Bell expansion, which is the Maclaurin tower of `exp` applied to a series with zero
constant term. **Why now?** `EGF_setSpecies` pins the `E ↔ exp` half, `egf_binConvPow` supplies
`exp = Σ a^{⋆k}/k!` as the convolution-power generating identity, and `card_prodSpecies` is the
proof template; the only genuinely new lemma is `card_compSpecies`, a cardinality count over set
partitions structurally analogous to the already-proved product count.

### 3. The higher Leibniz rule descended to species (`binConv` higher product rule)

`derivativeFun_iterate_mul` proves the binomial Leibniz expansion on `ℚ⟦X⟧`; transporting it
across the (injective, ring-isomorphic) EGF bridge should yield the *combinatorial* higher
product rule for the exponential convolution: `seqDeriv^[k] (binConv a b) = Σ_{i≤k} C(k,i) ·
binConv (seqDeriv^[i] a) (seqDeriv^[k-i] b)`, the enumerative content of the species isomorphism
`(F·G)^{(k)} ≅ Σ_{i+j=k} C(k,i) · F^{(i)} · G^{(j)}`. **The key insight is** that the higher
Leibniz rule is the species shadow of a pure power-series identity, so `egf_injective` upgrades
the already-proved `derivativeFun_iterate_mul` into a combinatorial theorem with *no* antidiagonal
bookkeeping — the `n!`-twist that defines `binConv` is exactly the binomial weighting that appears.
**Why now?** `binConv_leibniz` is the proven `k=1` instance, `derivativeFun_iterate_mul` is the
analytic engine, and `egf_seqDeriv_iterate` translates each tower entry, so the direction is a
single `Finset.sum`-indexed transport whose base and step are both already-proved bridges.

### 4. Newton's forward-difference calculus and the umbral inverse

`taylor_reconstruction` says `coeff₀ ∘ derivativeFun^[·]` inverts `egf`; the *ordinary* (not
exponential) generating function instead diagonalizes the **forward difference** `Δ a (n) = a(n+1)
- a(n)`, whose `k`-fold value at the origin recovers the Newton-series coefficients. The
falsifiable target is the dual reconstruction `a n = Σ_{k≤n} C(n,k) · (Δ^[k] a) 0` together with
its EGF shadow relating `Δ` to `derivativeFun` of the *shifted* EGF. **The key insight is** that
the species derivative (the shift `a ↦ a(·+1)`) and the forward difference `Δ = shift - id` are
the two natural finite-difference operators on counting sequences, and `taylor_reconstruction`
already identifies the shift tower's inverse — so Newton's interpolation is the umbral twin of the
Maclaurin reconstruction, obtained by replacing `derivativeFun` with `derivativeFun - id`.
**Why now?** The shift bridge `egf_seqDeriv_iterate` and the reconstruction inverse are in place,
`Nat.choose` and `Finset.sum_range` provide the binomial assembly, and the `k=1` step is just
`egf_derivative` minus the identity — the only new ingredient is the binomial inversion lemma.

### 5. Homotopy invariance of the entire differential tower

`Catalog/Applications/SpeciesHomotopyCardinality.lean` shows the EGF is a groupoid-cardinality
invariant; the derivative, pointing, and product towers should all respect that invariance. The
falsifiable target is the package of `Species.Iso`-preservation lemmas
`Species.Iso F G → Species.Iso (Species.derivative F) (Species.derivative G)`,
`Species.Iso F G → Species.Iso (Species.pointed F) (Species.pointed G)`, each upgraded to the
`k`-fold tower by `coeffSeq_iterate_derivative` / `coeffSeq_iterate_pointed`. **The key insight
is** that `Species.derivative` is built from `Equiv.Perm.viaEmbeddingHom (Fin.castSuccEmb)` and
`Species.pointed` from `Equiv.prodCongr`, both equivariant lifts, so each descends to the
localization that inverts relabelling equivalences — the differential calculus is a functor on the
*homotopy category* of species, not merely the skeletal one. **Why now?** The `act` field and the
homotopy-cardinality theorem are in place, the `k=1` constructions are the proven `derivative` /
`pointed`, and the new `coeffSeq_iterate_*` lemmas reduce every `k`-fold case to its single step,
so only the two single-step iso-preservation lemmas are missing to make the whole tower
homotopy-invariant.
