/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression X: `T`-wise Independence and Factorial Moments

## Bridge: higher independence (algebra) ↔ factorial moments (combinatorics)
##         ↔ list decoding (coding theory)

`AlmostLosslessListDecoding` bounds the failure probability of list-`T` decoding
by `δ + |S|/(T·M)`: the gain from a longer list is only **linear** in `T`,
because a first-moment (Markov) estimate on the number of collisions is all that
2-universality provides.

This file proves that higher independence turns that linear gain into an
**exponential** one, settling Conjecture 3 / sub-conjecture C3a of the previous
cycle.  The right statistic is the `T`-th *factorial* moment: instead of counting
collisions, count `T`-element sets of colliding partners.

* `IndepT` — the counting form of `(T+1)`-wise independence: for any `T` symbols
  and a distinct symbol `x`, at most a `M^{-T}` fraction of the keys make all of
  them collide with `x`;
* `universal2_of_indepT` — coherence: `IndepT H 1` is exactly 2-universality;
* `sum_choose_collisionSet_le` — **the factorial-moment identity**
  `(∑ₖ C(collisions(k), T))·M^T ≤ K·C(|S|,T)`, proved by double counting over
  `T`-subsets;
* `card_badKeysT_indep_le` — hence at most a `C(|S|,T)/M^T` fraction of keys are
  bad, versus `|S|/(T·M)` from the first moment;
* `exists_list_scheme_indepT` — **the deliverable**: list-`T` decoding with
  failure probability `≤ δ + C(|l|,T)/M^T`, list length `≤ T` and cost exactly
  `|l|`;
* `exists_list_scheme_exponential` — the readable form `δ + (|l|/M)^T`:
  exponentially small in the list size.

## Impact: factorial_moment_bound, exponential_list_decoding_gain
-/

import Mathlib
import Bridges.AlmostLosslessListDecoding

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section Independence

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-- **`(T+1)`-wise independence, counting form.**  For every set `s` of `T`
symbols and every symbol `x ∉ s`, at most a `M^{-T}` fraction of the keys send
all of `s` to the same value as `x`.  For `T = 1` this is exactly
2-universality (`universal2_of_indepT`). -/
def IndepT (H : Fin K → α → Fin M) (T : ℕ) : Prop :=
  ∀ (x : α) (s : Finset α), s.card = T → x ∉ s →
    ((Finset.univ.filter (fun k => ∀ y ∈ s, H k y = H k x)).card : ℝ) * (M : ℝ) ^ T
      ≤ K

/-- Coherence with the previous cycle: `1`-wise independence *is* 2-universality,
so all the results below strictly extend the 2-universal theory. -/
theorem universal2_of_indepT {H : Fin K → α → Fin M} (hI : IndepT H 1) :
    Universal2 H := by
  intro x y hxy
  have hs : ({y} : Finset α).card = 1 := Finset.card_singleton y
  have hx : x ∉ ({y} : Finset α) := by simpa [Finset.mem_singleton] using hxy
  have := hI x {y} hs hx
  simp only [pow_one] at this
  have heq : (Finset.univ.filter (fun k => ∀ z ∈ ({y} : Finset α), H k z = H k x))
      = Finset.univ.filter (fun k => H k x = H k y) := by
    ext k
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton,
      forall_eq]
    exact ⟨fun h => h.symm, fun h => h.symm⟩
  rwa [heq] at this

