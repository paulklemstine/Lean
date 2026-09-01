/-
# NET-83, cycle 3 — weighted heads, group-correlated dither, and the fix

Continuation of `Applications.NET83SuperAdditiveIntegration`, which proved

* the exact worst-case interaction cost `ε · min(1,(n−k)/k)` of combining
  top-k attention with quantization,
* the `2ε` top-k selection-stability threshold and its sharpness,
* the exact mean-square interaction `σ²(1/k − 1/n)` for centred, pairwise
  uncorrelated quantization error.

Three questions were left open there, and are answered here.

1. **Does the effect survive real (non-uniform) attention weights?**
   `NET83.meansquare_wRead` computes the transmitted variance of an arbitrary
   attention pattern as `σ²·∑ wᵢ²`, and
   `NET83.weighted_interaction_ge_sparse_floor` shows the interaction of any
   pattern supported on `k` keys is at least `σ²(1/k − 1/n)`.  Softmax heads
   are covered: nothing depends on the weights being uniform.

2. **Does GPTQ's group structure matter?**  GPTQ quantizes in groups of 128, so
   the error is correlated *inside* a group and the pairwise-uncorrelated
   hypothesis fails.  `NET83.meansquare_avgOn_grouped` gives the exact
   mean-square read under block correlation, and its two corollaries show that
   a **group-spread** selection pays only `σ²/k` while a **group-aligned**
   selection pays `σ²(1 + ρ(k−1))/k` — strictly more for `ρ > 0`.  Selecting
   keys across quantization groups is provably better.

3. **Can the interaction be removed?**  `NET83.recentering_kills_interaction`:
   if the quantization offsets are chosen so the error is centred *on the
   selected set* rather than globally, the first-order interaction cost is
   never positive, so the additive budget law becomes valid again.
-/
import Applications.NET83SuperAdditiveIntegration

namespace NET83

open Finset

variable {n : ℕ}

/-! ## 1.  Selection-aware recentering restores additivity -/

/-- **The fix.**  If the quantization error is centred on the *selected* key
set (rather than on the whole context), the combined arm loses exactly what
sparse attention alone loses, so the interaction cost is never positive and the
naive additive budget law is valid again. -/
theorem recentering_kills_interaction {v eta : Fin n → ℝ} {S : Finset (Fin n)}
    (hcent : ∑ i ∈ S, eta i = 0) :
    degAQ v eta S = degA v S ∧ interaction v eta S ≤ 0 := by
  have hzero : avgOn S eta = 0 := by simp [avgOn, hcent]
  have h1 : degAQ v eta S = degA v S := by
    unfold degAQ degA
    rw [avgOn_add S v eta, hzero, add_zero]
  refine ⟨h1, ?_⟩
  have : 0 ≤ degQ eta := abs_nonneg _
  unfold interaction
  rw [h1]
  linarith

/-- Sharper form of the fix: after recentering, the combined degradation is
*equal* to the sparse-attention degradation, so the entire quantization
penalty of the head disappears — the two axes stop interacting because the
sparse average of the error is what carried the interaction. -/
theorem recentering_interaction_eq_neg_degQ {v eta : Fin n → ℝ}
    {S : Finset (Fin n)} (hcent : ∑ i ∈ S, eta i = 0) :
    interaction v eta S = - degQ eta := by
  have h := (recentering_kills_interaction (v := v) hcent).1
  unfold interaction
  rw [h]
  ring

/-! ## 2.  Arbitrary attention patterns (softmax included) -/

/-- The output of an attention head with weight pattern `w`. -/
noncomputable def wRead (w f : Fin n → ℝ) : ℝ := ∑ i, w i * f i

section Weighted

variable {Omega : Type*} [Fintype Omega] [Nonempty Omega]

