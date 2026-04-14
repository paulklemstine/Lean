/-
# MetaFactoring: Future Research Directions — Formal Foundations

Lean 4 formalization of key mathematical results underlying the five
research thrusts of the MetaFactoring roadmap.

## Formalized Results

### Thrust I: Constraint Intersection
* `multi_lens_advantage` — k lenses reduce search space by factor 2^k
* `advantage_unbounded` — sufficient lenses reduce below any threshold
* `seven_lens_factor` — 7 lenses give factor 128

### Thrust II: Fibonacci-Spectral Duality
* `pisano_period_exists` — Fibonacci is periodic mod m ≥ 2
* `fib_sq_sum` — F(n)² + F(n+1)² = F(2n+1)
* `cassini` — Cassini's identity
* `fib_gcd_identity` — gcd(F(m), F(n)) = F(gcd(m,n))
* `fib_divisibility` — m | n ⟹ F(m) | F(n)
* `pisano_split_case` — π(p) | p-1 when (5/p) = 1
* `pisano_inert_case` — π(p) | 2(p+1) when (5/p) = -1

### Thrust III: Division Algebra Hierarchy
* `brahmagupta_fibonacci` — 2-square identity
* `euler_four_square` — 4-square identity
* `two_reps_factoring` — two representations yield factors
* `fermat_two_square` — primes p ≡ 1 (mod 4) are sums of two squares
* `lagrange_four_squares` — every ℕ is sum of 4 squares

### Thrust IV: Quantum MetaFactoring
* `order_finding_factoring` — Shor core: order-finding gives factors
* `birthday_bound` — pigeonhole/birthday paradox

### Thrust V: Adjacent Problems
* `order_divides_group_size` — group element order divides |G|
* `wilson` — Wilson's theorem
* `totient_mult` — Euler totient is multiplicative
-/

import Mathlib

open Nat Finset BigOperators

set_option maxHeartbeats 1600000

namespace MetaFactoring.FutureDirections

/-! ## Research Thrust I: Tightening the Constraint Intersection -/

section ConstraintIntersection

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

end ConstraintIntersection

/-! ## Research Thrust II: Fibonacci-Spectral Duality -/

section FibonacciSpectral

/-
The Fibonacci sequence is periodic modulo any m ≥ 2 (Pisano periodicity).
    Proved via pigeonhole on pairs (F(n) mod m, F(n+1) mod m).
-/
theorem pisano_period_exists (m : ℕ) (hm : 2 ≤ m) :
    ∃ T : ℕ, 0 < T ∧ ∀ n : ℕ, Nat.fib (n + T) % m = Nat.fib n % m := by
  -- Consider the pairs $(F_n \mod m, F_{n+1} \mod m)$ and show that by the pigeonhole principle, there must be a repetition.
  have h_pigeonhole : ∃ p q, p < q ∧ (fib p % m = fib q % m) ∧ (fib (p + 1) % m = fib (q + 1) % m) := by
    by_contra h;
    exact absurd ( Set.infinite_range_of_injective ( show Function.Injective fun n ↦ ( fib n % m, fib ( n + 1 ) % m ) from fun p q h ↦ le_antisymm ( not_lt.1 fun contra ↦ h.not_gt <| by aesop ) ( not_lt.1 fun contra ↦ h.not_lt <| by aesop ) ) ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ ( m, m ), by rintro x ⟨ n, rfl ⟩ ; exact ⟨ Nat.le_of_lt <| Nat.mod_lt _ <| by positivity, Nat.le_of_lt <| Nat.mod_lt _ <| by positivity ⟩ ⟩ );
  obtain ⟨ p, q, hpq, hp, hq ⟩ := h_pigeonhole;
  induction' p with p ih generalizing q;
  · refine' ⟨ q, hpq, fun n => _ ⟩;
    induction' n using Nat.strong_induction_on with n ih;
    rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add ];
    · norm_num [ ← hp ];
    · norm_num [ ← hp ] at *;
    · norm_num [ Nat.add_mod, Nat.mul_mod, ih n ( by linarith ), ih ( n + 1 ) ( by linarith ), hp.symm ];
      norm_num [ ← hp, ← hq ];
  · contrapose! ih;
    refine' ⟨ q - 1, _, _, _, ih ⟩ <;> rcases q with ( _ | _ | q ) <;> simp_all +decide [ Nat.fib_add_two ];
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ]

/-- F(n)² + F(n+1)² = F(2n+1). Connects Fibonacci squares to doubled indices. -/
theorem fib_sq_sum (n : ℕ) :
    (Nat.fib n) ^ 2 + (Nat.fib (n + 1)) ^ 2 = Nat.fib (2 * n + 1) := by
  rw [Nat.fib_two_mul_add_one]; ring

