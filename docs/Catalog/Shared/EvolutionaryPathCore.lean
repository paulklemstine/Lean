/-
  # Quotient Steps and Evolutionary Paths — Abstract Core

  This file supplies the two definitions that the Phase A mission asks for
  *before* the full decomposition conjecture is attempted, and then proves the
  decomposition conjecture in the abstract setting they generate.

  * A **quotient step** is one elementary, label-carrying, rank-decreasing
    move `x --l--> y` of a `QuotientSystem`.  The three axioms are
    - `rank_lt`      : every step strictly decreases an `ℕ`-valued rank
                       (termination / no infinite evolution),
    - `label_unique` : the label of a step is determined by its endpoints
                       (the "isomorphism type of the quotient" is well defined),
    - `exchange`     : two distinct steps out of the same point can be completed
                       to a diamond with the labels swapped (the abstract
                       Zassenhaus/butterfly axiom, i.e. local confluence with
                       label transport).

  * An **evolutionary path** `EvolPath Q x t ls` is a finite chain of quotient
    steps from `x` to `t` recording the list `ls` of labels used.  It is
    *complete* when its endpoint is `Terminal` (admits no further step).

  The main results:

  * `EvolPath.terminal_unique_multiset` (abstract Jordan–Hölder):
    any two complete evolutionary paths out of the same point end at the *same*
    terminal object and use the *same multiset* of labels.
  * `decomp`, the resulting `Multiset Λ`-valued invariant, with
    `decomp_step`, `decomp_eq_of_path`, `terminal_iff_decomp_zero`.
  * `EvolPath.labels_eq` : the label multiset of *any* path `x → y` equals
    `decomp x - decomp y`; in particular it depends only on the endpoints.
  * `Reach` is a graded partial order (`height_lt_of_reach`,
    `reach_antisymm`) and is confluent (`reach_confluent`).

  Nothing here is definitional: the Jordan–Hölder argument is a strong
  induction on rank driven by the exchange axiom.
-/
import Mathlib

namespace Shared.EvolutionaryPath

universe u v

/-- A **quotient system**: a labelled, rank-decreasing, exchange-closed step
relation.  `step x l y` is read "`y` is obtained from `x` by a quotient step of
type `l`". -/
structure QuotientSystem (α : Type u) (Λ : Type v) where
  /-- The elementary (quotient) steps, carrying a label. -/
  step : α → Λ → α → Prop
  /-- A termination measure. -/
  rank : α → ℕ
  /-- Every quotient step strictly decreases the rank. -/
  rank_lt : ∀ {x l y}, step x l y → rank y < rank x
  /-- The label of a step is determined by its source and target. -/
  label_unique : ∀ {x l₁ l₂ y}, step x l₁ y → step x l₂ y → l₁ = l₂
  /-- Abstract butterfly/Zassenhaus axiom: two distinct steps out of `x` close
  up into a diamond in which the labels are exchanged. -/
  exchange : ∀ {x l₁ y₁ l₂ y₂}, step x l₁ y₁ → step x l₂ y₂ → y₁ ≠ y₂ →
      ∃ z, step y₁ l₂ z ∧ step y₂ l₁ z

variable {α : Type u} {Λ : Type v} (Q : QuotientSystem α Λ)

/-- `x` is **terminal** (simple / irreducible) when no quotient step leaves it. -/
def Terminal (x : α) : Prop := ∀ l y, ¬ Q.step x l y

/-- An **evolutionary path** from `x` to `t` with label list `ls`: a finite
chain of quotient steps. -/
inductive EvolPath (Q : QuotientSystem α Λ) : α → α → List Λ → Prop
  | nil (x : α) : EvolPath Q x x []
  | cons {x l y t ls} : Q.step x l y → EvolPath Q y t ls → EvolPath Q x t (l :: ls)

/-- `Reach Q x y`: `y` sits somewhere along an evolutionary path out of `x`. -/
def Reach (x y : α) : Prop := ∃ ls, EvolPath Q x y ls

variable {Q}

theorem Terminal.not_step {x : α} (h : Terminal Q x) {l y} : ¬ Q.step x l y := h l y

theorem exists_step_of_not_terminal {x : α} (h : ¬ Terminal Q x) :
    ∃ l y, Q.step x l y := by
  by_contra hc
  push_neg at hc
  exact h fun l y => hc l y

