# Future Directions: The Full Order Type of the p-Degrees

## Synthesis

The order-theoretic core of the Cook–Reckhow program in this catalog has, over successive
cycles, been assembled from the simulation preorder `Simulates` on abstract proof systems
(`Catalog/Logic/ProofComplexity/SimulationPreorder.lean`), the generic separation template
and the antisymmetrized **poset of p-degrees**
(`.../SimulationDegrees.lean`), and the lattice/height results
(`.../DegreeLattice.lean`: binary meets via `sumSystem`, an infinite increasing chain
`powSystem`). This cycle adds the three remaining coordinates needed to talk about the
*order type* of the p-degrees, all in `.../OrderType.lean` and all `sorry`-free:

* **Infinite width.** The 2-adic valuation partitions `ℕ` into infinitely many infinite
  "spike sets"; placing an exponential spike `2^n` on the `i`-th set yields pairwise
  *incomparable* systems `spikeSys i` (`spikeSys_incomparable`), giving an injective
  infinite antichain in the poset (`spikeSys_isAntichain`, `spikeSys_pdegrees_injective`).
* **A least p-degree.** The size-`0` system `zeroSys` simulates *every* proof system over
  `ℕ` (`simulates_zeroSys`), hence is a bottom element (`zeroSys_isBot`), strictly below the
  whole height ladder (`zeroSys_lt_lin`).
* **Density at the Fibonacci separation.** A parity-thinned size function (Fibonacci on the
  evens, linear on the odds) is a degree strictly between `linSystem` and `fibSystem`
  (`exists_strictly_between_lin_fib`).

The unifying engine is the domination characterisation `simulates_sysOfSize_iff`:
simulation between size-indexed systems is *polynomial domination of size functions*. Width,
height, the bottom, and density are all read off as elementary growth-class facts, with the
single analytic input `exp_dominates_poly` (exponential beats polynomial).

## Results Summary

| Result | Statement | File |
| --- | --- | --- |
| `exp_dominates_poly` | `∀ a k, ∃ m, (2m+a)^k < 2^m` | `OrderType.lean` |
| `simulates_zeroSys` / `zeroSys_isBot` | the size-`0` system is a least p-degree | `OrderType.lean` |
| `zeroSys_lt_lin` | the bottom is strictly below `linSystem` | `OrderType.lean` |
| `spikeSys_incomparable` | spike systems are pairwise incomparable | `OrderType.lean` |
| `spikeSys_isAntichain` / `_pdegrees_injective` | an infinite antichain of p-degrees (infinite width) | `OrderType.lean` |
| `exists_incomparable_pair` | the simulation order is not total | `OrderType.lean` |
| `exists_strictly_between_lin_fib` | density witness between `lin` and `fib` | `OrderType.lean` |

Together with the earlier `powSystem_strictMono` (infinite height) and `isGLB_sumSystem`
(binary meets), the poset of p-degrees is now known to be a meet-semilattice of infinite
height and infinite width, with a least element and at least one density witness.

## Research Directions

### 1. Joins fail: the p-degrees are a meet-semilattice but **not** a lattice

We proved binary meets exist (`isGLB_sumSystem`) via the "run either system" direct sum. The
bold conjecture is that **binary joins do not exist**: there is a pair of proof systems
`P, Q` with no least upper bound in the simulation preorder, so the p-degrees form a
meet-semilattice that is provably *not* a lattice. A concrete falsifiable target: the two
incomparable spike systems `spikeSys 0` and `spikeSys 1` have *minimal* common upper bounds
that are pairwise incomparable, so no single least one exists.
**The key insight is** that an upper bound must simultaneously be at least as *strong* as
both systems — i.e. have a size function pointwise polynomially dominated by *both* spikes —
and on the disjoint supports the two spikes force conflicting "small" requirements that admit
many incomparable optimal compromises rather than a unique minimum, exactly the failure mode
that the one-point pinning argument behind `spikeSys_incomparable` already exposes.
**Why now?** The domination characterisation `simulates_sysOfSize_iff` turns "least upper
bound" into an explicit `IsLUB` statement about growth rates, and `polyMono_max` (already in
`DegreeLattice.lean`) shows what the *naive* candidate join looks like, so refuting its
minimality is a finite growth-class computation rather than an open-ended search.

