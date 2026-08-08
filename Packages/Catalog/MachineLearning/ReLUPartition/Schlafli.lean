import Mathlib
import MachineLearning.ReLUWidthDepthTradeoff

/-!
# The Schläfli partition function

The *exact* maximum number of regions into which `n` hyperplanes can cut `ℝ^d`
is the Schläfli number

  `S(n, d) = ∑_{k = 0}^{d} C(n, k)`.

This file develops the arithmetic of `S`: its Pascal recurrence, its saturation
`S(n,d) = 2^n` in the low-hyperplane regime `n ≤ d`, its strict deficiency
`S(n,d) < 2^n` when `d < n`, closed forms in dimensions `1` and `2`, and the
comparison

  `S(n, d) ≤ (n+1)^d = regionCapacity n d`

with the coarse capacity model already present in the catalog
(`MachineLearning/ReLUWidthDepthTradeoff.lean`).  The comparison shows that the
catalog's capacity heuristic is a genuine *upper* bound for the exact count, and
pins down exactly when it is sharp (dimension `≤ 1`, or no hyperplanes at all).

The geometric meaning of `S` — that it bounds the number of activation regions
of a ReLU layer — is proved in `MachineLearning.ReLUPartition.SignVectors`.
-/

open Finset

namespace ReLUPartition

/-- The Schläfli partition function `S(n,d) = ∑_{k ≤ d} C(n,k)`: the exact
maximal number of connected regions cut out of `ℝ^d` by `n` hyperplanes. -/
def schlafli (n d : ℕ) : ℕ := ∑ k ∈ Iic d, n.choose k

@[simp] theorem schlafli_zero_dim (n : ℕ) : schlafli n 0 = 1 := by
  rw [schlafli, show (Iic 0 : Finset ℕ) = {0} from rfl]
  simp

@[simp] theorem schlafli_zero_hyperplanes (d : ℕ) : schlafli 0 d = 1 := by
  classical
  unfold schlafli
  rw [Finset.sum_eq_single 0]
  · simp
  · intro k _ hk
    simp [Nat.choose_eq_zero_of_lt (Nat.pos_of_ne_zero hk)]
  · intro h
    simp at h

theorem schlafli_succ_dim (n d : ℕ) :
    schlafli n (d + 1) = schlafli n d + n.choose (d + 1) := by
  unfold schlafli
  rw [show Iic (d + 1) = insert (d + 1) (Iic d) by
        ext k; simp [Nat.le_succ_iff, or_comm]]
  rw [Finset.sum_insert (by simp)]
  ring

/-- Dimension one: `n` distinct points cut the line into `n+1` pieces. -/
@[simp] theorem schlafli_one_dim (n : ℕ) : schlafli n 1 = n + 1 := by
  rw [schlafli_succ_dim, schlafli_zero_dim, Nat.choose_one_right]
  ring

/-- **Pascal recurrence.**  Adding one hyperplane splits the count into the
regions it misses and the regions it cuts, the latter forming an arrangement of
`n` hyperplanes inside a `d`-dimensional hyperplane. -/
theorem schlafli_succ_succ (n d : ℕ) :
    schlafli (n + 1) (d + 1) = schlafli n (d + 1) + schlafli n d := by
  induction d with
  | zero => simp
  | succ d ih =>
      have hd := schlafli_succ_dim n d
      rw [schlafli_succ_dim (n + 1) (d + 1), ih, Nat.choose_succ_succ n (d + 1),
        schlafli_succ_dim n (d + 1)]
      simp only [Nat.succ_eq_add_one]
      omega

/-- Dimension two: the classical `1 + n + C(n,2)` "pancake" count, stated
without division. -/
theorem schlafli_two_dim (n : ℕ) : 2 * schlafli n 2 = n * n + n + 2 := by
  induction n with
  | zero => simp
  | succ n ih =>
      have h := schlafli_succ_succ n 1
      have h1 : schlafli n 1 = n + 1 := schlafli_one_dim n
      rw [show (1 : ℕ) + 1 = 2 from rfl] at h
      rw [h, h1]
      ring_nf
      ring_nf at ih
      omega

/-- In the low-hyperplane regime every sign pattern is available. -/
theorem schlafli_eq_two_pow (n d : ℕ) (h : n ≤ d) : schlafli n d = 2 ^ n := by
  have hIic : Iic d = Finset.range (d + 1) := by ext k; simp
  unfold schlafli
  rw [hIic, Finset.range_eq_Ico,
    ← Finset.sum_Ico_consecutive _ (Nat.zero_le (n + 1)) (by omega : n + 1 ≤ d + 1)]
  have h0 : ∑ k ∈ Finset.Ico 0 (n + 1), n.choose k = 2 ^ n := by
    rw [← Finset.range_eq_Ico]; exact Nat.sum_range_choose n
  have h1 : ∑ k ∈ Finset.Ico (n + 1) (d + 1), n.choose k = 0 :=
    Finset.sum_eq_zero fun k hk => Nat.choose_eq_zero_of_lt (by
      simp only [Finset.mem_Ico] at hk; omega)
  omega

