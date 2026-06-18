## Research Task: Tropical certified robustness for attention-style max-affine gating networks via pathwise margin decomposition

**Research Mode: PROVE**

Work in a new file

```lean
MachineLearning/Neural/TropicalAttentionRobustness.lean
```

and formalize a robustness theorem for a richer class of tropicalized networks with input-dependent routing. The goal is to push the existing tropical robustness program from fixed DAG / residual architectures to **gated max-affine architectures**, where each block may either:
1. take a hard max over finitely many affine branches, or
2. take a simplex-weighted convex combination of branch outputs using input-dependent gating maps that are 1-Lipschitz in `‖·‖∞`.

The key novelty is that routing depends on the input, so the proof must track how the active affine support can change under perturbation while still preserving a usable global tropical Lipschitz bound.

---

### Core definitions to introduce

Use concrete finite index types throughout, e.g. `Fin n`, `Fin k`, `Fin C`. A clean formal route is to define a class of functions represented by finite families of affine forms together with a certified `L∞` Lipschitz constant.

A useful affine primitive is:

```lean
def affineFun {n : ℕ} (w : Fin n → ℝ) (b : ℝ) (x : Fin n → ℝ) : ℝ :=
  (∑ i, w i * x i) + b
```

Define the `L∞` distance on inputs:

```lean
def distInf {n : ℕ} (x y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup (fun i => |x i - y i|)
```

If there is already a suitable sup-norm in the local library, use that instead; otherwise prove the basic lemmas you need for this concrete definition.

For tropical support, define a max-affine representation:

```lean
def IsMaxAffineRep {n k : ℕ} (f : (Fin n → ℝ) → ℝ)
    (W : Fin k → Fin n → ℝ) (b : Fin k → ℝ) : Prop :=
  ∀ x, f x = Finset.univ.sup (fun j : Fin k => affineFun (W j) (b j) x)
```

Since `Finset.sup` over `ℝ` may require an order-top workaround, it is also acceptable to use a nonempty finite set and write the representation with `iSup` over `Fin k`, or to define recursively by finite `max`. What matters is a finite max of affine forms.

For a certified tropical Lipschitz bound, define something like:

```lean
def AffineInfNormBound {n : ℕ} (w : Fin n → ℝ) (K : ℝ) : Prop :=
  ∀ i, |w i| ≤ K
```

and prove that if every affine branch has coefficient-wise bound `≤ K`, then the max-affine function is `K`-Lipschitz in `distInf`.

For gating, use two separate models.

A simplex-gated convex-combination block:

```lean
def InSimplex {k : ℕ} (g : Fin k → ℝ) : Prop :=
  (∀ j, 0 ≤ g j) ∧ (∑ j, g j) = 1
```

```lean
def GatedCombine {n k : ℕ}
    (g : (Fin n → ℝ) → Fin k → ℝ)
    (φ : Fin k → (Fin n → ℝ) → ℝ) :
    (Fin n → ℝ) → ℝ :=
  fun x => ∑ j, g x j * φ j x
```

and a hard-routing block:

```lean
def HardMaxRoute {n k : ℕ}
    (φ : Fin k → (Fin n → ℝ) → ℝ) :
    (Fin n → ℝ) → ℝ :=
  fun x => Finset.univ.sup (fun j : Fin k => φ j x)
```

For classifier margins, define:

```lean
def logitGap {n C : ℕ} (f : Fin C → (Fin n → ℝ) → ℝ)
    (c d : Fin C) (x : Fin n → ℝ) : ℝ :=
  f c x - f d x
```

```lean
def classMargin {n C : ℕ} (f : Fin C → (Fin n → ℝ) → ℝ)
    (c : Fin C) (x : Fin n → ℝ) : ℝ :=
  Finset.inf' (Finset.univ.erase c) (by
    -- prove nonemptiness when needed via hypothesis `1 < C`
  ) (fun d => logitGap f c d x)
```

