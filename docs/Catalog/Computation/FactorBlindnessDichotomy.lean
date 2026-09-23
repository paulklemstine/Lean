/-
# The dichotomy: where the wall is exact the sandwich is vacuous, and conversely

`Computation.FactorBlindnessWall` proves that a symmetric readout on a swap-closed,
off-diagonal *population* leaks exactly `0` which-factor bits.
`Computation.FactorBlindnessHintedView` proves that on a *sample* the plug-in reading is
pinned inside a band of width the collision fraction.  Numerically the two statements look
like they should collide: the exact reading is `0`, the sample reading of the hint view is
`0.97`.  They do not collide, and this file explains why in one theorem.

A sample is *swap-closed* when it carries a fixed-point-free involution `σ` that swaps the two
factors: the view is constant along `σ` (symmetry) and the which-factor label flips along `σ`.
On such a sample:

* `swapClosed_collisionCount_eq` — **every** fiber of the view has at least two elements, so
  `collisionCount c = n`: the collision fraction is `1` and the sandwich of
  `hintedView_sandwich` degenerates to the trivial statement `H(ℓ) − 1 ≤ Î ≤ H(ℓ)`.
* `swapClosed_mutualInfo_eq_zero` — and the reading really is exactly `0`, the sample-level
  form of `galoisBlind_zero_leakage`, proved from the involution alone.

Contrapositively (`not_swapClosed_of_collisionCount_lt`), **a sample on which the view is even
slightly injective cannot be swap-closed**: the sparse regime and the Galois-symmetric regime
are disjoint.  The `0.97`-bit hint-view reading therefore says nothing about leakage — it is a
reading taken in the regime where, by `hintedView_test_is_powerless`, the statistic has no
resolution, and the regime where the exact-zero theorem applies is exactly the regime where
the collision fraction is `1`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the exact-zero population readings and the near-`H(ℓ)` sample readings
  are not in tension; they occupy complementary regimes indexed by the collision fraction.
Experiment (Stage 2, `ComputationalEvidence.md`): 3906 ordered pairs of 63 primes in
  (50, 2000).  Product view `N mod 713`: 639 distinct codes, observed reading `0.0000`,
  200-shuffle null mean `0.1363`, sd `0.0070`.  `(s,d)` hint view: 1953 distinct codes (exactly
  `n/2`, one per unordered pair — the signature of the involution), observed `0.0000`, null
  mean `0.4990`.  Residue view: 3 codes, observed `0.0000`, null mean `0.0004`.  In every
  case the measured collision count is `3906 = n`, exactly as the theorem below predicts, and
  the observed reading is exactly `0`, exactly as `swapClosed_mutualInfo_eq_zero` predicts.
Analysis (Stage 3): the involution forces `2 · cellCount = fiberCount` in every cell, which is
  literally the product-table identity `labelCard · fiberCount = cellCount · n`; the same
  involution forces each fiber to contain the pair `{i, σ i}`, which is the collision
  statement.  One structure yields both halves of the dichotomy.
Critique (Stage 4): fixed-point-freeness is load-bearing — an involution with a fixed point
  is a sample containing `(p,p)`, where the label cannot flip; the label-flip hypothesis is
  the sample-level replacement for off-diagonality, and is stated rather than assumed away.
  The theorem is about the *sample*, so it applies to the experiment's shuffled surrogates
  only if the surrogate preserves the involution, which a label shuffle does not — which is
  precisely why the surrogate readings in the run above are *larger* than the observed `0`.
Synthesis (Stage 5): the permutation null of a symmetric view on a swap-closed sample is
  biased *upwards* away from an exactly-zero observation; the flagged positive readings of
  the programme are the null's own inflation seen from below.
-/
import Mathlib
import Computation.FactorBlindnessInformation
import Computation.FactorBlindnessHintedView

namespace Computation.FactorBlindness

open Finset

variable {n : ℕ} {K : Type*} [Fintype K] [DecidableEq K]
variable {l : Fin n → Bool} {c : Fin n → K} {σ : Equiv.Perm (Fin n)}

