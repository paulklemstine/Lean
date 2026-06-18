
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

**Title**: The natural next step is to formalize the actual probabilistic phase transition.
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Proof Phase Transitions

## 1. Probabilistic Sharp Threshold for Random Implicational Theories

The natural next step is to formalize the actual probabilistic phase transition. Consider the random implicational theory on `Fin n` where each directed edge is included independently with probability `p`. Our monotonicity theorem (theory_extension_monotone) establishes that derivability is a monotone increasing property in the edge set. By Friedgut's sharp threshold theorem for monotone graph properties, the probability that a fixed pair `(0, n-1)` is derivable must transition from near 0 to near 1 within a window of width `o(1)` around some critical probability `p*(n)`.

The key insight is that our `Derivable` predicate is exactly a monotone Boolean function on the Boolean hypercube `{0,1}^{n²}` (indexed by potential edges), and Friedgut's theorem applies to any such function with a coarse threshold.

Why now? We have the monotonicity infrastructure (Theorem 2) and the boundary characterizations (Theorems 1 and 3) already formalized. The remaining piece is formalizing Friedgut's theorem itself, which requires Fourier analysis on the Boolean cube — a significant but tractable formalization target that would have broad applications beyond this project.

## 2. Proof Length Phase Transitions and Resolution Complexity

A deeper conjecture concerns not just derivability but *short* derivability: is there a sharp threshold for the existence of derivations of length ≤ L(n)? Our chain_derivable theorem shows that the chain theory (with n edges) gives a derivation of length exactly n. The conjecture is that in a random theory with edge probability p, the minimum derivation length exhibits a phase transition: below p*, minimum proofs are exponentially long (or nonexistent); above p*, polynomial-length proofs exist with high probability.

The key insight is that this connects our framework to proof complexity theory. The implicational derivation system is equivalent to monotone resolution, and resolution complexity lower bounds are known for random k-CNF. Formalizing this connection would bridge combinatorial proof complexity with the random graph threshold machinery.

Why now? The chain_axiom_critical theorem already demonstrates that minimal-density theories have tight proof structure. Extending this to random theories requires formalizing the relationship between graph diameter and derivation length, which builds directly on our chain theory infrastructure.

## 3. Multi-Conclusion Theories and Hypergraph Phase Transitions

Our framework models single-conclusion implications (a → b). A natural generalization is multi-premise implications: (a₁ ∧ a₂ ∧ ... ∧ aₖ) → b, which correspond to directed hypergraphs. The derivability closure becomes k-uniform hypergraph reachability, and the phase transition behavior should depend on k in a way analogous to the k-SAT threshold phenomenon.

The key insight is that for k ≥ 2, the phase transition should become sharper (the critical window narrows as k increases), mirroring the behavior in random k-SAT where the satisfiability threshold sharpens with clause width. The barrier argument from chain_barrier_closed generalizes to hypergraph barriers, but the analysis becomes substantially more complex.

Why now? The formalized barrier technique (refl_trans_gen_closed + chain_barrier_closed) provides a template for proving non-derivability in richer settings. The generalization to hypergraphs would connect directly to random SAT thresholds, which are among the most actively studied problems in probabilistic combinatorics.

## 4. Thermodynamic Characterization of the Derivability Order

The derivability preorder on atoms, viewed as a partial order on strongly connected components, has a rich combinatorial structure. For random theories at density p, this partial order undergoes a structural phase transition: below criticality, it consists of many small antichains; above criticality, a giant "derivability class" emerges (analogous to the giant component in random graphs). The conjecture is that the entropy of the derivability partial order (measured as log of the number of linear extensions) has a non-analytic point at p*.

The key insight is that the derivability order is a random partial order whose structural properties can be analyzed using the theory of random directed graphs. The emergence of a giant strongly connected component at p = 1/n provides the underlying mechanism for the phase transition in derivability.

Why now? Our framework provides the correct abstraction layer: the ImplTheory/Derivable pair cleanly separates the "theory" (the random object) from the "consequence relation" (the derived structure). This separation is exactly what's needed to apply random graph theory to the study of random formal theories.

## 5. Axiom Criticality Index and Computational Hardness

