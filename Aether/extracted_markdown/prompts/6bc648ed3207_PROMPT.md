Build the actual complete Lean development for the original metric-filtration/single-linkage direction, not the unrelated β/Nerode/LTS bridge from the failed attempt.

Target a small, fully typechecked, finite combinatorial core in one coherent domain.

Create a complete file (or two staged files if cleaner) formalizing finite single-linkage via threshold graphs on a finite type. Use only definitions and lemmas that you can fully prove without `sorry`.

Precise task:
1. Let `α` be a finite type with decidable equality. Let `d : α → α → ℝ` (or `ℚ` if this materially simplifies proofs) satisfy symmetry, and optionally `d x x = 0` if needed.
2. Define the symmetrized Rips/threshold graph `ripsGraphOf d ε` whose edge relation is `d x y ≤ ε ∨ d y x ≤ ε` (if `d` is assumed symmetric, simplify to `d x y ≤ ε`).
3. Define `ConnAt d ε x y` as graph reachability / connectedness in this finite graph.
4. Prove the core finite facts:
   - `ConnAt` is an equivalence relation.
   - Monotonicity in threshold: if `ε₁ ≤ ε₂` then `ConnAt d ε₁ x y → ConnAt d ε₂ x y`.
   - Every edge gives connectivity.
   - Connectivity is equivalent to existence of a finite chain with successive distances `≤ ε`.
5. Define the single-linkage cluster partition at threshold `ε` as the quotient by `ConnAt d ε` (or an equivalent finite partition representation already available in Mathlib if easier).
6. Prove canonicity/extensionality results that are genuinely useful later:
   - If two distance functions agree pointwise, their `ConnAt` relations and cluster partitions agree.
   - Threshold monotonicity induces partition coarsening.
   - On a finite type, the construction depends only on the finite comparison data and requires no global minimization over `ℝ`.
7. If feasible, add one theorem connecting this to filtration language: the family `ε ↦ ConnAt d ε` is monotone, hence defines a finite filtration of equivalence relations/partitions.

Requirements:
- Stay tightly focused on this finite single-linkage combinatorial layer.
- Do not introduce unrelated λ-calculus, bisimulation, Nerode, automata, or broad catalog-style scaffolding.
- Prefer simple, robust definitions over ambitious abstractions.
- Provide the actual Lean code that compiles, with no `sorry`s.
- If quotient-level partition APIs become cumbersome, it is acceptable to stop at a clean equivalence relation plus a coarsening theorem, as long as all statements are complete and proved.

Why this revision: the prior attempt drifted into an unrelated and over-ambitious domain and produced only partial scaffolding. This version follows the original direction exactly and isolates a finite theorem pipeline that is concrete, checkable, and likely to succeed.