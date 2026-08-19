import Speculative.AutoResearch.FibreSpectrumRank

/-!
# Block-graded combinatorics of patterns: the Stirling row, boundary values, and tail sums

This file is the combinatorial toolbox for the *block-graded* refinement of the Bell-defect
theory developed in

* `Catalog/Bridges/MoonshineBellTransitivityBridge.lean` (orbit–pattern map, Bell floor
  `B_k·|G| ≤ Σ_g |X^g|^k`, `k`-transitivity criterion),
* `Catalog/Speculative/AutoResearch/MoonshineFibreSpectrumBridge.lean` (fibre multiplicities
  `m_P`, `bell_defect_eq`),
* `Catalog/Speculative/AutoResearch/FibreSpectrumRank.lean` (rank collapse `m_P = t_{rank P}`,
  Stirling expansion, monotonicity of the spectrum `t_r`).

All of the results of that thread are graded by the *number of blocks* only through the Stirling
numbers `S(k,r) = stirling k r` (the number of patterns of `Fin k` with `r` blocks).  To make the
grading usable one needs to know that each graded piece is inhabited and to know the boundary of
the Stirling triangle.  That is exactly what is proved here:

* `blockPattern` : an explicit pattern of `Fin k` with exactly `j` blocks (`rank_blockPattern`),
  for every `1 ≤ j ≤ k` — the coarsening `i ↦ min i (j-1)`.
* `stirling_pos` : hence `S(k,j) ≥ 1` for `1 ≤ j ≤ k`; the Stirling triangle has no interior
  zeros.
* `stirling_self`, `stirling_one`, `stirling_zero_right` : `S(k,k) = 1`, `S(k,1) = 1` (`k ≥ 1`),
  `S(k,0) = 0` (`k ≥ 1`) — the boundary values, proved by identifying the unique pattern in each
  case.
* `sum_stirling_Icc_two` : `Σ_{r=2}^{k} S(k,r) = B_k − 1`, the tail of the Bell row sum.
* `one_le_sum_stirling_Icc` : the tails `Σ_{r=j}^{k} S(k,r)` are positive.

There are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Function

namespace BellDefectGraded

open MoonshineBell FibreSpectrum

/-! ## Part 1: an explicit pattern with a prescribed number of blocks -/

section BlockPattern

variable {j k : ℕ}

/-- The **coarsening pattern** with `j` blocks: it keeps the first `j - 1` coordinates apart and
merges all remaining coordinates into the block of `j - 1`.  Concretely `i ↦ min i (j-1)`. -/
def blockPattern (k j : ℕ) : Pattern k :=
  ⟨fun i => ⟨min i.val (j - 1), by have := i.isLt; omega⟩,
    fun i => by simp [Fin.le_def],
    fun i => by
      refine Fin.ext ?_
      simp only
      omega⟩

@[simp] theorem blockPattern_apply (k j : ℕ) (i : Fin k) :
    ((blockPattern k j).1 i : ℕ) = min i.val (j - 1) := rfl