/-- **The factorial-moment identity.**  Summed over the keys, the number of
`T`-element sets of collision partners is at most `K·C(|S|,T)/M^T`.  Double
counting over `T`-subsets replaces the first moment used for 2-universality. -/
theorem sum_choose_collisionSet_le {H : Fin K → α → Fin M} {T : ℕ}
    (hI : IndepT H T) (S : Finset α) (x : α) :
    (∑ k : Fin K, ((collisionSet H k S x).card.choose T : ℝ)) * (M : ℝ) ^ T
      ≤ (K : ℝ) * (S.card.choose T : ℝ) := by
  classical
  set P : Finset (Finset α) := Finset.powersetCard T (S.erase x) with hP
  -- rewrite the binomial coefficient as a count of `T`-subsets
  have hsubC : ∀ k : Fin K, collisionSet H k S x ⊆ S.erase x := fun k => by
    unfold collisionSet
    exact Finset.filter_subset _ _
  have hpow : ∀ k : Fin K,
      Finset.powersetCard T (collisionSet H k S x)
        = P.filter (fun s => s ⊆ collisionSet H k S x) := by
    intro k
    ext s
    simp only [hP, Finset.mem_powersetCard, Finset.mem_filter]
    constructor
    · rintro ⟨h1, h2⟩
      exact ⟨⟨h1.trans (hsubC k), h2⟩, h1⟩
    · rintro ⟨⟨_, h2⟩, h3⟩
      exact ⟨h3, h2⟩
  have hcardk : ∀ k : Fin K, ((collisionSet H k S x).card.choose T : ℝ)
      = ∑ s ∈ P, (if s ⊆ collisionSet H k S x then (1 : ℝ) else 0) := by
    intro k
    rw [← Finset.sum_filter, ← hpow k]
    simp [Finset.card_powersetCard]
  have hswap : ∑ k : Fin K, ((collisionSet H k S x).card.choose T : ℝ)
      = ∑ s ∈ P,
          ((Finset.univ.filter (fun k => s ⊆ collisionSet H k S x)).card : ℝ) := by
    simp_rw [hcardk]
    rw [Finset.sum_comm]
    refine Finset.sum_congr rfl fun s _ => ?_
    rw [← Finset.sum_filter]
    simp [Finset.sum_const]
  rw [hswap, Finset.sum_mul]
  -- each `T`-subset is controlled by `T`-wise independence
  have hterm : ∀ s ∈ P,
      ((Finset.univ.filter (fun k => s ⊆ collisionSet H k S x)).card : ℝ) * (M : ℝ) ^ T
        ≤ (K : ℝ) := by
    intro s hs
    simp only [hP, Finset.mem_powersetCard] at hs
    have hxs : x ∉ s := fun hcon => (Finset.mem_erase.mp (hs.1 hcon)).1 rfl
    have hsub : (Finset.univ.filter (fun k => s ⊆ collisionSet H k S x))
        ⊆ Finset.univ.filter (fun k => ∀ y ∈ s, H k y = H k x) := by
      intro k hk
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk ⊢
      intro y hy
      have := hk hy
      unfold collisionSet at this
      exact (Finset.mem_filter.mp this).2
    have hcard : ((Finset.univ.filter (fun k => s ⊆ collisionSet H k S x)).card : ℝ)
        ≤ ((Finset.univ.filter (fun k => ∀ y ∈ s, H k y = H k x)).card : ℝ) := by
      exact_mod_cast Finset.card_le_card hsub
    have hMT : (0 : ℝ) ≤ (M : ℝ) ^ T := by positivity
    calc ((Finset.univ.filter (fun k => s ⊆ collisionSet H k S x)).card : ℝ) * (M : ℝ) ^ T
        ≤ ((Finset.univ.filter (fun k => ∀ y ∈ s, H k y = H k x)).card : ℝ) * (M : ℝ) ^ T :=
          mul_le_mul_of_nonneg_right hcard hMT
      _ ≤ (K : ℝ) := hI x s hs.2 hxs
  calc ∑ s ∈ P,
        ((Finset.univ.filter (fun k => s ⊆ collisionSet H k S x)).card : ℝ) * (M : ℝ) ^ T
      ≤ ∑ _s ∈ P, (K : ℝ) := Finset.sum_le_sum hterm
    _ = (P.card : ℝ) * K := by simp [Finset.sum_const, nsmul_eq_mul]
    _ ≤ (S.card.choose T : ℝ) * K := by
        have hPcard : (P.card : ℝ) = ((S.erase x).card.choose T : ℝ) := by
          rw [hP]; simp [Finset.card_powersetCard]
        have hmono : ((S.erase x).card.choose T : ℝ) ≤ (S.card.choose T : ℝ) := by
          have : (S.erase x).card.choose T ≤ S.card.choose T :=
            Nat.choose_le_choose T (Finset.card_le_card (Finset.erase_subset _ _))
          exact_mod_cast this
        rw [hPcard]
        exact mul_le_mul_of_nonneg_right hmono (Nat.cast_nonneg K)
    _ = (K : ℝ) * (S.card.choose T : ℝ) := by ring

