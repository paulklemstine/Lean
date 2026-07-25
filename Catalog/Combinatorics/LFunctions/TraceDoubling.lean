import NumberTheory.PosetTheory.HyperbolicTraceArithmetic

/-!
# Trace doubling on modular hyperbolic orbits

For an integral determinant-one Möbius transformation, the trace of its powers is an
intrinsic arithmetic coordinate on the corresponding hyperbolic orbit.  This chapter
shows that multiplication of the orbit index is transported to explicit polynomial
maps on traces.  In particular, doubling is the quadratic map `x ↦ x² - 2`, and its
trace discriminant factors multiplicatively.

These identities bridge group dynamics, integral recurrences, quadratic Diophantine
geometry, and polynomial iteration.  They also identify a robust arithmetic structure
that does not depend on assigning noncanonical ring operations to tessellation vertices.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Six falsifiable conjectures were ranked by impact.
(1) primitive modular conjugacy classes satisfy the prime-geodesic asymptotic;
(2) the completed spectral zeta function has zeros on its spectral critical locus;
(3) index multiplication on every determinant-one trace orbit is represented by integral
Chebyshev polynomials; (4) trace doubling preserves the Pell-conic family through an
explicit morphism; (5) the trace discriminant at a doubled index factors as the old
discriminant times a square; (6) reduction of every trace orbit modulo a positive modulus
is periodic. The first three are bold cross-domain targets joining hyperbolic dynamics,
spectral theory, and arithmetic geometry.

Experiment (Experimenter): The trace-three sequence begins `2, 3, 7, 18, 47, 123`.
Doubling predicts `u₂ = 3²-2 = 7`, `u₄ = 7²-2 = 47`, while tripling predicts
`u₃ = 3³-3·3 = 18`. The examples below test both identities again at later indices.
No arXiv abstract, OEIS sequence, or LMFDB object was supplied in the mission, so target
selection was not based on an unverified external signal.

Analysis (Analyst): Conjectures (3)--(5) survive for doubling and tripling. The key
structural pattern is that a recurrence orbit is the trace shadow of a group-power orbit:
`g^(mn) = (g^n)^m`. Cayley--Hamilton then turns index multiplication into polynomial
iteration. The Pell invariant from the imported arithmetic development supplies the
quadratic-geometric interpretation.

Critique (Critic): The original vertex-based “hyperbolic primes” have no specified
multiplicative monoid, so unique factorization is not yet a well-formed claim. Likewise,
a sum over an unspecified orbit norm is not canonically the Selberg zeta function, and
checking finitely many zeros cannot establish a critical-line theorem. The present results
make none of these assumptions. Boundary cases `t = ±2` are retained: their discriminant
vanishes, and the factorization theorem correctly records this parabolic degeneration.

Synthesis (Principal Investigator): Orbit-index multiplication, trace polynomials, and
Pell discriminants form one compatible arithmetic system. The doubling and tripling laws
are exact, conjugacy-invariant, and valid uniformly for elliptic, parabolic, and hyperbolic
integral determinant-one transformations. A broader generalization should construct the
full family of trace polynomials and study their reductions over finite rings.
-- !-- Lab Notes -- !--
-/

namespace HyperbolicTraceDoubling

open HyperbolicTraceArithmetic

/-- Every integral value occurs as the trace of a determinant-one integral Möbius map. -/
def traceWitness (t : ℤ) : MobiusMap where
  a := t - 1
  b := 1
  c := t - 2
  d := 1
  det_one := by ring

@[simp] theorem trace_traceWitness (t : ℤ) : (traceWitness t).trace = t := by
  simp [traceWitness, MobiusMap.trace]

/-
Powers of a trace witness realize the universal trace recurrence.
-/
theorem trace_pow_eq_traceSeq (f : MobiusMap) (n : ℕ) :
    (f.pow n).trace = traceSeq f.trace n := by
  induction' n using Nat.twoStepInduction with n ih1 ih2 <;> simp_all +decide [ traceSeq ];
  · exact Int.neg_inj.mp rfl
  · exact congr_arg MobiusMap.trace ( show MobiusMap.comp f MobiusMap.id = f from MobiusMap.comp_id f );
  · rw [ ← ih1, ← ih2, MobiusMap.trace_pow_recurrence ]

