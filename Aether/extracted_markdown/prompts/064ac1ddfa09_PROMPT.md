## Research Task: GL₃ tropical Satake injectivity from full rank-1 and rank-2 Levi marginals via a tropical Horn reconstruction theorem

### Precise theorem package to target

Work in a concrete model of the dominant coweight cone for `GL₃`:
```lean
def DomGL3 := {v : Fin 3 → ℤ // v 0 ≥ v 1 ∧ v 1 ≥ v 2}
```
or, if the existing files already use a normalized `A₂` model, equivalently
```lean
def A2Dom := {p : ℤ × ℤ // 0 ≤ p.2 ∧ 0 ≤ p.1}
```
with the identification
`(a,b) ↔ (a+b, b, 0)`.

For finitely supported tropical Hecke data, use
```lean
abbrev TropFn := DomGL3 →₀ ℝ∞
```
or the exact existing coefficient semiring if the current GL₂/GL₃ files use `ℝ`, `ℤ`, or `WithTop ℤ`. The key point is finite support and a min-plus support function/Newton object already defined in the library.

You should aim to prove a theorem of the following shape, with names adjusted to the existing API:

```lean
theorem tropicalSatake_GL3_injective_of_all_Levi_marginals
    (f g : TropFn)
    (hEdge :
      ∀ i : Fin 3,
        edgeMarginal i f = edgeMarginal i g)
    (hFace :
      ∀ i : Fin 3,
        faceMarginal i f = faceMarginal i g) :
    tropicalSatakeSupport f = tropicalSatakeSupport g
```

and then the coefficient-level strengthening

```lean
theorem finitelySupported_GL3_function_ext_of_all_Levi_marginals
    (f g : TropFn)
    (hEdge :
      ∀ i : Fin 3,
        edgeMarginal i f = edgeMarginal i g)
    (hFace :
      ∀ i : Fin 3,
        faceMarginal i f = faceMarginal i g) :
    f = g
```

where `edgeMarginal i` is the rank-1/simple-root `GL₂` slice Newton polygon data, and `faceMarginal i` is the codimension-1 rank-2 Levi/hypersimplex projection. If the current development separates support and coefficients, it is perfectly acceptable to split this into:

```lean
theorem support_eq_of_all_Levi_marginals_eq ...
theorem coeff_eq_of_support_and_projected_lower_hulls_eq ...
theorem ext_of_all_Levi_marginals_eq ...
```

A very useful intermediate “Horn reconstruction” statement is:

```lean
theorem A2_support_reconstructed_from_edge_and_face_marginals
    (S T : Finset DomGL3)
    (hEdge : ∀ i : Fin 3, edgeShadow i S = edgeShadow i T)
    (hFace : ∀ i : Fin 3, faceShadow i S = faceShadow i T) :
    S = T
```

or, in support-function language,

```lean
theorem A2_supportFunction_ext_of_Levi_restrictions
    (φ ψ : DomGL3 → ℝ∞)
    (hconvφ : IsTropicallyConvexSupport φ)
    (hconvψ : IsTropicallyConvexSupport ψ)
    (hEdge : ∀ i : Fin 3, restrictToEdge i φ = restrictToEdge i ψ)
    (hFace : ∀ i : Fin 3, restrictToFace i φ = restrictToFace i ψ) :
    φ = ψ
```

If the existing tropical Satake transform is already encoded as a support function on a dual cone, an even cleaner final statement is:

```lean
theorem tropicalSatake_GL3_ext_of_proper_Levi_restrictions
    (f g : TropFn)
    (h :
      ∀ L, IsProperLeviGL3 L →
        restrictTropSatakeToLevi L f = restrictTropSatakeToLevi L g) :
    tropSatake f = tropSatake g
```

followed by injectivity of the transform on the dominant chamber:
```lean
theorem tropicalSatake_GL3_faithful_on_dominant_chamber
    (f g : TropFn)
    (h :
      ∀ L, IsProperLeviGL3 L →
        restrictTropSatakeToLevi L f = restrictTropSatakeToLevi L g) :
    f = g
```

