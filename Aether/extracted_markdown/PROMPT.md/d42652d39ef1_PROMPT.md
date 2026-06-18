
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

**Title**: Close Proofs: Learning with Errors: Hardness Reductions
**Domain**: Applications
**Mathematical framing**: Cycle ee624f37 (Q=0.448) proved 696 theorems in Cryptography but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Formalize the hardness reduction from worst-case lattice problems (GapSVP, SIVP) to the Learning with Errors problem with specific parameters.
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Cryptography/LWE/HardnessReduction.lean
import Mathlib

/-!
# LWE Hardness Reduction: Bounded-Distance Decoding and Parameter Feasibility

This module formalizes the *geometric core* of the worst-case-to-average-case
hardness reduction for the Learning with Errors (LWE) problem (Regev 2005,
Peikert 2009).  It complements the algebraic search-to-decision material in
`Cryptography.LWE.SearchDecisionCore` (the affine-rerandomization lemmas
`ZMod.affine_bijective`, the noise-accumulation bounds, and the
`search_to_decision_advantage_bound` pigeonhole step).

## Mathematical background

An LWE sample `(A, b = A·s + e)` is exactly a *bounded-distance decoding*
(BDD) instance on the `q`-ary lattice generated by `A`: the received word `b`
lies near the lattice point `A·s`, and recovering `s` amounts to decoding.
The reduction is correct precisely because, **inside half the first minimum
`λ₁/2`, the closest lattice point is unique**.  The same `λ₁/2` radius is the
packing radius of the lattice (balls around lattice points are disjoint), and
this is what links the average-case noise rate `α` to the worst-case
approximation factor `γ` of `GapSVP`.

We work over an arbitrary normed additive group `E` with an additive subgroup
`L` (the lattice) whose nonzero elements have norm at least `lam` (a lower
bound on `λ₁`).  This abstraction makes every statement basis-independent and
applies verbatim to the `q`-ary lattice, ideal lattices, and module lattices.

## Main results

* `LWEHardness.bdd_unique_decoding` — uniqueness of decoding within `λ₁/2`.
* `LWEHardness.bdd_unique_decoding_asym` — sharper asymmetric radius `r₁+r₂<λ₁`.
* `LWEHardness.bdd_existsUnique` — existence **and** uniqueness (`∃!`).
* `LWEHardness.lattice_packing_disjoint` — `λ₁/2`-balls around lattice points
  are pairwise disjoint (lattice packing).
* `LWEHardness.lwe_unique_secret` / `lwe_decoding_correct` — the LWE-flavoured
  corollaries: a short error determines the secret uniquely.
* `gapsvp_promise_exclusive` — the `GapSVP_γ` YES/NO promises are exclusive.
* `modulus_for_approx_factor`, `noise_rate_for_decoding` — the parameter chain
  `α·q ≥ 2√n` linking modulus, noise rate, and approximation factor.
* `boundary_uniqueness_fails` — the radius `λ₁/2` is sharp: at the boundary,
  uniqueness fails (`ℤ ⊂ ℝ`, target `1/2`).

## References

* Regev, "On Lattices, Learning with Errors, Random Linear Codes, and
  Cryptography", STOC 2005 / JACM 2009.
* Peikert, "Public-Key Cryptosystems from the Worst-Case Shortest Vector
  Problem", STOC 2009.
* Micciancio–Regev, "Worst-case to average-case reductions based on Gaussian
  measures", FOCS 2004.
-/

open scoped BigOperators

namespace LWEHardness

noncomputable section

variable {E : Type*} [NormedAddCommGroup E]

/-! ## Section 1: Bounded-distance decoding is unique within `λ₁/2` -/

-- !-- If `t` is within `λ₁/2` of two lattice points `v, w`, then their
-- difference `v - w` is a lattice vector of norm `< λ₁` by the triangle
-- inequality, forcing `v - w = 0`. This is the reason LWE decoding succeeds. -- !--

/-- **Bounded-distance decoding is unique within radius `λ₁/2`.**
If both `v` and `w` are lattice points within distance `lam/2` of a target
`t`, they coincide.  Here `lam` is any lower bound on the lattice's first
minimum `λ₁`. -/
theorem bdd_unique_decoding (L : AddSubgroup E) (lam : ℝ)
    (hlam : ∀ x ∈ L, x ≠ 0 → lam ≤ ‖x‖)
    (t v w : E) (hv : v ∈ L) (hw : w ∈ L)
    (hvt : ‖t - v‖ < lam / 2) (hwt : ‖t - w‖ < lam / 2) : v = w := by
  by_contra hne
  have hge : lam ≤ ‖v - w‖ := hlam _ (L.sub_mem hv hw) (sub_ne_zero.mpr hne)
  have htri : ‖v - w‖ ≤ ‖t - w‖ + ‖t - v‖ := by
    have h : v - w = (t - w) - (t - v) := by abel
    rw [h]; exact norm_sub_le _ _
  linarith

