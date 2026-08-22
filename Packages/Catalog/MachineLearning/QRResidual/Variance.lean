import MachineLearning.QRResidual.Distribution

/-!
# The exact variance of the QR footprint dial

`MeanDial` computed the *mean* of the dial over a full period of moduli, and
`Distribution` computed the exact joint law of the per-prime quadratic-residue indicators
(they are exactly independent, with `(p+1)/2` favourable residues out of `p`).

This file closes the second-moment question, which is what the regression experiment
actually cares about: the mean of the dial is a constant and carries no signal, so *all*
of its predictive power lives in the fluctuation.  Here that fluctuation is computed in
closed form:

`Var(qrWeight) = Σ_{p ≤ B} (p² − 1)/p⁴.`

Main results.

* `qr_density_single` — `#{N < P : N is a QR mod p} = P·(p+1)/(2p)`.
* `qr_density_pair` — the joint density factorises for `p ≠ q` (pairwise independence in
  quantitative form).
* `sum_sq_dev_qrWeight` — **the exact variance identity**
  `Σ_{N < P} (qrWeight N − mean)² = P · Σ_{p ≤ B} (p² − 1)/p⁴`.
* `qrWeight_variance_pos` — the variance is strictly positive as soon as the factor base is
  nonempty, so the dial genuinely fluctuates.
* `qrWeight_nonconstant_on_period` — consequently two moduli inside a single period already
  receive different dial values: the feature is not a constant, and the observed R² lift
  cannot be an artefact of a degenerate regressor.
* `qrWeight_variance_lt_half` — the variance is bounded by `Σ_{p ≥ 3} 1/p² < 1/2`
  uniformly in `B`: the dial is a *bounded-fluctuation* feature.
-/

namespace QRResidual

open Finset

/-! ## Indicators and densities -/

/-- The quadratic-residue indicator of `N` at `p`, as a rational number. -/
def qrInd (N : ℤ) (p : ℕ) : ℚ := if IsQR N p then 1 else 0

/-- The density of quadratic residues mod `p`: `(p+1)/(2p)` (the `(p-1)/2` nonzero squares
plus the ramified residue `0`). -/
def qrDensity (p : ℕ) : ℚ := ((p : ℚ) + 1) / (2 * p)

theorem qrInd_mul_self (N : ℤ) (p : ℕ) : qrInd N p * qrInd N p = qrInd N p := by
  unfold qrInd; by_cases h : IsQR N p <;> simp [h]

/-- The dial is the indicator-weighted sum `Σ_p (2/p)·1[p is a QR prime of N]`. -/
theorem qrWeight_eq_sum_ind (N : ℤ) (B : ℕ) :
    qrWeight N B = ∑ p ∈ oddFactorBase B, (2 : ℚ) / p * qrInd N p := by
  classical
  unfold qrWeight qrInd
  rw [Finset.sum_filter]
  refine Finset.sum_congr rfl ?_
  intro p _
  by_cases h : IsQR N p <;> simp [h]

/-- For an odd prime `p`, the natural-number halving `(p+1)/2` is exact. -/
theorem cast_half_succ {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    ((((p + 1) / 2 : ℕ)) : ℚ) = ((p : ℚ) + 1) / 2 := by
  have hodd : p % 2 = 1 := Nat.odd_iff.1 (hp.odd_of_ne_two hp2)
  obtain ⟨k, hk⟩ : ∃ k, p + 1 = 2 * k := ⟨(p + 1) / 2, by omega⟩
  have hdiv : (p + 1) / 2 = k := by omega
  rw [hdiv]
  have : ((p : ℚ) + 1) = 2 * k := by exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) hk
  rw [this]; ring

/-- `∏_{r ∉ T} r · ∏_{r ∈ T} r = P` for a subset `T` of the factor base. -/
theorem prod_sdiff_mul_prod {B : ℕ} {T : Finset ℕ} (hT : T ⊆ oddFactorBase B) :
    (∏ r ∈ oddFactorBase B \ T, r) * (∏ r ∈ T, r) = basePrimorial B := by
  classical
  rw [basePrimorial]
  exact Finset.prod_sdiff hT

