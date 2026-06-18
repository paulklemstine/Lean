
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
3. **RESEARCH_PAPER.tex** (NEW) — A clean, compilable LaTeX version of
   the paper that mirrors the content of RESEARCH_PAPER.md. Use standard
   amsmath/amsart or article class, define all theorems inline, and make
   it suitable for direct PDF compilation with `pdflatex`. This is the
   publishable artifact.
4. **demo.py** — Numerical examples demonstrating the key results.
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
  "research_paper_tex": "RESEARCH_PAPER.tex",
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

**Title**: Derived from this cycle's findings in `Core.lean` and `Functoriality.lean`, whic
**Domain**: Novelty
**Mathematical framing**: # Future Directions — Rips Graph Monotonicity as a Functor into Tropical Valuation Objects

Derived from this cycle's findings in `Core.lean` and `Functoriality.lean`, which build the
object map (finite metric space ↦ normalized monotone edge-count profile in
`tropicalization_base`) and the morphism map (injective nonexpanding maps ↦ tropical
domination `RipsProfileDomination`).

## Conjecture 1 — The edge-count profile is *strictly* monotone across critical scales

**Statement.** For a finite metric space with at least two points at distance `d`, the
profile `ripsEdgeCount α` strictly increases at the threshold `r = ⌈d⌉`:
`ripsEdgeCount α (r-1) < ripsEdgeCount α r` whenever a pair first becomes connected at `r`.

**The key insight is...** that the *jumps* of the monotone profile encode exactly the
multiset of pairwise distances — the profile is a discrete derivative of the distance
distribution, so strict monotonicity at a scale certifies a new edge appearing there.

**Why now?** `ripsEdgeCount_mono` already gives the weak inequality through
`Set.ncard_le_ncard`; the strict version only needs an explicit witnessing edge in the
difference set, a small step that turns the profile into a genuine persistence summary.

## Conjecture 2 — Profiles separate finite metric spaces up to a tropical isometry invariant

**Statement.** Two finite metric spaces with integer distances have equal edge-count
profiles for all `r` iff they have the same multiset of pairwise distances; hence the
profile is a complete invariant of the distance multiset (though not of the space).

**The key insight is...** that `ripsProfile_max_chain` exhibits the profile as a chain in
`tropicalization_base`, and the successive tropical differences recover the distance
histogram bijectively.

**Why now?** Both directions of the equivalence are within reach of the `ncard`/`edgeSet`
machinery already used here; the forward direction is immediate and the reverse is a
counting identity over `Sym2 α`.

## Conjecture 3 — Domination is a genuine partial order, not merely a preorder, on profiles

**Statement.** On the quotient of finite integer metric spaces by "equal profile", the
relation `RipsProfileDomination` is antisymmetric: mutual domination forces equal profiles.

**The key insight is...** that `dom_refl` and `dom_trans` already give a preorder via
`tropicalization_base.le_refl`/`le_trans`, and `tropicalization_base.le_antisymm` upgrades
it to a partial order once profiles are the carriers.

**Why now?** The antisymmetry axiom is *already present* in `TropicalValuationObject`
(`le_antisymm`), so the categorical bridge built here exposes the order structure for free.

## Conjecture 4 — Non-injective nonexpanding maps satisfy a *reversed* bound

**Statement.** A surjective nonexpanding map `f : α → β` of finite metric spaces satisfies
`ripsEdgeCount β r ≤ (something explicit in fibers) · ripsEdgeCount α r`; in particular
quotient (gluing) maps can only *decrease* edges after accounting for collapsed pairs.

**The key insight is...** that the failure analysis in `Functoriality.lean` (injectivity is
necessary) is not a dead end but the boundary of a *second* functor going the other way —
collapsing points is a colimit-style operation dual to the embedding functor.

**Why now?** The counterexample showing non-injective maps break the forward bound is
already documented; formalizing its quantitative replacement is the natural next theorem and
connects to the catalog's `coveringNumber_antitone`.

## Conjecture 5 — The profile assembles into an `UltraNormObj` via tropical reconstruction

**Statement.** The edge-count profile of a finite metric space induces a separated
`UltraNormObj` (from `CategoricalTropicalUltrametric`) whose norm is the threshold at which
two configurations first agree, and nonexpanding embeddings induce `UltraHom`s.

**The key insight is...** that `valuationReconstruct` already turns ℕ-valued tropical
valuation data into an ultrametric seminorm object, so the profile (a ℕ-valued tropical
datum) should reconstruct an ultrametric directly, closing the Applications ↔ Bridges loop.

**Why now?** The reconstruction functor and its functoriality (`valuationReconstruct_map_comp`)
are mature in the catalog; the only missing input is precisely the tropical datum produced in
`Core.lean`, making this the immediate capstone of the bridge.

