## YOUR ASSIGNMENT: Compact tropical Choquet–Radon representation for upper-continuous idempotent EML functionals

**TARGET FILE**: `Bridges/CompactTropicalChoquetRadon.lean`

**PRIMARY GOAL**: Formalize and prove a compact-space idempotent Choquet–Radon theorem for upper-continuous max-plus linear functionals on continuous tropical-valued functions.

You should not aim for a vague existence theorem. Build a usable formal package:
1. a precise structure for compact tropical functionals,
2. a compact-set capacity extracted from the functional,
3. maxitivity + Radon regularity of that capacity,
4. the Choquet–Radon representation formula,
5. support/minimal-carrier uniqueness,
6. functoriality under continuous pullback.

This is the compact topological completion of the finite/discrete tropical moment–Riesz–Choquet program. Once formalized, it becomes the correct bridge from algebraic tropical linear functionals to geometric support theory on compact spaces.

---

## DEFINITIONS TO INTRODUCE

Work with a compact Hausdorff space `X`, represented in Lean by a type with:
```lean
variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]
```

Use tropical values in `WithBot ℝ`. Continuous tropical observables should be:
```lean
def TropCont (X : Type*) [TopologicalSpace X] := C(X, WithBot ℝ)
```

Introduce a structure encoding the functional axioms you actually need. A workable signature is:

```lean
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X] [CompactSpace X] [T2Space X] where
  toFun : C(X, WithBot ℝ) → WithBot ℝ
  monotone' :
    Monotone toFun
  sup_preserving' :
    ∀ f g : C(X, WithBot ℝ), toFun (f ⊔ g) = max (toFun f) (toFun g)
  const_add' :
    ∀ (a : WithBot ℝ) (f : C(X, WithBot ℝ)),
      toFun (ContinuousMap.const X a ⊔ f) = max a (toFun f)
  top_continuous' :
    ∀ {ι : Type*} [DirectedOrder ι] (s : ι → C(X, WithBot ℝ)),
      Monotone s →
      toFun (iSup s) = iSup (fun i => toFun (s i))
  map_bot' :
    toFun (ContinuousMap.const X ⊥) = ⊥
```

If `const_add'` is not the right tropical linearity axiom relative to your existing catalog, replace it by the exact scalar-translation axiom already available, but keep the theorem statements below unchanged up to definitional equivalence.

You will also need a compact-set capacity. Since Lean’s `Compacts X` is the natural object, define:

```lean
open Topology

def compactCapacity
  (Λ : UCTropicalFunctional X) :
  Compacts X → WithBot ℝ :=
fun K =>
  sInf {a : WithBot ℝ | ∃ f : C(X, WithBot ℝ),
    (∀ x : K, (0 : WithBot ℝ) ≤ f x) ∧
    a = Λ.toFun f}
```

This raw infimum definition may be too weak to encode “large on K”. If so, use the sharper and mathematically correct variant:
```lean
def compactCapacity
  (Λ : UCTropicalFunctional X) :
  Compacts X → WithBot ℝ :=
fun K =>
  sInf {Λ.toFun f | f : C(X, WithBot ℝ), ∀ x ∈ (K : Set X), (0 : WithBot ℝ) ≤ f x}
```

If your catalog already contains a better normalization convention for “test functions dominating `0` on `K`”, use that exact convention consistently. The theorem is invariant under that choice, but the proof is not.

For the support, define the carrier closed set by vanishing on neighborhoods or by capacity-null complement. The cleanest target is:
```lean
def tropSupport (Λ : UCTropicalFunctional X) : Set X :=
{x | ∀ K : Compacts X, x ∈ (K : Set X) → compactCapacity Λ K = ⊥ → False}
```

A more usable equivalent version is via open neighborhoods:
```lean
def tropSupport' (Λ : UCTropicalFunctional X) : Set X :=
{x | ∀ U : Set X, IsOpen U → x ∈ U →
  ∃ K : Compacts X, (K : Set X) ⊆ U ∧ compactCapacity Λ K ≠ ⊥}
```

Prove equivalence if you define both.

---

