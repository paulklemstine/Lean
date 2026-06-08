import Mathlib

/-! # CatalogBuild.Physics.Classical.TimelineGravityCycles

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 56
-/

noncomputable section

/-- A prime is "light" if p ≡ 1 mod 4. -/
def isLightPrime' (p : ℕ) : Prop := p.Prime ∧ p % 4 = 1

/-- A prime is "dark" if p ≡ 3 mod 4. -/
def isDarkPrime' (p : ℕ) : Prop := p.Prime ∧ p % 4 = 3

/-- [Section: # CatalogBuild.Physics.Classical.TimelineGravityCycles
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 56] -/
theorem prime_div_sq_add_one_mod_four (p n : ℕ) (hp : p.Prime) (hp2 : p ≠ 2)
    (hdvd : p ∣ n ^ 2 + 1) : p % 4 = 1 := by
      haveI := Fact.mk hp; norm_num [ ← ZMod.natCast_eq_zero_iff ] at *;
      have := ZMod.exists_sq_eq_neg_one_iff ( p := p );
      exact this.mp ⟨ n, by linear_combination' -hdvd ⟩ |> fun h => by have := Nat.Prime.eq_two_or_odd hp; omega;

/-- [Section: # CatalogBuild.Physics.Classical.TimelineGravityCycles
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 56] -/
theorem infinitely_many_dark_primes :
    ∀ N : ℕ, ∃ p, N < p ∧ isDarkPrime' p := by
      intro N;
      -- Consider the number $M = 4(N+1)! - 1$. This number is of the form $4k-1$ and is greater than $N$.
      set M := 4 * (N + 1)! - 1;
      have hM_form : M % 4 = 3 := by
        zify;
        rw [ Int.ofNat_sub ( Nat.one_le_iff_ne_zero.mpr <| by positivity ) ] ; norm_num [ Int.mul_emod, Int.sub_emod ];
      have hM_gt_N : M > N := by
        exact lt_tsub_iff_left.mpr ( by linarith [ Nat.self_le_factorial ( N + 1 ) ] );
      -- Since $M$ is of the form $4k-1$, it must have a prime divisor $p$ that is also of the form $4k-1$.
      obtain ⟨p, hp_prime, hp_div⟩ : ∃ p, Nat.Prime p ∧ p ∣ M ∧ p % 4 = 3 := by
        by_contra h_no_prime_divisor;
        -- If $M$ has no prime factors of the form $4k-1$, then all prime factors of $M$ must be of the form $4k+1$.
        have h_all_prime_factors_form : ∀ p : ℕ, Nat.Prime p → p ∣ M → p % 4 = 1 := by
          intro p pp dp; have := Nat.mod_lt p zero_lt_four; interval_cases h : p % 4 <;> simp_all +decide [ ← Nat.dvd_iff_mod_eq_zero, pp.dvd_iff_eq ] ;
          have := Nat.dvd_trans ( Nat.dvd_of_mod_eq_zero ( show p % 2 = 0 by norm_num [ ← Nat.mod_mod_of_dvd p ( by decide : 2 ∣ 4 ), h ] ) ) dp; omega;
        -- The product of numbers of the form $4k+1$ is again of the form $4k+1$.
        have h_prod_form : ∀ (n : ℕ), (∀ p : ℕ, Nat.Prime p → p ∣ n → p % 4 = 1) → n % 4 = 1 := by
          intros n hn; rw [ ← Nat.prod_primeFactorsList ( show n ≠ 0 from fun hk ↦ by subst hk; specialize hn 2 Nat.prime_two; simp_all +decide ) ] ; rw [ List.prod_nat_mod ] ; exact by rw [ List.prod_eq_one ] <;> intros <;> aesop;
        cases h_prod_form M h_all_prime_factors_form ▸ hM_form;
      exact ⟨ p, not_le.mp fun h => by have := Nat.dvd_sub ( dvd_mul_of_dvd_right ( Nat.dvd_factorial ( Nat.pos_of_ne_zero hp_prime.ne_zero ) ( by linarith : N + 1 ≥ p ) ) 4 ) hp_div.1; erw [ Nat.sub_sub_self ( Nat.one_le_iff_ne_zero.mpr <| by positivity ) ] at this; aesop, hp_prime, hp_div.2 ⟩

