import Mathlib

/-!
# Many-Sorted Convergent Rewrite Systems as Certified Quotient Optimizers

## Overview

This file lifts the single-sorted master theorem of certified algebraic optimization
to the many-sorted setting. The central result is the **many-sorted master theorem**:
if a rewrite system on many-sorted terms is convergent and every rewrite step is sound
in a many-sorted algebra, then the induced normal-form map preserves denotation at every
sort, in every model.

This is the formal bridge from single-sorted quotient optimizers to **typed symbolic
optimization** across algebra, module theory, representation theory, and beyond.

## Main Theorems

- `ms_rtc_sound`: multi-step rewrite soundness across sorts (Theorem 1).
- `ms_nf_preserves_eval`: many-sorted master theorem (Theorem 2).
- `ms_nf_preserves_eval_in_models`: model-theoretic master theorem (Theorem 3).
- `modRewrite_sound`: module rewrite rules are sound (Theorem 4).
- `module_nf_preserves_eval`: cross-domain module preservation (Theorem 5).
- `ms_nf_eval_eq_of_sound`: equal nf evals imply equal evals (Theorem 6).
- `ms_compose_preserves_eval`: normalizer composition (Theorem 7).
-/

open Relation

universe u

/-! ## Section 1: Many-Sorted Signatures -/

/-- A many-sorted signature: operation symbols with typed arities and result sorts.
Each operation `f` has `ar f` arguments, where argument `i` has sort `argSort f i`,
and the result has sort `result f`. -/
structure ManySortedSig (S : Type*) where
  /-- The type of operation symbols. -/
  Op : Type*
  /-- The number of arguments of each operation. -/
  ar : Op → ℕ
  /-- The sort of the `i`-th argument of operation `f`. -/
  argSort : (f : Op) → Fin (ar f) → S
  /-- The result sort of each operation. -/
  result : Op → S

/-! ## Section 2: Many-Sorted Terms -/

variable {S : Type*}

/-- Many-sorted terms over a signature with sort-indexed variables.
A term is either a variable of some sort, or an application of an operation
to arguments of the correct sorts. -/
inductive MSTerm (Sig : ManySortedSig S) (Var : S → Type*) : S → Type _
  | var {s : S} : Var s → MSTerm Sig Var s
  | app (f : Sig.Op) (args : (i : Fin (Sig.ar f)) → MSTerm Sig Var (Sig.argSort f i)) :
      MSTerm Sig Var (Sig.result f)

/-! ## Section 3: Many-Sorted Algebras and Evaluation -/

/-- A many-sorted algebra: a carrier set for each sort and an interpretation
for each operation symbol respecting the sort structure. -/
structure MSAlg (Sig : ManySortedSig S) where
  /-- The carrier type for each sort. -/
  Carrier : S → Type*
  /-- The interpretation of each operation symbol. -/
  interp : (f : Sig.Op) → ((i : Fin (Sig.ar f)) → Carrier (Sig.argSort f i)) →
    Carrier (Sig.result f)

/-- Evaluate a many-sorted term in an algebra under a variable assignment.
Defined by structural recursion on the term. -/
def MSTerm.eval {Sig : ManySortedSig S} {Var : S → Type*}
    (A : MSAlg Sig) (ρ : ∀ s, Var s → A.Carrier s) :
    {s : S} → MSTerm Sig Var s → A.Carrier s
  | _, .var x => ρ _ x
  | _, .app f args => A.interp f (fun i => eval A ρ (args i))

/-! ## Section 4: Rewrite Relations and Soundness -/

/-- A many-sorted rewrite rule: a pair of terms at the same sort. -/
structure MSRule (Sig : ManySortedSig S) (Var : S → Type*) where
  sort : S
  lhs : MSTerm Sig Var sort
  rhs : MSTerm Sig Var sort

/-- A sort-indexed rewrite relation is **sound** in algebra `A` if every single-step
rewrite at any sort preserves evaluation. -/
def MSRewriteSound {Sig : ManySortedSig S} {Var : S → Type*}
    (R : ∀ s, MSTerm Sig Var s → MSTerm Sig Var s → Prop)
    (A : MSAlg Sig) : Prop :=
  ∀ (s : S) (t u : MSTerm Sig Var s), R s t u →
    ∀ (ρ : ∀ s, Var s → A.Carrier s), MSTerm.eval A ρ t = MSTerm.eval A ρ u

/-! ## Section 5: Many-Sorted Certified Normalizer -/

