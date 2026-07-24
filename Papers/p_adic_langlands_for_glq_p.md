# Computational evidence: PadicLanglandsGL2

The main results are algebraic identities and structural bijections rather than a
numerical conjecture, so the relevant "evidence" is direct verification of the
identities on concrete matrices before proving them in general. All checks below
were run with `#eval` in Lean over `ℚ` (a computable field standing in for a
residue/coefficient field) and match the general theorems.

## Cayley–Hamilton (`matrix_two_cayley_hamilton`)

For `M = !![2, 3; 1, -1]`:
- `tr M = 1`, `det M = -5`.
- `M * M - (tr M • M - det M • 1) = !![0,0;0,0]`  ✓ (the CH residual is the zero matrix)

For `N = !![0, 1; 5, 2]`:
- `N * N - (tr N • N - det N • 1) = !![0,0;0,0]`  ✓

## Determinant surjectivity (`diagGL_det`, `det_surjective`)

The witness `diag(u, 1)` used in `det_surjective` realises an arbitrary
determinant:
- `det (diagonal ![7, 1]) = 7`  ✓ (so `7` is attained, not just squares)

This confirms that using a diagonal witness (rather than a scalar `u • 1`, whose
determinant is `u²`) is necessary for surjectivity onto all of `Kˣ`.

## Twist compatibility (`twistRep_det`)

The identity `det(χ ⊗ ρ)(g) = χ(g)² · det ρ(g)` reduces, at each `g`, to
`det(scalar(χ g)) = (χ g)²`, i.e. the scalar-matrix determinant computation
`det (a • 1) = a²` for `2×2` matrices, which is verified symbolically inside the
proof of `scalarGL_det`.

## Remarks

No counterexample hunt applies: the statements are proved theorems (universally
quantified identities), and the `#eval` checks above are consistency spot-checks
on representative inputs. No OEIS sequence arises. The evidence stage is
therefore intentionally brief and confined to sanity-checking the algebraic
identities that the formal proofs then establish in general.