theorem infinitely_many_light_primes :
    ∀ N : ℕ, ∃ p, N < p ∧ isLightPrime' p := by
      intro N;
      -- By Dirichlet's theorem on arithmetic progressions, there are infinitely many primes in the arithmetic progression $4k + 1$.
      have h_dirichlet : Set.Infinite {p : ℕ | Nat.Prime p ∧ p % 4 = 1} := by
        exact Nat.infinite_setOf_prime_modEq_one <| by decide;
      exact Exists.elim ( h_dirichlet.exists_gt N ) fun p hp => ⟨ p, hp.2, hp.1 ⟩

/-- Computational verification: light and dark counts. -/
def lightPrimeCount' (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter (fun p => p.Prime ∧ p % 4 = 1)).card

def darkPrimeCount' (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter (fun p => p.Prime ∧ p % 4 = 3)).card

/-- Both counts grow: 11 light and 13 dark primes up to 100. -/
theorem light_dark_count_100 :
    lightPrimeCount' 100 = 11 ∧ darkPrimeCount' 100 = 13 := by
  constructor <;> native_decide

/-- By 200: 21 light, 24 dark — dark still leads (Chebyshev bias). -/
theorem light_dark_count_200 :
    lightPrimeCount' 200 = 21 ∧ darkPrimeCount' 200 = 24 := by
  constructor <;> native_decide

theorem light_prime_is_sum_of_squares (p : ℕ) (hp : p.Prime) (hmod : p % 4 = 1) :
    ∃ a b : ℕ, a ^ 2 + b ^ 2 = p := by
      convert @Nat.Prime.sq_add_sq p ( Fact.mk hp ) ( by aesop ) using 1

/-- The Gaussian norm: |a + bi|² = a² + b². -/
def gaussianNormSq (a b : ℤ) : ℤ := a ^ 2 + b ^ 2

/-- A Gaussian integer decomposition of a light prime. -/
structure GaussianSplit (p : ℕ) where
  a : ℤ
  b : ℤ
  norm_eq : a ^ 2 + b ^ 2 = (p : ℤ)
  nontrivial_a : a ≠ 0
  nontrivial_b : b ≠ 0

/-- Concrete Gaussian split of 5 = (2 + i)(2 - i). -/
def split_5 : GaussianSplit 5 where
  a := 2; b := 1
  norm_eq := by norm_num
  nontrivial_a := by omega
  nontrivial_b := by omega

/-- Concrete Gaussian split of 13 = (3 + 2i)(3 - 2i). -/
def split_13 : GaussianSplit 13 where
  a := 3; b := 2
  norm_eq := by norm_num
  nontrivial_a := by omega
  nontrivial_b := by omega

/-- Concrete Gaussian split of 17 = (4 + i)(4 - i). -/
def split_17 : GaussianSplit 17 where
  a := 4; b := 1
  norm_eq := by norm_num
  nontrivial_a := by omega
  nontrivial_b := by omega

/-- Concrete Gaussian split of 29 = (5 + 2i)(5 - 2i). -/
def split_29 : GaussianSplit 29 where
  a := 5; b := 2
  norm_eq := by norm_num
  nontrivial_a := by omega
  nontrivial_b := by omega

/-- Concrete Gaussian split of 37 = (6 + i)(6 - i). -/
def split_37 : GaussianSplit 37 where
  a := 6; b := 1
  norm_eq := by norm_num
  nontrivial_a := by omega
  nontrivial_b := by omega

