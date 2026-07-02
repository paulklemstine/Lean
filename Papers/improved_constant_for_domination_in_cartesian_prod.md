# Computational Evidence — Domination in Cartesian products of graphs

Target statement (informal): for finite graphs `G`, `H`,
`γ(G □ H) ≥ ((19 − √73)/18) · γ(G) · γ(H)`, with `(19 − √73)/18 ≈ 0.5809`.

This note records the small-case checks that guided the formalization in
`GraphDominationBox.lean` and `DominationProductConstant.lean`.

## 1. The constant

`(19 − √73)/18`:

- `√73 = 8.544003...`
- `19 − √73 = 10.455996...`
- `/18 = 0.580888...`

So the constant lies strictly in `(1/2, 1)`: it beats the Clark–Suen constant
`1/2` and stays under the (conjectural Vizing) constant `1`.

Root check: `9x² − 19x + 8` at `x = 0.580888`:
`9·0.337431 − 19·0.580888 + 8 = 3.036878 − 11.036872 + 8 ≈ 0.000006 ≈ 0`.
The exact roots are `(19 ± √(19² − 4·9·8))/(2·9) = (19 ± √73)/18`, confirming
`(19 − √73)/18` is the smaller root of `9x² − 19x + 8 = 0`.

## 2. Small-case domination numbers and the bracket `max ≤ γ(G□H) ≤ γ(G)·|V(H)|`

| G      | H      | γ(G) | γ(H) | γ(G □ H) | max(γG,γH) | γ(G)·|V(H)| |
|--------|--------|------|------|----------|------------|-------------|
| K₂     | K₂     | 1    | 1    | 2 (=C₄)  | 1          | 2           |
| P₃     | K₂     | 1    | 1    | 2 (2×3 grid) | 1      | 2           |
| P₃     | P₃     | 1    | 1    | 3 (3×3 grid) | 1      | 3           |
| C₄     | K₂     | 2    | 1    | 2        | 2          | 4           |
| C₅     | C₅     | 2    | 2    | 5 (known)| 2          | 10          |

Every row satisfies both proven inequalities
`max(γG,γH) ≤ γ(G□H) ≤ γ(G)·|V(H)|`, and every row also satisfies the target
`γ(G□H) ≥ 0.5809·γ(G)·γ(H)` (e.g. C₅□C₅: `0.5809·4 = 2.32 ≤ 5`).

## 3. Regime covered by the elementary method

The projection bound gives `γ(G□H) ≥ max(γG,γH)`. Whenever `min(γG,γH) ≤ 1`
this already forces `γ(G□H) ≥ 0.5809·γG·γH`, because then
`0.5809·γG·γH ≤ 0.5809·max ≤ max ≤ γ(G□H)`. This is exactly the regime proved
unconditionally in `boxProd_vizing_bound_of_min_le_one`. Rows 1–4 above all fall
in this regime; row C₅□C₅ has `min = 2` and lies outside it (it holds, but not by
the elementary projection argument alone).

## 4. Counterexample hunt

No counterexample to the two proven inequalities was found among all products of
paths/cycles/complete graphs on ≤ 5 vertices (checked by hand / small enumeration).
The target constant inequality also held on every case; the difficulty is not its
truth but an unconditional proof for `min(γG,γH) ≥ 2`, which requires the full
discharging argument of Clark–Suen / Suen–Tarr and is left as future work.
