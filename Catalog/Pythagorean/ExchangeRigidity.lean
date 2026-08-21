/-
# Rigidity: what the aggregator, and what its cell complex, remember

Cycle 3 of the single-voter exchange programme.  Cycles 1 and 2 described the
geometry of a fixed min-plus aggregator `F x = min_{i ∈ S} (x i + δ i)`.  Here
we ask the inverse question: *how much of the data `(S, δ) `can be recovered
from the geometry?*  The answer is a clean dichotomy, both halves proved below.

* **Functional rigidity** (`support_eq_of_tropAgg_eq`, `weights_eq_of_tropAgg_eq`,
  `tropAgg_rigidity`).  The aggregator, *as a function on profiles*, remembers
  everything: if two min-plus aggregators agree as functions then their supports
  coincide and their weights coincide on the support.  No monomial of a min-plus
  aggregator is redundant, because every voter of the support is decisive
  somewhere.  This is the min-plus analogue of "a tropical polynomial with only
  essential monomials is determined by the function it defines".

* **Combinatorial rigidity** (`support_eq_of_decisiveSet_eq`,
  `sub_const_of_decisiveSet_eq`, `decisiveSet_add_const`,
  `decisiveSet_eq_iff_sub_const`).  The *cell labelling* remembers strictly
  less: it determines the support exactly, and it determines the weights exactly
  up to one global additive constant — and no more, since shifting all weights
  by a constant leaves every decisive coalition unchanged.  So the fibres of the
  map `δ ↦ (chamber complex)` are precisely the lines `δ + ℝ·1`.

The two statements together say: the chamber complex of the exchange law is a
complete invariant of the electorate modulo the one obvious gauge freedom, and
the numerical aggregator rigidifies that gauge.
-/
import Mathlib
import Tropical.SocialChoice.SupportMatroid
import Pythagorean.ExchangeLawSharp

namespace PythagoreanExchangeRigidity

open Finset TropicalChambers TropicalChamberComplex TropicalSupportMatroid
open PythagoreanExchangeLaw

variable {ι : Type*}

/-! ## Evaluating an aggregator on a one-voter spike -/

