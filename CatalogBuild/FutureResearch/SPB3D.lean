/-! # CatalogBuild.FutureResearch.SPB3D

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 12
-/

import Mathlib

noncomputable section

def dot3 (u v : Fin 3 → ℝ) : ℝ := ∑ i, u i * v i


def cross3 (u v : Fin 3 → ℝ) : Fin 3 → ℝ := fun i =>
  match i with
  | 0 => u 1 * v 2 - u 2 * v 1
  | 1 => u 2 * v 0 - u 0 * v 2
  | 2 => u 0 * v 1 - u 1 * v 0


def spb3 (u v : Fin 3 → ℝ) : Fin 3 → ℝ := fun i =>
  (u i + v i + cross3 u v i) / (1 - dot3 u v)


theorem spb3_zero_right (u : Fin 3 → ℝ) : spb3 u 0 = u := by
  ext i; simp [spb3, dot3, Fin.sum_univ_three]
  fin_cases i <;> simp [cross3]


theorem spb3_zero_left (v : Fin 3 → ℝ) : spb3 0 v = v := by
  ext i; simp [spb3, dot3, Fin.sum_univ_three]
  fin_cases i <;> simp [cross3]


theorem cross3_anti (u v : Fin 3 → ℝ) (i : Fin 3) :
    cross3 u v i = -cross3 v u i := by
  fin_cases i <;> simp [cross3] <;> ring


theorem dot3_comm (u v : Fin 3 → ℝ) : dot3 u v = dot3 v u := by
  simp [dot3, Fin.sum_univ_three]; ring


theorem spb3_noncomm :
    ∃ u v : Fin 3 → ℝ, spb3 u v ≠ spb3 v u := by
  use ![0, 1, 2];
  use ![1, 0, 3];
  unfold spb3;
  norm_num [ funext_iff, Fin.forall_fin_succ ];
  unfold cross3 dot3; norm_num;
  norm_num [ Fin.sum_univ_succ ]


theorem thomas_wigner_rotation (u v : Fin 3 → ℝ) (h : 1 - dot3 u v ≠ 0) (i : Fin 3) :
    spb3 u v i - spb3 v u i = 2 * cross3 u v i / (1 - dot3 u v) := by
  unfold spb3 cross3 dot3;
  rw [ ← Finset.sum_congr rfl fun i hi => mul_comm ( v i ) _ ] ; fin_cases i <;> norm_num <;> ring;


theorem cross3_neg_self (u : Fin 3 → ℝ) (i : Fin 3) :
    cross3 u (-u) i = 0 := by
  fin_cases i <;> simp [cross3] <;> ring


theorem dot3_neg (u : Fin 3 → ℝ) :
    dot3 u (-u) = -dot3 u u := by
  simp [dot3, Fin.sum_univ_three, mul_neg]


theorem spb3_neg_right (u : Fin 3 → ℝ) : spb3 u (-u) = 0 := by
  ext i; norm_num [ spb3 ] ; ring;
  exact Or.inl ( cross3_neg_self u i )


end
