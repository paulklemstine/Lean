## Research Task: Tropical certified robustness for multiclass residual ReLU networks with general 1-Lipschitz skip operators

**Research Mode: PROVE**

Create `MachineLearning/Neural/TropicalMulticlassResidualGeneralSkip.lean` and formalize a unified multiclass robustness theorem for residual ReLU networks whose skip map is an arbitrary linear/affine operator with known `‖·‖∞→∞` bound, not just the identity.

The goal is to push the existing tropical/Lipschitz certification line from:
- plain feedforward networks,
- residual networks with identity skip,
- multiclass pairwise-margin certification,

to a single theorem covering **multiclass residual architectures with general skip operators**.

---

### Concrete setup to formalize

Work over finite-dimensional real coordinate spaces using `Fin n → ℝ` and `Fin C → ℝ`.

A good concrete model is:

```lean
abbrev Vec (n : ℕ) := Fin n → ℝ
abbrev Lin (m n : ℕ) := Matrix (Fin m) (Fin n) ℝ
```

Represent a residual block on `Vec d` as
```lean
def residualBlock
    {d : ℕ}
    (S : Vec d → Vec d)
    (g : Vec d → Vec d) : Vec d → Vec d :=
  fun x => S x + g x
```

with hypotheses that `S` is linear (or affine if you prefer to package a bias separately) and that both `S` and `g` satisfy explicit `L∞`-Lipschitz bounds. The cleanest first target is linear skip maps:
```lean
IsLinBoundedInf (S : Vec d → Vec d) (s : ℝ) : Prop :=
  ∀ x y, dist (S x) (S y) ≤ s * dist x y
```
or equivalently a norm-style formulation using
```lean
‖S x - S y‖ ≤ s * ‖x - y‖
```
for the sup norm on `Fin d → ℝ`.

For the branch maps, use:
```lean
LipschitzWithBranch (g : Vec d → Vec d) (L : ℝ) : Prop :=
  ∀ x y, dist (g x) (g y) ≤ L * dist x y
```

Then define the depth-`n` residual composition:
```lean
def residualNet
    {d : ℕ}
    (blocks : Fin n → (Vec d → Vec d))
    : Vec d → Vec d
```
as the iterated composition of blocks in depth order.

For multiclass output, either:
1. keep all layers square on `Vec d` and let the final map be `head : Vec C`, or
2. define a final classifier map `out : Vec d → Vec C` with known Lipschitz bound.

The second is more flexible and is the right theorem. So the total model should look like:
```lean
F x = out (residualNet blocks x)
```
with `out : Vec d → Vec C`.

For pairwise gap functions, define:
```lean
def logitGap {C d : ℕ} (f : Vec d → Vec C) (y j : Fin C) : Vec d → ℝ :=
  fun x => f x y - f x j
```

and prediction:
```lean
def IsStrictArgmax {C : ℕ} (z : Vec C) (y : Fin C) : Prop :=
  ∀ j, j ≠ y → z j < z y
```

---

### Main theorem statements to target

You should prove the results in increasing strength. The following type signatures are the right targets, possibly with minor adaptation to the exact norm API already present in the repository.

#### 1. One-block residual Lipschitz bound with general skip

```lean
theorem residualBlock_lipschitz_inf
    {d : ℕ}
    {S g : Vec d → Vec d}
    {s L : ℝ}
    (hs_nonneg : 0 ≤ s)
    (hL_nonneg : 0 ≤ L)
    (hS : ∀ x y, ‖S x - S y‖ ≤ s * ‖x - y‖)
    (hg : ∀ x y, ‖g x - g y‖ ≤ L * ‖x - y‖) :
    ∀ x y, ‖(residualBlock S g) x - (residualBlock S g) y‖ ≤ (s + L) * ‖x - y‖ := by
```

This is the atomic estimate. It should be sharp at the level of triangle inequality.

#### 2. Depth-wise composition bound for residual networks with per-layer skip constants

For `n` residual blocks with skip bounds `s_k` and branch bounds `L_k`, the whole network is Lipschitz with constant
\[
K_{\mathrm{res}} = \prod_{k < n} (s_k + L_k).
\]

A concrete theorem:

```lean
theorem residualNet_lipschitz_inf
    {d n : ℕ}
    (blocks : Fin n → (Vec d → Vec d))
    (s L : Fin n → ℝ)
    (hs_nonneg : ∀ k, 0 ≤ s k)
    (hL_nonneg : ∀ k, 0 ≤ L k)
    (hblock :
      ∀ k, ∀ x y,
        ‖blocks k x - blocks k y‖ ≤ (s k + L k) * ‖x - y‖) :
    ∀ x y,
      ‖residualNet blocks x - residualNet blocks y‖
        ≤ (∏ k, (s k + L k)) * ‖x - y‖ := by
```