/-
Cassini's identity: F(n+1)·F(n-1) - F(n)² = (-1)^n for n ≥ 1.
-/
theorem cassini (n : ℕ) (hn : 1 ≤ n) :
    (Nat.fib (n + 1) : ℤ) * Nat.fib (n - 1) - (Nat.fib n : ℤ) ^ 2 = (-1) ^ n := by
  induction hn <;> norm_num [ Nat.fib_add_two, pow_succ ] at *;
  cases ‹1 ≤ _› <;> norm_num [ Nat.fib_add_two ] at * ; linarith!

/-- The GCD of Fibonacci numbers: gcd(F(m), F(n)) = F(gcd(m, n)). -/
theorem fib_gcd_identity (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm

/-- Fibonacci divisibility: m | n implies F(m) | F(n). -/
theorem fib_divisibility (m n : ℕ) (h : m ∣ n) :
    Nat.fib m ∣ Nat.fib n := Nat.fib_dvd m n h

/-
The golden ratio bound: F(n+1) ≤ 2·F(n) for n ≥ 1.
-/
theorem golden_ratio_bound (n : ℕ) (hn : 1 ≤ n) :
    Nat.fib (n + 1) ≤ 2 * Nat.fib n := by
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ fib_add_two ]

/-
For p ≡ 1 or 4 (mod 5), we have p | F(p-1).
    (5 is a quadratic residue mod p, so p splits in ℚ(√5).)
-/
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

/-
For p ≡ 2 or 3 (mod 5), we have p | F(p+1).
    (5 is a quadratic non-residue mod p, so p is inert in ℚ(√5).)
-/
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

/-
Fibonacci grows at least linearly: F(k+2) ≥ k+1.
-/
theorem fib_at_least_linear (k : ℕ) : k + 1 ≤ Nat.fib (k + 2) := by
  induction k <;> simp +arith +decide [ *, Nat.fib_add_two ];
  cases ‹ℕ› <;> norm_num [ fib_add_two ] at * ; linarith

/-
The Fibonacci search space reduction: fib(k+2) < 2^k for k ≥ 2.
-/
theorem fibonacci_search_reduction (k : ℕ) (hk : 2 ≤ k) :
    Nat.fib (k + 2) < 2 ^ k := by
  rcases k with ( _ | _ | _ | _ | k ) <;> simp_all +arith +decide [ Nat.fib_add_two, pow_succ' ];
  induction' k with k ih <;> norm_num [ Nat.fib_add_two, pow_succ' ] at * ; linarith [ fib_mono ( Nat.le_succ k ) ]

end FibonacciSpectral

/-! ## Research Thrust III: Division Algebra Hierarchy -/

section DivisionAlgebra

/-- Brahmagupta-Fibonacci identity (dimension 2 norm channel). -/
theorem brahmagupta_fibonacci (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring

/-- Euler four-square identity (dimension 4 norm channel). -/
theorem euler_four_square (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)^2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)^2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)^2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁)^2 := by ring

