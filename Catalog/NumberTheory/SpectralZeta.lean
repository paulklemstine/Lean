import Mathlib
import Catalog.NumberTheory.Zeta
import Catalog.NumberTheory.OrientedDouble

/-!
# The spectral zeta function of the oriented double — Conjecture 6, resolved

`FUTURE_DIRECTIONS.md` (Conjecture 6) predicted that the zeta function attached
to the **oriented double** `O = ℤ[τ]/(τ² − 1)` of
`Catalog/NumberTheory/MobiusIntegers/OrientedDouble.lean` should satisfy

```
ζ_O(s) = ζ(s)² · (1 − 2^{-s}),
```

the Euler factor of every *odd* prime being squared because the fibre of
`Spec O → Spec ℤ` over it has two points, and the factor at `2` being the
ramified one because the fibre there has a single point.  This file proves that
prediction, and then extracts three consequences that were **not** anticipated
by the conjecture.

Main results.

* `Mobius.OInt.sheets_prime`: the number of points of `Spec O` over a rational
  prime `p` is `1` if `p = 2` and `2` otherwise (a restatement of
  `Mobius.OInt.fiberOver_ncard_odd` / `fiberOver_ncard_two` in the form the
  Euler product needs).
* `Mobius.OInt.spectralZeta_eq`: **Conjecture 6.**  For `1 < re s` the Euler
  product over `Spec O` — one factor `(1 − p^{-s})^{-1}` per point of the
  fibre — equals `ζ(s)² · (1 − 2^{-s})`.
* `Mobius.OInt.spectralZeta_eq_tsum`: the same function, unfolded as a
  Dirichlet series, has integer coefficients `d(n) − d(n/2)` (with `d = σ₀` the
  divisor function and `d(n/2) = 0` for odd `n`); these are the predicted
  counts of ideals of `O` of index `n`.
* `Mobius.OInt.spectralZeta_two`: the numerical test proposed in the
  conjecture, `ζ_O(2) = π⁴/48`, together with
  `Mobius.OInt.spectralZeta_two_ne_zetaTilde_two`: `π⁴/48 ≠ π²/3 = ζ̃(2)`.  The
  multiplicative twist **squares** the Euler factors where the set-level Möbius
  twist merely **doubles** the zeta function.
* `Mobius.OInt.not_orientedRiemannHypothesis`: the ramified factor `1 − 2^{-s}`
  creates a zero at `s₀ = (2π/log 2)·i`, which is a zero of `ζ_O` but **not** a
  zero of `ζ` (`Mobius.OInt.riemannZeta_periodPoint_ne_zero`).  So the mission's
  original slogan "the Möbius zeta function has zeros off the critical line" is
  *literally true and non-trivially so* for the oriented double — unlike for
  `Z̃`, where only the trivial zeros of `ζ` were available
  (`Mobius.MInt.exists_zero_off_critical_line`).  The new zeros are supplied by
  the branch locus.
* `Mobius.OInt.orientedRH_strip_iff`: nevertheless the extra zeros all lie on
  the line `re s = 0`, so **inside the critical strip** the oriented Riemann
  hypothesis is exactly equivalent to the classical one.  The double cover moves
  the zero set only through its ramification.
-/

namespace Mobius
namespace OInt

open Complex ArithmeticFunction

/-! ### The number of sheets over a rational prime -/

/-- The number of points of `Spec O` above the rational prime `p`. -/
noncomputable def sheets (p : ℕ) : ℕ := (fiberOver p).ncard

theorem sheets_odd {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) : sheets p = 2 :=
  fiberOver_ncard_odd p hp hp2

theorem sheets_two : sheets 2 = 1 := fiberOver_ncard_two

/-- **The sheet count of the oriented double.**  Two points over every odd
prime, one point over the branch prime `2`. -/
theorem sheets_prime (p : Nat.Primes) : sheets (p : ℕ) = if (p : ℕ) = 2 then 1 else 2 := by
  by_cases h : (p : ℕ) = 2
  · rw [if_pos h, h, sheets_two]
  · rw [if_neg h, sheets_odd p.2 h]

/-! ### The Euler product over `Spec O` -/

/-- The **spectral zeta function** of the oriented double: one Euler factor for
each point of `Spec O`, the point over `p` contributing `(1 − p^{-s})^{-1}`
because its residue field is `𝔽_p` (`Mobius.OInt.quotientEquivProd`,
`Mobius.OInt.redPlus_surjective`). -/
noncomputable def spectralZeta (s : ℂ) : ℂ :=
  ∏' p : Nat.Primes, ((1 - (p : ℂ) ^ (-s))⁻¹) ^ sheets (p : ℕ)

