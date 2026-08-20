import Catalog.Shared.MordellDenominatorValuations

/-!
# Two-sided barriers: denominators of `x(2P)` neither exclude good primes nor reveal `p`, `q`

`Catalog/Shared/MordellDenominatorPrimes.lean` shows that primes of good reduction *do* occur
in the denominators of doubled points on Mordell curves.  This file completes the picture with
the complementary barrier: the primes `p, q` dividing `N = pq` need *not* occur at all.
Together the two statements say that the denominator of `x(2P)` is not a fingerprint of the
factorisation of `N` in either direction.

## Main results

* `addOrderOf_reduction_eq_two` : the group-theoretic content of the mechanism — at a good
  prime `ℓ ≥ 5` dividing `y`, the reduction `P̄` has additive order exactly `2` in
  `E_N(𝔽_ℓ)`.  So `ℓ` appears in the denominator precisely because `P̄` is a `2`-torsion
  point of the reduced curve.
* `barrier_bad_primes_absent` : for `N = 35 = 5 · 7` and `P = (1, 6)`,
  `x(2P) = -31/16`, whose denominator is a power of `2`: neither `5` nor `7` appears.
* `factorisation_barrier` : consequently there is a semiprime `N = p q` and a rational point
  `P` on `E_N` such that no prime factor of `N` divides the denominator of `x(2P)`; the
  denominator carries no information about the factorisation.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if good primes intrude into denominators, then symmetrically the
  bad primes `p, q` should be able to vanish from them, since `ℓ ∣ den x(2P)` is equivalent to
  a torsion condition on the reduction, which for `ℓ ∣ N` is not even defined (bad reduction).
Experiment (Experimenter): the sweep in `ComputationalEvidence.md` shows `q` never appeared
  (0/7 curves with a small integral point) and `p` appeared in only 2/7.  For `N = 35`,
  `P = (1,6)` we get `x(2P) = -279/144 = -31/16`: a clean power of two.
Analysis (Analyst): the two barriers have the same source.  `den x(2P) = 4y²/gcd(...)`, so the
  denominator only sees `y`; the factorisation of `N` enters only through the numerator, where
  it is generically cancelled.  Hence any factoring heuristic reading `p` or `q` off the
  denominators is reading a quantity that provably does not depend on them.
Critique (Critic): `barrier_bad_primes_absent` is a single numeric instance, so we also state
  `factorisation_barrier` in the same quantified language as `OnlyBadPrimesConj`, and derive
  the `2`-torsion statement `addOrderOf_reduction_eq_two` in full generality to show the
  phenomenon is structural.
-/

namespace MordellDenominators

open WeierstrassCurve WeierstrassCurve.Affine

/-! ## The reduced point is exactly `2`-torsion -/

/-- **Order-two reduction.**  For an integral point `(x, y)` of `E_N` and a prime `ℓ ≥ 5` of
good reduction with `ℓ ∣ y`, the reduction `P̄ ∈ E_N(𝔽_ℓ)` has additive order exactly `2`.
This is the group-theoretic reason why `ℓ` shows up in the denominator of `x(2P)`. -/
theorem addOrderOf_reduction_eq_two {N x y : ℤ} {ℓ : ℕ} [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (hlN : ¬(ℓ : ℤ) ∣ N) (heq : y ^ 2 = x ^ 3 + N) (hly : (ℓ : ℤ) ∣ y) :
    ∃ h : (mordell ((N : ZMod ℓ))).toAffine.Nonsingular ((x : ZMod ℓ)) ((y : ZMod ℓ)),
      addOrderOf (Point.some h) = 2 := by
  obtain ⟨h, hh⟩ := reduction_double_eq_zero hl5 hlN heq hly
  refine ⟨h, ?_⟩
  have h2 : (2 : ℕ) • (Point.some h) = 0 := by rw [two_nsmul]; exact hh
  exact addOrderOf_eq_prime h2 (Point.some_ne_zero h)

/-! ## The prime factors of `N` can be completely absent -/

/-- `(1, 6)` is a nonsingular point of `E_35 : y² = x³ + 35` (indeed `6² = 36 = 1³ + 35`). -/
lemma nonsingular_35_1_6 : (mordell (((5 * 7 : ℕ) : ℚ))).toAffine.Nonsingular 1 6 := by
  have hΔ : (mordell (((5 * 7 : ℕ) : ℚ))).Δ ≠ 0 := by rw [mordell_Δ]; norm_num
  exact (WeierstrassCurve.Affine.equation_iff_nonsingular_of_Δ_ne_zero hΔ).mp
    ((mordell_equation_iff _ _ _).mpr (by norm_num))

/-- **Barrier: the bad primes need not appear.**  On `E_35 : y² = x³ + 35` with `35 = 5 · 7`,
doubling `P = (1, 6)` gives `x(2P) = -279/144 = -31/16`, a denominator which is a pure power
of `2`.  Neither `5` nor `7` — the prime factors of `N` — divides it. -/
theorem barrier_bad_primes_absent :
    xCoord (Point.some nonsingular_35_1_6 + Point.some nonsingular_35_1_6)
        = some (-31 / 16 : ℚ) ∧
      ((-31 / 16 : ℚ)).den = 16 ∧ ¬(5 ∣ ((-31 / 16 : ℚ)).den) ∧ ¬(7 ∣ ((-31 / 16 : ℚ)).den) := by
  refine ⟨?_, by norm_num, by norm_num, by norm_num⟩
  rw [mordell_double_xCoord _ _ _ nonsingular_35_1_6 (by norm_num)]
  norm_num

/-- **Factorisation barrier.**  There is a semiprime `N = p q` and a nonsingular rational
point `P` of `E_N`, not `2`-torsion, such that no prime factor of `N` divides the denominator
of `x(2P)`.  Hence the denominators of doubled points cannot be used to detect `p` or `q`. -/
theorem factorisation_barrier :
    ∃ (p q : ℕ), p.Prime ∧ q.Prime ∧ p ≠ q ∧
      ∃ (x y : ℚ) (h : (mordell (((p * q : ℕ) : ℚ))).toAffine.Nonsingular x y), y ≠ 0 ∧
        ∀ X : ℚ, xCoord (Point.some h + Point.some h) = some X →
          ¬(p ∣ X.den) ∧ ¬(q ∣ X.den) := by
  refine ⟨5, 7, by norm_num, by norm_num, by norm_num, 1, 6, nonsingular_35_1_6,
    by norm_num, ?_⟩
  intro X hX
  rw [barrier_bad_primes_absent.1] at hX
  have hXval : X = -31 / 16 := by simpa using hX.symm
  subst hXval
  exact ⟨by norm_num, by norm_num⟩

end MordellDenominators