# Future Directions: Boundedness and Density in the Order Type of the p-Degrees

## Synthesis

The order-theoretic core of the Cook–Reckhow program in this catalog has, over successive
cycles, been assembled from the simulation preorder `Simulates` on abstract proof systems
(`SimulationPreorder.lean`), the generic separation template and the antisymmetrized poset
of **p-degrees** (`SimulationDegrees.lean`), the lattice/height results
(`DegreeLattice.lean`: binary meets via `sumSystem`, the infinite increasing ladder
`powSystem`), and the width/bottom/density triple (`OrderType.lean`: an infinite antichain
`spikeSys`, a least degree `zeroSys`, and one density witness `interSys`).

This cycle adds two further coordinates of the order type, both `sorry`-free, and both
driven by the master reduction `simulates_sysOfSize_iff` (*simulation between size-indexed
systems is polynomial domination of size functions*):

* **Boundedness asymmetry** (`NoTopElement.lean`). The p-degrees over `ℕ` have a least
  element (`zeroSys_isBot`, established earlier) but provably **no greatest element**
  (`no_top : ∀ T, ¬ IsTop T`). The two facts are packaged as `bot_exists_no_top`. The
  obstruction is a *local-to-global diagonalisation*: any candidate top `T` would have to
  p-simulate the diagonal system whose size at theorem `t` is `2 ^ (sec t) + 2 ^ t`, where
  `sec t` is the local size datum `T` exposes at `t` (a chosen `T`-proof, via
  `Function.surjInv`). The uniform growth fact `poly_lt_exp_eventually`
  (`∃ M, ∀ m ≥ M, (m+2)^k < 2^m`) clamps `sec` to a finite range, after which the second
  summand `2^t` overruns any constant — the local data never glue into a global simulation
  (`not_dominated_diag`).

* **Density along the entire height ladder** (`LadderDensity.lean`). The single Fibonacci
  density witness `interSys` is generalised to **every rung** of the ladder: for each
  `k ≥ 1` there is a degree strictly between `powSystem k` and `powSystem (k+1)`
  (`exists_strictly_between_powSystem`). The witness `interPowSys k` is *parity-glued* —
  the faster rate `2^(n^(k+1))` on the even indices, the slower rate `2^(n^k)` on the odd
  indices — so it is super-polynomially above the lower rung yet too thin to recover the
  upper one. The enabling tool is `pow_pow_succ_gap_strong`, an all-large-`n` upgrade of
  `DegreeLattice.pow_pow_succ_gap` that frees the *parity* of the gap witness.

## Results Summary

| Result | Statement | File |
| --- | --- | --- |
| `poly_lt_exp_eventually` | `∀ k, ∃ M, ∀ m ≥ M, (m+2)^k < 2^m` (uniform exp ≻ poly) | `NoTopElement.lean` |
| `not_dominated_diag` | no monotone polynomial blow-up dominates `t ↦ 2^(s t)+2^t` | `NoTopElement.lean` |
| `no_top` | no proof system over `ℕ` is a greatest p-degree | `NoTopElement.lean` |
| `bot_exists_no_top` | the p-degrees have a least but no greatest element | `NoTopElement.lean` |
| `pow_pow_succ_gap_strong` | `∀ n ≥ c+2, (2^(n^k)+2)^c < 2^(n^(k+1))` for `k ≥ 1` | `LadderDensity.lean` |
| `interPowSys` | parity-glued intermediate size system | `LadderDensity.lean` |
| `powSystem_lt_interPow` / `interPow_lt_powSystem_succ` | the glued system is strictly between consecutive rungs | `LadderDensity.lean` |
| `exists_strictly_between_powSystem` | density at every rung of the height ladder | `LadderDensity.lean` |

Together with the earlier `powSystem_strictMono` (infinite height), `spikeSys_isAntichain`
(infinite width), `isGLB_sumSystem` (binary meets), and `zeroSys_isBot` (least element), the
poset of p-degrees is now known to be a meet-semilattice of infinite height and infinite
width, with a least element, no greatest element, and density throughout the height ladder.

## Research Directions

### 1. Density is total, not just on the ladder

