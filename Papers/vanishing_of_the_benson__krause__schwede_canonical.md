# Computational Evidence — Cup-product forms of pro-2 Demushkin groups

This note records the small-case exploration that preceded the formal development in
`CupForm.lean`, `IsotropyLocus.lean`, and `Examples.lean`.

## 1. Setup

For a pro-2 Demushkin group `G` the mod-2 cohomology is concentrated in degrees `0,1,2`
with `H⁰ ≅ 𝔽₂`, `H² ≅ 𝔽₂`, and the cup product

    b : H¹(G;𝔽₂) × H¹(G;𝔽₂) → H²(G;𝔽₂) ≅ 𝔽₂

a nondegenerate symmetric bilinear form on the `𝔽₂`-vector space `V = H¹`.  We model this
form directly and study its characteristic-two features.

## 2. The squaring map is linear (characteristic-two check)

Define `q(x) = b(x,x)`.  Over `𝔽₂`:

    q(x+y) = b(x,x) + b(x,y) + b(y,x) + b(y,y) = q(x) + q(y)   (since b(x,y)=b(y,x) and 2=0)
    q(c·x) = c²·q(x) = c·q(x)                                  (since c² = c for c ∈ 𝔽₂)

so `q : V → 𝔽₂` is linear.  Verified on all `2×2` and `2×3` symmetric Gram matrices by
brute force enumeration: `q` is additive in every case; over `𝔽₃` (control) additivity
already fails for the identity form (`q(e₁+e₂)=2 ≠ 1+1`?  no — but `q(2e₁)=4·1=1≠2·q(e₁)`),
confirming the phenomenon is special to characteristic two.

## 3. Small-case table (dot product on 𝔽₂ⁿ)

`⟨x,y⟩ = Σ xᵢyᵢ`, Gram matrix `Iₙ`, always nondegenerate.

| n | dim H¹ | alternating? | Kummer class χ | # isotropic {x : ⟨x,x⟩=0} | 2^(n-1) |
|---|--------|--------------|----------------|---------------------------|---------|
| 1 | 1      | no (odd)     | (1)            | 1                         | 1       |
| 2 | 2      | no (odd)     | (1,1)          | 2                         | 2       |
| 3 | 3      | no (odd)     | (1,1,1)        | 4                         | 4       |
| 4 | 4      | no (odd)     | (1,1,1,1)      | 8                         | 8       |

The Kummer class is the all-ones vector because `⟨x,x⟩ = Σ xᵢ² = Σ xᵢ = ⟨𝟙,x⟩`.  The
isotropy count matches `2^(n-1)` exactly — the isotropic classes are the even-weight
vectors, a hyperplane.  This is `Demushkin.dotForm_isotropy_codim`.

## 4. Even type

The hyperbolic plane `⟨x,y⟩ = x₀y₁ + x₁y₀` on `𝔽₂²` is nondegenerate and alternating
(`⟨x,x⟩ = 2x₀x₁ = 0`).  Here the Kummer class is `0` and the isotropy locus is all of
`𝔽₂²` (4 vectors).  This is `Demushkin.hypForm_kummer_zero` / `hypForm_isotropic_top` and
realises the *even type*.

## 5. Counterexample hunt

* Is the isotropy locus always a subspace?  Over `𝔽₂`: **yes** (kernel of the linear map
  `q`), confirmed on all enumerated forms.  Over `𝔽₃`, `𝔽₅`: **no** — e.g. for the
  identity form the isotropic set is `{x : Σxᵢ²=0}`, a genuine quadric that is not closed
  under addition.  So the subspace phenomenon is exactly a characteristic-two effect.
* Is the codimension always `≤ 1`?  Yes for nonzero `q` (a functional into a 1-dimensional
  space), and `= 0` exactly in the alternating case.  No counterexample found.

## 6. Conclusion

The experiments pin down three robust phenomena, all subsequently proved with `0` sorries:
linearity of squaring, the Kummer/orientation class representing it, and the
`codim ∈ {0,1}` dichotomy of the isotropy locus (with the exact count `2^(n-1)` in the odd
case).
