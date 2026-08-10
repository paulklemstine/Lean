import MachineLearning.SemitotalDomination.Paths

/-!
# An explicit `2⌈n/5⌉` semitotal dominating set of the path

`Paths.lean` sandwiches `γ_t2(Pₙ)` between `⌈n/3⌉` and `2⌈n/3⌉` using only universal
inequalities.  Here we prove the much better *upper* bound

`γ_t2(Pₙ) ≤ 2⌈n/5⌉ = 2 · ((n+4)/5)`  for `n ≥ 2`,

by exhibiting an explicit periodic set: take every vertex congruent to `1` or `3` modulo `5`,
and repair the boundary with at most one extra vertex.  Inside a block
`{5k, 5k+1, 5k+2, 5k+3, 5k+4}` the two chosen vertices `5k+1` and `5k+3` dominate all five
vertices and are at distance exactly `2`, so they are each other's semitotal partner — this is
the "block of five" pattern that makes the conjectured formula `max(2, ⌈2n/5⌉)` plausible
(`FUTURE_DIRECTIONS.md`, Conjecture 1); the upper half of that conjecture is what is proved here.
-/

namespace SemitotalDomination

open Finset SimpleGraph

/-- The periodic pattern: all vertices congruent to `1` or `3` modulo `5`. -/
def pathSel (n : ℕ) : Finset (Fin n) :=
  Finset.univ.filter (fun i : Fin n => (i : ℕ) % 5 = 1 ∨ (i : ℕ) % 5 = 3)

/-- The boundary repair: at most one extra vertex near the right end of the path. -/
def pathPatch (n : ℕ) : Finset (Fin n) :=
  if h : n % 5 = 1 ∨ n % 5 = 3 then {⟨n - 1, by omega⟩}
  else if h2 : n % 5 = 2 then {⟨n - 2, by omega⟩}
  else ∅

/-- The explicit semitotal dominating set of `Pₙ`. -/
def pathSemitotalSet (n : ℕ) : Finset (Fin n) := pathSel n ∪ pathPatch n

@[simp] lemma mem_pathSel {n : ℕ} {i : Fin n} :
    i ∈ pathSel n ↔ (i : ℕ) % 5 = 1 ∨ (i : ℕ) % 5 = 3 := by simp [pathSel]

lemma mem_pathSemitotalSet_of_sel {n : ℕ} {i : Fin n}
    (h : (i : ℕ) % 5 = 1 ∨ (i : ℕ) % 5 = 3) : i ∈ pathSemitotalSet n :=
  Finset.mem_union_left _ (mem_pathSel.2 h)

lemma mem_pathSemitotalSet_of_patch {n : ℕ} {i : Fin n} (h : i ∈ pathPatch n) :
    i ∈ pathSemitotalSet n := Finset.mem_union_right _ h

/-- Adjacency of consecutive vertices of the path. -/
lemma pathGraph_adj_succ {n : ℕ} (k : ℕ) (h1 : k + 1 < n) :
    (pathGraph n).Adj ⟨k, by omega⟩ ⟨k + 1, h1⟩ := by
  rw [pathGraph_adj]
  left
  rfl

/-! ### Domination -/

