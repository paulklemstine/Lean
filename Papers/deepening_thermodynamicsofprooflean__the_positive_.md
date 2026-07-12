# Computational Evidence — The Kernel Law

The central claim is `erasedBits f = log₂|ker f|` for a homomorphism `f : G → H` between finite
groups, together with exact additivity along a surjective first step. We sanity-checked the
counting backbone `|image f| · |ker f| = |G|` and the additivity identity on small groups.

## Small-case checks of `|image f| · |ker f| = |G|`

- **Sign map `S₃ → ℤ/2`.** `|S₃| = 6`, image is all of `ℤ/2` (size 2), kernel is `A₃` (size 3).
  `2 · 3 = 6`. Erased bits `= log₂ 3 ≈ 1.585`.
- **Reduction `ℤ/4 → ℤ/2`.** Domain size 4, image size 2, kernel `{0,2}` size 2.
  `2 · 2 = 4`. Erased bits `= log₂ 2 = 1` (one full bit, matching the AND-gate reference).
- **Trivial map `G → 1`.** Image size 1, kernel `G`. Erased bits `= log₂|G|`, the total capacity
  — consistent with the base theory's `collapse` family.
- **Identity `G → G`.** Kernel trivial, erased bits `= log₂ 1 = 0` — reversible, as required.

## Additivity along a surjection

- **`ℤ/4 → ℤ/2 → 1`.** First map surjective, kernels of sizes 2 and 2; composite kernel is all of
  `ℤ/4`, size 4. Check `log₂ 4 = log₂ 2 + log₂ 2`, i.e. `2 = 1 + 1`. Additivity holds.
- **Contrast (non-surjective first step).** Embedding `ℤ/2 ↪ ℤ/4` followed by `ℤ/4 → 1`: the
  embedding erases 0 bits, the second erases `log₂ 4 = 2`, but the composite `ℤ/2 → 1` erases only
  `log₂ 2 = 1 ≠ 0 + 2`. Sub-additivity, not additivity — exactly the failure mode the surjectivity
  hypothesis rules out.

## Conclusion

Every small case matches the kernel law and the surjective-additivity theorem, and the
non-surjective contrast confirms that additivity genuinely requires exactness rather than holding
for free. No counterexample was found. The formal proofs generalize these checks to all finite
groups.
