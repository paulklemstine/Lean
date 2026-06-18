
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "descriptive_name", "description": "What this demo shows", "code": "# full Python source..."}
  ],
  "algorithms": [
    {"name": "descriptive_name", "pseudocode": "Brief description", "code": "# full Python source..."}
  ],
  "visualizations": [
    {"name": "descriptive_name", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Interactive Widget Title", "description": "What users can explore", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: The EBC framework now spans three files with 0 sorry's:
**Domain**: Bridges
**Mathematical framing**: # Future Directions: Entropy-Bounded Computation Framework

## What Was Built

The EBC framework now spans three files with 0 sorry's:

- **Defs.lean**: Core structures (LandauerParams, EntropyBudgetSystem, IrreversibleStep, StepSequence, ReversibleComputation, MaxwellDemon, SearchProblem)
- **Theorems.lean**: 15 theorems including `step_count_bounded_by_budget`, `exp_eventually_exceeds_poly`, `entropy_gap_unbounded`, `demon_cost_additive`, `reversible_forward_bijective`, `budget_monotone`, and more
- **Quantum.lean**: 8 theorems/definitions including `quantum_circuit_cost`, `gate_count_decomposition`, `measurement_budget_bound`, `unitary_compose_free`

All proofs compile cleanly with only standard axioms (propext, Classical.choice, Quot.sound).

---

## Direction 1: Entropy Hierarchy Theorem via Diagonalization

The `step_count_bounded_by_budget` theorem bounds the number of computational steps within an entropy budget, and `entropy_gap_unbounded` shows exponential search dominates polynomial. The next step is a proper hierarchy theorem: define ENTROPY(f) as the class of problems solvable with entropy budget f(n)·tempFactor, then prove strict containment ENTROPY(n^k) ⊊ ENTROPY(n^(k+1)).

The key insight is that the universal simulation argument needs only polynomial overhead — a simulator with n^(k+1) budget can simulate all n^k-bounded computations and diagonalize against them, because `entropy_gap_unbounded` provides the asymptotic room. This would be the first formally verified entropy hierarchy theorem, analogous to the time hierarchy theorem but in the Landauer cost model.

Why now? The gap theorem and budget bound are already proved. What remains is formalizing a universal simulator as a StepSequence transformer and proving its overhead is polynomial. The EBC framework's additive cost model makes this cleaner than classical time hierarchy proofs because there's no constant-factor overhead from simulation.

---

## Direction 2: Thermodynamic Sorting Lower Bound

Comparison-based sorting requires Ω(n log n) comparisons. Each comparison is an IrreversibleStep erasing 1 bit (it bisects the space of permutations). Using `step_count_bounded_by_budget` with minBits = 1, the number of comparisons is bounded by budget/tempFactor. Setting the budget equal to the Landauer cost of sorting n! permutations gives a lower bound of ⌈log₂(n!)⌉ comparisons.

The key insight is that this gives a *thermodynamic* proof of the sorting lower bound: the information-theoretic argument (n! permutations require log₂(n!) bits to distinguish) is equivalent to a Landauer cost argument (sorting dissipates at least log₂(n!) · kT·ln(2) energy). Formalizing this bridge would unify two independently discovered lower bound techniques.

Why now? The `step_count_bounded_by_budget` theorem provides exactly the mechanism needed. The missing piece is formalizing `ComparisonSort n` as a StepSequence where each step has bitsErased = 1 and proving that any valid sorting procedure for n elements requires at least ⌈log₂(n!)⌉ steps. Stirling's approximation (already in Mathlib as bounds on log of factorials) would give the Ω(n log n) form.

---

## Direction 3: Bennett's Reversible Simulation and Time-Entropy Tradeoff

The `reversible_compose` definition shows reversible computations compose at zero entropy cost. Bennett's theorem (1973) shows any T-step irreversible computation can be simulated reversibly in O(T^(1+ε)) time. This creates a Pareto frontier: you can trade entropy budget for time.

The key insight is formalizing this as a function `bennett_simulate : StepSequence params → ReversibleComputation α × ℕ` where the ℕ is the time overhead, and proving that the output ReversibleComputation has zero Landauer cost (by `reversible_compose`) while the time overhead satisfies a quantitative bound. The tradeoff curve — for entropy budget B < T·tempFactor, minimum simulation time is Ω(T²/B) — would follow from a counting argument on pebbling strategies.

Why now? The `ReversibleComputation` structure and zero-cost theorems are in place. The pebble game formalization requires only natural number arithmetic on a graph (the computation DAG). The EBC framework's clean separation between cost (measured in tempFactor units) and time (measured in step counts) makes the tradeoff analysis tractable.

---

## Direction 4: Quantum Measurement Complexity and Deferred Measurement

The `quantum_circuit_cost` theorem shows total cost equals measurementCount × tempFactor. The deferred measurement principle states that any quantum circuit can be rearranged so all measurements occur at the end, without changing the computation's outcome or total cost.

The key insight is that formalizing this requires a notion of quantum circuit *equivalence* — two circuits are equivalent if they produce the same measurement statistics. The deferred measurement transformation preserves measurement count (hence cost by `quantum_circuit_cost`) while reordering gates. This would give the first formally verified proof that quantum computation's entropy cost depends only on the number of classical bits extracted, not on when they're extracted.

Why now? The `QuantumCircuit` structure and `quantum_circuit_cost` theorem provide the cost model. What's needed is a `CircuitEquivalence` relation (same measurement statistics) and a constructive proof that any circuit can be transformed to deferred form while preserving this equivalence. The `gate_count_decomposition` theorem already shows the counting infrastructure works.

---

## Direction 5: Cryptographic Brute-Force Entropy Bound

The `demon_cost_additive` theorem shows sequential information-gathering operations have cumulative cost. A brute-force search of an n-bit key space requires 2^n measurements (one per candidate key), and `entropy_gap_unbounded` shows this cost exceeds any polynomial budget for large n.

The key insight is that this gives a *physical* lower bound on brute-force cryptanalysis: at temperature T, searching an n-bit key space costs at least 2^n · kT·ln(2) joules. At room temperature, a 256-bit key space requires ≈ 10^56 joules — more than the Sun's lifetime energy output. Formalizing this connects the EBC framework to post-quantum cryptographic security by showing that Grover's quadratic speedup (2^(n/2) measurements) gives a concrete, physically meaningful advantage.

Why now? The `demon_cost_scaling` theorem already shows cost scales linearly with measurements. The `entropy_gap_unbounded` theorem provides the polynomial-exponential separation. Connecting these to a formal `BruteForceSearch n` definition and proving the physical energy bound requires only arithmetic on the concrete Landauer parameters (kB ≈ 1.38 × 10^-23 J/K, T ≈ 300 K).

Research domain: Bridges
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/EBC/Defs.lean
import Mathlib

/-!
# Entropy-Bounded Computation (EBC): Core Definitions

This file develops a small but rigorous framework for reasoning about the
*thermodynamic* cost of computation in the spirit of Landauer's principle:
every irreversible bit erasure dissipates at least `kB · T · ln 2` joules of
energy.  We package this into an algebra of "computation steps" carrying an
entropy (bit-erasure) budget, and use it to derive genuine arithmetic and
asymptotic lower bounds in `Theorems.lean` and `Quantum.lean`.

## Design

* `LandauerParams`   — physical constants (Boltzmann constant, temperature).
* `EntropyBudgetSystem` — an abstract energy budget with a positive per-bit cost.
* `IrreversibleStep` / `StepSequence` — the additive cost model.
* `ReversibleComputation` — zero-cost (bijective) computation.
* `MaxwellDemon` — a sequential information-gathering process.
* `SearchProblem` — brute-force search over an `n`-bit key space.

`Bridges` domain: this file bridges thermodynamics (Landauer), information
theory (bit counting) and complexity theory (step counts / search).
-/

namespace EBC

/-- Physical Landauer parameters: a positive Boltzmann constant `kB` and a
positive absolute temperature `T`. -/
structure LandauerParams where
  kB : ℝ
  T : ℝ
  kB_pos : 0 < kB
  T_pos : 0 < T

/-- The Landauer energy cost of erasing a single bit: `kB · T · ln 2`. -/
noncomputable def LandauerParams.tempFactor (p : LandauerParams) : ℝ :=
  p.kB * p.T * Real.log 2

/-- An abstract entropy-budget system: a nonnegative energy `budget` together
with a positive per-bit dissipation cost `tempFactor`. -/
structure EntropyBudgetSystem where
  budget : ℝ
  tempFactor : ℝ
  budget_nonneg : 0 ≤ budget
  tempFactor_pos : 0 < tempFactor

/-- A single irreversible computation step, characterised by the number of
bits it erases. -/
structure IrreversibleStep where
  bitsErased : ℕ

/-- A sequence of irreversible steps. -/
abbrev StepSequence := List IrreversibleStep

/-- Total number of bits erased by a step sequence. -/
def StepSequence.totalBits (seq : StepSequence) : ℕ :=
  (seq.map IrreversibleStep.bitsErased).sum

/-- Total Landauer energy cost of a step sequence at per-bit cost `tf`. -/
noncomputable def StepSequence.totalCost (seq : StepSequence) (tf : ℝ) : ℝ :=
  (seq.totalBits : ℝ) * tf

/-- A reversible computation on `α`: a bijection (information-preserving), and
hence of zero Landauer cost. -/
structure ReversibleComputation (α : Type*) where
  forward : α ≃ α

/-- Sequential composition of reversible computations. -/
def ReversibleComputation.comp {α : Type*}
    (g f : ReversibleComputation α) : ReversibleComputation α :=
  ⟨f.forward.trans g.forward⟩

/-- The (always zero) Landauer cost of a reversible computation. -/
def ReversibleComputation.cost {α : Type*} (_ : ReversibleComputation α) : ℝ := 0

/-- A Maxwell demon performing `measurementCount` measurements, each extracting
`bitsPerMeasurement` bits of information (which must eventually be erased). -/
structure MaxwellDemon where
  measurementCount : ℕ
  bitsPerMeasurement : ℕ

/-- The total bits a demon must erase. -/
def MaxwellDemon.totalBits (d : MaxwellDemon) : ℕ :=
  d.measurementCount * d.bitsPerMeasurement

/-- The Landauer cost paid by a demon at per-bit cost `tf`. -/
noncomputable def MaxwellDemon.cost (d : MaxwellDemon) (tf : ℝ) : ℝ :=
  (d.totalBits : ℝ) * tf

/-- Concatenating two demons (running one after the other). -/
def MaxwellDemon.append (d e : MaxwellDemon) : MaxwellDemon :=
  ⟨d.measurementCount + e.measurementCount, 1⟩

/-- A brute-force search problem over an `n`-bit key space. -/
structure SearchProblem where
  keyBits : ℕ

/-- The number of candidate keys to test: `2 ^ keyBits`. -/
def SearchProblem.candidates (P : SearchProblem) : ℕ := 2 ^ P.keyBits

/-- A brute-force search as a step sequence: one bit-erasing step per
candidate key tested. -/
def SearchProblem.bruteForce (P : SearchProblem) : StepSequence :=
  List.replicate P.candidates ⟨1⟩

end EBC



-- NEW_FILE: Catalog/Bridges/EBC/Quantum.lean
import Bridges.EBC.Defs

/-!
# Entropy-Bounded Computation (EBC): Quantum Circuits

We extend the EBC cost model to quantum circuits.  The key thermodynamic fact is
that unitary (reversible) gates are *free* — only measurements, which extract
classical bits that must ultimately be erased, carry Landauer cost.  Thus the
entropy cost of a quantum computation depends only on the number of classical
bits it extracts, not on the number of gates or on *when* the measurements occur.

## Main results

* `QuantumCircuit.cost` — cost is `measurementCount · tf`, independent of gates.
* `unitary_compose_free` — a measurement-free circuit has zero cost.
* `quantum_cost_additive` — cost is additive over circuit composition.
* `measurement_budget_bound` — a budget caps the number of measurements.
* `deferred_measurement_cost_invariant` — deferring all measurements to the end
  preserves the total Landauer cost (a formal deferred-measurement principle at
  the level of cost accounting).
-/

namespace EBC

/-- A quantum circuit, abstracted by its gate count and measurement count. -/
structure QuantumCircuit where
  gateCount : ℕ
  measurementCount : ℕ

/-- Landauer cost of a quantum circuit: unitary gates are free, each measurement
costs one bit erasure. -/
noncomputable def QuantumCircuit.cost (c : QuantumCircuit) (tf : ℝ) : ℝ :=
  (c.measurementCount : ℝ) * tf

/-- Composition of quantum circuits: gate and measurement counts add. -/
def QuantumCircuit.comp (c d : QuantumCircuit) : QuantumCircuit :=
  ⟨c.gateCount + d.gateCount, c.measurementCount + d.measurementCount⟩

/-- The deferred-measurement transform: push every measurement to the end.  At
the level of cost accounting this only reshuffles gates and measurements, leaving
both counts unchanged. -/
def QuantumCircuit.defer (c : QuantumCircuit) : QuantumCircuit :=
  ⟨c.gateCount, c.measurementCount⟩

-- !-- Lab Notebook: quantum_circuit_cost / gate independence -- !--
-- !-- Hypothesis: Quantum entropy cost is measurementCount·tf, independent of gates. -- !--
-- !-- Result: Holds by definition of cost; the content is that two circuits with -- !--
-- !-- equal measurement counts have equal cost regardless of gate count. -- !--
-- !-- Insight: Reversibility of unitaries is the quantum analogue of EBC's -- !--
-- !-- ReversibleComputation zero-cost principle. -- !--
-- !-- Failure analysis: none. -- !--
-- !-- End Lab Notebook -- !--

/-- **Gate independence of cost.** Two circuits with the same number of
measurements have the same Landauer cost, irrespective of their gate counts. -/
theorem quantum_circuit_cost (g₁ g₂ m : ℕ) (tf : ℝ) :
    QuantumCircuit.cost ⟨g₁, m⟩ tf = QuantumCircuit.cost ⟨g₂, m⟩ tf := rfl

/-- A measurement-free (purely unitary) circuit has zero Landauer cost. -/
theorem unitary_compose_free (g : ℕ) (tf : ℝ) :
    QuantumCircuit.cost ⟨g, 0⟩ tf = 0 := by
  simp [QuantumCircuit.cost]

-- !-- Lab Notebook: quantum_cost_additive -- !--
-- !-- Hypothesis: Cost is additive over circuit composition. -- !--
-- !-- Result: Proved from comp adding measurement counts and add_mul. -- !--
-- !-- Insight: Mirrors totalCost_append; the quantum and classical cost models -- !--
-- !-- are the same additive monoid hom into (ℝ, +). -- !--
-- !-- Failure analysis: none. -- !--
-- !-- End Lab Notebook -- !--

/-- Quantum cost is additive over circuit composition. -/
theorem quantum_cost_additive (c d : QuantumCircuit) (tf : ℝ) :
    (c.comp d).cost tf = c.cost tf + d.cost tf := by
  unfold QuantumCircuit.comp QuantumCircuit.cost
  push_cast
  ring

/-- **Measurement budget bound.** A circuit whose cost is within budget `B`
satisfies `measurementCount · tf ≤ B` (so at most `B / tf` measurements when
`tf > 0`). -/
theorem measurement_budget_bound (c : QuantumCircuit) (tf : ℝ)
    (B : ℝ) (hB : c.cost tf ≤ B) : (c.measurementCount : ℝ) * tf ≤ B := hB

-- !-- Lab Notebook: deferred_measurement_cost_invariant -- !
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Entropy-Bounded Computation (EBC)

## Synthesis

This cycle built the Entropy-Bounded Computation framework from a cold start as a
*bridge* between thermodynamics (Landauer's principle), information theory (bit
counting) and computational complexity (step / measurement counts and search).
The framework lives in three files — `Defs.lean` (structures), `Theorems.lean`
(13 results) and `Quantum.lean` (5 results) — and every result compiles with only
the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via
`#print axioms`). There are **zero `sorry`s**, including in supporting lemmas.

The structural insight that emerged is that *cost is an additive monoid
homomorphism out of the free monoid of computation steps*. Both the classical
cost model (`totalCost_append`) and the quantum one (`quantum_cost_additive`) are
literally the same statement: a `(List, ++) → (ℝ, +)` homomorphism obtained by
counting erased bits and scaling by the per-bit factor `tf = kB·T·ln 2`. This
single algebraic fact is what makes budgets compositional and lets a *cost lower
bound* convert mechanically into a *step-count upper bound*
(`step_count_bounded_by_budget`). The one genuinely analytic ingredient is the
polynomial-versus-exponential separation `poly_isLittleO_exp`, distilled from
Mathlib's `isLittleO_pow_exp_pos_mul_atTop` by identifying `2^x` with
`exp((ln 2)·x)`; it is the engine behind every complexity separation here
(`entropy_gap_unbounded`, `entropy_gap_const`, `search_cost_exceeds_poly_budget`).

What did *not* fully materialize is the deep structural content behind the
quantum results: `quantum_circuit_cost` and `deferred_measurement_cost_invariant`
are true essentially by definition because our circuit abstraction records only
counts, not gate orderings or measurement statistics. This is a deliberate,
honest "cost-accounting shadow" of the deferred-measurement principle, and it
pinpoints exactly where the next cycle must add structure (a real circuit
semantics with an equivalence relation) to make the statement non-trivial. The
critique below makes this boundary precise.

## Results Summary

- `tempFactor_pos`: proved — the per-bit Landauer cost `kB·T·ln 2` is strictly positive; load-bearing positivity for every inequality.
- `totalBits_append`: proved — bit counts are additive over concatenation.
- `totalCost_append`: proved — Landauer cost is additive (the cost model is a monoid homomorphism into `(ℝ,+)`).
- `totalCost_nonneg`: proved — cost is nonnegative for a nonnegative per-bit factor.
- `totalCost_le_append_right`: proved — appending steps cannot decrease cost (budget monotonicity).
- `step_count_bounded_by_budget`: proved — flagship: an energy budget `B` admits at most `B/tf` unit-erasure steps (Landauer's principle as a complexity bound).
- `bruteForce_cost`: proved — brute-forcing an `n`-bit key space costs exactly `2^n·tf`.
- `demon_cost_additive`: proved — a Maxwell demon's erasure cost is additive over compos
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
