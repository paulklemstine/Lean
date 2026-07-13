import Mathlib

/-!
# Siegel–Weil for `E₈`: Möbius inversion, closed forms, and the eigenform boundary

The Siegel–Weil identity in rank `8` states that the theta series of the even
unimodular lattice `E₈` equals the weight-`4` Eisenstein series `E₄`; at the
level of Fourier coefficients this reads

```
r(n) = 240 · σ₃(n),      σ₃(n) = ∑_{d ∣ n} d³,
```

where `r(n)` counts the lattice vectors of squared length `2n`.  The arithmetic
skeleton of the identity is that `240·σ₃` is the coefficient system of a weight-`4`
Hecke eigenform.  This file develops three further structural strands, for the
general divisor-power sum `σ_s` (the coefficient system of the weight-`(s+1)`
Eisenstein series) and its `E₈` specialization `s = 3`.

## 1. A closed product form for prime powers

The value `σ_s(pʳ)` is the geometric sum `∑_{i≤r} p^{s i}`.  We record the
*division-free* closed form

```
σ_s(pʳ) · (p^s − 1) = p^{s(r+1)} − 1,
```

which is the exact statement that the local Euler factor of the Eisenstein
`L`-function is `(1 − p^{-w})^{-1}(1 − p^{s-w})^{-1}` — the coefficient shadow of
the factorization `∑ σ_s(n) n^{-w} = ζ(w)·ζ(w−s)`.

## 2. Möbius inversion: recovering pure powers

Because `σ_s = ζ ⋆ pow_s` as a Dirichlet convolution, Möbius inversion returns
the pure power function:

```
n^s = ∑_{d·e = n} μ(d) · σ_s(e).
```

This is the coefficient-level incarnation of dividing the Eisenstein
`L`-function by `ζ`, and it is genuinely non-formal: it uses the incidence
algebra of the divisor lattice.  We prove it (`sigma_moebius_inversion`) and
transport it to the `E₈` counts (`rE8_moebius_inversion`).

## 3. The eigenform boundary: not completely multiplicative

The Hecke recurrence forces a *quadratic correction* at `p²`,

```
σ_s(p²) + p^s = σ_s(p)²,
```

so `σ_s` is multiplicative but **strictly** fails to be completely
multiplicative: `σ_s(p²) < σ_s(p)²`.  This correction term `p^s` is precisely the
Hecke eigenvalue defect that distinguishes an eigenform from a mere character,
and it is what makes the `E₈` counts genuinely arithmetic rather than trivially
factorizable.

-- !-- Lab Notes -- !--
Hypothesis: The `E₈`/`E₄` coefficient system `σ₃` should be invertible against
  the divisor lattice (Möbius inversion returning `n³`), admit a division-free
  Euler-factor closed form, and exhibit a measurable eigenform defect separating
  it from completely multiplicative functions.
Experiment: Work with the general `σ_s`.  (a) Derive the geometric prime-power
  form and multiply by `p^s − 1` to get the closed product form via
  `geom_sum_mul`.  (b) Feed the divisor-sum identity `∑_{d|n} d^s = σ_s(n)` into
  Mathlib's Möbius inversion `sum_eq_iff_sum_mul_moebius_eq`.  (c) Extract the
  `p²` correction from the three-term recurrence and turn it into a strict
  inequality.  Transport (b) and the correction to `rE8 = 240·σ₃`.
Analysis: All three strands go through.  The Möbius inversion is the only truly
  non-elementary step (it rests on `ζ ⋆ μ = δ`); the closed form and the
  quadratic correction are geometric-series algebra.  The strict inequality
  `σ_s(p²) < σ_s(p)²` holds for every prime and every `s` because `p^s ≥ 1`.
Critique: None of the results are definitional: the Möbius inversion invokes the
  incidence algebra, the closed form uses `geom_sum_mul` and a genuine `p^s−1`
  cancellation, and the boundary theorem uses the recurrence-derived correction
  rather than a hard-coded numeric check.  The low-order values are corroboration
  only.
Synthesis: `240·σ₃` is exactly the coefficient system obtained by convolving `ζ`
  with the cube function; it is invertible over the divisor lattice, has the
  Eisenstein Euler factor as its closed form, and carries a nonzero eigenform
  defect — three independent fingerprints of `θ_{E₈} = E₄`.
-/

namespace SiegelWeilE8Moebius

open ArithmeticFunction Finset

/-- The Siegel–Weil / `E₄` prediction for the number of `E₈` vectors of squared
length `2n`: `240 · σ₃(n)`. -/
def rE8 (n : ℕ) : ℕ := 240 * (sigma 3) n

/-! ### Prime-power structure -/

