# Future Directions: Dimension-Uniform Mirror Parity and Fourfold Arithmetic

## Synthesis

This cycle pushed the catalog's arithmetic mirror-symmetry skeleton
(`Geometry.MirrorSymmetry.ArithmeticMirror`, with its master relation
`ArithmeticMirror.eulerChar_mirror : χ(mirror Y) = (-1)^n χ(X)`) and its fourfold
specialization (`Geometry.MirrorSymmetry.CalabiYauFourfold`) from *fixed-dimension
corollaries* to *dimension-uniform theorems*, and from *bare combinatorics* to
*arithmetic (divisibility / parity) constraints*.

Two new files were added, both building directly on the catalog `eulerChar`
machinery rather than reproving it:

* `Geometry.MirrorSymmetry.MirrorParityLaw` abstracts the catalog's two
  dimension-specific mirror corollaries — the threefold sign flip
  (`ArithmeticMirror.eulerChar_mirror_threefold`, `χ ↦ -χ`) and the fourfold
  invariance (`CY4.eulerChar_mirror_invariant`, `χ ↦ χ`) — into a single parity
  dichotomy valid in **every** complex dimension `n`, over an arbitrary
  `CommRing`. The unifying object is the universal *mirror Euler law*
  `χ(X) + (-1)^{n+1} χ(X̌) = 0`.

* `Geometry.MirrorSymmetry.FourfoldArithmetic` turns the catalog's exact integer
  Euler formulas (`CY4.eulerChar_eq`, `CY4.eulerChar_KLRY`) into the F-theory
  tadpole divisibilities `6 ∣ χ` and `24 ∣ χ`, and isolates the *parity of `χ`*
  as a function of the single mirror-fixed central Hodge number `h^{2,2}`.

The conceptual thread (duality & representation engine): the mirror `ℤ/2`-action
acts on the Euler characteristic through the one-dimensional sign representation
`(-1)^n`, so `χ` is, up to that sign character, the unique reflection invariant —
and the *parity of the dimension* is the entire content of mirror symmetry at the
level of `χ`.

## Results Summary

