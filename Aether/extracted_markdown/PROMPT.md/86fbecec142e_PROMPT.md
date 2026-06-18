## Research Task: EML universal approximation under pullback along continuous feature maps

Research Mode: PROVE

Establish a pullback-stability theorem for uniform approximation by EML classes. The key point is that approximation should not be phrased on all of `C(X, ℝ)` unless `φ` is injective: the correct target is the closed subalgebra of continuous functions on `X` that are constant on fibers of `φ`. This is the natural functional-analytic object associated to a feature map, and proving density there gives a robust transport principle for universal approximation across representation maps.

### Main theorem package

Work with compact Hausdorff spaces first if that makes the Lean development smoother; compact metric spaces are a special case and are enough for the intended applications. Use `ContinuousMap` with the uniform norm topology.

A good concrete formulation is:

```lean
open scoped Topology
open Topology

variable {X Y : Type*}
variable [TopologicalSpace X] [CompactSpace X]
variable [TopologicalSpace Y] [CompactSpace Y]
variable [T2Space X] [T2Space Y]

/-- Continuous functions on `X` that are constant on fibers of `φ`. -/
def FiberConst (φ : C(X, Y)) : Subalgebra ℝ C(X, ℝ) where
  carrier := {g | ∀ ⦃x x' : X⦄, φ x = φ x' → g x = g x'}
  algebraMap_mem' r := by
    intro x x' h
    simp
  add_mem' := by
    intro f g hf hg x x' h
    simp [hf h, hg h]
  zero_mem' := by
    intro x x' h
    simp
  mul_mem' := by
    intro f g hf hg x x' h
    simp [hf h, hg h]
  one_mem' := by
    intro x x' h
    simp
  smul_mem' := by
    intro r f hf x x' h
    simp [hf h]
```

Then define the pullback homomorphism:

```lean
/-- Pullback of continuous real-valued functions along `φ`. -/
def pullbackAlg (φ : C(X, Y)) : C(Y, ℝ) →ₐ[ℝ] C(X, ℝ) where
  toFun := fun f => f.comp φ
  map_zero' := by ext x <;> simp
  map_one' := by ext x <;> simp
  map_add' := by intro f g; ext x <;> simp
  map_mul' := by intro f g; ext x <;> simp
  commutes' := by intro r; ext x <;> simp
```

First prove its range lands in `FiberConst φ`:

```lean
theorem pullback_mem_fiberConst (φ : C(X, Y)) (f : C(Y, ℝ)) :
    pullbackAlg φ f ∈ FiberConst φ := by
  intro x x' h
  simp [pullbackAlg, h]
```

Then prove the exact density statement for a dense subalgebra `A` of `C(Y, ℝ)`:

```lean
theorem denseRange_pullback_of_denseRange
    (φ : C(X, Y))
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : Dense (A : Set C(Y, ℝ))) :
    Dense ((pullbackAlg φ) '' (A : Set C(Y, ℝ)) : Set (FiberConst φ)) := by
  -- precise proof to be developed
  sorry
```

If coercions into the subtype are awkward, an equivalent and often easier statement is:

```lean
theorem closure_range_pullback_eq_fiberConst
    (φ : C(X, Y))
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : Dense (A : Set C(Y, ℝ))) :
    Closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ))
      = (FiberConst φ : Set C(X, ℝ)) := by
  sorry
```

A stronger and more conceptual theorem should also be proved:

```lean
theorem fiberConst_eq_range_pullback_of_quotient_lift
    (φ : C(X, Y))
    (hclosed : IsClosed (Set.range φ)) :
    (FiberConst φ : Set C(X, ℝ)) ⊆ Set.range (pullbackAlg φ) := by
  sorry
```

In the compact Hausdorff setting, `Set.range φ` is compact hence closed in `Y`, so `hclosed` is automatic. This theorem gives not just density but exact factorization through the image. Once this is in place, the density theorem becomes a clean consequence of density of restrictions of `A` to `range φ`.

### Precise bridge corollaries

1. **Injective feature map transports universal approximation to all of `C(X, ℝ)`**

```lean
theorem closure_range_pullback_eq_top_of_injective
    (φ : C(X, Y))
    (hφ : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : Dense (A : Set C(Y, ℝ))) :
    Closure (((pullbackAlg φ) '' (A : Set C(Y, ℝ))) : Set C(X, ℝ)) = Set.univ := by
  sorry
```

A more type-correct algebraic version is:

```lean
theorem fiberConst_eq_top_of_injective
    (φ : C(X, Y))
    (hφ : Function.Injective φ) :
    FiberConst φ = ⊤ := by
  sorry
```

