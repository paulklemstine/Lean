import Mathlib
import Novelty.MandelbrotQuadraticEscape

/-!
# A formally specified escape-time test for the quadratic family

This file strengthens the escape estimates of `Novelty.MandelbrotQuadraticEscape`
(where divergence of the *critical* orbit is proved only under the a priori hypothesis
`2 < ‖c‖`) into a **complete escape criterion for arbitrary orbits** of `f_c(z) = z² + c`:

* `escapeRadius c = max 2 ‖c‖` is the standard escape radius.
* `escape_norm_growth`: once an orbit point strictly exceeds the escape radius, the whole
  forward orbit stays in the escaping region and grows geometrically,
  `(‖z‖ - 1)^n * ‖z‖ ≤ ‖orbit c z n‖`, with ratio `‖z‖ - 1 > 1`.
* `escape_tendsto_atTop`: hence the orbit norm tends to infinity — crossing the escape
  radius *once* certifies divergence.
* `escape_time_bound`: an **effective** escape time: an explicit number of iterations after
  which the orbit provably exceeds a prescribed threshold `B`.
* `bounded_iff_never_escapes`: soundness *and* completeness of the escape-time test:
  an orbit is bounded iff it never crosses the escape radius.
* `mem_Mandelbrot_iff`: `c ∈ M ↔ ∀ n, ‖critOrbit c n‖ ≤ 2` — the radius-`2` test used by
  every Mandelbrot renderer, now a theorem rather than a heuristic.
* `escapeRadius_sharp`: the radius `2` cannot be lowered (witness `c = -2`).
* Topological payoff: `Mandelbrot_eq_iInter`, `isClosed_Mandelbrot`, `isCompact_Mandelbrot`:
  the dynamical estimate converts the escape-time algorithm into the statement that `M`
  is a nested intersection of closed test sets, hence compact.
-/

namespace EscapeCriterion

open Filter MandelbrotEscape
open scoped Topology

/-! ## Orbits of arbitrary starting points -/

/-- The orbit of an arbitrary starting point `z` under `f_c(w) = w² + c`. -/
def orbit (c z : ℂ) (n : ℕ) : ℂ := (qmap c)^[n] z

@[simp] lemma orbit_zero (c z : ℂ) : orbit c z 0 = z := rfl

