/-
# Sharpness of the factor-blindness wall: zero leakage **iff** the table is a product

Cycle 1 (`Computation.FactorBlindnessWall`) proved that a symmetric readout leaks exactly
zero which-factor bits, and that a positive plug-in reading matching its own permutation null
is bias.  Both statements are one-sided: they say when the reading *must* be zero, and when a
positive reading is *uninformative*.  The obvious adversarial objection is then:

> is the functional you are using able to see leakage at all?

This file answers it by proving the converse half, which requires the **equality case** of
Gibbs' inequality rather than the inequality itself.

## Main results

* `sum_mul_log_div_pos` — strict Gibbs: if `p i₀ > 0` and `p i₀ ≠ q i₀` for a single index,
  the relative entropy is *strictly* positive.  Proved from `Real.log_lt_sub_one_of_pos`, the
  strict form of `log x ≤ x - 1`.
* `exists_pos_ne_of_ne` — a transfer lemma: two probability vectors that differ anywhere
  differ at an index where the first one is *positive*.  (Without it, strict Gibbs cannot be
  applied: the discrepancy could hide on the null set of `p`.)
* `mutualInfo_pos_of_ne_product` — any deviation from the product table produces a strictly
  positive reading.
* `mutualInfo_eq_zero_iff_product` — **the wall is exactly the product locus**: a plug-in
  reading of zero is equivalent to exact independence of the contingency table.
* `mutualInfo_sub_entropy_margL`, `mutualInfo_le_entropy_margL` — the reading is capped by the
  label entropy, so a which-factor reading of a binary label can never exceed `1` bit; with
  `sparse_mutualInfo` this shows the sparse regime sits exactly at the cap, which is why a
  sparse reading is a statistic of the label margin and not of any dependence.
* `leaky_mutualInfo`, `symmetry_is_necessary` — the instrument has power: on the *same* kind
  of population (swap-closed, off-diagonal) an **asymmetric** readout is caught at a full
  `1` bit.  Symmetry of the readout is therefore load-bearing in
  `galoisBlind_zero_leakage`, not decorative, and the battery's zero is a genuine finding
  rather than a blind functional.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the zero-leakage theorem could be an artefact of a weak functional; if
  so, some asymmetric readout on a swap-closed population would also read zero.
Experiment (Stage 2): built the minimal asymmetric readout — the which-factor label used as
  its own code — on the two-element population `{(3,5),(5,3)}`, and computed its exact
  reading: `1` bit, the maximum possible for a binary label.  The functional is therefore
  maximally sensitive on the very population family where the battery reads zero.
Analysis (Stage 3): the failure mode of the first attempt was instructive and is recorded in
  `exists_pos_ne_of_ne`: strict Gibbs needs the discrepancy to sit where `p > 0`, and a naive
  induction supplies only *some* discrepancy.  The repair is a mass-balance argument — if `p`
  and `q` agree wherever `p > 0`, then `∑ (q - p) = 0` with a pointwise nonnegative summand,
  forcing `q = p` everywhere.
Critique (Stage 4): `mutualInfo_eq_zero_iff_product` is stated for tables with total mass `1`
  and nonnegative entries; on the empty population the joint law is identically `0`, total
  mass `0`, and both sides of the iff degenerate — the hypothesis `htot` excludes exactly
  that corner, and the zero-leakage theorem of cycle 1 is *not* stated with it, so no
  circularity or hidden emptiness is introduced.
Synthesis (Stage 5): leakage is zero iff the contingency table factors; symmetry gives the
  factorisation; asymmetry is detected at full strength.  The three statements close the
  logical square around the experimental verdict.
-/
import Mathlib
import Computation.FactorBlindnessInformation
import Computation.FactorBlindnessWall

namespace Computation.FactorBlindness

open Finset

/-! ## Strict Gibbs -/

