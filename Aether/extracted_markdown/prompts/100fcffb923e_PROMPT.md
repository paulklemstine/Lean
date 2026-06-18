Formalize a narrowly scoped, fully self-contained core of one-variable min-plus tropical polynomial theory over `ℤ` in a single Lean 4 file with no `sorry`s. Stay entirely within the Tropical domain and do not introduce any entropy, compression, information theory, or cross-domain bridge material.

Target file goals:

1. Define tropical operations on integers:
- `tadd : ℤ → ℤ → ℤ := min`
- `tmul : ℤ → ℤ → ℤ := fun a b => a + b`

2. Prove the elementary laws actually needed later, such as commutativity/associativity of `tadd`, commutativity/associativity of `tmul`, distributive-style monotonicity facts if useful, and simple evaluation lemmas for `min` and integer addition. Do not try to build an abstract semiring instance unless it is genuinely helpful; concrete lemmas are preferred.

3. Define one-variable tropical monomials and finite tropical polynomials:
- A monomial is represented by a pair `(m, c)` with `m : ℕ`, `c : ℤ`, interpreted as the affine function `x ↦ (m : ℤ) * x + c`.
- A tropical polynomial is a finite `List (ℕ × ℤ)`.
- Define evaluation of a polynomial at `x : ℤ` as the minimum of the values of its monomials. Since empty lists are awkward, either:
  - define evaluation only for a nonempty polynomial structure, or
  - define list evaluation with a separate theorem family only for singleton/cons/nonempty cases.
Choose the representation that yields the cleanest proofs.

4. Prove complete classification results for very small families:
- Singleton classification: evaluation of `[(m,c)]` is exactly `(m : ℤ) * x + c`.
- Constant classification: if every monomial in the list has slope `0`, then the polynomial evaluates to the constant function given by the minimum intercept appearing in the list.
- Two-term classification for the family `[(0,a),(1,b)]`: evaluation is exactly `min a (x + b)`.

5. Define tropical roots concretely for a finite list of monomials: `x` is a root if there exist two distinct monomials in the list whose values at `x` both equal the polynomial minimum. Use a definition that is easy to reason about for the two-term family, even if it is specialized to lists with decidable equality.

6. Prove the full root classification for `[(0,a),(1,b)]`:
- If `a < b`, then there are no roots.
- If `b ≤ a`, then the roots are exactly the singleton `{a - b}`.
- Deduce in all cases that the root set has cardinality at most one.

Implementation guidance:
- Prefer explicit, concrete integer calculations over abstract algebra.
- Keep the development self-contained and robust: prove the exact lemmas you use.
- Use `linarith`, `omega`, or direct integer arithmetic lemmas where helpful, but avoid unnecessary automation if simple proofs suffice.
- The final artifact should be one compiling file, tightly focused on these definitions and theorems.
- Include brief module docstrings explaining the mathematical setup.

Success criterion: a complete Lean file, no truncation, no placeholders, no `sorry`s, and no drift into unrelated domains.