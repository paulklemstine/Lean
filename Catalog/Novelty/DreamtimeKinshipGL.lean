import Mathlib

/-!
# Dreamtime Algebra, Deepened: Kinship Systems as `(ℤ/2)ⁿ` and their Symmetry Group `GL(n, 𝔽₂)`

This file *deepens* the group-theoretic formalization of Australian Aboriginal
kinship systems.  The classical results treat the **four-section** (Kariera)
system as the Klein four-group `ℤ/2 × ℤ/2` and the **eight-subsection** (Aranda /
Warlpiri) system as `(ℤ/2)³`.  Here we work uniformly with the general
`n`-generation kinship space

```
  Kin n  :=  Fin n → ℤ/2
```

the elementary abelian `2`-group of rank `n`, and prove the structural theorems
at this general level.  The genuinely new depth over the base cycle is the
**symmetry theorem**:

> The group of kinship-system automorphisms of the `n`-generation system is the
> general linear group `GL(n, 𝔽₂)`, whose order is `∏ᵢ (2ⁿ − 2ⁱ)`.

Because the scalar field `𝔽₂ = ℤ/2` is prime, *every* additive automorphism of
`Kin n` is automatically `𝔽₂`-linear, so the abstract relabelling symmetries of a
kinship classification are exactly the invertible matrices over `𝔽₂`.  For the
four-section system this gives a symmetry group of order `6` — the three nonzero
sections (equivalently, the three possible marriage rules) are permuted freely,
recovering `GL(2, 𝔽₂) ≅ S₃`.

## Main results

* `card_kin`, `kin_add_self`, `kin_two_nsmul` — `Kin n` is the elementary abelian
  `2`-group of order `2ⁿ`.
* `kinHom_injective`, `kinGroupIso`, `kinGroup_card`, `kin_simplyTransitive` — the
  Cayley (regular) representation embeds `Kin n` into the symmetric group on its
  own sections as a simply transitive permutation group of order `2ⁿ`.
* `kin_not_addCyclic` — for `n ≥ 2` the system is genuinely `(ℤ/2)ⁿ`, never
  cyclic `ℤ/2ⁿ`.
* `card_kinshipSpectrum` — there are exactly `2ⁿ − 1` admissible marriage
  generators (nonzero involutions).
* `marriageMoiety_index`, `moietyQuotIso`, `marriage_preserves_moiety` — the
  marriage rule is a coset restriction: the moiety is an index-`2` subgroup and
  marriage never leaves its coset.
* `subsectionQuotIso`, `kerIso`, `forget_ker_card` — the `(n+1)`-system is a
  `ℤ/2`-extension (double cover) of the `n`-system via the forgetful map.
* `addAutMulEquivGL`, `card_addAut` — **the symmetry theorem**: the automorphism
  group of the kinship system is `GL(n, 𝔽₂)`, of order `∏ᵢ (2ⁿ − 2ⁱ)`.
* `card_addAut_two`, `karieraSymmetry_card` — the four-section symmetry group has
  order `6 = 3!`, i.e. `GL(2, 𝔽₂) ≅ S₃`.
* `mother`, `spouse`, `father`, `father_eq_spouse_mother` — the concrete Kariera
  descent/marriage permutations and the descent-consistency relation.

Everything is proved from first principles over `Fin n → ℤ/2`.
-/

open Equiv Matrix

namespace DreamtimeKinshipGL

/-! ## The general `n`-generation kinship space -/

/-- The `n`-generation kinship space: the elementary abelian `2`-group of rank
`n`, modelling a section/subsection system with `n` binary kinship coordinates.
`Kin 2` is the four-section (Kariera) system and `Kin 3` the eight-subsection
(Aranda) system. -/
abbrev Kin (n : ℕ) := Fin n → ZMod 2

/-- The kinship space has `2ⁿ` sections. -/
theorem card_kin (n : ℕ) : Fintype.card (Kin n) = 2 ^ n := by
  simp [Kin]

/-- Every section is its own inverse: the kinship group has exponent `2`
(applying any kinship step twice returns you to the start). -/
theorem kin_add_self (n : ℕ) (g : Kin n) : g + g = 0 := by
  funext i; exact CharTwo.add_self_eq_zero _

/-- `Kin n` is `2`-torsion: `2 • g = 0` for every section `g`. -/
theorem kin_two_nsmul (n : ℕ) (g : Kin n) : (2 : ℕ) • g = 0 := by
  rw [two_nsmul]; exact kin_add_self n g

