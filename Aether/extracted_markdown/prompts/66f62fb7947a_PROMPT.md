## Research Task: GL₃ tropical Satake injectivity from chamber-edge rank-2 Levi marginals and adjacent-facet compatibility

Research Mode: PROVE

Work in the existing `Tropical/Langlands` GL₃ tropical Satake framework, with dominant coweights represented concretely as triples `(a,b,c) : ℕ × ℕ × ℕ` satisfying `a ≥ b ∧ b ≥ c`, or equivalently by the standard dominant coordinates already used in the GL₃ files. Let `Coeff := DomGL3 →₀ ℤ` or `DomGL3 →₀ ℝ` according to the coefficient type already fixed in the surrounding development; the theorem should be stated for the strongest coefficient ring already available, ideally an additive cancellative ordered commutative group if the existing convolution lemmas support that generality.

The goal is to prove a new injectivity criterion: a finitely supported tropical Hecke coefficient function on dominant GL₃ coweights is uniquely determined by its chamber-edge rank-2 Levi marginals together with the adjacent-facet compatibility relations already formalized.

### Target theorem

Formulate and prove a theorem of the following shape, specialized to the exact existing definitions in the GL₃ files:

```lean
theorem gl3_tropical_satake_injective_of_edge_rank2_marginals
    (f g : DomGL3 →₀ ℤ)
    (hfg :
      ∀ e : ChamberEdge, edgeRank2LeviMarginal f e = edgeRank2LeviMarginal g e)
    (hfac :
      ∀ A B : AdjacentFacet, facetCompatible (f - g) A B)
    : f = g
```

A more operational equivalent statement, often easier to prove, is the zero-detection form:

```lean
theorem gl3_tropical_satake_zero_of_edge_rank2_marginals
    (h : DomGL3 →₀ ℤ)
    (hedge : ∀ e : ChamberEdge, edgeRank2LeviMarginal h e = 0)
    (hfac : ∀ A B : AdjacentFacet, facetCompatible h A B)
    : h = 0
```

Then derive the injectivity theorem by applying this to `h := f - g`.

If the library already has named predicates for:
- chamber edges,
- codimension-1 facets,
- adjacent facets,
- rank-2 Levi marginal/convolution operators,
- support height / dominance degree,

reuse those names exactly. If not, define minimal wrappers with concrete types such as:

```lean
def dominanceHeight : DomGL3 → ℕ
def onEdge : ChamberEdge → DomGL3 → Prop
def onFacet : Facet → DomGL3 → Prop
def edgeRank2LeviMarginal : (DomGL3 →₀ ℤ) → ChamberEdge → ℤ
def facetCompatible : (DomGL3 →₀ ℤ) → Facet → Facet → Prop
```

The theorem should ultimately assert that the map
```lean
f ↦ (edgeRank2LeviMarginal f, adjacent-facet compatibility data)
```
is injective on finitely supported dominant-coweight functions.

### Intermediate lemmas to prove

The proof should be decomposed into the following nontrivial lemmas, with exact Lean statements adapted to the local definitions.

1. **Extreme-ray vanishing from edge marginals**
```lean
theorem edge_marginal_zero_on_extreme_rays
    (h : DomGL3 →₀ ℤ)
    (hedge : ∀ e : ChamberEdge, edgeRank2LeviMarginal h e = 0) :
    ∀ μ : DomGL3, onExtremeRay μ → h μ = 0
```

This should isolate the fact that the chamber-edge rank-2 Levi data already detects coefficients on the two/three extreme rays of the dominant cone.

2. **Propagation from edge vanishing to facet vanishing**
```lean
theorem adjacent_facet_propagation
    (h : DomGL3 →₀ ℤ)
    (hfac : ∀ A B : AdjacentFacet, facetCompatible h A B)
    (hedge0 : ∀ μ : DomGL3, onExtremeRay μ → h μ = 0) :
    ∀ μ : DomGL3, onFacetBoundary μ → h μ = 0
```

This should formalize the idea that adjacent-facet compatibility recursively forces vanishing along each codimension-1 face once the boundary edge data vanish.

