# Computational Evidence

Small-case sanity checks supporting the formalized statements. These were used to fix
the formalizations before proving them (notably to discover the `r ≥ 1` hypothesis that
Kruskal–Katona shadow bounds require).

## 1. Turán / Mantel density bound (`TuranDensityForm`)

Integer form proved: `2·r·#edges ≤ (r-1)·n²` for `K_{r+1}`-free graphs.

| forbidden clique | r | n | bound on #edges | extremal graph | actual #edges |
|---|---|---|---|---|---|
| `K_3` (Mantel)   | 2 | 4 | `n²/4 = 4`        | `K_{2,2}`             | 4 |
| `K_3` (Mantel)   | 2 | 5 | `⌊n²/4⌋ = 6`      | `K_{2,3}`             | 6 |
| `K_4`            | 3 | 6 | `(1-1/3)·36/2 = 12`| `K_{2,2,2}` (Turán)  | 3·(2·2) = 12 |

Note the `K_4`, `n=6` row: the balanced tripartite graph `K_{2,2,2}` is `K_4`-free and
has `12` edges, exactly matching the mission-form bound `(1-1/(r-1))·n²/2` with `r=4`
(`(1-1/3)·36/2 = 12`) — consistent with sharpness (Future Direction 1). Here the
Mathlib parameterization uses `r = 3` (no `K_{r+1} = K_4`), giving the same number.

The general real form `(#edges:ℝ) ≤ (1 - 1/(r-1))·n²/2` was checked to reduce, for
`r = 3` (triangle-free), to Mantel's `n²/4`.

## 2. Kruskal–Katona shadow bound (`KruskalKatonaShadow`)

Lovász form (`i = 1`): `C(k,r) ≤ #𝒜  ⟹  C(k,r-1) ≤ #∂𝒜` (for `r ≥ 1`).

Counterexample hunt that fixed the statement: with `r = 0`, the family `𝒜 = {∅}` of
size `C(k,0) = 1` has shadow `∂{∅} = ∅` of size `0`, while `C(k, r-1) = C(k,0) = 1`.
So `1 ≤ 0` is false — the bound **fails for `r = 0`**. This forced the explicit
hypothesis `1 ≤ r` in `shadow_card_lower`, `shadow_nonempty_of_large`, and
`small_shadow_imp_small_family`. (The subagent's disproof confirmed exactly this
`n=3, r=0, k=1, 𝒜={∅}` witness.)

Positive small case: `n = 4, k = 4, r = 2`. The full family of all `C(4,2)=6` pairs has
shadow = all `C(4,1)=4` singletons, and indeed `C(4,1)=4 ≤ 4`. Tight.

## 3. Roth density (`RothDensity`)

`rothNumberNat N` (max size of a 3-AP-free subset of `{0,…,N-1}`), first terms (OEIS
A065825 for the related corner/Roth quantities; the `rothNumberNat` values are):
`rothNumberNat 1..9 = 1,2,2,3,4,4,4,4,5`. The ratio `rothNumberNat N / N` is
`1, 1, .67, .75, .80, .67, .57, .50, .56, …`, decreasing in trend, consistent with
`rothDensity_tendsto_zero` (the limit is `0`, though convergence is extremely slow —
Behrend's construction keeps the density above `exp(-c√(log N))`).

The uniform ε-N form `threeAPFree_card_eventually_le` was checked qualitatively: since
`#s ≤ rothNumberNat n` for every 3-AP-free `s ⊆ range n`, one threshold `N(ε)` from the
little-o statement bounds *all* such subsets simultaneously — the quantifier order that
makes the statement non-trivial.

## Scope note

These results are faithful reformulations and applications of theorems already in
Mathlib (Turán, Kruskal–Katona, Szemerédi regularity → triangle removal → Roth). The
computational stage was kept brief and was used primarily as a counterexample filter
(it caught the `r = 0` corner above); the substantive content is in the Lean proofs.
