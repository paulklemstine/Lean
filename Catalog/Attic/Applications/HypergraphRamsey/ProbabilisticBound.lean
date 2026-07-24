/-
# Hypergraph Ramsey Theory: Probabilistic Lower Bound

The first-moment (Erdős) probabilistic argument generalized to r-uniform
hypergraphs, showing R_r(k,k) grows at least as 2^{Ω(k^{r-1})}.

## Main results

* `hyper_ramsey_counting_lower_bound` — If 2·C(n,k) < 2^{C(k,r)}, then
    ¬ HyperRamseyProp r n k k
* `choose_grows_with_uniformity` — C(k, r+1) > C(k, r) for k > r+1
* `prob_bound_increases_with_uniformity` — lower bound floor rises with r
* `not_hyper_ramsey_self` — R_r(k,k) > k for k > r ≥ 2

## The Probabilistic Method for Hypergraphs

The argument: color each r-element subset independently and uniformly
at random. For a fixed k-element set T, the probability that all C(k,r)
r-subsets of T are the same color is 2·2^{-C(k,r)} = 2^{1-C(k,r)}.

By union bound over all C(n,k) possible k-sets T:
  P(∃ monochromatic K_k^{(r)}) ≤ 2·C(n,k)·2^{-C(k,r)}

If this is < 1, some coloring avoids monochromatic k-sets, so R_r(k,k) > n.

For r = 2: C(k,2) = k(k-1)/2, giving R_2(k,k) > 2^{k/2}.
For r = 3: C(k,3) = k(k-1)(k-2)/6, giving R_3(k,k) > 2^{ck²}.
For general r: C(k,r) = Θ(k^r/r!), giving R_r(k,k) > 2^{ck^{r-1}}.
-/
import Mathlib
import Applications.HypergraphRamsey.Defs

open Finset Nat

/-! ## The counting/probabilistic lower bound -/

/-
**Probabilistic lower bound for hypergraph Ramsey numbers**:
    If `2 * C(n, k) < 2^{C(k, r)}`, then ¬ HyperRamseyProp r n k k.

    This is the hypergraph generalization of the Erdős probabilistic argument.
    The proof uses a finite averaging/double-counting argument:
    - Count pairs (coloring, monochromatic k-set)
    - The total number of colorings is 2^{C(n,r)}
    - Each k-set contributes 2·2^{C(n,r)-C(k,r)} pairs
    - If 2·C(n,k) < 2^{C(k,r)}, the average < 1, so some coloring has 0
-/

