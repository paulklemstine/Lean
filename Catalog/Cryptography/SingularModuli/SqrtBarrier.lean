import Cryptography.SingularModuli.RootCount

/-!
# Singular Moduli Factoring, Step 3: the `√N` barrier

`RootCount.lean` shows that for a monic `H` of degree `h` and a semiprime
`N = pq`, the number of useful evaluation points modulo `N` is at most
`h (p + q)`.  Here we convert that counting bound into the running-time
statement of the paper:

* `successDensity_le` — the probability that a uniformly random `j₀ ∈ [0, N)`
  succeeds is at most `h (1/p + 1/q)`;
* `successDensity_le_balanced` — for a balanced semiprime (`p ≤ q ≤ 3p`) this is
  at most `4h/√N`;
* `expected_trials_ge` — hence the expected number of evaluations before a
  success is at least `√N / (4h)`;
* `multiDiscriminant_successDensity_le_balanced` — **running several
  discriminants does not help**: over a family `F` of monic class polynomials of
  degree `≤ h`, the density of successful (discriminant, evaluation point) pairs
  is still at most `4h/√N`.  The barrier is not an artifact of using a single
  `H_D`.

The last item is the formal content of the "circularity bottleneck": the useful
set is `{j₀ : H_D(j₀) ≡ 0 mod p}`, which is defined in terms of the unknown
prime `p`, and it is a `O(h·√N)`-density subset of the search space no matter
how the discriminants are chosen.
-/

namespace SingularModuli

open Polynomial Finset FactoringBarriers

variable {p q : ℕ} {H : Polynomial ℤ}

/-- **Success density bound.** For monic `H` of degree `h`, a uniformly random
evaluation point succeeds with probability at most `h (1/p + 1/q)`. -/
theorem successDensity_le (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) (hH : H.Monic) :
    (successCount H (p * q) : ℝ) / (p * q) ≤ H.natDegree * (1 / p + 1 / q) := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp.pos
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have hcount : (successCount H (p * q) : ℝ) ≤ (H.natDegree : ℝ) * (p + q) := by
    have := successCount_le hp hq hne hH
    have := (Nat.cast_le (α := ℝ)).mpr this
    push_cast at this
    linarith
  rw [div_le_iff₀ (by positivity)]
  have hrw : (H.natDegree : ℝ) * (1 / p + 1 / q) * ((p : ℝ) * q)
      = (H.natDegree : ℝ) * (p + q) := by
    field_simp
    ring
  rw [hrw]
  exact hcount

/-- **The `√N` density bound for balanced semiprimes.** If `p ≤ q ≤ 3p` then a
uniformly random evaluation point succeeds with probability at most `4h/√N`. -/
theorem successDensity_le_balanced (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hle : p ≤ q) (hbal : q ≤ 3 * p) (hH : H.Monic) :
    (successCount H (p * q) : ℝ) / (p * q) ≤ 4 * H.natDegree / Real.sqrt (p * q) := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp.pos
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have hple : (p : ℝ) ≤ q := by exact_mod_cast hle
  have hbal' : (q : ℝ) ≤ 3 * p := by exact_mod_cast hbal
  have hN : (0 : ℝ) < (p : ℝ) * q := by positivity
  have hs : 0 < Real.sqrt ((p : ℝ) * q) := Real.sqrt_pos.mpr hN
  have hsle : (p : ℝ) ≤ Real.sqrt ((p : ℝ) * q) := by
    have : Real.sqrt ((p : ℝ) * p) ≤ Real.sqrt ((p : ℝ) * q) := by
      apply Real.sqrt_le_sqrt
      nlinarith
    rwa [show (p : ℝ) * p = (p : ℝ) ^ 2 by ring, Real.sqrt_sq hp0.le] at this
  have hcount : (successCount H (p * q) : ℝ) ≤ (H.natDegree : ℝ) * (p + q) := by
    have := (Nat.cast_le (α := ℝ)).mpr (successCount_le hp hq hne hH)
    push_cast at this
    linarith
  have hdeg : (0 : ℝ) ≤ (H.natDegree : ℝ) := Nat.cast_nonneg _
  have hsum : (p : ℝ) + q ≤ 4 * Real.sqrt ((p : ℝ) * q) := by nlinarith
  have hsq : Real.sqrt ((p : ℝ) * q) * Real.sqrt ((p : ℝ) * q) = (p : ℝ) * q :=
    Real.mul_self_sqrt hN.le
  rw [div_le_div_iff₀ hN hs]
  calc (successCount H (p * q) : ℝ) * Real.sqrt ((p : ℝ) * q)
      ≤ (H.natDegree : ℝ) * ((p : ℝ) + q) * Real.sqrt ((p : ℝ) * q) := by
        apply mul_le_mul_of_nonneg_right hcount hs.le
    _ ≤ (H.natDegree : ℝ) * (4 * Real.sqrt ((p : ℝ) * q)) * Real.sqrt ((p : ℝ) * q) := by
        have := mul_le_mul_of_nonneg_left hsum hdeg
        nlinarith
    _ = 4 * (H.natDegree : ℝ) * ((p : ℝ) * q) := by rw [mul_assoc, mul_assoc, hsq]; ring

