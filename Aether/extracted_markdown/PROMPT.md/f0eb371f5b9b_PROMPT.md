## Research Task: Tropical Satake convolution-faithfulness for `GL₃` from adjacent-facet support functions on the dominant chamber

Research Mode: PROVE

Work in a concrete `GL₃` dominant-coweight model using triples `μ : ℕ × ℕ × ℕ` with dominance
`μ.1 ≥ μ.2 ∧ μ.2 ≥ μ.3`.  The intended tropical Satake transform is a min-plus support function
built from a finitely supported coefficient function `f : (ℕ × ℕ × ℕ) → ℝ∞` (or `ℝ` if your existing
development uses finite weights only) by
\[
\operatorname{trop}(f)(x) = \inf_{\mu \in \operatorname{supp}(f)} \bigl(f(\mu)+\langle \mu,x\rangle\bigr),
\]
or the max-plus variant if that is the convention already established in the tropical Hecke files.
Do not fight the existing sign convention: formulate every theorem in the native min-plus/max-plus language
already present, but make the statements below literally precise in Lean.

### Suggested concrete definitions

If these are not already present, introduce a small dedicated namespace for dominant triples and adjacent facets.

```lean
def DomGL3 : Type := {μ : ℕ × ℕ × ℕ // μ.1.1 ≥ μ.1.2 ∧ μ.1.2 ≥ μ.2}

def evalWeight (μ x : ℕ × ℕ × ℕ) : ℤ :=
  (μ.1.1 : ℤ) * (x.1.1 : ℤ) + (μ.1.2 : ℤ) * (x.1.2 : ℤ) + (μ.2 : ℤ) * (x.2 : ℤ)

def Facet12 : Set (ℕ × ℕ × ℕ) := {x | x.1.1 = x.1.2}
def Facet23 : Set (ℕ × ℕ × ℕ) := {x | x.1.2 = x.2}
def Facet30 : Set (ℕ × ℕ × ℕ) := {x | x.2 = 0}

def Dominant (x : ℕ × ℕ × ℕ) : Prop := x.1.1 ≥ x.1.2 ∧ x.1.2 ≥ x.2
```

For finitely supported functions, the cleanest type is usually:
```lean
abbrev Wt := ℕ × ℕ × ℕ
abbrev TropFn := Wt → ℤ
```
together with `Finsupp` support:
```lean
def tropSat (f : Wt →₀ ℤ) (x : Wt) : ℤ :=
  (f.support.inf' (by simpa using f.support_nonempty_iff.mpr ?h)
    (fun μ => f μ + evalWeight μ x))
```
or the corresponding `sInf`/`iInf` version if your existing tropical transform is already defined.  
If the library already has a support-function object for finite sets in `ℝ`, it is also acceptable to pass to
`Finset`-based support functions first and only then state the reconstruction theorem for `Finsupp`.

### Main theorem: adjacent-facet determination on the dominant chamber

The key new statement should be formalized in a form close to the following.

```lean
theorem tropSat_eq_of_eq_on_adjacent_facets
    (f g : Wt →₀ ℤ)
    (hf_dom : ∀ μ ∈ f.support, Dominant μ)
    (hg_dom : ∀ μ ∈ g.support, Dominant μ)
    (h12 : ∀ x, Dominant x → x ∈ Facet12 → tropSat f x = tropSat g x)
    (h23 : ∀ x, Dominant x → x ∈ Facet23 → tropSat f x = tropSat g x)
    (h30 : ∀ x, Dominant x → x ∈ Facet30 → tropSat f x = tropSat g x) :
    f = g
```

If equality of coefficients is too strong at the first pass because the current transform forgets additive
normalization, prove the support-level version first and then strengthen it:

```lean
theorem tropSat_support_eq_of_eq_on_adjacent_facets
    (f g : Wt →₀ ℤ) ... :
    f.support = g.support
```

and then a coefficient-recovery theorem

```lean
theorem tropSat_coeff_eq_of_support_eq_of_eq_on_adjacent_facets
    (f g : Wt →₀ ℤ) ... :
    f = g
```

A geometrically cleaner equivalent formulation is to package the transform as the support function of the Newton set:
```lean
def newtonSupport (f : Wt →₀ ℤ) : Finset Wt := f.support
```
and prove that the finite dominant set is determined by the three restricted support functions.  This may be easier
than proving coefficient equality directly, because support reconstruction can be expressed via exposed points.

### Structural lemma you should target first

The heart of the argument is an exposed-point lemma specialized to dominant triples.

A useful exact statement is:

```lean
theorem dominant_triple_exposed_by_adjacent_facet
    (μ : Wt) (hμ : Dominant μ) :
    ∃ x : Wt,
      Dominant x ∧
      (x ∈ Facet12 ∨ x ∈ Facet23 ∨ x ∈ Facet30) ∧
      ∀ ν : Wt, Dominant ν → ν ≠ μ → evalWeight μ x < evalWeight ν x ∨ evalWeight ν x < evalWeight μ x
```

