# Computational evidence

This note records the numerical exploration that guided the formalization in
`Geometry/MagnitudeTopeGraphs.lean`.

> **Status of the numbers below.** The tables in §1 come from an *ad hoc* exploratory
> script (dense/sparse Gaussian elimination modulo a large prime over the magnitude chain
> complex of a hypercube graph). They are **not** machine-checked and are reported here
> only as evidence that motivated the formal statements. Everything that is claimed as
> proven in the summary of this project is the content of the Lean file, which builds
> without `sorry`.

## 0. Setting

For a graph `G` with path metric `d`, the magnitude chain group `MC_{k,ℓ}(G)` is free on
the tuples `(x₀,…,x_k)` with `x_{i-1} ≠ x_i` and `Σ d(x_{i-1},x_i) = ℓ`; the differential
deletes an interior vertex whenever this preserves the total length.  Magnitude homology
`MH_{k,ℓ}(G)` is the homology of this complex.

The tope graph of the arrangement of the `n` coordinate hyperplanes in `ℝⁿ` is the
`n`-cube graph `Q_n` (topes = orthants = sign vectors; adjacency = exactly one separating
hyperplane).  This is also the Cayley graph of the Coxeter group `(ℤ/2)ⁿ`.

## 1. Small-case computation of `MH_{k,ℓ}(Q_n)`

Ranks `rk MH_{k,ℓ}` for `ℓ = 0,1,2,3,4`:

| n | k=0 | k=1 | k=2 | k=3 |
|---|-----|-----|-----|-----|
| 1 | `2,0,0,0,0` | `0,2,0,0,0` | `0,0,2,0,0` | `0,0,0,2,0` |
| 2 | `4,0,0,0,0` | `0,8,0,0,0` | `0,0,12,0,0` | `0,0,0,16,0` |
| 3 | `8,0,0,0,0` | `0,24,0,0,0` | `0,0,48,0,0` | `0,0,0,80,0` |

Two clear patterns, both matching the paper's main theorem:

* **Diagonality.** `MH_{k,ℓ} = 0` whenever `ℓ ≠ k`.
* **Diagonal ranks.** `rk MH_{k,k}(Q_n) = 2ⁿ · C(k+n-1, n-1)`.

Check: `n=3, k=3` gives `8 · C(5,2) = 8·10 = 80` ✓; `n=2, k=2` gives `4 · C(3,1) = 12` ✓.

`C(k+n-1,n-1)` is exactly the Hilbert function of the polynomial ring in `n` variables,
i.e. of the Stanley–Reisner ring of the full `(n-1)`-simplex.  For the Boolean
arrangement the simplicial complex attached to each tope is the full simplex on the `n`
hyperplanes (every hyperplane can be crossed from every tope), so the observed ranks are
`Σ_{topes} Hilb(k)` — the shape of the theorem in the paper.

## 2. Consistency with the formalized statements

The Lean file proves the following, which the table above confirms:

| Lean statement | numeric content | table check |
|---|---|---|
| `card_tope_edges` | `rk MH_{1,1} = 2ⁿ·n` | `n=3`: `24` ✓ |
| `card_tope_gen1` | `rk MC_{1,ℓ} = 2ⁿ·C(n,ℓ)` | `n=3, ℓ=2`: `8·3 = 24` ordered pairs at distance 2 |
| `card_tope_gen2` | `rk MC_{2,2} = 2ⁿ·n²` | `n=3`: `8·9 = 72` |
| `tope_cycles22_split` | `MH_{2,2} ⊕ ℤ^{2ⁿ·C(n,2)} ≅ ℤ^{2ⁿ·n²}` | `n=3`: `72 − 24 = 48` ✓ (table: `48`) |
| `topeMH1_vanishing` | `MH_{1,ℓ} = 0` for `ℓ ≥ 2` | row `k=1` ✓ |

The predicted diagonal rank in bidegree `(2,2)` is
`2ⁿ·n² − 2ⁿ·C(n,2) = 2ⁿ·n(n+1)/2`, which equals `2ⁿ·C(2+n-1, n-1)` as it must.

