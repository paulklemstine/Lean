# Computational Evidence — LWE Hardness Reductions (Regev parameters)

This note records the small-case checks that guided the formalization of the
worst-case (GapSVP/SIVP) → LWE reduction and its parameter regime.

## 1. The parameter condition `α·q ≥ 2√n`

Regev's reduction requires the Gaussian noise width `α·q` to exceed the smoothing
scale `≈ 2√n`. Sample admissible triples (taking `α = 1/M` inverse-polynomial):

| n    | √n (≈)  | 2√n (≈) | M (=1/α) | q (min ≈ 2√n·M) | α·q  |
|------|---------|---------|----------|-----------------|------|
| 4    | 2.000   | 4.000   | 4        | 16              | 4.0  |
| 16   | 4.000   | 8.000   | 16       | 128             | 8.0  |
| 64   | 8.000   | 16.000  | 64       | 1024            | 16.0 |
| 256  | 16.000  | 32.000  | 256      | 8192            | 32.0 |

In every row `α·q = 2√n` exactly at the boundary, and any larger `q` keeps the
condition satisfied — consistent with `modulus_lower_bound` (`q ≥ 2√n` when
`α ≤ 1`) and `smoothing_condition` (`√n ≤ α·q/2`).

## 2. Approximation factor vs. modulus trade-off

With `γ = C·n/α` and `α = 1/M`, the factor is the polynomial `γ = C·n·M`
(`approx_factor_eq`). The trade-off theorem predicts `γ ≤ C·√n·q/2`. Check at the
boundary `q = 2√n·M` (`C = 1`):

| n   | M   | γ = n·M | C·√n·q/2 = √n·(2√n·M)/2 = n·M | γ ≤ bound? |
|-----|-----|---------|------------------------------|------------|
| 4   | 4   | 16      | 16                           | ✓ (tight)  |
| 16  | 16  | 256     | 256                          | ✓ (tight)  |
| 64  | 64  | 4096    | 4096                         | ✓ (tight)  |

The bound is tight exactly at the boundary `α·q = 2√n`, confirming
`approx_modulus_tradeoff` is sharp (equality is attained, so no stronger constant
than `C/2` is possible).

## 3. Gaussian weight `ρ_s(x) = exp(-π x²/s²)` — shape

Values of `ρ₁(x)` (peak at 0, even, monotone decay):

| x    | ρ₁(x) = exp(-π x²) |
|------|--------------------|
| 0.0  | 1.000000           |
| 0.25 | 0.821725           |
| 0.5  | 0.455938           |
| 1.0  | 0.043214           |
| 2.0  | 0.00000349         |

- Peak `ρ₁(0)=1` ⇒ `rho_zero`, and all values in `(0,1]` ⇒ `rho_pos`,`rho_le_one`.
- `ρ₁(-x)=ρ₁(x)` ⇒ `rho_even`; strictly decreasing in `|x|` ⇒ `rho_antitone_abs`.
- Scaling: `ρ_s(x) = ρ₁(x/s)`, e.g. `ρ₂(1) = ρ₁(0.5) = 0.4559` ⇒ `rho_scale`.

## 4. Discrete Gaussian as a probability law

Support `pts = {-1, 0, 1}`, width `s = 1`:
`mass = ρ(−1)+ρ(0)+ρ(1) = 0.043214 + 1 + 0.043214 = 1.086428`.
Normalised masses: `0.039776, 0.920448, 0.039776`, which sum to `1.000000`
⇒ `discreteGaussian_sum_one`, each in `[0,1]` ⇒ the `nonneg`/`le_one` lemmas.

## 5. Counterexample hunt

- Dropping `α ≤ 1` from `modulus_lower_bound`: with `α = 4, q = 1, n = 1`,
  `α·q = 4 ≥ 2 = 2√n` but `q = 1 < 2` — so the hypothesis `α ≤ 1` is genuinely
  load-bearing (kept in the statement).
- Dropping `n > 0` from `approx_modulus_tradeoff`: at `n = 0`, `√n = 0`, the
  right side is `0` while `γ = C·0/α = 0`, degenerate; the theorem is stated with
  `hn : 0 < n` to stay in the meaningful regime.
- `gapSVP_promise_disjoint` with `γ < 1` (e.g. `γ = 1/2, β = 2, λ₁ = 1.5`): then
  YES (`1.5 ≤ 2`) and NO (`0.5·2 = 1 < 1.5`) both hold — so `γ ≥ 1` is required,
  and is present in the statement.

No counterexample was found to any theorem as stated; the boundary probes instead
pinned down exactly which hypotheses are necessary.
