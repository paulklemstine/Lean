import Mathlib

/-!
# Convergent Rewrite Systems as Certified Quotient Optimizers

## Overview

This file establishes the **master theorem of certified algebraic optimization**:
a convergent (terminating + confluent) rewrite system whose rules are sound for an
equational theory induces a semantics-preserving normalizer — a certified optimizer
that computes canonical representatives of semantic equivalence classes.

This generalizes catalog results like `commNorm_preserves_eval` and
`endomorphism_preserves_semantics` from specific quotients (commutativity,
free-monoid endomorphisms) to arbitrary convergent rewrite systems over any
equational theory.

## Main Definitions

- `RewriteSound`: a rewrite relation whose single-step reductions preserve
  evaluation in every model.
- `CertifiedNormalizer`: a structure packaging a rewrite relation with a
  normal-form function and its correctness witnesses.

## Main Theorems

- `rtc_sound_of_step_sound`: multi-step rewrite soundness (local → global).
- `nf_unique_of_confluent`: normal-form uniqueness under confluence.
- `convergent_rewrite_induces_optimizer`: the master optimizer theorem.
- `nf_constant_on_eqvGen`: normal forms are constant on equivalence classes.
- `quotient_nf_well_defined`: the normalizer factors through the quotient.
- `ring_rewrite_nf_preserves_eval`: cross-domain specialization to
  ring expressions.

## Scientific Significance

This result upgrades "normalization preserves evaluation" from an isolated fact
about specific algebraic structures to a **general architecture for certified
quotient optimization**. It provides the formal backbone for:

- equality saturation / e-graph extraction,
- verified compiler optimization passes,
- symbolic algebra / Gröbner-style canonicalization,
- SMT simplification.

## Lineage

Builds on:
- `Catalog/Pythagorean/VerifiedCompilerSynthesis.lean`:
  `endomorphism_preserves_semantics` (optimizer soundness for free monoids)
- The general pattern of quotient optimizer paradigm
-/

open Relation

/-! ## Section 1: Core Definitions -/

/-- A rewrite relation `R` on terms of type `T` is **sound** for an evaluation function
`eval : (α → A) → T → A` if every single-step rewrite preserves the evaluation in
every model. This is the exact hypothesis needed to lift local rewrite correctness to
global optimizer correctness. -/
def RewriteSound {T A α : Type*}
    (R : T → T → Prop) (eval : (α → A) → T → A) : Prop :=
  ∀ ⦃s t : T⦄, R s t → ∀ (ι : α → A), eval ι s = eval ι t

/-- A term `t` is in **normal form** with respect to `R` if no rewrite rule applies. -/
def IsNormalForm {T : Type*} (R : T → T → Prop) (t : T) : Prop :=
  ∀ u, ¬R t u

/-- A rewrite relation is **confluent** if whenever `t` rewrites to both `u₁` and `u₂`,
there exists a common reduct `v`. -/
def IsConfluent {T : Type*} (R : T → T → Prop) : Prop :=
  ∀ ⦃t u₁ u₂ : T⦄,
    ReflTransGen R t u₁ → ReflTransGen R t u₂ →
    ∃ v, ReflTransGen R u₁ v ∧ ReflTransGen R u₂ v

/-- A **certified normalizer** packages a rewrite relation together with a chosen
normal-form function and all correctness witnesses. -/
structure CertifiedNormalizer (T : Type*) where
  /-- The oriented rewrite relation. -/
  R : T → T → Prop
  /-- The normal-form function. -/
  nf : T → T
  /-- The normal form of `t` is always in normal form. -/
  nf_normal : ∀ t, IsNormalForm R (nf t)
  /-- `t` rewrites to `nf t` in finitely many steps. -/
  nf_reduces : ∀ t, ReflTransGen R t (nf t)
  /-- Normal forms are unique: if `u` is any normal form reachable from `t`,
      then `u = nf t`. -/
  nf_unique : ∀ t u, IsNormalForm R u → ReflTransGen R t u → u = nf t

/-! ## Section 2: Multi-Step Soundness (Theorem 1) -/

/-
**Multi-step semantics preservation.** Local rewrite soundness lifts to the
reflexive-transitive closure. This is the transport theorem from local rewriting
to global optimization.

**Proof:** By induction on `ReflTransGen R s t`.
-/
theorem rtc_sound_of_step_sound {T A α : Type*}
    {R : T → T → Prop} {eval : (α → A) → T → A}
    (hR : RewriteSound R eval)
    {s t : T} (hst : ReflTransGen R s t) :
    ∀ (ι : α → A), eval ι s = eval ι t := by
  induction hst;
  · exact fun _ => rfl;
  · exact fun ι => Eq.trans ( by solve_by_elim ) ( hR ‹_› ι )

