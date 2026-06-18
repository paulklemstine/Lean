
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

**Title**: This cycle isolated the *cardinal mechanism* behind the bridge between
**Domain**: Novelty
**Mathematical framing**: # Future Directions: The Oracle Counting Barrier

## Synthesis

This cycle isolated the *cardinal mechanism* behind the bridge between
finite-description complexity and three-valued oracle non-computability, and reduced
it to a single, domain-agnostic counting fact. The file
`Catalog/Computation/OracleCountingBarrier.lean` proves eight results that together
say: the space of three-valued oracles on `N` statements has size `3 ^ N`
(`oracle_card`); any program space strictly smaller than the oracle space fails to
cover it, for *any* answer alphabet (`oracle_not_covered_generic`) and in particular
for three verdicts (`oracle_not_covered`); a fixed program budget `b ^ k` is eventually
outrun by `3 ^ N` (`budget_gap_exists`); binary descriptions of length `N` are strictly
too poor, `2 ^ N < 3 ^ N` (`binary_insufficient`); the computable fraction
`C / 3 ^ N → 0` for any constant budget (`computable_fraction_tendsto_zero`); and the
binary-reachable fraction is the *exact* geometric law `2 ^ N / 3 ^ N = (2/3) ^ N`
(`binary_fraction_eq`) which itself vanishes (`binary_fraction_tendsto_zero`).

The structural insight that organizes all of this: the **coverage** obstruction and the
**information** obstruction are logically independent. Coverage needs nothing about the
number "3" — `oracle_not_covered_generic` is stated and proved for an arbitrary alphabet
size `a` and follows purely from `Fintype.card_le_of_surjective` together with the
function-space count `Fintype.card_fun`. The number "3" enters only the information
story, where it produces the binary deficit `2 ^ N < 3 ^ N` and, sharpened, the exact
rate `(2/3) ^ N`. Factoring the argument this way is what makes each proof one or two
lines and makes the core lemma reusable across domains by merely changing the codomain.