omit [Nonempty Omega] in
/-- **Transmitted quantization variance of an arbitrary attention pattern.**
For centred, pairwise uncorrelated error of variance `σ²`, a head with weights
`w` transmits exactly `σ²·∑ wᵢ²`.  Uniform dense attention gives `σ²/n`; any
`k`-sparse pattern gives at least `σ²/k`. -/
theorem meansquare_wRead (eta : Omega → Fin n → ℝ) (sigma : ℝ) (w : Fin n → ℝ)
    (hcov : ∀ i j, i ≠ j → Eavg (fun o => eta o i * eta o j) = 0)
    (hvar : ∀ i, Eavg (fun o => (eta o i) ^ 2) = sigma ^ 2) :
    Eavg (fun o => (wRead w (eta o)) ^ 2) = sigma ^ 2 * ∑ i, (w i) ^ 2 := by
  have hfun : (fun o => (wRead w (eta o)) ^ 2)
      = fun o => ∑ i, ∑ j, (w i * w j) * (eta o i * eta o j) := by
    funext o
    rw [wRead, sq, Finset.sum_mul_sum]
    exact Finset.sum_congr rfl fun i _ =>
      Finset.sum_congr rfl fun j _ => by ring
  rw [hfun, Eavg_sum univ (fun i o => ∑ j, (w i * w j) * (eta o i * eta o j))]
  have hrow : ∀ i : Fin n,
      Eavg (fun o => ∑ j, (w i * w j) * (eta o i * eta o j))
        = (w i) ^ 2 * sigma ^ 2 := by
    intro i
    rw [Eavg_sum univ (fun j o => (w i * w j) * (eta o i * eta o j))]
    rw [Finset.sum_eq_single i]
    · rw [Eavg_const_mul (w i * w i) (fun o => eta o i * eta o i)]
      have : (fun o => eta o i * eta o i) = fun o => (eta o i) ^ 2 := by
        funext o; ring
      rw [this, hvar i]; ring
    · intro j _ hne
      rw [Eavg_const_mul (w i * w j) (fun o => eta o i * eta o j),
        hcov i j (Ne.symm hne), mul_zero]
    · intro h; exact absurd (Finset.mem_univ i) h
  rw [Finset.sum_congr rfl (fun i _ => hrow i), ← Finset.sum_mul]
  ring

/-- **Softmax-ready interaction bound.**  Any normalised attention pattern
supported on `k` keys pays a mean-square interaction of at least
`σ²(1/k − 1/n)` — the uniform top-k head of the previous file is the *best*
case among all patterns with that support, not a worst case. -/
theorem weighted_interaction_ge_sparse_floor {S : Finset (Fin n)} {w : Fin n → ℝ}
    {sigma : ℝ} (hS : S.Nonempty) (hsupp : ∀ i, i ∉ S → w i = 0)
    (hw : ∑ i ∈ S, w i = 1) :
    sigma ^ 2 * (1 / (S.card : ℝ) - 1 / (n : ℝ))
      ≤ sigma ^ 2 * ∑ i, (w i) ^ 2 - sigma ^ 2 * (1 / (n : ℝ)) := by
  have hsq : ∑ i, (w i) ^ 2 = ∑ i ∈ S, (w i) ^ 2 := by
    rw [← Finset.sum_subset (Finset.subset_univ S)]
    intro i _ hi
    rw [hsupp i hi]; ring
  have hfloor : 1 / (S.card : ℝ) ≤ ∑ i ∈ S, (w i) ^ 2 :=
    sparse_noise_gain_ge_inv_card hS hw
  have hs2 : (0 : ℝ) ≤ sigma ^ 2 := sq_nonneg _
  rw [hsq]
  nlinarith [hfloor, hs2]

end Weighted

/-! ## 3.  Group-correlated quantization error (GPTQ group-128)

GPTQ shares a scale within each group of weights, so the rounding errors of a
group are correlated: `E[ηᵢηⱼ] = ρσ²` for `i ≠ j` in the same group and `0`
across groups.  The mean-square read then picks up one extra term counting the
same-group pairs inside the selected set.
-/

section Grouped

variable {Omega : Type*} [Fintype Omega] [Nonempty Omega]
variable {G : Type*} [DecidableEq G]

/-- Number of other selected keys sharing `i`'s quantization group. -/
def samePartners (S : Finset (Fin n)) (grp : Fin n → G) (i : Fin n) : ℕ :=
  ((S.erase i).filter (fun j => grp i = grp j)).card