/-- Concatenation of evolutionary paths. -/
theorem EvolPath.append {x y z : α} {ls₁ ls₂ : List Λ} (p₁ : EvolPath Q x y ls₁) :
    EvolPath Q y z ls₂ → EvolPath Q x z (ls₁ ++ ls₂) := by
  induction p₁ with
  | nil x => intro h; simpa using h
  | cons hs _ ih => intro h; exact EvolPath.cons hs (ih h)

theorem EvolPath.rank_le {x t : α} {ls : List Λ} (h : EvolPath Q x t ls) :
    Q.rank t ≤ Q.rank x := by
  induction h with
  | nil x => exact le_rfl
  | cons hs _ ih => exact ih.trans (Q.rank_lt hs).le

theorem EvolPath.length_le_rank {x t : α} {ls : List Λ} (h : EvolPath Q x t ls) :
    ls.length ≤ Q.rank x := by
  induction h with
  | nil x => exact Nat.zero_le _
  | cons hs _ ih =>
      have := Q.rank_lt hs
      simp only [List.length_cons]
      omega

/-- Every object admits a complete evolutionary path: evolution terminates. -/
theorem exists_complete_path (Q : QuotientSystem α Λ) (x : α) :
    ∃ t ls, EvolPath Q x t ls ∧ Terminal Q t := by
  generalize hn : Q.rank x = n
  induction n using Nat.strong_induction_on generalizing x with
  | _ n ih =>
    by_cases h : Terminal Q x
    · exact ⟨x, [], EvolPath.nil x, h⟩
    · obtain ⟨l, y, hs⟩ := exists_step_of_not_terminal h
      obtain ⟨t, ls, hp, ht⟩ := ih (Q.rank y) (by rw [← hn]; exact Q.rank_lt hs) y rfl
      exact ⟨t, l :: ls, EvolPath.cons hs hp, ht⟩

/-- **Abstract Jordan–Hölder theorem.**  Two complete evolutionary paths out of
the same object reach the same terminal object and carry the same multiset of
labels. -/
theorem EvolPath.terminal_unique_multiset :
    ∀ (n : ℕ) (x t₁ t₂ : α) (ls₁ ls₂ : List Λ), Q.rank x = n →
      EvolPath Q x t₁ ls₁ → EvolPath Q x t₂ ls₂ → Terminal Q t₁ → Terminal Q t₂ →
      t₁ = t₂ ∧ (ls₁ : Multiset Λ) = (ls₂ : Multiset Λ) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro x t₁ t₂ ls₁ ls₂ hn h₁ h₂ ht₁ ht₂
    cases h₁ with
    | nil =>
        cases h₂ with
        | nil => exact ⟨rfl, rfl⟩
        | cons s₂ _ => exact absurd s₂ ht₁.not_step
    | @cons _ l₁ y₁ _ ls₁' s₁ p₁ =>
        cases h₂ with
        | nil => exact absurd s₁ ht₂.not_step
        | @cons _ l₂ y₂ _ ls₂' s₂ p₂ =>
            by_cases hy : y₁ = y₂
            · subst hy
              have hl : l₁ = l₂ := Q.label_unique s₁ s₂
              subst hl
              obtain ⟨he, hm⟩ :=
                ih (Q.rank y₁) (by rw [← hn]; exact Q.rank_lt s₁) y₁ t₁ t₂ ls₁' ls₂'
                  rfl p₁ p₂ ht₁ ht₂
              refine ⟨he, ?_⟩
              simp only [← Multiset.cons_coe, hm]
            · obtain ⟨z, sz₁, sz₂⟩ := Q.exchange s₁ s₂ hy
              obtain ⟨t, ls, hp, ht⟩ := exists_complete_path Q z
              obtain ⟨e₁, m₁⟩ :=
                ih (Q.rank y₁) (by rw [← hn]; exact Q.rank_lt s₁) y₁ t₁ t ls₁' (l₂ :: ls)
                  rfl p₁ (EvolPath.cons sz₁ hp) ht₁ ht
              obtain ⟨e₂, m₂⟩ :=
                ih (Q.rank y₂) (by rw [← hn]; exact Q.rank_lt s₂) y₂ t₂ t ls₂' (l₁ :: ls)
                  rfl p₂ (EvolPath.cons sz₂ hp) ht₂ ht
              refine ⟨e₁.trans e₂.symm, ?_⟩
              simp only [← Multiset.cons_coe, m₁, m₂]
              exact Multiset.cons_swap l₁ l₂ _

