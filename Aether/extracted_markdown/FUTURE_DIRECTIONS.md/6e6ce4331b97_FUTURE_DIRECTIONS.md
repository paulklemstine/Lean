# Future Directions: Testable Hypotheses for Formal Class Field Theory

## Overview

This document presents five falsifiable scientific hypotheses emerging from our formalization of Artin map surjectivity, capitulation, and degree equality for Hilbert class fields. Each hypothesis specifies a precise conjecture, a concrete formal test, and success/failure criteria.

---

## Hypothesis 1: Ray Class Precursor Hypothesis

**Conjecture.** The surjective Artin map extends from ordinary class groups to ray class groups modulo a finite modulus 𝔪. Specifically, for a number field K and a modulus 𝔪, there exists a surjective group homomorphism

  Art_{𝔪} : Cl_𝔪(O_K) ↠ Gal(K_𝔪/K)

where K_𝔪 is the maximal abelian extension of K unramified outside 𝔪, and Cl_𝔪(O_K) is the ray class group modulo 𝔪.

**Test.** Formalize a ray class group surrogate in Lean 4:
```
structure IsRayClassField (K L : Type*) [...] (𝔪 : Ideal (𝓞 K)) : Prop where
  finiteDimensional : FiniteDimensional K L
  isGalois : IsGalois K L
  galGroupComm : ∀ (σ τ : L ≃ₐ[K] L), σ.trans τ = τ.trans σ
  ramification_bound : ∀ (𝔭 : Ideal (𝓞 K)), 𝔭.IsPrime → ¬(𝔭 ∣ 𝔪) → IsUnramifiedAt K L 𝔭
  artinIso : Nonempty (RayClassGroup (𝓞 K) 𝔪 ≃* (L ≃ₐ[K] L))
```
Prove the analogue of `artinMap_surjective_of_isHilbertClassField` for one explicit modulus over Q(√−5) or Q(i).

**Success criterion.** A compiled Lean theorem with no sorry, producing a surjective MonoidHom from a ray class group onto a Galois group, for at least one non-trivial modulus.

**Failure criterion.** If Mathlib lacks ray class group infrastructure and the construction from fractional ideals modulo a congruence subgroup cannot be formalized within 500 lines of new code, the hypothesis is deferred.

**Impact.** Success would extend formal reciprocity from unramified to ramified extensions, covering Dirichlet characters and cyclotomic fields.

---

## Hypothesis 2: Capitulation Detection Hypothesis

**Conjecture.** For cyclic unramified extensions L/K of prime degree p, the capitulation kernel (the set of ideal classes of K that become principal in L) equals the image of the group-theoretic transfer (Verlagerung) map Ver : Gal(L/K)^{ab} → Cl(O_K).

More precisely, define the canonical extension-of-ideals map ι : Cl(O_K) → Cl(O_L) via I ↦ I · O_L. Then:

  ker(ι) = im(Ver)

where Ver : Cl(O_L) → Cl(O_K) is the transfer map induced by the Galois action.

**Test.**
1. Define the canonical extension-of-ideals map ι in Lean 4 using the ideal extension infrastructure in Mathlib.
2. Define the transfer/Verlagerung map.
3. For Q(√−23) with its degree-3 Hilbert class field, compute ker(ι) and im(Ver) and verify they coincide.

```
theorem capitulation_kernel_eq_transfer_image
    (K L : Type*) [...] (hCyclic : IsCyclic (L ≃ₐ[K] L)) :
    MonoidHom.ker (extensionMap K L) = MonoidHom.range (transferMap L K) := by sorry
```

**Success criterion.** The kernel-image equality compiles for at least one non-trivial cyclic extension.

**Failure criterion.** The transfer map definition requires formalization of group cohomology H^{-1}(G, Cl(O_L)), which is currently absent from Mathlib.

**Impact.** Resolving this would connect formal class field theory to group cohomology, opening Iwasawa-theoretic directions.

---

## Hypothesis 3: CM Generation Hypothesis

**Conjecture.** For each Heegner discriminant D ∈ {−3, −4, −7, −8, −11, −19, −43, −67, −163}, the splitting field of the certified Hilbert class polynomial H_D over Q(√d) satisfies `IsHilbertClassField`.

Since all these have class number 1, the conjecture reduces to: the splitting field of H_D is Q(√d) itself, and the trivial extension satisfies IsHilbertClassField with the identity isomorphism.

**Test.** For each Heegner discriminant:
```
theorem heegner_isHilbertClassField_neg4 :
    IsHilbertClassField (QuadraticField (-1)) (QuadraticField (-1)) := by
  exact ⟨inferInstance, inferInstance, fun σ τ => by ext; simp, ⟨{
    toFun := fun _ => AlgEquiv.refl,
    invFun := fun _ => 1,
    left_inv := fun _ => Subsingleton.elim _ _,
    right_inv := fun _ => Subsingleton.elim _ _,
    map_mul' := fun _ _ => by simp
  }⟩⟩
```

