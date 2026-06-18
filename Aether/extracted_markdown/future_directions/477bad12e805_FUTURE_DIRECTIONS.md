# Future Directions — Stratified Self-Reference

## Synthesis

This cycle tested one structural hypothesis behind *self-referential type theory*:
that the paradoxes of self-reference (Russell, Cantor, the Gödel/Liar diagonal) are
caused by a **homogeneous, single-level** membership / self-application relation
`mem : U → U → Prop`, and that **stratifying** that relation into a level-shifting
`smem : Strat n → Strat (n+1) → Prop` turns an inconsistent comprehension principle
into a consistent, constructively realizable one — the type-theoretic analogue of
`Type_n : Type_{n+1}`.

`Catalog/Logic/StratifiedSelfReference.lean` confirms the dichotomy on both ends, and
`Catalog/Logic/StratifiedGap.lean` extracts its quantitative content:

* **Disease.** `naive_comprehension_inconsistent` shows any homogeneous comprehension
  entails `False` via the Russell predicate `λu, ¬ mem u u`, which is well-typed
  precisely because the two argument slots share a type. `no_homogeneous_diagonal`
  isolates the same obstruction at the level of operators: no `d : (S → Prop) → S`
  landing in the *same* type `S` can satisfy the Gödel/Tarski fixed-point spec.
* **Cure.** `Strat` (with `Strat 0 := PUnit`, `Strat (n+1) := Strat n → Prop`)
  realizes the *full* comprehension schema definitionally (`strat_comprehension`,
  `strat_comprehension_realizable`) over inhabited levels (`strat_nonempty`). Here
  `smem x x` is a *type error*, so the diagonal never forms.
* **Mechanism.** `collapse_reintroduces_paradox` reduces hierarchy consistency to the
  catalog's `cantor_from_lawvere` (`Logic/StrangeLoops/Core.lean`): any *surjective*
  collapse of two adjacent levels would restore homogeneity and reproduce Cantor's
  paradox. The theorem that *creates* incompleteness in the catalog is exactly the
  theorem that *guarantees the levels cannot fuse* — two faces of one structural fact.
* **Computation.** `finite_no_surjection` (`Fin m ↛ (Fin m → Bool)`) is the decidable
  shadow of collapse-impossibility; `fmem_comprehension` gives a runnable decidable
  comprehension at a finite level.
* **Quantification.** The Cantor gap `gap m = 2^m - m` measures the expressivity jump
  between adjacent finite levels. `gap_step` proves the exact per-step increment
  `gap (m+1) = gap m + (2^m − 1)`; `gap_strictMonoOn_one` proves strict growth from
  level `1`; and `not_strictMono_gap` *refutes* the naive global-strict-monotonicity
  conjecture because `gap 0 = gap 1 = 1` (`gap_base_collision`).
* **Application.** `self_modifying_spec_fixedpoint` / `self_modifying_spec_least` model
  "proofs that modify their own specification" as least fixed points of a *monotone*
  refinement operator on the spec-lattice `Set A`, via Knaster–Tarski.

## Results Summary

| Theorem | Content | Axioms |
|---|---|---|
| `naive_comprehension_inconsistent` | homogeneous comprehension ⟹ `False` | propext, choice, Quot.sound |
| `no_homogeneous_diagonal` | same-type Gödel diagonal ⟹ `False` | none |
| `strat_comprehension` | stratified comprehension schema (definitional) | none |
| `strat_nonempty` | every level inhabited | none |
| `strat_comprehension_realizable` | explicit comprehension operator (model) | none |
| `collapse_reintroduces_paradox` | surjective level-collapse ⟹ `False` | propext, choice |
| `finite_no_surjection` | computable finite Cantor `Fin m ↛ (Fin m → Bool)` | none |
| `fmem_comprehension` | decidable finite comprehension | none |
| `gap_step` | exact gap increment `gap(m+1)=gap m+(2^m−1)` | propext, Quot.sound |
| `not_strictMono_gap` | refutes global strict monotonicity of the gap | propext, choice, Quot.sound |
| `gap_strictMonoOn_one` | gap strictly increasing from level 1 | propext, choice, Quot.sound |
| `self_modifying_spec_fixedpoint` | monotone spec-refinement has a fixed point | propext, choice, Quot.sound |
| `self_modifying_spec_least` | canonical least self-consistent spec | propext, choice, Quot.sound |

No `sorry`, no custom axioms (only the standard `propext`, `Classical.choice`,
`Quot.sound`).

