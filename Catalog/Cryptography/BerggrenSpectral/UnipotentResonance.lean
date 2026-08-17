import Cryptography.BerggrenSpectral.Generators

/-!
# Unipotent Berggren Resonance mod `N`, and a Factoring Barrier

The generators `M₁` and `M₃` are unipotent (`berg_charpoly_one`, `berg_charpoly_three`), so
their powers grow **polynomially** rather than exponentially.  We compute the powers in closed
form,

```
M₁ ^ k = !![1, -2k, 2k; 2k, 1 - 2k², 2k²; 2k, -2k², 1 + 2k²]
M₃ ^ k = !![1 - 2k², 2k, 2k²; -2k, 1, 2k; -2k², 2k, 1 + 2k²]
```

and deduce the two main results.

* **Exact modular resonance** (`berg_one_pow_eq_one_iff`, `berg_one_orderOf`,
  `berg_three_pow_eq_one_iff`): for every odd modulus `m`, `M₁ ^ k ≡ 1 (mod m)` **iff**
  `m ∣ k`.  Hence the multiplicative order of `M₁` mod `m` is exactly `m`: the "resonant
  frequency" of a unipotent branch is the modulus itself, never a proper divisor of it.

* **Factoring barrier** (`berg_one_gcd_barrier`, `berg_one_no_advantage`): consequently the
  unipotent branch carries **no factoring information**.  Any gcd obtained from a nonzero
  entry of `M₁ ^ k - 1` and an odd modulus `N` already divides `gcd (k², N)`, so every prime
  it reveals is a prime the exponent `k` already contains.  A Pollard-style resonance search
  along the unipotent branches of the Berggren tree is provably useless; all the arithmetic
  content must come from the hyperbolic branch `M₂` (see `HyperbolicResonance.lean`).
-/

namespace BerggrenSpectral

open Matrix

/-- Reduction of an integer `3 × 3` matrix modulo `m`. -/
def redMat (m : ℕ) (A : Matrix (Fin 3) (Fin 3) ℤ) : Matrix (Fin 3) (Fin 3) (ZMod m) :=
  ((Int.castRingHom (ZMod m)).mapMatrix) A

theorem redMat_pow (m : ℕ) (A : Matrix (Fin 3) (Fin 3) ℤ) (k : ℕ) :
    redMat m (A ^ k) = (redMat m A) ^ k := map_pow _ _ _

theorem redMat_apply (m : ℕ) (A : Matrix (Fin 3) (Fin 3) ℤ) (i j : Fin 3) :
    redMat m A i j = ((A i j : ℤ) : ZMod m) := rfl

/-! ## Closed forms for the unipotent powers -/

/-- Closed form for the powers of the first Berggren generator. -/
theorem berg_one_pow (k : ℕ) :
    M₁ ^ k = !![1, -2 * (k : ℤ), 2 * (k : ℤ);
                2 * (k : ℤ), 1 - 2 * (k : ℤ) ^ 2, 2 * (k : ℤ) ^ 2;
                2 * (k : ℤ), -2 * (k : ℤ) ^ 2, 1 + 2 * (k : ℤ) ^ 2] := by
  induction k with
  | zero => ext i j; fin_cases i <;> fin_cases j <;> simp
  | succ n ih =>
    rw [pow_succ, ih]
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [M₁, Matrix.mul_apply, Fin.sum_univ_succ] <;> ring

/-- Closed form for the powers of the third Berggren generator (the catalog matrix `B₃`). -/
theorem berg_three_pow (k : ℕ) :
    M₃ ^ k = !![1 - 2 * (k : ℤ) ^ 2, 2 * (k : ℤ), 2 * (k : ℤ) ^ 2;
                -2 * (k : ℤ), 1, 2 * (k : ℤ);
                -2 * (k : ℤ) ^ 2, 2 * (k : ℤ), 1 + 2 * (k : ℤ) ^ 2] := by
  induction k with
  | zero => ext i j; fin_cases i <;> fin_cases j <;> simp
  | succ n ih =>
    rw [pow_succ, ih]
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [M₃, Matrix.mul_apply, Fin.sum_univ_succ] <;> ring

