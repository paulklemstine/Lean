import Pythagorean.HigherPythKernel

/-!
# The kernel spectrum in arbitrary dimension: the hypotenuse-merged part is exactly `k + 1`

`Pythagorean.HigherPythKernel` computes the spectrum of `x² + y² + z² = w²` by hand.  This
file extracts the part of that computation that works in **every** dimension.

Fix `k` legs and consider `∑_{i<k} xᵢ² = y²`, packaged as tuples `t : Fin (k+1) → ℕ` with
the hypotenuse in the last coordinate.  Call a realised pattern *hypotenuse-merged* if the
hypotenuse shares its block with some leg.

Main results.

* `HigherPythGen.constant_legs_ne_hyp_iff` — the pattern "all legs equal, hypotenuse apart"
  is realised **iff** `k` is a perfect square and `k ≠ 1`.  This subsumes
  `PythagoreanKernel.constant_legs_dim_two_three_four` (`k = 2, 3` blocked, `k = 4`
  realised) and `HigherPyth.blocked_0003`, and predicts the answer in every dimension.
* `HigherPythGen.hyp_merged_dichotomy` — a solution whose hypotenuse meets a leg is either
  identically zero or "one hot": one leg equals the hypotenuse and all other legs vanish.
* `HigherPythGen.mergedPart_eq` and `HigherPythGen.card_mergedPart` — consequently, for
  `k ≥ 2` there are **exactly `k + 1`** hypotenuse-merged patterns, namely the all-equal
  pattern and one pattern for each leg; in particular `k + 1 ≤ (coneSpectrum k).card`.
  For `k = 2` this gives `3` of the `4` realised patterns and for `k = 3` it gives `4` of
  the `8`.
-/

open KernelPattern PythagoreanKernel HigherPyth

namespace HigherPythGen

/-! ## Solutions of the `k`-dimensional cone -/

/-- `∑_{i<k} xᵢ² = y²`, with the legs in the first `k` coordinates and the hypotenuse in the
last one. -/
def IsConeSol (k : ℕ) (t : Fin (k + 1) → ℕ) : Prop :=
  (∑ i : Fin k, t i.castSucc ^ 2) = t (Fin.last k) ^ 2

/-! ## The all-legs-equal pattern in every dimension -/

/-- **Constant legs, in every dimension.**  A solution with all legs equal to a nonzero
value and a hypotenuse *different* from that value exists iff `k` is a perfect square other
than `1`. -/
theorem constant_legs_ne_hyp_iff (k : ℕ) :
    (∃ a y : ℕ, a ≠ 0 ∧ a ≠ y ∧ (∑ _i : Fin k, a ^ 2) = y ^ 2) ↔ IsSquare k ∧ k ≠ 1 := by
  have hsum : ∀ a : ℕ, (∑ _i : Fin k, a ^ 2) = k * a ^ 2 := by
    intro a; simp [Finset.sum_const]
  have hmain := ConicKernel.mul_sq_eq_mul_sq_ne_iff (P := k) (Q := 1) one_ne_zero
  rw [mul_one] at hmain
  rw [← hmain]
  constructor
  · rintro ⟨a, y, ha, hay, h⟩
    exact ⟨a, y, ha, hay, by rw [← hsum a, h, one_mul]⟩
  · rintro ⟨u, v, hu, huv, h⟩
    exact ⟨u, v, hu, huv, by rw [hsum u, h, one_mul]⟩

/-- Dimension `2`: blocked (`2` is not a square). -/
theorem constant_legs_blocked_two : ¬ (IsSquare 2 ∧ (2 : ℕ) ≠ 1) := fun h => not_isSquare_two h.1

/-- Dimension `3`: blocked (`3` is not a square). -/
theorem constant_legs_blocked_three : ¬ (IsSquare 3 ∧ (3 : ℕ) ≠ 1) := fun h =>
  not_isSquare_three h.1

/-- Dimension `4`: realised, `1²+1²+1²+1² = 2²`. -/
theorem constant_legs_realised_four : IsSquare 4 ∧ (4 : ℕ) ≠ 1 := ⟨⟨2, by norm_num⟩, by norm_num⟩

