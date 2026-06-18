## Research Task: Tropical certified robustness for residual ReLU networks with identity skip connections

Research Mode: PROVE

Develop a residual-network analogue of the existing tropical certified robustness theorem for multiclass ReLU score maps. The core goal is to formalize that identity skip connections do not destroy the tropical margin certificate, and in fact admit a clean compositional robustness bound controlled by a product-form Lipschitz factor and a residual tropical degree parameter.

### Precise theorem targets

Work with concrete finite-dimensional real vector spaces `Fin n → ℝ` and score maps `Fin n → ℝ → Fin c → ℝ` represented as functions on coordinates. Use the `‖·‖∞` norm on `Fin n → ℝ`, implemented concretely as a supremum over coordinates if needed.

A convenient starting setup is:

```lean
def LinftyNorm {n : ℕ} (x : Fin n → ℝ) : ℝ :=
  Finset.sup Finset.univ (fun i => |x i|)

def scoreMargin {c : ℕ} (y : Fin c) (f : (Fin n → ℝ) → Fin c → ℝ) (x : Fin n → ℝ) : ℝ :=
  f x y - Finset.sup (Finset.univ.erase y) (fun j => f x j)

def ResidualBlock (n : ℕ) :=
  (Fin n → ℝ) → (Fin n → ℝ)

def residualComp {n : ℕ} : List (ResidualBlock n) → ResidualBlock n
| [] => id
| R :: Rs => residualComp Rs ∘ R
```

For the residual architecture, use blocks of the form
```lean
R i x = x + g i x
```
where each `g i` has a certified `L∞` Lipschitz constant `K i`, and where the tropical score map after composition admits a tropical complexity parameter `D_res`.

The first main theorem should have a type essentially of the following form:

```lean
theorem residual_robust_radius
  {n c : ℕ} [NeZero c]
  (blocks : List ((Fin n → ℝ) → (Fin n → ℝ)))
  (K : ℕ → ℝ)
  (f : (Fin n → ℝ) → Fin c → ℝ)
  (y : Fin c) (x : Fin n → ℝ)
  (Kres Dres margin : ℝ)
  (hcomp : ∀ u, f u = f ((residualComp blocks) u)) -- or fold the classifier into the last map
  (hmargin : margin = scoreMargin y f x)
  (hmargin_pos : 0 < margin)
  (hKres : 0 ≤ Kres)
  (hDres : 0 < Dres)
  (hblocks_lip :
    ∀ i < blocks.length, ∀ u v,
      LinftyNorm (blocks.get ⟨i, by simpa using ‹i < blocks.length›⟩ u -
                  blocks.get ⟨i, by simpa using ‹i < blocks.length›⟩ v)
      ≤ (1 + K i) * LinftyNorm (u - v))
  (hscore_lip :
    ∀ u v,
      |scoreMargin y f u - scoreMargin y f v|
      ≤ (2 * Kres * Dres) * LinftyNorm (u - v))
  :
  ∀ η : Fin n → ℝ,
    LinftyNorm η < margin / (2 * Kres * Dres) →
    ∀ j : Fin c, j ≠ y → f (x + η) j < f (x + η) y
```

A more usable equivalent conclusion is classification preservation:

```lean
theorem residual_certified_argmax
  {n c : ℕ} [NeZero c]
  (f : (Fin n → ℝ) → Fin c → ℝ)
  (y : Fin c) (x : Fin n → ℝ)
  (Kres Dres : ℝ)
  (hDres_pos : 0 < Dres)
  (hKres_nonneg : 0 ≤ Kres)
  (hmargin_pos : 0 < scoreMargin y f x)
  (hmargin_lip :
    ∀ u v,
      |scoreMargin y f u - scoreMargin y f v|
        ≤ (2 * Kres * Dres) * LinftyNorm (u - v)) :
  ∀ η : Fin n → ℝ,
    LinftyNorm η < scoreMargin y f x / (2 * Kres * Dres) →
    0 < scoreMargin y f (x + η)
```

This is the exact residual analogue of the plain certificate `r* = margin / (2 K d)`: once you have a margin-Lipschitz estimate with constant `2 * Kres * Dres`, the proof should be a sharp one-line contradiction argument from positivity of the perturbed margin.

The second main theorem should identify the compositional residual Lipschitz constant in the identity-skip case:

```lean
theorem residual_block_lipschitz
  {n : ℕ}
  (g : List ((Fin n → ℝ) → (Fin n → ℝ)))
  (K : ℕ → ℝ)
  (hgi :
    ∀ i < g.length, ∀ u v,
      LinftyNorm (g.get ⟨i, by simpa using ‹i < g.length›⟩ u -
                  g.get ⟨i, by simpa using ‹i < g.length›⟩ v)
      ≤ K i * LinftyNorm (u - v)) :
  ∀ i < g.length, ∀ u v,
    LinftyNorm
      ((fun x => x + g.get ⟨i, by simpa using ‹i < g.length›⟩ x) u -
       (fun x => x + g.get ⟨i, by simpa using ‹i < g.length›⟩ x) v)
    ≤ (1 + K i) * LinftyNorm (u - v)
```

