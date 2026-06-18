# Future Directions — Stratified Self-Reference

## Synthesis

This cycle tested one structural hypothesis behind *self-referential type theory*:
that the paradoxes of self-reference (Russell, Cantor, the Gödel/Liar/Tarski diagonal)
are caused by a **homogeneous, single-level** membership / self-application relation
`mem : U → U → Prop`, in which the two argument slots share a type — and that
**stratifying** that relation into a level-shifting family
`smem : Strat n → Strat (n+1) → Prop` turns an inconsistent comprehension principle
into a consistent, constructively realizable one, the type-theoretic analogue of
`Type_n : Type_{n+1}`.

`Catalog/Logic/StratifiedSelfReference.lean` confirms the dichotomy on both ends, and
`Catalog/Logic/StratifiedGap.lean` extracts its quantitative content. Both build on the
catalog's `Logic/StrangeLoops/Core.lean` (`cantor_from_lawvere`, the `StrangeLoop`
structure).

* **Disease.** `naive_comprehension_inconsistent` derives `False` from any homogeneous
  comprehension via the Russell predicate `λu, ¬ mem u u`, well-typed precisely because
  the two slots share a type. `no_homogeneous_diagonal` isolates the same obstruction at
  the operator level: no `d : (S → Prop) → S` *landing in the same type* `S` can satisfy
  the Gödel/Tarski fixed-point spec `T (d P) ↔ P (d P)`. A surprising corollary,
  `no_strangeLoop`, shows the catalog's `StrangeLoop` structure is literally
  *uninhabited* — its `diag_spec` is exactly a homogeneous diagonal.
* **Cure.** `Strat` (`Strat 0 := PUnit`, `Strat (n+1) := Strat n → Prop`) realizes the
  *full* comprehension schema definitionally (`strat_comprehension`,
  `strat_comprehension_realizable`) over inhabited levels (`strat_nonempty`); `smem x x`
  is a type error, so the diagonal never forms.
* **Mechanism.** `collapse_reintroduces_paradox` reduces hierarchy rigidity to
  `cantor_from_lawvere`: any *surjective* collapse of two adjacent levels restores
  homogeneity and reproduces Cantor's paradox. The theorem that *creates* incompleteness
  in the catalog is exactly the one that *guarantees the levels cannot fuse*.
* **Computation.** `finite_no_surjection` (`Fin m ↛ (Fin m → Bool)`) is the decidable
  shadow of collapse-impossibility; `fmem_comprehension` is a runnable comprehension.
* **Quantification.** The Cantor gap `gap m = 2^m − m` measures the expressivity jump
  between adjacent finite levels. `gap_step` proves the exact increment
  `gap (m+1) = gap m + (2^m − 1)`; `gap_convex` proves the growth is *accelerating*
  (strictly positive second difference at every level); `gap_strictMonoOn_one` proves
  strict growth from level `1`; and `not_strictMono_gap` *refutes* naive global strict
  monotonicity because of the single base collision `gap 0 = gap 1 = 1`
  (`gap_base_collision`).
* **Application.** `self_modifying_spec_fixedpoint` / `self_modifying_spec_least` model
  "proofs that modify their own specification" as least fixed points of a *monotone*
  refinement operator on the spec-lattice `Set A`, via Knaster–Tarski.

## Results Summary

| Theorem | Content | Axioms |
|---|---|---|
| `naive_comprehension_inconsistent` | homogeneous comprehension ⟹ `False` | propext, choice, Quot.sound |
| `no_homogeneous_diagonal` | same-type Gödel/Tarski diagonal ⟹ `False` | propext, choice, Quot.sound |
| `no_strangeLoop` | the `StrangeLoop` structure is uninhabited | propext, choice, Quot.sound |
| `strat_comprehension` | stratified comprehension schema (definitional) | none |
| `strat_nonempty` | every level inhabited | none |
| `strat_comprehension_realizable` | explicit comprehension operator (model) | none |
| `collapse_reintroduces_paradox` | surjective level-collapse ⟹ `False` | propext, choice |
| `finite_no_surjection` | computable finite Cantor `Fin m ↛ (Fin m → Bool)` | propext, choice, Quot.sound |
| `fmem_comprehension` | decidable finite comprehension | none |
| `gap_step` | exact gap increment `gap(m+1)=gap m+(2^m−1)` | propext, Quot.sound |
| `gap_convex` | accelerating growth (positive 2nd difference) | propext, Quot.sound |
| `not_strictMono_gap` | refutes global strict monotonicity of the gap | propext, choice, Quot.sound |
| `gap_strictMonoOn_one` | gap strictly increasing from level 1 | propext, choice, Quot.sound |
| `self_modifying_spec_fixedpoint` | monotone spec-refinement has a fixed point | propext, choice, Quot.sound |
| `self_modifying_spec_least` | canonical least self-consistent spec | propext, choice, Quot.sound |