/-- **Exponentially few bad keys.**  Under `(T+1)`-wise independence, the
fraction of keys giving `x` at least `T` collision partners is at most
`C(|S|,T)/M^T` — compare `card_badKeysT_mul_le`, whose bound `|S|/(T·M)` decays
only linearly in `T`. -/
theorem card_badKeysT_indep_le {H : Fin K → α → Fin M} {T : ℕ}
    (hI : IndepT H T) (S : Finset α) (x : α) :
    ((badKeysT H S x T).card : ℝ) * (M : ℝ) ^ T ≤ (K : ℝ) * (S.card.choose T : ℝ) := by
  classical
  have hstep : ((badKeysT H S x T).card : ℝ)
      ≤ ∑ k : Fin K, ((collisionSet H k S x).card.choose T : ℝ) := by
    calc ((badKeysT H S x T).card : ℝ)
        = ∑ _k ∈ badKeysT H S x T, (1 : ℝ) := by simp [Finset.sum_const]
      _ ≤ ∑ k ∈ badKeysT H S x T, ((collisionSet H k S x).card.choose T : ℝ) := by
          refine Finset.sum_le_sum fun k hk => ?_
          simp only [badKeysT, Finset.mem_filter, Finset.mem_univ, true_and] at hk
          have : 0 < (collisionSet H k S x).card.choose T := Nat.choose_pos hk
          exact_mod_cast this
      _ ≤ ∑ k : Fin K, ((collisionSet H k S x).card.choose T : ℝ) :=
          Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
            (fun k _ _ => Nat.cast_nonneg _)
  have hMT : (0 : ℝ) ≤ (M : ℝ) ^ T := by positivity
  calc ((badKeysT H S x T).card : ℝ) * (M : ℝ) ^ T
      ≤ (∑ k : Fin K, ((collisionSet H k S x).card.choose T : ℝ)) * (M : ℝ) ^ T :=
        mul_le_mul_of_nonneg_right hstep hMT
    _ ≤ (K : ℝ) * (S.card.choose T : ℝ) := sum_choose_collisionSet_le hI S x

/-- The mass-weighted factorial-moment bound, averaged over the keys. -/
theorem sum_badT_mass_indep_le (μ : FinProbDist α) {H : Fin K → α → Fin M} {T : ℕ}
    (hI : IndepT H T) (S A : Finset α) :
    (M : ℝ) ^ T *
        ∑ k : Fin K, setMass μ (A.filter (fun x => T ≤ (collisionSet H k S x).card))
      ≤ (K : ℝ) * (S.card.choose T : ℝ) * setMass μ A := by
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
  have hbound : ∀ x ∈ A, (M : ℝ) ^ T * (((badKeysT H S x T).card : ℝ) * μ.mass x)
      ≤ ((K : ℝ) * (S.card.choose T : ℝ)) * μ.mass x := by
    intro x _
    have h1 := card_badKeysT_indep_le hI S x
    have h2 : (0 : ℝ) ≤ μ.mass x := μ.mass_nonneg x
    nlinarith [h1, h2]
  calc ∑ x ∈ A, (M : ℝ) ^ T * (((badKeysT H S x T).card : ℝ) * μ.mass x)
      ≤ ∑ x ∈ A, ((K : ℝ) * (S.card.choose T : ℝ)) * μ.mass x := Finset.sum_le_sum hbound
    _ = (K : ℝ) * (S.card.choose T : ℝ) * setMass μ A := by rw [← Finset.mul_sum]; rfl

