import Applications.AdjacentSumPolytopes.SecantSpectrum
import Applications.AdjacentSumPolytopes.Recurrence

/-!
# The Jacobi derivative identity for the cyclic series, in every dimension

`Jacobi.lean` proved, by hand, that the cyclic generating function of the three-state
model satisfies

`cycSeries 2 · (1 - 2X - X² + X³) = 2 + 2X - 3X²`,

and observed that the numerator `2 + 2X - 3X²` is exactly `-d/dX (1 - 2X - X² + X³)`.
The previous cycle conjectured (Conjecture 3) that this is a general phenomenon.  This
file proves it for **every** slack parameter `s`:

`cycSeries s · charDenom s = - d/dX (charDenom s)`.

Equivalently, with `p_s(X) = det(I - X · adjMat s)`, the Ehrhart-type series of the cyclic
parity class is the logarithmic derivative `-p_s'/p_s`.

## Strategy

1. A general **Newton identity in formal power series**: for any finite family `λ` of
   elements of a commutative ring, `p = ∏ (1 - λ_t X)` satisfies
   `p · ∑_m (∑_t λ_t^m) X^m = (#λ) · p - X p'`, proved by induction on the family from
   the geometric-series cancellation `(1 - λX)·∑ λ^m X^m = 1`
   (`AdjSum.newton_powerSeries`).  Dividing by `X` gives the form we need
   (`AdjSum.newton_powerSeries'`).
2. The cosecant spectrum of `SecantSpectrum.lean` splits the characteristic polynomial of
   `adjMat s` over `ℝ`, and the *reverse* of a split polynomial is the product
   `∏ (1 - λ_t X)` (`AdjSum.reverse_prod_X_sub_C`).
3. The counting series is the power-sum series because
   `#cycSet s d = tr(A^{d+1}) = ∑_t λ_t^{d+1}`.
4. Both sides have integer coefficients, so the real identity descends to `ℤ`.

## Main results

* `AdjSum.newton_powerSeries` / `AdjSum.newton_powerSeries'` : the general identity.
* `AdjSum.charDenom_eq_coe` : `charDenom s` is the polynomial `charDenomPoly s`.
* `AdjSum.charDenomPolyR_eq_rootPoly` : over `ℝ` that polynomial is `∏_t (1 - λ_t X)`.
* `AdjSum.cycSeries_mul_charDenom_eq_neg_derivative` : **the Jacobi derivative identity**
  `cycSeries s · charDenom s = -(charDenomPoly s)'`, valid for every `s`.
* `AdjSum.jacobi_numerator_natDegree_le` : the cyclic numerator has degree `≤ s`, which
  re-proves the numerator bound of `Recurrence.lean` from the closed formula.

-- !-- Lab Notes -- !--
* **Experiment.** `s = 2`: `charDenomPoly 2 = 1 - 2X - X² + X³`, `-p' = 2 + 2X - 3X²`,
  which is exactly the numerator computed by hand in `Jacobi.lean`; `s = 1`:
  `p = 1 - X - X²`, `-p' = 1 + 2X`, and indeed the cyclic counts `1, 3, 4, 7, 11, …`
  (Lucas numbers) have generating function `(1 + 2X)/(1 - X - X²)`.
* **Analysis.** The identity is *not* a consequence of Cayley–Hamilton alone: the latter
  only controls the coefficients in degrees `≥ s + 1`, whereas the derivative formula also
  pins down the `s + 1` initial values, i.e. the traces `tr(A), …, tr(A^{s+1})`.  What
  supplies them is the splitting of the characteristic polynomial over `ℝ` proved in
  `SecantSpectrum.lean`; the descent to `ℤ` is by injectivity of `ℤ → ℝ`.
* **Critique.** The general lemma `newton_powerSeries` is stated for an arbitrary
  commutative ring and an arbitrary finite family, so it is not tailored to the
  application; the only input specific to the model is the spectral factorisation.
-/