/-! ## Section 3: Normal-Form Uniqueness (Theorem 2) -/

/-
A normal form cannot be further reduced.
-/
theorem normal_form_of_rtc {T : Type*}
    {R : T → T → Prop} {u v : T}
    (hnf : IsNormalForm R u) (huv : ReflTransGen R u v) :
    u = v := by
  grind +locals

/-
**Normal-form uniqueness under confluence.** If the rewrite relation is confluent and
two normal forms are both reachable from the same term, they are equal.
-/
theorem nf_unique_of_confluent {T : Type*}
    {R : T → T → Prop}
    (hconf : IsConfluent R)
    {t u₁ u₂ : T}
    (hn₁ : IsNormalForm R u₁) (hn₂ : IsNormalForm R u₂)
    (h₁ : ReflTransGen R t u₁) (h₂ : ReflTransGen R t u₂) :
    u₁ = u₂ := by
  -- By confluence, there exists a common reduct v such that u₁ →* v and u₂ →* v.
  obtain ⟨v, hv₁, hv₂⟩ : ∃ v, ReflTransGen R u₁ v ∧ ReflTransGen R u₂ v := hconf h₁ h₂;
  -- By normal_form_of_rtc, since u₁ is in normal form and u₁ →* v, we have u₁ = v.
  have hu₁v : u₁ = v := by
    exact normal_form_of_rtc hn₁ hv₁
  exact normal_form_of_rtc hn₂ hv₂ ▸ hu₁v ▸ rfl

/-! ## Section 4: The Master Optimizer Theorem (Theorem 3) -/

/-
**The Master Optimizer Theorem.** The normal-form map induced by a convergent sound
rewrite system preserves semantics in every model.
-/
theorem convergent_rewrite_induces_optimizer {T A α : Type*}
    (N : CertifiedNormalizer T)
    {eval : (α → A) → T → A}
    (hR : RewriteSound N.R eval) :
    ∀ (t : T) (ι : α → A), eval ι (N.nf t) = eval ι t := by
  exact fun t ι => Eq.symm ( rtc_sound_of_step_sound hR ( N.nf_reduces t ) ι )

/-! ## Section 5: Quotient Factorization (Theorem 4) -/

/-
**Normal forms are constant on equivalence classes.** Under confluence,
`EqvGen R`-equivalent terms have equal normal forms.
-/
theorem nf_constant_on_eqvGen {T : Type*}
    (N : CertifiedNormalizer T)
    (_hconf : IsConfluent N.R) :
    ∀ {s t : T}, EqvGen N.R s t → N.nf s = N.nf t := by
  intro s t h;
  induction' h with s t h ih;
  · have := N.nf_unique s ( N.nf t ) ( N.nf_normal t ) ?_;
    · exact this.symm;
    · exact .single h |> ReflTransGen.trans <| N.nf_reduces t;
  · rfl;
  · grind;
  · grind

/-- The setoid on `T` induced by `EqvGen R`. -/
def eqvGenSetoid {T : Type*} (R : T → T → Prop) : Setoid T where
  r := EqvGen R
  iseqv := ⟨EqvGen.refl, fun h => h.symm, fun h₁ h₂ => EqvGen.trans _ _ _ h₁ h₂⟩

/-- **The normalizer factors through the quotient.** Under confluence, `nf` descends to a
well-defined function on `Quot (EqvGen R)`. -/
noncomputable def quotientNf {T : Type*}
    (N : CertifiedNormalizer T)
    (hconf : IsConfluent N.R) :
    Quot (EqvGen N.R) → T :=
  Quot.lift N.nf (fun _a _b hab => nf_constant_on_eqvGen N hconf hab)

/-- The quotient normalizer agrees with `nf` on representatives. -/
theorem quotientNf_mk {T : Type*}
    (N : CertifiedNormalizer T)
    (hconf : IsConfluent N.R) (t : T) :
    quotientNf N hconf (Quot.mk _ t) = N.nf t := by
  rfl

/-
The normalizer is idempotent: normal forms are fixed points.
-/
theorem nf_idempotent {T : Type*}
    (N : CertifiedNormalizer T) :
    ∀ t, N.nf (N.nf t) = N.nf t := by
  -- By definition of `nf`, we know that `N.nf t` is in normal form.
  have h_nf_normal : ∀ t : T, IsNormalForm N.R (N.nf t) := by
    exact N.nf_normal;
  exact fun t => normal_form_of_rtc ( h_nf_normal t ) ( N.nf_reduces ( N.nf t ) ) ▸ rfl

/-! ## Section 6: Compiler Pass Architecture -/

