/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression VI: List Decoding and the Rate–List Trade-off

## Bridge: Markov's inequality (probability) ↔ pigeonhole counting (combinatorics)

A list decoder answers with a short set of candidates instead of a single
symbol.  This relaxes the pigeonhole bound a second time — now by the list size
`T` rather than by the failure probability — and it *simultaneously* improves
the achievable failure probability, because a codeword only has to be discarded
when more than `T` codebook entries collide.

Main results:

* `card_listSuccessSet_le` / `list_card_code_ge_of_success` — **converse**:
  a decoder emitting lists of length `≤ T` has `P(success) ≤ T·|Code|·p_max`,
  i.e. `log|Code| + log T ≥ H_∞ + log(1−ε)`.  At `T = 1` this is the ordinary
  relaxed pigeonhole bound.
* `card_badKeysT_mul_le` — **Markov step**: at most a `|S|/(T·M)` fraction of
  keys give `x` more than `T` collision partners.
* `exists_list_almost_lossless_scheme` — **achievability**: an explicit key with
  failure probability `≤ δ + |S|/(T·M)`, decoding cost still exactly `|S|`, and
  the guarantee that a non-empty answer *always contains the true symbol*.

So list size `T` buys a factor `T` in the failure probability and costs
`log T` bits in the converse: the two sides of the trade-off match.

## Impact: list_decoding_tradeoff, no_silent_corruption
-/

import Mathlib
import Bridges.AlmostLosslessRandomCoding

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

/-! ## Section 1: List schemes and the rate–list converse -/

section ListConverse

variable {α : Type*} [Fintype α] [DecidableEq α] {Code : Type*}

/-- A compression scheme whose decoder returns a *list* of candidates.  An empty
list means "I abstain". -/
structure ListScheme (α : Type*) (Code : Type*) where
  /-- The encoder. -/
  enc : α → Code
  /-- The list decoder. -/
  dec : Code → List α

/-- The list decoder succeeds when the true symbol is among the candidates. -/
def ListScheme.Succeeds (s : ListScheme α Code) (x : α) : Prop :=
  x ∈ s.dec (s.enc x)

instance (s : ListScheme α Code) : DecidablePred s.Succeeds :=
  fun _ => by unfold ListScheme.Succeeds; infer_instance

/-- The set of symbols recovered by the list decoder. -/
def listSuccessSet (s : ListScheme α Code) : Finset α :=
  Finset.univ.filter s.Succeeds

/-- **Pigeonhole for list decoders.**  Each codeword can rescue at most `T`
symbols, so at most `T·|Code|` symbols are recovered. -/
theorem card_listSuccessSet_le [Fintype Code] [DecidableEq Code]
    (s : ListScheme α Code) (T : ℕ) (hT : ∀ c, (s.dec c).length ≤ T) :
    (listSuccessSet s).card ≤ Fintype.card Code * T := by
  classical
  have hsub : listSuccessSet s ⊆
      (Finset.univ : Finset Code).biUnion (fun c => (s.dec c).toFinset) := by
    intro x hx
    simp only [listSuccessSet, Finset.mem_filter, Finset.mem_univ, true_and] at hx
    exact Finset.mem_biUnion.mpr ⟨s.enc x, Finset.mem_univ _, List.mem_toFinset.mpr hx⟩
  calc (listSuccessSet s).card
      ≤ ((Finset.univ : Finset Code).biUnion (fun c => (s.dec c).toFinset)).card :=
        Finset.card_le_card hsub
    _ ≤ ∑ c : Code, ((s.dec c).toFinset).card := Finset.card_biUnion_le
    _ ≤ ∑ _c : Code, T :=
        Finset.sum_le_sum fun c _ => le_trans (List.toFinset_card_le _) (hT c)
    _ = Fintype.card Code * T := by
        simp [Finset.sum_const, Finset.card_univ, smul_eq_mul]

/-- Success probability of a list scheme. -/
noncomputable def listSuccessProb (μ : FinProbDist α) (s : ListScheme α Code) : ℝ :=
  setMass μ (listSuccessSet s)

