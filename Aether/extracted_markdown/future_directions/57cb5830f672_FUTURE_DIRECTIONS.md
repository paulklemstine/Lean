# FUTURE DIRECTIONS — Curvature of Preference Space: From Holonomy to Consensus

## Synthesis of findings this cycle

This cycle closed a dangling `sorry` and extended the catalog's
**Arrow-as-curvature** package (`Bridges.ArrowCurvature.Defs`), which models
Condorcet cycles as *holonomy* and transitivity as *flatness*. Two things were
accomplished, both verified with sound axioms only
(`propext`, `Classical.choice`, `Quot.sound`):

1. **`arrow_curvature_conjecture` is now proved** — but the proof exposes a
   structural fact rather than a deep theorem: the hypothesis
   `hunrestricted : ∀ P, 0 < CondorcetCurvature P` is *unsatisfiable*. The
   constant (identity) profile makes the majority relation a strict total order,
   so its curvature is `0`. Thus the previously-open statement was vacuously true,
   and the genuine impossibility content lives elsewhere (see Direction 1).

2. **A new "curvature ⇒ consensus" layer** was added on top of the catalog and
   fully proved:
   - `Tournament.cycleCount_eq_zero_iff_isTransitive` — the *numeric* curvature
     invariant `cycleCount` vanishes iff the tournament is flat (the discrete
     Ambrose–Singer statement at the level of cardinalities, upgrading the
     Prop-level `tournament_trans_iff_no_3cycle`).
   - `Tournament.condorcet_winner_unique` — at most one Condorcet winner.
   - `Tournament.transitive_has_condorcet_winner` — every nonempty flat
     tournament has a Condorcet winner (a global "holonomy-free section").
   - `Tournament.condorcet_winner_iff` — nonempty flat ⇒ *unique* Condorcet winner.
   - `PreferenceProfile.zero_curvature_condorcet_winner` — the voting payoff:
     odd electorate, `1 < n` alternatives, vanishing curvature ⇒ a genuine
     majority winner exists.

## Results summary

| Result | Status | Domain bridge |
|---|---|---|
| `arrow_curvature_conjecture` | proved (vacuous hypothesis) | social choice ↔ discrete geometry |
| `cycleCount_eq_zero_iff_isTransitive` | proved | enumerative combinatorics ↔ curvature |
| `condorcet_winner_unique` | proved | order theory |
| `transitive_has_condorcet_winner` | proved | finite well-foundedness ↔ consensus |
| `condorcet_winner_iff` | proved | — |
| `zero_curvature_condorcet_winner` | proved | majority rule ↔ flatness |

---

## Direction 1 — The honest Arrow theorem is the *real* curvature obstruction

`topological_arrow_conjecture` (in `Speculative.AutoResearch.TopologicalArrowImpossibility`)
remains open: every Pareto + IIA social welfare function on `k ≥ 3` alternatives
and `n ≥ 2` voters is dictatorial. The vacuous proof we found this cycle shows the
*curvature-everywhere* hypothesis is the wrong handle. The right one is the
**field of local pivotal coalitions**: IIA makes the social ranking of each pair a
function of the per-pair voter data, and Pareto pins the boundary values; the
contradiction is a global obstruction to a consistent flat connection.

- **The key insight is** that IIA = "the aggregation connection is determined by
  local (pairwise) data", and a Pareto + IIA SWF on an unrestricted domain is
  exactly a flat connection whose holonomy around a Condorcet 3-cycle must be both
  trivial (by local consistency) and nontrivial (by the existence of cyclic
  profiles) unless one voter's coordinate is a global section — the dictator.
