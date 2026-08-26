/-
# U065 — Cycle 3: the mixture excess needs no primality, and tight two-sided bounds on
the per-prime share

Cycles 1–2 worked with odd primes, where the root-count distribution is the explicit
two-point mixture `{0, 2}` (plus the single fixed point `a = 0`).  This cycle isolates
what is really responsible for the effect.

* `sum_rootCountM` — for **every** modulus `m`, the number of solutions of `j² ≡ N`
  averages to exactly `1` over `N`: the divisibility rate of `v = j² − N` at `m` always
  has the naive `1/m` mean.  This is pure fibre counting; primality plays no role.
* `mixture_convex_excess_general` — consequently, for every convex functional `G`,
  `m · G 1 ≤ ∑_N G(#{j : m ∣ j² − N})`.  Mean preservation plus convexity is the entire
  mechanism; the arithmetic of quadratic residues only fixes the *size* of the effect.
* `exists_rootCountM_eq_zero` — for `m ≥ 3` the rate is genuinely non-constant: some
  target has no square roots at all, because `x ↦ x²` identifies `x` with `−x`.  So the
  mixture is never degenerate and the excess is never vacuous.
* `logExcess_sandwich` — a non-asymptotic two-sided bound
  `Y/(1+Y) ≤ log (excessRatio q c) ≤ Y` with `Y = (1 − 1/q)(c−1)²/(2c)`, pinning the
  per-prime hump share to the variance term up to a factor `1 + Y`.
-/
import Computation.U065NoSingleCarrier

namespace U065

open Finset

section GeneralModulus

variable {m : ℕ} [NeZero m]

/-- Root count for an arbitrary modulus: the number of residues `j` mod `m` with
`m ∣ j² − a`. -/
noncomputable def rootCountM {m : ℕ} [NeZero m] (a : ZMod m) : ℕ :=
  (Finset.univ.filter (fun x : ZMod m => x ^ 2 = a)).card

/-- For a prime modulus this is the root count of `U065QRMixture`. -/
theorem rootCountM_eq_rootCount {p : ℕ} [Fact p.Prime] (a : ZMod p) :
    rootCountM a = rootCount p a := rfl

/-- **Mean preservation for every modulus.**  Summing the number of solutions of
`j² ≡ N (mod m)` over all targets `N` gives exactly `m`. -/
theorem sum_rootCountM : ∑ a : ZMod m, rootCountM a = m := by
  classical
  have hcard : (Finset.univ : Finset (ZMod m)).card = m := ZMod.card m
  have h := Finset.card_eq_sum_card_fiberwise
    (f := fun x : ZMod m => x ^ 2) (s := (Finset.univ : Finset (ZMod m)))
    (t := (Finset.univ : Finset (ZMod m))) (fun x _ => Finset.mem_univ _)
  rw [hcard] at h
  simpa [rootCountM] using h.symm

/-- **The general mechanism.**  For any modulus and any convex functional of the
divisibility rate, the mixture average is at least the naive baseline value. -/
theorem mixture_convex_excess_general {G : ℝ → ℝ} (hG : ConvexOn ℝ Set.univ G) :
    (m : ℝ) * G 1 ≤ ∑ a : ZMod m, G ((rootCountM a : ℝ)) := by
  classical
  have hm0 : (0 : ℝ) < m := by
    have : 0 < m := Nat.pos_of_ne_zero (NeZero.ne m)
    exact_mod_cast this
  have hcard : (Finset.univ : Finset (ZMod m)).card = m := ZMod.card m
  have hw : ∀ a ∈ (Finset.univ : Finset (ZMod m)), (0 : ℝ) ≤ 1 / (m : ℝ) := by
    intro a _; positivity
  have hw1 : ∑ _a : ZMod m, (1 / (m : ℝ)) = 1 := by
    rw [Finset.sum_const, hcard, nsmul_eq_mul]
    field_simp
  have hmean : ∑ a : ZMod m, (1 / (m : ℝ)) • ((rootCountM a : ℝ)) = 1 := by
    have hsum : ∑ a : ZMod m, ((rootCountM a : ℝ)) = (m : ℝ) := by
      have := sum_rootCountM (m := m)
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) this
    simp only [smul_eq_mul, ← Finset.mul_sum, hsum]
    field_simp
  have hJ := hG.map_sum_le (t := (Finset.univ : Finset (ZMod m)))
    (w := fun _ => 1 / (m : ℝ)) (p := fun a => ((rootCountM a : ℝ))) hw hw1
    (fun a _ => Set.mem_univ _)
  rw [hmean] at hJ
  simp only [smul_eq_mul, ← Finset.mul_sum] at hJ
  calc (m : ℝ) * G 1 ≤ (m : ℝ) * ((1 / (m : ℝ)) * ∑ a : ZMod m, G ((rootCountM a : ℝ))) := by
        exact mul_le_mul_of_nonneg_left hJ hm0.le
    _ = ∑ a : ZMod m, G ((rootCountM a : ℝ)) := by field_simp

