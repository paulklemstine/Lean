import Mathlib

/-!
# Adjacent-sum lattice sets and their transfer matrices

Fix a *slack* parameter `s : ℕ`.  The **open adjacent-sum set** in dimension `d + 1`
is the set of lattice points

`Δ(s, d) = { x ∈ ℤ^{d+1} : 0 ≤ xᵢ,  xᵢ + xᵢ₊₁ ≤ s  (0 ≤ i < d) }`

and the **cyclic adjacent-sum set** is the analogous set where the index `i + 1` is
taken modulo the length, so that the constraint graph is a cycle rather than a path.
Both are the sets of lattice points of a lattice polytope (the `d`-fold "adjacent-sum"
polytope), which is why their counting functions are Ehrhart-type quantities.

Because `0 ≤ xᵢ` and `xᵢ + xᵢ₊₁ ≤ s` force `xᵢ ≤ s`, every coordinate lives in the
`(s+1)`-element state space `Fin (s+1)`; the model with `s + 1` slack has the
`(s + 2)`-state transfer matrix `adjMat (s+1)`.

The **transfer matrix** is the `(s+1) × (s+1)` `0/1` matrix

`adjMat s a b = 1 ↔ a + b ≤ s`.

## Main results

* `AdjSum.card_pathSet` : the number of open adjacent-sum points of length `d + 1`
  with prescribed first coordinate `a` and last coordinate `b` is the matrix entry
  `(adjMat s ^ d) a b`.
* `AdjSum.card_openSet` : the total number of open points of length `d+1` is the
  sum of all entries of `adjMat s ^ d`.
* `AdjSum.card_cycSet` : the number of cyclic points of length `d + 1` is
  `trace (adjMat s ^ (d+1))`.
* `AdjSum.adjMat_isSymm`, `AdjSum.card_openSet_symm_swap` : structural symmetries.

-- !-- Lab Notes -- !--
* **Hypothesis.** The naive "walks in a digraph" heuristic should hold verbatim
  for these lattice sets: open points ↔ matrix products, cyclic points ↔ traces.
* **Experiment.** `#eval`-ing `trace (adjMat 1 ^ n)` gives `1, 3, 4, 7, 11, 18, 29, 47`
  (Lucas numbers) and `∑ₐ∑_b (adjMat 1 ^ n) a b` gives `2, 3, 5, 8, 13, 21, 34`
  (Fibonacci), matching a direct enumeration of `0/1` vectors with no two adjacent
  ones — the classical sanity check.  For `s = 2`: cyclic `2, 6, 11, 26, 57, 129`,
  open `3, 6, 14, 31, 70, 157`.
* **Analysis.** The proofs are genuine `Fin.snoc`/`Fin.init` bijections; the cyclic
  case additionally needs the wrap-around index lemma `castSucc_add_one` and
  `Fin.last_add_one`.
* **Critique.** No statement here is definitional: both sides are computed by
  different mechanisms (cardinality of a filtered `Finset` vs. matrix powers), and
  the induction step is a fiberwise decomposition, not `rfl`.
-/

namespace AdjSum

open Finset Matrix

/-- The adjacent-sum transfer matrix: `adjMat s a b = 1` iff `a + b ≤ s`. -/
def adjMat (s : ℕ) : Matrix (Fin (s + 1)) (Fin (s + 1)) ℕ :=
  fun a b => if (a : ℕ) + (b : ℕ) ≤ s then 1 else 0

@[simp] lemma adjMat_apply (s : ℕ) (a b : Fin (s + 1)) :
    adjMat s a b = if (a : ℕ) + (b : ℕ) ≤ s then 1 else 0 := rfl

/-- The transfer matrix is symmetric (the constraint `a + b ≤ s` is). -/
theorem adjMat_isSymm (s : ℕ) : (adjMat s).IsSymm := by
  ext a b
  simp only [Matrix.transpose_apply, adjMat_apply]
  rw [Nat.add_comm]

/-- The set of open adjacent-sum lattice points of length `d + 1` and slack `s`. -/
def openSet (s d : ℕ) : Finset (Fin (d + 1) → Fin (s + 1)) :=
  Finset.univ.filter
    (fun x => ∀ i : Fin d, ((x i.castSucc : Fin (s + 1)) : ℕ) + ((x i.succ : Fin (s + 1)) : ℕ) ≤ s)

/-- Open adjacent-sum points with prescribed endpoints `a` (first) and `b` (last). -/
def pathSet (s d : ℕ) (a b : Fin (s + 1)) : Finset (Fin (d + 1) → Fin (s + 1)) :=
  (openSet s d).filter (fun x => x 0 = a ∧ x (Fin.last d) = b)

/-- The set of cyclic adjacent-sum lattice points of length `d + 1` and slack `s`. -/
def cycSet (s d : ℕ) : Finset (Fin (d + 1) → Fin (s + 1)) :=
  Finset.univ.filter
    (fun x => ∀ i : Fin (d + 1), ((x i : Fin (s + 1)) : ℕ) + ((x (i + 1) : Fin (s + 1)) : ℕ) ≤ s)

