## Assignment: Algebra–Tropical–Cryptography — Tropical Choquet–Radon Trapdoor Duality via Idempotent Convex Semimodules and Certified Extremal Decomposition

**Mode:** prove

Build a genuinely new bridge theorem, not an incremental variant. The target is a mathematically sharp and formally meaningful duality: on a rigid tropical convex class, extremal decomposition is canonically recoverable from Radon-style data; outside that class, congruence-level collapse forces cryptographic ambiguity. This is the seed of a new subject: **tropical convex cryptography**.

Work in:

`Bridges/AlgebraTropicalCryptography/TropicalChoquetRadonTrapdoorDuality.lean`

and explicitly build on the verified theorem

- `certified_finite_tropical_decomposition`
  from `Bridges/AlgebraEML/TropicalChoquetClosureDuality.lean`

and, where relevant, the obstruction technology behind

- `tropical_hash_collision_obstruction`

The breakthrough is not “another tropical decomposition theorem.” The breakthrough is to formalize a **duality between geometric exposedness and algorithmic invertibility**, with a matching **obstruction theorem** showing that failure of exposedness creates cryptographic collision families. That is a field-opening statement.

---

## Precise Theorem Package

You should introduce a finite, formalizable abstraction of a tropical Choquet system. Keep it discrete/finite so Lean can certify the core phenomenon now, while leaving the analytic compact version to future work.

### Core structures to define

You likely need a structure along the lines of:

- a finite type `E` of extremal generators,
- a coefficient semiring `S` with `CanonicallyOrderedCommSemiring` / idempotent-max-plus style assumptions as needed,
- a carrier type `M`,
- an evaluation map from coefficient profiles on `E` into `M`,
- a predicate `IsSupportOf : Finset E → M → Prop`,
- a Radon profile map `radonProfile : M → R` for some finite profile type `R`,
- an exposedness/separation predicate encoded finitely.

Do **not** over-axiomatize. Make the weakest finite interface needed to prove the four theorems below.

---

## Theorem 1: Canonical Minimal Extremal Support

Formal target: every element has a canonical minimal support, obtained as the intersection of all supports of certified decompositions.

### Mathematical statement

Let `S` be a finitely generated commutative idempotent semiring, `E` a finite type of extremal generators, and `M` a finite tropical convex `S`-semimodule equipped with a finite Choquet representation system. Assume every `x : M` admits at least one certified finite tropical decomposition over `E`. Then for every `x : M`, there exists a unique minimal support `suppC x : Finset E` such that:

1. `suppC x` supports a certified decomposition of `x`,
2. for any support `T` of a certified decomposition of `x`, one has `suppC x ⊆ T`,
3. hence `suppC x` is the intersection of all decomposition supports of `x`.

This is the tropical analogue of a finite Choquet–Radon canonical support theorem.

### Lean 4 type signature target

A plausible target shape is:

```lean
theorem exists_unique_minimal_extremal_support
  {S E M : Type*}
  [Fintype E] [DecidableEq E]
  [CommSemiring S]
  (TC : TropicalChoquetSystem S E M)
  (hdecomp : ∀ x : M, ∃ w : E → S, TC.Represents x w) :
  ∀ x : M,
    ∃! K : Finset E,
      TC.Supports x K ∧
      ∀ L : Finset E, TC.Supports x L → K ⊆ L
```

and then define

```lean
noncomputable def suppC ... (x : M) : Finset E := ...
```

with a theorem

```lean
theorem suppC_eq_iInter_supports
  ...
  : TC.suppC x =
      Finset.unbiUnion
        (TC.allMinimalSupportWitnesses x) ...
```

If literal intersection over all support finsets is awkward, prove the universal minimality statement and derive the “intersection characterization” as a theorem.

### Why this matters

This theorem creates the **private key object**: the canonical extremal support. Without a canonical support notion, “trapdoor inversion” is just rhetoric. With it, tropical convex decomposition becomes a cryptographic state space.

---

## Theorem 2: Radon Inversion on the Separated/Exposed Class

Formal target: under a finite separation axiom, the Radon profile uniquely determines the canonical support.

### Mathematical statement

