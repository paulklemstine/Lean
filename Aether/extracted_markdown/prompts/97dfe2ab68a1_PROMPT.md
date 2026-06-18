## YOUR ASSIGNMENT: Functorial support duality for idempotent EML functionals via maxitive kernels and closed-set reconstruction

Work in the existing `UCTropicalFunctional` / `TropCont` / `muK` / `tropicalIntegral` infrastructure, and make the support of an upper-continuous tropical functional into a mathematically robust closed-set invariant that interacts functorially with pullback and reconstructs normalized functionals from local peak data.

### 1. Core definitions and exact formal targets

Introduce the support predicate by local nontriviality:

```lean
def supportOf {X : Type*} [TopologicalSpace X]
    (Λ : UCTropicalFunctional X) : Set X :=
  {x | ∀ U : Set X, IsOpen U → x ∈ U →
      ∃ f : TropCont X, support f ⊆ U ∧ Λ f ≠ ⊥}
```

If `support` is not yet available for `TropCont X` in the exact needed form, define an auxiliary open-vanishing support:

```lean
def TropCont.support {X : Type*} [TopologicalSpace X] (f : TropCont X) : Set X :=
  {x | f x ≠ ⊥}
```

or, if the library already uses closure of nonvanishing locus, define both and prove the comparison lemmas you need. The local definition of `supportOf` only needs a notion of “function concentrated in `U`”, so a nonclosed support is acceptable provided theorems are stated consistently.

Prove the closedness theorem by identifying the complement as the union of neighborhoods on which every supported test function is annihilated:

```lean
theorem isClosed_supportOf {X : Type*} [TopologicalSpace X]
    (Λ : UCTropicalFunctional X) :
    IsClosed (supportOf Λ)
```

A very useful equivalent characterization should also be established:

```lean
theorem mem_supportOf_iff {X : Type*} [TopologicalSpace X]
    (Λ : UCTropicalFunctional X) (x : X) :
    x ∈ supportOf Λ ↔
      ∀ U : Set X, IsOpen U → x ∈ U →
        ∃ f : TropCont X, support f ⊆ U ∧ Λ f ≠ ⊥
```

and, more importantly, the complement form:

```lean
theorem mem_compl_supportOf_iff {X : Type*} [TopologicalSpace X]
    (Λ : UCTropicalFunctional X) (x : X) :
    x ∈ (supportOf Λ)ᶜ ↔
      ∃ U : Set X, IsOpen U ∧ x ∈ U ∧
        ∀ f : TropCont X, support f ⊆ U → Λ f = ⊥
```

This is the key structural lemma behind `IsClosed`.

---

### 2. Functoriality under pullback

Assume there is already a pullback operation along a continuous map, something morally of the form
`UCTropicalFunctional.comap` or `pullbackFunctional`, and if not, define the weakest useful version. The target inequality is:

```lean
theorem support_pullback_le
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (φ : X → Y) (hφ : Continuous φ)
    (Λ : UCTropicalFunctional Y) :
    supportOf (UCTropicalFunctional.comap φ hφ Λ) ⊆ φ ⁻¹' supportOf Λ
```

If the API uses the opposite variance convention, prove the equivalent statement in that language. Also prove the pointwise contrapositive formulation, because it is often easier to use downstream:

```lean
theorem not_mem_support_pullback_of_not_mem_support
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (φ : X → Y) (hφ : Continuous φ)
    (Λ : UCTropicalFunctional Y) {x : X}
    (hx : φ x ∉ supportOf Λ) :
    x ∉ supportOf (UCTropicalFunctional.comap φ hφ Λ)
```

If additional assumptions such as injectivity, quotientness, or openness of `φ` are needed for a converse inclusion, state and prove the strongest clean theorem you can. A high-value strengthening is:

```lean
theorem support_pullback_eq
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (φ : X → Y) (hφ : Continuous φ) (hopen : IsOpenMap φ)
    (Λ : UCTropicalFunctional Y)
    (hsep : ∀ y ∈ supportOf Λ, ∃ x, φ x = y) :
    supportOf (UCTropicalFunctional.comap φ hφ Λ) = φ ⁻¹' supportOf Λ
```

If equality is too hard in full generality, isolate it as a conjecture and prove all preparatory lemmas.

---

### 3. Kernel/support duality on finite or discrete spaces

