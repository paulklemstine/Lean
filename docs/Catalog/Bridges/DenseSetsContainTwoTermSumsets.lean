/-
# Dense sets always contain a sumset `A + B` with `|B| = 2` and `|A|` linear in `n`

This is the complement to the sharpness construction of
`Bridges/DeltaDenseSumsetAvoidance.lean`.  There we produced, for each `0 < δ < 1`, a set
`S ⊆ [n]` with `|S| ≥ δ n` avoiding all sumsets `A + B` of two arithmetic progressions of
common length `≳ log n / log (1/δ)`.  The bound `min(|A|,|B|) ≳ log n` in such statements
must involve **both** summands: no bound at all can be imposed on the *larger* summand.

Indeed, here we prove that **every** set `S ⊆ [n]` contains a sumset `A + B` with
`|B| = 2` and `|A| ≥ (|S|² - |S|)/(2n)`, i.e. of size `≍ δ² n` when `|S| = δ n`.  Thus for
a `δ`-dense set one can always find a sumset with one summand of *linear* size, and it is
only the requirement that both summands be large which forces the logarithmic bound.

Main results:

* `TwoTermSumsets.exists_two_term_sumset` : the counting statement, in `ℕ`;
* `TwoTermSumsets.exists_two_term_sumset_density` : its density form, `|A| ≥ δ(δn-1)/2`.
-/
import Mathlib

namespace TwoTermSumsets

open Finset Pointwise

/-- For `d ≥ 1`, the set of `x ∈ S` with `x + d ∈ S`; equivalently `S ∩ (S - d)`. -/
def shiftInter (S : Finset ℕ) (d : ℕ) : Finset ℕ := S.filter (fun x => x + d ∈ S)

lemma shiftInter_subset (S : Finset ℕ) (d : ℕ) : shiftInter S d ⊆ S :=
  Finset.filter_subset _ _

/-- `shiftInter S d + {0, d} ⊆ S`: a sumset with a two-element summand. -/
lemma shiftInter_add_pair (S : Finset ℕ) (d : ℕ) :
    shiftInter S d + ({0, d} : Finset ℕ) ⊆ S := by
  intro x hx
  rw [Finset.mem_add] at hx
  obtain ⟨a, ha, b, hb, rfl⟩ := hx
  rw [shiftInter, Finset.mem_filter] at ha
  simp only [Finset.mem_insert, Finset.mem_singleton] at hb
  rcases hb with rfl | rfl
  · simpa using ha.1
  · exact ha.2

/-- The number of ordered pairs `x < y` from `S`, split according to the difference
`y - x`, equals `∑_{d=1}^{n} |S ∩ (S - d)|`. -/
lemma sum_shiftInter_card {n : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) :
    ∑ d ∈ Icc 1 n, (shiftInter S d).card
      = ((S ×ˢ S).filter (fun p => p.1 < p.2)).card := by
  classical
  set P := (S ×ˢ S).filter (fun p => p.1 < p.2) with hP
  have hmemP0 : ∀ p : ℕ × ℕ, p ∈ P ↔ (p.1 ∈ S ∧ p.2 ∈ S) ∧ p.1 < p.2 := by
    intro p; rw [hP, Finset.mem_filter, Finset.mem_product]
  have hfib : P.card = ∑ d ∈ Icc 1 n, (P.filter (fun p => p.2 - p.1 = d)).card := by
    refine Finset.card_eq_sum_card_fiberwise ?_
    intro p hp
    rw [Finset.mem_coe, hmemP0] at hp
    have h2 : p.2 < n := by simpa using hS hp.1.2
    rw [Finset.mem_coe, Finset.mem_Icc]
    simp only []
    omega
  rw [hfib]
  refine Finset.sum_congr rfl fun d hd => ?_
  rw [Finset.mem_Icc] at hd
  have hmemP : ∀ p : ℕ × ℕ, p ∈ P.filter (fun p => p.2 - p.1 = d) ↔
      (p.1 ∈ S ∧ p.2 ∈ S) ∧ p.1 < p.2 ∧ p.2 - p.1 = d := by
    intro p
    rw [Finset.mem_filter, hmemP0]
    tauto
  have hmemS : ∀ x : ℕ, x ∈ shiftInter S d ↔ x ∈ S ∧ x + d ∈ S := by
    intro x; rw [shiftInter, Finset.mem_filter]
  refine Finset.card_nbij' (fun x => (x, x + d)) (fun p => p.1) ?_ ?_ ?_ ?_
  · intro x hx
    rw [Finset.mem_coe, hmemS] at hx
    rw [Finset.mem_coe, hmemP]
    exact ⟨⟨hx.1, hx.2⟩, by simp; omega, by simp⟩
  · intro p hp
    rw [Finset.mem_coe, hmemP] at hp
    rw [Finset.mem_coe, hmemS]
    obtain ⟨⟨h1, h2⟩, h3, h4⟩ := hp
    have he : p.1 + d = p.2 := by omega
    rw [he]
    exact ⟨h1, h2⟩
  · intro x _; rfl
  · intro p hp
    rw [Finset.mem_coe, hmemP] at hp
    have he : p.1 + d = p.2 := by omega
    exact Prod.ext rfl he

