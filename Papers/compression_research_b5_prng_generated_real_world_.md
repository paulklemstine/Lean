# Computational evidence — PRNG detection and seed recovery (B5)

All numbers below were produced inside the Lean project itself, by `#eval` on the
same `Finset` definitions that the theorems talk about
(`lfsrWords`, `lowComplexityWords`, `lcgWords`, `routerWords`,
`lfsrPRNG.stream`, `lcgPRNG.stream`).  `#eval` uses the compiler, not the
kernel, so the tables are *evidence*, not proof; the five statements in
`Catalog/Probability/PRNGEvidence.lean` re-derive representative entries with
`decide`, i.e. kernel-checked.

## 1. How many length-`n` files can an order-`L` LFSR produce?

`|lfsrWords GF(2) L n|`, rows `L = 1,2,3`, columns `n = 2 … 10`:

| L \ n | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|----|
| 1 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 | 3 |
| 2 | 4 | 7 | 11 | 11 | 11 | 11 | 11 | 11 | 11 |
| 3 | 4 | 8 | 15 | 27 | 43 | 43 | 43 | 43 | 43 |

Over `GF(3)`, `L = 1, 2`:

| L \ n | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|
| 1 | 7 | 7 | 7 | 7 | 7 | 7 | 7 |
| 2 | 9 | 25 | 61 | 61 | 61 | 61 | 61 |

**Observation (saturation).** Each row is strictly increasing until `n = 2L` and
constant from then on.  This is the counting shadow of Berlekamp–Massey
optimality and motivated — and is now explained by —
`lfsr_stream_determined_by_two_L` (the `2L` theorem) and
`card_lfsrWords_saturate`.

## 2. Nesting of the complexity hierarchy

`|lowComplexityWords GF(2) M 10|` versus `|lfsrWords GF(2) M 10|`, `M = 1…5`:

```
(3,3)  (11,11)  (43,43)  (171,171)  (683,683)
```

The union over all orders `≤ M` equals the single order-`M` family, which is
proved as `lowComplexityWords_eq_lfsrWords` (via `lfsrWords_subset_succ`).

## 3. Sandwich against the proved bounds

For `GF(2)`, `n = 10`, proved bounds `2^L ≤ |lfsrWords| ≤ 2^{2L}`
(`card_lfsrWords_ge`, `card_lfsrWords_le`):

| L | lower `2^L` | actual | upper `2^{2L}` |
|---|---|---|---|
| 1 | 2 | 3 | 4 |
| 2 | 4 | 11 | 16 |
| 3 | 8 | 43 | 64 |
| 4 | 16 | 171 | 256 |
| 5 | 32 | 683 | 1024 |

Both bounds are within a constant factor of the truth; neither is vacuous.

**Exact-formula conjecture (see `FUTURE_DIRECTIONS.md`).**  The data fit
`|lfsrWords GF(q) L n| = (q^{2L+1} + 1)/(q + 1)` for `n ≥ 2L`:
`q = 2` gives `3, 11, 43, 171, 683` and `q = 3` gives `7, 61, 547`, matching all
computed entries.  (Sequence `3, 11, 43, 171, 683` = `(2^{2L+1}+1)/3`, OEIS
A007583 shifted; it is the classical count of sequences of linear complexity
`≤ L`.)

## 4. LCGs really are order-two LFSRs

Over `ZMod 16`, `x ↦ 5x + 3` started at `x₀ = 7`:

```
LCG stream                      : 7, 6, 1, 8, 11, 10, 5, 12, 15, 14
order-2 LFSR, taps ![-5, 6],
seed ![7, 5*7+3]                : 7, 6, 1, 8, 11, 10, 5, 12, 15, 14
```

Identical, as `lcg_seed_recovery` proves in general.  Set-theoretically, over
`GF(2)` with `n = 10`: `|lcgWords| = 6`, `|routerWords L=2| = |lfsrWords 2| = 11`
and `|routerWords L=3| = |lfsrWords 3| = 43` — the LCG family adds *nothing* to
the order-`≥2` LFSR family, exactly as the fingerprint theorem predicts.
Over `ZMod 4`: `|lcgWords| = 44 ≤ 4³ = 64` (`card_lcgWords_le`).

## 5. Counterexample hunt

* *Is every file seed-compressible?*  No: `exists_not_seedCompressible`,
  `exists_high_linear_complexity` and `exists_not_routed` are proved, and the
  tables confirm the gap quantitatively — at `n = 10` over `GF(2)` the order-`5`
  family covers `683` of `1024` words, but the order-`3` family only `43`, i.e.
  `4.2%`.
* *Could a longer observation window reveal more order-`L` candidates?*  No —
  saturation at `n = 2L`, both observed and proved.
* *Could two different tap vectors explain the same stream?*  Only when the
  Hankel window is singular; `lfsr_taps_unique` gives the exact criterion.

## 6. A concrete LFSR stream

Taps `![1,1,0]` (i.e. `x_{t+3} = x_t + x_{t+1}` over `GF(2)`), seed `![1,0,0]`:

```
1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 1   (period 7 after the seed window)
```

The first `3` symbols `1,0,0` are literally the seed (`lfsr_pref_eq_self`), and
the whole stream is regenerated from them (`lfsr_exact_reproduction`).

## 7. Order-one enumeration and the router deficit (second cycle)

The order-one family over a field is the set of geometric words `x_t = cᵗ s`.
Counting them by hand (seed `s ≠ 0` recovers `(s, c)` from the first two
symbols; `s = 0` gives the all-zero word whatever the taps):

