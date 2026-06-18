
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
    {
      "name": "descriptive_name",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
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

**Title**: Close Proofs: The current framework considers *static* observation systems where all
**Domain**: Applications
**Mathematical framing**: Cycle a3442408 (Q=0.727) proved 2316 theorems in Applications but left 8 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: The Observation Gap

## 1. Adaptive Observation Systems and Information-Theoretic Bounds

The current framework considers *static* observation systems where all predicates are fix
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/ObservationComplexity.lean
import Mathlib
import Algebra.ObservationGap
import Algebra.AdaptiveObservationGap

/-!
# The Observation Complexity Theorem: Exact Query Cost of Indistinguishability

This file closes the **information-theoretic gap** left open by
`Catalog/Algebra/ObservationGap.lean` and
`Catalog/Algebra/AdaptiveObservationGap.lean`.

Those files prove the *one-sided* counting bound: an observation system of depth
`n` can distinguish at most `2 ^ n` elements
(`ObservationGap.observation_pigeonhole`,
`AdaptiveObservationGap.adaptive_card_le_of_distinguishes`), and that the bound is
*achievable* on `Fin (2 ^ n)` (`ObservationGap.observation_can_suffice`,
`AdaptiveObservationGap.adaptive_can_suffice`).

What was missing is the **exact query complexity** for an *arbitrary* finite type:
how many Boolean observations are *necessary and sufficient* to tell apart every
element of a type `α` with `|α|` elements?  The answer is Shannon's bound made
precise:

> the minimal depth of a distinguishing observation system equals
> `⌈log₂ |α|⌉ = Nat.clog 2 |α|`,

and — crucially — adaptivity (a decision tree whose queries may depend on earlier
answers) gives **no speedup** over a fixed family of predicates: the same number
`Nat.clog 2 |α|` is optimal for both models.

## Main results

* `distinguish_depth_ge_clog` — **lower bound**: any *adaptive* system that
  distinguishes all of `α` has depth `≥ Nat.clog 2 |α|`.  (Sharpens
  `adaptive_card_le_of_distinguishes` from a cardinality bound to a depth bound.)
* `exists_distinguishing_static` — **upper bound**: there is a *static* system of
  depth exactly `Nat.clog 2 |α|` distinguishing all of `α`.  (Generalizes
  `observation_can_suffice` from `Fin (2 ^ n)` to every finite type.)
* `min_distinguishing_depth` — **the exact complexity**: `Nat.clog 2 |α|` is the
  *least* depth admitting a distinguishing adaptive system (`IsLeast`).  This is
  the flagship theorem: lower bound (adaptive) meets upper bound (static).
* `min_distinguishing_depth_fin100` — a concrete corollary: distinguishing the
  100 elements of `Fin 100` costs exactly `7` observations.
* `generalized_observation_complexity` — the `k`-ary lower bound: for observations
  valued in a `k`-element type the cost is `≥ Nat.clog k |α|`.

## References
* C. E. Shannon, *A mathematical theory of communication* (1948) — the "1 bit per
  query" decision-tree lower bound.
-/

namespace ObservationComplexity

open ObservationGap AdaptiveObservationGap

universe u

-- !-- Lab Notebook: distinguish_depth_ge_clog -- !--
-- !-- Hypothesis: the pigeonhole cardinality bound |α| ≤ 2^n should sharpen into a
--     query lower bound n ≥ clog₂|α| by applying clog monotonicity. -- !--
-- !-- Result: Proved. From adaptive_card_le_of_distinguishes we get |α| ≤ 2^n; apply
--     Nat.clog_mono_right and Nat.clog_pow to conclude clog 2 |α| ≤ clog 2 (2^n) = n. -- !--
-- !-- Insight: clog is the exact inverse of (2 ^ ·) on powers, so the counting bound
--     and the depth bound are literally the same statement transported through clog. -- !--
-- !-- Failure analysis: A direct induction on the tree depth is unnecessary; reusing the
--     already-proven cardinality bound is far cleaner. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: |α| ≤ 2^n (adaptive_card_le_of_distinguishes); clog 2 (·) is monotone
--     and clog 2 (2^n) = n, hence clog 2 |α| ≤ n. -- !--
/-- **Information-theoretic lower bound.**  Any adaptive observation system of depth
`n` that distinguishes every element of a finite type `α` must satisfy
`Nat.clog 2 |α| ≤ n`.  Equivalently: at least `⌈log₂ |α|⌉` Boolean queries are
necessary, even with full adaptivity. -/
theorem distinguish_depth_ge_clog {α : Type u} [Fintype α] {n : ℕ}
    (O : AdaptiveObs α n) (hinj : Function.Injective O.transcript) :
    Nat.clog 2 (Fintype.card α) ≤ n := by
  have h := adaptive_card_le_of_distinguishes O hinj
  calc Nat.clog 2 (Fintype.card α) ≤ Nat.clog 2 (2 ^ n) := Nat.clog_mono_right 2 h
    _ = n := Nat.clog_pow 2 n (by norm_num)

-- !-- Lab Notebook: exists_distinguishing_static -- !--
-- !-- Hypothesis: observation_can_suffice handles Fin (2^n); a general α with |α| ≤ 2^n
--     should inherit a distinguishing system by pulling predicates back along an
--     embedding α ↪ Fin (2^n). -- !--
-- !-- Result: Proved. Take n = clog 2 |α|; then |α| ≤ 2^n (Nat.le_pow_clog), giving an
--     embedding e; pull back the bit-extraction system from observation_can_suffice. -- !--
-- !-- Insight: The optimal *static* construction is just "binary-encode an injection into
--     Fin (2^n)", so the catalog's Fin (2^n) result is genuinely the universal case. -- !--
-- !-- Failure analysis: First considered a bespoke testBit system on α directly, but
--     reusing observation_can_suffice through the embedding avoids re-deriving bit lemmas. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: |α| ≤ 2^(clog 2 |α|) (Nat.le_pow_clog), so ∃ embedding e : α ↪ Fin(2^n);
--     pull back observation_can_suffice's system: pred i a := O'.pred i (e a). -- !--
/-- **Matching upper bound (static, hence adaptive).**  Every finite type `α` admits
a *static* observation system of depth exactly `Nat.clog 2 |α|` that distinguishes
all of its elements.  Generalizes `ObservationGap.observation_can_suffice` from
`Fin (2 ^ n)` to an arbitrary finite type. -/
theorem exists_distinguishing_static {α : Type u} [Fintype α] [DecidableEq α] :
    ∃ O : ObsSys α (Nat.clog 2 (Fintype.card α)),
      ∀ a b : α, O.twins a b → a = b := by
  set n := Nat.clog 2 (Fintype.card α) with hn
  have hcard : Fintype.card α ≤ Fintype.card (Fin (2 ^ n)) := by
    simpa using Nat.le_pow_clog (by norm_num) (Fintype.card α)
  obtain ⟨e⟩ := Function.Embedding.nonempty_of_card_le hcard
  obtain ⟨O', hO'⟩ := ObservationGap.observation_can_suffice n
  exact ⟨⟨fun i a => O'.pred i (e a)⟩, fun a b h => e.injective (hO' _ _ h)⟩

