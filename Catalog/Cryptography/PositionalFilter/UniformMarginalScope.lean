import Mathlib

/-!
# Paper 137 — the scope of the uniform-marginal lemma: position pays iff the marginal is
not flat

Paper 131's `ordering_invariance` (`Cryptography.PosteriorFilter.KeepRate`) shows that when
the target's marginal over candidates is **uniform**, no visitation order changes the
expected number of tests: every order costs `(n+1)/2`.  Experiment 467 found a `5.19x`
positional gain.  This file proves that the two statements are separated *exactly* by the
uniform-marginal hypothesis, and identifies the sham control used in the experiment.

## The model

There are `n = m + 1` candidates `Fin n`; the target is candidate `i` with weight `μ i ≥ 0`
(any real weights).  A visitation order is a permutation `σ` (candidate `i` is tested at
step `σ i + 1`); its expected cost is

  `orderCost μ σ = ∑ i, μ i * (σ i + 1)`.

The *sham* is the same order composed with a uniformly random cyclic shift, whose expected
cost is `shamCost μ = (∑ μ) (n + 1) / 2`.

## Main results

* `orderCost_const` — **uniform-marginal lemma**: with constant weights every order costs
  the sham.
* `sum_shift_orderCost` — **the cyclic sham**: averaging any order over the `n` cyclic
  shifts gives exactly `shamCost`, so the sham control is an average of real orders.
* `shiftCost_succ_sub` — the discrete derivative of the shifted cost:
  `C(k+1) - C(k) = ∑ μ - n · μ(σ⁻¹(last - k))`.
* `exists_shift_lt_sham` — if the weights are not constant, some cyclic shift of *any* order
  strictly beats the sham.
* `positional_gain_iff` — **separation theorem**: some order strictly beats the sham **iff**
  the marginal is not uniform.  Hence the `4/3` residue cap (proved under a uniform
  marginal) and the measured positional gain cannot contradict each other: they live on the
  two sides of this equivalence.
* `bayes_order_optimal` — the rearrangement inequality: an order that visits candidates in
  decreasing posterior weight minimises the expected cost among all orders.
* `descending_optimal_of_monotone`, `ascending_optimal_of_antitone` — Fermat's
  (sqrt-descending) order is the Bayes order of every prior increasing towards `√N`; the
  plain scan is the Bayes order of every decreasing prior.
* `descending_lt_sham_of_strictMono` — for a strictly increasing prior the descending
  order strictly beats the sham.
-/

namespace PositionalFilter

open Finset

variable {m : ℕ}

/-- Expected number of tests of the visitation order `σ` under target weights `μ`. -/
def orderCost (μ : Fin (m + 1) → ℝ) (σ : Equiv.Perm (Fin (m + 1))) : ℝ :=
  ∑ i, μ i * (((σ i : ℕ) : ℝ) + 1)

/-- The sham cost `(∑ μ) (n + 1) / 2`. -/
noncomputable def shamCost (μ : Fin (m + 1) → ℝ) : ℝ :=
  (∑ i, μ i) * ((m + 1 : ℝ) + 1) / 2

/-- The order `σ` followed by a cyclic shift by `k`. -/
def shiftOrder (σ : Equiv.Perm (Fin (m + 1))) (k : Fin (m + 1)) : Equiv.Perm (Fin (m + 1)) :=
  σ.trans (Equiv.addRight k)

/-- Sum of all positions `0 + 1 + ⋯ + m`, plus one per position. -/
theorem sum_val_add_one : ∑ j : Fin (m + 1), (((j : ℕ) : ℝ) + 1) = (m + 1) * ((m + 1) + 1) / 2 := by
  rw [Fin.sum_univ_eq_sum_range (fun j => ((j : ℝ) + 1)), Finset.sum_add_distrib]
  have h' := congrArg (Nat.cast : ℕ → ℝ) (Finset.sum_range_id_mul_two (m + 1))
  simp only [Nat.add_sub_cancel] at h'
  push_cast at h'
  simp only [sum_const, card_range, nsmul_eq_mul, mul_one]
  push_cast
  linarith

/-- Permuting positions does not change the sum of positions. -/
theorem sum_perm_val_add_one (σ : Equiv.Perm (Fin (m + 1))) :
    ∑ i, (((σ i : ℕ) : ℝ) + 1) = (m + 1) * ((m + 1) + 1) / 2 := by
  rw [Equiv.sum_comp σ (fun j : Fin (m + 1) => (((j : ℕ) : ℝ) + 1)), sum_val_add_one]

