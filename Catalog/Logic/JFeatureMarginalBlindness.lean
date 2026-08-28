/-
# Marginal blindness: why no `j`-feature can carry a hidden pair-carrier

This file formalises the structural reason behind the empirical verdict
`H0_CARRIER_OPEN` of the j-feature sweep (paper 248): *eight* registered
families of arithmetic features of the position index `j`
(`j mod 4`, `j mod 3`, `j mod 5`, `j mod 7`, `j mod 105`, `omega_small(j)`
terciles, smoothness of `|j - nearest square|`, `10^6`-smoothness of `j`)
all returned honest enrichment ratios `R ≤ 1.11`.

The theorems below say that this is not an accident of the particular eight
features chosen: on a sample space `α × β` where the hit set is *row balanced*
(every value of the first coordinate carries the same number of hits), **every**
cell cut out by **any** function of the first coordinate has enrichment ratio
*exactly* `1`.  Whatever new feature of `j` one invents, the marginal sweep is
guaranteed to return `R = 1`; the sweep has no power at all against carriers
that live in the *joint* (consecutive-position) structure.

Yet such carriers exist and are arbitrarily strong: for the graph of a
permutation `σ : α ≃ β` (a row-balanced hit set with one hit per row) the joint
cell "the graph itself" has hit rate `1`, i.e. enrichment `card α` over the
global rate, while all marginal cells sit at exactly `1`.

Main results.

* `exists_fiber_hits_ge` / `exists_fiber_rate_ge_globalRate` : the *selection
  floor*.  For every feature map and every hit set there is always a nonempty
  cell whose hit rate is at least the global rate; a raw "max over cells of
  `R`" statistic is therefore `≥ 1` by pure pigeonhole, with no signal
  whatsoever.  (Used in `Logic.JFeatureMaxStatistic` to show that the
  uncalibrated max test has type-I error rate `1`.)
* `rate_rowSet`, `enrich_rowSet_eq_one`, `enrich_marginal_feature_eq_one` :
  **marginal blindness**.
* `graphFinset_rowBalanced`, `rate_graphFinset`,
  `graph_joint_rate_eq_card_mul_globalRate`,
  `marginal_blind_carrier` : the joint carrier that is invisible to every
  marginal feature, with unbounded joint enrichment.
-/
import Mathlib

namespace Logic.JFeature

open Finset

/-! ## Hit rates, global rate, enrichment -/

section Rates

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Hit rate of the hit set `H` inside the cell `C`. -/
noncomputable def rate (H C : Finset ι) : ℝ := ((H ∩ C).card : ℝ) / (C.card : ℝ)

/-- Global hit rate. -/
noncomputable def globalRate (H : Finset ι) : ℝ := (H.card : ℝ) / (Fintype.card ι : ℝ)

/-- Enrichment ratio of a cell against its complement — the statistic `R` of the
sweep. -/
noncomputable def enrich (H C : Finset ι) : ℝ := rate H C / rate H Cᶜ

omit [Fintype ι] in
lemma rate_nonneg (H C : Finset ι) : 0 ≤ rate H C := by
  unfold rate; positivity

lemma rate_univ (H : Finset ι) : rate H univ = globalRate H := by
  simp [rate, globalRate, Finset.card_univ]

/-- Cell counts split the hit count. -/
lemma hits_split (H C : Finset ι) : (H ∩ C).card + (H ∩ Cᶜ).card = H.card := by
  classical
  rw [← Finset.card_union_of_disjoint]
  · congr 1
    ext x
    by_cases hx : x ∈ C <;> simp [hx]
  · refine Finset.disjoint_left.2 fun x hx hx' => ?_
    simp only [Finset.mem_inter, Finset.mem_compl] at hx hx'
    exact hx'.2 hx.2

lemma cells_split (C : Finset ι) : C.card + Cᶜ.card = Fintype.card ι := by
  rw [Finset.card_compl]
  have : C.card ≤ Fintype.card ι := Finset.card_le_univ C
  omega

