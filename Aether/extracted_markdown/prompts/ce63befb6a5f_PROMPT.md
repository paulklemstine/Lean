## Research Task: Quantitative algebraic-compositional universal approximation for EML networks on compact metric spaces

Research Mode: PROVE

Establish a compositional upgrade of the existing quantitative Stone–Weierstrass/EML density theory: not only can a single EML block approximate scalar continuous functions on a compact space, but finite compositions of such approximants approximate deep architectures with explicit error propagation and quantitative complexity bounds. The key new ingredient is a uniform-norm perturbation theory for composition, followed by a telescoping estimate over depth.

### Precise theorem targets

Work first in a concrete, Lean-friendly setting with compact domains realized as closed bounded subsets of Euclidean space, e.g. `Set.Icc (a : ℝ) b`, finite products thereof, or more generally a compact type `[TopologicalSpace K] [CompactSpace K]`. If the existing EML approximation theorems are already stated for `C(K, ℝ)`, keep that generality; otherwise specialize to a compact interval/cube and prove the compositional theorem there.

A good scalar composition-stability lemma is:

```lean
theorem comp_supNorm_le_of_lipschitz
    {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]
    {K : Set α} {g ĝ : α → β} {Φ : β → ℝ} {L : ℝ}
    (hL : LipschitzWith (ENNReal.ofReal L) Φ)
    (hK : ∀ x ∈ K, g x = g x) :
    ∀ x ∈ K, |Φ (g x) - Φ (ĝ x)| ≤ L * dist (g x) (ĝ x)
```

but for network composition you really want the vector-valued form:

```lean
theorem sup_dist_comp_le_lipschitz
    {α β γ : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ]
    {K : Set α} {g ĝ : α → β} {Φ : β → γ} {L : ℝ}
    (hΦ : LipschitzWith (ENNReal.ofReal L) Φ) :
    (∀ x ∈ K, dist (Φ (g x)) (Φ (ĝ x)) ≤ L * dist (g x) (ĝ x))
```

and then a uniform version over compact domains:

```lean
theorem supNorm_comp_le_lipschitz
    {α β γ : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ]
    {K : Set α} {g ĝ : α → β} {Φ : β → γ} {L : ℝ}
    (hΦ : LipschitzWith (ENNReal.ofReal L) Φ) :
    (sSup {r : ℝ | ∃ x ∈ K, r = dist (Φ (g x)) (Φ (ĝ x))})
      ≤ L * (sSup {r : ℝ | ∃ x ∈ K, r = dist (g x) (ĝ x)})
```

If `sSup`-based statements are too cumbersome in the current library, reformulate using `Bornology.IsVonNBounded`, `dist`, or a bespoke “uniform error on `K`” predicate:

```lean
def UniformApproxOn {α β : Type*} [PseudoMetricSpace β]
    (K : Set α) (f g : α → β) (ε : ℝ) : Prop :=
  ∀ x ∈ K, dist (f x) (g x) ≤ ε
```

Then prove the clean compositional estimate:

```lean
theorem UniformApproxOn.comp
    {α β γ : Type*} [PseudoMetricSpace β] [PseudoMetricSpace γ]
    {K : Set α} {f g : α → β} {Φ : β → γ} {ε L : ℝ}
    (hfg : UniformApproxOn K f g ε)
    (hΦ : LipschitzWith (ENNReal.ofReal L) Φ) :
    UniformApproxOn K (fun x => Φ (f x)) (fun x => Φ (g x)) (L * ε)
```

Next prove a two-stage telescoping lemma, the basic engine for depth:

```lean
theorem UniformApproxOn.comp₂
    {α β γ : Type*} [PseudoMetricSpace β] [PseudoMetricSpace γ]
    {K : Set α}
    {g ĝ : α → β} {Φ Φ̂ : β → γ}
    {ε₁ ε₂ L : ℝ}
    (hg : UniformApproxOn K g ĝ ε₁)
    (hΦ : LipschitzWith (ENNReal.ofReal L) Φ)
    (hΦ̂ : ∀ y, dist (Φ y) (Φ̂ y) ≤ ε₂) :
    UniformApproxOn K (fun x => Φ (g x)) (fun x => Φ̂ (ĝ x)) (L * ε₁ + ε₂)
```

