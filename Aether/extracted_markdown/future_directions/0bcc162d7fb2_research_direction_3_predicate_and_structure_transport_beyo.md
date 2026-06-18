# Predicate Transport Along Invariant-Preserving Morphisms: A General Calculus of Certified Property Transfer

## Abstract

We introduce a general framework for transporting certified properties across structure-preserving morphisms between mathematical theories equipped with numerical invariants. The central abstraction is the notion of an *invariant-determined predicate*: a property of theory objects that depends only on their invariant value. We prove that such predicates are precisely those that factor through the invariant function, establish existential (covariant) and universal (contravariant) transport theorems, show that invariant-determined predicates form a Boolean algebra, and prove that predicate transport composes functorially along morphism chains. As a corollary, we recover existing lower-bound transfer theorems as special cases. The framework is fully formalized in Lean 4 with Mathlib, with all theorems verified by the kernel without axioms beyond the standard foundation.

**Keywords:** predicate transport, invariant-determined logic, theory morphisms, certified bounds, categorical semantics, abstract interpretation, compositional verification

## 1. Introduction

### 1.1 Motivation

Across certified machine learning, tropical computation, Byzantine fault tolerance, and information-theoretic security, a common proof pattern recurs: one establishes a quantitative property (a bound, a complexity threshold, a safety certificate) about objects in one mathematical domain, then needs to transfer that property to objects in another domain connected by a structure-preserving map.

Currently, each such transfer is proved ad hoc. The lower-bound transfer theorem for theory morphisms [existing codebase, `TheoryMorphisms.lean`] handles the case `∃x, n ≤ T.Inv(x) → ∃y, n ≤ U.Inv(y)`. The composable transfer framework [`ComposableTransfer.lean`] extends this to chains of morphisms. But neither framework identifies the *class of properties* for which transfer is automatic, nor provides a general transport mechanism.

### 1.2 Contributions

We make the following contributions:

1. **Invariant-determined predicates** (Definition 2.1): We identify the precise class of properties that transfer along theory morphisms — those depending only on the invariant value.

2. **Factorization theorem** (Theorem 3.1): We prove that invariant-determination is equivalent to factorization through the invariant, giving a canonical decomposition of transportable predicates.

3. **Transport theorems** (Theorems 4.1–4.3): We establish existential pushforward, universal pullback, and the stability of invariant-determined predicates under transport.

4. **Functoriality** (Theorems 5.1–5.2): We prove that predicate transport composes along morphism chains and satisfies identity laws, forming a functorial structure.

5. **Boolean closure** (Theorems 6.1–6.5): We show invariant-determined predicates are closed under all Boolean operations.

6. **Subsumption** (Corollaries 7.1–7.3): We recover the existing lower-bound transfer, upper-bound pullback, and bounded-depth theorems as one-line corollaries.

All results are formalized in Lean 4 with Mathlib, compiled against `leanprover/lean4:v4.28.0`, and verified to use only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### 1.3 Related Work

**Abstract interpretation** (Cousot & Cousot, 1977) studies the transfer of program properties through abstraction functions. Our invariant-determined predicates correspond to properties observable in the abstract domain, and our transport theorem is a soundness principle for abstraction-preserving compilation.

**Categorical logic** and **fibered categories** provide the general framework for predicate transport along functors. Our work can be seen as a concrete instantiation where the base category is `(ℕ, ≤)` and the fibers are carrier types.

**Galois connections** in order theory formalize the adjunction between forward and backward transfer of properties. Our covariant/contravariant duality is an instance of this pattern.

## 2. Definitions and Notation

### 2.1 Research Theories

A **research theory** `T` consists of:
- A carrier type `T.Carrier : Type`
- An invariant function `T.Inv : T.Carrier → ℕ`

The invariant measures a quantitative attribute of theory objects (complexity, depth, dimension, fault tolerance, etc.).

### 2.2 Theory Morphisms

A **theory morphism** `f : TheoryHom T U` consists of:
- A function `f.toFun : T.Carrier → U.Carrier`
- A monotonicity witness `f.monotone_inv : ∀ x, T.Inv x ≤ U.Inv (f.toFun x)`

