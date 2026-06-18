## Assignment: Algebra–EML Spectral Tropical Langlands Correspondence via Idempotent Hecke Semirings and Closure Eigenmeasures

**Mode:** `formalize` + `prove`

Formalize a genuinely new tropical/idempotent analogue of the unramified Langlands dictionary. The goal is not a loose analogy: it is a precise anti-equivalence/classification theorem connecting spectral data of commutative idempotent Hecke actions on finite tropical semimodules to extremal equilibrium functionals on finitary closure systems. If this lands cleanly in Lean, it opens a new formal research interface between tropical representation theory, idempotent functional analysis, order/closure semantics, and EML.

The breakthrough is that **spectral decomposition becomes reconstructible from closure invariants**. This is a tropical Satake-style theorem in which “characters” are max-plus traces / spectral radii, and “parameters” are extremal closure eigenmeasures. If successful, this creates a machine-checkable paradigm for extracting representation-theoretic invariants from closure-theoretic data.

---

## Precise Theorem Target

Work in the setting of a finitely generated commutative idempotent semiring `H` with a distinguished finite Hecke generating set. Let `M` be a finite tropical semimodule with order-continuous, residuated `H`-action.

Define:

- `Rep_trop(H)`: finite semisimple tropical `H`-semimodules with residuated action,
- `Clo_eq(H)`: finitary closure systems with `H`-compatible closure transfer operators and normalized extremal equilibrium functionals,
- `Sat_trop : Rep_trop(H) ⥤ Clo_eq(H)`: the functor sending a module to its closure spectrum object,
- `ExtEig(Sat_trop M)`: extremal closure eigenmeasures,
- `SpecSummands(M)`: simple tropical spectral summands of `M`.

### Main theorem, mathematically

Assume:
1. `H` is commutative, idempotent, finitely generated as a semiring by a finite Hecke basis `B`,
2. each action map `ρ(h) : M → M` is order-preserving and residuated,
3. `M` is finite and semisimple in the tropical spectral sense,
4. the closure object `Sat_trop(M)` is finitary and separated by its normalized equilibrium functionals.

Then there exists a canonical contravariant correspondence
\[
\Phi_M : \mathrm{SpecSummands}(M) \xrightarrow{\sim} \mathrm{ExtEig}(Sat\_trop(M))
\]
such that:

1. **Spectral classification:** simple tropical spectral summands of `M` are in bijection with extremal closure eigenmeasures on `Sat_trop(M)`;
2. **Hecke covariance:** for `h₁ h₂ : H`, the closure transfer associated to `h₁ * h₂` agrees with composition / infimal convolution of the transfers of `h₁` and `h₂`;
3. **Character recovery:** the tropical character
   \[
   \chi_M(h) := \operatorname{tr}_{trop}(\rho(h))
   \]
   is recoverable from the finite family of closure pressure values attached to `Sat_trop(M)`;
4. **Semisimple classification:** isomorphism classes of finite semisimple tropical `H`-modules are classified by finite multisets of extremal closure eigenmeasures.

This is the right theorem because it is both structurally deep and Lean-feasible in stages: first define the categories and transfer operators, then prove the extremal correspondence for finite objects, then the classification statement.

---

## Lean 4 Formalization Targets

You should introduce precise structures rather than overcommit to existing abstractions too early.

### Core structures to define

```lean
structure IdempotentHeckeSemiring (H : Type _) extends Semiring H, PartialOrder H where
  add_idem : ∀ a : H, a + a = a
  add_le_iff : ∀ a b c : H, a + b ≤ c ↔ a ≤ c ∧ b ≤ c
  mul_mono : Monotone₂ (fun a b : H => a * b)
  finite_hecke_basis : Finset H
  generates : Subsemiring.closure (↑finite_hecke_basis : Set H) = ⊤
```

