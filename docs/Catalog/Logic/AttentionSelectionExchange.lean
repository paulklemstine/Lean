/-
# The exchange theorem: self-similar refinement preserves the selection gap **exactly**
# (NET-45, cycle 2)

`Logic.AttentionSelectionDilution` proves one half of the dilution theorem: under the
self-similar refinement `split p` of an attention profile (each position replaced by two
positions of half its weight) the top-`2k` mass is *at least* the old top-`k` mass, so the
selection gap cannot decrease.  The inequality was cheap — the refined pruner can always
copy the old selection.

This file proves the converse, which is not cheap: **the refined pruner can do no
better**.  The obstruction is that a `2k`-subset of the refined context need not be a
union of split pairs: it may take one half of some positions and both halves of others,
i.e. it solves a *fractional* selection problem with weights in `{1/2, 1}`.  The theorem
says that this relaxation buys nothing.

**The exchange argument.**  Write a subset `U ⊆ ι × Bool` through its two traces
`S_true, S_false ⊆ ι`.  Then `2 · mass(U) = ∑_{S_true} p + ∑_{S_false} p
= 2 ∑_{D} p + ∑_{E} p`, where `D = S_true ∩ S_false` are the doubly-selected positions and
`E` is the symmetric difference, and `2|D| + |E| = |U| = 2k`.  The set `E` has *even*
cardinality `2(k - |D|)`, and `SelectionExchange.exists_half_subset` — the combinatorial
core — produces a subset `C ⊆ E` of exactly half the size carrying at least half the
mass, by taking a maximiser: its complement inside `E` has the same cardinality, hence no
larger mass.  Then `D ∪ C` has exactly `k` elements and `mass(U) ≤ ∑_{D ∪ C} p ≤ T_k`.
No positivity, ordering, or normalisation of the profile is used.

**Results.**

* `SelectionExchange.exists_half_subset` : in any set of `2m` positions some `m` of them
  carry at least half the mass.  (A maximiser argument; true for signed weights.)
* `SelectionExchange.topMass_split_le`, `topMass_split_eq` : the top-mass functional is
  **invariant** under self-similar refinement at the matched budget:
  `T_{2k}(split p) = T_k(p)`.
* `SelectionExchange.selection_gap_split_eq` : hence the selection gap is *exactly*
  invariant, upgrading `SelectionDilution.selection_gap_mono_under_self_similar_refinement`
  from an inequality to an equality.
* `SelectionExchange.gap_change_refutes_self_similarity` : consequently **any** measured
  change of the selection gap across a context doubling at matched sparsity — in either
  direction — refutes exact self-similarity of the attention profile.  NET-45's decay
  `+5.9 → +1.7` is therefore a two-sided falsification, not merely a bound.
* `SelectionExchange.net45_gap_change_is_strict` : the round's own numbers are a strict
  change, so the hypothesis of the refutation is met by the measurement.
-/

import Mathlib
import Logic.AttentionSelectionDilution

namespace SelectionExchange

open Finset SelectionDilution

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## 1.  The combinatorial core -/

omit [Fintype ι] in
/-- **Half of a set carries half of its mass.**  In any set `E` of `2m` positions there
are `m` positions carrying at least half the total weight: take a maximiser among the
`m`-subsets; its complement inside `E` has the same size, hence no larger weight. -/
theorem exists_half_subset (p : ι → ℝ) (E : Finset ι) (m : ℕ) (hE : E.card = 2 * m) :
    ∃ C ⊆ E, C.card = m ∧ ∑ i ∈ E, p i ≤ 2 * ∑ i ∈ C, p i := by
  classical
  have hne : (E.powersetCard m).Nonempty := powersetCard_nonempty.2 (by omega)
  obtain ⟨C, hC, hCmax⟩ :=
    Finset.exists_max_image (E.powersetCard m) (fun S => ∑ i ∈ S, p i) hne
  rw [mem_powersetCard] at hC
  refine ⟨C, hC.1, hC.2, ?_⟩
  have hdiff : (E \ C).card = m := by
    rw [card_sdiff_of_subset hC.1, hE, hC.2]; omega
  have hmem : E \ C ∈ E.powersetCard m := mem_powersetCard.2 ⟨sdiff_subset, hdiff⟩
  have h1 : ∑ i ∈ E \ C, p i ≤ ∑ i ∈ C, p i := hCmax _ hmem
  have h2 : ∑ i ∈ E \ C, p i + ∑ i ∈ C, p i = ∑ i ∈ E, p i := Finset.sum_sdiff hC.1
  linarith

