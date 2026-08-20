/-
# Class-group descent along intermediate fields of a Hilbert class field datum

This file completes the descent picture for the catalog's conditional Hilbert class field
reciprocity interface.  Given a number field `K`, a finite Galois extension `H/K` and an Artin
reciprocity isomorphism `e : Gal(H/K) ≃* Cl(𝒪_K)`, every intermediate field `K ≤ L ≤ H` gives a
subgroup

  `artinImage e L := e (Gal(H/L)) ≤ Cl(𝒪_K)`

and the results below identify the arithmetic of `L` with the arithmetic of this subgroup:

* `galoisEquivQuotient` : `Gal(L/K) ≃* Cl(𝒪_K) ⧸ artinImage e L`;
* `finrank_eq_index` : `[L : K] = (artinImage e L).index`;
* `finrank_top_eq_card` : `[H : L] = #(artinImage e L)`;
* `character_descent` : an ideal-class character descends to a character of `Gal(L/K)` exactly
  when it is trivial on `artinImage e L`;
* `eq_bot_or_eq_top_of_classNumber_prime` : if `h_K` is prime, the only intermediate fields are
  `⊥` and `⊤`.
-/

import Catalog.NumberTheory.HilbertClassFieldIntermediate

open NumberField

namespace HilbertClassFieldDescent

noncomputable section

/-- Every intermediate field of a Hilbert class field datum is normal over the base; this is the
`Normal` instance packaged from `HilbertClassFieldIntermediate.intermediate_isGalois`. -/
theorem normal_of_reciprocity
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) : Normal K L :=
  letI : IsGalois K L := HilbertClassFieldIntermediate.intermediate_isGalois K H e L
  IsGalois.to_normal

/-- Restriction of automorphisms `Gal(H/K) → Gal(L/K)`, available for every intermediate field
of a Hilbert class field datum because such fields are automatically normal. -/
def restrictHom
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) : (H ≃ₐ[K] H) →* (L ≃ₐ[K] L) :=
  letI : Normal K L := normal_of_reciprocity K H e L
  AlgEquiv.restrictNormalHom L

theorem restrictHom_surjective
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) : Function.Surjective (restrictHom K H e L) :=
  letI : Normal K L := normal_of_reciprocity K H e L
  AlgEquiv.restrictNormalHom_surjective H

theorem restrictHom_ker
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) : (restrictHom K H e L).ker = L.fixingSubgroup :=
  letI : Normal K L := normal_of_reciprocity K H e L
  IntermediateField.restrictNormalHom_ker L

/-- The image under Artin reciprocity of the subgroup of automorphisms fixing `L`.  This is the
class-group side of the intermediate field `L`. -/
def artinImage
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) : Subgroup (ClassGroup (RingOfIntegers K)) :=
  L.fixingSubgroup.map e.toMonoidHom

theorem mem_artinImage_iff
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) (c : ClassGroup (RingOfIntegers K)) :
    c ∈ artinImage K H e L ↔ e.symm c ∈ L.fixingSubgroup := by
  constructor
  · rintro ⟨σ, hσ, rfl⟩
    simpa using hσ
  · intro h
    exact ⟨e.symm c, h, by simp⟩

/-- **Descent of Artin reciprocity to an intermediate field.**  The Galois group of `L/K` is
isomorphic to the quotient of the ideal class group by the Artin image of `Gal(H/L)`. -/
def galoisEquivQuotient
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) :
    (L ≃ₐ[K] L) ≃* ClassGroup (RingOfIntegers K) ⧸ artinImage K H e L :=
  (QuotientGroup.quotientKerEquivOfSurjective (restrictHom K H e L)
        (restrictHom_surjective K H e L)).symm.trans
    (QuotientGroup.congr _ _ e (by rw [restrictHom_ker]; rfl))

/-- The descent isomorphism sends the restriction of `σ` to the class of `e σ`. -/
theorem galoisEquivQuotient_restrictHom
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) (σ : H ≃ₐ[K] H) :
    galoisEquivQuotient K H e L (restrictHom K H e L σ)
      = QuotientGroup.mk (e σ) := by
  have h : (QuotientGroup.quotientKerEquivOfSurjective (restrictHom K H e L)
      (restrictHom_surjective K H e L)).symm (restrictHom K H e L σ)
      = QuotientGroup.mk σ := by
    rw [MulEquiv.symm_apply_eq]
    rfl
  simp [galoisEquivQuotient, h]

/-- **Degree as a subgroup index.**  The degree of an intermediate field over the base equals the
index in the class group of the Artin image of its fixing subgroup. -/
theorem finrank_eq_index
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) :
    Module.finrank K L = (artinImage K H e L).index := by
  letI : IsGalois K L := HilbertClassFieldIntermediate.intermediate_isGalois K H e L
  have h1 : Nat.card (L ≃ₐ[K] L) = Module.finrank K L := IsGalois.card_aut_eq_finrank K L
  have h2 : Nat.card (L ≃ₐ[K] L)
      = Nat.card (ClassGroup (RingOfIntegers K) ⧸ artinImage K H e L) :=
    Nat.card_congr (galoisEquivQuotient K H e L).toEquiv
  rw [← h1, h2]
  rfl

