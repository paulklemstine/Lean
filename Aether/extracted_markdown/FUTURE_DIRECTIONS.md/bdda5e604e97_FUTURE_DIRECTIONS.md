# Future Directions: Quasi-Symmetric Gauges, the Bi-Lipschitz Monoid, and Dimension

## Synthesis of this cycle

This cycle took the two existing quasi-symmetric files in the catalog —
`Catalog/Applications/QuasiSymmetric/Maps.lean` (the `dist`-based predicates
`IsQuasisymmetric`/`IsBiLipschitzWith`, with composition and the constant-or-injective
rigidity dichotomy) and `Catalog/Geometry/QuasiSymmetricComposition.lean` (the *set-local*
`AntilipschitzOnWith`/Hölder distortion theory for `dimH`) — and tied them together with a
new file, `Catalog/Geometry/QuasiSymmetricDimension.lean`. The unifying observation is that
the *relative-distortion gauge* `η` of a quasisymmetric map behaves like an algebraic object
with its own calculus, and that the bi-Lipschitz sub-class is precisely the part of this
calculus we can already connect to Mathlib's measure-theoretic Hausdorff dimension `dimH`.

## Results summary

Five new theorems, all proved with `sorry = 0` and depending only on
`propext`/`Classical.choice`/`Quot.sound`:

1. `IsQuasisymmetric.mono_gauge` — a quasisymmetric map stays quasisymmetric under any
   pointwise larger gauge (quasisymmetry is *having some* controlling gauge).
2. `IsQuasisymmetric.eccentricity` — equidistant points cannot be spread by more than the
   single number `η 1`; the precise conformal "bounded eccentricity" statement.
3. `isQuasisymmetric_iterate` — the `n`-fold iterate of an injective `η`-quasisymmetric
   self-map is `η^[n]`-quasisymmetric: iterating the map iterates the gauge.
4. `isBiLipschitzWith_comp` + `isBiLipschitzWith_id` — bi-Lipschitz maps form a monoid with
   multiplicative constants, sitting inside the quasisymmetric maps via the linear gauge of
   `biLipschitz_isQuasisymmetric`.
5. `IsBiLipschitzWith.dimH_image_eq` — the cross-domain bridge: a bi-Lipschitz map preserves
   Hausdorff dimension on every set, the global `dist`-predicate packaging of the set-local
   `dimH_image_eq_of_lipschitzOn_antilipschitzOn`.

## Bold, falsifiable research directions

### 1. The quasisymmetric inverse gauge

Conjecture: if `f` is an `η`-quasisymmetric bijection with `η` strictly increasing and
surjective on `[0,∞)`, then `f⁻¹` is `η'`-quasisymmetric for the explicit gauge
`η'(t) = 1 / η⁻¹(1/t)`. **The key insight is** that the defining inequality
`dist(fx,fa) ≤ η(r)·dist(fx,fb)` can be *inverted* by reading it as a lower bound on the
inverse ratio, so that the inverse map's gauge is the reflection of `η` through the
involution `t ↦ 1/t`. **Why now?** We already proved `isQuasisymmetric_comp` and the
rigidity dichotomy `isQuasisymmetric_constant_or_injective`; the missing ingredient is only
the order-theoretic manipulation of a single one-variable gauge, which is well within reach
of the gauge calculus established in `QuasiSymmetricDimension.lean`.

### 2. From the iterated gauge to a contraction/expansion dichotomy

Conjecture: for an injective quasisymmetric self-map `f` whose gauge satisfies `η 1 < 1`,
the iterates `f^[n]` collapse eccentricity geometrically, `η^[n] 1 ≤ (η 1)^n`, forcing every
orbit to be asymptotically "round". **The key insight is** that `isQuasisymmetric_iterate`
already makes `η^[n]` the controlling gauge, and `IsQuasisymmetric.eccentricity` reads off
the eccentricity bound at scale `1`, so the dynamics of the *scalar* sequence `η^[n] 1`
governs the geometric dynamics of `f`. **Why now?** Both halves — iteration of the gauge and
single-scale eccentricity — were proved this cycle, so the conjecture is a self-contained
scalar recursion on top of existing theorems.

### 3. Linear-gauge characterisation of the bi-Lipschitz monoid

Conjecture: a quasisymmetric map admits a *linear* gauge `η t = C·t` **iff** it is
bi-Lipschitz, giving an intrinsic, gauge-side characterisation of the monoid. **The key
insight is** that `biLipschitz_isQuasisymmetric` proves one direction (linear gauge `L²·t`),
and the converse should follow by feeding the linear bound into well-separated triples to
recover two-sided absolute distance control. **Why now?** The monoid structure
(`isBiLipschitzWith_comp`, `isBiLipschitzWith_id`) and the linear-gauge embedding are now in
place; closing the iff turns "bi-Lipschitz" into a property checkable purely from the gauge.

### 4. Dimension distortion under genuinely non-linear gauges

Conjecture: an `η`-quasisymmetric map with power-type control `η t ≤ C·t^a` near `0` is
locally Hölder, hence `dimH(f '' s) ≤ dimH s / a`, recovering and extending the set-local
Hölder bounds of `QuasiSymmetricComposition.lean` from the *intrinsic* gauge. **The key
insight is** that the asymptotics of `η` near `0` are exactly what convert relative into
absolute distance control, and `dimH_image_bounds_of_holderOn_holderOn_inverse` already
turns Hölder data into dimension bounds. **Why now?** `IsBiLipschitzWith.dimH_image_eq`
handles the exponent-`1` (linear-gauge) case; replacing `1` by `a` is the natural next rung
and reuses the existing Hölder→`dimH` machinery verbatim.

### 5. The bi-Lipschitz monoid acts; orbits have constant dimension spectrum

Conjecture: the monoid of bi-Lipschitz self-maps of a fixed space acts on subsets by
dimension-preserving transformations, so every orbit `{ g '' s : g bi-Lipschitz }` has a
single common Hausdorff dimension — a genuine invariant of the orbit. **The key insight is**
that `IsBiLipschitzWith.dimH_image_eq` plus `isBiLipschitzWith_comp` make `dimH` a constant
of motion for the monoid action, so dimension descends to the orbit space. **Why now?** With
the monoid and the dimension-invariance bridge both formalised this cycle, the statement is a
direct corollary that would seed a formal theory of *conformal dimension* (the infimum of
`dimH` over a quasisymmetry orbit) — exactly the invariant flagged in the research brief.