If `Finset.inf'` is awkward, formulate the main certification theorem with an explicit hypothesis
`∀ d ≠ c, m ≤ f c x - f d x`
instead of introducing `classMargin` first.

---

### Main theorem statements to target

You should prove at least the following three theorems, with exact Lean-style signatures along these lines.

#### 1. Max-affine functions are tropically Lipschitz

```lean
theorem maxAffine_lipschitz_inf
    {n k : ℕ} {f : (Fin n → ℝ) → ℝ}
    {W : Fin k → Fin n → ℝ} {b : Fin k → ℝ} {K : ℝ}
    (hrep : IsMaxAffineRep f W b)
    (hK : ∀ j i, |W j i| ≤ K) :
    ∀ x y, |f x - f y| ≤ K * distInf x y
```

This is the foundational support theorem. It is the tropical analogue of the standard fact that a maximum of affine functions inherits the worst branch Lipschitz constant.

A useful strengthening, if convenient, is to prove first:

```lean
lemma affine_lipschitz_inf
    {n : ℕ} {w : Fin n → ℝ} {b K : ℝ}
    (hK : ∀ i, |w i| ≤ K) :
    ∀ x y, |affineFun w b x - affineFun w b y| ≤ K * distInf x y
```

and then lift to finite maxima.

#### 2. Closure under gated composition

For simplex-gated mixtures, formulate a theorem of the following shape:

```lean
theorem gatedCombine_lipschitz_inf
    {n k : ℕ}
    {g : (Fin n → ℝ) → Fin k → ℝ}
    {φ : Fin k → (Fin n → ℝ) → ℝ}
    {Kg Kφ B : ℝ}
    (hg_lip : ∀ j x y, |g x j - g y j| ≤ Kg * distInf x y)
    (hg_simplex : ∀ x, InSimplex (g x))
    (hφ_lip : ∀ j x y, |φ j x - φ j y| ≤ Kφ * distInf x y)
    (hφ_bound : ∀ j x, |φ j x| ≤ B) :
    ∀ x y, |GatedCombine g φ x - GatedCombine g φ y|
      ≤ (Kφ + (k : ℝ) * Kg * B) * distInf x y
```

This theorem is not merely bookkeeping: it is the precise place where input-dependent routing enters. The decomposition
\[
g_x \cdot φ_x - g_y \cdot φ_y
= g_x \cdot (φ_x-φ_y) + (g_x-g_y)\cdot φ_y
\]
should be formalized carefully, using simplex positivity and `∑ g_x = 1` to control the first term, and the uniform branch bound `|φ_j| ≤ B` to control the second.

For hard max routing, prove:

```lean
theorem hardMaxRoute_lipschitz_inf
    {n k : ℕ}
    {φ : Fin k → (Fin n → ℝ) → ℝ}
    {K : ℝ}
    (hφ_lip : ∀ j x y, |φ j x - φ j y| ≤ K * distInf x y) :
    ∀ x y, |HardMaxRoute φ x - HardMaxRoute φ y| ≤ K * distInf x y
```

This gives closure of certified robustness under hard attention / argmax-style routing.

#### 3. Pairwise logit-gap perturbation bound and certification

Assume each class logit is globally `K_trop`-Lipschitz in `distInf`. Then prove the pairwise gap inequality:

```lean
theorem logitGap_lipschitz_inf
    {n C : ℕ}
    {f : Fin C → (Fin n → ℝ) → ℝ}
    {K_trop : ℝ}
    (hf_lip : ∀ c x y, |f c x - f c y| ≤ K_trop * distInf x y) :
    ∀ c d x y,
      |(f c x - f d x) - (f c y - f d y)| ≤ 2 * K_trop * distInf x y
```

Then derive the certification theorem:

```lean
theorem tropical_attention_certified_radius
    {n C : ℕ}
    {f : Fin C → (Fin n → ℝ) → ℝ}
    {K_trop m : ℝ}
    {c : Fin C} {x z : Fin n → ℝ}
    (hK : ∀ c x y, |f c x - f c y| ≤ K_trop * distInf x y)
    (hmarg : ∀ d, d ≠ c → m ≤ f c x - f d x)
    (hm_nonneg : 0 ≤ m)
    (hz : distInf x z < m / (2 * K_trop)) :
    ∀ d, d ≠ c → f d z < f c z
```

