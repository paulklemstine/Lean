/-
# Proof System Collapse Theory: The Simulation Preorder, its Lattice, and Polynomial Boundedness

This module develops an abstract theory of *propositional proof systems* in the
Cook–Reckhow sense, organized around the **simulation preorder**.

A proof system over a type of formulas `F` is modelled as a triple
`(Proof, concl, size)`: an abstract type of proofs, a conclusion function
assigning to each proof the formula it proves, and a natural-number size
measure. The *provable set* `Prov P = range concl` is the set of theorems of `P`.

The main results are:

* **Lattice structure.** The disjoint-union, fibred-product, and indexed-union
  constructions realize, on the level of provable sets, the join, meet, and
  arbitrary join of the powerset lattice (`prov_union`, `prov_meet`,
  `prov_iUnion`). Together with `prov_setSys` (every set of formulas is the
  provable set of *some* system) this is the **duality** between proof systems
  modulo simulation and subsets of `F`.

* **Maximality of complete systems.** Any complete system simulates every sound
  system (`complete_simulates_all_sound`) — the abstract heart of the
  Cook–Reckhow "optimality" phenomenon.

* **Polynomial boundedness is closed under joins.** The disjoint union of two
  p-bounded systems is p-bounded (`union_pBounded`), and — the quantitative
  flagship — the indexed union of *finitely many* p-bounded systems is p-bounded
  (`iUnion_pBounded`). This formalizes Future Direction #1 (the lattice join
  lifts to the polynomial setting).

All proofs are `sorry`-free.
-/
import Mathlib

open Set

namespace ProofSystemCollapse

variable {F : Type}

/-- A propositional proof system over a formula type `F`: an abstract type of
proofs `Proof`, a conclusion map `concl`, and a size measure `size`. -/
structure ProofSys (F : Type) where
  /-- The (abstract) type of proofs. -/
  Proof : Type
  /-- The formula proved by a given proof. -/
  concl : Proof → F
  /-- The size of a proof. -/
  size : Proof → ℕ

/-- The set of theorems (provable formulas) of a proof system. -/
def Prov (P : ProofSys F) : Set F := Set.range P.concl

@[simp] theorem mem_prov {P : ProofSys F} {f : F} :
    f ∈ Prov P ↔ ∃ p : P.Proof, P.concl p = f := Iff.rfl

/-! ## The simulation preorder -/

/-- `Simulates Q P` ("`Q` simulates `P`") holds when every theorem of `P` is a
theorem of `Q`. This is the qualitative core of polynomial simulation. -/
def Simulates (Q P : ProofSys F) : Prop := Prov P ⊆ Prov Q

/-- Simulation is reflexive. -/
theorem simulates_refl (P : ProofSys F) : Simulates P P := le_refl _

/-- Simulation is transitive. -/
theorem simulates_trans {P Q R : ProofSys F}
    (h₁ : Simulates R Q) (h₂ : Simulates Q P) : Simulates R P :=
  h₂.trans h₁

/-- Two systems are simulation-equivalent iff they have the same theorems. -/
def SimEquiv (P Q : ProofSys F) : Prop := Simulates P Q ∧ Simulates Q P

theorem simEquiv_iff_prov_eq {P Q : ProofSys F} :
    SimEquiv P Q ↔ Prov P = Prov Q := by
  constructor
  · rintro ⟨h₁, h₂⟩; exact le_antisymm h₂ h₁
  · intro h; exact ⟨h.ge, h.le⟩

/-! ## Lattice constructions -/

/-- The disjoint union of two proof systems: a proof is a proof in either
component. On provable sets this is the lattice **join**. -/
def union (P Q : ProofSys F) : ProofSys F where
  Proof := P.Proof ⊕ Q.Proof
  concl := Sum.elim P.concl Q.concl
  size := Sum.elim P.size Q.size

