# Computational Evidence — PRNGs cannot beat the pigeonhole bound

All numbers below were produced by evaluating Lean definitions from
`Catalog/MachineLearning/PRNGCompressionBound.lean` (`#eval`), and every claim
that is used mathematically is *also* proved as a theorem in the Lean files
(the two `decide`-checked demo theorems `lcg_missing_count` and
`lcg_misses_zero` are kernel-checked, not merely evaluated).

## 1. The demo generator

A four-bit-seed linear congruential generator producing eight bits of output:

```
lcgStep x = (5 * x + 3) % 16
lcgOut  s = lcgStep s + 16 * lcgStep (lcgStep s)      -- 8-bit output, 4-bit seed
```

`#eval` over all 16 seeds gives the reachable set

```
{9, 22, 35, 48, 77, 90, 103, 116, 129, 158, 171, 184, 197, 210, 239, 252}
```

| quantity | value |
|---|---|
| seeds | `2^4 = 16` |
| distinct 8-bit outputs | `16` |
| 8-bit values total | `2^8 = 256` |
| values with **no** seed | `240` (93.75 %) |
| coverage | `16/256 = 2^(4-8) = 2^-4` |

Verified formally: `lcg_image_card_le` (≤ 16 outputs), `lcg_missing_count`
(exactly 240 unreachable, by `decide`), `lcg_misses_zero` (the byte `0x00` has
no seed).

So the "compress my file to a seed" idea already fails at `n = 8`: a randomly
chosen byte has probability `1/16` of being expressible, and even then the
"compressed" form (4 bits of seed + 1 flag bit) is only useful for those 16
bytes. This is the exact numerical shadow of `prng_range_density`
(`2^(n-s) · |range G| ≤ 2^n`).

## 2. Counterexample hunt against the universal claim

The claim under test is: *for every generator `G : {0,1}^s → {0,1}^n` with
`s < n` there is a string no seed produces* (`exists_unreachable_of_short_seed`).
A counterexample would be a surjective `G` with `s < n`, i.e. an injection
`{0,1}^n ↪ {0,1}^s`. Exhaustive search is unnecessary: `2^n > 2^s` settles it,
and this is exactly the Lean proof (`Fintype.card_le_of_surjective` plus
`Nat.pow_le_pow_iff_right`). No counterexample can exist; the search space of
"clever generators" is empty for a *counting* reason, independent of the
generator's internal structure. This is why the negative result is robust to
any future PRNG design.

## 3. Compression-gain table (from `KC_compressible_count` / `compressible_fraction_le`)

Fraction of `n`-bit files that any fixed decompressor can shrink by `d` bits is
at most `2^(1-d)`:

| gain `d` (bits) | max fraction of files helped |
|---|---|
| 1 | 1 |
| 4 | `2^-3 = 12.5 %` |
| 8 (one byte) | `2^-7 ≈ 0.78 %` |
| 20 | `2^-19 ≈ 1.9·10^-6` |
| 80 (10 bytes) | `2^-79 ≈ 1.7·10^-24` |

Consequence for the "seed hunt": to compress a 1 MB file to a 256-bit seed one
needs a gain of `d ≈ 8·10^6 - 256` bits, so at most a `2^(-8·10^6)` fraction of
files can ever be helped, whatever generator is used.

## 4. Average-case table (from `average_length_lower_real`)

Mean codeword length over all `2^n` files is at least `(n-k)(1-2^-k)` for every
`k < n`:

| `n` | best `k` in the table | lower bound on mean length |
|---|---|---|
| 8 | 3 | `5 · 0.875 = 4.375` |
| 32 | 5 | `27 · 0.969 ≈ 26.2` |
| 256 | 8 | `248 · 0.996 ≈ 247.0` |
| 1024 | 10 | `1014 · 0.999 ≈ 1013.0` |

i.e. the mean rate is `n - O(log n)` bits per file: even *on average* against
uniform data there is essentially nothing to gain.

## 5. OEIS

No new integer sequence arises: the counting function
`#{strings of length ≤ k} = 2^(k+1) - 1` is A000225 (Mersenne numbers,
`1, 3, 7, 15, 31, …`), which is exactly the bound proved in `card_short_le`.
