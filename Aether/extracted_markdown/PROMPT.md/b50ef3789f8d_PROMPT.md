
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

**Title**: Thermodynamic Proof Erasure: Landauer's Principle for Mathematics
**Domain**: Applications
**Mathematical framing**: Landauer's principle states that erasing one bit of information dissipates at least kT*ln(2) of heat. Apply this to proof theory: erasing a proof of theorem T to recover a shorter proof is an information-theoretic process with a thermodynamic cost. Conjecture: The minimum energy required to compress a proof of n steps into a proof of m steps (m < n) is at least kT*(n-m)*ln(2), and this bound is tight for proofs in propositional logic. A proof of length n contains n bits of information (each step is a binary choice in the search tree). Compressing it to m steps requires erasing n-m bits, each costing kT*ln(2) by Landauer. This gives a physical lower bound on proof compression that is independent of the proof system. Test: formalize proof compression as an irreversible computation and derive the Landauer bound. Compute the erasure cost for compressing a 1000-step proof of the fundamental theorem of algebra into a 100-step proof. Impact: connects information thermodynamics to proof complexity, providing a physical lower bound on proof compression.
Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Computation/LandauerProofCompression.lean
import Mathlib

/-!
# Landauer's Principle for Proof Compression

Landauer's principle says erasing one bit of information dissipates at least
`k·T·ln 2` of heat. We apply it to **proof compression**.

A proof discovered by search is a path in a binary search tree: each of its `n`
steps is a binary decision, so the proof carries `n` bits of information. The set
of length-`n` proofs is modelled by the leaves `Fin (2^n)` of a complete binary
tree, and "knowing the proof" is the *uniform* distribution on these `2^n` leaves,
whose Shannon entropy is exactly `n · ln 2` (`entropy_uniformProb_pow_two`).

**Compressing** an `n`-step proof to (at most) `m`-step proofs is a function
`f : Fin (2^n) → Fin (2^m)`; it pushes the uniform distribution forward. Because
the image is supported on at most `2^m` configurations, its entropy is at most
`m · ln 2` (maximum-entropy / Gibbs bound `shannonEntropy_le_log_card`). Hence the
information *erased* is at least `(n − m) · ln 2`, and the dissipated heat is at
least `k·T·(n − m)·ln 2`. This is **independent of the proof system** — it is a
purely information-thermodynamic lower bound (`landauer_compression_lower_bound`).

The bound is **tight**: the residue map `i ↦ i mod 2^m` makes all fibers equal, so
its pushforward is again uniform and the erased information is *exactly* `(n−m)·ln 2`
(`landauer_compression_tight`).

This extends `Catalog.Computation.LandauerLowerBound` (the deterministic
data-processing inequality `H(f∗p) ≤ H(p)`) by pinning down the *extremal* numbers
for the proof-tree application and supplying the matching maximum-entropy upper
bound that the lower bound needs.

## Main results
* `shannonEntropy_uniformProb` — `H(uniform on N points) = log N`.
* `shannonEntropy_le_log_card` — **Gibbs / maximum entropy**: `H(p) ≤ log N`.
* `entropy_uniformProb_pow_two` — an `n`-bit proof tree has entropy `n · ln 2`.
* `landauer_compression_lower_bound` — compressing erases `≥ (n−m)·ln 2` bits, so
  dissipates `≥ k·T·(n−m)·ln 2` of heat.
* `landauer_compression_tight` — the residue map attains the bound exactly.
* `compression_cost_1000_to_100` — the worked example.

## References
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
- Bennett, C. H. (1973). Logical reversibility of computation.
- Cover, T. & Thomas, J. (2006). Elements of Information Theory.
-/

noncomputable section

open Finset Function Real BigOperators

namespace LandauerProofCompression

-- !-- Lab Notebook --!--
-- Hypothesis: A length-n proof is a path of n binary search decisions, hence carries
--   n bits = n·ln2 nats of Shannon information (uniform distribution on 2^n tree leaves).
--   Compressing to ≤ 2^m configurations must erase ≥ (n−m) bits, giving a proof-system
--   independent thermodynamic lower bound k·T·(n−m)·ln2 on the dissipated heat, tight
--   for the residue (mod 2^m) projection.
-- Result: Formalized the proof-tree distribution, proved its entropy is n·ln2, the Gibbs
--   maximum-entropy bound H(p) ≤ log N, the lower bound on erased information for ANY
--   compression map, and tightness for the residue map.
-- Insight: The lower bound needs NO data-processing inequality — only (i) the exact
--   entropy n·ln2 of the source and (ii) the one-sided Gibbs bound H(image) ≤ m·ln2.
--   Gibbs itself reduces to the single pointwise inequality log x ≤ x − 1 summed against
--   the distribution (relative entropy ≥ 0); no concavity machinery is required.
-- Failure analysis: Treating 0·log 0 needs care — zero-probability leaves contribute 0 to
--   entropy, so the Gibbs argument splits on p i = 0 vs p i > 0 to apply log_le_sub_one.
-- !-- end Lab Notebook --!--

