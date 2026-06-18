# Future Directions: Fractal Topology via Lattice-Theoretic Dimension

This cycle introduced `opensKrullDim X := krullDim (Opens X)`, the **open-set lattice
Krull dimension** of a topological space, and proved its foundational calculus in
`Bridges/FractalLatticeDimension.lean`:

* `opensKrullDim_eq_of_homeo` — homeomorphism invariance (via `Homeomorph.opensCongr`).
* `opensKrullDim_le_of_isOpenEmbedding` — monotonicity along open embeddings.
* `opensKrullDim_discrete` — collapse to `krullDim (Set X)` on discrete spaces.
* `opensKrullDim_le_prod_left` / `_right` — product factor lower bounds.
* `opensKrullDim_fin_discrete` — the exact value `n` for the `n`-point discrete space.

These give a complete "base calculus" (invariance, monotonicity, products, an exact
computation) on which the following research program can be built.

## 1. Discrete dimension is genuinely infinite, and the cardinal refinement

The capstone `opensKrullDim_fin_discrete` shows the `n`-point discrete space has
dimension exactly `n`. The natural next step is the infinite regime.

**Conjecture.** For any infinite discrete space `X`, `opensKrullDim X = ⊤`; more
sharply, for *every* discrete `X`, `opensKrullDim X` equals the order-theoretic height
of the Boolean algebra `Set X`, which is `⊤` iff `X` is infinite and `Fintype.card X`
otherwise.

The key insight is that `opensKrullDim_discrete` already reduces the whole question to
`krullDim (Set X)`, and an infinite discrete space embeds arbitrarily long finite
chains `∅ ⊂ {x₀} ⊂ {x₀,x₁} ⊂ ⋯`, so `InfiniteDimensionalOrder (Set X)` holds and
`krullDim_eq_top` applies.

**Why now?** The exact finite computation and the discrete reduction lemma are already
formalized; the infinite case only needs the `InfiniteDimensionalOrder` instance, which
`krullDim_eq_top` and `krullDim_eq_top_iff` in Mathlib turn into a finished theorem.

## 2. Sober reconstruction: lattice dimension vs. irreducible-closed dimension

Mathlib's `topologicalKrullDim` is defined through irreducible closed sets, whereas
`opensKrullDim` is defined through the open-set lattice directly. These two should agree
on the spaces where the open-set lattice "remembers" the points.

**Conjecture.** For a sober space `X` the two invariants are comparable in a precise way:
the irreducible-closed dimension `topologicalKrullDim X` is bounded by `opensKrullDim X`,
and for spectral spaces they coincide after passing to the spectrum of the frame.

The key insight is that for sober spaces the unit `X → Spec(Opens X)` of the
frame–space adjunction is a homeomorphism, so `IsHomeomorph.topologicalKrullDim_eq`
together with `opensKrullDim_eq_of_homeo` lets one transport both invariants onto the
same space `Spec(Opens X)` and compare them there.

**Why now?** Both invariants are now Lean-formalized and both are proven homeomorphism
invariants (`IsHomeomorph.topologicalKrullDim_eq`, `opensKrullDim_eq_of_homeo`), so the
only missing bridge is the `Spec` construction for frames — a localized, self-contained
target rather than an open-ended reconstruction.

## 3. A fiber inequality for closed surjections

`opensKrullDim_le_prod_left/right` are the constant-fiber instances of a general fiber
dimension formula. Projection `X × Y → X` is a closed surjection with constant fiber `Y`,
and the product bounds are exactly what a fiber formula predicts.

**Conjecture.** If `f : X → Y` is a continuous closed surjection whose fibers all
satisfy `opensKrullDim (f ⁻¹' {y}) ≤ k`, then
`opensKrullDim X ≤ opensKrullDim Y + k + 1`.

The key insight is that a chain of open sets in `X` projects (via the open *images* used
in `opensKrullDim_le_of_isOpenEmbedding`) to a chain in `Y`, and consecutive members
that project to the same open set in `Y` are separated only inside a single fiber, so the
fiber contributes at most `k + 1` extra levels.

**Why now?** The push-forward map `opensImage` and the strict-monotonicity engine
behind `opensKrullDim_le_of_isOpenEmbedding` are the precise tools needed to build the
projection half of the argument, and the product theorems give the base case to test the
constant `k + 1`.

## 4. Self-similar fractals: a logarithmic upper bound

The dimension here is purely topological, so it is the right invariant for the
*topological* (as opposed to Hausdorff/metric) complexity of fractals built by iterated
function systems.

**Conjecture.** For a self-similar set `F` satisfying the open set condition with `N`
contractions of ratio `r`, the open-set lattice dimension is finite with
`opensKrullDim F ≤ ⌈log N / log (1/r)⌉`.

The key insight is that the IFS gives a recursive decomposition of `Opens F` into `N`
rescaled copies, so any chain of open sets has length bounded by the recursion depth
needed to separate `N`-fold refinements — precisely the logarithmic count above.

**Why now?** With invariance (`opensKrullDim_eq_of_homeo`) and the open-embedding
monotonicity in place, each IFS piece is an open-embedded rescaled copy of the whole, so
the recursion can be set up entirely from already-proven monotonicity lemmas.

## 5. Decidable computation for finite T₀ spaces via Birkhoff duality

`opensKrullDim_fin_discrete` is the antichain (discrete) special case of the finite
theory. General finite T₀ spaces are finite posets, and their open-set lattices are
distributive.

**Conjecture.** For a finite T₀ space `X`, `opensKrullDim X` equals the height of the
poset of join-irreducible open sets (equivalently, the longest chain in the
specialization order), and this value is `Decidable`/computable, enabling `#eval`-based
verification of examples.

The key insight is Birkhoff's representation theorem: `Opens X` is the lattice of
downsets of the specialization preorder, and the Krull dimension of a finite distributive
lattice equals the height of its join-irreducibles — turning a lattice-chain search into
a finite poset-height computation.

**Why now?** The discrete computation already exhibits the finite-chain machinery
(`RelSeries`, cardinality bounds on strictly monotone chains) needed for the general
finite case; replacing "power set" by "downset lattice" via Birkhoff duality is the one
new ingredient, and it makes the invariant computable, closing the loop with
finite-model computational topology.
