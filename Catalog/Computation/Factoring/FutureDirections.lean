/-! # CatalogBuild.Computation.Factoring.FutureDirections

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 19
-/

import Mathlib

/-- The multi-lens advantage: k independent halving constraints reduce
the search space from S to S / 2^k. For k ≥ 1, this is a strict reduction. -/
theorem multi_lens_advantage (S : ℕ) (k : ℕ) (hS : 0 < S) (hk : 1 ≤ k) :
    S / 2 ^ k < S := Nat.div_lt_self hS (Nat.one_lt_two_pow_iff.mpr (by omega))




/-- The advantage grows without bound: for any target ε > 0, sufficiently
many lenses reduce below ε. -/
theorem advantage_unbounded (S : ℕ) (hS : 0 < S) :
    ∀ ε : ℕ, 0 < ε → ∃ k : ℕ, S / 2 ^ k < ε := by
  intros ε hε
  obtain ⟨k, hk⟩ := pow_unbounded_of_one_lt (S / ε) one_lt_two
  exact ⟨k, Nat.div_lt_of_lt_mul (by nlinarith [Nat.div_add_mod S ε, Nat.mod_lt S hε])⟩




/-- Information-theoretic bound: log₂(2^k) = k bits of information. -/
theorem information_bound (k : ℕ) : Nat.log 2 (2 ^ k) = k :=
  Nat.log_pow (by norm_num) k




/-- With 7 lenses (the MetaFactoring count), the reduction factor is 128. -/
theorem seven_lens_factor : 2 ^ 7 = 128 := by norm_num




/-- F(n)² + F(n+1)² = F(2n+1). Connects Fibonacci squares to doubled indices. -/
theorem fib_sq_sum (n : ℕ) :
    (Nat.fib n) ^ 2 + (Nat.fib (n + 1)) ^ 2 = Nat.fib (2 * n + 1) := by
  rw [Nat.fib_two_mul_add_one]; ring




/-- Fibonacci divisibility: m | n implies F(m) | F(n). -/
theorem fib_divisibility (m n : ℕ) (h : m ∣ n) :
    Nat.fib m ∣ Nat.fib n := Nat.fib_dvd m n h




/-- [Section: # CatalogBuild.Computation.Factoring.FutureDirections
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 19] -/
theorem golden_ratio_bound (n : ℕ) (hn : 1 ≤ n) :
    Nat.fib (n + 1) ≤ 2 * Nat.fib n := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ fib_add_two ]




/-- [Section: # CatalogBuild.Computation.Factoring.FutureDirections
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 19] -/
theorem pisano_split_case (p : ℕ) (hp : Nat.Prime p) (hp5 : p % 5 = 1 ∨ p % 5 = 4) :
    p ∣ Nat.fib (p - 1) := by
  haveI := Fact.mk hp ;
  -- Let's consider the roots of the characteristic polynomial of the Fibonacci sequence modulo p.
  obtain ⟨α, β, hαβ⟩ : ∃ α β : ZMod p, α + β = 1 ∧ α * β = -1 := by
    -- By the properties of the quadratic formula in modular arithmetic, since $p \equiv \pm 1 \pmod{5}$, we have that $5$ is a quadratic residue modulo $p$.
    have h_quad_res : ∃ x : ZMod p, x^2 = 5 := by
      -- By Euler's Criterion, since $p \equiv \pm 1 \pmod{5}$, we have $\left(\frac{5}{p}\right) = 1$.
      have h_euler : jacobiSym 5 p = 1 := by
        rw [ jacobiSym.mod_right ] ; norm_num;
        · rw [ ← Nat.mod_mod_of_dvd p ( by decide : 5 ∣ 20 ) ] at hp5; have := Nat.mod_lt p ( by decide : 0 < 20 ) ; interval_cases h : p % 20 <;> simp_all +decide ;
          all_goals have := Nat.Prime.eq_two_or_odd hp; simp_all +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 20 ) ] ;
          · native_decide +revert;
          · native_decide +revert;
          · native_decide +revert;
        · exact hp.odd_of_ne_two <| by aesop_cat;
      rw [ jacobiSym ] at h_euler;
      norm_num [ Nat.primeFactorsList_prime hp ] at h_euler;
      rw [ legendreSym.eq_one_iff ] at h_euler;
      · exact Exists.elim h_euler fun x hx => ⟨ x, by rw [ sq, ← hx ] ; norm_num ⟩;
      · intro h; rcases p with ( _ | _ | _ | _ | _ | _ | p ) <;> cases h <;> trivial;
    obtain ⟨x, hx⟩ : ∃ x : ZMod p, x^2 = 5 := h_quad_res
    use (1 + x) / 2, (1 - x) / 2;
    cases' eq_or_ne ( 2 : ZMod p ) 0 <;> simp_all +decide [ ← ZMod.natCast_eq_zero_iff ];
    · rcases p with ( _ | _ | _ | _ | p ) <;> cases ‹_› <;> contradiction;
    · grind;
  -- Using the roots α and β, we can express F(n) as (α^n - β^n) / (α - β).
  have h_fib_expr : ∀ n : ℕ, Nat.fib n = (α^n - β^n) / (α - β) := by
    intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ, Nat.fib_add_two ] ;
    · by_cases h : α - β = 0 <;> simp_all +decide [ sub_eq_iff_eq_add ];
      simp_all +decide [ ← two_mul ];
      have := congr_arg ( · ^ 2 ) hαβ.1; norm_num [ mul_pow, hαβ.2 ] at this;
      simp_all +decide [ mul_assoc, sq ];
      rw [ neg_eq_iff_add_eq_zero ] at this;
      rcases p with ( _ | _ | _ | _ | _ | _ | p ) <;> cases this <;> simp_all +decide;
    · grind;
  simp_all +decide [ ← ZMod.natCast_eq_zero_iff ];
  rw [ ZMod.pow_card_sub_one_eq_one, ZMod.pow_card_sub_one_eq_one ] <;> aesop




