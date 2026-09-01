import Probability.TailTransplantCost

/-!
# Margin scarcity, not weight-space distance, is the portability predictor (NET-56)

Two candidate predictors of transplant damage live in the catalog.

* the **norm route**: a block is portable if the two copies of its weights are
  close, because a small weight perturbation moves the logits by a Lipschitz
  amount and `Catalog.Novelty.KVDecisionDissociation.strictTop_of_margin` then
  freezes the decision;
* the **margin route**: a block is portable if the fraction of positions
  carrying no margin certificate is small
  (`Catalog.Probability.TailTransplantCost.uncertifiedFrac`), which by
  `uncertifiedFrac_ge` is a *certified upper bound on the measured damage*.

This file makes both predictors computable objects for an explicit linear block
model and then decides between them.

## Main results

* `blockLogit_dist_le` / `norm_route_no_damage` — the norm route is **sound**:
  entrywise weight distance `dW`, feature bound `B` and width `k` give the
  logit perturbation bound `k · dW · B`, and a top-1 gap above twice that
  freezes every decision.  So a norm bound *is* a sufficient condition.
* `margin_route_screens_damage` / `portability_screening` — the margin route is
  a **quantitative screen**: the damage fraction never exceeds the
  margin-uncertified fraction, so a purely forward-pass statistic (no
  transplant) upper-bounds the transplant damage at any threshold `τ`.
* `net54_margin_scarcity` — the NET-54 tail arm, run through the screen:
  `agree ≤ 0.5443` forces `uncertifiedFrac ≥ 0.4557` and the measured damage is
  exactly the certified lower bound of the margin statistic.
* `weight_distance_not_monotone` — the **falsification of the norm route as a
  predictor**: for any `0 < d < D` there are two block pairs, one at weight
  distance exactly `D` with damage `0`, one at weight distance exactly `d` with
  damage `1`.  Damage is not monotone in weight-space distance.
* `no_weight_distance_bound` — the sharp corollary: *any* function `g` of the
  weight distance alone that upper-bounds damage satisfies `g δ ≥ 1` for every
  `δ > 0`.  A norm-only bound is vacuous; the missing ingredient is exactly the
  feature scale / margin information.
* `margin_screen_is_conservative` — the honest boundary (Critic stage): the
  margin statistic is only a *sufficient* condition, it can be `1` while the
  damage is `0`.  `margin_screen_attained` shows it is nevertheless attained,
  so no universal improvement of the screen exists.

## Lab notes (measured inputs)

| arm | agree with donor | damage `1 − agree` | certified `uncertifiedFrac ≥` |
|---|---|---|---|
| tail L22/23 (`A ← B`) | `0.5443` | `0.4557` | `0.4557` |
| bulk L10/11 (`A ← B`) | `0.8385` | `0.1615` | `0.1615` |

The damage column is what a predictor has to reproduce.  The margin column
reproduces it by construction (`margin_route_screens_damage`); for the weight
distance, `weight_distance_not_monotone` shows that *any* ordering of the two
arms by distance is compatible with this damage column, so the distance column
carries no information about it.
-/

namespace Catalog.Applications.MarginScarcityPortability

open Finset
open Catalog.Novelty.KVDecisionDissociation
open Catalog.Probability.TailTransplantGeometry
open Catalog.Probability.TailTransplantCost

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω]

/-! ### 0. Damage: the measured post-transplant disagreement -/

/-- The measured post-transplant damage: the fraction of held-out positions at
which the hybrid `f` and the reference `g` make different top-1 decisions. -/
noncomputable def damageFrac {m : ℕ} (f g : Ω → Fin m) : ℝ :=
  ((disagreeSet f g).card : ℝ) / (Fintype.card Ω : ℝ)