But for reconstruction you need a sharper separation statement saying that for any distinct dominant `μ ≠ ν`,
some dominant `x` on one of the three adjacent facets separates them:
```lean
theorem dominant_pair_separated_by_adjacent_facet
    {μ ν : Wt} (hμ : Dominant μ) (hν : Dominant ν) (hneq : μ ≠ ν) :
    ∃ x : Wt,
      Dominant x ∧
      (x ∈ Facet12 ∨ x ∈ Facet23 ∨ x ∈ Facet30) ∧
      evalWeight μ x ≠ evalWeight ν x
```

An even more useful oriented version is:
```lean
theorem dominant_pair_strictly_ordered_by_adjacent_facet
    {μ ν : Wt} (hμ : Dominant μ) (hν : Dominant ν) (hneq : μ ≠ ν) :
    ∃ x : Wt,
      Dominant x ∧
      (x ∈ Facet12 ∨ x ∈ Facet23 ∨ x ∈ Facet30) ∧
      evalWeight μ x < evalWeight ν x
```
or the same with the inequality direction allowed to depend on `x`.  
This is the finite-dimensional separation statement that converts boundary equality of support functions into equality
of the underlying dominant support set.

### Concrete proof strategy

1. **Parametrize each adjacent facet by two free dominant coordinates.**  
   On `Facet12`, write `x = (a,a,b)` with `a ≥ b`; then
   \[
   \langle \mu,x\rangle = (\mu_1+\mu_2)a + \mu_3 b.
   \]
   On `Facet23`, write `x = (a,b,b)` with `a ≥ b`; then
   \[
   \langle \mu,x\rangle = \mu_1 a + (\mu_2+\mu_3)b.
   \]
   On `Facet30`, write `x = (a,b,0)` with `a ≥ b`; then
   \[
   \langle \mu,x\rangle = \mu_1 a + \mu_2 b.
   \]
   Thus the three facet restrictions recover exactly the three pairwise linear forms
   \[
   (\mu_1+\mu_2,\mu_3),\quad (\mu_1,\mu_2+\mu_3),\quad (\mu_1,\mu_2).
   \]
   This is the decisive combinatorial compression: each wall sees a `GL₂`-type projection.

2. **Prove injectivity of the projection family on dominant triples.**  
   Show that the map
   ```lean
   def adjacentData (μ : Wt) : (ℕ × ℕ) × (ℕ × ℕ) × (ℕ × ℕ) :=
     ((μ.1.1 + μ.1.2, μ.2), (μ.1.1, μ.1.2 + μ.2), (μ.1.1, μ.1.2))
   ```
   is injective.  In fact the third component already recovers `(μ₁, μ₂)`, and then the first or second recovers `μ₃`.
   Formalize:
   ```lean
   theorem adjacentData_injective : Function.Injective adjacentData
   ```
   This is elementary, but it tells you what the facet data should determine at the level of a single exposed support point.

3. **Lift injectivity from points to finite support functions via support-function minimizers.**  
   For each `μ ∈ f.support`, construct a dominant test vector `x` lying on one adjacent facet such that `μ` is the unique
   minimizer of `ν ↦ f ν + evalWeight ν x` among `ν ∈ f.support`.  Because the support is finite, it suffices to choose
   `x` with sufficiently large scale in one facet direction to lexicographically prioritize one of the projected pairs from step 2.
   A robust choice is to use rays:
   - on `Facet30`: `x_N = (N,1,0)` with `N` large;
   - on `Facet12`: `x_N = (N,N,1)`;
   - on `Facet23`: `x_N = (N,1,1)`.
   
   Then prove asymptotic comparison lemmas of the form
   ```lean
   theorem eventually_orders_by_first_then_second
       {μ ν : Wt} (h : μ.1.1 < ν.1.1 ∨ (μ.1.1 = ν.1.1 ∧ μ.1.2 < ν.1.2)) :
       ∃ N0, ∀ N ≥ N0, evalWeight μ (N,1,0) < evalWeight ν (N,1,0)
   ```
   and analogous lemmas on the other two facets.  
   These give unique minimizers by finite support and a “choose `N` larger than all pairwise error bounds” argument.

4. **Deduce equality of supports from equality of restricted tropical transforms.**  
   If `μ ∈ f.support` is exposed on some adjacent facet at `x`, then equality
   `tropSat f x = tropSat g x` forces `g` to have a support point with the same adjacent projection data.  
   By `adjacentData_injective`, that support point must equal `μ`. Hence every support point of `f` lies in `g.support`, and vice versa.
   Formalize a finite-set extensionality lemma:
   ```lean
   theorem support_subset_of_eq_on_adjacent_facets
       (f g : Wt →₀ ℤ) ... :
       f.support ⊆ g.support
   ```
   and then apply symmetry.

