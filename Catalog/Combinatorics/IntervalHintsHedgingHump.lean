/-
# ET-HINTS-FULL (I): the hedging hump (FACT round 40 #4, paper 148, theorem T7)

Continuation of `Logic.IntervalHintsTwoNumbers` (round 39 #5).  There the hint posterior was
uniform inside and outside the window.  Here the hint is *prior-proportional*: an oracle names a
set `S` of cells and the searcher trusts it at level `α`, i.e. puts mass `α` on `S` and `1 - α`
on its complement, each spread proportionally to the prior `p`:

  `trustPost p S α j = (α / P(S)) p j`  for `j ∈ S`,   `((1-α)/(1-P(S))) p j` otherwise.

At the calibrated trust `α = P(S)` the posterior *is* the prior (`trustPost_calibrated`).  The
Bayes-optimal expected number of probes `E_opt(α) = trustCost p S α` is studied as a function of
the trust level.

## Main results
* `trustPost_affine`, `trustPost_sum` — the trust family is an affine line of probability vectors.
* **`trustCost_concave`**, `trustCost_eq_inf_affine` — `E_opt` is concave and is the minimum of the
  `n!` affine functions `α ↦ probeCost (trustPost α) σ`: concave piecewise-linear (T7, shape).
* `optCost_le_uniform_level`, **`trustCost_le_uniform_level`** — no posterior whatsoever costs more
  than the uniform level `(n+1)/2`: this is the absolute ceiling of any hump.
* `hintPosterior_peak` — in the round-39 uniform-given-hit family the hump reaches this ceiling
  exactly, at `α = W/M`.
* **`hedging_hump`** — for *every* strictly decreasing prior and *every* window whose conditional
  mean position differs from the complement's, some intermediate trust `α ∈ (0,1)` makes the
  Bayes-optimal search strictly MORE expensive than ignoring the hint (`E_opt(α) > E_opt(P(S))`).
* **`minLaw_right_hump`** — under the min-law prior `J = min(p, q)` and a right-placed window of
  width `W ≤ M/3`, partial trust is strictly worse than no hint, than full trust (`α = 1`) and
  than full distrust (`α = 0`): partial trust is the most expensive regime.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): (H1) `E_opt(α)` is concave piecewise-linear; (H2) intermediate trust can be
  worse than *both* endpoints *and* than no hint; (H3) the hump is a min-law accident.
Experiment (Stage 2): exact rational evaluation (sorted posterior, `α` grid step `1/200`), min-law,
  `M = 512` (blind `171.17`): right `x = 1/4` peak `196.50` at `α = 0.22` (reported `196.09`);
  right `x = 1/2` `197.84`; left `x = 1/4` `186.37` at `α = 0.31`; centered `x = 1/4` `176.97`;
  right `x = 1/64` `173.76`.  Every placement shows a hump.  `M = 256`: blind `85.83`, right
  `x = 1/4` peak `98.50`.
Analysis (Stage 3): (H1) true for any prior (minimum of affine functions).  (H2) true, and
  (H3) false: the hump is universal for strictly decreasing priors — at the calibrated trust the
  greedy order is rigid, so `E_opt` is locally the *linear* committed cost, whose slope is the
  difference of the two conditional mean positions; moving trust in the uphill direction
  strictly raises the cost.  For left windows the hump sits *below* the calibrated trust.
Critique (Stage 4): the hump never exceeds `(n+1)/2` (`trustCost_le_uniform_level`, `256.5` at
  `M = 512`), so "196 vs 171" is about 29% of the way to that ceiling.  The endpoint comparison
  needs a narrow window (`3W ≤ M`); for `x = 1/2` left/right the peak still exceeds both
  endpoints numerically but this is not covered.
-/
import Logic.IntervalHintsTwoNumbers

namespace IntervalHintsHedgingHump

open Finset Filter Topology IntervalHintsTwoNumbers

variable {n : ℕ}

/-! ## 1. The trust family -/

