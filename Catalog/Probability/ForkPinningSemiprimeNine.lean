/-
# Semiprime readouts on the abelian ladder: the which-factor null and the split-count law

For a semiprime `N = p q` with `p, q` two independent uniformly random Frobenius classes in a
finite group `G` (for the degree-nine rung, `G = (ℤ/19)ˣ`), the experiment measured

* `I(N mod 19 ; unordered type pair)` and the **which-factor extra**
  `I(N ; ordered pair) - I(N ; unordered pair)` (measured `0.00053` bits — "null"), and
* the **split-count projection** `I(N ; #{split factors})`.

This file proves the exact laws behind those readings.

* `ForkPinning.mutualInfo_comm` : `I(X;Y) = I(Y;X)`.
* `ForkPinning.mutualInfo_sym2_eq` : **symmetrisation is free** — if an involution of the
  sample space preserves the observable `X` and swaps the two coordinates of a pair-valued
  statistic `Y`, then forgetting the order of the pair loses no information about `X`.
* `ForkPinning.which_factor_extra_zero` : for every finite **abelian** group and every type
  function `F`, `I(N ; (F p, F q)) = I(N ; {F p, F q})` — the which-factor extra is exactly `0`.
* `ForkPinning.degreeNine_which_factor_extra_zero` : the degree-nine instance (`F = T19`).
* `ForkPinning.semiprime_splitCount_mutualInfo` : **the split-count law** — for any finite
  group of order `n ≥ 2`,
  `I(N ; splitCount) = Is(n) + η(1/n²) + η(2(n-1)/n²) - η((2n-1)/n²)` with `η = negMulLog`
  and `Is = semiprimeDial` the OR-dial; the correction is the conditional entropy of the split
  count given the OR-fork, because `(N, splitCount)` and `(N, OR)` determine each other.
-/

import Probability.ForkPinningSharpConstant
import Probability.ForkPinningDegreeNine
import Probability.ForkPinningDataProcessing

namespace ForkPinning

open Finset Real

section General

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]
variable {κ β : Type*} [Fintype κ] [DecidableEq κ] [Fintype β] [DecidableEq β]

omit [Nonempty Ω] in
lemma entropy_joint_comm (X : Ω → κ) (Y : Ω → β) : H (joint X Y) = H (joint Y X) := by
  rw [← entropy_congr_equiv (Equiv.prodComm κ β) (joint X Y)]
  rfl

omit [Nonempty Ω] in
/-- Mutual information is symmetric. -/
theorem mutualInfo_comm (X : Ω → κ) (Y : Ω → β) : mutualInfo X Y = mutualInfo Y X := by
  unfold mutualInfo; rw [entropy_joint_comm]; ring

omit [Nonempty Ω] in
/-- Two statistics that determine each other have the same entropy. -/
theorem entropy_eq_of_determines_both {X : Ω → κ} {Y : Ω → β} (h1 : Determines X Y)
    (h2 : Determines Y X) : H X = H Y := by
  rw [← entropy_joint_eq_of_determines h1, entropy_joint_comm,
    entropy_joint_eq_of_determines h2]

/-! ## Symmetrisation is free -/

section Sym

variable {γ : Type*} [Fintype γ] [DecidableEq γ]

omit [Nonempty Ω] [Fintype γ] in
/-- Counting lemma: the cell of an unordered pair is one or two ordered cells, and the two
ordered cells have equal size thanks to the swapping involution. -/
lemma card_sym2_cell (σ : Ω → Ω) (hσ : Function.Involutive σ) (Y : Ω → γ × γ)
    (hY : ∀ ω, Y (σ ω) = (Y ω).swap) (p : Ω → Prop) [DecidablePred p]
    (hp : ∀ ω, p (σ ω) ↔ p ω) (s t : γ) :
    #{ω | Sym2.mk (Y ω) = s(s, t) ∧ p ω}
      = (if s = t then 1 else 2) * #{ω | Y ω = (s, t) ∧ p ω} := by
  classical
  have hunion : ({ω | Sym2.mk (Y ω) = s(s, t) ∧ p ω} : Finset Ω)
      = ({ω | Y ω = (s, t) ∧ p ω} : Finset Ω) ∪ ({ω | Y ω = (t, s) ∧ p ω} : Finset Ω) := by
    ext ω
    simp only [mem_filter, mem_univ, true_and, mem_union]
    obtain ⟨u, v⟩ := Y ω
    simp only [Sym2.eq_iff, Prod.mk.injEq]
    tauto
  have hswap : #{ω | Y ω = (t, s) ∧ p ω} = #{ω | Y ω = (s, t) ∧ p ω} := by
    refine Finset.card_nbij' σ σ (fun ω hω => ?_) (fun ω hω => ?_) (fun ω _ => hσ ω)
      (fun ω _ => hσ ω)
    · simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hω ⊢
      rw [hY, hω.1, hp]; exact ⟨rfl, hω.2⟩
    · simp only [coe_filter, mem_univ, true_and, Set.mem_setOf_eq] at hω ⊢
      rw [hY, hω.1, hp]; exact ⟨rfl, hω.2⟩
  rw [hunion]
  split_ifs with hst
  · subst hst; rw [union_self, one_mul]
  · rw [card_union_of_disjoint, hswap]
    · ring
    · rw [disjoint_filter]
      intro ω _ h1 h2
      rw [h1.1] at h2
      exact hst (Prod.mk.inj h2.1).1

