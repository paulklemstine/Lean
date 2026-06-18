
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

**Title**: Close Proofs: This cycle delivered `FibCarmichaelStructure.lean`, a **self-contained
**Domain**: Novelty
**Mathematical framing**: Cycle 6fec53b5 (Q=0.775) proved 16 theorems in Novelty but left 2 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — Fibonacci Primitive Divisors, Fifth Cycle

## Synthesis

This cycle delivered `FibCarmichaelStructure.lean`, a **self-contained, `sorry`-free** root for the
Carmichael primitive-
Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/ApparitionOrderBridge.lean
import Mathlib

/-!
# The Apparition–Order Bridge: a local-to-global / stalk-level unifier

Domain: Number Theory ↔ Group Theory (Bridges) — Conceptual Unification cycle.

## What this file adds to the catalog

The catalog already develops the **entry-point (rank of apparition) calculus** for
*strong divisibility sequences* `a (gcd m n) = gcd (a m) (a n)`:

* `Catalog/Speculative/AutoResearch/StrongDivisibilityEntryPoint.lean`
  (`EntryPointCalculus.entryPoint`, `dvd_iff_entryPoint_dvd`,
  `primitive_iff_entryPoint_eq`), and
* `Catalog/Speculative/AutoResearch/StrongDivPrimitiveCriterion.lean`
  (`IsStrongDivSeq`, `primitive_of_coprimePart_pos`, `fib_carmichael_band`,
  `mersenne_bang_band`).

Those files stay *inside* the divisor lattice `(ℕ, ∣)`.  They never connect the entry
point to the **multiplicative group** that secretly governs it.  This file builds that
bridge for the Mersenne / Bang–Zsygmondy family `n ↦ bⁿ − 1`:

> **The entry point of a prime `p` is the multiplicative order of `b` in the residue
> field `ZMod p`.**  (`mersenne_entryPoint_eq_orderOf`)

This is the *stalk-level reduction* demanded by the local-to-global program: the global,
purely arithmetic object `entryPoint (bⁿ−1) p` (defined by a `Nat.find` over *all*
indices) collapses to a single *local* computation in the stalk `ZMod p`, namely
`orderOf (b : ZMod p)`.  Two immediate global consequences fall out:

* **Local-to-global gluing** (`support_eq_multiples`): for *any* strong divisibility
  sequence, the apparition support `{n > 0 | p ∣ a n}` equals the principal arithmetic
  progression `{n > 0 | entryPoint a p ∣ n}` — the support "sheaf" is principal,
  generated by the entry point.
* **Fermat descent** (`mersenne_entryPoint_dvd_sub_one`): the entry point divides
  `p − 1`, because the local order divides `|ZMod pˣ| = p − 1`.

The Fibonacci instance (`fib_support_eq_multiples`) is recovered for free via
`Nat.fib_gcd`, tying the bridge back to the catalog's Carmichael program.

## Main results (all `sorry`-free)

* `dvd_iff_entryPoint_dvd`           — `p ∣ a n ↔ entryPoint a p ∣ n` (strong divisibility).
* `support_eq_multiples`             — the apparition support is a principal progression.
* `pow_sub_one_dvd_iff_orderOf`      — `p ∣ bⁿ − 1 ↔ (b : ZMod p)ⁿ = 1` (the stalk reduction).
* `mersenne_entryPoint_eq_orderOf`   — **entry point = multiplicative order in `ZMod p`**.
* `mersenne_entryPoint_dvd_sub_one`  — entry point divides `p − 1` (Fermat).
* `fib_support_eq_multiples`         — Fibonacci specialization of the gluing theorem.
-/

namespace ApparitionOrderBridge

/-
!-- Lab Notebook -- !--
Hypothesis: The entry-point of a prime in the Mersenne sequence `bⁿ − 1` — an a-priori
  *global* invariant ranging over all indices — should be computable *locally* in the
  stalk `ZMod p`, as the multiplicative order of `b`.  If so, the global apparition
  pattern is forced by a single group-theoretic datum.
Result: Confirmed (`mersenne_entryPoint_eq_orderOf`): `entryPoint (bⁿ−1) p =
  orderOf (b : ZMod p)` whenever `p ∤ b`.  As corollaries, the apparition support is a
  principal arithmetic progression (`support_eq_multiples`) and the entry point divides
  `p − 1` (`mersenne_entryPoint_dvd_sub_one`).
Insight: Strong divisibility makes `n ↦ {p | p ∣ a n}` a "support sheaf" over the index
  semigroup `(ℕ, +)`; its global sections are governed by the stalk order at `p`.  For
  `bⁿ − 1` the stalk is the cyclic group `⟨b⟩ ≤ (ZMod p)ˣ`, and the local-to-global
  obstruction vanishes: the order alone reconstructs the entire global divisibility set.
