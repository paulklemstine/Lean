/-
# The two extremes of the degree-five type channel: `S₅` and `A₅`

The catalog's splitting-type channel (`Shared.CyclicTypeChannel`) has been developed for
abelian Galois groups and, at degree five, for the Frobenius group `F₂₀ = AGL(1,5)`
(`Bridges.QuinticTypeChannelF20`).  This file closes the transitive-quintic row at its two
*extremes*, the two groups whose abelianizations are as large and as small as possible
among the quintic Galois groups:

* `S₅` (realised e.g. by `x⁵ - x - 1`): abelianization `C₂`, read off by the
  quadratic-residue bit of the discriminant;
* `A₅` (realised e.g. by `x⁵ + 20x + 16`): a **perfect** group, abelianization trivial.

## The model

Under Chebotarev the Frobenius class of an unramified prime is equidistributed on the Galois
group, so the *Chebotarev box* of the field is the group itself with counting measure, the
**type read-out** `qType` is the cycle type of the Frobenius (= the degree pattern of the
factorisation of the defining quintic mod `p`), and a **dial read-out** is any function of the
Frobenius that a residue class of `p` can see, i.e. any homomorphism into an abelian group.

## Results

Splitting entropies (exact closed forms, then certified brackets):

* `S5_typeEntropy` — `H(T) = 7/5 + (17/40) log₂ 3 + (5/24) log₂ 5`, bracketed in
  `S5_typeEntropy_bracket` by `2.5573 < H(T) < 2.5574`: seven factorisation types
  (`S5_image_qType`), the largest type entropy of the degree ≤ 5 row.
* `A5_typeEntropy` — `H(T) = 2/15 + (7/20) log₂ 3 + (5/12) log₂ 5`, bracketed by
  `1.6555 < H(T) < 1.6556`, on a four-state type channel (`A5_image_qType`): the odd
  factorisation types never occur.

The abelianization law, in both directions:

* `abelianization_law_S5` — `I(sign ; T) = 1` **exactly**: the seven-state type channel of
  `S₅` transmits exactly the one bit of the quadratic character, no more and no less.
* `S5_abelian_dial_dichotomy` — the sharp form: for *every* homomorphism `φ` of `S₅` into an
  abelian group, `I(φ ; T)` is `1` if `φ` is nontrivial and `0` if `φ` is trivial; in
  particular `I(φ ; T) ≤ 1` for every abelian dial (`S5_abelian_dial_le_one`).
* `S5_pair_law` — the semiprime pair channel also transmits exactly one bit.
* `A5_seal` — **the seal**: on `A₅` every multiplicative read-out into an abelian group is
  constant, hence `I(d ; T) = 0` for *every* type read-out `T` and *every* such dial `d`, a
  parameter-free zero.  `A5_pair_seal` is the semiprime-pair version.

The group-theoretic engine is `alternating_hom_trivial`: simplicity plus non-commutativity of
`A₅` force every homomorphism out of `A₅` into an abelian group to be trivial.  This is the
structural reason why the `S₅` channel is capped at one bit and the `A₅` channel at zero.
-/
import Shared.CyclicTypeChannel
import Bridges.QuinticTypeChannelF20

namespace QuinticS5A5

open Finset Equiv CyclicTypeChannel

set_option maxRecDepth 100000
set_option exponentiation.threshold 2000

/-! ## 0. Logarithm bookkeeping -/

