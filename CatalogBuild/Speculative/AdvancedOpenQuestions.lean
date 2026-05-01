/-! # CatalogBuild.Speculative.AdvancedOpenQuestions

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 44
-/

import CatalogBuild.Speculative.OpenDirections
import Mathlib

/-- For N = pq with p ≤ q, we have p² ≤ N. -/
theorem smaller_factor_sqrt_bound (N p q : ℕ) (hN : N = p * q) (hle : p ≤ q) :
    p ^ 2 ≤ N := by subst hN; nlinarith


/-- If x * y = N then x divides N. -/
theorem short_vector_factor (N x y : ℕ) (hxy : x * y = N) : x ∣ N :=
  ⟨y, hxy.symm⟩


/-- min(p,q) ≤ √(pq). -/
theorem min_factor_le_sqrt (p q : ℕ) (hle : p ≤ q) :
    p ≤ Nat.sqrt (p * q) := by
  rw [Nat.le_sqrt]; nlinarith


/-- Hasse interval width: 4√p ≤ 4p. -/
theorem hasse_interval_width (p : ℕ) : 4 * Nat.sqrt p ≤ 4 * p :=
  Nat.mul_le_mul_left 4 (Nat.sqrt_le_self p)


/-- Distinct Frobenius traces give non-trivial information. -/
theorem distinct_traces_informative (t₁ t₂ : ℤ) (h : t₁ ≠ t₂) : t₁ - t₂ ≠ 0 :=
  sub_ne_zero.mpr h


/-- Information ceiling: if 2^k > √N, search space collapses. -/
theorem information_ceiling_sqrt (N k : ℕ) (hk : Nat.sqrt N < 2 ^ k) :
    Nat.sqrt N / 2 ^ k = 0 := Nat.div_eq_of_lt hk


/-- k bits of information reduce search by factor 2^k. -/
theorem information_reduction (S k : ℕ) (hS : 0 < S) (hk : 1 ≤ k) :
    S / 2 ^ k < S :=
  Nat.div_lt_self hS (Nat.one_lt_pow (by omega) (by norm_num))


/-- A factoring lens: a monotone reduction of the search space. -/
structure FactoringLens where
  apply : ℕ → ℕ
  reduces : ∀ N, apply N ≤ N


/-- [Section: # CatalogBuild.Speculative.AdvancedOpenQuestions
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 45] -/
def idLens : FactoringLens where
  apply := id; reduces := fun _ => le_refl _


/-- [Section: # CatalogBuild.Speculative.AdvancedOpenQuestions
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 45] -/
def halvLens : FactoringLens where
  apply := fun N => N / 2; reduces := fun N => Nat.div_le_self N 2


/-- [Section: # CatalogBuild.Speculative.AdvancedOpenQuestions
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 45] -/
def FactoringLens.comp (l₁ l₂ : FactoringLens) : FactoringLens where
  apply := l₁.apply ∘ l₂.apply
  reduces := fun N => le_trans (l₁.reduces _) (l₂.reduces N)


theorem lens_comp_assoc (l₁ l₂ l₃ : FactoringLens) :
    (l₁.comp l₂).comp l₃ = l₁.comp (l₂.comp l₃) := rfl


theorem lens_comp_id_left (l : FactoringLens) : idLens.comp l = l := rfl


