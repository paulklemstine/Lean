import Applications.MordellApparitionIndex

/-!
# Unbounded `2`-adic denominators force an infinite orbit

The `2`-adic law of cycle 3 (`pow_dvd_den_double_two_iff`) says that doubling multiplies the
`2`-part of the denominator of the `x`-coordinate by exactly `4`.  Read as a *dynamical*
statement it is much stronger than an invariance law: along the sub-orbit `{2^k Q}` the
denominators grow without bound, so the points are pairwise distinct and the orbit can never
close up.  This gives an entirely elementary, denominator-theoretic proof that

* `P = (9,28)` on `E_55 : y² = x³ + 55` is **not** a torsion point, and
* `E_55(ℚ)` is **infinite** (equivalently, `E_55` has positive Mordell–Weil rank),

without any descent, height machinery or Nagell–Lutz.  The only inputs are the doubling
formula, the square-denominator law and the fact that a `2`-torsion point of `E_N` has
integral coordinates.

Combined with the apparition index law of cycle 7 this closes the loop on the "only bad primes"
conjecture: the good prime `7` divides the denominator of `x(kP)` for *every* even `k`, and
those points are genuinely infinitely many distinct points of `E_55(ℚ)`.

## Main results

* `x_den_eq_one_of_y_eq_zero` : a `2`-torsion point of `E_N` (`N ∈ ℤ`) has integral `x`.
* `y_ne_zero_of_two_dvd_x_den` : a point in the `2`-denominator kernel is not `2`-torsion.
* `two_pow_smul_den_factorization` : along `{2^k Q}` the `2`-adic valuation of the denominator
  is exactly `v + 2k`; in particular every such multiple is affine.
* `mordell_points_infinite_of_two_dvd_den`, `not_torsion_of_two_dvd_den` : a rational point with
  even `x`-denominator forces `E_N(ℚ)` to be infinite and the point to have infinite order.
* `mordell_55_point_infinite_order` : `m • (9,28) ≠ O` for every `m ≥ 1` on `E_55`.
* `mordell_55_points_infinite` : `E_55(ℚ)` is an infinite group.
* `good_prime_orbit_violations_infinite_55` : infinitely many distinct multiples of `(9,28)` have
  the good prime `7` in the denominator of their `x`-coordinate.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer, cycle 8): the `2`-adic growth law should obstruct torsion outright —
  a torsion point has a finite orbit, but the denominators along `{2^k Q}` are strictly
  increasing.
Experiment (Experimenter): `v₂(den x(2^k P)) = 6, 8, 10` for `k = 1, 2, 3` on `E_55`, matching
  `6 + 2(k-1)`; the formal statement needs the *exact* valuation (an inequality is not enough
  to separate the points), which the divisibility `iff` supplies through
  `Nat.Prime.pow_dvd_iff_le_factorization`.
Analysis (Analyst): the only genuinely new ingredient is that the sub-orbit never hits `O`:
  a point with `2 ∣ den x` has `y ≠ 0` because `y = 0` forces `den y = 1 = e³`, hence `e = 1`
  and `den x = 1`.  So the growth induction never stalls.
Critique (Critic): the conclusion is not vacuous — `E_55(ℚ)` really is infinite, and the proof
  produces an explicit injection `ℕ → E_55(ℚ)`, `k ↦ 2^k · (2P)`, rather than an abstract
  cardinality argument.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## `2`-torsion points are integral -/

/-- On `E_N : y² = x³ + N` with `N ∈ ℤ`, a point with `y = 0` (i.e. a `2`-torsion point) has an
integral `x`-coordinate. -/
lemma x_den_eq_one_of_y_eq_zero {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + ((N : ℤ) : ℚ))
    (hy : y = 0) : x.den = 1 := by
  obtain ⟨e, hxe, hye⟩ := mordell_den_pow_structure h
  have h1 : e ^ 3 = 1 := by rw [← hye, hy]; rfl
  have he : e = 1 := by
    rcases Nat.pow_eq_one.mp h1 with h | h
    · exact h
    · omega
  rw [hxe, he, one_pow]

