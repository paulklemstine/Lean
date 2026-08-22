import Mathlib

/-!
# The ceiling on transfinite dimension hierarchies

The mission "construct a surface of Hausdorff dimension `ℵ₁`" hides a structural
obstruction, and this file makes that obstruction a theorem rather than a slogan.

Hausdorff dimension takes values in `ℝ≥0∞`.  One could still *hope* to reach `ℵ₁`
indirectly, by exhibiting an `ℵ₁`-long strictly increasing hierarchy of sets

`A₀ ⊊ A₁ ⊊ ⋯ ⊊ A_α ⊊ ⋯   (α < ω₁)`,  with  `dimH A_α` strictly increasing,

and calling the "dimension at level `ω₁`" the `ℵ₁`-st dimension.  We prove this is
impossible: **every well-ordered chain of Hausdorff dimensions is countable.**

The proof is an order-theoretic squeeze.  If `S ⊆ ℝ≥0∞` is well-founded, then each
non-maximal `s ∈ S` has an immediate successor `succ s` in `S`, and the interval
`(s, succ s)` contains a rational.  Distinct elements get distinct rationals, so
`S` injects into `ℚ` up to one exceptional maximum.

## Main results

* `TransfiniteDimensionCeiling.countable_of_isWF` — a well-founded subset of
  `ℝ≥0∞` is countable.
* `TransfiniteDimensionCeiling.isWF_range_of_strictMono` — the range of a strictly
  monotone map from a well-ordered type into `ℝ≥0∞` is well-founded.
* `TransfiniteDimensionCeiling.countable_of_strictMono_dimH` — any well-ordered
  family of sets whose Hausdorff dimensions strictly increase is countable.
* `TransfiniteDimensionCeiling.card_le_continuum_of_strictMono_dimH` — without
  well-foundedness one still gets a hard ceiling of `𝔠` levels.
* `TransfiniteDimensionCeiling.no_uncountable_dimension_hierarchy` and
  `TransfiniteDimensionCeiling.no_aleph_one_dimension_hierarchy` — hence no
  `ℵ₁`-indexed strictly increasing dimension hierarchy exists, in any metric space
  whatsoever.  The `ℵ₁` in "the aleph-one surface" can only be a statement about
  *cardinality of points*, never about dimension.
-/

open Set Cardinal
open scoped ENNReal NNReal

namespace TransfiniteDimensionCeiling

/-- **A well-founded set of extended nonnegative reals is countable.**  Well-founded
means every nonempty subset has a least element; the gaps above successive elements
then carry distinct rationals. -/
theorem countable_of_isWF {S : Set ℝ≥0∞} (hS : S.IsWF) : S.Countable := by
  classical
  set A : Set ℝ≥0∞ := {s | s ∈ S ∧ ∃ t ∈ S, s < t} with hAdef
  have hAS : A ⊆ S := fun _ hs => hs.1
  -- Between `s ∈ A` and its immediate successor in `S` we can insert a rational,
  -- which is then `≤` every element of `S` above `s`.
  have key : ∀ s ∈ A, ∃ q : ℚ, s < (((q : ℝ)).toNNReal : ℝ≥0∞) ∧
      ∀ t ∈ S, s < t → (((q : ℝ)).toNNReal : ℝ≥0∞) ≤ t := by
    rintro s ⟨hsS, t0, ht0S, hst0⟩
    have hne : {t | t ∈ S ∧ s < t}.Nonempty := ⟨t0, ht0S, hst0⟩
    have hwf : {t | t ∈ S ∧ s < t}.IsWF := hS.mono fun t ht => ht.1
    have hmmem := hwf.min_mem hne
    obtain ⟨q, _, hq1, hq2⟩ := ENNReal.lt_iff_exists_rat_btwn.1 hmmem.2
    refine ⟨q, hq1, fun t htS hst => ?_⟩
    have hnot : ¬ t < hwf.min hne := hwf.not_lt_min hne ⟨htS, hst⟩
    exact hq2.le.trans (not_lt.1 hnot)
  have hAcount : A.Countable := by
    choose F hF1 hF2 using key
    have hinj : Function.Injective fun a : A => F a.1 a.2 := by
      intro a b hab
      by_contra hne
      have hne' : a.1 ≠ b.1 := fun h => hne (Subtype.ext h)
      -- in either order the rationals are separated, contradicting `hab`
      have main : ∀ u v : A, u.1 < v.1 →
          (((F u.1 u.2 : ℝ)).toNNReal : ℝ≥0∞) < (((F v.1 v.2 : ℝ)).toNNReal : ℝ≥0∞) := by
        intro u v huv
        exact lt_of_le_of_lt (hF2 u.1 u.2 v.1 (hAS v.2) huv) (hF1 v.1 v.2)
      have hFab : F a.1 a.2 = F b.1 b.2 := hab
      rcases lt_trichotomy a.1 b.1 with h | h | h
      · have hlt := main a b h
        rw [hFab] at hlt
        exact lt_irrefl _ hlt
      · exact hne' h
      · have hlt := main b a h
        rw [hFab] at hlt
        exact lt_irrefl _ hlt
    exact Set.countable_coe_iff.1 (Countable.of_equiv _ (Equiv.ofInjective _ hinj).symm)
  have hrest : (S \ A).Subsingleton := by
    intro s hs t ht
    by_contra hne
    rcases lt_or_gt_of_ne hne with h | h
    · exact hs.2 ⟨hs.1, t, ht.1, h⟩
    · exact ht.2 ⟨ht.1, s, hs.1, h⟩
  have : S = A ∪ (S \ A) := by
    ext x
    constructor
    · intro hx
      by_cases h : x ∈ A
      · exact Or.inl h
      · exact Or.inr ⟨hx, h⟩
    · rintro (hx | hx)
      · exact hAS hx
      · exact hx.1
  rw [this]
  exact hAcount.union hrest.countable

