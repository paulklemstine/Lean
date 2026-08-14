/-
# The semiprime dial for an arbitrary finite Galois group

`ForkPinningSemiprime` computed the semiprime-level dial for the conductor-7 cyclic cubic,
where the class group of the fork is `C₃`.  This file proves the **general** statement: for an
*arbitrary* finite group `G` (the abelianized Frobenius data of the two prime factors of the
semiprime `N = p q`) with

* observable `prodClass (a, b) = a * b`   (the class of `N`, the product of the two classes),
* fork `splitORG (a, b) = [a = 1 ∨ b = 1]`  (`p` splits **or** `q` splits),
* factor label `firstFactor F (a, b) = F a` (any statistic of the first prime alone),

the exact information content of the semiprime dial is a universal function of `n = |G|`:

`I = log n + ( −(2n−1) log(2n−1) + (n−1)(3−2n) log(n−1) + 2(n−1) log 2
                + (n−1)(n−2) log(n−2) ) / n²`.

Main results:

* `ForkPinning.semiprime_OR_mutualInfo_general` : the closed form above, for every finite group.
* `ForkPinning.semiprime_general_card_three` : specialising to `n = 3` recovers the measured
  cyclic-cubic value `log 3 − (5/9) log 5 − (2/9) log 2` (0.0728 bits).
* `ForkPinning.which_factor_wall_general` : **the which-factor wall is exact in every finite
  group** — the class of `N` is independent of *any* statistic of the first factor.
* `ForkPinning.semiprime_OR_never_pinned` and `ForkPinning.semiprime_OR_mutualInfo_pos` :
  the dial is genuine but always partial: `0 < I < H(fork)` as soon as `|G| ≥ 2`.
-/

import Probability.ForkPinningProduct
import Probability.ForkPinningSemiprime

namespace ForkPinning

open Finset Real

/-! ## Two toolkit lemmas -/

section Toolkit

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]
variable {κ β : Type*} [Fintype κ] [DecidableEq κ] [Fintype β] [DecidableEq β]

omit [Nonempty Ω] [Fintype β] in
/-- The second marginal of the joint law. -/
lemma sum_prb_joint_right (X : Ω → κ) (Y : Ω → β) (b : β) :
    ∑ k : κ, prb (joint X Y) (k, b) = prb Y b := by
  simp_rw [← prb_joint_swap X Y]
  exact sum_prb_joint Y X b

end Toolkit

/-- `negMulLog` of a ratio, allowing a vanishing numerator. -/
lemma negMulLog_div_nonneg (c N : ℝ) (hc : 0 ≤ c) (hN : 0 < N) :
    negMulLog (c / N) = (c / N) * Real.log N - (c / N) * Real.log c := by
  rcases eq_or_lt_of_le hc with h | h
  · simp [negMulLog, ← h]
  · rw [negMulLog, Real.log_div (ne_of_gt h) (ne_of_gt hN)]
    ring

/-! ## The general semiprime model -/

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The class of the semiprime `N = p q`: the product of the two prime classes. -/
def prodClass (x : G × G) : G := x.1 * x.2

/-- The accessible fork: `p` splits **or** `q` splits (split = trivial class). -/
def splitORG (x : G × G) : Bool := decide (x.1 = 1 ∨ x.2 = 1)

omit [Group G] [DecidableEq G] in
lemma card_prod_self : (Fintype.card (G × G) : ℝ) = Fintype.card G * Fintype.card G := by
  rw [Fintype.card_prod]; push_cast; ring

omit [DecidableEq G] in
lemma card_G_pos : (0 : ℝ) < Fintype.card G := by
  exact_mod_cast Fintype.card_pos

/-! ### Fibre counts -/

lemma fiber_prodClass (s : G) :
    fiber (prodClass : G × G → G) s = univ.image (fun a : G => (a, a⁻¹ * s)) := by
  ext ⟨a, b⟩
  simp only [fiber, mem_filter, mem_univ, true_and, mem_image, prodClass, Prod.mk.injEq]
  constructor
  · intro h
    exact ⟨a, rfl, by rw [← h]; group⟩
  · rintro ⟨c, rfl, rfl⟩
    group

