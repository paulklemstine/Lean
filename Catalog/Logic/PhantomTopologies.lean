/-
# Phantom Topologies

A phantom topology is an observer-indexed family of topologies.  This file makes
"agreement" precise as the supremum in Mathlib's (reverse-inclusion) lattice of
topologies and develops a chain of results from the general definition to two
substantive examples.

The literal proposed phantom number is degenerate: every topology has a
one-observer representation, obtained by letting that observer see the real
topology itself.  A nontrivial variant requires every observer to be strictly
finer than consensus.  For that variant, the standard topology on `ℝ` has a
genuine two-observer representation by the lower- and upper-limit topologies.
The proposed lower bound for nonmetrizable spaces is false: the indiscrete
space on `Bool` is nonmetrizable yet is the consensus of two strictly finer
Sierpiński topologies.
-/
import Mathlib

open Set TopologicalSpace

namespace PhantomTopology

variable {X ι : Type*}

/-- An observer-indexed family of topologies. -/
abbrev System (ι X : Type*) := ι → TopologicalSpace X

/-- The topology consisting of the opens on which every observer agrees. -/
def consensus (T : System ι X) : TopologicalSpace X := ⨆ i, T i

/-- A set is consensus-open exactly when every observer sees it as open. -/
theorem isOpen_consensus_iff (T : System ι X) (U : Set X) :
    (consensus T).IsOpen U ↔ ∀ i, (T i).IsOpen U :=
  isOpen_iSup_iff

/-- Each observer is finer than the consensus topology. -/
theorem observer_le_consensus (T : System ι X) (i : ι) : T i ≤ consensus T :=
  le_iSup T i

/-- The literal definition always admits a one-observer representation. -/
def singletonSystem (τ : TopologicalSpace X) : System Unit X := fun _ => τ

/-- Consensus of the singleton system recovers the given topology. -/
theorem consensus_singleton (τ : TopologicalSpace X) :
    consensus (singletonSystem τ) = τ := by
  simp [consensus, singletonSystem]

/-- Therefore every topology, including every Zariski topology, has phantom
number at most one under the literal definition in the prompt. -/
theorem every_topology_has_one_observer (τ : TopologicalSpace X) :
    ∃ T : System Unit X, consensus T = τ :=
  ⟨singletonSystem τ, consensus_singleton τ⟩

/-- A representation is genuinely phantom when every observer sees strictly
more opens than the consensus. -/
def Genuine (T : System ι X) : Prop := ∀ i, T i < consensus T

/-- A singleton representation cannot be genuinely phantom. -/
theorem no_genuine_singleton (T : System Unit X) : ¬ Genuine T := by
  intro h
  have hc : consensus T = T () := by
    simp [consensus]
  have := h ()
  rw [hc] at this
  exact (lt_irrefl _ this)

/-! ## The real line: two half-open observers -/

/-- Lower-limit openness: each point starts a contained interval `[x,b)`. -/
def lowerOpen (U : Set ℝ) : Prop := ∀ x ∈ U, ∃ b, x < b ∧ Ico x b ⊆ U

/-- Upper-limit openness: each point ends a contained interval `(a,x]`. -/
def upperOpen (U : Set ℝ) : Prop := ∀ x ∈ U, ∃ a, a < x ∧ Ioc a x ⊆ U

/-- The lower-limit (Sorgenfrey) topology on `ℝ`. -/
def lowerTop : TopologicalSpace ℝ where
  IsOpen := lowerOpen
  isOpen_univ := fun x _ => ⟨x + 1, by linarith, by simp⟩
  isOpen_inter s t hs ht := by
    intro x hx
    obtain ⟨b₁, hb₁, hs₁⟩ := hs x hx.1
    obtain ⟨b₂, hb₂, ht₂⟩ := ht x hx.2
    refine ⟨min b₁ b₂, lt_min hb₁ hb₂, ?_⟩
    intro y hy
    exact ⟨hs₁ ⟨hy.1, lt_of_lt_of_le hy.2 (min_le_left _ _)⟩,
      ht₂ ⟨hy.1, lt_of_lt_of_le hy.2 (min_le_right _ _)⟩⟩
  isOpen_sUnion S hS := by
    intro x hx
    obtain ⟨U, hUS, hxU⟩ := hx
    obtain ⟨b, hb, hsub⟩ := hS U hUS x hxU
    exact ⟨b, hb, fun y hy => ⟨U, hUS, hsub hy⟩⟩

