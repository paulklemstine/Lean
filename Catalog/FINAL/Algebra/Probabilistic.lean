/-
# Ramsey Theory: Probabilistic Lower Bound

This module formalizes the first-moment (Erdős) probabilistic lower bound
for diagonal Ramsey numbers via a finite averaging/double counting argument.

## Main result

* `ramsey_lower_bound_counting` — if `2 * C(n,k) < 2^C(k,2)`, then
  `¬ RamseyProp n k k` (there exists a coloring avoiding monochromatic K_k).

## The Probabilistic Method (Finite Averaging)

Count pairs (coloring, monochromatic k-clique). If the average number of
monochromatic k-cliques per coloring is < 1, some coloring has 0.
-/
import Mathlib
import Algebra.Ramsey.Defs

open Finset

/-! ## The finite averaging argument -/

/-- The set of edges of the complete graph on `Fin n` (as ordered pairs). -/
def edgeSet (n : ℕ) : Finset (Fin n × Fin n) :=
  Finset.univ.filter (fun p => p.1 < p.2)

/-
The number of edges equals `C(n, 2)`.
-/
theorem card_edgeSet (n : ℕ) : (edgeSet n).card = Nat.choose n 2 := by
  convert Finset.card_powersetCard 2 ( Finset.univ : Finset ( Fin n ) ) using 1;
  · refine' Finset.card_bij ( fun x hx => { x.1, x.2 } ) _ _ _ <;> simp_all +decide;
    · exact fun a b h => Finset.card_pair ( ne_of_lt ( Finset.mem_filter.mp h |>.2 ) );
    · simp +contextual [ Finset.Subset.antisymm_iff, Finset.subset_iff, edgeSet ];
      grind;
    · intro b hb; rw [ Finset.card_eq_two ] at hb; obtain ⟨ a, b, hab ⟩ := hb; cases lt_trichotomy a b <;> simp_all +decide [ edgeSet ] ;
      · exact ⟨ a, b, by assumption, rfl ⟩;
      · exact ⟨ b, a, by assumption, by rw [ Finset.pair_comm ] ⟩;
  · rw [ Finset.card_fin ]

/-
A k-element subset S of `Fin n` determines `C(k,2)` edges.
-/
theorem card_edges_of_subset {n k : ℕ} (S : Finset (Fin n)) (hS : S.card = k) :
    ((edgeSet n).filter (fun p => p.1 ∈ S ∧ p.2 ∈ S)).card = Nat.choose k 2 := by
      -- By definition of edge set, we can rewrite the left-hand side as the cardinality of the set of all pairs of distinct elements in S.
      have h_card_eq : (Finset.filter (fun p => p.1 ∈ S ∧ p.2 ∈ S) (edgeSet n)).card = (Finset.powersetCard 2 S).card := by
        refine' Finset.card_bij ( fun p hp => { p.1, p.2 } ) _ _ _;
        · simp +contextual [ Finset.mem_powersetCard, Finset.subset_iff ];
          exact fun a b hab ha hb => Finset.card_pair ( ne_of_lt ( Finset.mem_filter.mp hab |>.2 ) );
        · simp +contextual [ Finset.Subset.antisymm_iff, Finset.subset_iff ];
          grind +locals;
        · intro b hb; rw [ Finset.mem_powersetCard ] at hb; rcases Finset.card_eq_two.mp hb.2 with ⟨ x, y, hxy ⟩ ; cases lt_trichotomy x y <;> simp_all +decide [ edgeSet ] ;
          · exact ⟨ x, y, ⟨ by assumption, hb ( Finset.mem_insert_self _ _ ), hb ( Finset.mem_insert_of_mem ( Finset.mem_singleton_self _ ) ) ⟩, rfl ⟩;
          · exact ⟨ y, x, ⟨ by assumption, hb ( by simp +decide ), hb ( by simp +decide ) ⟩, by simp +decide [ *, Finset.pair_comm ] ⟩;
      aesop

