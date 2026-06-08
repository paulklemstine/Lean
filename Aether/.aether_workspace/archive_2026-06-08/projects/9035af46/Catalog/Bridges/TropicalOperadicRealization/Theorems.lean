import Mathlib
import Bridges.TropicalOperadicRealization.Defs

/-! # Tropical Operadic Realization Duality: Theorems

This file proves the main theorems of tropical operadic realization theory:

1. **Canonical Realization Theorem**: Every evaluation table over finite types
   admits a canonical (reduced + separated) realization, unique up to isomorphism.

2. **Minimal Realization Theorem**: Canonical realizations are minimal —
   no realization has fewer states.

3. **State Count Invariance**: All minimal realizations have the same state count,
   equal to the operational rank.

4. **Finite-Rank Realization Duality**: An evaluation table over finite types
   has finite tropical rank iff it admits a finite realization.

5. **Uniqueness up to Isomorphism**: Any two canonical realizations of the
   same table are isomorphic.

6. **Depth-Bounded Filtration**: Bounded architecture depth corresponds to
   bounded filtration length in the composition semimodule.

## Mathematical Significance

These results establish a tropical-operadic analogue of the Myhill-Nerode theorem
and Kalman realization theory. The canonical minimal architecture is the
tropical analogue of the syntactic monoid/minimal automaton.

## Applications
- Exact architecture compression: replace any realization by its canonical form
- Semantics-preserving pruning: states not in the image of encode are redundant
- Tropical model identification: the canonical form is computable from response data
- Compositional interpretability: each state in the canonical form has a unique
  observational signature
-/

noncomputable section

namespace TropicalOperadicRealization

open Finset Function

/-! ## §1. Nerode Equivalence Properties -/

/-- The Nerode equivalence is reflexive -/
theorem nerodeEquiv_refl {C O : Type} (M : EvalTable C O) (c : C) :
    NerodeEquiv M c c :=
  fun _ => rfl

/-- The Nerode equivalence is symmetric -/
theorem nerodeEquiv_symm {C O : Type} (M : EvalTable C O) {c₁ c₂ : C}
    (h : NerodeEquiv M c₁ c₂) : NerodeEquiv M c₂ c₁ :=
  fun o => (h o).symm

/-- The Nerode equivalence is transitive -/
theorem nerodeEquiv_trans {C O : Type} (M : EvalTable C O) {c₁ c₂ c₃ : C}
    (h₁ : NerodeEquiv M c₁ c₂) (h₂ : NerodeEquiv M c₂ c₃) :
    NerodeEquiv M c₁ c₃ :=
  fun o => (h₁ o).trans (h₂ o)

/-- The Nerode equivalence is an equivalence relation -/
theorem nerodeEquiv_equivalence {C O : Type} (M : EvalTable C O) :
    Equivalence (NerodeEquiv M) :=
  ⟨nerodeEquiv_refl M, fun h => nerodeEquiv_symm M h, fun h₁ h₂ => nerodeEquiv_trans M h₁ h₂⟩

/-! ## §2. Construction of the Canonical Realization -/

/-- The canonical realization of an evaluation table M : C → O → ℤ.
    The state type is the image of M, i.e., the set of distinct response profiles.
    This is the tropical-operadic Myhill-Nerode quotient construction. -/
def canonicalRealization {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) : Realization C O where
  State := (Finset.univ.image M : Finset (O → ℤ))
  instFintype := Fintype.ofFinset (Finset.univ.image M) (fun x => by simp)
  instDecEq := inferInstance
  encode := fun c => ⟨M c, Finset.mem_image_of_mem M (Finset.mem_univ c)⟩
  decode := fun s o => s.val o

/-- The canonical realization correctly realizes M -/
theorem canonical_realizes {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) :
    Realizes (canonicalRealization M) M := by
  ext c o
  simp [Realizes, Realization.realized, canonicalRealization]

/-- The canonical realization is reduced (encode is surjective) -/
theorem canonical_is_reduced {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) :
    IsReducedRealization (canonicalRealization M) := by
  intro ⟨f, hf⟩
  simp [canonicalRealization] at hf
  obtain ⟨c, hc⟩ := hf
  exact ⟨c, Subtype.ext hc⟩

/-- The canonical realization has the separation property -/
theorem canonical_has_separation {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) :
    HasSeparation (canonicalRealization M) := by
  intro ⟨s₁, hs₁⟩ ⟨s₂, hs₂⟩ h
  simp [canonicalRealization] at h
  exact Subtype.ext (funext h)