namespace AdjSum

open Finset

/-! ## A Newton identity for formal power series -/

section Newton

variable {R : Type*} [CommRing R] {ι : Type*} [DecidableEq ι]

/-- The reversed root polynomial `∏_{t ∈ S} (1 - λ_t X)`. -/
noncomputable def rootPoly (lam : ι → R) (S : Finset ι) : Polynomial R :=
  ∏ t ∈ S, (1 - Polynomial.C (lam t) * Polynomial.X)

/-- Geometric-series cancellation in `R⟦X⟧`. -/
lemma geom_cancel (r : R) :
    (1 - PowerSeries.C r * PowerSeries.X) * PowerSeries.mk (fun m => r ^ m) = 1 := by
  have h : (1 - PowerSeries.C r * PowerSeries.X) * PowerSeries.mk (fun m => r ^ m)
      = PowerSeries.mk (fun m => r ^ m)
        - PowerSeries.C r * (PowerSeries.X * PowerSeries.mk (fun m => r ^ m)) := by
    ring
  rw [h]
  ext n
  cases n with
  | zero => simp
  | succ n => simp [PowerSeries.coeff_succ_X_mul, pow_succ, mul_comm]

/-- **Newton's identity in power series.**  For a finite family `λ` in a commutative ring,
the product `p = ∏ (1 - λ_t X)` and the power-sum series `∑_m (∑_t λ_t^m) X^m` satisfy
`p · ∑ = #S · p - X p'`. -/
theorem newton_powerSeries (lam : ι → R) (S : Finset ι) :
    ((rootPoly lam S : Polynomial R) : PowerSeries R)
        * PowerSeries.mk (fun m => ∑ t ∈ S, lam t ^ m)
      = PowerSeries.C (S.card : R) * ((rootPoly lam S : Polynomial R) : PowerSeries R)
        - PowerSeries.X
            * ((Polynomial.derivative (rootPoly lam S) : Polynomial R) : PowerSeries R) := by
  classical
  induction S using Finset.induction_on with
  | empty =>
      have hz : (PowerSeries.mk fun _ : ℕ => (0 : R)) = 0 := by ext n; simp
      simp [rootPoly, hz]
  | insert a S ha ih =>
      have hprod : rootPoly lam (insert a S)
          = (1 - Polynomial.C (lam a) * Polynomial.X) * rootPoly lam S := by
        rw [rootPoly, Finset.prod_insert ha, rootPoly]
      have hT : PowerSeries.mk (fun m => ∑ t ∈ insert a S, lam t ^ m)
          = PowerSeries.mk (fun m => lam a ^ m)
            + PowerSeries.mk (fun m => ∑ t ∈ S, lam t ^ m) := by
        ext n; simp [Finset.sum_insert ha]
      have hder : Polynomial.derivative (rootPoly lam (insert a S))
          = (- Polynomial.C (lam a)) * rootPoly lam S
            + (1 - Polynomial.C (lam a) * Polynomial.X)
                * Polynomial.derivative (rootPoly lam S) := by
        rw [hprod, Polynomial.derivative_mul]
        simp
      rw [hT, hder, hprod, Finset.card_insert_of_notMem ha]
      push_cast
      simp only [map_add, map_one]
      have hg := geom_cancel (R := R) (lam a)
      linear_combination ((1 : PowerSeries R) - PowerSeries.C (lam a) * PowerSeries.X) * ih
        + ((rootPoly lam S : Polynomial R) : PowerSeries R) * hg

omit [DecidableEq ι] in
/-- The power-sum series splits off its constant term `#S`. -/
lemma psum_split (lam : ι → R) (S : Finset ι) :
    PowerSeries.mk (fun m => ∑ t ∈ S, lam t ^ m)
      = PowerSeries.C (S.card : R)
        + PowerSeries.X * PowerSeries.mk (fun m => ∑ t ∈ S, lam t ^ (m + 1)) := by
  ext n
  cases n with
  | zero => simp
  | succ n =>
      rw [map_add, PowerSeries.coeff_succ_X_mul, PowerSeries.coeff_C, if_neg (by omega),
        PowerSeries.coeff_mk, PowerSeries.coeff_mk, zero_add]

