Formalize a complete, self-contained bridge theorem from valuation-depth bounds to a tropical/max-depth semantics, avoiding any unfinished categorical infrastructure.

Target file: `Catalog/Bridges/ValuationDepthTropicalFunctor.lean`

Mathematical goal:
Build a lightweight formalization showing that the existing valuation-depth inequalities from the computation side induce a tropical-style nonexpansive structure with unit overhead, and derive a logarithmic balanced-tree bound. The previous attempt was too broad and declaration-heavy; this version must contain only definitions and theorems that are fully proved and compile without placeholders.

Precise scope:
1. Import the strongest relevant existing valuation-depth file(s) from `Catalog/FINAL/` if available; otherwise use the best existing computation file that actually contains the verified `vdepth` inequalities.
2. Do NOT depend on a large pre-existing categorical tropical framework unless it is already minimal and stable. Instead, define in this file a small tropical target structure sufficient for the theorem: e.g. a `MaxPlusDepth` viewpoint on `ℕ` with combination law controlled by `max` and unit overhead.
3. Bundle the source data into a simple structure such as:
   - a type `α`
   - operations needed for the theorem (for example a binary combine operation, or separate `add`/`mul` if the source file supports them cleanly)
   - a function `depth : α → ℕ`
   - hypotheses/theorems of the form `depth (combine x y) ≤ max (depth x) (depth y) + 1`
   Keep this as small as possible.
4. Prove the central bridge theorem(s): the depth map is 1-step nonexpansive with respect to tropical/max combination. State this directly as a theorem, not as category theory.
5. Define a balanced binary tree datatype or recursive evaluator for combining `2^n` leaves. Prove a theorem of the form: if every leaf has depth `≤ d`, then the balanced evaluation has depth `≤ d + n`. Use a clean recursion on height; avoid unnecessary generality.
6. Include one explicit strictness or non-improvability witness: a theorem showing that in general one cannot replace the unit-overhead inequality by the strict ultrametric/tropical law `depth (combine x y) ≤ max (depth x) (depth y)`. This may use an existing example from the valuation-depth file if available; otherwise package a minimal abstract witness structure and show how it yields strictness.
7. If source lemmas support both addition and multiplication, it is acceptable to prove parallel theorems for both; but only if this remains compact and fully proved.

Implementation guidance:
- Prefer `Catalog/FINAL/` references whenever they already contain the needed verified material.
- Keep all definitions executable and simple.
- No `sorry`, no placeholder declarations, no theorem inventory without proofs.
- If a previous tropical object file is unstable or too abstract, do not use it.
- The end product should read as a standalone bridge theorem with a concrete recursive complexity corollary.

Suggested theorem shape:
- `depth_one_lipschitz`: `depth (combine x y) ≤ max (depth x) (depth y) + 1`
- `depth_balanced_pow_two_le`: balanced tree of height `n` on leaves of depth `≤ d` has result depth `≤ d + n`
- `depth_not_strict_ultrametric`: an explicit witness where equality to `max + 1` (or at least strictness over `max`) occurs

Deliverable standard:
A single compiling Lean file with complete proofs, modest abstractions, and statements strong enough to justify the title “valuation-depth to tropical/max-depth bridge”.