## PRECISE THEOREM STATEMENTS

Break the main result into the following Lean targets.

### 1. Capacity maxitivity on compact sets
```lean
theorem compactCapacity_empty
  (Λ : UCTropicalFunctional X) :
  compactCapacity Λ ⊥ = ⊥
```

```lean
theorem compactCapacity_union
  (Λ : UCTropicalFunctional X) (K L : Compacts X) :
  compactCapacity Λ (K ⊔ L) =
    max (compactCapacity Λ K) (compactCapacity Λ L)
```

Also prove monotonicity:
```lean
theorem compactCapacity_mono
  (Λ : UCTropicalFunctional X) :
  Monotone (compactCapacity Λ)
```

### 2. Radon-style outer regularization from compact sets
Define an outer capacity on closed/open/arbritrary sets. The most practical version is on opens:
```lean
def openCapacity
  (Λ : UCTropicalFunctional X) (U : Set X) : WithBot ℝ :=
  iSup {K : Compacts X | (K : Set X) ⊆ U} compactCapacity Λ K
```

Then prove:
```lean
theorem openCapacity_eq_iSup_compacts
  (Λ : UCTropicalFunctional X) (U : Set X) :
  openCapacity Λ U =
    iSup (fun K : {K : Compacts X // (K : Set X) ⊆ U} =>
      compactCapacity Λ K)
```

and the compact-inner regularity / Radon property:
```lean
theorem compact_inner_regular
  (Λ : UCTropicalFunctional X) {F : Set X} (hF : IsClosed F) :
  (iSup (fun K : {K : Compacts X // (K : Set X) ⊆ F} =>
    compactCapacity Λ K))
  = -- the induced closed-set capacity on F
    closedCapacity Λ F
```

If defining `closedCapacity` becomes too heavy, prove directly the approximation theorem needed for the representation formula:
```lean
theorem compact_approx_of_upper_continuous
  (Λ : UCTropicalFunctional X) (f : C(X, WithBot ℝ)) :
  Λ.toFun f =
    iSup (fun K : Compacts X =>
      compactCapacity Λ K + sInf (f '' (K : Set X)))
```
with the understanding that `+` is the tropical additive action used in your existing development. If `WithBot ℝ` addition interacts poorly with `sInf`, replace this by `max-plus` notation already present in the catalog.

### 3. Choquet–Radon representation
The central target should be one of the following equivalent forms.

Preferred compact-set form:
```lean
theorem tropical_choquet_radon
  (Λ : UCTropicalFunctional X) (f : C(X, WithBot ℝ)) :
  Λ.toFun f =
    iSup (fun K : Compacts X =>
      compactCapacity Λ K + sInf (f '' (K : Set X)))
```

If image infima are awkward, define:
```lean
def infOnCompact (f : C(X, WithBot ℝ)) (K : Compacts X) : WithBot ℝ :=
  sInf (f '' (K : Set X))
```
and use:
```lean
theorem tropical_choquet_radon'
  (Λ : UCTropicalFunctional X) (f : C(X, WithBot ℝ)) :
  Λ.toFun f =
    iSup (fun K : Compacts X =>
      compactCapacity Λ K + infOnCompact f K)
```

You will likely also need the singleton corollary:
```lean
theorem tropical_choquet_radon_singletons_le
  (Λ : UCTropicalFunctional X) (f : C(X, WithBot ℝ)) :
  iSup (fun x : X =>
    compactCapacity Λ (Compacts.singleton x) + f x)
    ≤ Λ.toFun f
```

This is not merely a lemma: it identifies the “atomic shadow” of the compact representation and is the bridge to tropical support and moment duality.

### 4. Support is closed and minimal
```lean
theorem isClosed_tropSupport
  (Λ : UCTropicalFunctional X) :
  IsClosed (tropSupport Λ)
```

Define restriction to a closed carrier:
```lean
def supportedOn
  (Λ : UCTropicalFunctional X) (S : Set X) : Prop :=
  ∀ K : Compacts X, Disjoint (K : Set X) S → compactCapacity Λ K = ⊥
```

