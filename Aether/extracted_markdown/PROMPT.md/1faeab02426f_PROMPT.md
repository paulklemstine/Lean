Create one complete Lean 4 file formalizing a small, self-contained theory of finite Dung argumentation frameworks via conflict-free sets. Do not aim for a broad research paper; aim for a fully compiling, placeholder-free formalization.

Scope and priorities:
1. Work with a type `α` (preferably `[Fintype α] [DecidableEq α]` only when needed) and a binary relation `attacks : α → α → Prop`.
2. Define `ConflictFree attacks (S : Set α) : Prop` meaning no `a,b ∈ S` satisfy `attacks a b`. Self-attacks should be included in the prohibition.
3. Prove the hereditary/downward-closed property:
   `T ⊆ S → ConflictFree attacks S → ConflictFree attacks T`.
   This is the core result and should be fully proved.
4. Refute the false idea that preferred extensions form a simplicial complex. Keep this elementary and explicit:
   - Define only the minimum needed notions for a tiny counterexample: `defends`, `Admissible`, `Preferred` (as maximal admissible by inclusion).
   - Use a 2-argument framework with no attacks. Then `{a,b}` is preferred, but `{a}` is not preferred, so the family of preferred extensions is not downward closed.
   - If maximality formalization is cumbersome, simplify the target theorem to a direct statement that there exists a framework and sets `T ⊂ S` with `Preferred S` but not `Preferred T`.
5. Define the undirected conflict graph `conflictGraph attacks : SimpleGraph α` with adjacency `attacks a b ∨ attacks b a`, packaged so graph irreflexivity is respected. The cleanest route is to assume `h_irrefl : Irreflexive attacks` when defining/proving graph facts.
6. Prove the central equivalence under `Irreflexive attacks`:
   `ConflictFree attacks S ↔ (conflictGraph attacks).IsIndepSet S`.
7. Add only a few small corollaries if easy and already supported by the APIs:
   - `ConflictFree attacks ∅`
   - singleton conflict-free under irreflexivity
   - a pair `{a,b}` is conflict-free iff `a ≠ b` and neither attacks the other (or the corresponding graph nonadjacency statement)

Instructions:
- Prefer `Set α` throughout unless `Finset` is clearly easier for a specific lemma.
- Keep all theorem statements precise and modest. No placeholders, no `sorry`, no truncated proofs.
- Avoid introducing a bespoke simplicial-complex structure unless there is an existing Mathlib definition you can use immediately. A downward-closed family of subsets is sufficient.
- If preferred-extension machinery becomes too long, reduce it to the minimum necessary for the explicit no-attack 2-point counterexample; completeness is more important than generality.
- Include module docstrings and concise comments, but prioritize verified proofs.

Deliverable: one fully compiling Lean file with the definitions and theorems above, focused on correctness and minimality.