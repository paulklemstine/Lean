## Research Task: finite-dimensional vector-valued Stone–Weierstrass for EML via dual-basis scalarization

Research Mode: PROVE

Develop a finite-dimensional vector-valued extension of the scalar EML Stone–Weierstrass theorem by reducing approximation in `C(X,V)` to simultaneous scalar approximation along a finite dual basis of `V`. The target result should be stated for concrete finite-dimensional real normed spaces and should be strong enough to serve as the main approximation theorem for multi-output EML models.

### Precise theorem package to aim for

Work with:
- `X : Type*` with `[TopologicalSpace X] [CompactSpace X]`
- `V : Type*` with `[NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]`

Use `C(X, V)` as `ContinuousMap X V`.

The cleanest main theorem is a density statement parameterized by a class `A : Set (ContinuousMap X V)` that is closed under finite linear combinations with constant vectors and whose scalarizations are dense. A good formal target is:

```lean
theorem denseRange_of_dual_basis_scalar_approx
    {X V : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]
    (A : Set (ContinuousMap X V))
    (hzero : (0 : ContinuousMap X V) ∈ A)
    (hadd : ∀ {f g}, f ∈ A → g ∈ A → f + g ∈ A)
    (hsmul : ∀ (c : ℝ) {f}, f ∈ A → c • f ∈ A)
    (hconst_smul :
      ∀ (φ : ContinuousMap X ℝ) (v : V),
        (∃ g ∈ A, True) →  -- replace by your preferred scalar-realizability hypothesis
        ((fun x => φ x • v) : ContinuousMap X V) ∈ closure A)
    (hscalar_dense :
      ∀ (ℓ : V →L[ℝ] ℝ) (g : ContinuousMap X ℝ),
        ∀ ε > 0, ∃ f ∈ A, ‖fun x => ℓ (f x) - g x‖∞ < ε)
    :
    closure A = ⊤
```

But this is likely too abstract to prove directly. A more Lean-friendly and mathematically sharper route is to isolate the finite-dimensional reconstruction lemma first, then deduce density.

#### Core reconstruction lemma
Choose a basis `b : Basis ι ℝ V` with `[Fintype ι]`, and use its coordinate functionals `b.coord i : V →ₗ[ℝ] ℝ`.

Prove a sup-norm estimate of the following shape:

```lean
theorem exists_uniform_vector_approx_of_coordinate_approx
    {X V ι : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [Fintype ι] [Finite ι]
    (b : Basis ι ℝ V)
    (g : ContinuousMap X V) :
    ∃ C > 0,
      ∀ ε > 0,
      ∀ φ : ι → ContinuousMap X ℝ,
      (∀ i, ‖fun x => φ i x - b.coord i (g x)‖∞ < ε) →
      ‖fun x => (∑ i, (φ i x) • b i) - g x‖∞ < C * ε
```

A more practical equivalent is pointwise first, then take sup over compact `X`:

```lean
theorem norm_le_coord_sup
    {V ι : Type*}
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [Fintype ι]
    (b : Basis ι ℝ V) :
    ∃ C > 0, ∀ v : V, ‖v‖ ≤ C * ‖fun i => b.coord i v‖
```

or with `Finset.sup'` / `iSup` replaced by a finite max-norm on coordinates if easier:

```lean
theorem norm_le_max_coord
    {V ι : Type*}
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [Fintype ι]
    (b : Basis ι ℝ V) :
    ∃ C > 0, ∀ v : V, ‖v‖ ≤ C * (Finset.univ.sup' Finset.univ_nonempty (fun i => ‖b.coord i v‖))
```

Then derive:

```lean
theorem supNorm_reconstruction_bound
    {X V ι : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [Fintype ι]
    (b : Basis ι ℝ V) :
    ∃ C > 0,
      ∀ (ψ : ι → ContinuousMap X ℝ) (g : ContinuousMap X V),
      ‖fun x => (∑ i, (ψ i x) • b i) - g x‖∞
        ≤ C * (Finset.univ.sup' Finset.univ_nonempty
            (fun i => ‖fun x => ψ i x - b.coord i (g x)‖∞))
```

Here the reconstructed approximant is the continuous map
```lean
{ toFun := fun x => ∑ i, (ψ i x) • b i, ... }
```
and the key identity is
```lean
(∑ i, (ψ i x) • b i) - g x = ∑ i, (ψ i x - b.coord i (g x)) • b i
```
followed by the coordinate-norm estimate.

