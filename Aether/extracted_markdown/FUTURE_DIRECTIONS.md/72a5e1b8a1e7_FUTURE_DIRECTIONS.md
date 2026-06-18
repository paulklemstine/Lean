# Future Directions — Tropical Valuation Depth as an Ultrametric Bridge

## Synthesis

The new file `Catalog/Bridges/ValuationDepthUltrametric.lean` closes the gap the concept
identified between two pre-existing catalog pillars:

* the **computational engine** `ValuationDepthMeasure` / `vdepth_sum_le` in
  `Catalog/Computation/PadicValuationDepth.lean`, whose additive law carries a `+1`
  defect (`vdepth (f + g) ≤ max (vdepth f) (vdepth g) + 1`); and
* the **tropical/ultrametric packaging** `UltraNormObj`, `TropObj`,
  `TropicalValuationCarrier`, `valuationReconstruct`, `tropicalization` in
  `Catalog/Bridges/CategoricalTropicalUltrametric.lean`.

The decisive observation is that the genuine non-archimedean geometry lives **one level
sharper** than the computational depth law: in the `+1`-free *norm convention*
`v (a + b) ≤ max (v a) (v b)`. We isolated this as the class `AddValuationDepth` over an
additive commutative group, and proved that `d(x,y) := v(x − y)` is a true ultrametric
pseudodistance (`vdist_self`, `vdist_comm`, `vdist_strong_triangle`), that addition obeys
a tropical max-plus control law (`add_nonexpanding`, `add_left_isometry`,
`vdist_add_right`), and that negation is an isometry (`vdist_neg`). We then showed a
*multiplicative* valuation depth `MulValuationDepth` flows functorially into the existing
machinery: `toCarrier → valuationReconstruct → toUltraNormObj → tropicalization →
toTropObj`, with the reconstructed norm equal (definitionally) to the valuation, ultrametric
(`toUltraNormObj_ultrametric`) and multiplicative (`toUltraNormObj_mul`). The trivial
`{0,1}`-valuation witnesses both layers concretely (on any group, and on any integral
domain), giving a fully worked `ℤ`-instance of the depth → ultranorm → tropical pipeline.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `AddValuationDepth.vdist_self` | `d(x,x) = 0` | proved |
| `AddValuationDepth.vdist_comm` | `d(x,y) = d(y,x)` | proved |
| `AddValuationDepth.vdist_strong_triangle` | `d(x,z) ≤ max (d(x,y)) (d(y,z))` | proved |
| `AddValuationDepth.vdist_triangle` | ordinary triangle inequality | proved |
| `AddValuationDepth.add_nonexpanding` | tropical max-plus law for `+` | proved |
| `AddValuationDepth.{vdist_add_right, add_left_isometry, vdist_neg}` | isometry laws | proved |
| `MulValuationDepth.toUltraNormObj` / `toTropObj` | bridge constructors | defined |
| `MulValuationDepth.toUltraNormObj_ultrametric` / `_mul` | norm is ultrametric & multiplicative | proved |
| `trivialAddValuationDepth`, `trivialMulValuationDepth` | concrete instances | defined |
| `trivInt_norm_five`, `trivInt_norm_zero` | concrete `ℤ` checks | proved |

All main results use only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

## Research Directions

### 1. A first-class `PseudoMetricSpace`/`UniformSpace` instance from valuation depth

The current `vdist` lands in `ℕ`. The next step is to transport it through a monotone
embedding `ℕ → ℝ≥0` (e.g. `n ↦ 2^{-n}` for the depth convention, or `n ↦ n`) and register
a genuine Mathlib `PseudoMetricSpace` (in fact `IsUltrametricDist`) instance, so that the
whole apparatus of completions, balls, and continuity becomes available for free.
**The key insight is** that `max (d x y) (d y z)` already dominates the additive triangle
inequality, so the embedding only has to be monotone, not additive — the ultrametric does
the analytic work. **Why now?** Mathlib already has `IsUltrametricDist`; the only missing
ingredient was an abstract source of the strong triangle inequality, which `AddValuationDepth`
now supplies. This direction is falsifiable: it fails for the depth (min-convention)
valuation unless the order is reversed, pinning down exactly which transform is correct.

### 2. Reconciling the `+1` defect: a "defect-graded" ultrametric

`ValuationDepthMeasure` is not itself an ultrametric because of the `+1` in `vdepth_add`.
Conjecture: the function-depth measure induces a *graded* pseudodistance
`d_k(f,g) = vdepth(f − g)` on a ring of functions where the strong triangle inequality holds
up to an additive defect `1` per composition layer, and the defect is exactly the circuit
depth of the addition tree. **The key insight is** that the `+1` is not noise but a genuine
grading by parallel-time, so the right target is an ultrametric *valued in a tropical
(max-plus) monoid with a shift*, not in `ℕ`. **Why now?** Both the depth law and the
tropical objects are already formalized; the missing piece is the shifted-monoid codomain,
which is a small structure to add. Falsifiable: if no shift makes the triangle inequality
exact, the grading interpretation is wrong.

### 3. Functoriality: valuation-depth-preserving maps as `UltraHom`s

We built the object-level bridge; the arrow-level bridge is open. Conjecture: any additive
map `φ : α → β` between `AddValuationDepth` groups with `v_β (φ a) ≤ v_α a` induces an
`UltraHom` between the reconstructed objects, and this assignment is a functor compatible
with `valuationReconstruct_map`. **The key insight is** that non-expansiveness of the norm
*is* the morphism condition already present in `UltraHom.norm_nonexpansive'`, so the bridge
is functorial almost by definition. **Why now?** `UltraHom`, `TropHom`, and
`valuationReconstruct_map` are already in the catalog; only the depth-side morphism class is
missing. Falsifiable: functoriality fails if a depth-preserving map need not preserve the
multiplicative structure required by `TropicalValuationCarrier`.

### 4. Non-trivial ℕ-valued multiplicative instances beyond the trivial valuation

The only concrete `MulValuationDepth` we exhibited is the trivial `{0,1}` valuation. The
program is to build genuinely graded instances: e.g. on `ℤ` the map `n ↦ ` (largest `k`
with `p^k ∣ denominator`-style data) suitably truncated, or on a polynomial ring the
degree/order valuation `v(f) = ` order of vanishing, which is multiplicative and ultrametric.
**The key insight is** that order-of-vanishing valuations are already `ℕ`-valued and
multiplicative, so they slot directly into `MulValuationDepth` without the real-valued
detour the p-adic norm requires. **Why now?** Mathlib has `Polynomial.rootMultiplicity`
and `multiplicity`; wrapping one as a `MulValuationDepth` would give the first
arithmetically non-trivial point of the bridge. Falsifiable: multiplicativity can fail at
zero divisors, so the instance pins down the domain hypotheses precisely.

### 5. Tropical stability certificates for iterated computation

Combine `add_nonexpanding` with the catalog's `UltrametricCompositionLaw` and
`UltrametricLipschitzData.iter_exponent_stable` to prove a *stability theorem*: iterating a
non-expanding update map keeps the valuation-depth distance between two computation states
bounded by the initial distance, with no exponential blow-up — the ultrametric analogue of
the classical `L^n` Lipschitz growth. **The key insight is** that in the max (tropical)
world iteration takes a maximum, not a product, so the Lipschitz constant is *idempotent*
and stability is automatic. **Why now?** `iter_exponent_stable` already proves the
constant-`L` phenomenon for the abstract Lipschitz data; lifting it to actual state
distances via `add_nonexpanding` is the natural unification. Falsifiable: the bound breaks
the moment the update map is only non-expanding in the additive (not the max) sense.