Theory morphisms compose associatively with identity, forming a category.

### 2.3 Invariant-Determined Predicates

**Definition 2.1.** A predicate `P : T.Carrier → Prop` is **invariant-determined** if:
```
InvariantDetermined T P := ∀ ⦃x y⦄, T.Inv x = T.Inv y → (P x ↔ P y)
```

**Definition 2.2.** A predicate `P` **factors through the invariant** if:
```
PredicateFactorsThroughInvariant T P := ∃ R : ℕ → Prop, ∀ x, P x ↔ R (T.Inv x)
```

### 2.4 Transferable Predicates

**Definition 2.3.** A predicate `P` on `T` is **transferable** to `Q` on `U` along `f` if:
```
TransferablePredicate f P Q := ∀ x, P x → Q (f.toFun x)
```

### 2.5 Threshold Predicates

**Definition 2.4.**
- `SatisfiesLowerBoundPred T n := fun x => n ≤ T.Inv x`
- `SatisfiesUpperBound T n := fun x => T.Inv x ≤ n`

## 3. The Factorization Theorem

**Theorem 3.1** (Invariant-Determined ↔ Factors Through Invariant).
```
InvariantDetermined T P ↔ PredicateFactorsThroughInvariant T P
```

*Proof sketch.* 

(⇐) If `P x ↔ R (T.Inv x)` for some `R`, and `T.Inv x = T.Inv y`, then `P x ↔ R(T.Inv x) = R(T.Inv y) ↔ P y`.

(⇒) Define `R(n) := ∃ x, T.Inv x = n ∧ P x`. Then:
- Forward: `P x → ⟨x, rfl, P x⟩`, giving `R(T.Inv x)`.
- Backward: `R(T.Inv x)` gives `⟨y, T.Inv y = T.Inv x, P y⟩`. By invariant-determination, `P y ↔ P x`, so `P x`.

The construction is explicit and does not require choice.  ∎

**Remark 3.2.** The factoring predicate `R` is not unique in general. The canonical choice `R(n) = ∃ x, T.Inv x = n ∧ P x` depends on the carrier, but any two factoring predicates agree on the range of `T.Inv`.

## 4. Transport Theorems

### 4.1 Existential Transport

**Theorem 4.1** (Existential Pushforward).
```
TransferablePredicate f P Q → (∃ x, P x) → ∃ y, Q y
```

*Proof.* Given `⟨x, hx⟩`, produce `⟨f.toFun x, hPQ x hx⟩`.  ∎

### 4.2 Universal Pullback

**Theorem 4.2** (Universal Pullback).
```
(∀ y, Q y) → ∀ x, Q (f.toFun x)
```

*Proof.* Specialization.  ∎

**Theorem 4.3** (Upper Bound Pullback). For `f : TheoryHom T U`:
```
(∀ y, U.Inv y ≤ n) → ∀ x, T.Inv x ≤ n
```

*Proof.* `T.Inv x ≤ U.Inv (f.toFun x) ≤ n` by monotonicity and the hypothesis.  ∎

### 4.3 Invariant-Determined Transfer

**Theorem 4.4** (Stability of Invariant-Determination Under Transport). For any invariant-determined `P` on `T` and morphism `f : TheoryHom T U`:
```
∃ Q : U.Carrier → Prop, TransferablePredicate f P Q ∧ InvariantDetermined U Q
```

*Proof sketch.* Define `Q(y) := ∃ x, P x ∧ T.Inv x ≤ U.Inv y`. Transferability: given `P(x)`, take `⟨x, P x, f.monotone_inv x⟩`. Invariant-determination: if `U.Inv y₁ = U.Inv y₂`, then `Q(y₁) ↔ Q(y₂)` since the definition of Q depends on `U.Inv y` only.  ∎

**Remark 4.5.** The stronger statement with exact invariant preservation:
```
∃ R, (∀ x, P x ↔ R (T.Inv x)) ∧ TransferablePredicate f P (fun y => R (U.Inv y))
```
requires `∀ x, U.Inv (f.toFun x) = T.Inv x` (exact invariant preservation). With only monotonicity (`≤`), this fails: a predicate "Inv = 0" on the source may map to elements with Inv > 0 in the target, and R(0) = True but R(Inv(f(x))) = R(k) for k > 0 may be False.