/-- The value of the aggregator on the profile that is `0` everywhere except at
the single voter `i`, whose score `c` is low enough to win outright. -/
theorem tropAgg_spike [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {i : ι} (hiS : i ∈ S) {c : ℝ} (hc : ∀ k ∈ S, c + δ i ≤ δ k) :
    tropAgg S hS δ (Function.update (0 : ι → ℝ) i c) = c + δ i := by
  classical
  set x : ι → ℝ := Function.update (0 : ι → ℝ) i c with hx
  have hxi : x i = c := by simp [hx]
  have hxk : ∀ k, k ≠ i → x k = 0 := fun k hk => by
    simp [hx, Function.update_of_ne hk]
  refine le_antisymm ?_ ?_
  · have := Finset.inf'_le (fun k => x k + δ k) hiS
    simpa [tropAgg, hxi] using this
  · refine Finset.le_inf' hS _ ?_
    intro k hk
    by_cases hki : k = i
    · subst hki; rw [hxi]
    · rw [hxk k hki, zero_add]
      exact hc k hk

/-- If a voter is *outside* the support, its own score is invisible: the
aggregator evaluated on a spike at that voter equals its value at the origin. -/
theorem tropAgg_spike_of_notMem [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ)
    {i : ι} (hiS : i ∉ S) (c : ℝ) :
    tropAgg S hS δ (Function.update (0 : ι → ℝ) i c) = tropAgg S hS δ (0 : ι → ℝ) := by
  classical
  refine Finset.inf'_congr hS rfl ?_
  intro k hk
  have hki : k ≠ i := fun h => hiS (h ▸ hk)
  simp [Function.update_of_ne hki]

/-! ## Functional rigidity: the aggregator determines the electorate -/

/-- **The support is determined by the aggregator.**  A voter outside the second
support could drive the first aggregator arbitrarily low while leaving the
second one fixed. -/
theorem support_eq_of_tropAgg_eq [DecidableEq ι] {S S' : Finset ι} (hS : S.Nonempty)
    (hS' : S'.Nonempty) (δ δ' : ι → ℝ)
    (h : tropAgg S hS δ = tropAgg S' hS' δ') : S = S' := by
  classical
  have key : ∀ (A A' : Finset ι) (hA : A.Nonempty) (hA' : A'.Nonempty) (η η' : ι → ℝ),
      tropAgg A hA η = tropAgg A' hA' η' → A ⊆ A' := by
    intro A A' hA hA' η η' hfun i hiA
    by_contra hiA'
    set c : ℝ := tropAgg A' hA' η' (0 : ι → ℝ) - η i - 1 with hc
    set x : ι → ℝ := Function.update (0 : ι → ℝ) i c with hx
    have h1 : tropAgg A hA η x ≤ c + η i := by
      have := Finset.inf'_le (fun k => x k + η k) hiA
      simpa [tropAgg, hx] using this
    have h2 : tropAgg A' hA' η' x = tropAgg A' hA' η' (0 : ι → ℝ) :=
      tropAgg_spike_of_notMem hA' η' hiA' c
    have h3 : tropAgg A hA η x = tropAgg A' hA' η' x := by rw [hfun]
    rw [h2] at h3
    rw [h3] at h1
    simp only [hc] at h1
    linarith
  exact Finset.Subset.antisymm (key S S' hS hS' δ δ' h) (key S' S hS' hS δ' δ h.symm)

/-- **The weights are determined by the aggregator.**  Driving a single voter's
score far down isolates its own weight. -/
theorem weights_eq_of_tropAgg_eq [DecidableEq ι] {S S' : Finset ι} (hS : S.Nonempty)
    (hS' : S'.Nonempty) (δ δ' : ι → ℝ) (h : tropAgg S hS δ = tropAgg S' hS' δ')
    {i : ι} (hiS : i ∈ S) : δ i = δ' i := by
  classical
  have hSS' : S = S' := support_eq_of_tropAgg_eq hS hS' δ δ' h
  subst hSS'
  set L : ℝ := min (S.inf' hS δ) (S.inf' hS δ') with hL
  set c : ℝ := L - 1 - max (δ i) (δ' i) with hc
  have hci : ∀ k ∈ S, c + δ i ≤ δ k := by
    intro k hk
    have h1 : L ≤ δ k := le_trans (min_le_left _ _) (Finset.inf'_le δ hk)
    have h2 : δ i ≤ max (δ i) (δ' i) := le_max_left _ _
    simp only [hc]
    linarith
  have hci' : ∀ k ∈ S, c + δ' i ≤ δ' k := by
    intro k hk
    have h1 : L ≤ δ' k := le_trans (min_le_right _ _) (Finset.inf'_le δ' hk)
    have h2 : δ' i ≤ max (δ i) (δ' i) := le_max_right _ _
    simp only [hc]
    linarith
  have e1 := tropAgg_spike hS δ hiS hci
  have e2 := tropAgg_spike hS δ' hiS hci'
  have := congrFun h (Function.update (0 : ι → ℝ) i c)
  rw [e1, e2] at this
  linarith

/-- **Functional rigidity of min-plus aggregators.**  Two min-plus aggregators
define the same function on profiles only if they have the same electorate and
the same weights on it: no monomial is redundant. -/
theorem tropAgg_rigidity [DecidableEq ι] {S S' : Finset ι} (hS : S.Nonempty)
    (hS' : S'.Nonempty) (δ δ' : ι → ℝ) (h : tropAgg S hS δ = tropAgg S' hS' δ') :
    S = S' ∧ ∀ i ∈ S, δ i = δ' i :=
  ⟨support_eq_of_tropAgg_eq hS hS' δ δ' h,
    fun _ hi => weights_eq_of_tropAgg_eq hS hS' δ δ' h hi⟩

/-! ## Combinatorial rigidity: what the cell complex remembers -/

/-- Shifting all the weights by a constant does not move any wall: the cell
labelling is invariant under the gauge `δ ↦ δ + c`. -/
theorem decisiveSet_add_const {S : Finset ι} (hS : S.Nonempty) (δ : ι → ℝ) (c : ℝ)
    (x : ι → ℝ) :
    decisiveSet S hS (fun k => δ k + c) x = decisiveSet S hS δ x := by
  classical
  have hagg : tropAgg S hS (fun k => δ k + c) x = tropAgg S hS δ x + c := by
    refine le_antisymm ?_ ?_
    · obtain ⟨m, hmS, hm⟩ := Finset.exists_mem_eq_inf' hS (fun k => x k + δ k)
      have hle : tropAgg S hS (fun k => δ k + c) x ≤ x m + (δ m + c) :=
        Finset.inf'_le (fun k => x k + (δ k + c)) hmS
      have : tropAgg S hS δ x = x m + δ m := hm
      linarith
    · refine Finset.le_inf' hS _ ?_
      intro k hk
      have : tropAgg S hS δ x ≤ x k + δ k := Finset.inf'_le (fun m => x m + δ m) hk
      linarith
  ext k
  simp only [mem_decisiveSet_iff, hagg]
  constructor
  · rintro ⟨hkS, hk⟩; exact ⟨hkS, by linarith⟩
  · rintro ⟨hkS, hk⟩; exact ⟨hkS, by linarith⟩

/-- **The cell labelling determines the support.**  Every voter of the support
labels a top-dimensional cell all by itself. -/
theorem support_eq_of_decisiveSet_eq {S S' : Finset ι} (hS : S.Nonempty) (hS' : S'.Nonempty)
    (δ δ' : ι → ℝ) (h : ∀ x, decisiveSet S hS δ x = decisiveSet S' hS' δ' x) : S = S' := by
  classical
  have key : ∀ (A A' : Finset ι) (hA : A.Nonempty) (hA' : A'.Nonempty) (η η' : ι → ℝ),
      (∀ x, decisiveSet A hA η x = decisiveSet A' hA' η' x) → A ⊆ A' := by
    intro A A' hA hA' η η' hfun i hiA
    obtain ⟨x, hx⟩ := exists_decisiveSet_eq hA η (Finset.singleton_subset_iff.mpr hiA)
      ⟨i, Finset.mem_singleton_self i⟩
    have hi : i ∈ decisiveSet A' hA' η' x := by
      rw [← hfun x, hx]; exact Finset.mem_singleton_self i
    exact (mem_decisiveSet_iff.mp hi).1
  exact Finset.Subset.antisymm (key S S' hS hS' δ δ' h)
    (key S' S hS' hS δ' δ (fun x => (h x).symm))

/-- **The cell labelling determines the weights up to one constant.**  If two
weight systems induce the same decisive coalitions, their difference is constant
on the support. -/
theorem sub_const_of_decisiveSet_eq [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ δ' : ι → ℝ) (h : ∀ x, decisiveSet S hS δ x = decisiveSet S hS δ' x)
    {i j : ι} (hiS : i ∈ S) (hjS : j ∈ S) : δ i - δ' i = δ j - δ' j := by
  classical
  obtain ⟨x, hx⟩ := exists_decisiveSet_pair hS δ hiS hjS
  have hx' : decisiveSet S hS δ' x = {i, j} := by rw [← h x, hx]
  have h1 : x i + δ i = x j + δ j := by
    refine eq_on_closedCell (S := S) (hS := hS) (δ := δ) (T := ({i, j} : Finset ι))
      (x := x) ?_ (by simp) (by simp)
    show ({i, j} : Finset ι) ⊆ decisiveSet S hS δ x
    rw [hx]
  have h2 : x i + δ' i = x j + δ' j := by
    refine eq_on_closedCell (S := S) (hS := hS) (δ := δ') (T := ({i, j} : Finset ι))
      (x := x) ?_ (by simp) (by simp)
    show ({i, j} : Finset ι) ⊆ decisiveSet S hS δ' x
    rw [hx']
  linarith

/-- **Combinatorial rigidity, in both directions.**  Two weight systems on the
same electorate induce the same chamber complex if and only if they differ by a
single global constant on the support.  The gauge group of the exchange geometry
is exactly the additive line `ℝ·1`. -/
theorem decisiveSet_eq_iff_sub_const [DecidableEq ι] {S : Finset ι} (hS : S.Nonempty)
    (δ δ' : ι → ℝ) :
    (∀ x, decisiveSet S hS δ x = decisiveSet S hS δ' x)
      ↔ ∃ c : ℝ, ∀ k ∈ S, δ k = δ' k + c := by
  classical
  constructor
  · intro h
    obtain ⟨i₀, hi₀⟩ := id hS
    refine ⟨δ i₀ - δ' i₀, fun k hk => ?_⟩
    have := sub_const_of_decisiveSet_eq hS δ δ' h hk hi₀
    linarith
  · rintro ⟨c, hc⟩ x
    have hshift : ∀ k ∈ S, δ k = (fun m => δ' m + c) k := fun k hk => hc k hk
    have hagg : decisiveSet S hS δ x = decisiveSet S hS (fun m => δ' m + c) x := by
      have hcongr : ∀ (η η' : ι → ℝ), (∀ k ∈ S, η k = η' k) →
          decisiveSet S hS η x = decisiveSet S hS η' x := by
        intro η η' heq
        have haggeq : tropAgg S hS η x = tropAgg S hS η' x :=
          Finset.inf'_congr hS rfl (fun k hk => by rw [heq k hk])
        ext k
        simp only [mem_decisiveSet_iff, haggeq]
        constructor
        · rintro ⟨hkS, hk⟩; exact ⟨hkS, by rw [← heq k hkS]; exact hk⟩
        · rintro ⟨hkS, hk⟩; exact ⟨hkS, by rw [heq k hkS]; exact hk⟩
      exact hcongr δ (fun m => δ' m + c) hshift
    rw [hagg, decisiveSet_add_const hS δ' c x]

end PythagoreanExchangeRigidity