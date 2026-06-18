## Research Task: Vector-valued EML Stone–Weierstrass from scalar density

Work in the setting of compact Hausdorff spaces modeled in Mathlib as `X : Type*` with `[TopologicalSpace X] [CompactSpace X]`. The main objective is to lift the already-established scalar EML density theorem from `C(X, ℝ)` to finite-dimensional vector-valued codomains `Fin m → ℝ`, and then package this into a reusable approximation API for coupled outputs.

The mathematically clean core theorem should be stated for the coordinatewise class attached to a scalar function class `A : Set C(X, ℝ)`.

### Core definitions to introduce

Use the sup norm on continuous maps into finite products via the existing normed structure on `Fin m → ℝ`.

A natural coordinatewise vector class is:

```lean
def VecClass (A : Set C(X, ℝ)) (m : ℕ) : Set C(X, Fin m → ℝ) :=
  {F | ∀ i : Fin m, ((ContinuousMap.proj i).comp F) ∈ A}
```

where `ContinuousMap.proj i : C(Fin m → ℝ, ℝ)` is the `i`th coordinate projection, defined if needed by
```lean
def coordMap (i : Fin m) : C(Fin m → ℝ, ℝ) :=
  ⟨fun x => x i, continuous_apply i⟩
```
and then
```lean
((coordMap i).comp F) : C(X, ℝ).
```

If the scalar theorem in the library is phrased as density of `A` in `C(X, ℝ)`, formulate the vector theorem using `Dense` or closure equality, depending on what is already available. The strongest useful exact target is:

```lean
theorem dense_vecClass_of_dense_scalar
    {A : Set C(X, ℝ)} {m : ℕ}
    (hA_dense : Dense A) :
    Dense (VecClass A m)
```

but in practice the scalar result is likely not “`Dense A`” literally, rather “the closure of the EML-generated class is all of `C(X, ℝ)` under hypotheses.” In that case prove the closure version:

```lean
theorem closure_vecClass_eq_top_of_closure_scalar_eq_top
    {A : Set C(X, ℝ)} {m : ℕ}
    (hA : closure A = Set.univ) :
    closure (VecClass A m) = Set.univ
```

or equivalently

```lean
theorem closure_vecClass_eq_univ_of_scalar
    {A : Set C(X, ℝ)} {m : ℕ}
    (hA : ∀ f : C(X, ℝ), f ∈ closure A) :
    ∀ F : C(X, Fin m → ℝ), F ∈ closure (VecClass A m)
```

The theorem you ultimately want for the EML class itself should have the exact scalar hypotheses already used in the scalar Stone–Weierstrass file, and conclude density of the induced vector class:

```lean
theorem eml_vec_universalApprox
    {m : ℕ}
    (hm : 0 < m)
    : closure (VecClass (EMLClass X) m) = Set.univ
```

Replace `EMLClass X` by the actual scalar EML class name from the existing development.

---

## First main theorem: coordinatewise density in `C(X, Fin m → ℝ)`

The key statement is:

```lean
theorem approx_vec_of_coordwise_dense
    {A : Set C(X, ℝ)} {m : ℕ}
    (hA : ∀ f : C(X, ℝ), f ∈ closure A) :
    ∀ F : C(X, Fin m → ℝ), F ∈ closure (VecClass A m)
```

A more explicit ε-approximation form is often easier to use downstream:

```lean
theorem exists_mem_vecClass_uniformApprox
    {A : Set C(X, ℝ)} {m : ℕ}
    (hA : ∀ f : C(X, ℝ), f ∈ closure A)
    (F : C(X, Fin m → ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ G ∈ VecClass A m, ‖F - G‖ < ε
```

Here `‖F - G‖` is the uniform norm on continuous maps.

### Proof strategy
1. **Reduce to scalar coordinate approximation.**  
   For each `i : Fin m`, define the scalar coordinate
   ```lean
   fi : C(X, ℝ) := (coordMap i).comp F.
   ```
   Apply scalar density to get `gi ∈ A` approximating `fi` within `ε` or better within `ε` itself. Because `Fin m` is finite, you can choose all coordinates simultaneously by finite choice.

2. **Assemble the vector-valued approximant.**  
   Define
   ```lean
   G : C(X, Fin m → ℝ) :=
   ⟨fun x i => gi x, ...⟩
   ```
   using continuity of each `gi` and continuity into a finite product (`continuous_pi`). Then show `G ∈ VecClass A m` by construction.