In finite/discrete spaces, push the support picture into an exact reconstruction theorem from the kernel/maxitive measure side. Define the “bot-on” predicate for a set:

```lean
def botOn {X : Type*} (Λ : UCTropicalFunctional X) (S : Set X) : Prop :=
  ∀ f : TropCont X, support f ⊆ S → Λ f = ⊥
```

Then prove that outside the support, the functional is bot on every subset; equivalently, neighborhoods disjoint from support lie in the kernel. For discrete spaces the strongest useful theorem is:

```lean
theorem kernel_eq_botOn_compl_support_discrete
    {X : Type*} [TopologicalSpace X] [DiscreteTopology X]
    [Fintype X] [DecidableEq X]
    (Λ : UCTropicalFunctional X) :
    ∀ f : TropCont X, support f ⊆ (supportOf Λ)ᶜ → Λ f = ⊥
```

A setwise version is also valuable:

```lean
theorem kernel_eq_botOn_support
    {X : Type*} [TopologicalSpace X] [DiscreteTopology X]
    [Fintype X] [DecidableEq X]
    (Λ : UCTropicalFunctional X) (S : Set X) :
    S ⊆ (supportOf Λ)ᶜ →
    ∀ f : TropCont X, support f ⊆ S → Λ f = ⊥
```

If the maxitive measure representation `μ_Λ` already exists on finite spaces, prove the sharper kernel/support equivalence:

```lean
theorem supportOf_eq_carrier_mu
    {X : Type*} [TopologicalSpace X] [DiscreteTopology X]
    [Fintype X] [DecidableEq X]
    (Λ : UCTropicalFunctional X) :
    supportOf Λ = {x | μ_Λ ({x} : Set X) ≠ ⊥}
```

or a variant with principal finite sets / atomic weights matching the actual API. This is where the support theory stops being merely topological and becomes a genuine duality theorem.

---

### 4. Peak-function reconstruction and uniqueness up to scalar

Define a “peak at `x` inside `U`” notion adapted to the tropical setting. One workable version is:

```lean
def IsPeakAt {X : Type*} [TopologicalSpace X]
    (x : X) (U : Set X) (f : TropCont X) : Prop :=
  support f ⊆ U ∧ f x ≠ ⊥
```

If the library already has stronger Urysohn-type or bump-function notions, use those instead. Then formulate a normalized uniqueness principle: two functionals with the same support and the same values on a support-detecting family of local peaks must coincide, at least after tropical scalar renormalization.

You need a concrete normalization. The cleanest finite/discrete version is to normalize by the value on the constant-zero tropical function, or by sup over singleton peaks if constants are awkward. For example:

```lean
def Normalized {X : Type*} [TopologicalSpace X]
    (Λ : UCTropicalFunctional X) : Prop :=
  Λ (0 : TropCont X) = 0
```

Then prove a finite/discrete uniqueness theorem of the following shape:

```lean
theorem support_eq_and_agree_on_peaks_imp_eq
    {X : Type*} [TopologicalSpace X] [DiscreteTopology X]
    [Fintype X] [DecidableEq X]
    {Λ Γ : UCTropicalFunctional X}
    (hΛ : Normalized Λ) (hΓ : Normalized Γ)
    (hsupp : supportOf Λ = supportOf Γ)
    (hpeak :
      ∀ x : X, x ∈ supportOf Λ →
        ∀ f : TropCont X, IsPeakAt x Set.univ f →
          Λ f = Γ f) :
    Λ = Γ
```

If exact equality is too strong before normalization is fixed, prove the scalar-twist form:

```lean
theorem support_eq_and_agree_on_peaks_imp_eq_up_to_scalar
    {X : Type*} [TopologicalSpace X] [DiscreteTopology X]
    [Fintype X] [DecidableEq X]
    {Λ Γ : UCTropicalFunctional X} :
    supportOf Λ = supportOf Γ →
    (∃ c : WithBot ℝ, ∀ f : TropCont X, Γ f = c + Λ f) ∨ Λ = Γ
```

but do not leave this vague: define the exact scalar action that exists in the current API. If the semimodule structure is additive max-plus, the correct form may be `Γ f = c ⊗ Λ f`; use the actual notation from the library.

A more mathematically powerful intermediate theorem is atomic reconstruction:

