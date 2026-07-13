# Computational evidence

We check the two closed forms proved in
`Catalog/Bridges/GraphComponentColoringBridge.lean` on small graphs.

## The counting identity `card_edgeConst`

> `#{ f : V → β // f constant on every edge of G } = (card β) ^ (#components of G)`

| graph `G` (vertices) | components `c` | `β = Fin k` | edge-constant colourings | `k^c` |
|---|---|---|---|---|
| empty on 3 vertices (no edges) | 3 | `k` | every `f` works: `k^3` | `k^3` ✓ |
| single edge `K₂` | 1 | `k` | `f` const on the edge: `k` | `k^1` ✓ |
| path `P₃` (2 edges, connected) | 1 | `k` | `f` const on component: `k` | `k^1` ✓ |
| matching `M₂` = `K₂ ⊔ K₂` | 2 | `k` | const on each edge: `k·k` | `k^2` ✓ |
| triangle `K₃` | 1 | `k` | `k` | `k^1` ✓ |

Sanity: for a graph with no edges the constraint is vacuous, so all `k^n`
functions qualify and `c = n`, matching `k^n`.

## The block-kernel functional `blockHomSum`

For the block-diagonal kernel `W(i,j) = if i = j then t else 0`,

> `∑_{φ : V → Fin k} ∏_{(a,b): G.Adj a b} W(φ a, φ b) = t^{D} · k^{c}`,

where `D = #directed edges` (ordered adjacent pairs `= 2·|E|`) and `c = #components`.

Worked example, `K₂`, `k` blocks:
- ordered adjacent pairs: `(v₀,v₁),(v₁,v₀)`, so `D = 2`.
- `homProd φ = (if φ v₀ = φ v₁ then t else 0)^2`.
- exactly the `k` constant colourings contribute `t²`; the other `k² − k` give `0`.
- total `= k · t² = t² · k¹`, and indeed `D = 2`, `c = 1`. ✓

Worked example, `M₂ = K₂ ⊔ K₂`, `k` blocks:
- `D = 4`, `c = 2`; colourings constant on both edges: `k²`, each contributing `t⁴`.
- total `= k² · t⁴ = t⁴ · k²`. ✓

## Interpretation

The exponent of `k` in the analytic functional is exactly the number of connected
components `c` of the graph. This is the finite mechanism behind the block-graphon
`Lᵖ` value `k^{c − n + m·p} ρ^{m·p}` in the KNRS/Sidorenko threshold discussion:
normalising by `k^n` (uniform measure) and taking the diagonal value `t = (ρk)^p`
turns `t^{D}·k^{c}` into `k^{c−n} (ρk)^{p·2m}`-type expressions, so the reachable
`Lᵖ` exponent is governed by the graph invariant `c`.

No counterexamples were found; the identities are exact and are the ones proved
formally.
