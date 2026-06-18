            ## Assignment: Circuit Depth Lower Bounds from Layer Profiles

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
            Conjecture: The exchange descent problem with depth-`k` certificate in dimension `d` requires Boolean circuits of depth at least `(d - k - 1) · log d` to solve.

Test: Encode small instances (d = 4, 5, 6) as Boolean satisfiability problems and measure the depth of the smallest Boolean circuit that computes the optimal descent step. Compare with the layer profile prediction.

Impact: Would connect exchange descent complexity to the central open questions of computational complexity theory (circuit depth lower bounds, the P vs NC question).

            ### Mathematical Framing
            Conjecture: The exchange descent problem with depth-`k` certificate in dimension `d` requires Boolean circuits of depth at least `(d - k - 1) · log d` to solve.

Test: Encode small instances (d = 4, 5, 6) as Boolean satisfiability problems and measure the depth of the smallest Boolean circuit that computes the optimal descent step. Compare with the layer profile prediction.

Impact: Would connect exchange descent complexity to the central open questions of computational complexity theory (circuit depth lower bounds, the P vs NC question).


            ### Existing Verified Theorems
            Existing theorems you can build on:
  1. `conjecture_linear_certificate_density_lower_bound` : theorem conjecture_linear_certificate_density_lower_bound : True := trivial
     (file: Algebra/MatrixGroupGeneration.lean)
  2. `conjecture_linear_certificate_density_lower_bound` : theorem conjecture_linear_certificate_density_lower_bound : True := trivial
     (file: FINAL/Algebra/MatrixGroupGeneration.lean)
  3. `depth_lower_bound_log` : theorem depth_lower_bound_log (C : AlgCircuit R n) (d : ℕ)
     (file: Algebra/CoordinateRingDepth.lean)
  4. `depth_lower_bound_log` : theorem depth_lower_bound_log (C : AlgCircuit R n) (d : ℕ)
     (file: FINAL/Algebra/CoordinateRingDepth.lean)
  5. `bounded_circuit_depth_size` : theorem bounded_circuit_depth_size (C : AlgCircuit R n) (b : CircuitComplexityBound R n)
     (file: Algebra/AlgebraicCircuitComplexity.lean)
  6. `barrier_step_lower_bound` : theorem barrier_step_lower_bound (n : ℕ) (f : ℕ → ℝ) (δ : ℝ) (hδ : 0 < δ)
     (file: Algebra/EnergyLandscapeMetastability.lean)
  7. `circuit_lower_bound_from_obstruction` : theorem circuit_lower_bound_from_obstruction (f : α) (B : ℕ)
     (file: Algebra/GCT/Foundation.lean)
  8. `bounded_circuit_depth_size` : theorem bounded_circuit_depth_size (C : AlgCircuit R n) (b : CircuitComplexityBound R n)
     (file: FINAL/Algebra/AlgebraicCircuitComplexity.lean)
  9. `barrier_step_lower_bound` : theorem barrier_step_lower_bound (n : ℕ) (f : ℕ → ℝ) (δ : ℝ) (hδ : 0 < δ)
     (file: FINAL/Algebra/EnergyLandscapeMetastability.lean)
  10. `grover_optimal_lower_bound` : theorem grover_optimal_lower_bound (k : ℕ) :
     (file: Algebra/GroverAttacks.lean)
  11. `grover_optimal_lower_bound` : theorem grover_optimal_lower_bound (k : ℕ) :
     (file: FINAL/Algebra/GroverAttacks.lean)
  12. `demo_depth_2_optimal` : theorem demo_depth_2_optimal : demoDepth 2 = 3 := by
     (file: Algebra/Depth.lean)
  13. `OQ_descent_step_decrease` : theorem OQ_descent_step_decrease (a b c : ℤ)
     (file: Algebra/Synthesis.lean)
  14. `emlExprIterExp_depth_optimal` : theorem emlExprIterExp_depth_optimal (n : ℕ) :
     (file: Algebra/TightDepthHierarchy/Theorems.lean)
  15. `nontrivial_H1_lower_bounds_prediction_instability` : theorem nontrivial_H1_lower_bounds_prediction_instability
     (file: Bridges/SheafProofStateDuality.lean)

### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


### Catalog Reference Files (Catalog/FINAL/ = vetted, high-quality)

(File paths starting with FINAL/ are vetted, high-quality catalog entries.)
@FINAL/Algebra/Advanced.lean
```lean
import Mathlib
import Algebra.BerggrenLorentz.Core

/-!
# Berggren-Lorentz Monoid: Advanced Structure Theory

This file extends the core Berggren-Lorentz theory with:

1. **Iterated B-branch growth**: exponential hypotenuse growth along the B-orbit
2. **Parametric Pythagorean families**: Euclid's parametrization and its connection
3. **Abstract quadratic form preservation**: monoid closure theorem
4. **Trace algebra**: product traces and spectral invariants
5. **Twin-leg triples**: the consecutive-integer subfamily
6. **Entrywise norm bounds**: elementary Lipschitz estimates

## Bridge: Algebra (monoid theory) ↔ Number Theory (Pythagorean triples, GCD)
↔ Dynamics (iterated maps) ↔ Cryptography (search space bounds)
↔ ML (lipschitz_certified_robustness via entrywise bounds)
-/

set_option maxHeartbeats 1600000

namespace BerggrenLorentz

/-! ## Section 1: Iterated B-Branch Growth -/

/-- The n-th iterated B-child starting from (3,4,5).
    This traces the B-branch of the Berggren tree. -/
def iterateB : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => childB (iterateB n).1 (iterateB n).2.1 (iterateB n).2.2

/-- The first iterated B-child of (3,4,5) is (21,20,29). -/
theorem iterateB_one : iterateB 1 = (21, 20, 29) := by
  simp only [iterateB, childB]; norm_num

/-- The second iterated B-child is (119,120,169). -/
theorem iterateB_two : iterateB 2 = (119, 120, 169) := by
  simp only [iterateB, childB]; norm_num

/-- The third iterated B-child is (697,696,985). -/
theorem iterateB_three : iterateB 3 = (697, 696, 985) := by
  simp only [iterateB, childB]; norm_num

/-- Each iterated B-child is Pythagorean.
    Proof by induction using childB_preserves_pythag.
    Bridge: dynamics (orbit closure) ↔ Diophantine invariants. -/
theorem iterateB_pythag : ∀ n, IsPythag (iterateB n).1 (iterateB n).2.1 (iterateB n).2.2 := by
  intro n; induction n with
  | zero => exact seed_is_pythag
  | succ n ih => exact childB_preserves_pythag _ _ _ ih

/-- Each iterated B-child preserves the Lorentz form at zero. -/
theorem iterateB_on_light_cone :
    ∀ n, lorentzQ (iterateB n).1 (iterateB n).2.1 (iterateB n).2.2 = 0 := by
  intro n; rw [lorentzQ_zero_iff_pythag]; exact iterateB_pythag n

/-! ## Section 2: Hypotenuse Sequence Analysis -/

/-- The hypotenuse of the n-th B-iterate. -/
-- ... (truncated, full file has 333 lines)
```

