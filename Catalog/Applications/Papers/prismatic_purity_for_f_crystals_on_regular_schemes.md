# Computational Evidence — Prismatic Purity for F-Crystals

We give concise evidence for the two formalized pillars: **faithfulness of restriction**
(an injectivity phenomenon) and the **dimension-one Hartogs/normality** input.

## 1. Dimension-one extension (normality): small cases over ℤ ⊆ ℚ

A rational number `q` "extends" (is a global section) iff it is an algebraic integer.
Testing `q = a/b` in lowest terms against monic integer polynomials:

| q       | monic ℤ-poly with root q?            | integral over ℤ? | in ℤ? | consistent |
|---------|--------------------------------------|------------------|-------|------------|
| 3       | x − 3                                | yes              | yes   | ✓          |
| −2      | x + 2                                | yes              | yes   | ✓          |
| 1/2     | none (rational root thm: ±1)         | no               | no    | ✓          |
| 2/3     | none                                 | no               | no    | ✓          |
| 5/1     | x − 5                                | yes              | yes   | ✓          |

Rational-root theorem ⇒ a rational integral over ℤ must have denominator 1. No
counterexample exists: this is exactly `ℤ` integrally closed in `ℚ` (`hartogs_Z`).

## 2. Non-example confirming the hypothesis is load-bearing

Take the non-maximal order `R = ℤ[2i] ⊂ ℤ[i] ⊂ ℚ(i)` (not integrally closed).
The element `i` satisfies `x² + 1 = 0`, monic over `R`, so `i` is integral over `R`.
But `i ∉ ℤ[2i]`. Hence the extension statement **fails** without normality — confirming
`hartogs_dim_one`'s `[IsIntegrallyClosed R]` hypothesis is necessary, not cosmetic.

## 3. Faithfulness over ℤ (generic-point restriction)

The restriction map `ℤ → ℚ` (`rhoZQ`) is injective (ℤ is a domain). Sample check that a
ℤ-linear endomorphism of the trivial crystal is recovered from its ℚ-restriction:

| endo on ℤ (mult. by k) | restriction to ℚ (mult. by k) | recovered? |
|------------------------|-------------------------------|------------|
| ×0                     | ×0                            | yes        |
| ×1                     | ×1                            | yes        |
| ×7                     | ×7                            | yes        |
| ×(−3)                  | ×(−3)                         | yes        |

Distinct ℤ-endomorphisms have distinct ℚ-restrictions ⇒ faithfulness holds, matching
`trivZ_faithful` / `restriction_faithful`.

## 4. OEIS

No integer sequence is central to the claim; the content is structural (injectivity +
integral closedness), so no OEIS lookup applies.

## Conclusion

All small cases are consistent with the formalized theorems; the single non-example
pins down exactly where the regularity/normality hypothesis is required.