lemma mem_openSet {s d : ℕ} {x : Fin (d + 1) → Fin (s + 1)} :
    x ∈ openSet s d ↔
      ∀ i : Fin d, ((x i.castSucc : Fin (s + 1)) : ℕ) + ((x i.succ : Fin (s + 1)) : ℕ) ≤ s := by
  simp [openSet]

lemma mem_pathSet {s d : ℕ} {a b : Fin (s + 1)} {x : Fin (d + 1) → Fin (s + 1)} :
    x ∈ pathSet s d a b ↔
      (∀ i : Fin d, ((x i.castSucc : Fin (s + 1)) : ℕ) + ((x i.succ : Fin (s + 1)) : ℕ) ≤ s) ∧
        x 0 = a ∧ x (Fin.last d) = b := by
  simp [pathSet, openSet]

lemma mem_cycSet {s d : ℕ} {x : Fin (d + 1) → Fin (s + 1)} :
    x ∈ cycSet s d ↔
      ∀ i : Fin (d + 1), ((x i : Fin (s + 1)) : ℕ) + ((x (i + 1) : Fin (s + 1)) : ℕ) ≤ s := by
  simp [cycSet]

/-! ### Index bookkeeping for the cyclic wrap-around -/

lemma castSucc_add_one {d : ℕ} (j : Fin d) : (j.castSucc + 1 : Fin (d + 1)) = j.succ := by
  refine Fin.ext ?_
  rw [Fin.val_add_one, if_neg]
  · rfl
  · intro h
    have := congrArg Fin.val h
    simp [Fin.last] at this
    omega

lemma zero_eq_castSucc_zero {d : ℕ} : (0 : Fin (d + 2)) = (0 : Fin (d + 1)).castSucc := rfl

lemma snoc_zero {s d : ℕ} (x : Fin (d + 1) → Fin (s + 1)) (v : Fin (s + 1)) :
    (Fin.snoc x v : Fin (d + 2) → Fin (s + 1)) 0 = x 0 := by
  simp [Fin.snoc]

lemma init_zero {s d : ℕ} (y : Fin (d + 2) → Fin (s + 1)) :
    Fin.init y (0 : Fin (d + 1)) = y 0 := by
  simp [Fin.init]

/-! ### The transfer-matrix bijections -/

