import Mathlib

/-!
# Negligible Function Closure Properties

Standalone file proving that negligible functions are closed under addition,
constant multiplication, and finite sums.
-/

noncomputable section

open Finset BigOperators Classical

namespace TropicalHVR

/-- A function ε : ℕ → ℝ is negligible if for all polynomial degrees k,
    eventually ε(n) ≤ 1/n^k. -/
def negligible' (ε : ℕ → ℝ) : Prop :=
  ∀ k : ℕ, ∃ N, ∀ n, N ≤ n → |ε n| ≤ 1 / (n : ℝ) ^ k

/-- Zero function is negligible. -/
theorem negligible'_zero : negligible' (fun _ => 0) := by
  intro k; exact ⟨1, fun n _ => by simp⟩

/-
**Sum of two negligible functions is negligible.**
-/
theorem negligible'_add {f g : ℕ → ℝ}
    (hf : negligible' f) (hg : negligible' g) :
    negligible' (fun n => f n + g n) := by
  intro k;
  -- Given k, we need |f n + g n| ≤ 1/n^k for large enough n. Get N₁ from hf (k+1) and N₂ from hg (k+1).
  obtain ⟨N₁, hN₁⟩ := hf (k + 1)
  obtain ⟨N₂, hN₂⟩ := hg (k + 1)

  use max 2 (max N₁ N₂);
  intro n hn; specialize hN₁ n ( by aesop ) ; specialize hN₂ n ( by aesop ) ; norm_num [ pow_add ] at *;
  exact abs_le.mpr ⟨ by nlinarith [ abs_le.mp hN₁, abs_le.mp hN₂, show ( n : ℝ ) ≥ 2 by norm_cast; linarith, inv_mul_cancel₀ ( show ( n : ℝ ) ≠ 0 by norm_cast; linarith ), inv_nonneg.mpr ( show ( 0 : ℝ ) ≤ n ^ k by positivity ) ], by nlinarith [ abs_le.mp hN₁, abs_le.mp hN₂, show ( n : ℝ ) ≥ 2 by norm_cast; linarith, inv_mul_cancel₀ ( show ( n : ℝ ) ≠ 0 by norm_cast; linarith ), inv_nonneg.mpr ( show ( 0 : ℝ ) ≤ n ^ k by positivity ) ] ⟩

/-
**Constant multiple of a negligible function is negligible.**
-/
theorem negligible'_const_mul (c : ℝ) {f : ℕ → ℝ}
    (hf : negligible' f) :
    negligible' (fun n => c * f n) := by
  intro k
  by_cases hc : c = 0
  ·
    exact ⟨ 1, fun n hn => by norm_num [ hc ] ⟩
  ·
    rcases hf ( k + ⌈|c|⌉₊ + 1 ) with ⟨ N, hN ⟩;
    refine' ⟨ N + ⌈|c|⌉₊ + 1, fun n hn => _ ⟩ ; rw [ abs_mul ] ; specialize hN n ( by linarith ) ; simp_all +decide [ pow_add ];
    refine le_trans ( mul_le_mul_of_nonneg_left hN <| abs_nonneg _ ) ?_;
    field_simp;
    rw [ div_le_div_iff₀ ] <;> norm_cast <;> norm_num;
    · exact mul_le_mul_of_nonneg_right ( by nlinarith [ Nat.le_ceil ( |c| ), show ( n : ℝ ) ≥ ⌈|c|⌉₊ + 1 by norm_cast; linarith, pow_le_pow_right₀ ( show ( n : ℝ ) ≥ 1 by norm_cast; linarith ) ( show ⌈|c|⌉₊ ≥ 0 by positivity ) ] ) ( by positivity );
    · exact ⟨ ⟨ by linarith, pow_pos ( by linarith ) _ ⟩, pow_pos ( by linarith ) _ ⟩;
    · exact pow_pos ( by linarith ) _

/-
**Finite sum of negligible functions is negligible.**
-/
theorem negligible'_sum_finset {m : ℕ} {f : ℕ → ℕ → ℝ}
    (hf : ∀ i ∈ Finset.range m, negligible' (f i)) :
    negligible' (fun n => ∑ i ∈ Finset.range m, f i n) := by
  induction' m with m ih <;> simp_all +decide [ Finset.sum_range_succ ];
  · exact?;
  · convert TropicalHVR.negligible'_add ( ih fun i hi => hf i hi.le ) ( hf m le_rfl ) using 1

end TropicalHVR

end