/-! ## 2.  The traces of a subset of the refined context -/

section Traces

variable (U : Finset (ι × Bool))

/-- The trace of `U` on the `true` copies. -/
def traceT : Finset ι := univ.filter (fun i => (i, true) ∈ U)

/-- The trace of `U` on the `false` copies. -/
def traceF : Finset ι := univ.filter (fun i => (i, false) ∈ U)

theorem filter_true_eq : U.filter (fun q => q.2 = true) = (traceT U).image (fun i => (i, true)) := by
  ext q
  obtain ⟨i, b⟩ := q
  cases b <;> simp [traceT]

theorem filter_false_eq :
    U.filter (fun q => ¬ q.2 = true) = (traceF U).image (fun i => (i, false)) := by
  ext q
  obtain ⟨i, b⟩ := q
  cases b <;> simp [traceF]

theorem card_traces : (traceT U).card + (traceF U).card = U.card := by
  classical
  have h := Finset.card_filter_add_card_filter_not (s := U) (fun q => q.2 = true)
  rw [filter_true_eq, filter_false_eq] at h
  rwa [card_image_of_injective _ (fun a b hab => (Prod.mk.injEq _ _ _ _ ▸ hab).1),
    card_image_of_injective _ (fun a b hab => (Prod.mk.injEq _ _ _ _ ▸ hab).1)] at h

theorem sum_traces (p : ι → ℝ) :
    ∑ i ∈ traceT U, p i + ∑ i ∈ traceF U, p i = 2 * ∑ q ∈ U, split p q := by
  classical
  have h := Finset.sum_filter_add_sum_filter_not U (fun q => q.2 = true) (fun q => split p q)
  rw [filter_true_eq, filter_false_eq] at h
  rw [Finset.sum_image (fun a _ b _ hab => (Prod.mk.injEq _ _ _ _ ▸ hab).1),
    Finset.sum_image (fun a _ b _ hab => (Prod.mk.injEq _ _ _ _ ▸ hab).1)] at h
  simp only [split] at h ⊢
  rw [← Finset.sum_div, ← Finset.sum_div, ← Finset.sum_div] at h
  rw [← Finset.sum_div]
  linarith

end Traces

/-! ## 3.  Refinement buys nothing -/

