# Computational evidence for the `O(N)` `ε`-expansion cycle

All numbers below were produced with Lean `#eval` in a scratch file (exact `ℚ`
arithmetic where indicated, `Float` where a transcendental root had to be
approximated).  They are *exploratory* data used to pick and sanity-check the
conjectures; the statements that survived are proved in the `.lean` files of
`Catalog/Physics/` and only those are verified results.

Normalisation: `β_N(ε,g) = -εg + ((N+8)/3) g²`, so that `N = 1` reproduces the
catalog file `WilsonEpsilonExpansion.lean` exactly (`3 = (1+8)/3`).

## 1. The `η`-coefficient `η₂(N) = (N+2)/(2(N+8)²)` (exact rationals)

| `N` | 0 | 1 | 2 | 3 | **4** | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `η₂` | 1/64 | 1/54 | 1/50 | 5/242 | **1/48** | 7/338 | 1/49 | 1/50 | 5/256 | 11/578 | 1/54 | 13/722 | 7/400 |

The sequence rises to `N = 4` and falls afterwards, and the value at `N = 4` is
`1/48`.  This suggested — and we then proved — that `η₂` attains its maximum on
the whole admissible range exactly at `N = 4`
(`etaCoeff_le_of_gt_neg_eight`, `etaCoeff_eq_max_iff`).  Note the exact
coincidences `η₂(2) = η₂(7) = 1/50` and `η₂(1) = η₂(10) = 1/54`, reflecting the
reflection symmetry of `(N+2)/(N+8)²` about its critical point.

The `N = 1` entry `1/54` is exactly Wilson's coefficient used in the catalog
file, which is the consistency check that fixed the normalisation.

## 2. `ν`- and `α`-coefficients (exact rationals)

| `N` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 8 | 10 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|
| `ν₁` | 1/16 | 1/12 | 1/10 | 5/44 | 1/8 | 7/52 | 1/7 | 5/32 | 1/6 | 7/40 |
| `α₁` | 1/4 | 1/6 | 1/10 | 1/22 | 0 | −1/26 | −1/14 | −1/8 | −1/6 | −1/5 |

`ν₁` increases monotonically towards `1/4` (the spherical-model value) and `α₁`
decreases through **exactly zero at `N = 4`** — the classical statement that the
specific heat stops diverging above four components.  Both are now theorems
(`nuCoeff_strictMono`, `nuCoeff_bounds`, `alphaCoeff_strictAnti`,
`alpha_sign_flip_at_four`).

## 3. Counterexample hunt for the scaling relations (exact rationals)

Evaluating `1 + γ/β - (3+ε)` minus the conjectured closed form
`3ε²/(N+8-3ε)` at `(N,ε) ∈ {(0,1/10), (1,1/2), (3,1), (10,1/4)}` gives
`0, 0, 0, 0` — no discrepancy anywhere.  This is what motivated proving the
Widom deficit as an *identity* rather than an inequality
(`widom_deficit`); the analogous exact deficits for Josephson and Fisher were
found the same way.  No counterexample was found to any relation that is
asserted in the Lean files.

## 4. Two-loop fixed point: numerical root versus the predicted expansion

Newton's method (Float, 30 iterations) on `c x² - a x + ε` with
`a = (N+8)/3`, `c = (3N+14)/9`, compared with the prediction
`3ε/(N+8) + 27cε²/(N+8)³`:

`ε = 1/2`:

| `N` | numerical root | prediction | difference | bound `ε³` |
|---|---|---|---|---|
| 0 | 0.214286 | 0.208008 | 0.006278 | 0.125 |
| 1 | 0.189207 | 0.184156 | 0.005051 | 0.125 |
| 2 | 0.169052 | 0.165000 | 0.004052 | 0.125 |
| 3 | 0.152592 | 0.149324 | 0.003268 | 0.125 |
| 10 | 0.089922 | 0.088992 | 0.000930 | 0.125 |

`ε = 4/7` (the edge of the admissible window in `twoLoop_fixedPoint_uniform`):

| `N` | numerical root | prediction | difference | bound `ε³` |
|---|---|---|---|---|
| 0 | 0.251051 | 0.241071 | 0.009980 | 0.1866 |
| 1 | 0.221316 | 0.213320 | 0.007996 | 0.1866 |
| 2 | 0.197409 | 0.191020 | 0.006388 | 0.1866 |
| 3 | 0.177903 | 0.172772 | 0.005131 | 0.1866 |
| 10 | 0.104062 | 0.102629 | 0.001433 | 0.1866 |

Two features guided the formalisation: the difference is **always positive**
(the two-loop coupling exceeds the truncated expansion, because the neglected
terms have a definite sign) and it **decreases with `N`**.  Both are reflected
in the proved statement
`0 ≤ g* - (ε/a + cε²/a³) ≤ 12c²ε³/a⁵` (`root_expansion`), whose `N`-uniform
corollary is `twoLoop_fixedPoint_uniform`.

## 5. OEIS

The numerators/denominators of `η₂(N)` are values of a rational function rather
than an interesting integer sequence, and no OEIS entry was sought or used.

## Status

Sections 1–4 are exploratory computations, not verified claims.  Every
statement they suggested has been restated and proved in Lean; the tables above
are reported only as the evidence that motivated those statements.