### 2. Sacks-style density everywhere, not just at one witness

`exists_strictly_between_lin_fib` is a single density witness. The conjecture is full
**order density**: for *every* strictly comparable pair `P < Q` of size-indexed systems
there is an `R` with `P < R < Q`. Falsifiable by exhibiting a covering pair (a `P < Q` with
nothing strictly between).
**The key insight is** that the parity-thinning trick used for the witness generalises to an
*interpolation operator*: given size functions `a < b` (in the domination order), the
function agreeing with `b` on a suitably sparse arithmetic-progression of indices and with
`a` elsewhere is super-polynomially above `a` yet too thin to recover `b`, landing strictly
between — the density analogue of the Sacks/Ladner diagonalisation, but reduced to elementary
growth bookkeeping.
**Why now?** We already have the two halves of every such argument in reusable form:
`polyBounded_of_le` collapses the "too thin to recover `b`" direction to non-domination, and
`exp_dominates_poly` supplies the separating gap, so density becomes a single parametric
lemma over the gap between `a` and `b`.

### 3. Universality: every countable poset embeds into the p-degrees

Combining infinite height, infinite width, meets, and density suggests the strongest
structural statement: **every countable partial order order-embeds into the poset of
p-degrees.** This is falsifiable — a single countable poset that fails to embed would refute
it.
**The key insight is** that the disjoint 2-adic spike supports give independent "coordinate
axes" (each `spikeSys` family living on its own valuation class), so an arbitrary countable
poset can be encoded by assigning each element a tailored superposition of spikes whose
mutual domination pattern mirrors the target order — incomparabilities handled by disjoint
supports (as in `spikeSys_incomparable`) and comparabilities by nested growth rates (as in
`powSystem_strictMono`).
**Why now?** Mathlib has the order-embedding API (`OrderEmbedding`) and the antisymmetrization
poset is already exposed with its `PartialOrder` instance; the remaining work is purely the
combinatorial encoding of a countable order into growth rates, for which every primitive
(spikes, ladders, domination characterisation) is now in place.

### 4. The bottom element is an artifact of dropping poly-time `proves`

`zeroSys_isBot` exhibits a least p-degree, but `zeroSys` "proves" theorem `n` by the proof
`n` at size `0` — legitimate only because the abstraction dropped the Cook–Reckhow
requirement that `proves` be polynomial-time computable. The conjecture: **in a refined model
that re-imposes a computable/honest `proves`, the least element disappears (or collapses to a
specific natural system).** Falsifiable by either constructing an honest universal-simulator
bottom, or proving every honest system is strictly simulated by another.
**The key insight is** that `#print axioms` localises exactly where size-`0` magic enters:
the bottom uses an uncomputable surjection-witness, so re-attaching a size lower bound tied to
the *description length* of `proves` (a Kolmogorov-style floor) should make `zeroSys`
inadmissible and force a genuine infimum question.
**Why now?** The current development cleanly separates the size layer from the `proves` layer
in the `ProofSystem` structure, so adding a computability/honesty field is a conservative
extension that reuses every order-theoretic lemma above verbatim on the admissible
sub-preorder.

### 5. The exact height is `ω`, and cofinality questions

`powSystem_strictMono` gives an `ω`-chain. The conjecture pins the *order type of chains*:
**every well-ordered chain of size-indexed p-degrees has order type `< ω₁` (is countable),
and there exist chains of every countable order type**, so the suprema/cofinality structure
of the p-degrees matches that of the countable growth-rate hierarchy.
**The key insight is** that a size-indexed degree is determined up to p-equivalence by the
polynomial-equivalence class of its size function, and these classes form a countable
structure under domination, so no uncountable strictly increasing chain can exist while the
diagonal/limit constructions realise every countable type.
**Why now?** The domination characterisation reduces chains of degrees to chains of growth
rates in `ℕ → ℕ`, a setting where Mathlib's `Ordinal`/`Cardinal` machinery and the existing
`exp_dominates_poly` gap lemma can be combined to bound order types from above and construct
them from below.