```lean
structure TropicalRep (H M : Type _) [IdempotentHeckeSemiring H] extends
  OrderedSMul H M where
  semimoduleStr : Semiring H → Prop -- replace by actual semimodule-like data as feasible
  finite_carrier : Finite M
  action_mono : ∀ h : H, Monotone (fun m : M => h • m)
  residuated : ∀ h : H, ∃ r : M → M, GaloisConnection (fun m => h • m) r
```

```lean
structure ClosureEigenmeasure (C H : Type _) [IdempotentHeckeSemiring H] where
  toFun : C → TropicalReal -- replace TropicalReal by available max-plus object
  monotone' : Monotone toFun
  idempotent_additive : ∀ x y, toFun (closure_join x y) = max (toFun x) (toFun y)
  normalized : toFun closure_bot = 0
  hecke_covariant : ∀ h x, toFun (transfer h x) = heckeWeight h + toFun x
  extremal : ∀ μ₁ μ₂ a b, -- formulate extremality in max-plus convex sense
    ...
```

```lean
structure ClosureSpectrum (H C : Type _) [IdempotentHeckeSemiring H] where
  cl : C → C
  extensive : ∀ x, x ≤ cl x
  monotone_cl : Monotone cl
  idempotent_cl : ∀ x, cl (cl x) = cl x
  transfer : H → C → C
  transfer_mul : ∀ h₁ h₂ x, transfer (h₁ * h₂) x = transfer h₁ (transfer h₂ x)
  transfer_add : ∀ h₁ h₂ x, transfer (h₁ + h₂) x = infLike (transfer h₁ x) (transfer h₂ x)
```

### Candidate theorem signatures

First prove a finite-object correspondence theorem before categorical equivalence.

```lean
theorem spectralSummand_equiv_extremalEigenmeasure
  (H M : Type _)
  [IdempotentHeckeSemiring H]
  [Finite M]
  (ρ : TropicalRep H M) :
  Nonempty (SpecSummand ρ ≃ ClosureEigenmeasure (SatTropObj ρ) H)
```

A more realistic intermediate theorem:

```lean
theorem simpleSummands_biject_extremalMeasures
  (H M : Type _)
  [IdempotentHeckeSemiring H]
  [Finite M]
  (ρ : TropicalRep H M)
  (hsemisimple : TropicalSemisimple ρ) :
  ∃ e : Finset (SimpleSummand ρ) ≃ Finset (ExtremalEigenmeasure (SatTropObj ρ) H), True
```

Character recovery theorem:

```lean
theorem tropicalCharacter_eq_sup_closurePressures
  (H M : Type _)
  [IdempotentHeckeSemiring H]
  [Finite M]
  (ρ : TropicalRep H M)
  (h : H) :
  tropChar ρ h =
    Finset.sup (closureGenerators (SatTropObj ρ)) (fun c => closurePressure ρ h c)
```

Semisimple classification theorem:

```lean
theorem semisimple_iso_iff_eigenmeasure_multiset_eq
  (H M N : Type _)
  [IdempotentHeckeSemiring H]
  [Finite M] [Finite N]
  (ρM : TropicalRep H M) (ρN : TropicalRep H N)
  (hM : TropicalSemisimple ρM) (hN : TropicalSemisimple ρN) :
  Nonempty (TropicalRepIso ρM ρN) ↔
    eigenmeasureMultiset (SatTropObj ρM) = eigenmeasureMultiset (SatTropObj ρN)
```

Functorial statement:

```lean
def SatTrop : RepTropCat H ⥤ CloEqCat H := ...
```

And, if feasible:

```lean
theorem SatTrop_faithful_on_semisimple :
  Faithful (SatTrop (H := H))
```

or a weaker reconstruction theorem:

```lean
theorem SatTrop_reconstructs_semisimple_object
  (X : RepTropCat H)
  (hX : SemisimpleObj X) :
  ∃! Y, Nonempty (X ≅ reconstructFromClosure (SatTrop.obj X))
```

---

## Staged Theorem Architecture

Do not attempt the full equivalence at once. Build the bridge in four certified stages.

### Stage 1: Hecke action induces closure transfer system
For finite tropical representations, define a closure object whose closure operators are generated by residuated action and fixed-point saturation.