/-- **Symmetrisation is free.**  If an involution `σ` of the sample space preserves the
observable `X` and swaps the coordinates of the pair statistic `Y`, then the unordered pair
carries exactly as much information about `X` as the ordered one. -/
theorem mutualInfo_sym2_eq (σ : Ω → Ω) (hσ : Function.Involutive σ) (X : Ω → κ)
    (Y : Ω → γ × γ) (hX : ∀ ω, X (σ ω) = X ω) (hY : ∀ ω, Y (σ ω) = (Y ω).swap) :
    mutualInfo X (fun ω => Sym2.mk (Y ω)) = mutualInfo X Y := by
  rw [mutualInfo_comm, mutualInfo_comm X Y]
  refine (mutualInfo_comp_eq_iff Sym2.mk Y X).mpr ?_
  rintro ⟨s, t⟩ b
  have hN := card_pos (Ω := Ω)
  set c : ℝ := if s = t then 1 else 2 with hc
  have hc0 : 0 < c := by rw [hc]; split_ifs <;> norm_num
  have hA : ((fiber (joint (fun ω => Sym2.mk (Y ω)) X) (s(s, t), b)).card : ℝ)
      = c * (fiber (joint Y X) ((s, t), b)).card := by
    have h := card_sym2_cell σ hσ Y hY (fun ω => X ω = b) (fun ω => by simp only [hX]) s t
    have e1 : fiber (joint (fun ω => Sym2.mk (Y ω)) X) (s(s, t), b)
        = ({ω | Sym2.mk (Y ω) = s(s, t) ∧ X ω = b} : Finset Ω) := by
      ext ω; simp [fiber, joint]
    have e2 : fiber (joint Y X) ((s, t), b) = ({ω | Y ω = (s, t) ∧ X ω = b} : Finset Ω) := by
      ext ω; simp [fiber, joint]
    rw [e1, e2, h, hc]; split_ifs <;> push_cast <;> ring
  have hP : ((fiber (fun ω => Sym2.mk (Y ω)) s(s, t)).card : ℝ)
      = c * (fiber Y (s, t)).card := by
    have h := card_sym2_cell σ hσ Y hY (fun _ => True) (fun _ => Iff.rfl) s t
    have e1 : fiber (fun ω => Sym2.mk (Y ω)) s(s, t)
        = ({ω | Sym2.mk (Y ω) = s(s, t) ∧ True} : Finset Ω) := by
      ext ω; simp [fiber]
    have e2 : fiber Y (s, t) = ({ω | Y ω = (s, t) ∧ True} : Finset Ω) := by
      ext ω; simp [fiber]
    rw [e1, e2, h, hc]; split_ifs <;> push_cast <;> ring
  have hle : (fiber (joint Y X) ((s, t), b)).card ≤ (fiber Y (s, t)).card := by
    apply card_le_card
    intro ω hω
    simp only [fiber, joint, mem_filter, mem_univ, true_and, Prod.mk.injEq] at hω ⊢
    exact hω.1
  simp only [prb]
  rw [hA, hP]
  rcases Nat.eq_zero_or_pos (fiber Y (s, t)).card with h0 | h0
  · have : (fiber (joint Y X) ((s, t), b)).card = 0 := by omega
    rw [this, h0]; simp
  · have h0' : (0 : ℝ) < (fiber Y (s, t)).card := by exact_mod_cast h0
    field_simp

end Sym

end General

/-! ## The which-factor extra is exactly zero -/

section WhichFactor

variable {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]
variable {β : Type*} [Fintype β] [DecidableEq β]

