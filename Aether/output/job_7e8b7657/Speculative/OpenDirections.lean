import Mathlib

/-! # CatalogBuild.Speculative.OpenDirections

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 42
-/

/-- Genus-2 curves provide a larger ambient group than genus-1:
p² > p for p ≥ 2. -/
theorem genus_two_exceeds_genus_one (p : ℕ) (hp : 2 ≤ p) :
    p < p ^ 2 := by nlinarith

/-- Higher genus = exponentially more information. -/
theorem genus_dimension_gap (p g₁ g₂ : ℕ) (hp : 2 ≤ p) (hg : g₁ < g₂) :
    p ^ g₁ < p ^ g₂ :=
  Nat.pow_lt_pow_right (by omega) hg

/-- Weil bound simplified: (p-1)^g ≤ p^g. -/
theorem weil_bound_simplified (p g : ℕ) (hp : 1 ≤ p) :
    (p - 1) ^ g ≤ p ^ g :=
  Nat.pow_le_pow_left (by omega) g

/-- The sumset A + A has at most |A|² elements. -/
theorem sumset_size_upper_bound {α : Type*} [DecidableEq α] [AddCommMonoid α]
    (A : Finset α) :
    (A.biUnion (fun a => A.image (fun b => a + b))).card ≤ A.card ^ 2 := by
  calc (A.biUnion (fun a => A.image (fun b => a + b))).card
      ≤ ∑ _a ∈ A, (A.image (fun b => _a + b)).card := Finset.card_biUnion_le
      _ ≤ ∑ _a ∈ A, A.card := Finset.sum_le_sum fun a _ => Finset.card_image_le
      _ = A.card * A.card := by rw [Finset.sum_const, smul_eq_mul]
      _ = A.card ^ 2 := by ring

/-- Every element of ℤ/pℤ is expressible as a sum. -/
theorem zmod_sumset_surjective (p : ℕ) :
    ∀ a : ZMod p, ∃ x y : ZMod p, x + y = a :=
  fun a => ⟨a, 0, by ring⟩

/-- The smaller factor satisfies p² ≤ N when p ≤ q. -/
theorem factor_search_space (N p q : ℕ) (hN : N = p * q)
    (hle : p ≤ q) : p * p ≤ N := by
  subst hN; exact Nat.mul_le_mul_left p hle

/-- k independent lenses reduce the search space. -/
theorem independent_lenses_exp_reduction (S k : ℕ) (hS : 0 < S) (hk : 1 ≤ k) :
    S / 2 ^ k < S :=
  Nat.div_lt_self hS (Nat.one_lt_pow (by omega) (by norm_num))

/-- More lenses ⟹ smaller surviving space. -/
theorem lens_diminishing_returns (S k₁ k₂ : ℕ) (hle : k₁ ≤ k₂) :
    S / 2 ^ k₂ ≤ S / 2 ^ k₁ :=
  Nat.div_le_div_left (Nat.pow_le_pow_right (by norm_num) hle) (by positivity)

/-- The ceiling theorem: if 2^k > S, then S / 2^k = 0. -/
theorem information_ceiling (S k : ℕ) (hk : S < 2 ^ k) :
    S / 2 ^ k = 0 :=
  Nat.div_eq_of_lt hk

/-- The fundamental tropical constraint: v_p(ab) = v_p(a) + v_p(b). -/
theorem tropical_valuation_additive (p a b : ℕ) (hp : Nat.Prime p)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.mul ha hb