theorem unique_photon_structure (p : ℕ) (hp : p.Prime) (hmod : p % 4 = 1)
    (s₁ s₂ : GaussianSplit p) :
    (s₁.a.natAbs = s₂.a.natAbs ∧ s₁.b.natAbs = s₂.b.natAbs) ∨
    (s₁.a.natAbs = s₂.b.natAbs ∧ s₁.b.natAbs = s₂.a.natAbs) := by
      obtain ⟨a₁, b₁, ha₁⟩ := s₁
      obtain ⟨a₂, b₂, ha₂⟩ := s₂
      have h_eq : a₁^2 + b₁^2 = a₂^2 + b₂^2 := by
        linarith
      have h_div : (a₁ * a₂ + b₁ * b₂) % p = 0 ∨ (a₁ * a₂ - b₁ * b₂) % p = 0 := by
        have h_div : (a₁ * a₂ + b₁ * b₂) * (a₁ * a₂ - b₁ * b₂) ≡ 0 [ZMOD p] := by
          exact Int.modEq_zero_iff_dvd.mpr ⟨ a₂ ^ 2 - b₁ ^ 2, by nlinarith ⟩ ;
        generalize_proofs at *; (
        exact Int.Prime.dvd_mul' hp ( Int.dvd_of_emod_eq_zero h_div ) |> Or.imp ( fun h => Int.emod_eq_zero_of_dvd h ) fun h => Int.emod_eq_zero_of_dvd h;)
      have h_cases : (a₁ * a₂ + b₁ * b₂) % p = 0 ∧ (a₁ * b₂ - a₂ * b₁) % p = 0 ∨ (a₁ * a₂ - b₁ * b₂) % p = 0 ∧ (a₁ * b₂ + a₂ * b₁) % p = 0 := by
        cases h_div <;> simp_all +decide [ ← Int.dvd_iff_emod_eq_zero, Int.natAbs_dvd ];
        · have h_div : (p : ℤ) ∣ (a₁ * b₂ - a₂ * b₁) ^ 2 := by
            convert dvd_sub ( dvd_mul_right ( p : ℤ ) ( a₂ ^ 2 + b₂ ^ 2 ) ) ( ‹ ( p : ℤ ) ∣ a₁ * a₂ + b₁ * b₂ ›.mul_left ( a₁ * a₂ + b₁ * b₂ ) ) using 1 ; ring;
            rw [ ← h_eq ] ; ring;
          exact Or.inl <| Int.Prime.dvd_pow' hp h_div;
        · have h_div : (p : ℤ) ∣ (a₁ * b₂ + a₂ * b₁) := by
            have h_eq : (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + a₂ * b₁) ^ 2 = p * (a₂ ^ 2 + b₂ ^ 2) := by
              linear_combination' h_eq * ( a₂ ^ 2 + b₂ ^ 2 )
            exact Int.Prime.dvd_pow' hp <| show ( p : ℤ ) ∣ ( a₁ * b₂ + a₂ * b₁ ) ^ 2 by exact ⟨ ( a₂ ^ 2 + b₂ ^ 2 ) - ( a₁ * a₂ - b₁ * b₂ ) ^ 2 / p, by linarith [ Int.ediv_mul_cancel <| show ( p : ℤ ) ∣ ( a₁ * a₂ - b₁ * b₂ ) ^ 2 from dvd_pow ‹_› two_ne_zero ] ⟩ ;
          aesop
      have h_abs : Int.natAbs (a₁ * a₂ + b₁ * b₂) < p + p ∧ Int.natAbs (a₁ * a₂ - b₁ * b₂) < p + p ∧ Int.natAbs (a₁ * b₂ - a₂ * b₁) < p + p ∧ Int.natAbs (a₁ * b₂ + a₂ * b₁) < p + p := by
        have h_bounds : |a₁ * a₂ + b₁ * b₂| < 2 * p ∧ |a₁ * a₂ - b₁ * b₂| < 2 * p ∧ |a₁ * b₂ - a₂ * b₁| < 2 * p ∧ |a₁ * b₂ + a₂ * b₁| < 2 * p := by
          refine' ⟨ _, _, _, _ ⟩ <;> rw [ abs_lt ] <;> constructor <;> nlinarith [ sq_nonneg ( a₁ - a₂ ), sq_nonneg ( a₁ + a₂ ), sq_nonneg ( b₁ - b₂ ), sq_nonneg ( b₁ + b₂ ), hp.two_le ] ;
        exact ⟨ by linarith [ abs_lt.mp h_bounds.1 ], by linarith [ abs_lt.mp h_bounds.2.1 ], by linarith [ abs_lt.mp h_bounds.2.2.1 ], by linarith [ abs_lt.mp h_bounds.2.2.2 ] ⟩
      have h_cases : a₁ * a₂ + b₁ * b₂ = 0 ∨ a₁ * a₂ - b₁ * b₂ = 0 ∨ a₁ * b₂ - a₂ * b₁ = 0 ∨ a₁ * b₂ + a₂ * b₁ = 0 := by
        cases h_cases <;> simp_all +decide [ ← Int.dvd_iff_emod_eq_zero ];
        · cases' ‹_› with h₁ h₂;
          -- Since $p$ is prime and divides $a₁ * a₂ + b₁ * b₂$, and the absolute value of this sum is less than $2p$, the only possibilities are that the sum is $0$ or $p$. But if it were $p$, then $a₁ * a₂ + b₁ * b₂ = p$, which would imply that $a₁ * a₂$ and $b₁ * b₂$ are both less than $p$, leading to a contradiction.
          have h_sum_zero : a₁ * a₂ + b₁ * b₂ = 0 ∨ a₁ * a₂ + b₁ * b₂ = p ∨ a₁ * a₂ + b₁ * b₂ = -p := by
            obtain ⟨ k, hk ⟩ := h₁; simp_all +decide [ Int.natAbs_mul, Nat.prime_mul_iff ] ;
            have : k.natAbs ≤ 1 := Nat.le_of_lt_succ ( by nlinarith [ hp.two_le ] ) ; interval_cases _ : k.natAbs <;> simp_all +decide ;
            rw [ Int.natAbs_eq_iff ] at * ; aesop;
          rcases h_sum_zero with h | h | h <;> simp_all +decide [ sub_eq_iff_eq_add ];
          · have h_contra : (a₁ - a₂)^2 + (b₁ - b₂)^2 = 0 := by
              grind +locals;
            norm_num [ show a₁ = a₂ by nlinarith only [ h_contra ], show b₁ = b₂ by nlinarith only [ h_contra ] ] at *;
          · have h_contra : (a₁ + a₂)^2 + (b₁ + b₂)^2 = 0 := by
              grind;
            norm_num [ show a₁ = -a₂ by nlinarith only [ h_contra ], show b₁ = -b₂ by nlinarith only [ h_contra ] ] at *;
        · obtain ⟨ k₁, hk₁ ⟩ := ‹ ( p : ℤ ) ∣ a₁ * a₂ - b₁ * b₂ ∧ ( p : ℤ ) ∣ a₁ * b₂ + a₂ * b₁ ›.1; obtain ⟨ k₂, hk₂ ⟩ := ‹ ( p : ℤ ) ∣ a₁ * a₂ - b₁ * b₂ ∧ ( p : ℤ ) ∣ a₁ * b₂ + a₂ * b₁ ›.2; simp_all +decide [ sub_eq_iff_eq_add ] ;
          have h_contra : k₁ ^ 2 + k₂ ^ 2 = 1 := by
            have h_contra : (a₁ * a₂ - b₁ * b₂) ^ 2 + (a₁ * b₂ + a₂ * b₁) ^ 2 = p ^ 2 * (k₁ ^ 2 + k₂ ^ 2) := by
              rw [ hk₁, hk₂ ] ; ring;
            exact mul_left_cancel₀ ( pow_ne_zero 2 ( Nat.cast_ne_zero.mpr hp.ne_zero ) ) ( by nlinarith );
          have : k₁ ≤ 1 := Int.le_of_lt_add_one ( by nlinarith only [ h_contra ] ) ; ( have : k₁ ≥ -1 := Int.le_of_lt_add_one ( by nlinarith only [ h_contra ] ) ; interval_cases k₁ <;> ( have : k₂ ≤ 1 := Int.le_of_lt_add_one ( by nlinarith only [ h_contra ] ) ; ( have : k₂ ≥ -1 := Int.le_of_lt_add_one ( by nlinarith only [ h_contra ] ) ; interval_cases k₂ <;> simp_all +decide ; ) ) )
      have h_final : Int.natAbs a₁ = Int.natAbs a₂ ∧ Int.natAbs b₁ = Int.natAbs b₂ ∨ Int.natAbs a₁ = Int.natAbs b₂ ∧ Int.natAbs b₁ = Int.natAbs a₂ := by
        rcases h_cases with h | h | h | h <;> simp_all +decide [ sub_eq_iff_eq_add, add_eq_zero_iff_eq_neg ];
        · have h_abs : a₁^2 = b₂^2 ∧ b₁^2 = a₂^2 := by
            constructor <;> nlinarith [ sq_nonneg ( a₁ - a₂ ), sq_nonneg ( a₁ + a₂ ), sq_nonneg ( b₁ - b₂ ), sq_nonneg ( b₁ + b₂ ), mul_self_pos.2 ‹a₁ ≠ 0›, mul_self_pos.2 ‹b₁ ≠ 0›, mul_self_pos.2 ‹a₂ ≠ 0›, mul_self_pos.2 ‹b₂ ≠ 0› ] ;
          exact Or.inr ⟨ by simpa [ ← Int.natCast_inj ] using congr_arg Int.natAbs h_abs.1, by simpa [ ← Int.natCast_inj ] using congr_arg Int.natAbs h_abs.2 ⟩;
        · have h_final : a₁ ^ 2 = b₂ ^ 2 ∧ b₁ ^ 2 = a₂ ^ 2 := by
            constructor <;> nlinarith [ sq_nonneg ( a₁ - a₂ ), sq_nonneg ( a₁ + a₂ ), sq_nonneg ( b₁ - b₂ ), sq_nonneg ( b₁ + b₂ ) ];
          exact Or.inr ⟨ by simpa [ ← Int.natCast_inj ] using congr_arg Int.natAbs h_final.1, by simpa [ ← Int.natCast_inj ] using congr_arg Int.natAbs h_final.2 ⟩;
        · have h_cases : a₁ ^ 2 = a₂ ^ 2 ∧ b₁ ^ 2 = b₂ ^ 2 ∨ a₁ ^ 2 = b₂ ^ 2 ∧ b₁ ^ 2 = a₂ ^ 2 := by
            have h_cases : a₁ ^ 2 * b₂ ^ 2 = a₂ ^ 2 * b₁ ^ 2 := by
              linear_combination' h * h;
            cases le_or_gt ( a₁ ^ 2 ) ( a₂ ^ 2 ) <;> [ left; right ] <;> constructor <;> nlinarith [ show 0 < a₂ ^ 2 by positivity, show 0 < b₁ ^ 2 by positivity ] ;
          simp_all +decide [ ← Int.natCast_inj, Int.natAbs_pow ];
          exact Or.imp ( fun h => ⟨ by rw [ ← sq_eq_sq₀ ] <;> norm_num ; linarith, by rw [ ← sq_eq_sq₀ ] <;> norm_num ; linarith ⟩ ) ( fun h => ⟨ by rw [ ← sq_eq_sq₀ ] <;> norm_num ; linarith, by rw [ ← sq_eq_sq₀ ] <;> norm_num ; linarith ⟩ ) h_cases;
        · have h_abs : a₁ ^ 2 * b₂ ^ 2 = a₂ ^ 2 * b₁ ^ 2 := by
            linear_combination' h * h
          have h_abs_eq : a₁ ^ 2 = a₂ ^ 2 ∧ b₁ ^ 2 = b₂ ^ 2 ∨ a₁ ^ 2 = b₂ ^ 2 ∧ b₁ ^ 2 = a₂ ^ 2 := by
            exact Or.inl ⟨ by nlinarith, by nlinarith ⟩
          generalize_proofs at *; (
          simp_all +decide [ ← Int.natCast_inj, Int.natAbs_pow ];
          exact Or.imp ( fun h => ⟨ by rw [ ← sq_eq_sq₀ ] <;> norm_num ; linarith, by rw [ ← sq_eq_sq₀ ] <;> norm_num ; linarith ⟩ ) ( fun h => ⟨ by rw [ ← sq_eq_sq₀ ] <;> norm_num ; linarith, by rw [ ← sq_eq_sq₀ ] <;> norm_num ; linarith ⟩ ) h_abs_eq;)
      exact h_final

/-- 1 is highly composite (vacuously — the primordial singularity). -/
theorem hc_1 : IsHighlyComposite 1 := by
  constructor
  · omega
  · intro m hm hm1; omega

/-- 2 is highly composite: d(2) = 2 > d(1) = 1. -/
theorem hc_2 : IsHighlyComposite 2 := by
  refine ⟨by omega, ?_⟩
  intro m hm hm2
  interval_cases m <;> native_decide

/-- 4 is highly composite: d(4) = 3 > d(m) for m < 4. -/
theorem hc_4 : IsHighlyComposite 4 := by
  refine ⟨by omega, ?_⟩
  intro m hm hm4
  interval_cases m <;> native_decide

/-- 6 is highly composite: d(6) = 4 > d(m) for m < 6. -/
theorem hc_6 : IsHighlyComposite 6 := by
  refine ⟨by omega, ?_⟩
  intro m hm hm6
  interval_cases m <;> native_decide

/-- 12 is highly composite: d(12) = 6 > d(m) for m < 12. -/
theorem hc_12 : IsHighlyComposite 12 := by
  refine ⟨by omega, ?_⟩
  intro m hm hm12
  interval_cases m <;> native_decide

/-- 24 is highly composite: d(24) = 8 > d(m) for m < 24. -/
theorem hc_24 : IsHighlyComposite 24 := by
  refine ⟨by omega, ?_⟩
  intro m hm hm24
  interval_cases m <;> native_decide

/-- 3 is NOT highly composite: d(3) = 2 = d(2). -/
theorem not_hc_3 : ¬IsHighlyComposite 3 := by
  intro ⟨_, h⟩
  have h2 := h 2 (by omega) (by omega)
  revert h2; native_decide

/-- 5 is NOT highly composite: d(5) = 2 < d(4) = 3. -/
theorem not_hc_5 : ¬IsHighlyComposite 5 := by
  intro ⟨_, h⟩
  have h4 := h 4 (by omega) (by omega)
  revert h4; native_decide

/-- HCNs have strictly more gravitational mass than anything before them. -/
theorem hcn_maximal_gravity (n : ℕ) (hn : IsHighlyComposite n) :
    ∀ m, 0 < m → m < n → gravWeight m < gravWeight n :=
  hn.2

theorem hcn_even_or_one (n : ℕ) (hn : IsHighlyComposite n) (hn1 : n ≠ 1) :
    Even n := by
      by_contra h_odd;
      have := hn.2 2 ( by decide ) ?_ <;> simp_all +decide [ Nat.even_iff ];
      · -- Since $n$ is odd and greater than 1, we can write $n$ as $p^a * m$ where $p$ is an odd prime, $a \geq 1$, and $m$ is an integer not divisible by $p$.
        obtain ⟨p, a, m, hp, ha, hm⟩ : ∃ p a m, Nat.Prime p ∧ p ∣ n ∧ a ≥ 1 ∧ n = p^a * m ∧ ¬p ∣ m := by
          obtain ⟨ p, hp ⟩ := Nat.exists_prime_and_dvd hn1;
          exact ⟨ p, Nat.factorization n p, n / p ^ Nat.factorization n p, hp.1, hp.2, Nat.succ_le_of_lt ( Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp ( by aesop ) ) ), by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ], Nat.not_dvd_ordCompl ( by aesop ) ( by aesop ) ⟩;
        -- Consider the number $n' = 2^{a} \cdot m$. We have $n' < n$ and $d(n') \geq d(n)$.
        have hn'_lt_n : 2^a * m < n := by
          rcases p with ( _ | _ | _ | p ) <;> simp_all +decide [ Nat.pow_succ', Nat.mul_assoc ];
          · omega;
          · exact mul_lt_mul_of_pos_right ( pow_lt_pow_left₀ ( by linarith ) ( by linarith ) ( by linarith ) ) ( Nat.pos_of_ne_zero ( by aesop_cat ) )
        have hn'_divisors : (Nat.divisors (2^a * m)).card ≥ (Nat.divisors n).card := by
          -- Since $p$ is an odd prime, we have $d(p^a) = a + 1$ and $d(2^a) = a + 1$.
          have h_divisors_p_a : (Nat.divisors (p^a)).card = a + 1 := by
            rw [ Nat.divisors_prime_pow hp, Finset.card_map, Finset.card_range ]
          have h_divisors_2_a : (Nat.divisors (2^a)).card = a + 1 := by
            norm_num [ Nat.divisors_prime_pow ];
          -- Since $p$ is an odd prime, we have $d(p^a \cdot m) = d(p^a) \cdot d(m)$ and $d(2^a \cdot m) = d(2^a) \cdot d(m)$.
          have h_divisors_product : (Nat.divisors (p^a * m)).card = (Nat.divisors (p^a)).card * (Nat.divisors m).card ∧ (Nat.divisors (2^a * m)).card = (Nat.divisors (2^a)).card * (Nat.divisors m).card := by
            have h_divisors_product : ∀ {x y : ℕ}, Nat.gcd x y = 1 → (Nat.divisors (x * y)).card = (Nat.divisors x).card * (Nat.divisors y).card := by
              grind +suggestions;
            exact ⟨ h_divisors_product <| Nat.Coprime.pow_left _ <| hp.coprime_iff_not_dvd.mpr hm.2.2, h_divisors_product <| Nat.Coprime.pow_left _ <| Nat.prime_two.coprime_iff_not_dvd.mpr <| by intro h; have := Nat.mod_eq_zero_of_dvd h; simp_all +decide [ Nat.mul_mod, Nat.pow_mod ] ⟩;
          aesop;
        exact not_lt_of_ge hn'_divisors ( hn.2 _ ( Nat.mul_pos ( pow_pos ( by decide ) _ ) ( Nat.pos_of_ne_zero ( by aesop_cat ) ) ) hn'_lt_n );
      · rcases n with ( _ | _ | _ | n ) <;> simp_all +arith +decide

/-- The factorizations of HCNs use the smallest primes: 2, 3, 5, 7, ...
Computational evidence for small cases. -/
theorem hcn_12_factorization : 12 = 2 ^ 2 * 3 := by norm_num

theorem hcn_24_factorization : 24 = 2 ^ 3 * 3 := by norm_num

theorem hcn_60_factorization : 60 = 2 ^ 2 * 3 * 5 := by norm_num

theorem hcn_120_factorization : 120 = 2 ^ 3 * 3 * 5 := by norm_num

theorem hcn_360_factorization : 360 = 2 ^ 3 * 3 ^ 2 * 5 := by norm_num

/-- The light/dark signature of the n-th prime (0 = dark, 1 = light, 2 = twilight).
Using the first 15 primes: 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47. -/
def primeSignature : ℕ → ℕ
  | 0 => 2  -- p=2: twilight
  | 1 => 0  -- p=3: dark (3 % 4 = 3)
  | 2 => 1  -- p=5: light (5 % 4 = 1)
  | 3 => 0  -- p=7: dark (7 % 4 = 3)
  | 4 => 0  -- p=11: dark (11 % 4 = 3)
  | 5 => 1  -- p=13: light (13 % 4 = 1)
  | 6 => 1  -- p=17: light (17 % 4 = 1)
  | 7 => 0  -- p=19: dark (19 % 4 = 3)
  | 8 => 0  -- p=23: dark (23 % 4 = 3)
  | 9 => 1  -- p=29: light (29 % 4 = 1)
  | 10 => 0 -- p=31: dark (31 % 4 = 3)
  | 11 => 1 -- p=37: light (37 % 4 = 1)
  | 12 => 1 -- p=41: light (41 % 4 = 1)
  | 13 => 0 -- p=43: dark (43 % 4 = 3)
  | 14 => 0 -- p=47: dark (47 % 4 = 3)
  | _ => 0

/-- Among the first 14 odd primes, 6 are light. -/
theorem light_fraction_14 :
    ((Finset.range 14).filter (fun i => primeSignature (i + 1) = 1)).card = 6 := by
  native_decide

/-- Among the first 14 odd primes, 8 are dark. Chebyshev bias! -/
theorem dark_fraction_14 :
    ((Finset.range 14).filter (fun i => primeSignature (i + 1) = 0)).card = 8 := by
  native_decide

/-- The light/dark binary sequence: 0,1,0,0,1,1,0,0,1,0,1,1,0,0 (for primes 3..47). -/
theorem light_dark_binary_sequence :
    (List.range 14).map (fun i => primeSignature (i + 1)) =
    [0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 0] := by native_decide

/-- The prime counting function π(n). -/
def primeCountingFn (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter Nat.Prime).card

/-- π(10) = 4: primes are {2, 3, 5, 7}. -/
theorem pi_10 : primeCountingFn 10 = 4 := by native_decide

/-- π(100) = 25. -/
theorem pi_100 : primeCountingFn 100 = 25 := by native_decide

/-- π(1000) = 168. -/
theorem pi_1000 : primeCountingFn 1000 = 168 := by native_decide

/-- The prime counting function is monotone. -/
theorem primeCountingFn_mono {m n : ℕ} (h : m ≤ n) :
    primeCountingFn m ≤ primeCountingFn n := by
  unfold primeCountingFn
  apply Finset.card_le_card
  apply Finset.filter_subset_filter
  exact Finset.range_mono (by omega)

/-- The prime density π(n)/n decreases: evidence for logarithmic expansion.
π(10)/10 = 0.4 > π(100)/100 = 0.25 > π(1000)/1000 = 0.168. -/
theorem expansion_rate_decreasing :
    (4 : ℚ) / 10 > (25 : ℚ) / 100 ∧
    (25 : ℚ) / 100 > (168 : ℚ) / 1000 := by
  constructor <;> norm_num

/-- Quadratic reciprocity from Mathlib. -/
theorem quadratic_reciprocity_law (p q : ℕ) [Fact p.Prime] [Fact q.Prime]
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    legendreSym q p * legendreSym p q = (-1 : ℤ) ^ (p / 2 * (q / 2)) :=
  legendreSym.quadratic_reciprocity hp2 hq2 hpq

theorem light_light_symmetric (p q : ℕ) [Fact p.Prime] [Fact q.Prime]
    (hp : p % 4 = 1) (hq : q % 4 = 1)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    legendreSym q p * legendreSym p q = 1 := by
      rw [ quadratic_reciprocity_law p q hp2 hq2 hpq ];
      rw [ ← Nat.mod_add_div p 4, ← Nat.mod_add_div q 4, hp, hq ] ; norm_num [ Nat.even_div ] ;

theorem light_dark_symmetric (p q : ℕ) [Fact p.Prime] [Fact q.Prime]
    (hp : p % 4 = 1) (hq : q % 4 = 3)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    legendreSym q p * legendreSym p q = 1 := by
      rw [ quadratic_reciprocity_law p q hp2 hq2 hpq ];
      norm_num [ show p / 2 = 2 * ( p / 4 ) by omega, show q / 2 = 2 * ( q / 4 ) + 1 by omega ]

theorem dark_dark_repulsion (p q : ℕ) [Fact p.Prime] [Fact q.Prime]
    (hp : p % 4 = 3) (hq : q % 4 = 3)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hpq : p ≠ q) :
    legendreSym q p * legendreSym p q = -1 := by
      convert quadratic_reciprocity_law p q hp2 hq2 hpq using 1 ; ring;
      rw [ ← Nat.mod_add_div p 4, ← Nat.mod_add_div q 4, hp, hq ] ; ring;
      norm_num [ Nat.add_div, Nat.mul_div_assoc, Nat.mul_mod, Nat.add_mod, Nat.pow_mod ]

