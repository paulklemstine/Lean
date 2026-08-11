import Combinatorics.DepthVectorInclusion

/-!
# The exact inclusion order on the tag-sensitive finite-height theories

`Novelty.HeightSpectrumTransfer` and `Novelty.TransferPreorderRealization` established
that the finite-height, tag-sensitive theory `capC c N` depends on the height function
`c` only through its **depth vector**

  `depthVec c N i = min N (c i)`,

that the depth vector is a *complete* invariant (`provable_capC_congr_of_min_eq`,
`capC_ne_of_min_ne`), and that the resulting family of theories is **not** ordered by
the pointwise order on depth vectors (`theory_inclusion_not_pointwise`).

The accompanying conjecture list (`FUTURE_DIRECTIONS.md`, item 3, *order-preservation
criterion for inclusion*) proposed that the inclusion

  `TheoryIncl c c' N :  ∀ a, Provable (capC c' N) a → Provable (capC c N) a`

is equivalent to the conjunction of

1. `depthVec c N i ≤ depthVec c' N i` for all tags `i`  (depths only increase), and
2. `depthVec c' N i ≤ depthVec c' N j → depthVec c N i ≤ depthVec c N j`  (the relative
   order of the depths is undisturbed).

This file settles the question.  The conjectured criterion is **necessary but not
sufficient**, so the conjecture is *false* (`inclusion_order_criterion_false`,
`conjectured_criterion_insufficient`); the exact criterion is

  `capC_inclusion_iff_depthDominates` :  `TheoryIncl c c' N ↔ DepthDominates c c' N`, where
  `DepthDominates c c' N` says that depths only increase **and that a depth may
  strictly increase only at a tag of maximal depth**:

  * `∀ i, depthVec c N i ≤ depthVec c' N i`, and
  * `∀ i j, depthVec c N i < depthVec c' N i → depthVec c N j ≤ depthVec c N i`.

Equivalently (`theoryIncl_iff_truncation`) the weakenings of a theory are exactly its
**truncations**: `TheoryIncl c c' N ↔ ∃ D ≤ N, depthVec c N = min D ∘ depthVec c' N`.

Two structural consequences follow at once:

* `theoryIncl_chain` — the weakenings of a fixed theory are linearly ordered by
  inclusion (a *chain*, not merely a poset), and
* `theoryIncl_pigeonhole` — a theory has at most `N + 1` weakenings inside the family:
  among any `N + 2` of them two coincide.

The counterexample separating the conjectured criterion from the true one is explicit:
`N = 2`, `c = (0, 1, 1, …)`, `c' = (1, 2, 2, …)`.  Conditions 1 and 2 both hold, yet
the formula

  `□_0 ⊥ → (¬ □_1 ⊥ → ¬ □_1 □_1 ⊥)`

(the general witness `liftWitness 0 1 1`) is provable in `capC c' 2` and refuted in
`capC c 2`.  The mechanism is that raising the depth of tag `0` from `0` to `1` makes
the world `1` of the old model — at which tag `0` is dead while tag `1` is alive and
has depth exactly `1` — disappear from the new model, without any world of the new
model reproducing it.

## Relation to `Combinatorics.DepthVectorInclusion`, and what is new here

That file characterises the same inclusion by a *level-indexed* condition,
`LevelAgree c c' N`, and exhibits a counterexample to the conjecture at height `N = 3`.
The present file adds three things.

* A *tag-indexed* criterion, `DepthDominates`, together with the arithmetic bridge
  `levelAgree_iff_depthDominates` proving the two criteria equivalent — an identity
  between a level quantifier and a tag quantifier that needs no modal semantics, and
  which via `theoryLE_iff_depthDominates` reproves the inclusion theorem by a second,
  independent route.
* An **unconditional** truncation theorem `theoryIncl_iff_truncation` (the catalog
  version `capC_inclusion_iff_truncation` assumes that the maximal depth is attained by
  a named tag), obtained from the `topDepth` operator built with `Nat.findGreatest`.
* The **exact threshold** of the refuted conjecture,
  `conjecturedCriterion_sufficient_iff_le_one` : the conjectured criterion implies
  inclusion for all height functions **iff** `N ≤ 1`.  So the failure begins at height
  `2`, one step lower than the catalog counterexample, and the low-height cases where
  the conjecture is a theorem are delimited exactly.
-/

namespace DepthDomination

open PhysicsConsistency
open ProofSystemCollapse
open Form

/-! ## §1. Depth vectors, inclusion, and the criterion -/

