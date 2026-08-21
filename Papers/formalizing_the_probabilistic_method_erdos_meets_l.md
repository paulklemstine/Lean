# Computational Evidence

All numbers below were produced by `#eval` inside the project's Lean 4 / Mathlib environment
(exact integer and rational arithmetic — no floating point except for the final display column of
the last table). Every claim that is *used* in a proof has a machine-checked counterpart in the
`.lean` files; this document is the exploratory record that preceded them.

## 1. The counting hypothesis behind Erdős' Ramsey lower bound

For each `k`, `n` is the largest natural number with `n² ≤ 2^k` (i.e. `n = ⌊2^{k/2}⌋`), and the
counting hypothesis needed by `ErdosProbabilisticRamsey.exists_good_colouring` is
`2·binom(n,k) < 2^{binom(k,2)}`.

| k  | n  | 2·C(n,k)     | 2^C(k,2)            | holds? |
|----|----|--------------|---------------------|--------|
| 3  | 2  | 0            | 8                   | true   |
| 4  | 4  | 2            | 64                  | true   |
| 5  | 5  | 2            | 1024                | true   |
| 6  | 8  | 56           | 32768               | true   |
| 7  | 11 | 660          | 2097152             | true   |
| 8  | 16 | 25740        | 268435456           | true   |
| 9  | 22 | 994840       | 68719476736         | true   |
| 10 | 32 | 129024480    | 35184372088832      | true   |
| 11 | 45 | 20301191820  | 36028797018963968   | true   |

No counterexample was found for `3 ≤ k ≤ 11`. Note `k = 2` fails (`n = 2`, `2·C(2,2) = 2 = 2^1`),
which is why the theorem carries the hypothesis `3 ≤ k`; this is not an artefact — `R(2,2) = 2`,
so `R(2,2) > 2^{2/2} = 2` is genuinely false.

Two rows of the table (`k = 3` and `k = 8`) are re-verified by the Lean kernel with `decide`
in the "Lab notes" section of `Catalog/Bridges/ErdosProbabilisticRamsey.lean`.

## 2. The arithmetic engine `2^{k+2} < (k!)²`

This is the `ℕ`-form of `2·2^{k/2} < k!`, proved by induction in `two_pow_lt_factorial_sq`.

| k | 2^(k+2) | (k!)²      | holds? |
|---|---------|------------|--------|
| 3 | 32      | 36         | true   |
| 4 | 64      | 576        | true   |
| 5 | 128     | 14400      | true   |
| 6 | 256     | 518400     | true   |
| 7 | 512     | 25401600   | true   |
| 8 | 1024    | 1625702400 | true   |

The margin at `k = 3` is thin (32 vs 36), which is exactly the boundary case that forced the
hypothesis `3 ≤ k`.

## 3. Erdős–Szekeres upper bound versus `4^{k-1}` and versus the truth

| k | C(2(k−1), k−1) | 4^(k−1) | true R(k,k)  |
|---|----------------|---------|--------------|
| 3 | 6              | 16      | 6            |
| 4 | 20             | 64      | 18           |
| 5 | 70             | 256     | 43 ≤ R ≤ 48  |
| 6 | 252            | 1024    | 102 ≤ R ≤ 160|
| 7 | 924            | 4096    | unknown      |
| 8 | 3432           | 16384   | unknown      |

The formalized sandwich `2^{k/2} < R(k,k) ≤ 4^{k-1}` is therefore *tight at k = 3* on the upper
side (6 = R(3,3)), and the gap widens exponentially, as expected. (The "true R(k,k)" column is
standard published knowledge, quoted for orientation only; it is not used in any proof.)

## 4. Turán graph edge counts (divisible case)

`#edges(turanGraph n r) = n·(n − n/r)/2`, which should equal `(1 − 1/r)·n²/2`:

| n  | r | n(n−n/r)/2 | (1−1/r)n²/2 |
|----|---|------------|-------------|
| 4  | 2 | 4          | 4           |
| 6  | 3 | 12         | 12          |
| 9  | 3 | 27         | 27          |
| 12 | 4 | 54         | 54          |

Agreement in all sampled cases; the general identity is proved in
`TuranExplicitCount.card_edgeFinset_turanGraph_real`.

## 5. The Euler constant in the symmetric LLL

`(1 + 1/d)^d` (exact rationals) must stay below `e = 2.718281828…`:

| d | (1+1/d)^d (exact)     | decimal   |
|---|-----------------------|-----------|
| 1 | 2                     | 2.000000  |
| 2 | 9/4                   | 2.250000  |
| 3 | 64/27                 | 2.370370  |
| 4 | 625/256               | 2.441406  |
| 5 | 7776/3125             | 2.488320  |
| 6 | 117649/46656          | 2.521626  |
| 7 | 2097152/823543        | 2.546500  |
| 8 | 43046721/16777216     | 2.565785  |