#### Density theorem from scalarization
Once the reconstruction bound is available, formulate the actual vector-valued approximation theorem in a closure/density form. A concrete and provable statement is:

```lean
theorem mem_closure_of_coordinatewise_dense
    {X V ι : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]
    [Fintype ι]
    (b : Basis ι ℝ V)
    (A : Set (ContinuousMap X V))
    (hadd_closure : ∀ {f g}, f ∈ closure A → g ∈ closure A → f + g ∈ closure A)
    (hsmul_closure : ∀ (c : ℝ) {f}, f ∈ closure A → c • f ∈ closure A)
    (hcoord_lift :
      ∀ (i : ι) (φ : ContinuousMap X ℝ),
        φ ∈ closure {ψ : ContinuousMap X ℝ | ∃ f ∈ A, ψ = ContinuousMap.compCLM (b.coord i).toContinuousLinearMap f} →
        ((fun x => φ x • b i) : ContinuousMap X V) ∈ closure A)
    (hscalar_dense :
      ∀ (i : ι), closure {ψ : ContinuousMap X ℝ | ∃ f ∈ A, ψ = ContinuousMap.compCLM (b.coord i).toContinuousLinearMap f} = ⊤)
    :
    closure A = ⊤
```

This may still be technically heavy. A better final theorem, closer to the intended EML application, is:

```lean
theorem dense_of_dual_basis_scalar_density
    {X V ι : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [NormedAddCommGroup V] [NormedSpace ℝ V] [FiniteDimensional ℝ V]
    [Fintype ι]
    (b : Basis ι ℝ V)
    (S : Set (ContinuousMap X ℝ))
    (hS_dense : closure S = ⊤)
    (A : Set (ContinuousMap X V))
    (h_sum_of_coords :
      ∀ ψ : ι → ContinuousMap X ℝ,
        (∀ i, ψ i ∈ closure S) →
        ((fun x => ∑ i, (ψ i x) • b i) : ContinuousMap X V) ∈ closure A)
    :
    closure A = ⊤
```

Then instantiate `S` as the scalarized EML class coming from `A` and use the scalar Stone–Weierstrass theorem already available.

### Preferred EML-facing corollary

After the abstract finite-dimensional theorem, derive an EML-style corollary for `V = Fin n → ℝ` or `V = EuclideanSpace ℝ (Fin n)`, since this is the most concrete codomain for multi-output approximation and easiest to use in downstream files.

A very practical target is:

```lean
theorem eml_uniform_dense_finvec
    {X : Type*}
    [TopologicalSpace X] [CompactSpace X]
    (n : ℕ)
    (A : Set (ContinuousMap X (Fin n → ℝ)))
    (hcoord :
      ∀ i : Fin n,
        closure {φ : ContinuousMap X ℝ | ∃ f ∈ A, ∀ x, φ x = f x i} = ⊤)
    (hassemble :
      ∀ ψ : Fin n → ContinuousMap X ℝ,
        (∀ i, ψ i ∈ closure {φ : ContinuousMap X ℝ | ∃ f ∈ A, ∀ x, φ x = f x i}) →
        ((fun x i => ψ i x) : ContinuousMap X (Fin n → ℝ)) ∈ closure A) :
    closure A = ⊤
```

Because `Fin n → ℝ` has a canonical basis and the sup norm is coordinatewise, this version may avoid the hardest norm-equivalence lemma and can serve as the first fully formalized result before upgrading to arbitrary finite-dimensional `V`.

### Proof strategy: concrete steps

1. **Fix a basis and coordinate functionals.**  
   Use `FiniteDimensional.finBasis` or a chosen `Basis ι ℝ V`. For each `i`, let `ℓᵢ := b.coord i`. Recall the exact reconstruction identity
   ```lean
   b.sum_repr v : (∑ i, (b.coord i v) • b i) = v.
   ```
   For `g : C(X,V)`, define scalar coordinate maps
   ```lean
   gᵢ : ContinuousMap X ℝ := ContinuousMap.compCLM (b.coord i).toContinuousLinearMap g.
   ```

2. **Approximate each coordinate scalar map separately.**  
   Apply the already-proved scalar Stone–Weierstrass theorem to each `gᵢ`. Since `ι` is finite, choose a common tolerance `δ = ε / (2*C)` or `δ = ε / (C * card ι)` depending on the bound you prove. This is the only place where the scalar EML machinery enters.

