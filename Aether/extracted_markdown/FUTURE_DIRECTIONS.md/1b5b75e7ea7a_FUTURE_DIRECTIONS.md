# Future Directions — Cellular Automata as Fixed-Point Varieties

Derived from this cycle's findings in `Catalog/Shared/CellularAutomataVariety.lean`
and `Catalog/Bridges/CellularAutomataGardenBridge.lean`.

This cycle **refuted** the headline conjecture "fixed-point variety dimension
correlates with Wolfram complexity class": the Turing-complete Rule 110 (Class 4)
attains the *minimum* variety (one point), identical to the trivial Rule 0
(Class 1), while the boring identity Rule 204 (Class 2) attains the *maximum*
`2^n`.  The five conjectures below redirect the program toward the invariants the
data actually supports.

---

## Conjecture 1 — Fixed-point dimension is a linear-algebraic, not computational, invariant

For every ECA rule `r`, `log₂ |V(r)|` on a cycle of length `n` equals the
`GF(2)`-dimension of the kernel of `(L_r − I)`, where `L_r` is the linearization
(degree-≤1 part over `GF(2)`) of the global map; for genuinely nonlinear rules
the fixed set is still an affine slice whose size is a power of 2 (or 0).

- **The key insight is** that `caStep r s = s` is, locally, a *constraint
  satisfaction* problem whose solution count is dictated by the rank of the
  associated `GF(2)` operator, not by the rule's dynamical behaviour — exactly
  why Rule 110 and Rule 0 coincide.
- **Why now?** We already have `fixedCard` and the exact counts for 204/0/110/51;
  the linear rules 90/150 (counts `1,1,4,1,1,4` and `2,4,2,4`) give immediate
  test data for the kernel-dimension formula.

## Conjecture 2 — Full dimension is a class of one

`fixedCard n r = 2^n` for **all** `n ≥ 1` if and only if `r` is the identity
Rule 204. No other elementary rule achieves maximal-dimension fixed-point
variety on every cycle.

- **The key insight is** that maximality forces *every* configuration to be a
  fixed point, which pins the local rule to `output = centre` cell-by-cell; the
  "Class 4 ⇒ dim = n" prediction is therefore vacuous.
- **Why now?** `rule204_fixedCard` proves the identity reaches `2^n`, and
  `turing_complete_not_maximal` already shows a Class-4 rule misses it; the
  uniqueness direction is a finite local-rule case analysis well within reach.

## Conjecture 3 — Garden-of-Eden count, not fixed-point count, measures collapse

The number of Garden-of-Eden states of an ECA equals `2^n − |image(caStep r)|`
and is monotone in how far `r` is from injective; it is *independent* of Wolfram
class but *does* separate reversible from irreversible rules.

- **The key insight is** that the bridge `max variety ⇔ identity ⇔ surjective ⇔
  GoE-free` (proved this cycle) shows surjectivity, not fixed-point dimension, is
  the structurally meaningful invariant.
- **Why now?** `Catalog/Bridges/GardenOfEden.lean` supplies the
  surjectivity↔GoE equivalence, and this cycle already connected it to
  `caStep`; counting preimages is the natural next quantitative step.

## Conjecture 4 — Fixed-point counts satisfy a transfer-matrix linear recurrence in `n`

For each fixed rule `r`, the sequence `n ↦ fixedCard n r` equals `tr(T_r^n)` for a
fixed `2×2` (or `4×4`) Boolean transfer matrix `T_r`; consequently it is
eventually periodic, with the period dividing a `gcd`-type quantity (Rule 90's
`1,1,4,1,1,4` has period 3; Rule 150 and Rule 30 have period 2).

- **The key insight is** that fixed configurations on a cycle are exactly closed
  walks in the rule's local de Bruijn graph, so their count is a trace of a
  power of the adjacency matrix — a classical linear recurrence.
- **Why now?** The computed tables already display clean periodicity in `n`, so
  the transfer matrices can be pinned down and verified rule-by-rule.

## Conjecture 5 — Complexity lives in periodic-orbit growth, not level-1 fixed points

Replace `V(r) = {s | caStep r s = s}` by `V_p(r) = {s | caStep r^[p] s = s}`.
Then the *growth rate* `limsup_p (log₂ |V_p(r)|)/p` (topological entropy) is
strictly positive for Rule 110 and `0` for Rules 0, 204, 51 — recovering a
genuine complexity invariant that the level-1 variety dimension destroys.

- **The key insight is** that Turing-completeness is a statement about *orbits*,
  so the right algebraic object is the family of period-`p` varieties and their
  exponential growth, not the single fixed-point set.
- **Why now?** `caStep` and its iterates are already defined; computing `|V_p|`
  for small `p, n` is immediate and will quickly confirm or refute positive
  entropy for Rule 110 versus the trivial rules.