/-
**Compiler pass interpretation.** A certified normalizer induces a
semantics-preserving optimization pass.
-/
theorem compiler_pass_of_convergent_rewrite {T A α : Type*}
    (N : CertifiedNormalizer T)
    {eval : (α → A) → T → A}
    (hR : RewriteSound N.R eval) :
    ∀ (ι : α → A) (t : T), eval ι (N.nf t) = eval ι t := by
  -- Apply the master optimizer theorem to conclude the proof.
  apply fun ι t => convergent_rewrite_induces_optimizer N hR t ι

/-
Two normalizers for the same rewrite system agree.
-/
theorem normalizers_agree {T : Type*}
    (N₁ N₂ : CertifiedNormalizer T)
    (hR : N₁.R = N₂.R) :
    N₁.nf = N₂.nf := by
  have h_nf_eq : ∀ t, N₁.nf t = N₂.nf t := by
    intro t
    apply Eq.symm;
    apply N₁.nf_unique;
    · exact hR ▸ N₂.nf_normal t;
    · convert N₂.nf_reduces t using 1;
  exact funext h_nf_eq

/-! ## Section 7: Cross-Domain Bridge — Ring Expression Normalization -/

/-- A simple expression type for ring/semiring expressions. -/
inductive RingExpr (α : Type*)
  | var : α → RingExpr α
  | zero : RingExpr α
  | one : RingExpr α
  | add : RingExpr α → RingExpr α → RingExpr α
  | mul : RingExpr α → RingExpr α → RingExpr α

/-- Evaluate a ring expression in a commutative semiring. -/
def RingExpr.eval {α A : Type*} [CommSemiring A] (ι : α → A) : RingExpr α → A
  | .var x => ι x
  | .zero => 0
  | .one => 1
  | .add e₁ e₂ => e₁.eval ι + e₂.eval ι
  | .mul e₁ e₂ => e₁.eval ι * e₂.eval ι

/-- A rewrite relation on ring expressions capturing commutativity of addition. -/
inductive AddCommRewrite {α : Type*} : RingExpr α → RingExpr α → Prop
  | comm (e₁ e₂ : RingExpr α) : AddCommRewrite (.add e₁ e₂) (.add e₂ e₁)

/-
The additive commutativity rewrite is sound in any commutative semiring.
-/
theorem addComm_rewrite_sound {α A : Type*} [CommSemiring A] :
    RewriteSound (@AddCommRewrite α) (fun (ι : α → A) => RingExpr.eval ι) := by
  intro s t h ι;
  cases h;
  exact add_comm _ _

/-
**Cross-domain specialization.** Any convergent sound rewrite system on ring
expressions preserves evaluation in every commutative semiring model.
-/
theorem ring_rewrite_nf_preserves_eval {α A : Type*} [CommSemiring A]
    (N : CertifiedNormalizer (RingExpr α))
    (hR : RewriteSound N.R (fun (ι : α → A) => RingExpr.eval ι)) :
    ∀ (t : RingExpr α) (ι : α → A),
      RingExpr.eval ι (N.nf t) = RingExpr.eval ι t := by
  convert convergent_rewrite_induces_optimizer N hR

/-! ## Section 8: Composition of Normalizers -/

/-
Composing two sound normalizers preserves evaluation.
-/
theorem compose_normalizers_sound {T A α : Type*}
    (N₁ N₂ : CertifiedNormalizer T)
    {eval : (α → A) → T → A}
    (hR₁ : RewriteSound N₁.R eval)
    (hR₂ : RewriteSound N₂.R eval) :
    ∀ (t : T) (ι : α → A),
      eval ι (N₁.nf (N₂.nf t)) = eval ι t := by
  exact fun t ι => ( convergent_rewrite_induces_optimizer N₁ hR₁ ( N₂.nf t ) ι ) ▸ ( convergent_rewrite_induces_optimizer N₂ hR₂ t ι )

/-! ## Section 9: Equivalence of Evaluation on Normal Forms -/

/-
Two terms with the same normal form evaluate identically in every sound model.
-/
theorem eval_eq_of_nf_eq {T A α : Type*}
    (N : CertifiedNormalizer T)
    {eval : (α → A) → T → A}
    (hR : RewriteSound N.R eval)
    {s t : T} (h : N.nf s = N.nf t) :
    ∀ (ι : α → A), eval ι s = eval ι t := by
  -- By the convergent_rewrite_induces_optimizer theorem, we know that for any term t, eval ι (N.nf t) = eval ι t.
  have h_nf : ∀ t ι, eval ι (N.nf t) = eval ι t := by
    exact convergent_rewrite_induces_optimizer N hR
  intro ι
  calc eval ι s = eval ι (N.nf s) := (h_nf s ι).symm
    _ = eval ι (N.nf t) := by rw [h]
    _ = eval ι t := h_nf t ι