and then the composition theorem:

```lean
theorem residual_comp_lipschitz_product
  {n : ℕ}
  (R : List ((Fin n → ℝ) → (Fin n → ℝ)))
  (L : ℕ → ℝ)
  (hLip :
    ∀ i < R.length, ∀ u v,
      LinftyNorm (R.get ⟨i, by simpa using ‹i < R.length›⟩ u -
                  R.get ⟨i, by simpa using ‹i < R.length›⟩ v)
      ≤ L i * LinftyNorm (u - v)) :
  ∀ u v,
    LinftyNorm ((residualComp R) u - (residualComp R) v)
      ≤ ((R.enum.foldl (fun acc p => acc * L p.1) 1)) * LinftyNorm (u - v)
```

In the identity-skip specialization, instantiate `L i = 1 + K i` and derive
```lean
∏ i, (1 + K i)
```
as the certified global `L∞` constant.

A third theorem should formalize stability under insertion of zero residual blocks. If a block is literally the identity map, the certificate should not worsen.

```lean
theorem zero_residual_insertion_invariant
  {n : ℕ}
  (R : List ((Fin n → ℝ) → (Fin n → ℝ)))
  (pos : ℕ)
  (hpos : pos ≤ R.length) :
  residualComp (R.take pos ++ [id] ++ R.drop pos) = residualComp R
```

At the level of constants, prove the multiplicative factor is unchanged if the inserted block has `K = 0`:

```lean
theorem residual_product_insert_zero
  (Ks : List ℝ) (pos : ℕ) (hpos : pos ≤ Ks.length) :
  ((Ks.take pos ++ [0] ++ Ks.drop pos).map (fun K => 1 + K)).prod
    = (Ks.map (fun K => 1 + K)).prod
```

Finally, formalize a residual refinement monotonicity statement. If one residual block is split into two consecutive residual blocks whose realized composition equals the original block, the new certificate is controlled explicitly. A workable theorem is:

```lean
theorem residual_refinement_certificate
  {n : ℕ}
  (R S T : (Fin n → ℝ) → (Fin n → ℝ))
  (L₁ L₂ L : ℝ)
  (hST : S ∘ T = R)
  (hLipS : ∀ u v, LinftyNorm (S u - S v) ≤ L₁ * LinftyNorm (u - v))
  (hLipT : ∀ u v, LinftyNorm (T u - T v) ≤ L₂ * LinftyNorm (u - v))
  (hLipR : ∀ u v, LinftyNorm (R u - R v) ≤ L * LinftyNorm (u - v))
  :
  L ≤ L₁ * L₂
```

and then deduce that the refined certificate radius is at least
```lean
margin / (2 * Kres' * Dres')
```
with `Kres' * Dres' ≤ C * (Kres * Dres)` for an explicit `C`, ideally `C = 1` in exact-zero or exact-factorization cases.

### Proof strategy

1. **Prove the basic residual block Lipschitz estimate**
   For a single block `R(x) = x + g(x)`, use the triangle inequality:
   ```lean
   ‖(u + g u) - (v + g v)‖∞ ≤ ‖u - v‖∞ + ‖g u - g v‖∞ ≤ (1 + K) ‖u - v‖∞.
   ```
   In Lean, this will likely require a concrete lemma of the form
   ```lean
   LinftyNorm (a + b) ≤ LinftyNorm a + LinftyNorm b
   ```
   and then algebra on `ℝ`.

2. **Compose blockwise bounds multiplicatively**
   Prove by induction on the list of residual blocks that Lipschitz constants multiply under composition. The induction step is:
   ```lean
   ‖(Rtail ∘ Rhead) u - (Rtail ∘ Rhead) v‖∞
     ≤ Ltail * ‖Rhead u - Rhead v‖∞
     ≤ (Ltail * Lhead) * ‖u - v‖∞.
   ```
   This is the clean mechanism behind the sharpened identity-skip bound
   ```lean
   Kres = ∏ i, (1 + K_i).
   ```

3. **Transfer the network Lipschitz control to margin Lipschitz control**
   The margin function
   ```lean
   m_y(x) = f_y(x) - max_{j ≠ y} f_j(x)
   ```
   is controlled by score perturbation bounds. The key deterministic lemma is:
   ```lean
   |m_y(u) - m_y(v)| ≤ |f_y(u) - f_y(v)| + |max_{j≠y} f_j(u) - max_{j≠y} f_j(v)|.
   ```
   Then bound the `max` term by the supremum of coordinatewise score changes. This is where the factor `2` comes from. If the catalog already has a plain-network margin perturbation lemma, reuse it with the new residual `Kres * Dres` constant.

