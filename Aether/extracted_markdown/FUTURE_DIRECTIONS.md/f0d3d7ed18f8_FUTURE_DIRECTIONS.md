# Future Directions — Proof Phase Transitions in Random k-SAT

This cycle closed the **satisfiable side** of the first-moment picture for random
`k`-SAT, complementing the unsatisfiable (annealed upper) bound already present in
`RandomKSAT.lean` (`exists_unsat`, `exists_unsat_of_real_density`). The new results,
all proved by a pure averaging ("max ≥ mean") argument on the *same* exact first-moment
identity `first_moment_general`, are:

* `exists_many_sat_general` — for any finite CSP whose per-assignment satisfied-constraint
  count is a constant `S`, some `m`-constraint formula `F` satisfies the division-free
  bound `|A|·S^m ≤ |C|^m · #{a ⊨ F}` (max ≥ mean on the incidence sum).
* `exists_sat_general` — consequently, once the mean `|A|·S^m ≥ 1`, some formula is
  satisfiable.
* `exists_sat_count_ge`, `exists_sat`, `exists_sat_of_real_density` — the Boolean
  `k`-SAT specializations, the last reading: if `1 ≤ 2^n·(1 − 2^{−k})^m` then a
  *satisfiable* formula provably exists.

Together with the existing unsat results, the satisfiability transition is now formally
**bracketed** at the statistical-physics density `2^n·(1 − 2^{−k})^m = 1`: below it some
formula is unsatisfiable, at/above it some formula is satisfiable. The arguments are
pure averaging/pigeonhole on a single exact counting identity, which makes them unusually
robust and easy to transport to other constraint models (the `Qary` namespace already
demonstrates this for the `q`-ary model).

The following directions push the same exact-counting engine further.

## Direction 1 — A two-sided density window theorem as a single statement

We currently expose the lower and upper brackets as separate theorems. The next step is
one packaged statement `sat_phase_window`: for `1 ≤ n` and real density
`d := 2^n·(1 − 2^{−k})^m`, *both* a satisfiable and an unsatisfiable formula exist when
`d` sits in the half-open transition window, and the `m ↦ d` map is strictly antitone so
the window is hit by exactly one critical clause count `m*(n,k)`. The key insight is that
the satisfiable and unsatisfiable existence proofs both factor through the *same* incidence
sum `∑_F #{a ⊨ F} = |A|·S^m`, so the window is governed by a single scalar crossing `1`,
not by two independent phenomena. Why now? Both halves are now proved in `RandomKSAT.lean`,
and `exists_unsat_of_density_mono` already supplies the antitonicity; assembling them needs
only the integer monotonicity of `m ↦ 2^n·((2n)^k − n^k)^m`, which is within reach of the
existing casting lemmas.

## Direction 2 — Second-moment lower bound on the satisfiable side

The first moment only certifies *existence* of a satisfiable formula; the famous
strengthening is a second-moment / variance bound showing that a *positive fraction* of
formulas are satisfiable in the dense regime. Concretely, prove `second_moment_general`:
`∑_F (#{a ⊨ F})^2 = ∑_{a,b} (sat-overlap of a,b)^m`, then apply Paley–Zygmund to
lower-bound `#{F : #{a ⊨ F} > 0}`. The key insight is that the second moment again
factorizes coordinatewise over the `m` independent constraint slots — exactly like
`card_models_form` did for the first moment — so the entire variance computation reduces to
one per-pair overlap count `#{c : sat a c ∧ sat b c}`, a finite combinatorial quantity.
Why now? The factorization infrastructure (`card_models_form`, `first_moment_general`) is
already in place and is the only nontrivial ingredient; the second moment reuses it
verbatim with a pair `(a,b)` in place of a single `a`.

## Direction 3 — Exact satisfiability for the 1-in-k / NAE-SAT variants

The same incidence identity holds for *any* satisfaction relation, so it applies unchanged
to the 1-in-k SAT model (a clause is satisfied iff *exactly one* literal is true) and to
NAE-SAT (not-all-equal). For each the per-assignment satisfied-clause count `S` is a clean
inclusion–exclusion constant, and the existence thresholds drop out of
`exists_unsat_general` / `exists_many_sat_general` with no new proof effort. The key insight
is that our abstract law is indifferent to *which* clauses are deemed satisfied: only the
single number `S = #{c : sat a c}` (constant in `a` by symmetry) enters, so a new model is
fully specified by recomputing one cardinality. Why now? The abstract generals are already
model-agnostic and proven; each new model is a self-contained `card_*_clause` lemma plus a
one-line specialization, ideal for parallel formalization.

## Direction 4 — Sharpness: the brackets are tight at the endpoints

We should certify that neither bracket can be improved by a constant factor, by exhibiting
explicit witnesses. The key insight is that the averaging inequality
`|A|·S^m ≤ |C|^m·#{a ⊨ F}` becomes an *equality* exactly when every formula has the same
number of satisfying assignments, which happens degenerately at `k = 0` or `m = 0`;
classifying these equality cases pins down precisely where the "max ≥ mean" step loses
information. Why now? The equality analysis only requires inspecting
`Finset.sum_lt_sum_of_nonempty` (already used in `exists_many_sat_general`) under the
hypothesis that all summands are equal — a boundary-case study that also doubles as a
counterexample family showing the brackets cannot be sharpened.

## Direction 5 — From "exists" to a quantitative satisfying-assignment count

The strongest form of the lower bracket is not "some formula is satisfiable" but "some
formula has at least `⌈2^n·(1 − 2^{−k})^m⌉` satisfying assignments", which
`exists_sat_count_ge` already encodes in multiplicative form. Turning this into an explicit
floor/ceiling bound `∃ F, ⌈mean⌉ ≤ #{a ⊨ F}` would give a formally verified annealed
*capacity* statement for random k-SAT. The key insight is that the multiplicative
inequality `|C|^m·#{a ⊨ F} ≥ |A|·S^m` is exactly the division-free form of
`#{a ⊨ F} ≥ mean`, so the upgrade is a `Nat`-division manipulation
(`Nat.le_div_iff_mul_le`) rather than any new combinatorics. Why now? `exists_sat_count_ge`
is proved and positivity of `(2n)^{km}` is already handled in `exists_sat_of_real_density`,
so the ceiling refinement is a short arithmetic postprocessing step.
