# Computational Evidence

Supporting computations for the three Lean files on the Mandelbrot set's quadratic
recurrence `z_{n+1} = z_n^2 + c` and its "secret number theory".

## 1. Escape dynamics of `z^2 + c`

For `|c| > 2` the critical orbit `0, c, c^2+c, …` blows up. Sample (`c = 3`):

| n | z_n              | |z_n| |
|---|------------------|-------|
| 0 | 0                | 0     |
| 1 | 3                | 3     |
| 2 | 12               | 12    |
| 3 | 147              | 147   |
| 4 | 21612            | 21612 |

The proven lower bound `|c|·(|c|-1)^n ≤ |z_{n+1}|` (with `|c|-1 = 2 > 1`) forces divergence,
so no such `c` lies in the Mandelbrot set: `M ⊆ closed disk of radius 2`.
Bounded examples: `c = 0` (orbit `0,0,…`) and `c = -1` (2-cycle `0,-1,0,-1,…`).

## 2. External-angle doubling map = multiplication by 2 mod q

The doubling map `θ ↦ 2θ mod 1` on angles with denominator `q` is `x ↦ 2x` on `ℤ/qℤ`.
The **period of the angle `1/q`** is the multiplicative order of `2` modulo `q`:

| q  | ord_q(2) | q-1 | q odd? |
|----|----------|-----|--------|
| 3  | 2        | 2   | yes    |
| 5  | 4        | 4   | yes    |
| 7  | 3        | 6   | yes    |
| 9  | 6        | (φ=6)| yes   |
| 11 | 10       | 10  | yes    |
| 13 | 12       | 12  | yes    |
| 15 | 4        | (φ=8)| yes   |
| 17 | 8        | 16  | yes    |
| 19 | 18       | 18  | yes    |
| 21 | 6        | (φ=12)| yes  |
| 23 | 11       | 22  | yes    |

(computed in Lean with a `find?`-based order function). For odd prime `q`, `ord_q(2) | q-1`
(Fermat). For even `q`, `x ↦ 2x` is not injective (angles are only pre-periodic).

This is OEIS **A002326** (multiplicative order of 2 mod 2n+1): `1, 2, 4, 3, 6, 10, 12, 4, 8, …`.

### Counterexample hunt (contrarian conjectures)
- "2 is always a primitive root mod odd prime `q`" (period `= q-1`): **FALSE**, `q=7` gives `3 ≠ 6`.
- "the bulb period `ord_q(2)` is always prime": **FALSE**, `q=5` gives period `4`.

Both are proven as disproofs in `MandelbrotDoublingNumberTheory.lean`.

## 3. Farey / Fibonacci bulb ordering

Mediants and Cassini's identity along the golden path `1/1, 1/2, 2/3, 3/5, 5/8, …`:

| n | (F n, F(n+1)) ⊕ (F(n+1), F(n+2)) | = (F(n+2), F(n+3)) | Cassini F(n+1)^2 - F n F(n+2) |
|---|----------------------------------|--------------------|-------------------------------|
| 0 | (1,2)                            | (1,2)              | +1                            |
| 1 | (2,3)                            | (2,3)              | -1                            |
| 2 | (3,5)                            | (3,5)              | +1                            |
| 3 | (5,8)                            | (5,8)              | -1                            |

Cassini `F(n+1)^2 - F n·F(n+2) = (-1)^n` was verified for `n = 0..9`
(`[1,-1,1,-1,1,-1,1,-1,1,-1]`), confirming that consecutive Fibonacci ratios are Farey
neighbours (determinant `±1`), i.e. adjacent bulbs.
