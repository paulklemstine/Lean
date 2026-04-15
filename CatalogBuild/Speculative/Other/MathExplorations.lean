/-! # CatalogBuild.Speculative.Other.MathExplorations

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 34
-/

import Mathlib

/-- Primes ≠ 2 are either 1 or 3 mod 4. -/
theorem prime_mod_four (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) :
    p % 4 = 1 ∨ p % 4 = 3 := by
  have hodd := hp.odd_of_ne_two hp2
  rw [Nat.odd_iff] at hodd; omega


/-- Wilson's theorem: (p-1)! ≡ -1 (mod p). -/
theorem wilson_theorem' (p : ℕ) (hp : Nat.Prime p) :
    ((Nat.factorial (p - 1) : ℤ) : ZMod p) = -1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact_mod_cast ZMod.wilsons_lemma p


/-- [Section: ## 2. Continued Fractions & Pell Equations] -/
theorem pell_equation_small : (3 : ℤ) ^ 2 - 2 * 2 ^ 2 = 1 := by norm_num

theorem pell_equation_next : (17 : ℤ) ^ 2 - 2 * 12 ^ 2 = 1 := by norm_num


theorem pell_matrix_det : (3 : ℤ) * 3 - 4 * 2 = 1 := by norm_num


theorem seventeen_is_sum_of_squares : (17 : ℤ) = 1 ^ 2 + 4 ^ 2 := by norm_num


/-- There are infinitely many primes. -/
theorem primes_infinite' : ∀ n, ∃ p, n ≤ p ∧ Nat.Prime p :=
  fun n => let ⟨p, hp⟩ := Nat.exists_infinite_primes n; ⟨p, hp.1, hp.2⟩


/-- [Section: ## 5. Diophantine Equations] -/
theorem markov_111 : (1 : ℤ) ^ 2 + 1 ^ 2 + 1 ^ 2 = 3 * 1 * 1 * 1 := by norm_num


/-- Markov solutions generate new ones via Vieta jumping. -/
theorem markov_generate (x y z : ℤ) (h : x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z) :
    x ^ 2 + y ^ 2 + (3 * x * y - z) ^ 2 = 3 * x * y * (3 * x * y - z) := by nlinarith


theorem markov_112 : (1 : ℤ) ^ 2 + 1 ^ 2 + 2 ^ 2 = 3 * 1 * 1 * 2 := by norm_num

theorem markov_125 : (1 : ℤ) ^ 2 + 2 ^ 2 + 5 ^ 2 = 3 * 1 * 2 * 5 := by norm_num


/-- [Section: ## 6. Lattice Theory (Four Squares)] -/
theorem lagrange_four_sq_1 : ∃ a b c d : ℤ, 1 = a^2 + b^2 + c^2 + d^2 :=
  ⟨1, 0, 0, 0, by norm_num⟩

theorem lagrange_four_sq_7 : ∃ a b c d : ℤ, 7 = a^2 + b^2 + c^2 + d^2 :=
  ⟨1, 1, 1, 2, by norm_num⟩

theorem lagrange_four_sq_23 : ∃ a b c d : ℤ, 23 = a^2 + b^2 + c^2 + d^2 :=
  ⟨1, 2, 3, 3, by norm_num⟩

theorem lagrange_four_sq_15 : ∃ a b c d : ℤ, 15 = a^2 + b^2 + c^2 + d^2 :=
  ⟨1, 1, 2, 3, by norm_num⟩


/-- [Section: ## 7. Graph Theory (Tree Counting)] -/
theorem binary_tree_nodes (n : ℕ) : 2 ^ (n + 1) - 1 ≥ 2 ^ n := by omega


/-- Geometric sum: ∑_{i=0}^{d} 3^i = (3^(d+1) - 1)/2. -/
theorem ternary_tree_sum (d : ℕ) :
    2 * (∑ i ∈ Finset.range (d + 1), 3 ^ i) = 3 ^ (d + 1) - 1 := by
  induction d with
  | zero => simp
  | succ d ih =>
    rw [Finset.sum_range_succ]
    have h3 : 3 ^ (d + 1) ≥ 1 := Nat.one_le_pow _ _ (by norm_num)
    omega


/-- [Section: ## 8. Information Theory] -/
theorem factor_info_content (p q : ℕ) (hp : 2 ≤ p) (hq : 2 ≤ q) :
    p * q ≥ 4 := by nlinarith


/-- A strictly decreasing sequence on ℕ terminates. -/
theorem contracting_terminates {f : ℕ → ℕ}
    (hf : ∀ k, 0 < f k → f k < k) :
    ∀ n, ∃ m, m ≤ n ∧ f m = 0 := by
  intro n; induction n with
  | zero =>
    use 0; exact ⟨le_refl _, by
      by_contra h; exact absurd (hf 0 (by omega)) (by omega)⟩
  | succ n ih =>
    by_cases h : f (n + 1) = 0
    · exact ⟨n + 1, le_refl _, h⟩
    · obtain ⟨m, hm1, hm2⟩ := ih; exact ⟨m, by omega, hm2⟩


/-- Berggren descent is contracting. -/
theorem parent_hyp_less (a b c : ℤ) (ha : 0 < a) (hb : 0 < b)
    (hpyth : a^2 + b^2 = c^2) :
    -2*a - 2*b + 3*c < c := by nlinarith [sq_nonneg (a + b - c)]


/-- [Section: ## 10. p-adic Numbers] -/
theorem legendre_formula_example : padicValNat 2 (Nat.factorial 10) = 8 := by native_decide


/-- [Section: ## 11. Elliptic Curves (Congruent Numbers)] -/
theorem congruent_5 : ∃ a b c : ℚ, a ^ 2 + b ^ 2 = c ^ 2 ∧
    a * b / 2 = 5 ∧ 0 < a ∧ 0 < b :=
  ⟨20/3, 3/2, 41/6, by norm_num, by norm_num, by norm_num, by norm_num⟩


/-- [Section: ## 12. Sieve Theory] -/
theorem smallest_factor_le_sqrt (n : ℕ) (hn : 2 ≤ n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ n ∧ p * p ≤ n := by
  obtain ⟨ p, hp, hpn ⟩ := Nat.exists_prime_and_dvd ( by linarith );
  obtain ⟨ k, hk ⟩ := hpn;
  by_cases h₂ : p ≤ k;
  · exact ⟨ p, hp, hk.symm ▸ dvd_mul_right _ _, by nlinarith ⟩;
  · exact ⟨ k.minFac, Nat.minFac_prime ( by aesop_cat ), k.minFac_dvd.trans ( hk.symm ▸ dvd_mul_left _ _ ), by nlinarith [ Nat.minFac_le ( Nat.pos_of_ne_zero ( by aesop_cat : k ≠ 0 ) ) ] ⟩


/-- [Section: ## 13. Additive Combinatorics] -/
theorem sumset_singleton_card (A : Finset ℤ) (b : ℤ) :
    (A.image (· + b)).card = A.card :=
  Finset.card_image_of_injective A (fun _ _ h => by linarith)


/-- Pythagorean triples lie on the light cone. -/
theorem pyth_on_lightcone (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    lorentz_inner ![a, b, c] ![a, b, c] = 0 := by
  simp [lorentz_inner, Matrix.cons_val_zero, Matrix.cons_val_one]
  linarith


theorem lorentz_add_left (u v w : Fin 3 → ℤ) :
    lorentz_inner (u + v) w = lorentz_inner u w + lorentz_inner v w := by
  simp [lorentz_inner, Pi.add_apply]; ring


/-- [Section: ## 15. Algebraic Topology] -/
theorem euler_char_genus (g : ℕ) : 2 - 2 * (g : ℤ) = 2 * (1 - (g : ℤ)) := by ring


/-- Cayley-Hamilton for 2×2 (explicit). -/
theorem cayley_hamilton_2x2_identity (a b c d : ℤ) :
    let t := a + d; let dt := a * d - b * c
    (a ^ 2 + b * c) - t * a + dt = 0 ∧
    (a * b + b * d) - t * b = 0 ∧
    (c * a + d * c) - t * c = 0 ∧
    (c * b + d ^ 2) - t * d + dt = 0 := by
  simp only; constructor <;> [ring; constructor <;> [ring; constructor <;> [ring; ring]]]


/-- [Section: ## 17. Finite Fields] -/
theorem Fp_card (p : ℕ) [Fact (Nat.Prime p)] : Fintype.card (ZMod p) = p :=
  ZMod.card p


theorem Fp_star_cyclic (p : ℕ) [Fact (Nat.Prime p)] :
    IsCyclic (ZMod p)ˣ := inferInstance


/-- R(3,3) > 5: there exists a 2-coloring of K₅ with no monochromatic triangle. -/
theorem ramsey_lower : ∃ (f : Fin 5 → Fin 5 → Bool),
    (∀ i j, i ≠ j → (f i j = f j i)) ∧
    ¬∃ (a b c : Fin 5), a ≠ b ∧ b ≠ c ∧ a ≠ c ∧
      f a b = f b c ∧ f b c = f a c := by
  use fun i j => decide (((i : ℕ) + 5 - (j : ℕ)) % 5 = 1 ∨
                          ((i : ℕ) + 5 - (j : ℕ)) % 5 = 4)
  refine ⟨by intro i j hij; fin_cases i <;> fin_cases j <;> simp_all, ?_⟩
  intro ⟨a, b, c, _, _, _, h1, h2⟩
  fin_cases a <;> fin_cases b <;> fin_cases c <;> simp_all


theorem pyth_triples_finite (N : ℕ) :
    Set.Finite {t : ℕ × ℕ × ℕ | t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 ∧ t.2.2 ≤ N} := by
  apply Set.Finite.subset (Set.finite_Icc (0, 0, 0) (N, N, N))
  intro ⟨a, b, c⟩ ⟨hpyth, hc⟩
  simp only [Set.mem_Icc, Prod.le_def]
  exact ⟨⟨Nat.zero_le _, Nat.zero_le _, Nat.zero_le _⟩, ⟨by nlinarith, by nlinarith, hc⟩⟩


/-- The error signal E = 4δ(δ-1) is strictly positive for δ ∉ {0,1}. -/
theorem error_nonneg_over_Z (delta : ℤ) (hd : delta ≠ 0) (hd1 : delta ≠ 1) :
    0 < 4 * delta ^ 2 - 4 * delta := by
  have : 0 < delta * (delta - 1) := by
    rcases lt_or_gt_of_ne hd with h | h
    · exact mul_pos_of_neg_of_neg h (by omega)
    · rcases lt_or_gt_of_ne hd1 with h2 | h2
      · omega
      · exact mul_pos (by omega) (by omega)
  nlinarith


/-- [Section: ## New Theorems] -/
theorem multi_form_total_work (p f : ℕ) :
    (p - 1) / 2 / f * f ≤ (p - 1) / 2 := Nat.div_mul_le_self _ _
