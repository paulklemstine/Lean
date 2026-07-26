/-
# Closure–Thermodynamic Computation Duality via Idempotent Dissipation Semimodules
# and Certified Minimal Entropy-Scheduler Reconstruction

This file establishes a finite thermodynamic analogue of Myhill–Nerode minimal
realization theory, where **closure-compatible dissipation semantics** replaces
language acceptance or linear observability.

## Main Results

* `closedProfile_injective` — Dissipation profiles are injective on closed
  sets for separated systems.
* `separated_realization_state_minimal` — A separated realization has the fewest
  closed sets among all realizations of the same dissipation data.
* `separated_realizations_card_eq` — Two separated realizations of the same data
  have equal closed-set counts (uniqueness).
* `separated_realizations_equiv` — Profile-preserving bijection between two
  separated realizations (isomorphism theorem).
* `canonical_realization_exists` — Every nonempty finite dissipation datum
  is realizable by a separated ThermoComp.
* `reversible_or_irreversible` — Every generator is reversible or irreversible.
* `strict_closure_growth_implies_positive_energy` — Non-trivial closure growth
  implies positive energy cost (Landauer witness).
* `thermodynamic_realization_duality` — The complete duality theorem.

## Mathematical Significance

This constitutes a **"Myhill–Nerode theorem for irreversible physics"**: the minimal
finite thermodynamic scheduler is uniquely reconstructible from its
closure-constrained dissipative cost data.
-/

import Mathlib

set_option maxHeartbeats 800000

open Finset Function

namespace ClosureThermoDuality

/-! ## Section 1: Closure Operators on Finite Sets -/

/-- A closure operator on `Finset α` over a finite type. -/
structure ClosureOp (α : Type*) [Fintype α] [DecidableEq α] where
  cl : Finset α → Finset α
  extensive : ∀ A, A ⊆ cl A
  mono : ∀ {A B : Finset α}, A ⊆ B → cl A ⊆ cl B
  idem : ∀ A, cl (cl A) = cl A

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- A set is closed if it is a fixpoint of the closure operator. -/
def ClosureOp.IsClosed (C : ClosureOp α) (A : Finset α) : Prop := C.cl A = A

/-- Decidability of `IsClosed` (since `Finset` equality is decidable). -/
instance (C : ClosureOp α) (A : Finset α) : Decidable (C.IsClosed A) :=
  inferInstanceAs (Decidable (C.cl A = A))

/-- The closure of any set is closed. -/
theorem ClosureOp.cl_closed (C : ClosureOp α) (A : Finset α) :
    C.IsClosed (C.cl A) := C.idem A

/-- If `A` is closed, then `cl A = A`. -/
theorem ClosureOp.cl_of_closed (C : ClosureOp α) {A : Finset α}
    (h : C.IsClosed A) : C.cl A = A := h

/-! ## Section 2: Thermodynamic Computation Objects -/

/-- A finite thermodynamic computation object: closure + energy + n generators. -/
structure ThermoComp (S : Type*) [Fintype S] [DecidableEq S] (n : ℕ) extends
    ClosureOp S where
  energy : Finset S → ℕ
  energy_mono : ∀ A, energy A ≤ energy (cl A)
  dissip : Fin n → Finset S → ℕ

variable {S : Type*} [Fintype S] [DecidableEq S] {n : ℕ}

/-- The dissipation profile of a set: the vector of dissipation costs
    of the closure across all generators. -/
def ThermoComp.profile (T : ThermoComp S n) (A : Finset S) : Fin n → ℕ :=
  fun i => T.dissip i (T.cl A)

/-- For a closed set, the profile equals direct dissipation. -/
theorem ThermoComp.profile_of_closed (T : ThermoComp S n) {A : Finset S}
    (hA : T.toClosureOp.IsClosed A) (i : Fin n) :
    T.profile A i = T.dissip i A := by
  simp [ThermoComp.profile, ClosureOp.cl_of_closed _ hA]

/-- Two sets with the same closure have the same profile. -/
theorem ThermoComp.profile_eq_of_cl_eq (T : ThermoComp S n) {A B : Finset S}
    (h : T.cl A = T.cl B) : T.profile A = T.profile B := by
  ext i; simp [ThermoComp.profile, h]

