/-
# The transfer map of a Hilbert class field datum

Furtwängler's principal ideal theorem states that every ideal of `𝒪_K` becomes principal in the
Hilbert class field of `K`; group-theoretically it is the statement that the transfer
(Verlagerung) `Gal(H₁/K)^ab → Gal(H₁/H)` is trivial.  This file formalizes the abelian core of
that mechanism for the catalog's Hilbert class field interface:

* `coe_transfer_id` : for a commutative group `G` and a finite-index subgroup `S`, the transfer
  `G → S` attached to the identity of `S` is the `S.index`-th power map;
* `transfer_id_eq_one_iff` : this transfer is trivial exactly when `S.index` annihilates `G`;
* `transfer_bot_eq_one` : the transfer of a finite commutative group into its trivial subgroup is
  trivial (the abelian case of Furtwängler's theorem);
* `coe_transfer_artinImage` : along a Hilbert class field datum `e : Gal(H/K) ≃* Cl(𝒪_K)`, the
  transfer of `Cl(𝒪_K)` into the Artin image of an intermediate field `L` is the `[L : K]`-th
  power map;
* `transfer_artinImage_top_eq_one` : the transfer of `Cl(𝒪_K)` into the Artin image of `H`
  itself, i.e. into `Gal(H/H) = 1`, is trivial: every ideal class capitulates at the top of the
  datum.
-/

import Catalog.NumberTheory.HilbertClassFieldDescent

open NumberField

namespace ClassFieldTransfer

/-- **The transfer of a commutative group is the index power map.**  For a finite-index subgroup
`S` of a commutative group `G`, the transfer homomorphism attached to the identity `S → S` sends
`g` to `g ^ S.index`. -/
theorem coe_transfer_id {G : Type*} [CommGroup G] (S : Subgroup G) [S.FiniteIndex] (g : G) :
    ((MonoidHom.transfer (MonoidHom.id S) g : S) : G) = g ^ S.index := by
  rw [MonoidHom.transfer_eq_pow (MonoidHom.id S) g
    (fun k g₀ _ => by rw [mul_comm, ← mul_assoc, mul_inv_cancel, one_mul])]
  rfl

/-- The transfer into a finite-index subgroup of a commutative group is trivial precisely when
the index annihilates the group. -/
theorem transfer_id_eq_one_iff {G : Type*} [CommGroup G] (S : Subgroup G) [S.FiniteIndex] :
    MonoidHom.transfer (MonoidHom.id S) = 1 ↔ ∀ g : G, g ^ S.index = 1 := by
  constructor
  · intro h g
    have heq : MonoidHom.transfer (MonoidHom.id S) g = (1 : G →* S) g := by rw [h]
    have := congrArg Subtype.val heq
    rw [coe_transfer_id] at this
    simpa using this
  · intro h
    ext g
    simp [coe_transfer_id, h]

/-- **Abelian principal ideal theorem (group-theoretic core).**  The transfer of a finite
commutative group into its trivial subgroup is trivial. -/
theorem transfer_bot_eq_one {G : Type*} [CommGroup G] [Finite G] :
    MonoidHom.transfer (MonoidHom.id (⊥ : Subgroup G)) = 1 := by
  ext g
  simp [coe_transfer_id, Subgroup.index_bot]

section ClassField

variable (K : Type*) [Field K] [NumberField K]
  (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
  (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))

/-- **Transfer along a Hilbert class field datum.**  The transfer of the ideal class group into
the Artin image of an intermediate field `L` is raising to the power `[L : K]`. -/
theorem coe_transfer_artinImage (L : IntermediateField K H)
    (c : ClassGroup (RingOfIntegers K)) :
    ((MonoidHom.transfer (MonoidHom.id (HilbertClassFieldDescent.artinImage K H e L)) c :
        HilbertClassFieldDescent.artinImage K H e L) : ClassGroup (RingOfIntegers K))
      = c ^ Module.finrank K L := by
  rw [HilbertClassFieldDescent.finrank_eq_index K H e L]
  exact coe_transfer_id _ c

/-- The transfer into the Artin image of `L` is trivial exactly when `[L : K]` annihilates the
ideal class group. -/
theorem transfer_artinImage_eq_one_iff (L : IntermediateField K H) :
    MonoidHom.transfer (MonoidHom.id (HilbertClassFieldDescent.artinImage K H e L)) = 1 ↔
      ∀ c : ClassGroup (RingOfIntegers K), c ^ Module.finrank K L = 1 := by
  rw [transfer_id_eq_one_iff]
  rw [HilbertClassFieldDescent.finrank_eq_index K H e L]

/-- The Artin image of the top intermediate field is the trivial subgroup: `Gal(H/H) = 1`. -/
theorem artinImage_top : HilbertClassFieldDescent.artinImage K H e ⊤ = ⊥ := by
  rw [HilbertClassFieldDescent.artinImage]
  have h : (⊤ : IntermediateField K H).fixingSubgroup = ⊥ := by
    apply Subgroup.ext
    intro sigma
    simp only [Subgroup.mem_bot]
    constructor
    · intro hsigma
      exact AlgEquiv.ext fun x => hsigma ⟨x, trivial⟩
    · rintro rfl
      simp
  rw [h, Subgroup.map_bot]

/-- **Capitulation at the top of the datum.**  The transfer of `Cl(𝒪_K)` into the Artin image of
`H` is trivial; equivalently `c ^ h_K = 1` for every ideal class, which is the abelian shadow of
Furtwängler's principal ideal theorem. -/
theorem transfer_artinImage_top_eq_one :
    MonoidHom.transfer (MonoidHom.id (HilbertClassFieldDescent.artinImage K H e ⊤)) = 1 := by
  rw [HilbertClassFieldDescent.artinImage]
  -- Goal: (MonoidHom.id ↥(Subgroup.map ↑e ⊤.fixingSubgroup)).transfer = 1
  have h : (⊤ : IntermediateField K H).fixingSubgroup = ⊥ := by
    apply Subgroup.ext
    intro σ
    simp only [Subgroup.mem_bot]
    constructor
    · intro hσ
      apply AlgEquiv.ext
      intro x
      exact hσ ⟨x, trivial⟩
    · intro rfl
      simp
  rw [h, Subgroup.map_bot]
  exact transfer_bot_eq_one

omit [FiniteDimensional K H] [IsGalois K H] in
/-- **Degree annihilates the class group.**  For every intermediate field `L` of a Hilbert class
field datum whose degree over `K` is the full class number, `[L : K]` annihilates `Cl(𝒪_K)`. -/
theorem pow_finrank_eq_one_of_finrank_eq_classNumber (L : IntermediateField K H)
    (hL : Module.finrank K L = classNumber K) (c : ClassGroup (RingOfIntegers K)) :
    c ^ Module.finrank K L = 1 := by
  rw [hL, classNumber]
  exact pow_card_eq_one

end ClassField

end ClassFieldTransfer