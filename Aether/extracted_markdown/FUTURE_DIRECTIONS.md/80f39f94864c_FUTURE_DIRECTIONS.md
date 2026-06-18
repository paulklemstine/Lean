# Future Directions — Ultrapowers, Elementary Equivalence, and Keisler–Shelah

Cycle artifact: `Catalog/Bridges/UltrapowerKeislerShelah.lean`
Builds on: `Catalog/Bridges/ModelTheoryBridge.lean`,
`Catalog/Speculative/AutoResearch/AxKochenMorleyBridge.lean`.

## Synthesis

This cycle took **Research Direction 3** of the Ax–Kochen / Morley program
("Keisler–Shelah from the ultraproduct transfer") and turned its one-line easy
half into a complete, sorry-free *biconditional*. The catalog already proves that
componentwise elementary equivalence of a *family* lifts to ultraproducts
(`AxKochenMorleyBridge.ultraproduct_ee_of_forall`). We specialised this to the
**ultrapower** (the constant family `a ↦ M`) and discovered that the constant case
is strictly richer than a specialisation: it is *invertible*. The decisive new
lemma is `ultrapower_elementarilyEquivalent_base` (`M ≅[L] ∏ᵤ M`), proved from the
atomic Łoś fact `ultrapower_realize_sentence_iff` together with
`Filter.eventually_const` (which is exactly where the ultrafilter's `NeBot`
enters). With the base equivalence in hand, the backward arrow of the
biconditional `ultrapower_ee_iff` is a three-step transitivity chain
`M ≅ ∏ᵤM ≅ ∏ᵤN ≅ N`, and the forward arrow is the catalog lemma applied to two
constant families.

The structural insight is a clean **separation of content**: everything provable
about ultrapowers by Łoś alone is *elementary-equivalence* level, and it is
*exact* — ultrapowers lose no first-order information, so `≅[L]` is a perfect
invariant of the ultrapower functor. The genuinely hard part of Keisler–Shelah —
upgrading `≅[L]` to an honest isomorphism `≃[L]` — is therefore quarantined into a
single conjecture, `keislerShelah_isomorphism`, which we deliberately left with
`sorry`; it is the precise point where one must leave Łoś behind and invoke
ℵ₁-saturation / a regular ultrafilter and a back-and-forth. The same atomic lemma
also gives `ultrapower_model_of_model` for free (an ultrapower of a model of `T`
is a model of `T`), the single-structure shadow of the compactness packaging used
on the Ax–Kochen side.

What did *not* work, and why it was instructive: a first attempt proved the
biconditional monolithically by unfolding `sentence_realize` on both sides, which
repeatedly re-derived `eventually_const` and tangled the two directions. Factoring
out the sentence-level lemma and the base equivalence collapsed both arrows to
one-liners. The lesson — recorded in the Lab Notebook — is that for ultraproduct
arguments the *atomic* "single sentence, single structure" lemma is the right unit
of reuse, and the multi-sentence / multi-structure statements should always be
assembled from it via `elementarilyEquivalent_iff`.

## Results Summary

- `ultraproduct_ee_of_forall_ee`: **proved** — componentwise elementary
  equivalence of two families lifts to their ultraproducts (the EE-hypothesis
  foundation reused by everything below; mirrors the catalog's
  `ultraproduct_ee_of_forall`).
- `ultrapower_realize_sentence_iff`: **proved** — a sentence holds in an ultrapower
  iff it holds in the base structure (atomic Łoś for the constant family; the
  diagonal embedding is elementary at the sentence level).
- `ultrapower_elementarilyEquivalent_base`: **proved** — every structure is
  elementarily equivalent to each of its ultrapowers (`M ≅[L] ∏ᵤ M`); the new,
  decisive ingredient that makes the biconditional invertible.
- `keislerShelah_easy`: **proved** — elementarily equivalent structures have
  elementarily equivalent ultrapowers (the easy direction of Keisler–Shelah).
- `ultrapower_ee_iff`: **proved** — `∏ᵤM ≅[L] ∏ᵤN ↔ M ≅[L] N`; the headline
  biconditional, showing EE is an exact invariant of ultrapowers.
- `ultrapower_model_of_model`: **proved** — an ultrapower of a model of `T` is a
  model of `T` (Łoś model-preservation corollary).
- `keislerShelah_isomorphism`: **conjecture** (`sorry`) — for countable structures,
  EE yields *isomorphic* ultrapowers for a suitable ultrafilter; isolates the
  saturation-only content of full Keisler–Shelah.

## Research Directions

