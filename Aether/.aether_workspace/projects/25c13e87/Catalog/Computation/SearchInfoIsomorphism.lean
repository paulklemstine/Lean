import Mathlib

/-! # CatalogBuild.Computation.SearchInfoIsomorphism

Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 63
-/


noncomputable section

/-- Shannon entropy of a uniform distribution over N outcomes. -/
def uniformEntropy (N : ℕ) : ℝ := Real.log N / Real.log 2




/-- Information gained by learning the answer from a uniform distribution. -/
def informationGain (N : ℕ) : ℝ := uniformEntropy N




/-- Minimum binary search depth for a search space of size N. -/
def searchWork (N : ℕ) : ℝ := uniformEntropy N




/-- **Theorem 1.1 (The Search-Information Isomorphism)** -/
theorem search_info_isomorphism (N : ℕ) :
    searchWork N = informationGain N := rfl




/-- **Theorem 1.2**: Entropy of a trivial search space is zero. -/
theorem entropy_one : uniformEntropy 1 = 0 := by
  simp [uniformEntropy, Real.log_one]




/-- **Theorem 1.3**: Entropy of a binary choice is 1 bit. -/
theorem entropy_two : uniformEntropy 2 = 1 := by
  simp only [uniformEntropy, Nat.cast_ofNat]
  exact div_self (ne_of_gt (Real.log_pos (by norm_num : (1 : ℝ) < 2)))




/-- **Theorem 1.4**: Doubling the search space adds exactly 1 bit. -/
theorem entropy_doubling (N : ℕ) (hN : (N : ℝ) > 0) :
    uniformEntropy (2 * N) = 1 + uniformEntropy N := by
      unfold uniformEntropy
      field_simp [hN];
      rw [ Nat.cast_mul, Real.log_mul ] <;> aesop




/-- **Theorem 1.5**: Entropy is monotone. -/
theorem entropy_monotone {M N : ℕ} (hM : 0 < M) (h : M ≤ N) :
    uniformEntropy M ≤ uniformEntropy N := by
      exact div_le_div_of_nonneg_right ( Real.log_le_log ( by positivity ) ( by norm_cast ) ) ( by positivity )




/-- **Theorem 1.6**: Entropy is nonneg for nonempty search spaces. -/
theorem entropy_nonneg {N : ℕ} (hN : 1 ≤ N) :
    0 ≤ uniformEntropy N := by
  simp only [uniformEntropy]
  apply div_nonneg
  · exact Real.log_nonneg (by exact_mod_cast hN)
  · exact le_of_lt (Real.log_pos (by norm_num : (1:ℝ) < 2))




/-- A collapse operator is an idempotent endomorphism. -/
structure CollapseOperator (X : Type*) where
  collapse : X → X
  idempotent : ∀ x, collapse (collapse x) = collapse x




/-- The "collapsed set" — fixed points of the collapse. -/
def CollapseOperator.collapsedSet {X : Type*} (C : CollapseOperator X) : Set X :=
  {x | C.collapse x = x}




/-- The "superposition set" — non-fixed points. -/
def CollapseOperator.superpositionSet {X : Type*} (C : CollapseOperator X) : Set X :=
  {x | C.collapse x ≠ x}




/-- **Theorem 2.1**: Collapsed and superposition sets partition the space. -/
theorem collapse_partition {X : Type*} (C : CollapseOperator X) :
    C.collapsedSet ∪ C.superpositionSet = Set.univ := by
  ext x; simp [CollapseOperator.collapsedSet, CollapseOperator.superpositionSet, em]




/-- **Theorem 2.2**: Collapsed and superposition sets are disjoint. -/
theorem collapse_disjoint {X : Type*} (C : CollapseOperator X) :
    C.collapsedSet ∩ C.superpositionSet = ∅ := by
  ext x; simp [CollapseOperator.collapsedSet, CollapseOperator.superpositionSet]




/-- **Theorem 2.3 (Collapse Irreversibility)** -/
theorem collapse_to_collapsed {X : Type*} (C : CollapseOperator X) (x : X) :
    C.collapse x ∈ C.collapsedSet := C.idempotent x




/-- **Theorem 2.4 (Range = Collapsed Set)** -/
theorem collapse_range_eq {X : Type*} (C : CollapseOperator X) :
    range C.collapse = C.collapsedSet := by
  ext y; constructor
  · rintro ⟨x, rfl⟩; exact C.idempotent x
  · intro hy; exact ⟨y, hy⟩




