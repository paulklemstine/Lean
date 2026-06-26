# Computational Evidence

Scope: evidence supporting the formal results in `Core.lean` / `Fano.lean`
about Boolean degree one functions on the Grassmann scheme `J_q(n,2)`.

## 1. Trivial-function counts (small cases)

A Boolean degree one function on `J_q(n,2)` is, by the working definition,
`f ℓ = c + ∑_{p∈ℓ} w p` with values in `{0,1}`. The trivial family consists of:
the two constants, the `N` point-pencils (`N = (q^n−1)/(q−1)` points), and — by
duality — the hyperplane families, plus complements. The lower bound proved in
`exists_many_BDO` is `N + 2` (constants + pencils).

| `q` | `n` | points `N` | lines | proved lower bound `N+2` |
|----:|----:|-----------:|------:|-------------------------:|
|  2  |  3  |     7      |   7   |           9              |
|  3  |  4  |    40      | 130   |          42              |
|  4  |  4  |    85      | 357   |          87              |
|  5  |  4  |   156      | 806   |         158              |

The Fano row (`q=2,n=3`) is the only one small enough to settle every incidence
axiom by kernel `decide`; it is fully formalized as `fano_exists_many_BDO`.

## 2. Obstruction check (sum of pencils)

For distinct points `p ≠ p'`, `ind p + ind p'` equals `2` on the unique common
line, hence is never Boolean. Verified on the Fano plane for all `7·6/… ` pairs
implicitly via `fano_two_pencils_not_boolean`; matches the abstract proof
`two_pencils_not_boolean`. This is the elementary reason additive combinations of
pencils do not yield new Boolean degree one functions.

## 3. Symmetric (constant-weight) case

With a constant weight `a`, `f ℓ = c + (q+1)·a` is independent of `ℓ`, so the
function is constant. Confirmed abstractly (`const_weight_is_constant`) using
only the uniform line size `q+1`; no counterexample is possible.

## 4. Counterexample hunt / regime boundary

No counterexample to the *trivial-existence* claims was found (they are theorems).
The interesting boundary is the `q=2` vs `q≥3` divide for *non-trivial*
existence (Conjectures C1/C2): `q=2` is exceptional and expected to admit
non-trivial Boolean degree one functions, while `q≥3, n≥4` is conjectured rigid.
Verifying C1/C2 computationally requires the integral weight reduction (C3) to
make the search finite; this is left as a formal target.

## 5. OEIS

The point counts `N = (q^n−1)/(q−1)` for fixed `q` are the Gaussian/`q`-integer
sequences (e.g. `q=2`: 1,3,7,15,31,… = `2^n−1`, OEIS A000225). No new sequence is
introduced by the present results.