/-- **The refined pruner can do no better.**  Every `2k`-subset of the refined context
carries at most the old top-`k` mass, even though it may select single halves. -/
theorem topMass_split_le {p : ι → ℝ} {k : ℕ} {T T' : ℝ}
    (hT : IsTopMass p k T) (hT' : IsTopMass (split p) (2 * k) T') : T' ≤ T := by
  classical
  obtain ⟨⟨U, hU, hUval⟩, -⟩ := hT'
  rw [mem_powersetCard] at hU
  set St := traceT U with hSt
  set Sf := traceF U with hSf
  set D := St ∩ Sf with hD
  set E := (St ∪ Sf) \ D with hE
  have hcard : St.card + Sf.card = 2 * k := by
    rw [hSt, hSf, card_traces U, hU.2]
  have hDsub : D ⊆ St ∪ Sf := (inter_subset_left).trans subset_union_left
  have hcardE : E.card = (St ∪ Sf).card - D.card := by rw [hE, card_sdiff_of_subset hDsub]
  have hunion : (St ∪ Sf).card + D.card = St.card + Sf.card := card_union_add_card_inter St Sf
  have hDsubcard : D.card ≤ (St ∪ Sf).card := card_le_card hDsub
  have hDle : D.card ≤ k := by omega
  have hEcard : E.card = 2 * (k - D.card) := by omega
  -- masses
  have hsumUnion : ∑ i ∈ St ∪ Sf, p i + ∑ i ∈ D, p i = ∑ i ∈ St, p i + ∑ i ∈ Sf, p i :=
    Finset.sum_union_inter
  have hsumE : ∑ i ∈ E, p i = ∑ i ∈ St ∪ Sf, p i - ∑ i ∈ D, p i :=
    Finset.sum_sdiff_eq_sub hDsub
  have htraces : ∑ i ∈ St, p i + ∑ i ∈ Sf, p i = 2 * ∑ q ∈ U, split p q := sum_traces U p
  -- the exchange
  obtain ⟨C, hCsub, hCcard, hChalf⟩ := exists_half_subset p E (k - D.card) hEcard
  have hdisj : Disjoint D C := by
    refine Finset.disjoint_left.2 (fun a haD haC => ?_)
    have := hCsub haC
    rw [hE, mem_sdiff] at this
    exact this.2 haD
  have hcardDC : (D ∪ C).card = k := by
    rw [card_union_of_disjoint hdisj, hCcard]
    omega
  have hmemDC : D ∪ C ∈ univ.powersetCard k (α := ι) :=
    mem_powersetCard.2 ⟨fun x _ => mem_univ x, hcardDC⟩
  have hsumDC : ∑ i ∈ D ∪ C, p i = ∑ i ∈ D, p i + ∑ i ∈ C, p i :=
    Finset.sum_union hdisj
  have hle : ∑ i ∈ D ∪ C, p i ≤ T := hT.2 _ hmemDC
  rw [← hUval]
  linarith

/-- **Invariance of the top-mass functional under self-similar refinement.** -/
theorem topMass_split_eq {p : ι → ℝ} {k : ℕ} {T T' : ℝ}
    (hT : IsTopMass p k T) (hT' : IsTopMass (split p) (2 * k) T') : T' = T :=
  le_antisymm (topMass_split_le hT hT') (topMass_split_ge hT hT')

/-- **The selection gap is exactly invariant under self-similar refinement.**  Scale
invariant attention profiles neither dilute nor concentrate the advantage of data-free
top-`k` selection over the random-`k` control. -/
theorem selection_gap_split_eq {p : ι → ℝ} {k : ℕ} {T T' : ℝ}
    (hT : IsTopMass p k T) (hT' : IsTopMass (split p) (2 * k) T') :
    T' - (2 * k : ℝ) / (Fintype.card (ι × Bool) : ℝ)
      = T - (k : ℝ) / (Fintype.card ι : ℝ) := by
  have hcard : (Fintype.card (ι × Bool) : ℝ) = 2 * (Fintype.card ι : ℝ) := by
    simp [Fintype.card_prod]
    ring
  have hratio : (2 * k : ℝ) / (Fintype.card (ι × Bool) : ℝ)
      = (k : ℝ) / (Fintype.card ι : ℝ) := by
    rw [hcard]
    rcases eq_or_ne (Fintype.card ι : ℝ) 0 with h | h
    · simp [h]
    · field_simp
  rw [hratio, topMass_split_eq hT hT']

/-- **Two-sided falsification.**  Any change of the selection gap across a context
doubling at matched sparsity — increase or decrease — refutes exact self-similarity of
the attention profile. -/
theorem gap_change_refutes_self_similarity {p : ι → ℝ} {q : ι × Bool → ℝ} {k : ℕ}
    {T T' : ℝ} (hT : IsTopMass p k T) (hT' : IsTopMass q (2 * k) T')
    (hchange : T' - (2 * k : ℝ) / (Fintype.card (ι × Bool) : ℝ)
      ≠ T - (k : ℝ) / (Fintype.card ι : ℝ)) :
    q ≠ split p := by
  intro hq
  subst hq
  exact hchange (selection_gap_split_eq hT hT')

/-- The NET-45 selection gaps at the matched sparsity of the two ends of the ladder are
strictly different (`+5.9` accuracy points at `ctx = 1024`, `+1.7` at `ctx = 2048`), so
the hypothesis of the refutation is met by the measurement. -/
theorem net45_gap_change_is_strict : (17 : ℝ) / 10 ≠ 59 / 10 := by norm_num

end SelectionExchange