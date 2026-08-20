/-
# Hilbert class field data with elementary abelian class group

`Catalog/NumberTheory/HilbertClassFieldDescent.lean` classifies the intermediate fields of a
Hilbert class field datum `e : Gal(H/K) ≃* Cl(𝒪_K)` by the subgroups of the ideal class group,
order-reversingly, with `[L : K] = (artinImage e L).index`.
`Catalog/NumberTheory/SubspaceCounting.lean` counts the subspaces of a finite vector space by
Gaussian binomial coefficients.

This file combines the two and settles the elementary abelian counting problem: if
`Cl(𝒪_K) ≃ (ℤ/p)^r`, then the datum has exactly `∑_{k ≤ r} binom(r,k)_p` intermediate fields, of
which exactly `binom(r,k)_p` have degree `p^k` over `K`.

* `classGroupSubmoduleOrderIso` : `Subgroup Cl(𝒪_K) ≃o Submodule (ZMod p) ((ZMod p)^r)`;
* `card_subgroup_eq_pow`, `index_eq_pow` : orders and indices are the expected powers of `p`;
* `card_intermediateField_eq_sum_gaussBinom` : the total count;
* `finrank_eq_pow` : every intermediate field has degree `p^k` for some `k ≤ r`;
* `card_intermediateField_finrank_eq_gaussBinom` : the count in each degree;
* `card_intermediateField_kleinFour` (`p = 2`, `r = 2`: five intermediate fields) and
  `card_intermediateField_elementary_two_three` (`p = 2`, `r = 3`: sixteen intermediate fields,
  with degree counts `1, 7, 7, 1`).
-/

import Mathlib
import Catalog.NumberTheory.HilbertClassFieldDescent
import Catalog.NumberTheory.SubspaceCounting

open NumberField Module SubspaceCounting

namespace ElementaryAbelianClassField

noncomputable section

variable (p r : ℕ) [Fact p.Prime]

/-- Subgroups of an elementary abelian group `(ℤ/p)^r`, written multiplicatively, are the same
thing as `ZMod p`-subspaces of `(ZMod p)^r`. -/
def subgroupSubmoduleOrderIso :
    Subgroup (Multiplicative (Fin r → ZMod p)) ≃o Submodule (ZMod p) (Fin r → ZMod p) :=
  (AddSubgroup.toSubgroup (A := Fin r → ZMod p)).symm.trans (AddSubgroup.toZModSubmodule p)

variable (K : Type*) [Field K] [NumberField K]

/-- Transport of the subgroup lattice of the class group to the subspace lattice of `(ZMod p)^r`
along an isomorphism `Cl(𝒪_K) ≃* (ℤ/p)^r`. -/
def classGroupSubmoduleOrderIso
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p)) :
    Subgroup (ClassGroup (RingOfIntegers K)) ≃o Submodule (ZMod p) (Fin r → ZMod p) :=
  (MulEquiv.mapSubgroup E).trans (subgroupSubmoduleOrderIso p r)

variable {p r K}

omit [NumberField K] in
/-- The dimension of the subspace attached to a subgroup of the class group is at most `r`. -/
theorem finrank_le_rank
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) :
    finrank (ZMod p) (classGroupSubmoduleOrderIso p r K E S) ≤ r := by
  have h := Submodule.finrank_le (classGroupSubmoduleOrderIso p r K E S)
  simpa using h

omit [NumberField K] in
/-- A subgroup of the class group has order `p ^ k`, where `k` is the dimension of the
corresponding subspace. -/
theorem card_subgroup_eq_pow
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) :
    Nat.card S = p ^ finrank (ZMod p) (classGroupSubmoduleOrderIso p r K E S) := by
  have h₁ : Nat.card S
      = Nat.card (S.map (E : ClassGroup (RingOfIntegers K) →* Multiplicative (Fin r → ZMod p))) :=
    Nat.card_congr (S.equivMapOfInjective
      (E : ClassGroup (RingOfIntegers K) →* Multiplicative (Fin r → ZMod p)) E.injective).toEquiv
  have h₂ : Nat.card (classGroupSubmoduleOrderIso p r K E S)
      = Nat.card (S.map (E : ClassGroup (RingOfIntegers K) →* Multiplicative (Fin r → ZMod p))) :=
    rfl
  haveI : Fintype (classGroupSubmoduleOrderIso p r K E S) := Fintype.ofFinite _
  have h₃ : Nat.card (classGroupSubmoduleOrderIso p r K E S)
      = p ^ finrank (ZMod p) (classGroupSubmoduleOrderIso p r K E S) := by
    rw [Nat.card_eq_fintype_card, Module.card_eq_pow_finrank (K := ZMod p), ZMod.card]
  rw [h₁, ← h₂, h₃]

