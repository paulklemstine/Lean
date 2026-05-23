import Mathlib

/-!
# Convergent Rewrite Systems as Quotient Optimizers — The Master Theorem

## Overview

This file establishes the **master theorem of certified algebraic optimization**:
a convergent (terminating + confluent) rewrite system whose rules are sound for an
equational theory induces a semantics-preserving normalizer.

## Main Results

- **Newman's Lemma** (`newmans_lemma`): A terminating, locally confluent relation
  is confluent. Proved by well-founded induction.
- **Master Optimizer Theorem** (`convergent_nf_preserves_eval`): Normal forms of
  convergent sound rewrite systems preserve evaluation in every model.
- **Quotient Factorization** (`nf_constant_on_eqvGen`): Normal forms factor through
  the equivalence quotient.
- **Normalizer Composition** (`compose_normalizers_sound`): Composing sound
  normalizers preserves semantics.
- **Cross-Domain Bridge** (`ring_nf_preserves_eval`): Ring expression normalization
  as a special case.
- **Critical Pair Theorem** (`confluence_of_cps_joinable`): Confluence from
  joinability of critical pairs via Newman's Lemma.

## Novel Definitions

- `LocallyConfluent`: One-step divergences can be rejoined.
- `CriticalPair`: Obstruction to local confluence from overlapping rules.
- `ConvergentQuotientOptimizer`: Bundled certified optimizer structure.

## Lineage

Extends `Catalog/Pythagorean/ConvergentRewriteOptimizer.lean` and
`Catalog/Pythagorean/ConvergentRewriteSystems.lean`.
-/

open Relation

/-! ## Part I: Abstract Rewrite Systems and Newman's Lemma -/

/-- A relation is **locally confluent** (weakly Church-Rosser) if whenever
`a` reduces in one step to both `b` and `c`, there exists a common reduct `d`. -/
def LocallyConfluent {α : Type*} (r : α → α → Prop) : Prop :=
  ∀ ⦃a b c : α⦄, r a b → r a c → ∃ d, ReflTransGen r b d ∧ ReflTransGen r c d

/-- A relation is **confluent** (Church-Rosser) if whenever `a` reduces
(in multiple steps) to both `b` and `c`, there exists a common reduct `d`. -/
def IsConfl {α : Type*} (r : α → α → Prop) : Prop :=
  ∀ ⦃a b c : α⦄, ReflTransGen r a b → ReflTransGen r a c →
    ∃ d, ReflTransGen r b d ∧ ReflTransGen r c d

/-- A term `t` is a **normal form** w.r.t. `r` if no reduction applies. -/
def IsNF {α : Type*} (r : α → α → Prop) (t : α) : Prop := ∀ u, ¬r t u

/-- **Newman's Lemma** (1942): A terminating (well-founded), locally confluent
relation is confluent. This is one of the fundamental results in rewriting theory.

The proof proceeds by well-founded induction on `a`. Given `a →* b` and `a →* c`,
we case-split on whether each path is trivial (refl) or starts with a step.
When both start with a step (`a → a₂` and `a → a₃`), local confluence provides
a join `d` for `a₂` and `a₃`. The inductive hypothesis (applied to `a₂ < a` and
`a₃ < a`) then fills the remaining confluence diagram. -/
theorem newmans_lemma {α : Type*} (r : α → α → Prop)
    (hwf : WellFounded (fun x y => r y x))
    (hlc : LocallyConfluent r) :
    IsConfl r := by
  intro a
  induction hwf.apply a with
  | intro a _ha ih =>
    intro b c hab hac
    rcases hab.cases_head with rfl | ⟨a₂, ha₂, ha₂b⟩
    · exact ⟨c, hac, .refl⟩
    · rcases hac.cases_head with rfl | ⟨a₃, ha₃, ha₃c⟩
      · exact ⟨b, .refl, .head ha₂ ha₂b⟩
      · -- Both paths start with a step: a → a₂ →* b and a → a₃ →* c
        -- Local confluence: ∃ d, a₂ →* d ∧ a₃ →* d
        obtain ⟨d, hd₂, hd₃⟩ := hlc ha₂ ha₃
        -- IH at a₂ (a₂ < a): a₂ →* b and a₂ →* d gives ∃ e, b →* e ∧ d →* e
        obtain ⟨e, heb, hed⟩ := ih a₂ ha₂ ha₂b hd₂
        -- IH at a₃ (a₃ < a): a₃ →* c and a₃ →* d →* e gives ∃ f, c →* f ∧ e →* f
        obtain ⟨f, hfc, hfe⟩ := ih a₃ ha₃ ha₃c (hd₃.trans hed)
        exact ⟨f, heb.trans hfe, hfc⟩