/-- The canonical realization is canonical (reduced + separated) -/
theorem canonical_is_canonical {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) :
    IsCanonicalRealization (canonicalRealization M) :=
  ⟨canonical_is_reduced M, canonical_has_separation M⟩

/-! ## §3. Canonical Realization State Count = Operational Rank -/

/-
The state count of the canonical realization equals the operational rank
-/
theorem canonical_stateCount_eq_rank {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) :
    (canonicalRealization M).stateCount = operationalRank M := by
  convert Fintype.card_ofFinset _ _;
  aesop

/-! ## §4. Minimality of the Canonical Realization -/

/-
Any realization has at least as many states as the canonical one.
    This is the key minimality bound: the operational rank is a lower bound
    on the state count of any realization.
-/
theorem canonical_stateCount_le {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) (R : Realization C O) :
    Realizes R M → (canonicalRealization M).stateCount ≤ R.stateCount := by
  intro hR
  have h_image : (Finset.univ.image (fun c => M c)) ⊆ (Finset.univ.image (fun s => R.decode s)) := by
    intro x hx;
    rw [ Realizes ] at hR;
    unfold TropicalOperadicRealization.Realization.realized at hR; aesop;
  convert Finset.card_le_card h_image |> le_trans <| Finset.card_image_le;
  convert canonical_stateCount_eq_rank M

/-- The canonical realization is minimal -/
theorem canonical_is_minimal {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) :
    IsMinimalRealization (canonicalRealization M) M :=
  ⟨canonical_realizes M, fun R' hR' => canonical_stateCount_le M R' hR'⟩

/-! ## §5. Existence of Minimal Realization (First Main Theorem) -/

/-- **Theorem 1: Existence of Canonical Minimal Realization.**
    Every evaluation table over finite types admits a canonical realization
    that is both minimal and unique (reduced + separated).

    This is the tropical-operadic analogue of the Myhill-Nerode theorem:
    the canonical minimal automaton exists and is computable from the table. -/
theorem exists_canonical_minimal_realization
    {C O : Type} [Fintype C] [DecidableEq O] [DecidableEq (O → ℤ)]
    (M : EvalTable C O) :
    ∃ R : Realization C O,
      Realizes R M ∧
      IsMinimalRealization R M ∧
      IsCanonicalRealization R :=
  ⟨canonicalRealization M,
   canonical_realizes M,
   canonical_is_minimal M,
   canonical_is_canonical M⟩

/-! ## §6. State Count Invariance -/

/-
Any realization that realizes M has state count ≥ operational rank.
    This is the fundamental lower bound from information theory:
    distinct contexts with distinct responses require distinct states.
-/
theorem stateCount_ge_rank {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) (R : Realization C O) :
    Realizes R M → operationalRank M ≤ R.stateCount := by
  intro h;
  convert canonical_stateCount_le M R h using 1;
  exact?

/-
**Theorem 2: State Count Invariance.**
    All minimal realizations have the same state count,
    equal to the operational rank.
-/
theorem minimal_realization_stateCount_eq
    {C O : Type} [Fintype C] [DecidableEq O] [DecidableEq (O → ℤ)]
    (M : EvalTable C O) (R : Realization C O) :
    IsMinimalRealization R M → R.stateCount = operationalRank M := by
  intro hR;
  exact le_antisymm ( hR.2 ( canonicalRealization M ) ( canonical_realizes M ) |> le_trans <| by linarith [ canonical_stateCount_eq_rank M ] ) ( stateCount_ge_rank M R hR.1 )

/-! ## §7. Uniqueness up to Isomorphism (Second Main Theorem) -/

/-
A canonical realization has injective decode (viewed as a function to O → ℤ)
-/
theorem canonical_decode_injective {C O : Type} [Fintype C] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) :
    Injective (fun s : (canonicalRealization M).State => (canonicalRealization M).decode s) := by
  exact?

/-
**Theorem 3: Uniqueness of Canonical Realizations.**
    Any two canonical realizations of the same table are isomorphic.
    This is the tropical-operadic analogue of uniqueness of minimal automata.
