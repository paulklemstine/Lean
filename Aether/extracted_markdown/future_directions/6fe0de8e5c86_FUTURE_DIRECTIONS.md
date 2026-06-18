# Future Directions: Quasi-symmetric maps as a generalization of bi-Lipschitz maps

This cycle established a small but load-bearing theory of η-quasisymmetric maps in
`Maps.lean`: the containment of the bi-Lipschitz class (`biLipschitz_isQuasisymmetric`,
linear gauge `η t = L²·t`), closure under composition (`isQuasisymmetric_comp`, gauges
compose as `η_g ∘ η_f`), and the rigidity dichotomy (`isQuasisymmetric_constant_or_injective`:
a quasisymmetric map is constant or injective), with both branches realized by
`isQuasisymmetric_const` and `isQuasisymmetric_id`. The directions below extend this core.

## 1. Quantitative continuity from the gauge

A non-constant η-quasisymmetric map ought to be continuous as soon as its gauge `η` is
continuous at `0` with `η 0 = 0`. The conjecture: if `IsQuasisymmetric f η`, `f` is not
constant, `ContinuousAt η 0`, and `η 0 = 0`, then `f` is continuous. The key insight is
that the rigidity dichotomy already forces injectivity, and the gauge inequality with a
fixed base point converts "small input ratio" into "small output ratio," so controlling
`η` near `0` directly squeezes the modulus of continuity of `f`. **Why now?** We have the
dichotomy in hand (`isQuasisymmetric_constant_or_injective`), which is exactly the
hypothesis-elimination step that previously blocked a clean continuity statement; the
remaining work is a single `Metric.continuousAt` ε–δ chase against `η`.

## 2. Inverse maps and the dual gauge

If `f` is a surjective injective η-quasisymmetric map, its inverse `g = f⁻¹` should be
quasisymmetric with the *dual* gauge `η'(t) = 1 / η⁻¹(1/t)` (for `t > 0`). The key insight
is that swapping the roles of the two non-base points in the defining inequality turns an
upper bound on output ratios into a lower bound, which is precisely an upper bound for the
inverse direction. **Why now?** The composition theorem `isQuasisymmetric_comp` already
fixes the correct categorical bookkeeping for how gauges transform under maps, so the
inverse law is the natural next structural axiom; together they would upgrade the
quasisymmetric maps from a *category* to a *groupoid* on the injective objects.

## 3. Sharpness of the bi-Lipschitz gauge exponent

`biLipschitz_isQuasisymmetric` produces the gauge `η t = L²·t`. Conjecture: the exponent
`L²` is sharp — there is an `L`-bi-Lipschitz map on a two-point–rich space for which no
gauge of the form `η t = c·t` with `c < L²` works. The key insight is that equality in
both the upper Lipschitz bound and the lower bi-Lipschitz bound can be forced
simultaneously by a single carefully placed triple, pinning `c` to exactly `L²`. **Why
now?** The forward containment is proved and its proof exposes exactly which two
inequalities are tight, so a matching lower-bound counterexample is a finite, falsifiable
construction rather than an open-ended search.

## 4. A weak-quasisymmetry equivalence on connected spaces

Define *weak* H-quasisymmetry by the single-threshold condition: `dist x a ≤ dist x b ⇒
dist (f x) (f a) ≤ H · dist (f x) (f b)`. Conjecture: on a connected, doubling metric
space, weak H-quasisymmetry implies full η-quasisymmetry for a gauge `η` depending only on
`H` and the doubling constant. The key insight is that connectivity lets one chain the
single-threshold comparison along a sequence of points to amplify it into control of
arbitrary ratios. **Why now?** Our `IsQuasisymmetric` predicate is already stated as the
strong (full-gauge) form, so adding the weak form and proving the easy direction
(`strong ⇒ weak`) immediately, then targeting the hard direction, gives a clean
incremental research target with a concrete equivalence as the prize.

## 5. Hausdorff-dimension distortion bounds

Conjecture: an η-quasisymmetric map with a power-type gauge `η t = C · t^s` distorts
Hausdorff dimension by a factor controlled by `s` — explicitly, `dim f(E) ≤ s · dim E + κ`
for a constant `κ(C)`. The key insight is that a power gauge makes the relative-distance
distortion scale-invariant, so covering arguments transfer cover exponents linearly under
`s`. **Why now?** Mathlib's `MeasureTheory.Hausdorff` API is mature, and our gauge-based
definition is exactly the hypothesis those covering lemmas consume; the bi-Lipschitz case
(`s = 1`) is already a corollary of `biLipschitz_isQuasisymmetric`, giving a known
sanity-check endpoint for the general inequality.
