# Future Directions — Rips Graph Monotonicity as a Functor into Tropical Valuation Objects

Derived from this cycle's findings in `Core.lean` and `Functoriality.lean`, which build the
object map (finite metric space ↦ normalized monotone edge-count profile in
`tropicalization_base`) and the morphism map (injective nonexpanding maps ↦ tropical
domination `RipsProfileDomination`).

## Conjecture 1 — The edge-count profile is *strictly* monotone across critical scales

**Statement.** For a finite metric space with at least two points at distance `d`, the
profile `ripsEdgeCount α` strictly increases at the threshold `r = ⌈d⌉`:
`ripsEdgeCount α (r-1) < ripsEdgeCount α r` whenever a pair first becomes connected at `r`.

**The key insight is...** that the *jumps* of the monotone profile encode exactly the
multiset of pairwise distances — the profile is a discrete derivative of the distance
distribution, so strict monotonicity at a scale certifies a new edge appearing there.

**Why now?** `ripsEdgeCount_mono` already gives the weak inequality through
`Set.ncard_le_ncard`; the strict version only needs an explicit witnessing edge in the
difference set, a small step that turns the profile into a genuine persistence summary.

## Conjecture 2 — Profiles separate finite metric spaces up to a tropical isometry invariant

**Statement.** Two finite metric spaces with integer distances have equal edge-count
profiles for all `r` iff they have the same multiset of pairwise distances; hence the
profile is a complete invariant of the distance multiset (though not of the space).

**The key insight is...** that `ripsProfile_max_chain` exhibits the profile as a chain in
`tropicalization_base`, and the successive tropical differences recover the distance
histogram bijectively.

**Why now?** Both directions of the equivalence are within reach of the `ncard`/`edgeSet`
machinery already used here; the forward direction is immediate and the reverse is a
counting identity over `Sym2 α`.

## Conjecture 3 — Domination is a genuine partial order, not merely a preorder, on profiles

**Statement.** On the quotient of finite integer metric spaces by "equal profile", the
relation `RipsProfileDomination` is antisymmetric: mutual domination forces equal profiles.

**The key insight is...** that `dom_refl` and `dom_trans` already give a preorder via
`tropicalization_base.le_refl`/`le_trans`, and `tropicalization_base.le_antisymm` upgrades
it to a partial order once profiles are the carriers.

**Why now?** The antisymmetry axiom is *already present* in `TropicalValuationObject`
(`le_antisymm`), so the categorical bridge built here exposes the order structure for free.

## Conjecture 4 — Non-injective nonexpanding maps satisfy a *reversed* bound

**Statement.** A surjective nonexpanding map `f : α → β` of finite metric spaces satisfies
`ripsEdgeCount β r ≤ (something explicit in fibers) · ripsEdgeCount α r`; in particular
quotient (gluing) maps can only *decrease* edges after accounting for collapsed pairs.

**The key insight is...** that the failure analysis in `Functoriality.lean` (injectivity is
necessary) is not a dead end but the boundary of a *second* functor going the other way —
collapsing points is a colimit-style operation dual to the embedding functor.

**Why now?** The counterexample showing non-injective maps break the forward bound is
already documented; formalizing its quantitative replacement is the natural next theorem and
connects to the catalog's `coveringNumber_antitone`.

## Conjecture 5 — The profile assembles into an `UltraNormObj` via tropical reconstruction

**Statement.** The edge-count profile of a finite metric space induces a separated
`UltraNormObj` (from `CategoricalTropicalUltrametric`) whose norm is the threshold at which
two configurations first agree, and nonexpanding embeddings induce `UltraHom`s.

**The key insight is...** that `valuationReconstruct` already turns ℕ-valued tropical
valuation data into an ultrametric seminorm object, so the profile (a ℕ-valued tropical
datum) should reconstruct an ultrametric directly, closing the Applications ↔ Bridges loop.

**Why now?** The reconstruction functor and its functoriality (`valuationReconstruct_map_comp`)
are mature in the catalog; the only missing input is precisely the tropical datum produced in
`Core.lean`, making this the immediate capstone of the bridge.
