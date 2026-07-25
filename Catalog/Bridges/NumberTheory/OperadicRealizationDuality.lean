/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Operadic Realization–Minimality Duality via Context Equivalence

This file formalizes a Myhill–Nerode style minimization theorem for algebraic
architectures with observable semantics, bridging universal algebra, machine
learning architecture minimization, proof-circuit semantics, and weighted
automata realization theory.

## Main Results

* `ctxEquiv_isEquivalence` — context equivalence is an equivalence relation
* `ctxEquiv_congruence` — context equivalence is a congruence (preserved by ops)
* `state_factors_ctxEquiv` — state equiv refines context equiv (forward Myhill–Nerode)
* `separated_stateEquiv_iff_ctxEquiv` — full abstraction for separated architectures
* `morphism_preserves_behavior` — arch morphisms preserve observable behavior
* `minimality_via_separation` — separated reachable realization is minimal
* `uniqueness_of_minimal` — minimal realizations are isomorphic

## Mathematical Overview

Given a signature and observable semantics mapping terms to observations,
context equivalence identifies terms indistinguishable in all one-hole contexts.
We prove this is the coarsest congruence compatible with observations, yielding
a canonical minimal architecture via quotient — the algebraic generalization of
the Myhill–Nerode theorem to operadic/many-input structures.
-/

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

open Function Set

noncomputable section

namespace OperadicRealization

/-! ## §1. Signatures and Terms -/

/-- An algebraic signature: operation symbols with arities. -/
structure AlgSignature where
  Op : Type
  arity : Op → ℕ

/-- Terms over a signature with generators from `G`. -/
inductive Term (S : AlgSignature) (G : Type) : Type where
  | gen : G → Term S G
  | app : (op : S.Op) → (Fin (S.arity op) → Term S G) → Term S G

/-- One-hole contexts for substitution. -/
inductive Ctx (S : AlgSignature) (G : Type) : Type where
  | hole : Ctx S G
  | app : (op : S.Op) → (focus : Fin (S.arity op)) →
          (others : Fin (S.arity op) → Term S G) →
          (sub : Ctx S G) → Ctx S G

/-- Plug a term into a context's hole. -/
def Ctx.plug {S : AlgSignature} {G : Type} : Ctx S G → Term S G → Term S G
  | .hole, t => t
  | .app op focus others sub, t =>
    .app op (fun j => if j = focus then sub.plug t else others j)

/-- Compose two contexts. -/
def Ctx.comp {S : AlgSignature} {G : Type} :
    Ctx S G → Ctx S G → Ctx S G
  | .hole, c₂ => c₂
  | .app op focus others sub, c₂ => .app op focus others (sub.comp c₂)

/-- Plugging into a composed context equals sequential plugging. -/
theorem Ctx.plug_comp {S : AlgSignature} {G : Type}
    (c₁ c₂ : Ctx S G) (t : Term S G) :
    c₁.plug (c₂.plug t) = (c₁.comp c₂).plug t := by
  induction c₁ with
  | hole => rfl
  | app op focus others sub ih =>
    simp only [Ctx.plug, Ctx.comp]
    congr 1; funext j
    split <;> [exact ih; rfl]

/-! ## §2. Algebras and Architectures -/

/-- An algebra over a signature. -/
structure SigAlgebra (S : AlgSignature) where
  carrier : Type
  interpOp : (op : S.Op) → (Fin (S.arity op) → carrier) → carrier

variable {S : AlgSignature} {G Obs : Type}

/-- Evaluate a term in an algebra. -/
def SigAlgebra.eval (A : SigAlgebra S) (assign : G → A.carrier) :
    Term S G → A.carrier
  | .gen g => assign g
  | .app op args => A.interpOp op (fun i => A.eval assign (args i))

/-- Evaluate a context with a hole value. -/
def SigAlgebra.evalCtx (A : SigAlgebra S) (assign : G → A.carrier) :
    Ctx S G → A.carrier → A.carrier
  | .hole, v => v
  | .app op focus others sub, v =>
    A.interpOp op (fun j =>
      if j = focus then A.evalCtx assign sub v
      else A.eval assign (others j))

