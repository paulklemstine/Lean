import Shared.AttentionBudgetKnee

/-!
# Scaling laws for the attention budget: closed form, head merging, and the limits of
"flatness"

This is the second research cycle built on `Shared.AttentionBudgetKnee`.  Three
questions left open there are settled here.

1. **Closed form for the universal budget.**  `kstar_le_geometricBudget` replaces the
   existence statement of cycle 1 by the explicit value
   `K(r, τ) = max ⌈log((1-τ)(1-r)) / log r⌉ 1`, valid at *every* context length.
   Solving the formula for `r` turns a measured knee into a bound on the decay ratio of
   the attention profile, a model-internal quantity: the knee is a *spectrometer*.

2. **Is the flat chain literally flat?**  No.  `exact_flatness_refuted` computes the
   knee of the ideal geometric profile `(1/2)^i` at two context lengths and finds
   `k*(1) = 1 ≠ 2 = k*(2)`.  The normaliser grows with the context, so the retained
   fraction is *antitone* in `n` (`retained_antitone_context`).  Hence an observed
   `{16, 16}` cannot be upgraded to an equality law; the correct invariant is uniform
   boundedness, characterised by `ctxStable_iff_uniform_pass`.

3. **What happens when heads are merged?**  Context stability is closed under mixing
   (`ctxStable_add`): the knee of a two-head mixture is sandwiched between the two
   per-head knees (`min_le_kstar_add`, `kstar_add_le_max`), because retained mass is a
   *mediant* of the per-head retained masses (`retained_add_ge_min`,
   `retained_add_le_max`).  A context-stable model therefore cannot be destabilised by
   adding further context-stable heads — while by `kstar_ge_of_bounded_ratio` a single
   gapless head already destroys stability (`not_ctxStable_uniform`).  Stability is a
   property of the *worst* head: a max law, not a sum law.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 2):
 (H6) The budget admits a closed form in `(r, τ)` alone — no dependence on context
      length or on the head count.                                          [BOLD]
 (H7) Exact flatness `k*(2n) = k*(n)` is false even for the ideal geometric
      profile; only boundedness survives.
 (H8) Context stability is closed under head mixing and is decided by the worst
      head (a max law, not a sum law).                                      [BOLD]

Experimenter: H6 = `kstar_le_geometricBudget`; H7 = `exact_flatness_refuted`
(explicit computation: retained mass `2/3 < 3/4` at `k = 1`, `n = 2`, while the same
gate is cleared at `n = 1` by `k = 1`); H8 = `ctxStable_add` via the mediant
inequality.  All proved, zero sorries.

Analyst: the mediant inequality is the structural reason a *max* law appears rather
than a sum law: `(A₁+A₂)/(B₁+B₂)` is squeezed between `A₁/B₁` and `A₂/B₂`, so mixing is
never worse than the worst head.  This predicts that per-head knees measured separately
should bracket the model-level knee — a directly testable consequence.

Critic: `exact_flatness_refuted` is a genuine falsification, not a corner case: the
profile is the canonical geometric one and the gate `3/4` is interior.  Its moral is
that any claimed "flat chain" must be reported as a bracket, exactly as `knee_bracket`
demands.
-/

namespace AttentionBudget

open Finset

/-! ## Context stability -/

/-- A profile is *context stable* at gate `τ` when one finite key budget clears the gate
at every context length. -/
def CtxStable (w : ℕ → ℝ) (τ : ℝ) : Prop := ∃ K : ℕ, ∀ n : ℕ, 1 ≤ n → kstar w n τ ≤ K

/-- Context stability is equivalent to a single budget passing the gate at every context
length: the knee formulation and the mass formulation agree. -/
theorem ctxStable_iff_uniform_pass {w : ℕ → ℝ} {τ : ℝ} (hw : ∀ i, 0 < w i) (hτ : τ ≤ 1) :
    CtxStable w τ ↔ ∃ K : ℕ, ∀ n : ℕ, 1 ≤ n → τ ≤ retained w n K := by
  constructor
  · rintro ⟨K, hK⟩
    exact ⟨K, fun n hn =>
      le_trans (gate_le_retained_kstar hw hn hτ) (retained_mono hw n (hK n hn))⟩
  · rintro ⟨K, hK⟩
    exact ⟨K, fun n hn => kstar_le_of_pass (hK n hn)⟩