/-- **Strict Gibbs' inequality.**  A single index where `p` is positive and disagrees with `q`
already forces the relative entropy to be strictly positive. -/
theorem sum_mul_log_div_pos {ι : Type*} [Fintype ι] (p q : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i) (hac : ∀ i, q i = 0 → p i = 0)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i ≤ 1)
    {i₀ : ι} (hpos : 0 < p i₀) (hne : p i₀ ≠ q i₀) :
    0 < ∑ i, p i * Real.log (p i / q i) := by
  have key : ∀ i ∈ (univ : Finset ι), -(p i * Real.log (p i / q i)) ≤ q i - p i := by
    intro i _
    rcases eq_or_lt_of_le (hp i) with h | h
    · simp [← h, hq i]
    · have hqi : 0 < q i := by
        rcases eq_or_lt_of_le (hq i) with h0 | h0
        · exact absurd (hac i h0.symm) (ne_of_gt h)
        · exact h0
      have hlog : Real.log (p i / q i) = -Real.log (q i / p i) := by
        rw [← Real.log_inv]; congr 1; field_simp
      have hle : Real.log (q i / p i) ≤ q i / p i - 1 :=
        Real.log_le_sub_one_of_pos (div_pos hqi h)
      have hmul : p i * Real.log (q i / p i) ≤ p i * (q i / p i - 1) :=
        mul_le_mul_of_nonneg_left hle (le_of_lt h)
      have hid : p i * (q i / p i - 1) = q i - p i := by field_simp
      rw [hlog]; linarith [hid ▸ hmul]
  have hstrict : -(p i₀ * Real.log (p i₀ / q i₀)) < q i₀ - p i₀ := by
    have hqi : 0 < q i₀ := by
      rcases eq_or_lt_of_le (hq i₀) with h0 | h0
      · exact absurd (hac i₀ h0.symm) (ne_of_gt hpos)
      · exact h0
    have hratio : q i₀ / p i₀ ≠ 1 := by
      intro h
      rw [div_eq_one_iff_eq (ne_of_gt hpos)] at h
      exact hne h.symm
    have hlt : Real.log (q i₀ / p i₀) < q i₀ / p i₀ - 1 :=
      Real.log_lt_sub_one_of_pos (div_pos hqi hpos) hratio
    have hmul : p i₀ * Real.log (q i₀ / p i₀) < p i₀ * (q i₀ / p i₀ - 1) :=
      mul_lt_mul_of_pos_left hlt hpos
    have hid : p i₀ * (q i₀ / p i₀ - 1) = q i₀ - p i₀ := by field_simp
    have hlog : Real.log (p i₀ / q i₀) = -Real.log (q i₀ / p i₀) := by
      rw [← Real.log_inv]; congr 1; field_simp
    have hrw : -(p i₀ * Real.log (p i₀ / q i₀)) = p i₀ * Real.log (q i₀ / p i₀) := by
      rw [hlog]; ring
    rw [hrw]; linarith [hid ▸ hmul]
  have hsum : ∑ i, -(p i * Real.log (p i / q i)) < ∑ i, (q i - p i) :=
    Finset.sum_lt_sum key ⟨i₀, mem_univ i₀, hstrict⟩
  have h1 : ∑ i, -(p i * Real.log (p i / q i)) = -∑ i, p i * Real.log (p i / q i) := by simp
  have h2 : ∑ i, (q i - p i) = (∑ i, q i) - ∑ i, p i := by rw [Finset.sum_sub_distrib]
  rw [h1, h2, hp1] at hsum
  linarith

