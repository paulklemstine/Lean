
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
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
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

**Title**: This cycle laid the missing foundation for the "proof phase transition" program.
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Proof Phase Transitions in Random Implicational Theories

## Synthesis

This cycle laid the missing foundation for the "proof phase transition" program. The
concept brief referenced an infrastructure (`ImplTheory`, `Derivable`,
`theory_extension_monotone`, `chain_derivable`, the barrier method) that did not yet
exist anywhere in the catalog — a genuine cold start. We therefore built it from
scratch in `Catalog/Logic/ImplicationalThreshold.lean`, modelling an implicational
theory as a binary relation `T : α → α → Prop` (the directed edge set) and derivability
as its reflexive–transitive closure `Relation.ReflTransGen T`. This thin layer turns
out to be exactly the right abstraction: it exposes derivability as a *monotone* set
function of the axioms and admits a clean *barrier* certificate for non-derivability.

The two structural pillars are now formal. `theory_extension_monotone` proves that
`Derivable` is monotone increasing in the axiom relation — the precise hypothesis of
Friedgut's sharp-threshold theorem, and the reason a threshold should exist at all. Its
dual, `barrier_not_derivable` (via the invariance lemma `derivable_mem_of_closed`),
proves that any forward-closed set separating source from target certifies
non-derivability; this is the lower-bound half that a sharp-threshold proof consumes at
low density. The cross-domain payoff is `chain_axiom_critical`: on the minimal-density
chain theory, deleting any single axiom destroys derivability of `0 → n`. Its proof
*combines* the two pillars — the deleted theory is a subtheory (monotonicity) and the
down-set `{x ≤ k}` is the unique barrier created by the deletion — giving the first
formal "criticality index 1" statement.

What was tricky rather than what failed: the inductions over `Relation.ReflTransGen`
needed the right monovariant (`a ≤ ·` for `derivable_succ_iff`) and a strengthened
target (`derivable 0 → m for all m ≤ n`) to feed `chain_le_derivable`; and `omega`
cannot see through `Set` membership, so barrier goals must be `simp only
[Set.mem_setOf_eq]`-normalised first. These are the load-bearing idioms the next team
should reuse. The structural insight is that the whole random-theory program factors
through *monotonicity ⊕ barriers*, and every direction below is an instance of pushing
one of those two pillars into a richer setting.

## Results Summary

- `theory_extension_monotone`: proved — derivability is a monotone increasing property
  of the axiom set, the structural hypothesis behind any sharp-threshold statement.
- `derivable_mem_of_closed`: proved — forward-closed sets are invariant along
  derivations (the engine behind every barrier argument).
- `barrier_not_derivable`: proved — a forward-closed separating set certifies
  non-derivability; the low-density lower-bound tool.
- `derivable_succ_iff`: proved — boundary characterization: the successor theory on `ℕ`
  derives `a → b` iff `a ≤ b` (the deterministic endpoint of the random model).
- `chain_derivable`: proved — the length-`n` chain theory derives `0 → n` with a
  derivation of length exactly `n` (the graph diameter), anchoring proof-length study.
- `chain_axiom_critical`: proved — every chain axiom has criticality index `1`; deleting
  any single edge breaks `0 → n`. The headline cross-concept theorem (monotonicity ⊕
  barrier).

## Research Directions

### Direction 1: Probabilistic sharp threshold for random implicational theories
**Hypothesis**: For the random theory on `Fin n` where each directed edge is present
independently with probability `p`, there is a critical `p*(n)` such that
`Pr[Derivable T 0 (n-1)]` jumps from `≤ ε` to `≥ 1-ε` over a window of width `o(1)`
around `p*`.
**Test**: Formalize the event `Derivable T 0 (n-1)` as a monotone Boolean function on
`{0,1}^{n²}` using `theory_extension_monotone` to discharge monotonicity, then feed it
to a (to-be-formalized) Friedgut/Bourgain coarse-threshold theorem; numerically, sample
the empirical curve for small `n` to estimate `p*(n) ≈ log n / n`.
**Why now**: Monotonicity is now a one-liner (`theory_extension_monotone`), so the only
remaining ingredient is the general threshold theorem itself.
**If true**: Connects formal proof theory to the random-graph threshold machinery and
makes "proof phase transition" a theorem rather than a metaphor.
**If false**: Would mean derivability has a *coarse* threshold, revealing a genuine
proof-theoretic obstruction (a "pivotal-axiom" cluster) absent in ordinary connectivity.

