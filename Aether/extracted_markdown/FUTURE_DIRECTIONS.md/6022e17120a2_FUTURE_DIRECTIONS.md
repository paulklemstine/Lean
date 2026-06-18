# Future Directions: EML Closure Systems

## Overview

The closure–kernel duality established in `EML/GaloisDuality.lean` opens a rich vein of research connecting expressive model logics to lattice theory, formal concept analysis, and quantitative complexity. Below are five specific next steps, each with theorem statements, motivation, proof strategies, and dependencies on the current work.

---

## 1. EML Basis Irredundancy Theorem

### Exact Theorem Statement

```
def IsIrredundantGenerator (A : Set (ℝ → ℝ)) (C : Set (ℝ → ℝ)) : Prop :=
  EMLClosure A = C ∧ ∀ f ∈ A, EMLClosure (A \ {f}) ≠ C

theorem irredundant_generator_exists
    (C : Set (ℝ → ℝ)) (hC : EMLClosure C = C)
    (A : Set (ℝ → ℝ)) (hA : EMLClosure A = C) (hfin : A.Finite) :
    ∃ B ⊆ A, IsIrredundantGenerator B C
```

### Why It Matters

Irredundant generators are the analogue of bases in linear algebra or irredundant axiom sets in logic. They represent the minimal expressive core of a model class—removing any single generator strictly reduces expressivity. This is foundational for model compression and architecture search.

### Proof Strategy

Use Zorn's lemma (or finite descent for finite generators) on the poset of subsets of `A` whose closure equals `C`, ordered by reverse inclusion. The closure operator's monotonicity ensures that removing elements can only shrink the closure. The finite case follows by simple induction on cardinality.

### Dependencies

Requires `eml_gc_explicit` and `emlClosure_monotone'` from the current file. Also uses `minimalGeneratorsEq` as the universal lower bound for generators.

---

## 2. EML Concept Lattice

### Exact Theorem Statement

```
instance : CompleteLattice (emlClosureOp'.Closeds)

theorem eml_closed_sets_complete_lattice :
    ∀ (S : Set emlClosureOp'.Closeds),
      ∃ (sup inf : emlClosureOp'.Closeds),
        (∀ C ∈ S, C ≤ sup) ∧ (∀ D, (∀ C ∈ S, C ≤ D) → sup ≤ D) ∧
        (∀ C ∈ S, inf ≤ C) ∧ (∀ D, (∀ C ∈ S, D ≤ C) → D ≤ inf)
```

### Why It Matters

The complete lattice of EML-closed sets is the concept lattice of the EML framework. It provides:
- A canonical taxonomy of expressive classes, ordered by inclusion.
- Supremum (join) = closure of union, infimum (meet) = intersection.
- A bridge to Formal Concept Analysis, where concept intents correspond to closed EML classes.

### Proof Strategy

This follows directly from the Galois insertion `eml_galois_insertion_closed` and the Moore family theorem `eml_moore_family`. Mathlib's `GaloisInsertion.liftCompleteLattice` can be applied directly. The meet is `⋂₀`, which is closed by `eml_closed_sInter`. The join is `EMLClosure (⋃₀ ·)`.

### Dependencies

Requires `eml_galois_insertion_closed`, `eml_closed_sInter`, and `eml_moore_family`.

---

## 3. EML Closure Dimension (Carathéodory-type Bounds)

### Exact Theorem Statement

```
def EMLClosureDimension (C : Set (ℝ → ℝ)) : ℕ∞ :=
  ⨅ (A : Set (ℝ → ℝ)) (_ : EMLClosure A = C ∧ A.Finite), (A.toFinset.card : ℕ∞)

theorem eml_polynomial_closure_dimension_le
    (n : ℕ) (C : Set (ℝ → ℝ))
    (hC : C = EMLClosure {fun x => x ^ k | k ≤ n}) :
    EMLClosureDimension C ≤ n + 1
```

### Why It Matters

Closure dimension quantifies the "complexity" of an EML class—how many generators are needed to produce it. This is an EML analogue of:
- Linear algebra dimension (number of basis vectors).
- Algebraic transcendence degree.
- VC dimension (but for generative rather than discriminative capacity).

