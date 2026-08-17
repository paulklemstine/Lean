import Mathlib

/-!
# Lattice-point enumerators: asymptotics and rigidity

This file formalises the analytic core of the theory of *lattice-point enumerators*
`L_P(t) = |tP ∩ ℤ^d|` (`t > 0` a **real** dilation parameter) for bounded sets
`P ⊆ ℝ^d`, in the setting of the paper *A Fourier-analytic uniqueness theorem for
lattice-point enumerators*.

## Main definitions

* `LatticeEnumerator.shiftLattice P t y` : the set `{k ∈ ℤ^d : k/t - y ∈ P}` of lattice
  points of the dilated translate `t·(P + y)`.
* `LatticeEnumerator.dilLattice P t` : the lattice points `tP ∩ ℤ^d` (the case `y = 0`).
* `LatticeEnumerator.dilCount P t` : the lattice-point enumerator `L_P(t) = |tP ∩ ℤ^d|`.
* `LatticeEnumerator.shiftCount P t y` : the translated enumerator `|t(P + y) ∩ ℤ^d|`.
* `LatticeEnumerator.cube t k`, `LatticeEnumerator.floorMap t`,
  `LatticeEnumerator.approxSet P t` : the half-open `1/t`-cube attached to a lattice point,
  the coordinatewise rounding map `x ↦ ⌊t x⌋ / t`, and the union of the cubes attached to
  the counted lattice points.

## Main results

* `LatticeEnumerator.volume_approxSet` : the *exact* geometric identity
  `vol(A_t) = L_P(t) · t^{-d}`, where `A_t = {x : ⌊tx⌋/t ∈ P}` is a union of `L_P(t)`
  pairwise disjoint cubes of side `1/t`.
* `LatticeEnumerator.tendsto_dilCount_div` : the Gauss–Weyl counting theorem
  `L_P(t)/t^d → vol(P)` as `t → ∞`, for every bounded set with null topological frontier
  (Jordan measurable set).  The proof combines the exact identity above with dominated
  convergence, the domination coming from the fact that all the sets `A_t`, `t ≥ 1`, live
  in one fixed ball.
* `LatticeEnumerator.volume_eq_of_dilCount_eq` : two bounded Jordan measurable sets with
  the same real-parameter enumerator have the same volume.
* `LatticeEnumerator.volume_eq_of_dilCount_eq_convex` : the same statement for convex
  bodies, where Jordan measurability is automatic.
* `LatticeEnumerator.eq_of_shiftCount_eq` : a rigidity theorem.  If the enumerators of
  **all real translates** of two bounded sets agree, the sets are *equal* (not merely equal
  almost everywhere).  This isolates exactly where the difficulty of the integer-translate
  theorem lies: with real translates the periodisation is faithful at small `t`.
-/

noncomputable section

open MeasureTheory Metric Set Filter Topology

namespace LatticeEnumerator

variable {d : ℕ}

/-! ## Definitions -/

/-- `shiftLattice P t y = {k ∈ ℤ^d : k/t - y ∈ P}`, i.e. the set of lattice points of the
dilated translate `t · (P + y)`. -/
def shiftLattice (P : Set (Fin d → ℝ)) (t : ℝ) (y : Fin d → ℝ) : Set (Fin d → ℤ) :=
  {k | (fun i => (k i : ℝ) / t - y i) ∈ P}

/-- `dilLattice P t = tP ∩ ℤ^d`, viewed inside `ℤ^d`. -/
def dilLattice (P : Set (Fin d → ℝ)) (t : ℝ) : Set (Fin d → ℤ) := shiftLattice P t 0

/-- The translated lattice-point enumerator `|t(P + y) ∩ ℤ^d|`. -/
def shiftCount (P : Set (Fin d → ℝ)) (t : ℝ) (y : Fin d → ℝ) : ℕ := (shiftLattice P t y).ncard

/-- The lattice-point enumerator `L_P(t) = |tP ∩ ℤ^d|`. -/
def dilCount (P : Set (Fin d → ℝ)) (t : ℝ) : ℕ := (dilLattice P t).ncard

