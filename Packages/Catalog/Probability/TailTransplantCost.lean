import Probability.TailTransplantGeometry
import Novelty.KVDecisionDissociation

/-!
# What the NET-54 transplant costs, and where the cost lives

`Probability.TailTransplantGeometry` proved the *combinatorial* half of the
NET-54 verdict **THE-TAIL-IS-LOAD-BEARING-BUT-UNPORTABLE**.  This file proves the
*quantitative* half, and confronts the measurement with the prediction that the
previous round (NET-51, `Novelty.TailSwapAttribution.tail_swap_transfers_decision`)
had derived from the shared-core picture.

Three independent statements.

**A. The margin prediction is falsified on a quantified fraction of positions.**
NET-51 proved: if the two prefixes agree to `ε` and the donor tail holds its
top-1 decision with margin `> 2ε`, then the hybrid `tail_B ∘ core_A` makes the
donor's decision.  Contrapositively, every position where the hybrid and the
donor disagree is a position carrying *no* margin certificate.  With the
measured hybrid/donor agreement `0.5443`, at least `45.57 %` of the held-out
positions are margin-uncertified (`net54_margin_failure_fraction`).  The
prediction was not wrong as a theorem; the tail simply does not have the margins
its hypothesis requires — the tail sits in the low-margin regime that NET-51's
own `diffuse_decision_is_fragile` identified.

**B. Zero cross-entropy cost does not certify agreement.**  The bulk (L10/11)
arm was read off as "free" because `ΔCE ≈ 0`.  `zero_cost_full_disagreement`
shows that this reading is not licensed by the cost alone: for every `t ∈
(0,1/2)` there are two predictive distributions with *exactly equal*
cross-entropy against the truth whose top-1 decisions differ everywhere.  The
`0.9635` agreement measured in the bulk arm is therefore genuinely independent
evidence, not a corollary of the zero cost.  The correct converse direction is
`ce_diff_le_of_log_ratio_bounded`: a bounded log-ratio (not a bounded cost)
bounds the cost gap.

**C. A macroscopic cost is a locally concentrated cost.**  `cost_localization`
is a reverse-Markov bound: an average excess `Δ` with a per-window cap `C`
forces at least a `Δ/(2C)` fraction of windows to carry an excess of at least
`Δ/2`.  Applied to the measured `+0.4652` nats of the tail arm
(`net54_tail_cost_localized`) this says the damage cannot be spread thinly: with
a 2-nat cap, at least `11.63 %` of the windows individually lose more than
`0.23` nats.  This is the falsifiable per-window prediction of the verdict.
-/

namespace Catalog.Probability.TailTransplantCost

open Finset
open Catalog.Probability.TailTransplantGeometry
open Catalog.Novelty.KVDecisionDissociation

/-! ### A. Margin certificates and the falsified transfer prediction -/

variable {Ω : Type*} [Fintype Ω] [DecidableEq Ω] {m : ℕ}

/-- The NET-51 transfer hypothesis, localised at one position: the donor tail
evaluated on its own prefix (`u x`) holds its decision `d x` with margin
`> 2 ε`, and running the same tail on the host prefix moves every coordinate by
at most `ε` (`v x`).  This is exactly the hypothesis of
`Novelty.TailSwapAttribution.tail_swap_transfers_decision`. -/
def MarginCertified (u v : Ω → Fin m → ℝ) (d : Ω → Fin m) (eps : ℝ) (x : Ω) : Prop :=
  (∀ j, j ≠ d x → 2 * eps < u x (d x) - u x j) ∧ (∀ j, |u x j - v x j| ≤ eps)

/-- A strict top-1 choice is unique. -/
lemma strictTop_unique {u : Fin m → ℝ} {i j : Fin m}
    (hi : IsStrictTop u i) (hj : IsStrictTop u j) : i = j := by
  by_contra hne
  have h1 : u i < u j := hj i hne
  have h2 : u j < u i := hi j (Ne.symm hne)
  linarith

omit [Fintype Ω] [DecidableEq Ω] in
/-- At a certified position the hybrid inherits the donor's decision — the
NET-51 prediction, position by position. -/
theorem decision_transfers_of_certified {u v : Ω → Fin m → ℝ} {d dH : Ω → Fin m}
    {eps : ℝ} {x : Ω} (hcert : MarginCertified u v d eps x)
    (hH : IsStrictTop (v x) (dH x)) : dH x = d x :=
  strictTop_unique hH (strictTop_of_margin (u x) (v x) (d x) eps hcert.1 hcert.2)