/-- A **many-sorted certified normalizer**: a sort-indexed rewrite relation,
a sort-preserving normal-form function, and the witness that every term
reduces to its normal form. -/
structure MSCertifiedNormalizer (Sig : ManySortedSig S) (Var : S → Type*) where
  R : ∀ s, MSTerm Sig Var s → MSTerm Sig Var s → Prop
  nf : ∀ {s : S}, MSTerm Sig Var s → MSTerm Sig Var s
  nf_reduces : ∀ (s : S) (t : MSTerm Sig Var s), ReflTransGen (R s) t (nf t)

/-! ## Section 6: Theorem 1 — Multi-Step Soundness -/

/-
**Theorem 1: Multi-step semantic preservation across sorts.**
One-step soundness lifts to the reflexive-transitive closure at each sort.

**Proof.** By induction on `ReflTransGen`. The base case is `rfl`;
the step case applies one-step soundness and transitivity of `=`.
-/
theorem ms_rtc_sound {Sig : ManySortedSig S} {Var : S → Type*}
    {R : ∀ s, MSTerm Sig Var s → MSTerm Sig Var s → Prop}
    {A : MSAlg Sig}
    (hSound : MSRewriteSound R A)
    {s : S} {t u : MSTerm Sig Var s}
    (htu : ReflTransGen (R s) t u) :
    ∀ (ρ : ∀ s, Var s → A.Carrier s),
      MSTerm.eval A ρ t = MSTerm.eval A ρ u := by
  induction htu;
  · exact fun _ => rfl;
  · exact fun ρ => Eq.trans ( by solve_by_elim ) ( hSound _ _ _ ‹_› ρ )

/-! ## Section 7: Theorem 2 — Many-Sorted Master Theorem -/

/-
**Theorem 2: The many-sorted master theorem.**
The normal-form map induced by a convergent sound rewrite system preserves
semantics at every sort, in every algebra where the rules are sound.

**Proof.** Apply `ms_rtc_sound` to the reduction `t →* nf t`.
-/
theorem ms_nf_preserves_eval {Sig : ManySortedSig S} {Var : S → Type*}
    (N : MSCertifiedNormalizer Sig Var)
    {A : MSAlg Sig}
    (hSound : MSRewriteSound N.R A)
    {s : S} (t : MSTerm Sig Var s)
    (ρ : ∀ s, Var s → A.Carrier s) :
    MSTerm.eval A ρ (N.nf t) = MSTerm.eval A ρ t := by
  convert ms_rtc_sound hSound ( N.nf_reduces s t ) ρ |> Eq.symm

/-! ## Section 8: Theorem 3 — Model-Theoretic Master Theorem -/

/-- A many-sorted equation. -/
structure MSEquation (Sig : ManySortedSig S) (Var : S → Type*) where
  sort : S
  lhs : MSTerm Sig Var sort
  rhs : MSTerm Sig Var sort

/-- A many-sorted model of an equational theory: an algebra satisfying all equations. -/
structure MSModel {Sig : ManySortedSig S} {Var : S → Type*}
    (E : Set (MSEquation Sig Var)) extends MSAlg Sig where
  satisfies : ∀ e ∈ E, ∀ (ρ : ∀ s, Var s → toMSAlg.Carrier s),
    MSTerm.eval toMSAlg ρ e.lhs = MSTerm.eval toMSAlg ρ e.rhs

/-- **Theorem 3: Model-theoretic master theorem.**
Normalization preserves denotation in any algebra that satisfies an equational theory `E`,
provided the rewrite rules are sound in that algebra.

The formulation takes the model `M` first and the soundness hypothesis for that
specific model, avoiding universe-polymorphism issues with quantifying over all models.
The "for all models" aspect is recovered by instantiating this theorem for each model. -/
theorem ms_nf_preserves_eval_in_models {Sig : ManySortedSig S} {Var : S → Type*}
    (E : Set (MSEquation Sig Var))
    (N : MSCertifiedNormalizer Sig Var)
    (M : MSModel E)
    (hSound : MSRewriteSound N.R M.toMSAlg)
    {s : S}
    (t : MSTerm Sig Var s)
    (ρ : ∀ s, Var s → M.toMSAlg.Carrier s) :
    MSTerm.eval M.toMSAlg ρ (N.nf t) = MSTerm.eval M.toMSAlg ρ t := by
  exact ms_nf_preserves_eval N hSound t ρ

/-! ## Section 9: Theorems 6 & 7 — Derived Properties -/