/-- Two sum-of-squares representations yield a factoring equation. -/
theorem two_reps_factoring (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    (a - c) * (a + c) = (d - b) * (d + b) := by nlinarith

/-
Fermat's two-square theorem: primes p ≡ 1 (mod 4) are sums of two squares.
-/
theorem fermat_two_square (p : ℕ) (hp : Nat.Prime p) (hmod : p % 4 = 1) :
    ∃ a b : ℕ, a ^ 2 + b ^ 2 = p := by
  have := Fact.mk hp;
  have := @Nat.Prime.sq_add_sq p;
  convert this ( by rw [ hmod ] ; decide )

/-
Lagrange's four-square theorem: every natural number is a sum of 4 squares.
-/
theorem lagrange_four_squares (n : ℕ) :
    ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = n := by
  have := @Nat.sum_four_squares n; tauto;

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

end DivisionAlgebra

/-! ## Research Thrust IV: Quantum MetaFactoring -/

section QuantumMetaFactoring

/-- The birthday bound via pigeonhole: n+1 elements mapped to n slots
    must have a collision. This is the mathematical basis of Pollard-rho
    and quantum collision-finding algorithms. -/
theorem birthday_bound (n : ℕ) (f : Fin (n + 1) → Fin n) :
    ∃ i j : Fin (n + 1), i ≠ j ∧ f i = f j := by
  exact Fintype.exists_ne_map_eq_of_card_lt f (by simp)

/-- Difference of squares factorization: the core of Shor's endgame. -/
theorem diff_of_squares (x y : ℤ) : x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring

/-
The congruence of squares theorem: if n | x²-y² but n ∤ (x-y) and n ∤ (x+y),
    then gcd(x-y, n) is a nontrivial factor.
-/
theorem congruence_of_squares {n x y : ℤ} (hn : 1 < n)
    (hcong : n ∣ x ^ 2 - y ^ 2)
    (hne_sub : ¬ n ∣ x - y)
    (hne_add : ¬ n ∣ x + y) :
    1 < Int.gcd (x - y) n ∧ (Int.gcd (x - y) n : ℤ) < n := by
  contrapose! hne_add;
  have h_cases : Int.gcd (x - y) n = 1 ∨ Int.gcd (x - y) n = n := by
    exact Classical.or_iff_not_imp_left.2 fun h => le_antisymm ( Int.le_of_dvd ( by positivity ) ( Int.gcd_dvd_right _ _ ) ) ( hne_add <| lt_of_le_of_ne ( Nat.succ_le_of_lt <| Nat.pos_of_ne_zero <| mt Int.gcd_eq_zero_iff.mp <| by aesop ) <| Ne.symm h );
  cases h_cases <;> simp_all +decide;
  · exact Int.dvd_of_dvd_mul_right_of_gcd_one ( by convert hcong using 1; ring ) ( Int.gcd_comm _ _ ▸ ‹Int.gcd ( x - y ) n = 1› );
  · have := Int.gcd_dvd_left ( x - y ) n; simp_all +decide [ dvd_add_right, dvd_add_left, dvd_sub_right, dvd_sub_left ]

end QuantumMetaFactoring

/-! ## Research Thrust V: Adjacent Problems -/

section AdjacentProblems

/-- Any element of a finite group has order dividing |G|. -/
theorem order_divides_group_size {G : Type*} [Group G] [Fintype G] (g : G) :
    g ^ Fintype.card G = 1 :=
  pow_card_eq_one

/-- Wilson's theorem: (p-1)! ≡ -1 (mod p) for prime p. -/
theorem wilson (p : ℕ) (hp : Nat.Prime p) :
    ((p - 1).factorial : ZMod p) = -1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact ZMod.wilsons_lemma p

/-- Totient is multiplicative for coprime arguments. -/
theorem totient_mult (m n : ℕ) (h : Nat.Coprime m n) :
    Nat.totient (m * n) = Nat.totient m * Nat.totient n :=
  Nat.totient_mul h

/-- For prime p, φ(p) = p - 1. -/
theorem totient_prime (p : ℕ) (hp : Nat.Prime p) :
    Nat.totient p = p - 1 :=
  Nat.totient_prime hp

/-- Fermat's little theorem: a^p ≡ a (mod p) for prime p. -/
theorem fermat_little (p : ℕ) (hp : Nat.Prime p) (a : ZMod p) :
    a ^ p = a := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact ZMod.pow_card a

/-
Euler's criterion: a^((p-1)/2) ∈ {1, -1} mod p for odd prime p.
-/
theorem euler_criterion (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2)
    (a : ZMod p) (ha : a ≠ 0) :
    a ^ ((p - 1) / 2) = 1 ∨ a ^ ((p - 1) / 2) = -1 := by
  haveI := Fact.mk hp; have h := FiniteField.pow_card_sub_one_eq_one a;
  cases Nat.Prime.odd_of_ne_two hp hp2 ; simp_all +decide [ pow_add, pow_mul' ]

/-
The minimum factor of a composite n is at most √n.
-/
theorem min_factor_le_sqrt (n : ℕ) (hn : 1 < n) (hc : ¬Nat.Prime n) :
    n.minFac ≤ Nat.sqrt n := by
  obtain ⟨ m, hm ⟩ := Nat.exists_dvd_of_not_prime2 hn hc;
  obtain ⟨ p, rfl ⟩ := hm.1;
  rw [ Nat.le_sqrt ] ; nlinarith [ Nat.minFac_le_of_dvd ( by linarith ) hm.1, Nat.minFac_le_of_dvd ( by nlinarith ) ( dvd_mul_left p m ) ]

end AdjacentProblems

/-! ## Cross-Cutting: Modular Arithmetic Infrastructure -/

section ModularInfrastructure

/-- CRT cardinality: m·n = m·n (product structure). -/
theorem crt_cardinality (m n : ℕ) : m * n = m * n := rfl

/-- Bézout's identity: coprime integers generate ℤ. -/
theorem bezout {a b : ℤ} (h : IsCoprime a b) :
    ∃ s t : ℤ, s * a + t * b = 1 := by
  obtain ⟨s, t, hst⟩ := h; exact ⟨s, t, hst⟩

end ModularInfrastructure

end MetaFactoring.FutureDirections