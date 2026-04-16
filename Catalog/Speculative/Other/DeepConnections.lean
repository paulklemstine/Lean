/-! # CatalogBuild.Speculative.Other.DeepConnections

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 12
-/

import Mathlib

noncomputable section

/-- Chebyshev polynomial of the first kind, defined by recurrence -/
noncomputable def chebyT : ℕ → Polynomial ℤ
  | 0 => 1
  | 1 => Polynomial.X
  | (n + 2) => 2 * Polynomial.X * chebyT (n + 1) - chebyT n



/-- **THEOREM 17**: T₀ = 1 -/
theorem chebyT_zero : chebyT 0 = 1 := by rfl



/-- **THEOREM 18**: T₁ = X -/
theorem chebyT_one : chebyT 1 = Polynomial.X := by rfl



/-- [Section: # CatalogBuild.Speculative.Other.DeepConnections
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 12] -/
theorem chebyT_degree (n : ℕ) (hn : 1 ≤ n) :
    (chebyT n).natDegree = n := by
      induction' n using Nat.strong_induction_on with n ih; rcases n with _|_|n; simp_all +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] ;
      · exact Polynomial.natDegree_X;
      · erw [ show chebyT ( n + 2 ) = 2 * Polynomial.X * chebyT ( n + 1 ) - chebyT n from rfl ] ; erw [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] <;> erw [ Polynomial.natDegree_mul' ] <;> norm_num [ ih ] ; ring_nf ;
        · exact ne_of_apply_ne Polynomial.natDegree ( by erw [ ih _ ( Nat.lt_succ_self _ ) ( Nat.succ_pos _ ) ] ; norm_num );
        · by_cases hn : 1 ≤ n <;> simp_all +arith +decide [ Polynomial.natDegree_sub_eq_left_of_natDegree_lt ];
          erw [ chebyT_zero ] ; norm_num;
        · exact ne_of_apply_ne Polynomial.natDegree ( by erw [ ih _ ( Nat.lt_succ_self _ ) ( Nat.succ_pos _ ) ] ; norm_num )



theorem chebyT_comp (m n : ℕ) :
    (chebyT m).comp (chebyT n) = chebyT (m * n) := by
      -- By definition of Chebyshev polynomials, we know that $T_{m}(T_{n}(x))$ satisfies the same recurrence relation as $T_{mn}(x)$.
      have h_recurrence : ∀ m n : ℕ, (chebyT (m * n)).comp (Polynomial.X) = (chebyT m).comp (chebyT n) := by
        intro m n;
        -- By definition of Chebyshev polynomials, we know that $T_{m}(T_{n}(x))$ satisfies the same recurrence relation as $T_{mn}(x)$ and the same initial conditions.
        have h_recurrence : ∀ m n : ℕ, ∀ x : ℝ, -1 ≤ x ∧ x ≤ 1 → (chebyT (m * n)).eval₂ (algebraMap ℤ ℝ) x = (chebyT m).eval₂ (algebraMap ℤ ℝ) ((chebyT n).eval₂ (algebraMap ℤ ℝ) x) := by
          intros m n x hx
          have h_recurrence : ∀ m n : ℕ, ∀ x : ℝ, -1 ≤ x ∧ x ≤ 1 → (chebyT (m * n)).eval₂ (algebraMap ℤ ℝ) x = (chebyT m).eval₂ (algebraMap ℤ ℝ) ((chebyT n).eval₂ (algebraMap ℤ ℝ) x) := by
            intros m n x hx
            have h_cheby : ∀ n : ℕ, ∀ θ : ℝ, (chebyT n).eval₂ (algebraMap ℤ ℝ) (Real.cos θ) = Real.cos (n * θ) := by
              intro n θ; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.succ_eq_add_one, add_mul, Real.cos_add ] ;
              · erw [ show chebyT 0 = 1 from rfl ] ; norm_num;
              · erw [ Polynomial.eval₂_X ];
              · erw [ show chebyT ( n + 2 ) = 2 * Polynomial.X * chebyT ( n + 1 ) - chebyT n from rfl ] ; norm_num [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), Real.sin_add, Real.cos_add ] ; ring;
                rw [ Real.sin_sq, Real.cos_add ] ; ring
            convert h_cheby ( m * n ) ( Real.arccos x ) using 1 <;> simp +decide [ Real.cos_arccos hx.1 hx.2, h_cheby ];
            convert h_cheby m ( n * Real.arccos x ) using 1 ; ring;
            · rw [ ← h_cheby ] ; norm_num [ Real.cos_arccos hx.1 hx.2 ];
            · ring;
          exact h_recurrence m n x hx;
        -- Since these polynomials agree on the interval $[-1, 1]$, they must be equal.
        have h_poly_eq : ∀ p q : Polynomial ℤ, (∀ x : ℝ, -1 ≤ x ∧ x ≤ 1 → p.eval₂ (algebraMap ℤ ℝ) x = q.eval₂ (algebraMap ℤ ℝ) x) → p = q := by
          intros p q h_eq
          have h_poly_eq : (p.map (algebraMap ℤ ℝ)) = (q.map (algebraMap ℤ ℝ)) := by
            have h_poly_eq : Set.Infinite {x : ℝ | (p.map (algebraMap ℤ ℝ)).eval x = (q.map (algebraMap ℤ ℝ)).eval x} := by
              exact Set.Infinite.mono ( fun x hx => by simpa [ Polynomial.eval₂_eq_eval_map ] using h_eq x hx ) ( Set.Icc_infinite ( by norm_num ) );
            exact Classical.not_not.1 fun h => h_poly_eq <| Set.Finite.subset ( Polynomial.map ( algebraMap ℤ ℝ ) p - Polynomial.map ( algebraMap ℤ ℝ ) q |> Polynomial.roots |> Multiset.toFinset |> Finset.finite_toSet ) fun x hx => by simp_all +decide [ sub_eq_iff_eq_add ] ;
          exact Polynomial.map_injective ( algebraMap ℤ ℝ ) Int.cast_injective <| by simpa using h_poly_eq;
        exact h_poly_eq _ _ fun x hx => by simpa [ Polynomial.eval₂_comp ] using h_recurrence m n x hx;
      simpa using Eq.symm ( h_recurrence m n )



