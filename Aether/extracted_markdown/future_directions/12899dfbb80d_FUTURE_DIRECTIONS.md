# Future Directions: Cubical Type Theory Foundations

## Synthesis

The cubical path framework developed here establishes that endpoint-constrained interval-indexed functions provide a computationally tractable model of identity that interacts meaningfully with function spaces (via funext), type equivalences (via bijective path mapping), physical symmetry (via Lorentz invariance paths), and constructive analysis (via interpolation). The five directions below extend this foundation along three axes: (1) deepening the cubical structure toward genuine higher geometry, (2) broadening cross-domain connections to topology, category theory, and physics, and (3) testing computationally falsifiable predictions about path space cardinalities and homotopy invariants. Each direction builds directly on proven catalog theorems and the infrastructure of `CubicalCore.lean` and `CubicalApplications.lean`.

---

## Direction 1: Kan Composition and Groupoid Structure

**Conjecture:** For cubical intervals equipped with a "connection" operation (min/max structure on I), the path type supports a composition operation satisfying the groupoid laws up to higher paths — specifically, that composition is associative, admits left/right units, and inverses, all witnessed by 2-paths (paths between paths).

**Test:** Define `PathComp` for the standard real interval using piecewise-linear concatenation: `p · q (t) = p(2t)` for t ≤ 1/2, `q(2t-1)` for t ≥ 1/2. Verify computationally that: (1) endpoint conditions are satisfied, (2) `refl · p = p` up to reparametrization (a 2-path exists), (3) associativity holds up to reparametrization. Check for 100 randomly generated paths in ℝ with 1000 sample points.

**Impact:** This would extend the framework from a "path carrier" to a genuine ∞-groupoid approximation, making it possible to formalize higher category theory and homotopy theory internally.

**Catalog References:** `Logic/CubicalCore.lean` (PathOver, reflPath, cubical_funext)

**Proof Strategy:** Define composition as a piecewise function on `stdInterval`, prove continuity, and verify groupoid laws using `affine_path` reparametrizations. For the formal proof, use `Set.piecewise` or explicit case splits on the interval. The associativity 2-path is constructed by a linear reparametrization homotopy.

**Domain Bridges:** Topology (fundamental groupoid), Category Theory (∞-groupoids), Physics (parallel transport along spacetime paths)

**Lineage:** Extends cubical_funext + affine_path_interpolates

**Ambition:** ★★★★☆ (Grand challenge: full ∞-groupoid structure in Lean 4)

---

## Direction 2: Path Space Cardinality Invariants for Infinite Types

**Conjecture:** For the standard real interval `stdInterval = ⟨ℝ, 0, 1⟩` and any two distinct reals a, b, the path space `PathOver stdInterval ℝ a b` has the cardinality of the continuum (ℝ^ℝ restricted to endpoint conditions). Moreover, for any `CubicalEquiv ℝ ℝ` (e.g., translation by c), the induced bijection on path spaces preserves this cardinality — extending `pathCount_invariant` from finite to infinite types using cardinal arithmetic.

**Test:** (1) Prove that `PathOver stdInterval ℝ 0 1` contains the affine path and all polynomial interpolations of degree ≤ n with fixed endpoints, giving a lower bound of continuum cardinality. (2) Computationally: sample 10,000 random polynomials of degree 2-10 with p(0) = 0, p(1) = 1 and verify they define valid paths. (3) Check that translation by c maps the polynomial paths bijectively.

**Impact:** Extends the framework to handle genuine infinite-dimensional path spaces, bridging toward the measure-theoretic path integrals of physics.

**Catalog References:** `Logic/CubicalCore.lean` (pathCount_invariant, cubical_equiv_path_bijective), `Logic/CubicalApplications.lean` (affine_path)

**Proof Strategy:** Use `Cardinal.mk_le_of_injective` to embed polynomial paths into the path space. For the bijection, compose with the formal `mapPath` construction.

**Domain Bridges:** Measure Theory (Wiener measure on path spaces), Physics (Feynman path integrals), Functional Analysis (Banach spaces of paths)

**Lineage:** Extends pathCount_invariant + affine_path

**Ambition:** ★★★★★ (Grand challenge: connect cubical paths to path integral formalism)

---

## Direction 3: Detecting Nontrivial π₁ via Suspension Towers

**Conjecture:** The iterated suspension construction `Susp^n(A)` for finite A, when equipped with an appropriate quotient presentation, exhibits nontrivial fundamental group behavior detectable via the universal property. Specifically: `Susp(Susp(∅))` has a quotient presentation where the loop space at the north pole has exactly two elements (corresponding to S¹), testable by constructing a non-trivial target algebra.

