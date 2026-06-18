# Summary of changes for run 03af7534-b1be-4e08-935b-0f312b9a62ca
Created `Geometry/CliqueComplex.lean` (in the `Catalog` Lean project), a self-contained theory of clique complexes, flag complexes, and the Vietoris–Rips filtration, all built on Mathlib's `SimpleGraph` and `Finset`.

Definitions:
- `vertexSet` (the vertex set of a Mathlib graph, which is all of the type),
- `ASC` (abstract simplicial complex: a downward-closed set of faces),
- a `LE` order on `ASC`,
- `isClique`, `cliqueComplex`, `oneSkel` (one-skeleton), `isFlag`, `vietorisRips`, and `fVector`.

A design note explains why the singleton condition is kept *separate* from the `ASC` structure rather than baked in: Theorem 4 takes it as an explicit hypothesis and Theorem 5 asks whether it can be dropped, so both are only meaningful if singletons are not part of the structure.

All requested theorems have complete, machine-checked proofs (verified to use only the standard axioms `propext`, `Classical.choice`, `Quot.sound`; no `sorry` in any live declaration):
- Theorem 1 `isClique_pair`, Theorem 2 `cliqueComplex_isFlag`, Theorem 3 `oneSkeleton_cliqueComplex`, Theorem 4 `flag_eq_cliqueComplex`, Theorem 6 `vietorisRips_mono`, Theorem 7 `cliqueComplex_fVector_le_choose`.

Two of the originally requested statements were found to be false and were corrected (the originals are preserved verbatim in comments with explanations, per the requirement not to delete user content):
- Theorem 1: false when `a = b` (then `{a,a} = {a}` is a vacuous clique while `G.Adj a a` is false). Corrected by adding the hypothesis `a ≠ b`. The requested vertex-membership hypotheses `ha`, `hb` are kept as asked (they are vacuous, so the build reports them as unused).
- Theorem 5 (`flag_not_cliqueComplex_without_singletons`): false for this formalization of `isFlag`. Because `isFlag` quantifies over all finsets, the flag condition applied to a singleton has a vacuous premise, so every flag complex automatically contains all singletons. This is proved as `isFlag.mem_singleton`, and consequently every flag complex equals the clique complex of its one-skeleton (`isFlag.eq_cliqueComplex`) — the exact opposite of the proposed counterexample, whose witness `{∅}` is not even a flag complex. These corrected statements replace the false existential.

The file compiles cleanly (only the two intentional, documented unused-hypothesis warnings for `ha`/`hb` remain).