/-- The half-open cube of side `1/t` with lower corner the lattice point `k/t`. -/
def cube (t : ℝ) (k : Fin d → ℤ) : Set (Fin d → ℝ) :=
  Set.univ.pi fun i => Set.Ico ((k i : ℝ) / t) (((k i : ℝ) + 1) / t)

/-- Coordinatewise rounding to the grid `(1/t)ℤ^d`. -/
def floorMap (t : ℝ) (x : Fin d → ℝ) : Fin d → ℝ := fun i => (⌊t * x i⌋ : ℝ) / t

/-- The set `A_t = {x : ⌊tx⌋/t ∈ P}`; it is the union of the `1/t`-cubes attached to the
lattice points counted by `L_P(t)`. -/
def approxSet (P : Set (Fin d → ℝ)) (t : ℝ) : Set (Fin d → ℝ) := {x | floorMap t x ∈ P}

@[simp] lemma mem_shiftLattice {P : Set (Fin d → ℝ)} {t : ℝ} {y : Fin d → ℝ} {k : Fin d → ℤ} :
    k ∈ shiftLattice P t y ↔ (fun i => (k i : ℝ) / t - y i) ∈ P := Iff.rfl

@[simp] lemma mem_dilLattice {P : Set (Fin d → ℝ)} {t : ℝ} {k : Fin d → ℤ} :
    k ∈ dilLattice P t ↔ (fun i => (k i : ℝ) / t) ∈ P := by
  simp [dilLattice, shiftLattice]

/-! ## Finiteness of the counted lattice sets -/

/-- In the sup-metric on `ℝ^d`, membership in a closed ball bounds every coordinate. -/
lemma abs_coord_le_of_mem_closedBall {R : ℝ} {z : Fin d → ℝ}
    (h : z ∈ closedBall (0 : Fin d → ℝ) R) (i : Fin d) : |z i| ≤ R := by
  simp only [mem_closedBall, dist_zero_right] at h
  have hi : ‖z i‖ ≤ ‖z‖ := norm_le_pi_norm z i
  rw [Real.norm_eq_abs] at hi
  linarith

/-- For a bounded set `P` and `t > 0` only finitely many lattice points are counted. -/
lemma shiftLattice_finite {P : Set (Fin d → ℝ)} (hP : Bornology.IsBounded P) {t : ℝ} (ht : 0 < t)
    (y : Fin d → ℝ) : (shiftLattice P t y).Finite := by
  obtain ⟨R, hR⟩ := (Metric.isBounded_iff_subset_closedBall 0).1 hP
  set B : ℝ := (R + ‖y‖) * t with hB
  have hsub : shiftLattice P t y ⊆
      (Set.univ.pi fun _ : Fin d => Set.Icc (⌈-B⌉) (⌊B⌋) : Set (Fin d → ℤ)) := by
    intro k hk i _
    have h1 : |(k i : ℝ) / t - y i| ≤ R := abs_coord_le_of_mem_closedBall (hR hk) i
    have h2 : |y i| ≤ ‖y‖ := by
      have := norm_le_pi_norm y i
      rwa [Real.norm_eq_abs] at this
    have h3 : |(k i : ℝ) / t| ≤ R + ‖y‖ := by
      calc |(k i : ℝ) / t| = |((k i : ℝ) / t - y i) + y i| := by ring_nf
        _ ≤ |(k i : ℝ) / t - y i| + |y i| := abs_add_le _ _
        _ ≤ R + ‖y‖ := add_le_add h1 h2
    have h4 : |(k i : ℝ)| ≤ B := by
      rw [hB, abs_div, abs_of_pos ht] at *
      calc |(k i : ℝ)| = |(k i : ℝ)| / t * t := by field_simp
        _ ≤ (R + ‖y‖) * t := mul_le_mul_of_nonneg_right h3 ht.le
    refine ⟨?_, ?_⟩
    · exact_mod_cast Int.ceil_le.2 (by exact_mod_cast neg_le_of_abs_le h4)
    · exact Int.le_floor.2 (by exact_mod_cast le_of_abs_le h4)
  exact Set.Finite.subset (Set.Finite.pi fun _ => Set.finite_Icc _ _) hsub

