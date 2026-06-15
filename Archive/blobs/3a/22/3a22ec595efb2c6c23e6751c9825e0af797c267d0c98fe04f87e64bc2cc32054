# FUTURE DIRECTIONS — Tropical Lipschitz Stability of Rips Filtrations

Follow-up research conjectures arising from `Bridges/TropicalRipsLipschitz.lean`. Each is
stated to be **falsifiable** and **formalizable** in Lean 4 on top of the `DistEnvelope` /
`IsUltrametric` / `rips` machinery already established. The completed cycle proved:
one-sided & two-sided Lipschitz interleaving (Movement A), tropical rigidity of ultrametric
Rips graphs and the reachability=single-comparison collapse (Movement B), the denoising
capstone `tropical_rips_lipschitz_stability` (Movement C), and the valuation-depth ⟹
ultrametric realization `valDepthEnvelope_isUltrametric` (Movement D).

---

## Conjecture 1 — Exact connected-component count of an ultrametric Rips graph

For a *finite* type `α` and an ultrametric envelope `E`, the relation `D · · ≤ ε` is an
equivalence (proved: `ultrametric_rel_equivalence`). Conjecture: the number of connected
components of `E.rips ε` equals the number of equivalence classes of that relation, and as a
function of `ε` it is a **monotone non-increasing right-continuous step function** whose jump
points are exactly the distinct values `{ E.D x y : x ≠ y }`.

*Falsifiable form.* Define `numComponents E ε := (connectedComponent setoid).card`. Prove
`Antitone (numComponents E ·)` and that `numComponents E ε = numComponents E ε'` whenever
no envelope value lies in `(ε, ε']`. A counterexample would be an ultrametric envelope where
crossing a non-value of `D` changes the component count.

## Conjecture 2 — The ultrametric persistence barcode is a multiset of envelope values

For finite ultrametric `E`, the 0-dimensional persistence barcode of the Rips filtration
(the multiset of "death scales" of connected components, since all components are born at
`-∞`/scale `0`) equals exactly the multiset of edge weights selected by single-linkage /
a minimum spanning tree of `(α, D)`. Conjecture: in the ultrametric case this MST multiset
coincides with `{ D x y }` restricted to a *transversal* of the merge tree, i.e. the
ultrametric is **completely recoverable** from its barcode (an "inverse problem solved").

*Falsifiable form.* Build `deathScales E : Multiset ℝ` from component merges and prove a
bijection with MST weights; the strong claim is that for ultrametrics this determines `D` up
to relabeling. Failure mode: two non-isometric ultrametrics with identical barcodes.

## Conjecture 3 — Quantitative bottleneck stability (sharpening Movement C)

The capstone `tropical_rips_lipschitz_stability` is a *qualitative* threshold statement.
Conjecture the *quantitative* persistence-stability upper bound: for ultrametric `E` and any
`E'` with `sup|E.D - E'.D| ≤ δ`, the **bottleneck distance** between the 0-dim persistence
diagrams of `E.rips` and `E'.rips` is `≤ δ` (no constant factor — the tropical setting is
sharp, unlike the generic `2δ` from triangle-inequality detours noted in the Movement A lab
notes).

*Falsifiable form.* Define a finite 0-dim diagram and a bottleneck matching; prove
`bottleneck (diag E) (diag E') ≤ δ`. Falsified by an `(E, E', δ)` triple forcing a matching
cost `> δ`.

## Conjecture 4 — Functoriality: valuation-depth pullback is 1-Lipschitz

`valDepthEnvelope` turns depth data `v` into an ultrametric envelope. Conjecture this
construction is **functorial and 1-Lipschitz in the depth**: if `v, v'` are two symmetric
min-superadditive depth functions with `sup|v - v'| ≤ η` and base `b ≥ 1`, then the induced
envelopes satisfy `sup|D - D'| ≤ (b^η - 1) · sup D` (a `b`-dependent modulus), so by
Movement A their Rips filtrations are interleaved with an explicit scale shift. This makes
the whole pipeline `depth ↦ envelope ↦ filtration` a single Lipschitz functor, realizing the
"valuation reconstruction is a quantitative functor" thesis of
`CategoricalTropicalUltrametric` end-to-end.

*Falsifiable form.* Prove the displayed envelope bound from `Real.rpow` Lipschitz estimates,
then chain with `rips_interleave`. Falsified by depth pairs violating the modulus.

## Conjecture 5 — Sub-dominant ultrametric is the optimal denoiser

> NOTE: the tentative "tropical rigidity characterization" originally slated here turned out
> to be immediate (instantiate transitivity at `ε = max (D x y) (D y z)`) and is now the
> *proved* theorem `isUltrametric_iff_sublevel_transitive` in the Lean file. It is replaced
> below by a genuinely open optimization conjecture.

For a finite `DistEnvelope` `E`, the **sub-dominant ultrametric** `U(E)` (the largest
ultrametric below `D`, computed via single-linkage / maximal-spanning-tree min-of-path-max)
is conjectured to be the *pointwise-optimal* ultrametric approximation realized by Rips
connectivity: for every scale `ε`, `(E.rips ε).Reachable x y ↔ U(E).D x y ≤ ε`. Combined
with the capstone, this would say the denoising map of Movement C **factors through and is
exactly** the sub-dominant ultrametric, and that `U` is `1`-Lipschitz:
`sup|U(E) - U(E')| ≤ sup|E - E'|`.

*Falsifiable form.* Define `U(E) x y := the min over Rips-paths of the max edge weight`,
prove the reachability equivalence and the Lipschitz bound. Falsified by an envelope where
Rips connectivity disagrees with the path-max ultrametric, or by an `(E, E')` pair violating
the `1`-Lipschitz bound (which would also refute Conjecture 3's sharp constant).