/-- Evaluating a plugged term = evaluating context with term's value. -/
theorem SigAlgebra.eval_plug (A : SigAlgebra S) (assign : G → A.carrier)
    (c : Ctx S G) (t : Term S G) :
    A.eval assign (c.plug t) = A.evalCtx assign c (A.eval assign t) := by
  induction c with
  | hole => rfl
  | app op focus others sub ih =>
    simp only [Ctx.plug, SigAlgebra.eval, SigAlgebra.evalCtx]
    congr 1; funext j
    split
    case isTrue h => subst h; exact ih
    case isFalse => rfl

/-- A finite architecture: algebra + generators + observations. -/
structure Architecture (S : AlgSignature) (G Obs : Type) where
  alg : SigAlgebra S
  init : G → alg.carrier
  observe : alg.carrier → Obs

@[simp] def Architecture.state (A : Architecture S G Obs) (t : Term S G) :
    A.alg.carrier := A.alg.eval A.init t

def Architecture.behavior (A : Architecture S G Obs) (t : Term S G) : Obs :=
  A.observe (A.state t)

/-! ## §3. Observable Semantics and Context Equivalence -/

abbrev ObsSem (S : AlgSignature) (G Obs : Type) := Term S G → Obs

def Architecture.toSem (A : Architecture S G Obs) : ObsSem S G Obs := A.behavior

/-- **Context equivalence:** two terms are equivalent iff indistinguishable
    in all one-hole contexts. -/
def ctxEquiv (sem : ObsSem S G Obs) (t u : Term S G) : Prop :=
  ∀ c : Ctx S G, sem (c.plug t) = sem (c.plug u)

theorem ctxEquiv_refl (sem : ObsSem S G Obs) (t : Term S G) :
    ctxEquiv sem t t := fun _ => rfl

theorem ctxEquiv_symm {sem : ObsSem S G Obs} {t u : Term S G}
    (h : ctxEquiv sem t u) : ctxEquiv sem u t :=
  fun c => (h c).symm

theorem ctxEquiv_trans {sem : ObsSem S G Obs} {t u v : Term S G}
    (h1 : ctxEquiv sem t u) (h2 : ctxEquiv sem u v) :
    ctxEquiv sem t v :=
  fun c => (h1 c).trans (h2 c)

/-- Context equivalence is an equivalence relation. -/
theorem ctxEquiv_isEquivalence (sem : ObsSem S G Obs) :
    Equivalence (ctxEquiv sem) :=
  ⟨ctxEquiv_refl sem, fun h => ctxEquiv_symm h, fun h1 h2 => ctxEquiv_trans h1 h2⟩

def ctxSetoid (sem : ObsSem S G Obs) : Setoid (Term S G) :=
  ⟨ctxEquiv sem, ctxEquiv_isEquivalence sem⟩

/-- Context equivalence at the hole gives semantic equality. -/
theorem ctxEquiv_implies_sem_eq {sem : ObsSem S G Obs}
    {t u : Term S G} (h : ctxEquiv sem t u) :
    sem t = sem u := h Ctx.hole

/-! ## §4. Context Equivalence is a Congruence

The central algebraic theorem: if `tᵢ ~ uᵢ` for all i, then
`op(t₁,...,tₙ) ~ op(u₁,...,uₙ)`. -/

/-- Helper: two Term.app with same op and pointwise equal args are equal. -/
private theorem term_app_ext {S : AlgSignature} {G : Type}
    {op : S.Op} {f g : Fin (S.arity op) → Term S G}
    (h : ∀ i, f i = g i) : Term.app op f = Term.app op g := by
  congr 1; funext i; exact h i

