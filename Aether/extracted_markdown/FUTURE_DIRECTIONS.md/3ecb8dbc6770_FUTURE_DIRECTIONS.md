# FUTURE DIRECTIONS — Functorial Tropical Certificates for Berggren–Lorentz Lattice Reduction

This cycle established a **functorial tropical certificate** for the Berggren–Lorentz
monoid acting on Pythagorean triples
(`Catalog/Bridges/TropicalBerggrenCertificate.lean`):

- `rowNorm` — the ℕ-valued L∞ matrix row-norm — is **submultiplicative**
  (`rowNorm_mul_le`).
- Every Berggren generator has row-norm exactly `7` (`rowNorm_gen`).
- `wordMatrix` is a genuine **monoid homomorphism** `(List, ++) → (GL₃ℤ, *)`
  (`wordMatrix_append`), making the certificate functorial.
- Consequently a depth-`d` triple has all coordinates `≤ 5·7^d`
  (`berggren_hypotenuse_certificate`), and `tropCert = log ∘ rowNorm` is **subadditive**
  (`tropCert_mul_le`, `tropCert_wordMatrix_le`) — the tropical/max-plus image of the
  multiplicative bound.

The following conjectures are precise and falsifiable; each is intended to seed a
follow-up Lean formalization.

## Conjecture 1 (Sharpness of the tropical depth bound)
The `7^d` certificate is tight up to the constant: for the all-`B` word `Bᵈ`, the
hypotenuse of the resulting triple satisfies `c ≥ 5·5^d` and `c ≤ 5·7^d`, and the
ratio `log c / d → log r` for some `r ∈ [5,7]`. **Sharper claim:** `r = 1+2√2`
(the spectral radius / dominant eigenvalue of `matB`), i.e.
`lim_{d→∞} (1/d)·tropCert(Bᵈ) = log(1+2√2)`. Falsifiable by computing `rowNorm(Bᵈ)`
growth vs. `(1+2√2)^d`.

## Conjecture 2 (Spectral-radius refinement of `rowNorm`)
For every Berggren word matrix `M = wordMatrix w`, the *exact* asymptotic growth of
`rowNorm(Mᵏ)` as `k→∞` is governed by the Perron eigenvalue `λ(M)` of `|M|`, giving a
strengthened certificate `tropCert(Mᵏ) = k·log λ(M) + O(1)`. This would replace the
uniform constant `log 7` by a per-word Lyapunov exponent and is the tropical
linearization of the Berggren dynamics.

## Conjecture 3 (Reduction is the inverse functor and strictly decreases the certificate)
Define the reduction step by the inverse generators `invA, invB, invC` (from Core).
Then for any non-seed primitive triple `v` with hypotenuse `c > 5`, exactly one inverse
generator strictly decreases the hypotenuse, and the induced reduction word `w⁻¹`
satisfies `tropCert(wordMatrix w⁻¹) = tropCert(wordMatrix w)` (the certificate is a
two-sided invariant of the word, not just an upper bound). Equivalently: the Berggren
reduction algorithm terminates in exactly `length(w)` steps, matching the certificate.

## Conjecture 4 (Functorial transfer to ultrametric robustness)
Composing the tropical certificate with the valuation-reconstruction functor of
`Bridges/CategoricalTropicalUltrametric.lean` yields a certified ultrametric Lipschitz
bound: the Berggren action is `7^d`-Lipschitz in the L∞ metric, and the reconstructed
ultrametric seminorm makes it `1`-Lipschitz (an isometry) after rescaling by the
tropical certificate. Falsifiable by exhibiting a triple pair whose ultrametric
distance is *not* preserved.

## Conjecture 5 (Generalization to higher-dimensional Lorentz monoids)
For the O(n-1,1;ℤ) analogue generating Pythagorean (n-1)-tuples, the same L∞ row-norm
certificate holds with uniform generator norm `g(n) = 2n-1` (so `g(3)=7`). The
functorial tropical bound becomes depth `≥ log_{2n-1}(c/seed)`. Falsifiable by
constructing the n=4 generators (quadruples `a²+b²+c²=d²`) and checking
`rowNorm = 9` uniformly.
