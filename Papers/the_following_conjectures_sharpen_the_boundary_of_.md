# Computational Evidence

All numbers below are **kernel-checked inside Lean**, not computed in a scratch script.
Polynomials over `ℚ` are not executable in Lean 4 / Mathlib (`Polynomial.C` carries no
compiled code), so `#eval` is unavailable; every computation is therefore recorded as a
proved theorem in `Catalog/Geometry/RischWorkedExamples.lean` and
`Catalog/Geometry/RischSplitIntegration.lean`.

## 1. Small-case residue computations

Denominator `x (x-1)`, numerator `1` (`RischSplit.residue_example_zero/one`):

| pole | residue |
| --- | --- |
| `0` | `-1` |
| `1` | `1` |

Denominator `x (x-1) (x-2)` (`RischExamples.residue_three_poles_*`):

| numerator | residue at `0` | at `1` | at `2` | sum |
| --- | --- | --- | --- | --- |
| `1`   | `1/2` | `-1` | `1/2` | `0` |
| `x²`  | `0`   | `-1` | `2`   | `1` |

**Pattern found.** The residue sum is `0` in the first row and `1` in the second. The
data suggested, and `RischResidue.residue_sum` now proves, that for `n` distinct poles
the residues always add up to the coefficient of `x^{n-1}` in the numerator. The
classical "residues sum to zero" statement is the special case `deg p ≤ n - 2`.

## 2. Risch differential equation `q' + a q = p`

Solved instances (`RischExamples.risch_de_example_one/two`):

| `a` | `p`  | `q`         |
| --- | ---- | ----------- |
| `1` | `x²` | `x² - 2x + 2` |
| `2` | `x`  | `x/2 - 1/4` |

Both were found by the triangular back-substitution `q ← (leading coeff)/a · x^d + …`
that the existence proof `RischResidue.risch_de_poly_solvable` formalizes, and both are
verified by `ring`-level computation in Lean. Uniqueness of the solution is
`RischResidue.risch_de_poly_unique`.

## 3. Counterexample hunt

Two universal statements were tested for failure and *survived* as theorems:

* "every rational integrand with split denominator is elementarily integrable" —
  no counterexample; proved in full (`RischSplit.split_rational_has_EML_primitive`).
* "the Risch differential equation always has a rational solution" — **fails**. The
  quadratic exponent gives an explicit failure: `R' + 2xR = 1` has no rational solution
  (`RischGaussian.no_rational_solution_gaussian`). The search that produced this was a
  degree count: for polynomial `q ≠ 0` of degree `d`, `q' + 2xq` has degree `d+1 ≥ 1`,
  so it can never equal `1`; the rational case then reduces to the polynomial case by an
  `(X-a)`-adic valuation argument at any denominator root.

## 4. Boundary probing

`x² + 1` does not split over `ℚ` (`RischSplit.not_splits_X_sq_add_one`), so
`1/(x²+1)` sits strictly outside the hypothesis of the split-denominator integration
theorem — its antiderivative `arctan` needs either a complex logarithm or a new
constant-field extension. This marks the exact boundary of the current development.


---

# Addendum (continuation cycle)

The following data were produced while extending the development with
`Catalog/Geometry/RischLiouvilleDichotomy.lean`,
`Catalog/Geometry/RischLogIndependence.lean` and
`Catalog/Geometry/RischArctanBoundary.lean`.  As before, polynomials over `ℚ`, `ℝ` and `ℂ`
are not executable in Lean, so each item below is a kernel-checked *theorem*, not `#eval`
output.

## 5. Degree table for the exponential Risch equation `q' + g'·q = p`

For `q ≠ 0` one has `deg (q' + g'q) = deg q + deg g - 1` exactly
(`RischDichotomy.natDegree_risch_lhs`).  Tabulating the smallest achievable left-hand-side
degree against `deg g`:

| `deg g` | smallest `deg (q' + g'q)` over `q ≠ 0` | equation `… = 1` solvable? |
| ------- | -------------------------------------- | -------------------------- |
| `1`     | `0`                                    | yes (`q` constant)         |
| `2`     | `1`                                    | no                         |
| `3`     | `2`                                    | no                         |
| `d ≥ 2` | `d - 1`                                | no                         |

The `deg g = 1` row is `RischDichotomy.exp_linear_has_rational_exponential_primitive`; every
row with `deg g ≥ 2` is `RischDichotomy.expPoly_no_rational_exponential_primitive` with
`p = 1`, and `exp(x³)` is spelled out in
`RischDichotomy.exp_cube_no_rational_exponential_primitive`.  The right-hand column becomes
"yes" again as soon as `deg p = deg g - 1` (`RischDichotomy.degree_hypothesis_sharp`), which
is why the hypothesis of the obstruction theorem reads `deg p + 1 < deg g`.

## 6. Pole-order counting for derivatives

Writing `v_a` for the `(X-a)`-adic valuation and `A/B` in lowest terms with `v_a(B) = k`:

| `k = v_a(B)` | `v_a(A'B - AB')` | pole order of `(A/B)'` at `a` |
| ------------ | ---------------- | ----------------------------- |
| `0`          | `≥ 0`            | none                          |
| `1`          | `0`              | `2`                           |
| `2`          | `1`              | `3`                           |
| `k ≥ 1`      | `k - 1`          | `k + 1`                       |

Pole order `1` never occurs — this is the content of
`RischLogIndep.simple_pole_not_derivative`, and it is what forbids trading a logarithm for
a rational function.

## 7. Counterexample hunt, second round

* "Some rational function with a simple pole has a rational antiderivative" — **no
  instance exists**; refuted in general (`RischLogIndep.real_simple_pole_has_no_rational_primitive`),
  with `1/(x(x-1))` as an explicit witness of the refuted pattern
  (`RischLogIndep.inv_x_mul_x_sub_one_no_rational_primitive`).
* "Some combination of real logarithms and a rational function integrates `1/(x²+1)`" —
  **no instance exists** (`RischArctan.arctan_not_rational_plus_real_logs`).  The search
  that produced the proof was a residue count at the complex point `i`: the integrand has
  residue `1/(2i)` there, real logarithms contribute residues only at real points, and
  derivatives contribute none.
* "Every `exp(g)` with `deg g ≥ 2` fails" — survived for `p = 1`; **fails** for general
  numerators, since `g'·exp(g)` integrates to `exp(g)`.  This is what pinned down the exact
  hypothesis `deg p + 1 < deg g`.

---

# Addendum II (irreducible-factor cycle)

Data gathered while proving `Catalog/Geometry/RischIrreducibleFactor.lean`.  As in the
earlier addenda, polynomials over `ℚ`, `ℝ` and `ℂ` are not executable in Lean, so every
entry below is a kernel-checked *theorem*, not `#eval` output.

## 8. Pole order along an irreducible factor `F`

Let `A/B` be in lowest terms and let `k` be the `F`-adic valuation of `B`, so
`B = Fᵏ·S` with `F ∤ S`.  Reducing the Wronskian modulo `F`:

| `k = v_F(B)` | `A'B - AB'` factors as | `v_F(A'B - AB')` | `F`-pole order of `(A/B)'` |
| ------------ | ---------------------- | ---------------- | -------------------------- |
| `0`          | —                      | `≥ 0`            | none                       |
| `1`          | `F⁰·T`, `T ≡ -A F' S`  | `0`              | `2`                        |
| `2`          | `F¹·T`, `T ≡ -2A F' S` | `1`              | `3`                        |
| `k ≥ 1`      | `F^(k-1)·T`, `T ≡ -k A F' S` | `k - 1`    | `k + 1`                    |

Order `1` never occurs, because `F` divides none of `k` (characteristic zero), `A`
(coprimality), `F'` (degree), `S` (definition of `k`).  This is
`RischIrred.irreducible_pole_not_derivative`, and it specialises to the previous cycle's
table for `F = X - a`.

## 9. Hermite reduction coefficients at `Q = x² + bx + c`, `Δ = 4c - b² > 0`

Solving `u·Q + d·Q - k·(ux + v)·Q' = αx + β` identically in `x`
(`RischIrred.hermite_coefficients`) gives the closed form

| unknown | value                    |
| ------- | ------------------------ |
| `u`     | `(2β - αb)/(kΔ)`         |
| `v`     | `(ub - α/k)/2`           |
| `d`     | `u·(2k - 1)`             |

and hence `d/dx[(ux+v)/Qᵏ] = (αx+β)/Q^(k+1) - d/Qᵏ` (`RischIrred.hermite_step`): one step
lowers the pole order by one and leaves a *constant* numerator.  Iterating from `Q^(j+1)`
down to `Q` and finishing with

`∫ (αx+β)/Q = (α/2)·log Q + ((2β - αb)/√Δ)·arctan((2x+b)/√Δ)`

yields `RischIrred.quadratic_pow_has_log_arctan_primitive`.  Sanity checks contained in
the formal proofs: `α = 0, β = 1, b = 0, c = 1` gives `√Δ = 2` and the primitive
`arctan x` (`RischIrred.arctan_primitive`); `2β = αb` gives `u = 0`, i.e. no arctangent
term is needed and the primitive is `(α/2)·log Q`.

## 10. Counterexample hunt, third round

* "Some rational function with an order-one pole along an irreducible factor is a
  derivative" — **no instance exists**, over any field of characteristic zero
  (`RischIrred.irreducible_pole_not_derivative`).  The hypothesis `CharZero` enters the
  proof at exactly one place, to know that the multiplicity `k` is nonzero in the ground
  field; we did not investigate positive characteristic.
* "Some rational function plus real logarithms integrates `(αx+β)/(x²+bx+c)` with negative
  discriminant" — **no instance exists** (`RischIrred.quadratic_pole_not_rational_plus_logs`),
  for every numerator except the zero one.
* "The arctangent term is always needed" — **false**: at `2β = αb` the coefficient `μ`
  vanishes and a logarithm suffices.  This is why the negative theorems above are stated
  for the *rational* language, and why the boundary theorem
  `RischIrred.irreducible_quadratic_boundary` asserts necessity of the pair
  `{log, arctan}` rather than of `arctan` alone.
