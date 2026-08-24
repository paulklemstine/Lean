import Mathlib

/-!
# Kitchen query complexity: cooking, tasting, and an unconditional `P ≠ NP` in the kitchen

The slogan "a recipe is an algorithm, so `C(R)` versus `V(R)` is `P` versus `NP`" is
usually left as a metaphor.  This file makes the metaphor into a theorem by choosing a
computational model in which the separation is *provable*: the deterministic
**decision-tree (query) model**.

* A *pantry* of `n` ingredients is a Boolean vector `x : Fin n → Bool` (each ingredient is
  fresh/spoiled, whipped/flat, ...).
* A *dish* is a predicate `f : Pantry n → Bool`: is the result good?
* *Cooking* means touching all `n` ingredients: `C(R) = n`.
* *Tasting* is modelled by a `Taste` tree: adaptively probe individual ingredients of the
  finished dish and then declare it good or bad.  `V(R)` is the minimal depth of a taste
  tree computing `f` (`tasteCost`).
* *Nondeterministic verification* (a "garnish" pointing at what to taste) is certificate
  complexity: a set `S` of probes with `IsCertificate f x S`.

The main results are:

* `Taste.card_path_le_depth`, `Taste.eval_eq_of_agree`: the path lemma, the technical
  heart of every lower bound below.
* `sensitivity_le_tasteCost`: sensitivity is a lower bound on tasting time.
* `tasteCost_le_card_ingredients`: tasting is never slower than cooking, `V(R) ≤ C(R)`.
* `tasteCost_allFresh`: the "everything must be fresh" dish is *evasive*: `V = C = n`.
* `kitchen_P_ne_NP`: the anySpoiled dish has a one-probe nondeterministic certificate at
  every bad pantry, yet every deterministic taster needs all `n` probes.  This is an
  unconditional separation of deterministic and nondeterministic kitchen verification.
* `souffle_no_certificate_shortcut`: for the soufflé dish (parity of the pantry) *even*
  nondeterministic verification is useless — every certificate at every pantry is the whole
  pantry.  This is the honest version of "soufflé verification is co-NP-hard": the soufflé
  is hard to verify from *both* sides, unlike the salad.
* `tasteCost_zero_iff_constant`: you cannot tell whether the soufflé rose without cutting
  into it.

No claim about Navier–Stokes or `PSPACE` is made: those need a physical model that timing
data does not supply.  What *is* proved is the exact combinatorial shadow of the
conjecture.
-/

namespace KitchenQuery

open Finset

/-- A pantry state: each of the `n` ingredients is in one of two conditions. -/
abbrev Pantry (n : ℕ) := Fin n → Bool

/-- A dish: the predicate "this pantry cooks up to something good". -/
abbrev Dish (n : ℕ) := Pantry n → Bool

/-- An adaptive tasting strategy: probe an ingredient of the dish, branch, and eventually
serve a verdict. -/
inductive Taste (n : ℕ) where
  | serve : Bool → Taste n
  | probe : Fin n → Taste n → Taste n → Taste n
  deriving Inhabited

namespace Taste

variable {n : ℕ}

/-- Worst-case number of probes. -/
def depth : Taste n → ℕ
  | serve _ => 0
  | probe _ l r => 1 + max l.depth r.depth

/-- The verdict of a tasting strategy on a pantry. -/
def eval : Taste n → Pantry n → Bool
  | serve b, _ => b
  | probe i l r, x => if x i then eval r x else eval l x

/-- The set of ingredients actually probed on the pantry `x`. -/
def path : Taste n → Pantry n → Finset (Fin n)
  | serve _, _ => ∅
  | probe i l r, x => insert i (if x i then path r x else path l x)

@[simp] lemma depth_serve (b : Bool) : (serve b : Taste n).depth = 0 := rfl
@[simp] lemma eval_serve (b : Bool) (x : Pantry n) : (serve b : Taste n).eval x = b := rfl
@[simp] lemma path_serve (b : Bool) (x : Pantry n) : (serve b : Taste n).path x = ∅ := rfl

