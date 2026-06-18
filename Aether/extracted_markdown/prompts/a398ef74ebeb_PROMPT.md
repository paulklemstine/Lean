Develop a single Lean 4 file formalizing a compact, fully checked arithmetic stability core for `padicValNat p` on natural numbers. Do not include broad motivation text, tropical language, categorical abstractions, or list-level extensions unless the core is already complete. The goal is to produce a file whose main theorems are all fully proved and typechecked.

Target theorem suite:

1. A divisibility criterion for valuation depth on naturals. For prime `p`, prove a lemma of the form
`k ≤ padicValNat p n ↔ p ^ k ∣ n`
under the necessary side conditions (typically `n ≠ 0`, and use whatever exact assumptions Mathlib's existing lemmas require). If Mathlib already has this equivalence in a slightly different form, wrap it into a local theorem with a clean API.

2. Multiplicativity on products. Prove a theorem of the form
`padicValNat p (m * n) = padicValNat p m + padicValNat p n`
for prime `p`, with hypotheses arranged so the statement is literally true in `ℕ`. If zero causes definitional issues, handle it explicitly by hypotheses like `m ≠ 0`, `n ≠ 0`, or by splitting cases and proving the exact valid statement.

3. Ultrametric lower bound for sums. Prove
`min (padicValNat p m) (padicValNat p n) ≤ padicValNat p (m + n)`
in the regime where the statement is valid and useful. Preferred proof strategy: let `a = min ...`, obtain divisibility `p^a ∣ m` and `p^a ∣ n` from the criterion in (1), then deduce `p^a ∣ m+n`, and conclude via the same criterion.

4. Sharp isosceles law. Prove
`padicValNat p m < padicValNat p n → padicValNat p (m + n) = padicValNat p m`
under the necessary nonzero/prime hypotheses. Preferred proof strategy: set `a = padicValNat p m`; factor `m` as `p^a * u` with `¬ p ∣ u`, factor `n` as `p^a * (p * t)` using the strict inequality, rewrite
`m + n = p^a * (u + p*t)`,
and show `¬ p ∣ (u + p*t)` from `¬ p ∣ u`. Then conclude the valuation is exactly `a`. If a direct factorization API is awkward in Mathlib, use existing lemmas characterizing maximal divisibility and divisibility of sums to reach the same conclusion.

Implementation constraints:
- Keep the file small and self-contained.
- Every theorem stated in the file must have a complete proof; no placeholders, no truncated declarations, no commented theorem headers.
- Prefer reusing existing Mathlib lemmas about `padicValNat` rather than rebuilding the theory from scratch.
- If a theorem as stated is false without extra hypotheses, weaken it explicitly and document the exact valid version in the theorem name or docstring.
- Do not spend time on `list_prod`, `list_sum`, perturbation corollaries, or powers unless the four core items above are complete.

Deliverable:
A complete Lean file in an appropriate catalog location, with concise module docs listing only the theorems actually proved. The file should compile as-is against Mathlib.

Suggested structure:
- namespace `PadicDepthCore` or similar
- local helper lemmas wrapping Mathlib facts
- theorem `le_iff_pow_dvd` (or equivalent)
- theorem `mul`
- theorem `ultrametric_add`
- theorem `isosceles`

The key requirement is completeness and correctness of a narrow theorem package, not breadth.