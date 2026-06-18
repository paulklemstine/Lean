## Research Task: GL₃ tropical Satake uniqueness from chamber-valuations of triple convolution against rank-1 Levi generators

**Research Mode: PROVE**

Work in the concrete dominant chamber
```lean
def GL3Dom : Set (ℤ × ℤ × ℤ) := {x | x.1 ≥ x.2.1 ∧ x.2.1 ≥ x.2.2}
```
or an equivalent bundled subtype
```lean
def DomGL3 := {x : ℤ × ℤ × ℤ // x.1 ≥ x.2.1 ∧ x.2.1 ≥ x.2.2}
```
and use finitely supported tropical-valued functions
```lean
abbrev Trop := WithBot ℤ
abbrev TropFn := DomGL3 → Trop
```
with finite support encoded either by `Finsupp` into `WithBot ℤ` or by an explicit `Finite` support hypothesis:
```lean
abbrev TropFinsupp := DomGL3 →₀ Trop
```

Define tropical convolution on the dominant chamber by the max-plus formula
```lean
def tconv (f g : TropFinsupp) : TropFinsupp := ...
```
where
```lean
(tconv f g) λ = ⨆ μ ν, if h : add_dom μ ν = λ then f μ + g ν else ⊥
```
or, if your existing files already define dominant-chamber convolution with truncation/projection to dominant coweights, use that exact notion instead of rebuilding it.

The target theorem should be stated as an injectivity result for a **fixed finite test family** of three rank-1 Levi generators `τ₁ τ₂ τ₃`. The cleanest theorem shape is:

```lean
theorem gl3_tropical_satake_testFamily_injective
    (τ1 τ2 τ3 : TropFinsupp)
    (hτ1 : IsRankOneLeviTest 1 τ1)
    (hτ2 : IsRankOneLeviTest 2 τ2)
    (hτ3 : IsCentralOrDetTest τ3)
    (hgen : GeneratesAdjacentFacetValuations τ1 τ2 τ3) :
    Function.Injective (fun f : TropFinsupp =>
      (tconv f τ1, tconv f τ2, tconv f τ3)) := by
  ...
```

Equivalently, in extensional form:
```lean
theorem gl3_tropical_satake_testFamily_unique
    (τ1 τ2 τ3 : TropFinsupp)
    (hτ1 : IsRankOneLeviTest 1 τ1)
    (hτ2 : IsRankOneLeviTest 2 τ2)
    (hτ3 : IsCentralOrDetTest τ3)
    (hgen : GeneratesAdjacentFacetValuations τ1 τ2 τ3)
    {f g : TropFinsupp}
    (h1 : tconv f τ1 = tconv g τ1)
    (h2 : tconv f τ2 = tconv g τ2)
    (h3 : tconv f τ3 = tconv g τ3) :
    f = g := by
  ...
```

If the existing GL₃ files already package the “pairwise GL₂ Newton polygon marginals” or “Levi marginals” as operators
```lean
leviMarginal12 : TropFinsupp → ...
leviMarginal23 : TropFinsupp → ...
leviMarginal13 : TropFinsupp → ...
```
then formulate the core bridge theorem first:

```lean
theorem rankOne_tests_determine_pairwise_marginals
    (τ1 τ2 τ3 : TropFinsupp)
    (hτ1 : IsRankOneLeviTest 1 τ1)
    (hτ2 : IsRankOneLeviTest 2 τ2)
    (hτ3 : IsCentralOrDetTest τ3)
    (hgen : GeneratesAdjacentFacetValuations τ1 τ2 τ3)
    {f g : TropFinsupp}
    (h1 : tconv f τ1 = tconv g τ1)
    (h2 : tconv f τ2 = tconv g τ2)
    (h3 : tconv f τ3 = tconv g τ3) :
    leviMarginal12 f = leviMarginal12 g ∧
    leviMarginal23 f = leviMarginal23 g ∧
    leviMarginal13 f = leviMarginal13 g := by
  ...
```

and then deduce uniqueness from the already-established GL₃ support/marginal injectivity theorem:
```lean
theorem gl3_tropical_satake_testFamily_unique'
    (τ1 τ2 τ3 : TropFinsupp)
    ...
    {f g : TropFinsupp}
    (h1 : tconv f τ1 = tconv g τ1)
    (h2 : tconv f τ2 = tconv g τ2)
    (h3 : tconv f τ3 = tconv g τ3) :
    f = g := by
  rcases rankOne_tests_determine_pairwise_marginals τ1 τ2 τ3 ... h1 h2 h3 with
    ⟨h12, h23, h13⟩
  exact gl3_marginals_injective h12 h23 h13
```

### Concrete proof strategy

1. **Extract scalar valuation formulas from convolution with each test function.**  
   Prove that for each dominant `λ`, the value `(tconv f τi) λ` can be rewritten as a supremum of an affine functional over the support of `f`, where the affine functional depends only on one adjacent-simple-root direction. The intended lemma shape is:
   ```lean
   theorem tconv_rankOne_test_eq_facet_valuation
       (τi : TropFinsupp) (hi : IsRankOneLeviTest i τi)
       (f : TropFinsupp) (λ : DomGL3) :
       (tconv f τi) λ = facetValuation i f λ := by
     ...
   ```
   This is the key operator-theoretic step: tropical convolution by a rank-1 Levi generator is not arbitrary; it is exactly a chamber support-function valuation on a codimension-1 facet family.

