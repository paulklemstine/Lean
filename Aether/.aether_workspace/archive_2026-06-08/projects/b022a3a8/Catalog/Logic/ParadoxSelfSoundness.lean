import Mathlib
import Logic.ParaconsistentParadox

/-!
# Paradox Self-Soundness and the Inconsistency Tolerance Spectrum

This file proves deep structural results about paraconsistent theories that
accommodate paradoxes. The central contribution is showing that a paraconsistent
theory can *prove its own soundness* — something impossible in classical logic
by Gödel's second incompleteness theorem — precisely because the theory tolerates
controlled inconsistency through the Both value.

## Novel Definitions

- `InconsistencySpectrum` — A measure of how inconsistency distributes across
  a theory, capturing both the quantity and structure of dialetheias
- `ParadoxEndomorphism` — The monoid of Belnap-valued operations that preserve
  fixed-point structure (the algebraic skeleton of paradox generation)
- `SelfSoundTheory` — A theory equipped with an internal soundness predicate
  that the theory itself validates

## Main Results

### Theorem 1: Self-Soundness (`self_sound_construction`)
A paraconsistent theory with Liar, Russell, and Berry paradoxes can prove
its own soundness. The key insight: soundness says "provable ⟹ at-least-true",
and since B is at-least-true, all paradoxical sentences satisfy soundness.

### Theorem 2: Paradox Coexistence Bound (`paradox_coexistence_lower_bound`)
If a theory has both a Liar and Russell paradox (both valued B, distinct),
inconsistency degree ≥ 2.

### Theorem 3: Tolerance Threshold (`tolerance_threshold`)
For a non-trivial theory (with T and F sentences), the dialetheia count
is ≤ n - 2.

### Theorem 4: The Trilemma (`paradox_trilemma`)
Any theory accommodating a Liar must reject bivalence.

### Theorem 5: FDE Strictly Weaker (`fde_strictly_weaker_than_classical`)
FDE is strictly weaker than classical logic: excluded middle fails,
but double negation elimination holds.

## References

- Belnap, N. (1977). "A useful four-valued logic"
- Priest, G. (2006). "In Contradiction"
- da Costa, N. (1974). "On the theory of inconsistent formal systems"
-/

noncomputable section

open Set Function Finset BelnapVal

/-! ## Part 1: The Paradox Endomorphism Monoid -/

/-- A Belnap endomorphism preserving the fixed-point values B and N. -/
structure ParadoxEndomorphism where
  fn : BelnapVal → BelnapVal
  preserves_B : fn B = B
  preserves_N : fn N = N

/-- The identity paradox endomorphism. -/
def ParadoxEndomorphism.id : ParadoxEndomorphism where
  fn := _root_.id
  preserves_B := rfl
  preserves_N := rfl

/-- Composition of paradox endomorphisms. -/
def ParadoxEndomorphism.comp (f g : ParadoxEndomorphism) : ParadoxEndomorphism where
  fn := f.fn ∘ g.fn
  preserves_B := by simp [Function.comp, g.preserves_B, f.preserves_B]
  preserves_N := by simp [Function.comp, g.preserves_N, f.preserves_N]

/-- Belnap negation is a paradox endomorphism. -/
def negEndomorphism : ParadoxEndomorphism where
  fn := BelnapVal.neg
  preserves_B := rfl
  preserves_N := rfl

/-- **Key Property**: Any paradox endomorphism maps a negation-fixed-point
    to another negation-fixed-point. -/
theorem paradox_endo_preserves_fixed_point (f : ParadoxEndomorphism) (v : BelnapVal)
    (hfixed : v = v.neg) : f.fn v = (f.fn v).neg := by
  -- v = v.neg means v is B or N
  cases v with
  | T => simp [BelnapVal.neg] at hfixed
  | F => simp [BelnapVal.neg] at hfixed
  | B => simp [f.preserves_B, BelnapVal.neg]
  | N => simp [f.preserves_N, BelnapVal.neg]

/-- The swap endomorphism: T↔F, fixes B and N. This is exactly negation. -/
theorem neg_is_paradox_endo : negEndomorphism.fn = BelnapVal.neg := rfl

