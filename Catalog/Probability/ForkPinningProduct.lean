/-
# Independent side-information: the coprime control and the vanishing residual

In the arithmetic experiment the observable attached to a prime `p` is its residue in some
modulus `m`.  Chebotarev factorizes that observable: the part of `p mod m` that is visible to
the splitting field is the image of the Frobenius element in the abelianization of the Galois
group, and the rest is *independent noise*.  The two model theorems proved here are:

* `ForkPinning.coprime_control_flat` : a statistic that lives on an independent factor of the
  probability space carries **zero** information about the fork (the observed `I = 0.0000`
  at the coprime control modulus);
* `ForkPinning.mutualInfo_abelian_plus_noise` : adding independent noise to the abelian
  statistic changes nothing, `I((φ, noise); fork) = I(φ; fork)` — the observed
  "beyond-sign residual `= +0.0000` exactly".
-/

import Probability.ForkPinningCore

namespace ForkPinning

open Finset Real

variable {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Nonempty Ω₁] [Fintype Ω₂] [Nonempty Ω₂]
variable {κ β α : Type*} [Fintype κ] [DecidableEq κ] [Fintype β] [DecidableEq β]
  [Fintype α] [DecidableEq α]

/-! ## Marginals of a product space -/

omit [Nonempty Ω₁] [Nonempty Ω₂] [Fintype κ] in
lemma fiber_fst (U : Ω₁ → κ) (k : κ) :
    fiber (fun x : Ω₁ × Ω₂ => U x.1) k = (fiber U k) ×ˢ (univ : Finset Ω₂) := by
  ext x; simp [fiber]

omit [Nonempty Ω₁] [Nonempty Ω₂] [Fintype κ] in
lemma fiber_snd (V : Ω₂ → κ) (k : κ) :
    fiber (fun x : Ω₁ × Ω₂ => V x.2) k = (univ : Finset Ω₁) ×ˢ (fiber V k) := by
  ext x; simp [fiber]

omit [Fintype κ] in
lemma prb_fst (U : Ω₁ → κ) (k : κ) : prb (fun x : Ω₁ × Ω₂ => U x.1) k = prb U k := by
  have h1 : (0 : ℝ) < Fintype.card Ω₁ := card_pos
  have h2 : (0 : ℝ) < Fintype.card Ω₂ := card_pos
  rw [prb, fiber_fst, Finset.card_product, Finset.card_univ, prb]
  rw [Fintype.card_prod]
  push_cast
  field_simp

omit [Fintype κ] in
lemma prb_snd (V : Ω₂ → κ) (k : κ) : prb (fun x : Ω₁ × Ω₂ => V x.2) k = prb V k := by
  have h1 : (0 : ℝ) < Fintype.card Ω₁ := card_pos
  have h2 : (0 : ℝ) < Fintype.card Ω₂ := card_pos
  rw [prb, fiber_snd, Finset.card_product, Finset.card_univ, prb]
  rw [Fintype.card_prod]
  push_cast
  field_simp

lemma entropy_fst (U : Ω₁ → κ) : H (fun x : Ω₁ × Ω₂ => U x.1) = H U := by
  unfold H
  exact Finset.sum_congr rfl (fun k _ => by rw [prb_fst])

lemma entropy_snd (V : Ω₂ → κ) : H (fun x : Ω₁ × Ω₂ => V x.2) = H V := by
  unfold H
  exact Finset.sum_congr rfl (fun k _ => by rw [prb_snd])

omit [Fintype κ] [Fintype β] in
/-- Statistics living on different factors of a product space are independent. -/
lemma prb_indep_of_prod (U : Ω₁ → κ) (V : Ω₂ → β) (k : κ) (b : β) :
    prb (joint (fun x : Ω₁ × Ω₂ => U x.1) (fun x : Ω₁ × Ω₂ => V x.2)) (k, b)
      = prb (fun x : Ω₁ × Ω₂ => U x.1) k * prb (fun x : Ω₁ × Ω₂ => V x.2) b := by
  have h1 : (0 : ℝ) < Fintype.card Ω₁ := card_pos
  have h2 : (0 : ℝ) < Fintype.card Ω₂ := card_pos
  have hset : fiber (joint (fun x : Ω₁ × Ω₂ => U x.1) (fun x : Ω₁ × Ω₂ => V x.2)) (k, b)
      = (fiber U k) ×ˢ (fiber V b) := by
    ext x; simp [fiber, joint, Prod.ext_iff]
  rw [prb, hset, Finset.card_product, prb_fst, prb_snd, prb, prb, Fintype.card_prod]
  push_cast
  field_simp

