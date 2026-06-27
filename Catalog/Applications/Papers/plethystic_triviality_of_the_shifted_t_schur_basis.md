# Computational Evidence — Diagonal Plethysm Group of the Shifted `t`-Schur Basis

All objects live in `Lam = MvPolynomial ℕ K` with `K = ℚ(t) = RatFunc ℚ` and
`X k = p_{2k+1}` (the `(2k+1)`-st odd power sum). The deformation scalar is
`cc k = 1 - t^{2k+1}`. Everything claimed below is **formally verified** in
`DiagonalPlethysmGroup.lean` (and the companion files); the tables are the small-case
hand computations that motivated the formal statements.

## 1. Eigenvalue formula (`diagHom_monomial`, `diagHom_coeff`)

`φ_t` (and more generally `diagHom c`) is diagonal in the monomial basis: the monomial
`X^d = ∏_k p_{2k+1}^{d_k}` is an eigenvector with eigenvalue `∏_k c_k^{d_k}`.

| monomial `X^d`            | eigenvalue under `φ_t`            |
|---------------------------|-----------------------------------|
| `1`                       | `1`                               |
| `p_1 = X 0`               | `1 - t`                           |
| `p_1^2 = X 0 ^ 2`         | `(1 - t)^2`                       |
| `p_3 = X 1`               | `1 - t^3`                         |
| `p_1 p_3 = X 0 * X 1`     | `(1 - t)(1 - t^3)`                |
| `p_1^2 p_5 = X0^2 X2`     | `(1 - t)^2 (1 - t^5)`             |

Verified abstractly: `diagHom_coeff` gives `(φ_t f).coeff d = (∏_k cc k ^ d k) * f.coeff d`.

## 2. Non-degeneracy of eigenvalues (`cc_prod_ne_one`)

Claim tested: `∏_{k ∈ supp d} (1 - t^{2k+1})^{d_k} ≠ 1` whenever `d ≠ 0`.

Sanity check by evaluation at `t = 1`: every factor `1 - 1^{2k+1} = 0`, so the product
evaluates to `0 ≠ 1`. This single specialization already certifies the product is not the
constant polynomial `1`, and is exactly the route taken in the verified proof. (The
alternative degree argument `deg = ∑ d_k (2k+1) ≥ 1` also holds and was the original
hypothesis.)

## 3. Fixed subalgebra (`phiT_fixed_iff_const`)

Counterexample hunt for "`φ_t` fixes some non-constant `f`": none exists. Any candidate
`f` with `φ_t f = f` forces `(∏ cc^d − 1)·(coeff_d f) = 0` for every `d`; by item 2 the
left factor is non-zero for `d ≠ 0`, so all non-constant coefficients vanish. Tested
small cases: `f = a + b p_1` fixed ⟺ `b(1−t) = b` ⟺ `b·t = 0` ⟺ `b = 0`. Matches the
theorem: fixed points are exactly the scalars `K`.

## 4. Order of the deformation (`phiTEquiv_pow_eq_one_iff`, `orderOf_phiTEquiv`)

`φ_t^N = id` ⟺ `N = 0`. Reason: `φ_t^N` is diagonal with eigenvalues `cc k ^ N`; on `p_1`
the eigenvalue is `(1 − t)^N`, which equals `1` only if `N = 0` (else `(1−t)^N` has
positive degree). So `orderOf φ_t = 0` (infinite order): the cyclic group `⟨φ_t⟩` is a
faithful `ℤ` inside `Aut(Λ_odd)`.

| `N` | eigenvalue of `φ_t^N` on `p_1` | `= 1`? |
|-----|--------------------------------|--------|
| `0` | `1`                            | yes    |
| `1` | `1 − t`                        | no     |
| `2` | `(1 − t)^2`                    | no     |
| `N` | `(1 − t)^N`                    | iff N=0|

## 5. Faithful parametrisation (`diagHom_injective_param`, `diagAutHom_injective`)

Reading off the coefficient of `X k` shows `diagHom c = diagHom d ⟹ c = d`, so the whole
group `(K^×)^ℕ` embeds into `Aut(Λ_odd)` — no two scalar sequences collapse.

## OEIS / sequences

No integer sequence is intrinsic here (coefficients are rational functions of `t`). The
relevant invariant `∑ d_k (2k+1)` is the size of the underlying strict partition; for the
one-row case `d = (m at index k)` it is `m(2k+1)`, the standard odd-multiplicity grading.

## Why this is sufficient

The phenomenon is symbolic (over `ℚ(t)`), so finite numeric enumeration is not the right
tool; the decisive checks are the eigenvalue identity and the degree/evaluation
non-degeneracy, both of which are discharged in Lean with `0` sorries and only the
standard axioms `propext, Classical.choice, Quot.sound`.