We now have density at the Fibonacci separation (`interSys`) and at *every* ladder rung
(`interPowSys`). The bold conjecture is **total order density**: for every strictly
comparable pair of size-indexed systems `sysOfSize a < sysOfSize b` there is `sysOfSize c`
with `sysOfSize a < sysOfSize c < sysOfSize b`. It is falsifiable by exhibiting a *covering
pair* — comparable degrees with nothing strictly between.
**The key insight is** that both completed density proofs are the same parity-glueing
operator in disguise: given dominating-but-not-dominated `a < b`, the function equal to `b`
on the even indices and to `a` on the odd indices stays super-polynomially above `a` (the
even half keeps `b`'s rate) yet is too thin to recover `b` (the odd half collapses to `a`),
landing strictly between — exactly the local-to-global glueing that `interPowSys` realises,
now applied to an arbitrary gap rather than a named one.
**Why now?** The two halves of the argument are already isolated and reusable:
`polyBounded_of_le` (in `SimulationDegrees.lean`) discharges the "too thin to recover `b`"
direction as non-domination, and `pow_pow_succ_gap_strong` / `poly_lt_exp_eventually` supply
the separating gap uniformly in the argument, so total density reduces to a single parametric
lemma over the gap `a < b`.

### 2. The width lives inside the height: an antichain between two comparable degrees

`spikeSys` gives an infinite antichain, and `interPowSys` gives density; the natural fusion
is **an infinite antichain strictly between two comparable degrees** — e.g. infinitely many
pairwise incomparable p-degrees all lying strictly between `powSystem k` and
`powSystem (k+1)`. Falsifiable by showing some interval `(P, Q)` of the order is a chain.
**The key insight is** that the parity glueing of Direction 1 has infinitely many disjoint
"slots": instead of gluing `b` on the evens, glue it on the `i`-th 2-adic spike class
(`{n : v₂ n = i}`, the supports already used by `spikeSys_incomparable`) and `a` elsewhere;
distinct classes are disjoint and infinite, so the resulting degrees are pairwise
incomparable (one-point pinning of the blow-up at a class-specific witness) while all sitting
in the open interval `(a, b)`.
**Why now?** Every primitive is in place and already proven: the disjoint infinite supports
(`factorization_two_spike`), the incomparability mechanism (`spikeSys_incomparable`), and the
interval-membership machinery (`simulates_sysOfSize_iff` plus the uniform gap), so the
construction is a finite recombination rather than new theory.

### 3. The bottom is unique but the failure of a top is "uniform"

`zeroSys_isBot` and `no_top` together pin the boundedness type. Two sharper, falsifiable
follow-ups: (a) **the least degree is unique** — every `IsBot` system is p-equivalent to
`zeroSys`, so the bottom of the antisymmetrization poset is a single point; and (b)
**unboundedness is witnessed by a single cofinal ladder** — `powSystem` is *cofinal*, i.e.
every size-indexed degree is below some `powSystem k`. Claim (b) is falsifiable by a
size-indexed system dominating the whole `2^(n^k)` family.
**The key insight is** that `no_top` already produces, for each `T`, an explicit escapee
built from `T`'s own local size data; uniqueness of the bottom is the order-theoretic dual
(any two bottoms are mutually `≤`, hence `PEquiv`), while cofinality of `powSystem` would say
the *escapees can always be taken on the ladder* — a quantitative strengthening of `no_top`
asserting the ladder is not merely unbounded but cofinal.
**Why now?** `bot_exists_no_top` and `not_dominated_diag` localise exactly the growth
comparison needed, and the antisymmetrization poset with its `PartialOrder` is already
exposed, so uniqueness is pure order theory and cofinality is one domination estimate against
`2^(n^k)`.

### 4. Joins fail: the p-degrees are a meet-semilattice but **not** a lattice

We have binary meets (`isGLB_sumSystem`) but the dual is open here. The conjecture is that
**binary joins do not exist**: the incomparable `spikeSys 0` and `spikeSys 1` have minimal
common upper bounds that are pairwise incomparable, so no least one exists, making the
p-degrees a meet-semilattice that is provably not a lattice. Falsifiable by exhibiting an
explicit join for some incomparable pair.
**The key insight is** that an upper bound of two systems must be polynomially dominated by
*both* spike size functions on their disjoint 2-adic supports, and on those supports the two
spikes impose conflicting "small" requirements that admit many incomparable optimal
compromises rather than a unique minimum — the same one-point pinning that drives
`spikeSys_incomparable`, now run against a candidate join.
**Why now?** `simulates_sysOfSize_iff` turns "least upper bound" into an explicit `IsLUB`
statement about growth rates, and `polyMono_max` (in `DegreeLattice.lean`) exhibits the naive
candidate join, so refuting its minimality is a finite growth-class computation against the
spike supports rather than an open-ended search.

### 5. Order type of chains: countability from above, realisability from below

`powSystem_strictMono` gives one `ω`-chain and `no_top` shows chains never terminate at a
top. The conjecture pins the chain spectrum: **every well-ordered chain of size-indexed
p-degrees is countable (order type `< ω₁`), and every countable order type is realised** by
some chain. Falsifiable by an uncountable strictly increasing chain of size-indexed degrees.
**The key insight is** that a size-indexed degree is determined up to p-equivalence by the
polynomial-domination class of its size function in `ℕ → ℕ`, and these classes form a
countable structure under domination, so no uncountable strictly increasing chain can exist;
the diagonal/limit constructions behind `no_top` and `pow_pow_succ_gap_strong` realise the
countable types from below.
**Why now?** The domination characterisation reduces chains of degrees to chains of growth
rates in `ℕ → ℕ`, a setting where Mathlib's `Ordinal`/`Cardinal` API combines with the
uniform gap `poly_lt_exp_eventually` to bound order types from above and construct them from
below.
