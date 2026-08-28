import Mathlib
import Novelty.KVCliffExponent

/-!
# Splitting the cache budget by role: depth amplification and the optimal bit split

Cycle 3 of the NET-93 thread.  `Novelty.KeysOwnTheCliff` and
`Novelty.KVCliffExponent` establish the *per-layer* asymmetry: value error is
`1`-Lipschitz, key error is amplified by the query norm and then exponentiated.
Two consequences remain to be proved.

**Depth.**  The key path is the recursion the NET-83 note calls "amplifying":
each layer multiplies the perturbation by a factor `γ > 1`.  The value path is
an averaging recursion, which is non-expansive.  Sections 1–2 prove that these
two recursions have qualitatively different fates: `key_error_unbounded_in_depth`
(the key error passes every threshold at some depth) versus
`value_error_stays_le` (the value error never leaves its initial band).

**Budget.**  Section 3 studies the deployment question directly.  With the
first-order damage model `damage A bK bV = A/2^bK + 1/2^bV` — key damage carries
the amplification factor `A`, value damage does not —

* `shift_bit_to_keys` — moving one bit from the values to the keys *strictly*
  reduces damage whenever `2^bK < A · 2^bV`;
* `shift_bit_to_values_not_better` — and not otherwise, so the inequality
  `2^bK < A · 2^bV` characterises the equilibrium;
* `k8v4_optimal` — at the measured asymmetry scale `A = 16` and a 12-bit budget
  the unique optimum is **K8/V4**, the arm NET-93 nominates as the immediate
  follow-up.  In particular `k8v4_beats_symmetric`: K8/V4 strictly beats the
  equal split K6/V6 at the same average of 6 bits per element.

All of Section 3 is exact rational arithmetic — no floating point, no rounding.
-/

namespace Catalog.Novelty.KVBitBudgetSplit

open Catalog.Novelty.KeysOwnTheCliff

/-! ### 1. The key path: geometric amplification through depth -/

/-- If every layer multiplies the key-side perturbation by at least `γ ≥ 1`,
then after `L` layers the perturbation is at least `γ^L` times the input one. -/
theorem key_error_geometric (e : ℕ → ℝ) (gamma : ℝ) (hgamma : 1 ≤ gamma)
    (hstep : ∀ l, gamma * e l ≤ e (l + 1)) (L : ℕ) : gamma ^ L * e 0 ≤ e L := by
  induction L with
  | zero => simp
  | succ L ih =>
      have hgpos : 0 < gamma := lt_of_lt_of_le zero_lt_one hgamma
      have h1 : gamma * (gamma ^ L * e 0) ≤ gamma * e L :=
        mul_le_mul_of_nonneg_left ih hgpos.le
      calc gamma ^ (L + 1) * e 0 = gamma * (gamma ^ L * e 0) := by ring
        _ ≤ gamma * e L := h1
        _ ≤ e (L + 1) := hstep L

/-- **The key path has no depth-uniform bound.**  A strictly amplifying key
recursion (`γ > 1`) with a nonzero initial perturbation exceeds every threshold
at some finite depth.  This is why an error that is invisible in a single head
annihilates a 24-layer model. -/
theorem key_error_unbounded_in_depth (e : ℕ → ℝ) (gamma : ℝ) (hgamma : 1 < gamma)
    (he0 : 0 < e 0) (hstep : ∀ l, gamma * e l ≤ e (l + 1)) (M : ℝ) : ∃ L, M ≤ e L := by
  obtain ⟨L, hL⟩ := pow_unbounded_of_one_lt (M / e 0) hgamma
  refine ⟨L, le_trans ?_ (key_error_geometric e gamma hgamma.le hstep L)⟩
  rw [div_lt_iff₀ he0] at hL
  linarith

/-! ### 2. The value path: an averaging recursion never leaves its band -/

/-- **The value path is confined.**  If each layer re-averages the value-side
perturbation — `e (l+1) ≤ max ε (e l)`, the shape forced by
`attn_value_perturbation_le` — then the perturbation never exceeds `ε`, at any
depth.  Value error is local and non-compounding. -/
theorem value_error_stays_le (e : ℕ → ℝ) (eps : ℝ) (he0 : e 0 ≤ eps)
    (hstep : ∀ l, e (l + 1) ≤ max eps (e l)) (L : ℕ) : e L ≤ eps := by
  induction L with
  | zero => exact he0
  | succ L ih => exact le_trans (hstep L) (max_le le_rfl ih)