/-- The number of ordered pairs `x < y` from `S` is `(|S|² - |S|)/2`. -/
lemma two_mul_card_lt_pairs (S : Finset ℕ) :
    2 * ((S ×ˢ S).filter (fun p => p.1 < p.2)).card + S.card = S.card * S.card := by
  classical
  set P := (S ×ˢ S).filter (fun p => p.1 < p.2) with hP
  set Q := (S ×ˢ S).filter (fun p => p.2 < p.1) with hQ
  have hPQ : P.card = Q.card := by
    refine Finset.card_nbij' (fun p => (p.2, p.1)) (fun p => (p.2, p.1)) ?_ ?_ ?_ ?_
    · intro p hp
      simp only [Finset.mem_coe, hP, hQ, Finset.mem_filter, Finset.mem_product] at hp ⊢
      exact ⟨⟨hp.1.2, hp.1.1⟩, hp.2⟩
    · intro p hp
      simp only [Finset.mem_coe, hP, hQ, Finset.mem_filter, Finset.mem_product] at hp ⊢
      exact ⟨⟨hp.1.2, hp.1.1⟩, hp.2⟩
    · intro p _; rfl
    · intro p _; rfl
  have hsplit : S.offDiag = P ∪ Q := by
    ext p
    simp only [Finset.mem_offDiag, hP, hQ, Finset.mem_union, Finset.mem_filter,
      Finset.mem_product]
    constructor
    · rintro ⟨h1, h2, h3⟩
      rcases lt_or_gt_of_ne h3 with h | h
      · exact Or.inl ⟨⟨h1, h2⟩, h⟩
      · exact Or.inr ⟨⟨h1, h2⟩, h⟩
    · rintro (⟨⟨h1, h2⟩, h3⟩ | ⟨⟨h1, h2⟩, h3⟩)
      · exact ⟨h1, h2, by omega⟩
      · exact ⟨h1, h2, by omega⟩
  have hdisj : Disjoint P Q := by
    refine Finset.disjoint_left.2 fun p hp hq => ?_
    simp only [hP, hQ, Finset.mem_filter] at hp hq
    omega
  have hcard : S.offDiag.card = P.card + Q.card := by
    rw [hsplit, Finset.card_union_of_disjoint hdisj]
  have hoff : S.offDiag.card = S.card * S.card - S.card := Finset.offDiag_card S
  have hle : S.card ≤ S.card * S.card := by
    rcases Nat.eq_zero_or_pos S.card with h | h
    · simp [h]
    · exact Nat.le_mul_of_pos_left _ h
  omega

/-- **Every** subset of `[n]` contains a sumset `A + {0,d}` (so `|B| = 2`) whose large
summand `A` has at least `(|S|² - |S|)/(2n)` elements.  Consequently the "both summands
large" hypothesis in sumset-avoidance statements cannot be weakened to a hypothesis on a
single summand. -/
theorem exists_two_term_sumset {n : ℕ} {S : Finset ℕ} (hS : S ⊆ range n) (hn : 0 < n) :
    ∃ d : ℕ, 0 < d ∧ ∃ A : Finset ℕ, A ⊆ S ∧ A + ({0, d} : Finset ℕ) ⊆ S ∧
      S.card * S.card ≤ 2 * n * A.card + S.card := by
  classical
  have hne : (Icc 1 n).Nonempty := ⟨1, Finset.mem_Icc.2 ⟨le_rfl, hn⟩⟩
  obtain ⟨d, hd, hmax⟩ :=
    Finset.exists_max_image (Icc 1 n) (fun d => (shiftInter S d).card) hne
  have hsum : ∑ e ∈ Icc 1 n, (shiftInter S e).card ≤ n * (shiftInter S d).card := by
    calc ∑ e ∈ Icc 1 n, (shiftInter S e).card
        ≤ ∑ _e ∈ Icc 1 n, (shiftInter S d).card := Finset.sum_le_sum (fun e he => hmax e he)
      _ = n * (shiftInter S d).card := by
          rw [Finset.sum_const, Nat.card_Icc, smul_eq_mul]
          simp
  have h1 := sum_shiftInter_card hS
  have h2 := two_mul_card_lt_pairs S
  rw [Finset.mem_Icc] at hd
  have h3 : 2 * (n * (shiftInter S d).card) = 2 * n * (shiftInter S d).card := by ring
  refine ⟨d, by omega, shiftInter S d, shiftInter_subset S d, shiftInter_add_pair S d, ?_⟩
  omega

/-- Density form: a `δ`-dense subset of `[n]` contains a sumset `A + B` with `|B| = 2`
and `|A| ≥ δ(δn - 1)/2`, which is linear in `n`. -/
theorem exists_two_term_sumset_density {n : ℕ} {S : Finset ℕ} {δ : ℝ}
    (hS : S ⊆ range n) (hn : 0 < n) (hδ0 : 0 < δ) (hdense : δ * n ≤ S.card) (hδn : 1 ≤ δ * n) :
    ∃ d : ℕ, 0 < d ∧ ∃ A : Finset ℕ, A ⊆ S ∧ A + ({0, d} : Finset ℕ) ⊆ S ∧
      δ * (δ * n - 1) / 2 ≤ A.card := by
  obtain ⟨d, hd, A, hAS, hAsub, hcard⟩ := exists_two_term_sumset hS hn
  refine ⟨d, hd, A, hAS, hAsub, ?_⟩
  have hcardR : (S.card : ℝ) * S.card ≤ 2 * n * A.card + S.card := by exact_mod_cast hcard
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hm1 : (1 : ℝ) ≤ S.card := le_trans hδn hdense
  -- `t ↦ t² - t` is increasing on `t ≥ 1`
  have hmono : δ * n * (δ * n) - δ * n ≤ (S.card : ℝ) * S.card - S.card := by
    nlinarith [hdense, hm1, hδn]
  have : δ * n * (δ * n - 1) ≤ 2 * n * A.card := by nlinarith [hcardR, hmono]
  rw [div_le_iff₀ (by norm_num)]
  nlinarith [this, hnR]

end TwoTermSumsets