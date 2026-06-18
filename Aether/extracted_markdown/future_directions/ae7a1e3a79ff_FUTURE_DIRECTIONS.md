# Future Directions: Stable Tropical Curves and the Moduli Cone Complex

## Synthesis

This cycle built the combinatorial backbone of the tropical moduli space
`M_{g,n}^trop` directly, rather than only studying its tropical-semiring shadow.
The previous catalog work (`Catalog/Tropical/ModuliCompactification.lean`) fixed
the genus convention `g = |E| − |V| + 1` and proved `tree_genus_zero` and
`genus_connected` for `SimpleGraph`s. We abstracted away from `SimpleGraph` —
which cannot carry the multi-edges and loops that pervade stable curves — to a
lightweight `MarkedCombType` record: vertices, a valence function, an edge count,
a leg (marked-point) count, and the single handshaking axiom
`∑_v deg(v) = 2E + n`. This abstraction was decisive: it made the entire theory
of edge bounds collapse to one inequality.

The central discovery is that the sharp dimension bound `|E| ≤ 3g − 3 + n` of the
top cone of `M_{g,n}^trop` is **literally** the inequality `3V ≤ 2E + n`, which is
nothing more than handshaking combined with pointwise stability `deg(v) ≥ 3`.
Once this is seen, every downstream fact is linear arithmetic over `ℤ`: the
unmarked bound `|E| ≤ 3g − 3`, the sharpness statement that trivalent graphs
attain equality, the global Deligne–Mumford stability `2g − 2 + n ≥ V ≥ 1`, and
the parity-driven fact that unmarked stable curves force `g ≥ 2`. The theta graph
(two vertices, three parallel edges) was verified as a concrete genus-2 trivalent
witness attaining the bound — exactly the object `SimpleGraph` could not express.

What failed/clarified: a naive `simp [h]` could not rewrite a sum under a
`∀`-stability hypothesis; `Finset.sum_congr` was needed. More structurally,
`linarith` cannot see the integer parity step `2E ≥ 2V + 1 ⟹ E ≥ V + 1` that
rules out genus 1, whereas `omega` can — a reminder that the `g ≥ 2` lower bound
is an arithmetic (not merely linear) phenomenon. The structural insight that
emerged is that genus is an affine function of `(E, V)` with equal-and-opposite
coefficients, so it is invariant exactly under the *balanced* reduction performed
by non-loop edge contraction, and drops by one under loop contraction — which is
what grades the moduli cone poset by edge count.

## Results Summary

- `MarkedCombType.handshake_lower`: proved — stability `deg(v) ≥ 3` aggregates through handshaking to `3V ≤ 2E + n`, the arithmetic core of the whole theory.
- `MarkedCombType.marked_edge_bound`: proved — the sharp bound `|E| ≤ 3g − 3 + n`, i.e. the dimension of the top cone of `M_{g,n}^trop`.
- `MarkedCombType.edge_bound_unmarked`: proved — the `n = 0` specialization `|E| ≤ 3g − 3` (the originally targeted bound).
- `MarkedCombType.handshake_eq_trivalent`: proved — trivalent types satisfy `3V = 2E + n` exactly.
- `MarkedCombType.trivalent_edge_eq`: proved — trivalent stable types attain the bound with equality, so they are the maximal cones.
- `MarkedCombType.stable_global_stability`: proved — local stability implies global Deligne–Mumford stability `2g − 2 + n ≥ V`.
- `MarkedCombType.stable_global_stability_pos`: proved — `2g − 2 + n ≥ 1` for any nonempty stable type.
- `MarkedCombType.genus_ge_two_unmarked`: proved — every nonempty unmarked stable tropical curve has `g ≥ 2` (boundary case; `M_g^trop` has no top cones for `g < 2`).
- `MarkedCombType.genus_contract_nonloop`: proved — non-loop edge contraction preserves genus (codimension-1 face, same genus).
- `MarkedCombType.genus_contract_loop`: proved — loop contraction drops genus by 1.
- `MarkedCombType.theta`/`theta_trivalent`/`theta_genus`/`theta_attains_bound`: proved — the theta graph is an explicit genus-2 trivalent witness attaining `|E| = 3g − 3`.

## Research Directions

### Direction 1: Realizability — every admissible `(g, n)` cone is inhabited
**Hypothesis**: For all `g ≥ 0` and `n ≥ 0` with `2g − 2 + n > 0`, there exists a
`MarkedCombType` that is `Trivalent` (hence stable), has genus `g`, exactly `n`
legs, and therefore `E = 3g − 3 + n`. Conversely no such object exists when
`2g − 2 + n ≤ 0`.
**Test**: Construct an explicit family (e.g. a "caterpillar" of `g` loops opened
into bigons plus `n` legs distributed to keep all valences `= 3`) and prove its
`handshake` field; then prove non-existence in the unstable range by contradiction
with `stable_global_stability`. A `#eval`/`decide` sweep over small `(g, n)` can
pre-validate the construction before the general proof.
**Why now**: We already have the exact equality `trivalent_edge_eq` and the
obstruction `stable_global_stability_pos`; realizability is the missing converse
that turns "bound" into "dimension."
**If true**: It proves the cone complex `M_{g,n}^trop` is nonempty and
top-dimensional exactly on the Deligne–Mumford locus — a full existence theorem.
**If false**: A failing `(g, n)` would reveal a hidden parity or connectivity
obstruction beyond handshaking, sharpening what `MarkedCombType` must record.

