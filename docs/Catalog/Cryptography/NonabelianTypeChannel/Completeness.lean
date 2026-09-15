import Cryptography.NonabelianTypeChannel.GroupChannel

/-!
# When is a splitting-type channel complete?

The cap `I(coset ; T) ≤ log₂ [G : G']` of `GroupChannel.lean` is attained by `S₃` and
`S₄` and missed by `A₄`, `D₄`, `V₄`, `C₄`.  This file explains exactly why, by
characterising the vanishing of conditional entropy:

  `H(g | f) = 0` **iff** the readout `f` determines the readout `g` on the sample space.

Consequently the type channel of a field is *complete* — it delivers the whole
`log₂[G : G']` bits of its abelianization — precisely when the splitting type
determines the abelianization coset, and the "loss" column of the law table is
exactly the failure of that determination.

## Main results

* `TypeChannel.condEntropy_eq_zero_iff` — the determinism criterion.
* `TypeChannel.mutualInfo_eq_entropy_iff` — `I(f ; g) = H(g)` iff `f` determines `g`.
* `TypeChannel.typeChannel_complete_iff` — the type channel of a Galois group attains
  the abelianization cap iff the splitting type determines the coset.
* `TypeChannel.mutualInfo_eq_entropy_of_injOn` — an injective residue readout (the
  abelian case `G = G^ab` with a separating dial) always delivers all of `H(T)`.
-/

namespace TypeChannel

open Finset Real

variable {Ω α β : Type*} [DecidableEq α] [DecidableEq β]

section Determinism

variable {S : Finset Ω} {f : Ω → α} {g : Ω → β}

