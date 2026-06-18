## Research Task: GL₃ tropical Satake finite injective test family from simple-coroot edge valuations plus one rank-2 Levi mixed moment

Research Mode: PROVE

Work in a new file
`Tropical/Langlands/GL3FiniteTestFamily.lean`.

The target is a genuine finite-determinacy theorem for bounded-support dominant `GL₃` tropical Hecke data: on a bounded dominant region, the full tropical Satake transform should already be determined by the two simple-coroot edge restrictions together with one additional mixed rank-2 Levi statistic on each adjacent Levi slice. The point is to compress the existing reconstruction machinery to a minimal injective witness family.

### Suggested concrete model

Use dominant coweights for `GL₃` as pairs `(a,b) : ℕ × ℕ`, representing the dominant coweight
\[
(a+b,b,0),
\]
so the two chamber edges are `b = 0` and `a = 0`. This avoids quotient issues and gives a concrete finite-support combinatorics.

Represent tropical Hecke functions as finitely supported functions
```lean
abbrev DomGL3 := ℕ × ℕ
abbrev TropFn := DomGL3 → ℝ
```
with bounded support encoded by vanishing outside a rectangle:
```lean
def SupportedInBox (N : ℕ) (f : TropFn) : Prop :=
  ∀ p : DomGL3, N < p.1 + p.2 → f p = 0
```
or, if more convenient for your existing local infrastructure,
```lean
def SupportedInRect (A B : ℕ) (f : TropFn) : Prop :=
  ∀ p : DomGL3, A < p.1 ∨ B < p.2 → f p = 0
```
Use whichever bounded-support notion matches the already-developed GL₃ files.

Define the two edge restrictions:
```lean
def edge₁ (f : TropFn) (a : ℕ) : ℝ := f (a, 0)
def edge₂ (f : TropFn) (b : ℕ) : ℝ := f (0, b)
```

Define the adjacent rank-2 Levi slices by fixing one coordinate:
```lean
def sliceLeft  (f : TropFn) (b : ℕ) : ℕ → ℝ := fun a => f (a, b)
def sliceRight (f : TropFn) (a : ℕ) : ℕ → ℝ := fun b => f (a, b)
```

For the “single mixed moment”, use the first weighted moment on each slice:
```lean
def mixedMomentLeft (f : TropFn) (b : ℕ) : ℝ :=
  ∑ a in Finset.range (N+1), (a : ℝ) * f (a, b)

def mixedMomentRight (f : TropFn) (a : ℕ) : ℝ :=
  ∑ b in Finset.range (N+1), (b : ℝ) * f (a, b)
```
with the obvious bounded-support parameter `N`; alternatively define these over `Finset.Icc 0 N` or over the support finset if your existing file already packages finite support. The crucial point is that the mixed statistic is linear and probes the rank-2 Levi direction transverse to the chosen facet.

### Main theorem to prove

A clean, concrete target statement is:

```lean
theorem finite_test_family_injective_GL3
    (N : ℕ) (f g : TropFn)
    (hf : SupportedInBox N f) (hg : SupportedInBox N g)
    (hedge₁ : ∀ a ≤ N, edge₁ f a = edge₁ g a)
    (hedge₂ : ∀ b ≤ N, edge₂ f b = edge₂ g b)
    (hmixL : ∀ b ≤ N,
      mixedMomentLeft N (fun p => f p - g p) b = 0)
    (hmixR : ∀ a ≤ N,
      mixedMomentRight N (fun p => f p - g p) a = 0) :
    f = g
```

If your existing rank-2 Levi reconstruction theorem is formulated for a pre-existing tropical Satake transform type rather than raw functions `(ℕ × ℕ) → ℝ`, adapt the theorem statement to that type, but keep the same mathematical content: bounded support + equality on the two chamber edges + vanishing of one mixed Levi moment on each adjacent slice imply equality.

A stronger and often more usable intermediate linearized form is:

```lean
theorem finite_test_family_zero_GL3
    (N : ℕ) (h : TropFn)
    (hsupp : SupportedInBox N h)
    (hedge₁ : ∀ a ≤ N, h (a, 0) = 0)
    (hedge₂ : ∀ b ≤ N, h (0, b) = 0)
    (hmixL : ∀ b ≤ N, mixedMomentLeft N h b = 0)
    (hmixR : ∀ a ≤ N, mixedMomentRight N h a = 0) :
    h = 0
```

and then derive `finite_test_family_injective_GL3` by applying this to `h := fun p => f p - g p`.

### Preferred sharpened theorem

If the existing reconstruction theorem already shows that rank-2 Levi profiles plus edge moments determine the function, aim for the sharper refinement: the *full Levi profile data* can be replaced by just one mixed moment on each slice. In that case formulate a theorem of the shape

```lean
theorem reconstruct_from_edges_and_one_mixed_moment
    (N : ℕ) (h : TropFn)
    (hsupp : SupportedInBox N h)
    (hedge₁ : ∀ a ≤ N, h (a, 0) = 0)
    (hedge₂ : ∀ b ≤ N, h (0, b) = 0)
    (hLeviL : ∀ b ≤ N, leftMixedLeviGeneratorMoment N h b = 0)
    (hLeviR : ∀ a ≤ N, rightMixedLeviGeneratorMoment N h a = 0) :
    h = 0
```

where `leftMixedLeviGeneratorMoment` and `rightMixedLeviGeneratorMoment` should be the exact existing notions from your GL₃ Levi formalism if available. This is the most mathematically meaningful statement because it interfaces directly with the tropical Satake package rather than an ad hoc grid model.

### Proof strategy

Prove the zero theorem first, then package injectivity.