3. **Control the uniform norm coordinatewise.**  
   Prove a norm estimate of the form
   ```lean
   ‖F - G‖ ≤ max' (Finset.univ.image (fun i => ‖fi - gi‖)) ...
   ```
   or more simply use the pointwise estimate
   ```lean
   ‖F x - G x‖ ≤ C * max_i |fi x - gi x|
   ```
   and in the sup norm for `Fin m → ℝ`, the coordinatewise bound immediately gives
   ```lean
   ‖F x - G x‖ ≤ ε
   ```
   if every coordinate error is `< ε`. If the ambient norm on `Fin m → ℝ` is Euclidean, choose scalar accuracy `ε / √m` and use
   ```lean
   ‖v‖ ≤ Real.sqrt m * max i, |v i|
   ```
   or the standard finite-dimensional estimate available in Mathlib. If a direct max norm is easier, define an auxiliary theorem using pointwise `dist` and then transfer to the library norm. The important point is that finite-dimensional norms are equivalent, so any explicit estimate suffices.

4. **Conclude membership in the closure.**  
   Use the metric characterization of closure:
   ```lean
   mem_closure_iff.2
   ```
   or `Metric.mem_closure_iff` / `mem_closure_iff_nhds` depending on the imported API. The ε-approximation theorem is the most robust route.

5. **Handle the degenerate case `m = 0`.**  
   This case is trivial since `Fin 0 → ℝ` is a singleton. It is often easiest to prove the theorem for all `m` and let the coordinatewise arguments over `Fin m` handle `m = 0` automatically, but if finite maxima or `sqrt m` estimates become awkward, split on `m = 0` and discharge separately.

### Why this matters
This is the canonical finite-dimensional upgrade of the scalar EML Stone–Weierstrass theorem. It shows that once the scalar class is closed under the right lattice/algebra/postcomposition operations, no new approximation obstruction appears for vector outputs: multiclass classifiers, controllers, and learned dynamical systems are all reduced to the scalar approximation engine already formalized. This is the correct formal bridge from scalar universality to practically relevant architectures.

---

## Second main theorem: approximation from shared scalar features via continuous output coupling

The coordinatewise theorem above should then be strengthened to a “shared representation + continuous readout” statement. Introduce a coupled-output class generated from finitely many scalar features:

```lean
def CoupledVecClass (A : Set C(X, ℝ)) (m : ℕ) : Set C(X, Fin m → ℝ) :=
  {F | ∃ k : ℕ, ∃ g : Fin k → C(X, ℝ),
      (∀ j, g j ∈ A) ∧
      ∃ φ : C((Fin k → ℝ), (Fin m → ℝ)),
        F = φ.comp
          ⟨fun x j => g j x, by
             simpa using continuous_pi (fun j => (g j).continuous)⟩ }
```

This expresses a vector output obtained by first computing finitely many scalar features from `A`, then applying a continuous output coupling `φ`.

The theorem to prove is that this coupled class is also dense:

```lean
theorem dense_coupledVecClass_of_dense_scalar
    {A : Set C(X, ℝ)} {m : ℕ}
    (hA : ∀ f : C(X, ℝ), f ∈ closure A) :
    ∀ F : C(X, Fin m → ℝ), F ∈ closure (CoupledVecClass A m)
```

### Proof strategy
1. **Show `VecClass A m ⊆ CoupledVecClass A m`.**  
   Take `k = m`, use the coordinates themselves as features, and let `φ` be the identity map on `Fin m → ℝ`. This is the key embedding lemma:
   ```lean
   theorem vecClass_subset_coupledVecClass :
     VecClass A m ⊆ CoupledVecClass A m
   ```

2. **Transfer density along inclusion.**  
   Once the previous theorem gives density of `VecClass A m`, conclude density of `CoupledVecClass A m` from monotonicity of closure:
   ```lean
   closure_mono
   ```
   or directly from `Dense.mono`.

3. **Optional stronger closure property.**  
   If the scalar class `A` is itself closed under continuous scalar postcomposition, prove a finite-feature closure lemma showing that the coupled class is stable under postcomposition by continuous maps `ψ : C((Fin m → ℝ), (Fin n → ℝ))`. This is useful for downstream simplex/projection arguments.

### Why this matters
This theorem matches the architecture used in actual EML models: one shared latent representation feeds multiple outputs through a continuous readout. The theorem shows that vector universality does not require independent coordinatewise networks; shared-feature networks are already enough. This is the exact abstraction needed for multiclass prediction and low-dimensional control outputs.

---

## Third main theorem: compact target subsets stable under a continuous retraction

Now move beyond unconstrained codomain `ℝ^m` to constrained compact targets `K ⊆ Fin m → ℝ`. The right formalization is to use a continuous retraction from ambient space onto `K`.

A useful theorem schema is:

```lean
theorem dense_into_compactRange_of_retraction
    {A : Set C(X, ℝ)} {m : ℕ}
    (hA : ∀ f : C(X, ℝ), f ∈ closure A)
    {r : C(Fin m → ℝ, Fin m → ℝ)}
    {K : Set (Fin m → ℝ)}
    (hrK : ∀ y ∈ K, r y = y)
    (hrange : Set.range r ⊆ K) :
    ∀ F : C(X, Fin m → ℝ), (∀ x, F x ∈ K) →
      F ∈ closure {G : C(X, Fin m → ℝ) | ∀ x, G x ∈ K ∧ G ∈ CoupledVecClass A m}
```