theorem pathSemitotalSet_isDominatingSet {n : ℕ} (hn : 2 ≤ n) :
    IsDominatingSet (pathGraph n) (pathSemitotalSet n) := by
  intro v
  have hv : (v : ℕ) < n := v.isLt
  rcases (by omega : (v : ℕ) % 5 = 0 ∨ (v : ℕ) % 5 = 1 ∨ (v : ℕ) % 5 = 2 ∨ (v : ℕ) % 5 = 3 ∨
      (v : ℕ) % 5 = 4) with h | h | h | h | h
  · -- residue 0: the successor is selected, unless we are at the right end
    by_cases hsucc : (v : ℕ) + 1 < n
    · refine Or.inr ⟨⟨(v : ℕ) + 1, hsucc⟩, mem_pathSemitotalSet_of_sel (by simp; omega), ?_⟩
      have := pathGraph_adj_succ (n := n) (v : ℕ) hsucc
      have hvv : (⟨(v : ℕ), hv⟩ : Fin n) = v := rfl
      rw [hvv] at this
      exact this.symm
    · -- `v` is the last vertex and `n % 5 = 1`; then `v` itself is the patch
      have hn5 : n % 5 = 1 := by omega
      refine Or.inl (mem_pathSemitotalSet_of_patch ?_)
      rw [pathPatch, dif_pos (Or.inl hn5)]
      simp only [Finset.mem_singleton]
      exact Fin.ext (by simp; omega)
  · exact Or.inl (mem_pathSemitotalSet_of_sel (Or.inl h))
  · -- residue 2: the predecessor (residue 1) is selected
    refine Or.inr ⟨⟨(v : ℕ) - 1, by omega⟩, mem_pathSemitotalSet_of_sel (by simp; omega), ?_⟩
    have := pathGraph_adj_succ (n := n) ((v : ℕ) - 1) (by omega)
    have hvv : (⟨(v : ℕ) - 1 + 1, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
    rw [hvv] at this
    exact this
  · exact Or.inl (mem_pathSemitotalSet_of_sel (Or.inr h))
  · -- residue 4: the predecessor (residue 3) is selected
    refine Or.inr ⟨⟨(v : ℕ) - 1, by omega⟩, mem_pathSemitotalSet_of_sel (by simp; omega), ?_⟩
    have := pathGraph_adj_succ (n := n) ((v : ℕ) - 1) (by omega)
    have hvv : (⟨(v : ℕ) - 1 + 1, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
    rw [hvv] at this
    exact this

/-! ### The semitotal condition -/

/-- Two vertices of the path at distance two are `Within2`. -/
lemma within2_of_dist_two {n : ℕ} (k : ℕ) (h : k + 2 < n) :
    Within2 (pathGraph n) ⟨k, by omega⟩ ⟨k + 2, h⟩ :=
  Within2.of_adj_adj (pathGraph_adj_succ k (by omega))
    (by simpa using pathGraph_adj_succ (n := n) (k + 1) (by omega))

theorem pathSemitotalSet_isSemitotalSet {n : ℕ} (hn : 2 ≤ n) :
    IsSemitotalSet (pathGraph n) (pathSemitotalSet n) := by
  intro v hv
  have hvlt : (v : ℕ) < n := v.isLt
  rcases Finset.mem_union.1 hv with hsel | hpatch
  · rcases mem_pathSel.1 hsel with h1 | h3
    · -- residue 1: partner at distance two, unless we are at the right end
      by_cases hfar : (v : ℕ) + 2 < n
      · refine ⟨⟨(v : ℕ) + 2, hfar⟩, mem_pathSemitotalSet_of_sel (by simp; omega), ?_, ?_⟩
        · intro hc
          have := congrArg Fin.val hc
          simp at this
        · have := within2_of_dist_two (n := n) (v : ℕ) hfar
          have hvv : (⟨(v : ℕ), hvlt⟩ : Fin n) = v := rfl
          rw [hvv] at this
          exact this.symm
      · -- `v` is one of the last two vertices; the patch vertex is its neighbour
        by_cases hlast : (v : ℕ) + 1 = n
        · -- `n % 5 = 2`, patch is `n - 2 = v - 1`
          have hn5 : n % 5 = 2 := by omega
          refine ⟨⟨n - 2, by omega⟩, mem_pathSemitotalSet_of_patch ?_, ?_, ?_⟩
          · rw [pathPatch, dif_neg (by omega), dif_pos hn5]
            simp
          · intro hc
            have := congrArg Fin.val hc
            simp at this
            omega
          · refine Within2.of_adj ?_
            have := pathGraph_adj_succ (n := n) (n - 2) (by omega)
            have hvv : (⟨n - 2 + 1, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
            rw [hvv] at this
            exact this
        · -- `v = n - 2` and `n % 5 = 3`, patch is `n - 1 = v + 1`
          have hn5 : n % 5 = 3 := by omega
          refine ⟨⟨n - 1, by omega⟩, mem_pathSemitotalSet_of_patch ?_, ?_, ?_⟩
          · rw [pathPatch, dif_pos (Or.inr hn5)]
            simp
          · intro hc
            have := congrArg Fin.val hc
            simp at this
            omega
          · refine Within2.symm (Within2.of_adj ?_)
            have := pathGraph_adj_succ (n := n) ((v : ℕ)) (by omega)
            have hvv : (⟨(v : ℕ), hvlt⟩ : Fin n) = v := rfl
            have hvv2 : (⟨(v : ℕ) + 1, by omega⟩ : Fin n) = (⟨n - 1, by omega⟩ : Fin n) :=
              Fin.ext (by simp; omega)
            rw [hvv, hvv2] at this
            exact this
    · -- residue 3: partner at distance two on the left
      refine ⟨⟨(v : ℕ) - 2, by omega⟩, mem_pathSemitotalSet_of_sel (by simp; omega), ?_, ?_⟩
      · intro hc
        have := congrArg Fin.val hc
        simp at this
        omega
      · have := within2_of_dist_two (n := n) ((v : ℕ) - 2) (by omega)
        have hvv : (⟨(v : ℕ) - 2 + 2, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
        rw [hvv] at this
        exact this
  · -- the patch vertex itself
    rcases (by omega : n % 5 = 0 ∨ n % 5 = 1 ∨ n % 5 = 2 ∨ n % 5 = 3 ∨ n % 5 = 4) with
      h | h | h | h | h
    · rw [pathPatch, dif_neg (by omega), dif_neg (by omega)] at hpatch; simp at hpatch
    · -- `v = n - 1`, residue `0`; partner `n - 3` at distance two
      rw [pathPatch, dif_pos (Or.inl h)] at hpatch
      have hveq : (v : ℕ) = n - 1 := by
        simp only [Finset.mem_singleton] at hpatch
        exact congrArg Fin.val hpatch
      refine ⟨⟨n - 3, by omega⟩, mem_pathSemitotalSet_of_sel (by simp; omega), ?_, ?_⟩
      · intro hc
        have := congrArg Fin.val hc
        simp at this
        omega
      · have := within2_of_dist_two (n := n) (n - 3) (by omega)
        have hvv : (⟨n - 3 + 2, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
        rw [hvv] at this
        exact this
    · -- `v = n - 2`, residue `0`; partner `n - 1`, adjacent
      rw [pathPatch, dif_neg (by omega), dif_pos h] at hpatch
      have hveq : (v : ℕ) = n - 2 := by
        simp only [Finset.mem_singleton] at hpatch
        exact congrArg Fin.val hpatch
      refine ⟨⟨n - 1, by omega⟩, mem_pathSemitotalSet_of_sel (by simp; omega), ?_, ?_⟩
      · intro hc
        have := congrArg Fin.val hc
        simp at this
        omega
      · refine Within2.symm (Within2.of_adj ?_)
        have := pathGraph_adj_succ (n := n) (n - 2) (by omega)
        have hvv : (⟨n - 2, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
        have hvv2 : (⟨n - 2 + 1, by omega⟩ : Fin n) = (⟨n - 1, by omega⟩ : Fin n) :=
          Fin.ext (by simp; omega)
        rw [hvv, hvv2] at this
        exact this
    · -- `v = n - 1`, residue `2`; partner `n - 2`, adjacent
      rw [pathPatch, dif_pos (Or.inr h)] at hpatch
      have hveq : (v : ℕ) = n - 1 := by
        simp only [Finset.mem_singleton] at hpatch
        exact congrArg Fin.val hpatch
      refine ⟨⟨n - 2, by omega⟩, mem_pathSemitotalSet_of_sel (by simp; omega), ?_, ?_⟩
      · intro hc
        have := congrArg Fin.val hc
        simp at this
        omega
      · refine Within2.of_adj ?_
        have := pathGraph_adj_succ (n := n) (n - 2) (by omega)
        have hvv : (⟨n - 2 + 1, by omega⟩ : Fin n) = v := Fin.ext (by simp; omega)
        rw [hvv] at this
        exact this
    · rw [pathPatch, dif_neg (by omega), dif_neg (by omega)] at hpatch; simp at hpatch

/-! ### Cardinality -/

lemma card_filter_mod5 (n : ℕ) :
    ((range n).filter (fun i => i % 5 = 1 ∨ i % 5 = 3)).card
      = 2 * (n / 5) + (if 2 ≤ n % 5 then 1 else 0) + (if 4 ≤ n % 5 then 1 else 0) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [Finset.range_add_one, Finset.filter_insert]
    by_cases h : n % 5 = 1 ∨ n % 5 = 3
    · rw [if_pos h, Finset.card_insert_of_notMem (by simp), ih]
      split_ifs <;> omega
    · rw [if_neg h, ih]
      split_ifs <;> omega

lemma card_pathSel (n : ℕ) :
    (pathSel n).card
      = 2 * (n / 5) + (if 2 ≤ n % 5 then 1 else 0) + (if 4 ≤ n % 5 then 1 else 0) := by
  rw [← card_filter_mod5 n, pathSel,
    ← Finset.card_image_of_injective
      (Finset.univ.filter (fun i : Fin n => (i : ℕ) % 5 = 1 ∨ (i : ℕ) % 5 = 3)) Fin.val_injective]
  congr 1
  ext k
  simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_range]
  constructor
  · rintro ⟨i, hi, rfl⟩; exact ⟨i.isLt, hi⟩
  · rintro ⟨hk, hP⟩; exact ⟨⟨k, hk⟩, hP, rfl⟩

lemma card_pathPatch_le (n : ℕ) : (pathPatch n).card ≤ 1 := by
  rw [pathPatch]
  split_ifs <;> simp

lemma card_pathPatch_eq_zero {n : ℕ} (h : n % 5 = 0 ∨ n % 5 = 4) : (pathPatch n).card = 0 := by
  rw [pathPatch, dif_neg (by omega), dif_neg (by omega)]
  simp

/-- The explicit set has at most `2⌈n/5⌉` vertices. -/
theorem card_pathSemitotalSet_le (n : ℕ) : (pathSemitotalSet n).card ≤ 2 * ((n + 4) / 5) := by
  have hunion : (pathSemitotalSet n).card ≤ (pathSel n).card + (pathPatch n).card :=
    Finset.card_union_le _ _
  have hsel := card_pathSel n
  rcases (by omega : n % 5 = 0 ∨ n % 5 = 1 ∨ n % 5 = 2 ∨ n % 5 = 3 ∨ n % 5 = 4) with
    h | h | h | h | h
  · have hp := card_pathPatch_eq_zero (Or.inl h)
    rw [hsel] at hunion
    split_ifs at hunion <;> omega
  · have hp := card_pathPatch_le n
    rw [hsel] at hunion
    split_ifs at hunion <;> omega
  · have hp := card_pathPatch_le n
    rw [hsel] at hunion
    split_ifs at hunion <;> omega
  · have hp := card_pathPatch_le n
    rw [hsel] at hunion
    split_ifs at hunion <;> omega
  · have hp := card_pathPatch_eq_zero (Or.inr h)
    rw [hsel] at hunion
    split_ifs at hunion <;> omega

/-- **Upper bound for paths.**  `γ_t2(Pₙ) ≤ 2⌈n/5⌉` for `n ≥ 2`.  This is the upper half of the
conjectured formula `γ_t2(Pₙ) = max(2, ⌈2n/5⌉)`. -/
theorem semitotalDominationNumber_pathGraph_le_two_mul_ceil_div_five {n : ℕ} (hn : 2 ≤ n) :
    semitotalDominationNumber (pathGraph n) ≤ 2 * ((n + 4) / 5) :=
  le_trans
    (semitotalDominationNumber_le_card
      ⟨pathSemitotalSet_isDominatingSet hn, pathSemitotalSet_isSemitotalSet hn⟩)
    (card_pathSemitotalSet_le n)

end SemitotalDomination