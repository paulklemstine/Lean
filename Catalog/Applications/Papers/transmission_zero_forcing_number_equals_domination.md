# Computational Evidence — Domination vs. (Transmission) Zero Forcing on Trees

This note records the computational exploration that preceded the formal Lean proofs in
`Catalog/Novelty/TransmissionDominationTree.lean`.

## 1. Domination number of the path `P_n`

We enumerated all subsets of vertices `{0,…,n-1}` and recorded the minimum size of a
dominating set (`γ`). The values match `⌈n/3⌉ = (n+2)/3`, which is now a **proved theorem**
(`gammaPath_eq` / `dominationNumber_pathGraph_eq`).

| n | γ(P_n) (brute force) | ⌈n/3⌉ |
|---|----------------------|-------|
| 1 | 1 | 1 |
| 2 | 1 | 1 |
| 3 | 1 | 1 |
| 4 | 2 | 2 |
| 5 | 2 | 2 |
| 6 | 2 | 2 |
| 7 | 3 | 3 |
| 8 | 3 | 3 |
| 9 | 3 | 3 |

Sequence `1,1,1,2,2,2,3,3,3,…` = OEIS **A002264 shifted** / `floor((n+2)/3)` (the
"⌈n/3⌉" staircase). This is the textbook value `γ(P_n) = ⌈n/3⌉`.

## 2. Ordinary zero forcing number of `P_n` — the separation

Running the standard zero-forcing color-change rule (a filled vertex with a unique unfilled
neighbour forces it) shows that a **single endpoint** forces the entire path:

| n | Z(P_n) | γ(P_n) |
|---|--------|--------|
| 1 | 1 | 1 |
| 2 | 1 | 1 |
| 3 | 1 | 1 |
| 4 | 1 | 2 |
| 5 | 1 | 2 |
| 6 | 1 | 2 |
| 7 | 1 | 3 |

So `Z(P_n) = 1` for all `n`, while `γ(P_n) = ⌈n/3⌉ → ∞`. **Ordinary zero forcing is NOT
equal to domination on trees.** Hence the mission's `ξ_T = γ` conjecture can only hold for a
*transmission-weighted* variant of zero forcing, where the cost of a forcing set is measured
by accumulated transmission (sum of distances) rather than by cardinality, or where the
color-change rule is throttled by a distance/transmission budget. This separation is the key
experimental driver for the conjectures in `FUTURE_DIRECTIONS.md`.

## 3. Counterexample hunt for `γ(P_n) = ⌈n/3⌉`

None found for `n ≤ 9` by exhaustive search; the closed form is now proved for all `n`, so
no counterexample exists.

## 4. Methodology note

The decisive, machine-checked facts are the `γ` values, which follow from the proved closed
form in the Lean file. The `Z(P_n)` column is reported as enumeration evidence only (it is
not formalized in this cycle) and is used solely to motivate the transmission weighting.