| `q` | predicted `q² - q + 1` | `(q³+1)/(q+1)` | enumerated |
|-----|------------------------|----------------|------------|
| `2` | `3`                    | `9/3 = 3`      | `3` (`card_lfsrWords_two_one_four`, kernel-checked) |
| `3` | `7`                    | `28/4 = 7`     | `7` (`card_lfsrWords_one_zmod_three`, kernel-checked) |
| `4` | `13`                   | `65/5 = 13`    | `13` |
| `5` | `21`                   | `126/6 = 21`   | `21` |

The pattern was proved in general in `PRNGEnumerationL1.lean`
(`card_lfsrWords_one`), which also shows both previously known bounds are loose
at `L = 1`: `q = q^L < q² - q + 1 < q^{2L} = q²` for `q ≥ 2`.

**Router deficit.** The "try every order `≤ 1`" router carries `1 + q²` seeds
(one for the empty register, `q²` taps-and-seed pairs at order one) but covers
only `q² - q + 1` files, a wasted budget of exactly `q`:

| `q` | seed budget `1 + q²` | coverage `q² - q + 1` | deficit |
|-----|----------------------|-----------------------|---------|
| `2` | `5`                  | `3`                   | `2`     |
| `3` | `10`                 | `7`                   | `3`     |
| `4` | `17`                 | `13`                  | `4`     |

Proved as `card_familyWords_lfsrFamily_one` together with
`card_familyWords_lfsrFamily_one_lt_ceiling`, on top of the general capacity
ceiling `card_familyWords_le` and the collapse theorem `familyWords_lfsrFamily`.

## 8. Noise-tolerant decoding: the counterexample search (third cycle)

Conjectured threshold for unique decoding under `e` errors: `n ≥ 2L + 2e + 1`.
Take `K = GF(3)`, `L = 1`, and the two order-one streams

```
y = 1, 1, 1, 1, 1, 1, 1, …      (taps ![1], seed 1)
z = 1, 2, 1, 2, 1, 2, 1, …      (taps ![2], seed 1)
```

They agree at every *even* index, so inside a window of length `n` they disagree
at only the `⌈(n-1)/2⌉` odd indices — and a word may split those disagreements
between them.  Enumerating the split for a window of length `n`:

| `e` | conjectured safe length `2L + 2e + 1` | odd indices in window | can split `e : e`? | verdict |
|-----|---------------------------------------|-----------------------|--------------------|---------|
| `1` | `5`                                   | `2`                   | yes (`1 : 1`)      | conjecture fails |
| `2` | `7`                                   | `3`                   | yes (`1 : 2`)      | conjecture fails |
| `3` | `9`                                   | `4`                   | yes (`1 : 3`)      | conjecture fails |

The witness word used in the Lean proof is the cheapest one: it differs from `y`
at index `1` only, and from `z` at the remaining `e` odd indices
(`noise_tolerance_two_L_plus_two_e_false`).

**How far does the failure reach?**  With the same pair of streams, a window of
length `n` contains `⌈(n-1)/2⌉` odd indices and a word can be within distance
`e` of both exactly when that count is at most `2e`:

| `e` | largest failing length | proved sufficient length `2L(2e+1)` |
|-----|------------------------|-------------------------------------|
| `1` | `5`                    | `6`                                 |
| `2` | `9`                    | `10`                                |
| `3` | `13`                   | `14`                                |
| `e` | `4e + 1`               | `4e + 2`                            |

The two columns differ by one at every `e`, i.e. the block-pigeonhole threshold
is *exactly* optimal at order one.  Both halves are proved:
`unique_decoding_of_long_window` (sufficiency, all `L`) and
`unique_decoding_threshold_sharp_order_one` (failure at `4e + 1`).

## 9. Maximal linear complexity: the impulse word

| word (length `n`) | smallest order `L` with word ∈ `lfsrWords K L n` |
|-------------------|--------------------------------------------------|
| `0,0,0,0`         | `0`                                              |
| `1,1,1,1`         | `1`                                              |
| `1,2,1,2`         | `1` (over `GF(3)`: taps `![2]`, seed `1`)        |
| `0,0,0,1`         | `4` — no order `< n` works                        |

The last row is the general phenomenon: the first `L` symbols of `0,…,0,1` are
zero and they *are* the seed, so a short LFSR emits the all-zero file.  Proved
as `lfsr_pref_ne_impulseWord` / `impulseWord_not_mem_lfsrWords`, with the
consequence `bm_half_length_bound_false` — no recovery routine can promise an
order `≤ ⌈n/2⌉` consistent with the observed window.

## 10. Improved counting bound versus the true counts

The pigeonhole bound counts one file per (taps, seed) pair.  Removing the
zero-seed collapse (all `q^L` tap vectors emit the same all-zero file) gives the
bound `q^{2L} - q^L + 1`, proved in `PRNGZeroSeedBound.lean`:

| `q` | `L` | old bound `q^{2L}` | new bound `q^{2L} - q^L + 1` | true count | conjectured `(q^{2L+1}+1)/(q+1)` |
|-----|-----|--------------------|------------------------------|------------|----------------------------------|
| `2` | `1` | `4`                | `3`                          | `3` ✓ kernel-checked | `3` |
| `2` | `2` | `16`               | `13`                         | `11` ✓ kernel-checked | `11` |
| `2` | `3` | `64`               | `57`                         | `43` ✓ kernel-checked | `43` |
| `3` | `1` | `9`                | `7`                          | `7` ✓ kernel-checked | `7` |
| `3` | `2` | `81`               | `73`                         | `61` ✓ kernel-checked | `61` |

The new bound is exact at `L = 1` (proved: `card_lfsrWords_one_eq_zero_seed_bound`)
and loses ground as `L` grows, which locates the remaining work in C1: the
higher-order degenerate strata, where distinct tap vectors agree on a seed whose
Hankel matrix is singular.
