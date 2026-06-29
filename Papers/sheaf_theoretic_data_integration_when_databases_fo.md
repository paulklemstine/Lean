# Computational Evidence — Sheaf-Theoretic Data Integration

The headline results are *universal* sheaf-theoretic statements (gluing, separation,
consistency ⇔ integrability), proved directly and machine-checked in Lean 4 in
`Catalog/Cryptography/SheafDataIntegration.lean` (0 sorries; axioms: `propext`,
`Classical.choice`, `Quot.sound`). The Lean kernel check *is* the verification, so heavy
numerical experimentation is unnecessary. We record the small-case sanity checks that
guided the formalization.

## 1. Two-table merge (smallest nontrivial gluing)
Keys `K = {a, b, c}`, values in `ℤ`.
- Table `r₀` on `S₀ = {a, b}`: `a ↦ 1, b ↦ 2`.
- Table `r₁` on `S₁ = {b, c}`: `b ↦ 2, c ↦ 3`.
- Overlap `S₀ ∩ S₁ = {b}`: both give `b ↦ 2` ⇒ consistent.
- Predicted unique merge on `{a,b,c}`: `a ↦ 1, b ↦ 2, c ↦ 3`. ✓ (matches
  `exists_unique_merge_two`).
- Inconsistent variant `r₁'(b) = 5` violates `hagree`; no merge exists ⇒ matches
  `exists_glue_iff_consistent` (the ∃-glue side fails because consistency fails).

## 2. Separation on a 2-set cover
With the cover above, a global record over `{a,b,c}` is fully determined by its
restrictions to `{a,b}` and `{b,c}` (their union is everything). Hand-checking all
assignments confirms restriction is injective on the cover — the content of
`glue_eq_of_locally_eq`.

## 3. H0 / global sections on small graphs (constant sheaf, values in `ℤ`)
- Discrete graph on `Fin n` (no edges): every function is a section ⇒ `H0 = ⊤`,
  `dim = n` connected components. (e.g. `n = 2`: the section `0,1` is global.)
- Path / complete graph on `Fin 3` (connected): sections are exactly the constants ⇒
  `dim = 1`. Evaluation at any vertex is a bijection onto `ℤ`, matching
  `globalSections_eval_injective_of_connected`.
- These match `finrank_H0_eq_card_connectedComponent` from the catalog reference
  `CellularSheafCohomology.lean`.

## 4. Counterexample hunt
- *Claim tested:* "pairwise-consistent ⇒ jointly consistent for plain records." On all
  hand-enumerated 3-set covers of `{a,b,c}` no counterexample appears (consistent with
  Conjecture 3). The conjectured boundary — failure once stalks carry nontrivial transition
  maps — is left to the next cycle.
- No OEIS sequence is involved (the objects are sheaves/submodules, not integer
  sequences); `dim H0 = #components` is the only numeric invariant and it is already a
  proved catalog theorem.
