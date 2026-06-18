# Future Directions — Stratified Self-Reference

## Synthesis

The cycle set out to test a single structural hypothesis behind *Self-Referential
Type Theory*: that the paradoxes of self-reference (Russell, Cantor, the
Gödel/Liar diagonal) are caused by a **homogeneous, single-level** membership /
self-application relation `mem : U → U → Prop`, and that **stratifying** that
relation into a level-shifting `mem : Strat n → Strat (n+1) → Prop` converts an
inconsistent comprehension principle into a consistent, constructively realizable
one — the type-theoretic analogue of `Type_n : Type_{n+1}`.

The Lean file `Catalog/Logic/StratifiedSelfReference.lean` confirms this on both
ends of the dichotomy:

* **Disease.** `naive_comprehension_inconsistent` shows any homogeneous
  comprehension is `False` — the Russell predicate `λu, ¬ mem u u` is well-typed
  precisely because the two argument slots share a type.
* **Cure.** `Strat n` (with `Strat 0 := PUnit`, `Strat (n+1) := Strat n → Prop`)
  realizes the *full* comprehension schema definitionally (`strat_comprehension`,
  `strat_comprehension_realizable`) over inhabited levels (`strat_nonempty`).
  Here `smem x x` is a *type error*, so the diagonal never forms.
* **Mechanism.** `collapse_reintroduces_paradox` reduces the consistency of the
  hierarchy to the catalog's own `cantor_from_lawvere`: any *surjective* collapse
  of two adjacent levels would restore homogeneity and reproduce Cantor's
  paradox. The theorem that *creates* incompleteness in
  `Logic/StrangeLoops/Core.lean` is exactly the theorem that *guarantees* the
  levels cannot fuse — two faces of one structural fact.
* **Computation.** `finite_no_surjection` (with `#eval` of the `m < 2^m` gap) is
  the decidable shadow of collapse-impossibility, and `fmem_comprehension` gives
  a runnable, decidable comprehension at a finite level.
* **Application.** `self_modifying_spec_fixedpoint` models "proofs that modify
  their own specification" as fixed points of a *monotone* refinement operator on
  the spec-lattice `Set A`, always existing by Knaster–Tarski, with a canonical
  least solution (`self_modifying_spec_least`).

## Results Summary

| Theorem | Content | Axioms |
|---|---|---|
| `naive_comprehension_inconsistent` | homogeneous comprehension ⟹ `False` | propext, choice, Quot.sound |
| `strat_comprehension` | stratified comprehension schema (definitional) | none |
| `strat_nonempty` | every level inhabited | none |
| `strat_comprehension_realizable` | explicit comprehension operator (model) | none |
| `collapse_reintroduces_paradox` | surjective level-collapse ⟹ `False` | propext, choice |
| `finite_no_surjection` | computable finite Cantor `Fin m ↛ (Fin m → Bool)` | propext, choice, Quot.sound |
| `fmem_comprehension` | decidable finite comprehension | propext |
| `self_modifying_spec_fixedpoint` | monotone spec-refinement has a fixed point | propext, choice, Quot.sound |

No `sorry`, no custom axioms.

## Research Directions

### 1. Cross-level (cumulative) membership and an internal subset relation
The current model only relates level `n` to level `n+1`. A predicative *cumulative*
tower `Cum (n+1) := Cum n ⊕ (Cum n → Prop)` would let a level-`n` object remain a
citizen of every higher level, enabling an internal `⊆` and an extensionality
principle, while still forbidding `mem x x`.
**The key insight is** that cumulativity adds *upward* mobility without adding the
*self*-application that causes paradox, so extensional set theory should embed into
the tower level-by-level. **Why now?** We already have `strat_comprehension` as a
definitional schema and `collapse_reintroduces_paradox` as the rigidity guarantee;
cumulativity is the minimal enrichment that turns the schema into a usable
set theory. *Falsifiable test:* prove (or refute) that cumulative comprehension
remains consistent yet that any map identifying `Cum n` with `Cum (n+1)`
surjectively still yields `False`.

### 2. A definable diagonal gap function quantifying "how far from paradox"
Define `gap : ℕ → ℕ` measuring the expressivity jump between adjacent finite
levels (`gap m = 2^m - m`), and conjecture it is *strictly increasing and convex*,
certifying that each added self-reference level is strictly more expressive.
**The key insight is** that the impossibility of finite collapse is not binary but
*quantitative* — the Cantor gap is the exponent of the self-reference level, so
incompleteness has a measurable "margin." **Why now?** `finite_no_surjection`
already isolates `m < 2^m` as the operative inequality; promoting it to a proved
monotone/convex `gap` turns a qualitative no-collapse theorem into a complexity
hierarchy. *Falsifiable test:* prove `StrictMono gap` and `ConvexOn ℕ gap`, or
exhibit `m` where convexity fails.

### 3. Stratified fixed-point logic: refinement operators that respect levels
Combine Parts 2–5: index the spec-lattice by level, `R : (n:ℕ) → Set (Strat n) →
Set (Strat n)`, and ask when a *level-stratified* family of monotone refinements
has a *coherent* fixed point compatible with `smem`.
**The key insight is** that "self-improving formal systems" are safe exactly when
their refinement is monotone *and* level-preserving — the lattice analogue of the
type-level stratification proven here. **Why now?** We have both ingredients in
one file (`self_modifying_spec_fixedpoint` and the `Strat` tower); the open step is
their interaction. *Falsifiable test:* prove that a level-preserving monotone
family admits a fixed point coherent across levels, or find a monotone family whose
per-level fixed points are mutually incompatible.

### 4. Mechanized non-applicability of Gödel diagonalization
State the diagonal lemma abstractly (as `StrangeLoop.diag` in the catalog) and
prove that **no** `StrangeLoop` structure can be built whose `Sentence` type is a
single `Strat n` with `True_ := smem · ·` — i.e. the diagonal operator `diag`
cannot exist in the stratified model because it would require a homogeneous
self-membership.
**The key insight is** that Gödel's construction needs a `diag : (S → Prop) → S`
landing in the *same* type `S`, which the stratified tower structurally denies.
**Why now?** The catalog already packages diagonalization as `StrangeLoop.diag`;
we can now prove a *negative* embedding theorem against it. *Falsifiable test:*
prove `¬ ∃ (L : StrangeLoop) (n : ℕ), L.Sentence = Strat n ∧ L.diag = ...`, or
construct such an `L` (which would refute the whole stratification thesis).

### 5. Univalent / HoTT bridge: stratification as a truncation hierarchy
Connect `Strat n` to the catalog's `Logic/HoTT/` development by asking whether the
level index `n` corresponds to an `n`-truncation level, so that "self-reference at
level `n`" becomes "equivalence data one homotopy level up."
**The key insight is** that homotopy levels already stratify *identity*, exactly as
`Strat` stratifies *membership*, so univalence should provide the principled
equivalence between same-level types that stratification needs to avoid
diagonalization. **Why now?** Both the `HoTT` foundations and this membership tower
live in the same `Logic` library, making a definitional bridge cheap to attempt.
*Falsifiable test:* construct a map `Strat n → (n-truncated type)` preserving
`smem` up to equivalence, or prove no such level-preserving map exists.