/-- Multiplication by `X` is injective on `R⟦X⟧`. -/
lemma eq_zero_of_X_mul_eq_zero {f : PowerSeries R} (h : PowerSeries.X * f = 0) : f = 0 := by
  ext n
  have hc := congrArg (PowerSeries.coeff (n + 1)) h
  simpa [PowerSeries.coeff_succ_X_mul] using hc

/-- **Logarithmic-derivative form of Newton's identity.**  `p · ∑_m (∑_t λ_t^{m+1}) X^m
= -p'`. -/
theorem newton_powerSeries' (lam : ι → R) (S : Finset ι) :
    ((rootPoly lam S : Polynomial R) : PowerSeries R)
        * PowerSeries.mk (fun m => ∑ t ∈ S, lam t ^ (m + 1))
      = - ((Polynomial.derivative (rootPoly lam S) : Polynomial R) : PowerSeries R) := by
  have h := newton_powerSeries lam S
  rw [psum_split] at h
  have h2 : PowerSeries.X * (((rootPoly lam S : Polynomial R) : PowerSeries R)
        * PowerSeries.mk (fun m => ∑ t ∈ S, lam t ^ (m + 1))
      + ((Polynomial.derivative (rootPoly lam S) : Polynomial R) : PowerSeries R)) = 0 := by
    linear_combination h
  linear_combination eq_zero_of_X_mul_eq_zero h2

omit [DecidableEq ι] in
/-- A weighted power-sum series is a finite combination of geometric series. -/
lemma mk_weighted_sum (lam c : ι → R) (S : Finset ι) :
    PowerSeries.mk (fun m => ∑ t ∈ S, c t * lam t ^ m)
      = ∑ t ∈ S, PowerSeries.C (c t) * PowerSeries.mk (fun m => lam t ^ m) := by
  ext n
  simp [PowerSeries.coeff_C_mul]

/-- **Weighted (partial-fraction) Newton identity.**  For arbitrary weights `c`, the
weighted power-sum series `∑_m (∑_t c_t λ_t^m) X^m` has numerator
`∑_t c_t ∏_{u ≠ t} (1 - λ_u X)` over the same denominator `∏_t (1 - λ_t X)`. -/
theorem newton_weighted (lam c : ι → R) (S : Finset ι) :
    ((rootPoly lam S : Polynomial R) : PowerSeries R)
        * PowerSeries.mk (fun m => ∑ t ∈ S, c t * lam t ^ m)
      = ((∑ t ∈ S, Polynomial.C (c t) * rootPoly lam (S.erase t) :
          Polynomial R) : PowerSeries R) := by
  have hcoe : ((∑ t ∈ S, Polynomial.C (c t) * rootPoly lam (S.erase t) :
        Polynomial R) : PowerSeries R)
      = ∑ t ∈ S, ((Polynomial.C (c t) * rootPoly lam (S.erase t) :
          Polynomial R) : PowerSeries R) :=
    map_sum (Polynomial.coeToPowerSeries.ringHom (R := R))
      (fun t => Polynomial.C (c t) * rootPoly lam (S.erase t)) S
  rw [mk_weighted_sum, Finset.mul_sum, hcoe]
  refine Finset.sum_congr rfl (fun t ht => ?_)
  have hp : rootPoly lam S
      = (1 - Polynomial.C (lam t) * Polynomial.X) * rootPoly lam (S.erase t) := by
    rw [rootPoly, rootPoly, ← Finset.mul_prod_erase S _ ht]
  rw [hp]
  push_cast
  have hg := geom_cancel (R := R) (lam t)
  linear_combination ((rootPoly lam (S.erase t) : Polynomial R) : PowerSeries R)
    * PowerSeries.C (c t) * hg