/-- **Uniform-marginal lemma.** With constant weights, every order costs the sham. -/
theorem orderCost_const (c : ℝ) (σ : Equiv.Perm (Fin (m + 1))) :
    orderCost (fun _ => c) σ = shamCost (fun _ : Fin (m + 1) => c) := by
  unfold orderCost shamCost
  rw [← Finset.mul_sum, sum_perm_val_add_one]
  simp only [sum_const, card_univ, Fintype.card_fin, nsmul_eq_mul]
  push_cast; ring

/-- **The cyclic sham.** Averaging any order over all `n` cyclic shifts gives the sham. -/
theorem sum_shift_orderCost (μ : Fin (m + 1) → ℝ) (σ : Equiv.Perm (Fin (m + 1))) :
    ∑ k, orderCost μ (shiftOrder σ k) = (m + 1) * shamCost μ := by
  unfold orderCost shamCost shiftOrder
  rw [Finset.sum_comm]
  have hk : ∀ i, ∑ k : Fin (m + 1), μ i * ((((σ.trans (Equiv.addRight k)) i : ℕ) : ℝ) + 1) =
      μ i * ((m + 1) * ((m + 1) + 1) / 2) := by
    intro i
    rw [← Finset.mul_sum]
    congr 1
    simp only [Equiv.trans_apply, Equiv.coe_addRight]
    exact (Equiv.sum_comp (Equiv.addLeft (σ i))
      (fun j : Fin (m + 1) => (((j : ℕ) : ℝ) + 1))).trans sum_val_add_one
  rw [Finset.sum_congr rfl (fun i _ => hk i), ← Finset.sum_mul]
  ring

/-- One cyclic step moves every position up by one, except the last which wraps to `0`. -/
theorem val_add_one_sub (x : Fin (m + 1)) :
    (((x + 1 : Fin (m + 1)) : ℕ) : ℝ) - ((x : ℕ) : ℝ) =
      1 - (m + 1) * (if x = Fin.last m then 1 else 0) := by
  rw [Fin.val_add_one]
  split_ifs with h
  · subst h; simp
  · push_cast; ring