4. **Derive the certified radius by a positivity argument**
   Once you have
   ```lean
   |m_y(x + η) - m_y(x)| ≤ (2 * Kres * Dres) * ‖η‖∞,
   ```
   and
   ```lean
   ‖η‖∞ < m_y(x) / (2 * Kres * Dres),
   ```
   conclude
   ```lean
   m_y(x + η) > 0
   ```
   by strict inequality arithmetic. Then unfold `scoreMargin` to show every competing class score remains strictly below the true class score.

5. **Show skip-connection stability and refinement monotonicity**
   For insertion of an identity block, prove equality of realized maps by list decomposition and simplification of composition with `id`. For the certificate constants, use `1 + 0 = 1`, so the multiplicative Lipschitz factor is unchanged. For block splitting, prove the refined block realizes the same map and compare the old and new multiplicative constants; the generic bound is multiplicative subadditivity, while exact-zero residual insertions give equality.

### Concrete supporting lemmas worth proving first

These will likely make the main theorem much easier to formalize:

```lean
theorem linfty_triangle {n : ℕ} (u v : Fin n → ℝ) :
  LinftyNorm (u + v) ≤ LinftyNorm u + LinftyNorm v
```

```lean
theorem linfty_sub_le {n : ℕ} (u v : Fin n → ℝ) :
  LinftyNorm (u - v) = LinftyNorm (fun i => u i - v i)
```

```lean
theorem max_erase_lipschitz
  {c : ℕ} [NeZero c] (y : Fin c) (a b : Fin c → ℝ) :
  |Finset.sup (Finset.univ.erase y) a - Finset.sup (Finset.univ.erase y) b|
    ≤ Finset.sup (Finset.univ.erase y) (fun j => |a j - b j|)
```

```lean
theorem scoreMargin_lipschitz_of_score_lipschitz
  {n c : ℕ} [NeZero c]
  (f : (Fin n → ℝ) → Fin c → ℝ)
  (y : Fin c)
  (L : ℝ)
  (hL :
    ∀ j u v, |f u j - f v j| ≤ L * LinftyNorm (u - v)) :
  ∀ u v, |scoreMargin y f u - scoreMargin y f v|
    ≤ (2 * L) * LinftyNorm (u - v)
```

```lean
theorem positive_margin_implies_correct
  {n c : ℕ} [NeZero c]
  (f : (Fin n → ℝ) → Fin c → ℝ)
  (y : Fin c) (x : Fin n → ℝ)
  (h : 0 < scoreMargin y f x) :
  ∀ j : Fin c, j ≠ y → f x j < f x y
```

### Why this matters

This theorem is the natural next step in the tropical robustness program. The existing certification machinery for plain feedforward ReLU networks does not yet capture the architecture that dominates modern practice: residual networks with identity skips. A formal theorem showing that skip connections preserve a nontrivial tropical robustness certificate does three important things:

1. It extends the current tropical ReLU theory from sequential composition to residual composition, which is mathematically nontrivial because the map is now `id + g` rather than just `g`.
2. It gives a certified robustness bound that reflects the architecture correctly: degradation is controlled by `∏ (1 + K_i)` rather than a crude flattening argument, and zero-residual insertions are provably harmless.
3. It creates a reusable formal interface between tropical degree bounds and residual Lipschitz calculus, which should be the right foundation for later results on deeper residual architectures, certified robustness under architectural refinement, and eventually tropical analyses of transformers or attention-like skip structures.

### Suggested file structure

Place the main development in:

```lean
MachineLearning/Neural/TropicalResidualRobustness.lean
```

A sensible theorem progression is:

1. `linfty_triangle`
2. `residual_block_lipschitz`
3. `residual_comp_lipschitz_product`
4. `scoreMargin_lipschitz_of_score_lipschitz`
5. `residual_certified_argmax`
6. `zero_residual_insertion_invariant`
7. `residual_product_insert_zero`
8. `residual_refinement_certificate`

If the full tropical degree formalization `D_res` is too heavy for one pass, isolate it behind a hypothesis first:
```lean
(hscore_lip : ∀ u v, |scoreMargin y f u - scoreMargin y f v| ≤ (2 * Kres * Dres) * LinftyNorm (u - v))
```
Then prove the clean certified radius theorem unconditionally from that hypothesis, and only afterwards derive `hscore_lip` from the residual tropicalization lemmas. This keeps the hard tropical-combinatorial part modular while still delivering a rigorous, useful main theorem.

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