/-- **Relative degree as a subgroup order.**  The degree of the Hilbert class field over an
intermediate field equals the order of the corresponding class-group subgroup. -/
theorem finrank_top_eq_card
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) :
    Module.finrank L H = Nat.card (artinImage K H e L) := by
  have hfact := HilbertClassFieldIntermediate.intermediate_degree_factorization K H e L
  have hidx := finrank_eq_index K H e L
  have hcard : (artinImage K H e L).index * Nat.card (artinImage K H e L)
      = Nat.card (ClassGroup (RingOfIntegers K)) := Subgroup.index_mul_card _
  have hcl : Nat.card (ClassGroup (RingOfIntegers K)) = classNumber K := by
    rw [Nat.card_eq_fintype_card]; rfl
  refine Nat.eq_of_mul_eq_mul_left (Module.finrank_pos (R := K) (M := L)) ?_
  rw [hfact, hidx, hcard, hcl]

/-- **Character descent criterion.**  An ideal-class character `χ` induces a character of
`Gal(L/K)` (i.e. the transported Galois character factors through restriction to `L`) precisely
when `χ` is trivial on the Artin image of the fixing subgroup of `L`. -/
theorem character_descent
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) (χ : ClassGroup (RingOfIntegers K) →* ℂˣ) :
    (∃ ρ : (L ≃ₐ[K] L) →* ℂˣ,
        ∀ σ : H ≃ₐ[K] H, χ (e σ) = ρ (restrictHom K H e L σ)) ↔
      ∀ s ∈ artinImage K H e L, χ s = 1 := by
  constructor
  · rintro ⟨ρ, hρ⟩ s ⟨σ, hσ, rfl⟩
    have hker : restrictHom K H e L σ = 1 := by
      have : σ ∈ (restrictHom K H e L).ker := by rw [restrictHom_ker]; exact hσ
      simpa [MonoidHom.mem_ker] using this
    have : χ (e σ) = ρ (restrictHom K H e L σ) := hρ σ
    simpa [hker] using this
  · intro h
    refine ⟨(QuotientGroup.lift (artinImage K H e L) χ h).comp
      (galoisEquivQuotient K H e L).toMonoidHom, fun σ => ?_⟩
    simp [galoisEquivQuotient_restrictHom K H e L σ]

/-- **Prime class-number rigidity.**  If the class number of `K` is prime, then a Hilbert class
field datum has no proper intermediate fields. -/
theorem eq_bot_or_eq_top_of_classNumber_prime
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) (hp : (classNumber K).Prime) :
    L = ⊥ ∨ L = ⊤ := by
  have hdvd := HilbertClassFieldIntermediate.intermediate_finrank_dvd_classNumber K H e L
  have hfact := HilbertClassFieldIntermediate.intermediate_degree_factorization K H e L
  rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h1 | h2
  · exact Or.inl (IntermediateField.finrank_eq_one_iff.mp h1)
  · refine Or.inr (IntermediateField.finrank_eq_one_iff_eq_top.mp ?_)
    rw [h2] at hfact
    have hpos : 0 < classNumber K := hp.pos
    nlinarith [hfact, hpos]

/-!
## The class-group Galois correspondence

Artin reciprocity transports the Galois correspondence for `H/K` into an order-reversing
bijection between intermediate fields and subgroups of the ideal class group.  This is the
lattice form of explicit class field theory for the Hilbert class field datum.
-/

/-- **Class-group Galois correspondence.**  Intermediate fields of a Hilbert class field datum
correspond, order-reversingly, to subgroups of the ideal class group. -/
def intermediateFieldOrderIso
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K)) :
    IntermediateField K H ≃o (Subgroup (ClassGroup (RingOfIntegers K)))ᵒᵈ :=
  (IsGalois.intermediateFieldEquivSubgroup (F := K) (E := H)).trans
    (OrderIso.dual (MulEquiv.mapSubgroup e))

theorem ofDual_intermediateFieldOrderIso_apply
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L : IntermediateField K H) :
    OrderDual.ofDual (intermediateFieldOrderIso K H e L) = artinImage K H e L := rfl

/-- The correspondence is order reversing: a larger intermediate field has a smaller Artin
image. -/
theorem artinImage_le_artinImage_iff
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L M : IntermediateField K H) :
    artinImage K H e M ≤ artinImage K H e L ↔ L ≤ M :=
  (intermediateFieldOrderIso K H e).le_iff_le

/-- Distinct intermediate fields have distinct Artin images. -/
theorem artinImage_injective
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K)) :
    Function.Injective (artinImage K H e) := fun _ _ h =>
  (intermediateFieldOrderIso K H e).injective (congrArg OrderDual.toDual h)

