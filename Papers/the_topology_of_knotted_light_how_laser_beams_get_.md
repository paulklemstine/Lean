# Computational Evidence: Small-Knot Alexander Spectra

## Small-case calculations

For the torus-knot polynomial

`A_n(X) = 1 - X + X² - ··· + X^(n-1)`, with odd `n`,

its angular-grid roots in one period are indexed by residues coprime to `2n` when `n` is prime.

| Knot | Grid modulus | Allowed residues in one period | Channel count |
|---|---:|---|---:|
| Trefoil `T(2,3)` | 6 | `1, 5` | 2 |
| Cinquefoil `T(2,5)` | 10 | `1, 3, 7, 9` | 4 |

These are respectively the primitive sixth and primitive tenth roots of unity. The zero residue is excluded in both cases because a normalized Alexander polynomial evaluates to a nonzero value at `1`.

For the figure-eight knot, `Δ(X)=X²-3X+1` has roots

`(3+√5)/2 ≈ 2.6180339887` and `(3-√5)/2 ≈ 0.3819660113`.

Their product is `1`, but neither has modulus `1`. Consequently no root lies on an angular root-of-unity grid.

## Sequence search

The prime-family channel counts are `p-1`, giving `2, 4, 6, 10, 12, ...` for odd primes `3,5,7,11,13,...`. This is the Euler totient value `φ(2p)=φ(p)=p-1`; no separate sequence identification is needed beyond the standard totient function.

## Counterexample hunt

The proposed figure-eight values `(3±√5)/2 mod 1` do not satisfy the stated spectral equation. The equation evaluates the polynomial at `exp(2πil/N)`, which always has modulus one, whereas both polynomial roots are positive real numbers off the unit circle. Reducing their numerical values modulo one changes the input and does not preserve polynomial vanishing.

The unknot polynomial `Δ=1` has no roots at all, so the spectrum defined by `Δ(exp(2πil/N))=0` is empty, not `{0}`. A zero-charge optical mode may exist under a different convention, but it is not selected by this root-set definition.

## Numerical geometry

| Knot | Alexander-root geometry | Root-of-unity OAM prediction |
|---|---|---|
| Unknot | no roots | empty |
| Trefoil | primitive sixth roots | residues `1,5 mod 6` |
| Figure-eight | positive reciprocal real pair | no angular channels |
| Cinquefoil | primitive tenth roots | residues `1,3,7,9 mod 10` |

The exact classifications and the figure-eight exclusion are established in the accompanying mathematical development; the decimal values here are explanatory approximations only.
