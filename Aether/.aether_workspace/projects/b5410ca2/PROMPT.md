## Research Task: Tropical Satake convolution-faithfulness for GL₂ via min-plus Newton polygon recovery

**Research Mode: PROVE**

Work in a new file
`Tropical/Langlands/GL2/TropicalSatakeFaithful.lean`.

Establish a precise injectivity/reconstruction theorem for the already formalized tropical spherical Hecke algebra of `GL₂`. The target is not merely another isomorphism statement: the goal is to prove that a tropical Hecke operator is uniquely recoverable from its action on dominant coweights, and equivalently from the min-plus Newton polygon of its tropical Satake transform.

The cleanest formal endpoint is a chain of implications:

1. equality of tropical convolution operators on all dominant coweights,
2. equality of tropical Satake transforms,
3. equality of Hecke elements.

This should culminate in a reconstruction theorem expressing that the “top Cartan shell” of a Hecke function is detected by the leading slope/support face of its Satake image, and then recovered inductively.

---

### Precise theorem statements to aim for

Use the concrete types and names already present in the GL₂ tropical Satake development; if exact structure names differ slightly, preserve the mathematical shape below.

A first operator-faithfulness theorem:

```lean
theorem tropical_convolution_faithful_GL2
    (f g : TropicalHeckeGL2) :
    (∀ λ : DominantCoweightGL2, tropicalConvolutionAction f λ = tropicalConvolutionAction g λ) →
    f = g
```

If the action is encoded as convolution with a delta basis element, the more concrete variant is:

```lean
theorem tropical_convolution_faithful_on_dominant_GL2
    (f g : TropicalHeckeGL2) :
    (∀ λ : DominantCoweightGL2, f ⋆ δ λ = g ⋆ δ λ) →
    f = g
```

A Satake-injectivity theorem:

```lean
theorem tropical_satake_injective_GL2
    {f g : TropicalHeckeGL2} :
    tropicalSatakeGL2 f = tropicalSatakeGL2 g → f = g
```

A combined extensionality theorem, useful for later applications:

```lean
theorem tropical_satake_ext_GL2
    {f g : TropicalHeckeGL2} :
    f = g ↔ tropicalSatakeGL2 f = tropicalSatakeGL2 g
```

A support-triangularity lemma should be isolated explicitly, since it is the real engine behind injectivity. In whatever indexing type is used for Cartan/dominant coweights, prove something of the following form:

```lean
theorem tropical_satake_top_shell_detects
    (f : TropicalHeckeGL2) :
    ∀ n,
      isTopCartanIndex f n →
      topSlope (tropicalSatakeGL2 f) = some (slopeOfIndex n) ∧
      topCoefficient (tropicalSatakeGL2 f) = coefficientAtCartan f n
```

If the development already has a notion of finite support maximum instead of `isTopCartanIndex`, use that directly. The point is to isolate the “highest nonzero Cartan distance is readable from the leading tropical slope” statement.

Then prove the inductive peeling lemma:

```lean
theorem tropical_satake_recover_by_induction
    (f : TropicalHeckeGL2) :
    ∃ coeffs : CartanIndexGL2 → TropicalWeight,
      FiniteSupport coeffs ∧
      reconstructFromSatakeNewton (tropicalSatakeGL2 f) = coeffs ∧
      coeffs = heckeCoefficients f
```

If `reconstructFromSatakeNewton` is too ambitious as a new definition, replace it by an existential uniqueness theorem saying that the Newton polygon data determines the coefficients uniquely.

A practical uniqueness statement:

```lean
theorem tropical_satake_newton_polygon_faithful_GL2
    {f g : TropicalHeckeGL2} :
    newtonPolygon (tropicalSatakeGL2 f) = newtonPolygon (tropicalSatakeGL2 g) →
    f = g
```

Only prove this stronger statement if your existing Newton polygon API is rich enough. Otherwise, prove the weaker but still substantial theorem that equality of Satake images implies equality of Hecke elements, and separately prove that for `GL₂` the Satake image is determined by its lower hull / slope multiset.

---

### Suggested definitions/auxiliary lemmas

You will likely need a support filtration by Cartan radius or dominant index. Introduce it explicitly if it is not already available:

```lean
def cartanRadius : TropicalHeckeGL2 → ℕ
def truncatedAt : ℕ → TropicalHeckeGL2 → TropicalHeckeGL2
def topCartanSupport : TropicalHeckeGL2 → Finset ℕ
```

Then prove finite-support and truncation lemmas such as:

```lean
theorem exists_max_support_index
    (f : TropicalHeckeGL2) :
    f ≠ 0 → ∃ n, coefficientAtCartan f n ≠ ⊥ ∧
      ∀ m > n, coefficientAtCartan f m = ⊥
```

or the corresponding additive/tropical-zero formulation used in the file.

A triangularity statement for the action on dominant weights:

```lean
theorem convolution_on_large_weight_triangular
    (f : TropicalHeckeGL2) :
    ∃ N, ∀ λ ≥ N,
      leadingTermIndex ((tropicalConvolutionAction f) λ) =
        maxCartanIndexInSupport f
```