/-- A point whose `x`-coordinate has even denominator is not `2`-torsion. -/
lemma y_ne_zero_of_two_dvd_x_den {N : ℤ} {x y : ℚ} (h : y ^ 2 = x ^ 3 + ((N : ℤ) : ℚ))
    (hx : 2 ∣ x.den) : y ≠ 0 := by
  intro hy
  rw [x_den_eq_one_of_y_eq_zero h hy] at hx
  omega

/-! ## Exact `2`-adic growth along the doubling orbit -/

/-- One doubling step, in group-law form: if the `x`-coordinate of an affine point `R` has
`2`-adic denominator valuation `v ≥ 1`, then `R + R` is again affine and its `x`-coordinate has
`2`-adic denominator valuation exactly `v + 2`. -/
lemma den_factorization_two_double {N : ℤ}
    {R : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ} (hR : xCoord R = some X)
    (hdvd : 2 ∣ X.den) :
    ∃ Y : ℚ, xCoord (R + R) = some Y ∧
      Y.den.factorization 2 = X.den.factorization 2 + 2 := by
  cases hRc : R with
  | zero => rw [hRc] at hR; simp [xCoord] at hR
  | @some x y hns =>
      have hxX : x = X := by rw [hRc] at hR; simpa [xCoord] using hR
      have heq : y ^ 2 = x ^ 3 + ((N : ℤ) : ℚ) := (mordell_equation_iff _ _ _).1 hns.1
      have hx2 : 2 ∣ x.den := by rw [hxX]; exact hdvd
      have hy0 : y ≠ 0 := y_ne_zero_of_two_dvd_x_den heq hx2
      refine ⟨(x ^ 4 - 8 * ((N : ℤ) : ℚ) * x) / (4 * y ^ 2), ?_, ?_⟩
      · exact mordell_double_xCoord _ _ _ hns hy0
      · -- the exact valuation, from the divisibility `iff`
        set Z : ℚ := (x ^ 4 - 8 * ((N : ℤ) : ℚ) * x) / (4 * y ^ 2) with hZ
        have hiff : ∀ m : ℕ, 2 ^ m ∣ Z.den ↔ 2 ^ m ∣ 4 * x.den := fun m =>
          pow_dvd_den_double_two_iff heq hy0 hx2 m
        have hZden : Z.den ≠ 0 := Z.den_nz
        have hxden : (4 * x.den) ≠ 0 := by
          have := x.den_nz
          omega
        have hfac : Z.den.factorization 2 = (4 * x.den).factorization 2 := by
          refine le_antisymm ?_ ?_
          · have h1 : (2 : ℕ) ^ (Z.den.factorization 2) ∣ Z.den :=
              Nat.ordProj_dvd _ _
            exact (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hxden).1
              ((hiff _).1 h1)
          · have h1 : (2 : ℕ) ^ ((4 * x.den).factorization 2) ∣ 4 * x.den :=
              Nat.ordProj_dvd _ _
            exact (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hZden).1
              ((hiff _).2 h1)
        have hf4 : (Nat.factorization 4) 2 = 2 := by
          rw [show (4 : ℕ) = 2 ^ 2 by norm_num, Nat.Prime.factorization_pow Nat.prime_two]
          simp
        have h4 : (4 * x.den).factorization 2 = x.den.factorization 2 + 2 := by
          rw [Nat.factorization_mul (by norm_num) x.den_nz]
          simp [hf4, Nat.add_comm]
        rw [hfac, h4, hxX]

