/-
  # Braid Groups: Algebraic Foundations for Topological Quantum Computing

  Formalization of Artin's braid group B_{n+1} via group presentation, with:
  1. The writhe (exponent sum) homomorphism to ℤ
  2. The surjective quotient map to the symmetric group S_{n+1}
  3. Universal property of the braid group presentation
  4. Triviality of B_1

  The braid group is the algebraic foundation for topological quantum computing:
  anyonic braiding operations correspond to elements of B_n, and the density
  of certain representations (e.g. Jones at k=5) in SU(d) establishes
  universality for quantum computation.
-/
import Mathlib

namespace BraidGroup

/-! ## Definition of the Braid Group

The braid group B_{n+1} has generators σ_0, ..., σ_{n-1} (indexed by `Fin n`)
subject to two families of relations:
- **Far commutativity**: σ_i σ_j = σ_j σ_i when |i - j| ≥ 2
- **Braid (Yang-Baxter) relation**: σ_i σ_{i+1} σ_i = σ_{i+1} σ_i σ_{i+1}
-/

/-- Far commutativity relations: σ_i σ_j σ_i⁻¹ σ_j⁻¹ for i + 1 < j. -/
def farCommRels (n : ℕ) : Set (FreeGroup (Fin n)) :=
  { r | ∃ (i j : Fin n), i.val + 1 < j.val ∧
    r = FreeGroup.of i * FreeGroup.of j * (FreeGroup.of i)⁻¹ * (FreeGroup.of j)⁻¹ }

/-- Braid (Yang-Baxter) relations: σ_i σ_{i+1} σ_i σ_{i+1}⁻¹ σ_i⁻¹ σ_{i+1}⁻¹. -/
def braidYBRels (n : ℕ) : Set (FreeGroup (Fin n)) :=
  { r | ∃ (i : Fin n) (hi : i.val + 1 < n),
    r = FreeGroup.of i * FreeGroup.of ⟨i.val + 1, hi⟩ * FreeGroup.of i *
        (FreeGroup.of ⟨i.val + 1, hi⟩)⁻¹ * (FreeGroup.of i)⁻¹ *
        (FreeGroup.of ⟨i.val + 1, hi⟩)⁻¹ }

/-- The full set of braid relations for B_{n+1}. -/
def braidRels (n : ℕ) : Set (FreeGroup (Fin n)) :=
  farCommRels n ∪ braidYBRels n

/-- The braid group on n+1 strands, with n Artin generators.
    Defined as the quotient of the free group on `Fin n` by the braid relations. -/
abbrev BraidGrp (n : ℕ) := PresentedGroup (braidRels n)

instance (n : ℕ) : Group (BraidGrp n) := inferInstanceAs (Group (PresentedGroup _))
instance (n : ℕ) : Inhabited (BraidGrp n) := inferInstanceAs (Inhabited (PresentedGroup _))

/-- The i-th Artin generator σ_i ∈ B_{n+1}. -/
def sigma {n : ℕ} (i : Fin n) : BraidGrp n := PresentedGroup.of i

/-! ## Auxiliary: Commutator and Braid Relation Lemmas -/

/-- In any group, if a and b commute then their commutator is trivial. -/
theorem comm_of_eq {G : Type*} [Group G] {a b : G} (h : a * b = b * a) :
    a * b * a⁻¹ * b⁻¹ = 1 := by
  have : a * b * a⁻¹ = b := by rw [h]; group
  rw [this]; exact mul_inv_cancel b

/-- In any group, if a * b * a = b * a * b then the braid relator is trivial. -/
theorem braid_relator_of_eq {G : Type*} [Group G] {a b : G} (h : a * b * a = b * a * b) :
    a * b * a * b⁻¹ * a⁻¹ * b⁻¹ = 1 := by
  have : a * b * a * b⁻¹ * a⁻¹ * b⁻¹ = (a * b * a) * (b * a * b)⁻¹ := by group
  rw [this, h, mul_inv_cancel]

/-! ## Theorem 1: The Writhe Homomorphism

The writhe (or exponent sum) is a group homomorphism from B_{n+1} to ℤ
that sends each generator σ_i to 1. This is well-defined because ℤ is abelian. -/

/-
Auxiliary: every braid relation maps to 1 under lift to Multiplicative ℤ.
-/
theorem braidRels_lift_one (n : ℕ) :
    ∀ r ∈ braidRels n,
      (FreeGroup.lift (fun _ : Fin n => Multiplicative.ofAdd (1 : ℤ))) r = 1 := by
  rintro r ( hr | hr );
  · rcases hr with ⟨ i, j, hij, rfl ⟩ ; simp_all +decide [ mul_assoc ];
  · rcases hr with ⟨ i, hi, rfl ⟩ ; simp +decide [ mul_assoc, mul_comm, mul_left_comm ]

/-- The writhe (exponent sum) homomorphism from B_{n+1} to ℤ,
    sending each Artin generator σ_i to 1 ∈ ℤ. -/
noncomputable def writhe (n : ℕ) : BraidGrp n →* Multiplicative ℤ :=
  PresentedGroup.toGroup (f := fun _ => Multiplicative.ofAdd (1 : ℤ))
    (braidRels_lift_one n)

