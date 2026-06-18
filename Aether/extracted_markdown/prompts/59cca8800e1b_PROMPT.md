## Research Task: EML Stone–Weierstrass for compact product codomains via factorwise approximation and diagonal assembly

### Target theorem package

Work in a concrete metric-topological setting where the codomain product carries the sup metric. The core result should be stated first for arbitrary metric codomains, then specialized to the EML approximation predicates already available in the library.

A clean formal target is the following theorem schema.

```lean
theorem denseRange_pair_of_denseRange_fst_snd
    {X Y Z : Type*}
    [TopologicalSpace X]
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (AY : Set (C(X, Y))) (AZ : Set (C(X, Z)))
    (hY : ∀ f : C(X, Y), ∀ ε > 0, ∃ g ∈ AY, ∀ x, dist (g x) (f x) < ε)
    (hZ : ∀ f : C(X, Z), ∀ ε > 0, ∃ g ∈ AZ, ∀ x, dist (g x) (f x) < ε) :
    ∀ f : C(X, Y × Z), ∀ ε > 0,
      ∃ gY ∈ AY, ∃ gZ ∈ AZ,
        ∀ x, dist (gY x, gZ x) (f x) < ε
```

This statement only becomes correct after you equip `Y × Z` with the `sup`/`max` product metric. If Mathlib’s default product metric is not definitionally `max`, introduce an explicit theorem under the typeclass instance you want, or prove the corresponding estimate with whatever `Prod` metric instance is available. The ideal endpoint is a theorem where the final pointwise estimate is exactly controlled by the coordinatewise estimates.

A more structured version, closer to the intended EML use, is:

```lean
def PairClass
    {X Y Z : Type*}
    (AY : Set (C(X, Y))) (AZ : Set (C(X, Z))) : Set (C(X, Y × Z)) :=
  {f | ∃ g ∈ AY, ∃ h ∈ AZ, f = ContinuousMap.prodMk g h}

theorem pairClass_uniform_dense
    {X Y Z : Type*}
    [TopologicalSpace X]
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (AY : Set (C(X, Y))) (AZ : Set (C(X, Z)))
    (hY : ∀ f : C(X, Y), ∀ ε > 0, ∃ g ∈ AY, ∀ x, dist (g x) (f x) < ε)
    (hZ : ∀ f : C(X, Z), ∀ ε > 0, ∃ g ∈ AZ, ∀ x, dist (g x) (f x) < ε) :
    ∀ f : C(X, Y × Z), ∀ ε > 0,
      ∃ g ∈ PairClass AY AZ, ∀ x, dist (g x) (f x) < ε
```

Then specialize this to the EML-realizable classes. If the library already has a predicate such as `EMLRealizable X Y : Set (C(X,Y))`, or a theorem saying every target map can be approximated by an EML map, prove:

```lean
theorem eml_uniform_dense_prod
    {X Y Z : Type*}
    [TopologicalSpace X]
    [CompactSpace X]
    [PseudoMetricSpace Y] [CompactSpace Y]
    [PseudoMetricSpace Z] [CompactSpace Z]
    (hY : ∀ f : C(X, Y), ∀ ε > 0, ∃ g : C(X, Y), IsEML g ∧ ∀ x, dist (g x) (f x) < ε)
    (hZ : ∀ f : C(X, Z), ∀ ε > 0, ∃ g : C(X, Z), IsEML g ∧ ∀ x, dist (g x) (f x) < ε)
    (hpair : ∀ {g : C(X, Y)} {h : C(X, Z)}, IsEML g → IsEML h → IsEML (ContinuousMap.prodMk g h)) :
    ∀ f : C(X, Y × Z), ∀ ε > 0,
      ∃ g : C(X, Y × Z), IsEML g ∧ ∀ x, dist (g x) (f x) < ε
```

If the existing EML API uses `∀ x, ...` rather than `‖g - f‖∞ < ε`, stay pointwise. If there is already a uniform norm/sup-distance API on `C(X, Y)`, also prove the stronger normed formulation:

```lean
theorem pairClass_dense_uniformity
    {X Y Z : Type*}
    [TopologicalSpace X] [CompactSpace X]
    [PseudoMetricSpace Y] [PseudoMetricSpace Z] :
    ...
```

but only if the surrounding library makes this painless.

### Key supporting lemmas to prove first

The entire argument becomes easy once the product metric estimate is isolated. Prove one or both of the following, depending on the available metric instance:

```lean
theorem dist_prod_le_max
    {Y Z : Type*}
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    (a b : Y × Z) :
    dist a b ≤ max (dist a.1 b.1) (dist a.2 b.2)
```

and, more importantly for the approximation step,

```lean
theorem dist_prod_mk_lt_of_lt
    {Y Z : Type*}
    [PseudoMetricSpace Y] [PseudoMetricSpace Z]
    {y₁ y₂ : Y} {z₁ z₂ : Z} {ε : ℝ}
    (hy : dist y₁ y₂ < ε) (hz : dist z₁ z₂ < ε) :
    dist (y₁, z₁) (y₂, z₂) < ε
```

If the product metric is definitionally `max`, this should reduce to
`max_lt_iff.mpr ⟨hy, hz⟩`. If not, prove a compatible upper bound using the actual formula for `dist` on products.

You should also isolate the coordinate projection and reassembly identities for continuous maps:

```lean
theorem prodMk_fst_snd
    {X Y Z : Type*} [TopologicalSpace X]
    (f : C(X, Y × Z)) :
    ContinuousMap.prodMk
      (ContinuousMap.comp continuous_fst f)
      (ContinuousMap.comp continuous_snd f) = f
```

