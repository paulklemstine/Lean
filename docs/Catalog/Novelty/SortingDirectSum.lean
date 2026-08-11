import Novelty.MultiwaySortingRadix

/-!
# A thermodynamic direct-sum theorem for independent sorting tasks

Sorting two independent blocks of sizes `m` and `n` is modelled, as in the catalog, by the
constant map on the product of the two symmetric groups.  We prove the "entropy adds while
reversible state counts multiply" dichotomy conjectured in the previous cycle:

* `blockSorting_infoErased` / `blockSorting_landauer_additive`: the erased information and
  the Landauer work of the joint task are the **sums** of the single-block quantities.
* `block_history_lower_bound`: any reversible implementation needs at least `m! · n!`
  history states — the **product** of the block factorials.
* `block_history_equality_iff_no_garbage`: the history space has cardinality exactly
  `m! · n!` **iff** the history map is a bijection, i.e. iff the retained history is exactly
  the pair of block permutations with no cross-block garbage.  This settles the equality
  case left open by the conjecture.
* `block_depth_direct_sum`: for radix-`q` query models, the depth charge of a joint sorter
  is at least the sum of the two single-block Landauer baselines.

The general product lemma `infoErased_prod_const` is stated for arbitrary finite nonempty
types, so it applies to any tensorized erasure task, not only sorting.
-/

open Finset

namespace SortingDirectSum

/-- The block-sorting map: sort two independent blocks, keeping no information. -/
def blockSortingFunction (m n : ℕ) :
    Equiv.Perm (Fin m) × Equiv.Perm (Fin n) → Unit := fun _ => ()

/-- **Additivity of erased information for a product task.**  Collapsing a product of two
finite nonempty types erases the sum of the two individual entropies. -/
theorem infoErased_prod_const (α β : Type*) [Fintype α] [Fintype β] [Nonempty α] [Nonempty β] :
    infoErased (fun (_ : α × β) => ()) =
      infoErased (fun (_ : α) => ()) + infoErased (fun (_ : β) => ()) := by
  have hα : (0 : ℝ) < Fintype.card α := by exact_mod_cast Fintype.card_pos
  have hβ : (0 : ℝ) < Fintype.card β := by exact_mod_cast Fintype.card_pos
  unfold infoErased
  rw [Finset.image_const Finset.univ_nonempty, Finset.image_const Finset.univ_nonempty,
    Finset.image_const Finset.univ_nonempty]
  simp only [Finset.card_singleton, Nat.cast_one, Real.logb_one, sub_zero]
  rw [Fintype.card_prod]
  push_cast
  exact Real.logb_mul (ne_of_gt hα) (ne_of_gt hβ)

/-- The information erased by sorting two independent blocks is `log₂(m!) + log₂(n!)`. -/
theorem blockSorting_infoErased (m n : ℕ) :
    infoErased (blockSortingFunction m n) =
      Real.logb 2 m.factorial + Real.logb 2 n.factorial := by
  have h := infoErased_prod_const (Equiv.Perm (Fin m)) (Equiv.Perm (Fin n))
  rw [show blockSortingFunction m n = (fun (_ : Equiv.Perm (Fin m) × Equiv.Perm (Fin n)) => ())
    from rfl, h, SortingEntropyWork.sorting_info_erased_all m, SortingEntropyWork.sorting_info_erased_all n]

/-- **Direct sum for Landauer work.**  The minimum logical-erasure work of sorting two
independent blocks is the sum of the block works. -/
theorem blockSorting_landauer_additive (m n : ℕ) (kT : ℝ) :
    landauerGap (blockSortingFunction m n) kT =
      landauerGap (sortingFunction m) kT + landauerGap (sortingFunction n) kT := by
  unfold landauerGap landauerCost
  rw [blockSorting_infoErased, SortingEntropyWork.sorting_info_erased_all, SortingEntropyWork.sorting_info_erased_all]
  ring

/-- Cardinality of the joint ordering space: `m! · n!`. -/
theorem card_block_perm (m n : ℕ) :
    Fintype.card (Equiv.Perm (Fin m) × Equiv.Perm (Fin n)) = m.factorial * n.factorial := by
  rw [Fintype.card_prod, perm_card, perm_card]

