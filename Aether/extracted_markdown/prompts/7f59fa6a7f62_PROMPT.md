
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

**Title**: Bridge: Tropical Geometry as a Limit of Classical Algebraic Geometry
**Domain**: Applications
**Mathematical framing**: Prove that the tropicalization of a variety V over a non-Archimedean field is the limit of V as the valuation goes to infinity. Bridge: the tropical fundamental theorem states that the tropicalization of V equals the corner locus of the tropical polynomial. Show that tropical intersection numbers equal classical intersection numbers (tropical Bezout).
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/AlgebraTropicalGeometry/TropicalValuationLimitBridge.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Bridge: Tropical Geometry as the Image of a Non-Archimedean Valuation

This file builds the *bridge* between classical algebraic geometry over a non-Archimedean
valued field and tropical geometry.  The central object is an additive valuation
`v : AddValuation K Γ`, which we read as the **tropicalization map**
`x ↦ v x` sending a field element to its order (a point of the tropical semiring).

## The bridge results

* `addValuation_sum_eq_of_unique_min` — the ultrametric "winner takes all" lemma: if one term
  of a finite sum has a *strictly* smaller valuation than all the others, the valuation of the
  sum equals that of the smallest term.  This is the additive analogue of
  `Valuation.map_sum_eq_of_lt`.

* `kapranov_easy_direction` — **the Fundamental Theorem of Tropical Geometry (easy direction,
  Kapranov).**  If a point lies on the classical hypersurface `{∑ Tᵢ = 0}` (and not all terms
  vanish), then its tropicalization lies on the *corner locus*: the tropicalized minimum
  `minᵢ v(Tᵢ)` is attained at least twice.  This is exactly the statement that the
  tropicalization of a variety is contained in the corner locus of the tropical polynomial.

* `TropPoly.eval_mul` — **min-plus multiplicativity.**  Tropical evaluation turns the product
  of tropical polynomials into the (ordinary) sum of their evaluations,
  `eval (P ⊙ Q) = eval P + eval Q`.  This is the engine of *tropical Bézout*: it makes degrees
  add and hypersurfaces of products decompose.

* `attainedTwice_subsingleton` — boundary case: a one-term (univariate, single monomial) tropical
  polynomial has empty corner locus, so the easy direction genuinely needs ≥ 2 monomials.

## The "limit of valuations" picture

Classically one studies the family `v_t = t · v` for `t → ∞` (the valuation "going to infinity"
rescales the amoeba); the corner-locus characterization proven here is the invariant limiting
shape.  See `FUTURE_DIRECTIONS.md`.
-/

open Finset

namespace TropicalValuationBridge

/-! ## §1. The corner locus / tropical hypersurface predicate -/

/-- A weight function `w : ι → α` **attains its minimum at least twice** when there are two
distinct indices, each of which is a global minimum.  Geometrically this is the *corner locus*
(tropical hypersurface) condition: the piecewise-linear tropical polynomial is non-smooth, i.e.
the minimum defining it is achieved by (at least) two monomials. -/
def AttainedAtLeastTwice {ι α : Type*} [LinearOrder α] (w : ι → α) : Prop :=
  ∃ i j, i ≠ j ∧ (∀ k, w i ≤ w k) ∧ (∀ k, w j ≤ w k)

/-
!-- A single index can never witness `i ≠ j`, so the corner locus of a one-monomial
tropical polynomial is empty. This is the boundary case where the bridge theorem fails. -- !--

**Boundary case.** With at most one index the corner locus is empty: a single tropical
monomial defines a smooth (linear) function with no corners.
-/
theorem attainedTwice_subsingleton {ι α : Type*} [LinearOrder α] [Subsingleton ι]
    (w : ι → α) : ¬ AttainedAtLeastTwice w := by
  rintro ⟨ i, j, hij, hi, hj ⟩ ; exact hij ( Subsingleton.elim i j )

/-! ## §2. The ultrametric "winner takes all" lemma for additive valuations -/

/-
!-- Strip the unique minimiser `j` off the sum; the remaining terms all have strictly
larger valuation, so by `map_lt_sum` their sum does too, and `map_add_eq` of distinct
valuations gives `v(∑) = v(f j)`. -- !--