```lean
theorem eq_of_agree_on_singleton_peaks
    {X : Type*} [TopologicalSpace X] [DiscreteTopology X]
    [Fintype X] [DecidableEq X]
    {Λ Γ : UCTropicalFunctional X}
    (hconst : Λ (0 : TropCont X) = Γ (0 : TropCont X))
    (hatom : ∀ x : X, Λ (peakAt x) = Γ (peakAt x)) :
    Λ = Γ
```

where `peakAt x` is the characteristic tropical bump at `x`. If such a function does not yet exist, define it explicitly in the discrete case.

---

## PROOF STRATEGY

### A. Closedness of `supportOf`: prove the complement is open
The most promising route is the complement characterization.

1. Prove:
   ```lean
   x ∉ supportOf Λ ↔
     ∃ U, IsOpen U ∧ x ∈ U ∧ ∀ f, support f ⊆ U → Λ f = ⊥
   ```
   This is almost a direct negation of the definition, but you will need classical logic to move negation past the existential.
2. Define
   ```lean
   badSet Λ := {x | ∃ U, IsOpen U ∧ x ∈ U ∧ ∀ f, support f ⊆ U → Λ f = ⊥}
   ```
   and show `badSet Λ` is open by reusing the witnessing neighborhood `U`.
3. Conclude
   ```lean
   (supportOf Λ)ᶜ = badSet Λ
   ```
   and hence `IsOpen (supportOf Λ)ᶜ`, therefore `IsClosed (supportOf Λ)`.
4. Key Lean lemmas likely useful:
   - `isOpen_iff_mem_nhds`
   - `isClosed_compl_iff`
   - extensionality on sets via `ext x; constructor`
   - `by_contra`, `push_neg`, `classical`

This theorem matters because it upgrades support from an ad hoc “nontriviality locus” into a geometric object in the Stone/Gelfand sense: a closed carrier on which the idempotent functional lives.

---

### B. Pullback functoriality: use preimages of neighborhoods
To show
`supportOf (comap φ Λ) ⊆ φ ⁻¹' supportOf Λ`, argue contrapositive.

1. Assume `φ x ∉ supportOf Λ`. By the complement characterization, choose an open `V ⊆ Y` with `φ x ∈ V` and such that every `g` supported in `V` satisfies `Λ g = ⊥`.
2. Set `U := φ ⁻¹' V`; `U` is open by continuity and contains `x`.
3. For any `f : TropCont X` with `support f ⊆ U`, try to produce a test function on `Y` through the existing measure/kernel representation:
   - either use direct composition if the API has a pushforward of functions,
   - or use the representation `Λ ↦ μ_Λ` and prove that annihilation on `V` pulls back to annihilation on `U`,
   - or, in the discrete case, use explicit support computation.
4. Conclude every `f` supported in `U` is killed by the pullback functional, so `x ∉ supportOf (comap φ Λ)`.
5. In the finite/discrete case, support pullback should reduce to an atomic statement about points with non-`⊥` weights under `μ_Λ`; this may be the easiest route to a strong theorem.

This is the categorical heart of the program: support becomes a contravariant closed-set functor attached to tropical functionals, a genuine Stone-style geometric shadow of idempotent analysis.

---

### C. Kernel/support duality in discrete spaces: reduce to atomic peaks
This is likely the cleanest place to get exact theorems.

1. In a discrete topology, every singleton is open, so for `x ∉ supportOf Λ`, there is a neighborhood `U = {x}` on which every supported function is annihilated.
2. Define singleton peak functions `peakAt x` with `support (peakAt x) = {x}` and `peakAt x x ≠ ⊥`.
3. Show:
   ```lean
   x ∉ supportOf Λ ↔ Λ (peakAt x) = ⊥
   ```
   and therefore
   ```lean
   x ∈ supportOf Λ ↔ Λ (peakAt x) ≠ ⊥
   ```
4. For any `f` with support disjoint from `supportOf Λ`, decompose `f` as a tropical supremum over singleton peaks indexed by its support. Then use maxitivity / upper continuity of `Λ` to deduce `Λ f = ⊥`.
5. If `μ_Λ` exists, identify `Λ (peakAt x)` with `μ_Λ {x}` and derive the exact support/measure carrier equality.

The decomposition into atomic peaks is the bridge from abstract topology to algorithms: on finite spaces it turns support into a computable invariant, making classification and equality checking of functionals decidable.