/-- A rational lower bound for `log₂ a` from an integer power inequality. -/
lemma logb_two_lower {a m n : ℕ} (ha : 1 < a) (hn : 0 < n) (h : 2 ^ m < a ^ n) :
    (m : ℝ) / n < Real.logb 2 (a : ℝ) := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have ha' : (1 : ℝ) < a := by exact_mod_cast ha
  have hlt : ((2 : ℝ)) ^ m < ((a : ℝ)) ^ n := by exact_mod_cast h
  have hlog : Real.log ((2 : ℝ) ^ m) < Real.log ((a : ℝ) ^ n) :=
    Real.log_lt_log (by positivity) hlt
  rw [Real.log_pow, Real.log_pow] at hlog
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  rw [Real.logb, div_lt_div_iff₀ hn' h2]
  nlinarith [hlog]

/-- A rational upper bound for `log₂ a` from an integer power inequality. -/
lemma logb_two_upper {a m n : ℕ} (ha : 1 < a) (hn : 0 < n) (h : a ^ n < 2 ^ m) :
    Real.logb 2 (a : ℝ) < (m : ℝ) / n := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have ha' : (1 : ℝ) < a := by exact_mod_cast ha
  have hlt : ((a : ℝ)) ^ n < ((2 : ℝ)) ^ m := by exact_mod_cast h
  have hlog : Real.log ((a : ℝ) ^ n) < Real.log ((2 : ℝ) ^ m) :=
    Real.log_lt_log (by positivity) hlt
  rw [Real.log_pow, Real.log_pow] at hlog
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  rw [Real.logb, div_lt_div_iff₀ h2 hn']
  nlinarith [hlog]

/-- `log₂ 3 > 1054/665`, certified by `2 ^ 1054 < 3 ^ 665`. -/
lemma lb3_lower : (1054 : ℝ) / 665 < Real.logb 2 3 := by
  have h := logb_two_lower (a := 3) (m := 1054) (n := 665) (by norm_num) (by norm_num)
    (by decide)
  norm_num at h
  exact h

/-- `log₂ 3 < 485/306`, certified by `3 ^ 306 < 2 ^ 485`. -/
lemma lb3_upper : Real.logb 2 3 < (485 : ℝ) / 306 := by
  have h := logb_two_upper (a := 3) (m := 485) (n := 306) (by norm_num) (by norm_num)
    (by decide)
  norm_num at h
  exact h

/-- `log₂ 5 > 339/146`, certified by `2 ^ 339 < 5 ^ 146`. -/
lemma lb5_lower : (339 : ℝ) / 146 < Real.logb 2 5 := by
  have h := logb_two_lower (a := 5) (m := 339) (n := 146) (by norm_num) (by norm_num)
    (by decide)
  norm_num at h
  exact h

/-- `log₂ 5 < 1493/643`, certified by `5 ^ 643 < 2 ^ 1493`. -/
lemma lb5_upper : Real.logb 2 5 < (1493 : ℝ) / 643 := by
  have h := logb_two_upper (a := 5) (m := 1493) (n := 643) (by norm_num) (by norm_num)
    (by decide)
  norm_num at h
  exact h

lemma logb_double {x : ℝ} (hx : 0 < x) : Real.logb 2 (2 * x) - Real.logb 2 x = 1 := by
  rw [Real.logb_mul (by norm_num) (ne_of_gt hx), Real.logb_self_eq_one (by norm_num)]
  ring

lemma lb_20 : Real.logb 2 (20 : ℝ) = 2 + Real.logb 2 5 := by
  rw [show (20 : ℝ) = 4 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_4]

lemma lb_30 : Real.logb 2 (30 : ℝ) = 1 + Real.logb 2 3 + Real.logb 2 5 := by
  rw [show (30 : ℝ) = 2 * (3 * 5) by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num), Real.logb_self_eq_one (by norm_num)]
  ring

lemma lb_60 : Real.logb 2 (60 : ℝ) = 2 + Real.logb 2 3 + Real.logb 2 5 := by
  rw [show (60 : ℝ) = 4 * (3 * 5) by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num), lb_4]
  ring

lemma lb_120 : Real.logb 2 (120 : ℝ) = 3 + Real.logb 2 3 + Real.logb 2 5 := by
  rw [show (120 : ℝ) = 8 * (3 * 5) by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num), lb_8]
  ring

/-! ## 1. Entropy lemmas for constant and factoring read-outs -/

