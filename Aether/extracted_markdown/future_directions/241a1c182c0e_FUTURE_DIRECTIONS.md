# Future Directions — Unstoppable Self-Maps (Geometry)

Follow-up conjectures for the theme *"Self-modifying code that cannot be stopped"*,
based on `Geometry/Unstoppable.lean` (the **drift criterion** for aperiodicity and
its finite-state converse). Each is stated to be directly formalizable and
falsifiable in Lean 4 / Mathlib.

## Conjecture 1 — Drift criterion is complete on the line
**Statement.** Let `f : ℝ → ℝ` be continuous and monotone. Then `f` is
`Unstoppable` (no periodic points) **iff** it admits a continuous drift coordinate,
equivalently iff `f x ≠ x` for all `x` and `f x - x` has constant sign. More
sharply: a fixed-point-free continuous `f : ℝ → ℝ` is unstoppable, and conversely
any continuous self-map of `ℝ` with a fixed point halts there.
**Test.** Formalize `Unstoppable f ↔ ∀ x, f x ≠ x` for continuous `f : ℝ → ℝ`
using the intermediate value theorem on `f^[n] x - x`.
**Falsifier.** A continuous fixed-point-free `f : ℝ → ℝ` with a genuine periodic
orbit (would refute; conjecture predicts none exist).

## Conjecture 2 — Quantitative escape rate from drift
**Statement.** If `φ (f x) = φ x + c` with `c > 0` and `φ` is `K`-Lipschitz for a
metric `d`, then `d (f^[n] x, x) ≥ (|c|/K) · n`; hence the orbit is a
*quasi-isometric* embedding of `ℕ` and escapes every bounded set in finite time.
**Test.** Prove `dist (f^[n] x) x ≥ (c / K) * n` from `phi_iterate` and the
Lipschitz bound `|φ a - φ b| ≤ K · dist a b`.
**Falsifier.** A drifting `f` with Lipschitz `φ` whose orbit stays bounded.

## Conjecture 3 — Group-theoretic dichotomy for affine maps
**Statement.** An invertible affine map `f x = A x + b` of a finite-dimensional
real inner-product space is `Unstoppable` **iff** `b` is not in the range of
`A - I` (i.e. the affine fixed-point equation `(A - I) x = -b` has no solution).
When `A = I` this recovers `translate_unstoppable`; when `A` is a rotation with
`1 ∉ spectrum A`, the map always has a fixed point and halts.
**Test.** Formalize `Unstoppable f ↔ (-b) ∉ Set.range (A - 1)` for `f x = A x + b`.
**Falsifier.** An affine map with `(A-I)` surjective yet unstoppable, or with a
fixed point yet unstoppable.

## Conjecture 4 — Subexponential orbit growth forces a periodic point
**Statement.** (Compactness/recurrence converse.) If `X` is a compact metric
space and `f : X → X` is continuous, then `f` is **not** `Unstoppable`: every
continuous self-map of a nonempty compact metric space has a recurrent — in the
topological sense, almost-periodic — orbit, and on finite-dimensional compacta a
genuine periodic point in many cases. Minimal testable core: a continuous self-map
of `[0,1]` (or `S¹` with rational rotation number) always halts.
**Test.** Prove `¬ Unstoppable f` for continuous `f : Set.Icc (0:ℝ) 1 → ...`
via Brouwer fixed point, strengthening `not_unstoppable_of_finite` from finite to
compact.
**Falsifier.** A continuous fixed-point/periodic-point-free self-map of a compact
interval (Brouwer forbids it).

## Conjecture 5 — Cocycle drift and unstoppable group actions
**Statement.** A free action is the group-level analogue of unstoppability. If a
group `G` acts on `X` and admits a nonzero homomorphism-twisted cocycle
`φ : X → ℝ` with `φ (g • x) = φ x + χ(g)` for a nontrivial character `χ`, then
every `g` with `χ(g) ≠ 0` acts without periodic points. Conjecture: for
`G = ℤ` this is *equivalent* to the drift criterion, and the set of unstoppable
generators is exactly `{g : χ(g) ≠ 0}`.
**Test.** Generalize `unstoppable_of_drift` to a `χ`-twisted cocycle and recover
`unstoppable_iterate_of_drift` as the `χ(g) = c` special case.
**Falsifier.** A cocycle action with `χ(g) ≠ 0` admitting a periodic point.
