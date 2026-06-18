# Future Directions — Unique Games, MAX-CUT, and SDP Gaps

## Synthesis

`Cryptography/UniqueGamesMaxCut.lean` formalizes the combinatorial core of unique
two-prover label-cover games over the Boolean alphabet `ZMod 2`. The decisive structural
observation is that a *unique* (permutation) constraint over a two-element alphabet is one
of exactly two bijections, so every such constraint collapses to a single `ℤ/2`-affine
equation `x i + x j = b`. MAX-CUT is precisely the all-`b = 1` fragment. Within this clean
first-principles model we proved, with no axioms beyond Lean/Mathlib defaults:

- a single `ℤ/2` involution — flipping one endpoint, `Function.update x i (x i + 1)` —
  simultaneously explains the **global gauge symmetry** (`value_flipAll`) and the exact
  **per-constraint half-count** `2 · #sat = 2ⁿ` (`two_mul_card_sat`);
- the **averaging identity** `2 · Σ value = m · 2ⁿ` (`two_mul_sum_value`), whose
  pigeonhole consequence is the **unconditional factor-2 bound** `exists_half`: every
  instance admits an assignment satisfying at least half its constraints;
- the **triangle integrality gap** (`triangle_gap`): the smallest odd cycle has optimum
  `2 < 3`, tightly matching the half-bound's `⌈3/2⌉ = 2`.

## Results summary

| Theorem | Statement | Method |
|---|---|---|
| `value_flipAll` | global vertex flip preserves value | `ℤ/2` cancellation |
| `selfLoop_unsat` | a "differ" self-loop is never satisfiable | `x + x = 0 ≠ 1` |
| `two_mul_card_sat` | exactly half of `2ⁿ` assignments satisfy a binary constraint | fixed-point-free involution |
| `two_mul_sum_value` | `2 · Σ value = m · 2ⁿ` | induction + half-count |
| `exists_half` | `∃ x, m ≤ 2 · value x` | averaging / pigeonhole |
| `triangle_gap` | triangle optimum is `2 < 3` | finite decision |

## Research directions

### 1. Frustration index of odd cycles scales as a constant fraction failure

For the `k`-cycle with all "must differ" constraints, the maximum number of satisfiable
constraints should be exactly `k` when `k` is even and `k - 1` when `k` is odd; equivalently
the *frustration index* (minimum number of violated constraints) is `0` for even cycles and
`1` for odd cycles. The key insight is that the value of a cyclic `ℤ/2`-system telescopes:
summing the residuals `x_{v} + x_{v+1} + b_e` around the cycle forces the parity of the
violated-constraint count to equal the parity of `Σ b_e`, so a single odd obstruction can
never be removed, only relocated. Why now? `value_flipAll` and `two_mul_card_sat` already
give us the gauge-invariance and counting infrastructure; the only new ingredient is a
telescoping sum over `Fin k`, which is a self-contained induction well within reach and
turns the one-off `triangle_gap` into an infinite tight family.

### 2. The half-bound is exactly tight only on odd-cycle-dense instances

Sharpen `exists_half` to a characterization: `m = 2 · max value` (the bound is met with
equality) iff the instance is, up to gauge, an edge-disjoint union of odd structures with no
slack. The key insight is that equality in the averaging/pigeonhole step demands the value
function be *constant* across all assignments, which over `ℤ/2` happens precisely when every
flip-orbit of constraints is balanced — a rigidity statement, not merely an inequality. Why
now? We have the exact identity `2 · Σ value = m · 2ⁿ`; equality analysis only needs the
Mathlib equality case of `Finset.sum_lt_sum_of_nonempty`, so the upgrade from "≥ half" to
"exactly half iff …" is a short, falsifiable refinement.

### 3. A `ℤ/p` generalization with a `1 - 1/p` random bound

Replace `ZMod 2` by `ZMod p` and unique constraints by genuine permutations `π(x i) = x j`.
The key insight is that the same single-coordinate involution becomes a free `ℤ/p`-action by
`Function.update x i (x i + t)`, so for any constraint with distinct endpoints *exactly*
`pⁿ⁻¹` assignments satisfy it, yielding the random-assignment bound `value ≥ m/p` and showing
unique games over a `p`-alphabet are `(1 - 1/p)`-hard-to-beat trivially. Why now? Our
`two_mul_card_sat` proof never used `p = 2` except in two `by decide` parity facts; abstracting
the involution to a `ZMod p`-orbit count is a direct generalization that immediately reuses
`two_mul_sum_value` and `exists_half` verbatim with `2` replaced by `p`.

### 4. SDP relaxation value of the triangle equals 1, exhibiting an unconditional gap ratio

Formalize the Goemans–Williamson vector relaxation for the triangle: assign unit vectors to
the three vertices at mutual angle `2π/3`, giving relaxed objective `3 · (1 - cos(2π/3))/2 =
9/4`, against the integral optimum `2`, for a gap ratio `8/9`. The key insight is that the
relaxation value is computed by an explicit, fully concrete Gram matrix, so the gap becomes a
finite real-arithmetic certificate rather than an analytic theorem. Why now? `triangle_gap`
already pins the integral side at exactly `2`; the relaxation side only needs three explicit
vectors in `EuclideanSpace ℝ (Fin 2)` and a `norm_num`/`Real.cos` computation, making the
first machine-checked MAX-CUT SDP integrality gap genuinely attainable in this codebase.

### 5. Gauge-quotient normal form makes satisfiability decidable in linear time

Prove that an all-distinct-endpoint instance is *fully* satisfiable iff its "constraint graph
with `ℤ/2` edge labels" admits a consistent potential, i.e. every cycle has even label sum,
and that this is checkable by a single spanning-forest pass. The key insight is that
`value_flipAll`'s gauge symmetry quotients the `2ⁿ` assignment space down to the cycle space
of the graph, so satisfiability depends only on `H¹` of the labelled graph — a first
cohomological invariant. Why now? We already isolated the gauge action and the affine model;
building the spanning-forest potential is standard `SimpleGraph`/`UnionFind`-style induction,
and it converts the existence theorem `exists_half` into a sharp dichotomy (`value = m` or a
provable deficit), the natural next milestone.
