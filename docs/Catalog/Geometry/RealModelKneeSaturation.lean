import Mathlib
import Shared.AttentionBudgetKnee
import Probability.AttentionConcentration

/-!
# NET-49: the real-model knee collapses and saturates

Formal companion to NET-49 (paper 134): on Qwen2.5-0.5B the lossless top-`k`
attention knee is `k* = 16, 32, 24` at `ctx = 512, 1024, 2048`, far below the toy
law `d · ctx / 32` (`d = 24` layers).  This file isolates three structural
mechanisms that the measurement points to, building on the catalog theory of
`Shared.AttentionBudgetKnee` (`headMass`, `retained`, `kstar`).

## 1. The depth multiplier is a *sum* of per-layer deficits

If a forward pass retains a fraction `1 - δ_l` of its information at each layer
and these compound multiplicatively, then the compounded retention `R = ∏ (1 - δ_l)`
obeys the two-sided sandwich (`compRetention_sandwich`)

    1 - D ≤ R ≤ 1 / (1 + D),        D = ∑ δ_l.

So the gate `R ≥ g` is controlled, up to the constant factor `g`, by the *total*
deficit `D` (`gate_of_deficit_le`, `deficit_le_of_gate`).  For the toy power-law
tail `δ_l(k) = c / (c + k)` on all `d` layers this pins the depth-compounded knee
into the window `g d c/(1-g) - c ≤ k* ≤ ⌈d c/(1-g)⌉` (`toy_depth_knee_lower`,
`toy_depth_knee_upper`): the knee is linear in `d` — the toy *depth multiplier*.
If only `m` layers carry the tail and all others are lossless once `k ≥ k₀`
(NET-49: only L22/L23 are diffuse, the median layer has support ≈ 10–12 keys), then
`k* ≤ max k₀ ⌈m c/(1-g)⌉` for **every** depth `d` (`collapsed_depth_knee_upper`):
the depth multiplier collapses from `d` to `m`.

## 2. A fixed profile can only saturate, never decline

For a fixed positive sorted profile, retained mass is antitone in the context
length (`retained_antitone_context`), so the knee is monotone in the context
(`kstar_mono_context`).  Consequently the reported step `32 → 24` is impossible
for one context-extending profile (`knee_decline_forces_profile_change`), and in
the geometric-decay regime the knee sequence is *eventually constant*
(`kstar_eventually_constant_of_geometric_decay`): saturation is the only possible
long-context behaviour.  Critic note: the 1024 knee is only bracketed in
`(16, 32]` (`net49_brackets`), so the measured "decline" is not certified — the
data are equally consistent with flat saturation at `24`.

## 3. Selection importance

For a sorted (antitone) profile the top-`k` share always beats the uniform share
`k/n` (`uniform_share_le_retained`) — the share that a uniformly random `k`-subset
gets in expectation.  For a gapless profile (weights in `[c, M]`) the selection gap
is at most `k (M - c)/(n c)` (`selection_gap_le_of_band`), vanishing as `n` grows,
whereas at a knee the gap is at least `τ - k*/n` (`selection_gap_at_knee`); at the
NET-49 operating point `τ = 0.98`, `k* = 24`, `n = 2048` this is `> 0.968`
(`net49_selection_gap`).  That is the formal shape of the order-of-magnitude
inflation of the random-`k` gap.
-/

namespace RealModelKnee

open Finset AttentionBudget

/-! ## 1. Depth compounding -/

section Depth

variable {ι : Type*}

/-- Compounded retention of a stack of layers with per-layer deficits `δ`. -/
def compRetention (s : Finset ι) (δ : ι → ℝ) : ℝ := ∏ l ∈ s, (1 - δ l)

