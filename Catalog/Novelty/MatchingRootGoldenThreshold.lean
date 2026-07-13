import Mathlib

/-!
# Limit points of largest matching roots below the golden-ratio threshold

Let `τ = (1 + √5)/2` be the golden ratio and set the threshold
`T = √τ + 1/√τ = √(2 + √5) ≈ 2.058`.  A well-known circle of results
(analogous to Smith's / Hoffman–Shearer's theorems for adjacency eigenvalues)
studies the **largest matching root** `μ(G)` of a graph `G`, i.e. the largest
real zero of its matching polynomial, and asks which reals arise as *limit
points* of the values `μ(G)`.  The threshold `T` is the golden-ratio value
below which the set of limit points is conjecturally a countable set of
algebraic numbers built from the Dynkin families `Aₙ`, `Dₙ`.

This file isolates and fully proves the cleanest concrete instance of that
picture: the **path family**.  For the path `Pₙ` on `n` vertices the matching
polynomial obeys the edge–deletion recurrence
`μ(Pₙ) = x·μ(Pₙ₋₁) − μ(Pₙ₋₂)`, which we take as the definition `pathMatch n`.
We prove:

* `pathMatch_monic`, `pathMatch_natDegree` — `μ(Pₙ)` is monic of degree `n`;
* `pathMatch_eval_cos` — the trigonometric evaluation
  `μ(Pₙ)(2 cos θ)·sin θ = sin((n+1)θ)`;
* `pathMatch_isGreatest_root` — for `n ≥ 1` the *largest* real root of `μ(Pₙ)`
  is exactly `2 cos(π/(n+1))` (obtained by showing the `n` explicit numbers
  `2 cos(kπ/(n+1))`, `1 ≤ k ≤ n`, are all the roots);
* `mu_strictMono`, `mu_lt_two`, `mu_tendsto_two` — the largest matching roots of
  the paths form a strictly increasing sequence in `(−T, T)` converging to `2`;
* `two_lt_goldenThreshold`, `goldenThreshold_eq_sqrt_tau` — the arithmetic of
  the threshold: `T = √τ + 1/√τ` and `2 < T`;
* `largest_matching_root_accumulates_at_two` — the capstone: the largest
  matching roots of paths strictly increase inside `(−T, T)` to the limit point
  `2 < T`, exhibiting an explicit accumulation point strictly below the golden
  threshold;
* `mu_three_eq_tau` — a decorative identity: the largest matching root of `P₅`
  is *exactly* the golden ratio `τ = 2 cos(π/5)`.

Everything is elementary and self-contained (only trigonometry, the
degree/root count of polynomials, and continuity of `cos`).
-/

open Polynomial Real Filter Topology

namespace MatchingRootGolden

/-! ## The path matching polynomial -/

/-- The matching polynomial `μ(Pₙ)` of the path on `n` vertices, defined by the
edge–deletion recurrence `μ(Pₙ) = X·μ(Pₙ₋₁) − μ(Pₙ₋₂)`. -/
noncomputable def pathMatch : ℕ → ℝ[X]
  | 0 => 1
  | 1 => X
  | (n + 2) => X * pathMatch (n + 1) - pathMatch n

@[simp] lemma pathMatch_zero : pathMatch 0 = 1 := rfl
@[simp] lemma pathMatch_one : pathMatch 1 = X := rfl
lemma pathMatch_succ_succ (n : ℕ) :
    pathMatch (n + 2) = X * pathMatch (n + 1) - pathMatch n := rfl

/-
`μ(Pₙ)` is monic.
-/
lemma pathMatch_monic (n : ℕ) : (pathMatch n).Monic := by
  induction' n using Nat.twoStepInduction with n ih1 ih2;
  · exact Polynomial.monic_one;
  · exact Polynomial.monic_X;
  · rw [ pathMatch_succ_succ, Polynomial.Monic, Polynomial.leadingCoeff_sub_of_degree_lt ] <;> norm_num [ ih1, ih2 ];
    -- By definition of pathMatch, we know that its degree is n.
    have h_deg : ∀ n, Polynomial.degree (pathMatch n) = n := by
      intro n; induction' n using Nat.twoStepInduction with n ih1 ih2; aesop;
      · norm_num;
      · erw [ pathMatch_succ_succ, Polynomial.degree_sub_eq_left_of_degree_lt ] <;> simp_all +decide;
        · ring;
        · norm_cast ; linarith;
    rw [ h_deg, h_deg ] ; norm_cast ; simp +arith +decide

