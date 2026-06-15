# FUTURE DIRECTIONS
## Functorial Tropical–Ultrametric Connectivity Bounds for Rips Filtrations

This cycle established the **connectivity-collapse theorem** for Rips filtrations
built from valuation-depth data: in an ultrametric (= tropical-triangle) setting,
path-connectivity in the Rips 1-skeleton at scale `ε` coincides exactly with the
single-edge relation `vdist x y ≤ ε`, the connected components are exactly the
closed `ε`-balls, and the whole picture is *functorial* under depth-non-expansive
maps. See `TropicalUltrametricRipsConnectivity.lean`.

Below are bold, testable conjectures for follow-up cycles. Each is stated to be
falsifiable (a single counterexample, or a single proof, settles it).

---

### Conjecture 1 — Trivial persistent H₀ barcode (ultrametric ⟹ all bars start at 0)
For valuation-depth data on a finite set, the persistent **0-th homology** barcode
of the Rips filtration has *every* bar born at scale `0` (each point is its own
component until merges happen) and every merge happens at some `vdist` value that
already appears as a pairwise distance. Formally: the set of "death scales" of the
π₀-filtration is a subset of `{ vdist x y | x y }`. Stronger form: the number of
connected components of `vRipsGraph D ε` is a *step function* of `ε` whose jumps
occur only at attained pairwise distances. **Test:** define `numComponents D ε`
and prove it is locally constant away from the finite set of pairwise distances.

### Conjecture 2 — Exact connectivity threshold equals depth-diameter
For finite nonempty depth data `D`, define `connThreshold D := sInf { ε ≥ 0 |
(vRipsGraph D ε).Connected }`. Conjecture: `connThreshold D = ⨆ x y, vdist x y`
(the depth-diameter), and the infimum is **attained** (the graph is already
connected *at* the diameter, not merely above it). This sharpens
`vRipsGraph_connected_of_diam_le` / `vRipsGraph_diam_le_of_preconnected` into an
exact equality with attainment. **Test:** prove both inequalities and attainment
for `Fintype α`.

### Conjecture 3 — Functorial barcode contraction (interleaving bound)
A depth-non-expansive map `f` with the reverse bound `D.vdist x y ≤ c · D'.vdist
(f x) (f y)` for some `c ≥ 1` induces a `log c`-interleaving (in the additive or
multiplicative sense) of the two π₀-persistence modules. In particular an
*isometry* of depth data induces *identical* barcodes. This would upgrade
`vReachable_map` from a one-directional connectivity transfer to a quantitative
stability/interleaving statement, connecting to
`Applications/BoltzmannBridge/Interleaving*`. **Test:** formalize the bottleneck/
interleaving distance of the two component-count functions and bound it by `c`.

### Conjecture 4 — Ultrametric is the *only* metric with the collapse property
The connectivity collapse `Reachable x y ↔ dist x y ≤ ε` (for all `ε ≥ 0` and all
finite subsets) **characterizes** ultrametric spaces: if a metric space has the
property that every Rips path keeps endpoints within the scale, then `dist`
satisfies the strong triangle inequality. Equivalently, `vdist_ultra` is not just
sufficient but necessary. **Test:** prove the converse — from
`∀ ε ≥ 0, ∀ x y z, (dist x y ≤ ε ∧ dist y z ≤ ε) → dist x z ≤ ε`, derive
`dist x z ≤ max (dist x y) (dist y z)` (take `ε = max …`). This direction looks
provable and would turn the main theorem into an iff-characterization of
ultrametricity.

### Conjecture 5 — Cliques = balls (higher Rips skeleton triviality)
In ultrametric depth data, every clique of `vRipsGraph D ε` is contained in a
single closed `ε`-ball, and conversely every `ε`-ball is a clique. Hence the full
Vietoris–Rips *complex* (all skeleta) at scale `ε` is a disjoint union of
**simplices** (one per ball), so it is homotopy-equivalent to its set of
components and *all* higher persistent homology `Hₖ`, `k ≥ 1`, vanishes
identically. This would be the higher-dimensional culmination of the π₀ collapse
proved this cycle. **Test:** prove `IsClique (vRipsGraph D ε) S ↔ ∃ x, S ⊆ vBall
D ε x` for finite `S` (forward direction needs the pairwise `max` argument), then
state the contractibility/`Hₖ = 0` corollary.
