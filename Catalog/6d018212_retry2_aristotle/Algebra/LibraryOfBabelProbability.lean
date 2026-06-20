import Mathlib
import Algebra.LibraryOfBabel

/-!
# The Library of Babel: probabilistic completeness

This file extends `Algebra/LibraryOfBabel.lean` with a *lower* bound on the
probability that a uniformly random volume contains a fixed pattern, matching the
union *upper* bound already present there, and a "Borges completeness" corollary:
as the length grows, any fixed finite text almost surely occurs.

Main results:

* `prob_pair_coincide` : two independent uniform volumes coincide with
  probability exactly `b ^ (-L)`.
* `prob_le_one` : the uniform probability of any event is at most `1`.
* `card_noAlignedBlockMatch` : the number of volumes in which none of the
  `⌊L/k⌋` disjoint aligned length-`k` blocks equals the pattern is
  `(b ^ k - 1) ^ (L / k) * b ^ (L - (L / k) * k)`.
* `prob_contains_substring_lower_bound` : the probability that a random volume
  contains a fixed length-`k` pattern is at least `1 - (1 - b ^ (-k)) ^ ⌊L/k⌋`.
* `prob_contains_tendsto_one` : for `b ≥ 2`, this probability tends to `1` as
  `L → ∞`.

-- !-- Lab Notes -- !--
-- Hypothesis: the union bound `(L-k+1) b^{-k}` is tight from above but vacuous
-- for large L; a complementary lower bound should come from *independence of
-- disjoint blocks*. Partition `Fin L` into `m = ⌊L/k⌋` aligned blocks of length
-- `k` plus a remainder of `L - m k` free symbols. The blocks are independent;
-- each fails to equal the pattern with probability `1 - b^{-k}`. Counting:
-- `#{no aligned block matches} = (b^k - 1)^m · b^{L - m k}`, established via the
-- explicit reindexing equiv `blockEquiv` below (curry of the column-major
-- `finProdFinEquiv`, verified to send block `t`, offset `j` to position `t*k+j`).
-- Insight: the event "some aligned block matches" is a *subset* of "contains",
-- so the inclusion is one-directional and exact, no inclusion–exclusion needed.
-- Failure analysis: a naive attempt to lower-bound via the second-moment
-- (Paley–Zygmund) method requires the variance of the overlapping occurrence
-- count, which is messy; the disjoint-block argument is both cleaner and gives a
-- bound that is non-vacuous for *every* L and converges to 1.
-/

open Finset

namespace LibraryOfBabel

/-! ### Coincidence probability -/

/-
Two independent uniformly random volumes coincide with probability `b ^ (-L)`.
-/
theorem prob_pair_coincide (b L : ℕ) :
    ProbabilityTheory.prob (Library b L ×ˢ Library b L)
        {p : Volume b L × Volume b L | p.1 = p.2}
      = (b : ℝ) ^ (-(L : ℤ)) := by
  unfold ProbabilityTheory.prob; by_cases hL : L = 0 <;> by_cases hb : b = 0 <;> norm_num [ Finset.card_univ, hL, hb ] ;
  · subst_vars; norm_num [ Library ] ;
    simp +decide [ Finset.filter_singleton ];
  · unfold Library; aesop;
  · cases L <;> aesop;
  · rw [ inv_eq_one_div, div_eq_div_iff ] <;> norm_cast <;> simp_all +decide [ Library, card_library ];
    convert Finset.card_image_of_injective _ ( show Function.Injective ( fun x : Fin L → Fin b => ( x, x ) ) from fun x y hxy => by simpa using congrArg Prod.fst hxy ) using 1;
    any_goals exact Finset.univ;
    · congr with x ; aesop;
    · simp +decide [ Finset.card_univ ]

/-! ### Basic probability facts -/

/-
The uniform probability of any event is at most `1`.
-/
theorem prob_le_one {α : Type*} [Fintype α] (s : Finset α) (A : Set α) :
    ProbabilityTheory.prob s A ≤ 1 := by
  convert div_le_one_of_le₀ _ _ <;> norm_num [ ProbabilityTheory.prob ];
  · infer_instance;
  · infer_instance;
  · grind

/-! ### Aligned blocks and the block-counting lemma -/

/-- `v` has *no aligned block match*: for every one of the `⌊L/k⌋` disjoint
aligned length-`k` blocks, the pattern fails to occur at the block start. -/
def NoAlignedBlockMatch {b L k : ℕ} (pattern : Fin k → Fin b) (v : Volume b L) : Prop :=
  ∀ t : Fin (L / k), ¬ OccursAt pattern v ((t : ℕ) * k)