lemma card_fiber_prodClass (s : G) :
    (fiber (prodClass : G × G → G) s).card = Fintype.card G := by
  rw [fiber_prodClass, Finset.card_image_of_injective _ (fun a a' h => congrArg Prod.fst h),
    Finset.card_univ]

lemma prb_prodClass (s : G) :
    prb (prodClass : G × G → G) s = 1 / Fintype.card G := by
  rw [prb, card_fiber_prodClass, card_prod_self]
  field_simp

/-- The `OR`-true fibre over the trivial class is the single point `(1,1)`. -/
lemma fiber_joint_true_one :
    fiber (joint (prodClass : G × G → G) splitORG) (1, true) = {((1 : G), (1 : G))} := by
  ext ⟨a, b⟩
  simp only [fiber, mem_filter, mem_univ, true_and, joint, prodClass, splitORG,
    Prod.mk.injEq, mem_singleton, decide_eq_true_eq]
  constructor
  · rintro ⟨hab, ha | hb⟩
    · subst ha; simp only [one_mul] at hab; simp [hab]
    · subst hb; simp only [mul_one] at hab; simp [hab]
  · rintro ⟨rfl, rfl⟩
    exact ⟨by simp, Or.inl rfl⟩

/-- Over a non-trivial class `s` the `OR`-true fibre is `{(1,s), (s,1)}`. -/
lemma fiber_joint_true_ne {s : G} (hs : s ≠ 1) :
    fiber (joint (prodClass : G × G → G) splitORG) (s, true) = {((1 : G), s), (s, (1 : G))} := by
  ext ⟨a, b⟩
  simp only [fiber, mem_filter, mem_univ, true_and, joint, prodClass, splitORG,
    Prod.mk.injEq, mem_insert, mem_singleton, decide_eq_true_eq]
  constructor
  · rintro ⟨hab, ha | hb⟩
    · subst ha; exact Or.inl ⟨rfl, by simpa using hab⟩
    · subst hb; exact Or.inr ⟨by simpa using hab, rfl⟩
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · exact ⟨by simp, Or.inl rfl⟩
    · exact ⟨by simp, Or.inr rfl⟩

lemma card_fiber_true_one :
    ((fiber (joint (prodClass : G × G → G) splitORG) (1, true)).card : ℝ) = 1 := by
  rw [fiber_joint_true_one, Finset.card_singleton]; norm_num

lemma card_fiber_true_ne {s : G} (hs : s ≠ 1) :
    ((fiber (joint (prodClass : G × G → G) splitORG) (s, true)).card : ℝ) = 2 := by
  rw [fiber_joint_true_ne hs, Finset.card_insert_of_notMem (by simp [Prod.ext_iff, hs]),
    Finset.card_singleton]
  norm_num

/-- The two `OR`-fibres over a class `s` partition the fibre of the observable. -/
lemma card_fiber_true_add_false (s : G) :
    (fiber (joint (prodClass : G × G → G) splitORG) (s, true)).card
      + (fiber (joint (prodClass : G × G → G) splitORG) (s, false)).card = Fintype.card G := by
  rw [fiber_joint, fiber_joint, ← card_fiber_prodClass s]
  classical
  have := Finset.card_filter_add_card_filter_not
    (s := fiber (prodClass : G × G → G) s) (p := fun ω => splitORG ω = true)
  simpa using this

lemma card_fiber_false_one :
    ((fiber (joint (prodClass : G × G → G) splitORG) (1, false)).card : ℝ)
      = Fintype.card G - 1 := by
  have h := card_fiber_true_add_false (1 : G)
  have h' : ((fiber (joint (prodClass : G × G → G) splitORG) (1, true)).card : ℝ)
      + ((fiber (joint (prodClass : G × G → G) splitORG) (1, false)).card : ℝ)
      = (Fintype.card G : ℝ) := by exact_mod_cast h
  rw [card_fiber_true_one] at h'
  linarith

lemma card_fiber_false_ne {s : G} (hs : s ≠ 1) :
    ((fiber (joint (prodClass : G × G → G) splitORG) (s, false)).card : ℝ)
      = Fintype.card G - 2 := by
  have h := card_fiber_true_add_false s
  have h' : ((fiber (joint (prodClass : G × G → G) splitORG) (s, true)).card : ℝ)
      + ((fiber (joint (prodClass : G × G → G) splitORG) (s, false)).card : ℝ)
      = (Fintype.card G : ℝ) := by exact_mod_cast h
  rw [card_fiber_true_ne hs] at h'
  linarith

/-! ### Probabilities -/

lemma prb_joint_true_one :
    prb (joint (prodClass : G × G → G) splitORG) (1, true)
      = 1 / ((Fintype.card G : ℝ) * Fintype.card G) := by
  rw [prb, card_prod_self, card_fiber_true_one]

lemma prb_joint_false_one :
    prb (joint (prodClass : G × G → G) splitORG) (1, false)
      = ((Fintype.card G : ℝ) - 1) / ((Fintype.card G : ℝ) * Fintype.card G) := by
  rw [prb, card_prod_self, card_fiber_false_one]

lemma prb_joint_true_ne {s : G} (hs : s ≠ 1) :
    prb (joint (prodClass : G × G → G) splitORG) (s, true)
      = 2 / ((Fintype.card G : ℝ) * Fintype.card G) := by
  rw [prb, card_prod_self, card_fiber_true_ne hs]

lemma prb_joint_false_ne {s : G} (hs : s ≠ 1) :
    prb (joint (prodClass : G × G → G) splitORG) (s, false)
      = ((Fintype.card G : ℝ) - 2) / ((Fintype.card G : ℝ) * Fintype.card G) := by
  rw [prb, card_prod_self, card_fiber_false_ne hs]

/-- Splitting a sum over `G` off the identity element. -/
lemma sum_split_one {M : Type*} [AddCommMonoid M] (f : G → M) :
    ∑ s : G, f s = f 1 + ∑ s ∈ univ.erase (1 : G), f s :=
  (Finset.add_sum_erase _ f (mem_univ 1)).symm

lemma card_erase_one : ((univ.erase (1 : G)).card : ℝ) = (Fintype.card G : ℝ) - 1 := by
  rw [Finset.card_erase_of_mem (mem_univ 1), Finset.card_univ]
  have : 1 ≤ Fintype.card G := Fintype.card_pos
  push_cast [Nat.cast_sub this]
  ring

lemma prb_splitORG_true :
    prb (splitORG : G × G → Bool) true
      = (2 * (Fintype.card G : ℝ) - 1) / ((Fintype.card G : ℝ) * Fintype.card G) := by
  rw [← sum_prb_joint_right (prodClass : G × G → G) splitORG true, sum_split_one,
    prb_joint_true_one]
  rw [Finset.sum_congr rfl (fun s hs => prb_joint_true_ne (G := G)
      (Finset.ne_of_mem_erase hs)), Finset.sum_const, nsmul_eq_mul, card_erase_one]
  have hn := card_G_pos (G := G)
  field_simp
  ring

lemma prb_splitORG_false :
    prb (splitORG : G × G → Bool) false
      = ((Fintype.card G : ℝ) - 1) * ((Fintype.card G : ℝ) - 1)
          / ((Fintype.card G : ℝ) * Fintype.card G) := by
  have hsum : prb (splitORG : G × G → Bool) false + prb (splitORG : G × G → Bool) true = 1 := by
    have := sum_prb (splitORG : G × G → Bool)
    rw [Fintype.sum_bool] at this
    linarith
  have hn := card_G_pos (G := G)
  rw [prb_splitORG_true] at hsum
  field_simp at hsum ⊢
  nlinarith [hsum]

/-! ### Entropies -/

lemma entropy_prodClass_general :
    H (prodClass : G × G → G) = Real.log (Fintype.card G) := by
  have hn := card_G_pos (G := G)
  unfold H
  rw [Finset.sum_congr rfl (fun s _ => by
        rw [prb_prodClass (G := G) s, negMulLog_div_nonneg 1 _ (by norm_num) hn]),
    Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  rw [Real.log_one]
  field_simp
  ring

/-- The joint entropy of (class of `N`, `OR`), in closed form. -/
lemma entropy_joint_general (hn2 : 2 ≤ Fintype.card G) :
    H (joint (prodClass : G × G → G) splitORG)
      = (((Fintype.card G : ℝ) - 1) / ((Fintype.card G : ℝ) * Fintype.card G)
            * Real.log ((Fintype.card G : ℝ) * Fintype.card G)
          - ((Fintype.card G : ℝ) - 1) / ((Fintype.card G : ℝ) * Fintype.card G)
            * Real.log ((Fintype.card G : ℝ) - 1)
          + (1 / ((Fintype.card G : ℝ) * Fintype.card G)
            * Real.log ((Fintype.card G : ℝ) * Fintype.card G)))
        + ((Fintype.card G : ℝ) - 1) *
          (((Fintype.card G : ℝ) - 2) / ((Fintype.card G : ℝ) * Fintype.card G)
              * Real.log ((Fintype.card G : ℝ) * Fintype.card G)
            - ((Fintype.card G : ℝ) - 2) / ((Fintype.card G : ℝ) * Fintype.card G)
              * Real.log ((Fintype.card G : ℝ) - 2)
            + (2 / ((Fintype.card G : ℝ) * Fintype.card G)
                * Real.log ((Fintype.card G : ℝ) * Fintype.card G)
              - 2 / ((Fintype.card G : ℝ) * Fintype.card G) * Real.log 2)) := by
  have hn := card_G_pos (G := G)
  have h2 : (2 : ℝ) ≤ (Fintype.card G : ℝ) := by exact_mod_cast hn2
  have hN : (0 : ℝ) < (Fintype.card G : ℝ) * Fintype.card G := by positivity
  have hB : ∀ s ∈ univ.erase (1 : G),
      negMulLog (prb (joint (prodClass : G × G → G) splitORG) (s, true))
        + negMulLog (prb (joint (prodClass : G × G → G) splitORG) (s, false))
      = (((Fintype.card G : ℝ) - 2) / ((Fintype.card G : ℝ) * Fintype.card G)
            * Real.log ((Fintype.card G : ℝ) * Fintype.card G)
          - ((Fintype.card G : ℝ) - 2) / ((Fintype.card G : ℝ) * Fintype.card G)
            * Real.log ((Fintype.card G : ℝ) - 2))
        + (2 / ((Fintype.card G : ℝ) * Fintype.card G)
            * Real.log ((Fintype.card G : ℝ) * Fintype.card G)
          - 2 / ((Fintype.card G : ℝ) * Fintype.card G) * Real.log 2) := by
    intro s hs
    rw [prb_joint_false_ne (Finset.ne_of_mem_erase hs),
      prb_joint_true_ne (Finset.ne_of_mem_erase hs),
      negMulLog_div_nonneg ((Fintype.card G : ℝ) - 2) _ (by linarith) hN,
      negMulLog_div_nonneg 2 _ (by norm_num) hN]
    ring
  rw [entropy_joint_eq]
  simp_rw [Fintype.sum_bool]
  rw [sum_split_one, prb_joint_false_one, prb_joint_true_one,
    negMulLog_div_nonneg ((Fintype.card G : ℝ) - 1) _ (by linarith) hN,
    negMulLog_div_nonneg 1 _ (by norm_num) hN,
    Finset.sum_congr rfl hB, Finset.sum_const, nsmul_eq_mul, card_erase_one, Real.log_one]
  ring

/-! ## The main theorem -/

/-- **The universal semiprime dial.**  For every finite group `G` of order `n ≥ 2` the
information the class of the semiprime `N = p q` carries about the fork
`[p splits] ∨ [q splits]` equals
`log n + ( −(2n−1) log(2n−1) + (n−1)(3−2n) log(n−1) + 2(n−1) log 2 + (n−1)(n−2) log(n−2) ) / n²`.
-/
theorem semiprime_OR_mutualInfo_general (n : ℝ) (hcard : (Fintype.card G : ℝ) = n)
    (hn : 2 ≤ n) :
    mutualInfo (prodClass : G × G → G) splitORG
      = Real.log n
        + (-(2 * n - 1) * Real.log (2 * n - 1)
            + (n - 1) * (3 - 2 * n) * Real.log (n - 1)
            + 2 * (n - 1) * Real.log 2
            + (n - 1) * (n - 2) * Real.log (n - 2)) / (n * n) := by
  have hn0 : (0 : ℝ) < n := by linarith
  have hn2 : 2 ≤ Fintype.card G := by
    have : (2 : ℝ) ≤ (Fintype.card G : ℝ) := by rw [hcard]; exact hn
    exact_mod_cast this
  have hN : (0 : ℝ) < (Fintype.card G : ℝ) * Fintype.card G := by
    rw [hcard]; positivity
  rw [mutualInfo, entropy_prodClass_general, H_bool, prb_splitORG_true, prb_splitORG_false,
    entropy_joint_general hn2,
    negMulLog_div_nonneg (((Fintype.card G : ℝ) - 1) * ((Fintype.card G : ℝ) - 1)) _
      (by rw [hcard]; nlinarith) hN,
    negMulLog_div_nonneg (2 * (Fintype.card G : ℝ) - 1) _ (by rw [hcard]; linarith) hN,
    hcard]
  rw [Real.log_mul (ne_of_gt hn0) (ne_of_gt hn0),
    Real.log_mul (by linarith) (by linarith)]
  field_simp
  ring

/-- Specialising to `|G| = 3` recovers the cyclic-cubic value `0.0728` bits. -/
theorem semiprime_general_card_three (h : Fintype.card G = 3) :
    mutualInfo (prodClass : G × G → G) splitORG
      = Real.log 3 - (5 / 9) * Real.log 5 - (2 / 9) * Real.log 2 := by
  rw [semiprime_OR_mutualInfo_general 3 (by rw [h]; norm_num) (by norm_num)]
  norm_num
  ring

/-! ## The which-factor wall, in every finite group -/

/-- **The which-factor wall is exact in every finite group.**  The class of the semiprime `N`
is independent of *any* statistic of the first prime factor, so it carries exactly zero
information about which factor is the split one. -/
theorem which_factor_wall_general {β : Type*} [Fintype β] [DecidableEq β] (F : G → β) :
    mutualInfo (prodClass : G × G → G) (fun x : G × G => F x.1) = 0 := by
  have hn := card_G_pos (G := G)
  refine mutualInfo_eq_zero_of_indep _ _ (fun s v => ?_)
  have hset : fiber (joint (prodClass : G × G → G) (fun x : G × G => F x.1)) (s, v)
      = (fiber F v).image (fun a : G => (a, a⁻¹ * s)) := by
    ext ⟨a, b⟩
    simp only [fiber, mem_filter, mem_univ, true_and, joint, prodClass, mem_image,
      Prod.mk.injEq]
    constructor
    · rintro ⟨hab, hFa⟩
      exact ⟨a, by simpa [fiber] using hFa, rfl, by rw [← hab]; group⟩
    · rintro ⟨c, hc, rfl, rfl⟩
      refine ⟨by group, ?_⟩
      simpa [fiber] using hc
  have hcardset : (fiber (joint (prodClass : G × G → G) (fun x : G × G => F x.1)) (s, v)).card
      = (fiber F v).card := by
    rw [hset, Finset.card_image_of_injective _ (fun a a' h => congrArg Prod.fst h)]
  rw [prb, hcardset, card_prod_self, prb_prodClass, prb_fst F v, prb]
  field_simp

/-! ## The dial is genuine but always partial -/

/-- The observable never determines the fork once `|G| ≥ 2`: the dial is strictly partial. -/
theorem semiprime_OR_never_pinned (hn : 2 ≤ Fintype.card G) :
    mutualInfo (prodClass : G × G → G) splitORG ≠ H (splitORG : G × G → Bool) := by
  rw [Ne, pinned_iff_determines]
  intro hdet
  obtain ⟨g, hg⟩ := Fintype.exists_ne_of_one_lt_card (by omega) (1 : G)
  have h := hdet ((1 : G), (1 : G)) (g, g⁻¹) (by simp [prodClass])
  simp only [splitORG, decide_eq_decide] at h
  have : g = 1 ∨ g⁻¹ = 1 := h.mp (Or.inl trivial)
  rcases this with h1 | h1
  · exact hg h1
  · exact hg (inv_eq_one.mp h1)

/-- The dial is nevertheless genuine: strictly positive information once `|G| ≥ 2`. -/
theorem semiprime_OR_mutualInfo_pos (hn : 2 ≤ Fintype.card G) :
    0 < mutualInfo (prodClass : G × G → G) splitORG := by
  have hn0 := card_G_pos (G := G)
  have h2 : (2 : ℝ) ≤ (Fintype.card G : ℝ) := by exact_mod_cast hn
  refine mutualInfo_pos_of_not_indep _ _ (fun hindep => ?_)
  have h := hindep 1 true
  rw [prb_joint_true_one, prb_prodClass, prb_splitORG_true] at h
  field_simp at h
  nlinarith [h]

end ForkPinning