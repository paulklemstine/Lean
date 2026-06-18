
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are leading a research team: Hypothesizer, Experimenter, Analyst,
Critic, and Synthesist. Run the loop:
Hypothesize -> Experiment -> Analyze -> Critique -> Generalize -> Iterate.
Your ONLY job is to produce **new Lean 4 code** and **take good notes**
for the next team.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by theorem declarations)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.
5. **Lab Notebook** as `-- !-- Lab Notebook -- !--` comment blocks
   in each .lean file: Hypothesis, Result, Insight, Failure analysis.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.

            ### CATALOG SYNTHESIS (required — read the catalog context below):
            The Catalog Context and Recent Discoveries sections list existing theorems
            already proven in this project. You MUST analyze these and combine concepts
            from the catalog with the research direction above. Specifically:

            1. **Identify relevant catalog theorems** — Which existing results connect
               to your research direction? Cite them by name in your proof sketches.
            2. **Build on catalog foundations** — Your theorems should EXTEND or
               GENERALIZE catalog results, not reprove them from scratch. Use `import`
               and reference existing definitions and lemmas where possible.
            3. **Combine concepts across domains** — The most valuable theorems connect
               ideas from different catalog domains (e.g., applying algebraic structures
               to topological problems, or using combinatorial arguments in number theory).
               Look for cross-domain connections in the catalog context.
            4. **Avoid duplication** — Check the catalog context before proving. If a
               similar result already exists, extend it rather than reproving it.


## Concept

**Title**: This cycle isolated the *group-theoretic engine* underneath the conjecture that
**Domain**: Applications
**Mathematical framing**: # Future Directions — Monodromy-Driven Quantum Advantage in Hypergeometric Period Sampling

## Synthesis of this cycle

This cycle isolated the *group-theoretic engine* underneath the conjecture that
non-virtually-solvable monodromy of rigid hypergeometric local systems is a
source of provable quantum advantage. Rather than chase the full
complexity-theoretic separation (which is currently out of reach of any formal
system), we extracted the parts that are genuinely *true and provable now*, and
proved them with zero `sorry`:

* **The non-solvable core** (`FreeMonodromy.lean`). The fundamental group of the
  thrice-punctured sphere is free; we proved `FreeGroup (Fin 2)` is **not
  solvable** by exhibiting a surjection onto `S₅` (a 5-cycle and an adjacent
  transposition generate it) and transporting non-solvability backwards. From
  this, `faithful_monodromy_not_solvable` shows that *any faithful* monodromy
  representation already has a non-solvable image — the geometric "rigidity =
  faithfulness" hypothesis is exactly the input that makes the monodromy
  non-virtually-solvable.

* **The classical/quantum dichotomy** (`classical_phase_blindness`,
  `phase_blind_to_commutator`). Every *abelian phase character* — the only thing
  a classical period-phase sampler can read — annihilates the commutator
  subgroup, which is nonetheless non-trivial. So the non-abelian (non-solvable)
  content of the monodromy is provably invisible to phase sampling. This is the
  formal kernel of the conjectured gap: abelian data is classically simulable,
  the non-abelian remainder is not.

* **A concrete realisation** (`HypergeometricTriangle.lean`). The puncture
  relation `γ₀γ₁γ∞ = 1` is realised by explicit *integer* `SL₂` matrices (the
  Sanov pair and the inverse of their product); the monodromy is non-abelian and
  unimodular, and the eigenvalue *period phase* is shown to add along composed
  loops in `ℝ/2πℤ = Real.Angle`, the quantum phase-estimation register.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `freeGroup_two_not_solvable` | the free monodromy group of two loops is not solvable | proved |
| `faithful_monodromy_not_solvable` | faithful monodromy ⟹ non-solvable structure group | proved |
| `faithful_monodromy_range_not_solvable` | the faithful monodromy image is non-solvable | proved |
| `classical_phase_blindness` | a non-trivial loop killed by every abelian phase character | proved |
| `monodromy_triangle_relation` | `M₀ M₁ M∞ = 1` over `ℤ` | proved |
| `monodromy_noncommutative` / `monodromy_unimodular` | non-abelian, `SL₂` | proved |
| `monodromy_phase_additive` | period phases add along loops in `ℝ/2πℤ` | proved |

## Bold, falsifiable research directions