All results are proven with `sorry = 0` and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`), verified module-by-module.

In `MirrorParityLaw` (over a general `CommRing R`):

1. `MirrorParity.eulerChar_mirror_even` — for *even* `n`, `χ(mirror n h) = χ(h)`
   (generalizes the fourfold `n = 4` case to all even dimensions).
2. `MirrorParity.eulerChar_mirror_odd` — for *odd* `n`, `χ(mirror n h) = -χ(h)`
   (generalizes the threefold `n = 3` case to all odd dimensions).
3. `MirrorParity.mirror_euler_law` — the universal law
   `χ(X) + (-1)^{n+1} χ(X̌) = 0`, with `X̌ = mirror n h`, holding in every `n`.
4. `MirrorParity.eulerChar_double_mirror` — the mirror is an involution on `χ`
   in every dimension: `χ(mirror n (mirror n h)) = χ(h)`.

In `FourfoldArithmetic` (over `ℤ`, building on `CY4`):

5. `CY4.six_dvd_eulerChar` — under the KLRY Chern relation, `6 ∣ χ`.
6. `CY4.twentyfour_dvd_eulerChar` — under KLRY plus flux quantization
   `4 ∣ (h^{1,1} + h^{3,1} − h^{2,1})`, the full tadpole constraint `24 ∣ χ`.
7. `CY4.eulerChar_odd_iff_h22_odd` — `χ` is odd iff the mirror-fixed middle number
   `h^{2,2}` is odd; the parity of `χ` is carried entirely by the central column.

## Bold, Falsifiable Research Directions

### 1. A genuine `CYn` structure with a dimension-uniform closed-form `χ`

The catalog so far hard-codes diamonds by `match` at `n = 3, 4`. The next step is
a parameterized structure `CYn (m : ℕ)` whose fields are the independent Hodge
numbers `h^{p,q}` surviving Hodge symmetry, Serre duality and Calabi–Yau
vanishing on `{0,…,m}²`, together with a single theorem
`χ(X) = Σ_{orbits O} (-1)^{p+q} |O| · h_O` computed purely from the D4-orbit
structure of the index square — and a corollary that this functional is
mirror-symmetric (invariant under `p ↦ m−p`) **iff** `m` is even.

The key insight is that `MirrorParity.eulerChar_mirror_even/odd` already prove the
parity behaviour *abstractly for every diamond*, so the only missing piece is the
finite orbit-counting bookkeeping that turns "abstract reflection invariant" into
an *explicit* linear form; the sign is forced, not discovered.

Why now? The parity half is done in full generality this cycle; the remaining
combinatorial lemma is a `Finset` orbit-partition computation, and the `n = 4`
instance (`CY4.eulerChar_eq`) is a worked, falsifiable template to check the
general formula against.

### 2. The mirror-fixed locus is exactly the central column, in every even dimension

`CY4.eulerChar_odd_iff_h22_odd` shows the central number `h^{2,2}` is the unique
parity-carrier for `n = 4`. Conjecture: for every even `m`, the mirror involution
`h^{p,q} ↦ h^{m−p,q}` on the independent Hodge data has fixed locus exactly the
central column `p = m/2`, and `χ` depends on the single *genuinely central* number
`h^{m/2,m/2}` with an odd coefficient while every paired number contributes an
even coefficient — so `χ` is odd iff `h^{m/2,m/2}` is odd, uniformly in `m`.

The key insight is that this is an equivariant fixed-point statement about the
`ℤ/2`-action `MirrorParity.eulerChar_double_mirror` already formalizes: the
coefficient parity in `χ` is a shadow of orbit sizes (`1` for the fixed point,
`2` for free orbits), so "central column = fixed locus" mechanically forces the
parity dichotomy.

Why now? The `n = 4` endpoint is a theorem (`eulerChar_odd_iff_h22_odd`) and the
involution is fully formal; promoting it needs only the central-column lemma from
Direction 1, making the two directions mutually reinforcing.

### 3. Sharp converse to the tadpole divisibilities

`CY4.twentyfour_dvd_eulerChar` is one implication. Conjecture: the flux
quantization `4 ∣ (h^{1,1} + h^{3,1} − h^{2,1})` is **equivalent** to `24 ∣ χ`
for KLRY fourfolds (so the F-theory constraint is exactly captured, not merely
implied), and more generally `12 ∣ χ` iff `2 ∣ (h^{1,1} + h^{3,1} − h^{2,1})`,
giving a complete divisibility lattice `6 ∣ χ ⊆ 12 ∣ χ ⊆ 24 ∣ χ` indexed by the
2-adic valuation of `h^{1,1} + h^{3,1} − h^{2,1}`.

The key insight is that `CY4.eulerChar_KLRY` makes `χ = 6·(8 + a)` an *exact*
identity with `a = h^{1,1}+h^{3,1}−h^{2,1}`, so every divisibility question
becomes a transparent statement about `v_2(8 + a)` that `omega` can settle in
both directions — turning folklore one-way constraints into iff-theorems.

Why now? The forward divisibilities are proven this cycle and the closed form is
in hand; the converse is pure 2-adic arithmetic on a known linear form, requiring
no new geometry.

### 4. Batyrev polar duality realizes the abstract swap `h^{1,1} ↔ h^{m−1,1}`

`CY4.mirror_diamond_eq` shows the *abstract* reflection `mirror 4` induces the
swap `h^{1,1} ↔ h^{3,1}`. Conjecture: define two `Finset`-valued lattice-point
functionals on a reflexive polytope `Δ` and its polar dual `Δ°`, prove they are
exchanged by polar duality (an Ehrhart-style identity), and show this *induces*
exactly `CY4.swap` (and its `m`-fold analogue) on Hodge data — making mirror
symmetry a representation theorem: the geometric duality `Δ ↔ Δ°` is represented
by the `ℤ/2`-swap on the Hodge vector.

The key insight is that the abstract side is finished — `CY4.swap_involutive` and
`CY4.mirror_diamond_eq` give the target `ℤ/2`-action — so the work is to *build a
concrete model* (lattice-point counts) and prove polar duality matches it, i.e. a
dual translation from polytope geometry to the already-formal Hodge combinatorics.

Why now? Lean's `Finset` tooling supports lattice-point counting, the target is a
finite identity testable first on the quintic/its Batyrev mirror, and the
algebraic codomain (the `CY4` swap) is now fully proven, so success is verifiable
by matching against existing theorems rather than against informal geometry.