/-! ## Kinship steps as permutations (the Cayley representation) -/

/-- Translation of the section-set by a fixed section `v`; the permutation
realising a kinship step.  Since the group has exponent `2` it is an involution. -/
def transl (n : ℕ) (v : Kin n) : Perm (Kin n) :=
  ⟨fun x => x + v, fun x => x + v,
    fun x => by simp [add_assoc, kin_add_self],
    fun x => by simp [add_assoc, kin_add_self]⟩

@[simp] theorem transl_apply (n : ℕ) (v x : Kin n) : transl n v x = x + v := rfl

theorem transl_zero (n : ℕ) : transl n 0 = 1 := by ext x; simp

/-- Kinship steps compose additively. -/
theorem transl_add (n : ℕ) (v w : Kin n) :
    transl n (v + w) = transl n v * transl n w := by
  ext x; simp only [transl_apply, Perm.mul_apply, transl_apply, Pi.add_apply]; abel

/-- Every kinship translation is an involution. -/
theorem transl_involutive (n : ℕ) (v : Kin n) : transl n v * transl n v = 1 := by
  rw [← transl_add, kin_add_self, transl_zero]

/-- The kinship transformation homomorphism: the Cayley (regular) representation
of the section group inside the symmetric group on the sections. -/
def kinHom (n : ℕ) : Multiplicative (Kin n) →* Perm (Kin n) where
  toFun v := transl n (Multiplicative.toAdd v)
  map_one' := transl_zero n
  map_mul' _ _ := transl_add n _ _

theorem kinHom_injective (n : ℕ) : Function.Injective (kinHom n) := by
  intro a b h
  have := congrArg (fun p : Perm (Kin n) => p 0) h
  simpa [kinHom, transl_apply] using this

/-- **The kinship transformation group is `(ℤ/2)ⁿ`.**  The subgroup of the
symmetric group on the `2ⁿ` sections generated by the kinship steps is isomorphic
to `Kin n`. -/
noncomputable def kinGroupIso (n : ℕ) :
    Multiplicative (Kin n) ≃* (kinHom n).range :=
  MonoidHom.ofInjective (kinHom_injective n)

/-- The kinship transformation group has `2ⁿ` elements. -/
theorem kinGroup_card (n : ℕ) : Nat.card (kinHom n).range = 2 ^ n := by
  rw [← Nat.card_congr (kinGroupIso n).toEquiv]
  simp [Nat.card_eq_fintype_card, Kin]

/-- The section group acts **simply transitively** on itself: any two sections
are joined by a unique kinship step. -/
theorem kin_simplyTransitive (n : ℕ) (x y : Kin n) : ∃! v : Kin n, x + v = y := by
  refine ⟨y - x, by abel, ?_⟩
  intro w hw; rw [← hw]; abel

/-- For `n ≥ 2` the kinship group is **not** cyclic: it is genuinely `(ℤ/2)ⁿ`,
never `ℤ/2ⁿ`.  Every nonzero section has order `2`. -/
theorem kin_not_addCyclic (n : ℕ) (hn : 2 ≤ n) : ¬ IsAddCyclic (Kin n) := by
  intro _
  obtain ⟨g, hg⟩ := IsAddCyclic.exists_ofOrder_eq_natCard (α := Kin n)
  have hcard : Nat.card (Kin n) = 2 ^ n := by
    simp [Kin, Nat.card_eq_fintype_card]
  rw [hcard] at hg
  have hdvd : addOrderOf g ∣ 2 :=
    addOrderOf_dvd_of_nsmul_eq_zero (kin_two_nsmul n g)
  rw [hg] at hdvd
  have h1 : (2 : ℕ) ^ n ≤ 2 := Nat.le_of_dvd (by norm_num) hdvd
  have h2 : (2 : ℕ) ^ 2 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
  omega

/-! ## The kinship spectrum: admissible marriage generators -/

/-- The **kinship spectrum**: the set of nonzero sections.  Each is an admissible
marriage generator (a nonzero involution), and so defines a candidate marriage
rule on the same set of sections. -/
def kinshipSpectrum (n : ℕ) : Finset (Kin n) :=
  Finset.univ.filter (fun g => g ≠ 0)