/-- Dimension `1`: `k = 1` is a square, but the degeneracy clause blocks the pattern —
`x² = y²` forces `x = y`. -/
theorem constant_legs_blocked_one : ¬ (IsSquare 1 ∧ (1 : ℕ) ≠ 1) := fun h => h.2 rfl

/-! ## Hypotenuse-merged solutions are "one hot" -/

/-- If the hypotenuse equals the `j`-th leg then every other leg vanishes. -/
theorem legs_zero_of_hyp_merged {k : ℕ} {t : Fin (k + 1) → ℕ} (h : IsConeSol k t) {j : Fin k}
    (hj : t (Fin.last k) = t j.castSucc) : ∀ i : Fin k, i ≠ j → t i.castSucc = 0 := by
  intro i hi
  have := legs_zero_of_hyp_eq_leg (x := fun i : Fin k => t i.castSucc)
    (y := t (Fin.last k)) (j := j) h hj.symm i hi
  simpa using this

/-- **Dichotomy.**  A solution whose hypotenuse meets a leg is either identically zero, or
"one hot": that leg equals the hypotenuse and all the other legs are zero. -/
theorem hyp_merged_dichotomy {k : ℕ} {t : Fin (k + 1) → ℕ} (h : IsConeSol k t) {j : Fin k}
    (hj : t (Fin.last k) = t j.castSucc) :
    (∀ x, t x = 0) ∨ (t j.castSucc ≠ 0 ∧ ∀ i : Fin k, i ≠ j → t i.castSucc = 0) := by
  by_cases ha : t j.castSucc = 0
  · refine Or.inl fun x => ?_
    refine Fin.lastCases ?_ ?_ x
    · rw [hj, ha]
    · intro i
      by_cases hij : i = j
      · rw [hij, ha]
      · exact legs_zero_of_hyp_merged h hj i hij
  · exact Or.inr ⟨ha, legs_zero_of_hyp_merged h hj⟩

/-! ## The model solutions and their patterns -/

/-- The "one hot" solution: the `j`-th leg and the hypotenuse are `1`, all other legs `0`. -/
def coneModel (k : ℕ) (j : Fin k) : Fin (k + 1) → ℕ :=
  fun i => if i = j.castSucc ∨ i = Fin.last k then 1 else 0

theorem coneModel_last {k : ℕ} (j : Fin k) : coneModel k j (Fin.last k) = 1 := by
  simp [coneModel]

theorem coneModel_castSucc {k : ℕ} (j i : Fin k) :
    coneModel k j i.castSucc = if i = j then 1 else 0 := by
  have hne : i.castSucc ≠ Fin.last k := (Fin.castSucc_lt_last i).ne
  by_cases hij : i = j
  · simp [coneModel, hij]
  · have : i.castSucc ≠ j.castSucc := fun hc => hij (Fin.castSucc_injective _ hc)
    simp [coneModel, this, hne, hij]

theorem isConeSol_coneModel (k : ℕ) (j : Fin k) : IsConeSol k (coneModel k j) := by
  rw [IsConeSol, coneModel_last]
  have : ∀ i : Fin k, coneModel k j i.castSucc ^ 2 = if i = j then 1 else 0 := by
    intro i
    rw [coneModel_castSucc]
    by_cases hij : i = j <;> simp [hij]
  rw [Finset.sum_congr rfl fun i _ => this i]
  simp

theorem isConeSol_zero (k : ℕ) : IsConeSol k (fun _ => 0) := by
  simp [IsConeSol]

/-- The all-equal pattern is realised by the zero solution. -/
theorem canon_zero (k : ℕ) : canon (fun _ : Fin (k + 1) => (0 : ℕ)) = fun _ => 0 := by
  funext i
  exact canon_eq_iff_least.2 ⟨rfl, fun j _ => Fin.zero_le j⟩