-- !-- A strictly stronger statement: the two decoding radii need only sum to
-- less than `λ₁`. Setting `r₁ = r₂ = λ₁/2` recovers `bdd_unique_decoding`. -- !--

/-- **Asymmetric BDD uniqueness.** The decoding radii of `v` and `w` only need
to satisfy `‖t-v‖ + ‖t-w‖ < lam`; this is the sharpest triangle-inequality
form and generalizes `bdd_unique_decoding`. -/
theorem bdd_unique_decoding_asym (L : AddSubgroup E) (lam : ℝ)
    (hlam : ∀ x ∈ L, x ≠ 0 → lam ≤ ‖x‖)
    (t v w : E) (hv : v ∈ L) (hw : w ∈ L)
    (hsum : ‖t - v‖ + ‖t - w‖ < lam) : v = w := by
  by_contra hne
  have hge : lam ≤ ‖v - w‖ := hlam _ (L.sub_mem hv hw) (sub_ne_zero.mpr hne)
  have htri : ‖v - w‖ ≤ ‖t - w‖ + ‖t - v‖ := by
    have h : v - w = (t - w) - (t - v) := by abel
    rw [h]; exact norm_sub_le _ _
  linarith

-- !-- Given one near lattice point `v`, it is *the* unique solution: existence
-- is `v` itself, uniqueness is `bdd_unique_decoding`. -- !--

/-- **Existence and uniqueness of the BDD solution.** If `t` is within `lam/2`
of some lattice point `v`, then `v` is the unique lattice point within `lam/2`
of `t`. -/
theorem bdd_existsUnique (L : AddSubgroup E) (lam : ℝ)
    (hlam : ∀ x ∈ L, x ≠ 0 → lam ≤ ‖x‖)
    (t v : E) (hv : v ∈ L) (hvt : ‖t - v‖ < lam / 2) :
    ∃! w : E, w ∈ L ∧ ‖t - w‖ < lam / 2 := by
  refine ⟨v, ⟨hv, hvt⟩, ?_⟩
  rintro w ⟨hw, hwt⟩
  exact bdd_unique_decoding L lam hlam t w v hw hv hwt hvt

/-! ## Section 2: Lattice packing at radius `λ₁/2` -/

-- !-- If a point `x` lay in two `λ₁/2`-balls around distinct lattice points
-- `v, w`, the triangle inequality gives `‖v - w‖ < λ₁`, contradicting the
-- minimum distance. Hence the open balls are disjoint (sphere packing). -- !--

/-- **Lattice packing.** The open balls of radius `lam/2` around distinct
lattice points are disjoint.  This is the geometric dual of BDD uniqueness:
`λ₁/2` is the packing radius of the lattice. -/
theorem lattice_packing_disjoint (L : AddSubgroup E) (lam : ℝ)
    (hlam : ∀ x ∈ L, x ≠ 0 → lam ≤ ‖x‖)
    (v w : E) (hv : v ∈ L) (hw : w ∈ L) (hne : v ≠ w) :
    Disjoint (Metric.ball v (lam / 2)) (Metric.ball w (lam / 2)) := by
  rw [Set.disjoint_left]
  intro x hxv hxw
  rw [Metric.mem_ball] at hxv hxw
  have hge : lam ≤ ‖v - w‖ := hlam _ (L.sub_mem hv hw) (sub_ne_zero.mpr hne)
  have htri : ‖v - w‖ ≤ dist x v + dist x w := by
    rw [dist_eq_norm, dist_eq_norm]
    have h : v - w = (x - w) - (x - v) := by abel
    rw [h]
    calc ‖(x - w) - (x - v)‖ ≤ ‖x - w‖ + ‖x - v‖ := norm_sub_le _ _
      _ = ‖x - v‖ + ‖x - w‖ := by ring
  linarith

/-! ## Section 3: The LWE corollaries -/

-- !-- An LWE secret `s` is encoded as a lattice codeword `enc s`. Two secrets
-- whose codewords are both `λ₁/2`-close to the received word `t` must coincide
-- by `bdd_unique_decoding` and injectivity of `enc`. -- !--

/-- **LWE secret uniqueness.** With an injective lattice encoding `enc : S → L`
of secrets, any two secrets whose codewords lie within `lam/2` of a received
word `t` are equal: the secret is determined by a bounded error. -/
theorem lwe_unique_secret {S : Type*} (L : AddSubgroup E) (lam : ℝ)
    (hlam : ∀ x ∈ L, x ≠ 0 → lam ≤ ‖x‖)
    (enc : S → E) (hmem : ∀ s, enc s ∈ L) (hinj : Function.Injective enc)
    (t : E) (s₁ s₂ : S)
    (h₁ : ‖t - enc s₁‖ < lam / 2) (h₂ : ‖t - enc s₂‖ < lam / 2) : s₁ = s₂ :=
  hinj (bdd_unique_decoding L lam hlam t (enc s₁) (enc s₂) (hmem s₁) (hmem s₂) h₁ h₂)

