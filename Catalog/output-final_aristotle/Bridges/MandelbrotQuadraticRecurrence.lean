import Mathlib

/-!
# The Quadratic Recurrence `z ↦ z² + c`: Escape Dynamics and the Number Theory of Bulbs

This file develops two intertwined strands attached to the quadratic recurrence
`z_{n+1} = z_n² + c` that defines the Mandelbrot set `M`:

* **Dynamics (analysis).**  An *escape criterion*: once the orbit leaves the disk of
  radius `2`, it grows at least geometrically and hence tends to infinity.  In
  particular every parameter of modulus `> 2` lies outside `M`, so `M` is contained
  in the closed disk of radius `2`.

* **Number theory of the bulbs (arithmetic).**  Each hyperbolic component ("bulb") of
  `M` attached to the main cardioid carries a rotation number `p/q`.  The *period* of
  the attracting cycle of that bulb is the additive order of `p` in `ℤ/qℤ`; it equals
  `q` exactly when `p/q` is in lowest terms.  The Farey/Stern–Brocot arrangement of
  these rotation numbers is governed by the Fibonacci sequence, whose consecutive
  terms are coprime and satisfy Cassini's determinant identity — the arithmetic
  fingerprint of the "golden" spiral of bulbs.

The bridge is that a purely *analytic* growth estimate on a complex recurrence
constrains the geometry of `M`, while the labelling of the resulting components is a
purely *arithmetic* statement about orders in cyclic groups and Fibonacci determinants.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer).  Two testable claims:
--   (H1) The orbit of `0` under `z ↦ z²+c` is unbounded whenever `|c| > 2`, so
--        `M ⊆ closedBall 0 2`.
--   (H2) The "period of the bulb at angle p/q in lowest terms is exactly q" is the
--        statement `addOrderOf (p : ZMod q) = q ↔ Coprime p q`.
-- Experiment (Experimenter).  (H1) reduces to a one-step estimate
--   `|z² + c| ≥ |z|(|z|-1)` valid on `|z| ≥ |c|`, iterated to a geometric lower bound
--   `|orbit (n+1)| ≥ |c|·(|c|-1)ⁿ`, then unbounded by `pow_unbounded_of_one_lt`.
--   (H2) is `ZMod.addOrderOf_coe` combined with `Nat.Coprime`.
-- Analysis (Analyst).  The dynamical claim survives verbatim.  The naive Lyapunov
--   claim `λ = log 2 · cos(π p/q)` from the mission text does NOT survive: it is not
--   dimensionally consistent with the known multiplier map and we found no derivation;
--   we therefore replaced it by the robust, provable period=order statement (H2).
-- Critique (Critic).  No theorem is vacuous: the escape theorem exhibits an explicit
--   unbounded subsequence, and the period theorem is a genuine iff whose reverse
--   direction fails for non-coprime pairs (order strictly divides q).
-- Synthesis (PI).  Escape geometry + Farey/Fibonacci arithmetic package the "secret
--   number theory" of the recurrence into fully verified statements.
-/

namespace Catalog.Bridges.MandelbrotQR

open scoped Classical

/-! ## Part I — The quadratic map and its escape dynamics -/

/-- The quadratic map `z ↦ z² + c`. -/
def qmap (c z : ℂ) : ℂ := z ^ 2 + c

/-- The `n`-fold iterate of `qmap c`. -/
def qiter (c : ℂ) : ℕ → ℂ → ℂ
  | 0,     z => z
  | n + 1, z => qmap c (qiter c n z)

/-- The critical orbit: the forward orbit of `0` under `z ↦ z² + c`.
`orbit c n` is the `n`-th point; `orbit c 1 = c`. -/
def orbit (c : ℂ) (n : ℕ) : ℂ := qiter c n 0

@[simp] lemma qiter_zero (c z : ℂ) : qiter c 0 z = z := rfl

@[simp] lemma qiter_succ (c : ℂ) (n : ℕ) (z : ℂ) :
    qiter c (n + 1) z = qmap c (qiter c n z) := rfl