/-- **Open transfer identity.**  The number of open adjacent-sum lattice points of
length `d + 1` with first coordinate `a` and last coordinate `b` equals the entry
`(adjMat s ^ d) a b`. -/
theorem card_pathSet (s d : ℕ) (a b : Fin (s + 1)) :
    (pathSet s d a b).card = (adjMat s ^ d) a b := by
  induction d generalizing b with
  | zero =>
      rw [pow_zero, Matrix.one_apply]
      by_cases hab : a = b
      · subst hab
        rw [if_pos rfl, Finset.card_eq_one]
        refine ⟨fun _ => a, ?_⟩
        ext x
        simp only [mem_pathSet, Finset.mem_singleton, IsEmpty.forall_iff, true_and, Fin.last_zero]
        constructor
        · rintro ⟨h1, -⟩
          funext i
          have hi : i = 0 := Fin.ext (by omega)
          rw [hi]; exact h1
        · rintro rfl; exact ⟨rfl, rfl⟩
      · rw [if_neg hab, Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
        intro x hx
        rw [mem_pathSet, Fin.last_zero] at hx
        exact hab (hx.2.1.symm.trans hx.2.2)
  | succ d ih =>
      rw [pow_succ, Matrix.mul_apply]
      rw [Finset.card_eq_sum_card_fiberwise (f := fun x => x (Fin.last d).castSucc)
          (t := Finset.univ) (fun x _ => Finset.mem_univ _)]
      refine Finset.sum_congr rfl (fun c _ => ?_)
      by_cases hcb : (c : ℕ) + (b : ℕ) ≤ s
      · rw [adjMat, if_pos hcb, mul_one, ← ih c]
        refine Finset.card_nbij' (fun x => Fin.init x) (fun y => Fin.snoc y b) ?_ ?_ ?_ ?_
        · intro x hx
          simp only [Finset.coe_filter, Set.mem_setOf_eq] at hx
          obtain ⟨hx1, hx2⟩ := hx
          rw [mem_pathSet] at hx1
          simp only [Finset.mem_coe, mem_pathSet]
          refine ⟨fun i => ?_, ?_, ?_⟩
          · have := hx1.1 i.castSucc
            rw [Fin.succ_castSucc] at this
            simpa [Fin.init] using this
          · simpa [Fin.init, Fin.castSucc_zero] using hx1.2.1
          · simpa [Fin.init] using hx2
        · intro y hy
          simp only [Finset.mem_coe, mem_pathSet] at hy
          simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_pathSet]
          refine ⟨⟨fun i => ?_, ?_, ?_⟩, ?_⟩
          · refine Fin.lastCases ?_ ?_ i
            · rw [Fin.succ_last]
              simp only [Fin.snoc_castSucc, Fin.snoc_last]
              rw [hy.2.2]; exact hcb
            · intro j
              rw [Fin.succ_castSucc]
              simp only [Fin.snoc_castSucc]
              exact hy.1 j
          · rw [← Fin.castSucc_zero, Fin.snoc_castSucc]; exact hy.2.1
          · exact Fin.snoc_last _ _
          · rw [Fin.snoc_castSucc]; exact hy.2.2
        · intro x hx
          simp only [Finset.coe_filter, Set.mem_setOf_eq] at hx
          obtain ⟨hx1, -⟩ := hx
          rw [mem_pathSet] at hx1
          rw [← hx1.2.2]
          exact Fin.snoc_init_self x
        · intro y _
          exact Fin.init_snoc _ _
      · rw [adjMat, if_neg hcb, mul_zero, Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
        intro x hx
        simp only [Finset.mem_filter, mem_pathSet] at hx
        obtain ⟨⟨h1, -, h3⟩, h2⟩ := hx
        have := h1 (Fin.last d)
        rw [Fin.succ_last, h3, h2] at this
        exact hcb this

/-- **Cyclic transfer identity.**  The number of cyclic adjacent-sum lattice points of
length `d + 1` equals `trace (adjMat s ^ (d+1))`. -/
theorem card_cycSet (s d : ℕ) :
    (cycSet s d).card = Matrix.trace (adjMat s ^ (d + 1)) := by
  rw [Matrix.trace]
  rw [Finset.card_eq_sum_card_fiberwise (f := fun x => x 0) (t := Finset.univ)
      (fun x _ => Finset.mem_univ _)]
  refine Finset.sum_congr rfl (fun a _ => ?_)
  rw [Matrix.diag_apply, ← card_pathSet s (d + 1) a a]
  refine Finset.card_nbij' (fun x => Fin.snoc x (x 0)) (fun y => Fin.init y) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_cycSet] at hx
    obtain ⟨hx1, hx2⟩ := hx
    simp only [Finset.mem_coe, mem_pathSet]
    refine ⟨fun i => ?_, ?_, ?_⟩
    · refine Fin.lastCases ?_ ?_ i
      · rw [Fin.succ_last]
        simp only [Fin.snoc_castSucc, Fin.snoc_last]
        have := hx1 (Fin.last d)
        rwa [Fin.last_add_one] at this
      · intro j
        rw [Fin.succ_castSucc]
        simp only [Fin.snoc_castSucc]
        have := hx1 j.castSucc
        rwa [castSucc_add_one] at this
    · rw [snoc_zero]; exact hx2
    · rw [Fin.snoc_last]; exact hx2
  · intro y hy
    simp only [Finset.mem_coe, mem_pathSet] at hy
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_cycSet]
    refine ⟨fun i => ?_, ?_⟩
    · refine Fin.lastCases ?_ ?_ i
      · rw [Fin.last_add_one]
        have := hy.1 (Fin.last d)
        rw [Fin.succ_last, hy.2.2, ← hy.2.1] at this
        rw [init_zero]
        simpa [Fin.init] using this
      · intro j
        rw [castSucc_add_one]
        have := hy.1 j.castSucc
        rw [Fin.succ_castSucc] at this
        simpa [Fin.init] using this
    · rw [init_zero]; exact hy.2.1
  · intro x _
    exact Fin.init_snoc _ _
  · intro y hy
    simp only [Finset.mem_coe, mem_pathSet] at hy
    show Fin.snoc (Fin.init y) (Fin.init y (0 : Fin (d + 1))) = y
    have h0 : Fin.init y (0 : Fin (d + 1)) = y (Fin.last (d + 1)) := by
      rw [init_zero, hy.2.2, ← hy.2.1]
    rw [h0]
    exact Fin.snoc_init_self y

/-- **Total open count.**  The number of open adjacent-sum lattice points of length
`d + 1` is the sum of all entries of `adjMat s ^ d`. -/
theorem card_openSet (s d : ℕ) :
    (openSet s d).card = ∑ a, ∑ b, (adjMat s ^ d) a b := by
  rw [Finset.card_eq_sum_card_fiberwise (f := fun x => (x 0, x (Fin.last d)))
      (t := Finset.univ) (fun x _ => Finset.mem_univ _)]
  rw [Fintype.sum_prod_type]
  refine Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun b _ => ?_))
  rw [← card_pathSet s d a b]
  congr 1
  ext x
  simp [pathSet, Finset.mem_filter, Prod.ext_iff]

/-- The endpoint-refined counts are symmetric in the two endpoints. -/
theorem card_pathSet_swap (s d : ℕ) (a b : Fin (s + 1)) :
    (pathSet s d a b).card = (pathSet s d b a).card := by
  rw [card_pathSet, card_pathSet]
  have h : ((adjMat s) ^ d).IsSymm := (adjMat_isSymm s).pow d
  conv_lhs => rw [← h]
  rfl

end AdjSum