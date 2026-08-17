import MachineLearning.HyperAwareness11D.Injectivity

/-!
# Hyper-Awareness IV: rigidity at the optimum — width-`22` layers are perfectly balanced

`Injectivity.lean` shows that a lossless ReLU perception layer on `ℝ¹¹` needs at least `22`
units and that `22` suffice.  This file shows that architectures *at* the optimum are
extremely rigid: no slack is left anywhere.

## Main results

* `HyperAwareness11D.balanced_activation_at_optimum` — if an injective ReLU layer on `ℝⁿ` has
  exactly `2n` units, then there are two percepts whose active unit sets **partition** the
  units into two blocks of size exactly `n`.
* `HyperAwareness11D.every_unit_essential` — consequently *every* unit of a width-optimal
  lossless layer has a nonzero weight row: there are no dead or constant units, no
  redundancy, and no unit can be deleted.
* `HyperAwareness11D.balanced_activation_11` / `every_unit_essential_11` — the statements in
  the mission's dimension: a `22`-unit lossless 11-dimensional perception layer splits, at
  suitable antipodal percepts, into two perfectly balanced halves of `11` active units.

Interpretation: at the information-theoretic optimum the layer behaves exactly like the
canonical positive/negative split — half the units carry the "positive half" of the percept
and half carry the "negative half" — even though no such structure was assumed.
-/

namespace HyperAwareness11D

open Finset

noncomputable section

open scoped Classical

variable {ι : Type*} {n : ℕ}

/-- **Balanced activation at the optimum.**  An injective ReLU layer with exactly `2n` units
admits two percepts whose active sets are disjoint, of size exactly `n` each, and together
exhaust all units. -/
theorem balanced_activation_at_optimum [Fintype ι] (W : ι → Fin n → ℝ) (b : ι → ℝ)
    (hinj : Function.Injective (reluLayer W b)) (hcard : Fintype.card ι = 2 * n) :
    ∃ x y : Fin n → ℝ,
      (ActiveRows W b x).card = n ∧ (ActiveRows W b y).card = n ∧
      Disjoint (ActiveRows W b x) (ActiveRows W b y) ∧
      ∀ i, i ∈ ActiveRows W b x ∨ i ∈ ActiveRows W b y := by
  classical
  obtain ⟨x, y, hx, hy, hdisj⟩ := exists_antipodal_probes W b hinj
  have hunion : (ActiveRows W b x ∪ ActiveRows W b y).card
      = (ActiveRows W b x).card + (ActiveRows W b y).card :=
    Finset.card_union_of_disjoint hdisj
  have hle : (ActiveRows W b x ∪ ActiveRows W b y).card ≤ Fintype.card ι :=
    Finset.card_le_univ _
  have hcx : (ActiveRows W b x).card = n := by omega
  have hcy : (ActiveRows W b y).card = n := by omega
  refine ⟨x, y, hcx, hcy, hdisj, ?_⟩
  have huniv : ActiveRows W b x ∪ ActiveRows W b y = Finset.univ := by
    refine Finset.eq_univ_of_card _ ?_
    omega
  intro i
  have : i ∈ ActiveRows W b x ∪ ActiveRows W b y := by rw [huniv]; exact Finset.mem_univ i
  exact Finset.mem_union.mp this

/-- **No redundancy at the optimum.**  Every unit of a width-optimal lossless layer genuinely
depends on the input: its weight row is nonzero.  In particular no unit is a constant
detector and no unit can be removed. -/
theorem every_unit_essential [Fintype ι] (W : ι → Fin n → ℝ) (b : ι → ℝ)
    (hinj : Function.Injective (reluLayer W b)) (hcard : Fintype.card ι = 2 * n) (i : ι) :
    ∃ j, W i j ≠ 0 := by
  classical
  obtain ⟨x, y, -, -, -, hun⟩ := balanced_activation_at_optimum W b hinj hcard
  rcases hun i with h | h <;>
    · simp only [ActiveRows, Finset.mem_filter] at h
      exact h.2.2

/-- The balanced activation theorem in the mission's dimension: a `22`-unit lossless
11-dimensional perception layer splits into two blocks of exactly `11` active units. -/
theorem balanced_activation_11 (W : Fin 22 → Fin 11 → ℝ) (b : Fin 22 → ℝ)
    (hinj : Function.Injective (reluLayer W b)) :
    ∃ x y : Fin 11 → ℝ,
      (ActiveRows W b x).card = 11 ∧ (ActiveRows W b y).card = 11 ∧
      Disjoint (ActiveRows W b x) (ActiveRows W b y) ∧
      ∀ i, i ∈ ActiveRows W b x ∨ i ∈ ActiveRows W b y :=
  balanced_activation_at_optimum W b hinj (by simp)

/-- Every one of the `22` units of an optimal lossless 11-dimensional perception layer is
essential. -/
theorem every_unit_essential_11 (W : Fin 22 → Fin 11 → ℝ) (b : Fin 22 → ℝ)
    (hinj : Function.Injective (reluLayer W b)) (i : Fin 22) :
    ∃ j, W i j ≠ 0 :=
  every_unit_essential W b hinj (by simp) i

/-- The canonical optimum realises the balanced pattern concretely: at an all-positive
percept the active units are exactly the "positive half" of the split layer. -/
theorem doubleW_activeRows_pos (x : Fin n → ℝ) (hx : ∀ i, 0 < x i) (i : Fin n ⊕ Fin n) :
    i ∈ ActiveRows (doubleW n) 0 x ↔ ∃ k, i = Sum.inl k := by
  classical
  simp only [ActiveRows, Finset.mem_filter, Finset.mem_univ, true_and]
  cases i with
  | inl k =>
    constructor
    · intro _; exact ⟨k, rfl⟩
    · intro _
      refine ⟨by simpa [preAct_doubleW_inl] using hx k, ⟨k, ?_⟩⟩
      simp [doubleW]
  | inr k =>
    constructor
    · rintro ⟨hpos, -⟩
      rw [preAct_doubleW_inr] at hpos
      exact absurd hpos (by simpa using (hx k).le)
    · rintro ⟨k', hk'⟩
      exact absurd hk' (by simp)

end

end HyperAwareness11D