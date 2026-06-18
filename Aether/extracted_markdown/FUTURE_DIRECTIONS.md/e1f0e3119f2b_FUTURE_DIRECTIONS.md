# Future Directions: Dream Logic and Paraconsistent Reasoning

## Synthesis

This cycle established a small but load-bearing bridge between two worlds. On the
*algebraic* side, `Logic.DreamLogic.BelnapAlgebra` realizes Belnap's FOUR as a genuine
bounded **distributive lattice** (`DistribLattice`, `BoundedOrder` with `⊥ = F`, `⊤ = T`)
with a De Morgan involution `neg`, and isolates paraconsistency as a single algebraic
fact: `paraconsistency_iff_glut` says non-explosion is *equivalent* to the existence of a
designated glut, whose unique witness is `B` (`glut_iff_B`); dually `N` is the unique gap
(`gap_iff_N`). On the *topological* side, `Logic.DreamLogic.DreamSpace` introduces
**dream spaces** — families of opens closed under finite intersection but not arbitrary
unions — and proves the canonical finite-or-univ dream space on `ℕ` is genuinely
non-topological (`dreamNat_not_topological`), witnessed by the evens
(`evens_not_dreamOpen`). `Logic.DreamLogic.Bridge` fuses them: a Belnap valuation's
**glut locus** `{n | IsGlut (v n)}` equals `{n | v n = B}` (`glut_locus_eq`), and the very
same evens counterexample yields a paraconsistent valuation whose glut locus is *not*
dream-open (`exists_valuation_glut_locus_not_dreamOpen`). The metalogical defect and the
topological defect are literally one set.

## Results Summary

* `paraconsistency_iff_glut`, `not_explosive` — paraconsistency = existence of a glut.
* `glut_iff_B`, `gap_iff_N` — unique glut `B`, unique gap `N`.
* `neg_neg`, `neg_antitone`, `neg_inf`, `neg_sup` — `neg` is an order-reversing De Morgan involution.
* `DistribLattice Belnap`, `BoundedOrder Belnap`, `card_four` — FOUR is the 4-element bounded distributive lattice.
* `dreamNat_not_topological`, `evens_not_dreamOpen` — dream spaces strictly generalize topologies.
* `glut_locus_eq`, `constB_glut_locus_open`, `exists_valuation_glut_locus_not_dreamOpen` — the bridge.

## Direction 1: Glut-preservation under lattice homomorphisms

Characterize which lattice homomorphisms `φ : Belnap → L` into a bounded distributive
lattice with designation `D ⊆ L` preserve paraconsistency. **Conjecture:** `φ` transports
non-explosion iff `φ B` is a glut in `L` (both `φ B` and its `L`-negation are designated).
The key insight is that `paraconsistency_iff_glut` localizes all of paraconsistency at the
single element `B`, so preservation should reduce to the image of `B` alone, turning a
metalogical property into a one-point algebraic side condition. Why now? The
`DistribLattice Belnap` instance and `glut_iff_B` give exactly the source object and the
"glut detector" needed to state and check the morphism condition by `decide` on the
four-element domain.

## Direction 2: The topological completion of `dreamNat` is discrete

Define the completion `D⁺` of a dream space by closing its opens under arbitrary unions,
and the **defect** as the cardinality of the newly-opened sets. **Conjecture:** for
`dreamNat`, `D⁺` is the discrete topology on `ℕ` and the defect has cardinality `2^ℵ₀`.
The key insight is that arbitrary unions of finite sets already produce *every* subset of
`ℕ` (each `s = ⋃_{n∈s} {n}`), so a single closure step jumps from "finite or univ" to the
full powerset — the dream space is maximally far from its completion. Why now?
`dreamNat_not_topological` already exhibits the union `evens = ⋃ {n}` driving the jump; the
completion theorem is its quantitative refinement.

## Direction 3: Non-open glut loci are exactly the spread-out valuations

Classify which Belnap valuations `v : ℕ → Belnap` have dream-open glut loci. **Conjecture:**
`{n | IsGlut (v n)} ∈ dreamNat.opens` iff `v` is glutted at only finitely many coordinates
or at every coordinate (finite-or-univ glut locus). The key insight is that `glut_locus_eq`
reduces the entire question to the *shape* of `{n | v n = B}` as a subset of `ℕ`, so the
open/non-open dichotomy for valuations is precisely the finite/cofinite-free dichotomy for
sets. Why now? `glut_locus_eq` plus `constB_glut_locus_open` and
`exists_valuation_glut_locus_not_dreamOpen` already bracket both extremes; only the
"finite ⇒ open" and "infinite, non-univ ⇒ not open" halves remain.

## Direction 4: Counting gluts in finite De Morgan algebras

Generalize FOUR to finite De Morgan algebras and count gluts. **Conjecture:** in a finite
De Morgan algebra with designation `D` upward-closed in the truth order, the number of
gluts equals the number of designated fixed-points-under-negation pairs, and is controlled
by the "width" of the interval between `⊥` and `⊤`; FOUR (width 2) has exactly one. The key
insight is that `glut_iff_B` is a width-1-middle phenomenon, and replacing the single
incomparable pair `{N, B}` by an antichain of size `k` should yield exactly `k - 1` gluts.
Why now? The `DistribLattice`/`neg` template here is directly reusable for the larger
algebras, and the glut-counting predicate is already `decide`-checkable on each finite case.

## Direction 5: Dream spaces of valuations and belief revision

Equip the space of valuations `Var → Belnap` with the dream space whose opens are
finitely-specifiable truth conditions, and model **belief revision** as morphisms that
preserve finite intersections but may drop unions (retraction). **Conjecture:** the
resulting category of dream spaces with revision morphisms is non-trivially richer than
the category of topologies, and its non-topological objects correspond to valuation spaces
with infinitely many glut coordinates. The key insight is that retraction = deleting an
open is exactly the operation forbidden in topologies but native to dream spaces, so
non-monotone belief dynamics live precisely in the gap measured by
`dreamNat_not_topological`. Why now? The `DreamSpace` structure and the glut-locus bridge
give a concrete, already-formalized first object on which to test revision morphisms.
