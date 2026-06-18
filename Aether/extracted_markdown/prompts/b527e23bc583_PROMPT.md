
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

**Title**: For a Calabi-Yau threefold X defined over ℚ, the L-function L(X, s) = Σ aₙ n⁻ˢ
**Domain**: Novelty
**Mathematical framing**: # Future Directions: Arithmetic Mirror Symmetry

## 1. Modularity of CY Threefold Point Counts

For a Calabi-Yau threefold X defined over ℚ, the L-function L(X, s) = Σ aₙ n⁻ˢ
conjecturally satisfies a functional equation and admits analytic continuation.
For rigid CY threefolds (h²¹ = 0), the Fourier coefficients aₚ should coincide
with those of a weight-4 modular form.

The key insight is that the mirror Euler characteristic theorem (χ̃ = (-1)ⁿχ)
constrains the functional equation of L(X, s) via the parity of the motivic
weight, and for rigid CY threefolds the mirror has h¹¹ = 0 which forces the
L-function to be modular by Serre's conjecture (now proved).

Why now? The formalized Hodge diamond structure with Serre duality provides the
exact framework to state and prove that the Galois representation on H³(X)
has the correct Hodge-Tate weights for modularity. The `betti_poincare_dual`
theorem already encodes Poincaré duality, which is the geometric input to the
functional equation.

## 2. Arithmetic Mirror Map and Period Integrals

The mirror map τ(z) = ∫ Ω_z / ∫ Ω₀ relates the complex structure parameter z
of the mirror family to the Kähler parameter τ of X. For the quintic, this map
has q-expansion coefficients that are integers — a deep arithmetic fact.

The key insight is that integrality of the mirror map coefficients is equivalent
to a congruence condition on the Picard-Fuchs differential equation modulo
primes, which can be formalized as a statement about p-adic valuations of
hypergeometric series ₄F₃ evaluated at rational points.

Why now? Our formalization of CY3Data with concrete quintic examples (h¹¹=1,
h²¹=101) provides the numerical framework. The next step is to formalize the
Picard-Fuchs operator for the quintic family and prove that its solutions at
the MUM point have integer q-expansion, which is a finite verification for each
coefficient.

## 3. SYZ Fibration and Tropical Mirror Symmetry

The SYZ conjecture says mirror symmetry is T-duality on special Lagrangian torus
fibrations. Tropicalizing this picture yields a combinatorial version: the mirror
of a toric CY hypersurface is computed by dualizing the Newton polytope.

The key insight is that for toric CY hypersurfaces, h^{1,1}(X) equals the number
of lattice points interior to facets of the Newton polytope Δ, while h^{n-1,1}(X)
equals the number of interior lattice points of Δ itself, and the Batyrev mirror
construction swaps Δ ↔ Δ° (polar dual). This makes our mirror_euler_sign theorem
a shadow of a purely combinatorial duality.

Why now? Tropical geometry and polytope combinatorics are well within reach of
Lean formalization. The Hodge diamond framework we built can be instantiated with
Batyrev's formula, and the Euler characteristic relation becomes a theorem about
Ehrhart polynomials of dual polytopes.

## 4. Weil Conjectures for CY Varieties over Finite Fields

For a smooth CY n-fold X over 𝔽_q, the zeta function Z(X/𝔽_q, T) is a rational
function whose factors correspond to cohomology groups. Mirror symmetry predicts
specific relationships between the zeta functions of X and its mirror X̌.

The key insight is that our Hodge diamond structure directly controls the degrees
of the numerator/denominator factors of the zeta function: the factor corresponding
to Hᵏ has degree bₖ. The `betti_poincare_dual` theorem then implies the functional
equation Z(X, 1/q^n T) = ±q^{nχ/2} T^χ Z(X, T), and `eulerChar_mirror` shows
how this functional equation transforms under the mirror involution.

Why now? The Weil conjectures for smooth projective varieties follow from étale
cohomology theory. While full étale cohomology is not in Mathlib, the numerology
(degree of zeta function factors = Betti numbers) can be stated as axioms and
the mirror symmetry consequences derived formally from our framework.

## 5. Higher-Dimensional Hodge Diamond Classification

For CY n-folds with n ≥ 4, the Hodge diamond has more free parameters than
just (h¹¹, h^{n-1,1}). The mirror involution h^{p,q} ↦ h^{n-p,q} imposes
non-trivial constraints on which Hodge diamonds can appear in mirror pairs.

The key insight is that the CYHodgeDiamond structure we formalized (with the
vanishing conditions h^{k,0} = 0 for 0 < k < n) combined with Hodge symmetry
and Serre duality dramatically reduces the number of free Hodge numbers. For
CY 4-folds, the independent numbers are h¹¹, h²¹, h³¹, and h²², subject to
the constraint 2(24 + h¹¹ + h³¹ - h²¹) = h²² (from the top Chern class being
the Euler characteristic). Mirror symmetry then swaps h¹¹ ↔ h³¹ while
preserving h²¹ and h²².

Why now? Our formalization already handles the general n case for CY Hodge
diamonds. Specializing to n = 4 and proving the Chern class constraint as a
linear relation on Hodge numbers would yield the first formal verification of
CY 4-fold mirror symmetry constraints, which are actively studied in F-theory
compactifications.