Then prove minimality:
```lean
theorem tropSupport_is_smallest_closed_support
  (Λ : UCTropicalFunctional X) :
  IsClosed (tropSupport Λ) ∧
  supportedOn Λ (tropSupport Λ) ∧
  ∀ S : Set X, IsClosed S → supportedOn Λ S →
    tropSupport Λ ⊆ S
```

### 5. Functoriality under continuous pullback
Given `φ : C(X, Y)` with `Y` compact Hausdorff, define pullback:
```lean
def pullbackFunctional
  (φ : C(X, Y)) (Λ : UCTropicalFunctional Y) :
  UCTropicalFunctional X
```
by
```lean
toFun f := Λ.toFun (f.comp φ)
```

Then prove capacity functoriality in the image/preimage form that your definitions support. A practical theorem is:
```lean
theorem compactCapacity_pullback_le
  {Y : Type*} [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
  (φ : C(X, Y)) (Λ : UCTropicalFunctional Y) (K : Compacts X) :
  compactCapacity (pullbackFunctional φ Λ) K
    ≤ compactCapacity Λ (K.map φ)
```

If you can prove equality, do it:
```lean
theorem compactCapacity_pullback
  {Y : Type*} [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
  (φ : C(X, Y)) (Λ : UCTropicalFunctional Y) (K : Compacts X) :
  compactCapacity (pullbackFunctional φ Λ) K
    = compactCapacity Λ (K.map φ)
```

And support functoriality:
```lean
theorem tropSupport_pullback_subset
  {Y : Type*} [TopologicalSpace Y] [CompactSpace Y] [T2Space Y]
  (φ : C(X, Y)) (Λ : UCTropicalFunctional Y) :
  tropSupport (pullbackFunctional φ Λ) ⊆ φ ⁻¹' tropSupport Λ
```

---

## PROOF STRATEGY

### Strategy A: Capacity-from-functional via Urysohn separation and compact approximation
This is the most promising route.

1. **Build compact test functions using compact Hausdorff normality.**  
   The key technical engine is Urysohn-style separation for compact sets and open neighborhoods. For `K ⊆ U`, construct `f : C(X, WithBot ℝ)` with:
   - `0 ≤ f` on `K`,
   - `f = ⊥` or very small outside `U`,
   - monotone approximation as `U ↓ K`.
   
   In Lean, this may require first constructing ordinary real-valued continuous functions via `Urysohn`, then embedding into `WithBot ℝ`. This is the topological heart of Radon regularity.

2. **Prove union maxitivity by splitting test functions and using tropical linearity.**  
   For `K ∪ L`, one inequality follows from monotonicity immediately. For the reverse inequality, use functions `f_K`, `f_L` admissible for `K`, `L`, and combine them with pointwise sup:
   ```lean
   f := f_K ⊔ f_L
   ```
   Then invoke:
   ```lean
   Λ.toFun (f_K ⊔ f_L) = max (Λ.toFun f_K) (Λ.toFun f_L)
   ```
   and check admissibility on `K ⊔ L`.

3. **Establish compact approximation of `f` by lower step/plateau functions indexed by compact sublevel sets.**  
   For each threshold `t`, define compact superlevel/sublevel sets of `f`; use compactness to pass from pointwise order decomposition to a directed supremum. The key lemma is that continuous `WithBot ℝ`-valued functions on compact spaces admit compact exhaustion of their lower envelopes:
   ```lean
   infOnCompact f K ≤ f x  for x ∈ K
   ```
   hence
   ```lean
   compactCapacity Λ K + infOnCompact f K ≤ Λ.toFun f
   ```
   by monotonicity after shifting a compact-test function by `infOnCompact f K`.

4. **Prove the reverse inequality via upper continuity.**  
   Construct a directed family of compact-supported approximants whose tropical Choquet envelopes increase to `f`. Then apply `top_continuous'`. This is where upper continuity is essential: it converts a pointwise compact approximation into an exact representation identity.

5. **Extract support from null compacts and prove minimality.**  
   Define support as the complement of the union of open sets carrying only null compacts. Closedness follows from definition. Minimality follows because any closed carrier annihilating disjoint compacts must contain every point detected by some positive-capacity compact neighborhood.

