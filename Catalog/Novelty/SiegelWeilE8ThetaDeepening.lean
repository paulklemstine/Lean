import Mathlib

/-!
# Deepening the Siegel–Weil identity for the `E₈` theta series

The Siegel–Weil identity for rank `8` says the theta series of the even
unimodular lattice `E₈` equals the weight-`4` Eisenstein series `E₄`; at the
level of Fourier coefficients this is `r(n) = 240·σ₃(n)`, where
`σ₃(n) = ∑_{d ∣ n} d³`.  The arithmetic backbone — that `240·σ₃` carries the full
Hecke-eigenform structure of `E₄` — is captured by the global convolution law

```
σ₃(m)·σ₃(n) = ∑_{d ∣ gcd(m,n)} d³·σ₃(mn/d²).
```

This file *deepens* that result in two independent directions, and is
self-contained (it only imports `Mathlib`).

## 1. A more general setting: every Eisenstein weight

The Hecke-module structure is not special to weight `4`.  For **every** exponent
`s`, the divisor-power sum `σ_s` — the coefficient system of the weight-`(s+1)`
Eisenstein series — satisfies the same three-term prime-power recurrence and the
same global convolution identity.  We build the entire chain for arbitrary `s`:

* `sigma_prime_pow`, `sigma_prime` — the geometric prime-power form;
* `sigma_hecke_prime_pow` — the three-term Hecke recurrence at a prime power;
* `heckeRHSg_prime_pow`, `heckeRHSg_mul`, `heckeRHSg_coprime` — the
  multiplicative anatomy of the Hecke convolution;
* `sigma_hecke_identity` — the global Hecke eigenform identity for `σ_s`.

The original weight-`4` statement is recovered verbatim as the case `s = 3`
(`sigma_hecke_identity_three`).

## 2. New consequences of the identity

* `sigma_hecke_Tp` — the **Hecke operator eigenvalue relation** valid for *all*
  `n` (not merely prime powers):
  `σ_s(p)·σ_s(n) = σ_s(pn) + [p ∣ n]·p^s·σ_s(n/p)`.
  This is exactly the statement that `σ_s` is a simultaneous eigenfunction of
  every Hecke operator `T_p`, with eigenvalue `σ_s(p)`.
* `sigma_ge_self_pow` — the elementary lower bound `n^s ≤ σ_s(n)`.
* `rE8_ge`, `rE8_hecke_Tp` — these consequences transported to the `E₈` counts
  `rE8 n = 240·σ₃(n)`.
-/

set_option maxHeartbeats 1000000

namespace SiegelWeilE8Gen

open ArithmeticFunction Finset

/-- The `E₄`/Siegel–Weil prediction for the number of `E₈` vectors of squared
length `2n`: `240 · σ₃(n)`. -/
def rE8 (n : ℕ) : ℕ := 240 * (sigma 3) n

/-! ### A pure geometric double-sum identity

This is the combinatorial heart of the prime-power Hecke relation. -/

