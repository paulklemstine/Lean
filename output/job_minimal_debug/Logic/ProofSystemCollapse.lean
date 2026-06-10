import Mathlib

/-! # Proof System Collapse: Lattice Structure of Abstract Proof Systems

We formalize the abstract theory of propositional proof systems following
Cook–Reckhow (1979), proving that proof systems under the simulation
preorder carry a lattice-like structure. The central results are:

1. **Maximality of complete systems** (`complete_simulates_all_sound`):
   A complete sound system simulates every sound system — establishing
   completeness as the unique maximum in the simulation preorder.

2. **Lattice structure** (`union_least_upper_bound`, `inter_greatest_lower_bound`):
   Union and intersection satisfy join/meet universal properties.

3. **Strict separation criterion** (`union_strictly_stronger`):
   If T proves something S cannot, then S ∪ T is strictly stronger than S.

4. **Collapse–separation duality** (`incomplete_iff_nonsimulable`):
   A sound system is incomplete iff there exists another sound system it
   cannot simulate. This is the abstract content of the Cook–Reckhow
   characterization without polynomial-time machinery.
-/

namespace ProofComplexity

/-! ## Core Definitions -/

/-- An abstract proof system: a formula type, a proof type,
    and a boolean verification function. -/
structure ProofSys (F : Type*) where
  /-- The type of proof objects -/
  Proof : Type*
  /-- Verification: returns `true` iff `p` is a valid proof of `f` -/
  verify : F → Proof → Bool

variable {F : Type*}

/-- A formula is provable if the verifier accepts some proof. -/
def ProofSys.Provable (S : ProofSys F) (f : F) : Prop :=
  ∃ p : S.Proof, S.verify f p = true

/-- Soundness: every provable formula is valid. -/
def ProofSys.Sound (S : ProofSys F) (valid : F → Prop) : Prop :=
  ∀ f, S.Provable f → valid f

/-- Completeness: every valid formula is provable. -/
def ProofSys.Complete (S : ProofSys F) (valid : F → Prop) : Prop :=
  ∀ f, valid f → S.Provable f

/-- `Simulates S T` means S can prove everything T can. -/
def Simulates (S T : ProofSys F) : Prop :=
  ∀ f, T.Provable f → S.Provable f

/-- Two systems are simulation-equivalent if each simulates the other. -/
def SimEquiv (S T : ProofSys F) : Prop :=
  Simulates S T ∧ Simulates T S

/-! ## Simulation Preorder -/

theorem simulates_refl (S : ProofSys F) : Simulates S S :=
  fun _ h => h

theorem simulates_trans {R S T : ProofSys F}
    (hRS : Simulates R S) (hST : Simulates S T) : Simulates R T :=
  fun f hf => hRS f (hST f hf)

theorem simEquiv_refl (S : ProofSys F) : SimEquiv S S :=
  ⟨simulates_refl S, simulates_refl S⟩

theorem simEquiv_symm {S T : ProofSys F} (h : SimEquiv S T) : SimEquiv T S :=
  ⟨h.2, h.1⟩

theorem simEquiv_trans {R S T : ProofSys F}
    (h1 : SimEquiv R S) (h2 : SimEquiv S T) : SimEquiv R T :=
  ⟨simulates_trans h1.1 h2.1, simulates_trans h2.2 h1.2⟩

/-! ## Soundness and Completeness Transfer -/

theorem sound_preserved_by_simulation {S T : ProofSys F} {valid : F → Prop}
    (hS : S.Sound valid) (hSim : Simulates S T) : T.Sound valid :=
  fun f hf => hS f (hSim f hf)

theorem complete_preserved_by_simulation {S T : ProofSys F} {valid : F → Prop}
    (hT : T.Complete valid) (hSim : Simulates S T) : S.Complete valid :=
  fun f hf => hSim f (hT f hf)

/-! ## Main Theorem 1: Maximality of Complete Sound Systems -/

-- !-- A complete sound system simulates every other sound system.
--     Proof: T-provable → valid (soundness of T) → S-provable (completeness of S). -- !--
theorem complete_simulates_all_sound {S : ProofSys F} {valid : F → Prop}
    (hS_complete : S.Complete valid)
    {T : ProofSys F} (hT_sound : T.Sound valid) :
    Simulates S T :=
  fun f hf => hS_complete f (hT_sound f hf)

/-- Two complete sound systems are simulation-equivalent. -/
theorem complete_sound_simEquiv {S T : ProofSys F} {valid : F → Prop}
    (hS_sound : S.Sound valid) (hS_complete : S.Complete valid)
    (hT_sound : T.Sound valid) (hT_complete : T.Complete valid) :
    SimEquiv S T :=
  ⟨complete_simulates_all_sound hS_complete hT_sound,
   complete_simulates_all_sound hT_complete hS_sound⟩

