# Future Directions — Functorial Tropicalization of Valuation Depth

Follow-up conjectures arising from `Bridges/TropicalValuationDepth.lean`, which builds the
**max-plus** tropical valuation object `maxPlusBase` on `WithBot ℕ`, identifies valuation
*depth* (`Computation/PadicValuationDepth`) as a tropical-valued seminorm into it, and proves
the logarithmic-depth law `vdepth (treeSum g k) ≤ d + k` for balanced binary reductions.

Each conjecture is stated so it can be formalized as a Lean theorem (or refuted by a
counterexample) in a later cycle.

## C1. Sharpness of the logarithmic-depth law (depth lower bounds)
The proven bound `vdepth (treeSum g k) ≤ d + k` is an upper bound. Conjecture: there exists a
`ValuationDepthMeasure` instance and a family `g` of depth-`d` leaves for which equality is
*forced*, i.e. `vdepth (treeSum g k) = d + k`, while every *linear* (right-nested) fold of the
same `2 ^ k` leaves has depth exactly `d + (2 ^ k - 1)`. Formalizing this requires a
non-degenerate depth measure (the catalog's `ℕ → ℕ` instance is trivially `0`), e.g. one
counting genuine algebraic operations. This would turn the qualitative "balancing helps" into
an exact `DepthWitness`-style separation of `VAL_k`.

## C2. Max-plus is the universal receptacle for depth
Conjecture: among all `TropicalValuationObject`s `T` admitting a monotone map
`Φ : ℕ → T.α` with `Φ (max a b + 1) = T.mul (T.add (Φ a) (Φ b)) u` for a fixed cost unit `u`,
the max-plus object `maxPlusBase` is initial (universal): every such `(T, Φ, u)` factors
uniquely through `depthTropicalize`. This would make "tropicalization of depth" a genuine
universal property rather than one convenient model, strengthening the bridge to a functor with
a left adjoint.

## C3. Carry-free composition law in max-plus
`UltrametricCompositionLaw` adds `vdepth (f ∘ g) ≤ max (vdepth f) (vdepth g) + 1`.
Conjecture: under this law, the depth of a *balanced composition tree* of `2 ^ k` maps each of
depth `≤ d` is `≤ d + k` (the multiplicative/compositional analogue of `treeSum`), and the
tropical recasting `depthTropicalize (compTree g k) ≤ d + k` holds verbatim in `maxPlusBase`.
This unifies §3's additive/multiplicative reductions with sequential composition under one
max-plus cost calculus.

## C4. Functorial bound transfer: depth ⇒ ultrametric radius
Combine with `CategoricalTropicalUltrametric`. Conjecture: a depth bound `vdepth f ≤ d`
transfers, via `valuationReconstruct`, to a certified ultrametric perturbation radius that
*shrinks geometrically* in the number of balanced reduction levels: an `L`-layer balanced
circuit of depth-`d` leaves admits an ultrametric robustness radius bounded below by a function
of `d + log₂ L`. The target is a single theorem chaining `treeSum_tropical_bound` with
`tropical_bound_to_ultrametric_bound`.

## C5. A non-trivial concrete instance from `ℤ_[p]`
The only concrete `ValuationDepthMeasure` in the catalog is the trivial `ℕ → ℕ` (all depths 0).
Conjecture: the p-adic integers `ℤ_[p]` carry a *non-trivial* valuation depth measure for which
`padic_norm_ultrametric` makes addition genuinely depth-`1` and for which `maxPlusBase` is the
exact tropical shadow of the p-adic valuation. Constructing this instance would let C1–C4 be
tested on honest, non-degenerate data and connect the whole development to `PadicValuationDepth`'s
§11.
