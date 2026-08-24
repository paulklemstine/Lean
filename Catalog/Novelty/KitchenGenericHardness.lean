import Novelty.KitchenQueryComplexity

/-!
# Generic hardness in the kitchen, and the value of adaptivity

Second research cycle on the query model of `Novelty.KitchenQueryComplexity`.

The first cycle showed that individual dishes span the whole range of verification costs.
This file asks the *generic* question — how hard is a random recipe? — and the *structural*
question — is adaptive tasting really stronger than a fixed tasting checklist?

Main results.

* `card_quickDishes_succ_le`: the counting recursion `c_{d+1} ≤ 2 + n · c_d²` for the number
  `c_d` of dishes verifiable with `d` probes.  It comes from a genuine structure theorem
  (`tasteCost_succ_decomp`): a `(d+1)`-quick dish is a constant or a probe-and-branch of two
  `d`-quick dishes.
* `card_quickDishes_le`: solving the recursion, `c_d ≤ (6n)^(2^d)`.
* `exists_hard_dish`, `most_dishes_hard`: a doubly exponential counting argument against the
  doubly exponential number `2^(2^n)` of dishes.  **Almost every recipe is a soufflé**: for
  `n = 16` ingredients at least half of all dishes need more than `7` taste probes
  (`most_dishes_hard_16`).  Quick recipes are not merely rare, they are a measure-zero
  accident.
* `mux`, `tasteCost_mux`, `relevantSet_mux`, `adaptivity_gap`: an unconditional *adaptivity
  gap*.  The dish "if the sauce is on, judge by the fish, otherwise by the soup" needs a
  fixed tasting checklist of all three ingredients, but an adaptive taster needs only two
  probes.  So a cook who decides what to taste next *after* the previous taste is strictly
  more efficient — the kitchen analogue of adaptive versus nonadaptive query algorithms.
-/

namespace KitchenQuery

open Finset

variable {n : ℕ}

/-! ### A structure theorem for quick dishes -/

/-- **Structure of `(d+1)`-quick dishes.**  Either the verdict is already decided, or one
probe splits the dish into two `d`-quick dishes. -/
theorem tasteCost_succ_decomp {d : ℕ} {f : Dish n} (h : tasteCost f ≤ d + 1) :
    (∃ b, ∀ x, f x = b) ∨
      ∃ (i : Fin n) (g₀ g₁ : Dish n), tasteCost g₀ ≤ d ∧ tasteCost g₁ ≤ d ∧
        ∀ x, f x = if x i then g₁ x else g₀ x := by
  obtain ⟨t, ht, hd⟩ := exists_optimal_taste f
  have hd1 : t.depth ≤ d + 1 := le_trans hd h
  cases t with
  | serve b => exact Or.inl ⟨b, fun x => (ht x).symm⟩
  | probe i l r =>
      have hl : l.depth ≤ d := by simp only [Taste.depth] at hd1; omega
      have hr : r.depth ≤ d := by simp only [Taste.depth] at hd1; omega
      refine Or.inr ⟨i, l.eval, r.eval, ?_, ?_, ?_⟩
      · exact le_trans (tasteCost_le_of_computes (t := l) (fun _ => rfl)) hl
      · exact le_trans (tasteCost_le_of_computes (t := r) (fun _ => rfl)) hr
      · intro x; rw [← ht x]; rfl

/-! ### Counting quick dishes -/

open scoped Classical in
/-- The dishes verifiable with at most `d` taste probes. -/
noncomputable def quickDishes (n d : ℕ) : Finset (Dish n) :=
  Finset.univ.filter (fun f => tasteCost f ≤ d)

open scoped Classical in
@[simp] lemma mem_quickDishes {d : ℕ} {f : Dish n} :
    f ∈ quickDishes n d ↔ tasteCost f ≤ d := by
  simp [quickDishes]

