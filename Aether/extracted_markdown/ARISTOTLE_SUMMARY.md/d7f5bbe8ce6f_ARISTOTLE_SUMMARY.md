# Summary of changes for run b0407438-31ce-4648-b3a4-7c718171e5c1
## Cycle Output: Proof-Theoretic Ordinal Analysis III

I produced one new Lean file and the required notes, extending the catalog module `Catalog/Pythagorean/ProofTheoreticOrdinalsLattice.lean`.

### Lean file
`Catalog/Pythagorean/ProofTheoreticOrdinalsWQO.lean` — builds successfully, **0 sorries**, only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). It contains `-- !-- Lab Notebook -- !--` blocks (Hypothesis / Result / Insight / Failure analysis) and `-- !--` proof-sketch comments for each major theorem.

### Theorem declarations (all `proved`)
1. `OrdinalTheory.ext_provablyWO` — a theory is determined by its `provablyWO` set.
2. `OrdinalTheory.compl_nonempty` — boundedness gives a least non-provable ordinal.
3. `OrdinalTheory.charOrd_not_mem` — the characteristic ordinal is non-provable.
4. `provablyWO_eq_Iio` — **classification lemma**: `provablyWO = Iio (charOrd T)`.
5. `theory_eq_ofOrdinal` — every theory is `ofOrdinal (charOrd T)`.
6. `charOrd_ofOrdinal`, `charOrd_le_iff` — `charOrd` inverts `ofOrdinal` and is an order embedding.
7. `theoryOrderIso` — **central result**: `charOrd : OrdinalTheory ≃o Ordinal`, an order isomorphism that explains the catalog's totality structurally.
8. `theory_lt_wellFounded`, `theory_antichain_subsingleton`, `theory_isWQO` — **resolves the catalog's Direction 4 well-quasi-order conjecture** in the strongest form: theory strength is a well-order (well-founded, no nontrivial antichains, every sequence has an ascending pair).
9. `pto_le_charOrd` and the constructive counterexample `pto_lt_charOrd_example` — show the catalog's `pto` is strictly coarser than `charOrd` (witnessed by `ofOrdinal 1`: pto 0 vs charOrd 1), explaining `pto`'s observed non-injectivity.

### Critique / generalization
The Critic isolated that boundedness is used only in `compl_nonempty`, and that `pto`'s defect is exactly successor-collapse; these are turned into falsifiable conjectures (Directions 1 and 4) in the notes.

### Notes
`FUTURE_DIRECTIONS.md` (project root) with the required `## Synthesis`, `## Results Summary`, and 5 `## Research Directions`, each stating Hypothesis / Test / Why now / If true / If false.

The work combines the catalog's abstract ordinal-theory framework with order-isomorphism transport and well-foundedness of `Ordinal`, building on rather than reproving the catalog results.