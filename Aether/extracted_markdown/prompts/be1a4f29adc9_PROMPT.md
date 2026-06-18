
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

**Title**: Close Proofs: This cycle closed the single open `sorry` in `Bridges/ArrowCurvature/D
**Domain**: Computation
**Mathematical framing**: Cycle c86fcece (Q=0.556) proved 112 theorems in Applications but left 1 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: # Future Directions — Arrow's Theorem as Curvature of Preference Space

This cycle closed the single open `sorry` in `Bridges/ArrowCurvature/Defs.lean`
(`arrow_curvature_conjecture`) and added `Bridge
Research domain: Computation
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/StrongDivisibilitySequences.lean
import Mathlib

/-! # Strong divisibility sequences: a unification of Fibonacci and Mersenne primitive-divisor theory

Domain: Bridges / Conceptual unification (number theory ↔ algebra).

A **strong divisibility sequence** is a sequence `a : ℕ → ℕ` with `a 0 = 0` and
`gcd (a m) (a n) = a (gcd m n)` for all `m n`.  This single axiom is the hidden
structure shared by

* the **Fibonacci** sequence `F` (`Nat.fib_gcd`),
* the **Mersenne / repunit** sequences `n ↦ b^n - 1` (`Nat.pow_sub_one_gcd_pow_sub_one`),
* and the trivial **identity** sequence `n ↦ n`.

The catalog already develops the *Fibonacci* entry-point and primitive-divisor theory
twice — `Catalog/Applications/FibonacciEntryPoints.lean` (`entryPoint`,
`dvd_fib_iff_entry_dvd`, `primitive_iff_entry_eq`) and
`Catalog/Applications/FibonacciPrimitiveDivisors.lean` (`IsPrimitive`,
`isPrimitive_unique`, `dvd_fib_iff_index_dvd_of_primitive`, `simultaneous_apparition`).
Here we show that **every one of those theorems holds for an arbitrary strong divisibility
sequence**, depending on nothing but the two structural axioms.  The Fibonacci results
become the `fibSDS` instance, and the *same theorems* immediately give the analogous
facts for `b^n - 1` (`mersenneSDS`) — a Zsygmondy-flavoured primitive-divisor theory for
Mersenne numbers, obtained for free.

Main results (all generic over `s : StrongDivSeq`):

* `StrongDivSeq.dvd_of_dvd`          — divisibility monotonicity `m ∣ n → s m ∣ s n`.
* `StrongDivSeq.dvd_gcd_iff`         — the meet law `d ∣ s (gcd m n) ↔ d ∣ s m ∧ d ∣ s n`.
* `StrongDivSeq.isPrimitive_unique`  — a value is primitive for at most one positive index.
* `StrongDivSeq.dvd_iff_index_dvd`   — a primitive divisor pins the divisibility set to multiples.
* `StrongDivSeq.simultaneous_apparition`        — the join law via `lcm`.
* `StrongDivSeq.simultaneous_apparition_finset` — the finite-family join law.
* `StrongDivSeq.entryPoint_isPrimitive`         — the entry point is itself a primitive index.
* `StrongDivSeq.dvd_iff_entryPoint_dvd`         — `p ∣ s n ↔ entryPoint p ∣ n`.
* `StrongDivSeq.primitive_iff_entryPoint_eq`    — primitivity ⇔ entry point equals the index.

Instances and cross-domain corollaries:

* `fibSDS`, `mersenneSDS`, `idSDS`.
* `mersenne_simultaneous_apparition` — the join law specialised to `b^n - 1` (new).
-/

/-
!-- Lab Notebook -- !--
!-- Hypothesis: The Fibonacci primitive-divisor theory in the catalog never uses anything
about Fibonacci numbers beyond `a 0 = 0` and the strong-divisibility identity
`gcd (a m) (a n) = a (gcd m n)`.  Therefore the entire theory should lift verbatim to an
abstract structure, unifying Fibonacci with the Mersenne sequences `b^n - 1`. -- !--
!-- Result: Confirmed.  Every catalog theorem (meet law, uniqueness, divisibility pinning,
join law, entry-point characterization) is reproved here generically and then instantiated.
The Mersenne join law `mersenne_simultaneous_apparition` is a genuinely new corollary. -- !--
!-- Insight: "Strong divisibility sequence" is the right Grothendieck-style object: it makes
the rank-of-apparition labelling a property of a single algebraic axiom, not of golden-ratio
arithmetic.  Fibonacci and Mersenne primitive-divisor theory are one theory. -- !--
!-- Failure analysis: the index-pinning lemma needs the `m = 0` boundary handled separately
(`s 0 = 0` is divisible by everything and `n ∣ 0` always holds); uniqueness needs both
indices positive (index `0` is vacuously primitive for every value). -- !--
!-- End Lab Notebook -- !--
-/

namespace StrongDivSeq