If, among a finite family, the term `f j` has *strictly* the smallest valuation, then the
valuation of the whole sum equals `v (f j)`.  Additive analogue of
`Valuation.map_sum_eq_of_lt`.
-/
theorem addValuation_sum_eq_of_unique_min
    {K Γ ι : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ]
    (v : AddValuation K Γ) {s : Finset ι} {f : ι → K} {j : ι}
    (hj : j ∈ s) (hmin : ∀ i ∈ s, i ≠ j → v (f j) < v (f i)) :
    v (∑ i ∈ s, f i) = v (f j) := by
  classical
  by_cases h : v (f j) = ⊤
  · -- The unique minimiser has valuation ⊤, hence is the *maximum*, forcing `s = {j}`.
    have hs : s = {j} := by
      refine Finset.eq_singleton_iff_unique_mem.2 ⟨hj, ?_⟩
      intro i hi
      by_contra hne
      have hlt := hmin i hi hne
      rw [h] at hlt
      exact not_top_lt hlt
    rw [hs, Finset.sum_singleton]
  · rw [Finset.sum_eq_add_sum_diff_singleton hj]
    apply AddValuation.map_add_eq_of_lt_left
    refine v.map_lt_sum h ?_
    intro i hi
    rw [Finset.mem_sdiff, Finset.mem_singleton] at hi
    exact hmin i hi.1 hi.2

/-! ## §3. The Fundamental Theorem of Tropical Geometry — easy direction (Kapranov) -/

/-
!-- If the tropicalized minimum were attained uniquely at `m`, the winner-takes-all lemma
would give `v(∑ Tᵢ) = v(T m) ≠ ⊤`; but `∑ Tᵢ = 0` forces `v(∑) = ⊤`, a contradiction.
Hence the minimum is attained at least twice: the tropicalized point is on the corner locus. -- !--

**Tropicalization is contained in the corner locus.**  Let `K` be a non-Archimedean valued
field and `T : ι → K` the (finite, nonempty) family of monomials of a polynomial evaluated at a
point.  If that point lies on the hypersurface `∑ᵢ Tᵢ = 0` and the polynomial does not vanish
identically there (`∃ i, Tᵢ ≠ 0`), then the tropicalized weights `i ↦ v (Tᵢ)` attain their
minimum at least twice — the image point lies on the tropical hypersurface.
-/
theorem kapranov_easy_direction
    {K Γ ι : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ] [Nontrivial Γ]
    [Fintype ι] [Nonempty ι]
    (v : AddValuation K Γ) (T : ι → K)
    (hsum : ∑ i, T i = 0) (hnz : ∃ i, T i ≠ 0) :
    AttainedAtLeastTwice (fun i => v (T i)) := by
  obtain ⟨ m, hm ⟩ := Finset.exists_min_image Finset.univ ( fun i => v ( T i ) ) ⟨ hnz.choose, Finset.mem_univ _ ⟩;
  by_contra! h_contra
  have h_min : ∀ i, i ≠ m → v (T m) < v (T i) := by
    intro i hi; exact lt_of_le_of_ne ( hm.2 i ( Finset.mem_univ i ) ) ( fun h => h_contra ⟨ m, i, by aesop ⟩ ) ;
  have h_eq : v (∑ i, T i) = v (T m) := by
    apply addValuation_sum_eq_of_unique_min v (Finset.mem_univ m) (fun i hi hi' => h_min i hi')
  have h_contra' : v (T m) = ⊤ := by
    rw [ ← h_eq, hsum, v.map_zero ]
  exact (by
  obtain ⟨ i, hi ⟩ := hnz; specialize h_min i; simp_all +decide ;)

/-
**Tropical line / classical line corner.**  A concrete instance of the bridge:
if `(x, y)` is a point of the classical line `a·X + b·Y + c = 0` with `a, b, c` not all giving
a degenerate term, then the tropical line `min(v a + X, v b + Y, v c)` has a corner at
`(v(a·x), v(b·y), v c)`.
-/
theorem tropical_line_corner
    {K Γ : Type*} [Field K] [LinearOrderedAddCommMonoidWithTop Γ] [Nontrivial Γ]
    (v : AddValuation K Γ) (a b c x y : K)
    (hline : a * x + b * y + c = 0) (hnz : a * x ≠ 0 ∨ b * y ≠ 0 ∨ c ≠ 0) :
    AttainedAtLeastTwice (fun i : Fin 3 => v (![a * x, b * y, c] i)) := by
  -- Apply the kapranov_easy_direction theorem with the given hypotheses.
  apply kapranov_easy_direction v ![a * x, b * y, c];
  · simp +decide [ Fin.sum_univ_three, hline ];
  · rcases hnz with ( h | h | h ) <;> [ exact ⟨ 0, h ⟩ ; exact ⟨ 1, h ⟩ ; exact ⟨ 2, h ⟩ ]

