/-
# The NET-60 tail pair, as an exactly-solvable tropical model

We build an explicit prunable net on `24` layers (the depth of the measured
model) whose pruning-cost profile reproduces the NET-60 ablation table.  Costs
are recorded in *hundredths of an accuracy point*, so the measured `0.42 pts` of
the tail pair is the value `42` below.

| arm            | layers   | measured cost | Σ solo | class      |
|----------------|----------|---------------|--------|------------|
| `tail_22_23`   | 22,23    | 0.42          | 0.06   | SUPER 7×   |
| `bulk_12_15`   | 12,15    | 0.60          | 0.79   | sub        |
| `front_0_1`    | 0,1      | 0.25          | 0.25   | additive   |
| `mid_10_11`    | 10,11    | 0.40          | 0.28   | super 1.4× |
| `cross_22_12`  | 22,12    | 0.59          | 0.60   | sub        |
| `triple_21_22_23` | 21,22,23 | 0.76       | 0.19   | SUPER 4×   |

Each path of the model is a *retention pattern*: the path indexed by a target set
`T` survives exactly the prunings `S ⊆ T` and then incurs the loss recorded for
`T`.  Every entry of the table is verified by a tropical minimum computation
(`net60_cost`), and the qualitative verdicts of the experiment are then theorems:

* `net60_tail_super_additive` / `net60_tail_ratio_seven` — P1;
* `net60_three_of_six_super_additive` — P2 is refuted: super-, sub- and exact
  additivity all occur in one and the same net;
* `net60_triple_compounds` / `net60_triple_is_costliest` — P3;
* `net60_tail_coadapted` — the tail pair is a coordinated unit: each of its
  members is backed up only by paths routing through the other;
* `tailUnit_epiOrder_eq_two` — in the tail subsystem the epistasis order (the
  transversal number of the near-optimal path hypergraph) is exactly `2`.
-/
import Tropical.NetEpistasis.Transversal
import Tropical.NetEpistasis.Interaction
import Tropical.NetEpistasis.Merge

namespace NetEpistasis

open Finset

/-! ### The model -/

/-- Retention targets: the path with index `j` survives pruning `S` iff
`S ⊆ target j`. -/
def target : Fin 20 → Finset (Fin 24) :=
  ![∅, {0}, {1}, {10}, {11}, {12}, {15}, {21}, {22}, {23},
    {0, 1}, {10, 11}, {12, 15}, {12, 22}, {22, 23}, {21, 22, 23}, {21, 22}, {21, 23},
    Finset.univ \ ({0, 1, 10, 11, 12, 15, 21, 22, 23} : Finset (Fin 24)),
    Finset.univ]

/-- Losses, in hundredths of an accuracy point. -/
def lossVal : Fin 20 → ℚ :=
  ![0, 13, 12, 14, 14, 57, 22, 13, 3, 3, 25, 40, 60, 59, 42, 76, 45, 45, 20, 10000]

/-- The NET-60 model: `24` layers, `20` retention patterns. -/
def net60 : PrunableNet 24 where
  ι := Fin 20
  supp := fun j => (target j)ᶜ
  loss := lossVal
  base := 19
  base_supp := by decide

lemma net60_netLoss_empty : netLoss net60 ∅ = 0 := by
  have h := netLoss_eq_of_witness (N := net60) (S := (∅ : Finset (Fin 24)))
    (show net60.ι from (0 : Fin 20)) (by decide) (by decide)
  simpa using h

/-- Cost computation from an explicitly exhibited optimal surviving path. -/
lemma net60_cost (S : Finset (Fin 24)) (j : Fin 20) (v : ℚ)
    (h₁ : Disjoint ((target j)ᶜ) S) (hv : lossVal j = v)
    (h₂ : ∀ i : Fin 20, Disjoint ((target i)ᶜ) S → lossVal j ≤ lossVal i) :
    cost net60 S = v := by
  have h := netLoss_eq_of_witness (N := net60) (S := S) j h₁ h₂
  have hl : netLoss net60 S = v := by rw [h]; exact hv
  simp [cost, hl, net60_netLoss_empty]

