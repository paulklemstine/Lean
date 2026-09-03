import NumberTheory.TagFrameSemantics

/-!
# Bisimulation is exactly the resolution of modal observation

This file settles the *positive half* of the v19c mission conjecture inside the
tag-indexed frame semantics of `NumberTheory.TagFrameSemantics`:

> On image-finite transition systems, every interpretation invariant under all modal
> observations factors through bisimulation classes.

The frames `satF R V` of the catalog are automatically **image-finite** (indeed
converse well-founded): the successors of a world `m` at tag `i` are contained in
`{0, …, m-1}` (`fStep_lt`, `succList_spec`).  In that setting we prove the two halves
of the Hennessy–Milner theorem for the *multi-tag* language `Form`:

* `satF_congr_of_bisim` — a bisimulation transports the truth of **every** formula
  (this is the unbounded companion of `satF_congr_of_approx`, which only transports
  formulas of bounded box depth);
* `isBisim_modEq` — conversely, modal equivalence is *itself* a bisimulation.  The
  proof is the genuine Hennessy–Milner argument: a world `n` has only finitely many
  successors, so the (finitely many) distinguishing formulas can be conjoined into a
  single formula `conjList`, and a `box` of its negation separates `m` from `n`.

Consequently `Bisimilar` and `ModEq` coincide (`bisimilar_iff_modEq`) and an
interpretation of pointed models is invariant under modal observation **iff** it is
invariant under bisimulation (`modalInvariant_iff_bisimInvariant`): modal invariance
factors through bisimulation classes, and through nothing coarser.

The companion file `NumberTheory.BisimulationMultiplicityGap` shows that the
factorization through *isomorphism* classes is strictly finer: an explicit pair of
bisimilar, non-isomorphic pointed models is separated by the multiplicity-sensitive
observation "out-degree of the root".

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): in the catalog's frames, modal equivalence is a bisimulation
  with no image-finiteness hypothesis needed, because the semantics only inspects
  worlds `n < m`.
Experiment (Stage 2): formalised; the only finiteness used is
  `succList_spec : FStep R i n n' ↔ n' ∈ (List.range n).filter …`.
Analysis (Stage 3): the multi-tag language causes no difficulty — the distinguishing
  conjunction is built for one tag at a time.
Critique (Stage 4): the language `Form` has only `bot`, `atom`, `imp`, `box`, so the
  conjunction had to be *defined* (`fand`, `conjList`) and its semantics proved; no
  infinitary conjunction is used anywhere.
-/

namespace PhysicsConsistency

open ProofSystemCollapse
open Form

namespace Bisim

/-! ## §1. Steps, image-finiteness, and derived connectives -/

/-- The one-step accessibility relation of a tag-indexed frame: `m` sees `n` at tag `i`
iff `n < m` and `R i m n`. -/
def FStep (R : ℕ → ℕ → ℕ → Bool) (i m n : ℕ) : Prop := n < m ∧ R i m n = true

theorem fStep_lt {R : ℕ → ℕ → ℕ → Bool} {i m n : ℕ} (h : FStep R i m n) : n < m := h.1

/-- The list of successors of a world: the concrete witness of **image-finiteness**. -/
def succList (R : ℕ → ℕ → ℕ → Bool) (i m : ℕ) : List ℕ :=
  (List.range m).filter (fun n => R i m n)

/-- Image-finiteness: the successors of `m` at tag `i` are exactly the members of the
finite list `succList R i m`. -/
theorem succList_spec (R : ℕ → ℕ → ℕ → Bool) (i m n : ℕ) :
    n ∈ succList R i m ↔ FStep R i m n := by
  simp [succList, FStep, List.mem_filter, List.mem_range, and_comm]

/-- Verum. -/
def fTop : Form := imp bot bot

/-- Conjunction, defined from the primitive connectives `imp` and `bot`. -/
def fand (a b : Form) : Form := imp (imp a (imp b bot)) bot

/-- Finite conjunction of a list of formulas. -/
def conjList : List Form → Form := List.foldr fand fTop

variable {R R' : ℕ → ℕ → ℕ → Bool} {V V' : ℕ → ℕ → Bool}

@[simp] theorem satF_fTop (m : ℕ) : satF R V m fTop = true := by
  simp [fTop, satF]

@[simp] theorem satF_neg (m : ℕ) (a : Form) :
    satF R V m (Form.neg a) = !(satF R V m a) := by
  simp [Form.neg, satF]

@[simp] theorem satF_fand (m : ℕ) (a b : Form) :
    satF R V m (fand a b) = (satF R V m a && satF R V m b) := by
  simp only [fand, satF]
  cases satF R V m a <;> cases satF R V m b <;> simp

theorem satF_conjList (m : ℕ) (l : List Form) :
    satF R V m (conjList l) = true ↔ ∀ a ∈ l, satF R V m a = true := by
  induction l with
  | nil => simp [conjList]
  | cons a l ih =>
      simp only [conjList, List.foldr_cons, satF_fand, Bool.and_eq_true, List.mem_cons,
        forall_eq_or_imp]
      rw [show List.foldr fand fTop l = conjList l from rfl, ih]