@FINAL/Algebra/AffineWords.lean
```lean
import Mathlib
import Collatz.ParityCylinders

/-!
# Affine Iteration Formula and Descent Theory

This file develops the affine structure of Collatz iterates along parity words.
The key insight is that the k-step Collatz iterate along a parity word w is an
affine function of the starting value: D · x_k = A · n + B, where A = 3^(oddCount)
and D = 2^(evenCount).

## Main results

* `v2_mod_preserved_on_odd`: The 2-adic structure of 3n+1 is determined by n mod 2^k.
* `iterate_congr_mod`: The j-th iterate mod 2^(k-j) is determined by n mod 2^k.
* `parityWord_eq_of_residue`: The parity word factors through ℤ/2^kℤ.
* `parityCylinder_partition`: Parity cylinders partition ℕ.
* `countUpTo_partition`: Total count across all cylinders equals N+1.
* `exists_descent_word`: For k ≥ 1, at least one descent word exists.
-/

namespace Collatz

/-
============================================================================
§ 1. The 2-adic structure of 3n+1 is locally determined
============================================================================

For any numbers, 3n+1 mod 2^k depends only on n mod 2^k.
    This is the foundation of 2-adic local analysis for Collatz dynamics.
-/
theorem v2_mod_preserved_on_odd (n m k : ℕ)
    (h : n % 2 ^ k = m % 2 ^ k) :
    (3 * n + 1) % 2 ^ k = (3 * m + 1) % 2 ^ k := by
  exact Nat.ModEq.add ( Nat.ModEq.mul_left _ h ) rfl

/-
============================================================================
§ 2. Iterate congruence — strengthened version
============================================================================

The j-th Collatz iterate mod 2^(k-j) is determined by n mod 2^k.
    This is the quantitative backbone of the parity cylinder theorem.
-/
theorem iterate_congr_mod (k : ℕ) (n m : ℕ) (j : ℕ) (hj : j ≤ k)
    (h : n % 2 ^ k = m % 2 ^ k) :
    step^[j] n % 2 ^ (k - j) = step^[j] m % 2 ^ (k - j) := by
  induction' j with j ih generalizing n m;
  · exact h;
  · have := step_congr_mod ( step^[j] n ) ( step^[j] m ) ( 2 ^ ( k - j - 1 ) ) ?_ ?_ <;> simp_all +decide [ Nat.pow_succ', Nat.mul_mod_mul_left ];
    · erw [ Function.iterate_succ_apply', Function.iterate_succ_apply' ] at * ; aesop;
    · convert ih n m hj.le h using 1;
      · rw [ ← pow_succ', Nat.sub_add_cancel ( Nat.sub_pos_of_lt hj ) ];
      · rw [ ← pow_succ', Nat.sub_add_cancel ( Nat.sub_pos_of_lt hj ) ]

-- ============================================================================
-- § 3. Parity word as a well-defined function on ℤ/2^k ℤ
-- ============================================================================

/-- The parity word map factors through ℤ/2^kℤ: it defines a well-posed
-- ... (truncated, full file has 139 lines)
```

@FINAL/Algebra/Agent.lean
```lean
/- Original: AgentAlpha_Invariants.lean -/



/-- The inradius numerator (a+b−c) of a Euclid triple equals 2n(m−n).
(We avoid division to stay in ℤ.) -/
theorem euclid_inradius_num (m n : ℤ) :
    let t := euclidTriple m n
    t.1 + t.2.1 - t.2.2 = 2 * n * (m - n) := by
  simp [euclidTriple]; ring

/-- The perimeter of a Euclid triple is 2m(m + n). -/
theorem euclid_perimeter (m n : ℤ) :
    let t := euclidTriple m n
    t.1 + t.2.1 + t.2.2 = 2 * m * (m + n) := by
  simp [euclidTriple]; ring

/-- The twice-area of a Euclid triple is 2mn(m² − n²) = 2mn(m−n)(m+n). -/
theorem euclid_twice_area (m n : ℤ) :
    let t := euclidTriple m n
    t.1 * t.2.1 = 2 * m * n * (m ^ 2 - n ^ 2) := by
  simp [euclidTriple]; ring

/-- The twice-area factors as 2mn(m−n)(m+n). -/
theorem euclid_twice_area_factored (m n : ℤ) :
    2 * m * n * (m ^ 2 - n ^ 2) = 2 * m * n * (m - n) * (m + n) := by ring

/-- Key identity: (a + b − c)(a + b + c) = 2ab for Pythagorean triples. -/
theorem pyth_inradius_identity (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + b - c) * (a + b + c) = 2 * a * b := by nlinarith [sq_nonneg (a + b - c)]

/-- a + b − c ≥ 0 when a, b, c > 0 and a² + b² = c². -/
theorem pyth_sum_minus_hyp_nonneg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : 0 ≤ a + b - c := by
  nlinarith [sq_nonneg (a + b - c)]

/-- a + b > c for positive Pythagorean triples (strict triangle inequality). -/
theorem pyth_triangle_strict (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : c < a + b := by
  nlinarith [sq_nonneg (a - b)]

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentAlpha_Invariants
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 28] -/
theorem pyth_inradius_even (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 ∣ (a + b - c) := by
  exact even_iff_two_dvd.mp ( by apply_fun Even at *; simp_all +decide [ parity_simps ] )

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentAlpha_Invariants
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 28] -/
theorem consecutive_even (k : ℤ) : 2 ∣ k * (k + 1) := by
  exact even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] )

theorem euclid_leg_product_div4 (m n : ℤ) :
    4 ∣ (m ^ 2 - n ^ 2) * (2 * m * n) := by
  have : (m ^ 2 - n ^ 2) * (2 * m * n) = 2 * m * n * (m - n) * (m + n) := by ring
  rw [this]
-- ... (truncated, full file has 456 lines)
```