This is the exact formalization of the informal bound `ε₂ + L ε₁`.

Then iterate this to depth `n`. A robust finite-family version is:

```lean
theorem UniformApproxOn.comp_list
    {α : Type*} {β : ℕ → Type*}
    [∀ i, PseudoMetricSpace (β i)]
    (n : ℕ)
    (K : Set (β 0))
    (Φ  : ∀ i : Fin n, β i → β i.succ)
    (Φ̂ : ∀ i : Fin n, β i → β i.succ)
    (L  : ∀ i : Fin n, ℝ)
    (ε  : ∀ i : Fin n, ℝ)
    (hLip : ∀ i, LipschitzWith (ENNReal.ofReal (L i)) (Φ i))
    (hApprox : ∀ i y, dist (Φ i y) (Φ̂ i y) ≤ ε i) :
    UniformApproxOn K
      (fun x => (Fin.foldl n Φ x))
      (fun x => (Fin.foldl n Φ̂ x))
      (((Finset.univ : Finset (Fin n)).sum fun i =>
          ε i * ∏ j in (Finset.univ.filter fun j => i.1 < j.1), L j))
```

You may need to replace this with a recursive theorem over `List` or `Nat.rec` if dependent codomains are too painful. A simpler non-dependent same-space version is perfectly acceptable:

```lean
theorem UniformApproxOn.iterate_layers
    {α : Type*} [PseudoMetricSpace α]
    (K : Set α)
    (Φ Φ̂ : Fin n → α → α)
    (L ε : Fin n → ℝ)
    (hLip : ∀ i, LipschitzWith (ENNReal.ofReal (L i)) (Φ i))
    (hApprox : ∀ i x, dist (Φ i x) (Φ̂ i x) ≤ ε i) :
    UniformApproxOn K
      (fun x => ((List.ofFn Φ).foldr (fun φ acc => φ ∘ acc) id x))
      (fun x => ((List.ofFn Φ̂).foldr (fun φ acc => φ ∘ acc) id x))
      ((Finset.univ : Finset (Fin n)).sum fun i =>
        ε i * ∏ j in (Finset.univ.filter fun j => i.1 < j.1), L j)
```

Once the perturbation/telescoping theorem is in place, connect it to EML approximation rates. Introduce an abstract quantitative approximation hypothesis for a function class `A`:

```lean
def HasApproxRate
    {K : Type*} [TopologicalSpace K]
    (A : Set (ContinuousMap K ℝ))
    (w : ℝ → ℕ) : Prop :=
  ∀ (f : ContinuousMap K ℝ) {ε : ℝ}, 0 < ε →
    ∃ g ∈ A, ‖f - g‖ ≤ ε
```

If the catalog already has a richer notion of EML realizability with width bound, use that directly instead of inventing a new one. The theorem should then say: coordinatewise quantitative density plus Lipschitz control implies deep universal approximation.

A scalar-output version:

```lean
theorem exists_eml_deep_approx_scalar
    {K : Type*} [TopologicalSpace K] [CompactSpace K]
    [PseudoMetricSpace K]
    (A : Set (ContinuousMap K ℝ))
    (w : ℝ → ℕ)
    (hA_unital : ...)
    (hA_subalg : ...)
    (hA_sep : ...)
    (hDense : HasApproxRate A w)
    {n : ℕ}
    (Φ : Fin n → ContinuousMap ℝ ℝ)
    (hLip : ∀ i, ∃ L ≥ 0, LipschitzWith (ENNReal.ofReal L) (Φ i))
    {ε : ℝ} (hε : 0 < ε) :
    ∃ N, N ∈ DeepEMLRealization A n ∧
      ‖((fun x => (Fin.foldl (fun y i => Φ i y) x)) - N)‖ ≤ ε
```

A more meaningful theorem for hidden layers is vector-valued. The most practical Lean representation is coordinatewise via `Fin m → ℝ`:

