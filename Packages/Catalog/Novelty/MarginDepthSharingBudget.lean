import Novelty.KVDecisionDissociation

/-!
# The margin–depth sharing budget (NET-51, Part E)

Cycle 2 of the NET-51 thread closes conjecture **C1**: combine the divergence
recursion of `LayerDivergenceHump` with the margin certificate of
`KVDecisionDissociation` into a *depth budget* that says how deep a shared KV core
can run before decisions are no longer guaranteed to agree.

Let `Lip k` be the Lipschitz constant of layer `k` of the shared stack and `eps`
the per-layer fine-tune delta budget.  The **error budget**

```
budget 0       = 0
budget (k+1)   = Lip k * budget k + eps
```

dominates the true divergence (`divergence_le_budget`).  A layer is *certifiably
shareable* when its top-1 margin exceeds twice its budget
(`Shareable`), and then the two models provably agree there
(`agreement_of_shareable`).

Two structural facts follow:

* `shareable_downward_closed` — if the layers are non-contracting (`1 ≤ Lip k`)
  and the margin profile is non-increasing in depth, the shareable layers form an
  **initial segment**: sharing is a prefix property, exactly the empirically
  observed "core shared / tail personal" shape.
* `budget_le_linear` and `shareable_of_depth_lt` — for nonexpansive layers the
  budget is `k * eps`, so with margin `m` every layer of depth `k < m / (2 eps)`
  is shareable.  With the NET-51 numbers (`eps = 0.01`, margin `0.5`) this is
  every layer up to depth `24`.
-/

namespace Catalog.Novelty.MarginDepthSharingBudget

open Catalog.Novelty.KVDecisionDissociation

/-- The accumulated error budget of a shared core: a layerwise Lipschitz
amplification of the previous budget plus a fresh delta injection. -/
def budget (Lip : ℕ → ℝ) (eps : ℝ) : ℕ → ℝ
  | 0 => 0
  | k + 1 => Lip k * budget Lip eps k + eps

@[simp] theorem budget_zero (Lip : ℕ → ℝ) (eps : ℝ) : budget Lip eps 0 = 0 := rfl

@[simp] theorem budget_succ (Lip : ℕ → ℝ) (eps : ℝ) (k : ℕ) :
    budget Lip eps (k + 1) = Lip k * budget Lip eps k + eps := rfl

theorem budget_nonneg (Lip : ℕ → ℝ) (eps : ℝ) (hLip : ∀ k, 0 ≤ Lip k) (heps : 0 ≤ eps) :
    ∀ k, 0 ≤ budget Lip eps k := by
  intro k
  induction k with
  | zero => simp
  | succ m ih =>
      rw [budget_succ]
      have := mul_nonneg (hLip m) ih
      linarith

/-- The budget dominates any divergence sequence obeying the same recursion
inequality and starting from an exactly shared input. -/
theorem divergence_le_budget (d : ℕ → ℝ) (Lip : ℕ → ℝ) (eps : ℝ)
    (hLip : ∀ k, 0 ≤ Lip k) (hd0 : d 0 = 0)
    (hrec : ∀ k, d (k + 1) ≤ Lip k * d k + eps) :
    ∀ k, d k ≤ budget Lip eps k := by
  intro k
  induction k with
  | zero => simp [hd0]
  | succ m ih =>
      have h1 : Lip m * d m ≤ Lip m * budget Lip eps m :=
        mul_le_mul_of_nonneg_left ih (hLip m)
      have h2 := hrec m
      rw [budget_succ]
      linarith

/-- For nonexpansive shared layers the budget is exactly linear in depth. -/
theorem budget_le_linear (Lip : ℕ → ℝ) (eps : ℝ) (heps : 0 ≤ eps)
    (hLip : ∀ k, Lip k ≤ 1) (hLip0 : ∀ k, 0 ≤ Lip k) :
    ∀ k, budget Lip eps k ≤ k * eps := by
  intro k
  induction k with
  | zero => simp
  | succ m ih =>
      have hb : 0 ≤ budget Lip eps m := budget_nonneg Lip eps hLip0 heps m
      have h1 : Lip m * budget Lip eps m ≤ 1 * budget Lip eps m :=
        mul_le_mul_of_nonneg_right (hLip m) hb
      have h2 : budget Lip eps m ≤ m * eps := ih
      rw [budget_succ]
      push_cast
      linarith

/-- The budget is non-decreasing in depth once no layer contracts. -/
theorem budget_mono (Lip : ℕ → ℝ) (eps : ℝ) (heps : 0 ≤ eps) (hLip : ∀ k, 1 ≤ Lip k) :
    ∀ k l, k ≤ l → budget Lip eps k ≤ budget Lip eps l := by
  have hLip0 : ∀ k, 0 ≤ Lip k := fun k => le_trans zero_le_one (hLip k)
  intro k l hkl
  induction l, hkl using Nat.le_induction with
  | base => exact le_rfl
  | succ p hkp ih =>
      have hb : 0 ≤ budget Lip eps p := budget_nonneg Lip eps hLip0 heps p
      have h1 : 1 * budget Lip eps p ≤ Lip p * budget Lip eps p :=
        mul_le_mul_of_nonneg_right (hLip p) hb
      rw [budget_succ]
      linarith

