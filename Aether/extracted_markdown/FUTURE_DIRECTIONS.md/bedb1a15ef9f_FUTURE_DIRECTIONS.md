# Future Directions — Tropical Compactification of M_g

## Synthesis

This cycle attacked the dimension theory underlying the tropical compactification
of the moduli space of curves `\overline{M}_g`. The tropical moduli space
`M_g^trop` is a *cone complex*: each combinatorial type of stable tropical curve
(a connected weighted metric graph satisfying the local stability inequality
`2·w(v) + val(v) ≥ 3`) contributes a cone whose dimension equals the number of
edges, and whose faces — edge contractions — are exactly the boundary divisors of
`\overline{M}_g`. We isolated the entire content of the classical fact
`dim M_g = dim M_g^trop = 3g − 3` into a single subtraction-free combinatorial
inequality, `key_inequality`: `#E + 3 ≤ 3·b₁ + 2·W`, obtained by summing the
per-vertex stability bound and feeding the handshaking lemma plus the
Euler/Betti relation `#V + b₁ = #E + 1` to `omega`. From this one inequality the
dimension bound `edges_le_three_g_sub_three` falls out immediately, and the
sharpness construction `sharpBouquet` (a trivalent, weight-zero graph with
`2(g−1)` vertices and `3(g−1)` edges) shows the bound is attained for every
`g ≥ 2`.

The most instructive event of the cycle was a *failure*. The natural conjecture
"a curve is top-dimensional iff it is weight-zero" was refuted by `omega`: weight
zero only forces `2E ≥ 3V`, which bounds `E` from below relative to `V` but never
pins equality. The Critic's explicit counterexample `bouquetTwoLoops` — a single
vertex with two self-loops (valence 4, weight 0, genus 2, only 2 < 3 edges) —
makes the obstruction concrete: *excess valence*. This forced the correct
statement `top_cone_iff_trivalent_weightless`: the top cones (the interior of
`M_g^trop`) are precisely the **pure AND trivalent** types. The structural
insight is that the slack in `key_inequality` decomposes into two independent
non-negative contributions, total vertex weight `W` and total excess valence
`Σ(val − 3)`, and a maximal cone is exactly where both vanish — mirroring the
algebro-geometric fact that the deepest boundary strata of `\overline{M}_g` are
maximally degenerate irreducible nodal curves with 3-valent dual graphs.

These results sit alongside and beneath the catalog's
`Tropical/BrillNoether/Defs.lean` (`ChainOfLoops`, `brillNoetherNumber`,
Baker–Norine divisor theory): that file studies divisors *on* a fixed tropical
curve, whereas this file supplies the dimension theory of the *ambient moduli
cone complex* those curves vary in. The chain-of-loops graph is itself a
trivalent weight-zero type, hence a point of a top cone here; connecting the two
is the most promising next step.

## Results Summary

- `key_inequality`: proved — the master inequality `#E + 3 ≤ 3·b₁ + 2·W` from which all dimension statements follow.
- `edges_le_three_g_sub_three`: proved — every stable tropical curve of genus `g` has at most `3g − 3` edges, i.e. `dim M_g^trop ≤ 3g − 3`.
- `top_cone_implies_weightless`: proved — top-dimensional (maximal edge count) forces all vertex weights to vanish (purity is necessary).
- `top_cone_iff_trivalent_weightless`: proved — full characterization: maximal edge count iff every vertex is weight-zero and trivalent.
- `sharpBouquet` / `sharpBouquet_realises`: proved — explicit trivalent weight-zero graph attaining `3g − 3` edges for every `g ≥ 2`, so the bound is sharp and `dim M_g^trop = 3g − 3`.
- `bouquetTwoLoops` / `bouquetTwoLoops_not_top`: disproved (converse) — a weight-zero genus-2 curve that is NOT top-dimensional, refuting "weightless ⇒ top" and pinpointing excess valence as the obstruction.

## Research Directions

### Direction 1: Count the maximal cones — the genus-2 and genus-3 fans
**Hypothesis**: The number of distinct trivalent weight-zero combinatorial types
of genus `g` (the maximal cones of `M_g^trop`, up to isomorphism) is finite and,
for small `g`, equals the known values (`g = 2`: 2 types; `g = 3`: 5 types).
**Test**: Define isomorphism of `StableTropicalCurve` combinatorial types and
enumerate, with `Decidable` instances, all trivalent weight-zero types for fixed
small `g`; prove the counts by `decide`/explicit bijection.
**Why now**: We already have the exact constraints (`3V = 2E`, `V + b₁ = E + 1`,
`val ≡ 3`) that a maximal cone must satisfy, so the search space is fully pinned
down by this cycle's lemmas.
**If true**: Gives the first formal handle on the *combinatorial type poset* of
`M_g^trop`, the skeleton of the boundary complex of `\overline{M}_g`.
**If false**: Either our stability model is too coarse (missing graph
automorphisms) or the classical counts assume connectivity/2-edge-connectivity we
have not encoded — both diagnostic.