Target theorem:
```lean
theorem exists_closureSpectrum_of_rep
  (H M : Type _)
  [IdempotentHeckeSemiring H]
  [Finite M]
  (ρ : TropicalRep H M) :
  ∃ C, Nonempty (ClosureSpectrum H C)
```

This is the foundation: no closure object, no Satake analogue.

### Stage 2: Eigenvectors/eigencharacters give equilibrium functionals
Construct a map from tropical eigenlines / simple summands to closure eigenmeasures.

Target theorem:
```lean
theorem eigenline_to_closureEigenmeasure
  (H M : Type _)
  [IdempotentHeckeSemiring H]
  [Finite M]
  (ρ : TropicalRep H M) :
  SimpleSummand ρ → ExtremalEigenmeasure (SatTropObj ρ) H
```

### Stage 3: Extremality and injectivity/surjectivity
Show the map is bijective under semisimplicity + finite generation + separation.

Target theorem:
```lean
theorem eigenline_to_closureEigenmeasure_bijective
  (H M : Type _)
  [IdempotentHeckeSemiring H]
  [Finite M]
  (ρ : TropicalRep H M)
  (hss : TropicalSemisimple ρ)
  (hsep : ClosureSeparated (SatTropObj ρ)) :
  Function.Bijective (eigenlineToMeasure (ρ := ρ))
```

### Stage 4: Character reconstruction and classification
Use the finite Hecke basis and extremal decomposition to reconstruct characters and module isomorphism class.

Target theorem:
```lean
theorem tropChar_determined_by_extremalMeasures_on_basis
  (H M : Type _)
  [IdempotentHeckeSemiring H]
  [Finite M]
  (ρ : TropicalRep H M) :
  ∀ h ∈ IdempotentHeckeSemiring.finite_hecke_basis H,
    tropChar ρ h =
      recoveredCharFromMeasures (SatTropObj ρ) h
```

---

## Proof Strategy Options

## Strategy A: Tropical Perron–Frobenius → eigencone → extremal measure
This is likely the most promising route.

1. **Finite residuated action gives spectral eigencone.**  
   For each `h : H`, the action `ρ(h)` on a finite tropical semimodule admits a finite eigencone / extremal ray decomposition. Formalize a tropical spectral radius and show eigenvectors generate simple spectral summands.

2. **Residuated action defines closure transfer.**  
   Use the right adjoints from residuation to define closure-like operators:
   \[
   \mathrm{cl}_h(x) := r_h(h \cdot x)
   \]
   and then aggregate over the finite Hecke basis to obtain a finitary closure system. This turns representation data into EML closure dynamics.

3. **Extremal eigenvectors induce extremal equilibrium functionals.**  
   Send an eigenline to the corresponding support/evaluation functional on closure-fixed sets. Prove covariance under Hecke transfer and identify extremality with indecomposability of the tropical eigenray.

Why promising: it matches finite combinatorial data, avoids deep categorical machinery initially, and should interact well with available max-plus linear algebra infrastructure.

---

## Strategy B: Stone/Birkhoff reconstruction from finite closure lattices
This is conceptually elegant and may yield the cleanest classification theorem.

1. **Construct a finite closure lattice from the representation.**  
   Let closed objects encode invariant tropical faces / principal residuation cuts. Show this lattice is algebraic and finite.

2. **Represent equilibrium functionals as lattice valuations/capacities.**  
   Formalize normalized extremal equilibrium functionals as max-plus valuations on the finite closure lattice.

3. **Recover the semisimple module from join-prime/extremal data.**  
   Use finite duality in the spirit of Stone/Birkhoff: simple summands correspond to join-irreducibles or extremal valuations; then classify modules by finite multisets of such points.

Why promising: if the catalog already has closure duality and finite reconstruction patterns, this approach may leverage them directly. It is especially strong for the semisimple classification part.

---

## Strategy C: Tropical character theory first, reconstruction second
This route is more representation-theoretic.

