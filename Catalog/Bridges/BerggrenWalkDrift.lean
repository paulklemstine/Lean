import Bridges.BerggrenHarmonicMeasure
import Novelty.HyperbolicBerggrenSilverGrowth

/-!
# The hyperbolic drift of the Berggren random walk and the silver ratio

This file connects the probabilistic side of the Berggren tree (the harmonic measure of
`Catalog.Bridges.BerggrenHarmonicMeasure`) with its deterministic metric geometry as
established in `Catalog.Novelty.HyperbolicBerggrenSilverGrowth`, where the *silver* growth
exponent `log(1+√2)` of the tree was proved to be the exact upper envelope of the hyperbolic
distance per unit of depth, the frequency of the middle move `M` giving the matching lower
bound `(#M(w)+1) log 2`.

Here we average those two deterministic bounds over the random walk that appends the moves
`L, M, R` with probabilities `(p₁, p₂, p₃)`.  The expectation over the `3ⁿ` words of length
`n` is implemented by the recursive functional `expWord` (prepending one random letter at a
time); by construction the weight of a word is the product of the probabilities of its
letters, i.e. exactly the harmonic (Bernoulli) mass of the corresponding depth-`n` cylinder
computed in `bernoulli_cyl`.

## Main results

* `expWord_const`, `expWord_add_const`, `expWord_mono` : `expWord` is a probability average.
* `expWord_countM` : the expected number of middle moves in a random word of length `n` is
  exactly `n p₂`.
* `expected_drift_lower`, `expected_drift_upper` : the **drift sandwich**
  `(n p₂ + 1) log 2 ≤ 𝔼[d(i, zₙ)] ≤ (n+1) log(1+√2) + log 2`.
* `drift_rate_sandwich` : dividing by `n`, the hyperbolic speed of the Berggren random walk
  lies between `p₂ log 2` and `log(1+√2) + (log(1+√2) + log 2)/n`; in particular the silver
  exponent is an upper bound for the speed of *every* Berggren walk, and walks with `p₂`
  close to `1` have positive speed.
* `speed_pos_of_middle_prob` : any walk with `p₂ > 0` escapes to the boundary at a definite
  linear rate — the harmonic measure is genuinely supported on the boundary at infinity.
-/

namespace BerggrenHarmonic

open HyperbolicBerggrenGeodesics Finset

/-- The dictionary between the alphabet `Fin 3` and the catalog's Berggren moves. -/
def moveOf : Letter → Move
  | 0 => Move.L
  | 1 => Move.M
  | _ => Move.R

@[simp] lemma moveOf_zero : moveOf 0 = Move.L := rfl
@[simp] lemma moveOf_one : moveOf 1 = Move.M := rfl
@[simp] lemma moveOf_two : moveOf 2 = Move.R := rfl

/-- The hyperbolic distance from the base point to the node of the Berggren tree reached by
the word `w`. -/
noncomputable def hdist (w : List Move) : ℝ :=
  dist (hpoint (run w).1 (run w).2
    (lt_trans (run_isSeed w).pos (run_isSeed w).lt)) UpperHalfPlane.I

/-- The expectation of a functional of the random Berggren word of length `n`: a letter is
prepended with probability `pₐ` at each of the `n` steps.  The resulting weight of a word is
the product of the probabilities of its letters, i.e. the harmonic measure of the
corresponding cylinder. -/
noncomputable def expWord (P : ProbVec) : ℕ → (List Move → ℝ) → ℝ
  | 0, F => F []
  | (n + 1), F => ∑ a : Letter, P.p a * expWord P n (fun w => F (moveOf a :: w))

@[simp] lemma expWord_zero (P : ProbVec) (F : List Move → ℝ) : expWord P 0 F = F [] := rfl

lemma expWord_succ (P : ProbVec) (n : ℕ) (F : List Move → ℝ) :
    expWord P (n + 1) F = ∑ a : Letter, P.p a * expWord P n (fun w => F (moveOf a :: w)) := rfl

/-- `expWord` is an average: constants are preserved. -/
@[simp] theorem expWord_const (P : ProbVec) (n : ℕ) (c : ℝ) :
    expWord P n (fun _ => c) = c := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rw [expWord_succ]
      simp only [ih, ← Finset.sum_mul, P.sum_eq, one_mul]

theorem expWord_add_const (P : ProbVec) (n : ℕ) (F : List Move → ℝ) (c : ℝ) :
    expWord P n (fun w => F w + c) = expWord P n F + c := by
  induction n generalizing F with
  | zero => rfl
  | succ n ih =>
      rw [expWord_succ, expWord_succ]
      have hterm : ∀ a : Letter,
          P.p a * expWord P n (fun w => F (moveOf a :: w) + c)
            = P.p a * expWord P n (fun w => F (moveOf a :: w)) + P.p a * c := by
        intro a
        rw [ih (fun w => F (moveOf a :: w))]
        ring
      rw [Finset.sum_congr rfl (fun a _ => hterm a), Finset.sum_add_distrib, ← Finset.sum_mul,
        P.sum_eq, one_mul]