/-- **Single-prime density.**  Exactly `P·(p+1)/(2p)` of the moduli in one period are
quadratic residues mod `p`. -/
theorem qr_density_single (B p : ℕ) (hp : p ∈ oddFactorBase B) :
    ∑ N ∈ range (basePrimorial B), qrInd (N : ℤ) p
      = (basePrimorial B : ℚ) * qrDensity p := by
  classical
  obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hp
  have hppos : (0 : ℚ) < p := by exact_mod_cast hprime.pos
  have hT : ({p} : Finset ℕ) ⊆ oddFactorBase B := by
    simpa [Finset.singleton_subset_iff] using hp
  have hcount := card_qr_joint B {p} hT
  have hpred : ((range (basePrimorial B)).filter
        (fun N : ℕ => ∀ r ∈ ({p} : Finset ℕ), IsQR (N : ℤ) r))
      = (range (basePrimorial B)).filter (fun N : ℕ => IsQR (N : ℤ) p) := by
    apply Finset.filter_congr
    intro N _
    simp
  rw [hpred] at hcount
  simp only [Finset.prod_singleton] at hcount
  have hsum : ∑ N ∈ range (basePrimorial B), qrInd (N : ℤ) p
      = (((range (basePrimorial B)).filter (fun N : ℕ => IsQR (N : ℤ) p)).card : ℚ) := by
    unfold qrInd
    rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const_zero, add_zero, nsmul_eq_mul,
      mul_one]
  rw [hsum, hcount]
  set K := ∏ r ∈ oddFactorBase B \ ({p} : Finset ℕ), r with hK
  have hP : K * p = basePrimorial B := by
    have := prod_sdiff_mul_prod (B := B) hT
    simpa [hK] using this
  have hPQ : (basePrimorial B : ℚ) = (K : ℚ) * p := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) hP.symm
  rw [Nat.cast_mul, cast_half_succ hprime hp2, hPQ, qrDensity]
  field_simp

/-- **Pairwise independence, quantitatively.**  For distinct factor-base primes the joint
density of the two quadratic-residue indicators is the product of the densities. -/
theorem qr_density_pair (B p q : ℕ) (hp : p ∈ oddFactorBase B) (hq : q ∈ oddFactorBase B)
    (hpq : p ≠ q) :
    ∑ N ∈ range (basePrimorial B), qrInd (N : ℤ) p * qrInd (N : ℤ) q
      = (basePrimorial B : ℚ) * qrDensity p * qrDensity q := by
  classical
  obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hp
  obtain ⟨-, hqprime, hq2⟩ := mem_oddFactorBase.1 hq
  have hppos : (0 : ℚ) < p := by exact_mod_cast hprime.pos
  have hqpos : (0 : ℚ) < q := by exact_mod_cast hqprime.pos
  have hT : ({p, q} : Finset ℕ) ⊆ oddFactorBase B := by
    intro r hr
    rcases Finset.mem_insert.1 hr with h | h
    · subst h; exact hp
    · rw [Finset.mem_singleton] at h; subst h; exact hq
  have hcount := card_qr_joint B {p, q} hT
  have hpred : ((range (basePrimorial B)).filter
        (fun N : ℕ => ∀ r ∈ ({p, q} : Finset ℕ), IsQR (N : ℤ) r))
      = (range (basePrimorial B)).filter
          (fun N : ℕ => IsQR (N : ℤ) p ∧ IsQR (N : ℤ) q) := by
    apply Finset.filter_congr
    intro N _
    simp
  rw [hpred] at hcount
  rw [Finset.prod_insert (by simpa using hpq), Finset.prod_singleton] at hcount
  have hsum : ∑ N ∈ range (basePrimorial B), qrInd (N : ℤ) p * qrInd (N : ℤ) q
      = (((range (basePrimorial B)).filter
          (fun N : ℕ => IsQR (N : ℤ) p ∧ IsQR (N : ℤ) q)).card : ℚ) := by
    unfold qrInd
    rw [← Finset.sum_filter_add_sum_filter_not (range (basePrimorial B))
      (fun N : ℕ => IsQR (N : ℤ) p ∧ IsQR (N : ℤ) q)]
    have h1 : ∑ N ∈ (range (basePrimorial B)).filter
        (fun N : ℕ => IsQR (N : ℤ) p ∧ IsQR (N : ℤ) q),
        ((if IsQR (N : ℤ) p then (1 : ℚ) else 0) * (if IsQR (N : ℤ) q then 1 else 0))
        = (((range (basePrimorial B)).filter
            (fun N : ℕ => IsQR (N : ℤ) p ∧ IsQR (N : ℤ) q)).card : ℚ) := by
      rw [Finset.sum_congr rfl (fun N hN => ?_), Finset.sum_const, nsmul_eq_mul, mul_one]
      obtain ⟨-, h1, h2⟩ := Finset.mem_filter.1 hN
      simp [h1, h2]
    have h2 : ∑ N ∈ (range (basePrimorial B)).filter
        (fun N : ℕ => ¬ (IsQR (N : ℤ) p ∧ IsQR (N : ℤ) q)),
        ((if IsQR (N : ℤ) p then (1 : ℚ) else 0) * (if IsQR (N : ℤ) q then 1 else 0)) = 0 := by
      refine Finset.sum_eq_zero ?_
      intro N hN
      obtain ⟨-, h⟩ := Finset.mem_filter.1 hN
      by_cases hpp : IsQR (N : ℤ) p
      · have : ¬ IsQR (N : ℤ) q := fun hc => h ⟨hpp, hc⟩
        simp [this]
      · simp [hpp]
    rw [h1, h2, add_zero]
  rw [hsum, hcount]
  set K := ∏ r ∈ oddFactorBase B \ ({p, q} : Finset ℕ), r with hK
  have hP : K * (p * q) = basePrimorial B := by
    have := prod_sdiff_mul_prod (B := B) hT
    rw [Finset.prod_insert (by simpa using hpq), Finset.prod_singleton] at this
    simpa [hK] using this
  have hPQ : (basePrimorial B : ℚ) = (K : ℚ) * (p * q) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) hP.symm
  rw [Nat.cast_mul, Nat.cast_mul, cast_half_succ hprime hp2, cast_half_succ hqprime hq2,
    hPQ, qrDensity, qrDensity]
  field_simp

