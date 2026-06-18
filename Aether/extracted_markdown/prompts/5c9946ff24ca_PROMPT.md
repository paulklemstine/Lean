            ## Assignment: Closing the Single-Power Gap

            Prove new, non-trivial theorems. Build on catalog theorems. Minimize sorry.

            ## Depth Requirements (MANDATORY)

Your output must satisfy ALL of these:

1. **NO trivial proofs**: Do NOT prove statements by `native_decide`, `decide`,
   `norm_num`, or `rfl` unless the statement itself is genuinely important.
   If the only proof tactic is enumeration, the theorem is not worth formalizing.

2. **At least 3 theorems with deep proof tactics**: Your file must contain at
   least 3 theorems proven using induction, rcases, by_contra, field_simp,
   or multi-step calc reasoning.

3. **Novel definitions**: Define at least one new mathematical structure or concept
   that does not already exist in the Catalog. Check the catalog references to
   confirm novelty.

4. **Conjecture with testable prediction**: State at least one falsifiable
   conjecture with a clear computational test that could disprove it.


            ### Research Direction
            Conjecture: For every fixed `k ≥ 0`, there exists `c_k > 0` such that for infinitely many `d`, some depth-`k` exchange family in dimension `d` has worst-case descent length at least `c_k · d^{d-k}` (matching the upper bound exactly, not just `d^{d-k-1}`).

Test: Construct increasingly refined adversarial families for `d = 4, ..., 20` with fixed `k = 0, 1, 2`. Compute worst-case descent lengths and fit the growth rate. If `T(d,k) / d^{d-k}` converges to a positive constant, the conjecture holds. If `T(d,k) / d^{d-k-1}` converges instead, the lower bound is tight and the upper bound can be improved.

Impact: Resolves the central open question of the current theory. If the upper bound is tight, certificate depth is the exact complexity exponent. If not, there exists a finer invariant — a "certificate depth 2.0" — waiting to be discovered.

            ### Mathematical Framing
            Conjecture: For every fixed `k ≥ 0`, there exists `c_k > 0` such that for infinitely many `d`, some depth-`k` exchange family in dimension `d` has worst-case descent length at least `c_k · d^{d-k}` (matching the upper bound exactly, not just `d^{d-k-1}`).

Test: Construct increasingly refined adversarial families for `d = 4, ..., 20` with fixed `k = 0, 1, 2`. Compute worst-case descent lengths and fit the growth rate. If `T(d,k) / d^{d-k}` converges to a positive constant, the conjecture holds. If `T(d,k) / d^{d-k-1}` converges instead, the lower bound is tight and the upper bound can be improved.

