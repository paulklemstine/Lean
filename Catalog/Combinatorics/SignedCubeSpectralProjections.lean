import Computation.SensitivityConjectureExtensions

/-!
# Spectral projections for Huang's signed cube operator

This file advances the signed-cube spectral core by constructing the two
spectral projections algebraically.  For any nonzero `r` with `r² = n`, every
function on the cube splits into an `r`-eigenfunction and a `-r`-eigenfunction.
The two projection operators are complementary and orthogonal (their
composites vanish).
-/

namespace SensitivityExtensions

/-- The canonical signed adjacency operator is additive. -/
theorem signedAdj_add (n : Nat) (v w : Cube n → ℝ) :
    signedAdj n (v + w) = signedAdj n v + signedAdj n w := by
  induction n with
  | zero =>
    funext x
    cases x
    simp [signedAdj]
  | succ n ih =>
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

/-- The canonical signed adjacency operator commutes with real scalar multiplication. -/
theorem signedAdj_smul (n : Nat) (c : ℝ) (v : Cube n → ℝ) :
    signedAdj n (fun x => c * v x) = fun x => c * signedAdj n v x := by
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
      have := ih (fun y => v (Cube.cons false y))
      simp_all [mul_add]
    | Cube.cons true x =>
      simp [signedAdj]
      have := ih (fun y => v (Cube.cons true y))
      simp_all [mul_sub]

/-- Projection onto the `r`-eigenspace, provided `r²` is the cube dimension. -/
noncomputable def positiveSpectralPart (n : Nat) (r : ℝ) (v : Cube n → ℝ) : Cube n → ℝ :=
  fun x => (v x + r⁻¹ * signedAdj n v x) / 2

/-- Projection onto the `-r`-eigenspace, provided `r²` is the cube dimension. -/
noncomputable def negativeSpectralPart (n : Nat) (r : ℝ) (v : Cube n → ℝ) : Cube n → ℝ :=
  fun x => (v x - r⁻¹ * signedAdj n v x) / 2

/-- The positive and negative spectral parts reconstruct the original function. -/
theorem positive_add_negative (n : Nat) (r : ℝ) (v : Cube n → ℝ) :
    positiveSpectralPart n r v + negativeSpectralPart n r v = v := by
  funext x
  simp [positiveSpectralPart, negativeSpectralPart]
  ring

/-- The positive spectral part is an `r`-eigenfunction. -/
theorem signedAdj_positiveSpectralPart {n : Nat} {r : ℝ}
    (hr : r ^ 2 = n) (hr0 : r ≠ 0) (v : Cube n → ℝ) :
    signedAdj n (positiveSpectralPart n r v) =
      fun x => r * positiveSpectralPart n r v x := by
  have hsq := signedAdj_sq n v
  unfold positiveSpectralPart
  -- (v x + r⁻¹ * signedAdj n v x) / 2 = (1/2) * (v + r⁻¹ * signedAdj n v)
  have h1 : (fun x => (v x + r⁻¹ * signedAdj n v x) / 2) = (fun x => (1/2 : ℝ) * (v x + r⁻¹ * signedAdj n v x)) := by
    funext x; ring
  rw [h1]
  rw [signedAdj_smul]
  -- Now work on signedAdj n (fun x => v x + r⁻¹ * signedAdj n v x)
  have heq : (fun x => v x + r⁻¹ * signedAdj n v x) = v + (fun x => r⁻¹ * signedAdj n v x) := rfl
  rw [heq]
  rw [signedAdj_add]
  -- signedAdj n (fun x => r⁻¹ * signedAdj n v x) = r⁻¹ * signedAdj n (signedAdj n v)
  have h2 : (fun x => r⁻¹ * signedAdj n v x) = r⁻¹ • (signedAdj n v) := rfl
  rw [h2]
  have hsmul : signedAdj n (r⁻¹ • signedAdj n v) = r⁻¹ • signedAdj n (signedAdj n v) := by
    simpa using signedAdj_smul n r⁻¹ (signedAdj n v)
  rw [hsmul]
  rw [hsq]
  -- Now r⁻¹ • (fun x => n * v x) = fun x => r⁻¹ * n * v x
  -- Since r² = n, r⁻¹ * n = r
  funext x
  simp [Pi.smul_apply]
  have hn : (n : ℝ) = r ^ 2 := hr.symm
  field_simp [hr0]
  rw [hn]
  ring_nf