/-! ## Exact resonance modulo an odd number -/

/-- **Exact unipotent resonance.**  For an odd modulus `m`, the reduction of `M₁` mod `m`
satisfies `M₁ ^ k = 1` exactly when `m ∣ k`. -/
theorem berg_one_pow_eq_one_iff (m k : ℕ) (hm : Odd m) :
    (redMat m M₁) ^ k = 1 ↔ m ∣ k := by
  constructor
  · intro h
    have h' : redMat m (M₁ ^ k) = 1 := by rw [redMat_pow]; exact h
    have hentry := congrFun (congrFun h' 0) 1
    rw [redMat_apply, berg_one_pow] at hentry
    have h2 : ((-2 * (k : ℤ) : ℤ) : ZMod m) = 0 := by simpa [Matrix.one_apply] using hentry
    have hd : (m : ℤ) ∣ (-2 * (k : ℤ)) := (ZMod.intCast_zmod_eq_zero_iff_dvd _ m).mp h2
    have hd2 : (m : ℤ) ∣ 2 * (k : ℤ) := (dvd_neg).mp (by simpa [neg_mul] using hd)
    have hnat : m ∣ 2 * k := by exact_mod_cast hd2
    exact (Nat.coprime_two_right.mpr hm).dvd_of_dvd_mul_left hnat
  · rintro ⟨t, rfl⟩
    rw [← redMat_pow, berg_one_pow]
    ext i j
    fin_cases i <;> fin_cases j <;> simp [redMat]

/-- The same statement for the third generator. -/
theorem berg_three_pow_eq_one_iff (m k : ℕ) (hm : Odd m) :
    (redMat m M₃) ^ k = 1 ↔ m ∣ k := by
  constructor
  · intro h
    have h' : redMat m (M₃ ^ k) = 1 := by rw [redMat_pow]; exact h
    have hentry := congrFun (congrFun h' 0) 1
    rw [redMat_apply, berg_three_pow] at hentry
    have h2 : ((2 * (k : ℤ) : ℤ) : ZMod m) = 0 := by simpa [Matrix.one_apply] using hentry
    have hd : (m : ℤ) ∣ 2 * (k : ℤ) := (ZMod.intCast_zmod_eq_zero_iff_dvd _ m).mp h2
    have hnat : m ∣ 2 * k := by exact_mod_cast hd
    exact (Nat.coprime_two_right.mpr hm).dvd_of_dvd_mul_left hnat
  · rintro ⟨t, rfl⟩
    rw [← redMat_pow, berg_three_pow]
    ext i j
    fin_cases i <;> fin_cases j <;> simp [redMat]

/-- **The resonant frequency of the unipotent branch is the modulus itself.** -/
theorem berg_one_orderOf (m : ℕ) (hm : Odd m) (hpos : 0 < m) :
    orderOf (redMat m M₁) = m := by
  refine (orderOf_eq_iff hpos).mpr ⟨(berg_one_pow_eq_one_iff m m hm).mpr dvd_rfl, ?_⟩
  intro n hn hn0 hcon
  exact absurd (Nat.le_of_dvd hn0 ((berg_one_pow_eq_one_iff m n hm).mp hcon)) (not_le.mpr hn)

/-- The same for the third generator. -/
theorem berg_three_orderOf (m : ℕ) (hm : Odd m) (hpos : 0 < m) :
    orderOf (redMat m M₃) = m := by
  refine (orderOf_eq_iff hpos).mpr ⟨(berg_three_pow_eq_one_iff m m hm).mpr dvd_rfl, ?_⟩
  intro n hn hn0 hcon
  exact absurd (Nat.le_of_dvd hn0 ((berg_three_pow_eq_one_iff m n hm).mp hcon)) (not_le.mpr hn)

/-- In particular, for `N = p * q` the unipotent generator has order exactly `N` — the two
prime "frequencies" `p` and `q` are *not* separated by the unipotent flow. -/
theorem berg_one_orderOf_semiprime (p q : ℕ) (hp : Odd p) (hq : Odd q) (hp0 : 0 < p)
    (hq0 : 0 < q) : orderOf (redMat (p * q) M₁) = p * q :=
  berg_one_orderOf _ (hp.mul hq) (Nat.mul_pos hp0 hq0)

/-! ## The factoring barrier -/

/-- Every entry of `M₁ ^ k - 1` is `0`, `±2k`, or `±2k²`. -/
theorem berg_one_entries (k : ℕ) (i j : Fin 3) :
    (M₁ ^ k - 1) i j = 0 ∨ (M₁ ^ k - 1) i j = 2 * (k : ℤ) ∨ (M₁ ^ k - 1) i j = -2 * (k : ℤ) ∨
      (M₁ ^ k - 1) i j = 2 * (k : ℤ) ^ 2 ∨ (M₁ ^ k - 1) i j = -2 * (k : ℤ) ^ 2 := by
  rw [berg_one_pow]
  fin_cases i <;> fin_cases j <;> simp

/-- Auxiliary gcd bound: a divisor of `±2k` or `±2k²` that is coprime to `2` divides `k²`. -/
private theorem gcd_dvd_gcd_sq {N k : ℕ} (hN : Odd N) {x : ℤ}
    (hx : x = 2 * (k : ℤ) ∨ x = -2 * (k : ℤ) ∨ x = 2 * (k : ℤ) ^ 2 ∨ x = -2 * (k : ℤ) ^ 2) :
    Int.gcd x (N : ℤ) ∣ Nat.gcd (k ^ 2) N := by
  set g := Int.gcd x (N : ℤ) with hg
  have hgN : g ∣ N := by exact_mod_cast Int.gcd_dvd_right x (N : ℤ)
  have hgx : (g : ℤ) ∣ x := Int.gcd_dvd_left x (N : ℤ)
  have hk2 : (g : ℤ) ∣ 2 * (k : ℤ) ^ 2 := by
    rcases hx with h | h | h | h <;> rw [h] at hgx
    · exact hgx.trans ⟨(k : ℤ), by ring⟩
    · exact hgx.trans ⟨-(k : ℤ), by ring⟩
    · exact hgx
    · exact hgx.trans ⟨-1, by ring⟩
  have hnat : g ∣ 2 * k ^ 2 := by exact_mod_cast hk2
  have hg2 : Nat.Coprime g 2 := Nat.Coprime.coprime_dvd_left hgN (Nat.coprime_two_right.mpr hN)
  exact Nat.dvd_gcd (hg2.dvd_of_dvd_mul_left hnat) hgN

/-- **Factoring barrier for the unipotent branch.**  For an odd modulus `N`, the gcd of any
nonzero entry of `M₁ ^ k - 1` with `N` divides `gcd (k², N)`. -/
theorem berg_one_gcd_barrier (N k : ℕ) (hN : Odd N) (i j : Fin 3)
    (h : (M₁ ^ k - 1) i j ≠ 0) :
    Int.gcd ((M₁ ^ k - 1) i j) (N : ℤ) ∣ Nat.gcd (k ^ 2) N := by
  rcases berg_one_entries k i j with h0 | hx
  · exact absurd h0 h
  · exact gcd_dvd_gcd_sq hN hx

/-- **No factoring advantage.**  Any prime revealed by the unipotent branch already divides
the exponent `k`; so one has to *know* a prime factor of `N` before the unipotent resonance
can display it. -/
theorem berg_one_no_advantage (N k : ℕ) (hN : Odd N) (i j : Fin 3)
    (h : (M₁ ^ k - 1) i j ≠ 0) {r : ℕ} (hr : r.Prime)
    (hdvd : r ∣ Int.gcd ((M₁ ^ k - 1) i j) (N : ℤ)) : r ∣ k ∧ r ∣ N := by
  have h1 := hdvd.trans (berg_one_gcd_barrier N k hN i j h)
  exact ⟨hr.dvd_of_dvd_pow (h1.trans (Nat.gcd_dvd_left _ _)), h1.trans (Nat.gcd_dvd_right _ _)⟩

end BerggrenSpectral