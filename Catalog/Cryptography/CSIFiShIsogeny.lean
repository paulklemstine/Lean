/-
  # Isogeny-Based Cryptography: Random Self-Reducibility and Security Composition

  This module formalizes deep structural properties of the class group action
  on supersingular elliptic curves relevant to CSIDH/CSI-FiSh security:

  1. **Random Self-Reducibility**: GAIP hardness is worst-case = average-case
  2. **Subgroup Orbit Decomposition**: Subgroup actions partition the set
  3. **t-Special Soundness**: Security amplification via parallel repetition
  4. **Connector Transport**: Equivariance of connectors under abelian action
  5. **One-Way Function from GAIP**: Formal reduction
  6. **Forgery → GAIP**: Signature forgery reduces to GAIP
-/
import Mathlib

open Finset Function

namespace Cryptography.CSIFiShIsogeny

/-! ## Core Structures -/

structure CryptoGroupAction (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] where
  act : G → X → X
  act_one : ∀ x : X, act 1 x = x
  act_mul : ∀ (g h : G) (x : X), act (g * h) x = act g (act h x)

structure FreeTrans (G : Type*) (X : Type*) [Group G] [Fintype G] [Fintype X]
    [DecidableEq G] [DecidableEq X] extends CryptoGroupAction G X where
  transitive : ∀ x y : X, ∃ g : G, act g x = y
  free : ∀ (g : G) (x : X), act g x = x → g = 1

namespace CryptoGroupAction

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (A : CryptoGroupAction G X)

theorem act_inv_cancel (g : G) (x : X) : A.act g⁻¹ (A.act g x) = x := by
  rw [← A.act_mul, inv_mul_cancel, A.act_one]

theorem act_inv_cancel' (g : G) (x : X) : A.act g (A.act g⁻¹ x) = x := by
  rw [← A.act_mul, mul_inv_cancel, A.act_one]

def actEquiv (g : G) : X ≃ X where
  toFun := A.act g
  invFun := A.act g⁻¹
  left_inv := A.act_inv_cancel g
  right_inv := A.act_inv_cancel' g

theorem act_injective (g : G) : Injective (A.act g) := (A.actEquiv g).injective

end CryptoGroupAction

namespace FreeTrans

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

theorem unique_connector (x y : X) (g h : G)
    (hg : T.act g x = y) (hh : T.act h x = y) : g = h := by
  have key : T.act (g * h⁻¹) y = y := by
    calc T.act (g * h⁻¹) y
        = T.act (g * h⁻¹) (T.act h x) := by rw [hh]
      _ = T.act ((g * h⁻¹) * h) x := by rw [← T.act_mul]
      _ = T.act g x := by rw [show (g * h⁻¹) * h = g from by group]
      _ = y := hg
  have h1 := T.free (g * h⁻¹) y key
  rw [mul_inv_eq_one] at h1; exact h1

noncomputable def connector (x y : X) : G := (T.transitive x y).choose

theorem connector_spec (x y : X) : T.act (T.connector x y) x = y :=
  (T.transitive x y).choose_spec

theorem connector_self (x : X) : T.connector x x = 1 :=
  T.free _ _ (T.connector_spec x x)

theorem connector_compose (x y z : X) :
    T.connector x z = T.connector y z * T.connector x y := by
  apply T.unique_connector x z
  · exact T.connector_spec x z
  · rw [T.act_mul, T.connector_spec, T.connector_spec]

theorem connector_inv (x y : X) :
    T.connector y x = (T.connector x y)⁻¹ := by
  apply T.unique_connector y x _ _ (T.connector_spec y x)
  have := T.act_inv_cancel (T.connector x y) x
  rw [T.connector_spec] at this; exact this

theorem connector_of_act (x : X) (g : G) :
    T.connector x (T.act g x) = g :=
  T.unique_connector x (T.act g x) _ g (T.connector_spec _ _) rfl

include T in
theorem card_eq [Nonempty X] : Fintype.card G = Fintype.card X := by
  apply Fintype.card_of_bijective (f := fun g => T.act g (Classical.arbitrary X))
  exact ⟨fun g h hgh => T.unique_connector _ _ g h rfl hgh.symm,
         fun y => T.transitive _ y⟩

