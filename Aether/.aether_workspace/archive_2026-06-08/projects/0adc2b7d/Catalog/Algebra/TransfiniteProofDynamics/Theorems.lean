import Mathlib

/-!
# Transfinite Proof Dynamics: Ordinal-Valued Energy Framework

This file extends the `ProofRefinementSystem` framework from ℕ-valued to
**ordinal-valued** energy functions, enabling analysis of proof systems with
transfinite normalization chains.

## Catalog References

Extends `Pythagorean/ProofDynamics/Defs.lean` and `Pythagorean/ProofDynamics/Theorems.lean`.
-/

universe u v w

/-! ## Core Definitions -/

/-- An **Ordinal Proof Refinement System** generalizes ProofRefinementSystem to
    ordinal-valued energy functions. -/
structure OrdinalPRS (α : Type u) (σ : Type v) where
  step : α → α → Prop
  sem : α → σ
  energy : α → Ordinal
  sem_invariant : ∀ {p q}, step p q → sem p = sem q
  energy_strict : ∀ {p q}, step p q → energy q < energy p

/-- Normal form for an ordinal PRS. -/
def OPRS_NormalForm {α : Type u} {σ : Type v} (S : OrdinalPRS α σ) (p : α) : Prop :=
  ¬∃ q, S.step p q

/-- The energy spectrum of a state. -/
def energySpectrum {α : Type u} {σ : Type v}
    (S : OrdinalPRS α σ) (p : α) : Set Ordinal :=
  { o | ∃ q, Relation.ReflTransGen S.step p q ∧ S.energy q = o }

/-- Ordinal rank: supremum of all state energies. -/
noncomputable def ordinalRank {α : Type u} {σ : Type v}
    (S : OrdinalPRS α σ) : Ordinal :=
  ⨆ (p : α), S.energy p

/-- A stratified PRS with ordinal-indexed levels. -/
structure StratifiedPRS (α : Type u) (σ : Type v) extends OrdinalPRS α σ where
  level : α → Ordinal
  level_le_energy : ∀ p, level p ≤ energy p
  level_nonincreasing : ∀ {p q}, step p q → level q ≤ level p

/-- Step chain of length n. -/
inductive OStepChain {α : Type u} (r : α → α → Prop) : α → α → ℕ → Prop where
  | refl (p : α) : OStepChain r p p 0
  | cons {p m q : α} {n : ℕ} : r p m → OStepChain r m q n → OStepChain r p q (n + 1)

/-- Product of two ordinal PRS using Hessenberg (natural) sum. -/
noncomputable def OrdinalPRS.prod {α₁ : Type u} {α₂ : Type v}
    {σ₁ : Type w} {σ₂ : Type*}
    (S₁ : OrdinalPRS α₁ σ₁) (S₂ : OrdinalPRS α₂ σ₂) :
    OrdinalPRS (α₁ × α₂) (σ₁ × σ₂) where
  step := fun p q =>
    (S₁.step p.1 q.1 ∧ p.2 = q.2) ∨ (p.1 = q.1 ∧ S₂.step p.2 q.2)
  sem := fun p => (S₁.sem p.1, S₂.sem p.2)
  energy := fun p => (S₁.energy p.1).nadd (S₂.energy p.2)
  sem_invariant := by
    intro ⟨a1, a2⟩ ⟨b1, b2⟩ h
    rcases h with ⟨h1, rfl⟩ | ⟨rfl, h2⟩
    · exact Prod.ext (S₁.sem_invariant h1) rfl
    · exact Prod.ext rfl (S₂.sem_invariant h2)
  energy_strict := by
    intro ⟨a1, a2⟩ ⟨b1, b2⟩ h
    rcases h with ⟨h1, rfl⟩ | ⟨rfl, h2⟩
    · exact Ordinal.nadd_lt_nadd_right (S₁.energy_strict h1) _
    · exact Ordinal.nadd_lt_nadd_left (S₂.energy_strict h2) _