lemma dilLattice_finite {P : Set (Fin d → ℝ)} (hP : Bornology.IsBounded P) {t : ℝ} (ht : 0 < t) :
    (dilLattice P t).Finite := shiftLattice_finite hP ht 0

/-! ## The cube decomposition -/

lemma mem_cube {t : ℝ} (ht : 0 < t) {k : Fin d → ℤ} {x : Fin d → ℝ} :
    x ∈ cube t k ↔ ∀ i, ⌊t * x i⌋ = k i := by
  simp only [cube, Set.mem_pi, Set.mem_univ, forall_true_left, Set.mem_Ico]
  refine forall_congr' fun i => ?_
  rw [Int.floor_eq_iff, div_le_iff₀ ht, lt_div_iff₀ ht]
  constructor
  · rintro ⟨h1, h2⟩; exact ⟨by linarith, by linarith⟩
  · rintro ⟨h1, h2⟩; exact ⟨by linarith, by linarith⟩

lemma measurableSet_cube (t : ℝ) (k : Fin d → ℤ) : MeasurableSet (cube t k) :=
  MeasurableSet.univ_pi fun _ => measurableSet_Ico

lemma volume_cube {t : ℝ} (ht : 0 < t) (k : Fin d → ℤ) :
    volume (cube t k) = (ENNReal.ofReal (1 / t)) ^ d := by
  have h : ∀ i : Fin d, ((k i : ℝ) + 1) / t - (k i : ℝ) / t = 1 / t := by
    intro i; field_simp; ring
  rw [cube, volume_pi_pi]
  simp only [Real.volume_Ico, h, Finset.prod_const, Finset.card_univ, Fintype.card_fin]

