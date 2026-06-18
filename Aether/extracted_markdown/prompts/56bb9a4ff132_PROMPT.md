
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

**Title**: Close Proofs: **Entropy-Bounded Computation (EBC)** framew
**Domain**: Novelty
**Mathematical framing**: Cycle 1aaaec8c (Q=0.425) proved 388 theorems in Applications but left 4 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: Computational Complexity as Physical Law

## Synthesis

This research cycle established the **Entropy-Bounded Computation (EBC)** framework, which formalizes the connection betwee
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/EntropyBoundedComputation.lean
import Mathlib

/-!
# Entropy-Bounded Computation (EBC)

This file develops a small, fully formal core for the **Entropy-Bounded Computation**
framework, which treats a single deterministic computational step as a function
between finite *state spaces* and measures its information content by the
base-2 logarithm of the number of states (the Shannon entropy of the uniform
distribution over the states, measured in bits).

The guiding physical intuition is **Landauer's principle**: erasing or merging
logical states is necessarily irreversible and carries a nonnegative entropy
cost.  Here we isolate the purely mathematical skeleton of that statement.

## Main results

* `EBC.entropy_nonneg` — entropy of a nonempty finite state space is `≥ 0`.
* `EBC.entropy_eq_zero_of_card_one` — a single-state machine stores no information.
* `EBC.entropy_reversible_invariant` — reversible (bijective) computation
  preserves entropy.
* `EBC.entropy_prod` — entropy is additive over independent (product) state spaces.
* `EBC.entropy_le_of_surjective` — deterministic computation cannot create
  entropy (a data-processing / second-law inequality).
* `EBC.landauer_erasure_pos` — erasing a state space with at least two states
  to a single state has strictly positive entropy cost.
* `EBC.landauer_erasure_eq` — the entropy released by erasure equals the source
  entropy and is nonnegative.

This extends the catalog's `Computation/EntropyBridge.lean`, which bounds
*cardinality* via injective encodings; here we package the log-cardinality as a
genuine real-valued entropy and prove its structural laws.
-/

namespace EBC

open scoped Real

/-- The Shannon entropy, in bits, of the uniform distribution over a finite type
of computational states: the base-2 logarithm of the number of states. -/
noncomputable def entropy (S : Type*) [Fintype S] : ℝ :=
  Real.logb 2 (Fintype.card S)

@[simp] theorem entropy_def (S : Type*) [Fintype S] :
    entropy S = Real.logb 2 (Fintype.card S) := rfl

-- !-- Card of a nonempty fintype is ≥ 1, and logb base 2 of something ≥ 1 is ≥ 0. -- !--
/-- A nonempty finite state space carries nonnegative entropy. -/
theorem entropy_nonneg (S : Type*) [Fintype S] [Nonempty S] : 0 ≤ entropy S :=
  Real.logb_nonneg (by norm_num) (mod_cast Fintype.card_pos)

-- !-- A single-state machine stores no information: card = 1 ⇒ logb 2 1 = 0. -- !--
/-- A state space with exactly one state has zero entropy. -/
theorem entropy_eq_zero_of_card_one (S : Type*) [Fintype S]
    (h : Fintype.card S = 1) : entropy S = 0 := by
  unfold entropy; aesop

-- !-- Bijection preserves cardinality, hence preserves logb of cardinality. -- !--
/-- **Reversibility preserves entropy.** A bijection between finite state spaces
(a reversible computation) leaves the entropy unchanged. -/
theorem entropy_reversible_invariant {S T : Type*} [Fintype S] [Fintype T]
    (e : S ≃ T) : entropy S = entropy T := by
  simp [entropy, Fintype.card_congr e]

-- !-- card (S × T) = card S * card T and logb is additive on positive args. -- !--
/-- **Independent composition is additive.** The entropy of a product state
space is the sum of the component entropies. -/
theorem entropy_prod (S T : Type*) [Fintype S] [Fintype T]
    [Nonempty S] [Nonempty T] :
    entropy (S × T) = entropy S + entropy T := by
  convert Real.logb_mul ?_ ?_ using 1
  · norm_num [entropy]
  · exact Nat.cast_ne_zero.mpr Fintype.card_ne_zero
  · exact Nat.cast_ne_zero.mpr Fintype.card_ne_zero