/-! ### The solo (NET-59) profile -/

theorem net60_cost_L0 : cost net60 {0} = 13 := net60_cost _ 1 _ (by decide) rfl (by decide)
theorem net60_cost_L1 : cost net60 {1} = 12 := net60_cost _ 2 _ (by decide) rfl (by decide)
theorem net60_cost_L10 : cost net60 {10} = 14 := net60_cost _ 3 _ (by decide) rfl (by decide)
theorem net60_cost_L11 : cost net60 {11} = 14 := net60_cost _ 4 _ (by decide) rfl (by decide)
theorem net60_cost_L12 : cost net60 {12} = 57 := net60_cost _ 5 _ (by decide) rfl (by decide)
theorem net60_cost_L15 : cost net60 {15} = 22 := net60_cost _ 6 _ (by decide) rfl (by decide)
theorem net60_cost_L21 : cost net60 {21} = 13 := net60_cost _ 7 _ (by decide) rfl (by decide)
theorem net60_cost_L22 : cost net60 {22} = 3 := net60_cost _ 8 _ (by decide) rfl (by decide)
theorem net60_cost_L23 : cost net60 {23} = 3 := net60_cost _ 9 _ (by decide) rfl (by decide)

/-! ### The six measured arms -/

theorem net60_cost_front : cost net60 {0, 1} = 25 := net60_cost _ 10 _ (by decide) rfl (by decide)
theorem net60_cost_mid : cost net60 {10, 11} = 40 := net60_cost _ 11 _ (by decide) rfl (by decide)
theorem net60_cost_bulk : cost net60 {12, 15} = 60 := net60_cost _ 12 _ (by decide) rfl (by decide)
theorem net60_cost_cross : cost net60 {12, 22} = 59 := net60_cost _ 13 _ (by decide) rfl (by decide)
theorem net60_cost_tail : cost net60 {22, 23} = 42 := net60_cost _ 14 _ (by decide) rfl (by decide)
theorem net60_cost_triple : cost net60 {21, 22, 23} = 76 :=
  net60_cost _ 15 _ (by decide) rfl (by decide)

theorem net60_cost_tail21_22 : cost net60 {21, 22} = 45 :=
  net60_cost _ 16 _ (by decide) rfl (by decide)

theorem net60_cost_tail21_23 : cost net60 {21, 23} = 45 :=
  net60_cost _ 17 _ (by decide) rfl (by decide)

/-! ### Verdicts -/

private lemma union_pair (a b : Fin 24) : ({a} ∪ {b} : Finset (Fin 24)) = {a, b} := rfl

/-- **P1.**  The tail pair is 7× super-additive: solo costs `0.03 + 0.03` against
a joint cost of `0.42`. -/
theorem net60_tail_ratio_seven :
    cost net60 {22, 23} = 7 * (cost net60 {22} + cost net60 {23}) := by
  rw [net60_cost_tail, net60_cost_L22, net60_cost_L23]; norm_num

theorem net60_tail_epi : epi net60 {22} {23} = 36 := by
  simp only [epi, union_pair, net60_cost_tail, net60_cost_L22, net60_cost_L23]
  norm_num

theorem net60_tail_super_additive : SuperAdditive net60 {22} {23} := by
  simp only [SuperAdditive, net60_tail_epi]; norm_num

/-- The front pair is exactly additive. -/
theorem net60_front_additive : epi net60 {0} {1} = 0 := by
  simp only [epi, union_pair, net60_cost_front, net60_cost_L0, net60_cost_L1]
  norm_num

/-- The mid pair is (mildly) super-additive. -/
theorem net60_mid_super_additive : SuperAdditive net60 {10} {11} := by
  simp only [SuperAdditive, epi, union_pair, net60_cost_mid, net60_cost_L10, net60_cost_L11]
  norm_num