/-- `(∑_{i≤a} qⁱ)(∑_{j≤b} qʲ) = ∑_{i≤min a b} qⁱ · (∑_{l ≤ a+b-2i} qˡ)`. -/
theorem geom_double (q a b : ℕ) :
    (∑ i ∈ range (a + 1), q ^ i) * (∑ j ∈ range (b + 1), q ^ j)
      = ∑ i ∈ range (min a b + 1), q ^ i * ∑ l ∈ range (a + b - 2 * i + 1), q ^ l := by
  by_cases h_cases : a ≤ b;
  · induction' a with a ih generalizing b <;> simp_all +decide [ Nat.mul_succ, Finset.sum_range_succ' ];
    specialize ih ( b - 1 ) ( Nat.le_sub_one_of_lt h_cases ) ; rcases b with ( _ | b ) <;> simp_all +decide [ Nat.succ_eq_add_one, add_assoc, add_tsub_assoc_of_le, Finset.sum_range_succ ] ;
    simp_all +decide [ Nat.add_comm 1, Nat.add_assoc, Nat.add_sub_assoc, pow_succ', ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
    simp_all +decide [ ← add_assoc, Nat.add_sub_add_right, Finset.sum_range_add, pow_add ];
    simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, Finset.sum_add_distrib, add_mul, mul_add, pow_succ' ];
    nlinarith [ Nat.zero_le ( q * ( q * ( q * ( ( ∑ i ∈ Finset.range a, q ^ i ) * q ^ b ) ) ) ), Nat.zero_le ( q * ( q * q ^ b ) ), Nat.zero_le ( q * q ^ b ), Nat.zero_le ( q * ( q * ( ∑ i ∈ Finset.range a, q ^ i ) ) ), Nat.zero_le ( q * ( ∑ i ∈ Finset.range a, q ^ i ) ), Nat.zero_le ( q * ( q * ( ( ∑ i ∈ Finset.range a, q ^ i ) * ∑ i ∈ Finset.range b, q ^ i ) ) ), Nat.zero_le ( q * ( ∑ i ∈ Finset.range b, q ^ i ) ), Nat.zero_le ( q * ( ( ∑ i ∈ Finset.range b, q ^ i ) * q ^ a ) ), geom_sum_mul_neg ( q : ℤ ) a, geom_sum_mul_neg ( q : ℤ ) b ];
  · rw [ min_eq_right ( le_of_not_ge h_cases ), mul_comm ];
    induction' b with b ih generalizing a;
    · norm_num;
    · have := ih ( a + 1 ) ( by linarith ) ; simp_all +decide [ Finset.sum_range_succ, Nat.mul_succ, pow_succ' ];
      convert congr_arg ( · + q * q ^ b * ( ∑ j ∈ Finset.range ( a + ( b + 1 ) - ( 2 * b + 2 ) ), q ^ j + q ^ ( a + ( b + 1 ) - ( 2 * b + 2 ) ) ) ) this using 1 <;> ring;
      rw [ show 1 + b + a - ( 2 + b * 2 ) = a - ( b + 1 ) by omega ] ; ring;
      rw [ show a = ( a - ( 1 + b ) ) + ( 1 + b ) by rw [ Nat.sub_add_cancel ( by linarith ) ] ] ; norm_num [ pow_add, Finset.sum_range_add ] ; ring;
      simpa only [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] using by ring;

/-! ### The general prime-power and recurrence structure -/

/-
Geometric closed form of `σ_s` at a prime power:
`σ_s(pʳ) = ∑_{i=0}^{r} p^{s·i}`.
-/
theorem sigma_prime_pow (s p r : ℕ) (hp : p.Prime) :
    (sigma s) (p ^ r) = ∑ i ∈ range (r + 1), p ^ (s * i) := by
  rw [sigma_apply];
  norm_num [ pow_mul', Nat.divisors_prime_pow hp ]

/-
Value of `σ_s` at a prime: `σ_s(p) = 1 + p^s`.
-/
theorem sigma_prime (s p : ℕ) (hp : p.Prime) : (sigma s) p = 1 + p ^ s := by
  convert sigma_prime_pow s p 1 hp using 1;
  · norm_num;
  · norm_num [ add_comm, Finset.sum_range_succ ]

/-
The Hecke three-term recurrence for `σ_s` on powers of a prime:
`σ_s(p^{r+2}) + p^s·σ_s(pʳ) = σ_s(p)·σ_s(p^{r+1})`.  This is the coefficient-level
statement that the weight-`(s+1)` Eisenstein series is an eigenform of `T_p` with
eigenvalue `σ_s(p) = 1 + p^s`.
-/
theorem sigma_hecke_prime_pow (s p r : ℕ) (hp : p.Prime) :
    (sigma s) (p ^ (r + 2)) + p ^ s * (sigma s) (p ^ r)
      = (sigma s) p * (sigma s) (p ^ (r + 1)) := by
  rw [sigma_prime_pow, sigma_prime_pow, sigma_prime_pow, sigma_prime];
  · simp +arith +decide [ pow_add, pow_mul, Finset.mul_sum _ _ _, Finset.sum_range_succ ] ; ring;
  · assumption;
  · assumption;
  · assumption;
  · assumption

/-- Multiplicativity of `σ_s` across coprime arguments. -/
theorem sigma_mul_coprime (s : ℕ) {m n : ℕ} (h : Nat.Coprime m n) :
    (sigma s) (m * n) = (sigma s) m * (sigma s) n :=
  isMultiplicative_sigma.map_mul_of_coprime h

/-! ### The general Hecke convolution -/

/-- The Hecke convolution for weight `s+1`:
`∑_{d ∣ gcd(m,n)} d^s · σ_s(mn/d²)`. -/
def heckeRHSg (s m n : ℕ) : ℕ :=
  ∑ d ∈ (Nat.gcd m n).divisors, d ^ s * (sigma s) (m * n / d ^ 2)

@[simp] theorem heckeRHSg_zero_left (s n : ℕ) : heckeRHSg s 0 n = 0 := by
  simp [heckeRHSg]

@[simp] theorem heckeRHSg_zero_right (s m : ℕ) : heckeRHSg s m 0 = 0 := by
  simp [heckeRHSg]

/-
The Hecke convolution on prime powers factors as the product of `σ_s` values.
-/
theorem heckeRHSg_prime_pow (s p a b : ℕ) (hp : p.Prime) :
    heckeRHSg s (p ^ a) (p ^ b) = (sigma s) (p ^ a) * (sigma s) (p ^ b) := by
  -- Since p is prime, gcd(p^a, p^b) = p^(min a b).
  have gcd_pow : Nat.gcd (p ^ a) (p ^ b) = p ^ (Nat.min a b) := by
    cases le_total a b <;> simp +decide [ *, Nat.gcd_comm ];
    · exact Nat.gcd_eq_left ( pow_dvd_pow _ ‹_› );
    · exact Nat.gcd_eq_right ( pow_dvd_pow _ ‹_› );
  -- Rewrite `heckeRHSg s (p^a) (p^b)` using `gcd_pow` and the definition of `sigma_prime_pow`.
  have h_heckeRHSg : heckeRHSg s (p ^ a) (p ^ b) = ∑ i ∈ Finset.range (Nat.min a b + 1), p ^ (s * i) * (sigma s) (p ^ (a + b - 2 * i)) := by
    refine' Finset.sum_bij ( fun i hi => Nat.factorization i p ) _ _ _ _ <;> simp_all +decide [ Nat.factorization_pow ];
    · intro x hx; rw [ Nat.dvd_prime_pow hp ] at hx; aesop;
    · intro a₁ ha₁ ha₂ a₂ ha₃ ha₄; rw [ Nat.dvd_prime_pow hp ] at ha₁ ha₃; aesop;
    · exact fun i hi₁ hi₂ => ⟨ p ^ i, ⟨ pow_dvd_pow _ ( by aesop ), by aesop ⟩, by rw [ Nat.factorization_pow ] ; aesop ⟩;
    · intro x hx _; rw [ Nat.dvd_prime_pow hp ] at hx; rcases hx with ⟨ k, hk, rfl ⟩ ; simp_all +decide [ ← pow_add ] ;
      rw [ ← pow_mul, mul_comm, Nat.div_eq_of_eq_mul_left ] <;> ring;
      · exact pow_pos hp.pos _;
      · rw [ ← pow_add, ← pow_add, add_tsub_cancel_of_le ( by linarith ) ];
  rw [ h_heckeRHSg, sigma_prime_pow s p a hp, sigma_prime_pow s p b hp ];
  convert geom_double ( p ^ s ) a b |> Eq.symm using 1;
  · exact Finset.sum_congr rfl fun i hi => by rw [ sigma_prime_pow s p ( a + b - 2 * i ) hp ] ; simp +decide [ pow_mul ] ;
  · simp +decide only [pow_mul]

/-
The Hecke convolution is multiplicative across coprime factorizations of the
two arguments.
-/
theorem heckeRHSg_mul (s : ℕ) {m n m' n' : ℕ}
    (h1 : Nat.Coprime m m') (h2 : Nat.Coprime n n')
    (h3 : Nat.Coprime m n') (h4 : Nat.Coprime m' n) :
    heckeRHSg s (m * m') (n * n') = heckeRHSg s m n * heckeRHSg s m' n' := by
  unfold heckeRHSg; simp +decide [ *, Finset.sum_mul ] ;
  -- By definition of gcd, we can rewrite the divisors of gcd(m*m', n*n') as pairs (x, y) where x divides gcd(m, n) and y divides gcd(m', n').
  have h_divisors : (Nat.gcd (m * m') (n * n')).divisors = Finset.image (fun (p : ℕ × ℕ) => p.1 * p.2) ((Nat.gcd m n).divisors ×ˢ (Nat.gcd m' n').divisors) := by
    rw [ show Nat.gcd ( m * m' ) ( n * n' ) = Nat.gcd m n * Nat.gcd m' n' from ?_ ];
    · exact Nat.divisors_mul _ _;
    · simp_all +decide [ Nat.gcd_comm, Nat.Coprime, Nat.Coprime.gcd_mul ];
  rw [ h_divisors, Finset.sum_image, Finset.sum_product ];
  · refine' Finset.sum_congr rfl fun x hx => _ ; rw [ Finset.mul_sum _ _ _ ] ; refine' Finset.sum_congr rfl fun y hy => _ ; ring;
    rw [ show m * m' * n * n' / ( x ^ 2 * y ^ 2 ) = ( m * n / x ^ 2 ) * ( m' * n' / y ^ 2 ) from ?_, sigma_mul_coprime ];
    · ring;
    · refine' Nat.Coprime.coprime_dvd_left ( Nat.div_dvd_of_dvd _ ) ( Nat.Coprime.coprime_dvd_right ( Nat.div_dvd_of_dvd _ ) _ );
      · exact dvd_trans ( pow_two x ▸ mul_dvd_mul ( Nat.dvd_trans ( Nat.dvd_of_mem_divisors hx ) ( Nat.gcd_dvd_left _ _ ) ) ( Nat.dvd_trans ( Nat.dvd_of_mem_divisors hx ) ( Nat.gcd_dvd_right _ _ ) ) ) ( by ring_nf; norm_num );
      · exact dvd_trans ( pow_two y ▸ mul_dvd_mul ( Nat.dvd_trans ( Nat.dvd_of_mem_divisors hy ) ( Nat.gcd_dvd_left _ _ ) ) ( Nat.dvd_trans ( Nat.dvd_of_mem_divisors hy ) ( Nat.gcd_dvd_right _ _ ) ) ) ( by ring_nf; norm_num );
      · apply_rules [ Nat.Coprime.mul_left, Nat.Coprime.symm ];
    · rw [ Nat.div_mul_div_comm ];
      · ring;
      · exact dvd_trans ( pow_two x ▸ mul_dvd_mul ( Nat.dvd_trans ( Nat.dvd_of_mem_divisors hx ) ( Nat.gcd_dvd_left _ _ ) ) ( Nat.dvd_trans ( Nat.dvd_of_mem_divisors hx ) ( Nat.gcd_dvd_right _ _ ) ) ) ( by ring_nf; norm_num );
      · simp +zetaDelta at *;
        exact dvd_trans ( pow_two y ▸ mul_dvd_mul ( hy.1.trans ( Nat.gcd_dvd_left _ _ ) ) ( hy.1.trans ( Nat.gcd_dvd_right _ _ ) ) ) ( by ring_nf; norm_num );
  · intros p hp q hq h_eq;
    have h_div : p.1 ∣ q.1 ∧ q.1 ∣ p.1 := by
      simp +zetaDelta at *;
      exact ⟨ Nat.Coprime.dvd_of_dvd_mul_right ( show Nat.Coprime ( p.1 ) ( q.2 ) from Nat.Coprime.coprime_dvd_left ( hp.1.1.trans ( Nat.gcd_dvd_left _ _ ) ) <| Nat.Coprime.coprime_dvd_right ( hq.2.1.trans ( Nat.gcd_dvd_right _ _ ) ) <| by aesop ) <| h_eq.symm ▸ dvd_mul_right _ _, Nat.Coprime.dvd_of_dvd_mul_right ( show Nat.Coprime ( q.1 ) ( p.2 ) from Nat.Coprime.coprime_dvd_left ( hq.1.1.trans ( Nat.gcd_dvd_left _ _ ) ) <| Nat.Coprime.coprime_dvd_right ( hp.2.1.trans ( Nat.gcd_dvd_right _ _ ) ) <| by aesop ) <| h_eq.symm ▸ dvd_mul_right _ _ ⟩;
    have := Nat.dvd_antisymm h_div.1 h_div.2; aesop;

/-- On coprime arguments the Hecke convolution collapses to `σ_s(m)·σ_s(n)`. -/
theorem heckeRHSg_coprime (s : ℕ) {m n : ℕ} (h : Nat.Coprime m n) :
    heckeRHSg s m n = (sigma s) m * (sigma s) n := by
  have hg : Nat.gcd m n = 1 := h
  simp [heckeRHSg, hg, sigma_mul_coprime s h]

/-
The global Hecke eigenform identity for `σ_s`, valid for every exponent `s`:
`σ_s(m)·σ_s(n) = ∑_{d ∣ gcd(m,n)} d^s·σ_s(mn/d²)`.
-/
theorem sigma_hecke_identity (s m n : ℕ) :
    (sigma s) m * (sigma s) n
      = ∑ d ∈ (Nat.gcd m n).divisors, d ^ s * (sigma s) (m * n / d ^ 2) := by
  by_contra h_contra;
  -- Prove that ` heckeRHSg s m n = sigma s m * sigma s n` for every m ∈ ℕ by strong induction on m.
  have h_ind : ∀ (m : ℕ), (∀ m' < m, ∀ n, heckeRHSg s m' n = (sigma s) m' * (sigma s) n) → ∀ n, heckeRHSg s m n = (sigma s) m * (sigma s) n := by
    intro m ih n
    by_cases hm0 : m = 0;
    · simp +decide [ hm0, heckeRHSg_zero_left ];
    · by_cases hn0 : n = 0;
      · simp [hn0, heckeRHSg_zero_right];
      · by_cases hmn : Nat.Coprime m n;
        · convert heckeRHSg_coprime s hmn using 1;
        · -- Otherwise, by `Nat.Prime.not_coprime_iff_dvd`, get a prime p with p ∣ m and p ∣ n.
          obtain ⟨p, hp_prime, hp_div_m, hp_div_n⟩ : ∃ p, Nat.Prime p ∧ p ∣ m ∧ p ∣ n := by
            exact Nat.Prime.not_coprime_iff_dvd.mp hmn;
          -- Factor out the p-part: write m = p^a * m' with ¬ p ∣ m' (a = m.factorization p, m' = ordCompl), and n = p^b * n' with ¬ p ∣ n'.
          obtain ⟨a, m', hm'⟩ : ∃ a m', m = p^a * m' ∧ ¬p ∣ m' := by
            exact ⟨ Nat.factorization m p, m / p ^ Nat.factorization m p, by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ], Nat.not_dvd_ordCompl ( by aesop ) ( by aesop ) ⟩
          obtain ⟨b, n', hn'⟩ : ∃ b n', n = p^b * n' ∧ ¬p ∣ n' := by
            exact ⟨ Nat.factorization n p, n / p ^ Nat.factorization n p, by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ], Nat.not_dvd_ordCompl ( by aesop ) ( by aesop ) ⟩;
          -- Establish the coprimalities (Nat.Coprime.pow_left of hp.coprime_iff_not_dvd), that a > 0 (since p ∣ m), m' < m, and m', n' > 0.
          have h_coprime : Nat.Coprime (p ^ a) m' ∧ Nat.Coprime (p ^ b) n' ∧ a > 0 ∧ m' < m ∧ m' > 0 ∧ n' > 0 := by
            rcases a with ( _ | a ) <;> rcases b with ( _ | b ) <;> simp_all +decide [ Nat.Coprime, Nat.Coprime.pow_left ];
            exact ⟨ hp_prime.coprime_iff_not_dvd.mpr hm'.2, hp_prime.coprime_iff_not_dvd.mpr hn'.2, lt_mul_of_one_lt_left ( Nat.pos_of_ne_zero hm0.2 ) ( one_lt_pow₀ hp_prime.one_lt ( Nat.succ_ne_zero _ ) ), Nat.pos_of_ne_zero hm0.2, Nat.pos_of_ne_zero hn0 ⟩;
          -- Then rewrite with `heckeRHSg_mul` splitting into p-power and prime-to-p parts, use `heckeRHSg_prime_pow p a b hp`, the induction hypothesis on m' < m for (m', n'), and `sigma_mul_coprime` to reassemble, closing with `ring`.
          have h_rewrite : heckeRHSg s (p ^ a * m') (p ^ b * n') = heckeRHSg s (p ^ a) (p ^ b) * heckeRHSg s m' n' := by
            apply heckeRHSg_mul;
            · exact h_coprime.1;
            · exact h_coprime.2.1;
            · exact Nat.Coprime.pow_left _ ( hp_prime.coprime_iff_not_dvd.mpr hn'.2 );
            · exact Nat.Coprime.symm ( Nat.Coprime.pow_left _ <| hp_prime.coprime_iff_not_dvd.mpr hm'.2 );
          simp_all +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
          rw [ heckeRHSg_prime_pow s p a b hp_prime, sigma_mul_coprime s h_coprime.1, sigma_mul_coprime s h_coprime.2.1 ];
          ring;
  exact h_contra <| Eq.symm <| h_ind m ( fun m' hm' => by exact Nat.strongRecOn m' fun m'' hm'' => h_ind m'' fun m''' hm''' => hm'' _ hm''' ) n

/-- The weight-`4` (`E₄`/`E₈`) identity is exactly the case `s = 3`. -/
theorem sigma_hecke_identity_three (m n : ℕ) :
    (sigma 3) m * (sigma 3) n
      = ∑ d ∈ (Nat.gcd m n).divisors, d ^ 3 * (sigma 3) (m * n / d ^ 2) :=
  sigma_hecke_identity 3 m n

/-! ### New consequences: the global Hecke operator relation and growth bounds -/

/-
The **Hecke operator eigenvalue relation**, valid for *all* `n` (not just
prime powers): `σ_s(p)·σ_s(n) = σ_s(pn) + [p ∣ n]·p^s·σ_s(n/p)`.
This states that `σ_s` is a simultaneous eigenfunction of every Hecke operator
`T_p` with eigenvalue `σ_s(p)`.
-/
theorem sigma_hecke_Tp (s p n : ℕ) (hp : p.Prime) :
    (sigma s) p * (sigma s) n
      = (sigma s) (p * n) + (if p ∣ n then p ^ s * (sigma s) (n / p) else 0) := by
  have := @sigma_hecke_identity;
  specialize this s p n; split_ifs at * <;> simp_all +decide [ Nat.gcd_eq_left_iff_dvd ] ;
  · simp_all +decide [ Nat.gcd_eq_left ‹_› ];
    rw [ show p * n / p ^ 2 = n / p by rw [ Nat.pow_two, Nat.mul_div_mul_left _ _ hp.pos ] ] ; ring;
  · rw [ Nat.Coprime.gcd_eq_one ( hp.coprime_iff_not_dvd.mpr ‹_› ) ] ; norm_num

/-
Elementary lower bound: `n^s ≤ σ_s(n)` for `n ≥ 1` (the divisor `n` itself
contributes the term `n^s`).
-/
theorem sigma_ge_self_pow (s n : ℕ) (hn : 0 < n) : n ^ s ≤ (sigma s) n := by
  -- By definition of $sigma$, we know that $(sigma s) n = \sum_{d \mid n} d^s$.
  have h_sigma_def : (sigma s) n = ∑ d ∈ n.divisors, d ^ s := sigma_apply
  exact h_sigma_def.symm ▸ Finset.single_le_sum ( fun x _ => Nat.zero_le ( x ^ s ) ) ( by aesop )

/-! ### Transport back to the `E₈` representation numbers -/

/-
The cubic lower bound for the `E₈` vector counts: `rE8 n ≥ 240·n³`.
-/
theorem rE8_ge (n : ℕ) (hn : 0 < n) : 240 * n ^ 3 ≤ rE8 n := by
  convert Nat.mul_le_mul_left 240 ( sigma_ge_self_pow 3 n hn ) using 1

/-
The Hecke eigenvalue relation transported to the `E₈` representation numbers:
`rE8(p)·rE8(n) = 240·(rE8(pn) + [p ∣ n]·p³·rE8(n/p))`.
-/
theorem rE8_hecke_Tp (p n : ℕ) (hp : p.Prime) :
    rE8 p * rE8 n
      = 240 * (rE8 (p * n) + (if p ∣ n then p ^ 3 * rE8 (n / p) else 0)) := by
  have := sigma_hecke_Tp 3 p n hp; split_ifs at * <;> simp_all +decide [ rE8 ] ; ring;
  · grind;
  · grind

end SiegelWeilE8Gen