and then combine it with the main closure theorem.

2. **Surjective feature map identifies fiber-constant functions with all pullbacks from `Y`**

```lean
theorem fiberConst_eq_range_pullback_of_surjective
    (φ : C(X, Y))
    (hφ : Function.Surjective φ) :
    (FiberConst φ : Set C(X, ℝ)) = Set.range (pullbackAlg φ) := by
  sorry
```

This gives a descent theorem: every continuous observable on `Y` corresponds exactly to a fiber-constant continuous observable on `X`, and dense EML classes on `Y` approximate all such observables after pullback.

3. **Approximation statement in ε-form**

This is often more directly useful than closure equality:

```lean
theorem exists_pullback_approx_of_fiberConst
    (φ : C(X, Y))
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : Dense (A : Set C(Y, ℝ)))
    (g : C(X, ℝ))
    (hg : g ∈ FiberConst φ)
    {ε : ℝ} (hε : 0 < ε) :
    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
  sorry
```

and, under injectivity,

```lean
theorem exists_pullback_approx_of_injective
    (φ : C(X, Y))
    (hφ : Function.Injective φ)
    (A : Subalgebra ℝ C(Y, ℝ))
    (hA : Dense (A : Set C(Y, ℝ)))
    (g : C(X, ℝ))
    {ε : ℝ} (hε : 0 < ε) :
    ∃ f ∈ A, ‖(pullbackAlg φ f : C(X, ℝ)) - g‖ < ε := by
  sorry
```

### Core proof strategy

The mathematically right proof is through the image/factorization picture, not by trying to approximate fiber-constant functions directly on `X`.

1. **Show pullbacks are fiber-constant and define a norm-decreasing algebra map.**  
   Prove `pullbackAlg φ f ∈ FiberConst φ` for all `f`. Also prove the operator norm estimate
   ```lean
   theorem norm_pullback_le (φ : C(X, Y)) (f : C(Y, ℝ)) :
       ‖pullbackAlg φ f‖ ≤ ‖f‖ := by
     -- use `ContinuousMap.norm_le` / sup norm definition pointwise
     sorry
   ```
   This gives continuity of the pullback map and lets you push density through closures.

2. **Identify fiber-constant functions with functions on the image.**  
   Let `Z := Set.range φ` with the subspace topology. Define
   ```lean
   def factorThroughRange (φ : C(X, Y)) :
       C(Z, ℝ) →ₐ[ℝ] C(X, ℝ)
   ```
   by composition with the map `X → Z`, `x ↦ ⟨φ x, ⟨x, rfl⟩⟩`.  
   Then prove:
   - its range is exactly `FiberConst φ`;
   - for every `g ∈ FiberConst φ`, the candidate inverse on `Z` is
     ```lean
     z ↦ g z.choose
     ```
     where `z : Set.range φ`, and this is well-defined by fiber-constancy.
   The only delicate point is continuity of this inverse. Avoid quotient machinery if possible: on `Set.range φ`, define the function by choice and prove continuity using the universal property of the quotient induced by `φ`, or more concretely use compactness/Hausdorff plus graph arguments if that is easier in Lean. If quotient machinery for `ContinuousMap.lift` along surjections is available, use it.

3. **Restrict approximants to the compact image.**  
   Since `X` is compact and `φ` continuous, `Set.range φ` is compact. In a Hausdorff space it is closed. Define the restriction homomorphism
   ```lean
   def restrictRange (A : Subalgebra ℝ C(Y, ℝ)) (φ : C(X, Y)) :
       Subalgebra ℝ C(Set.range φ, ℝ)
   ```
   as the image of `A` under restriction.  
   Then prove that if `A` is dense in `C(Y, ℝ)`, its restrictions are dense in `C(Set.range φ, ℝ)`. This should follow from Tietze extension on compact Hausdorff spaces:
   - given `h : C(Set.range φ, ℝ)` and `ε > 0`,
   - extend `h` to `H : C(Y, ℝ)`,
   - approximate `H` uniformly by some `a ∈ A`,
   - restrict back to obtain an approximation to `h`.
   So an intermediate lemma of the form
   ```lean
   theorem dense_restrict_of_dense
       (A : Subalgebra ℝ C(Y, ℝ))
       (hA : Dense (A : Set C(Y, ℝ)))
       (K : Set Y) [CompactSpace K] :
       Dense (((fun f : C(Y, ℝ) => f.restrict K) '' (A : Set C(Y, ℝ))) :
         Set C(K, ℝ)) := by
     sorry
   ```
   would be very valuable.