/-- The pattern of a "one hot" solution, characterised by its equality relation. -/
theorem canon_eq_coneModel {k : ℕ} {t : Fin (k + 1) → ℕ} (h : IsConeSol k t) {j : Fin k}
    (hj : t (Fin.last k) = t j.castSucc) (ha : t j.castSucc ≠ 0) :
    canon t = canon (coneModel k j) := by
  have hzero := legs_zero_of_hyp_merged h hj
  have hval : ∀ x : Fin (k + 1),
      t x = if x = j.castSucc ∨ x = Fin.last k then t j.castSucc else 0 := by
    intro x
    refine Fin.lastCases ?_ ?_ x
    · simp [hj]
    · intro i
      have hne : i.castSucc ≠ Fin.last k := (Fin.castSucc_lt_last i).ne
      by_cases hij : i = j
      · simp [hij]
      · have hcs : i.castSucc ≠ j.castSucc := fun hc => hij (Fin.castSucc_injective _ hc)
        simp only [hcs, hne, or_self, if_false]
        exact hzero i hij
  refine canon_eq_canon_iff.2 (ker_eq_iff.2 fun x y => ?_)
  rw [hval x, hval y]
  by_cases hx : x = j.castSucc ∨ x = Fin.last k <;> by_cases hy : y = j.castSucc ∨ y = Fin.last k <;>
    simp [coneModel, hx, hy, ha, Ne.symm ha]

/-! ## The hypotenuse-merged part of the spectrum -/

/-- The full kernel spectrum of the `k`-dimensional cone. -/
noncomputable def coneSpectrum (k : ℕ) : Finset (Fin (k + 1) → Fin (k + 1)) :=
  open Classical in
  (Patterns (k + 1)).filter (fun p => ∃ t : Fin (k + 1) → ℕ, IsConeSol k t ∧ canon t = p)

theorem mem_coneSpectrum {k : ℕ} {p : Fin (k + 1) → Fin (k + 1)} :
    p ∈ coneSpectrum k ↔ ∃ t : Fin (k + 1) → ℕ, IsConeSol k t ∧ canon t = p := by
  classical
  rw [coneSpectrum, Finset.mem_filter]
  refine ⟨fun h => h.2, fun h => ⟨?_, h⟩⟩
  obtain ⟨t, -, rfl⟩ := h
  exact canon_mem_patterns t

/-- The patterns in which the hypotenuse shares a block with a leg. -/
noncomputable def mergedPart (k : ℕ) : Finset (Fin (k + 1) → Fin (k + 1)) :=
  open Classical in
  (coneSpectrum k).filter (fun p => p (Fin.last k) ≠ Fin.last k)

theorem canon_lt_last_iff {k : ℕ} {t : Fin (k + 1) → ℕ} :
    canon t (Fin.last k) ≠ Fin.last k ↔ ∃ j : Fin k, t (Fin.last k) = t j.castSucc := by
  constructor
  · intro h
    have hval : t (canon t (Fin.last k)) = t (Fin.last k) := apply_canon t _
    obtain ⟨j, hj⟩ : ∃ j : Fin k, canon t (Fin.last k) = j.castSucc := by
      refine ⟨⟨(canon t (Fin.last k)).val, ?_⟩, Fin.ext rfl⟩
      have hlt := (canon t (Fin.last k)).isLt
      have hne : (canon t (Fin.last k)).val ≠ k := fun hc => h (Fin.ext (by simpa using hc))
      omega
    exact ⟨j, by rw [← hj, hval]⟩
  · rintro ⟨j, hj⟩
    intro hcan
    have : canon t j.castSucc = canon t (Fin.last k) := ((eq_iff_canon_eq t _ _).1 hj.symm)
    rw [hcan] at this
    exact absurd (canon_le_self t j.castSucc) (by rw [this]; exact not_le.2 (Fin.castSucc_lt_last j))

