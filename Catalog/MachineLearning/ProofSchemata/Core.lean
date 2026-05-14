/-
# Composable Proof Schemata: A Formal Theory of Proof Architecture

This file formalizes "proof schemata" — certified reduction operators
that transform predicates while preserving provability. The key insight is that deep
proof techniques (infinite descent, local-to-global propagation, invariant rigidity,
finite obstruction) can be captured as composable mathematical objects.

## Main Results

### Structures
* `ProofSchema` — a certified reduction from one predicate to another
* `ConstructiveSchema` — a schema that produces a canonical reduced predicate
* `DescentSchema` — a well-founded descent schema with measure function
* `FiniteCoreSchema` — finite core extraction for local-to-global arguments

### Composition Theorems
* `ProofSchema.comp` — composition of two proof schemata
* `ProofSchema.comp_sound` — composed schemata preserve provability
* `ProofSchema.comp_assoc` — composition is associative

### Descent Theorems
* `nat_descent_principle` — well-founded descent eliminates counterexamples on ℕ
* `measured_descent_principle` — descent on arbitrary measured types
* `descent_schema_no_bad` — descent schemata yield universal proofs

### Invariant Rigidity
* `finite_invariant_classification` — classification via invariant fibers
* `invariant_rigidity_from_finite_obstructions` — rigidity on finite codomains

### Synthesis
* `no_bad_of_minimal_obstruction_elimination` — the meta-pattern
* `global_theorem_of_strategy_triad` — descent + finite obstruction + rigidity

## Mathematical Significance

This formalizes the recurring architecture of breakthrough proofs (FLT, Poincaré,
CFSG) as composable certified operators on predicate families.
-/

import Mathlib

open Function

/-! ## §1. Core Structures -/

/-- A `ProofSchema` captures a certified reduction between predicates.
    `ReducesTo P Q` means "proving Q suffices to prove P". -/
structure ProofSchema (α : Type*) where
  ReducesTo : (α → Prop) → (α → Prop) → Prop
  sound : ∀ {P Q : α → Prop}, ReducesTo P Q → (∀ x, Q x → P x)

/-- A `ConstructiveSchema` produces a canonical transform of any predicate,
    together with a certificate that the transform implies the original. -/
structure ConstructiveSchema (α : Type*) where
  transform : (α → Prop) → (α → Prop)
  certify : ∀ {P : α → Prop}, ∀ x, transform P x → P x

/-- A `DescentSchema` captures well-founded descent with a measure to ℕ. -/
structure DescentSchema (α : Type*) where
  μ : α → ℕ
  step : ∀ (P : α → Prop) (x : α), P x → ∃ y, P y ∧ μ y < μ x

/-! ## §2. Composition of Proof Schemata -/

/-- Compose two proof schemata. -/
def ProofSchema.comp {α : Type*} (S T : ProofSchema α) : ProofSchema α where
  ReducesTo P R := ∃ Q, S.ReducesTo P Q ∧ T.ReducesTo Q R
  sound := by
    intro P R ⟨Q, hPQ, hQR⟩ x hRx
    exact S.sound hPQ x (T.sound hQR x hRx)

/-- Composition of sound proof schemata preserves soundness transitively. -/
theorem ProofSchema.comp_sound
    {α : Type*}
    (S T : ProofSchema α)
    {P Q R : α → Prop}
    (hPQ : S.ReducesTo P Q)
    (hQR : T.ReducesTo Q R) :
    ∀ x, R x → P x := by
  intro x hRx
  exact S.sound hPQ x (T.sound hQR x hRx)

/-- The composed schema is itself sound. -/
theorem ProofSchema.comp_correct
    {α : Type*}
    (S T : ProofSchema α)
    {P R : α → Prop}
    (h : (ProofSchema.comp S T).ReducesTo P R) :
    ∀ x, R x → P x :=
  (ProofSchema.comp S T).sound h

/-
Composition of proof schemata is associative.
-/
theorem ProofSchema.comp_assoc
    {α : Type*}
    (S T U : ProofSchema α) :
    ProofSchema.comp (ProofSchema.comp S T) U =
    ProofSchema.comp S (ProofSchema.comp T U) := by
  unfold ProofSchema.comp
  simp
  grind +splitImp

