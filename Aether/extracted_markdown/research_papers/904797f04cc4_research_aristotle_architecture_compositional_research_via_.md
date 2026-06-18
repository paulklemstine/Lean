# A Formal Category of Research Theories with Certified Theorem Transfer

## Abstract

We introduce a formally verified framework in which mathematical theories are treated as first-class objects of a category, and structure-preserving translations between theories become certified arrows. Each theory is equipped with a natural-number-valued invariant measuring "depth" or "complexity," and each morphism is required to be monotone with respect to this invariant. We prove that this category satisfies the standard identity and composition laws, that composed morphisms preserve and accumulate depth, and that existential lower-bound witnesses transfer automatically across morphisms. We further develop products, coproducts, isomorphisms, chain composition for arbitrary-length pipelines, a "gap theorem" proving the non-existence of certain morphisms, and a validated-theory enrichment carrying conditional transfer. The framework is instantiated with concrete bridges between arithmetic height theory, geometric cell decomposition, dynamical stability, and closure-capacity theory, demonstrating genuine cross-domain theorem transfer. All results are machine-checked with no unresolved proof obligations.

## 1. Introduction

### 1.1 Motivation

Mathematical research produces deep results in specialized domains — number theory, dynamical systems, information theory, algebraic geometry — but the *transfer* of results between domains remains largely informal. When a number theorist proves that the height of an algebraic point controls the dimension of an associated space, and a dynamicist proves that contraction rates control stability margins, the structural similarity is evident but not formally exploitable.

We propose a lightweight categorical framework that makes such transfers explicit, composable, and machine-checkable. The core innovation is to model a "theory" as a type equipped with a ℕ-valued invariant, and a "morphism" as a function that is monotone with respect to this invariant. This minimal structure suffices to:
1. Form a well-behaved category with identity and composition laws.
2. Enable automatic transfer of existential depth certificates.
3. Support products, coproducts, chains, and amplification.
4. Prove gap theorems showing when transfer is impossible.

### 1.2 Related Work

**Category theory in proof assistants.** Mathlib provides a comprehensive library of category theory, but it focuses on standard mathematical categories (groups, rings, topological spaces) rather than meta-mathematical categories of theories. Our framework is deliberately lightweight and does not require the full Mathlib category hierarchy.

**Institutions and theory morphisms.** Goguen and Burstall's theory of institutions (1992) formalizes the notion of logical system with a satisfaction condition. Our work is more focused: we do not formalize syntax, deduction, or satisfaction, but instead capture the *quantitative invariant transfer* aspect that is most relevant for compositional research.

**Proof transport and transfer.** The concept of transporting proofs across isomorphisms has been studied extensively (Barthe et al., Cohen et al., Zimmermann & Herbelin). Our contribution is orthogonal: we transport *existential witnesses* across *non-invertible* morphisms, which is stronger than proof transport in the isomorphic case.

### 1.3 Contributions

1. **Definitions**: `ResearchTheory`, `TheoryHom`, `ValidatedTheory`, `ValidatedHom`, `TheoryIso`, `TheoryChain` (§2-3).
2. **Category laws**: identity, composition, associativity, unit laws for both `TheoryHom` and `ValidatedHom` (§3).
3. **Depth theorems**: composed depth monotonicity, componentwise lower bounds, strict amplification (§4).
4. **Transfer principle**: lower bounds transfer across morphisms; iterated transfer for chains (§5).
5. **Structural results**: products with universal property, coproducts, gap theorem, isomorphism invariant preservation (§6).
6. **Amplification**: monotone invariant amplification and domination ordering (§7).
7. **Instantiation**: concrete bridges between height, cell, stability, and capacity theories (§8).
8. **Algorithms**: morphism discovery, optimal path finding, gap detection (§9).

## 2. Core Definitions

### 2.1 Research Theory

```
structure ResearchTheory where
  Carrier : Type
  Inv : Carrier → ℕ
```