This cycle also realized two of the directions proposed in the seed concept: the
alphabet-generic barrier (the seed's Direction 2) is now proved as
`oracle_not_covered_generic` with the `a = 3` case recovered as the one-line
specialization `oracle_not_covered`, confirming the claim that the "3" was never used by
coverage; and the exact `(2/3) ^ N` law (the seed's Direction 1) is now proved as
`binary_fraction_eq`/`binary_fraction_tendsto_zero`, upgrading the constant-budget
limit to a closed form. The catalog connection is to `Computation/OracleBurden.lean`
(oracle jump hierarchy via provability sets) and `Computation/Oracles/Foundation.lean`
(geodesic idempotent oracles): this file supplies the single counting lemma those
chains can specialize, replacing an ascending sequence of separations by one cardinal
inequality.

## Results Summary

- `oracle_card`: proved — there are exactly `3 ^ N` three-valued oracles on `N` statements.
- `oracle_not_covered_generic`: proved — the reusable, alphabet-agnostic barrier: `card P < a ^ N` forces some oracle to escape every compilation `f : P → (Fin N → Fin a)`.
- `oracle_not_covered`: proved — the `a = 3` specialization, a one-line corollary of the generic barrier.
- `budget_gap_exists`: proved — every fixed budget `b ^ k` is eventually outrun by `3 ^ N`.
- `binary_insufficient`: proved — `2 ^ N < 3 ^ N` for `N ≥ 1`; the information deficit of binary descriptions (boundary `N = 0` is exactly where it fails).
- `computable_fraction_tendsto_zero`: proved — for any constant budget `C`, the nameable fraction `C / 3 ^ N → 0`.
- `binary_fraction_eq`: proved — the binary-reachable fraction is the exact geometric law `2 ^ N / 3 ^ N = (2/3) ^ N`.
- `binary_fraction_tendsto_zero`: proved — that exact fraction vanishes geometrically.

## Research Directions

### Direction 1: Logically Consistent Oracles Still Escape
**Hypothesis**: Fix a relation `R` of implications `i → j` among the `N` statements and
call an oracle *consistent* if it never assigns verdict `true` to `i` while assigning a
non-`true` verdict to `j` for `i → j ∈ R`. Whenever `R` leaves a linear-in-`N` antichain
of mutually independent statements, the number `L(N,R)` of consistent oracles still
exceeds `2 ^ N`, so the barrier `card P < L(N,R)` continues to bite.
**Test**: Define the consistent-oracle subtype as a `Fintype`, lower-bound its
cardinality by `3 ^ k` on a `k`-element independent antichain (an explicit injection
from `Fin k → Fin 3`), and feed that bound into `oracle_not_covered_generic`. Disproof
would be an `R` collapsing `L(N,R)` to a polynomial in `N`.
**Why now**: `oracle_not_covered_generic` already takes an *arbitrary* finite codomain
embedded in the oracle space, so only the counting lower bound is missing.
**If true**: Adding logical structure does not restore computability — the barrier is
robust to consistency constraints.
**If false**: There is a structured implication pattern that polynomially compresses the
oracle space, identifying exactly which logical constraints buy computability.

### Direction 2: Composition Amplifies the Gap (Finite Jump)
**Hypothesis**: The composition space `Oracle N → Oracle N` has cardinality
`(3 ^ N) ^ (3 ^ N) = 3 ^ (N · 3 ^ N)`, which exceeds `3 ^ (b ^ k)` for every fixed
budget and every `N ≥ 1`; hence composing oracles is strictly costlier to describe than
evaluating them — a finite, fully constructive analogue of the Turing jump.
**Test**: Prove `Fintype.card (Oracle N → Oracle N) = 3 ^ (N * 3 ^ N)` by applying
`oracle_card` and `Fintype.card_fun`, then derive `b ^ k < 3 ^ (N * 3 ^ N)` from an
iterate of `budget_gap_exists`. Falsified by a fixed-budget program family realizing all
compositions.
**Why now**: `oracle_card` and `budget_gap_exists` give both the base count and the
growth lemma; the composition count is just `card_fun` applied once more.
**If true**: The "jump" phenomenon is exhibited by a bare cardinal inequality with no
appeal to the halting problem.
**If false**: Some structural compression of oracle-to-oracle maps exists, which would be
a surprising finite analogue of degree collapse.

### Direction 3: The Exact Reachability Spectrum
**Hypothesis**: For each alphabet size `a` and binary description length `m`, the fraction
of `a`-valued oracles on `N` statements reachable by length-`m` binary descriptions is
exactly `min(2 ^ m, a ^ N) / a ^ N`, and for `m = c · N` with `c < log₂ a` it tends to `0`
geometrically while for `c > log₂ a` it is eventually `1`.
**Test**: Generalize `binary_fraction_eq` to `2 ^ (c*N) / a ^ N` and locate the threshold
`c = log₂ a` via `Real.logb`; prove the two-sided dichotomy with
`tendsto_pow_atTop_nhds_zero_of_lt_one` and its `> 1` counterpart. Falsified if the
transition is not sharp at `log₂ a`.
**Why now**: `binary_fraction_eq`/`binary_fraction_tendsto_zero` already pin the `a = 3`,
`m = N` point of this spectrum exactly.
**If true**: The information deficit is a sharp phase transition in description rate, the
finite shadow of Shannon source coding.
**If false**: The reachable fraction has nontrivial sub-geometric behavior near the
threshold, revealing structure beyond pure counting.

### Direction 4: Confidence Oracles via Discretization Limit
**Hypothesis**: Real-valued confidence oracles `Fin N → [0,1]`, discretized to `a` levels,
inherit the barrier uniformly in `a`: for every fixed program budget there is a
resolution `a` and size `N` with `card P < a ^ N`, and the barrier survives the limit
`a → ∞`.
**Test**: Instantiate `oracle_not_covered_generic` at growing `a`, and formalize the
discretization map `[0,1] → Fin a` to show realizable verdict vectors still number `a ^ N`
on an independent probe set. Falsified if continuity constraints cap the realizable count
below `a ^ N`.
**Why now**: `oracle_not_covered_generic` is already alphabet-parametric, so only the
discretization bookkeeping is new.
**If true**: The barrier covers decision, modal, and confidence oracles under one lemma.
**If false**: Continuous confidence assignments are genuinely more compressible than
discrete verdicts, isolating where analysis beats counting.

### Direction 5: Tropical Solution Oracles Inherit the Barrier
**Hypothesis**: Mapping each tropical polynomial system on `n` equations to its
three-valued verdict vector (feasible / infeasible / degenerate per probe point) yields
`≥ 2 ^ n` realizable vectors, so by `oracle_not_covered` no fixed-size family of tropical
certificates computes them all.
**Test**: Pair the verdict map with the catalog's `Tropical/ComplexityTransfer.lean`,
lower-bound the count of realizable verdict vectors via tropical hyperplane-arrangement
counts, and apply `oracle_not_covered`. For `n ≤ 5`, enumerate realizable vectors and
compare to `3 ^ N`; a small certificate family reproducing all vectors falsifies the
transfer.
**Why now**: Discretizing tropical solution sets into a three-valued verdict makes them
honest elements of `Oracle N`, so the *same* `oracle_not_covered` applies with no new
combinatorics.
**If true**: The oracle barrier transfers verbatim into tropical geometry, a genuine
cross-domain bridge.
**If false**: Tropical solution sets are constrained enough to be polynomially
certifiable, which would itself be a strong structural theorem.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/OracleBarrierExtensions.lean
import Mathlib

/-!
# Oracle Counting Barrier — Extensions

This file extends `Computation/OracleCountingBarrier.lean` along two of the research
directions the foundational file opened:

* **Constructive diagonalization** (`oracle_diagonal_escape`): when the program space is
  the *index set itself* (`Fin N` descriptions for `N` statements), the escaping oracle
  is produced *explicitly* by a Cantor-style diagonal — no pigeonhole, no `by_contra`.
  Works for any alphabet with at least two verdicts.

* **Composition amplifies the gap — a finite Turing jump** (`oracle_comp_card`,
  `oracle_comp_jump`, `oracle_comp_budget_gap`): the space of oracle-to-oracle maps has
  cardinality `3 ^ (N · 3 ^ N)`, strictly larger than the evaluation space `3 ^ N` for
  every `N ≥ 1`, and it outruns every fixed program budget. Composing oracles is
  strictly costlier to describe than evaluating them — a fully constructive, finite
  analogue of the Turing jump, exhibited by a bare cardinal inequality.

* **Robustness to logical structure** (`consistent_oracles_escape`): the barrier
  survives *any* consistency constraint that still admits an independent `3`-valued
  block of size `k`. If the consistent oracles contain an injective copy of
  `Fin k → Fin 3` and the program space has fewer than `3 ^ k` elements, some
  *consistent* oracle escapes every compilation. Adding logical structure does not
  restore computability.

The module is self-contained (it re-states the one-line `Oracle` abbreviation and the
base count) so that it compiles independently; the mathematical lineage is the
foundational file `OracleCountingBarrier.lean`.
-/

namespace OracleBarrier

/-- A three-valued oracle on `N` statements (mirrors `Oracle` in the foundation file). -/
abbrev Oracle (N : ℕ) := Fin N → Fin 3

/-- There are exactly `3 ^ N` three-valued oracles on `N` statements
(`oracle_card` in the foundation file). -/
theorem oracle_card (N : ℕ) : Fintype.card (Oracle N) = 3 ^ N := by
  simp [Oracle]

/-- The growth lemma `budget_gap_exists` from the foundation file. -/
theorem budget_gap_exists (b k : ℕ) : ∃ N, b ^ k < 3 ^ N :=
  pow_unbounded_of_one_lt (b ^ k) (by norm_num)

-- !-- comment -- !--
-- Cantor diagonal: define `g i := (f i i + 1) mod a`. Then `g` differs from the `i`-th
-- description at coordinate `i`, so no description equals it. Case-split on whether
-- `f i i + 1 < a` (no wraparound) or `= a` (wraps to `0`) to evaluate the mod, since
-- `omega` cannot reason about a variable modulus.
-- !-- comment -- !--
/-- **Constructive diagonal escape.** For any alphabet with at least two verdicts, given
`N` descriptions `f : Fin N → (Fin N → Fin a)` of oracles on `N` statements, an escaping
oracle is built *explicitly* by diagonalization: it disagrees with the `i`-th
description at coordinate `i`. -/
theorem oracle_diagonal_escape {N a : ℕ} (ha : 2 ≤ a)
    (f : Fin N → (Fin N → Fin a)) :
    ∃ g : Fin N → Fin a, ∀ i, f i ≠ g := by
  refine ⟨fun i => ⟨((f i i : ℕ) + 1) % a, Nat.mod_lt _ (by omega)⟩, ?_⟩
  intro i hi
  have hval : (f i i : ℕ) = ((f i i : ℕ) + 1) % a := by
    have := congrFun hi i
    simpa [Fin.ext_iff] using this
  have hlt : (f i i : ℕ) < a := (f i i).isLt
  rcases lt_or_eq_of_le (Nat.succ_le_of_lt hlt) with h | h
  · have h' : (f i i : ℕ) + 1 < a := h
    rw [Nat.mod_eq_of_lt h'] at hval; omega
  · have h' : (f i i : ℕ) + 1 = a := h
    rw [h', Nat.mod_self] at hval; omega

-- !-- comment -- !--
-- Counting oracle-to-oracle maps: `card (Oracle N → Oracle N) = (3 ^ N) ^ (3 ^ N)`
-- by `Fintype.card_fun` and `oracle_card`, and `(3 ^ N) ^ (3 ^ N) = 3 ^ (N · 3 ^ N)`
-- by collapsing the power tower with `pow_mul`.
-- !-- comment -- !--
/-- The composition space of oracle-to-oracle maps has cardinality `3 ^ (N · 3 ^ N)`. -/
theorem oracle_comp_card (N : ℕ) :
    Fintype.card (Oracle N → Oracle N) = 3 ^ (N * 3 ^ N) := by
  rw [Fintype.card_fun, oracle_card, ← pow_mul]

-- !-- comment -- !--
-- Finite jump: evaluation space `3 ^ N` is strictly below composition space
-- `3 ^ (N · 3 ^ N)` because `N < N · 3 ^ N` for `N ≥ 1` (as `3 ^ N ≥ 2`); apply strict
-- monotonicity of `3 ^ ·`.
-- !-- comment -- !--
/-- **The finite Turing jump.** For `N ≥ 1`, the evaluation space is strictly smaller
than the composition space: composing oracles is strictly costlier to describe than
evaluating them. -/
theorem oracle_comp_jump {N : ℕ} (hN : 1 ≤ N) :
    Fintype.card (Oracle N) < Fintype.card (Oracle N → Oracle N) := by
  rw [oracle_card, oracle_comp_card]
  apply Nat.pow_lt_pow_right (by norm_num)
  have h3 : 2 ≤ 3 ^ N := by
    calc 2 ≤ 3 ^ 1 := by norm_num
    _ ≤ 3 ^ N := Nat.pow_le_pow_right (by norm_num) hN
  nlinarith [Nat.one_le_iff_ne_zero.mpr (show N ≠ 0 by omega)]

-- !-- comment -- !--
-- Composition outruns every fixed budget: pick `N` with `b ^ k < 3 ^ N` (growth lemma),
-- then `3 ^ N ≤ 3 ^ (N · 3 ^ N) = card`.
-- !-- comment -- !--
/-- The composition space outruns every fixed program budget `b ^ k`. -/
theorem oracle_comp_budget_gap (b k : ℕ) :
    ∃ N, b ^ k < Fintype.card (Oracle N → Oracle N) := by
  obtain ⟨N, hN⟩ := budget_gap_exists b k
  refine ⟨N, ?_⟩
  rw [oracle_comp_card]
  calc b ^ k < 3 ^ N := hN
  _ ≤ 3 ^ (N * 3 ^ N) :=
      Nat.pow_le_pow_right (by norm_num) (Nat.le_mul_of_pos_right N (by positivity))

-- !-- comment -- !--
-- Robustness via the generic barrier: the consistent oracles contain an injective image
-- of `Fin k → Fin 3`, hence at least `3 ^ k` of them; a program space of size `< 3 ^ k`
-- has range too small to cover that image, so some consistent oracle escapes
-- (pigeonhole on Finset cardinalities).
-- !-- comment -- !--
/-- **Robustness to consistency constraints.** Suppose the consistent oracles (those
satisfying a predicate `C`) contain an injective copy `emb` of an independent
`3`-valued block `Fin k → Fin 3`. Then any program space with fewer than `3 ^ k`
descriptions fails to cover them: some *consistent* oracle escapes every compilation.
Adding logical structure does not restore computability. -/
theorem consistent_oracles_escape {P : Type*} [Fintype P] {N k : ℕ}
    (C : Oracle N → Prop)
    (emb : (Fin k → Fin 3) → Oracle N) (hemb : Function.Injective emb)
    (hC : ∀ x, C (emb x))
    (f : P → Oracle N) (hcard : Fintype.card P < 3 ^ k) :
    ∃ g : Oracle N, C g ∧ ∀ p, f p ≠ g := by
  classical
  set A : Finset (Oracle N) := Finset.univ.image emb with hA
  set B : Finset (Oracle N) := Finset.univ.image f with hB
  have hcardA : A.card = 3 ^ k := by
    rw [hA, Finset.card_image_of_injective _ hemb, Finset.card_univ]
    simp
  have hcardB : B.card ≤ Fintype.card P := by
    rw [hB]; exact le_trans (Finset.card_image_le) (by simp [Finset.card_univ])
  have hnsub : ¬ A ⊆ B := by
    intro hsub
    have := Finset.card_le_card hsub
    omega
  obtain ⟨a, haA, haB⟩ := Finset.not_subset.mp hnsub
  rw [hA, Finset.mem_image] at haA
  obtain ⟨x, _, hx⟩ := haA
  refine ⟨a, hx ▸ hC x, ?_⟩
  intro p hp
  apply haB
  rw [hB, Finset.mem_image]
  exact ⟨p, Finset.mem_univ p, hp⟩

end OracleBarrier

/-!
## Lab Notebook

-- !-- Lab Notebook -- !--

**Hypothesis.** The nonconstructive coverage barrier should have a *constructive* core
when the program space is the index set, and the barrier should *amplify* under
composition and *survive* logical-consistency constraints.

**Result.** All three confirmed. (1) `oracle_diagonal_escape` produces the escaping
oracle by an explicit diagonal flip, valid for any alphabet `a ≥ 2`. (2) The composition
count is the exact power tower `3 ^ (N · 3 ^ N)` (`oracle_comp_card`); it strictly
dominates `3 ^ N` for `N ≥ 1` (`oracle_comp_jump`) and outruns any fixed budget
(`oracle_comp_budget_gap`) — a finite Turing jump with no appeal to the halting
problem. (3) `consistent_oracles_escape` shows a `3 ^ k` independent block inside the
consistent oracles already defeats any sub-`3 ^ k` program space.

**Insight.** The composition jump is *purely cardinal*
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Oracle Counting Barrier

## Synthesis

This cycle isolated the *cardinal mechanism* behind the bridge between
finite-description complexity and three-valued oracle non-computability, and reduced it
to a single, domain-agnostic counting fact. Two Lean files carry the work.

`Catalog/Computation/OracleCountingBarrier.lean` proves eight foundational results: the
space of three-valued oracles on `N` statements has size `3 ^ N` (`oracle_card`); any
program space strictly smaller than the oracle space fails to cover it for *any* answer
alphabet (`oracle_not_covered_generic`) and in particular for three verdicts
(`oracle_not_covered`); a fixed program budget `b ^ k` is eventually outrun by `3 ^ N`
(`budget_gap_exists`); binary descriptions of length `N` are strictly too poor,
`2 ^ N < 3 ^ N` (`binary_insufficient`); the computable fraction `C / 3 ^ N → 0` for any
constant budget (`computable_fraction_tendsto_zero`); and the binary-reachable fraction is
the *exact* geometric law `2 ^ N / 3 ^ N = (2/3) ^ N` (`binary_fraction_eq`), which itself
vanishes (`binary_fraction_tendsto_zero`).

`Catalog/Computation/OracleBarrierExtensions.lean` pushes three directions further: a
*constructive* Cantor diagonal that exhibits the escaping oracle explicitly when the
program space is the index set (`oracle_diagonal_escape`); a finite Turing jump
(`oracle_comp_card`, `oracle_comp_jump`, `oracle_comp_budget_gap`) showing the
oracle-to-oracle space has the exact size `3 ^ (N · 3 ^ N)`, strictly above the
evaluation space `3 ^ N` for every `N ≥ 1` and beyond every fixed budget; and a
robustness theorem (`consistent_oracles_escape`) proving that any consistency constraint
leaving an independent `3`-valued block of size `k` keeps the barrier biting against any
sub-`3 ^ k` program space.

The structural insight that organizes all of this: the **coverage** obstruction and the
**information** obstruction are logically independent. Coverage needs nothing about the
number "3" — `oracle_not_covered_generic` is stated and proved for an arbitrary alphabet
size `a` and follows purely from `Fintype.card_le_of_surjective` together with the
function-space count `Fintype.card_fun`. The number "3" enters only the information story,
where it produces the binary deficit `2 ^ N < 3 ^ N` and, sharpened, the exact rate
`(2/3) ^ N`. Factoring the argument this way is what makes each proof one or two lines and
makes the core lemma reusable across domains by merely changing the codomain. The catalog
connections are to `Computation/OracleBurden.lean` (oracle jump hierarchy via provability
sets) and `Computation/Oracles/Foundation.lean` (geodesic idempotent oracles): this work
supplies the single counting lemma those chains can specialize, replacing an ascending
sequence of separations by one cardinal inequality, and now a finite, fully constructive
jump.

## Results Summary

- `oracle_card`: proved — exactly `3 ^ N` three-valued oracles on `N` statements.
- `oracle_not_co
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