/-- **The hypotenuse-merged part of the spectrum, in every dimension.**  It consists of the
all-equal pattern together with exactly one pattern for each leg. -/
theorem mergedPart_eq {k : ℕ} (hk : k ≠ 0) :
    mergedPart k =
      insert (fun _ => 0) ((Finset.univ : Finset (Fin k)).image
        fun j => canon (coneModel k j)) := by
  classical
  ext p
  simp only [mergedPart, Finset.mem_filter, Finset.mem_insert, Finset.mem_image,
    Finset.mem_univ, true_and]
  constructor
  · rintro ⟨hp, hlast⟩
    obtain ⟨t, ht, rfl⟩ := mem_coneSpectrum.1 hp
    obtain ⟨j, hj⟩ := canon_lt_last_iff.1 hlast
    rcases hyp_merged_dichotomy ht hj with hz | ⟨ha, -⟩
    · refine Or.inl ?_
      have : t = fun _ => 0 := funext hz
      rw [this, canon_zero]
    · exact Or.inr ⟨j, (canon_eq_coneModel ht hj ha).symm⟩
  · intro hp
    rcases hp with rfl | ⟨j, rfl⟩
    · refine ⟨mem_coneSpectrum.2 ⟨fun _ => 0, isConeSol_zero k, canon_zero k⟩, ?_⟩
      intro hc
      exact hk (by simpa using (congrArg Fin.val hc).symm)
    · refine ⟨mem_coneSpectrum.2 ⟨coneModel k j, isConeSol_coneModel k j, rfl⟩, ?_⟩
      refine canon_lt_last_iff.2 ⟨j, ?_⟩
      rw [coneModel_last, coneModel_castSucc, if_pos rfl]

theorem coneModel_canon_injective (k : ℕ) :
    Function.Injective fun j : Fin k => canon (coneModel k j) := by
  intro j j' hjj
  have hker : Ker (coneModel k j) = Ker (coneModel k j') := canon_eq_canon_iff.1 hjj
  rw [ker_eq_iff] at hker
  have h1 : coneModel k j j.castSucc = coneModel k j (Fin.last k) := by
    rw [coneModel_last, coneModel_castSucc, if_pos rfl]
  have h2 := (hker j.castSucc (Fin.last k)).1 h1
  rw [coneModel_last, coneModel_castSucc] at h2
  by_contra hne
  rw [if_neg hne] at h2
  exact absurd h2 (by norm_num)

theorem zero_pattern_not_mem_image {k : ℕ} (hk : 2 ≤ k) :
    (fun _ => 0) ∉ (Finset.univ : Finset (Fin k)).image fun j => canon (coneModel k j) := by
  classical
  simp only [Finset.mem_image, Finset.mem_univ, true_and, not_exists]
  intro j hj
  obtain ⟨i, hi⟩ : ∃ i : Fin k, i ≠ j := by
    have hcard : 1 < Fintype.card (Fin k) := by simpa using hk
    exact Fintype.exists_ne_of_one_lt_card hcard j
  have hker : canon (coneModel k j) i.castSucc = canon (coneModel k j) j.castSucc := by
    rw [hj]
  have := (eq_iff_canon_eq (coneModel k j) i.castSucc j.castSucc).2 hker
  rw [coneModel_castSucc, coneModel_castSucc, if_neg hi, if_pos rfl] at this
  exact absurd this (by norm_num)

/-- **Exactly `k + 1` hypotenuse-merged patterns, in every dimension `k ≥ 2`.** -/
theorem card_mergedPart {k : ℕ} (hk : 2 ≤ k) : (mergedPart k).card = k + 1 := by
  classical
  rw [mergedPart_eq (by omega), Finset.card_insert_of_notMem (zero_pattern_not_mem_image hk),
    Finset.card_image_of_injective _ (coneModel_canon_injective k), Finset.card_univ,
    Fintype.card_fin]

/-- Hence a universal lower bound for the size of the spectrum. -/
theorem card_coneSpectrum_ge {k : ℕ} (hk : 2 ≤ k) : k + 1 ≤ (coneSpectrum k).card := by
  classical
  have h : (mergedPart k).card ≤ (coneSpectrum k).card :=
    Finset.card_le_card (Finset.filter_subset _ _)
  rwa [card_mergedPart hk] at h

/-- Consistency check with the two computed cases: `3` of the `4` patterns in dimension two
and `4` of the `8` patterns in dimension three are hypotenuse-merged. -/
theorem card_mergedPart_two_three : (mergedPart 2).card = 3 ∧ (mergedPart 3).card = 4 :=
  ⟨card_mergedPart (le_refl 2), card_mergedPart (by norm_num)⟩

end HigherPythGen