/-- **Mediant inequality.** If a cell's rate is at least the global rate then it
is at least the complement's rate — the two ways of phrasing "enrichment" agree
in direction. -/
lemma rate_compl_le_rate_of_globalRate_le {H C : Finset ι}
    (hC : 0 < C.card) (hCc : 0 < Cᶜ.card) (h : globalRate H ≤ rate H C) :
    rate H Cᶜ ≤ rate H C := by
  have hc : (0:ℝ) < (C.card : ℝ) := by exact_mod_cast hC
  have hd : (0:ℝ) < (Cᶜ.card : ℝ) := by exact_mod_cast hCc
  have hab : ((H ∩ C).card : ℝ) + ((H ∩ Cᶜ).card : ℝ) = (H.card : ℝ) := by
    exact_mod_cast hits_split H C
  have hcd : ((C.card : ℝ)) + ((Cᶜ.card : ℝ)) = (Fintype.card ι : ℝ) := by
    exact_mod_cast cells_split C
  rw [globalRate, rate, ← hab, ← hcd] at h
  rw [div_le_div_iff₀ (by linarith) hc] at h
  rw [rate, rate, div_le_div_iff₀ hd hc]
  nlinarith

end Rates

/-! ## The selection floor: some cell always looks enriched -/

section SelectionFloor

variable {ι : Type*} [Fintype ι] [DecidableEq ι]
variable {κ : Type*} [Fintype κ] [DecidableEq κ]

omit [DecidableEq ι] in
/-- **Pigeonhole / selection floor (counting form).** For any feature map `u`
and hit set `H` there is a value `k` whose fiber carries at least a
proportional share of the hits.  No randomness and no signal are involved. -/
theorem exists_fiber_hits_ge [Nonempty ι] (u : ι → κ) (H : Finset ι) :
    ∃ k : κ, H.card * (univ.filter (fun i => u i = k)).card
      ≤ (H.filter (fun i => u i = k)).card * Fintype.card ι := by
  classical
  by_contra hcon
  push_neg at hcon
  have hκ : Nonempty κ := ⟨u (Classical.arbitrary ι)⟩
  have hsumH : ∑ k : κ, (H.filter (fun i => u i = k)).card = H.card :=
    (Finset.card_eq_sum_card_fiberwise (f := u) (s := H) (t := univ)
      (fun x _ => Finset.mem_univ _)).symm
  have hsumU : ∑ k : κ, (univ.filter (fun i => u i = k)).card = Fintype.card ι := by
    have := (Finset.card_eq_sum_card_fiberwise (f := u) (s := (univ : Finset ι))
      (t := univ) (fun x _ => Finset.mem_univ _)).symm
    simpa [Finset.card_univ] using this
  have hlt : ∑ k : κ, (H.filter (fun i => u i = k)).card * Fintype.card ι
      < ∑ k : κ, H.card * (univ.filter (fun i => u i = k)).card := by
    refine Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty ?_
    intro k _
    exact hcon k
  rw [← Finset.sum_mul, hsumH, ← Finset.mul_sum, hsumU] at hlt
  omega

omit [Fintype κ] in
lemma inter_filter_eq (u : ι → κ) (H : Finset ι) (k : κ) :
    H ∩ (univ.filter (fun i => u i = k)) = H.filter (fun i => u i = k) := by
  ext x; simp [Finset.mem_inter, Finset.mem_filter]

