
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   Reference the specific theorems proved in Phase A using @file references.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work,
   references to catalog results. Use @file references for theorems.
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
Use the @file references above to point readers to specific theorems.


## Concept

**Title**: Rigorous formal foundations for the Collatz conj
**Domain**: Computation
**Mathematical framing**: # Future Directions

## Synthesis

This research cycle established rigorous formal foundations for the Collatz conjecture's proof-theoretic analysis. The key results — parity exclusion, density contraction, odd density bounds, and orbit merge — form a coherent picture of why the conjecture is hard: local contraction is guaranteed by combinatorial constraints, but global contraction requires bounding growth phases that depend unpredictably on the input.

The most promising cross-domain connection is between the **Generalized Collatz System (GCS) framework** and the **computational universality** results in the Catalog's `Computation/` directory. Conway's theorem that GCS families are Turing-complete connects directly to the oracle and computability structures in `Computation/GravityOracle.lean` and `Computation/InfoEfficientAlgorithms.lean`. The GCS encoding notion defined in this cycle could bridge dynamical systems (Algebra) with computability theory (Computation), creating a formal pathway from specific Collatz dynamics to proof-theoretic independence.

The direction with highest breakthrough potential is Direction 1 (Sharp Contraction Threshold), because it would close the gap between our sufficient condition (odd density < 1/2) and the necessary condition (odd density < log₂3) using only real-number arithmetic already available in Mathlib. This would be the tightest known formal bound on Collatz contraction, directly useful for any future proof attempt.

---

### Direction 1: Sharp Contraction Threshold via Real Logarithms

**Conjecture**: For any Collatz orbit of length k with j odd steps, if j/k < log(2)/log(3), then the orbit segment contracts (the end value is less than the start value for sufficiently large starting values). Specifically: for all ε > 0, there exists N₀ such that if n ≥ N₀ and j/k < log(2)/log(3) - ε, then T^k(n) < n.

**Test**: Formalize the real-valued inequality log(3)/log(2) · j < k - j in Lean 4 using Mathlib's `Real.log`. Prove that this implies 3^j < 2^(k-j) using `Real.rpow_lt_rpow` and related lemmas. Verify computationally for k = 100, j = 62 (which is below the threshold) vs j = 64 (above).

**Impact**: This would give the sharpest possible formal contraction criterion, replacing our current sufficient condition (2j < k, i.e., density < 1/2) with the optimal threshold (density < log₂(2)/log₂(3) ≈ 0.6309). Any future proof of Collatz via density arguments would need this bound.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (pow3_lt_pow2_double, density_contraction), `Catalog/Algebra/ParityCylinders.lean` (isDescentWord)

**Proof Strategy**: 
1. Define the real-valued contraction condition: `j * Real.log 3 < (k - j) * Real.log 2`.
2. Show equivalence with `(3 : ℝ)^j < (2 : ℝ)^(k-j)` using `Real.exp_log` and monotonicity.
3. Transfer to natural numbers: `(3 : ℝ)^j < (2 : ℝ)^(k-j)` implies `3^j < 2^(k-j)` in ℕ using `Nat.cast_lt`.
4. Apply to the orbit affine bound to get the contraction result.

**Domain Bridges**: Algebra (parity word theory) <-> Analysis (real logarithms) <-> Computation (contraction verification)

**Lineage**: Builds on `pow3_lt_pow2_double` and `density_contraction` from this cycle.

**Ambition**: extension

---

### Direction 2: Collatz Orbit Encoding of Finite Automata

**Conjecture**: For every deterministic finite automaton (DFA) with n states, there exists a Generalized Collatz System with modulus m = O(n!) that simulates the DFA's computation. Specifically, the GCS can be constructed so that its residue-class dynamics on a set of n distinguished values exactly mirrors the DFA's state transitions.

**Test**: Construct explicit GCS encodings for small DFAs (2-state, 3-state) and verify in Lean that the GCS dynamics on the embedded states matches the DFA transitions. Then prove the general construction for arbitrary n-state DFAs.

**Impact**: This would be a concrete, constructive version of Conway's universality theorem, restricted to finite automata. It would establish the precise modulus needed for encoding, which is relevant to understanding whether the standard Collatz modulus (m = 2) has any encoding power.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (GCS, GCS.Encodes, FiniteTransition), `Catalog/Computation/InfoEfficientAlgorithms.lean` (BSState)

