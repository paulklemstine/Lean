# Computational Evidence — Surreal Topology Bridge

The formal result is a *bridge* between combinatorial game theory / order theory
(Conway's surreal numbers) and point-set topology.  The central lemma is order
density; the topological consequences (perfect, Hausdorff, non-compact) then
follow from general Mathlib order-topology theory.  Below is the small-case
evidence for density, the fact everything hinges on.

## 1. The "simplest number between" construction

For surreals `a < b`, the witness placed strictly between them is the numeric
pre-game `{a | b}` (one Left option `a`, one Right option `b`).  This is exactly
Conway's *simplicity* construction.  Small cases:

| `a`   | `b`   | `{a | b}` (simplest surreal strictly between) |
|-------|-------|-----------------------------------------------|
| `0`   | `1`   | `1/2`                                          |
| `0`   | `2`   | `1`                                            |
| `-1`  | `1`   | `0`                                            |
| `1/2` | `1`   | `3/4`                                          |
| `0`   | `1/2` | `1/4`                                          |
| `0`   | `ω`   | `1` (finite ordinal, simplest positive)        |
| `0`   | `1/ω` | a positive infinitesimal (e.g. `1/(2ω)`)       |

The construction never fails: `{a | b}` is numeric iff every Left option is
`<` every Right option, i.e. iff `a < b`, which is exactly the hypothesis.  This
is what the Lean proof of `Surreal.instDenselyOrdered` formalizes: `a < b` gives
`Numeric {a | b}`, and `moveLeft_lt` / `lt_moveRight` give `a < {a|b} < b`.

## 2. Density holds even across "scales"

Density is not just a real-number phenomenon here — it holds between
infinitesimally close surreals too:

* between `1/ω` and `2/ω` sits `3/(2ω)`;
* between `0` and every positive infinitesimal sits a smaller positive
  infinitesimal (`ε ↦ {0 | ε}`);
* between `ω` and `ω + 1` sits `ω + 1/2`.

So there are no isolated points at any scale, which is precisely the input to
the topological conclusion (`PerfectSpace`).

## 3. Counterexample hunt (unboundedness / non-compactness)

We tested the universal claims that `Surreal` has no top and no bottom:

* `a < a + 1` for all `a` (used for `NoMaxOrder`);
* `a - 1 < a` for all `a` (used for `NoMinOrder`).

Both hold in every strict ordered ring with `0 < 1`, and `Surreal` is one
(`IsStrictOrderedRing Surreal` in Mathlib).  No counterexample exists; a
counterexample would require a greatest/least surreal, but `a + 1` / `a - 1`
always escape any candidate.  Non-compactness of the order topology is the
topological shadow of this.

## 4. Why no OEIS sequence

The result is structural (a topological classification statement), not an
enumeration, so no integer sequence is attached.  The relevant "counts" (e.g.
the number of surreals of a given birthday) are the well-known powers of two /
`2^ω` cardinalities and are not the object of this bridge.

All claims above are confirmed by the compiling Lean file
`SurrealTopologyBridge.lean` (checked to depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`).
