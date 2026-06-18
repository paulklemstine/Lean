## Task: Minimal 1-Lipschitz Rank Functor on Persistence Modules

Produce a **single, self-contained Lean 4 file** containing exactly three theorems with complete proof terms (no `sorry`, no headers without bodies, no extraneous content from other projects).

### Mathematical Setup

Given a finite type `β`, a persistence module `M : PersMod (Set β)` assigns to each scale `t` a subset `M.obj t : Set β`, with inclusions `M.map (t ≤ t+h) : M.obj t ⊆ M.obj (t+h)`. The **rank functor** sends `M` to the ℕ-valued persistence module `rankMod M` where `(rankMod M).obj t = ncard (M.obj t)`.

### Three Theorems to Prove

1. **`rankMod_monotone`**: For `M : PersMod (Set β)` and `h ≥ 0`, `ncard (M.obj t) ≤ ncard (M.obj (t + h))`. This follows from `Set.ncard_le_ncard` applied to `M.map (t ≤ t+h)`.

2. **`rank_preserves_interleaving`**: If `Interleaved ε M N` in `PersMod (Set β)`, then `Interleaved ε (rankMod M) (rankMod N)` in `PersMod ℕ`. Proof: the ε-interleaving gives four inclusions `M.obj t ⊆ N.obj (t+ε)`, `N.obj t ⊆ M.obj (t+ε)`, etc. Push each through `Set.ncard_le_ncard` to get the required ℕ-valued inequalities.

3. **`rank_interleavingDist_le`**: `interleavingDist (rankMod M) (rankMod N) ≤ interleavingDist M N`. This follows from (2) by sInf-monotonicity: if every ε in the interleaving set of M,N is also in the interleaving set of rankMod M, rankMod N, then the infimum can only be smaller.

### Constraints

- The file must compile (or be very close to compiling) in Lean 4 with Mathlib.
- Use only standard Mathlib imports.
- Define `PersMod` and `Interleaved` if not importable from the catalog.
- Do NOT include any content about species, ordEGF, tropical valuations, Hodge Laplacians, neural systems, or lambda calculus.
- Every `def` and `theorem` must have a body (no header-only declarations).
- The entire file should be under 200 lines.