import Mathlib
import Probability.D5TypeChannel

/-!
# The dihedral dial: exactly one bit for every odd `n`, strictly less for `D₂`

Second iteration of the `THE-D5-DIAL-IS-MEASURED` loop (FACT round-33 #3,
paper 118).  The exact one-bit value of the `D₅` dial is not special to `n = 5`:

* `dihedral_odd_dial` — for every odd `n`, the quadratic shadow of a Frobenius in
  `D_n` carries **exactly one bit** about its order (the splitting type).  The
  mechanism: rotations of an odd dihedral group have odd order, reflections have
  order `2`, so the sign is a deterministic read-out of the type, and the sign is a
  fair coin (`dSign_balanced`, `dSign_entropy`).
* `dihedral_odd_dial_universal` — the same exact value for every balanced residue
  model at every conductor (Chebotarev fibre product over the sign quotient).
* `dihedral_two_dial` — the parity hypothesis is essential: for the Klein group
  `D₂` the dial reads `3/2 - (3/4)·log₂ 3 ≈ 0.311 < 1` bit, because the rotation
  `r 1` and the reflections have the same order `2`.
-/

open Finset DihedralGroup CyclicTypeChannel Catalog.Probability.D5TypeChannelCore
open Catalog.Probability.D5TypeChannel

namespace Catalog.Probability.D5TypeChannelDihedral

/-- The sign character `D_n → C₂` (rotations `↦ 0`, reflections `↦ 1`). -/
def dSign {n : ℕ} : DihedralGroup n → ZMod 2
  | r _ => 0
  | sr _ => 1

/-- The sign is a fair coin: each value is taken by exactly `n` elements. -/
theorem dSign_balanced (n : ℕ) [NeZero n] :
    ∀ e ∈ (univ : Finset (ZMod 2)), #{g ∈ (univ : Finset (DihedralGroup n)) | dSign g = e} = n := by
  intro e _
  fin_cases e
  · show #{g ∈ (univ : Finset (DihedralGroup n)) | dSign g = 0} = n
    have : {g ∈ (univ : Finset (DihedralGroup n)) | dSign g = 0}
        = (univ : Finset (ZMod n)).map ⟨r, fun a b h => r.inj h⟩ := by
      ext g; cases g <;> simp [dSign]
    rw [this, card_map, card_univ, ZMod.card]
  · show #{g ∈ (univ : Finset (DihedralGroup n)) | dSign g = 1} = n
    have : {g ∈ (univ : Finset (DihedralGroup n)) | dSign g = 1}
        = (univ : Finset (ZMod n)).map ⟨sr, fun a b h => sr.inj h⟩ := by
      ext g; cases g <;> simp [dSign]
    rw [this, card_map, card_univ, ZMod.card]