1. **Linearize by passing to the difference**
   Let
   ```lean
   h := fun p => f p - g p
   ```
   and show `SupportedInBox N h`. Rewrite all hypotheses in zero form. This isolates the argument to a single vanishing theorem for a bounded-support function.

2. **Induct on dominant height `k = a + b`**
   Define the height layer
   ```lean
   def layer (k : ℕ) : Finset DomGL3 :=
     (Finset.range (k+1)).image (fun a => (a, k-a))
   ```
   or an equivalent bounded finite set with a proof that all points on height `k` are enumerated. Prove by induction on `k ≤ N` that `h (a,b) = 0` whenever `a+b = k`.

   - Base case `k = 0`: immediate from either edge hypothesis.
   - Boundary points on layer `k`: `(k,0)` and `(0,k)` vanish by the two edge hypotheses.

3. **Use the mixed moment to eliminate interior points on each slice**
   For fixed `b`, the left slice `a ↦ h (a,b)` has finite support in `a ≤ N-b`. The edge hypothesis gives its value at `a = 0`. The mixed moment gives
   \[
   \sum_a a \, h(a,b) = 0.
   \]
   Combined with the inductive vanishing of all lower-height contributions or with an existing rank-2 Levi reconstruction lemma, this should force the remaining top-height coefficient on that slice to vanish. Concretely, isolate the maximal `a` with `a+b = k` and show all smaller `a` on the same slice are already zero from previous layers / Levi compatibility, leaving the weighted sum with only one possible surviving term.

   This is where the existing theorem
   `reconstruct_from_rank2Levi_profiles_and_edge_moments`
   should be exploited: treat each adjacent Levi slice as a rank-2 reconstruction problem, and show that once the edge datum is zero and the one chosen mixed moment vanishes, the slice profile must be zero. The new ingredient is a reduction lemma showing that, on bounded support in `GL₃`, one mixed moment suffices to recover the rank-2 profile needed by the old theorem.

4. **Propagate from facets into the interior**
   After proving each left and right slice vanishes, conclude that every interior point `(a,b)` with `a,b>0` vanishes because it belongs simultaneously to a left slice and a right slice. If your formalization instead organizes data by facet layers, prove a lemma:
   ```lean
   lemma zero_on_all_slices_of_height_le_k :
     ...
   ```
   and then deduce `h = 0` by extensionality.

5. **Conclude extensional equality**
   Use
   ```lean
   funext
   ```
   over `p : DomGL3`, split into the cases `N < p.1 + p.2` and `p.1 + p.2 ≤ N`. Outside the support box, `h p = 0` by `hsupp`; inside, use the induction result.

### Key intermediate lemmas worth proving

These are likely the right granularity for a robust Lean development:

```lean
lemma supportedInBox_sub
    (N : ℕ) {f g : TropFn}
    (hf : SupportedInBox N f) (hg : SupportedInBox N g) :
    SupportedInBox N (fun p => f p - g p)
```

```lean
lemma edge_zero_of_difference
    {f g : TropFn} (hfg : ∀ a ≤ N, edge₁ f a = edge₁ g a) :
    ∀ a ≤ N, (fun p => f p - g p) (a,0) = 0
```

```lean
lemma layer_decomposition
    {p : DomGL3} (hp : p.1 + p.2 = k) :
    p ∈ layer k
```

```lean
lemma mixedMomentLeft_eq_singleton
    (hzero : ∀ a < a₀, h (a,b) = 0)
    (hsupp : ∀ a > a₀, h (a,b) = 0) :
    mixedMomentLeft N h b = (a₀ : ℝ) * h (a₀,b)
```

and then, if `a₀ ≠ 0`,
```lean
lemma coeff_zero_of_weighted_singleton
    (ha₀ : a₀ ≠ 0)
    (hm : mixedMomentLeft N h b = 0) :
    h (a₀,b) = 0
```
using `nlinarith` or `field_simp` after coercions to `ℝ`.

If your existing GL₃ library has a more structural Levi-slice formalism, replace these ad hoc lemmas with analogues phrased using those definitions; the important thing is to expose one “moment isolates top coefficient” lemma that makes the finite test family argument actually go through.

### Lean-specific implementation advice

- If support is better encoded as a `Finsupp`, consider:
  ```lean
  abbrev TropFn := DomGL3 →₀ ℝ
  ```
  Then edge and moment sums become finite automatically. In that setting, the theorem signatures should use `f.support` bounded by a box condition:
  ```lean
  ∀ p ∈ f.support, p.1 + p.2 ≤ N
  ```
  This may make the proof substantially cleaner.
- For sums over bounded slices, use `Finset.range (N+1)` and show terms vanish outside the true slice support.
- For equality of functions, prefer `ext p` followed by case analysis on `p = (a,b)`.
- For arithmetic on `ℕ`-indexed layers, `omega`/`linarith`/`nlinarith` will likely be useful after coercing to `ℝ`.

### Why this matters

This theorem is not just another injectivity statement: it identifies a *strictly smaller finite test family* that still determines bounded-support `GL₃` tropical Satake data. That is exactly the right strengthening of the rank-1/rank-2 Levi reconstruction program: instead of storing full Levi profiles, one can certify equality from the two simple-coroot edge traces plus one mixed rank-2 moment per adjacent slice. Formally, this gives a minimal witness set for bounded-support injectivity in `GL₃`, sharpening the partial reconstruction results while remaining orthogonal to the harder surjectivity and global separation problems. It also provides the natural `GL₃` analogue of the already-established `GL₂` finite-determinacy phenomena and should become a reusable lemma for later tropical Hecke-algebra and Satake-faithfulness developments.

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
