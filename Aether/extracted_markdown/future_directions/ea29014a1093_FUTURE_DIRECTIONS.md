# Future Directions: Beyond the Compact Tropical Choquet–Radon Theorem

The formalized compact tropical Choquet–Radon representation opens several
concrete research frontiers. Each direction below is formalization-ready,
building directly on the definitions and theorems established in
`Bridges/CompactTropicalChoquetRadon.lean`.

---

## 1. Tropical Prokhorov Compactness for Maxitive Capacities

**Statement.** The space of normalized maxitive capacities on a compact
Hausdorff space `X`, equipped with the weak-* topology induced by the
Choquet–Radon pairing, is itself compact.

**Formalization target:**
```lean
theorem tropical_prokhorov_compact (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] :
    CompactSpace {Λ : UCTropicalFunctional X // Λ.toFun 0 = 0}
```

**Why it matters.** This is the idempotent analogue of Prokhorov's theorem
in probability. It guarantees that sequences of max-plus measures always
have convergent subsequences, enabling variational arguments in tropical
optimization and idempotent probability.

**Key ingredients.** The Choquet–Radon representation converts the problem
to compactness of a space of set functions, which can be attacked via
Tychonoff's theorem applied to the product `∏_{K : Compacts X} [⊥, 0]`.

---

## 2. Idempotent Kantorovich Duality on Compact Spaces

**Statement.** For compact Hausdorff `X, Y` and a continuous cost function
`c : X × Y → ℝ`, the max-plus optimal transport cost equals the inf-plus
Kantorovich dual:

```
sup_{π maxitive coupling} ∫⊕ c dπ = inf_{(f,g) : f(x)+g(y) ≤ c(x,y)} (Λ(f) + Μ(g))
```

**Formalization target:**
```lean
theorem tropical_kantorovich_duality
    (Λ : UCTropicalFunctional X) (Μ : UCTropicalFunctional Y)
    (c : C(X × Y, ℝ)) :
    ⨆ (π : UCTropicalFunctional (X × Y))
      (hπ₁ : pushforwardFunctional (ContinuousMap.fst) π = Λ)
      (hπ₂ : pushforwardFunctional (ContinuousMap.snd) π = Μ),
      π c
    = ⨅ (fg : C(X, ℝ) × C(Y, ℝ))
      (h : ∀ x y, fg.1 x + fg.2 y ≤ c (x, y)),
      Λ fg.1 + Μ fg.2
```

**Why it matters.** This is the foundation for tropical Wasserstein geometry.
The compact representation theorem provides the "measure side" of the duality;
the Kantorovich dual gives the "function side."

---

## 3. Support-Spectral Duality for Tropical Function Algebras

**Statement.** There is a categorical equivalence between:
- Closed supports (compact subsets of `X` arising as `tropSupport Λ`)
- Maximal tropical ideals in `C(X, ℝ)` under max-plus structure

**Formalization target:**
```lean
theorem tropical_gelfand_spectrum (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] :
    ∀ S : Set X, IsClosed S →
      ∃ Λ : UCTropicalFunctional X, tropSupport Λ = S
```

**Why it matters.** This is the tropical Gelfand theorem: it identifies
the "spectrum" of the max-plus algebra `C(X, ℝ)` with the space of
compact subsets of `X`. It connects tropical algebraic geometry to
the topological support theory established in our formalization.

---

## 4. Choquet Boundary Theory for Idempotent Convex Compacta

**Statement.** For the convex compact set of normalized UCTropicalFunctionals
on `X`, there exists a smallest closed face (the Choquet boundary) such that
every functional is the "max-plus barycenter" of a capacity supported on
this boundary.

**Formalization target:**
```lean
def choquetBoundary (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] : Set X :=
  ⋂ (Λ : UCTropicalFunctional X), tropSupport Λ

theorem choquet_boundary_represents
    (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    ∃ K : Compacts X, (K : Set X) ⊆ choquetBoundary X ∧
      Λ.toFun f = compactCapacity Λ K + infOnCompact f K
```

**Why it matters.** Classical Choquet theory identifies extreme points of
convex compact sets as the "essential" representatives. The tropical analogue
identifies the essential compact carriers, which correspond to tropical
vertices in tropical convexity.

---

## 5. Stone–Weierstrass Approximation for Tropical Function Semimodules

**Statement.** A max-plus subsemimodule of `C(X, ℝ)` that separates
points and contains constants is dense in the compact-open topology.

**Formalization target:**
```lean
theorem tropical_stone_weierstrass
    (A : Set C(X, ℝ))
    (h_max : ∀ f g ∈ A, f ⊔ g ∈ A)
    (h_shift : ∀ f ∈ A, ∀ c : ℝ, f + ContinuousMap.const X c ∈ A)
    (h_sep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y)
    (h_const : ∀ c : ℝ, ContinuousMap.const X c ∈ A) :
    Dense A
```

**Why it matters.** This is the foundation for computational approximation
in tropical analysis. It guarantees that any continuous observable can be
uniformly approximated by "tropical polynomials" (finite max-plus combinations),
which is exactly what makes tropical optimization tractable.

---

## Dependencies and Ordering

The recommended formalization order is:

1. **Stone–Weierstrass** (independent, uses only function space topology)
2. **Support-Spectral Duality** (uses tropSupport from our theorem)
3. **Prokhorov Compactness** (uses the representation theorem + Tychonoff)
4. **Choquet Boundary** (uses Prokhorov + spectral duality)
5. **Kantorovich Duality** (uses everything above)

Each theorem builds on the compact tropical Choquet–Radon representation
as its foundational layer.
