import Pythagorean.FactoringBarriers.Dequant.CombSpectrum

/-!
# Barrier IV, cycle 3: the exact distance between two comb distributions

The pigeonhole bound `Dequant.no_order_free_sampler` is soft.  Here we compute the
total variation between the output distributions of two different orders
*exactly*:

  `TV(P_{r₁}, P_{r₂}) = 1 - gcd(r₁,r₂) / max(r₁,r₂)`.

Two consequences:

* `Dequant.tv_comb_comb` — the exact formula (for `r₁ ≤ r₂`, both dividing `Q`).
* `Dequant.sampler_far_from_one_of_two` — by the triangle inequality, *any* single
  distribution is at total variation at least `(1 - gcd/max)/2` from one of the two
  candidate outputs.  For coprime orders this is `(1 - 1/r₂)/2 → 1/2`: the "`TV ≥
  0.5`" figure of the assessment, now a theorem with an exact constant.
-/

namespace Dequant

open Finset

variable {Q r₁ r₂ : ℕ}

/-- The peaks visible to *both* orders are the peaks of their gcd. -/
theorem peaks_inter (h1 : r₁ ∣ Q) (h2 : r₂ ∣ Q) :
    peaks Q r₁ ∩ peaks Q r₂ = peaks Q (Nat.gcd r₁ r₂) := by
  ext y
  simp only [Finset.mem_inter, mem_peaks]
  constructor
  · rintro ⟨⟨hy, hd1⟩, ⟨-, hd2⟩⟩
    refine ⟨hy, ?_⟩
    rw [← Nat.div_lcm_eq_div_gcd h1 h2]
    exact Nat.lcm_dvd hd1 hd2
  · rintro ⟨hy, hd⟩
    rw [← Nat.div_lcm_eq_div_gcd h1 h2] at hd
    exact ⟨⟨hy, dvd_trans (Nat.dvd_lcm_left _ _) hd⟩,
      ⟨hy, dvd_trans (Nat.dvd_lcm_right _ _) hd⟩⟩

/-- **Exact distance between two comb distributions.**  For orders `r₁ ≤ r₂`
dividing the grid size, the total variation between the two exact output
distributions is `1 - gcd(r₁,r₂)/r₂`. -/
theorem tv_comb_comb (hr₁ : 0 < r₁) (hr₂ : 0 < r₂) (hQ : 0 < Q)
    (h1 : r₁ ∣ Q) (h2 : r₂ ∣ Q) (hle : r₁ ≤ r₂) :
    tv (combDist hr₁ hQ h1) (combDist hr₂ hQ h2)
      = 1 - (Nat.gcd r₁ r₂ : ℝ) / r₂ := by
  classical
  set g := Nat.gcd r₁ r₂ with hg
  have hgpos : 0 < g := Nat.gcd_pos_of_pos_left r₂ hr₁
  have hgQ : g ∣ Q := dvd_trans (Nat.gcd_dvd_left r₁ r₂) h1
  set P := peaks Q r₁ with hP
  set R := peaks Q r₂ with hR
  set D := combDist hr₁ hQ h1 with hD
  set E := combDist hr₂ hQ h2 with hE
  have hPsub : P ⊆ Finset.range Q := Finset.filter_subset _ _
  have hRsub : R ⊆ Finset.range Q := Finset.filter_subset _ _
  have hcardP : P.card = r₁ := card_peaks hr₁ hQ h1
  have hcardR : R.card = r₂ := card_peaks hr₂ hQ h2
  have hcardG : (P ∩ R).card = g := by
    rw [hP, hR, peaks_inter h1 h2]
    exact card_peaks hgpos hQ hgQ
  have hr₁R : (0:ℝ) < r₁ := by exact_mod_cast hr₁
  have hr₂R : (0:ℝ) < r₂ := by exact_mod_cast hr₂
  -- values of the two densities
  have hDval : ∀ y, D.p y = if y ∈ P then 1 / (r₁ : ℝ) else 0 := by
    intro y; simp [hD, combDist, combPMF, hP]
  have hEval : ∀ y, E.p y = if y ∈ R then 1 / (r₂ : ℝ) else 0 := by
    intro y; simp [hE, combDist, combPMF, hR]
  -- reduce the sum to `P ∪ R`
  have hoff : ∀ y ∈ Finset.range Q, y ∉ P ∪ R → |D.p y - E.p y| = 0 := by
    intro y _ hy
    rw [Finset.mem_union] at hy
    push_neg at hy
    simp [hDval y, hEval y, hy.1, hy.2]
  have hunion_sub : P ∪ R ⊆ Finset.range Q := Finset.union_subset hPsub hRsub
  have hreduce : ∑ y ∈ Finset.range Q, |D.p y - E.p y|
      = ∑ y ∈ P ∪ R, |D.p y - E.p y| :=
    (Finset.sum_subset hunion_sub hoff).symm
  -- split `P ∪ R` into `P \ R`, `R \ P` and `P ∩ R`
  have hsplit1 : ∑ y ∈ P ∪ R, |D.p y - E.p y|
      = ∑ y ∈ (P ∪ R) \ R, |D.p y - E.p y| + ∑ y ∈ R, |D.p y - E.p y| :=
    (Finset.sum_sdiff (Finset.subset_union_right)).symm
  have hPR : (P ∪ R) \ R = P \ R := by
    ext y; simp only [Finset.mem_sdiff, Finset.mem_union]; tauto
  have hsplit2 : ∑ y ∈ R, |D.p y - E.p y|
      = ∑ y ∈ R \ P, |D.p y - E.p y| + ∑ y ∈ P ∩ R, |D.p y - E.p y| := by
    have hsub : P ∩ R ⊆ R := Finset.inter_subset_right
    rw [← Finset.sum_sdiff hsub]
    congr 1
    congr 1
    ext y
    simp only [Finset.mem_sdiff, Finset.mem_inter]
    tauto
  -- the three constant values
  have hv1 : ∀ y ∈ P \ R, |D.p y - E.p y| = 1 / (r₁ : ℝ) := by
    intro y hy
    obtain ⟨hyP, hyR⟩ := Finset.mem_sdiff.mp hy
    rw [hDval y, hEval y, if_pos hyP, if_neg hyR, sub_zero, abs_of_pos (by positivity)]
  have hv2 : ∀ y ∈ R \ P, |D.p y - E.p y| = 1 / (r₂ : ℝ) := by
    intro y hy
    obtain ⟨hyR, hyP⟩ := Finset.mem_sdiff.mp hy
    rw [hDval y, hEval y, if_pos hyR, if_neg hyP, zero_sub, abs_neg,
      abs_of_pos (by positivity)]
  have hv3 : ∀ y ∈ P ∩ R, |D.p y - E.p y| = 1 / (r₁ : ℝ) - 1 / r₂ := by
    intro y hy
    obtain ⟨hyP, hyR⟩ := Finset.mem_inter.mp hy
    have hmono : 1 / (r₂ : ℝ) ≤ 1 / r₁ := by
      apply one_div_le_one_div_of_le hr₁R
      exact_mod_cast hle
    rw [hDval y, hEval y, if_pos hyP, if_pos hyR, abs_of_nonneg (by linarith)]
  -- cardinalities of the three pieces
  have hgle₁ : g ≤ r₁ := Nat.le_of_dvd hr₁ (Nat.gcd_dvd_left r₁ r₂)
  have hgle₂ : g ≤ r₂ := Nat.le_of_dvd hr₂ (Nat.gcd_dvd_right r₁ r₂)
  have hcard1 : (P \ R).card = r₁ - g := by
    have e1 : (P \ R).card + (P ∩ R).card = P.card :=
      Finset.card_sdiff_add_card_inter P R
    omega
  have hcard2 : (R \ P).card = r₂ - g := by
    have hgc : (R ∩ P).card = g := by rw [Finset.inter_comm]; exact hcardG
    have e2 : (R \ P).card + (R ∩ P).card = R.card :=
      Finset.card_sdiff_add_card_inter R P
    omega
  -- assemble
  have hs1 : ∑ y ∈ P \ R, |D.p y - E.p y| = ((r₁ : ℝ) - g) * (1 / r₁) := by
    rw [Finset.sum_congr rfl hv1, Finset.sum_const, hcard1, nsmul_eq_mul,
      Nat.cast_sub hgle₁]
  have hs2 : ∑ y ∈ R \ P, |D.p y - E.p y| = ((r₂ : ℝ) - g) * (1 / r₂) := by
    rw [Finset.sum_congr rfl hv2, Finset.sum_const, hcard2, nsmul_eq_mul,
      Nat.cast_sub hgle₂]
  have hs3 : ∑ y ∈ P ∩ R, |D.p y - E.p y| = (g : ℝ) * (1 / r₁ - 1 / r₂) := by
    rw [Finset.sum_congr rfl hv3, Finset.sum_const, hcardG, nsmul_eq_mul]
  rw [tv, hreduce, hsplit1, hsplit2, hPR, hs1, hs2, hs3]
  field_simp
  ring

/-- **Any single sampler is far from one of two candidate outputs.**  By the
triangle inequality the exact distance splits: for orders `r₁ ≤ r₂` dividing `Q`,
every distribution `D` on the frequency window satisfies
`max(TV(D,P_{r₁}), TV(D,P_{r₂})) ≥ (1 - gcd(r₁,r₂)/r₂)/2`.  For coprime orders this
is `(1 - 1/r₂)/2`, the exact form of the `TV ≥ 0.5` figure. -/
theorem sampler_far_from_one_of_two (hr₁ : 0 < r₁) (hr₂ : 0 < r₂) (hQ : 0 < Q)
    (h1 : r₁ ∣ Q) (h2 : r₂ ∣ Q) (hle : r₁ ≤ r₂) (D : DistOn (Finset.range Q)) :
    (1 - (Nat.gcd r₁ r₂ : ℝ) / r₂) / 2
      ≤ max (tv D (combDist hr₁ hQ h1)) (tv D (combDist hr₂ hQ h2)) := by
  have htri := tv_triangle (combDist hr₁ hQ h1) D (combDist hr₂ hQ h2)
  rw [tv_comb_comb hr₁ hr₂ hQ h1 h2 hle] at htri
  have hc : tv (combDist hr₁ hQ h1) D = tv D (combDist hr₁ hQ h1) := tv_comm _ _
  rw [hc] at htri
  have h1' : tv D (combDist hr₁ hQ h1) ≤ max (tv D (combDist hr₁ hQ h1))
      (tv D (combDist hr₂ hQ h2)) := le_max_left _ _
  have h2' : tv D (combDist hr₂ hQ h2) ≤ max (tv D (combDist hr₁ hQ h1))
      (tv D (combDist hr₂ hQ h2)) := le_max_right _ _
  linarith

end Dequant