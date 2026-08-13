import Pythagorean.FactoringBarriers.Dequant.OrderProbe

/-!
# Barrier IV, part 3: the other direction — order finding *is* factoring

The de-quantization equivalence has two halves.  Parts 1 and 2 show that no
classical procedure reproduces or extracts the order without `Θ(r)` work.  This
file formalises the (classical, elementary) converse: **once the order is known,
factoring is easy**, and the continued-fraction post-processing that turns a
sampled frequency into the order is *well defined*.  Together with parts 1–2 this
is the statement "de-quantizing Shor = factoring".

* `Dequant.factor_of_nontrivial_sqrt` — a nontrivial square root of `1` modulo `N`
  splits `N`: `1 < gcd(x-1, N) < N`.
* `Dequant.order_finding_splits` — **Shor's reduction**: if the order `r` of `b`
  modulo `N` is even and `b^{r/2} ≢ -1`, then `gcd(b^{r/2} - 1, N)` is a nontrivial
  factor.  The hypothesis `b^{r/2} ≢ 1` is *not* assumed — it is a theorem, coming
  from the minimality of the order (`Dequant.probe_false_below_order`).
* `Dequant.farey_separation` — two distinct fractions with denominators `r, r'` are
  at distance at least `1/(r r')`.
* `Dequant.order_determined_by_approx` — hence a real number determines *at most
  one* reduced fraction with denominator `≤ R` to accuracy `1/(2R²)`: the
  continued-fraction step of Shor's post-processing returns the true order, so a
  sampler of the output distribution really does yield `r`, and then a factor.
-/

namespace Dequant

open Finset

/-! ### A nontrivial square root of unity splits the modulus -/

/-- **Nontrivial square roots split.**  If `x² ≡ 1 (mod N)` but `x ≢ ±1 (mod N)`,
then `gcd(x - 1, N)` is a nontrivial divisor of `N`. -/
theorem factor_of_nontrivial_sqrt {N : ℕ} {x : ℤ} (hN : 1 < N)
    (hsq : (N : ℤ) ∣ x ^ 2 - 1) (h1 : ¬ (N : ℤ) ∣ x - 1) (h2 : ¬ (N : ℤ) ∣ x + 1) :
    1 < Int.gcd (x - 1) (N : ℤ) ∧ Int.gcd (x - 1) (N : ℤ) < N := by
  set d : ℕ := Int.gcd (x - 1) (N : ℤ) with hd
  have hdN : (d : ℤ) ∣ (N : ℤ) := Int.gcd_dvd_right _ _
  have hdN' : d ∣ N := by exact_mod_cast hdN
  have hdx : (d : ℤ) ∣ x - 1 := Int.gcd_dvd_left _ _
  have hdne0 : d ≠ 0 := by
    intro h
    rw [h] at hdN'
    have : N = 0 := Nat.eq_zero_of_zero_dvd hdN'
    omega
  have hdne1 : d ≠ 1 := by
    intro h
    have hcop : IsCoprime ((N : ℤ)) (x - 1) := by
      rw [Int.isCoprime_iff_gcd_eq_one, Int.gcd_comm]
      exact h
    have hmul : (N : ℤ) ∣ (x - 1) * (x + 1) := by
      have : (x - 1) * (x + 1) = x ^ 2 - 1 := by ring
      rwa [this]
    exact h2 (hcop.dvd_of_dvd_mul_left hmul)
  have hdneN : d ≠ N := by
    intro h
    rw [h] at hdx
    exact h1 hdx
  have hdle : d ≤ N := Nat.le_of_dvd (by omega) hdN'
  exact ⟨by omega, by omega⟩

/-- **Shor's reduction, formalised.**  Let `r` be the multiplicative order of `b`
modulo `N > 1`.  If `r` is even and `b^{r/2} ≢ -1 (mod N)`, then
`gcd(b^{r/2} - 1, N)` is a nontrivial factor of `N`.  Knowing the order therefore
factors the modulus by a single gcd. -/
theorem order_finding_splits {N b : ℕ} (hN : 1 < N) (hr : 0 < ord N b)
    (heven : 2 ∣ ord N b)
    (hminus : ¬ (N : ℤ) ∣ (b : ℤ) ^ (ord N b / 2) + 1) :
    1 < Int.gcd ((b : ℤ) ^ (ord N b / 2) - 1) (N : ℤ) ∧
      Int.gcd ((b : ℤ) ^ (ord N b / 2) - 1) (N : ℤ) < N := by
  set r := ord N b with hrdef
  set h := r / 2 with hhdef
  have hh2 : 2 * h = r := by
    obtain ⟨c, hc⟩ := heven
    omega
  have hhpos : 0 < h := by omega
  have hhlt : h < r := by omega
  -- `x = b^{r/2}` squares to `1`
  have hsq : (N : ℤ) ∣ ((b : ℤ) ^ h) ^ 2 - 1 := by
    have hpr : probe N b r := (probe_iff_ord_dvd N b r).mpr dvd_rfl
    have : ((b : ℤ) ^ h) ^ 2 = (b : ℤ) ^ r := by
      rw [← pow_mul, mul_comm h 2, hh2]
    rw [this]
    exact hpr
  -- and is not `1`, by minimality of the order
  have hplus : ¬ (N : ℤ) ∣ (b : ℤ) ^ h - 1 := by
    intro hc
    exact probe_false_below_order (N := N) (b := b) hhpos hhlt hc
  exact factor_of_nontrivial_sqrt hN hsq hplus hminus

/-! ### Continued-fraction post-processing is well defined -/