/-- The coarsening pattern has exactly `j` blocks. -/
theorem rank_blockPattern (hj : 1 ≤ j) (hjk : j ≤ k) : rank (blockPattern k j) = j := by
  classical
  have himg : leaders (blockPattern k j)
      = Finset.image (fun m : Fin j => (⟨m.val, lt_of_lt_of_le m.isLt hjk⟩ : Fin k))
        Finset.univ := by
    ext x
    simp only [leaders, Finset.mem_image, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨i, hi⟩
      refine ⟨⟨x.val, ?_⟩, ?_⟩
      · have hx : (x : ℕ) = min i.val (j - 1) := by rw [← hi]; rfl
        omega
      · exact Fin.ext rfl
    · rintro ⟨m, hm⟩
      refine ⟨x, Fin.ext ?_⟩
      have hx : (x : ℕ) = m.val := by rw [← hm]
      have := m.isLt
      simp only [blockPattern_apply]
      omega
  have hinj : Function.Injective
      (fun m : Fin j => (⟨m.val, lt_of_lt_of_le m.isLt hjk⟩ : Fin k)) := by
    intro a b hab
    exact Fin.ext (by simpa using congrArg Fin.val hab)
  rw [rank, himg, Finset.card_image_of_injective _ hinj]
  simp

/-- **No interior zeros in the Stirling triangle**: for `1 ≤ j ≤ k` there is at least one pattern
of `Fin k` with exactly `j` blocks. -/
theorem stirling_pos (hj : 1 ≤ j) (hjk : j ≤ k) : 0 < stirling k j := by
  classical
  refine Finset.card_pos.2 ⟨blockPattern k j, ?_⟩
  simp [Finset.mem_filter, rank_blockPattern hj hjk]

end BlockPattern

/-! ## Part 2: the boundary of the Stirling triangle -/

section Boundary

variable {k : ℕ}

/-- A pattern with `k` blocks on `Fin k` is the discrete pattern. -/
theorem eq_idPattern_of_rank_eq {P : Pattern k} (hP : rank P = k) : P = idPattern k := by
  classical
  have huniv : leaders P = (Finset.univ : Finset (Fin k)) :=
    Finset.eq_univ_of_card _ (by rw [card_leaders, hP]; simp)
  refine Subtype.ext (funext fun i => ?_)
  have : P.1 i = i := leader_fixed (by rw [huniv]; exact Finset.mem_univ i)
  simpa [idPattern] using this

/-- `S(k,k) = 1`: the discrete pattern is the unique pattern with `k` blocks. -/
theorem stirling_self (k : ℕ) : stirling k k = 1 := by
  classical
  have : (Finset.univ.filter fun P : Pattern k => rank P = k) = {idPattern k} := by
    ext P
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
    exact ⟨eq_idPattern_of_rank_eq, fun h => by rw [h, rank_idPattern]⟩
  rw [stirling, this, Finset.card_singleton]

/-- `S(k,0) = 0` for `k ≥ 1`: a nonempty ground set has no partition into zero blocks. -/
theorem stirling_zero_right (hk : 1 ≤ k) : stirling k 0 = 0 := by
  classical
  refine Finset.card_eq_zero.2 (Finset.eq_empty_of_forall_notMem fun P hP => ?_)
  have hrank : rank P = 0 := (Finset.mem_filter.1 hP).2
  have hmem : P.1 ⟨0, hk⟩ ∈ leaders P := leader_mem P _
  rw [← card_leaders, Finset.card_eq_zero] at hrank
  rw [hrank] at hmem
  exact absurd hmem (Finset.notMem_empty _)

/-- `S(k,1) = 1` for `k ≥ 1`: the one-block pattern is unique. -/
theorem stirling_one (hk : 1 ≤ k) : stirling k 1 = 1 := by
  classical
  have hone : (Finset.univ.filter fun P : Pattern k => rank P = 1)
      = {blockPattern k 1} := by
    ext P
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
    constructor
    · intro hP
      -- `0` is always a leader, and there is only one leader, so every value is `0`.
      have hz : P.1 ⟨0, hk⟩ = ⟨0, hk⟩ := by
        refine Fin.ext ?_
        have := P.2.1 ⟨0, hk⟩
        simpa [Fin.le_def] using this
      have h0 : (⟨0, hk⟩ : Fin k) ∈ leaders P := by
        rw [← hz]; exact leader_mem P _
      have hsingle : leaders P = {(⟨0, hk⟩ : Fin k)} := by
        refine (Finset.eq_singleton_iff_unique_mem).2 ⟨h0, fun x hx => ?_⟩
        have hcard : (leaders P).card = 1 := by rw [card_leaders, hP]
        obtain ⟨y, hy⟩ := Finset.card_eq_one.1 hcard
        rw [hy] at hx h0
        rw [Finset.mem_singleton] at hx h0
        rw [hx, h0]
      refine Subtype.ext (funext fun i => Fin.ext ?_)
      have : P.1 i ∈ leaders P := leader_mem P i
      rw [hsingle, Finset.mem_singleton] at this
      rw [this]
      simp
    · intro hP
      rw [hP, rank_blockPattern (le_refl 1) hk]
  rw [stirling, hone, Finset.card_singleton]

/-! ## Part 3: tails of the Bell row sum -/

/-- Splitting the Stirling row at `r = 0, 1`. -/
theorem bell_eq_add_sum_Icc (hk : 1 ≤ k) :
    bell k = stirling k 0 + stirling k 1 + ∑ r ∈ Finset.Icc 2 k, stirling k r := by
  classical
  have hsplit : Finset.range (k + 1) = insert 0 (insert 1 (Finset.Icc 2 k)) := by
    ext r
    simp only [Finset.mem_range, Finset.mem_insert, Finset.mem_Icc]
    omega
  have h1 : (1 : ℕ) ∉ Finset.Icc 2 k := by simp
  have h0 : (0 : ℕ) ∉ insert 1 (Finset.Icc 2 k) := by simp
  rw [bell_eq_sum_stirling, hsplit, Finset.sum_insert h0, Finset.sum_insert h1, add_assoc]

/-- **Tail of the Bell row.**  `Σ_{r=2}^{k} S(k,r) = B_k − 1` for `k ≥ 1`. -/
theorem sum_stirling_Icc_two (hk : 1 ≤ k) :
    ∑ r ∈ Finset.Icc 2 k, stirling k r = bell k - 1 := by
  rw [bell_eq_add_sum_Icc hk, stirling_zero_right hk, stirling_one hk]
  omega

/-- Every tail `Σ_{r=j}^{k} S(k,r)` of a Stirling row is positive (for `j ≤ k`), because it
contains the term `S(k,k) = 1`. -/
theorem one_le_sum_stirling_Icc {j : ℕ} (hjk : j ≤ k) :
    1 ≤ ∑ r ∈ Finset.Icc j k, stirling k r := by
  classical
  calc (1 : ℕ) = stirling k k := (stirling_self k).symm
    _ ≤ ∑ r ∈ Finset.Icc j k, stirling k r :=
        Finset.single_le_sum (f := fun r => stirling k r) (fun _ _ => Nat.zero_le _)
          (Finset.mem_Icc.2 ⟨hjk, le_refl k⟩)

/-- `B_k ≥ 2` for `k ≥ 2`. -/
theorem two_le_bell (hk : 2 ≤ k) : 2 ≤ bell k := by
  have h := one_le_sum_stirling_Icc (k := k) (j := 2) hk
  rw [sum_stirling_Icc_two (by omega)] at h
  omega

end Boundary

/-! ## Part 4: counting injective tuples -/

/-- The number of injective `k`-tuples in a finite set is the falling factorial. -/
theorem card_injective_tuples (X : Type*) [Finite X] (k : ℕ) :
    Nat.card {f : Fin k → X // Function.Injective f} = (Nat.card X).descFactorial k := by
  classical
  cases nonempty_fintype X
  have e : {f : Fin k → X // Function.Injective f} ≃ (Fin k ↪ X) :=
    { toFun := fun f => ⟨f.1, f.2⟩
      invFun := fun f => ⟨f.1, f.2⟩
      left_inv := fun _ => rfl
      right_inv := fun _ => rfl }
  rw [Nat.card_congr e, Nat.card_eq_fintype_card, Fintype.card_embedding_eq, Fintype.card_fin,
    Nat.card_eq_fintype_card]

end BellDefectGraded