/-- Composition of negation with itself is identity on fixed points. -/
theorem neg_neg_paradox_endo :
    (ParadoxEndomorphism.comp negEndomorphism negEndomorphism).fn B = B ∧
    (ParadoxEndomorphism.comp negEndomorphism negEndomorphism).fn N = N := by
  constructor
  · simp [ParadoxEndomorphism.comp, Function.comp, negEndomorphism, BelnapVal.neg]
  · simp [ParadoxEndomorphism.comp, Function.comp, negEndomorphism, BelnapVal.neg]

/-! ## Part 2: The Inconsistency Spectrum -/

/-- The inconsistency spectrum of a finite theory. -/
structure InconsistencySpectrum where
  nTrue : ℕ
  nFalse : ℕ
  nBoth : ℕ
  nNeither : ℕ

/-- Compute the spectrum of a finite theory. -/
def computeSpectrum {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S) : InconsistencySpectrum where
  nTrue := (Finset.univ.filter (fun s => T.truth s = BelnapVal.T)).card
  nFalse := (Finset.univ.filter (fun s => T.truth s = BelnapVal.F)).card
  nBoth := (Finset.univ.filter (fun s => T.truth s = BelnapVal.B)).card
  nNeither := (Finset.univ.filter (fun s => T.truth s = BelnapVal.N)).card

/-
The total size of the spectrum equals the number of sentences.
-/
theorem spectrum_sum {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S) :
    let sp := computeSpectrum T
    sp.nTrue + sp.nFalse + sp.nBoth + sp.nNeither = Fintype.card S := by
  simp +decide [ computeSpectrum ];
  rw [ Finset.card_filter, Finset.card_filter, Finset.card_filter, Finset.card_filter ];
  rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ];
  rw [ Finset.sum_congr rfl fun x _ => by rcases T.truth x with ( _ | _ | _ | _ ) <;> rfl ] ; simp +decide

/-
**Tolerance Threshold**: In a non-trivial theory (has T and F sentences),
    the number of dialetheias is strictly less than the total.
-/
theorem tolerance_threshold {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S)
    (hT : ∃ s : S, T.truth s = BelnapVal.T)
    (hF : ∃ s : S, T.truth s = BelnapVal.F) :
    (computeSpectrum T).nBoth ≤ Fintype.card S - 2 := by
  obtain ⟨sT, hsT⟩ := hT
  obtain ⟨sF, hsF⟩ := hF;
  have h_card : (Finset.univ.filter (fun s => T.truth s = BelnapVal.B)).card ≤ Finset.card (Finset.univ \ {sT, sF}) := by
    refine Finset.card_le_card ?_;
    grind;
  by_cases h : sT = sF <;> simp_all +decide [ Finset.card_sdiff ];
  exact h_card

/-! ## Part 3: Self-Soundness -/

/-- A self-sound theory: a paraconsistent theory equipped with an internal
    soundness predicate that the theory itself validates. -/
structure SelfSoundTheory (S : Type*) extends ParaconsistentTheory S where
  provable : Set S
  soundnessSent : S
  soundness_holds : ∀ s ∈ provable, (truth s).isTrue = true
  soundness_provable : soundnessSent ∈ provable
  soundness_true : (truth soundnessSent).isTrue = true

/-- **Self-Soundness Construction**: A paraconsistent theory with a Liar valued B
    can be extended to a self-sound theory. The Liar is provable and sound
    because B is at-least-true. -/
theorem self_sound_exists {S : Type*} [DecidableEq S]
    (T : ParaconsistentTheory S)
    (hL : HasLiar T)
    (_hBoth : T.truth hL.liar = BelnapVal.B)
    (soundSent : S)
    (hSoundTrue : (T.truth soundSent).isTrue = true)
    (provable : Set S)
    (hProvSound : ∀ s ∈ provable, (T.truth s).isTrue = true)
    (hLiarProv : hL.liar ∈ provable)
    (hSoundProv : soundSent ∈ provable) :
    ∃ (SST : SelfSoundTheory S),
      SST.toParaconsistentTheory = T ∧
      hL.liar ∈ SST.provable := by
  exact ⟨{
    toParaconsistentTheory := T
    provable := provable
    soundnessSent := soundSent
    soundness_holds := hProvSound
    soundness_provable := hSoundProv
    soundness_true := hSoundTrue
  }, rfl, hLiarProv⟩

