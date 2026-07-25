import Mathlib
import Logic.NeuralCoding.JarzynskiLandauer
import Combinatorics.Proofsearchinformationlimits.ProofSearchInformationLimits

/-!
# Thermodynamics of Finite Proof Search

This study gives a finite, falsifiable model of logical erasure. A derivation of
length `n` is a binary word. Certifying one distinguished derivation destroys the
alternatives, so the erased multiplicity is `2^n - 1`. This combinatorial quantity
is linked to a Landauer work functional and to adversarial verification.

The conclusions are deliberately model-relative. They do not assert that every
deductive calculus physically dissipates the stated work, nor that semantic proof
search is always unstructured.
-/

noncomputable section

open Finset BigOperators Real

namespace ProofThermodynamics

/-- Candidate derivations of depth `n` over binary inference choices. -/
abbrev Derivation (n : ℕ) := ProofSearchInformationLimits.Words 2 n

/-- Binary descriptions whose lengths are strictly below `n`. -/
abbrev ShortDescription (n : ℕ) := ProofSearchInformationLimits.ShortBinary n

/-- The number of alternatives discarded when one derivation is retained. -/
def erasedAlternatives (n : ℕ) : ℕ := Fintype.card (Derivation n) - 1

/-- Work assigned to destroying `m` independent bits at temperature `T`,
with Boltzmann scale `k`. -/
def erasureWork (k T : ℝ) (m : ℕ) : ℝ := k * T * Real.log 2 * m

/-- The one-bit entropy loss computed in the finite Jarzynski development is
exactly the logarithmic factor in one Landauer work unit. -/
theorem one_bit_landauer_unit (k T : ℝ) :
    k * T * (JarzynskiLandauer.shannonEntropy JarzynskiLandauer.uniformBool -
      JarzynskiLandauer.shannonEntropy JarzynskiLandauer.erasedBool) =
      k * T * Real.log 2 := by
  rw [JarzynskiLandauer.entropy_loss]

/-- Repeated logical erasure is the one-bit entropy loss multiplied by the number
of destroyed bits. -/
theorem erasureWork_eq_entropy_loss (k T : ℝ) (m : ℕ) :
    erasureWork k T m =
      k * T * (JarzynskiLandauer.shannonEntropy JarzynskiLandauer.uniformBool -
        JarzynskiLandauer.shannonEntropy JarzynskiLandauer.erasedBool) * m := by
  rw [one_bit_landauer_unit]
  rfl

/-
Exact exponential multiplicity of discarded derivations.
-/
theorem erasedAlternatives_exact (n : ℕ) : erasedAlternatives n = 2 ^ n - 1 := by
  unfold erasedAlternatives;
  simp +decide [ Derivation ]

/-- At every depth, the number of erased alternatives dominates the number
of created binary choices. -/
theorem erasure_dominates_creation (n : ℕ) :
    n ≤ erasedAlternatives n := by
  exact Nat.le_sub_one_of_lt
    (Nat.recOn n (by norm_num) fun n ihn => by
      norm_num [Nat.pow_succ] at *
      linarith)

/-
From depth four onward, erasure is already more than twice creation, while
its exact closed form remains exponential.
-/
theorem erasure_more_than_double_creation (n : ℕ) (hn : 4 ≤ n) :
    2 * n < erasedAlternatives n := by
  induction hn <;> simp_all +arith +decide [ erasedAlternatives_exact ];
  lia

/-
Adding one binary inference level doubles the total candidate population and
therefore transforms erased multiplicity by `E(n+1)=2E(n)+1`.
-/
theorem erasedAlternatives_recurrence (n : ℕ) :
    erasedAlternatives (n + 1) = 2 * erasedAlternatives n + 1 := by
  rw [ erasedAlternatives_exact, erasedAlternatives_exact ];
  grind +locals

/-
The thermodynamic work of selecting one depth-`n` derivation has an exact
closed form with exponential multiplicity.
-/
theorem proof_erasure_work_exact (k T : ℝ) (n : ℕ) :
    erasureWork k T (erasedAlternatives n) =
      k * T * Real.log 2 * (2 ^ n - 1) := by
  unfold erasureWork;
  norm_num [ erasedAlternatives_exact ]

