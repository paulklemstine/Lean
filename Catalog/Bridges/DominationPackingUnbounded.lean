import Bridges.DominationPackingRatio

/-!
# The domination–packing ratio is unbounded for general graphs

The paper *Domination-packing ratio for planar and unit disk graphs* bounds `γ/ρ` for two
geometric graph classes.  This file explains why a graph class is needed at all: over *all*
finite graphs the ratio is unbounded, so no Erdős–Pósa bound `γ ≤ c·ρ` can hold in general.

The witness is an extremal-set-theoretic construction ("spread graph").  Fix `k` and `t` with
`k < 2t`:

* the vertices are the `k` *indices* `Fin k`, forming a clique, together with all `t`-element
  subsets `S ⊆ Fin k`, forming an independent set;
* an index `i` is adjacent to a subset `S` exactly when `i ∈ S`.

Because `k < 2t`, any two `t`-subsets intersect, and every ball contains an index; hence *all*
radius-`1` balls pairwise meet and `ρ = 1` (`spreadGraph_packingNumber`).  On the other hand a
dominating set must, for every `t`-subset `S` avoiding its chosen indices, contain `S` itself,
and the number of such subsets is large; this yields `γ ≥ k - t + 1`
(`spreadGraph_dominationNumber_ge`).

Taking `k = 2m`, `t = m+1` gives graphs with `ρ = 1` and `γ ≥ m`
(`exists_packing_one_domination_large`), so `sup γ/ρ = ∞` over all finite graphs.  This is a
sharp contrast with the verified bounds `γ ≤ (Δ+1)·ρ`, `γ ≤ 25·ρ` (unit disk) of
`Bridges.DominationPackingRatio`.
-/

namespace DominationPacking

open Finset

