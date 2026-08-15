import Cryptography.SingularModuli.SqrtBarrier

/-!
# Singular Moduli Factoring, Step 6: the `√N` scaling is two-sided and sharp

`SqrtBarrier.lean` gives the *upper* bound `S ≤ h(p+q)` on the number of useful
evaluation points, i.e. a *lower* bound `√N/(4h)` on the expected number of
evaluations.  A lower bound alone would be compatible with the method never
working at all, so this file proves the complementary facts:

* `successCount_add_two_sq_eq` — **the bound `h(p+q)` is sharp**: when `H_D`
  splits completely modulo both primes (`r_p = r_q = h`, the generic
  CM-friendly case) the success count is exactly `h(p+q) - 2h²`;
* `successCount_eq_mul_of_no_root_right` — when `H_D` has roots mod `p` but none
  mod `q`, the success count is exactly `r_p · q`;
* `expected_trials_le` — in that case the expected number of evaluations is at
  most `p ≤ √N`: the method *does* work, in `Θ(√N)` time;
* `sqrt_scaling_two_sided` — combining the two: `√N/(4h) ≤ N/S ≤ √N`.  The
  singular moduli method is neither better nor worse than `√N` up to the factor
  `4h`;
* `successDensity_comp_le` — **reparametrisation does not help**: substituting
  any monic polynomial `g` for the evaluation variable multiplies the degree by
  `deg g`, so it degrades the bound by exactly the factor by which the
  evaluation cost grows.

The moral: the `√N` behaviour is not an artifact of a lower-bound technique; it
is the true order of the method.
-/

namespace SingularModuli

open Polynomial Finset FactoringBarriers

variable {p q : ℕ} {H : Polynomial ℤ}

/-! ## Sharpness of the counting bound -/