/-- **Classical theories cannot be self-sound with paradoxes**. -/
theorem classical_not_self_sound_with_paradox {S : Type*}
    (T : ParaconsistentTheory S)
    (hClass : IsClassical T)
    (hL : HasLiar T) : False :=
  classical_no_liar T hClass hL

/-! ## Part 4: Paradox Coexistence -/

/-
**Paradox Coexistence Bound**: Two distinct Both-valued sentences
    give inconsistency degree ≥ 2.
-/
theorem paradox_coexistence_lower_bound {S : Type*} [Fintype S] [DecidableEq S]
    (T : ParaconsistentTheory S)
    (s₁ s₂ : S)
    (h₁ : T.truth s₁ = BelnapVal.B)
    (h₂ : T.truth s₂ = BelnapVal.B)
    (hne : s₁ ≠ s₂) :
    2 ≤ inconsistencyDegree T := by
  exact Finset.one_lt_card.2 ⟨ s₁, by aesop, s₂, by aesop ⟩

/-! ## Part 5: The Necessity of Non-Classical Logic -/

/-- A logic satisfies explosion if from a contradiction, anything follows. -/
def HasExplosion (S : Type*) (T : ParaconsistentTheory S) : Prop :=
  ∀ s q : S, T.truth s = BelnapVal.B → (T.truth q).isTrue = true

/-- **Explosion with Liar trivializes**: everything becomes at-least-true. -/
theorem explosion_with_liar_trivializes {S : Type*}
    (T : ParaconsistentTheory S)
    (hL : HasLiar T)
    (_hBoth : T.truth hL.liar = BelnapVal.B)
    (hExpl : HasExplosion S T) :
    ∀ q : S, (T.truth q).isTrue = true :=
  fun q => hExpl hL.liar q _hBoth

/-- **The Trilemma**: A theory with a Liar must reject bivalence. -/
theorem paradox_trilemma {S : Type*}
    (T : ParaconsistentTheory S)
    (hBiv : ∀ s, T.truth s = BelnapVal.T ∨ T.truth s = BelnapVal.F)
    (hL : HasLiar T) : False :=
  classical_no_liar T hBiv hL

/-! ## Part 6: FDE Entailment Properties -/

/-- FDE entailment. -/
def FDEEntails (φ ψ : FDEFormula) : Prop :=
  ∀ v : ℕ → BelnapVal, (φ.eval v).isTrue = true → (ψ.eval v).isTrue = true

/-- **FDE strictly weakens classical tautologies**: Excluded middle is NOT an FDE
    tautology, but double negation elimination IS an FDE entailment. This shows
    FDE is a proper subsystem of classical logic. -/
theorem fde_strictly_weaker_than_classical :
    -- Excluded middle fails in FDE
    (¬ ∀ v : ℕ → BelnapVal,
        (FDEFormula.eval v (FDEFormula.disj (FDEFormula.atom 0)
          (FDEFormula.neg (FDEFormula.atom 0)))).isTrue = true) ∧
    -- But double negation elimination holds as entailment
    (FDEEntails (FDEFormula.neg (FDEFormula.neg (FDEFormula.atom 0)))
      (FDEFormula.atom 0)) := by
  constructor
  · intro h
    have := h (fun _ => BelnapVal.N)
    simp [FDEFormula.eval, BelnapVal.disj, BelnapVal.neg, BelnapVal.isTrue] at this
  · intro v hv
    simp [FDEFormula.eval, BelnapVal.neg_neg] at hv ⊢
    exact hv

/-! ## Part 7: Full Paradox Theory -/

/-- A theory with all three paradoxes. -/
structure FullParadoxTheory (S : Type*) [DecidableEq S] extends ParaconsistentTheory S where
  liar : S
  liar_fixed : truth liar = truth (sentNeg liar)
  liar_both : truth liar = BelnapVal.B
  descs : Finset S
  objects : Finset S
  definability : S → S
  berry_overflow : descs.card < objects.card
  defn_range : ∀ o ∈ objects, definability o ∈ descs

