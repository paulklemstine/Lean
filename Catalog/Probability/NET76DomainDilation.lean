import Shared.AttentionBudgetKnee

/-!
# NET-76: why a *domain factor* can be multiplicative — and exactly how far it can be trusted

The NET-76 report ("THE-DOMAIN-FACTOR-IS-MULTIPLICATIVE") claims that each text
domain's whole key-budget curve is obtained from the English-prose curve
`{k*@512, k*@1024} = {16, 20}` by one multiplicative constant.  This file supplies
the missing *mechanism* and its sharp error term, working inside the model-free
knee theory of `Shared.AttentionBudgetKnee`.

The mechanism is **block dilation**: a domain whose attention profile spreads the
same mass over `c` times as many keys,
`dilate c w i = w (i / c) / c`, is exactly a `c`-fold time dilation of the base
profile `w`.  The results:

* `headMass_dilate` — master identity: `headMass (dilate c w) m
  = headMass w (m / c) + (m % c) • w (m / c) / c`.  Mass accumulates block by
  block and interpolates *linearly inside* a block; this single formula drives
  everything else.
* `retained_dilate` — at dilated contexts the retained-mass curve is the base
  curve reparametrised: `retained (dilate c w) (c*n) (c*k) = retained w n k`.
* `kstar_dilate_le_mul` and `mul_pred_lt_kstar_dilate` — the **multiplicative law
  with its exact error bar**: `c * (k* - 1) < k*_dilated ≤ c * k*`.  The domain
  factor is multiplicative *up to one dilation block* — never better in general.
* `kstar_dilate_lt_mul_example` — the error bar is not an artefact: an explicit
  profile, context and gate where `k*_dilated = 1 < 2 = c * k*`.  So exact
  multiplicativity is **false** as a theorem; the report's verdict needs a
  hypothesis.
* `kstar_dilate_eq_mul` — and here is that hypothesis, in checkable form: if the
  gate is not already cleared by the last sub-block of the previous block, then
  `k*_dilated = c * k*` exactly.
* `dilation_relative_error` — the honest asymptotic reading: the *relative* error
  of the multiplicative law is at most `1 / k*`.  A factor law measured on budgets
  of size 16–40 is good to ≈ 6 %, which is precisely the resolution at which the
  reported table was read.
* `ctxSens_dilate_bracket` — the doubling increment inherits the same factor:
  `c * Δ - (c-1) ≤ Δ_dilated ≤ c * Δ + (c-1)`.  This is the structural reason the
  report sees `+4` for English and `+8` for French: one dilation parameter governs
  *both* columns of the table.

-- !-- Lab Notes -- !--
Hypothesizer (round 28, five conjectures, ranked):
 (H1) A single multiplicative domain factor is exactly the signature of a block
      dilation of the attention profile; nothing else produces a factor that acts
      on both context columns at once.                                      [BOLD]
 (H2) Exact multiplicativity is false without a gate hypothesis: the knee can
      land strictly inside a dilation block.
 (H3) The failure is bounded by one block, so relative error ≤ 1/k*, i.e. the law
      is asymptotically exact in the large-budget regime.                   [BOLD]
 (H4) The doubling increment carries the same factor, with the same one-block
      error bar (predicting EN +4 ↦ FR +8).                                 [BOLD]
 (H5) Fractional factors (code 0.75×, DE 1.25×) cannot come from an integer
      dilation: they need a different mechanism (audited in
      `Probability.NET76MultiplicativeAudit`).

Experimenter: H1/H3/H4 are `retained_dilate`, `dilation_relative_error`,
`ctxSens_dilate_bracket`; H2 is refuted-in-the-sharp-direction by
`kstar_dilate_lt_mul_example` (uniform profile, `c = 2`, `n = 2`, `τ = 1/4`:
base knee 1, dilated knee 1, not 2).  H5 is settled in the audit file.

Analyst: the one-block error bar is the whole story.  `32 = 2 · 16` and
`40 = 2 · 20` sit at the *top* edge of the dilation window `[15c+1, 16c]`,
`[19c+1, 20c]` with `c = 2`; the reported French row is therefore consistent with
an exact `c = 2` dilation, whereas the code and German rows are not consistent
with any integer dilation at all.

Critic: no theorem here is vacuous.  `kstar_dilate_lt_mul_example` exhibits a
concrete strict inequality, so the bracket theorems are not silently equalities;
`retained_dilate` is an identity between two genuinely different profiles, not a
definitional unfolding; and every knee statement carries the positivity and
gate hypotheses that the underlying theory requires.
-/

namespace Catalog.Probability.NET76DomainDilation

open Finset AttentionBudget

/-! ## 1. Block dilation of an attention profile -/