/-- Two complete sound systems prove exactly the same formulas. -/
theorem complete_sound_provable_iff {S T : ProofSys F} {valid : F → Prop}
    (hS_sound : S.Sound valid) (hS_complete : S.Complete valid)
    (hT_sound : T.Sound valid) (hT_complete : T.Complete valid) :
    ∀ f, S.Provable f ↔ T.Provable f :=
  fun f => ⟨(complete_simulates_all_sound hT_complete hS_sound) f,
            (complete_simulates_all_sound hS_complete hT_sound) f⟩

/-! ## Union and Intersection -/

/-- The union of two proof systems. A proof is either an S-proof or a T-proof. -/
def ProofSys.union (S T : ProofSys F) : ProofSys F where
  Proof := S.Proof ⊕ T.Proof
  verify := fun f p => match p with
    | .inl ps => S.verify f ps
    | .inr pt => T.verify f pt

/-- The intersection of two proof systems. A proof requires witnesses from both. -/
def ProofSys.inter (S T : ProofSys F) : ProofSys F where
  Proof := S.Proof × T.Proof
  verify := fun f ⟨ps, pt⟩ => S.verify f ps && T.verify f pt

/-! ## Main Theorem 2: Lattice Structure -/

theorem union_simulates_left (S T : ProofSys F) :
    Simulates (S.union T) S :=
  fun _ ⟨p, hp⟩ => ⟨.inl p, hp⟩

theorem union_simulates_right (S T : ProofSys F) :
    Simulates (S.union T) T :=
  fun _ ⟨p, hp⟩ => ⟨.inr p, hp⟩

-- !-- Union is the join: if U simulates both S and T, then U simulates S ∪ T.
--     Case-split on whether the proof is from the left or right component. -- !--
theorem union_least_upper_bound {S T U : ProofSys F}
    (hUS : Simulates U S) (hUT : Simulates U T) :
    Simulates U (S.union T) := by
  intro f ⟨p, hp⟩
  match p with
  | .inl ps => exact hUS f ⟨ps, hp⟩
  | .inr pt => exact hUT f ⟨pt, hp⟩

theorem inter_simulated_by_left (S T : ProofSys F) :
    Simulates S (S.inter T) := by
  intro f ⟨⟨ps, _⟩, hp⟩
  exact ⟨ps, by simp [ProofSys.inter, Bool.and_eq_true] at hp; exact hp.1⟩

theorem inter_simulated_by_right (S T : ProofSys F) :
    Simulates T (S.inter T) := by
  intro f ⟨⟨_, pt⟩, hp⟩
  exact ⟨pt, by simp [ProofSys.inter, Bool.and_eq_true] at hp; exact hp.2⟩

-- !-- Intersection is the meet: the greatest lower bound under simulation.
--     Construct the pair proof from individual translations. -- !--
theorem inter_greatest_lower_bound {S T U : ProofSys F}
    (hSU : Simulates S U) (hTU : Simulates T U) :
    Simulates (S.inter T) U := by
  intro f hf
  obtain ⟨ps, hps⟩ := hSU f hf
  obtain ⟨pt, hpt⟩ := hTU f hf
  exact ⟨⟨ps, pt⟩, by simp [ProofSys.inter, hps, hpt]⟩

/-! ## Soundness/Completeness of Compound Systems -/

theorem union_sound {S T : ProofSys F} {valid : F → Prop}
    (hS : S.Sound valid) (hT : T.Sound valid) :
    (S.union T).Sound valid := by
  intro f ⟨p, hp⟩
  match p with
  | .inl ps => exact hS f ⟨ps, hp⟩
  | .inr pt => exact hT f ⟨pt, hp⟩

theorem inter_sound_left {S T : ProofSys F} {valid : F → Prop}
    (hS : S.Sound valid) : (S.inter T).Sound valid :=
  fun f hf => hS f ((inter_simulated_by_left S T) f hf)

theorem union_complete_of_left {S T : ProofSys F} {valid : F → Prop}
    (hS : S.Complete valid) : (S.union T).Complete valid :=
  fun f hf => (union_simulates_left S T) f (hS f hf)

/-! ## Main Theorem 3: Strict Separation Criterion -/

-- !-- If T proves f but S does not, then S ∪ T strictly dominates S in the
--     simulation order. The forward inclusion is structural; the separation
--     comes from f being provable in S ∪ T (via T) but not in S. -- !--
theorem union_strictly_stronger {S T : ProofSys F}
    {f : F} (hT : T.Provable f) (hS : ¬S.Provable f) :
    Simulates (S.union T) S ∧ ¬Simulates S (S.union T) :=
  ⟨union_simulates_left S T,
   fun h => hS (h f ((union_simulates_right S T) f hT))⟩

/-! ## Singleton Proof System -/

/-- A proof system that proves exactly one formula.
    Used as a building block in the duality theorem. -/
def singletonSys [DecidableEq F] (f₀ : F) : ProofSys F where
  Proof := PUnit
  verify := fun f _ => decide (f = f₀)

theorem singletonSys_provable [DecidableEq F] (f₀ : F) :
    (singletonSys f₀).Provable f₀ :=
  ⟨.unit, by simp [singletonSys]⟩