/-- **The coprime control is flat.**  A statistic supported on an independent factor of the
probability space carries no information whatsoever about the fork. -/
theorem coprime_control_flat (V : Ω₂ → κ) (Y : Ω₁ → β) :
    mutualInfo (fun x : Ω₁ × Ω₂ => V x.2) (fun x : Ω₁ × Ω₂ => Y x.1) = 0 := by
  refine mutualInfo_eq_zero_of_indep _ _ (fun k b => ?_)
  have hset : fiber (joint (fun x : Ω₁ × Ω₂ => V x.2) (fun x : Ω₁ × Ω₂ => Y x.1)) (k, b)
      = (fiber Y b) ×ˢ (fiber V k) := by
    ext x; simp [fiber, joint, Prod.ext_iff, and_comm]
  have h1 : (0 : ℝ) < Fintype.card Ω₁ := card_pos
  have h2 : (0 : ℝ) < Fintype.card Ω₂ := card_pos
  rw [prb, hset, Finset.card_product, prb_fst, prb_snd, prb, prb, Fintype.card_prod]
  push_cast
  field_simp

/-! ## Independent noise adjoined to the abelian statistic -/

/-- Reassociation `(α × Ω₂) × β ≃ (α × β) × Ω₂`. -/
def swapMid (α β Ω₂ : Type*) : (α × Ω₂) × β ≃ (α × β) × Ω₂ where
  toFun p := ((p.1.1, p.2), p.1.2)
  invFun q := ((q.1.1, q.2), q.1.2)
  left_inv _ := rfl
  right_inv _ := rfl

/-- **Zero residual beyond the abelian part.**  If the observable is the abelian statistic `φ`
together with an independent coordinate (the part of the residue that the field cannot see),
its information about the fork is exactly the information carried by `φ` alone. -/
theorem mutualInfo_abelian_plus_noise [DecidableEq Ω₂] (φ : Ω₁ → α) (Y : Ω₁ → β) :
    mutualInfo (fun x : Ω₁ × Ω₂ => (φ x.1, x.2)) (fun x : Ω₁ × Ω₂ => Y x.1)
      = mutualInfo φ Y := by
  have hHX : H (fun x : Ω₁ × Ω₂ => (φ x.1, x.2))
      = H φ + H (fun x : Ω₂ => x) := by
    have hj : H (joint (fun x : Ω₁ × Ω₂ => φ x.1) (fun x : Ω₁ × Ω₂ => x.2))
        = H (fun x : Ω₁ × Ω₂ => φ x.1) + H (fun x : Ω₁ × Ω₂ => x.2) :=
      entropy_joint_of_indep _ _ (fun k b => prb_indep_of_prod φ (fun x : Ω₂ => x) k b)
    rw [show (fun x : Ω₁ × Ω₂ => (φ x.1, x.2))
        = joint (fun x : Ω₁ × Ω₂ => φ x.1) (fun x : Ω₁ × Ω₂ => x.2) from rfl, hj,
      entropy_fst]
    congr 1
    exact entropy_snd (fun x : Ω₂ => x)
  have hHY : H (fun x : Ω₁ × Ω₂ => Y x.1) = H Y := entropy_fst Y
  have hHJ : H (joint (fun x : Ω₁ × Ω₂ => (φ x.1, x.2)) (fun x : Ω₁ × Ω₂ => Y x.1))
      = H (joint φ Y) + H (fun x : Ω₂ => x) := by
    have hrelabel : H (joint (fun x : Ω₁ × Ω₂ => (φ x.1, x.2)) (fun x : Ω₁ × Ω₂ => Y x.1))
        = H (fun x : Ω₁ × Ω₂ => swapMid α β Ω₂ (joint (fun x : Ω₁ × Ω₂ => (φ x.1, x.2))
            (fun x : Ω₁ × Ω₂ => Y x.1) x)) :=
      (entropy_congr_equiv (swapMid α β Ω₂) _).symm
    rw [hrelabel]
    have hsplit : (fun x : Ω₁ × Ω₂ => swapMid α β Ω₂
          (joint (fun x : Ω₁ × Ω₂ => (φ x.1, x.2)) (fun x : Ω₁ × Ω₂ => Y x.1) x))
        = joint (fun x : Ω₁ × Ω₂ => (joint φ Y) x.1) (fun x : Ω₁ × Ω₂ => x.2) := rfl
    rw [hsplit,
      entropy_joint_of_indep _ _ (fun k b => prb_indep_of_prod (joint φ Y) (fun x : Ω₂ => x) k b),
      entropy_fst]
    congr 1
    exact entropy_snd (fun x : Ω₂ => x)
  unfold mutualInfo
  rw [hHX, hHY, hHJ]
  ring

end ForkPinning