Also prove a weak `≤` version with `distInf x z ≤ m / (2 * K_trop)` yielding `f d z ≤ f c z`; this version is often easier and the strict version can follow from the strict radius hypothesis.

If division causes side conditions, isolate the positive-denominator assumption:

```lean
(hKpos : 0 < K_trop)
```

and use it explicitly. It is mathematically appropriate anyway: when `K_trop = 0`, the classifier is globally constant on connected components and should be treated separately.

A final corollary can package prediction invariance:

```lean
theorem tropical_attention_prediction_constant_on_ball
    {n C : ℕ}
    {f : Fin C → (Fin n → ℝ) → ℝ}
    {K_trop m : ℝ}
    {c : Fin C} {x : Fin n → ℝ}
    (hK : ∀ c x y, |f c x - f c y| ≤ K_trop * distInf x y)
    (hargmax : ∀ d, d ≠ c → m ≤ f c x - f d x)
    (hm_nonneg : 0 ≤ m)
    (hKpos : 0 < K_trop) :
    ∀ z, distInf x z < m / (2 * K_trop) →
      ∀ d, d ≠ c → f d z < f c z
```

This is the exact certified robustness statement: the predicted class `c` cannot change anywhere in the `L∞` ball of radius `m/(2K_trop)`.

---

### Proof strategy details

The difficult part is not the final margin argument; it is proving that input-dependent routing still preserves a global pathwise Lipschitz certificate. Structure the development in the following sequence.

#### Step 1: Build the `L∞` affine estimate coordinatewise
For `affineFun`, expand
\[
\mathrm{affineFun}(w,b,x)-\mathrm{affineFun}(w,b,y)=\sum_i w_i (x_i-y_i).
\]
Then use:
- `abs_sum_le_sum_abs`,
- `|w_i (x_i-y_i)| = |w_i| |x_i-y_i|`,
- the coordinatewise estimate `|x_i-y_i| ≤ distInf x y`,
- and the coefficient bound `|w_i| ≤ K`.

You may first prove
```lean
lemma abs_sub_le_distInf {n} (x y : Fin n → ℝ) (i : Fin n) :
  |x i - y i| ≤ distInf x y
```
from the definition of `distInf`.

A very useful stronger version is
```lean
lemma affine_lipschitz_inf_of_sum
    ...
    |affineFun w b x - affineFun w b y|
      ≤ (∑ i, |w i|) * distInf x y
```
and then deduce the simpler `K * distInf x y` bound under a hypothesis on `∑ i |w i|`. This may align better with the actual tropical pathwise constant if the catalog’s previous robustness work already uses `ℓ₁`-weight bounds against `ℓ∞` input perturbations.

#### Step 2: Lift from affine branches to finite maxima
For `f(x) = max_j a_j(x)`, prove the elementary inequality
\[
f(x) \le f(y) + K\,d(x,y)
\]
by choosing an index `j` nearly/actually attaining the maximum at `x`, then using the branch Lipschitz bound on `a_j`. By symmetry, get
\[
|f(x)-f(y)| \le K\,d(x,y).
\]
In Lean, finite maxima over `Fin k` let you use `Finset.le_sup` / `Finset.sup_le` style lemmas, or a recursion over `k` if order lemmas become awkward. Keep this lemma self-contained; it will be reused for hard routing and for tropical support representations of logits.

#### Step 3: Prove the gated-combination decomposition carefully
For
\[
F(x)=\sum_j g_j(x)\,φ_j(x),
\]
write
\[
F(x)-F(y)=\sum_j g_j(x)(φ_j(x)-φ_j(y))
+\sum_j (g_j(x)-g_j(y))φ_j(y).
\]
Then bound the two sums separately.