end Newton

/-! ## Reversal of a split polynomial -/

section Reverse

lemma reverse_one_poly {R : Type*} [CommRing R] : Polynomial.reverse (1 : Polynomial R) = 1 := by
  have h := Polynomial.reverse_C (1 : R)
  simpa using h

lemma reverse_X_poly {R : Type*} [CommRing R] [Nontrivial R] :
    Polynomial.reverse (Polynomial.X : Polynomial R) = 1 := by
  have h := Polynomial.reverse_mul_X (1 : Polynomial R)
  rw [one_mul, reverse_one_poly] at h
  exact h

/-- The reverse of a monic linear factor. -/
lemma reverse_X_sub_C {R : Type*} [CommRing R] [Nontrivial R] (r : R) :
    Polynomial.reverse (Polynomial.X - Polynomial.C r) = 1 - Polynomial.C r * Polynomial.X := by
  have h : (Polynomial.X - Polynomial.C r : Polynomial R) = Polynomial.X + Polynomial.C (-r) := by
    rw [map_neg]; ring
  rw [h, Polynomial.reverse_add_C, reverse_X_poly, Polynomial.natDegree_X, map_neg, pow_one]
  ring

variable {R : Type*} [CommRing R] [NoZeroDivisors R] [Nontrivial R] {ι : Type*} [DecidableEq ι]

/-- Reversing a split polynomial turns the roots into reciprocal linear factors. -/
theorem reverse_prod_X_sub_C (lam : ι → R) (S : Finset ι) :
    Polynomial.reverse (∏ t ∈ S, (Polynomial.X - Polynomial.C (lam t))) = rootPoly lam S := by
  classical
  induction S using Finset.induction_on with
  | empty => simpa [rootPoly] using reverse_one_poly (R := R)
  | insert a S ha ih =>
      rw [Finset.prod_insert ha, Polynomial.reverse_mul_of_domain, ih, reverse_X_sub_C]
      simp only [rootPoly, Finset.prod_insert ha]

end Reverse

/-! ## The reverse characteristic polynomial as a polynomial -/

/-- The reverse characteristic polynomial `det (I - X · adjMat s)` as an honest polynomial
(the power series `charDenom s` is its image). -/
noncomputable def charDenomPoly (s : ℕ) : Polynomial ℤ :=
  ∑ i ∈ Finset.range (s + 2),
    Polynomial.C ((adjMatZ s).charpoly.coeff i) * Polynomial.X ^ (s + 1 - i)

lemma charDenom_eq_coe (s : ℕ) : charDenom s = ((charDenomPoly s : Polynomial ℤ) : PowerSeries ℤ) := by
  have hsum : ((charDenomPoly s : Polynomial ℤ) : PowerSeries ℤ)
      = ∑ i ∈ Finset.range (s + 2),
          ((Polynomial.C ((adjMatZ s).charpoly.coeff i) * Polynomial.X ^ (s + 1 - i) :
            Polynomial ℤ) : PowerSeries ℤ) := by
    rw [charDenomPoly]
    exact map_sum (Polynomial.coeToPowerSeries.ringHom (R := ℤ))
      (fun i => Polynomial.C ((adjMatZ s).charpoly.coeff i) * Polynomial.X ^ (s + 1 - i))
      (Finset.range (s + 2))
  rw [charDenom, revDenom, hsum, show s + 2 = (s + 1) + 1 from rfl]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  push_cast
  simp

