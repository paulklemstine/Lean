import Bridges.BerggrenTrees.BerggrenPythagoreanCore

/-!
# The Berggren causal set: order-theoretic core

This file formalises the Berggren tree of primitive Pythagorean triples as a
**causal set** in the sense of Bombelli–Lee–Meyer–Sorkin: a partially ordered set
of "events" which is locally finite and has no closed causal curves.

The events are the integer null vectors of the Lorentz form `Q(a,b,c) = a² + b² − c²`
with positive entries which are reachable from the root `(3,4,5)` by the three
Berggren moves `bergA`, `bergB`, `bergC` (imported from
`Bridges.BerggrenTrees.BerggrenPythagoreanCore`).  The causal relation is
"is an ancestor of in the tree".

## Main results

* `step_inj` — the **unique parent property**: a Berggren child determines both its
  parent and the move that produced it.  The proof extracts the sign pattern of the
  explicit parent map `parent`, which returns `(a, −b, c)`, `(a, b, c)`, `(−a, b, c)`
  on the three branches.
* `run_word_unique` — the word labelling a causal path is unique, i.e. the Berggren
  tree really is a tree.
* `causal_partialOrder` — `Causal` is reflexive, transitive and antisymmetric on events
  (`causal_refl`, `causal_trans`, `causal_antisymm`) and admits no closed causal curve
  (`no_closed_causal_curve`).
* `causalInterval_finite` / `causalInterval_ncard` — **local finiteness**: every causal
  interval is finite, and the interval between an event and its depth-`k` descendant has
  exactly `k + 1` elements.
* `causalInterval_isChain` — every causal interval is a *chain*: any two events in it are
  causally related.  Together with the previous item this pins the interval growth to be
  exactly linear in the proper time.
* `level_card` — the level sets grow like `3 ^ k`.
-/

namespace BerggrenCausalSet

/-! ## Events -/

/-- An event of the model: a point of `ℤ³`. -/
abbrev Event := ℤ × ℤ × ℤ

/-- A *physical event*: a future-directed integer null vector of the Lorentz form
`a² + b² − c²`, i.e. a Pythagorean triple with strictly positive entries. -/
def IsEvent (t : Event) : Prop :=
  IsPythag t.1 t.2.1 t.2.2 ∧ 0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2

/-- The root event `(3,4,5)`. -/
def root : Event := (3, 4, 5)

theorem root_isEvent : IsEvent root := by
  refine ⟨?_, by norm_num [root], by norm_num [root], by norm_num [root]⟩
  show (3 : ℤ) ^ 2 + 4 ^ 2 = 5 ^ 2
  norm_num

/-- Both legs of an event are strictly shorter than the hypotenuse. -/
theorem legs_lt_hyp {t : Event} (h : IsEvent t) : t.1 < t.2.2 ∧ t.2.1 < t.2.2 := by
  obtain ⟨hp, ha, hb, hc⟩ := h
  unfold IsPythag at hp
  exact ⟨by nlinarith, by nlinarith⟩

/-! ## One Berggren step -/

@[simp] theorem applyStep_A (a b c : ℤ) :
    applyStep BerggrenStep.A (a, b, c) = bergA a b c := rfl

@[simp] theorem applyStep_B (a b c : ℤ) :
    applyStep BerggrenStep.B (a, b, c) = bergB a b c := rfl

@[simp] theorem applyStep_C (a b c : ℤ) :
    applyStep BerggrenStep.C (a, b, c) = bergC a b c := rfl

theorem bergA_isEvent {a b c : ℤ} (h : IsEvent (a, b, c)) : IsEvent (bergA a b c) := by
  obtain ⟨hac, hbc⟩ := legs_lt_hyp h
  obtain ⟨hp, ha, hb, hc⟩ := h
  simp only at hac hbc ha hb hc
  unfold IsPythag at hp
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp only [bergA, IsPythag] <;> nlinarith

theorem bergB_isEvent {a b c : ℤ} (h : IsEvent (a, b, c)) : IsEvent (bergB a b c) := by
  obtain ⟨hac, hbc⟩ := legs_lt_hyp h
  obtain ⟨hp, ha, hb, hc⟩ := h
  simp only at hac hbc ha hb hc
  unfold IsPythag at hp
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp only [bergB, IsPythag] <;> nlinarith

