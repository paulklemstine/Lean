# Computational evidence for the chart-calculus exactness programme

All numbers below were produced inside Lean (`#eval`) against the definitions that appear
in `Catalog/Bridges/Chart*.lean`, so they refer to exactly the objects that the theorems
talk about.  Items marked **[kernel-verified]** are additionally checked by the Lean kernel
inside a proof (`decide`), not merely evaluated.

## 1. How many chart points does degree `d` cost?

Grid size `(d+1)^n` used by `NExpr.degree_exact`, versus the dimension
`C(n+d, n)` of the space of polynomials of total degree `≤ d`
(the lower bound proved in `ChartCalculus.uniqueness_set_card_ge`).

| n | d | grid `(d+1)^n` | dimension `C(n+d,n)` |
|---|---|---------------:|---------------------:|
| 2 | 0 | 1  | 1  |
| 2 | 1 | 4  | 3  |
| 2 | 2 | 9  | 6  |
| 2 | 3 | 16 | 10 |
| 2 | 4 | 25 | 15 |
| 3 | 1 | 8  | 4  |
| 3 | 2 | 27 | 10 |
| 3 | 3 | 64 | 20 |
| 3 | 4 | 125| 35 |

The two columns agree exactly when `n = 1` (`(d+1)` versus `C(1+d,1) = d+1`), which is why
`ChartCalculus.card_monomialsLE_one_var` together with
`ChartCalculus.one_var_uniqueness_set_card_ge` gives *optimality* of the chart grid in one
variable, and only a gap for `n ≥ 2`.  Closing this gap is Direction 1 of
`FUTURE_DIRECTIONS.md`.

## 2. Multidegree beats total degree

Boolean cube `2^n` versus the total-degree grid `(n+1)^n` that a multilinear expression of
total degree `n` would otherwise require (`NExpr.multilinear_exact` versus
`NExpr.degree_exact`):

| n | `2^n` | `(n+1)^n` |
|---|------:|----------:|
| 0 | 1  | 1   |
| 1 | 2  | 2   |
| 2 | 4  | 9   |
| 3 | 8  | 64  |
| 4 | 16 | 625 |

Formalised as `NExpr.boolean_cube_beats_total_degree_grid`.

## 3. Counterexample hunt: is the grid size `d+1` really needed?

Yes.  With `rootProd d = (x₀-0)(x₀-1)⋯(x₀-(d-1))` (degree `d`):

* evaluation at every point of the `d`-point grid `{0,…,d-1}`:
  `d = 1 : [0]`, `d = 2 : [0,0]`, `d = 3 : [0,0,0]`, `d = 4 : [0,0,0,0]` — identically zero;
* evaluation at the *next* point `x₀ = d`:

| d | `rootProd d` at `x₀ = d` | `d!` |
|---|-------------------------:|-----:|
| 0 | 1   | 1   |
| 1 | 1   | 1   |
| 2 | 2   | 2   |
| 3 | 6   | 6   |
| 4 | 24  | 24  |
| 5 | 120 | 120 |
| 6 | 720 | 720 |

So a `d`-point grid is always defeated by a degree-`d` expression, and the value of the
witness there is exactly `d!` (the sequence `1, 1, 2, 6, 24, 120, 720` is OEIS A000142).
This is `NExpr.grid_bound_sharp`; the theorem proves nonvanishing at `x₀ = d` (via
`Finset.prod_ne_zero_iff`) rather than the exact factorial value, which is all the
sharpness statement needs.

## 4. Kernel-verified grid certificates **[kernel-verified]**

The following identities were established by *evaluating both sides at integer grid points
only* and then transporting the result to every commutative ring
(`NExpr.universal_of_gridCert`):

| identity | variables | degree | grid points checked | theorem |
|---|---|---|---|---|
| `(a+b)³ = a³+3a²b+3ab²+b³` | 2 | 3 | `4² = 16` | `NExpr.cube_identity` |
| `(a+b)²(a-b)² = (a²-b²)²` | 2 | 4 | `5² = 25` | `NExpr.quartic_identity` |
| `a³+b³+c³-3abc = (a+b+c)(a²+b²+c²-ab-bc-ca)` | 3 | 3 | `4³ = 64` | `NExpr.sym_identity` |
| `(1-a)(1-b) = 1-a-b+ab` | 2 | multilinear | `2² = 4` | `NExpr.incExcl_identity` |

Each check is discharged by `decide` (kernel reduction over `ℤ`), never by
`native_decide`.

## 5. What the evidence did *not* find