If your residual network is built from data `(S k, g k)` rather than preassembled blocks, prove the stronger theorem directly in that language and derive the displayed one as a corollary.

#### 3. Pairwise logit-gap Lipschitz bound

If `f : Vec d → Vec C` is `K`-Lipschitz in `L∞` on logits coordinatewise, then each gap
\[
h_{y,j}(x) = f_y(x) - f_j(x)
\]
is `2K`-Lipschitz. This factor `2` is exactly what drives the certified radius.

```lean
theorem logitGap_lipschitz_of_vector_lipschitz
    {d C : ℕ}
    {f : Vec d → Vec C}
    {K : ℝ}
    (hK_nonneg : 0 ≤ K)
    (hf : ∀ x y, ‖f x - f y‖ ≤ K * ‖x - y‖) :
    ∀ (y j : Fin C) (x x' : Vec d),
      |logitGap f y j x - logitGap f y j x'| ≤ (2 * K) * ‖x - x'‖ := by
```

A sharper version with pair-dependent constants is even better: if you can define `Kgap y j`, prove
```lean
∀ y j x x', |logitGap f y j x - logitGap f y j x'| ≤ Kgap y j * ‖x - x'‖
```
and then instantiate `Kgap y j = 2*K`.

#### 4. Multiclass certification from pairwise margins

This is the core robustness theorem:

```lean
theorem multiclass_certified_radius_of_gap
    {d C : ℕ}
    {f : Vec d → Vec C}
    {y : Fin C}
    {Kgap : Fin C → ℝ}
    {x0 x : Vec d}
    (hK_nonneg : ∀ j, 0 ≤ Kgap j)
    (hgap_lip :
      ∀ j, j ≠ y →
        |logitGap f y j x - logitGap f y j x0| ≤ Kgap j * ‖x - x0‖)
    (hmargin : ∀ j, j ≠ y → 0 < logitGap f y j x0)
    (hball :
      ‖x - x0‖ <
        sInf {r : ℝ | ∃ j, j ≠ y ∧ r = logitGap f y j x0 / (2 * Kgap j)}) :
    IsStrictArgmax (f x) y := by
```

This `sInf` formulation may be awkward in Lean because of positivity/zero-divisor issues. A much more tractable finite-dimensional formulation is to use a `Finset` minimum over `univ.erase y` and assume strict positivity of each `Kgap j`:

```lean
def certifiedRadius
    {C d : ℕ} (f : Vec d → Vec C) (y : Fin C) (Kgap : Fin C → ℝ) (x0 : Vec d) : ℝ :=
  ((Finset.univ.erase y).inf' _ (fun j => logitGap f y j x0 / (2 * Kgap j)))
```

Then prove:

```lean
theorem multiclass_certified_radius_of_gap_finset
    {d C : ℕ}
    [NeZero C]
    {f : Vec d → Vec C}
    {y : Fin C}
    {Kgap : Fin C → ℝ}
    {x0 x : Vec d}
    (hK_pos : ∀ j, j ≠ y → 0 < Kgap j)
    (hgap_lip :
      ∀ j, j ≠ y →
        |logitGap f y j x - logitGap f y j x0| ≤ Kgap j * ‖x - x0‖)
    (hmargin : ∀ j, j ≠ y → 0 < logitGap f y j x0)
    (hball :
      ‖x - x0‖ < (Finset.univ.erase y).inf' (by simp) (fun j => logitGap f y j x0 / (2 * Kgap j))) :
    IsStrictArgmax (f x) y := by
```

The key inequality to derive is
\[
h_{y,j}(x) \ge h_{y,j}(x_0) - K_j \|x-x_0\| > 0,
\]
for every `j ≠ y`, hence `f x j < f x y`.

#### 5. Unified residual-network certification theorem

Combine the residual network Lipschitz theorem with the pairwise gap theorem. A clean shared-bound version is:

