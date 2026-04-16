/-! # CatalogBuild.Cryptography.Factoring.HyperbolicFactoring

Auto-generated from theorem catalog database.
Domain: Cryptography/Factoring
Declarations: 8
-/

import Mathlib

/-- The divisor hyperbola: points (d, n/d) for d | n.
The divisors come in pairs (d, n/d) which are symmetric. -/
theorem hyperbola_symmetry {n d : ℕ} (hd : d ∣ n) :
    (n / d) ∣ n :=
  Nat.div_dvd_of_dvd hd



/-- d² ≤ n implies d ≤ n for any divisor d (the "small" divisor). -/
theorem small_divisor_bound {n d : ℕ} (hd : d ∣ n) (hn : 0 < n) :
    d ≤ n :=
  Nat.le_of_dvd hn hd



/-- The determinant is preserved under multiplication. -/
theorem SL2Z.mul_det (M N : SL2Z) :
    (SL2Z.mul M N).a * (SL2Z.mul M N).d - (SL2Z.mul M N).b * (SL2Z.mul M N).c = 1 :=
  (SL2Z.mul M N).det_eq



/-- Consecutive convergents of a continued fraction satisfy |pq' - p'q| = 1,
which implies they are coprime. -/
theorem convergent_coprime_of_det_one {p q : ℤ} (hq : 0 < q)
    (h : ∃ p' q' : ℤ, p * q' - p' * q = 1) :
    IsCoprime p q := by
  obtain ⟨p', q', hdet⟩ := h
  exact ⟨q', -p', by linarith⟩



/-- The mediant of two fractions a/b and c/d is (a+c)/(b+d).
If they are Farey neighbors, b+d > 0. -/
theorem farey_mediant_denominator {b d : ℕ} (hb : 0 < b) (hd : 0 < d) :
    0 < b + d := by omega



/-- The "hyperbolic" relationship between divisor pairs: if d₁ ≤ d₂ are both
divisors of n, then n/d₂ ≤ n/d₁ (the companion divisors are reversed). -/
theorem divisor_companion_reversed {d₁ d₂ n : ℕ}
    (hd1 : d₁ ∣ n) (hd2 : d₂ ∣ n)
    (hd1_pos : 0 < d₁) (hle : d₁ ≤ d₂) :
    n / d₂ ≤ n / d₁ :=
  Nat.div_le_div_left hle hd1_pos



/-- If a is a nonzero quadratic residue mod p, then its square root is also nonzero. -/
theorem quadratic_residue_nonzero {p : ℕ} (hp : Nat.Prime p)
    {a : ZMod p} (ha : a ≠ 0) (hsq : ∃ x : ZMod p, x * x = a) :
    ∃ x : ZMod p, x * x = a ∧ x ≠ 0 := by
  obtain ⟨x, hx⟩ := hsq
  exact ⟨x, hx, fun hx0 => ha (by rw [← hx, hx0, mul_zero])⟩



/-- The CRT projection: QR mod pq implies QR mod p. -/
theorem crt_quadratic_residue {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    {a : ZMod (p * q)} :
    (∃ x : ZMod (p * q), x * x = a) →
    (∃ xp : ZMod p, xp * xp = ZMod.castHom (dvd_mul_right p q) (ZMod p) a) := by
  intro ⟨x, hx⟩
  exact ⟨ZMod.castHom (dvd_mul_right p q) (ZMod p) x, by rw [← map_mul, hx]⟩


