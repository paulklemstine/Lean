import Applications.PrimePowerSmoothnessBudget

/-!
# The prime-power hit spectrum carries the whole smoothness budget

Second research cycle on experiment 505.  Cycle one
(`Catalog/Applications/PrimePowerSmoothnessBudget.lean`) showed that a single
prime-power hit is an exact shift of the smoothness budget and that the marginal
squarefree-hit features cannot see it.  Two questions were left open, and both
are answered here.

**Q1 (how much of the budget do the hit features carry?).**  *All of it.*
`sum_bigOmega_eq_sum_hitCount` is an exact identity: summed over the smooth
pool, the total budget `∑ Ω(v)` equals the sum of the prime-power hit counts
`∑_{p ≤ B} ∑_{j ≥ 1} hit(p^j)`.  Via cycle one's rescaling this is
`∑_{p ≤ B} ∑_{j ≥ 1} Ψ_B(x / p^j)` (`sum_bigOmega_eq_sum_smoothCount`): the
prime-power features are a *linear coordinate system* for the budget, which the
squarefree features (only the `j = 1` layer) are not.

**Q2 (are the hit features a complete invariant?).**  Yes.
`smooth_eq_of_hitProfile_eq`: two positive `B`-smooth values with the same
prime-power hit profile are equal.  So the feature family is *complete*, while
`exists_sqfHits_collision` shows its `j = 1` truncation provably collides as
soon as the pool outgrows `2 ^ π(B)` — an unavoidable pigeonhole, made
unconditional at `B = 2` in `exists_sqfHits_collision_two`.

## Main results

* `bigOmega_eq_sum_primesBelow` — the budget of a smooth value is the sum of its
  factor-base valuations.
* `factorization_eq_card_filter` — a valuation is the number of prime-power hits
  it triggers.
* `sum_bigOmega_eq_sum_hitCount`, `sum_bigOmega_eq_sum_smoothCount` — **the
  budget decomposition**.
* `smooth_eq_of_hitProfile_eq` — the prime-power profile is a complete invariant
  of a smooth value.
* `exists_sqfHits_collision`, `exists_sqfHits_collision_two` — the squarefree
  truncation is provably incomplete.
-/

namespace PrimePowerBudget

open Finset

/-! ## The budget as a sum of valuations -/

lemma bigOmega_eq_sum_primeFactors (v : ℕ) :
    bigOmega v = ∑ p ∈ v.primeFactors, v.factorization p := by
  have := ArithmeticFunction.cardFactors_eq_sum_factorization (n := v)
  rw [ArithmeticFunction.cardFactors_apply] at this
  simpa [bigOmega, Finsupp.sum, Nat.support_factorization] using this

/-- For a `B`-smooth value the budget is the sum of its factor-base valuations:
primes outside the factor base contribute nothing. -/
lemma bigOmega_eq_sum_primesBelow {B v : ℕ} (hsm : Sm B v) :
    bigOmega v = ∑ p ∈ Nat.primesBelow (B + 1), v.factorization p := by
  rw [bigOmega_eq_sum_primeFactors]
  refine Finset.sum_subset ?_ ?_
  · intro p hp
    exact Nat.mem_primesBelow.2 ⟨by have := hsm p hp; omega, Nat.prime_of_mem_primeFactors hp⟩
  · intro p _ hnot
    rw [← Nat.support_factorization] at hnot
    simpa using Finsupp.notMem_support_iff.1 hnot

/-- Every valuation of `v` is bounded by `log₂ v`: the base-two budget bounds all
prime-power exponents. -/
lemma factorization_le_log_two {p v : ℕ} (hp : p.Prime) (hv : v ≠ 0) :
    v.factorization p ≤ Nat.log 2 v := by
  have h1 : p ^ (v.factorization p) ∣ v := Nat.ordProj_dvd v p
  have h2 : (2 : ℕ) ^ (v.factorization p) ≤ p ^ (v.factorization p) :=
    Nat.pow_le_pow_left hp.two_le _
  have h3 : p ^ (v.factorization p) ≤ v := Nat.le_of_dvd (Nat.pos_of_ne_zero hv) h1
  exact (Nat.le_log_iff_pow_le (by norm_num) hv).2 (le_trans h2 h3)