Research domain: Novelty
Research mode: formalize


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: d9dd0490_retry3_aristotle/Catalog/Applications/PoincareData/RipsFunctorialEdgeCount.lean
/-
  # Functorial Edge Counts for Vietoris–Rips Graphs

  This file packages a small, finite-combinatorial API for counting the edges of the
  Vietoris–Rips 1-skeleton (`ripsGraph`) of a finite (pseudo)metric space.  It builds
  directly on `Catalog.Applications.PoincareData.MetricFiltration`, reusing the
  `ripsGraph` construction together with its filtration monotonicity lemma
  `ripsGraph_mono`.

  We count edges via the finite graph combinatorics already present in Mathlib:
  `SimpleGraph.edgeFinset` and finset cardinalities.  No `Sym2`-based hand-rolled
  counting or `Set.ncard` is introduced; the only appearance of `Sym2` is the standard
  edge-map `Sym2.map f` used to transport edges along a vertex map.

  ## Invariant

  For a finite metric space `α`, `edgeCount α r` is the number of edges of the Rips graph
  at scale `r`.  The two structural facts are:

  * **Monotonicity in the scale** — enlarging `r` only adds edges, so the count is
    nondecreasing.
  * **Domination under injective nonexpanding maps** — an injective, distance
    nonincreasing map `f : α → β` sends edges to edges injectively, so the source count
    is dominated by the target count.

  ## Main results

  * `edgeCount`                              — the number of Rips edges at scale `r`.
  * `ripsProfile`                            — the edge count as a function `ℝ → ℕ`.
  * `edgeCount_mono`                         — `r ≤ s → edgeCount α r ≤ edgeCount α s`.
  * `ripsProfile_monotone`                   — `Monotone (ripsProfile α)`.
  * `ripsGraph_adj_map`                      — edges map to edges under an injective
                                               nonexpanding map (adjacency form).
  * `edgeCount_le_of_injective_nonexpanding` — `edgeCount α r ≤ edgeCount β r`.
-/
import Catalog.Applications.PoincareData.MetricFiltration

open Finset Set

noncomputable section

/-! ## Edge counts and the Rips profile -/

/-- The number of edges of the Vietoris–Rips graph `ripsGraph α r` at scale `r`,
    counted via `SimpleGraph.edgeFinset`. -/