theorem bergC_isEvent {a b c : ℤ} (h : IsEvent (a, b, c)) : IsEvent (bergC a b c) := by
  obtain ⟨hac, hbc⟩ := legs_lt_hyp h
  obtain ⟨hp, ha, hb, hc⟩ := h
  simp only at hac hbc ha hb hc
  unfold IsPythag at hp
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp only [bergC, IsPythag] <;> nlinarith

theorem step_isEvent (s : BerggrenStep) {t : Event} (h : IsEvent t) :
    IsEvent (applyStep s t) := by
  obtain ⟨a, b, c⟩ := t
  cases s
  · exact bergA_isEvent h
  · exact bergB_isEvent h
  · exact bergC_isEvent h

/-- Every Berggren move strictly increases the hypotenuse (the "time" coordinate). -/
theorem step_hyp_lt (s : BerggrenStep) {t : Event} (h : IsEvent t) :
    t.2.2 < (applyStep s t).2.2 := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨hac, hbc⟩ := legs_lt_hyp h
  obtain ⟨_, ha, hb, hc⟩ := h
  simp only at hac hbc ha hb hc
  cases s <;> simp only [applyStep_A, applyStep_B, applyStep_C, bergA, bergB, bergC] <;> linarith

/-! ## The parent map and the unique-parent property -/

/-- The universal *parent map*: it is the inverse of `bergB`, and on the other two
branches it returns the parent with a sign flipped.  Explicitly
`parent (bergA a b c) = (a, −b, c)`, `parent (bergB a b c) = (a, b, c)`,
`parent (bergC a b c) = (−a, b, c)`; since events have positive legs, the sign pattern
recovers the branch. -/
def parent (t : Event) : Event :=
  (t.1 + 2 * t.2.1 - 2 * t.2.2, 2 * t.1 + t.2.1 - 2 * t.2.2, -2 * t.1 - 2 * t.2.1 + 3 * t.2.2)