open Classical in
/-- The positions carrying no margin certificate. -/
noncomputable def uncertifiedSet (u v : Ω → Fin m → ℝ) (d : Ω → Fin m) (eps : ℝ) : Finset Ω :=
  Finset.univ.filter (fun x => ¬ MarginCertified u v d eps x)

/-- Fraction of margin-uncertified positions. -/
noncomputable def uncertifiedFrac (u v : Ω → Fin m → ℝ) (d : Ω → Fin m) (eps : ℝ) : ℝ :=
  ((uncertifiedSet u v d eps).card : ℝ) / (Fintype.card Ω : ℝ)

open Classical in
omit [DecidableEq Ω] in
/-- **Every hybrid/donor disagreement is a missing margin.**  This is the exact
contrapositive of the NET-51 transfer theorem, lifted from one position to the
whole held-out set. -/
theorem disagreeSet_subset_uncertifiedSet (u v : Ω → Fin m → ℝ) (d dH : Ω → Fin m)
    (eps : ℝ) (hH : ∀ x, IsStrictTop (v x) (dH x)) :
    disagreeSet dH d ⊆ uncertifiedSet u v d eps := by
  intro x hx
  rw [mem_disagreeSet] at hx
  simp only [uncertifiedSet, Finset.mem_filter, Finset.mem_univ, true_and]
  intro hcert
  exact hx (decision_transfers_of_certified hcert (hH x))

