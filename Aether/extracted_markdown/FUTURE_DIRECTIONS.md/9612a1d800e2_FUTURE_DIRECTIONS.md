# Future Directions: Predicate Transport and Invariant-Determined Logic

## Overview

The predicate transport framework established in this work — invariant-determined predicates, factorization through invariants, covariant/contravariant transport, functorial composition, and Boolean closure — opens five concrete breakthrough research directions. Each is specific enough for a research team to pursue immediately, with clear hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Galois Connection Between Pushforward and Pullback Predicate Transformers

### Hypothesis

The pushforward and pullback operations on predicates along a theory morphism `f : TheoryHom T U` form a **Galois connection** between the posets of predicates on `T.Carrier` and `U.Carrier` (ordered by pointwise implication).

### Precise Formulation

Define:
- **Direct image (pushforward):** `f₊(P)(y) := ∃ x, f.toFun x = y ∧ P x`
- **Inverse image (pullback):** `f⁻¹(Q)(x) := Q (f.toFun x)`

Then the Galois connection states:
```
f₊(P) ≤ Q  ↔  P ≤ f⁻¹(Q)
```
where `≤` is pointwise implication.

### Proof Strategy

The forward direction: if `∀ y, (∃ x, f x = y ∧ P x) → Q y`, then for any `x`, `P x → Q (f x)` by specializing `y = f x` and using `⟨x, rfl, hPx⟩`.

The backward direction: if `∀ x, P x → Q (f x)`, and we have `⟨x, hfx, hPx⟩`, then `Q (f x)` holds, and since `f x = y`, we get `Q y`.

### Target Theorems

```lean
theorem pushforward_pullback_galois
    {T U : ResearchTheory} (f : TheoryHom T U)
    (P : T.Carrier → Prop) (Q : U.Carrier → Prop) :
    (∀ y, f.pushforward P y → Q y) ↔ (∀ x, P x → Q (f.toFun x))

theorem pullback_monotone
    {T U : ResearchTheory} (f : TheoryHom T U)
    {Q₁ Q₂ : U.Carrier → Prop} :
    (∀ y, Q₁ y → Q₂ y) → ∀ x, Q₁ (f.toFun x) → Q₂ (f.toFun x)

theorem pushforward_monotone
    {T U : ResearchTheory} (f : TheoryHom T U)
    {P₁ P₂ : T.Carrier → Prop} :
    (∀ x, P₁ x → P₂ x) → ∀ y, f.pushforward P₁ y → f.pushforward P₂ y
```

### Impact

Galois connections are the foundation of abstract interpretation. Proving this connection formally would link predicate transport to Cousot-style program analysis, enabling a formal soundness framework for abstraction-preserving compilation. This directly impacts certified ML deployment and secure compilation.

---

## Direction 2: Generalization to Lattice-Valued and Real-Valued Invariants

### Hypothesis

The entire predicate transport framework generalizes from `ℕ`-valued invariants to invariants valued in any **linearly ordered type** or **complete lattice**, with the factorization theorem and Boolean closure extending to the richer setting.

### Precise Formulation

Define a generalized theory:
```lean
structure GeneralTheory (α : Type*) [Preorder α] where
  Carrier : Type*
  Inv : Carrier → α
```

The invariant-determined predicate notion is identical:
```lean
def InvariantDetermined {α : Type*} [Preorder α]
    (T : GeneralTheory α) (P : T.Carrier → Prop) : Prop :=
  ∀ ⦃x y⦄, T.Inv x = T.Inv y → (P x ↔ P y)
```

Morphisms require `∀ x, T.Inv x ≤ U.Inv (f x)` in the preorder.

### Key Extensions

1. **Real-valued invariants** (`α = ℝ`): Handle Lipschitz constants, entropy values, collision probabilities as native invariants rather than discretized ℕ versions.

2. **Vector-valued invariants** (`α = ℝⁿ` with product order): Capture theories where objects have multiple independent quality measurements (e.g., both robustness AND efficiency).

3. **Lattice-valued invariants** (`α = L` a complete lattice): Model information-ordering domains where invariants form a lattice of approximations.

### Target Theorems