/-- Derandomization: a single key whose `T`-collision mass is at most
`C(|S|,T)/M^T`. -/
theorem exists_good_key_indepT (μ : FinProbDist α) {H : Fin K → α → Fin M} {T : ℕ}
    (hI : IndepT H T) (hK : 0 < K) (S A : Finset α) :
    ∃ k : Fin K, (M : ℝ) ^ T *
        setMass μ (A.filter (fun x => T ≤ (collisionSet H k S x).card))
      ≤ (S.card.choose T : ℝ) * setMass μ A := by
  classical
  have hne : (Finset.univ : Finset (Fin K)).Nonempty := by
    have : Nonempty (Fin K) := ⟨⟨0, hK⟩⟩
    exact Finset.univ_nonempty
  have hR : ∑ _k : Fin K, ((S.card.choose T : ℝ) * setMass μ A)
      = (K : ℝ) * (S.card.choose T : ℝ) * setMass μ A := by
    rw [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    ring
  have hsum : ∑ k : Fin K, ((M : ℝ) ^ T *
        setMass μ (A.filter (fun x => T ≤ (collisionSet H k S x).card)))
      ≤ ∑ _k : Fin K, ((S.card.choose T : ℝ) * setMass μ A) := by
    rw [← Finset.mul_sum, hR]
    exact sum_badT_mass_indep_le μ hI S A
  obtain ⟨k, _, hk⟩ := Finset.exists_le_of_sum_le hne hsum
  exact ⟨k, hk⟩

/-- **List decoding under `T`-wise independence.**  An explicit key gives a
list-`T` scheme whose failure probability is `≤ δ + C(|l|,T)/M^T`, with list
length `≤ T` and cost exactly `|l|`.  The failure term now decays like the
`T`-th power of `|l|/M`, not like `|l|/(T·M)`. -/
theorem exists_list_scheme_indepT (μ : FinProbDist α) {H : Fin K → α → Fin M} {T : ℕ}
    (hI : IndepT H T) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter
          (fun x => ¬ (listHashScheme T l (H k)).Succeeds x))
          ≤ δ + (l.length.choose T : ℝ) / (M : ℝ) ^ T
      ∧ (∀ i : Fin M, ((listHashScheme T l (H k)).dec i).length ≤ T)
      ∧ ∀ i : Fin M, (scanCost (H k) i l).2 = l.length := by
  classical
  obtain ⟨k, hk⟩ := exists_good_key_indepT μ hI hK l.toFinset Finset.univ
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hMT : (0 : ℝ) < (M : ℝ) ^ T := by positivity
  have hcard : l.toFinset.card = l.length := List.toFinset_card_of_nodup hnd
  set C : Finset α :=
    Finset.univ.filter (fun x => T ≤ (collisionSet H k l.toFinset x).card) with hC
  have hCbound : setMass μ C ≤ (l.length.choose T : ℝ) / (M : ℝ) ^ T := by
    rw [le_div_iff₀ hMT]
    have h2 := hk
    rw [setMass_univ, mul_one, hcard] at h2
    linarith [h2]
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
    _ ≤ δ + (l.length.choose T : ℝ) / (M : ℝ) ^ T := add_le_add hδ hCbound

/-- **The exponential gain, in readable form.**  Since `C(n,T) ≤ n^T`, the
failure probability of the list-`T` scheme is at most `δ + (|l|/M)^T`: for a
codebook of size `|l| ≤ M/2` the collision term is at most `2^{-T}`, versus
`|l|/(T·M) ≥ 1/(2T)` from 2-universality alone. -/
theorem exists_list_scheme_exponential (μ : FinProbDist α) {H : Fin K → α → Fin M}
    {T : ℕ} (hI : IndepT H T) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter
          (fun x => ¬ (listHashScheme T l (H k)).Succeeds x))
          ≤ δ + ((l.length : ℝ) / M) ^ T
      ∧ (∀ i : Fin M, ((listHashScheme T l (H k)).dec i).length ≤ T) := by
  obtain ⟨k, hfail, hlen, _⟩ :=
    exists_list_scheme_indepT μ hI hK hM l hnd δ hδ
  refine ⟨k, ?_, hlen⟩
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hMT : (0 : ℝ) < (M : ℝ) ^ T := by positivity
  have hchoose : (l.length.choose T : ℝ) ≤ (l.length : ℝ) ^ T := by
    have : l.length.choose T ≤ l.length ^ T := Nat.choose_le_pow _ _
    exact_mod_cast this
  have : (l.length.choose T : ℝ) / (M : ℝ) ^ T ≤ ((l.length : ℝ) / M) ^ T := by
    rw [div_pow, div_le_div_iff_of_pos_right hMT]
    exact hchoose
  linarith

end Independence

/-! ## Non-vacuity: the full function family is `T`-wise independent -/

section FullFamily

variable {α : Type*} [Fintype α] [DecidableEq α] {M : ℕ}