A **research theory** is a type `Carrier` equipped with an invariant function `Inv : Carrier → ℕ`. The invariant measures the "depth," "complexity," or "dimension" of each element. We use ℕ rather than ℝ or a general ordered set for simplicity and computability; see §10 for generalizations.

### 2.2 Theory Morphism

```
structure TheoryHom (T U : ResearchTheory) where
  toFun : T.Carrier → U.Carrier
  monotone_inv : ∀ x : T.Carrier, T.Inv x ≤ U.Inv (toFun x)
```

A **theory morphism** from T to U is a function between carriers that is *monotone* with respect to the invariants: translating an object can only increase (or preserve) its certified depth. The monotonicity witness is a proof obligation, checked by the type system.

### 2.3 Validated Theory (Enriched Version)

```
structure ValidatedTheory where
  Carrier : Type
  Complexity : Carrier → ℕ
  Valid : Carrier → Prop

structure ValidatedHom (T U : ValidatedTheory) where
  toFun : T.Carrier → U.Carrier
  map_valid : ∀ {x}, T.Valid x → U.Valid (toFun x)
  monotone_complexity : ∀ {x}, T.Valid x → T.Complexity x ≤ U.Complexity (toFun x)
```

The enriched version adds a validity predicate, enabling transfer of conditional results. Morphisms must preserve validity and be complexity-monotone on valid elements.

## 3. Category Structure

### 3.1 Extensionality

**Theorem (TheoryHom.ext).** Two morphisms f, g : TheoryHom T U are equal if and only if their underlying functions are equal: `f.toFun = g.toFun → f = g`.

*Proof.* By cases on the structure; the monotonicity proof is a proposition and therefore unique by proof irrelevance. □

### 3.2 Identity and Composition

**Definition.** The identity morphism `TheoryHom.id T` uses the identity function with trivial monotonicity.

**Definition.** Given `f : TheoryHom T U` and `g : TheoryHom U V`, their composition `TheoryHom.comp f g : TheoryHom T V` uses `g.toFun ∘ f.toFun` with monotonicity by transitivity:
```
T.Inv x ≤ U.Inv (f.toFun x) ≤ V.Inv (g.toFun (f.toFun x))
```

### 3.3 Laws

**Theorem (comp_assoc).** `comp (comp f g) h = comp f (comp g h)`.

**Theorem (id_comp).** `comp (id T) f = f`.

**Theorem (comp_id).** `comp f (id U) = f`.

All three follow immediately from function extensionality and the definitional equality of composition/identity on functions.

The same laws hold for `ValidatedHom` with identical proofs.

## 4. Depth Monotonicity

### 4.1 Composed Depth Preservation

**Theorem (composed_morphism_preserves_depth).** For `f : TheoryHom T U`, `g : TheoryHom U V`, and `x : T.Carrier`:
```
T.Inv x ≤ V.Inv (g.toFun (f.toFun x))
```

*Proof.* This is exactly the monotonicity witness of `comp f g`. □

### 4.2 Componentwise Bounds

**Theorem (comp_depth_ge_left).** `T.Inv x ≤ V.Inv (g.toFun (f.toFun x))` — the composite preserves source depth.

**Theorem (comp_depth_ge_middle).** `U.Inv (f.toFun x) ≤ V.Inv (g.toFun (f.toFun x))` — the composite preserves intermediate depth.

These follow from transitivity and the individual monotonicity witnesses.

### 4.3 Strict Amplification

**Theorem (height_to_cell_strict_increase).** For `x ≥ 2`:
```
HeightTheory.Inv x < CellTheory.Inv (heightToCellMorphism.toFun x)
```

*Proof.* Since `HeightTheory.Inv x = x` and `CellTheory.Inv x = x(x+1)`, we need `x < x(x+1)`, which holds when `x ≥ 2` since `x+1 ≥ 3 > 1`. □

This demonstrates that morphisms can *strictly* increase depth, not merely preserve it.

## 5. The Transfer Principle

### 5.1 Lower Bound Transfer

**Definition.** `SatisfiesLowerBound T n := ∃ x : T.Carrier, n ≤ T.Inv x`.

