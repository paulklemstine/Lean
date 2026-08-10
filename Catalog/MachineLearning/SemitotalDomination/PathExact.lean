import MachineLearning.SemitotalDomination.PathLowerBound

/-!
# The exact semitotal domination number of a path

Combining

* the periodic construction of `PathUpperBound.lean`,
* a tail-corrected variant of it for `n ≡ 2 (mod 5)` (this file), and
* the discharging lower bound of `PathLowerBound.lean`,

we obtain the exact formula

`γ_t2(Pₙ) = max(2, ⌈2n/5⌉)`  for every `n ≥ 2`,

which settles Conjecture 1 of `FUTURE_DIRECTIONS.md` (with `⌈2n/5⌉` written as `(2n+4)/5` in
natural division).

The correction is needed only in the residue class `n ≡ 2 (mod 5)` with `n ≥ 7`: there the plain
pattern "`1` and `3` mod `5`, plus a boundary repair" uses one vertex too many, and one must
instead *drop* the last selected vertex `n−1` and select `n−2`.
-/

namespace SemitotalDomination

open Finset SimpleGraph

/-- The tail-corrected pattern, used when `n ≡ 2 (mod 5)`: the vertices congruent to `1` or `3`
modulo `5`, except the last vertex `n−1`, together with the vertex `n−2`. -/
def pathSelTwo (n : ℕ) : Finset (Fin n) :=
  (pathSel n).filter (fun i : Fin n => (i : ℕ) + 1 ≠ n) ∪
    Finset.univ.filter (fun i : Fin n => (i : ℕ) + 2 = n)

lemma mem_pathSelTwo {n : ℕ} {i : Fin n} :
    i ∈ pathSelTwo n ↔
      (((i : ℕ) % 5 = 1 ∨ (i : ℕ) % 5 = 3) ∧ (i : ℕ) + 1 ≠ n) ∨ (i : ℕ) + 2 = n := by
  simp [pathSelTwo, mem_pathSel]

/-! ### Domination and the semitotal condition for the corrected pattern -/

