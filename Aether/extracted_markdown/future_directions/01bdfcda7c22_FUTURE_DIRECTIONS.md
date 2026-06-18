# Future Directions — Arrow's Theorem as Curvature of Preference Space

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