or, if Mathlib already has `f.fst` and `f.snd`:

```lean
theorem prodMk_fst_snd' (f : C(X, Y × Z)) :
    ContinuousMap.prodMk f.fst f.snd = f
```

This identity is the exact bridge from approximation of coordinates to approximation of the original map.

Finally, if EML closure under pairing is not already present, prove a closure theorem of the form:

```lean
theorem IsEML.prodMk
    {X Y Z : Type*}
    {g : C(X, Y)} {h : C(X, Z)} :
    IsEML g → IsEML h → IsEML (ContinuousMap.prodMk g h)
```

If the EML language is syntactic rather than semantic, the proof should go by the pairing constructor/diagonal combinator in the syntax and then interpretation soundness.

### Proof strategy

1. **Decompose the target map into coordinates.**  
   For `f : C(X, Y × Z)`, define `fY := f.fst` and `fZ := f.snd` (or via composition with `ContinuousMap.fst` and `ContinuousMap.snd`). Prove or reuse
   `ContinuousMap.prodMk fY fZ = f`. This is the exact categorical/product structure you need; avoid extensionality at the end by preparing this identity early.

2. **Approximate each coordinate separately with the same tolerance `ε`.**  
   Given `ε > 0`, apply `hY` to `fY` and `hZ` to `fZ` with the same `ε`. This gives `gY` and `gZ` with pointwise bounds
   `dist (gY x) (fY x) < ε` and `dist (gZ x) (fZ x) < ε`.  
   If the product metric theorem naturally gives a `max` bound, no need to split `ε/2`; the sup metric is specifically chosen so that coordinatewise `< ε` implies productwise `< ε`.

3. **Assemble the approximant by pairing.**  
   Set `g := ContinuousMap.prodMk gY gZ`. Show `g ∈ PairClass AY AZ` by construction. In the EML version, invoke closure under pairing:
   `IsEML gY → IsEML gZ → IsEML (ContinuousMap.prodMk gY gZ)`.

4. **Convert coordinatewise estimates into a product estimate.**  
   For each `x : X`, rewrite `f x` as `(fY x, fZ x)` and `g x` as `(gY x, gZ x)`. Then apply `dist_prod_mk_lt_of_lt` or the corresponding product-metric inequality. This is the only genuinely metric step; isolating it into a separate lemma will make the main theorem very short and robust.

5. **Optionally package the result as an induction principle for finite products.**  
   Once the binary product theorem is proved, state a corollary for iterated products, e.g. `Y × Z × W`, by repeated application. Even if you do not formalize full arbitrary finite products, a ternary corollary demonstrates the modularity and prepares the route to `Fin n → ℝ`/Euclidean targets.

### Important Lean details

- Use `C(X, Y)` for `ContinuousMap X Y`.
- The pairing map is usually `ContinuousMap.prodMk`.
- Coordinate projections may already exist as `f.fst` and `f.snd`; if not, use composition with continuous projections.
- The main proof likely ends with:
  ```lean
  intro f ε hε
  rcases hY f.fst ε hε with ⟨gY, hgY, happroxY⟩
  rcases hZ f.snd ε hε with ⟨gZ, hgZ, happroxZ⟩
  refine ⟨ContinuousMap.prodMk gY gZ, ?_, ?_⟩
  ```
  followed by the membership proof and then
  ```lean
  intro x
  simpa using dist_prod_mk_lt_of_lt (happroxY x) (happroxZ x)
  ```
  after rewriting the coordinates appropriately.

- For the extensional identity `ContinuousMap.prodMk f.fst f.snd = f`, use:
  ```lean
  ext x <;> rfl
  ```
  if the projections are definitionally the coordinate functions.

- If there is friction with the metric on products, do not fight the global instance machinery in the main theorem. Instead, prove a local lemma matching whatever `dist` formula Mathlib gives for `Y × Z`.

### Stronger corollaries worth pursuing if the binary theorem is successful

1. **Ternary product closure**
   ```lean
   theorem eml_uniform_dense_prod3
       {X Y Z W : Type*} ... :
       ...
   ```
   by applying the binary theorem twice. This is a concrete test that the theorem really behaves compositionally.

2. **Finite-dimensional vector-valued approximation as an iterated product corollary**  
   If `ℝ^n` is represented concretely as `Fin n → ℝ`, you may be able to derive a product-style approximation theorem coordinatewise. Even if a stronger finite-dimensional codomain theorem already exists, deriving it via repeated binary products is conceptually valuable because it shows the codomain calculus is modular rather than bespoke.

3. **Closedness of the approximating class under product formation**
   ```lean
   theorem PairClass_closed_under_coordinate_restriction ...
   ```
   showing that the product theorem is not just existential approximation, but an actual construction principle on approximation classes.

### Why this matters

This theorem upgrades codomain approximation from a collection of isolated target-specific results to a compositional calculus. The real gain is not merely that `Y × Z` works; it is that once approximation is known for basic codomains, finite products follow formally by repeated pairing. That is the correct structural next step after scalar and finite-dimensional results: it turns universal approximation into a category-theoretic closure property of the EML class.

This is strategically important for the larger program because future codomain theorems for convex compacta, ANRs, or embedded manifolds can be combined productwise without redoing approximation arguments from scratch. In other words, the binary product theorem is the bridge from “we can approximate maps into certain spaces” to “we can build new approximable codomains systematically.”

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