/-- A **strong divisibility sequence**: `a 0 = 0` and `gcd (a m) (a n) = a (gcd m n)`. -/
structure _root_.StrongDivSeq where
  /-- The underlying sequence. -/
  a : ℕ → ℕ
  /-- The sequence vanishes at `0`. -/
  map_zero : a 0 = 0
  /-- The strong divisibility identity. -/
  gcd_eq : ∀ m n, Nat.gcd (a m) (a n) = a (Nat.gcd m n)

variable (s : StrongDivSeq)

/-! ## §1. Structural consequences of the two axioms -/

/-
!-- `gcd m n = m` when `m ∣ n`, so `gcd (s m) (s n) = s m`, hence `s m ∣ s n`. -- !--
-/
theorem dvd_of_dvd {m n : ℕ} (h : m ∣ n) : s.a m ∣ s.a n := by
  have := s.gcd_eq m n;
  rw [ Nat.gcd_eq_left h ] at this;
  exact this ▸ Nat.gcd_dvd_right _ _

/-
!-- Rewrite `s (gcd m n)` to `gcd (s m) (s n)` by `gcd_eq`, then `Nat.dvd_gcd_iff`. -- !--
-/
theorem dvd_gcd_iff (d m n : ℕ) :
    d ∣ s.a (Nat.gcd m n) ↔ d ∣ s.a m ∧ d ∣ s.a n := by
  rw [ ← s.gcd_eq m n, Nat.dvd_gcd_iff ]

/-- `p` is a *primitive divisor* at index `n`: it divides `s n` but no earlier `s k`. -/
def IsPrimitive (p n : ℕ) : Prop :=
  p ∣ s.a n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ s.a k

/-! ## §2. Rigidity -/

/-
!-- At index `0` everything is primitive since `s 0 = 0`; the minimality clause is empty. -- !--
-/
theorem isPrimitive_zero (p : ℕ) : s.IsPrimitive p 0 := by
  exact ⟨ by rw [ s.map_zero ] ; norm_num, by intros; linarith ⟩

