## Research Task: Stone–Weierstrass universal approximation for EML-generated subalgebras

Research Mode: PROVE

Establish a genuine density theorem upgrading the current EML closure results to a full Stone–Weierstrass-style universal approximation statement. The right target is not merely another closure lemma, but a theorem saying that an EML-realizable class, once shown to be a point-separating unital subalgebra and stable under the already-verified compositional operations, is uniformly dense in `C(X, ℝ)` on compact spaces. A second theorem should isolate the pullback mechanism: density on `Y` transfers to density of the pullback class on `X` inside the closed subalgebra of functions factoring through `φ : X → Y`, and hence to all of `C(X, ℝ)` under an injectivity / quotient-separation hypothesis.

### Precise theorem targets

Work with `C(X, ℝ) = ContinuousMap X ℝ` and the sup norm / uniform topology already available on continuous maps into a normed group. Use compact Hausdorff hypotheses in a Lean-friendly form:
- `[TopologicalSpace X] [CompactSpace X] [T2Space X]`
- `[TopologicalSpace Y] [CompactSpace Y] [T2Space Y]`

A useful formalization route is to represent the EML class as a subset `A : Set C(X, ℝ)` and package the algebraic closure assumptions explicitly, rather than first building a bundled subalgebra. Then derive a bundled `Subalgebra ℝ C(X, ℝ)` when needed.

Aim for statements of the following shape.

### 1. Stone–Weierstrass for a real subalgebra of `C(X, ℝ)`

A precise Lean-facing target:

```lean
theorem eml_uniform_dense_of_separatesPoints
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : Set.SeparatesPoints (A : Set C(X, ℝ))) :
    Dense (A.topologicalClosure : Set C(X, ℝ)) := by
```

This exact statement may need adjustment depending on the available Stone–Weierstrass theorem in Mathlib, because for a subalgebra the more canonical conclusion is:

```lean
theorem eml_topologicalClosure_eq_top_of_separatesPoints
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : Set.SeparatesPoints (A : Set C(X, ℝ))) :
    A.topologicalClosure = ⊤ := by
```

If Mathlib exposes the theorem already in a form such as `Subalgebra.topologicalClosure_eq_top_of_separatesPoints`, use that directly. If not, prove the equivalent density statement:

```lean
theorem eml_dense_range_of_subalgebra_separatesPoints
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : Set.SeparatesPoints (A : Set C(X, ℝ))) :
    Dense ((A : Set C(X, ℝ))) := by
```

but only if this is really the notion delivered by closure machinery; otherwise prefer the closure-equals-top formulation.

A more directly approximation-theoretic corollary, useful for downstream EML applications, is:

```lean
theorem eml_exists_uniform_approx
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (A : Subalgebra ℝ C(X, ℝ))
    (hsep : Set.SeparatesPoints (A : Set C(X, ℝ)))
    (f : C(X, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ g : A, ‖(g : C(X, ℝ)) - f‖ < ε := by
```

This is the theorem that most clearly expresses universal approximation.

### 2. Pullback subalgebra and density in the factor-through subspace

Define the pullback of a subalgebra along a continuous map by precomposition.

A concrete definition:

```lean
def pullbackSubalgebra
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
    Subalgebra ℝ C(X, ℝ) where
  carrier := {f | ∃ g : A, f = (g : C(Y, ℝ)).comp φ}
  ...
```

You may instead define it as the `Subalgebra.map` / `comap` under the algebra hom induced by precomposition, if that API is easier:

```lean
def precompAlgHom
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y] :
    C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) := ...
```

Then set:

```lean
def pullbackSubalgebra
    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) : Subalgebra ℝ C(X, ℝ) :=
  A.map (precompAlgHom (X := X) (Y := Y) φ)
```

Also define the factor-through subalgebra:

```lean
def factorsThroughSubalgebra
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
  carrier := {f | ∃ g : C(Y, ℝ), f = g.comp φ}
  ...
```

The key structural theorem should then be:

```lean
theorem pullback_closure_eq_factorsThrough
    {X Y : Type*}
    [TopologicalSpace X] [CompactSpace X] [T2Space X]
    [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
    (φ : C(X, Y))
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : A.topologicalClosure = ⊤) :
    (pullbackSubalgebra φ A).topologicalClosure = factorsThroughSubalgebra φ := by
```

This is the correct bridge theorem: dense approximation on `Y` transfers to dense approximation of all continuous functions on `X` that factor through `φ`.