2. **Show equality of the three convolutions implies equality of the three induced facet valuations.**  
   Once the previous formula is available, your hypotheses
   ```lean
   h1 : tconv f τ1 = tconv g τ1
   h2 : tconv f τ2 = tconv g τ2
   h3 : tconv f τ3 = tconv g τ3
   ```
   immediately give
   ```lean
   facetValuation 1 f = facetValuation 1 g
   facetValuation 2 f = facetValuation 2 g
   centralValuation f = centralValuation g
   ```
   or the analogous three valuation equalities in your existing formalism. Make these explicit as intermediate lemmas, since they are likely reusable.

3. **Recover the pairwise GL₂ marginals from the facet valuations.**  
   Prove a reconstruction lemma saying the adjacent-facet valuations determine the pairwise rank-2/GL₂ Newton polygon marginals:
   ```lean
   theorem facet_valuations_determine_pairwise_marginals
       {f g : TropFinsupp}
       (hfac1 : facetValuation 1 f = facetValuation 1 g)
       (hfac2 : facetValuation 2 f = facetValuation 2 g)
       (hcen  : centralValuation f = centralValuation g) :
       leviMarginal12 f = leviMarginal12 g ∧
       leviMarginal23 f = leviMarginal23 g ∧
       leviMarginal13 f = leviMarginal13 g := by
     ...
   ```
   The nontrivial point is that the third test should pin down the missing translation/determinant ambiguity that the two adjacent simple-root valuations alone may leave unresolved.

4. **Invoke the existing GL₃ marginal/support injectivity theorem.**  
   Use the already-proved GL₃ reconstruction result from full Levi marginals or Horn-type support data:
   ```lean
   exact gl3_marginals_injective h12 h23 h13
   ```
   If the library theorem is stated in terms of support sets rather than functions, insert the short bridge lemma converting equality of tropical-valued marginals to equality of supports and then equality of finitely supported functions.

5. **Optional strengthening: package the result as an injective linear/tropical operator.**  
   If the current files define a tropical-semiring hom structure or at least an operator type, prove:
   ```lean
   theorem gl3_testFamily_operator_faithful
       (τ1 τ2 τ3 : TropFinsupp) ... :
       Function.Injective (testFamilyOperator τ1 τ2 τ3) := by
     ...
   ```
   This is a better endpoint than an elementwise uniqueness statement because it can be reused in later tropical Hecke algebra faithfulness arguments.

### Useful intermediate lemmas to target

These are the right granularity for Lean and isolate the geometric content from the final injectivity argument:

```lean
theorem tconv_eq_sup_over_support
    (f τ : TropFinsupp) (λ : DomGL3) :
    (tconv f τ) λ =
      Finset.sup (f.support.image fun μ => ...)
        (fun μ => f μ + τ (domSub λ μ ...)) := by
  ...
```

```lean
theorem rankOne_test_depends_only_on_adjacent_root_gap
    (τi : TropFinsupp) (hi : IsRankOneLeviTest i τi)
    (μ λ : DomGL3) :
    τi (domSub λ μ ...) = affineGapFunctional i λ μ := by
  ...
```

```lean
theorem equal_test_convolutions_imply_equal_facet_support
    (τi : TropFinsupp) (hi : IsRankOneLeviTest i τi)
    {f g : TropFinsupp}
    (h : tconv f τi = tconv g τi) :
    facetValuation i f = facetValuation i g := by
  ...
```

```lean
theorem pairwise_marginals_injective_on_gl3
    {f g : TropFinsupp}
    (h12 : leviMarginal12 f = leviMarginal12 g)
    (h23 : leviMarginal23 f = leviMarginal23 g)
    (h13 : leviMarginal13 f = leviMarginal13 g) :
    f = g := by
  ...
```

If exact existing names differ, preserve the mathematical structure above and align to the established API.

### Technical Lean guidance

- Use `Finsupp.ext` for the final equality of tropical functions.
- For tropical suprema over finite support, reduce to `Finset.sup` rather than arbitrary `iSup`; finite support should make the order-theoretic side manageable.
- If `WithBot ℤ` creates coercion friction, establish small helper lemmas for:
  ```lean
  by_cases h : f μ = ⊥
  ```
  and for monotonicity of `sup`.
- If dominant subtraction `λ - μ` is only partially defined, package it as an `Option DomGL3` and prove the test functions vanish off the admissible decomposition set; this often simplifies convolution formulas.
- It may be cleaner to formulate all valuation identities first on supports:
  ```lean
  supportValuation : Finset DomGL3 → DomGL3 → ℤ
  ```
  and only then lift to weighted tropical functions. That separates combinatorial chamber geometry from max-plus weights.

### Why this matters

This theorem is a sharp **operator separation principle** for the tropical Hecke algebra of `GL₃`: instead of reconstructing a finitely supported chamber function from a large family of marginals or from full support data, it shows that convolution against just three canonical rank-1/Levi test objects already determines the input. That is stronger and conceptually cleaner than support reconstruction alone. It gives a finite criterion for faithfulness of tropical Hecke action, provides a new route around the still-open surjectivity direction, and isolates the exact mechanism by which adjacent-facet valuations encode all pairwise GL₂ Newton data. In particular, once formalized, this should become the reusable injectivity engine for any later `GL₃` tropical Satake or tropical Hecke representation theorem.

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