```lean
theorem exists_eml_deep_approx_fin
    {K : Type*} [TopologicalSpace K] [CompactSpace K] [PseudoMetricSpace K]
    (A : Set (ContinuousMap K ℝ))
    (w : ℝ → ℕ)
    (hDense : HasApproxRate A w)
    {m : ℕ}
    {F : ContinuousMap K (Fin m → ℝ)}
    {ε : ℝ} (hε : 0 < ε) :
    ∃ G : Fin m → ContinuousMap K ℝ,
      (∀ i, G i ∈ A) ∧
      (∀ x, dist (F x) (fun i => G i x) ≤ ε)
```

This coordinatewise lemma is essential: it upgrades scalar density to finite-dimensional output density. After that, prove the hidden-layer/product-space lemma needed for internal maps whose domain is itself a finite-dimensional Euclidean coordinate space:

```lean
theorem HasApproxRate.fin_product
    {K : Type*} [TopologicalSpace K] [CompactSpace K] [PseudoMetricSpace K]
    (A : Set (ContinuousMap K ℝ))
    (w : ℝ → ℕ)
    (hDense : HasApproxRate A w)
    (m : ℕ) :
    ∀ (F : ContinuousMap K (Fin m → ℝ)) {ε : ℝ}, 0 < ε →
      ∃ G : Fin m → ContinuousMap K ℝ,
        (∀ i, G i ∈ A) ∧
        ∀ x, dist (F x) (fun i => G i x) ≤ ε
```

If product-space approximation is already available from the quantitative Stone–Weierstrass development, strengthen it to an explicit coordinate error allocation such as `ε / m` per coordinate and derive the final `ℓ∞` or Euclidean bound.

Finally, state the end-to-end compositional universal approximation theorem in the strongest form you can support:

```lean
theorem deep_eml_universal_approx_explicit
    {d : ℕ}
    {X : Fin (d+1) → Type*}
    [∀ i, PseudoMetricSpace (X i)]
    [∀ i, TopologicalSpace (X i)]
    [CompactSpace (X 0)]
    (A : ∀ i : Fin d, Set (ContinuousMap (X i) ℝ))
    (w : ∀ i : Fin d, ℝ → ℕ)
    (Φ : ∀ i : Fin d, ContinuousMap (X i) (X i.succ))
    (L : ∀ i : Fin d, ℝ)
    (hLip : ∀ i, LipschitzWith (ENNReal.ofReal (L i)) (Φ i))
    (hDense : ∀ i, HasApproxRate (A i) (w i))
    {ε : ℝ} (hε : 0 < ε) :
    ∃ N,
      N ∈ DeepEMLNetworkRealizes A d ∧
      UniformApproxOn Set.univ
        (fun x => Fin.foldl d Φ x)
        N
        ε
```

In practice you may need a non-dependent simplification where all layers live in `Fin m → ℝ` for fixed `m`; that is still a substantial theorem and is likely the best target for Mathlib ergonomics.

### Concrete proof strategy

1. **Define and stabilize a uniform approximation predicate.**  
   Introduce `UniformApproxOn K f g ε := ∀ x ∈ K, dist (f x) (g x) ≤ ε`. Prove basic monotonicity and triangle-inequality lemmas:
   - `UniformApproxOn.mono`
   - `UniformApproxOn.triangle`
   - `UniformApproxOn.comp` under `LipschitzWith`.
   The key proof is one line from `LipschitzWith` plus arithmetic: `dist (Φ (f x)) (Φ (g x)) ≤ L * dist (f x) (g x) ≤ L * ε`.

2. **Prove the telescoping composition estimate.**  
   For one layer,
   ```lean
   dist (Φ (g x)) (Φ̂ (ĝ x))
     ≤ dist (Φ (g x)) (Φ (ĝ x)) + dist (Φ (ĝ x)) (Φ̂ (ĝ x))
     ≤ L * dist (g x) (ĝ x) + ε₂
   ```
   then quantify uniformly on `K`. Iterate by induction on depth. The recursive error formula should be
   ```lean
   E₀ = 0,   E_{n+1} = ε_n + L_n * E_n
   ```
   and then optionally unfold this recurrence into the explicit weighted sum
   ```lean
   E_d = Σ i<d, ε_i * Π_{j : i<j<d} L_j.
   ```
   Even if the closed form is annoying in Lean, the recurrence itself is already a meaningful quantitative theorem.