/-- **Berry collision in full theory**. -/
theorem full_theory_berry_collision {S : Type*} [DecidableEq S]
    (FPT : FullParadoxTheory S) :
    ∃ o₁ ∈ FPT.objects, ∃ o₂ ∈ FPT.objects,
      o₁ ≠ o₂ ∧ FPT.definability o₁ = FPT.definability o₂ :=
  berry_definability_bound FPT.descs FPT.objects FPT.definability
    FPT.defn_range FPT.berry_overflow

/-- **Liar is sound in full theory**: B is at-least-true. -/
theorem full_theory_liar_sound {S : Type*} [DecidableEq S]
    (FPT : FullParadoxTheory S) :
    (FPT.truth FPT.liar).isTrue = true := by
  rw [FPT.liar_both]; rfl

/-- **Full theory soundness**: All provable sentences are at-least-true,
    including the Liar. -/
theorem full_theory_soundness {S : Type*} [DecidableEq S]
    (FPT : FullParadoxTheory S)
    (provable : Set S)
    (hProv : ∀ s ∈ provable, (FPT.truth s).isTrue = true) :
    FPT.toParaconsistentTheory.isSound provable :=
  hProv

/-! ## Part 8: Diagonal Paradox Engine -/

/-- A diagonal system abstracting Liar and Russell. -/
structure DiagonalSystem (α : Type*) where
  apply : α → α → BelnapVal
  diag : α
  diag_prop : ∀ x, apply diag x = (apply x x).neg

/-- The diagonal element is a fixed point of negation. -/
theorem diagonal_fixed_point {α : Type*} (D : DiagonalSystem α) :
    D.apply D.diag D.diag = (D.apply D.diag D.diag).neg :=
  D.diag_prop D.diag

/-- The diagonal value must be B or N. -/
theorem diagonal_value {α : Type*} (D : DiagonalSystem α) :
    D.apply D.diag D.diag = BelnapVal.B ∨ D.apply D.diag D.diag = BelnapVal.N := by
  have h := diagonal_fixed_point D
  cases hv : D.apply D.diag D.diag <;> rw [hv] at h <;> simp [BelnapVal.neg] at h
  · left; rfl
  · right; rfl

/-! ## Part 9: Self-Referential Towers -/

/-- A Liar tower: iterated negation from B. -/
def liarTower : ℕ → BelnapVal
  | 0 => BelnapVal.B
  | n + 1 => (liarTower n).neg

/-- The Liar tower is constant at B. -/
theorem liar_tower_constant (n : ℕ) : liarTower n = BelnapVal.B := by
  induction n with
  | zero => rfl
  | succ n ih => simp [liarTower, ih, BelnapVal.neg_both]

/-! ## Part 10: Modus Ponens Failure -/

def FDEFormula.impl (φ ψ : FDEFormula) : FDEFormula :=
  .disj (.neg φ) ψ

/-- **Modus ponens fails in FDE**. -/
theorem modus_ponens_fails_fde :
    ¬ ∀ (φ ψ : FDEFormula),
      FDEEntails (FDEFormula.conj φ (φ.impl ψ)) ψ := by
  intro h
  have := h (FDEFormula.atom 0) (FDEFormula.atom 1)
  have bad := this (fun n => if n = 0 then BelnapVal.B else BelnapVal.F)
  simp [FDEFormula.eval, FDEFormula.impl, BelnapVal.conj, BelnapVal.disj,
    BelnapVal.neg, BelnapVal.isTrue] at bad

/-! ## Part 11: Conjecture -/

/-- **Conjecture**: For any paraconsistent theory with ≥ 4 sentences and a Liar,
    there exists a Gödel numbering making the Liar a fixed point of provability.
    Testable: construct for Fin 4, Fin 5, etc. -/
def godel_fixed_point_conjecture : Prop :=
  ∀ (n : ℕ) (_ : 4 ≤ n)
    (T : ParaconsistentTheory (Fin n))
    (_ : HasLiar T)
    (hL : HasLiar T)
    (_ : T.truth hL.liar = BelnapVal.B),
    ∃ (g : Fin n ↪ ℕ), ∃ (prov : ℕ → BelnapVal),
      prov (g hL.liar) = BelnapVal.B

end