3. **Facewise vanishing implies interior vanishing via rank-2 Levi identities**
```lean
theorem face_vanishing_of_edge_and_Levi_data
    (h : DomGL3 →₀ ℤ)
    (hedge : ∀ e : ChamberEdge, edgeRank2LeviMarginal h e = 0)
    (hface : ∀ μ : DomGL3, onFacet μ → h μ = 0) :
    ∀ μ : DomGL3, h μ = 0
```

A stronger induction-friendly version is preferable:

```lean
theorem interior_vanishing_by_height_induction
    (h : DomGL3 →₀ ℤ)
    (hedge : ∀ e : ChamberEdge, edgeRank2LeviMarginal h e = 0)
    (hfac : ∀ A B : AdjacentFacet, facetCompatible h A B) :
    ∀ n : ℕ, (∀ μ : DomGL3, dominanceHeight μ < n → h μ = 0) →
      ∀ μ : DomGL3, dominanceHeight μ = n → h μ = 0
```

4. **Support-extremal contradiction lemma**
For finite support arguments, it is often cleaner to choose a maximal-height support element and derive a contradiction.

```lean
theorem no_maximal_support_of_zero_edge_data
    (h : DomGL3 →₀ ℤ)
    (hedge : ∀ e : ChamberEdge, edgeRank2LeviMarginal h e = 0)
    (hfac : ∀ A B : AdjacentFacet, facetCompatible h A B) :
    h.support = ∅
```

or equivalently

```lean
theorem exists_height_max_support
    (h : DomGL3 →₀ ℤ) (hh : h ≠ 0) :
    ∃ μ ∈ h.support, ∀ ν ∈ h.support, dominanceHeight ν ≤ dominanceHeight μ
```

followed by a contradiction using the previous lemmas.

### Proof strategy

Use the difference function `h := f - g` and reduce the statement to proving `h = 0`. The key insight is that edge marginals give enough one-dimensional boundary control, while adjacent-facet compatibility rigidifies the two-dimensional boundary so that the already-developed GL₃ rank-2 tropical convolution formulas force all interior coefficients to vanish.

Concrete proof steps:

1. **Reduce to zero and choose a maximal support point.**  
   Since `h` is finitely supported, if `h ≠ 0` then `h.support` is a nonempty finite set. Extract `μ₀ ∈ h.support` of maximal `dominanceHeight`. This is the natural induction parameter and avoids pointwise global induction over all coweights. Use `Finsupp.support`, `Finset.exists_max_image`, or a custom maximality lemma.

2. **Kill coefficients on extreme rays using edge marginals.**  
   Show that on each chamber edge, the rank-2 Levi marginal is triangular with respect to the natural edge parameter. In particular, if the marginal is identically zero, then the coefficient of `h` on the outermost/extreme ray point must vanish, and by descending induction the entire edge vanishes. This is the content of `edge_marginal_zero_on_extreme_rays`. If the existing convolution formulas are indexed by adjacent facets, use the specialization where one coordinate difference is zero.

3. **Propagate vanishing along facets using adjacent-facet compatibility.**  
   For a codimension-1 facet, use the compatibility relation between the two adjacent chambers/facets to express the coefficient at a boundary point in terms of lower-height points on neighboring edges/faces. Since the edge terms are already zero and lower-height terms vanish by maximality/induction, deduce vanishing on the whole facet. This is the nontrivial “boundary determines face” step and should be packaged as `adjacent_facet_propagation`.

4. **Use rank-2 Levi convolution identities to eliminate interior points.**  
   For an interior dominant coweight `μ`, apply the known rank-2 Levi tropical convolution identity attached to one of the three simple rank-2 Levi directions. The identity should express the marginal at parameter corresponding to `μ` as a sum involving `h μ` plus terms supported on strictly smaller height or on the facet boundary. All other terms vanish by the induction hypothesis and the facet-vanishing lemma, so the zero marginal forces `h μ = 0`. This is the crucial triangularity argument: isolate the coefficient of `μ` with coefficient `1` or another cancellable scalar.