lemma uEnt_zmod_two_id : uEnt (univ : Finset (ZMod 2)) id = 1 := by
  have h : ((univ : Finset (ZMod 2)).image id).val.map
      (fun v => #{x ∈ univ | id x = v}) = {1, 1} := by decide
  rw [uEnt_eq_countSum _ _ _ h]
  simp [Real.logb_self_eq_one]

/-- `H(sign) = 1` in every dihedral group. -/
theorem dSign_entropy (n : ℕ) [NeZero n] :
    uEnt (univ : Finset (DihedralGroup n)) dSign = 1 := by
  have := uEnt_cover (univ : Finset (DihedralGroup n)) (univ : Finset (ZMod 2)) dSign n
    (Nat.pos_of_ne_zero (NeZero.ne n)) (fun _ _ => mem_univ _) (dSign_balanced n) id
  rw [← uEnt_zmod_two_id, ← this]
  rfl

/-- In an odd dihedral group the sign is read off from the order. -/
theorem dSign_eq_signOfType_orderOf {n : ℕ} (hn : Odd n) (g : DihedralGroup n) :
    dSign g = signOfType (orderOf g) := by
  cases g with
  | r i =>
    haveI : NeZero n := ⟨by rintro rfl; exact absurd hn (by decide)⟩
    have hdvd : orderOf (r i) ∣ n := by
      rw [orderOf_r]; exact Nat.div_dvd_of_dvd (Nat.gcd_dvd_left n i.val)
    have hodd : Odd (orderOf (r i)) := Odd.of_dvd_nat hn hdvd
    have hne : orderOf (r i) ≠ 2 := by
      intro h; rw [h] at hodd; exact absurd hodd (by decide)
    simp [dSign, signOfType, hne]
  | sr i => simp [dSign, signOfType, orderOf_sr]

/-- **The odd dihedral dial reads exactly one bit.** -/
theorem dihedral_odd_dial (n : ℕ) [NeZero n] (hn : Odd n) :
    mutInfo (univ : Finset (DihedralGroup n)) orderOf dSign = 1 := by
  rw [mutInfo_of_function _ _ _ signOfType fun g _ => dSign_eq_signOfType_orderOf hn g,
    dSign_entropy]

/-- The odd dihedral dial at every conductor: exactly one bit for every balanced
residue model whose quotient character is the sign. -/
theorem dihedral_odd_dial_universal (n : ℕ) [NeZero n] (hn : Odd n) {A : Type*} [DecidableEq A]
    (U : Finset A) (χ : A → ZMod 2) (K : ℕ) (hK : 0 < K)
    (hbal : ∀ e : ZMod 2, #{a ∈ U | χ a = e} = K) :
    mutInfo (fibreProd U χ (dSign (n := n))) (orderOf ∘ Prod.snd) Prod.fst = 1 := by
  rw [fibreProd_mutInfo U χ dSign orderOf K hK fun g => hbal _, dihedral_odd_dial n hn]

/-- `D₅` is the case `n = 5`: the catalog's `d5Sign` is `dSign`. -/
theorem d5Sign_eq_dSign : (d5Sign : D5 → ZMod 2) = dSign := by
  funext g; cases g <;> rfl

/-! ## The even case fails: the Klein group `D₂` -/

/-- Explicit order function of `D₂`. -/
def d2Type : DihedralGroup 2 → ℕ
  | r i => if i = 0 then 1 else 2
  | sr _ => 2

lemma d2Type_eq_orderOf (g : DihedralGroup 2) : d2Type g = orderOf g := by
  cases g with
  | r i => rw [orderOf_r]; fin_cases i <;> simp [d2Type]; all_goals decide
  | sr i => rw [orderOf_sr]; rfl

lemma d2_typeEntropy : uEnt (univ : Finset (DihedralGroup 2)) d2Type
    = 2 - (3 / 4) * Real.logb 2 3 := by
  have h : ((univ : Finset (DihedralGroup 2)).image d2Type).val.map
      (fun v => #{x ∈ univ | d2Type x = v}) = {1, 3} := by decide
  have hc : (univ : Finset (DihedralGroup 2)).card = 4 := by
    rw [card_univ, DihedralGroup.card]
  rw [uEnt_eq_countSum _ _ _ h, hc]
  simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.map_singleton,
    Multiset.sum_cons, Multiset.sum_singleton]
  push_cast
  rw [lb_4, Real.logb_one]
  ring

lemma d2_cell_rot : uEnt {y ∈ (univ : Finset (DihedralGroup 2)) | dSign y = 0} d2Type = 1 := by
  have h : ({y ∈ (univ : Finset (DihedralGroup 2)) | dSign y = 0}.image d2Type).val.map
      (fun v => #{x ∈ {y ∈ (univ : Finset (DihedralGroup 2)) | dSign y = 0} | d2Type x = v})
        = {1, 1} := by decide
  have hc : ({y ∈ (univ : Finset (DihedralGroup 2)) | dSign y = 0}).card = 2 := by decide
  rw [uEnt_eq_countSum _ _ _ h, hc]
  simp [Real.logb_self_eq_one]

lemma d2_cell_refl : uEnt {y ∈ (univ : Finset (DihedralGroup 2)) | dSign y = 1} d2Type = 0 := by
  have h : ({y ∈ (univ : Finset (DihedralGroup 2)) | dSign y = 1}.image d2Type).val.map
      (fun v => #{x ∈ {y ∈ (univ : Finset (DihedralGroup 2)) | dSign y = 1} | d2Type x = v})
        = {2} := by decide
  have hc : ({y ∈ (univ : Finset (DihedralGroup 2)) | dSign y = 1}).card = 2 := by decide
  rw [uEnt_eq_countSum _ _ _ h, hc]
  simp

lemma d2_condEnt : condEnt (univ : Finset (DihedralGroup 2)) d2Type dSign = 1 / 2 := by
  have himg : (univ : Finset (DihedralGroup 2)).image dSign = {0, 1} := by decide
  have h0 : ({x ∈ (univ : Finset (DihedralGroup 2)) | dSign x = 0}).card = 2 := by decide
  have h1 : ({x ∈ (univ : Finset (DihedralGroup 2)) | dSign x = 1}).card = 2 := by decide
  have hc : (univ : Finset (DihedralGroup 2)).card = 4 := by
    rw [card_univ, DihedralGroup.card]
  rw [condEnt, himg, sum_pair (by decide), h0, h1, hc, d2_cell_rot, d2_cell_refl]
  norm_num

/-- **Parity is essential.** For the Klein group `D₂` the dial reads
`3/2 - (3/4)·log₂ 3 ≈ 0.311`, strictly less than one bit. -/
theorem dihedral_two_dial :
    mutInfo (univ : Finset (DihedralGroup 2)) orderOf dSign = 3 / 2 - (3 / 4) * Real.logb 2 3 ∧
      mutInfo (univ : Finset (DihedralGroup 2)) orderOf dSign < 1 := by
  have he : mutInfo (univ : Finset (DihedralGroup 2)) orderOf dSign
      = mutInfo (univ : Finset (DihedralGroup 2)) d2Type dSign :=
    mutInfo_congr (fun g _ => (d2Type_eq_orderOf g).symm) fun _ _ => rfl
  have hv : mutInfo (univ : Finset (DihedralGroup 2)) orderOf dSign
      = 3 / 2 - (3 / 4) * Real.logb 2 3 := by
    rw [he, mutInfo, d2_typeEntropy, d2_condEnt]
    ring
  refine ⟨hv, ?_⟩
  rw [hv]
  have := lb_three_gt
  linarith

end Catalog.Probability.D5TypeChannelDihedral