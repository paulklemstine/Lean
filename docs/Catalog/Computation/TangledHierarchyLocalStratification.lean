/-
# Locally stratified tangled hierarchies

This file unifies and strictly generalizes the two conservativity theorems of
`Catalog.Computation.TangledHierarchyConservativity`:

* *positive* tangles (loops allowed, but every truth atom positive), and
* *stratified* tangles (arbitrary polarity, but every dependency strictly
  descending in rank).

The common generalization is **local stratification**: a rank function `rk` on
names such that

* every **negative** dependency strictly decreases the rank, while
* every **positive** dependency merely does not increase it.

So strange loops are allowed *inside* a level, and only the negative
(refutation-like) dependencies have to point downwards.  The main theorem
`LocallyStratified.conservative` says such hierarchies are conservative over any
truth-free base theory: an arbitrarily tangled level can be bolted onto a theory
without changing a single old consequence.

The model is built level by level: on each level one takes the least fixed point
of the revision operator relative to the already-constructed lower levels
(Knaster–Tarski), and the levels are glued by a stability argument.
-/
import Catalog.Computation.TangledHierarchyConservativity

namespace TangledHierarchy

universe u v

variable {α : Type u} {ι : Type v}

/-! ## Polarised occurrences -/

/-- `OccursPol true c φ`: the name `c` has a positive occurrence in `φ`;
`OccursPol false c φ`: it has a negative occurrence. -/
def OccursPol : Bool → ι → Frm α ι → Prop
  | _, _, .atom _ => False
  | _, _, .fls => False
  | b, c, .imp φ ψ => OccursPol (!b) c φ ∨ OccursPol b c ψ
  | b, c, .tr c' => b = true ∧ c' = c

lemma occursPol_occurs : ∀ (φ : Frm α ι) (b : Bool) (c : ι), OccursPol b c φ → Occurs c φ := by
  intro φ
  induction φ with
  | atom a => intro b c h; exact h.elim
  | fls => intro b c h; exact h.elim
  | imp φ ψ ihφ ihψ =>
      rintro b c (h | h)
      · exact Or.inl (ihφ _ c h)
      · exact Or.inr (ihψ _ c h)
  | tr c' => intro b c h; exact h.2

