
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

**Title**: The current `OrdinalTheory` framework works with abstract `Ordinal` values from 
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Proof-Theoretic Ordinal Analysis

## 1. Ordinal Notation Systems and the ε₀ Barrier

The current `OrdinalTheory` framework works with abstract `Ordinal` values from Mathlib's set-theoretic ordinals. The next step is to connect this to *computable* ordinal notation systems — specifically Mathlib's `ONote` (ordinal notations below ε₀) and `NONote` (natural ordinal notations). The key insight is that the `pto_ofOrdinal_limit` theorem establishes that limit ordinals faithfully represent theories, but only for abstract ordinals; linking this to `ONote` would give a *decidable* theory comparison for theories with PTO below ε₀. Why now? The `Iio_sSup_subset_initSeg` half-saturation theorem shows that every ordinal below the PTO is provable, which is exactly the structural lemma needed to map between notation-system provability and set-theoretic provability.

**Testable conjecture**: For every `ONote` value `n`, `OrdinalTheory.ofOrdinal n.repr` has PTO exactly `n.repr`, and the inclusion ordering on such theories is decidable via the ordering on `ONote`.

## 2. The Quasi-Metric Geometry of Theory Space

We established that `depthDist` is a symmetric, positive-definite function on theory space (via `depthDist_comm`, `depthDist_self_eq_zero`, and `depthDist_eq_zero_iff`). The triangle inequality fails in general due to non-commutativity of ordinal addition, but the `pto_sandwich` theorem suggests a weaker "directed" triangle inequality may hold. The key insight is that ordinal subtraction satisfies `(a - b) + (b - c) ≥ a - c` when `a ≥ b ≥ c`, which is exactly the directed triangle inequality for the ordering induced by theory inclusion. Why now? The `pto_monotone` theorem guarantees that theory inclusion respects the PTO ordering, giving a directed structure to the space that should make the directed triangle inequality provable.

**Testable conjecture**: For theories T₁ ≤ T₂ ≤ T₃, `depthDist T₁ T₃ ≤ depthDist T₁ T₂ + depthDist T₂ T₃`, and this fails without the ordering assumption.

## 3. Lattice Structure of OrdinalTheories

The `join_pto_eq_max` theorem shows that the join operation is well-behaved with respect to PTOs. A natural next step is to formalize the *meet* (intersection) of theories and show that `OrdinalTheory` forms a complete lattice under inclusion, with PTO providing a lattice homomorphism to the ordinals. The key insight is that intersections of downward-closed sets are downward-closed, and the PTO of the meet should be the infimum of the PTOs — but this requires care because `sSup (S₁ ∩ S₂)` is not always `min (sSup S₁) (sSup S₂)` for general sets. Why now? Our discovery that strict inclusion does NOT imply strict PTO increase (the `{β | β < ω}` vs `{β | β ≤ ω}` counterexample) reveals that the PTO map is not an order embedding — characterizing its fibers (the equivalence classes of theories with the same PTO) is the right structural question.

**Testable conjecture**: The fibers of the PTO map are intervals in the inclusion lattice: if T₁ ≤ T₂ and pto(T₁) = pto(T₂) = α, then for any T with T₁ ≤ T ≤ T₂, pto(T) = α.

## 4. Connecting to Concrete Theories via Fast-Growing Hierarchies

The abstract framework should be connected to Mathlib's `ONote.fastGrowing` function hierarchy. The key insight is that a theory T "knows about" ordinal α if α ∈ T.provablyWO, and the fast-growing function f_α provides a *computational witness* of this knowledge: T should be able to prove totality of f_α for exactly those α in its provablyWO set. Why now? The `pto_le_of_not_mem` theorem gives the exact characterization needed: if T cannot prove α is well-ordered (α ∉ provablyWO), then α ≥ pto(T), which is precisely the "boundary" where the fast-growing hierarchy becomes unprovably total.

**Testable conjecture**: There exists a computable function from `ONote` to `OrdinalTheory` such that the PTO of the resulting theory equals the ordinal represented by the notation, and the theory's provablyWO set coincides with the set of notations whose fast-growing functions are provably total.

## 5. Well-Quasi-Order Structure Under Bounded PTO

The `pto_monotone` theorem shows that infinite ascending chains of theories produce infinite ascending sequences of ordinals. Since ordinals below any fixed bound are well-ordered, the set of theories with PTO below a fixed bound α admits no infinite strictly ascending chain *of PTOs*. The key insight is that while this does not immediately give a well-quasi-order (because PTO is not an order embedding, as we discovered), it does give a weaker "well-directed" structure: every infinite sequence of theories with bounded PTO has an infinite weakly increasing subsequence in the PTO ordering. Why now? The failure of strict monotonicity that we discovered (and documented in the file) actually makes this question more interesting — the PTO fibers add complexity that standard WQO theory for ordinals alone cannot capture.

