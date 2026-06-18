# Future Directions: Belnap's FOUR as a Lattice & the Non-Topology of Dream Spaces

## Synthesis

This cycle turned two *informal* slogans — "paraconsistency is the existence of a glut" and
"dream-like reasoning is locally coherent but globally inconsistent" — into machine-checked
mathematics, and discovered that they are the *same* phenomenon viewed through two lenses.

On the algebraic side (`BelnapFourLattice.lean`) we built Belnap's four-valued `FOUR` as a
genuine `DistribLattice` with `BoundedOrder` under the truth ordering, equipped it with the
involutive De Morgan negation, and proved the centrepiece `paraconsistency_iff_glut`: the
satisfiability of a contradiction with an irrelevant undesignated conclusion (the failure of
*ex contradictione quodlibet*) is *equivalent* to the existence of a designated glut. The
structural surprise is that the two "singular" values are exactly the **self-dual** ones
(`neg x = x`): the glut `B` is the self-dual *designated* fixed point, the gap `N` the
self-dual *undesignated* fixed point. Negation's two fixed points carry the entire
paraconsistent payload, and `glut_iff_B`/`gap_iff_N`/`unique_glut`/`unique_gap` pin them down.

On the topological side (`DreamSpaceNat.lean`) we defined `DreamSpace` (closed under finite
intersection and containing `∅`/`univ`, but *not* arbitrary unions) and `IsTopological`. We
proved the canonical finite-or-univ space `dreamNat` is non-topological by a genuine
infinitary argument (`dreamNat_not_topological`): the evens are a union of the open singletons
`{2k}` yet are neither finite nor all of `ℕ`. The cross-domain bridge `valuationDream` shows
the *same* failure for the space of valuations `ℕ → V`: with opens = "finitely determined"
sets, each cylinder "atom `n` has value `a`" is open, but "some atom has value `a`" is not —
even though it is their union. Instantiated at Belnap `FOUR` (`B ≠ T`), this is exactly
"some atom is a glut": locally checkable, globally not. The structural insight tying the cycle
together: **local finiteness/decidability does not survive arbitrary union**, and that gap is
the topological mirror of how locally-consistent valuations can be globally contradictory.

What did *not* work, and why: a first `valuationDream` used "finite atom-specifications" as
its opens; that family silently fails to contain `∅` (any nonempty spec is satisfiable when
`V` is nonempty), so it was not even a dream space. Replacing the opens by "membership decided
by finitely many atoms" repaired both the empty-set axiom and the intersection axiom at once
and made the non-topologicality proof fall out cleanly.

## Results Summary

- `BelnapFour.Four.instDistribLattice` (the `DistribLattice Four` instance): proved — FOUR is a distributive lattice under the truth ordering.
- `BelnapFour.Four.instBoundedOrder` (the `BoundedOrder Four` instance): proved — FOUR is bounded with `⊥ = F`, `⊤ = T`.
- `BelnapFour.Four.neg_neg`, `deMorgan_inf`, `deMorgan_sup`: proved — FOUR is a De Morgan algebra (involutive, antitone negation).
- `BelnapFour.Four.glut_iff_B`: proved — `B` is the unique glut (self-dual designated value).
- `BelnapFour.Four.gap_iff_N`: proved — `N` is the unique gap (self-dual undesignated value).
- `BelnapFour.Four.unique_glut`, `unique_gap`: proved — uniqueness of the singular values.
- `BelnapFour.Four.paraconsistency_iff_glut`: proved — failure of explosion ⇔ existence of a designated glut (the centrepiece).
- `BelnapFour.Four.explosion_fails`, `not_glut_and_gap`: proved — corollaries: FOUR is paraconsistent; no value is both a glut and a gap.
- `DreamLogic.dreamNat`: proved (construction) — the finite-or-univ family is a dream space on `ℕ`.
- `DreamLogic.evens_not_dreamOpen`: proved — the evens are not open in `dreamNat`.
- `DreamLogic.dreamNat_not_topological`: proved — `dreamNat` is genuinely non-topological (main infinitary result).
- `DreamLogic.dreamNat_fails_at`: proved — generalization: every infinite, co-infinite subset of `ℕ` is non-open.
- `DreamLogic.valuationDream`: proved (construction) — finitely-determined sets of valuations form a dream space.
- `DreamLogic.valuationDream_not_topological`: proved — non-topological for any `V` with two distinct values.
- `DreamLogic.belnapValuationDream_not_topological`: proved — cross-domain instantiation at Belnap `FOUR`.

## Research Directions

### Direction 1: Bilattice homomorphisms preserve paraconsistency iff they preserve the glut
**Hypothesis**: Extend `FOUR` with its *knowledge ordering* (`N ≤_k F,T ≤_k B`) to a bilattice,
and let `φ : FOUR → L` be a bilattice homomorphism into a De Morgan bilattice `L`. Then `φ`
preserves paraconsistency (the image logic still fails explosion) **iff** `φ(B)` is a glut in
`L` (both `φ(B)` and `¬φ(B)` designated).
**Test**: Formalize `KnowledgeLattice Four` analogously to the truth-ordering instance, define
`BilatticeHom`, and prove the biconditional; disprove the naive version where only `φ(B)`
designated (without `¬φ(B)`) by exhibiting a collapsing `φ`.
**Why now**: `paraconsistency_iff_glut` and `glut_iff_B` already isolate "designated glut" as
the operative condition; the functorial lift only needs the second (knowledge) lattice, whose
table is as finite as the truth table we already discharged by `decide`.
**If true**: A clean categorical characterization of which morphisms of paraconsistent algebras
are "explosion-safe" — the foundation for a category of paraconsistent logics.
**If false**: The counterexample would reveal a morphism that preserves the glut element but
not the *failure of explosion*, showing paraconsistency is not a purely local/element-wise
property and must be tracked globally.