-- !-- Given the genuine LWE word `t = enc s + e` with `‖e‖ < λ₁/2`, the secret
-- `s` is the unique decodable secret: existence uses `‖t - enc s‖ = ‖e‖`. -- !--

/-- **LWE decoding correctness.** If the received word is `enc s + e` with error
`‖e‖ < lam/2`, then `s` is the unique secret whose codeword lies within `lam/2`
of the received word.  This is precisely BDD correctness for LWE. -/
theorem lwe_decoding_correct {S : Type*} (L : AddSubgroup E) (lam : ℝ)
    (hlam : ∀ x ∈ L, x ≠ 0 → lam ≤ ‖x‖)
    (enc : S → E) (hmem : ∀ s, enc s ∈ L) (hinj : Function.Injective enc)
    (s : S) (e : E) (he : ‖e‖ < lam / 2) :
    ∃! s' : S, ‖(enc s + e) - enc s'‖ < lam / 2 := by
  refine ⟨s, ?_, ?_⟩
  · simpa using he
  · intro s' hs'
    exact hinj (bdd_unique_decoding L lam hlam (enc s + e) (enc s') (enc s)
      (hmem s') (hm
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — LWE Hardness Reduction

The file `HardnessReduction.lean` formalizes the *geometric core* of the
worst-case-to-average-case reduction for Learning with Errors: bounded-distance
decoding (BDD) is unique inside half the first minimum `λ₁/2`, the same radius
that gives the lattice packing, and the quantitative parameter chain
`α·q ≥ 2√n` that ties the average-case noise rate `α` to the worst-case
`GapSVP` approximation factor `γ`. It builds on the algebraic search-to-decision
material in `SearchDecisionCore.lean` (the affine-rerandomization equivalences
`ZMod.affine_bijective` and the pigeonhole `search_to_decision_advantage_bound`).
Below are five concrete, falsifiable directions that extend this skeleton toward
a complete machine-checked reduction.

## 1. Minkowski's first theorem as an effective lower bound on `λ₁`

Every theorem in the current file is stated relative to an *abstract* lower
bound `lam ≤ λ₁`. The natural next step is to discharge that hypothesis for
genuine full-rank lattices by proving Minkowski's first theorem in the form
`λ₁(L) ≤ √n · covol(L)^{1/n}`, and dually a packing lower bound on `λ₁` from
the determinant. Mathlib already provides `ZLattice.covolume` and the
convex-body Minkowski theorem (`MeasureTheory.exists_ne_zero_mem_lattice...`),
so the missing piece is the explicit `√n` constant.
**The key insight is** that the abstract `hlam` hypothesis used everywhere in
`HardnessReduction.lean` is exactly the conclusion of Minkowski's theorem, so
proving the latter instantly upgrades all BDD/packing theorems from conditional
to unconditional for the `q`-ary lattice. **Why now?** The covolume API and the
measure-theoretic Minkowski lemma landed in recent Mathlib, so the constant is
the only genuinely new analytic estimate required — a self-contained, testable
target.

## 2. Discrete-Gaussian tail bound ⇒ explicit decoding radius

The current `lwe_decoding_correct` assumes a hard norm bound `‖e‖ < λ₁/2`. Real
LWE errors are discrete Gaussians, so the falsifiable conjecture is a Banaszczyk
tail bound: for parameter `σ`, `Pr[‖e‖ ≥ σ√n] ≤ 2^{-n}`, hence decoding
succeeds except with exponentially small probability whenever `σ√n < λ₁/2`.
**The key insight is** that the deterministic uniqueness theorem and a single
scalar tail inequality factor cleanly: uniqueness needs no probability, and the
probability lives entirely in one `Pr[‖e‖ ≥ r]` bound that can be proved
independently and then composed. **Why now?** Mathlib's `ProbabilityTheory` and
`MeasureTheory.Gaussian` machinery is mature enough to state sub-Gaussian
concentration; pairing it with the already-proven uniqueness lemma is the first
end-to-end *probabilistic* correctness statement for LWE in Lean.

## 3. List-decoding beyond `λ₁/2`: a finite-ambiguity theorem

`lattice_packing_disjoint` shows that below `λ₁/2` there is at most one solution.
The conjecture is a quantitative relaxation: within radius `r = c·λ₁` for
`c < 1`, the number of lattice points 
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