/-
**Theorem 6: Terms with equal normal-form evaluations have equal evaluations.**
-/
theorem ms_nf_eval_eq_of_sound {Sig : ManySortedSig S} {Var : S → Type*}
    (N : MSCertifiedNormalizer Sig Var)
    {A : MSAlg Sig}
    (hSound : MSRewriteSound N.R A)
    {s : S} (t₁ t₂ : MSTerm Sig Var s)
    (heq : ∀ (ρ : ∀ s, Var s → A.Carrier s),
      MSTerm.eval A ρ (N.nf t₁) = MSTerm.eval A ρ (N.nf t₂))
    (ρ : ∀ s, Var s → A.Carrier s) :
    MSTerm.eval A ρ t₁ = MSTerm.eval A ρ t₂ := by
  convert ms_nf_preserves_eval N hSound t₁ ρ |> Eq.symm |> Eq.trans <| ( heq ρ ) |> Eq.trans <| ms_nf_preserves_eval N hSound t₂ ρ using 1

/-
**Theorem 7: Composition of normalizers preserves semantics.**
-/
theorem ms_compose_preserves_eval {Sig : ManySortedSig S} {Var : S → Type*}
    (N₁ N₂ : MSCertifiedNormalizer Sig Var)
    {A : MSAlg Sig}
    (h₁ : MSRewriteSound N₁.R A)
    (h₂ : MSRewriteSound N₂.R A)
    {s : S} (t : MSTerm Sig Var s)
    (ρ : ∀ s, Var s → A.Carrier s) :
    MSTerm.eval A ρ (N₁.nf (N₂.nf t)) = MSTerm.eval A ρ t := by
  rw [ ms_nf_preserves_eval N₁ h₁, ms_nf_preserves_eval N₂ h₂ ]

/-! ## Section 10: Cross-Domain — Two-Sorted Module Theory -/

/-- The two sorts for module theory: scalars and vectors. -/
inductive ModSort : Type
  | Scal : ModSort
  | Vec : ModSort
  deriving DecidableEq, Repr

open ModSort

/-- Operation symbols for a two-sorted module signature. -/
inductive ModOp : Type
  | scZero | scOne | scAdd | scMul | vZero | vAdd | smul
  deriving DecidableEq, Repr

/-- Arity of each module operation. -/
@[simp, reducible]
def modAr : ModOp → ℕ
  | .scZero => 0 | .scOne => 0 | .scAdd => 2 | .scMul => 2
  | .vZero => 0 | .vAdd => 2 | .smul => 2

/-- Argument sorts for each module operation (defined separately for reduction). -/
@[simp, reducible]
def modArgSort : (f : ModOp) → Fin (modAr f) → ModSort
  | .scAdd, ⟨0, _⟩ => Scal | .scAdd, ⟨1, _⟩ => Scal
  | .scMul, ⟨0, _⟩ => Scal | .scMul, ⟨1, _⟩ => Scal
  | .vAdd,  ⟨0, _⟩ => Vec  | .vAdd,  ⟨1, _⟩ => Vec
  | .smul,  ⟨0, _⟩ => Scal | .smul,  ⟨1, _⟩ => Vec

/-- Result sort for each module operation. -/
@[simp, reducible]
def modResult : ModOp → ModSort
  | .scZero => Scal | .scOne => Scal | .scAdd => Scal | .scMul => Scal
  | .vZero => Vec | .vAdd => Vec | .smul => Vec

/-- The module signature: a two-sorted signature for ring-module theory. -/
@[simp, reducible]
def ModuleSig : ManySortedSig ModSort where
  Op := ModOp
  ar := modAr
  argSort := modArgSort
  result := modResult

/-- Variables indexed by module sort (3 variables per sort). -/
@[reducible]
def ModVar : ModSort → Type
  | Scal => Fin 3
  | Vec  => Fin 3

/-- Scalar zero term. -/
def scZeroT : MSTerm ModuleSig ModVar Scal :=
  MSTerm.app (Sig := ModuleSig) (Var := ModVar) ModOp.scZero (fun i => Fin.elim0 i)

/-- Scalar one term. -/
def scOneT : MSTerm ModuleSig ModVar Scal :=
  MSTerm.app (Sig := ModuleSig) (Var := ModVar) ModOp.scOne (fun i => Fin.elim0 i)

/-- Vector zero term. -/
def vZeroT : MSTerm ModuleSig ModVar Vec :=
  MSTerm.app (Sig := ModuleSig) (Var := ModVar) ModOp.vZero (fun i => Fin.elim0 i)

/-- Scalar addition term. -/
def scAddT (a b : MSTerm ModuleSig ModVar Scal) : MSTerm ModuleSig ModVar Scal :=
  MSTerm.app (Sig := ModuleSig) (Var := ModVar) ModOp.scAdd
    (fun (i : Fin (modAr .scAdd)) => match i with | ⟨0, _⟩ => a | ⟨1, _⟩ => b)