Assume additionally that the tropical Choquet system satisfies a separation condition: distinct exposed extremals are distinguished by a finite family of prime-congruence-compatible Radon tests. Then for all `x y : M`,

- if `radonProfile x = radonProfile y`,
- and both `x, y` lie in the separated/exposed subclass,

then `suppC x = suppC y`.

Equivalently, on the rigid subclass, the public Radon profile determines the canonical extremal support.

This should be stated support-first, not necessarily element-first. The most formalizable version is:

> if two certified decompositions have distinct minimal supports, then their Radon profiles differ.

### Lean 4 type signature target

```lean
theorem radonProfile_injective_on_support
  {S E M P : Type*}
  [Fintype E] [DecidableEq E] [DecidableEq P]
  [CommSemiring S]
  (TC : TropicalChoquetSystem S E M)
  (RP : TropicalRadonSystem E M P)
  (hsep : TC.HasPrimeCongruenceSeparation RP)
  :
  ∀ {x y : M},
    TC.ExposedSeparated x →
    TC.ExposedSeparated y →
    RP.profile x = RP.profile y →
    TC.suppC x = TC.suppC y
```

A stronger support-level version is even better:

```lean
theorem radonProfile_separates_minimal_supports
  ...
  : ∀ {x y : M},
      TC.ExposedSeparated x →
      TC.ExposedSeparated y →
      TC.suppC x ≠ TC.suppC y →
      RP.profile x ≠ RP.profile y
```

### Why this matters

This is the public-key half of the story. The Radon profile is the **public image**; the support is the **hidden sparse structure**. On the rigid class, inversion is possible in principle and canonical. This is a tropical-geometric analogue of “structured one-wayness with a trapdoor subclass.”

---

## Theorem 3: Trapdoor Rigidity / Certified Recovery

Formal target: on semimodules with a certified exposed-extremal basis, support recovery is algorithmic by monotone elimination.

### Mathematical statement

Assume the exposed extremals admit a certified elimination ordering such that each Radon coefficient rules out a monotone family of impossible extremals, and assume soundness/completeness of these elimination rules. Then there exists a support recovery algorithm which, on input `radonProfile x`, returns `suppC x` for every exposed-separated `x`.

In Lean, you do not need machine complexity theory. Formalize **structural polynomial-time rigidity** as a finite elimination algorithm with monotonicity, termination, and exactness. If you can define a cost function bounded by `Fintype.card E ^ 2` or similar, excellent; otherwise prove exact termination in at most `card E` elimination steps.

### Lean 4 type signature target

```lean
def recoverSupport
  {S E M P : Type*}
  [Fintype E] [DecidableEq E] [DecidableEq P]
  [CommSemiring S]
  (TC : TropicalChoquetSystem S E M)
  (RP : TropicalRadonSystem E M P)
  : P → Finset E := ...

theorem recoverSupport_correct
  {S E M P : Type*}
  [Fintype E] [DecidableEq E] [DecidableEq P]
  [CommSemiring S]
  (TC : TropicalChoquetSystem S E M)
  (RP : TropicalRadonSystem E M P)
  (htrap : TC.HasCertifiedExposedBasis RP)
  :
  ∀ x : M,
    TC.ExposedSeparated x →
    recoverSupport TC RP (RP.profile x) = TC.suppC x
```

If possible, also prove a step bound:

```lean
theorem recoverSupport_terminates_bound
  ...
  : ∀ p : P, (recoverTrace TC RP p).length ≤ Fintype.card E
```

### Why this matters

This theorem is the actual **trapdoor**. The prior theorem says inversion is unique; this theorem says inversion is **certifiably executable** on the rigid subclass. That is the mathematical skeleton of a tropical public-key primitive.

---

## Theorem 4: Obstruction / Collision Families under Non-Exposedness

Formal target: failure of exposedness produces distinct supports with identical public Radon profiles.

### Mathematical statement

Assume exposedness fails. Then there exist `x y : M` such that:

1. `suppC x ≠ suppC y`,
2. `radonProfile x = radonProfile y`,
3. the supports are valuation-congruent / prime-congruence indistinguishable.

A support-level version is preferable:

> there exist distinct support sets `K ≠ L` and represented points `x_K, x_L` with minimal supports `K, L` respectively, but identical Radon profiles.

