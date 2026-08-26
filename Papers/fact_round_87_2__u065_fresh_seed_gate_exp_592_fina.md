# Computational evidence for the κ rate-dial theorems

All numbers below were produced with `#eval` inside the project's Lean environment (kernel-
evaluated `Finset` computations over the actual definitions in
`Catalog/Combinatorics/KappaRateDial.lean`), not in an external script. Each block states
which theorem it probes.

## 1. Brute-force cell counts vs. the closed form `κ` (probes `card_period_eq_kappaRaw`)

`P = {2,3,5,7}`, period `L = 210`. For every subset `T ⊆ P` (the set of primes required to
divide `v`) we brute-force `#{v < 210 : ∀ p ∈ P, (p ∣ v ↔ p ∈ T)}` and compare with
`κ = ∏_{p∈P} (if p ∈ T then 1 else p-1)`.

| T (dividing primes) | brute force | κ | match |
| --- | --- | --- | --- |
| ∅         | 48 | 48 | ✓ |
| {2}       | 48 | 48 | ✓ |
| {3}       | 24 | 24 | ✓ |
| {2,3}     | 24 | 24 | ✓ |
| {5}       | 12 | 12 | ✓ |
| {2,5}     | 12 | 12 | ✓ |
| {3,5}     |  6 |  6 | ✓ |
| {2,3,5}   |  6 |  6 | ✓ |
| {7}       |  8 |  8 | ✓ |
| {2,7}     |  8 |  8 | ✓ |
| {3,7}     |  4 |  4 | ✓ |
| {2,3,7}   |  4 |  4 | ✓ |
| {5,7}     |  2 |  2 | ✓ |
| {2,5,7}   |  2 |  2 | ✓ |
| {3,5,7}   |  1 |  1 | ✓ |
| {2,3,5,7} |  1 |  1 | ✓ |

16/16 agreement. Two structural facts jump out of the table and became theorems:

* rows differing only in whether `2 ∈ T` are **identical** — this is
  `kappaRaw_flip_two` (the prime `2` is a dead coordinate);
* the extremes are `48 = φ(210)` and `1` — this is `kappa_spread`.

Note the cell `{2,3,5}` (i.e. `2∣v ∧ 3∣v ∧ 5∣v ∧ 7∤v`), the "top cell" of the reported
composition layer, has exactly `6` members per period; brute force `6`, closed form `6`.

## 2. Sum over all cells (probes `sum_kappaRaw_powerset`)

`∑_{T ⊆ P} κ(T) = 210 = L`. ✓ (the 16 cells tile a period exactly).

## 3. Positional flatness (probes `cellCount_block`, `cellCount_period_multiple`)

Counts of the all-cleared cell in the ten consecutive blocks
`[0,210), [210,420), …, [1890,2100)`:

```
[48, 48, 48, 48, 48, 48, 48, 48, 48, 48]
```

Zero drift across blocks — the empirical "flat in t" observation is exact.

## 4. Coprime-scale equidistribution (probes `cellCount_coprime_residue`)

Counts of the all-cleared cell of `P = {2,3,5,7}` in `[0, 2310)` split by residue mod `11`
(`11` coprime to `210`):

```
r  = 0  1  2  3  4  5  6  7  8  9 10
n  = 48 48 48 48 48 48 48 48 48 48 48
```

Perfectly flat across all eleven classes — no positional signal at a coprime scale either.

## 5. The valuation ladder (probes `card_valPeriod_eq`)

`#{v < 3^{e+1} : v_3(v) = e}` for `e = 0,1,2,3`:

```
[2, 2, 2, 2]
```

Constant numerator `p - 1 = 2`, geometric denominator `3^{e+1}` — the ladder is exactly
`2/3, 2/9, 2/27, 2/81`.

## 6. Counterexample hunt: is the sweep map `σ ↦ κ(σ)` injective off the dead coordinate?

**No.** Distinct values reached by the full sweep:

| P | cells `2^{|P|}` | distinct κ values | bound `2^{|P|-1}` (if `2 ∈ P`) |
| --- | --- | --- | --- |
| {2,3,5,7}    | 16 | 8  | 8 (tight) |
| {3,7,13}     |  8 | 7  | — (no `2 ∈ P`) |
| {3,5,7,11,13}| 32 | 26 | — |

For `P = {3,7,13}` the sweep values are `[1, 2, 6, 12, 24, 72, 144]`: the value `12` is hit
twice, by `{7}` (i.e. `6·2`) and by `{13}` (i.e. `12`), because `(3-1)(7-1) = 13-1`. So the
bound `sweep_image_card_le` is tight for `P = {2,3,5,7}` but *not* an equality in general:
extra collisions come from multiplicative coincidences among the `p - 1`. This is
now covered by the exact criterion `sweepValues_card_eq_iff` (maximal sweep dimension holds
iff the `p-1` over the odd primes have pairwise distinct subset products); the two data
points above are formalised as `sweep_P4_card` and `sweep_collision_3_7_13`. Which prime
sets satisfy the criterion is left as an open direction.

## 7. OEIS

The row of maximal cell rates `φ(∏_{p ≤ x} p)` over primorials — `1, 1, 2, 8, 48, 480,
5760, …` — is the primorial-totient sequence (`A005867`). The counts in §1 are the
divisor-indexed refinement of that row; no new sequence is claimed.