/-- The negative spectral part is a `-r`-eigenfunction. -/
theorem signedAdj_negativeSpectralPart {n : Nat} {r : ℝ}
    (hr : r ^ 2 = n) (hr0 : r ≠ 0) (v : Cube n → ℝ) :
    signedAdj n (negativeSpectralPart n r v) =
      fun x => (-r) * negativeSpectralPart n r v x := by
  unfold negativeSpectralPart
  have h1 : (fun x => (v x - r⁻¹ * signedAdj n v x) / 2) = fun x => (2 : ℝ)⁻¹ * (v x - r⁻¹ * signedAdj n v x) := by
    ext x; ring
  rw [h1]
  rw [signedAdj_smul]
  have h2 : (fun x => v x - r⁻¹ * signedAdj n v x) = v + -(fun x => r⁻¹ * signedAdj n v x) := rfl
  rw [h2]
  rw [signedAdj_add]
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
  have signedAdj_neg : ∀ (n : Nat) (w : Cube n → ℝ), signedAdj n (-w) = -signedAdj n w := by
    intro n w
    have add_eq := signedAdj_add n w (-w)
    have eq_zero : w + -w = (0 : Cube n → ℝ) := by ext; simp
    rw [eq_zero, signedAdj_zero] at add_eq
    have add_eq' : signedAdj n (-w) + signedAdj n w = 0 := by rw [add_comm]; exact add_eq.symm
    calc signedAdj n (-w) = signedAdj n (-w) + signedAdj n w - signedAdj n w := by ring
      _ = 0 - signedAdj n w := by rw [add_eq']
      _ = -signedAdj n w := by ring
  rw [signedAdj_neg]
  rw [signedAdj_smul]
  rw [signedAdj_sq]
  have hrinv : r⁻¹ * (n : ℝ) = r := by field_simp; linarith [hr]
  have hrinv2 : ∀ x, r⁻¹ * ((n : ℝ) * v x) = r * v x := fun x => by rw [← mul_assoc, hrinv]
  ext x
  simp only [Pi.add_apply, Pi.neg_apply]
  rw [hrinv2 x]
  field_simp
  ring

/-- Applying the positive projection twice has no further effect. -/
theorem positiveSpectralPart_idempotent {n : Nat} {r : ℝ}
    (hr : r ^ 2 = n) (hr0 : r ≠ 0) (v : Cube n → ℝ) :
    positiveSpectralPart n r (positiveSpectralPart n r v) =
      positiveSpectralPart n r v := by
  have he := signedAdj_positiveSpectralPart hr hr0 v
  funext x
  have hx := congrFun he x
  simp only [positiveSpectralPart] at hx ⊢
  rw [hx]
  field_simp [hr0]
  ring

/-- Applying the negative projection twice has no further effect. -/
theorem negativeSpectralPart_idempotent {n : Nat} {r : ℝ}
    (hr : r ^ 2 = n) (hr0 : r ≠ 0) (v : Cube n → ℝ) :
    negativeSpectralPart n r (negativeSpectralPart n r v) =
      negativeSpectralPart n r v := by
  have he := signedAdj_negativeSpectralPart hr hr0 v
  funext x
  have hx := congrFun he x
  simp only [negativeSpectralPart] at hx ⊢
  rw [hx]
  field_simp [hr0]
  ring

/-- The positive projection annihilates the negative spectral part. -/
theorem positiveSpectralPart_negative_eq_zero {n : Nat} {r : ℝ}
    (hr : r ^ 2 = n) (hr0 : r ≠ 0) (v : Cube n → ℝ) :
    positiveSpectralPart n r (negativeSpectralPart n r v) = 0 := by
  have he := signedAdj_negativeSpectralPart hr hr0 v
  funext x
  have hx := congrFun he x
  simp only [positiveSpectralPart, negativeSpectralPart] at hx ⊢
  rw [hx]
  field_simp [hr0]
  simp

/-- The negative projection annihilates the positive spectral part. -/
theorem negativeSpectralPart_positive_eq_zero {n : Nat} {r : ℝ}
    (hr : r ^ 2 = n) (hr0 : r ≠ 0) (v : Cube n → ℝ) :
    negativeSpectralPart n r (positiveSpectralPart n r v) = 0 := by
  have he := signedAdj_positiveSpectralPart hr hr0 v
  funext x
  have hx := congrFun he x
  simp only [negativeSpectralPart, positiveSpectralPart] at hx ⊢
  rw [hx]
  field_simp [hr0]
  simp

end SensitivityExtensions