This should explicitly connect to `tropical_hash_collision_obstruction`: not by analogy, but by transporting the obstruction principle from “collision under tropical hashing” to “collision under tropical support projection.”

### Lean 4 type signature target

```lean
theorem exists_collision_of_not_exposed
  {S E M P : Type*}
  [Fintype E] [Nonempty E] [DecidableEq E] [DecidableEq P]
  [CommSemiring S]
  (TC : TropicalChoquetSystem S E M)
  (RP : TropicalRadonSystem E M P)
  (hfail : ¬ TC.GlobalExposedness RP)
  :
  ∃ x y : M,
    TC.suppC x ≠ TC.suppC y ∧
    RP.profile x = RP.profile y
```

A sharper theorem with congruence indistinguishability is even better:

```lean
theorem exists_valuation_congruent_collision
  ...
  : ∃ x y : M,
      TC.suppC x ≠ TC.suppC y ∧
      RP.profile x = RP.profile y ∧
      TC.ValuationCongruent x y
```

### Why this matters

This is the hardness side. Without it, the story is just “recovery works in nice cases.” With it, you get a genuine dichotomy:

- **rigid exposed class** ⇒ canonical inversion,
- **non-exposed class** ⇒ forced ambiguity/collisions.

That is a mathematically clean analogue of trapdoor-vs-collision separation.

---

## Recommended Build Order

1. **Finite support infrastructure**
   - define support of a decomposition,
   - define `Supports x K`,
   - prove support monotonicity,
   - import and reuse `certified_finite_tropical_decomposition`.

2. **Canonical support extraction**
   - prove existence of at least one support,
   - prove finite intersection/minimality lemma,
   - define `suppC`.

3. **Radon separation**
   - define finite Radon profile,
   - define exposed/separated predicate,
   - prove support separation from profile separation.

4. **Recovery algorithm**
   - define elimination step,
   - prove monotonicity and invariant preservation,
   - prove exactness on exposed-separated points.

5. **Obstruction theorem**
   - formulate failure of exposedness,
   - derive indistinguishable pairs,
   - connect to collision obstruction pattern.

---

## Proof Strategy Paths

### Strategy A: Finite order-theoretic core via support posets
Most promising.

1. Model all supports of decompositions of `x` as a finite nonempty set of `Finset E`.
2. Use finite minimal-element arguments under `⊆` to obtain a minimal support.
3. Upgrade minimality to uniqueness by imposing a support intersection stability axiom or a certified anti-exchange/exposedness property.
4. Then prove Radon injectivity by contradiction: if two minimal supports differ, separation supplies a Radon test distinguishing an extremal in the symmetric difference.

**Why promising:** Lean handles finite posets and `Finset` arguments very well. This route minimizes analytic baggage and turns Choquet language into combinatorial convexity.

### Strategy B: Certificate-first approach using the existing decomposition theorem
Exploit `certified_finite_tropical_decomposition` as the primitive object.

1. Refactor the output of `certified_finite_tropical_decomposition` into a support-bearing witness.
2. Define canonical support as the support of a decomposition with a minimality certificate.
3. Package Radon inversion as a theorem about equality of certificates modulo prime-congruence tests.
4. Derive algorithmic recovery by replaying certificate elimination.

**Why promising:** This reuses catalog infrastructure directly and keeps the formal development close to already verified proof patterns.

### Strategy C: Galois-style duality between supports and Radon tests
Most visionary, but riskier.

1. Define a closure operator on `Finset E` induced by equality of Radon profiles.
2. Show exposed supports are exactly the closed points/fixed points of this operator.
3. Prove canonical support as a nucleus/interior of the support lattice.
4. Derive collision families from non-Hausdorffness of the induced congruence space.

**Why important:** If it works, this gives a conceptual duality theorem, not just a set of lemmas. But it is more abstract and may be heavier in Lean. Use this if the finite infrastructure stabilizes cleanly.

---

## Cross-Domain Connections You Should Make Explicit

This project becomes revolutionary only if you articulate the unexpected bridges.

### 1. Tropical convexity × cryptography
Canonical extremal support is the hidden sparse key; Radon profile is the public image. Exposedness becomes an **invertibility criterion**, while non-exposedness becomes a **collision mechanism**.

