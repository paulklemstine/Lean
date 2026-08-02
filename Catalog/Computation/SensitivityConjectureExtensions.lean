import Mathlib

/-!
# Sensitivity conjecture extensions: a signed-cube spectral core

This file isolates the algebraic mechanism in Huang's signed adjacency operator.
The recursively signed operator has square exactly `n • I`; consequently every
nonzero real eigenvector has eigenvalue of squared magnitude `n`. The final
result packages the usual spectral-to-sensitivity numerical step.

A deliberately stronger conjecture—asserting that every choice of edge signs
has the same square—is disproved by the unsigned square. Thus cancellation of
length-two walks depends essentially on the signing.
-/

namespace SensitivityExtensions

/-- Vertices of the recursively presented `n`-dimensional Boolean cube. -/
inductive Cube : Nat → Type
  | unit : Cube 0
  | cons : Bool → Cube n → Cube (n + 1)
  deriving DecidableEq

/-- Huang's recursively signed adjacency operator on the Boolean cube.
At a new `false` layer it is `Aₙ v₀ + v₁`; at the `true` layer it is
`v₀ - Aₙ v₁`. The opposite signs make the two length-two cross terms cancel. -/
def signedAdj : (n : Nat) → (Cube n → ℝ) → Cube n → ℝ
  | 0, _, Cube.unit => 0
  | n + 1, v, Cube.cons false x =>
      signedAdj n (fun y => v (Cube.cons false y)) x + v (Cube.cons true x)
  | n + 1, v, Cube.cons true x =>
      v (Cube.cons false x) - signedAdj n (fun y => v (Cube.cons true y)) x