/-- A layer is *certifiably shareable* when its top-1 margin at the chosen index
exceeds twice the accumulated error budget of the core up to that depth. -/
def Shareable (margin : ℕ → ℝ) (Lip : ℕ → ℝ) (eps : ℝ) (k : ℕ) : Prop :=
  2 * budget Lip eps k < margin k

/-- **Agreement on shareable layers.**  If layer `k` is shareable and the base
model's scores there have margin at least `margin k`, then the fine-tuned model
reproduces the base model's decision at that layer. -/
theorem agreement_of_shareable {n : ℕ} (u v : ℕ → Fin n → ℝ) (i : ℕ → Fin n)
    (margin : ℕ → ℝ) (Lip : ℕ → ℝ) (eps : ℝ) (d : ℕ → ℝ) (k : ℕ)
    (hLip : ∀ k, 0 ≤ Lip k) (hd0 : d 0 = 0)
    (hrec : ∀ k, d (k + 1) ≤ Lip k * d k + eps)
    (hmargin : ∀ j, j ≠ i k → margin k ≤ u k (i k) - u k j)
    (hclose : ∀ j, |u k j - v k j| ≤ d k)
    (hshare : Shareable margin Lip eps k) :
    IsStrictTop (v k) (i k) := by
  have hdk : d k ≤ budget Lip eps k := divergence_le_budget d Lip eps hLip hd0 hrec k
  refine strictTop_of_margin (u k) (v k) (i k) (budget Lip eps k) ?_ ?_
  · intro j hj
    have := hmargin j hj
    have hs : 2 * budget Lip eps k < margin k := hshare
    linarith
  · intro j
    exact le_trans (hclose j) hdk

/-- **Sharing is a prefix property.**  With non-contracting layers and a margin
profile that does not increase with depth, the certifiably shareable layers form
an initial segment: the core is shareable and the tail is not, never the reverse. -/
theorem shareable_downward_closed (margin : ℕ → ℝ) (Lip : ℕ → ℝ) (eps : ℝ)
    (heps : 0 ≤ eps) (hLip : ∀ k, 1 ≤ Lip k)
    (hmargin : ∀ k l, k ≤ l → margin l ≤ margin k)
    (k l : ℕ) (hkl : k ≤ l) (h : Shareable margin Lip eps l) :
    Shareable margin Lip eps k := by
  have hb : budget Lip eps k ≤ budget Lip eps l := budget_mono Lip eps heps hLip k l hkl
  have hm : margin l ≤ margin k := hmargin k l hkl
  have : 2 * budget Lip eps l < margin l := h
  unfold Shareable
  linarith

/-- **Depth law.**  For nonexpansive layers, every layer shallower than
`margin / (2 eps)` is shareable. -/
theorem shareable_of_depth_lt (margin : ℕ → ℝ) (Lip : ℕ → ℝ) (eps : ℝ)
    (heps : 0 < eps) (hLip1 : ∀ k, Lip k ≤ 1) (hLip0 : ∀ k, 0 ≤ Lip k)
    (k : ℕ) (hk : 2 * (k * eps) < margin k) :
    Shareable margin Lip eps k := by
  have hb := budget_le_linear Lip eps heps.le hLip1 hLip0 k
  unfold Shareable
  linarith

/-- The NET-51 configuration: per-layer delta `eps = 0.01`, nonexpansive layers,
uniform margin `0.5`.  Every layer of depth at most `24` is certifiably
shareable — and the bound is tight at depth `25`. -/
theorem net51_depth_budget (Lip : ℕ → ℝ) (hLip1 : ∀ k, Lip k ≤ 1) (hLip0 : ∀ k, 0 ≤ Lip k)
    (k : ℕ) (hk : k ≤ 24) :
    Shareable (fun _ => 1 / 2) Lip (1 / 100) k := by
  refine shareable_of_depth_lt _ Lip (1 / 100) (by norm_num) hLip1 hLip0 k ?_
  have hk' : (k : ℝ) ≤ 24 := by exact_mod_cast hk
  norm_num
  linarith

/-- With identity Lipschitz constants the budget is exactly `k * eps`. -/
theorem budget_const_one (eps : ℝ) : ∀ k, budget (fun _ => 1) eps k = k * eps := by
  intro k
  induction k with
  | zero => simp
  | succ m ih => rw [budget_succ, ih]; push_cast; ring

/-- Tightness of `net51_depth_budget`: at depth `25` the certificate fails, so the
depth bound `24` cannot be improved. -/
theorem net51_depth_budget_tight :
    ¬ Shareable (fun _ => 1 / 2) (fun _ => 1) (1 / 100) 25 := by
  unfold Shareable
  rw [budget_const_one]
  norm_num

end Catalog.Novelty.MarginDepthSharingBudget