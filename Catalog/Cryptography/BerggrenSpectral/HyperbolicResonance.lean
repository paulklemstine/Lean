import Cryptography.BerggrenSpectral.UnipotentResonance

/-!
# Hyperbolic Berggren Resonance: the frequencies `2(p ∓ 1)`

The middle Berggren generator `M₂` is hyperbolic, with spectrum `{-1, 3 + 2√2, 3 - 2√2}`
(`berg_charpoly_two`).  This file proves that **modulo a prime `p` the resonant exponent of
`M₂` is `2(p - 1)` or `2(p + 1)` according to the quadratic character of `2`, i.e. according
to `p mod 8`** — the "energy frequency" of the hyperbolic branch is locked to the prime.

The proof is a fully explicit Frobenius computation.

1.  `berg_conj`: the integral conjugation `M₂ * W = W * V`, where the columns of
    `W = !![1,0,1; 1,0,-1; 0,1,0]` are the invariant vectors `(1,1,0)`, `(0,0,1)` and the
    `-1`-eigenvector `(1,-1,0)`, and `V` is block diagonal with blocks `U = !![3,2;4,3]`
    and `(-1)`.
2.  `bergU_frob`: over `ZMod p`, `U = 3 + S` with `S² = 8`, so the Frobenius endomorphism
    gives `U ^ p = 3 + 8^((p-1)/2) • S`; this is the matrix incarnation of
    `(3 + 2√2)^p = 3 ± 2√2` in `𝔽_p(√2)`.
3.  Hence `U ^ (p - 1) = 1` when `2` is a square mod `p` and `U ^ (p + 1) = 1` otherwise
    (`bergU_pow_qr`, `bergU_pow_nqr`), because `U⁻¹ = 6 - U`.
4.  Transporting back through `W` (invertible because `det W = -2` and `p` is odd) and
    squaring to kill the `-1` eigenvalue yields the main theorems
    `berg_two_resonance_qr`, `berg_two_resonance_nqr`, `berg_two_resonance_mod_eight`
    and the uniform `berg_two_resonance` : `M₂ ^ (2 * (p² - 1)) ≡ 1 (mod p)`.

This is the exact analogue, for the Pythagorean/Berggren tree, of the Lucas–Lehmer and
Pollard `p ± 1` phenomena; the factoring consequences are in `Factorization.lean`.
-/

namespace BerggrenSpectral

open Matrix

variable (R : Type*) [CommRing R]

/-! ## The hyperbolic block and the conjugating matrix -/

/-- The `2 × 2` hyperbolic block of `M₂` in the basis `(1,1,0), (0,0,1)`. -/
def bergU : Matrix (Fin 2) (Fin 2) R := !![3, 2; 4, 3]

/-- The traceless part of `bergU`; it satisfies `S² = 8`, the matrix form of `√8 = 2√2`. -/
def bergS : Matrix (Fin 2) (Fin 2) R := !![0, 2; 4, 0]

/-- Conjugating matrix: columns are `(1,1,0)`, `(0,0,1)` (spanning the hyperbolic plane) and
`(1,-1,0)` (the `-1`-eigenvector). -/
def bergW : Matrix (Fin 3) (Fin 3) R := !![1, 0, 1; 1, 0, -1; 0, 1, 0]

/-- Block-diagonal normal form of `M₂`. -/
def bergV : Matrix (Fin 3) (Fin 3) R := !![3, 2, 0; 4, 3, 0; 0, 0, -1]

/-- `M₂` over an arbitrary commutative ring. -/
def M2R : Matrix (Fin 3) (Fin 3) R := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Embedding of a `2 × 2` block plus a scalar into `3 × 3` matrices. -/
def blockEmbed (A : Matrix (Fin 2) (Fin 2) R) (c : R) : Matrix (Fin 3) (Fin 3) R :=
  !![A 0 0, A 0 1, 0; A 1 0, A 1 1, 0; 0, 0, c]

variable {R}

theorem blockEmbed_mul (A B : Matrix (Fin 2) (Fin 2) R) (c d : R) :
    blockEmbed R A c * blockEmbed R B d = blockEmbed R (A * B) (c * d) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [blockEmbed, Matrix.mul_apply, Fin.sum_univ_succ]

theorem blockEmbed_one : blockEmbed R (1 : Matrix (Fin 2) (Fin 2) R) 1 = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [blockEmbed]

theorem bergV_eq : bergV R = blockEmbed R (bergU R) (-1) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [bergV, blockEmbed, bergU]

/-- Powers of the normal form are block powers. -/
theorem bergV_pow (k : ℕ) : (bergV R) ^ k = blockEmbed R ((bergU R) ^ k) ((-1 : R) ^ k) := by
  induction k with
  | zero => simpa using (blockEmbed_one (R := R)).symm
  | succ n ih => rw [pow_succ, ih, bergV_eq, blockEmbed_mul, ← pow_succ, ← pow_succ]

