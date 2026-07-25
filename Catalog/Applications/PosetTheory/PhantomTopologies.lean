import Mathlib

open Set

namespace PhantomTopology

/-- A phantom topology is a topology selected by each observer. -/
abbrev System (Observer X : Type*) := Observer → TopologicalSpace X

/-- The topology consisting exactly of the sets on which two observers agree that
    the set is open. -/
def commonTopology {X : Type*} (t₁ t₂ : TopologicalSpace X) : TopologicalSpace X where
  IsOpen s := @IsOpen X t₁ s ∧ @IsOpen X t₂ s
  isOpen_univ := ⟨@isOpen_univ X t₁, @isOpen_univ X t₂⟩
  isOpen_inter s t hs ht :=
    ⟨@IsOpen.inter X t₁ s t hs.1 ht.1, @IsOpen.inter X t₂ s t hs.2 ht.2⟩
  isOpen_sUnion S hS :=
    ⟨@isOpen_sUnion X t₁ S (fun s hs ↦ (hS s hs).1),
      @isOpen_sUnion X t₂ S (fun s hs ↦ (hS s hs).2)⟩

private lemma lower_open_inter {α : Type*} [LinearOrder α]
    {s t : Set α}
    (hs : ∀ x ∈ s, ∃ b, x < b ∧ Ico x b ⊆ s)
    (ht : ∀ x ∈ t, ∃ b, x < b ∧ Ico x b ⊆ t) :
    ∀ x ∈ s ∩ t, ∃ b, x < b ∧ Ico x b ⊆ s ∩ t := by
      grind

private lemma lower_open_sUnion {α : Type*} [LinearOrder α]
    (S : Set (Set α))
    (hS : ∀ s ∈ S, ∀ x ∈ s, ∃ b, x < b ∧ Ico x b ⊆ s) :
    ∀ x ∈ ⋃₀ S, ∃ b, x < b ∧ Ico x b ⊆ ⋃₀ S := by
  intro x hx
  obtain ⟨s, hsS, hs⟩ := mem_sUnion.mp hx
  obtain ⟨b, hb, hsub⟩ := hS s hsS x hs
  exact ⟨b, hb, hsub.trans (subset_sUnion_of_mem hsS)⟩

/-- The lower-limit topology on a linear order: every point of an open set starts
    a half-open interval contained in that set. -/
def lowerLimitTopology (α : Type*) [LinearOrder α] [NoMaxOrder α] : TopologicalSpace α where
  IsOpen s := ∀ x ∈ s, ∃ b, x < b ∧ Ico x b ⊆ s
  isOpen_univ := by
    intro x hx
    obtain ⟨b, hb⟩ := exists_gt x
    exact ⟨b, hb, by simp⟩
  isOpen_inter _ _ := lower_open_inter
  isOpen_sUnion := lower_open_sUnion

private lemma upper_open_inter {α : Type*} [LinearOrder α]
    {s t : Set α}
    (hs : ∀ x ∈ s, ∃ a, a < x ∧ Ioc a x ⊆ s)
    (ht : ∀ x ∈ t, ∃ a, a < x ∧ Ioc a x ⊆ t) :
    ∀ x ∈ s ∩ t, ∃ a, a < x ∧ Ioc a x ⊆ s ∩ t := by
      grind

private lemma upper_open_sUnion {α : Type*} [LinearOrder α]
    (S : Set (Set α))
    (hS : ∀ s ∈ S, ∀ x ∈ s, ∃ a, a < x ∧ Ioc a x ⊆ s) :
    ∀ x ∈ ⋃₀ S, ∃ a, a < x ∧ Ioc a x ⊆ ⋃₀ S := by
  intro x hx
  obtain ⟨s, hsS, hs⟩ := mem_sUnion.mp hx
  obtain ⟨a, ha, hsub⟩ := hS s hsS x hs
  exact ⟨a, ha, hsub.trans (subset_sUnion_of_mem hsS)⟩

/-- The upper-limit topology on a linear order: every point of an open set ends
    a half-open interval contained in that set. -/
def upperLimitTopology (α : Type*) [LinearOrder α] [NoMinOrder α] : TopologicalSpace α where
  IsOpen s := ∀ x ∈ s, ∃ a, a < x ∧ Ioc a x ⊆ s
  isOpen_univ := by
    intro x hx
    obtain ⟨a, ha⟩ := exists_lt x
    exact ⟨a, ha, by simp⟩
  isOpen_inter _ _ := upper_open_inter
  isOpen_sUnion := upper_open_sUnion