/-- Two probability vectors that differ somewhere must differ at an index where the first is
positive.  (The discrepancy cannot hide on the null set of `p`: mass balance forbids it.) -/
theorem exists_pos_ne_of_ne {ι : Type*} [Fintype ι] (p q : ι → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (hp1 : ∑ i, p i = 1) (hq1 : ∑ i, q i = 1)
    {i₁ : ι} (h1 : p i₁ ≠ q i₁) : ∃ i, 0 < p i ∧ p i ≠ q i := by
  by_contra hcon
  push_neg at hcon
  have hle : ∀ i ∈ (univ : Finset ι), 0 ≤ q i - p i := by
    intro i _
    rcases eq_or_lt_of_le (hp i) with h | h
    · simpa [← h] using hq i
    · have := hcon i h
      linarith [this]
  have hzero : ∑ i, (q i - p i) = 0 := by
    rw [Finset.sum_sub_distrib, hp1, hq1]; ring
  have := (Finset.sum_eq_zero_iff_of_nonneg hle).1 hzero i₁ (mem_univ i₁)
  exact h1 (by linarith)

/-! ## The wall is exactly the product locus -/

variable {L K : Type*} [Fintype L] [Fintype K]

/-- **Any deviation from independence is seen.**  If the table differs from its product table
at even one cell, the plug-in reading is strictly positive. -/
theorem mutualInfo_pos_of_ne_product {p : L → K → ℝ} (hp : ∀ l k, 0 ≤ p l k)
    (htot : ∑ l, ∑ k, p l k = 1) {l₁ : L} {k₁ : K}
    (hne : p l₁ k₁ ≠ margL p l₁ * margK p k₁) : 0 < mutualInfo p := by
  set P : L × K → ℝ := fun x => p x.1 x.2 with hP
  set Q : L × K → ℝ := fun x => margL p x.1 * margK p x.2 with hQ
  have hPnn : ∀ x, 0 ≤ P x := fun x => hp x.1 x.2
  have hQnn : ∀ x, 0 ≤ Q x := fun x =>
    mul_nonneg (margL_nonneg hp x.1) (margK_nonneg hp x.2)
  have hac : ∀ x, Q x = 0 → P x = 0 := by
    rintro ⟨l, k⟩ hx
    rcases mul_eq_zero.1 hx with h | h
    · exact eq_zero_of_margL_eq_zero hp h k
    · exact eq_zero_of_margK_eq_zero hp h l
  have hP1 : ∑ x : L × K, P x = 1 := by rw [Fintype.sum_prod_type]; exact htot
  have hQ1 : ∑ x : L × K, Q x = 1 := by
    have hsplit : ∑ x : L × K, Q x = (∑ l, margL p l) * ∑ k, margK p k := by
      rw [Fintype.sum_prod_type, Finset.sum_mul]
      exact Finset.sum_congr rfl fun l _ => by rw [Finset.mul_sum]
    rw [hsplit, sum_margL, sum_margK, htot, one_mul]
  obtain ⟨x₀, hx₀pos, hx₀ne⟩ :=
    exists_pos_ne_of_ne P Q hPnn hQnn hP1 hQ1 (i₁ := (l₁, k₁)) hne
  have hgibbs := sum_mul_log_div_pos P Q hPnn hQnn hac hP1 (le_of_eq hQ1) hx₀pos hx₀ne
  have hmi : mutualInfo p = (∑ x : L × K, P x * Real.log (P x / Q x)) / Real.log 2 := by
    rw [Fintype.sum_prod_type, Finset.sum_div]
    refine Finset.sum_congr rfl fun l _ => ?_
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun k _ => by simp [Real.logb, hP, hQ, mul_div_assoc]
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [hmi]
  exact div_pos hgibbs hlog2

/-- **The equality case: a zero reading is exactly independence.**  This is the sharp form of
the factor-blindness wall — the wall is the product locus, nothing more and nothing less. -/
theorem mutualInfo_eq_zero_iff_product {p : L → K → ℝ} (hp : ∀ l k, 0 ≤ p l k)
    (htot : ∑ l, ∑ k, p l k = 1) :
    mutualInfo p = 0 ↔ ∀ l k, p l k = margL p l * margK p k := by
  constructor
  · intro h0
    by_contra hcon
    push_neg at hcon
    obtain ⟨l₁, k₁, hne⟩ := hcon
    exact absurd h0 (ne_of_gt (mutualInfo_pos_of_ne_product hp htot hne))
  · exact mutualInfo_eq_zero_of_product

/-! ## The label-entropy cap: a which-factor reading can never exceed one bit -/

/-- The gap between the reading and the label entropy is the (negated) conditional entropy of
the label given the code. -/
theorem mutualInfo_sub_entropy_margL {p : L → K → ℝ} (hp : ∀ l k, 0 ≤ p l k) :
    mutualInfo p - entropy (margL p)
      = ∑ l, ∑ k, p l k * Real.logb 2 (p l k / margK p k) := by
  unfold mutualInfo entropy
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun l _ => ?_
  rcases eq_or_lt_of_le (margL_nonneg hp l) with hL | hL
  · have hzero : ∀ k, p l k = 0 := eq_zero_of_margL_eq_zero hp hL.symm
    simp [hzero, ← hL]
  · have hterm : ∀ k : K, p l k * Real.logb 2 (p l k / (margL p l * margK p k))
        = p l k * Real.logb 2 (p l k / margK p k) - p l k * Real.logb 2 (margL p l) := by
      intro k
      rcases eq_or_lt_of_le (hp l k) with h | h
      · simp [← h]
      · have hK : 0 < margK p k := by
          have : p l k ≤ margK p k :=
            Finset.single_le_sum (f := fun l => p l k) (fun l _ => hp l k) (mem_univ l)
          linarith
        have hsplit : p l k / (margL p l * margK p k) = (p l k / margK p k) / margL p l := by
          field_simp
        rw [hsplit, Real.logb_div (by positivity) (ne_of_gt hL)]
        ring
    rw [Finset.sum_congr rfl (fun k _ => hterm k), Finset.sum_sub_distrib, ← Finset.sum_mul]
    have : ∑ k, p l k = margL p l := rfl
    rw [this]
    ring

/-- **The reading is capped by the label entropy.**  Plug-in mutual information never exceeds
the entropy of the label margin; combined with `sparse_mutualInfo` this says the sparse
regime sits exactly at the cap. -/
theorem mutualInfo_le_entropy_margL {p : L → K → ℝ} (hp : ∀ l k, 0 ≤ p l k) :
    mutualInfo p ≤ entropy (margL p) := by
  have hgap := mutualInfo_sub_entropy_margL hp
  have hle : ∑ l, ∑ k, p l k * Real.logb 2 (p l k / margK p k) ≤ 0 := by
    refine Finset.sum_nonpos fun l _ => Finset.sum_nonpos fun k _ => ?_
    rcases eq_or_lt_of_le (hp l k) with h | h
    · simp [← h]
    · have hK : p l k ≤ margK p k :=
        Finset.single_le_sum (f := fun l => p l k) (fun l _ => hp l k) (mem_univ l)
      have hKpos : 0 < margK p k := lt_of_lt_of_le h hK
      have : Real.logb 2 (p l k / margK p k) ≤ 0 :=
        Real.logb_nonpos (by norm_num) (by positivity)
          ((div_le_one hKpos).2 hK)
      exact mul_nonpos_of_nonneg_of_nonpos (le_of_lt h) this
  linarith [hgap ▸ hle]

/-! ## The instrument has power: asymmetry is caught at a full bit -/

/-- A two-element swap-closed, off-diagonal population. -/
def leakyS : Finset (ℕ × ℕ) := {(3, 5), (5, 3)}

/-- The maximally indiscreet readout: it publishes the which-factor label itself.  This is the
one readout of the population that is *not* symmetric. -/
def leakyCode (x : ℕ × ℕ) : Bool := decide (x.1 < x.2)

theorem leakyS_swap_closed : ∀ x ∈ leakyS, x.swap ∈ leakyS := by decide

theorem leakyS_offDiagonal : ∀ x ∈ leakyS, x.1 ≠ x.2 := by decide

theorem leakyCode_not_symmetric : ∃ x, leakyCode x.swap ≠ leakyCode x :=
  ⟨(3, 5), by decide⟩

theorem leaky_jointDist (b k : Bool) :
    jointDist leakyS leakyCode b k = if b = k then 1 / 2 else 0 := by
  have hcard : leakyS.card = 2 := by decide
  have h00 : (codeCell leakyS leakyCode false false).card = 1 := by decide
  have h01 : (codeCell leakyS leakyCode false true).card = 0 := by decide
  have h10 : (codeCell leakyS leakyCode true false).card = 0 := by decide
  have h11 : (codeCell leakyS leakyCode true true).card = 1 := by decide
  cases b <;> cases k <;> simp [jointDist, hcard, h00, h01, h10, h11]

/-- **Power of the instrument.**  The asymmetric readout on a swap-closed, off-diagonal
population reads a full bit — the maximum possible for a binary label.  The functional used
to certify the battery's zero is therefore not blind. -/
theorem leaky_mutualInfo : mutualInfo (jointDist leakyS leakyCode) = 1 := by
  have h : jointDist leakyS leakyCode = fun b k => if b = k then (1:ℝ) / 2 else 0 := by
    funext b k; exact leaky_jointDist b k
  rw [h]
  simp [mutualInfo, margL, margK]

/-- **Symmetry is load-bearing.**  There is a swap-closed, off-diagonal population carrying a
readout whose which-factor leakage is a full bit; the hypothesis `∀ x, c x.swap = c x` in
`galoisBlind_zero_leakage` cannot be dropped. -/
theorem symmetry_is_necessary :
    ∃ (S : Finset (ℕ × ℕ)) (c : ℕ × ℕ → Bool),
      (∀ x ∈ S, x.swap ∈ S) ∧ (∀ x ∈ S, x.1 ≠ x.2) ∧
      (∃ x, c x.swap ≠ c x) ∧ mutualInfo (jointDist S c) = 1 :=
  ⟨leakyS, leakyCode, leakyS_swap_closed, leakyS_offDiagonal, leakyCode_not_symmetric,
    leaky_mutualInfo⟩

/-- **The dichotomy of the battery programme.**  On the same population family, the symmetric
battery readout reads exactly `0` bits while the asymmetric readout reads exactly `1` bit:
zero leakage is a property of the *readout's symmetry*, not a limitation of the measurement. -/
theorem blindness_dichotomy :
    mutualInfo (jointDist leakyS battery4) = 0 ∧
    mutualInfo (jointDist leakyS leakyCode) = 1 :=
  ⟨battery4_zero_leakage leakyS_swap_closed leakyS_offDiagonal, leaky_mutualInfo⟩

end Computation.FactorBlindness