/-- Vector addition term. -/
def vAddT (v w : MSTerm ModuleSig ModVar Vec) : MSTerm ModuleSig ModVar Vec :=
  MSTerm.app (Sig := ModuleSig) (Var := ModVar) ModOp.vAdd
    (fun (i : Fin (modAr .vAdd)) => match i with | ⟨0, _⟩ => v | ⟨1, _⟩ => w)

/-- Scalar-vector multiplication term. -/
def smulT (a : MSTerm ModuleSig ModVar Scal)
    (v : MSTerm ModuleSig ModVar Vec) : MSTerm ModuleSig ModVar Vec :=
  MSTerm.app (Sig := ModuleSig) (Var := ModVar) ModOp.smul
    (fun (i : Fin (modAr .smul)) => match i with | ⟨0, _⟩ => a | ⟨1, _⟩ => v)

/-- Module rewrite rules as a sort-indexed relation:
- `smul 0 v → 0`  (zero scalar annihilates)
- `smul 1 v → v`  (unit scalar identity)
- `smul a 0 → 0`  (action on zero)
- `smul a (v + w) → smul a v + smul a w` (distributivity) -/
inductive ModRewrite : (s : ModSort) → MSTerm ModuleSig ModVar s →
    MSTerm ModuleSig ModVar s → Prop
  | smul_zero (v : MSTerm ModuleSig ModVar Vec) :
      ModRewrite Vec (smulT scZeroT v) vZeroT
  | smul_one (v : MSTerm ModuleSig ModVar Vec) :
      ModRewrite Vec (smulT scOneT v) v
  | smul_vZero (a : MSTerm ModuleSig ModVar Scal) :
      ModRewrite Vec (smulT a vZeroT) vZeroT
  | smul_dist (a : MSTerm ModuleSig ModVar Scal)
      (v w : MSTerm ModuleSig ModVar Vec) :
      ModRewrite Vec (smulT a (vAddT v w))
        (vAddT (smulT a v) (smulT a w))

/-- A module-style algebra from a commutative ring `R` and `R`-module `M`.
Both `R` and `M` must inhabit the same universe. -/
noncomputable def moduleAlgebra (R : Type u) (M : Type u)
    [CommRing R] [AddCommGroup M] [Module R M] : MSAlg ModuleSig where
  Carrier | Scal => R | Vec => M
  interp f args := match f with
    | ModOp.scZero => (0 : R)
    | ModOp.scOne  => (1 : R)
    | ModOp.scAdd  => (args ⟨0, by decide⟩ : R) + (args ⟨1, by decide⟩ : R)
    | ModOp.scMul  => (args ⟨0, by decide⟩ : R) * (args ⟨1, by decide⟩ : R)
    | ModOp.vZero  => (0 : M)
    | ModOp.vAdd   => (args ⟨0, by decide⟩ : M) + (args ⟨1, by decide⟩ : M)
    | ModOp.smul   => (args ⟨0, by decide⟩ : R) • (args ⟨1, by decide⟩ : M)

/-
**Theorem 4: Module rewrite soundness.**
Each module rewrite rule preserves evaluation in any `R`-module `M`.
-/
theorem modRewrite_sound (R : Type u) (M : Type u)
    [CommRing R] [AddCommGroup M] [Module R M] :
    MSRewriteSound ModRewrite (moduleAlgebra R M) := by
  intro s t u h ρ; rcases h with ( ⟨ v ⟩ | ⟨ v ⟩ | ⟨ a ⟩ | ⟨ a, v, w ⟩ ) <;> simp_all +decide [ moduleAlgebra ] ;
  · exact zero_smul _ _;
  · exact one_smul _ _;
  · -- By definition of scalar multiplication, we have $a • 0 = 0$.
    apply smul_zero;
  · convert smul_add ( MSTerm.eval _ ρ a ) ( MSTerm.eval _ ρ v ) ( MSTerm.eval _ ρ w ) using 1

/-
**Theorem 5: Cross-domain semantic preservation for modules.**
Any convergent normalizer with module rewrite rules preserves evaluation.
-/
theorem module_nf_preserves_eval (R : Type u) (M : Type u)
    [CommRing R] [AddCommGroup M] [Module R M]
    (N : MSCertifiedNormalizer ModuleSig ModVar)
    (hR : N.R = ModRewrite)
    {s : ModSort} (t : MSTerm ModuleSig ModVar s)
    (ρ : ∀ s, ModVar s → (moduleAlgebra R M).Carrier s) :
    MSTerm.eval (moduleAlgebra R M) ρ (N.nf t) =
    MSTerm.eval (moduleAlgebra R M) ρ t := by
  convert ms_nf_preserves_eval N ( modRewrite_sound R M |> fun h => ?_ ) t ρ;
  convert h using 1