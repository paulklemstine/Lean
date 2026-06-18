## Research Task: GL₃ tropical Satake separation by mixed rank-1/rank-2 Levi test family on bounded dominant support

Research Mode: PROVE

Work in a new file
`Tropical/Langlands/GL3SatakeMixedLeviSeparation.lean`.

The target is a genuinely new finite-test injectivity theorem for the GL₃ tropical Satake package: on a bounded dominant region, a finitely supported coefficient function should be recoverable from a reduced mixed family of tropical Hecke test functionals consisting of

1. rank-1 edge probes along the two simple-coroot directions,
2. rank-2 Levi profile moments for the two adjacent maximal parabolics,
3. optionally one top-weight normalization functional.

The point is not merely to restate a previously established full injectivity theorem with a finite-support hypothesis, but to prove that a strictly smaller, geometrically meaningful family of tests already separates bounded dominant-support functions.

### Concrete setup to formalize

Use the standard dominant chamber model for GL₃ coweights encoded as pairs `(a,b) : ℕ × ℕ`, corresponding to the dominant weight
`a * ω₁ + b * ω₂`.
This avoids unnecessary dependence on a full root datum API and makes the triangular induction transparent.

Represent finitely supported functions as `α → ℤ` or `α → ℝ` with finite support, where
`α := ℕ × ℕ`.
For exact separation, `ℤ` is preferable if existing convolution functionals are integer-valued; if current infrastructure is in `ℝ`, use `ℝ` and state extensional equality there.

A good bounded-support predicate is a rectangular dominant truncation:
```lean
def DomRect (N : ℕ) : Finset (ℕ × ℕ) :=
  (Finset.range (N+1)).product (Finset.range (N+1))

def SupportedInRect (N : ℕ) (f : (ℕ × ℕ) → ℤ) : Prop :=
  ∀ p, f p ≠ 0 → p ∈ DomRect N
```
If the existing support API is based on `Finsupp`, adapt this to
```lean
def SupportedInRectFinsupp (N : ℕ) (f : (ℕ × ℕ) →₀ ℤ) : Prop :=
  ∀ p ∈ f.support, p.1 ≤ N ∧ p.2 ≤ N
```

### Suggested test functionals

You should define explicit “edge sums” and “Levi profile sums” that model the intended tropical Hecke probes but are still Lean-manageable.

A minimal workable family is:

```lean
def edge1 (f : (ℕ × ℕ) →₀ ℤ) (i : ℕ) : ℤ :=
  ∑ b in Finset.range (i+1), f (i, b)

def edge2 (f : (ℕ × ℕ) →₀ ℤ) (j : ℕ) : ℤ :=
  ∑ a in Finset.range (j+1), f (a, j)
```

These are “prefix edge” observables; they detect cumulative mass along the vertical/horizontal dominant directions and are often easier to triangularize than single-point evaluations.

For rank-2 Levi profile tests, define anti-diagonal or facet moments:
```lean
def levi12 (f : (ℕ × ℕ) →₀ ℤ) (s : ℕ) : ℤ :=
  ∑ x in (Finset.range (s+1)), f (x, s - x)

def levi23 (f : (ℕ × ℕ) →₀ ℤ) (t : ℕ) : ℤ :=
  ∑ x in (Finset.range (t+1)), f (t - x, x)
```
Since on `(ℕ × ℕ)` these are formally the same profile under variable swap, it is acceptable to use one anti-diagonal family together with the two edge families; however, for the Satake interpretation it is better to keep two named families corresponding to the two maximal parabolics, even if one is definitionally a reindexing of the other.

If needed, add a top-layer normalization:
```lean
def topMass (f : (ℕ × ℕ) →₀ ℤ) (N : ℕ) : ℤ :=
  ∑ p in f.support.filter (fun p => p.1 + p.2 = N), f p
```
But ideally prove it is unnecessary once the edge and Levi data are available.

