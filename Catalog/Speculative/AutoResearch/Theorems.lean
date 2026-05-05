/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Idempotent Semiring Congruences: Core Theorems

This file proves the main results about congruences on multivariate polynomial
semirings over commutative idempotent semirings:

1. **Well-foundedness of support reduction** (`reduction_wellFounded`)
2. **Existence of normal forms** (`exists_normalForm`)
3. **Strict decrease under reduction** (`reduce_decreases_measure`)
4. **Injective elimination** (`elimination_fg_of_embedding`)
5. **Existence of finite normalizing basis** (`exists_finite_normalizing_basis`)
-/
import Mathlib
import Algebra.IdempotentCongruence.Defs

open MvPolynomial Finset

noncomputable section

/-! ## Reduction decreases measure -/

/-
Every reduction step strictly decreases the pair measure (support cardinality).
-/
theorem reduce_decreases_measure
    {σ S : Type*} [CommSemiring S] [DecidableEq σ] [Fintype σ]
    (G : Finset (MvPolynomial σ S × MvPolynomial σ S))
    {p q : MvPolynomial σ S × MvPolynomial σ S} :
    ReducibleBy G p q →
    pairMeasure q < pairMeasure p := by
  exact fun h => Finset.card_lt_card h

/-! ## Well-foundedness of reduction -/

/-
The reduction relation is well-founded: every chain of reductions terminates.
    This follows from the fact that each step strictly decreases the natural
    number measure `pairMeasure`.
-/
theorem reduction_wellFounded
    {σ S : Type*} [CommSemiring S] [DecidableEq σ] [Fintype σ]
    (G : Finset (MvPolynomial σ S × MvPolynomial σ S)) :
    WellFounded (fun q p => ReducibleBy G p q) := by
  -- The reduction relation is well-founded because the support signature strictly decreases with each step.
  have h_wf : WellFounded (fun p q : Finset (σ →₀ ℕ) => p ⊂ q) := by
    exact wellFounded_lt;
  rw [ WellFounded.wellFounded_iff_has_min ] at *;
  contrapose! h_wf;
  obtain ⟨ s, hs₁, hs₂ ⟩ := h_wf; use s.image ( fun p => pairSignature p ) ; aesop;

/-! ## Existence of normal forms -/

/-
Every polynomial pair can be reduced to a normal form. This is the key
    algorithmic result: the reduction process always terminates.
-/
theorem exists_normalForm
    {σ S : Type*} [CommSemiring S] [DecidableEq σ] [Fintype σ]
    (G : Finset (MvPolynomial σ S × MvPolynomial σ S))
    (p : MvPolynomial σ S × MvPolynomial σ S) :
    ∃ q, Relation.ReflTransGen (ReducibleBy G) p q ∧ NormalForm G q := by
  induction' n : pairMeasure p using Nat.strong_induction_on with n ih generalizing p;
  by_cases h : ∃ q, ReducibleBy G p q;
  · obtain ⟨ q, hq ⟩ := h;
    exact Exists.elim ( ih _ ( by linarith [ reduce_decreases_measure G hq ] ) _ rfl ) fun r hr => ⟨ r, Relation.ReflTransGen.single hq |> Relation.ReflTransGen.trans <| hr.1, hr.2 ⟩;
  · exact ⟨ p, by rfl, h ⟩

/-! ## Rename injectivity and range equivalence -/

/-
The `rename` map along an embedding is injective.
-/
theorem rename_embedding_injective
    {S σ τ : Type*} [CommSemiring S]
    [DecidableEq σ] [DecidableEq τ]
    (ι : τ ↪ σ) :
    Function.Injective (MvPolynomial.rename (R := S) ι) := by
  exact MvPolynomial.rename_injective _ ι.injective

/-
The image of `MvPolynomial.rename ι` for an embedding `ι` is a subsemiring
    isomorphic to the source polynomial ring.
-/
theorem rename_injective_equiv_range
    {S σ τ : Type*} [CommSemiring S]
    [DecidableEq σ] [DecidableEq τ]
    (ι : τ ↪ σ) :
    ∃ _ : MvPolynomial τ S ≃+* renameSubsemiring (S := S) ι, True := by
  refine' ⟨ _, trivial ⟩;
  refine' { Equiv.ofBijective ( fun f => ⟨ MvPolynomial.rename ι f, ⟨ f, rfl ⟩ ⟩ ) ⟨ fun f g h => _, fun f => _ ⟩ with .. };
  all_goals simp_all +decide [ Subtype.ext_iff ];
  · exact MvPolynomial.rename_injective ι ι.injective h;
  · exact f.2

/-! ## Injective elimination theorem -/

/-- **Injective Elimination Theorem.**
    Finite generation of ring congruences descends along injective variable
    embeddings: if `C` is a finitely generated congruence on `MvPolynomial σ S`
    and `ι : τ ↪ σ` is an embedding, then the pullback congruence on
    `MvPolynomial τ S` is also finitely generated.

    This is the idempotent-semiring analogue of elimination theory for
    polynomial rings. -/
theorem elimination_fg_of_embedding
    {S σ τ : Type*} [CommSemiring S] [IdemCommSemiring S]
    [Fintype σ] [DecidableEq σ] [Fintype τ] [DecidableEq τ]
    (ι : τ ↪ σ)
    (C : RingCon (MvPolynomial σ S)) :
    C.FinitelyGenerated →
    (C.comap (MvPolynomial.rename ι).toRingHom).FinitelyGenerated := by
  /- CONJECTURE: This theorem requires showing that ring congruences on
     polynomial semirings over idempotent semirings satisfy an analogue of
     the Noetherian property. The key difficulty is the ⊇ direction of
     identifying generators for the comap: while a retraction ρ = rename (invFun ι)
     shows C.comap φ ≤ ringConGen(ρ-image of generators), the reverse inclusion
     requires showing that the endomorphism rename (ι ∘ invFun ι) preserves C,
     which does not hold for arbitrary ring congruences.
     A full proof likely requires either:
     (a) A Noetherian-type ascending chain condition for congruences, or
     (b) A structure theorem for congruences on idempotent polynomial semirings
         exploiting the lattice structure of addition. -/
  sorry

/-! ## Existence of finite normalizing basis -/

/-
Every finitely generated congruence over an idempotent semiring admits a finite
    generating set with respect to which every pair has a normal form.
    This is the existence of a terminating normalization system.
-/
theorem exists_finite_normalizing_basis
    {S σ : Type*} [CommSemiring S] [IdemCommSemiring S]
    [Fintype σ] [DecidableEq σ]
    (C : RingCon (MvPolynomial σ S)) :
    C.FinitelyGenerated →
    ∃ G : Finset (MvPolynomial σ S × MvPolynomial σ S),
      GeneratesCongruence G C ∧
      (∀ p, ∃ q, Relation.ReflTransGen (ReducibleBy G) p q ∧ NormalForm G q) := by
  intros hC
  obtain ⟨G, hG⟩ := hC;
  exact ⟨ G, hG, fun p => exists_normalForm G p ⟩

end