/-- Exactly two dishes need no tasting at all. -/
theorem card_quickDishes_zero : (quickDishes n 0).card = 2 := by
  classical
  have hset : quickDishes n 0 = {(fun _ => false), (fun _ => true)} := by
    ext f
    simp only [mem_quickDishes, Nat.le_zero, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · intro h
      obtain ⟨b, hb⟩ := (tasteCost_zero_iff_constant f).1 h
      cases b
      · exact Or.inl (funext hb)
      · exact Or.inr (funext hb)
    · rintro (rfl | rfl) <;> exact tasteCost_const _
  rw [hset, Finset.card_insert_of_notMem (by
    simp only [Finset.mem_singleton]
    intro hc
    exact Bool.noConfusion (congrFun hc (fun _ => false))), Finset.card_singleton]

lemma one_le_card_quickDishes (d : ℕ) : 1 ≤ (quickDishes n d).card := by
  classical
  refine Finset.card_pos.2 ⟨(fun _ => false), ?_⟩
  simp [tasteCost_const]

/-- **The counting recursion.**  A `(d+1)`-quick dish is a constant or a probe followed by
two `d`-quick dishes, so there are at most `2 + n · c_d²` of them. -/
theorem card_quickDishes_succ_le (d : ℕ) :
    (quickDishes n (d + 1)).card ≤ 2 + n * (quickDishes n d).card ^ 2 := by
  classical
  set C : Finset (Dish n) :=
    Finset.image (fun b : Bool => (fun _ => b : Dish n)) Finset.univ with hC
  set B : Finset (Dish n) :=
    Finset.image
      (fun p : Fin n × Dish n × Dish n => (fun x => if x p.1 then p.2.2 x else p.2.1 x : Dish n))
      (Finset.univ ×ˢ (quickDishes n d ×ˢ quickDishes n d)) with hB
  have hsub : quickDishes n (d + 1) ⊆ C ∪ B := by
    intro f hf
    have h := tasteCost_succ_decomp (mem_quickDishes.1 hf)
    rcases h with ⟨b, hb⟩ | ⟨i, g₀, g₁, h0, h1, hf'⟩
    · exact Finset.mem_union_left _ (by
        simp only [hC, Finset.mem_image, Finset.mem_univ, true_and]
        exact ⟨b, (funext hb).symm⟩)
    · refine Finset.mem_union_right _ ?_
      simp only [hB, Finset.mem_image, Finset.mem_product, Finset.mem_univ, true_and]
      exact ⟨(i, g₀, g₁), ⟨mem_quickDishes.2 h0, mem_quickDishes.2 h1⟩,
        (funext hf').symm⟩
  refine le_trans (Finset.card_le_card hsub) ?_
  refine le_trans (Finset.card_union_le _ _) (Nat.add_le_add ?_ ?_)
  · refine le_trans (Finset.card_image_le) ?_
    simp
  · refine le_trans (Finset.card_image_le) ?_
    rw [Finset.card_product, Finset.card_product, Finset.card_univ, Fintype.card_fin]
    ring_nf
    exact le_of_eq (by ring)

/-- **Solving the recursion.**  At most `(6n)^(2^d)` dishes can be verified with `d`
probes — a doubly exponential bound, but in `d`, not in `n`. -/
theorem card_quickDishes_le (hn : 1 ≤ n) (d : ℕ) :
    3 * n * (quickDishes n d).card ≤ (6 * n) ^ (2 ^ d) := by
  induction d with
  | zero =>
      rw [card_quickDishes_zero]
      simp only [pow_zero, pow_one]
      omega
  | succ d ih =>
      have hstep := card_quickDishes_succ_le (n := n) d
      set c := (quickDishes n d).card with hc
      have hc1 : 1 ≤ c := one_le_card_quickDishes d
      have hpow : (6 * n) ^ (2 ^ (d + 1)) = ((6 * n) ^ (2 ^ d)) ^ 2 := by
        rw [← pow_mul]
        ring_nf
      have hkey : 3 * n * (quickDishes n (d + 1)).card ≤ (3 * n * c) ^ 2 := by
        have h1 : 3 * n * (quickDishes n (d + 1)).card ≤ 3 * n * (2 + n * c ^ 2) :=
          Nat.mul_le_mul_left _ hstep
        refine le_trans h1 ?_
        have hcc : 0 < c * c := Nat.mul_pos hc1 hc1
        have h2 : n ≤ n * n * (c * c) :=
          le_trans (Nat.le_mul_of_pos_left n (by omega)) (Nat.le_mul_of_pos_right _ hcc)
        calc 3 * n * (2 + n * c ^ 2) = 6 * n + 3 * (n * n * (c * c)) := by ring
          _ ≤ 6 * (n * n * (c * c)) + 3 * (n * n * (c * c)) :=
              Nat.add_le_add_right (Nat.mul_le_mul_left 6 h2) _
          _ = (3 * n * c) ^ 2 := by ring
      refine le_trans hkey ?_
      rw [hpow]
      exact Nat.pow_le_pow_left ih 2

theorem card_quickDishes_le' (hn : 1 ≤ n) (d : ℕ) :
    (quickDishes n d).card ≤ (6 * n) ^ (2 ^ d) :=
  le_trans (Nat.le_mul_of_pos_left _ (by omega)) (card_quickDishes_le hn d)

lemma card_dish (n : ℕ) : Fintype.card (Dish n) = 2 ^ 2 ^ n := by
  simp [Dish, Pantry]

/-- **There are hard recipes.**  Whenever the counting bound falls below the number of
dishes, some dish needs more than `d` probes. -/
theorem exists_hard_dish (hn : 1 ≤ n) (d : ℕ) (h : (6 * n) ^ (2 ^ d) < 2 ^ 2 ^ n) :
    ∃ f : Dish n, d < tasteCost f := by
  classical
  by_contra hcon
  push_neg at hcon
  have hall : (quickDishes n d) = Finset.univ := by
    ext f
    simp [mem_quickDishes, hcon f]
  have := card_quickDishes_le' hn d
  rw [hall, Finset.card_univ, card_dish] at this
  omega

/-- **Generic hardness.**  If the counting bound is at most half the number of dishes, then
at least half of all recipes need more than `d` taste probes. -/
theorem most_dishes_hard (hn : 1 ≤ n) (d : ℕ) (h : 2 * (6 * n) ^ (2 ^ d) ≤ 2 ^ 2 ^ n) :
    2 * (quickDishes n d).card ≤ Fintype.card (Dish n) := by
  rw [card_dish]
  exact le_trans (Nat.mul_le_mul_left 2 (card_quickDishes_le' hn d)) h

/-- A concrete instance of generic hardness: with sixteen ingredients, at least half of all
`2 ^ 65536` dishes cannot be verified with seven taste probes. -/
theorem most_dishes_hard_16 :
    2 * (quickDishes 16 7).card ≤ Fintype.card (Dish 16) := by
  refine most_dishes_hard (by norm_num) 7 ?_
  have h1 : (6 * 16 : ℕ) ^ (2 ^ 7) ≤ (2 ^ 7 : ℕ) ^ (2 ^ 7) :=
    Nat.pow_le_pow_left (by norm_num) _
  have h2 : ((2 : ℕ) ^ 7) ^ (2 ^ 7) = 2 ^ 896 := by rw [← pow_mul]; norm_num
  have h4 : (2 : ℕ) ^ 897 ≤ 2 ^ (2 ^ 16) := Nat.pow_le_pow_right (by norm_num) (by norm_num)
  calc 2 * (6 * 16 : ℕ) ^ (2 ^ 7) ≤ 2 * ((2 ^ 7 : ℕ) ^ (2 ^ 7)) := Nat.mul_le_mul_left 2 h1
    _ = 2 ^ 897 := by rw [h2, ← pow_succ']
    _ ≤ 2 ^ (2 ^ 16) := h4

/-! ### Adaptivity: deciding what to taste next is strictly powerful -/

/-- A fixed tasting checklist: probe the ingredients in `S`, whatever the dish looks like. -/
def NonadaptiveChecklist (f : Dish n) (S : Finset (Fin n)) : Prop :=
  ∀ x, IsCertificate f x S

/-- An ingredient matters for a dish if it is pivotal somewhere. -/
def relevantSet (f : Dish n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => ∃ x, Pivotal f x i)

/-- A fixed checklist must contain every ingredient that matters. -/
theorem relevantSet_subset_of_checklist {f : Dish n} {S : Finset (Fin n)}
    (hS : NonadaptiveChecklist f S) : relevantSet f ⊆ S := by
  intro i hi
  obtain ⟨x, hx⟩ : ∃ x, Pivotal f x i := by simpa [relevantSet] using hi
  exact pivotal_mem_certificate (hS x) hx

/-- The multiplexer dish: if the sauce (ingredient `0`) is on, the verdict is the fish
(ingredient `1`), otherwise the soup (ingredient `2`). -/
def mux : Dish 3 := fun x => if x 0 then x 1 else x 2

/-- Adaptive tasting handles the multiplexer with two probes. -/
theorem tasteCost_mux : tasteCost mux = 2 := by
  refine Nat.le_antisymm ?_ ?_
  · refine Nat.sInf_le ⟨.probe 0 (.probe 2 (.serve false) (.serve true))
      (.probe 1 (.serve false) (.serve true)), ?_, by simp [Taste.depth]⟩
    intro x
    cases h0 : x 0 <;> cases h1 : x 1 <;> cases h2 : x 2 <;>
      simp [Taste.eval, mux, h0, h1, h2]
  · have hx : pivotalSet mux ![true, true, false] = {0, 1} := by decide
    have h := pivotalSet_card_le_tasteCost mux ![true, true, false]
    rw [hx] at h
    simpa using h

/-- Every ingredient matters for the multiplexer. -/
theorem relevantSet_mux : relevantSet mux = Finset.univ := by
  ext i
  simp only [relevantSet, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
  fin_cases i
  · exact ⟨![true, true, false], by decide⟩
  · exact ⟨![true, true, false], by decide⟩
  · exact ⟨![false, true, false], by decide⟩

/-- **Adaptivity gap.**  Any fixed tasting checklist for the multiplexer must probe all three
ingredients, while an adaptive taster needs only two: choosing the next probe in the light of
the previous one is strictly more powerful in the kitchen. -/
theorem adaptivity_gap :
    (∀ S : Finset (Fin 3), NonadaptiveChecklist mux S → S = Finset.univ) ∧
      tasteCost mux = 2 ∧ (2 : ℕ) < (Finset.univ : Finset (Fin 3)).card := by
  refine ⟨fun S hS => ?_, tasteCost_mux, by simp⟩
  have h := relevantSet_subset_of_checklist hS
  rw [relevantSet_mux] at h
  exact Finset.univ_subset_iff.mp h

end KitchenQuery