@FINAL/Algebra/AlgebraicCircuitComplexity.lean
```lean
/-
  # Algebraic Circuit Complexity — Core Definitions and Foundational Lemmas

  Bridge: connects Algebra (polynomial rings, ideals) to Computation (circuit complexity).

  This file introduces algebraic circuits as an inductive type over commutative semirings,
  defines evaluation semantics, structural invariants (depth, size, degree bound),
  and proves foundational bounds relating these invariants.

  Key results:
  - Degree of a circuit-computed polynomial ≤ 2^depth (exponential degree-depth tradeoff)
  - Size ≥ depth + 1 (work ≥ span)
  - Evaluation semantics agree with MvPolynomial interpretation
  - Circuit addition/multiplication preserve structural bounds
  - Zero-function circuits form an ideal (closure under add/mul)
-/

import Mathlib

namespace AlgebraicCircuitComplexity

/-! ## Core Circuit Definition

An `AlgCircuit R n` represents a straight-line program over a commutative semiring `R`
with variables indexed by `Fin n`. This is the standard model in algebraic complexity theory.

Bridge: connects Algebra (polynomial ring `R[x₁,...,xₙ]`) to Computation (straight-line programs). -/

/-- An algebraic circuit over a commutative semiring `R` with `n` input variables.
    Each gate computes either a constant, a variable, or an addition/multiplication
    of two sub-circuits. This is the standard algebraic circuit model (Valiant 1979).

    Bridge: connects Algebra (polynomial evaluation) to Computation (circuit complexity). -/
inductive AlgCircuit (R : Type*) [CommSemiring R] (n : ℕ) : Type _ where
  | const : R → AlgCircuit R n
  | var : Fin n → AlgCircuit R n
  | add : AlgCircuit R n → AlgCircuit R n → AlgCircuit R n
  | mul : AlgCircuit R n → AlgCircuit R n → AlgCircuit R n
  deriving Inhabited

variable {R : Type*} [CommSemiring R] {n : ℕ}

/-! ## Evaluation Semantics -/

/-- Evaluate an algebraic circuit on an assignment of values to variables.
    This is the semantic function mapping circuits to the functions they compute.

    Bridge: connects Computation (circuit execution) to Algebra (polynomial evaluation). -/
def AlgCircuit.eval (C : AlgCircuit R n) (v : Fin n → R) : R :=
  match C with
  | .const r => r
  | .var i => v i
  | .add C₁ C₂ => C₁.eval v + C₂.eval v
  | .mul C₁ C₂ => C₁.eval v * C₂.eval v

/-! ## Structural Invariants -/

/-- The depth of an algebraic circuit — the length of the longest root-to-leaf path.
    Depth corresponds to parallel time complexity.

-- ... (truncated, full file has 469 lines)
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

Research domain: Algebra
Research mode: prove
