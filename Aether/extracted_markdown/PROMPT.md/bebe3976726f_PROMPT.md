
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

**Title**: Our `exists_revSim_of_surjective` proves that surjective endofunctions on `Fin n
**Domain**: Computation
**Mathematical framing**: # Future Directions: Reversible Computing and Thermodynamic Efficiency

## 1. Tight Ancilla Bound for General (Non-Surjective) Functions

Our `exists_revSim_of_surjective` proves that surjective endofunctions on `Fin n` can be made reversible with 1 ancilla bit (since surjective = bijective on finite types). The genuinely hard case is non-surjective functions where the max fiber size exceeds 1.

**Conjecture**: For any `f : Fin n → Fin n` with maximum fiber size `k`, there exists a reversible simulation using exactly `Fin k` ancilla, and this is tight — no simulation with `Fin (k-1)` ancilla exists.

The key insight is that the lower bound follows from a pigeonhole argument: if the ancilla space has fewer than `k` elements, then two inputs in the same fiber with the same ancilla must collide, violating injectivity of the simulation bijection.

**Why now?** We have the fiber infrastructure (`fiber`, `maxFiberSize`, `injective_iff_maxFiber_le_one`) and the `RevSim` structure already in place. The upper bound construction requires enumerating fibers and constructing an explicit bijection using `Finset.equivFin`, which is available in Mathlib.

## 2. Circuit Complexity of Reversible Simulation

The Toffoli gate is universal for reversible Boolean computation (any bijection on `Bool^n` can be decomposed into Toffoli gates). We formalized the Toffoli gate and showed it simulates AND.

**Conjecture**: Any function `f : (Fin 2)^n → (Fin 2)^n` can be expressed as a composition of at most `O(n · 2^n)` Toffoli gates applied to `(Fin 2)^(n + O(n))` (i.e., with O(n) ancilla bits). Furthermore, there exist functions requiring `Ω(2^n / n)` Toffoli gates (a counting/Shannon-style lower bound).

The key insight is that the upper bound follows from the standard construction: decompose f into a sequence of controlled-NOT operations using the truth table, and each row requires at most n Toffoli gates. The lower bound is a counting argument comparing the number of possible circuits of given size to the number of bijections.

**Why now?** The Toffoli and Fredkin gate formalizations provide the atomic building blocks. Formalizing circuit composition as lists of gate applications on `(Fin 2)^n` would connect to the existing `rev_compose` theorem and the group structure of `Equiv.Perm`.

## 3. Shannon Entropy Preservation Under Bijections

We proved that bijections preserve cardinality (`bijection_preserves_fiber_card`) and information content of uniform distributions (`bijection_preserves_info`). The natural next step is full Shannon entropy.

**Conjecture**: For any probability distribution `p : α → ℝ≥0∞` on a finite type and any bijection `σ : α ≃ α`, the Shannon entropy `H(p) = -∑_x p(x) log p(x)` equals `H(p ∘ σ⁻¹)`. Moreover, for any non-injective function `f : α → α`, there exists a distribution `p` such that `H(f_* p) < H(p)` (entropy strictly decreases under irreversible maps for some distributions).

The key insight is that Shannon entropy is a symmetric function of the probability vector, and bijections merely permute the vector. The strict decrease for non-injective maps follows because collapsing fibers forces probability mass to merge, which strictly decreases entropy by the strict concavity of `-x log x`.

**Why now?** Mathlib has `MeasureTheory.entropy` and related infrastructure. The challenge is connecting our finite combinatorial setup to the measure-theoretic entropy definition, but `Finset.sum` over explicit distributions avoids most measure theory overhead.

## 4. Reversible Computation and Kolmogorov Complexity

**Conjecture**: For any computable bijection `f : ℕ → ℕ`, the Kolmogorov complexity satisfies `K(f(n)) ≤ K(n) + O(1)` and `K(n) ≤ K(f(n)) + O(1)`. That is, reversible computation preserves Kolmogorov complexity up to an additive constant. For non-injective computable `f`, there exist infinitely many `n` with `K(f(n)) < K(n) - log(|f⁻¹(f(n))|) + O(1)`.

The key insight is that reversibility in the Kolmogorov setting means the description of the inverse is bounded (since it's computable), so the overhead is O(1). The loss for non-injective functions comes from the coding theorem: you lose the information needed to distinguish elements within a fiber.

**Why now?** While Kolmogorov complexity is not directly computable, the inequalities can be stated as relations between program sizes in a fixed universal Turing machine model. Our fiber-size infrastructure provides the combinatorial backbone, and Lean's computability library provides the TM model.

## 5. Thermodynamic Cost of Sorting

**Conjecture**: Any comparison-based sorting algorithm on `n` elements, when implemented reversibly, requires at least `⌈log₂(n!)⌉` ancilla bits, and merge sort achieves this bound (up to lower-order terms). The thermodynamic cost (in units of `kT ln 2`) of irreversible sorting is exactly `log₂(n!)`.

The key insight is that sorting maps `n!` permutations to a single sorted output, so the fiber of the "sort" function has size `n!`. By our `maxFiberSize` framework, this requires `n!` ancilla states, which is `⌈log₂(n!)⌉` bits. This connects algorithmic complexity (comparison lower bounds) to thermodynamic cost via Landauer's principle.

**Why now?** We have the fiber framework and the Landauer bound infrastructure. Formalizing sorting as a function `Equiv.Perm (Fin n) → Fin 1` (collapsing all permutations to one output) makes the fiber size exactly `n!`, directly applying our theory. Mathlib's `Nat.factorial` and Stirling's approximation provide the asymptotic analysis.

Research domain: Computation
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/IrreversibilityCost.lean
/-
# Strict Irreversibility Cost of Non-Injective Computation

This file complements `Computation.TightAncillaBound` and builds directly on the
thermodynamic infrastructure of `Computation.ReversibleSortingBennett`
(`infoErased`, `landauerCost`, `landauerGap`, `landauer_gap_nonneg`).

The catalog proves `landauer_gap_nonneg`: irreversible computation costs *at
least* as much as reversible computation. Here we sharpen the inequality to a
**strict** one exactly in the irreversible regime: a function loses a positive
amount of information — and hence incurs a strictly positive Landauer cost —
**iff** it is non-injective. Combined with
`TightAncilla.maxFiberSize_le_one_iff_injective`, this closes the conceptual
loop: a function needs more than one ancilla state ⇔ it is non-injective ⇔ it
erases information ⇔ its Landauer gap is strictly positive.

## Main results

* `image_card_lt_of_not_injective` — a non-injective map on a finite type has
  strictly fewer image points than domain points.
* `infoErased_pos_iff_not_injective` — positive information erasure characterises
  non-injectivity.
* `landauerGap_pos_of_not_injective` — strict positivity of the Landauer gap for
  every non-injective map (at positive temperature).
-/

import Mathlib
import Computation.ReversibleSortingBennett
import Computation.TightAncillaBound

open Finset Function

namespace IrreversibilityCost

/-
!-- Lab Notebook --!--
Hypothesis: `landauer_gap_nonneg` should be an equality `= 0` exactly for
injective maps, and a strict inequality `> 0` exactly otherwise. The
discriminating quantity is whether the image shrinks.
Result: Proved `infoErased f > 0 ↔ ¬Injective f` and the strict Landauer gap.
Insight: `infoErased = logb 2 |α| - logb 2 |image f|` is positive precisely
when `|image f| < |α|`, which by `Finset.card_image_iff` is exactly failure
of injectivity. `Real.logb` strict monotonicity does the rest.
Failure analysis: Watch the degenerate cases — `Real.logb` is only well behaved
for positive arguments. Non-injectivity forces `|α| ≥ 2` and `|image f| ≥ 1`,
so both logs are taken at strictly positive integers and monotonicity applies.
!-- end Lab Notebook --!--

!-- sketch: `card (image f) ≤ card α` always; equality would mean `InjOn` on
univ (`Finset.card_image_iff`), i.e. `f` injective, contradiction. --!--

A non-injective function on a finite type hits strictly fewer points than its
domain has.
-/
theorem image_card_lt_of_not_injective {α β : Type*}
    [Fintype α] [DecidableEq β]
    (f : α → β) (h : ¬ Function.Injective f) :
    (Finset.image f Finset.univ).card < Fintype.card α := by
  refine' lt_of_le_of_ne _ _;
  · exact Finset.card_image_le.trans_eq ( Finset.card_univ );
  · contrapose! h;
    exact fun x y hxy => by have := Finset.card_image_iff.mp ( by aesop : Finset.card ( Finset.image f Finset.univ ) = Finset.card Finset.univ ) ; aesop;

/-
!-- sketch: `infoErased f = logb 2 |α| - logb 2 |image f|`; this is `> 0` iff
`|image f| < |α|` by strict monotonicity of `logb 2`, which by
`image_card_lt_of_not_injective` is equivalent to non-injectivity. --!--

**Information erasure characterises irreversibility.** The information erased
by `f` (in bits) is strictly positive iff `f` is non-injective.
-/
theorem infoErased_pos_iff_not_injective {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) :
    0 < infoErased f ↔ ¬ Function.Injective f := by
  constructor <;> intro h;
  · intro hf;
    unfold infoErased at h; simp_all +decide [ Finset.card_image_of_injective ] ;
  · exact sub_pos_of_lt ( Real.logb_lt_logb ( by norm_num ) ( Nat.cast_pos.mpr ( Finset.card_pos.mpr ⟨ _, Finset.mem_image_of_mem f ( Finset.mem_univ ( Classical.arbitrary α ) ) ⟩ ) ) ( by exact_mod_cast image_card_lt_of_not_injective f h ) )

/-
!-- sketch: `landauerGap = kT·log 2·infoErased`; with `kT > 0` and
`infoErased > 0` (from `infoErased_pos_iff_not_injective`) the product is
strictly positive. --!--

**Strict Landauer cost.** At positive temperature, every non-injective
computation has a strictly positive Landauer gap — irreversibility is never free.
-/
theorem landauerGap_pos_of_not_injective {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β] [Nonempty α]
    (f : α → β) (kT : ℝ) (hkT : 0 < kT) (h : ¬ Function.Injective f) :
    0 < landauerGap f kT := by
  exact mul_pos ( mul_pos hkT ( Real.log_pos ( by norm_num ) ) ) ( infoErased_pos_iff_not_injective f |>.2 h )

end IrreversibilityCost


-- NEW_FILE: Catalog/Computation/TightAncillaBound.lean
/-
# Tight Ancilla Bound for Reversible Simulation

This file extends `Computation.ReversibleSortingBennett` (which proved Bennett's
reversible-witness theorem and the *lower* bound `rev_witness_aux_lower_bound`
in the special case of a genuine bijection `α ≃ β × Aux`) to the genuinely
general — and harder — situation of an arbitrary, possibly **non-surjective**
function.

A *reversible simulation* of `f : α → β` is an **injection**
`g : α → β × Aux` whose first component recovers `f`.  Unlike a `RevWitness`
(which demands a bijection, forcing `|β| ∣ |α|`), a reversible simulation
exists for every `f`, and the question becomes: how small can the ancilla
type `Aux` be?

## Main results

* `maxFiberSize_le_card_of_revSim` — **lower bound**: every reversible
  simulation needs ancilla space at least `maxFiberSize f`.
* `exists_revSim_fin_maxFiber` — **upper bound**: there is a reversible
  simulation with ancilla type `Fin (maxFiberSize f)`.
* `tight_ancilla_bound` — the two combine: `maxFiberSize f` is the exact
  minimal ancilla cardinality, and no simulation into `Fin (maxFiberSize f - 1)`
  exists once `f` has a nontrivial fiber.
* `maxFiberSize_le_one_iff_injective` — `f` is injective iff its largest
  fiber has size `≤ 1`, i.e. iff one ancilla state suffices.

These results reuse `maxFiberSize` from `ReversibleSortingBennett` and sharpen
`rev_witness_aux_lower_bound`.
-/

import Mathlib
import Computation.ReversibleSortingBennett

open Finset Function

namespace TightAncilla

-- !-- Lab Notebook --!--
-- Hypothesis: The Bennett witness in the catalog is restricted to bijections
--   `α ≃ β × Aux`, which only exist when `|β|` divides `|α|`. We conjectured the
--   right invariant for *arbitrary* functions is `maxFiberSize f`, realised by an
--   *injection* rather than a bijection.
-- Result: Proved both directions — `maxFiberSize f` ancilla states are necessary
--   (pigeonhole on a single fiber) and sufficient (sigma/fiber enumeration).
-- Insight: The fiber sigma-equivalence `Equiv.sigmaFiberEquiv` is the load-bearing
--   tool: it reduces the upper bound to embedding each fiber into `Fin k`.
-- Failure analysis: An earlier attempt tried to build the index function
--   `α → Fin k` by hand via `Finset.sort`; bounding the index was painful. Routing
--   through the sigma type and `Embedding.nonempty_of_card_le` removed all the
--   arithmetic.
-- !-- end Lab Notebook --!--

/-- A **reversible simulation** of `f : α → β`: an injection into `β × Aux`
whose first component recovers `f`.  The ancilla type `Aux` records exactly the
information lost by `f`. -/
structure RevSim {α β : Type*} (f : α → β) where
  /-- The ancilla ("history") type. -/
  Aux : Type*
  /-- The simulating injection. -/
  encode : α → β × Aux
  /-- The encoding is injective — this is what "reversible" means. -/
  enc_inj : Function.Injective encode
  /-- The first component recovers the original function. -/
  consistent : ∀ a, (encode a).1 = f a

/-
!-- sketch: a fiber injects into the ancilla via the second component of any
reversible simulation, since equal second components + equal first
components (both `= b`) force equal encodings, hence equal inputs. --!--

**Lower bound.** Any reversible simulation of `f` with a finite ancilla type
needs at least `maxFiberSize f` ancilla states.
-/
theorem maxFiberSize_le_card_of_revSim {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β]
  
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Reversible Computing and Thermodynamic Efficiency

## Synthesis of this cycle

This cycle closed the conceptual loop relating the *combinatorial* invariant of
a finite function (its fiber structure) to the *thermodynamic* cost of computing
it. Building on the catalog file `Computation.ReversibleSortingBennett` (which
gave Bennett's reversible-witness theorem for the special case of a genuine
bijection `α ≃ β × Aux`, plus the `landauer_gap_nonneg` non-strict cost bound),
we delivered two new files.

`Computation.TightAncillaBound` introduces the right notion for *arbitrary*
(possibly non-surjective) functions — a **reversible simulation**, i.e. an
*injection* `g : α → β × Aux` with `(g a).1 = f a` — and proves the ancilla
size is tightly pinned by the largest fiber:

* `maxFiberSize_le_card_of_revSim` — every simulation needs `≥ maxFiberSize f`
  ancilla states (pigeonhole on one fiber);
* `exists_revSim_fin_maxFiber` — `Fin (maxFiberSize f)` always suffices
  (via `Equiv.sigmaFiberEquiv` and per-fiber embeddings);
* `tight_ancilla_bound` — the two combine: `maxFiberSize f` is *exactly* minimal,
  and `Fin (maxFiberSize f - 1)` is impossible once a nontrivial fiber exists;
* `maxFiberSize_le_one_iff_injective` — one ancilla state ⇔ injectivity.

`Computation.IrreversibilityCost` sharpens `landauer_gap_nonneg` into a strict
dichotomy, reusing the catalog's `infoErased`/`landauerGap`:

* `infoErased_pos_iff_not_injective` — positive information erasure characterises
  non-injectivity;
* `landauerGap_pos_of_not_injective` — at positive temperature, every
  non-injective map costs a strictly positive amount of work.

Together: *more than one ancilla state* ⇔ *non-injective* ⇔ *erases information*
⇔ *strictly positive Landauer gap*. The fiber invariant `maxFiberSize` is the
single quantity governing the entire chain.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `maxFiberSize_le_card_of_revSim` | TightAncillaBound | lower ancilla bound |
| `exists_revSim_fin_maxFiber` | TightAncillaBound | matching upper bound |
| `tight_ancilla_bound` | TightAncillaBound | exact minimality |
| `maxFiberSize_le_one_iff_injective` | TightAncillaBound | injective ⇔ 1 ancilla |
| `image_card_lt_of_not_injective` | IrreversibilityCost | image strictly shrinks |
| `infoErased_pos_iff_not_injective` | IrreversibilityCost | erasure ⇔ non-injective |
| `landauerGap_pos_of_not_injective` | IrreversibilityCost | strict Landauer cost |

## Research directions for the next cycle

### 1. Optimal ancilla measured in *bits*, not *states*

We pinned the minimal ancilla *cardinality* at `maxFiberSize f`. Physically the
relevant cost is the number of *bits*, i.e. `⌈log₂ (maxFiberSize f)⌉`. The
conjecture is that `RevSim` realised over a *binary* ancilla `Fin 2 ^ m`
requires and admits exactly `m = ⌈log₂ (maxFiberSize f)⌉`, and that this equals
the catalog's `infoErased` on the worst-case uniform input. **The key insight
is** that the cardinalit
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