/-- **Selection floor (rate form).** Some nonempty cell of any feature map has
hit rate at least the global rate.  Scanning cells for `R > 1` therefore always
succeeds, whatever the data. -/
theorem exists_fiber_rate_ge_globalRate [Nonempty ι] (u : ι → κ) (H : Finset ι) :
    ∃ k : κ, (univ.filter (fun i => u i = k)).Nonempty ∧
      globalRate H ≤ rate H (univ.filter (fun i => u i = k)) := by
  classical
  set F : κ → Finset ι := fun k => univ.filter (fun i => u i = k) with hF
  set Hf : κ → Finset ι := fun k => H.filter (fun i => u i = k) with hHf
  have hn : (0:ℝ) < (Fintype.card ι : ℝ) := by
    have : 0 < Fintype.card ι := Fintype.card_pos
    exact_mod_cast this
  have hsumH : ∑ k : κ, (Hf k).card = H.card :=
    (Finset.card_eq_sum_card_fiberwise (f := u) (s := H) (t := univ)
      (fun x _ => Finset.mem_univ _)).symm
  have hsumU : ∑ k : κ, (F k).card = Fintype.card ι := by
    have := (Finset.card_eq_sum_card_fiberwise (f := u) (s := (univ : Finset ι))
      (t := univ) (fun x _ => Finset.mem_univ _)).symm
    simpa [hF, Finset.card_univ] using this
  by_contra hcon
  push_neg at hcon
  -- every nonempty fiber is strictly under-represented
  have key : ∀ k : κ, (Hf k).card * Fintype.card ι ≤ H.card * (F k).card := by
    intro k
    by_cases hne : (F k).Nonempty
    · have hlt := hcon k hne
      have hFk : (0:ℝ) < ((F k).card : ℝ) := by
        have : 0 < (F k).card := Finset.card_pos.2 hne
        exact_mod_cast this
      have : ((Hf k).card : ℝ) * (Fintype.card ι : ℝ) < (H.card : ℝ) * ((F k).card : ℝ) := by
        have h2 : ((Hf k).card : ℝ) / ((F k).card : ℝ) < (H.card : ℝ) / (Fintype.card ι : ℝ) := by
          simpa [rate, globalRate, hHf, hF, inter_filter_eq] using hlt
        rw [div_lt_div_iff₀ hFk hn] at h2
        linarith
      exact_mod_cast this.le
    · rw [Finset.not_nonempty_iff_eq_empty] at hne
      have h0 : Hf k = ∅ := by
        rw [Finset.eq_empty_iff_forall_notMem]
        intro x hx
        have hx' : x ∈ F k := by
          simp only [hF, Finset.mem_filter, Finset.mem_univ, true_and]
          exact (Finset.mem_filter.1 hx).2
        rw [hne] at hx'
        exact absurd hx' (Finset.notMem_empty x)
      simp [h0, hne]
  -- but at the fiber of an actual point the inequality is strict
  obtain ⟨i₀⟩ := ‹Nonempty ι›
  have hne0 : (F (u i₀)).Nonempty := ⟨i₀, by simp [hF]⟩
  have hstrict : (Hf (u i₀)).card * Fintype.card ι < H.card * (F (u i₀)).card := by
    have hlt := hcon (u i₀) hne0
    have hFk : (0:ℝ) < ((F (u i₀)).card : ℝ) := by
      have : 0 < (F (u i₀)).card := Finset.card_pos.2 hne0
      exact_mod_cast this
    have : ((Hf (u i₀)).card : ℝ) * (Fintype.card ι : ℝ)
        < (H.card : ℝ) * ((F (u i₀)).card : ℝ) := by
      have h2 : ((Hf (u i₀)).card : ℝ) / ((F (u i₀)).card : ℝ)
          < (H.card : ℝ) / (Fintype.card ι : ℝ) := by
        simpa [rate, globalRate, hHf, hF, inter_filter_eq] using hlt
      rw [div_lt_div_iff₀ hFk hn] at h2
      linarith
    exact_mod_cast this
  have hsum : ∑ k : κ, (Hf k).card * Fintype.card ι
      < ∑ k : κ, H.card * (F k).card :=
    Finset.sum_lt_sum (fun k _ => key k) ⟨u i₀, Finset.mem_univ _, hstrict⟩
  rw [← Finset.sum_mul, hsumH, ← Finset.mul_sum, hsumU] at hsum
  omega

end SelectionFloor

/-! ## Marginal blindness on a product sample space -/

section MarginalBlindness

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]

/-- The cell of the product space cut out by a set `S` of first coordinates:
all positions whose `j`-value lies in `S`. -/
def rowSet (S : Finset α) : Finset (α × β) := S ×ˢ (univ : Finset β)

/-- The number of hits in a row. -/
def rowHits (H : Finset (α × β)) (a : α) : ℕ := (H.filter (fun x => x.1 = a)).card