/-- Shannon entropy (in nats) of a weight function. -/
def shannonEntropy {ι : Type*} [Fintype ι] (p : ι → ℝ) : ℝ :=
  -∑ i, p i * Real.log (p i)

/-- `p` is a probability distribution. -/
def IsProb {ι : Type*} [Fintype ι] (p : ι → ℝ) : Prop :=
  (∀ i, 0 ≤ p i) ∧ ∑ i, p i = 1

/-- The uniform distribution on a finite type. -/
def uniformProb (ι : Type*) [Fintype ι] : ι → ℝ :=
  fun _ => 1 / (Fintype.card ι : ℝ)

/-
!-- comment -- !--
The uniform distribution is a genuine probability distribution.
!-- comment -- !--
-/
theorem uniformProb_isProb (ι : Type*) [Fintype ι] (hcard : 0 < Fintype.card ι) :
    IsProb (uniformProb ι) := by
      refine' ⟨ fun _ => one_div_nonneg.2 ( Nat.cast_nonneg _ ), _ ⟩;
      unfold uniformProb; norm_num [ hcard.ne' ] ;

/-
!-- comment -- !--
H(uniform) = -∑ (1/N) log(1/N) = -log(1/N) = log N.
!-- comment -- !--

The Shannon entropy of the uniform distribution on `N` points is `log N`.
-/
theorem shannonEntropy_uniformProb (ι : Type*) [Fintype ι] (hcard : 0 < Fintype.card ι) :
    shannonEntropy (uniformProb ι) = Real.log (Fintype.card ι) := by
      unfold uniformProb shannonEntropy; norm_num [ hcard.ne' ] ;

/-
!-- comment -- !--
Gibbs: log N − H(p) = ∑ pᵢ log(N·pᵢ) = relative entropy to uniform ≥ 0, via log x ≤ x−1.
!-- comment -- !--

**Maximum entropy (Gibbs' inequality).** Any probability distribution on a
finite type with `N` points has Shannon entropy at most `log N`.
-/
theorem shannonEntropy_le_log_card {ι : Type*} [Fintype ι] (p : ι → ℝ)
    (hp : IsProb p) : shannonEntropy p ≤ Real.log (Fintype.card ι) := by
      by_cases h : Fintype.card ι = 0 <;> simp_all +decide [ IsProb ];
      · rw [ Fintype.card_eq_zero_iff ] at h ; aesop;
      · -- By the properties of logarithms and sums, we can show that $\sum_{i} p_i \log(N p_i) \geq 0$.
        have h_log_sum : ∑ i, p i * Real.log (Fintype.card ι * p i) ≥ 0 := by
          have h_gibbs : ∀ i, p i * Real.log (Fintype.card ι * p i) ≥ p i - 1 / Fintype.card ι := by
            intro i; by_cases hi : p i = 0 <;> simp_all +decide [ div_eq_mul_inv ] ;
            have := Real.log_le_sub_one_of_pos ( show 0 < ( Fintype.card ι : ℝ ) ⁻¹ / p i from div_pos ( inv_pos.mpr ( Nat.cast_pos.mpr ( Nat.pos_of_ne_zero h ) ) ) ( lt_of_le_of_ne ( hp.1 i ) ( Ne.symm hi ) ) );
            rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_inv ] at this;
            rw [ Real.log_mul ( by positivity ) ( by positivity ) ] ; nlinarith [ hp.1 i, mul_div_cancel₀ ( ( Fintype.card ι : ℝ ) ⁻¹ ) hi ] ;
          refine' le_trans _ ( Finset.sum_le_sum fun i _ => h_gibbs i ) ; simp +decide [ hp.2, h ];
        -- By the properties of logarithms, we can rewrite the sum as $\sum_{i} p_i (\log(N) + \log(p_i))$.
        have h_log_sum_rewrite : ∑ i, p i * Real.log (Fintype.card ι * p i) = ∑ i, p i * (Real.log (Fintype.card ι) + Real.log (p i)) := by
          exact Finset.sum_congr rfl fun i _ => by by_cases hi : p i = 0 <;> simp +decide [ *, Real.log_mul, Nat.cast_ne_zero ] ;
        simp_all +decide [ mul_add, Finset.sum_add_distrib, ← Finset.sum_mul _ _ _ ];
        unfold shannonEntropy; linarith;

/-
!-- comment -- !--
card (Fin (2^n)) = 2^n, and log (2^n) = n · log 2.
!-- comment -- !--

A complete binary search tree of depth `n` (its `2^n` leaves under the uniform
distribution) carries exactly `n · ln 2` nats of information.
-/
theorem entropy_uniformProb_pow_two (n : ℕ) :
    shannonEntropy (uniformProb (Fin (2^n))) = (n : ℝ) * Real.log 2 := by
      rw [ shannonEntropy_uniformProb ] <;> norm_num

/-! ### Pushforward of a distribution along a compression map -/

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]

/-- Pushforward (image measure) of `p` along `f`: the weight of `y` is the total
weight of its fiber. -/
def pushforward (f : α → β) (p : α → ℝ) : β → ℝ :=
  fun y => ∑ x ∈ univ.filter (fun x => f x = y), p x

omit [Fintype β] in
theorem pushforward_nonneg (f : α → β) (p : α → ℝ) (hp : ∀ x, 0 ≤ p x) (y : β) :
    0 ≤ pushforward f p y :=
  Finset.sum_nonneg fun i _ => hp i

theorem pushforward_total (f : α → β) (p : α → ℝ) :
    ∑ y : β, pushforward f p y = ∑ x : α, p x := by
      convert Finset.sum_fiberwise ( Finset.univ : Finset α ) f p

/-
The pushforward of a probability distribut
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Landauer's Principle for Proof Compression

## Synthesis

This cycle turned the slogan *"compressing a proof erases information, and erasing
information costs heat"* into theorems. The carrier of the argument is a single,
deliberately minimal model: a length-`n` proof found by search is a path of `n`
binary decisions, hence the *uniform distribution on the `2^n` leaves* of a complete
binary tree. Its Shannon entropy is exactly `n · ln 2` nats
(`entropy_uniformProb_pow_two`). A compression to at most `2^m` configurations is an
arbitrary map `f : Fin (2^n) → Fin (2^m)`, which pushes that distribution forward.

The decisive structural observation is that the lower bound needs **no**
data-processing inequality and **no** concavity machinery. It rests on exactly two
facts that pull in opposite directions:

* the source entropy is pinned *exactly* at `n · ln 2`; and
* the image lives on `≤ 2^m` points, so the one-sided **Gibbs / maximum-entropy**
  bound `shannonEntropy_le_log_card` caps its entropy at `m · ln 2`.

Subtracting gives an erased-information floor of `(n − m) · ln 2`, hence a dissipated
heat of at least `k·T·(n − m)·ln 2` (`landauer_compression_lower_bound`) — a bound
*independent of `f`*, and therefore independent of the proof system. The bound is not
slack: the residue map `i ↦ i mod 2^m` equalizes all fibers, pushes uniform to
uniform, and attains it exactly (`landauer_compression_tight`). The worked example
(`compression_cost_1000_to_100`) instantiates the floor as `900 · k·T·ln 2` for a
1000-step proof compressed to 100 steps.

The Gibbs lemma itself was factored to its irreducible core: `log x ≤ x − 1` summed
against the distribution is relative entropy `≥ 0`, with the only subtlety being the
`0·log 0` convention handled by a case split. This is the reusable building block.

## Results Summary

| Theorem | Statement |
|---|---|
| `shannonEntropy_uniformProb` | `H(uniform on N points) = log N` |
| `shannonEntropy_le_log_card` | Gibbs bound: any distribution on `N` points has `H ≤ log N` |
| `entropy_uniformProb_pow_two` | an `n`-bit proof tree has entropy `n · ln 2` |
| `landauer_compression_lower_bound` | any compression `2^n → 2^m` dissipates `≥ k·T·(n−m)·ln 2` |
| `landauer_compression_tight` | the residue map attains the bound exactly |
| `compression_cost_1000_to_100` | worked instance: `≥ 900·k·T·ln 2` |
| `residueMap_fiber_card` | each residue fiber has exactly `2^(n−m)` points |
| `residueMap_pushforward_uniform` | the residue map sends uniform to uniform |

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
`Quot.sound`. The development extends `Catalog.Computation.LandauerLowerBound` (the
deterministic data-processing inequality `H(f∗p) ≤ H(p)`) by supplying the matching
*upper* bound (Gibbs) and pinning the extremal constants for the proof-tree case.

## Research Directions

### 1. Strict-loss refinement: compression is *strictly* dissipative unless trivial
The current 
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