**Proof Strategy**:
1. Define DFA as a `FiniteTransition` with input alphabet.
2. Use Chinese Remainder Theorem to construct residue classes that separate states.
3. Define affine rules that map each state's residue class to the successor state's class.
4. Prove the divisibility condition using CRT.
5. Verify the encoding property.

**Domain Bridges**: Algebra (GCS framework) <-> Computation (finite automata, Turing completeness) <-> Cryptography (CRT constructions)

**Lineage**: Builds on GCS and FiniteTransition definitions from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Transfinite Orbit Measures and Goodstein Analogy

**Conjecture**: There exists an ordinal-valued measure μ : ℕ → Ordinal (below ε₀) such that for all n ≥ 2, μ(T(n)) < μ(n) in the standard Collatz map. If such a measure exists, the Collatz conjecture follows by transfinite induction, but the measure itself may require principles beyond PA (analogous to Goodstein's theorem).

**Test**: Define candidate measures combining stopping time, peak value, and bit-length. Test whether μ(T(n)) < μ(n) for n ≤ 10^6. The measure μ(n) = ω^(bit-length(n)) · (n mod 2^k) + lower-order terms is a natural starting point.

**Impact**: If a sub-ε₀ measure works, it would prove the Collatz conjecture using transfinite induction up to ε₀ (which is the proof-theoretic ordinal of PA). This would simultaneously prove Collatz and show it's provable in PA + transfinite induction, placing it at the same logical level as Goodstein's theorem. If no sub-ε₀ measure works, it would be strong evidence for independence from PA.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, peakValue, ComplexityClass), `Catalog/Logic/` (ordinal theory if available)

**Proof Strategy**:
1. Define ordinal-valued measures on ℕ using Cantor Normal Form.
2. Show that even steps decrease the measure (easy: bit-length decreases).
3. Show that odd steps increase bit-length by at most 1 but decrease a secondary component.
4. The challenge is finding a measure where the odd-step increase is compensated by subsequent even steps — this is where the parity exclusion theorem is crucial.

**Domain Bridges**: Algebra (Collatz dynamics) <-> Logic (ordinal arithmetic, proof theory) <-> Computation (well-founded recursion)

**Lineage**: Builds on ComplexityClass and stoppingTime from this cycle, and the parity exclusion theorem.

**Ambition**: grand_challenge

---

### Direction 4: Spectral Analysis of Parity Words

**Conjecture**: The discrete Fourier transform of the parity word of a Collatz orbit of length k has spectral energy concentrated at frequency 1/2 (reflecting the parity exclusion alternation). Specifically, the spectral coefficient at frequency 1/2 satisfies |ĉ(1/2)| ≥ c·√k for some universal constant c > 0, and this spectral concentration is equivalent to the contraction property.

**Test**: Compute the DFT of parity words for orbits starting at n = 27 (a famously long orbit with 111 steps). Check whether the spectral peak at frequency 1/2 dominates. Compare with random binary words satisfying the no-consecutive-ones constraint.

**Impact**: A spectral characterization of contraction would connect Collatz dynamics to harmonic analysis, potentially enabling tools from analytic number theory (e.g., exponential sum estimates) to attack the conjecture. This bridges the combinatorial parity-word approach with the Fourier-analytic approach of Tao (2019).

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (orbitParity, oddSteps_le_half), `Catalog/MachineLearning/CollatzSpectral/` (existing spectral framework), `Catalog/Algebra/ParityCylinders.lean` (parityWord)

**Proof Strategy**:
1. Define the DFT on ParityWord: ĉ(f) = Σ w(i) · exp(2πi·f·i/k).
2. Use parity exclusion to show the alternating component is large.
3. Connect spectral energy to oddSteps/evenSteps ratio.
4. Prove that spectral concentration at f=1/2 implies the contraction bound.

**Domain Bridges**: Algebra (parity words) <-> Analysis (Fourier transform) <-> MachineLearning (spectral Collatz framework)

**Lineage**: Builds on orbitParity and oddSteps_le_half from this cycle; connects to `CollatzSpectral/` in the Catalog.

**Ambition**: extension

---

### Direction 5: Computational Lower Bounds on Collatz Independence

**Conjecture**: If the Collatz conjecture is independent of PA, then for infinitely many n, the stopping time of n exceeds any primitive recursive function of n. Conversely, if all stopping times are bounded by a fixed primitive recursive function, then the conjecture is provable in PA.

**Test**: Formalize the equivalence between "Collatz stopping times are primitive-recursively bounded" and "Collatz is provable in PA" using the connection between provably total functions and proof-theoretic ordinals. Test computationally: check whether stopping times for n ≤ 10^8 exceed n^(log log n), which is a candidate super-polynomial but sub-primitive-recursive bound.