/-- **The counting bound relaxes by the list size.**
`P(success) ≤ T·|Code|·p_max`. -/
theorem listSuccessProb_le [Nonempty α] [Fintype Code] [DecidableEq Code]
    (μ : FinProbDist α) (s : ListScheme α Code) (T : ℕ)
    (hT : ∀ c, (s.dec c).length ≤ T) :
    listSuccessProb μ s ≤ ((Fintype.card Code * T : ℕ) : ℝ) * maxMass μ := by
  refine (setMass_le_card_mul_maxMass μ _).trans ?_
  exact mul_le_mul_of_nonneg_right
    (by exact_mod_cast card_listSuccessSet_le s T hT) (le_of_lt (maxMass_pos μ))

/-- **Rate–list-size trade-off (converse).**  A list decoder of list size `T`
achieving success probability `1 - ε` needs `T·|Code| ≥ (1-ε)/p_max`; in
entropy form, `log|Code| + log T ≥ H_∞(μ) + log(1-ε)`.  For `T = 1` this is the
almost-lossless converse of `AlmostLosslessCompression`. -/
theorem list_card_code_ge_of_success [Nonempty α] [Fintype Code] [DecidableEq Code]
    (μ : FinProbDist α) (s : ListScheme α Code) (T : ℕ) (ε : ℝ)
    (hT : ∀ c, (s.dec c).length ≤ T) (h : 1 - ε ≤ listSuccessProb μ s) :
    (1 - ε) / maxMass μ ≤ (Fintype.card Code : ℝ) * T := by
  have hp := maxMass_pos μ
  rw [div_le_iff₀ hp]
  calc 1 - ε ≤ listSuccessProb μ s := h
    _ ≤ ((Fintype.card Code * T : ℕ) : ℝ) * maxMass μ := listSuccessProb_le μ s T hT
    _ = (Fintype.card Code : ℝ) * T * maxMass μ := by push_cast; ring

end ListConverse

/-! ## Section 2: The Markov step -/

section Markov

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- Keys for which `x` has at least `T` collision partners in the codebook. -/
def badKeysT (H : Fin K → α → Fin M) (S : Finset α) (x : α) (T : ℕ) : Finset (Fin K) :=
  Finset.univ.filter (fun k => T ≤ (collisionSet H k S x).card)

omit [Fintype α] in
/-- The total number of (key, collision partner) incidences is controlled by
2-universality. -/
theorem sum_card_collisionSet_mul_le {H : Fin K → α → Fin M} (hU : Universal2 H)
    (S : Finset α) (x : α) :
    (∑ k : Fin K, ((collisionSet H k S x).card : ℝ)) * M ≤ (K : ℝ) * S.card := by
  classical
  have hswap : ∑ k : Fin K, ((collisionSet H k S x).card : ℝ)
      = ∑ y ∈ S.erase x, ((Finset.univ.filter (fun k => H k y = H k x)).card : ℝ) := by
    have h1 : ∀ k : Fin K, ((collisionSet H k S x).card : ℝ)
        = ∑ y ∈ S.erase x, (if H k y = H k x then (1 : ℝ) else 0) := by
      intro k
      rw [← Finset.sum_filter]
      simp [collisionSet, Finset.sum_const]
    have h2 : ∀ y : α, ((Finset.univ.filter (fun k => H k y = H k x)).card : ℝ)
        = ∑ k : Fin K, (if H k y = H k x then (1 : ℝ) else 0) := by
      intro y
      rw [← Finset.sum_filter]
      simp [Finset.sum_const]
    simp_rw [h1, h2]
    rw [Finset.sum_comm]
  rw [hswap, Finset.sum_mul]
  calc ∑ y ∈ S.erase x, ((Finset.univ.filter (fun k => H k y = H k x)).card : ℝ) * M
      ≤ ∑ _y ∈ S.erase x, (K : ℝ) :=
        Finset.sum_le_sum fun y hy => hU y x (Finset.mem_erase.mp hy).1
    _ = ((S.erase x).card : ℝ) * K := by simp [Finset.sum_const, nsmul_eq_mul]
    _ ≤ (S.card : ℝ) * K := by
        have : ((S.erase x).card : ℝ) ≤ (S.card : ℝ) := by
          exact_mod_cast Finset.card_le_card (Finset.erase_subset _ _)
        exact mul_le_mul_of_nonneg_right this (Nat.cast_nonneg K)
    _ = (K : ℝ) * S.card := by ring

