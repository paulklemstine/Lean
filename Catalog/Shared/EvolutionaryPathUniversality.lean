/-
  # Universality and Rigidity of Evolutionary Decomposition

  Second research cycle on top of `Shared.EvolutionaryPathCore`.

  ## Universality
  `multisetSystem Λ` is the quotient system on `Multiset Λ` whose steps delete a
  single element.  `decomp` is a morphism of quotient systems into it
  (`decomp_step_multiset`), evolutionary paths map to deletion sequences
  (`evolPath_to_multiset`), and the multiset system computes its own invariant
  (`decomp_multisetSystem`).  So *every* evolutionary process is a shadow of
  multiset deletion: the universal target of the theory.

  ## Rigidity (how faithful is that shadow?)
  The bold conjecture "`decomp` separates the reachable stages of `x`" is
  **false in general**: `diamond_decomp_not_injective` exhibits a four-element
  quotient system (the Klein-type diamond) with two distinct stages having equal
  invariants.  The guarded version is **true**:

  * `Separated Q` — distinct targets of a step out of `x` have distinct labels
    (equivalently, `(x, l)` determines the target);
  * `EvolPath.pull_forward` — in a separated system any label occurring later in
    a path can be pulled to the front (a strong commutation lemma, proved from
    the exchange axiom);
  * `evolPath_endpoint_unique` — hence the endpoint of a path is determined by
    its *multiset* of labels;
  * `decomp_injOn_reach` — hence `decomp` is injective on the stages reachable
    from any fixed object.

  ## Consequences in arithmetic
  `natSystem` is separated, so the invariant is a *complete* divisibility
  invariant: `nat_dvd_iff_decomp_le`, `nat_eq_of_decomp_eq`.
-/
import Shared.EvolutionaryPathCombinatorics

namespace Shared.EvolutionaryPath

universe u v

variable {α : Type u} {Λ : Type v}

/-! ## The universal multiset system -/

/-- Deleting one element of a multiset. -/
def multisetStep (M : Multiset Λ) (l : Λ) (N : Multiset Λ) : Prop := M = l ::ₘ N

/-- The universal quotient system: multisets under deletion of one element. -/
def multisetSystem (Λ : Type v) : QuotientSystem (Multiset Λ) Λ where
  step := multisetStep
  rank := Multiset.card
  rank_lt := by
    rintro M l N rfl
    simp
  label_unique := by
    rintro M l₁ l₂ N rfl h
    exact (Multiset.cons_inj_left N).1 h
  exchange := by
    rintro M l₁ N₁ l₂ N₂ rfl h hne
    rcases Multiset.cons_eq_cons.1 h with ⟨-, rfl⟩ | ⟨-, cs, hcs₁, hcs₂⟩
    · exact absurd rfl hne
    · exact ⟨cs, hcs₁, hcs₂⟩

theorem multisetSystem_terminal_iff (M : Multiset Λ) :
    Terminal (multisetSystem Λ) M ↔ M = 0 := by
  constructor
  · intro h
    by_contra hM
    obtain ⟨l, hl⟩ := Multiset.exists_mem_of_ne_zero hM
    obtain ⟨N, rfl⟩ := Multiset.exists_cons_of_mem hl
    exact h l N rfl
  · rintro rfl l N (h : (0 : Multiset Λ) = l ::ₘ N)
    exact Multiset.cons_ne_zero h.symm

/-- The multiset system computes its own invariant. -/
theorem decomp_multisetSystem (M : Multiset Λ) : decomp (multisetSystem Λ) M = M := by
  induction M using Multiset.induction with
  | empty =>
      exact (terminal_iff_decomp_zero (Q := multisetSystem Λ) 0).1
        ((multisetSystem_terminal_iff (0 : Multiset Λ)).2 rfl)
  | cons a M ih =>
      have hstep : (multisetSystem Λ).step (a ::ₘ M) a M := rfl
      rw [decomp_step hstep, ih]

variable {Q : QuotientSystem α Λ}

/-- `decomp` turns a quotient step into a deletion step: it is a morphism of
quotient systems into the universal multiset system. -/
theorem decomp_step_multiset {x y : α} {l : Λ} (h : Q.step x l y) :
    (multisetSystem Λ).step (decomp Q x) l (decomp Q y) := decomp_step h

theorem decomp_terminal_multiset {x : α} (h : Terminal Q x) :
    Terminal (multisetSystem Λ) (decomp Q x) :=
  (multisetSystem_terminal_iff _).2 ((terminal_iff_decomp_zero x).1 h)

/-- **Universal representation.**  Every evolutionary path is carried by
`decomp` to the deletion sequence of its label multiset. -/
theorem evolPath_to_multiset {x t : α} {ls : List Λ} (h : EvolPath Q x t ls) :
    EvolPath (multisetSystem Λ) (decomp Q x) (decomp Q t) ls := by
  have := h.map (R := multisetSystem Λ) (decomp Q) id (fun hs => decomp_step_multiset hs)
  simpa using this

/-! ## Rigidity: when is the universal representation faithful? -/

