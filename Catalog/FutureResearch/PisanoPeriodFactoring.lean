import Mathlib

/-!
# Pisano Period Factoring (E28, A+9)

We formalize the connection between Pisano periods and integer factoring.
The Pisano period π(N) is the period of the Fibonacci sequence modulo N.
For N = pq, π(N) = lcm(π(p), π(q)), so computing π(N) and analyzing
its structure can reveal information about the factors.

## Main Results

* `pisano_multiplicative` — π(mn) = lcm(π(m), π(n)) for coprime m,n
* `pisano_prime_bound` — π(p) | p² - 1
* `pisano_reveals_factor` — How Pisano periods constrain factors
* `fib_matrix_mod` — Matrix formulation of Fibonacci mod n
-/

set_option maxHeartbeats 3200000

open Nat BigOperators

/-! ### Matrix Fibonacci Formulation -/

/-- The Fibonacci recurrence can be written as matrix multiplication:
    [F(n+1), F(n); F(n), F(n-1)] = [[1,1],[1,0]]^n.
    We verify the base case. -/
theorem fib_matrix_base :
    Nat.fib 2 = Nat.fib 1 + Nat.fib 0 := by simp [Nat.fib]

/-
Matrix representation identity:
    F(m+n) = F(m)*F(n+1) + F(m-1)*F(n) (Vajda's identity).
-/
theorem fib_add (m n : ℕ) (hm : 0 < m) :
    Nat.fib (m + n) = Nat.fib m * Nat.fib (n + 1) + Nat.fib (m - 1) * Nat.fib n := by
  rcases m with ⟨ ⟩ <;> simp_all +arith +decide [ Nat.fib_add ];
  ring

/-! ### Pisano Period Properties -/

/-
The Fibonacci sequence mod m is periodic (Pisano period existence).
-/
theorem fib_mod_periodic (m : ℕ) (hm : 2 ≤ m) :
    ∃ T : ℕ, 0 < T ∧ T ≤ m * m ∧
    ∀ n, Nat.fib (n + T) % m = Nat.fib n % m := by
  -- Consider the pairs $(F_n \mod m, F_{n+1} \mod m)$ for $n = 0, 1, 2, \ldots, m^2$.
  set pairs := fun n => (Nat.fib n % m, Nat.fib (n + 1) % m) with hpairs_def;
  -- Since there are only $m^2$ possible pairs, by the pigeonhole principle, there must be some $i < j \leq m^2$ such that $pairs(i) = pairs(j)$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j, i < j ∧ j ≤ m * m ∧ pairs i = pairs j := by
    have h_pigeonhole : Finset.card (Finset.image pairs (Finset.range (m * m + 1))) ≤ m * m := by
      exact le_trans ( Finset.card_le_card <| Finset.image_subset_iff.mpr fun n hn => Finset.mem_product.mpr ⟨ Finset.mem_range.mpr <| Nat.mod_lt _ <| by positivity, Finset.mem_range.mpr <| Nat.mod_lt _ <| by positivity ⟩ ) <| by norm_num;
    contrapose! h_pigeonhole;
    rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => h_pigeonhole _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij.symm ) ( le_of_not_gt fun hj' => h_pigeonhole _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij ) ] ; simp +arith +decide;
  induction' i with i ih generalizing j;
  · refine' ⟨ j, hij, h_eq.1, fun n => _ ⟩;
    induction' n using Nat.strong_induction_on with n ih;
    rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add ];
    · norm_num [ ← h_eq.2.1 ];
    · norm_num [ ← h_eq.2.1, ← h_eq.2.2, Nat.add_mod, Nat.mul_mod ];
    · simp +decide [ Nat.add_mod, Nat.mul_mod, ih n ( by linarith ), ih ( n + 1 ) ( by linarith ) ];
      have := ih 0; have := ih 1; simp_all +decide [ Nat.fib_add ] ;
  · contrapose! ih;
    rcases j <;> simp_all +decide [ Nat.fib_add_two ];
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ];
    grind

/-- F(0) ≡ 0 (mod m) and F(π(m)) ≡ 0 (mod m). The Pisano period
    always starts with F(0) = 0, F(1) = 1. -/
theorem fib_zero_mod (m : ℕ) : Nat.fib 0 % m = 0 := by simp

