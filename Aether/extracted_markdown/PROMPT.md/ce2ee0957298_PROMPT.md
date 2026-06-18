## Research Task: EML Stone–Weierstrass for compact finite CW-complex codomains via simplicial embedding and polyhedral neighborhood retraction

Research Mode: PROVE

Prove a finite-CW-complex codomain approximation theorem by reducing to a compact polyhedron in Euclidean space and then retracting Euclidean approximants back to the polyhedron. The point is to push the existing EML approximation theory beyond convex/manifold targets into a genuinely topological class where the codomain need not be convex, smooth, or assembled productwise.

### Precise target statements

Work in a formulation where the approximation class is represented by a predicate `A : C(X, ℝ^N) → Prop` or, more generally, by a subtype of continuous maps closed under the operations already established in the EML development. You should isolate the topological/polyhedral lemmas from the EML-specific closure assumptions.

A good core theorem package is:

```lean
/-- Uniform density of an approximation class in `C(X, Y)` after embedding `Y`
as a compact polyhedron in `ℝ^N` and retracting a Euclidean approximant. -/
theorem denseRange_eml_to_compactPolyhedron
  {X : Type*} [TopologicalSpace X] [CompactSpace X]
  {N : ℕ}
  {P : Set (EuclideanSpace ℝ (Fin N))}
  (hP_compact : IsCompact P)
  (hP_closed : IsClosed P)
  (hRetr :
    ∃ U : Set (EuclideanSpace ℝ (Fin N)),
      IsOpen U ∧ P ⊆ U ∧
      ∃ r : C(U, P), True)
  (A : C(X, EuclideanSpace ℝ (Fin N)) → Prop)
  (hA_dense :
    ∀ F : C(X, EuclideanSpace ℝ (Fin N)) ∀ ε > 0,
      ∃ g : C(X, EuclideanSpace ℝ (Fin N)),
        A g ∧ ∀ x, ‖g x - F x‖ < ε)
  (hA_postcomp :
    ∀ {U : Set (EuclideanSpace ℝ (Fin N))} (hU : IsOpen U)
      (r : C(U, P)) {g : C(X, EuclideanSpace ℝ (Fin N))},
      A g →
      (∀ x, g x ∈ U) →
      ∃ h : C(X, P), True)
  :
  ∀ F : C(X, P) ∀ ε > 0,
    ∃ h : C(X, P), True ∧ ∀ x, ‖(h x : EuclideanSpace ℝ (Fin N)) - F x‖ < ε
```

Then specialize this abstract polyhedron theorem to finite CW-complexes via a chosen embedding:

```lean
/-- Finite-CW target version: after choosing a topological embedding of `Y`
onto a compact polyhedron `P ⊆ ℝ^N`, EML maps are uniformly dense in `C(X, Y)`. -/
theorem denseRange_eml_to_compactFiniteCW
  {X Y : Type*} [TopologicalSpace X] [CompactSpace X]
  [TopologicalSpace Y] [CompactSpace Y]
  {N : ℕ}
  (e : Y → EuclideanSpace ℝ (Fin N))
  (he_embedding : Embedding e)
  (hP_poly :
    ∃ P : Set (EuclideanSpace ℝ (Fin N)),
      IsCompact P ∧
      IsClosed P ∧
      Set.range e = P ∧
      ∃ U : Set (EuclideanSpace ℝ (Fin N)),
        IsOpen U ∧ P ⊆ U ∧
        ∃ r : C(U, P), True)
  (A : C(X, EuclideanSpace ℝ (Fin N)) → Prop)
  (hA_dense :
    ∀ F : C(X, EuclideanSpace ℝ (Fin N)) ∀ ε > 0,
      ∃ g : C(X, EuclideanSpace ℝ (Fin N)),
        A g ∧ ∀ x, ‖g x - F x‖ < ε)
  (hA_postcomp_Y :
    ∀ {P : Set (EuclideanSpace ℝ (Fin N))} {U : Set (EuclideanSpace ℝ (Fin N))}
      (hU : IsOpen U) (hP : Set.range e = P)
      (r : C(U, P)) {g : C(X, EuclideanSpace ℝ (Fin N))},
      A g →
      (∀ x, g x ∈ U) →
      ∃ h : C(X, Y), True)
  :
  ∀ f : C(X, Y) ∀ ε > 0,
    ∃ h : C(X, Y), True
```

For the quantitative geometric step, prove a standalone lemma in Euclidean space:

