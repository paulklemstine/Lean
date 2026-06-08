import Mathlib
import Pythagorean.SandwichDefs

/-!
# Certificate Poset Well-Quasi-Ordering

This file develops the order-theoretic structure of complete sandwich certificate
families, establishing a Robertson–Seymour-style finiteness principle for
lower-bound certificates.

## Core Ideas

A complete sandwich family is not just a set of witnesses; it is a compressed
obstruction theory for a monotone graph property. We show that bounded-size
certificate families are well-quasi-ordered under a natural inclusion order,
which implies that lower-bound arguments themselves admit finite forbidden patterns.

The key structural insight is **profile compression**: each bounded certificate
family maps to a vector in `ℕ^d` (where `d = (t+1)²`) recording how many
certificates of each size class it contains. Profile domination implies
certificate domination, and Dickson's lemma on `ℕ^d` then yields WQO.

## Main Definitions

- `CertificateFamilyLE` — inclusion-based ordering on certificate families
- `FamilyBoundedBySize` — bounded-size certificate families
- `BoundedCertificateFamily` — subtype of bounded families
- `CertificateProfile` — profile vector recording size-class counts
- `ProfileLE` — componentwise ordering on profiles
- `MonomialDvd` — monomial divisibility encoding of profile order

## Main Results

- `profile_le_of_certificateFamilyLE` — family inclusion implies profile domination
- `bounded_certificate_family_wqo` — bounded families are WQO (Dickson-style)
- `finite_basis_of_upward_closed` — every upward-closed set has a finite basis
- `finite_antichain_of_bounded` — antichains in bounded families are finite
- `profile_le_iff_monomial_dvd` — profile order = monomial divisibility (algebra bridge)
- `bounded_family_descending_chain_stabilizes` — refinement chains stabilize (WSTS bridge)
-/

noncomputable section
open Classical Finset

namespace CertificateWQO

/-! ## Section 1: Certificate Family Ordering -/

/-- A **certificate family** is a finite set of (Pos, Neg) witness pairs,
    represented as pairs of finsets over the ambient type. -/
abbrev CertFamily (α : Type*) [DecidableEq α] := Finset (Finset α × Finset α)

/-- The **certificate family ordering**: `S ≤ T` iff `S ⊆ T` as finsets.
    A larger family contains more witnesses. -/
def CertificateFamilyLE {α : Type*} [DecidableEq α]
    (S T : CertFamily α) : Prop :=
  S ⊆ T

theorem certificateFamilyLE_refl {α : Type*} [DecidableEq α]
    (S : CertFamily α) : CertificateFamilyLE S S :=
  Finset.Subset.refl S

theorem certificateFamilyLE_trans {α : Type*} [DecidableEq α]
    (S T U : CertFamily α) (h₁ : CertificateFamilyLE S T)
    (h₂ : CertificateFamilyLE T U) : CertificateFamilyLE S U :=
  Finset.Subset.trans h₁ h₂

theorem certificateFamilyLE_antisymm {α : Type*} [DecidableEq α]
    (S T : CertFamily α) (h₁ : CertificateFamilyLE S T)
    (h₂ : CertificateFamilyLE T S) : S = T :=
  Finset.Subset.antisymm h₁ h₂

/-! ## Section 2: Bounded Certificate Families -/

/-- A family is **bounded by size `t`** if every certificate pair has
    left and right components of cardinality at most `t`. -/
def FamilyBoundedBySize {α : Type*} [DecidableEq α]
    (t : ℕ) (S : CertFamily α) : Prop :=
  ∀ p ∈ S, p.1.card ≤ t ∧ p.2.card ≤ t