**Theorem (transfer_lower_bound).** For `f : TheoryHom T U`:
```
SatisfiesLowerBound T n → SatisfiesLowerBound U n
```

*Proof.* Given witness `x` with `n ≤ T.Inv x`, take `f.toFun x` with `n ≤ T.Inv x ≤ U.Inv (f.toFun x)`. □

### 5.2 Iterated Transfer

**Theorem (transfer_lower_bound_comp).** Lower bounds survive composition:
```
SatisfiesLowerBound T n → SatisfiesLowerBound V n
```
via `comp f g`.

### 5.3 Chain Transfer

**Theorem (chain_transfer).** For a `TheoryChain n` (a sequence of n+1 theories with n morphisms):
```
SatisfiesLowerBound (theory 0) k → SatisfiesLowerBound (theory (last n)) k
```

*Proof.* By induction on n, composing the chain into a single morphism and applying `transfer_lower_bound`. □

### 5.4 Validated Transfer

**Theorem (validated_transfer_lower_bound).** The transfer principle extends to validated theories:
```
ValidatedSatisfiesLowerBound T n → ValidatedSatisfiesLowerBound U n
```
where the witness in U is guaranteed to be valid.

## 6. Structural Results

### 6.1 Product Theory

The product `T.prod U` has carrier `T.Carrier × U.Carrier` and invariant `min(T.Inv x, U.Inv y)`.

**Theorem (prod_lift_fst, prod_lift_snd).** The product satisfies the universal property: for any `f : W → T` and `g : W → U`, there exists a unique `(f, g) : W → T × U` such that `fst ∘ (f,g) = f` and `snd ∘ (f,g) = g`.

### 6.2 Coproduct Theory

The coproduct `T.coprod U` has carrier `T.Carrier ⊕ U.Carrier` with injections preserving the invariant exactly.

### 6.3 Theory Isomorphisms

**Theorem (TheoryIso.inv_eq).** If `iso : TheoryIso T U`, then `T.Inv x = U.Inv (iso.toHom.toFun x)` for all x — isomorphisms preserve invariants *exactly*.

**Theorem (TheoryIso.satisfies_iff).** Isomorphic theories satisfy exactly the same lower bounds.

### 6.4 Gap Theorem

**Theorem (no_morphism_from_gap).** If `SatisfiesLowerBound T (n+1)` and `HasBoundedDepth U n`, then `IsEmpty (TheoryHom T U)` — no morphism from T to U exists.

*Proof.* If `f : TheoryHom T U` existed, the witness `x` with `n+1 ≤ T.Inv x` would give `n+1 ≤ T.Inv x ≤ U.Inv (f.toFun x) ≤ n`, a contradiction. □

### 6.5 Preorder Structure

The relation `TheoryDominates T U := Nonempty (TheoryHom T U)` is reflexive and transitive, defining a preorder on theories.

## 7. Invariant Amplification

**Definition.** Given a theory T and a monotone, inflationary function `amp : ℕ → ℕ`, the amplified theory `T.amplify amp` has the same carrier with invariant `amp ∘ T.Inv`.

**Theorem (amplify_dominates).** `TheoryDominates T (T.amplify amp)` for any inflationary amplifier.

**Theorem (amplified_transfer).** Lower bounds transfer through amplified theories and may become stronger.

## 8. Catalog Bridge Instances

### 8.1 Theory Definitions

| Theory | Carrier | Invariant | Catalog Source |
|--------|---------|-----------|----------------|
| HeightTheory | ℕ | id | `key_dimension_lower_bound_from_height` |
| CellTheory | ℕ | n(n+1) | `cell_split_bound_from_height` |
| DimensionTheory | ℕ | n+1 | arithmetic dimension |
| StabilityTheory | ℕ | id | `diagonal_stability_from_contraction` |
| CapacityTheory | ℕ | id | `cap_depends_on_closure_class` |

### 8.2 Morphisms

