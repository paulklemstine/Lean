/-! # CatalogBuild.Tropical.TropicalSchurGL3

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 21
-/

import Mathlib

noncomputable section

/-- The shifted weight λ + ρ where ρ = (2,1,0) is the Weyl vector for GL₃. -/
noncomputable def shiftedWeight3 (lam : Fin 3 → ℝ) : Fin 3 → ℝ :=
  ![lam 0 + 2, lam 1 + 1, lam 2]


/-- The tropical Schur polynomial for GL₃:
s_λ^trop(x₁,x₂,x₃) = min_{σ∈S₃} ⟨λ+ρ, σ(x)⟩
This is the spectral-side object in the tropical Satake correspondence.
It encodes tropical Hecke operator eigenvalues on the Bruhat-Tits building.
The six terms correspond to the six elements of the Weyl group W = S₃. -/
noncomputable def tropicalSchurGL3 (lam : Fin 3 → ℝ) (x : Fin 3 → ℝ) : ℝ :=
  let a := lam 0 + 2; let b := lam 1 + 1; let c := lam 2
  min (a * x 0 + b * x 1 + c * x 2)    -- id
  (min (a * x 0 + b * x 2 + c * x 1)   -- (23)
  (min (a * x 1 + b * x 0 + c * x 2)   -- (12)
  (min (a * x 1 + b * x 2 + c * x 0)   -- (123)
  (min (a * x 2 + b * x 0 + c * x 1)   -- (132)
       (a * x 2 + b * x 1 + c * x 0)))))  -- (13)