/-- The conditional entropy `H(g | f)` as a sum of nonnegative cell contributions. -/
lemma condEntropy_eq_sum :
    condEntropy S g f = ∑ x ∈ S.image f ×ˢ S.image g,
      (prob S (pairObs f g) x * logb 2 (prob S f x.1)
        - prob S (pairObs f g) x * logb 2 (prob S (pairObs f g) x)) := by
  have hHp : entropy S (pairObs f g)
      = ∑ x ∈ S.image f ×ˢ S.image g,
        -(prob S (pairObs f g) x * logb 2 (prob S (pairObs f g) x)) :=
    entropy_eq_sum_of_subset image_pairObs_subset
  have hHf : entropy S f
      = ∑ x ∈ S.image f ×ˢ S.image g, -(prob S (pairObs f g) x * logb 2 (prob S f x.1)) := by
    rw [entropy, Finset.sum_product]
    refine Finset.sum_congr rfl (fun a _ => ?_)
    have h1 : ∀ b : β, -(prob S (pairObs f g) (a, b) * logb 2 (prob S f a))
        = (-(logb 2 (prob S f a))) * prob S (pairObs f g) (a, b) := fun b => by ring
    simp_rw [h1]
    rw [← Finset.mul_sum, sum_prob_pair_right]
    ring
  rw [condEntropy, hHp, hHf, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl (fun x _ => by ring)

/-- Each cell contributes nonnegatively to the conditional entropy. -/
lemma condEntropy_cell_nonneg (a : α) (b : β) :
    0 ≤ prob S (pairObs f g) (a, b) * logb 2 (prob S f a)
      - prob S (pairObs f g) (a, b) * logb 2 (prob S (pairObs f g) (a, b)) := by
  rcases eq_or_lt_of_le (prob_nonneg S (pairObs f g) (a, b)) with h | hpos
  · simp [← h]
  · have hle : prob S (pairObs f g) (a, b) ≤ prob S f a := prob_pair_le_left a b
    have hpa : 0 < prob S f a := lt_of_lt_of_le hpos hle
    have hlog : logb 2 (prob S (pairObs f g) (a, b)) ≤ logb 2 (prob S f a) :=
      (Real.logb_le_logb (by norm_num) hpos hpa).mpr hle
    nlinarith

/-- A cell contributes zero exactly when it is empty or exhausts its row. -/
lemma condEntropy_cell_eq_zero_iff (a : α) (b : β) :
    prob S (pairObs f g) (a, b) * logb 2 (prob S f a)
        - prob S (pairObs f g) (a, b) * logb 2 (prob S (pairObs f g) (a, b)) = 0 ↔
      prob S (pairObs f g) (a, b) = 0 ∨ prob S (pairObs f g) (a, b) = prob S f a := by
  constructor
  · intro h
    rcases eq_or_lt_of_le (prob_nonneg S (pairObs f g) (a, b)) with h0 | hpos
    · exact Or.inl h0.symm
    · right
      have hle : prob S (pairObs f g) (a, b) ≤ prob S f a := prob_pair_le_left a b
      have hpa : 0 < prob S f a := lt_of_lt_of_le hpos hle
      by_contra hne
      have hlt : prob S (pairObs f g) (a, b) < prob S f a := lt_of_le_of_ne hle hne
      have hlog : logb 2 (prob S (pairObs f g) (a, b)) < logb 2 (prob S f a) :=
        Real.logb_lt_logb (by norm_num) hpos hlt
      nlinarith
  · rintro (h | h) <;> rw [h] <;> ring

/-- **The determinism criterion.**  The conditional entropy `H(g | f)` vanishes exactly
when `f` determines `g` on the sample space. -/
theorem condEntropy_eq_zero_iff :
    condEntropy S g f = 0 ↔ ∀ w ∈ S, ∀ w' ∈ S, f w = f w' → g w = g w' := by
  rw [condEntropy_eq_sum]
  rw [Finset.sum_eq_zero_iff_of_nonneg (fun x _ => condEntropy_cell_nonneg x.1 x.2)]
  constructor
  · intro h w hw w' hw' hff
    have hx : (f w, g w) ∈ S.image f ×ˢ S.image g :=
      mem_product.mpr ⟨mem_image_of_mem _ hw, mem_image_of_mem _ hw⟩
    have hcell := h _ hx
    have hpos : 0 < prob S (pairObs f g) (f w, g w) :=
      prob_pos_of_mem (mem_image.mpr ⟨w, hw, rfl⟩)
    rcases (condEntropy_cell_eq_zero_iff (f w) (g w)).mp hcell with h0 | heq
    · exact absurd h0 (ne_of_gt hpos)
    · -- the cell exhausts its row, so the whole `f`-fibre has the same `g`-value
      have hsub : fiber S (pairObs f g) (f w, g w) ⊆ fiber S f (f w) := by
        rw [fiber_pair_eq]; exact Finset.filter_subset _ _
      have hcardeq : (fiber S (pairObs f g) (f w, g w)).card = (fiber S f (f w)).card := by
        have hS : (0:ℝ) < S.card := by exact_mod_cast card_pos.mpr ⟨w, hw⟩
        have := heq
        unfold prob at this
        field_simp at this
        exact_mod_cast this
      have hEq : fiber S (pairObs f g) (f w, g w) = fiber S f (f w) :=
        Finset.eq_of_subset_of_card_le hsub (le_of_eq hcardeq.symm)
      have hw'mem : w' ∈ fiber S f (f w) := by
        simp only [fiber, mem_filter]
        exact ⟨hw', hff.symm⟩
      rw [← hEq] at hw'mem
      simp only [fiber, mem_filter, pairObs, Prod.mk.injEq] at hw'mem
      exact hw'mem.2.2.symm
  · intro hdet x hx
    rw [condEntropy_cell_eq_zero_iff]
    rcases eq_or_lt_of_le (prob_nonneg S (pairObs f g) x) with h0 | hpos
    · exact Or.inl h0.symm
    · right
      -- the cell is nonempty, so it is the whole row
      have hne : (fiber S (pairObs f g) x).Nonempty := by
        by_contra hempty
        rw [Finset.not_nonempty_iff_eq_empty] at hempty
        simp [prob, hempty] at hpos
      obtain ⟨w, hw⟩ := hne
      simp only [fiber, mem_filter, pairObs] at hw
      obtain ⟨hwS, hwx⟩ := hw
      have hEq : fiber S (pairObs f g) x = fiber S f x.1 := by
        apply Finset.Subset.antisymm
        · rw [fiber_pair_eq]; exact Finset.filter_subset _ _
        · intro w' hw'
          simp only [fiber, mem_filter] at hw' ⊢
          obtain ⟨hw'S, hw'f⟩ := hw'
          have hfw : f w = x.1 := by rw [← hwx]
          refine ⟨hw'S, ?_⟩
          have hgw : g w = x.2 := by rw [← hwx]
          simp only [pairObs, Prod.ext_iff]
          exact ⟨hw'f, by rw [hdet w' hw'S w hwS (by rw [hw'f, hfw]), hgw]⟩
      unfold prob
      rw [hEq]
  
end Determinism

section Consequences

variable {S : Finset Ω} {f : Ω → α} {g : Ω → β}

/-- `I(f ; g) = H(g)` exactly when `f` determines `g`. -/
theorem mutualInfo_eq_entropy_iff :
    mutualInfo S f g = entropy S g ↔ ∀ w ∈ S, ∀ w' ∈ S, f w = f w' → g w = g w' := by
  rw [mutualInfo_eq_sub_condEntropy, ← condEntropy_eq_zero_iff (S := S) (f := f) (g := g)]
  constructor
  · intro h; linarith
  · intro h; rw [h]; ring

