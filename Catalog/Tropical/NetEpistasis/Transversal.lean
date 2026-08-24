/-
# Epistasis is a hitting-set phenomenon

This file explains *why* joint ablations can cost far more than the sum of solo
ablations, in purely combinatorial terms.

For a tolerance `ε` let `NearOpt N ε` be the family of paths whose loss is within
`ε` of the unpruned optimum.  Then:

* `lt_cost_iff_transversal` — pruning a set `S` of layers costs more than `ε`
  **iff** `S` is a *transversal* (hitting set) of the near-optimal path family.
* `epiOrder` — the least size of such a transversal.  Every smaller layer set is
  cheap (`cost_le_of_card_lt_epiOrder`) and the minimum is attained
  (`exists_expensive_card_eq_epiOrder`); so the "order at which epistasis lives"
  is exactly a hypergraph transversal number (`epiOrder_eq_two`).
* `coadaptation_of_pure_epistasis` — if two layers are individually free but
  jointly costly, then every backup path for one of them necessarily routes
  through the other: the pair is a *coordinated unit*.

This is the formal content of the NET-60 verdict: the tail pair is a minimal
size-2 transversal of the near-optimal path hypergraph, whereas front/bulk pairs
are unions of two independent size-1 transversals (hence merely additive or
sub-additive).
-/
import Tropical.NetEpistasis.Representation

namespace NetEpistasis

open Finset

variable {n : ℕ} {N : PrunableNet n}

/-- The paths whose loss is within `ε` of the unpruned optimum. -/
noncomputable def NearOpt (N : PrunableNet n) (ε : ℚ) : Finset N.ι :=
  Finset.univ.filter fun i => N.loss i ≤ netLoss N ∅ + ε

@[simp] lemma mem_nearOpt {ε : ℚ} {i : N.ι} :
    i ∈ NearOpt N ε ↔ N.loss i ≤ netLoss N ∅ + ε := by simp [NearOpt]

/-- `S` is a transversal (hitting set) of the `ε`-near-optimal path family: it
touches the support of every near-optimal path. -/
def Transversal (N : PrunableNet n) (ε : ℚ) (S : Finset (Fin n)) : Prop :=
  ∀ i ∈ NearOpt N ε, ¬ Disjoint (N.supp i) S

/-- **Hitting-set characterization of pruning cost.**  Pruning `S` costs strictly
more than `ε` exactly when `S` hits every `ε`-near-optimal path. -/
theorem lt_cost_iff_transversal (ε : ℚ) (S : Finset (Fin n)) :
    ε < cost N S ↔ Transversal N ε S := by
  constructor
  · intro h i hi hdisj
    have h1 : netLoss N S ≤ N.loss i := netLoss_le hdisj
    have h2 : N.loss i ≤ netLoss N ∅ + ε := mem_nearOpt.mp hi
    have : cost N S ≤ ε := by
      simp only [cost, sub_le_iff_le_add]
      linarith
    exact absurd h (not_lt.mpr this)
  · intro hT
    obtain ⟨i, hi, hval⟩ := exists_netLoss_eq (N := N) S
    have hnot : ¬ (N.loss i ≤ netLoss N ∅ + ε) := fun hle => hT i (mem_nearOpt.mpr hle) hi
    have : netLoss N ∅ + ε < N.loss i := lt_of_not_ge hnot
    have hSval : netLoss N ∅ + ε < netLoss N S := by rw [← hval]; exact this
    simp only [cost]
    linarith

/-- Contrapositive form: a set that misses some near-optimal path is cheap. -/
theorem cost_le_of_exists_survivor {ε : ℚ} {S : Finset (Fin n)} {i : N.ι}
    (hi : N.loss i ≤ netLoss N ∅ + ε) (hdisj : Disjoint (N.supp i) S) :
    cost N S ≤ ε := by
  by_contra h
  exact (lt_cost_iff_transversal ε S).mp (lt_of_not_ge h) i (mem_nearOpt.mpr hi) hdisj

/-- The **epistasis order** at tolerance `ε`: the least number of layers whose
joint pruning costs more than `ε`.  By `lt_cost_iff_transversal` this is the
transversal number of the near-optimal path hypergraph. -/
noncomputable def epiOrder (N : PrunableNet n) (ε : ℚ) : ℕ :=
  sInf {k | ∃ S : Finset (Fin n), S.card = k ∧ ε < cost N S}

