## Research Task: GL₃ tropical Satake finite-determinacy from bounded-support Levi moments

Work in the concrete bounded-support GL₃ dominant-coweight model already used in the tropical Satake development. The target is a genuine finite-determinacy theorem: on a fixed dominant box, equality of a finite family of tropical convolution observables against rank-1 and rank-2 Levi generators, together with finitely many edge moments, forces equality of the underlying finitely supported functions.

### Precise theorem statement

Use a concrete statement of the following shape, with the actual names in the local development substituted as needed:

```lean
theorem gl3_tropical_satake_finite_determinacy_bounded_support
    {B : DomCoweight}
    {f g : DomCoweight → Tropical}
    (hf : FiniteSupportWithin B f)
    (hg : FiniteSupportWithin B g)
    (hconv :
      ∀ t s,
        t ∈ finiteRank1Range B →
        s ∈ finiteRank2Range B →
        tripleConvObservable f t s = tripleConvObservable g t s)
    (hedge :
      ∀ e,
        e ∈ finiteEdgeMomentRange B →
        edgeMoment f e = edgeMoment g e) :
    f = g
```

If your library separates the two Levi families more cleanly, a stronger and often easier-to-use version is:

```lean
theorem gl3_tropical_satake_finite_determinacy_bounded_support'
    {B : DomCoweight}
    {f g : DomCoweight → Tropical}
    (hf : FiniteSupportWithin B f)
    (hg : FiniteSupportWithin B g)
    (hL1 :
      ∀ t,
        t ∈ finiteRank1Range B →
        rank1Profile f t = rank1Profile g t)
    (hL2 :
      ∀ s,
        s ∈ finiteRank2Range B →
        rank2Profile f s = rank2Profile g s)
    (hedge :
      ∀ e,
        e ∈ finiteEdgeMomentRange B →
        edgeMoment f e = edgeMoment g e) :
    f = g
```

A very useful intermediate theorem, and likely the real engine of the proof, is the “difference version”:

```lean
theorem gl3_tropical_satake_zero_of_vanishing_finite_tests
    {B : DomCoweight}
    {h : DomCoweight → Tropical}
    (hh : FiniteSupportWithin B h)
    (hconv :
      ∀ t s,
        t ∈ finiteRank1Range B →
        s ∈ finiteRank2Range B →
        tripleConvObservable h t s = 0)
    (hedge :
      ∀ e,
        e ∈ finiteEdgeMomentRange B →
        edgeMoment h e = 0) :
    h = 0
```

Then derive the main theorem by applying this to the pointwise tropical/semiring difference or to the extensional uniqueness theorem already available in the development.

### Mathematical content to establish

The finite test set should not be an arbitrary truncation. What must be proved is that the support bound `B` induces a finite “reconstruction horizon” for all chamber data. Concretely:

1. only finitely many adjacent-facet values can contribute to any tropical convolution involving a function supported in `≤ B`;
2. chamber-edge moments in a bounded finite range determine all edge data by recursion;
3. rank-2 Levi profiles plus edge data determine the full chamber valuation profile;
4. the existing GL₃ uniqueness theorem then upgrades equality of reconstructed chamber data to equality of the original functions.

This is the noetherian step missing from the current injectivity story.

### Suggested supporting lemmas

You will likely want explicit boundedness lemmas of the following form.

```lean
lemma finiteRank1Range_spec
    {B : DomCoweight} :
    ∀ t, t ∈ finiteRank1Range B ↔ rank1Relevant B t
```

```lean
lemma finiteRank2Range_spec
    {B : DomCoweight} :
    ∀ s, s ∈ finiteRank2Range B ↔ rank2Relevant B s
```

```lean
lemma finiteEdgeMomentRange_spec
    {B : DomCoweight} :
    ∀ e, e ∈ finiteEdgeMomentRange B ↔ edgeRelevant B e
```

```lean
lemma bounded_support_implies_vanishing_outside
    {B : DomCoweight} {f : DomCoweight → Tropical}
    (hf : FiniteSupportWithin B f) :
    ∀ λ, ¬ λ ≤ B → f λ = 0
```

```lean
lemma tripleConvObservable_depends_only_on_finite_window
    {B : DomCoweight} {f : DomCoweight → Tropical}
    (hf : FiniteSupportWithin B f) :
    ∀ t s,
      tripleConvObservable f t s =
        tripleConvObservable (truncateToBox B f) t s
```

```lean
lemma edge_recursion_from_finite_initial_data
    {B : DomCoweight} {f g : DomCoweight → Tropical}
    (hf : FiniteSupportWithin B f) (hg : FiniteSupportWithin B g)
    (hinit :
      ∀ e, e ∈ finiteEdgeMomentRange B →
        edgeMoment f e = edgeMoment g e) :
    ∀ e, edgeMoment f e = edgeMoment g e
```

