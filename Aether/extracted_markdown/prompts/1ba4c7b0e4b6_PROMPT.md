## Research Task: GL₃ tropical Satake surjectivity from simple-coroot edge valuations and rank-2 Levi convolution compatibility on bounded dominant support

Research Mode: PROVE

Prove a bounded-support converse/classification theorem for the GL₃ tropical Satake transform: every finitely supported dominant-chamber tropical datum satisfying the already-isolated edge and Levi compatibility relations is realized by a tropical Hecke-algebra element, and this realization is unique by the existing injectivity theorem. The point is to convert the current “local data determine global function” direction into a genuine “local admissibility iff global realizability” theorem on bounded support.

### Precise Lean target

Work with a concrete model of the dominant GL₃ coweight chamber as pairs `(a,b) : ℕ × ℕ`, representing the dominant coweight `(a+b,b,0)`. Use finitely supported functions on this chamber, e.g.
```lean
abbrev DomWt := ℕ × ℕ
abbrev TropDatum := DomWt → ℝ
```
and bounded support encoded by vanishing outside a box:
```lean
def BoundedSupport (N : ℕ) (D : TropDatum) : Prop :=
  ∀ p : DomWt, N < p.1 + p.2 → D p = 0
```
or, if your existing files use finite support via `Finset`, adapt the theorem to that representation.

Introduce predicates already suggested by the GL₃ tropical Satake development:
```lean
def EdgeValuationCompatible (D : TropDatum) : Prop := ...
def Levi12Compatible (D : TropDatum) : Prop := ...
def Levi23Compatible (D : TropDatum) : Prop := ...
def AdjacentFacetCompatible (D : TropDatum) : Prop := ...
def SatakeAdmissible (D : TropDatum) : Prop :=
  EdgeValuationCompatible D ∧
  Levi12Compatible D ∧
  Levi23Compatible D ∧
  AdjacentFacetCompatible D
```
and a type of bounded-support tropical Hecke elements together with a tropical Satake transform
```lean
abbrev TropHecke := ...
def tropSatake : TropHecke → TropDatum := ...
def HeckeBoundedSupport (N : ℕ) (h : TropHecke) : Prop := ...
```

The main theorem should have the shape
```lean
theorem gl3_tropSatake_surjective_on_bounded_support
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D)
    (hadm : SatakeAdmissible D) :
    ∃ h : TropHecke, HeckeBoundedSupport N h ∧ tropSatake h = D := by
  ...
```
and then package the classification consequence using the previously proved injectivity theorem:
```lean
theorem gl3_tropSatake_bounded_support_classification
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D)
    (hadm : SatakeAdmissible D) :
    ∃! h : TropHecke, HeckeBoundedSupport N h ∧ tropSatake h = D := by
  ...
```

If your library already has a concrete finitely supported object such as `DomWt →₀ ℝ`, then the more canonical theorem is:
```lean
theorem gl3_tropSatake_surjective_finsupp
    (D : DomWt →₀ ℝ)
    (hadm : SatakeAdmissible D) :
    ∃ h : TropHecke, tropSatake h = D := by
  ...
```
with bounded support automatic from `Finsupp`.

### Intermediate theorems worth proving first

A strong route is to isolate three constructive lemmas:

```lean
def edgeData (D : TropDatum) : ... := ...
def facetData (D : TropDatum) : ... := ...

theorem reconstruct_edge_generators
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D)
    (hedge : EdgeValuationCompatible D) :
    ∃ c : ..., edgeData D = c := by
  ...

theorem propagate_from_edges_to_facets
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D)
    (hedge : EdgeValuationCompatible D)
    (h12 : Levi12Compatible D)
    (h23 : Levi23Compatible D) :
    ∃ F : ..., facetData D = F := by
  ...

theorem global_consistency_of_propagation
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D)
    (hadm : SatakeAdmissible D) :
    ∃ h : TropHecke, HeckeBoundedSupport N h ∧ tropSatake h = D := by
  ...
```

If the finite-presentation theorem in the existing development is already stated as “every function satisfying a finite list of generator relations is in the image,” then the key new bridge theorem should identify `SatakeAdmissible D` with those presentation relations on bounded support:
```lean
theorem satakeAdmissible_iff_presentation_relations_on_bounded_support
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D) :
    SatakeAdmissible D ↔ PresentationRelations N D := by
  ...
```
This equivalence is likely the conceptual heart of the project.

### Proof strategy

1. **Parameterize the bounded dominant chamber by antidiagonals or height.**  
   Use the measure `p.1 + p.2` on `DomWt = ℕ × ℕ`. Bounded support means only finitely many heights occur, so induction on `k ≤ N` is natural. This gives a clean way to propagate local reconstruction from the chamber edges `(a,0)` and `(0,b)` into interior points `(a,b)`.

