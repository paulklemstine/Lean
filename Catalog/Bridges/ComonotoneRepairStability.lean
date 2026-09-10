/-
# Stability and attainment of the comonotone repair distance

Third instalment of the repair-distance thread (`Bridges.ComonotoneRepairDistance`,
`Bridges.ComonotoneRepairSharpness`).  Two structural properties are established that the
discordance mass provably does *not* share.

## 1.  The repair distance is `1`-Lipschitz in the rates

`repairDist_lipschitz`: `|δ(x, y) - δ(x, y')| ≤ ‖y - y'‖₁`.  Translating a repair of one
rate vector into a repair of another costs at most the ℓ¹ distance between them, so the
repair distance is a *robust* statistic: a measurement error of ℓ¹ size `η` moves it by at
most `η`.  `dial_pos_of_measured_repair_distance` turns this into a triage rule that is
valid for the true population when only a nearby rate vector has been measured.

`discordanceMass_not_lipschitz` shows the discordance mass has no such property — it is a
*quadratic* functional of the population and its sensitivity grows without bound.  So the
repair distance is not merely a coarser summary of `Δ`; it is the stable part of it.

## 2.  The infimum is attained

`repairDist_attained`: there is an optimal repair.  The repair set is closed (it is an
intersection of closed pairwise conditions), and intersecting it with the ℓ¹ ball of
radius `‖x - y‖₁` — which is nonempty, since `x - y` is always admissible — gives a
compact set on which the continuous ℓ¹ norm attains its minimum.  Hence `repairDist` is a
genuine ℓ¹ isotonic-projection distance, not merely an infimum, and the certificates of
the previous files are realised by actual perturbations.
-/
import Bridges.ComonotoneRepairDistance

open Finset

namespace Catalog.UniformDial

variable {ι : Type*} [Fintype ι]

/-! ### ℓ¹ stability -/