/-- A normal form cannot be further reduced: if `u` is a normal form and
`u →* v`, then `u = v`. -/
theorem nf_eq_of_rtc {α : Type*} {r : α → α → Prop} {u v : α}
    (hnf : IsNF r u) (huv : ReflTransGen r u v) : u = v := by
  rcases huv.cases_head with rfl | ⟨w, hw, _⟩
  · rfl
  · exact absurd hw (hnf w)

/-- Normal forms are unique under confluence: if `a →* b₁` and `a →* b₂` with
both `b₁, b₂` normal forms, then `b₁ = b₂`. -/
theorem nf_unique_of_confl {α : Type*} {r : α → α → Prop}
    (hconf : IsConfl r) {a b₁ b₂ : α}
    (hnf₁ : IsNF r b₁) (hnf₂ : IsNF r b₂)
    (h₁ : ReflTransGen r a b₁) (h₂ : ReflTransGen r a b₂) :
    b₁ = b₂ := by
  obtain ⟨d, hd₁, hd₂⟩ := hconf h₁ h₂
  rw [nf_eq_of_rtc hnf₁ hd₁, nf_eq_of_rtc hnf₂ hd₂]

/-- A **certified normalizer** packages a rewrite relation with a normal-form
function and all correctness witnesses. -/
structure CertifiedNormalizer (T : Type*) where
  /-- The oriented rewrite relation -/
  R : T → T → Prop
  /-- The normal-form function -/
  nf : T → T
  /-- The normal form is always in normal form -/
  nf_normal : ∀ t, IsNF R (nf t)
  /-- `t` rewrites to `nf t` in finitely many steps -/
  nf_reduces : ∀ t, ReflTransGen R t (nf t)
  /-- Normal forms are unique -/
  nf_unique : ∀ t u, IsNF R u → ReflTransGen R t u → u = nf t

/-! ## Part II: Soundness and the Master Theorem -/

