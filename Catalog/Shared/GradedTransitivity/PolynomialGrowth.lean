import Shared.GradedTransitivity.FiniteDifference

/-!
# Eventually polynomial sequences have denominator `(1-q)^{r+1}`

The discrete derivative `p ↦ p(X+1) - p` lowers the degree of a polynomial.
Iterating it `r+1` times therefore annihilates every polynomial of degree `≤ r`,
and combined with `Shared.GradedTransitivity.FiniteDifference` this shows that a
sequence which is *eventually* given by a polynomial of degree `≤ r` has
generating function with denominator `(1-q)^{r+1}`.

## Main results

* `pdiff_natDegree_le` : the discrete derivative drops the degree.
* `sdiff_iter_eval_eq_zero` : `Δ^{r+1}` kills degree `≤ r` polynomial sequences.
* `exists_poly_of_eventually_polynomial` : the rationality statement.
-/

namespace GradedTransitivity

open Polynomial

/-- The *discrete derivative* of a polynomial, `(Δp)(X) = p(X+1) - p(X)`. -/
noncomputable def pdiff (p : ℚ[X]) : ℚ[X] := p.comp (X + C 1) - p

@[simp] lemma pdiff_eval (p : ℚ[X]) (x : ℚ) : (pdiff p).eval x = p.eval (x + 1) - p.eval x := by
  simp [pdiff, Polynomial.eval_comp]

/-- The discrete derivative strictly lowers the degree: if `deg p ≤ d+1` then
`deg (Δp) ≤ d`. -/
theorem pdiff_natDegree_le {p : ℚ[X]} {d : ℕ} (hp : p.natDegree ≤ d + 1) :
    (pdiff p).natDegree ≤ d := by
  by_cases h0 : p.natDegree = 0
  · have : p = C (p.coeff 0) := Polynomial.eq_C_of_natDegree_eq_zero h0
    rw [pdiff, this]
    simp
  · have hpne : p ≠ 0 := fun h => h0 (by simp [h])
    have hcomp : (p.comp (X + C 1)).natDegree = p.natDegree := by
      rw [Polynomial.natDegree_comp, Polynomial.natDegree_X_add_C, mul_one]
    have hm : (X + C (1 : ℚ)).leadingCoeff = 1 := Polynomial.monic_X_add_C 1
    have hlead : (p.comp (X + C (1 : ℚ))).leadingCoeff = p.leadingCoeff := by
      rw [Polynomial.leadingCoeff_comp (by rw [Polynomial.natDegree_X_add_C]; norm_num), hm,
        one_pow, mul_one]
    have hcne : p.comp (X + C (1 : ℚ)) ≠ 0 := by
      intro h
      rw [h] at hlead
      simp only [Polynomial.leadingCoeff_zero] at hlead
      exact hpne (Polynomial.leadingCoeff_eq_zero.1 hlead.symm)
    have hdeg : (p.comp (X + C (1 : ℚ))).degree = p.degree := by
      rw [Polynomial.degree_eq_natDegree hcne, Polynomial.degree_eq_natDegree hpne, hcomp]
    by_cases hz : pdiff p = 0
    · simp [hz]
    · have hlt : (pdiff p).degree < (p.comp (X + C (1 : ℚ))).degree :=
        Polynomial.degree_sub_lt hdeg hcne hlead
      have : (pdiff p).natDegree < (p.comp (X + C (1 : ℚ))).natDegree :=
        Polynomial.natDegree_lt_natDegree hz hlt
      omega

/-- The sequence-level forward difference of a polynomial sequence is the
polynomial sequence of the discrete derivative. -/
theorem sdiff_evalSeq (p : ℚ[X]) :
    sdiff (fun n : ℕ => p.eval (n : ℚ)) = fun n : ℕ => (pdiff p).eval (n : ℚ) := by
  funext n
  simp [sdiff, pdiff_eval]

/-- `Δ^{d+1}` annihilates every polynomial sequence of degree `≤ d`. -/
theorem sdiff_iter_eval_eq_zero :
    ∀ (d : ℕ) (p : ℚ[X]), p.natDegree ≤ d →
      sdiff^[d + 1] (fun n : ℕ => p.eval (n : ℚ)) = fun _ => 0 := by
  intro d
  induction d with
  | zero =>
      intro p hp
      obtain ⟨c, rfl⟩ : ∃ c, p = C c :=
        ⟨p.coeff 0, Polynomial.eq_C_of_natDegree_eq_zero (Nat.le_zero.1 hp)⟩
      funext n
      simp [sdiff]
  | succ d ih =>
      intro p hp
      have hd : (pdiff p).natDegree ≤ d := pdiff_natDegree_le hp
      have : sdiff^[d + 1 + 1] (fun n : ℕ => p.eval (n : ℚ))
          = sdiff^[d + 1] (sdiff (fun n : ℕ => p.eval (n : ℚ))) :=
        Function.iterate_succ_apply _ _ _
      rw [this, sdiff_evalSeq]
      exact ih _ hd

/-- Forward differences only depend on the tail of a sequence. -/
theorem sdiff_iter_congr :
    ∀ (k : ℕ) (a b : ℕ → ℚ) (N : ℕ), (∀ n ≥ N, a n = b n) →
      ∀ n ≥ N, sdiff^[k] a n = sdiff^[k] b n := by
  intro k
  induction k with
  | zero => intro a b N h n hn; simpa using h n hn
  | succ k ih =>
      intro a b N h n hn
      rw [Function.iterate_succ_apply, Function.iterate_succ_apply]
      refine ih (sdiff a) (sdiff b) N (fun m hm => ?_) n hn
      simp only [sdiff, h m hm, h (m + 1) (by omega)]

/-- **Eventually polynomial sequences are rational with denominator
`(1-q)^{r+1}`.** If `a n = p(n)` for all large `n` and `deg p ≤ r`, then
`(1-q)^{r+1} ∑ a n qⁿ` is a polynomial. -/
theorem exists_poly_of_eventually_polynomial {a : ℕ → ℚ} {r N : ℕ} {p : ℚ[X]}
    (hdeg : p.natDegree ≤ r) (hev : ∀ n ≥ N, a n = p.eval (n : ℚ)) :
    ∃ P : ℚ[X], (1 - PowerSeries.X) ^ (r + 1) * gen a = (P : PowerSeries ℚ) := by
  refine exists_poly_pow_mul_gen (r + 1) a ⟨N, fun n hn => ?_⟩
  have hc := sdiff_iter_congr (r + 1) a (fun m : ℕ => p.eval (m : ℚ)) N hev n hn
  rw [hc, sdiff_iter_eval_eq_zero r p hdeg]

/-- The converse: denominator `(1-q)^{r+1}` forces `Δ^{r+1} a` to vanish
eventually, i.e. `a` satisfies a linear recurrence of Pascal type. -/
theorem eventually_sdiff_iter_zero_of_poly {a : ℕ → ℚ} {r : ℕ} {P : ℚ[X]}
    (h : (1 - PowerSeries.X) ^ (r + 1) * gen a = (P : PowerSeries ℚ)) :
    EventuallyZero (sdiff^[r + 1] a) :=
  eventuallyZero_sdiff_iter_of_poly (r + 1) a P h

end GradedTransitivity