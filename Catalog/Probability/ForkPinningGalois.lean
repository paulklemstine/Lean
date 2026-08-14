/-
# The fork-pinning criterion on three Galois groups: C₃, S₃, S₄

Model.  By Chebotarev, a random prime (unramified, in the natural density sense) produces a
uniformly random Frobenius element of the Galois group `G` of the splitting field, the splitting
type of the defining polynomial being the cycle type of that element on the roots.  Congruence
information about the prime is exactly the information visible through *abelian* characters of
`G`, i.e. through the abelianization `G^ab`.  Everything below is a theorem about the uniform
measure on the finite group `G`.

Main results.

* `ForkPinning.determines_abelianization_of_hom` — **the criterion**: if a fork is determined by
  *some* abelian character of `G`, it is determined by the abelianization map.  With
  `pinned_iff_determines` this says: a fork is congruence-pinned iff it factors through `G^ab`.
* `ForkPinning.comm_fork_pinned` — for an **abelian** Galois group *every* fork is pinned at
  100% of its entropy.
* `ForkPinning.cyclicCubic_fork_mutualInfo` — the cyclic cubic ([1,1,1] fork, `G = C₃`):
  `I = H(fork) = log 3 − (2/3) log 2` (= 0.9183 bits), matching the measured `0.9182`.
* `ForkPinning.S3_fork_mutualInfo` — the `S₃` cubic ([1,1,1] fork):
  `I = (4/3) log 2 + (1/2) log 3 − (5/6) log 5` (= 0.1909 bits), matching the measured `0.1906`;
  and `S3_fork_not_pinned`, `S3_mutualInfo_lt_entropy` : the pinning is strictly partial —
  only the quadratic (sign) character is seen.
* `ForkPinning.S4_hasRoot_mutualInfo` — the `S₄` quartic (has-a-root fork):
  `I = (3/2) log 2 − (5/8) log 5` (= 0.0488 bits), matching the measured `0.0483`.
* `ForkPinning.mutualInfo_flat_on_commutator` — **every within-face fork is flat**: on the
  commutator subgroup (the even face) every abelian character is constant, so its mutual
  information with an arbitrary fork is exactly `0`.
-/

import Probability.ForkPinningCore

namespace ForkPinning

open Finset Real

/-! ## The criterion: pinned ⟺ factors through the abelianization -/

section Criterion

variable {G : Type*} [Group G] [Fintype G] [Nonempty G]
variable {A β : Type*} [CommGroup A] [Fintype β] [DecidableEq β]