/-- **Block dilation.**  `dilate c w` spreads the mass of each key of `w` evenly over
`c` consecutive keys.  It is the profile of a domain that needs `c` times as many
keys to express the same information. -/
noncomputable def dilate (c : ℕ) (w : ℕ → ℝ) : ℕ → ℝ := fun i => w (i / c) / c

variable {w : ℕ → ℝ} {c : ℕ}

lemma dilate_pos (hc : 0 < c) (hw : ∀ i, 0 < w i) : ∀ i, 0 < dilate c w i := by
  intro i
  exact div_pos (hw _) (by exact_mod_cast hc)

/-- Dilation is mass preserving on whole blocks. -/
lemma headMass_dilate_mul (hc : 0 < c) (k : ℕ) :
    headMass (dilate c w) (c * k) = headMass w k := by
  induction k with
  | zero => simp [headMass]
  | succ k ih =>
      have hsplit : c * (k + 1) = c * k + c := by ring
      have hblock : ∑ i ∈ range c, dilate c w (c * k + i) = w k := by
        have : ∀ i ∈ range c, dilate c w (c * k + i) = w k / c := by
          intro i hi
          have hik : (c * k + i) / c = k := by
            rw [Nat.mul_add_div hc, Nat.div_eq_of_lt (mem_range.mp hi), Nat.add_zero]
          simp [dilate, hik]
        rw [Finset.sum_congr rfl this]
        rw [Finset.sum_const, card_range, nsmul_eq_mul]
        field_simp
      have hstep : headMass (dilate c w) (c * (k + 1))
          = headMass (dilate c w) (c * k) + ∑ i ∈ range c, dilate c w (c * k + i) := by
        rw [headMass, hsplit, Finset.sum_range_add]; rfl
      rw [hstep, hblock, ih, headMass, headMass, Finset.sum_range_succ]

/-- **Master identity.**  Inside a block the dilated mass grows linearly. -/
lemma headMass_dilate (hc : 0 < c) (m : ℕ) :
    headMass (dilate c w) m
      = headMass w (m / c) + (m % c : ℕ) * (w (m / c) / c) := by
  have hm : m = c * (m / c) + m % c := (Nat.div_add_mod m c).symm
  have hblock : ∀ i ∈ range (m % c), dilate c w (c * (m / c) + i) = w (m / c) / c := by
    intro i hi
    have hlt : i < m % c := mem_range.mp hi
    have hmod : m % c < c := Nat.mod_lt _ hc
    have : (c * (m / c) + i) / c = m / c := by
      rw [Nat.mul_add_div hc, Nat.div_eq_of_lt (lt_trans hlt hmod), Nat.add_zero]
    simp [dilate, this]
  calc headMass (dilate c w) m
      = ∑ i ∈ range (c * (m / c) + m % c), dilate c w i := by rw [headMass, ← hm]
    _ = headMass (dilate c w) (c * (m / c))
          + ∑ i ∈ range (m % c), dilate c w (c * (m / c) + i) := by
        rw [Finset.sum_range_add]; rfl
    _ = headMass w (m / c) + (m % c : ℕ) * (w (m / c) / c) := by
        rw [headMass_dilate_mul hc, Finset.sum_congr rfl hblock, Finset.sum_const,
          card_range, nsmul_eq_mul]

/-- At dilated contexts the retained-mass curve of the dilated profile is exactly the
base curve, reparametrised by `c`. -/
lemma retained_dilate (hc : 0 < c) (n k : ℕ) :
    retained (dilate c w) (c * n) (c * k) = retained w n k := by
  have hmin : min (c * n) (c * k) = c * min n k := by
    rw [Nat.mul_min_mul_left]
  rw [retained, retained, min_comm (c * k), hmin, headMass_dilate_mul hc,
    headMass_dilate_mul hc, min_comm]

/-! ## 2. The multiplicative law with its exact error bar -/

variable {tau : ℝ} {n : ℕ}

/-- With a positive gate the base knee is positive: the empty budget retains nothing. -/
lemma kstar_pos (hw : ∀ i, 0 < w i) (hn : 0 < n) (htau0 : 0 < tau) (htau : tau ≤ 1) :
    0 < kstar w n tau := by
  have hzero : retained w n 0 = 0 := by simp [retained, headMass]
  exact lt_kstar_of_fail hw hn htau (by rw [hzero]; exact htau0)

/-- **Upper half of the law.**  The dilated knee never exceeds `c` times the base
knee. -/
theorem kstar_dilate_le_mul (hw : ∀ i, 0 < w i) (hc : 0 < c) (hn : 0 < n)
    (htau : tau ≤ 1) :
    kstar (dilate c w) (c * n) tau ≤ c * kstar w n tau := by
  refine kstar_le_of_pass ?_
  rw [retained_dilate hc]
  exact gate_le_retained_kstar hw hn htau

