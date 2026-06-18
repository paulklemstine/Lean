
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

**Title**: Integrated Information via Tensor Networks
**Domain**: Computation
**Mathematical framing**: Formalize Tononi's Integrated Information Theory (IIT) using tensor network states. Conjecture: The integrated information Phi of a tensor network state equals the minimal quantum mutual information across any bipartition. Test: compute Phi for MPS (matrix product states) with bond dimension 2 and verify it matches the Schmidt rank. Impact: connects consciousness theory to quantum information and tensor categories.
Research domain: Computation
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/IIT/MultipartiteMIP.lean
import Mathlib

/-! # Integrated Information via Tensor Networks — Multipartite Minimum-Information Partition

This file lifts the bipartite Schmidt-rank picture of
`Computation.IIT.TensorNetworkSchmidt` to the genuinely multipartite setting that IIT
actually requires: a state on `n` sites, each of local dimension `d`, is an amplitude
tensor `ψ : (Fin n → Fin d) → ℂ`. Each bipartition `S ⊆ Fin n` reshapes `ψ` into a
matrix `cutMatrix (· ∈ S) ψ` whose rank is the Schmidt rank across that cut.

The IIT integrated information `Φ` is the value over the **minimum-information partition
(MIP)** — the bipartition that integrates the *least*. We model it as

  `phiMIP ψ := min_{S nontrivial} (schmidtRankAt S ψ - 1)`.

This is the direct multipartite generalization of `CausalSystem.phi` from
`Shared.CausalIntegration.Core` (min over `nontrivialBipartitions`), with the graph
cross-cut weight replaced by the quantum Schmidt rank across the cut.

Main results:
* `cutMatrix_rank_le_one_of_product` — if `ψ` factors as a product across a cut `S`, the
  Schmidt rank across `S` is ≤ 1.
* `phiMIP_eq_zero_of_product_cut` — the central IIT statement: if *any* nontrivial
  bipartition reduces the state to a product, then `Φ = 0`. (A system with a
  zero-integration partition is reducible.)
* `schmidtRankAt_le_block` — the Schmidt rank across `S` is bounded by the Hilbert-space
  dimension of the complementary block `d ^ |Sᶜ|` (area-law-style bound).
-/

open Matrix Finset

namespace IIT.Multipartite

variable {n d : ℕ}