/-- Prior mass of the hinted set `S`. -/
noncomputable def windowMass (p : Fin n → ℝ) (S : Finset (Fin n)) : ℝ := ∑ j ∈ S, p j

/-- Posterior after trusting the hint "`J ∈ S`" at level `α` (prior-proportional inside and
outside `S`). -/
noncomputable def trustPost (p : Fin n → ℝ) (S : Finset (Fin n)) (α : ℝ) (j : Fin n) : ℝ :=
  (if j ∈ S then α / windowMass p S else (1 - α) / (1 - windowMass p S)) * p j

/-- Bayes-optimal expected number of probes at trust level `α`. -/
noncomputable def trustCost (p : Fin n → ℝ) (S : Finset (Fin n)) (α : ℝ) : ℝ :=
  optCost (trustPost p S α)

/-- At the calibrated trust `α = P(S)` the posterior is the prior. -/
theorem trustPost_calibrated (p : Fin n → ℝ) (S : Finset (Fin n)) (h0 : windowMass p S ≠ 0)
    (h1 : windowMass p S ≠ 1) : trustPost p S (windowMass p S) = p := by
  have h1' : 1 - windowMass p S ≠ 0 := sub_ne_zero.mpr (Ne.symm h1)
  ext j
  unfold trustPost
  split_ifs
  · rw [div_self h0, one_mul]
  · rw [div_self h1', one_mul]

/-- The trust family is an affine line. -/
theorem trustPost_affine (p : Fin n → ℝ) (S : Finset (Fin n)) (α β t : ℝ) :
    trustPost p S (t * α + (1 - t) * β) =
      fun j => t * trustPost p S α j + (1 - t) * trustPost p S β j := by
  ext j
  unfold trustPost
  split_ifs <;> ring

lemma sum_split_ite (S : Finset (Fin n)) (a b : ℝ) (f : Fin n → ℝ) :
    ∑ j, (if j ∈ S then a else b) * f j = a * ∑ j ∈ S, f j + b * ∑ j ∈ Sᶜ, f j := by
  rw [← sum_add_sum_compl S, mul_sum, mul_sum]
  congr 1
  · exact sum_congr rfl fun j hj => by rw [if_pos hj]
  · exact sum_congr rfl fun j hj => by rw [if_neg (mem_compl.mp hj)]

/-- Every member of the trust family is a probability vector (total mass `α + (1-α) = 1`). -/
theorem trustPost_sum (p : Fin n → ℝ) (S : Finset (Fin n)) (hp : ∑ j, p j = 1)
    (h0 : windowMass p S ≠ 0) (h1 : windowMass p S ≠ 1) (α : ℝ) :
    ∑ j, trustPost p S α j = 1 := by
  unfold trustPost
  rw [sum_split_ite]
  have hc : ∑ j ∈ Sᶜ, p j = 1 - windowMass p S := by
    rw [← hp, ← sum_add_sum_compl S p]; unfold windowMass; ring
  have h1' : 1 - windowMass p S ≠ 0 := sub_ne_zero.mpr (Ne.symm h1)
  rw [hc]
  change α / windowMass p S * windowMass p S + _ = 1
  field_simp
  ring

/-! ## 2. Concave piecewise-linear shape -/

/-- **T7 (shape).**  `E_opt(α)` is concave in the trust level. -/
theorem trustCost_concave (p : Fin n → ℝ) (S : Finset (Fin n)) :
    ConcaveOn ℝ Set.univ (trustCost p S) := by
  refine ⟨convex_univ, fun x _ y _ a b ha hb hab => ?_⟩
  obtain rfl : b = 1 - a := by linarith
  simp only [smul_eq_mul]
  unfold trustCost
  rw [trustPost_affine]
  exact optCost_concave _ _ a ha (by linarith)

/-- **T7 (piecewise-linear).**  `E_opt(α)` is the minimum over all `n!` orders of the affine
functions `α ↦ α · c₁(σ) + (1 - α) · c₀(σ)`. -/
theorem trustCost_eq_inf_affine (p : Fin n → ℝ) (S : Finset (Fin n)) (α : ℝ) :
    trustCost p S α = univ.inf' univ_nonempty (fun σ : Equiv.Perm (Fin n) =>
      α * probeCost (trustPost p S 1) σ + (1 - α) * probeCost (trustPost p S 0) σ) := by
  unfold trustCost optCost
  have : trustPost p S α = fun j => α * trustPost p S 1 j + (1 - α) * trustPost p S 0 j := by
    rw [← trustPost_affine]; congr 1; ring
  rw [this]
  congr 1
  ext σ
  exact probeCost_mix _ _ α σ