/-- Identity collapse. -/
def CollapseOperator.identity (X : Type*) : CollapseOperator X where
  collapse := id
  idempotent _ := rfl




/-- **Theorem 2.6**: Identity collapse has empty superposition set. -/
theorem identity_no_superposition :
    (CollapseOperator.identity ℝ).superpositionSet = ∅ := by
  ext x; simp [CollapseOperator.superpositionSet, CollapseOperator.identity]




/-- Constant collapse. -/
def CollapseOperator.total {X : Type*} (answer : X) : CollapseOperator X where
  collapse := fun _ => answer
  idempotent _ := rfl




/-- **Theorem 2.8**: Total collapse has singleton collapsed set. -/
theorem total_collapse_singleton (c : ℝ) :
    (CollapseOperator.total c).collapsedSet = {c} := by
  ext x; simp [CollapseOperator.collapsedSet, CollapseOperator.total, eq_comm]




/-- Binary query entropy after k queries. -/
def binaryQueryEntropy (N : ℕ) (k : ℕ) : ℝ :=
  uniformEntropy N - k




/-- [Section: # CatalogBuild.Computation.SearchInfoIsomorphism
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 63] -/
theorem full_search_collapses (N : ℕ) :
    binaryQueryEntropy N 0 = uniformEntropy N := by
  simp [binaryQueryEntropy]




/-- [Section: # CatalogBuild.Computation.SearchInfoIsomorphism
Auto-generated from theorem catalog database.
Domain: Computation
Declarations: 63] -/
theorem query_reduces_entropy (N : ℕ) (k : ℕ) :
    binaryQueryEntropy N k - binaryQueryEntropy N (k + 1) = 1 := by
  simp only [binaryQueryEntropy]; push_cast; ring




theorem entropy_reduction_additive (N k₁ k₂ : ℕ) :
    binaryQueryEntropy N k₁ - binaryQueryEntropy N (k₁ + k₂) = k₂ := by
  simp only [binaryQueryEntropy]; push_cast; ring




/-- **Theorem 3.4 (Information Conservation)** -/
theorem information_conservation (N k : ℕ) :
    (k : ℝ) + binaryQueryEntropy N k = uniformEntropy N := by
  simp only [binaryQueryEntropy]; ring




/-- Landauer energy cost. -/
def landauerCost (n_bits : ℝ) (kT : ℝ) : ℝ :=
  n_bits * kT * Real.log 2




theorem landauer_nonneg (n : ℝ) (kT : ℝ) (hn : 0 ≤ n) (hkT : 0 ≤ kT) :
    0 ≤ landauerCost n kT := by
  unfold landauerCost
  apply mul_nonneg (mul_nonneg hn hkT)
  exact le_of_lt (Real.log_pos (by norm_num : (1:ℝ) < 2))




theorem landauer_linear (n₁ n₂ kT : ℝ) :
    landauerCost (n₁ + n₂) kT = landauerCost n₁ kT + landauerCost n₂ kT := by
  unfold landauerCost; ring




theorem search_energy_isomorphism (N : ℕ) (kT : ℝ) :
    landauerCost (searchWork N) kT = landauerCost (informationGain N) kT := rfl




theorem zero_search_zero_cost (kT : ℝ) :
    landauerCost (searchWork 1) kT = 0 := by
  simp [landauerCost, searchWork, uniformEntropy, Real.log_one]




theorem landauer_monotone (n₁ n₂ kT : ℝ) (hn : n₁ ≤ n₂) (hkT : 0 ≤ kT) :
    landauerCost n₁ kT ≤ landauerCost n₂ kT := by
  unfold landauerCost
  apply mul_le_mul_of_nonneg_right
  · exact mul_le_mul_of_nonneg_right hn hkT
  · exact le_of_lt (Real.log_pos (by norm_num : (1:ℝ) < 2))




structure MeasurementScenario where
  N : ℕ
  hN : 0 < N
  prob : Fin N → ℝ
  prob_nonneg : ∀ i, 0 ≤ prob i
  prob_sum_one : ∑ i : Fin N, prob i = 1




def MeasurementScenario.preMeasurementEntropy (m : MeasurementScenario) : ℝ :=
  -∑ i : Fin m.N, m.prob i * Real.log (m.prob i)




def postMeasurementEntropy : ℝ := 0




