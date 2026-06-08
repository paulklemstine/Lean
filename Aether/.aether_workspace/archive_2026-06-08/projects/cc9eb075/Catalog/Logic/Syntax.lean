import Mathlib

/-!
# Lambda Calculus: Syntax, Substitution, and Beta Reduction

This module formalizes the untyped lambda calculus using de Bruijn indices,
with capture-avoiding substitution and one-step β-reduction.
-/

namespace LambdaCalculus

/-- Lambda terms using de Bruijn indices. -/
inductive Lam : Type where
  | var : ℕ → Lam
  | app : Lam → Lam → Lam
  | lam : Lam → Lam
  deriving DecidableEq, Repr

/-- `lift d c t` increments all free variables ≥ c by d. -/
def Lam.lift : ℕ → ℕ → Lam → Lam
  | d, c, .var n => if n < c then .var n else .var (n + d)
  | d, c, .app t u => .app (Lam.lift d c t) (Lam.lift d c u)
  | d, c, .lam t => .lam (Lam.lift d (c + 1) t)

/-- `substAt σ k t` replaces variable k in t with σ (lifted by k). -/
def Lam.substAt : Lam → ℕ → Lam → Lam
  | σ, k, .var n =>
    if n < k then .var n
    else if n = k then Lam.lift k 0 σ
    else .var (n - 1)
  | σ, k, .app t u => .app (Lam.substAt σ k t) (Lam.substAt σ k u)
  | σ, k, .lam t => .lam (Lam.substAt σ (k + 1) t)

/-- `subst0 u t` substitutes u for variable 0 in t. -/
def Lam.subst0 (u t : Lam) : Lam := Lam.substAt u 0 t

/-- The size of a lambda term. -/
def Lam.size : Lam → ℕ
  | .var _ => 1
  | .app t u => 1 + t.size + u.size
  | .lam t => 1 + t.size