/-- The range of a strictly monotone map from a well-ordered type into `ℝ≥0∞` is
well-founded. -/
theorem isWF_range_of_strictMono {ι : Type*} [LinearOrder ι] [WellFoundedLT ι]
    {f : ι → ℝ≥0∞} (hf : StrictMono f) : (range f).IsWF := by
  rw [Set.isWF_iff_no_descending_seq]
  intro g hg hmem
  choose h hh using fun n => hmem n
  have hanti : StrictAnti h := by
    intro m n hmn
    have : f (h n) < f (h m) := by rw [hh m, hh n]; exact hg hmn
    exact hf.lt_iff_lt.1 this
  have huniv : (univ : Set ι).IsWF := isWF_univ_iff.mpr (by infer_instance)
  exact (Set.isWF_iff_no_descending_seq.1 huniv) h hanti fun _ => mem_univ _

/-- **Well-ordered chains of Hausdorff dimensions are countable.**  If the sets
`A i` have strictly increasing Hausdorff dimension along a well-ordered index type,
the index type is countable. -/
theorem countable_of_strictMono_dimH {X : Type*} [EMetricSpace X] {ι : Type*}
    [LinearOrder ι] [WellFoundedLT ι] (A : ι → Set X)
    (hmono : StrictMono fun i => dimH (A i)) : Countable ι := by
  have hrange : (range fun i => dimH (A i)).Countable :=
    countable_of_isWF (isWF_range_of_strictMono hmono)
  have : Countable (range fun i => dimH (A i)) := Set.countable_coe_iff.2 hrange
  exact Countable.of_equiv _ (Equiv.ofInjective _ hmono.injective).symm

/-- **No uncountable dimension hierarchy.**  There is no strictly increasing,
well-ordered, uncountable hierarchy of Hausdorff dimensions in any metric space. -/
theorem no_uncountable_dimension_hierarchy {X : Type*} [EMetricSpace X] {ι : Type}
    [LinearOrder ι] [WellFoundedLT ι] (A : ι → Set X)
    (hmono : StrictMono fun i => dimH (A i)) (hcard : ℵ₀ < #ι) : False := by
  haveI := countable_of_strictMono_dimH A hmono
  exact absurd (Cardinal.mk_le_aleph0 (α := ι)) (not_le.2 hcard)

/-- **"Hausdorff dimension `ℵ₁`" is unreachable even as a limit of a hierarchy.**
No `ℵ₁`-indexed well-ordered family of sets has strictly increasing Hausdorff
dimension; the transfinite content of the aleph-one surface must therefore live in
its *cardinality* (`ℵ₁` points under CH) and in the single value `dimH = ⊤`. -/
theorem no_aleph_one_dimension_hierarchy {X : Type*} [EMetricSpace X] {ι : Type}
    [LinearOrder ι] [WellFoundedLT ι] (A : ι → Set X)
    (hmono : StrictMono fun i => dimH (A i)) (hcard : #ι = aleph 1) : False :=
  no_uncountable_dimension_hierarchy A hmono
    (by rw [hcard]; simpa using Cardinal.aleph0_lt_aleph_one)

/-- By contrast, *countably* long strictly increasing dimension hierarchies exist in
abundance: the dimensions `0, 1, 2, …` are realised in `ℝ≥0∞`, so the ceiling above
is sharp at `ℵ₀`. -/
theorem exists_omega_chain : StrictMono fun n : ℕ => (n : ℝ≥0∞) := by
  intro m n h
  show (m : ℝ≥0∞) < (n : ℝ≥0∞)
  exact_mod_cast h

/-- There are at most continuum many extended nonnegative reals. -/
theorem mk_ennreal_le_continuum : #(ℝ≥0∞) ≤ 𝔠 := by
  have h1 : #(ℝ≥0∞) = #(Option (ℝ≥0)) := rfl
  rw [h1, mk_option]
  have h2 : #(ℝ≥0) ≤ 𝔠 := by
    have : #(ℝ≥0) ≤ #ℝ := mk_subtype_le _
    simpa [Cardinal.mk_real] using this
  calc #(ℝ≥0) + 1 ≤ 𝔠 + 𝔠 := add_le_add h2 (one_le_aleph0.trans aleph0_le_continuum)
    _ = 𝔠 := add_eq_self aleph0_le_continuum

/-- **Continuum ceiling.**  Dropping well-foundedness of the index order, a strictly
increasing hierarchy of Hausdorff dimensions can still never have more than `𝔠` levels,
because the dimension map is then injective into `ℝ≥0∞`.  Together with
`countable_of_strictMono_dimH` this brackets every dimension hierarchy: at most `ℵ₀` levels
when the index order is well-founded, and at most `𝔠` levels for an arbitrary linear order.
Since `ℵ₁ ≤ 𝔠`, the second bound alone does not forbid `ℵ₁` levels along a non-well-ordered
index; it is well-foundedness — the shape an ordinal hierarchy must have — that collapses the
length to countable. -/
theorem card_le_continuum_of_strictMono_dimH {X : Type*} [EMetricSpace X] {ι : Type}
    [LinearOrder ι] (A : ι → Set X) (hmono : StrictMono fun i => dimH (A i)) : #ι ≤ 𝔠 :=
  (mk_le_of_injective hmono.injective).trans mk_ennreal_le_continuum

end TransfiniteDimensionCeiling