/-- [Section: ## Weyl Group Invariance] -/
theorem tropicalSchurGL3_swap01 (lam : Fin 3 → ℝ) (x : Fin 3 → ℝ) :
    tropicalSchurGL3 lam (![x 1, x 0, x 2]) = tropicalSchurGL3 lam x := by
  unfold tropicalSchurGL3;
  simp +zetaDelta at *;
  ac_rfl


theorem tropicalSchurGL3_swap12 (lam : Fin 3 → ℝ) (x : Fin 3 → ℝ) :
    tropicalSchurGL3 lam (![x 0, x 2, x 1]) = tropicalSchurGL3 lam x := by
  unfold tropicalSchurGL3; ring;
  simp +zetaDelta at *;
  grind


theorem tropicalSchurGL3_weyl_invariant (lam : Fin 3 → ℝ) (x : Fin 3 → ℝ)
    (σ : Equiv.Perm (Fin 3)) :
    tropicalSchurGL3 lam (x ∘ σ) = tropicalSchurGL3 lam x := by
  fin_cases σ <;> simp +decide [ tropicalSchurGL3 ] <;> ring!;
  · grind;
  · grind +qlia;
  · grind;
  · grind;
  · grind


/-- A coweight λ = (λ₁, λ₂, λ₃) is dominant if λ₁ ≥ λ₂ ≥ λ₃. -/
def isDominantGL3 (lam : Fin 3 → ℝ) : Prop :=
  lam 0 ≥ lam 1 ∧ lam 1 ≥ lam 2


/-- A point x is in the positive Weyl chamber if x₁ ≥ x₂ ≥ x₃. -/
def inWeylChamberGL3 (x : Fin 3 → ℝ) : Prop :=
  x 0 ≥ x 1 ∧ x 1 ≥ x 2


/-- [Section: ## Dominant Chamber Optimality] -/
theorem tropSchur_dominant_chamber (lam x : Fin 3 → ℝ)
    (hlam : isDominantGL3 lam) (hx : inWeylChamberGL3 x) :
    tropicalSchurGL3 lam x =
    (lam 0 + 2) * x 2 + (lam 1 + 1) * x 1 + lam 2 * x 0 := by
  unfold tropicalSchurGL3 isDominantGL3 inWeylChamberGL3 at *;
  rw [ min_eq_right ];
  · rw [ min_eq_right ];
    · rw [ min_eq_right ];
      · rw [ min_eq_right ];
        · rw [ min_eq_right ] ; nlinarith;
        · cases min_cases ( ( lam 0 + 2 ) * x 2 + ( lam 1 + 1 ) * x 0 + lam 2 * x 1 ) ( ( lam 0 + 2 ) * x 2 + ( lam 1 + 1 ) * x 1 + lam 2 * x 0 ) <;> nlinarith;
      · cases min_cases ( ( lam 0 + 2 ) * x 1 + ( lam 1 + 1 ) * x 2 + lam 2 * x 0 ) ( Min.min ( ( lam 0 + 2 ) * x 2 + ( lam 1 + 1 ) * x 0 + lam 2 * x 1 ) ( ( lam 0 + 2 ) * x 2 + ( lam 1 + 1 ) * x 1 + lam 2 * x 0 ) ) <;> cases min_cases ( ( lam 0 + 2 ) * x 2 + ( lam 1 + 1 ) * x 0 + lam 2 * x 1 ) ( ( lam 0 + 2 ) * x 2 + ( lam 1 + 1 ) * x 1 + lam 2 * x 0 ) <;> nlinarith;
    · rw [ min_le_iff ];
      exact Or.inr ( by rw [ min_le_iff ] ; exact Or.inl <| by nlinarith );
  · simp +zetaDelta at *;
    exact Or.inr <| Or.inl <| by nlinarith;


/-- [Section: ## Translation Equivariance] -/
theorem tropSatake_translation (lam : Fin 3 → ℝ) (x : Fin 3 → ℝ) (δ : ℝ) :
    tropicalSchurGL3 lam (fun i => x i + δ) =
    tropicalSchurGL3 lam x + (lam 0 + lam 1 + lam 2 + 3) * δ := by
  simp [tropicalSchurGL3];
  rw [ ← min_add_add_right ] ; ring;
  simp +decide only [← min_add_add_left] ; ring


/-- **The tropical Schur polynomial is bounded above by the identity
permutation value**. -/
theorem tropicalSchurGL3_le_id (lam x : Fin 3 → ℝ) :
    tropicalSchurGL3 lam x ≤
    (lam 0 + 2) * x 0 + (lam 1 + 1) * x 1 + lam 2 * x 2 := by
  unfold tropicalSchurGL3
  exact min_le_left _ _


/-- The **tropical Gindikin-Karpelevich c-function** for GL₃.
For each positive root α, c^trop(α, s) = min(0, ⟨α, s⟩).
For GL₃, the positive roots are e₁-e₂, e₂-e₃, e₁-e₃.
This function governs the asymptotic behavior of Macdonald-Whittaker
functions in the tropical limit. -/
noncomputable def tropGKcFunction (s : Fin 3 → ℝ) : ℝ :=
  min 0 (s 0 - s 1) + min 0 (s 1 - s 2) + min 0 (s 0 - s 2)


/-- [Section: ## Tropical Gindikin-Karpelevich Formula] -/
theorem tropGKcFunction_nonpos (s : Fin 3 → ℝ) :
    tropGKcFunction s ≤ 0 := by
  exact add_nonpos ( add_nonpos ( min_le_left _ _ ) ( min_le_left _ _ ) ) ( min_le_left _ _ )


theorem tropGKcFunction_zero_dominant (s : Fin 3 → ℝ)
    (hs : s 0 ≥ s 1 ∧ s 1 ≥ s 2) :
    tropGKcFunction s = 0 := by
  unfold tropGKcFunction; norm_num [ min_le_iff, hs ] ;
  linarith


/-- **Tropical Plancherel measure** on the unramified dual of GL₃.
This is the density appearing in the tropical Plancherel formula,
given by -(c^trop(s) + c^trop(-s)). -/
noncomputable def tropPlancherelGL3 (s : Fin 3 → ℝ) : ℝ :=
  -(tropGKcFunction s + tropGKcFunction (fun i => -s i))


/-- [Section: ## Tropical Plancherel Measure] -/
theorem tropPlancherelGL3_nonneg (s : Fin 3 → ℝ) :
    0 ≤ tropPlancherelGL3 s := by
  exact neg_nonneg_of_nonpos ( add_nonpos ( by unfold tropGKcFunction; cases min_cases ( 0:ℝ ) ( s 0 - s 1 ) <;> cases min_cases ( 0:ℝ ) ( s 1 - s 2 ) <;> cases min_cases ( 0:ℝ ) ( s 0 - s 2 ) <;> linarith ) ( by unfold tropGKcFunction; norm_num; cases min_cases ( 0:ℝ ) ( -s 0 + s 1 ) <;> cases min_cases ( 0:ℝ ) ( -s 1 + s 2 ) <;> cases min_cases ( 0:ℝ ) ( -s 0 + s 2 ) <;> linarith ) )


/-- The **GL₂ tropical Schur polynomial**: s_μ^trop(y₁,y₂) = min over S₂
of ⟨μ+ρ₂, σ(y)⟩ where ρ₂ = (1,0). -/
noncomputable def tropicalSchurGL2 (mu : Fin 2 → ℝ) (y : Fin 2 → ℝ) : ℝ :=
  min ((mu 0 + 1) * y 0 + mu 1 * y 1)
      ((mu 0 + 1) * y 1 + mu 1 * y 0)


/-- [Section: ## GL₂ Tropical Schur and Rank Reduction] -/
theorem tropicalSchurGL2_symm (mu : Fin 2 → ℝ) (y : Fin 2 → ℝ) :
    tropicalSchurGL2 mu (![y 1, y 0]) = tropicalSchurGL2 mu y := by
  exact min_comm _ _


theorem tropSchurGL2_dominant (mu : Fin 2 → ℝ) (y : Fin 2 → ℝ)
    (hmu : mu 0 ≥ mu 1) (hmu_nn : 0 ≤ mu 1) (hy : y 0 ≥ y 1) :
    tropicalSchurGL2 mu y = (mu 0 + 1) * y 1 + mu 1 * y 0 := by
  exact min_eq_right ( by nlinarith )


/-- [Section: ## Fundamental Weight Computations] -/
theorem tropSchur_fund_equal (t : ℝ) :
    tropicalSchurGL3 (![1, 0, 0]) (![t, t, t]) = 4 * t := by
  unfold tropicalSchurGL3; norm_num; ring;
  simp +zetaDelta at *;
  constructor <;> linarith


theorem tropSchur_equal_coords (lam : Fin 3 → ℝ) (t : ℝ) :
    tropicalSchurGL3 lam (![t, t, t]) =
    (lam 0 + lam 1 + lam 2 + 3) * t := by
  -- By the properties of the minimum function, we can simplify the expression.
  simp [tropicalSchurGL3];
  ring


/-- [Section: ## Tropical Spectral Bound for GL₃] -/
theorem tropSchur_spectral_bound (lam x : Fin 3 → ℝ)
    (hlam : ∀ i, 0 ≤ lam i) :
    tropicalSchurGL3 lam x ≤
    (lam 0 + lam 1 + lam 2 + 3) * (|x 0| ⊔ |x 1| ⊔ |x 2|) := by
  -- Each term in the minimum is bounded by $(\lambda_0 + 2)|x_0| + (\lambda_1 + 1)|x_1| + \lambda_2|x_2|$.
  have h_term_bound : ∀ σ : Equiv.Perm (Fin 3), (lam 0 + 2) * x (σ 0) + (lam 1 + 1) * x (σ 1) + lam 2 * x (σ 2) ≤ (lam 0 + lam 1 + lam 2 + 3) * max (max |x 0| |x 1|) |x 2| := by
    intro σ
    have h_abs : ∀ i, |x i| ≤ max (max |x 0| |x 1|) |x 2| := by
      exact fun i => by fin_cases i <;> simp +decide [ le_max_iff ] ;
    nlinarith [ abs_le.mp ( h_abs ( σ 0 ) ), abs_le.mp ( h_abs ( σ 1 ) ), abs_le.mp ( h_abs ( σ 2 ) ), hlam 0, hlam 1, hlam 2 ];
  unfold tropicalSchurGL3;
  simp +zetaDelta at *;
  exact Or.inl <| h_term_bound 1

end
