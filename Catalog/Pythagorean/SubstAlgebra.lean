import Mathlib

/-!
# De Bruijn Substitution Algebra

This file defines the core syntax of the untyped lambda calculus with de Bruijn
indices and establishes the σ-algebra of simultaneous substitutions.
-/

namespace DeBruijn

/-! ## Syntax -/

/-- De Bruijn indexed lambda calculus terms. -/
inductive LamDB where
  | var : Nat → LamDB
  | app : LamDB → LamDB → LamDB
  | lam : LamDB → LamDB
  deriving DecidableEq, Repr

open LamDB

/-! ## Renaming Infrastructure -/

abbrev Renaming := Nat → Nat
abbrev SubstEnv := Nat → LamDB

def Renaming.lift (ρ : Renaming) : Renaming
  | 0 => 0
  | n + 1 => ρ n + 1

def rename (ρ : Renaming) : LamDB → LamDB
  | .var k => .var (ρ k)
  | .app t u => .app (rename ρ t) (rename ρ u)
  | .lam t => .lam (rename ρ.lift t)

/-! ## Simultaneous Substitution Infrastructure -/

def SubstEnv.lift (σ : SubstEnv) : SubstEnv
  | 0 => .var 0
  | n + 1 => rename (· + 1) (σ n)

def substEnv (σ : SubstEnv) : LamDB → LamDB
  | .var k => σ k
  | .app t u => .app (substEnv σ t) (substEnv σ u)
  | .lam t => .lam (substEnv σ.lift t)

def SubstEnv.id : SubstEnv := .var

def scons (t : LamDB) (σ : SubstEnv) : SubstEnv
  | 0 => t
  | n + 1 => σ n

def subst0 (s : LamDB) (t : LamDB) : LamDB := substEnv (scons s SubstEnv.id) t

/-! ## Derived Operations -/

def shift (d c : Nat) (t : LamDB) : LamDB :=
  rename (fun k => if k < c then k else k + d) t

def subst (k : Nat) (s : LamDB) (t : LamDB) : LamDB :=
  substEnv (fun n => if n < k then .var n else if n = k then s else .var (n - 1)) t

/-! ## Lift Compatibility -/

theorem liftRen_comp (ρ₁ ρ₂ : Renaming) :
    Renaming.lift (ρ₁ ∘ ρ₂) = Renaming.lift ρ₁ ∘ Renaming.lift ρ₂ := by
  funext n; cases n <;> rfl

theorem liftSubst_comp_liftRen (σ : SubstEnv) (ρ : Renaming) :
    SubstEnv.lift (σ ∘ ρ) = SubstEnv.lift σ ∘ Renaming.lift ρ := by
  funext n; cases n <;> rfl

theorem liftRen_comp_succ (ρ : Renaming) :
    Renaming.lift ρ ∘ (· + 1) = (· + 1) ∘ ρ := by
  funext n; rfl

theorem liftSubst_succ (σ : SubstEnv) :
    SubstEnv.lift σ ∘ (· + 1) = fun k => rename (· + 1) (σ k) := by
  funext k; rfl

/-! ## Fusion Lemmas -/

theorem rename_rename (ρ₁ ρ₂ : Renaming) (t : LamDB) :
    rename ρ₁ (rename ρ₂ t) = rename (ρ₁ ∘ ρ₂) t := by
  induction t generalizing ρ₁ ρ₂ with
  | var => rfl
  | app _ _ ih₁ ih₂ => simp [rename, ih₁, ih₂]
  | lam _ ih => simp [rename]; rw [ih, liftRen_comp]

theorem substEnv_rename (σ : SubstEnv) (ρ : Renaming) (t : LamDB) :
    substEnv σ (rename ρ t) = substEnv (σ ∘ ρ) t := by
  induction t generalizing σ ρ with
  | var => rfl
  | app _ _ ih₁ ih₂ => simp [rename, substEnv, ih₁, ih₂]
  | lam _ ih => simp [rename, substEnv]; rw [ih, liftSubst_comp_liftRen]

