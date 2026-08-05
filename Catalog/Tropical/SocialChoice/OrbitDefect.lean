/-
# The anonymity defect of a tropical aggregator: an exact orbit count

This file makes the quantitative half of the anonymity/independence conjecture
precise and proves it, in exact (not merely asymptotic) form.

Fix a finite electorate `ι` with `n = |ι|` voters and a min-plus aggregator
`F x = min_{i ∈ S} (x i + δ i)` with irredundant tropical support `S` of size
`k`.  Relabelling the electorate moves `S` through its **orbit**, which is
exactly the family of all `k`-element coalitions, of cardinality `binom(n, k)`
(`orbit_eq_powersetCard`, `card_orbit`).  Among these, only `S` itself is a
dependence (decisive) set of `F` (`decisive_in_orbit`,
`dependence_in_orbit_eq_singleton`).  Hence the aggregator fails coalition
decisiveness on exactly a proportion

`1 - 1 / binom(n, k)`

of the orbit of its minimal dependence set (`defect_card`, `defect_ratio`,
`dependence_defect_ratio`), and the bound is an equality, so it is sharp.

The dependence sets are imported from `Tropical/SocialChoice/TropicalArrow.lean`
via `dependence_eq_principal`.
-/
import Mathlib
import Tropical.SocialChoice.TropicalArrow

namespace TropicalOrbitDefect

open Finset

variable {ι : Type*} [DecidableEq ι] [Fintype ι]

/-- The orbit of a coalition under relabellings of the electorate, described
combinatorially as the coalitions of the same size. -/
def orbit (S : Finset ι) : Finset (Finset ι) :=
  Finset.univ.filter fun T => T.card = S.card

omit [DecidableEq ι] in
@[simp] lemma mem_orbit_iff {S T : Finset ι} : T ∈ orbit S ↔ T.card = S.card := by
  simp [orbit]

omit [DecidableEq ι] in
/-- The orbit of `S` is the family of all coalitions of size `|S|`. -/
theorem orbit_eq_powersetCard (S : Finset ι) :
    orbit S = Finset.univ.powersetCard S.card := by
  ext T
  simp [mem_orbit_iff, Finset.mem_powersetCard, Finset.subset_univ, eq_comm]

omit [DecidableEq ι] in
/-- The orbit has `binom(n, k)` members, `n` the number of voters and `k = |S|`. -/
theorem card_orbit (S : Finset ι) :
    (orbit S).card = (Fintype.card ι).choose S.card := by
  rw [orbit_eq_powersetCard, Finset.card_powersetCard, Finset.card_univ]

