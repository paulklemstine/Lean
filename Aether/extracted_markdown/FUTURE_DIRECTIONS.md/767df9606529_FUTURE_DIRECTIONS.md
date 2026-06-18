# Future Directions — Tropicalized Arithmetic Height on Berggren Transfer Boundaries

## Synthesis

This cycle fused two previously isolated strands of the catalog into a single
cross-domain object. From `Bridges/ArithmeticVCDimension.lean` we took the rational
arithmetic-height functional `ratArithHeight` together with its positivity facts
(`ratArithHeight_pos`, `ratArithHeight_ge_one`); from
`Bridges/BerggrenTransferDuality.lean` we took the prefix-closed boundary calculus
(`prefixClosed`, `finiteBerggrenSubtree`, `boundaryWords`, `boundaryWords_finite`).
The bridge is the functional `boundaryHeight param`, which aggregates the heights of the
rational transfer data attached to a finite set of Berggren boundary channels.

The central conceptual claim — and the reason this is a genuine *bridge* rather than two
results sitting side by side — is that `boundaryHeight` is simultaneously:

* **monotone** under channel-set / subtree inclusion (`boundaryHeight_mono`,
  `subtreeHeight_mono`),
* **tropically subadditive**: the de-tropicalized `H(s ∪ t) ≤ H(s) + H(t)`
  (`boundaryHeight_subadditive`) lifts *verbatim* to a tropical *submultiplicativity*
  `trop H(s ∪ t) ≤ trop H(s) ⊗ trop H(t)` in `Tropical ℕ`
  (`boundaryHeight_trop_submul`), and
* **certified**: bounded below by the channel count and above by `card · maxHeight`
  (`boundaryHeight_certificate`, `subtreeBoundaryHeight_certificate`).

These three properties are exactly the axioms of the abstract `TropicalBoundaryValuation`
structure, of which `boundaryHeight` is shown to be an instance
(`boundaryHeight_valuation`). This is the boundary/height analogue of the
`max`-additive law `ValuationDepthMeasure.vdepth_sum_le` from
`Computation/PadicValuationDepth.lean`: the Berggren boundary plays the role of the
computation graph, and arithmetic height plays the role of valuation depth.

## Results Summary

* `boundaryHeight`, `subtreeHeight`, `subtreeBoundaryHeight` — the new aggregators.
* `boundaryHeight_mono`, `boundaryHeight_mono_param`, `subtreeHeight_mono` — monotonicity.
* `card_le_boundaryHeight`, `boundaryHeight_le_card_mul`, `boundaryHeight_certificate`,
  `subtreeBoundaryHeight_certificate` — the two-sided computable certificate.
* `boundaryHeight_subadditive`, `boundaryHeight_trop_submul` — the core tropical bridge.
* `TropicalBoundaryValuation` + `boundaryHeight_valuation` +
  `TropicalBoundaryValuation.trop_submul` — abstract packaging.

All main results compile with `sorry = 0` and depend only on the standard axioms
`propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Exact intersection defect and an inclusion–exclusion height law

The proof of `boundaryHeight_subadditive` discards the intersection term of
`Finset.sum_union_inter`. The discarded quantity `boundaryHeight param (s ∩ t)` is itself a
meaningful "shared-channel height", so subadditivity is an *equality up to a measurable
defect*: `H(s ∪ t) + H(s ∩ t) = H(s) + H(t)`. Conjecture: `boundaryHeight` is a
**modular** (valuation-in-the-lattice-theoretic-sense) functional on the Boolean lattice of
channel `Finset`s, i.e. it extends to a finitely additive measure, and the tropical lift is
a modular function into `Tropical ℕ`. The key insight is that arithmetic height is a *sum*
of strictly positive atoms, so the only obstruction to full additivity is overlap, which is
exactly the inclusion–exclusion term — making the height a bona fide lattice valuation, not
merely a subadditive one. Why now? `Finset.sum_union_inter` already gives the equality for
free; the remaining work is purely to phrase modularity and connect it to Mathlib's
existing lattice-valuation API, which is a short, falsifiable target.

### 2. Strict monotonicity and a Northcott-style finiteness certificate

`boundaryHeight_mono` is non-strict. Conjecture: adding a *genuinely new* boundary channel
strictly increases the height, `s ⊊ t → boundaryHeight param s < boundaryHeight param t`,
because every channel contributes at least `1` (this is `ratArithHeight_ge_one`).
Consequently, for any bound `N` only finitely many channel sets satisfy
`boundaryHeight param s ≤ N` — a discrete **Northcott finiteness** statement for Berggren
boundaries. The key insight is that strict positivity of `ratArithHeight` turns the height
into a proper, coercive function on the (infinite) lattice of boundary sets, so sublevel
sets are finite exactly as Weil-height sublevel sets are finite in Diophantine geometry.
Why now? The strict-monotonicity step is `Finset.sum_lt_sum_of_subset` plus the existing
positivity lemma, and it immediately unlocks the finiteness/codebook interpretation already
motivated in `ArithmeticVCDimension.lean`.

### 3. Functoriality under rooted tree isomorphisms

`BerggrenTransferDuality.lean` defines `RootedIso` between word-sets. Conjecture: the
boundary height is a **rooted-iso invariant** up to relabelling of the transfer datum,
`subtreeBoundaryHeight (param ∘ φ.inv) (φ-image of B) = subtreeBoundaryHeight param B` for a
rooted isomorphism `φ`. The key insight is that `boundaryHeight` only ever sees the
*multiset* of attached rational data, never the words themselves, so any bijection of
boundary channels that transports the datum preserves the height — making height a genuine
invariant of the abstract scattering object rather than of its coordinatisation. Why now?
The `RootedIso` structure and `boundaryWords` are already in place, and the proof reduces to
`Finset.sum_bij`, a single well-supported Mathlib combinator.

### 4. Depth-graded (spectral-shell) refinement of the height

`spectral_shell_decomposition` stratifies a finite subtree by depth. Conjecture: the
boundary height decomposes as a finite sum over depth shells,
`boundaryHeight = ∑ d, (height of the depth-d boundary slice)`, and the per-shell heights
are themselves a tropically subadditive sequence in `d`, connecting to
`Bridges/SubadditiveSequenceBridge.lean`. The key insight is that depth gives an orthogonal
grading of the channel set into disjoint slices, so additivity over the grading is exact
(`Finset.sum_biUnion` over disjoint shells) while the *shell-to-shell* growth inherits the
tropical inequality — turning a single number into a Newton-polygon-like height profile.
Why now? The shell decomposition theorem already exists, so the grading is available; only
the disjoint-union sum identity and the sequence-level subadditivity remain.

### 5. A pseudo-dimension bound driven by boundary height (closing the VC loop)

The original motivation of `ArithmeticVCDimension.lean` is "height control ⇒ finite traces
⇒ bounded shattering". Conjecture: a uniform per-channel height bound `M` together with the
certificate `boundaryHeight ≤ card · M` yields an explicit upper bound on the number of
distinct transfer traces realisable by a finite Berggren subtree, and hence a
Sauer–Shelah-style pseudo-dimension surrogate for Berggren-parameterised hypothesis classes.
The key insight is that `boundaryHeight_certificate` is precisely the "finite arithmetic
codebook size" quantity that the VC pipeline consumes, so the bridge built here is the
missing arithmetic input to the learning-theoretic conclusion. Why now? Both endpoints —
the height certificate (this file) and the trace-counting machinery
(`ArithmeticVCDimension.lean`) — are now formalised, so the remaining step is a finite
counting argument linking `card · M` to trace multiplicity.