### 2. Idempotent functional analysis × integral geometry
The Choquet side contributes decomposition into extremals; the Radon side contributes measurement/projection data. Their compatibility is a tropical version of “tomography of sparse convex states.”

### 3. Prime congruences × hardness/ambiguity
Prime semiring congruences play the role of indistinguishability relations. This is not metaphorical: they are the algebraic source of support collapse. That is the right language for formal obstruction.

### 4. Matroid/anti-exchange geometry × support uniqueness
If you can identify an anti-exchange or convex-geometry style axiom on supports, then canonical decomposition resembles basis recovery in greedoid/matroid theory. This may sharpen the trapdoor class.

### 5. Sparse recovery/compressed sensing × tropical inversion
On the rigid class, the recovery theorem is a tropical analogue of exact sparse support recovery from measurement data. The obstruction theorem says the usual uniqueness assumptions are not optional.

### 6. Public-key semantics × geometric tomography
A sender publishes a Radon profile; only someone with certified exposed-basis structure can recover the hidden support efficiently. This is a geometric trapdoor model, not number-theoretic factoring.

---

## How to Use Existing Catalog Theorems

### `certified_finite_tropical_decomposition`
Use it as the **existence engine** for support witnesses. Extract:
- a finite decomposition witness,
- its support finset,
- any minimality/certification data already present.

If the theorem is slightly misaligned, prove a wrapper lemma translating its conclusion into your `Supports` predicate.

### `tropical_hash_collision_obstruction`
Use it as the **obstruction pattern**:
- identify the algebraic collapse mechanism there,
- abstract the same congruence-collapse logic to Radon profiles of supports,
- show that non-exposedness induces the same style of collision family.

Do not merely cite it. Transport its proof architecture.

---

## Minimal Formal Definitions Worth Introducing

You likely need finite versions of:

```lean
structure TropicalChoquetSystem (S E M : Type*) :=
  (Represents : M → (E → S) → Prop)
  (Supports : M → Finset E → Prop)
  (support_sound :
    ∀ {x w}, Represents x w →
      Supports x ((Finset.univ.filter fun e => w e ≠ 0)))
  (support_complete :
    ∀ {x K}, Supports x K →
      ∃ w : E → S, Represents x w ∧
        ∀ e, w e ≠ 0 → e ∈ K)
```

and

```lean
structure TropicalRadonSystem (E M P : Type*) :=
  (profile : M → P)
  (separates :
    Finset E → Finset E → Prop)
```

plus predicates such as:

```lean
def ExposedSeparated ... : M → Prop := ...
def HasPrimeCongruenceSeparation ... : Prop := ...
def HasCertifiedExposedBasis ... : Prop := ...
def GlobalExposedness ... : Prop := ...
def ValuationCongruent ... : M → M → Prop := ...
```

Keep these finite and proof-oriented.

---

## Technical Lemmas Likely Needed

1. `Supports` is upward closed:
```lean
theorem supports_mono ...
  : TC.Supports x K → K ⊆ L → TC.Supports x L
```

2. Finite minimal support extraction:
```lean
theorem exists_minimal_support ...
  : ∀ x, ∃ K, TC.Supports x K ∧ ∀ L, TC.Supports x L → K ⊆ L
```

3. Uniqueness from intersection stability or exposedness:
```lean
theorem minimal_support_unique ...
  : ...
```

4. Symmetric-difference witness lemma:
if `K ≠ L`, choose `e ∈ K \ L ∪ L \ K`.

5. Separation-to-profile-distinction lemma:
```lean
theorem distinguished_extremal_gives_profile_neq ...
```

6. Elimination invariant:
recovery never removes an element of the true support.

7. Completeness of elimination:
every non-support extremal is eventually removed.

8. Obstruction extraction:
failure of global exposedness yields distinct supports indistinguishable by all Radon tests.

---

## Application Keywords

Include these explicitly in comments/docstrings and theorem discussions:

- tropical convex cryptography
- idempotent convex semimodules
- tropical Choquet theory
- tropical Radon inversion
- canonical extremal support
- exposed extremals
- prime congruence separation
- valuation collapse
- collision families
- trapdoor inversion
- sparse support recovery
- tropical tomography
- idempotent functional analysis
- semiring cryptography
- geometric one-way structures