**Testable conjecture**: The quotient of `{T : OrdinalTheory | T.pto < ε₀}` by PTO-equivalence (T₁ ~ T₂ iff pto(T₁) = pto(T₂)) is a well-order isomorphic to ε₀, and each equivalence class is a complete lattice under theory inclusion.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/TightDepthHierarchy/Defs.lean
/-
# EML Tight Depth Hierarchy — Definitions

This file establishes the foundational definitions for the tight depth
hierarchy theorem: inverse-free EML expressions of depth D cannot represent
iterExp n for any n > D.

## Key Innovation

We introduce `HasPolyTowerMajorant k e`, stating that the evaluation of `e`
is bounded by `iterExp k (C * x^N)` for some constants C, N. This is sharper
than the previous `iterExp (k+1) (C * x)` bound, because polynomial arguments
inside iterExp can be absorbed when comparing with the next level.
-/
import Mathlib

noncomputable section

open Real Filter Finset

/-! ## Expression Language -/

/-- EML expression language: transcendence enters only through `eml(a,b) = a * exp(b)`. -/
inductive EMLExpr where
  | var : EMLExpr
  | const : ℝ → EMLExpr
  | add : EMLExpr → EMLExpr → EMLExpr
  | mul : EMLExpr → EMLExpr → EMLExpr
  | neg : EMLExpr → EMLExpr
  | inv : EMLExpr → EMLExpr
  | eml : EMLExpr → EMLExpr → EMLExpr

namespace EMLExpr

/-- Evaluation of `EMLExpr` at a point `x : ℝ`. -/
def eval : EMLExpr → ℝ → ℝ
  | .var, x => x
  | .const c, _ => c
  | .add a b, x => a.eval x + b.eval x
  | .mul a b, x => a.eval x * b.eval x
  | .neg a, x => -(a.eval x)
  | .inv a, x => (a.eval x)⁻¹
  | .eml a b, x => a.eval x * Real.exp (b.eval x)

/-- EML depth: counts maximum nesting of `eml` operations. -/
def emlDepth : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.emlDepth b.emlDepth
  | .mul a b => max a.emlDepth b.emlDepth
  | .neg a => a.emlDepth
  | .inv a => a.emlDepth
  | .eml a b => 1 + max a.emlDepth b.emlDepth

/-- An EMLExpr has no `inv` nodes: the inverse-free fragment. -/
def noInv : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.noInv ∧ b.noInv
  | .mul a b => a.noInv ∧ b.noInv
  | .neg a => a.noInv
  | .inv _ => False
  | .eml a b => a.noInv ∧ b.noInv

/-- An EMLExpr has no `eml` nodes: pure field expression. -/
def noEml : EMLExpr → Prop
  | .var => True
  | .const _ => True
  | .add a b => a.noEml ∧ b.noEml
  | .mul a b => a.noEml ∧ b.noEml
  | .neg a => a.noEml
  | .inv a => a.noEml
  | .eml _ _ => False

end EMLExpr

/-! ## Iterated Exponential -/

/-- The iterated exponential: `iterExp 0 x = x`, `iterExp (n+1) x = exp(iterExp n x)`. -/
def iterExp : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => Real.exp (iterExp n x)

@[simp] theorem iterExp_zero (x : ℝ) : iterExp 0 x = x := rfl
@[simp] theorem iterExp_succ (n : ℕ) (x : ℝ) :
    iterExp (n + 1) x = Real.exp (iterExp n x) := rfl

/-! ## Representability -/

/-- `e : EMLExpr` represents function `f` on positive reals. -/
def RepresentsOnPos (e : EMLExpr) (f : ℝ → ℝ) : Prop :=
  ∀ x : ℝ, 0 < x → e.eval x = f x

/-! ## Canonical Constructions -/

/-- The canonical `EMLExpr` representing `iterExp n`. -/
def emlExprIterExp : ℕ → EMLExpr
  | 0 => .var
  | n + 1 => .eml (.const 1) (emlExprIterExp n)

/-! ## Novel Definition: Tower Majorant with Polynomial Argument -/

/-- **Novel concept**: An expression has a polynomial-argument tower majorant at level `k`
    if its evaluation is eventually bounded by `iterExp k (C * x^N)` for some constants
    `C > 0` and `N : ℕ`.

    This is strictly sharper than `HasTowerMajorant k e` (which uses `C * x`),
    because polynomial arguments can be absorbed when comparing adjacent tower levels.
    This absorption is what eliminates the slack in the old `D+3` bound. -/