/-- The upper-limit topology on `ℝ`. -/
def upperTop : TopologicalSpace ℝ where
  IsOpen := upperOpen
  isOpen_univ := fun x _ => ⟨x - 1, by linarith, by simp⟩
  isOpen_inter s t hs ht := by
    intro x hx
    obtain ⟨a₁, ha₁, hs₁⟩ := hs x hx.1
    obtain ⟨a₂, ha₂, ht₂⟩ := ht x hx.2
    refine ⟨max a₁ a₂, max_lt ha₁ ha₂, ?_⟩
    intro y hy
    exact ⟨hs₁ ⟨lt_of_le_of_lt (le_max_left _ _) hy.1, hy.2⟩,
      ht₂ ⟨lt_of_le_of_lt (le_max_right _ _) hy.1, hy.2⟩⟩
  isOpen_sUnion S hS := by
    intro x hx
    obtain ⟨U, hUS, hxU⟩ := hx
    obtain ⟨a, ha, hsub⟩ := hS U hUS x hxU
    exact ⟨a, ha, fun y hy => ⟨U, hUS, hsub hy⟩⟩

/-- A set simultaneously lower- and upper-limit open is Euclidean open, and
conversely.  Thus the standard topology is the observers' agreement topology. -/
theorem lower_sup_upper_eq_standard :
    lowerTop ⊔ upperTop = (inferInstance : TopologicalSpace ℝ) := by
  apply TopologicalSpace.ext
  ext U
  constructor
  · rintro ⟨hlo, hup⟩
    rw [Metric.isOpen_iff]
    intro x hx
    obtain ⟨b, hb, hbsub⟩ := hlo x hx
    obtain ⟨a, ha, hasub⟩ := hup x hx
    refine ⟨min (x - a) (b - x), by simp only [lt_min_iff]; constructor <;> linarith, ?_⟩
    intro y hy
    rw [Metric.mem_ball, Real.dist_eq] at hy
    have h₁ : |y - x| < x - a := lt_of_lt_of_le hy (min_le_left _ _)
    have h₂ : |y - x| < b - x := lt_of_lt_of_le hy (min_le_right _ _)
    rw [abs_lt] at h₁ h₂
    rcases le_or_gt x y with hxy | hxy
    · exact hbsub ⟨hxy, by linarith [h₂.2]⟩
    · exact hasub ⟨by linarith [h₁.1], le_of_lt hxy⟩
  · intro hU
    rw [Metric.isOpen_iff] at hU
    refine ⟨?_, ?_⟩
    · intro x hx
      obtain ⟨ε, hε, hsub⟩ := hU x hx
      refine ⟨x + ε, by linarith, ?_⟩
      intro y hy
      apply hsub
      rw [Metric.mem_ball, Real.dist_eq, abs_lt]
      constructor <;> [linarith [hy.1]; linarith [hy.2]]
    · intro x hx
      obtain ⟨ε, hε, hsub⟩ := hU x hx
      refine ⟨x - ε, by linarith, ?_⟩
      intro y hy
      apply hsub
      rw [Metric.mem_ball, Real.dist_eq, abs_lt]
      constructor <;> [linarith [hy.1]; linarith [hy.2]]

/-- The two real-line observers, indexed by `Bool`. -/
def realObservers : System Bool ℝ := fun b => if b then lowerTop else upperTop

/-- Their consensus is the standard topology on `ℝ`. -/
theorem real_consensus_eq_standard :
    consensus realObservers = (inferInstance : TopologicalSpace ℝ) := by
  rw [consensus, iSup_bool_eq]
  exact lower_sup_upper_eq_standard

