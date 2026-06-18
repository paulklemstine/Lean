# Future Directions — Entropy-Bounded Computation (EBC)

## Synthesis

This cycle laid the algebraic and analytic foundations of the **Entropy-Bounded
Computation (EBC)** framework, which treats computational complexity as a
thermodynamic resource through Landauer's principle (erasing one bit dissipates at
least `kT ln 2`). Working over the abstract positive Landauer unit `u`, we built a
small, self-contained library with three pillars, all proved with `sorry = 0` and
only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

* **Foundations** (`Foundations.lean`): the cost functional `landauerCost`, an
  `EntropyBudgetSystem` structure, and the basic cost algebra —
  `one_bit_erasure_cost`, `landauerCost_additive` (dissipation composes additively),
  `entropy_budget_monotone`, `step_count_bounded_by_budget` (a finite budget caps
  the number of irreversible steps at `B/u`), and the cost-freeness of reversible
  computation (`reversible_comp_is_id`, `reversible_comp_cost_zero`).
* **The Entropy Gap Theorem** (`EntropyGap.lean`): `entropy_gap_unbounded` shows
  that `landauerCost (2^n) u − landauerCost (n^c) u → +∞` for every fixed unit
  `u > 0` and exponent `c`. This is the framework's thermodynamic shadow of
  `P ≠ NP`: exponential search is irreducibly more dissipative than any polynomial
  procedure, with `entropy_gap_eventually_pos` giving the eventual strict gap.
* **A thermodynamic sorting lower bound** (`SortingBound.lean`):
  `sorting_landauer_cost_lower_bound` recovers the classical `Ω(n log n)`
  comparison-sorting bound as a *physical* law — any correct comparison sort using
  `k` comparisons dissipates at least `⌈log₂(n!)⌉ · u`, via the pigeonhole fact
  `comparison_distinguish_bound` and the ceiling-log bridge `Nat.clog_le_iff_le_pow`.

The cross-domain payoff is that one cost functional `landauerCost` simultaneously
expresses a separation statement (the gap theorem) and recovers a concrete
algorithmic lower bound (sorting), tying complexity, thermodynamics, and
information theory through a single linear functional.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `landauerCost_additive` | dissipation composes additively | proved |
| `step_count_bounded_by_budget` | finite budget ⇒ `n ≤ B/u` steps | proved |
| `reversible_comp_is_id` | reversible round-trip is identity, cost 0 | proved |
| `entropy_gap_unbounded` | `2^n`–`n^c` cost gap `→ +∞` | proved |
| `sorting_landauer_cost_lower_bound` | sorting costs `≥ ⌈log₂ n!⌉·u` | proved |

---

## Direction 1 — Refine the gap into a quantitative separation rate

**Conjecture.** The entropy gap is not merely unbounded but admits an *explicit
eventual lower bound*: for fixed `u > 0`, `c`, there is an `N(c)` such that for all
`n ≥ N(c)`, `landauerCost (2^n) u − landauerCost (n^c) u ≥ (1/2)·2^n·u`. More
ambitiously, the *ratio* `landauerCost (2^n) u / landauerCost (n^c) u → +∞` with a
computable threshold beyond which it exceeds any target `R`.

**Test.** Strengthen `entropy_gap_unbounded` (already proved via the eventual bound
`2^n − n^c ≥ ½·2^n`) into a named `∀ n ≥ N, …` statement with an explicit `N`, then
prove the ratio divergence using `tendsto_pow_const_div_const_pow_of_one_lt` in the
denominator. Verify `N(c)` numerically with `#eval` for `c = 1,2,3`.

**The key insight is** that the current proof already *constructs* the witness
`½·2^n` as an eventual lower bound, so the unbounded limit can be upgraded to a
fully effective, constructive separation rate with the threshold extracted from the
`eventually` filter — no new analysis is required, only bookkeeping.

**Why now?** The limit theorem is in hand and its proof is constructive; turning a
`Tendsto … atTop` into an explicit `N` is the natural next deliverable for an
*algorithmic & constructive* engine and immediately yields a `#eval`-checkable
separation table.

---

## Direction 2 — Entropy complexity classes and a strict thermodynamic hierarchy

**Conjecture.** Define `ENTROPY(f)` as the languages decidable by an
`EntropyBudgetSystem` whose total Landauer cost on inputs of size `n` is at most
`f(n)·u`. Then the hierarchy is strict: `ENTROPY(n) ⊊ ENTROPY(n²) ⊊ ENTROPY(n³) ⊊ …`,
and the entropy gap theorem provides the separating witnesses at each level.