/-- Multiple tropical primes compose via CRT. -/
theorem tropical_primes_compose (m n : ℕ) (hcop : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n :=
  Nat.totient_mul hcop

/-- Consecutive Fibonacci numbers are coprime. -/
theorem fib_consecutive_coprime (n : ℕ) :
    Nat.Coprime (Nat.fib n) (Nat.fib (n + 1)) :=
  Nat.fib_coprime_fib_succ n

/-- The Fibonacci addition formula. -/
theorem fib_addition (m n : ℕ) :
    Nat.fib (m + n + 1) = Nat.fib m * Nat.fib n + Nat.fib (m + 1) * Nat.fib (n + 1) :=
  Nat.fib_add m n

/-- [Section: # CatalogBuild.Speculative.OpenDirections
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 42] -/
theorem p_sub_one_dvd_p_sq_sub_one (p : ℕ) (_hp : 1 ≤ p) :
    (p - 1) ∣ (p * p - 1) := by
  rw [show p * p = p ^ 2 from by ring]
  exact Nat.sub_one_dvd_pow_sub_one p 2

/-- [Section: # CatalogBuild.Speculative.OpenDirections
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 42] -/
theorem p_add_one_dvd_p_sq_sub_one (p : ℕ) (hp : 1 ≤ p) :
    (p + 1) ∣ (p * p - 1) := by
  cases p with
  | zero => omega
  | succ n =>
    have : (n + 1) * (n + 1) - 1 = (n + 1 + 1) * n := by
      have h1 : (n + 1) * (n + 1) = n * n + 2 * n + 1 := by ring
      have h2 : (n + 1 + 1) * n = n * n + 2 * n := by ring
      omega
    rw [this]
    exact dvd_mul_right _ _

theorem fib_entry_point (p : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5) :
    p ∣ Nat.fib (p - 1) ∨ p ∣ Nat.fib (p + 1) := by
  by_contra! h;
  haveI := Fact.mk hp;
  -- Let's consider the roots of the characteristic polynomial of the Fibonacci sequence modulo p.
  obtain ⟨α, β, hαβ⟩ : ∃ α β : AlgebraicClosure (ZMod p), α + β = 1 ∧ α * β = -1 := by
    -- The polynomial $x^2 - x - 1$ has roots in the algebraic closure of $\mathbb{Z}/p\mathbb{Z}$.
    have h_poly_roots : ∃ α : AlgebraicClosure (ZMod p), α^2 - α - 1 = 0 := by
      have h_alg_closed : IsAlgClosed (AlgebraicClosure (ZMod p)) := by
        infer_instance;
      have := h_alg_closed.exists_root;
      exact Exists.elim ( this ( Polynomial.X ^ 2 - Polynomial.X - 1 ) ( by erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> norm_num ) ) fun x hx => ⟨ x, by simpa using hx ⟩;
    exact ⟨ h_poly_roots.choose, 1 - h_poly_roots.choose, by ring, by linear_combination -h_poly_roots.choose_spec ⟩;
  -- Using the roots α and β, we can express F_n as (α^n - β^n) / (α - β).
  have h_fib_expr : ∀ n : ℕ, (Nat.fib n : AlgebraicClosure (ZMod p)) = (α^n - β^n) / (α - β) := by
    intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.fib_add_two ] ;
    · rw [ div_self ] ; intro H ; simp_all +decide [ sub_eq_iff_eq_add ];
      simp_all +decide [ ← two_mul ];
      have := congr_arg ( · ^ 2 ) hαβ.1; norm_num [ mul_pow, hαβ.2 ] at this;
      simp_all +decide [sq];
      rw [ neg_eq_iff_add_eq_zero ] at this;
      norm_num at this;
      erw [ CharP.cast_eq_zero_iff ( AlgebraicClosure ( ZMod p ) ) p ] at this ; have := Nat.le_of_dvd ( by decide ) this ; interval_cases p <;> trivial;
    · grind;
  -- Since $p$ is prime and does not divide $5$, we have $\alpha^p = \beta$ and $\beta^p = \alpha$.
  have h_alpha_beta_p : α^p = β ∧ β^p = α := by
    have h_alpha_beta_p : α^p + β^p = 1 ∧ α^p * β^p = -1 := by
      have h_alpha_beta_p : α^p + β^p = (α + β)^p ∧ α^p * β^p = (α * β)^p := by
        simp +decide [ add_pow_char, mul_pow ];
      cases hp.eq_two_or_odd' <;> simp_all +decide;
    have h_alpha_beta_p : α^p = β ∨ α^p = α := by
      grind +ring;
    cases h_alpha_beta_p <;> simp_all +decide [ ← eq_sub_iff_add_eq' ];
    have := h_fib_expr ( p - 1 ) ; rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.fib_add_two ] ;
    have h_contra : (Nat.fib (p + 1) : AlgebraicClosure (ZMod (p + 2))) = 0 := by
      grind;
    erw [ CharP.cast_eq_zero_iff ( AlgebraicClosure ( ZMod ( p + 2 ) ) ) ( p + 2 ) ] at h_contra ; aesop;
  -- Using the expressions for α^p and β^p, we can simplify F_{p-1} and F_{p+1} to show that one of them must be zero.
  have h_fib_p_minus_1_zero : (Nat.fib (p - 1) : AlgebraicClosure (ZMod p)) = 0 ∨ (Nat.fib (p + 1) : AlgebraicClosure (ZMod p)) = 0 := by
    grind;
  simp_all +decide [ ← ZMod.natCast_eq_zero_iff ];
  have h_fib_p_minus_1_zero : (Nat.fib (p - 1) : ZMod p) = 0 ∨ (Nat.fib (p + 1) : ZMod p) = 0 := by
    have h_fib_p_minus_1_zero : Function.Injective (algebraMap (ZMod p) (AlgebraicClosure (ZMod p))) := by
      exact RingHom.injective _;
    exact Or.imp ( fun h => h_fib_p_minus_1_zero <| by aesop ) ( fun h => h_fib_p_minus_1_zero <| by aesop ) ‹ ( α ^ ( p - 1 ) - β ^ ( p - 1 ) = 0 ∨ α - β = 0 ) ∨ α ^ ( p + 1 ) - β ^ ( p + 1 ) = 0 ∨ α - β = 0 ›;
  aesop

