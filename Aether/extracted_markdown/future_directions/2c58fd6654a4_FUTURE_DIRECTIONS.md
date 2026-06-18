# Future Directions: Tropical Geometry Infrastructure

This document outlines concrete next steps for building a full tropical geometry library, extending the foundational corner locus theorem formalized in `Tropical/Geometry/Hypersurface.lean`.

---

## 1. Closedness and Topological Properties of Tropical Hypersurfaces

**Status**: ✅ Completed in this cycle (`isClosed_tropHypersurface`).

**Next theorem targets**:

```lean
/-- The complement of a tropical hypersurface is open and dense
    when the polynomial has at least two distinct monomials. -/
theorem isOpen_compl_tropHypersurface {n : ℕ}
    (p : Finset (TropMonomial n)) (hp : p.Nonempty) :
    IsOpen (TropHypersurface p hp)ᶜ

/-- The tropical hypersurface has empty interior when the polynomial
    has at least two monomials with distinct exponent vectors. -/
theorem interior_tropHypersurface_eq_empty {n : ℕ}
    (p : Finset (TropMonomial n)) (hp : p.Nonempty)
    (hdist : ∃ m₁ ∈ p, ∃ m₂ ∈ p, m₁.exp ≠ m₂.exp) :
    interior (TropHypersurface p hp) = ∅
```

**Proof strategy**: The complement is open directly from closedness. For empty interior, use the fact that distinct exponent vectors produce affine forms whose equality locus is a proper affine subspace, hence nowhere dense.

**Cross-domain significance**: Establishes that tropical hypersurfaces are "thin" separating sets — analogous to decision boundaries in classification, or phase boundaries in statistical mechanics.

---

## 2. Convex-Complement Theorem: Unique Maximizer Regions

**Theorem statement**:

```lean
/-- A region of unique maximizer: the set where monomial m strictly
    dominates all others. -/
def StrictDominanceRegion {n : ℕ} (p : Finset (TropMonomial n))
    (m : TropMonomial n) : Set (Fin n → ℝ) :=
  {x | m ∈ p ∧ ∀ m' ∈ p, m' ≠ m → m'.eval x < m.eval x}

/-- The complement of the tropical hypersurface is the union of
    strict dominance regions. -/
theorem compl_tropHypersurface_eq_iUnion_strictDominance {n : ℕ}
    (p : Finset (TropMonomial n)) (hp : p.Nonempty) :
    (TropHypersurface p hp)ᶜ =
      ⋃ m ∈ p, StrictDominanceRegion p m

/-- Each strict dominance region is convex. -/
theorem convex_strictDominanceRegion {n : ℕ}
    (p : Finset (TropMonomial n)) (m : TropMonomial n) :
    Convex ℝ (StrictDominanceRegion p m)

/-- Each strict dominance region is open. -/
theorem isOpen_strictDominanceRegion {n : ℕ}
    (p : Finset (TropMonomial n)) (m : TropMonomial n) :
    IsOpen (StrictDominanceRegion p m)
```

**Proof strategy**: Each strict dominance region is defined by strict linear inequalities `m.eval x > m'.eval x` for all `m' ≠ m`. These are open half-spaces, so the region is an intersection of finitely many open half-spaces — hence open and convex. The complement decomposition follows from the trichotomy of order.

**Formalization plan**: Define `StrictDominanceRegion`, prove openness via `isOpen_lt` for continuous functions, prove convexity via `Convex.inter` of half-spaces, then prove the decomposition by elementary logic.

**Cross-domain significance**: This is the tropical analogue of the Voronoi decomposition. In machine learning, these are the linear regions of a max-affine model — directly applicable to understanding ReLU network geometry.

---

## 3. Newton Polytope Bridge

**Theorem statement**:

```lean
/-- The Newton polytope of a tropical polynomial is the convex hull
    of its exponent vectors (cast to ℝ). -/
def NewtonPolytope {n : ℕ} (p : Finset (TropMonomial n)) : Set (Fin n → ℝ) :=
  convexHull ℝ (p.image (fun m => (fun i => (m.exp i : ℝ))) : Set (Fin n → ℝ))

/-- The tropical polynomial evaluation is the Legendre-Fenchel transform
    of the indicator of the lifted Newton polytope. Specifically,
    tropPolyEval p hp x = sup_{α ∈ exponents(p)} (c_α + ⟨α, x⟩). -/
theorem tropPolyEval_eq_support_function {n : ℕ}
    (p : Finset (TropMonomial n)) (hp : p.Nonempty) (x : Fin n → ℝ) :
    tropPolyEval p hp x = p.sup' hp (fun m => m.coeff + ∑ i, (m.exp i : ℝ) * x i)
```

**Proof strategy**: This is essentially by definition, connecting the tropical polynomial to support function language. The deeper theorem relates the combinatorial type of the tropical hypersurface to the normal fan of the Newton polytope.

**Formalization plan**: Define `NewtonPolytope` using `convexHull`. State and prove the support function identity. Then formalize the regular subdivision theorem: for generic coefficients, the cells of the tropical hypersurface correspond to faces of a lifted polytope in dimension `n+1`.

**Cross-domain significance**: This is the central bridge between tropical geometry and polyhedral combinatorics. It connects tropical curves to triangulations, tropical intersection theory to mixed volumes, and tropical optimization to linear programming duality.

---

## 4. Tropical Line in Dimension 2: The Standard Tripod

**Theorem statement**:

