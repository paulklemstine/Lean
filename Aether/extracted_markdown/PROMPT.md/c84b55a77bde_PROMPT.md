Produce exactly one new Lean file in the existing ladder-system / simulation-preorder development, and do not work on any other topic. The previous attempt drifted into expander walks and was unusable. This retry must formalize only the requested intermediate ladder system.

Target task:
1. Work in the proof-complexity framework already present in the catalog, using the existing definitions and lemmas for simulation systems, ladder systems, `powSystem`, and `degree`.
2. Define an explicit system `interPowSys (k : ℕ)` for the relevant admissible range of `k` (preferably `1 ≤ k`, matching the original concept). Its defining size function should be a parity-splitting interpolation between `powSystem k` and `powSystem (k+1)`: even arguments follow the size behavior of `powSystem k`, odd arguments follow the size behavior of `powSystem (k+1)`, unless the catalog’s existing API suggests a definitionally equivalent piecewise formulation that is easier to prove with.
3. Prove the main theorem(s):
   - `degree (powSystem k) < degree (interPowSys k)`
   - `degree (interPowSys k) < degree (powSystem (k+1))`
   for all admissible `k`.
4. Include any necessary helper lemmas about parity cases, monotonicity/comparison of the relevant size functions, and any API lemmas needed to compute or bound degrees. Keep these helper lemmas tightly scoped to this task.

Hard constraints:
- Depend only on the existing simulation-preorder / ladder-system files already in the catalog; prefer FINAL catalog files where available.
- Do not introduce any external mathematical themes, abstractions, or imports beyond what this local development needs.
- Do not write a research essay, narrative prose, or pseudocode. Deliver actual Lean code only.
- No `sorry`, no placeholders, no theorem-name stubs, no malformed declarations.
- The file should be self-contained and coherent: definitions first, then helper lemmas, then the final strict degree inequalities.
- If the exact names in the local API differ, adapt to the existing names, but preserve the mathematical content above.

Recommended strategy:
- First inspect the existing `powSystem` and `degree` definitions and identify the lemmas already available for comparing degrees via asymptotic/pointwise size-function comparisons.
- Define `interPowSys` in the simplest way that makes parity case splits immediate by `Nat.even_or_odd` or equivalent lemmas.
- Prove explicit comparison lemmas showing its size function lies strictly between those of `powSystem k` and `powSystem (k+1)` often enough / in the right asymptotic sense required by the existing `degree` API.
- Then package those comparisons into the two strict degree inequalities.

Success criterion:
A single compilable sorry-free Lean file whose main exported results are the definition of `interPowSys` and the two strict inequalities between the degrees of adjacent power systems and the intermediate system.