/-- The canonical signed adjacency operator is a square root of `n` times the
identity. This is the exact cancellation identity behind the spectral method. -/
theorem signedAdj_sq (n : Nat) (v : Cube n → ℝ) :
    signedAdj n (signedAdj n v) = fun x => (n : ℝ) * v x := by
  have signedAdj_add : ∀ (n : Nat) (v w : Cube n → ℝ),
      signedAdj n (v + w) = signedAdj n v + signedAdj n w := by
    intro n
    induction n with
    | zero =>
      intro v w
      funext x
      cases x
      simp [signedAdj]
    | succ n ih =>
      intro v w
      funext x
      cases x with
      | cons b x =>
        cases b with
        | false =>
          simp only [signedAdj, Pi.add_apply]
          have : (fun y => v (Cube.cons false y) + w (Cube.cons false y)) =
                 (fun y => v (Cube.cons false y)) + (fun y => w (Cube.cons false y)) := rfl
          rw [this, ih]; simp [Pi.add_apply]; ring
        | true =>
          simp only [signedAdj, Pi.add_apply]
          have : (fun y => v (Cube.cons true y) + w (Cube.cons true y)) =
                 (fun y => v (Cube.cons true y)) + (fun y => w (Cube.cons true y)) := rfl
          rw [this, ih]; simp [Pi.add_apply]; ring
  induction n with
  | zero =>
    funext x
    cases x
    simp [signedAdj]
  | succ n ih =>
    funext x
    match x with
    | Cube.cons false x =>
      simp [signedAdj]
      have h1 := ih (fun y => v (Cube.cons false y))
      have heq : (fun y => signedAdj n (fun y => v (Cube.cons false y)) y + v (Cube.cons true y)) =
                 (fun y => signedAdj n (fun y => v (Cube.cons false y)) y) + fun y => v (Cube.cons true y) := rfl
      have h2 := signedAdj_add n (fun y => signedAdj n (fun y => v (Cube.cons false y)) y)
                                   (fun y => v (Cube.cons true y))
      rw [heq, h2]
      simp [h1]
      ring
    | Cube.cons true x =>
      simp [signedAdj]
      have h1 := ih (fun y => v (Cube.cons true y))
      -- First, show that signedAdj n (fun y => f y - g y) = signedAdj n f - signedAdj n g
      have signedAdj_zero : ∀ (n : Nat), signedAdj n (0 : Cube n → ℝ) = 0 := by
        intro n
        induction n with
        | zero => funext x; cases x; rfl
        | succ n ih =>
          funext x
          match x with
          | Cube.cons b x =>
            cases b with
            | false => simp [signedAdj]; exact congrFun ih x
            | true => simp [signedAdj]; exact congrFun ih x
      have signedAdj_neg : ∀ (n : Nat) (v : Cube n → ℝ), signedAdj n (-v) = -signedAdj n v := by
        intro n v
        have add_eq := signedAdj_add n v (-v)
        have eq_zero : v + -v = (0 : Cube n → ℝ) := by ext; simp
        rw [eq_zero, signedAdj_zero] at add_eq
        -- add_eq : 0 = signedAdj n v + signedAdj n (-v)
        have add_eq' : signedAdj n (-v) + signedAdj n v = 0 := by rw [add_comm]; exact add_eq.symm
        calc signedAdj n (-v) = signedAdj n (-v) + signedAdj n v - signedAdj n v := by ring
          _ = 0 - signedAdj n v := by rw [add_eq']
          _ = -signedAdj n v := by ring
      have signedAdj_sub : ∀ (n : Nat) (v w : Cube n → ℝ),
          signedAdj n (v - w) = signedAdj n v - signedAdj n w := by
        intro n v w
        simp [sub_eq_add_neg, signedAdj_add, signedAdj_neg]
      have heq : (fun y => v (Cube.cons false y) - signedAdj n (fun y => v (Cube.cons true y)) y) =
                 (fun y => v (Cube.cons false y)) - (fun y => signedAdj n (fun y => v (Cube.cons true y)) y) := rfl
      rw [heq, signedAdj_sub]
      have heq2 : (fun y => signedAdj n (fun y => v (Cube.cons true y)) y) = signedAdj n (fun y => v (Cube.cons true y)) := rfl
      rw [heq2, h1]; simp; ring

/-- Spectral rigidity: every eigenvalue admitting a nonzero eigenvector for the
canonical signed cube has square exactly the dimension. -/
theorem eigenvalue_sq_eq_dimension {n : Nat} {v : Cube n → ℝ} {lam : ℝ}
    (heigen : signedAdj n v = fun x => lam * v x)
    (hnonzero : ∃ x, v x ≠ 0) :
    lam ^ 2 = n := by
  have signedAdj_smul : ∀ (n : Nat) (c : ℝ) (w : Cube n → ℝ),
      signedAdj n (fun x => c * w x) = fun x => c * signedAdj n w x := by
    intro n
    induction n with
    | zero =>
      intro c w
      funext x
      cases x
      simp [signedAdj]
    | succ n ih =>
      intro c w
      funext x
      match x with
      | Cube.cons false x =>
        simp [signedAdj]
        have := ih c (fun y => w (Cube.cons false y))
        simp_all [mul_add]
      | Cube.cons true x =>
        simp [signedAdj]
        have := ih c (fun y => w (Cube.cons true y))
        simp_all [mul_sub]
  have hsq := signedAdj_sq n v
  rw [heigen] at hsq
  have hsq' := signedAdj_smul n lam v
  rw [hsq'] at hsq
  have ⟨x, hx⟩ := hnonzero
  have := congr_fun hsq x
  rw [heigen] at this
  simp at this
  exact mul_left_cancel₀ hx (by ring_nf at this ⊢; exact this)

/-- Numerical spectral-to-sensitivity step. Any upper bound `s` on the
magnitude of a certified eigenvalue forces `n ≤ s²`. -/
theorem dimension_le_sensitivity_sq {n s : Nat} {v : Cube n → ℝ} {lam : ℝ}
    (heigen : signedAdj n v = fun x => lam * v x)
    (hnonzero : ∃ x, v x ≠ 0)
    (hbound : |lam| ≤ s) :
    n ≤ s ^ 2 := by
  have h := eigenvalue_sq_eq_dimension heigen hnonzero
  have hle : lam ^ 2 ≤ s ^ 2 := by nlinarith [abs_le.mp hbound]
  rw [h] at hle
  exact_mod_cast hle

/-- The ordinary unsigned recursive adjacency operator. It differs from
`signedAdj` only by replacing the crucial minus sign with a plus sign. -/
def unsignedAdj : (n : Nat) → (Cube n → ℝ) → Cube n → ℝ
  | 0, _, Cube.unit => 0
  | n + 1, v, Cube.cons false x =>
      unsignedAdj n (fun y => v (Cube.cons false y)) x + v (Cube.cons true x)
  | n + 1, v, Cube.cons true x =>
      v (Cube.cons false x) + unsignedAdj n (fun y => v (Cube.cons true y)) x

/-- **Disproof of a bold extension.** It is false that arbitrary cube signings
(or even the all-positive signing) square to the dimension times identity.
The unsigned two-cube has non-cancelling two-step walks to the opposite vertex. -/
theorem not_every_signing_has_scalar_square :
    ¬ (∀ v : Cube 2 → ℝ,
      unsignedAdj 2 (unsignedAdj 2 v) = fun x => (2 : ℝ) * v x) := by
  push_neg
  use fun _ => 1
  intro h
  have := congr_fun h (Cube.cons false (Cube.cons false Cube.unit))
  simp only [unsignedAdj] at this
  norm_num at this

end SensitivityExtensions