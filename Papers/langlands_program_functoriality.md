# Computational Evidence — Symmetric Square Functoriality GL(2) → GL(3)

We model the *unramified* (Satake / Frobenius–conjugacy-class) heart of the
Gelbart–Jacquet symmetric-square lift `Sym² : GL₂ ⤳ GL₃`.

A 2-dimensional unramified parameter is a matrix `A ∈ GL₂` (the Satake class).
Its eigenvalues `{α, β}` are the Satake parameters. The symmetric square sends

    {α, β}  ↦  {α², αβ, β²}     (3 parameters → target group GL₃).

Concretely, on the basis `{x², xy, y²}` of `Sym²(std)`,

    Sym²(A) = !![ a², a·b, b²;
                  2ac, ad+bc, 2bd;
                  c², c·d, d² ]      for  A = !![a,b;c,d].

## Identities tested (exact rational arithmetic, 8 random integer matrices each)

| Identity | Meaning | Status |
|----------|---------|--------|
| `Sym²(A·B) = Sym²(A)·Sym²(B)` | `Sym²` is a representation (dual-group homomorphism `GL₂(ℂ)→GL₃(ℂ)`) | ✓ |
| `tr Sym²(A) = (tr A)² − det A` | Hecke-eigenvalue transfer  `a_p ↦ a_p² − χ(p)` | ✓ |
| `det Sym²(A) = (det A)³` | central-character transfer | ✓ |
| `tr(A⊗A) = tr Sym²(A) + det A` | `π⊗π = Sym²π ⊞ ∧²π`, with `∧²π = det` | ✓ |
| `det(I − X·A⊗A) = det(I − X·Sym²A)·(1 − X·det A)` | local Rankin–Selberg `L(s,π×π)=L(s,Sym²π)·ζ(s)` | ✓ |

## Symmetric power lifting GL(2) → GL(n+1)

Parameters `{αⁱβⁿ⁻ⁱ : 0 ≤ i ≤ n}` (n+1 of them).  Tested for n = 0..6, 20 cases:

| Identity | Meaning | Status |
|----------|---------|--------|
| `∏_{i=0}^n αⁱβⁿ⁻ⁱ = (αβ)^{n(n+1)/2}` | determinant of `Symⁿ` lift | ✓ |
| `(α−β)·∑_{i=0}^n αⁱβⁿ⁻ⁱ = α^{n+1} − β^{n+1}` | trace = complete homogeneous symmetric poly | ✓ |

## Tropical shadow (reuses catalog `TropicalSatake.tropE1/tropE2`)

With tropical Satake coordinates `(x₁,x₂) = (log α, log β)`, the Sym² parameters
become `{2x₁, x₁+x₂, 2x₂}` and

    max(2x₁, x₁+x₂, 2x₂) = 2·max(x₁,x₂) = 2·tropE1,
    (2x₁)+(x₁+x₂)+(2x₂) = 3·(x₁+x₂)   = 3·tropE2.

All identities are exact polynomial identities, so they formalize as theorems
with no numerical tolerance.
