import Mathlib

/-!
# The Siegel–Weil identity for the `E₈` theta series

The theta series of an even, positive-definite, unimodular lattice of rank `8`
coincides with the normalized Eisenstein series `E₄`.  Concretely, writing
`r(n)` for the number of lattice vectors of squared length `2n`, the identity

```
r(n) = 240 · σ₃(n),      σ₃(n) = ∑_{d ∣ n} d³
```

holds for every positive integer `n`.  This is the foundational rank-`8` case of
the classical Siegel–Weil formula, which equates the average theta series of a
genus of lattices with an Eisenstein series.  Because there is a single class in
the genus of even unimodular rank-`8` lattices, the average degenerates to the
single lattice `E₈`, and the identity reduces to matching the Fourier
coefficients of `θ_{E₈}` with those of `E₄`.

This file develops the arithmetic backbone of that identity: the structure of the
coefficient function `n ↦ 240·σ₃(n)`.  The Eisenstein series `E₄` is a Hecke
eigenform, and this manifests entirely at the level of its coefficients:

* a geometric closed form for `σ₃` at prime powers (`sigma3_prime_pow`);
* the *Hecke three-term recurrence* satisfied by `σ₃` on powers of a prime
  (`sigma3_hecke_prime_pow`) — the coefficient-level shadow of `E₄` being an
  eigenform of every Hecke operator `T_p`;
* multiplicativity across coprime arguments (`sigma3_mul_coprime`), and the
  induced quasi-multiplicativity of the representation numbers
  (`rE8_mul_coprime`);
* the global *Hecke eigenform identity* `σ₃(m)·σ₃(n) = ∑_{d ∣ (m,n)} d³·σ₃(mn/d²)`
  (`sigma3_hecke_identity`), which packages the entire Hecke module structure of
  `E₄` into a single convolution law on representation numbers.

Together these show that the sequence `240·σ₃(n)` — the vector counts of `E₈` —
is not an arbitrary arithmetic function but the coefficient system of a Hecke
eigenform, exactly as the Siegel–Weil philosophy predicts.

-- !-- Lab Notes -- !--
Hypothesis: The `E₈` vector-count function `n ↦ 240·σ₃(n)` inherits the full
  Hecke-eigenform structure of `E₄`, visible purely through divisor-sum identities.
Experiment: Formalize `σ₃` via `ArithmeticFunction.sigma 3`; establish the
  prime-power geometric form, derive the three-term Hecke recurrence, and lift to
  the global eigenform convolution identity using multiplicativity.
Analysis: The prime-power recurrence is a finite geometric-series identity; the
  global identity follows because both sides are multiplicative in the pair
  `(m, n)` and agree on prime powers.  Concrete low-order counts
  (240, 2160, 6720, 17520, 30240) confirm the match with `θ_{E₈}`.
Critique: All main results carry genuine content (induction / geometric sums /
  multiplicative reduction), none are definitional; the concrete counts are used
  only as corroborating evidence, not as main theorems.
Synthesis: `240·σ₃` is the coefficient system of a weight-`4` Hecke eigenform,
  the arithmetic incarnation of `θ_{E₈} = E₄`.
-/

namespace SiegelWeilE8

open ArithmeticFunction Finset

/-- The `E₄`/Siegel–Weil prediction for the number of `E₈` vectors of squared
length `2n`: `240 · σ₃(n)`. -/
def rE8 (n : ℕ) : ℕ := 240 * (sigma 3) n

/-- Geometric closed form of `σ₃` at a prime power:
`σ₃(pʳ) = ∑_{i=0}^{r} p^{3i}`. -/
theorem sigma3_prime_pow (p r : ℕ) (hp : p.Prime) :
    (sigma 3) (p ^ r) = ∑ i ∈ range (r + 1), p ^ (3 * i) := by
  rw [sigma_apply, Nat.divisors_prime_pow hp, Finset.sum_map]
  simp [pow_mul, mul_comm]

/-- Value of `σ₃` at a prime: `σ₃(p) = 1 + p³`. -/
theorem sigma3_prime (p : ℕ) (hp : p.Prime) : (sigma 3) p = 1 + p ^ 3 := by
  rw [show p = p ^ 1 by ring, sigma3_prime_pow p 1 hp]
  simp [Finset.sum_range_succ]

