# SmoothPoincare pipeline — sorry audit

Scope: the binary self-dual-code → lattice / ℤ-bilinear-form → intersection-form
bridge under `Catalog/Applications/SmoothPoincare/`.

## Files inspected

All nine files of the pipeline were inspected:

- `IntersectionForms.lean` — `IntersectionForm`, `value`, `Unimodular`, `IsEven`,
  `StdDiagonalizable`, `value_basisChange`, `isEven_of_even_diag`,
  `even_not_stdDiagonalizable`, the `E8` form (`E8mat`, explicit inverse `E8inv`,
  `E8_mul_inv`, `E8_unimodular`, `E8_even`, `E8_not_stdDiagonalizable`), `stdForm`,
  `sphereForm`.
- `DirectSum.lean` — block/Gram direct-sum bridge: `reindex_fromBlocks_diag_isSymm`,
  `directSum`, `directSum_unimodular`, `directSum_isEven`,
  `directSum_stdDiagonalizable`, and the `E8 ⊕ E8` corollaries.
- `DirectSumObstruction.lean` — index-type-generic restatement (`GForm`, `dsum`,
  `dsum_unimodular`, `dsum_even`, `dsum_stdDiagonalizable`, `E8_sum_E8_obstruction`).
- `CodeDirectSum.lean` — code-level direct sum (`appendCode`, `wt_append`,
  `ip_append`, `appendCode_selfDual`, `appendCode_doublyEven`,
  `appendCode_length_div_eight`).
- `SelfDualLength.lean` — `selfDual_doublyEven_length_div_four` and the Hamming `[8,4]`
  witness.
- `GleasonLength.lean` — `doublyEven_selfDual_length_div_eight` via the
  Gleason/Fourier (`iwt`, `bchar`, `char_orthogonality`) argument.
- `TopologicalCodes.lean`, `MinimumDistance.lean`, `HomotopySphere.lean` — supporting
  weight/inner-product, minimum-distance, and homotopy-sphere collapse results.

## Sorries filled

None were required: **every declaration in the pipeline is already `sorry`-free.**
A textual scan for `sorry`/`admit` finds matches only inside documentation comments
(the phrase "`sorry`-free"); there are no `sorry`/`admit` tactic occurrences in any of
the nine files. The foundational `IntersectionForms.lean` was re-elaborated
independently against Mathlib to confirm it compiles with no errors.

The bridge lemmas the task prioritizes (direct-sum decomposition and
projection/inclusion identities, block/Gram simplification, determinant /
invertibility for unimodularity, parity/evenness of the form, and the
self-dual-code → self-dual-form translation) are all already present and proven —
chiefly in `DirectSum.lean`, `DirectSumObstruction.lean`, `CodeDirectSum.lean`, and
`IntersectionForms.lean`.

## Gaps intentionally left untouched (outside the pipeline)

- `Catalog/Shared/CarmichaelProof.lean:129` — a `sorry` in a Fibonacci
  primitive-divisor / Carmichael's-theorem proof. Unrelated to the self-dual-code /
  lattice / intersection-form bridge; left untouched.
- `Catalog/Algebra/GroebnerDerandomization.lean` imports
  `Algebra.CircuitComplexity.AlgebraicCircuitComplexity` and
  `Algebra.CircuitComplexity.NullstellensatzPIT`, which do not exist on disk (a
  dangling reference into the polynomial-identity-testing domain). This is explicitly
  outside the SmoothPoincare pipeline and was deliberately not modified or recreated.