**Success criterion.** All 9 Heegner instances compile without sorry, using `QuadraticField d` from Mathlib.

**Failure criterion.** If `QuadraticField` does not support the required instances (e.g., `Subsingleton (ClassGroup (𝓞 (QuadraticField d)))` is not decidable), the hypothesis fails for that discriminant.

**Impact.** This would give the first concrete instantiation of IsHilbertClassField, transitioning from abstract to verified arithmetic.

---

## Hypothesis 4: Functoriality Hypothesis

**Conjecture.** Artin maps in towers of unramified abelian extensions form a natural transformation. Specifically, for K ⊆ M ⊆ L with both M/K and L/K being Hilbert class fields:

  res_{L/M} ∘ Art_{L/K} = Art_{M/K}

where res_{L/M} : Gal(L/K) → Gal(M/K) is the restriction map.

**Test.** Prove commutativity for one explicit tower. The minimal interesting case is K = Q(√−23), M = intermediate field of [H:K] = 3, L = H.

In Lean:
```
theorem artinMap_restriction_commutes
    (K M L : Type*) [...]
    [IsScalarTower K M L]
    (hKM : IsHilbertClassField K M)
    (hKL : IsHilbertClassField K L)
    (res : (L ≃ₐ[K] L) →* (M ≃ₐ[K] M))
    (Art_KL : ClassGroup (𝓞 K) ≃* (L ≃ₐ[K] L))
    (Art_KM : ClassGroup (𝓞 K) ≃* (M ≃ₐ[K] M)) :
    ∀ c, res (Art_KL c) = Art_KM c := by sorry
```

**Success criterion.** The commutativity theorem compiles for at least one non-trivial tower, even if the restriction map is axiomatized.

**Failure criterion.** Mathlib's `AlgEquiv.restrictNormalHom` does not provide the necessary tower compatibility infrastructure.

**Impact.** Functoriality is the central organizing principle of the Langlands program. Even a single verified instance would demonstrate that formal reciprocity can be structured categorically.

---

## Hypothesis 5: Abelian Langlands Shadow Hypothesis

**Conjecture.** There is a bijection between:
- Finite-order Hecke characters of K unramified everywhere, i.e., group homomorphisms χ : Cl(O_K) → ℂˣ
- 1-dimensional continuous representations ρ : Gal(H/K) → ℂˣ

realized by χ ↦ χ ∘ Art⁻¹.

**Test.** We have already proved injectivity of this map (`galoisCharacterOfClassGroupCharacter_injective`). The remaining test is *surjectivity*: every Galois character comes from a class group character.

```
theorem galoisCharacterOfClassGroupCharacter_surjective
    {K L : Type*} [...] (hHCF : IsHilbertClassField K L) :
    Function.Surjective (galoisCharacterOfClassGroupCharacter hHCF) := by sorry
```

This would give bijectivity, completing the abelian Langlands correspondence for unramified characters.

**Success criterion.** The surjectivity theorem compiles without sorry, giving a formal bijection between class group characters and Galois characters.

**Failure criterion.** The proof requires showing that precomposition with a MulEquiv is surjective on MonoidHom spaces, which may require Mathlib API that does not exist.

**Impact.** A formal bijection between automorphic and Galois objects, even in the simplest abelian unramified case, would be the first machine-verified instance of the Langlands correspondence. It would demonstrate that reciprocity is not merely an existence theorem but a computable correspondence.

---

## Priority Ordering

1. **Hypothesis 5** (Abelian Langlands surjectivity) — closest to current infrastructure, highest novelty-per-effort ratio.
2. **Hypothesis 3** (CM generation for Heegner numbers) — concretizes the abstract theory.
3. **Hypothesis 2** (Capitulation detection) — deepens understanding of the extension map.
4. **Hypothesis 1** (Ray class precursor) — extends the theory to ramified extensions.
5. **Hypothesis 4** (Functoriality) — the most ambitious, but potentially transformative.

---

## Methodology Notes

Each hypothesis is designed to be *falsifiable* in a precise sense: the Lean compiler is the arbiter. A hypothesis succeeds if and only if a Lean file compiles without sorry, using only standard axioms. This eliminates ambiguity about proof correctness and provides a reproducible criterion for progress.

The hypotheses are ordered by estimated difficulty and infrastructure requirements. We recommend attempting them in priority order, with the understanding that failure on one hypothesis often reveals the exact Mathlib infrastructure needed, guiding future library development.