/-- **The integral conjugation.** -/
theorem berg_conj : M2R R * bergW R = bergW R * bergV R := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [M2R, bergW, bergV, Matrix.mul_apply, Fin.sum_univ_succ] <;> ring

theorem berg_pow_conj (k : ℕ) : (M2R R) ^ k * bergW R = bergW R * (bergV R) ^ k := by
  induction k with
  | zero => simp
  | succ n ih => rw [pow_succ, pow_succ, mul_assoc, berg_conj, ← mul_assoc, ih, mul_assoc]

theorem det_bergW : (bergW R).det = 2 := by
  rw [bergW, Matrix.det_fin_three]
  simp [Matrix.cons_val_two, Matrix.tail_cons, Matrix.head_cons, Matrix.cons_val_one,
    Matrix.cons_val_zero]
  ring

/-! ## Algebraic identities for the hyperbolic block -/

theorem bergS_sq : (bergS R) ^ 2 = (8 : R) • 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [bergS, pow_two, Matrix.mul_apply, Fin.sum_univ_succ] <;> ring

theorem bergU_eq : bergU R = (3 : R) • 1 + bergS R := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [bergU, bergS]

/-- `U⁻¹ = 6 - U`: the hyperbolic block is a unit of determinant `1`. -/
theorem bergU_inv : bergU R * ((6 : R) • 1 - bergU R) = 1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [bergU, Matrix.mul_apply, Fin.sum_univ_succ, Matrix.one_apply] <;> ring

theorem det_bergU : (bergU R).det = 1 := by simp [bergU, Matrix.det_fin_two]; ring

/-! ## Frobenius over `ZMod p` -/

variable (p : ℕ) [Fact p.Prime]

/-- **Matrix Frobenius.**  `U ^ p = 3 + 8^((p-1)/2) • S`, the matrix incarnation of
`(3 + 2√2)^p = 3 ± 2√2` in `𝔽_p(√2)`. -/
theorem bergU_frob (hp : p ≠ 2) :
    (bergU (ZMod p)) ^ p = (3 : ZMod p) • 1 + ((8 : ZMod p) ^ ((p - 1) / 2)) • bergS (ZMod p) := by
  have hodd : Odd p := (Nat.Prime.odd_of_ne_two Fact.out hp)
  have hp1 : p = 2 * ((p - 1) / 2) + 1 := by obtain ⟨t, ht⟩ := hodd; omega
  have hcomm : Commute ((3 : ZMod p) • (1 : Matrix (Fin 2) (Fin 2) (ZMod p))) (bergS (ZMod p)) := by
    simp [Commute, SemiconjBy]
  have hSp : bergS (ZMod p) ^ p = ((8 : ZMod p) ^ ((p - 1) / 2)) • bergS (ZMod p) := by
    have h1 : bergS (ZMod p) ^ p = bergS (ZMod p) ^ (2 * ((p - 1) / 2) + 1) := by rw [← hp1]
    rw [h1, pow_succ, pow_mul, bergS_sq, smul_pow, one_pow, smul_mul_assoc, one_mul]
  rw [bergU_eq, add_pow_char_of_commute _ hcomm, smul_pow, one_pow, ZMod.pow_card, hSp]

/-- The quadratic character of `2` controls the Frobenius twist, because `8 = 2³` and the
character takes values `±1`. -/
theorem eight_pow_eq_two_pow :
    (8 : ZMod p) ^ ((p - 1) / 2) = ((2 : ZMod p) ^ ((p - 1) / 2)) ^ 3 := by
  rw [show (8 : ZMod p) = 2 ^ 3 by norm_num, ← pow_mul, ← pow_mul, mul_comm]

