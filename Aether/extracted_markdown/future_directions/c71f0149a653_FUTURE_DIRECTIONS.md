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
- `condorcetCurvature_eq_cycleCount`: proved — Condorcet curvature equals the directed 3-cycle count of the majority tournament (curvature = holonomy, literally).
- `Tournament.transitive_iff_has_potential`: proved — flatness ⇔ the `beats` 1-cochain is a coboundary of an integer (Copeland) potential.
- `zero_curvature_has_potential`: proved — zero Condorcet curvature yields a global majority potential / consistent social utility on alternatives.

## Research Directions

### Direction 1: Domain-relative Arrow impossibility
**Hypothesis**: For `n ≥ 3`, `k ≥ 2`, there is an admissible domain
`D : Set (PreferenceProfile n k)` that *excludes* unanimity, on which
`∀ P ∈ D, 0 < CondorcetCurvature P` holds and every Pareto+IIA social welfare
function restricted to `D` is dictatorial.
**Test**: Encode `D` (e.g. the orbit of the Condorcet paradox under voter/alternative
relabelling), prove the curvature premise is satisfiable on `D` via
`exists_positive_curvature_profile`, then attempt the dictatorship conclusion or build
a non-dictatorial Pareto+IIA counterexample on `D`.
**Why now**: We have isolated the obstruction (`unrestricted_domain_impossible`) and a
concrete curved witness (`exists_positive_curvature_profile`), so the only missing
ingredient is the domain encoding — a well-posed, incremental formalization rather than
an open search. The key insight is that the vacuity is a quantifier defect, not an Arrow
defect, so relativising to a curvature-positive `D` should restore non-vacuous content.
**If true**: A genuine geometric Arrow theorem stated entirely in curvature language.
**If false**: A Pareto+IIA non-dictatorial aggregator on a fully-curved domain would be
a striking escape from Arrow and would pinpoint which extra axiom Arrow secretly uses.

### Direction 2: Quantitative weighted curvature and a polarization inequality
**Hypothesis**: Define weighted curvature `W(P) = Σ` over majority 3-cycles of
`majorityMargin a b · majorityMargin b c · majorityMargin c a`. Then
`W(P) ≥ (CondorcetCurvature P) · m³` where `m` is the minimum positive margin, and `W`
grows with total Kendall disagreement `Σ_{i<j} KendallDistance (P i) (P j)`.
**Test**: Define `W`, prove the cycle-count lower bound by bounding each summand below
by `m³`, then seek a metric inequality relating `W` to the Kendall sum using
`kendall_symm`, `kendall_self`, and `majority_margin_bounded`.
**Why now**: `condorcetCurvature_eq_cycleCount` gives the exact cycle structure to sum
over, and the bounded-geometry lemmas (`majority_margin_bounded`) are already proved.
The key insight is that polarization (large pairwise Kendall distances) should *force*
large weighted curvature, turning the binary flat/curved dichotomy into a metric law.
**If true**: A discrete "disagreement ⇒ curvature" inequality, the voting analogue of a
Bonnet–Myers-type bound.
**If false**: A highly polarized yet low-curvature profile would show curvature and the
Kendall metric are independent, refining what "polarization" can mean.

### Direction 3: Uniqueness and normalization of the curvature potential
**Hypothesis**: When `CondorcetCurvature P = 0`, the potential `f` of
`zero_curvature_has_potential` is unique up to a strictly monotone reparametrisation,
and the Copeland score is its canonical representative: `f a = T.score a` linearly
orders the alternatives and equals their final social rank.
**Test**: Prove that any two strict potentials for the same transitive tournament induce
the same linear order, and that `Tournament.score` is injective on a transitive
tournament (hence a bijection `Fin n → Fin n` after sorting).
**Why now**: `Tournament.transitive_iff_has_potential` already exhibits `score` as a
potential; the missing step is rigidity. The key insight is that flatness collapses the
gauge freedom of the potential down to monotone reparametrisation, exactly like a
gradient determines its scalar field up to an additive constant.
**If true**: A canonical "social utility" attached to every flat profile, making the
cohomology class `[majorityMargin] = 0` carry a distinguished cochain primitive.
**If false**: Multiple inequivalent potentials would reveal hidden degeneracy in the
majority order and complicate the coboundary picture.

### Direction 4: Counting flat profiles (curvature statistics)
**Hypothesis**: For fixed `n` the fraction of the `(n!)^k` profiles with
`CondorcetCurvature P = 0` tends to a limit `p_n ∈ (0,1)` as `k → ∞` (odd), recovering
the classical "probability of a Condorcet winner" in curvature language, with
`p_3 = 1 − 3/(2π) · arccos(...)`-type closed form.
**Test**: Curvature is a decidable `Finset.card`, so first *compute* the flat fraction
by `decide`/`#eval` for small `n, k` (seeding off `condorcetParadox`), fit a candidate
closed form, and only then attempt the asymptotic proof.
**Why now**: `exists_positive_curvature_profile` and `condorcetCurvature_eq_cycleCount`
give both a curved seed and a computable invariant, so exhaustive small-case enumeration
is immediately available to falsify candidate formulas. The key insight is that a
folklore probability becomes a formal asymptotic statement once curvature is recognised
as a finite, decidable statistic.
**If true**: A formal asymptotic for Condorcet consistency expressed purely via
curvature.
**If false**: A non-convergent or boundary fraction would expose subtle dependence on
the parity/normalisation of `k`.

### Direction 5: Higher-dimensional curvature beyond 3-cycles
**Hypothesis**: 3-cycles do not exhaust the obstruction: define a degree-`d` curvature
counting directed `d`-cycles of the majority tournament, and prove that for tournaments,
`CondorcetCurvature P = 0` (no 3-cycle) already implies vanishing of all higher
`d`-cycle counts — i.e. 3-cycles generate the entire "homology."
**Test**: Strengthen `tournament_trans_of_no_3cycle`: show no 3-cycle ⇒ transitive ⇒ no
`d`-cycle for any `d ≥ 3`, then phrase this as a generation statement for the cycle
space of the majority tournament.
**Why now**: `tournament_trans_iff_no_3cycle` and `condorcetCurvature_eq_cycleCount` make
3-cycles the canonical generator; the natural next claim is that they generate all
holonomy. The key insight is that for *tournaments* (unlike general digraphs) the first
curvature class controls all higher ones, a strong rigidity special to total majority
data.
**If true**: A clean "3-cycles generate the obstruction" theorem justifying Condorcet
curvature as *the* invariant.
**If false**: A profile flat at degree 3 but curved at higher degree would reveal genuine
higher-order voting paradoxes invisible to pairwise majority cycles.