/-- **Discrete derivative of the shifted cost.** -/
theorem shiftCost_succ_sub (μ : Fin (m + 1) → ℝ) (σ : Equiv.Perm (Fin (m + 1)))
    (k : Fin (m + 1)) :
    orderCost μ (shiftOrder σ (k + 1)) - orderCost μ (shiftOrder σ k) =
      ∑ i, μ i - (m + 1) * μ (σ.symm (Fin.last m - k)) := by
  unfold orderCost shiftOrder
  rw [← Finset.sum_sub_distrib]
  have h : ∀ i, μ i * ((((σ.trans (Equiv.addRight (k + 1))) i : ℕ) : ℝ) + 1) -
      μ i * ((((σ.trans (Equiv.addRight k)) i : ℕ) : ℝ) + 1) =
      μ i - (m + 1) * (if i = σ.symm (Fin.last m - k) then μ i else 0) := by
    intro i
    simp only [Equiv.trans_apply, Equiv.coe_addRight]
    have := val_add_one_sub (σ i + k)
    rw [← add_assoc]
    have hiff : (σ i + k = Fin.last m) ↔ (i = σ.symm (Fin.last m - k)) := by
      rw [Equiv.eq_symm_apply, eq_sub_iff_add_eq]
    have e : μ i * ((((σ i + k + 1 : Fin (m + 1)) : ℕ) : ℝ) + 1) -
        μ i * ((((σ i + k : Fin (m + 1)) : ℕ) : ℝ) + 1) =
        μ i * ((((σ i + k + 1 : Fin (m + 1)) : ℕ) : ℝ) - (((σ i + k : Fin (m + 1)) : ℕ) : ℝ)) := by
      ring
    rw [e, this]
    by_cases hc : σ i + k = Fin.last m
    · rw [if_pos hc, if_pos (hiff.mp hc)]; ring
    · rw [if_neg hc, if_neg (fun h => hc (hiff.mpr h))]; ring
  rw [Finset.sum_congr rfl (fun i _ => h i), Finset.sum_sub_distrib, ← Finset.mul_sum,
    Finset.sum_ite_eq']
  simp

/-- **Strict positional gain.** If the weights are not all equal, some cyclic shift of any
order strictly beats the sham. -/
theorem exists_shift_lt_sham (μ : Fin (m + 1) → ℝ) (σ : Equiv.Perm (Fin (m + 1)))
    (hμ : ∃ i j, μ i ≠ μ j) : ∃ k, orderCost μ (shiftOrder σ k) < shamCost μ := by
  by_contra hcon
  push_neg at hcon
  -- all shifted costs equal the sham
  have hsum := sum_shift_orderCost μ σ
  have hall : ∀ k, orderCost μ (shiftOrder σ k) = shamCost μ := by
    have h0 : ∑ k, (orderCost μ (shiftOrder σ k) - shamCost μ) = 0 := by
      rw [Finset.sum_sub_distrib, hsum]; simp
    have := (Finset.sum_eq_zero_iff_of_nonneg (fun k _ => sub_nonneg.mpr (hcon k))).mp h0
    intro k; linarith [this k (mem_univ k)]
  -- hence every weight equals the mean
  have hmean : ∀ i, (m + 1 : ℝ) * μ i = ∑ j, μ j := by
    intro i
    have := shiftCost_succ_sub μ σ (Fin.last m - σ i)
    rw [hall, hall, sub_self, sub_sub_cancel, Equiv.symm_apply_apply] at this
    linarith
  obtain ⟨i, j, hij⟩ := hμ
  have hpos : (0 : ℝ) < m + 1 := by positivity
  apply hij
  have := (hmean i).trans (hmean j).symm
  exact mul_left_cancel₀ hpos.ne' this

/-- **Separation theorem.** Some visitation order strictly beats the sham if and only if the
target's marginal over candidates is not uniform. -/
theorem positional_gain_iff (μ : Fin (m + 1) → ℝ) :
    (∃ σ : Equiv.Perm (Fin (m + 1)), orderCost μ σ < shamCost μ) ↔ ∃ i j, μ i ≠ μ j := by
  constructor
  · rintro ⟨σ, hσ⟩
    by_contra h
    push_neg at h
    have hc : μ = fun _ => μ 0 := funext (fun i => h i 0)
    rw [hc, orderCost_const] at hσ
    exact lt_irrefl _ hσ
  · intro h
    obtain ⟨k, hk⟩ := exists_shift_lt_sham μ 1 h
    exact ⟨_, hk⟩

/-- **Bayes order is optimal.** An order whose positions antivary with the weights (heavier
candidates first) minimises the expected cost among all orders. -/
theorem bayes_order_optimal (μ : Fin (m + 1) → ℝ) (σ : Equiv.Perm (Fin (m + 1)))
    (hσ : Antivary μ (fun i => ((σ i : ℕ) : ℝ) + 1)) (τ : Equiv.Perm (Fin (m + 1))) :
    orderCost μ σ ≤ orderCost μ τ := by
  unfold orderCost
  have := hσ.sum_mul_le_sum_mul_comp_perm (σ := τ.trans σ.symm)
  simpa using this

/-- **Fermat's order is the Bayes order of a balance prior.** If the target weight is
nondecreasing along the pool (mass piled up near `√N`, as for a balance-concentrated
ensemble), the sqrt-descending order `Fin.revPerm` minimises the expected cost. -/
theorem descending_optimal_of_monotone (μ : Fin (m + 1) → ℝ) (hμ : Monotone μ)
    (τ : Equiv.Perm (Fin (m + 1))) : orderCost μ Fin.revPerm ≤ orderCost μ τ := by
  apply bayes_order_optimal
  intro i j hij
  have h : (Fin.rev i : ℕ) < (Fin.rev j : ℕ) := by
    simp only [Fin.revPerm_apply] at hij
    exact_mod_cast (by linarith : (((Fin.rev i : ℕ)) : ℝ) < ((Fin.rev j : ℕ) : ℝ))
  rw [Fin.val_rev, Fin.val_rev] at h
  exact hμ (Fin.le_iff_val_le_val.mpr (by omega))

/-- Dually, the ascending (plain) order is optimal for a nonincreasing prior. -/
theorem ascending_optimal_of_antitone (μ : Fin (m + 1) → ℝ) (hμ : Antitone μ)
    (τ : Equiv.Perm (Fin (m + 1))) : orderCost μ 1 ≤ orderCost μ τ := by
  apply bayes_order_optimal
  intro i j hij
  simp only [Equiv.Perm.one_apply, add_lt_add_iff_right, Nat.cast_lt] at hij
  exact hμ (le_of_lt hij)

/-- **Strictness for a strictly increasing balance prior.** With strictly increasing weights
on at least two candidates, the descending order strictly beats the sham. -/
theorem descending_lt_sham_of_strictMono (μ : Fin (m + 2) → ℝ) (hμ : StrictMono μ) :
    orderCost μ Fin.revPerm < shamCost μ := by
  obtain ⟨σ, hσ⟩ := (positional_gain_iff μ).mpr
    ⟨0, 1, (hμ (show (0 : Fin (m + 2)) < 1 from Fin.zero_lt_one)).ne⟩
  exact lt_of_le_of_lt (descending_optimal_of_monotone μ hμ.monotone σ) hσ

end PositionalFilter