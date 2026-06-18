# Future Directions: Proof-Net Curvature and Phase Transitions

This cycle introduced `ProofNetCurvature.lean`, isolating a single scalar
observable — the **wormhole curvature** of a tropical (min-plus) weighted graph,
`wormholeCurvature W u v x y τ = d_W(x,y) − d_{surgery}(x,y)` — and proving its
core structural laws on top of the catalog `ChargedSurgery` development:
nonnegativity, monotonicity of distance in the tunnel cost, the *threshold phase
transition* (curvature vanishes once the shortcut cost exceeds the direct edge),
and the gauge invariance / domination of the **charged** refinement. The
following directions extend this into a genuine theory of curvature observables
for automated theorem search, where the weighted graph is a proof-dependency
network and a "wormhole" is a newly discovered lemma that shortcuts many proofs.

---

## Direction 1 — The single-use lower bound (closing `ChargedSurgery`'s open `sorry`)

The catalog theorem `tropicalDistance_chargedSurgery_le_uncharged_add_defect`
remains open precisely because it needs the *matching lower bound*
`d_{surgery}(x,y) ≥ min(d_W(x,y), d_W(x,u)+λ+d_W(v,y), d_W(x,v)+λ+d_W(u,y))`.
Conjecture: with nonnegative weights, every shortest walk in a once-surgered graph
uses each cheap bridge edge **at most once**, so the surgered distance equals the
explicit three-way minimum, not merely bounds it.

**The key insight is** that any bridge traversal whose surgery weight equals the
original edge weight `W` is "inert" and the walk can be re-read as a plain
`W`-walk; the only *active* traversals cost exactly `λ`, and a loop-erasing
(simple-path) reduction with nonnegative weights leaves at most one active
traversal. Formalizing loop-erasure for the `Fin (k+1) → Fin n` walk encoding is
the missing infrastructure. **Why now?** The upper bound, gauge invariance, and
the entire `ProofNetCurvature` layer are already proved; only this one
combinatorial lemma blocks an exact closed form for surgered distance, which in
turn makes the curvature observable *computable* rather than merely bounded.

## Direction 2 — A discrete Lipschitz law: curvature is `1`-Lipschitz in `τ`

We proved curvature is antitone in `τ` and vanishes above threshold. The natural
quantitative strengthening is
`|wormholeCurvature W u v x y τ₁ − wormholeCurvature W u v x y τ₂| ≤ |τ₁ − τ₂|`,
i.e. the surgered distance is `1`-Lipschitz in the tunnel cost.

**The key insight is** that bumping `τ` by `ε` raises the cost of any walk by at
most `ε` per *active* bridge traversal, so once Direction 1 caps active
traversals at one, the Lipschitz constant is exactly `1`. This is falsifiable: a
weighted graph where the optimal route oscillates across the bridge would push
the constant above `1` and refute it. **Why now?** It converts the qualitative
"phase transition" into a continuity modulus, turning the curvature into a
well-behaved order parameter amenable to the phase-diagram language of the parent
concept.

## Direction 3 — Subadditivity / triangle law for curvature of composed surgeries

Inserting two wormholes `(u,v)` then `(u',v')` should curve the network by no
more than the sum of the individual curvatures plus a mixed term. Conjecture:
`wormholeCurvature` of the two-edge surgery `≤` sum of the two single-edge
curvatures, with equality iff the two shortcuts are not jointly used by any
shortest path.

**The key insight is** that distance contraction is governed by the min-plus
matrix product, where adding two shortcut edges corresponds to two rank-one
tropical perturbations whose combined effect telescopes through the triangle
inequality `tropicalDistance_triangle` already in the catalog. **Why now?** The
single-surgery theory is complete and the triangle inequality is available; the
multi-surgery case is the first place where *interaction* between proof-net
shortcuts appears, which is exactly the regime where a curvature "phase" can
become collective rather than local.

## Direction 4 — Gauge curvature as a holonomy class

The charged surgery carries a gauge potential `A : V → ℝ`; we proved the charged
curvature is invariant under the global shift `A ↦ A + c`. Conjecture: the charged
curvature depends on `A` only through the *defects* `|A u − A v|` along the
inserted edges, i.e. it is a genuine function on the quotient `ℝ^V / ℝ·𝟙`, and
sums of defects around a cycle of wormholes form a conserved holonomy that is
invariant under re-gauging.

**The key insight is** that `chargedPenalty` already factors through `|A u − A v|`
(catalog `chargedPenalty_gaugeInvariant`), so a cycle of `k` wormholes accumulates
`κ·Σ|A u_i − A v_i|`, a discrete line integral of the gauge field that telescopes
to a holonomy depending only on the endpoints' equivalence class. **Why now?**
Gauge invariance for a single edge is proved; lifting it to cycles is the step
that makes "charge" a topological, not merely local, feature — the natural bridge
between the tropical-metric and gauge-theory framings in the project catalog.

## Direction 5 — Curvature concentration and a search-time phase transition

The motivating conjecture is that a growing proof-dependency graph exhibits a
graph-geometric curvature observable that undergoes a phase transition as the
search proceeds. Concretely: model lemma discovery as a sequence of random
wormhole insertions and study the distribution of total curvature
`Σ wormholeCurvature` over random source/target pairs. Conjecture: there is a
critical density of shortcuts above which the *mean* curvature collapses to `0`
(every remaining shortcut is above threshold and hence inert) — a sharp
saturation transition.

**The key insight is** that `wormholeCurvature_eq_zero_of_threshold` already
pinpoints the per-edge inert regime, so the global transition is the percolation
of inert edges: once enough shortcuts exist, fresh ones almost surely exceed the
contracted direct distance and add zero curvature. **Why now?** The exact
threshold law for a single edge is proved this cycle, giving the microscopic rule
needed to state — and computationally test on random graphs — the macroscopic
phase transition that names the whole research program.
