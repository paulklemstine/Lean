## Research Task: Tropical Satake support reconstruction for `GL₄` via min-plus hypersimplex facet data, with dominant-chamber convolution faithfulness

### Research Mode
PROVE

### Core formal objects to introduce
Work with dominant integer 4-tuples as the `GL₄` dominant coweight monoid:
```lean
def DomGL4 : Set (Fin 4 → ℤ) :=
  {μ | μ 0 ≥ μ 1 ∧ μ 1 ≥ μ 2 ∧ μ 2 ≥ μ 3}
```
For finite-support functions, prefer an explicit finite support container:
```lean
structure TropFuncGL4 where
  support : Finset (Fin 4 → ℤ)
  val : (Fin 4 → ℤ) → ℝ
  dom_mem : ∀ μ ∈ support, μ ∈ DomGL4
```
and interpret `μ ∉ support` as coefficient `∞` if you later move to `ℝ∞`. If `ENNReal`/`WithTop ℝ` becomes cumbersome, it is acceptable to first formalize the faithful finite-valued case with
```lean
val : (Fin 4 → ℤ) → ℝ
```
supported on a finite `Finset`, because the faithfulness argument is really a finite min-attainment argument.

Define the three fundamental-weight tropical test functionals on `μ : Fin 4 → ℤ` by partial sums:
```lean
def omega1Eval (μ : Fin 4 → ℤ) : ℤ := μ 0
def omega2Eval (μ : Fin 4 → ℤ) : ℤ := μ 0 + μ 1
def omega3Eval (μ : Fin 4 → ℤ) : ℤ := μ 0 + μ 1 + μ 2
```
and also the adjacent root-gap coordinates
```lean
def gap12 (μ : Fin 4 → ℤ) : ℤ := μ 0 - μ 1
def gap23 (μ : Fin 4 → ℤ) : ℤ := μ 1 - μ 2
def gap34 (μ : Fin 4 → ℤ) : ℤ := μ 2 - μ 3
```
These are the right finite family of tropical linear observables for exposing dominant vertices.

A useful compressed encoding of dominant coweights is:
```lean
def domKey (μ : Fin 4 → ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (omega1Eval μ, omega2Eval μ, omega3Eval μ, μ 0 + μ 1 + μ 2 + μ 3)
```
or, even better for injectivity on dominant tuples,
```lean
def domGapKey (μ : Fin 4 → ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (gap12 μ, gap23 μ, gap34 μ, μ 3)
```
since this recovers `μ` exactly by telescoping.

### Main theorem package to aim for

#### 1. Dominant coweights are separated by fundamental sums and simple-root gaps
This is the algebraic backbone of support reconstruction.

```lean
theorem domGapKey_injective :
    Function.Injective domGapKey
```

A more geometric corollary, closer to the tropical exposure language:
```lean
theorem dominant_extensionality_by_fundamental_and_gap
    {μ ν : Fin 4 → ℤ}
    (hμ : μ ∈ DomGL4) (hν : ν ∈ DomGL4)
    (h1 : omega1Eval μ = omega1Eval ν)
    (h2 : omega2Eval μ = omega2Eval ν)
    (h3 : omega3Eval μ = omega3Eval ν)
    (hg12 : gap12 μ = gap12 ν)
    (hg23 : gap23 μ = gap23 ν)
    (hg34 : gap34 μ = gap34 ν) :
    μ = ν
```

Even stronger, and better aligned with tropical support-function reconstruction:
```lean
theorem dominant_extensionality_by_prefix_sums
    {μ ν : Fin 4 → ℤ}
    (h1 : omega1Eval μ = omega1Eval ν)
    (h2 : omega2Eval μ = omega2Eval ν)
    (h3 : omega3Eval μ = omega3Eval ν)
    (h4 : (μ 0 + μ 1 + μ 2 + μ 3) = (ν 0 + ν 1 + ν 2 + ν 3)) :
    μ = ν
```
This theorem is elementary but crucial: it shows that the `A₃` hypersimplex/facet data is information-theoretically sufficient to recover a dominant support point.

