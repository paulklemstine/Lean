# Computational Evidence: turn profiles of long snakes, n ≤ 7

## Setup
A snake is written as a transition sequence (the coordinate flipped at each step), starting at
the all-zero vertex of `Q_n`. Pick a set `R` of `a` row coordinates. The cube then splits as
`Q_n = Q_R □ Q_{n-a}`, and the **turn count** of the snake is the number of steps that flip a
coordinate in `R`. The theorem `turnsIn_eq_sum_flips` shows this equals the sum of the
per-coordinate flip counts over `R`. So the turn-minimal `a`-split uses the `a` coordinates
that are flipped least often.

## Snakes used (all certified in Lean, `Catalog/Geometry/SnakeRecords.lean`)
| n | length | transition sequence | status |
|---|---|---|---|
| 2 | 2 | 01 | record |
| 3 | 4 | 0120 | record |
| 4 | 7 | 0120310 | record |
| 5 | 13 | 0123104312301 | record |
| 6 | 26 | 01231043054013402410431534 | record |
| 7 | 48 | 346143014613450346143046240345643014356450345643 | **not** the record (the record is 50) |

The snakes were found by randomised DFS, beam search and a hybrid beam+DFS search, written as
ad-hoc scripts. Those searches reached lengths 47 and 48 in `Q_7` but never 50. The Lean file
certifies each listed sequence as a snake (`rec*_isSnake`, `best7_isSnake`) and certifies its
flip profile (`rec4/5/6_profile`, `best7_profile`).

## Turn profiles (flip counts certified in Lean; the other columns are arithmetic on them)
For each split dimension `a`, the table gives four numbers:
- the minimal turn count over all `a`-subsets;
- the normal-form upper bound `⌊aL/n⌋`, which is a Lean theorem (`exists_turnsIn_le`);
- the lower bound `⌈(L+1)/2^{n-a}⌉-1`, which is a Lean theorem
  (`succ_le_turnsIn_succ_mul_pow`);
- the sharper lower bound `⌈(L+1)/(S(n-a)+1)⌉-1`. This one uses the known snake values
  `S(b)` from the literature, which are **not** proved in Lean.

| n | L | flips per coordinate | a : min turns (≤ aL/n ; LB_2^b / LB_S(b)) |
|---|---|---|---|
| 2 | 2 | [1,1] | a=1: 1 (≤1; 1/1) |
| 3 | 4 | [2,1,1] | a=1: 1 (≤1; 1/1), a=2: 2 (≤2; 2/2) |
| 4 | 7 | [3,2,1,1] | a=1: 1 (≤1; 0/1), a=2: 2 (≤3; 1/2), a=3: 4 (≤5; 3/3) |
| 5 | 13 | [3,4,2,3,1] | a=1: 1 (≤2; 0/1), a=2: 3 (≤5; 1/2), a=3: 6 (≤7; 3/4), a=4: 9 (≤10; 6/6) |
| 6 | 26 | [6,5,2,5,6,2] | a=1: 2 (≤4; 0/1), a=2: 4 (≤8; 1/3), a=3: 9 (≤13; 3/5), a=4: 14 (≤17; 6/8), a=5: 20 (≤21; 13/13) |
| 7 | 48 | [6,5,1,10,14,5,7] | a=1: 1 (≤6; 0/1), a=2: 6 (≤13; 1/3), a=3: 11 (≤20; 3/6), a=4: 17 (≤27; 6/9), a=5: 24 (≤34; 12/16), a=6: 34 (≤41; 24/24) |

## Observations
1. The flips are uneven: in every case the minimal `a`-split lies well below the averaging
   bound `aL/n`.
2. In the `Q_7` 48-snake, coordinate 2 is flipped exactly once. That snake is therefore a
   one-turn comb in `Q_1 □ Q_6`: two snakes of `Q_6` joined by a single connector edge.
3. For `a = 1`, the minimal turn count equals the sharper lower bound
   `⌈(L+1)/(S(n-1)+1)⌉-1` at `n = 2, 3, 4, 5, 7`. At `n = 6` the 26-snake has 2 turns against
   a bound of 1. For larger `a`, the gap between the minimum and the lower bound grows.

## OEIS
The maximum snake lengths 1, 2, 4, 7, 13, 26, 50, 98 form the classical snake-in-the-box sequence. It is listed in the OEIS, but no online lookup was possible here, so the sequence ID is not quoted.

## Counterexample hunt
No counterexample to the general theorems is possible because they are proved. The only
"failure" was a claim in an early draft: that the trivial `Q_1 □ Q_5` lower bound forces every
coordinate of the 26-snake to flip at least once. Lean refuted that claim (`27 ≤ 32` holds
with zero flips), and it was replaced by a correct `Q_3 □ Q_3` statement
(`rec6_turn_profile`).
