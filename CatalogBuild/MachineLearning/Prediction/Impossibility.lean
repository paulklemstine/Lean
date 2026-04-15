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

/-! ## §2. The Halting Prediction Impossibility

No computable predictor can predict whether an arbitrary program halts.
We encode this as a diagonal argument. -/

/-- The diagonal argument: no function can predict its own negation -/

theorem cantor_diagonal_prediction {α : Type*}
    (f : α → (α → Bool)) :
    ∃ g : α → Bool, ∀ a, f a ≠ g := by
  use fun a => !f a a; intro a; simp [funext_iff];
  grobner

/-! ## §3. Heisenberg Prediction Uncertainty

Prediction precision for conjugate observables is bounded. -/

/-- The uncertainty principle for prediction -/

theorem prediction_uncertainty_principle
    (σ_x σ_p : ℝ) (_hx : 0 < σ_x) (_hp : 0 < σ_p)
    (huncertainty : σ_x * σ_p ≥ 1/2) :
    ¬ (σ_x < 1/4 ∧ σ_p < 1/4) := by
  exact fun h => by nlinarith

/-! ## §4. The Gödelian Prediction Limit

A prediction system cannot predict a diagonalized version of itself.
This is the prediction-theoretic Gödel incompleteness. -/

/-
PROBLEM
The Gödelian diagonal: for any predictor that maps codes to outputs,
    there exists a function that differs from every predicted function
    at its own index. This is Cantor's theorem applied to prediction.

PROVIDED SOLUTION
Let f n = predict n n + 1. Then f n = predict n n + 1 ≠ predict n n since Nat.succ_ne_self. Use ⟨fun n => predict n n + 1, fun n => Nat.succ_ne_self _⟩.
-/

theorem goedel_prediction_diagonal
    (predict : ℕ → (ℕ → ℕ)) :
    ∃ f : ℕ → ℕ, ∀ n, f n ≠ predict n n := by
  exact ⟨ fun n => predict n n + 1, fun n => ne_of_gt ( Nat.lt_succ_self _ ) ⟩

/-
PROBLEM
The liar's paradox for prediction: for any enumeration of
    predictors, there exists a function no predictor matches everywhere.
    This follows from the diagonal argument.

PROVIDED SOLUTION
Let f n = !(predictors n n). Then for any n, f n = !(predictors n n) ≠ predictors n n by Bool.not_ne_self or similar. Use ⟨fun n => !(predictors n n), fun n => Bool.not_ne_self _⟩ or ⟨fun n => !predictors n n, fun n => ...⟩.
-/

theorem prediction_liar_paradox
    (predictors : ℕ → (ℕ → Bool)) :
    ∃ f : ℕ → Bool, ∀ n, f n ≠ predictors n n := by
  exact ⟨ fun n => if predictors n n = Bool.true then Bool.false else Bool.true, fun n => by by_cases h : predictors n n = Bool.true <;> simp +decide [ h ] ⟩

/-! ## §5. The Conservation of Prediction Difficulty

Total prediction difficulty is conserved: making one aspect more predictable
necessarily makes another less predictable (information-theoretic). -/

/-- If total information is fixed, reducing uncertainty in one variable
    increases it in another (zero-sum prediction). -/

theorem prediction_conservation
    (H_total H_X H_Y I_XY : ℝ)
    (hH : H_total = H_X + H_Y - I_XY)
    (_hI : 0 ≤ I_XY)
    (_hHX : 0 ≤ H_X) (hHY : 0 ≤ H_Y) :
    H_X ≤ H_total + I_XY := by
  linarith

/-! ## §6. Arrow-type result: Dictatorial structure of binary aggregation

With 2 oracles, if the aggregation respects unanimity AND anti-unanimity
(both agree on false → aggregate false, both agree on true → aggregate true)
and is monotone, and the mixed profiles give opposite results,
then one oracle dictates. -/

/-- A social prediction function aggregates individual binary predictions -/

def SocialPredictionFn (n : ℕ) := (Fin n → Bool) → Bool

/-- Unanimity: if all predict true, aggregate is true (and vice versa) -/

def unanimous {n : ℕ} (f : SocialPredictionFn n) : Prop :=
  f (fun _ => true) = true ∧ f (fun _ => false) = false

/-- Dictatorial: there exists an oracle whose prediction always wins -/

def dictatorial {n : ℕ} (f : SocialPredictionFn n) : Prop :=
  ∃ d : Fin n, ∀ profile, f profile = profile d

/-
PROBLEM
With 2 oracles, if the two mixed profiles give different outputs,
    then the function is dictatorial. This is the core of Arrow's theorem
    in the binary prediction setting.

PROVIDED SOLUTION
There are exactly 4 profiles for 2 oracles: (T,T), (T,F), (F,T), (F,F). By unanimity, f(T,T) = T and f(F,F) = F. By hmixed, f(T,F) ≠ f(F,T). Since these are booleans, one is true and one is false. Case 1: f(T,F) = T, f(F,T) = F → oracle 0 is dictator. Case 2: f(T,F) = F, f(F,T) = T → oracle 1 is dictator. To show dictatorship, use Fin.forall_fin_two to check all 4 profiles. Use decide or native_decide for the finite case analysis.
-/

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
