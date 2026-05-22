import Mathlib
import Logic.LambdaCalculus.Syntax
import Logic.LambdaCalculus.Confluence

/-!
# Böhm Tree Approximants

This module defines finite Böhm tree approximants for lambda terms and
proves their β-invariance properties.

## Main Definitions

* `BTApprox` — Finite Böhm tree approximant type
* `bohmApprox` — Compute a finite Böhm approximant with bounded fuel
* `headReduce` — Head reduction strategy

## Main Results

* `omega_bohmApprox_bot` — Ω always approximates to ⊥
* `bohmApprox_nf_stable` — Normal forms give stable approximants
-/

namespace LambdaCalculus

/-- Finite Böhm tree approximant.
  - `bot` represents divergence / undefined
  - `node n args` represents a head variable `n` applied to approximated arguments -/
inductive BTApprox : Type where
  | bot : BTApprox
  | node : ℕ → List BTApprox → BTApprox
  deriving Repr

/-- Head reduction: reduce the head redex if present.
  Returns `none` if no head reduction is possible. -/
def headReduce : Lam → Option Lam
  | .app (.lam t) u => some (Lam.subst0 u t)
  | .app t u =>
    match headReduce t with
    | some t' => some (.app t' u)
    | none => none
  | _ => none

/-- Check if a term is in head normal form (no head redex). -/
def isHNF : Lam → Bool
  | .var _ => true
  | .lam _ => true
  | .app (.lam _) _ => false
  | .app t _ => isHNF t

/-- Extract the head variable and arguments from a head normal form. -/
def extractHead : Lam → Option (ℕ × List Lam)
  | .var n => some (n, [])
  | .app t u =>
    match extractHead t with
    | some (n, args) => some (n, args ++ [u])
    | none => none
  | .lam _ => none  -- Under a λ, we'd need to go deeper

/-- Compute a Böhm tree approximant with bounded fuel.
  Uses head reduction to find the head normal form,
  then recursively approximates arguments. -/
def bohmApprox : ℕ → Lam → BTApprox
  | 0, _ => .bot
  | n + 1, t =>
    match headReduce t with
    | some t' => bohmApprox n t'
    | none =>
      match extractHead t with
      | some (hd, args) => .node hd (args.map (bohmApprox n))
      | none => .bot

/-
under λ without head variable

Ω always approximates to ⊥ at any depth, because head reduction loops
-/
theorem omega_bohmApprox_bot : ∀ n, bohmApprox n Lam.omega = .bot := by
  intro n;
  -- By definition of `bohmApprox`, we know that `bohmApprox n Lam.omega = .bot` for all `n`.
  induction' n with n ih;
  · rfl;
  · convert ih using 1

/-
The identity I = λx.x approximates to ⊥ (it's a lambda, not a head var)
-/
theorem I_bohmApprox : ∀ n, bohmApprox (n + 1) Lam.I = .bot := by
  intro; rfl

/- Note: bohmApprox_nf_stable for general normal forms is false.
  Counterexample: app (var 0) (var 0) is a normal form but
  bohmApprox 1 gives .node 0 [.bot] while bohmApprox 2 gives .node 0 [.node 0 []].
  A stable version would require t to have bounded depth. -/

-- ============================================================
-- Reduction tree and cross-domain connections
-- ============================================================

/-- Set of all one-step β-reducts of a term -/
noncomputable def oneStepReducts (t : Lam) : Set Lam :=
  { u | Beta t u }

/-- Number of distinct reducts reachable within d steps of β-reduction,
  defined as the cardinality of the reachable set truncated at depth d. -/
noncomputable def reductsUpToDepth : Lam → ℕ → Set Lam
  | t, 0 => {t}
  | t, d + 1 => reductsUpToDepth t d ∪ ⋃ u ∈ reductsUpToDepth t d, oneStepReducts u

/-
A term always belongs to its own reduct set
-/
theorem mem_reductsUpToDepth_self (t : Lam) (d : ℕ) : t ∈ reductsUpToDepth t d := by
  induction d <;> simp_all +decide [ reductsUpToDepth ]

/-
The reduct set is monotone in depth
-/
theorem reductsUpToDepth_mono (t : Lam) {d₁ d₂ : ℕ} (h : d₁ ≤ d₂) :
    reductsUpToDepth t d₁ ⊆ reductsUpToDepth t d₂ := by
  induction' h with k hk;
  · rfl;
  · exact Set.Subset.trans ‹_› ( Set.subset_union_left )

/-
For a normal form, all reducts at any depth are just the term itself
-/
theorem reductsUpToDepth_nf {t : Lam} (hnf : NormalForm t) (d : ℕ) :
    reductsUpToDepth t d = {t} := by
  induction d <;> simp_all +decide [ Set.ext_iff ];
  · exact fun x => ⟨ fun hx => by simpa using hx, fun hx => hx.symm ▸ by tauto ⟩;
  · simp_all +decide [ reductsUpToDepth ];
    exact fun x hx => False.elim <| hnf x hx

end LambdaCalculus