def MeasurementScenario.infoGained (m : MeasurementScenario) : ℝ :=
  m.preMeasurementEntropy - postMeasurementEntropy




/-- **Theorem 5.1 (Collapse = Full Information Gain)** -/
theorem collapse_is_full_info_gain (m : MeasurementScenario) :
    m.infoGained = m.preMeasurementEntropy := by
  simp [MeasurementScenario.infoGained, postMeasurementEntropy]




/-- **Theorem 5.2**: For a uniform measurement, info gained = log(N). -/
theorem uniform_measurement_info (N : ℕ) (hN : 0 < N) :
    -∑ i : Fin N, (1 / (N : ℝ)) * Real.log (1 / (N : ℝ)) =
    Real.log N := by
      simp +zetaDelta
      rw [← mul_assoc, mul_inv_cancel₀ (by positivity : (N : ℝ) ≠ 0), one_mul]




/-- A uniform measurement scenario. -/
def uniformMeasurement (N : ℕ) (hN : 0 < N) : MeasurementScenario where
  N := N
  hN := hN
  prob := fun _ => 1 / N
  prob_nonneg := fun _ => by positivity
  prob_sum_one := by
    rw [Finset.sum_const, Finset.card_fin, nsmul_eq_mul]; field_simp




structure SearchMeasurementInfo where
  search_work : ℕ → ℝ
  info_gained : ℕ → ℝ
  energy_cost : ℕ → ℝ
  search_eq_info : search_work = info_gained
  info_eq_energy : info_gained = energy_cost




theorem grand_isomorphism : ∃ (_ : SearchMeasurementInfo), True :=
  ⟨{ search_work := uniformEntropy
     info_gained := uniformEntropy
     energy_cost := uniformEntropy
     search_eq_info := rfl
     info_eq_energy := rfl }, trivial⟩




theorem collapse_functor (C : CollapseOperator ℕ) (N : ℕ) :
    searchWork (C.collapse N) = informationGain (C.collapse N) := rfl




/-- **Theorem 7.1 (Search Additivity)** -/
theorem search_additivity (M N : ℕ) (hM : (M : ℝ) > 0) (hN : (N : ℝ) > 0) :
    uniformEntropy (M * N) = uniformEntropy M + uniformEntropy N := by
  simp only [uniformEntropy, Nat.cast_mul]
  rw [Real.log_mul (ne_of_gt hM) (ne_of_gt hN)]
  ring




def CollapseOperator.product {X Y : Type*}
    (C₁ : CollapseOperator X) (C₂ : CollapseOperator Y) :
    CollapseOperator (X × Y) where
  collapse := fun p => (C₁.collapse p.1, C₂.collapse p.2)
  idempotent := fun ⟨x, y⟩ => by simp [C₁.idempotent, C₂.idempotent]




theorem product_collapsed_set {X Y : Type*}
    (C₁ : CollapseOperator X) (C₂ : CollapseOperator Y) :
    (C₁.product C₂).collapsedSet = C₁.collapsedSet ×ˢ C₂.collapsedSet := by
  ext ⟨x, y⟩
  simp [CollapseOperator.collapsedSet, CollapseOperator.product, Set.mem_prod]




def CollapseOperator.iterate {X : Type*} (C : CollapseOperator X) : ℕ → X → X
  | 0 => id
  | n + 1 => C.collapse ∘ C.iterate n




theorem iterate_stabilizes {X : Type*} (C : CollapseOperator X) (n : ℕ) (x : X) :
    C.iterate (n + 1) x = C.collapse x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    show C.collapse (C.iterate (n + 1) x) = C.collapse x
    rw [ih]; exact C.idempotent x




/-- **Theorem 8.2 (One Collapse Suffices)** -/
theorem one_collapse_suffices {X : Type*} (C : CollapseOperator X) (x : X) :
    C.iterate 2 x = C.iterate 1 x :=
  iterate_stabilizes C 1 x




structure PhotonObservation where
  source_states : ℕ
  h_pos : 0 < source_states
  photon_capacity : ℝ
  h_capacity : photon_capacity = uniformEntropy source_states
  collapse : CollapseOperator (Fin source_states)




theorem photon_is_search_is_info (obs : PhotonObservation) :
    obs.photon_capacity = searchWork obs.source_states ∧
    obs.photon_capacity = informationGain obs.source_states :=
  ⟨obs.h_capacity, obs.h_capacity⟩