**Test:** (1) Construct `SuspApprox (SuspApprox Empty)` and enumerate its equivalence classes. (2) Define a target algebra with `CircleAlg` structure and test whether the universal map distinguishes the two meridian classes. (3) Computationally: for finite approximations of `Susp^n(Fin k)` with k ≤ 5 and n ≤ 3, count distinct maps to `Fin m` respecting the algebra, and check whether the count matches the predicted |π₁| · |Fin m|^|π₀|.

**Impact:** Would establish that the suspension approximation captures genuine homotopy information, not just connectivity — a major step toward mechanized algebraic topology.

**Catalog References:** `Logic/CubicalCore.lean` (SuspApprox, susp_rec_unique, SuspAlg)

**Proof Strategy:** Define double suspension as `SuspApprox (SuspApprox Empty)`. Construct a quotient map to `ZMod 2` that sends the two meridian generators to 0 and 1, proving they are distinct. Use the universal property to show this is the unique such map.

**Domain Bridges:** Algebraic Topology (homotopy groups of spheres), Combinatorics (counting homomorphisms), Physics (topological quantum field theory)

**Lineage:** Extends susp_rec_unique + SuspApprox

**Ambition:** ★★★★★ (Grand challenge: compute π_n(S^m) via formal suspension)

---

## Direction 4: Lorentz Group Path Action and Poincaré Symmetry

**Conjecture:** The observable invariance schema `observable_invariance_path` extends to the full Poincaré group (Lorentz boosts + rotations + translations) acting on 3+1D spacetime. The group structure is reflected in path composition: the path induced by boost v₁ followed by boost v₂ equals the path induced by the relativistic velocity addition boost.

**Test:** (1) Extend `lorentzBoost` to 3+1D with rotations. (2) Verify computationally for 100 random velocity-rotation pairs that the composed invariance path matches the single-step path. (3) Check that the path composition is associative (modulo Thomas rotation/Wigner rotation effects).

**Impact:** Would establish the cubical framework as a tool for mechanized relativistic physics, connecting group-theoretic symmetry to path-theoretic identity.

**Catalog References:** `Logic/CubicalApplications.lean` (lorentz_boost_preserves_interval, lorentz_interval_cubical_invariant, iterated_invariance_path), `Catalog/Logic/FormalTime.lean` (Event, minkowskiInterval)

**Proof Strategy:** Define `lorentzBoost3D` as a matrix action on Event, prove interval preservation by direct computation (as in the 1+1D case). The group homomorphism property `eqToPath CI (h_compose) = eqToPath CI h₁ · eqToPath CI h₂` follows from transitivity of equality.

**Domain Bridges:** Physics (special/general relativity), Group Theory (Lie groups), Differential Geometry (frame bundles)

**Lineage:** Extends lorentz_interval_cubical_invariant + observable_invariance_path

**Ambition:** ★★★☆☆ (Solid extension with clear path to completion)

---

## Direction 5: Dependent Paths and Transport

**Conjecture:** The dependent path type `DPathOver` (paths in fibers lying over a base path) supports a transport operation: given a path `p : PathOver CI A a₀ a₁` and `b₀ : B a₀`, there exists a dependent path from `b₀` to `transport B p b₀` where transport is defined using the path's underlying function. Moreover, transport along `reflPath` is the identity.

**Test:** (1) Define `DPathOver` and `cubical_transport` for concrete type families (e.g., `B(n) = Fin n` over `ℕ`). (2) Verify computationally that transport along a constant path is the identity for 100 instances. (3) Check that transport composes: `transport (p · q) = transport q ∘ transport p` for 50 random path pairs.

**Impact:** Dependent transport is the computational engine of HoTT — it powers the univalence computation. Formalizing it in our framework would significantly close the gap with genuine cubical systems.

**Catalog References:** `Logic/CubicalCore.lean` (PathOver, reflPath, eqToPath), `Logic/CubicalApplications.lean` (affine_path, path_apply)

**Proof Strategy:** Define `cubical_transport` using `Eq.rec` along `p.2.1` and `p.2.2`. For the identity and composition laws, use `PathOver.ext` and the definitional behavior of `Eq.rec` on `rfl`.

**Domain Bridges:** Type Theory (dependent elimination), Differential Geometry (parallel transport), Physics (gauge theory connections)

**Lineage:** Extends PathOver + eqToPath

**Ambition:** ★★★☆☆ (Solid extension building directly on existing infrastructure)