theorem singletonSys_sound [DecidableEq F] {f₀ : F} {valid : F → Prop}
    (hv : valid f₀) : (singletonSys f₀).Sound valid := by
  intro f ⟨_, hp⟩
  simp [singletonSys] at hp
  rwa [hp]

/-! ## Main Theorem 4: Collapse–Separation Duality -/

-- !-- A sound system is incomplete iff there exists a sound system it cannot
--     simulate. Forward: use the singleton system at a valid unprovable formula.
--     Backward: contrapositive of the maximality theorem. -- !--
/-- Note: soundness of `S` is not needed; the duality is purely about
    the structure of completeness and simulation. -/
theorem incomplete_iff_nonsimulable [DecidableEq F]
    {S : ProofSys F} {valid : F → Prop} :
    ¬S.Complete valid ↔ ∃ T : ProofSys F, T.Sound valid ∧ ¬Simulates S T := by
  constructor
  · -- Forward: S is incomplete → construct a system S can't simulate
    intro hInc
    simp only [ProofSys.Complete, not_forall] at hInc
    obtain ⟨f₀, hv, hnp⟩ := hInc
    exact ⟨singletonSys f₀, singletonSys_sound hv,
           fun hsim => hnp (hsim f₀ (singletonSys_provable f₀))⟩
  · -- Backward: if S can't simulate T, S is incomplete
    intro ⟨T, hT_sound, hnsim⟩ hS_complete
    exact hnsim (complete_simulates_all_sound hS_complete hT_sound)

/-! ## Provability Characterization -/

/-- In a sound and complete system, provability equals validity. -/
theorem provable_iff_valid {S : ProofSys F} {valid : F → Prop}
    (hSound : S.Sound valid) (hComplete : S.Complete valid) :
    ∀ f, S.Provable f ↔ valid f :=
  fun f => ⟨fun h => hSound f h, fun h => hComplete f h⟩

/-- Simulation between sound systems preserves validity witnesses:
    if S simulates T and both are sound w.r.t. the same validity,
    then T.Provable f → S.Provable f with validity as the bridge. -/
theorem simulation_validity_bridge {S T : ProofSys F} {valid : F → Prop}
    (hComplete : S.Complete valid) (hT_sound : T.Sound valid) :
    ∀ f, T.Provable f → valid f ∧ S.Provable f :=
  fun f hf => ⟨hT_sound f hf, hComplete f (hT_sound f hf)⟩

/-! ## Indexed Families of Proof Systems -/

/-- The union of a family of proof systems indexed by `ι`. -/
def ProofSys.iUnion {ι : Type*} (S : ι → ProofSys F) : ProofSys F where
  Proof := Σ i, (S i).Proof
  verify := fun f ⟨i, p⟩ => (S i).verify f p

/-- The indexed union simulates each component. -/
theorem iUnion_simulates {ι : Type*} (S : ι → ProofSys F) (i : ι) :
    Simulates (ProofSys.iUnion S) (S i) :=
  fun _ ⟨p, hp⟩ => ⟨⟨i, p⟩, hp⟩

/-- The indexed union is the least upper bound. -/
theorem iUnion_least_upper_bound {ι : Type*} {S : ι → ProofSys F}
    {U : ProofSys F} (h : ∀ i, Simulates U (S i)) :
    Simulates U (ProofSys.iUnion S) := by
  intro f ⟨⟨i, p⟩, hp⟩
  exact h i f ⟨p, hp⟩

/-- If all components are sound, the indexed union is sound. -/
theorem iUnion_sound {ι : Type*} {S : ι → ProofSys F} {valid : F → Prop}
    (h : ∀ i, (S i).Sound valid) : (ProofSys.iUnion S).Sound valid := by
  intro f ⟨⟨i, p⟩, hp⟩
  exact h i f ⟨p, hp⟩

/-! ## Proof System Morphisms -/

/-- A morphism between proof systems is an explicit proof translation
    that preserves verification. -/
structure ProofSysMorphism (S T : ProofSys F) where
  /-- The proof translation function -/
  translate : T.Proof → S.Proof
  /-- The translation preserves verification -/
  preserves : ∀ f p, T.verify f p = true → S.verify f (translate p) = true

/-- A morphism induces simulation. -/
theorem ProofSysMorphism.toSimulates {S T : ProofSys F}
    (m : ProofSysMorphism S T) : Simulates S T :=
  fun f ⟨p, hp⟩ => ⟨m.translate p, m.preserves f p hp⟩

/-- Identity morphism. -/
def ProofSysMorphism.id (S : ProofSys F) : ProofSysMorphism S S where
  translate := _root_.id
  preserves := fun _ _ h => h

/-- Composition of morphisms. -/
def ProofSysMorphism.comp {R S T : ProofSys F}
    (m : ProofSysMorphism R S) (n : ProofSysMorphism S T) :
    ProofSysMorphism R T where
  translate := m.translate ∘ n.translate
  preserves := fun f p hp => m.preserves f _ (n.preserves f p hp)

end ProofComplexity