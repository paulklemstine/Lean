# Computational Evidence: Collatz as a One-Way Map

All claims below are *also* formalized and machine-checked in the Lean files of
this directory; the tables here are the small-case exploration that motivated the
formal statements.

## 1. The Collatz step `T`

`T n = n/2` (n even), `3n+1` (n odd).

| n | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|----|----|----|
|T n| 4 | 1 |10 | 2 |16 | 3 |22 | 4 |28 | 5  |34  | 6  |

## 2. Preimage counts (the source of non-invertibility)

The preimage set of `k` is `{2k}` plus, when `k ≡ 4 (mod 6)`, the odd number
`(k-1)/3`.

| k | preimages | count |
|---|-----------|-------|
| 1 | {2}       | 1 |
| 2 | {4}       | 1 |
| 3 | {6}       | 1 |
| 4 | {1, 8}    | 2 |   ← `T 1 = T 8 = 4` (smallest collision)
| 5 | {10}      | 1 |
| 10| {3, 20}   | 2 |   ← `T 3 = T 20 = 10`
| 16| {5, 32}   | 2 |   ← `T 5 = T 32 = 16`
| 22| {7, 44}   | 2 |
| 28| {9, 56}   | 2 |

The two-preimage values are exactly `6j + 4` for `j = 0, 1, 2, …`
(4, 10, 16, 22, 28, …), an infinite family. The two preimages are
`2j+1` (odd) and `12j+8` (even), always of opposite parity, hence distinct.
Formalized as `two_preimages` and `infinitely_two_to_one`.

## 3. OEIS

The two-preimage targets `4, 10, 16, 22, 28, 34, …` form the arithmetic
progression `6j+4` (OEIS A016957, `6n+4`). The branch points being a full
arithmetic progression is what gives *unbounded* (infinite) information loss.

## 4. Inversion search space `2^a`

For the iterated map `f a n = T^[a] n`, a value's preimage fibre injects into the
set of `a`-bit parity transcripts `Fin a → Bool`. Brute-force inversion is a
search over at most `2^a` transcripts.

| a | #transcripts `2^a` | example: fibre of `f a (·) = 1` (preimages of 1) |
|---|--------------------|--------------------------------------------------|
| 0 | 1   | {1} |
| 1 | 2   | {2} |
| 2 | 4   | {4} |
| 3 | 8   | {8, 1} (since `T 1 = 4`, `T 4 = 2`, `T 2 = 1`; and `8→4→2→1`) |

The fibres are far smaller than `2^a` because most parity transcripts are not
realizable — only the upper bound `preimage_ncard_le : ncard ≤ 2^a` is claimed.

## 5. Counterexample hunt — collision resistance

We tested the slogan "Collatz gives a collision-resistant hash". It FAILS
immediately: with `collatzCompress s b = T (s + b)`, the messages `[1]` and `[8]`
hash to the same value (both reach `T 1 = T 8 = 4`). This explicit collision is
formalized (`collatz_hash_not_collision_resistant`) by feeding the two messages
into the catalog's Merkle–Damgård extraction theorem. One-wayness (hard to
invert) does *not* imply collision resistance (hard to find two preimages).