/-! ## Swap-closed samples -/

omit [Fintype K] in
/-- Every fiber of a view that is constant along a fixed-point-free involution contains at
least two samples. -/
theorem fiberCount_ge_two_of_swap (hnofix : ∀ i, σ i ≠ i) (hc : ∀ i, c (σ i) = c i) (i : Fin n) :
    2 ≤ fiberCount c (c i) := by
  unfold fiberCount
  rw [show (2 : ℕ) = 1 + 1 from rfl, Nat.add_one_le_iff, Finset.one_lt_card]
  refine ⟨i, by simp, σ i, by simp [hc i], ?_⟩
  exact fun h => hnofix i h.symm

omit [Fintype K] in
/-- **On a swap-closed sample every sample collides.**  The collision fraction is `1`, so the
sandwich of `hintedView_sandwich` carries no information there. -/
theorem swapClosed_collisionCount_eq (hnofix : ∀ i, σ i ≠ i) (hc : ∀ i, c (σ i) = c i) :
    collisionCount c = n := by
  unfold collisionCount
  rw [Finset.filter_true_of_mem (fun i _ => fiberCount_ge_two_of_swap hnofix hc i)]
  simp

/-! ## The exact zero on a swap-closed sample -/

omit [Fintype K] in
/-- The involution matches the two label cells of every fiber. -/
theorem cellCount_swap_eq (hinv : ∀ i, σ (σ i) = i) (hc : ∀ i, c (σ i) = c i)
    (hl : ∀ i, l (σ i) ≠ l i) (b : Bool) (k : K) :
    cellCount l c b k = cellCount l c (!b) k := by
  unfold cellCount
  refine Finset.card_bij' (fun i _ => σ i) (fun i _ => σ i) ?_ ?_ ?_ ?_
  · intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi ⊢
    refine ⟨?_, by rw [hc i]; exact hi.2⟩
    have := hl i
    rw [hi.1] at this
    cases hb : l (σ i) <;> cases b <;> simp_all
  · intro i hi
    simp only [mem_filter, mem_univ, true_and] at hi ⊢
    refine ⟨?_, by rw [hc i]; exact hi.2⟩
    have := hl i
    rw [hi.1] at this
    cases hb : l (σ i) <;> cases b <;> simp_all
  · intro i _; exact hinv i
  · intro i _; exact hinv i

omit [Fintype K] in
/-- Each fiber splits evenly between the two labels. -/
theorem two_mul_cellCount (hinv : ∀ i, σ (σ i) = i) (hc : ∀ i, c (σ i) = c i)
    (hl : ∀ i, l (σ i) ≠ l i) (b : Bool) (k : K) :
    2 * cellCount l c b k = fiberCount c k := by
  have hsum := sum_cellCount_over_label l c k
  rw [Fintype.sum_bool] at hsum
  have hswap := cellCount_swap_eq hinv hc hl b k
  cases b <;> simp only [Bool.not_false, Bool.not_true] at hswap <;> omega

/-- Each label carries exactly half the sample. -/
theorem two_mul_labelCard (hinv : ∀ i, σ (σ i) = i) (hc : ∀ i, c (σ i) = c i)
    (hl : ∀ i, l (σ i) ≠ l i) (b : Bool) :
    2 * labelCard l b = n := by
  have h1 : ∑ k, 2 * cellCount l c b k = ∑ k, fiberCount c k :=
    Finset.sum_congr rfl fun k _ => two_mul_cellCount hinv hc hl b k
  rw [← Finset.mul_sum, sum_cellCount_over_code, sum_fiberCount] at h1
  exact h1