-- !-- Lab Notebook: min_distinguishing_depth -- !--
-- !-- Hypothesis: clog 2 |α| is simultaneously a lower bound (adaptive) and achievable
--     (static), hence it is the exact least distinguishing depth. -- !--
-- !-- Result: Proved as IsLeast. Membership from exists_distinguishing_static converted
--     to an adaptive system via AdaptiveObs.ofStatic + twins_ofStatic; the lower-bound
--     half is distinguish_depth_ge_clog. -- !--
-- !-- Insight: The least element of the achievable-depth set is identical for the static
--     and adaptive models — a precise statement that *adaptivity buys no speedup*. -- !--
-- !-- Failure analysis: Stating it as IsLeast (rather than an sInf equality) sidesteps the
--     need to pad small trees up to larger depths. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Sketch: lower half = distinguish_depth_ge_clog; membership: turn the static system
--     of exists_distinguishing_static into AdaptiveObs.ofStatic, whose transcript equals
--     the static profile (twins_ofStatic), so injectivity = the distinguishing property. -- !--
/-- **The Observation Complexity Theorem.**  `Nat.clog 2 |α|` is the *least* depth `n`
for which some adaptive observation system of depth `n` distinguishes every element
of `α`.  The lower bound holds for adaptive systems and is met by a static one, so
the exact Boolean query complexity of distinguishability is `⌈log₂ |α|⌉` and
adaptivity provides no advantage. -/
theorem min_distinguishing_depth (α : Type u) [Fintype α] [DecidableEq α] :
    IsLeast {n : ℕ | ∃ O : AdaptiveObs α n, Function.Injective O.transcript}
      (Nat.clog 2 (Fintype.card α)) := by
  refine ⟨?_, ?_⟩
  · obtain ⟨O, hO⟩ := exists_distinguishing_static (α := α)
    exact ⟨AdaptiveObs.ofStatic O, fun a b h => hO a b ((twins_ofStatic O a b).1 h)⟩
  · rintro n ⟨O, hinj⟩
    exact distinguish_depth_ge_clog O hinj