/-- **The which-factor extra vanishes exactly**: in every finite abelian group, for every type
function `F`, knowing *which* factor carries which type adds nothing to what `N = p q` knows
about the unordered pair of types. -/
theorem which_factor_extra_zero (F : G → β) :
    mutualInfo (prodClass : G × G → G) (fun x : G × G => (F x.1, F x.2))
      - mutualInfo (prodClass : G × G → G) (fun x : G × G => Sym2.mk (F x.1, F x.2)) = 0 := by
  rw [mutualInfo_sym2_eq Prod.swap Prod.swap_swap (prodClass : G × G → G)
    (fun x : G × G => (F x.1, F x.2)) (fun x => by simp [prodClass, mul_comm])
    (fun x => rfl)]
  ring

/-- Degree-nine instance: the measured `0.00053`-bit which-factor extra is an exact null. -/
theorem degreeNine_which_factor_extra_zero :
    mutualInfo (prodClass : (ZMod 19)ˣ × (ZMod 19)ˣ → (ZMod 19)ˣ)
        (fun x => (T19 x.1, T19 x.2))
      - mutualInfo (prodClass : (ZMod 19)ˣ × (ZMod 19)ˣ → (ZMod 19)ˣ)
          (fun x => Sym2.mk (T19 x.1, T19 x.2)) = 0 :=
  which_factor_extra_zero T19

end WhichFactor

/-! ## The split-count law -/

section SplitCount

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- Number of split prime factors of `N = p q` (`0`, `1` or `2`). -/
def splitCount (x : G × G) : Fin 3 :=
  if x.1 = 1 ∧ x.2 = 1 then 2 else if x.1 = 1 ∨ x.2 = 1 then 1 else 0

omit [Fintype G] in
/-- `(N, splitCount)` determines `(N, OR)`. -/
lemma determines_count_OR :
    Determines (joint (prodClass : G × G → G) splitCount) (joint prodClass splitORG) := by
  have hOR : ∀ x : G × G, splitORG x = decide (splitCount x ≠ 0) := by
    intro x
    simp only [splitORG, splitCount]
    split_ifs with h1 h2 <;> simp_all
  intro x y h
  simp only [joint, Prod.mk.injEq] at h ⊢
  exact ⟨h.1, by rw [hOR, hOR, h.2]⟩

omit [Fintype G] in
/-- `(N, OR)` determines `(N, splitCount)`: given the class of `N`, the OR-fork already tells
how many factors split. -/
lemma determines_OR_count :
    Determines (joint (prodClass : G × G → G) splitORG) (joint prodClass splitCount) := by
  have hc : ∀ x : G × G, splitCount x
      = if splitORG x then (if prodClass x = 1 then 2 else 1) else 0 := by
    rintro ⟨a, b⟩
    simp only [splitCount, splitORG, prodClass]
    by_cases ha : a = 1 <;> by_cases hb : b = 1
    · simp [ha, hb]
    · simp [ha, hb]
    · simp [ha, hb]
    · simp [ha, hb]
  intro x y h
  simp only [joint, Prod.mk.injEq] at h ⊢
  exact ⟨h.1, by rw [hc, hc, h.1, h.2]⟩

lemma fiber_splitCount_two :
    fiber (splitCount : G × G → Fin 3) 2 = {((1 : G), (1 : G))} := by
  ext ⟨a, b⟩
  simp only [fiber, splitCount, mem_filter, mem_univ, true_and, mem_singleton, Prod.mk.injEq]
  split_ifs with h1 h2 <;> simp_all

lemma fiber_splitCount_zero :
    fiber (splitCount : G × G → Fin 3) 0 = fiber splitORG false := by
  ext ⟨a, b⟩
  simp only [fiber, splitCount, splitORG, mem_filter, mem_univ, true_and]
  split_ifs with h1 h2 <;> simp_all

lemma prb_splitCount_two :
    prb (splitCount : G × G → Fin 3) 2 = 1 / ((Fintype.card G : ℝ) * Fintype.card G) := by
  rw [prb, fiber_splitCount_two, card_singleton, card_prod_self]; simp

lemma prb_splitCount_zero :
    prb (splitCount : G × G → Fin 3) 0
      = ((Fintype.card G : ℝ) - 1) * ((Fintype.card G : ℝ) - 1)
          / ((Fintype.card G : ℝ) * Fintype.card G) := by
  rw [prb, fiber_splitCount_zero, ← prb, prb_splitORG_false]