/-- Weierstrass product inequality: `1 - ∑ δ ≤ ∏ (1 - δ)`. -/
theorem one_sub_sum_le_compRetention (s : Finset ι) (δ : ι → ℝ)
    (h0 : ∀ l ∈ s, 0 ≤ δ l) (h1 : ∀ l ∈ s, δ l ≤ 1) :
    1 - ∑ l ∈ s, δ l ≤ compRetention s δ := by
  classical
  unfold compRetention
  induction s using Finset.induction_on with
  | empty => simp
  | insert j s hj ih =>
    rw [prod_insert hj, sum_insert hj]
    have ih' := ih (fun l hl => h0 l (mem_insert_of_mem hl))
      (fun l hl => h1 l (mem_insert_of_mem hl))
    have ha0 := h0 j (mem_insert_self j s)
    have ha1 := h1 j (mem_insert_self j s)
    have hS : 0 ≤ ∑ l ∈ s, δ l := sum_nonneg fun l hl => h0 l (mem_insert_of_mem hl)
    have h1a : 0 ≤ 1 - δ j := by linarith
    nlinarith [mul_le_mul_of_nonneg_left ih' h1a, mul_nonneg ha0 hS]

/-- Compounded retention lies in `[0, 1]`. -/
theorem compRetention_mem_Icc (s : Finset ι) (δ : ι → ℝ)
    (h0 : ∀ l ∈ s, 0 ≤ δ l) (h1 : ∀ l ∈ s, δ l ≤ 1) :
    0 ≤ compRetention s δ ∧ compRetention s δ ≤ 1 := by
  unfold compRetention
  refine ⟨prod_nonneg fun l hl => by linarith [h1 l hl], ?_⟩
  exact prod_le_one (fun l hl => by linarith [h1 l hl]) (fun l hl => by linarith [h0 l hl])

/-- Upper half of the sandwich: `∏ (1 - δ) · (1 + ∑ δ) ≤ 1`. -/
theorem compRetention_mul_one_add_sum_le (s : Finset ι) (δ : ι → ℝ)
    (h0 : ∀ l ∈ s, 0 ≤ δ l) (h1 : ∀ l ∈ s, δ l ≤ 1) :
    compRetention s δ * (1 + ∑ l ∈ s, δ l) ≤ 1 := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [compRetention]
  | insert j s hj ih =>
    have h0' : ∀ l ∈ s, 0 ≤ δ l := fun l hl => h0 l (mem_insert_of_mem hl)
    have h1' : ∀ l ∈ s, δ l ≤ 1 := fun l hl => h1 l (mem_insert_of_mem hl)
    have ih' := ih h0' h1'
    have hP := compRetention_mem_Icc s δ h0' h1'
    have ha0 := h0 j (mem_insert_self j s)
    have ha1 := h1 j (mem_insert_self j s)
    have hS : 0 ≤ ∑ l ∈ s, δ l := sum_nonneg h0'
    have hrw : compRetention (insert j s) δ = (1 - δ j) * compRetention s δ := by
      simp [compRetention, prod_insert hj]
    rw [hrw, sum_insert hj]
    set P := compRetention s δ
    set S := ∑ l ∈ s, δ l
    have h1a : 0 ≤ 1 - δ j := by linarith
    have e : (1 - δ j) * P * (1 + (δ j + S)) =
        (1 - δ j) * (P * (1 + S)) + δ j * (1 - δ j) * P := by ring
    rw [e]
    nlinarith [mul_le_mul_of_nonneg_left ih' h1a,
      mul_le_mul_of_nonneg_left hP.2 (mul_nonneg ha0 h1a)]

/-- **Two-sided sandwich.**  `1 - D ≤ R ≤ 1/(1 + D)` with `D = ∑ δ_l`. -/
theorem compRetention_sandwich (s : Finset ι) (δ : ι → ℝ)
    (h0 : ∀ l ∈ s, 0 ≤ δ l) (h1 : ∀ l ∈ s, δ l ≤ 1) :
    1 - ∑ l ∈ s, δ l ≤ compRetention s δ ∧
      compRetention s δ ≤ 1 / (1 + ∑ l ∈ s, δ l) := by
  have hS : 0 ≤ ∑ l ∈ s, δ l := sum_nonneg h0
  refine ⟨one_sub_sum_le_compRetention s δ h0 h1, ?_⟩
  rw [le_div_iff₀ (by linarith)]
  exact compRetention_mul_one_add_sum_le s δ h0 h1

/-- Sufficiency: a total deficit within `1 - g` clears the gate. -/
theorem gate_of_deficit_le (s : Finset ι) (δ : ι → ℝ)
    (h0 : ∀ l ∈ s, 0 ≤ δ l) (h1 : ∀ l ∈ s, δ l ≤ 1) {g : ℝ}
    (hD : ∑ l ∈ s, δ l ≤ 1 - g) : g ≤ compRetention s δ := by
  have := one_sub_sum_le_compRetention s δ h0 h1
  linarith

/-- Necessity: clearing the gate forces `g · D ≤ 1 - g`. -/
theorem deficit_le_of_gate (s : Finset ι) (δ : ι → ℝ)
    (h0 : ∀ l ∈ s, 0 ≤ δ l) (h1 : ∀ l ∈ s, δ l ≤ 1) {g : ℝ}
    (hpass : g ≤ compRetention s δ) : g * ∑ l ∈ s, δ l ≤ 1 - g := by
  have h := compRetention_mul_one_add_sum_le s δ h0 h1
  have hS : 0 ≤ ∑ l ∈ s, δ l := sum_nonneg h0
  nlinarith [mul_le_mul_of_nonneg_right hpass (by linarith : (0:ℝ) ≤ 1 + ∑ l ∈ s, δ l)]

/-- The toy power-law tail deficit `c/(c+k)` of a layer at key budget `k`. -/
noncomputable def tailDeficit (c : ℝ) (k : ℕ) : ℝ := c / (c + k)

lemma tailDeficit_nonneg {c : ℝ} (hc : 0 < c) (k : ℕ) : 0 ≤ tailDeficit c k := by
  unfold tailDeficit; positivity

lemma tailDeficit_le_one {c : ℝ} (hc : 0 < c) (k : ℕ) : tailDeficit c k ≤ 1 := by
  unfold tailDeficit
  rw [div_le_one (by positivity)]
  linarith [(Nat.cast_nonneg k : (0:ℝ) ≤ k)]

/-- Depth-compounded knee of a stack whose layer `l` has deficit `δ l k` at budget `k`. -/
noncomputable def depthKnee (s : Finset ι) (δ : ι → ℕ → ℝ) (g : ℝ) : ℕ :=
  sInf {k | g ≤ compRetention s (fun l => δ l k)}

/-- **Toy depth multiplier, lower bound.**  If all `d` layers carry the tail
`c/(c+k)`, then any passing budget satisfies `g d c/(1-g) - c ≤ k`. -/
theorem toy_pass_lower {c g : ℝ} (hc : 0 < c) (hg1 : g < 1)
    (s : Finset ι) {k : ℕ}
    (hpass : g ≤ compRetention s (fun _ => tailDeficit c k)) :
    g * s.card * c / (1 - g) - c ≤ k := by
  have h := deficit_le_of_gate s (fun _ => tailDeficit c k)
    (fun _ _ => tailDeficit_nonneg hc k) (fun _ _ => tailDeficit_le_one hc k) hpass
  simp only [sum_const, nsmul_eq_mul, tailDeficit] at h
  have hck : 0 < c + k := by positivity
  have h1g : 0 < 1 - g := by linarith
  rw [sub_le_iff_le_add, div_le_iff₀ h1g]
  have : g * (s.card * c) ≤ (1 - g) * (c + k) := by
    have := mul_le_mul_of_nonneg_right h hck.le
    rw [show g * (s.card * (c / (c + k))) * (c + k) = g * (s.card * c) by
      field_simp] at this
    linarith
  nlinarith

/-- **Toy depth multiplier, upper bound.**  Budget `k ≥ d c/(1-g)` always passes. -/
theorem toy_pass_upper {c g : ℝ} (hc : 0 < c) (hg1 : g < 1)
    (s : Finset ι) {k : ℕ} (hk : s.card * c / (1 - g) ≤ k) :
    g ≤ compRetention s (fun _ => tailDeficit c k) := by
  apply gate_of_deficit_le _ _ (fun _ _ => tailDeficit_nonneg hc k)
    (fun _ _ => tailDeficit_le_one hc k)
  simp only [sum_const, nsmul_eq_mul, tailDeficit]
  have h1g : 0 < 1 - g := by linarith
  have hck : 0 < c + k := by positivity
  rw [div_le_iff₀ h1g] at hk
  rw [← mul_div_assoc, div_le_iff₀ hck]
  nlinarith

/-- The toy depth-compounded knee is at least `g d c/(1-g) - c`: linear in depth. -/
theorem toy_depth_knee_lower {c g : ℝ} (hc : 0 < c) (hg1 : g < 1)
    (s : Finset ι) :
    g * s.card * c / (1 - g) - c ≤ depthKnee s (fun _ k => tailDeficit c k) g := by
  have hne : {k | g ≤ compRetention s (fun _ => tailDeficit c k)}.Nonempty :=
    ⟨⌈s.card * c / (1 - g)⌉₊, toy_pass_upper hc hg1 s (Nat.le_ceil _)⟩
  exact toy_pass_lower hc hg1 s (Nat.sInf_mem hne)

/-- The toy depth-compounded knee is at most `⌈d c/(1-g)⌉`. -/
theorem toy_depth_knee_upper {c g : ℝ} (hc : 0 < c) (hg1 : g < 1) (s : Finset ι) :
    depthKnee s (fun _ k => tailDeficit c k) g ≤ ⌈s.card * c / (1 - g)⌉₊ :=
  Nat.sInf_le (toy_pass_upper hc hg1 s (Nat.le_ceil _))

/-- **Depth-multiplier collapse.**  Suppose only the layers in `T ⊆ s` (`m = |T|`)
carry a tail deficit at most `c/(c+k)`, and every other layer is lossless once
`k ≥ k₀`.  Then the compounded knee is at most `max k₀ ⌈m c/(1-g)⌉`, uniformly in
the total depth `|s|`. -/
theorem collapsed_depth_knee_upper {c g : ℝ} (hc : 0 < c) (hg1 : g < 1)
    (s T : Finset ι) (hT : T ⊆ s) (δ : ι → ℕ → ℝ) (k₀ : ℕ)
    (h0 : ∀ l ∈ s, ∀ k, 0 ≤ δ l k) (h1 : ∀ l ∈ s, ∀ k, δ l k ≤ 1)
    (htail : ∀ l ∈ T, ∀ k, δ l k ≤ tailDeficit c k)
    (hlossless : ∀ l ∈ s, l ∉ T → ∀ k, k₀ ≤ k → δ l k = 0) :
    depthKnee s δ g ≤ max k₀ ⌈T.card * c / (1 - g)⌉₊ := by
  classical
  set K := max k₀ ⌈T.card * c / (1 - g)⌉₊
  apply Nat.sInf_le
  show g ≤ compRetention s (fun l => δ l K)
  apply gate_of_deficit_le _ _ (fun l hl => h0 l hl K) (fun l hl => h1 l hl K)
  have hsplit : ∑ l ∈ s, δ l K = ∑ l ∈ T, δ l K := by
    symm
    apply sum_subset hT
    intro l hl hlT
    exact hlossless l hl hlT K (le_max_left _ _)
  rw [hsplit]
  have hTsum : ∑ l ∈ T, δ l K ≤ T.card * tailDeficit c K := by
    have := sum_le_sum (fun l hl => htail l hl K)
    simpa [sum_const, nsmul_eq_mul] using this
  have h1g : 0 < 1 - g := by linarith
  have hck : 0 < c + (K : ℝ) := by positivity
  have hK : T.card * c / (1 - g) ≤ (K : ℝ) :=
    le_trans (Nat.le_ceil _) (by exact_mod_cast le_max_right _ _)
  have : (T.card : ℝ) * tailDeficit c K ≤ 1 - g := by
    unfold tailDeficit
    rw [div_le_iff₀ h1g] at hK
    rw [← mul_div_assoc, div_le_iff₀ hck]
    nlinarith
  linarith

end Depth

/-! ## 2. Context monotonicity and saturation of the knee -/

section Context

variable {w : ℕ → ℝ} (hw : ∀ i, 0 < w i)
include hw

/-- Retained mass of a fixed profile is antitone in the context length. -/
theorem retained_antitone_context {n m : ℕ} (hn : 0 < n) (hnm : n ≤ m) (k : ℕ) :
    retained w m k ≤ retained w n k := by
  rcases le_or_gt k n with hkn | hkn
  · have hm : 0 < m := lt_of_lt_of_le hn hnm
    unfold retained
    rw [min_eq_left hkn, min_eq_left (hkn.trans hnm)]
    apply div_le_div_of_nonneg_left (headMass_nonneg hw k) (headMass_pos hw hn)
    exact headMass_mono hw hnm
  · rw [show retained w n k = 1 by
      unfold retained; rw [min_eq_right hkn.le]; exact div_self (headMass_pos hw hn).ne']
    exact retained_le_one hw m k (lt_of_lt_of_le hn hnm)

/-- **The knee of a fixed profile is monotone in the context length.** -/
theorem kstar_mono_context {τ : ℝ} {n m : ℕ} (hn : 0 < n) (hnm : n ≤ m) (hτ : τ ≤ 1) :
    kstar w n τ ≤ kstar w m τ :=
  kstar_le_of_pass ((gate_le_retained_kstar hw (lt_of_lt_of_le hn hnm) hτ).trans
    (retained_antitone_context hw hn hnm _))

omit hw in
/-- A knee that *declines* with context certifies that the attention profile itself
changed: no single context-extending positive profile can produce it. -/
theorem knee_decline_forces_profile_change {w' : ℕ → ℝ} {τ : ℝ} {n m : ℕ}
    (hw' : ∀ i, 0 < w' i) (hn : 0 < n) (hnm : n ≤ m) (hτ : τ ≤ 1)
    (hdecl : kstar w' m τ < kstar w n τ) : w' ≠ w := by
  rintro rfl
  have := kstar_mono_context hw' hn hnm hτ
  omega

/-- **Saturation.**  Under geometric decay of the sorted profile the knee is
eventually constant in the context length. -/
theorem kstar_eventually_constant_of_geometric_decay {r τ : ℝ} (hr0 : 0 < r) (hr1 : r < 1)
    (hdec : ∀ i, w (i + 1) ≤ r * w i) (hτ : τ < 1) :
    ∃ K N : ℕ, ∀ n, N ≤ n → kstar w n τ = K := by
  obtain ⟨B, -, hB⟩ := kstar_uniformly_bounded_of_geometric_decay hw hr0 hr1 hdec hτ
  set f : ℕ → ℕ := fun n => kstar w (n + 1) τ
  have hmono : Monotone f := fun a b hab =>
    kstar_mono_context hw (Nat.succ_pos a) (by omega) hτ.le
  have hbdd : BddAbove (Set.range f) := ⟨B, by
    rintro _ ⟨n, rfl⟩; exact hB (n + 1) (by omega)⟩
  obtain ⟨N, hN⟩ : sSup (Set.range f) ∈ Set.range f :=
    Nat.sSup_mem (Set.range_nonempty f) hbdd
  refine ⟨sSup (Set.range f), N + 1, fun n hn => ?_⟩
  have h1 : f N ≤ f (n - 1) := hmono (by omega)
  have h2 : f (n - 1) ≤ sSup (Set.range f) := le_csSup hbdd ⟨n - 1, rfl⟩
  have hfn : f (n - 1) = kstar w n τ := by
    simp only [f]; congr 1; omega
  omega

end Context

/-- **Critic: the NET-49 brackets.**  Whatever retention curves underlie the sweeps,
monotonicity alone turns the measured fail/pass pairs into the brackets
`k*(1024) ∈ (16, 32]` and `k*(2048) ∈ (16, 24]`; these brackets overlap, so the
reported decline is not certified by the data. -/
theorem net49_brackets (ret₁ ret₂ : ℕ → ℝ)
    (k₁ k₂ : ℕ) (hk₁ : ∀ k, 0.98 ≤ ret₁ k ↔ k₁ ≤ k) (hk₂ : ∀ k, 0.98 ≤ ret₂ k ↔ k₂ ≤ k)
    (f₁ : ret₁ 16 < 0.98) (p₁ : 0.98 ≤ ret₁ 32)
    (f₂ : ret₂ 16 < 0.98) (p₂ : 0.98 ≤ ret₂ 24) :
    (16 < k₁ ∧ k₁ ≤ 32) ∧ (16 < k₂ ∧ k₂ ≤ 24) ∧
      ∃ k, (16 < k ∧ k ≤ 32) ∧ (16 < k ∧ k ≤ 24) := by
  refine ⟨⟨?_, (hk₁ 32).1 p₁⟩, ⟨?_, (hk₂ 24).1 p₂⟩, 24, by omega, by omega⟩
  · by_contra h; exact absurd ((hk₁ 16).2 (by omega)) (not_le.2 f₁)
  · by_contra h; exact absurd ((hk₂ 16).2 (by omega)) (not_le.2 f₂)

/-! ## 3. Selection importance -/

section Selection

variable {w : ℕ → ℝ}

/-- Chebyshev prefix inequality: for an antitone nonnegative profile the average of
the first `k` weights dominates the average of the first `n ≥ k`. -/
theorem prefix_average_antitone (hanti : ∀ i, w (i + 1) ≤ w i) {k n : ℕ} (hkn : k ≤ n) :
    (k : ℝ) * headMass w n ≤ n * headMass w k := by
  have hanti' : Antitone w := antitone_nat_of_succ_le hanti
  induction n, hkn using Nat.le_induction with
  | base => ring_nf; rfl
  | succ n hkn ih =>
    have hstep : (k : ℝ) * w n ≤ headMass w k := by
      have : ∑ _i ∈ range k, w n ≤ ∑ i ∈ range k, w i :=
        sum_le_sum fun i hi => hanti' (by simp at hi; omega)
      simpa [headMass, sum_const, nsmul_eq_mul] using this
    have hH : headMass w (n + 1) = headMass w n + w n := by
      simp [headMass, sum_range_succ]
    rw [hH]; push_cast
    nlinarith

/-- **Top-`k` beats the uniform share.**  For a positive sorted profile the
retained top-`k` mass is at least `k/n`. -/
theorem uniform_share_le_retained (hw : ∀ i, 0 < w i) (hanti : ∀ i, w (i + 1) ≤ w i)
    {k n : ℕ} (hn : 0 < n) (hkn : k ≤ n) :
    (k : ℝ) / n ≤ retained w n k := by
  unfold retained
  rw [min_eq_left hkn, div_le_div_iff₀ (by exact_mod_cast hn) (headMass_pos hw hn)]
  linarith [prefix_average_antitone hanti hkn]

/-- Selection gap: top-`k` retained mass minus the uniform (random-`k`) share. -/
noncomputable def selectionGap (w : ℕ → ℝ) (n k : ℕ) : ℝ := retained w n k - k / n

/-- **Gapless profiles have a vanishing selection gap**: with weights in `[c, M]`,
`selectionGap ≤ k (M - c)/(n c)`. -/
theorem selection_gap_le_of_band (hw : ∀ i, 0 < w i) {c M : ℝ} (hc : 0 < c)
    (hlow : ∀ i, c ≤ w i) (hhigh : ∀ i, w i ≤ M) {k n : ℕ} (hn : 0 < n) (hkn : k ≤ n) :
    selectionGap w n k ≤ k * (M - c) / (n * c) := by
  have hnr : (0 : ℝ) < n := by exact_mod_cast hn
  have hH : (n : ℝ) * c ≤ headMass w n := by
    have : ∑ _i ∈ range n, c ≤ ∑ i ∈ range n, w i := sum_le_sum fun i _ => hlow i
    simpa [headMass, sum_const, nsmul_eq_mul] using this
  have hK : headMass w k ≤ k * M := by
    have : ∑ i ∈ range k, w i ≤ ∑ _i ∈ range k, M := sum_le_sum fun i _ => hhigh i
    simpa [headMass, sum_const, nsmul_eq_mul] using this
  have hHp := headMass_pos hw hn
  have hret : retained w n k ≤ k * M / (n * c) := by
    unfold retained
    rw [min_eq_left hkn, div_le_div_iff₀ hHp (by positivity)]
    have hk0 : (0 : ℝ) ≤ k * M := by
      have := (hc.trans_le ((hlow 0).trans (hhigh 0))).le; positivity
    nlinarith [mul_le_mul_of_nonneg_left hH hk0,
      mul_le_mul_of_nonneg_right hK (by positivity : (0:ℝ) ≤ n * c)]
  unfold selectionGap
  have : k * M / (n * c) - k / n = k * (M - c) / (n * c) := by
    field_simp
  linarith

/-- **The selection gap at a knee** is at least `τ - k*/n`. -/
theorem selection_gap_at_knee (hw : ∀ i, 0 < w i) {τ : ℝ} {n : ℕ} (hn : 0 < n)
    (hτ : τ ≤ 1) :
    τ - (kstar w n τ : ℝ) / n ≤ selectionGap w n (kstar w n τ) := by
  unfold selectionGap
  linarith [gate_le_retained_kstar hw hn hτ]

/-- At the NET-49 operating point (`τ = 0.98`, `n = 2048`) a knee of `24` forces a
selection gap above `0.968` in retained-mass units, while any gapless band profile
with `M/c ≤ 2` has gap below `0.012`. -/
theorem net49_selection_gap (hw : ∀ i, 0 < w i) (hknee : kstar w 2048 0.98 = 24) :
    0.968 < selectionGap w 2048 24 ∧
      ∀ v : ℕ → ℝ, (∀ i, 0 < v i) → ∀ c M : ℝ, 0 < c → (∀ i, c ≤ v i) →
        (∀ i, v i ≤ M) → M ≤ 2 * c → selectionGap v 2048 24 < 0.012 := by
  refine ⟨?_, ?_⟩
  · have h := selection_gap_at_knee hw (n := 2048) (τ := 0.98) (by norm_num) (by norm_num)
    rw [hknee] at h
    norm_num at h ⊢
    linarith
  · intro v hv c M hc hlow hhigh hM
    have h := selection_gap_le_of_band hv hc hlow hhigh (k := 24) (n := 2048)
      (by norm_num) (by norm_num)
    have : (24 : ℝ) * (M - c) / (2048 * c) ≤ 24 / 2048 := by
      rw [div_le_div_iff₀ (by positivity) (by norm_num)]
      nlinarith
    push_cast at h
    linarith [show (24 : ℝ) / 2048 < 0.012 by norm_num]

end Selection

/-! ## 4. Iteration 2: the depth map in mass units

NET-49 measured the effective support `N_eff = 1/∑ p²` per layer: ≈ 10–12 keys
for the median layer, but `128.5` for L22 at `ctx = 2048`.  Combining with the
catalog Cauchy–Schwarz bound (`AttentionConcentration.sq_subset_mass_le`), the
`24`-key knee necessarily drops more than half of L22's attention mass, so the
accuracy knee is *not* a mass knee in the diffuse tail layers: their diffusion is
not load-bearing at the level of mass. -/

section DepthMap

open AttentionConcentration

variable {ι : Type*}

/-- In any layer with effective support `N`, a retained set of `≤ k` keys carries
mass squared at most `k / N`. -/
theorem retained_sq_le_of_effSupport (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    {k : ℕ} (hk : T.card ≤ k) {N : ℝ} (hN : 0 < N) (hE : effSupport s p = N) :
    (∑ i ∈ T, p i) ^ 2 ≤ k / N := by
  have hc : collision s p = 1 / N := by
    unfold effSupport at hE
    have hc0 : collision s p ≠ 0 := by
      intro h; rw [h] at hE; simp at hE; linarith
    field_simp at hE ⊢; linarith
  have h := sq_subset_mass_le s T p hT
  rw [hc] at h
  have : (T.card : ℝ) * (1 / N) ≤ k * (1 / N) :=
    mul_le_mul_of_nonneg_right (by exact_mod_cast hk) (by positivity)
  calc (∑ i ∈ T, p i) ^ 2 ≤ T.card * (1 / N) := h
    _ ≤ k * (1 / N) := this
    _ = k / N := by ring

/-- **L22 at the knee.**  With `N_eff = 128.5`, any `24`-key truncation keeps
less than `43.3 %` of that layer's attention mass. -/
theorem net49_L22_mass_at_knee (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hp : ∀ i ∈ s, 0 ≤ p i) (hk : T.card ≤ 24) (hE : effSupport s p = 128.5) :
    ∑ i ∈ T, p i < 0.433 := by
  have h := retained_sq_le_of_effSupport s T p hT hk (by norm_num) hE
  have hnn : 0 ≤ ∑ i ∈ T, p i := sum_nonneg fun i hi => hp i (hT hi)
  norm_num at h
  nlinarith

/-- **Median layer.**  With `N_eff = 12`, retaining `98 %` of the mass needs at
least `12` keys, so the median-layer mass knee is context-independent and of the
same order as the measured accuracy knee. -/
theorem net49_median_layer_mass_knee (s T : Finset ι) (p : ι → ℝ) (hT : T ⊆ s)
    (hE : effSupport s p = 12) (h98 : 0.98 ≤ ∑ i ∈ T, p i) : 12 ≤ T.card := by
  have hc : 0 < collision s p := by
    unfold effSupport at hE
    rcases (collision_nonneg s p).lt_or_eq with h | h
    · exact h
    · rw [← h] at hE; simp at hE
  have h := card_ge_of_retained s T p hT hc (by norm_num) h98
  rw [hE] at h
  have : (11 : ℝ) < T.card := by norm_num at h; linarith
  exact_mod_cast this

end DepthMap

end RealModelKnee