@[simp] lemma orbit_zero (c : ℂ) : orbit c 0 = 0 := rfl

@[simp] lemma orbit_one (c : ℂ) : orbit c 1 = c := by
  simp [orbit, qmap]

@[simp] lemma orbit_succ (c : ℂ) (n : ℕ) : orbit c (n + 1) = (orbit c n) ^ 2 + c := rfl

/--
**One-step escape estimate.**  If `|c| ≤ |z|` then `|z² + c| ≥ |z|·(|z| - 1)`.
-/
lemma norm_qmap_lower (c z : ℂ) (hcz : ‖c‖ ≤ ‖z‖) :
    ‖z‖ * (‖z‖ - 1) ≤ ‖qmap c z‖ := by
  unfold qmap;
  have := norm_add_le ( z ^ 2 + c ) ( -c ) ; ( ring_nf at *; norm_num at *; nlinarith; )

/--
**Strict growth outside the disk of radius `2`.**  If `2 < |z|` and `|c| ≤ |z|`
then `|z| < |z² + c|`.
-/
lemma norm_lt_norm_qmap (c z : ℂ) (hz : 2 < ‖z‖) (hcz : ‖c‖ ≤ ‖z‖) :
    ‖z‖ < ‖qmap c z‖ := by
  exact lt_of_lt_of_le ( by nlinarith ) ( norm_qmap_lower c z hcz )

/--
**Geometric lower bound for the critical orbit.**  If `2 < |c|` then
`|orbit c (n+1)| ≥ |c|·(|c| - 1)ⁿ`.  In particular the modulus of the orbit grows at
least geometrically with ratio `|c| - 1 > 1`.
-/
lemma norm_orbit_ge_geometric (c : ℂ) (hc : 2 < ‖c‖) (n : ℕ) :
    ‖c‖ * (‖c‖ - 1) ^ n ≤ ‖orbit c (n + 1)‖ := by
  induction' n with n ih;
  · norm_num [ orbit_one ];
  · convert le_trans _ ( norm_qmap_lower _ _ _ ) using 1;
    · convert mul_le_mul ih ( show ‖orbit c ( n + 1 )‖ - 1 ≥ ‖c‖ - 1 from ?_ ) ?_ ?_ using 1;
      · ring;
      · exact sub_le_sub_right ( le_trans ( le_mul_of_one_le_right ( by positivity ) ( one_le_pow₀ ( by linarith ) ) ) ih ) _;
      · linarith;
      · positivity;
    · exact le_trans ( le_mul_of_one_le_right ( by positivity ) ( one_le_pow₀ ( by linarith ) ) ) ih

/--
**Escape theorem.**  If `|c| > 2` the critical orbit is unbounded: no real number
bounds every `|orbit c n|`.
-/
theorem orbit_unbounded_of_two_lt (c : ℂ) (hc : 2 < ‖c‖) :
    ∀ B : ℝ, ∃ n : ℕ, B < ‖orbit c n‖ := by
  -- By pow_unbounded_of_one_lt B (h : 1 < ‖c‖-1) there is n with B < (‖c‖-1)^n.
  have h_pow_unbounded : ∀ B : ℝ, ∃ n : ℕ, B < (‖c‖ - 1) ^ n := by
    exact fun B => pow_unbounded_of_one_lt B ( by linarith );
  intro B
  obtain ⟨n, hn⟩ := h_pow_unbounded B;
  exact ⟨ n + 1, hn.trans_le ( by exact le_trans ( by nlinarith [ pow_nonneg ( show 0 ≤ ‖c‖ - 1 by linarith ) n ] ) ( norm_orbit_ge_geometric c hc n ) ) ⟩

/-- Membership in the Mandelbrot set: the critical orbit stays bounded. -/
def Mandelbrot : Set ℂ := {c | ∃ B : ℝ, ∀ n : ℕ, ‖orbit c n‖ ≤ B}