/-! ## §4. Min-plus multiplicativity → tropical Bézout's degree law -/

/-
Min-plus distributivity: the infimum over a product of a separated sum factors as the sum of
the infima.  `min_{(i,k)} (f i + g k) = (min_i f i) + (min_k g k)`.
-/
theorem inf'_product_add
    {ι κ : Type*} {s : Finset ι} {t : Finset κ} (hs : s.Nonempty) (ht : t.Nonempty)
    (f : ι → ℝ) (g : κ → ℝ) :
    (s ×ˢ t).inf' (hs.product ht) (fun p => f p.1 + g p.2)
      = s.inf' hs f + t.inf' ht g := by
  refine' le_antisymm _ _ <;> simp_all +decide
  · obtain ⟨ a, ha ⟩ := Finset.exists_mem_eq_inf' hs f; obtain ⟨ b, hb ⟩ := Finset.exists_mem_eq_inf' ht g; use a, b; aesop;
  · exact fun a b ha hb => add_le_add ( Finset.inf'_le _ ha ) ( Finset.inf'_le _ hb )

/-- A tropical polynomial in `n` variables: a finite family of m
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Valuation–Tropicalization Bridge

The file `TropicalValuationLimitBridge.lean` formalizes the *easy half* of the Fundamental
Theorem of Tropical Geometry: tropicalizing a point of a classical hypersurface always lands on
the corner locus (`kapranov_easy_direction`), powered by the ultrametric winner-takes-all lemma
(`addValuation_sum_eq_of_unique_min`), and it isolates the min-plus multiplicativity
(`TropPoly.eval_mul`) that makes tropical degrees add. Below are the next conjectures this work
opens up. Each is stated so that it can be falsified by a single counterexample or settled by a
single Lean proof.

## Direction 1 — Kapranov's hard direction (surjectivity onto the corner locus)

Conjecture: if `K` is algebraically closed with a non-trivial valuation `v` whose value group is
divisible (so `v` is surjective onto `Γ`), then for every weight vector `w` lying on the corner
locus of a tropical polynomial `trop(f)` there exists a point `p` with `f(p) = 0` and
`v(p) = w`. This is the converse of `kapranov_easy_direction`, currently recorded as the open
target `kapranov_hard_direction_sketch`.

The key insight is that the easy direction is *purely a consequence of the ultrametric
inequality being an equality away from ties*, whereas the hard direction needs a genuine
*lifting* step: a Newton-polygon / Hensel argument that promotes a "leading-term cancellation"
(two monomials tied for the minimum) into an actual root. Formalizing the univariate case first
(`Fin 1` many variables, where the Newton polygon is literally the lower convex hull of
`{(i, v(cᵢ))}`) reduces the whole theorem to Hensel's lemma plus convexity.

Why now? Mathlib already has `Polynomial.Monic`, Hensel's lemma for complete local rings, and
the `AddValuation` API used here; the missing glue is a Newton-polygon predicate, which is a
finite-combinatorial object identical in spirit to the `inf'_product_add` lemma already proven.

## Direction 2 — The valuation-going-to-infinity limit is genuinely a limit

Conjecture: for the rescaled family `v_t := t • v` (`t : ℝ≥0`, `t → ∞`), the corner locus of
`trop_{v_t}(f)` converges, in the Hausdorff metric on compact windows, to the corner locus of
`trop_v(f)` *scaled by t*; equivalently the normalized amoeba `(1/t)·Log_t(V(f))` converges to
the tropical variety. This makes precise the slogan "tropicalization is the `t → ∞` limit".

The key insight is that `t • v` is *again* an `AddValuation` (scaling preserves the two
valuation axioms), so the entire corner-locus characterization is invariant under `t`-rescaling
up to a homothety — meaning the "limit" is not an analytic limit of moving sets but the fixed
shape that all members of the family already share after normalization.

Why now? The corner-locus predicate `AttainedAtLeastTwice` is scale-equivariant on the nose
(`AttainedAtLeastTwice (t • w) ↔ AttainedAtLeastTwice w` for `t > 0`), a one-line lemma to add,
turning a hard analytic statement into an algebraic invari
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
