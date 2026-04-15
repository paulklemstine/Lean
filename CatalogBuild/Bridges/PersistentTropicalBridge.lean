/-! # CatalogBuild.Bridges.PersistentTropicalBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 20
-/

import Mathlib

noncomputable section

/-- A trivial interval has zero lifetime. -/
theorem PersistenceInterval.trivial_lifetime (b : ℝ) :
    (⟨b, b, le_refl b⟩ : PersistenceInterval).lifetime = 0 := sub_self b


/-- The L∞ distance between two persistence points.
d∞((b₁,d₁), (b₂,d₂)) = max(|b₁-b₂|, |d₁-d₂|). -/
def bottleneckPointDist (I J : PersistenceInterval) : ℝ :=
  max (|I.birth - J.birth|) (|I.death - J.death|)


/-- The bottleneck distance is symmetric. -/
theorem bottleneckPointDist_comm (I J : PersistenceInterval) :
    bottleneckPointDist I J = bottleneckPointDist J I := by
  simp [bottleneckPointDist, abs_sub_comm]


/-- The bottleneck distance is non-negative. -/
theorem bottleneckPointDist_nonneg (I J : PersistenceInterval) :
    0 ≤ bottleneckPointDist I J :=
  le_max_of_le_left (abs_nonneg _)


/-- [Section: ## Part 2: The Bottleneck Distance (L∞ = Tropical Metric)] -/
theorem bottleneckPointDist_eq_zero_iff (I J : PersistenceInterval) :
    bottleneckPointDist I J = 0 ↔ I.birth = J.birth ∧ I.death = J.death := by
  unfold bottleneckPointDist;
  exact ⟨ fun h => ⟨ sub_eq_zero.mp ( abs_eq_zero.mp ( le_antisymm ( le_trans ( le_max_left _ _ ) h.le ) ( abs_nonneg _ ) ) ), sub_eq_zero.mp ( abs_eq_zero.mp ( le_antisymm ( le_trans ( le_max_right _ _ ) h.le ) ( abs_nonneg _ ) ) ) ⟩, fun h => by norm_num [ h ] ⟩


theorem bottleneckPointDist_triangle (I J K : PersistenceInterval) :
    bottleneckPointDist I K ≤ bottleneckPointDist I J + bottleneckPointDist J K := by
  unfold bottleneckPointDist;
  exact max_le_iff.mpr ⟨ by cases max_cases |I.birth - J.birth| |I.death - J.death| <;> cases max_cases |J.birth - K.birth| |J.death - K.death| <;> linarith [ abs_sub_le I.birth J.birth K.birth, abs_sub_le I.death J.death K.death ], by cases max_cases |I.birth - J.birth| |I.death - J.death| <;> cases max_cases |J.birth - K.birth| |J.death - K.death| <;> linarith [ abs_sub_le I.birth J.birth K.birth, abs_sub_le I.death J.death K.death ] ⟩


/-- Persistence stability for single intervals. -/
theorem persistence_stability_single (b₁ d₁ b₂ d₂ ε : ℝ)
    (hv1 : b₁ ≤ d₁) (hv2 : b₂ ≤ d₂)
    (hb : |b₁ - b₂| ≤ ε) (hd : |d₁ - d₂| ≤ ε) :
    bottleneckPointDist ⟨b₁, d₁, hv1⟩ ⟨b₂, d₂, hv2⟩ ≤ ε := by
  simp [bottleneckPointDist]; exact ⟨hb, hd⟩


/-- [Section: ## Part 3: Stability Theorem (Tropical Lipschitz)] -/
theorem lifetime_lipschitz (I J : PersistenceInterval) :
    |I.lifetime - J.lifetime| ≤ 2 * bottleneckPointDist I J := by
  unfold bottleneckPointDist;
  rw [ two_mul, PersistenceInterval.lifetime, PersistenceInterval.lifetime ];
  cases max_cases |I.birth - J.birth| |I.death - J.death| <;> cases abs_cases ( I.death - I.birth - ( J.death - J.birth ) ) <;> cases abs_cases ( I.birth - J.birth ) <;> cases abs_cases ( I.death - J.death ) <;> linarith


/-- A tropical monomial. -/
structure TropicalMonomial where
  coefficient : ℝ
  degree : ℕ


/-- Tropical polynomial evaluation: p(x) = max_i (aᵢ + nᵢ · x). -/
def tropicalEval (monomials : List TropicalMonomial) (x : ℝ) : ℝ :=
  match monomials with
  | [] => 0
  | [m] => m.coefficient + m.degree * x
  | m :: rest => max (m.coefficient + m.degree * x) (tropicalEval rest x)


/-- A single tropical monomial is linear. -/
theorem tropical_monomial_linear (a : ℝ) (n : ℕ) (x : ℝ) :
    tropicalEval [⟨a, n⟩] x = a + n * x := by simp [tropicalEval]


/-- Two monomials: tropical polynomial = max. -/
theorem tropical_union_is_max (a₁ a₂ : ℝ) (n₁ n₂ : ℕ) (x : ℝ) :
    tropicalEval [⟨a₁, n₁⟩, ⟨a₂, n₂⟩] x =
    max (a₁ + n₁ * x) (a₂ + n₂ * x) := by simp [tropicalEval]


/-- Diagonal distance = half lifetime. -/
theorem diagonalDist_eq_half_lifetime (I : PersistenceInterval) :
    diagonalDist I = I.lifetime / 2 := rfl


/-- Diagonal distance is non-negative. -/
theorem diagonalDist_nonneg (I : PersistenceInterval) :
    0 ≤ diagonalDist I := div_nonneg (sub_nonneg.mpr I.valid) (by positivity)


/-- The projection onto the diagonal. -/
def diagonalProjection (I : PersistenceInterval) : PersistenceInterval where
  birth := (I.birth + I.death) / 2
  death := (I.birth + I.death) / 2
  valid := le_refl _


/-- The diagonal projection has zero lifetime. -/
theorem diagonal_projection_trivial (I : PersistenceInterval) :
    (diagonalProjection I).lifetime = 0 := by
  simp [diagonalProjection, PersistenceInterval.lifetime]


/-- [Section: ## Part 5: Diagonal Projection] -/
theorem projection_distance (I : PersistenceInterval) :
    bottleneckPointDist I (diagonalProjection I) = diagonalDist I := by
  unfold bottleneckPointDist diagonalDist;
  rw [ max_eq_right ] <;> norm_num [ diagonalProjection ];
  · rw [ abs_of_nonneg ] <;> linarith [ I.valid ];
  · cases abs_cases ( I.birth - ( I.birth + I.death ) / 2 ) <;> cases abs_cases ( I.death - ( I.birth + I.death ) / 2 ) <;> linarith [ I.valid ]


/-- Significance of a loss landscape feature = its persistence. -/
def significance (f : PersistenceInterval) : ℝ := f.lifetime


/-- More persistent features are more significant. -/
theorem significance_monotone (I J : PersistenceInterval)
    (hb : I.birth = J.birth) (hd : I.death ≤ J.death) :
    significance I ≤ significance J := by
  simp [significance, PersistenceInterval.lifetime, hb]; linarith


/-- [Section: ## Part 6: TDA–Neural Network Bridge] -/
theorem topological_simplification_bound (I : PersistenceInterval) (ε : ℝ)
    (hε : 0 < ε) (hsmall : I.lifetime < ε) :
    bottleneckPointDist I (diagonalProjection I) < ε := by
  rw [PersistentTropicalBridge.projection_distance];
  linarith [PersistentTropicalBridge.diagonalDist_eq_half_lifetime I]


end
