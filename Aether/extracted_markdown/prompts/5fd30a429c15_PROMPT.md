
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

**Title**: Integrated Information via Tensor Networks
**Domain**: Applications
**Mathematical framing**: Formalize Tononi's Integrated Information Theory (IIT) using tensor network states. Conjecture: The integrated information Phi of a tensor network state equals the minimal quantum mutual information across any bipartition. Test: compute Phi for MPS (matrix product states) with bond dimension 2 and verify it matches the Schmidt rank. Impact: connects consciousness theory to quantum information and tensor categories.
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/IIT/TensorNetworkMultiCut.lean
import Mathlib
import Computation.IIT.TensorNetworkSchmidt

/-! # Multi-Cut Integrated Information of Tensor Networks

This file **synthesizes** two existing catalog developments of Tononi's Integrated
Information Theory (IIT):

* the *combinatorial* IIT skeleton (`Applications/Consciousness/IntegratedInformation.lean`),
  where the integrated information `Φ` of an `n`-element system is the **minimum** of an
  effective-information functional over all nontrivial bipartitions (the *Minimum
  Information Partition*, MIP); and
* the *quantum/tensor-network* development (`Computation/IIT/TensorNetworkSchmidt.lean`),
  where the single-cut integrated information of a bipartite pure state is `phiBip M =
  M.rank - 1`, one less than the **Schmidt rank**.

The single-cut `phiBip` only sees one bipartition. A genuine `n`-party tensor network is
cut in many ways, and IIT's defining move is to take the *worst* (least-information-loss)
cut. We package the Schmidt rank across every nontrivial bipartition as `CutData`, define
the multi-cut integrated information

  `phiMC S  :=  min over nontrivial cuts A of  (rank A - 1)`

and prove the IIT structural theorems in this quantum setting, culminating in the
**bond-dimension tightness theorem**: for a tensor network whose Schmidt rank across every
cut is capped by a bond dimension `D`, `Φ ≤ D - 1`, and this is *attained* by the network
that is maximally entangled across every cut (Schmidt rank `D` everywhere). The explicit
bond-dimension-`2` test case of the concept (`phiMC ≤ 1`) is a corollary, and is matched
to the single-cut `phiBip` of an identity (maximally entangled) coefficient matrix via
`phi_maximallyEntangled_eq` from the Schmidt file.

## Theorem declarations

1. `phiMC_le_cut` — `Φ ≤ rank A - 1` for every cut — proved — `Finset.min'_le`.
2. `exists_MIP` — a Minimum Information Partition exists and realizes `Φ` — proved —
   `Finset.min'_mem`.
3. `le_phiMC` — `Φ` is the greatest lower bound of the cut landscape — proved —
   `Finset.le_min'`.
4. `phiMC_eq_zero_iff` — reducibility: `Φ = 0` iff the network is a product state across
   some bipartition (Schmidt rank `1`) — proved — sandwich + `rank_pos`.
5. `phiMC_mono` — monotonicity in the Schmidt-rank data — proved — evaluate at the MIP.
6. `phiMC_le_bond` — bond dimension caps integrated information: ranks `≤ D ⟹ Φ ≤ D - 1`
   — proved — `le_phiMC`-free direct min bound.
7. `phiMC_bondTwo_le_one` — the concept's bond-dimension-`2` test: `Φ ≤ 1` — proved —
   specialize 6.
8. `phiMC_const` — a network with constant Schmidt rank `D` across all cuts has `Φ = D - 1`
   — proved — the image is a singleton value.
9. `phiMC_maximallyEntangled_tight` — **headline**: the maximally entangled network
   (Schmidt rank `D` across every cut) attains the bond bound, `Φ = D - 1`, certifying
   tightness; matched to `phiBip (1 : Matrix (Fin D) (Fin D) ℂ)` — proved.
-/

open Matrix Finset

namespace IIT.TensorNetwork.MultiCut

variable {n : ℕ}

/-- The nontrivial **bipartitions** (cuts) of an `n`-party tensor network: subsets `A` of
the parties that are neither empty nor everything. Each `A` encodes the cut separating `A`
from its complement. -/
def cuts (n : ℕ) : Finset (Finset (Fin n)) :=
  univ.powerset.filter (fun A => A.Nonempty ∧ A ≠ univ)

/-- Membership characterization for `cuts`. -/
theorem mem_cuts {A : Finset (Fin n)} : A ∈ cuts n ↔ A.Nonempty ∧ A ≠ univ := by
  simp [cuts]