#### 2. Finite separating family for dominant support points
Formalize a finite family of tropical linear forms. For example:
```lean
def TestDir := Fin 7
def evalTestDir : TestDir → (Fin 4 → ℤ) → ℤ
| 0 => omega1Eval
| 1 => omega2Eval
| 2 => omega3Eval
| 3 => gap12
| 4 => gap23
| 5 => gap34
| 6 => fun μ => μ 0 + μ 1 + μ 2 + μ 3
```

Then prove separation:
```lean
theorem finite_test_family_separates_dominant
    {μ ν : Fin 4 → ℤ}
    (hμ : μ ∈ DomGL4) (hν : ν ∈ DomGL4) :
    (∀ d : TestDir, evalTestDir d μ = evalTestDir d ν) → μ = ν
```

A more tropical/exposed-face version:
```lean
theorem exists_separating_testdir_of_ne_dominant
    {μ ν : Fin 4 → ℤ}
    (hμ : μ ∈ DomGL4) (hν : ν ∈ DomGL4) (hne : μ ≠ ν) :
    ∃ d : TestDir, evalTestDir d μ ≠ evalTestDir d ν
```

This theorem is the finite-combinatorial replacement for a full polyhedral duality development: it gives the “finite separating family of tropical linear functionals” mentioned in the project description.

#### 3. Reconstruction of a unique maximal exposed support point from test-direction minima/maxima
For a finite support, define extremal values along each test direction:
```lean
def dirMin (F : TropFuncGL4) (d : TestDir) : ℤ :=
  Finset.inf' F.support (by simpa using F.support_nonempty) (evalTestDir d)

def dirMax (F : TropFuncGL4) (d : TestDir) : ℤ :=
  Finset.sup' F.support (by simpa using F.support_nonempty) (evalTestDir d)
```
If your setup does not guarantee nonempty support, use hypotheses `F.support.Nonempty`.

Now formulate the support reconstruction theorem first for a uniquely exposed maximal point:
```lean
def IsTopDominance (μ : Fin 4 → ℤ) (S : Finset (Fin 4 → ℤ)) : Prop :=
  μ ∈ S ∧ ∀ ν ∈ S, μ ≠ ν → ¬ (ν 0 ≥ μ 0 ∧ ν 1 ≥ μ 1 ∧ ν 2 ≥ μ 2 ∧ ν 3 ≥ μ 3)

theorem unique_exposed_support_from_test_data
    (S : Finset (Fin 4 → ℤ))
    (hdom : ∀ μ ∈ S, μ ∈ DomGL4)
    {μ : Fin 4 → ℤ}
    (hμ : μ ∈ S)
    (hexpose :
      ∀ ν ∈ S, ν ≠ μ →
        ∃ d : TestDir, evalTestDir d μ > evalTestDir d ν) :
    ∀ ν ∈ S,
      (∀ d : TestDir, evalTestDir d ν = evalTestDir d μ) → ν = μ
```
This is the exact combinatorial content of “strict facet exposure determines the extreme dominant support point”.

A stronger and very usable finite-support statement:
```lean
theorem support_point_determined_by_test_values
    {S : Finset (Fin 4 → ℤ)}
    (hdom : ∀ μ ∈ S, μ ∈ DomGL4)
    {μ ν : Fin 4 → ℤ}
    (hμ : μ ∈ S) (hν : ν ∈ S)
    (hall : ∀ d : TestDir, evalTestDir d μ = evalTestDir d ν) :
    μ = ν
```
This follows directly from `finite_test_family_separates_dominant` and is the cleanest formal theorem for “support reconstruction from facet data”.

#### 4. Peel-off theorem for finitely supported tropical functions
To reach faithfulness, formalize subtraction/removal of a uniquely exposed support point. For a finite-valued function:
```lean
def supportArgmax (F : TropFuncGL4) (d : TestDir) : Finset (Fin 4 → ℤ) :=
  F.support.filter (fun μ => evalTestDir d μ = dirMax F d)
```
Then prove a uniqueness criterion:
```lean
theorem singleton_argmax_of_strict_exposure
    (F : TropFuncGL4) {μ : Fin 4 → ℤ} (hμ : μ ∈ F.support)
    (hexpose :
      ∃ d : TestDir, ∀ ν ∈ F.support, ν ≠ μ → evalTestDir d ν < evalTestDir d μ) :
    ∃ d : TestDir, supportArgmax F d = {μ}
```
This is the exact “strict facet exposure” mechanism needed for induction on support size.

