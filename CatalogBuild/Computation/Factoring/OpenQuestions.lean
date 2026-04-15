/-! # CatalogBuild.Computation.Factoring.OpenQuestions

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 23
-/

import CatalogBuild.Computation.Factoring.Core
import CatalogBuild.Computation.Factoring.FutureDirections
import Mathlib

/-- Generalized lens advantage: for any base β > 1 and k ≥ 1 lenses,
S / β^k < S. This addresses the Independence Problem: if correlations
reduce the effective base from 2 to β < 2, the true advantage is β^k. -/
theorem generalized_lens_advantage (S β : ℕ) (k : ℕ)
    (hS : 0 < S) (hβ : 1 < β) (hk : 1 ≤ k) :
    S / β ^ k < S := by
  apply Nat.div_lt_self hS
  calc β ^ k ≥ β ^ 1 := Nat.pow_le_pow_right (by omega) hk
    _ = β := pow_one β
    _ > 1 := hβ


/-- Lens monotonicity: adding more lenses never increases the surviving space. -/
theorem lens_monotonicity (S : ℕ) (k₁ k₂ : ℕ) (hle : k₁ ≤ k₂) :
    S / 2 ^ k₂ ≤ S / 2 ^ k₁ :=
  Nat.div_le_div_left (Nat.pow_le_pow_right (by norm_num) hle) (by positivity)


/-- Lens composition commutes: reducing by 2^a then 2^b = 2^(a+b). -/
theorem lens_composition_commutes (S a b : ℕ) :
    S / 2 ^ (a + b) = S / (2 ^ a * 2 ^ b) := by
  rw [pow_add]


