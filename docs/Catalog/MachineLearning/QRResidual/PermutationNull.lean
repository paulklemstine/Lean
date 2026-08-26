import MachineLearning.QRResidual.BlockCeiling

/-!
# Exact calibration of the permutation null for an `R²` increment

The verdict of experiment 585 rests on two numbers: an observed increment
`ΔR² = 0.01946`, and a permutation null obtained from 500 joint row-shuffles of the
covariate block, with `p = 0.389` and `q95 = 0.046`.  The permutation null is normally
treated as a Monte-Carlo object.  It is not: for a *single* centred covariate its exact
first moment is a closed-form function of the sample size alone.

Main results.

* `exists_perm_two_point` — sharp 2-transitivity of the symmetric group, in the explicit
  two-swap form needed below.
* `permSum_pair_const_offdiag`, `permSum_pair_const_diag` — the sum
  `W(i,j) = Σ_{σ} v(σ i) v(σ j)` over the whole symmetric group depends only on whether
  `i = j`.
* `perm_null_sum_sq_dot` — **the calibration identity**: for a centred residual `r` and a
  centred covariate `v` on a sample of size `n`,
  `Σ_{σ ∈ S_n} ⟨r, v∘σ⟩² = n! · ‖r‖²‖v‖² / (n−1)`,
  i.e. the *mean squared* residual correlation under a random row shuffle is exactly
  `1/(n−1)` of the maximum.
* `perm_null_mean_lift` — hence the mean permutation-null `R²` increment of one covariate
  is exactly `(1 − R²₀)/(n − 1)`: the null is calibrated by the baseline fit and the sample
  size, with no distributional assumption whatsoever.
* `perm_null_tail`, `exp585_perm_null_tail` — a Markov tail bound on the null, and its
  numeric instance: at the reported baseline `R²₀ = 0.4112` and any sample of at least
  `237` moduli, at most a `0.05` fraction of shuffles reach an increment of `0.05`.  This
  is consistent with, and independently bounds, the reported `q95 = 0.046`.

Together with `BlockCeiling`, this turns the experiment's null verdict into two theorems:
a *ceiling* on what the covariate block could ever have achieved, and a *calibration* of
the reference distribution against which the observed increment was judged.
-/

namespace QRResidual

open Finset

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Reindexing sums over the symmetric group -/

/-- Right translation is a bijection of the symmetric group, so it leaves sums invariant. -/
theorem sum_perm_mul_right (τ : Equiv.Perm ι) (f : Equiv.Perm ι → ℝ) :
    ∑ σ : Equiv.Perm ι, f (σ * τ) = ∑ σ : Equiv.Perm ι, f σ :=
  Fintype.sum_bijective (· * τ) (Group.mulRight_bijective τ) _ _ fun _ => rfl

