# Computational Evidence — Chromatic Polynomials and Deletion–Contraction

All computations below were run on the actual `chromVal` definition (number of proper
`Fin q`-colorings of a finite simple graph) used in the formal development, evaluated by
finite enumeration over the function space `V → Fin q`.

## 1. Small-case calculations

### Complete graph K₃ (vertices `Fin 3`, all pairs adjacent)
`chromVal (⊤ : SimpleGraph (Fin 3)) q` for `q = 0..4`:

| q | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| value | 0 | 0 | 0 | 6 | 24 |

Closed form predicted by `chromVal_top`: `q^{\underline 3} = q(q-1)(q-2)`
→ `0, 0, 0, 6, 24`. **Match.**

### Edgeless graph Ē₃ (vertices `Fin 3`, no edges)
`chromVal (⊥ : SimpleGraph (Fin 3)) q` for `q = 0..4`:

| q | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| value | 0 | 1 | 8 | 27 | 64 |

Closed form predicted by `chromVal_bot`: `q^3` → `0, 1, 8, 27, 64`. **Match.**

### Path P₃ (vertices `Fin 3`, edges `0–1`, `1–2`)
`chromVal P₃ q` for `q = 0..4`:

| q | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| value | 0 | 0 | 2 | 12 | 36 |

Closed form (a tree on 3 vertices): `q(q-1)^2` → `0, 0, 2, 12, 36`. **Match.**

## 2. Deletion–contraction spot check

P₃ is exactly K₃ with the edge `{0,2}` deleted. The recurrence
`P(K₃ − e, q) = P(K₃, q) + P(K₃ / e, q)` predicts, for the contraction `K₃ / e`
(two vertices joined by an edge, i.e. K₂):

`P(K₂, q) = q(q-1)` → at `q = 3`: `6`.

Check at `q = 3`:  `P(P₃, 3) = 12`,  `P(K₃, 3) = 6`,  `P(K₂, 3) = 6`, and indeed
`12 = 6 + 6`. **Match** — consistent with the formal theorem `deletion_contraction`.

## 3. Sequence identification

The chromatic polynomial coefficients of K_n are the (signed) Stirling numbers of the
first kind; the falling-factorial values `q^{\underline n}` are catalogued in OEIS as the
triangle of falling factorials (e.g. A008279, "number of permutations of n things k at a
time"). The K₃ row `q(q-1)(q-2)` matches A008279's `n=q, k=3` entries.

## 4. Counterexample hunt

The universal claims actually formalized — `chromVal_bot`, `chromVal_top`,
`deletion_contraction`, `chromVal_pos_iff_colorable`, `complete_colorable_iff` — were tested
on the graphs above (edgeless, complete, path, and the contraction K₂) for `q = 0..4`.
No discrepancy was found; every predicted value agreed with direct enumeration. The formal
proofs then establish these identities for all finite `V` and all `q`.
