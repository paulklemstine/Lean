import Mathlib

/-! # CatalogBuild.Speculative.Consciousness.InformationTheoreticDepth

Auto-generated from theorem catalog database.
Domain: Speculative/Consciousness
Declarations: 14
-/

noncomputable section

/-- No injective description can compress n items into fewer than n codes. -/
theorem pigeonhole_description {n m : ℕ} (hn : m < n)
    (f : Fin n → Fin m) : ¬ Injective f := by
  intro hinj
  exact absurd (Fintype.card_le_of_injective f hinj) (by simp; omega)

/-- A partition of a system into two parts, with information flow between them. -/
structure SystemPartition where
  n : ℕ
  k : ℕ
  hk : 0 < k
  hk_lt : k < n
  mutual_info : ℝ
  mutual_info_nonneg : 0 ≤ mutual_info

/-- Integrated information Φ: the minimum mutual information over all partitions. -/
def integratedInformation (partitions : Set SystemPartition)
    (hne : partitions.Nonempty) : ℝ :=
  sInf (SystemPartition.mutual_info '' partitions)

/-- Φ is bounded below by 0. -/
theorem phi_nonneg (partitions : Set SystemPartition) (hne : partitions.Nonempty) :
    0 ≤ integratedInformation partitions hne := by
  unfold integratedInformation
  apply le_csInf (hne.image _)
  rintro x ⟨p, -, rfl⟩
  exact p.mutual_info_nonneg

/-- A self-referential information system. -/
structure SelfRefInfo where
  State : Type*
  info : State → ℝ
  self_info : State → ℝ
  info_nonneg : ∀ s, 0 ≤ info s
  self_info_bounded : ∀ s, self_info s ≤ info s

/-- The self-referential gap: information NOT about the self. -/
def SelfRefInfo.gap (S : SelfRefInfo) (s : S.State) : ℝ :=
  S.info s - S.self_info s

/-- The gap is always nonneg. -/
theorem SelfRefInfo.gap_nonneg (S : SelfRefInfo) (s : S.State) :
    0 ≤ S.gap s := by
  unfold SelfRefInfo.gap; linarith [S.self_info_bounded s]

/-- Full self-knowledge means zero gap. -/
theorem SelfRefInfo.full_self_knowledge (S : SelfRefInfo) (s : S.State)
    (h : S.self_info s = S.info s) :
    S.gap s = 0 := by
  unfold SelfRefInfo.gap; linarith

/-- A system is conscious if its Φ exceeds a threshold. -/
structure ConsciousnessThreshold where
  threshold : ℝ
  threshold_pos : 0 < threshold

/-- [Section: # CatalogBuild.Speculative.Consciousness.InformationTheoreticDepth
Auto-generated from theorem catalog database.
Domain: Speculative/Consciousness
Declarations: 14] -/
def isConscious (ct : ConsciousnessThreshold)
    (partitions : Set SystemPartition) (hne : partitions.Nonempty) : Prop :=
  ct.threshold ≤ integratedInformation partitions hne

/-- If Φ is monotone under system combination, consciousness is preserved. -/
theorem combined_conscious (ct : ConsciousnessThreshold)
    (p1 : Set SystemPartition) (h1 : p1.Nonempty)
    (Φ1_conscious : isConscious ct p1 h1)
    (p_combined : Set SystemPartition) (hc : p_combined.Nonempty)
    (h_mono : integratedInformation p1 h1 ≤ integratedInformation p_combined hc) :
    isConscious ct p_combined hc := by
  unfold isConscious at *; linarith

/-- The self-reference tower: iterating self-description. -/
def selfRefTower (describe : ℕ → ℕ) : ℕ → ℕ
  | 0 => 0
  | n + 1 => describe (selfRefTower describe n)

/-- If description always increases length, the tower grows without bound. -/
theorem selfRefTower_unbounded (describe : ℕ → ℕ)
    (h_grows : ∀ n, n < describe n) :
    ∀ k, k ≤ selfRefTower describe k := by
  intro k
  induction k with
  | zero => simp [selfRefTower]
  | succ n ih =>
    simp [selfRefTower]
    calc n + 1 ≤ selfRefTower describe n + 1 := by omega
    _ ≤ describe (selfRefTower describe n) := by linarith [h_grows (selfRefTower describe n)]

/-- If description is bounded, the tower stabilizes. -/
theorem selfRefTower_bounded_stabilizes (describe : ℕ → ℕ) (bound : ℕ)
    (h_bound : ∀ n, describe n ≤ bound) :
    ∀ k, selfRefTower describe k ≤ bound := by
  intro k
  induction k with
  | zero => simp [selfRefTower]
  | succ n _ => simp [selfRefTower]; exact h_bound _

end