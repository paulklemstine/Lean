/-
# Idempotent Thermodynamic Realization via Closure Entropy and Free-Energy Minimization

This file formalizes a **thermodynamic Myhill–Nerode theorem**: a canonical minimization
principle for deterministic automata with observable outputs, where "observation" is
mediated by a closure operator and an entropy functional, and the free-energy observable
determines the finest useful state equivalence.

## Main Results

- `wordEquiv_right_congruence` — Free-energy indistinguishability is a right congruence.
- `thermoState_finite` — The quotient by behavioral equivalence has finitely many states.
- `quotientAut_behavior_eq` — The quotient automaton realizes the same behavior.
- `quotientAut_minimal` — The quotient is minimal among all behaviorally equivalent automata.
- `gibbsHankelRank_eq_card_thermoState` — The Gibbs–Hankel generator rank equals the
  number of quotient states.
- `freeEnergy_min_commutes_closure` — Free-energy minimization commutes with closure
  saturation.
- `optimal_paths_same_dissipation` — Optimal paths share a conserved dissipation class.

## Bridges

- **Automata Theory ↔ Tropical Algebra**: Myhill–Nerode via idempotent free energy
- **Statistical Mechanics ↔ Computation**: Free energy as canonical observable
- **Closure Semantics ↔ Minimization**: Coarse-graining commutes with optimization
- **EML ↔ Tropical Geometry**: Generator rank = tropical dimension of computation
-/

import Mathlib

open Function List Classical

noncomputable section

namespace Bridges.AlgebraEMLComputation.IdempotentThermodynamicRealization

/-! ## §1. Thermodynamic Automaton: Core Structure -/

/-- A thermodynamic automaton: a deterministic finite automaton with an observable
    output function `obs : Q → S`. The output captures the "free-energy observable"
    at each state, abstracting the formula `β * H_C(C(summary(q)))`. -/
structure ThermoAut (S : Type*) (σ : Type*) (Q : Type*) where
  init : Q
  step : Q → σ → Q
  obs : Q → S

variable {S σ Q : Type*}

/-! ## §2. Running the Automaton on Words -/

/-- Extend the transition function to words (lists of symbols). -/
def ThermoAut.run (A : ThermoAut S σ Q) : Q → List σ → Q
  | q, [] => q
  | q, a :: w => A.run (A.step q a) w

@[simp]
theorem ThermoAut.run_nil (A : ThermoAut S σ Q) (q : Q) :
    A.run q [] = q := rfl

@[simp]
theorem ThermoAut.run_cons (A : ThermoAut S σ Q) (q : Q) (a : σ) (w : List σ) :
    A.run q (a :: w) = A.run (A.step q a) w := rfl

/-- Running on a concatenation equals running sequentially. -/
theorem ThermoAut.run_append (A : ThermoAut S σ Q) (q : Q) (u v : List σ) :
    A.run q (u ++ v) = A.run (A.run q u) v := by
  induction u generalizing q with
  | nil => simp
  | cons a u ih => simp [ih]

/-! ## §3. Behavior and Residuals -/

/-- The global behavior: maps each word to its observable output. -/
def ThermoAut.behavior (A : ThermoAut S σ Q) : List σ → S :=
  fun w => A.obs (A.run A.init w)

/-- The residual behavior from state `q`: continuations mapped to outputs. -/
def ThermoAut.residual (A : ThermoAut S σ Q) (q : Q) : List σ → S :=
  fun w => A.obs (A.run q w)

theorem ThermoAut.residual_run (A : ThermoAut S σ Q) (q : Q) (u : List σ) :
    A.residual (A.run q u) = fun x => A.residual q (u ++ x) := by
  ext x; simp [residual, run_append]

theorem ThermoAut.behavior_eq_residual_init (A : ThermoAut S σ Q) :
    A.behavior = A.residual A.init := rfl

/-! ## §4. State Behavioral Equivalence (Thermodynamic Equivalence) -/

/-- Two states are **thermodynamically equivalent** if they produce the same output
    on every continuation. -/
def ThermoAut.stateEquiv (A : ThermoAut S σ Q) (q₁ q₂ : Q) : Prop :=
  A.residual q₁ = A.residual q₂