/-- The two recursions really do separate: with `γ > 1` the key error eventually
exceeds the value error by any prescribed factor. -/
theorem key_beats_value_at_depth (eK eV : ℕ → ℝ) (gamma eps : ℝ) (hgamma : 1 < gamma)
    (he0 : 0 < eK 0) (hstepK : ∀ l, gamma * eK l ≤ eK (l + 1))
    (hV0 : eV 0 ≤ eps) (hstepV : ∀ l, eV (l + 1) ≤ max eps (eV l)) (M : ℝ) :
    ∃ L, M * eps < eK L ∧ eV L ≤ eps := by
  obtain ⟨L, hL⟩ := key_error_unbounded_in_depth eK gamma hgamma he0 hstepK (M * eps + 1)
  exact ⟨L, by linarith, value_error_stays_le eV eps hV0 hstepV L⟩

/-! ### 3. The bit budget: keys deserve the bits -/

/-- First-order damage model for a `bK`-bit key cache and a `bV`-bit value
cache: the key term carries the amplification factor `A`, the value term does
not.  Exact rational arithmetic. -/
def damage (A : ℚ) (bK bV : ℕ) : ℚ := A / 2 ^ bK + 1 / 2 ^ bV

/-- **Move a bit to the keys.**  At a fixed total budget, transferring one bit
from the value cache to the key cache strictly reduces the damage as long as
`2^bK < A · 2^bV`. -/
theorem shift_bit_to_keys (A : ℚ) (bK bV : ℕ) (h : (2 : ℚ) ^ bK < A * 2 ^ bV) :
    damage A (bK + 1) bV < damage A bK (bV + 1) := by
  have hK : (0 : ℚ) < 2 ^ bK := by positivity
  have hV : (0 : ℚ) < 2 ^ bV := by positivity
  have key : damage A bK (bV + 1) - damage A (bK + 1) bV
      = (A * 2 ^ bV - 2 ^ bK) / (2 ^ bK * 2 ^ (bV + 1)) := by
    simp only [damage, pow_succ]
    field_simp
    ring
  have hpos : 0 < (A * 2 ^ bV - 2 ^ bK) / (2 ^ bK * 2 ^ (bV + 1)) :=
    div_pos (by linarith) (by positivity)
  linarith [key ▸ hpos]

/-- **Equilibrium.**  Once `A · 2^bV ≤ 2^bK`, moving a further bit to the keys
no longer helps: the two-sided statement pins the optimal split at the point
where the amplified key term balances the value term. -/
theorem shift_bit_to_values_not_better (A : ℚ) (bK bV : ℕ) (h : A * 2 ^ bV ≤ (2 : ℚ) ^ bK) :
    damage A bK (bV + 1) ≤ damage A (bK + 1) bV := by
  have hK : (0 : ℚ) < 2 ^ bK := by positivity
  have hV : (0 : ℚ) < 2 ^ bV := by positivity
  have key : damage A (bK + 1) bV - damage A bK (bV + 1)
      = (2 ^ bK - A * 2 ^ bV) / (2 ^ bK * 2 ^ (bV + 1)) := by
    simp only [damage, pow_succ]
    field_simp
    ring
  have hpos : 0 ≤ (2 ^ bK - A * 2 ^ bV) / (2 ^ bK * 2 ^ (bV + 1)) :=
    div_nonneg (by linarith) (by positivity)
  linarith [key ▸ hpos]

/-- **K8/V4 is the unique optimum of a 12-bit budget at amplification `A = 16`.**
Every other split of the same 12 bits is strictly worse. -/
theorem k8v4_optimal (bK bV : ℕ) (hsum : bK + bV = 12) (hne : bK ≠ 8) :
    damage 16 8 4 < damage 16 bK bV := by
  have hb : bV = 12 - bK := by omega
  have hK : bK ≤ 12 := by omega
  subst hb
  interval_cases bK <;> simp_all [damage] <;> norm_num

/-- The headline deployment comparison: at the same average of 6 bits per cache
element, the role-split allocation K8/V4 strictly beats the uniform K6/V6. -/
theorem k8v4_beats_symmetric : damage 16 8 4 < damage 16 6 6 :=
  k8v4_optimal 6 6 rfl (by norm_num)

/-- And the reversed split — spending the bits on the values — is far worse:
by a factor of more than `8` in guaranteed damage. -/
theorem k4v8_much_worse : 8 * damage 16 8 4 < damage 16 4 8 := by
  norm_num [damage]

end Catalog.Novelty.KVBitBudgetSplit