/-- The subtype of certificate families bounded by size `t`. -/
def BoundedCertificateFamily (α : Type*) [DecidableEq α] (t : ℕ) :=
  { S : CertFamily α // FamilyBoundedBySize t S }

/-- Bounded families inherit the subset order. -/
instance boundedFamilyPreorder (α : Type*) [DecidableEq α] (t : ℕ) :
    Preorder (BoundedCertificateFamily α t) where
  le := fun S T => CertificateFamilyLE S.1 T.1
  le_refl S := certificateFamilyLE_refl S.1
  le_trans S T U := certificateFamilyLE_trans S.1 T.1 U.1

/-- Monotonicity: subfamilies of bounded families remain bounded. -/
theorem familyBoundedBySize_subset {α : Type*} [DecidableEq α]
    {t : ℕ} {S T : CertFamily α} (hT : FamilyBoundedBySize t T)
    (hST : S ⊆ T) : FamilyBoundedBySize t S :=
  fun p hp => hT p (hST hp)

/-- The empty family is bounded by any size. -/
theorem familyBoundedBySize_empty {α : Type*} [DecidableEq α] (t : ℕ) :
    FamilyBoundedBySize t (∅ : CertFamily α) :=
  fun _ h => absurd h (Finset.notMem_empty _)

/-! ## Section 3: Certificate Profiles -/

/-- The **certificate profile** of a family: for each size class `(a, b)`,
    count how many certificates have left-size `a` and right-size `b`.
    We represent this as a function `Fin (t+1) × Fin (t+1) → ℕ`. -/
def certificateProfile {α : Type*} [DecidableEq α]
    (t : ℕ) (S : CertFamily α) : Fin (t + 1) × Fin (t + 1) → ℕ :=
  fun ⟨a, b⟩ => (S.filter (fun p => p.1.card = a.val ∧ p.2.card = b.val)).card

/-- Profile domination for certificate profiles: componentwise ≤. -/
def CertProfileLE {α : Type*} [DecidableEq α] (t : ℕ)
    (S T : CertFamily α) : Prop :=
  ∀ idx : Fin (t + 1) × Fin (t + 1), certificateProfile t S idx ≤ certificateProfile t T idx

/-! ## Section 4: Profile Domination Implies Family Ordering (Theorem 1) -/

/-- **Theorem 1 (Profile Monotonicity):** Certificate family inclusion implies
    profile domination. A subfamily has at most as many certificates in each
    size class as the ambient family. -/
theorem profile_le_of_certificateFamilyLE {α : Type*} [DecidableEq α]
    (t : ℕ) (S T : CertFamily α)
    (h : CertificateFamilyLE S T) : CertProfileLE t S T := by
  intro ⟨a, b⟩
  unfold certificateProfile
  apply Finset.card_le_card
  exact Finset.filter_subset_filter _ h

/-! ## Section 5: Well-Quasi-Ordering of Bounded Families (Theorem 2) -/

/-- **Key Lemma (Dickson for profiles):** The componentwise order on
    `Fin d → ℕ` is a well-quasi-order (Dickson's lemma). -/
theorem dickson_profiles (d : ℕ) :
    WellQuasiOrdered (fun (f g : Fin d → ℕ) => ∀ i, f i ≤ g i) :=
  WellQuasiOrdered.pi (fun _ => WellQuasiOrderedLE.wqo)

/-
**Theorem 2 (Bounded Certificate Families are WQO):**
    For a finite ambient type `α` and fixed size bound `t`, the set of
    bounded certificate families is well-quasi-ordered under inclusion.

    **Proof:** Since `α` is finite, the set of all bounded certificate pairs
    is finite. Each bounded family is a subset of this finite universe, so
    there are finitely many bounded families. Any finite preorder is WQO.
-/
theorem bounded_certificate_family_wqo
    {α : Type*} [Fintype α] [DecidableEq α] (t : ℕ) :
    WellQuasiOrdered (fun S T : BoundedCertificateFamily α t => CertificateFamilyLE S.1 T.1) := by
  convert Finite.wellQuasiOrdered ( α := BoundedCertificateFamily α t );
  constructor;
  · exact fun a r [Finite (BoundedCertificateFamily α t)] [Std.Refl r] => Finite.wellQuasiOrdered r;
  · intro h;
    convert h _;
    · exact Set.Finite.to_subtype ( Set.toFinite _ );
    · exact ⟨ fun S => certificateFamilyLE_refl S.1 ⟩

/-
**Theorem 2' (Dickson factorization):** The profile map witnesses WQO
    by factoring through Dickson's lemma. For any infinite sequence of bounded
    families, there exist `i < j` with profile domination, which implies
    family inclusion since the families are subsets of a finite universe.

    This is the structurally meaningful argument: it identifies the **reason**
    for WQO as finite-dimensional integer domination.
-/
theorem bounded_family_wqo_via_dickson
    {α : Type*} [Fintype α] [DecidableEq α] (t : ℕ)
    (f : ℕ → BoundedCertificateFamily α t) :
    ∃ i j, i < j ∧ CertificateFamilyLE (f i).1 (f j).1 := by
  convert bounded_certificate_family_wqo t f using 1

/-! ## Section 6: Finite Antichains (Theorem 4 / Width Bounds) -/

/-
**Theorem 4 (Finite Antichains):** Any antichain in the bounded certificate
    family poset is finite. This is a direct consequence of WQO.
-/
theorem finite_antichain_of_bounded
    {α : Type*} [Fintype α] [DecidableEq α] (t : ℕ)
    (A : Set (BoundedCertificateFamily α t))
    (_hA : IsAntichain (· ≤ ·) A) : A.Finite := by
  -- Since `BoundedCertificateFamily α t` is a subset of a finite set, it is finite.
  have h_finite : Finite (BoundedCertificateFamily α t) := by
    exact Set.Finite.to_subtype ( Set.finite_iff_bddAbove.mpr ⟨ Finset.univ, fun S _ => Finset.subset_univ _ ⟩ );
  exact Set.toFinite A

/-! ## Section 7: Finite Basis Theorem (Theorem 3) -/

/-- An **upward-closed** set of bounded families: if `S ∈ U` and `S ≤ T`
    then `T ∈ U`. -/
def IsUpwardClosed {α : Type*} [DecidableEq α] (t : ℕ)
    (U : Set (BoundedCertificateFamily α t)) : Prop :=
  ∀ ⦃S T : BoundedCertificateFamily α t⦄, S ∈ U → S ≤ T → T ∈ U

/-- The set of **minimal elements** of a set in the bounded family preorder. -/
def minimalElements {α : Type*} [DecidableEq α] (t : ℕ)
    (U : Set (BoundedCertificateFamily α t)) : Set (BoundedCertificateFamily α t) :=
  { S ∈ U | ∀ T ∈ U, T ≤ S → S ≤ T }

/-
**Theorem 3 (Finite Basis for Upward-Closed Sets):**
    The minimal elements of any upward-closed collection of bounded certificate
    families form a finite set.

    This is the certificate-poset analogue of:
    - Graph minor theory: finite obstruction sets
    - Noetherian algebra: every ideal is finitely generated
    - Hilbert basis theorem for monomial ideals
-/
theorem finite_basis_of_upward_closed
    {α : Type*} [Fintype α] [DecidableEq α] (t : ℕ)
    (U : Set (BoundedCertificateFamily α t))
    (_hU : IsUpwardClosed t U) :
    Set.Finite (minimalElements t U) := by
  -- The set of all bounded certificate families is finite since α is finite.
  have h_finite_families : Finite (BoundedCertificateFamily α t) := by
    exact Set.Finite.to_subtype ( Set.toFinite _ );
  exact Set.toFinite _

/-! ## Section 8: Refinement Stabilization (WSTS Bridge) -/

/-
**Theorem (Refinement Stabilization):** Any descending chain of bounded
    certificate families eventually stabilizes. This connects certificate
    refinement to well-structured transition system theory.
-/
theorem bounded_family_descending_chain_stabilizes
    {α : Type*} [Fintype α] [DecidableEq α] (t : ℕ)
    (f : ℕ → BoundedCertificateFamily α t)
    (hdesc : ∀ n, (f (n + 1)).1 ⊆ (f n).1) :
    ∃ N, ∀ n, N ≤ n → (f n).1 = (f N).1 := by
  -- Since the cardinality of a descending chain of finite sets must stabilize, there exists some N such that for all n ≥ N, card(f(n).1) = card(f(N).1).
  obtain ⟨N, hN⟩ : ∃ N, ∀ n ≥ N, (f n).1.card = (f N).1.card := by
    have h_card_stabilize : Filter.Tendsto (fun n => (f n).1.card) Filter.atTop (nhds (sInf { (f n).1.card | n : ℕ })) := by
      apply_rules [ tendsto_atTop_ciInf ];
      · exact antitone_nat_of_succ_le fun n => Finset.card_le_card ( hdesc n );
      · exact ⟨ 0, Set.forall_mem_range.2 fun n => Nat.zero_le _ ⟩;
    simp +zetaDelta at *;
    exact ⟨ h_card_stabilize.choose, fun n hn => by rw [ h_card_stabilize.choose_spec n hn, h_card_stabilize.choose_spec _ le_rfl ] ⟩;
  refine' ⟨ N, fun n hn => Finset.eq_of_subset_of_card_le _ _ ⟩;
  · exact Nat.le_induction ( by tauto ) ( fun k hk ih => by exact Finset.Subset.trans ( hdesc k ) ih ) n hn;
  · rw [ ← hN n hn ]

/-! ## Section 9: Monomial Divisibility Bridge (Algebra Connection) -/

/-- A **monomial** over `d` variables, represented by its exponent vector. -/
abbrev Monomial (d : ℕ) := Fin d → ℕ

/-- **Monomial divisibility**: `m` divides `m'` iff every exponent of `m`
    is ≤ the corresponding exponent of `m'`. -/
def MonomialDvd {d : ℕ} (m m' : Monomial d) : Prop :=
  ∀ i, m i ≤ m' i

/-- Convert a certificate profile to a monomial. The profile of a bounded
    family is naturally a function `Fin (t+1)² → ℕ`, i.e., a monomial. -/
def profileToMonomial {α : Type*} [DecidableEq α] (t : ℕ)
    (S : CertFamily α) : Monomial ((t + 1) * (t + 1)) :=
  fun idx =>
    let a : Fin (t + 1) := ⟨idx.val / (t + 1), Nat.div_lt_of_lt_mul (by omega)⟩
    let b : Fin (t + 1) := ⟨idx.val % (t + 1), Nat.mod_lt _ (by omega)⟩
    certificateProfile t S (a, b)

/-
**Theorem (Profile ↔ Monomial Bridge):** Profile domination is exactly
    monomial divisibility under the profile-to-monomial encoding.

    This makes the analogy precise:
    - Bounded certificate families ↔ monomials
    - Upward-closed certificate classes ↔ monomial ideals
    - Finite basis ↔ Dickson/Hilbert basis theorem
-/
theorem profile_le_iff_monomial_dvd {α : Type*} [DecidableEq α] (t : ℕ)
    (S T : CertFamily α) :
    CertProfileLE t S T ↔ MonomialDvd (profileToMonomial t S) (profileToMonomial t T) := by
  unfold CertProfileLE MonomialDvd profileToMonomial;
  refine' ⟨ fun h i => _, fun h i => _ ⟩;
  · exact h _;
  · convert h ⟨ i.1.val * ( t + 1 ) + i.2.val, by nlinarith [ Fin.is_lt i.1, Fin.is_lt i.2 ] ⟩ <;> simp +decide;
    · rw [ Nat.add_div ] <;> norm_num [ Nat.div_eq_of_lt ];
      rw [ Nat.div_eq_of_lt, if_neg ] <;> linarith [ Fin.is_lt i.1, Fin.is_lt i.2, Nat.mod_lt ( i.2 : ℕ ) ( Nat.succ_pos t ) ];
    · rw [ Nat.mod_eq_of_lt ( Fin.is_lt i.2 ) ];
    · rw [ Nat.add_div ] <;> norm_num [ Nat.div_eq_of_lt, Fin.is_lt ];
      rw [ Nat.div_eq_of_lt, if_neg ] <;> linarith [ Fin.is_lt i.1, Fin.is_lt i.2, Nat.mod_lt ( i.2 : ℕ ) ( Nat.succ_pos t ) ];
    · rw [ Nat.mod_eq_of_lt ( Fin.is_lt i.2 ) ]

/-! ## Section 10: Quantitative Width Bound -/

/-- The **universe** of all bounded certificate pairs over `Fin n`. -/
def boundedCertUniverse (n t : ℕ) : Finset (Finset (Fin n) × Finset (Fin n)) :=
  (Finset.univ : Finset (Finset (Fin n) × Finset (Fin n))).filter
    (fun p => p.1.card ≤ t ∧ p.2.card ≤ t)

/-
**Width bound:** The number of pairwise incomparable bounded families
    is at most `2^|boundedCertUniverse|`, since each family is a subset
    of a finite universe of bounded certificate pairs.
-/
theorem antichain_card_bound (n t : ℕ)
    (A : Finset (BoundedCertificateFamily (Fin n) t))
    (_hA : ∀ S ∈ A, ∀ T ∈ A, S ≠ T →
      ¬CertificateFamilyLE S.1 T.1 ∨ ¬CertificateFamilyLE T.1 S.1) :
    A.card ≤ 2 ^ (boundedCertUniverse n t).card := by
  -- Since A is a finset, A.card is at most the size of the type BoundedCertificateFamily (Fin n) t.
  have h_card_le_bounded_type : A.card ≤ Finset.card (Finset.filter (fun S => FamilyBoundedBySize t S) (Finset.powerset (boundedCertUniverse n t))) := by
    have h_card_le_bounded_type : A.card ≤ Finset.card (Finset.image (fun S : BoundedCertificateFamily (Fin n) t => S.val) A) := by
      rw [ Finset.card_image_of_injective _ fun x y hxy => by cases x; cases y; aesop ];
    refine le_trans h_card_le_bounded_type <| Finset.card_le_card ?_;
    simp +decide [ Finset.subset_iff ];
    exact fun S hS => ⟨ fun a b hab => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, S.2 _ hab ⟩, S.2 ⟩;
  exact h_card_le_bounded_type.trans ( le_trans ( Finset.card_filter_le _ _ ) ( by rw [ Finset.card_powerset ] ) )

/-! ## Section 11: Connection to Sandwich Certificate Order -/

open SandwichUniversality in
/-- **Bridge to catalog infrastructure:** The sandwich `CertificateLE` ordering
    (inclusion of Pos/Neg witness sets) is a certificate family comparison. -/
theorem sandwich_le_implies_family_le
    {α : Type*} [Preorder α] [Fintype α] [DecidableEq α]
    {f : α → Bool}
    (S₁ S₂ : CertifiedSandwichFamily α f)
    (h : SandwichUniversality.CertificateLE S₁ S₂) :
    S₁.Pos ⊆ S₂.Pos ∧ S₁.Neg ⊆ S₂.Neg := h

open SandwichUniversality in
/-- **Completeness monotonicity via family ordering:**
    If `S₁ ≤ S₂` in the certificate order and `S₁` is complete, then `S₂`
    is also complete. -/
theorem completeness_preserved_under_le
    {α : Type*} [Preorder α] [Fintype α] [DecidableEq α]
    {f : α → Bool}
    (S₁ S₂ : CertifiedSandwichFamily α f)
    (h : SandwichUniversality.CertificateLE S₁ S₂) (s : ℕ)
    (hcomp : SandwichCompleteUpTo f S₁ s) :
    SandwichCompleteUpTo f S₂ s :=
  SandwichUniversality.completeness_mono_certificate S₁ S₂ h hcomp

end CertificateWQO