/-! ## The variance identity -/

/-- The centred indicators at distinct primes have vanishing covariance, and the variance
of a single indicator is `a(1-a)`. -/
theorem sum_centred_ind_mul (B p q : ℕ) (hp : p ∈ oddFactorBase B)
    (hq : q ∈ oddFactorBase B) :
    ∑ N ∈ range (basePrimorial B),
        (qrInd (N : ℤ) p - qrDensity p) * (qrInd (N : ℤ) q - qrDensity q)
      = if p = q then (basePrimorial B : ℚ) * (qrDensity p * (1 - qrDensity p)) else 0 := by
  classical
  have hexpand : ∀ N : ℕ,
      (qrInd (N : ℤ) p - qrDensity p) * (qrInd (N : ℤ) q - qrDensity q)
        = qrInd (N : ℤ) p * qrInd (N : ℤ) q - qrDensity q * qrInd (N : ℤ) p
          - qrDensity p * qrInd (N : ℤ) q + qrDensity p * qrDensity q := by
    intro N; ring
  simp_rw [hexpand]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.sum_sub_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, Finset.sum_const, nsmul_eq_mul,
    Finset.card_range, qr_density_single B p hp, qr_density_single B q hq]
  by_cases hpq : p = q
  · subst hpq
    rw [if_pos rfl]
    have hdiag : ∑ N ∈ range (basePrimorial B), qrInd (N : ℤ) p * qrInd (N : ℤ) p
        = (basePrimorial B : ℚ) * qrDensity p := by
      simp_rw [qrInd_mul_self]
      exact qr_density_single B p hp
    rw [hdiag]; ring
  · rw [if_neg hpq, qr_density_pair B p q hp hq hpq]
    ring