section Generic

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- A read-out that is constant on `s` has zero entropy. -/
theorem uEnt_eq_zero_of_const {s : Finset α} {g : α → β}
    (h : ∀ x ∈ s, ∀ y ∈ s, g x = g y) : uEnt s g = 0 := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  · have hcard : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
    have hfib : ∀ a ∈ s, ({x ∈ s | g x = g a} : Finset α) = s := fun a ha =>
      Finset.filter_true_of_mem fun x hx => h x hx a ha
    have hsum : ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
        = (s.card : ℝ) * Real.logb 2 (s.card : ℝ) := by
      rw [Finset.sum_congr rfl fun a ha => by rw [hfib a ha]]
      simp [Finset.sum_const, nsmul_eq_mul]
    rw [uEnt, hsum, mul_comm, mul_div_assoc, div_self (ne_of_gt hcard), mul_one, sub_self]

/-- If the read-out `g` is a function of the read-out `k`, then conditioning on `k`
annihilates the entropy of `g`. -/
theorem condEnt_eq_zero_of_factors {s : Finset α} {g : α → β} {k : α → γ}
    (h : ∀ x ∈ s, ∀ y ∈ s, k x = k y → g x = g y) : condEnt s g k = 0 := by
  refine Finset.sum_eq_zero fun c _ => ?_
  have hz : uEnt {x ∈ s | k x = c} g = 0 := by
    refine uEnt_eq_zero_of_const fun x hx y hy => ?_
    simp only [mem_filter] at hx hy
    exact h x hx.1 y hy.1 (by rw [hx.2, hy.2])
  rw [hz, mul_zero]

/-- **Zero information from a constant read-out.**  A read-out that is constant on the box
carries no information about anything, and hears nothing from anything. -/
theorem mutInfo_eq_zero_of_const {s : Finset α} {g : α → β} (k : α → γ)
    (h : ∀ x ∈ s, ∀ y ∈ s, g x = g y) : mutInfo s g k = 0 := by
  have h1 : uEnt s g = 0 := uEnt_eq_zero_of_const h
  have h2 : condEnt s g k = 0 := condEnt_eq_zero_of_factors fun x hx y hy _ => h x hx y hy
  rw [mutInfo, h1, h2, sub_zero]

/-- **Full transmission.**  If the dial `g` is a function of the conditioning read-out `k`,
the information transmitted is the whole entropy of the dial. -/
theorem mutInfo_eq_uEnt_of_factors {s : Finset α} {g : α → β} {k : α → γ}
    (h : ∀ x ∈ s, ∀ y ∈ s, k x = k y → g x = g y) : mutInfo s g k = uEnt s g := by
  rw [mutInfo, condEnt_eq_zero_of_factors h, sub_zero]

end Generic

/-! ## 2. The boxes and the read-outs -/

/-- The Chebotarev box of an `S₅` quintic: all `120` Frobenius elements. -/
def S5box : Finset (Perm (Fin 5)) := univ

/-- The Chebotarev box of an `A₅` quintic: the `60` even Frobenius elements. -/
def A5box : Finset (Perm (Fin 5)) := univ.filter fun σ => Perm.sign σ = 1

/-- The splitting type of the quintic at a prime: the cycle type of its Frobenius. -/
def qType (σ : Perm (Fin 5)) : Multiset ℕ := σ.cycleType

/-- The abelianization dial of `S₅`: the sign of the Frobenius, i.e. the quadratic-residue
bit of the discriminant. -/
def signDial (σ : Perm (Fin 5)) : ℤˣ := Perm.sign σ