Monotone increasing and bounded by `e`, consistent with `one_add_inv_pow_le_exp_one`.

## 6. Counterexample hunt

* `d = 0` in the symmetric LLL: the natural choice `x = 1/(d+1) = 1` is **not** admissible
  (`x < 1` fails). This was found while formalizing and is the reason the proof uses
  `D = max d 1`; the theorem statement itself is unaffected.
* `k = 2` in the Ramsey lower bound: genuine counterexample to the unrestricted statement
  (see §1), hence the hypothesis `3 ≤ k`.
* `k = 1`, one singleton edge in property B: every colouring is monochromatic on it, so the
  strict inequality `#H < 2^{k-1}` cannot be relaxed to `≤`. This is recorded as the theorem
  `PropertyBUnionBound.property_B_sharp_example`.
* Turán with `r ∤ n`: `n = 5, r = 2` gives `n(n − n/r)/2 = 5·3/2 = 7` (integer division) while
  `(1 − 1/2)·25/2 = 6.25`; the real-valued identity therefore genuinely needs `r ∣ n`, and the
  divisibility hypothesis in `card_edgeFinset_turanGraph_real` is not removable.

## 7. OEIS

The central binomial coefficients appearing in the Erdős–Szekeres bound,
`1, 2, 6, 20, 70, 252, 924, 3432, …`, are OEIS A000984. No new sequence arose in this work.

## 8. Cycle 4 evidence — Caro–Wei, greedy independence, and Turán off the divisible case

All numbers below were produced by `#eval` on the Turán graphs `turanGraph n r`
(`ℚ`-valued arithmetic, exact).

### 8.1 Caro–Wei sum versus the true independence number

`cw(n,r) = ∑_v 1/(deg v + 1)`, `α` computed by brute force over all vertex subsets.

| (n, r) | Δ | Caro–Wei sum | n/(Δ+1) | α |
|--------|---|--------------|---------|---|
| (4, 2) | 2 | 4/3          | 4/3     | 2 |
| (5, 2) | 3 | 3/2          | 5/4     | 3 |
| (6, 2) | 3 | 3/2          | 3/2     | 3 |
| (6, 3) | 4 | 6/5          | 6/5     | 2 |
| (8, 4) | 6 | 8/7          | 8/7     | 2 |

Observations: (i) the inequality `∑ 1/(deg+1) ≤ α` holds in every case, as
`GreedyIndependentSet.caro_wei` now proves; (ii) on regular graphs the Caro–Wei sum coincides with
`n/(Δ+1)`, while on the irregular case `(5,2)` it is strictly larger (`3/2 > 5/4`), confirming that
Caro–Wei is the sharper of the two statements; (iii) the gap to the true `α` can be a factor of
almost 2 (case `(5,2)`: `3/2` versus `3`), which is exactly the slack Direction 6 targets.

### 8.2 Turán bound with no divisibility hypothesis

`#edges(turanGraph n r)` versus `(1 − 1/r)·n²/2`:

| (n, r) | #edges | bound   | equality? |
|--------|--------|---------|-----------|
| (4, 2) | 4      | 4       | yes       |
| (5, 2) | 6      | 25/4    | no        |
| (6, 2) | 9      | 9       | yes       |
| (7, 2) | 12     | 49/4    | no        |
| (6, 3) | 12     | 12      | yes       |
| (7, 3) | 16     | 49/3    | no        |
| (8, 3) | 21     | 64/3    | no        |
| (8, 4) | 24     | 24      | yes       |
| (9, 4) | 30     | 243/8   | no        |

No counterexample to `#edges ≤ (1 − 1/r)n²/2` was found, and equality occurs exactly at `r ∣ n`,
which is the pattern the (still open) floor characterisation of Direction 2 predicts. The
equality case `(4, 2)` is the one turned into the machine-checked sharpness theorem
`GreedyIndependentSet.turan_bound_sharp_four_two`.

---

## 9. Cycle 3 evidence: the floor formula for Turán numbers, and the deletion method

### 9.1 Where the floor formula for `ex(n, K_{r+1})` fails

The exact identity now proved (`TuranSharpNonDivisible.turan_edge_identity`) is

`2·r·#edges(turanGraph n r) + s·(r − s) = (r − 1)·n²`,  where `s = n mod r`,

so the Turán number equals `⌊(r − 1)n²/(2r)⌋` exactly when the *defect* `s·(r − s)` is smaller
than `2r` (`card_edgeFinset_eq_floor_iff`). Since `max_s s(r − s) = ⌊r²/4⌋`, the first modulus
where the defect can reach `2r` is `r = 8`, at `s = 4`:

| r | max defect `⌊r²/4⌋` | `2r` | floor formula always exact? |
|---|---------------------|------|-----------------------------|
| 2 | 1                   | 4    | yes                         |
| 3 | 2                   | 6    | yes                         |
| 4 | 4                   | 8    | yes                         |
| 5 | 6                   | 10   | yes                         |
| 6 | 9                   | 12   | yes                         |
| 7 | 12                  | 14   | yes                         |
| 8 | 16                  | 16   | **no** (fails at `n ≡ 4 mod 8`) |

Defect `s(8 − s)` for `n = 1 … 16`, `r = 8` (evaluated in Lean): `7, 12, 15, 16, 15, 12, 7, 0,
7, 12, 15, 16, 15, 12, 7, 0` — the value `16 = 2r` occurring exactly at `n ≡ 4 (mod 8)`.

The smallest instance is `n = 12`, `r = 8`: the true extremal number is `62`, while
`⌊7·144/16⌋ = 63`. This is the machine-checked theorem
`TuranSharpNonDivisible.turan_floor_overshoots_twelve_eight`, and it **refutes** the guess
recorded in the previous cycle that the floor formula is exact precisely when `n mod r ∈ {0,1}`
(for `r < 8` it is exact for *every* residue, `turan_floor_correct_of_lt_eight`).

### 9.2 Deletion method versus union bound for `R(k,k)`

For each `k`, `unionMax k` is the largest `n` with `2·C(n,k) < 2^{C(k,2)}` (the hypothesis of the
union-bound theorem `ErdosProbabilisticRamsey.exists_cliqueFree_and_compl_cliqueFree`), and
`delBest k = max_n (n − ⌊2·C(n,k)/2^{C(k,2)}⌋)` is the best lower bound obtainable from the
deletion theorem `RamseyDeletion.ramsey_deletion`. Evaluated in Lean:

| k  | union bound `R(k,k) >` | deletion bound `R(k,k) >` | optimal `n` |
|----|------------------------|---------------------------|-------------|
| 3  | 3                      | 3                         | 3           |
| 4  | 6                      | 6                         | 6           |
| 5  | 11                     | 11                        | 11          |
| 6  | 17                     | **18**                    | 19          |
| 7  | 27                     | **29**                    | 30          |
| 8  | 42                     | **47**                    | 51          |
| 9  | 65                     | **74**                    | 79          |
| 10 | 100                    | **116**                   | 126         |

So the first strict gain appears at `k = 6`, and it is exactly that instance which was turned
into the theorem `RamseyDeletion.ramsey_six_gt_eighteen` (`R(6,6) > 18`), together with
`RamseyDeletion.union_bound_fails_at_eighteen` certifying that the union bound cannot reach `18`.
The table entries other than `k = 6` come from evaluation only; they are not theorems.

## 10. Cycle 4 — max-cut: the exhaustive search versus the averaging bound

The search `MaxCutDerandomized.maxCut G = sup_{S ⊆ V} cut G S` is computable, so the bound
`#edges ≤ 2·maxCut G` can be inspected on small graphs. All numbers below were obtained by
evaluating the Lean definitions.

### 10.1 Complete graphs

| n | `m = #edges` | `maxCut Kₙ` | `2·maxCut` | `#edges (turanGraph n 2)` |
|---|--------------|-------------|------------|---------------------------|
| 2 | 1            | 1           | 2          | 1                         |
| 3 | 3            | 2           | 4          | 2                         |
| 4 | 6            | 4           | 8          | 4                         |
| 5 | 10           | 6           | 12         | 6                         |
| 6 | 15           | 9           | 18         | 9                         |

The third and fifth columns agree in every row; this is the theorem
`MaxCutDerandomized.maxCut_top_eq_card_edgeFinset_turanGraph`, proved for all `n`, and the third
column matches the closed form `(n/2)·(n − n/2)` of `MaxCutDerandomized.maxCut_top`. The
averaging bound `m ≤ 2·maxCut` is tight only at `n = 2, 3`: for `K₃` the largest cut misses one
of the three edges, which is the extremal case of the `1/2`-approximation.

### 10.2 Cycles (where the Edwards gain is visible)

| n | `m` | `maxCut Cₙ` | `m/2` | gain over the average |
|---|-----|-------------|-------|-----------------------|
| 3 | 3   | 2           | 1.5   | 0.5                   |
| 4 | 4   | 4           | 2     | 2                     |
| 5 | 5   | 4           | 2.5   | 1.5                   |
| 6 | 6   | 6           | 3     | 3                     |
| 7 | 7   | 6           | 3.5   | 2.5                   |

Even cycles are bipartite (`maxCut = m`); odd cycles lose exactly one edge (`maxCut = m − 1`).
In every row the gain over `m/2` is at least `(n − 1)/4`, the Edwards bound conjectured as
Direction 6 in `FUTURE_DIRECTIONS.md`; these rows are evaluations, not theorems (the theorems
proved this cycle are `maxCut_ge_half_edges`, `maxCut_top`, and their local-search counterparts).