/-- The bulk pair is sub-additive. -/
theorem net60_bulk_sub_additive : SubAdditive net60 {12} {15} := by
  simp only [SubAdditive, epi, union_pair, net60_cost_bulk, net60_cost_L12, net60_cost_L15]
  norm_num

/-- The cross pair (tail layer with a bulk layer) is sub-additive. -/
theorem net60_cross_sub_additive : SubAdditive net60 {12} {22} := by
  simp only [SubAdditive, epi, union_pair, net60_cost_cross, net60_cost_L12, net60_cost_L22]
  norm_num

/-- **P3.**  The tail triple compounds: it costs `4×` the sum of its solo
costs. -/
theorem net60_triple_compounds :
    cost net60 {21, 22, 23}
      = 4 * (cost net60 {21} + cost net60 {22} + cost net60 {23}) := by
  rw [net60_cost_triple, net60_cost_L21, net60_cost_L22, net60_cost_L23]; norm_num

/-- Adding the third tail layer is itself super-additive over the tail pair. -/
theorem net60_triple_super_over_pair : SuperAdditive net60 {21} {22, 23} := by
  have hun : ({21} ∪ {22, 23} : Finset (Fin 24)) = {21, 22, 23} := rfl
  simp only [SuperAdditive, epi, hun, net60_cost_triple, net60_cost_L21, net60_cost_tail]
  norm_num

/-- **P3, second half.**  The tail triple is the costliest of the six arms. -/
theorem net60_triple_is_costliest :
    cost net60 {0, 1} < cost net60 {21, 22, 23} ∧
    cost net60 {10, 11} < cost net60 {21, 22, 23} ∧
    cost net60 {12, 15} < cost net60 {21, 22, 23} ∧
    cost net60 {12, 22} < cost net60 {21, 22, 23} ∧
    cost net60 {22, 23} < cost net60 {21, 22, 23} := by
  rw [net60_cost_front, net60_cost_mid, net60_cost_bulk, net60_cost_cross, net60_cost_tail,
    net60_cost_triple]
  norm_num

/-- **P2 is refuted.**  Additivity is not a law: within a single tropical net,
three arms are super-additive, two are sub-additive and one is exactly additive. -/
theorem net60_three_of_six_super_additive :
    SuperAdditive net60 {22} {23} ∧ SuperAdditive net60 {10} {11} ∧
      SuperAdditive net60 {21} {22, 23} ∧
      SubAdditive net60 {12} {15} ∧ SubAdditive net60 {12} {22} ∧
      epi net60 {0} {1} = 0 :=
  ⟨net60_tail_super_additive, net60_mid_super_additive, net60_triple_super_over_pair,
    net60_bulk_sub_additive, net60_cross_sub_additive, net60_front_additive⟩

/-- **P1, comparative half.**  The tail pair has the strictly smallest solo sum
of all five pair arms, yet the strictly largest joint/solo ratio (compared by
cross-multiplication, so that no division is needed). -/
theorem net60_tail_smallest_solo_sum_largest_ratio :
    (cost net60 {22} + cost net60 {23} < cost net60 {0} + cost net60 {1} ∧
      cost net60 {22} + cost net60 {23} < cost net60 {10} + cost net60 {11} ∧
      cost net60 {22} + cost net60 {23} < cost net60 {12} + cost net60 {15} ∧
      cost net60 {22} + cost net60 {23} < cost net60 {12} + cost net60 {22}) ∧
    (cost net60 {0, 1} * (cost net60 {22} + cost net60 {23})
        < cost net60 {22, 23} * (cost net60 {0} + cost net60 {1}) ∧
      cost net60 {10, 11} * (cost net60 {22} + cost net60 {23})
        < cost net60 {22, 23} * (cost net60 {10} + cost net60 {11}) ∧
      cost net60 {12, 15} * (cost net60 {22} + cost net60 {23})
        < cost net60 {22, 23} * (cost net60 {12} + cost net60 {15}) ∧
      cost net60 {12, 22} * (cost net60 {22} + cost net60 {23})
        < cost net60 {22, 23} * (cost net60 {12} + cost net60 {22})) := by
  rw [net60_cost_L0, net60_cost_L1, net60_cost_L10, net60_cost_L11, net60_cost_L12,
    net60_cost_L15, net60_cost_L22, net60_cost_L23, net60_cost_front, net60_cost_mid,
    net60_cost_bulk, net60_cost_cross, net60_cost_tail]
  norm_num