instance {b L k : ℕ} (pattern : Fin k → Fin b) (v : Volume b L) :
    Decidable (NoAlignedBlockMatch pattern v) := by
  unfold NoAlignedBlockMatch; infer_instance

/-- Reindexing a volume as `(blocks, remainder)`: the `t`-th block, offset `j`,
sits at position `t*k + j`; see `blockEquiv_fst_apply`. -/
noncomputable def blockEquiv (b L k : ℕ) (h : (L / k) * k + (L - (L / k) * k) = L) :
    (Volume b L) ≃
      ((Fin (L / k) → Fin k → Fin b) × (Fin (L - (L / k) * k) → Fin b)) :=
  (Equiv.arrowCongr
      (((Equiv.sumCongr finProdFinEquiv (Equiv.refl (Fin (L - (L / k) * k)))).trans
          finSumFinEquiv).trans (finCongr h))
      (Equiv.refl (Fin b))).symm.trans
    ((Equiv.sumArrowEquivProdArrow _ _ _).trans
      (Equiv.prodCongr (Equiv.curry _ _ _) (Equiv.refl _)))

/-- The first component of `blockEquiv` reads the symbol at position `t*k + j`. -/
theorem blockEquiv_fst_apply {b L k : ℕ} (h : (L / k) * k + (L - (L / k) * k) = L)
    (v : Volume b L) (t : Fin (L / k)) (j : Fin k) :
    (blockEquiv b L k h v).1 t j
      = v (finCongr h (finSumFinEquiv (Sum.inl (finProdFinEquiv (t, j))))) := rfl

/-- The position index used by `blockEquiv` is `t*k + j`. -/
theorem blockEquiv_index {L k : ℕ} (h : (L / k) * k + (L - (L / k) * k) = L)
    (t : Fin (L / k)) (j : Fin k) :
    ((finCongr h (finSumFinEquiv (Sum.inl (finProdFinEquiv (t, j))))) : Fin L).val
      = (t : ℕ) * k + j := by
  simp [finProdFinEquiv]; ring

/-
`NoAlignedBlockMatch` says exactly that each block of `blockEquiv v` differs
from the pattern.
-/
theorem noAligned_iff {b L k : ℕ} (hk : 0 < k)
    (h : (L / k) * k + (L - (L / k) * k) = L) (pattern : Fin k → Fin b)
    (v : Volume b L) :
    NoAlignedBlockMatch pattern v ↔ ∀ t : Fin (L / k), (blockEquiv b L k h v).1 t ≠ pattern := by
  constructor;
  · intro h_no_aligned_block_match t ht_eq_pattern
    have h_occurs_at : OccursAt pattern v (t * k) := by
      intro j
      have h_pos : (t : ℕ) * k + j < L := by
        nlinarith [ Fin.is_lt t, Nat.div_mul_le_self L k, Fin.is_lt j ]
      simp [readAt, h_pos];
      convert congr_fun ht_eq_pattern j using 1;
      convert blockEquiv_fst_apply h v t j |> Eq.symm using 2;
      convert blockEquiv_index h t j |> Eq.symm;
      simp +decide [ Fin.ext_iff ];
    exact h_no_aligned_block_match t h_occurs_at;
  · intro h_no_aligned_block_match t
    by_contra h_aligned_block_match;
    refine' h_no_aligned_block_match t ( funext fun j => _ );
    convert h_aligned_block_match j using 1;
    unfold readAt; simp +decide [ blockEquiv_fst_apply, blockEquiv_index ] ;
    simp +decide [ Fin.cast, finProdFinEquiv ];
    grind

/-
The number of `m`-tuples of length-`k` blocks none of which equals a fixed
pattern is `(b^k - 1)^m`.
-/
theorem card_avoid {b k : ℕ} (m : ℕ) (pattern : Fin k → Fin b) :
    (Finset.univ.filter
        (fun g : Fin m → Fin k → Fin b => ∀ t, g t ≠ pattern)).card
      = (b ^ k - 1) ^ m := by
  convert Fintype.card_piFinset;
  any_goals exact Fin m;
  any_goals try infer_instance;
  swap;
  exact fun _ => Fin k → Fin b;
  constructor <;> intro h;
  · convert Fintype.card_piFinset;
  · convert h ( fun _ => Finset.univ.erase pattern ) using 1;
    · congr with g ; simp +decide [ Fintype.mem_piFinset ];
    · simp +decide [ Finset.card_univ ]