and then a reconstruction lemma such as

```lean
lemma bounded_rank2_and_edge_data_determine_chamber_profile
    {B : DomCoweight} {f g : DomCoweight → Tropical}
    (hf : FiniteSupportWithin B f) (hg : FiniteSupportWithin B g)
    (hL2 :
      ∀ s, s ∈ finiteRank2Range B →
        rank2Profile f s = rank2Profile g s)
    (hedge :
      ∀ e, e ∈ finiteEdgeMomentRange B →
        edgeMoment f e = edgeMoment g e) :
    chamberProfile f = chamberProfile g
```

If the library’s existing uniqueness theorem is phrased in terms of chamber valuations rather than full profiles, target that exact codomain instead:

```lean
lemma bounded_tests_determine_chamberValuation
    ...
    : chamberValuation f = chamberValuation g
```

followed by

```lean
exact existing_uniqueness_theorem hf hg hchamber
```

### Concrete proof strategy

1. **Pass to the bounded difference problem.**  
   Define the relation you need on `f` and `g` through the existing extensionality theorem. If there is a subtraction/difference operation compatible with the tropical model in your file, prove the zero-detection theorem for `h := f - g`; otherwise work directly with equality of profiles. The key simplification is that all observables for bounded-support functions depend only on a finite set of coweights.

2. **Show finite observables generate all relevant Levi/chamber data.**  
   Use `hf` and `hg` to prove that outside the box `B`, contributions vanish. Then prove that for parameters `t,s` outside `finiteRank1Range B` / `finiteRank2Range B`, the corresponding convolution observables are either constant, zero, or recursively determined by smaller parameters. This is the noetherian bounded-support lemma: every potentially contributing index is bounded by a measure extracted from `B`.

3. **Bootstrap finite edge moments to all edge moments.**  
   Apply the Weyl-chamber edge-moment recursion already developed in the GL₃ reconstruction work. The important point is to prove that the recursion terminates because the support is bounded: choose a natural-valued measure on edge indices and run strong induction. The initial conditions are exactly `hedge` on `finiteEdgeMomentRange B`.

4. **Recover chamber data from rank-2 Levi profiles plus edge data.**  
   Invoke the existing reconstruction theorem from rank-2 Levi convolution profiles and edge moments. If the theorem expects full rank-2 data, combine step 2 with the finite-range hypothesis `hconv` to extend equality from the finite test set to all parameters.

5. **Finish with the previously proved uniqueness theorem.**  
   Once you have equality of chamber valuations/profiles, apply the existing GL₃ tropical Satake uniqueness theorem to conclude `f = g`. This final step should be short if the intermediate codomain is chosen to match the existing theorem exactly.

### Key technical hints for Lean 4

- Prefer proving `f = g` by `funext λ λ => ...` only if the existing uniqueness theorem is unavailable. Otherwise use the catalog uniqueness theorem directly; it will avoid painful pointwise tropical algebra.
- If `FiniteSupportWithin B f` is encoded via a `Finset` support condition, immediately derive a lemma that every convolution sum/max can be restricted to a finite `Finset`. This usually turns opaque support hypotheses into rewrite lemmas usable by `simp`.
- For the recursion step, define a natural measure such as a coordinate sum, height, or distance to the boundary of the dominant box:
  ```lean
  def edgeHeight (B : DomCoweight) (e : EdgeIndex) : ℕ := ...
  ```
  Then use `Nat.strong_induction_on`.
- If `tripleConvObservable` factors through separate rank-1 and rank-2 profiles, prove that factorization once and rewrite `hconv` into the exact hypotheses needed by the reconstruction theorem.
- Expect to need extensionality lemmas for dominant coweights, e.g. reducing `λ ≤ B` to coordinate inequalities. Prove these early; they will make the boundedness arguments manageable.

### Why this matters

This theorem is the finite-determinacy completion of the GL₃ tropical Satake program. The current injectivity/reconstruction results are conceptually strong but still “infinite-data” in flavor: they identify a parameter from entire convolution profiles or all chamber-edge moments. The bounded-support theorem shows that on any fixed dominant box, only finitely many Hecke-side observables are needed, and moreover gives an explicit separating family built from rank-1 and rank-2 Levi generators. That is the correct tropical analogue of finite jet-determinacy/noetherianity: bounded geometric complexity forces finite testability.

Formally, this result is also strategically important because it turns abstract uniqueness into a computationally usable theorem. Once proved, it should support:
- algorithmic reconstruction of bounded tropical Satake parameters;
- finite certification procedures for equality/injectivity in GL₃;
- later generalization to `GL n` by induction on Levi rank and chamber combinatorics.

So the core deliverable is not just another injectivity lemma: it is the theorem that bounded support collapses infinite tropical Satake data to a finite separating set.

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