### 4.4 Lower Bound Transfer (Corollary)

**Corollary 4.6.** For `f : TheoryHom T U` and `n : ℕ`:
```
TransferablePredicate f (SatisfiesLowerBoundPred T n) (SatisfiesLowerBoundPred U n)
```

*Proof.* `n ≤ T.Inv x ≤ U.Inv (f.toFun x)` by transitivity with `f.monotone_inv`.  ∎

**Corollary 4.7.** The original `transfer_lower_bound`:
```
SatisfiesLowerBound T n → SatisfiesLowerBound U n
```
follows by applying existential transport (Theorem 4.1) to Corollary 4.6.

## 5. Functoriality

**Theorem 5.1** (Identity).
```
TransferablePredicate (TheoryHom.id T) P P
```

*Proof.* The identity morphism maps each element to itself.  ∎

**Theorem 5.2** (Composition).
```
TransferablePredicate f P Q → TransferablePredicate g Q R →
  TransferablePredicate (TheoryHom.comp f g) P R
```

*Proof.* `P x → Q (f.toFun x) → R (g.toFun (f.toFun x))`.  ∎

**Corollary 5.3** (Compositional Existential Transport).
```
(∃ x, P x) → ∃ z, R z
```
follows from Theorems 4.1 and 5.2.

**Remark 5.4.** The identity and composition laws make `TransferablePredicate` a profunctor from the category of theories (with morphisms) to the category of predicate pairs (with implication). This profunctorial structure is the categorical content of the framework.

## 6. Boolean Closure

**Theorem 6.1–6.5.** If `P` and `Q` are invariant-determined on `T`, then so are:
- `P ∧ Q` (conjunction)
- `P ∨ Q` (disjunction)
- `¬P` (negation)
- `P → Q` (implication)
- `P ↔ Q` (biconditional)

*Proof.* All follow from the observation that if `T.Inv x = T.Inv y` implies `P x ↔ P y` and `Q x ↔ Q y`, then the same invariant equality implies the corresponding Boolean combination of `P` and `Q` satisfies the analogous biconditional. Formally, conjunction uses `⟨(hP h).1 ∘ And.left, (hQ h).1 ∘ And.right⟩`, negation uses `not_congr`, etc.  ∎

**Corollary 6.6.** Interval predicates `fun x => lo ≤ T.Inv x ∧ T.Inv x ≤ hi` and exact-value predicates `fun x => T.Inv x = n` are invariant-determined.

## 7. Applications and Instantiations

### 7.1 Recovery of Existing Theorems

The following theorems from the existing codebase become one-line corollaries:

| Original Theorem | New Derivation |
|---|---|
| `transfer_lower_bound` | `transferablePredicate_exists f (certified_lower_bound_transfer_via_predicates f n)` |
| `bounded_depth_pullback` | `upper_bound_pullback f n` |
| `transfer_lower_bound_comp` | `lower_bound_exists_chain f g n` |

### 7.2 Cross-Domain Instantiations

**Certified ML (Lipschitz bounds).** The property `SemanticsInvariantCertificate` from `OperadicSemiringSemantics.lean` is exactly invariant-determined with respect to semantic equivalence as the invariant. The `certified_bound_transfer` theorem is an instance of Corollary 4.6 when the morphism preserves semantic equivalence class structure.

**Tropical computation (state counts).** The state count in `TropicalHankelRealizationDuality.lean` serves as the invariant. The `state_count_upper_bound` theorem is a universal upper-bound pullback (Theorem 4.3 instance).

**Byzantine fault tolerance.** The fault tolerance parameter `f` in `ByzantineCertificate.lean` is the invariant. The `parallel_composition_upper_bound` theorem follows from the Boolean closure of invariant-determined upper-bound predicates under the composition structure.

### 7.3 Pipeline Demonstration

