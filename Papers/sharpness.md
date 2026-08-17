# Computational Evidence — Sharpness of the finite moment problem on `{0, …, N}`

All formal statements referenced here live in
`Catalog/Probability/PowerSumSharpness.lean` and compile with `0` sorries.

Throughout, a *data set* is a finite multiset `s` of naturals with all elements `≤ N`, and
its power sums are `p_k(s) = ∑_{x ∈ s} x^k`.  Equivalently, a weight system
`w : ℕ → ℝ` supported in `{0, …, N}` has power sums `powerSum N w k = ∑_{i ≤ N} w i · i^k`.

**Status of each item below is stated explicitly.**  Items marked *(exploratory)* were
produced by `#eval` enumeration inside Lean and are *not* machine-verified proofs; items
marked *(verified)* are theorems in the Lean file.

---

## 1. The minimal example

`{0, 2}` and `{1, 1}` are both bounded by `2`:

| k | p_k({0,2}) | p_k({1,1}) |
|---|-----------|-----------|
| 0 | 2         | 2         |
| 1 | 2         | 2         |
| 2 | 4         | 2         |

They agree for `k ≤ 1 = N − 1` and split at `k = 2 = N`.
*(verified: `multiset_zero_two_ne_one_one`)*

## 2. The `N = 3` example

`{0,2,2,2}` versus `{1,1,1,3}`:

| k | p_k({0,2,2,2}) | p_k({1,1,1,3}) |
|---|----------------|----------------|
| 0 | 4              | 4              |
| 1 | 6              | 6              |
| 2 | 12             | 12             |
| 3 | 24             | 30             |

Agreement up to `k = 2 = N − 1`, split at `k = 3 = N`, gap `= 6 = 3!`, and each data set has
`4 = 2^{3-1}` elements.  *(verified: `multiset_N3_witness`)*

## 3. Where do these examples come from?

Both are the *even/odd split of the binomial weights*: the count vector of `{0,2}` is
`(1,0,1) = ` even part of `C(2,·)`, and of `{1,1}` is `(0,2,0) = ` odd part; likewise
`(1,0,3,0)` and `(0,3,0,1)` for `N = 3`.  Their difference is the alternating binomial vector
`i ↦ (−1)^i C(N,i)`, which annihilates every power `i^k` with `k < N`.
*(verified: `alternating_binom_pow_lt`, `halves_powerSum_agree`, `collision_card_bound_sharp`)*

## 4. The alternating binomial functional

`A_N(p) = ∑_{i=0}^{N} (−1)^i C(N,i) p(i)` evaluated on monomials, `N = 4`:

| p        | 1 | X | X² | X³ | X⁴ |
|----------|---|---|----|----|----|
| A_4(p)   | 0 | 0 | 0  | 0  | 24 |

and `24 = 4!`.  The general pattern `A_N(X^k) = 0` for `k < N`, `A_N(X^N) = (−1)^N N!` is the
Stirling-number identity `S(k, N) = 0` for `k < N`, `S(N,N) = 1`.
*(verified in the sharp form `alternating_binom_eval`:
`A_N(p) = (−1)^N N! · [X^N]p` for every `deg p ≤ N`)*

## 5. OEIS

The extremal data-set sizes `2^{N−1}` for `N = 1,2,3,4,…` are `1, 2, 4, 8, 16, …`
(**A000079**, shifted).  The gaps at the critical order, `N!/2^{N−1}` for `N = 1,2,3,4,5`, are
`1, 1, 3/2, 3, 15/2`, i.e. `N!/2^{N−1}`; numerators `1,1,3,3,15,45,315,…` (odd double
factorials `(N−1)!!`-like growth).  No further OEIS identification was attempted.

## 6. Counterexample hunt against rigidity

We looked for two distinct data sets bounded by `N` with equal power sums for *all* `k ≤ N`
(this would contradict `powerSum_determined`).  None exist — see the table in §8: the `K = N`
column is `0` everywhere in the searched range, as the theorem requires.

## 7. Structure of the collisions found

Every colliding pair found at `K = N − 1` has count-vector difference a *nonzero integer
multiple* of `(−1)^i C(N,i)`.  For `N = 2` that vector is `(1,−2,1)`; e.g.
`{0,0,2,2}` vs `{1,1,1,1}` has count difference `(2,−4,2) = 2·(1,−2,1)`.
*(verified in general: `diff_eq_alternating`; verified exhaustively for `N = 2` and data-set
sizes `2` and `3`: `exhaustive_search_N2_pairs`, `exhaustive_search_N2_triples`)*

## 8. Exhaustive search *(exploratory `#eval` enumeration)*

For each `N` and each data-set size `n`, we enumerated all `C(N+n, n)` multisets of size `n`
with entries in `{0, …, N}` and counted unordered pairs of **distinct** multisets whose power
sums agree for all `k ≤ K`.

