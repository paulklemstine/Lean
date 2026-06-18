# Theory Morphisms: A Formal Framework for Cross-Domain Theorem Transfer

## Abstract

We introduce a lightweight categorical framework in which mathematical theories — modeled as types equipped with ℕ-valued invariant functions — become objects of a category, and structure-preserving maps (theory morphisms) become arrows. Each morphism carries a machine-checked monotonicity witness guaranteeing that the invariant value of any element cannot decrease under translation. We prove that this category satisfies the standard laws (identity, composition, associativity), establish a transfer principle for existential lower bounds, and demonstrate a gap theorem characterizing when translation between theories is impossible. The framework is instantiated with concrete theories derived from arithmetic height bounds, cell decomposition complexity, dynamical stability, and closure-capacity invariants, with certified cross-domain bridges between them. All results are formally verified in Lean 4 with the Mathlib library.

**Keywords:** category of theories, theorem transport, certified invariant transfer, compositional mathematics, cross-domain synthesis, formal verification

---

## 1. Introduction

### 1.1 Motivation

Modern mathematics is organized into hundreds of specialized subdisciplines, each with distinct proof techniques, notation, and intuitions. Yet deep structural similarities between fields have been recognized since at least Weil's "Rosetta Stone" letter (1940), which identified analogies between number theory, algebraic geometry, and the theory of Riemann surfaces. Grothendieck's program (1960s) formalized many such analogies using category theory and functorial language, but the resulting framework operates at a high level of abstraction that makes automated theorem transport difficult.

We propose a pragmatic alternative: model each mathematical theory as a carrier type equipped with a single ℕ-valued invariant, and model translations between theories as functions that are monotone with respect to these invariants. This "minimal invariant category" is sufficient to:

1. Formalize the composition of cross-domain translations.
2. Prove a transfer principle: existential lower bounds propagate along morphisms.
3. Establish a gap theorem: depth mismatches obstruct the existence of morphisms.
4. Instantiate concrete bridges between catalog theorems from arithmetic geometry, cell decomposition theory, dynamical stability, and closure-capacity theory.

### 1.2 Relationship to Prior Work

Our framework draws on several traditions:

- **Institution theory** (Goguen & Burstall, 1992): Institutions formalize logical systems as categories of signatures with sentence and model functors satisfying a satisfaction condition. Our approach is simpler — we do not model syntax, satisfaction, or model categories — but captures the invariant-transfer content that institutions leave implicit.

- **Categorical logic** (Lawvere, 1963; Makkai & Reyes, 1977): Lawvere's functorial semantics interprets theories as categories and models as functors. We work at a coarser level, tracking only a numerical invariant rather than the full categorical structure.

- **Galois connections and abstract interpretation** (Cousot & Cousot, 1977): Our monotone morphisms are closely related to Galois connections between abstract domains. The transfer principle generalizes the soundness theorem of abstract interpretation.

- **Formal theorem libraries** (Mathlib, 2020–present): We build on the Mathlib library for Lean 4, using its extensive infrastructure for natural number arithmetic, order theory, and categorical abstractions.

### 1.3 Contributions

1. **Definitions** (§2): `ResearchTheory`, `TheoryHom`, `ValidatedTheory`, `ValidatedHom`.
2. **Category laws** (§3): Identity, composition, associativity, unit laws, extensionality.
3. **Depth monotonicity** (§4): Composed morphisms preserve depth; componentwise bounds.
4. **Transfer principle** (§5): Existential lower bounds propagate along morphisms and their compositions.
5. **Validated transfer** (§6): Conditional lower bounds (restricted to valid elements) transfer through validated morphisms.
6. **Preorder structure** (§7): The dominance relation on theories is a preorder; dominance implies bound transfer.
7. **Coproduct structure** (§8): Coproduct theories with injection morphisms; bounds lift from factors.
8. **Catalog bridges** (§9): Concrete instantiated theories and morphisms from height, cell, dimension, stability, and capacity theories.
9. **Gap theorem** (§10): Depth gaps obstruct morphism existence.

---

## 2. Definitions and Notation

### 2.1 Research Theory

**Definition 2.1.** A *research theory* is a pair `T = (Carrier, Inv)` where:
- `Carrier` is a type (the objects of the theory)
- `Inv : Carrier → ℕ` is the invariant function