omit [Fintype α] in
/-- **Markov step.**  At most a `|S|/(T·M)` fraction of the keys give `x` more
than `T` collision partners — the list-decoding refinement of
`card_badKeys_mul_le`, which is the case `T = 1`. -/
theorem card_badKeysT_mul_le {H : Fin K → α → Fin M} (hU : Universal2 H)
    (S : Finset α) (x : α) (T : ℕ) :
    (T : ℝ) * ((badKeysT H S x T).card : ℝ) * M ≤ (K : ℝ) * S.card := by
  classical
  have hstep : (T : ℝ) * ((badKeysT H S x T).card : ℝ)
      ≤ ∑ k : Fin K, ((collisionSet H k S x).card : ℝ) := by
    calc (T : ℝ) * ((badKeysT H S x T).card : ℝ)
        = ∑ _k ∈ badKeysT H S x T, (T : ℝ) := by
          simp [Finset.sum_const, nsmul_eq_mul, mul_comm]
      _ ≤ ∑ k ∈ badKeysT H S x T, ((collisionSet H k S x).card : ℝ) := by
          refine Finset.sum_le_sum fun k hk => ?_
          simp only [badKeysT, Finset.mem_filter, Finset.mem_univ, true_and] at hk
          exact_mod_cast hk
      _ ≤ ∑ k : Fin K, ((collisionSet H k S x).card : ℝ) :=
          Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
            (fun k _ _ => Nat.cast_nonneg _)
  have hM : (0 : ℝ) ≤ (M : ℝ) := Nat.cast_nonneg M
  calc (T : ℝ) * ((badKeysT H S x T).card : ℝ) * M
      ≤ (∑ k : Fin K, ((collisionSet H k S x).card : ℝ)) * M :=
        mul_le_mul_of_nonneg_right hstep hM
    _ ≤ (K : ℝ) * S.card := sum_card_collisionSet_mul_le hU S x

end Markov

/-! ## Section 3: The list-decoding scheme -/

section ListScheme

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- The list decoder: return all codebook entries matching the codeword, unless
there are more than `T` of them, in which case abstain (empty list). -/
def listDecodeT (T : ℕ) (h : α → Fin M) (l : List α) (i : Fin M) : List α :=
  if ((scanCost h i l).1).length ≤ T then (scanCost h i l).1 else []

/-- The list-decoding compression scheme. -/
def listHashScheme (T : ℕ) (l : List α) (h : α → Fin M) : ListScheme α (Fin M) where
  enc := h
  dec := listDecodeT T h l

omit [Fintype α] [DecidableEq α] in
/-- The answer is always short. -/
theorem listDecodeT_length_le (T : ℕ) (h : α → Fin M) (l : List α) (i : Fin M) :
    (listDecodeT T h l i).length ≤ T := by
  unfold listDecodeT
  split
  · assumption
  · simp

omit [Fintype α] [DecidableEq α] in
/-- **Never misleading.**  If the decoder returns a non-empty candidate list for
a codebook symbol, that symbol is on the list: there is no silent corruption,
only abstention. -/
theorem listDecodeT_contains_of_ne_nil {T : ℕ} {h : α → Fin M} {l : List α} {x : α}
    (hx : x ∈ l) (hne : listDecodeT T h l (h x) ≠ []) :
    x ∈ listDecodeT T h l (h x) := by
  unfold listDecodeT at hne ⊢
  by_cases hle : ((scanCost h (h x) l).1).length ≤ T
  · rw [if_pos hle]
    rw [scanCost_fst, List.mem_filter]
    exact ⟨hx, by simp⟩
  · rw [if_neg hle] at hne; exact absurd rfl hne

