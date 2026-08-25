/-
# Square positions of the sieve polynomial: the terminal Fermat position

Third companion to `Catalog/NumberTheory/FermatPositionGeometry.lean`.

Among all positions `j` of the sieve polynomial `v(j) = (b + j)^2 - N` the *square*
positions — those with `v(j)` a perfect square — are exactly the factorizations of `N`.
This is Fermat's method, and it gives the one piece of **exactly known** positional
geometry of the smooth locus, against which any statistical claim about hit positions can
be calibrated.

Main results.

* `sieveVal_eq_sq_iff` : `v(j) = k²` iff `N = (b + j - k)(b + j + k)`.
* `sieveVal_at_mid` : writing `N = s² - d²`, the position `s - b` is a square position
  with value `d²`; for `N = p q` with `p + q = 2s`, `q - p = 2d` this is the *terminal
  Fermat position*.
* `terminal_position_bound` : `2 b (s - b) ≤ d²`, i.e. the terminal position obeys the
  same linear magnitude law `2 b j ≤ v(j)` as every other position.  Balanced semiprimes
  (small `d` relative to `√N`) have their terminal position at small `j`; this is a
  *magnitude* statement, not extra positional structure.
* `semiprime_factor_pairs` : the factorizations of a semiprime.
* `square_position_unique` : the only square positions of a semiprime sieve are the
  trivial one (`b + j - k = 1`) and the terminal Fermat position `2 (b + j) = p + q`.
-/
import Mathlib
import Catalog.NumberTheory.FermatPositionGeometry

namespace FermatPosition

/-- A position is a *square position* exactly when it exhibits a factorization of `N`. -/
theorem sieveVal_eq_sq_iff (b N j k : ℤ) :
    sieveVal b N j = k ^ 2 ↔ N = (b + j - k) * (b + j + k) := by
  simp only [sieveVal]
  constructor <;> intro h <;> nlinarith [h]

/-- Writing `N = s² - d²`, the position `s - b` is a square position with value `d²`. -/
theorem sieveVal_at_mid (b s d : ℤ) : sieveVal b (s ^ 2 - d ^ 2) (s - b) = d ^ 2 := by
  simp only [sieveVal]; ring

/-- The terminal Fermat position of `N = p q`, written through `p + q = 2 s` and
`q - p = 2 d`: the value there is the perfect square `d²`. -/
theorem sieveVal_terminal (b p q s d : ℤ) (hs : p + q = 2 * s) (hd : q - p = 2 * d) :
    sieveVal b (p * q) (s - b) = d ^ 2 := by
  have h4 : 4 * (p * q) = 4 * (s ^ 2 - d ^ 2) := by
    linear_combination (p + q + 2 * s) * hs - (q - p + 2 * d) * hd
  have hN : p * q = s ^ 2 - d ^ 2 := by linarith
  rw [hN, sieveVal_at_mid]

/-- **The terminal position obeys the magnitude law.**  If `b ≤ s` and `b² ≥ N = s² - d²`
(as for `b = ⌈√N⌉`), the terminal Fermat position `j₀ = s - b` satisfies `2 b j₀ ≤ d²`.
Thus a balanced semiprime has its terminal position at small `j` *because* the value
there is the small square `d²` — magnitude, not positional structure. -/
theorem terminal_position_bound {b s d : ℤ} (hs : b ≤ s)
    (hN : s ^ 2 - d ^ 2 ≤ b ^ 2) : 2 * b * (s - b) ≤ d ^ 2 := by
  nlinarith [hs, hN]

/-- The factorizations of a semiprime: an ordered factor pair of `p q` with `p ≤ q` both
prime is either the trivial pair or `(p, q)` itself. -/
theorem semiprime_factor_pairs {p q u w : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (h : u * w = p * q) (huw : u ≤ w) : (u = 1 ∧ w = p * q) ∨ (u = p ∧ w = q) := by
  have hp2 : 2 ≤ p := hp.two_le
  have hq2 : 2 ≤ q := hq.two_le
  have hu : u ∣ p * q := ⟨w, h.symm⟩
  by_cases hpu : p ∣ u
  · obtain ⟨u', rfl⟩ := hpu
    have hq' : u' * w = q := by
      have : p * (u' * w) = p * q := by rw [← h]; ring
      exact Nat.eq_of_mul_eq_mul_left (by omega) this
    have hu'dvd : u' ∣ q := ⟨w, hq'.symm⟩
    rcases (Nat.Prime.eq_one_or_self_of_dvd hq u' hu'dvd) with h1 | h1
    · subst h1
      exact Or.inr ⟨by ring, by simpa using hq'⟩
    · exfalso
      rw [h1] at hq' huw
      have hw : w = 1 := by
        have : q * w = q * 1 := by omega
        exact Nat.eq_of_mul_eq_mul_left (by omega) this
      rw [hw] at huw
      nlinarith
  · have hcop : Nat.Coprime p u := (Nat.Prime.coprime_iff_not_dvd hp).2 hpu
    have hudvd : u ∣ q := Nat.Coprime.dvd_of_dvd_mul_left (Nat.Coprime.symm hcop) hu
    rcases (Nat.Prime.eq_one_or_self_of_dvd hq u hudvd) with h1 | h1
    · subst h1
      exact Or.inl ⟨rfl, by simpa using h⟩
    · subst h1
      have hw : w = p := by
        have h5 : u * w = u * p := by rw [h]; ring
        exact Nat.eq_of_mul_eq_mul_left (by omega) h5
      have hup : u = p := le_antisymm (by omega) hpq
      exact Or.inr ⟨hup, by omega⟩

/-- **Square positions of a semiprime sieve.**  If `v(j) = k²` at a position with
`1 < b + j - k`, then the position is the terminal Fermat position: `2 (b + j) = p + q`.
Every other square position is the trivial factorization `b + j - k = 1`. -/
theorem square_position_unique {b j k : ℤ} {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≤ q) (hk : 0 ≤ k) (hu : 1 < b + j - k)
    (hval : sieveVal b ((p : ℤ) * q) j = k ^ 2) :
    2 * (b + j) = (p : ℤ) + q := by
  have hfac : ((p : ℤ) * q) = (b + j - k) * (b + j + k) := (sieveVal_eq_sq_iff _ _ _ _).1 hval
  set u : ℤ := b + j - k with hudef
  set w : ℤ := b + j + k with hwdef
  have huw : u ≤ w := by simp only [hudef, hwdef]; linarith
  have hu0 : 0 < u := by omega
  have hw0 : 0 < w := lt_of_lt_of_le hu0 huw
  have hnat : u.toNat * w.toNat = p * q := by
    have : ((u.toNat * w.toNat : ℕ) : ℤ) = ((p * q : ℕ) : ℤ) := by
      push_cast [Int.toNat_of_nonneg (le_of_lt hu0), Int.toNat_of_nonneg (le_of_lt hw0)]
      linarith [hfac]
    exact_mod_cast this
  have hle : u.toNat ≤ w.toNat := by omega
  rcases semiprime_factor_pairs hp hq hpq hnat hle with ⟨h1, _⟩ | ⟨h1, h2⟩
  · exfalso
    have : u = 1 := by omega
    omega
  · have hu' : u = (p : ℤ) := by omega
    have hw' : w = (q : ℤ) := by omega
    simp only [hudef, hwdef] at hu' hw'
    linarith

end FermatPosition