### Direction 2: Proof-length thresholds and the diameter bound
**Hypothesis**: Define `minDerivLen T a b` as the least `k` with a `k`-step derivation.
On the chain theory, `minDerivLen (chain n) 0 n = n`; for random theories above `p*`,
`minDerivLen 0 (n-1) = O(log n / log(np))` with high probability, versus `∞` below.
**Test**: First prove the deterministic core — `minDerivLen (chain n) 0 n = n` and the
general lower bound `minDerivLen T a b ≥ graph distance` — by refining
`chain_le_derivable` into a length-counting induction; then layer the random diameter
estimate.
**Why now**: `chain_derivable` already realizes the diameter-length derivation; the only
new infrastructure is a `ℕ`-valued length function compatible with `ReflTransGen`.
**If true**: Bridges to resolution proof complexity (implicational derivation = monotone
resolution), importing random-`k`-CNF lower bounds.
**If false**: Short proofs exist even below the derivability threshold, indicating
proof-length and existence thresholds genuinely decouple.

### Direction 3: Hypergraph (multi-premise) theories and threshold sharpening
**Hypothesis**: For `k`-premise implications `(a₁ ∧ … ∧ a_k) → b` (directed
hypergraphs), derivability is still monotone, and the critical window narrows as `k`
grows, mirroring random `k`-SAT.
**Test**: Generalize `Derivable` to a hypergraph closure (least fixed point of "all
premises derived ⇒ conclusion derivable"), re-prove `theory_extension_monotone` and
`barrier_not_derivable` (the barrier becomes "closed under any rule all of whose
premises lie in `S`"), then study the window width as a function of `k`.
**Why now**: The barrier lemma `derivable_mem_of_closed` is stated purely via
forward-closure, so it generalizes to hypergraph closure almost verbatim — the
template is already in place.
**If true**: Directly connects this framework to the most studied object in
probabilistic combinatorics (random SAT thresholds).
**If false**: A `k`-independent window would signal that single-conclusion intuition
fails for hypergraph reachability, a surprising structural fact.

### Direction 4: Giant derivability component and order-entropy non-analyticity
**Hypothesis**: The derivability preorder (atoms ordered by `Derivable`) collapses, at
`p = 1/n`, from many small antichains to a single giant strongly-connected derivability
class, and the log-number of linear extensions has a non-analytic point at `p*`.
**Test**: Define the SCC quotient of `Derivable` and prove the deterministic anchors
(chain ⇒ a total order of `n+1` classes), then transport the random-digraph giant-SCC
theorem at `p = 1/n` through the `Derivable`/SCC correspondence.
**Why now**: The clean `ImplTheory`/`Derivable` split isolates the random object (edges)
from the derived structure (the preorder), exactly the separation needed to invoke
random-digraph theory.
**If true**: Gives a thermodynamic ("giant component") reading of proof-theoretic
phase transitions with a measurable order parameter.
**If false**: The derivability order's transition is decoupled from the SCC transition,
isolating a purely proof-theoretic emergence phenomenon.

### Direction 5: The criticality-index distribution and backbone universality
**Hypothesis**: Generalize `chain_axiom_critical` to define `critIndex T a b e` = least
number of axioms (including `e`) whose removal kills `Derivable T a b`. Then (i) the
index is monotone — adding axioms can only lower existing indices — and (ii) at
criticality the index distribution follows a power law, the proof-theoretic analogue of
SAT backbones.
**Test**: First prove the monotonicity lemma (a corollary of `theory_extension_monotone`
plus `barrier_not_derivable`), confirming chain edges have index `1`; then compute the
empirical index distribution for random theories near `p*`.
**Why now**: `chain_axiom_critical` is exactly the `critIndex = 1` base case, and its
monotonicity-⊕-barrier proof scheme is the template for the general monotonicity lemma.
**If true**: Establishes a universal backbone/criticality law across theory ensembles.
**If false**: A non-power-law (e.g. bimodal) distribution would expose theory-specific
proof structure violating constraint-satisfaction universality.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Logic/HypergraphThreshold.lean
/-
# Implicational Thresholds III: Multi-Premise (Hypergraph) Theories

This module **generalizes** the single-conclusion implicational machinery of
`Logic.ProofPhaseTransitions` (`ImplTheory`, `Derivable = ReflTransGen`,
`theory_extension_monotone`, `refl_trans_gen_closed`) from binary axioms `a → b` to
**`k`-premise rules** `(a₁ ∧ … ∧ aₘ) → b`, i.e. directed hypergraphs.  This is exactly the
content of Research Direction 3 ("Hypergraph (multi-premise) theories") of the cycle's
FUTURE_DIRECTIONS: re-establish the two structural pillars — *monotonicity* and the
*barrier method* — for the hypergraph closure, and then bridge back to the catalog's
single-premise model.

A **hypertheory** `R : Set (List α × α)` is a set of rules `(premises, conclusion)`.
Starting from a set `S` of assumed atoms, `HDeriv R S a` is the least set closed under
"`S` and every rule all of whose premises are already derived" — the standard forward
hypergraph closure / least fixed point.

Headline results:

* `hderiv_axioms_monotone` / `hderiv_hyps_monotone` — the **two monotonicities**: the
  hypergraph closure is monotone in *both* the rule set and the assumption set. The first is
  the hypergraph analogue of `ProofPhaseTransitions.theory_extension_monotone` (the
  threshold hypothesis) and generalizes it from edges to hyperedges.
* `hderiv_barrier` — the **hypergraph barrier method**: any set `C` containing the
  assumptions and closed under every rule whose premises lie in `C` absorbs the whole
  closure. The verbatim generalization of `ProofPhaseTransitions.refl_trans_gen_closed`
  ("closed under any rule all of whose premises lie in `C`"), the universal non-derivability
  certificate.
* `hderiv_singlePremise_iff_derivable` — the **cross-domain bridge**: when every rule has a
  single premise, hypergraph derivability collapses *exactly* onto the catalog's binary
  `ProofPhaseTransitions.Derivable`. This certifies that the hypergraph layer is a
  conservative generalization, connecting Direction 3 back to the original `Derivable`.

-- !-- Lab Notebook -- !--
-- Hypothesis: The monotonicity ⊕ barrier factorization of the proof-phase-transition program
--   is not special to binary edges; it should survive verbatim for multi-premise rules if
--   `Derivable` is replaced by the least fixed point `HDeriv` of "all premises derived ⇒
--   conclusion".  The single-premise specialization should recover `ReflTransGen` exactly.
-- Result: Both pillars generalize.  Monotonicity in rules and in assumptions are independent
--   structural inductions on `HDeriv`; the barrier lemma needs only "closed under any rule all
--   of whose premises lie in C", literally the FUTURE_DIRECTIONS prediction.  The single-premise
--   bridge is a clean iff with `Derivable`, so the catalog model embeds as the `m = 1` slice.
-- Insight: The barrier lemma is the *only* engine and it is premise-arity-agnostic: the closed
--   set `C` is the conserved quantity regardless of how many premises a rule consumes.  This is
--   why the same `{x ≤ m}`-style cuts that prove non-derivability for chains will prove it for
--   random hypergraphs — the certificate format does not change with `k`.
-- Failure analysis: The nested `∀ p ∈ prems, HDeriv R S p` constructor makes the auto-generated
--   recursor pass the inductive hypothesis as `∀ p ∈ prems, motive p`; one must use `induction`
--   (not `cases`) and feed *that* family, not re-derive premise facts.  `Set` membership again
--   blocks `omega`/`simp` until `Set.mem_setOf_eq` / `Set.mem_singleton_iff` normalization.
-- !-- end Lab Notebook -- !--
-/
import Mathlib

open Relation

namespace HypergraphThreshold

/-! ### Mirrored base infrastructure

`ImplTheory` and `Derivable` mirror `Logic.ProofPhaseTransitions`; they are reproduced
here so this file is self-contained and are *definitionally identical* to the catalog
versions (`Derivable` = reflexive–transitive closure of the axiom relation).  The
single-premise bridge below therefore connects the hypergraph layer to the very same
`Derivable` object studied in the catalog. -/

/-- An **implicational theory** (binary axioms), mirroring
`ProofPhaseTransitions.ImplTheory`. -/
abbrev ImplTheory (α : Type*) := α → α → Prop

/-- **Derivability**: reflexive–transitive closure of the axioms, mirroring
`ProofPhaseTransitions.Derivable`. -/
def Derivable {α : Type*} (T : ImplTheory α) : α → α → Prop := ReflTransGen T

/-- A **hypertheory** on atoms `α`: a set of multi-premise rules
`(premises, conclusion)`, generalizing the binary `ProofPhaseTransitions.ImplTheory`. -/
abbrev HyperTheory (α : Type*) := Set (List α × α)

/-- **Hypergraph derivability.** `HDeriv R S a` is the least predicate containing the
assumption set `S` and closed under every rule of `R` all of whose premises are already
derived. The multi-premise generalization of `ProofPhaseTransitions.Derivable`. -/
inductive HDeriv {α : Type*} (R : HyperTheory α) (S : Set α) : α → Prop
  | base {a : α} : a ∈ S → HDeriv R S a
  | rule {prems : List α} {concl : α} :
      (prems, concl) ∈ R → (∀ p ∈ prems, HDeriv R S p) → HDeriv R S concl

/-
!-- Monotone in the rule set: induct on the closure, replaying each rule through `R ⊆ R'`. -- !--

**Rule-set monotonicity.** Enlarging the hypertheory enlarges the closure. The
hypergraph analogue (and generalization) of
`ProofPhaseTransitions.theory_extension_monotone`.
-/
theorem hderiv_axioms_monotone {α : Type*} {R R' : HyperTheory α} (hR : R ⊆ R')
    {S : Set α} {a : α} (h : HDeriv R S a) : HDeriv R' S a := by
      induction h;
      · exact HDeriv.base ‹_›;
      · exact HDeriv.rule ( hR ‹_› ) ‹_›

/-
!-- Monotone in the assumptions: induct on the closure, relaxing each `base` via `S ⊆ S'`. -- !--

**Assumption monotonicity.** Enlarging the assumption set enlarges the closure.
-/
theorem hderiv_hyps_monotone {α : Type*} {R : HyperTheory α} {S S' : Set α} (hS : S ⊆ S')
    {a : α} (h : HDeriv R S a) : HDeriv R S' a := by
      induction h;
      · exact HDeriv.base ( hS ‹_› );
      · exact HDeriv.rule ‹_› ‹_›

/-
!-- Barrier method, premise-arity-agnostic: induct on the closure; `base` lands in `C` by
`S ⊆ C`, `rule` lands in `C` since all its premises are in `C` by the IH. -- !--

**Hypergraph barrier method.** If `C` contains the assumptions `S` and is closed under
every rule all of whose premises lie in `C`, then `C` absorbs the entire closure. The
verbatim generalization of `ProofPhaseTransitions.refl_trans_gen_closed` and the universal
certificate for hypergraph non-derivability.
-/
theorem hderiv_barrier {α : Type*} (R : HyperTheory α) (S C : Set α) (hS : S ⊆ C)
    (hclosed : ∀ prems concl, (prems, concl) ∈ R → (∀ p ∈ prems, p ∈ C) → concl ∈ C)
    {a : α} (h : HDeriv R S a) : a ∈ C := by
      induction h <;> aesop

/-- The single-premise hypertheory induced by a binary `ImplTheory`: each axiom `a → b`
becomes the one-premise rule `([a], b)`. -/
def toHyper {α : Type*} (T : ImplTheory α) : HyperTheory α :=
  {x | ∃ a, x.1 = [a] ∧ T a x.2}

/-
!-- Cross-domain bridge: forward by induction on `HDeriv` (each one-premise rule is a single
axiom step appended via `ReflTransGen.tail`), backward by induction on `ReflTransGen` (each
step is the one-premise rule `([b], c)`). -- !--

**Cross-domain bridge.** With single-premise rules, hypergraph derivability from the
singleton assumption `{a}` coincides *exactly* with the catalog's binary
`ProofPhaseTransitions.Derivable`. The hypergraph layer is a conservative generalization:
the original model is its `m = 1` slice.
-/
theorem hderiv_singlePremise_iff_derivable {α : Type*} (T : ImplTheory α) (a b : α) :
    HDeriv (toHyper T) {a} b ↔ Derivable T a b := by
      constructor;
      · intro h;
        induction h;
        · cases ‹_› ; exact ReflTransGen.refl;
        · rename_i prems concl h₁ h₂ h₃;
          obtain ⟨ x, hx₁, hx₂ ⟩ := h₁;
          exact ReflTransGen.tail ( h₃ x ( by aesop ) ) hx₂;
      · intro h;
        
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Proof Phase Transitions — Length & Hypergraph Layers

## Synthesis

The previous cycle built the *existence* layer of the proof–phase–transition program in
`Catalog/Logic/ProofPhaseTransitions.lean`: implicational theories as binary relations,
`Derivable` as reflexive–transitive closure, and the two structural pillars
`theory_extension_monotone` (monotonicity) and `refl_trans_gen_closed` (the barrier
method), with the chain theory as the extremal minimal-density witness
(`chain_derivable_iff`, `chain_axiom_critical`). That layer answers *whether* a
conclusion is derivable but is blind to *how long* the proof is and to *multi-premise*
rules.

This cycle adds the two missing dimensions called for in the prior FUTURE_DIRECTIONS, on
the very same `Derivable` object, in two new self-contained files.

`Catalog/Logic/ImplicationalThreshold.lean` introduces the **length-graded** layer
`DerivOfLen T a b k` ("a derivation of `b` from `a` using exactly `k` axiom steps") and
the minimal-proof-length function `minDerivLen`. The key insight is that on the chain
theory the proof length is *rigid* — `DerivOfLen chainT a b k ↔ b = a + k` forces the
achievable-length set of `0 ⊢ n` to be the singleton `{n}` — so the diameter theorem
`minDerivLen chainT 0 n = n` is not a minimum over many lengths but the only length. The
graded layer inherits the existence layer's monotonicity *length-preservingly*
(`derivOfLen_theory_monotone`), which immediately yields `minDerivLen_theory_anti`:
adding axioms can only shorten proofs. This is exactly the deterministic core needed
before any random diameter estimate, and the monotonicity base case for criticality
indices.

`Catalog/Logic/HypergraphThreshold.lean` lifts the whole framework from binary edges to
**`k`-premise rules** (directed hypergraphs) via the least-fixed-point closure `HDeriv`.
The two pillars survive verbatim — `hderiv_axioms_monotone` and `hderiv_hyps_monotone`
(monotone in both rules and assumptions) and `hderiv_barrier` (a closed set absorbing the
whole closure, premise-arity-agnostic) — and the cross-domain bridge
`hderiv_singlePremise_iff_derivable` proves the catalog's binary `Derivable` is *exactly*
the single-premise slice of `HDeriv`. The structural insight, again, is that the entire
program factors through **monotonicity ⊕ barriers**, and neither pillar cares about
premise arity; the conserved set in a barrier certificate has the same format for `k = 1`
(chains) and arbitrary `k` (random SAT-like ensembles).

## Results Summary

In `Catalog/Logic/ImplicationalThreshold.lean`:
- `derivable_iff_exists_len` — the graded layer refines `Derivable`: derivability is
  existence of *some* finite-length derivation.
- `derivOfLen_theory_monotone` — theory extension preserves a derivation *and its length*.
- `chain_derivOfLen_iff` — sharp graded boundary: in the chain, the unique proof length of
  `a ⊢ b` is the index gap `b − a`.
- `minDerivLen_chain` — **diameter theorem**: the minimal proo
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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