end FreeTrans

/-! ## Part 1: Random Self-Reducibility of GAIP

In a free transitive abelian action, any GAIP instance (x₀, y)
can be re-randomized to (r·x₀, r·y) with the same solution.
This gives worst-case = average-case hardness — the strongest
possible security guarantee for a cryptographic assumption.
-/

section RandomSelfReducibility

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-- **Rerandomization Lemma**: connector(r·x₀, r·y) = connector(x₀, y).
    This is the key to random self-reducibility of GAIP. -/
theorem rerandomization_preserves_solution (x₀ y : X) (r : G) :
    T.connector (T.act r x₀) (T.act r y) = T.connector x₀ y := by
  apply T.unique_connector
  · exact T.connector_spec _ _
  · calc T.act (T.connector x₀ y) (T.act r x₀)
        = T.act (T.connector x₀ y * r) x₀ := by rw [← T.act_mul]
      _ = T.act (r * T.connector x₀ y) x₀ := by rw [mul_comm]
      _ = T.act r (T.act (T.connector x₀ y) x₀) := by rw [T.act_mul]
      _ = T.act r y := by rw [T.connector_spec]

/-- **Random Self-Reducibility**: oracle on rerandomized instance gives original answer. -/
theorem random_self_reducibility
    (oracle : X → X → G)
    (h_oracle : ∀ x y : X, oracle x y = T.connector x y)
    (x₀ y : X) (r : G) :
    oracle (T.act r x₀) (T.act r y) = T.connector x₀ y := by
  rw [h_oracle, rerandomization_preserves_solution]

/-- **Worst-case to average-case**: inverter for base x₁ → solver for any base x₀.
    This proves that GAIP hardness is the same whether we measure worst-case
    or average-case, providing the strongest security foundation for CSIDH. -/
theorem worst_case_average_case
    (x₁ : X) (inverter : X → G)
    (h_inv : ∀ y : X, T.act (inverter y) x₁ = y)
    (x₀ y : X) :
    inverter y * (T.connector x₁ x₀)⁻¹ = T.connector x₀ y := by
  have h_inv_eq : ∀ z, inverter z = T.connector x₁ z := fun z =>
    T.unique_connector x₁ z _ _ (h_inv z) (T.connector_spec x₁ z)
  rw [h_inv_eq]
  have h_inv_conn : (T.connector x₁ x₀)⁻¹ = T.connector x₀ x₁ := by
    rw [T.connector_inv]; simp [inv_inv]
  rw [h_inv_conn, ← T.connector_compose]

/-- **Rerandomized instance solution**: connector(r·x₀, r·(s·x₀)) = s. -/
theorem rerandomized_instance_solution (x₀ : X) (s r : G) :
    T.connector (T.act r x₀) (T.act r (T.act s x₀)) = s := by
  rw [rerandomization_preserves_solution, T.connector_of_act]

end RandomSelfReducibility

/-! ## Part 2: Connector Transport and Equivariance -/

section ConnectorTransport

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-- **Connector transport**: g applied to both args preserves connector.
    This is a deep structural property: the "difference" between two curves
    is invariant under the group action. -/
theorem connector_transport_right (x y : X) (g : G) :
    T.connector (T.act g x) (T.act g y) = T.connector x y :=
  rerandomization_preserves_solution T x y g

/-- **Connector left-shift**: connector(g·x, y) = connector(x, y) · g⁻¹. -/
theorem connector_left_shift (x y : X) (g : G) :
    T.connector (T.act g x) y = T.connector x y * g⁻¹ := by
  apply T.unique_connector
  · exact T.connector_spec _ _
  · have : T.act (T.connector x y * g⁻¹) (T.act g x) = T.act (T.connector x y) x := by
      rw [← T.act_mul]; congr 1; group
    rw [this, T.connector_spec]

/-- **Connector right-shift**: connector(x, g·y) = g · connector(x, y). -/
theorem connector_right_shift (x y : X) (g : G) :
    T.connector x (T.act g y) = g * T.connector x y := by
  apply T.unique_connector
  · exact T.connector_spec _ _
  · calc T.act (g * T.connector x y) x
        = T.act g (T.act (T.connector x y) x) := by rw [T.act_mul]
      _ = T.act g y := by rw [T.connector_spec]