Then define support erasure:
```lean
def eraseSupport (F : TropFuncGL4) (μ : Fin 4 → ℤ) : TropFuncGL4 := ...
```
and prove the induction step:
```lean
theorem reconstruction_induction_step
    (F G : TropFuncGL4)
    (hTS : ∀ d : TestDir, dirMax F d = dirMax G d)
    {μ : Fin 4 → ℤ}
    (hμF : μ ∈ F.support)
    (hexposeF :
      ∃ d : TestDir, ∀ ν ∈ F.support, ν ≠ μ → evalTestDir d ν < evalTestDir d μ) :
    ∃ μ' : Fin 4 → ℤ,
      μ' ∈ G.support ∧
      (∀ d : TestDir, evalTestDir d μ' = evalTestDir d μ)
```
After this, use separation to conclude `μ' = μ`, hence `μ ∈ G.support`, then erase and recurse.

#### 5. Dominant-support faithfulness from equality of tropical transform data
State the final theorem at the level of the extracted tropical test data. This is the formally tractable version of “if two dominant Hecke-side functions have the same tropical Satake transform, then they are equal”:

```lean
def sameTropicalSatakeData (F G : TropFuncGL4) : Prop :=
  ∀ d : TestDir, dirMax F d = dirMax G d
```
or with `dirMin`, depending on your min-plus normalization.

Then prove support faithfulness:
```lean
theorem tropical_support_faithful_GL4
    (F G : TropFuncGL4)
    (hTS : sameTropicalSatakeData F G) :
    F.support = G.support
```

If coefficients are part of the transform and not just support, strengthen to:
```lean
theorem tropical_Satake_faithful_GL4
    (F G : TropFuncGL4)
    (hTS_support : ∀ d : TestDir, dirMax F d = dirMax G d)
    (hTS_coeff :
      ∀ μ, μ ∈ F.support ∪ G.support →
        F.val μ = G.val μ) :
    F = G
```
But the more interesting theorem is to recover coefficients recursively from the tropical transform itself. For that, define a weighted tropical transform:
```lean
def tropEval (F : TropFuncGL4) (d : TestDir) : ℝ :=
  (F.support.sup' ... (fun μ => F.val μ + (evalTestDir d μ : ℝ)))
```
or the min-plus analogue
```lean
def tropEvalMin (F : TropFuncGL4) (d : TestDir) : ℝ :=
  (F.support.inf' ... (fun μ => F.val μ + (evalTestDir d μ : ℝ)))
```
Then the full coefficient-level faithfulness theorem should be:

```lean
theorem tropical_Satake_convolution_faithful_GL4
    (F G : TropFuncGL4)
    (hTS : ∀ d : TestDir, tropEvalMin F d = tropEvalMin G d) :
    F = G
```

If this full statement is too ambitious in one pass, prove the support-only theorem first, then the coefficient recovery theorem under a genericity hypothesis:
```lean
theorem tropical_Satake_faithful_GL4_generic
    (F G : TropFuncGL4)
    (hgenF : ∀ μ ∈ F.support, ∃ d : TestDir, ∀ ν ∈ F.support, ν ≠ μ →
      F.val μ + (evalTestDir d μ : ℝ) < F.val ν + (evalTestDir d ν : ℝ))
    (hgenG : analogous ...)
    (hTS : ∀ d : TestDir, tropEvalMin F d = tropEvalMin G d) :
    F = G
```

### Concrete proof strategy

1. **Encode dominant coweights by prefix sums/gaps and prove injectivity.**  
   Show that the data
   `μ₁`, `μ₁+μ₂`, `μ₁+μ₂+μ₃`, `μ₁+μ₂+μ₃+μ₄`
   determines all coordinates by subtraction. In Lean, this is a direct `funext` argument on `Fin 4`, splitting cases with `fin_cases`. This gives the algebraic core behind hypersimplex-facet reconstruction.