### Direction 2: Codimension = number of edge contractions
**Hypothesis**: For any stable tropical curve, the codimension of its cone inside
the top dimension is exactly the total slack `W + Σ_v (val(v) − 3) = 3g − 3 − #E`,
and each unit of slack corresponds to one independent edge-contraction/face
relation.
**Test**: Prove `3 * genus = #E + 3 + W + Σ_v (val v − 3)` (an exact identity
strengthening `key_inequality` to an equality) and interpret each summand.
**Why now**: `key_inequality` already exposes the slack as `W` plus excess
valence; turning the inequality into an identity is a direct next step requiring
only the handshake and Betti relations we have.
**If true**: Promotes the dimension *bound* to a precise *codimension formula*,
the combinatorial shadow of the stratification of `\overline{M}_g` by topological
type.
**If false**: Reveals a hidden degeneracy (e.g. disconnection after contraction)
that the naive slack count misses.

### Direction 3: Bridge to Brill–Noether — chain-of-loops as a top cone
**Hypothesis**: The catalog's `ChainOfLoops` of genus `g` is (after recording
valences) a trivalent weight-zero `StableTropicalCurve`, hence lies in a maximal
cone of `M_g^trop`, and its `2g` edges plus genericity give the `brillNoetherNumber`
as the expected dimension of a divisor stratum.
**Test**: Construct a `StableTropicalCurve` from `ChainOfLoops g`, prove it
satisfies `top_cone_iff_trivalent_weightless`, and relate its edge count to
`3g − 3` (the chain of loops is NOT maximal for `g ≥ 3`, so quantify its
codimension via Direction 2).
**Why now**: Both objects now exist formally in the same `Tropical` namespace;
the missing link is a single structure-building lemma.
**If true**: Unifies the moduli-dimension theory of this cycle with the existing
divisor/Brill–Noether catalog, a genuine cross-domain bridge.
**If false**: Shows the chain-of-loops genericity is incompatible with maximal
degeneration, sharpening when tropical Brill–Noether arguments apply.

### Direction 4: Euler characteristic / Betti positivity for `g ≥ 2`
**Hypothesis**: Every stable tropical curve of genus `g ≥ 2` has `b₁ ≥ 1` and
`#V ≤ 2(g − 1)`, with both bounds attained exactly on the trivalent weight-zero
types.
**Test**: Derive `#V ≤ 2g − 2` from `key_inequality` plus stability, and
characterize equality (it should again be `top_cone_iff_trivalent_weightless`).
**Why now**: The same summed-stability machinery that bounds edges also bounds
vertices; it is a one-inequality variant we can prove with the existing `omega`
pipeline.
**If true**: Completes the "face vector" picture (`#V`, `#E`, `b₁`) of maximal
cones, the input data for computing the homotopy type of `M_g^trop`.
**If false**: Indicates the stability inequality alone does not control vertex
count, signaling a need for connectivity hypotheses.

### Direction 5: Weighted (universal) curve and the `n`-marked refinement
**Hypothesis**: For `M_{g,n}^trop` (curves with `n` marked legs) the dimension is
`3g − 3 + n`, obtained by upgrading stability to `2·w(v) + val(v) + legs(v) ≥ 3`
and counting legs as half-edges.
**Test**: Add a `legs : Fin numVertices → ℕ` field with total `n`, redo
`key_inequality` with the modified handshake `Σ val + n = 2E + n`, and prove
`#E + 3 ≤ 3·g + n − ... `; identify the corrected sharp construction.
**Why now**: Our model is parametric and subtraction-free, so adding a leg field
and re-running `omega` is low-risk; the marked case is the version actually used
in Gromov–Witten theory.
**If true**: Extends every theorem here to the moduli space that appears in
enumerative geometry, dramatically widening applicability.
**If false**: Exposes that legs interact with stability differently than weights
(e.g. a leg stabilizes but does not add a length coordinate), a subtle and
informative distinction.