1. **Define tropical trace / character on finite Hecke generators.**  
   Formalize `χ_M(h)` as spectral radius / maximal cycle weight invariant.

2. **Show closure pressures determine character values.**  
   Prove a finite max-formula recovering `χ_M` from closure pressure values on generators.

3. **Use character separation to classify semisimple modules.**  
   Once the character is recovered from closure data, prove semisimple objects are determined by these values, then identify extremal eigenmeasures as the irreducible support of the character.

Why promising: this may be the easiest way to get a first “Satake transform” theorem even before full categorical equivalence. It yields computational content early.

---

## Recommended path

Start with **Strategy A**, then import **Strategy B** for the classification theorem.

- Strategy A is best for constructing actual Lean objects and obtaining the bijection.
- Strategy B is best for turning the bijection into a conceptual reconstruction/classification statement.
- Strategy C is ideal for extracting an algorithmic corollary and a formally checkable “spectral fingerprint” pipeline.

---

## Cross-Domain Connections You Should Explicitly Exploit

1. **Tropical representation theory ↔ unramified Langlands / Satake philosophy**  
   In the classical Satake isomorphism, spherical Hecke algebras classify unramified parameters via symmetric function data. Here, the idempotent analogue replaces harmonic analysis by max-plus spectral geometry and replaces semisimple conjugacy classes by extremal closure eigenmeasures.

2. **EML closure semantics ↔ idempotent functional analysis**  
   Closure operators encode stable observables / knowledge states; extremal equilibrium functionals behave like idempotent states or capacities. This suggests a formal bridge between semantic closure systems and tropical spectral analysis.

3. **Residuated algebra ↔ program semantics / optimization**  
   Residuated actions naturally model backward propagation, abstract interpretation, and constraint solving. Your theorem would imply that spectral invariants of optimization-like dynamics can be reconstructed from closure semantics.

4. **Choquet theory / capacities ↔ tropical convexity**  
   Extremal eigenmeasures should be viewed as tropical analogues of extreme points in capacity spaces. This is the right language for the decomposition theorem.

5. **Finite lattice duality ↔ explainable spectral algorithms**  
   If closure invariants classify semisimple tropical modules, then spectral signatures become explainable in terms of finite closure generators. This is not merely abstract: it suggests certifiable algorithms.

---

## Concrete Formal Definitions to Aim For

You should make the following notions precise enough to support theorem statements:

- `tropChar : TropicalRep H M → H → TropicalScalar`
- `SimpleSummand ρ`
- `ExtremalEigenmeasure C H`
- `ClosurePressure : SatTropObj ρ → H → Generator → TropicalScalar`
- `recoveredCharFromMeasures`
- `eigenmeasureMultiset`
- `TropicalSemisimple ρ`
- `ClosureSeparated C`
- `HeckeCovariantMeasure`

If some ambient tropical scalar object is missing from Mathlib, use a finite max-plus surrogate first:
- values in `WithBot ℤ`, `WithBot ℚ`, or another linearly ordered canonically ordered commutative idempotent semiring,
- finite matrices / endomorphisms on finite index types,
- spectral radius as a finite supremum over cycle weights if matrix-level formalization is easier than abstract trace.

---

## Algorithmic Corollary to Formalize

A major reason this theorem matters is that it yields a computable extraction procedure.

Target corollary:

```lean
theorem spectral_fingerprint_computable_from_closure_data
  (H M : Type _)
  [IdempotentHeckeSemiring H]
  [Fintype M] [DecidableEq M]
  (ρ : TropicalRep H M) :
  ∃ alg : ClosureData (SatTropObj ρ) → Finset SpectralInvariant,
    CertifiedCorrect alg
```

Interpretation:
- from finite closure data and Hecke transfer operators,
- solve finite residuation constraints,
- extract extremal rays/eigenmeasures,
- reconstruct tropical character values and semisimple decomposition.

This would create a formal pipeline from closure invariants to representation-theoretic spectral fingerprints.

---

## Why This Would Be a Breakthrough

If proved, this establishes a new formal field:

- a **tropical Langlands dictionary** in which Hecke operators act in idempotent semirings,
- a **closure-theoretic parameter space** for tropical semisimple spectra,
- a **computable Satake transform** replacing harmonic analysis by residuation and closure pressure,
- a bridge from **representation theory to EML semantics** that is both conceptual and executable.

This is not a variant of existing tropical robustness or bulk-boundary themes. It creates a new universal pattern:
\[
\text{algebraic action} \longleftrightarrow \text{closure dynamics} \longleftrightarrow \text{extremal measures} \longleftrightarrow \text{spectral classification}.
\]
That pattern could propagate to automata, optimization, semantics, control, and idempotent probability.

---

## Minimal Viable Formalization Plan

1. Define `IdempotentHeckeSemiring`.
2. Define finite tropical representations with residuated action.
3. Build a closure object from action + residuals.
4. Define extremal closure eigenmeasures.
5. Construct map from simple spectral summands/eigenlines to eigenmeasures.
6. Prove bijectivity in the finite semisimple case.
7. Define tropical character and prove closure-pressure recovery on finite generators.
8. Package as a functor `SatTrop`.
9. State a categorical equivalence conjecture if the full proof is too large, but prove the object-level classification theorem.

---

## Deliverables

Produce:

1. Lean files implementing the core structures and the strongest proved intermediate theorem.
2. A theorem dependency map indicating which lemmas are genuinely new versus reducible to existing order/closure/category infrastructure.
3. A short note explaining where the formal theorem diverges from the informal Langlands analogy and what hypotheses are essential.
4. **A structured `FUTURE_DIRECTIONS.md` with 3–5 concrete breakthrough next steps**, such as:
   - tropical Tannakian reconstruction from closure eigenmeasures,
   - noncommutative idempotent Hecke semirings,
   - geometric realization via tropical affine Grassmannians,
   - idempotent Plancherel / harmonic measure theory,
   - algorithmic extraction of spectral packets from semantic closure data.

---

## Application Keywords

tropical Langlands, idempotent Hecke semiring, tropical Satake transform, residuated semimodule, closure eigenmeasure, EML closure semantics, max-plus spectral theory, idempotent Choquet theory, finite lattice duality, semisimple tropical representation, spectral fingerprinting, certified reconstruction, formalized representation theory, tropical harmonic analysis, categorical semantics

### Catalog Reference Files
@AutoResearch/CompactTropicalChoquetRadon.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Compact Tropical Choquet–Radon Representation

This file formalizes a Choquet–Radon representation theorem for upper-continuous
max-plus linear functionals on continuous real-valued functions over a compact
Hausdorff space.

## Main definitions

* `UCTropicalFunctional` — A structure encoding an upper-continuous, max-plus linear
  functional on `C(X, ℝ)` with values in `EReal`.
* `compactCapacity` — The compact-set capacity extracted from a functional.
* `infOnCompact` — The infimum of a continuous function on a compact set.
* `tropSupport` — The support of a tropical functional (smallest closed carrier).
* `supportedOn` — Predicate for a functional being supported on a set.
* `pushforwardFunctional` — Pushforward of a tropical functional along a continuous map.

## Main results

* `compactCapacity_empty` — Capacity of the empty compact set is ⊥.
* `compactCapacity_mono` — Capacity is monotone (larger sets, larger capacity).
* `compactCapacity_union` — Capacity is maxitive: `μ(K ∪ L) = max(μ(K), μ(L))`.
* `infOnCompact_le_eval` — The infimum on a compact set is bounded by point evaluation.
* `tropical_choquet_radon_le` — One direction of the representation:
    `⊔_K (μ(K) + inf_K f) ≤ Λ(f)`.
* `isClosed_tropSupport` — The tropical support is closed.
* `tropSupport_supported` — The functional is supported on its tropical support.
* `tropSupport_minimal` — The tropical support is the smallest closed carrier.
* `compactCapacity_pushforward_le` — Capacity is functorial under pushforward.

## Mathematical overview