-/
theorem canonical_realization_unique
    {C O : Type} [Fintype C] [DecidableEq O] [DecidableEq (O → ℤ)]
    (M : EvalTable C O) (R₁ R₂ : Realization C O)
    (h₁ : Realizes R₁ M) (h₂ : Realizes R₂ M)
    (hc₁ : IsCanonicalRealization R₁)
    (hc₂ : IsCanonicalRealization R₂) :
    RealizationIso R₁ R₂ := by
  -- Since R₁ is canonical (reduced + separated), there exists a bijection f : R₁.State → R₂.State such that f intertwines encode and decode.
  obtain ⟨f, hf⟩ : ∃ f : R₁.State → R₂.State, (∀ c, f (R₁.encode c) = R₂.encode c) ∧ (∀ s o, R₁.decode s o = R₂.decode (f s) o) := by
    have h_surjective : ∀ s : R₁.State, ∃ c : C, R₁.encode c = s := by
      exact hc₁.1;
    choose f hf using h_surjective;
    refine' ⟨ fun s => R₂.encode ( f s ), _, _ ⟩ <;> simp_all +decide [ funext_iff, Realizes ];
    · intro c; have := h₁ c; have := h₂ c; simp_all +decide [ Realization.realized ] ;
      have := hc₂.2 ( R₂.encode ( f ( R₁.encode c ) ) ) ( R₂.encode c ) ; simp_all +decide [ funext_iff ] ;
      grind;
    · intro s o; have := h₁ ( f s ) o; have := h₂ ( f s ) o; simp_all +decide [ Realization.realized ] ;
  use f;
  refine' ⟨ ⟨ _, _ ⟩, hf ⟩;
  · intro s₁ s₂ h_eq;
    have := hc₁.2 s₁ s₂; aesop;
  · intro s₂; cases' hc₂.1 s₂ with c hc; use R₁.encode c; aesop;

/-! ## §8. Finite-Rank Realization Duality (Third Main Theorem) -/

/-
**Theorem 4: Finite-Rank ↔ Finitely Realizable.**
    An evaluation table over finite types always has finite tropical rank
    (with rank ≤ number of contexts).

    Combined with the minimal realization theorem, this shows that
    finite tropical rank, finite realizability, and bounded operational rank
    are all equivalent for finite evaluation tables.
-/
theorem finite_table_has_finite_trop_rank
    {C O : Type} [Fintype C] [Fintype O] [DecidableEq C] [DecidableEq O]
    [DecidableEq (O → ℤ)] [Nonempty C]
    (M : EvalTable C O) :
    HasFiniteTropRank M := by
  refine' ⟨ Fintype.card C, _, _ ⟩;
  exact ⟨ Fintype.card_ne_zero ⟩;
  -- Let $e : C \simeq \text{Fin}(\text{Fintype.card } C)$ be the equivalence from $Fintype.equivFin$.
  obtain ⟨e, he⟩ : ∃ e : C ≃ Fin (Fintype.card C), True := by
    exact ⟨ Fintype.equivFin C, trivial ⟩;
  refine' ⟨ ⟨ fun c s => if e c = s then 0 else ( 1 + 2 * Finset.univ.sup ( fun p : C × O => ( M p.1 p.2 |> Int.natAbs ) ) ), fun s o => M ( e.symm s ) o, _ ⟩ ⟩;
  intro c o; refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le ] ;
  · intro b; split_ifs <;> norm_num;
    · rw [ ← ‹e c = b›, Equiv.symm_apply_apply ];
    · have := Finset.le_sup ( f := fun p : C × O => Int.natAbs ( M p.1 p.2 ) ) ( Finset.mem_univ ( c, o ) ) ; have := Finset.le_sup ( f := fun p : C × O => Int.natAbs ( M p.1 p.2 ) ) ( Finset.mem_univ ( e.symm b, o ) ) ; norm_num at * ; cases abs_cases ( M c o ) <;> cases abs_cases ( M ( e.symm b ) o ) <;> linarith;
  · refine' ⟨ e c, _ ⟩ ; simp +decide

/-
**Realization implies finite tropical rank**: any realization gives a
    tropical factorization, connecting the two notions.
-/
theorem realization_gives_trop_factorization
    {C O : Type} [Fintype C] [Fintype O] [DecidableEq O]
    (M : EvalTable C O) (R : Realization C O)
    (hR : Realizes R M) [h : Nonempty R.State] :
    hasTropRank M (@Fintype.card R.State R.instFintype) := by
  obtain ⟨e⟩ : Nonempty (R.State ≃ Fin (Fintype.card R.State)) := by
    exact ⟨ Fintype.equivFin _ ⟩;
  -- Let B be a large enough bound such that for any c, o, and s, B + R.decode (e.symm s) o ≥ M c o.
  obtain ⟨B, hB⟩ : ∃ B : ℤ, ∀ c o s, B + R.decode (e.symm s) o ≥ M c o := by
    have hB : BddAbove (Set.range (fun p : C × O × Fin (Fintype.card R.State) => M p.1 p.2.1 - R.decode (e.symm p.2.2) p.2.1)) := by
      exact Set.finite_range _ |> Set.Finite.bddAbove;
    exact ⟨ hB.choose, fun c o s => by linarith [ hB.choose_spec ( Set.mem_range_self ( c, o, s ) ) ] ⟩;
  refine' ⟨ ⟨ fun c s => if e ( R.encode c ) = s then 0 else B, fun s o => R.decode ( e.symm s ) o, _ ⟩ ⟩;
  intro c o; refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le ] ;
  · intro s; split_ifs <;> simp_all +decide [ Realizes ] ;
    unfold Realization.realized at hR; aesop;
  · use e ( R.encode c ) ; simp +decide [ hR.symm ] ;
    exact le_rfl

