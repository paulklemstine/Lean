/-
# Exact small Davenport constants of the abelian sections of `H_{p^3}`

`H_{p^3}` sits in the extension `C_p → H_{p^3} → C_p ⊕ C_p`, and the two
abelian groups involved are exactly the ones controlling our bounds.  Here we
compute their small Davenport constants exactly:

* `smallDavenport_multiplicative_zmod : d(C_p) = p - 1`,
* `smallDavenport_multiplicative_zmod_sq : d(C_p ⊕ C_p) = 2p - 2`.

The upper bound for `C_p` is the general pigeonhole bound `d(G) ≤ |G| - 1`; the
upper bound for `C_p ⊕ C_p` is the Chevalley–Warning bound of
`Algebra.Heisenberg125.ZeroSumTwoDim`.  Both lower bounds are explicit
zero-sum-free sequences.

Consequently `d(H_{p^3}) ≥ 3p - 3 = d(C_p) + d(C_p ⊕ C_p)`, i.e. the
conjectural value `3p - 3` is exactly the sum of the Davenport constants of the
abelian sub- and quotient group — this is the structural reason behind the
conjecture of Godara and Sarkar.
-/
import Algebra.Heisenberg125.LowerBound
import Algebra.Heisenberg125.ZeroSumTwoDim

namespace Heisenberg125

open Multiplicative

variable {A : Type*} [AddCommGroup A]

/-- The product of a list in `Multiplicative A` is the sum of the list. -/
lemma toAdd_list_prod (L : List (Multiplicative A)) :
    toAdd L.prod = (L.map toAdd).sum := by
  induction L with
  | nil => rfl
  | cons g L ih => simp [ih]

/-- Having product one in `Multiplicative A` means summing to zero in `A`. -/
lemma isProductOne_iff_sum_eq_zero (L : List (Multiplicative A)) :
    IsProductOne L ↔ (L.map toAdd).sum = 0 := by
  constructor
  · rintro ⟨M, hM, hprod⟩
    have h1 : (M.map toAdd).sum = (L.map toAdd).sum := (hM.map _).sum_eq
    rw [← h1, ← toAdd_list_prod, hprod]
    rfl
  · intro h
    refine ⟨L, List.Perm.refl _, ?_⟩
    have := toAdd_list_prod L
    rw [h] at this
    exact toAdd.injective this

lemma fst_list_sum {B C : Type*} [AddCommMonoid B] [AddCommMonoid C] (L : List (B × C)) :
    L.sum.1 = (L.map Prod.fst).sum := by
  induction L with
  | nil => rfl
  | cons g L ih => simp [ih]

lemma snd_list_sum {B C : Type*} [AddCommMonoid B] [AddCommMonoid C] (L : List (B × C)) :
    L.sum.2 = (L.map Prod.snd).sum := by
  induction L with
  | nil => rfl
  | cons g L ih => simp [ih]

/-! ## The cyclic group `C_p` -/

variable {p : ℕ}

/-- The zero-sum-free sequence `1^{p-1}` over `C_p`. -/
theorem productOneFree_replicate_one (hp : 0 < p) :
    ProductOneFree (List.replicate (p - 1) (ofAdd (1 : ZMod p))) := by
  intro T hT hne hone
  obtain ⟨k, hk, rfl⟩ := List.sublist_replicate_iff.1 hT
  rw [isProductOne_iff_sum_eq_zero] at hone
  simp only [List.map_replicate, List.sum_replicate, toAdd_ofAdd, nsmul_eq_mul, mul_one] at hone
  have := Heis.eq_zero_of_cast_eq_zero hp hk hone
  subst this
  exact hne rfl

/-- **`d(C_p) = p - 1`.** -/
theorem smallDavenport_multiplicative_zmod [NeZero p] :
    smallDavenport (Multiplicative (ZMod p)) = p - 1 := by
  have hp : 0 < p := Nat.pos_of_ne_zero (NeZero.ne p)
  refine le_antisymm ?_ ?_
  · have hcard : Fintype.card (Multiplicative (ZMod p)) = p := by simp [ZMod.card]
    have := smallDavenport_le_card_sub_one (G := Multiplicative (ZMod p))
    rwa [hcard] at this
  · have := (productOneFree_replicate_one hp).length_le_smallDavenport
    simpa using this

/-! ## The group `C_p ⊕ C_p` -/

/-- The zero-sum-free sequence `e₁^{p-1} e₂^{p-1}` over `C_p ⊕ C_p`. -/
theorem productOneFree_basis_seq (hp : 0 < p) :
    ProductOneFree (List.replicate (p - 1) (ofAdd ((1 : ZMod p), (0 : ZMod p))) ++
      List.replicate (p - 1) (ofAdd ((0 : ZMod p), (1 : ZMod p)))) := by
  intro T hT hne hone
  obtain ⟨T1, T2, rfl, h1, h2⟩ := List.sublist_append_iff.1 hT
  obtain ⟨i, hi, rfl⟩ := List.sublist_replicate_iff.1 h1
  obtain ⟨j, hj, rfl⟩ := List.sublist_replicate_iff.1 h2
  rw [isProductOne_iff_sum_eq_zero] at hone
  simp only [List.map_append, List.map_replicate, List.sum_append, List.sum_replicate,
    toAdd_ofAdd] at hone
  have hfst : (i : ZMod p) = 0 := by
    have := congrArg Prod.fst hone
    simpa [Prod.smul_mk, nsmul_eq_mul] using this
  have hsnd : (j : ZMod p) = 0 := by
    have := congrArg Prod.snd hone
    simpa [Prod.smul_mk, nsmul_eq_mul] using this
  have hi0 := Heis.eq_zero_of_cast_eq_zero hp hi hfst
  have hj0 := Heis.eq_zero_of_cast_eq_zero hp hj hsnd
  subst hi0; subst hj0
  exact hne (by simp)

/-- **`d(C_p ⊕ C_p) = 2p - 2`**, i.e. the Davenport constant of `C_p ⊕ C_p` is
`2p - 1`.  The upper bound is Chevalley–Warning, the lower bound is `e₁^{p-1}
e₂^{p-1}`. -/
theorem smallDavenport_multiplicative_zmod_sq [Fact p.Prime] :
    smallDavenport (Multiplicative (ZMod p × ZMod p)) = 2 * p - 2 := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  have hp : 0 < p := (Fact.out : p.Prime).pos
  refine le_antisymm ?_ ?_
  · refine csSup_le ⟨0, ⟨[], rfl, productOneFree_nil⟩⟩ ?_
    rintro n ⟨L, rfl, hL⟩
    by_contra hlen
    push_neg at hlen
    obtain ⟨T, hTsub, hTne, h1, h2⟩ :=
      exists_nonempty_zeroSum_sublist L (fun g => (toAdd g).1) (fun g => (toAdd g).2)
        (by omega)
    refine hL T hTsub hTne ?_
    rw [isProductOne_iff_sum_eq_zero]
    refine Prod.ext ?_ ?_
    · rw [fst_list_sum, List.map_map]
      simpa using h1
    · rw [snd_list_sum, List.map_map]
      simpa using h2
  · have h := (productOneFree_basis_seq (p := p) hp).length_le_smallDavenport
    simp only [List.length_append, List.length_replicate] at h
    omega

end Heisenberg125