/-- **Expected number of evaluations.** For a balanced semiprime, the expected
number of uniformly random evaluation points needed before the gcd step
succeeds — the reciprocal `N / S` of the success density — is at least
`√N / (4h)`.  This is the theorem quoted in the paper, now with an explicit
constant and no heuristic step. -/
theorem expected_trials_ge (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hle : p ≤ q) (hbal : q ≤ 3 * p) (hH : H.Monic)
    (hS : 0 < successCount H (p * q)) :
    Real.sqrt ((p : ℝ) * q) / (4 * H.natDegree) ≤ ((p : ℝ) * q) / successCount H (p * q) := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp.pos
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have hN : (0 : ℝ) < (p : ℝ) * q := by positivity
  have hs : 0 < Real.sqrt ((p : ℝ) * q) := Real.sqrt_pos.mpr hN
  have hS0 : (0 : ℝ) < (successCount H (p * q) : ℝ) := by exact_mod_cast hS
  rcases Nat.eq_zero_or_pos H.natDegree with hdeg0 | hdegpos
  · -- degenerate case `h = 0`: the left-hand side is `x / 0 = 0`
    rw [hdeg0]
    simp only [Nat.cast_zero, mul_zero, div_zero]
    positivity
  · have hdeg : (0 : ℝ) < (H.natDegree : ℝ) := by exact_mod_cast hdegpos
    have hdens' := successDensity_le_balanced hp hq hne hle hbal hH
    rw [div_le_div_iff₀ hN hs] at hdens'
    rw [div_le_div_iff₀ (by positivity : (0:ℝ) < 4 * (H.natDegree : ℝ)) hS0]
    nlinarith

/-! ## Many discriminants do not break the barrier -/

open scoped Classical in
/-- The set of successful (discriminant polynomial, evaluation point) pairs for a
finite family `F` of class polynomials. -/
noncomputable def successPairs (F : Finset (Polynomial ℤ)) (N : ℕ) : Finset (Polynomial ℤ × ℕ) :=
  (F ×ˢ Finset.range N).filter (fun z => NontrivialDivisor N (evalGcd z.1 (z.2 : ℤ) N))

/-- The successful pairs decompose over the family. -/
theorem successPairs_card_le (F : Finset (Polynomial ℤ)) (N : ℕ) :
    (successPairs F N).card ≤ ∑ H ∈ F, successCount H N := by
  classical
  have hsub : successPairs F N ⊆ F.biUnion (fun H => ({H} : Finset (Polynomial ℤ)) ×ˢ
      successSet H N) := by
    intro z hz
    simp only [successPairs, Finset.mem_filter, Finset.mem_product, Finset.mem_range] at hz
    simp only [Finset.mem_biUnion, Finset.mem_product, Finset.mem_singleton, successSet,
      Finset.mem_filter, Finset.mem_range]
    exact ⟨z.1, hz.1.1, rfl, hz.1.2, hz.2⟩
  calc (successPairs F N).card
      ≤ (F.biUnion (fun H => ({H} : Finset (Polynomial ℤ)) ×ˢ successSet H N)).card :=
        Finset.card_le_card hsub
    _ ≤ ∑ H ∈ F, (({H} : Finset (Polynomial ℤ)) ×ˢ successSet H N).card :=
        Finset.card_biUnion_le
    _ = ∑ H ∈ F, successCount H N := by
        refine Finset.sum_congr rfl (fun H _ => ?_)
        rw [Finset.card_product, Finset.card_singleton, one_mul, successCount]