/-- The generic reversal formula: for a polynomial of natDegree `k`, the sum
`∑_{i ≤ k} c_i X^{k-i}` is its reverse. -/
theorem sum_coeff_mul_X_pow_eq_reverse {R : Type*} [CommRing R] (q : Polynomial R) (k : ℕ)
    (hk : q.natDegree = k) :
    ∑ i ∈ Finset.range (k + 1), Polynomial.C (q.coeff i) * Polynomial.X ^ (k - i)
      = q.reverse := by
  ext j
  rw [Polynomial.coeff_reverse, hk, Polynomial.finset_sum_coeff]
  simp only [Polynomial.coeff_C_mul, Polynomial.coeff_X_pow]
  rw [Polynomial.revAt]
  simp only [Function.Embedding.coeFn_mk]
  by_cases hj : j ≤ k
  · rw [if_pos hj, Finset.sum_eq_single (k - j)]
    · rw [if_pos (by omega)]; ring
    · intro b hb _; rw [if_neg (by simp only [Finset.mem_range] at hb; omega)]; ring
    · intro hmem; simp only [Finset.mem_range] at hmem; omega
  · rw [if_neg hj, Finset.sum_eq_zero]
    · symm; exact Polynomial.coeff_eq_zero_of_natDegree_lt (by omega)
    · intro b hb; rw [Finset.mem_range] at hb; rw [if_neg (by omega)]; ring

/-! ## Identification over `ℝ` -/

lemma adjMatR_eq_mapZ (s : ℕ) :
    adjMatR s = (adjMatZ s).map (fun z : ℤ => (z : ℝ)) := by
  ext a b
  simp only [adjMatR, adjMatZ, Matrix.map_apply]
  split <;> simp

/-- Over `ℝ` the reverse characteristic polynomial is the product `∏_t (1 - λ_t X)` of the
cosecant spectrum. -/
theorem charDenomPolyR_eq_rootPoly (s : ℕ) :
    (charDenomPoly s).map (Int.castRingHom ℝ)
      = rootPoly (fun t : Fin (s + 1) => secEigval s (t : ℕ)) Finset.univ := by
  have hmap : (adjMatR s).charpoly = (adjMatZ s).charpoly.map (Int.castRingHom ℝ) := by
    rw [adjMatR_eq_mapZ]
    exact Matrix.charpoly_map (adjMatZ s) (Int.castRingHom ℝ)
  have hdeg : (adjMatR s).charpoly.natDegree = s + 1 := by
    rw [Matrix.charpoly_natDegree_eq_dim]
    simp
  have hsum : (charDenomPoly s).map (Int.castRingHom ℝ)
      = ∑ i ∈ Finset.range (s + 2),
          Polynomial.C ((adjMatR s).charpoly.coeff i) * Polynomial.X ^ (s + 1 - i) := by
    rw [charDenomPoly, Polynomial.map_sum]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [Polynomial.map_mul, Polynomial.map_pow, Polynomial.map_C, Polynomial.map_X, hmap,
      Polynomial.coeff_map]
  rw [hsum, show s + 2 = (s + 1) + 1 from rfl,
    sum_coeff_mul_X_pow_eq_reverse _ (s + 1) hdeg, charpoly_adjMatR s,
    reverse_prod_X_sub_C]

/-! ## The Jacobi derivative identity -/

/-- Over `ℝ`, the cyclic counting series is the power-sum series of the cosecant
spectrum. -/
lemma cycSeries_map_eq_psum (s : ℕ) :
    PowerSeries.map (Int.castRingHom ℝ) (cycSeries s)
      = PowerSeries.mk
          (fun m => ∑ t : Fin (s + 1), (secEigval s (t : ℕ)) ^ (m + 1)) := by
  ext n
  rw [PowerSeries.coeff_map, cycSeries, PowerSeries.coeff_mk, PowerSeries.coeff_mk, cycCount]
  simpa using card_cycSet_eq_sum_pow s n