4. **Transport density back to `X`.**  
   Compose the dense restricted class on `Set.range φ` with `factorThroughRange φ`. Since the latter has image exactly `FiberConst φ`, you get density in `FiberConst φ`. This is the conceptual heart:
   ```text
   A dense in C(Y)
   ⇒ A|range(φ) dense in C(range(φ))
   ⇒ {h ∘ φ : h ∈ A|range(φ)} dense in FiberConst(φ).
   ```

5. **Injective case collapses fiber-constancy to no condition.**  
   If `φ` is injective, prove `FiberConst φ = ⊤` by
   ```lean
   intro g; intro x x' h; exact congrArg g (hφ h)
   ```
   or directly:
   ```lean
   theorem mem_fiberConst_iff_of_injective
       (φ : C(X, Y)) (hφ : Function.Injective φ) (g : C(X, ℝ)) :
       g ∈ FiberConst φ := by
     intro x x' h
     exact by simpa [hφ h]
   ```
   Then the main theorem immediately upgrades to density in all of `C(X, ℝ)`.

### Important technical lemmas likely needed

Prove and package these as reusable lemmas; they are likely more valuable than one monolithic theorem.

```lean
theorem fiberConst_closed (φ : C(X, Y)) :
    IsClosed (FiberConst φ : Set C(X, ℝ)) := by
  sorry
```

A good route: write
```lean
FiberConst φ = ⋂ (x : X) (x' : X), ⋂ (h : φ x = φ x'),
  {g | g x = g x'}
```
and note each evaluation-equality set is closed because evaluation maps are continuous.

```lean
theorem range_comp_subalgebra_subset_fiberConst
    (φ : C(X, Y)) (A : Subalgebra ℝ C(Y, ℝ)) :
    ((pullbackAlg φ) '' (A : Set C(Y, ℝ))) ⊆ (FiberConst φ : Set C(X, ℝ)) := by
  intro g hg
  rcases hg with ⟨f, hf, rfl⟩
  exact pullback_mem_fiberConst φ f
```

```lean
theorem pullback_isometry_of_surjective
    (φ : C(X, Y)) (hφ : Function.Surjective φ) (f : C(Y, ℝ)) :
    ‖pullbackAlg φ f‖ = ‖f‖ := by
  sorry
```

This is useful in the surjective case and strengthens the descent theorem.

```lean
theorem fiberConst_eq_univ_iff_injective
    (φ : C(X, Y)) :
    (FiberConst φ = ⊤) ↔ Function.Injective φ := by
  sorry
```

The reverse implication should use Urysohn separation on compact Hausdorff spaces: if `φ x = φ x'` with `x ≠ x'`, choose `g : C(X, ℝ)` separating `x` and `x'`; then `g ∉ FiberConst φ`. This gives a sharp structural characterization.

### Suggested Lean organization

A practical route is to split into three files/sections internally:

1. `FiberConst` definitions and algebra/topological properties:
   - `FiberConst φ` as a `Subalgebra`
   - `pullbackAlg`
   - closedness of `FiberConst`
   - easy inclusion `range pullback ⊆ FiberConst`

2. Image factorization:
   - `Set.range φ` compact/closed
   - factor map `X → Set.range φ`
   - algebra equivalence between `C(Set.range φ, ℝ)` and `FiberConst φ`
     ```lean
     def fiberConstEquivRange (φ : C(X, Y)) :
         C(Set.range φ, ℝ) ≃ₐ[ℝ] FiberConst φ := ...
     ```
   This is the central structural theorem.

3. Density transport:
   - restriction of dense subalgebras to closed subsets remains dense
   - deduce closure equality / ε-approximation theorem
   - injective and surjective corollaries

### Why this matters

This theorem gives the correct topological invariance principle for EML approximation under representation maps. Universal approximation should be stable under passing to feature coordinates, but only up to the information lost by the feature map. The subalgebra `FiberConst φ` captures exactly the observables visible through `φ`. Proving density there cleanly separates two phenomena:

- **representation loss**: non-injective `φ` forces approximation only of fiber-constant targets;
- **representation transport**: injective `φ` transports full universal approximation from `Y` back to `X`.

This is a new bridge between the EML approximation program and topology of feature embeddings/factor maps. It is stronger than a one-off closure lemma: it gives a reusable categorical principle for transporting approximation theorems along continuous maps, and it should become a foundational tool for later work on learned representations, invariants, quotient architectures, and approximation on latent spaces.

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