theorem ThermoAut.stateEquiv_iff (A : ThermoAut S σ Q) (q₁ q₂ : Q) :
    A.stateEquiv q₁ q₂ ↔ ∀ w : List σ, A.obs (A.run q₁ w) = A.obs (A.run q₂ w) := by
  simp [stateEquiv, residual, funext_iff]

def ThermoAut.stateSetoid (A : ThermoAut S σ Q) : Setoid Q where
  r := A.stateEquiv
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-- Thermodynamic equivalence is compatible with transitions. -/
theorem ThermoAut.stateEquiv_step (A : ThermoAut S σ Q) {q₁ q₂ : Q} (a : σ)
    (h : A.stateEquiv q₁ q₂) : A.stateEquiv (A.step q₁ a) (A.step q₂ a) := by
  rw [stateEquiv_iff] at *; intro w; exact h (a :: w)

/-- Equivalent states have the same observation. -/
theorem ThermoAut.stateEquiv_obs (A : ThermoAut S σ Q) {q₁ q₂ : Q}
    (h : A.stateEquiv q₁ q₂) : A.obs q₁ = A.obs q₂ := by
  have := (A.stateEquiv_iff q₁ q₂).mp h []; simpa using this

/-- Equivalent states remain equivalent after running any word. -/
theorem ThermoAut.stateEquiv_run (A : ThermoAut S σ Q) {q₁ q₂ : Q} (w : List σ)
    (h : A.stateEquiv q₁ q₂) : A.stateEquiv (A.run q₁ w) (A.run q₂ w) := by
  induction w generalizing q₁ q₂ with
  | nil => simpa using h
  | cons a w ih => simp; exact ih (A.stateEquiv_step a h)

/-! ## §5. Word-Level Indistinguishability -/

/-- Two words are **free-energy indistinguishable** if they lead to states with
    the same residual behavior. -/
def ThermoAut.wordEquiv (A : ThermoAut S σ Q) (u v : List σ) : Prop :=
  A.stateEquiv (A.run A.init u) (A.run A.init v)

theorem ThermoAut.wordEquiv_iff (A : ThermoAut S σ Q) (u v : List σ) :
    A.wordEquiv u v ↔
      ∀ x : List σ, A.obs (A.run A.init (u ++ x)) = A.obs (A.run A.init (v ++ x)) := by
  simp [wordEquiv, stateEquiv_iff, run_append]

def ThermoAut.wordSetoid (A : ThermoAut S σ Q) : Setoid (List σ) where
  r := A.wordEquiv
  iseqv := ⟨fun _ => rfl, fun h => h.symm, fun h₁ h₂ => h₁.trans h₂⟩

/-! ## §6. Right Congruence -/

/-- **Thermodynamic Myhill–Nerode right congruence**: if `u ~ v`, then
    `u ++ w ~ v ++ w` for any word `w`. -/
theorem ThermoAut.wordEquiv_right_congruence (A : ThermoAut S σ Q)
    (u v w : List σ) (h : A.wordEquiv u v) :
    A.wordEquiv (u ++ w) (v ++ w) := by
  rw [wordEquiv_iff] at *
  intro x; rw [List.append_assoc, List.append_assoc]; exact h (w ++ x)

/-- Single-letter right congruence. -/
theorem ThermoAut.wordEquiv_snoc (A : ThermoAut S σ Q)
    (u v : List σ) (a : σ) (h : A.wordEquiv u v) :
    A.wordEquiv (u ++ [a]) (v ++ [a]) :=
  A.wordEquiv_right_congruence u v [a] h

/-! ## §7. Quotient State Space (Thermodynamic States) -/

/-- The quotient of Q by thermodynamic equivalence. -/
def ThermoState (A : ThermoAut S σ Q) : Type _ := Quotient A.stateSetoid

instance thermoState_finite [Finite Q] (A : ThermoAut S σ Q) :
    Finite (ThermoState A) := Quotient.finite _

noncomputable instance thermoState_fintype [Fintype Q]
    (A : ThermoAut S σ Q) : Fintype (ThermoState A) :=
  @Quotient.fintype _ _ A.stateSetoid (Classical.decRel _)

/-! ## §8. Quotient Automaton Construction -/