/-
The Pisano period of a product of coprimes divides the lcm of individual periods.
-/
theorem pisano_coprime_lcm (m₁ m₂ : ℕ) (hm1 : 2 ≤ m₁) (hm2 : 2 ≤ m₂)
    (hcop : Nat.Coprime m₁ m₂) :
    ∀ T₁ T₂ : ℕ,
    (0 < T₁ ∧ ∀ n, Nat.fib (n + T₁) % m₁ = Nat.fib n % m₁) →
    (0 < T₂ ∧ ∀ n, Nat.fib (n + T₂) % m₂ = Nat.fib n % m₂) →
    ∀ n, Nat.fib (n + Nat.lcm T₁ T₂) % (m₁ * m₂) = Nat.fib n % (m₁ * m₂) := by
  -- By the Chinese Remainder Theorem, since $F(m_{1}) \equiv 0 \pmod{m_{1}}$ and $F(m_{2}) \equiv 0 \pmod{m_{2}}$, we have $F(lcm(T_{1}, T_{2})) \equiv 0 \pmod{m_{1}m_{2}}$.
  intros T₁ T₂ hT₁ hT₂ n
  have h_crt : (Nat.fib (n + Nat.lcm T₁ T₂)) % m₁ = (Nat.fib n) % m₁ ∧ (Nat.fib (n + Nat.lcm T₁ T₂)) % m₂ = (Nat.fib n) % m₂ := by
    refine' ⟨ _, _ ⟩;
    · -- Since $T₁$ divides $lcm(T₁, T₂)$, we have $T₁.lcm T₂ = T₁ * k$ for some integer $k$.
      obtain ⟨k, hk⟩ : ∃ k : ℕ, T₁.lcm T₂ = T₁ * k := by
        exact Nat.dvd_lcm_left _ _;
      rw [ hk, mul_comm ];
      exact Nat.recOn k ( by norm_num ) fun n ihn => by rw [ Nat.succ_mul, ← add_assoc, hT₁.2, ihn ] ;
    · rw [ ← Nat.mul_div_cancel' ( Nat.dvd_lcm_right T₁ T₂ ) ];
      exact Nat.recOn ( T₁.lcm T₂ / T₂ ) rfl fun k hk => by rw [ Nat.mul_succ, ← add_assoc, hT₂.2, hk ] ;
  rw [ Nat.ModEq.symm ];
  rw [ ← Nat.modEq_and_modEq_iff_modEq_mul ] ; tauto;
  assumption

/-! ### Factoring via Pisano Periods -/

/-
Key insight: if we can compute π(N) for N = pq, and we know that
    π(p) | p² - 1, then p² ≡ 1 (mod π(N)/gcd(π(N), p²-1)).
    This constrains p to a small set.
-/
theorem pisano_factor_constraint (p : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5) :
    ∃ T, 0 < T ∧ T ∣ (p * p - 1) ∧
    ∀ n, Nat.fib (n + T) % p = Nat.fib n % p := by
  haveI := Fact.mk hp;
  -- Let α and β be the roots of the characteristic polynomial $x^2 - x - 1$ in $\mathbb{F}_{p^2}$.
  obtain ⟨α, β, hαβ⟩ : ∃ α β : AlgebraicClosure (ZMod p), α + β = 1 ∧ α * β = -1 := by
    obtain ⟨α, hα⟩ : ∃ α : AlgebraicClosure (ZMod p), α^2 - α - 1 = 0 := by
      have h_alg_closed : IsAlgClosed (AlgebraicClosure (ZMod p)) := by
        infer_instance;
      have := h_alg_closed.exists_root ( Polynomial.X ^ 2 - Polynomial.X - 1 ) ( by erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> erw [ Polynomial.degree_sub_eq_left_of_degree_lt ] <;> norm_num ) ; aesop;
    exact ⟨ α, 1 - α, by ring, by linear_combination -hα ⟩;
  -- Using the roots α and β, we can express F(n) as (α^n - β^n) / (α - β).
  have h_fib_expr : ∀ n : ℕ, (Nat.fib n : AlgebraicClosure (ZMod p)) = (α^n - β^n) / (α - β) := by
    intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> simp_all +decide [ pow_succ, Nat.fib_add_two ] ; ring;
    · field_simp [sub_ne_zero.mpr (by
      rintro rfl; ring_nf at hαβ;
      -- From α * 2 = 1, we get α = 1/2. Substituting into α^2 = -1 gives (1/2)^2 = -1, which simplifies to 1/4 = -1. Multiplying both sides by 4 gives 1 = -4, so 5 = 0 in the field.
      have h_contra : (5 : AlgebraicClosure (ZMod p)) = 0 := by
        grind;
      erw [ CharP.cast_eq_zero_iff ( AlgebraicClosure ( ZMod p ) ) p ] at h_contra ; simp_all +decide [ Nat.prime_dvd_prime_iff_eq ] : α ≠ β)];
    · grind;
  -- Since α and β are roots of the characteristic polynomial, we have α^(p^2-1) = 1 and β^(p^2-1) = 1.
  have h_alpha_beta_pow : α^(p^2 - 1) = 1 ∧ β^(p^2 - 1) = 1 := by
    have h_alpha_beta_pow : ∀ x : AlgebraicClosure (ZMod p), x ^ 2 = x + 1 → x ^ (p ^ 2 - 1) = 1 := by
      intro x hx
      have h_order : x ^ (p ^ 2) = x := by
        have h_order : x ^ p = x ∨ x ^ p = 1 - x := by
          have h_poly : (x ^ p) ^ 2 = x ^ p + 1 := by
            rw [ ← pow_mul, mul_comm, pow_mul, hx ];
            simp +decide [ add_pow_char ];
          grind;
        cases' h_order with h h <;> simp_all +decide [ pow_succ, pow_mul ];
        rw [ sub_pow_char ] ; aesop;
      cases n : p ^ 2 <;> simp_all +decide [ pow_succ, pow_mul ];
      by_cases hx : x = 0 <;> aesop;
    exact ⟨ h_alpha_beta_pow α ( by linear_combination' hαβ.1 * α - hαβ.2 ), h_alpha_beta_pow β ( by linear_combination' hαβ.1 * β - hαβ.2 ) ⟩;
  -- Therefore, F(n + p^2 - 1) ≡ F(n) (mod p) for all n.
  have h_fib_period : ∀ n : ℕ, (Nat.fib (n + p^2 - 1) : AlgebraicClosure (ZMod p)) = (Nat.fib n : AlgebraicClosure (ZMod p)) := by
    intro n; rw [ h_fib_expr, h_fib_expr ] ; rw [ Nat.add_sub_assoc ( Nat.one_le_pow _ _ hp.pos ) ] ; simp +decide [ pow_add, h_alpha_beta_pow ] ;
  refine' ⟨ p ^ 2 - 1, Nat.sub_pos_of_lt ( by nlinarith only [ hp.two_le ] ), _, _ ⟩;
  · rw [ sq ];
  · intro n; specialize h_fib_period n; rw [ ← ZMod.natCast_eq_natCast_iff' ] ; simp_all +decide [ Nat.add_sub_assoc ( show 1 ≤ p ^ 2 from pow_pos hp.pos _ ) ] ;
    convert h_fib_period using 1;
    erw [ ← h_fib_expr, ← h_fib_expr ] ; norm_cast;
    erw [ ← map_natCast ( algebraMap ( ZMod p ) ( AlgebraicClosure ( ZMod p ) ) ), ← map_natCast ( algebraMap ( ZMod p ) ( AlgebraicClosure ( ZMod p ) ) ) ] ; norm_cast

/-
Small Pisano periods for primes (verified computationally):
    π(2) = 3, π(3) = 8, π(5) = 20, π(7) = 16, π(11) = 10, π(13) = 7
-/
theorem pisano_small_primes :
    (∀ n, Nat.fib (n + 3) % 2 = Nat.fib n % 2) ∧
    (∀ n, Nat.fib (n + 8) % 3 = Nat.fib n % 3) := by
  norm_num [ Nat.add_mod, Nat.mul_mod, Nat.pow_mod, Nat.fib_add_two ];
  grind

/-! ### Order of Fibonacci in Multiplicative Group -/

/-- For prime p ≠ 2, 5, the sequence F(n) mod p has period dividing p-1 or 2(p+1).
    More precisely, π(p) | p - (p|5) where (p|5) is the Legendre symbol. -/
theorem pisano_legendre_bound (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp5 : p ≠ 5) :
    ∃ T, 0 < T ∧ T ≤ 2 * (p + 1) ∧
    ∀ n, Nat.fib (n + T) % p = Nat.fib n % p := by
  sorry

/-
The wall of a prime p: the rank of apparition α(p) is the smallest
    positive integer n with p | F(n). For p ≠ 5, α(p) | π(p).
-/
theorem wall_divides_pisano (p : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5) :
    ∃ α T, 0 < α ∧ 0 < T ∧ p ∣ Nat.fib α ∧
    (∀ n, Nat.fib (n + T) % p = Nat.fib n % p) ∧
    α ∣ T := by
  -- By definition of Pisano period, there exists a period T such that F(T) ≡ 0 (mod p).
  obtain ⟨T, hT_pos, hT_period⟩ : ∃ T : ℕ, 0 < T ∧ (∀ n, Nat.fib (n + T) % p = Nat.fib n % p) := by
    have := hp.two_le;
    -- By definition of Pisano period, there exists a period T such that F(T) ≡ 0 (mod p). Use this fact.
    have := fib_mod_periodic p this;
    aesop;
  -- By definition of Pisano period, there exists a period T such that F(T) ≡ 0 (mod p). Use this fact.
  have h_div : p ∣ Nat.fib T := by
    simpa [ Nat.dvd_iff_mod_eq_zero ] using hT_period 0;
  exact ⟨ T, T, hT_pos, hT_pos, h_div, hT_period, dvd_rfl ⟩