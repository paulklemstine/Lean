import Mathlib

/-!
# Matrix-product factorizations of finite relations

This file isolates the combinatorial core of matrix-product factorizations (MPFs) in
association schemes.  A zero-one adjacency matrix is represented by a relation `R`; its
ordinary product counts two-step witnesses.  Thus a product is again a zero-one adjacency
matrix exactly when every edge in the target relation has one intermediate witness and
every non-edge has none.

The results do not assume the full association-scheme axioms, so they can be reused for
arbitrary finite graphs and coherent configurations.
-/

open scoped BigOperators
open Finset

namespace AssociationSchemeMPF

variable {V : Type*} [Fintype V]

/-- The natural-number zero-one adjacency matrix of a decidable relation. -/
def adjacency (R : V → V → Prop) [DecidableRel R] : Matrix V V ℕ :=
  fun x y => if R x y then 1 else 0

/-- Number of outgoing neighbors of `x`. -/
def outDegree (R : V → V → Prop) [DecidableRel R] (x : V) : ℕ :=
  ((Finset.univ : Finset V).filter (R x)).card

/-- A relation has constant outgoing valency `k`. -/
def IsRegular (R : V → V → Prop) [DecidableRel R] (k : ℕ) : Prop :=
  ∀ x, outDegree R x = k

/-- Ordinary multiplication of zero-one adjacency matrices counts intermediate vertices. -/
theorem adjacency_mul_apply_eq_card
    (R S : V → V → Prop) [DecidableRel R] [DecidableRel S] (x z : V) :
    (adjacency R * adjacency S) x z =
      ((Finset.univ : Finset V).filter fun y => R x y ∧ S y z).card := by
  simp only [Matrix.mul_apply, adjacency, ite_mul, one_mul, zero_mul]
  rw [Finset.card_filter]
  apply Finset.sum_congr rfl
  intro y hy
  by_cases hR : R x y <;> by_cases hS : S y z <;> simp [hR, hS]

/-- A finite predicate has exactly one witness iff its filtered universe has cardinality
one. -/
lemma card_filter_univ_eq_one_iff_existsUnique (P : V → Prop) [DecidablePred P] :
    ((Finset.univ : Finset V).filter P).card = 1 ↔ ∃! x, P x := by
  constructor
  · intro h
    obtain ⟨a, ha⟩ := Finset.card_eq_one.mp h
    have hPa : P a := by
      have : a ∈ (Finset.univ.filter P : Finset V) := by simp [ha]
      simpa using this
    refine ⟨a, hPa, ?_⟩
    intro y hPy
    have hy : y ∈ (Finset.univ.filter P : Finset V) := by simp [hPy]
    rw [ha] at hy
    simpa using hy
  · rintro ⟨a, hPa, huniq⟩
    apply Finset.card_eq_one.mpr
    refine ⟨a, Finset.ext fun y => ?_⟩
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
    exact ⟨fun hPy => huniq y hPy, fun hya => hya ▸ hPa⟩

/-- A finite predicate has no witness iff its filtered universe has cardinality zero. -/
lemma card_filter_univ_eq_zero_iff_not_exists (P : V → Prop) [DecidablePred P] :
    ((Finset.univ : Finset V).filter P).card = 0 ↔ ¬ ∃ x, P x := by
  rw [Finset.card_eq_zero, Finset.filter_eq_empty_iff]
  simp

/-- The central structural criterion for an MPF: target pairs have exactly one witness,
and all other pairs have no witness. -/
theorem adjacency_mul_eq_iff_unique
    (R S U : V → V → Prop)
    [DecidableRel R] [DecidableRel S] [DecidableRel U] :
    adjacency R * adjacency S = adjacency U ↔
      ∀ x z, (U x z ∧ ∃! y, R x y ∧ S y z) ∨
        (¬ U x z ∧ ¬ ∃ y, R x y ∧ S y z) := by
  constructor
  · intro h x z
    have hxz := congrFun (congrFun h x) z
    rw [adjacency_mul_apply_eq_card] at hxz
    by_cases hU : U x z
    · left
      refine ⟨hU, (card_filter_univ_eq_one_iff_existsUnique _).mp ?_⟩
      simpa [adjacency, hU] using hxz
    · right
      refine ⟨hU, (card_filter_univ_eq_zero_iff_not_exists _).mp ?_⟩
      simpa [adjacency, hU] using hxz
  · intro h
    funext x z
    rw [adjacency_mul_apply_eq_card]
    rcases h x z with ⟨hU, hw⟩ | ⟨hU, hw⟩
    · rw [(card_filter_univ_eq_one_iff_existsUnique _).mpr hw]
      simp [adjacency, hU]
    · rw [(card_filter_univ_eq_zero_iff_not_exists _).mpr hw]
      simp [adjacency, hU]

