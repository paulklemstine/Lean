# Computational Evidence — Lyapunov exponents of recurrent EML architectures

All numbers below were produced by `#eval` inside the project's Lean/Mathlib toolchain
(64-bit `Float` arithmetic).  They are *exploratory* data used to select and sanity-check
the conjectures; the statements that survived are proved without any floating point in
`Catalog/Novelty/EMLLyapunovStability.lean`, `Catalog/Novelty/EMLLyapunovTropical.lean`
and `Catalog/Novelty/EMLLyapunovFibonacci.lean`.

## 1. Two-tap linear recurrent unit `h_{t+1} = h_t + h_{t-1}`

Finite-time exponent `λ_T = log(fib T)/T` (state = Fibonacci numbers, OEIS **A000045**:
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, …):

| T   | λ_T      | log φ − λ_T | log(√5)/T |
|-----|----------|-------------|-----------|
| 5   | 0.321888 | 0.159324    | 0.160944  |
| 10  | 0.400733 | 0.080479    | 0.080472  |
| 20  | 0.440976 | 0.040236    | 0.040236  |
| 40  | 0.461094 | 0.020118    | 0.020118  |
| 80  | 0.471153 | 0.010059    | 0.010059  |
| 200 | 0.477188 | 0.004024    | 0.004024  |

`log φ = 0.481212`.  The residual matches `log(√5)/T` to six digits, exactly the
finite-size correction predicted by Binet's formula `fib T = (φ^T − ψ^T)/√5`.  This is the
numerical fingerprint of the proved theorem `tendsto_log_fib`, and it also shows the
convergence is only `O(1/T)` — the exponent is a *limit*, not a finite-time identity.

## 2. Diagonal (gated) cell, `v = (0.9, 1.1)`

`λ_T = log ‖v^T‖_∞ / T` for `T = 1, 2, 5, 10, 50`:

```
0.095310, 0.095310, 0.095310, 0.095310, 0.095310      (= log 1.1 exactly)
```

No transient whatsoever: every finite depth already reports the asymptotic exponent.  This
is what motivated proving the *exact, non-asymptotic* statement `ftle_diagonal`
(`λ_T = log max_i |v_i|` for all `T ≥ 1`) rather than a mere limit.

## 3. Tropical (max-plus) cell, `A = [[0, 3], [−1, 2]]`

Sup-norm distance between two trajectories, `T = 0 … 7`.

Generic perturbation, `x₀ = (0,0)` vs `y₀ = (0.7, −0.4)`:

```
0.7, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4, 0.4
```

Uniform shift, `x₀ = (0,0)` vs `y₀ = (1,1)`:

```
1, 1, 1, 1, 1, 1, 1, 1
```

The state itself is *not* bounded — it grows linearly, at the max cycle mean 2 per step:

```
(0,0) → (3,2) → (5,4) → (7,6) → (9,8) → (11,10)
```

So the trajectory diverges while the separation between trajectories is exactly preserved
along the constant direction and never increases in any direction.  This is precisely the
"exactly critical" behaviour proved in `nlMle_tropCell`: the Lipschitz constant of every
iterate is exactly 1, hence the exponent is exactly 0.

**Counterexample hunt.**  A deterministic pseudo-random sweep (LCG seed 7) over 200 max-plus
`3×3` matrices with entries in `[−5, 5)`, each run to depth 8, measured

* `max over samples of (dist at depth T) − (dist at depth 0)` = `0.000000`
  (no sample ever expanded a distance), and
* `max over samples of |dist at depth T − |c||` for a uniform shift by `c` = `0.000000`
  (saturation is exact at every depth).

No counterexample to non-expansiveness or to saturation was found; both are now theorems,
so none exists.

## 4. Row-stochastic (attention/averaging) cell, `P = [[0.3, 0.7], [0.8, 0.2]]`

Uniform shift `x₀ = (0,0)` vs `(1,1)`:

```
1, 1, 1, 1, 1, 1, 1, 1
```

Generic pair `x₀ = (0,0)` vs `(1,0)`:

```
1, 0.8, 0.65, 0.6, 0.5625, 0.55, 0.540625, 0.5375
```

Contraction transverse to the consensus direction, exact preservation along it: again
Lipschitz constant exactly 1 and exponent exactly 0, as proved in `nlMle_stochCell`.

## 5. What the data ruled out

* *"Tropical cells contract, so their exponent is negative."*  False — the constant-shift
  data is flat at 1 for every depth, which forced the exponent to be exactly 0 rather than
  `< 0`, and led to the saturation half of `optLip_iterate_eq_one`.
* *"Every monotone cell has exponent ≤ 0."*  False — the dilation `x ↦ 2x` is monotone with
  exponent `log 2 = 0.693147`; this is the sharpness result `nlMle_dilationCell`.
* *"The exponent of a linear cell can be read off any single depth."*  False in general
  (Fibonacci table, `O(1/T)` convergence), true for diagonal cells (§2).  This split is
  reflected in the two different theorems proved for the two cases, plus the Fekete
  one-sided certificate `log_spectralRadius_le_ftle`, which *is* valid at every finite
  depth.

## 6. Residual cells: the critical `1/T` scaling (evidence for §7)

`#eval` of `(1 + c/T)^T` against `exp c` for `c = 1`, doubling the depth:

| `T` | `(1 + 1/T)^T` | `exp 1` |
|-----|---------------|---------|
| 2   | 2.250000      | 2.718282 |
| 4   | 2.441406      | 2.718282 |
| 8   | 2.565785      | 2.718282 |
| 16  | 2.637928      | 2.718282 |
| 32  | 2.676990      | 2.718282 |
| 64  | 2.697345      | 2.718282 |

The depth-`T` Lipschitz budget of a residual EML stack with `‖W‖ ≤ 1/T` stays uniformly
below `e` and increases monotonically towards it.  This is the numerical content of
`dist_resCell_iterate_le_exp` and `norm_fderiv_resCell_iterate_le_exp`: the bound is
depth-uniform *and* asymptotically attained, so `exp c` cannot be replaced by anything
smaller.

## 7. Skip connections: an exponent of exactly `log 2` (evidence for §8)

The residual tropical cell on two coordinates, `h x = (x₀ + max(x₀,x₁), x₁ + max(x₀,x₁))`,
started from `x = (1,0)` and `y = (0,0)`; `d_T` is the sup distance after `T` steps and
`(1/T) log d_T` the measured finite-depth exponent:

| `T` | `d_T` | `(1/T) log d_T` | `log 2` |
|-----|-------|-----------------|---------|
| 1 | 2   | 0.693147 | 0.693147 |
| 2 | 4   | 0.693147 | 0.693147 |
| 3 | 8   | 0.693147 | 0.693147 |
| 4 | 16  | 0.693147 | 0.693147 |
| 5 | 32  | 0.693147 | 0.693147 |
| 6 | 64  | 0.693147 | 0.693147 |
| 7 | 128 | 0.693147 | 0.693147 |
| 8 | 256 | 0.693147 | 0.693147 |

The measured exponent is `log 2` at *every* depth, with no transient — exactly the
behaviour that a grade-`2` cell must have.  This table is what suggested the graded
homogeneity framework of §8 and was then upgraded to the proofs
`optLip_iterate_eq_of_monotone_graded`, `nlMle_eq_log_of_monotone_graded` and
`nlMle_skip_eq_log_two`.  It also rules out the guess *"a skip connection perturbs the
exponent by an amount depending on the branch weights"*: the data are weight-independent,
which is exactly what the proof delivers.
