# Computational Evidence

All numbers below were produced by exact rational (`ℚ`) evaluation in Lean 4 (computable mirrors
of the `noncomputable` field-valued definitions used in the formal files). Floating point values
are marked as such and are only used to illustrate the `q → 1` limits. **The definitive statements
are the Lean theorems** in `Catalog/Physics/`; the tables here are the exploratory data that guided
and cross-checked them.

No OEIS lookup was performed (no network access); where an integer sequence appeared, a closed form
was guessed from the data and then verified exactly over ℚ, and finally proved in Lean.

---

## 1. Quantum integers `[m]_q = (q^m − q^{−m})/(q − q^{−1})`

Exact values at `q = 2`, `m = 0..6`:

| m | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| `[m]_2` | 0 | 1 | 5/2 | 21/4 | 85/8 | 341/16 | 1365/32 |

Approach to the classical limit (floating point, `q = 1.01`):

`[m]_{1.01}` for `m = 0..6`: `0, 1.000000, 2.000099, 3.000396, 4.000990, 5.001980, 6.003466`.

This is the numerical shadow of `QuantumSL2.qInt_tendsto : [m]_q → m` as `q → 1`.

**Identity check.** The quadratic identity `[a][b] − [a−1][b+1] = [b−a+1]` (`qInt_mul_sub`, the
engine of the `sl₂` commutation relation) was evaluated at `q = 2` for all `0 ≤ a, b ≤ 4`: all 25
residuals are exactly `0`.

## 2. Loop value and Temperley–Lieb coefficients

`δ(A) = −A² − A^{−2}`; at `A = 2`, `δ = −17/4`.

`b_n` (coefficient of the TL generator `e` in `(A·1 + A^{−1}e)^n`) at `A = 2`:

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| `b_n` | 0 | 1/2 | 15/16 | 241/128 | 3855/1024 | 61681/8192 | 986895/65536 |

The numerators `1, 15, 241, 3855, 61681, 986895` satisfy `u_{n+1} = 15u_n + 16u_{n−1}`, and the
guessed closed form `u_n = (16^n − (−1)^n)/17`, i.e.

```
b_n(2) = 4·(16^n − (−1)^n)/(17·8^n)
```

has residual exactly `0` for `n = 0..8`. The parameter-free version

```
b_n(A) = (A^n − (−1)^n A^{−3n})/(A² + A^{−2})
```

has residual exactly `0` for `n = 0..7` at both `A = 2` and `A = 5/3`. This is precisely the
content of the proved theorem `QuantumJones.loopValue_mul_bCoeff`
(`δ·b_n = (−1)^n A^{−3n} − A^n`).

## 3. Kauffman bracket and Jones invariant of the `(2,n)` torus links

Bracket `⟨n⟩ = A^n δ + b_n` and writhe-normalised invariant `V_n = (−A^{−3})^n ⟨n⟩` at `A = 2`:

| n | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| `⟨n⟩` | −17/4 | −8 | −257/16 | −4111/128 | −65777/1024 |
| `V_n` | −17/4 | 1 | −257/1024 | 4111/65536 | −65777/4194304 |

* **Unknot** (`n = 1`): `V_1 = 1` exactly, at `A = 2` and at `A = 3`. (Theorem `jones_unknot`.)
* **Hopf link** (`n = 2`): `⟨2⟩ = −257/16` and `−A^4 − A^{−4} = −257/16` agree exactly.
  (Theorem `bracket_hopf`.)
* **Trefoil** (`n = 3`): `V_3 = 4111/65536`, and evaluating `t + t³ − t⁴` at `t = A^{−4} = 1/16`
  gives `4111/65536` — exact agreement. (Theorem `jones_trefoil`.)
* **Counterexample hunt for "V_n is a knot-independent constant"**: `V_1 = 1 ≠ 4111/65536 = V_3`,
  so the trefoil is distinguished from the unknot already at `A = 2`. This single rational
  witness is what powers the proved separation theorem `jones_trefoil_ne_unknot`.
* **Closed-form residual check**: `δ·⟨n⟩ − (δ²A^n + (−1)^n A^{−3n} − A^n)` is exactly `0` for
  `n = 0..7` at `A = 2` (theorem `bracket_closed_form`).

## 4. Casimir spectrum and its classical limit

Shifted quantum Casimir eigenvalue `C(q,n) = (q^{n+1} + q^{−n−1})/(q−q^{−1})² − (q+q^{−1})/(q−q^{−1})²`
on the `(n+1)`-dimensional module, versus the classical value `n(n+2)/4`:

| n | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| classical `n(n+2)/4` | 0 | 3/4 | 2 | 15/4 | 6 |
| `C(1.1, n)` (float) | 0 | 0.750567 | 2.009091 | 3.787013 | 6.100497 |
| `C(1.01, n)` (float) | 0 | 0.750006 | 2.000099 | 3.750402 | 6.001089 |
| `C(1.0001, n)` (float) | 0 | 0.750000 | 2.000000 | 3.750000 | 6.000000 |

The convergence is the numerical shadow of `QuantumCasimir.casimir_tendsto`. In addition, the
regularised form `casimirReg` matches the shifted eigenvalue with residual exactly `0` at
`q = 11/10` for `n = 0..4` (theorem `casimir_shift_eq`).

*(An earlier, naive shift by `2/(q−q^{−1})²` converges instead to `(n+1)²/4`; the discrepancy of
`1/4` is exactly the difference between the two standard normalisations of the Casimir and was the
reason the regularised form `casimirReg` is stated with the shift `(q+q^{−1})/(q−q^{−1})²`.)*

## 5. Gaussian binomials

Computed from the `q`-Pascal recursion, row `n = 4` (`j = 0..5`):

| q | `[4 ; 0]` | `[4 ; 1]` | `[4 ; 2]` | `[4 ; 3]` | `[4 ; 4]` | `[4 ; 5]` |
|---|---|---|---|---|---|---|
| 1 | 1 | 4 | 6 | 4 | 1 | 0 |
| 2 | 1 | 15 | 35 | 15 | 1 | 0 |
| 3 | 1 | 40 | 130 | 40 | 1 | 0 |

At `q = 1` the row is Pascal's triangle (`qBinom_one_eq_choose`); the palindromic shape is the
reflection symmetry proved in `qBinom_symm`. The row is reproduced exactly (residual `0` at
`q = 2` and `q = 3`) by the polynomials `1, 1+q+q²+q³, 1+q+2q²+q³+q⁴, 1+q+q²+q³, 1, 0`, confirming
the Gaussian-binomial normalisation. The degeneration `[n ; j]_q → C(n,j)` as `q → 1` is proved
analytically in `qBinom_tendsto_choose` (continuity of a polynomial in `q`).

## 6. The scalar recursions behind the `[E, Fᵐ]` formula

The induction proving `E F^{m+1} − F^{m+1} E = [m+1]_q F^m (q^{−m}K − q^{m}K⁻¹)/(q−q⁻¹)`
(`QuantumSerre.E_mul_F_pow_commutator`) rests on the two quantum-integer recursions

```
[m+1]_q · q^{m+2}     + 1 = [m+2]_q · q^{m+1}
[m+1]_q · q^{−(m+2)}  + 1 = [m+2]_q · q^{−(m+1)}
```

Residuals for `m = 0..5` are exactly `0` at `q = 2` (both recursions) and at `q = 5/3` (first
recursion). Both are proved in Lean as `qInt_succ_rec` and `qInt_succ_rec_inv`.