Research domain: Novelty
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


-- NEW_FILE: Catalog/Algebra/MatrixGroupGeneration.lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Generation Certificates for Matrix Groups

This file develops a certificate-based framework for proving generation properties
of linear groups over finite fields. The central concept is that algebraic
irreducibility of the characteristic polynomial of a linear map provides a
"generation certificate" — a structural condition that feeds into probabilistic
lower bounds on random generation.

## Main definitions

* `IsInvariantSubmodule φ W`: Predicate that submodule `W` is invariant under `φ`.
* `LinearGenerationCertificate`: A bundled certificate consisting of an endomorphism
  with bijective action and irreducible characteristic polynomial.
* `certificateDensity`: The density of certified elements in a finite group.
* `GenerationCertificateSystem`: Abstract typeclass for certificate-based generation.

## Main results

* `eq_bot_or_top_of_charpoly_irreducible`: If `φ` has irreducible characteristic
  polynomial, every `φ`-invariant submodule is `⊥` or `⊤`.
* `span_orbit_eq_top_of_irreducible`: The orbit of any nonzero vector under an
  endomorphism with irreducible charpoly spans the entire space.
* `irreducible_endomorphism_has_no_fixed_proper_projective_subspace`: No proper
  nonzero invariant subspace exists — the finite-geometry bridge theorem.
* `generation_lower_bound_of_certificate_system`: Abstract generation lower bound
  from certificate density.

## Strategy

The proof of the invariant subspace theorem proceeds via minimal polynomials:
1. Cayley-Hamilt
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: Calabi–Yau Fourfold Hodge Combinatorics and Arithmetic Mirror Symmetry

## Synthesis

This cycle extended the catalog's arithmetic mirror-symmetry skeleton
(`Geometry.MirrorSymmetry.ArithmeticMirror`, with its `eulerChar` / `mirror`
reflection machinery and the threefold relation `χ(mirror Y) = −χ(X)`) from
complex dimension `3` to dimension `4`, the case actively studied in F-theory
compactifications. The new file
`Geometry.MirrorSymmetry.CalabiYauFourfold` packages the four independent Hodge
numbers `h^{1,1}, h^{2,1}, h^{3,1}, h^{2,2}` of a smooth Calabi–Yau fourfold into
a structure `CY4`, builds the full `ℕ → ℕ → ℤ` Hodge diamond from the D4
symmetries (Hodge symmetry, Serre duality, Calabi–Yau vanishing), and proves the
combinatorial backbone of fourfold mirror symmetry directly over the catalog's
`eulerChar`.

## Results Summary

All six results are proven with `sorry = 0` and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`):

1. `CY4.eulerChar_eq` — the bare combinatorial Euler characteristic of the
   fourfold diamond is `χ = 4 + 2 h¹¹ + 2 h³¹ + h²² − 4 h²¹` (no Chern input).
2. `CY4.mirror_diamond_eq` — the catalog reflection `ArithmeticMirror.mirror 4`
   realizes, on the support `p,q ≤ 4`, the F-theory mirror map `h^{1,1} ↔ h^{3,1}`
   with `h^{2,1}, h^{2,2}` fixed.
3. `CY4.swap_involutive` — that mirror exchange is an involution (`ℤ/2`-action).
4. `CY4.eulerChar_swap_invariant` and `CY4.eulerChar_mirror_invariant` — for the
   *even* dimension `4`, `χ(mirror X) = χ(X)`, the `(-1)^4 = 1` shadow of the
   catalog `ArithmeticMirror.eulerChar_mirror`, in sharp contrast to the
   threefold sign flip `ArithmeticMirror.eulerChar_mirror_threefold`.
5. `CY4.eulerChar_KLRY` — under the Klemm–Lian–Roan–Yau Chern relation
   `h²² = 2(22 + 2h¹¹ + 2h³¹ − h²¹)`, the Euler characteristic collapses to the
   celebrated F-theory formula `χ = 6(8 + h¹¹ + h³¹ − h²¹)`.

The unification observed is that *parity of the complex dimension* is the single
parameter governing the mirror behaviour of the Euler characteristic: odd
dimensions flip the sign, even dimensions fix it, and both are the `u = v = 1`
specializations of the catalog `eulerChar_mirror` / `HodgeEPolynomial`
functional equations.

## Bold, Falsifiable Research Directions

### 1. Closed-form `χ` for every Calabi–Yau `n`-fold diamond

The fourfold computation `CY4.eulerChar_eq` was a finite `Finset.sum_range_succ`
expansion of a `match`-defined diamond. Conjecture: for *every* `n` there is a
single uniform linear form, computed from the Hodge–symmetric / Serre-dual
orbit structure of the index square `{0,…,n}²`, giving
`χ(X_n) = Σ_{orbits O} (-1)^{p+q} |O| · h_O`, and this form is mirror-symmetric
(invariant under `p ↦ n−p`) iff `n` is even.

The key insight is that the D4 symmetry group acting on the index square `{0,…,n}²`
partitions the Hodge numbers into orbits whose alternating-sign-weighted sizes are
*computable as a function of `n` alone*, so `χ` 
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