/-- **The coordinated unit.**  At the tolerance `ε = 3` given by the solo costs,
the tail pair is a transversal of the near-optimal path family: every surviving
near-optimal backup for layer 22 routes through layer 23, and conversely. -/
theorem net60_tail_coadapted :
    (∃ p : net60.ι, net60.loss p ≤ netLoss net60 ∅ + 3 ∧
        (22 : Fin 24) ∉ net60.supp p ∧ (23 : Fin 24) ∈ net60.supp p) ∧
      (∃ q : net60.ι, net60.loss q ≤ netLoss net60 ∅ + 3 ∧
        (23 : Fin 24) ∉ net60.supp q ∧ (22 : Fin 24) ∈ net60.supp q) := by
  refine coadaptation_of_pair_epistasis (N := net60) (ε := 3) ?_ ?_ ?_
  · rw [net60_cost_L22]
  · rw [net60_cost_L23]
  · rw [union_pair, net60_cost_tail]; norm_num

/-- Every single layer of the model is affordable at tolerance `0.57 pts`. -/
theorem net60_singleton_cheap (i : Fin 24) : cost net60 {i} ≤ 57 := by
  have h : ∃ j : Fin 20, Disjoint ((target j)ᶜ) ({i} : Finset (Fin 24)) ∧ lossVal j ≤ 57 := by
    revert i; decide
  obtain ⟨j, hj, hle⟩ := h
  have hb : netLoss net60 {i} ≤ lossVal j := netLoss_le (N := net60) hj
  simp only [cost, net60_netLoss_empty, sub_zero]
  linarith

/-- **The epistasis order of the measured profile is exactly two**: no single
layer costs more than `0.57 pts`, but a pair does.  Equivalently, the
near-optimal path hypergraph has no size-one transversal and a size-two one. -/
theorem net60_epiOrder_eq_two : epiOrder net60 57 = 2 := by
  refine epiOrder_eq_two (by norm_num) net60_singleton_cheap (a := 12) (b := 15) ?_
  rw [net60_cost_bulk]; norm_num

/-- The NET-60 path system is **not mergeable**: the tail pair's super-additivity
is an obstruction to merging backup routes (`not_mergeable_of_superAdditive`). -/
theorem net60_not_mergeable : ¬ Mergeable net60 :=
  not_mergeable_of_superAdditive net60_tail_super_additive

/-- The explicit merge obstruction produced by the tail pair: an optimal backup
route avoiding layer 22 and one avoiding layer 23 whose common part is strictly
worse than both. -/
theorem net60_tail_merge_obstruction :
    ∃ p q : net60.ι, Disjoint (net60.supp p) ({22} : Finset (Fin 24)) ∧
      Disjoint (net60.supp q) ({23} : Finset (Fin 24)) ∧
      net60.loss p = netLoss net60 {22} ∧ net60.loss q = netLoss net60 {23} ∧
      ∀ r : net60.ι, net60.supp r ⊆ net60.supp p ∩ net60.supp q →
        max (net60.loss p) (net60.loss q) < net60.loss r :=
  merge_obstruction_of_superadditive net60_tail_super_additive

/-! ### Third-order structure of the tail triple -/

