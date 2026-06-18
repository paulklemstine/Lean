Formalize a complete Lean 4 file establishing density between consecutive `powSystem` rungs in the proof-complexity degree lattice, rather than pursuing the original quantum-code threshold conjecture. Work entirely within the existing proof-complexity framework in the catalog.

Precise target: for each natural `k` with `1 ≤ k`, define an explicit size system `interPowSys k` that agrees with the faster growth `2 ^ (n ^ (k+1))` on one parity class of inputs and the slower growth `2 ^ (n ^ k)` on the other parity class, then prove that its degree lies strictly between `powSystem k` and `powSystem (k+1)`.

Required deliverables:
1. A new file, preferably `Catalog/Logic/ProofComplexity/LadderDensity.lean`.
2. No `sorry`s, placeholders, or unfinished declarations.
3. Final theorems of the following shape (names can vary slightly to fit local conventions):
   - a definition of `interPowSys k`
   - `powSystem k ≤ interPowSys k`
   - `¬ interPowSys k ≤ powSystem k` or directly the strict inequality needed
   - `interPowSys k ≤ powSystem (k+1)`
   - `¬ powSystem (k+1) ≤ interPowSys k`
   - hence `powSystem k < interPowSys k`
   - hence `interPowSys k < powSystem (k+1)`
   - and finally `∃ S, powSystem k < S ∧ S < powSystem (k+1)` for `k ≥ 1`

Suggested proof strategy:
- Reuse the catalog’s simulation preorder and domination characterizations, especially any theorem equivalent to `simulates_sysOfSize_iff`.
- Build `interPowSys k` as a parity-based piecewise size function.
- For lower-bound separation, use the parity subsequence where `interPowSys k` takes the faster rate to show it eventually dominates `powSystem k` too strongly for converse simulation.
- For upper-bound separation, use the parity subsequence where `interPowSys k` falls back to the slower rate, together with the existing asymptotic gap between `n^k` and `n^(k+1)` inside exponentials, to refute simulation from `powSystem (k+1)` into `interPowSys k`.
- If a strong “for all sufficiently large n” growth-gap lemma is missing, first prove a reusable auxiliary lemma specialized to the exact exponential-polynomial rates needed here.

Important constraints:
- Stay in the proof-complexity domain; do not introduce unrelated coding-theory or tropical material.
- Prefer building directly on the strongest existing final catalog files.
- Keep statements concrete and machine-checkable.
- If the strict-order API uses degree quotients rather than raw systems, adapt the statements accordingly, but ensure the mathematical content remains: an explicit intermediate degree between consecutive ladder rungs.

A good outcome is a clean, self-contained formal theorem showing the ladder is dense at every adjacent pair by an explicit parity-glued witness.