/-- `H` is *row balanced* with `m` hits per row: every value of the first
coordinate carries exactly `m` hits. -/
def RowBalanced (H : Finset (α × β)) (m : ℕ) : Prop := ∀ a : α, rowHits H a = m

omit [Fintype α] [DecidableEq α] [DecidableEq β] in
lemma card_rowSet (S : Finset α) :
    (rowSet (β := β) S).card = S.card * Fintype.card β := by
  simp [rowSet, Finset.card_product, Finset.card_univ]

lemma compl_rowSet (S : Finset α) : (rowSet (β := β) S)ᶜ = rowSet Sᶜ := by
  ext x; simp [rowSet, Finset.mem_product]

omit [DecidableEq α] [DecidableEq β] in
/-- Any first-coordinate feature cell is a `rowSet`. -/
lemma filter_fst_eq_rowSet {κ : Type*} [DecidableEq κ] (u : α → κ) (k : κ) :
    (univ.filter (fun x : α × β => u x.1 = k)) = rowSet (univ.filter (fun a => u a = k)) := by
  ext x; simp [rowSet, Finset.mem_product]

omit [Fintype α] in
/-- **Cell hit counting.** The hits inside a `rowSet` are the hits of its rows. -/
lemma card_inter_rowSet_sum (H : Finset (α × β)) (S : Finset α) :
    (H ∩ rowSet (β := β) S).card = ∑ a ∈ S, rowHits H a := by
  classical
  have h1 : H ∩ rowSet (β := β) S = H.filter (fun x => x.1 ∈ S) := by
    ext x
    simp [rowSet, Finset.mem_product, Finset.mem_inter, Finset.mem_filter]
  have hmem : ∀ x ∈ H.filter (fun x : α × β => x.1 ∈ S), x.1 ∈ S := by
    intro x hx; exact (Finset.mem_filter.1 hx).2
  rw [h1, Finset.card_eq_sum_card_fiberwise hmem]
  refine Finset.sum_congr rfl fun a ha => ?_
  have hfe : (H.filter (fun x : α × β => x.1 ∈ S)).filter (fun x => x.1 = a)
      = H.filter (fun x => x.1 = a) := by
    ext x
    constructor
    · intro hx
      simp only [Finset.mem_filter] at hx ⊢
      exact ⟨hx.1.1, hx.2⟩
    · intro hx
      simp only [Finset.mem_filter] at hx ⊢
      exact ⟨⟨hx.1, by rw [hx.2]; exact ha⟩, hx.2⟩
  rw [hfe, rowHits]

omit [Fintype α] in
/-- **Row-balanced hit counting.** A row-balanced hit set puts exactly `m` hits
into each row of a cell, whatever the cell. -/
lemma card_inter_rowSet {H : Finset (α × β)} {m : ℕ} (hH : RowBalanced H m) (S : Finset α) :
    (H ∩ rowSet (β := β) S).card = S.card * m := by
  rw [card_inter_rowSet_sum]
  rw [Finset.sum_congr rfl (fun a _ => hH a), Finset.sum_const, smul_eq_mul]

omit [Fintype α] in
/-- **Marginal blindness, rate form.** For a row-balanced hit set, *every* cell
cut out by *any* feature of the first coordinate has hit rate `m / card β`,
independently of the feature and of the cell.  No such feature can ever show an
enrichment. -/
theorem rate_rowSet [Nonempty β] {H : Finset (α × β)} {m : ℕ} (hH : RowBalanced H m)
    {S : Finset α} (hS : S.Nonempty) :
    rate H (rowSet S) = (m : ℝ) / (Fintype.card β : ℝ) := by
  have hScard : ((S.card : ℝ)) ≠ 0 := by
    have : 0 < S.card := Finset.card_pos.2 hS
    positivity
  rw [rate, card_inter_rowSet hH, card_rowSet]
  push_cast
  exact mul_div_mul_left _ _ hScard

