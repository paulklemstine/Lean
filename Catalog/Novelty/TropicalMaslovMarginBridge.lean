import Novelty.KVDecisionDissociation

/-!
# The Maslov gap ↔ margin bridge (NET-50 ⋈ NET-51)

NET-50 measured, for the same transformer stack, a *tropical* quantity: the
**Maslov gap** `logsumexp(x) - max(x)` of the pre-softmax attention scores.  Its
median is close to `0` for most layers ("near-tropical": softmax behaves like a
max) and jumps to `2.5–2.7` exactly in the tail layers L22/L23.  NET-51 measured a
*functional* quantity on the same layers: top-1 decision agreement between two
fine-tunes, which collapses in exactly those layers.

This file proves that these are two views of one inequality.  Writing
`lse x = log ∑ exp (x i)` and `maslovGap x i = lse x - x i`:

* `maslovGap_nonneg`, `maslovGap_le_log_card` — the gap lives in `[0, log n]`,
  the tropical/Maslov dequantization window.
* `maslovGap_le_of_margin` — a margin `m` at the top forces a *small* gap:
  `gap ≤ log (1 + (n-1) e^{-m})`.  Near-tropical behaviour is exactly the regime
  of large margins.
* `margin_le_of_maslovGap` and `margin_le_of_maslovGap_simple` — the converse:
  a measured gap `g ≥ 1` caps the margin by `log (n-1) + log 2 - g`.  **Every nat
  of Maslov gap costs a nat of margin.**
* `exists_small_margin_of_maslovGap` + `flip_of_small_margin` — and a small margin
  is precisely a flippable decision: the far-from-tropical tail admits a
  perturbation of half the margin that changes the model's choice.
* `far_from_tropical_is_fragile` — the composite statement: a large Maslov gap
  yields an explicit small perturbation that destroys the top-1 decision.  This
  is the formal content of the NET-50/NET-51 convergence.
-/

namespace Catalog.Novelty.TropicalMaslovMarginBridge

open Finset Catalog.Novelty.KVDecisionDissociation

variable {n : ℕ}

/-- Log-sum-exp (the "soft" tropical sum). -/
noncomputable def lse (x : Fin n → ℝ) : ℝ := Real.log (∑ i, Real.exp (x i))

/-- The Maslov gap of a score vector at its top index: how far the softmax
aggregate sits above the tropical (max-plus) aggregate. -/
noncomputable def maslovGap (x : Fin n → ℝ) (i : Fin n) : ℝ := lse x - x i

theorem sum_exp_pos (x : Fin n → ℝ) (i : Fin n) : 0 < ∑ j, Real.exp (x j) :=
  Finset.sum_pos (fun j _ => Real.exp_pos (x j)) ⟨i, mem_univ i⟩

/-- The tropical lower bound: `lse` dominates every coordinate. -/
theorem le_lse (x : Fin n → ℝ) (i : Fin n) : x i ≤ lse x := by
  have h1 : Real.exp (x i) ≤ ∑ j, Real.exp (x j) :=
    Finset.single_le_sum (f := fun j => Real.exp (x j))
      (fun j _ => (Real.exp_pos (x j)).le) (mem_univ i)
  have := Real.log_le_log (Real.exp_pos (x i)) h1
  simpa [lse, Real.log_exp] using this

/-- The Maslov gap is nonnegative. -/
theorem maslovGap_nonneg (x : Fin n → ℝ) (i : Fin n) : 0 ≤ maslovGap x i := by
  simp only [maslovGap]
  linarith [le_lse x i]

