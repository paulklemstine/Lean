import MachineLearning.HyperAwareness11D.BalancedFrame

/-!
# Hyper-Awareness VI: depth, and 11-dimensional tensor percepts

Two architectural consequences of the width theorem of `Injectivity.lean`.

## Depth cannot repair a narrow first layer

* `HyperAwareness11D.no_injective_network_of_narrow_first_layer` — *no* network on `ℝ¹¹`,
  however deep and however wide its later layers, can be lossless if its first hidden layer
  has fewer than `22` ReLU units.  Information destroyed at the input interface is gone.
* `HyperAwareness11D.deep_split_injective` — conversely, stacking optimal split layers keeps
  the network lossless at every depth, so `22` units in the first layer are not only
  necessary but also compatible with arbitrary depth.

## Order-`k` 11-dimensional tensors

An order-`k` percept is an element of `(Fin k → Fin 11) → ℝ`, the `k`-fold tensor power of
the 11-dimensional percept space, of dimension `11 ^ k`.

* `HyperAwareness11D.tensor_width_bound` — a lossless ReLU layer on order-`k`
  11-dimensional tensors needs at least `2 · 11 ^ k` units, and
* `HyperAwareness11D.tensor_width_bound_attained` — that many always suffice.

So the cost of lossless "hyper-aware" tensor processing is exactly twice the tensor
dimension: `22` for vectors, `242` for matrices, `2662` for order-3 percepts.
-/

namespace HyperAwareness11D

open Finset

noncomputable section

open scoped Classical

variable {ι : Type*} {n : ℕ}

/-! ## Depth -/

/-- **A narrow first layer is fatal, at any depth.**  If the first hidden layer of a network
on `ℝ¹¹` has fewer than `22` ReLU units then the whole network — whatever the later layers
`g` compute — identifies two distinct percepts. -/
theorem no_injective_network_of_narrow_first_layer [Fintype ι] {α : Type*}
    (W : ι → Fin 11 → ℝ) (b : ι → ℝ) (hcard : Fintype.card ι < 22) (g : (ι → ℝ) → α) :
    ¬ Function.Injective (g ∘ reluLayer W b) := by
  intro hinj
  have hlayer : Function.Injective (reluLayer W b) := by
    intro x y hxy
    exact hinj (by simp [Function.comp, hxy])
  exact no_injective_layer_of_card_lt W b hcard hlayer

/-- Stacking two optimal split layers `ℝⁿ → ℝ^{2n} → ℝ^{4n}` stays lossless. -/
theorem deep_split_injective :
    Function.Injective
      (fun x : Fin n → ℝ =>
        reluLayer (doubleW (2 * n)) 0
          (fun i => reluLayer (doubleW n) 0 x (finSumFinEquiv.symm
            ((Fin.cast (by ring) i : Fin (n + n)))))) := by
  intro x y hxy
  apply doubleLayer_injective (n := n)
  funext i
  -- undo the outer (injective) split layer, then read off the inner layer at index `i`
  have houter : Function.Injective (reluLayer (doubleW (2 * n)) 0) := doubleLayer_injective
  have hmid := houter hxy
  have hk := congrFun hmid (Fin.cast (by ring) (finSumFinEquiv i))
  simpa using hk

/-! ## Order-`k` tensor percepts -/

/-- The dimension of the space of order-`k` 11-dimensional percept tensors. -/
lemma card_tensor_index (k : ℕ) : Fintype.card (Fin k → Fin 11) = 11 ^ k := by
  simp

/-- **Lossless order-`k` tensor processing needs `2 · 11 ^ k` units.** -/
theorem tensor_width_bound [Fintype ι] (k : ℕ) (W : ι → Fin (11 ^ k) → ℝ) (b : ι → ℝ)
    (hinj : Function.Injective (reluLayer W b)) :
    2 * 11 ^ k ≤ Fintype.card ι :=
  two_mul_le_card_of_injective W b hinj

/-- ... and `2 · 11 ^ k` units always suffice. -/
theorem tensor_width_bound_attained (k : ℕ) :
    ∃ (W : (Fin (11 ^ k) ⊕ Fin (11 ^ k)) → Fin (11 ^ k) → ℝ)
      (b : (Fin (11 ^ k) ⊕ Fin (11 ^ k)) → ℝ),
      Function.Injective (reluLayer W b) ∧
      Fintype.card (Fin (11 ^ k) ⊕ Fin (11 ^ k)) = 2 * 11 ^ k :=
  ⟨doubleW (11 ^ k), 0, doubleLayer_injective, by simp [two_mul]⟩

/-- Order-2 (matrix) percepts: `242` units; order-3 percepts: `2662` units. -/
example : 2 * 11 ^ 2 = 242 ∧ 2 * 11 ^ 3 = 2662 := by norm_num

end

end HyperAwareness11D