/-- **Sharpness.** If `H` splits with `h` distinct roots modulo each of the two
primes (the generic case for a Hilbert class polynomial at a prime represented by
a form of discriminant `D`), the success count is exactly `h(p+q) - 2h²`.
Stated without truncated subtraction: `S + 2h² = h(p+q)`. -/
theorem successCount_add_two_sq_eq (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (H : Polynomial ℤ) {h : ℕ}
    (hrp : haveI : NeZero p := ⟨hp.pos.ne'⟩; rootCount H p = h)
    (hrq : haveI : NeZero q := ⟨hq.pos.ne'⟩; rootCount H q = h)
    (hhp : h ≤ p) (hhq : h ≤ q) :
    successCount H (p * q) + 2 * h ^ 2 = h * (p + q) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  obtain ⟨a, rfl⟩ := Nat.exists_eq_add_of_le hhp
  obtain ⟨b, rfl⟩ := Nat.exists_eq_add_of_le hhq
  rw [successCount_eq hp hq hne H, hrp, hrq]
  simp only [Nat.add_sub_cancel_left]
  ring

/-- If `H` has no root modulo `q`, the successful evaluation points are exactly
those that are roots modulo `p`: `S = r_p · q`. -/
theorem successCount_eq_mul_of_no_root_right (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (H : Polynomial ℤ) (hrq : haveI : NeZero q := ⟨hq.pos.ne'⟩; rootCount H q = 0) :
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    successCount H (p * q) = rootCount H p * q := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  rw [successCount_eq hp hq hne H, hrq]
  simp

/-- **The method really works.** If `H` has at least one root mod `p` and none
mod `q`, at least `q` of the `pq` evaluation points succeed. -/
theorem successCount_ge_of_root (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (H : Polynomial ℤ) (hrp : haveI : NeZero p := ⟨hp.pos.ne'⟩; 1 ≤ rootCount H p)
    (hrq : haveI : NeZero q := ⟨hq.pos.ne'⟩; rootCount H q = 0) :
    q ≤ successCount H (p * q) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  rw [successCount_eq_mul_of_no_root_right hp hq hne H hrq]
  exact Nat.le_mul_of_pos_left q hrp

/-- **Matching upper bound on the expected number of evaluations.** Under the
same hypothesis, the expected number of uniform evaluations `N / S` is at most
`p`, hence at most `√N` for `p ≤ q`. -/
theorem expected_trials_le (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (H : Polynomial ℤ) (hrp : haveI : NeZero p := ⟨hp.pos.ne'⟩; 1 ≤ rootCount H p)
    (hrq : haveI : NeZero q := ⟨hq.pos.ne'⟩; rootCount H q = 0) (hle : p ≤ q) :
    ((p : ℝ) * q) / successCount H (p * q) ≤ Real.sqrt ((p : ℝ) * q) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp.pos
  have hSq : (q : ℝ) ≤ (successCount H (p * q) : ℝ) := by
    exact_mod_cast successCount_ge_of_root hp hq hne H hrp hrq
  have hS0 : (0 : ℝ) < (successCount H (p * q) : ℝ) := lt_of_lt_of_le hq0 hSq
  have hstep : ((p : ℝ) * q) / successCount H (p * q) ≤ (p : ℝ) := by
    rw [div_le_iff₀ hS0]
    nlinarith
  have hsqrt : (p : ℝ) ≤ Real.sqrt ((p : ℝ) * q) := by
    have hple : (p : ℝ) ≤ q := by exact_mod_cast hle
    have : Real.sqrt ((p : ℝ) * p) ≤ Real.sqrt ((p : ℝ) * q) :=
      Real.sqrt_le_sqrt (by nlinarith)
    rwa [show (p : ℝ) * p = (p : ℝ) ^ 2 by ring, Real.sqrt_sq hp0.le] at this
  linarith

/-- **Two-sided `√N` scaling.** For a balanced semiprime and a monic `H` of
degree `h` with roots mod `p` but none mod `q`, the expected number of
evaluations `N/S` satisfies

  `√N / (4h) ≤ N / S ≤ √N`.

So the method is genuinely a `√N` method: the lower bound of `SqrtBarrier.lean`
is attained up to the factor `4h`, and no polynomial-time behaviour is hiding in
the constants. -/
theorem sqrt_scaling_two_sided (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hle : p ≤ q) (hbal : q ≤ 3 * p) (hH : H.Monic)
    (hrp : haveI : NeZero p := ⟨hp.pos.ne'⟩; 1 ≤ rootCount H p)
    (hrq : haveI : NeZero q := ⟨hq.pos.ne'⟩; rootCount H q = 0) :
    Real.sqrt ((p : ℝ) * q) / (4 * H.natDegree) ≤ ((p : ℝ) * q) / successCount H (p * q) ∧
      ((p : ℝ) * q) / successCount H (p * q) ≤ Real.sqrt ((p : ℝ) * q) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  have hS : 0 < successCount H (p * q) :=
    lt_of_lt_of_le hq.pos (successCount_ge_of_root hp hq hne H hrp hrq)
  exact ⟨expected_trials_ge hp hq hne hle hbal hH hS,
    expected_trials_le hp hq hne H hrp hrq hle⟩

/-! ## The class number is not a free parameter -/

/-- A monic polynomial of degree `0` is the constant `1`, which has no roots. -/
theorem rootCount_eq_zero_of_natDegree_zero {m : ℕ} (hm : m.Prime) {H : Polynomial ℤ}
    (hH : H.Monic) (hdeg : H.natDegree = 0) :
    haveI : NeZero m := ⟨hm.pos.ne'⟩
    rootCount H m = 0 := by
  haveI : NeZero m := ⟨hm.pos.ne'⟩
  haveI : Fact m.Prime := ⟨hm⟩
  have hone : H = 1 := hH.natDegree_eq_zero.mp hdeg
  have hempty : rootFinset H m = ∅ := by
    rw [rootFinset]
    refine Finset.filter_eq_empty_iff.mpr (fun {y} _ => ?_)
    rw [redMod, hone]
    simp
  rw [rootCount, hempty, Finset.card_empty]

/-- If the polynomial is the constant `1` there are no useful evaluation points. -/
theorem successCount_eq_zero_of_natDegree_zero (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hH : H.Monic) (hdeg : H.natDegree = 0) : successCount H (p * q) = 0 := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  rw [successCount_eq hp hq hne H, rootCount_eq_zero_of_natDegree_zero hp hH hdeg,
    rootCount_eq_zero_of_natDegree_zero hq hH hdeg]
  simp

/-- **Raising the class number buys nothing.** Evaluating a degree-`h` polynomial
costs at least `h` ring operations (Horner), so the *total* expected arithmetic
work of the method is at least

  `h · (N / S) ≥ h · √N/(4h) = √N/4`,

independently of `h`.  The apparent `1/h` speed-up in the number of evaluations
is exactly cancelled by the cost of one evaluation: there is no choice of
discriminant family that turns the method into a subexponential one. -/
theorem total_work_ge (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (hle : p ≤ q) (hbal : q ≤ 3 * p) (hH : H.Monic)
    (hS : 0 < successCount H (p * q)) :
    Real.sqrt ((p : ℝ) * q) / 4
      ≤ (H.natDegree : ℝ) * (((p : ℝ) * q) / successCount H (p * q)) := by
  rcases Nat.eq_zero_or_pos H.natDegree with hdeg0 | hdegpos
  · exact absurd (successCount_eq_zero_of_natDegree_zero hp hq hne hH hdeg0) (by omega)
  · have hdeg : (0 : ℝ) < (H.natDegree : ℝ) := by exact_mod_cast hdegpos
    have hlow := expected_trials_ge hp hq hne hle hbal hH hS
    have hmul := mul_le_mul_of_nonneg_left hlow hdeg.le
    calc Real.sqrt ((p : ℝ) * q) / 4
        = (H.natDegree : ℝ) * (Real.sqrt ((p : ℝ) * q) / (4 * H.natDegree)) := by
          field_simp
      _ ≤ (H.natDegree : ℝ) * (((p : ℝ) * q) / successCount H (p * q)) := hmul

/-! ## Reparametrising the evaluation point does not help -/

/-- **Composition barrier.** Replacing the evaluation point `j₀` by `g(j₀)` for a
monic polynomial `g` of degree `d ≥ 1` — the natural way to try to "aim" at the
structured set — only produces the bound for degree `h·d`.  Since evaluating
`H ∘ g` costs a factor `d` more, nothing is gained: the density bound degrades
by exactly the factor by which the work grows. -/
theorem successDensity_comp_le (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    {g : Polynomial ℤ} (hH : H.Monic) (hg : g.Monic) (hgd : g.natDegree ≠ 0) :
    (successCount (H.comp g) (p * q) : ℝ) / (p * q)
      ≤ (H.natDegree * g.natDegree : ℕ) * (1 / p + 1 / q) := by
  have hcomp : (H.comp g).Monic := hH.comp hg hgd
  have hdeg : (H.comp g).natDegree = H.natDegree * g.natDegree := natDegree_comp
  have := successDensity_le hp hq hne hcomp
  rwa [hdeg] at this

end SingularModuli