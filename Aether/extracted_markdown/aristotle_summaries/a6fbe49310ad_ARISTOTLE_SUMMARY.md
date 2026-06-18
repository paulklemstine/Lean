# Summary of changes for run 808e7365-b7c2-4d24-baef-e8ecf6036ed3
Created a single, self-contained Lean 4 file `Logic/Dung.lean` formalizing a small theory of finite Dung argumentation frameworks via conflict-free sets. It compiles cleanly (no `sorry`, no extra axioms — proofs use only the standard `propext`/`Classical.choice`/`Quot.sound`).

Contents (all over `Set α`, with no unnecessary `Fintype`/`DecidableEq`):

- `ConflictFree attacks S` — no two members (self-attacks included) are related by `attacks`.
- `ConflictFree.subset` — the core hereditary/downward-closure result: `T ⊆ S → ConflictFree attacks S → ConflictFree attacks T`.
- Small corollaries: `conflictFree_empty`, `conflictFree_singleton` (under irreflexivity), and `conflictFree_pair_iff` (a pair is conflict-free iff no attack holds among its members).
- Minimal admissibility machinery: `Defends`, `Admissible`, `Preferred` (maximal admissible by inclusion).
- `preferred_not_downward_closed` — an explicit refutation that preferred extensions form a simplicial complex: in the two-argument, no-attack framework on `Bool`, `{true} ⊂ univ`, `univ` is preferred, but `{true}` is not, so the family is not downward closed.
- `conflictGraph attacks h_irrefl : SimpleGraph α` with adjacency `attacks a b ∨ attacks b a`, with looplessness discharged from `h_irrefl : Irreflexive attacks`, plus a `@[simp]` adjacency lemma `conflictGraph_adj`.
- `conflictFree_iff_isIndepSet` — the central equivalence under irreflexivity: `ConflictFree attacks S ↔ (conflictGraph attacks h_irrefl).IsIndepSet S`.
- `conflictFree_pair_iff_not_adj` — the graph reading of the pair corollary.

Note: the project's Mathlib version emits benign deprecation warnings for `Irreflexive` (suggesting `Std.Irrefl`); `Irreflexive attacks` was kept since the task explicitly requested it, and it still elaborates correctly.

The file lives at `Logic/Dung.lean` (module `Logic.Dung`), matching the project's `Logic.+` library glob, and builds via `lake build Logic.Dung`.