omit [Nonempty Omega] in
/-- **Exact mean-square read under group-correlated quantization error.**
The uniform `k`-sparse head transmits `σ²/k` *plus* a correlation term
proportional to the number of same-group pairs inside the selected set. -/
theorem meansquare_avgOn_grouped (eta : Omega → Fin n → ℝ) (sigma rho : ℝ)
    (grp : Fin n → G) {S : Finset (Fin n)} (hS : S.Nonempty)
    (hcov : ∀ i j, i ≠ j →
      Eavg (fun o => eta o i * eta o j) = if grp i = grp j then rho * sigma ^ 2 else 0)
    (hvar : ∀ i, Eavg (fun o => (eta o i) ^ 2) = sigma ^ 2) :
    Eavg (fun o => (avgOn S (eta o)) ^ 2)
      = (sigma ^ 2 * S.card
          + rho * sigma ^ 2 * ∑ i ∈ S, (samePartners S grp i : ℝ))
        / (S.card : ℝ) ^ 2 := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hfun : (fun o => (avgOn S (eta o)) ^ 2)
      = fun o => (1 / (S.card : ℝ) ^ 2) * ∑ i ∈ S, ∑ j ∈ S, eta o i * eta o j := by
    funext o
    have hsq : (∑ i ∈ S, eta o i) ^ 2 = ∑ i ∈ S, ∑ j ∈ S, eta o i * eta o j := by
      rw [sq, Finset.sum_mul_sum]
    rw [avgOn, div_pow, hsq]
    field_simp
  rw [hfun, Eavg_const_mul]
  have hinner : Eavg (fun o => ∑ i ∈ S, ∑ j ∈ S, eta o i * eta o j)
      = ∑ i ∈ S, ∑ j ∈ S, Eavg (fun o => eta o i * eta o j) := by
    rw [Eavg_sum S (fun i o => ∑ j ∈ S, eta o i * eta o j)]
    exact Finset.sum_congr rfl
      (fun i _ => Eavg_sum S (fun j o => eta o i * eta o j))
  rw [hinner]
  have hrow : ∀ i ∈ S, ∑ j ∈ S, Eavg (fun o => eta o i * eta o j)
      = sigma ^ 2 + rho * sigma ^ 2 * (samePartners S grp i : ℝ) := by
    intro i hi
    rw [← Finset.add_sum_erase S _ hi]
    have hdiag : Eavg (fun o => eta o i * eta o i) = sigma ^ 2 := by
      have : (fun o => eta o i * eta o i) = fun o => (eta o i) ^ 2 := by
        funext o; ring
      rw [this, hvar i]
    have hoff : ∑ j ∈ S.erase i, Eavg (fun o => eta o i * eta o j)
        = rho * sigma ^ 2 * (samePartners S grp i : ℝ) := by
      rw [Finset.sum_congr rfl (fun j hj =>
        hcov i j (Ne.symm (Finset.ne_of_mem_erase hj)))]
      rw [← Finset.sum_filter, Finset.sum_const, nsmul_eq_mul, samePartners]
      ring
    rw [hdiag, hoff]
  rw [Finset.sum_congr rfl hrow, Finset.sum_add_distrib, Finset.sum_const,
    nsmul_eq_mul, ← Finset.mul_sum]
  field_simp

omit [Nonempty Omega] in
/-- **Group-spread selection is clean.**  If no two selected keys share a
quantization group, the group correlation is invisible and the transmitted
variance is the uncorrelated value `σ²/k`. -/
theorem meansquare_grouped_spread (eta : Omega → Fin n → ℝ) (sigma rho : ℝ)
    (grp : Fin n → G) {S : Finset (Fin n)} (hS : S.Nonempty)
    (hcov : ∀ i j, i ≠ j →
      Eavg (fun o => eta o i * eta o j) = if grp i = grp j then rho * sigma ^ 2 else 0)
    (hvar : ∀ i, Eavg (fun o => (eta o i) ^ 2) = sigma ^ 2)
    (hspread : ∀ i ∈ S, samePartners S grp i = 0) :
    Eavg (fun o => (avgOn S (eta o)) ^ 2) = sigma ^ 2 / S.card := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  rw [meansquare_avgOn_grouped eta sigma rho grp hS hcov hvar]
  have : ∑ i ∈ S, (samePartners S grp i : ℝ) = 0 := by
    rw [Finset.sum_congr rfl (fun i hi => by rw [hspread i hi])]
    simp
  rw [this]
  field_simp
  ring