### Main theorem: exact finite-test separation on bounded support

A precise theorem statement worth targeting is:

```lean
theorem mixed_test_injective_rect
    (N : ℕ)
    (f g : (ℕ × ℕ) →₀ ℤ)
    (hf : SupportedInRectFinsupp N f)
    (hg : SupportedInRectFinsupp N g)
    (hedge1 : ∀ i ≤ N, edge1 f i = edge1 g i)
    (hedge2 : ∀ j ≤ N, edge2 f j = edge2 g j)
    (hlevi12 : ∀ s ≤ 2 * N, levi12 f s = levi12 g s)
    (hlevi23 : ∀ s ≤ 2 * N, levi23 f s = levi23 g s) :
    f = g
```

A sharper version, closer to the “minimal separating family” goal, is to prove one of the Levi families redundant:

```lean
theorem mixed_test_injective_rect_minimal
    (N : ℕ)
    (f g : (ℕ × ℕ) →₀ ℤ)
    (hf : SupportedInRectFinsupp N f)
    (hg : SupportedInRectFinsupp N g)
    (hedge1 : ∀ i ≤ N, edge1 f i = edge1 g i)
    (hedge2 : ∀ j ≤ N, edge2 f j = edge2 g j)
    (hlevi : ∀ s ≤ 2 * N, levi12 f s = levi12 g s) :
    f = g
```

If the fully minimal statement is too strong, first establish the four-family version and then derive a redundancy corollary under an additional symmetry hypothesis:
```lean
theorem mixed_test_injective_rect_minimal_symm
    (N : ℕ)
    (f g : (ℕ × ℕ) →₀ ℤ)
    ...
    (hsymm_f : ∀ a b, f (a,b) = f (b,a))
    (hsymm_g : ∀ a b, g (a,b) = g (b,a))
    (hedge1 ...)
    (hedge2 ...)
    (hlevi12 ...) :
    f = g
```

### Stronger layer-by-layer reconstruction statement

The cleanest route is often to prove a reconstruction theorem for the difference `h := f - g`. Formulate a vanishing theorem:

```lean
theorem mixed_tests_zero_implies_zero
    (N : ℕ)
    (h : (ℕ × ℕ) →₀ ℤ)
    (hh : SupportedInRectFinsupp N h)
    (hedge1 : ∀ i ≤ N, edge1 h i = 0)
    (hedge2 : ∀ j ≤ N, edge2 h j = 0)
    (hlevi12 : ∀ s ≤ 2 * N, levi12 h s = 0)
    (hlevi23 : ∀ s ≤ 2 * N, levi23 h s = 0) :
    h = 0
```

Then derive injectivity by applying this to `f - g`.

This formulation is often easier in Lean because:
- the proof becomes extensional on coefficients,
- sums become linear,
- existing lemmas about `Finsupp.sub_apply`, `by_cases hmem : p ∈ support`, and `ext` work naturally.

### Recommended proof strategy

The key mathematical insight should be a triangular reconstruction on the dominant poset, ordered by total degree `a+b` and then refined by one coordinate.

A robust 4-step proof plan is:

1. **Pass to the difference and isolate top total degree.**  
   Let `h = f - g`. Assume all mixed tests vanish. Suppose `h ≠ 0`. Since support is bounded in `[0,N]²`, there exists a maximal `s ≤ 2N` such that some coefficient on the anti-diagonal `a+b=s` is nonzero. Use finite support to choose this maximal layer.

   Lean lemmas you will likely need:
   - existence of a maximal element in `h.support.image (fun p => p.1 + p.2)`,
   - `Finset.exists_max_image` or a custom max-degree lemma on finite sets,
   - `Finsupp.support_finite`.