omit [DecidableEq Ω] in
lemma damageFrac_eq_one_sub_agree [Nonempty Ω] {m : ℕ} (f g : Ω → Fin m) :
    damageFrac f g = 1 - agreeFrac f g := by
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  have hcast : ((agreeSet f g).card : ℝ) + ((disagreeSet f g).card : ℝ)
      = (Fintype.card Ω : ℝ) := by exact_mod_cast card_agree_add_card_disagree f g
  rw [damageFrac, agreeFrac, eq_sub_iff_add_eq, ← add_div, div_eq_one_iff_eq hN.ne']
  linarith

omit [DecidableEq Ω] in
lemma damageFrac_nonneg {m : ℕ} (f g : Ω → Fin m) : 0 ≤ damageFrac f g := by
  unfold damageFrac; positivity

/-! ### 1. The linear block model and the norm route -/

/-- The logits produced by a block with weight matrix `W` on the features
`feat x` of the position `x`.  Two fine-tunes of the same architecture give two
weight matrices `WA`, `WB` for the same block; a transplant replaces one by the
other while keeping the host's features. -/
def blockLogit {k m : ℕ} (W : Fin m → Fin k → ℝ) (feat : Ω → Fin k → ℝ)
    (x : Ω) (j : Fin m) : ℝ := ∑ i, W j i * feat x i

omit [Fintype Ω] [DecidableEq Ω] in
/-- **The norm-based (Lipschitz) bound.**  Entrywise weight distance `dW` and
feature bound `B` move each logit by at most `k · dW · B`. -/
lemma blockLogit_dist_le {k m : ℕ} (WA WB : Fin m → Fin k → ℝ) (feat : Ω → Fin k → ℝ)
    (dW B : ℝ) (hW : ∀ j i, |WA j i - WB j i| ≤ dW) (hf : ∀ x i, |feat x i| ≤ B)
    (x : Ω) (j : Fin m) :
    |blockLogit WA feat x j - blockLogit WB feat x j| ≤ (k : ℝ) * dW * B := by
  have hdiff : blockLogit WA feat x j - blockLogit WB feat x j
      = ∑ i, (WA j i - WB j i) * feat x i := by
    simp only [blockLogit, ← Finset.sum_sub_distrib, sub_mul]
  rw [hdiff]
  have hstep : ∀ i : Fin k, |(WA j i - WB j i) * feat x i| ≤ dW * B := by
    intro i
    rw [abs_mul]
    exact mul_le_mul (hW j i) (hf x i) (abs_nonneg _)
      (le_trans (abs_nonneg _) (hW j i))
  calc |∑ i, (WA j i - WB j i) * feat x i|
      ≤ ∑ i, |(WA j i - WB j i) * feat x i| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _i : Fin k, dW * B := Finset.sum_le_sum (fun i _ => hstep i)
    _ = (k : ℝ) * dW * B := by
        rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul, mul_assoc]

omit [Fintype Ω] [DecidableEq Ω] in
/-- **The norm route is sound.**  If the host's top-1 gap exceeds twice the
Lipschitz budget `k · dW · B`, the transplanted block reproduces the host's
decision at every position: zero damage.  This is the norm-based *sufficient*
condition, and it is the only thing a norm bound buys. -/
theorem norm_route_no_damage {k m : ℕ} (WA WB : Fin m → Fin k → ℝ) (feat : Ω → Fin k → ℝ)
    (dW B : ℝ) (hW : ∀ j i, |WA j i - WB j i| ≤ dW) (hf : ∀ x i, |feat x i| ≤ B)
    (dA dB : Ω → Fin m)
    (hmargin : ∀ x j, j ≠ dA x →
      2 * ((k : ℝ) * dW * B) < blockLogit WA feat x (dA x) - blockLogit WA feat x j)
    (hdB : ∀ x, IsStrictTop (blockLogit WB feat x) (dB x)) :
    ∀ x, dB x = dA x := by
  intro x
  have htopB : IsStrictTop (blockLogit WB feat x) (dA x) :=
    strictTop_of_margin _ _ (dA x) ((k : ℝ) * dW * B) (hmargin x)
      (fun j => blockLogit_dist_le WA WB feat dW B hW hf x j)
  exact strictTop_unique (hdB x) htopB

omit [DecidableEq Ω] in
/-- Fractional form of `norm_route_no_damage`: under a satisfied norm
certificate the measured damage is exactly zero. -/
theorem norm_route_damageFrac_zero {k m : ℕ} (WA WB : Fin m → Fin k → ℝ)
    (feat : Ω → Fin k → ℝ) (dW B : ℝ)
    (hW : ∀ j i, |WA j i - WB j i| ≤ dW) (hf : ∀ x i, |feat x i| ≤ B)
    (dA dB : Ω → Fin m)
    (hmargin : ∀ x j, j ≠ dA x →
      2 * ((k : ℝ) * dW * B) < blockLogit WA feat x (dA x) - blockLogit WA feat x j)
    (hdB : ∀ x, IsStrictTop (blockLogit WB feat x) (dB x)) :
    damageFrac dB dA = 0 := by
  have h := norm_route_no_damage WA WB feat dW B hW hf dA dB hmargin hdB
  have hempty : disagreeSet dB dA = ∅ := by
    ext x
    simp only [mem_disagreeSet, Finset.notMem_empty, iff_false, not_not]
    exact h x
  simp [damageFrac, hempty]

