/-! # CatalogBuild.Tropical.TropicalMatrix

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 16
-/

import Mathlib

noncomputable section

/-- A 2×2 tropical matrix with entries in `WithTop ℕ`. -/
structure TropMat2 where
  a₁₁ : WithTop ℕ
  a₁₂ : WithTop ℕ
  a₂₁ : WithTop ℕ
  a₂₂ : WithTop ℕ
  deriving Repr, DecidableEq


/-- Tropical matrix multiplication for 2×2 matrices.
`(AB)ᵢⱼ = min_k(Aᵢₖ + Bₖⱼ)`, which in tropical notation is
`⊕_k (Aᵢₖ ⊙ Bₖⱼ)`.
This corresponds to the shortest path interpretation: if A and B
are adjacency matrices of weighted digraphs, then AB gives the
shortest 2-step paths. -/
noncomputable def TropMat2.mul (A B : TropMat2) : TropMat2 :=
  { a₁₁ := min (A.a₁₁ + B.a₁₁) (A.a₁₂ + B.a₂₁)
    a₁₂ := min (A.a₁₁ + B.a₁₂) (A.a₁₂ + B.a₂₂)
    a₂₁ := min (A.a₂₁ + B.a₁₁) (A.a₂₂ + B.a₂₁)
    a₂₂ := min (A.a₂₁ + B.a₁₂) (A.a₂₂ + B.a₂₂) }


/-- The tropical identity matrix: diagonal entries are 0 (= tropical 1),
off-diagonal entries are ⊤ (= tropical 0 = ∞). -/
def TropMat2.tropId : TropMat2 :=
  { a₁₁ := 0, a₁₂ := ⊤, a₂₁ := ⊤, a₂₂ := 0 }


/-- A diagonal tropical matrix. -/
def TropMat2.diag (d₁ d₂ : WithTop ℕ) : TropMat2 :=
  { a₁₁ := d₁, a₁₂ := ⊤, a₂₁ := ⊤, a₂₂ := d₂ }


/-- The tropical determinant of a 2×2 matrix:
`tdet(A) = min(a₁₁ + a₂₂, a₁₂ + a₂₁)`.
This is the minimum weight perfect matching in the bipartite graph. -/
noncomputable def TropMat2.det (A : TropMat2) : WithTop ℕ :=
  min (A.a₁₁ + A.a₂₂) (A.a₁₂ + A.a₂₁)


/-- The tropical trace: `ttr(A) = min(a₁₁, a₂₂)`.
This is the minimum diagonal entry = shortest self-loop. -/
noncomputable def TropMat2.tr (A : TropMat2) : WithTop ℕ :=
  min A.a₁₁ A.a₂₂


/-- [Section: ## Section 2: Properties of Tropical Matrix Multiplication] -/
theorem tropMat2_id_mul (A : TropMat2) :
    TropMat2.mul TropMat2.tropId A = A := by
      unfold TropMat2.tropId TropMat2.mul;
      cases A ; aesop


theorem tropMat2_mul_id (A : TropMat2) :
    TropMat2.mul A TropMat2.tropId = A := by
      cases A ; unfold TropMat2.mul TropMat2.tropId ; aesop


theorem tropMat2_mul_assoc (A B C : TropMat2) :
    TropMat2.mul (TropMat2.mul A B) C = TropMat2.mul A (TropMat2.mul B C) := by
      cases A ; cases B ; cases C ; simp +decide [ TropMat2.mul ];
      simp_all +decide [ ← min_add_add_left, ← min_add_add_right, add_comm, add_left_comm, add_assoc ] ;
      grind


/-- The tropical determinant of the identity matrix is 0 (= tropical 1). -/
theorem tropMat2_det_id :
    TropMat2.det TropMat2.tropId = 0 := by
  simp [TropMat2.det, TropMat2.tropId]


/-- The tropical determinant of a diagonal matrix is the sum of
diagonal entries (= tropical product of eigenvalues). -/
theorem tropMat2_det_diag (d₁ d₂ : WithTop ℕ) :
    TropMat2.det (TropMat2.diag d₁ d₂) = d₁ + d₂ := by
  simp [TropMat2.det, TropMat2.diag, min_eq_left (le_top)]


/-- [Section: ## Section 3: Tropical Determinant Properties] -/
theorem tropMat2_diag_mul (d₁ d₂ e₁ e₂ : WithTop ℕ) :
    TropMat2.mul (TropMat2.diag d₁ d₂) (TropMat2.diag e₁ e₂) =
    TropMat2.diag (d₁ + e₁) (d₂ + e₂) := by
      cases d₁ <;> cases e₁ <;> simp +decide [ TropMat2.mul, TropMat2.diag ]


theorem tropMat2_det_mul_diag (d₁ d₂ e₁ e₂ : WithTop ℕ) :
    TropMat2.det (TropMat2.mul (TropMat2.diag d₁ d₂) (TropMat2.diag e₁ e₂)) =
    TropMat2.det (TropMat2.diag d₁ d₂) + TropMat2.det (TropMat2.diag e₁ e₂) := by
      unfold TropMat2.det;
      cases d₁ <;> cases d₂ <;> simp +decide [ TropMat2.mul, TropMat2.diag ] at *;
      cases e₁ <;> cases e₂ <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ]


/-- [Section: ## Section 4: Trace-Determinant Inequality
The tropical trace-determinant inequality is the tropical analog of
the AM-GM inequality: for a 2×2 tropical matrix, the trace
(minimum diagonal entry) is ≤ half the determinant.
In the Langlands context, this constrains the Satake parameters:
the "tropical eigenvalues" (trace contributions) are bounded by
the "tropical Hecke eigenvalue" (determinant).] -/
theorem tropical_trace_eq_det_diag (d₁ d₂ : WithTop ℕ) :
    (TropMat2.diag d₁ d₂).tr ≤ (TropMat2.diag d₁ d₂).det := by
      cases d₁ <;> cases d₂ <;> simp +decide [ TropMat2.tr, TropMat2.det, TropMat2.diag ]


/-- **Shortest path interpretation**: The entry (1,1) of the tropical
matrix square gives the shortest 2-step closed walk from vertex 1
back to vertex 1. This is `min(a₁₁ + a₁₁, a₁₂ + a₂₁)`. -/
theorem tropical_shortest_path_two_step (A : TropMat2) :
    (TropMat2.mul A A).a₁₁ = min (A.a₁₁ + A.a₁₁) (A.a₁₂ + A.a₂₁) := by
  simp [TropMat2.mul]


/-- The trace of the tropical matrix square gives the length of the
shortest 2-step closed walk in the graph. -/
theorem tropical_shortest_closed_walk_2 (A : TropMat2) :
    (TropMat2.mul A A).tr =
    min (min (A.a₁₁ + A.a₁₁) (A.a₁₂ + A.a₂₁))
        (min (A.a₂₁ + A.a₁₂) (A.a₂₂ + A.a₂₂)) := by
  simp [TropMat2.mul, TropMat2.tr]


end