/-- One-step β-reduction. -/
inductive Beta : Lam → Lam → Prop where
  | redex (t u : Lam) : Beta (.app (.lam t) u) (Lam.subst0 u t)
  | app_left (u : Lam) {t t' : Lam} : Beta t t' → Beta (.app t u) (.app t' u)
  | app_right (t : Lam) {u u' : Lam} : Beta u u' → Beta (.app t u) (.app t u')
  | lam_body {t t' : Lam} : Beta t t' → Beta (.lam t) (.lam t')

/-- A term is a normal form if it admits no β-reduction step. -/
def NormalForm (t : Lam) : Prop := ∀ u, ¬ Beta t u

/-- β-equivalence: the equivalence closure of β-reduction. -/
def BetaEq (t u : Lam) : Prop := Relation.EqvGen Beta t u

-- Standard combinators
def Lam.I : Lam := .lam (.var 0)
def Lam.K : Lam := .lam (.lam (.var 1))
def Lam.S : Lam := .lam (.lam (.lam (.app (.app (.var 2) (.var 0)) (.app (.var 1) (.var 0)))))
def Lam.omega : Lam := .app (.lam (.app (.var 0) (.var 0))) (.lam (.app (.var 0) (.var 0)))

-- ============================================================
-- Substitution lemmas
-- ============================================================

/-- Lifting by 0 is identity -/
theorem Lam.lift_zero (t : Lam) (c : ℕ) : Lam.lift 0 c t = t := by
  induction t generalizing c with
  | var n => simp [Lam.lift]
  | app t u iht ihu => simp [Lam.lift, iht, ihu]
  | lam t ih => simp [Lam.lift, ih]

/-- Lift-lift commutation -/
theorem Lam.lift_lift (t : Lam) (d₁ d₂ c₁ c₂ : ℕ) (h : c₂ ≤ c₁) :
    Lam.lift d₂ c₂ (Lam.lift d₁ c₁ t) =
    Lam.lift d₁ (c₁ + d₂) (Lam.lift d₂ c₂ t) := by
  induction t generalizing c₁ c₂ with
  | var n =>
    simp only [Lam.lift]
    split_ifs <;> simp only [Lam.lift] <;> split_ifs <;> simp_all [Lam.var.injEq] <;> omega
  | app t u iht ihu =>
    simp only [Lam.lift, Lam.app.injEq]
    exact ⟨iht c₁ c₂ h, ihu c₁ c₂ h⟩
  | lam t ih =>
    simp only [Lam.lift, Lam.lam.injEq]
    convert ih (c₁ + 1) (c₂ + 1) (by omega) using 2; omega

/-
Merging two lifts: when K ≥ c, two lifts at related cutoffs merge into one.
-/
theorem Lam.lift_lift_merge (t : Lam) (j K c c₀ : ℕ) (h : K ≥ c) :
    Lam.lift j (c + c₀) (Lam.lift K c₀ t) = Lam.lift (K + j) c₀ t := by
  have h_ind : ∀ t c₀, lift j (c + c₀) (lift K c₀ t) = lift (K + j) c₀ t := by
    intro t c₀;
    induction' t with t ih generalizing c₀;
    · grind +locals;
    · simp_all +decide [ Lam.lift ];
    · grind +locals;
  exact h_ind t c₀

/-- SubstAt-lift cancellation -/
theorem Lam.substAt_lift_cancel (t σ : Lam) (k : ℕ) :
    Lam.substAt σ k (Lam.lift 1 k t) = t := by
  induction t generalizing k with
  | var n =>
    simp only [Lam.lift]
    by_cases h : n < k
    · simp [Lam.substAt, h]
    · push_neg at h
      have h1 : ¬(n + 1 < k) := by omega
      have h2 : ¬(n + 1 = k) := by omega
      simp [show ¬(n < k) from by omega, Lam.substAt, h1, h2]
  | app t u iht ihu =>
    simp only [Lam.lift, Lam.substAt, Lam.app.injEq]
    exact ⟨iht k, ihu k⟩
  | lam t ih =>
    simp only [Lam.lift, Lam.substAt, Lam.lam.injEq]
    exact ih (k + 1)

/-- Generalized lift-substAt commutation -/
theorem Lam.lift_substAt_comm (σ t : Lam) (d c k : ℕ) (h : k ≤ c) :
    Lam.lift d c (Lam.substAt σ k t) =
    Lam.substAt (Lam.lift d (c - k) σ) k (Lam.lift d (c + 1) t) := by
  induction t generalizing σ d c k with
  | var n =>
    simp only [Lam.substAt]
    split_ifs with h1 h2
    · simp only [Lam.lift, show n < c from by omega, ite_true,
                  show n < c + 1 from by omega, Lam.substAt, h1]
    · subst h2
      simp only [Lam.lift, show n < c + 1 from by omega, ite_true,
                  Lam.substAt, show ¬(n < n) from by omega, ite_false, ite_true]
      have := Lam.lift_lift σ d n (c - n) 0 (Nat.zero_le _)
      rw [Nat.sub_add_cancel h] at this; exact this.symm
    · by_cases h3 : n ≤ c
      · simp only [Lam.lift, show n - 1 < c from by omega, ite_true,
                    show n < c + 1 from by omega,
                    Lam.substAt, show ¬(n < k) from by omega, ite_false,
                    show ¬(n = k) from h2]
      · push_neg at h3
        simp only [Lam.lift, show ¬(n - 1 < c) from by omega, ite_false,
                    show ¬(n < c + 1) from by omega,
                    Lam.substAt, show ¬(n + d < k) from by omega, ite_false,
                    show ¬(n + d = k) from by omega]
        congr 1; omega
  | app t u iht ihu =>
    simp only [Lam.substAt, Lam.lift, Lam.app.injEq]
    exact ⟨iht σ d c k h, ihu σ d c k h⟩
  | lam t ih =>
    simp only [Lam.substAt, Lam.lift, Lam.lam.injEq]
    have := ih σ d (c + 1) (k + 1) (by omega)
    rwa [show c + 1 - (k + 1) = c - k from by omega,
         show c + 1 + 1 = c + 2 from by omega] at this

/-- lift commutes with subst0 -/
theorem Lam.lift_subst0_comm (u t : Lam) (d c : ℕ) :
    Lam.lift d c (Lam.subst0 u t) =
    Lam.subst0 (Lam.lift d c u) (Lam.lift d (c + 1) t) := by
  unfold Lam.subst0
  rw [Lam.lift_substAt_comm u t d c 0 (Nat.zero_le c)]
  simp [Nat.sub_zero]

/-
substAt commutes with lift (dual direction)
-/
theorem Lam.substAt_lift_comm_gen (σ t : Lam) (k j c : ℕ) :
    Lam.substAt σ (k + j + c) (Lam.lift j c t) =
    Lam.lift j c (Lam.substAt σ (k + c) t) := by
  induction t generalizing k c;
  · simp +arith +decide [ Lam.substAt, Lam.lift ];
    split_ifs <;> simp_all +arith +decide [ Lam.substAt, Lam.lift ];
    · grind;
    · omega;
    · nontriviality;
      convert Lam.lift_lift_merge σ j ( k + c ) c 0 ( by linarith ) |> Eq.symm using 1;
      ac_rfl;
    · grind;
  · grind +locals;
  · convert congr_arg _ ( ‹∀ (k c : ℕ), σ.substAt ( k + j + c ) ( lift j c _ ) = lift j c ( σ.substAt ( k + c ) _ ) › k ( c + 1 ) ) using 1

/-- substAt commutes with lift at cutoff 0 -/
theorem Lam.substAt_lift_comm (σ t : Lam) (k j : ℕ) :
    Lam.substAt σ (k + j) (Lam.lift j 0 t) =
    Lam.lift j 0 (Lam.substAt σ k t) := by
  have := Lam.substAt_lift_comm_gen σ t k j 0
  simp at this; exact this

/-
Generalized substitution composition
-/
theorem Lam.substAt_substAt_comm (t σ u : Lam) (k j : ℕ) :
    Lam.substAt σ (k + j) (Lam.substAt u j t) =
    Lam.substAt (Lam.substAt σ k u) j (Lam.substAt σ (k + 1 + j) t) := by
  induction' t with n t u ih_t ih_u generalizing σ u k j <;> simp +arith +decide [ * ];
  · by_cases h1 : n < j <;> by_cases h2 : n = j <;> simp_all +arith +decide [ Lam.substAt ];
    · split_ifs <;> try linarith;
      exact Eq.symm ( by rw [ Lam.substAt ] ; aesop );
    · convert Lam.substAt_lift_comm σ u k j using 1;
    · split_ifs <;> simp_all +arith +decide [ Lam.substAt ];
      · linarith;
      · grind;
      · grind;
      · have h_lift : lift (k + j + 1) 0 σ = lift 1 j (lift (k + j) 0 σ) := by
          rw [ ← lift_lift_merge ] <;> norm_num;
          congr! 1;
          grind;
        rw [ h_lift, Lam.substAt_lift_cancel ];
      · grind;
  · convert congr_arg₂ ( fun x y => x.app y ) ( ih_t σ u k j ) ( ih_u σ u k j ) using 1 ; ring;
    rfl;
  · rename_i t ih;
    convert congr_arg Lam.lam ( ih σ u k ( j + 1 ) ) using 1 ; ring;
    simp +arith +decide [ Lam.substAt ]

/-- Substitution composition: substAt distributes over subst0 -/
theorem Lam.substAt_subst0 (t σ u : Lam) (k : ℕ) :
    Lam.substAt σ k (Lam.subst0 u t) =
    Lam.subst0 (Lam.substAt σ k u) (Lam.substAt σ (k + 1) t) := by
  unfold Lam.subst0
  have := Lam.substAt_substAt_comm t σ u k 0
  simp at this; exact this

/-- I is a normal form -/
theorem Lam.I_normal : NormalForm Lam.I := by
  intro u h; unfold Lam.I at h; cases h with | lam_body h => cases h

/-- K is a normal form -/
theorem Lam.K_normal : NormalForm Lam.K := by
  intro u h; unfold Lam.K at h
  cases h with | lam_body h => cases h with | lam_body h => cases h

/-- Ω reduces to itself -/
theorem Lam.omega_self_reduces : Beta Lam.omega Lam.omega := by
  unfold Lam.omega
  convert Beta.redex (.app (.var 0) (.var 0)) (.lam (.app (.var 0) (.var 0))) using 1

/-- Ω is not a normal form -/
theorem Lam.omega_not_normal : ¬ NormalForm Lam.omega := by
  intro h; exact h _ Lam.omega_self_reduces

end LambdaCalculus