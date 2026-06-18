## Research Task: Tropical certified robustness for multiclass piecewise-linear networks with softmax-free top-k decision under 1-Lipschitz score aggregation

Research Mode: PROVE

Prove a compositional top-`k` robustness theorem for multiclass score maps `f : Fin C → ℝ` depending on an input `x : Fin d → ℝ`, assuming the same coordinatewise perturbation estimate already established in the tropical robustness line:
```lean
∀ i : Fin C, |f (x + δ) i - f x i| ≤ K * d * ‖δ‖∞
```
or its existing Mathlib-compatible formulation on functions `Fin d → ℝ`. The goal is to upgrade the known top-1 margin certificate to a genuinely set-valued top-`k` certificate.

The key new object is the `k`-th order-statistic gap:
- if `scores : Fin C → ℝ`,
- let `s_(0) ≥ s_(1) ≥ ... ≥ s_(C-1)` be the decreasing rearrangement,
- define the top-`k` margin for `k : ℕ` with `k+1 < C` by
```lean
gap_k(scores, k) = s_(k-1) - s_(k)
```
in 1-based language, or equivalently in Lean’s 0-based indexing,
```lean
gap_k(scores, k) = s_[k] - s_[k+1]
```
for `k < C-1`.

You should formalize the top-`k` decision set in a way that avoids unnecessary tie-breaking complexity. The cleanest route is to define
```lean
TopK (scores : Fin C → ℝ) (k : ℕ) : Finset (Fin C)
```
as any `Finset` of cardinality `k` containing exactly those indices whose score is at least the `k`-th threshold, and then prove uniqueness under a strict gap hypothesis. Alternatively, define it via sorting the finite set of indices by descending score with a deterministic secondary key on the index, and take the first `k` entries. The strict-gap theorem should make the particular convention irrelevant.

### Precise theorem targets

A good main theorem should have a Lean signature close to:
```lean
theorem topk_stable_of_gap_pos
    {d C : ℕ} (hC : 2 ≤ C)
    (k : ℕ) (hk1 : 1 ≤ k) (hkC : k < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K : ℝ) (hK : 0 ≤ K)
    (x δ : Fin d → ℝ)
    (hcoord :
      ∀ i : Fin C, |f (x + δ) i - f x i| ≤ K * d * ‖δ‖∞)
    (hgap :
      topkGap (f x) k > 2 * K * d * ‖δ‖∞) :
    topKSet (f (x + δ)) k = topKSet (f x) k
```
where `topkGap` and `topKSet` are your formal definitions.

A radius/certificate corollary should then be:
```lean
theorem topk_stable_on_closedBall
    {d C : ℕ} (hC : 2 ≤ C)
    (k : ℕ) (hk1 : 1 ≤ k) (hkC : k < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K r : ℝ) (hK : 0 ≤ K) (hr : 0 ≤ r)
    (x : Fin d → ℝ)
    (hcoord :
      ∀ δ : Fin d → ℝ, ‖δ‖∞ ≤ r →
        ∀ i : Fin C, |f (x + δ) i - f x i| ≤ K * d * ‖δ‖∞)
    (hmargin : 2 * K * d * r < topkGap (f x) k) :
    ∀ δ : Fin d → ℝ, ‖δ‖∞ ≤ r →
      topKSet (f (x + δ)) k = topKSet (f x) k
```

And the explicit margin certificate in the style requested:
```lean
theorem topk_certified_radius
    {d C : ℕ} (hC : 2 ≤ C)
    (k : ℕ) (hk1 : 1 ≤ k) (hkC : k < C)
    (f : (Fin d → ℝ) → Fin C → ℝ)
    (K : ℝ) (hK : 0 ≤ K)
    (x : Fin d → ℝ)
    (hcoord :
      ∀ δ : Fin d → ℝ,
        ∀ i : Fin C, |f (x + δ) i - f x i| ≤ K * d * ‖δ‖∞) :
    ∀ δ : Fin d → ℝ,
      ‖δ‖∞ < topkGap (f x) k / (2 * K * d) →
      topKSet (f (x + δ)) k = topKSet (f x) k
```
with the usual nondegeneracy side conditions if division by `2 * K * d` is awkward. It is perfectly acceptable to state the usable theorem in the multiplicative form
```lean
2 * K * d * ‖δ‖∞ < topkGap (f x) k
```
and derive the quotient form only under positivity assumptions on `K` and `d`.

### Stronger compositional theorem with score aggregation