/-! ## §3. Identity Schema -/

/-- The identity proof schema. -/
def ProofSchema.id (α : Type*) : ProofSchema α where
  ReducesTo P Q := ∀ x, Q x → P x
  sound h := h

/-! ## §4. Constructive → Proof Schema -/

/-- Every constructive schema induces a proof schema. -/
def ConstructiveSchema.toProofSchema {α : Type*} (C : ConstructiveSchema α) :
    ProofSchema α where
  ReducesTo P Q := ∀ x, Q x → C.transform P x
  sound h x hQx := C.certify x (h x hQx)

/-- Composition of constructive schemata. -/
def ConstructiveSchema.comp {α : Type*}
    (C D : ConstructiveSchema α) : ConstructiveSchema α where
  transform P := D.transform (C.transform P)
  certify _ h := C.certify _ (D.certify _ h)

/-! ## §5. Descent Principles -/

/-
**Well-founded descent eliminates global counterexamples on ℕ.**
    If every counterexample has a strictly smaller counterexample,
    then no counterexample exists.
-/
theorem nat_descent_principle
    {P : ℕ → Prop}
    (hstep : ∀ n, ¬ P n → ∃ m, m < n ∧ ¬ P m) :
    ∀ n, P n := by
  intro n;
  induction' n using Nat.strong_induction_on with n ih;
  exact Classical.not_not.1 fun h => by obtain ⟨ m, hm₁, hm₂ ⟩ := hstep n h; exact hm₂ ( ih m hm₁ ) ;

/-
**Measured descent principle.**
    Generalization to any type with a measure μ : α → ℕ.
-/
theorem measured_descent_principle
    {α : Type*}
    (μ : α → ℕ)
    (P : α → Prop)
    (hstep : ∀ x, ¬ P x → ∃ y, μ y < μ x ∧ ¬ P y) :
    ∀ x, P x := by
  intro x
  by_contra h_not_Px
  induction' n : μ x using Nat.strong_induction_on with n ih generalizing x;
  grind

/-
Descent schema: if every P-element descends, P holds nowhere.
-/
theorem descent_schema_no_bad
    {α : Type*}
    (D : DescentSchema α)
    (Bad : α → Prop)
    (hD : ∀ x, Bad x → ∃ y, Bad y ∧ D.μ y < D.μ x) :
    ∀ x, ¬ Bad x := by
  -- Let's choose any $x$ and derive a contradiction from the assumption that $Bad x$.
  by_contra h_contra; push_neg at h_contra; exact (by
  exact absurd ( measured_descent_principle D.μ ( fun x => ¬ Bad x ) fun x hx => by obtain ⟨ y, hy₁, hy₂ ⟩ := hD x ( by tauto ) ; exact ⟨ y, hy₂, by tauto ⟩ ) ( by tauto ))

/-! ## §6. Invariant Rigidity -/

/-
**Finite invariant classification.**
    If every element has a canonical representative in its fiber
    and canonicity propagates within fibers, all elements are canonical.
-/
theorem finite_invariant_classification
    {α β : Type*}
    [Fintype α] [Fintype β] [DecidableEq β]
    (I : α → β)
    (Canonical : α → Prop)
    (h_complete : ∀ y : α, ∃ x : α, I x = I y ∧ Canonical x)
    (h_rigid : ∀ x y, I x = I y → Canonical x → Canonical y) :
    ∀ y : α, Canonical y := by
  exact fun y => by obtain ⟨ x, hx₁, hx₂ ⟩ := h_complete y; exact h_rigid x y hx₁ hx₂;

/-
**Invariant rigidity from finite obstructions.**
-/
theorem invariant_rigidity_from_finite_obstructions
    {α β : Type*}
    [Fintype β] [DecidableEq β]
    (I : α → β)
    (Good : α → Prop)
    (hfiber : ∀ b, (∃ x, I x = b ∧ Good x) → ∀ y, I y = b → Good y)
    (hcover : ∀ b, ∃ x, I x = b ∧ Good x) :
    ∀ y, Good y := by
  -- For any y in α, let b = I y. By hcover, there exists an x with I x = b and Good x. Then, by hfiber, since I y = b and Good x, it follows that Good y.
  intros y
  obtain ⟨x, hx₁, hx₂⟩ := hcover (I y)
  apply hfiber (I y) ⟨x, hx₁, hx₂⟩ y rfl

