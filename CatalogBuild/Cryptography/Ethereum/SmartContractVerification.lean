/-! # CatalogBuild.Cryptography.Ethereum.SmartContractVerification

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13
-/

import Mathlib

/-- [Section: # CatalogBuild.Cryptography.Ethereum.SmartContractVerification
Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 13] -/
theorem reentrancy_guard_sound (postLocked : Bool)
    (h_guarded : postLocked = false)
    (h_reenter : postLocked = true) : False := by
  rw [h_guarded] at h_reenter; exact Bool.false_ne_true h_reenter



def Invariant (S : Type) := S → Prop



def preservesInvariant {S : Type} (inv : Invariant S) (op : S → S) : Prop :=
  ∀ s, inv s → inv (op s)



theorem sequential_preserves {S : Type} (inv : Invariant S)
    (op₁ op₂ : S → S)
    (h₁ : preservesInvariant inv op₁)
    (h₂ : preservesInvariant inv op₂) :
    preservesInvariant inv (op₂ ∘ op₁) :=
  fun s hs => h₂ _ (h₁ _ hs)



theorem id_preserves {S : Type} (inv : Invariant S) : preservesInvariant inv id :=
  fun _ hs => hs



theorem tighter_slippage_less_mev (output min₁ min₂ : ℝ)
    (hle : min₁ ≤ min₂) :
    output - min₂ ≤ output - min₁ := by linarith



def hasPermission (roles : ℕ → Finset ℕ) (requiredRole addr : ℕ) : Prop :=
  requiredRole ∈ roles addr



theorem access_control_blocks (roles : ℕ → Finset ℕ) (requiredRole addr : ℕ)
    (h_no_role : requiredRole ∉ roles addr) :
    ¬ hasPermission roles requiredRole addr := h_no_role



structure SwapSpec where
  reserveX : ℝ
  reserveY : ℝ
  inputDx : ℝ
  outputDy : ℝ
  hRX : 0 < reserveX
  hRY : 0 < reserveY
  hDx : 0 < inputDx
  hFormula : outputDy = reserveY * inputDx / (reserveX + inputDx)



theorem swap_spec_correct (spec : SwapSpec) :
    spec.outputDy = spec.reserveY * spec.inputDx / (spec.reserveX + spec.inputDx) :=
  spec.hFormula



/-- The constant product invariant is preserved after a swap -/
theorem swap_spec_preserves_invariant (spec : SwapSpec) :
    (spec.reserveX + spec.inputDx) *
    (spec.reserveY - spec.outputDy) = spec.reserveX * spec.reserveY := by
  rw [spec.hFormula]
  have h_pos : (0:ℝ) ≠ spec.reserveX + spec.inputDx := by linarith [spec.hRX, spec.hDx]
  field_simp
  ring



/-- Output is always positive -/
theorem swap_spec_output_pos (spec : SwapSpec) :
    0 < spec.outputDy := by
  rw [spec.hFormula]
  apply div_pos (mul_pos spec.hRY spec.hDx)
  linarith [spec.hRX, spec.hDx]



theorem swap_spec_output_bounded (spec : SwapSpec) :
    spec.outputDy < spec.reserveY := by
  rw [spec.hFormula]
  rw [ div_lt_iff₀ ] <;> nlinarith [ spec.hRX, spec.hRY, spec.hDx ]