### Direction 2: The topological completion of `dreamNat` is the discrete topology
**Hypothesis**: The smallest topology containing `dreamNat`'s opens (close under arbitrary
unions, then under the resulting finite intersections to a fixpoint) is the **discrete**
topology on `ℕ`; equivalently, the "topological defect" set (sets forced open by completion
that were not `dreamNat`-open) has cardinality `2^ℵ₀`.
**Test**: Define `completion D := ⋃-closure` and prove `(completion dreamNat).IsOpen = fun _ => True`
by showing every singleton is open and every set is a union of singletons; then compute the
defect cardinality via `Set.ncard`/`Cardinal`.
**Why now**: `evens_eq_iUnion`-style decompositions and `singleton_dreamOpen` give exactly the
machinery: every set is `⋃₀` of its open singletons, so one union step already yields discreteness.
**If true**: Confirms `dreamNat` sits "one union away" from the discrete topology — the defect
is maximal, quantifying how far a dream space can be from a topology.
**If false**: Some set resists the completion, meaning the union-closure of `dreamNat` is a
strictly intermediate (non-discrete) topology — a more interesting object worth classifying.

### Direction 3: Non-topological points of `valuationDream` are the infinitely-glutted valuations
**Hypothesis**: In `valuationDream BelnapFour.Four`, define a valuation `v` to be a
*non-topological point* if every dream-open neighbourhood basis at `v` fails to be a genuine
filter base for a point of the union-completion. Then the non-topological points are exactly
the valuations assigning `B` (glut) to infinitely many atoms.
**Test**: Make "non-topological point" precise via failure of the neighbourhood filter to be
closed under the completion's opens, then prove the iff by the same `Infinite.exists_notMem_finset`
argument used in `exists_atom_not_finitelyDetermined`, now relativized to the glut-set `{n | v n = B}`.
**Why now**: `valuationDream` and `belnapValuationDream_not_topological` already supply the dream
space and the obstruction set "some atom is a glut"; the bridge needs only to localize that
obstruction to individual valuations.
**If true**: A precise dictionary "infinitely-glutted valuation ⇔ non-topological point",
unifying the Belnap algebra with point-set topology in a verified setting.
**If false**: Non-topological points would be governed by something other than glut-density
(e.g. gaps `N`, or value-alternation patterns), reshaping the conjectured Belnap/topology bridge.

### Direction 4: Counting gluts in finite De Morgan algebras
**Hypothesis**: For each `n ≥ 4` there is, up to isomorphism, a bounded distributive De Morgan
algebra on `n` elements whose number of gluts (self-dual designated points strictly between
`⊥` and `⊤`) equals `⌊n/2⌋ − 1`, generalizing `FOUR`'s single glut `B`.
**Test**: Build the `2k`-element "diamond chain" algebra in Lean, define `glut`/`gap` as in
`BelnapFourLattice.lean`, and prove the glut count by a `Fintype.card`/`Finset.filter`
computation; disprove for algebras violating self-duality of negation.
**Why now**: `glut_iff_B`/`gap_iff_N` give the exact template ("self-dual + designation") for
detecting gluts, and `unique_glut` shows the counting method works at `n = 4`.
**If true**: A combinatorial formula linking lattice width to "capacity for contradiction" —
a graded theory of paraconsistency.
**If false**: The glut count is not a function of cardinality alone but of the negation's
fixed-point structure, sharpening what data actually controls paraconsistent strength.

### Direction 5: Dream spaces as a non-monotone belief-revision dynamics
**Hypothesis**: The operation "remove one open set from a dream space" (belief retraction) and
"add one open set" (learning) generate a transition system on `DreamSpace X` under which
`dreamNat` and its completion are connected, and retraction is genuinely non-monotone
(re-adding a previously removed open need not restore the prior space).
**Test**: Define `add`/`remove` as the minimal re-closure of `IsOpen` under finite intersection,
prove `remove ∘ add ≠ id` by exhibiting a witness in `dreamNat`, and relate a retraction step to
the LPm non-monotonicity already proved in the sibling file `Paraconsistent.lean`
(`retraction_nonmonotone`).
**Why now**: We now have a concrete `DreamSpace` API (finite-intersection closure) and a
proven non-monotone consequence relation next door; the bridge needs only to read retraction as
open-removal.
**If true**: A verified bridge from paraconsistent/non-monotone *logic* to a dynamical *topology*
of belief states — connecting `Paraconsistent.lean`'s LPm to `DreamSpaceNat.lean`.
**If false**: Open-removal would turn out monotone (order-theoretically tame), indicating that
the genuine non-monotonicity of belief revision lives in the *valuation* layer, not the
*open-set* layer.
