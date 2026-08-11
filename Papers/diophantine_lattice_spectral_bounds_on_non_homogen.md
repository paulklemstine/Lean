# Computational Evidence — Diophantine–Lattice Spectral Bounds

All numbers below were produced by Lean `#eval` computations (exact rational
arithmetic for the counting data, `Float` for the theta data).  They are
exploratory: they motivated the theorems, and every claim that is asserted as a
*result* is proved in `Catalog/Applications/DiophantineLatticeSpectral.lean`
without `sorry`.

## 1. Test object

The extremal half-shift instance of the theory: `A = I`, `t = (1/2, …, 1/2)`,
so `Q(x − t) = ∑ᵢ (xᵢ − 1/2)²` with spectral bounds `m = M = 1` and
`d(t, ℤⁿ)² = n/4`.

## 2. Counting function `N(R) = #{x ∈ ℤⁿ : ∑ (xᵢ − 1/2)² ≤ R}`

(computed over the box `|xᵢ| ≤ 8` for `n ≤ 2` and `|xᵢ| ≤ 6` for `n = 3`, which
contains all solutions in the listed range)

| `n` | `R = n/4 − 0.01` | `R = n/4` | `R = 1` | `R = 4` | `R = 9` |
|-----|------------------|-----------|---------|---------|---------|
| 1   | 0                | 2         | 2       | 4       | 6       |
| 2   | 0                | 4         | 4       | 12      | 32      |
| 3   | 0                | 8         | 8       | 32      | 136     |

Observations.

* `N(R) = 0` for every `R < n/4`: the **spectral gap** `m·d(t,ℤⁿ)² = n/4` is
  attained and no integer point lies below it (proved: `spectral_gap_lower`,
  `sum_sq_half_shift_ge`, `no_integer_solution_below_gap`).
* `N(n/4) = 2ⁿ`: the minimum is attained exactly at the `2ⁿ` vertices
  `xᵢ ∈ {0,1}`, matching the covering bound `M·n/4` (proved as an upper bound:
  `exists_le_covering`, `inhomMin_sandwich`).  The exact multiplicity `2ⁿ` and
  the exact description of the extremal set as the vertex set of the unit cube
  are *proved*: `Cycle4.half_shift_solution_iff`,
  `Cycle4.half_shift_minimizer_count`.

## 3. Two-sided counting bounds

Proved bounds: `(2√(R/(M·n)) − 1)ⁿ ≤ N(R) ≤ (2√(R/m) + 1)ⁿ` (the lower bound for
`R ≥ M·n/4`).  With `m = M = 1`:

| `n` | `R` | lower bound | `N(R)` | upper bound |
|-----|-----|-------------|--------|-------------|
| 2   | 1   | 0.17        | 4      | 9           |
| 2   | 4   | 3.34        | 12     | 25          |
| 2   | 9   | 10.51       | 32     | 49          |
| 3   | 4   | 2.25        | 32     | 125         |
| 3   | 9   | 14.96       | 136    | 343         |

No violation was found; both inequalities are of the correct order `R^{n/2}`,
with the constants losing the factor `n^{-n/2}` on the lower side (the box vs.
ball discrepancy).

## 4. Theta series and the gap decay rate

`Θ(s) = ∑_{k∈ℤ} exp(−s (k − 1/2)²)` (truncated at `|k| ≤ 20`, error `< 10⁻¹⁰⁰`):

| `s` | `Θ(s)` | gap bound `exp(−(s−1)/4)·Θ(1)` |
|-----|--------|-------------------------------|
| 1   | 1.77227 | 1.77227 |
| 2   | 1.23529 | 1.38025 |
| 4   | 0.73601 | 0.83716 |
| 8   | 0.27067 | 0.30797 |

The proved estimate `Θ(s) ≤ exp(−(s − s₀)·m·d(t,ℤⁿ)²)·Θ(s₀)` (`theta_decay`)
holds in every sample and is tight to within ~12%: the exponential rate `1/4`
of the decay is exactly the spectral gap, and `Θ(s) → 0` (`theta_tendsto_zero`).

## 5. Counterexample hunt

* Exhaustive rational check (exact `ℚ` arithmetic): for every `1 ≤ q ≤ 12` and
  every `|a| ≤ 40` with `q ∤ a`, the bound `d(a/q, ℤ) ≥ 1/q` (`distZ_rat_ge`)
  holds; equality occurs at `a = 1`, `q ≥ 2`.
* The naive strengthening "`N(R) ≥ (2√(R/M) − 1)ⁿ`" (dropping the `n` inside the
  square root) is **false**, as an explicit counterexample search shows: for
  `n = 2, m = M = 1` and the half-shift,

  | `R` | `N(R)` | `(2√R − 1)²` |
  |-----|--------|--------------|
  | 25  | 80     | 81           |
  | 49  | 156    | 169          |
  | 100 | 316    | 361          |

  The reason is geometric: a ball of radius `√R` cannot contain a cube of side
  `2√R`.  This is exactly why the proved lower bound
  (`Cycle3.exists_many_solutions`) carries the extra `1/n` inside the square
  root — the inscribed cube has half-side `√(R/(M·n))`.

## 6. OEIS

No OEIS lookup was performed (the working environment is offline), so no OEIS
identifiers are claimed for the sequences `2, 4, 8, …` (minimum multiplicities)
or `2, 4, 6, …` / `4, 12, 32` (counting values).
