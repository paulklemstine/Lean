# Future Directions: Phantom Topologies

This cycle established the foundational layer of *phantom topology* in
`Catalog/Novelty/PhantomTopology.lean`. The phantom number of a topology `τ` on a type
`X` is the minimum cardinality of a family of strictly **finer** topologies whose
*consensus* (the topology whose open sets are open for every observer, i.e. the supremum
`⨆ o, T o` in Mathlib's lattice of topologies) equals `τ`.

The proven, `sorry`-free anchors for everything below are:

- `threeOpen` and `isOpen_threeOpen_iff` — the atom whose only open sets are `∅`, `A`,
  `univ`, with the explicit verification of the topology axioms.
- `complementary_consensus_eq_top` — for a proper nonempty `A`, the consensus of the
  complementary pair `threeOpen A`, `threeOpen Aᶜ` is the indiscrete topology `⊤`.
- `threeOpen_lt_top` — each atom is *strictly finer* than `⊤`.
- `complementary_isPhantomRepresentation` — the pair is a genuine phantom representation
  of `⊤`, so the indiscrete topology has phantom number `≤ 2`.
- `consensus_pullback_surjective`, `consensus_pullback_le` — functoriality of consensus.
- `not_isPhantomRepresentation_bot` — the discrete topology is phantom-rigid.

## 1. The indiscrete phantom number is exactly 2

We proved phantom number `≤ 2` for the indiscrete topology `⊤` on any type carrying a
proper nonempty subset (`complementary_isPhantomRepresentation`). The matching lower
bound is missing: a single strictly finer topology `T` with `consensus T = ⊤` would have
to satisfy `T = ⊤` and `T < ⊤` simultaneously, which is impossible.

**Conjecture.** For `X` with at least two points, the phantom number of `⊤` is exactly
`2`: there is no phantom representation indexed by a one-element observer set.

The key insight is that a singleton-indexed consensus is just the single observer
topology itself (`consensus (fun _ : Unit => T) = T`), so demanding both `T < ⊤` and
`consensus = ⊤` is a direct contradiction with `lt_irrefl`. This converts the lower
bound into a one-line lattice fact, complementing the constructive upper bound already
in hand.

**Why now?** `not_isPhantomRepresentation_bot` already packages the "nothing is strictly
finer" pattern; the same `lt_irrefl`/`not_lt` reasoning applied to a `Unit`-indexed
family closes the gap with no new infrastructure.

## 2. Finite phantom numbers from complementary chains

`complementary_consensus_eq_top` recovers `⊤` from two atoms. For a general non-discrete
finite topology `τ` one expects to need more, but still finitely many, observers.

**Conjecture.** For a finite type `X` with `|X| = n`, every topology `τ ≠ ⊥` (non-
discrete) has phantom number at most `n − 1`, realized by atoms of the form
`threeOpen U` for `τ`-open `U` together with their point-separating complements.

The key insight is that the join of all atoms `threeOpen U` over `τ`-open `U` reconstructs
`τ` exactly (`τ = ⨆_{U open} threeOpen U`), and on a finite carrier only finitely many
distinct atoms occur; pruning to a subfamily whose join is still `τ` gives the bound.
Each atom is strictly finer than `τ` precisely when `U` is a proper nonempty `τ`-open set,
which `threeOpen_lt_top` already characterizes.

**Why now?** The atom/consensus machinery is proven and the join-of-atoms identity is a
direct generalization of the two-atom computation; Mathlib's `Fintype` and `Finset.sup`
provide the finiteness bookkeeping needed to extract the `n − 1` bound.

## 3. The rigidity dichotomy: phantom-finite ⇔ not T₁

We proved the discrete topology `⊥` is phantom-rigid (`not_isPhantomRepresentation_bot`)
and the indiscrete `⊤` is phantom-finite (number `≤ 2`). These are the two extremes of a
conjectured dichotomy.

**Conjecture.** A topology on `X` has a finite phantom representation if and only if it
is **not** T₁. Equivalently, T₁ spaces are exactly the phantom-rigid ones.

The key insight is that failure of T₁ produces a pair of points `x ≠ y` with `y` in the
closure of `{x}`, and the atom `threeOpen {z | x ⤳ z}` (the specialization down-set)
together with a complementary atom realizes a finite phantom pair generalizing the
complementary-singleton construction; conversely T₁ forces every proper refinement to be
"independent", obstructing finite reconstruction.

**Why now?** The complementary-atom template is proven and Mathlib's `T1Space` /
`specializes` API gives a clean handle on the specialization preorder, so both
directions reduce to manipulating atoms whose behaviour we have already formalized.

## 4. Consensus as global sections of an observer sheaf

`consensus_pullback_surjective` shows consensus is invariant under surjective re-indexing
of observers — the first functoriality property of the assignment
`O ↦ consensus_O`. This is the shadow of a sheaf-theoretic structure.

**Conjecture.** When the observer space `O` carries its own topology and the assignment
`o ↦ T o` is "continuous" (for each fixed `U`, the set of observers seeing `U` as open is
open in `O`), the consensus topology is the global-sections topology of a sheaf of open-
set lattices on `O`, and the locality/gluing axioms hold: a set open for every observer
in an open cover of `O` is consensus-open.

The key insight is that `isOpen_consensus_iff` (`U` consensus-open ⇔ `∀ o, U` open for
`o`) is literally the global-sections condition of the presheaf `o ↦ {open sets of T o}`,
so the consensus already *is* a section functor; `consensus_pullback_surjective` is the
restriction-along-surjections compatibility a sheaf must satisfy.

**Why now?** With functoriality proven and `isOpen_consensus_iff` exposing the
section description, the remaining work is to phrase the continuity hypothesis and invoke
Mathlib's `Mathlib.Topology.Sheaves` infrastructure, rather than to build new
order-theoretic foundations.

## 5. Phantom entropy and the width of the refinement interval

The phantom *number* counts observers; a finer invariant weighs them. Define the
*phantom entropy* of `τ` as the infimum of `log₂ |O|` over all phantom representations
`T : O → TopologicalSpace X` of `τ`.

**Conjecture.** For finite `X`, the phantom entropy of `τ` equals `log₂ w`, where `w` is
the width (maximum antichain size, by Dilworth) of the interval `[τ, ⊥]` in the lattice
of topologies — the largest family of pairwise-incomparable topologies strictly finer
than `τ`.

The key insight is that `consensus_pullback_le` shows enlarging the observer family can
only refine the consensus, so a *minimal* representation uses pairwise-incomparable
observers — an antichain in `[τ, ⊥]` — and the minimum size of an antichain whose join is
`τ` is governed by Dilworth's theorem applied to the refinement interval.

**Why now?** The pullback monotonicity lemma already isolates incomparability as the
relevant minimality condition, and computing widths of `[τ, ⊥]` for `|X| ≤ 4` is feasible
with `Fintype`/`Finset` enumeration, giving concrete data to calibrate the entropy
formula before attempting the general Dilworth argument.