## 3. OEIS

For fixed `n`, the diagonal ranks `rk MH_{k,k}(Q_n) = 2ⁿ·C(k+n-1,n-1)` are `2ⁿ` times the
`(n-1)`-dimensional simplex/binomial sequence; for `n = 2` this is `4,8,12,16,…`
(multiples of 4), for `n = 3` it is `8,24,48,80,…` = `8·(1,3,6,10,…)`, i.e. `8` times the
triangular numbers (A000217). No new sequence appears.

## 4. Counterexample hunt

Two universal claims were tested exhaustively on the sample `n ∈ {1,2,3}`,
`k ≤ 3`, `ℓ ≤ 4`:

* `MH_{k,ℓ}(Q_n) = 0` for `ℓ ≠ k` — no counterexample found (and the case `k = 1` is
  proved in Lean for *every* connected graph).
* `rk MH_{k,k}(Q_n) = 2ⁿ·C(k+n-1,n-1)` — no counterexample found.

In addition, the degree-1 vanishing statement `MH_{1,ℓ} = 0` for `ℓ ≥ 2` was checked
against several non-tope graphs, with `rk MH_{1,ℓ}` for `ℓ = 0,…,4`:

| graph | `MH_{1,•}` | `2·#edges` |
|---|---|---|
| `C₅` | `0,10,0,0,0` | 10 |
| `C₆` | `0,12,0,0,0` | 12 |
| `K₄` | `0,12,0,0,0` | 12 |
| `P₄` | `0,6,0,0,0` | 6 |
| `K_{3,3}` | `0,18,0,0,0` | 18 |

This is consistent with the proof given in Lean: it only uses that a geodesic of length
`≥ 2` has an interior vertex, so it is valid for every connected graph.

## Addendum (second session): status of the `k = 2` numbers

The row `rk MH_{2,2}(Q_n) = 2ⁿ · C(n+1,2)` of the tables above is no longer merely
exploratory: it is now proved in Lean, as
`MagnitudeTope.topeMH22_finrank` / `MagnitudeTope.topeMH22_free` in
`Geometry/MagnitudeTopeGraphsDiagonal.lean` (and `MagnitudeTope.cayleyMH22_finrank` for
the Cayley graph of `(ℤ/2)ⁿ`).  Concretely this gives ranks `0, 2, 12, 48` for
`n = 0, 1, 2, 3`, matching the exploratory computations recorded above.  All remaining
entries of the tables (`k ≥ 3`, and `MH_{k,ℓ}` off the diagonal for `k ≥ 2`) are still
exploratory and are not backed by a machine-checked statement.

## Addendum (third session): the degree-2 chain and cycle counts in all lengths

The counts of the degree-2 magnitude chain groups and of the `(2,ℓ)`-cycle groups of the
tope graph are now proved in Lean for *every* length `ℓ`, in
`Geometry/MagnitudeTopeGraphsHilbert.lean`:

* `#MC_{2,ℓ}(Q_n) = 2ⁿ · (C(2n,ℓ) − 2·C(n,ℓ))` for `ℓ ≥ 1`
  (`MagnitudeTope.card_tope_gen2_general`),
* `rk Z_{2,ℓ}(Q_n) = 2ⁿ · (C(2n,ℓ) − 3·C(n,ℓ))` for `ℓ ≥ 2`
  (`MagnitudeTope.finrank_tope_cycles_general`), the cycles being free abelian
  (`MagnitudeTope.tope_cycles_free_general`).

For example, for `n = 2` these give `#MC_{2,2} = 16`, `#MC_{2,3} = 16`, `#MC_{2,4} = 4`
and cycle ranks `12`, `16`, `4` in lengths `2, 3, 4`.  Note that the cycle group `Z_{2,ℓ}`
is the homology `MH_{2,ℓ}` only for `ℓ = 2` (where there are no `(3,2)`-chains); for
`ℓ ≥ 3` these ranks are upper bounds for `rk MH_{2,ℓ}`, and the diagonality entries of the
tables above remain exploratory.
