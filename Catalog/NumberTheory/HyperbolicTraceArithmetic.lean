import MachineLearning.HyperbolicNumberTheory.Foundations

/-!
# Arithmetic of modular traces and Pell conics

A determinant-one integral Möbius transformation generates an arithmetic orbit through
its powers.  Its traces satisfy a second-order recurrence, and consecutive traces lie
on a fixed integral Pell conic.  This gives a precise bridge between the dynamics of a
hyperbolic element of the modular group and quadratic Diophantine arithmetic.

The construction deliberately uses traces, rather than declaring tessellation vertices
to be primes: vertices do not carry canonical addition or multiplication.  Trace
coordinates are conjugacy-invariant and therefore provide intrinsic arithmetic data.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Six falsifiable targets were ranked by expected impact.
(1) Primitive closed geodesics admit a prime-orbit theorem with the Selberg asymptotic;
(2) a suitably completed Selberg zeta function has all nontrivial zeros on its spectral
critical locus; (3) primitive modular conjugacy classes correspond to primitive integral
points on a family of Pell conics; (4) every power orbit of an integral determinant-one
Möbius map remains on one fixed Pell conic; (5) reduction modulo any modulus makes every
trace orbit eventually periodic; (6) the trace discriminant is invariant under modular
conjugacy. Targets (1)--(3) are the bold cross-domain conjectures, linking dynamics,
spectral analysis, and Diophantine geometry.

Experiment (Experimenter): No arXiv abstract, OEIS identifier, or LMFDB object was
supplied as an external signal, so no unverified external datum influenced target selection.
The recurrence with initial values `2,t` gives, for `t = 3`, the values
`2,3,7,18,47,123`. Substitution shows that every adjacent pair satisfies
`x² - 3xy + y² = -5`. The same symbolic cancellation works for arbitrary integral `t`.
Concrete examples below record both the trace values and their conic equation.

Analysis (Analyst): Target (4) survives in full generality. The invariant is the
Cayley--Hamilton determinant identity in scalar form. Target (6) was already established
by the imported conjugacy theorem and is used here to show that the conic parameter is
independent of the chosen representative. Finite-state reasoning supports (5), while
(1)--(3) require substantially richer notions of primitive conjugacy and spectral zeta.

Critique (Critic): Calling all tessellation vertices “primes” supplies neither a
multiplicative monoid nor irreducibility, so unique factorization is not yet a meaningful
claim. Likewise, the displayed Dirichlet-style sum in the mission has no canonical norm
or multiplicity and cannot be identified with Selberg zeta. The claimed asymptotic
`R²/(2 log R)` also conflicts with exponential hyperbolic area growth when `R` is true
hyperbolic radius. These are definition boundaries, not counterexamples to a corrected
prime-geodesic statement. The results here avoid these hidden assumptions.

Synthesis (Principal Investigator): Modular dynamics yields an integral recurrence,
conjugacy invariance fixes its parameter, and a quadratic first integral places the full
orbit on a Pell conic. This supplies a rigorous arithmetic object on which future notions
of primitiveness and factorization can be tested.
-- !-- Lab Notes -- !--
-/

namespace HyperbolicTraceArithmetic

/-- The quadratic form governing adjacent terms of a determinant-one trace orbit. -/
def pellTraceForm (t x y : ℤ) : ℤ := x ^ 2 - t * x * y + y ^ 2

/-- One recurrence step preserves the trace Pell form. -/
theorem pellTraceForm_step (t x y : ℤ) :
    pellTraceForm t y (t * y - x) = pellTraceForm t x y := by
  unfold pellTraceForm
  ring

/-
Consecutive terms of every trace recurrence lie on one fixed Pell conic.
-/
theorem traceSeq_pell_invariant (t : ℤ) (n : ℕ) :
    pellTraceForm t (traceSeq t n) (traceSeq t (n + 1)) = 4 - t ^ 2 := by
  induction' n with n ih <;> norm_num [ pellTraceForm ] at *;
  · ring;
  · rw [ show traceSeq t ( n + 2 ) = t * traceSeq t ( n + 1 ) - traceSeq t n from rfl ] ; linear_combination' ih;

/-
The invariant is the negative trace discriminant, making the quadratic-field
parameter explicit.
-/
theorem traceSeq_discriminant_bridge (t : ℤ) (n : ℕ) :
    pellTraceForm t (traceSeq t n) (traceSeq t (n + 1)) =
      -(t ^ 2 - 4) := by
  convert traceSeq_pell_invariant t n using 1 ; ring

/-- Traces of consecutive powers of a modular transformation satisfy its Pell conic. -/
theorem mobius_power_trace_pell (f : MobiusMap) (n : ℕ) :
    pellTraceForm f.trace (f.pow n).trace (f.pow (n + 1)).trace = 4 - f.trace ^ 2 := by
  have hseq : ∀ k : ℕ, (f.pow k).trace = traceSeq f.trace k := by
    intro k
    induction k using Nat.twoStepInduction with
    | zero => simp [MobiusMap.pow, MobiusMap.trace, MobiusMap.id, traceSeq]
    | one => simp [MobiusMap.pow, MobiusMap.trace, MobiusMap.comp, MobiusMap.id, traceSeq]
    | more k hk hk1 =>
        rw [MobiusMap.trace_pow_recurrence, hk, hk1]
        rfl
  rw [hseq n, hseq (n + 1)]
  exact traceSeq_pell_invariant f.trace n

/-- Conjugate modular transformations determine the same Pell conic parameter. -/
theorem conjugate_pell_parameter (f g : MobiusMap) :
    4 - (MobiusMap.comp (MobiusMap.comp f g) (MobiusMap.inv f)).trace ^ 2 =
      4 - g.trace ^ 2 := by
  rw [MobiusMap.trace_conjugate]

/-- The standard hyperbolic trace-three orbit begins with the expected values. -/
example :
    traceSeq 3 0 = 2 ∧ traceSeq 3 1 = 3 ∧ traceSeq 3 2 = 7 ∧
      traceSeq 3 3 = 18 ∧ traceSeq 3 4 = 47 ∧ traceSeq 3 5 = 123 := by
  norm_num [traceSeq]

/-- A concrete point of the trace-three orbit lies on `x² - 3xy + y² = -5`. -/
example : pellTraceForm 3 (traceSeq 3 4) (traceSeq 3 5) = -5 := by
  norm_num [pellTraceForm, traceSeq]

#check traceSeq_pell_invariant
#check traceSeq_discriminant_bridge
#check mobius_power_trace_pell

end HyperbolicTraceArithmetic