/-- Every edge of the target of an MPF has a unique factorization through an
intermediate vertex. -/
theorem unique_intermediate_of_mpf
    (R S U : V → V → Prop)
    [DecidableRel R] [DecidableRel S] [DecidableRel U]
    (hMPF : adjacency R * adjacency S = adjacency U)
    {x z : V} (hxz : U x z) :
    ∃! y, R x y ∧ S y z := by
  rcases (adjacency_mul_eq_iff_unique R S U).mp hMPF x z with h | h
  · exact h.2
  · exact (h.1 hxz).elim

/-- A non-edge of the target of an MPF has no factorization through an intermediate
vertex. -/
theorem no_intermediate_of_mpf
    (R S U : V → V → Prop)
    [DecidableRel R] [DecidableRel S] [DecidableRel U]
    (hMPF : adjacency R * adjacency S = adjacency U)
    {x z : V} (hxz : ¬ U x z) :
    ¬ ∃ y, R x y ∧ S y z := by
  rcases (adjacency_mul_eq_iff_unique R S U).mp hMPF x z with h | h
  · exact (hxz h.1).elim
  · exact h.2

/-- The sum of an adjacency-matrix row is its outdegree. -/
lemma adjacency_row_sum (R : V → V → Prop) [DecidableRel R] (x : V) :
    ∑ y, adjacency R x y = outDegree R x := by
  simp only [adjacency, outDegree]
  rw [Finset.card_filter]

/-- Valencies multiply in every MPF.  This is the basic arithmetic obstruction used
throughout the classification theory of association-scheme factorizations. -/
theorem valency_multiplication
    (R S U : V → V → Prop)
    [DecidableRel R] [DecidableRel S] [DecidableRel U] [Nonempty V]
    {r s u : ℕ} (hR : IsRegular R r) (hS : IsRegular S s)
    (hU : IsRegular U u)
    (hMPF : adjacency R * adjacency S = adjacency U) :
    u = r * s := by
  let x : V := Classical.choice (inferInstance : Nonempty V)
  have hrows : (∑ z, (adjacency R * adjacency S) x z) = ∑ z, adjacency U x z := by
    simpa using congrArg (fun M : Matrix V V ℕ => ∑ z, M x z) hMPF
  have hleft : (∑ z, (adjacency R * adjacency S) x z) = r * s := by
    simp only [Matrix.mul_apply]
    rw [Finset.sum_comm]
    simp_rw [← Finset.mul_sum]
    simp_rw [adjacency_row_sum]
    have heq : (∑ y, adjacency R x y * outDegree S y) =
        ∑ y, adjacency R x y * s := by
      apply Finset.sum_congr rfl
      intro y hy
      rw [hS y]
    rw [heq, ← Finset.sum_mul, adjacency_row_sum, hR]
  have hright : (∑ z, adjacency U x z) = u := by
    rw [adjacency_row_sum, hU x]
  omega

/-- In the universal-complement case, valencies satisfy `r*s = |V|-1`.  This is the
first numerical restriction behind the universal pentagon theorem. -/
theorem complement_valency_restriction
    (R S : V → V → Prop)
    [DecidableEq V] [DecidableRel R] [DecidableRel S] [Nonempty V]
    {r s : ℕ} (hR : IsRegular R r) (hS : IsRegular S s)
    (hMPF : adjacency R * adjacency S = adjacency (fun x y : V => x ≠ y)) :
    r * s = Fintype.card V - 1 := by
  have hreg : IsRegular (fun x y : V => x ≠ y) (Fintype.card V - 1) := by
    intro x
    unfold outDegree
    rw [show (Finset.univ.filter fun y : V => x ≠ y) = Finset.univ.erase x by
      ext y
      simp [ne_comm]]
    rw [Finset.card_erase_of_mem (Finset.mem_univ x)]
    simp
  exact (valency_multiplication R S (fun x y : V => x ≠ y)
    hR hS hreg hMPF).symm