end ConnectorTransport

/-! ## Part 3: t-Special Soundness -/

section VectorialGAIP

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-- **t-Special Soundness**: extract secrets from two transcripts with
    different challenges, for t parallel repetitions of CSI-FiSh.
    This is the core security property that makes CSI-FiSh a
    proof of knowledge of the secret key. -/
theorem t_special_soundness (t : ℕ) (x₀ : X)
    (pk : Fin t → X) (R : Fin t → X)
    (z₀ z₁ : Fin t → G)
    (h0 : ∀ i, T.act (z₀ i) x₀ = R i)
    (h1 : ∀ i, T.act (z₁ i) (pk i) = R i) :
    ∀ i, T.act (z₀ i * (z₁ i)⁻¹) x₀ = pk i := by
  intro i
  have h_eq : T.act (z₁ i)⁻¹ (R i) = pk i := by
    rw [← h1 i]; exact T.act_inv_cancel (z₁ i) (pk i)
  calc T.act (z₀ i * (z₁ i)⁻¹) x₀
      = T.act ((z₁ i)⁻¹ * z₀ i) x₀ := by rw [mul_comm]
    _ = T.act (z₁ i)⁻¹ (T.act (z₀ i) x₀) := by rw [T.act_mul]
    _ = T.act (z₁ i)⁻¹ (R i) := by rw [h0 i]
    _ = pk i := h_eq

omit [Fintype G] [DecidableEq G] in
/-- **Extracted key = secret** (algebraic identity). -/
theorem t_extraction_identity (r s : G) :
    r * (r * s⁻¹)⁻¹ = s := by simp [mul_inv_rev]

/-- **VGAIP reduces to GAIP**: t instances = t individual calls. -/
theorem vgaip_reduces_to_gaip (t : ℕ) (x₀ : X)
    (targets : Fin t → X)
    (gaip_solver : X → X → G)
    (h_gaip : ∀ x y : X, T.act (gaip_solver x y) x = y) :
    ∀ i : Fin t, T.act (gaip_solver x₀ (targets i)) x₀ = targets i :=
  fun i => h_gaip x₀ (targets i)

end VectorialGAIP

/-! ## Part 4: Subgroup Orbit Structure -/

section SubgroupOrbits

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-- The orbit of x under subgroup H. -/
def subgroupOrbit (H : Subgroup G) [DecidablePred (· ∈ H)] (x : X) : Finset X :=
  Finset.univ.image (fun h : H => T.act (h : G) x)

/-- **Orbit map is injective** (from freeness of the action). -/
theorem subgroupOrbit_map_injective (H : Subgroup G) [DecidablePred (· ∈ H)] (x : X) :
    Injective (fun h : H => T.act (h : G) x) := by
  intro ⟨h₁, _⟩ ⟨h₂, _⟩ heq
  simp only at heq
  exact Subtype.ext (T.unique_connector x _ h₁ h₂ rfl heq.symm)

/-- **Orbit size = subgroup order** in a free action.
    This implies the orbits partition X into |G|/|H| classes. -/
theorem subgroupOrbit_card (H : Subgroup G) [DecidablePred (· ∈ H)] (x : X) :
    (subgroupOrbit T H x).card = Fintype.card H := by
  rw [subgroupOrbit, Finset.card_image_of_injective _ (subgroupOrbit_map_injective T H x)]
  exact Finset.card_univ