/-- The Maslov gap of a *maximal* coordinate never exceeds `log n`: the softmax
aggregate is squeezed between the tropical aggregate and `log n` above it. -/
theorem maslovGap_le_log_card (x : Fin n → ℝ) (i : Fin n) (hmax : ∀ j, x j ≤ x i) :
    maslovGap x i ≤ Real.log n := by
  have hcard : ∑ _j : Fin n, Real.exp (x i) = (n : ℝ) * Real.exp (x i) := by
    simp [Finset.sum_const, nsmul_eq_mul]
  have hsum : ∑ j, Real.exp (x j) ≤ (n : ℝ) * Real.exp (x i) := by
    rw [← hcard]
    exact Finset.sum_le_sum fun j _ => Real.exp_le_exp.2 (hmax j)
  have hn : 0 < (n : ℝ) := by
    have : 0 < n := Fin.pos i
    exact_mod_cast this
  have hlog := Real.log_le_log (sum_exp_pos x i) hsum
  rw [Real.log_mul (ne_of_gt hn) (Real.exp_ne_zero _), Real.log_exp] at hlog
  simp only [maslovGap, lse]
  linarith

/-! ### Margin ⟹ small gap (near-tropical) -/

/-- **A margin makes the layer tropical.**  If every competitor is at least `m`
below the top, the Maslov gap is at most `log (1 + (n-1) e^{-m})`, which decays
exponentially in the margin. -/
theorem maslovGap_le_of_margin (x : Fin n → ℝ) (i : Fin n) (m : ℝ)
    (hm : ∀ j, j ≠ i → m ≤ x i - x j) :
    maslovGap x i ≤ Real.log (1 + ((n : ℝ) - 1) * Real.exp (-m)) := by
  have hn1 : 1 ≤ n := Fin.pos i
  have hcard : ((univ.erase i).card : ℝ) = (n : ℝ) - 1 := by
    rw [Finset.card_erase_of_mem (mem_univ i)]
    simp [Nat.cast_sub hn1]
  have hterm : ∀ j ∈ univ.erase i, Real.exp (x j) ≤ Real.exp (x i) * Real.exp (-m) := by
    intro j hj
    have hji : j ≠ i := (Finset.mem_erase.1 hj).1
    have : x j ≤ x i + -m := by linarith [hm j hji]
    calc Real.exp (x j) ≤ Real.exp (x i + -m) := Real.exp_le_exp.2 this
      _ = Real.exp (x i) * Real.exp (-m) := Real.exp_add _ _
  have hsplit : ∑ j, Real.exp (x j)
      = Real.exp (x i) + ∑ j ∈ univ.erase i, Real.exp (x j) :=
    (Finset.add_sum_erase univ (fun j => Real.exp (x j)) (mem_univ i)).symm
  have htail : ∑ j ∈ univ.erase i, Real.exp (x j)
      ≤ ((n : ℝ) - 1) * (Real.exp (x i) * Real.exp (-m)) := by
    calc ∑ j ∈ univ.erase i, Real.exp (x j)
        ≤ ∑ _j ∈ univ.erase i, Real.exp (x i) * Real.exp (-m) :=
          Finset.sum_le_sum hterm
      _ = ((univ.erase i).card : ℝ) * (Real.exp (x i) * Real.exp (-m)) := by
          simp [Finset.sum_const, nsmul_eq_mul]
      _ = ((n : ℝ) - 1) * (Real.exp (x i) * Real.exp (-m)) := by rw [hcard]
  have hbound : ∑ j, Real.exp (x j)
      ≤ Real.exp (x i) * (1 + ((n : ℝ) - 1) * Real.exp (-m)) := by
    rw [hsplit]; nlinarith [htail]
  have hpos : (0 : ℝ) < 1 + ((n : ℝ) - 1) * Real.exp (-m) := by
    have h1 : (0 : ℝ) ≤ (n : ℝ) - 1 := by
      have : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn1
      linarith
    have := Real.exp_pos (-m)
    nlinarith
  have hlog := Real.log_le_log (sum_exp_pos x i) hbound
  rw [Real.log_mul (Real.exp_ne_zero _) (ne_of_gt hpos), Real.log_exp] at hlog
  simp only [maslovGap, lse]
  linarith

/-! ### Large gap ⟹ small margin (far from tropical) -/