omit [Nonempty Omega] in
/-- **Group-aligned selection is penalised.**  If all selected keys sit in one
quantization group, the transmitted variance is `σ²(1 + ρ(k−1))/k`, strictly
larger than the uncorrelated `σ²/k` whenever the group correlation `ρ` is
positive and the budget is at least two keys.  Engineering consequence: spread
the top-k selection across quantization groups. -/
theorem meansquare_grouped_aligned (eta : Omega → Fin n → ℝ) (sigma rho : ℝ)
    (grp : Fin n → G) {S : Finset (Fin n)} (hS : S.Nonempty)
    (hcov : ∀ i j, i ≠ j →
      Eavg (fun o => eta o i * eta o j) = if grp i = grp j then rho * sigma ^ 2 else 0)
    (hvar : ∀ i, Eavg (fun o => (eta o i) ^ 2) = sigma ^ 2)
    (halign : ∀ i ∈ S, samePartners S grp i = S.card - 1) :
    Eavg (fun o => (avgOn S (eta o)) ^ 2)
      = sigma ^ 2 * (1 + rho * ((S.card : ℝ) - 1)) / S.card := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  have hcard1 : 1 ≤ S.card := Finset.card_pos.mpr hS
  rw [meansquare_avgOn_grouped eta sigma rho grp hS hcov hvar]
  have hsum : ∑ i ∈ S, (samePartners S grp i : ℝ)
      = (S.card : ℝ) * ((S.card : ℝ) - 1) := by
    rw [Finset.sum_congr rfl (fun i hi => by rw [halign i hi])]
    rw [Finset.sum_const, nsmul_eq_mul]
    congr 1
    push_cast [Nat.cast_sub hcard1]
    ring
  rw [hsum]
  field_simp

/-- The aligned selection is strictly worse than the spread one. -/
theorem grouped_aligned_worse (sigma rho : ℝ) (k : ℕ) (hk : 2 ≤ k)
    (hsig : sigma ≠ 0) (hrho : 0 < rho) :
    sigma ^ 2 / (k : ℝ) < sigma ^ 2 * (1 + rho * ((k : ℝ) - 1)) / (k : ℝ) := by
  have hkR : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  have hkpos : (0 : ℝ) < k := by linarith
  have hs : 0 < sigma ^ 2 := by positivity
  rw [div_lt_div_iff_of_pos_right hkpos]
  nlinarith [mul_pos hs (mul_pos hrho (by linarith : (0:ℝ) < (k : ℝ) - 1))]

end Grouped

/-! ## 4.  Non-vacuity for the grouped model: shared-scale dither

GPTQ shares one scale per group, so the extreme case `ρ = 1` — the error of a
whole group moving together — is the physically relevant one.  The `2^{|G|}`
group-sign ensemble realises it, and the consequence is stark: a top-k
selection drawn from a single quantization group transmits the **full**
quantization variance `σ²`, i.e. `k` times more than the ideal `σ²/k`.
-/

section GroupRademacher

variable {G : Type*} [Fintype G] [DecidableEq G]

/-- Flip the sign of one quantization group. -/
def flipG (g : G) (w : G → Bool) : G → Bool := Function.update w g (!w g)

omit [Fintype G] in
lemma flipG_involutive (g : G) : Function.Involutive (flipG g) := by
  intro w
  funext h
  by_cases hh : h = g
  · subst hh; simp [flipG]
  · simp [flipG, Function.update_of_ne hh]

