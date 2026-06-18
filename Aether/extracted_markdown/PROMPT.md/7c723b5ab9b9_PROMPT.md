## Research Task: Tropical certified robustness for multiclass piecewise-linear networks under top-k decision via order-statistic gaps

Research Mode: PROVE

Develop a formal top-`k` robustness theory for multiclass score maps `f : α → Fin n → ℝ` on a metric input space, with statements phrased so they are usable both for abstract Lipschitz maps and for tropical / max-affine networks already present in the library.

The central point is to avoid sorting machinery as much as possible: define the top-`k` set at `x` by pairwise comparison against all outside classes, and certify its stability from a positive gap. This is the right formulation for Lean because it reduces order-statistics to finite quantification over `Fin n`.

### Core definitions to introduce

Work with:
```lean
variable {α : Type*} [PseudoMetricSpace α]
variable {n : ℕ}
```

Define the score gap between two classes:
```lean
def scoreGap (f : α → Fin n → ℝ) (x : α) (i j : Fin n) : ℝ :=
  f x i - f x j
```

Define the “all classes in `S` dominate all classes outside `S`” margin:
```lean
def topkMargin (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : ℝ :=
  sInf {r : ℝ | ∃ i ∈ S, ∃ j : Fin n, j ∉ S ∧ r = scoreGap f x i j}
```
This `sInf` version is mathematically natural but awkward in Lean. A more practical formalization is to use `Finset.inf'` over a nonempty finite set of gaps. Since `S × Sᶜ` may be empty in degenerate cases (`S = ∅` or `S = univ`), state theorems under hypotheses `S.Nonempty` and `∃ j, j ∉ S`. A convenient implementation is:
```lean
def crossGaps (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Finset ℝ :=
  (S.product (Finset.univ.filter fun j => j ∉ S)).image
    (fun p => scoreGap f x p.1 p.2)

def topkMargin' (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n))
    (hS : S.Nonempty) (hSc : (Finset.univ.filter fun j => j ∉ S).Nonempty) : ℝ :=
  (crossGaps f x S).inf' (by
    rcases hS with ⟨i, hi⟩
    rcases hSc with ⟨j, hj⟩
    refine ⟨scoreGap f x i j, ?_⟩
    simp [crossGaps, hi, hj])
```

Define top-`k` realization of a set:
```lean
def IsTopKSet (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → f x j ≤ f x i
```

For the strict version needed for stability:
```lean
def StrictTopKSet (f : α → Fin n → ℝ) (x : α) (S : Finset (Fin n)) : Prop :=
  ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → f x j < f x i
```

This bypasses having to formalize the `k`-th and `(k+1)`-st sorted coordinates immediately. Once the set-stability theorem is done, you can derive an order-statistic corollary when `S.card = k`.

### Main theorem 1: uniform coordinate-Lipschitz top-k certification

A clean theorem that should be straightforward to reuse is:

```lean
theorem topk_stable_of_coordinate_lipschitz
    {f : α → Fin n → ℝ} {K : ℝ} (hK : 0 ≤ K)
    (hLip : ∀ i : Fin n, LipschitzWith K fun x => f x i)
    {x y : α} {S : Finset (Fin n)}
    (hS : S.Nonempty)
    (hSc : (Finset.univ.filter fun j => j ∉ S).Nonempty)
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → 2 * K * dist x y < f x i - f x j) :
    StrictTopKSet f y S
```

A more user-friendly radius form:
```lean
theorem topk_stable_on_ball_of_coordinate_lipschitz
    {f : α → Fin n → ℝ} {K r : ℝ} (hK : 0 ≤ K)
    (hLip : ∀ i : Fin n, LipschitzWith K fun x => f x i)
    {x : α} {S : Finset (Fin n)}
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → 2 * K * r < f x i - f x j) :
    ∀ ⦃y : α⦄, dist x y ≤ r → StrictTopKSet f y S
```

And the margin-packaged version:
```lean
theorem topk_stable_of_margin
    {f : α → Fin n → ℝ} {K r : ℝ} (hK : 0 ≤ K)
    (hLip : ∀ i : Fin n, LipschitzWith K fun x => f x i)
    {x : α} {S : Finset (Fin n)}
    (hS : S.Nonempty)
    (hSc : (Finset.univ.filter fun j => j ∉ S).Nonempty)
    (hmargin : 2 * K * r < topkMargin' f x S hS hSc) :
    ∀ ⦃y : α⦄, dist x y ≤ r → StrictTopKSet f y S
```

This is the exact analog of the classical `margin / (2K)` certificate, but for an arbitrary designated top-`k` set `S`.