Carathéodory-type bounds would say: every element of the closure of a finite set can be expressed using at most `d` generators, where `d` depends on the algebraic structure.

### Proof Strategy

For polynomial classes, the bound follows from counting monomials. The general theory requires analyzing the inductive depth of `EMLGenerated` derivations and bounding the number of distinct generators used.

### Dependencies

Requires `emlClosureOp'` and the closure axioms. Benefits from the irredundancy theory (Direction 1).

---

## 4. Quantitative EML Nullstellensatz

### Exact Theorem Statement

```
theorem eml_nullstellensatz_finite
    (A : Finset (ℝ → ℝ)) (f : ℝ → ℝ)
    (hf : f ∈ EMLClosure (A : Set (ℝ → ℝ)))
    (S : Finset ℝ)
    (hzero : ∀ g ∈ A, ∀ x ∈ S, g x = 0) :
    ∀ x ∈ S, f x = 0 ∨ ∃ c : ℝ, f = fun _ => c
```

### Why It Matters

This is the EML analogue of Hilbert's Nullstellensatz: if all generators vanish on a set, what can be said about functions in the closure? The classical Nullstellensatz connects ideals to varieties; the EML version connects generator zero-sets to closure zero-sets. This has applications in:
- Identifiability: understanding when model outputs are forced to be constant.
- Zero-set bounds: connecting to `nonzero_linear_form_zero_set_bound` from the existing catalog.
- Algebraic structure of neural network function classes.

### Proof Strategy

Induction on the `EMLGenerated` derivation. The base case is immediate. Constants either vanish or are constant (trivially). Addition and multiplication of functions that vanish on S also vanish on S. Composition requires care: `f(g(x))` where `g(x) = 0` gives `f(0)`, which is a constant.

### Dependencies

Requires the `EMLGenerated'` inductive type and `EMLClosure'` definition. Could leverage `eml_level_set` and `mvpolynomial_zero_set_card_le_totalDegree_mul_pow` from the existing catalog for quantitative refinements.

---

## 5. Abstract Interpretation via EML Closure

### Exact Theorem Statement

```
def EMLAbstraction (concrete : Set (ℝ → ℝ)) : Set (ℝ → ℝ) :=
  EMLClosure concrete

def EMLBestApproximation (abstract : Set (ℝ → ℝ)) (concrete : Set (ℝ → ℝ)) : Prop :=
  EMLClosure concrete ⊆ abstract ∧
  ∀ A, EMLClosure concrete ⊆ A → A ⊆ abstract → A = abstract

theorem eml_abstraction_is_best_approximation
    (concrete : Set (ℝ → ℝ)) :
    EMLBestApproximation (EMLClosure concrete) concrete
```

### Why It Matters

Abstract interpretation is a foundational framework in program analysis where concrete semantics are approximated by abstract domains. The EML closure provides a natural abstraction: given a concrete set of functions (e.g., those computable by a specific architecture), the EML closure is the best (smallest) EML-closed over-approximation. This connects to:
- Certified model compression: if two architectures have the same EML closure, they are expressively equivalent.
- Semantic analysis of neural networks.
- Fixed-point computation for iterative model refinement.

### Proof Strategy

The best approximation property follows directly from the Galois connection: `EMLClosure` is the left adjoint, so `EMLClosure concrete` is the least closed set containing `concrete`. The Galois insertion ensures this is optimal.

### Dependencies

Requires `eml_galois_insertion_closed` and `eml_gc_explicit`.

---

## Cross-Cutting Themes

All five directions share common infrastructure:

1. **The Galois insertion** (`eml_galois_insertion_closed`) provides the semantic adjunction that makes generators and closed classes dually related.

2. **The Moore family theorem** (`eml_moore_family`) ensures that intersections of closed classes remain closed, enabling lattice-theoretic constructions.

3. **The explicit biconditional** (`eml_gc_explicit`) is the workhorse lemma: it converts between generator-side and closure-side reasoning with a single rewrite.

4. **The core operator** (`emlCore`) provides a canonical "minimal content" map that can be refined with additional algebraic hypotheses.

Together, these form a **closure-theoretic engine** that can be instantiated not only for EML but for any inductively defined closure system—tropical algebras, probabilistic model classes, or differentiable function spaces.