/-- Monotone in the number of hyperplanes. -/
theorem schlafli_mono_hyperplanes {n₁ n₂ : ℕ} (h : n₁ ≤ n₂) (d : ℕ) :
    schlafli n₁ d ≤ schlafli n₂ d :=
  Finset.sum_le_sum fun k _ => Nat.choose_le_choose k h

/-- Monotone in the dimension. -/
theorem schlafli_mono_dim (n : ℕ) {d₁ d₂ : ℕ} (h : d₁ ≤ d₂) :
    schlafli n d₁ ≤ schlafli n d₂ :=
  Finset.sum_le_sum_of_subset (by intro k hk; simp at hk ⊢; omega)

theorem schlafli_le_two_pow (n d : ℕ) : schlafli n d ≤ 2 ^ n := by
  rcases le_or_gt n d with h | h
  · exact (schlafli_eq_two_pow n d h).le
  · calc schlafli n d ≤ schlafli n n := schlafli_mono_dim n h.le
      _ = 2 ^ n := schlafli_eq_two_pow n n le_rfl

theorem schlafli_pos (n d : ℕ) : 0 < schlafli n d :=
  Finset.sum_pos' (fun _ _ => Nat.zero_le _) ⟨0, by simp⟩

/-- **Strict deficiency.**  Once there are more hyperplanes than dimensions the
Schläfli count is strictly below the naive `2^n` sign-pattern bound: some sign
patterns are geometrically unrealizable. -/
theorem schlafli_lt_two_pow {n d : ℕ} (h : d < n) : schlafli n d < 2 ^ n := by
  have hn : n - 1 + 1 = n := by omega
  have hstep : schlafli n (n - 1) + n.choose n = schlafli n n := by
    conv_rhs => rw [← hn]
    rw [schlafli_succ_dim, hn]
  have hmono : schlafli n d ≤ schlafli n (n - 1) :=
    schlafli_mono_dim n (Nat.le_sub_one_of_lt h)
  have hfull : schlafli n n = 2 ^ n := schlafli_eq_two_pow n n le_rfl
  rw [Nat.choose_self] at hstep
  omega

/-- The catalog capacity model `(n+1)^d` dominates the exact Schläfli count. -/
theorem schlafli_le_regionCapacity (n d : ℕ) :
    schlafli n d ≤ ReLUWidthDepth.regionCapacity n d := by
  unfold ReLUWidthDepth.regionCapacity
  induction n generalizing d with
  | zero => simp
  | succ n ih =>
      cases d with
      | zero => simp
      | succ d =>
          have h1 := schlafli_succ_succ n d
          have h2 : schlafli n (d + 1) ≤ (n + 1) ^ (d + 1) := ih (d + 1)
          have h3 : schlafli n d ≤ (n + 1) ^ d := ih d
          have h4 : (n + 1) ^ (d + 1) + (n + 1) ^ d ≤ (n + 1 + 1) ^ (d + 1) := by
            have hp : (n + 1) ^ d ≤ (n + 2) ^ d := Nat.pow_le_pow_left (by omega) d
            calc (n + 1) ^ (d + 1) + (n + 1) ^ d
                = (n + 2) * (n + 1) ^ d := by ring
              _ ≤ (n + 2) * (n + 2) ^ d := Nat.mul_le_mul_left _ hp
              _ = (n + 1 + 1) ^ (d + 1) := by ring
          omega

/-- In dimension `1` the coarse capacity model is exactly the Schläfli count,
so the comparison above is sharp there. -/
theorem schlafli_eq_regionCapacity_dim_one (n : ℕ) :
    schlafli n 1 = ReLUWidthDepth.regionCapacity n 1 := by
  simp [ReLUWidthDepth.regionCapacity]

/-- **The capacity heuristic is strictly lossy in dimension `≥ 2`.**  For at
least one hyperplane and dimension at least two, `(n+1)^d` strictly exceeds the
exact count, so the catalog's `regionCapacity` can never be attained there. -/
theorem schlafli_lt_regionCapacity {n d : ℕ} (hn : 1 ≤ n) (hd : 2 ≤ d) :
    schlafli n d < ReLUWidthDepth.regionCapacity n d := by
  unfold ReLUWidthDepth.regionCapacity
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  obtain ⟨e, rfl⟩ : ∃ e, d = e + 1 := ⟨d - 1, by omega⟩
  have he : 1 ≤ e := by omega
  have h1 := schlafli_succ_succ m e
  have h2 : schlafli m (e + 1) ≤ (m + 1) ^ (e + 1) := schlafli_le_regionCapacity m (e + 1)
  have h3 : schlafli m e ≤ (m + 1) ^ e := schlafli_le_regionCapacity m e
  have hp : (m + 1) ^ e < (m + 2) ^ e := by
    exact Nat.pow_lt_pow_left (by omega) (by omega)
  have h4 : (m + 1) ^ (e + 1) + (m + 1) ^ e < (m + 1 + 1) ^ (e + 1) := by
    calc (m + 1) ^ (e + 1) + (m + 1) ^ e
        = (m + 2) * (m + 1) ^ e := by ring
      _ < (m + 2) * (m + 2) ^ e := mul_lt_mul_of_pos_left hp (by omega)
      _ = (m + 1 + 1) ^ (e + 1) := by ring
  omega

end ReLUPartition