/-- Convenient form of the abstract Jordan–Hölder theorem. -/
theorem EvolPath.jordan_holder {x t₁ t₂ : α} {ls₁ ls₂ : List Λ}
    (h₁ : EvolPath Q x t₁ ls₁) (h₂ : EvolPath Q x t₂ ls₂)
    (ht₁ : Terminal Q t₁) (ht₂ : Terminal Q t₂) :
    t₁ = t₂ ∧ (ls₁ : Multiset Λ) = (ls₂ : Multiset Λ) :=
  EvolPath.terminal_unique_multiset _ x t₁ t₂ ls₁ ls₂ rfl h₁ h₂ ht₁ ht₂

/-- In particular all complete evolutionary paths out of `x` have equal length. -/
theorem EvolPath.length_eq {x t₁ t₂ : α} {ls₁ ls₂ : List Λ}
    (h₁ : EvolPath Q x t₁ ls₁) (h₂ : EvolPath Q x t₂ ls₂)
    (ht₁ : Terminal Q t₁) (ht₂ : Terminal Q t₂) : ls₁.length = ls₂.length := by
  have := (h₁.jordan_holder h₂ ht₁ ht₂).2
  simpa using congrArg Multiset.card this

section Decomp

variable (Q)

/-- The **normal form** of `x`: the (unique) terminal object reachable from `x`. -/
noncomputable def normalForm (x : α) : α := (exists_complete_path Q x).choose

/-- The **decomposition invariant** of `x`: the multiset of labels of any
complete evolutionary path out of `x`.  This is the object whose existence and
well-definedness constitutes the decomposition conjecture. -/
noncomputable def decomp (x : α) : Multiset Λ :=
  ((exists_complete_path Q x).choose_spec.choose : List Λ)

theorem path_normalForm (x : α) :
    ∃ ls : List Λ, EvolPath Q x (normalForm Q x) ls ∧ (ls : Multiset Λ) = decomp Q x
      ∧ Terminal Q (normalForm Q x) := by
  refine ⟨(exists_complete_path Q x).choose_spec.choose, ?_, rfl, ?_⟩
  · exact (exists_complete_path Q x).choose_spec.choose_spec.1
  · exact (exists_complete_path Q x).choose_spec.choose_spec.2

theorem terminal_normalForm (x : α) : Terminal Q (normalForm Q x) :=
  (path_normalForm Q x).choose_spec.2.2

theorem reach_normalForm (x : α) : Reach Q x (normalForm Q x) :=
  ⟨_, (path_normalForm Q x).choose_spec.1⟩

variable {Q}

/-- Any complete evolutionary path computes the invariants. -/
theorem decomp_eq_of_path {x t : α} {ls : List Λ} (h : EvolPath Q x t ls)
    (ht : Terminal Q t) : decomp Q x = (ls : Multiset Λ) ∧ normalForm Q x = t := by
  obtain ⟨ls', hp, hm, htn⟩ := path_normalForm Q x
  obtain ⟨he, hmm⟩ := hp.jordan_holder h htn ht
  exact ⟨by rw [← hm, hmm], he⟩

/-- The invariant is additive along a single quotient step: this is the
"one-step decomposition law". -/
theorem decomp_step {x y : α} {l : Λ} (h : Q.step x l y) :
    decomp Q x = l ::ₘ decomp Q y := by
  obtain ⟨ls, hp, hm, ht⟩ := path_normalForm Q y
  have hx : EvolPath Q x (normalForm Q y) (l :: ls) := EvolPath.cons h hp
  rw [(decomp_eq_of_path hx ht).1, ← hm, Multiset.cons_coe]

theorem normalForm_step {x y : α} {l : Λ} (h : Q.step x l y) :
    normalForm Q x = normalForm Q y :=
  (decomp_eq_of_path (EvolPath.cons h (path_normalForm Q y).choose_spec.1)
    (terminal_normalForm Q y)).2

/-- Terminal objects are exactly those with empty decomposition. -/
theorem terminal_iff_decomp_zero (x : α) : Terminal Q x ↔ decomp Q x = 0 := by
  constructor
  · intro h
    exact (decomp_eq_of_path (EvolPath.nil x) h).1
  · intro h l y hc
    rw [decomp_step hc] at h
    exact Multiset.cons_ne_zero h

