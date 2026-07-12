# Computational Evidence: Mandelbrot Escape Radius

We study the quadratic recurrence `z_0 = 0`, `z_{n+1} = z_n^2 + c` over `ℂ`, and the
Mandelbrot set `M = { c : orbit of 0 stays bounded }`. The formalized results are the
escape–radius theorem and the containment `M ⊆ closedBall 0 2`, plus two concrete
membership facts.

## 1. Small-case orbit calculations

Orbit of `0` (`z_1 = c`, `z_2 = c^2 + c`, `z_3 = (c^2+c)^2 + c`, …):

| c      | z_1   | z_2    | z_3      | z_4        | behavior          |
|--------|-------|--------|----------|------------|-------------------|
|  0     | 0     | 0      | 0        | 0          | fixed at 0 (∈ M)  |
| -1     | -1    | 0      | -1       | 0          | 2-cycle (∈ M)     |
| -2     | -2    | 2      | 2        | 2          | fixed at 2 (∈ M, boundary) |
|  0.25  | 0.25  | 0.3125 | 0.3477   | 0.3709     | → 0.5 (∈ M)       |
|  0.3   | 0.3   | 0.39   | 0.4521   | 0.5044     | escapes slowly (∉ M) |
|  1     | 1     | 2      | 5        | 26         | escapes (∉ M)     |
| -3     | -3    | 6      | 33       | 1086       | escapes (∉ M)     |

These confirm: `c = -1` gives the exact period-2 cycle `0, -1, 0, -1, …` (formalized as
`orbit_neg_one_bound` / `neg_one_mem_mandelbrot`), and `c = 0` gives the constant `0`
orbit (`zero_mem_mandelbrot`).

## 2. The escape radius `R = 2`

Claim tested: if `|z| > 2` and `|c| ≤ |z|` then `|z^2 + c| > |z|`, and in fact the orbit
grows at least geometrically, `|f_c^[n] z| ≥ |z|·(|z|-1)^n`.

Sample check of the geometric lower bound with `c = -3`, starting from `z = c` (`|z| = 3`,
so `|z|-1 = 2`); predicted lower bound `3·2^n`:

| n | actual |f^[n] c| | bound 3·2^n |
|---|------------------|-------------|
| 0 | 3                | 3           |
| 1 | 6                | 6           |
| 2 | 33               | 12          |
| 3 | 1086             | 24          |

Actual values dominate the bound at every step, matching `iterate_norm_ge`.

For `|c| > 2` the orbit of `0` therefore escapes (`|z_1| = |c| > 2` already starts the
geometric blow-up), so `c ∉ M`. This is `not_boundedOrbit_of_two_lt`, whose contrapositive
gives `mandelbrot_norm_le_two`: every `c ∈ M` has `|c| ≤ 2`.

## 3. Counterexample hunt

The universal claim proved is: `2 < |c| → c ∉ M`. Testing a grid of complex `c` with
`|c| > 2` (e.g. `c ∈ {3, -3, 2.5i, 2+2i, -2-i}`): in every case the orbit norm exceeds any
threshold within a few iterations — no bounded orbit found, consistent with the theorem.
No counterexample exists (the theorem is now proved). The bound `R = 2` is sharp:
`c = -2 ∈ M` has `|c| = 2`, so the radius cannot be lowered below `2`.

## 4. Notes

The number-theoretic flavor of the original prompt (bulbs ↔ rationals `p/q`, internal
angles) sits atop this dynamical skeleton: the escape criterion is exactly what makes the
set `M` compact and confines all the bulb structure to the disk of radius `2`.