omit [Fintype G] [Nonempty G] [Fintype β] [DecidableEq β] in
/-- **Fork-pinning criterion, structural half.**  If a fork is determined by an abelian
character `f : G →* A`, then it is determined by the abelianization map, i.e. it factors
through `G^ab`. -/
theorem determines_abelianization_of_hom (f : G →* A) (Y : G → β)
    (h : Determines (fun g => f g) Y) :
    Determines (fun g : G => Abelianization.of g) Y := by
  intro x y hxy
  refine h x y ?_
  have hxy' : Abelianization.of x = Abelianization.of y := hxy
  have hlift : Abelianization.lift f (Abelianization.of x)
      = Abelianization.lift f (Abelianization.of y) := by rw [hxy']
  rwa [Abelianization.lift_apply_of, Abelianization.lift_apply_of] at hlift

omit [Fintype G] [Nonempty G] [Fintype β] [DecidableEq β] in
/-- Conversely, a fork factoring through the abelianization is determined by it. -/
theorem determines_of_factors_abelianization (Y : G → β)
    (ψ : Abelianization G → β) (hY : Y = ψ ∘ (Abelianization.of : G → Abelianization G)) :
    Determines (fun g : G => Abelianization.of g) Y := by
  intro x y hxy
  rw [hY]
  simp [Function.comp_apply, hxy]

/-- **Pinned by an abelian character ⇒ the fork factors through `G^ab`.** -/
theorem factors_abelianization_of_pinned [Fintype A] [DecidableEq A] [Inhabited β]
    (f : G →* A) (Y : G → β) (hpin : mutualInfo (fun g => f g) Y = H Y) :
    ∃ ψ : Abelianization G → β, Y = ψ ∘ (Abelianization.of : G → Abelianization G) :=
  (determines_iff_factors _ Y).mp
    (determines_abelianization_of_hom f Y ((pinned_iff_determines _ Y).mp hpin))

omit [Fintype β] [DecidableEq β] in
/-- For an **abelian** Galois group the abelianization map is injective, so every fork is
determined by it: the whole splitting behaviour is congruence-pinned. -/
theorem comm_determines_abelianization {G : Type*} [CommGroup G] [Fintype G] [Nonempty G]
    (Y : G → β) : Determines (fun g : G => Abelianization.of g) Y := by
  intro x y hxy
  have hinj : Function.Injective (Abelianization.of : G → Abelianization G) := by
    have hof : (Abelianization.of : G → Abelianization G)
        = (Abelianization.equivOfComm : G ≃* Abelianization G) := rfl
    rw [hof]
    exact (Abelianization.equivOfComm (H := G)).injective
  rw [hinj hxy]

/-- **Abelian Galois group ⇒ 100% pinning.**  For a commutative `G` (e.g. the cyclic cubic
field, `G = C₃`) every fork gives up all of its entropy to the abelianization. -/
theorem comm_fork_pinned {G : Type*} [CommGroup G] [Fintype G] [Nonempty G]
    [Fintype (Abelianization G)] [DecidableEq (Abelianization G)] (Y : G → β) :
    mutualInfo (fun g : G => Abelianization.of g) Y = H Y :=
  (pinned_iff_determines _ Y).mpr (comm_determines_abelianization Y)

end Criterion

/-! ## Within-face flatness -/

section Face

variable {G : Type*} [Group G] {A β : Type*} [CommGroup A] [Fintype A] [DecidableEq A]
  [Fintype β] [DecidableEq β]

/-- **Every within-face fork is flat.**  On the commutator subgroup (the "even face") an
abelian character is identically trivial, so it carries exactly zero information about any
fork whatsoever. -/
theorem mutualInfo_flat_on_commutator [Fintype (commutator G)] [Nonempty (commutator G)]
    (f : G →* A) (Y : (commutator G) → β) :
    mutualInfo (fun x : commutator G => f (x : G)) Y = 0 := by
  have hconst : (fun x : commutator G => f (x : G)) = fun _ => (1 : A) := by
    funext x
    have hx : (x : G) ∈ f.ker := Abelianization.commutator_subset_ker f x.2
    simpa using hx
  rw [hconst]
  exact mutualInfo_const_left 1 Y

end Face

/-! ## Numerical toolkit -/

section Toolkit

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

omit [Nonempty Ω] in
lemma H_bool (Y : Ω → Bool) : H Y = negMulLog (prb Y false) + negMulLog (prb Y true) := by
  unfold H
  rw [Fintype.sum_bool]
  ring

omit [Nonempty Ω] in
lemma H_joint_bool (X Y : Ω → Bool) :
    H (joint X Y) = negMulLog (prb (joint X Y) (false, false))
      + negMulLog (prb (joint X Y) (false, true))
      + negMulLog (prb (joint X Y) (true, false))
      + negMulLog (prb (joint X Y) (true, true)) := by
  rw [entropy_joint_eq]
  rw [Fintype.sum_bool, Fintype.sum_bool, Fintype.sum_bool]
  ring

lemma negMulLog_ratio (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    negMulLog (a / b) = (a / b) * (Real.log b - Real.log a) := by
  rw [negMulLog, Real.log_div (ne_of_gt ha) (ne_of_gt hb)]
  ring

end Toolkit

/-! ### Logarithms of the small integers that occur -/

lemma log_four : Real.log 4 = 2 * Real.log 2 := by
  rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
  push_cast; ring

lemma log_six : Real.log 6 = Real.log 2 + Real.log 3 := by
  rw [show (6 : ℝ) = 2 * 3 by norm_num, Real.log_mul (by norm_num) (by norm_num)]

lemma log_eight : Real.log 8 = 3 * Real.log 2 := by
  rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.log_pow]
  push_cast; ring

lemma log_nine : Real.log 9 = 2 * Real.log 3 := by
  rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.log_pow]
  push_cast; ring

