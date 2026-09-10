/-
# The optimal constant in the repair/discordance lower bound

`Bridges.ComonotoneRepairDistance` proved the dimension-free bound `g · δ ≤ Δ` and showed
that no constant above `2` can work (`no_lower_bound_constant_above_two`).  This file
closes the remaining factor: the sharp bound

  `2 · g · δ ≤ Δ`

holds, and it is attained (`optimal_constant_attained`), so `2` is *exactly* the optimal
constant.

The mechanism is a *disjoint double charging* argument.  The isotonic upper envelope
charges the repair cost of each key `b` to a discordant pair `(w b, b)` whose second
coordinate is `b`, so those pairs are pairwise distinct.  Because the discordance matrix is
symmetric, the transposed pairs `(b, w b)` carry the same mass; and the two families are
disjoint, since `(w b, b) = (b', w b')` would force `x b' < x b` and `x b < x b'`.  Summing
over both families therefore doubles the charge without double counting.
-/
import Bridges.ComonotoneRepairDistance

open Finset

namespace Catalog.UniformDial

variable {ι : Type*} [Fintype ι]

/-- The discordance matrix entry of an ordered pair of keys. -/
noncomputable def discPair (x y : ι → ℝ) (a b : ι) : ℝ :=
  max (-((x a - x b) * (y a - y b))) 0

omit [Fintype ι] in
lemma discPair_nonneg (x y : ι → ℝ) (a b : ι) : 0 ≤ discPair x y a b := le_max_right _ _

omit [Fintype ι] in
/-- The discordance matrix is symmetric. -/
lemma discPair_symm (x y : ι → ℝ) (a b : ι) : discPair x y a b = discPair x y b a := by
  simp only [discPair]
  congr 1
  ring

lemma discordanceMass_eq_sum_pairs (x y : ι → ℝ) :
    discordanceMass x y = ∑ p ∈ (univ ×ˢ univ : Finset (ι × ι)), discPair x y p.1 p.2 := by
  rw [Finset.sum_product]
  rfl