/-- **Marginal blindness, enrichment form.** Every marginal cell has enrichment
ratio exactly `1`.  (`0 < m` rules out the degenerate empty-hit case, where the
ratio is a `0/0`.) -/
theorem enrich_rowSet_eq_one [Nonempty β] {H : Finset (α × β)} {m : ℕ}
    (hH : RowBalanced H m) (hm : 0 < m) {S : Finset α} (hS : S.Nonempty) (hSc : Sᶜ.Nonempty) :
    enrich H (rowSet S) = 1 := by
  have hne : (m : ℝ) / (Fintype.card β : ℝ) ≠ 0 := by
    have h1 : (0:ℝ) < (m:ℝ) := by exact_mod_cast hm
    have h2 : (0:ℝ) < (Fintype.card β : ℝ) := by
      have : 0 < Fintype.card β := Fintype.card_pos
      exact_mod_cast this
    positivity
  rw [enrich, compl_rowSet, rate_rowSet hH hS, rate_rowSet hH hSc, div_self hne]

/-- **No feature of `j` can carry the excess.** For a row-balanced hit set the
enrichment ratio of the cell where `u j = k` is exactly `1`, for every feature
map `u` and every value `k` — the structural statement behind the
`H0_CARRIER_OPEN` verdict of the eight-family sweep. -/
theorem enrich_marginal_feature_eq_one [Nonempty β] {κ : Type*} [DecidableEq κ]
    {H : Finset (α × β)} {m : ℕ} (hH : RowBalanced H m) (hm : 0 < m) (u : α → κ) (k : κ)
    (hS : (univ.filter (fun a => u a = k)).Nonempty)
    (hSc : (univ.filter (fun a => u a = k))ᶜ.Nonempty) :
    enrich H (univ.filter (fun x : α × β => u x.1 = k)) = 1 := by
  rw [filter_fst_eq_rowSet]
  exact enrich_rowSet_eq_one hH hm hS hSc

