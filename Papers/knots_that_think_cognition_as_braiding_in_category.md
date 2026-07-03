# Computational Evidence — Jones "Quantum Dimension" of a Thought

All computations below were reproduced symbolically inside Lean (exact complex
arithmetic), so the "evidence" here is exact rather than floating point.

## 1. The three cognitive archetypes and their Jones polynomials

| Thought   | Knot / braid closure        | Jones polynomial `V(t)`               |
|-----------|-----------------------------|----------------------------------------|
| trivial   | unknot (`1`)                | `1`                                    |
| creative  | right trefoil (`σ₀³`)       | `-t⁻⁴ + t⁻³ + t⁻¹`                     |
| confused  | figure-eight (`(σ₀σ₁⁻¹)²`)  | `t⁻² - t⁻¹ + 1 - t + t²`               |

These are the standard Jones polynomials (the trefoil's is the classical
`-t⁻⁴+t⁻³+t⁻¹`, not the `-t²+t+1` written in the informal prompt, which is not a
Jones polynomial of any knot).

## 2. Evaluation at the proposed value `t = e^{2πi/3}` (primitive cube root `ω`)

Using `ω² + ω + 1 = 0` (equivalently `ω³ = 1`):

* `V_trefoil(ω) = -ω² + 1 + ω²  = 1`
* `V_fig8(ω)    =  ω - ω² + 1 - ω + ω² = 1`
* `V_unknot(ω)  = 1`

**All three equal 1.** Hence `log|V(ω)| = 0` for every thought.  The proposed
information content is identically zero — it cannot distinguish any thought from
no thinking.  (Formalized: `quantumDimension_cubeRoot_collapses`.)

This is a manifestation of the classical special value of the Jones polynomial at
a primitive cube root of unity.

## 3. Evaluation at the correct value `t = e^{iπ/3}` (primitive sixth root `ζ`)

Using `ζ² - ζ + 1 = 0` (equivalently `ζ³ = -1`):

* `V_trefoil(ζ) = 1 - 2ζ`,  `|1 - 2ζ|² = 3`,  so `|V_trefoil(ζ)| = √3`.
* `V_fig8(ζ)    = -1`,        `|V_fig8(ζ)| = 1`.
* `V_unknot(ζ)  = 1`,         `|V_unknot(ζ)| = 1`.

So the corrected quantum dimension `log|V(ζ)|` is:

| Thought  | `log|V(ζ)|`        |
|----------|--------------------|
| trivial  | `0`                |
| creative | `½·log 3 ≈ 0.549`  |
| confused | `0`                |

**Creativity is detected; "confusion" is not.**  The figure-eight is
quantum-indistinguishable from no thinking (it has no `ℤ/3` Fox colourings).
(Formalized: `quantumDimension_sixthRoot_discriminates`.)

## 4. Distinctness of the full polynomials

Evaluating at `t = 2`:

* `V_trefoil(2) = -1/16 + 1/8 + 1/2 = 9/16`
* `V_fig8(2)    = 1/4 - 1/2 + 1 - 2 + 4 = 11/4`
* `V_unknot(2)  = 1`

All three are distinct, so the three knots are genuinely inequivalent: the full
Jones polynomial *does* separate the thoughts even though single root-of-unity
evaluations do not.  (Formalized: `jones_polynomials_distinct`.)

## 5. Braid / process-level companion (writhe)

For the braid representatives, the catalog writhe (exponent sum) gives:

* `writhe(σ₀³) = 3`      (creative)
* `writhe((σ₀σ₁⁻¹)²) = 0` (confused)
* `writhe(1) = 0`         (trivial)

so the scalar writhe also detects creativity but is blind to the confused
process, which is nonetheless non-trivial (its image in `S₃` is a non-identity
permutation).  (Formalized: `writhe_insufficient`.)

## Counterexample hunt summary

The single universal claim under test — "`log|V(e^{2πi/3})|` distinguishes these
thoughts" — is falsified on the very first non-trivial sample (the trefoil):
`V(e^{2πi/3}) = 1`.  No search was needed; the collapse is exact and total.
