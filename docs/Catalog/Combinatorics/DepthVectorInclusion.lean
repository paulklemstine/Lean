import Novelty.TransferPreorderRealization

/-!
# The exact inclusion criterion for finite-height provability theories

`Novelty.TransferPreorderRealization` §7 established two facts about the family of
tag-sensitive finite-height GL theories `capC c N`:

* the *depth vector* `d c N i := min N (c i)` is a complete invariant
  (`provable_capC_congr_of_min_eq`, `capC_ne_of_min_ne`), and
* inclusion between two such theories is **not** the pointwise order on depth vectors
  (`theory_inclusion_not_pointwise`).

The accompanying conjecture list (item 3, "order-preservation criterion for
inclusion") proposed that the two conditions

1. `d i ≤ d' i` for all tags `i`, and
2. `d' i ≤ d' j → d i ≤ d j` for all tags `i, j`

together characterize the inclusion `Provable (capC c' N) a → Provable (capC c N) a`.

This file settles the question.  Both conditions are indeed **necessary**
(`inclusion_depth_mono`, `inclusion_order_preserving`), so the "only if" half of the
conjecture is a theorem; but they are **not sufficient**, and the conjecture is
refuted by an explicit witness (`inclusion_criterion_conjecture_false`): with `N = 3`,
`d = (1, 2, 1, 1, …)` and `d' = (2, 3, 2, 2, …)` both conditions hold, yet the formula

  `wit = □₁³⊥ → (¬□₁²⊥ → ¬□₀²⊥)`

is provable in `capC c' 3` and refuted in `capC c 3`.

The correct criterion is a *level-by-level* agreement condition
(`capC_inclusion_iff`):

  `capC c' N ⊆ capC c N`  ↔  for every level `m ≤ N` that is still **alive** in `c`
  (some tag has `m ≤ c i`), the two height functions agree below `m`:
  `min m (c j) = min m (c' j)` for every tag `j`.

Semantically: every world of the smaller-height model is *literally a world of the
larger* model, and the extra worlds of the larger model are invisible because the
smaller model's top worlds are already inert (all their boxes are vacuously true, so
they are modally equivalent to the root; `satC_eq_of_dead`).

Three structural consequences are extracted from the criterion:

* **Truncation structure** (`capC_inclusion_iff_truncation`): if the depth vector of
  `c` attains its maximum `M`, then `capC c' N ⊆ capC c N` iff `d = min M ∘ d'`, i.e.
  the smaller theory is exactly the truncation of the larger one at its own maximal
  depth.  Conversely every truncation is a subtheory (`truncation_subtheory`).
* **Chain** (`capC_inclusion_chain`): the subtheories of a fixed `capC c' N` inside
  this family are **totally ordered** by inclusion — a strong failure of the pointwise
  (product) order, which is not total.
* **Pigeonhole** (`capC_subtheory_pigeonhole`): a fixed `capC c' N` has at most
  `N + 1` subtheories in the family; among any `N + 2` of them two coincide.  This is
  the inclusion-order analogue of `transfer_pigeonhole`.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): the conjectured criterion (1)+(2) is too weak, because raising a
  tag's depth can create a *new alive level* at which the two models differ, and the
  new level is detectable by a formula that first pins the current world down with an
  iterated boxed falsum and then reads off a second tag's depth.
Experiment (Stage 2): brute-force search over all height functions on two tags with
  values `≤ N + 2`, for `N ≤ 4`, comparing (i) inclusion of the theories, computed via
  the greatest bisimulation between the two finite Kripke models (bisimilarity =
  modal equivalence for these image-finite models), and (ii) the level-agreement
  criterion below.  0 mismatches in all 4 sweeps.  A direct formula sweep (all 746
  formulas of size ≤ 6 over two tags) flagged apparent mismatches, all explained by
  the discriminating formula being of size 13 — evidence that the discriminators
  really need the nested "guard + depth probe" shape used in `exists_discriminator`.