/-- The history map of a reversible implementation: the auxiliary component of the encoding. -/
def historyMap {m n : ℕ} {Aux : Type*}
    (e : Equiv.Perm (Fin m) × Equiv.Perm (Fin n) ≃ Unit × Aux) :
    Equiv.Perm (Fin m) × Equiv.Perm (Fin n) → Aux := fun p => (e p).2

/-- The history map of a reversible implementation of block sorting is injective: the
history alone must determine the input, since the output is constant. -/
theorem historyMap_injective {m n : ℕ} {Aux : Type*}
    (e : Equiv.Perm (Fin m) × Equiv.Perm (Fin n) ≃ Unit × Aux) :
    Function.Injective (historyMap e) := by
  intro p₁ p₂ h
  exact e.injective (Prod.ext rfl h)

/-- **History states multiply.**  Any reversible implementation of the two-block sorting
task needs a history space of at least `m! · n!` states. -/
theorem block_history_lower_bound (m n : ℕ) (Aux : Type*) [Fintype Aux]
    (e : Equiv.Perm (Fin m) × Equiv.Perm (Fin n) ≃ Unit × Aux) :
    m.factorial * n.factorial ≤ Fintype.card Aux := by
  have h := Fintype.card_le_of_injective _ (historyMap_injective e)
  rwa [card_block_perm] at h

/-- **Equality case: no cross-block garbage.**  A reversible implementation attains the
minimal history space `|Aux| = m!·n!` exactly when its history map is a bijection, i.e. the
retained history is a faithful, garbage-free copy of the pair of block orderings. -/
theorem block_history_equality_iff_no_garbage (m n : ℕ) (Aux : Type*) [Fintype Aux]
    (e : Equiv.Perm (Fin m) × Equiv.Perm (Fin n) ≃ Unit × Aux) :
    Fintype.card Aux = m.factorial * n.factorial ↔ Function.Bijective (historyMap e) := by
  constructor
  · intro hcard
    refine ⟨historyMap_injective e, ?_⟩
    have hc : Fintype.card (Equiv.Perm (Fin m) × Equiv.Perm (Fin n)) = Fintype.card Aux := by
      rw [card_block_perm, hcard]
    exact (Fintype.bijective_iff_injective_and_card _).2 ⟨historyMap_injective e, hc⟩ |>.2
  · intro hbij
    have := Fintype.card_of_bijective hbij
    rw [card_block_perm] at this
    exact this.symm

/-- **Strict garbage bound.**  If the history map is *not* surjective (there is unused or
cross-block garbage), the history space is strictly larger than `m!·n!`. -/
theorem block_history_strict_of_garbage (m n : ℕ) (Aux : Type*) [Fintype Aux]
    (e : Equiv.Perm (Fin m) × Equiv.Perm (Fin n) ≃ Unit × Aux)
    (hns : ¬ Function.Surjective (historyMap e)) :
    m.factorial * n.factorial < Fintype.card Aux := by
  rcases lt_or_eq_of_le (block_history_lower_bound m n Aux e) with h | h
  · exact h
  · exact absurd ((block_history_equality_iff_no_garbage m n Aux e).1 h.symm).2 hns

/-! ## Direct sum in the multiway query model -/

/-- A joint radix-`q`, depth-`d` sorter for two independent blocks: the transcript
determines both block orderings. -/
structure BlockSorter (m n q d : ℕ) where
  /-- The transcript of the `d` queries. -/
  transcript : Equiv.Perm (Fin m) × Equiv.Perm (Fin n) → MultiwaySorting.Transcript q d
  /-- Correctness for the joint task. -/
  correct : Function.Injective transcript