/-- The **depth vector** of a height function: the truncated height `min N (c i)`, which
by `capC_provable_boxPow_bot_iff` is exactly the depth of provable inconsistency of the
tag `i` in `capC c N`. -/
def depthVec (c : ℕ → ℕ) (N i : ℕ) : ℕ := min N (c i)

@[simp] theorem depthVec_eq (c : ℕ → ℕ) (N i : ℕ) : depthVec c N i = min N (c i) := rfl

theorem depthVec_le (c : ℕ → ℕ) (N i : ℕ) : depthVec c N i ≤ N := Nat.min_le_left _ _

/-- `capC c N` is **weaker than** `capC c' N`: every theorem of the latter is a theorem
of the former.  (Inclusion of theories, written with the weaker theory first.) -/
def TheoryIncl (c c' : ℕ → ℕ) (N : ℕ) : Prop :=
  ∀ a : Form, Provable (capC c' N) a → Provable (capC c N) a

/-- **The exact criterion.**  Depths may only increase, and a depth may increase
strictly only at a tag whose depth is already maximal. -/
def DepthDominates (c c' : ℕ → ℕ) (N : ℕ) : Prop :=
  (∀ i, depthVec c N i ≤ depthVec c' N i) ∧
    (∀ i j, depthVec c N i < depthVec c' N i → depthVec c N j ≤ depthVec c N i)

/-- The criterion conjectured in the previous cycle: pointwise growth together with
preservation of the relative order of the depths. -/
def ConjecturedCriterion (c c' : ℕ → ℕ) (N : ℕ) : Prop :=
  (∀ i, depthVec c N i ≤ depthVec c' N i) ∧
    (∀ i j, depthVec c' N i ≤ depthVec c' N j → depthVec c N i ≤ depthVec c N j)

/-! ## §2. Two semantic transfer lemmas -/

/-- If two height functions declare the same tags alive at every level `≤ M`, then they
satisfy the same formulas at every world `≤ M`. -/
theorem satC_congr_below {c c' : ℕ → ℕ} {M : ℕ}
    (h : ∀ i n, n ≤ M → (n ≤ c i ↔ n ≤ c' i)) :
    ∀ (a : Form) (m : ℕ), m ≤ M → satC c m a = satC c' m a := by
  intro a
  induction a with
  | bot => intro m _; rfl
  | atom _ => intro m _; rfl
  | imp a b iha ihb => intro m hm; simp only [satC, iha m hm, ihb m hm]
  | box i a ih =>
      intro m hm
      have hflag := h i m hm
      rw [Bool.eq_iff_iff, satC_box, satC_box]
      constructor
      · intro hb hle n hn
        rw [← ih n (by omega)]
        exact hb (hflag.2 hle) n hn
      · intro hb hle n hn
        rw [ih n (by omega)]
        exact hb (hflag.1 hle) n hn

/-- A world is **dead** when no tag has a successor there: either it is the root, or it
lies above every tag's height. -/
def DeadWorld (c : ℕ → ℕ) (m : ℕ) : Prop := m = 0 ∨ ∀ i, c i < m

theorem deadWorld_zero (c : ℕ → ℕ) : DeadWorld c 0 := Or.inl rfl

/-- At a dead world every box is vacuously true. -/
theorem satC_box_of_dead {c : ℕ → ℕ} {m : ℕ} (h : DeadWorld c m) (i : ℕ) (a : Form) :
    satC c m (box i a) = true := by
  rw [satC_box]
  rcases h with rfl | h
  · intro _ n hn; omega
  · intro hle n _; exact absurd (h i) (by omega)

/-- **All dead worlds are modally indistinguishable**, across different height
functions: every formula takes the same value at any two of them. -/
theorem satC_eq_of_deadWorld {c c' : ℕ → ℕ} {m m' : ℕ}
    (h : DeadWorld c m) (h' : DeadWorld c' m') (a : Form) :
    satC c m a = satC c' m' a := by
  induction a with
  | bot => rfl
  | atom _ => rfl
  | imp a b iha ihb => simp only [satC, iha, ihb]
  | box i a _ => rw [satC_box_of_dead h, satC_box_of_dead h']

/-! ## §3. Sufficiency of the criterion -/

/-- **The criterion is sufficient.**  If depths only increase and strict increases occur
only at maximal-depth tags, then every theorem of `capC c' N` is a theorem of
`capC c N`.

The proof matches each world `m ≤ N` of the model of `c` with a world of the model of
`c'`: a dead world is matched with the root, and a live world with *itself*, because
the two height functions then declare exactly the same tags alive at all levels `≤ m`.
-/
theorem theoryIncl_of_depthDominates {c c' : ℕ → ℕ} {N : ℕ}
    (h : DepthDominates c c' N) : TheoryIncl c c' N := by
  obtain ⟨h1, h2⟩ := h
  intro a ha
  rw [provable_capC] at ha ⊢
  intro m hm
  by_cases hdead : DeadWorld c m
  · rw [satC_eq_of_deadWorld hdead (deadWorld_zero c') a]
    exact ha 0 (Nat.zero_le N)
  · obtain ⟨hm0, i0, hi0⟩ : m ≠ 0 ∧ ∃ i, m ≤ c i := by
      rw [DeadWorld] at hdead
      push_neg at hdead
      obtain ⟨hm0, i0, hi0⟩ := hdead
      exact ⟨hm0, i0, hi0⟩
    have hflags : ∀ i n, n ≤ m → (n ≤ c i ↔ n ≤ c' i) := by
      intro i n hn
      have hd1 := h1 i
      simp only [depthVec_eq] at hd1
      constructor
      · intro hc; omega
      · intro hc'
        by_contra hc
        have hgt : depthVec c N i < depthVec c' N i := by
          simp only [depthVec_eq]; omega
        have hmax := h2 i i0 hgt
        simp only [depthVec_eq] at hmax
        omega
    rw [satC_congr_below hflags a m le_rfl]
    exact ha m hm

/-! ## §4. Necessity: reading the depths and their order off the theory -/

/-- **Depths can only increase.**  This half of the criterion is read off the iterated
boxed falsa via `capC_provable_boxPow_bot_iff`. -/
theorem depthVec_le_of_theoryIncl {c c' : ℕ → ℕ} {N : ℕ} (h : TheoryIncl c c' N)
    (i : ℕ) : depthVec c N i ≤ depthVec c' N i := by
  by_contra hlt
  simp only [depthVec_eq] at hlt
  push_neg at hlt
  have hp : Provable (capC c' N) (boxPow i (min N (c' i) + 1) bot) := by
    rw [capC_provable_boxPow_bot_iff]; omega
  have hq := h _ hp
  rw [capC_provable_boxPow_bot_iff] at hq
  omega

/-- The **order witness**: the formula `□_i ⊥ → (¬ □_j^m ⊥ → ¬ □_j^{m+1} ⊥)`.  It says:
*if tag `i` is dead, then tag `j` does not have depth exactly `m`.* -/
def liftWitness (i j m : ℕ) : Form :=
  imp (box i bot) (imp (neg (boxPow j m bot)) (neg (boxPow j (m + 1) bot)))

/-- The order witness is a theorem whenever tag `i` is still alive at level `m`: at any
world where `□_i ⊥` holds and tag `j` has depth exactly `m`, the world would have to be
`m` itself, where `□_i ⊥` fails. -/
theorem provable_liftWitness (c : ℕ → ℕ) (N i j m : ℕ) (hm : 1 ≤ m) (hi : m ≤ c i) :
    Provable (capC c N) (liftWitness i j m) := by
  rw [provable_capC]
  intro w _
  rw [liftWitness, satC_imp]
  intro hp
  rw [satC_imp]
  intro hnq
  rw [neg, satC_imp]
  intro hr
  exfalso
  -- `hp` : `□_i ⊥` holds at `w`
  have hp' : w = 0 ∨ c i < w := (satC_box_bot_iff c w i).1 hp
  -- `hnq` : `□_j^m ⊥` fails at `w`
  rw [neg, satC_imp] at hnq
  have hq' : ¬ (1 ≤ m ∧ (w < m ∨ c j < w)) := by
    intro hx
    have := hnq ((satC_boxPow_bot c j m w).2 hx)
    simp [satC] at this
  -- `hr` : `□_j^{m+1} ⊥` holds at `w`
  have hr' : 1 ≤ m + 1 ∧ (w < m + 1 ∨ c j < w) := (satC_boxPow_bot c j (m + 1) w).1 hr
  omega

/-- The order witness **fails** in a model where tag `i` is dead at level `m` while tag
`j` still has depth exactly `m`: it is refuted at the world `m`. -/
theorem not_provable_liftWitness (c : ℕ → ℕ) (N i j m : ℕ) (hm : 1 ≤ m) (hmN : m ≤ N)
    (hi : c i < m) (hj : m ≤ c j) : ¬ Provable (capC c N) (liftWitness i j m) := by
  rw [provable_capC]
  intro hprov
  have hw := hprov m hmN
  rw [liftWitness, satC_imp] at hw
  have hp : satC c m (box i bot) = true := (satC_box_bot_iff c m i).2 (Or.inr hi)
  have hstep := (satC_imp c m _ _).1 (hw hp)
  have hnq : satC c m (neg (boxPow j m bot)) = true := by
    rw [neg, satC_imp]
    intro hq
    exact absurd ((satC_boxPow_bot c j m m).1 hq) (by omega)
  have hfin := hstep hnq
  rw [neg, satC_imp] at hfin
  have hr : satC c m (boxPow j (m + 1) bot) = true :=
    (satC_boxPow_bot c j (m + 1) m).2 ⟨by omega, Or.inl (by omega)⟩
  have := hfin hr
  simp [satC] at this

/-- **A depth may increase strictly only at a maximal-depth tag.**  If the depth of `i`
strictly grows while some tag `j` is deeper than `i`, the order witness
`liftWitness i j (depthVec c N i + 1)` is a theorem of the new theory but not of the
old one. -/
theorem depthVec_max_of_theoryIncl {c c' : ℕ → ℕ} {N : ℕ} (h : TheoryIncl c c' N)
    (i j : ℕ) (hij : depthVec c N i < depthVec c' N i) :
    depthVec c N j ≤ depthVec c N i := by
  by_contra hgt
  simp only [depthVec_eq] at hij hgt
  push_neg at hgt
  set m := min N (c i) + 1 with hmdef
  have hNi : min N (c i) < N := by have := Nat.min_le_left N (c' i); omega
  have hci : c i < m := by omega
  have hmN : m ≤ N := by have := Nat.min_le_left N (c j); omega
  have hcj : m ≤ c j := by have := Nat.min_le_right N (c j); omega
  have hci' : m ≤ c' i := by have := Nat.min_le_right N (c' i); omega
  exact not_provable_liftWitness c N i j m (by omega) hmN hci hcj
    (h _ (provable_liftWitness c' N i j m (by omega) hci'))

/-! ## §5. The exact inclusion criterion -/

/-- **Main theorem: the exact criterion for inclusion of finite-height tag-sensitive
theories.**  `capC c' N ⊆ capC c N` holds precisely when the depth vector of `c` is
pointwise below that of `c'` *and* every tag whose depth strictly increases already has
maximal depth for `c`. -/
theorem capC_inclusion_iff_depthDominates (c c' : ℕ → ℕ) (N : ℕ) :
    TheoryIncl c c' N ↔ DepthDominates c c' N :=
  ⟨fun h => ⟨depthVec_le_of_theoryIncl h, fun i j hij => depthVec_max_of_theoryIncl h i j hij⟩,
    theoryIncl_of_depthDominates⟩

/-- **The conjectured criterion is necessary.**  Both conditions of the conjecture do
follow from inclusion; it is only their sufficiency that fails. -/
theorem conjecturedCriterion_of_theoryIncl {c c' : ℕ → ℕ} {N : ℕ}
    (h : TheoryIncl c c' N) : ConjecturedCriterion c c' N := by
  obtain ⟨h1, h2⟩ := (capC_inclusion_iff_depthDominates c c' N).1 h
  refine ⟨h1, fun i j hij => ?_⟩
  have h1i := h1 i
  rcases Nat.eq_or_lt_of_le (h1 j) with heq | hlt
  · omega
  · have := h2 j i hlt; omega

/-! ## §6. The conjecture is false -/

/-- The lower height function `c = (0, 1, 1, …)`. -/
def cSmall : ℕ → ℕ := fun k => if k = 0 then 0 else 1

/-- The upper height function `c' = (1, 2, 2, …)`. -/
def cBig : ℕ → ℕ := fun k => if k = 0 then 1 else 2

@[simp] theorem depthVec_cSmall (i : ℕ) : depthVec cSmall 2 i = if i = 0 then 0 else 1 := by
  by_cases h : i = 0 <;> simp [depthVec, cSmall, h]

@[simp] theorem depthVec_cBig (i : ℕ) : depthVec cBig 2 i = if i = 0 then 1 else 2 := by
  by_cases h : i = 0 <;> simp [depthVec, cBig, h]

/-- **The conjectured criterion holds for the pair `(cSmall, cBig)`.**  Depths increase
pointwise (`0 ≤ 1`, `1 ≤ 2`) and their relative order is undisturbed. -/
theorem conjecturedCriterion_cSmall_cBig : ConjecturedCriterion cSmall cBig 2 := by
  constructor
  · intro i
    rw [depthVec_cSmall, depthVec_cBig]
    split_ifs <;> omega
  · intro i j hij
    rw [depthVec_cBig, depthVec_cBig] at hij
    rw [depthVec_cSmall, depthVec_cSmall]
    split_ifs at hij ⊢ <;> omega

/-- **But the inclusion fails**, witnessed by the explicit formula
`□_0 ⊥ → (¬ □_1 ⊥ → ¬ □_1 □_1 ⊥)`: it is a theorem of `capC cBig 2` and is refuted in
`capC cSmall 2` at the world `1`, where tag `0` is dead and tag `1` has depth exactly
`1`. -/
theorem liftWitness_separates :
    Provable (capC cBig 2) (liftWitness 0 1 1) ∧
      ¬ Provable (capC cSmall 2) (liftWitness 0 1 1) := by
  refine ⟨provable_liftWitness cBig 2 0 1 1 le_rfl (by simp [cBig]), ?_⟩
  exact not_provable_liftWitness cSmall 2 0 1 1 le_rfl (by omega) (by simp [cSmall])
    (by simp [cSmall])

/-- **The order-preservation conjecture is false.**  The pair `(cSmall, cBig)` satisfies
both conjectured conditions, yet the theory of `cBig` is not contained in the theory of
`cSmall`; the separating formula is explicit. -/
theorem inclusion_order_criterion_false :
    ConjecturedCriterion cSmall cBig 2 ∧ ¬ TheoryIncl cSmall cBig 2 ∧
      Provable (capC cBig 2) (liftWitness 0 1 1) ∧
      ¬ Provable (capC cSmall 2) (liftWitness 0 1 1) :=
  ⟨conjecturedCriterion_cSmall_cBig,
    fun h => liftWitness_separates.2 (h _ liftWitness_separates.1),
    liftWitness_separates.1, liftWitness_separates.2⟩

/-- **The conjectured criterion is strictly weaker than inclusion.** -/
theorem conjectured_criterion_insufficient :
    ¬ ∀ (c c' : ℕ → ℕ) (N : ℕ), ConjecturedCriterion c c' N → TheoryIncl c c' N :=
  fun hall => inclusion_order_criterion_false.2.1
    (hall cSmall cBig 2 conjecturedCriterion_cSmall_cBig)

/-! ## §7. Weakenings are truncations -/

/-- The **top depth** of a height function: the largest depth attained by a tag. -/
noncomputable def topDepth (c : ℕ → ℕ) (N : ℕ) : ℕ :=
  @Nat.findGreatest (fun k => ∃ i, k ≤ min N (c i)) (Classical.decPred _) N

theorem topDepth_le (c : ℕ → ℕ) (N : ℕ) : topDepth c N ≤ N :=
  @Nat.findGreatest_le (fun k => ∃ i, k ≤ min N (c i)) (Classical.decPred _) N

theorem depthVec_le_topDepth (c : ℕ → ℕ) (N i : ℕ) : depthVec c N i ≤ topDepth c N := by
  letI : DecidablePred (fun k => ∃ i, k ≤ min N (c i)) := Classical.decPred _
  exact Nat.le_findGreatest (Nat.min_le_left _ _) ⟨i, le_rfl⟩

theorem exists_depthVec_eq_topDepth (c : ℕ → ℕ) (N : ℕ) :
    ∃ i, depthVec c N i = topDepth c N := by
  letI : DecidablePred (fun k => ∃ i, k ≤ min N (c i)) := Classical.decPred _
  obtain ⟨i, hi⟩ :=
    Nat.findGreatest_spec (P := fun k => ∃ i, k ≤ min N (c i)) (m := 0)
      (Nat.zero_le N) ⟨0, Nat.zero_le _⟩
  exact ⟨i, le_antisymm (depthVec_le_topDepth c N i) hi⟩

/-- **Weakenings are exactly truncations.**  `capC c N` is weaker than `capC c' N`
precisely when its depth vector is the depth vector of `c'` truncated at a single
uniform level `D ≤ N`. -/
theorem theoryIncl_iff_truncation (c c' : ℕ → ℕ) (N : ℕ) :
    TheoryIncl c c' N ↔ ∃ D ≤ N, ∀ i, depthVec c N i = min D (depthVec c' N i) := by
  rw [capC_inclusion_iff_depthDominates]
  constructor
  · rintro ⟨h1, h2⟩
    obtain ⟨i0, hi0⟩ := exists_depthVec_eq_topDepth c N
    refine ⟨topDepth c N, topDepth_le c N, fun i => ?_⟩
    have hb := depthVec_le_topDepth c N i
    rcases Nat.eq_or_lt_of_le (h1 i) with heq | hlt
    · omega
    · have hmax := h2 i i0 hlt
      omega
  · rintro ⟨D, hD, hEq⟩
    refine ⟨fun i => by have := hEq i; omega, fun i j hij => ?_⟩
    have hi := hEq i
    have hj := hEq j
    omega

/-- **The weakenings of a theory form a chain.**  Any two theories weaker than a fixed
`capC c' N` are comparable — the inclusion order on the family below a given theory is
linear, which is exactly what `theoryIncl_iff_truncation` predicts. -/
theorem theoryIncl_chain {c₁ c₂ c' : ℕ → ℕ} {N : ℕ}
    (h1 : TheoryIncl c₁ c' N) (h2 : TheoryIncl c₂ c' N) :
    TheoryIncl c₁ c₂ N ∨ TheoryIncl c₂ c₁ N := by
  obtain ⟨D₁, hD₁, hE₁⟩ := (theoryIncl_iff_truncation c₁ c' N).1 h1
  obtain ⟨D₂, hD₂, hE₂⟩ := (theoryIncl_iff_truncation c₂ c' N).1 h2
  rcases Nat.le_total D₁ D₂ with hle | hle
  · left
    refine (theoryIncl_iff_truncation c₁ c₂ N).2 ⟨D₁, hD₁, fun i => ?_⟩
    have := hE₁ i
    have := hE₂ i
    omega
  · right
    refine (theoryIncl_iff_truncation c₂ c₁ N).2 ⟨D₂, hD₂, fun i => ?_⟩
    have := hE₁ i
    have := hE₂ i
    omega

/-- **A theory has at most `N + 1` weakenings.**  Among any `N + 2` height functions all
of whose theories are weaker than a fixed `capC c' N`, two generate literally the same
theory. -/
theorem theoryIncl_pigeonhole (c' : ℕ → ℕ) (N : ℕ) (f : Fin (N + 2) → ℕ → ℕ)
    (hf : ∀ a, TheoryIncl (f a) c' N) :
    ∃ a b : Fin (N + 2), a ≠ b ∧
      ∀ x : Form, Provable (capC (f a) N) x ↔ Provable (capC (f b) N) x := by
  choose D hD hEq using fun a => (theoryIncl_iff_truncation (f a) c' N).1 (hf a)
  have hcard : Fintype.card (Fin (N + 1)) < Fintype.card (Fin (N + 2)) := by simp
  obtain ⟨a, b, hab, heq⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt
      (fun a : Fin (N + 2) => (⟨D a, by have := hD a; omega⟩ : Fin (N + 1))) hcard
  have hDab : D a = D b := congrArg Fin.val heq
  refine ⟨a, b, hab, fun x => provable_capC_congr_of_min_eq (fun i => ?_) x⟩
  have h1 := hEq a i
  have h2 := hEq b i
  simp only [depthVec_eq] at h1 h2
  omega

/-! ## §8. Order-theoretic corollaries of the criterion -/

/-- The criterion is reflexive. -/
theorem depthDominates_refl (c : ℕ → ℕ) (N : ℕ) : DepthDominates c c N :=
  ⟨fun _ => le_rfl, fun i j hij => absurd hij (by omega)⟩

/-- **The criterion is transitive** — a fact that is entirely opaque on the arithmetic
side, but immediate once it is identified with inclusion of theories. -/
theorem depthDominates_trans {c₁ c₂ c₃ : ℕ → ℕ} {N : ℕ}
    (h1 : DepthDominates c₁ c₂ N) (h2 : DepthDominates c₂ c₃ N) :
    DepthDominates c₁ c₃ N :=
  (capC_inclusion_iff_depthDominates c₁ c₃ N).1
    (fun a ha => (capC_inclusion_iff_depthDominates c₁ c₂ N).2 h1 a ((capC_inclusion_iff_depthDominates c₂ c₃ N).2 h2 a ha))

/-- **Mutual inclusion is equality of depth vectors** — and hence, by
`provable_capC_congr_of_min_eq`, equality of the theories. -/
theorem depthVec_eq_of_mutual_incl {c c' : ℕ → ℕ} {N : ℕ}
    (h : TheoryIncl c c' N) (h' : TheoryIncl c' c N) (i : ℕ) :
    depthVec c N i = depthVec c' N i :=
  le_antisymm (depthVec_le_of_theoryIncl h i) (depthVec_le_of_theoryIncl h' i)

/-- **Constant-depth theories are weaker than everything above them.**  If all tags of
`c` have the same depth `d`, then every `c'` whose depths dominate `d` gives a stronger
theory.  This is the extreme case of the criterion, and explains why the failure of the
pointwise order is a genuinely *relational* phenomenon. -/
theorem theoryIncl_of_constant_depth {c c' : ℕ → ℕ} {N d : ℕ}
    (hc : ∀ i, depthVec c N i = d) (hd : ∀ i, d ≤ depthVec c' N i) :
    TheoryIncl c c' N :=
  (capC_inclusion_iff_depthDominates c c' N).2
    ⟨fun i => by rw [hc i]; exact hd i, fun i j _ => by rw [hc i, hc j]⟩

/-! ## §9. Reconciliation with the level-agreement criterion

`Combinatorics.DepthVectorInclusion` characterises the same inclusion by the
*level-agreement* condition

  `LevelAgree c c' N : ∀ m ≤ N, (∃ i, m ≤ c i) → ∀ j, min m (c j) = min m (c' j)`,

a statement quantified over the *levels* of the two models.  The criterion proved here
is quantified over the *tags* instead.  The two are equivalent, and the equivalence is
a purely arithmetic fact about truncations, provable without any reference to the modal
semantics. -/

/-- **The level-agreement criterion and the depth-domination criterion coincide.**

Left to right: the depth `min N (c i)` is itself an alive level, which forces
`min N (c i) ≤ min N (c' i)`; and if the depth of `i` strictly grows while some tag `j`
is deeper, the level `min N (c i) + 1` is alive in `c` and the two functions disagree
there.  Right to left: at an alive level `m`, a tag `j` whose depth strictly grows must
be of maximal `c`-depth, hence at least `m` deep in *both* models, so both truncations
equal `m`. -/
theorem levelAgree_iff_depthDominates (c c' : ℕ → ℕ) (N : ℕ) :
    LevelAgree c c' N ↔ DepthDominates c c' N := by
  constructor
  · intro h
    have h1 : ∀ i, depthVec c N i ≤ depthVec c' N i := by
      intro i
      have hmN : min N (c i) ≤ N := Nat.min_le_left _ _
      have hci : min N (c i) ≤ c i := Nat.min_le_right _ _
      have hkey := h (min N (c i)) hmN ⟨i, hci⟩ i
      simp only [depthVec_eq]
      omega
    refine ⟨h1, fun i j hij => ?_⟩
    by_contra hgt
    have h1i := h1 i
    simp only [depthVec_eq] at h1i hij hgt
    push_neg at hgt
    have hmN : min N (c i) + 1 ≤ N := by
      have := Nat.min_le_left N (c j); omega
    have hcj : min N (c i) + 1 ≤ c j := by
      have := Nat.min_le_right N (c j); omega
    have hci' : min N (c i) + 1 ≤ c' i := by
      have := Nat.min_le_right N (c' i); omega
    have hkey := h (min N (c i) + 1) hmN ⟨j, hcj⟩ i
    omega
  · rintro ⟨h1, h2⟩ m hmN ⟨i0, hi0⟩ j
    have hd1 := h1 j
    rcases Nat.eq_or_lt_of_le hd1 with heq | hlt
    · simp only [depthVec_eq] at heq
      omega
    · have hmax := h2 j i0 hlt
      simp only [depthVec_eq] at hlt hmax
      omega

/-- **The two criteria describe the same inclusion.**  Combining the level-agreement
theorem of `Combinatorics.DepthVectorInclusion` with the bridge above reproves the main
theorem of §5 by an independent route, and conversely certifies that the two catalog
criteria are the same condition. -/
theorem theoryLE_iff_depthDominates (c c' : ℕ → ℕ) (N : ℕ) :
    TheoryLE c c' N ↔ DepthDominates c c' N :=
  (PhysicsConsistency.capC_inclusion_iff c c' N).trans (levelAgree_iff_depthDominates c c' N)

/-! ## §10. The exact threshold at which the conjectured criterion breaks down -/

/-- **Below height `2` the conjectured criterion is correct.**  If `N ≤ 1` every depth
is `0` or `1`, and a strict increase at `i` forces `min N (c i) = 0`,
`min N (c' i) = 1 = N`; any tag `j` of depth `1` would then violate the conjectured
order condition applied to the pair `(j, i)`. -/
theorem depthDominates_of_conjecturedCriterion_of_le_one {c c' : ℕ → ℕ} {N : ℕ}
    (hN : N ≤ 1) (h : ConjecturedCriterion c c' N) : DepthDominates c c' N := by
  obtain ⟨h1, h2⟩ := h
  refine ⟨h1, fun i j hij => ?_⟩
  by_contra hgt
  push_neg at hgt
  have hbj := depthVec_le c N j
  have hb'i := depthVec_le c' N i
  have hb'j := depthVec_le c' N j
  have hji : depthVec c' N j ≤ depthVec c' N i := by omega
  have := h2 j i hji
  omega

/-- The conjectured criterion holds for the pair `(cSmall, cBig)` at every height
`N ≥ 2`. -/
theorem conjecturedCriterion_cSmall_cBig_of_two_le {N : ℕ} (hN : 2 ≤ N) :
    ConjecturedCriterion cSmall cBig N := by
  have hs : ∀ i, depthVec cSmall N i = if i = 0 then 0 else 1 := by
    intro i
    by_cases h : i = 0
    · simp [depthVec, cSmall, h]
    · simp only [depthVec, cSmall, h, if_false]
      omega
  have hb : ∀ i, depthVec cBig N i = if i = 0 then 1 else 2 := by
    intro i
    by_cases h : i = 0
    · simp only [depthVec, cBig, h, if_true]
      omega
    · simp only [depthVec, cBig, h, if_false]
      omega
  constructor
  · intro i; rw [hs, hb]; split_ifs <;> omega
  · intro i j hij
    rw [hb, hb] at hij
    rw [hs, hs]
    split_ifs at hij ⊢ <;> omega

/-- The separating formula works at every height `N ≥ 1`. -/
theorem liftWitness_separates_of_one_le {N : ℕ} (hN : 1 ≤ N) :
    Provable (capC cBig N) (liftWitness 0 1 1) ∧
      ¬ Provable (capC cSmall N) (liftWitness 0 1 1) := by
  refine ⟨provable_liftWitness cBig N 0 1 1 le_rfl (by simp [cBig]), ?_⟩
  exact not_provable_liftWitness cSmall N 0 1 1 le_rfl hN (by simp [cSmall])
    (by simp [cSmall])

/-- **The exact threshold.**  The conjectured order-preservation criterion is a correct
description of inclusion precisely for the heights `N ≤ 1`; from height `2` upwards it
is strictly weaker than inclusion, so `N = 2` is the least height at which the
conjecture fails. -/
theorem conjecturedCriterion_sufficient_iff_le_one (N : ℕ) :
    (∀ c c' : ℕ → ℕ, ConjecturedCriterion c c' N → TheoryIncl c c' N) ↔ N ≤ 1 := by
  constructor
  · intro h
    by_contra hN
    push_neg at hN
    obtain ⟨hp, hnp⟩ := liftWitness_separates_of_one_le (N := N) (by omega)
    exact hnp (h cSmall cBig (conjecturedCriterion_cSmall_cBig_of_two_le (by omega)) _ hp)
  · intro hN c c' h
    exact theoryIncl_of_depthDominates (depthDominates_of_conjecturedCriterion_of_le_one hN h)

/-- **Summary.**  The conjectured order-preservation criterion is refuted, the exact
criterion is established, and the resulting inclusion order is described: weakenings are
truncations, and they form a chain of length at most `N + 1`. -/
theorem domination_criterion_summary :
    (∀ (c c' : ℕ → ℕ) (N : ℕ), TheoryIncl c c' N ↔ DepthDominates c c' N) ∧
      (∀ (c c' : ℕ → ℕ) (N : ℕ), TheoryIncl c c' N →
        ConjecturedCriterion c c' N) ∧
      (ConjecturedCriterion cSmall cBig 2 ∧ ¬ TheoryIncl cSmall cBig 2) ∧
      (∀ (c c' : ℕ → ℕ) (N : ℕ), TheoryIncl c c' N ↔
        ∃ D ≤ N, ∀ i, depthVec c N i = min D (depthVec c' N i)) ∧
      (∀ N : ℕ, (∀ c c' : ℕ → ℕ, ConjecturedCriterion c c' N → TheoryIncl c c' N) ↔ N ≤ 1) :=
  ⟨capC_inclusion_iff_depthDominates, fun _ _ _ h => conjecturedCriterion_of_theoryIncl h,
    ⟨conjecturedCriterion_cSmall_cBig, inclusion_order_criterion_false.2.1⟩,
    theoryIncl_iff_truncation, conjecturedCriterion_sufficient_iff_le_one⟩

end DepthDomination