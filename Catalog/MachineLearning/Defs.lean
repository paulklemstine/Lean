import Mathlib

/-!
# Top-k Order Statistics and Robustness Definitions

This file defines the core objects for top-k certified robustness:

* `kthLargest s k` — the (k+1)-th largest value of `s : Fin C → ℝ` (0-indexed)
* `topkGap s k` — the gap between the k-th and (k+1)-th largest values
* `topKSet s k` — the set of indices with scores strictly above the (k+1)-th largest

The k-th largest value is defined via the classical "sup of infima" characterization:
  `kthLargest s k = max_{|S|=k+1} min_{i ∈ S} s(i)`

This definition is proof-friendly because the perturbation bound follows directly
from the monotonicity of inf and sup operations.
-/

noncomputable section

open Finset

/-! ## Auxiliary lemmas for powersetCard -/

/-- Nonemptiness of powersetCard when k+1 ≤ C -/
lemma powersetCard_univ_nonempty {C : ℕ} (k : ℕ) (h : k < C) :
    ((univ : Finset (Fin C)).powersetCard (k + 1)).Nonempty := by
  rw [powersetCard_nonempty, card_univ, Fintype.card_fin]; omega

/-- Any member of `powersetCard (k+1) univ` is nonempty -/
lemma nonempty_of_mem_powersetCard_succ {C : ℕ} {k : ℕ} {S : Finset (Fin C)}
    (hS : S ∈ (univ : Finset (Fin C)).powersetCard (k + 1)) : S.Nonempty := by
  rw [nonempty_iff_ne_empty]
  intro h
  have := (mem_powersetCard.mp hS).2
  rw [h, card_empty] at this; omega

/-- Card of members of powersetCard -/
lemma card_of_mem_powersetCard {C : ℕ} {k : ℕ} {S : Finset (Fin C)}
    (hS : S ∈ (univ : Finset (Fin C)).powersetCard (k + 1)) : S.card = k + 1 :=
  (mem_powersetCard.mp hS).2

/-! ## Core Definitions -/

/-- The k-th largest value (0-indexed) of a finite score function `s : Fin C → ℝ`.
    Defined as the maximum over all (k+1)-element subsets of `Fin C` of the
    minimum value of `s` on the subset:
      `kthLargest s k = sup_{|S|=k+1} inf_{i ∈ S} s(i)`
    Returns 0 if `k ≥ C`. -/
def kthLargest {C : ℕ} (s : Fin C → ℝ) (k : ℕ) : ℝ :=
  if h : k < C then
    ((univ : Finset (Fin C)).powersetCard (k + 1)).sup'
      (powersetCard_univ_nonempty k h)
      (fun S => if hne : S.Nonempty then S.inf' hne s else 0)
  else 0

/-- The top-k gap: the difference between the k-th largest and (k+1)-th largest values.
    For `k ≥ 1`, this measures the separation between the top-k scores and the rest.
    `topkGap s k = kthLargest s (k-1) - kthLargest s k` -/
def topkGap {C : ℕ} (s : Fin C → ℝ) (k : ℕ) : ℝ :=
  kthLargest s (k - 1) - kthLargest s k

/-- The top-k set: the set of indices whose score strictly exceeds the (k+1)-th
    largest value. Under a positive gap condition, this has exactly k elements. -/
def topKSet {C : ℕ} (s : Fin C → ℝ) (k : ℕ) : Finset (Fin C) :=
  univ.filter (fun i => kthLargest s k < s i)

/-! ## Basic kthLargest simplification -/

/-- Unfold kthLargest when k < C -/
lemma kthLargest_def {C : ℕ} (s : Fin C → ℝ) (k : ℕ) (hk : k < C) :
    kthLargest s k =
      ((univ : Finset (Fin C)).powersetCard (k + 1)).sup'
        (powersetCard_univ_nonempty k hk)
        (fun S => if hne : S.Nonempty then S.inf' hne s else 0) := by
  simp [kthLargest, hk]

/-- The sup' function on powersetCard evaluates to inf' on nonempty subsets -/
lemma kthLargest_eq_sup'_inf' {C : ℕ} (s : Fin C → ℝ) (k : ℕ) (hk : k < C) :
    kthLargest s k =
      ((univ : Finset (Fin C)).powersetCard (k + 1)).sup'
        (powersetCard_univ_nonempty k hk)
        (fun S => if hne : S.Nonempty then S.inf' hne s else 0) :=
  kthLargest_def s k hk

end