**Impact**: This would give a precise computational criterion for independence: either stopping times are "tame" (primitive-recursively bounded) and the conjecture is provable, or they are "wild" (eventually exceeding any primitive recursive function) and the conjecture is independent. This transforms a metamathematical question into a concrete computational one.

**Catalog References**: `Catalog/Algebra/CollatzUndecidable.lean` (stoppingTime, ComplexityClass, CollatzIndependenceConjecture), `Catalog/Computation/PadicValuationDepth.lean` (depth measures)

**Proof Strategy**:
1. Formalize the concept of a "provably total function" in a proof system.
2. Show that if Collatz is provable in PA, then its stopping-time function is provably total in PA.
3. By the characterization of provably total functions of PA (those bounded by functions in the fast-growing hierarchy below ε₀), this gives a concrete bound.
4. Conversely, show that a primitive recursive bound on stopping times yields a PA proof.

**Domain Bridges**: Algebra (Collatz dynamics) <-> Computation (primitive recursion, fast-growing hierarchy) <-> Logic (proof-theoretic ordinals)

**Lineage**: Builds on stoppingTime and CollatzIndependenceConjecture from this cycle.

**Ambition**: grand_challenge

Research domain: Computation
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/CanonicalKernelDefs.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Canonical Tropical Kernel — Definitions

This file introduces the foundational definitions for the canonical tropical
kernel theory, connecting harmonic functions on graph subsets to chip-firing
equivalence classes and the restricted critical group.

## Main Definitions

* `IsHarmonicOn` — a function satisfies the discrete Laplace equation on a subset
* `NormalizedOn` — a function sums to zero on a subset (mean-zero normalization)
* `SeparatedOn` — the restriction-faithfulness separation hypothesis
* `FiringEquivalentOn` — two functions differ by a Laplacian image supported on a subset
* `IsTreeAttachmentAlong` — a set T is attached to S as a tree
* `RestrictedLaplacianImage` — the image of the restricted Laplacian on S
* `harmonicKernel` — the set of harmonic functions on S

## References

* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-/

import Mathlib
import Pythagorean.TropicalBridge.Defs

open Finset BigOperators

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Harmonic Functions on Subsets -/

/-- A function `f : V → ℤ` is **harmonic on** a subset `S` with respect to graph `G`
    if for every vertex `v ∈ S`, the Laplacian of `f` at `v` vanishes:
    `∑ w, L(v,w) · f(w) = 0`.
    This is the discrete analogue of harmonicity in potential theory. -/
def IsHarmonicOn
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (f : V → ℤ) : Prop :=
  ∀ v ∈ S, ∑ w : V, graphLaplacian G v w * f w = 0

/-- A function is **normalized on** `S` if its values sum to zero over `S`:
    `∑ v ∈ S, f(v) = 0`. This removes the constant-function ambiguity
    from the harmonic kernel. -/
def NormalizedOn (S : Finset V) (f : V → ℤ) : Prop :=
  ∑ v ∈ S, f v = 0

/-- The **separation hypothesis** for `S` in `G`: if two harmonic functions on `S`
    are both normalized on `S` and agree on every vertex of `S`, then they are
    equal everywhere. This ensures that harmonic extensions from `S` are unique
    and encodes the geometric idea that `S` "sees" enough of the graph. -/
def SeparatedOn
    (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Prop :=
  ∀ ⦃f g : V → ℤ⦄,
    IsHarmonicOn G S f →
    IsHarmonicOn G S g →
    NormalizedOn S f →
    NormalizedOn S g →
    (∀ v ∈ S, f v = g v) →
    f = g

/-- Two functions are **firing-equivalent on** `S` if they differ by a
    Laplacian image of a function supported on `S`. This is the algebraic
    expression of chip-firing: `g = f + L · c` where `c` is supported on `S`. -/
def FiringEquivalentOn
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) (f g : V → ℤ) : Prop :=
  ∃ c : V → ℤ, (∀ v, v ∉ S → c v = 0) ∧
    ∀ v, g v = f v + ∑ w : V, graphLaplacian G v w * c w

/-- A subset `T` is a **tree attachment along** `S` in `G` if:
    1. `S` and `T` are disjoint,
    2. Every vertex in `T` has at most one neighbor in `S`,
    3. The induced subgraph on `T` is acyclic (forest),
    4. Every vertex in `T` has a path to `S` through `T`. -/