/-- The `t`-element subsets of `Fin k`, as a type. -/
abbrev TSet (k t : ℕ) := {S : Finset (Fin k) // S.card = t}

/-- The **spread graph**: a clique of `k` indices together with an independent set of all
`t`-subsets, an index being adjacent to the subsets containing it. -/
def spreadGraph (k t : ℕ) : SimpleGraph (Fin k ⊕ TSet k t) where
  Adj x y :=
    match x, y with
    | Sum.inl i, Sum.inl j => i ≠ j
    | Sum.inl i, Sum.inr S => i ∈ S.1
    | Sum.inr S, Sum.inl j => j ∈ S.1
    | Sum.inr _, Sum.inr _ => False
  symm := by
    intro x y h
    cases x with
    | inl i =>
      cases y with
      | inl j => exact fun hji => h hji.symm
      | inr T => exact h
    | inr S =>
      cases y with
      | inl j => exact h
      | inr T => exact h.elim
  loopless := by
    refine ⟨?_⟩
    intro x
    cases x <;> simp

lemma spreadGraph_adj_inl_inl {k t : ℕ} {i j : Fin k} :
    (spreadGraph k t).Adj (Sum.inl i) (Sum.inl j) ↔ i ≠ j := Iff.rfl

lemma spreadGraph_adj_inl_inr {k t : ℕ} {i : Fin k} {S : TSet k t} :
    (spreadGraph k t).Adj (Sum.inl i) (Sum.inr S) ↔ i ∈ S.1 := Iff.rfl

lemma spreadGraph_adj_inr_inl {k t : ℕ} {j : Fin k} {S : TSet k t} :
    (spreadGraph k t).Adj (Sum.inr S) (Sum.inl j) ↔ j ∈ S.1 := Iff.rfl

lemma spreadGraph_not_adj_inr_inr {k t : ℕ} {S T : TSet k t} :
    ¬ (spreadGraph k t).Adj (Sum.inr S) (Sum.inr T) := id

/-- Every index of a subset `S` lies in the ball of `S`. -/
lemma inl_mem_ball_inr {k t : ℕ} {j : Fin k} {S : TSet k t} (hj : j ∈ S.1) :
    (Sum.inl j : Fin k ⊕ TSet k t) ∈ ball (spreadGraph k t) (Sum.inr S) :=
  Or.inr hj

/-- Every index lies in the ball of every index. -/
lemma inl_mem_ball_inl {k t : ℕ} (i j : Fin k) :
    (Sum.inl j : Fin k ⊕ TSet k t) ∈ ball (spreadGraph k t) (Sum.inl i) := by
  by_cases h : j = i
  · exact Or.inl (by rw [h])
  · exact Or.inr (fun hij => h hij.symm)

/-! ## The packing number is `1` -/

/-- If `k < 2t` then any two `t`-subsets of `Fin k` meet. -/
lemma inter_nonempty_of_card {k t : ℕ} (h2t : k < 2 * t) {S T : Finset (Fin k)}
    (hS : S.card = t) (hT : T.card = t) : (S ∩ T).Nonempty := by
  rw [← Finset.card_pos]
  have hunion : (S ∪ T).card ≤ k := by
    simpa using Finset.card_le_univ (S ∪ T)
  have h := Finset.card_union_add_card_inter S T
  omega

theorem spreadGraph_packingNumber {k t : ℕ} (hk : 0 < k) (ht : 0 < t) (h2t : k < 2 * t) :
    packingNumber (spreadGraph k t) = 1 := by
  haveI : Nonempty (Fin k ⊕ TSet k t) := ⟨Sum.inl ⟨0, hk⟩⟩
  refine packingNumber_eq_one_of_pairwise_meet ?_
  intro u v huv
  rw [Set.not_disjoint_iff]
  have hne : ∀ S : TSet k t, S.1.Nonempty := by
    intro S
    rw [← Finset.card_pos, S.2]
    exact ht
  cases u with
  | inl i =>
    cases v with
    | inl j => exact ⟨Sum.inl j, inl_mem_ball_inl i j, mem_ball_self _ _⟩
    | inr T =>
      obtain ⟨j, hj⟩ := hne T
      exact ⟨Sum.inl j, inl_mem_ball_inl i j, inl_mem_ball_inr hj⟩
  | inr S =>
    cases v with
    | inl j =>
      obtain ⟨i, hi⟩ := hne S
      exact ⟨Sum.inl i, inl_mem_ball_inr hi, inl_mem_ball_inl j i⟩
    | inr T =>
      obtain ⟨j, hj⟩ := inter_nonempty_of_card h2t S.2 T.2
      rw [Finset.mem_inter] at hj
      exact ⟨Sum.inl j, inl_mem_ball_inr hj.1, inl_mem_ball_inr hj.2⟩

/-! ## The domination number is at least `k - t + 1` -/

theorem spreadGraph_dominationNumber_ge {k t : ℕ} (ht : 0 < t) (htk : t ≤ k) :
    k - t + 1 ≤ dominationNumber (spreadGraph k t) := by
  classical
  refine le_dominationNumber_of_forall ?_
  intro D hD
  set A : Finset (Fin k) := Finset.univ.filter (fun i => (Sum.inl i : Fin k ⊕ TSet k t) ∈ D)
    with hA
  set Ac : Finset (Fin k) := Finset.univ \ A with hAc
  have hAcard : A.card + Ac.card = k := by
    have h := Finset.card_sdiff_add_card_eq_card (Finset.subset_univ A)
    rw [Finset.card_univ, Fintype.card_fin] at h
    rw [hAc]
    omega
  have hAsub : A.image Sum.inl ⊆ D := by
    intro x hx
    obtain ⟨i, hi, rfl⟩ := Finset.mem_image.mp hx
    rw [hA, Finset.mem_filter] at hi
    exact hi.2
  have hAcardim : (A.image (Sum.inl : Fin k → Fin k ⊕ TSet k t)).card = A.card :=
    Finset.card_image_of_injective _ (fun a b h => by injection h)
  by_cases hcase : Ac.card < t
  · calc k - t + 1 ≤ A.card := by omega
      _ = (A.image Sum.inl).card := hAcardim.symm
      _ ≤ D.card := Finset.card_le_card hAsub
  · push_neg at hcase
    obtain ⟨S₀, hS₀sub, hS₀card⟩ := Finset.exists_subset_card_eq hcase
    obtain ⟨s₀, hs₀⟩ : S₀.Nonempty := by rw [← Finset.card_pos, hS₀card]; exact ht
    set E : Finset (Fin k) := S₀.erase s₀ with hE
    have hEcard : E.card = t - 1 := by rw [hE, Finset.card_erase_of_mem hs₀, hS₀card]
    have hEsub : E ⊆ Ac := fun x hx => hS₀sub (Finset.mem_of_mem_erase hx)
    -- every `t`-subset of `Ac` obtained by adding one element to `E` belongs to `D`
    have hins : ∀ z ∈ Ac \ E, (insert z E).card = t := by
      intro z hz
      rw [Finset.card_insert_of_notMem (Finset.mem_sdiff.mp hz).2, hEcard]
      omega
    have hmemD : ∀ (z : Fin k) (hz : z ∈ Ac \ E),
        (Sum.inr ⟨insert z E, hins z hz⟩ : Fin k ⊕ TSet k t) ∈ D := by
      intro z hz
      rcases hD (Sum.inr ⟨insert z E, hins z hz⟩) with h | ⟨d, hd, hadj⟩
      · exact h
      · exfalso
        cases d with
        | inl i =>
          have hi : i ∈ insert z E := hadj
          have hiAc : i ∈ Ac := by
            rcases Finset.mem_insert.mp hi with rfl | hi'
            · exact (Finset.mem_sdiff.mp hz).1
            · exact hEsub hi'
          rw [hAc, Finset.mem_sdiff] at hiAc
          exact hiAc.2 (by rw [hA, Finset.mem_filter]; exact ⟨Finset.mem_univ i, hd⟩)
        | inr T => exact spreadGraph_not_adj_inr_inr hadj
    set F : Finset (Fin k ⊕ TSet k t) :=
      (Ac \ E).attach.image (fun z => Sum.inr ⟨insert z.1 E, hins z.1 z.2⟩) with hF
    have hFsub : F ⊆ D := by
      intro x hx
      obtain ⟨z, -, rfl⟩ := Finset.mem_image.mp hx
      exact hmemD z.1 z.2
    have hFcard : F.card = (Ac \ E).card := by
      rw [hF, Finset.card_image_of_injective _ ?_, Finset.card_attach]
      intro z z' hzz'
      have h1 : insert z.1 E = insert z'.1 E := by
        injection hzz' with h
        exact congrArg Subtype.val h
      have hz : z.1 ∉ E := (Finset.mem_sdiff.mp z.2).2
      have hz' : z'.1 ∉ E := (Finset.mem_sdiff.mp z'.2).2
      have : z.1 ∈ insert z'.1 E := by rw [← h1]; exact Finset.mem_insert_self _ _
      rcases Finset.mem_insert.mp this with h | h
      · exact Subtype.ext h
      · exact absurd h hz
    have hdisj : Disjoint (A.image Sum.inl) F := by
      rw [Finset.disjoint_left]
      intro x hx hxF
      obtain ⟨i, -, rfl⟩ := Finset.mem_image.mp hx
      rw [hF] at hxF
      obtain ⟨z, -, hz⟩ := Finset.mem_image.mp hxF
      simp at hz
    have hsdcard : (Ac \ E).card + (t - 1) = Ac.card := by
      have h := Finset.card_sdiff_add_card_eq_card hEsub
      rw [hEcard] at h
      exact h
    have hunion : (A.image Sum.inl ∪ F) ⊆ D := Finset.union_subset hAsub hFsub
    calc k - t + 1 ≤ A.card + (Ac \ E).card := by omega
      _ = (A.image Sum.inl).card + F.card := by rw [hAcardim, hFcard]
      _ = (A.image Sum.inl ∪ F).card := (Finset.card_union_of_disjoint hdisj).symm
      _ ≤ D.card := Finset.card_le_card hunion

/-! ## Unboundedness -/

/-- **The domination–packing ratio is unbounded over all finite graphs.**  For every `m ≥ 1`
the spread graph with `k = 2m` indices and `t = m+1` has `ρ = 1` and `γ ≥ m`. -/
theorem exists_packing_one_domination_large (m : ℕ) (hm : 1 ≤ m) :
    packingNumber (spreadGraph (2 * m) (m + 1)) = 1 ∧
      m ≤ dominationNumber (spreadGraph (2 * m) (m + 1)) := by
  refine ⟨spreadGraph_packingNumber (by omega) (by omega) (by omega), ?_⟩
  have h := spreadGraph_dominationNumber_ge (k := 2 * m) (t := m + 1) (by omega) (by omega)
  omega

/-- Consequently no bound of the form `γ ≤ c·ρ + b` can hold for all finite graphs. -/
theorem no_universal_erdos_posa_bound (c b : ℕ) :
    ¬ (∀ (k t : ℕ), dominationNumber (spreadGraph k t)
        ≤ c * packingNumber (spreadGraph k t) + b) := by
  intro h
  obtain ⟨hrho, hgamma⟩ := exists_packing_one_domination_large (c + b + 1) (by omega)
  have h1 := h (2 * (c + b + 1)) (c + b + 1 + 1)
  rw [hrho] at h1
  omega

end DominationPacking