2. **Reconstruct candidate generator coefficients from edge valuations.**  
   The edge conditions should determine the tropical coefficients attached to the simple-coroot directions. Prove that along the two chamber walls, admissibility gives unique values for the fundamental generator data. If existing finite-generation results already say that bounded dominant support is generated by simple-coroot edge data plus rank-2 Levi profiles, invoke that theorem explicitly here to define the candidate Hecke element.

3. **Use rank-2 Levi compatibility to extend across adjacent facets.**  
   The interior of the GL₃ dominant chamber is controlled by the two rank-2 Levi subgroups corresponding to simple roots `α₁, α₂`. Show that the values propagated from the `α₁`-edge and `α₂`-edge agree on overlaps because `Levi12Compatible` and `Levi23Compatible` force the same tropical convolution profile on adjacent facets. The key local statement should be: once the boundary values on two adjacent edges are fixed, the rank-2 tropical convolution relation determines the value at the next interior lattice point.

4. **Reduce all overlap ambiguities to the finite presentation relations.**  
   There are potentially different propagation paths from edges to a given interior point. The nontrivial step is to show path independence. Here the finite-presentation theorem should be used exactly as a coherence result: all elementary moves between propagation paths are generated by the fundamental double-coset relations already known, so any two reconstructions agree. In Lean, formulate this as an induction on height together with a local diamond lemma for the two simple-root propagation operators.

5. **Package existence and uniqueness.**  
   Once the candidate `h` is constructed and shown to satisfy `tropSatake h = D`, uniqueness follows immediately from the existing injectivity theorem for the tropical Satake transform on bounded support. The final classification theorem should therefore be a short wrapper around surjectivity plus injectivity.

### Concrete proof hints for Lean

- If using `ℕ × ℕ`, define:
  ```lean
  def height (p : DomWt) : ℕ := p.1 + p.2
  ```
  and prove helper lemmas
  ```lean
  lemma height_left (a : ℕ) : height (a,0) = a := by simp [height]
  lemma height_right (b : ℕ) : height (0,b) = b := by simp [height]
  lemma interior_pred_left {a b : ℕ} (hb : 0 < b) :
      height (a, b - 1) < height (a,b) := by
    ...
  lemma interior_pred_right {a b : ℕ} (ha : 0 < a) :
      height (a - 1, b) < height (a,b) := by
    ...
  ```
  These are useful for strong induction over the chamber.

- Represent bounded support either by `D p = 0` above height `N` or by a finite support `Finset`. If you stay with functions `DomWt → ℝ`, the theorem is easier to state but you will want a finite set
  ```lean
  def chamberBox (N : ℕ) : Finset DomWt := ...
  ```
  and a lemma that every admissible bounded-support datum is determined by its values on `chamberBox N`.

- If the Hecke side is already generated by finitely many fundamental double cosets, define the candidate element by summing the reconstructed coefficients over those generators:
  ```lean
  def candidateHecke (N : ℕ) (D : TropDatum) : TropHecke := ...
  ```
  Then the central verification theorem is
  ```lean
  theorem tropSatake_candidate_eq
      (N : ℕ) (D : TropDatum)
      (hbd : BoundedSupport N D)
      (hadm : SatakeAdmissible D) :
      tropSatake (candidateHecke N D) = D := by
    ...
  ```

- For uniqueness, expect something like
  ```lean
  have hinj := gl3_tropSatake_injective_on_bounded_support N
  apply hinj
  simpa [h1eq, h2eq]
  ```
  depending on the exact catalog statement.

### Why this matters

This theorem is the missing converse needed to turn the current GL₃ tropical Satake theory into a genuine classification of bounded-support tropical Hecke data. Injectivity says the local edge/Levi invariants determine a global object if one exists; surjectivity says the admissibility relations are also sufficient. Together they identify the image of the tropical Satake transform with an explicit finitely presented combinatorial moduli space on the dominant chamber.

That is mathematically significant for two reasons:

1. It upgrades the existing finite-generation and finite-presentation results from structural information about the image to an actual realization theorem.
2. It provides the first robust template for higher-rank tropical Satake reconstruction: local rank-1 and rank-2 compatibility plus finite presentation should be the mechanism for global reconstruction in larger reductive groups as well.

So the ideal endpoint is not merely an existence theorem, but an equivalence:
```lean
theorem gl3_tropSatake_mem_range_iff_admissible_bounded
    (N : ℕ) (D : TropDatum)
    (hbd : BoundedSupport N D) :
    (∃ h : TropHecke, HeckeBoundedSupport N h ∧ tropSatake h = D) ↔
    SatakeAdmissible D := by
  constructor
  · intro h
    -- extract edge and Levi relations from an actual Hecke element
  · intro hadm
    exact gl3_tropSatake_surjective_on_bounded_support N D hbd hadm
```
This “range iff admissible” statement is the cleanest formal expression of the bounded-support GL₃ tropical Satake classification program.

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
