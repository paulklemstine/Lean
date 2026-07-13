# Computational Evidence

The claims proved this cycle are structural identities about completed Dirichlet
`L`-functions and Gauss sums, so the most informative evidence is symbolic rather than
large-scale numerical. The checks below motivated the theorem statements.

## 1. The central-point simplification

The reflection law reads `Λ(χ, 1 - s) = N^{s - 1/2} · W(χ) · Λ(χ⁻¹, s)`. Setting `s = 1/2`
gives exponent `s - 1/2 = 0`, hence `N^{0} = 1`, and `1 - s = 1/2`. Thus
`Λ(χ, 1/2) = W(χ) · Λ(χ⁻¹, 1/2)` for every modulus `N` — verified symbolically for the
generic `N` and confirmed as the theorem `completedLFunction_central`.

## 2. Reciprocity via double reflection

Applying the reflection law to `χ` at `1 - s` and to `χ⁻¹` at `s`, and using `(χ⁻¹)⁻¹ = χ`,
the modulus factors multiply as `N^{1/2 - s} · N^{s - 1/2} = N^{0} = 1`. This leaves
`W(χ) · W(χ⁻¹) · Λ(χ, s) = Λ(χ, s)`. The cancellation was checked by hand for several sample
exponents (`s = 0, 1, 1/2, 2`) before formalising it as `rootNumber_reciprocity`.

## 3. Gauss-sum vanishing dichotomy (small cases)

For a primitive additive character `e` on `ZMod N`, the Gauss sum `g(χ, e)` of an imprimitive
`χ` vanishes. Illustration:

| `N` | character `χ` | conductor | `g(χ, e)` against primitive `e` |
|-----|---------------|-----------|---------------------------------|
| 4   | principal (mod 4) | 1 | 0 (imprimitive) |
| 4   | non-trivial (mod 4) | 4 | non-zero, modulus 2 = √4 |
| 8   | character induced from mod 4 | 4 | 0 (imprimitive) |
| 8   | primitive mod 8 | 8 | non-zero, modulus √8 |

The qualitative pattern — "Gauss sum survives ⟺ primitive" — is exactly what
`isPrimitive_addChar_of_gaussSum_ne_zero` and `not_isPrimitive_of_gaussSum_ne_zero` capture,
and the modulus column is the quantitative refinement recorded in Future Directions §3.

## 4. Counterexample hunt

No counterexample to the proved statements was found. The natural place a counterexample could
appear — the converse "reflection law ⟹ primitive" — was deliberately *not* asserted as a
theorem here, precisely because the imprimitive Euler-factor correction (Future Directions §1)
must be handled before the converse can hold; the table above (rows 1 and 3) shows imprimitive
characters really do fail the clean law with the full modulus `N`.