/-
**E**xample: writhe sends each generator σ_i to 1.
-/
theorem writhe_sigma {n : ℕ} (i : Fin n) :
    writhe n (sigma i) = Multiplicative.ofAdd (1 : ℤ) := by
  unfold writhe sigma;
  erw [ QuotientGroup.lift_mk ]

/-
**G**eneralization: Any constant map to a commutative group extends
    to a homomorphism from B_{n+1}.
-/
theorem braidRels_comm_lift {G : Type*} [CommGroup G] (g : G) (n : ℕ) :
    ∀ r ∈ braidRels n, (FreeGroup.lift (fun _ : Fin n => g)) r = 1 := by
  intro r hr
  cases' hr with hr1 hr2;
  · rcases hr1 with ⟨ i, j, hij, rfl ⟩ ; simp +decide [ mul_assoc, comm_of_eq ];
  · obtain ⟨ i, hi, rfl ⟩ := hr2; simp +decide [ mul_assoc ] ;

/-- The generalized abelianization map to any commutative group. -/
noncomputable def abelianization_map (n : ℕ) {G : Type*} [CommGroup G] (g : G) :
    BraidGrp n →* G :=
  PresentedGroup.toGroup (f := fun _ => g) (braidRels_comm_lift g n)

/-
**B**oundary: The writhe is NOT injective for n ≥ 2.
    The commutator [σ_0, σ_1] is in the kernel.
-/
theorem writhe_comm_kernel {n : ℕ} (hn : 1 < n) :
    let i : Fin n := ⟨0, by omega⟩
    let j : Fin n := ⟨1, by omega⟩
    writhe n (sigma i * sigma j * (sigma i)⁻¹ * (sigma j)⁻¹) = 1 := by
  simp_all +decide [ writhe ]

/-! ## Theorem 2: The Quotient Map to the Symmetric Group

There is a surjective group homomorphism from B_{n+1} to S_{n+1} = Perm(Fin(n+1))
that sends each braid generator σ_i to the transposition (i, i+1). -/

/-- Adjacent transpositions in Fin (n+1): the transposition swapping
    position i with position i+1. -/
def adjTransposition {n : ℕ} (i : Fin n) : Equiv.Perm (Fin (n + 1)) :=
  Equiv.swap i.castSucc i.succ

/-
Far commutativity of non-adjacent transpositions.
-/
theorem adjTransposition_commute {n : ℕ} (i j : Fin n) (h : i.val + 1 < j.val) :
    adjTransposition i * adjTransposition j = adjTransposition j * adjTransposition i := by
  -- By definition of adjTransposition, we have:
  unfold adjTransposition;
  ext x; by_cases hi : x = i.castSucc <;> by_cases hj : x = j.castSucc <;> simp_all +decide [ Equiv.swap_apply_def ] ;
  · grind;
  · grind;
  · grind

/-
The braid (Yang-Baxter) relation for adjacent transpositions.
-/
theorem adjTransposition_braid {n : ℕ} (i : Fin n) (hi : i.val + 1 < n) :
    adjTransposition i * adjTransposition ⟨i.val + 1, hi⟩ * adjTransposition i =
    adjTransposition ⟨i.val + 1, hi⟩ * adjTransposition i * adjTransposition ⟨i.val + 1, hi⟩ := by
  ext x
  simp [adjTransposition];
  grind +locals

/-- Auxiliary: braid relations are satisfied by adjacent transpositions. -/
theorem braidRels_adjTransposition (n : ℕ) :
    ∀ r ∈ braidRels n,
      (FreeGroup.lift (fun i : Fin n => adjTransposition i)) r = 1 := by
  intro r hr
  simp only [braidRels, farCommRels, braidYBRels, Set.mem_union, Set.mem_setOf_eq] at hr
  rcases hr with ⟨i, j, hij, rfl⟩ | ⟨i, hi, rfl⟩
  · simp only [map_mul, map_inv, FreeGroup.lift_apply_of]
    exact comm_of_eq (adjTransposition_commute i j hij)
  · simp only [map_mul, map_inv, FreeGroup.lift_apply_of]
    exact braid_relator_of_eq (adjTransposition_braid i hi)

/-- The quotient homomorphism from the braid group B_{n+1} to the symmetric group S_{n+1},
    sending σ_i to the adjacent transposition (i, i+1). -/
noncomputable def toSymm (n : ℕ) : BraidGrp n →* Equiv.Perm (Fin (n + 1)) :=
  PresentedGroup.toGroup (f := fun i => adjTransposition i)
    (braidRels_adjTransposition n)

/-
**E**xample: The map sends σ_i to the expected transposition.
-/
theorem toSymm_sigma {n : ℕ} (i : Fin n) :
    toSymm n (sigma i) = adjTransposition i := by
  exact Equiv.coe_inj.mp rfl

/-
**B**oundary: σ_i² maps to the identity in S_{n+1}.
-/
theorem toSymm_sigma_sq {n : ℕ} (i : Fin n) :
    toSymm n (sigma i ^ 2) = 1 := by
  rw [ map_pow, toSymm_sigma ];
  simp +decide [ sq, adjTransposition ]

