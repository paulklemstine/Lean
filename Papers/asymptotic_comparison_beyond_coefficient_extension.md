# Computational Evidence

All computations below were run inside Lean 4 (`#eval`, `Float` arithmetic) before the
formal proofs were written. They are *evidence*, not verification: the verified
statements are the `theorem`s in `Catalog/NumberTheory/AsymptoticGerm*.lean`.

Notation: a bounded coefficient sequence `a : ℕ → ℝ` with `|a n| ≤ M` is evaluated at
`t = 1/x` by `psum a t N = ∑_{n<N} a n tⁿ`, approximating the germ
`eval a x = ∑' n, a n x⁻ⁿ`.

---

## 1. Sanity check of the evaluation map

`a n = (-1)ⁿ` (so `M = 1`). Closed form: `eval a x = 1/(1 + 1/x) = x/(x+1)`.

| `x` | `psum a (1/x) 200` | `x/(x+1)` |
|-----|--------------------|-----------|
| 2   | 0.666667           | 0.666667  |
| 4   | 0.800000           | 0.800000  |
| 10  | 0.909091           | 0.909091  |
| 100 | 0.990099           | 0.990099  |

Agreement to 6 digits. The interpretation `BddSeries.eval` is the expected one.

---

## 2. The leading-monomial sign threshold is **sharp**

Take `a 0 = 0`, `a 1 = -1`, `a n = 1` for `n ≥ 2`; so `M = 1`, the leading rank is
`n₀ = 1` and `a n₀ = -1 < 0`. The theorem
`BddSeries.eventually_neg_of_leading` gives negativity for
`x > (M + |a n₀|)/|a n₀| = 2`.

| `x`  | `psum a (1/x) 400` |
|------|--------------------|
| 1.5  | **+0.666667**      |
| 2.0  | 0.000000           |
| 3.0  | −0.166667          |
| 5.0  | −0.150000          |
| 10   | −0.088889          |
| 50   | −0.019592          |

Exactly: `eval a x = -t + t²/(1-t)` with `t = 1/x`, which vanishes precisely at
`t = 1/2`, i.e. `x = 2`, and is positive for `x < 2`. So the threshold
`(bound + |a n₀|)/|a n₀|` extracted in the proof of
`BddSeries.eventually_pos_of_leading` cannot be improved for this family: the
counterexample hunt for "the leading monomial controls the sign *everywhere*"
succeeds, and only the *eventual* statement survives. This is why the formal
statement is an `∀ᶠ x in atTop` and not a pointwise claim.

---

## 3. The tail bound is an equality in the extremal case

For `a n = 1` (so `M = 1`) the bound of `BddSeries.tail_bound`,
`M · tᵏ / (1 - t)`, is compared with the exact tail
`(1-t)⁻¹ - ∑_{n<k} tⁿ`.

| `t`   | `k` | bound `tᵏ/(1-t)` | exact tail |
|-------|-----|------------------|------------|
| 0.5   | 3   | 0.250000         | 0.250000   |
| 0.25  | 5   | 0.001302         | 0.001302   |
| 0.1   | 4   | 0.000111         | 0.000111   |

The estimate is attained (all coefficients equal to the bound), confirming that no
constant factor can be shaved.

---

## 4. Flatness of `e^{-x}` against every rank

Values of `xⁿ · e^{-x}`:

| `n` | `x = 10`   | `x = 20`  | `x = 40` |
|-----|------------|-----------|----------|
| 1   | 0.000454   | 4.1e−8    | ~0       |
| 2   | 0.004540   | 8.2e−7    | ~0       |
| 3   | 0.045400   | 1.6e−5    | ~0       |
| 5   | 4.539993   | 0.006596  | ~0       |
| 8   | 4539.99    | 52.7655   | 0.000028 |

For each fixed `n` the column tends to `0`; the onset of decay moves right with `n`.
This is the numerical shadow of `exp_neg_isLittleO_monoN`: `e^{-x}` is negligible
against *every* rank, but not uniformly in the rank. Hence a nonzero function whose
asymptotic expansion is identically zero — the counterexample formalized in
`expansion_not_germ_injective`.

---

## 5. OEIS

No integer sequence is produced by this project (the objects are arbitrary bounded
real coefficient sequences), so no OEIS lookup applies.
