import Mathlib

/-! # CatalogBuild.Computation.Oracles.SymmetryPrinciples

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 6
-/


/-- [Section: # CatalogBuild.Computation.Oracles.SymmetryPrinciples
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 6] -/
theorem am_gm_two_nat (a b : ℕ) : (a + b) ^ 2 ≥ 4 * (a * b) := by
  linarith [ sq_nonneg ( a - b : ℤ ) ]




/-- [Section: # CatalogBuild.Computation.Oracles.SymmetryPrinciples
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 6] -/
theorem cauchy_schwarz_discrete (n : ℕ) (a b : ℕ → ℤ) :
    (∑ i ∈ range n, a i * b i) ^ 2 ≤
    (∑ i ∈ range n, a i ^ 2) * (∑ i ∈ range n, b i ^ 2) := by
      exact?




theorem am_ge_gm (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) :
    (a + b) ^ 2 ≥ 4 * (a * b) := by
      linarith [ sq_nonneg ( a - b ) ]




theorem schur_ineq (a b c : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (hc : 0 ≤ c) :
    a * (a - b) * (a - c) + b * (b - a) * (b - c) + c * (c - a) * (c - b) ≥ 0 := by
      cases le_total a b <;> cases le_total a c <;> cases le_total b c <;> nlinarith [ sq_nonneg ( a - b ), sq_nonneg ( a - c ), sq_nonneg ( b - c ) ]




theorem sum_degrees_even (n : ℕ) (R : Fin n → Fin n → Prop) [DecidableRel R]
    (hsymm : ∀ i j, R i j → R j i) (hirrefl : ∀ i, ¬R i i) :
    2 ∣ ((univ : Finset (Fin n × Fin n)).filter fun p => R p.1 p.2).card := by
      -- Consider the set of pairs (i, j) with i ≠ j such that R(i, j) holds. This set can be partitioned into pairs (i, j) and (j, i).
      set S := Finset.filter (fun p => R p.1 p.2 ∧ p.1 ≠ p.2) (Finset.univ : Finset (Fin n × Fin n))
      have hS_even : 2 ∣ Finset.card S := by
        have hS_even : ∃ T : Finset (Fin n × Fin n), S = T ∪ Finset.image (fun p => (p.2, p.1)) T ∧ Disjoint T (Finset.image (fun p => (p.2, p.1)) T) := by
          use Finset.filter (fun p => R p.1 p.2 ∧ p.1 < p.2) (Finset.univ : Finset (Fin n × Fin n));
          norm_num [ Finset.ext_iff, Finset.disjoint_right ];
          grind;
        obtain ⟨ T, hT₁, hT₂ ⟩ := hS_even; rw [ hT₁, Finset.card_union_of_disjoint hT₂ ] ; simp +arith +decide [ Finset.card_image_of_injective, Function.Injective ] ;
        exact ⟨ T.card, by ring ⟩;
      convert hS_even using 2 ; ext ; aesop




theorem pigeonhole_simple (n : ℕ) (f : Fin (n + 2) → Fin (n + 1)) :
    ∃ i j, i ≠ j ∧ f i = f j := by
      by_contra! h;
      exact absurd ( Fintype.card_le_of_injective f fun i j hij => not_imp_not.mp ( h i j ) hij ) ( by simp +arith +decide )