# Future Directions — Homotopy Cardinality and the Species Bridge

## Synthesis

The species program in `Catalog/Applications/` had developed the exponential generating
function (EGF) as a *purely algebraic* bridge: `egf : (ℕ → ℚ) ≃+* ℚ⟦X⟧` is a ring
isomorphism carrying the disjoint-union/sum, the Day-convolution product, differentiation,
pointing, and the convolution power to their analytic counterparts (`egf_add`, `egf_mul`,
`egf_seqDeriv`, `egf_seqPoint`, `egf_binConvPow`, `egfRingEquiv`).

`SpeciesHomotopyCardinality.lean` adds the missing *homotopical* reading. The new result
`groupoidCard_eq` proves that the homotopy (groupoid) cardinality of any finite action
groupoid `X ⫽ G`, defined as `∑_{orbits ω} 1/|Stab(ω)|`, equals `|X|/|G|` — the
homotopy-theoretic refinement of orbit counting. Specialized to the relabelling action of
`Sₙ` on a species' structure set `F[n]`, this yields the conceptual unification
`coeff n (EGF F) = |F[n] ⫽ Sₙ|` (`Species.EGF_coeff_eq_actionGroupoidCard`): **Joyal's
analytic functor is the homotopy-cardinality generating function**, and the ubiquitous
`1/n!` is the reciprocal order of the symmetry group being homotopy-quotiented, not a mere
normalization. The two emblematic computations crystallize this: the species of sets `E` has
`|E[n] ⫽ Sₙ| = 1/n!` (one structure, full symmetry `Sₙ`), recovering `exp`; the species of
linear orders `L` has `|L[n] ⫽ Sₙ| = 1` because the relabelling action is a *torsor*
(free + transitive ⇒ contractible homotopy quotient), recovering `1/(1-X)`.

## Results Summary

- `groupoidCard_eq` — homotopy cardinality of an action groupoid equals `|X|/|G|` (in `ℚ`),
  from orbit–stabilizer (`card_orbit_mul_card_stabilizer_eq_card_group`) and the orbit
  decomposition (`selfEquivSigmaOrbits`).
- `Species.actMulAction`, `Species.actionGroupoidCard` — the relabelling action of `Sₙ` on
  `F[n]` and the homotopy cardinality of its action groupoid.
- `Species.actionGroupoidCard_eq` — `|F[n] ⫽ Sₙ| = |F[n]|/n!`.
- `Species.EGF_coeff_eq_actionGroupoidCard` — the EGF coefficient *is* the homotopy
  cardinality (the central bridge theorem).
- `setSpecies_actionGroupoidCard`, `linearOrderSpecies_actionGroupoidCard` — the `1/n!`
  (full symmetry) and `1` (torsor) emblematic homotopy cardinalities.

## Research Directions

### 1. The product law is the homotopy cardinality of a homotopy fiber product

The catalog already has `egf_mul`/`egf_card_prodSpecies` (EGF of the Day-convolution product
is the product of EGFs). Conjecture: the homotopy cardinality is *multiplicative under the
product of action groupoids*, i.e. `|(F·G)[n] ⫽ Sₙ| = ∑_{i+j=n} |F[i] ⫽ Sᵢ| · |G[j] ⫽ Sⱼ|`,
and more structurally `|A ⫽ G × B ⫽ H| = |A ⫽ G| · |B ⫽ H|` for finite group actions. The
key insight is that homotopy cardinality is a *symmetric monoidal functor* from finite
groupoids to `ℚ`, so the algebraic product law of `egf_mul` is the shadow of a genuinely
categorical (homotopy) multiplicativity. Why now? With `groupoidCard_eq` proven, the product
case reduces to `Fintype.card_prod` plus the already-formalized `card_prodSpecies`, so the
homotopy upgrade of `egf_mul` is within immediate reach.

### 2. Burnside / cycle index as the fixed-point form of homotopy cardinality

The number of *isomorphism classes* of `F`-structures is `|π₀(F[n] ⫽ Sₙ)|`, the count of
orbits, which by Burnside equals `(1/n!) ∑_{σ ∈ Sₙ} |Fix(σ)|`. Conjecture: the orbit count
and the homotopy cardinality coincide exactly when the action is *free* (all stabilizers
trivial), with the homotopy cardinality being the finer invariant in general. The key insight
is that homotopy cardinality `∑ 1/|Stab|` and naive orbit count `∑ 1` differ precisely by the
automorphism weighting, so freeness is the homotopical condition "the groupoid is equivalent
to a set." Why now? Mathlib has `MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group`
(Burnside), so both sides are formalizable and the comparison theorem is a clean next target
that connects to the catalog's enumerative results.

### 3. Homotopy cardinality of the derivative and pointing functors

The catalog's `egf_seqDeriv` and `egf_seqPoint` show the derivative species `F'[n] = F[n+1]`
and pointed species `F^•[n] = n·F[n]` map to `d/dX` and `X·d/dX`. Conjecture: these are the
homotopy cardinalities of the *slice/comma* action groupoids — `F^•[n] ⫽ Sₙ` is the groupoid
of structures-with-a-marked-point, and pointing multiplies the homotopy cardinality by `n`
because it breaks one unit of symmetry (the marked point is fixed). The key insight is that
pointing is the homotopy-cardinality avatar of the Euler vector field `X d/dX` acting by
"de-symmetrizing" one label. Why now? `egf_seqPoint` already supplies the analytic identity,
so the task is to construct the marked-point action groupoid and verify its cardinality is
`n · |F[n] ⫽ Sₙ|` — a direct application of `groupoidCard_eq` to a product action.

### 4. The exponential formula as `exp` of homotopy cardinalities

The catalog's `egf_binConvPow` gives `egf (a^{⋆k}) = (egf a)^k`, the algebraic engine of
species composition. Conjecture: the composite "species of sets of `F`-structures" `E ∘ F`
(with `F[0] = ∅`) has homotopy cardinality `exp` of the homotopy cardinality generating
function of `F`, i.e. `EGF(E∘F) = exp(EGF(F))` realized as `∑_k (1/k!)·(EGF F)^k` where each
`1/k!` is the homotopy quotient by the symmetry permuting the `k` blocks of a set-partition.
The key insight is that the `1/k!` in the exponential series is *itself* a homotopy
cardinality (of `Sₖ` acting on `k` blocks), so the exponential formula is the statement that
homotopy cardinality is a monoidal functor sending coproducts of symmetric powers to `exp`.
Why now? With `egf_const_one` (`EGF E = exp`) and `egf_binConvPow` in hand, the missing piece
is the set-partition decomposition of `(E∘F)[n]`, a finite combinatorial sum amenable to the
`groupoidCard_eq` machinery.

### 5. Homotopy cardinality over a localization: inverting weak equivalences

Frame the species groupoids inside a homotopical localization: invert the relabelling
isomorphisms to obtain the *core* `∞`-groupoid, and conjecture that homotopy cardinality
descends to a well-defined invariant on the localized category `Spc[W⁻¹]` where `W` is the
class of natural isomorphisms of species. The key insight is that homotopy cardinality is
*invariant under equivalence of groupoids* (it depends only on `π₀` and the `|Aut|`), so it
factors through the localization — making it a genuine `∞`-categorical invariant rather than a
property of a presentation. Why now? `Species.EGF_inj` already proves the EGF is a complete
invariant for the counting sequence; upgrading "equal counting sequence" to "equivalent action
groupoids" would show the EGF is the universal homotopy-invariant of a species, closing the
loop between the algebraic bridge and the homotopical one and giving a localization-theoretic
characterization of when two species have the same EGF.