/-- **The Jacobi derivative identity, in every dimension.**  The cyclic Ehrhart-type
series of the adjacent-sum model is the logarithmic derivative of the reverse
characteristic polynomial:
`cycSeries s · det(I - X·A) = - d/dX det(I - X·A)`. -/
theorem cycSeries_mul_charDenom_eq_neg_derivative (s : ℕ) :
    cycSeries s * charDenom s
      = - ((Polynomial.derivative (charDenomPoly s) : Polynomial ℤ) : PowerSeries ℤ) := by
  apply PowerSeries.map_injective (Int.castRingHom ℝ) Int.cast_injective
  have hR := newton_powerSeries' (fun t : Fin (s + 1) => secEigval s (t : ℕ)) Finset.univ
  rw [map_mul, map_neg, cycSeries_map_eq_psum, charDenom_eq_coe,
    ← Polynomial.polynomial_map_coe, ← Polynomial.polynomial_map_coe,
    ← Polynomial.derivative_map, charDenomPolyR_eq_rootPoly]
  linear_combination hR

/-! ### Consistency check: the two-state model -/

lemma charpoly_adjMatZ_one : (adjMatZ 1).charpoly = Polynomial.X ^ 2 - Polynomial.X - 1 := by
  rw [Matrix.charpoly_fin_two]
  simp [adjMatZ, Matrix.det_fin_two, Matrix.trace_fin_two]
  ring

lemma charDenomPoly_one : charDenomPoly 1 = 1 - Polynomial.X - Polynomial.X ^ 2 := by
  have c0 : (Polynomial.X ^ 2 - Polynomial.X - 1 : Polynomial ℤ).coeff 0 = -1 := by simp
  have c1 : (Polynomial.X ^ 2 - Polynomial.X - 1 : Polynomial ℤ).coeff 1 = -1 := by
    simp [Polynomial.coeff_one]
  have c2 : (Polynomial.X ^ 2 - Polynomial.X - 1 : Polynomial ℤ).coeff 2 = 1 := by
    simp [Polynomial.coeff_one, Polynomial.coeff_X]
  rw [charDenomPoly, charpoly_adjMatZ_one, show (1 : ℕ) + 2 = 3 from rfl,
    Finset.sum_range_succ, Finset.sum_range_succ, Finset.sum_range_one, c0, c1, c2]
  simp
  ring

/-- **The two-state instance.**  The generating function of the cyclic (Lucas) counts
`1, 3, 4, 7, 11, …` is `(1 + 2X)/(1 - X - X²)`, exactly `-p'/p`. -/
theorem cycSeries_one_closed :
    cycSeries 1 * (1 - PowerSeries.X - PowerSeries.X ^ 2)
      = 1 + PowerSeries.C 2 * PowerSeries.X := by
  have h := cycSeries_mul_charDenom_eq_neg_derivative 1
  rw [charDenom_eq_coe, charDenomPoly_one] at h
  have hd : Polynomial.derivative (1 - Polynomial.X - Polynomial.X ^ 2 : Polynomial ℤ)
      = -1 - Polynomial.C 2 * Polynomial.X := by
    simp [Polynomial.derivative_sub, Polynomial.derivative_pow]
  rw [hd] at h
  push_cast at h
  linear_combination h

/-- The cyclic numerator has degree at most `s`: the derivative of a polynomial of degree
`s + 1`. -/
theorem jacobi_numerator_natDegree_le (s : ℕ) :
    (Polynomial.derivative (charDenomPoly s)).natDegree ≤ s := by
  have hdeg : (charDenomPoly s).natDegree ≤ s + 1 := by
    rw [charDenomPoly]
    refine Polynomial.natDegree_sum_le_of_forall_le _ _ (fun i _ => ?_)
    refine le_trans (Polynomial.natDegree_mul_le) ?_
    have h1 : (Polynomial.C ((adjMatZ s).charpoly.coeff i)).natDegree = 0 :=
      Polynomial.natDegree_C _
    have h2 : ((Polynomial.X : Polynomial ℤ) ^ (s + 1 - i)).natDegree = s + 1 - i := by
      simp
    rw [h1, h2]
    omega
  calc (Polynomial.derivative (charDenomPoly s)).natDegree
      ≤ (charDenomPoly s).natDegree - 1 := Polynomial.natDegree_derivative_le _
    _ ≤ s := by omega

end AdjSum