In max-plus (tropical) algebra, addition is `max` and multiplication is `+`.
A max-plus linear functional Λ on continuous functions satisfies:
- `Λ(f ⊔ g) = Λ(f) ⊔ Λ(g)` (preserves tropical addition = max)
- `Λ(f + c) = Λ(f) + c` (equivariant under tropical scalar action = real translation)

The Choquet–Radon representation expresses such a functional as a "max-plus integral":
  `Λ(f) = ⊔_K (μ(K) + inf_K f)`
where `μ` is a maxitive capacity on compact sets.
-/

noncomputable section

open TopologicalSpace Set EReal

/-! ### The functional structure -/

/-- An upper-continuous tropical (max-plus linear) functional on `C(X, ℝ)`,
taking values in `EReal` (extended reals with ±∞).

The axioms encode:
- `monotone'`: monotonicity with respect to pointwise order
- `sup_preserving'`: max-plus additivity `Λ(f ⊔ g) = max(Λ(f), Λ(g))`
- `shift_equivariant'`: tropical scalar action `Λ(f + c) = Λ(f) + c`
- `normalized'`: normalization `Λ(0) = 0`

The upper-continuity axiom (`top_continuous'`) states that Λ commutes with
directed suprema of continuous functions, provided the supremum is itself continuous.
-/
structure UCTropicalFunctional (X : Type*) [TopologicalSpace X]
    [CompactSpace X] [T2Space X] where
  /-- The underlying function from continuous maps to extended reals. -/
  toFun : C(X, ℝ) → EReal
  /-- The functional is monotone. -/
  monotone' : Monotone toFun
  /-- The functional preserves binary suprema (max-plus additivity). -/
  sup_preserving' : ∀ f g : C(X, ℝ), toFun (f ⊔ g) = toFun f ⊔ toFun g
  /-- The functional is equivariant under translation by real constants. -/
  shift_equivariant' : ∀ (c : ℝ) (f : C(X, ℝ)),
    toFun (f + ContinuousMap.const X c) = toFun f + (c : EReal)
  /-- Upper continuity: Λ commutes with monotone suprema of continuous functions,
      provided the supremum is itself continuous. -/
  top_continuous' : ∀ {ι : Type*} [Nonempty ι] [Preorder ι] (s : ι → C(X, ℝ))
    (f : C(X, ℝ)),
    (∀ x, f x = ⨆ i, (s i x : EReal)) →
    Monotone s →
    toFun f = ⨆ i, toFun (s i)
  /-- Normalization: the zero function maps to zero. -/
  normalized' : toFun 0 = 0

variable {X : Type*} [TopologicalSpace X] [CompactSpace X] [T2Space X]

namespace UCTropicalFunctional

instance : CoeFun (UCTropicalFunctional X) (fun _ => C(X, ℝ) → EReal) :=
  ⟨toFun⟩

@[simp]
theorem coe_toFun (Λ : UCTropicalFunctional X) (f : C(X, ℝ)) :
    Λ f = Λ.toFun f := rfl

theorem monotone (Λ : UCTropicalFunctional X) : Monotone Λ.toFun :=
  Λ.monotone'

theorem sup_preserving (Λ : UCTropicalFunctional X) (f g : C(X, ℝ)) :
    Λ (f ⊔ g) = Λ f ⊔ Λ g :=
  Λ.sup_preserving' f g

theorem shift_equivariant (Λ : UCTropicalFunctional X) (c : ℝ) (f : C(X, ℝ)) :
    Λ (f + ContinuousMap.const X c) = Λ f + (c : EReal) :=
  Λ.shift_equivariant' c f

theorem normalized (Λ : UCTropicalFunctional X) :
    Λ 0 = 0 := Λ.normalized'

/-- The functional maps constant functions to the constant. -/
theorem map_const (Λ : UCTropicalFunctional X) (c : ℝ) :
    Λ (ContinuousMap.const X c) = (c : EReal) := by
  have h := Λ.shift_equivariant c 0
  simp [Λ.normalized] at h
  exact h