/-
!-- If `m < n`, primitivity at `n` forbids `p ∣ s m` while primitivity at `m` asserts it;
symmetrically for `n < m`.  Pure minimality clash, no structure needed. -- !--
-/
theorem isPrimitive_unique {p m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (hpm : s.IsPrimitive p m) (hpn : s.IsPrimitive p n) : m = n := by
  grind +locals

/-! ## §3. A primitive divisor pins down the divisibility set -/

/-
!-- (←) `n ∣ m → s n ∣ s m` (`dvd_of_dvd`) and `p ∣ s n`.  (→) `p ∣ s m, s n` give
`p ∣ s (gcd n m)` (`dvd_gcd_iff`); `gcd n m ≤ n` and minimality force `gcd n m = n`. -- !--
-/
theorem dvd_iff_index_dvd {p n : ℕ} (hn : 0 < n) (hp : s.IsPrimitive p n) (m : ℕ) :
    p ∣ s.a m ↔ n ∣ m := by
  constructor;
  · intro hm;
    have h_gcd : p ∣ s.a (Nat.gcd n m) := by
      exact s.dvd_gcd_iff p n m |>.2 ⟨ hp.1, hm ⟩;
    exact Classical.not_not.1 fun h => hp.2 ( Nat.gcd n m ) ( Nat.gcd_pos_of_pos_left _ hn ) ( lt_of_le_of_ne ( Nat.le_of_dvd hn ( Nat.gcd_dvd_left _ _ ) ) fun con => h <| con ▸ Nat.gcd_dvd_right _ _ ) h_gcd;
  · exact fun h => dvd_trans hp.1 ( s.dvd_of_dvd h )

/-! ## §4. The join law -/

/-
!-- Rewrite each conjunct by `dvd_iff_index_dvd` to `a ∣ n`, `b ∣ n`, then `Nat.lcm_dvd_iff`. -- !--
-/
theorem simultaneous_apparition {p q a b n : ℕ} (ha : 0 < a) (hb : 0 < b)
    (hp : s.IsPrimitive p a) (hq : s.IsPrimitive q b) :
    (p ∣ s.a n ∧ q ∣ s.a n) ↔ Nat.lcm a b ∣ n := by
  constructor <;> intro H;
  · exact Nat.lcm_dvd ( s.dvd_iff_index_dvd ha hp n |>.1 H.1 ) ( s.dvd_iff_index_dvd hb hq n |>.1 H.2 );
  · exact ⟨ dvd_trans ( s.dvd_iff_index_dvd ha hp a |>.2 ( dvd_refl a ) ) ( s.dvd_of_dvd ( dvd_trans ( Nat.dvd_lcm_left _ _ ) H ) ), dvd_trans ( s.dvd_iff_index_dvd hb hq b |>.2 ( dvd_refl b ) ) ( s.dvd_of_dvd ( dvd_trans ( Nat.dvd_lcm_right _ _ ) H ) ) ⟩

/-
!-- `Finset.induction`: empty case `Finset.lcm ∅ = 1`; insert step combines
`dvd_iff_index_dvd` with `Nat.lcm_dvd_iff`. -- !--
-/
theorem simultaneous_apparition_finset {ι : Type*} (t : Finset ι) (f g : ι → ℕ)
    (hpos : ∀ i ∈ t, 0 < g i) (hprim : ∀ i ∈ t, s.IsPrimitive (f i) (g i)) (n : ℕ) :
    (∀ i ∈ t, f i ∣ s.a n) ↔ (t.lcm g) ∣ n := by
  constructor <;> intro h;
  · refine' Finset.lcm_dvd fun i hi => _;
    exact s.dvd_iff_index_dvd ( hpos i hi ) ( hprim i hi ) n |>.1 ( h i hi );
  · intro i hi; exact dvd_trans ( hprim i hi |>.1 ) ( s.dvd_of_dvd ( by exact Nat.dvd_trans ( Finset.dvd_lcm hi ) h ) ) ;

/-! ## §5. Entry point (rank of apparition) -/

open Classical in
/-- The **entry point** of `p`: the least `k > 0` with `p ∣ s k`, or `0` if none exists. -/
noncomputable def entryPoint (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ s.a k then Nat.find h else 0

/-
!-- `Nat.find` of the existence witness is positive and satisfies `p ∣ s (entryPoint)`,
with the minimality clause from `Nat.find_min`; package as `IsPrimitive`. -- !--
-/
theorem entryPoint_isPrimitive {p : ℕ} (hex : ∃ k, 0 < k ∧ p ∣ s.a k) :
    s.IsPrimitive p (s.entryPoint p) := by
  unfold StrongDivSeq.IsPrimitive StrongDivSeq.entryPoint;
  grind +suggestions

/-
!-- (←) `entryPoint p ∣ n → 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Strong Divisibility Sequences as the Hidden Skeleton of Primitive-Divisor Theory

## Synthesis

This cycle isolated the *single structural axiom* that powers the catalog's entire Fibonacci
primitive-divisor theory and reused it to unify two historically separate worlds — the
**Fibonacci** numbers `F_n` and the **Mersenne / repunit** numbers `b^n − 1`. The new file
`Catalog/Bridges/StrongDivisibilitySequences.lean` defines a `StrongDivSeq` (a sequence with
`a 0 = 0` and `gcd (a m) (a n) = a (gcd m n)`) and proves the *whole* rank-of-apparition /
primitive-divisor calculus generically:

* divisibility monotonicity (`dvd_of_dvd`), the meet law (`dvd_gcd_iff`),
* rigidity of primitivity (`isPrimitive_unique`), divisibility pinning (`dvd_iff_index_dvd`),
* the join law and its finite-family generalization (`simultaneous_apparition[_finset]`),
* the entry-point characterization (`entryPoint_isPrimitive`, `dvd_iff_entryPoint_dvd`,
  `primitive_iff_entryPoint_eq`).

Fibonacci theory (the catalog's `FibonacciEntryPoints` and `FibonacciPrimitiveDivisors`) drops
out as the `fibSDS` instance, and the *same theorems* immediately produce a Zsygmondy-flavoured
join law for `b^n − 1` (`mersenne_simultaneous_apparition`) at no extra cost. The conceptual
payoff: the "rank of apparition" is not a fact about the golden ratio — it is a fact about one
gcd identity.

## Results Summary

* **12 new theorems, zero `sorry`** in `Catalog/Bridges/StrongDivisibilitySequences.lean`
  (10 generic results + 2 cross-domain corollaries), plus three instances `fibSDS`,
  `mersenneSDS`, `idSDS`.
* Removed a dangling broken import in `Catalog/Shared/CarmichaelProof.lean` so that file again
  elaborates, and corrected the package source root (`srcDir = "Catalog"`) in the root lakefile.
* The one genuinely open `sorry` in the catalog — `fib_carmichael_composite` for composite
  `n > 10000` — was attacked but **not** closed: it is the full analytic Carmichael/Zsygmondy
  statement and needs cyclotomic-value lower bounds absent from Mathlib. It is left honest and
  unaxiomatized, and is now the headline target below.

---

## Direction 1 — Close `fib_carmichael_composite` via a generic "cyclotomic lower bound"

State and prove, for `StrongDivSeq` of *Lucas type* (those arising from `(α^n − β^n)/(α − β)`
with `|α| > 1 ≥ |β|`, `αβ = ±1`), the inequality `Φ_n(a) > n` for all but finitely many `n`,
where `Φ_n = ∏_{d|n} a(d)^{μ(n/d)}` is the Möbius-defined primitive part. Combined with
`primitive_iff_entryPoint_eq`, this discharges the open tail `n > 10000` for Fibonacci.

The key insight is that the obstruction to a primitive divisor is *exactly one* intrinsic
prime, dividing `Φ_n` to the first power and bounded by `n`; so a single quantitative bound
`Φ_n > n` — not the full strength of Carmichael's proof — suffices, and that bound is a
property of the `StrongDivSeq`, not of Fibonacci specifically.

Why now? The generic `entryPoint`/`primitivePart` scaffolding built th
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
