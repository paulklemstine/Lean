/-
# Why the cyclic-cubic channel is *fully* pinned: the structural reason

## Context (FACT round-32 #3, cycle 3)

`Applications.CyclicCubicTypeChannel.Entropy` computes, for the conductor-`7`
cyclic cubic field, the exact identity `I(p mod 7 ; T) = H(T)`.  Taken alone
that is a numerical coincidence of two closed forms.  This file explains it.

Two general facts about an arbitrary finite joint distribution `w : α × β → ℝ`
are proved from the entropy deficit of `Applications.LabelEntropyDeficit`:

* `CyclicCubic.MI_le_left` / `CyclicCubic.MI_le_right` — the *data-processing
  ceiling* `I(X;Y) ≤ H(X)` and `I(X;Y) ≤ H(Y)`, a consequence of
  `LabelEntropy.nlp_sum_le_H` (merging labels loses entropy) applied fibrewise;
* `CyclicCubic.MI_of_deterministic` — if the second coordinate is a *function*
  of the first, the ceiling is attained: `I(X;Y) = H(Y)`.

Specialising the second statement to the splitting-type map `resType` gives
`CyclicCubic.full_pinning_structural`, a second and conceptual proof of full
pinning: the type is pinned because the splitting law
`p ≡ ±1 (mod 7) ↔ deg = 1` is a *deterministic* function of `p mod 7`, not
because two logarithms happen to agree.

Finally `CyclicCubic.semiprime_deficit_eq_type_entropy` measures the failure for
semiprimes in the same currency: the gap between the ceiling `H(pair)` and the
transmitted information `I` is *exactly* `H(T)`, one full type's worth of
entropy — the multiplicative structure destroys precisely one factor's label.
-/
import Mathlib
import Applications.CyclicCubicTypeChannel.Entropy

open Finset LabelEntropy

namespace CyclicCubic

/-! ## General upper bounds on mutual information -/

section General

variable {α β : Type*} [Fintype α] [Fintype β]

/-- Merging the `β`-fibres loses entropy: the `α`-marginal has entropy at most
that of the joint distribution. -/
theorem H_marginal_left_le (w : α × β → ℝ) (hw : ∀ q, 0 ≤ w q) :
    H univ (fun a : α => ∑ b : β, w (a, b)) ≤ H univ w := by
  have hsplit : H univ w = ∑ a : α, H univ (fun b : β => w (a, b)) := by
    simp only [H]
    rw [Fintype.sum_prod_type]
  rw [hsplit]
  simp only [H]
  exact Finset.sum_le_sum fun a _ => nlp_sum_le_H fun b _ => hw _

/-- The same bound for the `β`-marginal. -/
theorem H_marginal_right_le (w : α × β → ℝ) (hw : ∀ q, 0 ≤ w q) :
    H univ (fun b : β => ∑ a : α, w (a, b)) ≤ H univ w := by
  have hsplit : H univ w = ∑ b : β, H univ (fun a : α => w (a, b)) := by
    simp only [H]
    rw [Fintype.sum_prod_type_right]
  rw [hsplit]
  simp only [H]
  exact Finset.sum_le_sum fun b _ => nlp_sum_le_H fun a _ => hw _

/-- **Data-processing ceiling, first coordinate.**  `I(X;Y) ≤ H(X)`. -/
theorem MI_le_left (w : α × β → ℝ) (hw : ∀ q, 0 ≤ w q) :
    MI w ≤ H univ (fun a : α => ∑ b : β, w (a, b)) := by
  unfold MI
  linarith [H_marginal_right_le w hw]

/-- **Data-processing ceiling, second coordinate.**  `I(X;Y) ≤ H(Y)`. -/
theorem MI_le_right (w : α × β → ℝ) (hw : ∀ q, 0 ≤ w q) :
    MI w ≤ H univ (fun b : β => ∑ a : α, w (a, b)) := by
  unfold MI
  linarith [H_marginal_left_le w hw]

