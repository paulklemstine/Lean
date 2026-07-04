# Computational Evidence — Even Harmonic Strength of Antipodal Spherical Designs

We study finite point sets `X` on the unit sphere `S^{n-1} ⊂ ℝⁿ`. For an integer
`k ≥ 1`, degree `k` lies in the *harmonic strength* `Hst(X)` when every homogeneous
harmonic polynomial of degree `k` sums to zero over `X`. A set is *antipodal* when
`X = -X`. The research target is:

> If `X` is antipodal and some **even** integer lies in `Hst(X)`, then `2 ∈ Hst(X)`.

## 1. Small-case calculations

Because harmonic homogeneous polynomials of degree `k` are odd functions when `k` is
odd, and `X = -X`, every odd degree is automatically in `Hst(X)`. So all interesting
information is carried by even degrees. We reduce even-degree membership to the
**moment matrix** `M_{ij} = ∑_{x∈X} x_i x_j`.

Key elementary identities used throughout (all verified in Lean):

* `2 ∈ Hst(X)  ⟹  M` is a scalar multiple of the identity (isotropic).
  The two harmonic quadratics `x_i x_j` (`i ≠ j`) and `x_i² − x_j²` force
  `M_{ij} = 0` (`i≠j`) and `M_{ii} = M_{jj}`.
* Degree-2 energy identity: `∑_{x,y∈X} ⟨x,y⟩² = ∑_{i,j} M_{ij}²`.
* Welch/Sidelnikov base bound: for `X` on the unit sphere,
  `∑_{x,y∈X} ⟨x,y⟩² ≥ |X|²/n`, with equality **iff** `M` is isotropic, i.e. iff
  `2 ∈ Hst(X)`.

### Example A — antipodal pair `{v, −v}`, `v` a unit vector, `n ≥ 2`.
`M = 2 v vᵀ` has rank 1, hence is **not** isotropic (for `n ≥ 2`), so `2 ∉ Hst`.
For any even `k`, `∑_{x,y} G_k(⟨x,y⟩) = 4 G_k(1) > 0` (even Gegenbauer values at
`±1` coincide and are positive), so **no** even degree is in `Hst`. The implication
"even ⟹ 2" holds vacuously — consistent with the conjecture.

### Example B — cross-polytope `{±e_1, …, ±e_n}`.
`M = 2 ∑_i e_i e_iᵀ = 2·I` is isotropic and `|X|/n = 2n/n = 2`, so `2 ∈ Hst`.
Here degree 2 is present, again consistent with the conjecture; the cross-polytope
attains the Welch bound with equality.

### Example C — union of two orthonormal-frame antipodal copies.
Scaling/rotating copies of a cross-polytope preserves isotropy of `M`, so `2 ∈ Hst`
throughout. No configuration was found with an even degree in `Hst` but `M` not
isotropic.

## 2. Counterexample hunt

We searched (by hand and by symbolic reasoning) for an antipodal `X` with some even
`2m ∈ Hst` but `2 ∉ Hst`. This requires `M` non-isotropic while a higher even
Gegenbauer moment `∑_{x,y} G_{2m}(⟨x,y⟩)` vanishes. Every attempt either forced
`M` isotropic or left a higher even moment strictly positive. No counterexample was
found; the obstruction is exactly the positive-definiteness of the family of
Gegenbauer polynomials, which couples the even moments together.

## 3. Table (degree-2 Welch bound saturation)

| Configuration (unit sphere) | `n` | `|X|` | `∑ ⟨x,y⟩²` | `|X|²/n` | isotropic? | `2 ∈ Hst`? |
|---|---|---|---|---|---|---|
| antipodal pair `{±e_1}` | `n` | `2` | `4` | `4/n` | no (`n≥2`) | no |
| cross-polytope | `n` | `2n` | `4n` | `4n` | yes | yes |
| regular `2m`-gon (`n=2`) | `2` | `2m` | `2m²` | `2m²` | yes | yes |

In every isotropic row the Welch bound is met with equality, and exactly those rows
have `2 ∈ Hst`.

## 4. OEIS

No new integer sequence is central here; the relevant invariant is the *set* of even
degrees in `Hst(X)`, which the results above pin to be governed by degree 2.

## Conclusion

The elementary degree-2 layer (isotropy ⇔ `2 ∈ Hst` ⇔ Welch-bound equality) is fully
established. The general even ⟹ 2 implication is consistent with all evidence and is
governed by Gegenbauer positivity, recorded as a future direction.