omit [Fintype α] in
/-- The number of matches is one more than the number of collision partners. -/
theorem length_matches_eq (h : α → Fin M) {l : List α} (hnd : l.Nodup) {x : α}
    (hx : x ∈ l) :
    ((scanCost h (h x) l).1).length
      = (collisionSet (fun _ : Fin 1 => h) 0 l.toFinset x).card + 1 := by
  classical
  rw [scanCost_fst]
  have hfilter_nodup : (l.filter (fun y => decide (h y = h x))).Nodup := hnd.filter _
  have h1 : (l.filter (fun y => decide (h y = h x))).length
      = (l.toFinset.filter (fun y => h y = h x)).card := by
    rw [← List.toFinset_card_of_nodup hfilter_nodup, List.toFinset_filter]
    simp
  rw [h1]
  have hins : l.toFinset.filter (fun y => h y = h x)
      = insert x (collisionSet (fun _ : Fin 1 => h) 0 l.toFinset x) := by
    ext y
    simp only [collisionSet, Finset.mem_filter, Finset.mem_insert, Finset.mem_erase,
      List.mem_toFinset]
    constructor
    · rintro ⟨hyl, hyh⟩
      by_cases hyx : y = x
      · exact Or.inl hyx
      · exact Or.inr ⟨⟨hyx, hyl⟩, hyh⟩
    · rintro (rfl | ⟨⟨_, hyl⟩, hyh⟩)
      · exact ⟨hx, rfl⟩
      · exact ⟨hyl, hyh⟩
  rw [hins, Finset.card_insert_of_notMem (by simp [collisionSet])]

end ListScheme

/-! ## Section 4: Achievability for list decoding -/