def HasPolyTowerMajorant (k : ℕ) (e : EMLExpr) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∃ N : ℕ, ∃ X₀ : ℝ, ∀ x : ℝ, x ≥ X₀ →
    |e.eval x| ≤ iterExp k (C * x ^ N)

/-- Standard tower majorant with linear argument (for comparison). -/
def HasTowerMajorant (k : ℕ) (e : EMLExpr) : Prop :=
  ∃ C : ℝ, 0 < C ∧ ∀ x : ℝ, 1 < x →
    e.eval x ≤ iterExp k (C * x)

/-- **Growth rank**: the structural growth complexity of an inverse-free expression.
    This assigns to each expression the minimum tower level needed to majorize it.
    - `var`, `const`: rank 0 (polynomial, bounded by `C * x^N`)
    - `add`, `mul`, `neg`: max of children ranks (polynomial closure)
    - `inv`: not defined for inverse-free fragment
    - `eml(a,b)`: `max(a.growthRank, b.growthRank) + 1`

    Key theorem: `growthRank e ≤ emlDepth e` for all `e`. -/
def EMLExpr.growthRank : EMLExpr → ℕ
  | .var => 0
  | .const _ => 0
  | .add a b => max a.growthRank b.growthRank
  | .mul a b => max a.growthRank b.growthRank
  | .neg a => a.growthRank
  | .inv a => a.growthRank
  | .eml a b => 1 + max a.growthRank b.growthRank

end


-- NEW_FILE: Catalog/Bridges/Advanced.lean
import Mathlib

/-! # CatalogBuild.Computation.Oracles.Advanced

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16
-/


noncomputable section

/-- O₁ refines O₂ if every fixed point of O₁ is a fixed point of O₂. -/
def OracleRefines {X : Type*} (O₁ O₂ : X → X) : Prop :=
  ∀ x, O₁ x = x → O₂ x = x