/-
`μ(Pₙ)` has degree `n`.
-/
lemma pathMatch_natDegree (n : ℕ) : (pathMatch n).natDegree = n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp +arith +decide [*];
  rw [ pathMatch_succ_succ, Polynomial.natDegree_sub_eq_left_of_natDegree_lt ] <;> rw [ Polynomial.natDegree_mul' ] <;> norm_num [ ih ];
  · ring;
  · exact Polynomial.Monic.ne_zero ( pathMatch_monic _ );
  · linarith;
  · exact Polynomial.Monic.ne_zero ( pathMatch_monic _ )

lemma pathMatch_ne_zero (n : ℕ) : pathMatch n ≠ 0 := (pathMatch_monic n).ne_zero

/-
The trigonometric evaluation identity:
`μ(Pₙ)(2 cos θ)·sin θ = sin((n+1)θ)`.
-/
lemma pathMatch_eval_cos (n : ℕ) (θ : ℝ) :
    (pathMatch n).eval (2 * Real.cos θ) * Real.sin θ = Real.sin ((n + 1) * θ) := by
  induction' n using Nat.twoStepInduction with n ih;
  · norm_num [ pathMatch_zero ];
  · norm_num [ pathMatch_one, Real.sin_two_mul ];
    ring;
  · simp_all +decide [ add_mul, Real.sin_add ];
    simp_all +decide [ Real.cos_add, Real.sin_two_mul, Real.cos_two_mul, pathMatch_succ_succ ];
    grind

/-
Value at `x = 2`: `μ(Pₙ)(2) = n + 1`.
-/
lemma pathMatch_eval_two (n : ℕ) : (pathMatch n).eval 2 = (n : ℝ) + 1 := by
  induction' n using Nat.twoStepInduction with n ih ih2;
  · norm_num [ pathMatch_zero ];
  · norm_num [ pathMatch_one ];
  · erw [ pathMatch_succ_succ, Polynomial.eval_sub, Polynomial.eval_mul, Polynomial.eval_X, ih2, ih ] ; push_cast ; ring;

/-! ## Roots of the path matching polynomial -/

/-
For `1 ≤ k ≤ n`, the argument `kπ/(n+1)` lies in the open interval `(0, π)`.
-/
lemma cos_arg_mem_Ioo (n k : ℕ) (hk1 : 1 ≤ k) (hkn : k ≤ n) :
    (k : ℝ) * π / (n + 1) ∈ Set.Ioo (0 : ℝ) π := by
      exact ⟨ by positivity, by rw [ div_lt_iff₀ ( by positivity ) ] ; nlinarith [ Real.pi_pos, show ( k : ℝ ) ≤ n by norm_cast ] ⟩

/-
Each `2 cos(kπ/(n+1))` with `1 ≤ k ≤ n` is a root of `μ(Pₙ)`.
-/
lemma pathMatch_isRoot_cos (n k : ℕ) (hk1 : 1 ≤ k) (hkn : k ≤ n) :
    (pathMatch n).IsRoot (2 * Real.cos ((k : ℝ) * π / (n + 1))) := by
      have := pathMatch_eval_cos n ( k * Real.pi / ( n + 1 ) );
      rw [ mul_div_cancel₀ ] at this <;> norm_num at *;
      · exact this.resolve_right ( ne_of_gt ( Real.sin_pos_of_pos_of_lt_pi ( by positivity ) ( by rw [ div_lt_iff₀ ( by positivity ) ] ; nlinarith [ Real.pi_pos, show ( k : ℝ ) ≤ n by norm_cast ] ) ) );
      · linarith

/-
The `n` numbers `2 cos(kπ/(n+1))`, `1 ≤ k ≤ n`, are exactly the roots of
`μ(Pₙ)`, and the largest of them (at `k = 1`) is the greatest root.
-/
lemma pathMatch_isGreatest_root (n : ℕ) (hn : 1 ≤ n) :
    IsGreatest {x : ℝ | (pathMatch n).IsRoot x} (2 * Real.cos (π / (n + 1))) := by
  refine' ⟨ _, fun x hx => _ ⟩;
  · simpa using pathMatch_isRoot_cos n 1 le_rfl hn;
  · -- By definition of $f$, we know that $x = 2 \cos(k \pi / (n + 1))$ for some $k \in \{1, 2, \ldots, n\}$.
    obtain ⟨k, hk⟩ : ∃ k ∈ Finset.Icc 1 n, x = 2 * Real.cos (k * Real.pi / (n + 1)) := by
      -- Let $S := (Finset.Icc 1 n).image f$. We need to show that $S = (pathMatch n).roots.toFinset$.
      set S : Finset ℝ := Finset.image (fun k : ℕ => 2 * Real.cos (k * Real.pi / (n + 1))) (Finset.Icc 1 n)
      have hS : S = (pathMatch n).roots.toFinset := by
        refine' Finset.eq_of_subset_of_card_le ( _ ) _;
        · intro;
          simp +zetaDelta at *;
          exact fun k hk₁ hk₂ hk₃ => ⟨ pathMatch_ne_zero n, by subst hk₃; exact pathMatch_isRoot_cos n k hk₁ hk₂ ⟩;
        · rw [ Finset.card_image_of_injOn ];
          · exact le_trans ( Multiset.toFinset_card_le _ ) ( le_trans ( Polynomial.card_roots' _ ) ( by simp +decide [ pathMatch_natDegree ] ) );
          · intros k hk l hl hkl; simp_all +decide;
            exact_mod_cast ( by apply_fun Real.arccos at hkl; rw [ Real.arccos_cos, Real.arccos_cos ] at hkl <;> nlinarith [ Real.pi_pos, show ( k : ℝ ) ≤ n by norm_cast; linarith, show ( l : ℝ ) ≤ n by norm_cast; linarith, mul_div_cancel₀ ( ( k : ℝ ) * Real.pi ) ( by positivity : ( n : ℝ ) + 1 ≠ 0 ), mul_div_cancel₀ ( ( l : ℝ ) * Real.pi ) ( by positivity : ( n : ℝ ) + 1 ≠ 0 ) ] : ( k : ℝ ) = l );
      replace hS := Finset.ext_iff.mp hS x; simp_all +decide [ eq_comm ] ;
      exact Exists.elim ( Finset.mem_image.mp ( hS.mpr ( pathMatch_ne_zero n ) ) ) fun k hk => ⟨ k, Finset.mem_Icc.mp hk.1, hk.2.symm ⟩;
    exact hk.2.symm ▸ mul_le_mul_of_nonneg_left ( Real.cos_le_cos_of_nonneg_of_le_pi ( by positivity ) ( by rw [ div_le_iff₀ ( by positivity ) ] ; nlinarith [ Real.pi_pos, show ( k : ℝ ) ≤ n by norm_cast; linarith [ Finset.mem_Icc.mp hk.1 ] ] ) ( by rw [ div_le_div_iff_of_pos_right ( by positivity ) ] ; nlinarith [ Real.pi_pos, show ( k : ℝ ) ≥ 1 by norm_cast; linarith [ Finset.mem_Icc.mp hk.1 ] ] ) ) zero_le_two

/-! ## The sequence of largest matching roots of paths -/

/-- `mu n` is the largest matching root of the path `P_{n+2}` on `n+2` vertices,
namely `2 cos(π/(n+2))`. -/
noncomputable def mu (n : ℕ) : ℝ := 2 * Real.cos (π / (n + 2))

/-
`mu n` is indeed the greatest root of `μ(P_{n+2})`.
-/
lemma mu_isGreatest_root (n : ℕ) :
    IsGreatest {x : ℝ | (pathMatch (n + 1)).IsRoot x} (mu n) := by
      convert pathMatch_isGreatest_root ( n + 1 ) ( by linarith ) using 1 ; push_cast ; ring;
      unfold mu; ring;

lemma mu_nonneg (n : ℕ) : 0 ≤ mu n := by
  exact mul_nonneg zero_le_two ( Real.cos_nonneg_of_mem_Icc ⟨ by rw [ le_div_iff₀ <| by positivity ] ; nlinarith [ Real.pi_pos ], by rw [ div_le_iff₀ <| by positivity ] ; nlinarith [ Real.pi_pos ] ⟩ )

lemma mu_lt_two (n : ℕ) : mu n < 2 := by
  exact mul_lt_of_lt_one_right zero_lt_two ( by rw [ ← Real.cos_zero ] ; exact Real.cos_lt_cos_of_nonneg_of_le_pi ( by positivity ) ( by linarith [ Real.pi_pos, div_le_self Real.pi_pos.le ( by linarith : ( n : ℝ ) + 2 ≥ 1 ) ] ) ( by linarith [ Real.pi_pos, div_pos Real.pi_pos ( by linarith : 0 < ( n : ℝ ) + 2 ) ] ) )

lemma mu_strictMono : StrictMono mu := by
  refine' strictMono_nat_of_lt_succ fun n => _;
  exact mul_lt_mul_of_pos_left ( Real.cos_lt_cos_of_nonneg_of_le_pi ( by positivity ) ( by rw [ div_le_iff₀ ] <;> nlinarith [ Real.pi_pos ] ) ( by rw [ div_lt_div_iff₀ ] <;> norm_num <;> linarith [ Real.pi_pos ] ) ) zero_lt_two

lemma mu_tendsto_two : Tendsto mu atTop (𝓝 2) := by
  convert Filter.Tendsto.const_mul 2 ( Real.continuous_cos.continuousAt.tendsto.comp <| tendsto_const_nhds.div_atTop <| Filter.tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop ) using 2 ; norm_num [ mu ]

/-! ## The golden-ratio threshold -/

/-- The golden ratio `τ = (1 + √5)/2`. -/
noncomputable def tau : ℝ := (1 + Real.sqrt 5) / 2

/-- The threshold `T = √(2 + √5)`. -/
noncomputable def goldenThreshold : ℝ := Real.sqrt (2 + Real.sqrt 5)

lemma tau_pos : 0 < tau := by
  exact div_pos ( by positivity ) ( by positivity )

/-
`T² = 2 + √5`.
-/
lemma goldenThreshold_sq : goldenThreshold ^ 2 = 2 + Real.sqrt 5 := by
  exact Real.sq_sqrt <| by positivity;

/-
`τ + 1/τ = √5`.
-/
lemma tau_add_inv_tau : tau + 1 / tau = Real.sqrt 5 := by
  rw [ add_div', div_eq_iff ] <;> nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ), show tau = ( 1 + Real.sqrt 5 ) / 2 by rfl ]

/-
`T = √τ + 1/√τ`, the golden-ratio form of the threshold.
-/
lemma goldenThreshold_eq_sqrt_tau :
    goldenThreshold = Real.sqrt tau + 1 / Real.sqrt tau := by
      rw [ eq_comm, ← sq_eq_sq₀ ] <;> norm_num [ goldenThreshold_sq, tau_pos.le ];
      · grind +suggestions;
      · positivity;
      · exact Real.sqrt_nonneg _

/-
The threshold exceeds `2`.
-/
lemma two_lt_goldenThreshold : 2 < goldenThreshold := by
  exact Real.lt_sqrt_of_sq_lt ( by nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] )

/-! ## Capstone: `2` is an accumulation point of largest matching roots below `T` -/

/-
**Main theorem.**  The largest matching roots `μ(P_{n+2}) = mu n` of the
paths form a strictly increasing sequence contained in the open interval
`(−T, T)` around the golden-ratio threshold `T`, and this sequence converges to
`2`, which is itself strictly below `T`.  Thus `2` is an explicit accumulation
point of largest matching roots lying strictly below the golden threshold.
-/
theorem largest_matching_root_accumulates_at_two :
    (∀ n : ℕ, IsGreatest {x : ℝ | (pathMatch (n + 1)).IsRoot x} (mu n)) ∧
    StrictMono mu ∧
    (∀ n : ℕ, mu n ∈ Set.Ioo (-goldenThreshold) goldenThreshold) ∧
    Tendsto mu atTop (𝓝 2) ∧
    (2 : ℝ) < goldenThreshold := by
  exact ⟨ fun n => mu_isGreatest_root n, mu_strictMono, fun n => ⟨ by linarith [ mu_nonneg n, two_lt_goldenThreshold ], by linarith [ mu_lt_two n, two_lt_goldenThreshold ] ⟩, mu_tendsto_two, two_lt_goldenThreshold ⟩

/-
`2` is a genuine accumulation point of the set of largest matching roots of
paths.
-/
theorem two_isAccPt_matching_roots :
    AccPt (2 : ℝ) (𝓟 (Set.range mu)) := by
      rw [ accPt_iff_frequently, frequently_iff ];
      intro U hU;
      obtain ⟨a, ha⟩ : ∃ a : ℕ, ∀ b ≥ a, mu b ∈ U := by
        exact Filter.eventually_atTop.mp ( mu_tendsto_two.eventually hU );
      exact ⟨ mu a, ha a le_rfl, ne_of_lt ( mu_lt_two a ), ⟨ a, rfl ⟩ ⟩

/-
Decorative identity: the largest matching root of the path `P₅` is exactly
the golden ratio `τ = (1 + √5)/2 = 2 cos(π/5)`.
-/
lemma mu_three_eq_tau : mu 3 = tau := by
  unfold mu tau; norm_num;
  ring

end MatchingRootGolden