Formalize a final aggregation layer
```lean
A : (Fin m → ℝ) → Fin C → ℝ
```
satisfying a coordinatewise sup-norm Lipschitz estimate
```lean
∀ z z', ∀ i : Fin C, |A z i - A z' i| ≤ ‖z - z'‖∞
```
or a stronger global form
```lean
∀ z z', ‖A z - A z'‖∞ ≤ ‖z - z'‖∞
```
together with whatever monotonicity hypothesis is natural for your tropical framework:
```lean
∀ z z', (∀ j, z j ≤ z' j) → ∀ i, A z i ≤ A z' i
```
Then show that if `h : (Fin d → ℝ) → Fin m → ℝ` satisfies the established coordinatewise robustness bound with constant `K * d`, so does `A ∘ h`, and therefore the same top-`k` certificate applies to `A ∘ h`.

A suitable compositional statement is:
```lean
theorem topk_stable_comp_agg
    {d m C : ℕ} (hC : 2 ≤ C)
    (k : ℕ) (hk1 : 1 ≤ k) (hkC : k < C)
    (h : (Fin d → ℝ) → Fin m → ℝ)
    (A : (Fin m → ℝ) → Fin C → ℝ)
    (K : ℝ) (hK : 0 ≤ K)
    (x δ : Fin d → ℝ)
    (hh :
      ∀ j : Fin m, |h (x + δ) j - h x j| ≤ K * d * ‖δ‖∞)
    (hA :
      ∀ z z' : Fin m → ℝ, ∀ i : Fin C,
        |A z i - A z' i| ≤ ‖z - z'‖∞)
    (hgap :
      topkGap (A (h x)) k > 2 * K * d * ‖δ‖∞) :
    topKSet (A (h (x + δ))) k = topKSet (A (h x)) k
```
The proof should first show
```lean
∀ i, |A (h (x + δ)) i - A (h x) i| ≤ K * d * ‖δ‖∞
```
by bounding `‖h (x + δ) - h x‖∞` using the coordinatewise estimate on `h`.

### Key intermediate lemmas to prove first

1. **Order-statistic lower bound under coordinate perturbation**
```lean
theorem topkGap_sub_le_topkGap_add_perturb
    {C : ℕ} (hC : 2 ≤ C)
    (k : ℕ) (hk1 : 1 ≤ k) (hkC : k < C)
    (s t : Fin C → ℝ)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hpert : ∀ i : Fin C, |t i - s i| ≤ ε) :
    topkGap t k ≥ topkGap s k - 2 * ε
```
This is the central quantitative lemma. It expresses that the gap between the `k`-th and `(k+1)`-st largest coordinates can shrink by at most `2ε`.

A more elementary pair of inequalities may be easier to prove first:
```lean
theorem kthLargest_ge_kthLargest_sub_eps ...
theorem kthLargest_le_kthLargest_add_eps ...
```
namely:
- the `k`-th largest value of `t` is at least the `k`-th largest value of `s` minus `ε`,
- the `(k+1)`-st largest value of `t` is at most the `(k+1)`-st largest value of `s` plus `ε`.

2. **Positive gap implies uniqueness of the top-`k` set**
```lean
theorem topKSet_unique_of_gap_pos
    {C : ℕ} (hC : 2 ≤ C)
    (k : ℕ) (hk1 : 1 ≤ k) (hkC : k < C)
    (s : Fin C → ℝ)
    (hgap : topkGap s k > 0) :
    ∃! S : Finset (Fin C),
      S.card = k ∧
      (∀ i ∈ S, ∀ j ∉ S, s j < s i)
```
This lets you avoid low-level arguments about arbitrary tie-breaking: once the gap is positive, the top-`k` set is characterized intrinsically.

3. **Set equality from preserved separation**
```lean
theorem topKSet_eq_of_cross_inequalities
    {C : ℕ} (k : ℕ) (s t : Fin C → ℝ)
    (S : Finset (Fin C))
    (hS : S.card = k)
    (hs : ∀ i ∈ S, ∀ j ∉ S, s j < s i)
    (ht : ∀ i ∈ S, ∀ j ∉ S, t j < t i) :
    topKSet s k = S ∧ topKSet t k = S
```
For the main theorem, it is enough to show that every `i` originally in the top-`k` still dominates every `j` originally outside by a positive amount after perturbation:
```lean
t i - t j ≥ (s i - s j) - 2ε
```
and then use the strict original margin.

4. **Composition preserves the coordinatewise perturbation constant**
```lean
theorem coord_lipschitz_comp_preserves_bound
    {d m C : ℕ}
    (h : (Fin d → ℝ) → Fin m → ℝ)
    (A : (Fin m → ℝ) → Fin C → ℝ)
    (K : ℝ) (x δ : Fin d → ℝ)
    (hh : ∀ j : Fin m, |h (x + δ) j - h x j| ≤ K * d * ‖δ‖∞)
    (hA : ∀ z z', ∀ i : Fin C, |A z i - A z' i| ≤ ‖z - z'‖∞) :
    ∀ i : Fin C, |A (h (x + δ)) i - A (h x) i| ≤ K * d * ‖δ‖∞
```
Use the sup-norm estimate
```lean
‖h (x + δ) - h x‖∞ ≤ K * d * ‖δ‖∞
```
derived from the coordinatewise bound.