/-
At nonnegative temperature and scale, proof-selection work is bounded below by
the work associated with the `n` created choices.
-/
theorem proof_erasure_landauer_lower_bound (k T : ℝ) (n : ℕ)
    (hk : 0 ≤ k) (hT : 0 ≤ T) :
    k * T * Real.log 2 * n ≤ erasureWork k T (erasedAlternatives n) := by
  have hdom := erasure_dominates_creation n
  exact mul_le_mul_of_nonneg_left (by exact_mod_cast hdom) (by positivity)

/-- No lossless coding scheme represents every depth-`n` binary derivation using
strictly fewer than `n` bits. This imports the finite incompressibility boundary
into the thermodynamic model. -/
theorem proof_descriptions_incompressible (n : ℕ) :
    ¬ ∃ encode : Derivation n → ShortDescription n,
      Function.Injective encode := by
  exact ProofSearchInformationLimits.no_uniform_strict_compression n

/-
Any verifier that examines fewer than all depth-`n` derivations leaves room for
a unique successful proof outside its transcript.
-/
theorem verification_requires_exponential_coverage (n : ℕ)
    (queried : Finset (Derivation n)) (hbudget : queried.card < 2 ^ n) :
    ∃ proof : Derivation n, proof ∉ queried ∧
      ∀ candidate ∈ queried, (candidate = proof) = False := by
  obtain ⟨ proof, hproof ⟩ := Finset.exists_of_ssubset ( Finset.ssubset_iff_subset_ne.mpr ⟨ queried.subset_univ, by aesop ⟩ ) ; use proof ; aesop;

/-
A compact synthesis: for each depth at least four there is a finite proof-search
space whose discarded alternatives are exactly exponential, dominate creation,
are incompressible below depth, and defeat every sub-exhaustive verifier.
-/
theorem exponential_erasure_witness (n : ℕ) (hn : 4 ≤ n) :
    erasedAlternatives n = 2 ^ n - 1 ∧
    2 * n < erasedAlternatives n ∧
    (¬ ∃ encode : Derivation n → ShortDescription n,
      Function.Injective encode) ∧
    ∀ queried : Finset (Derivation n), queried.card < 2 ^ n →
      ∃ proof : Derivation n, proof ∉ queried ∧
        ∀ candidate ∈ queried, (candidate = proof) = False := by
  refine ⟨erasedAlternatives_exact n, erasure_more_than_double_creation n hn,
    proof_descriptions_incompressible n, ?_⟩
  intro queried hbudget
  exact verification_requires_exponential_coverage n queried hbudget

/-!
-- !-- Lab Notes -- !--

**Hypothesis.** Ranked by expected impact: (1) finite proof selection admits an
exact Landauer-style cost whose multiplicity grows exponentially with derivation
depth; (2) there are proof families in which erased alternatives eventually
outnumber created choices; (3) incompressibility and thermodynamic erasure are two
faces of the same finite cardinality obstruction; (4) sub-exhaustive verification
cannot rule out a hidden unique proof; (5) reversible proof transformations have
zero information loss; (6) these bounds hold without qualification for every
semantic deductive system.

**Experiment.** Binary derivations were counted exactly, selection of one candidate
was modeled by discarding the remainder, and the resulting count was propagated
through a physical work functional. The same finite family was tested against
strict compression and adversarial query transcripts.

**Analysis.** Hypotheses 1--4 survive in the explicit finite model. Hypothesis 5 is
already supplied by the general entropy-preservation theorem for injective maps.
Hypothesis 6 needs a different definition: structured semantics can make a proof
locally recognizable without exhaustive search. The unifying invariant is fiber
multiplicity: it controls discarded alternatives, compression, entropy loss, and
adversarial ambiguity.

**Critique.** The exponential statement concerns candidate multiplicity, not an
unconditional lower bound for all proof systems. The work functional assumes that
each discarded alternative is recorded as an independent bit before destruction;
a compressed representation can instead charge by Shannon entropy, and the
incompressibility theorem marks the limit of uniform strict compression. The
strict more-than-double domination begins at depth four; the smaller boundary
cases are excluded explicitly. No result is obtained from a vacuous proposition or a contradictory premise.

**Synthesis.** Finite derivation spaces exhibit a precise bridge from proof
combinatorics to thermodynamic accounting: exponential candidate growth yields
exponential discarded multiplicity, while pigeonhole incompressibility and an
adversarial verifier expose independent operational consequences of the same
count.
-/

end ProofThermodynamics