/-- **Rigidity: marginal invisibility is exactly row balance.**  If every
single-row cell has enrichment ratio `1` — the weakest possible instance of a
flat marginal sweep — then the hit set is row balanced, and conversely by
`enrich_rowSet_eq_one`.  So the flat outcome of a marginal sweep is precisely
equivalent to row balance of the hit set, and says nothing else. -/
theorem rowBalanced_of_enrich_singletons [Nonempty β] {H : Finset (α × β)}
    (hcard : 2 ≤ Fintype.card α)
    (h : ∀ a : α, enrich H (rowSet ({a} : Finset α)) = 1) :
    ∃ m : ℕ, RowBalanced H m ∧ H.card = Fintype.card α * m := by
  classical
  have hb : (0:ℝ) < (Fintype.card β : ℝ) := by
    have : 0 < Fintype.card β := Fintype.card_pos
    exact_mod_cast this
  have hnR : (2:ℝ) ≤ (Fintype.card α : ℝ) := by exact_mod_cast hcard
  have htot : ∑ b : α, rowHits H b = H.card := by
    have hru : rowSet (β := β) (univ : Finset α) = (univ : Finset (α × β)) := by
      ext x; simp [rowSet]
    have := card_inter_rowSet_sum H (univ : Finset α)
    rw [hru, Finset.inter_univ] at this
    exact this.symm
  have key : ∀ a : α, Fintype.card α * rowHits H a = H.card := by
    intro a
    have hsum : rowHits H a + ∑ b ∈ ({a} : Finset α)ᶜ, rowHits H b = H.card := by
      have h0 : ∑ b ∈ ({a} : Finset α), rowHits H b
          + ∑ b ∈ ({a} : Finset α)ᶜ, rowHits H b = ∑ b : α, rowHits H b :=
        Finset.sum_add_sum_compl _ _
      rw [Finset.sum_singleton] at h0
      rw [h0, htot]
    have hcardC : (rowSet (β := β) ({a} : Finset α)).card = Fintype.card β := by
      rw [card_rowSet, Finset.card_singleton, one_mul]
    have hA : rate H (rowSet (β := β) ({a} : Finset α))
        = (rowHits H a : ℝ) / (Fintype.card β : ℝ) := by
      rw [rate, card_inter_rowSet_sum, hcardC, Finset.sum_singleton]
    have hcardCc : (rowSet (β := β) (({a} : Finset α)ᶜ)).card
        = (Fintype.card α - 1) * Fintype.card β := by
      rw [card_rowSet, Finset.card_compl, Finset.card_singleton]
    have hB : rate H (rowSet (β := β) (({a} : Finset α)ᶜ))
        = ((∑ b ∈ ({a} : Finset α)ᶜ, rowHits H b : ℕ) : ℝ)
          / (((Fintype.card α - 1) * Fintype.card β : ℕ) : ℝ) := by
      rw [rate, card_inter_rowSet_sum, hcardCc]
    have hne : rate H (rowSet (β := β) ({a} : Finset α))ᶜ ≠ 0 := by
      intro h0
      have h1 := h a
      rw [enrich, h0, div_zero] at h1
      exact zero_ne_one h1
    have hAB : rate H (rowSet (β := β) ({a} : Finset α))
        = rate H (rowSet (β := β) ({a} : Finset α))ᶜ := by
      have h1 := h a
      rw [enrich, div_eq_one_iff_eq hne] at h1
      exact h1
    rw [compl_rowSet, hA, hB] at hAB
    -- clear denominators
    have hcast : (((Fintype.card α - 1) * Fintype.card β : ℕ) : ℝ)
        = ((Fintype.card α : ℝ) - 1) * (Fintype.card β : ℝ) := by
      have h1 : (1:ℕ) ≤ Fintype.card α := by omega
      push_cast [Nat.cast_sub h1]
      ring
    rw [hcast] at hAB
    have hpos : (0:ℝ) < ((Fintype.card α : ℝ) - 1) * (Fintype.card β : ℝ) := by
      have : (0:ℝ) < (Fintype.card α : ℝ) - 1 := by linarith
      positivity
    rw [div_eq_div_iff (ne_of_gt hb) (ne_of_gt hpos)] at hAB
    have hsumR : (rowHits H a : ℝ) + ((∑ b ∈ ({a} : Finset α)ᶜ, rowHits H b : ℕ) : ℝ)
        = (H.card : ℝ) := by exact_mod_cast hsum
    have hfinal : (Fintype.card α : ℝ) * (rowHits H a : ℝ) = (H.card : ℝ) := by
      nlinarith [hAB, hsumR]
    exact_mod_cast hfinal
  have hneα : Nonempty α := Fintype.card_pos_iff.1 (by omega)
  obtain ⟨a₀⟩ := hneα
  refine ⟨rowHits H a₀, ?_, ?_⟩
  · intro a
    have h1 := key a
    have h2 := key a₀
    have hn : 0 < Fintype.card α := by omega
    have : Fintype.card α * rowHits H a = Fintype.card α * rowHits H a₀ := by
      rw [h1, h2]
    exact Nat.eq_of_mul_eq_mul_left hn this
  · exact (key a₀).symm