/-- On the real line, a set open in both the lower- and upper-limit topologies is
    open in the Euclidean topology. -/
theorem real_isOpen_of_lower_upper {s : Set ℝ}
    (hl : @IsOpen ℝ (lowerLimitTopology ℝ) s)
    (hu : @IsOpen ℝ (upperLimitTopology ℝ) s) : IsOpen s := by
      refine' isOpen_iff_forall_mem_open.2 _;
      intro x hx; cases' hl x hx with b hb; cases' hu x hx with a ha; use Set.Ioo a b; simp_all +decide [ Set.subset_def, Set.mem_Ioo ] ;
      exact ⟨ fun y hy₁ hy₂ => if hy₃ : y ≤ x then ha.2 y hy₁ hy₃ else hb.2 y ( le_of_not_ge hy₃ ) hy₂, isOpen_Ioo ⟩

/-- Every Euclidean-open subset of the real line is open in the lower-limit
    topology. -/
theorem real_lower_isOpen_of_isOpen {s : Set ℝ} (hs : IsOpen s) :
    @IsOpen ℝ (lowerLimitTopology ℝ) s := by
      intro x hx
      obtain ⟨ε, hε_pos, hε⟩ : ∃ ε > 0, Metric.ball x ε ⊆ s := by
        exact Metric.isOpen_iff.1 hs x hx;
      exact ⟨ x + ε, by linarith, fun y hy => hε <| Metric.mem_ball.2 <| abs_lt.2 ⟨ by linarith [ hy.1 ], by linarith [ hy.2 ] ⟩ ⟩

/-- Every Euclidean-open subset of the real line is open in the upper-limit
    topology. -/
theorem real_upper_isOpen_of_isOpen {s : Set ℝ} (hs : IsOpen s) :
    @IsOpen ℝ (upperLimitTopology ℝ) s := by
      intro x hx; exact (by
      rcases Metric.isOpen_iff.1 hs x hx with ⟨ ε, εpos, hε ⟩ ; exact ⟨ x - ε, by linarith, fun y hy => hε <| Metric.mem_ball.2 <| abs_lt.2 ⟨ by linarith [ hy.1 ], by linarith [ hy.2 ] ⟩ ⟩ ;);

/-- A basic half-open interval is open to the lower-limit observer. -/
theorem real_Ico_isOpen_lower (a b : ℝ) :
    @IsOpen ℝ (lowerLimitTopology ℝ) (Ico a b) := by
      intro x hx;
      exact ⟨ b, hx.2, Set.Ico_subset_Ico hx.1 le_rfl ⟩

/-- A nonempty proper half-open interval is not Euclidean-open. -/
theorem real_Ico_not_isOpen_standard {a b : ℝ} (hab : a < b) :
    ¬IsOpen (Ico a b) := by
      rw [ Metric.isOpen_iff ] ; norm_num;
      exact ⟨ a, le_rfl, hab, fun ε hε => Set.not_subset.2 ⟨ a - ε / 2, Metric.mem_ball.2 <| abs_lt.2 ⟨ by linarith, by linarith ⟩, by intro h; linarith [ h.1, h.2 ] ⟩ ⟩

/-- Thus the lower-limit observer genuinely sees more open sets than the standard
    observer. -/
theorem real_lowerLimit_ne_standard :
    lowerLimitTopology ℝ ≠ inferInstanceAs (TopologicalSpace ℝ) := by
      by_contra h_eq;
      convert real_Ico_not_isOpen_standard zero_lt_one _;
      convert real_Ico_isOpen_lower 0 1;
      convert h_eq.symm

/-- The standard topology on `ℝ` is exactly the common-open-set topology of the
    lower-limit and upper-limit observers. -/
theorem real_standard_eq_common_lower_upper :
    inferInstanceAs (TopologicalSpace ℝ) =
      commonTopology (lowerLimitTopology ℝ) (upperLimitTopology ℝ) := by
        apply_rules [ TopologicalSpace.ext, Set.ext ];
        intro s; exact ⟨fun h => ⟨real_lower_isOpen_of_isOpen h, real_upper_isOpen_of_isOpen h⟩, fun h => real_isOpen_of_lower_upper h.left h.right⟩;

/-- Any topology has a one-observer phantom representation if observers are not
    required to see a topology different from reality. This shows that observer
    lower bounds need an additional nondegeneracy condition. -/
theorem one_observer_representation {X : Type*} (t : TopologicalSpace X) :
    t = commonTopology t t := by
      ext x
      simp [commonTopology]

end PhantomTopology