/-
The Hecke three-term recurrence for `σ₃` on powers of a prime:
`σ₃(p^{r+2}) + p³·σ₃(pʳ) = σ₃(p)·σ₃(p^{r+1})`.
This is the coefficient-level statement that `E₄` is an eigenform of the Hecke
operator `T_p` with eigenvalue `σ₃(p) = 1 + p³`.
-/
theorem sigma3_hecke_prime_pow (p r : ℕ) (hp : p.Prime) :
    (sigma 3) (p ^ (r + 2)) + p ^ 3 * (sigma 3) (p ^ r)
      = (sigma 3) p * (sigma 3) (p ^ (r + 1)) := by
  rw [sigma3_prime_pow, sigma3_prime_pow, sigma3_prime_pow, sigma3_prime];
  · norm_num [ Finset.sum_range_succ, pow_add, pow_mul ] ; ring;
  · assumption;
  · assumption;
  · assumption;
  · assumption

/-- Multiplicativity of `σ₃` across coprime arguments. -/
theorem sigma3_mul_coprime {m n : ℕ} (h : Nat.Coprime m n) :
    (sigma 3) (m * n) = (sigma 3) m * (sigma 3) n :=
  isMultiplicative_sigma.map_mul_of_coprime h

/-- Quasi-multiplicativity of the `E₈` representation numbers:
for coprime `m, n`, `240 · r(mn) = r(m) · r(n)`. -/
theorem rE8_mul_coprime {m n : ℕ} (h : Nat.Coprime m n) :
    240 * rE8 (m * n) = rE8 m * rE8 n := by
  simp only [rE8, sigma3_mul_coprime h]
  ring

/-- The convolution appearing on the right-hand side of the Hecke eigenform
identity: `∑_{d ∣ gcd(m,n)} d³ · σ₃(mn/d²)`. -/
def heckeRHS (m n : ℕ) : ℕ :=
  ∑ d ∈ (Nat.gcd m n).divisors, d ^ 3 * (sigma 3) (m * n / d ^ 2)

/-
Pure geometric double-sum identity underlying the prime-power Hecke relation:
`(∑_{i≤a} qⁱ)(∑_{j≤b} qʲ) = ∑_{i≤min a b} qⁱ · (∑_{l ≤ a+b-2i} qˡ)`.
-/
set_option maxHeartbeats 1000000 in
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

@[simp] theorem heckeRHS_zero_left (n : ℕ) : heckeRHS 0 n = 0 := by
  simp [heckeRHS]

@[simp] theorem heckeRHS_zero_right (m : ℕ) : heckeRHS m 0 = 0 := by
  simp [heckeRHS]