/-! ## §2. Bisimulations and modal equivalence -/

/-- A **bisimulation** between the tag-indexed models `(R, V)` and `(R', V')`: related
worlds agree on all atoms, and every step of one is matched by a step of the other at
the same tag, landing in related worlds. -/
def IsBisim (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) (R' : ℕ → ℕ → ℕ → Bool)
    (V' : ℕ → ℕ → Bool) (E : ℕ → ℕ → Prop) : Prop :=
  (∀ m n, E m n → ∀ p, V m p = V' n p) ∧
  (∀ m n, E m n → ∀ i m', FStep R i m m' → ∃ n', FStep R' i n n' ∧ E m' n') ∧
  (∀ m n, E m n → ∀ i n', FStep R' i n n' → ∃ m', FStep R i m m' ∧ E m' n')

/-- Two pointed models are **bisimilar** when some bisimulation relates their roots. -/
def Bisimilar (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) (R' : ℕ → ℕ → ℕ → Bool)
    (V' : ℕ → ℕ → Bool) (m n : ℕ) : Prop :=
  ∃ E, IsBisim R V R' V' E ∧ E m n

/-- Two pointed models are **modally equivalent** when no formula separates them. -/
def ModEq (R : ℕ → ℕ → ℕ → Bool) (V : ℕ → ℕ → Bool) (R' : ℕ → ℕ → ℕ → Bool)
    (V' : ℕ → ℕ → Bool) (m n : ℕ) : Prop :=
  ∀ a : Form, satF R V m a = satF R' V' n a

theorem modEq_symm {m n : ℕ} (h : ModEq R V R' V' m n) : ModEq R' V' R V n m :=
  fun a => (h a).symm

/-! ## §3. Transport: bisimulation preserves all modal truth -/

/-- **Bisimulation invariance of modal truth.**  Related worlds satisfy exactly the
same formulas — of arbitrary box depth. -/
theorem satF_congr_of_bisim {E : ℕ → ℕ → Prop} (hE : IsBisim R V R' V' E) :
    ∀ (a : Form) (m n : ℕ), E m n → satF R V m a = satF R' V' n a := by
  obtain ⟨hatom, hforth, hback⟩ := hE
  intro a
  induction a with
  | bot => intro m n _; rfl
  | atom p => intro m n h; simpa using hatom m n h p
  | imp b c ihb ihc => intro m n h; simp only [satF, ihb m n h, ihc m n h]
  | box i b ih =>
      intro m n h
      rw [Bool.eq_iff_iff, satF_box, satF_box]
      constructor
      · intro hm n' hn' hR'
        obtain ⟨m', hm', hE'⟩ := hback m n h i n' ⟨hn', hR'⟩
        rw [← ih m' n' hE']
        exact hm m' hm'.1 hm'.2
      · intro hn m' hm' hR
        obtain ⟨n', hn', hE'⟩ := hforth m n h i m' ⟨hm', hR⟩
        rw [ih m' n' hE']
        exact hn n' hn'.1 hn'.2

/-- Bisimilar pointed models are modally equivalent. -/
theorem modEq_of_bisimilar {m n : ℕ} (h : Bisimilar R V R' V' m n) : ModEq R V R' V' m n := by
  obtain ⟨E, hE, hmn⟩ := h
  exact fun a => satF_congr_of_bisim hE a m n hmn

/-! ## §4. Hennessy–Milner: modal equivalence is a bisimulation -/

/-- The *forth* half of the Hennessy–Milner argument.  If `m` and `n` are modally
equivalent then every `i`-successor `m'` of `m` is modally equivalent to some
`i`-successor of `n`.  The proof uses image-finiteness of `n`: the finitely many
formulas separating `m'` from the successors of `n` are conjoined into one formula,
whose boxed negation would separate `n` from `m`. -/
theorem modEq_forth {m n : ℕ} (h : ModEq R V R' V' m n) (i m' : ℕ)
    (hm' : FStep R i m m') : ∃ n', FStep R' i n n' ∧ ModEq R V R' V' m' n' := by
  by_contra hcon
  push_neg at hcon
  -- For each candidate successor `n'` of `n`, choose a formula true at `m'` and false
  -- at `n'`; for non-successors take verum.
  have hchoice : ∀ n' : ℕ, ∃ a : Form,
      satF R V m' a = true ∧ (FStep R' i n n' → satF R' V' n' a = false) := by
    intro n'
    by_cases hs : FStep R' i n n'
    · have hne : ¬ ModEq R V R' V' m' n' := hcon n' hs
      simp only [ModEq, not_forall] at hne
      obtain ⟨a, ha⟩ := hne
      by_cases hmm : satF R V m' a = true
      · refine ⟨a, hmm, fun _ => ?_⟩
        cases hx : satF R' V' n' a with
        | false => rfl
        | true => exact absurd (hmm.trans hx.symm) ha
      · simp only [Bool.not_eq_true] at hmm
        have hn'a : satF R' V' n' a = true := by
          cases hx : satF R' V' n' a with
          | false => exact absurd (hmm.trans hx.symm) ha
          | true => rfl
        exact ⟨Form.neg a, by simp [hmm], fun _ => by simp [hn'a]⟩
    · exact ⟨fTop, by simp, fun hc => absurd hc hs⟩
  choose d hd using hchoice
  -- The single separating formula.
  obtain ⟨A, hA⟩ : ∃ A : Form, A = conjList ((List.range n).map d) := ⟨_, rfl⟩
  have hAm : satF R V m' A = true := by
    rw [hA, satF_conjList]
    intro a ha
    obtain ⟨n', _, rfl⟩ := List.mem_map.1 ha
    exact (hd n').1
  have hAn : ∀ n', FStep R' i n n' → satF R' V' n' A = false := by
    intro n' hn'
    cases h1 : satF R' V' n' A with
    | false => rfl
    | true =>
      rw [hA, satF_conjList] at h1
      have hmem : d n' ∈ (List.range n).map d :=
        List.mem_map.2 ⟨n', List.mem_range.2 hn'.1, rfl⟩
      have := h1 _ hmem
      rw [(hd n').2 hn'] at this
      exact absurd this (by simp)
  -- `n` satisfies `□_i ¬A`, hence so does `m`, contradicting `m'`.
  have hn : satF R' V' n (box i (Form.neg A)) = true := by
    rw [satF_box]
    intro n' hn' hR'
    simp [hAn n' ⟨hn', hR'⟩]
  have hm : satF R V m (box i (Form.neg A)) = true := (h (box i (Form.neg A))).trans hn
  rw [satF_box] at hm
  have := hm m' hm'.1 hm'.2
  rw [satF_neg, hAm] at this
  exact absurd this (by simp)

/-- **Hennessy–Milner theorem.**  On the (automatically image-finite) tag-indexed
frames, modal equivalence is itself a bisimulation. -/
theorem isBisim_modEq : IsBisim R V R' V' (ModEq R V R' V') := by
  refine ⟨?_, ?_, ?_⟩
  · intro m n h p; simpa using h (atom p)
  · intro m n h i m' hm'
    exact modEq_forth h i m' hm'
  · intro m n h i n' hn'
    obtain ⟨m', hm', hE⟩ := modEq_forth (modEq_symm h) i n' hn'
    exact ⟨m', hm', modEq_symm hE⟩

/-- **Bisimilarity = modal equivalence.**  Modal observation resolves pointed models
exactly up to bisimulation. -/
theorem bisimilar_iff_modEq {m n : ℕ} :
    Bisimilar R V R' V' m n ↔ ModEq R V R' V' m n :=
  ⟨modEq_of_bisimilar, fun h => ⟨ModEq R V R' V', isBisim_modEq, h⟩⟩

/-! ## §5. Factorization of interpretations -/

/-- An **interpretation** of pointed tag-indexed models with values in `α`. -/
abbrev Interp (α : Type*) := (ℕ → ℕ → ℕ → Bool) → (ℕ → ℕ → Bool) → ℕ → α

/-- Invariance under all modal observations. -/
def ModalInvariant {α : Type*} (I : Interp α) : Prop :=
  ∀ R V R' V' m n, ModEq R V R' V' m n → I R V m = I R' V' n

/-- Invariance under bisimulation. -/
def BisimInvariant {α : Type*} (I : Interp α) : Prop :=
  ∀ R V R' V' m n, Bisimilar R V R' V' m n → I R V m = I R' V' n

/-- **Factorization through bisimulation classes.**  An interpretation is invariant
under all modal observations iff it is invariant under bisimulation; in particular
every modally invariant interpretation factors through the bisimulation quotient. -/
theorem modalInvariant_iff_bisimInvariant {α : Type*} (I : Interp α) :
    ModalInvariant I ↔ BisimInvariant I := by
  constructor
  · intro hI R V R' V' m n hb
    exact hI R V R' V' m n (modEq_of_bisimilar hb)
  · intro hI R V R' V' m n hm
    exact hI R V R' V' m n (bisimilar_iff_modEq.2 hm)

/-- The canonical modally invariant interpretation: the modal theory of a pointed
model.  Every modally invariant interpretation factors through it. -/
def modalTheory : Interp (Form → Bool) := fun R V m a => satF R V m a

theorem modalInvariant_modalTheory : ModalInvariant modalTheory := by
  intro R V R' V' m n h
  funext a
  exact h a

/-- Explicit factorization: a modally invariant interpretation is a function of the
modal theory alone. -/
theorem factors_through_modalTheory {α : Type*} (I : Interp α) (hI : ModalInvariant I)
    {R R' : ℕ → ℕ → ℕ → Bool} {V V' : ℕ → ℕ → Bool} {m n : ℕ}
    (h : modalTheory R V m = modalTheory R' V' n) : I R V m = I R' V' n :=
  hI R V R' V' m n (fun a => congrFun h a)

end Bisim

end PhysicsConsistency