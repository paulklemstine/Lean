Produce a single Lean 4 file formalizing a self-contained theorem package for strict density between consecutive polynomial-growth systems under eventual domination. Keep the scope narrow and executable: no unrelated abstraction layers, no spectral/Hodge narrative, no placeholder classes, and no unfinished theorem skeletons.

Target file content:

1. Define a structure `PSystem` with one field `size : ℕ → ℕ`.
2. Define the simulation relation `SimLe : PSystem → PSystem → Prop` by
   `S ≼ T :↔ ∃ N, ∀ n ≥ N, S.size n ≤ T.size n`.
   Provide only the order-theoretic lemmas actually needed:
   - reflexivity
   - transitivity
   - notation if convenient
   - a definition of strict comparison `S ≺ T := S ≼ T ∧ ¬ T ≼ S`
   Avoid building a large `Preorder` instance unless it is genuinely used cleanly.
3. Define `powSystem k : PSystem` by `size n = n ^ k`.
4. For `k ≥ 1`, define the explicit intermediate witness
   `interPowSys k : PSystem` by
   - if `Even n` then `n^(k+1)`
   - else `n^k`.
5. Prove the two domination directions:
   - `powSystem k ≼ interPowSys k` (threshold `N = 0` should work)
   - `interPowSys k ≼ powSystem (k+1)` (again threshold `N = 0` should work)
6. Prove the two non-domination statements needed for strictness:
   - `¬ interPowSys k ≼ powSystem k` for `k ≥ 1`
   - `¬ powSystem (k+1) ≼ interPowSys k` for `k ≥ 1`
   These should be proved by contradiction from an arbitrary eventual bound threshold `N`, then choosing explicit large witnesses of the appropriate parity:
   - an even witness `n = 2 * max N 1` or similar for the first
   - an odd witness `n = 2 * N + 1` or similar for the second.
   The arithmetic should be elementary and explicit. Prefer proving small helper lemmas such as:
   - for `k ≥ 1`, `n ≤ n^k`
   - hence for positive even/odd `n`, `n^k < n^(k+1)` when `n ≥ 2`
   If a more convenient statement is needed, prove it locally in the file.
7. Conclude the main theorem, for `k ≥ 1`:
   `powSystem k ≺ interPowSys k ∧ interPowSys k ≺ powSystem (k+1)`.
   Also package a corollary stating that there exists `U` with
   `powSystem k ≺ U ∧ U ≺ powSystem (k+1)`.

Technical guidance:
- Prioritize a fully checked, `sorry`-free file over elegance.
- Use only basic `Nat` lemmas, parity facts, and simple power inequalities.
- Keep all definitions and proofs local to this file unless a standard Mathlib lemma is directly available.
- Avoid introducing quotient orders, equivalence classes, or degree structures unless absolutely necessary.
- If a preorder instance causes friction, use explicit lemmas instead of typeclass machinery.
- Include concise module documentation explaining the model and the parity-gluing idea, but make the Lean theorems themselves the main deliverable.

The intended final result is a robust, minimal formalization of an explicit intermediate asymptotic degree between `n^k` and `n^(k+1)` for every `k ≥ 1`.