/-! ## 3. The uniform level is the absolute ceiling -/

/-- Scanning forwards and backwards together costs `(n+1)` times the total mass. -/
lemma probeCost_refl_add_rev (q : Fin n → ℝ) :
    probeCost q (Equiv.refl _) + probeCost q Fin.revPerm = ((n : ℝ) + 1) * ∑ j, q j := by
  unfold probeCost
  have hrev : ∑ i : Fin n, (((i : ℕ) : ℝ) + 1) * q (Fin.revPerm i)
      = ∑ i : Fin n, ((((Fin.revPerm i : Fin n) : ℕ) : ℝ) + 1) * q i := by
    rw [← Equiv.sum_comp Fin.revPerm (fun i => ((((Fin.revPerm i : Fin n) : ℕ) : ℝ) + 1) * q i)]
    refine sum_congr rfl fun i _ => ?_
    simp [Fin.revPerm_apply, Fin.rev_rev]
  rw [hrev, ← sum_add_distrib, mul_sum]
  refine sum_congr rfl fun i _ => ?_
  simp only [Equiv.refl_apply, Fin.revPerm_apply, Fin.val_rev]
  have hi : (i : ℕ) < n := i.isLt
  rw [Nat.cast_sub (by omega)]
  push_cast
  ring

/-- **Uniform ceiling.**  The Bayes-optimal cost of *any* weight vector is at most
`(n+1)/2` times its mass. -/
theorem optCost_le_uniform_level (q : Fin n → ℝ) :
    optCost q ≤ ((n : ℝ) + 1) / 2 * ∑ j, q j := by
  have h1 : optCost q ≤ probeCost q (Equiv.refl _) := inf'_le _ (mem_univ _)
  have h2 : optCost q ≤ probeCost q Fin.revPerm := inf'_le _ (mem_univ _)
  have := probeCost_refl_add_rev q
  linarith

/-- The uniform vector attains the ceiling: `(n+1)/2` is the global maximum of the Bayes cost
over probability vectors. -/
theorem optCost_uniform (hn : 0 < n) : optCost (fun _ : Fin n => 1 / (n : ℝ)) = ((n : ℝ) + 1) / 2 := by
  have hb := blindCost_eq n hn
  unfold blindCost at hb
  rw [optCost_eq_of_antitone _ (Equiv.refl _) (fun _ _ _ => le_rfl), hb]

/-- **No hump exceeds the uniform level.** -/
theorem trustCost_le_uniform_level (p : Fin n → ℝ) (S : Finset (Fin n)) (hp : ∑ j, p j = 1)
    (h0 : windowMass p S ≠ 0) (h1 : windowMass p S ≠ 1) (α : ℝ) :
    trustCost p S α ≤ ((n : ℝ) + 1) / 2 := by
  have := optCost_le_uniform_level (trustPost p S α)
  rwa [trustPost_sum p S hp h0 h1, mul_one] at this

