import Novelty.KitchenQueryComplexity
import Novelty.RecipeBarycenterBridge

/-!
# The kitchen complexity spectrum: every ratio `C/V` occurs, and quick recipes are rare

This file continues `Novelty.KitchenQueryComplexity` and connects it to the convex-geometric
menu calculus of `Novelty.RecipeBarycenterBridge`.

Main contents.

* `parityOnSet`, `pivotalSet_parityOnSet`: the parity dish supported on a set `S` of
  ingredients is pivotal exactly on `S`.  Hence `tasteCost (parityOn k) = k` for every
  `k ≤ n` (`tasteCost_parityOn`): the whole spectrum of verification times is realised.
* `ratio_toRecipe_parityOn`: the cook/verify ratio of that dish is exactly `n / k`, so
  **every rational ratio `n/k` in `[1, n]` is realised by an actual dish**.
* `census100_*`: the mission's "classify 100 recipes" test, carried out formally: the
  hundred dishes `parityOn 1, …, parityOn 100` on a hundred ingredients have ratios
  `100/k`, and the aggregate menu ratio is exactly `200/101`.
* `ratio_eq_one_iff_evasive`, `menu_ratio_one_iff_all_evasive`: **the informal conjecture is
  inverted.**  `C(R) = V(R)` holds precisely for the *evasive* dishes — the hardest ones,
  such as the soufflé — while the *easy* dishes (salads) have the extreme ratio `C/V = n`.
  Combining with the barycentric rigidity theorem of `RecipeBarycenterBridge`, a whole menu
  is break-even iff every single dish on it is evasive.
* `quick_dish_classification`, `quick_dishes_card_le`, `quick_dishes_rare`: dishes with
  `V ≤ 1` are exactly constants, single-ingredient salads and their negations; there are at
  most `2n + 2` of them out of `2 ^ 2 ^ n` dishes, so quick recipes are vanishingly rare.
-/

namespace KitchenQuery

open Finset

variable {n : ℕ}

/-! ### Parity dishes supported on a set of ingredients -/

/-- The dish whose quality is the parity of the ingredients in `S`. -/
def parityOnSet (S : Finset (Fin n)) : Dish n :=
  fun x => decide (Odd (∑ j ∈ S, if x j then 1 else 0))

lemma parityOnSet_update_mem {S : Finset (Fin n)} (x : Pantry n) {i : Fin n} (hi : i ∈ S) :
    parityOnSet S (Function.update x i (!x i)) ≠ parityOnSet S x := by
  classical
  have hx : (∑ j ∈ S, if x j then 1 else 0)
      = (if x i then 1 else 0) + ∑ j ∈ S.erase i, if x j then 1 else 0 := by
    rw [← Finset.add_sum_erase _ _ hi]
  have hu : (∑ j ∈ S, if Function.update x i (!x i) j then 1 else 0)
      = (if !x i then 1 else 0) + ∑ j ∈ S.erase i, if x j then 1 else 0 := by
    rw [← Finset.add_sum_erase _ _ hi]
    simp only [Function.update_self]
    congr 1
    refine Finset.sum_congr rfl ?_
    intro j hj
    have hne : j ≠ i := (Finset.mem_erase.mp hj).1
    simp [Function.update_of_ne hne]
  simp only [parityOnSet, ne_eq, decide_eq_decide, Nat.odd_iff, hx, hu]
  cases hxi : x i <;> simp <;> omega

lemma parityOnSet_update_not_mem {S : Finset (Fin n)} (x : Pantry n) {i : Fin n} (hi : i ∉ S) :
    parityOnSet S (Function.update x i (!x i)) = parityOnSet S x := by
  have hsum : (∑ j ∈ S, if Function.update x i (!x i) j then 1 else 0)
      = ∑ j ∈ S, (if x j then 1 else 0 : ℕ) := by
    refine Finset.sum_congr rfl ?_
    intro j hj
    have hne : j ≠ i := by rintro rfl; exact hi hj
    simp [Function.update_of_ne hne]
  simp only [parityOnSet, hsum]