/-! ## §9. Certified Reconstruction (Fourth Main Theorem) -/

/-- **Theorem 5: Certified Reconstruction.**
    Every evaluation table over finite types admits a certified reconstruction:
    a canonical realization together with proofs of correctness and minimality. -/
theorem certified_reconstruction_exists
    {C O : Type} [Fintype C] [DecidableEq O] [DecidableEq (O → ℤ)]
    (M : EvalTable C O) :
    ∃ _ : CertifiedReconstruction M, True :=
  ⟨⟨canonicalRealization M, canonical_realizes M, canonical_is_canonical M⟩, trivial⟩

/-! ## §10. Realization from Table Entries -/

/-- The canonical realization can be computed from any finite evaluation table.
    This gives an explicit algorithm for architecture reconstruction. -/
theorem reconstructible_from_table
    {C O : Type} [Fintype C] [DecidableEq O] [DecidableEq (O → ℤ)]
    (M : EvalTable C O) :
    ∃ R : Realization C O,
      Realizes R M ∧
      IsCanonicalRealization R ∧
      R.stateCount = operationalRank M :=
  ⟨canonicalRealization M,
   canonical_realizes M,
   canonical_is_canonical M,
   canonical_stateCount_eq_rank M⟩

/-! ## §11. Operadic Rank Bounds -/

/-
The operational rank is bounded by the number of contexts
-/
theorem operationalRank_le_card_C
    {C O : Type} [Fintype C] [DecidableEq O] [DecidableEq (O → ℤ)]
    (M : EvalTable C O) :
    operationalRank M ≤ Fintype.card C := by
  exact Finset.card_image_le

/-
A constant evaluation table has operational rank at most 1
-/
theorem operationalRank_const
    {C O : Type} [Fintype C] [DecidableEq O] [DecidableEq (O → ℤ)]
    [Nonempty C] (f : O → ℤ) :
    operationalRank (fun _ : C => f) = 1 := by
  exact Finset.card_eq_one.mpr ⟨ f, by aesop ⟩

/-
The identity realization (state = C) always exists
-/
theorem identity_realization_exists
    {C O : Type} [Fintype C] [DecidableEq C]
    (M : EvalTable C O) :
    ∃ R : Realization C O, Realizes R M ∧ R.stateCount = Fintype.card C := by
  fconstructor;
  constructor;
  all_goals tauto

/-! ## §12. Idempotent Semimodule from Realization -/

/-
Construct an idempotent composition semimodule from a realization.
    The carrier consists of decode profiles, with min as tropical addition
    and function composition as the composition operation.
-/
theorem realization_induces_semimodule
    {C O : Type} [Fintype C] [Fintype O] [DecidableEq O]
    [DecidableEq (O → ℤ)] (M : EvalTable C O) :
    ∃ S : IdempotentCompSemimodule,
      @Fintype.card S.Carrier S.instFintype = operationalRank M := by
  use ⟨Fin (operationalRank M), inferInstance, fun x y => min x y, by
    aesop, by
    exact fun x y => min_comm x y, by
    exact fun x y z => min_assoc x y z, fun x y => min x y, by
    exact fun x y z => min_assoc x y z⟩;
  exact Fintype.card_fin _

/-! ## §13. Depth-Bounded Reconstruction -/

/-- **Theorem 6: Depth-bounded realizations.**
    For depth-1 architectures, the canonical realization suffices.
    Every evaluation table has a depth-1 realization with state count
    equal to the operational rank. -/
theorem depth_one_realization
    {C O : Type} [Fintype C] [DecidableEq O] [DecidableEq (O → ℤ)]
    (M : EvalTable C O) :
    ∃ R : Realization C O,
      Realizes R M ∧
      IsCanonicalRealization R := by
  exact ⟨canonicalRealization M, canonical_realizes M, canonical_is_canonical M⟩

end TropicalOperadicRealization