### Strategy B: Reduce to an existing tropical Riesz theorem, then upgrade from points to compacts
Use this if the catalog already contains a representation by a maxitive measure on closed/open sets.

1. Start from the existing tropical Riesz representation for `Λ`.
2. Define `compactCapacity Λ K` as the restriction of the representing measure to compact sets.
3. Prove compact maxitivity and regularity using the measure-side infrastructure.
4. Derive the compact Choquet formula as a reformulation of the Riesz formula using:
   ```lean
   infOnCompact f K
   ```
   as the compact-level observable.
5. Show support agreement between the functional support and the measure support.

This route is shorter if the catalog already formalized enough maxitive measure theory; otherwise Strategy A is better.

### Strategy C: Finitary approximation through finite tropical partitions
Use only if direct topological regularity becomes hard.

1. Approximate `X` by finite closed covers subordinate to `f`.
2. For each finite cover, derive a discrete Choquet formula using existing finite/discrete machinery.
3. Pass to the limit over refinements using compactness and upper continuity.
4. Recover the compact-set capacity as the supremum over finite approximants.

This route is technically heavier but can rescue the main theorem if direct Urysohn/regularity lemmas are unavailable.

---

## KEY INTERMEDIATE LEMMAS TO TARGET

These are likely the actual bottlenecks.

```lean
theorem infOnCompact_le_eval
  (f : C(X, WithBot ℝ)) (K : Compacts X) {x : X}
  (hx : x ∈ (K : Set X)) :
  infOnCompact f K ≤ f x
```

```lean
theorem compactCapacity_sup_test
  (Λ : UCTropicalFunctional X) (K L : Compacts X) :
  compactCapacity Λ (K ⊔ L)
    ≤ max (compactCapacity Λ K) (compactCapacity Λ L)
```

```lean
theorem compactCapacity_union_ge
  (Λ : UCTropicalFunctional X) (K L : Compacts X) :
  max (compactCapacity Λ K) (compactCapacity Λ L)
    ≤ compactCapacity Λ (K ⊔ L)
```

```lean
theorem compactCapacity_shift_infOnCompact_le
  (Λ : UCTropicalFunctional X) (f : C(X, WithBot ℝ)) (K : Compacts X) :
  compactCapacity Λ K + infOnCompact f K ≤ Λ.toFun f
```

```lean
theorem choquet_envelope_directed
  (Λ : UCTropicalFunctional X) (f : C(X, WithBot ℝ)) :
  Directed (· ≤ ·) (fun K : Compacts X =>
    compactCapacity Λ K + infOnCompact f K)
```

If this directedness statement is false as written because compacts are not directed under inclusion, replace it by a sigma-type over finite unions or over neighborhood approximants. Do not force a false lemma; instead build the right directed indexing type.

A very useful support lemma:
```lean
theorem not_mem_tropSupport_iff
  (Λ : UCTropicalFunctional X) (x : X) :
  x ∉ tropSupport Λ ↔
  ∃ U : Set X, IsOpen U ∧ x ∈ U ∧
    ∀ K : Compacts X, (K : Set X) ⊆ U → compactCapacity Λ K = ⊥
```

---

## LEAN-SPECIFIC IMPLEMENTATION ADVICE

- Use `Compacts X` aggressively; it packages compactness and is compatible with `map`, lattice operations, and coercions to sets.
- For `infOnCompact`, compactness plus continuity should give existence of minima in the real-valued case. Since the codomain is `WithBot ℝ`, it may be easier to work with `sInf` rather than trying to prove attainment immediately.
- If `ContinuousMap` into `WithBot ℝ` is awkward due to order-topology issues, introduce an intermediate theorem for `C(X, ℝ)` and then lift to `WithBot ℝ` via coercions where possible.
- Expect to need lemmas about:
  - `image` of a compact under a continuous map is compact,
  - `sInf` over compact images in conditionally complete lattices,
  - pointwise order on `C(X, α)`,
  - `ContinuousMap.comp`,
  - lattice structure on `ContinuousMap`.