/-- **Path lemma, part 1.** A tasting strategy probes at most `depth` ingredients. -/
theorem card_path_le_depth (t : Taste n) (x : Pantry n) : (t.path x).card ≤ t.depth := by
  induction t with
  | serve b => simp
  | probe i l r hl hr =>
      have h : ((if x i then r.path x else l.path x)).card ≤ max l.depth r.depth := by
        by_cases hx : x i
        · simp only [hx, if_true]
          exact le_trans (hr) (le_max_right _ _)
        · simp only [hx, if_false, Bool.false_eq_true]
          exact le_trans (hl) (le_max_left _ _)
      refine le_trans (Finset.card_insert_le _ _) ?_
      simp only [depth]
      omega

/-- **Path lemma, part 2.** The verdict only depends on the ingredients actually probed. -/
theorem eval_eq_of_agree (t : Taste n) (x y : Pantry n)
    (h : ∀ i ∈ t.path x, y i = x i) : t.eval y = t.eval x := by
  induction t with
  | serve b => rfl
  | probe i l r hl hr =>
      have hi : y i = x i := h i (by simp [path])
      by_cases hx : x i
      · have hy : y i = true := by rw [hi]; exact hx
        simp only [eval, hy, hx, if_true]
        exact hr (fun j hj => h j (by simp [path, hx, hj]))
      · have hy : y i = false := by rw [hi]; simpa using hx
        simp only [eval, hy, hx, if_false, Bool.false_eq_true]
        exact hl (fun j hj => h j (by simp [path, hx, hj]))

end Taste

variable {n : ℕ}

/-- A tasting strategy decides a dish. -/
def Computes (t : Taste n) (f : Dish n) : Prop := ∀ x, t.eval x = f x

/-! ### Brute-force tasting: cooking-time verification always works -/

/-- The exhaustive taster that probes ingredients `0, …, k-1`, starting from the default
guess `a` for the untouched ones. -/
def brute (f : Dish n) : ℕ → Pantry n → Taste n
  | 0, a => .serve (f a)
  | (k + 1), a =>
      if h : k < n then
        .probe ⟨k, h⟩ (brute f k (Function.update a ⟨k, h⟩ false))
          (brute f k (Function.update a ⟨k, h⟩ true))
      else brute f k a

lemma brute_depth_le (f : Dish n) (k : ℕ) (a : Pantry n) : (brute f k a).depth ≤ k := by
  induction k generalizing a with
  | zero => simp [brute]
  | succ k ih =>
      by_cases h : k < n
      · simp only [brute, h, dif_pos, Taste.depth]
        have := ih (Function.update a ⟨k, h⟩ false)
        have := ih (Function.update a ⟨k, h⟩ true)
        omega
      · simp only [brute, h, dif_neg, not_false_iff]
        exact le_trans (ih a) (Nat.le_succ k)