/-
**Block-independence count.** The number of volumes in which no aligned block
matches the pattern is `(b^k - 1)^{⌊L/k⌋} · b^{L - ⌊L/k⌋·k}`.
-/
theorem card_noAlignedBlockMatch {b k : ℕ} (L : ℕ) (hk : 0 < k) (pattern : Fin k → Fin b) :
    (Finset.univ.filter (fun v : Volume b L => NoAlignedBlockMatch pattern v)).card
      = (b ^ k - 1) ^ (L / k) * b ^ (L - (L / k) * k) := by
  have h_card : ({v : Volume b L | NoAlignedBlockMatch pattern v}).ncard = (b ^ k - 1) ^ (L / k) * b ^ (L - (L / k) * k) := by
    have h_card : ({v : Volume b L | NoAlignedBlockMatch pattern v}) = (blockEquiv b L k (by
    rw [ Nat.add_sub_of_le ( Nat.div_mul_le_self _ _ ) ])).symm '' (Finset.univ.filter (fun g : Fin (L / k) → Fin k → Fin b => ∀ t, g t ≠ pattern) ×ˢ Finset.univ) := by
      all_goals generalize_proofs at *;
      ext v; simp [noAligned_iff];
      convert noAligned_iff hk ‹_› pattern v using 1
    generalize_proofs at *;
    rw [ h_card, Set.ncard_image_of_injective ] <;> norm_num [ Function.Injective ];
    rw [ Set.ncard_eq_toFinset_card' ] ; norm_num [ card_avoid ];
  rw [ Set.ncard_eq_toFinset_card' ] at h_card ; aesop

/-! ### Main lower bound and completeness -/

/-
**Aligned-block lower bound.** The probability that a uniformly random
volume of length `L` contains a fixed length-`k` pattern is at least
`1 - (1 - b^{-k})^{⌊L/k⌋}`. This complements the union upper bound
`prob_contains_substring_bound` and, unlike it, is never vacuous.
-/
theorem prob_contains_substring_lower_bound {b k : ℕ} (L : ℕ) (hk : 0 < k)
    (pattern : Fin k → Fin b) :
    1 - (1 - (b : ℝ) ^ (-(k : ℤ))) ^ (L / k)
      ≤ ProbabilityTheory.prob (Library b L) {v : Volume b L | Contains pattern v} := by
  by_cases hb : b = 0;
  · exact absurd ( Fin.is_lt ( pattern ⟨ 0, hk ⟩ ) ) ( by simp +decide [ hb ] );
  · -- Let $m = \lfloor L / k \rfloor$ and $mk = m * k$.
    set m := L / k with hm
    set mk := m * k with hmk;
    -- By definition of $m$ and $mk$, we have $mk \leq L$.
    have hmk_le_L : mk ≤ L := by
      exact Nat.div_mul_le_self _ _;
    -- Using the fact that `NoAlignedBlockMatch` implies `¬ Contains`, we can bound the probability.
    have h_prob_bound : ProbabilityTheory.prob (Library b L) {v | ¬ Contains pattern v} ≤ (b ^ k - 1 : ℝ) ^ m * b ^ (L - mk) / b ^ L := by
      have h_prob_bound : ProbabilityTheory.prob (Library b L) {v | ¬ Contains pattern v} ≤ (Finset.univ.filter (fun v : Volume b L => NoAlignedBlockMatch pattern v)).card / b ^ L := by
        unfold ProbabilityTheory.prob; norm_num [ Library ] ;
        gcongr;
        exact fun h => fun t => fun ht => h ⟨ t * k, ht ⟩;
      convert h_prob_bound using 2;
      rw [ card_noAlignedBlockMatch L hk pattern ];
      cases b <;> simp_all +decide [ Nat.one_le_iff_ne_zero ];
    -- Using the fact that `ProbabilityTheory.prob (Library b L) {v | ¬ Contains pattern v} = 1 - ProbabilityTheory.prob (Library b L) {v | Contains pattern v}`, we can rewrite the inequality.
    have h_prob_rewrite : ProbabilityTheory.prob (Library b L) {v | Contains pattern v} = 1 - ProbabilityTheory.prob (Library b L) {v | ¬ Contains pattern v} := by
      unfold ProbabilityTheory.prob; norm_num [ Finset.filter_not, Finset.card_sdiff ] ;
      rw [ one_sub_div ] <;> norm_cast <;> simp +decide [ Finset.filter_not, Finset.card_sdiff, Library ];
      · rw [ Int.subNatNat_of_le ] <;> norm_cast;
        · simp +decide [ Finset.filter_not, Finset.card_sdiff, Library ];
          rw [ Nat.sub_eq_of_eq_add ];
          rw [ Finset.card_filter_add_card_filter_not, Finset.card_univ ] ; aesop;
        · exact le_trans ( Finset.card_le_univ _ ) ( by norm_num [ card_library ] );
      · aesop;
    convert sub_le_sub_left h_prob_bound 1 using 1 ; norm_num [ zpow_neg, zpow_ofNat ];
    field_simp;
    rw [ div_pow, div_mul_eq_mul_div, div_eq_iff ] <;> first | positivity | rw [ show ( b : ℝ ) ^ L = ( b : ℝ ) ^ mk * ( b : ℝ ) ^ ( L - mk ) by rw [ ← pow_add, Nat.add_sub_of_le hmk_le_L ] ] ; ring;

/-
**Borges completeness.** For an alphabet of at least two symbols, the
probability that a random volume contains a fixed finite pattern tends to `1` as
the length tends to infinity: any text almost surely eventually appears.
-/
theorem prob_contains_tendsto_one {b k : ℕ} (hk : 0 < k) (hb : 1 < b)
    (pattern : Fin k → Fin b) :
    Filter.Tendsto
      (fun L => ProbabilityTheory.prob (Library b L) {v : Volume b L | Contains pattern v})
      Filter.atTop (nhds 1) := by
  -- By the squeeze theorem, it suffices to show that $1 - (1 - (b : ℝ) ^ (-(k : ℤ))) ^ (L / k)$ tends to $1$ as $L$ tends to infinity.
  suffices h_squeeze : Filter.Tendsto (fun L => 1 - (1 - (b : ℝ) ^ (-(k : ℤ))) ^ (L / k)) Filter.atTop (nhds 1) by
    refine' tendsto_of_tendsto_of_tendsto_of_le_of_le' h_squeeze tendsto_const_nhds _ _;
    · filter_upwards [ Filter.eventually_gt_atTop 0 ] with L hL using prob_contains_substring_lower_bound L hk pattern;
    · exact Filter.Eventually.of_forall fun L => prob_le_one _ _;
  -- Since $0 < 1 - (b : ℝ) ^ (-(k : ℤ)) < 1$, we can apply the fact that $(1 - (b : ℝ) ^ (-(k : ℤ))) ^ n$ tends to $0$ as $n$ tends to infinity.
  have h_exp : Filter.Tendsto (fun n => (1 - (b : ℝ) ^ (-(k : ℤ))) ^ n) Filter.atTop (nhds 0) := by
    norm_num [ zpow_neg, zpow_ofNat ];
    rw [ abs_of_nonneg ] <;> nlinarith [ show ( b : ℝ ) ^ k ≥ 2 by exact_mod_cast one_lt_pow₀ hb hk.ne', inv_mul_cancel₀ ( by positivity : ( b : ℝ ) ^ k ≠ 0 ) ];
  simpa using tendsto_const_nhds.sub ( h_exp.comp ( Filter.tendsto_atTop_atTop.mpr fun n => ⟨ n * k, fun m hm => Nat.le_div_iff_mul_le hk |>.2 <| by linarith ⟩ ) )

/-
**Exponential decay of avoidance.** A uniformly random volume of length `L`
avoids a fixed length-`k` pattern entirely with probability at most
`(1 - b^{-k})^{⌊L/k⌋}`. This is the quantitative complement of
`prob_contains_substring_lower_bound` and drives `prob_contains_tendsto_one`.
-/
theorem prob_avoids_substring_bound {b k : ℕ} (L : ℕ) (hk : 0 < k)
    (pattern : Fin k → Fin b) :
    ProbabilityTheory.prob (Library b L) {v : Volume b L | ¬ Contains pattern v}
      ≤ (1 - (b : ℝ) ^ (-(k : ℤ))) ^ (L / k) := by
  by_cases hb : b = 0;
  · exact absurd ( Fin.is_lt ( pattern ⟨ 0, hk ⟩ ) ) ( by simp +decide [ hb ] );
  · -- Using the fact that `NoAlignedBlockMatch` implies `¬ Contains`, we can bound the probability by considering the number of volumes that avoid the pattern.
    have h_prob_bound : ProbabilityTheory.prob (Library b L) {v | ¬ Contains pattern v} ≤ (Finset.univ.filter (fun v : Volume b L => NoAlignedBlockMatch pattern v)).card / b ^ L := by
      unfold ProbabilityTheory.prob; norm_num [ Library ] ;
      gcongr;
      exact fun h t => fun ht => h ⟨ t * k, ht ⟩;
    refine le_trans h_prob_bound ?_;
    rw [ card_noAlignedBlockMatch L hk pattern, zpow_neg, zpow_natCast ];
    field_simp;
    rw [ div_pow, mul_div, le_div_iff₀ ] <;> norm_cast <;> ring <;> norm_num [ hb ];
    · rw [ Int.subNatNat_of_le ( Nat.one_le_pow _ _ ( Nat.pos_of_ne_zero hb ) ) ] ; norm_cast ; rw [ ← pow_add, Nat.add_sub_of_le ( Nat.mul_div_le _ _ ) ];
    · positivity

end LibraryOfBabel