### Direction 2: Connectivity and `β₁ ≥ 0` for disconnected types
**Hypothesis**: Enriching `MarkedCombType` with a component count `c` and the
refined genus `β₁ = E − V + c` yields `β₁ ≥ 0` for all types, with `β₁ = 0` iff
the underlying graph is a forest; and a connected stable type satisfies the
present `genus = β₁`.
**Test**: Either bridge to Mathlib's `SimpleGraph.ConnectedComponent` (as in the
catalog's `graphGenus`) for the simple-graph case, or prove `E ≥ V − c` by an
inductive edge-deletion argument internal to a multigraph model.
**Why now**: The catalog already computes `Fintype.card G.ConnectedComponent` and
proves `tree_genus_zero`; combining that with our handshaking abstraction is a
direct merge of two existing pieces.
**If true**: It generalizes `genus_ge_two_unmarked` to disconnected curves and
connects our abstract record to Mathlib's graph theory, closing the
forest-characterization gap noted in the original concept.
**If false**: It would expose that `E − V + 1` is the wrong invariant for
disconnected types, forcing the component count into the core structure.

### Direction 3: Contraction as a graded poset and an Euler-characteristic functor
**Hypothesis**: Edge contraction defines a graded partial order on combinatorial
types of fixed genus `g`, graded by `E` (= cone dimension), with the trivalent
types as maximal elements and the one-vertex type as minimum; genus is the unique
(up to scale) contraction-invariant affine functional of `(E, V)`.
**Test**: Define an actual contraction *operation* producing a new
`MarkedCombType` (building the contracted valence function), prove it preserves
`handshake` and `Stable` for non-loop edges, and show the resulting order is
graded using `genus_contract_nonloop`/`genus_contract_loop` as the key step.
**Why now**: We already proved the genus arithmetic of both contraction types;
only the structural (Fin-indexed) bookkeeping of the operation remains.
**If true**: It formalizes the face poset of the moduli cone complex and matches
contraction to codimension, the combinatorial heart of `M_{g,n}^trop`.
**If false**: A failure of stability-preservation under contraction would pinpoint
which low-valence configurations sit on cone boundaries.

### Direction 4: Vertex genera and the general stability `2g(v) − 2 + val(v) > 0`
**Hypothesis**: Allowing each vertex a nonnegative genus `g(v)` and total genus
`g = (E − V + 1) + ∑_v g(v)`, the per-vertex stability `2g(v) − 2 + val(v) > 0`
still yields `|E| ≤ 3g − 3 + n`, with equality iff every vertex has `g(v) = 0`
and `val(v) = 3`.
**Test**: Add `vgen : Fin V → ℕ` to the structure, redefine `genus`, and redo the
aggregation: stability now reads `val(v) ≥ 3 − 2g(v)`, so the sum bound must be
split by whether `g(v) = 0`. Prove the bound, then characterize equality.
**Why now**: Our proof isolates the single inequality `3V ≤ 2E + n`; replacing it
with a `g(v)`-weighted version is a localized generalization of one lemma.
**If true**: It captures *all* stable tropical curves (including curves with
positive-genus vertices), the genuinely general Deligne–Mumford object.
**If false**: It would show that positive vertex genera relax the edge bound,
revealing extra moduli directions invisible to the trivalent picture.

### Direction 5: The balancing condition and embeddings into `ℤ^N`
**Hypothesis**: Equipping each bounded edge with a primitive direction vector in
`ℤ^N` and a positive weight, the per-vertex balancing condition
`∑_{e ∋ v} w_e · d_e = 0` is consistent with stability for every trivalent type,
and the number of independent balancing equations equals `N · V`, bounding the
dimension of the space of tropical embeddings.
**Test**: Add `dir : edges → (Fin N → ℤ)` and `w : edges → ℕ` to the structure,
state balancing as a `Finset.sum` over incident edges, and prove a small case
(the theta graph in `ℤ^1`) by `decide`/linear algebra before the general count.
**Why now**: `MarkedCombType` already tracks incidence through valences; balancing
is a finite linear system over `ℤ` that Lean's `Matrix`/`Finset` API handles, and
the theta witness gives an immediate test bed.
**If true**: It bridges the purely combinatorial moduli theory to embedded
tropical curves (tropical subvarieties of `ℝ^N`), the analogue of holomorphicity.
**If false**: An unbalanceable trivalent type would identify which abstract cones
fail to be realized by genuine tropical subvarieties.