omit [Fintype ι] in
/-- Every repair of one rate vector becomes a repair of a nearby one, at the cost of their
ℓ¹ distance. -/
lemma mem_RepairSet_translate {x y y' d : ι → ℝ} (hd : d ∈ RepairSet x y') :
    (fun i => d i + (y' i - y i)) ∈ RepairSet x y := by
  intro i j
  have hcom := hd i j
  have h : (x i - x j) * ((y i + (d i + (y' i - y i))) - (y j + (d j + (y' j - y j))))
      = (x i - x j) * ((y' i + d i) - (y' j + d j)) := by ring
  rw [h]
  exact hcom

lemma l1norm_add_le (d e : ι → ℝ) : l1norm (fun i => d i + e i) ≤ l1norm d + l1norm e := by
  simp only [l1norm, ← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun i _ => abs_add_le _ _

/-- **One-sided stability.**  Repairing `y` costs no more than repairing `y'` plus the ℓ¹
distance between the two rate vectors. -/
theorem repairDist_le_add_l1 (x y y' : ι → ℝ) :
    repairDist x y ≤ repairDist x y' + l1norm (fun i => y i - y' i) := by
  have key : ∀ d ∈ RepairSet x y',
      repairDist x y - l1norm (fun i => y i - y' i) ≤ l1norm d := by
    intro d hd
    have hmem := mem_RepairSet_translate (y := y) hd
    have h1 := repairDist_le_of_mem hmem
    have h2 : l1norm (fun i => d i + (y' i - y i)) ≤ l1norm d + l1norm (fun i => y i - y' i) := by
      refine (l1norm_add_le d (fun i => y' i - y i)).trans ?_
      have : l1norm (fun i => y' i - y i) = l1norm (fun i => y i - y' i) := by
        simp only [l1norm]
        exact Finset.sum_congr rfl fun i _ => abs_sub_comm _ _
      rw [this]
    linarith
  have := le_repairDist key
  linarith

/-- **The repair distance is `1`-Lipschitz in the rates.**  In particular it is a robust
population statistic: measurement error of ℓ¹ size `η` perturbs it by at most `η`. -/
theorem repairDist_lipschitz (x y y' : ι → ℝ) :
    |repairDist x y - repairDist x y'| ≤ l1norm (fun i => y i - y' i) := by
  have h1 := repairDist_le_add_l1 x y y'
  have h2 := repairDist_le_add_l1 x y' y
  have hsymm : l1norm (fun i => y' i - y i) = l1norm (fun i => y i - y' i) := by
    simp only [l1norm]
    exact Finset.sum_congr rfl fun i _ => abs_sub_comm _ _
  rw [hsymm] at h2
  rw [abs_le]
  constructor <;> linarith

/-- **The discordance mass is not Lipschitz.**  Comparing `y = (3,0)` with the constant
rate vector shows the discordance mass moves by twice the ℓ¹ displacement; by homogeneity
the ratio is unbounded, so no ℓ¹-Lipschitz estimate can hold for `Δ`.  The repair distance
is therefore the stable part of the discordance information. -/
theorem discordanceMass_not_lipschitz :
    ¬ ∀ (n : ℕ) (x y y' : Fin n → ℝ),
        |discordanceMass x y - discordanceMass x y'| ≤ l1norm (fun i => y i - y' i) := by
  intro h
  have hz : discordanceMass vx (fun _ => (0 : ℝ)) = 0 := by
    simp [discordanceMass]
  have hd : l1norm (fun i => vy i - (0 : ℝ)) = 3 := by
    simp [l1norm, Fin.sum_univ_two, vy]
  have := h 2 vx vy (fun _ => 0)
  rw [hz, hd, discordanceMass_vx_vy] at this
  norm_num at this

/-- **Robust triage.**  If the rates have been measured up to ℓ¹ error `η`, the dial is
still certified positive in every regime with per-key mass in `[ε, M]`, provided the
measured repair distance leaves room for the error. -/
theorem dial_pos_of_measured_repair_distance {p x y y' : ι → ℝ} {ε M R η : ℝ}
    (hp : ∑ i, p i = 1) (hε : 0 < ε) (hlo : ∀ i, ε ≤ p i) (hhi : ∀ i, p i ≤ M)
    (hx : ∀ i j, |x i - x j| ≤ R) (herr : l1norm (fun i => y i - y' i) ≤ η)
    (htriage : M ^ 2 * (2 * (Fintype.card ι : ℝ) * R * (repairDist x y' + η))
      < ε ^ 2 * concordanceMass x y) :
    0 < wcov p x y := by
  rcases isEmpty_or_nonempty ι with hι | hι
  · exfalso
    have hcard : (Fintype.card ι : ℝ) = 0 := by simp [Fintype.card_eq_zero]
    have hC : concordanceMass x y = 0 := by simp [concordanceMass, Finset.univ_eq_empty]
    rw [hcard, hC] at htriage
    simp at htriage
  · obtain ⟨i0⟩ := hι
    have hR : 0 ≤ R := by simpa using hx i0 i0
    have hδ : repairDist x y ≤ repairDist x y' + η := by
      have := repairDist_le_add_l1 x y y'
      linarith
    refine dial_pos_of_repair_distance hp hε hlo hhi hx ?_
    have hcoef : (0 : ℝ) ≤ 2 * (Fintype.card ι : ℝ) * R := by positivity
    have hM : (0 : ℝ) ≤ M ^ 2 := sq_nonneg M
    have hstep : M ^ 2 * (2 * (Fintype.card ι : ℝ) * R * repairDist x y)
        ≤ M ^ 2 * (2 * (Fintype.card ι : ℝ) * R * (repairDist x y' + η)) :=
      mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hδ hcoef) hM
    linarith

/-! ### The infimum is attained -/

omit [Fintype ι] in
lemma isClosed_RepairSet (x y : ι → ℝ) : IsClosed (RepairSet x y) := by
  have hrw : RepairSet x y = ⋂ (i : ι), ⋂ (j : ι),
      {d : ι → ℝ | 0 ≤ (x i - x j) * ((y i + d i) - (y j + d j))} := by
    ext d
    simp [RepairSet, Comonotone, Set.mem_iInter]
  rw [hrw]
  exact isClosed_iInter fun i => isClosed_iInter fun j =>
    isClosed_le continuous_const (by fun_prop)

lemma continuous_l1norm : Continuous (l1norm : (ι → ℝ) → ℝ) := by
  unfold l1norm
  fun_prop

lemma abs_le_l1norm (d : ι → ℝ) (i : ι) : |d i| ≤ l1norm d :=
  Finset.single_le_sum (f := fun k => |d k|) (fun _ _ => abs_nonneg _) (mem_univ i)

/-- **The repair distance is attained.**  There is an optimal perturbation: the infimum
defining `repairDist` is a minimum, so `repairDist` is a genuine ℓ¹ distance from the rate
vector to the isotonic cone determined by the footprint. -/
theorem repairDist_attained (x y : ι → ℝ) :
    ∃ d ∈ RepairSet x y, l1norm d = repairDist x y := by
  classical
  set B : ℝ := l1norm (fun i => x i - y i) with hB
  have hB0 : 0 ≤ B := l1norm_nonneg _
  set K : Set (ι → ℝ) := RepairSet x y ∩ {d | l1norm d ≤ B} with hKdef
  have hKne : K.Nonempty := ⟨fun i => x i - y i, ⟨sub_mem_RepairSet x y, hB.ge⟩⟩
  have hKclosed : IsClosed K :=
    (isClosed_RepairSet x y).inter (isClosed_le continuous_l1norm continuous_const)
  have hKbdd : ∀ d ∈ K, ∀ i, |d i| ≤ B := fun d hd i => (abs_le_l1norm d i).trans hd.2
  have hKcompact : IsCompact K := by
    refine Metric.isCompact_of_isClosed_isBounded hKclosed ?_
    rw [Metric.isBounded_iff_subset_closedBall 0]
    refine ⟨B, fun d hd => ?_⟩
    simp only [Metric.mem_closedBall, dist_zero_right]
    refine (pi_norm_le_iff_of_nonneg hB0).mpr fun i => ?_
    simpa [Real.norm_eq_abs] using hKbdd d hd i
  obtain ⟨d0, hd0, hmin⟩ :=
    hKcompact.exists_isMinOn hKne continuous_l1norm.continuousOn
  refine ⟨d0, hd0.1, le_antisymm ?_ (repairDist_le_of_mem hd0.1)⟩
  refine le_repairDist ?_
  intro d hd
  rcases le_or_gt (l1norm d) B with hle | hgt
  · exact hmin ⟨hd, hle⟩
  · exact le_trans hd0.2 hgt.le

end Catalog.UniformDial