---

## Revolutionary Significance

If you complete this theorem package, you will have created a new formal paradigm:

- a **geometric cryptography** based on tropical convex decomposition,
- a **duality principle** between exposedness and invertibility,
- a **collision theorem** rooted in semiring congruence collapse,
- and a reusable finite formal framework connecting idempotent analysis, tropical geometry, and algorithmic hardness.

This is not a variant of prior tropical one-way minors or Hecke trapdoors. It is a new primitive: **hidden extremal support under public Radon data**.

That opens follow-on programs in:
- tropical compressed sensing,
- semiring tomography,
- cryptographic hardness from non-uniqueness of idempotent decompositions,
- and formalized tropical integral geometry.

---

## Deliverables

1. Theorems 1–4 above, in Lean 4, with minimal `sorry`.
2. Supporting definitions and lemmas, designed for reuse.
3. Clear module documentation explaining the rigid/exposed class versus obstruction class.
4. A structured `FUTURE_DIRECTIONS.md` containing **3–5 concrete breakthrough-level next steps**, for example:
   - infinite/compact Choquet versions with topological hypotheses,
   - tropical compressed sensing analogues of RIP/coherence,
   - cryptographic protocol semantics for support-hiding keys,
   - matroidal characterization of exposed-support recoverability,
   - lower bounds on collision multiplicity under congruence collapse.

Be bold: prove the finite theorem package in a way that makes the next cycle inevitable.

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