/-- The pivotal ingredients of a parity dish are exactly its support, at every pantry. -/
theorem pivotalSet_parityOnSet (S : Finset (Fin n)) (x : Pantry n) :
    pivotalSet (parityOnSet S) x = S := by
  ext i
  simp only [pivotalSet, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · intro hpiv
    by_contra hi
    exact hpiv (parityOnSet_update_not_mem x hi)
  · intro hi
    exact parityOnSet_update_mem x hi

/-! ### Dishes that only use the first `k` ingredients -/

/-- `f` only uses the first `k` ingredients. -/
def UsesFirst (k : ℕ) (f : Dish n) : Prop :=
  ∀ x y : Pantry n, (∀ j : Fin n, (j : ℕ) < k → x j = y j) → f x = f y

/-- A dish using only the first `k` ingredients can be tasted with `k` probes. -/
theorem tasteCost_le_of_usesFirst {k : ℕ} {f : Dish n} (h : UsesFirst k f) :
    tasteCost f ≤ k := by
  refine Nat.sInf_le ⟨brute f k (fun _ => false), fun x => ?_, brute_depth_le f k _⟩
  rw [brute_eval]
  exact h _ _ (fun j hj => by simp [hj])

/-- The parity dish on the first `k` ingredients: the mission's tunable recipe family. -/
def parityOn (k : ℕ) : Dish n := parityOnSet (Finset.univ.filter (fun j : Fin n => (j : ℕ) < k))

lemma card_filter_lt {k : ℕ} (hk : k ≤ n) :
    (Finset.univ.filter (fun j : Fin n => (j : ℕ) < k)).card = k := by
  classical
  have himg : (Finset.univ.filter (fun j : Fin n => (j : ℕ) < k))
      = Finset.image (fun i : Fin k => (⟨(i : ℕ), lt_of_lt_of_le i.isLt hk⟩ : Fin n))
        Finset.univ := by
    ext j
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    constructor
    · intro hj
      exact ⟨⟨(j : ℕ), hj⟩, by ext; rfl⟩
    · rintro ⟨i, rfl⟩
      exact i.isLt
  rw [himg, Finset.card_image_of_injective _ ?_, Finset.card_univ, Fintype.card_fin]
  intro a b hab
  ext
  simpa using congrArg Fin.val hab

lemma usesFirst_parityOn (k : ℕ) : UsesFirst k (parityOn (n := n) k) := by
  intro x y hxy
  have hsum : (∑ j ∈ Finset.univ.filter (fun j : Fin n => (j : ℕ) < k), if x j then 1 else 0)
      = ∑ j ∈ Finset.univ.filter (fun j : Fin n => (j : ℕ) < k), (if y j then 1 else 0 : ℕ) := by
    refine Finset.sum_congr rfl ?_
    intro j hj
    rw [hxy j (by simpa using (Finset.mem_filter.mp hj).2)]
  simp only [parityOn, parityOnSet, hsum]

/-- **The verification-time spectrum is fully realised**: for every `k ≤ n` there is a dish
on `n` ingredients whose optimal tasting cost is exactly `k`. -/
theorem tasteCost_parityOn {k : ℕ} (hk : k ≤ n) : tasteCost (parityOn (n := n) k) = k := by
  refine Nat.le_antisymm (tasteCost_le_of_usesFirst (usesFirst_parityOn k)) ?_
  have h := pivotalSet_card_le_tasteCost (parityOn (n := n) k) (fun _ => false)
  rwa [parityOn, pivotalSet_parityOnSet, card_filter_lt hk] at h

/-! ### The bridge to the barycentric menu calculus -/

/-- The timing record of a dish: cooking time `n`, verification time `tasteCost`. -/
noncomputable def toRecipe (f : Dish n) : RecipeBarycenter.Recipe :=
  ⟨cookCost f, tasteCost f⟩

lemma toRecipe_verify_pos {f : Dish n} (hf : ¬ ∃ b, ∀ x, f x = b) :
    0 < (toRecipe f).verify := by
  have : tasteCost f ≠ 0 := fun h => hf ((tasteCost_zero_iff_constant f).1 h)
  exact Nat.pos_of_ne_zero this

/-- **The cook/verify ratio of the tunable family is exactly `n/k`.** -/
theorem ratio_toRecipe_parityOn {k : ℕ} (hk : k ≤ n) :
    RecipeBarycenter.ratio (toRecipe (parityOn (n := n) k)) = (n : ℚ) / (k : ℚ) := by
  simp [RecipeBarycenter.ratio, toRecipe, cookCost, tasteCost_parityOn hk]

/-- **The conjecture is inverted.**  A dish is break-even (`C(R) = V(R)`) exactly when it is
*evasive*, i.e. maximally hard to verify — not when it is quick. -/
theorem ratio_eq_one_iff_evasive {f : Dish n} (hf : ¬ ∃ b, ∀ x, f x = b) :
    RecipeBarycenter.ratio (toRecipe f) = 1 ↔ tasteCost f = n := by
  rw [RecipeBarycenter.ratio_eq_one_iff (toRecipe_verify_pos hf)]
  exact ⟨fun h => h.symm, fun h => h.symm⟩

/-- The one-ingredient salad is the opposite extreme: quick to taste, ratio `n`. -/
theorem ratio_toRecipe_salad (i : Fin n) :
    RecipeBarycenter.ratio (toRecipe (salad i)) = (n : ℚ) := by
  simp [RecipeBarycenter.ratio, toRecipe, cookCost, tasteCost_salad]

/-- The soufflé sits at ratio one, the salad at ratio `n`: the two extremes are both
attained, and they are attained by the *hard* and the *easy* dish respectively. -/
theorem souffle_salad_ratio_gap (hn : 2 ≤ n) (i : Fin n) :
    RecipeBarycenter.ratio (toRecipe (souffle (n := n))) = 1 ∧
      RecipeBarycenter.ratio (toRecipe (salad i)) = (n : ℚ) ∧
      (1 : ℚ) < RecipeBarycenter.ratio (toRecipe (salad i)) := by
  have hn0 : 0 < n := by omega
  have hne : (n : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hn0.ne'
  refine ⟨?_, ratio_toRecipe_salad i, ?_⟩
  · simp [RecipeBarycenter.ratio, toRecipe, cookCost, tasteCost_souffle, div_self hne]
  · rw [ratio_toRecipe_salad i]
    have h1 : (1 : ℕ) < n := by omega
    exact_mod_cast h1

/-- **Menu rigidity, transported to the kitchen.**  A finite menu of non-constant dishes on
`n` ingredients is globally break-even exactly when every single dish is evasive.  This uses
the barycentric rigidity theorem of `RecipeBarycenterBridge`. -/
theorem menu_ratio_one_iff_all_evasive {ι : Type*} [Fintype ι] [Nonempty ι]
    (F : ι → Dish n) (hF : ∀ i, ¬ ∃ b, ∀ x, F i x = b) :
    RecipeBarycenter.ratio (RecipeBarycenter.aggregate (fun i => toRecipe (F i))) = 1 ↔
      ∀ i, tasteCost (F i) = n := by
  have hpos : ∀ i, 0 < (toRecipe (F i)).verify := fun i => toRecipe_verify_pos (hF i)
  have hphys : ∀ i, (toRecipe (F i)).verify ≤ (toRecipe (F i)).cook := fun i =>
    tasteCost_le_card_ingredients (F i)
  rw [RecipeBarycenter.aggregate_ratio_eq_one_iff _ hpos hphys]
  exact forall_congr' fun i => (ratio_eq_one_iff_evasive (hF i))

/-! ### The mission's test: a census of one hundred recipes -/

/-- The census menu: on a pantry of `100` ingredients, the hundred dishes
`parityOn 1, …, parityOn 100`. -/
noncomputable def census100 (k : Fin 100) : RecipeBarycenter.Recipe :=
  toRecipe (parityOn (n := 100) ((k : ℕ) + 1))

/-- Each census recipe has cook time `100` and verification time `k + 1`. -/
theorem census100_times (k : Fin 100) :
    (census100 k).cook = 100 ∧ (census100 k).verify = (k : ℕ) + 1 := by
  refine ⟨rfl, ?_⟩
  simpa [census100, toRecipe] using tasteCost_parityOn (n := 100) (k := (k : ℕ) + 1) k.isLt

/-- Each census recipe realises the ratio `100 / (k+1)`; the ratios sweep the whole interval
from `1` (the evasive dish `parityOn 100`) to `100` (the one-probe dish `parityOn 1`). -/
theorem census100_ratio (k : Fin 100) :
    RecipeBarycenter.ratio (census100 k) = (100 : ℚ) / ((k : ℕ) + 1) := by
  obtain ⟨hc, hv⟩ := census100_times k
  simp [RecipeBarycenter.ratio, hc, hv]

lemma census100_sum_verify :
    (RecipeBarycenter.aggregate census100).verify = 5050 := by
  have : ∀ k : Fin 100, (census100 k).verify = (k : ℕ) + 1 :=
    fun k => (census100_times k).2
  simp only [RecipeBarycenter.aggregate, this]
  rw [Fin.sum_univ_eq_sum_range (fun i => i + 1) 100]
  decide

lemma census100_sum_cook :
    (RecipeBarycenter.aggregate census100).cook = 10000 := by
  have : ∀ k : Fin 100, (census100 k).cook = 100 := fun k => (census100_times k).1
  simp only [RecipeBarycenter.aggregate, this]
  simp

/-- **The census test, formally.**  The aggregate cook/verify ratio of the hundred-recipe
menu is exactly `200/101 ≈ 1.98`: even a menu containing very quick dishes is dragged towards
the break-even boundary by the evasive ones, since verification work is the barycentric
weight. -/
theorem census100_aggregate_ratio :
    RecipeBarycenter.ratio (RecipeBarycenter.aggregate census100) = 200 / 101 := by
  rw [RecipeBarycenter.ratio, census100_sum_verify, census100_sum_cook]
  norm_num

/-! ### Quick recipes are rare -/

lemma depth_eq_zero_iff (t : Taste n) : t.depth = 0 ↔ ∃ b, t = .serve b := by
  cases t with
  | serve b => exact ⟨fun _ => ⟨b, rfl⟩, fun _ => rfl⟩
  | probe i l r =>
      constructor
      · intro h; simp [Taste.depth] at h
      · rintro ⟨b, hb⟩; exact absurd hb (by simp)

/-- **Classification of quick recipes.**  A dish verifiable with at most one taste probe is a
constant, a single-ingredient salad, or the complement of one. -/
theorem quick_dish_classification (f : Dish n) (h : tasteCost f ≤ 1) :
    (∃ b, ∀ x, f x = b) ∨ ∃ i : Fin n, (∀ x, f x = x i) ∨ (∀ x, f x = !x i) := by
  obtain ⟨t, ht, hd⟩ := exists_optimal_taste f
  have hd1 : t.depth ≤ 1 := le_trans hd h
  cases t with
  | serve b => exact Or.inl ⟨b, fun x => (ht x).symm⟩
  | probe i l r =>
      have hl : l.depth = 0 := by simp only [Taste.depth] at hd1; omega
      have hr : r.depth = 0 := by simp only [Taste.depth] at hd1; omega
      obtain ⟨a, rfl⟩ := (depth_eq_zero_iff l).1 hl
      obtain ⟨c, rfl⟩ := (depth_eq_zero_iff r).1 hr
      have hf : ∀ x, f x = if x i then c else a := fun x => by
        rw [← ht x]; rfl
      cases a <;> cases c
      · exact Or.inl ⟨false, fun x => by rw [hf x]; cases x i <;> simp⟩
      · exact Or.inr ⟨i, Or.inl fun x => by rw [hf x]; cases x i <;> simp⟩
      · exact Or.inr ⟨i, Or.inr fun x => by rw [hf x]; cases x i <;> simp⟩
      · exact Or.inl ⟨true, fun x => by rw [hf x]; cases x i <;> simp⟩

open scoped Classical in
/-- There are at most `2n + 2` quick recipes. -/
theorem quick_dishes_card_le :
    (Finset.univ.filter (fun f : Dish n => tasteCost f ≤ 1)).card ≤ 2 * n + 2 := by
  classical
  set g : Bool ⊕ (Fin n × Bool) → Dish n := fun p => match p with
    | .inl b => fun _ => b
    | .inr (i, c) => fun x => xor c (x i) with hg
  have hsub : (Finset.univ.filter (fun f : Dish n => tasteCost f ≤ 1))
      ⊆ Finset.image g Finset.univ := by
    intro f hf
    have h := quick_dish_classification f (by simpa using (Finset.mem_filter.mp hf).2)
    simp only [Finset.mem_image, Finset.mem_univ, true_and]
    rcases h with ⟨b, hb⟩ | ⟨i, hi | hi⟩
    · exact ⟨.inl b, funext fun x => (hb x).symm⟩
    · exact ⟨.inr (i, false), funext fun x => by simp [hg, hi x]⟩
    · exact ⟨.inr (i, true), funext fun x => by simp [hg, hi x]⟩
  refine le_trans (Finset.card_le_card hsub) ?_
  refine le_trans (Finset.card_image_le) ?_
  simp [Finset.card_univ, Nat.mul_comm, Nat.add_comm]

lemma two_pow_ge_add_two {m : ℕ} (hm : 2 ≤ m) : m + 2 ≤ 2 ^ m := by
  induction m with
  | zero => omega
  | succ k ih =>
      rcases Nat.lt_or_ge k 2 with hk | hk
      · have hk1 : k = 1 := by omega
        subst hk1; norm_num
      · have := ih (by omega)
        have hpos : 1 ≤ 2 ^ k := Nat.one_le_two_pow
        calc k + 1 + 2 ≤ 2 ^ k + 2 ^ k := by omega
          _ = 2 ^ (k + 1) := by ring
    
open scoped Classical in
/-- **Quick recipes are vanishingly rare.**  For `n ≥ 2` the number of dishes verifiable with
one probe is strictly smaller than the number of dishes; in fact `2n + 2 < 2 ^ 2 ^ n`, and the
gap is doubly exponential. -/
theorem quick_dishes_rare (hn : 2 ≤ n) :
    (Finset.univ.filter (fun f : Dish n => tasteCost f ≤ 1)).card < 2 ^ 2 ^ n := by
  refine lt_of_le_of_lt quick_dishes_card_le ?_
  have h1 : n + 2 ≤ 2 ^ n := two_pow_ge_add_two hn
  have h2 : 2 ^ (n + 2) ≤ 2 ^ 2 ^ n := Nat.pow_le_pow_right (by norm_num) h1
  have h3 : (2 : ℕ) ^ (n + 2) = 4 * 2 ^ n := by ring
  have h4 : n + 1 ≤ 2 ^ n := by omega
  omega

end KitchenQuery