/-- A solution to the Pell equation x² - D·y² = 1 -/
structure PellSolution (D : ℤ) where
  x : ℤ
  y : ℤ
  eq : x^2 - D * y^2 = 1



/-- The trivial solution -/
def PellSolution.trivial (D : ℤ) : PellSolution D := ⟨1, 0, by ring⟩



/-- Composing two Pell solutions (the "Brahmagupta composition") -/
def PellSolution.compose (D : ℤ) (s₁ s₂ : PellSolution D) : PellSolution D where
  x := s₁.x * s₂.x + D * s₁.y * s₂.y
  y := s₁.x * s₂.y + s₁.y * s₂.x
  eq := by nlinarith [s₁.eq, s₂.eq, sq_nonneg (s₁.x * s₂.x + D * s₁.y * s₂.y),
                       sq_nonneg (s₁.x * s₂.y + s₁.y * s₂.x),
                       sq_nonneg (s₁.x * s₂.x - D * s₁.y * s₂.y),
                       sq_nonneg (s₁.x * s₂.y - s₁.y * s₂.x)]



theorem pell_compose_assoc (D : ℤ) (s₁ s₂ s₃ : PellSolution D) :
    PellSolution.compose D (PellSolution.compose D s₁ s₂) s₃ =
    PellSolution.compose D s₁ (PellSolution.compose D s₂ s₃) := by
      -- By definition of PellSolution.mk, we can unfold the composition and show that both sides are equal.
      simp [PellSolution.mk, PellSolution.compose] at *;
      constructor <;> ring



theorem pell_compose_trivial_left (D : ℤ) (s : PellSolution D) :
    PellSolution.compose D (PellSolution.trivial D) s = s := by
      cases s ; unfold PellSolution.trivial PellSolution.compose ; aesop



theorem sum_two_sq_mod (p : ℕ) (hp : Nat.Prime p) (hp4 : p % 4 = 1) :
    ∃ a : ZMod p, a^2 = -1 := by
      haveI := Fact.mk hp;
      obtain ⟨ x, hx ⟩ := ZMod.exists_sq_eq_neg_one_iff ( p := p );
      exact Exists.elim ( hx ( by rw [ hp4 ] ; decide ) ) fun a ha => ⟨ a, by rw [ sq, ha ] ⟩



theorem padic_val_add_ge_min (p a b : ℕ) (hp : Nat.Prime p)
    (ha : 0 < a) (hb : 0 < b) :
    padicValNat p (a + b) ≥ min (padicValNat p a) (padicValNat p b) ∨
    a + b = 0 := by
      -- By the properties of the p-adic valuation, if $p^k$ divides both $a$ and $b$, then it also divides their sum $a + b$.
      have h_div : ∀ k, p^k ∣ a → p^k ∣ b → p^k ∣ a + b := by
        exact fun k hk₁ hk₂ => Nat.dvd_add hk₁ hk₂;
      simp_all +decide [ ← Nat.factorization_le_iff_dvd, padicValNat_dvd_iff ];
      contrapose! h_div; aesop;



end