@Speculative/AutoResearch/TropicalOneWayFunctions.lean
```lean
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical One-Way Functions and Min-Plus Cryptographic Primitives

## Bridge: Tropical Algebra ↔ Post-Quantum Cryptography ↔ Certified ML Robustness

The min-plus semiring (ℝ, min, +) harbors a deep computational asymmetry:
tropical matrix powering is computable in O(n³ log k), yet recovering k from
M and M^⊗k (the tropical discrete logarithm) appears to require Ω(2^n) time.

## Main Results (30+ theorems, 0 sorry)

### Algebraic Foundations
* `tropMul_assoc` — min-plus multiplication is associative
* `minplus_left_distrib` — tropical distributivity
* `minplus_idem` — min(a,a) = a

### Metric Theory & Lipschitz Bounds
* `tropDist_triangle` — triangle inequality for sup-norm
* `min_lipschitz_bound` — |min(a,c) - min(b,c)| ≤ |a - b|
* `tropLinMap_nonexpansive` — tropical linear maps are 1-Lipschitz

### Certified ML Robustness
* `certified_robustness_from_margin` — margin + Lipschitz ⟹ stable classification
* `certified_robustness_multivariate` — extends to ℝⁿ classifiers

### Cryptographic Primitives
* `tropical_security_exponential_gap` — n³ < 2ⁿ for n ≥ 10
* `tropical_idempotent_quantum_obstruction` — no cyclic group in idempotent monoid
* `tropical_post_quantum_framework` — master security chain
-/

noncomputable section

open Finset BigOperators

set_option maxHeartbeats 1600000
set_option linter.unusedVariables false

namespace TropicalOWF

/-! ## Section 1: Min-Plus Matrix Multiplication

(A ⊗ B)ᵢⱼ = min_k (Aᵢₖ + Bₖⱼ)

Bridge: graph theory (shortest paths) → tropical algebra → cryptography -/

/-- **Min-plus matrix multiplication** over `ℝ`.
    Bridge: connects shortest-path algorithms to tropical algebraic structure. -/
def tropMul {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.univ.inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => A i k + B k j)

theorem tropMul_entry_le {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j k : Fin n) : tropMul hn A B i j ≤ A i k + B k j :=
  Finset.inf'_le _ (Finset.mem_univ k)

theorem tropMul_exists_witness {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) : ∃ k, tropMul hn A B i j = A i k + B k j := by
  obtain ⟨k, _, hk⟩ := Finset.exists_mem_eq_inf' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)
    (fun k => A i k + B k j)
  exact ⟨k, hk⟩

/-- **Transpose anti-homomorphism.** (A ⊗ B)ᵀ = Bᵀ ⊗ Aᵀ. -/
theorem tropMul_transpose {n : ℕ} (hn : 0 < n) (A B : Matrix (Fin n) (Fin n) ℝ) :
    Matrix.transpose (tropMul hn A B) =
    tropMul hn (Matrix.transpose B) (Matrix.transpose A) := by
  ext i j; simp only [tropMul, Matrix.transpose_apply]; congr 1; ext k; ring

/-- **Min-plus products preserve entry bounds.** -/
theorem tropMul_preserves_bound {n : ℕ} (hn : 0 < n)
    (A B : Matrix (Fin n) (Fin n) ℝ) (MA MB : ℝ)
    (hA : ∀ i j, A i j ≤ MA) (hB : ∀ i j, B i j ≤ MB) :
    ∀ i j, tropMul hn A B i j ≤ MA + MB := by
  intro i j
  calc tropMul hn A B i j ≤ A i ⟨0, hn⟩ + B ⟨0, hn⟩ j :=
      tropMul_entry_le hn A B i j ⟨0, hn⟩
    _ ≤ MA + MB := add_le_add (hA _ _) (hB _ _)

/-
**Min-plus multiplication is associative.**
    Bridge: semigroup theory → tropical geometry → cryptographic group actions
-/
theorem tropMul_assoc {n : ℕ} (hn : 0 < n) (A B C : Matrix (Fin n) (Fin n) ℝ) :
    tropMul hn (tropMul hn A B) C = tropMul hn A (tropMul hn B C) := by
  -- By definition of min-plus multiplication, we have:
  funext i j;
  refine' le_antisymm _ _;
  · -- By definition of min-plus multiplication, we have that for any $i, j$, $(A \otimes B)_{ij} = \min_{k} (A_{ik} + B_{kj})$.
    simp [tropMul];
    intro b;
    obtain ⟨ k, hk ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty_iff.mpr ⟨ b ⟩ ) ( fun k => B b k + C k j ) ; use k; simp_all +decide [ Finset.inf'_le ] ;
    linarith [ Finset.inf'_le ( fun k_1 => A i k_1 + B k_1 k ) ( Finset.mem_univ b ) ];
  · obtain ⟨ k, hk ⟩ := tropMul_exists_witness hn ( tropMul hn A B ) C i j;
    obtain ⟨ m, hm ⟩ := tropMul_exists_witness hn A B i k;
    refine' le_trans ( tropMul_entry_le hn A ( tropMul hn B C ) i j m ) _;
    linarith [ tropMul_entry_le hn B C m j k ]

/-! ## Section 2: Tropical Matrix Powers -/

/-- **Tropical identity matrix**: 0 on diagonal, T off-diagonal. -/
def tropId {n : ℕ} (T : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => if i = j then 0 else T

/-- **Tropical matrix power**: M^⊗k.
    Bridge: connects exponentiation in tropical semiring to cryptographic OWF. -/
def tropMatPow {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ) :
    ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => tropId T
  | k + 1 => tropMul hn (tropMatPow hn M T k) M

@[simp] theorem tropMatPow_zero {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ) :
    tropMatPow hn M T 0 = tropId T := rfl

@[simp] theorem tropMatPow_succ {n : ℕ} (hn : 0 < n) (M : Matrix (Fin n) (Fin n) ℝ) (T : ℝ)
    (k : ℕ) : tropMatPow hn M T (k + 1) = tropMul hn (tropMatPow hn M T k) M := rfl

theorem tropId_diagonal {n : ℕ} (T : ℝ) (i : Fin n) : tropId T i i = 0 := if_pos rfl

theorem tropId_off_diagonal {n : ℕ} (T : ℝ) (i j : Fin n) (hij : i ≠ j) :
    tropId T i j = T := if_neg hij

/-! ## Section 3: Tropical Distance (Sup-Norm) -/

/-- **Tropical distance** (sup-norm).
    Bridge: connects tropical geometry to lattice cryptography. -/
def tropDist {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun i => |x i - y i|)

theorem tropDist_nonneg {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) : 0 ≤ tropDist hn x y :=
  le_trans (abs_nonneg _) (Finset.le_sup' (fun i => |x i - y i|) (Finset.mem_univ ⟨0, hn⟩))

theorem tropDist_symm {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) :
    tropDist hn x y = tropDist hn y x := by
  simp only [tropDist]; congr 1; ext i; rw [abs_sub_comm]

theorem tropDist_self {n : ℕ} (hn : 0 < n) (x : Fin n → ℝ) : tropDist hn x x = 0 := by
  unfold tropDist
  have : (fun i : Fin n => |x i - x i|) = fun _ => (0 : ℝ) := by ext; simp
  rw [this]
  exact Finset.sup'_const _ _

theorem tropDist_coord_le {n : ℕ} (hn : 0 < n) (x y : Fin n → ℝ) (i : Fin n) :
    |x i - y i| ≤ tropDist hn x y :=
-- ... (truncated, full file has 400 lines)
```