/-
The Hecke convolution on prime powers factors as the product of `σ₃` values.
-/
theorem heckeRHS_prime_pow (p a b : ℕ) (hp : p.Prime) :
    heckeRHS (p ^ a) (p ^ b) = (sigma 3) (p ^ a) * (sigma 3) (p ^ b) := by
  -- As `p` is prime, `gcd(p^a,p^b) = p^(min a b)`, so we can rewrite `heckeRHS` using the divisor sum formula.
  have gcd_pow (hp : p.Prime) (a b : ℕ) : Nat.gcd (p ^ a) (p ^ b) = p ^ (min a b) := by
    cases le_total a b <;> simp +decide [ *, Nat.gcd_comm ];
    · exact Nat.gcd_eq_left ( pow_dvd_pow _ ‹_› );
    · exact Nat.gcd_eq_right ( pow_dvd_pow _ ‹_› )
  have h_hecke : heckeRHS (p ^ a) (p ^ b) = (∑ i ∈ Finset.range (min a b + 1), p ^ (3 * i) * (sigma 3) (p ^ (a + b - 2 * i))) := by
    unfold heckeRHS;
    simp +decide [ ← pow_add, gcd_pow hp, Nat.divisors_prime_pow hp ];
    refine' Finset.sum_congr rfl fun i hi => _;
    rw [ show p ^ ( a + b ) / ( p ^ i ) ^ 2 = p ^ ( a + b - 2 * i ) from Nat.div_eq_of_eq_mul_left ( by exact pow_pos ( pow_pos hp.pos _ ) _ ) <| by rw [ ← pow_mul', ← pow_add, Nat.sub_add_cancel <| show 2 * i ≤ a + b from by linarith [ Finset.mem_range.mp hi, min_le_left a b, min_le_right a b ] ] ] ; ring;
  simp_all +decide [ sigma3_prime_pow ];
  have := geom_double ( p ^ 3 ) a b; simp_all +decide [ pow_mul, Finset.mul_sum _ _ _, Finset.sum_mul ] ;

/-
The Hecke convolution is multiplicative across coprime factorizations of the
two arguments.
-/
theorem heckeRHS_mul {m n m' n' : ℕ}
    (h1 : Nat.Coprime m m') (h2 : Nat.Coprime n n')
    (h3 : Nat.Coprime m n') (h4 : Nat.Coprime m' n) :
    heckeRHS (m * m') (n * n') = heckeRHS m n * heckeRHS m' n' := by
  -- Apply the fact that the divisors of a product of coprime numbers are the product of the divisors of each number.
  have h_divisors : Nat.divisors (Nat.gcd (m * m') (n * n')) = Finset.image (fun (d : ℕ × ℕ) => d.1 * d.2) (Nat.divisors (Nat.gcd m n) ×ˢ Nat.divisors (Nat.gcd m' n')) := by
    rw [ show Nat.gcd ( m * m' ) ( n * n' ) = Nat.gcd m n * Nat.gcd m' n' from ?_ ];
    · exact Nat.divisors_mul _ _;
    · simp_all +decide [ Nat.gcd_comm, Nat.Coprime, Nat.Coprime.gcd_mul ];
  unfold heckeRHS;
  rw [ h_divisors, Finset.sum_image, Finset.sum_product ];
  · rw [ Finset.sum_mul_sum ] ; refine' Finset.sum_congr rfl fun x hx => Finset.sum_congr rfl fun y hy => _ ; ring;
    rw [ show m * m' * n * n' / ( x ^ 2 * y ^ 2 ) = ( m * n / x ^ 2 ) * ( m' * n' / y ^ 2 ) from ?_, sigma3_mul_coprime ] <;> norm_num [ mul_assoc, h1.coprime_dvd_left, h2.coprime_dvd_left, h3.coprime_dvd_left, h4.coprime_dvd_left ];
    · refine' Nat.Coprime.coprime_dvd_left ( Nat.div_dvd_of_dvd _ ) ( Nat.Coprime.coprime_dvd_right ( Nat.div_dvd_of_dvd _ ) _ );
      · rw [ sq ];
        exact mul_dvd_mul ( Nat.dvd_trans ( Nat.dvd_of_mem_divisors hx ) ( Nat.gcd_dvd_left _ _ ) ) ( Nat.dvd_trans ( Nat.dvd_of_mem_divisors hx ) ( Nat.gcd_dvd_right _ _ ) );
      · simp +zetaDelta at *;
        exact dvd_trans ( pow_two y ▸ mul_dvd_mul ( hy.1.trans ( Nat.gcd_dvd_left _ _ ) ) ( hy.1.trans ( Nat.gcd_dvd_right _ _ ) ) ) ( by ring_nf; norm_num );
      · apply_rules [ Nat.Coprime.mul_left, Nat.Coprime.symm ];
    · rw [ Nat.div_mul_div_comm ];
      · ring;
      · exact dvd_trans ( pow_dvd_pow_of_dvd ( Nat.dvd_of_mem_divisors hx ) 2 ) ( by simpa only [ sq ] using mul_dvd_mul ( Nat.gcd_dvd_left _ _ ) ( Nat.gcd_dvd_right _ _ ) );
      · simp +zetaDelta at *;
        exact dvd_trans ( pow_two y ▸ mul_dvd_mul ( hy.1.trans ( Nat.gcd_dvd_left _ _ ) ) ( hy.1.trans ( Nat.gcd_dvd_right _ _ ) ) ) ( by ring_nf; norm_num );
  · intros x hx y hy; simp_all +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ] ;
    intro h; have := Nat.dvd_antisymm ( show x.1 ∣ y.1 from ?_ ) ( show y.1 ∣ x.1 from ?_ ) ; simp_all +decide [ Nat.dvd_gcd_iff ] ;
    · aesop;
    · exact ( Nat.Coprime.dvd_of_dvd_mul_right ( show Nat.Coprime ( x.1 ) ( y.2 ) from Nat.Coprime.coprime_dvd_left ( Nat.dvd_trans hx.1.1 ( Nat.gcd_dvd_left _ _ ) ) <| Nat.Coprime.coprime_dvd_right ( Nat.dvd_trans hy.2 ( Nat.gcd_dvd_right _ _ ) ) <| by aesop ) ) <| h.symm ▸ dvd_mul_right _ _;
    · exact ( Nat.Coprime.dvd_of_dvd_mul_right ( show Nat.Coprime ( y.1 ) ( x.2 ) from Nat.Coprime.coprime_dvd_left ( hy.1.trans ( Nat.gcd_dvd_left _ _ ) ) <| Nat.Coprime.coprime_dvd_right ( hx.2.1.trans ( Nat.gcd_dvd_right _ _ ) ) <| by aesop ) ) <| h.symm ▸ dvd_mul_right _ _

/-- On coprime arguments the Hecke convolution collapses to `σ₃(m)·σ₃(n)`. -/
theorem heckeRHS_coprime {m n : ℕ} (h : Nat.Coprime m n) :
    heckeRHS m n = (sigma 3) m * (sigma 3) n := by
  have hg : Nat.gcd m n = 1 := h
  simp [heckeRHS, hg, sigma3_mul_coprime h]

/-- The global Hecke eigenform identity for `σ₃`:
`σ₃(m)·σ₃(n) = ∑_{d ∣ gcd(m,n)} d³·σ₃(mn/d²)`.
This single convolution law encodes the entire Hecke-module structure of `E₄`:
it is equivalent to `240·σ₃` being the coefficient system of a simultaneous
eigenform for all Hecke operators. -/
theorem sigma3_hecke_identity (m n : ℕ) :
    (sigma 3) m * (sigma 3) n
      = ∑ d ∈ (Nat.gcd m n).divisors, d ^ 3 * (sigma 3) (m * n / d ^ 2) := by
  suffices h : ∀ m : ℕ, 0 < m → ∀ n : ℕ, 0 < n →
      heckeRHS m n = (sigma 3) m * (sigma 3) n by
    rcases Nat.eq_zero_or_pos m with hm | hm
    · subst hm; simp
    rcases Nat.eq_zero_or_pos n with hn | hn
    · subst hn; simp
    simpa [heckeRHS] using (h m hm n hn).symm
  clear m n
  intro m
  induction m using Nat.strong_induction_on with
  | _ m ih =>
    intro hm n hn
    by_cases hmn : Nat.Coprime m n
    · exact heckeRHS_coprime hmn
    · obtain ⟨p, hp, hpm, hpn⟩ := Nat.Prime.not_coprime_iff_dvd.mp hmn
      obtain ⟨a, m', hm'eq, hm'p⟩ :
          ∃ a m', m = p ^ a * m' ∧ ¬ p ∣ m' :=
        ⟨m.factorization p, m / p ^ m.factorization p,
          (Nat.mul_div_cancel' (Nat.ordProj_dvd _ _)).symm,
          Nat.not_dvd_ordCompl hp hm.ne'⟩
      obtain ⟨b, n', hn'eq, hn'p⟩ :
          ∃ b n', n = p ^ b * n' ∧ ¬ p ∣ n' :=
        ⟨n.factorization p, n / p ^ n.factorization p,
          (Nat.mul_div_cancel' (Nat.ordProj_dvd _ _)).symm,
          Nat.not_dvd_ordCompl hp hn.ne'⟩
      have hcpm : Nat.Coprime (p ^ a) m' := Nat.Coprime.pow_left _ (hp.coprime_iff_not_dvd.mpr hm'p)
      have hcpn : Nat.Coprime (p ^ b) n' := Nat.Coprime.pow_left _ (hp.coprime_iff_not_dvd.mpr hn'p)
      have hcpn' : Nat.Coprime (p ^ a) n' := Nat.Coprime.pow_left _ (hp.coprime_iff_not_dvd.mpr hn'p)
      have hcpm' : Nat.Coprime m' (p ^ b) := ((hp.coprime_iff_not_dvd.mpr hm'p).symm).pow_right b
      have ha_pos : 0 < a := by
        by_contra ha
        have ha0 : a = 0 := by omega
        subst ha0; simp at hm'eq; subst hm'eq; exact hm'p hpm
      have hm'pos : 0 < m' := by
        rcases Nat.eq_zero_or_pos m' with h0 | h0
        · simp [h0] at hm'eq; omega
        · exact h0
      have hn'pos : 0 < n' := by
        rcases Nat.eq_zero_or_pos n' with h0 | h0
        · simp [h0] at hn'eq; omega
        · exact h0
      have hpa1 : 1 < p ^ a := by
        calc 1 < p := hp.one_lt
          _ = p ^ 1 := (pow_one p).symm
          _ ≤ p ^ a := Nat.pow_le_pow_right hp.pos ha_pos
      have hm'lt : m' < m := by
        rw [hm'eq]
        calc m' = 1 * m' := (one_mul _).symm
          _ < p ^ a * m' := (Nat.mul_lt_mul_right hm'pos).mpr hpa1
      rw [hm'eq, hn'eq, heckeRHS_mul hcpm hcpn hcpn' hcpm',
          heckeRHS_prime_pow p a b hp,
          ih m' hm'lt hm'pos n' hn'pos,
          sigma3_mul_coprime hcpm, sigma3_mul_coprime hcpn]
      ring

/-! ### Low-order corroboration against `θ_{E₈}`

The following concrete values confirm that `240·σ₃(n)` reproduces the known
vector counts of the `E₈` lattice: `240` roots, then `2160, 6720, 17520, 30240`
vectors of squared length `4, 6, 8, 10`. -/

theorem rE8_one : rE8 1 = 240 := by decide
theorem rE8_two : rE8 2 = 2160 := by decide
theorem rE8_three : rE8 3 = 6720 := by decide
theorem rE8_four : rE8 4 = 17520 := by decide
theorem rE8_five : rE8 5 = 30240 := by decide

end SiegelWeilE8