/-- **Exact growth along the `2`-power orbit.**  If the `x`-coordinate of `Q` has `2`-adic
denominator valuation `v ≥ 1`, then for every `k` the multiple `2^k • Q` is affine and its
`x`-coordinate has `2`-adic denominator valuation exactly `v + 2k`. -/
theorem two_pow_smul_den_factorization {N : ℤ}
    {Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ} (hQ : xCoord Q = some X)
    (hdvd : 2 ∣ X.den) (k : ℕ) :
    ∃ Y : ℚ, xCoord ((2 ^ k : ℕ) • Q) = some Y ∧
      Y.den.factorization 2 = X.den.factorization 2 + 2 * k := by
  induction k with
  | zero => exact ⟨X, by simpa using hQ, by simp⟩
  | succ k ih =>
      obtain ⟨Y, hY, hvY⟩ := ih
      have hYdvd : 2 ∣ Y.den := by
        have hv : 1 ≤ Y.den.factorization 2 := by
          have : 1 ≤ X.den.factorization 2 :=
            (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two X.den_nz).1 (by simpa using hdvd)
          omega
        have := (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two Y.den_nz).2 hv
        simpa using this
      obtain ⟨Z, hZ, hvZ⟩ := den_factorization_two_double hY hYdvd
      refine ⟨Z, ?_, by rw [hvZ, hvY]; ring⟩
      have hstep : ((2 ^ (k + 1) : ℕ)) • Q = (2 ^ k : ℕ) • Q + (2 ^ k : ℕ) • Q := by
        rw [← two_nsmul, ← mul_nsmul', pow_succ, mul_comm]
      rw [hstep]
      exact hZ

/-! ## A positive-rank criterion for Mordell curves -/

/-- The `2`-power multiples of a point whose `x`-denominator is even are pairwise distinct: their
`x`-denominators have strictly increasing `2`-adic valuations. -/
theorem two_pow_smul_injective {N : ℤ}
    {Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ} (hQ : xCoord Q = some X)
    (hdvd : 2 ∣ X.den) : Function.Injective (fun k : ℕ => (2 ^ k : ℕ) • Q) := by
  intro k k' hkk'
  obtain ⟨Y, hY, hvY⟩ := two_pow_smul_den_factorization hQ hdvd k
  obtain ⟨Y', hY', hvY'⟩ := two_pow_smul_den_factorization hQ hdvd k'
  have hYY : Y' = Y := by
    simp only at hkk'
    rw [hkk'] at hY
    rw [hY'] at hY
    simpa using hY
  subst hYY
  omega

/-- **A positive-rank criterion.**  If some rational point of `E_N : y² = x³ + N` (`N ∈ ℤ`) has an
`x`-coordinate with even denominator, then `E_N(ℚ)` is infinite. -/
theorem mordell_points_infinite_of_two_dvd_den {N : ℤ}
    {Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ} (hQ : xCoord Q = some X)
    (hdvd : 2 ∣ X.den) : Infinite ((mordell ((N : ℤ) : ℚ)).toAffine.Point) :=
  Infinite.of_injective _ (two_pow_smul_injective hQ hdvd)

/-- **A non-torsion criterion.**  A rational point of `E_N` whose `x`-coordinate has even
denominator has infinite order. -/
theorem not_torsion_of_two_dvd_den {N : ℤ}
    {Q : (mordell ((N : ℤ) : ℚ)).toAffine.Point} {X : ℚ} (hQ : xCoord Q = some X)
    (hdvd : 2 ∣ X.den) (m : ℕ) (hm : 0 < m) : m • Q ≠ 0 := by
  intro hzero
  have hmod : ∀ n : ℕ, n • Q = (n % m) • Q := by
    intro n
    conv_lhs => rw [← Nat.div_add_mod n m]
    rw [add_nsmul, mul_nsmul, hzero, nsmul_zero, zero_add]
  have hrange : Set.range (fun k : ℕ => (2 ^ k : ℕ) • Q)
      ⊆ (fun i : ℕ => i • Q) '' (Set.Iio m) := by
    rintro _ ⟨k, rfl⟩
    exact ⟨(2 ^ k) % m, Nat.mod_lt _ hm, (hmod _).symm⟩
  have hfin : (Set.range (fun k : ℕ => (2 ^ k : ℕ) • Q)).Finite :=
    Set.Finite.subset ((Set.finite_Iio m).image _) hrange
  exact (Set.infinite_range_of_injective (two_pow_smul_injective hQ hdvd)) hfin

/-! ## `E_55(ℚ)` is infinite -/

/-- Notation for the doubled point `2P` on `E_55`, `P = (9,28)`: its `x`-coordinate is
`2601/3136` with `2`-adic denominator valuation `6`. -/
private noncomputable def Q55 : (mordell (((55 : ℤ)) : ℚ)).toAffine.Point :=
  Point.some nonsingular_int_55_9_28 + Point.some nonsingular_int_55_9_28

private lemma xCoord_Q55 : xCoord Q55 = some (2601 / 3136 : ℚ) := by
  rw [Q55, mordell_double_xCoord _ _ _ nonsingular_int_55_9_28 (by norm_num)]
  norm_num

/-- **`E_55(ℚ)` is infinite.**  Elementary consequence of the unbounded `2`-adic growth of the
denominators along `{2^k · 2P}`; equivalently, `E_55 : y² = x³ + 55` has positive rank. -/
theorem mordell_55_points_infinite :
    Infinite ((mordell (((55 : ℤ)) : ℚ)).toAffine.Point) :=
  mordell_points_infinite_of_two_dvd_den xCoord_Q55 (by norm_num)

/-- **`P = (9,28)` is a point of infinite order on `E_55`.**  No positive multiple of `P` is the
point at infinity. -/
theorem mordell_55_point_infinite_order (m : ℕ) (hm : 0 < m) :
    m • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point) ≠ 0 := by
  intro hzero
  have hQ2 : Q55 = (2 : ℕ) • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point) := by
    rw [Q55, two_nsmul]
  have h2 : m • Q55 = 0 := by
    rw [hQ2, ← mul_nsmul', mul_comm, mul_nsmul', hzero, nsmul_zero]
  exact not_torsion_of_two_dvd_den xCoord_Q55 (by norm_num) m hm h2

/-! ## The capstone: infinitely many distinct violations of the "only bad primes" conjecture -/

/-- **The refutation, in its strongest orbit form.**  On `E_55 : y² = x³ + 55` with
`P = (9,28)` there are *infinitely many distinct* multiples `nP` whose `x`-coordinate has a
denominator divisible by the good prime `7` (recall `7 ∤ Δ = -432 · 55²`).  So the "only bad
primes" conjecture does not merely fail at one index: it fails at an infinite, explicitly
described set of pairwise distinct rational points. -/
theorem good_prime_orbit_violations_infinite_55 :
    {R : (mordell (((55 : ℤ)) : ℚ)).toAffine.Point |
      (∃ n : ℕ, R = n • (Point.some nonsingular_int_55_9_28 :
        (mordell (((55 : ℤ)) : ℚ)).toAffine.Point)) ∧
      ∃ X : ℚ, xCoord R = some X ∧ 7 ∣ X.den}.Infinite := by
  refine Set.infinite_of_injective_forall_mem
    (two_pow_smul_injective xCoord_Q55 (by norm_num)) ?_
  intro k
  have hQP : Q55 = (2 : ℕ) • (Point.some nonsingular_int_55_9_28 :
      (mordell (((55 : ℤ)) : ℚ)).toAffine.Point) := by
    rw [Q55, two_nsmul]
  refine ⟨⟨2 ^ k * 2, ?_⟩, ?_⟩
  · show (2 ^ k : ℕ) • Q55 = (2 ^ k * 2 : ℕ) • _
    rw [hQP, mul_nsmul']
  · obtain ⟨Y, hY, -⟩ :=
      two_pow_smul_den_factorization xCoord_Q55 (by norm_num : 2 ∣ (2601 / 3136 : ℚ).den) k
    exact ⟨Y, hY, dvd_den_nsmul (by norm_num) xCoord_Q55 (by norm_num) (2 ^ k) Y hY⟩

end MordellDenominators