theorem parent_bergA (a b c : ℤ) : parent (bergA a b c) = (a, -b, c) := by
  simp only [parent, bergA, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem parent_bergB (a b c : ℤ) : parent (bergB a b c) = (a, b, c) := by
  simp only [parent, bergB, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem parent_bergC (a b c : ℤ) : parent (bergC a b c) = (-a, b, c) := by
  simp only [parent, bergC, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

/-- **Unique parent property.**  A Berggren child determines the move and the parent. -/
theorem step_inj {s s' : BerggrenStep} {t t' : Event} (h : IsEvent t) (h' : IsEvent t')
    (heq : applyStep s t = applyStep s' t') : s = s' ∧ t = t' := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨a', b', c'⟩ := t'
  obtain ⟨_, ha, hb, _⟩ := h
  obtain ⟨_, ha', hb', _⟩ := h'
  simp only at ha hb ha' hb'
  have key := congrArg parent heq
  cases s <;> cases s' <;>
    simp only [applyStep_A, applyStep_B, applyStep_C, parent_bergA, parent_bergB, parent_bergC,
      Prod.mk.injEq] at key <;>
    refine ⟨?_, ?_⟩ <;>
      first
        | rfl
        | (exfalso; omega)
        | (simp only [Prod.mk.injEq]; omega)

/-! ## Causal paths -/

/-- Run a word of Berggren moves, leftmost move first. -/
def run : List BerggrenStep → Event → Event
  | [], t => t
  | s :: w, t => run w (applyStep s t)

@[simp] theorem run_nil (t : Event) : run [] t = t := rfl

@[simp] theorem run_cons (s : BerggrenStep) (w : List BerggrenStep) (t : Event) :
    run (s :: w) t = run w (applyStep s t) := rfl

theorem run_append (w₁ w₂ : List BerggrenStep) (t : Event) :
    run (w₁ ++ w₂) t = run w₂ (run w₁ t) := by
  induction w₁ generalizing t with
  | nil => simp
  | cons s w ih => simp [ih]

theorem run_concat (w : List BerggrenStep) (s : BerggrenStep) (t : Event) :
    run (w ++ [s]) t = applyStep s (run w t) := by
  rw [run_append]; rfl

theorem run_isEvent (w : List BerggrenStep) {t : Event} (h : IsEvent t) :
    IsEvent (run w t) := by
  induction w generalizing t with
  | nil => simpa using h
  | cons s w ih => exact ih (step_isEvent s h)

/-- The hypotenuse grows by at least one unit per Berggren move. -/
theorem run_hyp_ge (w : List BerggrenStep) {t : Event} (h : IsEvent t) :
    t.2.2 + w.length ≤ (run w t).2.2 := by
  induction w generalizing t with
  | nil => simp
  | cons s w ih =>
      have h1 := step_hyp_lt s h
      have h2 := ih (step_isEvent s h)
      simp only [run_cons, List.length_cons]
      push_cast
      push_cast at h2
      linarith

/-! ## The causal order -/

/-- The causal relation: `Causal t u` means `u` is a Berggren descendant of `t`. -/
def Causal (t u : Event) : Prop := ∃ w : List BerggrenStep, run w t = u

theorem causal_refl (t : Event) : Causal t t := ⟨[], rfl⟩

theorem causal_trans {t u v : Event} (h₁ : Causal t u) (h₂ : Causal u v) : Causal t v := by
  obtain ⟨w₁, rfl⟩ := h₁
  obtain ⟨w₂, rfl⟩ := h₂
  exact ⟨w₁ ++ w₂, by rw [run_append]⟩

theorem causal_hyp_le {t u : Event} (ht : IsEvent t) (h : Causal t u) : t.2.2 ≤ u.2.2 := by
  obtain ⟨w, rfl⟩ := h
  have := run_hyp_ge w ht
  have : (0 : ℤ) ≤ (w.length : ℤ) := Int.natCast_nonneg _
  omega

/-- **No closed causal curves**: a nonempty word never returns to its starting event. -/
theorem no_closed_causal_curve {t : Event} (ht : IsEvent t) {w : List BerggrenStep}
    (hw : w ≠ []) : run w t ≠ t := by
  intro hcontra
  have h := run_hyp_ge w ht
  rw [hcontra] at h
  have : 0 < w.length := List.length_pos_iff.mpr hw
  have : (0 : ℤ) < (w.length : ℤ) := by exact_mod_cast this
  omega

theorem causal_antisymm {t u : Event} (ht : IsEvent t) (h₁ : Causal t u) (h₂ : Causal u t) :
    t = u := by
  obtain ⟨w₁, rfl⟩ := h₁
  obtain ⟨w₂, hw₂⟩ := h₂
  have hcyc : run (w₁ ++ w₂) t = t := by rw [run_append]; exact hw₂
  have h1 : w₁ ++ w₂ = [] := by
    by_contra hne
    exact no_closed_causal_curve ht hne hcyc
  have : w₁ = [] := (List.append_eq_nil_iff.mp h1).1
  simp [this]

/-! ## Uniqueness of causal paths (the tree property) -/

/-- **Ancestor dichotomy.**  If two causal paths, of comparable lengths, arrive at the same
event, the longer one factors through the shorter one. -/
theorem ancestor_factor :
    ∀ (n : ℕ) (w w' : List BerggrenStep) (t t' : Event), IsEvent t → IsEvent t' →
      w.length = n → w.length ≤ w'.length → run w t = run w' t' →
      ∃ p : List BerggrenStep, w' = p ++ w ∧ run p t' = t := by
  intro n
  induction n with
  | zero =>
      intro w w' t t' _ _ hw _ heq
      have hw0 : w = [] := List.length_eq_zero_iff.mp hw
      subst hw0
      exact ⟨w', by simp, by simpa using heq.symm⟩
  | succ n ih =>
      intro w w' t t' ht ht' hw hlen heq
      obtain ⟨r, s, rfl⟩ : ∃ r s, w = r ++ [s] := by
        rcases List.eq_nil_or_concat' w with h | ⟨r, s, h⟩
        · exfalso; rw [h] at hw; simp at hw
        · exact ⟨r, s, h⟩
      obtain ⟨r', s', rfl⟩ : ∃ r' s', w' = r' ++ [s'] := by
        rcases List.eq_nil_or_concat' w' with h | ⟨r', s', h⟩
        · exfalso; rw [h] at hlen; simp at hlen
        · exact ⟨r', s', h⟩
      rw [run_concat, run_concat] at heq
      obtain ⟨hs, hstep⟩ := step_inj (run_isEvent r ht) (run_isEvent r' ht') heq
      have hrlen : r.length = n := by simpa using hw
      have hlen' : r.length ≤ r'.length := by
        simp only [List.length_append, List.length_singleton] at hlen; omega
      obtain ⟨p, hp, hpt⟩ := ih r r' t t' ht ht' hrlen hlen' hstep
      exact ⟨p, by rw [hp, hs, List.append_assoc], hpt⟩

/-- **The Berggren tree is a tree**: the word labelling a causal path is unique. -/
theorem run_word_unique {t : Event} (ht : IsEvent t) {w w' : List BerggrenStep}
    (heq : run w t = run w' t) : w = w' := by
  rcases le_total w.length w'.length with hle | hle
  · obtain ⟨p, hp, hpt⟩ := ancestor_factor w.length w w' t t ht ht rfl hle heq
    have := run_hyp_ge p ht
    rw [hpt] at this
    have hp0 : p.length = 0 := by
      have : (0 : ℤ) ≤ (p.length : ℤ) := Int.natCast_nonneg _
      omega
    rw [hp, List.length_eq_zero_iff.mp hp0, List.nil_append]
  · obtain ⟨p, hp, hpt⟩ := ancestor_factor w'.length w' w t t ht ht rfl hle heq.symm
    have := run_hyp_ge p ht
    rw [hpt] at this
    have hp0 : p.length = 0 := by
      have : (0 : ℤ) ≤ (p.length : ℤ) := Int.natCast_nonneg _
      omega
    rw [hp, List.length_eq_zero_iff.mp hp0, List.nil_append]

/-! ## Levels: the volume growth of the causal set -/

instance : Fintype BerggrenStep :=
  ⟨{BerggrenStep.A, BerggrenStep.B, BerggrenStep.C}, by intro x; cases x <;> decide⟩

theorem card_berggrenStep : Fintype.card BerggrenStep = 3 := rfl

/-- The set of events at depth `k` below `t`, as a `Finset`. -/
def levelFinset (t : Event) (k : ℕ) : Finset Event :=
  Finset.image (fun f : Fin k → BerggrenStep => run (List.ofFn f) t) Finset.univ

/-- **Volume growth**: each level of the Berggren causal set carries exactly `3 ^ k` events. -/
theorem level_card {t : Event} (ht : IsEvent t) (k : ℕ) : (levelFinset t k).card = 3 ^ k := by
  have hinj : Function.Injective (fun f : Fin k → BerggrenStep => run (List.ofFn f) t) := by
    intro f g hfg
    have : List.ofFn f = List.ofFn g := run_word_unique ht hfg
    exact List.ofFn_injective this
  rw [levelFinset, Finset.card_image_of_injective _ hinj, Finset.card_univ,
    Fintype.card_fun, card_berggrenStep, Fintype.card_fin]

/-! ## Local finiteness and the structure of causal intervals -/

/-- The causal interval (Alexandrov set) between two events. -/
def causalInterval (t u : Event) : Set Event := {x | Causal t x ∧ Causal x u}

/-- Every element of a causal interval `[t, run v t]` is `run (v.take j) t` for some `j`. -/
theorem mem_causalInterval_iff {t : Event} (ht : IsEvent t) (v : List BerggrenStep) (x : Event) :
    x ∈ causalInterval t (run v t) ↔ ∃ j ≤ v.length, run (v.take j) t = x := by
  constructor
  · rintro ⟨⟨w, rfl⟩, ⟨w', hw'⟩⟩
    have hcat : run (w ++ w') t = run v t := by rw [run_append]; exact hw'
    have hv : w ++ w' = v := run_word_unique ht hcat
    refine ⟨w.length, ?_, ?_⟩
    · rw [← hv]; simp
    · rw [← hv, List.take_left]
  · rintro ⟨j, hj, rfl⟩
    refine ⟨⟨v.take j, rfl⟩, ⟨v.drop j, ?_⟩⟩
    rw [← run_append, List.take_append_drop]

/-- The causal interval `[t, run v t]` is the (finite) image of `{0, …, |v|}`. -/
theorem causalInterval_eq_image {t : Event} (ht : IsEvent t) (v : List BerggrenStep) :
    causalInterval t (run v t) =
      ↑((Finset.range (v.length + 1)).image (fun j => run (v.take j) t)) := by
  ext x
  rw [mem_causalInterval_iff ht]
  simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, Finset.mem_range]
  constructor
  · rintro ⟨j, hj, rfl⟩; exact ⟨j, by omega, rfl⟩
  · rintro ⟨j, hj, rfl⟩; exact ⟨j, by omega, rfl⟩

/-- **Local finiteness.** Every causal interval of the Berggren causal set is finite. -/
theorem causalInterval_finite {t u : Event} (ht : IsEvent t) :
    (causalInterval t u).Finite := by
  by_cases h : Causal t u
  · obtain ⟨v, rfl⟩ := h
    rw [causalInterval_eq_image ht]
    exact (Finset.finite_toSet _)
  · have : causalInterval t u = ∅ := by
      ext x
      simp only [Set.mem_empty_iff_false, iff_false]
      rintro ⟨h₁, h₂⟩
      exact h (causal_trans h₁ h₂)
    rw [this]
    exact Set.finite_empty

/-- Splitting a prefix of a prefix. -/
theorem take_split {i j : ℕ} (h : i ≤ j) (v : List BerggrenStep) :
    v.take i ++ (v.take j).drop i = v.take j := by
  conv_rhs => rw [← List.take_append_drop i (v.take j)]
  rw [List.take_take, min_eq_left h]

/-- Along a fixed path the hypotenuse is strictly increasing in the number of steps. -/
theorem take_hyp_strictMono {t : Event} (ht : IsEvent t) (v : List BerggrenStep)
    {i j : ℕ} (hij : i < j) (hj : j ≤ v.length) :
    (run (v.take i) t).2.2 < (run (v.take j) t).2.2 := by
  have hsplit : v.take j = v.take i ++ (v.take j).drop i := (take_split hij.le v).symm
  have hlen : ((v.take j).drop i).length = j - i := by
    simp only [List.length_drop, List.length_take]
    omega
  have hev : IsEvent (run (v.take i) t) := run_isEvent _ ht
  have := run_hyp_ge ((v.take j).drop i) hev
  rw [← run_append, ← hsplit] at this
  rw [hlen] at this
  have : (1 : ℤ) ≤ ((j - i : ℕ) : ℤ) := by
    have : 1 ≤ j - i := by omega
    exact_mod_cast this
  omega

/-- **The causal intervals are chains of exactly `|v| + 1` events.**  Discrete proper time
between an event and its depth-`k` descendant is `k`, and the interval volume is `k + 1`:
the interval cardinality grows *linearly*, not like a power `> 1`, in the proper time. -/
theorem causalInterval_ncard {t : Event} (ht : IsEvent t) (v : List BerggrenStep) :
    (causalInterval t (run v t)).ncard = v.length + 1 := by
  rw [causalInterval_eq_image ht, Set.ncard_coe_finset]
  rw [Finset.card_image_of_injOn, Finset.card_range]
  intro i hi j hj hij
  simp only [Finset.mem_coe, Finset.mem_range] at hi hj
  by_contra hne
  simp only at hij
  rcases lt_or_gt_of_ne hne with h | h
  · have := take_hyp_strictMono ht v h (by omega)
    rw [hij] at this
    omega
  · have := take_hyp_strictMono ht v h (by omega)
    rw [hij] at this
    omega

/-- **Causal intervals are totally ordered chains.**  This is the structural reason the
Berggren causal set cannot approximate a spacetime of dimension `> 1`: in a causal set
faithfully embedded in `d`-dimensional Minkowski space a large interval contains many
mutually *unrelated* pairs, whereas here every pair inside an interval is related. -/
theorem causalInterval_isChain {t : Event} (ht : IsEvent t) (v : List BerggrenStep)
    {x y : Event} (hx : x ∈ causalInterval t (run v t)) (hy : y ∈ causalInterval t (run v t)) :
    Causal x y ∨ Causal y x := by
  obtain ⟨i, hi, rfl⟩ := (mem_causalInterval_iff ht v x).mp hx
  obtain ⟨j, hj, rfl⟩ := (mem_causalInterval_iff ht v y).mp hy
  rcases le_total i j with h | h
  · left
    exact ⟨(v.take j).drop i, by rw [← run_append, take_split h]⟩
  · right
    exact ⟨(v.take i).drop j, by rw [← run_append, take_split h]⟩

end BerggrenCausalSet