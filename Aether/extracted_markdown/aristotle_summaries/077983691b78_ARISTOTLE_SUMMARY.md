# Summary of changes for run a98eb650-061b-4577-9aa8-a75095c6a91b
Created a self-contained, fully proved Lean 4 file `Catalog/Speculative/CompetitiveExclusion.lean` formalizing a finite, strictly combinatorial "mathematical ecosystem" framework. The file imports only Mathlib and depends on no unformalized helper files; it compiles with zero `sorry`s, and every theorem uses only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

Objects set up (in namespace `CompetitiveExclusion`):
- `T` a type of theories (with `Fintype`/`DecidableEq` instances assumed where needed) and a finite niche type `N`.
- Integer invariants `connections proofDensity axiomCount : T → ℕ`.
- The rational fitness score `fitness t = ((connections t * proofDensity t : ℕ) : ℚ) / (axiomCount t : ℚ)`.
- `AtEquilibrium niche E := Set.InjOn niche (E : Set T)`, i.e. the niche assignment is injective on the ecosystem `E`.

Theorems proved:
1. `card_le_card_niche` (packing): `AtEquilibrium niche E → E.card ≤ Fintype.card N`, via `Finset.card_le_card_of_injOn`.
2. `competitive_exclusion`: `Fintype.card N < E.card → ∃ a ∈ E, ∃ b ∈ E, a ≠ b ∧ niche a = niche b`, a pigeonhole argument via `Finset.exists_ne_map_eq_of_card_lt_of_maps_to`.
3. `argmax_unique`: a reusable, type-generic uniqueness-of-argmax result for any `s : T → α` into a `LinearOrder`, showing any two maximizers of `s` on `E` coincide when `s` is injective on `E`.
4. `fitness_max_unique`: the corollary instantiating `argmax_unique` for the `fitness` score.

Each definition and theorem carries documentation, and there is a module-level docstring explaining the framework. Since the only known matching name (`CompetitiveExclusion`) had no prior implementation in the project, this new file supplies the complete formalization. I verified compilation directly with the Lean compiler and confirmed there are no remaining placeholders.