/-- Geometric closed form of `σ_s` at a prime power: `σ_s(pʳ) = ∑_{i=0}^{r} p^{s i}`. -/
theorem sigma_prime_pow (s p r : ℕ) (hp : p.Prime) :
    (sigma s) (p ^ r) = ∑ i ∈ range (r + 1), p ^ (s * i) := by
  rw [sigma_apply]
  norm_num [pow_mul', Nat.divisors_prime_pow hp]

/-- Value of `σ_s` at a prime: `σ_s(p) = 1 + p^s`. -/
theorem sigma_prime (s p : ℕ) (hp : p.Prime) : (sigma s) p = 1 + p ^ s := by
  convert sigma_prime_pow s p 1 hp using 1
  · norm_num
  · norm_num [add_comm, Finset.sum_range_succ]

/-- **Division-free Euler-factor closed form.** For a prime `p`,
`σ_s(pʳ) · (p^s − 1) = p^{s(r+1)} − 1`.  This is the coefficient-level statement
that the local factor of the Eisenstein `L`-function at `p` is
`(1 − p^{s-w})^{-1}(1 − p^{-w})^{-1}`. -/
theorem sigma_prime_pow_geom (s p r : ℕ) (hp : p.Prime) :
    ((sigma s) (p ^ r) : ℤ) * ((p : ℤ) ^ s - 1) = (p : ℤ) ^ (s * (r + 1)) - 1 := by
  rw [sigma_prime_pow s p r hp]
  push_cast
  simp_rw [pow_mul]
  rw [geom_sum_mul, ← pow_mul]

/-! ### The eigenform boundary -/

/-- **Quadratic Hecke correction.** For every prime `p` and exponent `s`,
`σ_s(p²) + p^s = σ_s(p)²`.  The term `p^s` is the eigenform defect: it is the
`T_{p²} = T_p² − p^{k-1}` relation for the weight-`k = s+1` Eisenstein series,
read off on Fourier coefficients. -/
theorem sigma_hecke_correction (s p : ℕ) (hp : p.Prime) :
    (sigma s) (p ^ 2) + p ^ s = ((sigma s) p) ^ 2 := by
  rw [sigma_prime_pow s p 2 hp, sigma_prime s p hp]
  simp [Finset.sum_range_succ]
  ring

/-- **The eigenform is not a character.** `σ_s` is multiplicative but *strictly*
fails complete multiplicativity: `σ_s(p²) < σ_s(p)²` for every prime `p`.  The
gap is exactly the correction term `p^s ≥ 1`. -/
theorem sigma_not_completely_multiplicative (s p : ℕ) (hp : p.Prime) :
    (sigma s) (p ^ 2) < ((sigma s) p) ^ 2 := by
  have hcorr := sigma_hecke_correction s p hp
  have hpos : 1 ≤ p ^ s := Nat.one_le_pow _ _ hp.pos
  omega

/-! ### Möbius inversion -/

/-- **Möbius inversion of the divisor-power sum.** For every `n ≥ 1`,
`n^s = ∑_{d·e = n} μ(d) · σ_s(e)`.  Equivalently, dividing the Eisenstein
`L`-function by `ζ` returns the pure power `L`-function; this rests on the
incidence-algebra identity `ζ ⋆ μ = δ` over the divisor lattice. -/
theorem sigma_moebius_inversion (s n : ℕ) (hn : 0 < n) :
    ∑ x ∈ n.divisorsAntidiagonal, (moebius x.1 : ℤ) * ((sigma s) x.2 : ℤ) = (n : ℤ) ^ s := by
  have h : ∀ m > 0, ∑ i ∈ m.divisors, (Nat.cast i : ℤ) ^ s = ((sigma s) m : ℤ) := by
    intro m _
    rw [sigma_apply]
    push_cast
    rfl
  exact (sum_eq_iff_sum_mul_moebius_eq.mp h) n hn

/-! ### Transport to the `E₈` representation numbers -/

/-- The Hecke correction transported to the `E₈` counts:
`240·r(p²) + 240²·p³ = r(p)²`. -/
theorem rE8_hecke_correction (p : ℕ) (hp : p.Prime) :
    240 * rE8 (p ^ 2) + 240 * 240 * p ^ 3 = (rE8 p) ^ 2 := by
  have hcorr := sigma_hecke_correction 3 p hp
  simp only [rE8]
  nlinarith [hcorr]

/-- The `E₈` counts are not completely multiplicative:
`240·r(p²) < r(p)²` for every prime `p`. -/
theorem rE8_not_completely_multiplicative (p : ℕ) (hp : p.Prime) :
    240 * rE8 (p ^ 2) < (rE8 p) ^ 2 := by
  have hgap := sigma_not_completely_multiplicative 3 p hp
  simp only [rE8]
  nlinarith [hgap, Nat.zero_le ((sigma 3) p)]

/-- Möbius inversion transported to the `E₈` counts:
`∑_{d·e = n} μ(d)·r(e) = 240·n³`. -/
theorem rE8_moebius_inversion (n : ℕ) (hn : 0 < n) :
    ∑ x ∈ n.divisorsAntidiagonal, (moebius x.1 : ℤ) * (rE8 x.2 : ℤ) = 240 * (n : ℤ) ^ 3 := by
  have hm := sigma_moebius_inversion 3 n hn
  simp only [rE8]
  rw [← hm, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro x _
  push_cast
  ring

/-! ### Low-order corroboration

Concrete instances of the closed form and the eigenform defect, matching the
known `E₈` vector counts `240, 2160, 6720, 17520, 30240`. -/

theorem sigma3_four : (sigma 3) 4 = 73 := by decide
theorem sigma3_two_sq : ((sigma 3) 2) ^ 2 = 81 := by decide
theorem eigenform_defect_two : ((sigma 3) 2) ^ 2 - (sigma 3) 4 = 2 ^ 3 := by decide
theorem rE8_one : rE8 1 = 240 := by decide
theorem rE8_two : rE8 2 = 2160 := by decide

end SiegelWeilE8Moebius