import Mathlib

/-! # CatalogBuild.Tropical.Core.NewResearch

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 23
-/

noncomputable section

/-- [Section: # CatalogBuild.Tropical.Core.NewResearch
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 23] -/
theorem tropPow_zero (a : ℝ) : tropPow a 0 = 0 := by simp [tropPow]

/-- [Section: # CatalogBuild.Tropical.Core.NewResearch
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 23] -/
theorem tropPow_one (a : ℝ) : tropPow a 1 = a := by simp [tropPow]

theorem tropPow_succ (a : ℝ) (n : ℕ) :
    tropPow a (n + 1) = tropPow a n + a := by
  simp [tropPow]; ring

theorem tropPow_add (a : ℝ) (m n : ℕ) :
    tropPow a (m + n) = tropPow a m + tropPow a n := by
  simp [tropPow]; ring

/-- ℝ with max has no absorbing element -/
theorem no_max_absorbing : ¬ ∃ e : ℝ, ∀ a : ℝ, max a e = a := by
  intro ⟨e, he⟩
  have h1 := he (e - 1)
  linarith [le_max_right (e - 1) e]

/-- Tropical polynomial evaluation: max_i (a_i + i * x) -/
def tropPolyEval {n : ℕ} [NeZero n] (coeffs : Fin n → ℝ) (x : ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty
    (fun i => coeffs i + (i : ℕ) * x)

/-- Tropical polynomial is bounded below by any single term -/
theorem tropPolyEval_ge_term {n : ℕ} [NeZero n] (coeffs : Fin n → ℝ)
    (x : ℝ) (j : Fin n) :
    coeffs j + (j : ℕ) * x ≤ tropPolyEval coeffs x := by
  exact Finset.le_sup' (fun i => coeffs i + (↑↑i : ℝ) * x) (Finset.mem_univ j)

/-- Tropical matrix type -/
abbrev TropMatrix (n : ℕ) := Fin n → Fin n → ℝ

/-- Entry-wise ordering -/
def tropMatLE {n : ℕ} (A B : TropMatrix n) : Prop := ∀ i j, A i j ≤ B i j

theorem tropMatMul_mono_left {n : ℕ} [NeZero n] (A A' B : TropMatrix n)
    (h : tropMatLE A A') : tropMatLE (tropMatMul A B) (tropMatMul A' B) := by
  intro i j;
  convert Finset.sup'_le _ _ _;
  exact fun k _ => le_trans ( add_le_add ( h i k ) le_rfl ) ( Finset.le_sup' ( fun k => A' i k + B k j ) ( Finset.mem_univ k ) )

theorem tropMatMul_mono_right {n : ℕ} [NeZero n] (A B B' : TropMatrix n)
    (h : tropMatLE B B') : tropMatLE (tropMatMul A B) (tropMatMul A B') := by
  -- By definition of tropical matrix multiplication, we need to show that for any i and j, the supremum of (A i k + B k j) is less than or equal to the supremum of (A i k + B' k j).
  intro i j
  apply le_trans (Finset.sup'_le _ _ _) (Finset.le_sup' _ _);
  have := Finset.exists_max_image Finset.univ ( fun k => A i k + B' k j ) ⟨ j, Finset.mem_univ j ⟩;
  exact this.choose;
  · exact Finset.mem_univ _;
  · grind +locals

theorem max_eq_relu_form (a b : ℝ) : max a b = a + relu (b - a) := by
  unfold relu; cases max_cases a b <;> cases max_cases ( b - a ) 0 <;> linarith;

/-- The decision boundary of a ReLU neuron -/
theorem relu_boundary (w b x : ℝ) :
    max (w * x + b) 0 = 0 ↔ w * x + b ≤ 0 :=
  max_eq_right_iff

/-- A tropical halfspace -/
def tropHalfspace (c : ℝ) : Set ℝ := {x | x ≥ c}

theorem tropHalfspace_convex (c : ℝ) : Convex ℝ (tropHalfspace c) := by
  exact convex_Ici c

/-- Tropical expectation: max_i (logP(i) + X(i)) -/
def tropExpectation {n : ℕ} [NeZero n] (logProb : Fin n → ℝ) (X : Fin n → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => logProb i + X i)

theorem tropExpectation_mono {n : ℕ} [NeZero n] (logProb : Fin n → ℝ)
    (X Y : Fin n → ℝ) (h : ∀ i, X i ≤ Y i) :
    tropExpectation logProb X ≤ tropExpectation logProb Y := by
  -- Since $X(i) \leq Y(i)$ for all $i$, adding $\logProb(i)$ to both sides preserves the inequality.
  have h_add : ∀ i, logProb i + X i ≤ logProb i + Y i := by
    grind;
  exact Finset.sup'_le _ _ fun i _ => le_trans ( h_add i ) ( Finset.le_sup' ( fun i => logProb i + Y i ) ( Finset.mem_univ i ) )

theorem tropExpectation_shift {n : ℕ} [NeZero n] (logProb : Fin n → ℝ)
    (X : Fin n → ℝ) (c : ℝ) :
    tropExpectation logProb (fun i => X i + c) = tropExpectation logProb X + c := by
  -- Let's simplify the expression inside the supremum.
  apply le_antisymm;
  · simp +decide [ tropExpectation ];
    exact fun i => by linarith [ Finset.le_sup' ( fun i => logProb i + X i ) ( Finset.mem_univ i ) ] ;
  · unfold tropExpectation;
    simp +decide [ ← add_assoc, Finset.sup'_le_iff ];
    simpa using Finset.exists_max_image Finset.univ ( fun i => logProb i + X i ) ⟨ ⟨ 0, NeZero.pos n ⟩, Finset.mem_univ _ ⟩

/-- Individual term bounded by tropical expectation -/
theorem tropExpectation_ge_term {n : ℕ} [NeZero n] (logProb : Fin n → ℝ)
    (X : Fin n → ℝ) (i : Fin n) :
    logProb i + X i ≤ tropExpectation logProb X := by
  exact Finset.le_sup' (fun i => logProb i + X i) (Finset.mem_univ i)

/-- Tropical variance -/
def tropVariance {n : ℕ} [NeZero n] (logProb : Fin n → ℝ) (X : Fin n → ℝ) : ℝ :=
  let μ := tropExpectation logProb X
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => logProb i + |X i - μ|)

/-- LogSumExp with temperature -/
def logSumExpTemp {n : ℕ} [NeZero n] (β : ℝ) (v : Fin n → ℝ) : ℝ :=
  (1 / β) * Real.log (∑ i, Real.exp (β * v i))

/-- At temperature 1, LogSumExp_β = LogSumExp -/
theorem logSumExpTemp_one {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
    logSumExpTemp 1 v = logSumExp v := by
  simp [logSumExpTemp, logSumExp]

theorem max_circuit_size (n : ℕ) (hn : 1 ≤ n) : n - 1 + 1 = n := by omega

end