# Computational evidence

All computations below are exhaustive brute-force searches over subsets of `2^[n]` for
small `n`; they were used to sanity-check the statements before formalizing them.
The formal, machine-checked content is in
`Catalog/Combinatorics/B3FreeAntichainMonotone.lean` (no `sorry`, no `native_decide`).

## 1. Small values of `La(n, B_d)` and `La*(n, B_d)`

Exhaustive search over all `2^(2^n)` families of subsets of `[n]`, testing for weak
(resp. strong) copies of `B_d` by enumerating all injections `B_d → 2^[n]`.

| n | d | La(n, B_d) | La*(n, B_d) |
|---|---|-----------|-------------|
| 1 | 1 | 1 | 1 |
| 1 | 2 | 2 | 2 |
| 1 | 3 | 2 | 2 |
| 2 | 1 | 2 | 2 |
| 2 | 2 | 3 | 3 |
| 2 | 3 | 4 | 4 |
| 3 | 1 | 3 | 3 |
| 3 | 2 | 6 | 6 |
| 3 | 3 | 7 | 7 |

These agree with the already-formalized values `La(d, B_d) = 2^d − 1`,
`La(d+1, B_d) = 2^(d+1) − 2` and `La(n, B_1) = C(n, ⌊n/2⌋)`.

*Strict monotonicity in `d` (conjecture D3).*  In every row with `d ≤ n` the value
strictly increases when `d` is replaced by `d + 1` (`1 < 2` at `n = 1`; `2 < 3 < 4` at
`n = 2`; `3 < 6 < 7` at `n = 3`), while for `d > n` it is constant (`n = 1`:
`La = 2` for `d = 2, 3`).  This is exactly the dichotomy proved in
`La_boolLat_lt_succ_iff`.

*Weak vs. strong (conjecture D4).*  In this range `La = La*` throughout, consistent with
the known equalities for `n ∈ {d, d+1}`; no separation appears for `n ≤ 3`.

## 2. The quantitative bound `2^n + n·La(n, B_d) ≤ (n+1)·La(n, B_(d+1))`

Checked against the table above:

| n | d | LHS | RHS |
|---|---|-----|-----|
| 1 | 1 | 2 + 1·1 = 3 | 2·2 = 4 |
| 2 | 1 | 4 + 2·2 = 8 | 3·3 = 9 |
| 2 | 2 | 4 + 2·3 = 10 | 3·4 = 12 |
| 3 | 1 | 8 + 3·3 = 17 | 4·6 = 24 |
| 3 | 2 | 8 + 3·6 = 26 | 4·7 = 28 |

and, using the formalized values at `n = 4`, `La(4, B_3) = 14`, `La(4, B_4) = 15`:
`16 + 4·14 = 72 ≤ 5·15 = 75`.  The inequality is fairly tight, and is
`La_succ_pigeonhole`.

## 3. Counterexample hunt for the union theorem

Claim tested: *if `F` is weak `B_d`-free and `L` is an antichain, then `F ∪ L` is weak
`B_(d+1)`-free* (and the strong analogue).

Exhaustive test on `n = 3` (all `256` families, all `20` antichains of `2^[3]`):

| d | pairs tested | violations |
|---|--------------|------------|
| 1 (weak)   | 400  | 0 |
| 2 (weak)   | 3220 | 0 |
| 1 (strong) | 400  | 0 |
| 2 (strong) | 3340 | 0 |

No counterexample; the claim is now the theorem `weakFree_union_antichain` /
`strongFree_union_antichain`.

## 4. A stronger claim that survived testing (source of conjecture F1)

Claim tested: *if `F` is weak `B_d`-free and `G` is weak `B_e`-free, then `F ∪ G` is weak
`B_(d+e)`-free.*

| n | (d, e) | pairs tested | violations |
|---|--------|--------------|------------|
| 3 | (1,1)  | 400          | 0 |
| 3 | (1,2)  | 3220         | 0 |
| 3 | (2,1)  | 3220         | 0 |
| 4 | (1,1)  | 168² = 28224 | 0 |

(The `n = 4`, `(1,1)` row ranges over all `168` antichains of `2^[4]`, the Dedekind
number `M(4)`.)  The case `e = 1` is proved in this cycle; the general case is recorded
as conjecture **F1** in `FUTURE_DIRECTIONS.md`.

## 5. Sharpness of the height sandwich

`weakFree_of_not_hasChain` (height `≤ d` ⟹ weak `B_d`-free) and
`not_hasChain_of_weakFree` (weak `B_d`-free ⟹ height `≤ 2^d − 1`) are both sharp, and
the gap between the two thresholds is genuine:

* `{∅, {1}, {2}, {1,2}} ⊆ 2^[2]` has height `3 = d + 1` for `d = 2` and *is* a weak copy
  of `B_2`; so height `d + 1` no longer forces freeness (formalized in general as
  `exists_not_weakFree_of_height_succ`).
* the chain `∅ ⊂ {1} ⊂ {1,2}` in `2^[3]` has height `3 = 2^2 − 1` and *is* weak
  `B_2`-free, since a weak copy of `B_2` needs `4` distinct sets (formalized in general as
  `exists_weakFree_hasChain`).

So for `d = 2` there are both free and non-free families of every height in `{3}`, and
neither implication can be reversed.