```lean
theorem residual_multiclass_certified_radius_shared
    {d C n : ℕ}
    [NeZero C]
    (blocks : Fin n → (Vec d → Vec d))
    (out : Vec d → Vec C)
    (s L : Fin n → ℝ)
    (Kout : ℝ)
    (y : Fin C)
    (x0 x : Vec d)
    (hs_nonneg : ∀ k, 0 ≤ s k)
    (hL_nonneg : ∀ k, 0 ≤ L k)
    (hKout_nonneg : 0 ≤ Kout)
    (hblocks :
      ∀ k, ∀ u v, ‖blocks k u - blocks k v‖ ≤ (s k + L k) * ‖u - v‖)
    (hout :
      ∀ u v, ‖out u - out v‖ ≤ Kout * ‖u - v‖)
    (hmargin :
      ∀ j, j ≠ y →
        0 < logitGap (fun z => out (residualNet blocks z)) y j x0)
    (hball :
      ‖x - x0‖ <
        (Finset.univ.erase y).inf' (by simp)
          (fun j =>
            logitGap (fun z => out (residualNet blocks z)) y j x0
              / (2 * (Kout * ∏ k, (s k + L k))))) :
    IsStrictArgmax (out (residualNet blocks x)) y := by
```

This is the theorem that exactly matches the intended “shared tropical/Lipschitz constant” form. Also prove the pair-dependent refinement:

```lean
theorem residual_multiclass_certified_radius_pairwise
    ...
    (Kgap : Fin C → ℝ)
    (hgap :
      ∀ j, j ≠ y →
        |logitGap (fun z => out (residualNet blocks z)) y j x
          - logitGap (fun z => out (residualNet blocks z)) y j x0|
          ≤ Kgap j * ‖x - x0‖)
    ...
```

The shared-bound theorem should be a corollary with
```lean
Kgap j = 2 * (Kout * ∏ k, (s k + L k))
```
or any sharper already-available tropical constant.

#### 6. Identity-skip and contraction-skip corollaries

To show this theorem is genuinely a strict extension of the current residual theorem, prove at least these corollaries:

- **Identity skip**: if `s k = 1` for all `k`, recover the known radius formula with product `∏ k (1 + L k)`.
- **Contractive skip**: if `s k ≤ 1`, then
  \[
  \prod_k (s_k + L_k) \le \prod_k (1 + L_k),
  \]
  so the general-skip certified radius is at least as good as the identity-skip bound whenever skips are contractions.

A clean Lean statement for the latter:

```lean
theorem prod_add_le_prod_one_add_of_le_one
    {n : ℕ} {s L : Fin n → ℝ}
    (hs_nonneg : ∀ k, 0 ≤ s k)
    (hs_le_one : ∀ k, s k ≤ 1)
    (hL_nonneg : ∀ k, 0 ≤ L k) :
    (∏ k, (s k + L k)) ≤ ∏ k, (1 + L k) := by
```

Then deduce a radius monotonicity corollary.

---

### Proof strategy details

1. **Single residual block = triangle inequality plus additive constants.**  
   Expand
   ```lean
   (S x + g x) - (S y + g y) = (S x - S y) + (g x - g y)
   ```
   and apply the norm triangle inequality. Then use the given bounds for `S` and `g`, and finish with
   ```lean
   s * ‖x-y‖ + L * ‖x-y‖ = (s+L) * ‖x-y‖.
   ```
   This is the exact place where the residual structure yields additive layer constants before composition turns them multiplicative.

2. **Composition theorem by induction on depth.**  
   Define `residualNet` recursively or via `Fin.fold`. Prove the standard composition lemma:
   ```lean
   ‖f (g x) - f (g y)‖ ≤ Kf * (Kg * ‖x-y‖) = (Kf*Kg) * ‖x-y‖.
   ```
   Then induct over layers to obtain the product formula. If there is already a theorem analogous to `deep_lipschitz_bound`, reuse it with per-layer constants `s k + L k`.

3. **Gap Lipschitz constant from vector Lipschitz constant.**  
   For fixed `y,j`,
   ```lean
   (f x y - f x j) - (f x' y - f x' j)
     = (f x y - f x' y) - (f x j - f x' j).
   ```
   Apply `abs_sub_le` or the scalar triangle inequality:
   \[
   |a-b| \le |a| + |b|.
   \]
   Each coordinate difference is bounded by `‖f x - f x'‖` under the sup norm, then by `K‖x-x'‖`. This gives the factor `2K`. If the library has a theorem that each coordinate is bounded by the sup norm, use it directly; otherwise prove a small lemma for `Fin n → ℝ`.