A more pointwise approximation version:

```lean
theorem pullback_dense_on_factoring_functions
    {X Y : Type*}
    [TopologicalSpace X] [CompactSpace X] [T2Space X]
    [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
    (φ : C(X, Y))
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : A.topologicalClosure = ⊤)
    (f : C(X, ℝ))
    (hf : f ∈ factorsThroughSubalgebra φ)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ g : pullbackSubalgebra φ A, ‖(g : C(X, ℝ)) - f‖ < ε := by
```

### 3. Injective pullback corollary: density transfers to all of `C(X, ℝ)`

If `φ` is injective and `Y` is compact Hausdorff, then every continuous `f : X → ℝ` factors through `φ` on the image of `φ`, and by Tietze extension / compact embedding into Hausdorff image one can extend to all of `Y`. In Lean, the cleanest version may require assuming a factorization hypothesis rather than proving it abstractly; but the strongest desirable theorem is:

```lean
theorem pullback_dense_of_injective
    {X Y : Type*}
    [TopologicalSpace X] [CompactSpace X] [T2Space X]
    [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
    (φ : C(X, Y))
    (hφinj : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : A.topologicalClosure = ⊤) :
    (pullbackSubalgebra φ A).topologicalClosure = ⊤ := by
```

If the extension step to all of `Y` is too heavy, isolate the hard part and prove the image-subspace version first:

```lean
theorem factorsThrough_eq_top_of_embedding
    {X Y : Type*}
    [TopologicalSpace X] [CompactSpace X] [T2Space X]
    [TopologicalSpace Y] [T2Space Y]
    (φ : C(X, Y))
    (hφinj : Function.Injective φ) :
    factorsThroughSubalgebra φ = ⊤ := by
```

or a theorem using `Set.range φ` and continuous maps on the image, then compose with a separate extension lemma if available.

### 4. EML-facing corollary from closure assumptions

After the abstract theorem is in place, package it into an EML-ready statement. If `EMLClass X : Set C(X, ℝ)` is the syntactic realizable family, define the generated subalgebra:

```lean
def emlGeneratedSubalgebra (X : Type*) [TopologicalSpace X] :
    Subalgebra ℝ C(X, ℝ) := ...
```

Then prove a theorem of the form:

```lean
theorem eml_universalApproximation
    {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
    (hconst : ...)          -- constants belong to the EML class
    (hadd : ...)            -- closed under addition
    (hmul : ...)            -- closed under multiplication, or enough to generate a subalgebra
    (hsep : Set.SeparatesPoints (emlGeneratedSubalgebra X : Set C(X, ℝ))) :
    (emlGeneratedSubalgebra X).topologicalClosure = ⊤ := by
```

If multiplication is awkward but max-closure is already available and there is a lattice Stone–Weierstrass theorem in Mathlib, a parallel route is:

```lean
theorem eml_lattice_universalApproximation
    ...
    (hmax : ∀ f g ∈ A, ContinuousMap.max f g ∈ A)
    (hmin : ∀ f g ∈ A, ContinuousMap.min f g ∈ A)
    (hsep : Set.SeparatesPoints A)
    (hconst : ...)
    :
    closure A = Set.univ := by
```

But only choose the lattice route if Mathlib’s API is actually smoother than the subalgebra route.

## Proof strategy

1. **Bundle the EML closure hypotheses into an actual `Subalgebra ℝ C(X, ℝ)`**
   - Start from the EML-realizable set and prove the elementary closure lemmas needed to define a subalgebra: `0`, `1`, addition, negation, scalar multiplication, multiplication.
   - If you already have closure under finite products and enough affine operations, multiplication may be derivable from those results rather than primitive.
   - If only a generating-set statement is available, define `Subalgebra.closure` of the primitive family and work with that object.

2. **Use the existing Stone–Weierstrass theorem in Mathlib rather than reproving it**
   - Search for lemmas around `ContinuousMap`, `Subalgebra`, `topologicalClosure`, and `Set.SeparatesPoints`.
   - The likely pattern is: compact Hausdorff domain + real subalgebra + point separation + constants imply topological closure is all of `C(X, ℝ)`.
   - If the theorem is stated for a subalgebra of `C(X, 𝕜)` over `𝕜 = ℝ`, reduce your goal to that exact form and let the library theorem discharge the main analytic content.

