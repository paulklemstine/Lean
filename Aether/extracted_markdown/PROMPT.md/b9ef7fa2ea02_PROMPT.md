
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

**Title**: This cycle closed the single open `sorry` in `Bridges/ArrowCurvature/Defs.lean`
**Domain**: Applications
**Mathematical framing**: # Future Directions — Arrow's Theorem as Curvature of Preference Space

This cycle closed the single open `sorry` in `Bridges/ArrowCurvature/Defs.lean`
(`arrow_curvature_conjecture`) and added `Bridges/ArrowCurvature/Extensions.lean`,
which makes the underlying obstruction explicit. The central discovery is that the
"unrestricted-domain" hypothesis `∀ P, 0 < CondorcetCurvature P` is *unsatisfiable*:
a unanimous profile is always flat. Below are concrete, falsifiable directions that
build on this.

## 1. Replace the unsatisfiable hypothesis with a domain-relative one

The current `arrow_curvature_conjecture` is vacuously true because no profile space
has positive curvature everywhere (see `unrestricted_domain_impossible`). A genuine
Arrow-style theorem should quantify curvature over a *restricted* admissible domain
`D : Set (PreferenceProfile n k)` and ask: if every profile in `D` has positive
curvature, is every Pareto+IIA SWF defined on `D` dictatorial?

The key insight is that the vacuity is not a flaw in Arrow's theorem but a signal
that curvature positivity must be stated relative to the *reachable* configuration
space, exactly as holonomy is computed over loops that actually bound. Why now? We
have already isolated the obstruction theorem (`unrestricted_domain_impossible`) and
the constructive witnesses (`exists_unanimous_profile`), so the next step — encoding
an admissible domain and re-deriving impossibility on it — is now a well-posed,
incremental formalization rather than an open-ended search.

## 2. Curvature as an exact obstruction class (cohomological reading)

`condorcetCurvature_eq_cycleCount` identifies profile curvature with the directed
3-cycle count of the majority tournament. This invites a cochain interpretation:
treat `majorityMargin : Fin n → Fin n → ℤ` as a 1-cochain and ask whether
`CondorcetCurvature P = 0` is equivalent to that 1-cochain being a coboundary
(i.e. `majorityMargin a b = f a - f b` for some potential `f`).

The key insight is that transitivity of the majority relation is exactly the
"gradient field" condition, so Condorcet curvature should equal the rank of an
explicit discrete curl operator. Why now? With curvature already proved equal to a
concrete cycle count and `zero_curvature_majority_transitive` already in hand, the
coboundary characterization is the natural strengthening and is fully constructive
over the finite alternative set.

## 3. Quantitative flatness: a curvature lower bound from cycle margins

Beyond the binary "curvature = 0 vs > 0" dichotomy, define a *weighted* curvature
summing the margin products `majorityMargin a b · margin b c · margin c a` over
cycles, and prove it is bounded below by the number of strict 3-cycles times the
minimum positive margin.

The key insight is that polarization (large Kendall distances between voters, see
`KendallDistance`) should force large weighted curvature, giving a metric inequality
linking disagreement to cyclicity. Why now? `majority_margin_bounded` and
`kendall_symm`/`kendall_self` already provide the bounded-geometry scaffolding, so a
genuine inequality between the Kendall metric and weighted curvature is the obvious,
testable next theorem.

## 4. Single-peaked domains have zero curvature (Black's theorem, formalized)

The file defines `IsSinglePeaked` but never proves Black's median-voter theorem:
a single-peaked profile with an odd number of voters has transitive majority rule,
hence `CondorcetCurvature P = 0`.

The key insight is that single-peakedness is a discrete *convexity* condition that
flattens the preference manifold, so it should compose cleanly with
`curvature_zero_iff_no_majority_cycle` once the median voter is exhibited. Why now?
The single-peaked machinery and the curvature-zero criterion are both present and
proved; only the median-extraction lemma is missing, making this a high-value,
self-contained target.

## 5. Counting flat profiles: an enumeration / probability conjecture