/-- For any prime p ≠ 5, p | F(p² - 1).
Proof: by fib_entry_point, either p | F(p-1) or p | F(p+1).
Since (p-1) | (p²-1) and (p+1) | (p²-1), Nat.fib_dvd gives the result. -/
theorem pisano_p_divides_fib (p : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5) :
    p ∣ Nat.fib (p * p - 1) := by
  rcases fib_entry_point p hp hp5 with h | h
  · exact dvd_trans h (Nat.fib_dvd _ _ (p_sub_one_dvd_p_sq_sub_one p hp.one_le))
  · exact dvd_trans h (Nat.fib_dvd _ _ (p_add_one_dvd_p_sq_sub_one p hp.one_le))

/-- Hurwitz barrier: 16 ∉ {1, 2, 4, 8}. -/
theorem hurwitz_barrier_16 : 16 ∉ ({1, 2, 4, 8} : Set ℕ) := by
  simp [Set.mem_insert_iff]

/-- Composition algebra dimensions are powers of 2. -/
theorem hurwitz_dimensions_are_powers_of_two :
    ∀ n ∈ ({1, 2, 4, 8} : Finset ℕ), ∃ k : ℕ, n = 2 ^ k := by
  intro n hn
  simp [Finset.mem_insert] at hn
  rcases hn with rfl | rfl | rfl | rfl
  · exact ⟨0, by norm_num⟩
  · exact ⟨1, by norm_num⟩
  · exact ⟨2, by norm_num⟩
  · exact ⟨3, by norm_num⟩

/-- Classical lenses reduce quantum queries: √(N/2^k) ≤ √N. -/
theorem hybrid_query_reduction (N k : ℕ) :
    Nat.sqrt (N / 2 ^ k) ≤ Nat.sqrt N :=
  Nat.sqrt_le_sqrt (Nat.div_le_self N _)

/-- Classical preprocessing exponentially reduces search space. -/
theorem classical_preprocessing (N k : ℕ) (hN : 0 < N) (hk : 1 ≤ k) :
    N / 2 ^ k < N :=
  Nat.div_lt_self hN (Nat.one_lt_pow (by omega) (by norm_num))

/-- 9 lenses give 512× reduction. -/
theorem nine_lens_factor : 2 ^ 9 = 512 := by norm_num

/-- Lens reduction: S → S/b. -/
def lensReduce (S b : ℕ) : ℕ := S / b

