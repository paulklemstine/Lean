/-! # CatalogBuild.Tropical.Langlands.Algorithmic

Auto-generated from theorem catalog database.
Domain: Tropical/Langlands
Declarations: 28
-/

import Mathlib

noncomputable section

def isSorted (n : ℕ) (x : Fin n → ℝ) : Prop :=
  ∀ i j : Fin n, i ≤ j → x i ≤ x j


theorem const_sorted (n : ℕ) (c : ℝ) : isSorted n (fun _ : Fin n => c) :=
  fun _ _ _ => le_refl _


theorem monotone_sorted (n : ℕ) (f : Fin n → ℝ) (hf : Monotone f) :
    isSorted n f :=
  fun _ _ h => hf h


def tropicalDet (n : ℕ) [NeZero n] (A : Fin n → Fin n → ℝ) : ℝ :=
  (Finset.univ : Finset (Equiv.Perm (Fin n))).inf'
    ⟨1, Finset.mem_univ _⟩
    (fun sigma => ∑ i : Fin n, A i (sigma i))


theorem tropicalDet_zero (n : ℕ) [NeZero n] :
    tropicalDet n (fun _ _ => (0 : ℝ)) = 0 := by
  -- By definition of tropical determinant, we know that
  simp [tropicalDet]


theorem tropicalDet_le_identity (n : ℕ) [NeZero n] (A : Fin n → Fin n → ℝ) :
    tropicalDet n A ≤ ∑ i : Fin n, A i i := by
  exact Finset.inf'_le _ ( Finset.mem_univ 1 ) |> le_trans <| by norm_num;


def minPlusConv (f g : ℤ → ℝ) (n : ℤ) : ℝ :=
  ⨅ k : ℤ, f k + g (n - k)


theorem minPlusConv_comm (f g : ℤ → ℝ) (n : ℤ) :
    minPlusConv f g n = minPlusConv g f n := by
  unfold minPlusConv;
  rw [ ← Equiv.iInf_comp ( Equiv.subLeft n ) ] ; simp +decide [ add_comm ]


def graphLFunction (n : ℕ) (G : WeightedGraph n) (s t : Fin n) (scale : ℝ) : ℝ :=
  G.weight s t * scale


theorem graphLFunction_linear (n : ℕ) (G : WeightedGraph n) (s t : Fin n) (a b : ℝ) :
    graphLFunction n G s t (a + b) =
    graphLFunction n G s t a + graphLFunction n G s t b := by
  simp [graphLFunction, mul_add]


theorem graphLFunction_zero (n : ℕ) (G : WeightedGraph n) (s t : Fin n) :
    graphLFunction n G s t 0 = 0 := by
  simp [graphLFunction]


structure YoungDiagram' where
  numRows : ℕ
  rowLengths : Fin numRows → ℕ
  sorted : ∀ i j : Fin numRows, i ≤ j → rowLengths i ≥ rowLengths j


def YoungDiagram'.size (Y : YoungDiagram') : ℕ :=
  ∑ i : Fin Y.numRows, Y.rowLengths i


def emptyYoung : YoungDiagram' where
  numRows := 0
  rowLengths := Fin.elim0
  sorted := fun i => Fin.elim0 i


theorem emptyYoung_size : emptyYoung.size = 0 := by
  simp [YoungDiagram'.size, emptyYoung]


def singleRowYoung (k : ℕ) : YoungDiagram' where
  numRows := 1
  rowLengths := ![k]
  sorted := by intro i j _; simp [Fin.eq_zero i, Fin.eq_zero j]


theorem singleRowYoung_size (k : ℕ) : (singleRowYoung k).size = k := by
  simp [YoungDiagram'.size, singleRowYoung, Fin.sum_univ_one]


def sortingBound (n : ℕ) : ℕ := n * (Nat.log 2 n + 1)


theorem sortingBound_ge (n : ℕ) : sortingBound n ≥ n := by
  exact Nat.le_mul_of_pos_right _ ( Nat.succ_pos _ )


def assignmentComplexity (n : ℕ) : ℕ := n ^ 3


theorem assignment_ge_quadratic (n : ℕ) (hn : n ≥ 1) :
    assignmentComplexity n ≥ n ^ 2 := by
  exact Nat.pow_le_pow_right hn ( by decide )


def hookLength (arm leg : ℕ) : ℕ := arm + leg + 1


theorem hookLength_pos (arm leg : ℕ) : hookLength arm leg ≥ 1 := by
  unfold hookLength; omega


def minPlusIdentity (n : ℕ) (bigVal : ℝ) : Fin n → Fin n → ℝ :=
  fun i j => if i = j then 0 else bigVal


theorem minPlusIdentity_diag (n : ℕ) (M : ℝ) (i : Fin n) :
    minPlusIdentity n M i i = 0 := by
  simp [minPlusIdentity]


theorem minPlusIdentity_off_diag (n : ℕ) (M : ℝ) (i j : Fin n) (h : i ≠ j) :
    minPlusIdentity n M i j = M := by
  simp [minPlusIdentity, h]


def bellmanFordStep (n : ℕ) (hn : 0 < n) (G : WeightedGraph n) (dist : Fin n → ℝ) : Fin n → ℝ :=
  fun v => min (dist v) ((Finset.univ : Finset (Fin n)).inf'
    ⟨⟨0, hn⟩, Finset.mem_univ _⟩
    (fun u => dist u + G.weight u v))


theorem bellmanFord_monotone (n : ℕ) (hn : 0 < n) (G : WeightedGraph n)
    (dist : Fin n → ℝ) (v : Fin n) :
    bellmanFordStep n hn G dist v ≤ dist v := by
  exact min_le_left _ _


end