3. **For pullbacks, construct the precomposition algebra hom and identify the image**
   - Define
     ```lean
     precompAlgHom (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ)
     ```
     by `g ↦ g.comp φ`.
   - Show that `pullbackSubalgebra φ A` is exactly `A.map (precompAlgHom φ)`.
   - Prove that `f ∈ factorsThroughSubalgebra φ` iff `∃ g, f = g.comp φ`.
   - Then show closure commutes with continuous linear/algebra hom images in the needed direction: the closure of the pullback contains all pullbacks of functions in the closure of `A`. Concretely, if `g_n → g` uniformly on `Y`, then `g_n ∘ φ → g ∘ φ` uniformly on `X`; this is the essential norm estimate.

4. **Use the sup-norm contraction under precomposition**
   - The key estimate is
     ```lean
     ‖(g.comp φ) - (h.comp φ)‖ ≤ ‖g - h‖
     ```
     for `g h : C(Y, ℝ)`.
   - Prove this either by extensionality and pointwise estimates followed by the `sInf`/`iSup` norm lemma for continuous maps, or by invoking the operator norm bound for precomposition if available.
   - This estimate is exactly what transfers density from `A` to the factor-through subalgebra.

5. **For the injective/quotient-separating corollary, reduce factoring to topology of the image**
   - If `φ` is injective and `X` compact, `Y` Hausdorff, then `φ` is a topological embedding onto a compact closed image.
   - Given `f : C(X, ℝ)`, define a continuous function on `Set.range φ` by transport along the inverse of the embedding.
   - Extend from `Set.range φ` to all of `Y` using a normality/Tietze extension theorem if available in Mathlib; compact Hausdorff suffices for normality.
   - If this extension infrastructure is not immediately available, isolate the theorem “every `f` factors through `φ` after restricting codomain to `Set.range φ`” and state the final all-of-`C(X,ℝ)` corollary under an additional extension hypothesis.

## Key intermediate lemmas worth proving explicitly

These will make the main theorem modular and reusable.

```lean
theorem mem_factorsThroughSubalgebra_iff
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (φ : C(X, Y)) (f : C(X, ℝ)) :
    f ∈ factorsThroughSubalgebra φ ↔ ∃ g : C(Y, ℝ), f = g.comp φ := by
```

```lean
theorem norm_comp_le
    {X Y : Type*} [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Y]
    (φ : C(X, Y)) (g h : C(Y, ℝ)) :
    ‖g.comp φ - h.comp φ‖ ≤ ‖g - h‖ := by
```

```lean
theorem pullback_mem_closure_of_mem_closure
    {X Y : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [TopologicalSpace Y]
    (φ : C(X, Y)) (A : Set C(Y, ℝ)) {g : C(Y, ℝ)}
    (hg : g ∈ closure A) :
    g.comp φ ∈ closure ((fun h : C(Y, ℝ) => h.comp φ) '' A) := by
```

```lean
theorem pullbackSubalgebra_le_factorsThroughSubalgebra
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
    pullbackSubalgebra φ A ≤ factorsThroughSubalgebra φ := by
```

```lean
theorem factorsThrough_of_injective
    {X Y : Type*}
    [TopologicalSpace X] [CompactSpace X] [T2Space X]
    [TopologicalSpace Y] [T2Space Y]
    (φ : C(X, Y)) (hφinj : Function.Injective φ)
    (f : C(X, ℝ)) :
    f ∈ factorsThroughSubalgebra φ := by
```

The last one is likely the technically deepest. If it becomes blocked on extension theory, split it into:
- factorization through `Set.range φ`,
- extension from `Set.range φ` to `Y`.

## Why this matters

This theorem is the missing conceptual endpoint of the EML approximation program. The current library has algebraic-compositional closure and pullback stability, but not yet the decisive functional-analytic upgrade from “closed under expressive operations” to “uniformly dense in all continuous observables.” Proving this gives a mathematically clean universal approximation theorem, not tied to ad hoc architectures but derived from the intrinsic algebra generated by EML primitives.

The pullback theorem is especially important because it turns feature engineering into a formal density-transfer principle: once density is known on a feature space `Y`, approximation on `X` follows automatically for all target functions that factor through the feature map, and for all continuous targets when the feature map is injective / quotient-complete. This provides the correct abstract bridge between EML syntax, compositional semantics, and classical topology, and it should become the central theorem connecting the earlier finite-product/max-composition results to a robust, architecture-independent approximation theory.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: EML
Research mode: prove