-- !-- The singleton `{0}` is a nonempty proper subset when `n ≥ 2`, witnessing a cut. -- !--
/-- A tensor network on at least two parties always admits a nontrivial cut. -/
theorem cuts_nonempty (h : 2 ≤ n) : (cuts n).Nonempty := by
  refine ⟨{⟨0, by omega⟩}, ?_⟩
  rw [mem_cuts]
  refine ⟨singleton_nonempty _, ?_⟩
  intro hcontra
  have : (univ : Finset (Fin n)).card = 1 := by rw [← hcontra]; simp
  rw [Finset.card_univ, Fintype.card_fin] at this
  omega

/-- **Cut data** of an `n`-party tensor network state: the Schmidt rank across every
nontrivial bipartition. A nonzero state has Schmidt rank `≥ 1` across every cut. -/
structure CutData (n : ℕ) where
  /-- The Schmidt rank across the cut separating `A` from its complement. -/
  rank : Finset (Fin n) → ℕ
  /-- A nonzero pure state has positive Schmidt rank across every cut. -/
  rank_pos : ∀ A, 1 ≤ rank A

/-- **Multi-cut integrated information** `Φ` of a tensor network: the minimum, over all
nontrivial bipartitions, of the single-cut integrated information `rank A - 1`. This is the
quantum/Schmidt-rank instance of IIT's Minimum Information Partition. -/
def phiMC (S : CutData n) (h : 2 ≤ n) : ℕ :=
  ((cuts n).image (fun A => S.rank A - 1)).min' ((cuts_nonempty h).image (fun A => S.rank A - 1))

-- !-- `phiMC` is the minimum of the finite nonempty image, so `min'_le` at `rank A - 1`. -- !--
/-- `Φ` is a lower bound: no cut has integrated information below `Φ`. -/
theorem phiMC_le_cut (S : CutData n) (h : 2 ≤ n) {A : Finset (Fin n)} (hA : A ∈ cuts n) :
    phiMC S h ≤ S.rank A - 1 :=
  Finset.min'_le _ _ (Finset.mem_image_of_mem _ hA)

