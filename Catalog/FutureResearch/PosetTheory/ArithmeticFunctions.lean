import Mathlib

/-!
# Arithmetic Functions and Multiplicative Theory — v10

## Main Results

* `totient_prime` — φ(p) = p - 1
* `totient_multiplicative` — φ is multiplicative
* `totient_prime_pow` — φ(p^k) = p^k - p^(k-1)
* `tau_prime` — τ(p) = 2
* `tau_one` — τ(1) = 1
* `tau_prime_pow` — τ(p^k) = k + 1
* `tau_multiplicative` — τ is multiplicative
* `mobius_at_prime` — μ(p) = -1
* `mobius_inversion_statement` — Möbius inversion formula
* `triperfect_120` — 120 is 3-perfect
* `triperfect_672` — 672 is 3-perfect
* `abundant_12` — 12 is abundant
* `prime_deficient` — All primes are deficient
* `smallest_abundant` — 12 is the smallest abundant number
-/

set_option maxHeartbeats 8000000

open Nat BigOperators Finset

/-! ### Euler's Totient Function -/

/-- φ(p) = p - 1 for prime p. -/
theorem totient_prime' (p : ℕ) (hp : Nat.Prime p) : Nat.totient p = p - 1 :=
  Nat.totient_prime hp

/-- φ is multiplicative for coprime arguments. -/
theorem totient_multiplicative' (m n : ℕ) (hcop : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n :=
  Nat.totient_mul hcop

/-
φ(p^k) = p^k - p^(k-1) for prime p and k ≥ 1.
-/
theorem totient_prime_pow (p k : ℕ) (hp : Nat.Prime p) (hk : 0 < k) :
    Nat.totient (p ^ k) = p ^ k - p ^ (k - 1) := by
  rw [ Nat.totient_prime_pow hp hk ];
  rw [ mul_tsub, mul_one, ← pow_succ, Nat.sub_add_cancel hk ]

/-! ### Divisor Count Function -/

/-- τ(n) = |{d : d | n}| -/
noncomputable def tau (n : ℕ) : ℕ := n.divisors.card

