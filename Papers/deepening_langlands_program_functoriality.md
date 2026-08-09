# Computational evidence

All numbers below were produced by evaluating Lean 4 programs (exact `ℤ` arithmetic, no
floating point) *before* the corresponding theorems were formalised.  Polynomials are encoded
as coefficient lists, lowest degree first, and multiplied by exact convolution.

Notation: `a, b` are the Satake parameters of an unramified `GL(2)` representation,
`s = a + b = a_p`, `p̃ = a b = χ(p)`, and `h_k = a_{p^k}` is the Hecke sequence
`h_0 = 1`, `h_1 = s`, `h_{k+2} = s h_{k+1} - p̃ h_k`.

## 1. Gelbart–Jacquet Euler factor of `Sym^2`

Direct product `∏_{i=0}^{2} (1 - a^i b^{2-i} X)` versus the predicted GL(3) shape
`1 - h_2 X + p̃ h_2 X^2 - p̃^3 X^3`:

| `(a, b)` | `∏ (1 - γ_i X)` | predicted |
|---|---|---|
| `(2, 3)`  | `[1, -19, 114, -216]`    | `[1, -19, 114, -216]` |
| `(-5, 7)` | `[1, -39, -1365, 42875]` | `[1, -39, -1365, 42875]` |

Formalised as `Langlands.symEuler_two_eq`.

## 2. Symmetric cube Euler factor (GL(4))

Predicted shape `1 - h_3 X + p̃ (h_4 + p̃^2) X^2 - p̃^3 h_3 X^3 + p̃^6 X^4`:

| `(a, b)` | `∏_{i=0}^{3} (1 - a^i b^{3-i} X)` | predicted |
|---|---|---|
| `(2, 3)` | `[1, -65, 1482, -14040, 46656]` | `[1, -65, 1482, -14040, 46656]` |

The four elementary symmetric functions were also checked to agree for
`(a,b) ∈ {(-3,2), (5,7), (2,-2), (1,4)}`.  Formalised as `Langlands.symEuler_three_eq`.

## 3. Local Rankin–Selberg

Convolution of `(h_k^2)_k` with the `Sym^2` Euler factor, for `(a,b) = (2,3)`
(so `p̃ = 6`), first eight coefficients:

```
[1, 6, 0, 0, 0, 0, 0, 0]
```

i.e. the product is exactly `1 + p̃ X`.  Formalised as `Langlands.rankin_selberg_sym_two`.

## 4. General Clebsch–Gordan `Sym^m × Sym^n` (counterexample hunt)

For each pair below the full Euler factor
`∏_{i≤m} ∏_{j≤n} (1 - a^i b^{m-i} a^j b^{n-j} X)` was compared coefficient by coefficient
with `∏_{r≤n} ∏_{i≤m+n-2r} (1 - (ab)^r a^i b^{m+n-2r-i} X)`:

| `(m, n)` | `(a, b)` | equal? |
|---|---|---|
| `(3, 2)` | `(2, 3)`   | true |
| `(4, 1)` | `(-2, 5)`  | true |
| `(2, 2)` | `(3, -4)`  | true |
| `(5, 3)` | `(2, 2)`   | true |

No counterexample was found in the regime `n ≤ m`; the identity **fails** if the summation
range `r ≤ n` is used with `n > m` (the correct bound there is `r ≤ min(m,n)`), which is why
the formal statement `Langlands.symEuler_tensor_general` carries the hypothesis `n ≤ m`.

## 5. Arithmetic instance: Ramanujan's `τ`

Satake data of `Δ` at `p = 2`: `s = τ(2) = -24`, `p̃ = 2^11 = 2048`.  The recursion gives

```
h_2 = τ(4)  = -1472
h_3 = τ(8)  = 84480
h_4 = τ(16) = 987136
```

matching the classical values of `τ` at powers of `2`, and the Clebsch–Gordan relation
`τ(2) τ(8) = τ(16) + 2^11 τ(4)` reads `-2027520 = 987136 - 3014656`.  Formalised as
`Langlands.tau_four`, `Langlands.tau_eight`, `Langlands.tau_sixteen`,
`Langlands.tau_clebsch_gordan`.

## Sequences

The unnormalised sequence `1, 3, 7, 15, 31, …` obtained from `h_k(2,1)` is `2^{k+1} - 1`
(OEIS A000225); for `a = b = 1` the Hecke sequence is `h_k = k + 1` (OEIS A000027), which is
the equality case of the Ramanujan bound `‖h_k‖ ≤ k + 1` proved in
`Langlands.hecke_norm_le`.  No new sequences arose that required an OEIS lookup.