```
Height Theory (Inv = id)
  ─── heightToDimension ──→ Dimension Theory (Inv = n+1)
  ─── dimensionToStability ──→ Stability Theory (Inv = id)
  ─── stabilityToCapacity ──→ Capacity Theory (Inv = id)
```

Lower-bound `n` transfers through the entire pipeline:
```
height_to_stability_via_predicates : SatisfiesLowerBound HeightTheory n → SatisfiesLowerBound StabilityTheory n
```

## 8. Computational Experiments

### 8.1 Invariant Determination Check

We implement Algorithm 1 (O(n) time, O(k) space where k = |range(Inv)|) to verify invariant-determination on finite carrier sets. On the test range [0, 20]:

| Predicate | Invariant-Determined? | Factored R |
|---|---|---|
| n ≤ Inv(x), n=5 | Yes | R(m) = (5 ≤ m) |
| Inv(x) ≤ n, n=10 | Yes | R(m) = (m ≤ 10) |
| 3 ≤ Inv(x) ≤ 8 | Yes | R(m) = (3 ≤ m ≤ 8) |
| Inv(x) = 7 | Yes | R(m) = (m = 7) |

### 8.2 Transfer Chain Verification

Algorithm 4 verifies the height → dimension → stability pipeline on [0, 20]:

| Stage | Verified |
|---|---|
| height → dimension | ✓ |
| dimension → stability | ✓ |
| full composition | ✓ |

Witness transport for x=7: Height.Inv(7)=7 → Dim.Inv(7)=8 → Stab.Inv(8)=8 ≥ 7. ✓

### 8.3 Boolean Closure Verification

All Boolean combinations of `(Inv ≥ 3)` and `(Inv ≤ 10)` are verified invariant-determined on [0, 20], producing 9 combined predicates, all passing the invariant-determination check.

## 9. Discussion

### 9.1 The Exact vs. Monotone Distinction

A subtlety emerged during formalization: the strongest transport theorem (transporting the *same* invariant-level predicate R from source to target) requires exact invariant preservation, not just monotonicity. With only `T.Inv x ≤ U.Inv (f.toFun x)`, a predicate like "Inv = 0" on the source does not transfer to "Inv = 0" on the target, because the image may have higher invariant.

Our framework handles this by providing:
1. `invariant_predicate_transport`: full factorization transport, requiring exact preservation
2. `invariant_determined_transfer`: weaker but always available, constructing a *different* codomain predicate `Q(y) = ∃x, P(x) ∧ T.Inv(x) ≤ U.Inv(y)` that is invariant-determined and transferable

This distinction is mathematically important and reflects the difference between isomorphism and monotone map in the invariant category.

### 9.2 Relationship to PreservesProperty

Our `TransferablePredicate` is definitionally equal to the existing `PreservesProperty` from `ComposableTransfer.lean`. This is by design: the new framework generalizes rather than replaces the existing one, and the definitional equality ensures seamless interoperation.

### 9.3 Limitations

The current framework restricts invariants to `ℕ`. Extensions to `ℤ`, `ℝ`, or general ordered types would broaden applicability. The monotonicity requirement `T.Inv x ≤ U.Inv (f.toFun x)` is natural for lower bounds but asymmetric; dual frameworks with `≥` would handle different classes of properties.

## 10. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps, including:
1. Galois connections between pushforward and pullback predicate transformers
2. Generalization to lattice-valued and real-valued invariants
3. A bundled category of theories with predicate transport functors
4. Modal logic of invariant-observable properties
5. Automated certification pipelines via reflexive theory morphism verification

## References

1. Cousot, P., & Cousot, R. (1977). Abstract interpretation: A unified lattice model for static analysis of programs by construction or approximation of fixpoints. *POPL*.

2. Mac Lane, S. (1998). *Categories for the Working Mathematician* (2nd ed.). Springer.

3. Davey, B. A., & Priestley, H. A. (2002). *Introduction to Lattices and Order* (2nd ed.). Cambridge University Press.

4. Awodey, S. (2010). *Category Theory* (2nd ed.). Oxford University Press.

5. Jacobs, B. (1999). *Categorical Logic and Type Theory*. Elsevier.
