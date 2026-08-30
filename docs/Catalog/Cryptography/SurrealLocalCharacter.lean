import Catalog.Cryptography.SurrealOrderTopology

/-!
# No surreal number has countable local character

Building on `Catalog.Cryptography.SurrealOrderTopology`, this file proves that the
order topology on `Surreal` has **uncountable character at every point**:

* `Surreal.exists_nhds_zero_not_subset_family` — given any small family of neighbourhoods
  of `0` there is a neighbourhood of `0` containing none of them.  The witness comes from the
  Conway cut `{0 | r₀, r₁, …}` of the right endpoints of intervals inside the given
  neighbourhoods.
* `Surreal.exists_nhds_not_subset_family` — the same at an arbitrary point, obtained by
  *translating* the statement at `0` along the homeomorphism `x ↦ x + c`.
* `Surreal.nhds_not_isCountablyGenerated` — `𝓝 c` is never countably generated.
* `Surreal.not_countable_of_nhds_basis` and `Surreal.not_small_of_nhds_basis` — every
  neighbourhood basis at any point is uncountable, and indeed not small at all, i.e. the
  character of every point exceeds every small cardinal.
* `Surreal.not_firstCountableTopology`, `Surreal.not_secondCountableTopology`,
  `Surreal.not_metrizableSpace` — global consequences.
* `Surreal.tendsto_iff_eventually_eq` — the surreals are *sequentially discrete*:
  a sequence converges iff it is eventually constant; yet
  `Surreal.not_discreteTopology` shows the space is not discrete.  Together these give a
  second, independent proof that no point has countable character.
-/

open SetTheory PGame Filter Set Topology

namespace Surreal

/-! ## Failure of countable character at zero -/

/-- **No small family of neighbourhoods of `0` is a neighbourhood basis at `0`.**
Given neighbourhoods `B i` of `0`, choose intervals `Ioo (l i) (r i) ⊆ B i` around `0`
and let `y = {0 | r}` be positive and below every `r i`; then `Ioo (-y) y` is a
neighbourhood of `0` containing no `B i`, since `y ∈ Ioo (l i) (r i) ⊆ B i`. -/
theorem exists_nhds_zero_not_subset_family {ι : Type u} (B : ι → Set Surreal.{u})
    (hB : ∀ i, B i ∈ 𝓝 (0 : Surreal.{u})) :
    ∃ s ∈ 𝓝 (0 : Surreal.{u}), ∀ i, ¬ B i ⊆ s := by
  choose l r hmem hsub using fun i => mem_nhds_iff_exists_Ioo_subset.1 (hB i)
  obtain ⟨y, hy0, hy⟩ := exists_pos_lt_family r fun i => (hmem i).2
  refine ⟨Ioo (-y) y, Ioo_mem_nhds (neg_lt_zero.2 hy0) hy0, fun i hsubset => ?_⟩
  have hyB : y ∈ B i := hsub i ⟨(hmem i).1.trans hy0, hy i⟩
  exact absurd (hsubset hyB).2 (lt_irrefl y)

/-- The countable special case of `exists_nhds_zero_not_subset_family`. -/
theorem exists_nhds_zero_not_subset (B : ℕ → Set Surreal.{u})
    (hB : ∀ n, B n ∈ 𝓝 (0 : Surreal.{u})) :
    ∃ s ∈ 𝓝 (0 : Surreal.{u}), ∀ n, ¬ B n ⊆ s := by
  obtain ⟨s, hs, hns⟩ :=
    exists_nhds_zero_not_subset_family (fun j : ULift.{u} ℕ => B j.down) (fun j => hB j.down)
  exact ⟨s, hs, fun n => hns (ULift.up n)⟩

/-! ## Transfer to every point by translation -/