/-- **The exact variance of the QR footprint dial.**  Over a full period of moduli, the
mean-squared deviation of the dial from its mean `Σ (p+1)/p²` is exactly
`Σ_{p ≤ B} (p² − 1)/p⁴`.  This is the quantitative form of "all the content of the dial is
in its fluctuation": the mean is a constant, and the fluctuation has this closed form,
coming entirely from the diagonal terms because the QR indicators are independent. -/
theorem sum_sq_dev_qrWeight (B : ℕ) :
    ∑ N ∈ range (basePrimorial B),
        (qrWeight (N : ℤ) B - ∑ p ∈ oddFactorBase B, ((p : ℚ) + 1) / (p : ℚ) ^ 2) ^ 2
      = (basePrimorial B : ℚ) * ∑ p ∈ oddFactorBase B, ((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4 := by
  classical
  -- rewrite the deviation as a sum of centred indicators
  have hdev : ∀ N : ℕ,
      qrWeight (N : ℤ) B - ∑ p ∈ oddFactorBase B, ((p : ℚ) + 1) / (p : ℚ) ^ 2
        = ∑ p ∈ oddFactorBase B, (2 : ℚ) / p * (qrInd (N : ℤ) p - qrDensity p) := by
    intro N
    rw [qrWeight_eq_sum_ind, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl ?_
    intro p hp
    obtain ⟨-, hprime, -⟩ := mem_oddFactorBase.1 hp
    have hppos : (0 : ℚ) < p := by exact_mod_cast hprime.pos
    rw [qrDensity]
    field_simp
  simp_rw [hdev, sq]
  simp_rw [Finset.sum_mul_sum]
  rw [Finset.sum_comm]
  have hswap : ∀ p ∈ oddFactorBase B,
      ∑ N ∈ range (basePrimorial B), ∑ q ∈ oddFactorBase B,
          ((2 : ℚ) / p * (qrInd (N : ℤ) p - qrDensity p)) *
            ((2 : ℚ) / q * (qrInd (N : ℤ) q - qrDensity q))
        = (basePrimorial B : ℚ) * (((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4) := by
    intro p hp
    obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hp
    have hppos : (0 : ℚ) < p := by exact_mod_cast hprime.pos
    rw [Finset.sum_comm]
    have hinner : ∀ q ∈ oddFactorBase B,
        ∑ N ∈ range (basePrimorial B),
            ((2 : ℚ) / p * (qrInd (N : ℤ) p - qrDensity p)) *
              ((2 : ℚ) / q * (qrInd (N : ℤ) q - qrDensity q))
          = ((2 : ℚ) / p) * ((2 : ℚ) / q) *
              (if p = q then (basePrimorial B : ℚ) * (qrDensity p * (1 - qrDensity p))
                else 0) := by
      intro q hq
      rw [← sum_centred_ind_mul B p q hp hq, Finset.mul_sum]
      refine Finset.sum_congr rfl ?_
      intro N _
      ring
    rw [Finset.sum_congr rfl hinner]
    have hzero : ∀ q ∈ oddFactorBase B, q ≠ p →
        ((2 : ℚ) / p) * ((2 : ℚ) / q) *
          (if p = q then (basePrimorial B : ℚ) * (qrDensity p * (1 - qrDensity p))
            else 0) = 0 := by
      intro q _ hqp
      rw [if_neg (fun h => hqp h.symm), mul_zero]
    rw [Finset.sum_eq_single p hzero (fun h => absurd hp h), if_pos rfl, qrDensity]
    field_simp
    ring
  rw [Finset.sum_congr rfl hswap, ← Finset.mul_sum]
  congr 1
  exact Finset.sum_congr rfl fun x _ => by ring

/-! ## Consequences: the dial really fluctuates, but only a little -/

/-- The per-prime variance contribution is strictly positive for every odd prime. -/
theorem variance_term_pos {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) :
    0 < ((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4 := by
  have h3 : 3 ≤ p := by
    rcases hp.two_le.lt_or_eq with h | h
    · omega
    · exact absurd h.symm hp2
  have hq : (3 : ℚ) ≤ p := by exact_mod_cast h3
  have hppos : (0 : ℚ) < p := by linarith
  apply div_pos
  · nlinarith
  · positivity

/-- **The dial genuinely fluctuates.**  As soon as the factor base is nonempty, the exact
variance is strictly positive. -/
theorem qrWeight_variance_pos {B : ℕ} (h : (oddFactorBase B).Nonempty) :
    0 < ∑ p ∈ oddFactorBase B, ((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4 := by
  refine Finset.sum_pos ?_ h
  intro p hp
  obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hp
  exact variance_term_pos hprime hp2

/-- **The feature is not a constant regressor.**  Positive variance forces two moduli
inside a single period with different dial values, so the R² lift reported by the
experiment cannot be an artefact of a degenerate (constant) feature. -/
theorem qrWeight_nonconstant_on_period {B : ℕ} (h : (oddFactorBase B).Nonempty) :
    ∃ N₁ N₂ : ℕ, N₁ < basePrimorial B ∧ N₂ < basePrimorial B ∧
      qrWeight (N₁ : ℤ) B ≠ qrWeight (N₂ : ℤ) B := by
  classical
  by_contra hcon
  push_neg at hcon
  set m := ∑ p ∈ oddFactorBase B, ((p : ℚ) + 1) / (p : ℚ) ^ 2 with hm
  have hPpos : 0 < basePrimorial B := by
    rw [basePrimorial]
    refine Finset.prod_pos ?_
    intro p hp
    exact (mem_oddFactorBase.1 hp).2.1.pos
  -- every dial value on the period equals the value at 0
  have hconst : ∀ N ∈ range (basePrimorial B), qrWeight (N : ℤ) B = qrWeight (0 : ℤ) B := by
    intro N hN
    exact hcon N 0 (Finset.mem_range.1 hN) hPpos
  have hkey := sum_sq_dev_qrWeight B
  -- the sum of squares is `P·(c − m)²` for the common value `c`
  have hlhs : ∑ N ∈ range (basePrimorial B), (qrWeight (N : ℤ) B - m) ^ 2
      = (basePrimorial B : ℚ) * (qrWeight (0 : ℤ) B - m) ^ 2 := by
    rw [Finset.sum_congr rfl (fun N hN => by rw [hconst N hN]), Finset.sum_const,
      nsmul_eq_mul, Finset.card_range]
  rw [hlhs] at hkey
  have hPQ : (0 : ℚ) < (basePrimorial B : ℚ) := by exact_mod_cast hPpos
  have hvar := qrWeight_variance_pos (B := B) h
  -- but then the mean must be the common value, forcing the variance to vanish
  have hc : (qrWeight (0 : ℤ) B - m) ^ 2
      = ∑ p ∈ oddFactorBase B, ((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4 :=
    mul_left_cancel₀ (ne_of_gt hPQ) hkey
  -- the mean of a constant sequence is the constant, so the deviation is zero
  have hmean := mean_qrWeight B
  have hmean' : (basePrimorial B : ℚ) * qrWeight (0 : ℤ) B = (basePrimorial B : ℚ) * m := by
    rw [← hmean, Finset.sum_congr rfl (fun N hN => hconst N hN), Finset.sum_const,
      nsmul_eq_mul, Finset.card_range]
  have hzero : qrWeight (0 : ℤ) B - m = 0 := by
    have := mul_left_cancel₀ (ne_of_gt hPQ) hmean'
    rw [this]; ring
  rw [hzero] at hc
  simp at hc
  rw [← hc] at hvar
  exact lt_irrefl 0 hvar

/-- **Bounded fluctuation.**  The variance of the dial is uniformly bounded by `1/2`,
independently of the bound `B`: the feature is a small, tightly concentrated perturbation
of the random-model footprint. -/
theorem qrWeight_variance_lt_half (B : ℕ) :
    ∑ p ∈ oddFactorBase B, ((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4 < 1 / 2 := by
  classical
  have hterm : ∀ p ∈ oddFactorBase B,
      ((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4 ≤ 1 / ((p : ℚ) - 1) - 1 / (p : ℚ) := by
    intro p hp
    obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hp
    have h3 : 3 ≤ p := by
      rcases hprime.two_le.lt_or_eq with h | h
      · omega
      · exact absurd h.symm hp2
    have hq : (3 : ℚ) ≤ p := by exact_mod_cast h3
    have h1 : (0 : ℚ) < (p : ℚ) - 1 := by linarith
    have h2 : (0 : ℚ) < (p : ℚ) := by linarith
    have key : 1 / ((p : ℚ) - 1) - 1 / (p : ℚ) - ((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4
        = ((p : ℚ) ^ 3 + (p : ℚ) ^ 2 - (p : ℚ))
            / (((p : ℚ) - 1) * (p : ℚ) * (p : ℚ) ^ 4) := by
      field_simp
      ring
    rw [← sub_nonneg, key]
    apply div_nonneg
    · nlinarith
    · positivity
  refine lt_of_le_of_lt (Finset.sum_le_sum hterm) ?_
  -- the telescoping majorant is bounded by its value at the smallest prime, 3
  have htel : ∑ p ∈ oddFactorBase B, (1 / ((p : ℚ) - 1) - 1 / (p : ℚ))
      ≤ ∑ n ∈ Finset.Ico 3 (B + 1), (1 / ((n : ℚ) - 1) - 1 / (n : ℚ)) := by
    refine Finset.sum_le_sum_of_subset_of_nonneg ?_ ?_
    · intro p hp
      obtain ⟨hpB, hprime, hp2⟩ := mem_oddFactorBase.1 hp
      have h3 : 3 ≤ p := by
        rcases hprime.two_le.lt_or_eq with h | h
        · omega
        · exact absurd h.symm hp2
      exact Finset.mem_Ico.2 ⟨h3, by omega⟩
    · intro n hn _
      have h3 : 3 ≤ n := (Finset.mem_Ico.1 hn).1
      have hq : (3 : ℚ) ≤ n := by exact_mod_cast h3
      have h1 : (0 : ℚ) < (n : ℚ) - 1 := by linarith
      have h2 : (0 : ℚ) < (n : ℚ) := by linarith
      rw [sub_nonneg]
      exact div_le_div_of_nonneg_left (by norm_num) h1 (by linarith)
  refine lt_of_le_of_lt htel ?_
  have hsum : ∀ k : ℕ, ∑ n ∈ Finset.Ico 3 (k + 3), (1 / ((n : ℚ) - 1) - 1 / (n : ℚ))
      = 1 / 2 - 1 / ((k : ℚ) + 2) := by
    intro k
    induction k with
    | zero => norm_num
    | succ j ih =>
      have hrange : j + 1 + 3 = (j + 3) + 1 := by omega
      rw [hrange, Finset.sum_Ico_succ_top (by omega), ih]
      have hj : ((j : ℚ) + 2) ≠ 0 := by positivity
      have hj3 : ((j : ℚ) + 3) ≠ 0 := by positivity
      push_cast
      have hstep : ((j : ℚ) + 3 - 1) = (j : ℚ) + 2 := by ring
      rw [hstep]
      field_simp
      ring
  by_cases hB : B + 1 ≤ 3
  · have : Finset.Ico 3 (B + 1) = ∅ := Finset.Ico_eq_empty (by omega)
    rw [this]; norm_num
  · obtain ⟨k, hk⟩ : ∃ k, B + 1 = k + 3 := ⟨B + 1 - 3, by omega⟩
    rw [hk, hsum k]
    have : (0 : ℚ) < 1 / ((k : ℚ) + 2) := by positivity
    linarith

section LabNotes

/-! Kernel-checked instances of the variance law for the factor base `{3, 5}` (`B = 5`,
period `P = 15`).  The exact variance is `8/81 + 24/625 = 6944/50625 ≈ 0.13717`, well
inside the uniform bound `1/2`. -/

example : oddFactorBase 5 = {3, 5} := by decide

example : ∑ p ∈ ({3, 5} : Finset ℕ), ((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4 = 6944 / 50625 := by
  norm_num

example : ∑ p ∈ ({3, 5} : Finset ℕ), ((p : ℚ) ^ 2 - 1) / (p : ℚ) ^ 4 < 1 / 2 := by
  norm_num

/-- The mean of the dial for `B = 5` is `4/9 + 6/25 = 154/225`, and the six moduli of the
period with full QR pattern sit at `2/3 + 2/5 = 16/15` — a deviation of `+0.529`,
comparable with the exact standard deviation `√(6944/50625) ≈ 0.370`. -/
example : ∑ p ∈ ({3, 5} : Finset ℕ), ((p : ℚ) + 1) / (p : ℚ) ^ 2 = 154 / 225 := by
  norm_num

example : qrWeight 4 5 = 16 / 15 := by
  have h : (oddFactorBase 5).filter (fun p => IsQR (4 : ℤ) p) = {3, 5} := by decide
  rw [qrWeight, h]
  norm_num

end LabNotes

end QRResidual