### Main theorem 2: pairwise-difference Lipschitz certification

The sharper theorem should avoid the factor `2` coming from bounding each coordinate separately when pairwise score differences are directly controlled.

```lean
theorem topk_stable_of_pairwise_lipschitz
    {f : α → Fin n → ℝ} {L : Fin n → Fin n → ℝ}
    (hL : ∀ i j, 0 ≤ L i j)
    (hLip : ∀ i j, LipschitzWith (L i j) fun x => f x i - f x j)
    {x y : α} {S : Finset (Fin n)}
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → L i j * dist x y < f x i - f x j) :
    StrictTopKSet f y S
```

A uniform-max version:
```lean
theorem topk_stable_of_pairwise_lipschitz_max
    {f : α → Fin n → ℝ} {Lmax r : ℝ}
    (hLmax : 0 ≤ Lmax)
    (hLip : ∀ i j : Fin n, LipschitzWith Lmax fun x => f x i - f x j)
    {x : α} {S : Finset (Fin n)}
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → Lmax * r < f x i - f x j) :
    ∀ ⦃y : α⦄, dist x y ≤ r → StrictTopKSet f y S
```

This theorem is genuinely stronger than the coordinate-wise one: if `f_i - f_j` has a small Lipschitz constant due to cancellation in a tropical network, the certificate improves from `margin/(2K)` to `margin/Lij`.

### Main theorem 3: preservation of membership for a target subset inside the initial top-k

This is the more refined “partial preservation” statement and is likely useful for hierarchical readouts.

```lean
theorem subset_of_topk_preserved
    {f : α → Fin n → ℝ} {K r : ℝ} (hK : 0 ≤ K)
    (hLip : ∀ i : Fin n, LipschitzWith K fun x => f x i)
    {x : α} {S T : Finset (Fin n)}
    (hTS : T ⊆ S)
    (hsep : ∀ ⦃i j : Fin n⦄, i ∈ T → j ∉ S → 2 * K * r < f x i - f x j) :
    ∀ ⦃y : α⦄, dist x y ≤ r → ∀ ⦃i j : Fin n⦄, i ∈ T → j ∉ S → f y j < f y i
```

Interpretation: even if the entire top-`k` set may permute internally, any class in `T` cannot drop below any class that started outside `S`, provided the corresponding margin budget is positive. This is the right theorem for “safe inclusion” guarantees.

### Main theorem 4: order-statistic corollary

Once the set-based result is available, derive a statement closer to the informal specification. Avoid formal sorting unless necessary; one acceptable route is:

- assume `S.card = k`,
- assume `StrictTopKSet f x S`,
- conclude that `S` is the unique top-`k` set at `x`,
- then use the stability theorem to show it remains the top-`k` set at `y`.

A suitable theorem signature is:

```lean
theorem topk_cardinal_stability
    {f : α → Fin n → ℝ} {K r : ℝ} {k : ℕ}
    (hK : 0 ≤ K)
    (hkn : k ≤ n)
    (hLip : ∀ i : Fin n, LipschitzWith K fun x => f x i)
    {x : α} {S : Finset (Fin n)}
    (hcard : S.card = k)
    (hstrict : ∀ ⦃i j : Fin n⦄, i ∈ S → j ∉ S → 2 * K * r < f x i - f x j) :
    ∀ ⦃y : α⦄, dist x y ≤ r →
      StrictTopKSet f y S ∧ S.card = k
```

If sorting/order-statistics on finite families is already available in your environment, strengthen this to a direct `k`-th gap statement. But the set-based theorem is already the mathematically essential content.

### Tropical / compositional theorem

The next layer should specialize to piecewise-linear/tropical architectures built from affine maps, ReLU, and coordinatewise max-pooling. The target is not to formalize a whole network syntax unless that syntax already exists; instead prove closure lemmas that can be chained.

Useful intermediate lemmas:

```lean
theorem lipschitz_max_two
    {g h : α → ℝ} {K : ℝ}
    (hg : LipschitzWith K g) (hh : LipschitzWith K h) :
    LipschitzWith K (fun x => max (g x) (h x))
```

```lean
theorem lipschitz_finset_sup
    {β : Type*} [Fintype β]
    {g : β → α → ℝ} {K : ℝ}
    (hg : ∀ b, LipschitzWith K (g b)) :
    LipschitzWith K (fun x => Finset.univ.sup fun b => g b x)
```
If `Finset.sup` over `ℝ` causes order issues, use nested `max` or restrict to nonempty finite sets with an explicit fold.

