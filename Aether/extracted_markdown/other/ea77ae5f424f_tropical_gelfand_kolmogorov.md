# Tropical Gelfand–Kolmogorov Duality: Reconstructing Spaces from Max-Plus Observable Algebras

## Abstract

We establish a tropical analogue of the classical Gelfand–Kolmogorov theorem. For a compact Hausdorff space *X*, we prove that every max-plus semiring homomorphism from C(*X*, ℝ) to ℝ—preserving both pointwise maximum and pointwise addition—is evaluation at a unique point of *X*. This result is formally verified in Lean 4 using the Mathlib library, with no unproven steps.

The theorem shows that the idempotent algebraic structure of continuous functions suffices to completely reconstruct the underlying topological space. We extend the result to dense subalgebras and discuss applications to EML function algebras in machine learning theory.

A critical contribution is identifying that **additivity** (tropical multiplicativity) is an essential axiom: without it, the sup functional φ(*f*) = sup_*x* *f*(*x*) provides a counterexample.

## 1. Introduction

### 1.1 Classical Background

The Gelfand–Kolmogorov theorem (1939) states that for a compact Hausdorff space *X*, every ring homomorphism φ: C(*X*, ℝ) → ℝ is evaluation at a unique point *x*₀ ∈ *X*. This means the space *X* can be completely recovered from the algebraic structure of its function ring—algebra determines topology.

### 1.2 The Tropical Setting

In the tropical (max-plus) semiring, the two operations are:
- **Tropical addition**: *a* ⊕ *b* = max(*a*, *b*)
- **Tropical multiplication**: *a* ⊙ *b* = *a* + *b*

C(*X*, ℝ) carries a natural max-plus semiring structure. A **tropical character** is a functional φ: C(*X*, ℝ) → ℝ satisfying:
1. φ(*f* ⊔ *g*) = max(φ(*f*), φ(*g*))    [preserves tropical addition]
2. φ(*f* + *g*) = φ(*f*) + φ(*g*)          [preserves tropical multiplication]
3. φ(const *c*) = *c*                       [preserves constants]

### 1.3 Main Result

**Theorem** (Tropical Gelfand–Kolmogorov). *Let X be a nonempty compact Hausdorff space. Every tropical character on C(X, ℝ) is evaluation at a unique point.*

### 1.4 Why Additivity Matters

Without the additivity axiom, the theorem fails: φ(*f*) = sup_*x* *f*(*x*) satisfies axioms 1 and 3, plus constant shifts, but not full additivity, and is not a point evaluation. This is the tropical analogue of the classical observation that multiplicativity is the key distinguishing axiom for ring homomorphisms.

## 2. Proof

### 2.1 Key Properties

From the axioms we derive:
- **Monotonicity**: *f* ≤ *g* implies φ(*f*) ≤ φ(*g*) (since *f* ⊔ *g* = *g*).
- **Negation**: φ(−*f*) = −φ(*f*) (from *f* + (−*f*) = 0 and additivity).
- **Absolute value**: φ(|*f*|) = |φ(*f*)| (since |*f*| = *f* ⊔ (−*f*)).

### 2.2 The Absolute Value Trick

**Lemma** (FIP). *For any finite {f₁, ..., fₙ} ⊆ C(X, ℝ), there exists x₀ with fᵢ(x₀) = φ(fᵢ) for all i.*

*Proof*: Set *h* = Σ |*fᵢ* − φ(*fᵢ*)|. Then φ(*h*) = Σ |φ(*fᵢ*) − φ(*fᵢ*)| = 0 and *h* ≥ 0. By compactness and monotonicity, *h* achieves its minimum 0 at some *x*₀, forcing *fᵢ*(*x*₀) = φ(*fᵢ*). □

### 2.3 Completion

The sets S_*f* = {*x* | *f*(*x*) = φ(*f*)} are closed and satisfy the FIP. By compactness, ∩_*f* S_*f* ≠ ∅, giving *x*₀ with φ(*f*) = *f*(*x*₀) for all *f*. Uniqueness follows from T₂ separation (Urysohn). □

## 3. Extension to Dense Subalgebras

For *A* ⊆ C(*X*, ℝ) closed under +, ⊔, negation, containing constants, and separating points, the same absolute value trick works within *A*, giving:

**Theorem**. *Every tropical character on such A is evaluation at a unique point.*

**Corollary** (EML Reconstruction). *For an EML-generated tropical subalgebra satisfying these closure properties, the evaluation map X → TropSpec(A) is a bijection.*

## 4. Formal Verification

The complete proof is verified in Lean 4 with Mathlib. Key declarations:

| Theorem | Statement |
|---------|-----------|
| `tropChar_on_full_alg_eq_eval` | Every character on C(X,ℝ) is evaluation |
| `tropChar_eq_eval_of_dense` | Same for dense subalgebras |
| `evalMap_injective` | Point separation ⟹ injective evaluation |
| `evalMap_bijective` | Full bijectivity under hypotheses |
| `evalEmbedding_continuous` | Continuity of evaluation embedding |

Only standard axioms are used (propext, Classical.choice, Quot.sound).

## 5. Applications

**Spectral semantics**: EML observable algebras completely determine their latent state spaces, upgrading approximation to reconstruction.

**Model identification**: Given observed values (*c*₁, ..., *c*ₙ) of generators, minimizing *h*(*x*) = Σ|*fᵢ*(*x*) − *cᵢ*| recovers the unique latent state.

**Tropical vs. classical**: Both the ring structure and the max-plus semiring structure of C(*X*, ℝ) independently determine *X*, suggesting deep connections between classical and tropical algebraic geometry.

## 6. Discussion: The Space Inside the Algebra

Imagine learning about a room's shape only through measurements—temperature, brightness, pressure. Classical mathematics says: knowing how measurements *multiply* reconstructs the room. Our result says: knowing only how to take *maxima* and *sums* also reconstructs it completely. The max-plus structure alone remembers the space.

This is practically relevant because max and addition are the fundamental operations in tropical neural networks (ReLU networks). Our theorem suggests that the algebraic structure of a neural network's feature space contains enough information to recover the input space entirely—a potential foundation for understanding neural representations through algebraic duality.

## 7. Conclusion

We established and formally verified a tropical Gelfand–Kolmogorov theorem. The proof introduces the "absolute value trick" for idempotent semiring characters. Future directions include tropical Choquet theory, algorithmic reconstruction, tropical Banach–Stone rigidity, and spectral invariants for EML model classification.