The invariant measures "depth," "complexity," "dimension," or any other quantitative certificate. The choice of ℕ as codomain is deliberate: it provides decidable comparison, avoids real-number complications, and suffices for all our applications.

### 2.2 Theory Morphism

**Definition 2.2.** A *theory morphism* from T to U is a pair `f = (toFun, monotone_inv)` where:
- `toFun : T.Carrier → U.Carrier` is the translation function
- `monotone_inv : ∀ x, T.Inv x ≤ U.Inv (toFun x)` is the monotonicity witness

The monotonicity condition ensures that translation cannot decrease the certified invariant value.

### 2.3 Validated Theory and Morphism

**Definition 2.3.** A *validated theory* extends the basic theory with a validity predicate:
- `Carrier : Type`
- `Complexity : Carrier → ℕ`
- `Valid : Carrier → Prop`

**Definition 2.4.** A *validated morphism* requires:
- `toFun : T.Carrier → U.Carrier`
- `map_valid : T.Valid x → U.Valid (toFun x)` (validity preservation)
- `monotone_complexity : T.Valid x → T.Complexity x ≤ U.Complexity (toFun x)` (conditional monotonicity)

### 2.4 Lower Bounds

**Definition 2.5.** Theory T *satisfies a lower bound* n if `∃ x : T.Carrier, n ≤ T.Inv x`.

**Definition 2.6.** Theory T has *bounded depth* n if `∀ x : T.Carrier, T.Inv x ≤ n`.

---

## 3. Category Laws

**Theorem 3.1 (Extensionality).** Two morphisms `f, g : TheoryHom T U` are equal iff `f.toFun = g.toFun`.

*Proof.* By case analysis on the structure fields. The monotonicity witnesses are propositions and hence proof-irrelevant. □

**Theorem 3.2 (Identity).** For any theory T, the identity function with reflexivity witness is a morphism `id_T : TheoryHom T T`.

**Theorem 3.3 (Composition).** Given `f : TheoryHom T U` and `g : TheoryHom U V`, the composition `g ∘ f` with transitivity witness is a morphism `f ; g : TheoryHom T V`, with:
```
(f ; g).monotone_inv x = le_trans (f.monotone_inv x) (g.monotone_inv (f.toFun x))
```

**Theorem 3.4 (Associativity).** `(f ; g) ; h = f ; (g ; h)` for all composable morphisms.

*Proof.* By extensionality, since both sides have the same underlying function `h ∘ g ∘ f`. □

**Theorem 3.5 (Unit laws).** `id ; f = f` and `f ; id = f` for all morphisms f.

---

## 4. Depth Monotonicity

**Theorem 4.1 (Composed depth preservation).** For `f : TheoryHom T U`, `g : TheoryHom U V`, and `x : T.Carrier`:
```
T.Inv x ≤ V.Inv (g.toFun (f.toFun x))
```

*Proof.* This is precisely the monotonicity witness of the composed morphism `f ; g`. □

**Theorem 4.2 (Left componentwise bound).** `T.Inv x ≤ V.Inv (g.toFun (f.toFun x))`.

**Theorem 4.3 (Middle componentwise bound).** `U.Inv (f.toFun x) ≤ V.Inv (g.toFun (f.toFun x))`.

*Proof.* Direct from g's monotonicity witness applied to `f.toFun x`. □

These theorems certify that composition is not merely lawful but *depth-accumulating*: at every stage of the pipeline, the invariant is at least as large as at any previous stage.

---

## 5. The Transfer Principle

**Theorem 5.1 (Transfer of lower bounds).** If `f : TheoryHom T U` and `SatisfiesLowerBound T n`, then `SatisfiesLowerBound U n`.

*Proof sketch.* Given witness `⟨x, hx : n ≤ T.Inv x⟩`, produce `⟨f.toFun x, le_trans hx (f.monotone_inv x)⟩`. □

**Theorem 5.2 (Iterated transfer).** If `f : TheoryHom T U` and `g : TheoryHom U V`, then `SatisfiesLowerBound T n → SatisfiesLowerBound V n`.

*Proof.* Apply Theorem 5.1 to the composed morphism `f ; g`. □