```lean
/-- If `P` is compact and contained in an open set `U`, then some uniform tubular
neighborhood of `P` is still contained in `U`. -/
theorem exists_thickening_subset_open
  {N : ℕ} {P U : Set (EuclideanSpace ℝ (Fin N))}
  (hP_compact : IsCompact P)
  (hU_open : IsOpen U)
  (hPU : P ⊆ U) :
  ∃ δ > 0, ∀ z, z ∈ P → Metric.closedBall z δ ⊆ U
```

and preferably the more approximation-friendly corollary

```lean
theorem exists_dist_lt_subset_open
  {N : ℕ} {P U : Set (EuclideanSpace ℝ (Fin N))}
  (hP_compact : IsCompact P)
  (hU_open : IsOpen U)
  (hPU : P ⊆ U) :
  ∃ δ > 0, ∀ z, z ∈ P → ∀ w, dist w z < δ → w ∈ U
```

You will also want a compact-uniform-continuity lemma for the retract:

```lean
/-- Uniform continuity of a continuous map on a compact set, phrased with explicit
`ε-δ` control for later approximation estimates. -/
theorem compact_uniform_continuous_eps_delta
  {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]
  {K : Set α} (hK : IsCompact K) {f : α → β}
  (hf : ContinuousOn f K) :
  ∀ ε > 0, ∃ δ > 0, ∀ x ∈ K, ∀ y ∈ K, dist x y < δ → dist (f x) (f y) < ε
```

If the ambient theorem is easier to prove first for `P`-valued maps with the induced metric from `ℝ^N`, do that. The passage back to `Y` can then use the homeomorphism induced by the embedding.

### Recommended proof architecture

1. **Separate the geometry from the approximation class.**  
   First prove the abstract polyhedron-retraction theorem for maps into a compact subset `P ⊆ ℝ^N`. Do not entangle the finite-CW triangulation inside the approximation argument. The theorem should only use:
   - compactness/closedness of `P`,
   - existence of an open neighborhood `U`,
   - existence of a continuous retraction `r : U → P`,
   - density of the EML class in Euclidean-valued continuous maps,
   - closure of the EML class under postcomposition by continuous codomain maps on the image.

2. **Quantitative neighborhood lemma.**  
   The key nontrivial step is: from `P ⊆ U` with `P` compact and `U` open, extract a uniform `δ > 0` such that every point within `δ` of some point of `P` lies in `U`. A robust route is:
   - for each `z ∈ P`, openness gives `ε_z > 0` with `ball z ε_z ⊆ U`;
   - the family `ball z (ε_z / 2)` covers `P`;
   - compactness gives a finite subcover;
   - let `δ` be the minimum of the finitely many `ε_z / 2`;
   - if `dist w z < δ` and `z ∈ P`, choose the subcover ball containing `z`, then triangle inequality gives `w ∈ U`.
   
   This is the exact place where the polyhedral argument needs genuine quantitative compactness rather than mere pointwise openness.

3. **Uniform continuity of the retract on a compact thickening.**  
   Once `δ₀` is chosen so that the `δ₀`-neighborhood of `P` lies in `U`, define the compact set
   ```lean
   K := {z | dist z P ≤ δ₀ / 2}
   ```
   or use the image of `F` thickened by `δ₀ / 2`. Show `K` is compact and contained in `U`. Then `r` is uniformly continuous on `K`. This yields:
   ```lean
   ∀ ε > 0, ∃ η > 0, ∀ z ∈ K, ∀ w ∈ K, dist z w < η → dist (r z) (r w) < ε.
   ```
   Since `r` fixes `P`, for `p ∈ P` and `z` close to `p`, one gets `dist (r z) p < ε`.

4. **Approximate the embedded map and retract.**  
   For `F : C(X, P)` (or `F := e ∘ f : C(X, ℝ^N)` with image in `P`), choose `η` from the previous step, then use Euclidean EML density to obtain `g` with
   ```lean
   ∀ x, ‖g x - F x‖ < min (η, δ₀/2).
   ```
   Then:
   - `g x ∈ U` for all `x` by the thickening lemma,
   - `dist (r (g x)) (F x) < ε` because `F x ∈ P`, `r (F x) = F x`, and `g x` is `η`-close to `F x`.
   This gives the uniform estimate for the retracted approximant.