### 1. Sanov faithfulness: the missing geometric input, formalised by ping-pong
**Conjecture.** The lift `FreeGroup (Fin 2) →* SL₂(ℤ)` sending the generators to
`[[1,2],[0,1]]` and `[[1,0],[2,1]]` is **injective**; consequently, by
`faithful_monodromy_range_not_solvable`, the Legendre/hypergeometric monodromy
group is non-solvable on the nose, not merely conditionally.
**The key insight is** that Mathlib already ships
`FreeGroup.injective_lift_of_ping_pong`, so the only thing to supply is the two
cones `X = {|x| > |y|}`, `Y = {|x| < |y|}` in `ℝ²` and the inequalities showing
`a^{±1}` map the complement of one into the other — a finite analytic checklist,
not new theory.
**Why now?** This cycle proved every *conditional* consequence of faithfulness;
discharging the single ping-pong hypothesis would upgrade all of them to
unconditional theorems and is the highest-leverage next step.
**Falsifiable:** if any reduced word maps to the identity matrix, the conjecture
(and Sanov's theorem) is refuted.

### 2. Exponential word growth as a complexity lower-bound certificate
**Conjecture.** The faithful monodromy group has **exponential growth**: the
number of distinct matrices reachable by reduced words of length `≤ n` is
`≥ 3·2^{n-1}`, and this growth rate is preserved by the eigenvalue-phase map only
on the abelianized quotient (polynomial growth `~ n²`).
**The key insight is** that growth rate is a *quasi-isometry invariant* that
separates the full monodromy (free, exponential) from its phase shadow (abelian,
polynomial) — turning the qualitative "classical blindness" of this cycle into a
quantitative `exp` vs `poly` gap that mirrors the conjectured runtime separation.
**Why now?** `freeGroup_two_not_solvable` and `classical_phase_blindness` give
both endpoints; a growth-counting lemma over reduced words is elementary and
makes the separation numerical and testable.
**Falsifiable:** any sub-exponential bound on reduced-word images refutes it.

### 3. Phase-character cohomology classifies the simulable layer exactly
**Conjecture.** The group of phase characters `Hom(π₁, Circle)` is naturally
isomorphic to `Hom(H₁(ℙ¹∖S; ℤ), Circle)`, i.e. the classically simulable layer is
*exactly* `H¹` of the punctured curve, with the commutator subgroup spanning the
entire non-simulable remainder.
**The key insight is** that `Abelianization.lift` makes "phase character" and
"first cohomology class" the same object, so the classical/quantum cut coincides
with the `H¹` vs higher-monodromy filtration — a precise, structural home for the
informal "abelian = easy" intuition.
**Why now?** `phase_character_kills_commutator` already proves one containment;
the reverse (every abelianization character lifts to a phase character) is a
direct application of the universal property and closes the classification.
**Falsifiable:** a phase character not factoring through `H₁`, or a commutator
detected by some character, refutes it.

### 4. Rigidity transfer: solvable monodromy ⟹ classically samplable phases
**Conjecture.** For the *complementary* regime — one-parameter families whose
monodromy is virtually solvable (e.g. resonant/degenerate hypergeometric
parameters) — the period-phase sampling problem reduces to a polynomial-time
classical computation, because solvable groups are built from abelian layers each
of which is phase-detectable.
**The key insight is** that solvability is the exact negation of the obstruction
proved here: where `freeGroup_two_not_solvable` blocks classical simulation,
a solvable derived series provides a *finite tower of phase characters* that
reconstructs the whole representation.
**Why now?** Mathlib's `derivedSeries`/`IsSolvable` API lets one induct on the
solvable length; pairing it with this cycle's phase-additivity lemma yields a
clean "solvable ⟹ samplable" companion theorem, completing the dichotomy.
**Falsifiable:** a solvable monodromy family with provably hard phase sampling
refutes it.

### 5. Arithmetic monodromy and a Galois-action obstruction to dequantization
**Conjecture.** When the hypergeometric parameters are rational, the monodromy
matrices lie in `SL₂` over a number field and the absolute Galois group acts on
the phase data; the orbit of a period phase under this action is polynomially
bounded iff the monodromy is solvable, giving an *arithmetic* certificate of
quantum hardness independent of the geometric one.
**The key insight is** that the integer realisation in `HypergeometricTriangle.lean`
already lives over `ℤ ⊂ ℚ̄`, so the Galois action is concrete, and non-solvable
monodromy forces large Galois orbits — converting a geometric obstruction into an
arithmetic one and connecting to the catalog's `Algebra/ZetaZeroFree` and
L-function threads.
**Why now?** The explicit unimodular integer matrices make the number-theoretic
side fully computable today; even the rank-1 (phase) case is a tractable first
theorem about cyclotomic orbits of `Complex.arg` values.
**Falsifiable:** a non-solvable rational family with uniformly small Galois phase
orbits refutes it.

**Concept description**: # Future Directions — Monodromy-Driven Quantum Advantage in Hypergeometric Period Sampling

## Synthesis of this cycle

This cycle isolated the *group-theoretic engine* underneath the conjecture that
non-virtually-solvable monodromy of rigid hypergeometric local systems is a
source of provable quantum advantage. Rather than chase the full
complexity-theoretic separation (which is currently out of reach of any formal
system), we extracted the parts that are genuinely *true and provable now*, and
proved them with zero `sorry`:

* **The non-solvable core** (`FreeMonodromy.lean`). The fundamental group of the
  thrice-punctured sphere is free; we proved `FreeGroup (Fin 2)` is **not
  solvable** by exhibiting a surjection onto `S₅` (a 5-cycle and an adjacent
  transposition generate it) and transporting non-solvability backwards. From
  this, `faithful_monodromy_not_solvable` shows that *any faithful* monodromy
  representation already has a non-solvable image — the geometric "rigidity =
  faithfulness" hypothesis is exactly the input that makes the monodromy
  non-virtually-solvable.

* **The classical/quantum dichotomy** (`classical_phase_blindness`,
  `phase_blind_to_commutator`). Every *abelian phase character* — the only thing
  a classical period-phase sampler can read — annihilates the commutator
  subgroup, which is nonetheless non-trivial. So the non-abelian (non-solvable)
  content of the monodromy is provably invisible to phase sampling. This is the
  formal kernel of the conjectured gap: abelian data is classically simulable,
  the non-abelian remainder is not.

* **A concrete realisation** (`HypergeometricTriangle.lean`). The puncture
  relation `γ₀γ₁γ∞ = 1` is realised by explicit *integer* `SL₂` matrices (the
  Sanov pair and the inverse of their product); the monodromy is non-abelian and
  unimodular, and the eigenvalue *period phase* is shown to add along composed
  loops in `ℝ/2πℤ = Real.Angle`, the quantum phase-estimation register.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `freeGroup_two_not_solvable` | the free monodromy group of two loops is not solvable | proved |
| `faithful_monodromy_not_solvable` | faithful monodromy ⟹ non-solvable structure group | proved |
| `faithful_monodromy_range_not_solvable` | the faithful monodromy image is non-solvable | proved |
| `classical_phase_blindness` | a non-trivial loop killed by every abelian phase character | proved |
| `monodromy_triangle_relation` | `M₀ M₁ M∞ = 1` over `ℤ` | proved |
| `monodromy_noncommutative` / `monodromy_unimodular` | non-abelian, `SL₂` | proved |
| `monodromy_phase_additive` | period phases add along loops in `ℝ/2πℤ` | proved |

## Bold, falsifiable research directions

### 1. Sanov faithfulness: the missing geometric input, formalised by ping-pong
**Conjecture.** The lift `FreeGroup (Fin 2) →* SL₂(ℤ)` sending the generators to
`[[1,2],[0,1]]` and `[[1,0],[2,1]]` is **injective**; consequently, by
`faithful_monodromy_range_not_solvable`, the Legendre/hypergeometric monodromy
group is non-solvable on the nose, not merely conditionally.
**The key insight is** that Mathlib already ships
`FreeGroup.injective_lift_of_ping_pong`, so the only thing to supply is the two
cones `X = {|x| > |y|}`, `Y = {|x| < |y|}` in `ℝ²` and the inequalities showing
`a^{±1}` map the complement of one into the other — a finite analytic checklist,
not new theory.
**Why now?** This cycle proved every *conditional* consequence of faithfulness;
discharging the single ping-pong hypothesis would upgrade all of them to
unconditional theorems and is the highest-leverage next step.
**Falsifiable:** if any reduced word maps to the identity matrix, the conjecture
(and Sanov's theorem) is refuted.

### 2. Exponential word growth as a complexity lower-bound certificate
**Conjecture.** The faithful monodromy group has **exponential growth**: the
number of distinct matrices reachable by reduced words of length `≤ n` is
`≥ 3·2^{n-1}`, and this growth rate is preserved by the eigenvalue-phase map only
on the abelianized quotient (polynomial growth `~ n²`).
**The key insight is** that growth rate is a *quasi-isometry invariant* that
separates the full monodromy (free, exponential) from its phase shadow (abelian,
polynomial) — turning the qualitative "classical blindness" of this cycle into a
quantitative `exp` vs `poly` gap that mirrors the conjectured runtime separation.
**Why now?** `freeGroup_two_not_solvable` and `classical_phase_blindness` give
both endpoints; a growth-counting lemma over reduced words is elementary and
makes the separation numerical and testable.
**Falsifiable:** any sub-exponential bound on reduced-word images refutes it.

### 3. Phase-character cohomology classifies the simulable layer exactly
**Conjecture.** The group of phase characters `Hom(π₁, Circle)` is naturally
isomorphic to `Hom(H₁(ℙ¹∖S; ℤ), Circle)`, i.e. the classically simulable layer is
*exactly* `H¹` of the punctured curve, with the commutator subgroup spanning the
entire non-simulable remainder.
**The key insight is** that `Abelianization.lift` makes "phase character" and
"first cohomology class" the same object, so the classical/quantum cut coincides
with the `H¹` vs higher-monodromy filtration — a precise, structural home for the
informal "abelian = easy" intuition.
**Why now?** `phase_character_kills_commutator` already proves one containment;
the reverse (every abelianization character lifts to a phase character) is a
direct application of the universal property and closes the classification.
**Falsifiable:** a phase character not factoring through `H₁`, or a commutator
detected by some character, refutes it.

### 4. Rigidity transfer: solvable monodromy ⟹ classically samplable phases
**Conjecture.** For the *complementary* regime — one-parameter families whose
monodromy is virtually solvable (e.g. resonant/degenerate hypergeometric
parameters) — the period-phase sampling problem reduces to a polynomial-time
classical computation, because solvable groups are built from abelian layers each
of which is phase-detectable.
**The key insight is** that solvability is the exact negation of the obstruction
proved here: where `freeGroup_two_not_solvable` blocks classical simulation,
a solvable derived series provides a *finite tower of phase characters* that
reconstructs the whole representation.
**Why now?** Mathlib's `derivedSeries`/`IsSolvable` API lets one induct on the
solvable length; pairing it with this cycle's phase-additivity lemma yields a
clean "solvable ⟹ samplable" companion theorem, completing the dichotomy.
**Falsifiable:** a solvable monodromy family with provably hard phase sampling
refutes it.

### 5. Arithmetic monodromy and a Galois-action obstruction to dequantization
**Conjecture.** When the hypergeometric parameters are rational, the monodromy
matrices lie in `SL₂` over a number field and the absolute Galois group acts on
the phase data; the orbit of a period phase under this action is polynomially
bounded iff the monodromy is solvable, giving an *arithmetic* certificate of
quantum hardness independent of the geometric one.
**The key insight is** that the integer realisation in `HypergeometricTriangle.lean`
already lives over `ℤ ⊂ ℚ̄`, so the Galois action is concrete, and non-solvable
monodromy forces large Galois orbits — converting a geometric obstruction into an
arithmetic one and connecting to the catalog's `Algebra/ZetaZeroFree` and
L-function threads.
**Why now?** The explicit unimodular integer matrices make the number-theoretic
side fully computable today; even the rank-1 (phase) case is a tractable first
theorem about cyclotomic orbits of `Complex.arg` values.
**Falsifiable:** a non-solvable rational family with uniformly small Galois phase
orbits refutes it.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Applications
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v9 Depth Requirements -- Adversarial Ground-Truth Research Engine

You are leading a mathematical research team. Your goal is to produce groundbreaking,
master-class, useful, novel, and marvelous new Mathematics that pushes the frontier of human knowledge.

This engine is configured for **Adversarial Ground-Truth**. Trust nothing, assume everything is false until proven, and actively seek weaknesses. Think like an Adversarial Critic to pressure-test claims.

### RESEARCH CORE METHODOLOGY:
1. **Challenge Assumptions**: For every conjecture or theorem under investigation, actively search for counterexamples, corner cases, and boundary conditions. Proving that a claim is FALSE or identifying exactly where it fails is as valuable as a proof.
2. **Stress-Test the Frontier**: When a proof succeeds, push it to its limits. What happens if you drop or if a hypothesis is weakened? Write explicit comments documenting these boundary conditions.
3. **Relentless Rigor**: Write robust, clean, compilable Lean 4 proofs. Avoid trivial tautologies or simple wrapper theorems. Let your mathematical curiosity drive deep structural insights.

### DELIVERABLES:
- **Lean 4 proofs** of deep, non-trivial theorems with complete proofs (no sorry on main results).
- **Lab Notebook** comment blocks in each .lean file detailing Hypothesis, Result, Insight, and Failure analysis.
- **FUTURE_DIRECTIONS.md** outlining the Synthesis of your findings, a Results Summary, and 3-5 bold, falsifiable research directions to steer the next cycle.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