and a Satake-side asymptotic extraction lemma:

```lean
theorem tropical_satake_slope_recovers_top_index
    (f : TropicalHeckeGL2) :
    f ≠ 0 →
    slopeAtInfinity (tropicalSatakeGL2 f) = maxCartanIndexInSupport f
```

If “slope at infinity” is not already formalized, use an equivalent combinatorial notion: maximal exponent, maximal dominant monomial, or eventual affine-linear behavior along the dominant ray.

For the induction step, isolate subtraction/removal of the top shell:

```lean
theorem remove_top_shell_strictly_decreases_radius
    (f : TropicalHeckeGL2) :
    f ≠ 0 →
    cartanRadius (f - topShell f) < cartanRadius f
```

In a semiring/tropical setting where literal subtraction is unavailable, define `eraseTopShell` by support restriction instead.

---

### Proof strategy

1. **Introduce a Cartan-support filtration and prove triangularity.**  
   Index the spherical double cosets by dominant coweights for `GL₂`, which in rank one should reduce to a single natural-number parameter. Show that a finitely supported tropical Hecke function has a well-defined maximal Cartan index. Then prove that convolution with `δ_λ` for sufficiently large dominant `λ` has a unique leading contribution coming from that maximal index. This is the tropical analogue of upper-triangularity of the Cartan basis.

2. **Relate the leading Cartan shell to the leading tropical monomial/slope of the Satake image.**  
   Use the already formalized tropical Satake formulas on fundamental/dominant coweights to show that the maximal support index of `f` contributes the extremal slope/monomial of `tropicalSatakeGL2 f`, and lower support indices cannot cancel it because tropical addition is min/max and the support filtration is strict. This is where the min-plus Newton polygon enters: the top shell corresponds to the outermost face / leading slope.

3. **Prove injectivity by maximal-support contradiction.**  
   Assume `tropicalSatakeGL2 f = tropicalSatakeGL2 g` but `f ≠ g`. Apply the theorem to `h := difference_or_supportSymmetricDifference f g` (depending on the ambient algebraic structure). Let `n` be the maximal Cartan index where `f` and `g` differ. By the slope-detection lemma, the Satake image of `h` has a detectable leading slope/monomial at index `n`, contradicting `tropicalSatakeGL2 h = 0`. This yields `tropical_satake_injective_GL2`.

4. **Deduce convolution-faithfulness from Satake injectivity or directly from action on basis vectors.**  
   If the development already contains compatibility of Satake with convolution action, use it to show that equal action on all dominant basis vectors implies equal Satake image. Alternatively, use the triangular action lemma directly: if `f` and `g` act identically on all large enough dominant `λ`, their top Cartan shells must agree; peel them off and iterate by induction on support radius.

5. **Package the reconstruction statement.**  
   Once injectivity is proved, formulate an extensionality theorem saying the Satake transform determines the Hecke element. If the Newton polygon API is available, define the lower hull / slope sequence of the tropical Satake image and prove this data determines the coefficients recursively in rank one. Even a theorem of the form “same Newton polygon implies same Satake image for GL₂ tropical symmetric Laurent polynomials with finite support” would already give the advertised recovery principle.

---

### Key technical lemmas likely needed

- Finite support of every spherical tropical Hecke element in the Cartan basis.
- Existence of a maximal support index for a nonzero element.
- Monotonicity of dominant-weight translation: evaluating on sufficiently large dominant weights separates support shells.
- No cancellation of the top shell in tropical convolution/Satake expansion.
- Eventual affine-linearity or extremal-monomial stability of the Satake image along the dominant ray.
- Induction on `cartanRadius f` or on `Finset.max'` of the support.

A useful induction skeleton is:

```lean
refine Nat.strong_induction_on (cartanRadius f) ?_
```

combined with a decomposition into `topShell f` and `eraseTopShell f`.

If equality of Hecke elements is extensional over coefficients, register an ext lemma early:

```lean
@[ext] theorem TropicalHeckeGL2.ext :
    (∀ n, coefficientAtCartan f n = coefficientAtCartan g n) → f = g
```

This will make the final reconstruction theorem much easier to state and reuse.

---

### Significance

This theorem upgrades the tropical Satake story for `GL₂` from a correspondence theorem to a genuine reconstruction principle. It shows that tropical Hecke operators are not just representable on the Satake side: they are *rigidly encoded* by their tropical spectral data. In rank one, this is exactly the place where convex-geometric Newton polygon methods and tropical representation theory meet in a theorem with computational content.

Formally, this gives a reusable uniqueness principle for future files on tropical Hecke algebras, tropical automorphic forms, and min-plus harmonic analysis. Mathematically, it is the first theorem in the program that says the tropical Satake transform is not merely surjective or structure-preserving, but *faithful*, with explicit recovery from leading slopes. That makes later work on tropical eigenpackets, tropical excursion operators, and higher-rank tropical Satake filtrations much more plausible.

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