/-- **Label conservation.**  The multiset of labels of *any* evolutionary path
`x → y` equals `decomp x - decomp y`; equivalently `decomp x = labels + decomp y`.
Hence the labels of a path depend only on its endpoints. -/
theorem EvolPath.labels_eq {x y : α} {ls : List Λ} (h : EvolPath Q x y ls) :
    decomp Q x = (ls : Multiset Λ) + decomp Q y := by
  induction h with
  | nil x => simp
  | @cons x l y t ls hs _ ih =>
      rw [decomp_step hs, ih, ← Multiset.cons_coe, Multiset.cons_add]

/-- Two evolutionary paths with the same endpoints carry the same labels. -/
theorem EvolPath.labels_unique {x y : α} {ls₁ ls₂ : List Λ}
    (h₁ : EvolPath Q x y ls₁) (h₂ : EvolPath Q x y ls₂) :
    (ls₁ : Multiset Λ) = (ls₂ : Multiset Λ) := by
  have e₁ := h₁.labels_eq
  have e₂ := h₂.labels_eq
  rw [e₂] at e₁
  exact (add_right_cancel e₁.symm)

/-- The **height** of `x`: the common length of all complete evolutionary paths
out of `x`. -/
noncomputable def height (x : α) : ℕ := Multiset.card (decomp Q x)

theorem height_step {x y : α} {l : Λ} (h : Q.step x l y) :
    height (Q := Q) x = height (Q := Q) y + 1 := by
  simp [height, decomp_step h]

theorem height_le_rank (x : α) : height (Q := Q) x ≤ Q.rank x := by
  obtain ⟨ls, hp, hm, _⟩ := path_normalForm Q x
  have : height (Q := Q) x = ls.length := by simp [height, ← hm]
  rw [this]
  exact hp.length_le_rank

theorem height_add_of_reach {x y : α} (h : Reach Q x y) :
    ∃ k, height (Q := Q) x = k + height (Q := Q) y := by
  obtain ⟨ls, hp⟩ := h
  exact ⟨ls.length, by simp [height, hp.labels_eq]⟩

