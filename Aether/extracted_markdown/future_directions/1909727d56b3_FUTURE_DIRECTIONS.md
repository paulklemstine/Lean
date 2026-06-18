# FUTURE DIRECTIONS — Tropical Component-Rank Profiles of Metric Filtrations

Derived from the research cycle recorded in
`Catalog/Bridges/TropicalComponentRankProfile.lean`, which formalizes the
connected-component rank profile of a Rips filtration as a max-plus
`TropicalValuationObject` on `WithBot ℕ`, proves antitone/monotone behaviour,
functoriality under nonexpansive surjections, and nesting/interleaving stability.

Each conjecture below is falsifiable: it is either provable in Lean or refutable by
a finite counterexample.

---

## C1. Strict separation: component rank is strictly richer than edge count

**Statement.** There exist finite pseudometric spaces `α`, `β` and scales `ε`
with `edgeCount (ripsGraph α ε) = edgeCount (ripsGraph β ε)` but
`graphComponentCount (ripsGraph α ε) ≠ graphComponentCount (ripsGraph β ε)`, and
conversely equal component counts with distinct edge counts. Hence neither invariant
is a function of the other.

**The key insight is...** that component rank is `Nat.card` of a *quotient* of the
vertex set by reachability, while edge count is a sum over pairs; a quotient cardinal
cannot in general be reconstructed from a pair-sum, so the two filtration invariants
are provably independent coordinates.

**Why now?** The catalog already has both the edge-count machinery (`ripsGraph`,
`ripsGraph_mono`) and the freshly-built `graphComponentCount`; the separation is a
finite search over small graphs that the proving pipeline can certify directly with
`decide`-free `Nat.card` computations.

---

## C2. A persistence-style bottleneck bound for rank profiles

**Statement.** If two finite filtrations `F, G : ℝ → SimpleGraph V` are
`δ`-interleaved in *both* directions (`F ε ≤ G (ε+δ)` and `G ε ≤ F (ε+δ)` for all
`ε`), then for every `ε`,
`graphComponentCount (F (ε+δ)) ≤ graphComponentCount (G ε)` and
`graphComponentCount (G (ε+δ)) ≤ graphComponentCount (F ε)`,
i.e. the rank profiles are pointwise sandwiched within a `δ`-shift — a discrete
bottleneck-stability statement for `H₀`.

**The key insight is...** that `interleaved_rankProfile_tropOrder` already gives one
side of the sandwich from a single inclusion; a symmetric interleaving yields both
sides, turning the tropical order inequality into a two-sided stability band.

**Why now?** The one-directional theorem is already proved; the symmetric version is a
direct corollary needing only the mirror hypothesis, so it is low-risk and
immediately testable against the catalog `MetricFiltration` order.

---

## C3. The rank profile is a lattice homomorphism into the tropical object

**Statement.** For filtrations on a fixed finite `V`, the map
`F ↦ (ε ↦ graphComponentCount (F ε))` sends the pointwise *join* `F ⊔ G` of
filtrations to the pointwise tropical *min* of the rank profiles (component rank is
antitone, so a join of graphs gives the smaller rank), making the profile an
order-reversing lattice map into `tropNat`.

**The key insight is...** that `graphComponentCount_antitone_of_le` is exactly the
monotonicity needed for a Galois-style order-reversing map; upgrading it to preserve
binary joins/meets turns a single inequality into a structural homomorphism.

**Why now?** `SimpleGraph V` is already a complete lattice in Mathlib and
`graphComponentCount_antitone_of_le` is in hand, so the homomorphism law reduces to
comparing `Nat.card` of components of `G ⊔ H` against each factor.

---

## C4. Sub-additivity of merges: a quantitative tropical valuation law

**Statement.** For graphs `G, H` on finite `V`,
`graphComponentCount (G ⊔ H) ≥ graphComponentCount G + graphComponentCount H - Nat.card V`,
and the deficit `Nat.card V - graphComponentCount G` (the "merge count") is
sub-additive under graph union.

**The key insight is...** that `Nat.card V - graphComponentCount G` equals the rank of
a spanning forest of `G`; rank is sub-additive under union of edge sets, which is the
matroid-union shadow of the tropical "multiplication = +" law on profiles.

**Why now?** With `graphComponentCount` defined and its antitone law proved, the
forest-rank identity is the natural next lemma and connects the component invariant to
the additive (multiplicative-tropical) side of `tropNat`, not just the order side.

---

## C5. Functorial colimit: rank profile of a quotient metric space

**Statement.** If `f : α → β` is a distance-nonincreasing surjection of finite
pseudometric spaces that is also *distance-noncontracting on fibers' complement*
(an isometry off the collapsed set), then
`ripsComponentCount β ε = ripsComponentCount α ε` for all `ε` below the smallest
collapsed distance, and strictly drops above it.

**The key insight is...** that `ripsComponentMap` is already surjective for any
nonexpansive surjection; adding a lower distance bound makes it *injective* below the
collapse scale, so the induced component map becomes a bijection and the rank profile
is preserved exactly until clustering forces a strict drop.

**Why now?** The surjectivity half (`ripsComponentMap_surjective`) and the count
inequality (`ripsComponentCount_le_of_nonexpansive_surjective`) are proved; the
injectivity half is the remaining ingredient, giving a clean functorial
"colimit/quotient" theorem for the new finite-metric ⇒ tropical pipeline.