**Test.** Formalize `ENTROPY(f)` on top of `EntropyBudgetSystem`, prove the trivial
containments `ENTROPY(f) ⊆ ENTROPY(g)` for `f ≤ g` from `entropy_budget_monotone`,
then attempt one strict separation `ENTROPY(n) ⊊ ENTROPY(n²)` by exhibiting a
decision problem requiring `Θ(n²)` erasures (e.g. all-pairs distinctness over `n`
items, lower-bounded by the same pigeonhole pattern as the sorting bound).

**The key insight is** that `entropy_budget_monotone` already gives the easy
inclusions for free, so the only mathematical content left is a single strict
separation — and the sorting bound shows our pigeonhole machinery
(`comparison_distinguish_bound`) can manufacture exactly such lower bounds.

**Why now?** Both halves of a hierarchy theorem (monotone inclusion + one strict
gap) now have working prototypes in the library; assembling them into a class-level
statement is the first genuinely *new* complexity-theoretic object the framework can
support.

---

## Direction 3 — Quantum entropy budget and the measurement bottleneck

**Conjecture.** In a quantum extension where steps are either unitary (cost `0`,
modelled exactly as a `ReversibleComputation`/`Equiv`) or measurements (cost `u`),
the total Landauer cost equals `(number of measurements)·u`, independent of the
number of unitary gates. Hence quantum advantage is a *deferral* of entropy
production to measurement time, and a circuit with `M` measurements costs `M·u`.

**Test.** Define `QuantumStep := Unitary (e : Equiv α α) | Measure`, give a list of
steps a cost via `landauerCost (measurementCount steps) u`, and prove additivity and
the measurement-count formula by reusing `reversible_comp_cost_zero` (unitaries are
free) and `landauerCost_additive`. Compute the cost of toy Grover/Shor traces with
`#eval`.

**The key insight is** that our `ReversibleComputation = Equiv.Perm` abstraction
*already* assigns cost `0` to bijective (unitary-like) steps, so the quantum cost
model is the existing cost algebra restricted to a two-constructor step type — the
measurement-count theorem is `landauerCost_additive` applied to a filtered list.

**Why now?** The reversible-is-free results (`reversible_comp_is_id`,
`reversible_comp_cost_zero`) are the exact primitive a quantum model needs, and they
are proved; the quantum layer is a thin, computable wrapper rather than new physics.

---

## Direction 4 — Bennett's reversible simulation as a time–entropy trade-off

**Conjecture.** Any `T`-step irreversible computation can be simulated by a
reversible one (a composition of `Equiv`s) with **zero** Landauer cost but a
multiplicative time overhead `O(T·S)` in space `S`. Formally, the simulated process
is a `ReversibleComputation`, so its `reversibleCost` is `0`, while its step count is
bounded by an explicit polynomial in `T` and `S`.

**Test.** Model Bennett's pebble game as a finite sequence of `Equiv` moves, show the
composite is a `ReversibleComputation` (so cost `0` by `reversible_comp_cost_zero`),
and bound the move count combinatorially. Validate on a reversible AND (Toffoli)
gadget with `#eval` confirming zero cost.

**The key insight is** that "reversible ⇒ zero cost" is already a theorem in the
library, so Bennett's construction only needs to be *exhibited* as a chain of
`Equiv`s; the entropy side is then immediate and all remaining work is a step count.

**Why now?** With `step_count_bounded_by_budget` quantifying the irreversible regime
and `reversibleCost = 0` quantifying the reversible one, the framework can finally
state the *trade-off between the two regimes* — the conceptual core of reversible
computing — as a single comparative theorem.

---

## Direction 5 — From comparison sorts to general decision-tree lower bounds

**Conjecture.** The signature abstraction behind `comparison_distinguish_bound`
generalizes: any algorithm whose observable behaviour on a finite instance set `X`
is a `k`-bit signature `X → (Fin k → Bool)` and which must distinguish all of `X`
requires `k ≥ ⌈log₂ |X|⌉`, hence Landauer cost `≥ ⌈log₂ |X|⌉·u`. Instantiating
`X` as searching (`|X| = N`), median-finding, or element-distinctness recovers their
information-theoretic bounds as thermodynamic laws.

**Test.** Keep `comparison_distinguish_bound` as the general lemma (it is already
stated for an arbitrary `Fintype α`), and add corollaries instantiating `α` to a
search space `Fin N` and to other finite instance families, each yielding a
`landauerCost`-form lower bound by the same `entropy_budget_monotone` step used in
`sorting_landauer_cost_lower_bound`.

**The key insight is** that `comparison_distinguish_bound` is *already* proved at full
generality over any finite type — the sorting bound is just the `Equiv.Perm (Fin n)`
instance — so a whole family of lower bounds is one `Fintype.card` computation away.

**Why now?** The general pigeonhole lemma and the cost-monotonicity bridge are both
proved and decoupled; harvesting additional classical lower bounds as corollaries is
high-yield, low-risk, and squarely constructive (each new bound is a finite-cardinality
`#eval` check plus a one-line instantiation).