/-- **A valuation counts prime-power hits.**  As long as the window `[1, J]`
reaches the valuation, `v_p(v)` is exactly the number of exponents `j` for which
the hit feature `p ^ j ∣ v` fires. -/
lemma factorization_eq_card_filter {p v J : ℕ} (hp : p.Prime) (hv : v ≠ 0)
    (hJ : v.factorization p ≤ J) :
    v.factorization p = ((Finset.Icc 1 J).filter (fun j => p ^ j ∣ v)).card := by
  have hset : ((Finset.Icc 1 J).filter (fun j => p ^ j ∣ v))
      = Finset.Icc 1 (v.factorization p) := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_Icc]
    rw [Nat.Prime.pow_dvd_iff_le_factorization hp hv]
    omega
  rw [hset, Nat.card_Icc]
  omega

/-! ## The budget decomposition -/

/-- **Budget decomposition (hit form).**  Summed over the whole `B`-smooth pool
below `x`, the smoothness budget is exactly the total number of prime-power hits:
`∑_v Ω(v) = ∑_{p ≤ B} ∑_{j = 1}^{⌊log₂ x⌋} hit(p^j)`.

This is the precise sense in which the prime-power features *carry* the budget:
they are not a heuristic proxy for it, they are a linear coordinate system for
it.  The squarefree features are the single layer `j = 1` of this sum. -/
theorem sum_bigOmega_eq_sum_hitCount (B x : ℕ) :
    ∑ v ∈ (Finset.Icc 1 x).filter (fun v => Sm B v), bigOmega v
      = ∑ p ∈ Nat.primesBelow (B + 1), ∑ j ∈ Finset.Icc 1 (Nat.log 2 x),
          hitCount B (p ^ j) x := by
  classical
  set J := Nat.log 2 x with hJ
  set P := (Finset.Icc 1 x).filter (fun v => Sm B v) with hP
  have hstep : ∀ v ∈ P, bigOmega v
      = ∑ p ∈ Nat.primesBelow (B + 1), ∑ j ∈ Finset.Icc 1 J,
          (if p ^ j ∣ v then 1 else 0) := by
    intro v hv
    simp only [hP, Finset.mem_filter, Finset.mem_Icc] at hv
    obtain ⟨⟨hv1, hvx⟩, hsm⟩ := hv
    have hv0 : v ≠ 0 := by omega
    rw [bigOmega_eq_sum_primesBelow hsm]
    refine Finset.sum_congr rfl ?_
    intro p hp
    have hpp := Nat.prime_of_mem_primesBelow hp
    have hle : v.factorization p ≤ J :=
      le_trans (factorization_le_log_two hpp hv0) (Nat.log_mono_right hvx)
    rw [factorization_eq_card_filter hpp hv0 hle, Finset.card_filter]
  rw [Finset.sum_congr rfl hstep, Finset.sum_comm]
  refine Finset.sum_congr rfl ?_
  intro p hp
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl ?_
  intro j _
  rw [← Finset.card_filter]
  unfold hitCount
  congr 1
  rw [hP, Finset.filter_filter]

/-- **Budget decomposition (rescaled form).**  Combining with cycle one's exact
rescaling, the total budget of the smooth pool is a sum of smooth counts at
geometrically rescaled bounds. -/
theorem sum_bigOmega_eq_sum_smoothCount (B x : ℕ) :
    ∑ v ∈ (Finset.Icc 1 x).filter (fun v => Sm B v), bigOmega v
      = ∑ p ∈ Nat.primesBelow (B + 1), ∑ j ∈ Finset.Icc 1 (Nat.log 2 x),
          smoothCount B (x / p ^ j) := by
  rw [sum_bigOmega_eq_sum_hitCount]
  refine Finset.sum_congr rfl ?_
  intro p hp
  have hpp := Nat.prime_of_mem_primesBelow hp
  have hpB : p ≤ B := by have := Nat.lt_of_mem_primesBelow hp; omega
  refine Finset.sum_congr rfl ?_
  intro j _
  refine hitCount_eq_smoothCount B (p ^ j) x (pow_pos hpp.pos j) ?_
  intro q hq
  have hqp := Nat.prime_of_mem_primeFactors hq
  have : q = p := (Nat.prime_dvd_prime_iff_eq hqp hpp).1
    (hqp.dvd_of_dvd_pow (Nat.dvd_of_mem_primeFactors hq))
  omega

/-! ## Completeness of the prime-power profile -/