@Speculative/AutoResearch/Bridges/TropicalValuationFunctor.lean
```lean
/-
  # Tropical Valuation Functor:
  # The Bridge Between Multiplicative Algebra, p-Adic Analysis,
  # and Post-Quantum Lattice Security

  ## Domain Bridge: Tropical Geometry ↔ p-Adic Analysis ↔ Lattice Cryptography ↔ Neural Network Robustness

  The central discovery: The p-adic valuation is a *functor* from multiplicative
  algebra to tropical (min-plus) algebra that preserves exactly the structure needed for:
  - Post-quantum lattice security reductions (hardness amplification)
  - Lipschitz-certified neural network robustness (composition bounds)
  - Algorithmic complexity classification (tropical circuit complexity)

  The valuation map v_p : (ℤ_p \ {0}, ×) → (ℤ, +) sends:
  - multiplication ↦ addition
  - divisibility ↦ order
  - gcd ↦ min (tropical multiplication)

  ## Main Results (35+ theorems, zero sorry)

  ## Structures (8 novel types)

  - `TropicalSemiringCertificate` — certified min-plus algebraic structure
  - `ValuationDepthMeasure` — complexity measure via p-adic depth
  - `LipschitzCompositionChain` — chain of Lipschitz maps with certified bound
  - `SpectralAmplificationCertificate` — spectral gap amplification bounds
  - `CertifiedRobustnessWitness` — end-to-end adversarial robustness certificate
  - `TropicalSecurityParameter` — post-quantum security from tropical rank
  - `TropicalHashFunction` — hash function with tropical collision resistance
  - `TropicalDistanceMetric` — tropical metric structure
-/

import Mathlib

open Finset BigOperators

noncomputable section

namespace TropicalValuationFunctor

/-! ## §1. Tropical Arithmetic Infrastructure

The tropical semiring (ℝ ∪ {+∞}, ⊕, ⊗) where:
  a ⊕ b = min(a, b)     (tropical addition)
  a ⊗ b = a + b          (tropical multiplication) -/

set_option checkBinderAnnotations false in
/-- **TropicalSemiringCertificate**: A certificate that a linearly ordered
    additive type carries tropical semiring structure.
    Bridge: connects abstract algebra to quantitative crypto bounds.
    Impact: post_quantum_security, lattice_crypto. -/
structure TropicalSemiringCertificate (α : Type*) [LinearOrder α] [Add α] where
  /-- Tropical addition (min) is commutative -/
  tropAdd_comm : ∀ a b : α, min a b = min b a
  /-- Tropical addition (min) is associative -/
  tropAdd_assoc : ∀ a b c : α, min (min a b) c = min a (min b c)
  /-- Tropical multiplication (add) is commutative -/
  tropMul_comm : ∀ a b : α, a + b = b + a
  /-- Tropical multiplication distributes over tropical addition -/
  tropDistrib : ∀ a b c : α, a + min b c = min (a + b) (a + c)

/-- **ℤ is a tropical semiring**. -/
def int_tropical_certificate : TropicalSemiringCertificate ℤ where
  tropAdd_comm := min_comm
  tropAdd_assoc := min_assoc
  tropMul_comm := add_comm
  tropDistrib := fun a b c => (min_add_add_left a b c).symm

/-- **ℕ is a tropical semiring**. -/
def nat_tropical_certificate : TropicalSemiringCertificate ℕ where
  tropAdd_comm := min_comm
  tropAdd_assoc := min_assoc
  tropMul_comm := add_comm
  tropDistrib := fun a b c => (min_add_add_left a b c).symm

/-- **ℝ is a tropical semiring**. -/
def real_tropical_certificate : TropicalSemiringCertificate ℝ where
  tropAdd_comm := min_comm
  tropAdd_assoc := min_assoc
  tropMul_comm := add_comm
  tropDistrib := fun a b c => (min_add_add_left a b c).symm

/-- **Tropical commutativity is universal**: min is commutative in any linear order.
    Bridge: connects ordered algebra to tropical structure (Algebra ↔ Tropical). -/
theorem tropical_min_comm {α : Type*} [LinearOrder α] (a b : α) :
    min a b = min b a := min_comm a b

/-- **Tropical distributivity over ℤ**: a + min(b,c) = min(a+b, a+c). -/
theorem tropical_distrib_int (a b c : ℤ) :
    a + min b c = min (a + b) (a + c) := (min_add_add_left a b c).symm

/-- **Tropical distributivity over ℝ**: a + min(b,c) = min(a+b, a+c). -/
theorem tropical_distrib_real (a b c : ℝ) :
    a + min b c = min (a + b) (a + c) := (min_add_add_left a b c).symm

/-- **Tropical idempotency**: min(a, a) = a. Distinguishes tropical from classical. -/
theorem tropical_idempotent {α : Type*} [LinearOrder α] (a : α) :
    min a a = a := min_self a

/-- **Tropical absorption**: min(a, a + b) = a when b ≥ 0.
    Adding a non-negative "cost" never decreases the tropical sum. -/
theorem tropical_absorption (a b : ℤ) (hb : 0 ≤ b) :
    min a (a + b) = a := by simp [min_def]; omega

/-! ## §2. Valuation Depth Measure -/

/-- **ValuationDepthMeasure**: Complexity measure based on p-adic depth.
    Bridge: connects number theory to post-quantum security parameters.
    Impact: post_quantum_security, lattice_crypto. -/
structure ValuationDepthMeasure where
  /-- The prime base -/
  prime : ℕ
  /-- Primality certificate -/
  isPrime : Nat.Prime prime

/-- **Valuation additive on products**: v_p(ab) = v_p(a) + v_p(b).
    The *homomorphism property* making v_p a tropical functor.
    Bridge: connects multiplicative structure to tropical addition.
    Impact: tropical_hash_collision resistance bounds. -/
theorem valuation_additive_on_products (p a b : ℕ) (hp : Nat.Prime p)
    (ha : a ≠ 0) (hb : b ≠ 0) :
    padicValNat p (a * b) = padicValNat p a + padicValNat p b := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.mul ha hb

/-- **Valuation of prime powers**: v_p(p^k) = k.
    Bridge: connects exponentiation to tropical scaling. -/
theorem valuation_prime_power (p k : ℕ) (hp : Nat.Prime p) :
    padicValNat p (p ^ k) = k := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.prime_pow k

/-- **Valuation of prime itself**: v_p(p) = 1. -/
theorem valuation_prime_self (p : ℕ) (hp : Nat.Prime p) :
    padicValNat p p = 1 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  exact padicValNat.self hp.one_lt

/-- **Valuation of 1**: v_p(1) = 0. The unit maps to tropical zero. -/
theorem valuation_one (p : ℕ) : padicValNat p 1 = 0 := by simp

/-- **Valuation bounds power divisibility**: p^(v_p(n)) | n.
    Bridge: connects valuation to divisibility lattice. -/
theorem valuation_power_dvd (p n : ℕ) (hp : Nat.Prime p) :
    p ^ padicValNat p n ∣ n :=
  haveI : Fact (Nat.Prime p) := ⟨hp⟩; pow_padicValNat_dvd

/-- **Iterated valuation**: v_p(p^a · p^b) = a + b.
    Bridge: tropical multiplication = ordinary addition of exponents. -/
theorem valuation_iterated (p a b : ℕ) (hp : Nat.Prime p) :
-- ... (truncated, full file has 531 lines)
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
    "algorithms": [ { "name": "...", "pseudocode": "...", "code": "executable Python implementation" } ],
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
Research mode: prove