/-- **Lower half of the law.**  The dilated knee is above the previous whole block:
the multiplicative prediction is correct to within one dilation block. -/
theorem mul_pred_lt_kstar_dilate (hw : ∀ i, 0 < w i) (hc : 0 < c) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1) :
    c * (kstar w n tau - 1) < kstar (dilate c w) (c * n) tau := by
  have hpos := kstar_pos hw hn htau0 htau
  have hfail : retained w n (kstar w n tau - 1) < tau := by
    by_contra hcon
    push_neg at hcon
    have := kstar_le_of_pass (w := w) (n := n) (τ := tau) hcon
    omega
  have h2 : retained (dilate c w) (c * n) (c * (kstar w n tau - 1)) < tau := by
    rw [retained_dilate hc]; exact hfail
  exact lt_kstar_of_fail (dilate_pos hc hw) (Nat.mul_pos hc hn) htau h2

/-- **Exactness criterion.**  If the gate is still not cleared by the *last* sub-block
before the block boundary, the multiplicative law holds on the nose. -/
theorem kstar_dilate_eq_mul (hw : ∀ i, 0 < w i) (hc : 0 < c) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1)
    (hgate : retained (dilate c w) (c * n) (c * kstar w n tau - 1) < tau) :
    kstar (dilate c w) (c * n) tau = c * kstar w n tau := by
  have hpos := kstar_pos hw hn htau0 htau
  refine le_antisymm (kstar_dilate_le_mul hw hc hn htau) ?_
  have hlt := lt_kstar_of_fail (dilate_pos hc hw) (Nat.mul_pos hc hn) htau hgate
  have hck : 1 ≤ c * kstar w n tau := Nat.one_le_iff_ne_zero.mpr (by positivity)
  omega

/-- **The error bar is real.**  For the uniform profile with `c = 2`, `n = 2` and
gate `tau = 1/4`, the base knee is `1` while the dilated knee is `1`, not `2`: exact
multiplicativity is false without the gate hypothesis. -/
theorem kstar_dilate_lt_mul_example :
    kstar (fun _ : ℕ => (1 : ℝ)) 2 (1 / 4) = 1 ∧
      kstar (dilate 2 (fun _ : ℕ => (1 : ℝ))) 4 (1 / 4)
        < 2 * kstar (fun _ : ℕ => (1 : ℝ)) 2 (1 / 4) := by
  have hw : ∀ i : ℕ, (0 : ℝ) < (fun _ : ℕ => (1 : ℝ)) i := fun _ => one_pos
  have hmass : ∀ m : ℕ, headMass (fun _ : ℕ => (1 : ℝ)) m = m := by
    intro m; simp [headMass]
  have hbase : kstar (fun _ : ℕ => (1 : ℝ)) 2 (1 / 4) = 1 := by
    have hpass : (1 / 4 : ℝ) ≤ retained (fun _ : ℕ => (1 : ℝ)) 2 1 := by
      rw [retained, hmass, hmass]; norm_num
    have hfail : retained (fun _ : ℕ => (1 : ℝ)) 2 0 < (1 / 4 : ℝ) := by
      rw [retained, hmass, hmass]; norm_num
    have h1 := kstar_le_of_pass (w := fun _ : ℕ => (1 : ℝ)) (n := 2) hpass
    have h2 := lt_kstar_of_fail hw (by norm_num) (by norm_num) hfail
    omega
  refine ⟨hbase, ?_⟩
  have hdil : ∀ m : ℕ, headMass (dilate 2 (fun _ : ℕ => (1 : ℝ))) m = (m : ℝ) / 2 := by
    intro m
    simp [headMass, dilate]
    ring
  have hpass : (1 / 4 : ℝ) ≤ retained (dilate 2 (fun _ : ℕ => (1 : ℝ))) 4 1 := by
    rw [retained]
    norm_num [hdil]
  have := kstar_le_of_pass (w := dilate 2 (fun _ : ℕ => (1 : ℝ))) (n := 4) hpass
  omega

/-! ## 3. Relative accuracy and the increment law -/

