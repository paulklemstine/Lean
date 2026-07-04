# Computational Evidence: 2-adic valuation of shifted Perrin numbers `ν₂(Rₘ − 1)`

## The sequence

Perrin numbers `R` are defined by `R₀ = 3, R₁ = 0, R₂ = 2` and `Rₙ₊₃ = Rₙ₊₁ + Rₙ`.
Sequence (OEIS **A001608**): `3, 0, 2, 3, 2, 5, 5, 7, 10, 12, 17, 22, 29, 39, 51, 68, 90, …`

We study `ν₂(Rₘ − 1)`, the exponent of the largest power of 2 dividing `Rₘ − 1`
(the shifted Perrin sequence `A001608(n) − 1`).

## Small-case table `(m, Rₘ, ν₂(Rₘ−1))`

```
0  3   1     10 17   4     20 277  2     30 4610 0
1  0   0     11 22   0     21 367  1
2  2   0     12 29   2     22 486  0
3  3   1     13 39   1     23 644  0
4  2   0     14 51   1     24 853  2
5  5   2     15 68   0     25 1130 0
6  5   2     16 90   0     26 1497 3
7  7   1     17 119  1     27 1983 1
8 10   0     18 158  0     28 2627 1
9 12   0     19 209  4     29 3480 0
```

## Periodicity of `R mod 2ᵏ`  (verified up to k = 5)

| modulus `2ᵏ` | 2 | 4 | 8 | 16 | 32 |
|---|---|---|---|---|---|
| period of `Rₘ mod 2ᵏ` | 7 | 14 | 28 | 56 | 112 |

So the period mod `2ᵏ` is exactly `7·2ᵏ⁻¹`.

## Classification by residue mod 7 (period-7, i.e. `R mod 2`)

- `m mod 7 ∈ {1,2,4}` ⇒ `Rₘ` even ⇒ `ν₂(Rₘ−1) = 0`.
- `m mod 7 ∈ {0,3,5,6}` ⇒ `Rₘ` odd ⇒ `ν₂(Rₘ−1) ≥ 1`.

## Complete classification by residue mod 28 (period-28, i.e. `R mod 8`)

For 25 of the 28 residues the valuation is **constant**:

```
m%28:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27
ν₂:    1  0  0  1  0  2  2  1  0  0  *  0  2  1  1  0  0  1  0  *  2  1  0  0  2  0  *  1
```
The three residues `m ≡ 10, 19, 26 (mod 28)` (marked `*`) have `ν₂ ≥ 3` and are the only
ones where the valuation is **not** determined by `m mod 28`. Equivalently:
`ν₂ = 0 ⇔ Rₘ even`; `ν₂ = 1 ⇔ Rₘ ≡ 3 (mod 4)`; `ν₂ = 2 ⇔ Rₘ ≡ 5 (mod 8)`;
`ν₂ ≥ 3 ⇔ Rₘ ≡ 1 (mod 8)`.

## Self-similar refinement at the next level (period-56, i.e. `R mod 16`)

Each exceptional residue mod 28 splits into one "resolved" child (`ν₂ = 3` exactly) and
one "still exceptional" child (`ν₂ ≥ 4`):

```
m%56 ∈ {26, 38, 47}  ⇒ ν₂ = 3   (exactly three residues, one per parent 10,19,26)
m%56 ∈ {10, 19, 54}  ⇒ ν₂ ≥ 4   (exactly three residues persist)
```

This doubling continues: at level `2ᵏ` exactly three residues (mod `7·2ᵏ⁻¹`) carry `ν₂ ≥ k`.

## Counterexample hunt / all-values check

`ν₂(Rₘ−1)` is **unbounded**: computing `Rₘ mod 2²⁰` we find valuations 0,1,2,…,19 all
attained; smallest witnesses:
```
val : 0  1  2  3   4   5    6   7    8     …
m   : 1  0  5  26  10  110  66  75   290   …
```
No counterexample to the mod-28 / mod-56 classification was found in ≥ 4000 full periods.

## OEIS

Perrin numbers: **A001608**.  The 2-adic valuation profile of `A001608(n) − 1`
matches the piecewise structure above.