```lean
theorem generalTheory_factorization {α : Type*} [Preorder α]
    (T : GeneralTheory α) (P : T.Carrier → Prop) :
    InvariantDetermined T P ↔ ∃ R : α → Prop, ∀ x, P x ↔ R (T.Inv x)

theorem generalTheory_transport {α : Type*} [Preorder α]
    {T U : GeneralTheory α} (f : GeneralTheoryHom T U)
    {P : T.Carrier → Prop} (hP : InvariantDetermined T P)
    (hf : ∀ x, U.Inv (f.toFun x) = T.Inv x) :
    ∃ R, (∀ x, P x ↔ R (T.Inv x)) ∧
         TransferablePredicate f P (fun y => R (U.Inv y))
```

### Impact

Real-valued invariants would immediately connect to the existing `lipschitz_composition_bound` and `ShellPartition.collisionProb_upper_bound` catalog theorems, which use real-valued bounds. This eliminates the current mismatch between the ℕ-valued framework and the ℝ-valued theorems in the catalog.

---

## Direction 3: A Bundled Category of Theories with Predicate Transport Functors

### Hypothesis

The collection of research theories and theory morphisms forms a **category** (already verified), and predicate transport defines a **functor** from this category to the category of Boolean algebras with monotone maps.

### Precise Formulation

Define the functor:
- **On objects:** `T ↦ {P : T.Carrier → Prop | InvariantDetermined T P}` (a Boolean algebra)
- **On morphisms:** `f ↦ (P ↦ f₊(P))` where `f₊` is the pushforward restricted to invariant-determined predicates

The functor laws:
- `(id)₊ = id`: The identity morphism's pushforward is the identity on predicates
- `(g ∘ f)₊ = g₊ ∘ f₊`: Composition of pushforwards equals pushforward of composition

### Target Theorems

```lean
structure InvDetPred (T : ResearchTheory) where
  pred : T.Carrier → Prop
  inv_det : InvariantDetermined T pred

def InvDetPred.pushforward {T U : ResearchTheory}
    (f : TheoryHom T U) (P : InvDetPred T) : InvDetPred U

theorem InvDetPred.pushforward_id (T : ResearchTheory) (P : InvDetPred T) :
    InvDetPred.pushforward (TheoryHom.id T) P = P

theorem InvDetPred.pushforward_comp
    {T U V : ResearchTheory} (f : TheoryHom T U) (g : TheoryHom U V)
    (P : InvDetPred T) :
    InvDetPred.pushforward (TheoryHom.comp f g) P =
      InvDetPred.pushforward g (InvDetPred.pushforward f P)
```

### Impact

This makes the framework a genuine *categorical semantics* of certified reasoning. It opens the door to adjunctions, (co)limits of theories, and Kan extensions — powerful tools from category theory that would enable automatic construction of optimal transfer strategies.

---

## Direction 4: Modal Logic of Invariant-Observable Properties

### Hypothesis

Invariant-determined predicates define a **modal logic** where the modality "□P" (necessarily P) means "P is invariant-determined." This logic has a sound and complete axiomatization.

### Precise Formulation

Define the modal operators:
- **□P** ("necessarily P"): `P` holds for all objects with the same invariant value. Formally: `□P(x) := ∀ y, T.Inv y = T.Inv x → P y`
- **◇P** ("possibly P"): `P` holds for some object with the same invariant value. Formally: `◇P(x) := ∃ y, T.Inv y = T.Inv x ∧ P y`

### Key Properties

1. `□P → P` (T axiom: what is necessary is actual)
2. `□P → □□P` (4 axiom: necessity is necessarily necessary)
3. `P → □◇P` (B axiom: what is actual is necessarily possible)
4. `□(P → Q) → (□P → □Q)` (K axiom: distribution)
5. `InvariantDetermined T P ↔ (P ↔ □P)` (characterization: P is invariant-determined iff it equals its necessitation)

### Target Theorems

```lean
def Necessarily (T : ResearchTheory) (P : T.Carrier → Prop) : T.Carrier → Prop :=
  fun x => ∀ y, T.Inv y = T.Inv x → P y

def Possibly (T : ResearchTheory) (P : T.Carrier → Prop) : T.Carrier → Prop :=
  fun x => ∃ y, T.Inv y = T.Inv x ∧ P y

theorem necessarily_implies (T : ResearchTheory) (P : T.Carrier → Prop) (x : T.Carrier) :
    Necessarily T P x → P x

theorem invariantDetermined_iff_necessarily
    (T : ResearchTheory) (P : T.Carrier → Prop) :
    InvariantDetermined T P ↔ ∀ x, P x ↔ Necessarily T P x

theorem necessarily_invariantDetermined (T : ResearchTheory) (P : T.Carrier → Prop) :
    InvariantDetermined T (Necessarily T P)
```