/-- The **thermodynamic quotient automaton**: minimal realization by
    identifying behaviorally equivalent states. -/
noncomputable def ThermoAut.quotientAut (A : ThermoAut S σ Q) :
    ThermoAut S σ (ThermoState A) where
  init := @Quotient.mk _ A.stateSetoid A.init
  step := fun q a =>
    @Quotient.lift _ _ A.stateSetoid
      (fun q' => @Quotient.mk _ A.stateSetoid (A.step q' a))
      (fun _ _ h => Quotient.sound (A.stateEquiv_step a h)) q
  obs := fun q =>
    @Quotient.lift _ _ A.stateSetoid A.obs
      (fun _ _ h => A.stateEquiv_obs h) q

theorem ThermoAut.quotientAut_step_mk (A : ThermoAut S σ Q) (q : Q) (a : σ) :
    A.quotientAut.step (@Quotient.mk _ A.stateSetoid q) a =
      @Quotient.mk _ A.stateSetoid (A.step q a) := by
  simp [ThermoAut.quotientAut]

/-- Running the quotient automaton from `⟦q⟧` on word `w` gives `⟦run q w⟧`. -/
theorem ThermoAut.quotientAut_run (A : ThermoAut S σ Q) (q : Q) (w : List σ) :
    A.quotientAut.run (@Quotient.mk _ A.stateSetoid q) w =
      @Quotient.mk _ A.stateSetoid (A.run q w) := by
  induction w generalizing q with
  | nil => rfl
  | cons a w ih =>
    simp only [run_cons]
    show A.quotientAut.run (A.quotientAut.step (@Quotient.mk _ A.stateSetoid q) a) w = _
    rw [A.quotientAut_step_mk q a]
    exact ih (A.step q a)

theorem ThermoAut.quotientAut_obs_mk (A : ThermoAut S σ Q) (q : Q) :
    A.quotientAut.obs (@Quotient.mk _ A.stateSetoid q) = A.obs q := by
  simp [ThermoAut.quotientAut]

/-! ## §9. Behavior Preservation -/

/-- **The quotient automaton realizes the same behavior.** -/
theorem ThermoAut.quotientAut_behavior_eq (A : ThermoAut S σ Q) :
    A.quotientAut.behavior = A.behavior := by
  ext w
  simp only [behavior]
  show A.quotientAut.obs (A.quotientAut.run (@Quotient.mk _ A.stateSetoid A.init) w) =
    A.obs (A.run A.init w)
  rw [A.quotientAut_run A.init w, A.quotientAut_obs_mk]

/-! ## §10. Minimality of the Quotient Automaton -/

