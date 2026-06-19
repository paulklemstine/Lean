# Computational Evidence — Library of Babel Combinatorics

All claims below were checked computationally (small `#eval` cases / direct arithmetic)
before being formalized in `Counting.lean` and `Diagonal.lean`.

## 1. Library size `|Volume b L| = b^L`

| b | L | b^L | brute-force count of `Fin L → Fin b` |
|---|---|-----|--------------------------------------|
| 2 | 2 | 4   | 4  |
| 2 | 3 | 8   | 8  |
| 3 | 2 | 9   | 9  |
| 5 | 3 | 125 | 125 |

Matches `Fintype.card_fun`. Borges instance: `25 ^ 1312000` (≈ `10^1834097`).

## 2. Agreement count `#{f | f≡g on S} = b^(L-|S|)`

b = 2, L = 3:

| |S| | predicted 2^(3-|S|) | brute count |
|-----|---------------------|-------------|
| 0   | 8                   | 8  |
| 1   | 4                   | 4  |
| 2   | 2                   | 2  |
| 3   | 1                   | 1  |

So the matching **fraction** is `2^(-|S|)`: `1, 1/2, 1/4, 1/8`. This confirms
`prob_match`: probability of a fixed `m`-symbol block is exactly `b^{-m}`.

### Counterexample hunt against the informal conjecture `|T|·b^{-k}`

The informal "`P ≈ |T| · 25^{-k}`" has a spurious linear `|T|` prefactor. For a block at
**fixed** positions the exact probability is `b^{-m}` (no prefactor). The `|T|`-style factor
only appears as an **upper bound** for "block occurs at *some* of the `L-m+1` windows"
(union bound `≤ (L-m+1)·b^{-m}`), never as an equality. Computationally, for b=2, L=3, m=1,
the exact fixed-position probability is `1/2`, whereas `|T|·b^{-k}` with `|T|=k=1` gives
`1/2` only by coincidence; for m=2 exact is `1/4` while a `(L-m+1)=2` windowed bound gives
`2/4=1/2`. The two are genuinely different — the conjecture's equality is false. ✗

## 3. Diagonal obstruction `L < b^L`

| b | L | L | b^L | L < b^L |
|---|---|---|-----|---------|
| 2 | 1 | 1 | 2   | ✓ |
| 2 | 5 | 5 | 32  | ✓ |
| 25| 1312000 | 1312000 | 25^1312000 | ✓ |

Confirms a single volume's `L` positions cannot address `b^L` volumes.

## 4. Distributed catalog threshold `⌈b^L / L⌉`

Smallest `N` with `b^L ≤ N·L`:

| b | L | b^L | ⌈b^L/L⌉ |
|---|---|-----|---------|
| 2 | 2 | 4   | 2 |
| 2 | 3 | 8   | 3 |
| 3 | 2 | 9   | 5 |

Note the **absence of any `log₂ b` factor**: the informal `b^L/(L·log₂ b)` underestimates;
the true entry-count threshold is `b^L/L`, and the bit-level book threshold is even larger
(`b^L`). See Lab Notes in `Diagonal.lean`.

## 5. de Bruijn lengths `m = b^n` (OEIS context)

de Bruijn sequence `B(b,n)` has length `b^n`; the number of distinct ones is
`(b!)^{b^{n-1}} / b^n` (the de Bruijn–van Aardenne-Ehrenfest theorem).

| b | n | length b^n | #B(b,n) |
|---|---|-----------|---------|
| 2 | 2 | 4         | 1  |
| 2 | 3 | 8         | 2  (OEIS A016031 family) |
| 3 | 2 | 9         | 24 |
| 4 | 16| 4294967296 | astronomically large |

Concrete `B(2,2)` witness `0 0 1 1`: cyclic windows `00, 01, 11, 10` — all four binary
2-words, each once. Verified by `decide` in `deBruijn_witness_two_two`. The mini-Library
`B(4,16)` necessarily has length `4^16 = 4294967296` (`miniLibrary_deBruijn_length`);
explicit construction is infeasible to store but the length is forced.