For the first sum:
- use `0 ≤ g_j(x)` and `∑_j g_j(x)=1`,
- use `|φ_j(x)-φ_j(y)| ≤ Kφ d(x,y)`,
- conclude `≤ Kφ d(x,y)`.

For the second sum:
- use `|(g_j(x)-g_j(y))φ_j(y)| ≤ |g_j(x)-g_j(y)| B`,
- sum over `j`,
- use the per-coordinate gating Lipschitz bound to get `≤ k * Kg * B * d(x,y)`.

This is the key pathwise decomposition theorem. It is the attention analogue of the residual/DAG decomposition: the routing perturbation contributes an extra additive term controlled by gate smoothness and branch magnitude. If you can sharpen `k * Kg * B` to `B * ∑_j Kg_j`, even better; but the uniform version is already substantial.

#### Step 4: Derive pairwise logit-gap stability
For any classes `c,d`,
\[
[(f_c-f_d)(x)]-[(f_c-f_d)(y)]
= [f_c(x)-f_c(y)]-[f_d(x)-f_d(y)].
\]
Then use
\[
|A-B| \le |A|+|B|
\]
with the classwise `K_trop` bound to obtain the factor `2K_trop`.

This is the exact perturbation inequality needed for certification, and it is architecture-agnostic once the closure theorems have supplied `hK`.

#### Step 5: Convert gap stability into a certified radius
Fix `d ≠ c`. From the margin hypothesis at `x`,
\[
m \le f_c(x)-f_d(x).
\]
Using the gap perturbation bound,
\[
(f_c(z)-f_d(z)) \ge (f_c(x)-f_d(x)) - 2K_trop\,d(x,z)
\ge m - 2K_trop\,d(x,z).
\]
Thus if `d(x,z) < m/(2K_trop)`, then `f_c(z)-f_d(z) > 0`, hence `f_d(z) < f_c(z)`.

Isolate the algebraic inequality
```lean
m - 2 * K_trop * distInf x z > 0
```
as a small lemma; it will simplify the final proof script substantially.

---

### Stronger theorem worth attempting if the development goes smoothly

After the basic certification theorem is in place, package a compositional theorem for a recursively defined syntax of gated tropical networks. For example:

```lean
inductive TropGateNet (n : ℕ) : Type
| affine    : (Fin n → ℝ) → ℝ → TropGateNet n
| max       : {k : ℕ} → (Fin k → TropGateNet n) → TropGateNet n
| convexGate :
    {k : ℕ} →
    ((Fin n → ℝ) → Fin k → ℝ) →
    (Fin k → TropGateNet n) →
    TropGateNet n
```

with an evaluator `eval : TropGateNet n → (Fin n → ℝ) → ℝ` and a recursively computed certificate `certLip : TropGateNet n → ℝ`. Then prove:

```lean
theorem eval_lipschitz_of_cert
    {n : ℕ} :
    ∀ (N : TropGateNet n) x y,
      |eval N x - eval N y| ≤ certLip N * distInf x y
```

followed by a classifier-level certification corollary. This would be a very strong formal artifact: it turns the mathematical theorem into a reusable certified robustness engine for attention-style tropical networks.

---

### Why this matters

This theorem is the natural next step in the tropical robustness program. Existing results for residual or fixed-DAG ReLU/tropical networks rely on static graph structure: the set of contributing paths is combinatorially fixed. Attention and mixture-of-experts architectures break that simplicity because routing is itself input-dependent. The theorem above shows that tropical geometry still controls robustness in this dynamic setting: the classifier margin survives perturbation so long as the total pathwise tropical Lipschitz constant is small relative to the observed logit gap.

Formally, this gives a mathematically rigorous bridge between:
- tropical max-plus representations of neural computation,
- certified `L∞` robustness via margins,
- and modern gating / attention mechanisms.

It is a genuinely new theorem, not a routine restatement of the residual case, because the proof must explicitly decompose and control routing variation. If successful, this file will provide the first reusable Lean theorem showing that **input-dependent tropical routing preserves certifiable classification under a pathwise margin bound**.

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
