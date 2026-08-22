/-
# The abelian ceiling: a residue sees exactly `log₂ |G^ab|` bits

`Catalog.NumberTheory.CharacterOneBit` proves that a quadratic character extracts exactly one bit
of splitting-type entropy.  One bit is `log₂ 2`, and `2 = |G^ab|` for `G = S_n`; this file shows
that the coincidence is the theorem.  For a finite group `G` and *any* surjective character
`χ : G →* C` onto a finite abelian group:

* `uEnt_eq_logb_card_of_balanced` — a read-out with all fibres of equal size `|s| / m` carries
  exactly `log₂ m` bits;
* `card_fiber_of_surjective` — every fibre of `χ` has size `|G| / |C|`;
* `mutInfo_conjClasses_character_eq_logb` — **the Frobenius class and the character share exactly
  `log₂ |C|` bits**, with no hypothesis beyond surjectivity: a homomorphism into an abelian group
  is a class function, so the conjugacy class always refines it;
* `mutInfo_le_logb_card_of_factors` — **the ceiling**: *any* read-out that is a function of `χ`
  (this is what "visible in the residue `p mod |disc|`" means, by class field theory) reveals at
  most `log₂ |C|` bits about the Frobenius class, and the ceiling is attained by `χ` itself;
* `conjClasses_character_deficit` — the exact deficit `H(class | χ) = H(class) - log₂ |C|`.

Two corollaries frame the dichotomy of the `S₃` story:

* `mutInfo_conjClasses_eq_one_of_card_two` — an index-two kernel gives exactly one bit;
* `mutInfo_self_abelian` — when `G` itself is abelian the residue sees *everything*,
  `I = log₂ |G|`; the cyclic cubic field hides nothing, the `S₃` cubic hides `H(T) - 1` bits.
-/
import Catalog.NumberTheory.CharacterOneBit

namespace CyclicTypeChannel

open Finset

variable {α β γ δ : Type*}

/-! ## 1. Balanced `m`-valued read-outs -/

section Balanced

variable [DecidableEq γ] {s : Finset α} {k : α → γ}