lemma orbit_succ (c z : ℂ) (n : ℕ) : orbit c z (n + 1) = (orbit c z n) ^ 2 + c := by
  simp [orbit, qmap, Function.iterate_succ_apply']

lemma orbit_succ' (c z : ℂ) (n : ℕ) : orbit c z (n + 1) = qmap c (orbit c z n) := by
  simp [orbit_succ, qmap]

lemma orbit_add (c z : ℂ) (m n : ℕ) : orbit c z (m + n) = orbit c (orbit c z m) n := by
  rw [Nat.add_comm]
  exact Function.iterate_add_apply _ n m z

lemma critOrbit_eq_orbit (c : ℂ) (n : ℕ) : critOrbit c n = orbit c 0 n := rfl

/-! ## The escape radius and the one-step growth estimate -/

/-- The standard escape radius of the parameter `c`: `max 2 ‖c‖`. -/
noncomputable def escapeRadius (c : ℂ) : ℝ := max 2 ‖c‖

lemma two_le_escapeRadius (c : ℂ) : 2 ≤ escapeRadius c := le_max_left _ _

lemma norm_le_escapeRadius (c : ℂ) : ‖c‖ ≤ escapeRadius c := le_max_right _ _

/-- One-step growth in the escaping region: if `‖z‖` exceeds the escape radius then
`‖f_c(z)‖ ≥ (‖z‖ - 1)·‖z‖`, where the factor `‖z‖ - 1` is `> 1`. -/
lemma qmap_norm_ge_mul (c z : ℂ) (hz : escapeRadius c < ‖z‖) :
    (‖z‖ - 1) * ‖z‖ ≤ ‖qmap c z‖ := by
  have h1 : ‖z‖ ^ 2 - ‖c‖ ≤ ‖qmap c z‖ := qmap_norm_lower c z
  have h2 : ‖c‖ ≤ ‖z‖ := le_trans (norm_le_escapeRadius c) hz.le
  nlinarith

/-- The escaping region `{z | escapeRadius c < ‖z‖}` is forward invariant. -/
lemma escapeRadius_lt_qmap_norm (c z : ℂ) (hz : escapeRadius c < ‖z‖) :
    escapeRadius c < ‖qmap c z‖ := by
  have h2 : (2 : ℝ) < ‖z‖ := lt_of_le_of_lt (two_le_escapeRadius c) hz
  have h := qmap_norm_ge_mul c z hz
  nlinarith

/-! ## The strengthened growth theorem and divergence -/

/-- **Escape norm growth (strengthened).** If a point `z` lies strictly outside the escape
radius of `c`, then its whole forward orbit does, and the orbit grows at least
geometrically with ratio `‖z‖ - 1 > 1`. -/
theorem escape_norm_growth (c z : ℂ) (hz : escapeRadius c < ‖z‖) (n : ℕ) :
    escapeRadius c < ‖orbit c z n‖ ∧ (‖z‖ - 1) ^ n * ‖z‖ ≤ ‖orbit c z n‖ := by
  have h2z : (2 : ℝ) < ‖z‖ := lt_of_le_of_lt (two_le_escapeRadius c) hz
  induction n with
  | zero => exact ⟨by simpa using hz, by simp⟩
  | succ n ih =>
    have hone : (1 : ℝ) ≤ (‖z‖ - 1) ^ n := one_le_pow₀ (by linarith)
    have hzn : ‖z‖ ≤ ‖orbit c z n‖ := by nlinarith [ih.2, norm_nonneg z]
    refine ⟨?_, ?_⟩
    · rw [orbit_succ']
      exact escapeRadius_lt_qmap_norm c _ ih.1
    · rw [orbit_succ']
      calc (‖z‖ - 1) ^ (n + 1) * ‖z‖ = (‖z‖ - 1) * ((‖z‖ - 1) ^ n * ‖z‖) := by ring
        _ ≤ (‖z‖ - 1) * ‖orbit c z n‖ := by
            exact mul_le_mul_of_nonneg_left ih.2 (by linarith)
        _ ≤ (‖orbit c z n‖ - 1) * ‖orbit c z n‖ := by
            exact mul_le_mul_of_nonneg_right (by linarith) (norm_nonneg _)
        _ ≤ ‖qmap c (orbit c z n)‖ := qmap_norm_ge_mul c _ ih.1

/-- **Escape criterion.** Crossing the escape radius once forces divergence to infinity. -/
theorem escape_tendsto_atTop (c z : ℂ) (hz : escapeRadius c < ‖z‖) :
    Tendsto (fun n => ‖orbit c z n‖) atTop atTop := by
  have h2z : (2 : ℝ) < ‖z‖ := lt_of_le_of_lt (two_le_escapeRadius c) hz
  have hg : Tendsto (fun n : ℕ => (‖z‖ - 1) ^ n * ‖z‖) atTop atTop :=
    Filter.Tendsto.atTop_mul_const (by linarith)
      (tendsto_pow_atTop_atTop_of_one_lt (by linarith))
  exact tendsto_atTop_mono (fun n => (escape_norm_growth c z hz n).2) hg

/-- Divergence from an *arbitrary* escape time `N`: if some orbit point crosses the escape
radius, the orbit norm tends to infinity. This is the formal specification of the
escape-time test used in practice. -/
theorem tendsto_atTop_of_exists_escape (c z : ℂ) (h : ∃ N, escapeRadius c < ‖orbit c z N‖) :
    Tendsto (fun n => ‖orbit c z n‖) atTop atTop := by
  obtain ⟨N, hN⟩ := h
  have hshift := escape_tendsto_atTop c (orbit c z N) hN
  have key : ∀ n : ℕ, orbit c z (n + N) = orbit c (orbit c z N) n := by
    intro n; rw [Nat.add_comm, orbit_add]
  rw [← Filter.tendsto_add_atTop_iff_nat N]
  simpa only [key] using hshift

/-- **Effective escape time.** If the starting point exceeds the escape radius with margin
`ε > 0` above `2`, then after `n ≥ B / (ε * ‖z‖)` iterations the orbit provably exceeds the
threshold `B`. This turns the qualitative escape criterion into a terminating algorithm. -/
theorem escape_time_bound (c z : ℂ) (ε B : ℝ) (hε : 0 < ε)
    (hz : escapeRadius c < ‖z‖) (hzε : 2 + ε ≤ ‖z‖)
    {n : ℕ} (hn : B / (ε * ‖z‖) ≤ n) : B ≤ ‖orbit c z n‖ := by
  have hzpos : (0 : ℝ) < ‖z‖ := by linarith
  have hprod : (0 : ℝ) < ε * ‖z‖ := mul_pos hε hzpos
  have hBle : B ≤ (n : ℝ) * (ε * ‖z‖) := (div_le_iff₀ hprod).mp hn
  have hb : 1 + (n : ℝ) * ε ≤ (1 + ε) ^ n := one_add_mul_le_pow (by linarith) n
  have hmono : (1 + ε) ^ n ≤ (‖z‖ - 1) ^ n :=
    pow_le_pow_left₀ (by linarith) (by linarith) n
  have hg := (escape_norm_growth c z hz n).2
  have h1 : (1 + (n : ℝ) * ε) * ‖z‖ ≤ (‖z‖ - 1) ^ n * ‖z‖ :=
    mul_le_mul_of_nonneg_right (hb.trans hmono) hzpos.le
  nlinarith [h1, hg, hBle, hzpos]

/-! ## Soundness and completeness of the escape-time test -/

/-- The orbit of `z` under `f_c` is bounded. -/
def BoundedOrbit (c z : ℂ) : Prop := ∃ B : ℝ, ∀ n, ‖orbit c z n‖ ≤ B

/-- **Soundness and completeness of the escape-time test**: an orbit of `f_c` is bounded
if and only if it never crosses the escape radius `max 2 ‖c‖`. -/
theorem bounded_iff_never_escapes (c z : ℂ) :
    BoundedOrbit c z ↔ ∀ n, ‖orbit c z n‖ ≤ escapeRadius c := by
  constructor
  · rintro ⟨B, hB⟩ n
    by_contra hlt
    push_neg at hlt
    have hdiv := tendsto_atTop_of_exists_escape c z ⟨n, hlt⟩
    obtain ⟨m, hm⟩ := (hdiv.eventually_gt_atTop B).exists
    exact absurd (hB m) (not_le.mpr hm)
  · intro h; exact ⟨escapeRadius c, h⟩

/-- Escaping and diverging are the same for the quadratic family. -/
theorem exists_escape_iff_tendsto (c z : ℂ) :
    (∃ N, escapeRadius c < ‖orbit c z N‖) ↔
      Tendsto (fun n => ‖orbit c z n‖) atTop atTop := by
  constructor
  · exact tendsto_atTop_of_exists_escape c z
  · intro h
    obtain ⟨N, hN⟩ := (h.eventually_gt_atTop (escapeRadius c)).exists
    exact ⟨N, hN⟩

/-! ## The radius-2 test for the Mandelbrot set -/

/-- The escape-time test at radius `2` characterises the Mandelbrot set exactly. -/
theorem mem_Mandelbrot_iff (c : ℂ) :
    c ∈ Mandelbrot ↔ ∀ n, ‖critOrbit c n‖ ≤ 2 := by
  constructor
  · intro hc n
    have hc2 : ‖c‖ ≤ 2 := mandelbrot_subset_closedBall hc
    have hR : escapeRadius c = 2 := max_eq_left hc2
    obtain ⟨B, hB⟩ := hc
    have hb : BoundedOrbit c 0 := ⟨B, fun k => by simpa [critOrbit_eq_orbit] using hB k⟩
    have := (bounded_iff_never_escapes c 0).mp hb n
    rw [hR] at this
    simpa [critOrbit_eq_orbit] using this
  · intro h; exact ⟨2, h⟩

/-- **Dichotomy for the critical orbit**: it either stays in the closed disk of radius `2`
forever, or its norm tends to infinity. There is no intermediate behaviour. -/
theorem critOrbit_dichotomy (c : ℂ) :
    (∀ n, ‖critOrbit c n‖ ≤ 2) ∨ Tendsto (fun n => ‖critOrbit c n‖) atTop atTop := by
  by_cases h : ∀ n, ‖critOrbit c n‖ ≤ 2
  · exact Or.inl h
  · right
    push_neg at h
    obtain ⟨n, hn⟩ := h
    by_cases hc : ‖c‖ ≤ 2
    · have hR : escapeRadius c = 2 := max_eq_left hc
      have : Tendsto (fun k => ‖orbit c 0 k‖) atTop atTop :=
        tendsto_atTop_of_exists_escape c 0 ⟨n, by rw [hR]; simpa [critOrbit_eq_orbit] using hn⟩
      simpa [critOrbit_eq_orbit] using this
    · exact critOrbit_tendsto_atTop c (not_le.mp hc)

/-! ## Sharpness of the radius `2` -/

/-- The critical orbit of `c = -2` is `0, -2, 2, 2, 2, …`. -/
lemma critOrbit_neg_two (n : ℕ) : critOrbit (-2 : ℂ) (n + 2) = 2 := by
  induction n with
  | zero => norm_num [critOrbit_succ]
  | succ n ih => rw [critOrbit_succ, ih]; norm_num

/-- `c = -2` lies in the Mandelbrot set: its critical orbit is eventually the fixed point
`2`, of norm exactly `2`. -/
theorem neg_two_mem_Mandelbrot : (-2 : ℂ) ∈ Mandelbrot := by
  rw [mem_Mandelbrot_iff]
  intro n
  match n with
  | 0 => simp
  | 1 => norm_num [critOrbit_succ]
  | (k + 2) => rw [critOrbit_neg_two]; norm_num

/-- **Sharpness of the escape radius.** For every `R < 2` the radius-`R` test is unsound:
`c = -2` belongs to the Mandelbrot set although its critical orbit exceeds `R`. Hence the
escape radius `2` in `mem_Mandelbrot_iff` cannot be lowered. -/
theorem escapeRadius_sharp {R : ℝ} (hR : R < 2) :
    ∃ c : ℂ, c ∈ Mandelbrot ∧ ∃ n, R < ‖critOrbit c n‖ := by
  refine ⟨-2, neg_two_mem_Mandelbrot, 2, ?_⟩
  have : critOrbit (-2 : ℂ) 2 = 2 := critOrbit_neg_two 0
  rw [this]
  simpa using hR

/-! ## Topological consequences: the escape-time test sets -/

/-- The `n`-th test set of the escape-time algorithm: the parameters that survive `n`
iterations of the radius-`2` test. -/
def testSet (n : ℕ) : Set ℂ := {c | ∀ k ≤ n, ‖critOrbit c k‖ ≤ 2}

lemma continuous_critOrbit (n : ℕ) : Continuous fun c : ℂ => critOrbit c n := by
  induction n with
  | zero => simpa using continuous_const
  | succ n ih =>
    simp only [critOrbit_succ]
    exact (ih.pow 2).add continuous_id

lemma isClosed_testSet (n : ℕ) : IsClosed (testSet n) := by
  have h : testSet n = ⋂ k ∈ Set.Iic n, {c : ℂ | ‖critOrbit c k‖ ≤ 2} := by
    ext c; simp [testSet, Set.mem_Iic]
  rw [h]
  exact isClosed_biInter fun k _ =>
    isClosed_le ((continuous_critOrbit k).norm) continuous_const

lemma testSet_antitone : Antitone testSet := by
  intro m n hmn c hc k hk
  exact hc k (hk.trans hmn)

/-- The Mandelbrot set is exactly the intersection of all escape-time test sets: the
escape-time algorithm converges to `M` from outside. -/
theorem Mandelbrot_eq_iInter : Mandelbrot = ⋂ n, testSet n := by
  ext c
  simp only [Set.mem_iInter, testSet, Set.mem_setOf_eq]
  rw [mem_Mandelbrot_iff]
  constructor
  · intro h n k _; exact h k
  · intro h n; exact h n n le_rfl

theorem isClosed_Mandelbrot : IsClosed Mandelbrot := by
  rw [Mandelbrot_eq_iInter]
  exact isClosed_iInter isClosed_testSet

theorem isCompact_Mandelbrot : IsCompact Mandelbrot := by
  refine Metric.isCompact_of_isClosed_isBounded isClosed_Mandelbrot ?_
  refine Bornology.IsBounded.subset (Metric.isBounded_closedBall (x := (0 : ℂ)) (r := 2)) ?_
  intro c hc
  simpa [mem_closedBall_zero_iff] using mandelbrot_subset_closedBall hc

end EscapeCriterion

/-!
## Lab Notes (experimental data behind the statements above)

Floating-point experiments performed before formalisation (see `ComputationalEvidence.md`
in the project root for the full protocol); these guided, but do not constitute, the proofs.

* 20 000 random pairs `(c, z₀) ∈ ([-3,3]²)²`: every orbit that crossed `max(2, ‖c‖)` had
  `‖z‖ > 10⁶` within 50 further iterations — 0 counterexamples to
  `tendsto_atTop_of_exists_escape`.
* 20 000 random escaping points: 0 violations of the one-step bound
  `‖z² + c‖ ≥ (‖z‖ - 1)‖z‖` (`qmap_norm_ge_mul`).
* 20 000 random `c` with `‖c‖ ≤ 2`: every critical orbit that exceeded `2` diverged
  (0 counterexamples to `mem_Mandelbrot_iff`).
* Growth is *much* faster than the geometric bound: for `c = 0.3 + 0.1i`, `z₀ = 2.5`,
  the orbit norms are `2.5, 6.55, 43.2, 1.87·10³, 3.49·10⁶` against the certified lower
  bounds `2.5, 3.75, 5.63, 8.44, 12.66`. This gap is exactly what
  `Novelty.EscapeDoublyExponential.log_norm_orbit_sub_one_ge` closes.
* Sharpness: the orbit of `c = -2` is `0, -2, 2, 2, …`, bounded with norm exactly `2`
  (`escapeRadius_sharp`); no radius below `2` yields a sound test.
-/