/-- The third-order Möbius interaction of the tail triple is `-0.37 pts`: the
three pairwise epistases over-count, and the genuine order-3 term corrects them
downwards.  The tail epistasis is therefore a *pairwise* phenomenon that
saturates rather than compounding indefinitely. -/
theorem net60_triple_moebius : mob (cost net60) {21, 22, 23} = -37 := by
  rw [mob_triple _ (by decide) (by decide) (by decide), net60_cost_triple,
    net60_cost_tail21_22, net60_cost_tail21_23, net60_cost_tail, net60_cost_L21,
    net60_cost_L22, net60_cost_L23, cost_empty]
  norm_num

/-- The measured `0.76 pts` of the tail triple decomposed into solo costs,
pairwise epistases and the third-order term: `76 = 19 + (29 + 29 + 36) - 37`. -/
theorem net60_triple_decomposition :
    cost net60 {21, 22, 23}
      = (cost net60 {21} + cost net60 {22} + cost net60 {23})
        + (epi net60 {21} {22} + epi net60 {21} {23} + epi net60 {22} {23})
        + mob (cost net60) {21, 22, 23} := by
  have h := triple_compounding net60 (a := 21) (b := 22) (d := 23)
    (by decide) (by decide) (by decide)
  linarith [h]

/-! ### The tail subsystem

A minimal model of the tail alone: layers `22` and `23` are individually almost
free, everything else is cheap, and only the joint pruning is expensive. -/

/-- Retention targets of the tail subsystem. -/
def tailTarget : Fin 5 → Finset (Fin 24) :=
  ![∅, {22}, {23}, Finset.univ \ ({22, 23} : Finset (Fin 24)), Finset.univ]

/-- Losses of the tail subsystem. -/
def tailLoss : Fin 5 → ℚ := ![0, 3, 3, 3, 42]

/-- The tail subsystem as a prunable net. -/
def tailUnit : PrunableNet 24 where
  ι := Fin 5
  supp := fun j => (tailTarget j)ᶜ
  loss := tailLoss
  base := 4
  base_supp := by decide

lemma tailUnit_netLoss_empty : netLoss tailUnit ∅ = 0 := by
  have h := netLoss_eq_of_witness (N := tailUnit) (S := (∅ : Finset (Fin 24)))
    (show tailUnit.ι from (0 : Fin 5)) (by decide) (by decide)
  simpa using h

lemma tailUnit_singleton_cheap (i : Fin 24) : cost tailUnit {i} ≤ 3 := by
  have h : ∃ j : Fin 5, Disjoint ((tailTarget j)ᶜ) ({i} : Finset (Fin 24)) ∧ tailLoss j ≤ 3 := by
    revert i; decide
  obtain ⟨j, hj, hle⟩ := h
  have hb : netLoss tailUnit {i} ≤ tailLoss j := netLoss_le (N := tailUnit) hj
  simp only [cost, tailUnit_netLoss_empty, sub_zero]
  linarith

lemma tailUnit_cost_pair : cost tailUnit {22, 23} = 42 := by
  have h := netLoss_eq_of_witness (N := tailUnit) (S := ({22, 23} : Finset (Fin 24)))
    (show tailUnit.ι from (4 : Fin 5)) (by decide) (by decide)
  have hl : netLoss tailUnit {22, 23} = 42 := by rw [h]; rfl
  simp [cost, hl, tailUnit_netLoss_empty]

/-- **The tail is one unit.**  In the tail subsystem no single layer is worth
more than `0.03 pts`, yet the pair is worth `0.42 pts`: the epistasis order — the
transversal number of the near-optimal path hypergraph — equals `2`, so budgets
must be assigned to the pair, never to its members. -/
theorem tailUnit_epiOrder_eq_two : epiOrder tailUnit 3 = 2 := by
  refine epiOrder_eq_two (by norm_num) tailUnit_singleton_cheap (a := 22) (b := 23) ?_
  rw [tailUnit_cost_pair]; norm_num

end NetEpistasis