/-- **A read-out whose fibres all have size `|s| / m` carries exactly `log₂ m` bits.**  For `m = 2`
this is `uEnt_eq_one_of_balanced`; the general case is what makes the abelian ceiling `log₂ |G^ab|`
rather than merely finite. -/
theorem uEnt_eq_logb_card_of_balanced {m : ℕ} (hm : 0 < m) (hs : s.Nonempty)
    (hbal : ∀ a ∈ s, m * #{x ∈ s | k x = k a} = s.card) : uEnt s k = Real.logb 2 m := by
  classical
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hm' : (0 : ℝ) < m := by exact_mod_cast hm
  have hterm : ∀ a ∈ s, Real.logb 2 (#{x ∈ s | k x = k a} : ℝ)
      = Real.logb 2 (s.card : ℝ) - Real.logb 2 m := by
    intro a ha
    have h : (#{x ∈ s | k x = k a} : ℝ) = (s.card : ℝ) / m := by
      have h1 : (m : ℝ) * (#{x ∈ s | k x = k a} : ℝ) = (s.card : ℝ) := by
        exact_mod_cast hbal a ha
      field_simp
      linarith
    rw [h, Real.logb_div (ne_of_gt hN) (ne_of_gt hm')]
  rw [uEnt, Finset.sum_congr rfl hterm, Finset.sum_const, nsmul_eq_mul]
  field_simp
  ring

end Balanced

/-! ## 2. Characters of a finite group -/

section Character

variable {G C : Type*} [Group G] [Fintype G] [Group C] [Fintype C] [DecidableEq C]

/-- Every fibre of a surjective character has size `|G| / |C|`. -/
theorem card_fiber_of_surjective (χ : G →* C) (hsurj : Function.Surjective χ) (a : G) :
    Fintype.card C * #{x : G | χ x = χ a} = Fintype.card G := by
  classical
  have hsum : Fintype.card G = ∑ c : C, #{x : G | χ x = c} :=
    Finset.card_eq_sum_card_fiberwise (fun x _ => Finset.mem_univ (χ x))
  have hconst : ∀ c : C, #{x : G | χ x = c} = #{x : G | χ x = χ a} :=
    fun c => MonoidHom.card_fiber_eq_of_mem_range χ (hsurj c) ⟨a, rfl⟩
  rw [hsum, Finset.sum_congr rfl fun c _ => hconst c, Finset.sum_const, Finset.card_univ,
    smul_eq_mul]

/-- A surjective character carries exactly `log₂ |C|` bits. -/
theorem uEnt_character (χ : G →* C) (hsurj : Function.Surjective χ) :
    uEnt (univ : Finset G) (fun x => χ x) = Real.logb 2 (Fintype.card C) := by
  refine uEnt_eq_logb_card_of_balanced Fintype.card_pos univ_nonempty (fun a _ => ?_)
  rw [Finset.card_univ]
  exact card_fiber_of_surjective χ hsurj a

omit [Fintype G] [Fintype C] [DecidableEq C] in
/-- A homomorphism into a commutative group is a class function. -/
theorem map_eq_of_isConj (hcomm : ∀ a b : C, a * b = b * a) (χ : G →* C) {x y : G}
    (h : IsConj x y) : χ x = χ y := by
  obtain ⟨c, rfl⟩ := isConj_iff.1 h
  rw [map_mul, map_mul, map_inv, hcomm (χ c) (χ x), mul_assoc, mul_inv_cancel, mul_one]

variable [DecidableEq (ConjClasses G)]

/-- **The Frobenius class and an abelian character share exactly `log₂ |C|` bits.**

No refinement hypothesis is needed: a character into an abelian group is constant on conjugacy
classes, so the class read-out always determines it.  Specialised to `C = G^ab` this says that the
*entire* residue-visible content of the Frobenius is `log₂ |G^ab|` bits — one bit when
`G^ab = C₂`. -/
theorem mutInfo_conjClasses_character_eq_logb (hcomm : ∀ a b : C, a * b = b * a) (χ : G →* C)
    (hsurj : Function.Surjective χ) :
    mutInfo (univ : Finset G) (fun x => ConjClasses.mk x) (fun x => χ x)
      = Real.logb 2 (Fintype.card C) := by
  classical
  rw [mutInfo_comm univ_nonempty, mutInfo,
    condEnt_eq_zero_of_refines (s := (univ : Finset G)) (g := fun x => ConjClasses.mk x)
      (k := fun x => χ x) (fun x _ y _ hxy => map_eq_of_isConj hcomm χ
        (ConjClasses.mk_eq_mk_iff_isConj.1 hxy)),
    sub_zero, uEnt_character χ hsurj]

/-- **The exact deficit.**  Everything the Frobenius class knows beyond `log₂ |C|` bits is
invisible to the character. -/
theorem conjClasses_character_deficit (hcomm : ∀ a b : C, a * b = b * a) (χ : G →* C)
    (hsurj : Function.Surjective χ) :
    condEnt (univ : Finset G) (fun x => ConjClasses.mk x) (fun x => χ x)
      = uEnt (univ : Finset G) (fun x => ConjClasses.mk x) - Real.logb 2 (Fintype.card C) := by
  have h := mutInfo_conjClasses_character_eq_logb hcomm χ hsurj
  rw [mutInfo] at h
  linarith

/-- **The abelian ceiling.**  Any read-out `w = u ∘ χ` that is visible through the abelian
quotient — by class field theory, exactly the read-outs computable from the residue of `p` modulo
the conductor — reveals at most `log₂ |C|` bits about the Frobenius class. -/
theorem mutInfo_le_logb_card_of_factors [DecidableEq δ] (χ : G →* C)
    (hsurj : Function.Surjective χ) (u : C → δ) :
    mutInfo (univ : Finset G) (fun x => ConjClasses.mk x) (fun x => u (χ x))
      ≤ Real.logb 2 (Fintype.card C) := by
  classical
  have h₁ : mutInfo (univ : Finset G) (fun x => ConjClasses.mk x) (fun x => u (χ x))
      ≤ uEnt (univ : Finset G) (fun x => u (χ x)) :=
    mutInfo_le_uEnt_right univ_nonempty _ _
  have h₂ : uEnt (univ : Finset G) (fun x => u (χ x))
      ≤ uEnt (univ : Finset G) (fun x => χ x) :=
    uEnt_comp_le (univ : Finset G) (fun x => χ x) u
  rw [uEnt_character χ hsurj] at h₂
  linarith

/-- **Exactly one bit** for an index-two abelian quotient: the ceiling of
`mutInfo_le_logb_card_of_factors` equals `1` and is attained. -/
theorem mutInfo_conjClasses_eq_one_of_card_two (hcomm : ∀ a b : C, a * b = b * a) (χ : G →* C)
    (hsurj : Function.Surjective χ) (hC : Fintype.card C = 2) :
    mutInfo (univ : Finset G) (fun x => ConjClasses.mk x) (fun x => χ x) = 1 := by
  rw [mutInfo_conjClasses_character_eq_logb hcomm χ hsurj, hC]
  norm_num [Real.logb_self_eq_one]

end Character

/-! ## 3. The dichotomy: abelian Galois groups hide nothing -/

section Abelian

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]

/-- **An abelian Galois group hides nothing.**  When `G` is abelian the identity character is
surjective, so the residue determines the Frobenius outright: `I = log₂ |G|`, the full entropy.
Contrast `CyclicTypeChannel.S3.mutInfo_splitType_sign_eq_one`, where only `1` of the `1.4591…`
available bits survives. -/
theorem mutInfo_self_abelian :
    mutInfo (univ : Finset G) (fun x => x) (fun x => (MonoidHom.id G) x)
      = Real.logb 2 (Fintype.card G) := by
  classical
  rw [mutInfo_comm univ_nonempty, mutInfo,
    condEnt_eq_zero_of_refines (s := (univ : Finset G)) (g := fun x => x)
      (k := fun x => (MonoidHom.id G) x) (fun x _ y _ hxy => by simpa using hxy),
    sub_zero, uEnt_character (MonoidHom.id G) Function.surjective_id]

/-- **The cyclic cubic field hides nothing.**  For a cyclic cubic field (`G = C₃`, abelian) the
residue determines the Frobenius completely, and the channel carries `log₂ 3 = 1.5849…` bits —
*more* than the `1` bit available in the `S₃` cubic, even though the `S₃` type has larger entropy
`1.4591…`.  Non-abelian richness is not visibility. -/
theorem mutInfo_cyclic_cubic :
    mutInfo (univ : Finset (Multiplicative (ZMod 3))) (fun x => x)
        (fun x => (MonoidHom.id (Multiplicative (ZMod 3))) x) = Real.logb 2 3 := by
  rw [mutInfo_self_abelian]
  norm_num

/-- One bit is strictly less than what a cyclic cubic reveals. -/
theorem one_lt_mutInfo_cyclic_cubic :
    (1 : ℝ) < mutInfo (univ : Finset (Multiplicative (ZMod 3))) (fun x => x)
      (fun x => (MonoidHom.id (Multiplicative (ZMod 3))) x) := by
  rw [mutInfo_cyclic_cubic]
  have h : Real.logb 2 2 < Real.logb 2 3 := Real.logb_lt_logb (by norm_num) (by norm_num)
    (by norm_num)
  rwa [Real.logb_self_eq_one (by norm_num)] at h

end Abelian

/-! ## 4. The `S₃` cubic field, read through the ceiling -/

namespace S3

open Equiv Equiv.Perm

/-- The sign character of `S₃` is surjective onto the two-element group `ℤˣ`. -/
theorem sign_surjective_three : Function.Surjective (Equiv.Perm.sign : Perm (Fin 3) →* ℤˣ) :=
  sign_surjective (Fin 3)

/-- **`I(p mod 31 ; type) = 1` exactly.**  The conjugacy class of the Frobenius — the complete
arithmetic datum of an unramified prime — shares exactly one bit with the quadratic character
`(-31 | ·)`, which is all that a residue can see. -/
theorem mutInfo_conjClasses_sign_eq_one [DecidableEq (ConjClasses (Perm (Fin 3)))] :
    mutInfo (univ : Finset (Perm (Fin 3))) (fun σ => ConjClasses.mk σ)
        (fun σ => Equiv.Perm.sign σ) = 1 :=
  mutInfo_conjClasses_eq_one_of_card_two (fun a b => mul_comm a b) Equiv.Perm.sign
    sign_surjective_three (by simp)

/-- **No residue does better.**  Every read-out computed from the quadratic character — i.e. every
function of `p mod 31` that is visible in the abelian quotient — is capped at one bit. -/
theorem residue_readout_le_one [DecidableEq (ConjClasses (Perm (Fin 3)))] {δ : Type*}
    [DecidableEq δ] (u : ℤˣ → δ) :
    mutInfo (univ : Finset (Perm (Fin 3))) (fun σ => ConjClasses.mk σ)
        (fun σ => u (Equiv.Perm.sign σ)) ≤ 1 := by
  have h := mutInfo_le_logb_card_of_factors (G := Perm (Fin 3)) Equiv.Perm.sign
    sign_surjective_three u
  rwa [show Fintype.card ℤˣ = 2 by simp, Nat.cast_ofNat,
    Real.logb_self_eq_one (by norm_num)] at h

end S3

end CyclicTypeChannel