2. **Use Levi profile vanishing to constrain the top layer.**  
   Since `levi12 h s = 0`, the sum of coefficients on the maximal anti-diagonal vanishes. On its own this does not force each coefficient to vanish, but it reduces the top layer ambiguity to codimension one.

   Prove an auxiliary lemma:
   ```lean
   lemma levi_layer_eq_sum
       (h : (ℕ × ℕ) →₀ ℤ) (s : ℕ) :
       levi12 h s =
         ∑ a in Finset.range (s+1), h (a, s-a)
   ```
   and, under support bounded by `N`, terms with `a > N` or `s-a > N` vanish automatically.

3. **Use edge probes to kill extremal coefficients on that layer, then peel inward.**  
   On the maximal layer `a+b=s`, the quantities `edge1 a` and `edge2 b` detect cumulative contributions from points with first or second coordinate fixed at the boundary of the remaining support. Because all higher layers vanish by maximality, these edge sums become triangular equations for the extremal points `(s,0)`, `(s-1,1)`, … intersected with the rectangle.

   The intended induction is inward along the layer:
   - show the outermost admissible point on the layer must have coefficient zero from an edge equation,
   - subtract it from the Levi sum to move to the next point,
   - continue until the whole layer vanishes,
   - contradict maximality.

   You may find it cleaner to prove a stronger “south-east corner elimination” lemma:
   ```lean
   lemma coeff_eq_zero_of_top_layer_and_edge
       (h : (ℕ × ℕ) →₀ ℤ) (N a b : ℕ)
       (hh : SupportedInRectFinsupp N h)
       (htop : ∀ p ∈ h.support, p.1 + p.2 ≤ a + b)
       (hedge1 : edge1 h a = 0)
       (hcorner : ∀ b' < b, h (a, b') = 0) :
       h (a,b) = 0
   ```
   and the analogous statement with coordinates swapped.

4. **Induct on total degree bound or support cardinality.**  
   After proving the maximal layer is zero, restrict to degree `< s` and iterate. This gives `h = 0`.

   Two induction schemes are plausible:
   - induction on `M = max {a+b | (a,b) ∈ support h}` with base case `M=0`,
   - induction on `h.support.card`, removing one forced-zero coefficient at a time.

   Degree induction is conceptually closer to the Satake filtration and should produce the cleanest theorem.

### Important intermediate lemmas to isolate

These are worth proving as named lemmas before the main theorem.

1. **Support boundedness kills out-of-rectangle coefficients**
```lean
lemma supportedInRect_apply_eq_zero
    {N : ℕ} {f : (ℕ × ℕ) →₀ ℤ}
    (hf : SupportedInRectFinsupp N f) {a b : ℕ}
    (ha : N < a ∨ N < b) :
    f (a,b) = 0
```

2. **Difference preserves bounded support**
```lean
lemma SupportedInRectFinsupp.sub
    {N : ℕ} {f g : (ℕ × ℕ) →₀ ℤ}
    (hf : SupportedInRectFinsupp N f)
    (hg : SupportedInRectFinsupp N g) :
    SupportedInRectFinsupp N (f - g)
```

3. **Vanishing of all coefficients from vanishing on each degree layer**
```lean
lemma finsupp_eq_zero_of_degree_layers_zero
    (h : (ℕ × ℕ) →₀ ℤ)
    (hzero : ∀ s, ∀ a ≤ s, h (a, s-a) = 0) :
    h = 0
```

4. **Top-layer elimination lemma**
```lean
lemma top_degree_layer_zero
    (N s : ℕ)
    (h : (ℕ × ℕ) →₀ ℤ)
    (hh : SupportedInRectFinsupp N h)
    (hmax : ∀ p ∈ h.support, p.1 + p.2 ≤ s)
    (hedge1 : ∀ i ≤ N, edge1 h i = 0)
    (hedge2 : ∀ j ≤ N, edge2 h j = 0)
    (hlevi12 : levi12 h s = 0)
    (hlevi23 : levi23 h s = 0) :
    ∀ a ≤ s, h (a, s-a) = 0
```