omit [Fintype ι] in
/-- **Sharp 2-transitivity of `S_n`**, in explicit two-swap form: any ordered pair of
distinct points can be moved to any other ordered pair of distinct points. -/
theorem exists_perm_two_point {i j i' j' : ι} (hij : i ≠ j) (hij' : i' ≠ j') :
    ∃ τ : Equiv.Perm ι, τ i' = i ∧ τ j' = j := by
  set s₁ := Equiv.swap i' i with hs₁
  set c := s₁ j' with hc
  have hci : c ≠ i := by
    simp only [hc, hs₁]
    intro h
    have h2 : j' = i' := by
      have := congrArg (Equiv.swap i' i) h
      simpa [Equiv.swap_apply_self] using this
    exact hij' h2.symm
  refine ⟨Equiv.swap c j * s₁, ?_, ?_⟩
  · simp only [Equiv.Perm.mul_apply, hs₁, Equiv.swap_apply_left]
    exact Equiv.swap_apply_of_ne_of_ne (Ne.symm hci) hij
  · simp only [Equiv.Perm.mul_apply, ← hc, Equiv.swap_apply_left]

/-! ## The pair sum over the symmetric group -/

/-- The total pair statistic `W(i,j) = Σ_σ v(σ i)·v(σ j)` of a covariate. -/
def permPairSum (v : ι → ℝ) (i j : ι) : ℝ := ∑ σ : Equiv.Perm ι, v (σ i) * v (σ j)

/-- Off the diagonal, `W(i,j)` does not depend on the pair. -/
theorem permSum_pair_const_offdiag (v : ι → ℝ) {i j i' j' : ι} (hij : i ≠ j) (hij' : i' ≠ j') :
    permPairSum v i j = permPairSum v i' j' := by
  obtain ⟨τ, hτ1, hτ2⟩ := exists_perm_two_point hij hij'
  calc permPairSum v i j
      = ∑ σ : Equiv.Perm ι, v ((σ * τ) i') * v ((σ * τ) j') := by
        refine Finset.sum_congr rfl fun σ _ => ?_
        simp [Equiv.Perm.mul_apply, hτ1, hτ2]
    _ = permPairSum v i' j' :=
        sum_perm_mul_right τ (fun σ => v (σ i') * v (σ j'))

/-- On the diagonal, `W(i,i)` does not depend on the point. -/
theorem permSum_pair_const_diag (v : ι → ℝ) (i i' : ι) :
    permPairSum v i i = permPairSum v i' i' := by
  set τ := Equiv.swap i' i with hτ
  have hτ1 : τ i' = i := by simp [hτ]
  calc permPairSum v i i
      = ∑ σ : Equiv.Perm ι, v ((σ * τ) i') * v ((σ * τ) i') := by
        refine Finset.sum_congr rfl fun σ _ => ?_
        simp [Equiv.Perm.mul_apply, hτ1]
    _ = permPairSum v i' i' := sum_perm_mul_right τ (fun σ => v (σ i') * v (σ i'))

/-- Summing the diagonal statistic over the sample gives `|S_n| · ‖v‖²`. -/
theorem sum_permPairSum_diag (v : ι → ℝ) :
    ∑ i, permPairSum v i i = (Fintype.card (Equiv.Perm ι) : ℝ) * sqNorm v := by
  unfold permPairSum
  rw [Finset.sum_comm]
  have h : ∀ σ : Equiv.Perm ι, (∑ i, v (σ i) * v (σ i)) = sqNorm v := by
    intro σ
    have : (∑ i, v (σ i) * v (σ i)) = ∑ i, (v (σ i)) ^ 2 := by
      exact Finset.sum_congr rfl fun i _ => by ring
    rw [this, sqNorm]
    exact Equiv.sum_comp σ (fun i => (v i) ^ 2)
  simp [h, Finset.sum_const, nsmul_eq_mul, Finset.card_univ]

/-- For a **centred** covariate the full pair statistic sums to zero. -/
theorem sum_permPairSum_all {v : ι → ℝ} (hv : ∑ i, v i = 0) :
    ∑ i, ∑ j, permPairSum v i j = 0 := by
  have hswap : ∀ i : ι, (∑ j, permPairSum v i j)
      = ∑ σ : Equiv.Perm ι, ∑ j, v (σ i) * v (σ j) := by
    intro i; unfold permPairSum; exact Finset.sum_comm
  rw [Finset.sum_congr rfl fun i _ => hswap i, Finset.sum_comm]
  refine Finset.sum_eq_zero fun σ _ => ?_
  have hzero : (∑ j, v (σ j)) = 0 := by rw [Equiv.sum_comp σ v]; exact hv
  calc (∑ i, ∑ j, v (σ i) * v (σ j))
      = (∑ i, v (σ i)) * (∑ j, v (σ j)) := by
        rw [Finset.sum_mul_sum]
    _ = 0 := by rw [hzero, mul_zero]

/-! ## The calibration identity -/

/-- The diagonal and off-diagonal values of `W`, packaged for the main computation. -/
theorem permPairSum_split {v : ι → ℝ} (hn : 2 ≤ Fintype.card ι) (i₀ j₀ : ι) (hij₀ : i₀ ≠ j₀) :
    (Fintype.card ι : ℝ) * permPairSum v i₀ i₀
        + (Fintype.card ι : ℝ) * ((Fintype.card ι : ℝ) - 1) * permPairSum v i₀ j₀
      = ∑ i, ∑ j, permPairSum v i j := by
  have hrow : ∀ i : ι, (∑ j, permPairSum v i j)
      = permPairSum v i₀ i₀ + ((Fintype.card ι : ℝ) - 1) * permPairSum v i₀ j₀ := by
    intro i
    have hsplit : (∑ j, permPairSum v i j)
        = permPairSum v i i + ∑ j ∈ Finset.univ.erase i, permPairSum v i j := by
      rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
    have hoff : ∀ j ∈ Finset.univ.erase i, permPairSum v i j = permPairSum v i₀ j₀ := by
      intro j hj
      exact permSum_pair_const_offdiag v (Ne.symm (Finset.ne_of_mem_erase hj)) hij₀
    rw [hsplit, Finset.sum_congr rfl hoff, Finset.sum_const, nsmul_eq_mul,
      Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ,
      permSum_pair_const_diag v i i₀]
    have hcast : ((Fintype.card ι - 1 : ℕ) : ℝ) = (Fintype.card ι : ℝ) - 1 := by
      have : 1 ≤ Fintype.card ι := le_trans (by norm_num) hn
      push_cast [Nat.cast_sub this]
      ring
    rw [hcast]
  rw [Finset.sum_congr rfl fun i _ => hrow i, Finset.sum_const, nsmul_eq_mul, Finset.card_univ]
  ring

/-- **The permutation-null calibration identity.**  For a centred residual `r` and a centred
covariate `v` on a sample of size `n ≥ 2`, the sum over *all* row shuffles of the squared
sample correlation numerator is exactly `n!·‖r‖²‖v‖²/(n−1)`.  The permutation null of a
single covariate is therefore an exact, assumption-free object. -/
theorem perm_null_sum_sq_dot {r v : ι → ℝ} (hn : 2 ≤ Fintype.card ι)
    (hr : ∑ i, r i = 0) (hv : ∑ i, v i = 0) :
    ((Fintype.card ι : ℝ) - 1) * (∑ σ : Equiv.Perm ι, (dot r (fun i => v (σ i))) ^ 2)
      = (Fintype.card (Equiv.Perm ι) : ℝ) * (sqNorm r * sqNorm v) := by
  classical
  -- two distinct sample points exist
  obtain ⟨i₀, j₀, hij₀⟩ : ∃ i₀ j₀ : ι, i₀ ≠ j₀ := by
    have h1 : 1 < Fintype.card ι := hn
    exact Fintype.exists_pair_of_one_lt_card h1
  set n : ℝ := (Fintype.card ι : ℝ) with hn'
  set D : ℝ := permPairSum v i₀ i₀ with hD
  set T : ℝ := permPairSum v i₀ j₀ with hT
  -- expand the square of the shuffled inner product
  have hexpand : (∑ σ : Equiv.Perm ι, (dot r (fun i => v (σ i))) ^ 2)
      = ∑ i, ∑ j, r i * r j * permPairSum v i j := by
    have hstep : ∀ σ : Equiv.Perm ι, (dot r (fun i => v (σ i))) ^ 2
        = ∑ i, ∑ j, (r i * v (σ i)) * (r j * v (σ j)) := by
      intro σ
      rw [dot, sq, Finset.sum_mul_sum]
    calc (∑ σ : Equiv.Perm ι, (dot r (fun i => v (σ i))) ^ 2)
        = ∑ σ : Equiv.Perm ι, ∑ i, ∑ j, (r i * v (σ i)) * (r j * v (σ j)) := by
          exact Finset.sum_congr rfl fun σ _ => hstep σ
      _ = ∑ i, ∑ j, ∑ σ : Equiv.Perm ι, (r i * v (σ i)) * (r j * v (σ j)) := by
          rw [Finset.sum_comm]
          exact Finset.sum_congr rfl fun i _ => Finset.sum_comm
      _ = ∑ i, ∑ j, r i * r j * permPairSum v i j := by
          refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
          unfold permPairSum
          rw [Finset.mul_sum]
          exact Finset.sum_congr rfl fun σ _ => by ring
  -- the pair statistic takes only two values
  have hvalue : ∀ i j : ι, permPairSum v i j = if i = j then D else T := by
    intro i j
    by_cases h : i = j
    · subst h; simp [hD, permSum_pair_const_diag v i i₀]
    · simp [h, hT, permSum_pair_const_offdiag v h hij₀]
  have hrow : ∀ i : ι, (∑ j, r i * r j * permPairSum v i j)
      = r i * (r i * D) + r i * ((∑ j, r j) - r i) * T := by
    intro i
    have hsplit : (∑ j, r i * r j * permPairSum v i j)
        = r i * r i * permPairSum v i i
          + ∑ j ∈ Finset.univ.erase i, r i * r j * permPairSum v i j := by
      rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
    have hoff : ∀ j ∈ Finset.univ.erase i, r i * r j * permPairSum v i j = r i * r j * T := by
      intro j hj
      rw [hvalue i j, if_neg (Ne.symm (Finset.ne_of_mem_erase hj))]
    have herase : (∑ j ∈ Finset.univ.erase i, r j) = (∑ j, r j) - r i := by
      rw [eq_sub_iff_add_eq, add_comm]
      exact Finset.add_sum_erase _ _ (Finset.mem_univ i)
    rw [hsplit, Finset.sum_congr rfl hoff, hvalue i i, if_pos rfl, ← Finset.sum_mul,
      ← Finset.mul_sum, herase]
    ring
  have htotal : (∑ i, ∑ j, r i * r j * permPairSum v i j) = sqNorm r * D - sqNorm r * T := by
    rw [Finset.sum_congr rfl fun i _ => hrow i, hr]
    have : ∀ i : ι, r i * (r i * D) + r i * (0 - r i) * T = (r i) ^ 2 * D - (r i) ^ 2 * T := by
      intro i; ring
    rw [Finset.sum_congr rfl fun i _ => this i, Finset.sum_sub_distrib, ← Finset.sum_mul,
      ← Finset.sum_mul]
    rfl
  -- the centred covariate forces `n·D + n(n−1)·T = 0`
  have hzero : n * D + n * (n - 1) * T = 0 := by
    rw [permPairSum_split (v := v) hn i₀ j₀ hij₀, sum_permPairSum_all hv]
  have hdiag : n * D = (Fintype.card (Equiv.Perm ι) : ℝ) * sqNorm v := by
    have := sum_permPairSum_diag v
    rw [Finset.sum_congr rfl fun i _ => permSum_pair_const_diag v i i₀, Finset.sum_const,
      nsmul_eq_mul, Finset.card_univ] at this
    exact this
  have h2n : (2 : ℝ) ≤ n := by rw [hn']; exact_mod_cast hn
  have hn1 : (1 : ℝ) ≤ n - 1 := by linarith
  have hTval : (n - 1) * T = -D := by
    have hnpos : (0 : ℝ) < n := by linarith
    have : n * ((n - 1) * T + D) = 0 := by linarith [hzero]
    have h2 := mul_eq_zero.1 this
    rcases h2 with h | h
    · exact absurd h hnpos.ne'
    · linarith
  rw [hexpand, htotal]
  have hfinal : (n - 1) * (sqNorm r * D - sqNorm r * T)
      = sqNorm r * ((n - 1) * D - (n - 1) * T) := by ring
  rw [hfinal, hTval]
  have : (n - 1) * D - -D = n * D := by ring
  rw [this, hdiag]
  ring

/-- **The permutation null is calibrated by the sample size.**  The mean, over all row
shuffles, of the `R²` increment contributed by one centred covariate is exactly
`(1 − R²₀)/(n − 1)`. -/
theorem perm_null_mean_lift {y g v : ι → ℝ} (hn : 2 ≤ Fintype.card ι)
    (hr : ∑ i, (y - g) i = 0) (hv : ∑ i, v i = 0) (hvn : sqNorm v ≠ 0) (htss : 0 < tss y) :
    (∑ σ : Equiv.Perm ι, (dot (y - g) (fun i => v (σ i))) ^ 2 / (sqNorm v * tss y))
        / (Fintype.card (Equiv.Perm ι) : ℝ)
      = (1 - rsqOf y g) / ((Fintype.card ι : ℝ) - 1) := by
  have hcard : (0 : ℝ) < (Fintype.card (Equiv.Perm ι) : ℝ) := by
    have : 0 < Fintype.card (Equiv.Perm ι) := Fintype.card_pos
    exact_mod_cast this
  have hn1 : (0 : ℝ) < (Fintype.card ι : ℝ) - 1 := by
    have : (2 : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast hn
    linarith
  have hkey := perm_null_sum_sq_dot (r := y - g) (v := v) hn hr hv
  have hres : sqNorm (y - g) = (1 - rsqOf y g) * tss y := sqNorm_residual_eq htss
  have hpull : (∑ σ : Equiv.Perm ι, (dot (y - g) (fun i => v (σ i))) ^ 2 / (sqNorm v * tss y))
      = (∑ σ : Equiv.Perm ι, (dot (y - g) (fun i => v (σ i))) ^ 2) / (sqNorm v * tss y) := by
    rw [Finset.sum_div]
  rw [hpull]
  rw [div_div, div_eq_div_iff (by positivity) (ne_of_gt hn1)]
  have hvpos : 0 < sqNorm v := lt_of_le_of_ne (sqNorm_nonneg v) (Ne.symm hvn)
  rw [hres] at hkey
  field_simp at hkey ⊢
  linear_combination hkey

/-! ## A tail bound for the null, and the exp-585 instance -/

/-- **Markov tail bound for the permutation null.**  The number of shuffles achieving an
increment of at least `t` is at most `|S_n|·(1 − R²₀)/((n−1)·t)`. -/
theorem perm_null_tail {y g v : ι → ℝ} (hn : 2 ≤ Fintype.card ι)
    (hr : ∑ i, (y - g) i = 0) (hv : ∑ i, v i = 0) (hvn : sqNorm v ≠ 0) (htss : 0 < tss y)
    {t : ℝ} :
    ((Finset.univ.filter fun σ : Equiv.Perm ι =>
        t ≤ (dot (y - g) (fun i => v (σ i))) ^ 2 / (sqNorm v * tss y)).card : ℝ) * t
      * ((Fintype.card ι : ℝ) - 1)
      ≤ (Fintype.card (Equiv.Perm ι) : ℝ) * (1 - rsqOf y g) := by
  classical
  have hvpos : 0 < sqNorm v := lt_of_le_of_ne (sqNorm_nonneg v) (Ne.symm hvn)
  set f : Equiv.Perm ι → ℝ :=
    fun σ => (dot (y - g) (fun i => v (σ i))) ^ 2 / (sqNorm v * tss y) with hf
  have hfnn : ∀ σ : Equiv.Perm ι, 0 ≤ f σ := by
    intro σ; rw [hf]; positivity
  set S := Finset.univ.filter fun σ : Equiv.Perm ι => t ≤ f σ with hS
  have hlow : (S.card : ℝ) * t ≤ ∑ σ ∈ S, f σ := by
    have := Finset.card_nsmul_le_sum S f t (fun σ hσ => (Finset.mem_filter.1 hσ).2)
    simpa [nsmul_eq_mul] using this
  have hsub : (∑ σ ∈ S, f σ) ≤ ∑ σ : Equiv.Perm ι, f σ :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
      (fun σ _ _ => hfnn σ)
  have hmean := perm_null_mean_lift (y := y) (g := g) (v := v) hn hr hv hvn htss
  have hcard : (0 : ℝ) < (Fintype.card (Equiv.Perm ι) : ℝ) := by
    have : 0 < Fintype.card (Equiv.Perm ι) := Fintype.card_pos
    exact_mod_cast this
  have hn1 : (0 : ℝ) < (Fintype.card ι : ℝ) - 1 := by
    have : (2 : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast hn
    linarith
  have htot : (∑ σ : Equiv.Perm ι, f σ) * ((Fintype.card ι : ℝ) - 1)
      = (Fintype.card (Equiv.Perm ι) : ℝ) * (1 - rsqOf y g) := by
    field_simp at hmean
    linarith [hmean]
  have hchain : (S.card : ℝ) * t ≤ ∑ σ : Equiv.Perm ι, f σ := le_trans hlow hsub
  nlinarith [hchain, hn1, htot]

/-- **Exp 585, the null-calibration instance.**  At the reported baseline `R²₀ = 0.4112`,
on any sample of at least `237` moduli, at most a `0.05` fraction of row shuffles of a
centred covariate reaches an increment of `0.05`.  The reported empirical null
`q95 = 0.046` sits inside this unconditional bound. -/
theorem exp585_perm_null_tail {y g v : ι → ℝ} (hcards : 237 ≤ Fintype.card ι)
    (hr : ∑ i, (y - g) i = 0) (hv : ∑ i, v i = 0) (hvn : sqNorm v ≠ 0) (htss : 0 < tss y)
    (hR0 : rsqOf y g = 0.4112) :
    ((Finset.univ.filter fun σ : Equiv.Perm ι =>
        (0.05 : ℝ) ≤ (dot (y - g) (fun i => v (σ i))) ^ 2 / (sqNorm v * tss y)).card : ℝ)
      ≤ 0.05 * (Fintype.card (Equiv.Perm ι) : ℝ) := by
  classical
  have hn : 2 ≤ Fintype.card ι := le_trans (by norm_num) hcards
  have hbound := perm_null_tail (y := y) (g := g) (v := v) hn hr hv hvn htss (t := 0.05)
  rw [hR0] at hbound
  have hcast : (237 : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast hcards
  have hcardnn : (0 : ℝ) ≤ (Fintype.card (Equiv.Perm ι) : ℝ) := by positivity
  have hfilnn : (0 : ℝ) ≤ ((Finset.univ.filter fun σ : Equiv.Perm ι =>
      (0.05 : ℝ) ≤ (dot (y - g) (fun i => v (σ i))) ^ 2 / (sqNorm v * tss y)).card : ℝ) := by
    positivity
  nlinarith [hbound, hcast, hcardnn, hfilnn]

end QRResidual