2. **Build the finite separating family of tropical linear forms.**  
   Use `omega1Eval`, `omega2Eval`, `omega3Eval`, the three adjacent gaps, and optionally total sum. Prove that if two dominant coweights agree on all of them, then they are equal. This is the formal substitute for a more elaborate polyhedral statement that codimension-1 hypersimplex facets plus adjacent root directions expose vertices of the dominant Newton polytope.

3. **Show strict exposure yields singleton argmax/argmin sets.**  
   For a support point `μ`, if there is a test direction `d` with strict inequality against all other support points, then the extremizer set along `d` is exactly `{μ}`. This is a clean `Finset.ext` proof using `Finset.mem_filter` and order reasoning on integers/reals. This is the “peeling” lemma.

4. **Induct on support cardinality.**  
   Given equality of tropical transform data for `F` and `G`, choose a maximal/exposed support point `μ` of `F`; use the corresponding extremal equality to show `G` has some `μ'` with the same test values; invoke separation to conclude `μ'=μ`. Remove `μ` from both supports and recurse on smaller support. Use `Finset.card_erase_lt_of_mem` for the measure decrease.

5. **Upgrade support reconstruction to function equality.**  
   Once support equality is known, recover coefficients either:
   - directly from weighted tropical evaluations under generic exposure hypotheses, or
   - by an additional induction selecting a uniquely minimizing support point for the weighted affine forms.  
   The key idea is that once a support point is isolated by one test direction, the tropical transform value on that direction reads off its coefficient.

### Key local lemmas likely needed in Lean
These are good intermediate targets and should be stated explicitly.

```lean
theorem fin4_funext :
    ∀ {f g : Fin 4 → ℤ}, (∀ i, f i = g i) → f = g
```

```lean
theorem dominant_coordinate_recovery
    {μ : Fin 4 → ℤ} :
    μ 1 = omega2Eval μ - omega1Eval μ ∧
    μ 2 = omega3Eval μ - omega2Eval μ ∧
    μ 3 = (μ 0 + μ 1 + μ 2 + μ 3) - omega3Eval μ
```

```lean
theorem mem_supportArgmax_iff
    (F : TropFuncGL4) (d : TestDir) (μ : Fin 4 → ℤ) :
    μ ∈ supportArgmax F d ↔ μ ∈ F.support ∧ evalTestDir d μ = dirMax F d
```

```lean
theorem eraseSupport_card_lt
    (F : TropFuncGL4) {μ : Fin 4 → ℤ} (hμ : μ ∈ F.support) :
    (eraseSupport F μ).support.card < F.support.card
```

```lean
theorem equal_extremal_data_gives_equal_singleton_exposed_point
    (F G : TropFuncGL4) (hTS : sameTropicalSatakeData F G)
    {μ : Fin 4 → ℤ}
    (hμ : μ ∈ F.support)
    (hexpose :
      ∃ d : TestDir, ∀ ν ∈ F.support, ν ≠ μ → evalTestDir d ν < evalTestDir d μ) :
    μ ∈ G.support
```

### Why this matters
This is the first genuinely higher-rank case where the tropical Satake transform is shown to be **faithful on the dominant chamber** by a finite polyhedral reconstruction argument rather than brute-force rank-2 identities. The `GL₄` case is the natural stress test for whether the tropical Satake program scales beyond `A₂`: the geometry is no longer linearly ordered, and the hypersimplex/permuthedral facets begin to interact in a truly higher-rank way. A successful formalization here would isolate the exact combinatorial mechanism—finite separation by fundamental-weight and adjacent-root test directions, plus strict facet exposure and peel-off induction—that should generalize to `GLₙ`. In particular, proving support reconstruction and dominant-chamber faithfulness for `GL₄` would provide the first robust template for tropical Langlands injectivity arguments in higher rank, while staying within concrete finite `Finset`/`ℤ`/`ℝ` combinatorics that are realistic in Lean 4.

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