/-- τ(p) = 2 for prime p. -/
theorem tau_prime (p : ℕ) (hp : Nat.Prime p) : tau p = 2 := by
  simp [tau, Nat.Prime.divisors hp, Finset.card_pair (Ne.symm hp.one_lt.ne')]

/-- τ(1) = 1. -/
theorem tau_one : tau 1 = 1 := by
  simp [tau]

/-
τ(p^k) = k + 1 for prime p.
-/
theorem tau_prime_pow (p k : ℕ) (hp : Nat.Prime p) :
    tau (p ^ k) = k + 1 := by
  simp +decide [ tau, Nat.divisors_prime_pow hp ]

/-
τ is multiplicative for coprime arguments.
-/
theorem tau_multiplicative (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcop : Nat.Coprime m n) :
    tau (m * n) = tau m * tau n := by
  unfold tau;
  exact?

/-! ### Möbius Function -/

/-
μ(p) = -1 for prime p.
-/
theorem mobius_at_prime (p : ℕ) (hp : Nat.Prime p) :
    ArithmeticFunction.moebius p = -1 := by
  rw [ ArithmeticFunction.moebius_apply_prime hp ]

/-
Möbius inversion: if g(n) = Σ_{d|n} f(d), then f(n) = Σ_{d|n} μ(n/d) g(d).
-/
theorem mobius_inversion_statement :
    ∀ (f g : ℕ → ℤ),
    (∀ n, 0 < n → g n = ∑ d ∈ n.divisors, f d) →
    ∀ n, 0 < n →
      f n = ∑ d ∈ n.divisors, ArithmeticFunction.moebius (n / d) * g d := by
  intro f g hg n hn;
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius (n / d) * (∑ k ∈ Nat.divisors d, f k) = ∑ k ∈ Nat.divisors n, f k * (∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius (n / d) * (if k ∣ d then 1 else 0)) := by
    have h_fubini : ∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius (n / d) * (∑ k ∈ Nat.divisors d, f k) = ∑ k ∈ Nat.divisors n, ∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius (n / d) * f k * (if k ∣ d then 1 else 0) := by
      rw [ Finset.sum_comm, Finset.sum_congr rfl ];
      simp +decide [ Finset.mul_sum _ _ _, mul_assoc, Finset.sum_ite ];
      intro x hx hn; rw [ ← Finset.sum_subset ( show x.divisors ⊆ n.divisors.filter ( fun y => y ∣ x ) from fun y hy => Finset.mem_filter.mpr ⟨ Nat.mem_divisors.mpr ⟨ dvd_trans ( Nat.dvd_of_mem_divisors hy ) hx, hn ⟩, Nat.dvd_of_mem_divisors hy ⟩ ) ] ; aesop;
    simpa only [ mul_assoc, mul_left_comm, Finset.mul_sum _ _ _ ] using h_fubini;
  -- Let's simplify the inner sum $\sum_{d \mid n} \mu(n/d) \cdot \mathbf{1}_{k \mid d}$.
  have h_inner : ∀ k ∈ Nat.divisors n, ∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius (n / d) * (if k ∣ d then 1 else 0) = if k = n then 1 else 0 := by
    intro k hk
    have h_inner_sum : ∑ d ∈ Nat.divisors n, ArithmeticFunction.moebius (n / d) * (if k ∣ d then 1 else 0) = ∑ d ∈ Nat.divisors (n / k), ArithmeticFunction.moebius d := by
      have h_inner_sum : Finset.filter (fun d => k ∣ d) (Nat.divisors n) = Finset.image (fun d => k * d) (Nat.divisors (n / k)) := by
        ext; simp [Finset.mem_image];
        constructor <;> intro h;
        · exact ⟨ ‹_› / k, ⟨ Nat.dvd_div_of_mul_dvd <| by simpa only [ Nat.mul_div_cancel' h.2 ] using h.1.1, Nat.ne_of_gt <| Nat.pos_of_mem_divisors hk, Nat.le_of_dvd hn <| Nat.dvd_of_mem_divisors hk ⟩, Nat.mul_div_cancel' h.2 ⟩;
        · rcases h with ⟨ a, ⟨ ha₁, ha₂, ha₃ ⟩, rfl ⟩ ; exact ⟨ ⟨ by exact Nat.mul_dvd_of_dvd_div ( Nat.dvd_of_mem_divisors hk ) ha₁, hn.ne' ⟩, dvd_mul_right _ _ ⟩ ;
      simp_all +decide [ Finset.sum_ite ];
      rw [ Finset.sum_image ];
      · conv_rhs => rw [ ← Nat.sum_div_divisors ] ;
        exact Finset.sum_congr rfl fun x hx => by rw [ Nat.div_div_eq_div_mul ] ;
      · intro x hx y hy; aesop;
    split_ifs <;> simp_all +decide [ Nat.div_self ( Nat.pos_of_mem_divisors hk ) ];
    have h_inner_sum_zero : ∀ m : ℕ, m ≠ 1 → ∑ d ∈ Nat.divisors m, ArithmeticFunction.moebius d = 0 := by
      intro m hm_ne_one
      have h_inner_sum_zero : ∑ d ∈ Nat.divisors m, ArithmeticFunction.moebius d = (ArithmeticFunction.moebius * ArithmeticFunction.zeta) m := by
        simp +decide [ ArithmeticFunction.moebius, ArithmeticFunction.zeta ];
        rw [ Nat.sum_divisorsAntidiagonal fun x y => if y = 0 then 0 else if Squarefree x then ( -1 ) ^ ArithmeticFunction.cardFactors x else 0 ];
        exact Finset.sum_congr rfl fun x hx => by rw [ if_neg ( Nat.ne_of_gt ( Nat.div_pos ( Nat.le_of_dvd ( Nat.pos_of_ne_zero ( by aesop ) ) ( Nat.dvd_of_mem_divisors hx ) ) ( Nat.pos_of_mem_divisors hx ) ) ) ] ;
      simp_all +decide [ ArithmeticFunction.moebius_mul_coe_zeta ];
    exact h_inner_sum_zero _ ( by intro h; have := Nat.div_mul_cancel hk.1; aesop );
  rw [ Finset.sum_congr rfl fun x hx => by rw [ hg x ( Nat.pos_of_mem_divisors hx ) ] ];
  rw [ h_fubini, Finset.sum_congr rfl fun x hx => by rw [ h_inner x hx ] ] ; aesop

/-! ### Perfect Number Variants -/

/-- A k-multiperfect number has σ₁(n) = k·n. -/
def IsMultiperfect (k n : ℕ) : Prop :=
  0 < n ∧ ∑ d ∈ n.divisors, d = k * n

/-- 120 is 3-perfect (triperfect). -/
theorem triperfect_120 : IsMultiperfect 3 120 := by
  refine ⟨by omega, ?_⟩; native_decide

/-- 672 is 3-perfect (triperfect). -/
theorem triperfect_672 : IsMultiperfect 3 672 := by
  refine ⟨by omega, ?_⟩; native_decide

/-! ### Abundancy -/

/-- An abundant number has σ₁(n) > 2n. -/
def IsAbundant (n : ℕ) : Prop := 0 < n ∧ 2 * n < ∑ d ∈ n.divisors, d

/-- 12 is abundant. -/
theorem abundant_12 : IsAbundant 12 := by
  refine ⟨by omega, ?_⟩; native_decide

/-- A deficient number has σ₁(n) < 2n. -/
def IsDeficient (n : ℕ) : Prop := 0 < n ∧ ∑ d ∈ n.divisors, d < 2 * n

/-- All primes are deficient. -/
theorem prime_deficient (p : ℕ) (hp : Nat.Prime p) : IsDeficient p := by
  constructor
  · exact hp.pos
  · simp [hp.sum_divisors]; have := hp.one_lt; omega

/-
The smallest abundant number is 12.
-/
theorem smallest_abundant : ∀ n, 0 < n → n < 12 → ¬ IsAbundant n := by
  -- By definition of IsAbundant, we need to show that for any n < 12, the sum of its divisors is not greater than 2n.
  intros n hn_pos hn_lt_12
  simp [IsAbundant];
  interval_cases n <;> trivial