5. **Transfer from the polyhedron back to the CW-complex.**  
   After choosing an embedding `e : Y → ℝ^N` with image `P`, package `e` as a homeomorphism `Y ≃ₜ P` onto its range. Then define
   ```lean
   h := e⁻¹ ∘ r ∘ g
   ```
   as a continuous map `X → Y`. The approximation estimate can be stated either:
   - in the metric pulled back from `ℝ^N` via `e`, which is easiest formally, or
   - using the original metric on `Y`, if you already have compact-homeomorphism uniform continuity lemmas allowing transport of estimates through `e` and `e⁻¹`.

### Concrete proof steps and key lemmas to exploit

- **Step 1: image compactness.**  
  For `F : C(X, P)` and `X` compact, `Set.range F` is compact in `P`, hence compact in the ambient Euclidean space. This lets you localize all continuity estimates to compact sets. In Lean, `Continuous.image` + `isCompact_range` are the likely tools.

- **Step 2: closedness/compactness of thickenings.**  
  You may need:
  ```lean
  {z | dist z P ≤ ρ}
  ```
  is closed, and bounded when `P` is compact, hence compact in finite-dimensional Euclidean space. If direct library lemmas are awkward, a simpler workaround is to use a finite subcover argument directly on `P` and avoid introducing the full closed thickening as a separate compact set.

- **Step 3: retract fixes `P`.**  
  If `r : C(U, P)` is a retraction, make sure you have or define the property
  ```lean
  ∀ p : P, r ⟨p, hPU p.property⟩ = p
  ```
  or ambiently
  ```lean
  ∀ z ∈ P, (r ⟨z, hPU hz⟩ : EuclideanSpace ℝ (Fin N)) = z.
  ```
  This identity is what turns continuity of `r` into approximation to the original map, rather than just approximation to some arbitrary `P`-valued perturbation.

- **Step 4: pointwise-to-uniform estimate.**  
  Because the approximation statement is already pointwise uniform (`∀ x, ‖g x - F x‖ < η`), the final estimate for `r ∘ g` is immediate pointwise. Avoid introducing sup norms unless needed; the quantified pointwise bound is often easier in Lean than a statement using `sInf` or explicit `dist` on function spaces.

- **Step 5: homeomorphism onto the image.**  
  For the finite-CW specialization, use the embedding `e` to identify `Y` with `P := Set.range e`. Compactness of `Y` plus Hausdorffness of Euclidean space gives that `e` is a homeomorphism onto `P`. Then all approximation can happen in `P` and be transported back to `Y`.

### Finite-CW/polyhedral specialization to aim for

Once the abstract theorem is complete, state a clean corollary in the language of compact finite CW-complexes. Since the actual triangulation theorem may not yet be formalized, it is acceptable to phrase the finite-CW input as an explicit hypothesis giving the polyhedral embedding:

```lean
/-- A compact space admitting a homeomorphism to a compact polyhedron inherits
EML uniform approximation from Euclidean-valued EML density. -/
theorem denseRange_eml_of_homeomorphicToCompactPolyhedron
  {X Y : Type*} [TopologicalSpace X] [CompactSpace X]
  [TopologicalSpace Y] [CompactSpace Y]
  {N : ℕ}
  (hY :
    ∃ P : Set (EuclideanSpace ℝ (Fin N)),
      IsCompact P ∧ IsClosed P ∧ Nonempty (Y ≃ₜ P) ∧
      ∃ U : Set (EuclideanSpace ℝ (Fin N)),
        IsOpen U ∧ P ⊆ U ∧
        ∃ r : C(U, P), True)
  (A : C(X, EuclideanSpace ℝ (Fin N)) → Prop)
  ...
  :
  ∀ f : C(X, Y) ∀ ε > 0, ∃ h : C(X, Y), True
```

This is the right formal milestone even if the full theorem “every compact finite CW-complex admits such a polyhedral model” remains an imported topological fact rather than something proved in this file.

### Why this matters

This theorem is the clean next step after manifold-valued and compact-convex-codomain approximation. Compact finite CW-complexes include wedges, tori, projective spaces, finite graphs, and many naturally occurring homotopy-theoretic targets that are neither convex nor smooth. The proof route is also conceptually new in the EML program: it uses polyhedral geometry and neighborhood retractions, not differential charts or convex averaging. Formalizing this gives a reusable “approximate in Euclidean space, then retract” mechanism that should later generalize to compact ANRs and other retract-like targets. In particular, it establishes that the obstruction to EML universality is not nonlinearity of the target itself, but rather the availability of a controlled ambient retraction after Euclidean embedding.

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