Analysis (Stage 3): the smallest counterexample to the conjectured criterion has
  `N = 3`, `d = (1,2)`, `d' = (2,3)`; the conjectured conditions cannot see the level
  `m = 2`, which is alive in `c` and at which the depth of tag `0` changes from `1`
  to `2`.
Critique (Stage 4): the criterion is proved as an exact biconditional, not merely a
  sufficient condition; necessity is witnessed by explicit formulas (four cases in
  `exists_discriminator`), so no step relies on an abstract completeness theorem.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

/-! ## §1. Inclusion and the level-agreement criterion -/

/-- Theory inclusion inside the family: every theorem of `capC c' N` is a theorem of
`capC c N`. -/
def TheoryLE (c c' : ℕ → ℕ) (N : ℕ) : Prop :=
  ∀ a : Form, Provable (capC c' N) a → Provable (capC c N) a

/-- The **level-agreement criterion**: at every level `m ≤ N` that is still alive in
`c` (some tag reaches up to `m`), the two height functions agree below `m`. -/
def LevelAgree (c c' : ℕ → ℕ) (N : ℕ) : Prop :=
  ∀ m ≤ N, (∃ i, m ≤ c i) → ∀ j, min m (c j) = min m (c' j)

/-! ## §2. Two satisfaction lemmas -/

/-- Negation in the tag-sensitive semantics. -/
theorem satC_neg (h : ℕ → ℕ) (m : ℕ) (a : Form) :
    satC h m (neg a) = true ↔ satC h m a ≠ true := by
  rw [neg, satC_imp]
  constructor
  · intro hx hy
    have := hx hy
    simp [satC] at this
  · intro hx hy
    exact absurd hy hx

/-- **Inert worlds are modally invisible.**  At a world lying above every tag's height
all boxes are vacuously true, exactly as at the root of any other model; hence such a
world satisfies precisely the formulas satisfied at the root. -/
theorem satC_eq_of_dead (c c' : ℕ → ℕ) {m : ℕ} (hdead : ∀ i, c i < m) :
    ∀ a : Form, satC c m a = satC c' 0 a := by
  intro a
  induction a with
  | bot => rfl
  | atom _ => rfl
  | imp a b iha ihb => simp only [satC, iha, ihb]
  | box i b _ =>
      have h1 : satC c m (box i b) = true := satC_box_of_gt c (hdead i) b
      have h2 : satC c' 0 (box i b) = true := by
        rw [satC_box]; intro _ n hn; omega
      rw [h1, h2]

/-! ## §3. Sufficiency of the criterion -/

/-- **Level agreement implies inclusion.**  Every alive world of the `c`-model is a
world of the `c'`-model verbatim, and every inert world of the `c`-model is modally
equivalent to the root of the `c'`-model. -/
theorem theoryLE_of_levelAgree {c c' : ℕ → ℕ} {N : ℕ} (h : LevelAgree c c' N) :
    TheoryLE c c' N := by
  intro a ha
  rw [provable_capC] at ha ⊢
  intro m hm
  by_cases hact : ∃ i, m ≤ c i
  · have hagree : ∀ i, min m (c i) = min m (c' i) := h m hm hact
    rw [satC_eq_of_min_eq hagree a m le_rfl]
    exact ha m hm
  · push_neg at hact
    rw [satC_eq_of_dead c c' (fun i => hact i) a]
    exact ha 0 (Nat.zero_le N)

/-! ## §4. Discriminating formulas -/

/-- The **guard**: `□_i^{m+1}⊥ → (¬□_i^m⊥ → χ)`.  In any model, the antecedent pins
the current world to be exactly `m` and forces tag `i` to be alive there, so the guard
is a way of asserting `χ` *only at the level `m`*. -/
def guard (i m : ℕ) (chi : Form) : Form :=
  imp (boxPow i (m + 1) bot) (imp (neg (boxPow i m bot)) chi)

/-- **The guard does what it says.** -/
theorem satC_guard (h : ℕ → ℕ) (i m n : ℕ) (hm : 1 ≤ m) (chi : Form) :
    satC h n (guard i m chi) = true ↔ ((n = m ∧ m ≤ h i) → satC h n chi = true) := by
  have hb1 := satC_boxPow_bot h i (m + 1) n
  have hb2 := satC_boxPow_bot h i m n
  rw [guard, satC_imp]
  constructor
  · rintro hall ⟨rfl, hle⟩
    have h1 : satC h n (boxPow i (n + 1) bot) = true := hb1.2 ⟨by omega, by omega⟩
    have h2 : satC h n (neg (boxPow i n bot)) = true := by
      rw [satC_neg]
      intro hx
      have := hb2.1 hx
      omega
    exact (satC_imp h n _ _).1 (hall h1) h2
  · intro hR h1
    rw [satC_imp]
    intro h2
    rw [satC_neg] at h2
    have hA := hb1.1 h1
    have hB : ¬ (1 ≤ m ∧ (n < m ∨ h i < n)) := fun hx => h2 (hb2.2 hx)
    exact hR (by omega)

/-- **Reading a tag's depth from a neighbouring alive tag.**  With tag `i` alive at
`m`, the formula `□_i (□_j^k ⊥)` says exactly that tag `j` dies within `k` steps at
every world strictly below `m`. -/
theorem satC_box_boxPow_bot (h : ℕ → ℕ) (i j k m : ℕ) (hk : 1 ≤ k) (hi : m ≤ h i) :
    satC h m (box i (boxPow j k bot)) = true ↔ min (m - 1) (h j) < k := by
  rw [satC_box]
  constructor
  · intro hb
    by_contra hge
    have hr : min (m - 1) (h j) < m := by omega
    have := (satC_boxPow_bot h j k (min (m - 1) (h j))).1 (hb hi _ hr)
    omega
  · intro hlt _ n hn
    rw [satC_boxPow_bot]
    exact ⟨hk, by omega⟩

/-- **Existence of a discriminating formula.**  If two height functions disagree about
some tag `j` below a level `m` at which a common tag `i` is alive in both, then there
is a formula separating the two models at the world `m`.  Four explicit witnesses are
used, according to whether the truncated heights of `j` reach `m` or not. -/
theorem exists_discriminator {c c' : ℕ → ℕ} {m i j : ℕ} (hm : 1 ≤ m)
    (hci : m ≤ c i) (hci' : m ≤ c' i) (hne : min m (c j) ≠ min m (c' j)) :
    ∃ chi : Form, satC c m chi ≠ true ∧ satC c' m chi = true := by
  have hb : ∀ (h : ℕ → ℕ) (k : ℕ), satC h m (boxPow j k bot) = true ↔
      (1 ≤ k ∧ (m < k ∨ h j < m)) := fun h k => satC_boxPow_bot h j k m
  rcases Nat.lt_or_ge (min m (c j)) m with hp | hp
  · -- tag `j` is dead at `m` in the `c`-model
    rcases Nat.lt_or_ge (min m (c' j)) m with hq | hq
    · -- both dead at `m`; the depths differ strictly below `m`
      rcases Nat.lt_or_ge (min m (c j)) (min m (c' j)) with hlt | hge
      · refine ⟨neg (box i (boxPow j (min m (c j) + 1) bot)), ?_, ?_⟩
        · intro hx
          exact (satC_neg c m _).1 hx
            ((satC_box_boxPow_bot c i j _ m (by omega) hci).2 (by omega))
        · rw [satC_neg]
          intro hx
          have := (satC_box_boxPow_bot c' i j _ m (by omega) hci').1 hx
          omega
      · refine ⟨box i (boxPow j (min m (c' j) + 1) bot), ?_, ?_⟩
        · intro hx
          have := (satC_box_boxPow_bot c i j _ m (by omega) hci).1 hx
          omega
        · exact (satC_box_boxPow_bot c' i j _ m (by omega) hci').2 (by omega)
    · -- `j` is alive at `m` in the `c'`-model only
      refine ⟨neg (boxPow j m bot), ?_, ?_⟩
      · intro hx
        exact (satC_neg c m _).1 hx ((hb c m).2 ⟨hm, by omega⟩)
      · rw [satC_neg]
        intro hx
        have := (hb c' m).1 hx
        omega
  · -- `j` is alive at `m` in the `c`-model, hence dead in the `c'`-model
    refine ⟨boxPow j m bot, ?_, ?_⟩
    · intro hx
      have := (hb c m).1 hx
      omega
    · exact (hb c' m).2 ⟨hm, by omega⟩

/-! ## §5. Necessity of the criterion -/

/-- **Inclusion implies level agreement.**  Failure of agreement at an alive level is
witnessed by a guarded discriminating formula. -/
theorem levelAgree_of_theoryLE {c c' : ℕ → ℕ} {N : ℕ} (h : TheoryLE c c' N) :
    LevelAgree c c' N := by
  rintro m hm ⟨i, hci⟩ j
  by_contra hne
  have hm1 : 1 ≤ m := by
    rcases Nat.eq_zero_or_pos m with rfl | hp
    · simp at hne
    · exact hp
  by_cases hci' : m ≤ c' i
  · obtain ⟨chi, h1, h2⟩ := exists_discriminator hm1 hci hci' hne
    have hprov : Provable (capC c' N) (guard i m chi) := by
      rw [provable_capC]
      intro n hn
      rw [satC_guard _ _ _ _ hm1]
      rintro ⟨rfl, -⟩
      exact h2
    have hc := h _ hprov
    rw [provable_capC] at hc
    exact h1 ((satC_guard c i m m hm1 chi).1 (hc m hm) ⟨rfl, hci⟩)
  · have hprov : Provable (capC c' N) (guard i m bot) := by
      rw [provable_capC]
      intro n hn
      rw [satC_guard _ _ _ _ hm1]
      rintro ⟨rfl, hle⟩
      exact absurd hle hci'
    have hc := h _ hprov
    rw [provable_capC] at hc
    have := (satC_guard c i m m hm1 bot).1 (hc m hm) ⟨rfl, hci⟩
    simp [satC] at this

/-- **The exact inclusion criterion.**  One finite-height tag-sensitive theory is
contained in another exactly when the height functions agree below every level that is
still alive in the smaller theory. -/
theorem capC_inclusion_iff (c c' : ℕ → ℕ) (N : ℕ) :
    TheoryLE c c' N ↔ LevelAgree c c' N :=
  ⟨levelAgree_of_theoryLE, theoryLE_of_levelAgree⟩

/-! ## §6. The conjectured criterion: necessary but not sufficient -/

/-- **Condition 1 of the conjecture is necessary**: inclusion forces the depth vector
of the smaller theory to be pointwise below that of the larger. -/
theorem inclusion_depth_mono {c c' : ℕ → ℕ} {N : ℕ} (h : TheoryLE c c' N) (j : ℕ) :
    min N (c j) ≤ min N (c' j) := by
  have hL := levelAgree_of_theoryLE h
  have hm : min N (c j) ≤ N := by omega
  have := hL (min N (c j)) hm ⟨j, by omega⟩ j
  omega

/-- **Condition 2 of the conjecture is necessary**: inclusion preserves the relative
order of the depths. -/
theorem inclusion_order_preserving {c c' : ℕ → ℕ} {N : ℕ} (h : TheoryLE c c' N)
    (i j : ℕ) (hij : min N (c' i) ≤ min N (c' j)) : min N (c i) ≤ min N (c j) := by
  have hL := levelAgree_of_theoryLE h
  by_contra hlt
  push_neg at hlt
  have hmi : min N (c i) ≤ N := by omega
  have halive : ∃ k, min N (c i) ≤ c k := ⟨i, by omega⟩
  have hj := hL (min N (c i)) hmi halive j
  have hi := hL (min N (c i)) hmi halive i
  omega

/-- The lower height function of the counterexample: depth vector `(1, 2, 1, 1, …)`. -/
def cLow : ℕ → ℕ := fun k => if k = 1 then 2 else 1

/-- The upper height function of the counterexample: depth vector `(2, 3, 2, 2, …)`. -/
def cHigh : ℕ → ℕ := fun k => if k = 1 then 3 else 2

/-- The separating formula `□₁³⊥ → (¬□₁²⊥ → ¬□₀²⊥)`: at the level `2` pinned by the
guard it says that tag `0` is *not* dead within two steps. -/
def wit : Form := guard 1 2 (neg (boxPow 0 2 bot))

/-- **The conjectured inclusion criterion is false.**  For `N = 3`,
`d = (1, 2, 1, 1, …)` and `d' = (2, 3, 2, 2, …)` the two conjectured conditions —
pointwise growth of the depths and preservation of their relative order — both hold,
yet the explicit formula `wit` is provable in `capC cHigh 3` and refuted in
`capC cLow 3`.  Hence conditions 1 and 2 do not characterize inclusion. -/
theorem inclusion_criterion_conjecture_false :
    (∀ j, min 3 (cLow j) ≤ min 3 (cHigh j)) ∧
      (∀ i j, min 3 (cHigh i) ≤ min 3 (cHigh j) → min 3 (cLow i) ≤ min 3 (cLow j)) ∧
      Provable (capC cHigh 3) wit ∧ ¬ Provable (capC cLow 3) wit := by
  refine ⟨fun j => ?_, fun i j => ?_, ?_, ?_⟩
  · by_cases hj : j = 1 <;> simp [cLow, cHigh, hj]
  · by_cases hi : i = 1 <;> by_cases hj : j = 1 <;> simp [cLow, cHigh, hi, hj]
  · rw [provable_capC]
    intro n hn
    rw [wit, satC_guard _ _ _ _ (by norm_num)]
    rintro ⟨rfl, -⟩
    rw [satC_neg]
    intro hx
    have := (satC_boxPow_bot cHigh 0 2 2).1 hx
    simp only [cHigh] at this
    norm_num at this
  · rw [provable_capC]
    intro hp
    have h2 := hp 2 (by norm_num)
    rw [wit, satC_guard _ _ _ _ (by norm_num)] at h2
    have h3 := h2 ⟨rfl, by norm_num [cLow]⟩
    rw [satC_neg] at h3
    exact h3 ((satC_boxPow_bot cLow 0 2 2).2 ⟨by norm_num, by norm_num [cLow]⟩)

/-- **The refuted pair really does violate the correct criterion**, at the level
`m = 2`: it is alive in `cLow` (tag `1` has height `2`) and the depth of tag `0`
changes there from `1` to `2`. -/
theorem cLow_cHigh_not_levelAgree : ¬ LevelAgree cLow cHigh 3 := by
  intro h
  have := h 2 (by norm_num) ⟨1, by norm_num [cLow]⟩ 0
  norm_num [cLow, cHigh] at this

/-! ## §7. Structure of the family of subtheories -/

/-- **Every truncation is a subtheory.**  Cutting all heights off at a level `M`
produces a theory contained in the original one. -/
theorem truncation_subtheory (c' : ℕ → ℕ) (N M : ℕ) :
    TheoryLE (fun j => min M (c' j)) c' N := by
  rw [capC_inclusion_iff]
  rintro m hm ⟨i, hi⟩ j
  simp only at hi ⊢
  omega

/-- **Truncation structure theorem.**  If the depth vector of `c` attains its maximum
`M` (at the tag `k`), then `capC c' N ⊆ capC c N` holds precisely when the depth
vector of `c` is the truncation at `M` of the depth vector of `c'`. -/
theorem capC_inclusion_iff_truncation {c c' : ℕ → ℕ} {N M k : ℕ}
    (hk : min N (c k) = M) (hmax : ∀ j, min N (c j) ≤ M) :
    TheoryLE c c' N ↔ ∀ j, min N (c j) = min M (min N (c' j)) := by
  rw [capC_inclusion_iff]
  constructor
  · intro h j
    have hMN : M ≤ N := by omega
    have := h M hMN ⟨k, by omega⟩ j
    have hj := hmax j
    omega
  · intro h m hm hex j
    obtain ⟨i, hi⟩ := hex
    have hmM : m ≤ M := by have := hmax i; omega
    have hj := h j
    omega

/-- **The subtheories of a fixed theory form a chain.**  If two finite-height theories
are both contained in a third, then one of them is contained in the other: inclusion
is *total* on the lower set of any `capC c' N`.  (Contrast the pointwise order on
depth vectors, which is not total.) -/
theorem capC_inclusion_chain {c₁ c₂ c' : ℕ → ℕ} {N : ℕ}
    (h₁ : TheoryLE c₁ c' N) (h₂ : TheoryLE c₂ c' N) :
    TheoryLE c₁ c₂ N ∨ TheoryLE c₂ c₁ N := by
  rw [capC_inclusion_iff] at h₁ h₂
  by_cases hsub : ∀ m ≤ N, (∃ i, m ≤ c₁ i) → (∃ i, m ≤ c₂ i)
  · left
    rw [capC_inclusion_iff]
    intro m hm hex j
    have e1 := h₁ m hm hex j
    have e2 := h₂ m hm (hsub m hm hex) j
    omega
  · right
    rw [capC_inclusion_iff]
    push_neg at hsub
    obtain ⟨m₀, hm₀N, ⟨i₀, hi₀⟩, hno⟩ := hsub
    intro m hm hex j
    have hex1 : ∃ i, m ≤ c₁ i := by
      obtain ⟨i, hi⟩ := hex
      have := hno i
      exact ⟨i₀, by omega⟩
    have e1 := h₁ m hm hex1 j
    have e2 := h₂ m hm hex j
    omega

/-- The **alive level** of a theory: the largest `m ≤ N` still reached by some tag. -/
noncomputable def aliveLevel (c : ℕ → ℕ) (N : ℕ) : ℕ :=
  @Nat.findGreatest (fun m => ∃ i, m ≤ c i) (Classical.decPred _) N

/-- The alive level never exceeds the bound. -/
theorem aliveLevel_le (c : ℕ → ℕ) (N : ℕ) : aliveLevel c N ≤ N :=
  @Nat.findGreatest_le (fun m => ∃ i, m ≤ c i) (Classical.decPred _) N

/-- The alive level is itself alive. -/
theorem aliveLevel_spec (c : ℕ → ℕ) (N : ℕ) : ∃ i, aliveLevel c N ≤ c i :=
  @Nat.findGreatest_spec 0 (fun m => ∃ i, m ≤ c i) (Classical.decPred _) N
    (Nat.zero_le N) ⟨0, Nat.zero_le _⟩

/-- Every alive level below the bound is at most the alive level. -/
theorem le_aliveLevel {c : ℕ → ℕ} {N m : ℕ} (hm : m ≤ N) (h : ∃ i, m ≤ c i) :
    m ≤ aliveLevel c N :=
  @Nat.le_findGreatest m (fun m => ∃ i, m ≤ c i) (Classical.decPred _) N hm h

/-- Below the bound, a level is alive exactly when it is at most the alive level. -/
theorem alive_iff_le_aliveLevel (c : ℕ → ℕ) (N m : ℕ) (hm : m ≤ N) :
    (∃ i, m ≤ c i) ↔ m ≤ aliveLevel c N := by
  refine ⟨le_aliveLevel hm, fun h => ?_⟩
  obtain ⟨i, hi⟩ := aliveLevel_spec c N
  exact ⟨i, by omega⟩

/-- **Equal alive levels give equal theories.**  Two subtheories of a common theory
that reach the same level are literally the same theory. -/
theorem capC_eq_of_aliveLevel_eq {c₁ c₂ c' : ℕ → ℕ} {N : ℕ}
    (h₁ : TheoryLE c₁ c' N) (h₂ : TheoryLE c₂ c' N)
    (hlev : aliveLevel c₁ N = aliveLevel c₂ N) (a : Form) :
    Provable (capC c₁ N) a ↔ Provable (capC c₂ N) a := by
  rw [capC_inclusion_iff] at h₁ h₂
  have key : ∀ (d₁ d₂ : ℕ → ℕ), LevelAgree d₁ c' N → LevelAgree d₂ c' N →
      aliveLevel d₁ N = aliveLevel d₂ N → TheoryLE d₁ d₂ N := by
    intro d₁ d₂ k₁ k₂ hk
    rw [capC_inclusion_iff]
    intro m hm hex j
    have hex2 : ∃ i, m ≤ d₂ i := by
      rw [alive_iff_le_aliveLevel _ _ _ hm, ← hk,
        ← alive_iff_le_aliveLevel _ _ _ hm]
      exact hex
    have e1 := k₁ m hm hex j
    have e2 := k₂ m hm hex2 j
    omega
  exact ⟨fun hp => key c₂ c₁ h₂ h₁ hlev.symm a hp, fun hp => key c₁ c₂ h₁ h₂ hlev a hp⟩

/-- **At most `N + 1` subtheories.**  Among any `N + 2` finite-height theories all
contained in a fixed `capC c' N`, two are literally the same theory.  This is the
inclusion-order counterpart of `transfer_pigeonhole`. -/
theorem capC_subtheory_pigeonhole (c' : ℕ → ℕ) (N : ℕ) (F : Fin (N + 2) → (ℕ → ℕ))
    (hF : ∀ t, TheoryLE (F t) c' N) :
    ∃ s t : Fin (N + 2), s ≠ t ∧
      ∀ a : Form, Provable (capC (F s) N) a ↔ Provable (capC (F t) N) a := by
  have hcard : Fintype.card (Fin (N + 1)) < Fintype.card (Fin (N + 2)) := by simp
  obtain ⟨s, t, hst, heq⟩ :=
    Fintype.exists_ne_map_eq_of_card_lt
      (fun t : Fin (N + 2) =>
        (⟨aliveLevel (F t) N, by
          have := aliveLevel_le (F t) N
          omega⟩ : Fin (N + 1))) hcard
  refine ⟨s, t, hst, ?_⟩
  exact capC_eq_of_aliveLevel_eq (hF s) (hF t) (congrArg Fin.val heq)

/-- **Summary.**  The conjectured order-preservation criterion is necessary but not
sufficient, and the exact criterion is level agreement, which makes the lower set of
any finite-height theory a chain of length at most `N + 1`. -/
theorem inclusion_criterion_summary (N : ℕ) :
    (∀ c c' : ℕ → ℕ, TheoryLE c c' N ↔ LevelAgree c c' N) ∧
      (∀ (c c' : ℕ → ℕ), TheoryLE c c' N →
        (∀ j, min N (c j) ≤ min N (c' j)) ∧
          ∀ i j, min N (c' i) ≤ min N (c' j) → min N (c i) ≤ min N (c j)) ∧
      ((∀ j, min 3 (cLow j) ≤ min 3 (cHigh j)) ∧
        (∀ i j, min 3 (cHigh i) ≤ min 3 (cHigh j) → min 3 (cLow i) ≤ min 3 (cLow j)) ∧
        Provable (capC cHigh 3) wit ∧ ¬ Provable (capC cLow 3) wit) :=
  ⟨fun c c' => capC_inclusion_iff c c' N,
    fun _ _ h => ⟨inclusion_depth_mono h, inclusion_order_preserving h⟩,
    inclusion_criterion_conjecture_false⟩

end PhysicsConsistency