/-- The orbit really is a permutation orbit: any two coalitions of the same size
are exchanged by a relabelling of the electorate. -/
theorem mem_orbit_iff_exists_perm {S T : Finset ι} :
    T ∈ orbit S ↔ ∃ σ : Equiv.Perm ι, S.image σ = T := by
  classical
  constructor
  · intro hT
    have hcard : S.card = T.card := (mem_orbit_iff.mp hT).symm
    set e : {x // x ∈ S} ≃ {x // x ∈ T} := Finset.equivOfCardEq hcard with he
    refine ⟨e.extendSubtype, ?_⟩
    have hsub : S.image e.extendSubtype ⊆ T := by
      intro y hy
      obtain ⟨a, haS, hay⟩ := Finset.mem_image.mp hy
      have : e.extendSubtype a = ↑(e ⟨a, haS⟩) :=
        Equiv.extendSubtype_apply_of_mem e a haS
      rw [this] at hay
      exact hay ▸ (e ⟨a, haS⟩).2
    have hcard' : (S.image e.extendSubtype).card = T.card := by
      rw [Finset.card_image_of_injective _ e.extendSubtype.injective, hcard]
    exact Finset.eq_of_subset_of_card_le hsub (le_of_eq hcard'.symm)
  · rintro ⟨σ, rfl⟩
    rw [mem_orbit_iff, Finset.card_image_of_injective _ σ.injective]

/-- **Only one coalition in the whole orbit is decisive.**  Among the `binom(n,k)`
relabellings of the support, the support itself is the unique one that contains
the support, i.e. the unique dependence set. -/
theorem decisive_in_orbit (S : Finset ι) :
    (orbit S).filter (fun T => S ⊆ T) = {S} := by
  ext T
  simp only [Finset.mem_filter, mem_orbit_iff, Finset.mem_singleton]
  constructor
  · rintro ⟨hcard, hsub⟩
    exact (Finset.eq_of_subset_of_card_le hsub (le_of_eq hcard)).symm
  · rintro rfl
    exact ⟨rfl, Finset.Subset.refl _⟩

/-- The number of coalitions in the orbit that are **not** decisive is
`binom(n, k) - 1`. -/
theorem defect_card (S : Finset ι) :
    ((orbit S).filter (fun T => ¬ S ⊆ T)).card = (Fintype.card ι).choose S.card - 1 := by
  classical
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := orbit S) (p := fun T => S ⊆ T)
  rw [decisive_in_orbit S, Finset.card_singleton, card_orbit S] at hsplit
  omega

/-- **Exact anonymity defect.**  The proportion of the orbit of the minimal
dependence set on which the aggregator is not decisive equals
`1 - 1 / binom(n, k)`.  Being an equality, the bound is sharp. -/
theorem defect_ratio (S : Finset ι) :
    (((orbit S).filter (fun T => ¬ S ⊆ T)).card : ℝ) / ((orbit S).card : ℝ)
      = 1 - 1 / ((Fintype.card ι).choose S.card : ℝ) := by
  classical
  have hkle : S.card ≤ Fintype.card ι := by
    simpa [Finset.card_univ] using Finset.card_le_card (Finset.subset_univ S)
  have hpos : 0 < (Fintype.card ι).choose S.card := Nat.choose_pos hkle
  have hne : ((Fintype.card ι).choose S.card : ℝ) ≠ 0 := by positivity
  rw [defect_card S, card_orbit S]
  have h1 : (((Fintype.card ι).choose S.card - 1 : ℕ) : ℝ)
      = ((Fintype.card ι).choose S.card : ℝ) - 1 := by
    have : 1 ≤ (Fintype.card ι).choose S.card := hpos
    push_cast [Nat.cast_sub this]
    ring
  rw [h1]
  field_simp

omit [Fintype ι] in
/-- Membership in the dependence family is, for coalitions, containment of the
tropical support. -/
theorem mem_dependence_iff_subset {F : (ι → ℝ) → ℝ} {S : Finset ι} {hS : S.Nonempty}
    {δ : ι → ℝ} (hnn : ∀ i ∈ S, 0 ≤ δ i) (hzero : S.inf' hS δ = 0)
    (hF : ∀ x, F x = S.inf' hS fun i => x i + δ i) (T : Finset ι) :
    (↑T : Set ι) ∈ TropicalSocialChoice.Dependence F ↔ S ⊆ T := by
  rw [TropicalSocialChoice.dependence_eq_principal hnn hzero hF]
  simp [Set.subset_def, Finset.subset_iff]

theorem filter_dependence_eq {F : (ι → ℝ) → ℝ} {S : Finset ι} {hS : S.Nonempty}
    {δ : ι → ℝ} (hnn : ∀ i ∈ S, 0 ≤ δ i) (hzero : S.inf' hS δ = 0)
    (hF : ∀ x, F x = S.inf' hS fun i => x i + δ i)
    [DecidablePred fun T : Finset ι => (↑T : Set ι) ∈ TropicalSocialChoice.Dependence F] :
    (orbit S).filter (fun T : Finset ι => (↑T : Set ι) ∈ TropicalSocialChoice.Dependence F)
      = (orbit S).filter (fun T => S ⊆ T) :=
  Finset.filter_congr fun T _ => by
    simpa using mem_dependence_iff_subset hnn hzero hF T

theorem filter_not_dependence_eq {F : (ι → ℝ) → ℝ} {S : Finset ι} {hS : S.Nonempty}
    {δ : ι → ℝ} (hnn : ∀ i ∈ S, 0 ≤ δ i) (hzero : S.inf' hS δ = 0)
    (hF : ∀ x, F x = S.inf' hS fun i => x i + δ i)
    [DecidablePred fun T : Finset ι => (↑T : Set ι) ∉ TropicalSocialChoice.Dependence F] :
    (orbit S).filter (fun T : Finset ι => (↑T : Set ι) ∉ TropicalSocialChoice.Dependence F)
      = (orbit S).filter (fun T => ¬ S ⊆ T) :=
  Finset.filter_congr fun T _ => by
    simpa using not_congr (mem_dependence_iff_subset hnn hzero hF T)

/-- The same statement in terms of the dependence sets of the aggregator itself:
of the `binom(n, k)` coalitions in the orbit of the tropical support, exactly one
is a dependence set of `F`. -/
theorem dependence_in_orbit_eq_singleton {F : (ι → ℝ) → ℝ} {S : Finset ι} {hS : S.Nonempty}
    {δ : ι → ℝ} (hnn : ∀ i ∈ S, 0 ≤ δ i) (hzero : S.inf' hS δ = 0)
    (hF : ∀ x, F x = S.inf' hS fun i => x i + δ i)
    [DecidablePred fun T : Finset ι => (↑T : Set ι) ∈ TropicalSocialChoice.Dependence F] :
    (orbit S).filter (fun T : Finset ι => (↑T : Set ι) ∈ TropicalSocialChoice.Dependence F) = {S} := by
  classical
  rw [filter_dependence_eq hnn hzero hF, decisive_in_orbit S]

/-- **Quantitative anonymity–independence tradeoff.**  For a normalized tropical
aggregator with irredundant support of size `k` on an electorate of `n` voters,
the proportion of the orbit of its minimal dependence set consisting of
coalitions that are *not* dependence sets is exactly `1 - 1 / binom(n, k)`. -/
theorem dependence_defect_ratio {F : (ι → ℝ) → ℝ} {S : Finset ι} {hS : S.Nonempty}
    {δ : ι → ℝ} (hnn : ∀ i ∈ S, 0 ≤ δ i) (hzero : S.inf' hS δ = 0)
    (hF : ∀ x, F x = S.inf' hS fun i => x i + δ i)
    [DecidablePred fun T : Finset ι => (↑T : Set ι) ∉ TropicalSocialChoice.Dependence F] :
    (((orbit S).filter
        (fun T : Finset ι => (↑T : Set ι) ∉ TropicalSocialChoice.Dependence F)).card : ℝ)
        / ((orbit S).card : ℝ)
      = 1 - 1 / ((Fintype.card ι).choose S.card : ℝ) := by
  classical
  rw [filter_not_dependence_eq hnn hzero hF]
  exact defect_ratio S

end TropicalOrbitDefect