/-! ## A closed form for the universal budget -/

/-- The explicit budget predicted by a decay ratio `r` and a gate `τ`. -/
noncomputable def geometricBudget (r τ : ℝ) : ℕ :=
  max ⌈Real.log ((1 - τ) * (1 - r)) / Real.log r⌉₊ 1

/-- **H6 — closed-form universal budget.**  For a profile with decay ratio `r < 1` the
knee never exceeds `geometricBudget r τ`, at any context length. -/
theorem kstar_le_geometricBudget {w : ℕ → ℝ} {r τ : ℝ} (hw : ∀ i, 0 < w i) (hr0 : 0 < r)
    (hr1 : r < 1) (hdec : ∀ i, w (i + 1) ≤ r * w i) (hτ : τ < 1) {n : ℕ} (hn : 1 ≤ n) :
    kstar w n τ ≤ geometricBudget r τ := by
  set K := geometricBudget r τ with hKdef
  have hr1' : (0 : ℝ) < 1 - r := by linarith
  have hc : 0 < (1 - τ) * (1 - r) := mul_pos (by linarith) hr1'
  have hlogr : Real.log r < 0 := Real.log_neg hr0 hr1
  have hKge : Real.log ((1 - τ) * (1 - r)) / Real.log r ≤ (K : ℝ) := by
    refine le_trans (Nat.le_ceil _) ?_
    have : (⌈Real.log ((1 - τ) * (1 - r)) / Real.log r⌉₊ : ℕ) ≤ K := le_max_left _ _
    exact_mod_cast this
  have hmul : (K : ℝ) * Real.log r ≤ Real.log ((1 - τ) * (1 - r)) := by
    rwa [div_le_iff_of_neg hlogr] at hKge
  have hpow : r ^ K ≤ (1 - τ) * (1 - r) := by
    have hlp : Real.log (r ^ K) = (K : ℝ) * Real.log r := by rw [Real.log_pow]
    exact (Real.log_le_log_iff (pow_pos hr0 K) hc).mp (by rw [hlp]; exact hmul)
  have hK1 : 1 ≤ K := le_max_right _ _
  have hdivle : r ^ K / (1 - r) ≤ 1 - τ := by
    rw [div_le_iff₀ hr1']
    linarith
  exact kstar_le_of_pass
    (le_trans (by linarith) (retained_ge_of_geometric_decay hw hr0 hr1 hdec hK1 hn))

/-- Geometric profiles are context stable. -/
theorem ctxStable_of_geometric_decay {w : ℕ → ℝ} {r τ : ℝ} (hw : ∀ i, 0 < w i) (hr0 : 0 < r)
    (hr1 : r < 1) (hdec : ∀ i, w (i + 1) ≤ r * w i) (hτ : τ < 1) : CtxStable w τ :=
  ⟨geometricBudget r τ, fun _ hn => kstar_le_geometricBudget hw hr0 hr1 hdec hτ hn⟩

/-! ## Retained mass decays with context length -/

/-- For a fixed key budget the retained fraction is antitone in the context length: a
longer context always dilutes a fixed budget. -/
theorem retained_antitone_context {w : ℕ → ℝ} (hw : ∀ i, 0 < w i) (k : ℕ) {n₁ n₂ : ℕ}
    (hn₁ : 1 ≤ n₁) (h : n₁ ≤ n₂) : retained w n₂ k ≤ retained w n₁ k := by
  rcases le_or_gt n₁ k with hk | hk
  · have hone : retained w n₁ k = 1 := by
      rw [retained, min_eq_right hk, div_self (headMass_pos hw hn₁).ne']
    rw [hone]
    exact retained_le_one hw n₂ k (by omega)
  · have hmin₁ : min k n₁ = k := min_eq_left hk.le
    have hmin₂ : min k n₂ = k := min_eq_left (by omega)
    rw [retained, retained, hmin₁, hmin₂]
    exact div_le_div_of_nonneg_left (headMass_nonneg hw k) (headMass_pos hw hn₁)
      (headMass_mono hw h)

/-! ## H7: exact flatness is false -/

/-- **H7 — the flat chain is not literally flat.**  For the ideal geometric profile
`(1/2)^i` at gate `3/4`, the knee is `1` at context length `1` and `2` at context
length `2`.  So `k*` is not a constant function of the context even in the most
favourable case: a two-point measurement `{16, 16}` supports boundedness, never
equality. -/
theorem exact_flatness_refuted :
    kstar (fun i => (1 / 2 : ℝ) ^ i) 1 (3 / 4) = 1 ∧
      kstar (fun i => (1 / 2 : ℝ) ^ i) 2 (3 / 4) = 2 := by
  have hw : ∀ i : ℕ, (0 : ℝ) < (1 / 2 : ℝ) ^ i := fun i => by positivity
  constructor
  · have h0 : retained (fun i => (1 / 2 : ℝ) ^ i) 1 0 < 3 / 4 := by
      norm_num [retained, headMass]
    have h1 : (3 / 4 : ℝ) ≤ retained (fun i => (1 / 2 : ℝ) ^ i) 1 1 := by
      norm_num [retained, headMass]
    obtain ⟨hlt, hle⟩ := knee_bracket hw (n := 1) one_pos (by norm_num) h0 h1
    exact le_antisymm hle hlt
  · have h1 : retained (fun i => (1 / 2 : ℝ) ^ i) 2 1 < 3 / 4 := by
      norm_num [retained, headMass, Finset.sum_range_succ]
    have h2 : (3 / 4 : ℝ) ≤ retained (fun i => (1 / 2 : ℝ) ^ i) 2 2 := by
      norm_num [retained, headMass, Finset.sum_range_succ]
    obtain ⟨hlt, hle⟩ := knee_bracket hw (n := 2) (by norm_num) (by norm_num) h1 h2
    exact le_antisymm hle hlt

/-! ## H8: merging heads — the mediant law -/

section Merge

variable {w₁ w₂ : ℕ → ℝ} {τ : ℝ} {n : ℕ}

lemma headMass_add (k : ℕ) :
    headMass (fun i => w₁ i + w₂ i) k = headMass w₁ k + headMass w₂ k := by
  simp [headMass, Finset.sum_add_distrib]

/-- **The mediant inequality.**  The retained mass of a mixture of two heads is at least
the smaller of the two per-head retained masses (and, symmetrically, at most the
larger). -/
theorem retained_add_ge_min (hw₁ : ∀ i, 0 < w₁ i) (hw₂ : ∀ i, 0 < w₂ i) (hn : 0 < n)
    (k : ℕ) :
    min (retained w₁ n k) (retained w₂ n k) ≤ retained (fun i => w₁ i + w₂ i) n k := by
  have hB₁ : 0 < headMass w₁ n := headMass_pos hw₁ hn
  have hB₂ : 0 < headMass w₂ n := headMass_pos hw₂ hn
  set m := min (retained w₁ n k) (retained w₂ n k) with hm
  have h₁ : m * headMass w₁ n ≤ headMass w₁ (min k n) := by
    have : m ≤ headMass w₁ (min k n) / headMass w₁ n := min_le_left _ _
    rwa [le_div_iff₀ hB₁] at this
  have h₂ : m * headMass w₂ n ≤ headMass w₂ (min k n) := by
    have : m ≤ headMass w₂ (min k n) / headMass w₂ n := min_le_right _ _
    rwa [le_div_iff₀ hB₂] at this
  rw [retained, headMass_add, headMass_add, le_div_iff₀ (by linarith)]
  nlinarith

/-- The upper half of the mediant inequality: mixing two heads is never better than the
better head. -/
theorem retained_add_le_max (hw₁ : ∀ i, 0 < w₁ i) (hw₂ : ∀ i, 0 < w₂ i) (hn : 0 < n)
    (k : ℕ) :
    retained (fun i => w₁ i + w₂ i) n k ≤ max (retained w₁ n k) (retained w₂ n k) := by
  have hB₁ : 0 < headMass w₁ n := headMass_pos hw₁ hn
  have hB₂ : 0 < headMass w₂ n := headMass_pos hw₂ hn
  set M := max (retained w₁ n k) (retained w₂ n k) with hM
  have h₁ : headMass w₁ (min k n) ≤ M * headMass w₁ n := by
    have : headMass w₁ (min k n) / headMass w₁ n ≤ M := le_max_left _ _
    rwa [div_le_iff₀ hB₁] at this
  have h₂ : headMass w₂ (min k n) ≤ M * headMass w₂ n := by
    have : headMass w₂ (min k n) / headMass w₂ n ≤ M := le_max_right _ _
    rwa [div_le_iff₀ hB₂] at this
  rw [retained, headMass_add, headMass_add, div_le_iff₀ (by linarith)]
  nlinarith

/-- The knee of a mixture is at least the smaller of the two per-head knees. -/
theorem min_le_kstar_add (hw₁ : ∀ i, 0 < w₁ i) (hw₂ : ∀ i, 0 < w₂ i) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    min (kstar w₁ n τ) (kstar w₂ n τ) ≤ kstar (fun i => w₁ i + w₂ i) n τ := by
  set k := kstar (fun i => w₁ i + w₂ i) n τ with hk
  have hwsum : ∀ i, 0 < w₁ i + w₂ i := fun i => add_pos (hw₁ i) (hw₂ i)
  have hpass : τ ≤ retained (fun i => w₁ i + w₂ i) n k :=
    gate_le_retained_kstar hwsum hn hτ
  have hle := retained_add_le_max hw₁ hw₂ hn k
  rcases max_cases (retained w₁ n k) (retained w₂ n k) with ⟨he, _⟩ | ⟨he, _⟩
  · exact le_trans (min_le_left _ _) (kstar_le_of_pass (by rw [← he]; linarith))
  · exact le_trans (min_le_right _ _) (kstar_le_of_pass (by rw [← he]; linarith))

/-- **H8 — the max law for head mixtures.**  The knee of a two-head mixture is at most
the larger of the two per-head knees. -/
theorem kstar_add_le_max (hw₁ : ∀ i, 0 < w₁ i) (hw₂ : ∀ i, 0 < w₂ i) (hn : 0 < n)
    (hτ : τ ≤ 1) :
    kstar (fun i => w₁ i + w₂ i) n τ ≤ max (kstar w₁ n τ) (kstar w₂ n τ) := by
  set K := max (kstar w₁ n τ) (kstar w₂ n τ) with hK
  have p₁ : τ ≤ retained w₁ n K :=
    le_trans (gate_le_retained_kstar hw₁ hn hτ) (retained_mono hw₁ n (le_max_left _ _))
  have p₂ : τ ≤ retained w₂ n K :=
    le_trans (gate_le_retained_kstar hw₂ hn hτ) (retained_mono hw₂ n (le_max_right _ _))
  exact kstar_le_of_pass
    (le_trans (le_min p₁ p₂) (retained_add_ge_min hw₁ hw₂ hn K))

/-- Context stability is closed under mixing heads. -/
theorem ctxStable_add (hw₁ : ∀ i, 0 < w₁ i) (hw₂ : ∀ i, 0 < w₂ i) (hτ : τ ≤ 1)
    (h₁ : CtxStable w₁ τ) (h₂ : CtxStable w₂ τ) : CtxStable (fun i => w₁ i + w₂ i) τ := by
  obtain ⟨K₁, hK₁⟩ := h₁
  obtain ⟨K₂, hK₂⟩ := h₂
  refine ⟨max K₁ K₂, fun n hn => ?_⟩
  have := kstar_add_le_max hw₁ hw₂ (n := n) (τ := τ) (by omega) hτ
  have b₁ := hK₁ n hn
  have b₂ := hK₂ n hn
  omega

end Merge

/-- A gapless (flat) head is never context stable: no fixed key budget serves all
context lengths. -/
theorem not_ctxStable_uniform {τ : ℝ} (hτ0 : 0 < τ) (hτ : τ ≤ 1) :
    ¬ CtxStable (fun _ => (1 : ℝ)) τ := by
  rintro ⟨K, hK⟩
  obtain ⟨m, hm⟩ := exists_nat_gt ((K + 1 : ℝ) / τ)
  set n := max m 1 with hn
  have hn0 : 0 < n := by omega
  have hnR : (m : ℝ) ≤ (n : ℝ) := by exact_mod_cast le_max_left m 1
  have hbig : (K : ℝ) + 1 ≤ τ * n := by
    rw [div_lt_iff₀ hτ0] at hm
    nlinarith
  have hlow := kstar_uniform_ge (n := n) (τ := τ) hn0 hτ
  have hup : (kstar (fun _ => (1 : ℝ)) n τ : ℝ) ≤ (K : ℝ) := by
    exact_mod_cast hK n hn0
  linarith

end AttentionBudget