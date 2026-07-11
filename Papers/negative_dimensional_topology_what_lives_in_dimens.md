# Computational Evidence — Negative-Dimensional Topology

We model a virtual graded space by a Laurent polynomial in `t` over `ℤ`
(`ℤ[t, t⁻¹] = AddMonoidAlgebra ℤ ℤ`), where the monomial `c · tᵈ` means "`c` cells in
dimension `d`" and `d` is allowed to be negative.  The Euler characteristic is the
ring homomorphism `χ : t ↦ -1`, i.e. `χ(∑ b_d tᵈ) = ∑ (-1)ᵈ b_d`.

## 1. Small-case calculations of `χ` of a pure `(-n)`-dimensional space with `k` cells

`χ(k · t^{-n}) = (-1)^{-n} · k = (-1)^n · k`.

| dim `-n` | `k = |π₀|` | `χ` |
|----------|-----------|-----|
| `-1`     | 1         | `-1` |
| `-1`     | 3         | `-3` |
| `-2`     | 1         | `+1` |
| `-2`     | 5         | `+5` |
| `-3`     | 2         | `-2` |
| `-4`     | 1         | `+1` |
|  `0`     | 1         | `+1` (a point) |

This is exactly the formula proved as `chi_pure_neg` / `chi_neg_dim`:
`χ(X) = (-1)^n · |π₀(X)|` for `dim X = -n`.  In particular **dimension `-1`**
(the title question) is characterized by `chi_dim_neg_one`: a `k`-component
`(-1)`-space has `χ = -k`.

## 2. Suspension / stabilization

Suspension `Σ` multiplies by `t`, so `χ(ΣX) = -χ(X)` and `χ(ΣⁿX) = (-1)ⁿ χ(X)`.
Suspending a `(-n)`-space `n` times moves it to dimension `0`:

`Σⁿ (k · t^{-n}) = k · t⁰`,   and   `χ = (-1)ⁿ · (-1)ⁿ k = k`.

Numerical check (`n = 3, k = 2`): `χ(2 t^{-3}) = -2`; after `Σ³` we get `2 t⁰` with
`χ = 2 = (-1)³ · (-2)`. Consistent (formalized as `stabilize_neg`, `stabilize_chi`).

Desuspension `Σ⁻¹` (multiply by `t⁻¹`) is the two-sided inverse of `Σ`
(`susp_desusp`, `desusp_susp`), so the stabilization map between negative and
positive dimensions is a bijection.

## 3. Counterexample hunt (contrarian conjectures)

* **"Every negative-dimensional space has `χ < 0`."**  FALSE.  Tested over
  `n ∈ {1,…,6}`, `k ∈ {1,…,5}`: the sign is `(-1)ⁿ`, so all *even*-codimension
  spaces have `χ > 0` (e.g. `dim = -2, k = 1 ⇒ χ = +1`).  Formalized as the
  disproof `disproof_all_neg_chi`.
* **"`χ` is injective / remembers the dimension."**  FALSE.  `χ` only detects the
  parity of the dimension.  Smallest witness: `t⁰` (a point) and `t²` (one
  2-cell) are different spaces with `χ = 1` each.  Formalized as
  `disproof_chi_not_injective`.

## 4. OEIS

The signed sequence `χ(1 · t^{-n}) = (-1)ⁿ`, `n = 0,1,2,…` is `1, -1, 1, -1, …`
(**OEIS A033999**, `a(n) = (-1)^n`).  No deeper sequence arises; the invariant is
governed entirely by the parity function, which is what makes the disproofs above
work.

All numeric claims above are discharged in `Core.lean` by `decide`/`ring`/`simp`,
so this table is fully backed by the Lean proofs.