Our chain_axiom_critical theorem shows that in minimal theories, every axiom has "criticality index" 1 (removing it breaks some derivation). For non-minimal theories, define the criticality index of an axiom as the minimum number of axioms that must be removed (including this one) before some derivation breaks. The conjecture is that for random theories at the critical density, the distribution of criticality indices follows a power law, analogous to the distribution of backbone variables in random SAT instances near the satisfiability threshold.

The key insight is that axiom criticality is the proof-theoretic analogue of the "backbone" concept in constraint satisfaction. Backbone variables are those that take the same value in all satisfying assignments; critical axioms are those that participate in all proofs. The universality of power-law behavior near phase transitions suggests this distribution should be robust across theory ensembles.

Why now? The spanning_critical generalization already provides the conceptual framework for studying criticality beyond chain theories. Formalizing the criticality index and proving basic properties (e.g., monotonicity: adding axioms can only decrease criticality indices of existing axioms) is a natural next step that extends our current infrastructure.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Logic/ProofPhaseTransitions.lean
/-
# Proof Phase Transitions: Implicational Theories as Monotone Reachability

This module lays the *formal infrastructure* underpinning the program of "proof phase
transitions" for random implicational theories.  An **implicational theory** on a type
of atoms `α` is a set of single-conclusion axioms `a → b`, modelled as a binary relation
`ImplTheory α := α → α → Prop`.  **Derivability** is the reflexive–transitive closure of
the axiom relation — i.e. exactly graph reachability in the directed graph of axioms.

The headline structural facts proved here are:

* `theory_extension_monotone` / `derivable_monotone` — derivability is a **monotone**
  property of the axiom set.  This is the precise hypothesis required by Friedgut's sharp
  threshold theorem: `fun T => Derivable T a b` is a monotone Boolean function on the
  hypercube of potential edges.
* `refl_trans_gen_closed` — the **barrier method**: any set closed under the axioms and
  containing the source contains every derivable conclusion.  This is the canonical tool
  for proving *non*-derivability.
* `chain_derivable_iff` — a sharp **boundary characterization** for the linear chain
  theory: in `chainT` (the axioms `k → k+1`), `a` derives `b` iff `a ≤ b`.
* `chain_axiom_critical` — every axiom of a minimal (chain) theory is **critical**:
  deleting a single axiom destroys a derivation, while the full theory still derives it
  (`chain_axiom_restorable`).
* `chainPath_chain` / `chainPath_length` — a **constructive** witness: the explicit
  derivation `0 → 1 → ⋯ → n` of length `n`, realising the derivation as a concrete list.

-- !-- Lab Notebook -- !--
-- Hypothesis: Single-conclusion implicational derivability is *definitionally* reflexive–
--   transitive closure, hence a monotone graph-reachability property; the whole "phase
--   transition" narrative should rest on (a) monotonicity and (b) a barrier (closure)
--   lemma for non-derivability, with chains as the extremal minimal-density witnesses.
-- Result: All five pillars formalize cleanly. Monotonicity is `ReflTransGen.mono`; the
--   barrier lemma is a one-line induction on `ReflTransGen`; the chain boundary is a tight
--   iff; criticality and constructive length both follow from the barrier/chain machinery.
-- Insight: The barrier lemma `refl_trans_gen_closed` is the single reusable engine — both
--   "no backward derivation" and "deleted axiom blocks the proof" are instances of picking
--   the right closed set (`{k | a ≤ k}` resp. `{k | k ≤ m}`). Non-derivability proofs
--   reduce to exhibiting an invariant cut, exactly mirroring potential-function arguments.
-- Failure analysis: Initial `omega` calls failed because the edge relation `chainT x y`
--   was not unfolded in the closure hypothesis; `simp only [chainT]` before `omega` fixes
--   it. `List.Chain'` is deprecated in this toolchain — `List.IsChain` +
--   `List.isChain_iff_getElem` is the current API for the constructive path witness.
-- !-- end Lab Notebook -- !--
-/
import Mathlib

open Relation

namespace ProofPhaseTransitions

/-- An **implicational theory** on atoms of type `α`: the set of single-conclusion axioms
`a → b`, encoded as a binary relation. -/
abbrev ImplTheory (α : Type*) := α → α → Prop