/-- Transposing an MPF reverses its factors.  For symmetric relations this says that
an MPF automatically holds in the opposite order, as it does in a commutative symmetric
association scheme. -/
theorem reverse_mpf_of_symmetric
    (R S U : V → V → Prop)
    [DecidableRel R] [DecidableRel S] [DecidableRel U]
    (hR : Symmetric R) (hS : Symmetric S) (hU : Symmetric U)
    (hMPF : adjacency R * adjacency S = adjacency U) :
    adjacency S * adjacency R = adjacency U := by
  funext x z
  rw [adjacency_mul_apply_eq_card]
  have hcount := congrFun (congrFun hMPF z) x
  rw [adjacency_mul_apply_eq_card] at hcount
  rw [show (Finset.univ.filter fun y => S x y ∧ R y z) =
      Finset.univ.filter fun y => R z y ∧ S y x by
    apply Finset.filter_congr
    intro y hy
    constructor
    · rintro ⟨hs, hr⟩
      exact ⟨hR hr, hS hs⟩
    · rintro ⟨hr, hs⟩
      exact ⟨hS hs, hR hr⟩]
  rw [hcount]
  unfold adjacency
  by_cases h : U x z
  · simp [h, hU h]
  · have hn : ¬ U z x := fun hzx => h (hU hzx)
    simp [h, hn]

/-!
## The pentagon: the 5-cycle factorization of `J - I`

The headline example of the theory is the scheme of the 5-cycle `C₅`.  Its two nontrivial
basic relations are "distance one" and "distance two", each of valency two, and their
ordinary matrix product is exactly the all-ones-minus-identity matrix `J - I`.  This is a
genuine loopless matrix-product factorization, showing the general criteria above are not
vacuous, and it saturates `complement_valency_restriction` with `2 * 2 = 5 - 1`.
-/

namespace Pentagon

/-- Distance-one relation on the 5-cycle `ℤ/5`. -/
def R1 : Fin 5 → Fin 5 → Prop := fun x y => y = x + 1 ∨ x = y + 1

/-- Distance-two relation on the 5-cycle `ℤ/5`. -/
def R2 : Fin 5 → Fin 5 → Prop := fun x y => y = x + 2 ∨ x = y + 2

instance : DecidableRel R1 := fun x y => by unfold R1; infer_instance
instance : DecidableRel R2 := fun x y => by unfold R2; infer_instance

/-- Both basic relations are symmetric. -/
theorem R1_symmetric : Symmetric R1 := by unfold Symmetric R1; decide
theorem R2_symmetric : Symmetric R2 := by unfold Symmetric R2; decide

/-- The distance-one relation has valency two. -/
theorem R1_regular : IsRegular R1 2 := by unfold IsRegular outDegree; decide

/-- The distance-two relation has valency two. -/
theorem R2_regular : IsRegular R2 2 := by unfold IsRegular outDegree; decide

/-- **The pentagon factorization.**  On the 5-cycle the product of the distance-one and
distance-two adjacency matrices is `J - I`, the adjacency matrix of the "distinct"
relation.  This is a nontrivial loopless MPF. -/
theorem pentagon_mpf :
    adjacency R1 * adjacency R2 = adjacency (fun x y : Fin 5 => x ≠ y) := by decide

/-- The pentagon example realizes the universal-complement valency equation
`r * s = |V| - 1` with `r = s = 2` and `|V| = 5`. -/
theorem pentagon_valency_restriction : (2 : ℕ) * 2 = Fintype.card (Fin 5) - 1 :=
  complement_valency_restriction R1 R2 R1_regular R2_regular pentagon_mpf

/-- Every non-loop pair of the pentagon has a unique distance-one/distance-two witness. -/
theorem pentagon_unique_intermediate {x z : Fin 5} (hxz : x ≠ z) :
    ∃! y, R1 x y ∧ R2 y z :=
  unique_intermediate_of_mpf R1 R2 (fun x y : Fin 5 => x ≠ y) pentagon_mpf hxz

end Pentagon

end AssociationSchemeMPF