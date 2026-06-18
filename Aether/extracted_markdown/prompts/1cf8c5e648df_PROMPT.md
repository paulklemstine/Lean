
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

**Title**: The current formalization establishes the structural machinery (definitions of S
**Domain**: Novelty
**Mathematical framing**: # Future Directions: The Geometry of Consensus

## 1. Full Arrow's Impossibility via Decisive Ultrafilters

The current formalization establishes the structural machinery (definitions of SWF, Pareto, IIA, decisive coalitions, and the ultrafilter-on-finite-types theorem) but does not yet close the full loop: proving that decisive coalitions under Pareto + IIA form an ultrafilter. The key insight is that the "field expansion lemma" — showing decisiveness for one pair implies decisiveness for all pairs — requires constructing specific preference profiles that witness the transfer, and this construction is the technically hardest part.

**Testable conjecture**: The decisive coalitions of any SWF satisfying Pareto + IIA on ≥3 alternatives form a filter that is also an ultrafilter (i.e., for every coalition S, either S or Sᶜ is in the family). This can be tested by attempting to formalize the field expansion lemma for the 3-alternative case first, where only 6 preference orderings exist per voter.

**Why now?** Our definitions compile cleanly and the ultrafilter-is-principal theorem is already in Mathlib. The only missing piece is the algebraic characterization of decisive families, which requires careful but finite case analysis on triples of alternatives.

## 2. Quantitative Arrow: Curvature Bounds on Near-Dictatorships

Our Hellinger distance and Bhattacharyya coefficient results give a metric structure on the space of probability distributions. A natural quantitative extension of Arrow's theorem would bound how "close to dictatorial" a SWF must be, measured in terms of the curvature of the underlying preference space.

**Testable conjecture**: For any ε-approximately IIA social welfare function F (meaning |BC(F(P), F(Q))| ≤ ε whenever P and Q agree on a pair), there exists a voter v such that the Hellinger distance between F(P) and the dictatorial output Pᵥ is at most C·ε for some universal constant C depending only on the number of alternatives. The key insight is that our `bhattacharyya_cauchy_schwarz` and `hellinger_pos_of_ne` results already give the rigidity needed — strict positivity of Hellinger distance means approximate IIA forces approximate projection.

**Why now?** The Friedgut-Kalai-Naor quantitative Arrow theorem (2002) proves exactly this in the Boolean case. Our Fisher-Rao framework should give a cleaner proof via spherical geometry, and the necessary inequalities are already formalized.

## 3. Single-Peaked Preferences and Zero Curvature

Our `polarization_consensus` theorem shows that when all voters agree, the polarization index (average Hellinger distance) is zero. The geometric conjecture is stronger: when preferences are "single-peaked" (unimodal on a common axis), the effective curvature of the restricted preference space drops to zero, and majority rule satisfies all Arrow conditions on this restricted domain.

**Testable conjecture**: Define single-peakedness as the condition that all voter utility vectors lie in a geodesic arc (1-dimensional submanifold) of the probability simplex. On such a submanifold, the induced curvature is zero, and the Bhattacharyya coefficient satisfies BC(midpoint(p,q), r) = (BC(p,r) + BC(q,r))/2 exactly (no contraction). The key insight is that geodesics on the sphere are great circles, and a great circle has zero intrinsic curvature, so the contraction inequality becomes an equality.

**Why now?** Black's single-peakedness theorem (1948) is the classical positive result complementing Arrow's impossibility. Our framework gives a geometric explanation: single-peaked preferences live on a flat submanifold where the curvature obstruction vanishes.

## 4. Gibbard-Satterthwaite via Spherical Fixed Points

The Gibbard-Satterthwaite theorem states that any strategy-proof voting rule on ≥3 alternatives is dictatorial. The standard proof uses Arrow's theorem as a lemma. Our geometric framework suggests a more direct route: strategy-proofness corresponds to the aggregation map being a retraction (continuous map with F∘F = F), and the Brouwer fixed-point theorem on the sphere constrains such retractions.

**Testable conjecture**: Any continuous retraction F: (S^{n-1})^m → S^{n-1} satisfying unanimity (F(x,...,x) = x) and locality (F depends on each coordinate only through its angular position) is a projection onto one coordinate. The key insight is that retractions of the sphere onto itself must be the identity or a constant on each connected component, and locality plus unanimity forces projection.

**Why now?** The Borsuk-Ulam theorem and spherical topology are well-developed in Mathlib. Connecting them to social choice would be a genuine cross-domain bridge theorem.

## 5. Information-Geometric Characterization of Voting Rules

Beyond Arrow's impossibility, different voting rules (Borda count, Condorcet, approval voting, etc.) correspond to different maps on the Fisher-Rao manifold with different geometric properties. The polarization index gives a scalar summary of voter disagreement; different voting rules optimize different functions of this index.

**Testable conjecture**: The Borda count corresponds to the center of mass (Fréchet mean) on the probability simplex, while Condorcet methods correspond to the metric median. The Fréchet mean minimizes Σ H²(F, pᵢ) (total Hellinger distance) while the median minimizes Σ H(F, pᵢ) (total Hellinger distance without squaring). The key insight is that our `hellinger_eq_half_sq_dist` result shows H² = ½‖√p - √q‖², so minimizing total H² is equivalent to finding the Euclidean mean of the sqrt-embedded distributions, projected back to the sphere.

**Why now?** The Fréchet mean on Riemannian manifolds is computable and well-studied. Our sqrt-embedding reduces it to a standard linear algebra problem, making the characterization of voting rules as optimization problems on the sphere both precise and computable.

Research domain: Novelty
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Bridges/SinglePeakedFlatness.lean
import Bridges.ArrowCurvature.Defs

/-!
# Single-Peaked Preferences are Flat: Black's Theorem as Vanishing Curvature

This file extends `Bridges.ArrowCurvature.Defs`, where the *Condorcet curvature*
of a preference profile (the number of directed majority 3-cycles) was introduced
as a discrete analogue of Riemannian curvature on the space of preference profiles.

The headline result advertised but **left unproven** in `Defs` was Black's theorem
(`single_peaked_majority_transitive`). We close that gap here, and recast Black's
1948 theorem in geometric language:

> **Single-peaked preference domains are flat.**
> If every voter's ranking is single-peaked on a common axis, the Condorcet
> curvature vanishes, hence the majority tournament is transitive.

## Strategy (Sen's value restriction → Black's theorem)

The proof goes through Amartya Sen's *value restriction* condition, which we
isolate as the key structural lemma:

* `single_peaked_never_worst` — On any triple `a < b < c` (in axis order), a
  single-peaked voter never ranks the **middle** alternative `b` last; i.e. the
  voter prefers `b` to `a` or prefers `b` to `c`.

The engine that converts value restriction into transitivity is a *transfer of
decisiveness* across the middle alternative:

* `cross_beats` — If the middle `m` is never-worst for every voter, and a flank
  alternative `L` beats `m` by majority, then `L` also beats the opposite flank
  `R` by majority. (The `L > m` voters are forced, by value restriction and
  transitivity, to also rank `L > R`.)

These combine to forbid majority cycles, giving flatness:

* `single_peaked_no_majority_cycle` — no Condorcet cycle.
* `single_peaked_curvature_zero` — `CondorcetCurvature P = 0` (geometric form).
* `single_peaked_majority_transitive` — **Black's theorem** (classical form).

## Catalog synthesis

We build directly on `Bridges.ArrowCurvature.Defs`:
`CondorcetCurvature`, `PreferenceProfile.majorityBeats`,
`PreferenceProfile.supportCount`, `support_partition`,
`StrictRanking.IsSinglePeakedAt`, `curvature_zero_iff_no_majority_cycle`, and
`zero_curvature_majority_transitive`. Where `unanimous_curvature_zero` (in `Defs`)
showed the *single point* is flat, we show the entire *single-peaked submanifold*
is flat — the geometric explanation, anticipated in the project's FUTURE
DIRECTIONS, for why single-peakedness escapes Arrow's impossibility.

-- !-- Lab Notebook -- !--
Hypothesis: The "single-peaked ⟹ transitive majority" result (Black 1948),
  advertised in `ArrowCurvature/Defs.lean` but unproven, should follow from a
  purely local value-restriction property combined with a counting/transfer
  argument, with no parity (odd-`k`) hypothesis needed for *acyclicity*.
Result: Confirmed. `single_peaked_no_majority_cycle` and
  `single_peaked_curvature_zero` need no oddness assumption; oddness only enters
  `single_peaked_majority_transitive` because the underlying
  `majorityTournament` of `Defs` is only defined for odd `k` (to break ties).
Insight: The whole proof factors through ONE inequality lemma `cross_beats`:
  decisiveness of a flank over the never-worst middle transfers to decisiveness
  over the far flank. This is the discrete shadow of "geodesics on a flat
  submanifold carry no holonomy". Value restriction = flatness; the transfer
  lemma = parallel transport with trivial holonomy.
Failure analysis: A first instinct was to do a 4-class (n1..n4) census of the
  six linear orders on a triple. That is correct but heavy in Lean. The subset
  inclusion `{i : L ≻ m} ⊆ {i : L ≻ R}` (valid precisely because `m` is
  never-worst) replaces the entire census with one `Finset.card_le_card`.
-- !-- end Lab Notebook -- !--
-/

open Finset Function

namespace SinglePeakedFlatness

/-! ## Part I: Value restriction — the middle is never worst -/

/-
!-- For a voter single-peaked at `p`, on a triple `a < b < c` either the peak
is at/right of `b` (use the right-monotone clause to get `b ≻ c`) or strictly
left of `b` (use the left-monotone clause to get `b ≻ a`). Either way `b` is
not last. -- !--

**Sen value restriction from single-peakedness.** A single-peaked voter never
    ranks the axis-middle alternative `b` of a triple `a < b < c` last: it prefers
    `b` to `a` or prefers `b` to `c`.
-/
theorem single_peaked_never_worst {n : ℕ} (r : StrictRanking n) (p : Fin n)
    (hsp : r.IsSinglePeakedAt p) (a b c : Fin n)
    (hab : (a : ℕ) < (b : ℕ)) (hbc : (b : ℕ) < (c : ℕ)) :
    r.prefers b a ∨ r.prefers b c := by
  by_cases hp : ( b : ℕ ) ≤ p.val <;> simp_all +decide [ StrictRanking.IsSinglePeakedAt ];
  exact Or.inr ( hsp.2.2 _ _ hp.le hbc )

/-! ## Part II: The transfer-of-decisiveness lemma -/

/-
!-- The voters with `L ≻ m` are a subFinset of those with `L ≻ R`: each such
voter has, by value restriction, `m ≻ L` or `m ≻ R`; `m ≻ L` is impossible
(asymmetry), so `m ≻ R`, hence `L ≻ m ≻ R ⟹ L ≻ R`. Counting:
`supportCount L R ≥ supportCount L m > k/2`, so `L` beats `R`. -- !--

**Transfer of decisiveness across a never-worst middle.** If `m` is never
    ranked worst (every voter prefers `m` to `L` or to `R`) and the flank `L`
    beats `m` by strict majority, then `L` beats the far flank `R` by strict
    majority.
-/
theorem cross_beats {n k : ℕ} (P : PreferenceProfile n k) (m L R : Fin n)
    (hLm : L ≠ m) (hLR : L ≠ R)
    (hvr : ∀ i, (P i).prefers m L ∨ (P i).prefers m R)
    (hbeat : P.majorityBeats L m) :
    P.majorityBeats L R := by
  unfold PreferenceProfile.majorityBeats at *;
  have h_support_count : (Finset.univ.filter (fun i => (P i).prefers L m)).card ≤ (Finset.univ.filter (fun i => (P i).prefers L R)).card := by
    refine Finset.card_le_card ?_;
    intro i hi; specialize hvr i; simp_all +decide [ StrictRanking.prefers ] ;
    exact lt_trans hi ( hvr.resolve_left ( lt_asymm hi ) );
  linarith! [ P.support_partition L m hLm, P.support_partition L R hLR ]

/-! ## Part III: No majority cycles on the sorted triple -/

/-
!-- With `a < b < c` the middle is `b`; value restriction gives `b` never-worst
for all voters. Each cyclic orientation contains an edge `flank ≻ b`; apply
`cross_beats` to get `flank` beating the opposite flank, contradicting the
closing edge of the cycle by majority asymmetry. -- !--

For an axis-sorted triple `a < b < c`, neither cyclic orientation of the
    majority relation can occur on a single-peaked profile.
-/
theorem median_no_cycle {n k : ℕ} (P : PreferenceProfile n k)
    (hsp : P.IsSinglePeaked) (a b c : Fin n)
    (hab : (a : ℕ) < (b : ℕ)) (hbc : (b : ℕ) < (c : ℕ)) :
    ¬ (P.majorityBeats a b ∧ P.majorityBeats b c ∧ P.majorityBeats c a) ∧
    ¬ (P.majorityBeats a c ∧ P.majorityBeats c b ∧ P.majorityBeats b a) := by
  constructor <;> intro h <;> rcases h with ⟨ h₁, h₂, h₃ ⟩;
  · -- By `cross_beats`, `a` beats `c` by majority, contradicting `h₃`.
    have h_cross : P.majorityBeats a c := by
      apply cross_beats;
      exact ne_of_lt hab;
      · exact ne_of_lt ( lt_trans hab hbc );
      · exact fun i => single_peaked_never_worst _ _ ( hsp i |> Classical.choose_spec ) _ _ _ hab hbc;
      · assumption;
    unfold PreferenceProfile.majorityBeats at *; linarith;
  · -- By `cross_beats`, since `c` beats `b`, `c` must also beat `a`.
    have h_c_beats_a : P.majorityBeats c a := by
      apply cross_beats P b c a (by
      exact ne_of_gt hbc) (by
      exact ne_of_gt ( lt_trans hab hbc )) (by
      intro i
      obtain ⟨p, hp⟩ := hsp i
      have := single_peaked_never_worst (P i) p hp a b c hab hbc
      aesop) h₂;
    unfold PreferenceProfile.majorityBeats at *; linarith;

/-! ## Part IV: Black's theorem, geometric and classical forms -/

/-
!-- A Condorcet cycle forces three distinct alternatives; sorting them by axis
position lands in one of the two orientations ruled out by `median_no_cycle`. -- !--

**No Condorcet cycle on a single-peaked profile.**
-/
theorem single_peaked_no_majority_cycle {n k : ℕ} (P : PreferenceProfile n k)
    (hsp : P.IsSingle
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions: The Geometry of Consensus, Continued

## Synthesis of this cycle

The Arrow–Curvature bridge (`Catalog/Bridges/ArrowCurvature/`) introduced the
*Condorcet curvature* of a preference profile — the count of directed majority
3-cycles — as a discrete analogue of Riemannian curvature, and showed that the
*single point* (a unanimous profile) is flat (`unanimous_curvature_zero`). What
it advertised but did not prove was Black's theorem, the positive counterpart to
Arrow's impossibility.

This cycle closes that gap in `Catalog/Bridges/SinglePeakedFlatness.lean`. The
new results are:

* `single_peaked_never_worst` — single-peakedness implies Sen's *value
  restriction*: the axis-middle alternative of any triple is never ranked last.
* `cross_beats` — a *transfer of decisiveness*: across a never-worst middle,
  a flank that beats the middle by majority also beats the far flank.
* `single_peaked_no_majority_cycle` — no Condorcet cycle on a single-peaked
  profile.
* `single_peaked_curvature_zero` — **Black's theorem, geometric form**: the
  whole single-peaked *submanifold* is flat (`CondorcetCurvature P = 0`),
  strengthening `unanimous_curvature_zero` from a point to a submanifold.
* `single_peaked_majority_transitive` — **Black's theorem, classical form**:
  majority rule is transitive on single-peaked domains with an odd electorate.

The conceptual payoff is a clean dictionary: *value restriction = flatness*, and
*transfer-of-decisiveness = parallel transport with trivial holonomy*. A notable
finding is that acyclicity (the geometric statement) needs **no parity
hypothesis**; oddness enters only to make the tie-broken `majorityTournament`
well-defined.

The directions below are deliberately falsifiable and build on the now-proven
flatness theorems and the existing catalog (`ArrowCurvature`, `BorsukUlamArrow`,
`TopologicalArrowImpossibility`).

## 1. Median-voter Condorcet winner as the center of the flat submanifold

We proved that single-peaked profiles have zero curvature, but we did not yet
exhibit the *Condorcet winner*. Black's full theorem says the median voter's peak
beats every alternative pairwise.

**Testable conjecture.** For a single-peaked profile with an odd number of voters,
let `m*` be the alternative that is the median of the voters' peaks (under the
axis order on `Fin n`). Then `m*` is a Condorcet winner: for every `b ≠ m*`,
`P.majorityBeats m* b`. Equivalently, `m*` is the unique source of the (now known
to be transitive) majority tournament.

**The key insight is** that our `cross_beats` lemma already transfers decisiveness
*outward* from a never-worst middle; iterating it from the median peak should push
decisiveness all the way to the boundary of the axis, pinning the winner at the
median. Flatness guarantees the iteration cannot loop back on itself.

**Why now?** With `single_peaked_majority_transitive` proven, the tournament is a
strict linear order, so a unique maximum exists; the only remaining work is to

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