## Research Directions

### 1. Cross-level (cumulative) membership and an internal subset relation
The current model only relates level `n` to level `n+1`. A predicative *cumulative*
tower `Cum (n+1) := Cum n ⊕ (Cum n → Prop)` would let a level-`n` object remain a
citizen of every higher level, enabling an internal `⊆` and an extensionality
principle, while still forbidding `mem x x`.
**The key insight is** that cumulativity adds *upward* mobility without adding the
*self*-application that causes paradox, so extensional set theory should embed into the
tower level-by-level. **Why now?** We already have `strat_comprehension` as a
definitional schema and `collapse_reintroduces_paradox` as the rigidity guarantee;
cumulativity is the minimal enrichment that turns the schema into a usable set theory.
*Falsifiable test:* prove (or refute) that cumulative comprehension remains consistent,
yet that any map identifying `Cum n` with `Cum (n+1)` surjectively still yields `False`.

### 2. Convexity and a complexity hierarchy from the gap increment
`gap_step` shows the increment is exactly `2^m − 1`, which is itself strictly
increasing — so on `Set.Ici 1` the gap should be *discretely convex*
(`gap (m+2) − gap (m+1) > gap (m+1) − gap m`). Promote this to a proved second-order
monotonicity and connect the gap to circuit/description complexity of level-`m`
predicates.
**The key insight is** that collapse-impossibility is not binary but has a *measurable,
accelerating margin*: each added self-reference level is not just more expressive but
*increasingly* more expressive. **Why now?** `gap_step` already isolates the increment
in closed form; second differences are then pure `omega`-arithmetic over `2^m`.
*Falsifiable test:* prove `∀ m ≥ 1, gap (m+2) - gap (m+1) > gap (m+1) - gap m`, or
exhibit `m ≥ 1` where the second difference is non-positive.

### 3. Stratified fixed-point logic: refinement operators that respect levels
Index the spec-lattice by level, `R : (n:ℕ) → Set (Strat n) → Set (Strat n)`, and ask
when a *level-stratified* family of monotone refinements has a *coherent* fixed point
compatible with `smem`.
**The key insight is** that "self-improving formal systems" are safe exactly when their
refinement is monotone *and* level-preserving — the lattice analogue of the type-level
stratification proven here. **Why now?** Both ingredients live in one place
(`self_modifying_spec_fixedpoint` plus the `Strat` tower); the open step is their
interaction. *Falsifiable test:* prove that a level-preserving monotone family admits a
fixed point coherent across levels, or find a monotone family whose per-level fixed
points are mutually incompatible.

### 4. Mechanized non-applicability of Gödel diagonalization
`no_homogeneous_diagonal` already proves that no same-type truth-diagonal exists. Lift
this to the catalog's packaged `StrangeLoop` (in `Logic/StrangeLoops/Core.lean`): show
that **no** `StrangeLoop` whose `Sentence` type is a single `Strat n` with
`True_ := smem · ·` can exist, because its `diag : (Sentence → Prop) → Sentence` would
be exactly the forbidden homogeneous operator.
**The key insight is** that Gödel's construction needs `diag` landing in the *same*
type, which the stratified tower structurally denies — `strat_comprehension` lands one
level up on purpose. **Why now?** The catalog packages diagonalization as
`StrangeLoop.diag`, and `no_homogeneous_diagonal` is the negative core; the remaining
work is the embedding bookkeeping. *Falsifiable test:* prove
`¬ ∃ (L : StrangeLoop) (n : ℕ), L.Sentence = Strat n ∧ L.True_ ≍ smem`, or construct
such an `L` (which would refute the whole stratification thesis).

### 5. Univalent / HoTT bridge: stratification as a truncation hierarchy
Connect `Strat n` to the catalog's `Logic/HoTT/` development by asking whether the
level index `n` corresponds to an `n`-truncation level, so that "self-reference at level
`n`" becomes "equivalence data one homotopy level up."
**The key insight is** that homotopy levels already stratify *identity*, exactly as
`Strat` stratifies *membership*, so univalence should supply the principled equivalence
between same-level types that stratification needs to avoid diagonalization. **Why
now?** Both the `HoTT` foundations and this membership tower live in the same `Logic`
library, making a definitional bridge cheap to attempt. *Falsifiable test:* construct a
map `Strat n → (n-truncated type)` preserving `smem` up to equivalence, or prove no such
level-preserving map exists.