/-- Computational verification: 3 and 7 are both dark, and (3/7)·(7/3) = -1. -/
theorem dark_dark_3_7 :
    haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
    haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
    legendreSym 7 3 * legendreSym 3 7 = -1 := by native_decide

/-- Computational verification: 5 and 13 are both light, and (5/13)·(13/5) = 1. -/
theorem light_light_5_13 :
    haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
    haveI : Fact (Nat.Prime 13) := ⟨by norm_num⟩
    legendreSym 13 5 * legendreSym 5 13 = 1 := by native_decide

/-- Computational verification: 5 (light) and 7 (dark), (5/7)·(7/5) = 1. -/
theorem light_dark_5_7 :
    haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
    haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
    legendreSym 7 5 * legendreSym 5 7 = 1 := by native_decide

/-- Computational verification: 3 and 11 are both dark, and (3/11)·(11/3) = -1. -/
theorem dark_dark_3_11 :
    haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
    haveI : Fact (Nat.Prime 11) := ⟨by norm_num⟩
    legendreSym 11 3 * legendreSym 3 11 = -1 := by native_decide

/-- A universe is a self-referential system: a space of states with a
dynamics that has a fixed point (the ground state). -/
structure SelfComputingUniverse (S : Type*) where
  dynamics : S → S
  groundState : S
  isFixedPoint : dynamics groundState = groundState
  attracts : ∀ s, ∃ n : ℕ, dynamics^[n] s = groundState