/--
**The Mandelbrot set lives in the disk of radius `2`.**  Any parameter of modulus
`> 2` escapes, hence is not in `M`.
-/
theorem Mandelbrot_subset_closedBall : Mandelbrot ⊆ Metric.closedBall (0 : ℂ) 2 := by
  intro c hc;
  contrapose! hc;
  exact fun ⟨ B, hB ⟩ => by obtain ⟨ n, hn ⟩ := orbit_unbounded_of_two_lt c ( by simpa using hc ) B; linarith [ hB n ] ;

/-! ## Part II — The arithmetic of the bulbs: rotation numbers and Fibonacci -/

/--
**Period of the `p/q` bulb.**  For `q > 0`, the additive order of `p` in `ℤ/qℤ`
— the period of the rotation by angle `p/q` — equals `q / gcd(p, q)`.
-/
theorem bulb_period (p q : ℕ) (hq : q ≠ 0) :
    addOrderOf (p : ZMod q) = q / Nat.gcd q p := by
  convert ZMod.addOrderOf_coe p hq using 1

/--
**Lowest terms ⇒ period `q`.**  If `p/q` is in lowest terms (`gcd p q = 1`) then
the rotation by `p/q` has period exactly `q`.
-/
theorem bulb_period_coprime (p q : ℕ) (hq : q ≠ 0) (h : Nat.Coprime p q) :
    addOrderOf (p : ZMod q) = q := by
  rw [ bulb_period p q hq, h.symm.gcd_eq_one, Nat.div_one ]

/--
**The period always divides `q`.**
-/
theorem bulb_period_dvd (p q : ℕ) :
    addOrderOf (p : ZMod q) ∣ q := by
  norm_num [ addOrderOf_dvd_iff_nsmul_eq_zero ]

/--
**Non-coprime rotation numbers have strictly smaller period.**  If `1 < gcd p q`
then the period of the rotation by `p/q` is strictly less than `q`; this is the
arithmetic reason a bulb genuinely at angle `p/q` requires lowest terms.
-/
theorem bulb_period_lt_of_not_coprime (p q : ℕ) (hq : q ≠ 0)
    (hg : 1 < Nat.gcd q p) : addOrderOf (p : ZMod q) < q := by
  rw [ bulb_period ];
  · exact Nat.div_lt_self ( Nat.pos_of_ne_zero hq ) hg;
  · assumption

/-- **Consecutive Fibonacci rotation numbers are coprime.**  The golden spiral of
bulbs uses `F_n / F_{n+1}`, always in lowest terms. -/
theorem fib_ratio_lowest_terms (n : ℕ) :
    Nat.Coprime (Nat.fib n) (Nat.fib (n + 1)) :=
  Nat.fib_coprime_fib_succ n

/--
**Cassini's identity.**  `F_{n+1}² − F_n · F_{n+2} = (−1)ⁿ` over `ℤ`.  This is the
determinant of the `2×2` matrix of consecutive Fibonacci mediants — the reason
successive Fibonacci fractions are Farey neighbours (unit determinant) and hence
adjacent bulbs.
-/
theorem fib_cassini (n : ℕ) :
    (Nat.fib (n + 1) : ℤ) ^ 2 - (Nat.fib n : ℤ) * (Nat.fib (n + 2) : ℤ) = (-1) ^ n := by
  exact Nat.recOn n ( by norm_num ) fun n ih => by norm_num [ Nat.fib_add_two, pow_succ' ] at * ; linarith;

/--
**Farey-neighbour determinant for consecutive Fibonacci fractions.**  The mediant
matrix `[[F_{n+1}, F_n], [F_{n+2}, F_{n+1}]]` has determinant `±1`, so `F_n/F_{n+1}`
and `F_{n+1}/F_{n+2}` are Farey neighbours — the combinatorial rule generating the
Fibonacci arrangement of bulbs.
-/
theorem fib_farey_neighbours (n : ℕ) :
    (Nat.fib (n + 1) : ℤ) * (Nat.fib (n + 1) : ℤ)
        - (Nat.fib n : ℤ) * (Nat.fib (n + 2) : ℤ) = (-1) ^ n := by
  convert fib_cassini n using 1 ; ring

end Catalog.Bridges.MandelbrotQR