4. **Certification by preserving positivity of every pairwise gap.**  
   For each `j ≠ y`, use:
   \[
   h_{y,j}(x) \ge h_{y,j}(x_0) - |h_{y,j}(x)-h_{y,j}(x_0)|.
   \]
   Then plug in the Lipschitz bound. If
   \[
   \|x-x_0\| < \frac{h_{y,j}(x_0)}{K_j},
   \]
   then `h_{y,j}(x) > 0`. In the shared-bound theorem, `K_j = 2K`, hence the advertised radius
   \[
   r^* = \min_{j \ne y} \frac{h_{y,j}(x_0)}{2K}.
   \]
   The only subtlety is handling the finite minimum over classes in Lean; use `Finset.univ.erase y` and `Finset.inf'`.

5. **General skip theorem as the bridge between existing results.**  
   The residual bound gives a network-wide `Kres`; the output map contributes `Kout`; the gap theorem contributes the factor `2`. Chain them carefully:
   \[
   K_{\mathrm{gap}} \le 2 K_{\mathrm{out}} \prod_k (s_k + L_k).
   \]
   Then invoke the multiclass certification lemma.

6. **Contraction-skip improvement.**  
   The proof of
   \[
   \prod_k (s_k + L_k) \le \prod_k (1 + L_k)
   \]
   is pointwise monotonicity of multiplication over nonnegative reals, using `s_k ≤ 1`. This corollary is mathematically important: it shows non-identity skips are not merely tolerated, but can improve the certified radius when the skip path is contractive.

---

### Important auxiliary lemmas worth proving first

These will make the main proofs much smoother:

```lean
theorem coord_abs_le_supnorm
    {n : ℕ} (v : Vec n) (i : Fin n) :
    |v i| ≤ ‖v‖ := by
```

```lean
theorem abs_logitGap_diff_le_two_mul_norm
    {C : ℕ} (z z' : Vec C) (y j : Fin C) :
    |((z y - z j) - (z' y - z' j))| ≤ 2 * ‖z - z'‖ := by
```

```lean
theorem lipschitz_comp
    {α β γ : Type _}
    [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ]
    {f : β → γ} {g : α → β} {Kf Kg : ℝ}
    (hKf : ∀ u v, dist (f u) (f v) ≤ Kf * dist u v)
    (hKg : ∀ x y, dist (g x) (g y) ≤ Kg * dist x y)
    (hKf_nonneg : 0 ≤ Kf) :
    ∀ x y, dist (f (g x)) (f (g y)) ≤ (Kf * Kg) * dist x y := by
```

```lean
theorem gap_positive_of_gap_positive_at_center
    {d C : ℕ}
    {f : Vec d → Vec C}
    {y j : Fin C}
    {x0 x : Vec d}
    {K : ℝ}
    (hK_nonneg : 0 ≤ K)
    (hmargin : 0 < logitGap f y j x0)
    (hlip : |logitGap f y j x - logitGap f y j x0| ≤ K * ‖x - x0‖)
    (hball : ‖x - x0‖ < logitGap f y j x0 / K) :
    0 < logitGap f y j x := by
```

You may need a version with `2*K` already absorbed to avoid division-by-zero complications.

---

### Why this matters

This theorem is a genuine strengthening of the tropical certified robustness program:

- It removes the artificial restriction that residual skips must be the identity.
- It unifies residual certification and multiclass pairwise-margin certification in one formal theorem.
- It captures practical architectures with projection, downsampling, or contractive skip paths.
- It shows the certified radius depends transparently on the residual branch constants and skip operator norms:
  \[
  r^*(x_0,y) = \min_{j\ne y} \frac{f_y(x_0)-f_j(x_0)}
    {2 K_{y,j}},
  \qquad
  K_{y,j} \le 2 K_{\mathrm{out}} \prod_k (s_k + L_k).
  \]
- In the common case `s_k ≤ 1`, it recovers or improves the identity-skip bound, so this is not merely a generalization but a sharper theorem for contractive residual architectures.

This is exactly the sort of publishable bridge theorem that turns isolated binary/multiclass and identity/general-skip results into a single robust formal framework.

---

### Implementation guidance

- Prefer a staged file structure: first elementary norm/gap lemmas, then residual block bounds, then network composition, then multiclass certification, then corollaries.
- Keep affine skips as a later corollary: if `S x = A x + b`, the bias cancels in differences, so the same Lipschitz proof works once you prove the difference formula.
- Use finite `Fin` index types throughout so all minima can be handled with `Finset`.
- If exact operator-norm machinery is cumbersome, phrase hypotheses directly as Lipschitz inequalities; this is sufficient for the certification theorem and avoids unnecessary linear-algebra overhead.
- If there is an existing theorem giving a feedforward/tropical Lipschitz constant for the branch `g_k`, plug it in rather than reproving branch bounds from scratch.

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