No `sorry`, no custom axioms (only the standard `propext`, `Classical.choice`,
`Quot.sound`).

## Research Directions

### 1. Cumulative membership and an internal subset relation
The current tower only relates level `n` to level `n+1`. A predicative *cumulative*
tower `Cum (n+1) := Cum n ⊕ (Cum n → Prop)` would let a level-`n` object remain a
citizen of every higher level, enabling an internal `⊆` and an extensionality
principle, while still forbidding `mem x x`. **The key insight is** that cumulativity
adds *upward* mobility without adding the *self*-application that causes paradox, so
extensional set theory should embed into the tower level-by-level. **Why now?** We
already have `strat_comprehension` as a definitional schema and
`collapse_reintroduces_paradox` as the rigidity guarantee; cumulativity is the minimal
enrichment that turns the schema into a usable set theory. *Falsifiable test:* prove
that cumulative comprehension remains consistent, yet that any surjection
`Cum n ↠ Cum (n+1)` still yields `False` — or exhibit a cumulative comprehension whose
extension operator reintroduces a same-level diagonal.

### 2. From the gap increment to a description-complexity hierarchy
`gap_step` and `gap_convex` pin the increment to `2^m − 1` with a strictly positive
second difference. Connect this closed form to the circuit/description complexity of
level-`m` predicates: define `K(m)` as the minimal description length of the hardest
predicate in `Strat m` restricted to `Fin m`, and conjecture `K(m) = Θ(gap m)`. **The
key insight is** that collapse-impossibility is not binary but has a *measurable,
accelerating margin*, and that margin should equal the information needed to name the
diagonal predicate the collapse would have to forget. **Why now?** `gap_convex` already
proves the margin accelerates as pure `2^m`-arithmetic, so the only open step is the
encoding/decoding bridge to a complexity measure. *Falsifiable test:* prove
`gap m ≤ K(m) ≤ gap m + O(log m)` for a fixed Kolmogorov-style measure, or exhibit a
level where the hardest predicate is describable in `o(gap m)` bits.

### 3. Stratified fixed-point logic: refinement operators that respect levels
Index the spec-lattice by level, `R : (n : ℕ) → Set (Strat n) →o Set (Strat n)`, and ask
when a *level-stratified* family of monotone refinements has a *coherent* fixed point
compatible with `smem`. **The key insight is** that "self-improving formal systems" are
safe exactly when their refinement is monotone *and* level-preserving — the lattice
analogue of the type-level stratification proven here. **Why now?** Both ingredients live
in one place (`self_modifying_spec_fixedpoint` plus the `Strat` tower); the open step is
their interaction. *Falsifiable test:* prove that a level-preserving monotone family
admits a fixed point coherent across levels (each `S_n` is the `smem`-preimage of
`S_{n+1}`), or find a monotone family whose per-level least fixed points are mutually
`smem`-incompatible.

### 4. Mechanized non-applicability of Gödel diagonalization to the tower
`no_homogeneous_diagonal` and `no_strangeLoop` already show that no same-type truth
diagonal exists. Lift this to a *parameterized* impossibility: no `StrangeLoop` whose
`Sentence` type is a single `Strat n` with `True_ := smem ·` can exist, because its
`diag : (Sentence → Prop) → Sentence` would be exactly the forbidden homogeneous
operator. **The key insight is** that Gödel's construction needs `diag` landing in the
*same* type, which the tower structurally denies — `strat_comprehension` lands one level
up *on purpose*. **Why now?** The catalog packages diagonalization as `StrangeLoop.diag`,
and `no_homogeneous_diagonal` is the negative core; the remaining work is embedding
bookkeeping. *Falsifiable test:* prove
`¬ ∃ (L : StrangeLoop) (n : ℕ), L.Sentence = Strat n ∧ HEq L.True_ (@smem n)`, or
construct such an `L` (which would refute the whole stratification thesis).

### 5. Univalent / HoTT bridge: stratification as a truncation hierarchy
Connect `Strat n` to the catalog's `Logic/HoTT/` development by asking whether the level
index `n` corresponds to a homotopy truncation level, so that "self-reference at level
`n`" becomes "equivalence data one homotopy level up." **The key insight is** that
homotopy levels already stratify *identity* exactly as `Strat` stratifies *membership*,
so univalence should supply the principled same-level equivalence that stratification
needs in order to avoid diagonalization. **Why now?** Both the `HoTT` foundations and this
membership tower live in the same `Logic` library, making a definitional bridge cheap to
attempt. *Falsifiable test:* construct a level-preserving map `Strat n → (n-truncated
type)` preserving `smem` up to equivalence, or prove no such map exists.