/-- Below the epistasis order everything is cheap: no set of fewer layers can
cost more than `ε`. -/
theorem cost_le_of_card_lt_epiOrder {ε : ℚ} {S : Finset (Fin n)}
    (h : S.card < epiOrder N ε) : cost N S ≤ ε := by
  by_contra hc
  have hmem : S.card ∈ {k | ∃ S : Finset (Fin n), S.card = k ∧ ε < cost N S} :=
    ⟨S, rfl, lt_of_not_ge hc⟩
  exact absurd (Nat.sInf_le hmem) (not_le.mpr h)

/-- The epistasis order is attained: there is an expensive set of exactly that
many layers. -/
theorem exists_expensive_card_eq_epiOrder {ε : ℚ} (h : ∃ T : Finset (Fin n), ε < cost N T) :
    ∃ S : Finset (Fin n), S.card = epiOrder N ε ∧ ε < cost N S := by
  obtain ⟨T, hT⟩ := h
  have hne : {k | ∃ S : Finset (Fin n), S.card = k ∧ ε < cost N S}.Nonempty :=
    ⟨T.card, T, rfl, hT⟩
  obtain ⟨S, hS, hcost⟩ := Nat.sInf_mem hne
  exact ⟨S, hS, hcost⟩

/-- **The epistasis lives at order two.**  If every single layer is affordable at
tolerance `ε ≥ 0` but some pair is not, the epistasis order is exactly `2`: the
near-optimal path hypergraph has no size-1 transversal but does have a size-2
one. -/
theorem epiOrder_eq_two {ε : ℚ} (hε : 0 ≤ ε) (hsolo : ∀ i : Fin n, cost N {i} ≤ ε)
    {a b : Fin n} (hpair : ε < cost N {a, b}) : epiOrder N ε = 2 := by
  have hab : a ≠ b := by
    rintro rfl
    rw [Finset.insert_eq_self.mpr (Finset.mem_singleton_self a)] at hpair
    exact absurd (hsolo a) (not_le.mpr hpair)
  have hcard : ({a, b} : Finset (Fin n)).card = 2 := by
    rw [Finset.card_insert_of_notMem (by simpa using hab), Finset.card_singleton]
  refine le_antisymm ?_ ?_
  · exact Nat.sInf_le ⟨{a, b}, hcard, hpair⟩
  · by_contra hlt
    push_neg at hlt
    obtain ⟨S, hScard, hScost⟩ :=
      exists_expensive_card_eq_epiOrder (N := N) (ε := ε) ⟨{a, b}, hpair⟩
    have hlt2 : S.card < 2 := by omega
    have hcases : S.card = 0 ∨ S.card = 1 := by omega
    rcases hcases with h | h
    · have hS0 : S = ∅ := Finset.card_eq_zero.mp h
      subst hS0
      simp only [cost_empty] at hScost
      exact absurd hε (not_le.mpr hScost)
    · obtain ⟨i, rfl⟩ := Finset.card_eq_one.mp h
      exact absurd (hsolo i) (not_le.mpr hScost)

/-!
### Epistasis of arbitrary order

The tail pair realizes order two.  Nothing stops higher orders: for every
`k`-element block of layers there is a tropical net in which every set of fewer
than `k` layers is free and the block itself is costly.  This is the formal
prediction behind "deeper-tail units on larger models".
-/

/-- The profile that charges `r` exactly when the whole block `K` is pruned. -/
def blockProfile (K : Finset (Fin n)) (r : ℚ) : Finset (Fin n) → ℚ :=
  fun S => if K ⊆ S then r else 0

lemma blockProfile_mono {K : Finset (Fin n)} {r : ℚ} (hr : 0 ≤ r) :
    ∀ S T : Finset (Fin n), S ⊆ T → blockProfile K r S ≤ blockProfile K r T := by
  intro S T hST
  by_cases h : K ⊆ S
  · simp [blockProfile, h, h.trans hST]
  · by_cases h' : K ⊆ T <;> simp [blockProfile, h, h', hr]

lemma cost_blockProfile {K : Finset (Fin n)} (hK : K.Nonempty) {r : ℚ} (hr : 0 < r)
    (S : Finset (Fin n)) :
    cost (ofProfile (blockProfile K r)) S = if K ⊆ S then r else 0 := by
  refine cost_ofProfile ?_ (blockProfile_mono hr.le) S
  obtain ⟨x, hx⟩ := hK
  have : ¬ K ⊆ (∅ : Finset (Fin n)) := fun h => absurd (h hx) (by simp)
  simp [blockProfile, this]