/-- A convergent ordinal PRS: terminating + locally confluent. -/
structure ConvergentOPRS (α : Type u) (σ : Type v) extends OrdinalPRS α σ where
  locally_confluent : ∀ a b c, step a b → step a c →
    ∃ d, Relation.ReflTransGen step b d ∧ Relation.ReflTransGen step c d

variable {α : Type u} {σ : Type v}

/-! ## Theorem 1: Transfinite Termination -/

/-
The inverse step relation of any OrdinalPRS is well-founded.
-/
theorem oprs_wellFounded (S : OrdinalPRS α σ) :
    WellFounded (Function.swap S.step) := by
  rw [ WellFounded.wellFounded_iff_has_min ];
  intro s hs;
  -- By the well-foundedness of � Ord�inal.lt, there exists a minimal element in the energy spectrum of s.
  obtain ⟨m, hm⟩ : ∃ m ∈ Set.image S.energy s, ∀ n ∈ Set.image S.energy s, ¬(n < m) := by
    exact ⟨ InfSet.sInf ( S.energy '' s ), csInf_mem ( Set.Nonempty.image _ hs ), fun n hn => not_lt_of_ge ( csInf_le' hn ) ⟩;
  obtain ⟨ ⟨ x, hx, rfl ⟩, hm ⟩ := hm; exact ⟨ x, hx, fun y hy hxy => hm _ ( Set.mem_image_of_mem _ hy ) ( S.energy_strict hxy ) ⟩ ;

/-! ## Theorem 2: Semantic Invariance -/

/-
Semantic invariance lifts to multi-step derivations.
-/
theorem oprs_sem_invariant_rtc (S : OrdinalPRS α σ)
    {p q : α} (h : Relation.ReflTransGen S.step p q) :
    S.sem p = S.sem q := by
  induction h <;> [ rfl; exact S.sem_invariant ‹_› ▸ ‹_› ]

/-
Semantic invariance for transitive closure.
-/
theorem oprs_sem_invariant_tc (S : OrdinalPRS α σ)
    {p q : α} (h : Relation.TransGen S.step p q) :
    S.sem p = S.sem q := by
  -- Convert TransGen to ReflTransGen then use oprs_sem_invariant_rtc.
  apply oprs_sem_invariant_rtc S (by
  exact h.to_reflTransGen)

/-! ## Theorem 3: No Cycles and Energy Descent -/

/-
The transitive closure strictly decreases ordinal energy.
-/
theorem oprs_transGen_energy_strict (S : OrdinalPRS α σ)
    {p q : α} (h : Relation.TransGen S.step p q) :
    S.energy q < S.energy p := by
  induction h;
  · exact S.energy_strict ‹_›;
  · exact lt_trans ( S.energy_strict ‹_› ) ‹_›

/-
No nontrivial cycles exist in an ordinal PRS.
-/
theorem oprs_no_cycles (S : OrdinalPRS α σ) (p : α) :
    ¬Relation.TransGen S.step p p := by
  intro h;
  exact lt_irrefl _ ( oprs_transGen_energy_strict S h )

/-! ## Theorem 4: Existence of Normal Forms -/

/-
Reflexive-transitive closure from a normal form is trivial.
-/
theorem oprs_rtc_from_nf {r : α → α → Prop} {a b : α}
    (hn : ¬∃ q, r a q) (h : Relation.ReflTransGen r a b) : a = b := by
  grind +qlia

/-
Every state in an ordinal PRS reaches a normal form.
-/
theorem oprs_exists_normalForm (S : OrdinalPRS α σ) (p : α) :
    ∃ q, Relation.ReflTransGen S.step p q ∧ OPRS_NormalForm S q := by
  have h_wf : WellFounded (Function.swap S.step) := by
    -- Apply the well-foundedness of the inverse step relation to conclude the proof.
    apply oprs_wellFounded;
  have := h_wf.has_min { q | Relation.ReflTransGen S.step p q } ⟨ p, Relation.ReflTransGen.refl ⟩;
  exact ⟨ this.choose, this.choose_spec.1, fun ⟨ q, hq ⟩ => this.choose_spec.2 q ( this.choose_spec.1.trans ( Relation.ReflTransGen.single hq ) ) hq ⟩

/-! ## Theorem 5: Newman's Lemma for Ordinal PRS -/

/-
Newman's Lemma: WF + local confluence ⇒ confluence.
-/
theorem oprs_newman_lemma (S : OrdinalPRS α σ)
    (hLC : ∀ a b c, S.step a b → S.step a c →
      ∃ d, Relation.ReflTransGen S.step b d ∧ Relation.ReflTransGen S.step c d) :
    ∀ a b c, Relation.ReflTransGen S.step a b → Relation.ReflTransGen S.step a c →
      ∃ d, Relation.ReflTransGen S.step b d ∧ Relation.ReflTransGen S.step c d := by
  intro a b c;
  induction' ha : S.energy a using Ordinal.induction with o ih generalizing a b c;
  intro hab hbc
  by_cases h : a = b ∨ a = c;
  · grind +splitImp;
  · -- Since $a \neq b$ and � $�a \neq c$, there exist $a_1$ and $a_2$ such that $a \to a_1 \to^* b$ � and� $a \to a_2 \to^* c$.
    obtain ⟨a1, ha1⟩ : ∃ a1, S.step a a1 ∧ Relation.ReflTransGen S.step a1 b := by
      have := hab.cases_head; aesop;
    obtain ⟨a2, ha2⟩ : ∃ a2, S.step a a2 ∧ Relation.ReflTransGen S.step a2 c := by
      have := hbc.cases_head; aesop;
    obtain ⟨ d, hd1, hd2 ⟩ := hLC a a1 a2 ha1.1 ha2.1;
    -- By the induction hypothesis, there exists $e$ � such� that $b \to^* e$ and $d \to^* e$.
    obtain ⟨e, he1, he2⟩ : ∃ e, Relation.ReflTransGen S.step b e ∧ Relation.ReflTransGen S.step d e := by
      exact ih _ ( by simpa [ ha ] using S.energy_strict ha1.1 ) _ _ _ rfl ha1.2 hd1;
    -- By the induction hypothesis, there exists $f$ such that $c \to^* f$ and $e \to^* f$.
    obtain ⟨ f, hf1, hf2 ⟩ := ih (S.energy a2) (by
    grind +suggestions) a2 c e (by
    rfl) ha2.right (hd2.trans he2);
    exact ⟨ f, he1.trans hf2, hf1 ⟩

/-! ## Theorem 6: Energy Spectrum Properties -/

/-
The energy of the starting state is in the energy spectrum.
-/
theorem energy_mem_spectrum (S : OrdinalPRS α σ) (p : α) :
    S.energy p ∈ energySpectrum S p := by
  exact ⟨ p, by rfl, rfl ⟩

/-
Every ordinal in the energy spectrum is at most the energy of the starting state.
-/
theorem spectrum_le_energy (S : OrdinalPRS α σ) (p : α) (o : Ordinal)
    (ho : o ∈ energySpectrum S p) : o ≤ S.energy p := by
  obtain ⟨ q, hq, rfl ⟩ := ho;
  induction hq <;> [ rfl; exact le_trans ( S.energy_strict ‹_› |> le_of_lt ) ‹_› ]

/-! ## Theorem 7: Product Well-Foundedness -/

/-
The product of two ordinal PRS systems is well-founded.
-/
theorem prod_wellFounded {α₁ : Type u} {α₂ : Type v} {σ₁ : Type w} {σ₂ : Type*}
    (S₁ : OrdinalPRS α₁ σ₁) (S₂ : OrdinalPRS α₂ σ₂) :
    WellFounded (Function.swap (S₁.prod S₂).step) := by
  convert oprs_wellFounded ( OrdinalPRS.prod S₁ S₂ ) using 1

/-! ## Theorem 8: Convergent PRS Unique Normal Forms -/

/-
In a convergent ordinal PRS, normal forms are unique.
-/
theorem convergent_unique_nf (S : ConvergentOPRS α σ)
    {a n₁ n₂ : α}
    (h1 : Relation.ReflTransGen S.step a n₁)
    (h2 : Relation.ReflTransGen S.step a n₂)
    (hn1 : OPRS_NormalForm S.toOrdinalPRS n₁)
    (hn2 : OPRS_NormalForm S.toOrdinalPRS n₂) :
    n₁ = n₂ := by
  -- By Newman's Lemma, since S is well-founded and locally confluent, it is also confluent.
  have h_confluent : ∀ a b c, Relation.ReflTransGen S.step a b → Relation.ReflTransGen S.step a c → ∃ d, Relation.ReflTransGen S.step b d ∧ Relation.ReflTransGen S.step c d := by
    exact oprs_newman_lemma _ S.locally_confluent;
  -- Since $n₁$ and $n₂ �$� are both normal forms, they must be equal.
  have h_eq : n₁ = n₂ := by
    have h_nf : ∀ p, OPRS_NormalForm S.toOrdinalPRS p → ∀ q, Relation.ReflTransGen S.step p q → p = q := by
      intros p hp q hq;
      apply oprs_rtc_from_nf hp hq
    grind;
  exact h_eq

/-! ## Theorem 9: Stratified Level Descent -/

/-
In a stratified PRS, the level is non-increasing along rtc.
-/
theorem stratified_level_rtc (S : StratifiedPRS α σ)
    {p q : α} (h : Relation.ReflTransGen S.step p q) :
    S.level q ≤ S.level p := by
  contrapose! h;
  intro hq; induction hq;
  · exact lt_irrefl _ h;
  · exact h.not_ge ( le_trans ( S.level_nonincreasing ‹_› ) ( le_of_not_gt ‹_› ) )

/-! ## Theorem 10: Energy Gap Bounds -/

/-
Any derivation chain of length n requires energy gap of at least n.
-/
theorem energy_gap_lower_bound (S : OrdinalPRS α σ)
    {p q : α} {n : ℕ}
    (h : OStepChain S.step p q n) :
    (n : Ordinal) ≤ S.energy p := by
  induction' n with n ih generalizing p q;
  · simp +decide;
  · cases h;
    rename_i m hm₁ hm₂;
    have := S.energy_strict hm₁;
    exact le_trans ( by rw [ Nat.cast_succ ] ; exact Order.succ_le_of_lt ( lt_of_le_of_lt ( ih hm₂ ) this ) ) le_rfl

/-! ## Energy Monotonicity -/

/-
If p reduces to q via rtc, then q has at most the energy of p.
-/
theorem oprs_energy_nonincreasing (S : OrdinalPRS α σ)
    {p q : α} (h : Relation.ReflTransGen S.step p q) :
    S.energy q ≤ S.energy p := by
  induction h;
  · rfl;
  · exact le_trans ( le_of_lt ( S.energy_strict ‹_› ) ) ‹_›

/-! ## Conjecture: Finite Descent Bound -/

/-
If the energy of p is a natural number k, then every derivation chain
    from p has length at most k.
-/
theorem finite_energy_chain_bound (S : OrdinalPRS α σ)
    {p q : α} {n k : ℕ}
    (hen : S.energy p = (k : Ordinal))
    (h : OStepChain S.step p q n) :
    n ≤ k := by
  -- We start by applying the theorem energy_gap_lower_bound to reach the conclusion that `(n : Ordinal) ≤ S.energy p`.
  -- Then we use the assumption `hen` to equate `S.energy p` with `↑k`, and finally convert from `Ordinal` to `ℕ`.
  have h_ordinal : (n : Ordinal) ≤ S.energy p := by
    exact energy_gap_lower_bound S h
  have h_eq : S.energy p = ↑k := by
    exact hen
  have h_final : n ≤ k := by
    simpa [h_eq] using h_ordinal
  exact h_final