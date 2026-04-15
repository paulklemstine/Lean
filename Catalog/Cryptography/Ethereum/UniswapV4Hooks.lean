/-! # CatalogBuild.Cryptography.Ethereum.UniswapV4Hooks

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 18
-/

import Mathlib

noncomputable section

structure PoolV4 where
  reserveX : ℝ
  reserveY : ℝ
  baseFee : ℝ
  hX : 0 < reserveX
  hY : 0 < reserveY
  hFee0 : 0 ≤ baseFee
  hFee1 : baseFee < 1


noncomputable def PoolV4.invariant (p : PoolV4) : ℝ := p.reserveX * p.reserveY

noncomputable def PoolV4.spotPrice (p : PoolV4) : ℝ := p.reserveY / p.reserveX


structure Hook where
  adjustFee : ℝ → ℝ → ℝ → ℝ
  afterSwapRedistribution : ℝ → ℝ
  fee_nonneg : ∀ bf dx sp, 0 ≤ adjustFee bf dx sp
  fee_lt_one : ∀ bf dx sp, adjustFee bf dx sp < 1
  redist_nonneg : ∀ out, 0 ≤ afterSwapRedistribution out


noncomputable def swapWithHook (p : PoolV4) (h : Hook) (dx : ℝ) : ℝ :=
  let effectiveFee := h.adjustFee p.baseFee dx p.spotPrice
  let effectiveDx := (1 - effectiveFee) * dx
  p.reserveY * effectiveDx / (p.reserveX + effectiveDx)


noncomputable def swapNoHook (p : PoolV4) (dx : ℝ) : ℝ :=
  let effectiveDx := (1 - p.baseFee) * dx
  p.reserveY * effectiveDx / (p.reserveX + effectiveDx)


def identityHook (baseFee : ℝ) (hFee0 : 0 ≤ baseFee) (hFee1 : baseFee < 1) : Hook where
  adjustFee := fun _bf _dx _sp => baseFee
  afterSwapRedistribution := fun _ => 0
  fee_nonneg := fun _ _ _ => hFee0
  fee_lt_one := fun _ _ _ => hFee1
  redist_nonneg := fun _ => le_refl _


theorem identity_hook_preserves_output (p : PoolV4) (dx : ℝ) :
    swapWithHook p (identityHook p.baseFee p.hFee0 p.hFee1) dx = swapNoHook p dx := by
  unfold swapWithHook swapNoHook identityHook; simp


theorem dynamic_fee_bounded (minFee maxFee t : ℝ)
    (hMin : 0 ≤ minFee) (hOrder : minFee ≤ maxFee) (ht0 : 0 ≤ t) (ht1 : t ≤ 1) :
    minFee ≤ minFee + t * (maxFee - minFee) ∧
    minFee + t * (maxFee - minFee) ≤ maxFee := by
  constructor
  · linarith [mul_nonneg ht0 (sub_nonneg.mpr hOrder)]
  · nlinarith [mul_le_of_le_one_left (sub_nonneg.mpr hOrder) ht1]


def composeHooks (h₁ h₂ : Hook) : Hook where
  adjustFee := fun bf dx sp => h₂.adjustFee (h₁.adjustFee bf dx sp) dx sp
  afterSwapRedistribution := fun out =>
    h₁.afterSwapRedistribution out + h₂.afterSwapRedistribution out
  fee_nonneg := fun bf dx sp => h₂.fee_nonneg _ _ _
  fee_lt_one := fun bf dx sp => h₂.fee_lt_one _ _ _
  redist_nonneg := fun out => add_nonneg (h₁.redist_nonneg out) (h₂.redist_nonneg out)


structure TWAMMHook where
  numBlocks : ℕ
  hBlocks : 0 < numBlocks


noncomputable def TWAMMHook.perBlockAmount (tw : TWAMMHook) (totalDx : ℝ) : ℝ :=
  totalDx / tw.numBlocks


theorem twamm_reduces_per_block (tw : TWAMMHook) (totalDx : ℝ)
    (htotal : 0 < totalDx) (hmulti : 1 < tw.numBlocks) :
    tw.perBlockAmount totalDx < totalDx := by
  unfold TWAMMHook.perBlockAmount
  rw [div_lt_iff₀ (by exact_mod_cast tw.hBlocks : (0:ℝ) < tw.numBlocks)]
  nlinarith [show (1:ℝ) < tw.numBlocks by exact_mod_cast hmulti]


theorem twamm_reduces_price_impact (reserveX dx₁ dx₂ : ℝ)
    (hRX : 0 < reserveX) (h1 : 0 < dx₁) (h2 : 0 < dx₂) (hle : dx₁ ≤ dx₂) :
    dx₁ / (reserveX + dx₁) ≤ dx₂ / (reserveX + dx₂) := by
  rw [div_le_div_iff₀ (by linarith) (by linarith)]
  nlinarith


structure HookPermissions where
  allowSwap : Bool
  allowAddLiquidity : Bool
  allowRemoveLiquidity : Bool


def permissionedSwapAllowed (perms : HookPermissions) : Prop :=
  perms.allowSwap = true


theorem no_swap_no_extraction (perms : HookPermissions)
    (h_blocked : perms.allowSwap = false) :
    ¬ permissionedSwapAllowed perms := by
  simp [permissionedSwapAllowed, h_blocked]


theorem higher_fee_less_output (reserveX reserveY dx fee₁ fee₂ : ℝ)
    (hRX : 0 < reserveX) (hRY : 0 < reserveY) (hdx : 0 < dx)
    (hf1 : 0 ≤ fee₁) (hf2 : 0 ≤ fee₂) (hf1_lt : fee₁ < 1) (hf2_lt : fee₂ < 1)
    (hle : fee₁ ≤ fee₂) :
    reserveY * ((1 - fee₂) * dx) / (reserveX + (1 - fee₂) * dx) ≤
    reserveY * ((1 - fee₁) * dx) / (reserveX + (1 - fee₁) * dx) := by
  field_simp;
  rw [ div_le_div_iff₀ ] <;> nlinarith [ mul_le_mul_of_nonneg_left hle hdx.le ]


end