/-- **Converse bound.**  A measured Maslov gap `g > 0` caps any uniform margin:
`m ≤ log (n-1) - log (e^g - 1)`. -/
theorem margin_le_of_maslovGap (x : Fin n → ℝ) (i : Fin n) (m g : ℝ)
    (hm : ∀ j, j ≠ i → m ≤ x i - x j) (hg : 0 < g) (hgap : g ≤ maslovGap x i)
    (hn : 2 ≤ n) :
    m ≤ Real.log ((n : ℝ) - 1) - Real.log (Real.exp g - 1) := by
  have hn1 : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hupper := maslovGap_le_of_margin x i m hm
  have hpos : (0 : ℝ) < 1 + ((n : ℝ) - 1) * Real.exp (-m) := by
    have := Real.exp_pos (-m); nlinarith
  have hglog : g ≤ Real.log (1 + ((n : ℝ) - 1) * Real.exp (-m)) := le_trans hgap hupper
  have hexp : Real.exp g ≤ 1 + ((n : ℝ) - 1) * Real.exp (-m) := by
    have := Real.exp_le_exp.2 hglog
    rwa [Real.exp_log hpos] at this
  have hg1 : 0 < Real.exp g - 1 := by
    have := Real.add_one_le_exp g
    linarith
  have hnm1 : (0 : ℝ) < (n : ℝ) - 1 := by linarith
  have hkey : (Real.exp g - 1) / ((n : ℝ) - 1) ≤ Real.exp (-m) := by
    rw [div_le_iff₀ hnm1]; linarith
  have hlog := Real.log_le_log (by positivity) hkey
  rw [Real.log_exp, Real.log_div (ne_of_gt hg1) (ne_of_gt hnm1)] at hlog
  linarith

/-- Readable form: for a gap of at least one nat, each further nat of Maslov gap
costs a nat of margin, `m ≤ log (n-1) + log 2 - g`. -/
theorem margin_le_of_maslovGap_simple (x : Fin n → ℝ) (i : Fin n) (m g : ℝ)
    (hm : ∀ j, j ≠ i → m ≤ x i - x j) (hg : 1 ≤ g) (hgap : g ≤ maslovGap x i)
    (hn : 2 ≤ n) :
    m ≤ Real.log ((n : ℝ) - 1) + Real.log 2 - g := by
  have hg0 : 0 < g := lt_of_lt_of_le zero_lt_one hg
  have hmain := margin_le_of_maslovGap x i m g hm hg0 hgap hn
  have hlog2 : Real.log 2 < 1 := by
    have := Real.log_two_lt_d9
    linarith
  have hexp2 : (2 : ℝ) ≤ Real.exp g := by
    calc (2 : ℝ) = Real.exp (Real.log 2) := (Real.exp_log (by norm_num)).symm
      _ ≤ Real.exp g := Real.exp_le_exp.2 (by linarith)
  have hhalf : Real.exp g / 2 ≤ Real.exp g - 1 := by linarith
  have hpos : (0 : ℝ) < Real.exp g / 2 := by positivity
  have hlog := Real.log_le_log hpos hhalf
  rw [Real.log_div (ne_of_gt (Real.exp_pos g)) (by norm_num), Real.log_exp] at hlog
  linarith

/-! ### Small margin ⟹ flippable decision -/