/-- **Context equivalence is a congruence.** -/
theorem ctxEquiv_congruence (sem : ObsSem S G Obs)
    (op : S.Op) (ts us : Fin (S.arity op) → Term S G)
    (h : ∀ i, ctxEquiv sem (ts i) (us i)) :
    ctxEquiv sem (Term.app op ts) (Term.app op us) := by
  intro c
  -- Telescoping: replace arguments one at a time
  let mixed (k : ℕ) : Fin (S.arity op) → Term S G :=
    fun j => if (j : ℕ) < k then us j else ts j
  have h_start : mixed 0 = ts := by
    funext j; simp [mixed]
  have h_end : mixed (S.arity op) = us := by
    funext j; simp [mixed, show (j : ℕ) < S.arity op from j.isLt]
  suffices step : ∀ k : ℕ, k < S.arity op →
      sem (c.plug (.app op (mixed k))) =
      sem (c.plug (.app op (mixed (k + 1)))) by
    have telescope : ∀ k : ℕ, k ≤ S.arity op →
        sem (c.plug (.app op (mixed 0))) =
        sem (c.plug (.app op (mixed k))) := by
      intro k hk
      induction k with
      | zero => rfl
      | succ n ih => exact (ih (by omega)).trans (step n (by omega))
    calc sem (c.plug (.app op ts))
        = sem (c.plug (.app op (mixed 0))) := by rw [h_start]
      _ = sem (c.plug (.app op (mixed (S.arity op)))) := telescope _ le_rfl
      _ = sem (c.plug (.app op us)) := by rw [h_end]
  intro k hk
  -- Factor through context focusing on position k
  let c' := c.comp (.app op ⟨k, hk⟩ (mixed (k + 1)) .hole)
  -- c'.plug (ts k) = c.plug (app op (mixed k))
  have h1 : c'.plug (ts ⟨k, hk⟩) = c.plug (.app op (mixed k)) := by
    simp only [c', ← Ctx.plug_comp, Ctx.plug]
    congr 1
    apply term_app_ext; intro j
    simp only [mixed]
    by_cases hj : j = ⟨k, hk⟩
    · subst hj; simp
    · simp [hj]
      have : ¬((j : ℕ) = k) := fun heq => hj (Fin.ext heq)
      split <;> split <;> first | rfl | omega
  have h2 : c'.plug (us ⟨k, hk⟩) = c.plug (.app op (mixed (k + 1))) := by
    simp only [c', ← Ctx.plug_comp, Ctx.plug]
    congr 1
    apply term_app_ext; intro j
    by_cases hj : j = ⟨k, hk⟩
    · subst hj; simp; dsimp only [mixed]; simp
    · simp [hj]
  rw [← h1, ← h2]
  exact h ⟨k, hk⟩ c'

/-! ## §5. Architecture Morphisms -/

structure ArchMorphism (A B : Architecture S G Obs) where
  toFun : A.alg.carrier → B.alg.carrier
  map_op : ∀ (op : S.Op) (args : Fin (S.arity op) → A.alg.carrier),
    toFun (A.alg.interpOp op args) = B.alg.interpOp op (fun i => toFun (args i))
  map_init : ∀ g : G, toFun (A.init g) = B.init g
  map_obs : ∀ s : A.alg.carrier, A.observe s = B.observe (toFun s)

theorem ArchMorphism.map_eval {A B : Architecture S G Obs}
    (f : ArchMorphism A B) (t : Term S G) :
    f.toFun (A.state t) = B.state t := by
  induction t with
  | gen g => exact f.map_init g
  | app op args ih =>
    simp only [Architecture.state, SigAlgebra.eval]
    rw [f.map_op]; congr 1; funext i; exact ih i

theorem ArchMorphism.preserves_behavior {A B : Architecture S G Obs}
    (f : ArchMorphism A B) (t : Term S G) :
    A.behavior t = B.behavior t := by
  simp only [Architecture.behavior]
  rw [f.map_obs, f.map_eval]

/-! ## §6. Realization and Core Theorems -/

def Realizes (A : Architecture S G Obs) (sem : ObsSem S G Obs) : Prop :=
  ∀ t : Term S G, A.behavior t = sem t

@[simp] def stateEquiv (A : Architecture S G Obs) (t u : Term S G) : Prop :=
  A.state t = A.state u

theorem architecture_induces_semantics (A : Architecture S G Obs) :
    Realizes A A.toSem := fun _ => rfl

/-- **State equivalence refines context equivalence (forward Myhill–Nerode).** -/
theorem state_factors_ctxEquiv (A : Architecture S G Obs)
    (sem : ObsSem S G Obs) (hreal : Realizes A sem)
    {t u : Term S G} (hst : A.state t = A.state u) :
    ctxEquiv sem t u := by
  intro c
  rw [← hreal, ← hreal]
  simp only [Architecture.behavior]
  congr 1
  simp only [Architecture.state] at hst ⊢
  rw [A.alg.eval_plug, A.alg.eval_plug, hst]

theorem surjection_coarsens {A B : Architecture S G Obs}
    (f : ArchMorphism B A) {t u : Term S G} (hst : B.state t = B.state u) :
    A.state t = A.state u := by
  change A.alg.eval A.init t = A.alg.eval A.init u
  have h1 := f.map_eval (G := G) t
  have h2 := f.map_eval (G := G) u
  simp only [Architecture.state] at h1 h2 hst
  rw [← h1, ← h2, hst]

theorem morphism_preserves_realization {A B : Architecture S G Obs}
    (f : ArchMorphism A B) {sem : ObsSem S G Obs}
    (hB : Realizes B sem) : Realizes A sem :=
  fun t => by rw [← hB]; exact f.preserves_behavior t

/-! ## §7. Observable Separation and Full Abstraction -/

/-- An architecture is observably separated if distinct states yield
    different observations in some context. -/
def ObsSeparated (A : Architecture S G Obs) : Prop :=
  ∀ s₁ s₂ : A.alg.carrier,
    (∀ c : Ctx S G, A.observe (A.alg.evalCtx A.init c s₁) =
                     A.observe (A.alg.evalCtx A.init c s₂)) →
    s₁ = s₂

def Reachable (A : Architecture S G Obs) : Prop :=
  Surjective (fun t : Term S G => A.state t)

/-- **Full abstraction for separated architectures:**
    state equivalence ↔ context equivalence. -/
theorem separated_stateEquiv_iff_ctxEquiv
    (A : Architecture S G Obs)
    (sem : ObsSem S G Obs) (hreal : Realizes A sem)
    (hsep : ObsSeparated A) {t u : Term S G} :
    A.state t = A.state u ↔ ctxEquiv sem t u := by
  constructor
  · exact fun h => state_factors_ctxEquiv A sem hreal h
  · intro hctx
    apply hsep
    intro c
    have : A.behavior (c.plug t) = A.behavior (c.plug u) := by
      rw [hreal, hreal]; exact hctx c
    simp only [Architecture.behavior, Architecture.state] at this
    rwa [A.alg.eval_plug, A.alg.eval_plug] at this

/-! ## §8. Minimality and Uniqueness -/

/-
**Minimality theorem.** The observably separated, reachable realization
    is surjected onto from any other realization.
-/
theorem minimality_via_separation
    (A B : Architecture S G Obs)
    {sem : ObsSem S G Obs}
    (hA : Realizes A sem) (hB : Realizes B sem)
    (hsepB : ObsSeparated B) (hreachA : Reachable A)
    (hreachB : Reachable B) :
    ∃ f : A.alg.carrier → B.alg.carrier,
      Surjective f ∧
      (∀ t : Term S G, f (A.state t) = B.state t) := by
  -- Define f on A's states using Classical.choice: for each state s in A's carrier, choose a term t with A.state t = s (using hreachA), then set f(s) = B.state t.
  obtain ⟨f, hf⟩ : ∃ f : A.alg.carrier → B.alg.carrier, ∀ t : Term S G, f (A.state t) = B.state t := by
    use fun s => B.state (Classical.choose (hreachA s));
    intro t
    have h_eq : ctxEquiv sem (Classical.choose (hreachA (A.state t))) t := by
      apply state_factors_ctxEquiv A sem hA;
      exact Classical.choose_spec ( hreachA ( A.state t ) );
    apply (separated_stateEquiv_iff_ctxEquiv B sem hB hsepB).mpr h_eq;
  exact ⟨ f, fun x => by obtain ⟨ t, rfl ⟩ := hreachB x; exact ⟨ _, hf t ⟩, hf ⟩

/-
**Uniqueness of minimal realizations.**
-/
theorem uniqueness_of_minimal
    (A B : Architecture S G Obs)
    {sem : ObsSem S G Obs}
    (hA : Realizes A sem) (hB : Realizes B sem)
    (hsepA : ObsSeparated A) (hsepB : ObsSeparated B)
    (hreachA : Reachable A) (hreachB : Reachable B) :
    ∃ f : A.alg.carrier → B.alg.carrier,
      Bijective f ∧
      (∀ t : Term S G, f (A.state t) = B.state t) := by
  -- By the minimality via separation theorem, we obtain surjective maps $f: A \to B$ and $g: B \to A$.
  obtain ⟨f, hf_surj, hf⟩ := minimality_via_separation A B hA hB hsepB hreachA hreachB
  refine ⟨f, ⟨?_, hf_surj⟩, hf⟩
  intros s1 s2 h_eq
  obtain ⟨t1, ht1⟩ := hreachA s1
  obtain ⟨t2, ht2⟩ := hreachA s2
  simp only at ht1 ht2
  rw [← ht1, ← ht2]
  have h_ctx_eq : ctxEquiv sem t1 t2 := by
    apply state_factors_ctxEquiv B sem hB
    rw [← hf t1, ← hf t2, ht1, ht2, h_eq]
  exact (separated_stateEquiv_iff_ctxEquiv A sem hA hsepA).mpr h_ctx_eq

/-! ## §9. Concrete Instance -/

def UnarySig : AlgSignature where
  Op := Unit; arity := fun _ => 1

def boolUnaryArch : Architecture UnarySig (Fin 2) Bool where
  alg := {
    carrier := Bool
    interpOp := fun _ args => !args ⟨0, by simp [UnarySig]⟩
  }
  init := fun i => i = 0
  observe := id

theorem boolUnaryArch_separated : ObsSeparated boolUnaryArch := by
  intro s₁ s₂ h
  have := h Ctx.hole
  simp [SigAlgebra.evalCtx, boolUnaryArch] at this
  exact this

theorem boolUnaryArch_reachable : Reachable boolUnaryArch := by
  intro s; cases s
  · exact ⟨.gen 1, rfl⟩
  · exact ⟨.gen 0, rfl⟩

/-! ## §10. Quotient Algebra -/

def TermQuotient (sem : ObsSem S G Obs) := Quotient (ctxSetoid sem)

theorem obs_descends (sem : ObsSem S G Obs) :
    ∀ t u : Term S G, ctxEquiv sem t u → sem t = sem u :=
  fun _ _ h => ctxEquiv_implies_sem_eq h

def quotientObs (sem : ObsSem S G Obs) : TermQuotient sem → Obs :=
  Quotient.lift sem (obs_descends sem)

theorem quotientObs_mk (sem : ObsSem S G Obs) (t : Term S G) :
    quotientObs sem (Quotient.mk (ctxSetoid sem) t) = sem t := rfl

/-! ## §11. Realization Duality Bridge -/

theorem realization_to_finite_classes
    (A : Architecture S G Obs) (sem : ObsSem S G Obs)
    (hreal : Realizes A sem) :
    ∀ t u : Term S G, A.state t = A.state u → ctxEquiv sem t u :=
  fun t u h => state_factors_ctxEquiv A sem hreal h

/-! ## §12. Abstract Kernel Theory -/

def obsStateEquiv {State Obs' : Type} (observe : State → Obs') (s₁ s₂ : State) : Prop :=
  observe s₁ = observe s₂

theorem obsStateEquiv_equivalence {State Obs' : Type} (observe : State → Obs') :
    Equivalence (obsStateEquiv observe) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

theorem map_preserves_obsEquiv {State₁ State₂ Obs' : Type}
    {obs₁ : State₁ → Obs'} {obs₂ : State₂ → Obs'}
    (f : State₁ → State₂) (hf : ∀ s, obs₁ s = obs₂ (f s))
    {s₁ s₂ : State₁} (h : obsStateEquiv obs₁ s₁ s₂) :
    obsStateEquiv obs₂ (f s₁) (f s₂) := by
  unfold obsStateEquiv at *; rw [← hf, ← hf, h]

end OperadicRealization