`exists_unanimous_profile` gives one flat profile; the natural quantitative question
is how many of the `(n!)^k` profiles are flat (`CondorcetCurvature = 0`), and whether
this fraction tends to a limit as `k → ∞` for fixed `n` (the classic "probability of
a Condorcet cycle" question, but cast in curvature language).

The key insight is that flatness fraction is a tractable curvature statistic that can
first be *computed* by `decide`/`#eval` for small `n, k` and then conjectured in
closed form, turning a folklore probability into a formal asymptotic statement. Why
now? Curvature is already a decidable `Finset.card`, so exhaustive small-case
verification is immediately available to seed and falsify candidate formulas before
attempting the general proof.

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- DIFF: Catalog/Bridges/ArrowCurvature/Defs.lean
--- a/Bridges/ArrowCurvature/Defs.lean
+++ b/Bridges/ArrowCurvature/Defs.lean
@@ -292,55 +292,6 @@
     (P.majorityTournament hk hn).IsTransitive := by
   convert tournament_trans_of_no_3cycle _ _;
   convert curvature_zero_iff_no_majority_cycle P |>.1 hcurv using 1
-
-/-! ## Part VIII: The Arrow-Curvature Conjecture -/
-
-/-- **Arrow-Curvature Conjecture (testable direction)**: For `n ≥ 3` alternatives
-    and `k ≥ 2` voters, if the Condorcet curvature is positive for a sufficiently
-    rich family of profiles, then any Pareto + IIA social welfare function is dictatorial.
-
-    Test: Compute `CondorcetCurvature` for random profiles with `n = 3, k = 3`.
-    If curvature > 0, verify that the only Pareto + IIA SWFs are dictatorial.
-    If curvature = 0, verify that majority rule gives a valid SWF.
-
-    This conjecture is falsifiable: find a Pareto + IIA + non-dictatorial SWF
-    on a domain where some profile has positive curvature. -/
-theorem arrow_curvature_conjecture
-    (n k : ℕ) (hn : 3 ≤ n) (hk : 2 ≤ k)
-    (F : SocialWelfareFunction n k)
-    (hpareto : F.IsPareto)
-    (hiia : F.IsIIA)
-    -- Hypothesis: curvature is positive on ALL profiles (unrestricted domain)
-    (hunrestricted : ∀ P : PreferenceProfile n k, 0 < CondorcetCurvature P) :
-    F.IsDictatorial := by
-  sorry
-
-/-! ## Part IX: Kendall Distance and Polarization -/
-
-/-- The Kendall tau distance between two rankings: the number of pairs
-    on which they disagree. This measures how "far apart" two voters'
-    preferences are — the discrete analogue of geodesic distance
-    on the preference manifold. -/
-noncomputable def KendallDistance {n : ℕ} (r₁ r₂ : StrictRanking n) : ℕ :=
-  ((Finset.univ (α := Fin n × Fin n)).filter
-    (fun ⟨a, b⟩ => r₁.prefers a b ∧ r₂.prefers b a)).card
-
-/-
-Kendall distance is symmetric
--/
-theorem kendall_symm {n : ℕ} (r₁ r₂ : StrictRanking n) :
-    KendallDistance r₁ r₂ = KendallDistance r₂ r₁ := by
-  apply Finset.card_bij (fun x _ => (x.snd, x.fst));
-  · grind;
-  · grind;
-  · exact fun b hb => ⟨ ( b.2, b.1 ), by aesop ⟩
-
-/-
-Kendall distance from a ranking to itself is zero
--/
-theorem kendall_self {n : ℕ} (r : StrictRanking n) :
-    KendallDistance r r = 0 := by
-  exact Finset.card_eq_zero.mpr ( Finset.filter_eq_empty_iff.mpr fun x hx => by have := r.prefers_asymm x.1 x.2; tauto )
 
 /-! ## Part X: Unanimity and Flat Preference Spaces -/
 
@@ -383,6 +334,80 @@
     exact fun i => StrictRanking.prefers_trans _ _ _ _ ( h_all_prefer_b_c i ) ( h_all_prefer_c_a i );
   exact Finset.card_le_card fun x hx => by aesop;
 
+/-! ## Part VIII: The Arrow-Curvature Conjecture -/
+
+/-- **Arrow-Curvature Conjecture (testable direction)**: For `n ≥ 3` alternatives
+    and `k ≥ 2` voters, if the Condorcet curvature is positive for a sufficiently
+    rich family of profiles, then any Pareto + IIA social welfare function is dictatorial.
+
+    Test: Compute `CondorcetCurvature` for random profiles with `n = 3, k = 3`.
+    If curvature > 0, verify that the only Pareto + IIA SWFs are dictatorial.
+    If curvature = 0, verify that majority rule gives a valid SWF.
+
+    This conjecture is falsifiable: find a Pareto + IIA + non-dictatorial SWF
+    on a domain where some profile has positive curvature. -/
+theorem arrow_curvature_conjecture
+    (n k : ℕ) (hn : 3 ≤ n) (hk : 2 ≤ k)
+    (F : SocialWelfareFunction n k)
+    (hpareto : F.IsPareto)
+    (hiia : F.IsIIA)
+    -- Hypothesis: curvature is positive on ALL profiles (unrestricted domain)
+    (hunrestricted : ∀ P : PreferenceProfile n k, 0 < CondorcetCurvature P) :
+    F.IsDictatorial := by
+  -- !-- Proof sketch -- !--
+  -- The unrestricted-domain hypothesis is unsatisfiable: a unanimous profile is
+  -- always flat (`unanimous_curvature_zero`), so `hunrestricted` applied to the
+  -- all-identical profile yields `0 < 0`. The conclusion is thus vacuously true.
+  -- !-- End proof sketch -- !--
+  exfalso
+  set r : StrictRanking n := ⟨Equiv.refl _⟩ with hr
+  set P : PreferenceProfile n k := fun _ => r with hP
+  have hu : P.IsUnanimous := fun i j a b h => h
+  have h0 : CondorcetCurvature P = 0 := unanimous_curvature_zero P hu
+  have h1 := hunrestricted P
+  omega
+
+-- !-- Lab Notebook: arrow_curvature_conjecture -- !--
+-- !-- Hypothesis: a global "positive curvature everywhere" hypothesis would force
+--     dictatorship, mirroring Arrow's impossibility theorem. -- !--
+-- !-- Result: Proved, but vacuously: the hypothesis `∀ P, 0 < CondorcetCurvature P`
+--     is unsatisfiable, since the unanimous profile is flat. -- !--
+-- !-- Insight: "curvature positive everywhere" is the wrong global hypothesis; the
+--     unanimous (flat) profile is always reachable, so positivity must be stated
+--     relative to a restricted admissible domain (see Extensions.lean). -- !--
+-- !-- Failure analysis: A direct Arrow-style derivation is impossible here because
+--     the antecedent can never hold; the honest content is the obstruction theorem
+--     `unrestricted_domain_impossible` proved in Extensions.lean. -- !--
+-- !-- End Lab Notebook -- !--
+
+/-! ## Part IX: Kendall Distance and Polarization -/
+
+/-- The Kendall tau distance between two rankings: the number of pairs
+    on which they disagree. This measures how "far apart" two voters'
+    preferences are — the discrete analogue of geodesic distance
+    on the preference manifold. -/
+noncomputable def KendallDistance {n : ℕ} (r₁ r₂ : StrictRanking n) : ℕ :=
+  ((Finset.univ (α := Fin n × Fin n)).filter
+    (fun ⟨a, b⟩ => r₁.prefers a b ∧ r₂.prefers b a)).card
+
+/-
+Kendall distance is symmetric
+-/
+theorem kendall_symm {n : ℕ} (r₁ r₂ : StrictRanking n) :
+    KendallDistance r₁ r₂ = KendallDistance r₂ r₁ := by
+  apply Finset.card_bij (fun x _ => (x.snd, x.fst));
+  · grind;
+  · grind;
+  · exact fun b hb => ⟨ ( b.2, b.1 ), by aesop ⟩
+
+/-
+Kendall distance from a ranking to itself is zero
+-/
+theorem kendall_self {n : ℕ} (r : StrictRanking n) :
+    KendallDistance r r = 0 := by
+  exact Finset.card_eq_zero.mpr ( Finset.filter_eq_empty_iff.mpr fun x hx => by have := r.prefers_asymm x.1 x.2; tauto )
+
+
 /-! ## Part XI: Cycle Count Characterization -/
 
 /-



-- NEW_FILE: Catalog/Bridges/ArrowCurvature/Extensions.lean
import Bridges.ArrowCurvature.Defs

/-!
# Arrow–Curvature, Extensions: the obstruction is explicit, and curvature is a coboundary class

This file extends `Bridges.ArrowCurvature.Defs`. There, `arrow_curvature_conjecture`
was stated with the global hypothesis `∀ P, 0 < CondorcetCurvature P` ("positive
curvature everywhere"). We make the *content* of that cycle precise:

* The global hypothesis is **unsatisfiable** (`unrestricted_domain_impossible`): a
  unanimous profile is always flat, so no profile space has positive curvature
  everywhere. This is exactly why `arrow_curvature_conjecture` is vacuously true —
  the obstruction lives in the *reachable* configuration space, not in Arrow's axioms.

* By contrast, positive curvature **is** achievable on individual profiles
  (`exists_positive_curvature_profile`): the classical Condorcet paradox witnesses
  `0 < CondorcetCurvature`. So restricting curvature positivity to an admissible
  domain is meaningful, while demanding it everywhere is not.

* Condorcet curvature is *literally* the directed 3-cycle count of the majority
  tournament (`condorcetCurvature_eq_cycleCount`).

* The cohomological reading: a tournament is transitive (flat) **iff** its `beats`
  relation is the strict order induced by an integer potential `f : Fin n → ℤ`
  (`Tournament.transitive_iff_has_potential`). Transitivity is exactly the
  "the curl/curvature 1-cochain is a coboundary `f a − f b`" condition. Specialised
  to profiles: zero Condorcet curvature gives such a global potential
  (`zero_curvature_has_potential`).

## Main results

* `exists_unanimous_profile`         — a flat (unanimous) profile always exists.
* `unrestr
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — Arrow's Theorem as Curvature of Preference Space

## Synthesis

This cycle closed the single open `sorry` in `Bridges/ArrowCurvature/Defs.lean`
(`arrow_curvature_conjecture`) and added `Bridges/ArrowCurvature/Extensions.lean`,
which makes the underlying obstruction explicit. The central discovery is structural,
not numerical: the "unrestricted-domain" hypothesis `∀ P, 0 < CondorcetCurvature P`
that the original conjecture assumed is **unsatisfiable**. A unanimous profile is
always flat (`unanimous_curvature_zero`), and a unanimous profile always exists
(`exists_unanimous_profile`), so demanding positive curvature on *every* profile is
self-contradictory. The conjecture is therefore vacuously true, and we proved it that
way honestly, recording the diagnosis in the file's Lab Notebook.

The interesting content lives in the *quantifier*. We proved the obstruction theorem
`unrestricted_domain_impossible` (positive-curvature-everywhere fails for all `n, k`)
side by side with `exists_positive_curvature_profile` (the classical Condorcet paradox
realises positive curvature on a single profile). So curvature is a genuine two-sided
invariant — flat profiles and curved profiles both exist — and the failure of the
original conjecture is purely about "every profile" versus "some admissible profile."
This reframes Arrow geometrically: curvature must be measured over the *reachable*
configuration space, exactly as holonomy is computed over loops that actually bound.

The deepest new result is the cohomological reading. `condorcetCurvature_eq_cycleCount`
shows Condorcet curvature is literally the directed 3-cycle count of the majority
tournament, and `Tournament.transitive_iff_has_potential` proves that a tournament is
flat **iff** its `beats` relation is the strict order of an integer potential
`f : Fin n → ℤ` (via the Copeland score). Transitivity is precisely the discrete
"gradient field"/coboundary condition; a 3-cycle is exactly the obstruction to writing
the majority margin as a coboundary `f a − f b`. Specialised to profiles,
`zero_curvature_has_potential` extracts a global "social utility" potential from
vanishing curvature. These results turn the slogan "curvature = holonomy = cohomology
class" into theorems and set up the next cycle's coboundary/curl program.

## Results Summary

- `arrow_curvature_conjecture`: proved (vacuously) — the global positive-curvature premise is unsatisfiable, so the Arrow-style conclusion holds trivially; the honest content is the obstruction below.
- `exists_unanimous_profile`: proved — every profile space contains a flat (unanimous) profile, the explicit witness behind the vacuity.
- `unrestricted_domain_impossible`: proved — `∀ P, 0 < CondorcetCurvature P` is false for every `n, k`; curvature positivity cannot be a global hypothesis.
- `exists_positive_curvature_profile`: proved — the Condorcet paradox realises positive curvature, so the obstruction is about the quantifier, not curvature triviality.

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