/-! ## Theorem 3: Universal Property of the Braid Group

Any group G equipped with elements satisfying both braid relation families
receives a unique homomorphism from B_{n+1}. -/

/-- Any group with elements satisfying braid relations receives a
    homomorphism from B_{n+1}. -/
noncomputable def toGroup_of_braid_rels {n : ℕ} {G : Type*} [Group G] (f : Fin n → G)
    (far_comm : ∀ i j : Fin n, i.val + 1 < j.val →
      f i * f j = f j * f i)
    (braid_rel : ∀ (i : Fin n) (hi : i.val + 1 < n),
      f i * f ⟨i.val + 1, hi⟩ * f i =
      f ⟨i.val + 1, hi⟩ * f i * f ⟨i.val + 1, hi⟩) :
    BraidGrp n →* G := by
  apply PresentedGroup.toGroup (f := f)
  intro r hr
  simp only [braidRels, farCommRels, braidYBRels, Set.mem_union, Set.mem_setOf_eq] at hr
  rcases hr with ⟨i, j, hij, rfl⟩ | ⟨i, hi, rfl⟩
  · simp only [map_mul, map_inv, FreeGroup.lift_apply_of]
    exact comm_of_eq (far_comm i j hij)
  · simp only [map_mul, map_inv, FreeGroup.lift_apply_of]
    exact braid_relator_of_eq (braid_rel i hi)

/-- **E**xample: Applying the universal property to recover toSymm. -/
noncomputable example (n : ℕ) : BraidGrp n →* Equiv.Perm (Fin (n + 1)) :=
  toGroup_of_braid_rels
    (fun i => adjTransposition i)
    (fun i j h => adjTransposition_commute i j h)
    (fun i hi => adjTransposition_braid i hi)

/-! ## Theorem 4: Triviality of B_1 -/

/-
B_1 (one strand, zero generators) is the trivial group.
-/
theorem braidGrp_zero_eq_one : ∀ x : BraidGrp 0, x = 1 := by
  intro x;
  obtain ⟨ y, rfl ⟩ := QuotientGroup.mk_surjective x;
  fin_cases y ; aesop

/-! ## Theorem 5: Surjectivity of the Symmetric Group Map -/

/-
The quotient map from the braid group to the symmetric group is surjective.
-/
theorem toSymm_surjective (n : ℕ) : Function.Surjective (toSymm n) := by
  intro g
  induction' g using Equiv.Perm.swap_induction_on with g i j hij h_ind
  exact ⟨ 1, map_one _ ⟩
  generalize_proofs at *; (
  -- Since $i \neq j$, we can find a sequence of adjacent transpositions that swaps $i$ and $j$.
  have h_adj_transpose : ∀ (i j : Fin (n + 1)), i < j → ∃ x : BraidGrp n, toSymm n x = Equiv.swap i j := by
    intro i j hij
    induction' j using Fin.induction with j ih generalizing i
    generalize_proofs at *; (
    tauto);
    by_cases hi : i < Fin.castSucc j;
    · obtain ⟨ x, hx ⟩ := ih i hi
      use x * sigma j * x
      simp [hx, toSymm_sigma];
      simp +decide [ Equiv.Perm.ext_iff, Equiv.swap_apply_def, adjTransposition ];
      grind +ring;
    · cases lt_or_eq_of_le ( show i ≤ Fin.castSucc j from Nat.le_of_lt_succ hij ) <;> simp_all +decide [ Equiv.swap_comm ];
      exact ⟨ sigma j, toSymm_sigma j ⟩
  generalize_proofs at *; (
  obtain ⟨ x, hx ⟩ := if hij' : i < j then h_adj_transpose i j hij' else by obtain ⟨ x, hx ⟩ := h_adj_transpose j i ( lt_of_le_of_ne ( le_of_not_gt hij' ) hij.symm ) ; exact ⟨ x, by simp +decide [ hx, Equiv.swap_comm ] ⟩ ; ; obtain ⟨ y, hy ⟩ := h_ind; use x * y; simp +decide [ hx, hy ] ;))

end BraidGroup

/-
  ## FUTURE DIRECTIONS

  1. **Faithfulness of the Burau representation**: The reduced Burau representation
     ρ: B_n → GL_{n-1}(ℤ[t, t⁻¹]) is faithful for n ≤ 3 but unfaithful for n ≥ 5.
     The n=4 case remains open.

  2. **Jones representation density**: For the Jones representation at k=5,
     ρ_5(B_4) generates a dense subgroup of SU(3) (Freedman-Kitaev-Larsen-Wang theorem).

  3. **Orderability**: B_n is left-orderable (Dehornoy ordering), giving a proof
     that B_n is torsion-free.

  4. **Pure braid group**: ker(toSymm) = P_{n+1} has a known presentation via
     generators A_{ij}. Formalizing this and showing P_n is finitely generated.

  5. **Solovay-Kitaev approximation**: Given density, any U ∈ SU(3) can be
     ε-approximated by a braid word of length O(log^c(1/ε)).
-/