/-- A quotient system is **separated** when a step is determined by its source
and its label. -/
def Separated (Q : QuotientSystem α Λ) : Prop :=
  ∀ {x l y₁ y₂}, Q.step x l y₁ → Q.step x l y₂ → y₁ = y₂

/-- **Commutation / pull-forward lemma.**  In a separated system, a label used
somewhere along a path can be performed first, the rest of the path being
rearranged accordingly. -/
theorem EvolPath.pull_forward (hsep : Separated Q) {x y : α} {ls : List Λ}
    (h : EvolPath Q x y ls) : ∀ {l w : _}, l ∈ ls → Q.step x l w →
      ∃ ls', EvolPath Q w y ls' ∧ l ::ₘ (ls' : Multiset Λ) = (ls : Multiset Λ) := by
  induction h with
  | nil x =>
      intro l w hl _
      simp at hl
  | @cons x l₁ x₁ y ls₁ hs hp ih =>
      intro l w hl hw
      by_cases hll : l₁ = l
      · subst hll
        have hx : x₁ = w := hsep hs hw
        subst hx
        exact ⟨ls₁, hp, by rw [Multiset.cons_coe]⟩
      · have hl' : l ∈ ls₁ := by
          rcases List.mem_cons.1 hl with rfl | h'
          · exact absurd rfl hll
          · exact h'
        have hne : x₁ ≠ w := by
          rintro rfl
          exact hll (Q.label_unique hs hw)
        obtain ⟨v, hv₁, hv₂⟩ := Q.exchange hs hw hne
        obtain ⟨ls'', hpath, hmul⟩ := ih hl' hv₁
        refine ⟨l₁ :: ls'', EvolPath.cons hv₂ hpath, ?_⟩
        rw [← Multiset.cons_coe, ← Multiset.cons_coe, Multiset.cons_swap, hmul]

/-- **Endpoint rigidity.**  In a separated system the endpoint of an
evolutionary path depends only on the multiset of labels used. -/
theorem evolPath_endpoint_unique (hsep : Separated Q) :
    ∀ (n : ℕ) (x y z : α) (ls₁ ls₂ : List Λ), ls₁.length = n →
      EvolPath Q x y ls₁ → EvolPath Q x z ls₂ → (ls₁ : Multiset Λ) = (ls₂ : Multiset Λ) →
      y = z := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro x y z ls₁ ls₂ hlen h₁ h₂ hm
    cases h₁ with
    | nil =>
        have : ls₂ = [] := (Multiset.coe_eq_zero ls₂).1 (by simpa using hm.symm)
        subst this
        cases h₂ with
        | nil => rfl
    | @cons _ l₁ x₁ _ ls₁' hs p₁ =>
        have hmem : l₁ ∈ ls₂ := by
          have : l₁ ∈ (ls₂ : Multiset Λ) := by
            rw [← hm, ← Multiset.cons_coe]
            exact Multiset.mem_cons_self _ _
          exact Multiset.mem_coe.1 this
        obtain ⟨ls₂', p₂, hmul⟩ := h₂.pull_forward hsep hmem hs
        have htail : (ls₁' : Multiset Λ) = (ls₂' : Multiset Λ) := by
          have : l₁ ::ₘ (ls₁' : Multiset Λ) = l₁ ::ₘ (ls₂' : Multiset Λ) := by
            rw [hmul, Multiset.cons_coe, hm]
          exact (Multiset.cons_inj_right l₁).1 this
        exact ih ls₁'.length (by simp [← hlen]) x₁ y z ls₁' ls₂' rfl p₁ p₂ htail

/-- **Faithfulness on futures.**  In a separated system the decomposition
invariant separates the stages reachable from a fixed object. -/
theorem decomp_injOn_reach (hsep : Separated Q) {x y z : α}
    (hy : Reach Q x y) (hz : Reach Q x z) (h : decomp Q y = decomp Q z) : y = z := by
  obtain ⟨ls₁, p₁⟩ := hy
  obtain ⟨ls₂, p₂⟩ := hz
  have e₁ := p₁.labels_eq
  have e₂ := p₂.labels_eq
  rw [h] at e₁
  have : (ls₁ : Multiset Λ) = (ls₂ : Multiset Λ) := add_right_cancel (e₁.symm.trans e₂)
  exact evolPath_endpoint_unique hsep ls₁.length x y z ls₁ ls₂ rfl p₁ p₂ this

/-! ## The diamond: faithfulness genuinely needs separation -/

/-- Steps of the Klein-type diamond `3 → {1,2} → 0` with a single label. -/
def diamondStep : Fin 4 → Unit → Fin 4 → Prop := fun x _ y =>
  (x = 3 ∧ (y = 1 ∨ y = 2)) ∨ ((x = 1 ∨ x = 2) ∧ y = 0)

/-- The diamond is a genuine quotient system: it is terminating, its labels are
(trivially) determined, and its unique diamond closes. -/
def diamondSystem : QuotientSystem (Fin 4) Unit where
  step := diamondStep
  rank := fun x => if x = 3 then 2 else if x = 0 then 0 else 1
  rank_lt := by
    rintro x l y (⟨rfl, rfl | rfl⟩ | ⟨rfl | rfl, rfl⟩) <;> decide
  label_unique := fun _ _ => Subsingleton.elim _ _
  exchange := by
    have key : ∀ x y₁ y₂ : Fin 4, diamondStep x () y₁ → diamondStep x () y₂ → y₁ ≠ y₂ →
        ∃ z, diamondStep y₁ () z ∧ diamondStep y₂ () z := by
      unfold diamondStep
      decide
    intro x l₁ y₁ l₂ y₂ h₁ h₂ hne
    exact key x y₁ y₂ h₁ h₂ hne

@[simp] theorem diamond_step_iff {x y : Fin 4} {l : Unit} :
    diamondSystem.step x l y ↔ diamondStep x l y := Iff.rfl

theorem diamond_terminal_zero : Terminal diamondSystem 0 := by
  intro l y h
  rcases (h : diamondStep 0 l y) with ⟨hx, -⟩ | ⟨hx | hx, -⟩ <;> exact absurd hx (by decide)

theorem diamond_decomp_one : decomp diamondSystem 1 = {()} := by
  have hstep : diamondSystem.step 1 () 0 := diamond_step_iff.2 (Or.inr ⟨Or.inl rfl, rfl⟩)
  rw [decomp_step hstep, (terminal_iff_decomp_zero (Q := diamondSystem) 0).1 diamond_terminal_zero]
  rfl

theorem diamond_decomp_two : decomp diamondSystem 2 = {()} := by
  have hstep : diamondSystem.step 2 () 0 := diamond_step_iff.2 (Or.inr ⟨Or.inr rfl, rfl⟩)
  rw [decomp_step hstep, (terminal_iff_decomp_zero (Q := diamondSystem) 0).1 diamond_terminal_zero]
  rfl

/-- **The bold conjecture is false without separation.**  In the diamond system
two *distinct* stages reachable from the top have the same decomposition
invariant, so the universal multiset representation is not faithful. -/
theorem diamond_decomp_not_injective :
    ∃ (x y z : Fin 4), Reach diamondSystem x y ∧ Reach diamondSystem x z ∧
      decomp diamondSystem y = decomp diamondSystem z ∧ y ≠ z := by
  have s₁ : diamondSystem.step 3 () 1 := diamond_step_iff.2 (Or.inl ⟨rfl, Or.inl rfl⟩)
  have s₂ : diamondSystem.step 3 () 2 := diamond_step_iff.2 (Or.inl ⟨rfl, Or.inr rfl⟩)
  refine ⟨3, 1, 2, ⟨[()], EvolPath.cons s₁ (EvolPath.nil 1)⟩,
    ⟨[()], EvolPath.cons s₂ (EvolPath.nil 2)⟩, ?_, by decide⟩
  rw [diamond_decomp_one, diamond_decomp_two]

/-- The diamond is exactly the failure of separation. -/
theorem diamond_not_separated : ¬ Separated diamondSystem := by
  intro h
  have s₁ : diamondSystem.step 3 () 1 := diamond_step_iff.2 (Or.inl ⟨rfl, Or.inl rfl⟩)
  have s₂ : diamondSystem.step 3 () 2 := diamond_step_iff.2 (Or.inl ⟨rfl, Or.inr rfl⟩)
  exact absurd (h s₁ s₂) (by decide)

/-! ## Arithmetic and combinatorial consequences -/

theorem natSystem_separated : Separated natSystem := by
  rintro n p m₁ m₂ ⟨hp, -, e₁⟩ ⟨-, -, e₂⟩
  exact Nat.eq_of_mul_eq_mul_left hp.pos (e₁ ▸ e₂)

theorem finsetSystem_separated {ι : Type*} [DecidableEq ι] :
    Separated (finsetSystem (ι := ι)) := by
  rintro S a T₁ T₂ ⟨-, rfl⟩ ⟨-, rfl⟩
  rfl

/-- **The evolutionary invariant is a complete divisibility invariant.** -/
theorem nat_dvd_iff_decomp_le {m n : ℕ} (hm : 0 < m) (hn : 0 < n) :
    m ∣ n ↔ decomp natSystem m ≤ decomp natSystem n := by
  constructor
  · intro h
    exact decomp_le_of_reach ((natReach_iff_dvd hn hm).2 h)
  · intro h
    rw [← Nat.factorization_le_iff_dvd hm.ne' hn.ne']
    intro p
    have h₁ := natDecomp_count_eq_factorization hm p
    have h₂ := natDecomp_count_eq_factorization hn p
    have := Multiset.le_iff_count.1 h p
    omega

/-- Positive integers are determined by their evolutionary invariant. -/
theorem nat_eq_of_decomp_eq {m n : ℕ} (hm : 0 < m) (hn : 0 < n)
    (h : decomp natSystem m = decomp natSystem n) : m = n := by
  refine decomp_injOn_reach natSystem_separated (x := m * n) ?_ ?_ h
  · exact (natReach_iff_dvd (Nat.mul_pos hm hn) hm).2 ⟨n, rfl⟩
  · exact (natReach_iff_dvd (Nat.mul_pos hm hn) hn).2 ⟨m, Nat.mul_comm m n⟩

end Shared.EvolutionaryPath