3. **Upgrade scalar approximation to vector-valued approximation.**  
   For `F : K → Fin m → ℝ`, approximate each coordinate `fun x => F x i` by some `g_i ∈ A` with error budget `ε/m`, `ε/(m+1)`, or better `ε` in `ℓ∞` if you use sup norm on coordinates. Then assemble
   ```lean
   G x := fun i => g_i x
   ```
   and prove `dist (F x) (G x) ≤ ε`. This is the tensorization/product lemma needed to approximate hidden-layer maps coordinatewise. If Euclidean norm estimates are cumbersome, work with `dist = sup` on `Fin m → ℝ` or prove an explicit inequality between Euclidean and coordinatewise max norms.

4. **Approximate each layer separately using the existing quantitative EML density theorem.**  
   For each layer map `Φ_i`, choose a local error tolerance `δ_i` so that the telescoping bound yields total error `< ε`. A natural choice is backward allocation:
   ```lean
   δ_i = ε / (d * max 1 (Π_{j>i} L_j))
   ```
   or any simpler bound derived from a global Lipschitz constant. Use the existing quantitative Stone–Weierstrass/EML theorem to produce an EML realization of each coordinate of `Φ_i` within `δ_i`, and package these into an approximate layer `Φ̂_i`.

5. **Derive explicit width/depth complexity bounds.**  
   If `w_A(δ)` bounds the width needed to approximate a scalar coordinate to tolerance `δ`, then an `m_out`-coordinate layer can be realized with width at most something like
   ```lean
   m_out * w_A(δ)
   ```
   (or `Finset.sum` of per-coordinate widths). Compose over depth to obtain a network with:
   - depth exactly `d`,
   - width at layer `i` bounded by `m_{i+1} * w_i(δ_i)`,
   - final error bounded by the telescoping formula.  
   Even if the architecture datatype is not yet formalized, proving the numerical recurrence for widths alongside the approximation theorem would already be valuable.

### Lean-specific implementation advice

- Prefer `ContinuousMap` for approximation statements, but switch to plain functions when proving pointwise Lipschitz/triangle lemmas.
- If dependent families `X i` become too heavy, specialize all hidden layers to `Fin m → ℝ`. This is already expressive enough for “deep EML network on compact subsets of finite-dimensional Euclidean space.”
- Use `Fin m → ℝ` rather than matrices unless the current EML files already package layer outputs as vectors/matrices.
- For norm estimates, if `‖·‖` on function spaces is inconvenient, stay with `dist`/`UniformApproxOn` and only translate to sup norm at the end.
- For coordinate assembly, useful patterns are:
  ```lean
  fun x i => g i x
  ```
  and extensionality by `funext`.
- If product compactness is needed, finite products of compact spaces should be available; otherwise keep the domain fixed and only build vector-valued codomains coordinatewise.

### Why this matters

This theorem is the natural next step after shallow quantitative EML approximation. The existing results show density of a single algebraic activation class in `C(K, ℝ)`; what is still missing is the mathematically decisive statement that **depth preserves quantitative universality**. The compositional theorem turns scalar algebraic density into an actual network expressivity result, with explicit error propagation through Lipschitz layers and explicit width/error tradeoffs. This creates the bridge between the Stone–Weierstrass side of the project and the architecture side: once formalized, it supports future results on certified robustness, Barron-type rates for deep compositions, and quantitative separation theorems for EML networks beyond one hidden block.

A strong deliverable would be:
1. `UniformApproxOn.comp`,
2. `UniformApproxOn.comp₂`,
3. a depth-`n` telescoping theorem with recursive error,
4. a coordinatewise/vector-valued approximation lemma for `Fin m → ℝ`,
5. a final deep EML universal approximation theorem with explicit per-layer error allocation.

Even proving this first for compact intervals/cubes and fixed-width `Fin m → ℝ` hidden states would be a genuinely new and substantial extension of the current development.

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

Research domain: EML
Research mode: prove