/-- The class field attached to a subgroup of the ideal class group: the fixed field of its
preimage under Artin reciprocity. -/
def classField
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) : IntermediateField K H :=
  (intermediateFieldOrderIso K H e).symm (OrderDual.toDual S)

/-- **Existence theorem (conditional form).**  Every subgroup of the ideal class group is the
Artin image of its class field. -/
theorem artinImage_classField
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) :
    artinImage K H e (classField K H e S) = S := by
  rw [← ofDual_intermediateFieldOrderIso_apply K H e]
  simp [classField]

/-- **Uniqueness theorem (conditional form).**  Each subgroup of the ideal class group is the
Artin image of exactly one intermediate field. -/
theorem existsUnique_intermediateField
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) :
    ∃! L : IntermediateField K H, artinImage K H e L = S :=
  ⟨classField K H e S, artinImage_classField K H e S, fun _ hL =>
    artinImage_injective K H e (hL.trans (artinImage_classField K H e S).symm)⟩

/-- **Degree of a class field.**  The class field of a subgroup `S` of the ideal class group has
degree over `K` equal to the index of `S`. -/
theorem finrank_classField
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) :
    Module.finrank K (classField K H e S) = S.index := by
  rw [finrank_eq_index K H e, artinImage_classField K H e S]

/-- The class field of a subgroup `S` has Galois group over `K` isomorphic to the quotient
`Cl(𝒪_K) ⧸ S`. -/
def classFieldGaloisEquiv
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) :
    (classField K H e S ≃ₐ[K] classField K H e S) ≃*
      ClassGroup (RingOfIntegers K) ⧸ S :=
  (galoisEquivQuotient K H e (classField K H e S)).trans
    (QuotientGroup.quotientMulEquivOfEq (artinImage_classField K H e S))

/-- **Counting intermediate fields.**  There are exactly as many intermediate fields of a Hilbert
class field datum as there are subgroups of the ideal class group. -/
theorem card_intermediateField_eq_card_subgroup
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K)) :
    Nat.card (IntermediateField K H)
      = Nat.card (Subgroup (ClassGroup (RingOfIntegers K))) :=
  Nat.card_congr (intermediateFieldOrderIso K H e).toEquiv

/-- **Relative degree as a relative index.**  For intermediate fields `L ≤ M` of a Hilbert class
field datum, the degree of `M` over `L` is the index of the Artin image of `M` inside the Artin
image of `L`. -/
theorem relIndex_eq_finrank
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (L M : IntermediateField K H) (hLM : L ≤ M) :
    (artinImage K H e M).relIndex (artinImage K H e L)
      = Module.finrank L (IntermediateField.extendScalars hLM) := by
  have hle : artinImage K H e M ≤ artinImage K H e L :=
    (artinImage_le_artinImage_iff K H e L M).2 hLM
  have hrel := Subgroup.relIndex_mul_index hle
  rw [← finrank_eq_index K H e L, ← finrank_eq_index K H e M] at hrel
  have htower : Module.finrank K L * Module.finrank L (IntermediateField.extendScalars hLM)
      = Module.finrank K M :=
    Module.finrank_mul_finrank K L (IntermediateField.extendScalars hLM)
  refine Nat.eq_of_mul_eq_mul_right (Module.finrank_pos (R := K) (M := L)) ?_
  rw [hrel, ← htower, Nat.mul_comm]

/-!
## GL(1) correspondence for class fields

Combining the descent isomorphism with the catalog's unramified GL(1) correspondence, the
characters of the class-group quotient `Cl(𝒪_K) ⧸ S` are exactly the one-dimensional complex
representations of the Galois group of the class field of `S`.
-/

/-- **GL(1) correspondence for the class field of `S`.**  Characters of `Cl(𝒪_K) ⧸ S` correspond
to one-dimensional complex representations of `Gal(L_S/K)`. -/
def classFieldGL1Correspondence
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) :
    ((ClassGroup (RingOfIntegers K) ⧸ S) →* ℂˣ) ≃*
      ((classField K H e S ≃ₐ[K] classField K H e S) →* ℂˣ) :=
  MulEquiv.monoidHomCongrLeft (classFieldGaloisEquiv K H e S).symm

/-- The GL(1) correspondence for a class field is computed by the Artin map: the Galois
representation attached to `χ` sends the restriction of `σ` to the value of `χ` on the class of
`e σ`. -/
theorem classFieldGL1Correspondence_apply
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (S : Subgroup (ClassGroup (RingOfIntegers K)))
    (chi : (ClassGroup (RingOfIntegers K) ⧸ S) →* ℂˣ) (sigma : H ≃ₐ[K] H) :
    classFieldGL1Correspondence K H e S chi
        (restrictHom K H e (classField K H e S) sigma)
      = chi (QuotientGroup.mk (e sigma)) := by
  simp [classFieldGL1Correspondence, classFieldGaloisEquiv,
    galoisEquivQuotient_restrictHom K H e (classField K H e S) sigma]

end

end HilbertClassFieldDescent