/-- **Translation transfers the failure of small character from `0` to every point.**
Given neighbourhoods `B i` of an arbitrary surreal `c`, there is a neighbourhood of `c`
containing none of them. -/
theorem exists_nhds_not_subset_family (c : Surreal.{u}) {ι : Type u} (B : ι → Set Surreal.{u})
    (hB : ∀ i, B i ∈ 𝓝 c) :
    ∃ s ∈ 𝓝 c, ∀ i, ¬ B i ⊆ s := by
  set h := addRightHomeomorph (-c) with hh
  have hc : h c = 0 := by simp [hh]
  have hBim : ∀ i, h '' B i ∈ 𝓝 (0 : Surreal.{u}) := by
    intro i
    rw [← hc, ← h.map_nhds_eq c, mem_map]
    exact mem_of_superset (hB i) (fun x hx => ⟨x, hx, rfl⟩)
  obtain ⟨s, hs, hns⟩ := exists_nhds_zero_not_subset_family (fun i => h '' B i) hBim
  refine ⟨h ⁻¹' s, ?_, fun i hsubset => hns i ?_⟩
  · exact h.continuous.continuousAt.preimage_mem_nhds (by rwa [hc])
  · rintro x ⟨z, hz, rfl⟩
    exact hsubset hz

/-- The countable special case of `exists_nhds_not_subset_family`. -/
theorem exists_nhds_not_subset (c : Surreal.{u}) (B : ℕ → Set Surreal.{u})
    (hB : ∀ n, B n ∈ 𝓝 c) :
    ∃ s ∈ 𝓝 c, ∀ n, ¬ B n ⊆ s := by
  obtain ⟨s, hs, hns⟩ :=
    exists_nhds_not_subset_family c (fun j : ULift.{u} ℕ => B j.down) (fun j => hB j.down)
  exact ⟨s, hs, fun n => hns (ULift.up n)⟩

/-! ## Countably generated neighbourhood filters -/

/-- The neighbourhood filter of any surreal number is **not countably generated**. -/
theorem nhds_not_isCountablyGenerated (c : Surreal.{u}) :
    ¬ (𝓝 c).IsCountablyGenerated := by
  intro hgen
  obtain ⟨B, hB⟩ := (𝓝 c).exists_antitone_basis
  obtain ⟨s, hs, hns⟩ := exists_nhds_not_subset c B (fun n => hB.1.mem_of_mem trivial)
  obtain ⟨n, -, hn⟩ := hB.1.mem_iff.1 hs
  exact hns n hn

/-- **Every neighbourhood basis at every point is uncountable**: the character of each
surreal number is uncountable. -/
theorem not_countable_of_nhds_basis (c : Surreal.{u}) (B : Set (Set Surreal.{u}))
    (hmem : ∀ s ∈ B, s ∈ 𝓝 c) (hbasis : ∀ s ∈ 𝓝 c, ∃ t ∈ B, t ⊆ s) :
    ¬ B.Countable := by
  intro hcount
  have hne : B.Nonempty := by
    obtain ⟨t, ht, -⟩ := hbasis univ univ_mem
    exact ⟨t, ht⟩
  obtain ⟨f, rfl⟩ := hcount.exists_eq_range hne
  obtain ⟨s, hs, hns⟩ := exists_nhds_not_subset c f (fun n => hmem _ (mem_range_self n))
  obtain ⟨t, ⟨n, rfl⟩, ht⟩ := hbasis s hs
  exact hns n ht

/-- **The character of every surreal number exceeds every small cardinal.**  No
neighbourhood basis at any point of `Surreal.{u}` is `Small.{u}`; in particular there is no
neighbourhood basis indexed by a set of size `< ` the number of surreals of any fixed
birthday level. -/
theorem not_small_of_nhds_basis (c : Surreal.{u}) (B : Set (Set Surreal.{u}))
    (hmem : ∀ s ∈ B, s ∈ 𝓝 c) (hbasis : ∀ s ∈ 𝓝 c, ∃ t ∈ B, t ⊆ s) :
    ¬ Small.{u} B := by
  intro hsmall
  have hB : ∀ i : Shrink.{u} B, ((equivShrink B).symm i : Set Surreal.{u}) ∈ 𝓝 c :=
    fun i => hmem _ ((equivShrink B).symm i).2
  obtain ⟨s, hs, hns⟩ :=
    exists_nhds_not_subset_family c (fun i : Shrink.{u} B => ((equivShrink B).symm i : Set _)) hB
  obtain ⟨t, htB, ht⟩ := hbasis s hs
  refine hns (equivShrink B ⟨t, htB⟩) ?_
  simpa using ht