section ListAchievability

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- Averaged over the keys, the mass of symbols with more than `T` collision
partners is at most `|S|/(T·M)`. -/
theorem sum_badT_mass_le (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (S A : Finset α) (T : ℕ) :
    (T : ℝ) * (M : ℝ) *
        ∑ k : Fin K, setMass μ (A.filter (fun x => T ≤ (collisionSet H k S x).card))
      ≤ (K : ℝ) * S.card * setMass μ A := by
  classical
  have hinner : ∀ x : α,
      ∑ k : Fin K, (if T ≤ (collisionSet H k S x).card then μ.mass x else 0)
        = ((badKeysT H S x T).card : ℝ) * μ.mass x := by
    intro x
    rw [← Finset.sum_filter]
    simp [badKeysT, Finset.sum_const, nsmul_eq_mul]
  have hswap : ∑ k : Fin K,
        setMass μ (A.filter (fun x => T ≤ (collisionSet H k S x).card))
      = ∑ x ∈ A, ((badKeysT H S x T).card : ℝ) * μ.mass x := by
    unfold setMass
    simp_rw [Finset.sum_filter]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl fun x _ => hinner x
  rw [hswap, Finset.mul_sum]
  have hbound : ∀ x ∈ A, (T : ℝ) * (M : ℝ) * (((badKeysT H S x T).card : ℝ) * μ.mass x)
      ≤ ((K : ℝ) * S.card) * μ.mass x := by
    intro x _
    have h1 := card_badKeysT_mul_le hU S x T
    have h2 : (0 : ℝ) ≤ μ.mass x := μ.mass_nonneg x
    nlinarith [h1, h2]
  calc ∑ x ∈ A, (T : ℝ) * (M : ℝ) * (((badKeysT H S x T).card : ℝ) * μ.mass x)
      ≤ ∑ x ∈ A, ((K : ℝ) * S.card) * μ.mass x := Finset.sum_le_sum hbound
    _ = (K : ℝ) * S.card * setMass μ A := by rw [← Finset.mul_sum]; rfl

/-- Derandomization of the Markov bound: a single key whose `T`-collision mass
is at most `|S|/(T·M)`. -/
theorem exists_good_key_T (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (S A : Finset α) (T : ℕ) :
    ∃ k : Fin K, (T : ℝ) * (M : ℝ) *
        setMass μ (A.filter (fun x => T ≤ (collisionSet H k S x).card))
      ≤ (S.card : ℝ) * setMass μ A := by
  classical
  have hne : (Finset.univ : Finset (Fin K)).Nonempty := by
    have : Nonempty (Fin K) := ⟨⟨0, hK⟩⟩
    exact Finset.univ_nonempty
  have hR : ∑ _k : Fin K, ((S.card : ℝ) * setMass μ A)
      = (K : ℝ) * S.card * setMass μ A := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    ring
  have hsum : ∑ k : Fin K, ((T : ℝ) * (M : ℝ) *
        setMass μ (A.filter (fun x => T ≤ (collisionSet H k S x).card)))
      ≤ ∑ _k : Fin K, ((S.card : ℝ) * setMass μ A) := by
    rw [← Finset.mul_sum, hR]
    exact sum_badT_mass_le μ hU S A T
  obtain ⟨k, _, hk⟩ := Finset.exists_le_of_sum_le hne hsum
  exact ⟨k, hk⟩

/-- **List-decoding achievability.**  With list size `T ≥ 1`, an explicit key of
the universal family gives a scheme that

* fails with probability at most `δ + |l|/(T·M)` — a factor `T` better than the
  unique-decoding bound `δ + |l|/M`;
* never misleads: a non-empty answer always contains the true symbol
  (`listDecodeT_contains_of_ne_nil`);
* returns at most `T` candidates and still costs exactly `|l|` steps.
-/
theorem exists_list_almost_lossless_scheme (μ : FinProbDist α) {H : Fin K → α → Fin M}
    (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M) (T : ℕ) (hT : 0 < T)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter
          (fun x => ¬ (listHashScheme T l (H k)).Succeeds x))
          ≤ δ + (l.length : ℝ) / (T * M)
      ∧ (∀ i : Fin M, ((listHashScheme T l (H k)).dec i).length ≤ T)
      ∧ ∀ i : Fin M, (scanCost (H k) i l).2 = l.length := by
  classical
  obtain ⟨k, hk⟩ := exists_good_key_T μ hU hK l.toFinset Finset.univ T
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hTR : (0 : ℝ) < T := by exact_mod_cast hT
  have hcard : (l.toFinset.card : ℝ) = (l.length : ℝ) := by
    rw [List.toFinset_card_of_nodup hnd]
  set C : Finset α :=
    Finset.univ.filter (fun x => T ≤ (collisionSet H k l.toFinset x).card) with hC
  have hCbound : setMass μ C ≤ (l.length : ℝ) / (T * M) := by
    rw [le_div_iff₀ (by positivity)]
    have h2 := hk
    rw [setMass_univ, mul_one, hcard] at h2
    nlinarith [h2]
  refine ⟨k, ?_, fun i => listDecodeT_length_le T _ l i, fun i => scanCost_snd _ _ _⟩
  have hsub : Finset.univ.filter (fun x => ¬ (listHashScheme T l (H k)).Succeeds x)
      ⊆ (l.toFinset)ᶜ ∪ C := by
    intro x hx
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
    rw [Finset.mem_union]
    by_cases hxl : x ∈ l.toFinset
    · right
      rw [hC, Finset.mem_filter]
      refine ⟨Finset.mem_univ _, ?_⟩
      by_contra hlt
      push_neg at hlt
      -- few collisions ⇒ the match list is short ⇒ `x` is returned
      refine hx ?_
      have hxl' : x ∈ l := List.mem_toFinset.mp hxl
      have hlen : ((scanCost (H k) (H k x) l).1).length ≤ T := by
        have := length_matches_eq (H k) hnd hxl'
        have hcc : (collisionSet (fun _ : Fin 1 => H k) 0 l.toFinset x).card
            = (collisionSet H k l.toFinset x).card := by
          unfold collisionSet; rfl
        omega
      show x ∈ listDecodeT T (H k) l ((listHashScheme T l (H k)).enc x)
      unfold listHashScheme listDecodeT
      simp only [if_pos hlen]
      rw [scanCost_fst, List.mem_filter]
      exact ⟨hxl', by simp⟩
    · left; exact Finset.mem_compl.mpr hxl
  calc setMass μ (Finset.univ.filter (fun x => ¬ (listHashScheme T l (H k)).Succeeds x))
      ≤ setMass μ ((l.toFinset)ᶜ ∪ C) := setMass_mono μ hsub
    _ ≤ setMass μ (l.toFinset)ᶜ + setMass μ C := setMass_union_le μ _ _
    _ ≤ δ + (l.length : ℝ) / (T * M) := add_le_add hδ hCbound

end ListAchievability

end AlmostLossless