lemma card_S5box : (#S5box : ℕ) = 120 := by decide

lemma card_A5box : (#A5box : ℕ) = 60 := by decide

lemma mem_A5box {σ : Perm (Fin 5)} : σ ∈ A5box ↔ Perm.sign σ = 1 := by
  rw [A5box, Finset.mem_filter]
  exact ⟨fun h => h.2, fun h => ⟨mem_univ _, h⟩⟩

/-- Seven factorisation types occur for an `S₅` quintic: `[1,1,1,1,1]`, `[1,1,1,2]`,
`[1,2,2]`, `[1,1,3]`, `[2,3]`, `[1,4]` and `[5]`. -/
theorem S5_image_qType :
    S5box.image qType = {0, {2}, {2, 2}, {3}, {2, 3}, {4}, {5}} := by decide

/-- Only four factorisation types occur for an `A₅` quintic: the odd types `[1,1,1,2]`,
`[2,3]` and `[1,4]` never occur. -/
theorem A5_image_qType : A5box.image qType = {0, {2, 2}, {3}, {5}} := by decide

theorem S5_card_image_qType : (S5box.image qType).card = 7 := by decide

theorem A5_card_image_qType : (A5box.image qType).card = 4 := by decide

/-! ## 3. The splitting entropies -/

theorem S5_class_sizes :
    (S5box.image qType).val.map (fun v => (#{x ∈ S5box | qType x = v} : ℕ))
      = {1, 10, 15, 20, 20, 30, 24} := by decide

theorem A5_class_sizes :
    (A5box.image qType).val.map (fun v => (#{x ∈ A5box | qType x = v} : ℕ))
      = {1, 15, 20, 24} := by decide

/-- **The `S₅` splitting entropy.**  `H(T) = 7/5 + (17/40) log₂ 3 + (5/24) log₂ 5`. -/
theorem S5_typeEntropy :
    uEnt S5box qType = 7 / 5 + 17 / 40 * Real.logb 2 3 + 5 / 24 * Real.logb 2 5 := by
  rw [uEnt_eq_countSum S5box qType _ S5_class_sizes, card_S5box]
  norm_num [Multiset.insert_eq_cons, lb_120, lb_10, lb_15, lb_20, lb_30, lb_24]
  ring

/-- **The `A₅` splitting entropy.**  `H(T) = 2/15 + (7/20) log₂ 3 + (5/12) log₂ 5`. -/
theorem A5_typeEntropy :
    uEnt A5box qType = 2 / 15 + 7 / 20 * Real.logb 2 3 + 5 / 12 * Real.logb 2 5 := by
  rw [uEnt_eq_countSum A5box qType _ A5_class_sizes, card_A5box]
  norm_num [Multiset.insert_eq_cons, lb_60, lb_15, lb_20, lb_24]
  ring

theorem S5_typeEntropy_bracket :
    2.5573 < uEnt S5box qType ∧ uEnt S5box qType < 2.5574 := by
  rw [S5_typeEntropy]
  refine ⟨?_, ?_⟩
  · nlinarith [lb3_lower, lb5_lower]
  · nlinarith [lb3_upper, lb5_upper]

theorem A5_typeEntropy_bracket :
    1.6555 < uEnt A5box qType ∧ uEnt A5box qType < 1.6556 := by
  rw [A5_typeEntropy]
  refine ⟨?_, ?_⟩
  · nlinarith [lb3_lower, lb5_lower]
  · nlinarith [lb3_upper, lb5_upper]

/-- The `S₅` type channel is strictly richer than the `A₅` one. -/
theorem A5_typeEntropy_lt_S5 : uEnt A5box qType < uEnt S5box qType := by
  have h1 := A5_typeEntropy_bracket.2
  have h2 := S5_typeEntropy_bracket.1
  linarith

/-! ## 4. The abelianization law for `S₅` -/

/-- The sign of a permutation is a function of its cycle type: this is the arithmetic
statement that the quadratic character of the discriminant is readable from the
factorisation type. -/
theorem signDial_of_qType {σ τ : Perm (Fin 5)} (h : qType σ = qType τ) :
    signDial σ = signDial τ := by
  unfold signDial
  rw [Perm.sign_of_cycleType, Perm.sign_of_cycleType]
  unfold qType at h
  rw [h]

lemma sign_fiber_card :
    ∀ σ : Perm (Fin 5), (#{x ∈ S5box | signDial x = signDial σ} : ℕ) = 60 := by decide

/-- The abelianization dial of `S₅` carries exactly one bit. -/
theorem S5_signEntropy : uEnt S5box signDial = 1 := by
  have h := QuinticF20.uEnt_eq_logb_of_uniform_fibers (s := S5box) (g := signDial) (c := 60)
    ⟨1, by simp [S5box]⟩ (fun a _ => sign_fiber_card a)
  rw [h, card_S5box, show ((120 : ℕ) : ℝ) = 2 * ((60 : ℕ) : ℝ) by norm_num]
  exact logb_double (by norm_num)

/-- **The abelianization law at `S₅`.**  The seven-state splitting type transmits exactly one
bit — the quadratic-residue bit of the discriminant — and nothing else. -/
theorem abelianization_law_S5 : mutInfo S5box signDial qType = 1 := by
  rw [mutInfo_eq_uEnt_of_factors (fun x _ y _ h => signDial_of_qType h), S5_signEntropy]

/-! ## 5. The perfection of `A₅` and the two dial theorems -/

/-- An even permutation of five letters. -/
def evenA : Perm (Fin 5) := Equiv.swap 0 1 * Equiv.swap 1 2

/-- A second even permutation, not commuting with `evenA`. -/
def evenB : Perm (Fin 5) := Equiv.swap 0 1 * Equiv.swap 1 3

lemma sign_evenA : Perm.sign evenA = 1 := by decide

lemma sign_evenB : Perm.sign evenB = 1 := by decide

lemma evenA_mul_evenB_ne : evenA * evenB ≠ evenB * evenA := by decide

/-- `A₅` is not commutative. -/
theorem alternating_not_commutative :
    ¬ ∀ x y : alternatingGroup (Fin 5), x * y = y * x := by
  intro h
  have ha : evenA ∈ alternatingGroup (Fin 5) := Perm.mem_alternatingGroup.2 sign_evenA
  have hb : evenB ∈ alternatingGroup (Fin 5) := Perm.mem_alternatingGroup.2 sign_evenB
  exact evenA_mul_evenB_ne (congrArg Subtype.val (h ⟨evenA, ha⟩ ⟨evenB, hb⟩))

/-- **The engine: `A₅` is perfect.**  Every homomorphism from `A₅` into an abelian group is
trivial.  Simplicity forces the kernel to be `⊥` or `⊤`, and `⊥` would make `A₅` abelian. -/
theorem alternating_hom_trivial {M : Type*} [CommGroup M]
    (ψ : alternatingGroup (Fin 5) →* M) (x : alternatingGroup (Fin 5)) : ψ x = 1 := by
  rcases IsSimpleGroup.eq_bot_or_eq_top_of_normal ψ.ker (MonoidHom.normal_ker ψ) with hker | hker
  · exfalso
    have hinj : Function.Injective ψ := (MonoidHom.ker_eq_bot_iff ψ).1 hker
    refine alternating_not_commutative fun a b => hinj ?_
    rw [map_mul, map_mul, mul_comm]
  · have hx : x ∈ ψ.ker := by rw [hker]; exact Subgroup.mem_top x
    exact hx

/-- **The `A₅` seal, pointwise.**  Any multiplicative read-out of the Frobenius into an
abelian group is constant on the `A₅` box. -/
theorem A5_dial_const {M : Type*} [CommGroup M] (d : Perm (Fin 5) → M)
    (hd : ∀ x ∈ A5box, ∀ y ∈ A5box, d (x * y) = d x * d y)
    {x y : Perm (Fin 5)} (hx : x ∈ A5box) (hy : y ∈ A5box) : d x = d y := by
  have hmul : ∀ a b : alternatingGroup (Fin 5),
      d ((a * b : alternatingGroup (Fin 5)) : Perm (Fin 5)) = d (a : Perm (Fin 5)) * d b :=
    fun a b => hd a (mem_A5box.2 (Perm.mem_alternatingGroup.1 a.2)) b
      (mem_A5box.2 (Perm.mem_alternatingGroup.1 b.2))
  let ψ : alternatingGroup (Fin 5) →* M :=
    { toFun := fun a => d (a : Perm (Fin 5))
      map_one' := by
        have h := hmul 1 1
        simp only [mul_one, OneMemClass.coe_one] at h
        have h' : d 1 * 1 = d 1 * d 1 := by rw [mul_one]; exact h
        exact (mul_left_cancel h').symm
      map_mul' := hmul }
  have hx' : x ∈ alternatingGroup (Fin 5) := Perm.mem_alternatingGroup.2 (mem_A5box.1 hx)
  have hy' : y ∈ alternatingGroup (Fin 5) := Perm.mem_alternatingGroup.2 (mem_A5box.1 hy)
  have h1 : ψ ⟨x, hx'⟩ = 1 := alternating_hom_trivial ψ _
  have h2 : ψ ⟨y, hy'⟩ = 1 := alternating_hom_trivial ψ _
  simpa [ψ] using h1.trans h2.symm

/-- **The complete seal of the `A₅` type channel.**  No abelian (residue) dial can hear
anything about *any* read-out of the Frobenius, nor be heard by it: the mutual information is
exactly `0`, with no parameter to tune. -/
theorem A5_seal {M : Type*} [CommGroup M] [DecidableEq M] {β : Type*} [DecidableEq β]
    (d : Perm (Fin 5) → M) (T : Perm (Fin 5) → β)
    (hd : ∀ x ∈ A5box, ∀ y ∈ A5box, d (x * y) = d x * d y) :
    mutInfo A5box d T = 0 :=
  mutInfo_eq_zero_of_const T fun _ hx _ hy => A5_dial_const d hd hx hy

/-- In particular the sign dial of `A₅` is dead: `I(sign ; T) = 0`, against the
`I(sign ; T) = 1` of `S₅`. -/
theorem A5_sign_seal : mutInfo A5box signDial qType = 0 := by
  refine mutInfo_eq_zero_of_const qType fun x hx y hy => ?_
  unfold signDial
  rw [mem_A5box.1 hx, mem_A5box.1 hy]

/-! ## 6. The sharp form of the law at `S₅`: every abelian dial is capped at one bit -/

section AbelianDial

variable {M : Type*} [CommGroup M] [DecidableEq M]

omit [DecidableEq M] in
/-- Every homomorphism from `S₅` into an abelian group kills the even permutations. -/
theorem S5_hom_trivial_on_even (φ : Perm (Fin 5) →* M) {σ : Perm (Fin 5)}
    (hσ : Perm.sign σ = 1) : φ σ = 1 :=
  alternating_hom_trivial (φ.comp (alternatingGroup (Fin 5)).subtype)
    ⟨σ, Perm.mem_alternatingGroup.2 hσ⟩

omit [DecidableEq M] in
/-- Every homomorphism from `S₅` into an abelian group factors through the sign. -/
theorem S5_hom_factors_sign (φ : Perm (Fin 5) →* M) {x y : Perm (Fin 5)}
    (h : Perm.sign x = Perm.sign y) : φ x = φ y := by
  have hsign : Perm.sign (x * y⁻¹) = 1 := by
    rw [map_mul, map_inv, h, mul_inv_cancel]
  have h1 := S5_hom_trivial_on_even φ hsign
  rw [map_mul, map_inv] at h1
  exact mul_inv_eq_one.mp h1

omit [DecidableEq M] in
/-- An abelian dial on `S₅` is a function of the splitting type. -/
theorem S5_hom_factors_qType (φ : Perm (Fin 5) →* M) {x y : Perm (Fin 5)}
    (h : qType x = qType y) : φ x = φ y :=
  S5_hom_factors_sign φ (signDial_of_qType h)

/-- The information an abelian dial receives from the splitting type is its own entropy. -/
theorem S5_abelian_dial_mutInfo (φ : Perm (Fin 5) →* M) :
    mutInfo S5box (fun σ => φ σ) qType = uEnt S5box (fun σ => φ σ) :=
  mutInfo_eq_uEnt_of_factors fun _ _ _ _ h => S5_hom_factors_qType φ h

omit [DecidableEq M] in
/-- If the dial is nontrivial, its fibres are exactly the two cosets of `A₅`. -/
theorem S5_nontrivial_hom_fiber (φ : Perm (Fin 5) →* M) (hφ : ∃ τ, φ τ ≠ 1)
    {x y : Perm (Fin 5)} : φ x = φ y ↔ Perm.sign x = Perm.sign y := by
  obtain ⟨τ, hτ⟩ := hφ
  have hτodd : Perm.sign τ = -1 :=
    (Int.units_eq_one_or _).resolve_left fun h => hτ (S5_hom_trivial_on_even φ h)
  refine ⟨fun h => ?_, fun h => S5_hom_factors_sign φ h⟩
  by_contra hne
  have hu : Perm.sign (x * y⁻¹) ≠ 1 := by
    rw [map_mul, map_inv]
    exact fun hc => hne (by rwa [mul_inv_eq_one] at hc)
  have hxy : Perm.sign (x * y⁻¹) = -1 := (Int.units_eq_one_or _).resolve_left hu
  have hev : Perm.sign (x * y⁻¹ * τ⁻¹) = 1 := by
    rw [map_mul, hxy, map_inv, hτodd]
    decide
  have h1 : φ (x * y⁻¹ * τ⁻¹) = 1 := S5_hom_trivial_on_even φ hev
  rw [map_mul, map_mul, map_inv, map_inv, h] at h1
  simp only [mul_inv_cancel, one_mul, inv_eq_one] at h1
  exact hτ h1

/-- **The sharp abelianization law at `S₅`.**  For every homomorphism of `S₅` into an abelian
group the splitting type transmits exactly one bit if the dial is nontrivial, and nothing at
all if it is trivial: the channel has no intermediate regime. -/
theorem S5_abelian_dial_dichotomy (φ : Perm (Fin 5) →* M) :
    mutInfo S5box (fun σ => φ σ) qType = if (∃ τ, φ τ ≠ 1) then 1 else 0 := by
  rw [S5_abelian_dial_mutInfo]
  by_cases hφ : ∃ τ, φ τ ≠ 1
  · rw [if_pos hφ]
    have hfib : ∀ a ∈ S5box, (#{x ∈ S5box | φ x = φ a} : ℕ) = 60 := by
      intro a _
      have hset : ({x ∈ S5box | φ x = φ a} : Finset (Perm (Fin 5)))
          = {x ∈ S5box | signDial x = signDial a} := by
        ext x
        simp only [mem_filter, signDial]
        exact and_congr_right fun _ => S5_nontrivial_hom_fiber φ hφ
      rw [hset, sign_fiber_card]
    have h := QuinticF20.uEnt_eq_logb_of_uniform_fibers (s := S5box) (g := fun σ => φ σ)
      (c := 60) ⟨1, by simp [S5box]⟩ hfib
    rw [h, card_S5box, show ((120 : ℕ) : ℝ) = 2 * ((60 : ℕ) : ℝ) by norm_num]
    exact logb_double (by norm_num)
  · rw [if_neg hφ]
    push_neg at hφ
    exact uEnt_eq_zero_of_const fun x _ y _ => by rw [hφ x, hφ y]

/-- The cap: no abelian dial of `S₅` can receive more than one bit from the splitting type. -/
theorem S5_abelian_dial_le_one (φ : Perm (Fin 5) →* M) :
    mutInfo S5box (fun σ => φ σ) qType ≤ 1 := by
  rw [S5_abelian_dial_dichotomy]
  split <;> norm_num

end AbelianDial

/-! ## 7. The semiprime pair channel -/

/-- The box of semiprime pairs: two independent Frobenius elements. -/
def S5pairBox : Finset (Perm (Fin 5) × Perm (Fin 5)) := S5box ×ˢ S5box

/-- The pair type read-out of a semiprime `N = p q`. -/
def qTypePair (p : Perm (Fin 5) × Perm (Fin 5)) : Multiset ℕ × Multiset ℕ :=
  (qType p.1, qType p.2)

/-- The dial of the semiprime `N = p q`: the product of the two quadratic characters. -/
def pairSignDial (p : Perm (Fin 5) × Perm (Fin 5)) : ℤˣ := signDial p.1 * signDial p.2

lemma card_S5pairBox : (#S5pairBox : ℕ) = 14400 := by
  rw [S5pairBox, Finset.card_product, card_S5box]

lemma sign_value_fiber : ∀ v : ℤˣ, (#{x ∈ S5box | signDial x = v} : ℕ) = 60 := by decide

lemma pairSign_fiber_card (p : Perm (Fin 5) × Perm (Fin 5)) :
    (#{x ∈ S5pairBox | pairSignDial x = pairSignDial p} : ℕ) = 7200 := by
  classical
  have hsplit : ({x ∈ S5pairBox | pairSignDial x = pairSignDial p} : Finset _)
      = S5box.biUnion (fun a => ({a} : Finset (Perm (Fin 5))) ×ˢ
          {b ∈ S5box | signDial b = (signDial a)⁻¹ * pairSignDial p}) := by
    ext ⟨a, b⟩
    simp only [S5pairBox, mem_filter, mem_product, mem_biUnion, mem_singleton, pairSignDial]
    constructor
    · rintro ⟨⟨ha, hb⟩, h⟩
      refine ⟨a, ha, ⟨rfl, hb, ?_⟩⟩
      rw [← h]
      group
    · rintro ⟨a', ha', ⟨rfl, hb, h⟩⟩
      refine ⟨⟨ha', hb⟩, ?_⟩
      rw [h]
      group
  rw [hsplit, Finset.card_biUnion]
  · have hterm : ∀ a ∈ S5box, (#(({a} : Finset (Perm (Fin 5))) ×ˢ
        {b ∈ S5box | signDial b = (signDial a)⁻¹ * pairSignDial p}) : ℕ) = 60 := by
      intro a _
      rw [Finset.card_product, Finset.card_singleton, one_mul, sign_value_fiber]
    rw [Finset.sum_congr rfl hterm]
    simp [card_S5box]
  · intro a _ b _ hab
    simp only [Finset.disjoint_left, mem_product, mem_singleton]
    rintro ⟨x, y⟩ ⟨hx, _⟩ ⟨hx', _⟩
    exact hab (hx ▸ hx')

/-- The semiprime dial carries exactly one bit. -/
theorem S5_pairSign_entropy : uEnt S5pairBox pairSignDial = 1 := by
  have h := QuinticF20.uEnt_eq_logb_of_uniform_fibers (s := S5pairBox) (g := pairSignDial)
    (c := 7200) ⟨(1, 1), by simp [S5pairBox, S5box]⟩ (fun a _ => pairSign_fiber_card a)
  rw [h, card_S5pairBox, show ((14400 : ℕ) : ℝ) = 2 * ((7200 : ℕ) : ℝ) by norm_num]
  exact logb_double (by norm_num)

/-- **The semiprime pair law at `S₅`.**  The pair of splitting types transmits exactly one
bit about the semiprime's quadratic character — the same one bit, no pair bonus. -/
theorem S5_pair_law : mutInfo S5pairBox pairSignDial qTypePair = 1 := by
  rw [mutInfo_eq_uEnt_of_factors (g := pairSignDial) (k := qTypePair) ?_, S5_pairSign_entropy]
  rintro ⟨x₁, x₂⟩ _ ⟨y₁, y₂⟩ _ h
  have h1 : qType x₁ = qType y₁ := congrArg Prod.fst h
  have h2 : qType x₂ = qType y₂ := congrArg Prod.snd h
  simp only [pairSignDial]
  rw [signDial_of_qType h1, signDial_of_qType h2]

/-- The `A₅` semiprime pair box. -/
def A5pairBox : Finset (Perm (Fin 5) × Perm (Fin 5)) := A5box ×ˢ A5box

/-- **The semiprime pair seal at `A₅`.**  Even at the pair level the abelian dial is dead. -/
theorem A5_pair_seal : mutInfo A5pairBox pairSignDial qTypePair = 0 := by
  refine mutInfo_eq_zero_of_const qTypePair fun x hx y hy => ?_
  rw [A5pairBox, mem_product] at hx hy
  unfold pairSignDial signDial
  rw [mem_A5box.1 hx.1, mem_A5box.1 hx.2, mem_A5box.1 hy.1, mem_A5box.1 hy.2]

end QuinticS5A5