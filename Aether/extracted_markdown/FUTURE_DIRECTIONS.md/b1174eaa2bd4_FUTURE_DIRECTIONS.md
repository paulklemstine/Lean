# FUTURE_DIRECTIONS

## Synthesis

This cycle lifted the combinatorial–analytic dictionary of Joyal's theory of
species from the level of bare *counting sequences* (where the catalog file
`Applications/CombinatorialSpecies.lean` already established the additive law
`egf_add`, the binomial-convolution/product law `egf_mul`, and the cardinality
bridge `egf_card_prodSpecies`) up to the level of honest *operations on species*
— functors on the groupoid of finite sets. We defined the disjoint-union species
`sumSpecies` with its genuine relabelling action (`Equiv.Perm.sumCongrHom`), the
structural Day-convolution product `prodSpecies`, and proved that the exponential
generating function (EGF) carries `+` and `·` of species onto `+` and `·` of the
formal power-series ring `ℚ⟦X⟧` (`EGF_sumSpecies`, `EGF_prodSpecies`). The
structural insight that emerged is a clean *separation of concerns*: the EGF
factors through the counting sequence, so every algebraic law of species reduces
to an already-proven law about sequences plus a cardinality computation. This is
why both bridge theorems were one-liners once the right objects were defined.

The most conceptually new result is the rigidity theorem `EGF_inj_coeffSeq`: the
EGF is a *faithful* invariant — equal EGFs force equal counting sequences at every
arity — because division by `n!` is invertible in `ℚ`. This upgrades the EGF from
"a homomorphism" to "an injective homomorphism" on counting sequences, the precise
sense in which the analytic shadow loses no enumerative information. We then ran
the machine on a concrete instance: `E · E` (pairs of complementary subsets) has
exactly `2ⁿ` structures and EGF `exp²`, and the corollary `binConv_const_one`
exhibits the classical identity `∑ₖ C(n,k) = 2ⁿ` as nothing but the Cauchy product
of `exp` with itself — the analytic shadow of "a subset is a 2-colouring".

What did *not* get done, and why, points the way forward. We equipped `prodSpecies`
with the trivial relabelling action because a faithful Day-convolution action
(permuting subsets and acting compatibly on `F[S] × G[Sᶜ]`) is intricate to build
as a `MonoidHom` by hand; the EGF only sees cardinalities, so this did not block
the bridge, but a *functorial* product species is the natural next target. The
larger missing piece is the third species operation — *substitution/composition*
`F ∘ G` and its EGF law `EGF(F∘G) = (EGF F) ∘ (EGF G)` — which is the deepest part
of Joyal's bridge and is genuinely absent from Mathlib.

## Results Summary

- `sumSpecies`: proved (definition) — disjoint-union species with the genuine `sumCongrHom` relabelling action.
- `coeffSeq_sumSpecies`: proved — the counting sequence of a sum is the pointwise sum of counting sequences.
- `EGF_sumSpecies`: proved — the EGF carries disjoint union of species to addition in `ℚ⟦X⟧`.
- `prodSpecies`: proved (definition) — the structural Day-convolution product species (trivial action, EGF-faithful).
- `coeffSeq_prodSpecies`: proved — unfolds the product's counting sequence to the cardinality of the Day-convolution Sigma type.
- `EGF_prodSpecies`: proved — the EGF carries the structural product of species to multiplication in `ℚ⟦X⟧`.
- `EGF_inj_coeffSeq`: proved — **rigidity**: the EGF is a complete invariant of a species' counting sequence.
- `coeffSeq_prod_setSpecies`: proved — `E · E` has exactly `2ⁿ` structures on an `n`-label set.
- `EGF_prod_setSpecies`: proved — `(E · E).EGF = exp²`, the worked instance of the product bridge.
- `binConv_const_one`: proved — `∑_{i+j=n} C(n,i) = 2ⁿ` as the binomial convolution of `1` with itself.

## Research Directions

### Direction 1: A faithful Day-convolution action for the product species
**Hypothesis**: There is a `MonoidHom (Equiv.Perm (Fin n)) (Equiv.Perm ((prodSpecies F G).obj n))`
making `prodSpecies` a genuine functor on finite sets: a permutation `σ` sends the
datum `(S, x, y)` with `x : F[S]`, `y : G[Sᶜ]` to `(σ ⁻¹ '' S, F.act … x, G.act … y)`,
and this assignment respects composition and identity.
**Test**: Construct the hom in Lean and prove `map_one`/`map_mul`; confirm
`EGF_prodSpecies` still holds verbatim (it must, since the EGF depends only on
cardinality, which the action preserves). The key insight is that the action only
relabels indices and so is an automorphism of the Sigma type that fixes its
cardinality.
**Why now**: `EGF_prodSpecies` already pins down the *enumerative* content, so the
remaining work is purely the equivariance bookkeeping — isolated and self-contained.
**If true**: `prodSpecies` becomes a true monoidal product on the category of species,
enabling species-level (not just EGF-level) algebraic statements.
**If false**: it would reveal a coherence obstruction in the skeletal `Species`
model, suggesting the groupoid action must be indexed by bijections, not just `Fin n`.