/-- **The round-39 family peaks exactly at the ceiling.**  In the uniform-given-hit model of
`Logic.IntervalHintsTwoNumbers`, trusting the window at `α = W/M` flattens the posterior to the
uniform vector, so the Bayes cost reaches the global maximum `(M+1)/2`; no trust level exceeds it. -/
theorem hintPosterior_peak (M W : ℕ) (hW : 0 < W) (hWM : W < M) :
    optCost (hintPosterior M W ((W : ℝ) / M)) = ((M : ℝ) + 1) / 2 ∧
      ∀ α, optCost (hintPosterior M W α) ≤ ((M : ℝ) + 1) / 2 := by
  have hM : (0 : ℝ) < M := by exact_mod_cast hW.trans hWM
  have hW' : (W : ℝ) ≠ 0 := by exact_mod_cast hW.ne'
  have hMW : (M : ℝ) - W ≠ 0 := by
    have : (W : ℝ) < M := by exact_mod_cast hWM
    linarith
  refine ⟨?_, fun α => ?_⟩
  · have : hintPosterior M W ((W : ℝ) / M) = fun _ => 1 / (M : ℝ) := by
      ext j
      unfold hintPosterior
      split_ifs <;> field_simp
    rw [this, optCost_uniform (hW.trans hWM)]
  · have := optCost_le_uniform_level (hintPosterior M W α)
    rwa [hintPosterior_sum M W hW hWM α, mul_one] at this

/-! ## 4. The universal hedging hump -/

/-- Conditional mean position inside `S` under the prior. -/
noncomputable def meanIn (p : Fin n → ℝ) (S : Finset (Fin n)) : ℝ :=
  (∑ j ∈ S, (((j : ℕ) : ℝ) + 1) * p j) / windowMass p S

/-- Conditional mean position outside `S` under the prior. -/
noncomputable def meanOut (p : Fin n → ℝ) (S : Finset (Fin n)) : ℝ :=
  (∑ j ∈ Sᶜ, (((j : ℕ) : ℝ) + 1) * p j) / (1 - windowMass p S)