Impact: Resolves the central open question of the current theory. If the upper bound is tight, certificate depth is the exact complexity exponent. If not, there exists a finer invariant — a "certificate depth 2.0" — waiting to be discovered.


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `monotone_KW_lower_bound_implies_formula_depth_lower_bound` : theorem monotone_KW_lower_bound_implies_formula_depth_lower_bound
     (file: Computation/ApproximationMethod.lean)
  2. `KW_lower_bound_implies_formula_depth_lower_bound` : theorem KW_lower_bound_implies_formula_depth_lower_bound [NeZero n]
     (file: Computation/KarchmerWigderson.lean)
  3. `monotone_KW_lower_bound_implies_formula_depth_lower_bound` : theorem monotone_KW_lower_bound_implies_formula_depth_lower_bound
     (file: FINAL/Computation/ApproximationMethod.lean)
  4. `KW_lower_bound_implies_formula_depth_lower_bound` : theorem KW_lower_bound_implies_formula_depth_lower_bound [NeZero n]
     (file: FINAL/Computation/KarchmerWigderson.lean)
  5. `family_path_length_bound` : theorem family_path_length_bound
     (file: Computation/Theorems.lean)
  6. `family_path_length_bound` : theorem family_path_length_bound
     (file: FINAL/Computation/Theorems.lean)
  7. `conjecture_linear_certificate_density_lower_bound` : theorem conjecture_linear_certificate_density_lower_bound : True := trivial
     (file: Algebra/MatrixGroupGeneration.lean)
  8. `not_exists_uniform_exp_depth_bound` : theorem not_exists_uniform_exp_depth_bound :
     (file: Bridges/ArrowDepthComplexity.lean)
  9. `exists_fixed_point_on_orbit_with_bound` : theorem exists_fixed_point_on_orbit_with_bound
     (file: Bridges/HolographicProofRenormalization.lean)
  10. `conjecture_linear_certificate_density_lower_bound` : theorem conjecture_linear_certificate_density_lower_bound : True := trivial
     (file: FINAL/Algebra/MatrixGroupGeneration.lean)
  11. `not_exists_uniform_exp_depth_bound` : theorem not_exists_uniform_exp_depth_bound :
     (file: FINAL/Bridges/ArrowDepthComplexity.lean)
  12. `exists_fixed_point_on_orbit_with_bound` : theorem exists_fixed_point_on_orbit_with_bound
     (file: FINAL/Bridges/HolographicProofRenormalization.lean)
  13. `adversarial_descent_lower_bound` : theorem adversarial_descent_lower_bound
     (file: Bridges/Catalog/Pythagorean/SharpExponentLowerBounds.lean)
  14. `adversarial_descent_lower_bound` : theorem adversarial_descent_lower_bound
     (file: FINAL/Bridges/SharpExponentLowerBounds.lean)
  15. `dag_depth_lower_bound_for_iterExp` : theorem dag_depth_lower_bound_for_iterExp
     (file: Pythagorean/DagDepthHierarchy/Theorems.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


### Catalog Reference Files (Catalog/FINAL/ = vetted, high-quality)

(File paths starting with FINAL/ are vetted, high-quality catalog entries.)
@FINAL/Computation/AffineDistortionComplexity.lean
```lean
import Mathlib

/-!
# Affine Distortion as a Complexity Monotone

This file establishes that **affine encodability** — the ability to map a finite dataset
into a bounded discrete grid via an affine transformation — yields certified upper bounds
on description complexity, code length, and entropy.

## Main Definitions

* `RationalAffineEncodable xs k`: A finite list of rationals `xs` can be affinely mapped
  into `{0, 1, ..., 2^k - 1}` with positive scaling factor.

## Main Results

* `rational_affine_encodable_perm_invariant`: Affine encodability is invariant under
  permutation of the data list.
* `rational_affine_encodable_gives_code_length`: Affine encodability with bit budget `k`
  implies existence of a code of length at most `n * k + k`, where `n = xs.length`.
* `rational_affine_encodable_gives_entropy_bound`: Affine encodability implies the
  dataset lives in a set of cardinality at most `(2^k)^n`, yielding a finite entropy bound.
* `rational_affine_encodable_empty`: The empty list is trivially affine encodable.
* `rational_affine_encodable_singleton`: Any singleton list is affine encodable for any k ≥ 1.
* `rational_affine_encodable_mono`: Affine encodability is monotone in the bit budget.
* `rational_affine_encodable_sublist`: Affine encodability is inherited by sublists.

## Mathematical Significance

These results establish **affine distortion as an algorithmic regularity certificate**.
Low affine distortion is not merely an approximation quality metric — it is a
compressibility witness with direct complexity-theoretic meaning. The pipeline is:

  affine distortion → compression bound → entropy bound

This creates a reusable architecture for proving information-theoretic consequences
from geometric normalization.
-/

open List

/-! ## Definition of Rational Affine Encodability -/

/-- A list of rationals `xs` is **rationally affine encodable** with bit budget `k` if
there exist rational affine parameters `a, b` with `a > 0` such that every element
`x ∈ xs` maps to a natural number `n < 2^k` under the transformation `x ↦ a * x + b`. -/
def RationalAffineEncodable (xs : List ℚ) (k : ℕ) : Prop :=
  ∃ a b : ℚ, 0 < a ∧ ∀ x ∈ xs, ∃ n : ℕ, n < 2 ^ k ∧ a * x + b = ↑n

/-! ## Permutation Invariance -/

/-- Affine encodability depends only on the multiset of values, not their order.
This is because the defining property quantifies over membership, which is
permutation-invariant. -/
theorem rational_affine_encodable_perm_invariant
    {xs ys : List ℚ} {k : ℕ}
    (h : ys ~ xs) :
    RationalAffineEncodable xs k ↔ RationalAffineEncodable ys k := by
  constructor
  · rintro ⟨a, b, ha, henc⟩
-- ... (truncated, full file has 217 lines)
```

@FINAL/Computation/Algebra.lean
```lean
import Computation.TropicalLife.Basic
import Computation.TropicalLife.StillLife

/-!
# Tropical Algebraic Structure of the Life Automaton

## Overview

We establish algebraic properties of the tropical Life automaton that connect
it to the broader theory of tropical semirings and closure operators. These
results demonstrate that the automaton's dynamics are not arbitrary but arise
from genuine tropical algebraic structure.

## Main Results

* `neighborScore_min_assoc` — associativity of tropical aggregation over the
  Moore neighborhood, using the catalog's `tropical_min_associative`
* `tropicalThreshold_shift_invariant` — the threshold function is invariant
  under uniform shifts, reflecting tropical distributivity
* `tropicalLifeStep_iterate_fixed` — the step operator is idempotent on fixed points
* `stillLife_orbitDiversity_eq_one` — still lifes have minimal orbit diversity
* `still_life_has_bounded_orbit_description` — still lifes are compression-theoretic
  attractors (connecting to the catalog's closure framework)
* `neighborSum_le_eight_of_binary` — neighbor sum bound for binary configurations

## Catalog Connections

This file explicitly uses theorems from the project's tropical algebra catalog:
- `tropical_min_associative_nat` for neighborhood aggregation order-independence
- The closure compression framework for still-life characterization
-/

open Function Finset

/-! ## Tropical Aggregation Properties -/

/-- The tropical minimum over three neighbor values is associative, establishing
    that the order of pairwise comparison does not affect the result.
    This is a direct application of `tropical_min_associative_nat` from the
    catalog's tropical algebra foundation.

    In the context of the Life automaton, this ensures that the tropical
    energy (minimum over neighborhood) is well-defined regardless of the
    order in which neighbors are processed. -/
theorem neighborScore_min_assoc (a b c : ℕ) :
    min (min a b) c = min a (min b c) :=
  tropical_min_associative_nat a b c

/-- Tropical distributivity applied to threshold computation:
    shifting a threshold interval is equivalent to applying the shift
    after comparison. This is the algebraic backbone of the local rule's
    translation-invariance.

    Uses `tropical_distributivity_nat` from the catalog. -/
theorem tropicalThreshold_shift_invariant (s lo hi k : ℕ) :
    tropicalThreshold (s + k) (lo + k) (hi + k) = tropicalThreshold s lo hi := by
  simp only [tropicalThreshold]
  congr 1
  · congr 1; omega
  · congr 1; omega
-- ... (truncated, full file has 133 lines)
```

@FINAL/Computation/AlgorithmicCertificate.lean
```lean
import Mathlib

/-!
# Algorithmic Certificates: A Unified Framework

This file formalizes the abstract meta-theorem that unifies binary search, Dijkstra's algorithm,
and NTT/FFT as instances of a single paradigm:

* A **state transition system** with a step function
* An **invariant** preserved by each step
* A **potential function** that strictly decreases on each non-terminal step
* A **semantic extraction** that yields the correct answer at termination

The main theorem `correctness_of_decreasing_potential` shows that any such system
terminates within `potential(init)` steps and produces a correct answer.

This is the formal backbone of the "algorithms as dynamical systems with monotone certificates"
paradigm.
-/

open Function

noncomputable section

/-- An algorithmic certificate bundles a state transition system with
an invariant, a potential function, a termination predicate, and a
specification extraction map. -/
structure AlgorithmicCertificate (State Spec : Type*) where
  /-- The step function advances the state. -/
  step : State → State
  /-- The invariant that must be preserved. -/
  invariant : State → Prop
  /-- The potential / ranking function, a natural number that decreases. -/
  potential : State → ℕ
  /-- Whether the state is terminal (search complete). -/
  terminal : State → Bool
  /-- Extracts the answer from a terminal state. -/
  extract : State → Spec

/-- The specification predicate: what it means for the output to be correct. -/
def CorrectSpec {Spec : Type*} (correctness : Spec → Prop) (s : Spec) : Prop :=
  correctness s

/-- Iterated step function. -/
def AlgorithmicCertificate.iterStep {State Spec : Type*}
    (A : AlgorithmicCertificate State Spec) (n : ℕ) (s : State) : State :=
  A.step^[n] s

/-
The main meta-theorem: any state machine with a preserved invariant,
strictly decreasing potential on non-terminal steps, and correct extraction
at terminal states, terminates within `potential(init)` steps with a correct output.
-/
theorem correctness_of_decreasing_potential
    {State Spec : Type*}
    (A : AlgorithmicCertificate State Spec)
    (correctness : Spec → Prop)
    (init : State)
    (hInv0 : A.invariant init)
    (hPres : ∀ s, A.invariant s → A.terminal s = false → A.invariant (A.step s))
-- ... (truncated, full file has 144 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above (FINAL/ entries are vetted, high-quality — prioritize these).

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction.

            ### Anti-Triviality Rules
            Do NOT produce any of the following:
            - Commutativity/associativity proofs for standard algebraic structures
              (e.g., `a + b = b + a` for semirings, `a * b * c = a * (b * c)`)
            - Wrapper theorems that just unwrap a definition without mathematical insight
            - Proofs that are just `by simp` or `by trivial` with no depth
            - Definitions followed by trivial properties that don't advance understanding
            If a result seems obvious, prove something STRONGER — the stronger theorem
            is often easier to prove and more interesting.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md, RESEARCH_PAPER.md,
                      ARTICLE.md (Scientific American style), algorithm, demo.py
            Optional: (none — all key deliverables are mandatory)

            ## Taboo Topics for ARTICLE.md

            The Scientific American-style article MUST NOT focus on formal verification
            or machine verification. Do not write about proof assistants, type theory
            as verification, or mechanized checking — those topics are technical niche
            and alienate a broad audience. Instead, write about the IDEAS: what was
            discovered, why it matters, and what it means for mathematics and science.
            The article should read like a Scientific American feature, not a software
            demo or verification report.

            ## Catalog Context for Future Directions
            Below are key theorems from the Catalog for lineage references.
            Use the **Catalog References** field to cite the exact file paths.

            ### Key Theorems Available
            **Algebra**:
  `Algebra/Advanced.lean`: iterateB, iterateB_one, iterateB_two
  `Algebra/Agent.lean`: euclid_inradius_num, euclid_perimeter, euclid_twice_area
  `Algebra/Berggren.lean`: applyB₁, A_iter, A_closed
**Bridges**:
  `Bridges/AlgebraEMLClosureComputation.lean`: ClosureSemimoduleSystem, ProbeFamily, ClosureStableProbe
  `Bridges/AlgebraEMLReconstruction.lean`: SetClosureOperator, {α, ClosedSet
  `Bridges/AlgebraPythagoreanCryptography/BerggrenLatticeReductionDuality.lean`: PrimTriple, PrimTriple.a_lt_c, PrimTriple.b_lt_c
**Computation**:
  `Computation/GravityOracle.lean`: IsGravOracle, GravTruthSet, geodesic_oracle_idempotent
  `Computation/InfoEfficientAlgorithms.lean`: InfoEfficientAlgorithm, InfoEfficientAlgorithm.terminates_within_potential, BSState
  `Computation/PadicValuationDepth.lean`: ValuationDepthMeasure, vdepth_const_eq_zero, vdepth_sum_le
**Cryptography**:
  `Cryptography/BerggrenDiophantineLattice.lean`: lorentzForm, euclidNormSq, IsPythagoreanVec
  `Cryptography/BerggrenFingerprintRigidity.lean`: berggrenGen, evalWord, rootTriple
  `Cryptography/BerggrenGroupoidOrbit.lean`: berggrenA, berggrenB, berggrenC
**EML**:
  `EML/AdvancedTheory.lean`: ensembleComplexity, ensemble_complexity_additive, uniform_ensemble_complexity
  `EML/EMLv17Core.lean`: eml, emlDiag, sigmaEml
  `EML/ModularForms.lean`: T_sq, S_gen, BM₃_inv

            FUTURE_DIRECTIONS.md MUST be a standalone research roadmap. It will be
            used to steer future research rounds WITHOUT access to this cycle's code.
            Each direction must be self-contained: include enough mathematical context,
            definitions, and motivation that a fresh researcher can pick up any
            direction and start working on it immediately. Do NOT assume the reader
            has seen your Lean code.

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Begin with a ## Synthesis section tying all directions together and
            identifying the most promising cross-domain connections from this cycle.
            Then list 3-5 directions (1-2 grand_challenge + 2-3 extension) using:

            ## Synthesis

            [2-3 paragraphs tying all directions together. Identify the most promising
            cross-domain connection from this cycle's discoveries. Explain how the
            cycle's results relate to the broader Catalog. Highlight which direction
            has the highest breakthrough potential and why.]

            ---

            ### Direction 1: [Title]

            **Conjecture**: A precise mathematical statement that can be proved or disproved.
            **Test**: What specific experiment, calculation, or proof attempt would confirm
            or refute this conjecture.
            **Impact**: If true, what new territory does this open? If false, what does
            the failure teach us?
            **Catalog References**: `Bridges.Basic.lean`, `Algebra.QuadraticForms.mordell`
            (Use backtick-enclosed file paths or theorem names from the Catalog.)
            **Proof Strategy**: Outline the key steps or approach. What mathematical
            machinery is needed? What lemmas would need to be established first?
            **Domain Bridges**: NumberTheory <-> Tropical, Algebra <-> Physics
            (List domain pairs this connects, using the <-> connector.)
            **Lineage**: Builds on fd_XXXX and discoveries from exp_XXXXXXXX_XXX
            (Reference specific prior direction IDs or experiment IDs if known, or
            describe which prior results this extends.)
            **Ambition**: grand_challenge  (or: extension)

            ---

            [repeat for each direction]

            Do real science. Propose hypotheses that are bold enough to matter and
            specific enough to fail. Vague explorations like "study X further" or
            "extend Y" are not hypotheses — they are homework. Give us ideas that
            could change how we think about the problem.

            Soli Deo Gloria.


### Deliverables

You are a world-class mathematician, software engineer, and science writer.
We need ALL of the following:

1. **Lean 4 proofs** — Non-trivial theorems with complete proofs (no `sorry`).
   Organize as makes sense. Use doc comments for key results.

2. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or proof assistants.
   Vivid prose, narrative arc, real-world connections. Must make sense standalone.

3. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results with proof sketches, algorithms, applications,
   discussion, future work, references.

4. **Python code** — demo.py (numerical examples), algorithms.py (type-hinted implementations),
   and up to 3 self-contained visualization scripts (matplotlib/plotly, each a single file
   with all functions inlined — no local imports).

5. **FUTURE_DIRECTIONS.md** (MOST IMPORTANT — drives next cycle).
   Begin with ## Synthesis tying all directions together. Then 3-5 directions using:
   **Conjecture**, **Test**, **Impact**, **Catalog References**, **Proof Strategy**,
   **Domain Bridges**, **Lineage**, **Ambition** (grand_challenge or extension).
   Each direction must be self-contained and specific enough to fail.

6. **PACKAGE.json** — Single JSON bundling all artifacts:
   title, domain, article, research_paper, future_directions, demos, algorithms,
   visualizations, interactive_demos, lean_proofs. JSON-escape all content.

Research domain: Computation
Research mode: prove