-- !-- A surjection forces card T ≤ card S; logb base > 1 is monotone. -- !--
/-- **Second law / data-processing inequality.** A deterministic computation
`f : S → T` that hits every output (surjective) cannot increase entropy. -/
theorem entropy_le_of_surjective {S T : Type*} [Fintype S] [Fintype T]
    [Nonempty S] {f : S → T} (hf : Function.Surjective f) :
    entropy T ≤ entropy S := by
  unfold entropy
  gcongr
  · norm_num
  · exact Nat.cast_pos.mpr (Fintype.card_pos_iff.mpr ⟨f (Classical.arbitrary S)⟩)
  · exact Fintype.card_le_of_surjective f hf

-- !-- card ≥ 2 ⇒ logb 2 (card) > logb 2 1 = 0 by strict monotonicity. -- !--
/-- **Landauer cost of erasure.** Resetting a state space with at least two
states to a single fixed state dissipates strictly positive entropy. -/
theorem landauer_erasure_pos (S : Type*) [Fintype S]
    (h : 2 ≤ Fintype.card S) : 0 < entropy S :=
  Real.logb_pos (by norm_num) (mod_cast h)

-- !-- The target T has zero entropy, so the dissipated entropy collapses to entropy S. -- !--
/-- The entropy released by erasing `S` down to one cleared state is exactly
`entropy S`, and it is nonnegative. -/
theorem landauer_erasure_eq {S T : Type*} [Fintype S] [Fintype T]
    [Nonempty S] (h : Fintype.card T = 1) :
    entropy S - entropy T = entropy S ∧ 0 ≤ entropy S - entropy T := by
  have hT : entropy T = 0 := entropy_eq_zero_of_card_one T h
  exact ⟨by rw [hT, sub_zero], by rw [hT, sub_zero]; exact entropy_nonneg S⟩

end EBC



-- NEW_FILE: Catalog/Cryptography/ModuleLWE/Compression.lean
import Mathlib
import Cryptography.ModuleLWE.Defs

/-!
# Theorem C: Compliance-Safe Compression via Linear Noise Bound

This module proves that linear compression maps preserve decryption correctness
when the error lies within a certified radius. The key insight is that the
operator norm of the compression map controls the noise amplification:
if `‖e‖ ≤ δ` and the decoder tolerates errors up to `‖f‖ * δ`,
then compression preserves correctness.

This connects cryptographic correctness proofs to functional analysis /
operator norms, giving a mathematically principled route from abstract
reductions to standards compliance (e.g., NIST parameter validation).

## Proof Strategy

The proof uses the continuous linear map norm bound:
  ‖f e‖ ≤ ‖f‖ * ‖e‖ ≤ ‖f‖ * δ
Combined with the decoder's correctness hypothesis, this yields the result.
-/

open Finset BigOperators

noncomputable section

/-! ## Main Compression Correctness Theorem -/

/-- **Compliance-Safe Compression Bound via Linear Noise Radius**.

Let `f : M →L[𝕜] N` be a continuous linear compression map.
If `‖e‖ ≤ δ` and the decoder correctly recovers message `m` whenever
the received point is within `‖f‖ * δ` of `encode m`, then applying
compression to a noisy codeword preserves correctness.

This theorem instantiates to NIST-style "decryption failure probability
is zero below threshold" statements for any lattice-based KEM.

**Proof**: We show `‖(encode m + f e) - encode m‖ = ‖f e‖ ≤ ‖f‖ * ‖e‖ ≤ ‖f‖ * δ`,
then apply the decoder correctness hypothesis. -/
theorem decode_correct_of_linear_noise_bound
    {𝕜 M N : Type*}
    [NontriviallyNormedField 𝕜]
    [SeminormedAddCommGroup M] [NormedSpace 𝕜 M]
    [SeminormedAddCommGroup N] [NormedSpace 𝕜 N]
    (f : M →L[𝕜] N)
    (decode : N → Message)
    (encode : Message → N)
    (m : Message) (e : M) (δ : ℝ)
    (he : ‖e‖ ≤ δ)
    (hdecode :
      ∀ x, ‖x - encode m‖ ≤ ‖f‖ * δ → decode x = m) :
    decode (encode m + f e) = m := by
  apply hdecode
  rw [add_sub_cancel_left]
  exact le_trans (ContinuousLinearMap.le_opNorm f e)
    (mul_le_mul_of_nonneg_left he (norm_nonneg f))

