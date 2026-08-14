/-
# Coarsening a character can only lose information (data processing), and the
# abelianization is the optimal congruence observable

The fork-pinning criterion says *which* forks a Dirichlet character can pin.  This file makes
the criterion **quantitative**: information about a fork can never be created by post-processing
the observable, so among all abelian characters of the Galois group the abelianization map
`G → G^ab` is the unique optimum:

* `ForkPinning.mutualInfo_comp_le` : the data-processing inequality
  `I(g ∘ X ; Y) ≤ I(X ; Y)` for the uniform measure on a finite space;
* `ForkPinning.mutualInfo_le_of_determines` : a coarser statistic carries less information;
* `ForkPinning.mutualInfo_le_abelianization` : **every** Dirichlet character `f : G →* A`
  satisfies `I(f ; Y) ≤ I(G^ab ; Y)` — no abelian character can beat the abelianization;
* `ForkPinning.abelianization_is_optimal` : the resulting sharp capacity statement, that the
  supremum over abelian characters of the pinned information is attained at `G^ab`.

The proof of the data-processing inequality is a grouped Gibbs argument: writing
`r = P(X = k, Y = b)`, `p = P(X = k)`, `q = P(gX = gk, Y = b)`, `P = P(gX = gk)`, the
elementary inequality `r log r − r log (q p / P) ≥ r − q p / P` is summed over all `(k, b)`;
the right-hand side telescopes to `0` and the left-hand side is exactly `I(X;Y) − I(gX;Y)`.
-/

import Probability.ForkPinningGalois

namespace ForkPinning

