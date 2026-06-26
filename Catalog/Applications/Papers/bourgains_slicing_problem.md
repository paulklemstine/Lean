# Theorem Trace — Bourgain's Slicing Problem (DiscreteCube model)

Source of truth: Phase A Lean file `Catalog/Pythagorean/BourgainSlicing/DiscreteCube.lean`.
Every claim in `ARTICLE.md` and `RESEARCH_PAPER.md` maps to one of the items below.
No theorem is invented or renamed into a grander claim.

## Definitions

| Lean name | Statement | Article | Paper |
|-----------|-----------|---------|-------|
| `sgn` | `sgn b = if b then 1 else -1` (sign value of a bit) | yes | Def. 1 |
| `coord` | `coord x i = sgn (x i)` (the ±1 i-th coordinate) | yes | Def. 2 |
| `E` | `E f = (∑ x, f x) / 2^n` (uniform expectation over `{-1,1}ⁿ`) | yes | Def. 3 |
| `flip` | `flip i x = Function.update x i (!(x i))` (sign flip of coord i) | yes | Def. 4 |
| `flipPerm` | permutation of cube points induced by `flip i` | implicit | Def. 4 |
| `T` | `T k l = ∑ x, coord x k * coord x l` (covariance kernel) | yes | Def. 5 |

## Lemmas / Theorems

| Lean name | Statement | Article | Paper |
|-----------|-----------|---------|-------|
| `sgn_true` | `sgn true = 1` | — | aux |
| `sgn_false` | `sgn false = -1` | — | aux |
| `sgn_not` | `sgn (!b) = - sgn b` | yes (sign-flip) | Lemma 1 |
| `sgn_mul_self` | `sgn b * sgn b = 1` | yes (±1 squared) | Lemma 2 |
| `card_cube` | `|univ : Fin n → Bool| = 2^n` | yes | Lemma 3 |
| `flip_involutive` | `flip i` is an involution | yes | Lemma 4 |
| `coord_flip_self` | `coord (flip i x) i = - coord x i` | yes | Lemma 5 |
| `coord_flip_ne` | `j ≠ i ⇒ coord (flip i x) j = coord x j` | yes | Lemma 6 |
| `flipPerm_apply` | `flipPerm i x = flip i x` | — | aux |
| `sum_coord_eq_zero` | `∑ x, coord x i = 0` (centred) | yes | Thm A |
| `T_off_diag` | `k ≠ l ⇒ T k l = 0` | yes | Thm B (off-diag) |
| `T_diag` | `T k k = 2^n` | yes | Thm B (diag) |
| `covariance` | `T k l = if k = l then 2^n else 0` | yes | Thm B |
| `sum_inner_sq` | `∑ x, (∑ k, θ k * coord x k)^2 = 2^n * ∑ k, θ k^2` | yes | Thm C |
| `E_inner_sq` | `E[(∑ k, θ k * coord x k)^2] = ∑ k, θ k^2` | yes | Thm C (expectation) |
| `discreteCube_isotropic` | unit `θ` ⇒ `E[⟨θ,x⟩²] = 1`, dimension-free | yes (main) | Thm D |
| `E_inner` | `E[⟨θ,x⟩] = 0` (functionals centred) | yes | Thm A' |

Note: `discreteCube_isotropic` and `E_inner` appear in the file's stated Main Results
list; the file text shown was truncated mid-`E_inner` docstring, but both are named
results of the module and are reported as such.