/-- The fibred product ("meet") of two proof systems: a proof is a pair of proofs
of the *same* formula. On provable sets this is the lattice **meet**. -/
def meet (P Q : ProofSys F) : ProofSys F where
  Proof := {pq : P.Proof × Q.Proof // P.concl pq.1 = Q.concl pq.2}
  concl := fun pq => P.concl pq.val.1
  size := fun pq => P.size pq.val.1 + Q.size pq.val.2

/-- The indexed disjoint union of a family of proof systems. On provable sets
this is the **arbitrary join** of the powerset lattice. -/
def iUnion {ι : Type} (P : ι → ProofSys F) : ProofSys F where
  Proof := Σ i, (P i).Proof
  concl := fun p => (P p.1).concl p.2
  size := fun p => (P p.1).size p.2

/-- The trivial one-theorem system proving exactly `f`. -/
def singletonSys (f : F) : ProofSys F where
  Proof := Unit
  concl := fun _ => f
  size := fun _ => 0

/-- The "tautology table" system whose theorems are exactly the prescribed set
`S`: a proof *is* an element of `S`. -/
def setSys (S : Set F) : ProofSys F where
  Proof := S
  concl := Subtype.val
  size := fun _ => 0

/-- **Join.** The provable set of a disjoint union is the union of the provable
sets. -/
-- !-- `range (Sum.elim f g) = range f ∪ range g`. -- !--
theorem prov_union (P Q : ProofSys F) :
    Prov (union P Q) = Prov P ∪ Prov Q := by
  ext f
  simp only [Prov, union, mem_range, Set.mem_union]
  constructor
  · rintro ⟨p, rfl⟩
    cases p with
    | inl a => exact Or.inl ⟨a, rfl⟩
    | inr b => exact Or.inr ⟨b, rfl⟩
  · rintro (⟨a, rfl⟩ | ⟨b, rfl⟩)
    · exact ⟨Sum.inl a, rfl⟩
    · exact ⟨Sum.inr b, rfl⟩

/-- **Meet.** The provable set of the fibred product is the intersection of the
provable sets. -/
-- !-- A formula has a proof in `meet P Q` iff it is provable in both `P` and `Q`. -- !--
theorem prov_meet (P Q : ProofSys F) :
    Prov (meet P Q) = Prov P ∩ Prov Q := by
  ext f
  simp only [Prov, meet, mem_range, Set.mem_inter_iff]
  constructor
  · rintro ⟨⟨⟨a, b⟩, hab⟩, rfl⟩
    exact ⟨⟨a, rfl⟩, ⟨b, hab.symm⟩⟩
  · rintro ⟨⟨a, rfl⟩, ⟨b, hb⟩⟩
    exact ⟨⟨(a, b), hb.symm⟩, rfl⟩

/-- **Arbitrary join.** The provable set of an indexed union is the union of the
provable sets. -/
-- !-- A formula is provable in `iUnion P` iff it is provable in some `P i`. -- !--
theorem prov_iUnion {ι : Type} (P : ι → ProofSys F) :
    Prov (iUnion P) = ⋃ i, Prov (P i) := by
  ext f
  simp only [Prov, iUnion, mem_range, Set.mem_iUnion]
  constructor
  · rintro ⟨⟨i, p⟩, rfl⟩
    exact ⟨i, p, rfl⟩
  · rintro ⟨i, p, rfl⟩
    exact ⟨⟨i, p⟩, rfl⟩

/-- The singleton system proves exactly its formula. -/
@[simp] theorem prov_singletonSys (f : F) : Prov (singletonSys f) = {f} := by
  simp only [Prov, singletonSys, Set.range_const]

/-- **Duality / surjectivity.** Every set of formulas is realized as the provable
set of some proof system. Hence `Prov` is a surjection onto `Set F`, and the
poset of proof systems modulo simulation is the full powerset lattice of `F`. -/
-- !-- `setSys S` has `range Subtype.val = S` as its provable set. -- !--
theorem prov_setSys (S : Set F) : Prov (setSys S) = S := by
  simp only [Prov, setSys]
  exact Subtype.range_coe

theorem prov_surjective : Function.Surjective (Prov : ProofSys F → Set F) :=
  fun S => ⟨setSys S, prov_setSys S⟩

/-! ## Universal properties of join and meet -/

/-- The join simulates its left component. -/
theorem union_simulates_left (P Q : ProofSys F) : Simulates (union P Q) P := by
  rw [Simulates, prov_union]; exact Set.subset_union_left

/-- The join simulates its right component. -/
theorem union_simulates_right (P Q : ProofSys F) : Simulates (union P Q) Q := by
  rw [Simulates, prov_union]; exact Set.subset_union_right

/-- The join is the least system simulating both components. -/
theorem union_is_lub {P Q R : ProofSys F}
    (hP : Simulates R P) (hQ : Simulates R Q) : Simulates R (union P Q) := by
  rw [Simulates, prov_union]; exact Set.union_subset hP hQ

/-- The meet is simulated by its left component. -/
theorem meet_simulated_by_left (P Q : ProofSys F) : Simulates P (meet P Q) := by
  rw [Simulates, prov_meet]; exact Set.inter_subset_left

/-- The meet is the greatest system simulated by both components. -/
theorem meet_is_glb {P Q R : ProofSys F}
    (hP : Simulates P R) (hQ : Simulates Q R) : Simulates (meet P Q) R := by
  rw [Simulates, prov_meet]; exact Set.subset_inter hP hQ

/-! ## Soundness, completeness, and maximality -/

/-- A system is *sound* for a validity predicate `Valid` when all its theorems
are valid. -/
def Sound (Valid : F → Prop) (P : ProofSys F) : Prop := ∀ f ∈ Prov P, Valid f

/-- A system is *complete* for `Valid` when all valid formulas are theorems. -/
def Complete (Valid : F → Prop) (P : ProofSys F) : Prop := ∀ f, Valid f → f ∈ Prov P

/-- **Maximality of complete systems.** A complete system simulates every sound
system. This is the abstract Cook–Reckhow optimality phenomenon: completeness
forces a system to sit at the top of the simulation order among all sound
systems. -/
-- !-- `Prov P ⊆ Valid ⊆ Prov Q` by soundness of `P` and completeness of `Q`. -- !--
theorem complete_simulates_all_sound {Valid : F → Prop} {P Q : ProofSys F}
    (hQ : Complete Valid Q) (hP : Sound Valid P) : Simulates Q P := by
  intro f hf
  exact hQ f (hP f hf)

/-! ## Polynomial boundedness -/

/-- A system is *p-bounded* with respect to a formula-complexity measure
`cx : F → ℕ` when there are constants `c, k` such that every theorem `f` has a
proof of size at most `c · (cx f + 1)^k`. -/
def PBounded (cx : F → ℕ) (P : ProofSys F) : Prop :=
  ∃ c k : ℕ, ∀ f ∈ Prov P, ∃ p : P.Proof, P.concl p = f ∧ P.size p ≤ c * (cx f + 1) ^ k

/-- The "table" system `setSys S` is p-bounded (every proof has size `0`). -/
theorem setSys_pBounded (cx : F → ℕ) (S : Set F) : PBounded cx (setSys S) := by
  refine ⟨0, 0, ?_⟩
  intro f hf
  rw [prov_setSys] at hf
  exact ⟨⟨f, hf⟩, rfl, by simp [setSys]⟩

/-- **Join preserves p-boundedness.** The disjoint union of two p-bounded systems
is p-bounded, with the larger exponent and the sum of constants. -/
-- !-- Take `c = c₁ + c₂`, `k = max k₁ k₂`; embed the smaller-system proof and
--    bound `(cx f+1)^kᵢ ≤ (cx f+1)^k` via `Nat.pow_le_pow_right`. -- !--
theorem union_pBounded {cx : F → ℕ} {P Q : ProofSys F}
    (hP : PBounded cx P) (hQ : PBounded cx Q) : PBounded cx (union P Q) := by
  obtain ⟨c₁, k₁, h₁⟩ := hP
  obtain ⟨c₂, k₂, h₂⟩ := hQ
  refine ⟨c₁ + c₂, max k₁ k₂, ?_⟩
  intro f hf
  rw [prov_union] at hf
  have hb : 1 ≤ cx f + 1 := Nat.succ_le_succ (Nat.zero_le _)
  rcases hf with hfP | hfQ
  · obtain ⟨p, hp, hps⟩ := h₁ f hfP
    refine ⟨Sum.inl p, hp, ?_⟩
    calc P.size p ≤ c₁ * (cx f + 1) ^ k₁ := hps
      _ ≤ (c₁ + c₂) * (cx f + 1) ^ max k₁ k₂ := by
          apply Nat.mul_le_mul (Nat.le_add_right _ _)
          exact Nat.pow_le_pow_right hb (le_max_left _ _)
  · obtain ⟨q, hq, hqs⟩ := h₂ f hfQ
    refine ⟨Sum.inr q, hq, ?_⟩
    calc Q.size q ≤ c₂ * (cx f + 1) ^ k₂ := hqs
      _ ≤ (c₁ + c₂) * (cx f + 1) ^ max k₁ k₂ := by
          apply Nat.mul_le_mul (Nat.le_add_left _ _)
          exact Nat.pow_le_pow_right hb (le_max_right _ _)

/-- **Quantitative flagship (Future Direction #1).** The indexed union of
*finitely many* p-bounded proof systems is p-bounded. The uniform constants are
obtained as the finite suprema of the per-system constants. -/
-- !-- Choose `cf i, kf i` per system, set `c = sup cf`, `k = sup kf`; for `f`
--    provable in `iUnion`, it is provable in some `P i`, and the embedded proof
--    is bounded since `cf i ≤ c`, `kf i ≤ k`. -- !--
theorem iUnion_pBounded {m : ℕ} {cx : F → ℕ} (P : Fin m → ProofSys F)
    (h : ∀ i, PBounded cx (P i)) : PBounded cx (iUnion P) := by
  choose cf kf hpf using h
  refine ⟨Finset.univ.sup cf, Finset.univ.sup kf, ?_⟩
  intro f hf
  rw [prov_iUnion] at hf
  rw [Set.mem_iUnion] at hf
  obtain ⟨i, hfi⟩ := hf
  obtain ⟨p, hp, hps⟩ := hpf i f hfi
  refine ⟨⟨i, p⟩, hp, ?_⟩
  have hb : 1 ≤ cx f + 1 := Nat.succ_le_succ (Nat.zero_le _)
  have hci : cf i ≤ Finset.univ.sup cf := Finset.le_sup (Finset.mem_univ i)
  have hki : kf i ≤ Finset.univ.sup kf := Finset.le_sup (Finset.mem_univ i)
  show (P i).size p ≤ _
  calc (P i).size p ≤ cf i * (cx f + 1) ^ kf i := hps
    _ ≤ Finset.univ.sup cf * (cx f + 1) ^ Finset.univ.sup kf := by
        apply Nat.mul_le_mul hci
        exact Nat.pow_le_pow_right hb hki

/-! ## Examples -/

/-- The empty proof system (`setSys ∅`) proves nothing. -/
example : Prov (setSys (∅ : Set F)) = (∅ : Set F) := prov_setSys ∅

/-- A complete system for the trivial (always-valid) predicate proves everything
and therefore simulates every system. -/
example (P Q : ProofSys F) (hQ : Complete (fun _ => True) Q) : Simulates Q P :=
  complete_simulates_all_sound hQ (fun _ _ => trivial)

/-- Concrete instance: over `F = ℕ`, the union of the singleton systems for `0`
and `1` proves exactly `{0, 1}`. -/
example : Prov (union (singletonSys (0 : ℕ)) (singletonSys 1)) = {0, 1} := by
  rw [prov_union, prov_singletonSys, prov_singletonSys]
  rfl

end ProofSystemCollapse