/-- Auxiliary: on the half plane of absolute convergence the ramified Euler
factor at `2` does not vanish. -/
theorem one_sub_two_cpow_ne_zero {s : ℂ} (hs : 0 < s.re) : (1 : ℂ) - (2 : ℂ) ^ (-s) ≠ 0 := by
  have hlt : ‖((2 : ℕ) : ℂ) ^ (-s)‖ < 1 := by
    rw [Complex.norm_natCast_cpow_of_pos (by norm_num)]
    simp only [neg_re]
    exact Real.rpow_lt_one_of_one_lt_of_neg (by norm_num) (by linarith)
  intro h
  have h1 : ((2 : ℕ) : ℂ) ^ (-s) = 1 := by
    have : ((2 : ℕ) : ℂ) = (2 : ℂ) := by norm_num
    rw [this]; linear_combination -h
  rw [h1] at hlt
  simp at hlt

/-- **Conjecture 6, confirmed.**  For `1 < re s` the spectral zeta function of
the oriented double is the square of the Riemann zeta function corrected by the
ramified factor at the branch prime `2`:
`ζ_O(s) = ζ(s)² · (1 − 2^{-s})`. -/
theorem spectralZeta_eq {s : ℂ} (hs : 1 < s.re) :
    spectralZeta s = riemannZeta s ^ 2 * (1 - (2 : ℂ) ^ (-s)) := by
  have hne : (1 : ℂ) - ((2 : ℕ) : ℂ) ^ (-s) ≠ 0 := by
    have := one_sub_two_cpow_ne_zero (s := s) (by linarith)
    simpa using this
  have hz := riemannZeta_eulerProduct_hasProd hs
  have hc : HasProd (fun p : Nat.Primes ↦ if (p : ℕ) = 2 then (1 - ((2 : ℕ) : ℂ) ^ (-s)) else 1)
      (1 - ((2 : ℕ) : ℂ) ^ (-s)) := by
    have := hasProd_single (b := (⟨2, Nat.prime_two⟩ : Nat.Primes))
      (f := fun p : Nat.Primes ↦ if (p : ℕ) = 2 then (1 - ((2 : ℕ) : ℂ) ^ (-s)) else 1)
      (fun b' hb' ↦ if_neg (fun h ↦ hb' (Subtype.ext h)))
    simpa using this
  have hmain := (hz.mul hz).mul hc
  have heq : (fun p : Nat.Primes ↦ (1 - (p : ℂ) ^ (-s))⁻¹ * (1 - (p : ℂ) ^ (-s))⁻¹ *
      (if (p : ℕ) = 2 then (1 - ((2 : ℕ) : ℂ) ^ (-s)) else 1))
      = fun p : Nat.Primes ↦ ((1 - (p : ℂ) ^ (-s))⁻¹) ^ sheets (p : ℕ) := by
    funext p
    rw [sheets_prime p]
    by_cases h : (p : ℕ) = 2
    · have hp2 : ((p : ℕ) : ℂ) = ((2 : ℕ) : ℂ) := by rw [h]
      rw [if_pos h, if_pos h, hp2, pow_one]
      field_simp
    · rw [if_neg h, if_neg h, mul_one, sq]
  rw [heq] at hmain
  rw [spectralZeta, hmain.tprod_eq]
  push_cast
  ring

/-- On the half plane of absolute convergence the spectral zeta function has no
zeros: the cover is unramified there and `ζ` itself does not vanish. -/
theorem spectralZeta_ne_zero {s : ℂ} (hs : 1 < s.re) : spectralZeta s ≠ 0 := by
  rw [spectralZeta_eq hs]
  exact mul_ne_zero (pow_ne_zero _ (riemannZeta_ne_zero_of_one_le_re hs.le))
    (one_sub_two_cpow_ne_zero (by linarith))

/-! ### The Dirichlet coefficients: `d(n) − d(n/2)` -/

/-- The predicted number of ideals of `O` of index `n`: the `n`-th Dirichlet
coefficient of `ζ(s)²·(1 − 2^{-s})`, namely `d(n) − d(n/2)`. -/
def idealCoeff (n : ℕ) : ℤ :=
  (ArithmeticFunction.sigma 0 n : ℤ) - (if 2 ∣ n then (ArithmeticFunction.sigma 0 (n / 2) : ℤ)
    else 0)

@[simp] theorem idealCoeff_one : idealCoeff 1 = 1 := by decide

@[simp] theorem idealCoeff_two : idealCoeff 2 = 1 := by decide

/-- The coefficients are non-negative, as befits a counting function. -/
theorem idealCoeff_nonneg (n : ℕ) : 0 ≤ idealCoeff n := by
  rw [idealCoeff]
  by_cases h : 2 ∣ n
  · rw [if_pos h]
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · have hdvd : (n / 2) ∣ n := Nat.div_dvd_of_dvd h
      have hmono : ArithmeticFunction.sigma 0 (n / 2) ≤ ArithmeticFunction.sigma 0 n := by
        simp only [ArithmeticFunction.sigma_zero_apply]
        exact Finset.card_le_card (Nat.divisors_subset_of_dvd hn.ne' hdvd)
      exact sub_nonneg.2 (by exact_mod_cast hmono)
  · rw [if_neg h, sub_zero]
    positivity

/-- **The coefficients reproduce the sheet counts.**  Over an odd prime the
coefficient is `2`, matching the two points of `Mobius.OInt.fiberOver`. -/
theorem idealCoeff_odd_prime {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    idealCoeff p = (sheets p : ℤ) := by
  have h2 : ¬ (2 ∣ p) := fun h => hp2 ((Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).1 h).symm
  rw [sheets_odd hp hp2, idealCoeff, if_neg h2, sub_zero, ArithmeticFunction.sigma_zero_apply,
    hp.divisors, Finset.card_pair hp.one_lt.ne]

/-- **At the branch prime the coefficients collapse to `1`** — one ideal of each
`2`-power index, matching the single point of `Mobius.OInt.fiberOver 2`. -/
theorem idealCoeff_two_pow (k : ℕ) : idealCoeff (2 ^ (k + 1)) = (sheets 2 : ℤ) := by
  have h : (2 : ℕ) ∣ 2 ^ (k + 1) := dvd_pow_self 2 (Nat.succ_ne_zero k)
  rw [sheets_two, idealCoeff, if_pos h, show (2 : ℕ) ^ (k + 1) / 2 = 2 ^ k by simp [pow_succ],
    ArithmeticFunction.sigma_zero_apply_prime_pow Nat.prime_two,
    ArithmeticFunction.sigma_zero_apply_prime_pow Nat.prime_two]
  push_cast
  ring

/-- Lab note (kernel-checked): the first twelve predicted ideal counts of `O`.
The entry at `n = 9` is `3`, the three ideals `P⁺(3)²`, `P⁺(3)P⁻(3) = (3)`,
`P⁻(3)²`; the entries at the powers of `2` are all `1`. -/
theorem idealCoeff_table :
    (List.range 12).map (fun n => idealCoeff (n + 1)) = [1, 1, 2, 1, 2, 2, 2, 1, 3, 2, 2, 2] := by
  decide

/-! ### The coefficients at prime index really do count ideals -/

/-- The set of ideals of `O` of index `n`. -/
def idealsOfIndex (n : ℕ) : Set (Ideal OInt) := {I | Nat.card (OInt ⧸ I) = n}

/-- The residue ring of `O` at an oriented prime is `ℤ/p`. -/
theorem card_quotient_primeAtPlus (p : ℕ) : Nat.card (OInt ⧸ primeAtPlus p) = p := by
  have e := RingHom.quotientKerEquivOfSurjective (redPlus_surjective p)
  exact (Nat.card_congr e.toEquiv).trans (Nat.card_zmod p)

theorem card_quotient_primeAtMinus (p : ℕ) : Nat.card (OInt ⧸ primeAtMinus p) = p := by
  have e := RingHom.quotientKerEquivOfSurjective (redMinus_surjective p)
  exact (Nat.card_congr e.toEquiv).trans (Nat.card_zmod p)

/-- An ideal of prime index `p` lies in the fibre of `Spec O → Spec ℤ` over `p`. -/
theorem comap_eq_of_card_eq_prime {p : ℕ} (hp : p.Prime) {I : Ideal OInt}
    (hI : Nat.card (OInt ⧸ I) = p) :
    I.IsPrime ∧ Ideal.comap iota I = Ideal.span {(p : ℤ)} := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI hfin : Finite (OInt ⧸ I) := Nat.finite_of_card_ne_zero (by rw [hI]; exact hp.pos.ne')
  haveI : Fintype (OInt ⧸ I) := Fintype.ofFinite _
  have hcard : Fintype.card (OInt ⧸ I) = p := by rw [← Nat.card_eq_fintype_card]; exact hI
  have echar : CharP (OInt ⧸ I) p := charP_of_card_eq_prime hcard
  have e : ZMod p ≃+* (OInt ⧸ I) := ZMod.ringEquivOfPrime _ hp hcard
  haveI : IsDomain (OInt ⧸ I) := e.symm.injective.isDomain _
  have hprime : I.IsPrime := (Ideal.Quotient.isDomain_iff_prime I).1 inferInstance
  refine ⟨hprime, ?_⟩
  -- the class of `p` vanishes in the residue ring, so `p` lies in the contraction
  have hmem : (p : ℤ) ∈ Ideal.comap iota I := by
    have hz : (Ideal.Quotient.mk I) (iota (p : ℤ)) = 0 := by
      have : (Ideal.Quotient.mk I) (iota (p : ℤ)) = ((p : ℕ) : OInt ⧸ I) := by
        rw [show ((p : ℤ)) = ((p : ℕ) : ℤ) by norm_num]
        simp
      rw [this]
      exact (CharP.cast_eq_zero_iff (OInt ⧸ I) p p).2 dvd_rfl
    exact Ideal.mem_comap.2 ((Ideal.Quotient.eq_zero_iff_mem).1 hz)
  have hle : Ideal.span {(p : ℤ)} ≤ Ideal.comap iota I := by
    rw [Ideal.span_le, Set.singleton_subset_iff]
    exact hmem
  have hpZ : Prime ((p : ℤ)) := Nat.prime_iff_prime_int.mp hp
  haveI : (Ideal.span {(p : ℤ)}).IsPrime := (Ideal.span_singleton_prime hpZ.ne_zero).2 hpZ
  have hspan : (Ideal.span {(p : ℤ)}).IsMaximal :=
    IsPrime.to_maximal_ideal (by simpa [Ideal.span_singleton_eq_bot] using hpZ.ne_zero)
  have hne : Ideal.comap iota I ≠ ⊤ := by
    intro h
    have h1 : (1 : ℤ) ∈ Ideal.comap iota I := by rw [h]; trivial
    have : (1 : OInt) ∈ I := by simpa using h1
    exact hprime.ne_top (Ideal.eq_top_of_isUnit_mem I this isUnit_one)
  exact (hspan.eq_of_le hne hle).symm

/-- **Two ideals of index `p` over an odd prime.**  The Dirichlet coefficient
`d(p) − d(p/2) = 2` of `Mobius.OInt.spectralZeta_eq_tsum` is exactly the number
of ideals of `O` of index `p`. -/
theorem idealsOfIndex_odd_prime {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    idealsOfIndex p = {primeAtPlus p, primeAtMinus p} := by
  ext I
  constructor
  · intro hI
    obtain ⟨hprime, hcomap⟩ := comap_eq_of_card_eq_prime hp hI
    have hQ : (⟨I, hprime⟩ : PrimeSpectrum OInt) ∈ fiberOver p := hcomap
    exact (mem_fiberOver_iff p hp hp2).1 hQ
  · rintro (rfl | rfl)
    · exact card_quotient_primeAtPlus p
    · exact card_quotient_primeAtMinus p

/-- **A single ideal of index `2`.**  At the branch prime the two orientations
collapse, and the Dirichlet coefficient is `1`. -/
theorem idealsOfIndex_two : idealsOfIndex 2 = {primeAtPlus 2} := by
  ext I
  constructor
  · intro hI
    obtain ⟨hprime, hcomap⟩ := comap_eq_of_card_eq_prime Nat.prime_two hI
    obtain ⟨Q₀, hQ₀⟩ := Set.ncard_eq_one.1 fiberOver_ncard_two
    have h1 : (⟨I, hprime⟩ : PrimeSpectrum OInt) ∈ fiberOver 2 := hcomap
    have h2 : (⟨primeAtPlus 2, (primeAtPlus_isMaximal 2 Nat.prime_two).isPrime⟩ :
        PrimeSpectrum OInt) ∈ fiberOver 2 := comap_primeAtPlus 2
    rw [hQ₀] at h1 h2
    have := h1.trans h2.symm
    exact congrArg PrimeSpectrum.asIdeal this
  · rintro rfl
    exact card_quotient_primeAtPlus 2

/-- **The Dirichlet coefficients count ideals, at prime index.**  For every
rational prime `p` the number of ideals of `O` of index `p` equals the
coefficient `d(p) − d(p/2)` predicted by `Mobius.OInt.spectralZeta_eq_tsum`. -/
theorem card_idealsOfIndex_eq_idealCoeff {p : ℕ} (hp : p.Prime) :
    ((idealsOfIndex p).ncard : ℤ) = idealCoeff p := by
  by_cases hp2 : p = 2
  · subst hp2
    rw [idealsOfIndex_two, Set.ncard_singleton, idealCoeff_two]
    norm_num
  · rw [idealsOfIndex_odd_prime hp hp2, Set.ncard_pair (primeAt_ne p hp hp2),
      idealCoeff_odd_prime hp hp2, sheets_odd hp hp2]

/-- The `L`-series of the divisor function is `ζ²` on `1 < re s`. -/
theorem lseries_sigma_zero {s : ℂ} (hs : 1 < s.re) :
    LSeries (fun n : ℕ ↦ ((ArithmeticFunction.sigma 0 n : ℕ) : ℂ)) s = riemannZeta s ^ 2 := by
  have h1 : ((ArithmeticFunction.zeta : ArithmeticFunction ℕ) : ArithmeticFunction ℂ) *
      ((ArithmeticFunction.zeta : ArithmeticFunction ℕ) : ArithmeticFunction ℂ)
      = ((ArithmeticFunction.sigma 0 : ArithmeticFunction ℕ) : ArithmeticFunction ℂ) := by
    rw [← ArithmeticFunction.natCoe_mul, ← ArithmeticFunction.zeta_mul_pow_eq_sigma,
      ArithmeticFunction.pow_zero_eq_zeta]
  have hsum : LSeriesSummable
      (fun n : ℕ ↦ (((ArithmeticFunction.zeta : ArithmeticFunction ℕ) :
        ArithmeticFunction ℂ) n)) s := by
    simpa using LSeriesSummable_zeta_iff.mpr hs
  have hmul := ArithmeticFunction.LSeries_mul' hsum hsum
  rw [h1] at hmul
  have hz : LSeries (fun n : ℕ ↦ (((ArithmeticFunction.zeta : ArithmeticFunction ℕ) :
      ArithmeticFunction ℂ) n)) s = riemannZeta s := by
    rw [← LSeries_zeta_eq_riemannZeta hs]; simp
  rw [hz] at hmul
  simpa [sq] using hmul

/-- The `L`-series of the divisor function, written as a plain Dirichlet
series. -/
theorem tsum_sigma_zero {s : ℂ} (hs : 1 < s.re) :
    ∑' n : ℕ, ((ArithmeticFunction.sigma 0 n : ℕ) : ℂ) / (n : ℂ) ^ s = riemannZeta s ^ 2 := by
  rw [← lseries_sigma_zero hs, LSeries]
  refine (tsum_congr fun n => ?_).symm
  rcases eq_or_ne n 0 with rfl | hn
  · simp [LSeries.term]
  · rw [LSeries.term_of_ne_zero hn]

/-- Summability of the divisor Dirichlet series on `1 < re s`. -/
theorem summable_sigma_zero {s : ℂ} (hs : 1 < s.re) :
    Summable (fun n : ℕ ↦ ((ArithmeticFunction.sigma 0 n : ℕ) : ℂ) / (n : ℂ) ^ s) := by
  have h1 : ((ArithmeticFunction.zeta : ArithmeticFunction ℕ) : ArithmeticFunction ℂ) *
      ((ArithmeticFunction.zeta : ArithmeticFunction ℕ) : ArithmeticFunction ℂ)
      = ((ArithmeticFunction.sigma 0 : ArithmeticFunction ℕ) : ArithmeticFunction ℂ) := by
    rw [← ArithmeticFunction.natCoe_mul, ← ArithmeticFunction.zeta_mul_pow_eq_sigma,
      ArithmeticFunction.pow_zero_eq_zeta]
  have hsum : LSeriesSummable
      (fun n : ℕ ↦ (((ArithmeticFunction.zeta : ArithmeticFunction ℕ) :
        ArithmeticFunction ℂ) n)) s := by
    simpa using LSeriesSummable_zeta_iff.mpr hs
  have hconv : LSeriesSummable
      (fun n : ℕ ↦ ((ArithmeticFunction.sigma 0 n : ℕ) : ℂ)) s := by
    have := ArithmeticFunction.LSeriesSummable_mul (f := ((ArithmeticFunction.zeta :
      ArithmeticFunction ℕ) : ArithmeticFunction ℂ)) (g := ((ArithmeticFunction.zeta :
      ArithmeticFunction ℕ) : ArithmeticFunction ℂ)) hsum hsum
    rw [h1] at this
    simpa using this
  have hfun : (fun n : ℕ ↦ LSeries.term (fun n : ℕ ↦ ((ArithmeticFunction.sigma 0 n : ℕ) : ℂ)) s n)
      = fun n : ℕ ↦ ((ArithmeticFunction.sigma 0 n : ℕ) : ℂ) / (n : ℂ) ^ s := by
    funext n
    rcases eq_or_ne n 0 with rfl | hn
    · simp [LSeries.term]
    · rw [LSeries.term_of_ne_zero hn]
  exact hfun ▸ hconv

/-- Halving reindexation: multiplying a Dirichlet series by `2^{-s}` shifts its
coefficients to the even integers. -/
theorem tsum_halved {a : ℕ → ℂ} (s : ℂ) :
    ∑' n : ℕ, (if 2 ∣ n then a (n / 2) else 0) / (n : ℂ) ^ s
      = (2 : ℂ) ^ (-s) * ∑' m : ℕ, a m / (m : ℂ) ^ s := by
  set F : ℕ → ℂ := fun n ↦ (if 2 ∣ n then a (n / 2) else 0) / (n : ℂ) ^ s with hF
  have hinj : Function.Injective (fun m : ℕ ↦ 2 * m) := fun x y h => by simpa using h
  have hsupp : Function.support F ⊆ Set.range (fun m : ℕ ↦ 2 * m) := by
    intro n hn
    simp only [Function.mem_support, hF] at hn
    by_cases h : 2 ∣ n
    · exact ⟨n / 2, by simp only []; omega⟩
    · simp [h] at hn
  rw [← hinj.tsum_eq hsupp, ← tsum_mul_left]
  refine tsum_congr fun m => ?_
  simp only [hF]
  rw [if_pos ⟨m, rfl⟩, show (2 * m) / 2 = m by omega]
  have hc : (((2 * m : ℕ)) : ℂ) ^ s = (2 : ℂ) ^ s * (m : ℂ) ^ s := by
    have := Complex.mul_cpow_ofReal_nonneg (a := (2 : ℝ)) (b := (m : ℝ)) (by norm_num)
      (by positivity) s
    push_cast at this ⊢
    exact this
  rw [hc, Complex.cpow_neg]
  field_simp

/-- Summability of the halved series. -/
theorem summable_halved {a : ℕ → ℂ} {s : ℂ} (ha : Summable (fun m : ℕ ↦ a m / (m : ℂ) ^ s)) :
    Summable (fun n : ℕ ↦ (if 2 ∣ n then a (n / 2) else 0) / (n : ℂ) ^ s) := by
  set F : ℕ → ℂ := fun n ↦ (if 2 ∣ n then a (n / 2) else 0) / (n : ℂ) ^ s with hF
  have hinj : Function.Injective (fun m : ℕ ↦ 2 * m) := fun x y h => by simpa using h
  have hsupp : ∀ n ∉ Set.range (fun m : ℕ ↦ 2 * m), F n = 0 := by
    intro n hn
    by_cases h : 2 ∣ n
    · exact absurd ⟨n / 2, by simp only []; omega⟩ hn
    · simp [hF, h]
  refine (hinj.summable_iff hsupp).1 ?_
  have hcomp : (F ∘ fun m : ℕ ↦ 2 * m) = fun m : ℕ ↦ (2 : ℂ) ^ (-s) * (a m / (m : ℂ) ^ s) := by
    funext m
    simp only [Function.comp_apply, hF]
    rw [if_pos ⟨m, rfl⟩, show (2 * m) / 2 = m by omega]
    have hc : (((2 * m : ℕ)) : ℂ) ^ s = (2 : ℂ) ^ s * (m : ℂ) ^ s := by
      have := Complex.mul_cpow_ofReal_nonneg (a := (2 : ℝ)) (b := (m : ℝ)) (by norm_num)
        (by positivity) s
      push_cast at this ⊢
      exact this
    rw [hc, Complex.cpow_neg]
    field_simp
  rw [hcomp]
  exact ha.mul_left _

/-- **The Dirichlet expansion of the spectral zeta function.**  For `1 < re s`,
`ζ_O(s) = ∑ (d(n) − d(n/2)) n^{-s}`: the coefficients are the integers
`Mobius.OInt.idealCoeff`, the predicted numbers of ideals of index `n`.  The
first values are `1, 1, 2, 1, 2, 2, 2, 1, 3, …`, and only the odd primes
contribute a genuine doubling. -/
theorem spectralZeta_eq_tsum {s : ℂ} (hs : 1 < s.re) :
    spectralZeta s = ∑' n : ℕ, ((idealCoeff n : ℤ) : ℂ) / (n : ℂ) ^ s := by
  have hA := summable_sigma_zero hs
  have hB := summable_halved (a := fun n : ℕ ↦ ((ArithmeticFunction.sigma 0 n : ℕ) : ℂ)) hA
  have hsplit : ∑' n : ℕ, ((idealCoeff n : ℤ) : ℂ) / (n : ℂ) ^ s
      = (∑' n : ℕ, ((ArithmeticFunction.sigma 0 n : ℕ) : ℂ) / (n : ℂ) ^ s)
        - ∑' n : ℕ, (if 2 ∣ n then ((ArithmeticFunction.sigma 0 (n / 2) : ℕ) : ℂ) else 0) /
            (n : ℂ) ^ s := by
    rw [← hA.tsum_sub hB]
    refine tsum_congr fun n => ?_
    simp only [idealCoeff]
    by_cases h : 2 ∣ n
    · rw [if_pos h, if_pos h]
      push_cast
      ring
    · rw [if_neg h, if_neg h]
      push_cast
      ring
  have hhalf := tsum_halved (a := fun n : ℕ ↦ ((ArithmeticFunction.sigma 0 n : ℕ) : ℂ)) s
  rw [hsplit, tsum_sigma_zero hs, hhalf, tsum_sigma_zero hs, spectralZeta_eq hs]
  ring

/-! ### The numerical test at `s = 2` -/

/-- **The prediction of Conjecture 6 at `s = 2`:** `ζ_O(2) = π⁴/48 ≈ 2.0294`. -/
theorem spectralZeta_two : spectralZeta 2 = ((Real.pi : ℂ) ^ 4) / 48 := by
  rw [spectralZeta_eq (by norm_num), riemannZeta_two]
  have h : (2 : ℂ) ^ (-(2 : ℂ)) = 1 / 4 := by
    rw [show (-(2 : ℂ)) = ((-2 : ℤ) : ℂ) by norm_num, Complex.cpow_intCast]
    norm_num
  rw [h]
  ring

/-- **The two twists are analytically different.**  The set-level Möbius twist
doubles the zeta function (`ζ̃(2) = π²/3`), the multiplicative twist squares its
Euler factors (`ζ_O(2) = π⁴/48`); the two numbers differ. -/
theorem spectralZeta_two_ne_zetaTilde_two : spectralZeta 2 ≠ MInt.zetaTilde 2 := by
  rw [spectralZeta_two, MInt.zetaTilde, riemannZeta_two]
  intro h
  have hpi : (Real.pi : ℂ) ^ 2 = 16 := by field_simp at h; linear_combination h / 6
  have hr : (Real.pi : ℝ) ^ 2 = 16 := by exact_mod_cast hpi
  nlinarith [Real.pi_lt_d2, Real.pi_gt_three]

/-! ### New zeros created by the branch prime -/

/-- The first zero of the ramified Euler factor: `s₀ = (2π/log 2)·i`. -/
noncomputable def periodPoint : ℂ := ((2 * Real.pi / Real.log 2 : ℝ) : ℂ) * Complex.I

@[simp] theorem periodPoint_re : periodPoint.re = 0 := by
  rw [periodPoint, Complex.mul_I_re, Complex.ofReal_im, neg_zero]

theorem periodPoint_im : periodPoint.im = 2 * Real.pi / Real.log 2 := by
  rw [periodPoint, Complex.mul_I_im, Complex.ofReal_re]

theorem periodPoint_im_ne_zero : periodPoint.im ≠ 0 := by
  rw [periodPoint_im]
  have h1 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  positivity

/-- The ramified Euler factor vanishes at `s₀`. -/
theorem one_sub_two_cpow_periodPoint : (1 : ℂ) - (2 : ℂ) ^ (-periodPoint) = 0 := by
  have hlogpos : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlog : ((Real.log 2 : ℝ) : ℂ) ≠ 0 := by exact_mod_cast hlogpos.ne'
  rw [Complex.cpow_def_of_ne_zero two_ne_zero]
  have hl : Complex.log 2 = ((Real.log 2 : ℝ) : ℂ) := by
    rw [show ((2 : ℂ)) = ((2 : ℝ) : ℂ) by norm_num, ← Complex.ofReal_log (by norm_num)]
  rw [hl, periodPoint]
  have hkey : ((Real.log 2 : ℝ) : ℂ) * (-(((2 * Real.pi / Real.log 2 : ℝ)) * Complex.I))
      = -(2 * (Real.pi : ℂ) * Complex.I) := by
    push_cast; field_simp
  rw [hkey, Complex.exp_neg, Complex.exp_two_pi_mul_I]
  norm_num

/-- **`s₀` is not a zero of the Riemann zeta function.**  Hence the zero of the
spectral zeta function at `s₀` is genuinely new: it is created by the
ramification of the oriented double at the prime `2`, not inherited from `ζ`. -/
theorem riemannZeta_periodPoint_ne_zero : riemannZeta periodPoint ≠ 0 := by
  have him := periodPoint_im_ne_zero
  have hn : ∀ n : ℕ, periodPoint ≠ -(n : ℂ) := by
    intro n h
    exact him (by rw [h]; simp)
  have h1 : periodPoint ≠ 1 := fun h => him (by rw [h]; simp)
  have hkey := riemannZeta_one_sub hn h1
  have hne : riemannZeta (1 - periodPoint) ≠ 0 := by
    refine riemannZeta_ne_zero_of_one_le_re ?_
    rw [Complex.sub_re, Complex.one_re, periodPoint_re]
    norm_num
  intro hz
  rw [hz] at hkey
  simp only [mul_zero] at hkey
  exact hne hkey

/-- The meromorphic continuation predicted by `Mobius.OInt.spectralZeta_eq`:
the function `ζ(s)²·(1 − 2^{-s})`, defined on all of `ℂ`. -/
noncomputable def spectralZetaC (s : ℂ) : ℂ := riemannZeta s ^ 2 * (1 - (2 : ℂ) ^ (-s))

theorem spectralZetaC_eq_spectralZeta {s : ℂ} (hs : 1 < s.re) :
    spectralZetaC s = spectralZeta s := (spectralZeta_eq hs).symm

/-- The naive oriented Riemann hypothesis, stated exactly like Mathlib's
`RiemannHypothesis` with the trivial zeros of `ζ` excluded. -/
def OrientedRiemannHypothesis : Prop :=
  ∀ s : ℂ, spectralZetaC s = 0 → (¬∃ n : ℕ, s = -2 * (n + 1)) → s ≠ 1 → s.re = 1 / 2

/-- **The oriented Riemann hypothesis is false.**  The branch prime `2` puts a
zero at `s₀ = (2π/log 2)·i`, on the line `re s = 0`: a non-trivial zero off the
critical line, and one that `ζ` does not have
(`Mobius.OInt.riemannZeta_periodPoint_ne_zero`).  This is the mission's
"zeros off the critical line" phenomenon, realised — and its true source is
ramification, not any failure of the Ore condition. -/
theorem not_orientedRiemannHypothesis : ¬ OrientedRiemannHypothesis := by
  intro h
  have hzero : spectralZetaC periodPoint = 0 := by
    rw [spectralZetaC, one_sub_two_cpow_periodPoint, mul_zero]
  have htriv : ¬∃ n : ℕ, periodPoint = -2 * (n + 1) := by
    rintro ⟨n, hn⟩
    exact periodPoint_im_ne_zero (by rw [hn]; simp)
  have hne : periodPoint ≠ 1 := fun hc => periodPoint_im_ne_zero (by rw [hc]; simp)
  have := h periodPoint hzero htriv hne
  rw [periodPoint_re] at this
  norm_num at this

/-- **Inside the critical strip the oriented and the classical Riemann
hypotheses are equivalent.**  All the extra zeros produced by the branch prime
lie on `re s = 0`, so they never enter the strip: the double cover moves the
zero set only through its ramification. -/
theorem orientedRH_strip_iff :
    (∀ s : ℂ, spectralZetaC s = 0 → 0 < s.re → s.re < 1 → s.re = 1 / 2)
      ↔ (∀ s : ℂ, riemannZeta s = 0 → 0 < s.re → s.re < 1 → s.re = 1 / 2) := by
  constructor
  · intro h s hs h0 h1
    exact h s (by rw [spectralZetaC, hs]; ring) h0 h1
  · intro h s hs h0 h1
    rw [spectralZetaC, mul_eq_zero] at hs
    rcases hs with hz | hb
    · exact h s (pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hz) h0 h1
    · exact absurd hb (one_sub_two_cpow_ne_zero h0)

/-- The classical Riemann hypothesis implies the oriented one *inside the
strip*; combined with `Mobius.OInt.not_orientedRiemannHypothesis` this pins down
exactly how much the oriented double changes the picture. -/
theorem riemannHypothesis_imp_orientedRH_strip (h : RiemannHypothesis) :
    ∀ s : ℂ, spectralZetaC s = 0 → 0 < s.re → s.re < 1 → s.re = 1 / 2 := by
  refine orientedRH_strip_iff.2 fun s hs h0 h1 => h s hs ?_ ?_
  · rintro ⟨n, rfl⟩
    have : ((-2 : ℂ) * ((n : ℂ) + 1)).re = -2 * (n + 1) := by
      simp [Complex.mul_re]
    rw [this] at h0
    have : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith
  · rintro rfl
    simp at h1

end OInt
end Mobius