/-
**Probabilistic lower bound**: if the expected number of monochromatic
    k-cliques is less than 1, then some coloring avoids them all.

    More precisely: if `2 * C(n,k) < 2^C(k,2)`, then there exists a
    2-coloring of K_n with no monochromatic k-clique.

    The factor 2 accounts for the two possible monochromatic colors (red/blue).
-/
set_option maxHeartbeats 1600000 in
theorem ramsey_lower_bound_counting
    {n k : ℕ} (hk : 2 ≤ k) (hkn : k ≤ n)
    (h : 2 * Nat.choose n k < 2 ^ Nat.choose k 2) :
    ¬ RamseyProp n k k := by
      -- By the pigeonhole principle, if the number of colorings is greater than the number of monochromatic k-cliques, then there must exist a coloring with no monochromatic k-clique.
      have h_pigeonhole : ∃ C : TwoColoring n, ¬∃ S : Finset (Fin n), S.card = k ∧ (IsRedClique C S ∨ IsBlueClique C S) := by
        by_contra h_contra;
        -- By assumption, every 2-coloring of K_n has a monochromatic k-clique.
        have h_all : ∀ (f : Finset (Fin n × Fin n)), (∀ p ∈ f, p.1 < p.2) → (∀ p ∈ f, p.2 < n) → ∃ S : Finset (Fin n), S.card = k ∧ (∀ i ∈ S, ∀ j ∈ S, i ≠ j → (i, j) ∈ f ∨ (j, i) ∈ f) ∨ ∃ S : Finset (Fin n), S.card = k ∧ (∀ i ∈ S, ∀ j ∈ S, i ≠ j → (i, j) ∉ f ∧ (j, i) ∉ f) := by
          intros f hf1 hf2
          obtain ⟨C, hC⟩ : ∃ C : TwoColoring n, ∀ p : Fin n × Fin n, p.1 < p.2 → (C.color p.1 p.2 = true ↔ p ∈ f) := by
            use ⟨fun i j => if i < j then (i, j) ∈ f else if j < i then (j, i) ∈ f else false, by
              grind, by
              aesop⟩;
            grind;
          push_neg at h_contra; specialize h_contra C; simp_all +decide [ IsRedClique, IsBlueClique ] ;
          obtain ⟨ S, hS₁, hS₂ ⟩ := h_contra; use S; rcases hS₂ with hS₂ | hS₂ <;> simp_all +decide [ Finset.ext_iff ] ;
          · grind +locals;
          · grind +splitIndPred;
        have h_subset : Finset.card (Finset.filter (fun f => ∃ S : Finset (Fin n), S.card = k ∧ (∀ i ∈ S, ∀ j ∈ S, i ≠ j → (i, j) ∈ f ∨ (j, i) ∈ f)) (Finset.filter (fun f => ∀ p ∈ f, p.1 < p.2) (Finset.powerset (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n)))))) ≤ Nat.choose n k * 2 ^ (Nat.choose n 2 - Nat.choose k 2) := by
          have h_subset : Finset.card (Finset.filter (fun f => ∃ S : Finset (Fin n), S.card = k ∧ (∀ i ∈ S, ∀ j ∈ S, i ≠ j → (i, j) ∈ f ∨ (j, i) ∈ f)) (Finset.filter (fun f => ∀ p ∈ f, p.1 < p.2) (Finset.powerset (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n)))))) ≤ Finset.sum (Finset.powersetCard k (Finset.univ : Finset (Fin n))) (fun S => 2 ^ (Nat.choose n 2 - Nat.choose k 2)) := by
            have h_subset : ∀ S : Finset (Fin n), S.card = k → Finset.card (Finset.filter (fun f => ∀ i ∈ S, ∀ j ∈ S, i ≠ j → (i, j) ∈ f ∨ (j, i) ∈ f) (Finset.filter (fun f => ∀ p ∈ f, p.1 < p.2) (Finset.powerset (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n)))))) ≤ 2 ^ (Nat.choose n 2 - Nat.choose k 2) := by
              intros S hS_card
              have h_subset : Finset.filter (fun f => ∀ i ∈ S, ∀ j ∈ S, i ≠ j → (i, j) ∈ f ∨ (j, i) ∈ f) (Finset.filter (fun f => ∀ p ∈ f, p.1 < p.2) (Finset.powerset (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n))))) ⊆ Finset.image (fun f => f ∪ Finset.filter (fun p => p.1 ∈ S ∧ p.2 ∈ S ∧ p.1 < p.2) (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n)))) (Finset.powerset (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n)) \ Finset.filter (fun p => p.1 ∈ S ∧ p.2 ∈ S ∧ p.1 < p.2) (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n))))) := by
                simp +decide [ Finset.subset_iff ];
                intro f hf₁ hf₂; use f \ Finset.filter ( fun p => p.1 ∈ S ∧ p.2 ∈ S ∧ p.1 < p.2 ) ( Finset.filter ( fun p => p.1 < p.2 ) ( Finset.univ : Finset ( Fin n × Fin n ) ) ) ; simp +decide [ Finset.ext_iff ] ;
                grind;
              refine le_trans ( Finset.card_le_card h_subset ) ?_;
              refine' Finset.card_image_le.trans _;
              rw [ Finset.card_powerset, Finset.card_sdiff ];
              rw [ show # ( Finset.filter ( fun p : Fin n × Fin n => p.1 < p.2 ) Finset.univ ) = Nat.choose n 2 from ?_, show # ( Finset.filter ( fun p : Fin n × Fin n => p.1 ∈ S ∧ p.2 ∈ S ∧ p.1 < p.2 ) ( Finset.filter ( fun p : Fin n × Fin n => p.1 < p.2 ) Finset.univ ) ∩ Finset.filter ( fun p : Fin n × Fin n => p.1 < p.2 ) Finset.univ ) = Nat.choose k 2 from ?_ ];
              · convert card_edges_of_subset S hS_card using 1;
                congr 1 with p ; simp +decide [ edgeSet ];
                tauto;
              · convert card_edgeSet n using 1;
            refine' le_trans _ ( Finset.sum_le_sum fun S hS => h_subset S <| Finset.mem_powersetCard.mp hS |>.2 );
            refine' le_trans _ ( Finset.card_biUnion_le );
            refine' Finset.card_mono _;
            simp +contextual [ Finset.subset_iff ];
          simp_all +decide [ Finset.card_univ ];
        have h_subset_blue : Finset.card (Finset.filter (fun f => ∃ S : Finset (Fin n), S.card = k ∧ (∀ i ∈ S, ∀ j ∈ S, i ≠ j → (i, j) ∉ f ∧ (j, i) ∉ f)) (Finset.filter (fun f => ∀ p ∈ f, p.1 < p.2) (Finset.powerset (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n)))))) ≤ Nat.choose n k * 2 ^ (Nat.choose n 2 - Nat.choose k 2) := by
          refine' le_trans _ h_subset;
          refine' le_of_eq _;
          refine' Finset.card_bij ( fun f hf => Finset.filter ( fun p => p.1 < p.2 ) ( Finset.univ : Finset ( Fin n × Fin n ) ) \ f ) _ _ _ <;> simp +decide;
          · grind;
          · intro a₁ ha₁ ha₂ x hx hx' a₂ ha₃ ha₄ y hy hy' h; rw [ Finset.sdiff_eq_sdiff_iff_inter_eq_inter ] at h;
            rw [ Finset.inter_eq_right.mpr ha₁, Finset.inter_eq_right.mpr ha₃ ] at h ; aesop;
          · intro b hb hb' x hx hx'; use Finset.filter ( fun p => p.1 < p.2 ) ( Finset.univ : Finset ( Fin n × Fin n ) ) \ b; simp +decide [ *, Finset.subset_iff ] ;
            grind;
        have h_union : Finset.card (Finset.filter (fun f => ∃ S : Finset (Fin n), S.card = k ∧ (∀ i ∈ S, ∀ j ∈ S, i ≠ j → (i, j) ∈ f ∨ (j, i) ∈ f)) (Finset.filter (fun f => ∀ p ∈ f, p.1 < p.2) (Finset.powerset (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n)))))) + Finset.card (Finset.filter (fun f => ∃ S : Finset (Fin n), S.card = k ∧ (∀ i ∈ S, ∀ j ∈ S, i ≠ j → (i, j) ∉ f ∧ (j, i) ∉ f)) (Finset.filter (fun f => ∀ p ∈ f, p.1 < p.2) (Finset.powerset (Finset.filter (fun p => p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n)))))) ≥ 2 ^ (Nat.choose n 2) := by
          rw [ ← Finset.card_union_add_card_inter ];
          refine' le_trans _ ( Nat.le_add_right _ _ );
          refine' le_trans _ ( Finset.card_mono _ );
          rotate_left;
          exact Finset.image ( fun f : Finset ( Fin n × Fin n ) => f ) ( Finset.powerset ( Finset.filter ( fun p : Fin n × Fin n => p.1 < p.2 ) Finset.univ ) );
          · simp +contextual [ Finset.subset_iff ];
            exact fun f hf => h_all f ( fun p hp => hf _ _ hp ) ( fun p hp => by simp ) |> fun ⟨ S, hS ⟩ => hS.elim ( fun hS => Or.inl ⟨ S, hS.1, hS.2 ⟩ ) fun hS => Or.inr hS;
          · simp +decide [ Finset.card_univ, card_edgeSet ];
            rw [ show Finset.card ( Finset.filter ( fun p : Fin n × Fin n => p.1 < p.2 ) Finset.univ ) = Nat.choose n 2 from ?_ ];
            convert card_edgeSet n using 1;
        rw [ show Nat.choose n 2 = Nat.choose k 2 + ( Nat.choose n 2 - Nat.choose k 2 ) by rw [ Nat.add_sub_of_le ( Nat.choose_le_choose _ hkn ) ] ] at h_union ; norm_num [ pow_add ] at h_union;
        norm_num +zetaDelta at *;
        nlinarith [ pow_pos ( zero_lt_two' ℕ ) ( Nat.choose n 2 - Nat.choose k 2 ) ];
      intro h; obtain ⟨ C, hC ⟩ := h_pigeonhole; specialize h C; aesop;

/-! ## Application: concrete lower bounds -/

/-- R(4,4) > 5: verified by the counting criterion.
    2 * C(5,4) = 10 < 2^6 = 64. -/
theorem ramsey_44_lower_5 : ¬ RamseyProp 5 4 4 :=
  ramsey_lower_bound_counting (by omega) (by omega) (by native_decide)

/-- R(5,5) > 8: 2 * C(8,5) = 112 < 2^10 = 1024. -/
theorem ramsey_55_lower_8 : ¬ RamseyProp 8 5 5 :=
  ramsey_lower_bound_counting (by omega) (by omega) (by native_decide)

/-- R(6,6) > 17: 2 * C(17,6) = 24752 < 2^15 = 32768. -/
theorem ramsey_66_lower_17 : ¬ RamseyProp 17 6 6 :=
  ramsey_lower_bound_counting (by omega) (by omega) (by native_decide)

/-
**Cross-domain connection to coding theory**: The counting argument
    shows that the density of "Ramsey-good" colorings in the space of all
    `2^C(n,2)` colorings is at least `1 - C(n,k) * 2^(1-C(k,2))`.
    This is analogous to random coding arguments in information theory.
-/
theorem good_coloring_count_lower_bound
    {n k : ℕ} (hk : 2 ≤ k) (hkn : k ≤ n)
    (h : 2 * Nat.choose n k < 2 ^ Nat.choose k 2) :
    ∃ C : TwoColoring n,
      (¬ ∃ S : Finset (Fin n), S.card = k ∧ IsRedClique C S) ∧
      (¬ ∃ S : Finset (Fin n), S.card = k ∧ IsBlueClique C S) := by
        convert ramsey_lower_bound_counting hk hkn h using 1;
        unfold RamseyProp; aesop;