/-- **Derivability** in a theory `T`: the reflexive–transitive closure of the axiom
relation. Equivalently, reachability in the directed graph whose edges are the axioms. -/
def Derivable {α : Type*} (T : ImplTheory α) : α → α → Prop := ReflTransGen T

/-- Reflexivity of derivability (the empty derivation). -/
theorem derivable_refl {α} (T : ImplTheory α) (a : α) : Derivable T a a := ReflTransGen.refl

/-- Transitivity of derivability (concatenation of derivations). -/
theorem derivable_trans {α} (T : ImplTheory α) {a b c}
    (h₁ : Derivable T a b) (h₂ : Derivable T b c) : Derivable T a c := h₁.trans h₂

/-- A single axiom yields a one-step derivation. -/
theorem derivable_of_axiom {α} (T : ImplTheory α) {a b} (h : T a b) : Derivable T a b :=
  ReflTransGen.single h

-- !-- Monotonicity: enlarging the axiom set can only enlarge the set of derivable pairs;
-- this is `ReflTransGen.mono`, the exact hypothesis Friedgut's sharp-threshold theorem
-- requires of a monotone Boolean function on the edge hypercube. -- !--
/-- **Theory extension monotonicity.** If every axiom of `T` is an axiom of `T'`, then
everything derivable in `T` is derivable in `T'`. -/
theorem theory_extension_monotone {α} {T T' : ImplTheory α} (h : ∀ a b, T a b → T' a b)
    {a b} (hab : Derivable T a b) : Derivable T' a b := hab.mono h