---

### D. Uniqueness from support and peak values: reconstruct from generators
This should be attacked in finite/discrete spaces first, where the semiring of functions is generated by atomic peaks and constants.

1. Prove a normal form for discrete tropical continuous functions:
   ```lean
   f = ⨆ x, (f x) • peakAt x
   ```
   with the correct tropical scalar action and finite supremum notation.
2. Show a normalized functional is determined by its values on these generators:
   - constants,
   - singleton peaks or scaled singleton peaks.
3. If `Λ` and `Γ` have the same support and agree on all peaks based at support points, then they agree on every atomic summand in the normal form.
4. Use linearity/maxitivity to conclude `Λ f = Γ f` for all `f`.
5. If only agreement up to scalar is available, absorb the discrepancy into normalization by proving:
   ```lean
   ∃ c, ∀ f, Γ f = c ⊗ Λ f
   ```
   and then pin down `c` using the normalization hypothesis.

This theorem is the first genuine reconstruction principle in the support-duality program: support plus local probes determines the functional. That is the tropical/idempotent analogue of recovering a measure from its values on a generating family, and it opens the door to classification, equivalence, and computation.

---

## CONCRETE IMPLEMENTATION HINTS IN LEAN

- Use `classical` early for set extensionality and negation manipulations.
- If `support` for `TropCont` is awkward, define an auxiliary:
  ```lean
  def nonBotSupport (f : TropCont X) : Set X := {x | f x ≠ ⊥}
  ```
  and prove conversion lemmas rather than fighting the API.
- For discrete spaces, instantiate continuity automatically:
  ```lean
  have hcont : Continuous fun x : X => ...
  ```
  via `continuous_of_discreteTopology`.
- A useful peak in the discrete case is:
  ```lean
  def peakAt [DecidableEq X] (x : X) : TropCont X := ...
  ```
  with values `0` at `x` and `⊥` elsewhere.
- Prove immediately:
  ```lean
  theorem support_peakAt [DecidableEq X] (x : X) :
      support (peakAt x) = {x}
  ```
  and
  ```lean
  theorem eval_peakAt_same [DecidableEq X] (x : X) :
      peakAt x x = 0
  ```
- If finite suprema are easier than arbitrary upper continuity, formulate discrete reconstruction over `Finset X`.
- Look for existing lemmas about `iSup`, `sSup`, maxitivity, and monotonicity of `UCTropicalFunctional`; many proofs will become one-line once the right generator decomposition is in place.

---

## IF THE FULL TARGET RESISTS

Then prove the following staged theorem package with no `sorry` except perhaps one decomposition lemma:

1. `isClosed_supportOf` for arbitrary topological spaces.
2. `support_pullback_le` for arbitrary spaces, at least in the contrapositive form.
3. `x ∈ supportOf Λ ↔ Λ (peakAt x) ≠ ⊥` for finite discrete spaces.
4. `kernel_eq_botOn_compl_support_discrete`.
5. `eq_of_agree_on_singleton_peaks` for normalized functionals on finite discrete spaces.

If the scalar-twist uniqueness theorem is not reachable, state the precise conjecture with exact type signature, and prove all prerequisites needed for it.

---

## WHY THIS MATTERS

This is not a cosmetic support theory. It is the missing geometric layer between tropical Riesz representation and tropical Stone/Gelfand duality:

- `supportOf` turns an idempotent functional into a closed geometric carrier.
- `support_pullback_le` makes that carrier functorial, so functionals acquire a genuine spatial semantics under continuous maps.
- `kernel_eq_botOn_support` identifies the support as the exact locus where information survives; this is the idempotent analogue of a measure’s essential support.
- `support_eq_and_agree_on_peaks_imp_eq_up_to_scalar` says the functional is reconstructible from local probes, creating a tropical analogue of sheaf-like or spectral reconstruction.

This opens three major directions immediately:
1. a categorical duality between maxitive kernels and closed subsets,
2. computable classification of finite tropical functionals via atomic support data,
3. transport of support semantics into optimization, tropical probability, and neural-network max-plus models where “where the mass lives” is the central algorithmic question.

Produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems that build directly on this support duality, including at least one categorical theorem, one finite algorithmic theorem, and one reconstruction theorem beyond the discrete case.

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

Research domain: Bridges
Research mode: prove