### Concrete proof strategy

1. **Choose a finite-order-statistics formalization that works smoothly in Lean.**  
   The most robust route is to convert `s : Fin C → ℝ` to the list
   ```lean
   ((Finset.univ : Finset (Fin C)).sort (fun i j => s j ≤ s i))
   ```
   or to a multiset/image and then use `List.get` / `Fin` indexing on the descending sort. Define:
   ```lean
   def sortedScores (s : Fin C → ℝ) : List ℝ := ...
   def kthLargest (s : Fin C → ℝ) (k : Fin C) : ℝ := ...
   def topkGap (s : Fin C → ℝ) (k : ℕ) : ℝ := kthLargest s ⟨k-1,...⟩ - kthLargest s ⟨k,...⟩
   ```
   If sorting values directly is simpler than sorting indices, do that for the gap lemma, and separately define `topKSet` on indices for the final stability theorem.

2. **Prove the order-statistic perturbation lemma via counting/sublevel arguments.**  
   If `|t i - s i| ≤ ε` for all `i`, then for every threshold `a`,
   ```lean
   {i | s i ≥ a} ⊆ {i | t i ≥ a - ε}
   ```
   and similarly
   ```lean
   {i | t i ≥ a} ⊆ {i | s i ≥ a - ε}.
   ```
   This transfers cardinality statements defining the `k`-th largest coordinate. From this derive:
   - `kthLargest t k ≥ kthLargest s k - ε`
   - `kthLargest t (k+1) ≤ kthLargest s (k+1) + ε`
   and subtract to obtain
   ```lean
   topkGap t k ≥ topkGap s k - 2 * ε.
   ```

3. **Derive strict separation of inside/outside indices from a positive gap.**  
   Show that if `topkGap s k > 0`, then for every `i` in `topKSet s k` and every `j` outside,
   ```lean
   s i - s j ≥ topkGap s k > 0.
   ```
   This is the exact bridge from the order-statistic statement to set stability. After perturbation with coordinatewise error `ε = K * d * ‖δ‖∞`,
   ```lean
   t i - t j ≥ (s i - s j) - 2 * ε.
   ```
   Under `2 * ε < topkGap s k`, the right-hand side remains positive, so every original inside index still beats every original outside index.

4. **Conclude top-`k` set invariance by cardinality and pairwise domination.**  
   Once all original inside indices still dominate all original outside indices, the same `Finset` must be the unique top-`k` set for the perturbed scores. This avoids any need to compare the exact `k`-th threshold after perturbation.

5. **Lift the theorem through a 1-Lipschitz aggregation layer.**  
   Prove the sup-norm bound on `A ∘ h` first. Then the top-`k` theorem applies verbatim. For concrete aggregators, derive reusable lemmas:
   - coordinate projection is 1-Lipschitz,
   - coordinatewise max over a finite family is 1-Lipschitz in `‖·‖∞`,
   - coordinatewise min is 1-Lipschitz,
   - arithmetic mean is 1-Lipschitz in `‖·‖∞`.
   These lemmas will make the compositional theorem immediately applicable to max-pooling, average-pooling, and max-affine fusion architectures.

### Significance

This theorem is the right next step in the tropical certified-robustness program because it replaces scalar argmax certification by certification of a structured decision set. In applications, top-`k` prediction is often the operational object, and many modern architectures end with pooling or score-fusion layers rather than a bare linear classifier. A formal theorem showing that a strict `k`/`k+1` score gap survives all perturbations inside an explicit `L∞` ball extends the existing multiclass robustness line in a genuinely nontrivial way.

Mathematically, the important novelty is that the certification target is no longer a single winning class but an order-statistic stratum of the score vector. The core lemma that the top-`k` gap degrades by at most `2ε` under coordinatewise perturbation is the finite-dimensional order-statistics fact needed to make tropical robustness compositional. Once formalized, it should also support later work on:
- robust ranking / retrieval guarantees,
- certified beam-search or shortlist preservation,
- robustness of pooled or attention-style score fusion,
- tropical analogues of margin-based structured prediction bounds.

A strong deliverable would therefore be:
1. a clean formalization of `k`-th largest score and `topKSet`,
2. the `gap shrinks by at most 2ε` lemma,
3. the main top-`k` invariance theorem,
4. the compositional corollary for 1-Lipschitz aggregators,
5. concrete corollaries for max-pooling, min-pooling, averaging, and projections.

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