/-- Reshape an `n`-site amplitude tensor `ψ` into the bipartite coefficient matrix across
the cut defined by predicate `p`: rows indexed by configurations of the `p`-block, columns
by configurations of its complement. -/
noncomputable def cutMatrix (p : Fin n → Prop) [DecidablePred p]
    (ψ : (Fin n → Fin d) → ℂ) :
    Matrix ({i // p i} → Fin d) ({i // ¬ p i} → Fin d) ℂ :=
  fun a b => ψ ((Equiv.piEquivPiSubtypeProd p (fun _ => Fin d)).symm (a, b))

/-- The Schmidt rank of the state `ψ` across the bipartition given by a finite set `S` of
sites: the rank of the reshaped coefficient matrix. -/
noncomputable def schmidtRankAt (S : Finset (Fin n)) (ψ : (Fin n → Fin d) → ℂ) : ℕ :=
  (cutMatrix (· ∈ S) ψ).rank

/-- The nontrivial bipartitions of `Fin n`: nonempty proper subsets. (Same indexing set as
`Shared.CausalIntegration.Core.nontrivialBipartitions`.) -/
def biparts (n : ℕ) : Finset (Finset (Fin n)) :=
  univ.powerset.filter (fun S => S.Nonempty ∧ S ≠ univ)

/-- Integrated information over the minimum-information partition: the least
`schmidtRankAt S ψ - 1` over all nontrivial bipartitions `S`. -/
noncomputable def phiMIP (ψ : (Fin n → Fin d) → ℂ) (hne : (biparts n).Nonempty) : ℕ :=
  (biparts n).inf' hne (fun S => schmidtRankAt S ψ - 1)

-- !-- Lab Notebook: cutMatrix_rank_le_one_of_product -- !--
-- !-- Hypothesis: If the amplitude tensor factorizes across a cut `S` as
--     `ψ(x) = f(x|_S) · g(x|_Sᶜ)`, the reshaped coefficient matrix is an outer product,
--     so the Schmidt rank across `S` is ≤ 1. -- !--
-- !-- Result: Proved. The reshape `cutMatrix (·∈S) ψ` equals `vecMulVec f g` pointwise
--     (the subtype index makes the `dite` from `piEquivPiSubtypeProd` collapse via
--     `i.2`), and `rank_vecMulVec_le` finishes. -- !--
-- !-- Insight: The subtype membership proof `i.2` is exactly what kills the
--     decidable-branch in the reshaping equivalence — the cleanest way to relate a
--     tensor factorization to outer-product matrix structure. -- !--
-- !-- Failure analysis: First `simp`-only attempt left a `dite` goal; resolving it by
--     `congr 1` then `dif_pos i.2 / dif_neg i.2` on each factor was the fix. -- !--
-- !-- End Lab Notebook -- !--

-- !-- A factorization `ψ(x)=f(x|_S)·g(x|_Sᶜ)` makes the reshaped matrix an outer product
--     `vecMulVec f g`, whose rank is ≤ 1. -- !--
/-- If `ψ` factors as a product across the cut `S`, the Schmidt rank across `S` is ≤ 1. -/
theorem cutMatrix_rank_le_one_of_product (S : Finset (Fin n))
    (f : ({i // i ∈ S} → Fin d) → ℂ) (g : ({i // i ∉ S} → Fin d) → ℂ)
    (ψ : (Fin n → Fin d) → ℂ)
    (hfac : ∀ x, ψ x = f (fun i => x i) * g (fun i => x i)) :
    schmidtRankAt S ψ ≤ 1 := by
  have hM : cutMatrix (· ∈ S) ψ = vecMulVec f g := by
    ext a b
    simp only [cutMatrix, vecMulVec, hfac, Equiv.piEquivPiSubtypeProd_symm_apply]
    congr 1
    · congr 1; funext i; rw [dif_pos i.2]
    · congr 1; funext i; rw [dif_neg i.2]
  simp only [schmidtRankAt, hM]
  exact rank_vecMulVec_le f g

-- !-- Lab Notebook: phiMIP_eq_zero_of_product_cut -- !--
-- !-- Hypothesis: A multipartite state is "reducible" (Φ = 0) as soon as ONE nontrivial
--     bipartition factorizes it into a product — the existence of a zero-integration
--     partition pins the minimum-information-partition value to 0. -- !--
-- !-- Result: Proved. `inf'_le` at the product cut `S` bounds `Φ` by
--     `schmidtRankAt S ψ - 1 = 0`, and Φ ≥ 0, so Φ = 0. -- !--
-- !-- Insight: This is the precise tensor-network analogue of
--     `phi_zero_of_disconnected`: a single decoupled cut suffices for global
--     reducibility. It is the *only-if* direction of the IIT conjecture
--     "Φ = 0 ⟺ state is a product across some cut". -- !--
-- !-- Failure analysis: None once `phiMIP` was defined via `inf'`; `omega` combines the
--     `inf'_le` bound with the rank-≤-1 lemma. -- !--
-- !-- End Lab Notebook -- !--

-- !-- `inf'_le` at the product cut `S` gives `Φ ≤ schmidtRankAt S ψ - 1 = 0`; with Φ ≥ 0,
--     conclude `Φ = 0`. -- !--
/-- **Reducibility ⟹ zero integration.** If some nontrivial bipartition `S` reduces the
state to a product, the minimum-information-partition integrated information is `0`. -/
theorem phiMIP_eq_zero_of_product_cut (ψ : (Fin n → Fin d) → ℂ)
    (S : Finset (Fin n)) (hS : S ∈ biparts n)
    (f : ({i // i ∈ S} → Fin d) → ℂ) (g : ({i // i ∉ S} → Fin d) → ℂ)
    (hfac : ∀ x, ψ x = f (fun i => x i) * g (fun i => x i)) :
    phiMIP ψ ⟨S, hS⟩ = 0 := by
  have hle : phiMIP ψ ⟨S, hS⟩ ≤ schmidtRankAt S ψ - 1 := Finset.inf'_le _ hS
  have h1 : schmidtRankAt S ψ ≤ 1 := cutMatrix_rank_le_one_of_product S f g ψ hfac
  omega

-- !-- Lab Notebook: schmidtRankAt_le_block -- !--
-- !-- Hypothesis: The Schmidt rank across any cut is capped by the Hilbert dimension of
--     the smaller block — the discrete shadow of the entanglement area law. -- !--
-- !-- Result: Proved (complement-block form). `rank ≤ #columns = d ^ |Sᶜ|` via
--     `rank_le_card_width`. -- !--
-- !-- Insight: Combined with `phi_mps_le_bond`, this shows two independent ceilings on
--     integration — geometric (block size) and algebraic (bond dimension); the MIP picks
--     the cut where their minimum is smallest. -- !--
-- !-- Failure analysis: None; `rank_le_card_width` applies verbatim after unfolding. -- !--
-- !-- End Lab Notebook -- !--

-- !-- `rank ≤ #columns` of the reshaped matrix, i.e. the dimension of the complement
--     block's configuration space, `d ^ |Sᶜ|`. -- !--
/-- The Schmidt rank across the cut `S` is bounded by the dimension of the complementary
block's configuration space (`= d ^ |Sᶜ|`): a discrete area-law-style bound. -/
theorem schmidtRankAt_le_block (S : Finset (Fin n)) (ψ : (Fin n → Fin d) → ℂ) :
    schmidtRankAt S ψ ≤ Fintype.card ({i // i ∉ S} → Fin d) := by
  simpa [schmidtRankAt] using (cutMatrix (· ∈ S) ψ).rank_le_card_width

end IIT.Multipartite



-- NEW_FILE: Catalog/Computation/IIT/TensorNetworkSchmidt.lean
import Mathlib

/-! # Integrated Information via Tensor Networks — Bipartite Schmidt Rank

A formalization of the discrete, exact core of Tononi's Integrated Information Theory
(IIT) for *quantum* states represented as tensor networks. We model a bipartite pure
state by its coefficient matrix `M : Matrix (Fin m) (Fin n) ℂ` (the amplitude tensor
reshaped across the single cut). The **Schmidt rank** of the state is exactly the matrix
rank of `M`, and we define a discrete inte
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Integrated Information via Tensor Networks

## Synthesis

This cold-start cycle established a rigorous, sorry-free algebraic skeleton connecting
Tononi's Integrated Information Theory (IIT) to quantum tensor networks. The key structural
move was to identify the IIT integrated-information functional `Φ` of a pure quantum state
with the **Schmidt rank** of its coefficient tensor across a cut, discretized as
`Φ = rank − 1`. Under this identification, the two poles of IIT become exact linear-algebra
facts: a *reducible* (product/separable) state has `Φ = 0` (`phi_productState_eq_zero`,
`phiMIP_eq_zero_of_product_cut`), and the *maximally entangled* state attains the maximal
`Φ = d − 1` (`phi_maximallyEntangled_eq`). In between, the matrix-product-state (MPS) bond
dimension `D` provides a sharp algebraic ceiling on integration, `Φ ≤ D − 1`
(`phi_mps_le_bond`), with the bond-dimension-2 case (`phi_mps_bondTwo_le_one`) realizing the
concept's explicit test: a bond-2 MPS can integrate at most one bit's worth of Schmidt
structure.

The cycle deliberately built on the catalog's existing graph-theoretic IIT in
`Shared.CausalIntegration.Core`, where `CausalSystem.phi` is the min-cut of a weighted
digraph over `nontrivialBipartitions`. We mirrored that minimum-over-bipartitions
architecture exactly in `phiMIP`, replacing the graph cross-cut weight with the quantum
Schmidt rank across the cut. This makes the two formalizations *structurally aligned*: both
take a minimum over the same indexing set, and both have a "decoupled cut ⟹ Φ = 0" theorem
(`phi_zero_of_disconnected` ↔ `phiMIP_eq_zero_of_product_cut`). The cross-domain bridge —
graph min-cut IIT ≅ tensor-network Schmidt-rank IIT — is the novel contribution.

What we could *not* close this cycle: the converse direction (`Φ = 0 ⟹ the state is a
product across some cut`), which requires the rank-one ⟹ outer-product structure theorem;
and the genuine quantum *mutual information* (von Neumann entropy) version, which Mathlib
does not yet support for density matrices. These define the natural next cycle. The deepest
open structural question is whether the discrete `Φ = rank − 1` is *monotone* under local
operations (LOCC), which would make it a bona fide entanglement measure rather than a mere
cut statistic.

## Results Summary

- `phi_productState_eq_zero`: proved — a separable bipartite state `|u⟩⊗|v⟩` has `Φ = 0`,
  the IIT reducibility axiom as an exact rank fact.
- `phi_mps_le_bond`: proved — an MPS through a bond of dimension `D` satisfies `Φ ≤ D − 1`;
  bond dimension is the algebraic throttle on integration.
- `phi_mps_bondTwo_le_one`: proved — the concept's explicit bond-2 test case, `Φ ≤ 1`.
- `phi_maximallyEntangled_eq`: proved — the maximally entangled `d⊗d` state attains the
  extremal `Φ = d − 1`, showing the bond bound is tight (needs `D = d`).
- `cutMatrix_rank_le_one_of_product`: proved — a tensor factorizing across a cut has Schmidt
  rank ≤ 1 across that cut (multipartite
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