-- !-- `min'_mem` places `Φ` in the image; `mem_image` extracts the witnessing cut. -- !--
/-- **The Minimum Information Partition exists and realizes `Φ`.** Some nontrivial cut has
single-cut integrated information equal to the network's `Φ`. -/
theorem exists_MIP (S : CutData n) (h : 2 ≤ n) :
    ∃ A ∈ cuts n, S.rank A - 1 = phiMC S h := by
  obtain ⟨v, hv, hve⟩ := Finset.mem_image.mp (Finset.min'_mem _ ((cuts_nonempty h).image (fun A => S.rank A - 1)))
  exact ⟨v, hv, hve⟩

-- !-- Any common lower bound of the image is `≤` its minimum, by `Finset.le_min'`. -- !--
/-- `Φ` is the **greatest** lower bound of the cut landscape: any common lower bound `c` of
the per-cut integrated informations satisfies `c ≤ Φ`. -/
theorem le_phiMC (S : CutData n) (h : 2 ≤ n) {c : ℕ}
    (hc : ∀ A ∈ cuts n, c ≤ S.rank A - 1) : c ≤ phiMC S h := by
  apply Finset.le_min'
  intro y hy
  obtain ⟨A, hA, hAe⟩ := Finset.mem_image.mp hy
  exact hAe ▸ hc A hA

-- !-- Forward: the MIP cut has `rank A - 1 = 0`, and `rank A ≥ 1` forces `rank A = 1`.
--     Backward: `0 ≤ Φ ≤ rank A - 1 = 0`. -- !--
/-- **Reducibility characterization.** A tensor network is *reducible* (`Φ = 0`) exactly
when it is a **product state across some bipartition**, i.e. has Schmidt rank `1` across
some nontrivial cut. -/
theorem phiMC_eq_zero_iff (S : CutData n) (h : 2 ≤ n) :
    phiMC S h = 0 ↔ ∃ A ∈ cuts n, S.rank A = 1 := by
  constructor
  · intro H
    obtain ⟨A, hA, hAe⟩ := exists_MIP S h
    refine ⟨A, hA, ?_⟩
    have := S.rank_pos A
    omega
  · rintro ⟨A, hA, hAe⟩
    have hle := phiMC_le_cut S h hA
    omega

-- !-- Evaluate `T`'s MIP cut `A`: `Φ S ≤ rank_S A - 1 ≤ rank_T A - 1 = Φ T`. -- !--
/-- **Monotonicity.** If `S` has pointwise no larger Schmidt rank than `T` across every
cut, then `Φ S ≤ Φ T`. -/
theorem phiMC_mono (S T : CutData n) (h : 2 ≤ n)
    (hST : ∀ A, S.rank A ≤ T.rank A) : phiMC S h ≤ phiMC T h := by
  obtain ⟨A, hA, hAe⟩ := exists_MIP T h
  have h1 := phiMC_le_cut S h hA
  have h2 := hST A
  omega

-- !-- Every image point is `≤ D - 1`, so the minimum is too. -- !--
/-- **Bond dimension caps integrated information.** If the Schmidt rank across every cut is
at most the bond dimension `D`, then `Φ ≤ D - 1`. -/
theorem phiMC_le_bond (S : CutData n) (h : 2 ≤ n) {D : ℕ}
    (hbond : ∀ A ∈ cuts n, S.rank A ≤ D) : phiMC S h ≤ D - 1 := by
  obtain ⟨A, hA, hAe⟩ := exists_MIP S h
  have := hbond A hA
  omega

-- !-- Specialize the bond bound to `D = 2`, the concept's test case. -- !--
/-- The concept's explicit test: a tensor network whose Schmidt rank is at most `2` across
every cut (e.g. a bond-dimension-`2` MPS) has `Φ ≤ 1`. -/
theorem phiMC_bondTwo_le_one (S : CutData n) (h : 2 ≤ n)
    (hbond : ∀ A ∈ cuts n, S.rank A ≤ 2) : phiMC S h ≤ 1 :=
  phiMC_le_bond S h hbond

/-- The constant-Schmidt-rank tensor network: Schmidt rank `D ≥ 1` across every cut. -/
def constCutData (n 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Multi-Cut Integrated Information of Tensor Networks

The file `Computation/IIT/TensorNetworkMultiCut.lean` synthesizes the catalog's
combinatorial IIT skeleton (`Applications/Consciousness/IntegratedInformation.lean`,
the Minimum-Information-Partition `Φ = min over bipartitions`) with the quantum/Schmidt
development (`Computation/IIT/TensorNetworkSchmidt.lean`, single-cut `phiBip = rank − 1`).
The result is a multi-cut integrated information `phiMC` taking the minimum of the
per-cut Schmidt-rank deficit over all nontrivial bipartitions, together with a
reducibility characterization (`Φ = 0` iff the state is a product across some cut), a
bond-dimension bound (`Φ ≤ D − 1`), and a tightness theorem realizing the bound by the
maximally entangled network. These leave several sharp, falsifiable continuations.

## 1. Schmidt rank from genuine coefficient matrices, not abstract `CutData`

The current `CutData` records the Schmidt rank across each cut as an abstract function.
The next step is to *derive* `rank A` from a single underlying amplitude tensor by
reshaping it across the cut `A` into a coefficient matrix `M_A`, with `rank A := M_A.rank`,
reusing `phiBip M_A` from the Schmidt file as the per-cut value. **The key insight is**
that the consistency constraint "all `M_A` arise from one global tensor" is exactly what
makes IIT's MIP nontrivial — the cuts are not independent, so the minimum is constrained by
the shared tensor. **Why now?** Mathlib already has `Matrix.rank`, `vecMulVec`, and
`rank_mul_le_left`, and the Schmidt file proves the single-cut anchors, so the reshaping
layer is the only missing piece and it is purely bookkeeping over `Fin` products.

## 2. Strict monotonicity and the entanglement order

`phiMC_mono` shows `Φ` is monotone in the Schmidt-rank data. Conjecture: if `S.rank ≤
T.rank` pointwise and the inequality is strict *at the MIP cut of `T`*, then `Φ S < Φ T`.
**The key insight is** that only the minimizing cut controls `Φ`, so strictness must be
located there rather than globally — a falsifiable refinement, since a counterexample is
any `S` that lowers a non-MIP cut while leaving the MIP cut fixed. **Why now?** The
`exists_MIP` realizer is already proved, giving direct access to the controlling cut, so
the strict version is a short `omega`/case argument away.

## 3. Subadditivity of `Φ` under tensoring of networks

Given two networks `S₁, S₂`, their independent composite has, across each cut, Schmidt
rank equal to the product of the per-component ranks. Conjecture:
`Φ(S₁ ⊗ S₂) + 1 ≤ (Φ S₁ + 1)(Φ S₂ + 1)`, i.e. integrated information is *submultiplicative*
in `rank` and the `+1` shift linearizes it. **The key insight is** that composing systems
multiplies Schmidt ranks per cut but the MIP of the composite may pick a *different* cut
than either factor's MIP, forcing an inequality rather than equality. **Why now?** With
`phiMC` defined over `Finset (Fin n)` cuts, the product network's cut lattice is the
produ
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
