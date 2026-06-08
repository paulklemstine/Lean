/-
# Formal Novelty Certification for Theorem Descriptors

A mathematically certified mechanism that assigns to each theorem descriptor
a computable embedding into a normed space and proves that sufficiently large
distance from a certified archive implies non-identity, non-redundancy,
and structural novelty.

## Main Results

- `novelty_of_pointwise_lower_bound`: If all archive elements are at distance ≥ ε
  from d, then d is ε-novel relative to the archive.
- `not_mem_of_positive_novelty`: If the embedding is injective and ε > 0,
  then an ε-novel descriptor is not in the archive.
- `archiveDist_eq_witness`: The archive distance is realized by some witness.
- `novelty_certificate_iff`: Novel ε A d ↔ ∀ a ∈ A, ε ≤ ‖embed d - embed a‖.
- `archiveDist_antitone`: Archive distance is antitone under archive growth.
- `novelty_transfer`: Archive distance is 1-Lipschitz in descriptor space.
- `archiveDist_eq_zero_iff`: Zero archive distance characterizes membership
  (under injectivity).
-/

import Mathlib

open Finset

/-! ## Descriptor: a concrete finite record encoding bounded theorem features -/

/-- A `Descriptor` encodes syntactic/semantic features of a theorem statement
as a finite record of natural numbers and booleans. This is a concrete
abstraction over a restricted theorem language. -/
structure Descriptor where
  quantDepth : ℕ
  symbolCount : ℕ
  binderCount : ℕ
  hasEq : Bool
  hasForall : Bool
  hasExists : Bool
  natArity : ℕ
  finArity : ℕ
  boolArity : ℕ
  deriving DecidableEq, Repr

/-! ## Embedding into a normed space -/

/-- Embed a descriptor into `Fin 9 → ℝ` by mapping each field to a coordinate.
The ambient space carries the sup-norm, but our theorems are norm-agnostic. -/
noncomputable def embed (d : Descriptor) : Fin 9 → ℝ :=
  fun i =>
    match i.1, i.2 with
    | 0, _ => (d.quantDepth : ℝ)
    | 1, _ => (d.symbolCount : ℝ)
    | 2, _ => (d.binderCount : ℝ)
    | 3, _ => if d.hasEq then 1 else 0
    | 4, _ => if d.hasForall then 1 else 0
    | 5, _ => if d.hasExists then 1 else 0
    | 6, _ => (d.natArity : ℝ)
    | 7, _ => (d.finArity : ℝ)
    | 8, _ => (d.boolArity : ℝ)
    | n + 9, h => absurd h (by omega)

/-! ## Archive distance and novelty -/

/-- The archive distance of a candidate descriptor `d` from a finite archive `A`
is the minimum distance from `d` to any element of `A` in the embedding space.
Returns 0 for the empty archive. -/
noncomputable def archiveDist (A : Finset Descriptor) (d : Descriptor) : ℝ :=
  if h : A.Nonempty then
    A.inf' h (fun a => ‖embed d - embed a‖)
  else 0

/-- A descriptor `d` is `ε`-novel relative to archive `A` if the archive
distance is at least `ε`. -/
def Novel (ε : ℝ) (A : Finset Descriptor) (d : Descriptor) : Prop :=
  ε ≤ archiveDist A d

/-! ## Core certification theorems -/