theorem liftSubst_rename_comm (ρ : Renaming) (σ : SubstEnv) :
    SubstEnv.lift (fun k => rename ρ (σ k)) =
    fun k => rename (Renaming.lift ρ) (SubstEnv.lift σ k) := by
  funext k; cases k with
  | zero => rfl
  | succ n =>
    show rename (· + 1) (rename ρ (σ n)) = rename (Renaming.lift ρ) (rename (· + 1) (σ n))
    rw [rename_rename, rename_rename, liftRen_comp_succ]

theorem rename_substEnv (ρ : Renaming) (σ : SubstEnv) (t : LamDB) :
    rename ρ (substEnv σ t) = substEnv (fun k => rename ρ (σ k)) t := by
  induction t generalizing ρ σ with
  | var => rfl
  | app _ _ ih₁ ih₂ => simp [substEnv, rename, ih₁, ih₂]
  | lam _ ih => simp [substEnv, rename]; rw [ih, liftSubst_rename_comm]

theorem liftSubst_substEnv_comm (σ₁ σ₂ : SubstEnv) :
    SubstEnv.lift (fun k => substEnv σ₁ (σ₂ k)) =
    fun k => substEnv (SubstEnv.lift σ₁) (SubstEnv.lift σ₂ k) := by
  funext k; cases k with
  | zero => rfl
  | succ n =>
    show rename (· + 1) (substEnv σ₁ (σ₂ n)) = substEnv (SubstEnv.lift σ₁) (rename (· + 1) (σ₂ n))
    rw [rename_substEnv, substEnv_rename, liftSubst_succ]

theorem substEnv_comp (σ₁ σ₂ : SubstEnv) (t : LamDB) :
    substEnv σ₁ (substEnv σ₂ t) = substEnv (fun k => substEnv σ₁ (σ₂ k)) t := by
  induction t generalizing σ₁ σ₂ with
  | var => rfl
  | app _ _ ih₁ ih₂ => simp [substEnv, ih₁, ih₂]
  | lam _ ih => simp [substEnv]; rw [ih, liftSubst_substEnv_comm]

/-! ## Identity Lemmas -/

theorem liftRen_id : Renaming.lift id = id := by funext n; cases n <;> rfl

theorem liftSubst_id : SubstEnv.lift SubstEnv.id = SubstEnv.id := by
  funext n; cases n with
  | zero => rfl
  | succ n => show rename (· + 1) (.var n) = .var (n + 1); rfl

theorem rename_id (t : LamDB) : rename id t = t := by
  induction t with
  | var => rfl
  | app _ _ ih₁ ih₂ => simp [rename, ih₁, ih₂]
  | lam _ ih => simp [rename, liftRen_id, ih]

theorem substEnv_id (t : LamDB) : substEnv SubstEnv.id t = t := by
  induction t with
  | var => rfl
  | app _ _ ih₁ ih₂ => simp [substEnv, ih₁, ih₂]
  | lam _ ih => simp [substEnv, liftSubst_id, ih]

/-! ## Corollaries for Beta Reduction -/

/-- Renaming commutes with beta substitution. -/
theorem rename_subst0 (ρ : Renaming) (s body : LamDB) :
    rename ρ (subst0 s body) = subst0 (rename ρ s) (rename ρ.lift body) := by
  simp only [subst0]
  rw [rename_substEnv, substEnv_rename]
  congr 1
  funext k; cases k with
  | zero => rfl
  | succ n => simp [scons, SubstEnv.id, rename, Renaming.lift]

/-- **Key lemma**: Substitution commutes with beta substitution. -/
theorem substEnv_beta_comm (σ : SubstEnv) (s body : LamDB) :
    substEnv σ (subst0 s body) = subst0 (substEnv σ s) (substEnv σ.lift body) := by
  simp only [subst0]
  rw [substEnv_comp, substEnv_comp]
  congr 1
  funext k; cases k with
  | zero => rfl
  | succ n =>
    show substEnv σ (.var n) =
      substEnv (scons (substEnv σ s) SubstEnv.id) (rename (· + 1) (σ n))
    simp only [substEnv]
    rw [substEnv_rename]
    show σ n = substEnv (scons (substEnv σ s) SubstEnv.id ∘ (· + 1)) (σ n)
    have : (scons (substEnv σ s) SubstEnv.id ∘ (· + 1)) = SubstEnv.id := by
      funext k; rfl
    rw [this]; exact (substEnv_id (σ n)).symm

end DeBruijn