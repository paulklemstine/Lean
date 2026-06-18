Develop a single standalone Lean 4 file formalizing a precise counterexample-based fragment of the 'periodic table of finite groups' idea. Do not attempt a broad taxonomy or speculative classification. The file should contain only coherent material about minimal normal subgroups, simple groups, and one explicit lossy invariant that fails to determine group order.

Target theorem package:

1. Define `IsMinimalNormal (N : Subgroup G)` to mean: `N.Normal`, `N ≠ ⊥`, and every normal subgroup `M ≤ N` with `M ≠ ⊥` satisfies `M = N`.

2. Prove the basic simple-group structure lemmas:
   - In a simple group, every nontrivial normal subgroup is `⊤`.
   - Therefore `⊤` is a minimal normal subgroup in a simple group.
   - Therefore every minimal normal subgroup in a simple group is `⊤`, i.e. uniqueness of the minimal normal subgroup.

3. Specialize to the finite commutative/abelian simple case:
   - Prove a finite commutative simple group has prime cardinality.
   - If the exact existing API permits, derive an isomorphism with a standard prime-order cyclic model already in mathlib, preferably `Multiplicative (ZMod p)` or an equivalent cyclic additive form.
   - If the isomorphism theorem is too API-heavy, it is acceptable to stop at the prime-cardinality theorem, but only if all previous results are complete and polished.

4. End with one explicit negative result about coarse composition-factor data:
   - Do NOT use vague language like 'periodic table' in theorem statements.
   - Define a deliberately lossy invariant that forgets multiplicity, such as the set of prime orders appearing among composition factors, or a similarly concrete support invariant that is actually easy to compute for the examples.
   - Use a fully explicit pair of finite groups, preferably `Multiplicative (ZMod 4)` and `Multiplicative (ZMod 2) × Multiplicative (ZMod 2)` or equivalent additive versions, to show the invariant agrees but the group orders differ.
   - Keep this elementary: the point is a clean counterexample, not a full Jordan–Hölder development.

Requirements:
- Produce complete theorem statements and proofs only; no placeholders, no omitted bodies, no unrelated material.
- Prefer already-verified mathlib/group-theory infrastructure over ambitious custom definitions.
- If composition-factor APIs are awkward, define the lossy invariant directly for the chosen explicit examples and prove equality of the invariant plus inequality of cardinalities/orders.
- Keep the file tightly scoped and self-contained.

Suggested structure:
- Section 1: definition of `IsMinimalNormal`
- Section 2: simple groups imply unique minimal normal subgroup
- Section 3: finite commutative simple groups have prime cardinality
- Section 4: explicit counterexample showing multiplicity-forgetting factor data does not determine order

The final result should read as a rigorous counterexample program: some structural invariants are meaningful, but coarse support-only factor data is insufficient.