/-
**Novelty Certificate (Forward Direction).**
If every archived descriptor lies at distance at least `ε` from `d`,
then `d` is certified `ε`-novel relative to `A`.
-/
theorem novelty_of_pointwise_lower_bound
    (A : Finset Descriptor) (d : Descriptor) (ε : ℝ)
    (hA : A.Nonempty)
    (_hε : 0 ≤ ε)
    (hsep : ∀ a ∈ A, ε ≤ ‖embed d - embed a‖) :
    Novel ε A d := by
  exact le_trans ( Finset.le_inf' _ _ hsep ) ( by unfold archiveDist; aesop )

/-
**Non-membership from positive novelty.**
If the embedding is injective and `d` has positive novelty,
then `d` is not in the archive.
-/
theorem not_mem_of_positive_novelty
    (_hinj : Function.Injective embed)
    (A : Finset Descriptor) (d : Descriptor) (ε : ℝ)
    (hA : A.Nonempty)
    (hε : 0 < ε)
    (hnov : Novel ε A d) :
    d ∉ A := by
  -- By contradiction, assume $d \in A$.
  by_contra h_contra;
  -- Since $d \in A$, we have $\|embed d - embed d\| = 0$.
  have h_dist_zero : ‖embed d - embed d‖ = 0 := by
    norm_num;
  -- Since the archive distance is the infimum of the distances, and zero is one of those distances (when a = d), the infimum must be zero.
  have h_inf_zero : archiveDist A d ≤ ‖embed d - embed d‖ := by
    unfold archiveDist;
    split_ifs ; aesop;
  -- Since the archive distance is the infimum of the distances, and zero is one of those distances (when a = d), the infimum must be zero. Therefore, ε ≤ 0, which contradicts hε.
  have h_contra : ε ≤ 0 := by
    exact hnov.trans ( h_inf_zero.trans h_dist_zero.le );
  linarith

/-! ## Witness realization -/

/-
**Nearest-Neighbor Witness.**
For any nonempty archive, the archive distance is realized by some
archived descriptor — there exists an actual nearest neighbor.
-/
theorem archiveDist_eq_witness
    (A : Finset Descriptor) (d : Descriptor)
    (hA : A.Nonempty) :
    ∃ a ∈ A, archiveDist A d = ‖embed d - embed a‖ := by
  have := Finset.exists_mem_eq_inf' hA ( fun a => ‖embed d - embed a‖ );
  unfold archiveDist; aesop;

/-! ## Certificate equivalence -/

/-
**Novelty Certificate Theorem (Equivalence).**
A descriptor is `ε`-novel relative to an archive if and only if
every archived descriptor lies at distance at least `ε`.
-/
theorem novelty_certificate_iff
    (A : Finset Descriptor) (d : Descriptor) (ε : ℝ)
    (hA : A.Nonempty) :
    Novel ε A d ↔ ∀ a ∈ A, ε ≤ ‖embed d - embed a‖ := by
  constructor <;> intro h <;> simp_all +decide [ Novel ];
  · unfold archiveDist at h;
    split_ifs at h ; aesop;
  · unfold archiveDist;
    split_ifs ; aesop

/-! ## Extensions -/

/-
**Archive distance is nonneg.**
-/
theorem archiveDist_nonneg (A : Finset Descriptor) (d : Descriptor) :
    0 ≤ archiveDist A d := by
  unfold archiveDist; aesop

/-
**Monotonicity under archive growth.**
Adding theorems to the archive can only decrease (or preserve) the
archive distance — more known results means harder to be novel.
-/
theorem archiveDist_antitone
    {A B : Finset Descriptor} {d : Descriptor}
    (hAB : A ⊆ B) (hA : A.Nonempty) :
    archiveDist B d ≤ archiveDist A d := by
  unfold archiveDist;
  split_ifs <;> simp_all +decide [ Finset.inf'_le_iff ];
  exact fun x hx => ⟨ x, hAB hx, le_rfl ⟩

/-
**Triangle-transfer novelty (1-Lipschitz).**
Archive distance is 1-Lipschitz in the descriptor embedding:
the novelty of one descriptor bounds the novelty of a nearby descriptor.
-/
theorem novelty_transfer
    (A : Finset Descriptor) (d₁ d₂ : Descriptor)
    (hA : A.Nonempty) :
    archiveDist A d₁ - ‖embed d₁ - embed d₂‖ ≤ archiveDist A d₂ := by
  -- Use archiveDist_eq_witness to get a₁ ∈ A with archiveDist A d₁ = ‖embed d₁ - embed a₁‖.
  obtain ⟨a₁, ha₁, h₁⟩ : ∃ a₁ ∈ A, archiveDist A d₁ = ‖embed d₁ - embed a₁‖ := archiveDist_eq_witness A d₁ hA;
  -- By triangle inequality: ‖embed d₂ - embed a₁‖ ≤ ‖embed d₂ - embed d₁‖ + ‖embed d₁ - embed a₁‖.
  have h_triangle : ‖embed d₂ - embed a₁‖ ≤ ‖embed d₂ - embed d₁‖ + ‖embed d₁ - embed a₁‖ := by
    convert norm_add_le ( embed d₂ - embed d₁ ) ( embed d₁ - embed a₁ ) using 1 ; abel_nf;
  rw [ norm_sub_rev ( embed d₁ ) ( embed d₂ ) ];
  unfold archiveDist at *;
  split_ifs at * ; simp_all +decide;
  intro b hb; rw [ ← h₁ ] ; exact le_trans ( Finset.inf'_le _ hb ) ( by simpa [ norm_sub_rev ] using norm_sub_le ( embed d₂ - embed b ) ( embed d₂ - embed d₁ ) ) ;

/-
**Zero-radius characterization.**
Under injectivity of the embedding, the archive distance is zero
if and only if the descriptor is in the archive.
-/
theorem archiveDist_eq_zero_iff
    (hinj : Function.Injective embed)
    (A : Finset Descriptor) (d : Descriptor)
    (hA : A.Nonempty) :
    archiveDist A d = 0 ↔ d ∈ A := by
  constructor;
  · obtain ⟨ a, ha, h ⟩ := archiveDist_eq_witness A d hA;
    simp_all +decide [ sub_eq_zero, hinj.eq_iff ];
  · intro hd
    unfold archiveDist;
    simp +decide [ hA ];
    exact le_antisymm ( Finset.inf'_le _ hd |> le_trans <| by norm_num ) ( by exact le_trans ( by norm_num ) <| Finset.le_inf' _ _ fun x hx => norm_nonneg _ )

/-
**Embedding injectivity.**
The 9-dimensional embedding is injective: distinct descriptors map to
distinct points. This is the key property enabling non-membership certificates.
-/
theorem embed_injective : Function.Injective embed := by
  intro d₁ d₂ h;
  simp_all +decide [ funext_iff, Fin.forall_fin_succ ];
  cases d₁ ; cases d₂ ; simp_all +decide [ embed ];
  grind