/-- The normal form is an invariant of the evolutionary future. -/
theorem normalForm_eq_of_reach {x y : α} (h : Reach Q x y) :
    normalForm Q x = normalForm Q y := by
  obtain ⟨ls, hp⟩ := h
  obtain ⟨ls', hp', _, ht'⟩ := path_normalForm Q y
  exact (decomp_eq_of_path (hp.append hp') ht').2

/-- Decomposition is monotone along reachability. -/
theorem decomp_le_of_reach {x y : α} (h : Reach Q x y) : decomp Q y ≤ decomp Q x := by
  obtain ⟨ls, hp⟩ := h
  rw [hp.labels_eq]
  exact Multiset.le_add_left _ _

theorem Reach.trans {x y z : α} (h₁ : Reach Q x y) (h₂ : Reach Q y z) : Reach Q x z := by
  obtain ⟨ls₁, p₁⟩ := h₁
  obtain ⟨ls₂, p₂⟩ := h₂
  exact ⟨ls₁ ++ ls₂, p₁.append p₂⟩

theorem Reach.refl (x : α) : Reach Q x x := ⟨[], EvolPath.nil x⟩

theorem rank_le_of_reach {x y : α} (h : Reach Q x y) : Q.rank y ≤ Q.rank x := by
  obtain ⟨ls, hp⟩ := h
  exact hp.rank_le

/-- Reachability is antisymmetric: the evolutionary order is a genuine partial
order (no nontrivial cycles). -/
theorem reach_antisymm {x y : α} (h₁ : Reach Q x y) (h₂ : Reach Q y x) : x = y := by
  obtain ⟨ls₁, p₁⟩ := h₁
  cases p₁ with
  | nil => rfl
  | cons hs p =>
      exfalso
      have h1 := p.rank_le
      have h2 := Q.rank_lt hs
      have h3 := rank_le_of_reach h₂
      omega

/-- Any evolutionary path can be split at any prescribed position. -/
theorem EvolPath.split {x y : α} {ls : List Λ} (h : EvolPath Q x y ls) :
    ∀ j ≤ ls.length, ∃ z ls₁ ls₂,
      EvolPath Q x z ls₁ ∧ EvolPath Q z y ls₂ ∧ ls₁.length = j ∧ ls₂.length = ls.length - j := by
  induction h with
  | nil x =>
      intro j hj
      simp only [List.length_nil, Nat.le_zero] at hj
      subst hj
      exact ⟨x, [], [], EvolPath.nil x, EvolPath.nil x, rfl, rfl⟩
  | @cons x l y t ls hs hp ih =>
      intro j hj
      cases j with
      | zero => exact ⟨x, [], l :: ls, EvolPath.nil x, EvolPath.cons hs hp, rfl, by simp⟩
      | succ j =>
          simp only [List.length_cons, Nat.succ_le_succ_iff] at hj
          obtain ⟨z, ls₁, ls₂, p₁, p₂, h₁, h₂⟩ := ih j hj
          exact ⟨z, l :: ls₁, ls₂, EvolPath.cons hs p₁, p₂, by simp [h₁], by simp [h₂]⟩

/-- **The evolutionary order is graded.**  If `y` is reachable from `x`, every
height between `height y` and `height x` is realised by an intermediate stage. -/
theorem exists_intermediate_of_reach {x y : α} (h : Reach Q x y) {k : ℕ}
    (hk : height (Q := Q) y ≤ k) (hk' : k ≤ height (Q := Q) x) :
    ∃ z, Reach Q x z ∧ Reach Q z y ∧ height (Q := Q) z = k := by
  obtain ⟨ls, hp⟩ := h
  have hcard : height (Q := Q) x = ls.length + height (Q := Q) y := by
    simp [height, hp.labels_eq]
  obtain ⟨z, ls₁, ls₂, p₁, p₂, h₁, h₂⟩ := hp.split (height (Q := Q) x - k) (by omega)
  refine ⟨z, ⟨ls₁, p₁⟩, ⟨ls₂, p₂⟩, ?_⟩
  have hz : height (Q := Q) z = ls₂.length + height (Q := Q) y := by
    simp [height, p₂.labels_eq]
  omega

/-- **Confluence of evolution.**  Any two evolutionary futures of `x` have a
common future, namely the normal form of `x`. -/
theorem reach_confluent {x y z : α} (h₁ : Reach Q x y) (h₂ : Reach Q x z) :
    ∃ w, Reach Q y w ∧ Reach Q z w := by
  refine ⟨normalForm Q x, ?_, ?_⟩
  · rw [normalForm_eq_of_reach h₁]; exact reach_normalForm Q y
  · rw [normalForm_eq_of_reach h₂]; exact reach_normalForm Q z

end Decomp

section Functoriality

variable {β : Type*} {Λ' : Type*} {R : QuotientSystem β Λ'}

/-- A map of quotient systems transports evolutionary paths. -/
theorem EvolPath.map (f : α → β) (g : Λ → Λ')
    (hf : ∀ {x l y}, Q.step x l y → R.step (f x) (g l) (f y))
    {x t : α} {ls : List Λ} (h : EvolPath Q x t ls) :
    EvolPath R (f x) (f t) (ls.map g) := by
  induction h with
  | nil x => exact EvolPath.nil (f x)
  | cons hs _ ih => exact EvolPath.cons (hf hs) ih

/-- **Functoriality of the decomposition invariant.**  A step-preserving,
terminality-preserving map of quotient systems transports the invariant along
the label map. -/
theorem decomp_map (f : α → β) (g : Λ → Λ')
    (hf : ∀ {x l y}, Q.step x l y → R.step (f x) (g l) (f y))
    (hterm : ∀ {x : α}, Terminal Q x → Terminal R (f x)) (x : α) :
    decomp R (f x) = (decomp Q x).map g := by
  obtain ⟨ls, hp, hm, ht⟩ := path_normalForm Q x
  have hd := (decomp_eq_of_path (hp.map f g hf) (hterm ht)).1
  rw [hd, ← hm]
  simp

/-- Heights are preserved by maps of quotient systems. -/
theorem height_map (f : α → β) (g : Λ → Λ')
    (hf : ∀ {x l y}, Q.step x l y → R.step (f x) (g l) (f y))
    (hterm : ∀ {x : α}, Terminal Q x → Terminal R (f x)) (x : α) :
    height (Q := R) (f x) = height (Q := Q) x := by
  simp [height, decomp_map f g hf hterm x]

end Functoriality

end Shared.EvolutionaryPath