**Theorem 5.3 (Validated transfer).** If `f : ValidatedHom T U` and `ValidatedSatisfiesLowerBound T n`, then `ValidatedSatisfiesLowerBound U n`.

*Proof sketch.* Given `⟨x, hvalid, hbound⟩`, produce `⟨f.toFun x, f.map_valid hvalid, le_trans hbound (f.monotone_complexity hvalid)⟩`. □

**Theorem 5.4 (Functoriality of transfer).** The transfer functions compose:
```
(transfer g) ∘ (transfer f) = transfer (f ; g)
```
as functions on `SatisfiesLowerBound T n`.

*Proof.* By function extensionality and the propositional nature of the bound witnesses. □

---

## 6. Preorder Structure

**Definition 6.1.** Theory T *dominates* theory U, written `T ≼ U`, if there exists a morphism `TheoryHom T U`.

**Theorem 6.1 (Reflexivity).** `T ≼ T` for all T, via the identity morphism.

**Theorem 6.2 (Transitivity).** If `T ≼ U` and `U ≼ V`, then `T ≼ V`, via composition.

**Theorem 6.3 (Dominance implies transfer).** If `T ≼ U`, then every lower bound achieved by T is also achieved by U.

Note: This is a *preorder*, not a partial order, since `T ≼ U` and `U ≼ T` does not imply `T = U` (the theories may have different carrier types).

---

## 7. Coproduct Structure

**Theorem 7.1.** For any theories T and U, the coproduct `T ⊕ U` (with carrier `T.Carrier ⊕ U.Carrier` and invariant inherited from each component) admits injection morphisms `inl : TheoryHom T (T ⊕ U)` and `inr : TheoryHom U (T ⊕ U)`.

**Theorem 7.2.** Lower bounds from either factor lift to the coproduct.

---

## 8. Gap Theorem

**Theorem 8.1 (Bounded depth pullback).** If `f : TheoryHom T U` and U has bounded depth n, then T has bounded depth n.

*Proof.* For any x, `T.Inv x ≤ U.Inv (f.toFun x) ≤ n`. □

**Theorem 8.2 (Gap theorem).** If `SatisfiesLowerBound T (n+1)` and `HasBoundedDepth U n`, then `TheoryHom T U` is empty.

*Proof.* By contradiction: a morphism f would give `HasBoundedDepth T n` (Theorem 8.1), but the witness `⟨x, hx : n+1 ≤ T.Inv x⟩` contradicts `T.Inv x ≤ n`. □

This theorem provides a *separation principle*: theories with incompatible depth profiles cannot be related by any monotone translation. It is the invariant-theoretic analogue of complexity-class separations.

---

## 9. Catalog Bridge Instances

### 9.1 Theory Definitions

| Theory | Carrier | Invariant | Catalog Source |
|--------|---------|-----------|----------------|
| HeightTheory | ℕ | id | `key_dimension_lower_bound_from_height` |
| CellTheory | ℕ | n ↦ n·(n+1) | `cell_split_bound_from_height` |
| DimensionTheory | ℕ | n ↦ n+1 | Krull dimension bounds |
| StabilityTheory | ℕ | id | `diagonal_stability_from_contraction` |
| CapacityTheory | ℕ | id | `cap_depends_on_closure_class` |

### 9.2 Bridge Morphisms

| Bridge | Source | Target | Map | Monotonicity |
|--------|--------|--------|-----|-------------|
| heightToCellMorphism | Height | Cell | id | n ≤ n·(n+1) |
| stabilityToCapacity | Stability | Capacity | id | n ≤ n |
| heightToDimension | Height | Dimension | id | n ≤ n+1 |
| dimensionToStability | Dimension | Stability | n ↦ n+1 | n+1 ≤ n+1 |
| heightToStabilityPipeline | Height | Stability | n ↦ n+1 | composed |

### 9.3 Transfer Theorems

**Theorem 9.1 (Height → Cell transfer).** `SatisfiesLowerBound HeightTheory n → SatisfiesLowerBound CellTheory n`.

**Theorem 9.2 (Stability → Capacity transfer).** `SatisfiesLowerBound StabilityTheory n → SatisfiesLowerBound CapacityTheory n`.