/-- Every occurrence is either positive or negative. -/
lemma occurs_pol_total : ∀ (φ : Frm α ι) (c : ι),
    Occurs c φ → OccursPol true c φ ∨ OccursPol false c φ := by
  intro φ
  induction φ with
  | atom a => intro c h; exact h.elim
  | fls => intro c h; exact h.elim
  | imp φ ψ ihφ ihψ =>
      rintro c (h | h)
      · rcases ihφ c h with h' | h'
        · exact Or.inr (Or.inl h')
        · exact Or.inl (Or.inl h')
      · rcases ihψ c h with h' | h'
        · exact Or.inl (Or.inr h')
        · exact Or.inr (Or.inr h')
  | tr c' => intro c h; exact Or.inl ⟨rfl, h⟩

/-- A formula that is positive in the sense of `Polar` has no negative occurrences. -/
lemma polar_not_occursPol : ∀ (φ : Frm α ι) (b : Bool) (c : ι),
    Polar b φ → OccursPol (!b) c φ → False := by
  intro φ
  induction φ with
  | atom a => intro b c _ h; exact h.elim
  | fls => intro b c _ h; exact h.elim
  | imp φ ψ ihφ ihψ =>
      rintro b c ⟨hφ, hψ⟩ (h | h)
      · exact ihφ (!b) c hφ (by simpa using h)
      · exact ihψ b c hψ h
  | tr c' =>
      intro b c hb h
      simp only [Polar] at hb
      subst hb
      exact absurd h.1 (by simp)

/-! ## The polarised shift lemma -/

/-- Evaluation is monotone at positive occurrences and antitone at negative ones. -/
lemma eval_shift (v : α → Prop) : ∀ (φ : Frm α ι) (w w' : ι → Prop),
    (∀ c, (OccursPol true c φ → w c → w' c) ∧ (OccursPol false c φ → w' c → w c)) →
    eval v w φ → eval v w' φ := by
  intro φ
  induction φ with
  | atom a => intro w w' _ h; exact h
  | fls => intro w w' _ h; exact h
  | imp φ ψ ihφ ihψ =>
      intro w w' hyp h hx
      have hφ : eval v w φ :=
        ihφ w' w (fun c => ⟨fun ho => (hyp c).2 (Or.inl ho), fun ho => (hyp c).1 (Or.inl ho)⟩) hx
      exact ihψ w w' (fun c => ⟨fun ho => (hyp c).1 (Or.inr ho),
        fun ho => (hyp c).2 (Or.inr ho)⟩) (h hφ)
  | tr c' => intro w w' hyp h; exact (hyp c').1 ⟨rfl, rfl⟩ h

/-! ## Locally stratified hierarchies -/

/-- A rank function witnessing local stratification: negative dependencies go
strictly down, positive dependencies stay within the level. -/
structure LocallyStratified (den : ι → Frm α ι) (rk : ι → ℕ) : Prop where
  neg : ∀ c c', OccursPol false c' (den c) → rk c' < rk c
  pos : ∀ c c', OccursPol true c' (den c) → rk c' ≤ rk c

namespace LocallyStratified

variable {den : ι → Frm α ι} {rk : ι → ℕ}

/-- Any occurrence has rank at most the rank of the defined name. -/
lemma occurs_le (hs : LocallyStratified den rk) {c c' : ι} (h : Occurs c' (den c)) :
    rk c' ≤ rk c := by
  rcases occurs_pol_total (den c) c' h with h' | h'
  · exact hs.pos c c' h'
  · exact le_of_lt (hs.neg c c' h')

/-- The level-`n` revision operator: names of rank `< n` are frozen to the
already-built assignment `A`, names of rank `≤ n` are revised. -/
def levelStep (hs : LocallyStratified den rk) (v : α → Prop) (n : ℕ) (A : ι → Prop) :
    (ι → Prop) →o (ι → Prop) where
  toFun w := fun c =>
    if rk c ≤ n then eval v (fun c' => if rk c' < n then A c' else w c') (den c) else False
  monotone' := by
    intro w w' hww c
    by_cases hc : rk c ≤ n
    · simp only [hc, if_true]
      intro h
      refine eval_shift v (den c) _ _ (fun c' => ⟨?_, ?_⟩) h
      · intro hpos hx
        by_cases hlt : rk c' < n
        · simp only [if_pos hlt] at hx ⊢
          exact hx
        · simp only [if_neg hlt] at hx ⊢
          exact hww c' hx
      · intro hneg hx
        have hlt : rk c' < n := lt_of_lt_of_le (hs.neg c c' hneg) hc
        simp only [if_pos hlt] at hx ⊢
        exact hx
    · simp only [hc, if_false]
      exact fun h => h.elim

/-- The truth assignment after `n` levels have been built. -/
def levelFix (hs : LocallyStratified den rk) (v : α → Prop) : ℕ → (ι → Prop)
  | 0 => fun _ => False
  | n + 1 => OrderHom.lfp (levelStep hs v n (levelFix hs v n))

variable (hs : LocallyStratified den rk) (v : α → Prop)

lemma levelFix_succ (n : ℕ) (c : ι) :
    levelFix hs v (n + 1) c ↔
      (if rk c ≤ n then
        eval v (fun c' => if rk c' < n then levelFix hs v n c' else levelFix hs v (n + 1) c')
          (den c)
      else False) := by
  have h := OrderHom.map_lfp (levelStep hs v n (levelFix hs v n))
  have hc := congrFun h c
  rw [show levelFix hs v (n + 1) = OrderHom.lfp (levelStep hs v n (levelFix hs v n)) from rfl]
  rw [← hc]
  rfl

lemma levelFix_of_lt (n : ℕ) (c : ι) (hc : n < rk c) : ¬ levelFix hs v (n + 1) c := by
  rw [levelFix_succ hs v n c]
  simp [Nat.not_le.2 hc]

/-- **Stability**: once a level has been built, later stages do not change it. -/
lemma levelFix_stable_succ : ∀ n : ℕ, ∀ c : ι, rk c < n →
    (levelFix hs v (n + 1) c ↔ levelFix hs v n c) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => intro c hc; exact absurd hc (by omega)
    | m + 1 =>
      intro c hc
      have hcm : rk c ≤ m := by omega
      rw [levelFix_succ hs v (m + 1) c, levelFix_succ hs v m c]
      simp only [show rk c ≤ m + 1 from by omega, hcm, if_true]
      refine eval_congr_of_occurs v _ _ ?_
      intro c' hc'
      have hle : rk c' ≤ rk c := hs.occurs_le hc'
      by_cases hlt : rk c' < m
      · simp only [show rk c' < m + 1 from by omega, if_true, hlt]
        exact ih m (by omega) c' hlt
      · have hrk' : rk c' ≤ m := by omega
        simp [show rk c' < m + 1 from by omega, hlt]

/-- Stability in the strong form: all stages above the rank agree. -/
lemma levelFix_stable : ∀ (n : ℕ) (c : ι), rk c < n →
    (levelFix hs v n c ↔ levelFix hs v (rk c + 1) c) := by
  intro n
  induction n with
  | zero => intro c hc; exact absurd hc (by omega)
  | succ n ih =>
    intro c hc
    rcases Nat.lt_or_ge (rk c) n with h | h
    · rw [levelFix_stable_succ hs v n c h]
      exact ih c h
    · have : rk c = n := by omega
      rw [this]

/-- The canonical model of a locally stratified hierarchy. -/
def model : ι → Prop := fun c => levelFix hs v (rk c + 1) c

lemma model_isModel : TangleModel den v (model hs v) := by
  intro c
  have h := levelFix_succ hs v (rk c) c
  simp only [le_refl, if_true] at h
  rw [show model hs v c = levelFix hs v (rk c + 1) c from rfl, h]
  refine (eval_congr_of_occurs v _ _ ?_).symm
  intro c' hc'
  have hle : rk c' ≤ rk c := hs.occurs_le hc'
  by_cases hlt : rk c' < rk c
  · simp only [model, if_pos hlt]
    exact (levelFix_stable hs v (rk c) c' hlt).symm
  · have heq : rk c' = rk c := by omega
    rw [if_neg hlt]
    simp only [model, heq]

include hs in
/-- **Every locally stratified tangled hierarchy has a model.** -/
theorem exists_model : ∃ w, TangleModel den v w :=
  ⟨model hs v, model_isModel hs v⟩

include hs in
/-- **Main theorem: local stratification implies conservativity.**  A tangle whose
negative dependencies descend — however wildly its positive dependencies loop
within a level — adds no new truth-free consequences to any truth-free base
theory. -/
theorem conservative (T : Set (Frm α ι)) (hT : ∀ φ ∈ T, TrFree φ)
    (ψ : Frm α ι) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx den) ψ ↔ Conseq T ψ :=
  conservative_of_exists_model den (fun v => exists_model hs v) T hT ψ hψ

end LocallyStratified

/-! ## The two earlier theorems as special cases -/

/-- A positive tangle is locally stratified with the constant rank: one single
level containing all the strange loops. -/
theorem locallyStratified_of_positive (den : ι → Frm α ι) (hpos : ∀ c, Polar true (den c)) :
    LocallyStratified den (fun _ => 0) where
  neg := by
    intro c c' h
    exact absurd (polar_not_occursPol (den c) true c' (hpos c) (by simpa using h)) (by simp)
  pos := by intro c c' _; exact le_rfl

/-- A rank-stratified tangle is locally stratified. -/
theorem locallyStratified_of_stratified (den : ι → Frm α ι) (rk : ι → ℕ)
    (hrk : ∀ c c', Occurs c' (den c) → rk c' < rk c) : LocallyStratified den rk where
  neg := fun c c' h => hrk c c' (occursPol_occurs (den c) false c' h)
  pos := fun c c' h => le_of_lt (hrk c c' (occursPol_occurs (den c) true c' h))

/-- Local stratification really is a strict generalization: a tangle can have a
genuine positive self-loop on its own level *and* a negative dependency to a
lower level, so it is neither positive nor rank-stratified. -/
def mixedDen : Bool → Frm Unit Bool
  | false => Frm.fls
  | true => Frm.imp (Frm.tr false) (Frm.tr true)

theorem mixedDen_locallyStratified :
    LocallyStratified mixedDen (fun b => if b then 1 else 0) where
  neg := by
    intro c c' h
    cases c with
    | false => exact absurd h (by simp [mixedDen, OccursPol])
    | true =>
        have hc' : c' = false := by
          have := h
          simp only [mixedDen, OccursPol] at this
          tauto
        subst hc'
        simp
  pos := by
    intro c c' h
    cases c with
    | false => exact absurd h (by simp [mixedDen, OccursPol])
    | true =>
        have hc' : c' = true := by
          have := h
          simp only [mixedDen, OccursPol] at this
          tauto
        subst hc'
        simp

theorem mixedDen_not_positive : ¬ (∀ c, Polar true (mixedDen c)) := by
  intro h
  have := h true
  simp [mixedDen, Polar] at this

theorem mixedDen_not_stratified :
    ¬ ∃ rk : Bool → ℕ, ∀ c c', Occurs c' (mixedDen c) → rk c' < rk c := by
  rintro ⟨rk, hrk⟩
  have : rk true < rk true := hrk true true (by simp [mixedDen, Occurs])
  omega

/-- The mixed tangle nevertheless has a model, hence is conservative. -/
theorem mixedDen_conservative (T : Set (Frm Unit Bool)) (hT : ∀ φ ∈ T, TrFree φ)
    (ψ : Frm Unit Bool) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx mixedDen) ψ ↔ Conseq T ψ :=
  LocallyStratified.conservative mixedDen_locallyStratified T hT ψ hψ

/-! ## The boundary: local stratification is sufficient but not necessary -/

/-- A tangle whose single sentence is `tr c → tr c`: the name occurs both
positively and negatively in its own definition. -/
def tautDen : Unit → Frm Unit Unit := fun _ => Frm.imp (Frm.tr ()) (Frm.tr ())

theorem tautDen_not_locallyStratified : ¬ ∃ rk, LocallyStratified tautDen rk := by
  rintro ⟨rk, hs⟩
  have h : rk () < rk () := hs.neg () () (by simp [tautDen, OccursPol])
  omega

theorem tautDen_hasModel (v : Unit → Prop) : TangleModel tautDen v (fun _ => True) := by
  intro c
  simp [tautDen, eval]

/-- Nevertheless this tangle is conservative: local stratification is a
sufficient, not a necessary, condition — the exact criterion is solvability of
the loop equations (`conservative_iff_exists_model`). -/
theorem tautDen_conservative (T : Set (Frm Unit Unit)) (hT : ∀ φ ∈ T, TrFree φ)
    (ψ : Frm Unit Unit) (hψ : TrFree ψ) :
    Conseq (T ∪ tarskiAx tautDen) ψ ↔ Conseq T ψ :=
  conservative_of_exists_model tautDen (fun v => ⟨_, tautDen_hasModel v⟩) T hT ψ hψ

end TangledHierarchy