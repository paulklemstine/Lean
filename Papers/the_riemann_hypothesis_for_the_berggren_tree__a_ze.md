# Computational Evidence — Zeta function of the Berggren tree

All numbers below were produced by `#eval` on a faithful re-implementation of the
definitions in `Catalog/Novelty/BerggrenTreeZetaCore.lean` (Euclid-seed coordinates,
root `(m,n) = (2,1)`, moves `L(m,n) = (2m-n,m)`, `M(m,n) = (2m+n,m)`, `R(m,n) = (m+2n,n)`,
hypotenuse `c(w) = m²+n²`).  They are numerical evidence only; every claim that is asserted
as a theorem is proved separately and `sorry`-free in `Catalog/Novelty/`.

## 1. The three spines

| depth `k` | `c(Mᵏ)` (middle) | `c(Lᵏ)` (left) | `c(Rᵏ)` (right) |
|-----------|------------------|----------------|-----------------|
| 0 | 5     | 5  | 5   |
| 1 | 29    | 13 | 17  |
| 2 | 169   | 25 | 37  |
| 3 | 985   | 41 | 65  |
| 4 | 5741  | 61 | 101 |

* Middle spine: `5, 29, 169, 985, 5741, 33461`, satisfying `c_{k+1} = 6c_k − c_{k−1}`
  (Pell/NSW-type recursion), with `c_{k+1}/c_k → 5.8284… = 3 + 2√2 = (1+√2)²`
  (`985/169 = 5.828…`, `5741/985 = 5.8284…`).
* Left spine: `c(Lᵏ) = 2k² + 6k + 5` — **quadratic**.
* Right spine: `c(Rᵏ) = 4k² + 8k + 5` — **quadratic**.

This is the *silver growth dichotomy*: only one of the three branches realises the silver
speed limit.  Formalised as `Mspine_silver_growth`, `Lspine_hyp`, `Rspine_hyp` in
`Catalog/Novelty/BerggrenTreeSilverGrowth.lean`.

## 2. Extremal hypotenuse at each depth

`max { c(w) : |w| = d }` for `d = 0..5`:  `5, 29, 169, 985, 5741, 33461` — i.e. the maximum
is always attained on the middle spine, and `max ≤ 5(3+2√2)^d` holds with room to spare
(`5(3+2√2)^5 ≈ 33630 ≥ 33461`).  Formalised as `hyp_le_silver_pow`.

Depth-2 slice (all nine words): `25, 73, 53, 89, 169, 85, 65, 97, 37` — the spread from
`25` to `169` already shows that most nodes grow far slower than the silver rate, which is
the mechanism that pushes the abscissa of convergence up to `1`.

## 3. Counterexample hunt against the silver-abscissa conjecture

The mission conjecture predicted abscissa `σ₀ = log 3 / (2 log(1+√2)) ≈ 0.6237`.  Counting
nodes with `c(w) ≤ H` (equivalently admissible Euclid seeds in the disc of radius `√H`):

| `H`   | 100 | 200 | 400 | 800 | 1600 | 3200 |
|-------|-----|-----|-----|-----|------|------|
| `N(H)`| 16  | 32  | 63  | 128 | 254  | 507  |
| `N(H)/H` | 0.160 | 0.160 | 0.158 | 0.160 | 0.159 | 0.158 |

`N(H)` is linear in `H` (empirically `N(H) ≈ 0.159 H ≈ H/(2π)`), **not** `H^{0.6237}`.
Since `Σ_w c(w)^{-s}` converges iff `∫ N(H) dH^{-s}` does, this predicts abscissa `1`, and
that is exactly what is proved: `treeZeta_summable_iff` (converges iff `s > 1`) together
with `treeZeta_abscissa_ne_silver`.  So the conjecture as literally stated is **false**, and
the failure is quantitative and visible already at `H = 100`.

The silver exponent nevertheless survives as a *lower* bound (`3^d` nodes at depth `d`,
each of height `≤ 5(3+2√2)^d`):  `count_ge_silver_rpow` gives `N(H) ≥ (1/3)(H/5)^{σ₀}`,
consistent with the table (`H = 3200`: bound `≈ 0.33·640^{0.6237} ≈ 18 ≤ 507`).

## 4. Prime hypotenuses

Hypotenuses occurring in the tree that are prime, in increasing order:
`5, 13, 17, 29, 37, 41, 53, 61, 73, 89, 97, 101, 109, 113, 137, 149, 157, 173, 181, 193,
197` — exactly the primes `≡ 1 (mod 4)` up to 200, with no exceptions and no omissions in
this range.  Formalised (for all primes) as `prime_hyp_iff` and `hyp_mod_four` in
`Catalog/Novelty/BerggrenTreePrimeHypotenuse.lean`; infinitude via `infinite_prime_hyp`.

## 5. The silver zeta and its zeros

For the depth-graded model `Z(s) = Σ_d 3^d (ε^{2d})^{-s} = (1 − 3ε^{-2s})^{-1}`,
`ε = 1+√2`, the denominator vanishes iff `Re s = σ₀` and `Im s ∈ (π/log ε)ℤ`.
Numerically `σ₀ = log 3/(2 log 2.41421) = 1.09861/1.76275 = 0.62324…` and the pole spacing
is `π/log ε = 3.14159/0.88137 = 3.5646…`.  Formalised as `silver_denom_eq_zero_iff`,
`silver_pole_re_eq`, `silver_pole_shift`.

## 6. The hyperbolic subtree `{MM, MR}`

Hypotenuses of the block subtree, by block depth `d` (all `2^d` nodes):

* `d = 0`: `5`
* `d = 1`: `169, 97`
* `d = 2`: `5741, 2885, 3293, 1733`
* `d = 3`: `195025, 97609, 97921, 51913, 111865, 56065, 58825, 31105`

Observed per-block growth factors at depth 3: `33.97, 17.00, 33.94, 17.99, 33.97, 17.03,
33.94, 17.95` — i.e. the `MM` block multiplies the hypotenuse by ≈ `(3+2√2)² = 33.97` and
the `MR` block by ≈ `17`.  Both are comfortably above the proved uniform lower factor `5/2`
and at most the proved upper factor `(3+2√2)² = 33.97`, which is exactly the sandwich used
in `summable_subtree` / `not_summable_subtree`.  The empirical abscissa suggested by these
factors is `log 2 / log 17 ≈ 0.245` (worst branch), well inside the proved interval
`[0.196, 0.757]` and far below the full tree's abscissa `1`.

## 7. OEIS

No OEIS identifiers are asserted here: the sequences above (`5, 29, 169, 985, 5741, 33461`
and `2k²+6k+5`, `4k²+8k+5`) were not looked up in OEIS during this work, so any ID would be
unverified.  The Pell-type recursion `c_{k+1} = 6c_k − c_{k−1}` was verified directly on the
computed terms.