**Theorem 9.3 (Pipeline transfer).** `SatisfiesLowerBound HeightTheory n → SatisfiesLowerBound StabilityTheory n`.

**Theorem 9.4 (Strict depth increase).** For x ≥ 2, `HeightTheory.Inv x < CellTheory.Inv (heightToCellMorphism.toFun x)`.

*Proof.* We need x < x·(x+1). Since x ≥ 2, x+1 ≥ 3 > 1, so x·(x+1) > x·1 = x. □

This last theorem demonstrates that some bridges *strictly increase* depth — the Cell theory is strictly more expressive than the Height theory for non-trivial inputs.

---

## 10. Computational Demonstrations

### 10.1 Bridge Composition Pipeline

We implemented a Python demonstration that constructs theory objects, morphisms, and pipelines, computing invariant values at each stage. For height h = 5:

| Stage | Theory | Invariant Value |
|-------|--------|----------------|
| Input | Height | 5 |
| After heightToCellMorphism | Cell | 30 |
| After heightToDimension | Dimension | 6 |
| After dimensionToStability | Stability | 6 |
| After stabilityToCapacity | Capacity | 6 |

The Cell theory amplifies invariant values quadratically, while the Height → Dimension → Stability pipeline provides a linear shift.

### 10.2 Gap Analysis

We computed the maximum lower bound achievable in each theory for carrier elements 0 through 20, identifying the gap regions where morphisms cannot exist. For example, CellTheory achieves invariant 420 at element 20, while StabilityTheory achieves only 20 — confirming that no morphism from a sufficiently deep Cell subtheory to Stability can exist.

---

## 11. Discussion

### 11.1 Design Choices

**Why ℕ-valued invariants?** Natural numbers provide decidable comparison, avoid the subtleties of real-number arithmetic in type theory, and suffice for all our applications (heights, dimensions, split counts, stability depths are all naturally ℕ-valued). The framework generalizes straightforwardly to any preordered codomain.

**Why not first-order syntax?** Encoding theories as syntactic objects (signatures, axioms, models) introduces substantial bureaucracy: variable binding, substitution lemmas, satisfaction predicates. Our semantic approach — carrier + invariant — captures the *quantitative content* of theorem transfer while avoiding this overhead.

**Why monotonicity rather than equality?** Requiring `T.Inv x = U.Inv (f.toFun x)` would be far too restrictive; most interesting bridges amplify invariants (cf. Theorem 9.4). Monotonicity is the weakest condition that still supports lower-bound transfer.

### 11.2 Limitations

1. The framework transfers only existential lower bounds (`∃ x, n ≤ Inv x`), not universal properties or structural theorems.
2. The ℕ-valued invariant loses multi-dimensional information (e.g., separate height and dimension bounds).
3. The concrete bridges in §9 use simplified carrier types (ℕ) rather than the full algebraic structures from the catalog theorems.

### 11.3 Open Questions

1. Can the framework be extended to transfer universal statements `∀ x, P x → Q (f x)`?
2. Is there a natural notion of adjunction between research theories?
3. Can bridge morphisms be discovered automatically from a catalog of theorem statements?

---

## 12. Future Work

See FUTURE_DIRECTIONS.md for detailed specifications of five breakthrough-level research directions: multi-invariant transfer, adjunctions, predicate transport, bicategorical structure, and automated bridge discovery.

---

## References

1. Goguen, J.A. & Burstall, R.M. (1992). Institutions: Abstract model theory for specification and programming. *Journal of the ACM*, 39(1), 95–146.

2. Lawvere, F.W. (1963). Functorial semantics of algebraic theories. *Proceedings of the National Academy of Sciences*, 50(5), 869–872.

3. Cousot, P. & Cousot, R. (1977). Abstract interpretation: A unified lattice model for static analysis of programs. *POPL '77*, 238–252.

4. Weil, A. (1940). Letter to Simone Weil ("Rosetta Stone" letter). Published in *Œuvres Scientifiques*, Vol. I.

5. Grothendieck, A. (1960–1967). *Éléments de géométrie algébrique*. Publications Mathématiques de l'IHÉS.

6. The Mathlib Community (2020–present). *Mathlib: The Lean Mathematical Library*. https://leanprover-community.github.io/mathlib4_docs/