/-- The committed (ascending-scan) cost is *linear* in the trust level. -/
theorem committedCost_eq (p : Fin n → ℝ) (S : Finset (Fin n)) (α : ℝ) :
    probeCost (trustPost p S α) (Equiv.refl _) = α * meanIn p S + (1 - α) * meanOut p S := by
  unfold probeCost trustPost meanIn meanOut
  simp only [Equiv.refl_apply]
  rw [← sum_add_sum_compl S]
  congr 1
  · rw [mul_div_assoc', mul_comm α, mul_div_assoc, sum_mul]
    refine sum_congr rfl fun j hj => ?_
    rw [if_pos hj]; ring
  · rw [mul_div_assoc', mul_comm (1 - α), mul_div_assoc, sum_mul]
    refine sum_congr rfl fun j hj => ?_
    rw [if_neg (mem_compl.mp hj)]; ring

/-- Near the calibrated trust, the posterior of a strictly decreasing prior stays decreasing. -/
lemma eventually_antitone (p : Fin n → ℝ) (hp : StrictAnti p) (S : Finset (Fin n))
    (h0 : 0 < windowMass p S) (h1 : windowMass p S < 1) :
    ∀ᶠ α in 𝓝 (windowMass p S), Antitone (trustPost p S α ∘ Equiv.refl _) := by
  set P := windowMass p S with hP
  have hP1 : 1 - P ≠ 0 := by linarith
  have hcross : ∀ᶠ α in 𝓝 P, ∀ i j : Fin n, i < j →
      (1 - α) / (1 - P) * p j < α / P * p i ∧ α / P * p j < (1 - α) / (1 - P) * p i := by
    refine eventually_all.2 fun i => eventually_all.2 fun j => ?_
    by_cases hij : i < j
    · have hlt := hp hij
      have tin : Tendsto (fun α : ℝ => α / P * p i) (𝓝 P) (𝓝 (P / P * p i)) :=
        ((continuous_id.div_const P).mul continuous_const).tendsto P
      have tin' : Tendsto (fun α : ℝ => α / P * p j) (𝓝 P) (𝓝 (P / P * p j)) :=
        ((continuous_id.div_const P).mul continuous_const).tendsto P
      have tout : Tendsto (fun α : ℝ => (1 - α) / (1 - P) * p i) (𝓝 P)
          (𝓝 ((1 - P) / (1 - P) * p i)) :=
        (((continuous_const.sub continuous_id).div_const _).mul continuous_const).tendsto P
      have tout' : Tendsto (fun α : ℝ => (1 - α) / (1 - P) * p j) (𝓝 P)
          (𝓝 ((1 - P) / (1 - P) * p j)) :=
        (((continuous_const.sub continuous_id).div_const _).mul continuous_const).tendsto P
      have e1 : (1 - P) / (1 - P) * p j < P / P * p i := by
        rw [div_self hP1, div_self h0.ne', one_mul, one_mul]; exact hlt
      have e2 : P / P * p j < (1 - P) / (1 - P) * p i := by
        rw [div_self hP1, div_self h0.ne', one_mul, one_mul]; exact hlt
      filter_upwards [tout'.eventually_lt tin e1, tin'.eventually_lt tout e2] with α ha hb _
      exact ⟨ha, hb⟩
    · exact Eventually.of_forall fun _ h => absurd h hij
  filter_upwards [hcross, Ioo_mem_nhds h0 h1] with α hα hI
  have ha0 : 0 ≤ α / P := div_nonneg hI.1.le h0.le
  have hb0 : 0 ≤ (1 - α) / (1 - P) := div_nonneg (by linarith [hI.2]) (by linarith)
  intro i j hij
  rcases hij.lt_or_eq with hlt | heq
  · have hpij := (hp hlt).le
    obtain ⟨c1, c2⟩ := hα i j hlt
    simp only [Function.comp_apply, Equiv.refl_apply, trustPost]
    split_ifs
    · exact mul_le_mul_of_nonneg_left hpij ha0
    · exact c2.le
    · exact c1.le
    · exact mul_le_mul_of_nonneg_left hpij hb0
  · rw [heq]

/-- **T7 (hedging hump, universal form).**  For every strictly decreasing prior and every hinted
set whose conditional mean position differs from that of its complement, there is an
intermediate trust level `α ∈ (0, 1)` at which the Bayes-optimal search is strictly more
expensive than the optimal search *without* the hint. -/
theorem hedging_hump (p : Fin n → ℝ) (hp : StrictAnti p) (S : Finset (Fin n))
    (h0 : 0 < windowMass p S) (h1 : windowMass p S < 1) (hne : meanIn p S ≠ meanOut p S) :
    ∃ α, 0 < α ∧ α < 1 ∧ optCost p < trustCost p S α := by
  set P := windowMass p S with hP
  have hcal := trustPost_calibrated p S h0.ne' h1.ne
  have hB : optCost p = P * meanIn p S + (1 - P) * meanOut p S := by
    rw [optCost_eq_of_antitone p (Equiv.refl _) hp.antitone]
    conv_lhs => rw [← hcal]
    exact committedCost_eq p S P
  have key : ∀ α, Antitone (trustPost p S α ∘ Equiv.refl _) →
      trustCost p S α = α * meanIn p S + (1 - α) * meanOut p S := fun α hα => by
    unfold trustCost
    rw [optCost_eq_of_antitone _ _ hα, committedCost_eq]
  have hev := (eventually_antitone p hp S h0 h1).and (Ioo_mem_nhds h0 h1)
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · obtain ⟨α, ⟨hA, hI⟩, hα⟩ :=
      ((hev.filter_mono (nhdsWithin_le_nhds (s := Set.Iio P))).and self_mem_nhdsWithin).exists
    refine ⟨α, hI.1, hI.2, ?_⟩
    rw [key α hA, hB]
    have : α < P := hα
    nlinarith
  · obtain ⟨α, ⟨hA, hI⟩, hα⟩ :=
      ((hev.filter_mono (nhdsWithin_le_nhds (s := Set.Ioi P))).and self_mem_nhdsWithin).exists
    refine ⟨α, hI.1, hI.2, ?_⟩
    rw [key α hA, hB]
    have : P < α := hα
    nlinarith

/-! ## 5. The min-law, right-placed window: partial trust is the most expensive regime -/

/-- The min-law prior `P(J = j+1) = (2(M-1-j)+1)/M²` on `Fin M`. -/
noncomputable def minPrior (M : ℕ) (j : Fin M) : ℝ := minLaw M j

/-- The right-placed window: the last `W` cells. -/
def rightWindow (M W : ℕ) : Finset (Fin M) := univ.filter fun j => M - W ≤ (j : ℕ)

lemma minPrior_pos (M : ℕ) (j : Fin M) : 0 < minPrior M j := by
  unfold minPrior minLaw
  have hj : ((j : ℕ) : ℝ) + 1 ≤ M := by exact_mod_cast j.isLt
  have hM : (0 : ℝ) < M := by linarith [(Nat.cast_nonneg (j : ℕ) : (0 : ℝ) ≤ (j : ℕ))]
  apply div_pos _ (by positivity)
  linarith

lemma minPrior_sum (M : ℕ) (hM : 0 < M) : ∑ j, minPrior M j = 1 := by
  unfold minPrior
  rw [Fin.sum_univ_eq_sum_range (fun j => minLaw M j)]
  exact minLaw_sum M hM

lemma minPrior_strictAnti (M : ℕ) (hM : 0 < M) : StrictAnti (minPrior M) :=
  fun _ _ hij => minLaw_strictAnti M hM (show _ < _ from hij)

/-- Blind (no-hint) Bayes-optimal cost under the min-law: `(M+1)(2M+1)/(6M)`. -/
theorem minPrior_optCost (M : ℕ) (hM : 0 < M) :
    optCost (minPrior M) = ((M : ℝ) + 1) * (2 * M + 1) / (6 * M) := by
  rw [optCost_eq_of_antitone (minPrior M) (Equiv.refl _) (minPrior_strictAnti M hM).antitone]
  unfold probeCost minPrior
  simp only [Equiv.refl_apply]
  rw [Fin.sum_univ_eq_sum_range (fun i => ((i : ℝ) + 1) * minLaw M i)]
  exact minLaw_mean M hM

/-- **T7 (min-law, right window).**  With a right-placed window of width `0 < W`, `3W ≤ M`, some
intermediate trust `α ∈ (0,1)` makes the Bayes-optimal search strictly more expensive than
(i) no hint, (ii) full distrust `α = 0`, and (iii) full trust `α = 1`. -/
theorem minLaw_right_hump (M W : ℕ) (hW : 0 < W) (h3 : 3 * W ≤ M) :
    ∃ α, 0 < α ∧ α < 1 ∧ optCost (minPrior M) < trustCost (minPrior M) (rightWindow M W) α ∧
      trustCost (minPrior M) (rightWindow M W) 0 < trustCost (minPrior M) (rightWindow M W) α ∧
      trustCost (minPrior M) (rightWindow M W) 1 < trustCost (minPrior M) (rightWindow M W) α := by
  have hM : 0 < M := by omega
  set p := minPrior M
  set S := rightWindow M W
  have hmemS : ∀ j : Fin M, j ∈ S ↔ M - W ≤ (j : ℕ) := fun j => by simp [S, rightWindow]
  have hsplit := sum_add_sum_compl S p
  rw [minPrior_sum M hM] at hsplit
  have hS0 : 0 < windowMass p S := by
    apply sum_pos (fun j _ => minPrior_pos M j)
    exact ⟨⟨M - 1, by omega⟩, (hmemS _).2 (by simp; omega)⟩
  have hSc0 : 0 < ∑ j ∈ Sᶜ, p j := by
    apply sum_pos (fun j _ => minPrior_pos M j)
    exact ⟨⟨0, hM⟩, mem_compl.2 fun h => by have := (hmemS _).1 h; simp at this; omega⟩
  have hS1 : windowMass p S < 1 := by unfold windowMass; linarith
  have hc : 1 - windowMass p S = ∑ j ∈ Sᶜ, p j := by unfold windowMass; linarith
  -- positions inside the window are `≥ M - W + 1`, outside `≤ M - W`
  have hin : ((M : ℝ) - W + 1) * windowMass p S ≤ ∑ j ∈ S, (((j : ℕ) : ℝ) + 1) * p j := by
    unfold windowMass; rw [mul_sum]
    refine sum_le_sum fun j hj => mul_le_mul_of_nonneg_right ?_ (minPrior_pos M j).le
    have := (hmemS j).1 hj
    have : ((M - W : ℕ) : ℝ) ≤ (j : ℕ) := by exact_mod_cast this
    rw [Nat.cast_sub (by omega)] at this; linarith
  have hout : ∑ j ∈ Sᶜ, (((j : ℕ) : ℝ) + 1) * p j ≤ ((M : ℝ) - W) * ∑ j ∈ Sᶜ, p j := by
    rw [mul_sum]
    refine sum_le_sum fun j hj => mul_le_mul_of_nonneg_right ?_ (minPrior_pos M j).le
    have := mt (hmemS j).2 (mem_compl.1 hj)
    have : (((j : ℕ) + 1 : ℕ) : ℝ) ≤ ((M - W : ℕ) : ℝ) := by exact_mod_cast (by omega)
    rw [Nat.cast_sub (by omega)] at this; push_cast at this; linarith
  have hmIn : (M : ℝ) - W + 1 ≤ meanIn p S := by
    unfold meanIn; rw [le_div_iff₀ hS0]; exact hin
  have hmOut : meanOut p S ≤ (M : ℝ) - W := by
    unfold meanOut; rw [hc, div_le_iff₀ hSc0]; exact hout
  obtain ⟨α, hα0, hα1, hhump⟩ :=
    hedging_hump p (minPrior_strictAnti M hM) S hS0 hS1 (by intro h; linarith)
  -- the blind cost, as a mixture of the two conditional means
  have hcal := trustPost_calibrated p S hS0.ne' hS1.ne
  have hB : optCost p = windowMass p S * meanIn p S + (1 - windowMass p S) * meanOut p S := by
    rw [optCost_eq_of_antitone p (Equiv.refl _) (minPrior_strictAnti M hM).antitone]
    conv_lhs => rw [← hcal]
    exact committedCost_eq p S _
  refine ⟨α, hα0, hα1, hhump, ?_, ?_⟩
  · -- full distrust: scanning in order costs `meanOut < blind`
    have h0le : trustCost p S 0 ≤ meanOut p S := by
      have : trustCost p S 0 ≤ probeCost (trustPost p S 0) (Equiv.refl _) := inf'_le _ (mem_univ _)
      rw [committedCost_eq] at this; linarith
    nlinarith
  · -- full trust: scanning backwards visits the window in the first `W` probes
    have h1le : trustCost p S 1 ≤ W := by
      have hle : trustCost p S 1 ≤ probeCost (trustPost p S 1) Fin.revPerm := inf'_le _ (mem_univ _)
      have hsum := trustPost_sum p S (minPrior_sum M hM) hS0.ne' hS1.ne 1
      have hpt : probeCost (trustPost p S 1) Fin.revPerm ≤ ∑ i : Fin M, (W : ℝ) * trustPost p S 1 (Fin.revPerm i) := by
        unfold probeCost
        refine sum_le_sum fun i _ => ?_
        by_cases hi : Fin.revPerm i ∈ S
        · have := (hmemS _).1 hi
          simp only [Fin.revPerm_apply, Fin.val_rev] at this
          have hiW : (((i : ℕ) : ℝ) + 1) ≤ W := by exact_mod_cast (by omega)
          apply mul_le_mul_of_nonneg_right hiW
          unfold trustPost; rw [if_pos hi]
          exact mul_nonneg (div_nonneg zero_le_one hS0.le) (minPrior_pos M _).le
        · unfold trustPost; rw [if_neg hi]; simp
      rw [← mul_sum, Equiv.sum_comp Fin.revPerm (trustPost p S 1), hsum, mul_one] at hpt
      linarith
    have hBW : (W : ℝ) < optCost p := by
      rw [minPrior_optCost M hM]
      have hM' : (0 : ℝ) < M := by exact_mod_cast hM
      have h3' : 3 * (W : ℝ) ≤ M := by exact_mod_cast h3
      rw [lt_div_iff₀ (by positivity)]
      nlinarith
    linarith

end IntervalHintsHedgingHump