### Direction 1: Genuine Keisler–Shelah via a regular ultrafilter on ℕ
**Hypothesis**: For countable elementarily-equivalent `L`-structures `M ≅[L] N`,
there is a (regular, hence ℵ₁-incomplete) ultrafilter `v` on `ℕ` such that
`∏ᵥ M ≃[L] ∏ᵥ N` as `L`-structures, discharging `keislerShelah_isomorphism`.
**Test**: Build the back-and-forth: regular ultrapowers of countable structures
over a countable language are ℵ₁-saturated; two elementarily equivalent
ℵ₁-saturated structures of the same cardinality are isomorphic by a
back-and-forth on finite partial elementary maps. Formalise "ℵ₁-saturated + EE +
equicardinal ⟹ isomorphic" first, then the saturation of regular ultrapowers.
**Why now**: `ultrapower_ee_iff` already delivers the EE hypothesis of the
back-and-forth for free, so the only missing inputs are saturation and the
equicardinality bookkeeping — no Łoś re-derivation needed.
**If true**: A machine-checked Keisler–Shelah theorem, the canonical
characterisation of elementary equivalence by ultrapower isomorphism.
**If false (in this form)**: The failure would pinpoint exactly which saturation
strength the back-and-forth requires, refining the conjecture's cardinal
hypotheses.

### Direction 2: Ultraproducts of models of `T` are models of `T` (full family version)
**Hypothesis**: For a family `M : α → Type*` with `∀ a, M a ⊨ T` and any
ultrafilter `u`, the ultraproduct `∏ᵤ M ⊨ T`.
**Test**: Generalise `ultrapower_model_of_model` from the constant family to an
arbitrary family: replace `ultrapower_realize_sentence_iff` by
`Language.Ultraproduct.sentence_realize` and `eventually_const` by
`Filter.Eventually.of_forall`. This is a short, finitely-checkable edit.
**Why now**: The constant-family proof already lays out the exact skeleton
(`Theory.model_iff` → per-sentence transfer); only the "eventually" step changes.
**If true**: Gives the Łoś compactness packaging directly, the missing lemma for a
self-contained ultraproduct proof of the compactness theorem inside the catalog.
**If false**: Would expose a missing `Nonempty`/measurability side condition in the
Mathlib ultraproduct API, valuable as an API bug report.

### Direction 3: A Łoś–Vaught completeness test phrased through ultrapowers
**Hypothesis**: If a satisfiable theory `T` has the property that all of its models
become pairwise elementarily equivalent after passing to some common ultrapower,
then `T` is complete — and conversely.
**Test**: Combine `ultrapower_ee_iff` (to strip the ultrapower) with the catalog's
`ModelTheoryBridge.isComplete_of_allModels_ee`. The forward direction is immediate
from `ultrapower_ee_iff`; the converse uses `complete_theory_models_elementarilyEquivalent`.
**Why now**: `ultrapower_ee_iff` makes "EE after ultrapower" and "EE" interchangeable,
so this is a definitional repackaging of an already-proved catalog theorem.
**If true**: A new, ultrapower-native completeness criterion that dovetails with
`AxKochenMorleyBridge.losVaught_isComplete`.
**If false**: Indicates the ultrapower-invariance of EE is *not* preserved under the
quantifier over all models, flagging a quantifier-order subtlety.

### Direction 4: The biconditional fails for non-constant families (a sharp counterexample)
**Hypothesis**: There exist families `M, N : ℕ → Type*` and an ultrafilter `u`
with `∏ᵤ M ≅[L] ∏ᵤ N` but `¬ ∀ a, M a ≅[L] N a` — i.e. the backward arrow of
`ultrapower_ee_iff` genuinely needs the constant-family hypothesis.
**Test**: Take `L` empty, `M a` finite sets of sizes `2,2,2,…` and `N a` of sizes
`1,2,3,…`; both ultraproducts are infinite (along a non-principal `u`) hence EE in
the pure-equality language, yet `M 0 ≇ N 0`. Formalise the cardinality computation
of ultraproducts of finite sets.
**Why now**: This is the Critic's boundary case for the new theorem; it certifies
that constancy is not a removable convenience but the load-bearing hypothesis.
**If true**: A clean, reusable counterexample delimiting exactly when EE is an
ultraproduct invariant.
**If false**: Would mean the invariance extends to arbitrary families — a much
stronger and surprising transfer principle worth chasing.

### Direction 5: Ax–Kochen exceptional set as a cofinite-ultrafilter instance
**Hypothesis**: Phrasing the Ax–Kochen "all but finitely many `p`" quantifier as the
hyperfilter (cofinite ultrafilter on primes) and feeding `ℚ_p` vs `𝔽_p((t))` into
`axKochen_almost_all_transfer` (catalog) plus `ultrapower_model_of_model` yields a
formal "for all but finitely many `p`, every degree-`d` form in `d²+1` variables
over `ℚ_p` has a nontrivial zero".
**Test**: Formalise the function-field truth via Chevalley–Warning (already within
Mathlib's reach) and transfer along the cofinite ultrafilter using the existing
transfer lemma; no new model theory required.
**Why now**: The transfer engine is proved and `ultrapower_model_of_model` shows
the model-preservation half; the remaining content is an elementary point count.
**If true**: A machine-checked instance of the Artin-conjecture consequence of
Ax–Kochen, a genuinely number-theoretic payoff of the bridge.
**If false**: The exceptional-set bookkeeping would reveal whether the cofinite
ultrafilter is too coarse, suggesting a sharper filter on primes.
