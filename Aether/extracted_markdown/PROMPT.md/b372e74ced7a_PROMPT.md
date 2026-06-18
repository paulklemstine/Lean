
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

**Title**: Close Proofs: Impossible Geometries: Where Parallel Lines Converge AND Diverge
**Domain**: Pythagorean
**Mathematical framing**: Cycle 40370763 (Q=0.470) proved 805 theorems in Computation but left 3 `sorry` placeholders. Fill them with complete proofs. Focus on the most important theorems first. Original: Euclid's parallel postulate says parallel lines never meet. Hyperbolic geometry says they can diverge. Elliptic geometry says they converge. But what about a geometry where parallel lines BOTH converg
Research domain: Pythagorean
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Algebra/MarkovBases/Geodesic.lean
import Mathlib
import Algebra.MarkovBases.NoThreeWay

/-!
# Algebraic Statistics: Geodesics in the Markov Graph of the No-Three-Way Model

Building directly on `Algebra.MarkovBases.NoThreeWay`, this file upgrades the *qualitative*
Fundamental Theorem of Markov Bases (`noThreeWay_fiber_connected` — "the single move `M3`
connects every fiber") to a *quantitative* one: it computes the **exact graph distance**
between two tables in the Markov graph of the `2 × 2 × 2` no-three-way interaction model.

The Markov graph of a fiber has the non-negative tables as vertices and a `± M3` move as an
edge.  We define a length-counted walk `Walk u v n` (a path of `n` legal `± M3` steps) and
prove:

* every `± M3` step changes the corner cell `u 0 0 0` by exactly one
  (`step_corner_natAbs_le`);
* hence any walk of length `n` satisfies `|v₀₀₀ − u₀₀₀| ≤ n` — a **geodesic lower bound**
  (`walk_corner_bound`);
* conversely there is a walk of length exactly `|t|` realising `u ⇝ u + t • M3`
  (`walk_add_smul`), staying non-negative throughout (discrete convexity);
* therefore the graph distance between any two equal-margin non-negative tables is **exactly**
  `|v₀₀₀ − u₀₀₀|` (`noThreeWay_geodesic`): the natural corner coordinate is an isometry from
  the fiber onto an integer interval.

## Catalog synthesis

This extends `Algebra.MarkovBases.NoThreeWay` (rank-one move lattice + connectivity) and is
the `2×2×2` analogue of the interval picture in `Algebra.MarkovBases.TwoWay`
(`twoWay_fiber_card_interval`).  Where those files show *that* one move suffices, this file
quantifies the *cost*: the Markov graph of every fiber is a path graph, and the corner cell
is a graph isometry onto `ℤ`.  The lower bound is a potential-function argument (a discrete
1-Lipschitz invariant), a reusable bridge between lattice walks (catalog: combinatorial step
relations) and metric geometry on graphs.
-/

namespace MarkovBases.NoThreeWay

/-- A length-counted walk in the Markov graph: a path of `n` legal `± M3` steps from `u`
to `v`, every intermediate table non-negative (the `Step` relation enforces this). -/
inductive Walk : Table3 → Table3 → ℕ → Prop
  | refl (u : Table3) : Walk u u 0
  | cons {u v w : Table3} {n : ℕ} : Step u v → Walk v w n → Walk u w (n + 1)

-- !-- step_corner_natAbs_le: a ±M3 move changes the corner cell by exactly M3 0 0 0 = ±1,
-- so a single Markov step moves the corner coordinate by one. -- !--
/-- A single legal `± M3` step changes the corner cell `u 0 0 0` by exactly one:
`M3 0 0 0 = 1`, so `v 0 0 0 - u 0 0 0 = ±1`. -/
theorem step_corner_natAbs_le {u v : Table3} (h : Step u v) :
    (v 0 0 0 - u 0 0 0).natAbs ≤ 1 := by
  rcases h with ⟨hu, hv, huv⟩
  rcases huv with (rfl | rfl) <;> norm_num [M3]

-- !-- walk_corner_bound: induct on the walk; the corner coordinate is 1-Lipschitz along edges,
-- so its total change is at most the number of steps — the geodesic lower bound. -- !--
/-- **Geodesic lower bound.** Any walk of `n` legal `± M3` steps from `u` to `v` satisfies
`|v 0 0 0 - u 0 0 0| ≤ n`: the corner cell is a `1`-Lipschitz potential, so no path can be
shorter than the corner displacement. -/
theorem walk_corner_bound {u v : Table3} {n : ℕ} (h : Walk u v n) :
    (v 0 0 0 - u 0 0 0).natAbs ≤ n := by
  induction h with
  | refl u => norm_num
  | cons s _ ih =>
      have := step_corner_natAbs_le s
      omega

-- !-- walk_add_smul: induct on |t|; one unit step (±M3) toward the target stays non-negative
-- by discrete convexity, giving a walk of length exactly |t|. -- !--
/-- **Existence of a length-`|t|` geodesic.** If both `u` and `u + t • M3` are non-negative
then there is a walk of length exactly `t.natAbs` between them, staying non-negative at every
step.  (Refines `connected_add_smul`, which forgets the length.) -/
theorem walk_add_smul (t : ℤ) (u : Table3)
    (hu : Nonneg u) (hv : Nonneg (u + t • M3)) :
    Walk u (u + t • M3) t.natAbs := by
  induction' n : t.natAbs with n ih generalizing u t
  · rw [Int.natAbs_eq_zero.mp n]; simp +decide [Walk.refl]
  · rcases Int.natAbs_eq_iff.mp n with (rfl | rfl)
    · -- positive case: first add M3, then recurse with exponent n
      have h_ind : Walk (u + M3) (u + (↑(Nat.succ ‹_›) : ℤ) • M3) ‹_› := by
        convert ih (↑‹ℕ› : ℤ) (u + M3) _ _ _ using 1 <;> norm_num [add_smul_M3_apply]
        · ext i j k; simp; ring
        · intro i j k; specialize hv i j k; specialize hu i j k
          simp_all +decide
          cases M3_apply_eq i j k <;> nlinarith
        · convert hv using 1; ext i j k; simp +decide; ring
      refine Walk.cons ?_ h_ind
      constructor <;> norm_num [hu, hv]
      intro i j k; specialize hv i j k; simp_all +decide [M3]
      split_ifs at * <;> linarith [hu i j k]
    · -- negative case: first subtract M3, then recurse with exponent n
      refine Walk.cons (v := u - M3) ?_ ?_
      · constructor <;> norm_num [Step]
        · assumption
        · intro i j k; have := hu i j k; have := hv i j k
          simp_all +decide [M3]
          split_ifs at * <;> linarith
      · convert ih (-↑‹ℕ›) (u - M3) _ _ _ using 1 <;> norm_num [sub_eq_add_neg]
        · ext i j k; norm_num; ring
        · intro i j k; have := hu i j k; have := hv i j k
          simp_all +decide [M3]
          split_ifs at * <;> linarith
        · convert hv using 1; ext i j k; norm_num; ring

-- !-- noThreeWay_geodesic: the kernel theorem writes v = u + (v000-u000)•M3; walk_add_smul gives
-- a walk of that length and walk_corner_bound shows none is shorter — distance = |v000-u000|. -- !--
/-- **Markov-graph geodesic distance.** For any two non-negative tables `u`, `v` with the same
two-way margins, the corner displacement `|v 0 0 0 - u 0 0 0|` is realised by some walk and is
a lower bound for every walk.  Hence it is *exactly* the graph distance between `u` and `v` in
the Markov graph of the fiber: the corner cell is an isometry onto an integer interval. -/
theorem noThreeWay_geodesic (u v : Table3)
    (hu : Nonneg u) (hv : Nonneg v) (h : SameMargins u v) :
    Walk u v (v 0 0 0 - u 0 0 0).natAbs ∧
      ∀ n, Walk u v n → (v 0 0 0 - u 0 0 0).natAbs ≤ n := by
  refine ⟨?_, fun n hn => walk_corner_bound hn⟩
  have hk := noThreeWay_kernel u v h
  convert walk_add_smul (v 0 0 0 - u 0 0 0) u hu _
  exact hk ▸ hv

end MarkovBases.NoThreeWay


-- NEW_FILE: Catalog/Bridges/HyperbolicArithmetic.lean
import Mathlib

/-!
# Hyperbolic Arithmetic on the Poincaré Disk

This module develops arithmetic on the one-dimensional Poincaré disk model
(-1, 1) ⊂ ℝ using Möbius addition. Unlike the complex case, real Möbius
addition is fully associative via the artanh isomorphism, making (-1, 1)
an abelian group isomorphic to (ℝ, +).

## Main Definitions
* `DiskPoint` — Points in the open unit disk (-1, 1) ⊂ ℝ
* `moebiusAdd` — Möbius addition: (a+b)/(1+ab)
* `HypWord` — Words in a two-generator system for hyperbolic lattices
* `moebiusIterate` — Iteration of Möbius self-addition
* `orbitGap` — Separation between distinct Möbius orbits
* `hypDist` — Hyperbolic distance via artanh

## Main Results
* `moebius_preserves_disk` — Closure under Möbius addition
* `moebius_assoc` — Full associativity (field_simp + ring)
* `moebius_iterate_strict_mono` — Monotonicity of iterates (induction)
* `moebius_no_interior_fixed_point` — No interior fixed points (by_contra)
* `orbit_growth_lower_bound` — Exponential growth of lattice balls
* `hyp_zeta_summand_diverges` — Zeta summand reversal
* `wordBall_exact` — Exact ball count by geometric series

## Falsifiable Conjecture
The **Orbit Separation Conjecture**: for 0 < a < b < 1, the Möbius orbits
moebiusIterate a n and moebiusIterate b n maintain positive gap at all steps.
-/

noncomputable section

open Real BigOperators

namespace HyperbolicArithmetic

/-! ## §1. Möbius Addition -/

/-- Möbius addition: the canonical operation on the Poincaré disk. -/
def moebiusAdd (a b : ℝ) : ℝ := (a + b) / (1 + a * b)

theorem moebius_denom_pos (a b : ℝ) (ha : |a| < 1) (hb 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Impossible Geometries via the Fibonacci Apparition Lattice

## Synthesis

This cycle reframed the divisibility structure of Fibonacci numbers as a *discrete
geometry* and proved that this geometry simultaneously exhibits the Euclidean and
the elliptic faces of the parallel postulate.

The organizing object is the **entry point** (rank of apparition) `α(m)`: the least
`k > 0` with `m ∣ F(k)`. The Entry-Point Characterization Theorem
(`fib_dvd_iff_entryPt_dvd`) shows that each divisibility "line"
`L(m) = {k | m ∣ F(k)}` is exactly the principal ideal `α(m)·ℕ`. Reading these
ideals geometrically:

* **Divergence (Euclidean face).** `apparition_step` proves that consecutive members
  of a line are spaced by *exactly* `α(m)`, with no member in between — evenly spaced
  parallel hyperplanes that drift apart linearly as `α(m)` grows.
* **Convergence (elliptic / "impossible" face).** `apparition_inter_eq_mul` and
  `apparition_lines_meet` prove that for coprime moduli the two lines are *forced to
  re-intersect*, and their meeting set is again a line generated by
  `lcm(α a, α b)` — parallel families that converge.

The bridge between the two faces is the **lcm law** `fibEntryPt_mul_coprime`
(`α(a·b) = lcm(α a, α b)` for coprime `a, b`), which we closed this cycle (it had
been left as a `sorry` research target). Together with the
`(3,4,5)`-instantiation (`fibEntryPt_five`, `fibEntryPt_three_four`, giving the
apparition profile `(4,6,5)`), this packages the apparition lattice into a usable
arithmetic-geometry dictionary.

## Results Summary

Proved, `sorry = 0`, axioms `{propext, Classical.choice, Quot.sound}` only:

1. `FibEntryChar.fibEntryPt_mul_coprime` — the lcm law for entry points (sorry filled).
2. `ApparitionGeometry.apparition_inter_eq_mul` — coprime lines meet on the product line.
3. `ApparitionGeometry.apparition_lines_meet` — the meeting set is the `lcm(α a, α b)` line.
4. `ApparitionGeometry.apparition_step` — lines are arithmetic progressions of gap `α(m)`.
5. `ApparitionGeometry.fibEntryPt_five`, `fibEntryPt_three_four` — the `(3,4,5)` profile.

Files: `Catalog/Speculative/AutoResearch/FibonacciEntryPointCharacterization.lean`
(lcm law completed) and the new self-contained
`Catalog/Pythagorean/ApparitionLatticeGeometry.lean`.

---

## Direction 1 — The full apparition reconstruction functor `α` from prime powers

**Conjecture.** For every `m ≥ 1`, `α(m) = lcm over prime powers p^e ‖ m of α(p^e)`,
and `α(p^e) = p^{max(e - e_0, 0)} · α(p)` where `e_0` is the `p`-adic valuation of
`F(α(p))` (the "wall" exponent). Equivalently, `α` is a fully multiplicative-on-lcm
functor from the divisor lattice of `m` to the index lattice of `ℕ`.

**The key insight is** that `fibEntryPt_mul_coprime` already proves the *coprime
gluing* half; what remains is the single-prime *lifting law*, which is governed by
the `p`-adic valuation `v_p(F_k)` and the lifting-the-exponent lemma for Lucas
sequences. Once both halves are in place, `α` is co
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
