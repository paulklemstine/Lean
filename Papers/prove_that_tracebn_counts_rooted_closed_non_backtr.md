# Computational evidence: `trace(Bⁿ)` as a walk counter

All numbers below were produced by kernel-level evaluation inside Lean 4 (`#eval` on the
Hashimoto matrix defined in `Catalog/Algebra/NonBacktracking/HashimotoTrace.lean`), using
the same definitions that the formal proofs use. Every graph is a `SimpleGraph (Fin n)`
with decidable adjacency, and `B = Hashimoto.hashimoto G` is a `Matrix G.Dart G.Dart ℕ`.

## 1. Small-case tables of `trace(Bⁿ)`

| graph | #darts | n = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|---|
| `K₃` (triangle)   |  6 |  6 | 0 | 0 |  6 |   0 |   0 |   6 |    0 |    0 |
| `K₄`              | 12 | 12 | 0 | 0 | 24 |  24 |   0 |  96 |  168 |  168 |
| `K₅`              | 20 | 20 | 0 | 0 | 60 | 120 | 120 | 780 | 2520 | 6120 |
| `C₅` (pentagon)   | 10 | 10 | 0 | 0 |  0 |   0 |  10 |   0 |    0 |    0 |
| `C₆` (hexagon)    | 12 | 12 | 0 | 0 |  0 |   0 |   0 |  12 |    0 |    0 |
| Petersen          | 30 | 30 | 0 | 0 |  0 |   0 | 120 | 120 |    0 |    — |
| `P₃` (path, tree) |  4 |  4 | 0 | 0 |  0 |   0 |   0 |   0 |    0 |    0 |

Readings that guided the formalisation:

* `n = 0` always returns the number of darts `= ∑_v deg v` — formalised as
  `Hashimoto.trace_hashimoto_pow_zero`.
* `n = 1, 2` always return `0` — formalised as `Hashimoto.trace_hashimoto` and
  `Hashimoto.trace_hashimoto_sq`.
* `n = 3` returns `6 · #triangles` (`K₄`: `24 = 6·4`; `K₅`: `60 = 6·10`) — formalised as
  `Hashimoto.trace_hashimoto_cube` (as the number of *ordered* triangles).
* The first nonzero positive index equals the girth: `5` for `C₅` and for Petersen,
  `6` for `C₆`, never for the tree `P₃`. This motivated
  `Hashimoto.one_le_trace_of_isCycle` and `Hashimoto.isAcyclic_of_trace_eq_zero`.
* Petersen at `n = 5` gives `120 = 2 · 5 · 12`, i.e. twelve pentagons each rooted in
  `5` positions and `2` orientations; at `n = 6` it gives `120 = 2 · 6 · 10`, i.e. ten
  hexagons. This is the "rooted + oriented" bookkeeping that the cyclic form of the main
  theorem (`Hashimoto.trace_hashimoto_pow_eq_card_nbCycles`) makes precise.

## 2. Counterexample hunt: parity and growth

* **Parity.** Every entry in the table above is even. Tested on all the graphs listed and
  on all displayed lengths; no odd value was found. This suggested — and we then proved —
  `Hashimoto.even_trace_hashimoto_pow`: dart reversal is a fixed-point-free involution on
  rooted closed non-backtracking walks, so the count is even for *every* graph and every
  `n`.
* **Growth.** For the `(q+1)`-regular examples the counts stay below `#darts · qⁿ`
  (`K₄`, `q = 2`: `168 ≤ 12·2⁷ = 1536`; Petersen, `q = 2`: `120 ≤ 30·2⁵ = 960`;
  `C₅`, `q = 1`: `10 ≤ 10·1ⁿ`). No violation was found, and the bound is proved in
  `Hashimoto.trace_hashimoto_pow_le_of_regular`. Note `C₅` shows the bound is sharp.
* **Failed guess.** "`trace(B³ᵏ)` is periodic" is *false* in general: it holds for `K₃`
  (`B³ = 1`) and `C₅` (`B⁵ = 1`) because those Hashimoto matrices are permutation
  matrices, but `K₄` already grows (`24, 96, 168, …`). Periodicity is therefore stated
  only for the two examples where `B` is a permutation matrix, and proved from the
  identities `B³ = 1` and `B⁵ = 1` rather than conjectured in general.

## 3. Sequence identification

No OEIS lookup was performed (this run had no network access), so no OEIS identifier is
claimed here. The prefixes above (e.g. `12, 0, 0, 24, 24, 0, 96, 168, 168` for `K₄`) are
recorded so they can be checked against OEIS later.

## 4. Status of the numbers

The table is exploratory `#eval` output. The statements that were *verified in the Lean
kernel* (no `native_decide`) are the ones appearing as theorems in
`Catalog/Algebra/NonBacktracking/Examples.lean`:
`K₃`: `B³ = 1`, `#darts = 6`, and the full periodic count;
`K₄`: `24` walks of length `3` and `24` of length `4`;
`C₅`: `B⁵ = 1`, `#darts = 10`, and the full periodic count;
`P₃`: `B² = 0` and vanishing of all positive-length counts.

## 5. How the numbers turned into theorems (second pass)

The tables above were re-read after the first synthesis, and three further patterns were
isolated and then proved:

* **Zero exactly below the girth.** `C₅`, `C₆` and Petersen are zero at every positive
  index below their girth, and `P₃` (a tree) is zero at every positive index. Both are now
  theorems: `Hashimoto.trace_hashimoto_pow_eq_zero_of_lt_egirth` and
  `Hashimoto.trace_hashimoto_pow_eq_zero_of_isAcyclic`, the latter giving the exact
  criterion `G.IsAcyclic ↔ ∀ n ≥ 1, trace(Bⁿ) = 0` and the former giving
  `girth G = min {n ≥ 1 : trace(Bⁿ) ≠ 0}` (`Hashimoto.girth_eq_sInf_trace_ne_zero`).
* **Multiples of `2 · girth`.** `K₃` at `n = 3` gives `6 = 2·3`, `C₅` at `n = 5` gives
  `10 = 2·5`, `C₆` at `n = 6` gives `12 = 2·6`, Petersen at `n = 5` gives `120 = 2·5·12`.
  The lower bound `2·m ≤ trace(Bᵐ)` for every cycle of length `m` is now proved
  (`Hashimoto.two_mul_length_le_trace_of_isCycle`); the exact multiplicity
  `2 · girth · #{shortest cycles}` is recorded as an open direction.
* **Monotonicity.** Comparing the rows for `K₃ ⊆ K₄ ⊆ K₅` at each index shows the counts
  never decrease when edges are added; this is now
  `Hashimoto.trace_hashimoto_pow_mono`.