/-- As constants decrease to -∞, the functional value goes to ⊥. -/
theorem map_const_neg_iInf (Λ : UCTropicalFunctional X) :
    ⨅ (n : ℕ), Λ (ContinuousMap.const X (-(n : ℝ))) = ⊥ := by
  simp [map_const]
  rw [iInf_eq_bot]
  intro b hb
  induction b with
    | bot => exact absurd rfl (ne_of_gt hb)
    | top => exact ⟨0, by simp⟩
    | coe r =>
      obtain ⟨n, hn⟩ := exists_nat_gt (-r)
      exact ⟨n, EReal.coe_lt_coe_iff.mpr (by linarith)⟩

end UCTropicalFunctional

/-! ### Compact-set capacity -/

/-- The compact-set capacity extracted from a tropical functional.
    `compactCapacity Λ K` is the infimum of `Λ(f)` over all continuous functions `f`
    that are nonneg (≥ 0) on `K`. -/
def compactCapacity (Λ : UCTropicalFunctional X) (K : Compacts X) : EReal :=
  sInf {a : EReal | ∃ f : C(X, ℝ), (∀ x ∈ (K : Set X), (0 : ℝ) ≤ f x) ∧ a = Λ.toFun f}

/-- The infimum of a continuous function over a compact set.
    When `K` is empty, this is `⊤` by convention (infimum of empty set). -/
def infOnCompact (f : C(X, ℝ)) (K : Compacts X) : EReal :=
  ⨅ x ∈ (K : Set X), (f x : EReal)

/-! ### Basic capacity properties -/