For vector-valued maps:
```lean
theorem coordinate_lipschitz_of_max_affine_coordinate
    {ι : Type*} [Fintype ι]
    {a : ι → α → ℝ} {K : ℝ}
    (ha : ∀ t, LipschitzWith K (a t)) :
    LipschitzWith K (fun x => Finset.univ.sup fun t => a t x)
```

Then formulate a compositional certification theorem abstractly:

```lean
theorem topk_certified_radius_of_coordinate_lipschitz
    {f : α → Fin n → ℝ} {x : α} {S : Finset (Fin n)} {K : ℝ}
    (hK : 0 ≤ K)
    (hLip : ∀ i, LipschitzWith K fun x => f x i)
    (hS : S.Nonempty)
    (hSc : (Finset.univ.filter fun j => j ∉ S).Nonempty) :
    ∀ {r : ℝ}, 0 ≤ r →
      r < topkMargin' f x S hS hSc / (2 * K) →
      ∀ ⦃y : α⦄, dist x y ≤ r → StrictTopKSet f y S
```

Then instantiate this theorem for tropical networks by proving that each output coordinate has the expected Lipschitz constant under the available tropical robustness calculus. If the existing library already has theorems of the form “depth-`d` network is `K*d`-Lipschitz” or similar `r* = margin/(2Kd)` certification, connect directly to them by deriving the coordinate Lipschitz hypotheses needed here.

### Concrete proof strategy

1. **Prove pairwise perturbation inequality.**  
   For coordinate-Lipschitz hypotheses, first show:
   ```lean
   f y i - f y j ≥ (f x i - f x j) - 2 * K * dist x y
   ```
   by combining
   `|f y i - f x i| ≤ K * dist x y` and
   `|f y j - f x j| ≤ K * dist x y`.
   This is the key lemma from which every stability theorem follows.  
   For the sharper variant, prove directly:
   ```lean
   |(f y i - f y j) - (f x i - f x j)| ≤ L i j * dist x y
   ```
   using the pairwise Lipschitz assumption.

2. **Convert strict margin at `x` into strict dominance at `y`.**  
   Fix `i ∈ S`, `j ∉ S`. If
   `2 * K * dist x y < f x i - f x j`,
   then the perturbation lemma yields
   `0 < f y i - f y j`, hence `f y j < f y i`.  
   This establishes `StrictTopKSet f y S` by finite quantification only—no sorting needed.

3. **Package the pointwise inequalities via `Finset.inf'`.**  
   Show that if `a < inf' A`, then `a < z` for every `z ∈ A`. Applied to `A = crossGaps f x S`, this lets one discharge all `(i,j)` obligations from a single hypothesis
   `2 * K * r < topkMargin' f x S hS hSc`.
   Expect to need lemmas about `Finset.mem_image`, `Finset.mem_product`, and `Finset.mem_filter`.

4. **Derive top-`k` cardinal corollaries from strict separation.**  
   Once every member of `S` strictly dominates every outside class, `S` is exactly the top-`k` label set whenever `S.card = k`. Internal ties inside `S` or outside `S` are irrelevant. This is the clean bridge from pairwise separation to order-statistics.

5. **Prove max/ReLU closure for Lipschitz constants.**  
   For `max`, use the elementary inequality
   ```lean
   |max a b - max c d| ≤ max (|a-c|) (|b-d|) ≤ ...
   ```
   or the 1-Lipschitz property of `(u,v) ↦ max u v` in the sup norm.  
   ReLU is just `fun z => max z 0`, so it is 1-Lipschitz immediately.  
   This gives the compositional tropical theorem: max-affine and ReLU nodes do not increase the coordinate Lipschitz constant beyond the expected bound.

### Why this matters

This gives a formally robust replacement for argmax-margin certification in the multiclass setting where the decision rule is top-`k` membership, which is the natural notion in retrieval, shortlist prediction, and hierarchical tropical classifiers. The pairwise-difference version is especially important: tropical/max-affine architectures often admit much sharper control on score differences than on raw coordinates, so this theorem should produce strictly tighter certificates than the generic `margin/(2K)` bound. It also fits the tropical program better than soft aggregation results because top-`k` stability is fundamentally an order-theoretic statement about max-selection and finite comparisons, exactly the kind of structure Lean can handle cleanly with `Finset` and Lipschitz lemmas.

A good endpoint is a file containing:
- abstract set-based top-`k` stability theorems,
- pairwise-difference sharpening,
- subset-preservation theorem,
- closure lemmas for `max` / ReLU / finite max-pooling,
- one final corollary giving a certified radius for tropical piecewise-linear score maps.

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

Research domain: MachineLearning
Research mode: prove