omit [NumberField K] in
/-- The class group of the datum has order `p ^ r`. -/
theorem card_classGroup_eq_pow
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p)) :
    Nat.card (ClassGroup (RingOfIntegers K)) = p ^ r := by
  rw [Nat.card_congr E.toEquiv]
  simp [Nat.card_eq_fintype_card, ZMod.card]

omit [NumberField K] in
/-- A subgroup of the class group has index `p ^ (r - k)`, where `k` is the dimension of the
corresponding subspace. -/
theorem index_eq_pow
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) :
    S.index = p ^ (r - finrank (ZMod p) (classGroupSubmoduleOrderIso p r K E S)) := by
  set k := finrank (ZMod p) (classGroupSubmoduleOrderIso p r K E S) with hk
  have hkr : k ≤ r := finrank_le_rank E S
  have hcard : Nat.card S * S.index = Nat.card (ClassGroup (RingOfIntegers K)) :=
    Subgroup.card_mul_index S
  rw [card_subgroup_eq_pow E S, card_classGroup_eq_pow E, ← hk] at hcard
  have hsplit : p ^ r = p ^ k * p ^ (r - k) := by
    rw [← pow_add]
    congr 1
    omega
  have hpos : 0 < p ^ k := Nat.pow_pos (Nat.Prime.pos (Fact.out))
  exact Nat.eq_of_mul_eq_mul_left hpos (by rw [hcard, hsplit])

variable (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]

/-- The bijection between intermediate fields of the datum and subspaces of `(ZMod p)^r`. -/
def intermediateFieldSubmoduleEquiv
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p)) :
    IntermediateField K H ≃ Submodule (ZMod p) (Fin r → ZMod p) :=
  ((HilbertClassFieldDescent.intermediateFieldOrderIso K H e).toEquiv.trans
    (OrderDual.toDual (α := Subgroup (ClassGroup (RingOfIntegers K)))).symm).trans
      (classGroupSubmoduleOrderIso p r K E).toEquiv

theorem intermediateFieldSubmoduleEquiv_apply
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    (L : IntermediateField K H) :
    intermediateFieldSubmoduleEquiv H e E L
      = classGroupSubmoduleOrderIso p r K E (HilbertClassFieldDescent.artinImage K H e L) := rfl

/-- **The total count.**  A Hilbert class field datum whose class group is elementary abelian of
rank `r` and exponent `p` has exactly `∑_{k ≤ r} binom(r,k)_p` intermediate fields. -/
theorem card_intermediateField_eq_sum_gaussBinom
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p)) :
    Nat.card (IntermediateField K H) = ∑ k ∈ Finset.range (r + 1), gaussBinom p r k := by
  rw [Nat.card_congr (intermediateFieldSubmoduleEquiv H e E), card_submodule_zmod]

/-- The degree over `K` of an intermediate field, in terms of the attached subspace. -/
theorem finrank_eq_pow_sub
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    (L : IntermediateField K H) :
    finrank K L = p ^ (r - finrank (ZMod p) (intermediateFieldSubmoduleEquiv H e E L)) := by
  rw [HilbertClassFieldDescent.finrank_eq_index K H e L,
    index_eq_pow E (HilbertClassFieldDescent.artinImage K H e L),
    intermediateFieldSubmoduleEquiv_apply]

/-- **The possible degrees.**  Every intermediate field of such a datum has degree `p ^ k` over
`K` for some `k ≤ r`. -/
theorem finrank_eq_pow
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    (L : IntermediateField K H) :
    ∃ k ≤ r, finrank K L = p ^ k := by
  refine ⟨r - finrank (ZMod p) (intermediateFieldSubmoduleEquiv H e E L), Nat.sub_le _ _,
    finrank_eq_pow_sub H e E L⟩