/-
Taking powers in two stages multiplies their indices.
-/
theorem mobius_pow_mul (f : MobiusMap) (m n : ℕ) :
    (f.pow n).pow m = f.pow (m * n) := by
  induction' m with m ih;
  · aesop;
  · convert congr_arg ( fun x => MobiusMap.comp ( f.pow n ) x ) ih using 1;
    convert MobiusMap.pow_add f n ( m * n ) using 1 ; ring

/-
Index doubling is the quadratic trace map `x ↦ x² - 2`.
-/
theorem traceSeq_double (t : ℤ) (n : ℕ) :
    traceSeq t (2 * n) = (traceSeq t n) ^ 2 - 2 := by
  have h_traceSeq : ∀ n : ℕ, traceSeq t (2 * n) = traceSeq t n ^ 2 - 2 := by
    intro n;
    obtain ⟨f, hf⟩ : ∃ f : MobiusMap, f.trace = t := by
      exact ⟨ traceWitness t, trace_traceWitness t ⟩;
    rw [ ← hf, ← trace_pow_eq_traceSeq ];
    convert MobiusMap.trace_sq ( f.pow n ) using 1;
    · rw [ two_mul, MobiusMap.pow_add ];
    · rw [ ← trace_pow_eq_traceSeq ];
  exact h_traceSeq n

/-
Index tripling is the cubic trace map `x ↦ x³ - 3x`.
-/
theorem traceSeq_triple (t : ℤ) (n : ℕ) :
    traceSeq t (3 * n) = (traceSeq t n) ^ 3 - 3 * traceSeq t n := by
  let f := traceWitness t
  calc
    traceSeq t (3 * n) = (f.pow (3 * n)).trace := by
      rw [trace_pow_eq_traceSeq, trace_traceWitness]
    _ = ((f.pow n).pow 3).trace := by rw [mobius_pow_mul]
    _ = traceSeq (f.pow n).trace 3 := trace_pow_eq_traceSeq _ _
    _ = (f.pow n).trace ^ 3 - 3 * (f.pow n).trace := traceSeq_three _
    _ = traceSeq t n ^ 3 - 3 * traceSeq t n := by
      rw [trace_pow_eq_traceSeq, trace_traceWitness]

/-
The discriminant of a doubled trace is the old discriminant times a square.
-/
theorem traceSeq_double_discriminant (t : ℤ) (n : ℕ) :
    traceSeq t (2 * n) ^ 2 - 4 =
      (traceSeq t n ^ 2 - 4) * traceSeq t n ^ 2 := by
  rw [ traceSeq_double ] ; ring

/-
Doubling transports the trace Pell parameter by an explicit square factor.
-/
theorem pell_parameter_double (t : ℤ) (n : ℕ) :
    4 - traceSeq t (2 * n) ^ 2 =
      (4 - traceSeq t n ^ 2) * traceSeq t n ^ 2 := by
  rw [ traceSeq_double ] ; ring

/-- Concrete doubling at index five in the trace-three orbit. -/
example : traceSeq 3 10 = traceSeq 3 5 ^ 2 - 2 := by
  exact traceSeq_double 3 5

/-- Concrete tripling at index four in the trace-three orbit. -/
example : traceSeq 3 12 = traceSeq 3 4 ^ 3 - 3 * traceSeq 3 4 := by
  exact traceSeq_triple 3 4

/-- The parabolic boundary has identically vanishing doubled discriminant. -/
example (n : ℕ) : traceSeq 2 (2 * n) ^ 2 - 4 = 0 := by
  rw [traceSeq_double_discriminant]
  have h : traceSeq 2 n = 2 := by
    induction n using Nat.twoStepInduction with
    | zero => rfl
    | one => rfl
    | more n h0 h1 => simp [traceSeq, h0, h1]
  rw [h]
  norm_num

#check traceSeq_double
#check traceSeq_triple
#check traceSeq_double_discriminant
#check HyperbolicTraceArithmetic.traceSeq_pell_invariant

end HyperbolicTraceDoubling