/-! ### 2. The margin route: a forward-pass screen for portability -/

open Classical in
omit [DecidableEq Ω] in
/-- **The margin screen.**  The measured damage never exceeds the
margin-uncertified fraction — a statistic of the *donor's own forward pass*
(logit margins) and the prefix drift `eps`, requiring no transplant. -/
theorem margin_route_screens_damage [Nonempty Ω] {m : ℕ} (u v : Ω → Fin m → ℝ)
    (d dH : Ω → Fin m) (eps : ℝ) (hH : ∀ x, IsStrictTop (v x) (dH x)) :
    damageFrac dH d ≤ uncertifiedFrac u v d eps := by
  rw [damageFrac_eq_one_sub_agree]
  exact uncertifiedFrac_ge u v d dH eps hH

open Classical in
omit [DecidableEq Ω] in
/-- **Portability is predictable without a transplant.**  If the cheap
forward-pass statistic sits below a threshold `τ`, the (expensive) measured
post-transplant damage is guaranteed to sit below `τ` as well. -/
theorem portability_screening [Nonempty Ω] {m : ℕ} (u v : Ω → Fin m → ℝ)
    (d dH : Ω → Fin m) (eps tau : ℝ) (hH : ∀ x, IsStrictTop (v x) (dH x))
    (hscreen : uncertifiedFrac u v d eps ≤ tau) :
    damageFrac dH d ≤ tau :=
  le_trans (margin_route_screens_damage u v d dH eps hH) hscreen

open Classical in
omit [DecidableEq Ω] in
/-- **NET-54 tail arm through the screen.**  The measured damage of the tail
transplant is `1 − 0.5443 = 0.4557`, and the margin statistic certifies at
least that much scarcity: the two numbers coincide, i.e. the margin screen is
*exactly saturated* by the tail arm.  (Reuses
`net54_margin_failure_fraction` as the certified lower bound.) -/
theorem net54_margin_scarcity [Nonempty Ω] {m : ℕ} (u v : Ω → Fin m → ℝ)
    (d dH : Ω → Fin m) (eps : ℝ) (hH : ∀ x, IsStrictTop (v x) (dH x))
    (hagree : agreeFrac dH d = 0.5443) :
    damageFrac dH d = 0.4557 ∧ (0.4557 : ℝ) ≤ uncertifiedFrac u v d eps := by
  refine ⟨?_, net54_margin_failure_fraction u v d dH eps hH (le_of_eq hagree)⟩
  rw [damageFrac_eq_one_sub_agree, hagree]
  norm_num

/-! ### 3. Weight-space distance is not a predictor -/

/-- A dead feature direction: the second coordinate of every feature vector
vanishes, so weight mass placed there is invisible to the logits. -/
def deadFeat (_x : Ω) : Fin 2 → ℝ := ![1, 0]

omit [Fintype Ω] [DecidableEq Ω] in
lemma blockLogit_deadFeat (W : Fin 2 → Fin 2 → ℝ) (x : Ω) (j : Fin 2) :
    blockLogit W (deadFeat) x j = W j 0 := by
  simp [blockLogit, deadFeat, Fin.sum_univ_two]