A cleaner version is to define the constrained class
```lean
def KValuedCoupledVecClass (A : Set C(X, ℝ)) (K : Set (Fin m → ℝ)) : Set C(X, Fin m → ℝ) :=
  {F | F ∈ CoupledVecClass A m ∧ ∀ x, F x ∈ K}
```
and prove density of this class in the subspace of continuous maps with image in `K`.

### Proof strategy
1. **Approximate in ambient space first.**  
   Use the previous theorem to approximate the target `F : C(X, Fin m → ℝ)` by some `G ∈ CoupledVecClass A m`.

2. **Project back into `K`.**  
   Replace `G` by `r.comp G`. Since `r` is continuous and `CoupledVecClass` is built to be closed under continuous vector postcomposition, `r.comp G` remains in the coupled class.

3. **Use the retraction identity on the target.**  
   Since `F x ∈ K`, one has `r (F x) = F x`. Hence
   ```lean
   r.comp F = F.
   ```
   This is the formal mechanism that keeps the target fixed while forcing approximants back into `K`.

4. **Control the error using uniform continuity of `r`.**  
   On compact subsets of `ℝ^m`, continuity implies uniform continuity. If `G` is close to `F`, then `r ∘ G` is close to `r ∘ F = F`. In Lean, use the uniform continuity API for continuous maps on compact spaces, or if needed, a local argument with `Metric.continuous_iff`. Since the domain of `r` can be restricted to a compact neighborhood containing all approximants, compactness is available.

### Why this matters
Many vector-valued learning tasks have intrinsic output constraints: probability simplices, boxes, positive cones, and normalized control sets. This theorem converts ambient Euclidean universality into constrained-target universality by a clean retract argument, and it is exactly the right stepping stone toward certified multiclass robustness and constrained approximation.

---

## Fourth main theorem: simplex-valued approximation

Specialize the retraction theorem to the standard simplex. Define for `m : ℕ`:
```lean
def simplex (m : ℕ) : Set (Fin m → ℝ) :=
  {p | (∀ i, 0 ≤ p i) ∧ (∑ i, p i = 1)}
```

A useful target theorem is:

```lean
theorem dense_simplexValued_eml
    {m : ℕ}
    (hm : 0 < m) :
    ∀ F : C(X, Fin m → ℝ), (∀ x, F x ∈ simplex m) →
      F ∈ closure
        {G : C(X, Fin m → ℝ) |
          G ∈ CoupledVecClass (EMLClass X) m ∧
          ∀ x, G x ∈ simplex m}
```

To prove this, it is enough to construct a continuous map
```lean
simplexProj : C(Fin m → ℝ, Fin m → ℝ)
```
with image in `simplex m` and identity on `simplex m`.

The cleanest candidate is the softmax-style normalization of positive coordinates:
```lean
simplexProj y i = Real.exp (y i) / ∑ j, Real.exp (y j)
```
for `m > 0`. This is continuous and lands in the open simplex, hence in the closed simplex. It is not literally the identity on the simplex, so it gives surjectivity onto the interior but not a retraction. For the theorem above you want an actual retraction or at least a continuous “repair map” that is uniformly close to the identity on simplex-valued targets after a preliminary approximation. A more retraction-like option is Euclidean projection onto the simplex, but that is analytically heavier.

A formally easier theorem is therefore an **interior-simplex approximation** statement:

```lean
def softmaxMap (m : ℕ) (hm : 0 < m) : C(Fin m → ℝ, Fin m → ℝ) := ...

theorem softmaxMap_mem_simplex
    {m : ℕ} (hm : 0 < m) (y : Fin m → ℝ) :
    softmaxMap m hm y ∈ simplex m
```

and then

```lean
theorem dense_simplex_outputs_via_softmax
    {m : ℕ} (hm : 0 < m)
    (hA : ∀ f : C(X, ℝ), f ∈ closure A) :
    closure {G | ∃ H ∈ CoupledVecClass A m, G = (softmaxMap m hm).comp H}
      = Set.univ
```

for targets whose image lies in the interior of the simplex and is represented after log-ratio coordinates. A particularly precise and provable variant is:

```lean
theorem approx_simplex_interior_of_logitFactorization
    {m : ℕ} (hm : 0 < m)
    {F : C(X, Fin m → ℝ)}
    (hF : ∀ x, F x ∈ simplex m)
    (hpos : ∀ x i, 0 < F x i) :
    F ∈ closure {G | ∃ H ∈ CoupledVecClass A m, G = (softmaxMap m hm).comp H}
```