/-- `[0,1)` is lower-limit open. -/
theorem lowerOpen_Ico : lowerOpen (Ico 0 1) :=
  fun _ hx => ⟨1, hx.2, fun _ hy => ⟨le_trans hx.1 hy.1, hy.2⟩⟩

/-- `[0,1)` is not Euclidean open. -/
theorem not_standardOpen_Ico : ¬ IsOpen (Ico (0 : ℝ) 1) := by
  intro h
  rw [Metric.isOpen_iff] at h
  obtain ⟨ε, hε, hsub⟩ := h 0 (by constructor <;> norm_num)
  have hm : -(ε / 2) ∈ Metric.ball (0 : ℝ) ε := by
    rw [Metric.mem_ball, Real.dist_eq, show (-(ε / 2) - 0 : ℝ) = -(ε / 2) by ring,
      abs_neg, abs_of_nonneg (by linarith)]
    linarith
  have := hsub hm
  simp only [mem_Ico] at this
  linarith [this.1]

/-- `(0,1]` is upper-limit open. -/
theorem upperOpen_Ioc : upperOpen (Ioc 0 1) :=
  fun _ hx => ⟨0, hx.1, fun _ hy => ⟨hy.1, le_trans hy.2 hx.2⟩⟩

/-- `(0,1]` is not Euclidean open. -/
theorem not_standardOpen_Ioc : ¬ IsOpen (Ioc (0 : ℝ) 1) := by
  intro h
  rw [Metric.isOpen_iff] at h
  obtain ⟨ε, hε, hsub⟩ := h 1 (by constructor <;> norm_num)
  have hm : 1 + ε / 2 ∈ Metric.ball (1 : ℝ) ε := by
    rw [Metric.mem_ball, Real.dist_eq, show (1 + ε / 2 - 1 : ℝ) = ε / 2 by ring,
      abs_of_nonneg (by linarith)]
    linarith
  have := hsub hm
  simp only [mem_Ioc] at this
  linarith [this.2]

/-- The lower observer is strictly finer than Euclidean reality. -/
theorem lowerTop_lt_standard : lowerTop < (inferInstance : TopologicalSpace ℝ) := by
  refine lt_of_le_of_ne ?_ ?_
  · rw [← lower_sup_upper_eq_standard]
    exact le_sup_left
  · intro h
    apply not_standardOpen_Ico
    have ho : @IsOpen ℝ lowerTop (Ico 0 1) := lowerOpen_Ico
    rw [h] at ho
    exact ho

/-- The upper observer is strictly finer than Euclidean reality. -/
theorem upperTop_lt_standard : upperTop < (inferInstance : TopologicalSpace ℝ) := by
  refine lt_of_le_of_ne ?_ ?_
  · rw [← lower_sup_upper_eq_standard]
    exact le_sup_right
  · intro h
    apply not_standardOpen_Ioc
    have ho : @IsOpen ℝ upperTop (Ioc 0 1) := upperOpen_Ioc
    rw [h] at ho
    exact ho

/-- The real-line representation is genuinely phantom. -/
theorem realObservers_genuine : Genuine realObservers := by
  intro b
  rw [real_consensus_eq_standard]
  cases b <;> simp [realObservers, lowerTop_lt_standard, upperTop_lt_standard]

/-! ## A nonmetrizable two-observer counterexample -/

/-- The Sierpiński topology whose extra open singleton is `{true}`. -/
def sierpTrue : TopologicalSpace Bool where
  IsOpen U := false ∈ U → true ∈ U
  isOpen_univ := by intro _; trivial
  isOpen_inter s t hs ht := by intro h; exact ⟨hs h.1, ht h.2⟩
  isOpen_sUnion S hS := by
    rintro ⟨U, hUS, hfU⟩
    exact ⟨U, hUS, hS U hUS hfU⟩

/-- The opposite Sierpiński topology, with extra open singleton `{false}`. -/
def sierpFalse : TopologicalSpace Bool where
  IsOpen U := true ∈ U → false ∈ U
  isOpen_univ := by intro _; trivial
  isOpen_inter s t hs ht := by intro h; exact ⟨hs h.1, ht h.2⟩
  isOpen_sUnion S hS := by
    rintro ⟨U, hUS, htU⟩
    exact ⟨U, hUS, hS U hUS htU⟩