/-- A section lies in the spectrum iff it is a nonzero involution. -/
theorem mem_kinshipSpectrum (n : ℕ) (g : Kin n) :
    g ∈ kinshipSpectrum n ↔ (g + g = 0 ∧ g ≠ 0) :=
  ⟨fun hg => ⟨kin_add_self n g, by simpa [kinshipSpectrum] using hg⟩,
   fun hg => by simpa [kinshipSpectrum] using hg.2⟩

/-- **There are exactly `2ⁿ − 1` admissible marriage rules.** -/
theorem card_kinshipSpectrum (n : ℕ) : (kinshipSpectrum n).card = 2 ^ n - 1 := by
  rw [kinshipSpectrum, Finset.filter_ne']
  rw [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ]
  simp [Kin]

/-! ## Marriage as a coset restriction -/

/-- The **moiety functional**: reads off the last kinship coordinate.  Its kernel
is the moiety subgroup and its two fibres are the two moieties. -/
def lastCoord (n : ℕ) : Kin (n + 1) →+ ZMod 2 where
  toFun f := f (Fin.last n)
  map_zero' := rfl
  map_add' _ _ := rfl

theorem lastCoord_surjective (n : ℕ) : Function.Surjective (lastCoord n) :=
  fun c => ⟨Function.const _ c, rfl⟩

/-- The **moiety** subgroup: the kernel of the moiety functional.  Its two cosets
are the two moieties and marriage is confined to a single coset. -/
def marriageMoiety (n : ℕ) : AddSubgroup (Kin (n + 1)) := (lastCoord n).ker

/-- There are exactly **two** moieties (cosets of the moiety subgroup): the
moiety is an index-`2` subgroup. -/
noncomputable def moietyQuotIso (n : ℕ) :
    (Kin (n + 1) ⧸ marriageMoiety n) ≃+ ZMod 2 :=
  QuotientAddGroup.quotientKerEquivOfSurjective _ (lastCoord_surjective n)

theorem marriageMoiety_index (n : ℕ) :
    Nat.card (Kin (n + 1) ⧸ marriageMoiety n) = 2 := by
  rw [Nat.card_congr (moietyQuotIso n).toEquiv]
  simp [Nat.card_eq_fintype_card]

/-- **Marriage as a coset restriction.**  If the marriage generator lies in the
moiety subgroup, then marriage (translation by that generator) never leaves the
moiety coset: `y - x` stays in the moiety subgroup. -/
theorem marriage_preserves_moiety (n : ℕ) (mgen : Kin (n + 1))
    (hm : mgen ∈ marriageMoiety n) (x y : Kin (n + 1)) (h : y = x + mgen) :
    y - x ∈ marriageMoiety n := by
  rw [h]; simpa using hm

/-! ## The `(n+1)`-system as a `ℤ/2`-extension (double cover) of the `n`-system -/

/-- The **forgetful map** collapsing an `(n+1)`-coordinate subsection to its first
`n` coordinates (a subsection refines a section). -/
def forget (n : ℕ) : Kin (n + 1) →+ Kin n where
  toFun f := Fin.init f
  map_zero' := rfl
  map_add' _ _ := rfl

theorem forget_surjective (n : ℕ) : Function.Surjective (forget n) :=
  fun g => ⟨Fin.snoc g 0, by ext i; simp [forget, Fin.init_snoc]⟩

/-- **The `(n+1)`-system is an extension of the `n`-system.**  The quotient of
`Kin (n+1)` by the forgetful kernel recovers exactly `Kin n`. -/
noncomputable def subsectionQuotIso (n : ℕ) :
    (Kin (n + 1) ⧸ (forget n).ker) ≃+ Kin n :=
  QuotientAddGroup.quotientKerEquivOfSurjective _ (forget_surjective n)

/-- The kernel of the forgetful map is `ℤ/2`: refining an `n`-generation system
to an `(n+1)`-generation one is a **double cover** (a `ℤ/2`-extension). -/
def kerIso (n : ℕ) : (forget n).ker ≃+ ZMod 2 where
  toFun p := p.1 (Fin.last n)
  invFun c := ⟨Fin.snoc 0 c, by
    rw [AddMonoidHom.mem_ker]; ext i; simp [forget, Fin.init_snoc]⟩
  left_inv := by
    rintro ⟨f, hf⟩
    rw [AddMonoidHom.mem_ker] at hf
    apply Subtype.ext
    ext i
    induction i using Fin.lastCases with
    | last => simp
    | cast j =>
      have hj : f j.castSucc = 0 := congrFun hf j
      simp [Fin.snoc_castSucc, hj]
  right_inv c := by simp
  map_add' _ _ := rfl

theorem forget_ker_card (n : ℕ) : Nat.card (forget n).ker = 2 := by
  rw [Nat.card_congr (kerIso n).toEquiv]
  simp [Nat.card_eq_fintype_card]

/-! ## The symmetry theorem: kinship automorphisms are `GL(n, 𝔽₂)`

The relabelling symmetries of a kinship system are its additive automorphisms.
Because the scalar field `ℤ/2` is prime, *every* additive automorphism is
automatically `𝔽₂`-linear, so the symmetry group is the general linear group
`GL(n, 𝔽₂)`.  This is the deep structural payoff of the group-theoretic reading. -/

/-- **Every additive automorphism of `Kin n` is `𝔽₂`-linear**, giving a group
isomorphism between the additive automorphism group and the linear automorphism
group.  (Scalars in `ℤ/2` are `0` and `1`, so `𝔽₂`-linearity is forced by
additivity.) -/
def addAutToLin (n : ℕ) : AddAut (Kin n) ≃* ((Kin n) ≃ₗ[ZMod 2] (Kin n)) where
  toFun e := { e with map_smul' := by intro c x; fin_cases c <;> simp }
  invFun l := l.toAddEquiv
  left_inv _ := rfl
  right_inv _ := rfl
  map_mul' _ _ := rfl

/-- **The symmetry group of the `n`-generation kinship system is `GL(n, 𝔽₂)`.** -/
noncomputable def addAutMulEquivGL (n : ℕ) : AddAut (Kin n) ≃* GL (Fin n) (ZMod 2) :=
  (addAutToLin n).trans
    (((Matrix.GeneralLinearGroup.toLin (n := Fin n) (R := ZMod 2)).trans
      (LinearMap.GeneralLinearGroup.generalLinearEquiv (ZMod 2) (Kin n))).symm)

/-- **The number of kinship-system symmetries is `∏ᵢ (2ⁿ − 2ⁱ)`** — the order of
`GL(n, 𝔽₂)`. -/
theorem card_addAut (n : ℕ) :
    Nat.card (AddAut (Kin n)) = ∏ i : Fin n, (2 ^ n - 2 ^ (i : ℕ)) := by
  rw [Nat.card_congr (addAutMulEquivGL n).toEquiv, Matrix.card_GL_field]
  simp

/-- The **four-section** (Kariera) system has a symmetry group of order `6`.
Since `6 = 3!`, this is `GL(2, 𝔽₂) ≅ S₃`: the three nonzero sections
(equivalently the three admissible marriage rules) are permuted freely. -/
theorem card_addAut_two : Nat.card (AddAut (Kin 2)) = 6 := by
  rw [card_addAut]; decide

/-- The four-section symmetry group has the order of the symmetric group `S₃`
on the three nonzero sections. -/
theorem karieraSymmetry_card :
    Nat.card (AddAut (Kin 2)) = Nat.card (Perm (Fin 3)) := by
  rw [card_addAut_two, Nat.card_eq_fintype_card, Fintype.card_perm]
  decide

/-! ## Concrete Kariera (four-section) kinship relations -/

/-- The **mother→child** section map of the Kariera system. -/
def mother : Perm (Kin 2) := transl 2 ![0, 1]

/-- The **marriage** (spouse) section map of the Kariera system. -/
def spouse : Perm (Kin 2) := transl 2 ![1, 0]

/-- The **father→child** section map of the Kariera system. -/
def father : Perm (Kin 2) := transl 2 ![1, 1]

theorem mother_involution : mother * mother = 1 := transl_involutive _ _
theorem spouse_involution : spouse * spouse = 1 := transl_involutive _ _
theorem father_involution : father * father = 1 := transl_involutive _ _

/-- The Kariera relations commute (the system is abelian). -/
theorem mother_spouse_comm : mother * spouse = spouse * mother := by
  rw [mother, spouse, ← transl_add, ← transl_add, add_comm]

/-- **Descent consistency**: the father-map is the composite of the marriage-map
and the mother-map (a father's child-section equals the mother's child-section,
since parents are spouses). -/
theorem father_eq_spouse_mother : father = spouse * mother := by
  rw [father, spouse, mother, ← transl_add]
  congr 1
  decide

end DreamtimeKinshipGL