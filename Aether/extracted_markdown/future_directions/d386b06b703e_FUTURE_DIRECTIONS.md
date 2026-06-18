# Future Directions — Categorical Tropical Rips Interleaving (Rank & Shift cycle)

This cycle added two fully-verified files (0 sorries) extending
`Bridges.CategoricalTropicalRipsInterleaving`:

- `Bridges.CategoricalTropicalRipsRank` — **Conjecture 5** discharged: the rank functor
  `rankMod : PersMod (Set β) → PersMod ℕ` (finite `β`) is a 1-Lipschitz functor for the
  interleaving distance (`rank_preserves_interleaving`, `rank_interleavingDist_le`), giving
  Vietoris–Rips rank/Betti-0 curve stability over a finite point set (`rips_rank_stability`,
  `rips_rank_interleavingDist_le`).
- `Bridges.CategoricalTropicalRipsShift` — **Conjectures 2 & 4** discharged: the constant
  shift is a strict isometry of the interleaving distance (`interleavingDist_shift`),
  displaces a module by at most `c` (`interleavingDist_self_shift`), the self-distance is
  the tropical unit (`trop_interleavingDist_self`), and *finite interleaving distance* is an
  equivalence relation (`finInterleaved_equivalence`) equal to `interleavingDist ≠ ⊤`
  (`finInterleaved_iff_dist_ne_top`).

The following are bold, falsifiable targets for the next cycles.

## Conjecture A (The rank contraction is generically strict)
`rank_interleavingDist_le` proves `interleavingDist (rankMod M) (rankMod N) ≤
interleavingDist M N`. Claim: this inequality is **strict** for some explicit pair of Rips
modules on a 3-point set, i.e. the rank invariant strictly forgets geometry.
**The key insight is** that `ncard` collapses two non-nested edge sets of equal cardinality
to the *same* number, so a permutation-type perturbation that is invisible to the rank curve
still costs a positive interleaving distance at the lattice level.
**Why now?** We have both sides of the inequality formalized; constructing a 3-point
counterexample to equality is a finite `decide`-free computation that immediately upgrades
"1-Lipschitz" to "strictly contracting", a quantitative information-loss statement.

## Conjecture B (Shift is the unique tropical scalar action)
Beyond `interleavingDist_self_shift : d(M, shift c M) ≤ ofReal c`, claim the bound is
**tight**: `interleavingDist M (shift c M) = ENNReal.ofReal c` whenever `M` is *strictly*
monotone on a real interval of length `> c`.
**The key insight is** that strict monotonicity blocks any cheaper interleaving: an
`ε`-interleaving with `ε < c` would force `M.obj t < M.obj t` after composing the two
shifted dominations, a contradiction extracted by evaluating at an interior point.
**Why now?** The `≤` direction and the isometry `interleavingDist_shift` are already proved,
so only the `≥` direction (a single strict-monotonicity extraction) remains — the same
"evaluate the interleaving at a witness point" technique used for the catalog's stability.

## Conjecture C (The finite-distance quotient carries a tropical metric)
`finInterleaved_equivalence` makes `FinInterleaved` an equivalence relation. Claim: the
quotient `PersMod α / FinInterleaved` carries a well-defined `Tropical ℝ≥0∞`-valued metric
`⟦M⟧ ↦ ⟦N⟧ ↦ trop (interleavingDist M N)` that is submultiplicative end-to-end
(Conjecture 3's tropical inequality) and separates points.
**The key insight is** that `interleavingDist` is constant on `FinInterleaved`-classes
because the triangle inequality plus `interleavingDist_self = 0` forces equal distances to a
common third module — so the descent to the quotient is automatic.
**Why now?** Transitivity (`Interleaved.trans`), the pseudometric axioms, and the tropical
submultiplicativity (`interleaving_tropical_submul`) are all already in the catalog; only the
`Quotient.lift` well-definedness lemma is missing.

## Conjecture D (Rank curves are the universal ℕ-valued 1-Lipschitz invariant)
Among all functors `F : PersMod (Set β) → PersMod ℕ` that send `ε`-interleavings to
`ε`-interleavings and are inclusion-monotone on objects, the rank functor `rankMod` is
**maximal**: `F.obj t ≤ rankMod.obj t` pointwise for every such `F` normalized at the empty
object.
**The key insight is** that any 1-Lipschitz monotone ℕ-valued invariant is bounded by the
cardinality it can distinguish, and `ncard` realizes the finest distinguishable count, so the
rank functor is the terminal object among additive stable counts.
**Why now?** We have isolated the precise interface (`Interleaved`-preservation +
object-monotonicity) that makes a functor stable; characterizing its extremal element is the
natural categorical follow-up and needs only the lattice structure already in play.

## Conjecture E (Rank stability is sharp on a 2-point space)
For a 2-point metric space, the Rips rank curve stability `rips_rank_interleavingDist_le` is
**an equality**: `interleavingDist (ripsRankCurve d) (ripsRankCurve d') =
ENNReal.ofReal |d - d'|` (the only off-diagonal distance).
**The key insight is** that on two points the edge-set lattice is the 2-element Boolean
algebra, so the rank curve faithfully records the single threshold `d(x,y)`, and no
information is lost — making the generic contraction of Conjecture A degenerate to equality.
**Why now?** The 2-point case reduces to a one-parameter step function; the matching `≥`
bound is the same threshold-extraction argument as Conjecture B, providing a clean sharpness
companion to the general inequality just proved.