/-- **The prime-power hit profile is a complete invariant.**  Two positive
`B`-smooth values that trigger exactly the same prime-power hit features are
equal.  Contrast `squarefree_features_blind`: the `j = 1` truncation of this
profile has infinite fibres. -/
theorem smooth_eq_of_hitProfile_eq {B v w : ℕ} (hv : 0 < v) (hw : 0 < w)
    (hsv : Sm B v) (hsw : Sm B w)
    (h : ∀ p ≤ B, ∀ j : ℕ, (p ^ j ∣ v ↔ p ^ j ∣ w)) : v = w := by
  refine Nat.eq_of_factorization_eq hv.ne' hw.ne' ?_
  intro p
  by_cases hp : p.Prime
  · by_cases hpB : p ≤ B
    · have h1 : v.factorization p ≤ w.factorization p := by
        rw [← Nat.Prime.pow_dvd_iff_le_factorization hp hw.ne']
        exact (h p hpB (v.factorization p)).1 (Nat.ordProj_dvd v p)
      have h2 : w.factorization p ≤ v.factorization p := by
        rw [← Nat.Prime.pow_dvd_iff_le_factorization hp hv.ne']
        exact (h p hpB (w.factorization p)).2 (Nat.ordProj_dvd w p)
      omega
    · have hv0 : v.factorization p = 0 := by
        by_contra hne
        exact hpB (hsv p (Nat.mem_primeFactors.2 ⟨hp,
          Nat.dvd_of_factorization_pos hne, hv.ne'⟩))
      have hw0 : w.factorization p = 0 := by
        by_contra hne
        exact hpB (hsw p (Nat.mem_primeFactors.2 ⟨hp,
          Nat.dvd_of_factorization_pos hne, hw.ne'⟩))
      rw [hv0, hw0]
  · rw [Nat.factorization_eq_zero_of_not_prime _ hp,
      Nat.factorization_eq_zero_of_not_prime _ hp]

/-- **The squarefree truncation must collide.**  Once the smooth pool is larger
than the number `2 ^ π(B)` of possible squarefree-hit vectors, two distinct
smooth values share a vector — so no predictor built from squarefree hits alone
can separate them. -/
theorem exists_sqfHits_collision {B x : ℕ}
    (h : 2 ^ (Nat.primesBelow (B + 1)).card < smoothCount B x) :
    ∃ v ∈ (Finset.Icc 1 x).filter (fun v => Sm B v),
      ∃ w ∈ (Finset.Icc 1 x).filter (fun v => Sm B v),
        v ≠ w ∧ sqfHits B v = sqfHits B w := by
  classical
  have hmaps : ∀ v ∈ (Finset.Icc 1 x).filter (fun v => Sm B v),
      sqfHits B v ∈ (Nat.primesBelow (B + 1)).powerset := by
    intro v _
    simp only [Finset.mem_powerset, sqfHits]
    exact Finset.filter_subset _ _
  have hcard : ((Nat.primesBelow (B + 1)).powerset).card
      < ((Finset.Icc 1 x).filter (fun v => Sm B v)).card := by
    rw [Finset.card_powerset]
    exact h
  obtain ⟨v, hv, w, hw, hne, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard hmaps
  exact ⟨v, hv, w, hw, hne, heq⟩

/-- The collision is unconditional in the exactly solvable case `B = 2`: for
`x ≥ 4` the pool of powers of two already outgrows the two possible
squarefree-hit vectors, so a colliding pair exists. -/
theorem exists_sqfHits_collision_two {x : ℕ} (hx : 4 ≤ x) :
    ∃ v ∈ (Finset.Icc 1 x).filter (fun v => Sm 2 v),
      ∃ w ∈ (Finset.Icc 1 x).filter (fun v => Sm 2 v),
        v ≠ w ∧ sqfHits 2 v = sqfHits 2 w := by
  refine exists_sqfHits_collision (B := 2) (x := x) ?_
  have hpi : (Nat.primesBelow 3).card = 1 := by decide
  have hcount : smoothCount 2 x = Nat.log 2 x + 1 := smoothCount_two (by omega)
  have hlog : 2 ≤ Nat.log 2 x :=
    (Nat.le_log_iff_pow_le (b := 2) (by norm_num) (by omega)).2 (by omega)
  rw [show (2 : ℕ) + 1 = 3 from rfl, hpi, hcount]
  omega

end PrimePowerBudget