because strictly positive simplex-valued maps admit continuous logit coordinates relative to one reference class.

### Proof strategy
1. **For the strict interior theorem, build logits explicitly.**  
   Fix a base coordinate `i₀ : Fin m` (available from `hm`). Define
   ```lean
   z x i = Real.log (F x i / F x i₀)
   ```
   on the remaining coordinates. Strict positivity ensures continuity.

2. **Approximate the logits by coupled EML maps.**  
   Apply vector density to the logit map.

3. **Recover the simplex-valued output by softmax.**  
   Show the softmax of logits exactly reconstructs `F` pointwise.

4. **Conclude by composition closure.**  
   Since softmax is continuous, composition with a coupled approximant remains in the coupled class.

### Why this matters
This is the right multiclass specialization: simplex-valued outputs correspond to class-probability vectors. Even the interior-simplex theorem is already a substantial and useful universality result, and it gives a formally tractable route to probability-valued EML models without needing a full metric projection onto the simplex.

---

## Key supporting lemmas to prove first

These lemmas will likely be the real Lean bottlenecks, so isolate them early.

### 1. Coordinate assembly lemma
```lean
theorem exists_continuousMap_of_coords
    {m : ℕ} (g : Fin m → C(X, ℝ)) :
    ∃ G : C(X, Fin m → ℝ), ∀ i x, G x i = g i x
```

This should be proved by `refine ⟨⟨fun x i => g i x, ?_⟩, ?_⟩` and `continuous_pi`.

### 2. Membership characterization for `VecClass`
```lean
theorem mem_VecClass_iff
    {A : Set C(X, ℝ)} {m : ℕ} {F : C(X, Fin m → ℝ)} :
    F ∈ VecClass A m ↔ ∀ i : Fin m, ((coordMap i).comp F) ∈ A
```

This is mostly definitional but useful for rewriting.

### 3. Coordinatewise sup-norm control
Prove a finite-dimensional estimate suitable for approximation transfer. One robust statement is:

```lean
theorem norm_le_of_coord_sup_bound
    {m : ℕ} {v : Fin m → ℝ} {ε : ℝ}
    (h : ∀ i, |v i| ≤ ε) :
    ‖v‖ ≤ (m : ℝ) * ε
```

or, if available more sharply,
```lean
theorem norm_le_sqrt_card_mul_max
    {m : ℕ} {v : Fin m → ℝ} :
    ‖v‖ ≤ Real.sqrt m * ‖v‖∞
```
with an appropriate sup norm notion. Any explicit linear bound is enough for density: simply approximate each coordinate within `ε / C`.

Then lift pointwise to continuous maps:
```lean
theorem norm_continuousMap_le_of_coord_bound
    {m : ℕ} {F G : C(X, Fin m → ℝ)} {δ : ℝ}
    (h : ∀ x i, |F x i - G x i| ≤ δ) :
    ‖F - G‖ ≤ (m : ℝ) * δ
```

### 4. Inclusion of coordinatewise class into coupled class
```lean
theorem VecClass_subset_CoupledVecClass
    {A : Set C(X, ℝ)} {m : ℕ} :
    VecClass A m ⊆ CoupledVecClass A m
```

Use `k = m`, features `g i = (coordMap i).comp F`, and `φ = ContinuousMap.id _`.

### 5. Closure under continuous output postcomposition
If not already automatic from the definition, prove:
```lean
theorem comp_mem_CoupledVecClass
    {A : Set C(X, ℝ)} {m n : ℕ}
    {F : C(X, Fin m → ℝ)} (hF : F ∈ CoupledVecClass A m)
    (ψ : C(Fin m → ℝ, Fin n → ℝ)) :
    ψ.comp F ∈ CoupledVecClass A n
```

This is essential for the compact-target and simplex arguments.

---

## Recommended theorem order

1. Define `coordMap`, `VecClass`, `CoupledVecClass`.
2. Prove coordinate assembly and coordinatewise error lemmas.
3. Prove `approx_vec_of_coordwise_dense`.
4. Deduce density of `CoupledVecClass` via inclusion.
5. Prove the retraction-based constrained-target theorem.
6. If time permits, prove the simplex/interior-simplex specialization.

This sequence gives a strong new theorem quickly, while leaving more analytic geometry of special targets as a second layer.

---

## Expected mathematical payoff

This development upgrades scalar EML universality into a genuinely usable vector-valued approximation theory. It should become the foundation for:
- multiclass classification (`Δ^(m-1)`-valued outputs),
- constrained control outputs (compact action sets),
- robustness theorems for vector predictors via coordinatewise error transfer,
- shared-latent EML architectures with continuous readout heads.

The crucial conceptual point is that the scalar Stone–Weierstrass theorem is not an endpoint: once formalized correctly, it automatically propagates through finite products and continuous output couplings. That propagation theorem is the right next result in the EML research program.

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