theorem two_ne_zero_of_odd_prime (hp : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  intro h
  have h2 : ((2 : ℤ) : ZMod p) = 0 := by exact_mod_cast h
  have hd : (p : ℤ) ∣ 2 := (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp h2
  have hd' : p ∣ 2 := by exact_mod_cast hd
  exact hp ((Nat.prime_dvd_prime_iff_eq Fact.out Nat.prime_two).mp hd')

/-- The Legendre symbol of `2` squares to `1`. -/
theorem two_chi_sq (hp : p ≠ 2) : ((2 : ZMod p) ^ ((p - 1) / 2)) ^ 2 = 1 := by
  have hodd : Odd p := (Nat.Prime.odd_of_ne_two Fact.out hp)
  have hp1 : 2 * ((p - 1) / 2) = p - 1 := by obtain ⟨t, ht⟩ := hodd; omega
  rw [← pow_mul, mul_comm, hp1]
  exact ZMod.pow_card_sub_one_eq_one (two_ne_zero_of_odd_prime p hp)

/-- If `2` is a quadratic residue mod `p`, the hyperbolic block has order dividing `p - 1`. -/
theorem bergU_pow_qr (hp : p ≠ 2) (h : (2 : ZMod p) ^ ((p - 1) / 2) = 1) :
    (bergU (ZMod p)) ^ (p - 1) = 1 := by
  have hp0 : 1 ≤ p := (Fact.out : p.Prime).one_lt.le.trans' (by norm_num)
  have hfrob : (bergU (ZMod p)) ^ p = bergU (ZMod p) := by
    rw [bergU_frob p hp, eight_pow_eq_two_pow p, h, one_pow, one_smul, ← bergU_eq]
  have hsucc : (bergU (ZMod p)) ^ (p - 1) * bergU (ZMod p) = (bergU (ZMod p)) ^ p := by
    rw [← pow_succ]; congr 1; omega
  calc (bergU (ZMod p)) ^ (p - 1)
      = (bergU (ZMod p)) ^ (p - 1) * (bergU (ZMod p) * ((6 : ZMod p) • 1 - bergU (ZMod p))) := by
        rw [bergU_inv, mul_one]
    _ = ((bergU (ZMod p)) ^ (p - 1) * bergU (ZMod p)) * ((6 : ZMod p) • 1 - bergU (ZMod p)) := by
        rw [mul_assoc]
    _ = bergU (ZMod p) * ((6 : ZMod p) • 1 - bergU (ZMod p)) := by rw [hsucc, hfrob]
    _ = 1 := bergU_inv

/-- If `2` is a quadratic non-residue mod `p`, the hyperbolic block has order dividing
`p + 1`. -/
theorem bergU_pow_nqr (hp : p ≠ 2) (h : (2 : ZMod p) ^ ((p - 1) / 2) = -1) :
    (bergU (ZMod p)) ^ (p + 1) = 1 := by
  have hfrob : (bergU (ZMod p)) ^ p = (6 : ZMod p) • 1 - bergU (ZMod p) := by
    rw [bergU_frob p hp, eight_pow_eq_two_pow p, h]
    ext i j
    fin_cases i <;> fin_cases j <;> simp [bergS, bergU] <;> ring
  rw [pow_succ, hfrob, sub_mul, smul_mul_assoc, one_mul]
  ext i j
  fin_cases i <;> fin_cases j <;> simp [bergU] <;> ring

/-- `p² - 1 = (p-1)(p+1)` in `ℕ`. -/
theorem sq_sub_one_nat (n : ℕ) : n ^ 2 - 1 = (n - 1) * (n + 1) := by
  cases n with
  | zero => rfl
  | succ m => simp only [Nat.add_sub_cancel]; exact (Nat.sub_eq_of_eq_add (by ring))

/-! ## Transport back to `M₂` -/

/-- If the hyperbolic block has trivial `k`-th power and `k` is even, then `M₂ ^ k ≡ 1`. -/
theorem M2R_pow_eq_one (hp : p ≠ 2) {k : ℕ} (hU : (bergU (ZMod p)) ^ k = 1) (hk : Even k) :
    (M2R (ZMod p)) ^ k = 1 := by
  have hdet : IsUnit (bergW (ZMod p)).det := by
    rw [det_bergW]
    exact (isUnit_iff_ne_zero).mpr (two_ne_zero_of_odd_prime p hp)
  haveI : Invertible (bergW (ZMod p)) := invertibleOfIsUnitDet _ hdet
  have hV : (bergV (ZMod p)) ^ k = 1 := by
    rw [bergV_pow, hU, hk.neg_one_pow, blockEmbed_one]
  have h := berg_pow_conj (R := ZMod p) k
  rw [hV, mul_one] at h
  have h1 : (M2R (ZMod p)) ^ k * bergW (ZMod p) = 1 * bergW (ZMod p) := by rw [h, one_mul]
  exact mul_left_injective_of_invertible (bergW (ZMod p)) h1

/-- The reduction of the integral `M₂` mod `p` is the generic `M2R`. -/
theorem redMat_M₂ (m : ℕ) : redMat m M₂ = M2R (ZMod m) := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [redMat, M₂, M2R]

/-- `p - 1` is even for an odd prime. -/
theorem even_sub_one (hp : p ≠ 2) : Even (p - 1) := by
  have hodd : Odd p := (Nat.Prime.odd_of_ne_two Fact.out hp)
  obtain ⟨t, ht⟩ := hodd
  exact ⟨t, by omega⟩

/-- `p + 1` is even for an odd prime. -/
theorem even_add_one (hp : p ≠ 2) : Even (p + 1) := by
  have hodd : Odd p := (Nat.Prime.odd_of_ne_two Fact.out hp)
  obtain ⟨t, ht⟩ := hodd
  exact ⟨t + 1, by omega⟩

/-- **Hyperbolic resonance, residue case.**  If `2` is a quadratic residue mod `p` then
`M₂ ^ (p - 1) ≡ 1 (mod p)`.  (The `-1` eigenvalue costs nothing: `p - 1` is already even.) -/
theorem berg_two_resonance_qr (hp : p ≠ 2) (h : (2 : ZMod p) ^ ((p - 1) / 2) = 1) :
    (redMat p M₂) ^ (p - 1) = 1 := by
  rw [redMat_M₂]
  exact M2R_pow_eq_one p hp (bergU_pow_qr p hp h) (even_sub_one p hp)

/-- **Hyperbolic resonance, non-residue case.**  If `2` is a quadratic non-residue mod `p`
then `M₂ ^ (p + 1) ≡ 1 (mod p)`. -/
theorem berg_two_resonance_nqr (hp : p ≠ 2) (h : (2 : ZMod p) ^ ((p - 1) / 2) = -1) :
    (redMat p M₂) ^ (p + 1) = 1 := by
  rw [redMat_M₂]
  exact M2R_pow_eq_one p hp (bergU_pow_nqr p hp h) (even_add_one p hp)

/-- The character of `2` is `±1`. -/
theorem two_chi_cases (hp : p ≠ 2) :
    (2 : ZMod p) ^ ((p - 1) / 2) = 1 ∨ (2 : ZMod p) ^ ((p - 1) / 2) = -1 := by
  have h := two_chi_sq p hp
  have : ((2 : ZMod p) ^ ((p - 1) / 2) - 1) * ((2 : ZMod p) ^ ((p - 1) / 2) + 1) = 0 := by
    linear_combination h
  rcases mul_eq_zero.mp this with h1 | h1
  · exact Or.inl (by linear_combination h1)
  · exact Or.inr (by linear_combination h1)

/-- **Uniform hyperbolic resonance.**  For every odd prime `p`, `M₂ ^ (p² - 1) ≡ 1 (mod p)`:
the resonant frequency of the hyperbolic Berggren branch divides `p² - 1`, and in fact
divides `p - 1` or `p + 1`. -/
theorem berg_two_resonance (hp : p ≠ 2) : (redMat p M₂) ^ (p ^ 2 - 1) = 1 := by
  rcases two_chi_cases p hp with h | h
  · obtain ⟨t, ht⟩ : (p - 1) ∣ (p ^ 2 - 1) := ⟨p + 1, sq_sub_one_nat p⟩
    rw [ht, pow_mul, berg_two_resonance_qr p hp h, one_pow]
  · obtain ⟨t, ht⟩ : (p + 1) ∣ (p ^ 2 - 1) := ⟨p - 1, by rw [sq_sub_one_nat p]; ring⟩
    rw [ht, pow_mul, berg_two_resonance_nqr p hp h, one_pow]

/-- **Resonance is governed by `p mod 8`.**  The Berggren hyperbolic frequency divides `p-1`
exactly for `p ≡ ±1 (mod 8)` and divides `p+1` for `p ≡ ±3 (mod 8)`. -/
theorem berg_two_resonance_mod_eight (hp : p ≠ 2) :
    (p % 8 = 1 ∨ p % 8 = 7 → (redMat p M₂) ^ (p - 1) = 1) ∧
    (p % 8 = 3 ∨ p % 8 = 5 → (redMat p M₂) ^ (p + 1) = 1) := by
  have hne : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd_prime p hp
  have hhalf : p / 2 = (p - 1) / 2 := by
    have hodd : Odd p := (Nat.Prime.odd_of_ne_two Fact.out hp)
    obtain ⟨t, ht⟩ := hodd; omega
  constructor
  · intro h8
    have hsq : IsSquare (2 : ZMod p) := (ZMod.exists_sq_eq_two_iff hp).mpr h8
    have := (ZMod.euler_criterion p hne).mp hsq
    rw [hhalf] at this
    exact berg_two_resonance_qr p hp this
  · intro h8
    have hsq : ¬ IsSquare (2 : ZMod p) := by
      intro hs
      rcases (ZMod.exists_sq_eq_two_iff hp).mp hs with h | h <;> omega
    have hne1 : (2 : ZMod p) ^ ((p - 1) / 2) ≠ 1 := by
      intro hcon
      exact hsq ((ZMod.euler_criterion p hne).mpr (by rw [hhalf]; exact hcon))
    rcases two_chi_cases p hp with h | h
    · exact absurd h hne1
    · exact berg_two_resonance_nqr p hp h

end BerggrenSpectral