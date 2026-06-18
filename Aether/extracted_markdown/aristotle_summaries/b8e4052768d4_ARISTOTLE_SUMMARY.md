# Summary of changes for run 8b95a729-9c53-4327-950b-bd0ed8abc0c0
## Cycle complete: The Differential Calculus of Combinatorial Species

I extended the existing catalog development on Joyal's combinatorial species and the exponential generating function (EGF) bridge (`Catalog/Applications/CombinatorialSpecies.lean`, which had the additive/multiplicative dictionary) with a new **differential dictionary**, delivered in a new self-contained module:

**New file:** `Catalog/Bridges/SpeciesCalculus.lean` (builds cleanly, 0 sorries, only standard axioms `propext`/`Classical.choice`/`Quot.sound`).

### Theorems proved (all complete, no sorry on any result)
1. `egf_deriv` — the derivative bridge: the EGF of the species derivative `F'[n]=F[n+1]` equals the formal derivative `d/dX` of the EGF.
2. `egf_pointing` — the pointing bridge: the EGF of the pointed sequence `n ↦ n·aₙ` equals the Euler operator `X·d/dX` of the EGF.
3. `Species.EGF_deriv` — the derivative bridge at the functorial level, with a genuine `Sₙ`-action on the derivative species `Species.deriv` (via the hole-fixing embedding `Perm (Fin n) ↪ Perm (Fin (n+1))`).
4. `EGF_setSpecies_deriv_fixed` — the species of sets satisfies `E' = E`, i.e. the formal statement `exp' = exp`.
5. `binConv_leibniz` — the combinatorial Leibniz/Pascal product rule `(a⋆b)ₙ₊₁ = (a∘succ ⋆ b)ₙ + (a ⋆ b∘succ)ₙ`, the shadow of `(F·G)' = F'·G + F·G'`.
6. `egf_pointed_setSpecies` — pointing the species of sets gives EGF `X·exp`.

The file restates (with explicit citation) the minimal prerequisite definitions/lemmas from the catalog so it stands alone as a single buildable module. Each main theorem carries a `-- !-- Lab Notebook -- !--` block (Hypothesis / Result / Insight / Failure analysis) and a docstring proof sketch.

### Notes deliverable
`FUTURE_DIRECTIONS.md` contains the required **Synthesis** and **Results Summary** sections plus five falsifiable research directions (composition/analytic-functor bridge, the cycle species and `exp`/`log` duality, species integration and the discrete FTC, uniqueness of the `exp` fixed point, and faithfulness of the derivative functor), each with a "The key insight is..." sentence and a "Why now" justification tied to results proved this cycle.

The catalog lakefile was temporarily modified during exploration and has been restored to its original state.