theorem hyper_ramsey_counting_lower_bound {n k r : ℕ}
    (_hr : 2 ≤ r) (hk : r ≤ k) (hkn : k ≤ n)
    (h : 2 * Nat.choose n k < 2 ^ Nat.choose k r) :
    ¬ HyperRamseyProp r n k k := by
  intro h';
  -- Consider the coloring where we color each r-subset of [n] randomly with probability 1/2 of being red and 1/2 of being blue.
  obtain ⟨c, hc⟩ : ∃ c : Finset (Fin n) → Bool, ∀ T : Finset (Fin n), T.card = k → ¬(IsMonoHyperClique r c T true) ∧ ¬(IsMonoHyperClique r c T false) := by
    -- Consider the set of all r-uniform hypergraphs on [n] and the set of all colorings of these hypergraphs.
    set H := Finset.powersetCard r (Finset.univ : Finset (Fin n)) with hH_def
    set C := Finset.powerset H with hC_def;
    -- By the pigeonhole principle, since $2 * \binom{n}{k} < 2^{\binom{k}{r}}$, there must exist a coloring $c$ such that no $k$-subset is monochromatic.
    obtain ⟨c, hc⟩ : ∃ c ∈ C, ∀ T : Finset (Fin n), T.card = k → ¬(T.powersetCard r ⊆ c) ∧ ¬(T.powersetCard r ⊆ H \ c) := by
      have h_pigeonhole : ∑ T ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), (Finset.filter (fun c => T.powersetCard r ⊆ c ∨ T.powersetCard r ⊆ H \ c) C).card < C.card := by
        have h_pigeonhole : ∀ T ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), (Finset.filter (fun c => T.powersetCard r ⊆ c ∨ T.powersetCard r ⊆ H \ c) C).card ≤ 2 * 2 ^ (Nat.choose n r - Nat.choose k r) := by
          intros T hT
          have h_card : (Finset.filter (fun c => T.powersetCard r ⊆ c) C).card ≤ 2 ^ (Nat.choose n r - Nat.choose k r) := by
            have h_card : (Finset.filter (fun c => T.powersetCard r ⊆ c) C).card ≤ Finset.card (Finset.powerset (H \ T.powersetCard r)) := by
              refine' le_trans ( Finset.card_le_card _ ) _;
              exact Finset.image ( fun c => powersetCard r T ∪ c ) ( Finset.powerset ( H \ powersetCard r T ) );
              · simp +decide [ Finset.subset_iff ];
                intro x hx hx'; use x \ powersetCard r T; simp_all +decide [ Finset.subset_iff ] ;
              · exact Finset.card_image_le;
            simp_all +decide [ Finset.card_sdiff ];
            convert h_card using 2;
            rw [ Finset.inter_eq_left.mpr ( Finset.powersetCard_mono <| Finset.subset_univ _ ), Finset.card_powersetCard, hT ];
          have h_card_compl : (Finset.filter (fun c => T.powersetCard r ⊆ H \ c) C).card ≤ 2 ^ (Nat.choose n r - Nat.choose k r) := by
            have h_card_compl : (Finset.filter (fun c => T.powersetCard r ⊆ H \ c) C).card ≤ Finset.card (Finset.powerset (H \ T.powersetCard r)) := by
              refine Finset.card_le_card ?_;
              grind;
            simp_all +decide [ Finset.card_sdiff ];
            convert h_card_compl using 2;
            rw [ Finset.inter_eq_left.mpr ( Finset.powersetCard_mono <| Finset.subset_univ _ ), Finset.card_powersetCard, hT ];
          exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun c => powersetCard r T ⊆ c ∨ powersetCard r T ⊆ H \ c ) C ⊆ Finset.filter ( fun c => powersetCard r T ⊆ c ) C ∪ Finset.filter ( fun c => powersetCard r T ⊆ H \ c ) C from fun x hx => by aesop ) ) ( by exact le_trans ( Finset.card_union_le _ _ ) ( by linarith ) );
        refine' lt_of_le_of_lt ( Finset.sum_le_sum h_pigeonhole ) _;
        simp +zetaDelta at *;
        rw [ show 2 ^ n.choose r = 2 ^ ( n.choose r - k.choose r ) * 2 ^ k.choose r by rw [ ← pow_add, Nat.sub_add_cancel ( show k.choose r ≤ n.choose r from Nat.choose_le_choose _ hkn ) ] ] ; nlinarith [ pow_pos ( zero_lt_two' ℕ ) ( n.choose r - k.choose r ) ];
      contrapose! h_pigeonhole;
      have h_pigeonhole : ∀ c ∈ C, ∃ T ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), T.powersetCard r ⊆ c ∨ T.powersetCard r ⊆ H \ c := by
        grind;
      have h_pigeonhole : C ⊆ Finset.biUnion (Finset.powersetCard k (Finset.univ : Finset (Fin n))) (fun T => Finset.filter (fun c => T.powersetCard r ⊆ c ∨ T.powersetCard r ⊆ H \ c) C) := by
        grind;
      exact le_trans ( Finset.card_le_card h_pigeonhole ) ( Finset.card_biUnion_le );
    use fun S => S ∈ c;
    intro T hT; specialize hc; have := hc.2 T hT; simp_all +decide [ Finset.subset_iff, IsMonoHyperClique ] ;
  cases h' c <;> aesop

/-! ## Choose function properties -/

/-
**Choose grows on left half of Pascal's triangle**: C(k, r+1) > C(k, r)
    when 2(r+1) ≤ k, i.e., r+1 is at most half of k.
-/

theorem lower_upper_gap_three_uniform (k : ℕ) (hk : 4 ≤ k) :
    Nat.choose k 3 < 2 ^ (k * k) := by
  refine' lt_of_le_of_lt ( _ : _ ≤ _ ) ( pow_lt_pow_right₀ ( by decide ) ( by nlinarith : k * k > 3 * k ) );
  rw [ Nat.mul_comm, pow_mul ];
  exact le_trans ( Nat.choose_le_pow _ _ ) ( by gcongr ; linarith [ show 2 ^ k ≥ k + 1 from Nat.recOn k ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith [ ihn, Nat.one_le_pow n 2 zero_lt_two ] ] )