/-! ## Global consequences -/

theorem not_firstCountableTopology : ¬ FirstCountableTopology Surreal.{u} := by
  intro h
  exact nhds_not_isCountablyGenerated 0 (h.nhds_generated_countable 0)

theorem not_secondCountableTopology : ¬ SecondCountableTopology Surreal.{u} := by
  intro h
  haveI := h
  exact not_firstCountableTopology
    (TopologicalSpace.SecondCountableTopology.to_firstCountableTopology Surreal.{u})

theorem not_metrizableSpace : ¬ TopologicalSpace.MetrizableSpace Surreal.{u} := by
  intro h
  haveI := h
  exact not_firstCountableTopology
    (TopologicalSpace.PseudoMetrizableSpace.firstCountableTopology (X := Surreal.{u}))

/-! ## Sequential discreteness -/

/-- **The surreals are sequentially discrete**: a sequence converges in the order
topology if and only if it is eventually constant. -/
theorem tendsto_iff_eventually_eq (f : ℕ → Surreal.{u}) (c : Surreal.{u}) :
    Tendsto f atTop (𝓝 c) ↔ ∀ᶠ n in atTop, f n = c := by
  constructor
  · intro hf
    by_contra hcon
    have hfreq : ∃ᶠ n in atTop, f n ≠ c := by
      rwa [Filter.not_eventually] at hcon
    set d : ℕ → Surreal.{u} := fun n => if f n = c then 1 else |f n - c| with hd
    have hdpos : ∀ n, 0 < d n := by
      intro n
      by_cases h : f n = c
      · simp [hd, h]
      · simp only [hd, if_neg h]
        exact abs_pos.2 (sub_ne_zero.2 h)
    obtain ⟨y, hy0, hy⟩ := exists_pos_lt_seq d hdpos
    have hnhds : Ioo (c - y) (c + y) ∈ 𝓝 c :=
      Ioo_mem_nhds (by simpa using hy0) (by simpa using hy0)
    have heven := hf hnhds
    have : ∀ᶠ n in atTop, f n = c := by
      filter_upwards [heven] with n hn
      by_contra hne
      have h1 : |f n - c| < y := by
        rw [abs_lt]
        constructor
        · linarith [hn.1]
        · linarith [hn.2]
      have h2 : y < |f n - c| := by
        have := hy n
        simpa [hd, if_neg hne] using this
      exact absurd h1 (not_lt.2 h2.le)
    exact hcon this
  · intro h
    exact Tendsto.congr' (by filter_upwards [h] with n hn using hn.symm)
      tendsto_const_nhds

/-- The order topology on the surreals is **not discrete**, since the order is dense. -/
theorem not_discreteTopology : ¬ DiscreteTopology Surreal.{u} := by
  intro h
  have hmem : ({(0 : Surreal.{u})} : Set Surreal.{u}) ∈ 𝓝 (0 : Surreal.{u}) := by
    exact (isOpen_discrete _).mem_nhds rfl
  obtain ⟨l, r, hlr, hsub⟩ := mem_nhds_iff_exists_Ioo_subset.1 hmem
  obtain ⟨z, hz0, hzr⟩ := exists_between hlr.2
  have : z ∈ ({(0 : Surreal.{u})} : Set Surreal.{u}) := hsub ⟨hlr.1.trans hz0, hzr⟩
  simp only [mem_singleton_iff] at this
  exact absurd this (ne_of_gt hz0)

end Surreal