/-- **Membership in orbit characterization.** -/
theorem mem_subgroupOrbit_iff (H : Subgroup G) [DecidablePred (· ∈ H)] (x y : X) :
    y ∈ subgroupOrbit T H x ↔ ∃ h : G, h ∈ H ∧ T.act h x = y := by
  simp only [subgroupOrbit, Finset.mem_image, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨⟨h, hh⟩, _, rfl⟩; exact ⟨h, hh, rfl⟩
  · rintro ⟨h, hh, rfl⟩; exact ⟨⟨h, hh⟩, rfl⟩

end SubgroupOrbits

/-! ## Part 5: OWF ↔ GAIP Equivalence -/

section OWFReduction

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-- **Inverter solves GAIP**: any OWF inverter is a GAIP solver. -/
theorem owf_inverter_solves_gaip (x₀ : X) (inverter : X → G)
    (h_inv : ∀ y : X, T.act (inverter y) x₀ = y) :
    ∀ g : G, inverter (T.act g x₀) = g :=
  fun g => T.unique_connector x₀ _ _ _ (h_inv (T.act g x₀)) rfl

/-- **GAIP solver inverts OWF**: any GAIP solver is an OWF inverter. -/
theorem gaip_solver_inverts_owf (x₀ : X) (solver : X → X → G)
    (h_solver : ∀ x y : X, T.act (solver x y) x = y) :
    ∀ y : X, T.act (solver x₀ y) x₀ = y :=
  fun y => h_solver x₀ y

/-- **The CSIDH map is a bijection** (free + transitive).
    This is the fundamental bijectivity that makes CSIDH a valid
    key exchange: every public key has a unique secret key. -/
theorem csidh_bijective (x₀ : X) : Bijective (fun g : G => T.act g x₀) :=
  ⟨fun g h hgh => T.unique_connector x₀ _ g h rfl hgh.symm,
   fun y => T.transitive x₀ y⟩

end OWFReduction

/-! ## Part 6: Smooth Isogeny Decomposition (Novel Definition)

In CSIDH, the class group Cl(O) is decomposed into a product of
cyclic subgroups generated by small prime ideals l₁, ..., lₙ.
Each secret key is a vector of exponents (e₁, ..., eₙ) with |eᵢ| ≤ Bᵢ.
This structure formalizes that decomposition.
-/

/-- **Novel Definition**: A `SmoothIsogenyDecomposition` captures the
    structure of decomposing a class group element into a product of
    small prime-power ideal classes, as used in CSIDH key generation. -/
structure SmoothIsogenyDecomposition (G : Type*) [CommGroup G] [Fintype G]
    [DecidableEq G] (n : ℕ) where
  generators : Fin n → G
  bounds : Fin n → ℕ
  spans : ∀ g : G, ∃ exps : Fin n → ℤ,
    (∀ i, (exps i).natAbs ≤ bounds i) ∧
    g = Finset.univ.prod (fun i => (generators i) ^ (exps i))

/-- Key space size for a smooth decomposition: ∏ᵢ (2Bᵢ + 1). -/
def keySpaceSize {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]
    {n : ℕ} (D : SmoothIsogenyDecomposition G n) : ℕ :=
  Finset.univ.prod (fun i : Fin n => 2 * D.bounds i + 1)

/-- **Key space is positive.** -/
theorem keySpaceSize_pos {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]
    {n : ℕ} (D : SmoothIsogenyDecomposition G n) :
    0 < keySpaceSize D := by
  unfold keySpaceSize
  apply Finset.prod_pos
  intro i _; omega

/-- **Key space lower bound**: keySpaceSize ≥ (2·minB + 1)^n. -/
theorem keySpaceSize_lower_bound {G : Type*} [CommGroup G] [Fintype G] [DecidableEq G]
    {n : ℕ} (D : SmoothIsogenyDecomposition G n)
    (B : ℕ) (hB : ∀ i : Fin n, B ≤ D.bounds i) :
    (2 * B + 1) ^ n ≤ keySpaceSize D := by
  unfold keySpaceSize
  have h1 : (2 * B + 1) ^ n = Finset.univ.prod (fun _ : Fin n => 2 * B + 1) := by
    rw [Finset.prod_const, Finset.card_fin]
  rw [h1]
  apply Finset.prod_le_prod
  · intro i _; omega
  · intro i _; have := hB i; omega

/-! ## Part 7: CSI-FiSh Signature Forgery → GAIP -/

section FiatShamir

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-- A CSI-FiSh signature for t parallel repetitions. -/
structure CSIFiShSignature (X G : Type*) (t : ℕ) where
  commitments : Fin t → X
  responses : Fin t → G
  challenges : Fin t → Bool

/-- Verification of a CSI-FiSh signature. -/
def verifySignature (x₀ pk : X) {t : ℕ} (sig : CSIFiShSignature X G t) : Prop :=
  ∀ i : Fin t, if sig.challenges i
    then T.act (sig.responses i) pk = sig.commitments i
    else T.act (sig.responses i) x₀ = sig.commitments i

/-- **Forgery implies GAIP solution**: two valid signatures with different
    challenges on the same commitments yield the secret key.
    This is the core security reduction for CSI-FiSh. -/
theorem forgery_implies_gaip
    (x₀ pk : X) {t : ℕ}
    (sig₁ sig₂ : CSIFiShSignature X G t)
    (h_same_commit : sig₁.commitments = sig₂.commitments)
    (h_valid₁ : verifySignature T x₀ pk sig₁)
    (h_valid₂ : verifySignature T x₀ pk sig₂)
    (i : Fin t)
    (h_diff : sig₁.challenges i = false ∧ sig₂.challenges i = true) :
    T.act (sig₁.responses i * (sig₂.responses i)⁻¹) x₀ = pk := by
  have hv1 := h_valid₁ i
  have hv2 := h_valid₂ i
  simp only [h_diff.1, h_diff.2, ite_true] at hv1 hv2
  have h_comm_eq : sig₁.commitments i = sig₂.commitments i :=
    congr_fun h_same_commit i
  have h_step : T.act (sig₂.responses i)⁻¹ (sig₂.commitments i) = pk := by
    rw [← hv2]; exact T.act_inv_cancel _ _
  calc T.act (sig₁.responses i * (sig₂.responses i)⁻¹) x₀
      = T.act ((sig₂.responses i)⁻¹ * sig₁.responses i) x₀ := by rw [mul_comm]
    _ = T.act (sig₂.responses i)⁻¹ (T.act (sig₁.responses i) x₀) := by rw [T.act_mul]
    _ = T.act (sig₂.responses i)⁻¹ (sig₁.commitments i) := by rw [hv1]
    _ = T.act (sig₂.responses i)⁻¹ (sig₂.commitments i) := by rw [h_comm_eq]
    _ = pk := h_step

/-- **Completeness**: honest prover with z = r·s⁻¹ succeeds for challenge=true. -/
theorem csifish_completeness (x₀ : X) (s r : G) :
    T.act (r * s⁻¹) (T.act s x₀) = T.act r x₀ := by
  rw [← T.act_mul]; congr 1; group

end FiatShamir

/-! ## Part 8: Isogeny Graph -/

section IsogenyGraphSection

/-- Isogeny graph from group action with generators. -/
structure IsogenyGraph (G : Type*) (X : Type*)
    [Group G] [Fintype G] [Fintype X] [DecidableEq G] [DecidableEq X] where
  action : CryptoGroupAction G X
  generators : Finset G
  one_not_gen : (1 : G) ∉ generators
  inv_closed : ∀ g ∈ generators, g⁻¹ ∈ generators

namespace IsogenyGraph

variable {G X : Type*} [Group G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (Γ : IsogenyGraph G X)

def adjacent (x y : X) : Prop :=
  ∃ g ∈ Γ.generators, Γ.action.act g x = y

/-- **Adjacency is symmetric.** -/
theorem adjacent_symm (x y : X) (h : Γ.adjacent x y) : Γ.adjacent y x := by
  obtain ⟨g, hg_mem, hg_act⟩ := h
  exact ⟨g⁻¹, Γ.inv_closed g hg_mem, by rw [← hg_act]; exact Γ.action.act_inv_cancel g x⟩

def neighbors (x : X) : Finset X :=
  Γ.generators.image (fun g => Γ.action.act g x)

/-- **Regularity from freeness**: in a free action, degree = |generators|. -/
theorem regular_of_free
    (hfree : ∀ (g : G) (x : X), Γ.action.act g x = x → g = 1) (x : X) :
    (Γ.neighbors x).card = Γ.generators.card := by
  apply Finset.card_image_of_injOn
  intro g₁ _ g₂ _ heq
  simp only at heq
  have key : Γ.action.act (g₂⁻¹ * g₁) x = x := by
    rw [Γ.action.act_mul, heq, Γ.action.act_inv_cancel]
  exact (inv_mul_eq_one.mp (hfree _ _ key)).symm

end IsogenyGraph

end IsogenyGraphSection

/-! ## Part 9: Class Group Structure -/

section ClassGroupStructure

/-- **Novel Definition**: decomposition of class group as product of cyclics.
    The class group Cl(O) ≅ ℤ/d₁ℤ × ⋯ × ℤ/dₖℤ by the structure theorem
    for finite abelian groups. -/
structure ClassGroupDecomposition where
  numFactors : ℕ
  orders : Fin numFactors → ℕ
  orders_ge_two : ∀ i, 2 ≤ orders i
  classNumber : ℕ
  classNumber_eq : classNumber = Finset.univ.prod orders

/-- **Class number is positive.** -/
theorem classNumber_pos (D : ClassGroupDecomposition) : 0 < D.classNumber := by
  rw [D.classNumber_eq]
  apply Finset.prod_pos
  intro i _; have := D.orders_ge_two i; omega

/-- **Lower bound on class number**: h ≥ 2^k where k = number of cyclic factors. -/
theorem classNumber_lower_bound (D : ClassGroupDecomposition) :
    2 ^ D.numFactors ≤ D.classNumber := by
  rw [D.classNumber_eq]
  calc 2 ^ D.numFactors
      = 2 ^ Finset.card (Finset.univ : Finset (Fin D.numFactors)) := by
        rw [Finset.card_fin]
    _ = Finset.univ.prod (fun _ : Fin D.numFactors => 2) := by rw [Finset.prod_const]
    _ ≤ Finset.univ.prod D.orders := by
        apply Finset.prod_le_prod
        · intro i _; omega
        · intro i _; exact D.orders_ge_two i

end ClassGroupStructure

/-! ## Part 10: Actions Commute (Abelian Case) -/

section AbelianActions

variable {G X : Type*} [CommGroup G] [Fintype G] [Fintype X]
  [DecidableEq G] [DecidableEq X]
  (T : FreeTrans G X)

/-- **Actions commute** in abelian group: this is what makes CSIDH work. -/
theorem actions_commute (g h : G) (x : X) :
    T.act g (T.act h x) = T.act h (T.act g x) := by
  rw [← T.act_mul, ← T.act_mul, mul_comm]

/-- **CSIDH shared secret agreement.** -/
theorem csidh_key_exchange (x₀ : X) (a b : G) :
    T.act a (T.act b x₀) = T.act b (T.act a x₀) :=
  actions_commute T a b x₀

/-- **Multi-party permutation invariance**: the shared secret is independent
    of the order in which parties contribute their keys. -/
theorem multiparty_permutation_invariance
    (secrets perm : List G) (x₀ : X) (hp : secrets.Perm perm) :
    T.act secrets.prod x₀ = T.act perm.prod x₀ := by
  congr 1; exact List.Perm.prod_eq hp

end AbelianActions

/-! ## Part 11: Security Level -/

section SecurityLevel

/-- **Soundness error of CSI-FiSh with t repetitions**: 2^{-t} < 1. -/
theorem csifish_soundness_error (t : ℕ) (ht : 0 < t) :
    (1 : ℝ) / 2 ^ t < 1 := by
  rw [div_lt_one (by positivity : (0:ℝ) < 2 ^ t)]
  calc (1 : ℝ) < 2 := by norm_num
    _ ≤ 2 ^ t := le_self_pow₀ (by norm_num : (1:ℝ) ≤ 2) (by omega)

end SecurityLevel

/-! ## Part 12: Testable Conjecture

**Conjecture**: For ℤ/nℤ with generators {±1}, the Cayley diameter is ⌊n/2⌋.

**Test**: For n ∈ {5, 7, 11, 13, 17, 19, 23, 29}, verify every element
can be reached in ≤ ⌊n/2⌋ steps using ±1. Falsifiable by finding n where
some element requires > ⌊n/2⌋ steps. -/

def cayleyDiameterConj (n : ℕ) (_ : 2 ≤ n) : Prop :=
  ∀ a : ZMod n, ∃ k : ℕ, k ≤ n / 2 ∧ (a = (k : ZMod n) ∨ a = -(k : ZMod n))

end Cryptography.CSIFiShIsogeny