# Future Directions — Borsuk–Ulam ⇄ Arrow (Social Choice Is Topology)

Derived from the cycle in `Computation/BorsukUlamArrow.lean` and
`Computation/BorsukUlamArrowDichotomy.lean`. Each conjecture is falsifiable in
Lean 4.

## What this cycle established (basis for the conjectures below)

- 1-D Borsuk–Ulam (`borsuk_ulam_one_dim`) is provable directly from the
  Intermediate Value Theorem (Bridges domain).
- No continuous, `2π`-periodic, reversal-respecting, decisive social welfare
  function exists (`no_continuous_decisive_swf`).
- Dropping continuity restores possibility: the square wave
  `socialWave θ = (-1)^⌊θ/π⌋` is decisive and reversal-respecting
  (`decisive_reversal_swf_exists`), and is therefore *provably discontinuous*
  via the impossibility theorem (`socialWave_not_continuous`).
- The obstruction is the algebraically free `ZMod 2` antipodal involution
  (`borsuk_ulam_arrow_bridge`, reusing `Impossibility/Core.zmod_add_free`).

---

## Conjecture 1 — Higher-dimensional simultaneous ties (full Borsuk–Ulam)

For a continuous `F : S^{n} → ℝ^{n}` with `F(-x) = -F(x)` (antipodal/odd), there
is a single `x` with `F(x) = 0` — all `n` coordinates tie *simultaneously*. The
1-D file only ties coordinates independently.

The key insight is... coordinatewise IVT is too weak; simultaneous vanishing is
exactly the content of full Borsuk–Ulam, so the social-choice corollary "all
pairwise margins tie at one profile" is genuinely `n`-dimensional topology.

Why now? Mathlib has no Borsuk–Ulam theorem at all; building even the `S^2 → ℝ^2`
case (e.g. via degree theory or `ℤ/2`-equivariant cohomology of spheres) would be
the first formalization and would upgrade `no_continuous_decisive_swf` to genuine
multi-alternative Arrow.

## Conjecture 2 — Continuity is the *unique* obstructed axiom

Among {continuity, periodicity, reversal, decisiveness}, exactly one cannot be
dropped-and-restored: removing continuity restores a model (proved), and we
conjecture removing *any other single axiom* also restores a model, while keeping
all four is contradictory.

The key insight is... the impossibility is a single topological cut, so each of
the other three axioms should be individually inessential — a "minimal
unsatisfiable core" of size dictated solely by topology.

Why now? We already have the discontinuous witness; constructing the three
remaining witnesses (non-periodic, non-reversing, indecisive) is elementary and
would formally certify that `Continuous` is load-bearing and the others are not.

## Conjecture 3 — The tie set is a nonempty closed antipode-stable subset

For continuous reversal-respecting `swf`, the tie set `{θ | swf θ = 0}` is
nonempty (proved), closed, and invariant under `θ ↦ θ + π`; moreover its image in
the circle has cardinality ≥ 2.

The key insight is... antipode-stability (`tie_set_antipodal`) plus continuity
forces the zero set to be a `ℤ/2`-invariant closed set, so a *single* tie is
impossible — ties always come in antipodal pairs.

Why now? `tie_set_antipodal` is already proved; closedness is `IsClosed`
of a preimage of `{0}`, and the pairing follows immediately, so this is a short
next step that sharpens the impossibility into a structural statement.

## Conjecture 4 — Equivariant reformulation: no `ℤ/2`-map `S¹ → S⁰`

`no_continuous_decisive_swf` is equivalent to: there is no continuous
`ℤ/2`-equivariant map from the antipodal circle to `S⁰ = {±1}`. This connects the
analytic statement to `Impossibility/Core.lean`'s equivariant framework.

The key insight is... a decisive reversal-respecting `swf` normalizes to a map
into `{±1}` intertwining the two free `ℤ/2` actions; its nonexistence is
`no_equivariant_constant`-style freeness made continuous.

Why now? The algebraic half (`zmod_add_free`, `no_equivariant_constant`) already
exists in the catalog; formalizing `S⁰` as `{±1}` with the sign action and the
equivalence would unify the analytic and algebraic impossibility statements into
one theorem.

## Conjecture 5 — Chichilnisky continuity bound

For continuous, anonymous, unanimous social choice on the `m`-sphere of
preferences, an impossibility holds iff `m ≥ 1`; for `m = 0` (two profiles) a
rule exists. The threshold is the connectivity of the preference space.

The key insight is... the impossibility is governed by whether the preference
space is connected/has nontrivial `ℤ/2`-action, exactly as the IVT (connectivity)
drove the 1-D proof here — so the boundary is `m = 0` vs `m ≥ 1`.

Why now? With the 1-D case fully formalized, isolating the connectivity
hypothesis (`PreconnectedSpace`) used in `borsuk_ulam_one_dim` and exhibiting the
`m = 0` counterexample would give the first formal Chichilnisky-style threshold
theorem.