structure IsTreeAttachmentAlong
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S T : Finset V) : Prop where
  disjoint : Disjoint S T
  single_attachment : ∀ v ∈ T,
    ((S.filter (G.Adj v)).card ≤ 1)
  acyclic : ∀ v ∈ T, ∀ w ∈ T, v ≠ w →
    G.Adj v w →
    ¬∃ p : G.Walk v w, p.support.tail.toFinset ⊆ ↑T ∧ p.support.length > 2

/-- The **restricted Laplacian image** on `S`: the set of functions that arise
    as `L · c` for some `c` supported on `S`. This is the chip-firing lattice
    restricted to `S`. -/
def RestrictedLaplacianImage
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) : Set (V → ℤ) :=
  {h | ∃ c : V → ℤ, (∀ v, v ∉ S → c v = 0) ∧
    ∀ v, h v = ∑ w : V, graphLaplacian G v w * c w}

/-- The **harmonic kernel** on `S`: the set of all functions harmonic on `S`. -/
def harmonicKernel
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (S : Finset V) : Set (V → ℤ) :=
  {f | IsHarmonicOn G S f}

/-- A function is **constant** if it takes a single value everywhere. -/
def IsConstant (f : V → ℤ) : Prop :=
  ∀ v w : V, f v = f w

/-- Two functions are **equivalent modulo constants** if they differ by
    a constant function. -/
def EquivModConst (f g : V → ℤ) : Prop :=
  ∃ c : ℤ, ∀ v, f v = g v + c


-- DIFF: Catalog/Bridges/CanonicalKernelTheorems.lean
--- a/Bridges/CanonicalKernelTheorems.lean
+++ b/Bridges/CanonicalKernelTheorems.lean
@@ -463,49 +463,4 @@
   simp_all +decide [ SeparatedOn ];
   refine' ⟨ fun v => f v - g v - ( ∑ v ∈ S, ( f v - g v ) ) / S.card, _, fun v => 0, _, _, _, _ ⟩ <;> simp_all +decide [ IsHarmonicOn, NormalizedOn ];
   · simp_all +decide [ mul_sub ];
-  · exact fun h => hsep.elim fun v hv => hv <| by have := congr_fun h v; norm_num at this; linarith;
-
-
--- !-- Merged from CanonicalKernelDefs.lean (auto-dedup) -- !--
-
-This file introduces the foundational definitions for the canonical tropical
-kernel theory, connecting harmonic functions on graph subsets to chip-firing
-equivalence classes and the restricted critical group.
-* `IsHarmonicOn` — a function satisfies the discrete Laplace equation on a subset
-* `NormalizedOn` — a function sums to zero on a subset (mean-zero normalization)
-* `SeparatedOn` — the restriction-faithfulness separation hypothesis
-* `FiringEquivalentOn` — two functions differ by a Laplacian image supported on a subset
-* `IsTreeAttachmentAlong` — a set T is attached to S as a tree
-* `RestrictedLaplacianImage` — the image of the restricted Laplacian on S
-* `harmonicKernel` — the set of harmonic functions on S
-* Baker, M. and Norine, S. "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
-import Pythagorean.TropicalBridge.Defs
-/-! ### Harmonic Functions on Subsets -/
-    if for every vertex `v ∈ S`, the Laplacian of `f` at `v` vanishes:
-    `∑ w, L(v,w) · f(w) = 0`.
-    This is the discrete analogue of harmonicity in potential theory. -/
-  ∀ v ∈ S, ∑ w : V, graphLaplacian G v w * f w = 0
-/-- A function is **normalized on** `S` if its values sum to zero over `S`:
-    `∑ v ∈ S, f(v) = 0`. This removes the constant-function ambiguity
-    from the harmonic kernel. -/
-/-- The **separation hypothesis** for `S` in `G`: if two harmonic functions on `S`
-    are both normalized on `S` and agree on every vertex of `S`, then they are
-    equal everywhere. This ensures that harmonic extensions from `S` are unique
-    and encodes the geometric idea that `S` "sees" enough of the graph. -/
-    Laplacian image of a function supported on `S`. This is the algebraic
-    expression of chip-firing: `g = f + L · c` where `c` is supported on `S`. -/
-    ∀ v, g v = f v + ∑ w : V, graphLaplacian G v w * c w
-/-- A subset `T` is a **tree attachment along** `S` in `G` if:
-    1. `S` and `T` are disjoint,
-    2. Every vertex in `T` has at most one neighbor in `S`,
-    3. The induced subgraph on `T` is acyclic (forest),
-    4. Every vertex in `T` has a path to `S` through `T`. -/
-/-- The **restricted Laplacian image** on `S`: the set of functions that arise
-    as `L · c` for some `c` supported on `S`. This is the chip-firing lattice
-    restricted to `S`. -/
-    ∀ v, h v = ∑ w : V, graphLaplacian G v w * c w}
-/-- The **harmonic kernel** on `S`: the set of all functions harmonic on `S`. -/
-/-- A function is **constant** if it takes a single value everywhere. -/
-def IsConstant (f : V → ℤ) : Prop :=
-/-- Two functions are **equivalent modulo constants** if they differ by
-    a constant function. -/+  · exact fun h => hsep.elim fun v hv => hv <| by have := congr_fun h v; norm_num at this; linarith;