lemma prb_splitCount_one :
    prb (splitCount : G × G → Fin 3) 1
      = 2 * ((Fintype.card G : ℝ) - 1) / ((Fintype.card G : ℝ) * Fintype.card G) := by
  have hsum := sum_prb (splitCount : G × G → Fin 3)
  rw [Fin.sum_univ_three, prb_splitCount_zero, prb_splitCount_two] at hsum
  have hn := card_G_pos (G := G)
  have h1 : prb (splitCount : G × G → Fin 3) 1
      = 1 - ((Fintype.card G : ℝ) - 1) * ((Fintype.card G : ℝ) - 1)
          / ((Fintype.card G : ℝ) * Fintype.card G)
        - 1 / ((Fintype.card G : ℝ) * Fintype.card G) := by
    linarith
  rw [h1]
  field_simp
  ring

/-- **The split-count law.**  For any finite group of order `n ≥ 2`,
`I(N ; splitCount) = Is(n) + η(1/n²) + η(2(n-1)/n²) - η((2n-1)/n²)`,
where `Is = semiprimeDial` is the OR-dial and `η = negMulLog`. -/
theorem semiprime_splitCount_mutualInfo (n : ℝ) (hcard : (Fintype.card G : ℝ) = n)
    (hn : 2 ≤ n) :
    mutualInfo (prodClass : G × G → G) splitCount
      = semiprimeDial n + negMulLog (1 / (n * n)) + negMulLog (2 * (n - 1) / (n * n))
          - negMulLog ((2 * n - 1) / (n * n)) := by
  have hJ : H (joint (prodClass : G × G → G) splitCount) = H (joint prodClass splitORG) :=
    entropy_eq_of_determines_both determines_count_OR determines_OR_count
  have hI : mutualInfo (prodClass : G × G → G) splitCount
      = mutualInfo (prodClass : G × G → G) splitORG + H (splitCount : G × G → Fin 3)
          - H (splitORG : G × G → Bool) := by
    unfold mutualInfo; rw [hJ]; ring
  rw [hI, semiprimeDial_eq n hcard hn]
  unfold H
  rw [Fin.sum_univ_three, Fintype.sum_bool, prb_splitCount_zero, prb_splitCount_one,
    prb_splitCount_two, prb_splitORG_true, prb_splitORG_false, hcard]
  ring_nf

/-- The split-count projection strictly exceeds the OR-dial (the count refines the fork). -/
theorem splitCount_gt_OR (n : ℝ) (hcard : (Fintype.card G : ℝ) = n) (hn : 2 ≤ n) :
    mutualInfo (prodClass : G × G → G) splitORG
      < mutualInfo (prodClass : G × G → G) splitCount := by
  rw [semiprime_splitCount_mutualInfo n hcard hn, semiprimeDial_eq n hcard hn]
  have hn0 : 0 < n * n := by nlinarith
  have ha : 0 < 1 / (n * n) := by positivity
  have hb : 0 < 2 * (n - 1) / (n * n) := by apply div_pos <;> nlinarith
  have hsum : 1 / (n * n) + 2 * (n - 1) / (n * n) = (2 * n - 1) / (n * n) := by
    field_simp; ring
  have hlt : negMulLog ((2 * n - 1) / (n * n))
      < negMulLog (1 / (n * n)) + negMulLog (2 * (n - 1) / (n * n)) := by
    rw [← hsum]
    simp only [negMulLog]
    have h1 : Real.log (1 / (n * n)) < Real.log (1 / (n * n) + 2 * (n - 1) / (n * n)) :=
      Real.log_lt_log ha (by linarith)
    have h2 : Real.log (2 * (n - 1) / (n * n))
        < Real.log (1 / (n * n) + 2 * (n - 1) / (n * n)) :=
      Real.log_lt_log hb (by linarith)
    nlinarith [mul_lt_mul_of_pos_left h1 ha, mul_lt_mul_of_pos_left h2 hb]
  linarith

end SplitCount

/-- **Degree-nine split-count law.**  The Galois group of `ℚ(ζ₁₉)⁺` is `C₉`; a prime splits
iff its Frobenius class is trivial.  The split-count projection of the class of `N = p q` in
`C₉` is `Is(9) + η(1/81) + η(16/81) - η(17/81)` (`≈ 0.0738` bits). -/
theorem degreeNine_splitCount :
    mutualInfo (prodClass : Multiplicative (ZMod 9) × Multiplicative (ZMod 9) →
        Multiplicative (ZMod 9)) splitCount
      = semiprimeDial 9 + negMulLog (1 / 81) + negMulLog (16 / 81) - negMulLog (17 / 81) := by
  rw [semiprime_splitCount_mutualInfo 9 (by simp) (by norm_num)]
  norm_num

end ForkPinning