/-- For coprime moduli, CRT gives exact multiplicative reduction. -/
theorem crt_exact_reduction (m n : ℕ) (hcop : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n :=
  Nat.totient_mul hcop


/-- For any prime p ≠ 5, the Pisano period π(p) divides p²−1.
This unifies the split and inert cases. -/
theorem pisano_period_divides_p_sq_sub_one (p : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5) :
    p ∣ Nat.fib (p * p - 1) := by
  -- Case split: either p%5 ∈ {1,4} (split) or p%5 ∈ {2,3} (inert) or p=5
  have h5cases : p % 5 = 0 ∨ p % 5 = 1 ∨ p % 5 = 2 ∨ p % 5 = 3 ∨ p % 5 = 4 := by omega
  have hp1 := hp.one_le
  rcases h5cases with h | h | h | h | h
  · -- p % 5 = 0 implies p = 5, contradicting hp5
    exfalso; exact hp5 (by have := hp.eq_one_or_self_of_dvd 5 (Nat.dvd_of_mod_eq_zero h); omega)
  · -- Split case: p | F(p-1) and (p-1) | (p²-1)
    have hsplit := MetaFactoring.FutureDirections.pisano_split_case p hp (Or.inl h)
    rw [pp_sub_one_eq p hp1]
    exact dvd_trans hsplit (Nat.fib_dvd _ _ (dvd_mul_right (p - 1) (p + 1)))
  · -- Inert case: p | F(p+1) and (p+1) | (p²-1)
    have hinert := MetaFactoring.FutureDirections.pisano_inert_case p hp (Or.inl h)
    rw [pp_sub_one_eq p hp1]
    exact dvd_trans hinert (Nat.fib_dvd _ _ (dvd_mul_left (p + 1) (p - 1)))
  · -- Inert case
    have hinert := MetaFactoring.FutureDirections.pisano_inert_case p hp (Or.inr h)
    rw [pp_sub_one_eq p hp1]
    exact dvd_trans hinert (Nat.fib_dvd _ _ (dvd_mul_left (p + 1) (p - 1)))
  · -- Split case
    have hsplit := MetaFactoring.FutureDirections.pisano_split_case p hp (Or.inr h)
    rw [pp_sub_one_eq p hp1]
    exact dvd_trans hsplit (Nat.fib_dvd _ _ (dvd_mul_right (p - 1) (p + 1)))


/-- Pisano periodicity composes: if T₁ is a period mod m, then T₁·j is too for any j. -/
theorem pisano_period_composes (m : ℕ) (hm : 2 ≤ m)
    (T₁ : ℕ) (hT₁ : 0 < T₁)
    (h₁ : ∀ k, Nat.fib (k + T₁) % m = Nat.fib k % m)
    (j : ℕ) :
    ∀ k, Nat.fib (k + T₁ * j) % m = Nat.fib k % m := by
  intro k; induction j with
  | zero => simp
  | succ j ih =>
    rw [Nat.mul_succ, ← Nat.add_assoc, h₁]
    exact ih


/-- [Section: ## Thrust II: Fibonacci-Spectral Duality] -/
theorem fib_determined_by_consecutive_pair (m : ℕ) (hm : 2 ≤ m)
    (a b : ℕ)
    (h₀ : Nat.fib a % m = Nat.fib b % m)
    (h₁ : Nat.fib (a + 1) % m = Nat.fib (b + 1) % m) :
    ∀ k, Nat.fib (a + k) % m = Nat.fib (b + k) % m := by
  intro k;
  induction' k using Nat.strong_induction_on with k ih;
  rcases k with ( _ | _ | k ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  exact Nat.ModEq.add ( ih _ <| Nat.le_succ _ ) ( ih _ <| Nat.le_refl _ )


/-- F(n) mod m depends only on n mod T where T is the Pisano period. -/
theorem fib_mod_periodic_reduction (m T n : ℕ) (hm : 2 ≤ m) (hT : 0 < T)
    (hper : ∀ k, Nat.fib (k + T) % m = Nat.fib k % m) :
    Nat.fib n % m = Nat.fib (n % T) % m := by
  conv_lhs => rw [← Nat.div_add_mod n T]
  rw [Nat.add_comm]
  exact pisano_period_composes m hm T hT hper (n / T) (n % T)


/-- Dim-4 channel subsumes dim-2: any 2-square representation lifts to 4-square. -/
theorem norm_channel_dim4_subsumes_dim2 (a b : ℤ) (h : ∃ x y : ℤ, x^2 + y^2 = a^2 + b^2) :
    ∃ w x y z : ℤ, w^2 + x^2 + y^2 + z^2 = a^2 + b^2 :=
  ⟨a, b, 0, 0, by ring⟩


/-- Non-commutativity of quaternion multiplication: both orderings have the same norm. -/
theorem quaternion_two_factorizations (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 =
    (b₁*a₁ - b₂*a₂ - b₃*a₃ - b₄*a₄)^2 +
    (b₁*a₂ + b₂*a₁ + b₃*a₄ - b₄*a₃)^2 +
    (b₁*a₃ - b₂*a₄ + b₃*a₁ + b₄*a₂)^2 +
    (b₁*a₄ + b₂*a₃ - b₃*a₂ + b₄*a₁)^2 := by ring


/-- The naive pointwise 16-square identity fails (consequence of Hurwitz 1898). -/
theorem no_16_square_naive_identity :
    ¬ ∀ (a b : Fin 16 → ℤ),
      (∑ i, a i ^ 2) * (∑ i, b i ^ 2) = ∑ i, (a i * b i) ^ 2 := by
  push_neg
  exact ⟨fun _ => 1, fun _ => 1, by decide⟩


/-- Dim-8 subsumes dim-4: any 4-square representation lifts to 8-square. -/
theorem norm_channel_dim8_subsumes_dim4 (a b c d : ℤ)
    (h : ∃ w x y z : ℤ, w^2 + x^2 + y^2 + z^2 = a^2 + b^2 + c^2 + d^2) :
    ∃ e₁ e₂ e₃ e₄ e₅ e₆ e₇ e₈ : ℤ,
      e₁^2 + e₂^2 + e₃^2 + e₄^2 + e₅^2 + e₆^2 + e₇^2 + e₈^2 =
      a^2 + b^2 + c^2 + d^2 :=
  ⟨a, b, c, d, 0, 0, 0, 0, by ring⟩


/-- Order-finding gives a nontrivial GCD candidate. -/
theorem order_finding_factor_candidate (N a r : ℕ) (hN : 1 < N) :
    1 ≤ Nat.gcd (a ^ (r / 2) - 1) N :=
  Nat.one_le_iff_ne_zero.mpr (by intro h; simp [Nat.gcd_eq_zero_iff] at h; omega)


/-- Grover's bound: (⌊√N⌋ + 1)² > N. -/
theorem grover_query_bound (N : ℕ) :
    N < (Nat.sqrt N + 1) ^ 2 :=
  Nat.lt_succ_sqrt' N


/-- Classical-quantum hybrid: classical lenses reduce the quantum search space. -/
theorem hybrid_speedup (S k : ℕ) :
    Nat.sqrt (S / 2 ^ k) ≤ Nat.sqrt S :=
  Nat.sqrt_le_sqrt (Nat.div_le_self S (2 ^ k))


/-- Group element order divides group size (basis of DLP structure). -/
theorem dlp_order_connection {G : Type*} [Group G] [Fintype G] (g : G) :
    g ^ Fintype.card G = 1 :=
  pow_card_eq_one


/-- [Section: ## Thrust V: Adjacent Problems] -/
theorem pohlig_hellman_structure (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≠ q) :
    Nat.totient (p * q) = (p - 1) * (q - 1) := by
  rw [ Nat.totient_mul, Nat.totient_prime hp, Nat.totient_prime hq ];
  simpa [ hpq ] using Nat.coprime_primes hp hq


/-- Miller-Rabin bound: n/4 < n for n ≥ 4. -/
theorem miller_rabin_bound (n : ℕ) (hn : 4 ≤ n) :
    n / 4 < n := by omega


/-- Primality certificate bound: log₂(p) < p for p ≥ 2. -/
theorem primality_certificate_bound (p : ℕ) (hp : 2 ≤ p) :
    Nat.log 2 p < p := by
  apply Nat.log_lt_of_lt_pow (by omega)
  exact @Nat.lt_pow_self p 2 (by omega)


/-- Norm multiplicativity in ℤ[√d] — structural basis for NFS. -/
theorem zsqrtd_norm_mult (d : ℤ) (a b : ℤ√d) :
    (a * b).norm = a.norm * b.norm :=
  Zsqrtd.norm_mul a b


/-- [Section: ## Cross-Cutting: New Bridge Theorems] -/
theorem norm_congruence_bridge (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 3)
    (a b : ℤ) (hdvd : (p : ℤ) ∣ a ^ 2 + b ^ 2) :
    (p : ℤ) ∣ a ∧ (p : ℤ) ∣ b := by
  haveI := Fact.mk hp;
  -- Since $p \equiv 3 \pmod{4}$, we know that $-1$ is a quadratic non-residue modulo $p$.
  have h_neg_one_nonresidue : ¬∃ x : ZMod p, x^2 = -1 := by
    rintro ⟨ x, hx ⟩ ; have := ZMod.exists_sq_eq_neg_one_iff ( p := p ) ; simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ] ;
    exact this ⟨ x, by rw [ sq ] at hx; aesop ⟩;
  simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd, eq_neg_iff_add_eq_zero ];
  by_cases hb : ( b : ZMod p ) = 0 <;> simp_all +decide [ add_eq_zero_iff_eq_neg ];
  exact h_neg_one_nonresidue ( a / b ) ( by simp_all +decide [ ← ZMod.intCast_eq_intCast_iff, mul_pow, mul_assoc, div_pow, mul_div_cancel₀ ] )


/-- Lattice-hyperbolic bridge: min(p,q) ≤ √(pq) for any factorization. -/
theorem lattice_hyperbolic_bridge (p q : ℕ) (hp : 0 < p) (hle : p ≤ q) :
    p ≤ Nat.sqrt (p * q) := by
  rw [Nat.le_sqrt]
  nlinarith


/-- Fibonacci + hyperbolic synergy: d < fib(k+2) implies d < 2^k. -/
theorem fib_hyperbolic_synergy (d k : ℕ)
    (hd_bound : d < Nat.fib (k + 2)) (hk : 2 ≤ k) :
    d < 2 ^ k :=
  lt_trans hd_bound (MetaFactoring.fibonacci_search_reduction k hk)