Failure analysis: the bridge needs `1 ≤ b` (else `Nat` truncation `bⁿ − 1 = 0` for `b=0`
  breaks the ZMod equivalence); this is automatic from `p ∤ b`.  Existence of *some*
  apparition index is supplied by Fermat (`ZMod.pow_card_sub_one_eq_one`), which also
  pins down positivity of the order.
-/

/-- A `ℕ`-indexed `ℕ`-valued sequence is a **strong divisibility sequence** when the value
at a gcd of indices is the gcd of the values: `a (gcd m n) = gcd (a m) (a n)`. -/
def StrongDiv (a : ℕ → ℕ) : Prop := ∀ m n, a (Nat.gcd m n) = Nat.gcd (a m) (a n)

variable {a : ℕ → ℕ}

-- !-- `m ∣ n ⇒ gcd m n = m`, so strong divisibility reads `a m = gcd (a m) (a n) ∣ a n`. -- !--
theorem StrongDiv.dvd_of_index_dvd (h : StrongDiv a) {m n : ℕ} (hmn : m ∣ n) :
    a m ∣ a n := by
  have hg : Nat.gcd m n = m := Nat.gcd_eq_left hmn
  have hmn' := h m n
  rw [hg] at hmn'
  rw [hmn']
  exact Nat.gcd_dvd_right _ _

-- !-- `a (gcd m n) = gcd (a m) (a n)`, and a common divisor divides the gcd. -- !--
theorem StrongDiv.dvd_gcd (h : StrongDiv a) {p m n : ℕ} (hm : p ∣ a m) (hn : p ∣ a n) :
    p ∣ a (Nat.gcd m n) := by
  rw [h m n]; exact Nat.dvd_gcd hm hn

open Classical in
/-- The **entry point** (rank of apparition) of `p` in `a`: the least `k > 0` with
`p ∣ a k`, or `0` if no such `k` exists. -/
noncomputable def entryPoint (a : ℕ → ℕ) (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ a k then Nat.find h else 0

-- !-- Positivity, witness, minimality read directly off `Nat.find`. -- !--
theorem entryPoint_pos (p : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    0 < entryPoint a p := by
  unfold entryPoint; rw [dif_pos hex]; exact (Nat.find_spec hex).1

theorem dvd_a_entryPoint (p : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    p ∣ a (entryPoint a p) := by
  unfold entryPoint; rw [dif_pos hex]; exact (Nat.find_spec hex).2

theorem entryPoint_min (p m : ℕ) (hm : 0 < m) (hlt : m < entryPoint a p) :
    ¬ p ∣ a m := by
  intro hdvd
  unfold entryPoint at hlt
  by_cases hex : ∃ k, 0 < k ∧ p ∣ a k
  · rw [dif_pos hex] at hlt
    exact Nat.find_min hex hlt ⟨hm, hdvd⟩
  · rw [dif_neg hex] at hlt; exact absurd hlt (by omega)

-- !-- (←) `entryPoint ∣ n ⇒ a (entryPoint) ∣ a n` by `dvd_of_index_dvd`.
-- (→) contrapositive: if `entryPoint ∤ n` then `gcd (entryPoint) n` is a smaller positive
-- index killing `p ∣ a`, via `dvd_gcd`, contradicting minimality. -- !--
theorem dvd_iff_entryPoint_dvd (h : StrongDiv a) (p n : ℕ)
    (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    p ∣ a n ↔ entryPoint a p ∣ n := by
  set e := entryPoint a p with he
  have he_pos : 0 < e := entryPoint_pos p hex
  have he_div : p ∣ a e := dvd_a_entryPoint p hex
  constructor
  · intro hn
    by_contra hcon
    have h_gcd_lt_e : Nat.gcd e n < e :=
      lt_of_le_of_ne (Nat.le_of_dvd he_pos (Nat.gcd_dvd_left _ _))
        (fun hh => hcon (hh ▸ Nat.gcd_dvd_right _ _))
    exact entryPoint_min p (Nat.gcd e n) (Nat.gcd_pos_of_pos_left _ he_pos) h_gcd_lt_e
      (h.dvd_gcd he_div hn)
  · intro hdvd
    exact dvd_trans he_div (h.dvd_of_index_dvd hdvd)

/-! ## Local-to-global gluing: the apparition support is principal -/

-- !-- Pointwise rewrite by `dvd_iff_entryPoint_dvd`. -- !--
/-- **Local-to-global gluing.** For a strong divisibility sequence, the apparition support
`{n > 0 | p ∣ a n}` is exactly the principal arithmetic progression generated by the entry
point: `{n > 0 | entryPoint a p ∣ n}`. -/
theorem support_eq_multiples (h : StrongDiv a) (p : ℕ) (hex : ∃ k, 0 < k ∧ p ∣ a k) :
    {n | 0 < n ∧ p ∣ a n} = {n | 0 < n ∧ entryPoint a p ∣ n} := by
  ext n
  simp only [Set.mem_setOf_eq]
  constructor
  · rintro ⟨hn, hd⟩; exact ⟨hn, (dvd_iff_entryPoint_dvd h p n hex).1 hd⟩
  · rintro ⟨hn, hd⟩; exact ⟨hn, (dvd_iff_entryPoint_dvd h p n hex).2 hd⟩

/-! ## The stalk reduction: Mersenne apparition lives in `ZMod p` -/

-- !-- `1 ≤ bⁿ`, so `Nat.modEq_iff_dvd'` turns `p ∣ bⁿ − 1` into `1 ≡ bⁿ [MOD p]`;
-- `ZMod.natCast_eq_natCast_iff` and `push_cast` move it to `(b : ZMod p)ⁿ = 1`. -- !--
/-- **Stalk reduction.** For `1 ≤ b`, divisibility of `bⁿ − 1` by `p` is detected entirely
in the stalk `ZMod p`: `p ∣ bⁿ − 1 ↔ (b : ZMod p)ⁿ = 1`. -/
theorem pow_sub_one_dvd_iff_orderOf (b p n : ℕ) [Fact p.Prime] (hb : 1 ≤ b) :
    p ∣ b ^ n - 1 ↔ (b : ZMod p) ^ n = 1 := by
  have h1 : 1 ≤ b ^ n := Nat.one_le_pow _ _ hb
  rw [← Nat.modEq_iff_dvd' h1, Nat.ModEq.comm, ← ZMod.natCast_eq_natCast_iff]
  push_cast
 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Apparition–Order Bridge (Local-to-Global / Sheaves cycle)

## Synthesis

This cycle delivered `Catalog/Bridges/ApparitionOrderBridge.lean`, a self-contained,
`sorry`-free file that **reduces a global arithmetic invariant to a single stalk-level
group computation**. Concretely, for the Mersenne / Bang–Zsygmondy family
`a(n) = bⁿ − 1`, the *entry point* (rank of apparition) of a prime `p` — defined globally
as `Nat.find` over **all** indices `k` with `p ∣ a(k)` — is proven equal to the
*multiplicative order of `b` in the residue field* `ZMod p`:

> `mersenne_entryPoint_eq_orderOf : entryPoint (bⁿ−1) p = orderOf (b : ZMod p)`  (for `p ∤ b`).

This is the local-to-global program in miniature: the apparition data forms a "support
sheaf" `n ↦ {p : p ∣ a(n)}` over the index semigroup `(ℕ, +)`, and the bridge shows the
sheaf's global sections are completely determined by the *stalk order* at each prime. Two
global theorems fall out for free — `support_eq_multiples` (the support is the principal
arithmetic progression generated by the entry point) and `mersenne_entryPoint_dvd_sub_one`
(Fermat descent: the entry point divides `p − 1`). The Fibonacci specialization
`fib_support_eq_multiples` ties the result back to the catalog's Carmichael
primitive-divisor program (`StrongDivisibilityEntryPoint.lean`,
`StrongDivPrimitiveCriterion.lean`, `CarmichaelProof.lean`).

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `dvd_iff_entryPoint_dvd` | `p ∣ a n ↔ entryPoint a p ∣ n` for strong divisibility sequences | proved |
| `support_eq_multiples` | apparition support = principal progression generated by entry point | proved |
| `pow_sub_one_dvd_iff_orderOf` | `p ∣ bⁿ − 1 ↔ (b : ZMod p)ⁿ = 1` (stalk reduction) | proved |
| `mersenne_entryPoint_eq_orderOf` | **entry point = `orderOf (b : ZMod p)`** | proved |
| `mersenne_entryPoint_dvd_sub_one` | entry point divides `p − 1` (Fermat descent) | proved |
| `fib_support_eq_multiples` | Fibonacci specialization of the gluing theorem | proved |

All results are `sorry`-free and depend only on `Mathlib` (axioms: `propext`,
`Classical.choice`, `Quot.sound`).

---

## Direction 1 — The Fibonacci stalk: entry point = order of the companion matrix mod p

**Conjecture.** For a prime `p` with `p ∤ 5`, `entryPoint Nat.fib p` equals the
multiplicative order of the Fibonacci companion matrix `Q = !![1,1;1,0]` in
`GL₂(ZMod p)` (equivalently, the order of the golden-ratio image in `(ZMod p)[x]/(x²−x−1)`).

The key insight is that the Apparition–Order Bridge proved here for `bⁿ − 1` is the
*rank-1* shadow of a *rank-2* phenomenon: Fibonacci is the (1,2)-entry of `Qⁿ`, so
`p ∣ Fₙ ↔ Qⁿ ≡ (scalar) (mod p)`, turning the global Fibonacci entry point into the order
of a single matrix in a finite group — the stalk at `p` is now `GL₂(ZMod p)` rather than
`(ZMod p)ˣ`. Why now? The present file already supplies every abstract lemma
(`dvd_iff_entryPoint_dvd`, `support_eq_multiples`) over arbitrary stron
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