open Finset Real

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]
variable {κ κ' β : Type*} [Fintype κ] [DecidableEq κ] [Fintype κ'] [DecidableEq κ']
  [Fintype β] [DecidableEq β]

/-! ## Fibres of a post-processed statistic -/

omit [Nonempty Ω] [Fintype κ'] in
lemma card_fiber_comp (g : κ → κ') (X : Ω → κ) (k' : κ') :
    (fiber (fun ω => g (X ω)) k').card
      = ∑ k ∈ univ.filter (fun k => g k = k'), (fiber X k).card := by
  have hmaps : ∀ ω ∈ fiber (fun ω => g (X ω)) k', X ω ∈ univ.filter (fun k => g k = k') := by
    intro ω hω
    simp only [fiber, mem_filter, mem_univ, true_and] at hω ⊢
    exact hω
  have hfib : ∀ k ∈ univ.filter (fun k => g k = k'),
      (fiber (fun ω => g (X ω)) k').filter (fun ω => X ω = k) = fiber X k := by
    intro k hk
    simp only [mem_filter, mem_univ, true_and] at hk
    ext ω
    simp only [fiber, mem_filter, mem_univ, true_and]
    constructor
    · rintro ⟨-, h⟩; exact h
    · intro h; exact ⟨by rw [h, hk], h⟩
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  exact Finset.sum_congr rfl (fun k hk => by rw [hfib k hk])

omit [Nonempty Ω] [Fintype κ'] [Fintype β] in
lemma card_fiber_joint_comp (g : κ → κ') (X : Ω → κ) (Y : Ω → β) (k' : κ') (b : β) :
    (fiber (joint (fun ω => g (X ω)) Y) (k', b)).card
      = ∑ k ∈ univ.filter (fun k => g k = k'), (fiber (joint X Y) (k, b)).card := by
  have hmaps : ∀ ω ∈ fiber (joint (fun ω => g (X ω)) Y) (k', b),
      X ω ∈ univ.filter (fun k => g k = k') := by
    intro ω hω
    simp only [fiber, joint, mem_filter, mem_univ, true_and, Prod.mk.injEq] at hω ⊢
    exact hω.1
  have hfib : ∀ k ∈ univ.filter (fun k => g k = k'),
      (fiber (joint (fun ω => g (X ω)) Y) (k', b)).filter (fun ω => X ω = k)
        = fiber (joint X Y) (k, b) := by
    intro k hk
    simp only [mem_filter, mem_univ, true_and] at hk
    ext ω
    simp only [fiber, joint, mem_filter, mem_univ, true_and, Prod.mk.injEq]
    constructor
    · rintro ⟨⟨-, hb⟩, hk'⟩; exact ⟨hk', hb⟩
    · rintro ⟨hk', hb⟩; exact ⟨⟨by rw [hk', hk], hb⟩, hk'⟩
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  exact Finset.sum_congr rfl (fun k hk => by rw [hfib k hk])

omit [Nonempty Ω] [Fintype κ'] in
lemma prb_comp_eq_sum (g : κ → κ') (X : Ω → κ) (k' : κ') :
    prb (fun ω => g (X ω)) k' = ∑ k ∈ univ.filter (fun k => g k = k'), prb X k := by
  simp only [prb]
  rw [card_fiber_comp g X k', ← Finset.sum_div]
  push_cast
  ring

omit [Nonempty Ω] [Fintype κ'] [Fintype β] in
lemma prb_joint_comp_eq_sum (g : κ → κ') (X : Ω → κ) (Y : Ω → β) (k' : κ') (b : β) :
    prb (joint (fun ω => g (X ω)) Y) (k', b)
      = ∑ k ∈ univ.filter (fun k => g k = k'), prb (joint X Y) (k, b) := by
  simp only [prb]
  rw [card_fiber_joint_comp g X Y k' b, ← Finset.sum_div]
  push_cast
  ring

omit [Fintype κ'] in
lemma prb_le_prb_comp (g : κ → κ') (X : Ω → κ) (k : κ) :
    prb X k ≤ prb (fun ω => g (X ω)) (g k) := by
  rw [prb_comp_eq_sum g X (g k)]
  exact Finset.single_le_sum (f := fun k => prb X k) (fun i _ => prb_nonneg _ _)
    (by simp)

omit [Fintype κ'] [Fintype β] in
lemma prb_joint_le_prb_joint_comp (g : κ → κ') (X : Ω → κ) (Y : Ω → β) (k : κ) (b : β) :
    prb (joint X Y) (k, b) ≤ prb (joint (fun ω => g (X ω)) Y) (g k, b) := by
  rw [prb_joint_comp_eq_sum g X Y (g k) b]
  exact Finset.single_le_sum (f := fun k => prb (joint X Y) (k, b))
    (fun i _ => prb_nonneg _ _) (by simp)

/-! ## The elementary Gibbs term of the data-processing inequality -/

/-- `r log r − r log (q p / P) ≥ r − q p / P`, in the additively split form used below. -/
lemma dpi_term {r p q P : ℝ} (hr : 0 ≤ r) (hrp : r ≤ p) (hrq : r ≤ q) (hqP : q ≤ P)
    (hp : 0 ≤ p) (hP : 0 ≤ P) :
    r - q * p / P
      ≤ r * Real.log r - r * Real.log q - r * Real.log p + r * Real.log P := by
  rcases eq_or_lt_of_le hr with h0 | h0
  · have : 0 ≤ q * p / P := by
      have hq : 0 ≤ q := le_trans hr hrq
      positivity
    rw [← h0]
    simpa using this
  · have hp0 : 0 < p := lt_of_lt_of_le h0 hrp
    have hq0 : 0 < q := lt_of_lt_of_le h0 hrq
    have hP0 : 0 < P := lt_of_lt_of_le hq0 hqP
    have hu0 : 0 < q * p / P := by positivity
    have hlog : Real.log ((q * p / P) / r) ≤ (q * p / P) / r - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    have hsplit : Real.log ((q * p / P) / r)
        = Real.log q + Real.log p - Real.log P - Real.log r := by
      rw [Real.log_div (ne_of_gt hu0) (ne_of_gt h0), Real.log_div (by positivity) (ne_of_gt hP0),
        Real.log_mul (ne_of_gt hq0) (ne_of_gt hp0)]
    rw [hsplit] at hlog
    have hmul := mul_le_mul_of_nonneg_left hlog (le_of_lt h0)
    have hfield : r * ((q * p / P) / r - 1) = q * p / P - r := by field_simp
    nlinarith [hmul, hfield]

/-! ## The four sum identities -/

omit [Nonempty Ω] in
lemma sum_joint_log_joint (X : Ω → κ) (Y : Ω → β) :
    ∑ k : κ, ∑ b : β, prb (joint X Y) (k, b) * Real.log (prb (joint X Y) (k, b))
      = - H (joint X Y) := by
  rw [entropy_joint_eq]
  rw [← Finset.sum_neg_distrib]
  refine Finset.sum_congr rfl (fun k _ => ?_)
  rw [← Finset.sum_neg_distrib]
  exact Finset.sum_congr rfl (fun b _ => by rw [negMulLog]; ring)

omit [Nonempty Ω] in
lemma sum_joint_log_left (X : Ω → κ) (Y : Ω → β) :
    ∑ k : κ, ∑ b : β, prb (joint X Y) (k, b) * Real.log (prb X k) = - H X := by
  have h : ∀ k : κ, ∑ b : β, prb (joint X Y) (k, b) * Real.log (prb X k)
      = - negMulLog (prb X k) := by
    intro k
    rw [← Finset.sum_mul, sum_prb_joint X Y k, negMulLog]
    ring
  rw [Finset.sum_congr rfl (fun k _ => h k), Finset.sum_neg_distrib]
  rfl

omit [Nonempty Ω] in
lemma sum_joint_log_comp_left (g : κ → κ') (X : Ω → κ) (Y : Ω → β) :
    ∑ k : κ, ∑ b : β, prb (joint X Y) (k, b) * Real.log (prb (fun ω => g (X ω)) (g k))
      = - H (fun ω => g (X ω)) := by
  have hgroup : ∀ k' : κ', ∑ k ∈ univ.filter (fun k => g k = k'), ∑ b : β,
      prb (joint X Y) (k, b) * Real.log (prb (fun ω => g (X ω)) (g k))
      = - negMulLog (prb (fun ω => g (X ω)) k') := by
    intro k'
    have hinner : ∀ k ∈ univ.filter (fun k => g k = k'), ∑ b : β,
        prb (joint X Y) (k, b) * Real.log (prb (fun ω => g (X ω)) (g k))
        = prb X k * Real.log (prb (fun ω => g (X ω)) k') := by
      intro k hk
      simp only [mem_filter, mem_univ, true_and] at hk
      rw [hk, ← Finset.sum_mul, sum_prb_joint X Y k]
    rw [Finset.sum_congr rfl hinner, ← Finset.sum_mul, ← prb_comp_eq_sum g X k', negMulLog]
    ring
  rw [← Finset.sum_fiberwise_of_maps_to (g := g) (t := (univ : Finset κ'))
      (fun k _ => mem_univ (g k)),
    Finset.sum_congr rfl (fun k' _ => hgroup k'), Finset.sum_neg_distrib]
  rfl

omit [Nonempty Ω] in
lemma sum_joint_log_comp_joint (g : κ → κ') (X : Ω → κ) (Y : Ω → β) :
    ∑ k : κ, ∑ b : β,
        prb (joint X Y) (k, b) * Real.log (prb (joint (fun ω => g (X ω)) Y) (g k, b))
      = - H (joint (fun ω => g (X ω)) Y) := by
  have hgroup : ∀ k' : κ', ∑ k ∈ univ.filter (fun k => g k = k'), ∑ b : β,
      prb (joint X Y) (k, b) * Real.log (prb (joint (fun ω => g (X ω)) Y) (g k, b))
      = ∑ b : β, - negMulLog (prb (joint (fun ω => g (X ω)) Y) (k', b)) := by
    intro k'
    have hinner : ∀ k ∈ univ.filter (fun k => g k = k'), ∑ b : β,
        prb (joint X Y) (k, b) * Real.log (prb (joint (fun ω => g (X ω)) Y) (g k, b))
        = ∑ b : β,
            prb (joint X Y) (k, b) * Real.log (prb (joint (fun ω => g (X ω)) Y) (k', b)) := by
      intro k hk
      simp only [mem_filter, mem_univ, true_and] at hk
      rw [hk]
    rw [Finset.sum_congr rfl hinner, Finset.sum_comm]
    refine Finset.sum_congr rfl (fun b _ => ?_)
    rw [← Finset.sum_mul, ← prb_joint_comp_eq_sum g X Y k' b, negMulLog]
    ring
  rw [← Finset.sum_fiberwise_of_maps_to (g := g) (t := (univ : Finset κ'))
      (fun k _ => mem_univ (g k)),
    Finset.sum_congr rfl (fun k' _ => hgroup k'), entropy_joint_eq, ← Finset.sum_neg_distrib]
  exact Finset.sum_congr rfl (fun k' _ => by rw [Finset.sum_neg_distrib])

omit [Fintype κ'] in
/-- The right-hand sides of the Gibbs terms telescope to zero. -/
lemma sum_dpi_rhs_zero (g : κ → κ') (X : Ω → κ) (Y : Ω → β) :
    ∑ k : κ, ∑ b : β, (prb (joint X Y) (k, b)
        - prb (joint (fun ω => g (X ω)) Y) (g k, b) * prb X k
            / prb (fun ω => g (X ω)) (g k)) = 0 := by
  have hk : ∀ k : κ, ∑ b : β, (prb (joint X Y) (k, b)
      - prb (joint (fun ω => g (X ω)) Y) (g k, b) * prb X k
          / prb (fun ω => g (X ω)) (g k)) = 0 := by
    intro k
    rw [Finset.sum_sub_distrib, sum_prb_joint X Y k]
    have hmul : ∀ b : β, prb (joint (fun ω => g (X ω)) Y) (g k, b) * prb X k
        / prb (fun ω => g (X ω)) (g k)
        = prb (joint (fun ω => g (X ω)) Y) (g k, b)
            * (prb X k / prb (fun ω => g (X ω)) (g k)) := by
      intro b; ring
    rw [Finset.sum_congr rfl (fun b _ => hmul b), ← Finset.sum_mul,
      sum_prb_joint (fun ω => g (X ω)) Y (g k)]
    rcases eq_or_lt_of_le (prb_nonneg (fun ω => g (X ω)) (g k)) with h0 | h0
    · have hle := prb_le_prb_comp g X k
      have hk0 : prb X k = 0 := le_antisymm (by rw [← h0] at hle; exact hle) (prb_nonneg _ _)
      rw [hk0, ← h0]
      simp
    · field_simp
      ring
  rw [Finset.sum_congr rfl (fun k _ => hk k)]
  simp

/-! ## The data-processing inequality -/

/-- The **strict** Gibbs term: strict unless the fine cell is exactly the coarse cell rescaled. -/
lemma dpi_term_lt {r p q P : ℝ} (hr : 0 ≤ r) (hrp : r ≤ p) (hrq : r ≤ q) (hqP : q ≤ P)
    (hp : 0 ≤ p) (hne : r ≠ q * p / P) :
    r - q * p / P
      < r * Real.log r - r * Real.log q - r * Real.log p + r * Real.log P := by
  rcases eq_or_lt_of_le hr with h0 | h0
  · have hq : 0 ≤ q := le_trans hr hrq
    have hnn : 0 ≤ q * p / P := div_nonneg (mul_nonneg hq hp) (le_trans hq hqP)
    have hpos : 0 < q * p / P := lt_of_le_of_ne hnn (by rw [← h0] at hne; exact hne)
    rw [← h0]
    simpa using hpos
  · have hp0 : 0 < p := lt_of_lt_of_le h0 hrp
    have hq0 : 0 < q := lt_of_lt_of_le h0 hrq
    have hP0 : 0 < P := lt_of_lt_of_le hq0 hqP
    have hu0 : 0 < q * p / P := by positivity
    have hx1 : (q * p / P) / r ≠ 1 := by
      intro hx
      apply hne
      rw [eq_div_iff (ne_of_gt hP0)]
      field_simp at hx
      linear_combination -hx
    have hlog : Real.log ((q * p / P) / r) < (q * p / P) / r - 1 :=
      Real.log_lt_sub_one_of_pos (by positivity) hx1
    have hsplit : Real.log ((q * p / P) / r)
        = Real.log q + Real.log p - Real.log P - Real.log r := by
      rw [Real.log_div (ne_of_gt hu0) (ne_of_gt h0), Real.log_div (by positivity) (ne_of_gt hP0),
        Real.log_mul (ne_of_gt hq0) (ne_of_gt hp0)]
    rw [hsplit] at hlog
    have hmul := mul_lt_mul_of_pos_left hlog h0
    have hfield : r * ((q * p / P) / r - 1) = q * p / P - r := by field_simp
    nlinarith [hmul, hfield]

/-- The Gibbs term vanishes when the fine cell is the coarse cell rescaled. -/
lemma dpi_term_eq_zero {r p q P : ℝ} (hr : 0 ≤ r) (hrp : r ≤ p) (hrq : r ≤ q) (hqP : q ≤ P)
    (h : r = q * p / P) :
    r * Real.log r - r * Real.log q - r * Real.log p + r * Real.log P = 0 := by
  rcases eq_or_lt_of_le hr with h0 | h0
  · rw [← h0]; simp
  · have hp0 : 0 < p := lt_of_lt_of_le h0 hrp
    have hq0 : 0 < q := lt_of_lt_of_le h0 hrq
    have hP0 : 0 < P := lt_of_lt_of_le hq0 hqP
    have hlogr : Real.log r = Real.log q + Real.log p - Real.log P := by
      rw [h, Real.log_div (by positivity) (ne_of_gt hP0),
        Real.log_mul (ne_of_gt hq0) (ne_of_gt hp0)]
    rw [hlogr]; ring

/-- The pointwise information gap of the data-processing inequality: the amount by which the
cell `(k, b)` of the fine joint law fails to be the corresponding coarse cell rescaled. -/
noncomputable def dpiGap (g : κ → κ') (X : Ω → κ) (Y : Ω → β) (k : κ) (b : β) : ℝ :=
  (prb (joint X Y) (k, b) * Real.log (prb (joint X Y) (k, b))
      - prb (joint X Y) (k, b) * Real.log (prb (joint (fun ω => g (X ω)) Y) (g k, b))
      - prb (joint X Y) (k, b) * Real.log (prb X k)
      + prb (joint X Y) (k, b) * Real.log (prb (fun ω => g (X ω)) (g k)))
    - (prb (joint X Y) (k, b)
      - prb (joint (fun ω => g (X ω)) Y) (g k, b) * prb X k
          / prb (fun ω => g (X ω)) (g k))

omit [Fintype κ'] in
lemma dpiGap_nonneg (g : κ → κ') (X : Ω → κ) (Y : Ω → β) (k : κ) (b : β) :
    0 ≤ dpiGap g X Y k b :=
  sub_nonneg.mpr (dpi_term (prb_nonneg _ _) (prb_joint_le_left X Y k b)
    (prb_joint_le_prb_joint_comp g X Y k b)
    (prb_joint_le_left (fun ω => g (X ω)) Y (g k) b) (prb_nonneg _ _) (prb_nonneg _ _))

omit [Fintype κ'] in
lemma dpiGap_eq_zero_iff (g : κ → κ') (X : Ω → κ) (Y : Ω → β) (k : κ) (b : β) :
    dpiGap g X Y k b = 0
      ↔ prb (joint X Y) (k, b)
          = prb (joint (fun ω => g (X ω)) Y) (g k, b) * prb X k
              / prb (fun ω => g (X ω)) (g k) := by
  constructor
  · intro h
    by_contra hne
    have hlt := dpi_term_lt (prb_nonneg (joint X Y) (k, b)) (prb_joint_le_left X Y k b)
      (prb_joint_le_prb_joint_comp g X Y k b)
      (prb_joint_le_left (fun ω => g (X ω)) Y (g k) b) (prb_nonneg _ _) hne
    rw [dpiGap] at h
    linarith
  · intro h
    have hzero := dpi_term_eq_zero (prb_nonneg (joint X Y) (k, b)) (prb_joint_le_left X Y k b)
      (prb_joint_le_prb_joint_comp g X Y k b)
      (prb_joint_le_left (fun ω => g (X ω)) Y (g k) b) h
    rw [dpiGap, hzero, ← h]
    ring

/-- The total gap is exactly the information lost by post-processing. -/
lemma sum_dpiGap (g : κ → κ') (X : Ω → κ) (Y : Ω → β) :
    ∑ k : κ, ∑ b : β, dpiGap g X Y k b
      = mutualInfo X Y - mutualInfo (fun ω => g (X ω)) Y := by
  have hsplit : ∀ k : κ, ∑ b : β, dpiGap g X Y k b
      = (∑ b : β, prb (joint X Y) (k, b) * Real.log (prb (joint X Y) (k, b)))
        - (∑ b : β, prb (joint X Y) (k, b)
            * Real.log (prb (joint (fun ω => g (X ω)) Y) (g k, b)))
        - (∑ b : β, prb (joint X Y) (k, b) * Real.log (prb X k))
        + (∑ b : β, prb (joint X Y) (k, b) * Real.log (prb (fun ω => g (X ω)) (g k)))
        - (∑ b : β, (prb (joint X Y) (k, b)
            - prb (joint (fun ω => g (X ω)) Y) (g k, b) * prb X k
                / prb (fun ω => g (X ω)) (g k))) := by
    intro k
    simp only [dpiGap]
    rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      Finset.sum_sub_distrib]
  rw [Finset.sum_congr rfl (fun k _ => hsplit k), Finset.sum_sub_distrib, Finset.sum_add_distrib,
    Finset.sum_sub_distrib, Finset.sum_sub_distrib, sum_joint_log_joint X Y,
    sum_joint_log_comp_joint g X Y, sum_joint_log_left X Y, sum_joint_log_comp_left g X Y,
    sum_dpi_rhs_zero g X Y, mutualInfo, mutualInfo]
  ring

/-- **Data processing.**  Post-processing the observable can only destroy information about a
fork: `I(g ∘ X ; Y) ≤ I(X ; Y)`. -/
theorem mutualInfo_comp_le (g : κ → κ') (X : Ω → κ) (Y : Ω → β) :
    mutualInfo (fun ω => g (X ω)) Y ≤ mutualInfo X Y := by
  have h0 : 0 ≤ ∑ k : κ, ∑ b : β, dpiGap g X Y k b :=
    Finset.sum_nonneg (fun k _ => Finset.sum_nonneg (fun b _ => dpiGap_nonneg g X Y k b))
  rw [sum_dpiGap g X Y] at h0
  linarith

/-- **Equality in data processing detects sufficiency.**  The coarse observable `g ∘ X` retains
*all* of the information `X` has about the fork exactly when every fine cell of the joint law is
the corresponding coarse cell rescaled — i.e. when `g ∘ X` is a sufficient statistic for `Y`. -/
theorem mutualInfo_comp_eq_iff (g : κ → κ') (X : Ω → κ) (Y : Ω → β) :
    mutualInfo (fun ω => g (X ω)) Y = mutualInfo X Y
      ↔ ∀ k b, prb (joint X Y) (k, b)
          = prb (joint (fun ω => g (X ω)) Y) (g k, b) * prb X k
              / prb (fun ω => g (X ω)) (g k) := by
  constructor
  · intro heq k b
    have hzero : ∑ k : κ, ∑ b : β, dpiGap g X Y k b = 0 := by
      rw [sum_dpiGap g X Y, heq]; ring
    have hk := (Finset.sum_eq_zero_iff_of_nonneg
      (fun k _ => Finset.sum_nonneg (fun b _ => dpiGap_nonneg g X Y k b))).mp hzero k (mem_univ k)
    have hb := (Finset.sum_eq_zero_iff_of_nonneg
      (fun b _ => dpiGap_nonneg g X Y k b)).mp hk b (mem_univ b)
    exact (dpiGap_eq_zero_iff g X Y k b).mp hb
  · intro hsuff
    have hzero : ∑ k : κ, ∑ b : β, dpiGap g X Y k b = 0 :=
      Finset.sum_eq_zero (fun k _ => Finset.sum_eq_zero
        (fun b _ => (dpiGap_eq_zero_iff g X Y k b).mpr (hsuff k b)))
    rw [sum_dpiGap g X Y] at hzero
    linarith

/-- A coarser statistic carries less information: if `X` determines `X'` then
`I(X' ; Y) ≤ I(X ; Y)`. -/
theorem mutualInfo_le_of_determines [Inhabited κ'] (X : Ω → κ) (X' : Ω → κ') (Y : Ω → β)
    (h : Determines X X') : mutualInfo X' Y ≤ mutualInfo X Y := by
  obtain ⟨g, hg⟩ := (determines_iff_factors X X').mp h
  rw [hg]
  exact mutualInfo_comp_le g X Y

/-! ## The abelianization is the optimal congruence observable -/

section Galois

variable {G : Type*} [Group G] [Fintype G] [Nonempty G] [DecidableEq G]
variable {A : Type*} [CommGroup A] [Fintype A] [DecidableEq A]
variable [Fintype (Abelianization G)] [DecidableEq (Abelianization G)]

omit [DecidableEq G] in
/-- **No Dirichlet character can beat the abelianization.**  For every abelian character
`f : G →* A` of the Galois group and every fork `Y`, the information `f` carries about `Y`
is at most the information carried by the abelianization map `G → G^ab`. -/
theorem mutualInfo_le_abelianization (f : G →* A) (Y : G → β) :
    mutualInfo (fun g : G => f g) Y ≤ mutualInfo (fun g : G => Abelianization.of g) Y := by
  have hfac : (fun g : G => f g)
      = fun g : G => (Abelianization.lift f) (Abelianization.of g) := by
    funext g
    rw [Abelianization.lift_apply_of]
  rw [hfac]
  exact mutualInfo_comp_le (Abelianization.lift f) (fun g : G => Abelianization.of g) Y

omit [DecidableEq G] in
/-- **An injective character is exactly as good as the abelianization.**  If the character
`f : G →* A` induces an injective map on `G^ab` (equivalently, its kernel is precisely the
commutator subgroup), then it extracts the full abelian information about every fork. -/
theorem mutualInfo_eq_abelianization_of_injective (f : G →* A) (Y : G → β)
    (hinj : Function.Injective (Abelianization.lift f)) :
    mutualInfo (fun g : G => f g) Y = mutualInfo (fun g : G => Abelianization.of g) Y := by
  refine le_antisymm (mutualInfo_le_abelianization f Y) ?_
  haveI : Inhabited (Abelianization G) := ⟨1⟩
  refine mutualInfo_le_of_determines (fun g : G => f g) (fun g : G => Abelianization.of g) Y ?_
  intro w w' hw
  apply hinj
  rw [Abelianization.lift_apply_of, Abelianization.lift_apply_of]
  exact hw

omit [DecidableEq G] in
/-- The sharp capacity statement: the abelianization attains the supremum of the information
that abelian characters can carry about a fork, and it attains the fork's full entropy exactly
when the fork factors through `G^ab`. -/
theorem abelianization_is_optimal (Y : G → β) (f : G →* A) :
    mutualInfo (fun g : G => f g) Y ≤ mutualInfo (fun g : G => Abelianization.of g) Y
      ∧ (mutualInfo (fun g : G => Abelianization.of g) Y = H Y
          ↔ ∀ g c, c ∈ commutator G → Y (g * c) = Y g) :=
  ⟨mutualInfo_le_abelianization f Y, pinned_iff_commutator_invariant Y⟩

end Galois

end ForkPinning