/-- **The barrier is not beaten by using more discriminants.** For a family `F`
of monic polynomials of degree at most `h`, the density of successful pairs
inside the whole search space `F × [0, N)` is still at most `4h/√N`. -/
theorem multiDiscriminant_successDensity_le_balanced (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) (hle : p ≤ q) (hbal : q ≤ 3 * p) {h : ℕ} {F : Finset (Polynomial ℤ)}
    (hF : ∀ G ∈ F, G.Monic ∧ G.natDegree ≤ h) (hFne : F.Nonempty) :
    ((successPairs F (p * q)).card : ℝ) / (F.card * (p * q))
      ≤ 4 * h / Real.sqrt ((p : ℝ) * q) := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp.pos
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have hN : (0 : ℝ) < (p : ℝ) * q := by positivity
  have hs : 0 < Real.sqrt ((p : ℝ) * q) := Real.sqrt_pos.mpr hN
  have hFcard : (0 : ℝ) < F.card := by exact_mod_cast Finset.card_pos.mpr hFne
  -- each individual polynomial obeys the single-discriminant bound
  have hone : ∀ G ∈ F, (successCount G (p * q) : ℝ)
      ≤ 4 * h / Real.sqrt ((p : ℝ) * q) * ((p : ℝ) * q) := by
    intro G hG
    obtain ⟨hGm, hGd⟩ := hF G hG
    have hdens := successDensity_le_balanced hp hq hne hle hbal hGm
    have hstep : (successCount G (p * q) : ℝ)
        ≤ 4 * G.natDegree / Real.sqrt ((p : ℝ) * q) * ((p : ℝ) * q) := by
      rw [div_le_iff₀ hN] at hdens
      exact hdens
    have hmono : 4 * (G.natDegree : ℝ) / Real.sqrt ((p : ℝ) * q)
        ≤ 4 * (h : ℝ) / Real.sqrt ((p : ℝ) * q) := by
      have hle' : (G.natDegree : ℝ) ≤ (h : ℝ) := by exact_mod_cast hGd
      gcongr
    nlinarith [mul_le_mul_of_nonneg_right hmono hN.le]
  have hsum : ((successPairs F (p * q)).card : ℝ)
      ≤ F.card * (4 * h / Real.sqrt ((p : ℝ) * q) * ((p : ℝ) * q)) := by
    have h1 : ((successPairs F (p * q)).card : ℝ) ≤ ∑ G ∈ F, (successCount G (p * q) : ℝ) := by
      have := (Nat.cast_le (α := ℝ)).mpr (successPairs_card_le F (p * q))
      push_cast at this
      exact this
    have h2 : ∑ G ∈ F, (successCount G (p * q) : ℝ)
        ≤ ∑ _G ∈ F, (4 * h / Real.sqrt ((p : ℝ) * q) * ((p : ℝ) * q)) :=
      Finset.sum_le_sum hone
    simp only [Finset.sum_const, nsmul_eq_mul] at h2
    linarith
  rw [div_le_iff₀ (by positivity)]
  calc ((successPairs F (p * q)).card : ℝ)
      ≤ F.card * (4 * h / Real.sqrt ((p : ℝ) * q) * ((p : ℝ) * q)) := hsum
    _ = 4 * h / Real.sqrt ((p : ℝ) * q) * (F.card * ((p : ℝ) * q)) := by ring

end SingularModuli