- `heightToCellMorphism : Height → Cell` (identity on carriers, quadratic invariant gain)
- `heightToDimension : Height → Dimension` (identity, +1 gain)
- `dimensionToStability : Dimension → Stability` (n ↦ n+1)
- `stabilityToCapacity : Stability → Capacity` (identity)
- `heightToCapacityDirect : Height → Capacity` (n ↦ n(n+1), quadratic amplification)

### 8.3 Transfer Theorems

**Theorem (transferred_height_bound).** `SatisfiesLowerBound HeightTheory n → SatisfiesLowerBound CellTheory n`.

**Theorem (cross_domain_transfer).** `SatisfiesLowerBound HeightTheory n → SatisfiesLowerBound CapacityTheory n`.

**Theorem (strict_depth_amplification).** For `x ≥ 2`: `HeightTheory.Inv x < CapacityTheory.Inv (heightToCapacityDirect.toFun x)`.

## 9. Algorithms

### 9.1 Chain Composition

**Algorithm.** Given morphisms `[f₁, ..., fₙ]`, compose iteratively.
- **Time:** O(n) for construction, O(n · |carrier|) for verification.
- **Space:** O(n) for nested closures.

### 9.2 Morphism Discovery

**Algorithm.** Given source and target theories with finite carriers, enumerate candidate maps and filter by monotonicity.
- **Time:** O(|candidates| × |source.carrier|).
- **Space:** O(|valid_morphisms|).

### 9.3 Optimal Transfer Path

**Algorithm.** Build a directed graph of theories (nodes) and morphisms (edges). Use BFS for shortest path or modified Dijkstra for maximum depth amplification.
- **Time:** O((V + E) log V) for optimal depth.
- **Space:** O(V).

### 9.4 Gap Detection

**Algorithm.** Compare max depth of source with bounded depth of target.
- **Time:** O(|source| + |target|).
- **Space:** O(1).

## 10. Discussion

### 10.1 Design Choices

**ℕ-valued invariants.** The choice of ℕ as the invariant codomain is a pragmatic simplification. It enables direct comparison (total order), avoids universe issues, and suffices for all current catalog bridges. Extensions to ℤ, ℚ, ℝ, or general lattices are straightforward but require more infrastructure.

**No syntax/semantics split.** Unlike institutions, we do not formalize logical syntax. This is deliberate: the invariant-transfer content is orthogonal to syntactic concerns, and avoiding syntax eliminates the bureaucratic overhead of signature morphisms, satisfaction conditions, and amalgamation.

**Type-level carriers.** Using `Type` rather than `Set α` or `Fintype` maximizes flexibility and avoids universe constraints in composition.

### 10.2 Limitations

1. The current framework handles only existential transfer (∃ x, P x) and not universal transfer (∀ x, P x). Extending to universal transfer would require morphisms to be surjective or to carry additional structure.
2. The ℕ-valued invariant collapses multi-dimensional complexity into a single number. A lattice-valued generalization would enable finer transfer.
3. The catalog instances use simple arithmetic invariants. Connecting to deep Mathlib results (e.g., Krull dimension, VC dimension) would require additional formalization effort.

### 10.3 Soundness

All theorems depend only on the standard axioms: `propext`, `Quot.sound`, and `Classical.choice`. No `sorry` statements remain. The development is fully machine-checked.

## 11. Future Work

See `FUTURE_DIRECTIONS.md` for a detailed roadmap. Key directions include:
1. Lattice-valued invariants for multi-dimensional transfer.
2. Adjunctions between research theories.
3. Automated morphism discovery across the catalog.
4. Predicate transport beyond existential lower bounds.
5. A bicategory of theories, interpretations, and proof transformations.

## References

1. S. Mac Lane, *Categories for the Working Mathematician*, Springer, 1971.
2. J. A. Goguen and R. M. Burstall, "Institutions: Abstract Model Theory for Specification and Programming," *JACM*, 39(1), 1992.
3. The Mathlib Community, *Mathlib: A Unified Library of Mathematics Formalized*, 2020–present.
4. G. Barthe et al., "Transport of Proofs and Programs across Isomorphisms," *TCS*, 2003.