open Classical in
/-- A key at or below `b` in footprint whose rate realises the upper envelope at `b`. -/
noncomputable def envWitness (x y : ι → ℝ) (b : ι) : ι :=
  (Finset.exists_mem_eq_sup' (predSet_nonempty x b) y).choose

lemma envWitness_mem (x y : ι → ℝ) (b : ι) : envWitness x y b ∈ predSet x b := by
  classical
  exact (Finset.exists_mem_eq_sup' (predSet_nonempty x b) y).choose_spec.1

lemma isoUp_eq_envWitness (x y : ι → ℝ) (b : ι) : isoUp x y b = y (envWitness x y b) := by
  classical
  exact (Finset.exists_mem_eq_sup' (predSet_nonempty x b) y).choose_spec.2

/-- The repair cost the isotonic envelope spends at a key. -/
noncomputable def envCost (x y : ι → ℝ) (b : ι) : ℝ := isoUp x y b - y b

lemma envCost_nonneg (x y : ι → ℝ) (b : ι) : 0 ≤ envCost x y b :=
  sub_nonneg.mpr (le_isoUp x y b)

/-- Where the envelope actually spends something, its witness sits strictly lower in
footprint and strictly higher in rate: the pair is genuinely discordant. -/
lemma envWitness_lt {x y : ι → ℝ} {b : ι} (hb : 0 < envCost x y b) :
    x (envWitness x y b) < x b ∧ y b < y (envWitness x y b) := by
  have hval := isoUp_eq_envWitness x y b
  have hy : y b < y (envWitness x y b) := by
    have : 0 < isoUp x y b - y b := hb
    rw [hval] at this
    linarith
  refine ⟨?_, hy⟩
  rcases mem_predSet_iff.mp (envWitness_mem x y b) with heq | hlt
  · exfalso
    rw [heq] at hy
    exact lt_irrefl _ hy
  · exact hlt

/-- The charge of a key against its witness pair. -/
lemma gap_envCost_le_discPair {x y : ι → ℝ} {g : ℝ}
    (hgap : ∀ i j, x i < x j → g ≤ x j - x i) {b : ι} (hb : 0 < envCost x y b) :
    g * envCost x y b ≤ discPair x y (envWitness x y b) b := by
  obtain ⟨hx, hy⟩ := envWitness_lt hb
  have hgg : g ≤ x b - x (envWitness x y b) := hgap _ _ hx
  have hval : envCost x y b = y (envWitness x y b) - y b := by
    simp [envCost, isoUp_eq_envWitness x y b]
  have hpos : 0 < y (envWitness x y b) - y b := by linarith
  have hle : g * (y (envWitness x y b) - y b)
      ≤ -((x (envWitness x y b) - x b) * (y (envWitness x y b) - y b)) := by nlinarith
  rw [hval]
  exact hle.trans (le_max_left _ _)

/-- **The sharp dimension-free lower bound.**  For a `g`-separated footprint,
`2 · g · δ ≤ Δ`.  Each key charges its repair cost to a discordant pair with that key as
second coordinate, and the symmetric transposed pair carries the same mass; the two
families are disjoint, so the charge may be counted twice. -/
theorem two_gap_repairDist_le_discordanceMass {x y : ι → ℝ} {g : ℝ} (hg : 0 < g)
    (hgap : ∀ i j, x i < x j → g ≤ x j - x i) :
    2 * g * repairDist x y ≤ discordanceMass x y := by
  classical
  set w : ι → ι := envWitness x y with hw
  set B : Finset ι := univ.filter (fun b => 0 < envCost x y b) with hB
  -- the two families of charged pairs
  set P : Finset (ι × ι) := B.image (fun b => (w b, b)) with hP
  set Q : Finset (ι × ι) := B.image (fun b => (b, w b)) with hQ
  have hPinj : Set.InjOn (fun b => (w b, b)) B := fun a _ b _ hab => congrArg Prod.snd hab
  have hQinj : Set.InjOn (fun b => (b, w b)) B := fun a _ b _ hab => congrArg Prod.fst hab
  have hdisj : Disjoint P Q := by
    rw [Finset.disjoint_left]
    rintro p hp hq
    rw [hP, Finset.mem_image] at hp
    rw [hQ, Finset.mem_image] at hq
    obtain ⟨b, hbB, hbp⟩ := hp
    obtain ⟨c, hcB, hcp⟩ := hq
    have hb : 0 < envCost x y b := by
      rw [hB, Finset.mem_filter] at hbB; exact hbB.2
    have hc : 0 < envCost x y c := by
      rw [hB, Finset.mem_filter] at hcB; exact hcB.2
    have h1 : w b = c := by
      have := congrArg Prod.fst (hbp.trans hcp.symm); simpa using this
    have h2 : b = w c := by
      have := congrArg Prod.snd (hbp.trans hcp.symm); simpa using this
    have hxb : x (w b) < x b := (envWitness_lt hb).1
    have hxc : x (w c) < x c := (envWitness_lt hc).1
    rw [h1] at hxb
    rw [← h2] at hxc
    exact absurd hxb (not_lt.mpr hxc.le)
  -- the total mass dominates the mass of the charged pairs
  have hsub : P ∪ Q ⊆ (univ ×ˢ univ : Finset (ι × ι)) := fun p _ => Finset.mem_product.mpr
    ⟨mem_univ _, mem_univ _⟩
  have hmass : ∑ p ∈ P ∪ Q, discPair x y p.1 p.2 ≤ discordanceMass x y := by
    rw [discordanceMass_eq_sum_pairs]
    exact Finset.sum_le_sum_of_subset_of_nonneg hsub
      (fun p _ _ => discPair_nonneg x y p.1 p.2)
  have hsplit : ∑ p ∈ P ∪ Q, discPair x y p.1 p.2
      = (∑ p ∈ P, discPair x y p.1 p.2) + ∑ p ∈ Q, discPair x y p.1 p.2 :=
    Finset.sum_union hdisj
  have hPsum : ∑ p ∈ P, discPair x y p.1 p.2 = ∑ b ∈ B, discPair x y (w b) b := by
    rw [hP, Finset.sum_image (fun a ha b hb hab => hPinj ha hb hab)]
  have hQsum : ∑ p ∈ Q, discPair x y p.1 p.2 = ∑ b ∈ B, discPair x y (w b) b := by
    rw [hQ, Finset.sum_image (fun a ha b hb hab => hQinj ha hb hab)]
    exact Finset.sum_congr rfl fun b _ => discPair_symm x y b (w b)
  -- the charged pairs pay for the envelope repair
  have hcharge : g * ∑ b ∈ B, envCost x y b ≤ ∑ b ∈ B, discPair x y (w b) b := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun b hbB => ?_
    have hb : 0 < envCost x y b := by
      rw [hB, Finset.mem_filter] at hbB; exact hbB.2
    exact gap_envCost_le_discPair hgap hb
  have hBsum : ∑ b ∈ B, envCost x y b = ∑ b, envCost x y b := by
    refine Finset.sum_subset (f := fun b => envCost x y b) (Finset.subset_univ B) ?_
    intro b _ hbB
    have : ¬ 0 < envCost x y b := by
      rw [hB, Finset.mem_filter] at hbB
      exact fun h => hbB ⟨mem_univ b, h⟩
    have h0 := envCost_nonneg x y b
    linarith [not_lt.mp this]
  -- the envelope is an admissible repair
  have hmem : (fun i => envCost x y i) ∈ RepairSet x y := by
    intro i j
    have hi : y i + envCost x y i = isoUp x y i := by simp [envCost]
    have hj : y j + envCost x y j = isoUp x y j := by simp [envCost]
    show (0 : ℝ) ≤ (x i - x j) * ((y i + envCost x y i) - (y j + envCost x y j))
    rw [hi, hj]
    exact comonotone_isoUp x y i j
  have hl1 : l1norm (fun i => envCost x y i) = ∑ i, envCost x y i :=
    Finset.sum_congr rfl fun i _ => abs_of_nonneg (envCost_nonneg x y i)
  have hδ : repairDist x y ≤ ∑ i, envCost x y i := by
    rw [← hl1]; exact repairDist_le_of_mem hmem
  have hfinal : 2 * (g * ∑ b, envCost x y b) ≤ discordanceMass x y := by
    rw [← hBsum]
    linarith [hmass, hsplit, hPsum, hQsum, hcharge]
  have hscale : 2 * (g * repairDist x y) ≤ 2 * (g * ∑ i, envCost x y i) := by
    have := mul_le_mul_of_nonneg_left hδ hg.le
    linarith
  linarith

/-- **Sharp two-sided comparison.**  Combining the optimal lower constant with the upper
bound of `Bridges.ComonotoneRepairDistance`:
`2 g · δ ≤ Δ ≤ 2 |ι| R · δ`.  Both constants are attained: the left by `x = (0,1)`,
`y = (3,0)`, the right (up to a factor two) by the outlier family of
`Bridges.ComonotoneRepairSharpness`. -/
theorem repair_discordance_two_sided_sharp {x y : ι → ℝ} {g R : ℝ} (hg : 0 < g)
    (hgap : ∀ i j, x i < x j → g ≤ x j - x i) (hx : ∀ i j, |x i - x j| ≤ R) :
    2 * g * repairDist x y ≤ discordanceMass x y ∧
      discordanceMass x y ≤ 2 * (Fintype.card ι : ℝ) * R * repairDist x y :=
  ⟨two_gap_repairDist_le_discordanceMass hg hgap, discordanceMass_le_repairDist x y hx⟩

/-- **The constant `2` is exactly optimal.**  For `x = (0,1)`, `y = (3,0)` the footprint is
`1`-separated and `2 · g · δ = 6 = Δ`, so the inequality
`two_gap_repairDist_le_discordanceMass` is an equality; by
`no_lower_bound_constant_above_two` no larger constant is admissible. -/
theorem optimal_constant_attained :
    2 * (1 : ℝ) * repairDist vx vy = discordanceMass vx vy := by
  rw [repairDist_vx_vy, discordanceMass_vx_vy]
  norm_num

end Catalog.UniformDial