noncomputable def edgeCount (α : Type*) [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
    (r : ℝ) : ℕ :=
  (ripsGraph α r).edgeFinset.card

/-- The **Rips edge-count profile** of a finite metric space: the edge count viewed as a
    function of the scale `r`. -/
noncomputable def ripsProfile (α : Type*) [Fintype α] [DecidableEq α] [PseudoMetricSpace α] :
    ℝ → ℕ :=
  fun r => edgeCount α r

/-! ## Monotonicity in the scale -/

/-- Enlarging the scale only adds edges, so the edge count is nondecreasing.
    The edge inclusion comes from `ripsGraph_mono` together with
    `SimpleGraph.edgeFinset_mono`. -/
theorem edgeCount_mono {α : Type*} [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
    {r s : ℝ} (h : r ≤ s) : edgeCount α r ≤ edgeCount α s :=
  Finset.card_le_card (SimpleGraph.edgeFinset_mono (ripsGraph_mono h))

/-- Order-theoretic packaging of `edgeCount_mono`: the Rips profile is monotone. -/
theorem ripsProfile_monotone (α : Type*) [Fintype α] [DecidableEq α] [PseudoMetricSpace α] :
    Monotone (ripsProfile α) :=
  fun _ _ h => edgeCount_mono h

/-! ## Functoriality under injective nonexpanding maps -/

variable {α β : Type*} [Fintype α] [DecidableEq α] [PseudoMetricSpace α]
  [Fintype β] [DecidableEq β] [PseudoMetricSpace β]
  {f : α → β} {r : ℝ}

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] in
/-- An injective, distance nonincreasing map sends Rips edges to Rips edges: if
    `f` is injective and nonexpanding, then adjacency in `ripsGraph α r` is carried to
    adjacency in `ripsGraph β r`. -/
theorem ripsGraph_adj_map (hf_inj : Function.Injective f)
    (hf_nonexp : ∀ x y, dist (f x) (f y) ≤ dist x y) {x y : α}
    (h : (ripsGraph α r).Adj x y) : (ripsGraph β r).Adj (f x) (f y) :=
  ⟨fun he => h.1 (hf_inj he), le_trans (hf_nonexp x y) h.2⟩

/-- For an injective nonexpanding map `f : α → β`, the source edge count is dominated by
    the target edge count.  The induced edge map `Sym2.map f` sends edges to edges
    (`ripsGraph_adj_map`) and is injective (`Sym2.map.injective hf_inj`), so the
    cardinality comparison follows from `Finset.card_le_card_of_injOn`. -/
theorem edgeCount_le_of_injective_nonexpanding (hf_inj : Function.Injective f)
    (hf_nonexp : ∀ x y, dist (f x) (f y) ≤ dist x y) :
    edgeCount α r ≤ edgeCount β r := by
  unfold edgeCount
  apply Finset.card_le_card_of_injOn (Sym2.map f)
  · intro e he
    simp only [Finset.mem_coe, SimpleGraph.mem_edgeFinset] at he ⊢
    induction e with
    | h x y =>
      rw [Sym2.map_pair_eq, SimpleGraph.mem_edgeSet] at *
      exact ripsGraph_adj_map hf_inj hf_nonexp he
  · exact (Sym2.map.injective hf_inj).injOn

end
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Fibonacci rank of apparition & Pisano period

This cycle proved that the Fibonacci **rank of apparition** `z(p) = fibEntry p` is a full
lattice homomorphism of `(ℕ, ∣)` (`fibEntry_lcm`, `fibEntry_dvd_of_dvd`, with the meet law
inherited from `fib_dvd_gcd_iff`), constructed the **Pisano period** `π(p) = fibPeriod p` from
the Fibonacci-shift dynamics on `ZMod p × ZMod p`, characterized its return-time ideal
(`fibPeriod_dvd_iff`), and proved the bridge `z(p) ∣ π(p)` (`fibEntry_dvd_fibPeriod`).
All results are in `Catalog/Novelty/FibEntryPisano.lean`, axiom-clean and sorry-free.

The conjectures below were each spot-checked computationally (moduli ≤ 60 unless noted) and are
stated so a follow-up cycle can drop them directly into Lean.

## C1 — The Pisano period is itself a lattice morphism

Mirror the `z`-theorems for `π`. Computationally verified for all `m, n ≤ 12`:
`π(lcm m n) = lcm (π m) (π n)` and `m ∣ n → π m ∣ π n`.

```lean
theorem fibPeriod_lcm (m n : ℕ) :
    fibPeriod (Nat.lcm m n) = Nat.lcm (fibPeriod m) (fibPeriod n) := by sorry
theorem fibPeriod_dvd_of_dvd {m n : ℕ} (h : m ∣ n) (hm : 1 ≤ m) :
    fibPeriod m ∣ fibPeriod n := by sorry
```
**Route:** lift `fibPeriod_dvd_iff` to a "period duality" `π p ∣ k ↔ (p ∣ F k ∧ p ∣ F (k+1) - 1)`
(read the two coordinates of `fibPair`), then transport `Nat.lcm_dvd_iff` across it exactly as
`fibEntry_lcm` does. The CRT step `ZMod (lcm m n) ≅ ZMod m × ZMod n` on coprime parts is the
only delicate ingredient.

## C2 — The period/entry cofactor is always in {1, 2, 4}

For every modulus `p ≥ 1`, `π(p) / z(p) ∈ {1, 2, 4}`, i.e. `π(p) ∣ 4 · z(p)`. Verified for all
primes `p < 60` (observed values: 1, 2, 4). This is the classical statement that the Fibonacci
sequence has multiplicative order 1, 2, or 4 of `(-1)` modulo `p` relative to its entry point.

```lean
theorem fibPeriod_dvd_four_mul_fibEntry {p : ℕ} (hp : 1 ≤ p) :
    fibPeriod p ∣ 4 * fibEntry p := by sorry
```
**Route:** `(F (z+1))^2 ≡ ±1` at the entry point forces the residual rotation in
`ZMod p × ZMod p` to be a 1st/2nd/4th root, so `π ∣ 4 z`.

## C3 — Wall's conjecture (entry point at prime powers)

For a prime `p` and `k ≥ 1`, `z(p^{k}) = p^{k-1} · z(p)` **unless** `p` is a Wall–Sun–Sun prime
(none are known). The clean unconditional sub-claim, equivalent to the nonexistence of
Wall–Sun–Sun primes, is `z(p^2) ≠ z(p)`:

```lean
theorem fibEntry_prime_sq_ne {p : ℕ} (hp : Nat.Prime p) :
    fibEntry (p ^ 2) ≠ fibEntry p := by sorry   -- famous OPEN problem
```
Combined with `fibEntry_squarefree` (already proved) and C1, a resolution would give a complete
multiplicative formula for `z` on all of `ℕ`.

## C4 — Carmichael primitive-divisor theorem, infinite tail

Close the single standing `sorry` in `Catalog/Shared/CarmichaelProof.lean`: every composite
`n > 12` makes the primitive part `primPart n > 1`, hence `F n` has a primitive prime divisor.
The finite range `n ≤ 10000` is already discharged by `native_decide`; the open p
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