/-- Monotonicity of the average, on words of the correct length. -/
theorem expWord_mono (P : ProbVec) :
    ∀ (n : ℕ) (F G : List Move → ℝ), (∀ w : List Move, w.length = n → F w ≤ G w) →
      expWord P n F ≤ expWord P n G := by
  intro n
  induction n with
  | zero => intro F G h; exact h [] rfl
  | succ n ih =>
      intro F G h
      rw [expWord_succ, expWord_succ]
      refine Finset.sum_le_sum fun a _ => ?_
      refine mul_le_mul_of_nonneg_left (ih _ _ fun w hw => h (moveOf a :: w) ?_) (P.pos a).le
      simp [hw]

/-- **The expected number of middle moves.**  In a random Berggren word of length `n` the
mean number of `M` moves is exactly `n p₂`. -/
theorem expWord_countM (P : ProbVec) (n : ℕ) :
    expWord P n (fun w => (countM w : ℝ)) = n * P.p 1 := by
  induction n with
  | zero => simp [countM]
  | succ n ih =>
      rw [expWord_succ]
      have hterm : ∀ a : Letter,
          P.p a * expWord P n (fun w => ((countM (moveOf a :: w) : ℕ) : ℝ))
            = P.p a * ((n : ℝ) * P.p 1) + (if a = 1 then P.p a else 0) := by
        intro a
        have hcount : ∀ w : List Move,
            ((countM (moveOf a :: w) : ℕ) : ℝ)
              = ((countM w : ℕ) : ℝ) + (if a = 1 then 1 else 0) := by
          intro w
          fin_cases a <;> simp [countM, moveOf]
        rw [show (fun w : List Move => ((countM (moveOf a :: w) : ℕ) : ℝ))
              = (fun w : List Move => ((countM w : ℕ) : ℝ) + (if a = 1 then 1 else 0)) from
            funext hcount,
          expWord_add_const, ih]
        by_cases ha : a = 1
        · simp [ha]; ring
        · simp [ha]
      rw [Finset.sum_congr rfl (fun a _ => hterm a), Finset.sum_add_distrib, ← Finset.sum_mul,
        P.sum_eq, one_mul, Finset.sum_ite_eq' Finset.univ (1 : Letter)]
      simp
      ring

/-! ## The drift sandwich -/

/-- **Lower bound for the expected drift.**  Averaging the catalog bound
`(#M(w)+1) log 2 ≤ d` over the random walk. -/
theorem expected_drift_lower (P : ProbVec) (n : ℕ) :
    ((n : ℝ) * P.p 1 + 1) * Real.log 2 ≤ expWord P n hdist := by
  have hmono := expWord_mono P n (fun w => ((countM w : ℝ) + 1) * Real.log 2) hdist
    (fun w _ => (berggren_word_two_sided w).1)
  have hlin : expWord P n (fun w => ((countM w : ℝ) + 1) * Real.log 2)
      = ((n : ℝ) * P.p 1 + 1) * Real.log 2 := by
    have hfun : (fun w : List Move => ((countM w : ℝ) + 1) * Real.log 2)
        = (fun w : List Move => Real.log 2 * (countM w : ℝ) + Real.log 2) := by
      funext w; ring
    rw [hfun, expWord_add_const]
    have hsmul : ∀ (c : ℝ) (m : ℕ) (F : List Move → ℝ),
        expWord P m (fun w => c * F w) = c * expWord P m F := by
      intro c m
      induction m with
      | zero => intro F; rfl
      | succ m ih =>
          intro F
          rw [expWord_succ, expWord_succ, Finset.mul_sum]
          exact Finset.sum_congr rfl fun a _ => by rw [ih (fun w => F (moveOf a :: w))]; ring
    rw [hsmul, expWord_countM]
    ring
  linarith [hlin ▸ hmono]

/-- **Upper bound for the expected drift.**  Averaging the catalog's sharp silver envelope
`d ≤ (|w|+1) log(1+√2) + log 2`. -/
theorem expected_drift_upper (P : ProbVec) (n : ℕ) :
    expWord P n hdist ≤ ((n : ℝ) + 1) * Real.log silver + Real.log 2 := by
  have hmono := expWord_mono P n hdist
    (fun _ => ((n : ℝ) + 1) * Real.log silver + Real.log 2) (fun w hw => by
      have := (berggren_word_two_sided w).2
      rw [hw] at this
      exact this)
  simpa using hmono

/-- **The speed of the Berggren random walk is sandwiched by the silver exponent.** -/
theorem drift_rate_sandwich (P : ProbVec) (n : ℕ) (hn : 0 < n) :
    P.p 1 * Real.log 2 ≤ expWord P n hdist / n ∧
      expWord P n hdist / n ≤ Real.log silver + (Real.log silver + Real.log 2) / n := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  constructor
  · rw [le_div_iff₀ hnR]
    have h := expected_drift_lower P n
    have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    nlinarith [h]
  · rw [div_le_iff₀ hnR]
    have h := expected_drift_upper P n
    have : (Real.log silver + (Real.log silver + Real.log 2) / n) * n
        = ((n : ℝ) + 1) * Real.log silver + Real.log 2 := by
      field_simp
      ring
    rw [this]
    exact h

/-- **Positive escape speed.**  A Berggren walk that uses the middle move with positive
probability drifts to the boundary at a linear rate, bounded below by `p₂ log 2` and above by
the silver exponent `log(1+√2)`. -/
theorem speed_pos_of_middle_prob (P : ProbVec) (n : ℕ) (hn : 0 < n) :
    0 < expWord P n hdist / n := by
  have h := (drift_rate_sandwich P n hn).1
  have hlog2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  nlinarith [P.pos 1]

end BerggrenHarmonic