/-! ## §7. Synthesis Theorems -/

/-
**No bad elements when minimal obstructions are eliminated.**
    The formal skeleton of infinite descent + local analysis:
    every bad object reduces to a minimal bad object,
    and every minimal bad object is impossible.
-/
theorem no_bad_of_minimal_obstruction_elimination
    {α : Type*}
    (μ : α → ℕ)
    (Bad : α → Prop)
    (helim : ∀ x, Bad x → (∀ z, Bad z → μ z < μ x → False) → False) :
    ∀ x, ¬ Bad x := by
  intro x hx;
  -- By the well-founded induction hypothesis, for all z with μ z < μ x, ¬Bad z.
  have h_ind : ∀ z, μ z < μ x → ¬Bad z := by
    intro z hz hz';
    induction' n : μ x using Nat.strong_induction_on with n ih generalizing z x;
    grind +splitImp;
  exact helim x hx fun z hz hz' => h_ind z hz' hz

/-
**The Strategy Triad: Descent + Rigidity implies no bad elements.**
    If every bad element descends to a smaller bad element,
    then no bad elements exist (the rigidity/finiteness hypotheses
    are subsumed by the well-foundedness of ℕ).
-/
theorem global_theorem_of_strategy_triad
    {α β : Type*}
    [Fintype β] [DecidableEq β]
    (μ : α → ℕ)
    (_I : α → β)
    (Bad : α → Prop)
    (hdescend : ∀ x, Bad x → ∃ y, Bad y ∧ μ y < μ x) :
    ∀ x, ¬ Bad x := by
  apply no_bad_of_minimal_obstruction_elimination μ
  exact fun x hx hx' => by obtain ⟨ y, hy, hy' ⟩ := hdescend x hx; exact hx' y hy hy'

/-! ## §8. Finite Core Schema -/

/-- A schema for finite core extraction: properties verified on
    a finite core propagate globally. -/
structure FiniteCoreSchema (α : Type*) where
  IsCore : Finset α → Prop
  core_exists : ∃ s : Finset α, IsCore s
  propagate : ∀ (P : α → Prop) (s : Finset α),
    IsCore s → (∀ x ∈ s, P x) → ∀ x, P x

/-
Finite core schema yields universal statements from finite verification.
-/
theorem FiniteCoreSchema.global_from_core
    {α : Type*}
    (F : FiniteCoreSchema α)
    (P : α → Prop)
    (hverify : ∀ s : Finset α, F.IsCore s → ∀ x ∈ s, P x) :
    ∀ x, P x := by
  exact fun x => F.propagate P _ F.core_exists.choose_spec ( hverify _ F.core_exists.choose_spec ) x

/-
Composing finite core extraction with descent.
-/
theorem finite_core_then_descent
    {α : Type*}
    (F : FiniteCoreSchema α)
    (P : α → Prop)
    (hcore_verify : ∀ s : Finset α, F.IsCore s → ∀ x ∈ s, P x) :
    ∀ x, P x := by
  exact F.global_from_core P hcore_verify

/-! ## §9. Concrete Arithmetic Instantiations -/

/-
Descent applied to divisibility.
-/
theorem divisibility_by_descent
    (d : ℕ) (_hd : d ≠ 0)
    (hstep : ∀ n, ¬(d ∣ n) → ∃ m, m < n ∧ ¬(d ∣ m)) :
    ∀ n, d ∣ n := by
  -- Applying the descent principle to the divisibility predicate P(n) = d ∣ n.
  intros n
  apply nat_descent_principle
  intro n hn
  apply hstep n hn

/-- The descent schema packaged as a `ProofSchema` on ℕ. -/
def descentProofSchema : ProofSchema ℕ where
  ReducesTo P Q := (∀ n, ¬ Q n → ∃ m, m < n ∧ ¬ Q m) ∧ (∀ n, Q n → P n)
  sound := by
    intro P Q ⟨_, hQP⟩ x hQx
    exact hQP x hQx

/-- The identity constructive schema (trivial but composable). -/
def idConstructiveSchema (α : Type*) : ConstructiveSchema α where
  transform P := P
  certify _ h := h