/-- The class field of a subgroup corresponding to a `k`-dimensional subspace has degree
`p ^ (r - k)`. -/
theorem finrank_classField_eq_pow
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    (S : Subgroup (ClassGroup (RingOfIntegers K))) :
    finrank K (HilbertClassFieldDescent.classField K H e S)
      = p ^ (r - finrank (ZMod p) (classGroupSubmoduleOrderIso p r K E S)) := by
  rw [HilbertClassFieldDescent.finrank_classField K H e S, index_eq_pow E S]

/-- **The count in each degree.**  Exactly `binom(r,k)_p` intermediate fields have degree `p ^ k`
over `K`. -/
theorem card_intermediateField_finrank_eq_gaussBinom
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    {k : ℕ} (hk : k ≤ r) :
    Nat.card {L : IntermediateField K H // finrank K L = p ^ k} = gaussBinom p r k := by
  have hp : 1 < p := (Fact.out : p.Prime).one_lt
  have hequiv : {L : IntermediateField K H // finrank K L = p ^ k} ≃
      {W : Submodule (ZMod p) (Fin r → ZMod p) // finrank (ZMod p) W = r - k} := by
    refine Equiv.subtypeEquiv (intermediateFieldSubmoduleEquiv H e E) fun L => ?_
    have hdim : finrank (ZMod p) (intermediateFieldSubmoduleEquiv H e E L) ≤ r := by
      rw [intermediateFieldSubmoduleEquiv_apply]
      exact finrank_le_rank E _
    rw [finrank_eq_pow_sub H e E L]
    constructor
    · intro h
      have := Nat.pow_right_injective hp h
      omega
    · intro h
      rw [h]
      congr 1
      omega
  rw [Nat.card_congr hequiv, card_submodule_finrank_zmod p r (Nat.sub_le r k),
    ← gaussBinom_symm p hk]

/-- **Existence in every admissible degree.**  For every `k ≤ r` the datum has an intermediate
field of degree `p ^ k` over `K`. -/
theorem exists_intermediateField_finrank
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    {k : ℕ} (hk : k ≤ r) :
    ∃ L : IntermediateField K H, finrank K L = p ^ k := by
  have hcard : Nat.card {L : IntermediateField K H // finrank K L = p ^ k} = gaussBinom p r k :=
    card_intermediateField_finrank_eq_gaussBinom H e E hk
  have hpos : 0 < Nat.card {L : IntermediateField K H // finrank K L = p ^ k} := by
    rw [hcard]; exact gaussBinom_pos p hk
  obtain ⟨L, hL⟩ := Nat.card_pos_iff.mp hpos |>.1
  exact ⟨L, hL⟩

/-- **The degrees occurring in the datum are exactly the powers `p ^ k` with `k ≤ r`.** -/
theorem exists_intermediateField_finrank_iff
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p))
    (m : ℕ) :
    (∃ L : IntermediateField K H, finrank K L = m) ↔ ∃ k ≤ r, m = p ^ k := by
  constructor
  · rintro ⟨L, rfl⟩
    obtain ⟨k, hk, hL⟩ := finrank_eq_pow H e E L
    exact ⟨k, hk, hL⟩
  · rintro ⟨k, hk, rfl⟩
    exact exists_intermediateField_finrank H e E hk

/-- **Consistency of the two counts.**  Summing the number of intermediate fields of each degree
`p ^ k`, `k ≤ r`, gives the total number of intermediate fields. -/
theorem sum_card_intermediateField_finrank
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin r → ZMod p)) :
    ∑ k ∈ Finset.range (r + 1), Nat.card {L : IntermediateField K H // finrank K L = p ^ k}
      = Nat.card (IntermediateField K H) := by
  rw [card_intermediateField_eq_sum_gaussBinom H e E]
  refine Finset.sum_congr rfl fun k hk => ?_
  exact card_intermediateField_finrank_eq_gaussBinom H e E (by
    simpa [Nat.lt_succ_iff] using Finset.mem_range.mp hk)

section Examples

/-- **Klein four class group.**  If `Cl(𝒪_K) ≃ (ℤ/2)²` then the datum has exactly five
intermediate fields; this recovers the count of the previous cycle. -/
theorem card_intermediateField_kleinFour
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin 2 → ZMod 2)) :
    Nat.card (IntermediateField K H) = 5 := by
  rw [card_intermediateField_eq_sum_gaussBinom H e E]
  decide

