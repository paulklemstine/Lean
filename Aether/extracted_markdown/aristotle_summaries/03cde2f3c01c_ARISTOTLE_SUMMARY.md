# Summary of changes for run f6bc9d2d-8124-45dc-aabe-68745071618e
Formalized the complete Korselt's Criterion bridge in `Shared/KorseltCriterion.lean` (located at `Catalog/Shared/KorseltCriterion.lean`, which builds as module `Shared.KorseltCriterion`).

All four required theorems are stated and fully proved (no `sorry`, only the standard axioms `propext`, `Classical.choice`, `Quot.sound`):

1. `forall_orderOf_dvd_of_forall_pow_eq_one` — from the universal Fermat condition on units, the order of each unit divides `n - 1` (via `orderOf_dvd_of_pow_eq_one`).
2. `orderOf_map_dvd_of_surjective` — the order-transfer lemma: `orderOf (f g) ∣ orderOf g` for a monoid hom `f` (via `pow_orderOf_eq_one`, `map_pow`, `map_one`).
3. `prime_sub_one_dvd_of_forall_pow_eq_one` — for a prime `p ∣ n`, `(p-1) ∣ (n-1)`, obtained by taking a generator of the cyclic group `(ZMod p)ˣ` (order `p-1`), lifting it through the surjection `ZMod.unitsMap`, and chaining the two order-divisibility facts.
4. `korselt_criterion` — the main equivalence `IsCarmichael n ↔ Squarefree n ∧ ∀ p prime, p ∣ n → (p-1) ∣ (n-1)`.

To support the main theorem I defined `IsCarmichael n := ∀ a : ℤ, (n:ℤ) ∣ a^n - a` (the Korselt/Fermat condition; it is not in Mathlib) and proved supporting lemmas: `pow_eq_self_of_isCarmichael`, `forall_pow_eq_one_of_isCarmichael` (extracting the unit condition), `squarefree_of_isCarmichael` (squarefreeness via the `a = p` argument), `int_dvd_of_squarefree` (a squarefree `n` divides `x` once every prime factor does, via `Finset.prod_dvd_of_coprime`), and `isCarmichael_of_squarefree_of_dvd` (the backward direction using Fermat's little theorem prime-by-prime).

I also fixed a pre-existing build-blocking issue: `lakefile.toml` was missing `srcDir = "Catalog"`, so the whole project failed to build (lake looked for sources in the project root instead of under `Catalog/`). Adding this line lets the libraries resolve to the actual source layout. The target file builds successfully and reports no remaining warnings beyond two unused-hypothesis notes on `hn`/`hf`, which are kept because they are part of the explicitly required lemma signatures (noted in the docstrings).