/-- Helper: the defining set for compactCapacity is nonempty. -/
-- ... (truncated, full file has 459 lines)
```

            ---

            You are Aristotle. Pursue this research direction deeply and originally.
            Discover what matters. Prove what you can. Define what needs defining.
            Build on the catalog theorems referenced above.

            Use concrete types (Nat, Real, Finset, Matrix). Avoid trivial tautologies.
            If a direct proof fails, try the contrapositive, a constructive witness,
            or structural induction. Connect to at least one other domain for impact.

            Required: Lean 4 proofs, FUTURE_DIRECTIONS.md
            Optional: ARTICLE.md, RESEARCH_PAPER.md, demo.py, diagram.svg

            FUTURE_DIRECTIONS.md is critical — it drives the next research cycle.
            Structure it with specific theorem statements, proof strategies, and
            cross-domain connections.


### WHAT WE NEED FROM YOU

You are a world-class mathematician, software engineer, and science writer.
Use your judgment on the best way to organize and present your work.
We need ALL of the following deliverables:

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 1 — Formally verified mathematics (Lean 4)
────────────────────────────────────────────────────────────────────────────
- Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
- Organize the code however makes sense — one file or several,
  whatever serves the mathematics best
- Use doc comments to explain the significance of key results

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 2 — Standalone Popular-Science ARTICLE  →  ARTICLE.md
────────────────────────────────────────────────────────────────────────────
Write a **superb, standalone magazine-quality article** about this research.

CRITICAL RULES FOR THE ARTICLE:
• Do NOT mention "Scientific American", "Sci Am", or "Lean" anywhere.
• Do NOT mention "Lean", "Lean 4", "formal verification", or "proof assistant".
• This is a POPULAR SCIENCE article for a curious, intelligent audience.
  Write it as if it will be published in a premier science magazine.
• The reader should come away saying "Wow, I had no idea math could do THAT."

ARTICLE QUALITY STANDARDS:
• **Superb writing**: Vivid, engaging prose. Strong opening hook. Narrative arc.
  Use concrete analogies and metaphors that make abstract ideas tangible.
• **Depth without jargon**: Explain the IDEAS, not the formalism.
  A reader with a college education should understand and enjoy every paragraph.
• **Story structure**: Open with a provocative question or surprising fact.
  Build tension. Reveal the breakthrough. Show why it matters.
• **Real-world connections**: Connect to technology, nature, everyday life.
  Why should a non-mathematician care about this?
• **Historical context**: Place the discovery in the sweep of intellectual history.
  Who tried this before? What barriers stood in the way?
• **Length**: 1500–3000 words. Substantial but not padded.
• **Standalone**: The article must make complete sense on its own.
  No references to "the proof above" or "our formal verification."

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 3 — Comprehensive RESEARCH PAPER  →  RESEARCH_PAPER.md
────────────────────────────────────────────────────────────────────────────
Write a **thorough, in-depth research paper** that a mathematician or
graduate student would find valuable. This is NOT a summary — it is a
complete, publishable-quality paper.

RESEARCH PAPER REQUIREMENTS:
• **Abstract**: Concise summary of contributions and significance.
• **Introduction**: Motivation, context, relationship to prior work.
• **Definitions & Notation**: Precise mathematical setup.
• **Main Results**: Full theorem statements with detailed proof sketches.
  Include the key ideas, not just "by induction."
• **Algorithms**: If the work produces algorithms, include complete
  pseudocode with complexity analysis (time, space, convergence).
• **Applications**: Concrete applications with worked examples.
  Show HOW to use the results in practice.
• **Computational Experiments**: Reference the Python demos.
  Include tables, charts, or numerical results.
• **Discussion**: Implications, limitations, open questions.
• **Future Work**: Specific, actionable next steps.
• **References**: Cite relevant prior work properly.
• **Length**: 3000–8000 words. Comprehensive and substantive.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 4 — Python Code: Demos, Visualizations, Algorithms
────────────────────────────────────────────────────────────────────────────
- **demo.py** — Working Python code demonstrating the theorems with
  concrete numerical examples. Make the math tangible.
- **visualizations** — matplotlib / plotly charts showing key mathematical
  structures, convergence behavior, phase diagrams, etc.
  Save figures as PNG/SVG files for inclusion in the HTML package.
- **algorithms.py** — Implement any algorithms from the research paper.
  Include docstrings, type hints, and example usage.
- **applications.py** — Code showing real-world applications of the results.
  If the math applies to ML, crypto, physics — show it working.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 5 — FUTURE_DIRECTIONS.md  (MANDATORY — drives next cycle)
────────────────────────────────────────────────────────────────────────────
The MOST IMPORTANT deliverable. Structured roadmap of breakthrough
research opportunities opened by this work. See detailed spec below.

────────────────────────────────────────────────────────────────────────────
DELIVERABLE 6 — JSON Data Package  →  PACKAGE.json
────────────────────────────────────────────────────────────────────────────
Create a **single JSON file** that bundles ALL artifacts for the web templating system.
Requirements:

• **Structure**: Output a strictly valid JSON object matching this schema:
  {
    "title": "Title of the Research",
    "domain": "Mathematical Domain",
    "article": "Markdown content...",
    "research_paper": "Markdown content...",
    "future_directions": "Markdown content...",
    "demos": [ { "name": "...", "code": "# Must be 100% self-contained. Do not import local files like 'algorithms'" } ],
    "algorithms": [ { "name": "...", "pseudocode": "..." } ],
    "visualizations": [ { "name": "...", "data": "base64 encoded URI or inline SVG string" } ],
    "lean_proofs": "Raw lean code..."
  }
• **String Encoding**: Ensure all Markdown and code is properly JSON-escaped (e.g. `
` for newlines).
• **Embedded images**: ALL images (charts, diagrams, visualizations) MUST be
  embedded directly in the JSON. If you generate matplotlib/plotly figures, convert them to base64
  data URIs (e.g., `data:image/png;base64,...`). For SVG diagrams, put the raw `<svg>...</svg>`
  string into the `data` field. NEVER reference external image files.
• **Complete**: Include ALL content from the article, research paper, and code. This JSON file
  is the sole data source for the frontend web application.

────────────────────────────────────────────────────────────────────────────

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real, useful, and
beautiful. Every deliverable should be something you'd be proud to show.

Research domain: Bridges
Research mode: formalize