/-- Agreement of the opposite Sierpiński observers is the indiscrete topology. -/
theorem sierp_sup_eq_indiscrete :
    sierpTrue ⊔ sierpFalse = (⊤ : TopologicalSpace Bool) := by
  apply TopologicalSpace.ext
  ext U
  rw [isOpen_top_iff]
  constructor
  · rintro ⟨hT, hF⟩
    by_cases hne : U = ∅
    · exact Or.inl hne
    · refine Or.inr ?_
      obtain ⟨x, hx⟩ := nonempty_iff_ne_empty.2 hne
      have ht : true ∈ U := by
        cases x with
        | false => exact hT hx
        | true => exact hx
      have hf : false ∈ U := hF ht
      ext y
      cases y <;> simp_all
  · rintro (rfl | rfl)
    · exact @isOpen_empty Bool (sierpTrue ⊔ sierpFalse)
    · exact @isOpen_univ Bool (sierpTrue ⊔ sierpFalse)

/-- The indiscrete topology on two points is not metrizable. -/
theorem indiscrete_bool_not_metrizable : ¬ @MetrizableSpace Bool ⊤ := by
  intro h
  have hT0 : @T0Space Bool ⊤ := @MetrizableSpace.toT0Space Bool ⊤ h
  have hins : @Inseparable Bool ⊤ true false := by
    rw [@inseparable_iff_forall_isOpen Bool ⊤]
    intro U hU
    rcases (isOpen_top_iff U).1 hU with h0 | h1 <;> subst_vars <;> simp
  have : true = false := @T0Space.t0 Bool ⊤ hT0 true false hins
  simp at this

/-- The two Sierpiński observers. -/
def boolObservers : System Bool Bool := fun b => if b then sierpTrue else sierpFalse

/-- Their consensus is indiscrete. -/
theorem bool_consensus_eq_indiscrete :
    consensus boolObservers = (⊤ : TopologicalSpace Bool) := by
  rw [consensus, iSup_bool_eq]
  exact sierp_sup_eq_indiscrete

/-- Each Sierpiński observer is strictly finer than indiscrete reality. -/
theorem boolObservers_genuine : Genuine boolObservers := by
  intro b
  rw [bool_consensus_eq_indiscrete]
  cases b
  · simp only [boolObservers, Bool.false_eq]
    refine lt_of_le_of_ne le_top ?_
    intro h
    have ho : @IsOpen Bool sierpFalse {false} := by intro ht; simp at ht
    have : @IsOpen Bool (⊤ : TopologicalSpace Bool) {false} := h ▸ ho
    rw [isOpen_top_iff] at this
    rcases this with h0 | h1
    · exact Set.singleton_ne_empty false h0
    · have : true ∈ ({false} : Set Bool) := by rw [h1]; trivial
      simp at this
  · simp only [boolObservers, ↓reduceIte]
    refine lt_of_le_of_ne le_top ?_
    intro h
    have ho : @IsOpen Bool sierpTrue {true} := by intro hf; simp at hf
    have : @IsOpen Bool (⊤ : TopologicalSpace Bool) {true} := h ▸ ho
    rw [isOpen_top_iff] at this
    rcases this with h0 | h1
    · exact Set.singleton_ne_empty true h0
    · have : false ∈ ({true} : Set Bool) := by rw [h1]; trivial
      simp at this

/-- A nonmetrizable topology has a genuine two-observer representation.  This
formally refutes the proposed claim that every nonmetrizable space requires at
least three observers, even after excluding trivial observers. -/
theorem nonmetrizable_genuine_two_observer_counterexample :
    ∃ (Y : Type) (T : System Bool Y),
      ¬ @MetrizableSpace Y (consensus T) ∧ Genuine T := by
  refine ⟨Bool, boolObservers, ?_, boolObservers_genuine⟩
  rw [bool_consensus_eq_indiscrete]
  exact indiscrete_bool_not_metrizable

end PhantomTopology