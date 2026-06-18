# Future Directions: Tropical Min-Plus Stone–Weierstrass

## 1. Extension to Lower-Semicontinuous Maps on `ℝ≥∞` / `WithTop ℝ`

The natural habitat for min-plus value functions is not `C(X, ℝ)` but the space of lower-semicontinuous maps `X → ℝ ∪ {+∞}`. Extending the Stone–Weierstrass framework to `WithTop ℝ`-valued LSC functions would:
- Capture infinite-cost barriers and hard constraints in optimization
- Model tropical varieties where functions naturally take value `+∞`
- Connect to Moreau–Fenchel convex duality (convex conjugation is tropical Fourier transform)

**Concrete target:** Formalize `LSCMap X (WithTop ℝ)` and prove that min-plus subalgebras separating points are dense in the epi-topology.

## 2. Tropical Gelfand–Kolmogorov Reconstruction Theorem

Classical Gelfand duality reconstructs a compact space `X` from the max-spectrum of `C(X, ℝ)`. The tropical analog should reconstruct `X` from the "tropical spectrum" of a min-plus algebra — the set of min-plus homomorphisms to `(ℝ, min, +)`.

**Concrete target:** Define `TropSpec A` for a min-plus algebra `A` of continuous functions, equip it with the weak topology, and prove it is homeomorphic to `X` when `A` separates points and contains constants.

## 3. Certified Approximation of Dynamic Programming Value Functions

The Lipschitz approximation theorem (distance templates) has immediate algorithmic content: given a value function `V` from dynamic programming, construct a certified tropical polynomial `g` with `‖V - g‖∞ < ε` using `O(K/ε)` template points.

**Concrete targets:**
- Formalize the McShane–Whitney extension theorem in min-plus form
- Prove convergence rates for tropical approximation of Lipschitz functions
- Connect to Bellman equations: show that the Bellman operator preserves the tropical polynomial class

## 4. Automatic Max-Plus ↔ Min-Plus Duality API

The negation transport formalized here should be packaged as a generic "duality functor" that automatically mirrors any max-plus theorem to a min-plus theorem. This requires:
- A typeclass for "tropical semiring" with a `dual` operation
- Meta-programming to apply negation transport to theorem statements automatically
- Coverage of operations beyond basic algebra: integration, convolution, spectral radius

**Concrete target:** A Lean 4 tactic `tropical_dual` that, given a max-plus theorem, produces the min-plus variant.

## 5. Approximation of Morphological Erosions/Dilations

Mathematical morphology uses erosion `(f ⊖ b)(x) = inf_y [f(y) + b̃(x-y)]` and dilation `(f ⊕ b)(x) = sup_y [f(y) + b(x-y)]`, which are tropical min-plus and max-plus convolutions respectively. The Stone–Weierstrass theorem implies:
- Finite structuring element decompositions exist for any morphological operator
- Cascade decompositions (sequential erosions) are dense in the operator algebra

**Concrete target:** Formalize morphological operators as tropical convolutions, prove that the algebra of finite morphological cascades is dense in the operator norm.