3. **Reconstruct a vector-valued approximant from the scalar approximants.**  
   Given scalar approximants `φᵢ : C(X,ℝ)`, form
   ```lean
   F : ContinuousMap X V := {
     toFun := fun x => ∑ i, (φᵢ x) • b i,
     continuous_toFun := by
       simpa using continuous_finset_sum (fun i _ => (φᵢ.continuous.smul continuous_const))
   }
   ```
   If your closure hypotheses are set up correctly, show `F ∈ closure A` using closure under finite sums and scalar multiplication by constant vectors / coordinate assembly.

4. **Control the error by finite-dimensional norm equivalence.**  
   The key lemma is that on a finite-dimensional space, the norm is bounded by a constant times the max of the absolute values of coordinates in a fixed basis. Prove this either:
   - abstractly using continuity of the coordinate map and equivalence of norms on finite-dimensional spaces, or
   - concretely by defining the linear equivalence `V ≃ₗ[ℝ] (ι → ℝ)` from `b.repr`, upgrading it to a continuous linear equivalence, and using operator norm bounds:
     ```lean
     ‖v‖ = ‖(b.repr.symm) (b.repr v)‖ ≤ ‖(b.repr.symm : (ι → ℝ) →L[ℝ] V)‖ * ‖b.repr v‖.
     ```
     If you take `(ι → ℝ)` with its standard norm, this gives the desired coordinate estimate almost immediately.

5. **Upgrade pointwise coordinate control to uniform control.**  
   For every `x`,
   ```lean
   F x - g x = ∑ i, (φᵢ x - ℓᵢ (g x)) • b i.
   ```
   Apply the reconstruction bound pointwise, then take sup over `x : X`. Use the compact-domain sup norm already available on `ContinuousMap`. Choosing `δ` appropriately yields `‖F - g‖∞ < ε`, hence `g ∈ closure A`.

### Key technical lemmas worth proving separately

These are useful reusable building blocks and should be isolated rather than buried in the main proof.

```lean
theorem basis_reconstruction_sub
    {V ι : Type*}
    [NormedAddCommGroup V] [NormedSpace ℝ V] [Fintype ι]
    (b : Basis ι ℝ V) (a c : ι → ℝ) :
    (∑ i, a i • b i) - (∑ i, c i • b i) = ∑ i, (a i - c i) • b i
```

```lean
theorem continuousMap_sum_smul_basis
    {X V ι : Type*}
    [TopologicalSpace X]
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [Fintype ι]
    (b : Basis ι ℝ V) (φ : ι → ContinuousMap X ℝ) :
    ContinuousMap X V
```

```lean
theorem coord_comp_continuousMap
    {X V ι : Type*}
    [TopologicalSpace X]
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [Fintype ι]
    (b : Basis ι ℝ V) (i : ι) (g : ContinuousMap X V) :
    ContinuousMap X ℝ
```

```lean
theorem exists_coord_bound_constant
    {V ι : Type*}
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    [FiniteDimensional ℝ V] [Fintype ι]
    (b : Basis ι ℝ V) :
    ∃ C > 0, ∀ v : V,
      ‖v‖ ≤ C * (Finset.univ.sup' Finset.univ_nonempty (fun i => ‖b.coord i v‖))
```

For the concrete codomain `Fin n → ℝ`, prove the stronger exact estimate if possible:
```lean
theorem norm_finvec_le_sup_coord
    (v : Fin n → ℝ) :
    ‖v‖ ≤ Real.sqrt n * (Finset.univ.sup' Finset.univ_nonempty (fun i => ‖v i‖))
```
or even use the ambient product/sup norm if that is the instantiated norm on the chosen codomain.

### Why this matters

This theorem is the correct finite-dimensional vector-output analogue of the scalar EML Stone–Weierstrass result. It turns scalar approximation machinery into a reusable vector-valued approximation principle with minimal extra hypotheses. Formally, it provides the bridge needed for:
- multi-output EML universal approximation,
- approximation of vector fields and controlled dynamical systems,
- later operator-valued approximation results obtained by scalarizing against finitely many test functionals.

Mathematically, the nontrivial content is not the coordinate decomposition itself, but the uniform error reconstruction through a finite-dimensional norm comparison, which is exactly the ingredient that lets scalar density imply vector density in a robust and reusable Lean form.

A good execution plan is:
1. first prove the theorem for `V = Fin n → ℝ`,
2. then abstract the reconstruction argument to an arbitrary basis,
3. finally package the result as a codomain-lifting theorem from scalar EML density to finite-dimensional vector EML density.

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