/-- A decision held by a margin of at most `m` over *some* competitor is destroyed
by a coordinatewise perturbation of size `(m + η)/2`. -/
theorem flip_of_small_margin (x : Fin n → ℝ) (i j : Fin n) (hij : j ≠ i) (m eta : ℝ)
    (hgap : x i - x j ≤ m) (hm : 0 ≤ m) (heta : 0 < eta) :
    ∃ y : Fin n → ℝ, (∀ k, |x k - y k| ≤ (m + eta) / 2) ∧ y i < y j ∧ ¬ IsStrictTop y i := by
  set d : ℝ := (m + eta) / 2 with hd
  have hdpos : 0 < d := by rw [hd]; linarith
  refine ⟨Function.update (Function.update x i (x i - d)) j (x j + d), ?_, ?_, ?_⟩
  · intro k
    by_cases hkj : k = j
    · subst hkj
      rw [Function.update_self]
      have : x k - (x k + d) = -d := by ring
      rw [this, abs_neg, abs_of_pos hdpos]
    · rw [Function.update_of_ne hkj]
      by_cases hki : k = i
      · subst hki
        rw [Function.update_self]
        have : x k - (x k - d) = d := by ring
        rw [this, abs_of_pos hdpos]
      · rw [Function.update_of_ne hki]
        simpa using hdpos.le
  · rw [Function.update_of_ne (Ne.symm hij), Function.update_self, Function.update_self]
    have : x i - x j < 2 * d := by rw [hd]; linarith
    linarith
  · intro htop
    have h := htop j hij
    rw [Function.update_of_ne (Ne.symm hij), Function.update_self, Function.update_self] at h
    have h2 : x i - x j < 2 * d := by rw [hd]; linarith
    linarith

/-- Some competitor is within `M + δ` of the top, where `M` is the margin cap
implied by the measured Maslov gap. -/
theorem exists_small_margin_of_maslovGap (x : Fin n → ℝ) (i : Fin n) (g delta : ℝ)
    (hg : 1 ≤ g) (hgap : g ≤ maslovGap x i) (hn : 2 ≤ n) (hdelta : 0 < delta) :
    ∃ j, j ≠ i ∧ x i - x j < Real.log ((n : ℝ) - 1) + Real.log 2 - g + delta := by
  by_contra hcon
  push_neg at hcon
  set M : ℝ := Real.log ((n : ℝ) - 1) + Real.log 2 - g with hM
  have hm : ∀ j, j ≠ i → M + delta ≤ x i - x j := fun j hj => hcon j hj
  have := margin_le_of_maslovGap_simple x i (M + delta) g hm hg hgap hn
  rw [← hM] at this
  linarith

/-- **Far from tropical ⟹ decision-fragile.**  A layer whose Maslov gap is at
least `g ≥ 1` (the NET-50 tail regime, `g ≈ 2.5`) admits a coordinatewise
perturbation of size at most `(log (n-1) + log 2 - g + δ + η)/2` that destroys its
top-1 decision — even though such a perturbation leaves the score vector
cosine-similar (`cosine_near_one_decision_flip`).  Conversely, by
`maslovGap_le_of_margin`, a near-tropical layer (small gap) has a large margin and
is stable (`strictTop_of_margin`).  This is the NET-50 ⋈ NET-51 convergence. -/
theorem far_from_tropical_is_fragile (x : Fin n → ℝ) (i : Fin n) (g delta eta : ℝ)
    (hg : 1 ≤ g) (hgap : g ≤ maslovGap x i) (hn : 2 ≤ n)
    (hdelta : 0 < delta) (heta : 0 < eta)
    (hcap : 0 ≤ Real.log ((n : ℝ) - 1) + Real.log 2 - g + delta) :
    ∃ (j : Fin n) (y : Fin n → ℝ), j ≠ i ∧
      (∀ k, |x k - y k| ≤ (Real.log ((n : ℝ) - 1) + Real.log 2 - g + delta + eta) / 2) ∧
      y i < y j ∧ ¬ IsStrictTop y i := by
  obtain ⟨j, hj, hlt⟩ := exists_small_margin_of_maslovGap x i g delta hg hgap hn hdelta
  obtain ⟨y, hy1, hy2, hy3⟩ :=
    flip_of_small_margin x i j hj (Real.log ((n : ℝ) - 1) + Real.log 2 - g + delta) eta
      hlt.le hcap heta
  exact ⟨j, y, hj, hy1, hy2, hy3⟩

end Catalog.Novelty.TropicalMaslovMarginBridge