/-- Counting the functions constrained to agree with `f x` on a set `s` of size
`T` avoiding `x`: they form at most a `M^{-T}` fraction of all functions.  The
proof glues a constrained function to an arbitrary pattern on `s`, which is an
injection into the full function space. -/
theorem card_constrained_mul_pow_le {T : ℕ} (x : α) (s : Finset α)
    (hs : s.card = T) (hx : x ∉ s) :
    (Finset.univ.filter (fun f : α → Fin M => ∀ y ∈ s, f y = f x)).card * M ^ T
      ≤ Fintype.card (α → Fin M) := by
  classical
  set A : Finset (α → Fin M) :=
    Finset.univ.filter (fun f : α → Fin M => ∀ y ∈ s, f y = f x) with hA
  set B : Finset (↥s → Fin M) := Finset.univ with hB
  have hcards : Fintype.card (↥s → Fin M) = M ^ T := by
    rw [Fintype.card_fun, Fintype.card_coe, Fintype.card_fin, hs]
  have hprod : (A ×ˢ B).card = A.card * M ^ T := by
    rw [Finset.card_product, hB, Finset.card_univ, hcards]
  set glue : ((α → Fin M) × (↥s → Fin M)) → (α → Fin M) :=
    fun p z => if h : z ∈ s then p.2 ⟨z, h⟩ else p.1 z with hglue
  have hinj : Set.InjOn glue ↑(A ×ˢ B) := by
    intro p hp q hq hpq
    simp only [Finset.mem_coe, Finset.mem_product, hA, Finset.mem_filter,
      Finset.mem_univ, true_and] at hp hq
    have hval : ∀ z : α, (if h : z ∈ s then p.2 ⟨z, h⟩ else p.1 z)
        = (if h : z ∈ s then q.2 ⟨z, h⟩ else q.1 z) := fun z => congrFun hpq z
    have hxeq : p.1 x = q.1 x := by
      have := hval x
      simpa [hx] using this
    have hfst : p.1 = q.1 := by
      funext z
      by_cases hz : z ∈ s
      · rw [hp.1 z hz, hq.1 z hz, hxeq]
      · have := hval z
        simpa [hz] using this
    have hsnd : p.2 = q.2 := by
      funext z
      have := hval z.1
      simpa [z.2] using this
    exact Prod.ext hfst hsnd
  have hmaps : ∀ p ∈ A ×ˢ B, glue p ∈ (Finset.univ : Finset (α → Fin M)) :=
    fun p _ => Finset.mem_univ _
  have hle := Finset.card_le_card_of_injOn glue hmaps hinj
  rw [hprod, Finset.card_univ] at hle
  exact hle

/-- The family of **all** functions `α → Fin M`, indexed by `Fin K` with
`K = M^{|α|}`: the extreme case of a random codebook, with full independence. -/
noncomputable def fullFamily (α : Type*) [Fintype α] [DecidableEq α] (M : ℕ) :
    Fin (Fintype.card (α → Fin M)) → α → Fin M :=
  fun k => (Fintype.equivFin (α → Fin M)).symm k

/-- **Non-vacuity.**  The full function family satisfies `IndepT` for *every*
`T`, so the hypotheses used above are satisfiable at all levels of independence
(at the price of a large key). -/
theorem fullFamily_indepT (T : ℕ) : IndepT (fullFamily α M) T := by
  classical
  intro x s hs hx
  set e := Fintype.equivFin (α → Fin M) with he
  have hbij : (Finset.univ.filter
        (fun k => ∀ y ∈ s, fullFamily α M k y = fullFamily α M k x)).card
      = (Finset.univ.filter (fun f : α → Fin M => ∀ y ∈ s, f y = f x)).card := by
    refine Finset.card_bij (fun k _ => e.symm k) ?_ ?_ ?_
    · intro k hk
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk ⊢
      simpa [fullFamily, he] using hk
    · intro k₁ _ k₂ _ h
      exact e.symm.injective h
    · intro f hf
      refine ⟨e f, ?_, by simp [he]⟩
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hf ⊢
      simpa [fullFamily, he] using hf
  rw [hbij]
  have hcount := card_constrained_mul_pow_le (M := M) x s hs hx
  have hcast : (((Finset.univ.filter (fun f : α → Fin M => ∀ y ∈ s, f y = f x)).card
      * M ^ T : ℕ) : ℝ) ≤ ((Fintype.card (α → Fin M) : ℕ) : ℝ) := by
    exact_mod_cast hcount
  push_cast at hcast
  exact hcast

end FullFamily

end AlmostLossless