/-- **Depth direct sum.**  A joint sorter's depth obeys `m!·n! ≤ q^d`, hence its physical
charge `d · kT log q` is at least the *sum* of the two single-block Landauer baselines. -/
theorem block_depth_direct_sum {m n q d : ℕ} (S : BlockSorter m n q d) {kT : ℝ} (hkT : 0 ≤ kT) :
    landauerGap (sortingFunction m) kT + landauerGap (sortingFunction n) kT
      ≤ MultiwaySorting.naiveTranscriptWork kT q d := by
  have hcount : m.factorial * n.factorial ≤ q ^ d := by
    have h := Fintype.card_le_of_injective _ S.correct
    rwa [card_block_perm, MultiwaySorting.card_transcript] at h
  have hcast : ((m.factorial : ℝ)) * (n.factorial : ℝ) ≤ (q : ℝ) ^ d := by
    exact_mod_cast hcount
  have hmpos : (0 : ℝ) < m.factorial := by exact_mod_cast m.factorial_pos
  have hnpos : (0 : ℝ) < n.factorial := by exact_mod_cast n.factorial_pos
  have hlog : Real.log m.factorial + Real.log n.factorial ≤ (d : ℝ) * Real.log q := by
    calc Real.log m.factorial + Real.log n.factorial
        = Real.log ((m.factorial : ℝ) * (n.factorial : ℝ)) :=
          (Real.log_mul (ne_of_gt hmpos) (ne_of_gt hnpos)).symm
      _ ≤ Real.log ((q : ℝ) ^ d) := Real.log_le_log (by positivity) hcast
      _ = (d : ℝ) * Real.log q := Real.log_pow _ _
  rw [SortingEntropyWork.sorting_landauer_gap_exact, SortingEntropyWork.sorting_landauer_gap_exact]
  calc kT * Real.log m.factorial + kT * Real.log n.factorial
      = kT * (Real.log m.factorial + Real.log n.factorial) := by ring
    _ ≤ kT * ((d : ℝ) * Real.log q) := mul_le_mul_of_nonneg_left hlog hkT
    _ = MultiwaySorting.naiveTranscriptWork kT q d := by
        unfold MultiwaySorting.naiveTranscriptWork; ring

/-- **Thermodynamic direct-sum synthesis.**  For two independent blocks:
entropy (and hence Landauer work) is *additive*, the reversible history space is at least
the *product* `m!·n!` of the block factorials, and the product is attained exactly when the
implementation carries no garbage beyond the two block orderings. -/
theorem sorting_direct_sum_synthesis (m n : ℕ) (kT : ℝ) (Aux : Type*) [Fintype Aux]
    (e : Equiv.Perm (Fin m) × Equiv.Perm (Fin n) ≃ Unit × Aux) :
    landauerGap (blockSortingFunction m n) kT =
        landauerGap (sortingFunction m) kT + landauerGap (sortingFunction n) kT ∧
    m.factorial * n.factorial ≤ Fintype.card Aux ∧
    (Fintype.card Aux = m.factorial * n.factorial ↔ Function.Bijective (historyMap e)) :=
  ⟨blockSorting_landauer_additive m n kT, block_history_lower_bound m n Aux e,
    block_history_equality_iff_no_garbage m n Aux e⟩

-- !-- Lab Notes -- !--
-- Hypothesis (Future Direction 3): entropy adds while reversible state counts multiply,
-- with equality in the state count characterising garbage-free protocols.
-- Experiment: small blocks were tabulated.  For (m,n) = (3,3): erased information
-- log₂ 6 + log₂ 6 = 5.1699 bits = log₂ 36, minimal history 36 states.  For (m,n) = (4,2):
-- log₂ 24 + log₂ 2 = 5.585 bits, minimal history 48.  Any implementation with, say, 49
-- history states has a non-surjective history map, matching `block_history_strict_of_garbage`.
-- Analysis: additivity is `log(ab) = log a + log b` applied to the product of ordering
-- spaces; multiplicativity is `Fintype.card_prod` plus injectivity of the history map.  The
-- equality case is the finite pigeonhole statement `injective + equal cardinality ↔ bijective`,
-- which is exactly the formal content of "no cross-block garbage".
-- Critique: the model charges nothing for the *interface* between blocks; a protocol that
-- physically interleaves the blocks is still covered, since only the induced encoding map
-- matters.  The equality criterion is about the history map, not about the algorithm's
-- intermediate states, so it does not preclude transient garbage that is later uncomputed.
-- !-- end Lab Notes -- !--

end SortingDirectSum