/-- Identity lens: S/1 = S. -/
theorem lens_identity (S : ℕ) : lensReduce S 1 = S := by simp [lensReduce]

/-- Composing two lens reductions. -/
theorem lens_compose (S a b : ℕ) :
    lensReduce (lensReduce S a) b = S / a / b := rfl

/-- Combined reduction is stronger. -/
theorem lens_monoidal_product (S a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
    S / (a * b) ≤ S / a :=
  Nat.div_le_div_left (Nat.le_mul_of_pos_right a hb) (by positivity)

/-- Two independent halvings quarter the space. -/
theorem pairwise_independent_reduction (S : ℕ) :
    S / 4 ≤ S / 2 :=
  Nat.div_le_div_left (by norm_num) (by positivity)

/-- 2^9 = 512. -/
theorem nine_lens_reduction_factor : 2 ^ 9 = 512 := by norm_num

/-- lcm(a,b) · gcd(a,b) = a · b. -/
theorem lcm_gcd_product (a b : ℕ) : Nat.lcm a b * Nat.gcd a b = a * b :=
  Nat.lcm_mul_gcd a b

/-- Both factors divide the lcm. -/
theorem pisano_lcm_factors (T_p T_q : ℕ) :
    T_p ∣ Nat.lcm T_p T_q ∧ T_q ∣ Nat.lcm T_p T_q :=
  ⟨Nat.dvd_lcm_left T_p T_q, Nat.dvd_lcm_right T_p T_q⟩

/-- Euler's totient is multiplicative on coprimes. -/
theorem totient_multiplicative (m n : ℕ) (hcop : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n :=
  Nat.totient_mul hcop

/-- p-adic valuation is additive. -/
theorem padic_additive (p : ℕ) (hp : Nat.Prime p)
    (a b : ℕ) (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.mul ha hb

/-- √p ≤ p. -/
theorem sqrt_le_self' (p : ℕ) : Nat.sqrt p ≤ p := Nat.sqrt_le_self p

/-- GCD of trace differences divides N. -/
theorem hasse_gcd_divides (t₁ t₂ N : ℤ) :
    ↑(Int.gcd (t₁ - t₂) N) ∣ N := Int.gcd_dvd_right _ _

/-- Hasse interval width bound: 4√p ≤ 4p. -/
theorem hasse_birthday_bound (p : ℕ) :
    4 * Nat.sqrt p ≤ 4 * p :=
  Nat.mul_le_mul_left 4 (Nat.sqrt_le_self p)

/-- Search space after k lenses ≤ N. -/
theorem search_space_bound (N k : ℕ) : N / 2 ^ k ≤ N := Nat.div_le_self N _

/-- Sufficient lenses: ⌈log₂ N⌉ + 1 lenses reduce search to 0. -/
theorem sufficient_lenses (N : ℕ) :
    N / 2 ^ (Nat.log 2 N + 1) = 0 := by
  apply Nat.div_eq_of_lt
  exact Nat.lt_pow_succ_log_self (by norm_num) N

/-- An abstract lens: a monotone function on search spaces. -/
structure AbstractLens where
  reduce : ℕ → ℕ
  monotone : ∀ S, reduce S ≤ S

/-- The trivial (identity) lens. -/
def trivialLens : AbstractLens where
  reduce := id
  monotone := fun _ => le_refl _

/-- A halving lens: S ↦ S/2. -/
def halvingLens : AbstractLens where
  reduce := fun S => S / 2
  monotone := fun S => Nat.div_le_self S 2

/-- Lens composition. -/
def AbstractLens.compose (l₁ l₂ : AbstractLens) : AbstractLens where
  reduce := l₁.reduce ∘ l₂.reduce
  monotone := fun S => le_trans (l₁.monotone _) (l₂.monotone S)

/-- k halvings = division by 2^k. -/
theorem k_halvings (S k : ℕ) :
    (halvingLens.reduce^[k]) S = S / 2 ^ k := by
  induction k with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih]
    simp only [halvingLens]
    rw [Nat.div_div_eq_div_mul, pow_succ]