### Direction 2: Species composition and the chain-rule bridge
**Hypothesis**: For species `F`, `G` with `G[0] = ∅`, the substitution species
`(F ∘ G)[n] = Σ (partitions π of [n]) F[π] × ∏_{B ∈ π} G[B]` satisfies
`EGF (F ∘ G) = (EGF F) ∘ (EGF G)` (composition of EGFs).
**Test**: Define `compSpecies` over set partitions, compute its counting sequence,
and prove the EGF identity; the special case `F = E` should recover the
exponential formula `EGF(E ∘ G) = exp(EGF G)`. The key insight is that the
partition sum is exactly the combinatorial expansion of composition of power series.
**Why now**: With `sumSpecies` and `prodSpecies` and their bridges in hand, the
inductive scaffolding (sum over the size of the first block) reduces composition to
products already handled by `EGF_prodSpecies`.
**If true**: completes the three core operations (`+`, `·`, `∘`) of Joyal's calculus
in Lean — the exponential formula, connected/disconnected structures, and species
of trees all become accessible.
**If false**: the failure would localize to the partition bookkeeping (Faà di Bruno
coefficients), pinpointing exactly which Mathlib partition lemmas are missing.

### Direction 3: Sharpen rigidity to a ring isomorphism onto its image
**Hypothesis**: The map `coeffSeq ↦ EGF` is an injective ring homomorphism from
`(ℕ → ℚ, +, ⋆)` (with `⋆ = binConv`) into `ℚ⟦X⟧`, i.e. `EGF_inj_coeffSeq` extends to
a `RingHom` whose kernel is trivial, so two species are EGF-equal iff they are
counting-equal *and* this equivalence respects both operations.
**Test**: Package `egf` as a `RingHom` (using `egf_add`, `egf_mul`, and the unit
`egf (Pi.single 0 1) = 1`) and prove injectivity from `EGF_inj_coeffSeq`. The key
insight is that rigidity plus the two bridge laws is exactly the data of an
injective ring homomorphism.
**Why now**: all three ingredients (additivity, multiplicativity, injectivity) are
now proved this cycle; only the bundling remains.
**If true**: gives a structural theorem "the EGF is a faithful representation of the
binomial-convolution ring", a reusable algebraic object for downstream work.
**If false**: a missing unit or distributivity law would surface, revealing that the
binomial-convolution structure on `ℕ → ℚ` is weaker than a full ring.

### Direction 4: Derivative/pointing and the operator `X · d/dX`
**Hypothesis**: The pointing species `F•` with `F•[n] = Fin n × F[n]` (a distinguished
label) has counting sequence `n ↦ n · |F[n]|` and EGF `X · (EGF F)′`, where `′` is the
formal derivative on `ℚ⟦X⟧`.
**Test**: Define `pointSpecies`, prove `coeffSeq (F•) n = n * coeffSeq F n`, and match
it against `PowerSeries.derivative`. The key insight is that multiplying the `n`-th
coefficient by `n` is exactly `X·d/dX` at the level of EGFs.
**Why now**: pointing is the simplest *differential* operation and reuses the same
"EGF sees only the counting sequence" reduction that made this cycle's bridges trivial.
**If true**: opens the differential calculus of species (recurrences for labelled
trees and endofunctions via `L = E(C)`, etc.).
**If false**: a mismatch with Mathlib's `PowerSeries.derivative` normalization would
indicate the factor `n!` must be tracked more carefully than in the integral bridges.

### Direction 5: Cycle-index / unlabelled enumeration beyond the EGF
**Hypothesis**: The EGF is *not* a complete invariant of a species as a functor: there
exist non-isomorphic species (different `act`) with identical EGFs, distinguished only
by their cycle-index series (ordinary generating function of orbits under relabelling).
**Test**: Exhibit two `Species` with equal `coeffSeq` (hence equal EGF by
`EGF_inj_coeffSeq`'s converse) but non-isomorphic actions, e.g. `linearOrderSpecies`
vs. a species with `n!` structures permuted trivially; compute their orbit counts
(unlabelled structures) and show they differ. The key insight is that rigidity holds
for the EGF *only* because it forgets the action — the action carries strictly more
information.
**Why now**: `EGF_inj_coeffSeq` precisely delimits what the EGF *does* capture, so the
natural falsifiable question is what it *misses*; the catalog already provides two
concrete species (`setSpecies`, `linearOrderSpecies`) to contrast.
**If true**: motivates formalizing the cycle-index series and Burnside/orbit-counting
as the finer invariant — the genuinely categorical (not merely analytic) layer.
**If false**: it would mean (surprisingly) that the action is determined by the counts,
collapsing the species/EGF distinction and overturning a basic tenet of Joyal's theory.