/-- **Epistasis can live at any order.**  For a block `K` of `k` layers there is
a tropical net whose epistasis order is exactly `k`: every collection of fewer
than `k` layers is free, and the block costs `r`. -/
theorem epiOrder_block_eq_card {K : Finset (Fin n)} (hK : K.Nonempty) {r : ℚ} (hr : 0 < r) :
    epiOrder (ofProfile (blockProfile K r)) 0 = K.card := by
  set M := ofProfile (blockProfile K r) with hM
  have hcost : ∀ S, cost M S = if K ⊆ S then r else 0 := cost_blockProfile hK hr
  have hKcost : (0 : ℚ) < cost M K := by rw [hcost]; simpa using hr
  refine le_antisymm (Nat.sInf_le ⟨K, rfl, hKcost⟩) ?_
  obtain ⟨S, hScard, hScost⟩ :=
    exists_expensive_card_eq_epiOrder (N := M) (ε := 0) ⟨K, hKcost⟩
  have hKS : K ⊆ S := by
    by_contra hsub
    rw [hcost, if_neg hsub] at hScost
    exact lt_irrefl 0 hScost
  rw [← hScard]
  exact Finset.card_le_card hKS

/-- **Co-adaptation at tolerance `ε`.**  Suppose two layers are individually
affordable (solo cost at most `ε`) but their joint pruning costs more than `ε`.
Then every `ε`-near-optimal backup path that avoids `a` must route through `b`,
and vice versa: the two layers back each other up and nothing else does.  This is
the precise sense in which such a pair is a single coordinated unit. -/
theorem coadaptation_of_pair_epistasis {ε : ℚ} {a b : Fin n}
    (ha : cost N {a} ≤ ε) (hb : cost N {b} ≤ ε) (hab : ε < cost N ({a} ∪ {b})) :
    (∃ p : N.ι, N.loss p ≤ netLoss N ∅ + ε ∧ a ∉ N.supp p ∧ b ∈ N.supp p) ∧
      (∃ q : N.ι, N.loss q ≤ netLoss N ∅ + ε ∧ b ∉ N.supp q ∧ a ∈ N.supp q) := by
  have hT : Transversal N ε ({a} ∪ {b}) := (lt_cost_iff_transversal ε _).mp hab
  have key : ∀ {x y : Fin n}, cost N {x} ≤ ε →
      ({x} ∪ {y} : Finset (Fin n)) = ({a} ∪ {b} : Finset (Fin n)) →
      ∃ p : N.ι, N.loss p ≤ netLoss N ∅ + ε ∧ x ∉ N.supp p ∧ y ∈ N.supp p := by
    intro x y hx hxy
    obtain ⟨p, hp, hval⟩ := exists_netLoss_eq (N := N) {x}
    have hloss : N.loss p ≤ netLoss N ∅ + ε := by
      have hcost : netLoss N {x} - netLoss N ∅ ≤ ε := hx
      rw [hval]; linarith
    have hxnot : x ∉ N.supp p := fun hmem =>
      (Finset.disjoint_right.mp hp (Finset.mem_singleton_self x)) hmem
    have hhit : ¬ Disjoint (N.supp p) ({a} ∪ {b}) := hT p (mem_nearOpt.mpr hloss)
    rw [← hxy] at hhit
    have hy : y ∈ N.supp p := by
      by_contra hyn
      refine hhit ?_
      rw [Finset.disjoint_union_right]
      exact ⟨Finset.disjoint_singleton_right.mpr hxnot,
        Finset.disjoint_singleton_right.mpr hyn⟩
    exact ⟨p, hloss, hxnot, hy⟩
  exact ⟨key ha rfl, key hb (Finset.union_comm _ _)⟩

/-- The zero-tolerance case: two layers that are *free* on their own but costly
together are backed up only through each other. -/
theorem coadaptation_of_pure_epistasis {a b : Fin n}
    (ha : cost N {a} = 0) (hb : cost N {b} = 0) (hab : 0 < cost N ({a} ∪ {b})) :
    (∃ p : N.ι, N.loss p = netLoss N ∅ ∧ a ∉ N.supp p ∧ b ∈ N.supp p) ∧
      (∃ q : N.ι, N.loss q = netLoss N ∅ ∧ b ∉ N.supp q ∧ a ∈ N.supp q) := by
  obtain ⟨⟨p, hp, hpa, hpb⟩, ⟨q, hq, hqb, hqa⟩⟩ :=
    coadaptation_of_pair_epistasis (N := N) (ε := 0) ha.le hb.le hab
  have hple : netLoss N ∅ ≤ N.loss p := netLoss_le (by simp)
  have hqle : netLoss N ∅ ≤ N.loss q := netLoss_le (by simp)
  refine ⟨⟨p, le_antisymm (by linarith [hp]) hple, hpa, hpb⟩,
    ⟨q, le_antisymm (by linarith [hq]) hqle, hqb, hqa⟩⟩

end NetEpistasis