/-- **Monotone Boolean function form.** For fixed endpoints `a b`, the map sending a theory
to the proposition "`a` derives `b`" is monotone in the (pointwise) order on theories. This
is the precise statement that derivability is a monotone property of the edge set. -/
theorem derivable_monotone {α} (a b : α) :
    Monotone (fun T : ImplTheory α => Derivable T a b) := by
  intro T T' hTT' hab
  exact ReflTransGen.mono (fun x y h => hTT' x y h) hab

-- !-- Barrier method: a one-step induction on the reflexive-transitive closure shows any
-- set closed under the axioms and containing the source absorbs every conclusion; this is
-- the universal certificate for NON-derivability. -- !--
/-- **Barrier / invariant-cut lemma.** If `S` is closed under the axioms of `T` (any axiom
out of a member of `S` lands back in `S`) and contains `a`, then every `T`-derivable
conclusion of `a` lies in `S`. Picking a suitable `S` is the standard way to certify that
something is *not* derivable. -/
theorem refl_trans_gen_closed {α} (T : ImplTheory α) (S : Set α)
    (hclosed : ∀ a ∈ S, ∀ b, T a b → b ∈ S) {a b} (ha : a ∈ S)
    (hab : Derivable T a b) : b ∈ S := by
  induction hab with
  | refl => exact ha
  | tail _ hbc ih => exact hclosed _ ih _ hbc

/-! ### The linear chain theory — the minimal-density extremal case -/

/-- The **chain theory** on `ℕ`: the axioms are exactly `k → k+1`. This is the minimal
theory making `0` derive `n`, with a derivation of length precisely `n`. -/
def chainT : ImplTheory ℕ := fun a b => b = a + 1

-- !-- Forward direction of the chain boundary: induct on the target; either the source is
-- already strictly below and we extend a shorter derivation, or source = target. -- !--
/-- In the chain theory, `a ≤ b` implies `a` derives `b`. -/
theorem chain_derivable_le {a b : ℕ} (h : a ≤ b) : Derivable chainT a b := by
  induction b with
  | zero => simp_all; exact ReflTransGen.refl
  | succ n ih =>
    rcases Nat.lt_or_ge a (n + 1) with h1 | h1
    · exact (ih (Nat.lt_succ_iff.mp h1)).tail rfl
    · have : a = n + 1 := le_antisymm h h1
      subst this; exact ReflTransGen.refl

/-- The chain theory derives `n` from `0`. -/
theorem chain_derivable (n : ℕ) : Derivable chainT 0 n := chain_derivable_le (Nat.zero_le n)

-- !-- Backward direction via the barrier lemma with the upward-closed cut `{k | a ≤ k}`:
-- the axioms only ever increase the index, so derivability cannot decrease it. -- !--
/-- In the chain theory, derivability forces `a ≤ b`: no derivation can go "backward". -/
theorem chain_barrier_closed {a b : ℕ} (hab : Derivable chainT a b) : a ≤ b := by
  have := refl_trans_gen_closed chainT {k | a ≤ k}
    (by intro x hx y hy; simp only [Set.mem_setOf_eq, chainT] at *; omega) (by simp) hab
  simpa using this

/-- **Sharp boundary characterization** for the chain theory: `a` derives `b` iff `a ≤ b`.
A complete, decidable description of the consequence relation. -/
theorem chain_derivable_iff (a b : ℕ) : Derivable chainT a b ↔ a ≤ b :=
  ⟨chain_barrier_closed, chain_derivable_le⟩

/-- No backward derivation: `1` does not derive `0` in the chain theory. -/
theorem chain_no_backward : ¬ Derivable chainT 1 0 := by
  intro h; have := chain_barrier_closed h; omega

/-! ### Axiom criticality -/

/-- The chain theory with the single axiom `m → m+1` **deleted**. -/
def chainMinus (m : ℕ) : ImplTheory ℕ := fun a b => b = 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Proof Phase Transitions

## Synthesis

The file `Catalog/Logic/ProofPhaseTransitions.lean` builds the formal scaffolding for
treating *derivability in an implicational theory* as a monotone reachability property on
the directed graph of axioms. An implicational theory is a relation `ImplTheory α := α →
α → Prop`; derivability `Derivable T` is its reflexive–transitive closure. On this base we
proved the five structural pillars that the "proof phase transition" program needs:

1. **Monotonicity** (`theory_extension_monotone`, `derivable_monotone`): enlarging the
   axiom set only enlarges the derivable relation. Equivalently, `fun T => Derivable T a b`
   is monotone in the pointwise order on theories.
2. **The barrier method** (`refl_trans_gen_closed`): any axiom-closed set containing the
   source contains every conclusion — the universal certificate for non-derivability.
3. **A sharp boundary** (`chain_derivable_iff`): for the linear chain theory `chainT`,
   `a` derives `b` iff `a ≤ b`.
4. **Axiom criticality** (`chain_axiom_critical`, `chain_axiom_restorable`): deleting any
   one chain axiom destroys a derivation, restoring it recovers the derivation.
5. **A constructive witness** (`chainPath`, `chainPath_chain`, `chainPath_length`): the
   explicit path `0 → 1 → ⋯ → n` realising the derivation, with length exactly `n`.

## Results Summary

All declarations are proved with `sorry = 0`. The barrier lemma is the single reusable
engine: both "no backward derivation" and "deleted axiom blocks the proof" instantiate it
by choosing the right closed cut (`{k | a ≤ k}` resp. `{k | k ≤ m}`). The chain theory is
the minimal-density extremal object whose every axiom has criticality index 1.

## Research Directions

### 1. Probabilistic sharp threshold for random implicational theories

Equip the edge set on `Fin n` with the product measure where each directed edge is present
independently with probability `p`, and study `ℙ[Derivable T 0 (n-1)]` as a function of `p`.
Our `derivable_monotone` shows the event is monotone increasing in the edge set, so it is a
monotone Boolean function on `{0,1}^{n²}`; Friedgut's theorem then forces a coarse-to-sharp
threshold of window width `o(1)` around some `p*(n)`. **The key insight is** that the entire
random-theory phase transition reduces to applying a single off-the-shelf threshold theorem
to the monotone indicator `fun T => Derivable T 0 (n-1)` that we have already isolated. *Why
now?* Monotonicity and the boundary characterization are formalized; the only missing piece
is Friedgut's theorem (Fourier analysis on the cube), a self-contained and broadly reusable
target. Falsifiable: if the derivability indicator failed to be monotone, the threshold
machinery would not apply — but `derivable_monotone` rules this out.

### 2. Proof-length phase transition and the diameter–length identity

`chainPath_length` shows the minimal theory admits a derivation of length exactly `n`.
Conjecture: in a random
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