5. **Recover coefficients once supports agree.**  
   After `f.support = g.support`, isolate the coefficient at a fixed support point `μ` using the same exposing `x`.
   For large exposing `x`, the tropical value is exactly `f μ + evalWeight μ x`, since `μ` is the unique minimizer.  
   Equality of transforms on that facet gives
   \[
   f(\mu)+\langle \mu,x\rangle = g(\mu)+\langle \mu,x\rangle,
   \]
   hence `f μ = g μ`.  Conclude by `Finsupp.ext`.
   This avoids any need for a general Legendre duality theorem.

### Recommended intermediate lemmas

These are worth proving explicitly because they modularize the hard part and should be reusable later for `GL₄`.

```lean
theorem eval_on_facet12
    (μ : Wt) {a b : ℕ} :
    evalWeight μ (a,b,b) = (μ.1.1 : ℤ) * a + ((μ.1.2 + μ.2 : ℕ) : ℤ) * b
```
```lean
theorem eval_on_facet23
    (μ : Wt) {a b : ℕ} :
    evalWeight μ (a,a,b) = (((μ.1.1 + μ.1.2 : ℕ) : ℤ) * a) + (μ.2 : ℤ) * b
```
```lean
theorem eval_on_facet30
    (μ : Wt) {a b : ℕ} :
    evalWeight μ (a,b,0) = (μ.1.1 : ℤ) * a + (μ.1.2 : ℤ) * b
```

```lean
theorem unique_minimizer_on_large_facet30_ray
    (f : Wt →₀ ℤ) {μ : Wt} (hμ : μ ∈ f.support) :
    ∃ N0, ∀ N ≥ N0,
      IsGreatest
        {m : Wt | m ∈ f.support ∧
          ∀ ν ∈ f.support, f m + evalWeight m (N,1,0) ≤ f ν + evalWeight ν (N,1,0)}
        μ
```
Adjust `IsGreatest`/`IsLeast` to your min-plus convention; in practice a custom uniqueness lemma may be easier than forcing
order-theoretic packaging.

```lean
theorem adjacent_facets_determine_support
    (f g : Wt →₀ ℤ) ... :
    f.support = g.support
```

```lean
theorem adjacent_facets_determine_coefficients
    (f g : Wt →₀ ℤ) ... :
    f = g
```

### Convolution-faithfulness corollary

Once the reconstruction theorem is in place, prove the faithful-action statement for tropical convolution on dominant support.

If tropical convolution is already defined as `tconv`, aim for:

```lean
theorem tconv_left_cancel_dominant
    (h f g : Wt →₀ ℤ)
    (hh_nonzero : h ≠ 0)
    (hh_dom : ∀ μ ∈ h.support, Dominant μ)
    (hf_dom : ∀ μ ∈ f.support, Dominant μ)
    (hg_dom : ∀ μ ∈ g.support, Dominant μ)
    (hconv : tconv f h = tconv g h) :
    f = g
```

or equivalently right-cancellation if that is the convention in your files.

The intended proof is short once the main theorem exists:

1. Apply the tropical Satake transform to `hconv`.
2. Use the transform-to-convolution identity already present in the development:
   \[
   \operatorname{TropSat}(f ∗ h)=\operatorname{TropSat}(f)+\operatorname{TropSat}(h)
   \]
   in the tropical semiring sense.
3. Restrict to each adjacent facet; cancel the common summand `TropSat(h)` pointwise.
4. Invoke `tropSat_eq_of_eq_on_adjacent_facets` to conclude `f = g`.

If cancellation in the tropical semiring is delicate because `+∞` may appear, first prove a “nondegenerate on dominant chamber” lemma under `hh_nonzero`
ensuring the facet restrictions are finite somewhere, or specialize to coefficient types where ordinary additive cancellation is available.

### Why this matters

This is the sharpest plausible `GL₃` boundary-determination theorem: instead of requiring the full tropical transform on the dominant chamber,
or all hypersimplex facets, or all pairwise `GL₂` marginals, it shows that the three geometrically adjacent codimension-1 walls already suffice.
That is exactly the minimal Weyl-boundary dataset one would expect from the `A₂` chamber geometry.  Proving it would do three important things:

1. **Upgrade reconstruction from redundant to minimal data.**  
   It identifies the smallest natural boundary package from which a dominant tropical Satake transform can be recovered.

2. **Strengthen the Hecke-faithfulness story.**  
   The convolution corollary says every nonzero dominant kernel acts faithfully, giving a clean injectivity principle for tropical Hecke operators.

3. **Provide the correct `GL₃` model for higher-rank generalization.**  
   The mechanism here—facetwise `GL₂` projections plus exposed-point recovery—looks like the right blueprint for the open `GL₄` and tropical Hecke problems.
   Even partial formalization of the separation lemmas and large-ray unique minimizer arguments would be valuable reusable infrastructure.

A good endpoint is a file proving the support-reconstruction theorem completely, with coefficient recovery and convolution-faithfulness either completed or reduced
to one clearly isolated hard lemma about unique minimizers along large facet rays.

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