/-- **The contingency table of a swap-closed sample is a product table** (in integer form). -/
theorem labelCard_mul_fiberCount (hinv : ∀ i, σ (σ i) = i) (hc : ∀ i, c (σ i) = c i)
    (hl : ∀ i, l (σ i) ≠ l i) (b : Bool) (k : K) :
    labelCard l b * fiberCount c k = cellCount l c b k * n := by
  have h1 := two_mul_cellCount hinv hc hl b k
  have h2 := two_mul_labelCard (c := c) hinv hc hl b
  calc labelCard l b * fiberCount c k
      = labelCard l b * (2 * cellCount l c b k) := by rw [h1]
    _ = cellCount l c b k * (2 * labelCard l b) := by ring
    _ = cellCount l c b k * n := by rw [h2]

/-- **The sample-level wall.**  On a swap-closed sample — a fixed-point-free involution along
which the view is constant and the which-factor label flips — the plug-in reading is exactly
`0` bits, with no null calibration and no sensitivity floor. -/
theorem swapClosed_mutualInfo_eq_zero (hn : 0 < n) (hinv : ∀ i, σ (σ i) = i)
    (hc : ∀ i, c (σ i) = c i) (hl : ∀ i, l (σ i) ≠ l i) :
    mutualInfo (viewTable l c) = 0 := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  refine mutualInfo_eq_zero_of_product fun b k => ?_
  rw [margL_viewTable, margK_viewTable]
  have hnat := labelCard_mul_fiberCount hinv hc hl b k
  have hreal : (labelCard l b : ℝ) * (fiberCount c k : ℝ) = (cellCount l c b k : ℝ) * n := by
    exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) hnat
  unfold viewTable
  field_simp
  linarith [hreal]

omit [Fintype K] in
/-- **The regimes are disjoint.**  A sample on which the view has even one non-colliding
value cannot be swap-closed: the exactly-blind regime and the sparse regime never overlap. -/
theorem not_swapClosed_of_collisionCount_lt (hlt : collisionCount c < n) :
    ¬ ∃ σ : Equiv.Perm (Fin n), (∀ i, σ i ≠ i) ∧ (∀ i, c (σ i) = c i) := by
  rintro ⟨τ, hnofix, hc⟩
  exact absurd (swapClosed_collisionCount_eq hnofix hc) (Nat.ne_of_lt hlt)

/-- **THE DICHOTOMY.**  For a swap-closed sample the reading is exactly `0` while the
collision fraction is exactly `1`; hence a sample whose reading is positive, or whose
collision fraction is below `1`, is not swap-closed, and its reading is governed by the
sandwich rather than by the wall.  The two halves of the programme never apply at once. -/
theorem blindness_sparsity_dichotomy (hn : 0 < n) (hinv : ∀ i, σ (σ i) = i)
    (hc : ∀ i, c (σ i) = c i) (hl : ∀ i, l (σ i) ≠ l i) (hnofix : ∀ i, σ i ≠ i) :
    mutualInfo (viewTable l c) = 0 ∧ collisionCount c = n ∧
      ((collisionCount c : ℝ) / n) * Real.logb 2 (Fintype.card Bool) = 1 := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  refine ⟨swapClosed_mutualInfo_eq_zero hn hinv hc hl,
    swapClosed_collisionCount_eq hnofix hc, ?_⟩
  rw [swapClosed_collisionCount_eq hnofix hc]
  simp [div_self (ne_of_gt hnR)]

/-- **Nonvacuity.**  The hypotheses of the dichotomy are satisfiable: the two-sample
`{(p,q), (q,p)}` with a constant view and the swap involution meets all four. -/
theorem blindness_sparsity_dichotomy_nonvacuous :
    ∃ (l : Fin 2 → Bool) (c : Fin 2 → Unit) (σ : Equiv.Perm (Fin 2)),
      (∀ i, σ (σ i) = i) ∧ (∀ i, c (σ i) = c i) ∧ (∀ i, l (σ i) ≠ l i) ∧ (∀ i, σ i ≠ i) := by
  refine ⟨fun i => decide (i = 1), fun _ => (), Equiv.swap 0 1, ?_, ?_, ?_, ?_⟩ <;> decide

end Computation.FactorBlindness