/-- **Certified compression preserves correctness with explicit compliance window**.

A variant of `decode_correct_of_linear_noise_bound` using the `ComplianceWindow`
and `LinearNoiseCertified` abstractions. This is the form most natural for
standards-compliance arguments. -/
theorem decode_correct_of_compliance_window
    {𝕜 M N : Type*}
    [NontriviallyNormedField 𝕜]
    [SeminormedAddCommGroup M] [NormedSpace 𝕜 M]
    [SeminormedAddCommGroup N] [NormedSpace 𝕜 N]
    (f : M →L[𝕜] N)
    (decode : N → Message)
    (encode : Message → N)
    (w : ComplianceWindow M)
    (m : Message) (e : M)
    (hcert : LinearNoiseCertified e w.radius)
    (hdecode :
      ∀ x, ‖x - encode m‖ ≤ ‖f‖ * w.radius → decode x = m) :
    decode (encode m + f e) = m :=
  decode_correct_of_linear_noise_bound f decode encode m e w.radi
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Entropy-Bounded Computation (EBC)

This cycle established a fully formal, `sorry`-free core for the **Entropy-Bounded
Computation** framework in `Catalog/Computation/EntropyBoundedComputation.lean`.
We model one deterministic computational step as a function between finite *state
spaces* and define `EBC.entropy S := Real.logb 2 (Fintype.card S)`, the Shannon
entropy (in bits) of the uniform distribution over states. On this skeleton we
proved the structural laws of information under computation:

* `entropy_nonneg`, `entropy_eq_zero_of_card_one` (ground facts),
* `entropy_reversible_invariant` (bijections preserve entropy — reversibility),
* `entropy_prod` (additivity over independent product spaces),
* `entropy_le_of_surjective` (a deterministic map cannot create entropy — a
  data-processing / second-law inequality), and
* `landauer_erasure_pos` / `landauer_erasure_eq` (Landauer's principle: erasing a
  multi-state space to a point dissipates strictly positive entropy).

These results generalize `Computation/EntropyBridge.lean`, which only bounded
*cardinality* through injective encodings: we promote log-cardinality to a
genuine real-valued entropy functional and prove its algebra. The directions
below extend that functional toward an information-theoretic theory of
computation that is mechanically checkable end to end.

---

## Direction 1 — Entropy is subadditive under arbitrary deterministic maps

Strengthen `entropy_le_of_surjective` by dropping surjectivity: for **any**
`f : S → T` the image `Set.range f` is the genuine reachable output space, and
`entropy (Set.range f) ≤ entropy S`, with equality iff `f` is injective. This
turns the second-law inequality into an exact accounting: the *entropy defect*
`entropy S − entropy (Set.range f)` is precisely the information irreversibly
discarded by the step.

**The key insight is** that for finite types `Fintype.card (Set.range f) ≤
Fintype.card S` always holds (`Set.card_range_le`), and equality is exactly
`Function.Injective f` — so the entire reversibility/irreversibility dichotomy is
already encoded in the cardinality of the range, with no probability theory
required.

**Why now?** We already have `entropy_le_of_surjective` and
`entropy_reversible_invariant` as the two extreme cases (surjective and
bijective); the general statement is the natural interpolation between them and
needs only `Set.range`/`Finset.image` cardinality lemmas that are present in
Mathlib, so it is reachable in a single cycle.

## Direction 2 — Compositional cost: entropy defect is additive along pipelines

Define `defect f := entropy S − entropy (Set.range f)` and prove that for a
pipeline `g ∘ f` the total dissipated entropy is bounded by the sum of stage
defects: `defect (g ∘ f) ≤ defect f + defect g`, with equality when the stages
do not "re-merge" already-merged states. This is the EBC analogue of additivity
of thermodynamic cost along a process.

**The key insight is** that `Set.range (g ∘ f) = 
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
