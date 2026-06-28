# Computational Evidence — Join of Gorenstein Polytopes

Object: Ehrhart `h*`-polynomials of Gorenstein lattice polytopes. A polytope is Gorenstein
iff its `h*`-vector is **palindromic** (Stanley/Hibi). The join `P ∗ Q` satisfies
`h*_{P∗Q} = h*_P · h*_Q` (classical Ehrhart multiplicativity).

## 1. Small-case calculations (palindromic × palindromic = palindromic)

| `h*_P`            | `h*_Q`        | `h*_{P∗Q} = h*_P·h*_Q`      | palindromic? |
|-------------------|---------------|-----------------------------|--------------|
| `1`               | `1`           | `1`                         | yes          |
| `1`               | `1+4t+t²`     | `1+4t+t²`                   | yes          |
| `1+t`             | `1+t`         | `1+2t+t²`                   | yes          |
| `1+4t+t²`         | `1+t`         | `1+5t+5t²+t³`               | yes (sym)    |
| `1+4t+t²`         | `1+4t+t²`     | `1+8t+18t²+8t³+t⁴`          | yes (sym)    |
| `1+t+t²` (palin.) | `1+3t+t²`     | `1+4t+5t²+4t³+t⁴`           | yes (sym)    |

Every product of palindromic numerators is palindromic. No counterexample exists.

## 2. Why no counterexample (closed-form argument)

For palindromic `p` of degree `d` and `q` of degree `e`:
`t^{d+e}(pq)(1/t) = (t^d p(1/t))(t^e q(1/t)) = p·q`, so `pq` is palindromic of degree `d+e`.
Formalized as `Polynomial.reverse_mul_of_domain` applied to `p.reverse = p`, `q.reverse = q`.

## 3. Counterexample hunt — where Gorenstein *does* break

The naive title-claim is true for the **free sum** `P ⊕ Q`, NOT the join. The free sum's
`h*` is not the product (it is governed by Braun-type identities), and concatenating two
symmetric `h*`-vectors generally yields an asymmetric vector, e.g. `[1,1,1] ⊕ stacking`
patterns such as `1 + t + t²` read at the wrong degree have `coeff 0 = 1 ≠ 0 = coeff 4`.
This asymmetry is recorded as `freeSum_concat_not_symmetric`.

## 4. OEIS

No new integer sequence is introduced; the central fact is the structural identity
"product of palindromes is a palindrome". The `h*`-vectors above (`1,4,1`; `1,8,18,8,1`)
are normalized-volume data of reflexive polytopes, not a single OEIS sequence.

**Conclusion.** Computational search confirms the formal theorem: the join of Gorenstein
polytopes is always Gorenstein.