/-- **The rate is never constant for `m ≥ 3`.**  Since `x ↦ x²` identifies `x` with
`−x`, the squaring map is not injective, hence not surjective, so some target has no
square roots: the mixture always has a genuine zero stratum. -/
theorem exists_rootCountM_eq_zero (hm : 3 ≤ m) : ∃ a : ZMod m, rootCountM a = 0 := by
  classical
  haveI : Fact (2 < m) := ⟨by omega⟩
  have hne : (1 : ZMod m) ≠ -1 := fun h => ZMod.neg_one_ne_one h.symm
  have hnotinj : ¬ Function.Injective (fun x : ZMod m => x ^ 2) := by
    intro hinj
    exact hne (hinj (by simp))
  have hnotsurj : ¬ Function.Surjective (fun x : ZMod m => x ^ 2) := fun hsurj =>
    hnotinj (Finite.injective_iff_surjective.mpr hsurj)
  simp only [Function.Surjective, not_forall] at hnotsurj
  obtain ⟨a, ha⟩ := hnotsurj
  push_neg at ha
  refine ⟨a, ?_⟩
  simp only [rootCountM, Finset.card_eq_zero]
  ext x
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.notMem_empty, iff_false]
  exact fun hx => ha x hx

end GeneralModulus

section Sandwich

variable {q : ℕ} [Fact q.Prime]

/-- **Two-sided bound on a prime's hump share.**  With `Y = (1 − 1/q)(c−1)²/(2c)` the
per-prime log-excess satisfies `Y/(1+Y) ≤ logExcess q c ≤ Y`: the share is the variance
term up to the factor `1 + Y`, so the amplitude is a genuinely second-order quantity. -/
theorem logExcess_sandwich (hq : q ≠ 2) {c : ℝ} (hc : 0 < c) :
    (1 - 1 / (q : ℝ)) * ((c - 1) ^ 2 / (2 * c)) /
        (1 + (1 - 1 / (q : ℝ)) * ((c - 1) ^ 2 / (2 * c)))
      ≤ logExcess q c ∧
    logExcess q c ≤ (1 - 1 / (q : ℝ)) * ((c - 1) ^ 2 / (2 * c)) := by
  have hq3 := three_le_cast hq
  have hq0 : (0 : ℝ) < q := by exact_mod_cast (Fact.out (p := q.Prime)).pos
  have hinv : 1 / (q : ℝ) ≤ 1 / 3 := one_div_le_one_div_of_le (by norm_num) hq3
  have hfacnn : 0 ≤ 1 - 1 / (q : ℝ) := by linarith
  have hX : 0 ≤ (c - 1) ^ 2 / (2 * c) := by positivity
  set Y := (1 - 1 / (q : ℝ)) * ((c - 1) ^ 2 / (2 * c)) with hY
  have hYnn : 0 ≤ Y := mul_nonneg hfacnn hX
  have hpos : (0 : ℝ) < 1 + Y := by linarith
  have hval : logExcess q c = Real.log (1 + Y) := by
    rw [logExcess, excessRatio_eq_shape hq hc]
  constructor
  · -- `log t ≥ 1 - 1/t` applied to `t = 1 + Y`
    have h := Real.log_le_sub_one_of_pos (x := 1 / (1 + Y)) (by positivity)
    have hlog : Real.log (1 / (1 + Y)) = -Real.log (1 + Y) := by
      rw [one_div, Real.log_inv]
    rw [hlog] at h
    have hdiv : Y / (1 + Y) = 1 - 1 / (1 + Y) := by
      field_simp
      ring
    rw [hval, hdiv]
    linarith
  · have h := Real.log_le_sub_one_of_pos hpos
    rw [hval]
    linarith

end Sandwich

end U065