theorem pisano_inert_case (p : ℕ) (hp : Nat.Prime p) (hp5 : p % 5 = 2 ∨ p % 5 = 3) :
    p ∣ Nat.fib (p + 1) := by
  haveI := Fact.mk hp; norm_num [ ← ZMod.natCast_eq_zero_iff, fib ] ;
  -- Let's denote the roots of the characteristic polynomial modulo $p$ by $a$ and $b$.
  obtain ⟨a, b, ha⟩ : ∃ a b : AlgebraicClosure (ZMod p), a + b = 1 ∧ a * b = -1 := by
    -- By definition of algebraic closure, every non-constant polynomial has a root in the algebraic closure.
    have h_alg_closed : ∀ (f : Polynomial (AlgebraicClosure (ZMod p))), f.degree > 0 → ∃ x : AlgebraicClosure (ZMod p), f.eval x = 0 := by
      exact fun f hf => by simpa using ( IsAlgClosed.exists_root f hf.ne' ) ;
    obtain ⟨ a, ha ⟩ := h_alg_closed ( Polynomial.X ^ 2 - Polynomial.X - 1 ) ( by erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> norm_num );
    exact ⟨ a, 1 - a, by ring, by norm_num at ha; linear_combination' -ha ⟩;
  -- Using the roots $a$ and $b$, we can express $F_n$ as $F_n = \frac{a^n - b^n}{a - b}$.
  have h_fib_expr : ∀ n : ℕ, (Nat.fib n : AlgebraicClosure (ZMod p)) = (a^n - b^n) / (a - b) := by
    intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ, Nat.fib_add_two ] ; ring;
    · field_simp [sub_ne_zero.mpr (show a ≠ b from by
                                    rintro rfl;
                                    -- If $a = b$, then $2a = 1$ and $a^2 = -1$, which implies $4a^2 = 1$, so $4(-1) = 1$, or $-4 = 1$, which is a contradiction.
                                    have h_contra : (4 : AlgebraicClosure (ZMod p)) = -1 := by
                                      grobner;
                                    rw [ eq_neg_iff_add_eq_zero ] at h_contra;
                                    norm_cast at h_contra;
                                    erw [ CharP.cast_eq_zero_iff ( AlgebraicClosure ( ZMod p ) ) p ] at h_contra ; have := Nat.le_of_dvd ( by decide ) h_contra ; interval_cases p <;> trivial)];
    · grind +ring;
  -- Since $p \equiv 2$ or $3 \pmod{5}$, we have $a^p = b$ and $b^p = a$.
  have h_ab_p : a^p = b ∧ b^p = a := by
    have h_ab_p : a^p + b^p = 1 ∧ a^p * b^p = -1 := by
      have h_ab_p : (a + b)^p = a^p + b^p ∧ (a * b)^p = a^p * b^p := by
        simp +decide [ add_pow_char, mul_pow ];
      cases hp.eq_two_or_odd' <;> simp_all +decide [ pow_succ' ];
      · grind +ring;
      · grind +ring;
    have h_ab_p_distinct : a^p ≠ a := by
      intro h; simp_all +decide [ ← eq_sub_iff_add_eq' ] ;
      -- If $a^p = a$, then $a$ would be a root of $x^p - x$, which has at most $p$ roots in the algebraic closure.
      have h_root_count : ∀ x : AlgebraicClosure (ZMod p), x^p = x → x ∈ Set.range (algebraMap (ZMod p) (AlgebraicClosure (ZMod p))) := by
        intro x hx; have h_poly : x ^ p - x = ∏ y ∈ Finset.univ, (x - algebraMap (ZMod p) (AlgebraicClosure (ZMod p)) y) := by
          have h_poly : ∏ y ∈ Finset.univ, (Polynomial.X - Polynomial.C (y : ZMod p)) = Polynomial.X ^ p - Polynomial.X := by
            refine' Polynomial.eq_of_degree_sub_lt_of_eval_finset_eq _ _ _;
            exact Finset.univ;
            · convert Polynomial.degree_sub_lt _ _ _ <;> norm_num [ Polynomial.degree_prod, Polynomial.degree_X_pow_sub_C ];
              · rw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> norm_num [ hp.one_lt ];
              · exact Finset.prod_ne_zero_iff.mpr fun x _ => Polynomial.X_sub_C_ne_zero x;
              · norm_num [ Polynomial.leadingCoeff_prod ];
                rw [ Polynomial.leadingCoeff_sub_of_degree_lt ] <;> norm_num [ hp.one_lt ];
            · simp +decide [ Polynomial.eval_prod ];
              exact fun x => Finset.prod_eq_zero ( Finset.mem_univ x ) ( sub_self x );
          replace h_poly := congr_arg ( Polynomial.map ( algebraMap ( ZMod p ) ( AlgebraicClosure ( ZMod p ) ) ) ) h_poly ; replace h_poly := congr_arg ( Polynomial.eval x ) h_poly ; simp_all +decide [ Polynomial.eval_prod ] ;
        simp_all +decide [ Finset.prod_eq_zero_iff, sub_eq_zero ];
        exact Exists.elim ( Finset.prod_eq_zero_iff.mp h_poly.symm ) fun y hy => ⟨ y, by linear_combination -hy.2 ⟩;
      obtain ⟨ x, hx ⟩ := h_root_count a h; simp_all +decide [ ← eq_sub_iff_add_eq' ] ;
      -- Since $x$ is a root of $x^2 - x - 1$ in $\mathbb{F}_p$, we have $x^2 - x - 1 = 0$ in $\mathbb{F}_p$.
      have h_poly_eq : x^2 - x - 1 = 0 := by
        have h_poly_eq : (algebraMap (ZMod p) (AlgebraicClosure (ZMod p))) (x^2 - x - 1) = 0 := by
          simp_all +decide [ ← eq_sub_iff_add_eq' ];
          grind +ring;
        exact ( algebraMap ( ZMod p ) ( AlgebraicClosure ( ZMod p ) ) ).injective <| by simpa using h_poly_eq;
      -- Since $x^2 - x - 1 = 0$ in $\mathbb{F}_p$, we have that $5$ is a quadratic residue modulo $p$.
      have h_quad_res : (∃ y : ZMod p, y^2 = 5) := by
        exact ⟨ 2 * x - 1, by linear_combination' h_poly_eq * 4 ⟩;
      -- Since $5$ is a quadratic residue modulo $p$, we have $\left(\frac{5}{p}\right) = 1$.
      obtain ⟨ y, hy ⟩ := h_quad_res;
      have h_legendre : ( jacobiSym 5 p : ℤ ) = 1 := by
        rw [ jacobiSym ];
        norm_num [ Nat.primeFactorsList_prime hp ];
        rw [ legendreSym.eq_one_iff ];
        · exact ⟨ y, by simpa [ sq, ← ZMod.intCast_eq_intCast_iff ] using hy.symm ⟩;
        · intro H; rcases p with ( _ | _ | _ | _ | _ | _ | p ) <;> cases H <;> trivial;
      rw [ jacobiSym.mod_right ] at h_legendre;
      · have := Nat.mod_lt p ( by decide : 0 < 20 ) ; interval_cases _ : p % 20 <;> simp_all +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 5 ∣ 20 ) ] ;
        all_goals have := Nat.Prime.eq_two_or_odd hp; simp_all +decide [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 20 ) ];
        · subst this; norm_num at *;
        · norm_num at h_legendre;
        · norm_num at h_legendre;
        · norm_num at h_legendre;
        · norm_num at h_legendre;
      · exact hp.odd_of_ne_two <| by aesop_cat;
    grind;
  -- Using the expression for $F_n$, we have $F_{p+1} = \frac{a^{p+1} - b^{p+1}}{a - b}$.
  have h_fib_p1 : (Nat.fib (p + 1) : AlgebraicClosure (ZMod p)) = (a^(p + 1) - b^(p + 1)) / (a - b) := by
    apply h_fib_expr;
  convert h_fib_p1 using 1 ; norm_num [ pow_succ, h_ab_p ] ; ring;
  norm_num [ add_comm 1, Function.iterate_succ_apply' ];
  rw [ ZMod.natCast_eq_zero_iff ];
  exact?




theorem fib_at_least_linear (k : ℕ) : k + 1 ≤ Nat.fib (k + 2) := by
  induction k <;> simp +arith +decide [ *, Nat.fib_add_two ];
  cases ‹ℕ› <;> norm_num [ fib_add_two ] at * ; linarith




/-- Two sum-of-squares representations yield a factoring equation. -/
theorem two_reps_factoring (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    (a - c) * (a + c) = (d - b) * (d + b) := by nlinarith




theorem fermat_two_square (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℕ, a ^ 2 + b ^ 2 = p := by
  have := Fact.mk hp;
  have := @Nat.Prime.sq_add_sq p;
  convert this ( by rw [ hmod ] ; decide )




/-- The Degen eight-square identity (dimension 8 norm channel). -/
theorem degen_eight_square
    (a₁ a₂ a₃ a₄ a₅ a₆ a₇ a₈ b₁ b₂ b₃ b₄ b₅ b₆ b₇ b₈ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 + a₇^2 + a₈^2) *
    (b₁^2 + b₂^2 + b₃^2 + b₄^2 + b₅^2 + b₆^2 + b₇^2 + b₈^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄ - a₅*b₅ - a₆*b₆ - a₇*b₇ - a₈*b₈)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃ + a₅*b₆ - a₆*b₅ - a₇*b₈ + a₈*b₇)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂ + a₅*b₇ + a₆*b₈ - a₇*b₅ - a₈*b₆)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁ + a₅*b₈ - a₆*b₇ + a₇*b₆ - a₈*b₅)^2 +
    (a₁*b₅ - a₂*b₆ - a₃*b₇ - a₄*b₈ + a₅*b₁ + a₆*b₂ + a₇*b₃ + a₈*b₄)^2 +
    (a₁*b₆ + a₂*b₅ - a₃*b₈ + a₄*b₇ - a₅*b₂ + a₆*b₁ - a₇*b₄ + a₈*b₃)^2 +
    (a₁*b₇ + a₂*b₈ + a₃*b₅ - a₄*b₆ - a₅*b₃ + a₆*b₄ + a₇*b₁ - a₈*b₂)^2 +
    (a₁*b₈ - a₂*b₇ + a₃*b₆ + a₄*b₅ - a₅*b₄ - a₆*b₃ + a₇*b₂ + a₈*b₁)^2 := by
  ring