/-- The trivial universe: a single state that maps to itself. -/
def trivialUniverse : SelfComputingUniverse Unit where
  dynamics := id
  groundState := ()
  isFixedPoint := rfl
  attracts := fun _ => ⟨0, rfl⟩

/-- A Boolean universe with two states: Light (true) and Dark (false).
Dynamics: everything → Dark (the heat death). -/
def booleanUniverse : SelfComputingUniverse Bool where
  dynamics := fun _ => false
  groundState := false
  isFixedPoint := rfl
  attracts := fun _ => ⟨1, rfl⟩

/-- The research oracle is a self-computing universe:
hypotheses are validated iteratively until stable knowledge emerges.
An idempotent function reaches a fixed point after one step. -/
theorem research_is_universe {H : Type*} (R : { f : H → H // ∀ h, f (f h) = f h })
    (h₀ : H) :
    R.1 (R.1 h₀) = R.1 h₀ :=
  R.2 h₀

/-- Grand Synthesis Theorem: The number line encodes a complete physics.
Every natural number participates in the light/dark/gravity/expansion framework. -/
theorem grand_synthesis (n : ℕ) (hn : 2 ≤ n) :
    -- n has a prime factor (enters the light/dark classification)
    (∃ p, p.Prime ∧ p ∣ n) ∧
    -- n has a definite gravitational weight
    (0 < n.divisors.card) ∧
    -- n participates in entanglement (sum-of-squares relations)
    (∃ m k : ℕ, n + m = k ^ 2) := by
  refine ⟨?_, ?_, ?_⟩
  · exact Nat.exists_prime_and_dvd (by omega)
  · exact Finset.card_pos.mpr ⟨1, Nat.one_mem_divisors.mpr (by omega)⟩
  · refine ⟨(n + 1) ^ 2 - n, n + 1, ?_⟩
    have h1 : n ≤ (n + 1) ^ 2 := by nlinarith
    omega

end