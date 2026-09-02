# Computational evidence — BALANCED-BKEY (exp 523, round-54 #1)

All numbers below were produced with exact rational arithmetic and, where marked *(Lean)*, are
`#eval`s of the very definitions used in the formal proofs
(`Catalog/Cryptography/BalancedBKeyDialRobustness.lean`,
`Catalog/Cryptography/BalancedBKeyFixedWeight.lean`).  Everything asserted as a theorem in the
Lean files is proved there without `sorry`; the tables here are the exploratory data that guided
the statements.

## 1. The `bitlen × cap` table of tie ceilings

The dial statistic is `T_u(x) = min(v₂(x), u)` on `b`-bit keys.  Its tie profile is
`capBlocks u b = [2^(b-1), …, 2^(b-u), 2^(b-u)]`, and the attainable Spearman ceiling against
any tie-refining response is `ρ(b,u) = √(spearmanSq (capBlocks u b))`.

Exact small cases *(Lean, exact ℚ)*:

| profile | `capBlocks u b` | `ρ²` |
|---|---|---|
| `u=0, b=3` | `[8]` | `0` |
| `u=1, b=3` | `[4,4]` | `16/21` |
| `u=2, b=3` | `[4,2,2]` | `6/7` |
| `u=3, b=3` | `[4,2,1,1]` | `73/84` |

These match the closed form `ρ²(b,u) = (6/7)(1 − 8^(−u))(1 + 1/(4^b − 1))` proved as
`capped_ceiling_factorisation`, e.g. `(6/7)(63/64)(64/63) = 6/7` at `u = 2, b = 3`.

Ceiling table in `ρ` (rounded from the exact rationals):

| b \ u | 1 | 2 | 3 | 4 | 6 | 8 |
|---|---|---|---|---|---|---|
| 8  | 0.866032 | 0.918566 | 0.924923 | 0.925714 | 0.925825 | 0.925827 |
| 16 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| 32 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| 44 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| 52 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |
| 64 | 0.866025 | 0.918559 | 0.924916 | 0.925707 | 0.925818 | 0.925820 |

Observed patterns, each subsequently proved:

* every entry is above `0.866` — no cell approaches the recorded floor `0.53`
  (`capped_cell_floor`);
* rows are proportional to one another (rank-one table, `ceiling_table_rank_one`);
* columns vary by less than `10⁻⁵` beyond `b = 8` (`bitlen_movement_small`, bound `2·4^(−b)`).

## 2. Counterexample hunt: how large can the `T`-versus-count advantage be?

The recorded claim is that `T` beats the bare count by `0.10 – 0.15`.  Searching the whole
envelope for the largest tie-resolution advantage `ρ(b,u) − ρ(b,1)`:

| cell | advantage in `ρ` |
|---|---|
| `b=8, u=2` | 0.052534 |
| `b=16, u=8` | 0.059795 |
| `b=52, u→∞` | 0.059795 |
| supremum over all cells | `√(6/7) − √(3/4) = 0.059795` |

No cell reaches `0.10`.  This is the content of `gap_ceiling_upper_real` (bound `0.07`) and
`recorded_gap_forces_slack`: the recorded advantage requires the bare-count reading to lie at
least `0.03` below its own ceiling.

## 3. Balanced (fixed-weight) keys

For weight-`w` `b`-bit keys the trailing-zero profile is binomial,
`weightBlocks b w = [C(b−1,w−1), C(b−2,w−1), …, C(w−1,w−1)]`:

| `b` | `w` | profile *(Lean)* | `n` | `ρ²` *(Lean)* | `ρ` |
|---|---|---|---|---|---|
| 6 | 3 | `[10, 6, 3, 1]` | 20 | `563/665` | 0.920118 |
| 8 | 4 | `[35, 20, 10, 4, 1]` | 70 | `1386/1633` | 0.921274 |

Checks that motivated the theorems:

* `10+6+3+1 = 20 = C(6,3)` and `35+20+10+4+1 = 70 = C(8,4)` — the hockey-stick identity
  (`weightBlocks_sum`);
* `2·10 = 20` and `2·35 = 70` — the modal class carries exactly half the keys at `w = b/2`
  (`half_weight_modal_half`), which is the boundary case of the floor law and the entry point of
  the half-mass cap (`fixedWeight_two_sided_pin`);
* uniform comparison at `b = 8`: `ρ = 0.925826` versus balanced `0.921274`, a difference of
  `0.004552` — two orders of magnitude below the recorded effects, and inside the proved `0.07`
  law-change capacity (`law_change_capacity`).

## 4. Where the floor actually breaks

Scanning profiles of the form `[n−1, 1]` (one dominant class):

| profile | modal mass | `ρ` |
|---|---|---|
| `[3,1]` | 0.750 | 0.7746 |
| `[7,1]` | 0.875 | 0.5774 |
| `[15,1]` | 0.9375 | 0.4201 |

So the `0.53` floor fails only once the modal class exceeds roughly `85%` of the sample.  The
formal statements bracket this: `mass_fraction_cliff_edge` proves the floor holds up to modal
mass `0.847`, and `majority_block_cliff_example` proves `[15,1]` (modal mass `0.9375`) reads
`ρ² = 3/17 < 0.53²`.

## 5. OEIS

The block-size sequences involved are the powers of two `1, 2, 4, 8, …` (A000079) for uniform
draws and the binomial column `C(m, w−1)` (e.g. triangular numbers A000217 for `w = 3`) for
balanced draws; the profile sums are the binomial coefficients A007318.  No new integer sequence
arises, which is itself evidence that the phenomenon is structural rather than accidental.