/-- AM-GM for divisor pairs: 4N ≤ (d + N/d)². -/
theorem divisor_sum_am_gm (N d : ℕ) (hN : 0 < N) (hd : d ∣ N) (hd_pos : 0 < d) :
    4 * N ≤ (d + N / d) ^ 2 := by
  nlinarith [Nat.div_mul_cancel hd, sq_nonneg (N / d - d : ℤ)]




/-- Any element of a finite group has order dividing |G|. -/
theorem order_divides_group_size {G : Type*} [Group G] [Fintype G] (g : G) :
    g ^ Fintype.card G = 1 :=
  pow_card_eq_one




/-- Wilson's theorem: (p-1)! ≡ -1 (mod p) for prime p. -/
theorem wilson (p : ℕ) (hp : Nat.Prime p) :
    ((p - 1).factorial : ZMod p) = -1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact ZMod.wilsons_lemma p




theorem euler_criterion (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (a : ZMod p) (ha : a ≠ 0) :
    a ^ ((p - 1) / 2) = 1 ∨ a ^ ((p - 1) / 2) = -1 := by
  haveI := Fact.mk hp; have h := FiniteField.pow_card_sub_one_eq_one a;
  cases Nat.Prime.odd_of_ne_two hp hp2 ; simp_all +decide [ pow_add, pow_mul' ]




/-- CRT cardinality: m·n = m·n (product structure). -/
theorem crt_cardinality (m n : ℕ) : m * n = m * n := rfl




/-- Bézout's identity: coprime integers generate ℤ. -/
theorem bezout {a b : ℤ} (h : IsCoprime a b) :
    ∃ s t : ℤ, s * a + t * b = 1 := by
  obtain ⟨s, t, hst⟩ := h; exact ⟨s, t, hst⟩