Finally, package the convolution-faithfulness consequence in a form that is directly usable later:
```lean
theorem tropicalConvolution_left_cancel_of_all_Levi_marginals
    (f g h : TropFn)
    (hf : DominantSupported f) (hg : DominantSupported g) (hh : DominantSupported h)
    (hconv :
      ∀ L, IsProperLeviGL3 L →
        restrictTropSatakeToLevi L (f ⋆ h) = restrictTropSatakeToLevi L (g ⋆ h)) :
    f = g
```
provided the existing files already identify tropical Satake with convolution-to-min-plus multiplication.

### Concrete reconstruction strategy

The right proof is not pointwise extensionality by brute force; it should go through a genuine `A₂` reconstruction principle.

1. **Reduce from functions to Newton support data.**  
   Prove first that equality of all Levi marginals implies equality of the associated tropical Newton object / lower hull / support function. This should use the already developed GL₂ slice theory for each simple-root direction. A likely formal bridge is:
   ```lean
   edgeMarginal i f = edgeMarginal i g
   → restrictToEdge i (tropSatakeSupport f) = restrictToEdge i (tropSatakeSupport g)
   ```
   and similarly for faces. If coefficient data are encoded as lower-hull heights, keep support and height reconstruction as separate lemmas.

2. **Establish an `A₂` intersection-of-halfspaces lemma.**  
   The key geometric statement is that a finite tropical convex support set in the dominant `A₂` cone is determined by its three edge restrictions together with its three codimension-1 face projections. Formally, show that any support set `S` equals the intersection of the pullbacks of its face shadows together with the inequalities read off from the edge Newton polygons:
   ```lean
   S = ⋂ i, pullbackFace i (faceShadow i S) ∩ ⋂ i, edgeHalfspace i (edgeShadow i S)
   ```
   In Lean, this may be easier as two inclusions:
   - every point of `S` maps to each marginal;
   - if a dominant point lies in all pulled-back marginals, then it lies in `S`.
   
   The nontrivial inclusion should use the `GL₃` dominance coordinates `(x,y,z)` or normalized `(a,b)` and reconstruct the missing coordinate bounds from the consistency of the three projections. This is the tropical Horn step: the three pairwise/rank-2 marginals force the full point.

3. **Recover coefficients from projected lower hull compatibility.**  
   Once supports agree, show the coefficient/height at each support point is the unique value compatible with all projected lower hulls. A useful target lemma is:
   ```lean
   theorem coeff_unique_of_all_projected_heights_agree
       (f g : TropFn) (μ : DomGL3)
       (hsupp : support f = support g)
       (hproj :
         ∀ i : Fin 3, projectedHeight i f μ = projectedHeight i g μ) :
       f μ = g μ
   ```
   The proof should use that for a dominant lattice point in `A₂`, the triple of projected heights is not independent: one of them is redundant, and the remaining compatible pair determines the full height. If there is an existing “adjacent facet determines coefficient” theorem, use it twice and then prove the compatibility relation to globalize.

4. **Promote support-function equality to equality of finitely supported functions.**  
   If there is already a theorem saying the tropical Satake transform is injective once the Newton support function is known, invoke it directly. Otherwise prove:
   ```lean
   tropSatakeSupport f = tropSatakeSupport g → f = g
   ```
   under finite support and dominant support hypotheses. This may require a lemma that the support function determines the lower hull vertices and their labels.

5. **Deduce convolution-faithfulness.**  
   Use functoriality of Levi restriction with respect to tropical convolution:
   ```lean
   restrictToLevi L (f ⋆ g) = restrictToLevi L f ⋆ restrictToLevi L g
   ```
   Then if all proper Levi restrictions of `f ⋆ h` and `g ⋆ h` agree, injectivity on the dominant chamber implies equality of the full transforms, and hence `f = g` after canceling by faithfulness already available in the tropical Hecke setup. If cancellation is not yet formalized, prove a weaker but still valuable theorem:
   ```lean
   tropSatake (f ⋆ h) = tropSatake (g ⋆ h) → tropSatake f = tropSatake g
   ```
   under a nondegeneracy hypothesis on `h`.