- **Why now?** We already have `Tournament`, `PreferenceProfile`, `IsDecisiveFor`,
  `decisive_coalitions_intersect`, and `condorcet_cycle` proved in the catalog.
  The classical field-expansion / contraction lemma chain ("a coalition decisive
  on one pair is decisive on all pairs") is the only missing link, and it is a
  finite combinatorial induction — squarely in reach of the prover.
- **Falsifiable test:** for `k = 3, n = 2` enumerate all `36` profile pairs; any
  Pareto + IIA function must copy one voter. A counterexample pair refutes it.

## Direction 2 — A quantitative curvature–acyclicity inequality (Kendall–Babington Smith)

Strengthen `cycleCount_eq_zero_iff_isTransitive` from a 0/≠0 dichotomy to the exact
identity `cycleCount T = 2·(C(n,3) − Σ_v C(outdeg v, 2))` (counting ordered cyclic
triples), hence `T.cycleCount ≤ 2·C(n,3)` with equality controlled by the
out-degree variance.

- **The key insight is** that a triple fails to be cyclic exactly when it has a
  local source, so non-cyclic triples are counted by `Σ_v C(outdeg v, 2)`; the
  curvature is therefore a *variance* of the out-degree sequence, making
  "flatness" literally "minimum-variance".
- **Why now?** `cycleCount` is already defined as a `Finset.card`, and Mathlib has
  `Finset.card`, `Finset.sum_boole`, and double-counting infrastructure. The proof
  is a single re-indexing of `Fin n × Fin n × Fin n`.
- **Falsifiable test:** `#eval` both sides for all tournaments on `Fin 4, Fin 5`;
  any mismatch refutes the formula.

## Direction 3 — Black's theorem closes the loop to a *constructive* SWF

The catalog states `single_peaked_majority_transitive` (Black's theorem). Combined
with this cycle's `zero_curvature_condorcet_winner`, conjecture:
**on the single-peaked domain the median-voter alternative is the Condorcet
winner**, i.e. the winner produced by `transitive_has_condorcet_winner` equals the
peak of the median voter.

- **The key insight is** that single-peakedness forces every pairwise majority to
  agree with the one-dimensional order, so the `beats`-maximal element our
  well-foundedness argument selects is forced to be the median peak — turning a
  pure existence proof into an explicit, computable aggregator.
- **Why now?** Black's theorem and the winner-existence theorem are both in the
  repository; only the identification "selected source = median peak" is missing,
  and it is an order argument on `Fin n`.
- **Falsifiable test:** generate single-peaked profiles for `n = 5, k = 5` and
  check the computed Condorcet winner equals the median voter's peak; a deviation
  refutes it.

## Direction 4 — Curvature is monotone under domain restriction (a comparison theorem)

Conjecture a **monotonicity / comparison principle**: deleting a voter or merging
two alternatives cannot increase `CondorcetCurvature` past a controlled bound, and
restricting to any value-restricted subdomain is curvature-nonincreasing. This is
the discrete analogue of curvature comparison under submersions.

- **The key insight is** that value restriction removes exactly the local
  configurations (the "Latin-square" triples) that generate holonomy, so each
  restriction step can only erase cyclic triples — never create them.
- **Why now?** `CondorcetCurvature` and `supportCount` are explicit `Finset.card`s,
  so monotonicity reduces to a `Finset.card_le_card` of filtered triple sets under
  an injection — directly automatable.
- **Falsifiable test:** for random `n = 4, k = 5` profiles, compare curvature
  before/after deleting one voter; an increase beyond the conjectured bound refutes
  it.

## Direction 5 — Holonomy as a genuine group: the cycle space of the majority tournament

Promote "holonomy" from a slogan to structure: define the **cycle space**
`Z₁(T) ⊆ (Fin n → Fin n → ℤ)` of the majority tournament (formal sums of directed
edges with zero boundary) and conjecture `dim Z₁(T) = E − V + (#components)`, with
`CondorcetCurvature > 0 ↔ Z₁ ≠ 0` for the strongly connected case.

- **The key insight is** that Condorcet curvature is the first Betti number of the
  directed majority graph: cycles in the literal homological sense *are* the
  preference cycles, so Arrow's obstruction becomes `H₁ ≠ 0`.
- **Why now?** Mathlib's `SimpleGraph`, incidence matrices, and linear-algebra rank
  machinery are mature; the tournament's edge set is `Finset (Fin n × Fin n)`, so
  the boundary map is a concrete `Matrix` and Euler's formula is in reach.
- **Falsifiable test:** compute `rank` of the boundary matrix for tournaments on
  `Fin 3..Fin 6` and compare with `E − V + c`; any mismatch refutes the homological
  identification.