theorem pathSelTwo_isDominatingSet {n : ℕ} (h5 : n % 5 = 2) (hn : 7 ≤ n) :
    IsDominatingSet (pathGraph n) (pathSelTwo n) := by
  intro v
  have hv : (v : ℕ) < n := v.isLt
  by_cases hlast : (v : ℕ) + 2 = n
  · exact Or.inl (mem_pathSelTwo.2 (Or.inr hlast))
  rcases (by omega : (v : ℕ) % 5 = 0 ∨ (v : ℕ) % 5 = 1 ∨ (v : ℕ) % 5 = 2 ∨ (v : ℕ) % 5 = 3 ∨
      (v : ℕ) % 5 = 4) with h | h | h | h | h
  · -- residue `0`: the successor is selected
    refine Or.inr ⟨⟨(v : ℕ) + 1, by omega⟩, mem_pathSelTwo.2 (Or.inl ⟨by simp; omega, by
      simp; omega⟩), ?_⟩
    have := pathGraph_adj_succ (n := n) (v : ℕ) (by omega)
    have hvv : (⟨(v : ℕ), hv⟩ : Fin n) = v := rfl
    rw [hvv] at this
    exact this.symm
  · -- residue `1`: either `v` itself is selected, or `v = n - 1` and `n - 2` dominates it
    by_cases hne : (v : ℕ) + 1 = n
    · refine Or.inr ⟨⟨n - 2, by omega⟩, mem_pathSelTwo.2 (Or.inr (by simp; omega)), ?_⟩
      have := pathGraph_adj_succ (n := n) (n - 2) (by omega)
      have hvv : (⟨n - 2 + 1, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
      rw [hvv] at this
      exact this
    · exact Or.inl (mem_pathSelTwo.2 (Or.inl ⟨Or.inl h, hne⟩))
  · -- residue `2`: the predecessor is selected
    refine Or.inr ⟨⟨(v : ℕ) - 1, by omega⟩, mem_pathSelTwo.2 (Or.inl ⟨by simp; omega, by
      simp; omega⟩), ?_⟩
    have := pathGraph_adj_succ (n := n) ((v : ℕ) - 1) (by omega)
    have hvv : (⟨(v : ℕ) - 1 + 1, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
    rw [hvv] at this
    exact this
  · -- residue `3`: `v` itself is selected (it is not the last vertex)
    exact Or.inl (mem_pathSelTwo.2 (Or.inl ⟨Or.inr h, by omega⟩))
  · -- residue `4`: the predecessor is selected
    refine Or.inr ⟨⟨(v : ℕ) - 1, by omega⟩, mem_pathSelTwo.2 (Or.inl ⟨by simp; omega, by
      simp; omega⟩), ?_⟩
    have := pathGraph_adj_succ (n := n) ((v : ℕ) - 1) (by omega)
    have hvv : (⟨(v : ℕ) - 1 + 1, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
    rw [hvv] at this
    exact this

theorem pathSelTwo_isSemitotalSet {n : ℕ} (h5 : n % 5 = 2) (hn : 7 ≤ n) :
    IsSemitotalSet (pathGraph n) (pathSelTwo n) := by
  intro v hv
  have hvlt : (v : ℕ) < n := v.isLt
  rcases mem_pathSelTwo.1 hv with ⟨hres, hne⟩ | hlast
  · rcases hres with h1 | h3
    · -- residue `1`: partner two steps to the right
      refine ⟨⟨(v : ℕ) + 2, by omega⟩, mem_pathSelTwo.2 (Or.inl ⟨by simp; omega, by
        simp; omega⟩), ?_, ?_⟩
      · intro hc
        have := congrArg Fin.val hc
        simp at this
      · have := within2_of_dist_two (n := n) (v : ℕ) (by omega)
        have hvv : (⟨(v : ℕ), hvlt⟩ : Fin n) = v := rfl
        rw [hvv] at this
        exact this.symm
    · -- residue `3`: partner two steps to the left
      refine ⟨⟨(v : ℕ) - 2, by omega⟩, mem_pathSelTwo.2 (Or.inl ⟨by simp; omega, by
        simp; omega⟩), ?_, ?_⟩
      · intro hc
        have := congrArg Fin.val hc
        simp at this
        omega
      · have := within2_of_dist_two (n := n) ((v : ℕ) - 2) (by omega)
        have hvv : (⟨(v : ℕ) - 2 + 2, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
        rw [hvv] at this
        exact this
  · -- the corrected tail vertex `n - 2`: partner `n - 4`
    refine ⟨⟨n - 4, by omega⟩, mem_pathSelTwo.2 (Or.inl ⟨by simp; omega, by simp; omega⟩), ?_, ?_⟩
    · intro hc
      have := congrArg Fin.val hc
      simp at this
      omega
    · have := within2_of_dist_two (n := n) (n - 4) (by omega)
      have hvv : (⟨n - 4 + 2, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
      rw [hvv] at this
      exact this

/-! ### Cardinality of the corrected pattern -/

lemma card_pathSelTwo_le {n : ℕ} (h5 : n % 5 = 2) (hn : 7 ≤ n) :
    (pathSelTwo n).card ≤ 2 * (n / 5) + 1 := by
  classical
  have hmemlast : (⟨n - 1, by omega⟩ : Fin n) ∈ pathSel n := by
    rw [mem_pathSel]
    left
    simp
    omega
  have hssub : (pathSel n).filter (fun i : Fin n => (i : ℕ) + 1 ≠ n) ⊂ pathSel n := by
    refine ⟨Finset.filter_subset _ _, ?_⟩
    intro hsub
    have := hsub hmemlast
    rw [Finset.mem_filter] at this
    exact this.2 (by simp; omega)
  have hcard1 : ((pathSel n).filter (fun i : Fin n => (i : ℕ) + 1 ≠ n)).card < (pathSel n).card :=
    Finset.card_lt_card hssub
  have hcard2 : (Finset.univ.filter (fun i : Fin n => (i : ℕ) + 2 = n)).card ≤ 1 := by
    rw [Finset.card_le_one]
    intro a ha b hb
    rw [Finset.mem_filter] at ha hb
    exact Fin.ext (by omega)
  have hunion : (pathSelTwo n).card
      ≤ ((pathSel n).filter (fun i : Fin n => (i : ℕ) + 1 ≠ n)).card +
        (Finset.univ.filter (fun i : Fin n => (i : ℕ) + 2 = n)).card :=
    Finset.card_union_le _ _
  have hsel := card_pathSel n
  rw [h5] at hsel
  norm_num at hsel
  omega

/-! ### The exact formula -/

/-- The plain construction already has the optimal size outside the class `n ≡ 2 (mod 5)`,
`n ≥ 7`. -/
lemma card_pathSemitotalSet_le_target {n : ℕ} (hn : 2 ≤ n) (h : ¬ (n % 5 = 2 ∧ 7 ≤ n)) :
    (pathSemitotalSet n).card ≤ max 2 ((2 * n + 4) / 5) := by
  have hunion : (pathSemitotalSet n).card ≤ (pathSel n).card + (pathPatch n).card :=
    Finset.card_union_le _ _
  have hsel := card_pathSel n
  have hpatch := card_pathPatch_le n
  rcases (by omega : n % 5 = 0 ∨ n % 5 = 1 ∨ n % 5 = 2 ∨ n % 5 = 3 ∨ n % 5 = 4) with
    h0 | h0 | h0 | h0 | h0
  · rw [card_pathPatch_eq_zero (Or.inl h0)] at hunion
    rw [hsel] at hunion
    split_ifs at hunion <;> omega
  · rw [hsel] at hunion
    split_ifs at hunion <;> omega
  · -- here `n = 2`, since the case `n ≥ 7` is excluded
    have hn2 : n = 2 := by omega
    subst hn2
    rw [hsel] at hunion
    split_ifs at hunion <;> omega
  · rw [hsel] at hunion
    split_ifs at hunion <;> omega
  · rw [card_pathPatch_eq_zero (Or.inr h0)] at hunion
    rw [hsel] at hunion
    split_ifs at hunion <;> omega

/-- **Upper bound, sharp form.**  `γ_t2(Pₙ) ≤ max(2, ⌈2n/5⌉)` for `n ≥ 2`. -/
theorem semitotalDominationNumber_pathGraph_le_max {n : ℕ} (hn : 2 ≤ n) :
    semitotalDominationNumber (pathGraph n) ≤ max 2 ((2 * n + 4) / 5) := by
  by_cases h : n % 5 = 2 ∧ 7 ≤ n
  · obtain ⟨h5, h7⟩ := h
    refine le_trans (semitotalDominationNumber_le_card
      ⟨pathSelTwo_isDominatingSet h5 h7, pathSelTwo_isSemitotalSet h5 h7⟩) ?_
    have := card_pathSelTwo_le h5 h7
    omega
  · exact le_trans (semitotalDominationNumber_le_card
      ⟨pathSemitotalSet_isDominatingSet hn, pathSemitotalSet_isSemitotalSet hn⟩)
      (card_pathSemitotalSet_le_target hn h)

/-- **The exact semitotal domination number of a path** (Conjecture 1, resolved):
`γ_t2(Pₙ) = max(2, ⌈2n/5⌉)` for every `n ≥ 2`. -/
theorem semitotalDominationNumber_pathGraph_eq {n : ℕ} (hn : 2 ≤ n) :
    semitotalDominationNumber (pathGraph n) = max 2 ((2 * n + 4) / 5) := by
  haveI : Nonempty (Fin n) := ⟨⟨0, by omega⟩⟩
  refine le_antisymm (semitotalDominationNumber_pathGraph_le_max hn) (max_le ?_ ?_)
  · exact two_le_semitotalDominationNumber (exists_semitotalDominatingSet_pathGraph hn)
  · exact ceil_two_mul_div_five_le_semitotalDominationNumber_pathGraph hn

/-- Sanity check against the independently computed instance `γ_t2(P₇) = 3`. -/
example : semitotalDominationNumber (pathGraph 7) = 3 := by
  rw [semitotalDominationNumber_pathGraph_eq (by norm_num)]
  norm_num

end SemitotalDomination