/-! ## (1) The cyclic cubic field: `G = C₃`, the fork is pinned at 100% -/

section CyclicCubic

/-- The `[1,1,1]` fork of a cyclic cubic field: the Frobenius is trivial. -/
def forkC3 (g : ZMod 3) : Bool := decide (g = 0)

lemma card_C3 : Fintype.card (ZMod 3) = 3 := by decide

lemma prb_forkC3_true : prb forkC3 true = 1 / 3 := by
  rw [prb, card_C3, show (fiber forkC3 true).card = 1 from by decide]
  norm_num

lemma prb_forkC3_false : prb forkC3 false = 2 / 3 := by
  rw [prb, card_C3, show (fiber forkC3 false).card = 2 from by decide]
  norm_num

/-- The entropy of the cyclic-cubic fork is `H(1/3) = log 3 − (2/3) log 2` (0.9183 bits). -/
theorem entropy_forkC3 : H forkC3 = Real.log 3 - (2 / 3) * Real.log 2 := by
  rw [H_bool, prb_forkC3_false, prb_forkC3_true,
    negMulLog_ratio 2 3 (by norm_num) (by norm_num),
    negMulLog_ratio 1 3 (by norm_num) (by norm_num), Real.log_one]
  ring

/-- The residue statistic `id` (the full cubic-residue character) determines the fork. -/
theorem determines_forkC3 : Determines (id : ZMod 3 → ZMod 3) forkC3 := by
  intro x y hxy
  rw [show x = y from hxy]

/-- **Cyclic cubic: the fork is pinned at 100% of its entropy**, with the exact value
`log 3 − (2/3) log 2` (= 0.9183 bits; the measured value was 0.9182). -/
theorem cyclicCubic_fork_mutualInfo :
    mutualInfo (id : ZMod 3 → ZMod 3) forkC3 = Real.log 3 - (2 / 3) * Real.log 2 := by
  rw [(pinned_iff_determines _ forkC3).mpr determines_forkC3, entropy_forkC3]

theorem cyclicCubic_fork_pinned : mutualInfo (id : ZMod 3 → ZMod 3) forkC3 = H forkC3 :=
  (pinned_iff_determines _ forkC3).mpr determines_forkC3

end CyclicCubic

/-! ## (2) The `S₃` cubic: only the sign is pinned -/

section S3

/-- The sign character — the abelianization of `Sₙ` for `n = 3, 4`. -/
def signBool {n : ℕ} (σ : Equiv.Perm (Fin n)) : Bool := decide (Equiv.Perm.sign σ = 1)

/-- Splitting type `[1,1,1]`: the Frobenius fixes all three roots. -/
def forkSplit3 (σ : Equiv.Perm (Fin 3)) : Bool := decide (σ = 1)

lemma card_S3 : Fintype.card (Equiv.Perm (Fin 3)) = 6 := by decide

lemma prb_signBool3_false : prb (signBool : Equiv.Perm (Fin 3) → Bool) false = 1 / 2 := by
  rw [prb, card_S3, show (fiber (signBool : Equiv.Perm (Fin 3) → Bool) false).card = 3 from by decide]
  norm_num

lemma prb_signBool3_true : prb (signBool : Equiv.Perm (Fin 3) → Bool) true = 1 / 2 := by
  rw [prb, card_S3, show (fiber (signBool : Equiv.Perm (Fin 3) → Bool) true).card = 3 from by decide]
  norm_num