/-- Distinct lattice points give disjoint cubes. -/
lemma pairwiseDisjoint_cube {t : ℝ} (ht : 0 < t) (S : Set (Fin d → ℤ)) :
    S.PairwiseDisjoint (cube t) := by
  intro k _ l _ hkl
  apply Set.disjoint_left.2
  intro x hx hx'
  exact hkl (funext fun i => ((mem_cube ht).1 hx i).symm.trans ((mem_cube ht).1 hx' i))

/-- `A_t` is the union of the cubes attached to the counted lattice points. -/
lemma approxSet_eq_iUnion (P : Set (Fin d → ℝ)) {t : ℝ} (ht : 0 < t) :
    approxSet P t = ⋃ k ∈ dilLattice P t, cube t k := by
  ext x
  simp only [approxSet, Set.mem_setOf_eq, Set.mem_iUnion, mem_dilLattice, exists_prop]
  constructor
  · intro hx
    exact ⟨fun i => ⌊t * x i⌋, hx, (mem_cube ht).2 fun i => rfl⟩
  · rintro ⟨k, hk, hxk⟩
    have hfl : floorMap t x = fun i => (k i : ℝ) / t := by
      funext i; simp [floorMap, (mem_cube ht).1 hxk i]
    rw [hfl]; exact hk

lemma measurableSet_approxSet {P : Set (Fin d → ℝ)} (hP : Bornology.IsBounded P) {t : ℝ}
    (ht : 0 < t) : MeasurableSet (approxSet P t) := by
  rw [approxSet_eq_iUnion P ht]
  exact (dilLattice_finite hP ht).measurableSet_biUnion fun k _ => measurableSet_cube t k

/-- **Exact geometric identity**: the volume of `A_t` is `L_P(t)` times the volume `t^{-d}`
of a single cube. -/
lemma volume_approxSet {P : Set (Fin d → ℝ)} (hP : Bornology.IsBounded P) {t : ℝ} (ht : 0 < t) :
    volume (approxSet P t) = dilCount P t • (ENNReal.ofReal (1 / t)) ^ d := by
  have hfin := dilLattice_finite hP ht
  have hU : approxSet P t = ⋃ k ∈ hfin.toFinset, cube t k := by
    rw [approxSet_eq_iUnion P ht]; simp [hfin.mem_toFinset]
  rw [hU, measure_biUnion_finset
      (pairwiseDisjoint_cube ht (↑hfin.toFinset : Set (Fin d → ℤ)))
      (fun k _ => measurableSet_cube t k),
    Finset.sum_congr rfl (fun k _ => volume_cube ht k), Finset.sum_const, dilCount,
    Set.ncard_eq_toFinset_card _ hfin]

/-- The real-valued form of the identity: `vol(A_t) = L_P(t)/t^d`. -/
lemma toReal_volume_approxSet {P : Set (Fin d → ℝ)} (hP : Bornology.IsBounded P) {t : ℝ}
    (ht : 0 < t) : (volume (approxSet P t)).toReal = (dilCount P t : ℝ) / t ^ d := by
  rw [volume_approxSet hP ht, nsmul_eq_mul, ENNReal.toReal_mul, ENNReal.toReal_pow,
    ENNReal.toReal_ofReal (by positivity), ENNReal.toReal_natCast, div_pow, one_pow]
  ring

/-! ## The rounding map and pointwise convergence -/

lemma dist_floorMap_le {t : ℝ} (ht : 0 < t) (x : Fin d → ℝ) : dist (floorMap t x) x ≤ 1 / t := by
  refine (dist_pi_le_iff (by positivity)).2 fun i => ?_
  have h1 : (⌊t * x i⌋ : ℝ) ≤ t * x i := Int.floor_le _
  have h2 : t * x i - 1 < (⌊t * x i⌋ : ℝ) := Int.sub_one_lt_floor _
  have hrw : (⌊t * x i⌋ : ℝ) / t - x i = ((⌊t * x i⌋ : ℝ) - t * x i) / t := by
    field_simp
  rw [Real.dist_eq, floorMap, hrw, abs_div, abs_of_pos ht]
  gcongr
  rw [abs_le]
  constructor <;> linarith

/-- Off the frontier of `P`, membership in `A_t` eventually agrees with membership in `P`. -/
lemma eventually_mem_approxSet_iff {P : Set (Fin d → ℝ)} {x : Fin d → ℝ} (hx : x ∉ frontier P) :
    ∀ᶠ t : ℝ in atTop, (x ∈ approxSet P t ↔ x ∈ P) := by
  rcases (em (x ∈ closure P)) with hcl | hcl
  · -- `x` is an interior point
    have hint : x ∈ interior P := by
      by_contra hni
      exact hx ⟨hcl, hni⟩
    obtain ⟨ε, hε, hball⟩ := Metric.isOpen_iff.1 isOpen_interior x hint
    filter_upwards [eventually_gt_atTop (max 1 (1 / ε))] with t ht
    have ht0 : 0 < t := lt_of_le_of_lt (le_max_left 1 (1 / ε)) ht |>.trans_le' zero_le_one
    have hlt : 1 / t < ε := by
      have h1 : 1 / ε < t := lt_of_le_of_lt (le_max_right 1 (1 / ε)) ht
      rw [div_lt_iff₀ ht0]
      rw [div_lt_iff₀ hε] at h1
      linarith
    have : floorMap t x ∈ P :=
      interior_subset (hball (by
        rw [mem_ball]
        exact lt_of_le_of_lt (dist_floorMap_le ht0 x) hlt))
    simp [approxSet, this, interior_subset hint]
  · -- `x` lies in the exterior
    have hopen : IsOpen (closure P)ᶜ := isClosed_closure.isOpen_compl
    obtain ⟨ε, hε, hball⟩ := Metric.isOpen_iff.1 hopen x hcl
    filter_upwards [eventually_gt_atTop (max 1 (1 / ε))] with t ht
    have ht0 : 0 < t := lt_of_le_of_lt (le_max_left 1 (1 / ε)) ht |>.trans_le' zero_le_one
    have hlt : 1 / t < ε := by
      have h1 : 1 / ε < t := lt_of_le_of_lt (le_max_right 1 (1 / ε)) ht
      rw [div_lt_iff₀ ht0]
      rw [div_lt_iff₀ hε] at h1
      linarith
    have hnot : floorMap t x ∉ P := by
      intro hmem
      exact hball (by
        rw [mem_ball]
        exact lt_of_le_of_lt (dist_floorMap_le ht0 x) hlt) (subset_closure hmem)
    have hxP : x ∉ P := fun h => hcl (subset_closure h)
    simp [approxSet, hnot, hxP]

/-- The sets `A_t`, `t ≥ 1`, are all contained in a fixed ball. -/
lemma approxSet_subset_closedBall {P : Set (Fin d → ℝ)} {R : ℝ}
    (hR : P ⊆ closedBall 0 R) {t : ℝ} (ht : 1 ≤ t) :
    approxSet P t ⊆ closedBall (0 : Fin d → ℝ) (R + 1) := by
  intro x hx
  have ht0 : (0 : ℝ) < t := lt_of_lt_of_le zero_lt_one ht
  have h1 : dist (floorMap t x) 0 ≤ R := by simpa using hR hx
  have h2 : dist x (floorMap t x) ≤ 1 := by
    rw [dist_comm]
    refine (dist_floorMap_le ht0 x).trans ?_
    rw [div_le_one ht0]; exact ht
  have := dist_triangle x (floorMap t x) 0
  simp only [mem_closedBall]
  linarith

/-! ## The Gauss–Weyl counting theorem -/

/-- **Gauss–Weyl counting theorem.**  For a bounded, null-measurable set `P ⊆ ℝ^d` whose
topological frontier is Lebesgue-null (a Jordan measurable set), the real-parameter
lattice-point enumerator satisfies `L_P(t)/t^d → vol(P)` as `t → ∞`. -/
theorem tendsto_dilCount_div {P : Set (Fin d → ℝ)} (hb : Bornology.IsBounded P)
    (hm : NullMeasurableSet P volume) (hfr : volume (frontier P) = 0) :
    Tendsto (fun t : ℝ => (dilCount P t : ℝ) / t ^ d) atTop (𝓝 (volume P).toReal) := by
  obtain ⟨R, hR⟩ := (Metric.isBounded_iff_subset_closedBall 0).1 hb
  set bound : (Fin d → ℝ) → ℝ :=
    (closedBall (0 : Fin d → ℝ) (R + 1)).indicator (fun _ => (1 : ℝ)) with hbound
  have hintP : ∫ x, P.indicator (fun _ => (1 : ℝ)) x = (volume P).toReal := by
    obtain ⟨u, hu, hsu⟩ := hm
    rw [integral_congr_ae (indicator_ae_eq_of_ae_eq_set hsu), integral_indicator_const _ hu,
      measure_congr hsu]
    simp [measureReal_def]
  have key : Tendsto (fun t : ℝ => ∫ x, (approxSet P t).indicator (fun _ => (1 : ℝ)) x) atTop
      (𝓝 ((volume P).toReal)) := by
    rw [← hintP]
    refine tendsto_integral_filter_of_dominated_convergence bound ?_ ?_ ?_ ?_
    · filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
      exact (measurable_const.indicator (measurableSet_approxSet hb ht)).aestronglyMeasurable
    · filter_upwards [eventually_ge_atTop (1 : ℝ)] with t ht
      filter_upwards with x
      have hsub := approxSet_subset_closedBall hR ht
      by_cases hx : x ∈ approxSet P t
      · rw [Set.indicator_of_mem hx, hbound, Set.indicator_of_mem (hsub hx)]
        simp
      · rw [Set.indicator_of_notMem hx]
        simp only [norm_zero, hbound]
        exact Set.indicator_nonneg (by intro _ _; norm_num) x
    · rw [hbound, integrable_indicator_iff measurableSet_closedBall]
      exact integrableOn_const measure_closedBall_lt_top.ne
    · have hae : ∀ᵐ x : (Fin d → ℝ), x ∉ frontier P :=
        measure_eq_zero_iff_ae_notMem.1 hfr
      filter_upwards [hae] with x hx
      have hev := eventually_mem_approxSet_iff (P := P) hx
      refine Tendsto.congr' ?_ tendsto_const_nhds
      filter_upwards [hev] with t ht
      by_cases hxP : x ∈ P
      · rw [Set.indicator_of_mem hxP, Set.indicator_of_mem (ht.2 hxP)]
      · rw [Set.indicator_of_notMem hxP, Set.indicator_of_notMem (fun h => hxP (ht.1 h))]
  refine key.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
  rw [integral_indicator_const _ (measurableSet_approxSet hb ht), measureReal_def, smul_eq_mul,
    mul_one, toReal_volume_approxSet hb ht]

/-- Two bounded Jordan measurable sets with the same real-parameter lattice-point
enumerator have the same volume. -/
theorem volume_eq_of_dilCount_eq {P Q : Set (Fin d → ℝ)} (hbP : Bornology.IsBounded P)
    (hmP : NullMeasurableSet P volume) (hfrP : volume (frontier P) = 0)
    (hbQ : Bornology.IsBounded Q) (hmQ : NullMeasurableSet Q volume)
    (hfrQ : volume (frontier Q) = 0) (h : ∀ t : ℝ, 0 < t → dilCount P t = dilCount Q t) :
    volume P = volume Q := by
  have hP := tendsto_dilCount_div hbP hmP hfrP
  have hQ := tendsto_dilCount_div hbQ hmQ hfrQ
  have hPQ : Tendsto (fun t : ℝ => (dilCount P t : ℝ) / t ^ d) atTop (𝓝 (volume Q).toReal) := by
    refine hQ.congr' ?_
    filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
    rw [h t ht]
  have hreal : (volume P).toReal = (volume Q).toReal := tendsto_nhds_unique hP hPQ
  have hfinP : volume P ≠ ⊤ := hbP.measure_lt_top.ne
  have hfinQ : volume Q ≠ ⊤ := hbQ.measure_lt_top.ne
  exact (ENNReal.toReal_eq_toReal_iff' hfinP hfinQ).1 hreal

/-- **Convex bodies are volume-determined by their real-parameter enumerator.**
For convex bounded sets Jordan measurability is automatic. -/
theorem volume_eq_of_dilCount_eq_convex {P Q : Set (Fin d → ℝ)} (hcP : Convex ℝ P)
    (hcQ : Convex ℝ Q) (hbP : Bornology.IsBounded P) (hbQ : Bornology.IsBounded Q)
    (h : ∀ t : ℝ, 0 < t → dilCount P t = dilCount Q t) : volume P = volume Q :=
  volume_eq_of_dilCount_eq hbP (hcP.nullMeasurableSet volume) (hcP.addHaar_frontier volume)
    hbQ (hcQ.nullMeasurableSet volume) (hcQ.addHaar_frontier volume) h

/-! ## Rigidity for real translates -/

/-- If the enumerators of all real translates of `P` dominate those of `Q` (here: agree),
then `P ⊆ Q`.  The mechanism: for `t` small the periodisation `y ↦ |t(P+y) ∩ ℤ^d|` sees a
single lattice point, so it is the indicator of `P` up to a reflection. -/
lemma subset_of_shiftCount_eq {P Q : Set (Fin d → ℝ)} (hbP : Bornology.IsBounded P)
    (hbQ : Bornology.IsBounded Q)
    (h : ∀ t : ℝ, 0 < t → ∀ y : Fin d → ℝ, shiftCount P t y = shiftCount Q t y) : P ⊆ Q := by
  obtain ⟨R₁, hR₁⟩ := (Metric.isBounded_iff_subset_closedBall 0).1 hbP
  obtain ⟨R₂, hR₂⟩ := (Metric.isBounded_iff_subset_closedBall 0).1 hbQ
  set R : ℝ := max (max R₁ R₂) 0 with hRdef
  have hR0 : 0 ≤ R := le_max_right _ _
  have hPR : P ⊆ closedBall 0 R := hR₁.trans (closedBall_subset_closedBall
    (le_trans (le_max_left R₁ R₂) (le_max_left _ _)))
  have hQR : Q ⊆ closedBall 0 R := hR₂.trans (closedBall_subset_closedBall
    (le_trans (le_max_right R₁ R₂) (le_max_left _ _)))
  intro x hx
  set t : ℝ := 1 / (2 * R + 1) with htdef
  have hden : (0 : ℝ) < 2 * R + 1 := by linarith
  have ht : 0 < t := by rw [htdef]; positivity
  have hinv : (1 : ℝ) / t = 2 * R + 1 := by rw [htdef]; field_simp
  -- the origin is counted for `P` at the translate `y = -x`
  have h0 : (0 : Fin d → ℤ) ∈ shiftLattice P t (-x) := by
    have : (fun i => ((0 : Fin d → ℤ) i : ℝ) / t - (-x) i) = x := by
      funext i; simp
    rw [mem_shiftLattice, this]; exact hx
  have hfinQ := shiftLattice_finite hbQ ht (-x)
  have hposP : 0 < shiftCount P t (-x) := by
    rw [shiftCount, Set.ncard_pos (shiftLattice_finite hbP ht (-x))]
    exact ⟨0, h0⟩
  have hposQ : 0 < shiftCount Q t (-x) := by rw [← h t ht (-x)]; exact hposP
  obtain ⟨k, hk⟩ : (shiftLattice Q t (-x)).Nonempty := by
    rw [← Set.ncard_pos hfinQ]; exact hposQ
  -- the counted lattice point must be the origin, because `1/t > 2R`
  have hk0 : k = 0 := by
    funext i
    have hmem : (fun i => (k i : ℝ) / t + x i) ∈ Q := by
      have : (fun i => (k i : ℝ) / t - (-x) i) = fun i => (k i : ℝ) / t + x i := by
        funext j; simp [sub_neg_eq_add]
      rw [mem_shiftLattice] at hk
      rwa [this] at hk
    have hQb : |(k i : ℝ) / t + x i| ≤ R := abs_coord_le_of_mem_closedBall (hQR hmem) i
    have hxb : |x i| ≤ R := abs_coord_le_of_mem_closedBall (hPR hx) i
    have hkb : |(k i : ℝ) / t| ≤ 2 * R := by
      obtain ⟨hQ1, hQ2⟩ := abs_le.1 hQb
      obtain ⟨hx1, hx2⟩ := abs_le.1 hxb
      rw [abs_le]
      constructor <;> linarith
    have hexp : |(k i : ℝ)| * (2 * R + 1) ≤ 2 * R := by
      have : |(k i : ℝ) / t| = |(k i : ℝ)| * (2 * R + 1) := by
        rw [abs_div, abs_of_pos ht, ← hinv]
        field_simp
      linarith [this ▸ hkb]
    have hlt : |(k i : ℝ)| < 1 := by nlinarith [abs_nonneg ((k i : ℝ))]
    have : |k i| < 1 := by exact_mod_cast hlt
    simpa using Int.abs_lt_one_iff.1 this
  rw [hk0] at hk
  simpa using hk

/-- **Rigidity theorem for real translates.**  If two bounded sets have the same
lattice-point enumerators for *all real translates* and all real dilation parameters, they
are equal as sets (no measurability or regularity assumption is needed, and the conclusion
is genuine set equality, not merely a.e. equality). -/
theorem eq_of_shiftCount_eq {P Q : Set (Fin d → ℝ)} (hbP : Bornology.IsBounded P)
    (hbQ : Bornology.IsBounded Q)
    (h : ∀ t : ℝ, 0 < t → ∀ y : Fin d → ℝ, shiftCount P t y = shiftCount Q t y) : P = Q :=
  Set.Subset.antisymm (subset_of_shiftCount_eq hbP hbQ h)
    (subset_of_shiftCount_eq hbQ hbP fun t ht y => (h t ht y).symm)

end LatticeEnumerator