The main theorem then becomes a short induction using `top_degree_layer_zero`.

### Lean-specific implementation advice

- Prefer `Finsupp` over raw functions plus support predicates. The extensional conclusion `f = g` is easier via `ext p`.
- Use `classical` locally for finite support maxima and decidable equality on pairs.
- When summing over anti-diagonals, guard terms outside the support rectangle using `supportedInRect_apply_eq_zero`; this avoids awkward dependent finite sets.
- For equalities of sums, expect to use:
  - `Finset.sum_congr`,
  - `Finset.mem_range`,
  - `Nat.lt_succ_iff`,
  - `omega` or `linarith` where arithmetic is linear,
  - `by_cases hax : a ≤ N`.
- If subtraction on `ℤ` complicates support lemmas, prove zero theorems coefficientwise and use `sub_eq_zero.mp`.
- A convenient extensional endpoint is:
  ```lean
  ext p
  rcases p with ⟨a,b⟩
  ...
  ```

### Why this matters

This theorem should serve as the bounded-support finite-test separation principle for the GL₃ tropical Satake program. Its significance is threefold:

1. **Minimality of observables.**  
   It replaces a potentially large or redundant family of tropical Hecke probes by a sharply reduced mixed rank-1/rank-2 test family. That is exactly the right notion of “finite determinacy” for computational Satake reconstruction.

2. **Triangular reconstruction in rank 2.**  
   The proof isolates the real geometric mechanism: edge data detects extremal chamber behavior, while Levi profile moments resolve the codimension-1 ambiguity on adjacent facets. This is the rank-2 prototype for higher-rank tropical Satake injectivity.

3. **Bridge to finite-generation and algorithmic reconstruction.**  
   Once proved, the theorem gives a practical recovery algorithm for bounded dominant-support functions from finitely many tropical convolution values. This is the natural theorem needed before attempting a full GL₃ tropical Hecke/Satake equivalence or extending to GL₄.

### Deliverables

Aim to prove at least:

```lean
theorem mixed_tests_zero_implies_zero
    (N : ℕ)
    (h : (ℕ × ℕ) →₀ ℤ)
    (hh : SupportedInRectFinsupp N h)
    (hedge1 : ∀ i ≤ N, edge1 h i = 0)
    (hedge2 : ∀ j ≤ N, edge2 h j = 0)
    (hlevi12 : ∀ s ≤ 2 * N, levi12 h s = 0)
    (hlevi23 : ∀ s ≤ 2 * N, levi23 h s = 0) :
    h = 0
```

and then derive

```lean
theorem mixed_test_injective_rect
    (N : ℕ)
    (f g : (ℕ × ℕ) →₀ ℤ)
    (hf : SupportedInRectFinsupp N f)
    (hg : SupportedInRectFinsupp N g)
    (hedge1 : ∀ i ≤ N, edge1 f i = edge1 g i)
    (hedge2 : ∀ j ≤ N, edge2 f j = edge2 g j)
    (hlevi12 : ∀ s ≤ 2 * N, levi12 f s = levi12 g s)
    (hlevi23 : ∀ s ≤ 2 * N, levi23 f s = levi23 g s) :
    f = g
```

If the full minimal-family theorem is reachable, add:

```lean
theorem mixed_test_injective_rect_minimal
    (N : ℕ)
    (f g : (ℕ × ℕ) →₀ ℤ)
    (hf : SupportedInRectFinsupp N f)
    (hg : SupportedInRectFinsupp N g)
    (hedge1 : ∀ i ≤ N, edge1 f i = edge1 g i)
    (hedge2 : ∀ j ≤ N, edge2 f j = edge2 g j)
    (hlevi12 : ∀ s ≤ 2 * N, levi12 f s = levi12 g s) :
    f = g
```

Even if that final redundancy statement remains partially open, a complete proof of the four-family finite-test injectivity theorem with clean supporting lemmas would already be a substantial and publishable advance.

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