lemma prb_forkSplit3_true : prb forkSplit3 true = 1 / 6 := by
  rw [prb, card_S3, show (fiber forkSplit3 true).card = 1 from by decide]
  norm_num

lemma prb_forkSplit3_false : prb forkSplit3 false = 5 / 6 := by
  rw [prb, card_S3, show (fiber forkSplit3 false).card = 5 from by decide]
  norm_num

lemma prb_S3_joint_ff :
    prb (joint (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3) (false, false) = 1 / 2 := by
  rw [prb, card_S3,
    show (fiber (joint (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3) (false, false)).card = 3
      from by decide]
  norm_num

lemma prb_S3_joint_ft :
    prb (joint (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3) (false, true) = 0 := by
  rw [prb, card_S3,
    show (fiber (joint (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3) (false, true)).card = 0
      from by decide]
  norm_num

lemma prb_S3_joint_tf :
    prb (joint (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3) (true, false) = 1 / 3 := by
  rw [prb, card_S3,
    show (fiber (joint (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3) (true, false)).card = 2
      from by decide]
  norm_num

lemma prb_S3_joint_tt :
    prb (joint (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3) (true, true) = 1 / 6 := by
  rw [prb, card_S3,
    show (fiber (joint (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3) (true, true)).card = 1
      from by decide]
  norm_num

/-- Entropy of the `S₃` `[1,1,1]` fork: `log 6 − (5/6) log 5` (= 0.6500 bits). -/
theorem entropy_forkSplit3 :
    H forkSplit3 = Real.log 2 + Real.log 3 - (5 / 6) * Real.log 5 := by
  rw [H_bool, prb_forkSplit3_false, prb_forkSplit3_true,
    negMulLog_ratio 5 6 (by norm_num) (by norm_num),
    negMulLog_ratio 1 6 (by norm_num) (by norm_num), Real.log_one, log_six]
  ring

/-- **`S₃` cubic: the congruence content of the `[1,1,1]` fork is exactly the sign.**
`I(sign; fork) = (4/3) log 2 + (1/2) log 3 − (5/6) log 5` = 0.1909 bits
(the measured value was 0.1906). -/
theorem S3_fork_mutualInfo :
    mutualInfo (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3
      = (4 / 3) * Real.log 2 + (1 / 2) * Real.log 3 - (5 / 6) * Real.log 5 := by
  rw [mutualInfo, H_bool, H_bool, H_joint_bool,
    prb_signBool3_false, prb_signBool3_true, prb_forkSplit3_false, prb_forkSplit3_true,
    prb_S3_joint_ff, prb_S3_joint_ft, prb_S3_joint_tf, prb_S3_joint_tt,
    negMulLog_zero,
    negMulLog_ratio 1 2 (by norm_num) (by norm_num),
    negMulLog_ratio 5 6 (by norm_num) (by norm_num),
    negMulLog_ratio 1 6 (by norm_num) (by norm_num),
    negMulLog_ratio 1 3 (by norm_num) (by norm_num), Real.log_one, log_six]
  ring

/-- The `[1,1,1]` fork of the `S₃` cubic does **not** factor through the sign: the Frobenius
classes `1` and a 3-cycle are both even but split differently. -/
theorem S3_fork_not_pinned :
    ¬ Determines (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3 := by
  intro h
  have hne : forkSplit3 1 ≠ forkSplit3 (Equiv.swap 0 1 * Equiv.swap 1 2) := by decide
  exact hne (h 1 (Equiv.swap 0 1 * Equiv.swap 1 2) (by decide))

/-- Consequently the pinning is strictly partial: the sign captures only part of the fork. -/
theorem S3_mutualInfo_lt_entropy :
    mutualInfo (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3 < H forkSplit3 :=
  mutualInfo_lt_entropy_of_not_determines _ _ S3_fork_not_pinned

/-- …but it is strictly positive: the sign *is* pinned (`2⁸·3³ = 6912 > 3125 = 5⁵`). -/
theorem S3_mutualInfo_pos :
    0 < mutualInfo (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3 := by
  rw [S3_fork_mutualInfo]
  have h1 : Real.log 3125 < Real.log 6912 := Real.log_lt_log (by norm_num) (by norm_num)
  have h2 : Real.log 6912 = 8 * Real.log 2 + 3 * Real.log 3 := by
    rw [show (6912 : ℝ) = 2 ^ 8 * 3 ^ 3 by norm_num,
      Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow]
    push_cast; ring
  have h3 : Real.log 3125 = 5 * Real.log 5 := by
    rw [show (3125 : ℝ) = 5 ^ 5 by norm_num, Real.log_pow]
    push_cast; ring
  rw [h2, h3] at h1
  linarith

end S3

/-! ## (3) The `S₄` quartic: only the sign is pinned -/

section S4

/-- The quartic has a root mod `p`: the Frobenius fixes one of the four roots. -/
def forkHasRoot (σ : Equiv.Perm (Fin 4)) : Bool := decide (∃ i, σ i = i)

lemma card_S4 : Fintype.card (Equiv.Perm (Fin 4)) = 24 := by decide

lemma prb_signBool4_false : prb (signBool : Equiv.Perm (Fin 4) → Bool) false = 1 / 2 := by
  rw [prb, card_S4,
    show (fiber (signBool : Equiv.Perm (Fin 4) → Bool) false).card = 12 from by decide]
  norm_num

lemma prb_signBool4_true : prb (signBool : Equiv.Perm (Fin 4) → Bool) true = 1 / 2 := by
  rw [prb, card_S4,
    show (fiber (signBool : Equiv.Perm (Fin 4) → Bool) true).card = 12 from by decide]
  norm_num

lemma prb_hasRoot_true : prb forkHasRoot true = 5 / 8 := by
  rw [prb, card_S4, show (fiber forkHasRoot true).card = 15 from by decide]
  norm_num

lemma prb_hasRoot_false : prb forkHasRoot false = 3 / 8 := by
  rw [prb, card_S4, show (fiber forkHasRoot false).card = 9 from by decide]
  norm_num

lemma prb_S4_joint_ff :
    prb (joint (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot) (false, false) = 1 / 4 := by
  rw [prb, card_S4,
    show (fiber (joint (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot) (false, false)).card = 6
      from by decide]
  norm_num

lemma prb_S4_joint_ft :
    prb (joint (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot) (false, true) = 1 / 4 := by
  rw [prb, card_S4,
    show (fiber (joint (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot) (false, true)).card = 6
      from by decide]
  norm_num

lemma prb_S4_joint_tf :
    prb (joint (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot) (true, false) = 1 / 8 := by
  rw [prb, card_S4,
    show (fiber (joint (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot) (true, false)).card = 3
      from by decide]
  norm_num

lemma prb_S4_joint_tt :
    prb (joint (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot) (true, true) = 3 / 8 := by
  rw [prb, card_S4,
    show (fiber (joint (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot) (true, true)).card = 9
      from by decide]
  norm_num

/-- The splitting densities `4 : 2 : 1 : 0` roots of a genuine `S₄` quartic:
`1 : 6 : 8 : 9` out of `24`. -/
theorem S4_root_counts :
    (univ.filter (fun σ : Equiv.Perm (Fin 4) => (univ.filter (fun i => σ i = i)).card = 4)).card = 1
    ∧ (univ.filter (fun σ : Equiv.Perm (Fin 4) =>
        (univ.filter (fun i => σ i = i)).card = 2)).card = 6
    ∧ (univ.filter (fun σ : Equiv.Perm (Fin 4) =>
        (univ.filter (fun i => σ i = i)).card = 1)).card = 8
    ∧ (univ.filter (fun σ : Equiv.Perm (Fin 4) =>
        (univ.filter (fun i => σ i = i)).card = 0)).card = 9 := by
  refine ⟨by decide, by decide, by decide, by decide⟩

/-- Entropy of the has-a-root fork: `3 log 2 − (5/8) log 5 − (3/8) log 3` (= 0.9544 bits). -/
theorem entropy_hasRoot :
    H forkHasRoot = 3 * Real.log 2 - (5 / 8) * Real.log 5 - (3 / 8) * Real.log 3 := by
  rw [H_bool, prb_hasRoot_false, prb_hasRoot_true,
    negMulLog_ratio 3 8 (by norm_num) (by norm_num),
    negMulLog_ratio 5 8 (by norm_num) (by norm_num), log_eight]
  ring

/-- **`S₄` quartic: only the sign is pinned.**
`I(sign; has-a-root) = (3/2) log 2 − (5/8) log 5` = 0.0488 bits
(the measured value was 0.0483, the predicted 0.0488). -/
theorem S4_hasRoot_mutualInfo :
    mutualInfo (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot
      = (3 / 2) * Real.log 2 - (5 / 8) * Real.log 5 := by
  rw [mutualInfo, H_bool, H_bool, H_joint_bool,
    prb_signBool4_false, prb_signBool4_true, prb_hasRoot_false, prb_hasRoot_true,
    prb_S4_joint_ff, prb_S4_joint_ft, prb_S4_joint_tf, prb_S4_joint_tt,
    negMulLog_ratio 1 2 (by norm_num) (by norm_num),
    negMulLog_ratio 3 8 (by norm_num) (by norm_num),
    negMulLog_ratio 5 8 (by norm_num) (by norm_num),
    negMulLog_ratio 1 4 (by norm_num) (by norm_num),
    negMulLog_ratio 1 8 (by norm_num) (by norm_num), Real.log_one, log_four, log_eight]
  ring

/-- The has-a-root fork does not factor through the sign. -/
theorem S4_hasRoot_not_pinned :
    ¬ Determines (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot := by
  intro h
  have hne : forkHasRoot 1 ≠ forkHasRoot (Equiv.swap 0 1 * Equiv.swap 2 3) := by decide
  exact hne (h 1 (Equiv.swap 0 1 * Equiv.swap 2 3) (by decide))

theorem S4_mutualInfo_lt_entropy :
    mutualInfo (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot < H forkHasRoot :=
  mutualInfo_lt_entropy_of_not_determines _ _ S4_hasRoot_not_pinned

/-- …and the sign really is pinned: `2¹² = 4096 > 3125 = 5⁵`. -/
theorem S4_mutualInfo_pos :
    0 < mutualInfo (signBool : Equiv.Perm (Fin 4) → Bool) forkHasRoot := by
  rw [S4_hasRoot_mutualInfo]
  have h1 : Real.log 3125 < Real.log 4096 := Real.log_lt_log (by norm_num) (by norm_num)
  have h2 : Real.log 4096 = 12 * Real.log 2 := by
    rw [show (4096 : ℝ) = 2 ^ 12 by norm_num, Real.log_pow]
    push_cast; ring
  have h3 : Real.log 3125 = 5 * Real.log 5 := by
    rw [show (3125 : ℝ) = 5 ^ 5 by norm_num, Real.log_pow]
    push_cast; ring
  rw [h2, h3] at h1
  linarith

end S4

/-! ## Comparison: abelian closure pins strictly more than the `S₃` closure -/

/-- The cyclic cubic pins strictly more of its fork than the `S₃` cubic does:
`0.9183 > 0.1909` bits.  Flatness is "the fork lies outside `G^ab`", not a class-number
phenomenon. -/
theorem cyclicCubic_pins_more_than_S3 :
    mutualInfo (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3
      < mutualInfo (id : ZMod 3 → ZMod 3) forkC3 := by
  rw [S3_fork_mutualInfo, cyclicCubic_fork_mutualInfo]
  -- reduces to `2^12 · 3^3 < 5^5 · 3^6`, i.e. `110592 < 2278125`
  have h1 : Real.log 110592 < Real.log 2278125 := Real.log_lt_log (by norm_num) (by norm_num)
  have h2 : Real.log 110592 = 12 * Real.log 2 + 3 * Real.log 3 := by
    rw [show (110592 : ℝ) = 2 ^ 12 * 3 ^ 3 by norm_num,
      Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow]
    push_cast; ring
  have h3 : Real.log 2278125 = 5 * Real.log 5 + 6 * Real.log 3 := by
    rw [show (2278125 : ℝ) = 5 ^ 5 * 3 ^ 6 by norm_num,
      Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow]
    push_cast; ring
  rw [h2, h3] at h1
  linarith

/-! ## A checkable form of the criterion, and "no character pins it" theorems -/

section CommutatorForm

variable {G : Type*} [Group G] {β : Type*}

/-- **Checkable form of the criterion.**  A fork factors through `G^ab` exactly when it is
invariant under multiplication by commutators. -/
theorem determines_abelianization_iff_commutator_invariant (Y : G → β) :
    Determines (fun g : G => Abelianization.of g) Y
      ↔ ∀ g c, c ∈ commutator G → Y (g * c) = Y g := by
  constructor
  · intro h g c hc
    refine h (g * c) g ?_
    refine QuotientGroup.eq.mpr ?_
    have : (g * c)⁻¹ * g = c⁻¹ := by group
    rw [this]
    exact Subgroup.inv_mem _ hc
  · intro h x y hxy
    have hmem : x⁻¹ * y ∈ commutator G := QuotientGroup.eq.mp hxy
    have hx := h x (x⁻¹ * y) hmem
    have hxy' : x * (x⁻¹ * y) = y := by group
    rw [hxy'] at hx
    exact hx.symm

variable [Fintype G] [Nonempty G] [Fintype β] [DecidableEq β]

/-- The criterion in its final form: pinned by the abelianization ⟺ commutator-invariant. -/
theorem pinned_iff_commutator_invariant [Fintype (Abelianization G)]
    [DecidableEq (Abelianization G)] (Y : G → β) :
    mutualInfo (fun g : G => Abelianization.of g) Y = H Y
      ↔ ∀ g c, c ∈ commutator G → Y (g * c) = Y g :=
  (pinned_iff_determines _ Y).trans (determines_abelianization_iff_commutator_invariant Y)

/-- **No abelian character at all pins a fork that fails commutator invariance.** -/
theorem never_pinned_of_not_commutator_invariant {A : Type*} [CommGroup A] [Fintype A]
    [DecidableEq A] (f : G →* A) (Y : G → β)
    (hbad : ¬ ∀ g c, c ∈ commutator G → Y (g * c) = Y g) :
    mutualInfo (fun g => f g) Y ≠ H Y := by
  intro hpin
  exact hbad ((determines_abelianization_iff_commutator_invariant Y).mp
    (determines_abelianization_of_hom f Y ((pinned_iff_determines _ Y).mp hpin)))

end CommutatorForm

/-! ## Capacity of the sign character -/

/-- **One bit is all there is.**  For a symmetric-group closure, whatever the fork, the sign
character can transmit at most `log 2` nats (one bit) about it. -/
theorem sign_capacity {n : ℕ} (Y : Equiv.Perm (Fin n) → Bool) :
    mutualInfo (signBool : Equiv.Perm (Fin n) → Bool) Y ≤ Real.log 2 := by
  have h := mutualInfo_le_log_card (signBool : Equiv.Perm (Fin n) → Bool) Y
  simpa using h

/-- Pinned by the sign ⟺ the fork is a function of the sign. -/
theorem pinned_by_sign_iff_factors {n : ℕ} (Y : Equiv.Perm (Fin n) → Bool) :
    mutualInfo (signBool : Equiv.Perm (Fin n) → Bool) Y = H Y
      ↔ ∃ ψ : Bool → Bool, Y = ψ ∘ signBool :=
  (pinned_iff_determines _ Y).trans (determines_iff_factors _ Y)

/-! ## The two non-abelian forks are pinned by *no* Dirichlet character -/

/-- The `[1,1,1]` fork of the `S₃` cubic is not invariant under the commutator subgroup:
multiplying `1` by the commutator `⁅(0 1), (1 2)⁆` (a 3-cycle) changes the fork. -/
theorem S3_fork_not_commutator_invariant :
    ¬ ∀ g c, c ∈ commutator (Equiv.Perm (Fin 3)) → forkSplit3 (g * c) = forkSplit3 g := by
  intro h
  have hc : ⁅Equiv.swap (0 : Fin 3) 1, Equiv.swap (1 : Fin 3) 2⁆ ∈ commutator (Equiv.Perm (Fin 3)) := by
    rw [commutator_def]
    exact Subgroup.commutator_mem_commutator (Subgroup.mem_top _) (Subgroup.mem_top _)
  have := h 1 _ hc
  revert this
  decide

/-- **No Dirichlet character pins the `S₃` fork.**  For every abelian character `f` of the
Galois group the `[1,1,1]` fork keeps a strictly positive amount of entropy hidden. -/
theorem S3_fork_never_pinned {A : Type*} [CommGroup A] [Fintype A] [DecidableEq A]
    (f : Equiv.Perm (Fin 3) →* A) :
    mutualInfo (fun g => f g) forkSplit3 ≠ H forkSplit3 :=
  never_pinned_of_not_commutator_invariant f forkSplit3 S3_fork_not_commutator_invariant

/-- The has-a-root fork of the `S₄` quartic is not commutator invariant either. -/
theorem S4_hasRoot_not_commutator_invariant :
    ¬ ∀ g c, c ∈ commutator (Equiv.Perm (Fin 4)) → forkHasRoot (g * c) = forkHasRoot g := by
  intro h
  have hc : ⁅Equiv.swap (0 : Fin 4) 1, Equiv.swap (1 : Fin 4) 2⁆ ∈ commutator (Equiv.Perm (Fin 4)) := by
    rw [commutator_def]
    exact Subgroup.commutator_mem_commutator (Subgroup.mem_top _) (Subgroup.mem_top _)
  have := h (Equiv.swap (0 : Fin 4) 1 * Equiv.swap (1 : Fin 4) 2 * Equiv.swap (2 : Fin 4) 3) _ hc
  revert this
  decide

/-- **No Dirichlet character pins the `S₄` has-a-root fork.** -/
theorem S4_hasRoot_never_pinned {A : Type*} [CommGroup A] [Fintype A] [DecidableEq A]
    (f : Equiv.Perm (Fin 4) →* A) :
    mutualInfo (fun g => f g) forkHasRoot ≠ H forkHasRoot :=
  never_pinned_of_not_commutator_invariant f forkHasRoot S4_hasRoot_not_commutator_invariant

/-- **The residual bookkeeping of the `S₃` fork.**  Conditioned on the sign, the fork still has
the full cyclic-cubic entropy on the even face and none on the odd face, so
`I(sign ; fork) = H(fork) − ½ · H(1/3)` — exactly the decomposition observed numerically. -/
theorem S3_mutualInfo_eq_entropy_sub_half_H3 :
    mutualInfo (signBool : Equiv.Perm (Fin 3) → Bool) forkSplit3
      = H forkSplit3 - (1 / 2) * (Real.log 3 - (2 / 3) * Real.log 2) := by
  rw [S3_fork_mutualInfo, entropy_forkSplit3]
  ring

end ForkPinning