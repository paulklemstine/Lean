# Computational Evidence — Monotonicity and Jumps of `σ₅`

`σ₅(n)` is the minimal absolute value of a **non-vanishing** sum of `n` fifth roots of
unity. Every sum of `n` roots reduces (via `ζ⁵ = 1`) to `∑_{r<5} aᵣ ζʳ` with `aᵣ ≥ 0`,
`∑ aᵣ = n`, so `σ₅(n)` is the minimum of `|∑ aᵣ ζʳ|` over all compositions with the sum
nonzero. This is a finite search, computed by brute force below (`ζ = e^{2πi/5}`).

## 1. Small-case table (`n = 1..40`)

| n | σ₅(n) | n | σ₅(n) | n | σ₅(n) | n | σ₅(n) |
|---|-------|---|-------|---|-------|---|-------|
| 1 | 1.000000 | 11 | 0.145898 | 21 | 0.145898 | 31 | 0.145898 |
| 2 | 0.618034 | 12 | 0.236068 | 22 | 0.090170 | 32 | 0.090170 |
| 3 | 0.618034 | 13 | 0.236068 | 23 | 0.090170 | 33 | 0.090170 |
| 4 | 0.381966 | 14 | 0.145898 | 24 | 0.145898 | 34 | 0.055728 |
| 5 | 0.726543 | 15 | 0.277515 | 25 | 0.171513 | 35 | 0.171513 |
| 6 | 0.381966 | 16 | 0.145898 | 26 | 0.145898 | 36 | 0.055728 |
| 7 | 0.236068 | 17 | 0.236068 | 27 | 0.090170 | 37 | 0.090170 |
| 8 | 0.236068 | 18 | 0.090170 | 28 | 0.090170 | 38 | 0.090170 |
| 9 | 0.381966 | 19 | 0.145898 | 29 | 0.055728 | 39 | 0.055728 |
| 10 | 0.449028 | 20 | 0.277515 | 30 | 0.171513 | 40 | 0.106001 |

Recognisable constants: `1`, `φ⁻¹ = 0.618034`, `φ⁻² = 0.381966`, where `φ = (1+√5)/2`.
The value at the `n=6` jump is `√((7-3√5)/2) = φ⁻² = 0.381966`.

## 2. Monotonicity along residue classes mod 5 (confirmed)

Each column below is non-increasing (the formalized statement `sigma5_residue_antitone`):

- r=0: 5:0.7265, 10:0.4490, 15:0.2775, 20:0.2775, 25:0.1715, 30:0.1715, 35:0.1715, 40:0.1060
- r=1: 1:1.0000, 6:0.3820, 11:0.1459, 16:0.1459, 21:0.1459, 26:0.1459, 31:0.1459, 36:0.0557
- r=2: 2:0.6180, 7:0.2361, 12:0.2361, 17:0.2361, 22:0.0902, 27:0.0902, 32:0.0902, 37:0.0902
- r=3: 3:0.6180, 8:0.2361, 13:0.2361, 18:0.0902, 23:0.0902, 28:0.0902, 33:0.0902, 38:0.0902
- r=4: 4:0.3820, 9:0.3820, 14:0.1459, 19:0.1459, 24:0.1459, 29:0.0557, 34:0.0557, 39:0.0557

## 3. Jump positions (strict decreases `σ₅(n) > σ₅(n+5)`)

Fibonacci `F: 0,1,1,2,3,5,8,13,…`; Lucas `L: 2,1,3,4,7,11,18,29,47,…`.

| residue | jump positions `n+5` | matched form |
|---------|----------------------|--------------|
| 0 | 10, 15, 25, 40 | 5F₃, 5F₄, 5F₅, 5F₆ |
| 1 | 6, 11, 36 | 2L₂, L₅, 2L₆ |
| 2 | 7, 22 | L₄, 2L₅ |
| 3 | 8, 18 | 2L₃, L₆ |
| 4 | 14, 29 | 2L₄, L₇ |

Every observed jump position `n+5 ≤ 40` is exactly one of `5Fₘ, Lₘ, 2Lₘ` (`m ≥ 1`), and
every such value in range is a jump. This confirms the characterization
`σ₅(n) > σ₅(n+5) ⟺ n+5 ∈ {5Fₘ, Lₘ, 2Lₘ}`.

## 4. Residue split of the jump families (the formalized backbone)

- `5Fₘ ≡ 0 (mod 5)` always.
- `Lₘ mod 5 = 2,1,3,4,2,1,3,4,…` (period 4): **never 0**.
- `2Lₘ mod 5 = 4,2,1,3,4,2,1,3,…` (period 4): **never 0**.

Hence the only multiple-of-5 jumps come from the Fibonacci family `5Fₘ`. This is exactly
the content of `lucasNum_not_dvd_five` and `jump_dvd_five_is_fib`
(`FifthRootLucasJumps.lean`).

## 5. Counterexample hunt

- Monotonicity: no violation of `σ₅(5k+r) ≥ σ₅(5(k+1)+r)` found for `n ≤ 40`.
- Jump characterization: for `6 ≤ N ≤ 40`, the set of `N` with `σ₅(N-5) > σ₅(N)` equals
  `{N : N = 5Fₘ ∨ N = Lₘ ∨ N = 2Lₘ, m ≥ 1}` exactly — no false positives or negatives.

## 6. OEIS

The integer sequence `⌊1/σ₅(n)²⌋` and the jump-position sequence `10,15,25,40,…` /
`6,7,8,11,14,18,…` are Fibonacci/Lucas-driven; the union `{5Fₘ} ∪ {Lₘ} ∪ {2Lₘ}` interleaves
the classical Fibonacci (A000045) and Lucas (A000032) numbers.
