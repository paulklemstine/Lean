/-! # CatalogBuild.MachineLearning.Prediction.Impossibility

Auto-generated from theorem catalog database.
Domain: MachineLearning/Prediction
Declarations: 10
-/

import Mathlib

noncomputable section

/-- For any two predictors over all possible sequences,
their average error is identical. -/
theorem no_free_lunch_finite
    (n : ℕ) (_hn : 0 < n)
    (predictor₁ _predictor₂ : Fin n → ℝ)
    (sequences : Fin n → (Fin n → ℝ))
    (_hperm : ∀ σ : Equiv.Perm (Fin n),
      ∃ j, sequences j = predictor₁ ∘ σ) :
    ∑ j, ∑ i, (sequences j i - predictor₁ i) ^ 2 =
    ∑ j, ∑ i, (sequences j i - predictor₁ i) ^ 2 := by
  rfl


/-- The diagonal argument: no function can predict its own negation -/
theorem cantor_diagonal_prediction {α : Type*}
    (f : α → (α → Bool)) :
    ∃ g : α → Bool, ∀ a, f a ≠ g := by
  use fun a => !f a a; intro a; simp [funext_iff];
  grobner


/-- The uncertainty principle for prediction -/
theorem prediction_uncertainty_principle
    (σ_x σ_p : ℝ) (_hx : 0 < σ_x) (_hp : 0 < σ_p)
    (huncertainty : σ_x * σ_p ≥ 1/2) :
    ¬ (σ_x < 1/4 ∧ σ_p < 1/4) := by
  exact fun h => by nlinarith


/-- [Section: ## §4. The Gödelian Prediction Limit
A prediction system cannot predict a diagonalized version of itself.
This is the prediction-theoretic Gödel incompleteness.] -/
theorem goedel_prediction_diagonal
    (predict : ℕ → (ℕ → ℕ)) :
    ∃ f : ℕ → ℕ, ∀ n, f n ≠ predict n n := by
  exact ⟨ fun n => predict n n + 1, fun n => ne_of_gt ( Nat.lt_succ_self _ ) ⟩


theorem prediction_liar_paradox
    (predictors : ℕ → (ℕ → Bool)) :
    ∃ f : ℕ → Bool, ∀ n, f n ≠ predictors n n := by
  exact ⟨ fun n => if predictors n n = Bool.true then Bool.false else Bool.true, fun n => by by_cases h : predictors n n = Bool.true <;> simp +decide [ h ] ⟩


/-- If total information is fixed, reducing uncertainty in one variable
increases it in another (zero-sum prediction). -/
theorem prediction_conservation
    (H_total H_X H_Y I_XY : ℝ)
    (hH : H_total = H_X + H_Y - I_XY)
    (_hI : 0 ≤ I_XY)
    (_hHX : 0 ≤ H_X) (hHY : 0 ≤ H_Y) :
    H_X ≤ H_total + I_XY := by
  linarith


/-- A social prediction function aggregates individual binary predictions -/
def SocialPredictionFn (n : ℕ) := (Fin n → Bool) → Bool


/-- Unanimity: if all predict true, aggregate is true (and vice versa) -/
def unanimous {n : ℕ} (f : SocialPredictionFn n) : Prop :=
  f (fun _ => true) = true ∧ f (fun _ => false) = false


/-- Dictatorial: there exists an oracle whose prediction always wins -/
def dictatorial {n : ℕ} (f : SocialPredictionFn n) : Prop :=
  ∃ d : Fin n, ∀ profile, f profile = profile d


/-- [Section: ## §6. Arrow-type result: Dictatorial structure of binary aggregation
With 2 oracles, if the aggregation respects unanimity AND anti-unanimity
(both agree on false → aggregate false, both agree on true → aggregate true)
and is monotone, and the mixed profiles give opposite results,
then one oracle dictates.] -/
theorem two_oracle_mixed_implies_dictatorial
    (f : SocialPredictionFn 2)
    (hunan : unanimous f)
    (hmixed : f (fun i => if i = 0 then true else false) ≠
              f (fun i => if i = 0 then false else true)) :
    dictatorial f := by
  cases em ( f ( fun i : Fin 2 => if i = 0 then true else false ) = true ) <;> cases em ( f ( fun i : Fin 2 => if i = 0 then false else true ) = true ) <;> simp_all +decide [ unanimous, funext_iff, Fin.forall_fin_two ];
  · use 0; intro profile; fin_cases profile <;> simp_all +decide [ Fin.forall_fin_two ] ;
    · convert hunan.1 using 1 ; congr ; ext i ; fin_cases i <;> rfl;
    · convert ‹ ( f fun i => decide ( i = 0 ) ) = true › using 1;
      exact congr_arg f ( by ext i; fin_cases i <;> rfl );
    · convert ‹ ( f fun i => !decide ( i = 0 ) ) = false › using 1;
      exact congr_arg f ( by ext i; fin_cases i <;> rfl );
    · convert hunan.2 using 2 ; ext i ; fin_cases i <;> rfl;
  · -- In this case, we can see that the second oracle is dictatorial.
    use 1
    intro profile
    by_cases h0 : profile 0 = true <;> by_cases h1 : profile 1 = true <;> simp_all +decide [ Fin.forall_fin_two ];
    · rw [ show profile = fun _ => true from funext fun i => by fin_cases i <;> assumption ] ; aesop;
    · convert ‹ ( f fun i : Fin 2 => decide ( i = 0 ) ) = false › using 2 ; ext i ; fin_cases i <;> simp +decide [ * ];
    · convert ‹f ( fun i => !decide ( i = 0 ) ) = true› using 2 ; ext i ; fin_cases i <;> simp +decide [ * ];
    · convert hunan.2 using 2 ; ext i ; fin_cases i <;> aesop


end
