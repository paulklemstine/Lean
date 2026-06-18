# Future Directions: Arithmetic-Height Monotonicity on Berggren Subtrees

## Synthesis

`Bridges/BerggrenBoundaryHeight.lean` turns arithmetic height from a *pointwise* statistic on
Pythagorean triples into a *monotone boundary functional* on finite prefix-closed Berggren
subtrees. We modelled a finite search frontier as a `Finset BerggrenWord` (reusing the catalog's
`BerggrenGen`/`BerggrenWord` from `Bridges/BerggrenTransferDuality.lean`), defined the total
boundary height `boundaryHeightF H B = Σ_{w ∈ boundaryF B} H w`, and bridged it to the catalog's
`Set`-level `boundaryWords` via `coe_boundaryF`. The height function is pulled back along word
evaluation through `ArithmeticVCDim.ratArithHeight` (`wordArithHeight`).

The decisive structural fact is `boundaryF_expand`: a one-step ternary Berggren expansion of a
leaf `w` replaces `w` in the boundary by *exactly* its three children `childWords w`, with
prefix-closedness used in precisely one place (to certify the new children are themselves leaves).
This yields the subtraction-free accounting identity `boundaryHeightF_expand_eq`, from which weak
and strict monotonicity (`boundaryHeightF_expand_mono`, `boundaryHeightF_expand_strict`) drop out
under a local growth hypothesis.

## Results Summary

- `boundaryHeightF_ge_card` / `boundaryHeightF_ge_card_mul_min`: positivity-only lower bounds
  (boundary height ≥ leaf count, and ≥ count × min height).
- `boundaryF_expand`: exact post-expansion boundary description.
- `boundaryHeightF_expand_eq`: clean additive accounting identity.
- `boundaryHeightF_expand_mono` / `boundaryHeightF_expand_strict`: one-step expansion
  monotonicity under `ChildrenDominate` / `ChildrenDominateStrict`.
- `coe_boundaryF`: bridge to the catalog `Set`-level boundary.
- `boundaryHeightF_wordArithHeight_ge_card`: an unconditional certified lower bound for the
  concrete slope-pullback height.

**Adversarial finding.** Expansion monotonicity is *false* without a growth hypothesis: the
accounting identity removes the parent height `H w` and adds the three child heights, so a tiny
child can make the boundary functional drop. The growth hypothesis is the exact boundary
condition, not cosmetic. Computationally, for `wordArithHeight` every tested word satisfies even
the strict *per-child* domination (root height `8 = 3+5`, every child strictly larger), so the
hypothesis is empirically robust for the concrete height — but it remains unproven in general.

## Falsifiable Research Directions

### 1. Prove `ChildrenDominateStrict wordArithHeight` unconditionally
The concrete monotonicity theorems are currently *conditional* on a growth hypothesis that
computation suggests is always true. Conjecture: for every Berggren word `w`,
`wordArithHeight w < wordArithHeight (w++[A]) + wordArithHeight (w++[B]) + wordArithHeight (w++[C])`,
in fact each child strictly dominates the parent. **The key insight is** that for a primitive
triple `(a,b,c)` the legs and hypotenuse are pairwise coprime, so the slope `a/c` is already in
lowest terms and `ratArithHeight (a/c) = a + c`; since every Berggren child strictly increases the
hypotenuse `c` (catalog `BerggrenEntropyExtractor`: "strict norm growth under Berggren steps") and
keeps the leg positive, `a + c` strictly grows. **Why now?** The catalog already proves Pythagorean
preservation, positivity of children, and strict hypotenuse growth for the Berggren maps; combining
those with a coprimality lemma would discharge the only hypothesis in the present file, upgrading
every conditional theorem to an unconditional certified bound. Falsifiable: a single word with a
non-coprime `(a,c)` or a non-increasing `a+c` would refute it.

### 2. Global inclusion monotonicity `T₁ ⊆ T₂ ⟹ boundaryHeightF H T₁ ≤ boundaryHeightF H T₂`
Bootstrap one-step monotonicity to arbitrary inclusions of finite prefix-closed subtrees with a
common root. **The key insight is** that any inclusion of finite prefix-closed Berggren subtrees
factors as a finite chain of one-step ternary leaf expansions (induction on `T₂.card - T₁.card`,
each step adding a complete sibling-triple at a current leaf), so `boundaryHeightF_expand_mono`
composes along the chain. **Why now?** `boundaryF_expand` already gives the exact one-step boundary
update and the additive identity makes each step's contribution explicit; only the
expansion-chain decomposition lemma is missing. Falsifiable: exhibit an inclusion that cannot be
realized by complete-triple expansions (e.g. a subtree where only one of three siblings is
present), which would also sharpen the correct hypotheses.

### 3. Height-stratified Sauer–Shelah / VC bound from boundary growth
Connect boundary arithmetic height to the `ArithmeticVCDim` pipeline: bound the number of distinct
boundary height-profiles of depth-`n` Berggren subtrees and derive a pseudo-dimension surrogate.
**The key insight is** that `boundaryHeightF` is a single integer summary of a finite arithmetic
codebook (the boundary leaves), and Northcott-style finiteness of bounded-height rationals caps how
many distinct boundary profiles can occur below a height threshold. **Why now?** Both ingredients
already live in the catalog (`ratArithHeight` finiteness heuristics in `ArithmeticVCDimension`,
finite Hankel rank in `BerggrenTransferDuality`); the boundary functional is the missing bridge
that makes "bounded height ⇒ bounded trace count" concrete on Berggren frontiers. Falsifiable: a
family of equal-depth subtrees with super-polynomially many distinct boundary profiles below a
fixed height bound would break the surrogate.

### 4. Tight two-sided bounds: `boundaryHeightF` vs. depth and leaf count
Establish matching upper bounds to complement the lower bounds, e.g. `boundaryHeightF H B ≤
(boundaryF B).card · maxHeight` and exponential-in-depth growth for the full depth-`n` tree under
`wordArithHeight`. **The key insight is** that the additive accounting identity makes
`boundaryHeightF` of the complete depth-`n` tree a closed recurrence in `n` (each leaf spawns three
strictly heavier leaves), so both `card` and total height satisfy explicit ternary recurrences.
**Why now?** With `boundaryF_expand` proven, the recurrence for the *full* tree is mechanical, and
the strict per-child domination observed computationally suggests a clean geometric lower bound.
Falsifiable: measured growth rates departing from the predicted ternary recurrence.

### 5. Robustness of monotonicity under alternative pullback heights
Test whether monotonicity survives other natural pullbacks: leg slope `b/c`, full triple height
`|a|+|b|+|c|`, or a Weil-style logarithmic height, and characterize exactly which pullbacks satisfy
`ChildrenDominate`. **The key insight is** that `ChildrenDominate` is a purely local 4-point
inequality on the height function, so it can be screened generator-by-generator and the *set* of
admissible heights forms a tropical-style cone closed under sums and positive scaling. **Why now?**
The framework already abstracts over an arbitrary `H : BerggrenWord → ℕ`, so swapping pullbacks is a
one-line change; an adversarial search over candidate heights would map the exact frontier between
monotone and non-monotone arithmetic complexity measures. Falsifiable: a natural height for which a
specific generator violates `ChildrenDominate` (which the abstract theorems already predict must
exist for sufficiently "unbalanced" heights).