/-- **Determinism saturates the ceiling.**  If the second coordinate is the
value of a function `g` of the first, the mutual information equals the full
entropy of the second marginal. -/
theorem MI_of_deterministic [DecidableEq β] (g : α → β) (v : α → ℝ) :
    MI (fun q : α × β => if q.2 = g q.1 then v q.1 else 0)
      = H univ (fun b : β => ∑ a : α, if b = g a then v a else 0) := by
  have hnlp0 : nlp (0 : ℝ) = 0 := by simp [nlp]
  have hA : (fun a : α => ∑ b : β, if b = g a then v a else 0) = v := by
    funext a
    simp
  have hjoint : H univ (fun q : α × β => if q.2 = g q.1 then v q.1 else 0) = H univ v := by
    simp only [H]
    rw [Fintype.sum_prod_type]
    refine Finset.sum_congr rfl fun a _ => ?_
    simp [apply_ite nlp, hnlp0]
  unfold MI
  rw [hA, hjoint]
  ring

end General

/-! ## The conductor-7 type channel saturates the ceiling -/

lemma pRT_nonneg (q : ZMod 7 × Bool) : 0 ≤ pRT q := by
  rw [pRT_eq]
  split <;> norm_num

/-- The residue-to-type channel is deterministic: the joint law is supported on
the graph of `resType`. -/
theorem pRT_deterministic :
    pRT = fun q : ZMod 7 × Bool =>
      if q.2 = resType q.1 then (if q.1 ≠ 0 then (1 : ℝ) / 6 else 0) else 0 := by
  funext q
  rw [pRT_eq]
  by_cases h1 : q.1 = 0
  · simp [h1]
  · by_cases h2 : q.2 = resType q.1
    · simp [h1, h2]
    · simp [h1, h2, Ne.symm h2]

/-- **Full pinning, structurally.**  `I(p mod 7 ; T) = H(T)` because the type is
a function of the residue — a second proof of `CyclicCubic.full_pinning` that
uses no closed-form logarithm computation. -/
theorem full_pinning_structural :
    MI pRT = H univ (fun b : Bool => ∑ n : ZMod 7, pRT (n, b)) := by
  rw [pRT_deterministic]
  exact MI_of_deterministic resType (fun n : ZMod 7 => if n ≠ 0 then (1 : ℝ) / 6 else 0)

/-- The type channel attains the general ceiling `I ≤ H(T)`: pinning is maximal,
not merely large. -/
theorem pinning_saturates :
    MI pRT ≤ H univ (fun b : Bool => ∑ n : ZMod 7, pRT (n, b)) :=
  MI_le_right pRT pRT_nonneg

/-! ## The semiprime channel: an exactly quantified failure -/

lemma pSemi_nonneg (q : ZMod 7 × Fin 3) : 0 ≤ pSemi q := by
  rw [pSemi_eq]
  split
  · norm_num
  · split <;> norm_num

/-- The semiprime channel also obeys the ceiling. -/
theorem semiprime_below_ceiling :
    MI pSemi ≤ H univ (fun k : Fin 3 => ∑ n : ZMod 7, pSemi (n, k)) :=
  MI_le_right pSemi pSemi_nonneg

/-- **The semiprime deficit is exactly one type entropy.**  The information the
residue `N mod 7` fails to convey about the unordered type pair of `N = p·q`
equals `H(T) = log₂ 3 − 2/3`, the entropy of a single prime's type.  So
multiplying two primes destroys precisely one label. -/
theorem semiprime_deficit_eq_type_entropy :
    H univ (fun k : Fin 3 => ∑ n : ZMod 7, pSemi (n, k)) - MI pSemi
      = H univ (fun b : Bool => ∑ n : ZMod 7, pRT (n, b)) := by
  rw [H_semi_pair, mutualInfo_semiprime, H_typeMarginal]
  ring

/-- Consequently the semiprime deficit is strictly positive and lies in
`(0.917, 0.919)` bits. -/
theorem semiprime_deficit_bounds :
    0.917 < H univ (fun k : Fin 3 => ∑ n : ZMod 7, pSemi (n, k)) - MI pSemi ∧
      H univ (fun k : Fin 3 => ∑ n : ZMod 7, pSemi (n, k)) - MI pSemi < 0.919 := by
  rw [semiprime_deficit_eq_type_entropy]
  exact H_typeMarginal_bounds

end CyclicCubic