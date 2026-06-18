# Future Directions — One-Way Functions: Existence and Hierarchy

## Synthesis

This cycle isolates the **deterministic combinatorial skeleton** of the cryptographic
hardness lattice `OWF → PRG → PRF → ENC`. The catalog already contained two anchors:
`Cryptography.HardnessHierarchy` (the order-theoretic `CryptoLevel` chain, lossy
functions, fiber counting, the `GGMTree` construction, and `ggm_image_bounded`, which
caps the GGM image at `|α|`), and `Cryptography.OneWayHierarchy` (the *inversion*
bottleneck `|Im f|`, with `exact_inversions_le_image` and the order skeleton
`rank_injective`/`owf_weakest`/`enc_strongest`).

The new module `Cryptography.GGMSecurity` completes the *expansion* side of that
picture. Where `OneWayHierarchy` measures how badly a function can be inverted
(`|Im f|`), we measure how richly a generator can expand. We package the
information-theoretic shadow of a length-doubling PRG as a `LengthDoublingExpander`
(both halves injective, ranges disjoint) and prove:

* `ggm_injOn_length` — GGM evaluation is injective on equal-length input paths;
* `ggm_image_card` — it realizes **all** `2 ^ n` outputs on `n`-bit inputs (no entropy
  loss), upgrading `ggm_image_bounded`'s `≤ |α|` into an *attained* count `= 2 ^ n`;
* `prf_domain_lower_bound` — hence `2 ^ n ≤ |α|`, the matching lower bound;
* `ggm_bijOn_length` — the keyed family is a perfect enumeration of `{0,1}^n`.

The unifying theme: **both edges of the hierarchy are governed by a single
cardinality invariant.** Inversion is limited from above by `|Im f|`; expansion is
forced from below by `2 ^ n`. The "two halves disjoint + injective" hypothesis is the
collision-theoretic dual of the lossy-function analysis in `HardnessHierarchy`.

## Results summary

| Theorem | Statement | Status |
|---|---|---|
| `ggm_injOn_length` | GGM injective on equal-length paths | proved (0 sorry) |
| `ggm_image_card` | `|image of length-n paths| = 2 ^ n` | proved (0 sorry) |
| `prf_domain_lower_bound` | `2 ^ n ≤ |α|` | proved (0 sorry) |
| `ggm_bijOn_length` | bijection onto range | proved (0 sorry) |

All four depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research directions

### 1. Composition of expanders climbs the hierarchy multiplicatively

A single `LengthDoublingExpander` doubles entropy; composing the seed map with itself
should *square* the spread. Conjecture: if `E : LengthDoublingExpander α`, then the
"two-step" generator `x ↦ ((E.G (E.G x).1), (E.G (E.G x).2))` is again a
length-doubling expander whose GGM image on `n`-bit inputs has cardinality `2 ^ n` for
inputs interpreted at double depth, and that the loss factors compose exactly as in
`CryptoReduction.compose` (`reduction_compose_loss`). **The key insight is** that the
disjoint-injective conditions are *closed under composition*, so the expander family
forms a monoid whose action on `CryptoLevel` is the successor map. **Why now?** The
composition machinery (`CryptoReduction.compose`, `reduction_compose_loss`) and the
order skeleton (`rank_injective`) are already in the catalog; this direction fuses them
with `ggm_image_card` to make "stronger primitive = more composition" a literal
theorem rather than a slogan.

### 2. The disjoint-range hypothesis is *necessary*, not just sufficient

We proved injectivity assuming `ranges_disjoint`. Conjecture (falsifiable): dropping
disjointness genuinely breaks GGM — there exists `α`, `G` with both halves injective
but overlapping ranges, a seed, and an `n`, such that
`(univ.image (fun v : List.Vector Bool n => ggmTree G seed v.toList)).card < 2 ^ n`.
**The key insight is** that a left/right collision at depth 1 propagates to a leaf
collision, so the three structural hypotheses of `LengthDoublingExpander` are
*independent* and each is tight. **Why now?** `ggm_image_card` gives the exact target
`2 ^ n` to violate; a small explicit `G` on `Fin 3` or `Fin 4` should be discoverable
by `#eval`/`decide`, turning a hypothesis into a sharp separation.

### 3. A quantitative bridge: inversion capacity × expansion capacity

`OneWayHierarchy.exact_inversions_le_image` bounds exact inversion by `|Im f|`;
`prf_domain_lower_bound` forces `2 ^ n ≤ |α|`. Conjecture: for a GGM-PRF block space
`α` of size `N`, the maximal number of *simultaneously exactly invertible* leaf outputs
of `ggmTree E.G seed` over length-`n` inputs equals `min (2 ^ n) N`, attained by
`Function.invFun`. **The key insight is** that expansion and inversion are dual
capacities of the *same* finite set `α`, and the hierarchy's "security at level i" in
`SecurityProfile` is exactly the ratio `2 ^ n / N`. **Why now?** Both extremal
quantities (`|Im f|`, `2 ^ n`) are now formal theorems; combining them via
`invFun_exact_inversions` would yield the first catalog result that *quantitatively*
links the OWF and PRF layers.

### 4. Hybrid distance scales linearly in the GGM depth

The catalog's `HybridSequence`/`hybrid_advantage_triangle` bounds total advantage by
`n · max εᵢ`. Conjecture: for the GGM tree of depth `n`, the natural hybrid sequence
(replacing one PRG call per level) has exactly `n` steps, so the PRF distinguishing
advantage is `≤ n · ε_PRG`, and this `n` is precisely `List.length` of the input path —
the same `n` that appears in `ggm_image_card`. **The key insight is** that the depth
parameter governing *security loss* (hybrid count) and the depth parameter governing
*entropy gain* (`2 ^ n`) are one and the same integer, so security degrades linearly
while output space grows exponentially. **Why now?** `hybrid_advantage_triangle` is
proved and `ggmTree` is recursive on exactly `n` levels; wiring the two needs only a
`HybridSequence` instance of `numSteps = n`.

### 5. Order-isomorphism: expanders realize every rung of `CryptoLevel`

`OneWayHierarchy` shows `CryptoLevel.rank` is injective into `Fin 4`. Conjecture: there
is a constructive functor sending each `LengthDoublingExpander` to a chain of objects
realizing `OWF ≤ PRG ≤ PRF ≤ ENC` such that `rank` is the depth of the GGM unrolling,
making `CryptoLevel` literally the truncation of the natural-number grading by GGM
depth. **The key insight is** that the four-element hierarchy is the `n ≤ 3` shadow of
an *unbounded* `ℕ`-graded tower of pseudorandom primitives, with `2 ^ n` as the grading
character. **Why now?** `rank_injective` and `level_total` already exhibit the chain as
order-isomorphic to `Fin 4`; `ggm_image_card`'s `2 ^ n` supplies the missing graded
character to extend it to all of `ℕ`.
