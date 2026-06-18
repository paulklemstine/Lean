# Future Directions: Idempotent Congruence Hilbert Basis Theory

This document outlines concrete next steps building on the formalized reduced basis
theory for finitely generated semiring congruences.

---

## 1. Buchberger-Style Completion for Idempotent Congruence Bases

**Goal**: Develop a completion algorithm that, given two finite generating sets of
compatible congruences, computes a common reduced basis for their join (smallest
congruence containing both).

**Formalization target**:
```lean
def buchbergerCompletion
    {A : Type*} [DecidableEq A] [Semiring A]
    (S₁ S₂ : Finset (RelPair A)) : Finset (RelPair A)

theorem buchbergerCompletion_spec
    {A : Type*} [DecidableEq A] [Semiring A]
    (S₁ S₂ : Finset (RelPair A)) :
    IsReducedCongruenceBasis
      (SemiringCongruence.generatedBy (S₁ ∪ S₂))
      (buchbergerCompletion S₁ S₂)
```

**Why it matters**: This is the congruence analogue of Buchberger's algorithm for
Gröbner bases. It would enable algorithmic computation of intersections and joins
of congruences, which is essential for tropical elimination theory.

---

## 2. Tropical Syzygy Modules and Congruence Homology

**Goal**: Define first syzygies among congruence generators — finite certificates
that witness redundancy relations among the generators of a reduced basis.

**Key definition**:
```lean
structure CongruenceSyzygy {A : Type*} [Semiring A]
    (B : Finset (RelPair A)) where
  coefficients : RelPair A → ℤ
  support : Finset (RelPair A)
  support_sub : support ⊆ B
  is_syzygy : -- the weighted combination is trivial in the congruence
```

**Why it matters**: Syzygies encode the "relations among relations" and form the
first step toward a congruence homology theory. In classical commutative algebra,
syzygy modules control free resolutions and Hilbert functions. The idempotent
analogue would give a homological invariant for tropical varieties.

---

## 3. Elimination Orders and Tropical Hilbert Functions

**Goal**: Define a notion of elimination order on congruence generators (analogous
to monomial orders in polynomial rings) and prove that elimination preserves
finite generation.

**Formalization target**:
```lean
def eliminationOrder {A : Type*} [Semiring A]
    (C : SemiringCongruence A) (vars : List (A → A)) :
    SemiringCongruence A

theorem elimination_preserves_fg
    {A : Type*} [Semiring A]
    (C : SemiringCongruence A) (v : A → A) :
    IsFinitelyGeneratedCongruence C →
    IsFinitelyGeneratedCongruence (eliminationOrder C [v])
```

**Why it matters**: Elimination theory is how you project geometric objects
(varieties, congruence loci) onto lower-dimensional spaces. A formal elimination
theorem for congruences would enable algorithmic tropical implicitization — computing
the tropical variety of a parametrically defined object.

---

## 4. Certified Algorithms for EML Neural Function Algebras

**Goal**: Implement and verify algorithms that decide equality and redundancy
in concrete EML (Exponential-Max-Linear) function algebras, using the reduced
basis infrastructure.

**Key application**: In neural network verification, EML functions represent
ReLU networks. Two networks compute the same function iff their representations
lie in the same congruence class. A certified reduced basis algorithm would give
provably correct network equivalence checking.

**Formalization target**:
```lean
def EMLFunctionAlgebra (n : ℕ) := (Fin n → ℝ) → ℝ

noncomputable def emlCongruenceDecide
    {n : ℕ} (S : Finset (RelPair (EMLFunctionAlgebra n)))
    (f g : EMLFunctionAlgebra n) :
    Decidable ((SemiringCongruence.generatedBy S).r f g)
```

**Why it matters**: This connects the abstract algebraic theory to practical
computation in machine learning and optimization. Certified equivalence checking
for neural networks is an active area where formal verification adds real value.

---

## 5. Canonical Congruence Bases via Bend Relations

**Goal**: Prove that for radical vanishing congruences in EML algebras, the
reduced basis is not merely inclusion-minimal but *canonical* — unique up to
a well-defined normal form.

**Conjecture**:
```lean
theorem canonical_reduced_basis_unique
    {A : Type*} [Semiring A] [IdempotentAdd A]
    {C : SemiringCongruence A} :
    IsRadicalVanishingCongruence C →
    IsFinitelyGeneratedCongruence C →
    ∃! B : Finset (RelPair A), CanonicalBasisProperty C B
```

**Why it matters**: Canonicality is the difference between a useful normal form
and merely a minimal presentation. Unique canonical bases would give a
complete invariant for tropical varieties — two varieties are equal iff their
canonical congruence bases are equal. This is the tropical analogue of the
reduced Gröbner basis theorem in classical algebraic geometry.

---

## Priority Assessment

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|-------------|
| 1. Buchberger completion | Medium | High | Current work |
| 2. Syzygy modules | High | Very High | Direction 1 |
| 3. Elimination orders | Medium | High | Current work |
| 4. EML certification | Medium | Very High (practical) | Current work + EML defs |
| 5. Canonical bases | Very High | Breakthrough | Directions 1-3 |

The recommended path is: **1 → 3 → 4** for practical impact, and **1 → 2 → 5** for
theoretical depth. Direction 4 (certified EML algorithms) is the most immediately
applicable to real-world problems in neural network verification and optimization.