No counterexample was found to the statement that the standard chart grid `{0,…,d}^n`
certifies degree-`≤ d` identities — as expected, since that statement is now a theorem
(`NExpr.degree_exact`).  The search for smaller *product* grids does produce
counterexamples immediately (Section 3).  Smaller *non-product* uniqueness sets of size
between `C(n+d,n)` and `(d+1)^n` do exist, and the optimum is now known: see Section 6.

## 6. Simplex-lattice node counts **[theorem-verified]**

The simplex lattice `S(n,d) = {a ∈ ℕⁿ : ∑ aᵢ ≤ d}` is a uniqueness set for total degree
`≤ d` (`simplex_unisolvent`) and has exactly `C(n+d, n)` points (`card_simplexTuples`, a
theorem, proved by a fiberwise decomposition plus the hockey-stick identity — not by
sampling).  The saving over the box grid `{0,…,d}^n`:

| n | d | simplex points `C(n+d,n)` | box points `(d+1)^n` | ratio |
|---|---|---|---|---|
| 2 | 2 | 6 | 9 | 0.67 |
| 2 | 3 | 10 | 16 | 0.63 |
| 3 | 3 | 20 | 64 | 0.31 |
| 4 | 3 | 35 | 256 | 0.14 |
| 5 | 3 | 56 | 1024 | 0.055 |
| 6 | 3 | 84 | 4096 | 0.021 |

For fixed `d` the simplex count grows polynomially in `n` (degree `d`) while the box count
grows exponentially, so the ratio tends to `0`; the rows `(n,d) = (2,3)` and `(3,3)` are
kernel-checked in Lean (`card_simplexTuples_two_three`, `card_simplexTuples_three_three`),
and the general strict inequality for `n ≥ 2`, `d ≥ 1` is `card_simplexNodes_lt_grid`.

The two identities below were re-proved from simplex certificates only:

| identity | variables | degree | simplex points | box points | theorem |
|---|---|---|---|---|---|
| `(a+b)³ = a³+3a²b+3ab²+b³` | 2 | 3 | `10` | `16` | `NExpr.cube_identity_simplex` |
| `a³+b³+c³-3abc = (a+b+c)(a²+b²+c²-ab-bc-ca)` | 3 | 3 | `20` | `64` | `NExpr.sym_identity_simplex` |

Both checks are discharged by `decide` (kernel reduction over `ℤ`), never by
`native_decide`.

## 7. Support-adapted (downset) node counts **[theorem-verified where marked]**

The latest cycle replaces the degree filtration by the *support* filtration: any lower set
`D ⊆ ℕⁿ` of exponents is a uniqueness set for the polynomials supported in it
(`downset_unisolvent`), it has exactly `#D` nodes, and no smaller test set works
(`downsetNodes_is_minimum_uniqueness_set`).  Weighted sublevel sets
`{a : ∑ wᵢaᵢ ≤ d}` are the computable family used in the reflective layer.

Node counts (`#eval` of the corresponding `Finset` in Lean; the first row is additionally a
kernel-checked theorem, `card_weightedTuples_example` and `card_simplexTuples_two_four`):

| n | weights `w` | `d` | weighted nodes | total-degree simplex `C(n+d,n)` | box `(d+1)^n` |
|---|---|---|---|---|---|
| 2 | (1,2) | 4 | **9** | **15** | 25 |
| 2 | (1,2) | 6 | 16 | 28 | 49 |
| 2 | (1,3) | 6 | 12 | 28 | 49 |
| 3 | (1,2,3) | 6 | 23 | 84 | 343 |

The saving grows with the weights: a quasi-homogeneous identity of weighted degree `d` is
decided by a node set whose size is governed by `d^n / (n! ∏ wᵢ)` rather than by `C(n+d,n)`.

Worked certificate re-proved this way:

| identity | variables | weights | weighted nodes | simplex nodes | box nodes | theorem |
|---|---|---|---|---|---|---|
| `(a²+b)(a²−b) = a⁴ − b²` | 2 | (1,2) | `9` | `15` | `25` | `NExpr.quasi_identity` |

The check is discharged by `decide` (kernel reduction over `ℤ`), never by `native_decide`.

**Counterexample hunt (successful).** Weighted sublevel sets do *not* exhaust the downsets:
for the downset `{(a,0) : a ≤ 2} ∪ {(0,b) : b ≤ 2}` every weight vector `w` and bound `d`
with `2w₀ ≤ d` and `2w₁ ≤ d` also admits `(1,1)`, since `w₀ + w₁ ≤ max(2w₀, 2w₁) ≤ d`.  This
is formalised as `exists_downset_not_weighted_sublevel`, and it is the reason the syntactic
weighted degree is strictly weaker than the semantic downset theorem — the gap that
Direction 3 of `FUTURE_DIRECTIONS.md` proposes to close.