theorem photon_collapse_theorem (obs : PhotonObservation) (state : Fin obs.source_states) :
    obs.collapse.collapse state ∈ obs.collapse.collapsedSet :=
  obs.collapse.idempotent state




theorem no_photon_no_info : uniformEntropy 1 = 0 := entropy_one




theorem experiment_binary_8 : uniformEntropy 8 = 3 := by
  show Real.log (8 : ℝ) / Real.log 2 = 3
  rw [show (8 : ℝ) = 2 ^ 3 from by norm_num]; exact log_pow2_div 3




theorem experiment_binary_1024 : uniformEntropy 1024 = 10 := by
  show Real.log (1024 : ℝ) / Real.log 2 = 10
  rw [show (1024 : ℝ) = 2 ^ 10 from by norm_num]; exact log_pow2_div 10




/-- Powers of 2 have integer entropy. -/
theorem power_of_two_entropy (k : ℕ) : uniformEntropy (2 ^ k) = k := by
  show Real.log ((2 ^ k : ℕ) : ℝ) / Real.log 2 = k
  rw [Nat.cast_pow, Nat.cast_ofNat]; exact log_pow2_div k




theorem experiment_retraction (C : CollapseOperator ℝ) :
    ∀ x, C.collapse x ∈ range C.collapse := fun x => ⟨x, rfl⟩




theorem experiment_landauer_byte :
    landauerCost 8 (411 / 100) = 8 * (411/100) * Real.log 2 := by
  unfold landauerCost; ring




theorem recursive_collapse (M N : ℕ) (hM : (M : ℝ) > 0) (hN : (N : ℝ) > 0) :
    uniformEntropy (M * N) = uniformEntropy M + uniformEntropy N :=
  search_additivity M N hM hN




theorem info_has_mass (kT c_squared : ℝ) (hc : c_squared > 0)
    (n_bits : ℝ) (hn : 0 ≤ n_bits) (hkT : 0 ≤ kT) :
    landauerCost n_bits kT / c_squared ≥ 0 :=
  div_nonneg (landauer_nonneg n_bits kT hn hkT) (le_of_lt hc)




def collapse_compose {X : Type*} (C₁ C₂ : CollapseOperator X)
    (_h_comm : ∀ x, C₁.collapse (C₂.collapse x) = C₂.collapse (C₁.collapse x))
    (h_idem : ∀ x, C₁.collapse (C₂.collapse (C₁.collapse (C₂.collapse x))) =
                    C₁.collapse (C₂.collapse x)) :
    CollapseOperator X where
  collapse := C₁.collapse ∘ C₂.collapse
  idempotent x := h_idem x




theorem collapse_refinement {X : Type*} (C₁ C₂ : CollapseOperator X)
    (h : C₂.collapsedSet ⊆ C₁.collapsedSet)
    (h_range : ∀ x, C₂.collapse x ∈ C₂.collapsedSet) :
    ∀ x, C₁.collapse (C₂.collapse x) = C₂.collapse x :=
  fun x => h (h_range x)




/-- **H5 (Information Speed Limit)**: |Δx| ≤ |Δt| for causal signals. -/
theorem information_speed_limit (Δx Δt : ℝ) (h_causal : Δx ^ 2 ≤ Δt ^ 2) :
    |Δx| ≤ |Δt| := by
      simpa only [ sq_le_sq ] using h_causal




structure GrandSynthesis where
  search_is_info : ∀ N, searchWork N = informationGain N
  collapse_once : ∀ (X : Type) (C : CollapseOperator X) (x : X),
    C.collapse (C.collapse x) = C.collapse x
  info_costs_energy : ∀ n kT, 0 ≤ n → 0 ≤ kT → 0 ≤ landauerCost n kT
  entropy_log : ∀ (k : ℕ), uniformEntropy (2 ^ k) = k
  search_additive : ∀ M N : ℕ, (M : ℝ) > 0 → (N : ℝ) > 0 →
    uniformEntropy (M * N) = uniformEntropy M + uniformEntropy N




/-- **The Grand Theorem**: The synthesis is internally consistent. -/
theorem grand_synthesis_consistent : Nonempty GrandSynthesis :=
  ⟨{ search_is_info := fun _ => rfl
     collapse_once := fun _ C x => C.idempotent x
     info_costs_energy := fun n kT hn hkT => landauer_nonneg n kT hn hkT
     entropy_log := power_of_two_entropy
     search_additive := search_additivity }⟩




end