open Classical in
omit [DecidableEq Ω] in
/-- Fractional form: the margin-uncertified fraction is at least the
hybrid/donor disagreement fraction. -/
theorem uncertifiedFrac_ge [Nonempty Ω] (u v : Ω → Fin m → ℝ) (d dH : Ω → Fin m)
    (eps : ℝ) (hH : ∀ x, IsStrictTop (v x) (dH x)) :
    1 - agreeFrac dH d ≤ uncertifiedFrac u v d eps := by
  have hN : 0 < Fintype.card Ω := Fintype.card_pos
  have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  have hsub := Finset.card_le_card (disagreeSet_subset_uncertifiedSet u v d dH eps hH)
  have hpart := card_agree_add_card_disagree dH d
  have hcard : (Fintype.card Ω : ℝ) - ((agreeSet dH d).card : ℝ)
      ≤ ((uncertifiedSet u v d eps).card : ℝ) := by
    have hnat : Fintype.card Ω - (agreeSet dH d).card ≤ (uncertifiedSet u v d eps).card := by
      omega
    have hle : (agreeSet dH d).card ≤ Fintype.card Ω := by omega
    have := (Nat.cast_le (α := ℝ)).2 hnat
    rw [Nat.cast_sub hle] at this
    linarith
  rw [uncertifiedFrac, agreeFrac, le_div_iff₀ hNR, sub_mul, div_mul_cancel₀ _ hNR.ne']
  linarith

open Classical in
omit [DecidableEq Ω] in
/-- **NET-54 against NET-51.**  The measured hybrid/donor prediction agreement of
the tail swap is `0.5443`; hence at least `45.57 %` of the held-out positions
carry no margin certificate at the observed prefix drift.  The transfer theorem
is sound but its hypothesis is massively violated in the last two layers: the
tail's decisions are *not* margin-protected, which is precisely why they do not
travel. -/
theorem net54_margin_failure_fraction [Nonempty Ω] (u v : Ω → Fin m → ℝ) (d dH : Ω → Fin m)
    (eps : ℝ) (hH : ∀ x, IsStrictTop (v x) (dH x))
    (hagree : agreeFrac dH d ≤ 0.5443) :
    (0.4557 : ℝ) ≤ uncertifiedFrac u v d eps := by
  have h := uncertifiedFrac_ge u v d dH eps hH
  linarith

/-! ### B. Cross-entropy: cost and agreement are dissociated -/

/-- Cross-entropy of the predictive distribution `q` against the truth `p`. -/
noncomputable def crossEntropy {n : ℕ} (p q : Fin n → ℝ) : ℝ :=
  -∑ i, p i * Real.log (q i)

/-- **Zero cost, total disagreement.**  For every perturbation size
`t ∈ (0, 1/2)` there are two strictly positive predictive distributions on two
tokens with *identical* cross-entropy against the uniform truth whose top-1
decisions are opposite.  A vanishing `ΔCE` — the signature of the bulk L10/11
arm — therefore carries **no** information about prediction agreement: the
`0.9635` agreement measured there is independent evidence. -/
theorem zero_cost_full_disagreement (t : ℝ) (ht : 0 < t) (ht2 : t < 1 / 2) :
    ∃ q₁ q₂ : Fin 2 → ℝ,
      (∀ i, 0 < q₁ i) ∧ (∀ i, 0 < q₂ i) ∧
      (∑ i, q₁ i = 1) ∧ (∑ i, q₂ i = 1) ∧
      crossEntropy ![1 / 2, 1 / 2] q₁ = crossEntropy ![1 / 2, 1 / 2] q₂ ∧
      IsStrictTop q₁ 0 ∧ IsStrictTop q₂ 1 := by
  refine ⟨![1 / 2 + t, 1 / 2 - t], ![1 / 2 - t, 1 / 2 + t], ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · intro i
    fin_cases i <;> simp <;> linarith
  · intro i
    fin_cases i <;> simp <;> linarith
  · simp [Fin.sum_univ_two]; ring
  · simp [Fin.sum_univ_two]; ring
  · simp [crossEntropy, Fin.sum_univ_two]; ring
  · intro j hj
    fin_cases j
    · exact absurd rfl hj
    · simp
      linarith
  · intro j hj
    fin_cases j
    · simp
      linarith
    · exact absurd rfl hj

/-- The correct converse: it is a bounded **log-ratio**, not a bounded cost,
that controls the cross-entropy gap.  If two predictive distributions differ by
at most `κ` in log-space at every token, their cross-entropies against any
probability vector differ by at most `κ`. -/
theorem ce_diff_le_of_log_ratio_bounded {n : ℕ} (p q₁ q₂ : Fin n → ℝ) (kappa : ℝ)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i, p i = 1)
    (hlog : ∀ i, |Real.log (q₁ i) - Real.log (q₂ i)| ≤ kappa) :
    |crossEntropy p q₁ - crossEntropy p q₂| ≤ kappa := by
  have hrewrite : crossEntropy p q₁ - crossEntropy p q₂
      = ∑ i, p i * (Real.log (q₂ i) - Real.log (q₁ i)) := by
    simp only [crossEntropy, ← Finset.sum_neg_distrib, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl ?_
    intro i _
    ring
  rw [hrewrite]
  calc |∑ i, p i * (Real.log (q₂ i) - Real.log (q₁ i))|
      ≤ ∑ i, |p i * (Real.log (q₂ i) - Real.log (q₁ i))| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, p i * kappa := by
        refine Finset.sum_le_sum ?_
        intro i _
        rw [abs_mul, abs_of_nonneg (hp i)]
        have habs : |Real.log (q₂ i) - Real.log (q₁ i)| ≤ kappa := by
          rw [abs_sub_comm]; exact hlog i
        exact mul_le_mul_of_nonneg_left habs (hp i)
    _ = kappa := by rw [← Finset.sum_mul, hsum, one_mul]

/-! ### C. A macroscopic cost must be locally concentrated -/

omit [DecidableEq Ω] in
/-- **Reverse Markov / cost localisation.**  If a nonnegative per-window excess
is capped by `C` and its mean is at least `Δ`, then at least a `Δ/(2C)` fraction
of windows individually carry an excess of at least `Δ/2`.  A measured average
degradation cannot be an evenly spread infinitesimal. -/
theorem cost_localization [Nonempty Ω] (f : Ω → ℝ) (C Delta : ℝ)
    (hC : 0 < C) (hfC : ∀ x, f x ≤ C)
    (hmean : Delta * (Fintype.card Ω : ℝ) ≤ ∑ x, f x) :
    Delta / (2 * C)
      ≤ (((Finset.univ.filter (fun x => Delta / 2 ≤ f x)).card : ℝ)) /
          (Fintype.card Ω : ℝ) := by
  classical
  rcases le_or_gt Delta 0 with hD | hD
  · have h2C : (0 : ℝ) < 2 * C := by linarith
    have hneg : Delta / (2 * C) ≤ 0 / (2 * C) := by gcongr
    have hRHS : (0 : ℝ)
        ≤ (((Finset.univ.filter (fun x => Delta / 2 ≤ f x)).card : ℝ)) /
            (Fintype.card Ω : ℝ) := by positivity
    simp only [zero_div] at hneg
    linarith
  set S := Finset.univ.filter (fun x => Delta / 2 ≤ f x) with hS
  have hN : 0 < Fintype.card Ω := Fintype.card_pos
  have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast hN
  have hsplit : ∑ x ∈ S, f x + ∑ x ∈ Finset.univ.filter (fun x => ¬ (Delta / 2 ≤ f x)), f x
      = ∑ x, f x := Finset.sum_filter_add_sum_filter_not _ _ _
  have hbig : ∑ x ∈ S, f x ≤ (S.card : ℝ) * C := by
    calc ∑ x ∈ S, f x ≤ ∑ _x ∈ S, C := Finset.sum_le_sum (fun x _ => hfC x)
      _ = (S.card : ℝ) * C := by rw [Finset.sum_const, nsmul_eq_mul]
  have hsmall : ∑ x ∈ Finset.univ.filter (fun x => ¬ (Delta / 2 ≤ f x)), f x
      ≤ ((Fintype.card Ω : ℝ)) * (Delta / 2) := by
    have hstep : ∑ x ∈ Finset.univ.filter (fun x => ¬ (Delta / 2 ≤ f x)), f x
        ≤ ∑ _x ∈ Finset.univ.filter (fun x => ¬ (Delta / 2 ≤ f x)), (Delta / 2) := by
      refine Finset.sum_le_sum ?_
      intro x hx
      simp only [Finset.mem_filter, not_le] at hx
      exact le_of_lt hx.2
    have hcardle : ((Finset.univ.filter (fun x => ¬ (Delta / 2 ≤ f x))).card : ℝ)
        ≤ (Fintype.card Ω : ℝ) := by
      have : (Finset.univ.filter (fun x => ¬ (Delta / 2 ≤ f x))).card ≤ Fintype.card Ω := by
        simpa [Finset.card_univ] using
          Finset.card_le_card (Finset.filter_subset (fun x => ¬ (Delta / 2 ≤ f x)) Finset.univ)
      exact_mod_cast this
    have hnonneg : (0 : ℝ) ≤ Delta / 2 := by linarith
    calc ∑ x ∈ Finset.univ.filter (fun x => ¬ (Delta / 2 ≤ f x)), f x
        ≤ ((Finset.univ.filter (fun x => ¬ (Delta / 2 ≤ f x))).card : ℝ) * (Delta / 2) := by
          rw [Finset.sum_const, nsmul_eq_mul] at hstep; exact hstep
      _ ≤ ((Fintype.card Ω : ℝ)) * (Delta / 2) :=
          mul_le_mul_of_nonneg_right hcardle hnonneg
  have hkey : (Fintype.card Ω : ℝ) * (Delta / 2) ≤ (S.card : ℝ) * C := by
    linarith
  rw [div_le_div_iff₀ (by linarith : (0:ℝ) < 2 * C) hNR]
  linarith

omit [DecidableEq Ω] in
/-- **NET-54, per-window prediction.**  The tail arm loses `0.4652` nats on
average.  If no single held-out window can lose more than `2` nats, then at
least `11.63 %` of the windows individually lose at least `0.2326` nats: the
tail-swap damage is *localised*, not a uniform haze.  This is the concrete
falsifiable consequence of the verdict — a per-window histogram of the arm must
show such a tail. -/
theorem net54_tail_cost_localized [Nonempty Ω] (f : Ω → ℝ) (hfC : ∀ x, f x ≤ 2)
    (hmean : (0.4652 : ℝ) * (Fintype.card Ω : ℝ) ≤ ∑ x, f x) :
    (0.1163 : ℝ)
      ≤ (((Finset.univ.filter (fun x => (0.4652 : ℝ) / 2 ≤ f x)).card : ℝ)) /
          (Fintype.card Ω : ℝ) := by
  have h := cost_localization f 2 0.4652 (by norm_num) hfC hmean
  have hval : (0.4652 : ℝ) / (2 * 2) = 0.1163 := by norm_num
  rw [hval] at h
  exact h

end Catalog.Probability.TailTransplantCost