### Impact

This would give engineers a formal *language* for reasoning about observability. In certified ML, "□(robust)" means "robustness is observable from the invariant alone" — exactly the condition needed for automatic certification transfer. The modal logic would provide a decision procedure for which properties can be certified from limited measurements.

---

## Direction 5: Automated Certification Pipelines via Reflexive Morphism Verification

### Hypothesis

If every transformation in a software deployment pipeline is registered as a theory morphism with a machine-verified monotonicity proof, then end-to-end certification reduces to **checking the pipeline registration** — no human mathematical reasoning is needed at deployment time.

### Architecture

```
Source Code  ──[compile]──→  IR  ──[optimize]──→  Bytecode  ──[deploy]──→  Runtime
    │                         │                       │                      │
    ▼                         ▼                       ▼                      ▼
  Theory₁ ───TheoryHom₁₂──→ Theory₂ ──TheoryHom₂₃──→ Theory₃ ──TheoryHom₃₄──→ Theory₄
    │                                                                          │
    └──── "invariant ≥ n" ──── transfers automatically ────────────────────────┘
```

### Required Formalizations

1. **Pipeline registration DSL**: A Lean macro for declaring pipeline stages as theory morphisms with auto-generated monotonicity obligations.

2. **Certificate propagation tactic**: A tactic that, given a proof of `∃ x, n ≤ T₁.Inv x` at the source, automatically constructs `∃ y, n ≤ T₄.Inv y` at the target by composing through the registered pipeline.

3. **Reflexive verification**: A decision procedure that checks whether a given function is a valid theory morphism by testing monotonicity on concrete inputs (a sound but incomplete check for infinite carriers, complete for finite ones).

### Target Artifacts

```lean
/-- Register a compilation pass as a theory morphism. -/
macro "register_pass" name:ident source:ident target:ident fun_body:term : command

/-- Automatically transport a certificate through a registered pipeline. -/
macro "transport_certificate" cert:term "through" pipeline:ident : tactic

/-- Decision procedure for monotonicity on finite carriers. -/
def checkMonotonicity [DecidableEq α] [Fintype α] [LE β] [DecidableRel (· ≤ · : β → β → Prop)]
    (T : GeneralTheory β) (U : GeneralTheory β)
    (f : T.Carrier → U.Carrier) : Bool
```

### Impact

This is the engineering capstone of the entire research program. It would transform predicate transport from a mathematical framework into an *automated certification tool*. Any software organization could register their deployment pipeline and get certified guarantee propagation for free. The mathematical theorems become invisible infrastructure — users never see a proof, they just get a certified deployment.

---

## Cross-Cutting Connections

| Direction | Connects To |
|---|---|
| 1 (Galois) | Abstract interpretation, program analysis, type systems |
| 2 (Lattice-valued) | Real analysis, measure theory, probability, information theory |
| 3 (Categorical) | Topos theory, fibered categories, doctrines |
| 4 (Modal logic) | Epistemic logic, observability, control theory |
| 5 (Automation) | Compiler verification, DevSecOps, MLOps certification |

Each direction reinforces the others: Galois connections (1) become functorial (3) when generalized to lattice-valued invariants (2), the modal logic (4) provides the user-facing language for the automated pipeline (5), and the categorical structure (3) ensures that all compositions are handled correctly by the automation (5).

---

## Priority Ranking

1. **Direction 1** (Galois connection): Highest mathematical value per effort. The proofs are elementary and the connection to abstract interpretation is immediate.

2. **Direction 2** (Lattice-valued): Highest practical value. Real-valued invariants unlock most catalog theorem instantiations.

3. **Direction 4** (Modal logic): Most conceptually novel. Would attract attention from the logic and philosophy of science communities.

4. **Direction 3** (Categorical): Most architecturally important. Provides the organizing framework for all future development.

5. **Direction 5** (Automation): Highest engineering impact but requires the most infrastructure work. Should build on 1–4.