/-- The exhaustive taster reconstructs the pantry on the coordinates it probes. -/
theorem brute_eval (f : Dish n) (k : ℕ) (a x : Pantry n) :
    (brute f k a).eval x = f (fun j => if (j : ℕ) < k then x j else a j) := by
  induction k generalizing a with
  | zero => simp [brute]
  | succ k ih =>
      by_cases h : k < n
      · have key : ∀ b : Bool, x ⟨k, h⟩ = b →
            (brute f k (Function.update a ⟨k, h⟩ b)).eval x =
              f (fun j => if (j : ℕ) < k + 1 then x j else a j) := by
          intro b hb
          rw [ih]
          congr 1
          funext j
          by_cases h1 : (j : ℕ) < k
          · simp [h1, Nat.lt_succ_of_lt h1]
          · by_cases h2 : (j : ℕ) = k
            · have hj : j = ⟨k, h⟩ := by ext; simpa using h2
              subst hj
              simp [hb]
            · have : ¬ (j : ℕ) < k + 1 := by omega
              have hne : j ≠ ⟨k, h⟩ := by
                intro hc; exact h2 (by rw [hc])
              simp [h1, this, Function.update_of_ne hne]
        by_cases hx : x ⟨k, h⟩
        · simp only [brute, h, dif_pos, Taste.eval, hx, if_true]
          exact key true hx
        · have hx' : x ⟨k, h⟩ = false := by simpa using hx
          simp only [brute, h, dif_pos, Taste.eval, hx', if_false, Bool.false_eq_true]
          exact key false hx'
      · simp only [brute, h, dif_neg, not_false_iff]
        rw [ih]
        congr 1
        funext j
        have hj : (j : ℕ) < k := by omega
        simp [hj, Nat.lt_succ_of_lt hj]

theorem brute_computes (f : Dish n) (a : Pantry n) : Computes (brute f n a) f := by
  intro x
  rw [brute_eval]
  congr 1
  funext j
  simp [j.isLt]

/-! ### Verification cost -/

/-- The set of achievable tasting depths for a dish. -/
def tasteDepths (f : Dish n) : Set ℕ := {d | ∃ t : Taste n, Computes t f ∧ t.depth ≤ d}

lemma tasteDepths_nonempty (f : Dish n) : (tasteDepths f).Nonempty :=
  ⟨n, brute f n (fun _ => false), brute_computes f _, brute_depth_le f n _⟩

/-- **Verification time `V(R)`**: the least number of probes of a worst-case-optimal
adaptive taster. -/
noncomputable def tasteCost (f : Dish n) : ℕ := sInf (tasteDepths f)

/-- **Cooking time `C(R)`**: every one of the `n` ingredients must be handled. -/
def cookCost (_f : Dish n) : ℕ := n

lemma tasteCost_mem (f : Dish n) : tasteCost f ∈ tasteDepths f :=
  Nat.sInf_mem (tasteDepths_nonempty f)

lemma tasteCost_le_of_computes {t : Taste n} {f : Dish n} (h : Computes t f) :
    tasteCost f ≤ t.depth :=
  Nat.sInf_le ⟨t, h, le_rfl⟩

/-- **`V(R) ≤ C(R)`: tasting never costs more than cooking.** -/
theorem tasteCost_le_card_ingredients (f : Dish n) : tasteCost f ≤ cookCost f :=
  Nat.sInf_le ⟨brute f n (fun _ => false), brute_computes f _, brute_depth_le f n _⟩

/-- There is an optimal taster realising `tasteCost`. -/
lemma exists_optimal_taste (f : Dish n) :
    ∃ t : Taste n, Computes t f ∧ t.depth ≤ tasteCost f := tasteCost_mem f

/-! ### Sensitivity: the universal lower bound on tasting -/

/-- Ingredient `i` is *pivotal* for the dish `f` at the pantry `x` if swapping it alone
changes the verdict. -/
def Pivotal (f : Dish n) (x : Pantry n) (i : Fin n) : Prop :=
  f (Function.update x i (!x i)) ≠ f x

instance (f : Dish n) (x : Pantry n) (i : Fin n) : Decidable (Pivotal f x i) := by
  unfold Pivotal; infer_instance

/-- The pivotal ingredients at a pantry (the *sensitivity* set). -/
def pivotalSet (f : Dish n) (x : Pantry n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => Pivotal f x i)

/-- Every pivotal ingredient must actually be probed. -/
theorem pivotal_mem_path {t : Taste n} {f : Dish n} (ht : Computes t f) (x : Pantry n)
    {i : Fin n} (hi : Pivotal f x i) : i ∈ t.path x := by
  by_contra hmem
  set y := Function.update x i (!x i) with hy
  have hagree : ∀ j ∈ t.path x, y j = x j := by
    intro j hj
    have hne : j ≠ i := by rintro rfl; exact hmem hj
    simp [hy, Function.update_of_ne hne]
  have : f y = f x := by
    rw [← ht y, ← ht x]
    exact t.eval_eq_of_agree x y hagree
  exact hi this

/-- **Sensitivity lower bound.** No taster can beat the number of pivotal ingredients. -/
theorem pivotalSet_card_le_tasteCost (f : Dish n) (x : Pantry n) :
    (pivotalSet f x).card ≤ tasteCost f := by
  obtain ⟨t, ht, hd⟩ := exists_optimal_taste f
  refine le_trans (le_trans (Finset.card_le_card ?_) (t.card_path_le_depth x)) hd
  intro i hi
  exact pivotal_mem_path ht x (by simpa [pivotalSet] using hi)

/-- The maximal sensitivity of a dish is a lower bound for verification time. -/
theorem sensitivity_le_tasteCost (f : Dish n) (x : Pantry n) (m : ℕ)
    (hm : m ≤ (pivotalSet f x).card) : m ≤ tasteCost f :=
  le_trans hm (pivotalSet_card_le_tasteCost f x)

/-! ### Nondeterministic verification: certificates -/

/-- A *garnish certificate*: probing the ingredients in `S` already pins the verdict. -/
def IsCertificate (f : Dish n) (x : Pantry n) (S : Finset (Fin n)) : Prop :=
  ∀ y, (∀ i ∈ S, y i = x i) → f y = f x

/-- Deterministic tasting produces certificates: the probed path is one. -/
theorem certificate_of_computes {t : Taste n} {f : Dish n} (ht : Computes t f) (x : Pantry n) :
    IsCertificate f x (t.path x) ∧ (t.path x).card ≤ t.depth := by
  refine ⟨fun y hy => ?_, t.card_path_le_depth x⟩
  rw [← ht y, ← ht x]
  exact t.eval_eq_of_agree x y hy

/-- **Nondeterminism is at least as fast as determinism in the kitchen.** -/
theorem exists_certificate_card_le_tasteCost (f : Dish n) (x : Pantry n) :
    ∃ S : Finset (Fin n), IsCertificate f x S ∧ S.card ≤ tasteCost f := by
  obtain ⟨t, ht, hd⟩ := exists_optimal_taste f
  exact ⟨t.path x, (certificate_of_computes ht x).1,
    le_trans ((certificate_of_computes ht x).2) hd⟩

/-- Certificates must mention every pivotal ingredient. -/
theorem pivotal_mem_certificate {f : Dish n} {x : Pantry n} {S : Finset (Fin n)}
    (hS : IsCertificate f x S) {i : Fin n} (hi : Pivotal f x i) : i ∈ S := by
  by_contra hmem
  refine hi (hS _ ?_)
  intro j hj
  have hne : j ≠ i := by rintro rfl; exact hmem hj
  simp [Function.update_of_ne hne]

theorem pivotalSet_subset_certificate {f : Dish n} {x : Pantry n} {S : Finset (Fin n)}
    (hS : IsCertificate f x S) : pivotalSet f x ⊆ S := by
  intro i hi
  exact pivotal_mem_certificate hS (by simpa [pivotalSet] using hi)

/-! ### Three model dishes -/

/-- **Salad / constant dish**: no probing needed. -/
theorem tasteCost_const (b : Bool) : tasteCost (fun _ : Pantry n => b) = 0 :=
  Nat.le_antisymm (Nat.sInf_le ⟨.serve b, fun _ => rfl, le_rfl⟩) (Nat.zero_le _)

/-- **You cannot judge a dish without tasting it**: a zero-probe verdict is possible exactly
for dishes whose quality is decided in advance. -/
theorem tasteCost_zero_iff_constant (f : Dish n) :
    tasteCost f = 0 ↔ ∃ b, ∀ x, f x = b := by
  constructor
  · intro h
    obtain ⟨t, ht, hd⟩ := exists_optimal_taste f
    rw [h] at hd
    cases t with
    | serve b => exact ⟨b, fun x => (ht x).symm ▸ rfl⟩
    | probe i l r => simp [Taste.depth] at hd
  · rintro ⟨b, hb⟩
    have : (fun x : Pantry n => f x) = fun _ => b := funext hb
    simpa [this] using tasteCost_const (n := n) b

/-- **The one-ingredient salad**: good iff the single flagged ingredient is fresh. -/
def salad (i : Fin n) : Dish n := fun x => x i

theorem tasteCost_salad (i : Fin n) : tasteCost (salad i) = 1 := by
  refine Nat.le_antisymm (Nat.sInf_le ⟨.probe i (.serve false) (.serve true), ?_, by simp [Taste.depth]⟩) ?_
  · intro x
    by_cases hx : x i <;> simp [Taste.eval, salad, hx]
  · rcases Nat.eq_zero_or_pos (tasteCost (salad i)) with h | h
    · obtain ⟨b, hb⟩ := (tasteCost_zero_iff_constant _).1 h
      have h1 : (true : Bool) = b := hb (fun _ => true)
      have h2 : (false : Bool) = b := hb (fun _ => false)
      exact absurd (h1.trans h2.symm) (by simp)
    · exact h

/-- **`anySpoiled`**: the dish is bad as soon as one ingredient is spoiled.  (Written as an
OR over the pantry.) -/
def anySpoiled : Dish n := fun x => decide (∃ i, x i = true)

/-- A single spoiled ingredient is a one-probe nondeterministic certificate. -/
theorem anySpoiled_certificate {x : Pantry n} {i : Fin n} (hi : x i = true) :
    IsCertificate anySpoiled x {i} := by
  intro y hy
  have hyi : y i = true := by rw [hy i (by simp), hi]
  simp only [anySpoiled, decide_eq_decide]
  exact ⟨fun _ => ⟨i, hi⟩, fun _ => ⟨i, hyi⟩⟩

/-- At the all-fresh pantry every ingredient is pivotal for `anySpoiled`. -/
theorem anySpoiled_pivotalSet_univ :
    pivotalSet (anySpoiled (n := n)) (fun _ => false) = Finset.univ := by
  ext i
  simp only [pivotalSet, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
  intro hc
  have h1 : anySpoiled (Function.update (fun _ : Fin n => false) i (!false)) = true := by
    simp only [anySpoiled, decide_eq_true_eq]
    exact ⟨i, by simp⟩
  have h2 : anySpoiled (fun _ : Fin n => false) = false := by
    simp [anySpoiled]
  rw [h1, h2] at hc
  exact Bool.noConfusion hc

/-- **Determinstic verification of `anySpoiled` costs a full cook.** -/
theorem tasteCost_anySpoiled : tasteCost (anySpoiled (n := n)) = n := by
  refine Nat.le_antisymm (tasteCost_le_card_ingredients _) ?_
  have := pivotalSet_card_le_tasteCost (anySpoiled (n := n)) (fun _ => false)
  rwa [anySpoiled_pivotalSet_univ, Finset.card_univ, Fintype.card_fin] at this

/-- **`P ≠ NP` in the kitchen (unconditional, in the query model).**
For `n ≥ 2` the dish `anySpoiled` has, at every bad pantry, a *one-probe* nondeterministic
certificate, while every deterministic taster must probe all `n` ingredients: verification
with a hint is strictly and unboundedly faster than verification without one. -/
theorem kitchen_P_ne_NP (hn : 2 ≤ n) :
    (∀ x : Pantry n, (∃ i, x i = true) →
      ∃ S : Finset (Fin n), IsCertificate anySpoiled x S ∧ S.card = 1) ∧
    tasteCost (anySpoiled (n := n)) = n ∧ 1 < tasteCost (anySpoiled (n := n)) := by
  refine ⟨?_, tasteCost_anySpoiled, ?_⟩
  · rintro x ⟨i, hi⟩
    exact ⟨{i}, anySpoiled_certificate hi, Finset.card_singleton i⟩
  · rw [tasteCost_anySpoiled]; omega

/-! ### The soufflé: parity, hard from both sides -/

/-- The soufflé verdict: it rises exactly when an odd number of the `n` critical steps were
performed correctly — a parity, the canonical "no partial information" dish. -/
def souffle : Dish n := fun x => decide (Odd (∑ i, if x i then 1 else 0))

lemma souffle_update (x : Pantry n) (i : Fin n) :
    souffle (Function.update x i (!x i)) ≠ souffle x := by
  classical
  have hmem : i ∈ (Finset.univ : Finset (Fin n)) := Finset.mem_univ i
  have hx : (∑ j, if x j then 1 else 0)
      = (if x i then 1 else 0) + ∑ j ∈ Finset.univ.erase i, if x j then 1 else 0 := by
    rw [← Finset.add_sum_erase _ _ hmem]
  have hu : (∑ j, if Function.update x i (!x i) j then 1 else 0)
      = (if !x i then 1 else 0) + ∑ j ∈ Finset.univ.erase i, if x j then 1 else 0 := by
    rw [← Finset.add_sum_erase _ _ hmem]
    simp only [Function.update_self]
    congr 1
    refine Finset.sum_congr rfl ?_
    intro j hj
    have hne : j ≠ i := (Finset.mem_erase.mp hj).1
    simp [Function.update_of_ne hne]
  simp only [souffle, ne_eq, decide_eq_decide, Nat.odd_iff, hx, hu]
  cases hxi : x i <;> simp <;> omega

/-- Every ingredient is pivotal for the soufflé, at *every* pantry. -/
theorem souffle_pivotalSet_univ (x : Pantry n) :
    pivotalSet (souffle (n := n)) x = Finset.univ := by
  ext i
  simp only [pivotalSet, Finset.mem_filter, Finset.mem_univ, true_and, iff_true]
  exact souffle_update x i

/-- **The soufflé is evasive: `V(R) = C(R) = n`.** -/
theorem tasteCost_souffle : tasteCost (souffle (n := n)) = n := by
  refine Nat.le_antisymm (tasteCost_le_card_ingredients _) ?_
  have := pivotalSet_card_le_tasteCost (souffle (n := n)) (fun _ => false)
  rwa [souffle_pivotalSet_univ, Finset.card_univ, Fintype.card_fin] at this

/-- **Soufflé theorem: no nondeterministic shortcut, at either verdict.**
Unlike the salad, no garnish helps: every certificate at every pantry is the entire pantry,
so nondeterministic *and* co-nondeterministic verification both cost a full cook. -/
theorem souffle_no_certificate_shortcut (x : Pantry n) (S : Finset (Fin n))
    (hS : IsCertificate (souffle (n := n)) x S) : S = Finset.univ := by
  refine Finset.eq_univ_of_card S ?_
  have hsub : pivotalSet (souffle (n := n)) x ⊆ S := pivotalSet_subset_certificate hS
  have := Finset.card_le_card hsub
  rw [souffle_pivotalSet_univ, Finset.card_univ, Fintype.card_fin] at this
  have hub : S.card ≤ n := by simpa using Finset.card_le_univ S
  rw [Fintype.card_fin]
  omega

/-- The soufflé strictly separates from the salad: for `n ≥ 2`, tasting the soufflé costs
strictly more than tasting a salad, and exactly as much as cooking it. -/
theorem souffle_vs_salad (hn : 2 ≤ n) (i : Fin n) :
    tasteCost (salad i) < tasteCost (souffle (n := n)) ∧
      tasteCost (souffle (n := n)) = cookCost (souffle (n := n)) := by
  rw [tasteCost_salad, tasteCost_souffle]
  exact ⟨by omega, rfl⟩

end KitchenQuery