/-- A rewrite relation `R` is **sound** for an evaluation function if every
single-step rewrite preserves evaluation in every model. -/
def RewriteSound {T A VarType : Type*}
    (R : T → T → Prop) (eval' : (VarType → A) → T → A) : Prop :=
  ∀ ⦃s t : T⦄, R s t → ∀ (ι : VarType → A), eval' ι s = eval' ι t

/-- **Multi-step soundness**: single-step soundness lifts to the reflexive-
transitive closure by induction. -/
theorem rtc_sound_of_step_sound {T A VarType : Type*}
    {R : T → T → Prop} {eval' : (VarType → A) → T → A}
    (hR : RewriteSound R eval')
    {s t : T} (hst : ReflTransGen R s t) :
    ∀ (ι : VarType → A), eval' ι s = eval' ι t := by
  induction hst with
  | refl => exact fun _ => rfl
  | @tail b c _hab hbc ih => exact fun ι => (ih ι).trans (hR hbc ι)

/-- **The Master Optimizer Theorem**: The normal-form map of a convergent sound
rewrite system preserves semantics in every model.

This is the unified foundation for certified algebraic optimization. Every
compiler pass, SMT simplification, and Gröbner basis reduction that can be
expressed as a convergent rewrite system is an instance of this theorem. -/
theorem convergent_nf_preserves_eval {T A VarType : Type*}
    (N : CertifiedNormalizer T)
    {eval' : (VarType → A) → T → A}
    (hR : RewriteSound N.R eval') :
    ∀ (t : T) (ι : VarType → A), eval' ι (N.nf t) = eval' ι t :=
  fun t ι => (rtc_sound_of_step_sound hR (N.nf_reduces t) ι).symm

/-- The normalizer is **idempotent**: normal forms are fixed points. -/
theorem nf_idempotent {T : Type*} (N : CertifiedNormalizer T) :
    ∀ t, N.nf (N.nf t) = N.nf t := by
  intro t
  exact (nf_eq_of_rtc (N.nf_normal t) (N.nf_reduces (N.nf t))).symm

/-- Two terms with the same normal form evaluate identically.
This gives a **decision procedure** for semantic equivalence:
compute normal forms and compare syntactically. -/
theorem eval_eq_of_nf_eq {T A VarType : Type*}
    (N : CertifiedNormalizer T)
    {eval' : (VarType → A) → T → A}
    (hR : RewriteSound N.R eval')
    {s t : T} (h : N.nf s = N.nf t) :
    ∀ (ι : VarType → A), eval' ι s = eval' ι t := by
  intro ι
  calc eval' ι s = eval' ι (N.nf s) := (convergent_nf_preserves_eval N hR s ι).symm
    _ = eval' ι (N.nf t) := by rw [h]
    _ = eval' ι t := convergent_nf_preserves_eval N hR t ι

/-- **Normalizer composition**: composing two sound normalizers preserves
evaluation. This models optimization pass pipelines in verified compilers. -/
theorem compose_normalizers_sound {T A VarType : Type*}
    (N₁ N₂ : CertifiedNormalizer T)
    {eval' : (VarType → A) → T → A}
    (hR₁ : RewriteSound N₁.R eval')
    (hR₂ : RewriteSound N₂.R eval') :
    ∀ (t : T) (ι : VarType → A),
      eval' ι (N₁.nf (N₂.nf t)) = eval' ι t := by
  intro t ι
  rw [convergent_nf_preserves_eval N₁ hR₁, convergent_nf_preserves_eval N₂ hR₂]

/-- Two normalizers for the same rewrite system must agree. -/
theorem normalizers_agree {T : Type*}
    (N₁ N₂ : CertifiedNormalizer T)
    (hR : N₁.R = N₂.R) :
    N₁.nf = N₂.nf := by
  ext t
  symm
  apply N₁.nf_unique
  · exact hR ▸ N₂.nf_normal t
  · exact hR ▸ N₂.nf_reduces t

/-! ## Part III: Quotient Factorization -/

/-- Normal forms are constant on equivalence classes generated by the
rewrite relation. Under confluence, `EqvGen R`-equivalent terms have
equal normal forms.

**Proof**: By induction on the `EqvGen` derivation. The key case is `rel`:
given `x →R y`, both `nf(x)` and `nf(y)` are reachable from `x`, so
confluence gives a common reduct `d`. Since both are normal forms, they
equal `d`, hence equal each other. -/
theorem nf_constant_on_eqvGen {T : Type*}
    (N : CertifiedNormalizer T)
    (hconf : IsConfl N.R) :
    ∀ {s t : T}, EqvGen N.R s t → N.nf s = N.nf t := by
  intro s t h
  induction h with
  | rel x y hxy =>
    -- x →R y, need nf(x) = nf(y)
    -- x →* nf(x) and x → y →* nf(y)
    have hx_nfx : ReflTransGen N.R x (N.nf x) := N.nf_reduces x
    have hx_nfy : ReflTransGen N.R x (N.nf y) := .head hxy (N.nf_reduces y)
    obtain ⟨d, hd₁, hd₂⟩ := hconf hx_nfx hx_nfy
    rw [nf_eq_of_rtc (N.nf_normal x) hd₁, nf_eq_of_rtc (N.nf_normal y) hd₂]
  | refl => rfl
  | symm _ _ _ ih => exact ih.symm
  | trans _ _ _ _ _ ih₁ ih₂ => exact ih₁.trans ih₂

/-- The normalizer descends to the quotient: it defines a well-defined function
on `Quot (EqvGen R)`. -/
noncomputable def quotientNf {T : Type*}
    (N : CertifiedNormalizer T)
    (hconf : IsConfl N.R) :
    Quot (EqvGen N.R) → T :=
  Quot.lift N.nf (fun _a _b hab => nf_constant_on_eqvGen N hconf hab)

/-- The quotient normalizer agrees with `nf` on representatives. -/
theorem quotientNf_mk {T : Type*} (N : CertifiedNormalizer T)
    (hconf : IsConfl N.R) (t : T) :
    quotientNf N hconf (Quot.mk _ t) = N.nf t := rfl

/-! ## Part IV: Newman's Lemma Applied -/

/-- From termination + local confluence, we get confluence via Newman's Lemma. -/
theorem newman_gives_confluence {T : Type*} (R : T → T → Prop)
    (hwf : WellFounded (fun x y => R y x))
    (hlc : LocallyConfluent R) :
    IsConfl R :=
  newmans_lemma R hwf hlc

/-- In a terminating system, every element has a normal form.
Proved by well-founded induction on the termination order. -/
theorem terminating_has_nf {T : Type*} (R : T → T → Prop)
    (hwf : WellFounded (fun x y => R y x))
    (t : T) :
    ∃ u, ReflTransGen R t u ∧ IsNF R u := by
  induction hwf.apply t with
  | intro t _ ih =>
    by_cases h : ∃ u, R t u
    · obtain ⟨u, hu⟩ := h
      obtain ⟨v, hv, hvnf⟩ := ih u hu
      exact ⟨v, .head hu hv, hvnf⟩
    · push_neg at h
      exact ⟨t, .refl, h⟩

/-! ## Part V: Cross-Domain — Ring Expression Normalization -/

/-- A simple expression type for ring/semiring expressions. -/
inductive RExpr (α : Type*)
  | var : α → RExpr α
  | zero : RExpr α
  | one : RExpr α
  | add : RExpr α → RExpr α → RExpr α
  | mul : RExpr α → RExpr α → RExpr α

/-- Evaluate a ring expression in a commutative semiring. -/
def RExpr.eval {α A : Type*} [CommSemiring A] (ι : α → A) : RExpr α → A
  | .var x => ι x
  | .zero => 0
  | .one => 1
  | .add e₁ e₂ => e₁.eval ι + e₂.eval ι
  | .mul e₁ e₂ => e₁.eval ι * e₂.eval ι

/-- Size of a ring expression. -/
def RExpr.size {α : Type*} : RExpr α → ℕ
  | .var _ => 1
  | .zero => 1
  | .one => 1
  | .add e₁ e₂ => 1 + e₁.size + e₂.size
  | .mul e₁ e₂ => 1 + e₁.size + e₂.size

theorem RExpr.size_pos {α : Type*} (e : RExpr α) : 0 < e.size := by
  cases e <;> simp [RExpr.size]

/-- Additive commutativity rewrite on ring expressions. -/
inductive AddCommRewrite {α : Type*} : RExpr α → RExpr α → Prop
  | comm (e₁ e₂ : RExpr α) : AddCommRewrite (.add e₁ e₂) (.add e₂ e₁)

/-- Multiplicative commutativity rewrite. -/
inductive MulCommRewrite {α : Type*} : RExpr α → RExpr α → Prop
  | comm (e₁ e₂ : RExpr α) : MulCommRewrite (.mul e₁ e₂) (.mul e₂ e₁)

/-- Distributivity rewrite: a * (b + c) → a * b + a * c. -/
inductive DistribRewrite {α : Type*} : RExpr α → RExpr α → Prop
  | left_distrib (a b c : RExpr α) :
      DistribRewrite (.mul a (.add b c)) (.add (.mul a b) (.mul a c))

/-- The additive commutativity rewrite is sound in any commutative semiring. -/
theorem addComm_sound {α A : Type*} [CommSemiring A] :
    RewriteSound (@AddCommRewrite α) (fun (ι : α → A) => RExpr.eval ι) := by
  intro s t h ι; cases h; simp [RExpr.eval, add_comm]

/-- The multiplicative commutativity rewrite is sound. -/
theorem mulComm_sound {α A : Type*} [CommSemiring A] :
    RewriteSound (@MulCommRewrite α) (fun (ι : α → A) => RExpr.eval ι) := by
  intro s t h ι; cases h; simp [RExpr.eval, mul_comm]

/-- The distributivity rewrite is sound. -/
theorem distrib_sound {α A : Type*} [CommSemiring A] :
    RewriteSound (@DistribRewrite α) (fun (ι : α → A) => RExpr.eval ι) := by
  intro s t h ι; cases h; simp [RExpr.eval, mul_add]

/-- **Cross-domain theorem**: Any convergent sound rewrite system on ring
expressions preserves evaluation in every commutative semiring model. -/
theorem ring_nf_preserves_eval {α A : Type*} [CommSemiring A]
    (N : CertifiedNormalizer (RExpr α))
    (hR : RewriteSound N.R (fun (ι : α → A) => RExpr.eval ι)) :
    ∀ (t : RExpr α) (ι : α → A),
      RExpr.eval ι (N.nf t) = RExpr.eval ι t :=
  convergent_nf_preserves_eval N hR

/-- Union of two rewrite relations. -/
inductive UnionRewrite {α : Type*} (R₁ R₂ : α → α → Prop) : α → α → Prop
  | left {a b : α} : R₁ a b → UnionRewrite R₁ R₂ a b
  | right {a b : α} : R₂ a b → UnionRewrite R₁ R₂ a b

/-- The union of two sound rewrites is sound. -/
theorem union_sound {T A VarType : Type*}
    {R₁ R₂ : T → T → Prop} {eval' : (VarType → A) → T → A}
    (h₁ : RewriteSound R₁ eval') (h₂ : RewriteSound R₂ eval') :
    RewriteSound (UnionRewrite R₁ R₂) eval' := by
  intro s t h ι
  cases h with
  | left h => exact h₁ h ι
  | right h => exact h₂ h ι

/-! ## Part VI: Critical Pairs -/

/-- A **critical pair** represents an overlap between two rewrite rule
applications at a common term. -/
structure CriticalPair (T : Type*) where
  /-- The common ancestor term -/
  peak : T
  /-- Result of applying the first rule -/
  left_result : T
  /-- Result of applying the second rule -/
  right_result : T

/-- A critical pair is **joinable** if both results reduce to a common term. -/
def CriticalPair.Joinable {T : Type*} (R : T → T → Prop)
    (cp : CriticalPair T) : Prop :=
  ∃ d, ReflTransGen R cp.left_result d ∧ ReflTransGen R cp.right_result d

/-- If all critical pairs are joinable and the critical pairs capture all
one-step divergences, the relation is locally confluent.

This is the **Critical Pair Lemma** (one direction). -/
theorem locally_confluent_of_joinable_cps {T : Type*} (R : T → T → Prop)
    (cps : Set (CriticalPair T))
    (h_complete : ∀ a b c, R a b → R a c →
      ∃ cp ∈ cps, cp.peak = a ∧
        ReflTransGen R b cp.left_result ∧ ReflTransGen R c cp.right_result)
    (h_joinable : ∀ cp ∈ cps, cp.Joinable R) :
    LocallyConfluent R := by
  intro a b c hab hac
  obtain ⟨cp, hcp_mem, _, hb_cp, hc_cp⟩ := h_complete a b c hab hac
  obtain ⟨d, hd_l, hd_r⟩ := h_joinable cp hcp_mem
  exact ⟨d, hb_cp.trans hd_l, hc_cp.trans hd_r⟩

/-- **The Critical Pair Theorem**: For a terminating system with a complete
set of critical pairs, joinability of all critical pairs implies confluence.
This combines the Critical Pair Lemma with Newman's Lemma. -/
theorem confluence_of_cps_joinable {T : Type*} (R : T → T → Prop)
    (hwf : WellFounded (fun x y => R y x))
    (cps : Set (CriticalPair T))
    (h_complete : ∀ a b c, R a b → R a c →
      ∃ cp ∈ cps, cp.peak = a ∧
        ReflTransGen R b cp.left_result ∧ ReflTransGen R c cp.right_result)
    (h_joinable : ∀ cp ∈ cps, cp.Joinable R) :
    IsConfl R :=
  newmans_lemma R hwf
    (locally_confluent_of_joinable_cps R cps h_complete h_joinable)

/-! ## Part VII: The Convergent Quotient Optimizer Structure -/

/-- A **ConvergentQuotientOptimizer** bundles a convergent rewrite system with
its correctness certificate. This is the novel structure that packages
everything needed for certified algebraic optimization. -/
structure ConvergentQuotientOptimizer (T A VarType : Type*) where
  /-- The certified normalizer -/
  normalizer : CertifiedNormalizer T
  /-- The evaluation function -/
  eval' : (VarType → A) → T → A
  /-- The rewrite relation is sound -/
  sound : RewriteSound normalizer.R eval'

/-- The optimizer preserves semantics. -/
theorem ConvergentQuotientOptimizer.preserves_eval
    {T A VarType : Type*} (opt : ConvergentQuotientOptimizer T A VarType) :
    ∀ (t : T) (ι : VarType → A),
      opt.eval' ι (opt.normalizer.nf t) = opt.eval' ι t :=
  convergent_nf_preserves_eval opt.normalizer opt.sound

/-- The optimizer is idempotent. -/
theorem ConvergentQuotientOptimizer.idempotent
    {T A VarType : Type*} (opt : ConvergentQuotientOptimizer T A VarType) :
    ∀ t, opt.normalizer.nf (opt.normalizer.nf t) = opt.normalizer.nf t :=
  nf_idempotent opt.normalizer

/-! ## Part VIII: Boolean Expression Optimization — Worked Example -/

/-- Simple Boolean expressions. -/
inductive BExpr
  | var : ℕ → BExpr
  | true_ : BExpr
  | false_ : BExpr
  | and_ : BExpr → BExpr → BExpr
  | or_ : BExpr → BExpr → BExpr
  | not_ : BExpr → BExpr

/-- Evaluate a Boolean expression. -/
def BExpr.eval (ι : ℕ → Bool) : BExpr → Bool
  | .var n => ι n
  | .true_ => true
  | .false_ => false
  | .and_ a b => a.eval ι && b.eval ι
  | .or_ a b => a.eval ι || b.eval ι
  | .not_ a => !(a.eval ι)

/-- Idempotent AND rewrite: x ∧ x → x. -/
inductive AndIdempotentRewrite : BExpr → BExpr → Prop
  | idem (e : BExpr) : AndIdempotentRewrite (.and_ e e) e

/-- Idempotent OR rewrite: x ∨ x → x. -/
inductive OrIdempotentRewrite : BExpr → BExpr → Prop
  | idem (e : BExpr) : OrIdempotentRewrite (.or_ e e) e

/-- The AND idempotent rewrite is sound. -/
theorem and_idem_sound :
    RewriteSound AndIdempotentRewrite
      (fun (ι : ℕ → Bool) => BExpr.eval ι) := by
  intro s t h ι; cases h; simp [BExpr.eval, Bool.and_self]

/-- The OR idempotent rewrite is sound. -/
theorem or_idem_sound :
    RewriteSound OrIdempotentRewrite
      (fun (ι : ℕ → Bool) => BExpr.eval ι) := by
  intro s t h ι; cases h; simp [BExpr.eval, Bool.or_self]

/-! ## Part IX: Abstraction Theorem -/

/-- **Abstraction Theorem**: If `φ` maps terms from domain T to domain S such
that evaluation is preserved, then normalizing in S via φ preserves evaluation
relative to T. This provides a framework for **abstraction refinement**. -/
theorem abstraction_preserves_eval {T S A VarType : Type*}
    (N : CertifiedNormalizer S)
    {evalT : (VarType → A) → T → A}
    {evalS : (VarType → A) → S → A}
    (φ : T → S)
    (hR : RewriteSound N.R evalS)
    (hφ_eval : ∀ t ι, evalS ι (φ t) = evalT ι t) :
    ∀ (t : T) (ι : VarType → A),
      evalS ι (N.nf (φ t)) = evalT ι t := by
  intro t ι
  rw [convergent_nf_preserves_eval N hR (φ t) ι, hφ_eval]

/-! ## Part X: Simplifying Systems and Size Bounds -/

/-- Multi-step rewriting in a size-reducing system decreases size. -/
theorem rtc_size_mono {α : Type*} {R : RExpr α → RExpr α → Prop}
    (h_step : ∀ s t, R s t → RExpr.size t ≤ RExpr.size s)
    {s t : RExpr α} (hst : ReflTransGen R s t) :
    RExpr.size t ≤ RExpr.size s := by
  induction hst with
  | refl => exact le_refl _
  | @tail b c _hab hbc ih => exact le_trans (h_step b c hbc) ih

/-- For a normalizer where every rewrite step does not increase size,
the normal form is never larger than the input. -/
theorem simplifying_nf_bounded {α : Type*}
    (N : CertifiedNormalizer (RExpr α))
    (h_simplifying : ∀ s t, N.R s t → RExpr.size t ≤ RExpr.size s) :
    ∀ t, RExpr.size (N.nf t) ≤ RExpr.size t :=
  fun t => rtc_size_mono h_simplifying (N.nf_reduces t)

/-- Normal form complexity ratio is at most 1 for simplifying systems. -/
theorem simplifying_complexity_le_one {α : Type*}
    (N : CertifiedNormalizer (RExpr α))
    (h_simplifying : ∀ s t, N.R s t → RExpr.size t ≤ RExpr.size s)
    (t : RExpr α) :
    (RExpr.size (N.nf t) : ℚ) / (RExpr.size t : ℚ) ≤ 1 := by
  apply div_le_one_of_le₀
  · exact Nat.cast_le.mpr (simplifying_nf_bounded N h_simplifying t)
  · exact Nat.cast_nonneg _

/-! ## Part XI: Falsifiable Conjecture

**Conjecture (Linear Normal Form Blowup for Simplifying Systems)**:
For any convergent *simplifying* rewrite system R, for every term t:
  `size(nf(t)) ≤ size(t)`

**Status**: This is verified above (`simplifying_nf_bounded`).

The interesting open question is whether *non-simplifying* but terminating
systems always have polynomial blowup. This is known to be FALSE in general:
the distributive law `a * (b + c) → a*b + a*c` can cause exponential blowup
(consider `a₁ * (a₂ * (... * (aₙ₋₁ + aₙ)...))`).

**Computational Test**: Generate 50 convergent non-simplifying rewrite systems,
compute normal forms of 10000 random terms, track `size(nf(t)) / size(t)`.
If the ratio grows faster than any polynomial in `size(t)` for any system,
the polynomial bound conjecture is refuted.
-/

-- Verify axiom cleanliness of main theorems
#print axioms newmans_lemma
#print axioms convergent_nf_preserves_eval
#print axioms nf_constant_on_eqvGen
#print axioms compose_normalizers_sound
#print axioms eval_eq_of_nf_eq
#print axioms confluence_of_cps_joinable
#print axioms simplifying_nf_bounded
#print axioms abstraction_preserves_eval
#print axioms nf_idempotent
#print axioms normalizers_agree