/-- The profile of `cl A` equals the profile of `A`. -/
theorem ThermoComp.profile_cl (T : ThermoComp S n) (A : Finset S) :
    T.profile (T.cl A) = T.profile A :=
  T.profile_eq_of_cl_eq (T.idem A)

/-! ## Section 3: Separatedness and Profile Injectivity -/

/-- A system is **separated** if distinct closed sets have distinct profiles. -/
def ThermoComp.Separated (T : ThermoComp S n) : Prop :=
  ∀ A B : Finset S, T.toClosureOp.IsClosed A → T.toClosureOp.IsClosed B →
    T.profile A = T.profile B → A = B

/-- The type of closed sets of a thermodynamic computation object. -/
abbrev ThermoComp.ClosedSetType (T : ThermoComp S n) :=
  {A : Finset S // T.toClosureOp.IsClosed A}

/-- The profile map restricted to closed sets. -/
def ThermoComp.closedProfile (T : ThermoComp S n) (p : T.ClosedSetType) :
    Fin n → ℕ := T.profile p.val

/-- **Profile Injectivity**: For separated systems, profiles are injective
    on closed sets. -/
theorem ThermoComp.closedProfile_injective (T : ThermoComp S n)
    (hsep : T.Separated) : Function.Injective T.closedProfile := by
  intro ⟨A, hA⟩ ⟨B, hB⟩ h
  exact Subtype.ext (hsep A B hA hB h)

/-! ## Section 4: Dissipation Data and Realization -/

/-- Abstract dissipation data: a finite family of distinct profiles. -/
structure DissipData (n : ℕ) where
  numProfs : ℕ
  prof : Fin numProfs → (Fin n → ℕ)
  prof_inj : Function.Injective prof

/-- A ThermoComp **realizes** dissipation data if there is a profile-preserving
    surjection from closed sets to data indices. -/
structure ThermoComp.Realizes (T : ThermoComp S n) (D : DissipData n) where
  map : T.ClosedSetType → Fin D.numProfs
  map_surj : Function.Surjective map
  map_compat : ∀ p : T.ClosedSetType, T.closedProfile p = D.prof (map p)

/-- For a separated realization, the map is also injective (hence bijective). -/
theorem ThermoComp.Realizes.map_injective (T : ThermoComp S n) (D : DissipData n)
    (hsep : T.Separated) (hR : T.Realizes D) :
    Function.Injective hR.map := by
  intro ⟨A, hA⟩ ⟨B, hB⟩ hm
  have h1 := hR.map_compat ⟨A, hA⟩
  have h2 := hR.map_compat ⟨B, hB⟩
  have h3 : T.closedProfile ⟨A, hA⟩ = T.closedProfile ⟨B, hB⟩ := by rw [h1, h2, hm]
  exact T.closedProfile_injective hsep h3

/-- **Counting Lemma**: A separated realization has exactly `D.numProfs` closed sets. -/
theorem ThermoComp.card_closedSets_eq_of_separated
    (T : ThermoComp S n) (D : DissipData n)
    (hsep : T.Separated) (hR : T.Realizes D) :
    Fintype.card T.ClosedSetType = D.numProfs := by
  have := Fintype.card_of_bijective (f := hR.map) ⟨hR.map_injective T D hsep, hR.map_surj⟩
  simp [Fintype.card_fin] at this
  exact this

/-- **Lower Bound**: Any realization has at least `D.numProfs` closed sets. -/
theorem ThermoComp.card_closedSets_ge
    (T : ThermoComp S n) (D : DissipData n) (hR : T.Realizes D) :
    D.numProfs ≤ Fintype.card T.ClosedSetType := by
  have := Fintype.card_le_of_surjective hR.map hR.map_surj
  simp [Fintype.card_fin] at this
  exact this

/-! ## Section 5: Minimality and Uniqueness -/

/-- **Minimal Realization Theorem**: A separated realization has the fewest
    closed sets among all realizations of the same data. -/
theorem ThermoComp.separated_realization_state_minimal
    {S₁ S₂ : Type*} [Fintype S₁] [DecidableEq S₁] [Fintype S₂] [DecidableEq S₂]
    (T₁ : ThermoComp S₁ n) (T₂ : ThermoComp S₂ n) (D : DissipData n)
    (hsep : T₁.Separated) (hR₁ : T₁.Realizes D) (hR₂ : T₂.Realizes D) :
    Fintype.card T₁.ClosedSetType ≤ Fintype.card T₂.ClosedSetType := by
  rw [T₁.card_closedSets_eq_of_separated D hsep hR₁]
  exact T₂.card_closedSets_ge D hR₂

/-- **Uniqueness Theorem**: Two separated realizations have equal closed-set counts. -/
theorem ThermoComp.separated_realizations_card_eq
    {S₁ S₂ : Type*} [Fintype S₁] [DecidableEq S₁] [Fintype S₂] [DecidableEq S₂]
    (T₁ : ThermoComp S₁ n) (T₂ : ThermoComp S₂ n) (D : DissipData n)
    (hsep₁ : T₁.Separated) (hsep₂ : T₂.Separated)
    (hR₁ : T₁.Realizes D) (hR₂ : T₂.Realizes D) :
    Fintype.card T₁.ClosedSetType = Fintype.card T₂.ClosedSetType := by
  have h1 := T₁.card_closedSets_eq_of_separated D hsep₁ hR₁
  have h2 := T₂.card_closedSets_eq_of_separated D hsep₂ hR₂
  omega

/-- **Isomorphism Theorem**: Two separated realizations admit a profile-preserving
    bijection between their closed-set types. -/
theorem ThermoComp.separated_realizations_equiv
    {S₁ S₂ : Type*} [Fintype S₁] [DecidableEq S₁] [Fintype S₂] [DecidableEq S₂]
    (T₁ : ThermoComp S₁ n) (T₂ : ThermoComp S₂ n) (D : DissipData n)
    (hsep₁ : T₁.Separated) (hsep₂ : T₂.Separated)
    (hR₁ : T₁.Realizes D) (hR₂ : T₂.Realizes D) :
    ∃ f : T₁.ClosedSetType → T₂.ClosedSetType,
      Function.Bijective f ∧
      ∀ p, T₁.closedProfile p = T₂.closedProfile (f p) := by
  have hf : Nonempty (T₁.ClosedSetType ≃ T₂.ClosedSetType) := by
    exact ⟨ Fintype.equivOfCardEq ( by rw [ ThermoComp.card_closedSets_eq_of_separated _ _ hsep₁ hR₁, ThermoComp.card_closedSets_eq_of_separated _ _ hsep₂ hR₂ ] ) ⟩;
  have h_map_inj : Function.Bijective hR₁.map ∧ Function.Bijective hR₂.map := by
    exact ⟨ ⟨ ThermoComp.Realizes.map_injective _ _ hsep₁ _, hR₁.map_surj ⟩, ⟨ ThermoComp.Realizes.map_injective _ _ hsep₂ _, hR₂.map_surj ⟩ ⟩;
  refine' ⟨ Equiv.ofBijective _ h_map_inj.1 |> Equiv.trans <| Equiv.symm <| Equiv.ofBijective _ h_map_inj.2, _, _ ⟩;
  · exact Equiv.bijective _;
  · intro p; exact (by
    convert hR₁.map_compat p using 1;
    convert hR₂.map_compat _ using 1;
    simp +decide [ Equiv.ofBijective ];
    rw [ surjInv_eq h_map_inj.2.2 ])

/-! ## Section 6: Canonical Realization -/

/-- The identity closure operator: every set is closed. -/
def identityClosure (β : Type*) [Fintype β] [DecidableEq β] : ClosureOp β where
  cl := id
  extensive := fun _ => Finset.Subset.refl _
  mono := fun h => h
  idem := fun _ => rfl

/-
**Canonical Realization**: Every nonempty finite dissipation datum is
    realizable by a separated ThermoComp. The construction uses the identity
    closure on `Fin D.numProfs` and encodes set membership via dissipation
    to achieve separation.
-/
theorem canonical_realization_exists (D : DissipData n) (hn : 0 < D.numProfs) :
    ∃ (T : ThermoComp (Fin D.numProfs) n),
      T.Separated ∧ Nonempty (T.Realizes D) := by
  by_contra! h;
  -- Define the canonical realization T with the specified properties.
  set T : ThermoComp (Fin D.numProfs) n := {
    cl := fun A => Finset.univ.filter (fun x => x.val ≤ (if h : A.Nonempty then (A.max' h).val else 0)),
    extensive := by
      intro A x hx; split_ifs <;> simp_all +decide [ Finset.le_max' ] ;,
    mono := by
      intro A B hAB; split_ifs <;> simp_all +decide [ Finset.subset_iff ] ;
      · exact fun x hx => le_trans hx <| Finset.le_max' _ _ <| hAB <| Finset.max'_mem _ _;
      · exact fun x hx => Fin.le_iff_val_le_val.mpr ( by linarith [ Fin.is_lt x, Fin.is_lt ( Finset.max' B ‹_› ) ] ),
    idem := by
      intro A; split_ifs <;> simp_all +decide [ Finset.Nonempty ] ;
      · ext; simp [Finset.max'];
        exact ⟨ fun ⟨ b, ⟨ c, hc, hbc ⟩, hab ⟩ => ⟨ c, hc, hab.trans hbc ⟩, fun ⟨ c, hc, hac ⟩ => ⟨ c, ⟨ c, hc, le_rfl ⟩, hac ⟩ ⟩;
      · exact absurd ( ‹∀ x y : Fin D.numProfs, y ∈ A → y < x› _ _ ( Finset.max'_mem _ ‹_› ) ) ( lt_irrefl _ );
      · simp_all +decide [ Finset.max' ];
        grind,
    energy := fun _ => 0,
    energy_mono := by
      exact fun _ => Nat.zero_le _,
    dissip := fun i A => D.prof (if h : A.Nonempty then ⟨A.max' h, by
      exact Fin.is_lt _⟩ else ⟨0, hn⟩) i
  }
  generalize_proofs at *;
  refine' h T _ |>.elim _;
  · intro A B hA hB hAB;
    -- Since $A$ and $B$ are closed, we have $A = \{x \mid x.val \leq \max(A)\}$ and $B = \{x \mid x.val \leq \max(B)\}$.
    have hA_eq : A = Finset.univ.filter (fun x => x.val ≤ (if h : A.Nonempty then (A.max' h).val else 0)) := by
      exact hA.symm
    have hB_eq : B = Finset.univ.filter (fun x => x.val ≤ (if h : B.Nonempty then (B.max' h).val else 0)) := by
      exact hB.symm;
    have := D.prof_inj ( show D.prof ( if h : A.Nonempty then ⟨ A.max' h, by
                          exact Fin.is_lt _ ⟩ else ⟨ 0, hn ⟩ ) = D.prof ( if h : B.Nonempty then ⟨ B.max' h, by
                          exact Fin.is_lt _ ⟩ else ⟨ 0, hn ⟩ ) from by
                          convert hAB using 1;
                          · unfold ThermoComp.profile; simp +decide [ T ] ;
                            grind;
                          · grind +suggestions )
    generalize_proofs at *;
    grind;
  · use fun p => if h : p.val.Nonempty then ⟨ p.val.max' h, by
      grind +splitIndPred ⟩ else ⟨ 0, hn ⟩
    all_goals generalize_proofs at *;
    · intro x;
      use ⟨ Finset.Iic x, by
        simp +decide [ T, ClosureOp.IsClosed ];
        simp +decide [ Finset.max' ];
        ext; simp [Iic];
        exact ⟨ fun ⟨ b, hb₁, hb₂ ⟩ => Finset.mem_Iic.mpr ( le_trans hb₂ hb₁ ), fun hx => ⟨ _, Finset.mem_Iic.mp hx, le_rfl ⟩ ⟩ ⟩
      generalize_proofs at *;
      simp +decide [ Finset.max' ];
      exact le_antisymm ( Finset.sup'_le _ _ fun y hy => Finset.mem_Iic.mp hy ) ( Finset.le_sup' ( fun x => x ) ( Finset.mem_Iic.mpr le_rfl ) );
    · intro p; ext i; simp +decide [ ThermoComp.closedProfile, ThermoComp.profile ] ;
      grind +locals

/-! ## Section 7: Zero-Loss Strata and Reversibility -/

/-- A closed set has **zero loss** if all generators produce zero dissipation. -/
def ThermoComp.IsZeroLoss (T : ThermoComp S n) (A : Finset S) : Prop :=
  T.toClosureOp.IsClosed A ∧ ∀ i : Fin n, T.dissip i A = 0

/-- Zero-loss closed sets have the zero profile. -/
theorem ThermoComp.zero_loss_profile_eq_zero (T : ThermoComp S n)
    {A : Finset S} (h : T.IsZeroLoss A) :
    T.profile A = fun _ => 0 := by
  funext i
  simp only [profile]
  rw [h.1, h.2 i]

/-- In a separated system, there is at most one zero-loss closed set. -/
theorem ThermoComp.zero_loss_unique (T : ThermoComp S n) (hsep : T.Separated)
    {A B : Finset S} (hA : T.IsZeroLoss A) (hB : T.IsZeroLoss B) : A = B := by
  apply hsep A B hA.1 hB.1
  rw [ThermoComp.zero_loss_profile_eq_zero T hA,
      ThermoComp.zero_loss_profile_eq_zero T hB]

/-- A generator is **reversible** if it has zero dissipation on all closed sets. -/
def ThermoComp.IsReversible (T : ThermoComp S n) (i : Fin n) : Prop :=
  ∀ A : Finset S, T.toClosureOp.IsClosed A → T.dissip i A = 0

/-- A generator is **irreversible** if some closed set witnesses positive dissipation. -/
def ThermoComp.IsIrreversible (T : ThermoComp S n) (i : Fin n) : Prop :=
  ∃ A : Finset S, T.toClosureOp.IsClosed A ∧ T.dissip i A ≠ 0

/-- **Reversible-Irreversible Dichotomy**: Every generator is reversible or irreversible. -/
theorem ThermoComp.reversible_or_irreversible (T : ThermoComp S n) (i : Fin n) :
    T.IsReversible i ∨ T.IsIrreversible i := by
  by_cases h : ∀ A : Finset S, T.toClosureOp.IsClosed A → T.dissip i A = 0
  · exact Or.inl h
  · push_neg at h; exact Or.inr h

/-- Reversible and irreversible are complementary. -/
theorem ThermoComp.not_reversible_iff_irreversible (T : ThermoComp S n) (i : Fin n) :
    ¬T.IsReversible i ↔ T.IsIrreversible i := by
  simp only [IsReversible, IsIrreversible]
  push_neg
  rfl

/-- The Finset of reversible generators. -/
noncomputable def ThermoComp.reversibleGens (T : ThermoComp S n) : Finset (Fin n) :=
  Finset.univ.filter (fun i =>
    ∀ A : Finset S, T.toClosureOp.IsClosed A → T.dissip i A = 0)

/-- The Finset of irreversible generators. -/
noncomputable def ThermoComp.irreversibleGens (T : ThermoComp S n) : Finset (Fin n) :=
  Finset.univ.filter (fun i =>
    ∃ A : Finset S, T.toClosureOp.IsClosed A ∧ T.dissip i A ≠ 0)

/-- **Generator Partition**: Reversible and irreversible generators cover all generators. -/
theorem ThermoComp.reversible_irreversible_union (T : ThermoComp S n) :
    T.reversibleGens ∪ T.irreversibleGens = Finset.univ := by
  ext i; simp [ThermoComp.reversibleGens, ThermoComp.irreversibleGens]
  exact Classical.or_iff_not_imp_left.2 fun h => by push_neg at h; exact h

/-- Reversible and irreversible generators are disjoint. -/
theorem ThermoComp.reversible_irreversible_disjoint (T : ThermoComp S n) :
    Disjoint T.reversibleGens T.irreversibleGens := by
  exact Finset.disjoint_filter.2 fun _ _ _ _ => by tauto

/-! ## Section 8: Strict Energy Growth (Landauer Witness) -/

/-- Strict energy monotonicity: proper closure growth strictly increases energy. -/
def ThermoComp.StrictEnergyMono (T : ThermoComp S n) : Prop :=
  ∀ A : Finset S, T.cl A ≠ A → T.energy A < T.energy (T.cl A)

/-- **Landauer Witness**: Strict energy monotonicity yields positive energy gap. -/
theorem ThermoComp.strict_closure_growth_implies_positive_energy
    (T : ThermoComp S n) (hstrict : T.StrictEnergyMono)
    (A : Finset S) (h : T.cl A ≠ A) :
    0 < T.energy (T.cl A) - T.energy A := by
  exact Nat.sub_pos_of_lt (hstrict A h)

/-- Closed sets have zero energy gap from closure. -/
theorem ThermoComp.closed_energy_stable (T : ThermoComp S n) {A : Finset S}
    (hA : T.toClosureOp.IsClosed A) :
    T.energy (T.cl A) = T.energy A := by
  simp [ClosureOp.cl_of_closed _ hA]

/-
**Energy chain bound**: For energy strictly monotone on closed sets,
    a strict chain of k closed sets forces energy gap ≥ k-1.
    Here specialized to k=3 for concreteness.
-/
theorem ThermoComp.closure_chain_energy_bound (T : ThermoComp S n)
    (hm : ∀ A B : Finset S,
      T.toClosureOp.IsClosed A → T.toClosureOp.IsClosed B →
      A ⊂ B → T.energy A < T.energy B)
    (A₁ A₂ A₃ : Finset S)
    (h12 : A₁ ⊂ A₂) (h23 : A₂ ⊂ A₃)
    (hcl1 : T.toClosureOp.IsClosed A₁)
    (hcl2 : T.toClosureOp.IsClosed A₂)
    (hcl3 : T.toClosureOp.IsClosed A₃) :
    T.energy A₁ + 2 ≤ T.energy A₃ := by
  linarith [ hm A₁ A₂ hcl1 hcl2 h12, hm A₂ A₃ hcl2 hcl3 h23 ]

/-! ## Section 9: Profile Equivalence -/

/-- Profile equivalence: two sets have the same dissipation profile. -/
def ThermoComp.ProfileEquiv (T : ThermoComp S n) (A B : Finset S) : Prop :=
  T.profile A = T.profile B

/-- Profile equivalence is an equivalence relation. -/
theorem ThermoComp.profileEquiv_equivalence (T : ThermoComp S n) :
    Equivalence (T.ProfileEquiv) where
  refl _ := rfl
  symm h := h.symm
  trans h1 h2 := h1.trans h2

/-- A set and its closure are always profile-equivalent. -/
theorem ThermoComp.set_profileEquiv_closure (T : ThermoComp S n) (A : Finset S) :
    T.ProfileEquiv A (T.cl A) := (T.profile_cl A).symm

/-! ## Section 10: Complete Duality Theorem -/

/-- **Thermodynamic Realization Duality** (the main theorem):
    For two separated realizations of the same dissipation data,
    profiles are injective on closed sets, closed-set counts are equal,
    and both equal the number of profiles (minimality + uniqueness). -/
theorem ThermoComp.thermodynamic_realization_duality
    {S₁ S₂ : Type*} [Fintype S₁] [DecidableEq S₁] [Fintype S₂] [DecidableEq S₂]
    (T₁ : ThermoComp S₁ n) (T₂ : ThermoComp S₂ n) (D : DissipData n)
    (hsep₁ : T₁.Separated) (hsep₂ : T₂.Separated)
    (hR₁ : T₁.Realizes D) (hR₂ : T₂.Realizes D) :
    Function.Injective T₁.closedProfile ∧
    Function.Injective T₂.closedProfile ∧
    Fintype.card T₁.ClosedSetType = Fintype.card T₂.ClosedSetType ∧
    Fintype.card T₁.ClosedSetType = D.numProfs := by
  exact ⟨T₁.closedProfile_injective hsep₁,
         T₂.closedProfile_injective hsep₂,
         T₁.separated_realizations_card_eq T₂ D hsep₁ hsep₂ hR₁ hR₂,
         T₁.card_closedSets_eq_of_separated D hsep₁ hR₁⟩

/-! ## Section 11: Concrete Example -/

/-- A two-state separated system: two states with identity closure
    and two generators acting as membership indicators, giving
    distinct profiles to every finset. -/
noncomputable def twoStateSeparated : ThermoComp (Fin 2) 2 where
  cl := id
  extensive := fun _ => Finset.Subset.refl _
  mono := fun h => h
  idem := fun _ => rfl
  energy := fun A => A.card
  energy_mono := fun _ => le_refl _
  dissip := fun i A => if i ∈ A then 1 else 0

/-
The two-state system with indicator dissipation is separated:
    distinct sets have distinct profiles since the indicator function
    uniquely determines set membership.
-/
theorem twoStateSeparated_separated : twoStateSeparated.Separated := by
  intro A B;
  fin_cases A <;> fin_cases B <;> simp +decide

end ClosureThermoDuality