| N | n | # pairs at `K = N` | # pairs at `K = N − 1` |
|---|---|--------------------|------------------------|
| 1 | 1 | 0 | 1 |
| 1 | 2 | 0 | 3 |
| 1 | 3 | 0 | 6 |
| 1 | 4 | 0 | 10 |
| 2 | 1 | 0 | 0 |
| 2 | 2 | 0 | 1 |
| 2 | 3 | 0 | 3 |
| 2 | 4 | 0 | 7 |
| 3 | 1 | 0 | 0 |
| 3 | 2 | 0 | 0 |
| 3 | 3 | 0 | 0 |
| 3 | 4 | 0 | 1 |
| 4 | 1–4 | 0 | 0 |
| 5 | 1–4 | 0 | 0 |

Two structural facts are visible and are now theorems:

* **`K = N` column is identically `0`** — this is rigidity, `powerSum_determined` /
  `multiset_determined_by_powerSums`.
* **The first nonzero entry in the `K = N − 1` column occurs at `n = 2^{N−1}`**
  (`n = 1, 2, 4` for `N = 1, 2, 3`, and nothing for `N = 4, 5` because `2^{N−1} = 8, 16` are
  outside the searched range).  This is exactly
  `multiset_collision_card_lower_bound` (lower bound, verified) together with
  `collision_card_bound_sharp` (attainment for every `N`, verified).

The unique minimal collisions found are `({0},{1})` for `N=1`, `({0,2},{1,1})` for `N=2`, and
`({0,2,2,2},{1,1,1,3})` for `N=3` — precisely the even/odd binomial halves.

## 9. Quantitative data on the critical gap

For probability distributions on `{0, …, N}` agreeing up to order `N − 1`, the largest
possible discrepancy at order `N` is `N!/2^{N−1}`:

| N | max gap `N!/2^{N−1}` | attained by |
|---|----------------------|-------------|
| 1 | 1                    | `δ₀` vs `δ₁` |
| 2 | 1                    | `(½,0,½)` vs `(0,1,0)` |
| 3 | 3/2                  | `(¼,0,¾,0)` vs `(0,¾,0,¼)` |
| 4 | 3                    | even/odd halves of `C(4,·)` |

*(verified: upper bound `powerSum_gap_le`, attainment `halves_gap_eq_extremal`)*

## 10. Widening the alphabet: minimal collision sizes off the critical window

Section 8 searched only the critical window `K = N − 1`.  Widening the alphabet while keeping
the agreement order fixed makes collisions *smaller*, which refuted the first draft of
conjecture C2 (`card ≥ 2^K`).  Minimal sizes `m(N, K)` found by direct search:

| K | N | minimal collision size `m(N,K)` | witness |
|---|---|--------------------------------|---------|
| 1 | 2 | 2 = 2^1                        | `{0,2}` vs `{1,1}` |
| 1 | ≥2| 2 = K + 1                      | `{0,2}` vs `{1,1}` |
| 2 | 3 | 4 = 2^2                        | `{0,2,2,2}` vs `{1,1,1,3}` |
| 2 | 4 | 3 = K + 1                      | `{0,3,3}` vs `{1,1,4}` |
| 3 | 4 | 8 = 2^3                        | even/odd halves of `C(4,·)` |
| 3 | 11| 4 = K + 1                      | `{0,4,7,11}` vs `{1,2,9,10}` |

Check of the degree-`3` row: `0+4+7+11 = 1+2+9+10 = 22`;
`0+16+49+121 = 1+4+81+100 = 186`; `0+64+343+1331 = 1+8+729+1000 = 1738`; and at order `4`,
`0+256+2401+14641 = 17298 ≠ 16578 = 1+16+6561+10000`.

The general lower bound `K < card s` (Prouhet–Tarry–Escott) is
`PowerSumNewton.collision_card_gt_degree`; the two rows attaining it are
`ideal_pte_degree_two` and `ideal_pte_degree_three`; the strict drop between `N = 3` and
`N = 4` at `K = 2` is `collision_min_card_drops_with_alphabet`.  *(all verified in Lean)*

## 11. The invariant `m(N, K)` and its drop profile at `K = 2`

Section 10 lists individual minimal collision sizes.  These are now packaged as a single
invariant `m(N,K) = minCollisionCard N K` in
`Catalog/Probability/PowerSumMinimalCollision.lean` (with the convention `m(N,K) = 0` when the
problem is rigid, i.e. when no collision exists), and the `K = 2` row is settled completely:

