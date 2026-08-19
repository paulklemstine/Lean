import Algebra.ScanSchemeDecoding.Rigidity

/-!
# The `ε`-compression barrier for scan indices

The exact pigeonhole optimum of `Algebra.ScanSchemeDecoding.Triangle` is stated with the
*floor* `⌊N/m⌋`.  Here we sharpen it to a statement with genuine (real) division, which
is the form in which a space/time trade-off is usually quoted:

  `N * (N + m) ≤ 2 * m * triangleOpt N m`  (`triangleOpt_mul_ge`, an exact `ℕ` statement),

and deduce the analytic corollaries

* `mean_decodeCost_ge` — the mean decoding cost of any scan scheme is at least
  `(N/m + 1)/2`;
* `mean_decodeCost_ge_inv_two_mul` — the **`ε`-compression barrier**: a scheme whose
  index uses only `m ≤ ε · N` buckets has mean decoding cost at least `1/(2ε)`.

Both are sharp: for `m ∣ N` the residue scheme of `Algebra.ScanSchemeDecoding.Optimum`
meets the first bound with equality (`mean_decodeCost_modScheme_eq` for `m ∣ N`).
-/

namespace ScanSchemeDecoding

open Finset

/-- Exact, division-free form of the averaged optimum. -/
theorem triangleOpt_mul_ge {m : ℕ} (hm : 0 < m) (N : ℕ) :
    N * (N + m) ≤ 2 * m * triangleOpt N m := by
  rw [triangleOpt_eq hm]
  have hN := Nat.div_add_mod N m
  have hr : N % m < m := Nat.mod_lt _ hm
  have h2 := two_mul_triangle (N / m)
  set q := N / m with hqdef
  set r := N % m with hrdef
  set T := triangle q with hTdef
  clear_value T
  clear_value q r
  subst hN
  obtain ⟨s, hs⟩ : ∃ s, m = s + r := ⟨m - r, by omega⟩
  subst hs
  have hexp : 2 * (s + r) * ((s + r) * T + r * (q + 1))
      = (s + r) * ((s + r) * (2 * T)) + 2 * (s + r) * r * (q + 1) := by ring
  rw [hexp, h2]
  nlinarith [Nat.zero_le (r * s), Nat.zero_le q, Nat.zero_le r, Nat.zero_le s]

namespace ScanScheme

variable {α β : Type*} [Fintype α] [LinearOrder α] [Fintype β] [DecidableEq β]
variable (S : ScanScheme α β)

/-- Division-free averaged bound for an arbitrary scan scheme. -/
theorem card_mul_ge (hβ : 0 < Fintype.card β) :
    Fintype.card α * (Fintype.card α + Fintype.card β)
      ≤ 2 * Fintype.card β * ∑ x, S.decodeCost x :=
  le_trans (triangleOpt_mul_ge hβ (Fintype.card α))
    (Nat.mul_le_mul_left _ (S.triangleOpt_le_decodeCost hβ))

/-- **Mean-cost lower bound.**  The average number of comparisons per decoded key is at
least `(N/m + 1)/2`, with *exact* real division. -/
theorem mean_decodeCost_ge (hα : 0 < Fintype.card α) (hβ : 0 < Fintype.card β) :
    ((Fintype.card α : ℝ) / (Fintype.card β : ℝ) + 1) / 2
      ≤ (∑ x, S.decodeCost x : ℝ) / (Fintype.card α : ℝ) := by
  have hNpos : (0 : ℝ) < (Fintype.card α : ℝ) := by exact_mod_cast hα
  have hmpos : (0 : ℝ) < (Fintype.card β : ℝ) := by exact_mod_cast hβ
  have hkey : (Fintype.card α : ℝ) * ((Fintype.card α : ℝ) + (Fintype.card β : ℝ))
      ≤ 2 * (Fintype.card β : ℝ) * ((∑ x, S.decodeCost x : ℕ) : ℝ) := by
    exact_mod_cast S.card_mul_ge hβ
  rw [div_le_div_iff₀ (by norm_num) hNpos, div_add' _ _ _ (ne_of_gt hmpos)]
  rw [div_mul_eq_mul_div, div_le_iff₀ hmpos]
  push_cast at hkey ⊢
  nlinarith [hkey, hNpos, hmpos]

/-- **The `ε`-compression barrier.**  If the index is compressed to `m ≤ ε · N` buckets
then the mean decoding cost is at least `1 / (2ε)`: buying a factor `ε` of space costs a
factor `1/ε` of time, with the exact constant `1/2`. -/
theorem mean_decodeCost_ge_inv_two_mul (eps : ℝ) (heps : 0 < eps)
    (hα : 0 < Fintype.card α) (hβ : 0 < Fintype.card β)
    (hcomp : (Fintype.card β : ℝ) ≤ eps * (Fintype.card α : ℝ)) :
    1 / (2 * eps) ≤ (∑ x, S.decodeCost x : ℝ) / (Fintype.card α : ℝ) := by
  have hNpos : (0 : ℝ) < (Fintype.card α : ℝ) := by exact_mod_cast hα
  have hmpos : (0 : ℝ) < (Fintype.card β : ℝ) := by exact_mod_cast hβ
  refine le_trans ?_ (S.mean_decodeCost_ge hα hβ)
  rw [div_le_div_iff₀ (by positivity) (by norm_num)]
  have hdiv : 1 / eps ≤ (Fintype.card α : ℝ) / (Fintype.card β : ℝ) := by
    rw [div_le_div_iff₀ heps hmpos, one_mul]
    linarith
  have hone : (0 : ℝ) ≤ 1 := by norm_num
  have hstep : 1 / eps ≤ (Fintype.card α : ℝ) / (Fintype.card β : ℝ) + 1 := by linarith
  calc (1 : ℝ) * 2 = 2 * eps * (1 / eps) := by field_simp
    _ ≤ 2 * eps * ((Fintype.card α : ℝ) / (Fintype.card β : ℝ) + 1) := by
        have h2e : (0 : ℝ) < 2 * eps := by linarith
        exact mul_le_mul_of_nonneg_left hstep (le_of_lt h2e)
    _ = ((Fintype.card α : ℝ) / (Fintype.card β : ℝ) + 1) * (2 * eps) := by ring

end ScanScheme

/-- **Sharpness.**  When `m` divides `N` the residue scheme meets the mean-cost bound with
equality, so the constant `1/2` in the barrier cannot be improved. -/
theorem modScheme_mean_eq {N m : ℕ} (hm : 0 < m) (hdvd : m ∣ N) :
    2 * m * (∑ x, (modScheme N hm).decodeCost x) = N * (N + m) := by
  obtain ⟨q, rfl⟩ := hdvd
  rw [modScheme_decodeCost, triangleOpt_eq hm]
  have hmod : m * q % m = 0 := Nat.mul_mod_right m q
  have hdiv : m * q / m = q := Nat.mul_div_cancel_left q hm
  rw [hmod, hdiv]
  have h2 := two_mul_triangle q
  calc 2 * m * (m * triangle q + 0 * (q + 1)) = m * m * (2 * triangle q) := by ring
    _ = m * m * (q * (q + 1)) := by rw [h2]
    _ = m * q * (m * q + m) := by ring

end ScanSchemeDecoding