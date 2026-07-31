# Computational evidence

The proposed connector reduces the half-canonical Brill–Noether condition to
an exact integer identity, so only a short sanity check is useful before the
general proof.

## Small cases

For `ρ(g,r,g-1) = g-(r+1)^2`:

| genus `g` | rank `r` | `ρ(g,r,g-1)` | admissible? |
|---:|---:|---:|:---|
| 1 | 0 | 0 | yes |
| 4 | 0 | 3 | yes |
| 4 | 1 | 0 | yes |
| 4 | 2 | -5 | no |
| 9 | 2 | 0 | yes |
| 9 | 3 | -7 | no |
| 16 | 3 | 0 | yes |
| 16 | 4 | -9 | no |

Thus perfect-square genera exhibit the expected sharp transition at
`r = √g - 1`.

## Sequence / OEIS

The boundary genera as rank varies are `(r+1)^2 = 1, 4, 9, 16, 25, ...`, the
positive squares (OEIS A000290 with its initial zero omitted).

## Counterexample hunt

No counterexample appears in the table. More importantly, the Lean theorem
`rho_halfCanonical_eq_genus_sub_square` proves the identity for every integer
`g,r`, and `rho_halfCanonical_nonneg_iff_square_le` proves the exact natural
number threshold, so finite sampling is not being used as evidence for an
unproved universal claim.

## Plot description

For fixed `g`, the values form the downward parabola `g-(r+1)^2`; its
nonnegative integer points are exactly `0 ≤ r ≤ √g-1`. A separate plot would
add no information beyond this exact formula.
