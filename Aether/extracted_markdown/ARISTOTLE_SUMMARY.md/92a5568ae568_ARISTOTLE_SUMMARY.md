# Summary of changes for run b93a58b6-18f8-420b-84cc-1cbf2b0e7ac8
Created a single self-contained Lean file `Catalog/Speculative/NichewiseSelection.lean` (Lean 4 + Mathlib) formalizing the finite combinatorial optimization theory of nichewise selection, with full proofs and no `sorry`. It compiles cleanly (no errors, no warnings) and all main results depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Contents (with docstrings interpreting `T` as theories, `N` as niches, `niche`/`fitness` the niche map and fitness, equilibrium = competitive exclusion, `selected` = local fitness maximization):

1. Setup: `AtEquilibrium E` defined via `Set.Pairwise` (distinct members occupy distinct niches), over finite `T`, `N`.

2. Structural lemmas:
   - `atEquilibrium_iff_injOn`: equilibrium ⇔ `niche` injective on `E`.
   - `card_le_card_niche_of_atEquilibrium`: `E.card ≤ Fintype.card N`.
   - `not_atEquilibrium_of_card_lt`: any set larger than the number of niches is not at equilibrium.

3. Constructive nichewise maximizers:
   - `nicheSet n` = theories in niche `n`; `exists_maximizer` via finite argmax (`Finset.exists_max_image`).
   - `selRep t` = chosen fitness-maximal representative of `t`'s niche (every theory lies in its own niche, so the niche is nonempty); `selRep_spec`, `niche_selRep`, `fitness_le_selRep`, and `selRep_congr` (the representative depends only on the niche).
   - `selected` = image of `selRep`, i.e. exactly one maximal representative per nonempty niche; `mem_selected`, `selected_maximal` (each selected theory is fitness-maximal in its niche).

4. Main optimization theorems:
   - `atEquilibrium_selected` and `card_selected_le`.
   - `sum_le_sum_selected`: for any equilibrium `E`, `∑_{t∈E} fitness t ≤ ∑_{t∈selected} fitness t`, via nichewise comparison (each `t∈E` dominated by its niche representative, `selRep` injective on `E`, image inside `selected`).

5. Uniqueness:
   - `UniqueMaximizers` hypothesis (unique fitness maximizer per niche).
   - `eq_selected_of_atEquilibrium_of_sum_eq`: any equilibrium with total fitness equal to that of `selected` must equal `selected`.

Faithfulness note on hypotheses: the global optimality theorem requires nonnegative fitness (`0 ≤ fitness`), and uniqueness requires strict positivity (`0 < fitness`). These are genuinely necessary — without them `selected` (which keeps every nonempty niche) is beaten or tied by smaller equilibria that drop niches of low/zero fitness (e.g. one niche of fitness 5 and one of fitness -10: the singleton {5} is an equilibrium with larger total than `selected`). The hypotheses are stated explicitly on the relevant theorems and documented.

The development is fully finite and combinatorial (no entropy/limits/measure theory) and is organized as reusable lemmas rather than a monolith.