/-- An injective readout delivers the entire entropy of any second readout: this is the
abelian case `G = G^ab` read through a separating residue dial. -/
theorem mutualInfo_eq_entropy_of_injOn (h : ∀ w ∈ S, ∀ w' ∈ S, f w = f w' → w = w') :
    mutualInfo S f g = entropy S g :=
  mutualInfo_eq_entropy_iff.mpr (fun w hw w' hw' hff => by rw [h w hw w' hw' hff])

end Consequences

section GroupLevel

variable {G : Type*} [Group G] [DecidableEq G] {κ τ : Type*} [DecidableEq κ] [DecidableEq τ]
variable {S N : Finset G} {c : G → κ} {T : G → τ}

/-- **Completeness criterion for a type channel.**  A field's splitting-type channel
attains the abelianization cap `log₂ [G : G']` exactly when the splitting type
determines the abelianization coset.  (`S₃` and `S₄` do; `A₄`, `D₄`, `V₄`, `C₄` do
not, and their losses are precisely the resulting conditional entropies.) -/
theorem typeChannel_complete_iff (hS : IsSubgroupFinset S) (hN : IsSubgroupFinset N)
    (hNS : N ⊆ S) (hc : IsCosetReadout S N c) :
    mutualInfo S c T = logb 2 (S.image c).card ↔
      ∀ a ∈ S, ∀ b ∈ S, T a = T b → c a = c b := by
  have hloss := loss_eq hS hN hNS hc T
  constructor
  · intro h
    have : condEntropy S c T = 0 := by rw [← hloss, h]; ring
    exact condEntropy_eq_zero_iff.mp this
  · intro h
    have h0 : condEntropy S c T = 0 := condEntropy_eq_zero_iff.mpr h
    rw [h0] at hloss
    linarith

omit [DecidableEq G] in
/-- In an abelian Galois group the derived subgroup is trivial. -/
lemma derived_eq_one_of_abelian (hS : IsSubgroupFinset S)
    (hab : ∀ a ∈ S, ∀ b ∈ S, a * b = b * a) (hd : IsDerivedFinset S N) : N = {1} := by
  apply Finset.Subset.antisymm
  · intro n hn
    obtain ⟨a, ha, b, hb, rfl⟩ := hd.mem_commutator n hn
    have hcomm : a * b = b * a := hab a ha b hb
    simp only [Finset.mem_singleton]
    rw [hcomm]
    group
  · intro x hx
    rw [Finset.mem_singleton] at hx
    subst hx
    simpa using hd.commutator_mem 1 hS.one_mem 1 hS.one_mem

omit [DecidableEq G] in
/-- **Abelian fields have complete channels.**  If the Galois group is abelian then the
residue dial reads the splitting type perfectly: the channel carries the entire type
entropy `H(T)`, for every type readout `T`.  (This is the abelian pair of the law
table: `V₄` and `C₄` sit exactly at `H(T)`.) -/
theorem typeChannel_abelian_eq_entropy (hS : IsSubgroupFinset S)
    (hab : ∀ a ∈ S, ∀ b ∈ S, a * b = b * a) (hd : IsDerivedFinset S N)
    (hc : IsCosetReadout S N c) (T : G → τ) :
    mutualInfo S c T = entropy S T := by
  have hN : N = {1} := derived_eq_one_of_abelian hS hab hd
  refine mutualInfo_eq_entropy_of_injOn (fun a ha b hb hcc => ?_)
  have := (hc a ha b hb).mp hcc
  rw [hN, Finset.mem_singleton] at this
  exact mul_inv_eq_one.mp this

omit [Group G] [DecidableEq G] in
/-- **Where the deficit comes from.**  If a single abelianization coset carries two
different splitting types, the channel is strictly below the type entropy: the residue
dial cannot resolve the type.  This is exactly the `S₄` situation, where the coset `A₄`
carries the types `[1,1,1,1]`, `[2,2]` and `[3,1]`. -/
theorem typeChannel_lt_entropy_of_coset_splits {a b : G} (ha : a ∈ S) (hb : b ∈ S)
    (hcoset : c a = c b) (htype : T a ≠ T b) :
    mutualInfo S c T < entropy S T := by
  rcases lt_or_eq_of_le (mutualInfo_le_right S c T) with h | h
  · exact h
  · exact absurd (mutualInfo_eq_entropy_iff.mp h a ha b hb hcoset) htype

end GroupLevel

end TypeChannel