/-- **Complete characterisation of what a marginal sweep can see.**  For a
nonempty hit set, flatness of the single-row enrichment ratios is *equivalent*
to row balance.  A sweep reporting `R = 1` everywhere has learned exactly one
bit about the data — that its rows are balanced — and nothing about any joint
structure. -/
theorem marginal_invisibility_iff_rowBalanced [Nonempty β] {H : Finset (α × β)}
    (hcard : 2 ≤ Fintype.card α) (hH : H.Nonempty) :
    (∀ a : α, enrich H (rowSet ({a} : Finset α)) = 1) ↔ ∃ m : ℕ, 0 < m ∧ RowBalanced H m := by
  constructor
  · intro h
    obtain ⟨m, hm, hcardH⟩ := rowBalanced_of_enrich_singletons hcard h
    refine ⟨m, ?_, hm⟩
    rcases Nat.eq_zero_or_pos m with rfl | hpos
    · exact absurd hcardH (by simpa using (Finset.card_pos.2 hH).ne')
    · exact hpos
  · rintro ⟨m, hm, hbal⟩ a
    have hS : ({a} : Finset α).Nonempty := ⟨a, Finset.mem_singleton_self a⟩
    have hSc : (({a} : Finset α)ᶜ).Nonempty := by
      rw [← Finset.card_pos, Finset.card_compl, Finset.card_singleton]
      omega
    exact enrich_rowSet_eq_one hbal hm hS hSc

/-! ### A carrier that hides from every marginal feature -/

/-- The graph of a permutation, viewed as a hit set: one hit per row. -/
def graphFinset (σ : α ≃ β) : Finset (α × β) := univ.filter (fun x => x.2 = σ x.1)

lemma graphFinset_rowBalanced (σ : α ≃ β) : RowBalanced (graphFinset σ) 1 := by
  intro a
  have h : (graphFinset σ).filter (fun x => x.1 = a) = {(a, σ a)} := by
    ext x
    simp only [graphFinset, Finset.mem_filter, Finset.mem_univ, true_and,
      Finset.mem_singleton]
    constructor
    · rintro ⟨h2, h1⟩
      obtain ⟨x1, x2⟩ := x
      simp_all
    · rintro rfl
      exact ⟨rfl, rfl⟩
  rw [rowHits, h, Finset.card_singleton]

lemma card_graphFinset (σ : α ≃ β) : (graphFinset σ).card = Fintype.card α := by
  classical
  have hmem : ∀ x ∈ graphFinset σ, x.1 ∈ (univ : Finset α) := fun x _ => Finset.mem_univ _
  rw [Finset.card_eq_sum_card_fiberwise hmem]
  have h : ∀ a ∈ (univ : Finset α), ((graphFinset σ).filter (fun x => x.1 = a)).card = 1 :=
    fun a _ => graphFinset_rowBalanced σ a
  rw [Finset.sum_congr rfl h]
  simp

/-- The joint cell given by the graph itself is a perfect carrier: hit rate `1`. -/
theorem rate_graphFinset (σ : α ≃ β) (hcard : 0 < Fintype.card α) :
    rate (graphFinset σ) (graphFinset σ) = 1 := by
  have h : (0:ℝ) < ((graphFinset σ).card : ℝ) := by
    rw [card_graphFinset]; exact_mod_cast hcard
  rw [rate, Finset.inter_self]
  exact div_self (ne_of_gt h)

/-- The joint carrier is enriched by the factor `card β` over the global rate,
which is unbounded — while every marginal cell sits at exactly `1`. -/
theorem graph_joint_rate_eq_card_mul_globalRate (σ : α ≃ β) (hcard : 0 < Fintype.card α) :
    rate (graphFinset σ) (graphFinset σ)
      = (Fintype.card β : ℝ) * globalRate (graphFinset σ) := by
  have hA : (0:ℝ) < (Fintype.card α : ℝ) := by exact_mod_cast hcard
  have hB : (0:ℝ) < (Fintype.card β : ℝ) := by
    have hc : Fintype.card β = Fintype.card α := (Fintype.card_congr σ).symm
    rw [hc]; exact hA
  rw [rate_graphFinset σ hcard, globalRate, card_graphFinset, Fintype.card_prod]
  push_cast
  field_simp

/-- **Marginal-blind carrier theorem.**  The permutation-graph hit set is
simultaneously:

* invisible to *every* feature of the first coordinate (all marginal enrichment
  ratios are exactly `1`), and
* carried by a joint cell whose enrichment over the global rate is `card β`,
  i.e. arbitrarily large.

A marginal sweep returning `R ≈ 1` on all families therefore carries **no**
evidence against a joint (consecutive-position) carrier. -/
theorem marginal_blind_carrier [Nonempty β] {κ : Type*} [DecidableEq κ]
    (σ : α ≃ β) (hcard : 0 < Fintype.card α) (u : α → κ) (k : κ)
    (hS : (univ.filter (fun a => u a = k)).Nonempty)
    (hSc : (univ.filter (fun a => u a = k))ᶜ.Nonempty) :
    enrich (graphFinset σ) (univ.filter (fun x : α × β => u x.1 = k)) = 1 ∧
      rate (graphFinset σ) (graphFinset σ)
        = (Fintype.card β : ℝ) * globalRate (graphFinset σ) :=
  ⟨enrich_marginal_feature_eq_one (graphFinset_rowBalanced σ) one_pos u k hS hSc,
    graph_joint_rate_eq_card_mul_globalRate σ hcard⟩

end MarginalBlindness

end Logic.JFeature