### Key lemmas worth isolating

These are likely the real mathematical heart and should be stated separately rather than buried inside one proof.

```lean
theorem dominant_point_mem_of_all_Levi_memberships
    (S : Finset DomGL3) (μ : DomGL3)
    (hEdge : ∀ i : Fin 3, edgeCoord i μ ∈ edgeShadow i S)
    (hFace : ∀ i : Fin 3, faceCoord i μ ∈ faceShadow i S) :
    μ ∈ S
```

```lean
theorem A2_coordinates_determined_by_three_face_projections
    (μ ν : DomGL3)
    (h : ∀ i : Fin 3, faceCoord i μ = faceCoord i ν) :
    μ = ν
```
This may be almost immediate in coordinates, but it is the formal algebraic backbone of the reconstruction.

```lean
theorem edge_face_compatibility_for_dominant_support
    (S : Finset DomGL3) :
    CompatibleLeviData (fun i => edgeShadow i S) (fun i => faceShadow i S)
```
This lets you characterize exactly which systems of marginals arise from a global support set and prevents proving a false reconstruction statement for inconsistent arbitrary data.

```lean
theorem supportFunction_eq_of_eq_on_generating_Levi_directions
    (φ ψ : DomGL3 → ℝ∞)
    (hconvφ : IsTropicallyConvexSupport φ)
    (hconvψ : IsTropicallyConvexSupport ψ)
    (hgen :
      ∀ u ∈ generatingLeviDirectionsGL3,
        φ u = ψ u) :
    φ = ψ
```
If the support function is piecewise-linear on the `A₂` fan, this can be proved from agreement on the rays/facets generating the fan.

```lean
theorem lowerHull_height_determined_by_face_data
    (f g : TropFn)
    (hsupp : tropicalSatakeSupport f = tropicalSatakeSupport g)
    (hFace : ∀ i : Fin 3, faceLowerHull i f = faceLowerHull i g) :
    lowerHull f = lowerHull g
```

### Lean-specific implementation hints

- Prefer a normalized coordinate model `A2Dom := ℕ × ℕ` whenever possible. Many reconstruction arguments become explicit arithmetic:
  - edge data give the one-variable profiles along `a = 0`, `b = 0`, and `a+b = const`;
  - face projections correspond to forgetting one of `(λ₁, λ₂, λ₃)` before reimposing dominance.
- If `DomGL3` as a subtype is awkward, prove the combinatorial reconstruction lemmas first on raw triples:
  ```lean
  {x : Fin 3 → ℤ // x 0 ≥ x 1 ∧ x 1 ≥ x 2}
  ```
  and only then transfer them to the tropical Hecke objects.
- Use `Finsupp.ext` for the final equality of functions. The hard part should be proving equality of values at each support point, not rewriting.
- For finite supports, `Finset`-based shadows/projections are often easier than `Set`; later derive set-level equalities via coercions if needed.
- If the current API already has GL₂ Newton polygon injectivity, explicitly factor the proof through it on each simple-root slice rather than reproving 1-dimensional uniqueness.

### Why this matters

This theorem is the correct `GL₃` analogue of a tropical Horn/Schur–Horn uniqueness principle: global tropical Satake data are reconstructed from all proper Levi shadows. It is substantially stronger than pairwise-slice or adjacent-facet statements because it gives a single conceptual injectivity theorem from the full system of proper Levi marginals. That has two major consequences for the research program:

1. **Structural control of tropical Hecke data for `GL₃`.**  
   It shows that rank-1 and rank-2 Levi information already captures the full dominant object, matching the representation-theoretic intuition that proper Levi branching controls global highest-weight data.

2. **A robust path toward convolution faithfulness and higher-rank generalization.**  
   Once proved cleanly in `A₂`, this becomes the template for `GLₙ`: reconstruct a tropical Newton object from its proper Levi marginals, then deduce faithfulness of tropical convolution from functoriality under Levi restriction. So even a well-packaged `GL₃` proof is not isolated—it is the first nontrivial test case for a general tropical Satake injectivity machine.

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

Research domain: Tropical
Research mode: prove