```lean
/-- A standard tropical line in ℝ² is defined by three monomials:
    the constant term c₀, the x-term c₁ + x, and the y-term c₂ + y. -/
def standardTropLine (c₀ c₁ c₂ : ℝ) : Finset (TropMonomial 2) :=
  {⟨c₀, ![0, 0]⟩, ⟨c₁, ![1, 0]⟩, ⟨c₂, ![0, 1]⟩}

/-- The tropical line has exactly three rays emanating from a single vertex.
    When c₀ = c₁ = c₂ = 0, the vertex is the origin and the three rays
    point in directions (-1,0), (0,-1), and (1,1). -/
theorem tropLine_vertex {x y : ℝ} :
    IsTropRoot (standardTropLine 0 0 0) ⟨by decide⟩ ![x, y] ↔
    (x ≤ 0 ∧ y ≤ 0 ∧ x = y) ∨
    (x ≤ 0 ∧ y ≤ x) ∨
    (y ≤ 0 ∧ x ≤ y)
```

**Proof strategy**: Direct computation. The three monomials evaluate to `0`, `x`, and `y` respectively. The tropical root condition requires two of these to tie and dominate the third. Case analysis gives three linear conditions corresponding to three rays meeting at the origin.

**Formalization plan**: Define the standard tropical line, compute evaluations, and prove the characterization by case analysis on which pair of monomials achieves the maximum.

**Cross-domain significance**: This is the "hello world" of tropical geometry — the simplest nontrivial example. It demonstrates that tropical curves look qualitatively different from classical algebraic curves: they are piecewise-linear graphs (metric trees) rather than smooth manifolds. The tripod structure is fundamental to tropical enumerative geometry and Mikhalkin's correspondence theorem.

---

## 5. Optimization Bridge: Nondifferentiability Locus

**Theorem statement**:

```lean
/-- A max-affine function is a tropical polynomial where exponents
    are interpreted as slope vectors. -/
def MaxAffineFunc (n k : ℕ) := Fin k → (Fin n → ℝ) × ℝ  -- (slope, intercept) pairs

/-- The active set at a point: indices whose affine piece achieves the max. -/
def activeSet {n k : ℕ} (f : MaxAffineFunc n k) (x : Fin n → ℝ) : Finset (Fin k) :=
  Finset.univ.filter (fun j => ∀ j', innerProduct (f j).1 x + (f j).2 ≤
                                      innerProduct (f j').1 x + (f j').2 →
                                      innerProduct (f j).1 x + (f j).2 =
                                      innerProduct (f j').1 x + (f j').2)

/-- The nondifferentiability locus of a max-affine function equals
    the tropical hypersurface of the corresponding tropical polynomial. -/
theorem nondiff_locus_eq_tropHypersurface {n k : ℕ}
    (slopes : Fin k → Fin n → ℝ) (intercepts : Fin k → ℝ) :
    {x : Fin n → ℝ | ¬DifferentiableAt ℝ (fun x => ⨆ j : Fin k,
      (∑ i, slopes j i * x i + intercepts j)) x} =
    TropHypersurface (correspondingTropPoly slopes intercepts) ⟨...⟩
```

**Proof strategy**: A convex function that is the max of finitely many affine functions is differentiable at a point if and only if a unique affine piece achieves the maximum. This is a standard result in convex analysis. The tropical hypersurface is exactly the set where uniqueness fails.

**Formalization plan**: This requires connecting to Mathlib's convex analysis infrastructure (`ConvexOn`, `DifferentiableAt`). First establish that `fun x => max (f x) (g x)` is differentiable where `f` or `g` strictly dominates, using subdifferential characterizations.

**Cross-domain significance**: This is the deepest bridge in the roadmap. It connects tropical geometry to:
- **Neural networks**: ReLU networks compute max-affine functions; their decision boundaries are tropical hypersurfaces.
- **Robust optimization**: The nondifferentiability locus is where the optimal solution jumps between active constraints.
- **Convex analysis**: Tropical geometry provides a combinatorial language for the Legendre-Fenchel transform.
- **Subgradient methods**: The tropical cell structure determines the convergence geometry of subgradient optimization algorithms.

---

## Cross-Cutting Research Themes

### A. Tropical Convexity
Develop a theory of tropical convex sets (closed under tropical linear combinations `max(a + x, b + y)`). Prove that tropical convex hulls are polyhedral. Connect to the existing formalization via the observation that each PairCell is a tropical halfspace.

### B. Max-Plus Spectral Theory
Formalize the max-plus eigenvalue problem: given a matrix `A : Fin n → Fin n → ℝ`, find `λ` and `v` with `max_j (A_{ij} + v_j) = λ + v_i`. Connect the eigenspace geometry to tropical hypersurfaces of the characteristic polynomial.

### C. Tropical Intersection Theory
Define tropical intersection multiplicities via balancing conditions. Prove Bézout's theorem for tropical curves in the plane: two generic tropical curves of degrees `d₁` and `d₂` intersect in `d₁ · d₂` points (counted with multiplicity).

### D. Certified Piecewise-Linearity
Prove that every tropical hypersurface admits a finite polyhedral complex structure. This is the gateway to computational tropical geometry: algorithms for tropical Gröbner bases, tropical resultants, and tropical discriminants.

---

## Implementation Priority

| Priority | Target | Estimated Difficulty | Dependencies |
|----------|--------|---------------------|--------------|
| 1 | Strict dominance regions (convex complement) | Medium | Current file |
| 2 | Tropical line classification | Easy-Medium | Current file |
| 3 | Empty interior theorem | Medium | Closedness (done) |
| 4 | Newton polytope bridge | Hard | Mathlib convex hull |
| 5 | Nondifferentiability characterization | Hard | Mathlib differentiability |