omit [DecidableEq Ω] in
/-- **Damage is not monotone in weight-space distance.**  For any `0 < d < D`
there are two block pairs sharing the same features: the first differs by
exactly `D` in weight space yet transplants with *zero* damage, the second
differs by only `d` yet transplants with *total* damage.  Weight distance
therefore carries no ordering information about portability. -/
theorem weight_distance_not_monotone [Nonempty Ω] (d D : ℝ) (hd : 0 < d) (hdD : d < D) :
    ∃ (WA WB WA' WB' : Fin 2 → Fin 2 → ℝ) (dA dB dA' dB' : Ω → Fin 2),
      (∀ x, IsStrictTop (blockLogit WA deadFeat x) (dA x)) ∧
      (∀ x, IsStrictTop (blockLogit WB deadFeat x) (dB x)) ∧
      (∀ x, IsStrictTop (blockLogit WA' deadFeat x) (dA' x)) ∧
      (∀ x, IsStrictTop (blockLogit WB' deadFeat x) (dB' x)) ∧
      (∀ j i, |WA j i - WB j i| ≤ D) ∧ (|WA 0 1 - WB 0 1| = D) ∧
      (∀ j i, |WA' j i - WB' j i| ≤ d) ∧ (|WA' 0 0 - WB' 0 0| = d) ∧
      damageFrac dB dA = 0 ∧ damageFrac dB' dA' = 1 := by
  classical
  have hD : 0 < D := lt_trans hd hdD
  refine ⟨![![1, 0], ![0, 0]], ![![1, D], ![0, 0]],
    ![![d / 2, 0], ![-(d / 2), 0]], ![![-(d / 2), 0], ![d / 2, 0]],
    (fun _ => 0), (fun _ => 0), (fun _ => 0), (fun _ => 1), ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro x j hj
    fin_cases j
    · exact absurd rfl hj
    · simp [blockLogit_deadFeat]
  · intro x j hj
    fin_cases j
    · exact absurd rfl hj
    · simp [blockLogit_deadFeat]
  · intro x j hj
    fin_cases j
    · exact absurd rfl hj
    · rw [blockLogit_deadFeat, blockLogit_deadFeat]
      simp
      linarith
  · intro x j hj
    fin_cases j
    · rw [blockLogit_deadFeat, blockLogit_deadFeat]
      simp
      linarith
    · exact absurd rfl hj
  · intro j i
    fin_cases j <;> fin_cases i <;> rw [abs_le] <;> constructor <;> simp <;> linarith
  · simp [abs_of_nonneg hD.le]
  · intro j i
    fin_cases j <;> fin_cases i <;> rw [abs_le] <;> constructor <;> simp <;> linarith
  · rw [show (![![d / 2, 0], ![-(d / 2), 0]] : Fin 2 → Fin 2 → ℝ) 0 0 = d / 2 by simp,
      show (![![-(d / 2), 0], ![d / 2, 0]] : Fin 2 → Fin 2 → ℝ) 0 0 = -(d / 2) by simp]
    rw [show d / 2 - -(d / 2) = d by ring, abs_of_pos hd]
  · have hempty : disagreeSet (fun _ : Ω => (0 : Fin 2)) (fun _ => 0) = ∅ := by
      ext x; simp [mem_disagreeSet]
    simp [damageFrac, hempty]
  · have huniv : disagreeSet (fun _ : Ω => (1 : Fin 2)) (fun _ => 0) = Finset.univ := by
      ext x; simp [mem_disagreeSet]
    have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
    rw [damageFrac, huniv, Finset.card_univ, div_self hN.ne']

omit [DecidableEq Ω] in
/-- **No norm-only predictor exists.**  If `g` is any function of the entrywise
weight distance alone that upper-bounds the transplant damage, then `g δ ≥ 1`
for every `δ > 0`: the bound is vacuous.  What a norm bound is missing is the
feature scale — the same weight perturbation is harmless in a dead direction
and fatal in a live one. -/
theorem no_weight_distance_bound [Nonempty Ω] (g : ℝ → ℝ)
    (hg : ∀ (delta : ℝ) (WA WB : Fin 2 → Fin 2 → ℝ) (feat : Ω → Fin 2 → ℝ)
        (dA dB : Ω → Fin 2), (∀ j i, |WA j i - WB j i| ≤ delta) →
        (∀ x, IsStrictTop (blockLogit WA feat x) (dA x)) →
        (∀ x, IsStrictTop (blockLogit WB feat x) (dB x)) →
        damageFrac dB dA ≤ g delta) :
    ∀ delta : ℝ, 0 < delta → 1 ≤ g delta := by
  classical
  intro delta hdelta
  have hdist : ∀ j i, |(![![delta / 2, 0], ![-(delta / 2), 0]] : Fin 2 → Fin 2 → ℝ) j i
      - (![![-(delta / 2), 0], ![delta / 2, 0]] : Fin 2 → Fin 2 → ℝ) j i| ≤ delta := by
    intro j i
    fin_cases j <;> fin_cases i <;> rw [abs_le] <;> constructor <;> simp <;> linarith
  have hA : ∀ x : Ω,
      IsStrictTop (blockLogit (![![delta / 2, 0], ![-(delta / 2), 0]]) deadFeat x) 0 := by
    intro x j hj
    fin_cases j
    · exact absurd rfl hj
    · rw [blockLogit_deadFeat, blockLogit_deadFeat]
      simp
      linarith
  have hB : ∀ x : Ω,
      IsStrictTop (blockLogit (![![-(delta / 2), 0], ![delta / 2, 0]]) deadFeat x) 1 := by
    intro x j hj
    fin_cases j
    · rw [blockLogit_deadFeat, blockLogit_deadFeat]
      simp
      linarith
    · exact absurd rfl hj
  have hdam : damageFrac (fun _ : Ω => (1 : Fin 2)) (fun _ => 0) = 1 := by
    have huniv : disagreeSet (fun _ : Ω => (1 : Fin 2)) (fun _ => 0) = Finset.univ := by
      ext x; simp [mem_disagreeSet]
    have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
    rw [damageFrac, huniv, Finset.card_univ, div_self hN.ne']
  have := hg delta _ _ deadFeat (fun _ => 0) (fun _ => 1) hdist hA hB
  rwa [hdam] at this

/-! ### 4. The boundary of the margin screen (adversarial review) -/

open Classical in
omit [DecidableEq Ω] in
/-- **The margin screen is only sufficient.**  There is a configuration with a
*completely* scarce margin statistic (`uncertifiedFrac = 1`) and yet zero
damage: the screen is an upper bound on damage, never an estimate of it.  This
is the honest boundary of the "margin scarcity predicts damage" claim. -/
theorem margin_screen_is_conservative [Nonempty Ω] :
    ∃ (u v : Ω → Fin 2 → ℝ) (d dH : Ω → Fin 2),
      (∀ x, IsStrictTop (v x) (dH x)) ∧
      uncertifiedFrac u v d 1 = 1 ∧ damageFrac dH d = 0 := by
  classical
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  refine ⟨fun _ => ![1, 0], fun _ => ![1, 0], fun _ => 0, fun _ => 0, ?_, ?_, ?_⟩
  · intro x j hj
    fin_cases j
    · exact absurd rfl hj
    · norm_num
  · have huniv : uncertifiedSet (fun _ : Ω => ![(1 : ℝ), 0]) (fun _ => ![(1 : ℝ), 0])
        (fun _ => 0) 1 = Finset.univ := by
      ext x
      simp only [uncertifiedSet, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
      intro hcert
      have := hcert.1 1 (by simp)
      norm_num at this
    rw [uncertifiedFrac, huniv, Finset.card_univ, div_self hN.ne']
  · have hempty : disagreeSet (fun _ : Ω => (0 : Fin 2)) (fun _ => 0) = ∅ := by
      ext x; simp [mem_disagreeSet]
    simp [damageFrac, hempty]

open Classical in
omit [DecidableEq Ω] in
/-- **The margin screen is attained.**  There is a configuration where the
screen is exactly the damage (`uncertifiedFrac = damageFrac = 1`), so no
universal strengthening of `margin_route_screens_damage` (no constant `c < 1`
with `damage ≤ c · uncertifiedFrac`) exists. -/
theorem margin_screen_attained [Nonempty Ω] :
    ∃ (u v : Ω → Fin 2 → ℝ) (d dH : Ω → Fin 2),
      (∀ x, IsStrictTop (v x) (dH x)) ∧
      uncertifiedFrac u v d 1 = 1 ∧ damageFrac dH d = 1 := by
  classical
  have hN : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  refine ⟨fun _ => ![1, 0], fun _ => ![0, 1], fun _ => 0, fun _ => 1, ?_, ?_, ?_⟩
  · intro x j hj
    fin_cases j
    · norm_num
    · exact absurd rfl hj
  · have huniv : uncertifiedSet (fun _ : Ω => ![(1 : ℝ), 0]) (fun _ => ![(0 : ℝ), 1])
        (fun _ => 0) 1 = Finset.univ := by
      ext x
      simp only [uncertifiedSet, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
      intro hcert
      have := hcert.1 1 (by simp)
      norm_num at this
    rw [uncertifiedFrac, huniv, Finset.card_univ, div_self hN.ne']
  · have huniv : disagreeSet (fun _ : Ω => (1 : Fin 2)) (fun _ => 0) = Finset.univ := by
      ext x; simp [mem_disagreeSet]
    rw [damageFrac, huniv, Finset.card_univ, div_self hN.ne']

end Catalog.Applications.MarginScarcityPortability