5. **Conclude by contradiction with maximal support.**  
   If `μ₀` lies on an extreme ray, use step 2. If `μ₀` lies on a facet but not an extreme ray, use step 3. If `μ₀` is interior, use step 4. Each case contradicts `μ₀ ∈ h.support`, hence `h = 0`. Then deduce `f = g` from `f - g = 0`.

### Key technical points to formalize carefully

- Define a robust `dominanceHeight` that is visibly strictly decreased by every term appearing in the non-leading part of the convolution/facet formulas. A good candidate is a linear form such as
  ```lean
  def dominanceHeight : DomGL3 → ℕ := fun μ => μ.1 + μ.2 + μ.3
  ```
  or the 2-parameter dominant-coordinate sum already used in the GL₃ files.

- Prove monotonicity lemmas of the shape:
  ```lean
  lemma lower_terms_have_smaller_height ...
  lemma facet_neighbors_have_le_height ...
  lemma interior_convolution_triangular ...
  ```
  These are likely the real combinatorial core; isolate them so the main theorem remains clean.

- If the existing tropical convolution outputs live in `ℝ` while coefficients are in `ℤ`/`ℕ`, prove the zero-detection theorem in the codomain where cancellation is available, then use coercion lemmas:
  ```lean
  by
    ext μ
    ...
  ```

- If the support uses dominant-coordinate pairs `(x,y)` for GL₃ rather than triples, restate everything in that coordinate system. The theorem is about the dominant chamber geometry, not the ambient coordinate presentation.

### Suggested Lean theorem signatures

Use whichever of these best matches the current codebase.

```lean
theorem edge_marginal_zero_on_extreme_rays
    (h : DomGL3 →₀ ℤ)
    (hedge : ∀ e, edgeRank2LeviMarginal h e = 0) :
    ∀ μ, IsExtremeRayPoint μ → h μ = 0
```

```lean
theorem adjacent_facet_propagation
    (h : DomGL3 →₀ ℤ)
    (hfac : ∀ p : AdjacentFacetPair, AdjacentFacetCompatible h p)
    (hray : ∀ μ, IsExtremeRayPoint μ → h μ = 0) :
    ∀ μ, IsFacetPoint μ → h μ = 0
```

```lean
theorem interior_zero_of_rank2_Levi_zero
    (h : DomGL3 →₀ ℤ)
    (hedge : ∀ e, edgeRank2LeviMarginal h e = 0)
    (hfacet : ∀ μ, IsFacetPoint μ → h μ = 0) :
    ∀ μ, IsInteriorPoint μ → h μ = 0
```

```lean
theorem gl3_tropical_satake_zero_of_edge_rank2_marginals
    (h : DomGL3 →₀ ℤ)
    (hedge : ∀ e, edgeRank2LeviMarginal h e = 0)
    (hfac : ∀ p : AdjacentFacetPair, AdjacentFacetCompatible h p) :
    h = 0
```

```lean
theorem gl3_tropical_satake_injective_of_edge_rank2_marginals
    (f g : DomGL3 →₀ ℤ)
    (hedge : ∀ e, edgeRank2LeviMarginal f e = edgeRank2LeviMarginal g e)
    (hfac : ∀ p : AdjacentFacetPair, AdjacentFacetCompatible (f - g) p) :
    f = g
```

### Why this matters

This theorem gives a sharper GL₃ tropical Satake faithfulness statement than the previously used full Levi-marginal reconstruction. It shows that one does not need all rank-1 and rank-2 local data: chamber-edge rank-2 marginals plus adjacent-facet compatibility already determine the global coefficient function. That is exactly the higher-rank analogue of a “boundary data determine the interior” principle and is the natural injective counterpart to the recent GL₃ surjectivity result.

Formally, this is valuable because it compresses the reconstruction interface for future GL₃ and higher-rank developments: instead of reconstructing from a larger family of local observables, one proves that a much smaller and more geometric package of data is faithful. Conceptually, it clarifies how tropical Satake information is organized by chamber combinatorics: edges control rays, compatibility controls faces, and rank-2 Levi convolution controls the interior. This is likely the right pattern for any future GLₙ tropical Satake program, so proving it cleanly in GL₃ is an important structural milestone.

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