-- NEW_FILE: Catalog/Bridges/KTheoryNeuralAdvanced.lean
/-
  Algebraic K-Theory of Neural Architectures — Advanced Theorems

  Bridge: extends the core K-theoretic framework with deeper results on
  projective stability, Whitehead lemma analogs, spectral ce
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Collatz Parity Contraction Theory

## What We Proved

This cycle formalized four key results about Collatz orbit structure in `Catalog/Computation/CollatzParityContraction.lean`:

1. **Parity Exclusion** — after an odd Collatz step (3n+1), the result is always even, so consecutive odd steps are impossible.
2. **Power Comparison** — 3^j < 2^k whenever 2j < k (j ≥ 1), the arithmetic engine behind density contraction.
3. **Parity Density Bound** — at most ⌈k/2⌉ of the first k orbit values can be odd, a quantitative consequence of parity exclusion.
4. **Orbit Determinism** — if two Collatz trajectories meet, they agree on all subsequent iterates.

---

## Direction 1: Sharp Contraction Threshold via Real Logarithms

The current power comparison requires 2j < k (odd density < 1/2), but the optimal threshold is j/k < log(2)/log(3) ≈ 0.6309. The key insight is that the real-valued inequality j · log(3) < (k−j) · log(2) is equivalent to 3^j < 2^(k−j), which transfers to ℕ via Nat.cast_lt. This would give the tightest formal contraction criterion known.

**Why now?** Mathlib's `Real.log` API is mature enough to formalize this chain: define the contraction condition as `j * Real.log 3 < (k - j) * Real.log 2`, prove equivalence with `(3 : ℝ)^j < (2 : ℝ)^(k-j)` via `Real.exp_log` and monotonicity, then transfer to ℕ. The `pow3_le_pow4` and `pow3_lt_pow2_of_two_mul_lt` lemmas from this cycle provide the integer-side infrastructure.

**Testable claim**: For k = 100 and j = 63 (density 0.63 < log2/log3), one should be able to prove 3^63 < 2^37 using the real logarithm path, while 2·63 = 126 > 100 means the integer-only path fails.

---

## Direction 2: Orbit Affine Upper Bound

After j odd steps and e even steps in a Collatz orbit starting at n, the orbit value is bounded above by (n · 3^j + 2 · 3^j) / 2^e. The key insight is that each odd step multiplies by at most 3 and adds at most 1 (contributing the +2·3^j error term from geometric series), while each even step divides by 2. Combined with `pow3_lt_pow2_of_two_mul_lt`, this gives an explicit contraction criterion: if 2j < e, the orbit value after j+e steps is less than n for sufficiently large n.

**Why now?** The parity exclusion bound `oddCount_le_half_ceil` guarantees that e ≥ j (at least as many even steps as odd steps), and the power comparison lemma handles the 3^j vs 2^e comparison. The missing piece is formalizing the affine recurrence T(n) ≤ (3n+1)/2 for odd-then-even steps.

**Testable claim**: For n = 27 (111-step orbit), with j = 41 odd steps and e = 70 even steps, verify that 27 · 3^41 / 2^70 < 27.

---

## Direction 3: Residue Class Descent Automation

The file `Catalog/Algebra/ResidueDescent.lean` proves that a finite residue-class descent certificate would imply the Collatz conjecture. The key insight is that combining parity exclusion with modular arithmetic can automatically generate descent certificates for small moduli. For modulus 2^M, each residue class mod 2^M det
```

## Your task

Produce the deliverables listed above. Reference the specific theorems and
results in the Lean code by their @file path and statement. The Lean file is
the source of truth — your prose must accurately explain it.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). Include future directions from Phase A
in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