/-- [Section: # CatalogBuild.Computation.Oracles.Advanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem oracleRefines_refl {X : Type*} (O : X → X) : OracleRefines O O :=
  fun _ h => h




/-- [Section: # CatalogBuild.Computation.Oracles.Advanced
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 16] -/
theorem oracleRefines_trans {X : Type*} (O₁ O₂ O₃ : X → X)
    (h₁₂ : OracleRefines O₁ O₂) (h₂₃ : OracleRefines O₂ O₃) :
    OracleRefines O₁ O₃ :=
  fun x hx => h₂₃ x (h₁₂ x hx)




theorem idem_compose_self {X : Type*} (f : X → X) (hf : ∀ x, f (f x) = f x) :
    f ∘ f = f := funext hf




theorem binaryEntropy_nonneg (p : ℝ) (hp0 : 0 < p) (hp1 : p < 1) :
    0 ≤ binaryEntropy p := by
  unfold binaryEntropy;
  split_ifs <;> nlinarith [ Real.logb_neg ( show 1 < 2 by norm_num ) hp0 hp1, Real.logb_neg ( show 1 < 2 by norm_num ) ( show 0 < 1 - p by linarith ) ( show 1 - p < 1 by linarith ) ]




theorem binaryEntropy_half : binaryEntropy (1/2 : ℝ) = 1 := by
  unfold binaryEntropy; norm_num;
  norm_num [ Real.logb_div ]




/-- A constant oracle has a unique fixed point. -/
theorem constant_unique_fixed_point (c : ℝ) :
    ∃! x : ℝ, (fun _ => c) x = x :=
  ⟨c, rfl, fun y hy => hy.symm⟩




/-- Idempotent maps converge in one step. -/
theorem idem_one_step (f : ℝ → ℝ) (hf : ∀ x, f (f x) = f x) (x : ℝ) :
    f x = f (f x) := (hf x).symm




theorem mobius_compose (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ x : ℝ)
    (h : c₂ * x + d₂ ≠ 0)
    (h' : c₁ * mobiusTransform a₂ b₂ c₂ d₂ x + d₁ ≠ 0) :
    mobiusTransform a₁ b₁ c₁ d₁ (mobiusTransform a₂ b₂ c₂ d₂ x) =
    (a₁ * (a₂ * x + b₂) + b₁ * (c₂ * x + d₂)) /
    (c₁ * (a₂ * x + b₂) + d₁ * (c₂ * x + d₂)) := by
  unfold mobiusTransform; simp_all +decide [ mul_comm, mul_assoc, mul_left_comm ] ; ring;
  grind




/-- Meta-oracle: selects the best oracle from a family. -/
structure MetaGeodesicOracle (α : Type*) where
  family : α → (ℝ → ℝ)
  idem : ∀ i, ∀ x, family i (family i x) = family i x
  selectIdx : ℝ → α




/-- Meta-oracle consultation. -/
def MetaGeodesicOracle.consult {α : Type*} (M : MetaGeodesicOracle α) (x : ℝ) : ℝ :=
  M.family (M.selectIdx x) x




/-- With constant selector, meta-oracle is a standard oracle. -/
theorem MetaGeodesicOracle.constant_selector_is_oracle {α : Type*}
    (M : MetaGeodesicOracle α) (i : α) (hsel : ∀ x, M.selectIdx x = i) :
    ∀ x, M.consult (M.consult x) = M.consult x := by
  intro x
  simp only [MetaGeodesicOracle.consult, hsel]
  exact M.idem i _




/-- N-dimensional inverse stereographic projection ℝⁿ → Sⁿ ⊂ ℝⁿ⁺¹. -/
def invStereoN (n : ℕ) (x : Fin n → ℝ) : Fin (n + 1) → ℝ :=
  let s := ∑ i, x i ^ 2
  fun i =>
    if h : i.val < n then
      2 * x ⟨i.val, h⟩ / (1 + s)
    else
      (s - 1) / (1 + s)




theorem invStereoN_on_sphere (n : ℕ) (x : Fin n → ℝ) :
    ∑ i : Fin (n + 1), (invStereoN n x i) ^ 2 = 1 := by
  unfold invStereoN;
  norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, mul_pow, Finset.sum_mul _ _ _, div_pow ];
  norm_num [ Finset.sum_ite, Fin.
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Proof-Theoretic Ordinal Analysis II

This cycle established the structural backbone of the `OrdinalTheory` framework
(file `Pythagorean/ProofTheoreticOrdinalsLattice.lean`, extending the catalog file
`Catalog/Pythagorean/ProofTheoreticOrdinals.lean`). The main new results are:

- **Totality of inclusion** (`provablyWO_subset_total`, `le_total_theory`): any two
  `OrdinalTheory`s are comparable — the space of theories is a *chain*, not merely a
  poset. This is sharper than the catalog's observation that `pto` is not an order
  embedding.
- **`pto` is a lattice homomorphism** (`pto_meet_eq_min` together with
  `pto_join_eq_max`): the proof-theoretic ordinal preserves both meet and join.
- **Exact chain additivity of the depth metric** (`depthDist_chain_additive`): along a
  chain `T₁ ≤ T₂ ≤ T₃`, `depthDist T₁ T₃ = depthDist T₁ T₂ + depthDist T₂ T₃` exactly
  — not merely sub-additively. The directed triangle inequality
  (`depthDist_directed_triangle`) is a corollary.
- **Failure of the unconditional triangle inequality**
  (`depthDist_triangle_general_false`): with PTOs `ω+1, ω, 0` the inequality breaks,
  since `1 + ω = ω < ω+1`. So `depthDist` is a genuinely *directed* quasi-metric.
- **PTO fibers are order-convex** (`pto_constant_on_interval`): if the endpoints of an
  interval share a PTO, the PTO is constant throughout it.

The directions below extend these results.

## 1. The complete-lattice / `LinearOrder` instance up to PTO-equivalence

We proved inclusion is total (`le_total_theory`) and that `meet`/`join` realize the
infimum/supremum. The natural next step is to package `OrdinalTheory` modulo the
equivalence "same `provablyWO`" as a genuine `LinearOrder`, and then show that the
quotient by *PTO-equivalence* (`T₁ ~ T₂ ↔ pto T₁ = pto T₂`) is order-isomorphic to the
image of `pto` in the ordinals. The key insight is that the fiber-convexity theorem
`pto_constant_on_interval` already shows each PTO-fiber is an interval of the chain, so
the quotient map collapses intervals to points and is automatically monotone and
injective on the quotient — exactly the data of an order embedding. Why now? With
totality in hand, the only obstruction to a `LinearOrder`/`CompleteLattice` instance is
bookkeeping about the `provablyWO`-equivalence, which `pto_meet_eq_min` and
`pto_join_eq_max` make routine.

**Testable conjecture**: The quotient of `OrdinalTheory` by PTO-equivalence carries a
`LinearOrder` for which `pto` descends to an order embedding into `Ordinal`, and each
equivalence class is a bounded interval (hence a complete sublattice) of the inclusion
chain.

## 2. A normalized, genuine pseudometric refining `depthDist`

`depthDist_triangle_general_false` shows the raw depth distance is only a *directed*
quasi-metric because ordinal addition absorbs on the left (`1 + ω = ω`). The key
insight is that the *natural (Hessenberg) ordinal sum* `⊕` is commutative and strictly
monotone, so replacing `+` by `⊕` in the definition of `dep
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
