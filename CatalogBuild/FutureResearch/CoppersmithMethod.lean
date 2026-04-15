/-! # CatalogBuild.FutureResearch.CoppersmithMethod

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 9
-/

import Mathlib

/-- If |a| < N and N | a, then a = 0. Fundamental principle of Coppersmith. -/
theorem small_mod_root_zero (a N : ℤ) (hN : 0 < N) (hmod : N ∣ a) (hsmall : |a| < N) :
    a = 0 := by
  obtain ⟨k, hk⟩ := hmod
  rw [hk] at hsmall ⊢
  rw [abs_mul, abs_of_pos hN] at hsmall
  have : |k| = 0 := by
    by_contra h
    have : 1 ≤ |k| := Int.one_le_abs (mt abs_eq_zero.mpr h)
    linarith [mul_le_mul_of_nonneg_left this (le_of_lt hN)]
  simp [abs_eq_zero.mp this]

/-- For a linear polynomial f(x) = ax + b, if N | f(x₀) and |f(x₀)| < N, then f(x₀) = 0. -/

theorem coppersmith_linear (a b x₀ N : ℤ) (hN : 0 < N)
    (hmod : N ∣ a * x₀ + b) (hsmall : |a * x₀ + b| < N) :
    a * x₀ + b = 0 :=
  small_mod_root_zero _ N hN hmod hsmall

/-! ### Quadratic Extension -/

/-- For a monic quadratic f(x) = x² + bx + c, if N | f(x₀) and |f(x₀)| < N, then f(x₀) = 0. -/

theorem coppersmith_quadratic_bound (x₀ b c N : ℤ) (hN : 0 < N)
    (hmod : N ∣ x₀ ^ 2 + b * x₀ + c) (hsmall : |x₀ ^ 2 + b * x₀ + c| < N) :
    x₀ ^ 2 + b * x₀ + c = 0 :=
  small_mod_root_zero _ N hN hmod hsmall

/-! ### Hensel's Lemma (for quadratics) -/

/-
If p is prime and p ∤ b, then for any k there exists t with p | k + b·t.
-/

theorem exists_mod_cancel (b k p : ℤ) (hp : Nat.Prime p.toNat) (hb : ¬ p ∣ b) :
    ∃ t : ℤ, p ∣ (k + b * t) := by
  rcases Int.eq_nat_or_neg p with ⟨ n, rfl | rfl ⟩ <;> simp_all +decide [ Int.natCast_dvd ];
  -- Since $n$ is prime and does not divide $b$, $b$ is invertible modulo $n$. Let $b^{-1}$ be the multiplicative inverse of $b$ modulo $n$.
  obtain ⟨b_inv, hb_inv⟩ : ∃ b_inv : ℤ, b * b_inv ≡ 1 [ZMOD ↑n] := by
    have := Int.gcd_eq_gcd_ab b n;
    exact ⟨ Int.gcdA b n, Int.modEq_iff_dvd.mpr ⟨ Int.gcdB b n, by linarith [ show Int.gcd b n = 1 from Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr hb ] ⟩ ⟩;
  exact ⟨ -k * b_inv, by rw [ ← Int.natCast_dvd ] ; simpa using hb_inv.symm.dvd.trans ⟨ -k, by ring ⟩ ⟩

/-- Hensel lifting for x² - c: if a² ≡ c (mod p) and p ∤ 2a (p prime),
    then there exists a' with a'² ≡ c (mod p²) and a' ≡ a (mod p). -/

theorem hensel_lift_square (a c p : ℤ) (hp : 0 < p) (hprime : Nat.Prime p.toNat)
    (hroot : p ∣ (a ^ 2 - c))
    (hderiv : ¬ p ∣ (2 * a)) :
    ∃ a' : ℤ, p ^ 2 ∣ (a' ^ 2 - c) ∧ p ∣ (a' - a) := by
  obtain ⟨k, hk⟩ := hroot
  obtain ⟨t, ht⟩ := exists_mod_cancel (2 * a) k p hprime hderiv
  refine ⟨a + p * t, ?_, ⟨t, by ring⟩⟩
  obtain ⟨d, hd⟩ := ht
  refine ⟨d + t ^ 2, ?_⟩
  have : a ^ 2 - c = p * k := hk
  have : k + 2 * a * t = p * d := hd
  nlinarith

/-! ### Lattice Basis for Coppersmith -/


theorem coppersmith_lattice_det (N : ℤ) : N * N = N ^ 2 := by ring

/-! ### Application to Factoring -/

/-- Fermat factoring for odd semiprimes. -/

theorem fermat_factoring_odd (p q : ℤ) (hp : 0 < p) (hq : 0 < q)
    (hpodd : p % 2 = 1) (hqodd : q % 2 = 1) :
    p * q = ((p + q) / 2) ^ 2 - ((q - p) / 2) ^ 2 := by
  nlinarith [ Int.ediv_mul_cancel ( show 2 ∣ p + q from Int.dvd_of_emod_eq_zero ( by rw [ Int.add_emod, hpodd, hqodd ] ; norm_num ) ), Int.ediv_mul_cancel ( show 2 ∣ q - p from Int.dvd_of_emod_eq_zero ( by rw [ Int.sub_emod, hqodd, hpodd ] ; norm_num ) ) ]

/-- The difference of squares identity. -/

theorem diff_sq_factor (a b : ℤ) : a ^ 2 - b ^ 2 = (a - b) * (a + b) := by ring

/-- Fermat's factoring identity. -/

theorem fermat_identity (a b : ℤ) :
    4 * (a * b) = (a + b) ^ 2 - (a - b) ^ 2 := by ring