| N | `m(N, 2)` | reason |
|---|-----------|--------|
| 0,1,2 | 0 (no collision) | rigidity, `minCollisionCard_eq_zero_iff` |
| 3 | 4 = 2^2 | critical window, `minCollisionCard_critical` |
| ≥ 4 | 3 = K + 1 | PTE floor, attained by `{0,3,3}` vs `{1,1,4}` (`minCollisionCard_two`) |

*(all rows verified: `minCollisionCard_two_table`)*

More generally the following are verified in the same file: the critical value
`m(N, N−1) = 2^(N−1)` for every `N ≥ 1`, the floor `K < m(N,K)` whenever `K < N`, the
monotonicity `m(N', K) ≤ m(N, K)` for `N ≤ N'`, and the two further exact values
`m(N,1) = 2` for `N ≥ 2` and `m(N,3) = 4` for `N ≥ 11`.

## 12. Exhaustive kernel search for ideal collisions of degree `K ≤ 5`

A collision `s ≠ t` bounded by `N` at agreement order `K` is the same thing as a nonzero
integer vector `c : {0,…,N} → ℤ` in the kernel of the `(K+1) × (N+1)` Vandermonde matrix
`c ↦ (∑_i c_i i^k)_{k ≤ K}`, with `card s = ∑_i max(c_i, 0)` for the minimal choice (no common
part).  Enumerating all kernel vectors with `|c_i| ≤ 3` gives the following exact values of
`m(N, 3)` (the entry `N = 4` is the critical window, out of reach of the coefficient bound
used, and is `2^3 = 8` by `minCollisionCard_critical`):

| N | 4 | 5 | 6 | 7 | 8 | 9 | 10 | ≥ 11 |
|---|---|---|---|---|---|---|----|------|
| `m(N,3)` | 8 | 6 | 6 | 4 | 4 | 4 | 4 | 4 |

So the drop to the Prouhet–Tarry–Escott floor `K + 1 = 4` happens at `N = 7`, not at `N = 11`
as the classical *set* solution `{0,4,7,11}` vs `{1,2,9,10}` would suggest: allowing repeated
entries, `{1,1,6,6}` vs `{0,3,4,7}` is an ideal solution of diameter `7`
(`1+1+6+6 = 0+3+4+7 = 14`, `1+1+36+36 = 0+9+16+49 = 74`,
`1+1+216+216 = 0+27+64+343 = 434`, and at order `4`, `1+1+1296+1296 = 2594 ≠ 2498 =
0+81+256+2401`).  *(verified in Lean: `PowerSumIdealPTE.ideal_pte_three_narrow`,
`PowerSumIdealPTE.minCollisionCard_three_narrow`)*

Minimal diameters `d(K)` of an ideal solution (size exactly `K + 1`), obtained by exhaustive
enumeration of multisets:

| K | d(K) | ideal witness |
|---|------|---------------|
| 1 | 2  | `{0,2}` vs `{1,1}` |
| 2 | 4  | `{0,3,3}` vs `{1,1,4}` |
| 3 | 7  | `{1,1,6,6}` vs `{0,3,4,7}` |
| 4 | 18 | `{0,4,8,16,17}` vs `{1,2,10,14,18}` |
| 5 | 16 | `{0,3,5,11,13,16}` vs `{1,1,8,8,15,15}` |

Note `d(5) < d(4)`: the minimal alphabet is **not** monotone in the degree.  All five witnesses
are verified in Lean (`PowerSumSharpness.multiset_zero_two_ne_one_one`,
`PowerSumNewton.ideal_pte_degree_two`, `PowerSumIdealPTE.ideal_pte_three_narrow`,
`ideal_pte_four`, `ideal_pte_five`), giving the exact values `m(N,3) = 4` for `N ≥ 7`,
`m(N,4) = 5` for `N ≥ 18` and `m(N,5) = 6` for `N ≥ 16`; the minimality of the diameters
themselves is computational evidence only, not a formal theorem.

## 13. The Prouhet–Thue–Morse pairs

`PowerSumProuhet.prouhet K` is the pair obtained by iterating the doubling construction from
`({0}, {1})`.  Evaluated in Lean:

| K | `(prouhet K).1` | `(prouhet K).2` | power sums `k = 0,1,2,3` |
|---|-----------------|-----------------|--------------------------|
| 2 | `{0,3,5,6}` | `{1,2,4,7}` | `(4,4)`, `(14,14)`, `(70,70)`, `(368,416)` |
| 3 | `{0,3,5,6,9,10,12,15}` | `{1,2,4,7,8,11,13,14}` | agree up to `k = 3`, differ at `k = 4` (`89924` vs `88388`) |

These are the even/odd Thue–Morse classes, i.e. the naturals below `2^(K+1)` with an even
(resp. odd) binary digit sum, and they give the constructive form of the upper bound
`m(N, K) ≤ 2^K` (`PowerSumProuhet.minCollisionCard_le_two_pow`).