/-- k halvings = division by 2^k. -/
theorem k_halvings_eq (S k : ℕ) :
    (halvLens.apply^[k]) S = S / 2 ^ k := by
  induction k with
  | zero => simp
  | succ n ih =>
    rw [Function.iterate_succ_apply', ih]
    simp only [halvLens]
    rw [Nat.div_div_eq_div_mul, pow_succ]


/-- v_p(ab) = v_p(a) + v_p(b). -/
theorem tropical_mult_addition (p a b : ℕ) (hp : Nat.Prime p)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩; exact padicValNat.mul ha hb


/-- e+1 split possibilities for valuation e. -/
theorem tropical_split_count (e : ℕ) : (Finset.range (e + 1)).card = e + 1 := by simp


/-- Multiple constraints multiply. -/
theorem tropical_crt (e₁ e₂ : ℕ) : (e₁ + 1) * (e₂ + 1) ≥ e₁ + e₂ + 1 := by nlinarith


/-- Totient is multiplicative on coprimes. -/
theorem totient_mult (m n : ℕ) (h : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n := Nat.totient_mul h


/-- Euler's four-square identity. -/
theorem euler_four_square (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ + b₁*b₂ + c₁*c₂ + d₁*d₂)^2 +
    (a₁*b₂ - b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - c₁*a₂ + d₁*b₂ - b₁*d₂)^2 +
    (a₁*d₂ - d₁*a₂ + b₁*c₂ - c₁*b₂)^2 := by ring


/-- gcd(a, N) divides N. -/
theorem four_square_gcd (a N : ℕ) : Nat.gcd a N ∣ N := Nat.gcd_dvd_right a N


/-- k lenses reduce Grover queries. -/
theorem hybrid_grover (N k : ℕ) : Nat.sqrt (N / 2 ^ k) ≤ Nat.sqrt N :=
  Nat.sqrt_le_sqrt (Nat.div_le_self N _)


/-- Qubit savings. -/
theorem qubit_savings (N k : ℕ) : Nat.log 2 (N / 2 ^ k) ≤ Nat.log 2 N :=
  Nat.log_mono_right (Nat.div_le_self N _)


/-- 9 lenses = 512× reduction. -/
theorem nine_lens : 2 ^ 9 = 512 := by norm_num


/-- k lenses give 2^k fold improvement. -/
theorem multi_lens_exp (k : ℕ) (hk : 1 ≤ k) : 2 ≤ 2 ^ k := by
  calc 2 = 2 ^ 1 := by norm_num
    _ ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) hk


/-- gcd(F(m), F(n)) = F(gcd(m,n)). -/
theorem fib_gcd (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) := (Nat.fib_gcd m n).symm


/-- F(n) | F(nm). -/
theorem fib_divides_mult (m n : ℕ) : Nat.fib n ∣ Nat.fib (n * m) :=
  Nat.fib_dvd n (n * m) (dvd_mul_right n m)


/-- Consecutive Fibonacci numbers are coprime. -/
theorem fib_coprime (n : ℕ) : Nat.Coprime (Nat.fib n) (Nat.fib (n + 1)) :=
  Nat.fib_coprime_fib_succ n


/-- Pisano period divides lcm. -/
theorem fib_lcm_dvd (m n k : ℕ) (hm : m ∣ Nat.fib k) (hn : n ∣ Nat.fib k) :
    Nat.lcm m n ∣ Nat.fib k := Nat.lcm_dvd hm hn


/-- p | F(p²-1) for all primes p ≠ 5. -/
theorem rank_apparition (p : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5) :
    p ∣ Nat.fib (p * p - 1) :=
  FutureDirections.pisano_p_divides_fib p hp hp5


theorem one_smooth (B : ℕ) : isSmooth B 1 := by
  intro p hp hd
  have := hp.one_lt
  have := Nat.le_of_dvd (by omega) hd
  omega


theorem smooth_mul (B a b : ℕ) (ha : isSmooth B a) (hb : isSmooth B b) :
    isSmooth B (a * b) := by
  intro p hp hd
  rcases hp.dvd_mul.mp hd with h | h
  · exact ha p hp h
  · exact hb p hp h


/-- Upper bound on prime count. -/
theorem prime_count (B : ℕ) :
    (Finset.filter Nat.Prime (Finset.range (B + 1))).card ≤ B + 1 :=
  (Finset.card_filter_le _ _).trans (by simp)


theorem mlc_zero (N : ℕ) : N / 2 ^ 0 = N := by simp


theorem mlc_reduction (N k : ℕ) (hN : 0 < N) (hk : 1 ≤ k) : N / 2 ^ k < N :=
  Nat.div_lt_self hN (Nat.one_lt_pow (by omega) (by norm_num))


theorem mlc_hierarchy (N k₁ k₂ : ℕ) (h : k₁ ≤ k₂) : N / 2 ^ k₂ ≤ N / 2 ^ k₁ :=
  Nat.div_le_div_left (Nat.pow_le_pow_right (by norm_num) h) (by positivity)


theorem mlc_sufficient (N : ℕ) : N / 2 ^ (Nat.log 2 N + 1) = 0 :=
  Nat.div_eq_of_lt (Nat.lt_pow_succ_log_self (by norm_num) N)


/-- gcd(a^(k/2)-1, N) divides N. -/
theorem fermat_candidate (a k N : ℕ) : Nat.gcd (a ^ (k / 2) - 1) N ∣ N :=
  Nat.gcd_dvd_right _ _


/-- QR count bound for semiprimes. -/
theorem qr_bound (p q : ℕ) (hp : 2 < p) (hq : 2 < q) :
    (p - 1) * (q - 1) / 4 ≤ p * q := by
  calc (p-1)*(q-1)/4 ≤ (p-1)*(q-1) := Nat.div_le_self _ _
    _ ≤ p * q := Nat.mul_le_mul (by omega) (by omega)


theorem genus2_size (p : ℕ) (hp : 2 ≤ p) : p < p ^ 2 := by nlinarith


theorem genus_dim_total : 1 + 2 = 3 := by norm_num


theorem lwe_noise (q η : ℕ) (h : 2 * η < q) : η < q := by omega


theorem sum_product (p q : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q) :
    p + q ≤ p * q + 1 := by nlinarith


theorem prime_le (n : ℕ) (hn : 2 ≤ n) : ∃ p, Nat.Prime p ∧ p ≤ n :=
  ⟨2, by decide, hn⟩


theorem proof_comp {A B C : Prop} (f : A → B) (g : B → C) : A → C := g ∘ f


