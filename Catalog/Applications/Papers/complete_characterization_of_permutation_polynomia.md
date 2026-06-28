# Computational Evidence — Permutation polynomials `x^q + b x^2 + c x + d` over `F_{q^2}`

This note records the small-case evidence that motivated, and is now fully
*machine-verified by*, the Lean files

* `Catalog/Novelty/PermutationPolynomialFq2.lean`
* `Catalog/Novelty/PermutationPolynomialCounting.lean`

The central object is the *linearized* (Frobenius) map
`L_{a,c}(x) = a·x^p + c·x` over a field `K` with `|K| = p^2` (prime base case
`q = p`). The proven criterion is:

> `L_{a,c}` is a permutation of `K`  ⇔  `a^(p+1) ≠ c^(p+1)`  (i.e. `N(a) ≠ N(c)`),

where `N(z) = z^(p+1) = z·z^p` is the field norm `K → F_p`.

## 1. Small-case calculations

### `p = 2`, `K = F_4 = {0, 1, ω, ω²}` with `ω² = ω + 1`, `ω³ = 1`

Norm `N(z) = z^3 ∈ {0, 1}`: `N(0) = 0`, `N(1) = N(ω) = N(ω²) = 1`.

Map `x ↦ x^2 + c·x` (`a = 1`, so `N(a) = 1`). Criterion: permutation ⇔
`N(c) ≠ 1` ⇔ `c = 0`.

| c   | N(c) | permutation? (criterion) | direct check `x²+cx` on {0,1,ω,ω²}             |
|-----|------|--------------------------|------------------------------------------------|
| 0   | 0    | YES                      | x↦x²: 0,1,ω²,ω — bijection ✓                    |
| 1   | 1    | NO                       | x↦x²+x: 0,0,1,1 — collapses (0,1↦0) ✗          |
| ω   | 1    | NO                       | x↦x²+ωx: 0,1+ω=ω²,ω²+ω²=0,… two zeros ✗         |
| ω²  | 1    | NO                       | similarly 2-to-1 ✗                              |

Exactly **`p + 1 = 3`** values of `c` are exceptional — matches
`card_norm_one`. Exactly `p² − (p+1) = 1` value gives a permutation — matches
`card_permutation_coeffs`.

### `p = 3`, `K = F_9`

`|K| = 9`, `|Kˣ| = 8 = (p−1)(p+1) = 2·4`. Norm `N(z) = z^4`; the norm-1 set
`{c : c^4 = 1}` is the unique subgroup of order `p + 1 = 4` of the cyclic group
`Kˣ` (order 8). So exactly `4` coefficients `c` are exceptional for
`x ↦ x^3 + c·x`, and `9 − 4 = 5` give permutations — again matching the formulas
with `p = 3`.

### General `p`

`|{c : c^(p+1) = 1}| = p + 1`, because `(p+1) ∣ p²−1 = |Kˣ|` and `Kˣ` is cyclic,
so the `(p+1)`-th roots of unity form the unique subgroup of order `p+1`. The
fraction of *bad* coefficients is `(p+1)/p² → 0`: almost every linear
coefficient yields a permutation.

## 2. The `q` even collapse (why `F_4` is "complete")

When `p = 2` the term `b·x²` is `b·x^q = b·(Frobenius x)`, i.e. it is *linear*,
not genuinely quadratic. Hence the full family
`f(x) = x² + b·x² + c·x + d = (1+b)·x² + c·x + d`
is linearized, and the criterion gives a *complete* characterization
(`permPoly_charTwo_iff`): `f` permutes `F_4` ⇔ `(1+b)^3 ≠ c^3`. No Weil sum is
needed in this case — this is the surprising structural collapse.

## 3. Counterexample hunt (where the clean criterion fails)

For `b ≠ 0` and `p` odd, `x²` is genuinely quadratic and the simple
norm criterion no longer governs the permutation property: e.g. over `F_9`,
`f(x) = x³ + x² + c·x` is *not* captured by any `N(a) ≠ N(c)` rule, because the
relevant count of solutions to `f(x) = f(y)` becomes a Weil/character sum whose
vanishing is a genuine cubic-discriminant condition. This is exactly the regime
left to `FUTURE_DIRECTIONS.md`; the linear and `q`-even cases are the parts that
admit the clean, Weil-free criterion proved here.

## 4. Status

All numeric claims above are **theorems** (not `#eval`/`native_decide` outputs):

* the criterion `linearized_bijective_iff`,
* the counts `card_norm_one` (= `p+1`) and `card_permutation_coeffs`
  (= `p² − (p+1)`),
* the `q`-even complete characterization `permPoly_charTwo_iff`,

are all proved with `0` sorries and depend only on the standard axioms
`propext, Classical.choice, Quot.sound`.