/-- The Klein four group in the product presentation `ZMod 2 × ZMod 2` is the rank two
elementary abelian group `(ZMod 2)^2`. -/
def kleinFourMulEquiv : Multiplicative (ZMod 2 × ZMod 2) ≃* Multiplicative (Fin 2 → ZMod 2) :=
  AddEquiv.toMultiplicative
    (({ piFinTwoEquiv (fun _ => ZMod 2) with map_add' := fun _ _ => rfl } :
      (Fin 2 → ZMod 2) ≃+ (ZMod 2 × ZMod 2)).symm)

/-- **Klein four class group, product presentation.**  Five intermediate fields. -/
theorem card_intermediateField_of_kleinFour
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (ZMod 2 × ZMod 2)) :
    Nat.card (IntermediateField K H) = 5 :=
  card_intermediateField_kleinFour H e (E.trans kleinFourMulEquiv)

/-- **Three quadratic intermediate fields** in the Klein four case. -/
theorem card_quadratic_intermediateField_of_kleinFour
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (ZMod 2 × ZMod 2)) :
    Nat.card {L : IntermediateField K H // finrank K L = 2} = 3 := by
  have h := card_intermediateField_finrank_eq_gaussBinom H e (E.trans kleinFourMulEquiv)
    (k := 1) (by norm_num)
  simpa [show gaussBinom 2 2 1 = 3 from by decide] using h

/-- **The possible degrees in the Klein four case** are `1`, `2` and `4`. -/
theorem finrank_eq_one_or_two_or_four
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (ZMod 2 × ZMod 2))
    (L : IntermediateField K H) :
    finrank K L = 1 ∨ finrank K L = 2 ∨ finrank K L = 4 := by
  obtain ⟨k, hk, hL⟩ := finrank_eq_pow H e (E.trans kleinFourMulEquiv) L
  interval_cases k <;> simp_all

/-- **Elementary abelian of rank three.**  If `Cl(𝒪_K) ≃ (ℤ/2)³` then the datum has exactly
sixteen intermediate fields — the falsifiable prediction of the previous cycle. -/
theorem card_intermediateField_elementary_two_three
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin 3 → ZMod 2)) :
    Nat.card (IntermediateField K H) = 16 := by
  rw [card_intermediateField_eq_sum_gaussBinom H e E]
  decide

/-- The degree distribution in the rank three case: `1, 7, 7, 1` fields of degree `1, 2, 4, 8`. -/
theorem card_intermediateField_finrank_two_three
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (E : ClassGroup (RingOfIntegers K) ≃* Multiplicative (Fin 3 → ZMod 2)) :
    Nat.card {L : IntermediateField K H // finrank K L = 1} = 1 ∧
      Nat.card {L : IntermediateField K H // finrank K L = 2} = 7 ∧
      Nat.card {L : IntermediateField K H // finrank K L = 4} = 7 ∧
      Nat.card {L : IntermediateField K H // finrank K L = 8} = 1 := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · have h := card_intermediateField_finrank_eq_gaussBinom H e E (k := 0) (by norm_num)
    simpa only [pow_zero, gaussBinom_zero] using h
  · have h := card_intermediateField_finrank_eq_gaussBinom H e E (k := 1) (by norm_num)
    simpa [show gaussBinom 2 3 1 = 7 from by decide] using h
  · have h := card_intermediateField_finrank_eq_gaussBinom H e E (k := 2) (by norm_num)
    simpa [show gaussBinom 2 3 2 = 7 from by decide] using h
  · have h := card_intermediateField_finrank_eq_gaussBinom H e E (k := 3) (by norm_num)
    simpa [show gaussBinom 2 3 3 = 1 from by decide] using h

end Examples

end

end ElementaryAbelianClassField