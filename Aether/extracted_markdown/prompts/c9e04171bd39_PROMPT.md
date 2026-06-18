
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

**Title**: Close Proofs: Order-theoretic core of the Cook–Reckhow program built i
**Domain**: Novelty
**Mathematical framing**: Cycle c0138e6f (Q=0.426) proved 205 theorems in Applications but left 5 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions: The Poset of p-Degrees — Lattice Shape and Parametric Separation

## Synthesis

This cycle extended the order-theoretic core of the Cook–Reckhow program built in
`Catalog/Logic/Pr
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Logic/ProofComplexity/DegreeLattice.lean
import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder
import Catalog.Logic.ProofComplexity.SimulationDegrees

/-! # Lattice shape and parametric separation of the poset of p-degrees

This file extends the order-theoretic core of the Cook–Reckhow program developed in
`Catalog.Logic.ProofComplexity.SimulationPreorder` (the simulation preorder `Simulates`,
its `Preorder` instance `simulationPreorder`, `PolyBounded`/`PolyMono`, the Fibonacci
super-polynomiality `not_polyBounded_fib`) and
`Catalog.Logic.ProofComplexity.SimulationDegrees` (the generic separation template
`no_simulation_of_hard`, and the concrete `linSystem` / `fibSystem`).

We answer two structural questions about the **poset of p-degrees**
(`Antisymmetrization (ProofSystem Thm) (· ≤ ·)`):

* **Lattice shape.**  Binary *meets* always exist: the direct-sum proof system
  `sumSystem P Q` (proofs are `P.Proof ⊕ Q.Proof`) is the greatest lower bound of
  `{P, Q}` in the simulation preorder (`isGLB_sumSystem`).  Hence the simulation preorder
  is down-directed (`simulation_directed`) and the p-degrees form a meet-semilattice.

* **Parametric separation / infinite height.**  Beyond the single Fibonacci separation
  `lin_lt_fib`, the size functions `n ↦ 2 ^ (n ^ k)` give an **infinite strictly increasing
  chain** of p-degrees (`powSystem_strictMono`): each polynomial step in the exponent is a
  super-polynomial jump in size, so the poset of p-degrees has infinite height.

-- !-- Lab Notebook -- !--
Hypothesis : (1) The simulation preorder should have binary meets, realised concretely by
             a "run both systems" direct sum.  (2) Beyond one Fibonacci separation the
             degree poset should have infinite height, witnessed by a growth ladder whose
             consecutive rungs are separated by a super-polynomial gap.
Result     : Both confirmed, `sorry = 0`.  `isGLB_sumSystem` exhibits the meet; the
             characterisation `simulates_sysOfSize_iff` reduces simulation between
             `ℕ`-indexed size systems to pointwise polynomial domination, turning the
             chain into the elementary growth fact `pow_pow_succ_gap`.
Insight    : The right invariant is *polynomial domination of size functions*: `sys a`
             p-simulates `sys b` iff `a ≤ poly ∘ b`.  Lattice meets correspond to the
             pointwise `min`-in-strength (= `max` of blow-ups), and height corresponds to
             chains of growth rates that are not polynomially comparable.  The ladder
             `2 ^ (n ^ k)` works precisely because `n ^ (k+1) = n · n ^ k` outruns
             `c · n ^ k + c` for `n > c`, whereas a plain exponential `2 ^ (k·n)` would
             collapse (all such rungs are polynomially comparable).
Failure analysis : A first ladder attempt used `2 ^ (k * n)`; it collapses because
             `2 ^ ((k+1) n) ≤ (2 ^ (k n)) ^ 2`, i.e. consecutive rungs are p-equivalent.
             Moving the parameter into the *exponent of the exponent* (`n ^ k`) creates a
             genuinely non-polynomial gap.  The `k = 0` rung (constant size) needs a
             separate argument, so the published chain starts at `k = 1`.
-- !-- Lab Notebook -- !--
-/

set_option maxHeartbeats 1000000

namespace ProofComplexity

universe u v

variable {Thm : Type u}

/-! ## The direct-sum proof system and binary meets -/

-- !-- comment: `sumSystem P Q` runs whichever of `P`, `Q` you like: proofs are the disjoint
--             union, and `proves`/`size` are read off componentwise. -- !--
/-- The **direct sum** of two proof systems for the same theorem type: a proof is either a
`P`-proof or a `Q`-proof, certifying the same theorem with the same size. -/
def sumSystem (P Q : ProofSystem.{u, v} Thm) : ProofSystem.{u, v} Thm where
  Proof := P.Proof ⊕ Q.Proof
  proves := Sum.elim P.proves Q.proves
  size := Sum.elim P.size Q.size
  complete := by
    intro t
    obtain ⟨p, hp⟩ := P.complete t
    exact ⟨Sum.inl p, hp⟩

-- !-- comment: `max` of two blow-ups is again a monotone polynomial blow-up — the
--             algebra behind closing the meet under the universal property. -- !--
/-- The pointwise maximum of two monotone polynomially-bounded blow-ups is again one. -/
lemma polyMono_max {f g : ℕ → ℕ} (hf : PolyMono f) (hg : PolyMono g) :
    PolyMono (fun n => max (f n) (g n)) := by
      refine' ⟨ fun n m hnm => _, _ ⟩;
      · exact max_le_max ( hf.1 hnm ) ( hg.1 hnm );
      · obtain ⟨ k₁, hk₁ ⟩ := hf.2
        obtain ⟨ k₂, hk₂ ⟩ := hg.2
        use k₁ + k₂ + 1
        intro n
        have h1 : f n + 1 ≤ (n + 2) ^ k₁ := hk₁ n
        have h2 : g n + 1 ≤ (n + 2) ^ k₂ := hk₂ n
        have h3 : (n + 2) ^ k₁ ≤ (n + 2) ^ (k₁ + k₂ + 1) := by
          exact pow_le_pow_right₀ ( by linarith ) ( by linarith )
        have h4 : (n + 2) ^ k₂ ≤ (n + 2) ^ (k₁ + k₂ + 1) := by
          exact pow_le_pow_right₀ ( by linarith ) ( by linarith )
        have h5 : max (f n) (g n) + 1 ≤ (n + 2) ^ (k₁ + k₂ + 1) := by
          grind
        exact h5

/-- The direct sum p-simulates its left summand (identity blow-up via `Sum.inl`). -/
lemma simulates_sumSystem_left (P Q : ProofSystem.{u, v} Thm) :
    Simulates (sumSystem P Q) P := by
      refine' ⟨ fun n => n, polyMono_id, fun q => ⟨ Sum.inl q, rfl, _ ⟩ ⟩;
      rfl

/-- The direct sum p-simulates its right summand (identity blow-up via `Sum.inr`). -/
lemma simulates_sumSystem_right (P Q : ProofSystem.{u, v} Thm) :
    Simulates (sumSystem P Q) Q := by
      refine' ⟨ fun n => n, polyMono_id, fun q => ⟨ Sum.inr q, rfl, _ ⟩ ⟩;
      rfl

/-- Universal property of the meet: any `R` that simulates both `P` and `Q` simulates the
direct sum (using the `max` of the two blow-ups). -/
lemma simulates_sumSystem_of_simulates_both {R P Q : ProofSystem.{u, v} Thm}
    (hP : Simulates R P) (hQ : Simulates R Q) : Simulates R (sumSystem P Q) := by
      obtain ⟨ f₁, hf₁, hf₁' ⟩ := hP
      obtain ⟨ f₂, hf₂, hf₂' ⟩ := hQ;
      refine' ⟨ fun n => Max.max ( f₁ n ) ( f₂ n ), _, _ ⟩;
      · exact polyMono_max hf₁ hf₂;
      · rintro ( q | q ) <;> [ exact hf₁' q |> fun ⟨ p, hp₁, hp₂ ⟩ => ⟨ p, hp₁, le_max_of_le_left hp₂ ⟩ ; exact hf₂' q |> fun ⟨ p, hp₁, hp₂ ⟩ => ⟨ p, hp₁, le_max_of_le_right hp₂ ⟩ ]

-- !-- comment: Packaging the three facts: `sumSystem P Q` is the GLB of `{P,Q}` in the
--             simulation preorder, so binary meets exist. -- !--
/-- **Lattice shape (meets exist).**  In the simulation preorder, `sumSystem P Q` is the
greatest lower bound of `{P, Q}`.  Equivalently, the poset of p-degrees has binary meets. -/
theorem isGLB_sumSystem (P Q : ProofSystem.{u, v} Thm) :
    IsGLB ({P, Q} : Set (ProofSystem.{u, v} Thm)) (sumSystem P Q) := by
      refine' ⟨ _, fun R hR => _ ⟩;
      · rintro R ( rfl | rfl ) <;> [ exact simulates_sumSystem_left P Q; exact simulates_sumSystem_right P Q ];
        · exact simulates_sumSystem_left R Q;
        · exact simulates_sumSystem_right P R;
      · exact simulates_sumSystem_of_simulates_both ( hR ( Set.mem_insert _ _ ) ) ( hR ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) ) )

/-- **The simulation preorder is down-directed.**  Any two proof systems have a common
lower bound, namely their direct sum. -/
theorem simulation_directed (P Q : ProofSystem.{u, v} Thm) :
    ∃ R, Simulates R P ∧ Simulates R Q :=
  ⟨sumSystem P Q, simulates_sumSystem_left P Q, simulates_sumSystem_right P Q⟩

/-! ## Size-indexed systems over `ℕ` and the domination characterisation -/

-- !-- comment: A proof system over `ℕ` whose proof of `n` is `n` itself, with prescribed
--             size `a n`; `linSystem`/`fibSystem` are the cases `a = id`, `a = fib`. -- !--
/-- The proof system over `ℕ` with `proves = id` and prescribed size function `a`. -/
def sysOfSize (a : ℕ → ℕ) : ProofSystem.{0, 0} ℕ where
  Proof := ℕ
  proves := id
  size := a
  complete := Function.surjective_id

-- !-- comment: For size-indexed systems, simulation is *exactly* polynomial domination of
--       
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Lattice Shape and Parametric Separation of the Poset of p-Degrees

## Synthesis

This cycle pushed the order-theoretic core of the Cook–Reckhow program
(`Catalog/Logic/ProofComplexity/SimulationPreorder.lean` and `SimulationDegrees.lean`) from
"there is a preorder with one separating pair" to genuine **structural geometry** of the
poset of p-degrees `Antisymmetrization (ProofSystem Thm) (· ≤ ·)`. The new file
`Catalog/Logic/ProofComplexity/DegreeLattice.lean` contributes three structural facts, all
`sorry`-free and depending only on `propext, Classical.choice, Quot.sound`:

1. **Binary meets exist** (`isGLB_sumSystem`, `simulation_directed`). The direct-sum system
   `sumSystem P Q` — "keep whichever proof you like" — is the greatest lower bound of
   `{P, Q}`. The universal property is closed by taking the pointwise `max` of the two
   blow-ups (`polyMono_max`). So the p-degrees form a **meet-semilattice** and the preorder
   is down-directed.

2. **A reusable separation engine** (`simulates_sysOfSize_iff`). For `ℕ`-indexed size
   systems, `sysOfSize a` p-simulates `sysOfSize b` **iff** `a` is pointwise dominated by a
   monotone polynomial blow-up of `b`. Every separation question becomes one of *polynomial
   domination of growth rates*. This subsumes the catalog's `linSystem`/`fibSystem`
   separation (`lin_lt_fib`) and powers the chain below.

3. **Infinite height** (`powSystem_strictMono`, `powSystem_pdegrees_injective`). The growth
   ladder `n ↦ 2 ^ (n ^ k)` is a strictly increasing chain: each step is a super-polynomial
   jump (`pow_pow_succ_gap`), and the rungs descend to genuinely distinct p-degrees. So the
   poset of p-degrees contains an infinite strictly increasing chain.

The unifying lesson: the right invariant is **polynomial comparability of size functions**.
Meets are the `max`-of-blow-ups; height is a chain of growth rates that are pairwise *not*
polynomially comparable; the ladder works precisely because the exponent-of-the-exponent
`n^(k+1) = n · n^k` outruns `c · n^k + c`, whereas a plain exponential `2^(k·n)` collapses
(all such rungs are polynomially comparable, hence p-equivalent).

## Results Summary

| Result | Statement | Status |
|---|---|---|
| `isGLB_sumSystem` | `sumSystem P Q` is the GLB of `{P,Q}` | proved |
| `simulation_directed` | every two systems have a common lower bound | proved |
| `simulates_sysOfSize_iff` | simulation = polynomial domination of size functions | proved |
| `lin_lt_fib` | `linSystem < fibSystem` (strict 2-chain) | proved |
| `pow_pow_succ_gap` | `(2^(n^k)+2)^c < 2^(n^(k+1))` for some `n` (`k ≥ 1`) | proved |
| `powSystem_strictMono` | `j ↦ powSystem (j+1)` is a strict chain | proved |
| `powSystem_pdegrees_injective` | the chain gives distinct p-degrees | proved |

## Research Directions

### 1. The poset of p-degrees is a meet-semilattice but *not* a lattice

We proved that binary **meets** always exist. The dual conjecture is that binary **joins**
(least upper b
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