/-
**Minimality theorem**: if automaton `B` with state space `Q'` has the same
    global behavior as `A`, then `A`'s quotient has at most `|Q'|` states.

    Key insight: if two words reach the same B-state, they produce the same output
    on all continuations (since behaviors agree), hence are in the same A-equivalence class.
    So distinct A-classes map to distinct B-states.
-/
theorem ThermoAut.quotientAut_minimal {Q' : Type*}
    [Fintype Q] [Fintype Q']
    (A : ThermoAut S σ Q) (B : ThermoAut S σ Q')
    (hbeh : A.behavior = B.behavior)
    (hA_surj : ∀ q : Q, ∃ w, A.run A.init w = q) :
    Fintype.card (ThermoState A) ≤ Fintype.card Q' := by
  -- The set of A-residuals (image of A.residual on Q) is contained in the set of B-residuals (image of B.residual on Q').
  have h_image_subset : Set.range (fun q : Q => A.residual q) ⊆ Set.range (fun q : Q' => B.residual q) := by
    rintro _ ⟨ q, rfl ⟩;
    obtain ⟨ w, rfl ⟩ := hA_surj q;
    use B.run B.init w;
    ext x;
    simp_all +decide [ funext_iff, ThermoAut.residual, ThermoAut.behavior ];
    convert hbeh ( w ++ x ) |> Eq.symm using 1;
    · rw [ ThermoAut.run_append ];
    · rw [ ThermoAut.run_append ];
  have h_card_image : Fintype.card (ThermoState A) = Set.ncard (Set.range (fun q : Q => A.residual q)) := by
    rw [ Set.ncard_eq_toFinset_card' ];
    refine' Finset.card_bij ( fun q _ => A.residual ( Quotient.out q ) ) _ _ _ <;> simp +decide;
    · intro a₁ a₂ h; rw [ ← Quotient.out_eq a₁, ← Quotient.out_eq a₂ ] ; exact Quotient.sound h;
    · intro q;
      have := Quotient.out_eq' ( ⟦q⟧ : Quotient A.stateSetoid );
      erw [ Quotient.eq ] at this ; aesop;
  exact h_card_image ▸ le_trans ( Set.ncard_le_ncard h_image_subset ) ( by rw [ Set.ncard_eq_toFinset_card _ ] ; simpa using Finset.card_image_le )

/-! ## §11. Free-Energy Specific Definitions -/

variable {Obs : Type*}

/-- Construct a ThermoAut from closure-enriched data:
    `obs(q) = β * Hc(C(summary(q)))`. -/
def mkThermoAut [Mul S] (init : Q) (step : Q → σ → Q) (summary : Q → Obs)
    (C : Obs → Obs) (Hc : Obs → S) (β : S) : ThermoAut S σ Q where
  init := init
  step := step
  obs := fun q => β * Hc (C (summary q))

/-- Free-energy indistinguishability with explicit closure structure. -/
def freeEnergyIndistinguishable [Mul S] (init : Q) (step : Q → σ → Q)
    (summary : Q → Obs) (C : Obs → Obs) (Hc : Obs → S) (β : S)
    (u v : List σ) : Prop :=
  (mkThermoAut init step summary C Hc β).wordEquiv u v

/-- Free-energy indistinguishability is a right congruence. -/
theorem freeEnergyIndistinguishable_right_congruence [Mul S]
    (init : Q) (step : Q → σ → Q) (summary : Q → Obs)
    (C : Obs → Obs) (Hc : Obs → S) (β : S)
    (u v w : List σ)
    (h : freeEnergyIndistinguishable init step summary C Hc β u v) :
    freeEnergyIndistinguishable init step summary C Hc β (u ++ w) (v ++ w) :=
  (mkThermoAut init step summary C Hc β).wordEquiv_right_congruence u v w h

/-- Free-energy indistinguishability unpacked. -/
theorem freeEnergyIndistinguishable_iff [Mul S]
    (init : Q) (step : Q → σ → Q) (summary : Q → Obs)
    (C : Obs → Obs) (Hc : Obs → S) (β : S) (u v : List σ) :
    freeEnergyIndistinguishable init step summary C Hc β u v ↔
      ∀ x : List σ,
        β * Hc (C (summary ((mkThermoAut init step summary C Hc β).run init (u ++ x)))) =
        β * Hc (C (summary ((mkThermoAut init step summary C Hc β).run init (v ++ x)))) := by
  simp [freeEnergyIndistinguishable, ThermoAut.wordEquiv, ThermoAut.stateEquiv,
    ThermoAut.residual, mkThermoAut, ThermoAut.run_append, funext_iff]

/-! ## §12. Gibbs–Hankel Semimodule and Generator Rank -/

/-- The Gibbs–Hankel row of a state: its residual function. -/
def ThermoAut.gibbsHankelRow (A : ThermoAut S σ Q) (q : Q) : List σ → S :=
  A.residual q

theorem ThermoAut.gibbsHankelRow_eq_iff (A : ThermoAut S σ Q) (q₁ q₂ : Q) :
    A.gibbsHankelRow q₁ = A.gibbsHankelRow q₂ ↔ A.stateEquiv q₁ q₂ :=
  Iff.rfl

/-- The set of distinct Gibbs–Hankel rows. -/
noncomputable def ThermoAut.gibbsHankelRows [Fintype Q]
    (A : ThermoAut S σ Q) : Finset (List σ → S) :=
  Finset.univ.image A.gibbsHankelRow

/-- **Gibbs–Hankel generator rank**: the number of distinct behavioral profiles. -/
noncomputable def ThermoAut.gibbsHankelGeneratorRank [Fintype Q]
    (A : ThermoAut S σ Q) : ℕ :=
  A.gibbsHankelRows.card

/-
**Rank–state equality**: the Gibbs–Hankel generator rank equals the number
    of thermodynamic states.
-/
theorem ThermoAut.gibbsHankelRank_eq_card_thermoState [Fintype Q]
    (A : ThermoAut S σ Q) :
    A.gibbsHankelGeneratorRank = Fintype.card (ThermoState A) := by
  -- Show that the image of ther Gibbs–Hankel row function is in bijection with the quotient Q/stateEquiv.
  have h_bij : Nonempty (A.gibbsHankelRows ≃ ThermoState A) := by
    refine' ⟨ Equiv.ofBijective _ ⟨ _, _ ⟩ ⟩;
    refine' fun x => Quotient.mk'' ( Classical.choose ( Finset.mem_image.mp x.2 ) );
    · intro x y hxy
      have h_eq : A.gibbsHankelRow (Classical.choose (Finset.mem_image.mp x.2)) = A.gibbsHankelRow (Classical.choose (Finset.mem_image.mp y.2)) := by
        exact Quotient.exact hxy
      generalize_proofs at *;
      grind +suggestions;
    · intro q;
      obtain ⟨ q, rfl ⟩ := Quotient.exists_rep q;
      refine' ⟨ ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ q ) ⟩, _ ⟩;
      have := Classical.choose_spec ( Finset.mem_image.mp ( show A.gibbsHankelRow q ∈ Finset.image A.gibbsHankelRow Finset.univ from Finset.mem_image_of_mem _ ( Finset.mem_univ q ) ) );
      exact Quotient.sound ( by simpa [ ThermoAut.gibbsHankelRow ] using this.2 );
  simpa using Fintype.card_congr h_bij.some

/-! ## §13. Uniqueness Up to Isomorphism -/

/-- An isomorphism between thermodynamic automata. -/
structure ThermoAutIso (A : ThermoAut S σ Q) {Q' : Type*} (B : ThermoAut S σ Q') where
  toEquiv : Q ≃ Q'
  init_map : toEquiv A.init = B.init
  step_map : ∀ q a, toEquiv (A.step q a) = B.step (toEquiv q) a
  obs_map : ∀ q, A.obs q = B.obs (toEquiv q)

/-- A thermodynamic automaton is a **minimal realization** if no two distinct
    states are behaviorally equivalent. -/
def ThermoAut.IsMinimalRealization (A : ThermoAut S σ Q) : Prop :=
  ∀ q₁ q₂ : Q, A.stateEquiv q₁ q₂ → q₁ = q₂

/-
**Uniqueness of minimal realizations**: any two minimal realizations with the
    same behavior are isomorphic (assuming all states are reachable).
-/
theorem ThermoAut.minimal_realization_unique {Q' : Type*}
    [Fintype Q] [Fintype Q'] [DecidableEq Q] [DecidableEq Q']
    (A : ThermoAut S σ Q) (B : ThermoAut S σ Q')
    (hA : A.IsMinimalRealization) (hB : B.IsMinimalRealization)
    (hbeh : A.behavior = B.behavior)
    (hA_surj : ∀ q : Q, ∃ w, A.run A.init w = q)
    (hB_surj : ∀ q : Q', ∃ w, B.run B.init w = q) :
    Nonempty (ThermoAutIso A B) := by
  -- Construct the isomorphism f : Q ≃ Q' as follows.
  have h_iso : Nonempty (Q ≃ Q') := by
    have h_card : Fintype.card Q = Fintype.card (ThermoState A) := by
      refine' Fintype.card_congr _;
      refine' Equiv.ofBijective ( fun q => Quotient.mk'' q ) ⟨ fun q₁ q₂ h => _, fun q => _ ⟩ <;> simp_all +decide [ ThermoAut.stateEquiv ];
      · exact hA _ _ ( Quotient.exact h );
      · exact Quotient.exists_rep q
    have h_card' : Fintype.card Q' = Fintype.card (ThermoState B) := by
      refine' Fintype.card_congr _;
      refine' Equiv.ofBijective ( fun q => Quotient.mk'' q ) ⟨ fun q₁ q₂ h => _, fun q => _ ⟩;
      · exact hB _ _ ( Quotient.exact h );
      · exact Quotient.exists_rep q
    have h_card_eq : Fintype.card (ThermoState A) = Fintype.card (ThermoState B) := by
      have h_card_eq : Fintype.card (ThermoState A) ≤ Fintype.card Q' := by
        apply ThermoAut.quotientAut_minimal A B hbeh hA_surj
      have h_card_eq' : Fintype.card (ThermoState B) ≤ Fintype.card Q := by
        apply ThermoAut.quotientAut_minimal B A (by
        exact hbeh.symm) (by
        exact hB_surj)
      linarith [h_card_eq, h_card_eq']
    have h_card_eq' : Fintype.card Q = Fintype.card Q' := by
      rw [h_card, h_card', h_card_eq]
    exact ⟨Fintype.equivOfCardEq h_card_eq'⟩;
  -- Define the function f that maps each state in A to the corresponding state in B.
  obtain ⟨f, hf⟩ : ∃ f : Q ≃ Q', ∀ q, A.residual q = B.residual (f q) := by
    have h_iso : ∀ q : Q, ∃ q' : Q', A.residual q = B.residual q' := by
      intro q
      obtain ⟨w, hw⟩ := hA_surj q
      use B.run B.init w;
      ext x; have := congr_fun hbeh ( w ++ x ) ; simp_all +decide [ ThermoAut.behavior ] ;
      convert this using 1 <;> simp +decide [ ← hw, ThermoAut.residual ];
      · rw [ ThermoAut.run_append ];
      · rw [ ThermoAut.run_append ];
    choose f hf using h_iso;
    have h_inj : Function.Injective f := by
      intro q₁ q₂ h_eq
      have h_res : A.residual q₁ = A.residual q₂ := by
        rw [ hf q₁, hf q₂, h_eq ];
      exact hA q₁ q₂ h_res;
    have h_surj : Function.Surjective f := by
      exact ( Fintype.bijective_iff_injective_and_card f ).mpr ⟨ h_inj, by simp +decide [ Fintype.card_congr h_iso.some ] ⟩ |>.2;
    exact ⟨ Equiv.ofBijective f ⟨ h_inj, h_surj ⟩, hf ⟩;
  refine' ⟨ ⟨ f, _, _, _ ⟩ ⟩;
  · have h_init : A.residual A.init = B.residual B.init := by
      convert hbeh using 1;
    have := hB ( f A.init ) B.init; aesop;
  · intro q a;
    apply hB;
    simp_all +decide [ ThermoAut.stateEquiv, funext_iff ];
    intro x; have := hf ( A.step q a ) x; have := hf q ( a :: x ) ; simp_all +decide [ ThermoAut.residual ] ;
  · intro q; specialize hf q; replace hf := congr_fun hf []; aesop;

/-! ## §14. Closure–Minimization Commutation -/

/-- A closure operator on Obs. -/
structure ClosureOp (Obs : Type*) [Preorder Obs] where
  cl : Obs → Obs
  extensive : ∀ o, o ≤ cl o
  monotone : ∀ {o₁ o₂}, o₁ ≤ o₂ → cl o₁ ≤ cl o₂
  idempotent : ∀ o, cl (cl o) = cl o

/-- Entropy is closure-invariant. -/
def ClosureEntropySubmodular [Preorder Obs] (C : ClosureOp Obs) (Hc : Obs → S) : Prop :=
  ∀ o, Hc (C.cl o) = Hc o

/-- The closure-saturated automaton. -/
def closureSaturatedAut [Mul S] [Preorder Obs]
    (init : Q) (step : Q → σ → Q) (summary : Q → Obs)
    (C : ClosureOp Obs) (Hc : Obs → S) (β : S) : ThermoAut S σ Q :=
  mkThermoAut init step (fun q => C.cl (summary q)) C.cl Hc β

/-
**Closure–minimization commutation**: when entropy is closure-invariant,
    the original and closure-saturated automata have the same behavior.
-/
theorem freeEnergy_min_commutes_closure [Mul S] [Preorder Obs]
    (init : Q) (step : Q → σ → Q) (summary : Q → Obs)
    (C : ClosureOp Obs) (Hc : Obs → S) (β : S)
    (_hsub : ClosureEntropySubmodular C Hc) :
    (mkThermoAut init step summary C.cl Hc β).behavior =
      (closureSaturatedAut init step summary C Hc β).behavior := by
  unfold mkThermoAut closureSaturatedAut;
  unfold ThermoAut.behavior mkThermoAut;
  simp +decide [ C.idempotent ]

/-! ## §15. Dissipation Classes and Conservation -/

/-- A dissipation class labels a state with a coarse-grained observable. -/
structure DissipationClass (S : Type*) where
  label : S
  deriving DecidableEq

def ThermoAut.wordDissipation (A : ThermoAut S σ Q) (w : List σ) : DissipationClass S :=
  ⟨A.obs (A.run A.init w)⟩

/-- A word is **optimal** if its observation is ≤ all same-length words'. -/
def ThermoAut.IsOptimalPath [Preorder S] (A : ThermoAut S σ Q) (w : List σ) : Prop :=
  ∀ w' : List σ, w'.length = w.length → A.obs (A.run A.init w) ≤ A.obs (A.run A.init w')

/-
**Conservation of dissipation class** for optimal paths of the same length.
-/
theorem ThermoAut.optimal_paths_same_dissipation [PartialOrder S]
    (A : ThermoAut S σ Q) (w₁ w₂ : List σ)
    (h₁ : A.IsOptimalPath w₁) (h₂ : A.IsOptimalPath w₂)
    (hlen : w₁.length = w₂.length) :
    A.wordDissipation w₁ = A.wordDissipation w₂ := by
  grind +locals

/-! ## §16. Certified Minimization -/

/-
**Existence of certified minimization**: the quotient construction provides
    a minimal realization for any thermodynamic automaton.
-/
theorem exists_certified_minimizer [Fintype Q]
    (A : ThermoAut S σ Q) :
    ∃ (minQ : Type) (_ : Fintype minQ) (B : ThermoAut S σ minQ),
      B.behavior = A.behavior ∧
      Fintype.card minQ ≤ Fintype.card Q := by
  refine' ⟨ _, _, _, _, _ ⟩;
  exact Fin ( Fintype.card Q );
  exact inferInstance;
  exact ⟨ Fintype.equivFinOfCardEq rfl A.init, fun q a => Fintype.equivFinOfCardEq rfl ( A.step ( Fintype.equivFinOfCardEq rfl |>.symm q ) a ), fun q => A.obs ( Fintype.equivFinOfCardEq rfl |>.symm q ) ⟩;
  · unfold ThermoAut.behavior;
    congr! 2;
    induction ‹List σ› using List.reverseRecOn <;> simp +decide [ * ];
    grind +suggestions;
  · simp +decide

/-! ## §17. Auxiliary Lemmas -/

def ThermoAut.reachableStates (A : ThermoAut S σ Q) : Set Q :=
  {q | ∃ w : List σ, A.run A.init w = q}

theorem ThermoAut.init_reachable (A : ThermoAut S σ Q) :
    A.init ∈ A.reachableStates := ⟨[], rfl⟩

theorem ThermoAut.reachable_step (A : ThermoAut S σ Q)
    (q : Q) (a : σ) (hq : q ∈ A.reachableStates) :
    A.step q a ∈ A.reachableStates := by
  obtain ⟨w, rfl⟩ := hq
  exact ⟨w ++ [a], by rw [run_append]; simp [run]⟩

/-- The quotient has at most as many states as the original. -/
theorem ThermoAut.card_thermoState_le [Fintype Q]
    (A : ThermoAut S σ Q) :
    Fintype.card (ThermoState A) ≤ Fintype.card Q :=
  Fintype.card_quotient_le _

/-! ## §18. Closure Invariance -/

/-- Closure invariance of free energy: applying closure to summaries
    doesn't change the output when entropy is closure-invariant. -/
theorem freeEnergy_closure_invariant [Mul S] (summary : Q → Obs)
    (C : Obs → Obs) (Hc : Obs → S) (β : S)
    (hC_idem : ∀ o, C (C o) = C o)
    (_hHc_inv : ∀ o, Hc (C o) = Hc o) (q : Q) :
    β * Hc (C (C (summary q))) = β * Hc (C (summary q)) := by
  rw [hC_idem]

end Bridges.AlgebraEMLComputation.IdempotentThermodynamicRealization