# Computational Evidence: Barycenter Criterion for Toric Fano Surfaces

We test the toric Yau–Tian–Donaldson principle

> a toric Fano admits a Kähler–Einstein metric  ⟺  the moment vector
> `∑ wᵢ • pᵢ` of its polytope vanishes (barycenter at the origin)

on the five smooth toric del Pezzo surfaces, using the equal-weight moment vector
of the primitive ray generators (the spanning / Fano polytope vertices).

## Small-case calculations

| Surface | Ray generators | Moment vector `∑ pᵢ` | Vanishes? | Admits KE? (known) |
|---|---|---|---|---|
| ℙ² | (1,0),(0,1),(−1,−1) | (0,0) | yes | yes (Fubini–Study) |
| ℙ¹×ℙ¹ | (1,0),(−1,0),(0,1),(0,−1) | (0,0) | yes | yes |
| Bl₁ℙ² = F₁ | (1,0),(0,1),(−1,1),(0,−1) | (0,1) | **no** | **no** (Futaki ≠ 0) |
| Bl₂ℙ² (dP₇) | (1,0),(0,1),(−1,0),(−1,−1),(0,−1) | (−1,−1) | **no** | **no** |
| Bl₃ℙ² (dP₆) | (1,0),(1,1),(0,1),(−1,0),(−1,−1),(0,−1) | (0,0) | yes | yes |

The equal-weight ray-generator sum already reproduces the textbook dichotomy:
the three surfaces with a symmetric polytope (ℙ², ℙ¹×ℙ¹, dP₆) are exactly the toric
del Pezzo surfaces that carry a Kähler–Einstein metric, while the asymmetric blow-ups
F₁ and dP₇ have a nonzero moment vector and are obstructed.

## Symmetry observation

For ℙ² the order-3 linear map `[[0,−1],[1,−1]]` cyclically permutes the three
vertices `(1,0) → (0,1) → (−1,−1) → (1,0)`. Its characteristic polynomial is
`λ² + λ + 1`, which has no real eigenvalue `1`; hence its only fixed vector is the
origin. Because the moment vector is fixed by any symmetry of the configuration, it
must be `0`. This recovers KE-existence with no coordinate computation and is the
combinatorial shadow of Matsushima's theorem (a large reductive symmetry kills the
Futaki invariant). The same mechanism applies verbatim to ℙ¹×ℙ¹ and dP₆.

## Counterexample hunt (sharpness of the symmetry criterion)

F₁ is the minimal counterexample to "every Fano is KE": it is a smooth Fano surface
whose moment vector `(0,1)` is nonzero. Its automorphism group is non-reductive, so the
symmetry argument provably cannot apply — consistent with the nonzero moment vector.

## Conclusion

These finite computations motivated the formal development: the linear-algebra core
(moment vector = 0 ⟺ Futaki vanishes in every direction) is dimension-independent,
while the convex-geometry input (which polytopes are balanced) is what distinguishes
KE from non-KE Fanos. Both the balanced case (ℙⁿ, including the symmetry route) and the
obstructed case (F₁) are verified formally in `Examples.lean`.