-- !-- Lab Notebook: min_distinguishing_depth_fin100 -- !--
-- !-- Hypothesis: instantiating the complexity theorem at Fin 100 should give the clean
--     numeric answer 7 = ⌈log₂ 100⌉. -- !
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Observation Complexity Cycle

## Synthesis

This cycle attacked the *information-theoretic gap* in the Observation framework
(`Catalog/Algebra/ObservationGap.lean`, `Catalog/Algebra/AdaptiveObservationGap.lean`).
Those files establish only the **one-sided** counting law: an observation system of
depth `n` can separate at most `2 ^ n` elements, and that bound is *achievable* on
`Fin (2 ^ n)`. What was missing is the **exact query complexity** for an arbitrary
finite type. We closed this gap in `Catalog/Algebra/ObservationComplexity.lean` with
the theorem that the minimal depth needed to distinguish every element of a finite
type `α` is exactly `Nat.clog 2 |α| = ⌈log₂ |α|⌉`, stated as an `IsLeast` fact
(`min_distinguishing_depth`).

The structural insight that drove the proof is that `Nat.clog` is the *exact* inverse
of `2 ^ ·` on powers (`Nat.clog_pow`, `Nat.le_pow_clog`). This lets us *transport*
both directions of the existing counting law into a single depth statement: the
cardinality bound `|α| ≤ 2 ^ n` becomes the depth lower bound by monotonicity of
`clog`, and the `Fin (2 ^ n)` sufficiency result becomes a general construction by
binary-encoding an embedding `α ↪ Fin (2 ^ n)`. A second, conceptual payoff is that
the *same* number `Nat.clog 2 |α|` is optimal for both the static and the adaptive
(decision-tree) models — the lower bound is proved for adaptive systems while the
matching upper bound is realized by a static one — so **adaptivity buys no speedup**
for the pure distinguishability task. The only genuine subtlety surfaced in the
generalization: the base-`k` version is sharp only for `k ≥ 2`, and the `k ≤ 1`
boundary (where `Nat.clog` collapses to `0`) had to be handled by an explicit case
split. That degenerate case is itself informative: a unary alphabet carries no
discriminative power, which is exactly why the logarithmic law needs `k ≥ 2`.

What did *not* work cleanly: an attempt to phrase the result as an `sInf` equality
between the static and adaptive optimal depths would have forced us to *pad* small
decision trees up to larger depths (a constructive operation on the `AdaptiveObs`
inductive type). Re-casting the statement as `IsLeast` sidestepped this entirely and
is in fact the stronger, cleaner statement. The padding operation remains an
interesting missing primitive (see Direction 3).

## Results Summary

- `distinguish_depth_ge_clog`: **proved** — any adaptive system distinguishing all of
  `α` has depth `≥ Nat.clog 2 |α|`; sharpens the catalog cardinality bound into a
  query lower bound.
- `exists_distinguishing_static`: **proved** — a static system of depth exactly
  `Nat.clog 2 |α|` distinguishes every finite type, generalizing
  `observation_can_suffice` from `Fin (2 ^ n)` to all finite types.
- `min_distinguishing_depth`: **proved** (flagship) — `Nat.clog 2 |α|` is the least
  depth admitting a distinguishing adaptive system; the exact query complexity, with
  adaptivity giving no advantage.

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
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a name, a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
