# Future Directions

## Concrete Next Steps for the Idempotent Semiring Congruence Program

### 1. Injective Elimination Theorem: Complete Proof

**Status:** Conjectured (see `elimination_fg_of_embedding` in `Algebra/IdempotentCongruence/Theorems.lean`)

The key missing ingredient is showing that finite generation of ring congruences descends along injective variable embeddings `ι : τ ↪ σ` for idempotent semirings. Two promising proof strategies:

- **Strategy A (Noetherian for congruences):** Prove an ascending chain condition for ring congruences on `MvPolynomial τ S` when `S` is an `IdemCommSemiring` and `τ` is finite. This would immediately give elimination since the comap congruence is a sub-congruence of a finitely generated one (via the retraction argument already formalized).

- **Strategy B (Idempotent structure theory):** Exploit the `SemilatticeSup` structure of `IdemCommSemiring` to characterize congruences on polynomial semirings in terms of support-theoretic data. In an idempotent semiring, every polynomial is the join of its monomial terms, and congruences respect this lattice structure.

**Key technical obstacle:** For a ring endomorphism `rename π` (where `π = ι ∘ invFun ι`), showing that a ring congruence `C` satisfies `C f g → C (rename π f) (rename π g)`. This does not hold for arbitrary ring congruences, but may hold when `C` is compatible with the idempotent lattice order.

### 2. Uniqueness/Confluence of Normal Forms for Completed Bases

**Status:** Stated as a conjecture (`normalForm_unique_of_completedBasis`)

Prove that for a completed basis `G` (in the sense of the Buchberger criterion), normal forms are unique. This would give:

```lean
theorem normalForm_unique_of_completedBasis
    (hG : CompletedBasis G)
    (hp : ReflTransGen (ReducibleBy G) p q₁) (hq : ReflTransGen (ReducibleBy G) p q₂)
    (hn1 : NormalForm G q₁) (hn2 : NormalForm G q₂) :
    q₁ = q₂
```

The proof should adapt Newman's Lemma (local confluence + termination → confluence) to the support-decreasing reduction framework. The current `CompletedBasis` definition asserts critical pair confluence; deriving global confluence requires showing that the `ReducibleBy` relation is locally confluent when restricted to support-decreasing steps.

### 3. Dickson's Lemma for Monomial Divisibility Order

**Status:** Not yet formalized

Replace the coarse support-cardinality measure with Dickson's lemma on the monomial divisibility partial order `(σ →₀ ℕ, ≤)`. This gives a much finer well-quasi-ordering:

```lean
theorem dickson_lemma {σ : Type*} [Fintype σ] :
    WellFoundedGT (Finset (σ →₀ ℕ))
```

or equivalently, the divisibility ordering on monomials is a well-quasi-order. This would:
- Strengthen the termination results from support cardinality to monomial divisibility
- Enable coefficient-sensitive reduction (not just support-based)
- Give tighter bounds on completion sequences

Mathlib has `Finsupp.wellFounded_lt` which may be adaptable.

### 4. Certified Congruence-Membership Algorithm

**Status:** Infrastructure ready, extraction needed

With `exists_normalForm` and a refined `CompletedBasis`, extract a certified decision procedure:

```lean
def decideCongruenceMem
    (G : Finset (MvPolynomial σ S × MvPolynomial σ S))
    (hG : CompletedBasis G) (f g : MvPolynomial σ S) :
    Decidable (GeneratesCongruence G C → C f g)
```

This would be the first formally verified decision procedure for tropical polynomial equivalence. The key steps are:
1. Compute normal forms (by `exists_normalForm`)
2. Check if the normal forms are "diagonal" (same support/coefficients)
3. Return a decision with proof

### 5. Tropical Variety Applications

**Status:** Conceptual bridge established

Congruences on tropical polynomial semirings correspond algebraically to tropical prevarieties. The finite basis theorem would give:

- **Finite description of tropical varieties:** Every tropical prevariety defined by finitely many polynomial equivalences has a finite canonical description.
- **Tropical elimination theory:** Projecting a tropical variety to fewer variables preserves its finite description — the geometric content of `elimination_fg_of_embedding`.
- **Algorithmic tropical geometry:** The Buchberger completion procedure provides a computational method for tropical variety intersection and membership testing.

Concrete formalization targets:
```lean
def TropicalPrevariety (G : Finset (MvPolynomial σ TropicalSemiring × ...)) :
    Set (σ → TropicalSemiring) := ...

theorem tropical_elimination :
    TropicalPrevariety (project G ι) = project (TropicalPrevariety G) ι
```

### 6. Extension to Infinite Variables with Finite Support

**Status:** Not started

Generalize from `[Fintype σ]` to arbitrary variable types with a finite support condition. The key insight is that each polynomial only uses finitely many variables, so the well-foundedness arguments should still apply locally:

```lean
theorem exists_normalForm_general
    {σ S : Type*} [CommSemiring S] [DecidableEq σ]
    (G : Finset (MvPolynomial σ S × MvPolynomial σ S))
    (p : MvPolynomial σ S × MvPolynomial σ S) :
    ∃ q, ReflTransGen (ReducibleBy G) p q ∧ NormalForm G q
```

This removes the `[Fintype σ]` hypothesis by working with the finite support of each individual polynomial rather than the ambient variable type.

---

## Broader Research Directions

### A New Gröbner Theory Beyond Rings

The classical Gröbner basis theory relies fundamentally on subtraction (working in a ring). The idempotent semiring framework replaces subtraction with support geometry and congruence pairs. This is not an incremental variant — it is a structurally different algebraic theory. Key questions:

1. **Complexity:** What is the complexity of the Buchberger completion procedure for idempotent semiring congruences? Is there an analogue of the doubly-exponential degree bounds?

2. **Specialization:** For specific idempotent semirings (Boolean, tropical, max-plus), do the general bounds improve?

3. **Connection to formal languages:** Congruences on free idempotent semirings are related to rational/regular language equivalence. Does the Buchberger procedure give new algorithms for language-theoretic problems?

### Automated Reasoning in Max-Plus Systems

The normal form algorithm provides a symbolic simplifier for max-plus expressions. Applications include:
- Scheduling optimization in manufacturing
- Timing analysis in digital circuits
- Performance evaluation of communication protocols
- Control theory for discrete event systems