/-- **Farey separation.**  Two distinct fractions with positive denominators `r, r'`
are at distance at least `1 / (r r')`. -/
theorem farey_separation {s r s' r' : ℕ} (hr : 0 < r) (hr' : 0 < r')
    (hne : s * r' ≠ s' * r) :
    1 / ((r : ℝ) * r') ≤ |(s : ℝ) / r - (s' : ℝ) / r'| := by
  have hrR : (0:ℝ) < r := by exact_mod_cast hr
  have hr'R : (0:ℝ) < r' := by exact_mod_cast hr'
  have hnum : (1:ℝ) ≤ |(s : ℝ) * r' - (s' : ℝ) * r| := by
    have hz : ((s * r' : ℕ) : ℤ) - ((s' * r : ℕ) : ℤ) ≠ 0 := by
      simp only [sub_ne_zero]
      exact_mod_cast hne
    have h1 : (1:ℤ) ≤ |((s * r' : ℕ) : ℤ) - ((s' * r : ℕ) : ℤ)| :=
      Int.one_le_abs (by omega)
    have : ((1:ℤ) : ℝ) ≤ ((|((s * r' : ℕ) : ℤ) - ((s' * r : ℕ) : ℤ)| : ℤ) : ℝ) := by
      exact_mod_cast h1
    rw [Int.cast_abs] at this
    push_cast at this ⊢
    exact this
  have hkey : (s : ℝ) / r - (s' : ℝ) / r' = ((s : ℝ) * r' - (s' : ℝ) * r) / (r * r') := by
    field_simp
  rw [hkey, abs_div, abs_of_pos (by positivity : (0:ℝ) < (r:ℝ) * r')]
  rw [div_le_div_iff_of_pos_right (by positivity)]
  exact hnum

/-- Two reduced fractions that are equal as rationals have equal numerators and
denominators. -/
theorem eq_of_coprime_cross {s r s' r' : ℕ} (hr : 0 < r) (hr' : 0 < r')
    (hc : Nat.Coprime s r) (hc' : Nat.Coprime s' r') (hcross : s * r' = s' * r) :
    r = r' ∧ s = s' := by
  have hrr' : r ∣ r' := by
    have h1 : r ∣ s * r' := ⟨s', by rw [hcross]; ring⟩
    exact (Nat.Coprime.dvd_of_dvd_mul_left (Nat.Coprime.symm hc) h1)
  have hr'r : r' ∣ r := by
    have h1 : r' ∣ s' * r := ⟨s, by rw [← hcross]; ring⟩
    exact (Nat.Coprime.dvd_of_dvd_mul_left (Nat.Coprime.symm hc') h1)
  have hreq : r = r' := Nat.dvd_antisymm hrr' hr'r
  subst hreq
  exact ⟨rfl, Nat.eq_of_mul_eq_mul_right hr hcross⟩

/-- **The post-processing is unambiguous.**  A real number `x` (in Shor's algorithm,
the measured frequency divided by the grid size) determines at most one reduced
fraction with denominator at most `R`, provided the approximation error is below
`1/(2R²)`.  Hence the continued-fraction step of the classical post-processing
returns *the* order: a sampler of the exact output distribution yields `r`, and by
`Dequant.order_finding_splits` a factor of `N`. -/
theorem order_determined_by_approx {R : ℕ} {x : ℝ} {s r s' r' : ℕ}
    (hr : 0 < r) (hrR : r ≤ R) (hr' : 0 < r') (hr'R : r' ≤ R)
    (h1 : |x - (s : ℝ) / r| < 1 / (2 * (R : ℝ) ^ 2))
    (h2 : |x - (s' : ℝ) / r'| < 1 / (2 * (R : ℝ) ^ 2))
    (hc : Nat.Coprime s r) (hc' : Nat.Coprime s' r') :
    r = r' ∧ s = s' := by
  have hRpos : (0:ℝ) < R := by
    have : 0 < R := lt_of_lt_of_le hr hrR
    exact_mod_cast this
  have hrR' : (r : ℝ) ≤ R := by exact_mod_cast hrR
  have hr'R' : (r' : ℝ) ≤ R := by exact_mod_cast hr'R
  have hrpos : (0:ℝ) < r := by exact_mod_cast hr
  have hr'pos : (0:ℝ) < r' := by exact_mod_cast hr'
  have hclose : |(s : ℝ) / r - (s' : ℝ) / r'| < 1 / ((r : ℝ) * r') := by
    have htri : |(s : ℝ) / r - (s' : ℝ) / r'| ≤ |x - (s : ℝ) / r| + |x - (s' : ℝ) / r'| := by
      calc |(s : ℝ) / r - (s' : ℝ) / r'|
          = |-(x - (s : ℝ) / r) + (x - (s' : ℝ) / r')| := by ring_nf
        _ ≤ |-(x - (s : ℝ) / r)| + |x - (s' : ℝ) / r'| := abs_add_le _ _
        _ = |x - (s : ℝ) / r| + |x - (s' : ℝ) / r'| := by rw [abs_neg]
    have hsum : |x - (s : ℝ) / r| + |x - (s' : ℝ) / r'| < 1 / (R : ℝ) ^ 2 := by
      have : (1:ℝ) / (2 * (R:ℝ)^2) + 1 / (2 * (R:ℝ)^2) = 1 / (R:ℝ)^2 := by
        field_simp
        ring
      linarith
    have hmono : 1 / (R : ℝ) ^ 2 ≤ 1 / ((r : ℝ) * r') := by
      apply one_div_le_one_div_of_le (by positivity)
      calc (r : ℝ) * r' ≤ (R : ℝ) * R := by nlinarith
      _ = (R : ℝ) ^ 2 := by ring
    linarith
  have hcross : s * r' = s' * r := by
    by_contra hne
    exact absurd hclose (not_lt.mpr (farey_separation hr hr' hne))
  exact eq_of_coprime_cross hr hr' hc hc' hcross

end Dequant