lemma sum_eq_zero_of_flipG_odd {g : G} (f : (G → Bool) → ℝ)
    (hodd : ∀ w, f (flipG g w) = - f w) : ∑ w, f w = 0 := by
  have h1 : ∑ w, f (flipG g w) = ∑ w, f w :=
    Equiv.sum_comp (Function.Involutive.toPerm _ (flipG_involutive g)) f
  rw [Finset.sum_congr rfl (fun w _ => hodd w), Finset.sum_neg_distrib] at h1
  linarith

/-- Shared-scale (group) dither: one sign per quantization group. -/
def radG (sigma : ℝ) (grp : Fin n → G) (w : G → Bool) (i : Fin n) : ℝ :=
  if w (grp i) then sigma else -sigma

lemma radG_var (sigma : ℝ) (grp : Fin n → G) (i : Fin n) :
    Eavg (fun w : G → Bool => (radG sigma grp w i) ^ 2) = sigma ^ 2 := by
  have h : (fun w : G → Bool => (radG sigma grp w i) ^ 2) = fun _ => sigma ^ 2 := by
    funext w
    by_cases hw : w (grp i) <;> simp [radG, hw]
  rw [h, Eavg_const]

/-- The shared-scale ensemble realises the block covariance with `ρ = 1`. -/
theorem radG_cov (sigma : ℝ) (grp : Fin n → G) (i j : Fin n) :
    Eavg (fun w : G → Bool => radG sigma grp w i * radG sigma grp w j)
      = if grp i = grp j then 1 * sigma ^ 2 else 0 := by
  by_cases hg : grp i = grp j
  · rw [if_pos hg]
    have h : (fun w : G → Bool => radG sigma grp w i * radG sigma grp w j)
        = fun _ => 1 * sigma ^ 2 := by
      funext w
      rw [radG, radG, hg]
      by_cases hw : w (grp j) <;> simp [hw] <;> ring
    rw [h, Eavg_const]
  · rw [if_neg hg, Eavg]
    rw [sum_eq_zero_of_flipG_odd (g := grp i) _ (fun w => ?_)]
    · simp
    · have h1 : radG sigma grp (flipG (grp i) w) i = - radG sigma grp w i := by
        simp only [radG, flipG, Function.update_self]
        cases w (grp i) <;> simp
      have h2 : radG sigma grp (flipG (grp i) w) j = radG sigma grp w j := by
        simp [radG, flipG, Function.update_of_ne (Ne.symm hg)]
      rw [h1, h2]; ring

omit [Fintype G] in
/-- A selection inside a single quantization group has every other selected key
as a same-group partner. -/
lemma samePartners_of_aligned {S : Finset (Fin n)} {grp : Fin n → G}
    (hal : ∀ i ∈ S, ∀ j ∈ S, grp i = grp j) {i : Fin n} (hi : i ∈ S) :
    samePartners S grp i = S.card - 1 := by
  rw [samePartners, Finset.filter_true_of_mem
    (fun j hj => hal i hi j (Finset.mem_of_mem_erase hj)),
    Finset.card_erase_of_mem hi]

/-- **Worst case of the grouped model.**  Under shared-scale (`ρ = 1`) group
dither, a top-k selection drawn from a single quantization group transmits the
*entire* quantization variance `σ²`: the sparse weighted sum averages nothing
at all, losing the whole `1/k` factor.  Spreading the same `k` keys across
distinct groups restores `σ²/k` (`meansquare_grouped_spread`). -/
theorem radG_aligned_full_variance (sigma : ℝ) (grp : Fin n → G)
    {S : Finset (Fin n)} (hS : S.Nonempty)
    (halign : ∀ i ∈ S, ∀ j ∈ S, grp i = grp j) :
    Eavg (fun w : G → Bool => (avgOn S (radG sigma grp w)) ^ 2) = sigma ^ 2 := by
  have hcard : (0 : ℝ) < S.card := by exact_mod_cast Finset.card_pos.mpr hS
  rw [meansquare_grouped_aligned (fun w => radG sigma grp w) sigma 1 grp hS
    (fun i j _ => radG_cov sigma grp i j) (radG_var sigma grp)
    (fun i hi => samePartners_of_aligned halign hi)]
  field_simp
  ring

end GroupRademacher

end NET83