- If the exact `iSup` of continuous maps is not available because arbitrary suprema are not continuous, do not encode upper continuity using `iSup` inside `C(X, WithBot ℝ)` naively. Instead quantify over a directed family together with a witness `f` that is their pointwise supremum and continuous:
  ```lean
  ∀ {ι} [DirectedOrder ι] (s : ι → C(X, WithBot ℝ)) (f : C(X, WithBot ℝ)),
    (∀ x, f x = iSup (fun i => s i x)) →
    Monotone s →
    Λ.toFun f = iSup (fun i => Λ.toFun (s i))
  ```
  This formulation is much more likely to formalize.

---

## WHAT TO DO IF THE FULL THEOREM IS TOO HARD

If the full compact theorem resists formalization, prove the strongest breakthrough special case rather than leaving diffuse gaps.

### Strong special case A: finite-image continuous functions
Prove the representation for `f : C(X, WithBot ℝ)` with finite range:
```lean
theorem tropical_choquet_radon_finite_range
  (Λ : UCTropicalFunctional X)
  (f : C(X, WithBot ℝ))
  (hf : Set.Finite (Set.range f)) :
  Λ.toFun f =
    iSup (fun K : Compacts X =>
      compactCapacity Λ K + infOnCompact f K)
```
This already gives a nontrivial compact/discrete bridge.

### Strong special case B: singleton representation
If compact-set representation is hard, prove at least:
```lean
theorem tropical_riesz_atomic_shadow
  (Λ : UCTropicalFunctional X) (f : C(X, WithBot ℝ)) :
  Λ.toFun f =
    iSup (fun x : X =>
      pointMassWeight Λ x + f x)
```
for a suitably defined `pointMassWeight`. This is revolutionary if obtainable and gives a tropical Gelfand-style support theory.

### Strong special case C: support and functoriality only
Even without the full representation, proving that the compact capacity is maxitive, inner regular, and has a smallest closed carrier is already a substantial advance.

If you must leave a conjecture, state it exactly:

```lean
conjecture tropical_choquet_radon_full
  (Λ : UCTropicalFunctional X) (f : C(X, WithBot ℝ)) :
  Λ.toFun f =
    iSup (fun K : Compacts X =>
      compactCapacity Λ K + infOnCompact f K)
```

---

## WHY THIS MATTERS

This theorem is not a routine compactification. It creates the missing topological layer of idempotent functional analysis.

- **It upgrades tropical Riesz theory from algebra to geometry.**  
  Finite and discrete tropical moment formulas become genuine compact-space representation theory.

- **It makes support visible.**  
  Once `Λ` is represented by a compact maxitive capacity with a smallest closed carrier, tropical spectra, tropical ideals, and idempotent moment problems acquire a geometric support object analogous to the support of a Radon measure.

- **It enables functorial tropical semantics.**  
  The pullback theorem means these functionals behave naturally under continuous maps, which is exactly what is needed for a category-level tropical duality.

- **It has an algorithmic shadow.**  
  The formula
  ```lean
  Λ(f) = iSup_K (μ(K) + inf_K f)
  ```
  is a max-plus optimization principle over compact witnesses. This is the right abstraction for robust optimization, tropical control, and idempotent dynamic programming on compact state spaces.

- **It opens the next frontier.**  
  With this theorem in place, the next steps become concrete: tropical Prokhorov compactness, idempotent Wasserstein geometry, spectral support for tropical function algebras, and compact-space duality between tropical ideals and maxitive carriers.

---

## REQUIRED OUTPUT BEYOND THE LEAN FILE

Also produce `FUTURE_DIRECTIONS.md` with 3–5 concrete next theorems that become possible once this file is complete. They must be specific, formalization-ready, and breakthrough-level. Suggested directions include:
1. tropical Prokhorov compactness for Radon maxitive capacities,
2. idempotent Kantorovich duality on compact spaces,
3. support-spectral duality for tropical function algebras,
4. Choquet boundary theory for idempotent convex compacta,
5. Stone–Weierstrass-style approximation for tropical continuous function semimodules.

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