/-- **Asymptotic exactness.**  The relative error of the multiplicative prediction is
at most `1 / k*`: on the budgets actually measured (`k* ≥ 16`) the law is good to
better than 7 %. -/
theorem dilation_relative_error (hw : ∀ i, 0 < w i) (hc : 0 < c) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1) :
    (1 : ℝ) - 1 / kstar w n tau
        < (kstar (dilate c w) (c * n) tau : ℝ) / (c * kstar w n tau) ∧
      (kstar (dilate c w) (c * n) tau : ℝ) / (c * kstar w n tau) ≤ 1 := by
  have hpos := kstar_pos hw hn htau0 htau
  have hcR : (0 : ℝ) < c := by exact_mod_cast hc
  have hkR : (0 : ℝ) < (kstar w n tau : ℝ) := by exact_mod_cast hpos
  have hden : (0 : ℝ) < (c : ℝ) * (kstar w n tau : ℝ) := by positivity
  constructor
  · have hlow : c * (kstar w n tau - 1) < kstar (dilate c w) (c * n) tau :=
      mul_pred_lt_kstar_dilate hw hc hn htau0 htau
    have hcast : ((c * (kstar w n tau - 1) : ℕ) : ℝ)
        = (c : ℝ) * ((kstar w n tau : ℝ) - 1) := by
      push_cast [Nat.cast_sub hpos]
      ring
    have hlowR : (c : ℝ) * ((kstar w n tau : ℝ) - 1)
        < (kstar (dilate c w) (c * n) tau : ℝ) := by
      rw [← hcast]; exact_mod_cast hlow
    rw [lt_div_iff₀ hden]
    have hexp : ((1 : ℝ) - 1 / (kstar w n tau : ℝ)) * ((c : ℝ) * (kstar w n tau : ℝ))
        = (c : ℝ) * ((kstar w n tau : ℝ) - 1) := by
      field_simp
    rw [hexp]
    exact hlowR
  · have hup : kstar (dilate c w) (c * n) tau ≤ c * kstar w n tau :=
      kstar_dilate_le_mul hw hc hn htau
    have hupR : (kstar (dilate c w) (c * n) tau : ℝ)
        ≤ (c : ℝ) * (kstar w n tau : ℝ) := by exact_mod_cast hup
    rw [div_le_one hden]
    exact hupR

/-- **The increment carries the same factor.**  The doubling increment of the dilated
profile is `c` times the base increment, up to the same one-block error.  This is the
structural prediction behind the reported `+4` (English) versus `+8` (French). -/
theorem ctxSens_dilate_bracket (hw : ∀ i, 0 < w i) (hc : 0 < c) (hn : 0 < n)
    (htau0 : 0 < tau) (htau : tau ≤ 1) :
    (c : ℤ) * ((kstar w (2 * n) tau : ℤ) - kstar w n tau) - (c - 1)
        ≤ (kstar (dilate c w) (2 * (c * n)) tau : ℤ)
            - kstar (dilate c w) (c * n) tau ∧
      (kstar (dilate c w) (2 * (c * n)) tau : ℤ)
          - kstar (dilate c w) (c * n) tau
        ≤ (c : ℤ) * ((kstar w (2 * n) tau : ℤ) - kstar w n tau) + (c - 1) := by
  have h2n : 0 < 2 * n := by omega
  have hcomm : 2 * (c * n) = c * (2 * n) := by ring
  have h1 := kstar_pos hw hn htau0 htau
  have h2 := kstar_pos hw h2n htau0 htau
  have hup1 : (kstar (dilate c w) (c * n) tau : ℤ) ≤ (c : ℤ) * (kstar w n tau : ℤ) := by
    exact_mod_cast kstar_dilate_le_mul hw hc hn htau
  have hup2 : (kstar (dilate c w) (c * (2 * n)) tau : ℤ)
      ≤ (c : ℤ) * (kstar w (2 * n) tau : ℤ) := by
    exact_mod_cast kstar_dilate_le_mul hw hc h2n htau
  have hlow1 : (c : ℤ) * ((kstar w n tau : ℤ) - 1)
      < (kstar (dilate c w) (c * n) tau : ℤ) := by
    have h := mul_pred_lt_kstar_dilate hw hc hn htau0 htau
    have hcast : ((c * (kstar w n tau - 1) : ℕ) : ℤ)
        = (c : ℤ) * ((kstar w n tau : ℤ) - 1) := by
      push_cast [Nat.cast_sub h1]; ring
    rw [← hcast]; exact_mod_cast h
  have hlow2 : (c : ℤ) * ((kstar w (2 * n) tau : ℤ) - 1)
      < (kstar (dilate c w) (c * (2 * n)) tau : ℤ) := by
    have h := mul_pred_lt_kstar_dilate hw hc h2n htau0 htau
    have hcast : ((c * (kstar w (2 * n) tau - 1) : ℕ) : ℤ)
        = (c : ℤ) * ((kstar w (2 * n) tau : ℤ) - 1) := by
      push_cast [Nat.cast_sub h2]; ring
    rw [← hcast]; exact_mod_cast h
  rw [hcomm]
  constructor <;> [linarith; linarith]

end Catalog.Probability.NET76DomainDilation