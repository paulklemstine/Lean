# Future Directions: Support Duality for Idempotent EML Functionals

Building directly on the support duality theorems established in this work, here are five concrete next steps spanning categorical, algorithmic, and analytic extensions.

---

## 1. Categorical Duality: Support as a Contravariant Functor (Categorical)

**Statement**: Define a category **TropFunc** whose objects are pairs `(X, Λ)` of a topological space with a UCTropicalFunctional, and morphisms are continuous maps `φ : X → Y` equipped with a pushforward relation `Λ_X ↦ pushforward φ Λ_X`. Then `supportOf` defines a contravariant functor from **TropFunc** to the category **ClSets** of topological spaces with closed subsets, sending `(X, Λ)` to `(X, supportOf Λ)` and morphisms to image maps on closed sets.

**Lean target**:
```lean
-- Define the category structure
structure TropFuncMor (X Y : Type*) [TopologicalSpace X] [TopologicalSpace Y] where
  map : X → Y
  hcont : Continuous map
  source : UCTropicalFunctional X
  target : UCTropicalFunctional Y
  compat : target = UCTropicalFunctional.pushforward map hcont source

-- Prove functoriality of support
theorem support_functor_comp {X Y Z : Type*} ... :
    supportOf (pushforward (ψ ∘ φ) _ Λ) = supportOf (pushforward ψ _ (pushforward φ _ Λ))
```

**Why it matters**: This turns the support theory into a genuine piece of categorical infrastructure, enabling transport of support data across adjunctions and natural transformations in tropical geometry.

---

## 2. Decidable Support Computation on Finite Types (Algorithmic)

**Statement**: On a finite discrete space `X` with `Fintype X` and `DecidableEq X`, implement a decidable procedure that computes `supportOf Λ` as a `Finset X` by evaluating `Λ(peakAt x)` for each `x ∈ Finset.univ`.

**Lean target**:
```lean
def computeSupport [Fintype X] [DecidableEq X] [DiscreteTopology X]
    (Λ : UCTropicalFunctional X) : Finset X :=
  Finset.univ.filter (fun x => Λ.toFun (peakAt x) ≠ ⊥)

theorem computeSupport_eq_supportOf :
    ↑(computeSupport Λ) = supportOf Λ
```

**Why it matters**: This makes support a computable invariant, enabling machine-verified classification of finite tropical functionals. Combined with the uniqueness theorem, two functionals can be algorithmically compared by checking their supports and peak values.

---

## 3. Compact Hausdorff Extension: Support via Maxitive Capacities (Reconstruction)

**Statement**: For compact Hausdorff spaces, prove that `supportOf Λ` coincides with the closed support of the maxitive capacity `μ_Λ` derived from `Λ` via the tropical Riesz representation. Specifically:

```lean
theorem supportOf_eq_capacity_support [CompactSpace X] [T2Space X]
    (Λ : UCTropicalFunctional X) :
    supportOf Λ = {x | ∀ U : Set X, IsOpen U → x ∈ U → μ_Λ U ≠ ⊥}
```

**Prerequisite lemma**: The capacity `μ_Λ` must be shown to be a maxitive measure (completely max-additive set function), and the reconstruction integral `∫ᵗ f dμ_Λ = Λ(f)` must be established.

**Why it matters**: This bridges the abstract functional-analytic definition of support with the measure-theoretic carrier, creating a genuine tropical Riesz-Markov correspondence. It is the non-discrete analogue of `supportOf_eq_peakAt_nonbot`.

---

## 4. Spectral Reconstruction: Recovering Functionals from Support Data (Beyond Discrete)

**Statement**: For compact metrizable spaces, prove a reconstruction theorem analogous to `eq_of_agree_on_singleton_peaks` using Urysohn functions instead of peak functions:

```lean
theorem eq_of_agree_on_urysohn_peaks [CompactSpace X] [T2Space X] [MetrizableSpace X]
    {Λ Γ : UCTropicalFunctional X}
    (hΛ : Normalized Λ) (hΓ : Normalized Γ)
    (hsupp : supportOf Λ = supportOf Γ)
    (hurysohn : ∀ x ∈ supportOf Λ, ∀ U : Set X, IsOpen U → x ∈ U →
      ∀ f : TropCont X, f.support ⊆ U → Λ.toFun f = Γ.toFun f) :
    Λ = Γ
```

**Why it matters**: This extends the reconstruction principle from finite spaces to the full compact metrizable setting, showing that a normalized functional is uniquely determined by its local behavior on support points. Combined with Stone-Weierstrass for max-plus algebras, this could yield a tropical Gelfand duality.

---

## 5. Neural Network Mass Localization: Support of Tropical ReLU Functionals (Applications)

**Statement**: For a ReLU neural network `N : ℝⁿ → ℝ` with tropical (max-plus) structure, define the associated tropical functional `Λ_N(f) = sup_x (N(x) + f(x))` and prove that `supportOf Λ_N` equals the closure of the set of "active regions" — connected components of the input space where the network's piecewise linear structure achieves its maximum.

**Why it matters**: In machine learning, understanding where a neural network "concentrates its mass" is central to interpretability, adversarial robustness, and margin analysis. The support theory provides a mathematically rigorous framework for this: `supportOf Λ_N` is provably closed, behaves functorially under input transformations (preprocessing, augmentation), and the kernel duality theorem shows that inputs outside the support cannot affect the network's decision boundary. This connects tropical algebraic geometry to neural network certification.
