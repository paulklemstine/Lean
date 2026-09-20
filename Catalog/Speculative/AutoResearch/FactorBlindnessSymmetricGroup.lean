/-
# `Sₙ`-blindness: no permutation-invariant battery can order `n` factors

`Computation.FactorBlindnessOrbit` proved *orbit blindness*: a `G`-invariant readout leaks
exactly zero bits about any torsor coordinate of the `G`-action.  This file instantiates the
theorem in the case the battery programme actually cares about — multi-prime moduli, where the
symmetry group is the full symmetric group `Sₙ` and "which factor is the biggest" is replaced by
the entire *ordering pattern* of the `n` factors.

The label is the **rank permutation** `rankPerm v` of an injective tuple `v : Fin n → ℕ`:
`rankPerm v i` is the number of coordinates carrying a strictly smaller value, i.e. the position
of the `i`-th factor in increasing order.  It is a genuine `Sₙ`-torsor coordinate
(`rank_torsor`), so `symmetricGroup_rank_zero_leakage` says: for any population of tuples of
pairwise distinct factors closed under coordinate permutations, and any permutation-invariant
readout, the empirical reading about the ordering of the factors is `0` exactly — for every `n`.

`battery_triple_blind` is the explicit three-factor instance: the six orderings of `(3,5,7)`
read against the CRT-style trace battery `v ↦ (∑ vᵢ mod 13, ∏ vᵢ mod 17)`.

No `sorry`; the only axioms used are `propext`, `Classical.choice`, `Quot.sound`.
-/
import Computation.FactorBlindnessOrbit

namespace Computation.FactorBlindness

open Finset

section Rank

variable {n : ℕ}

/-- The coordinate-permutation action of `Sₙ` on ordered `n`-tuples of naturals. -/
def permAct (σ : Equiv.Perm (Fin n)) (v : Fin n → ℕ) : Fin n → ℕ := fun i => v (σ⁻¹ i)

theorem permAct_one (v : Fin n → ℕ) : permAct 1 v = v := by
  funext i
  simp [permAct]

theorem permAct_mul (g h : Equiv.Perm (Fin n)) (v : Fin n → ℕ) :
    permAct g (permAct h v) = permAct (g * h) v := by
  funext i
  simp [permAct, mul_inv_rev]

theorem permAct_injective {v : Fin n → ℕ} (hv : Function.Injective v) (σ : Equiv.Perm (Fin n)) :
    Function.Injective (permAct σ v) := by
  intro a b hab
  exact (Equiv.injective σ⁻¹) (hv hab)

/-- At most `n - 1` coordinates can carry a value strictly below `v i`. -/
theorem rank_card_lt (v : Fin n → ℕ) (i : Fin n) :
    ((univ : Finset (Fin n)).filter (fun j => v j < v i)).card < n := by
  have hsub : (univ : Finset (Fin n)).filter (fun j => v j < v i) ⊆ univ.erase i := by
    intro j hj
    simp only [mem_filter, mem_univ, true_and] at hj
    refine mem_erase.2 ⟨?_, mem_univ j⟩
    rintro rfl
    exact absurd hj (lt_irrefl _)
  have hcard := Finset.card_le_card hsub
  have h2 : (univ.erase i).card = n - 1 := by
    rw [Finset.card_erase_of_mem (mem_univ i), Finset.card_univ, Fintype.card_fin]
  have hn : 0 < n := lt_of_le_of_lt (Nat.zero_le _) i.isLt
  omega

/-- The rank of coordinate `i`: the number of coordinates with a strictly smaller value. -/
def rankFun (v : Fin n → ℕ) (i : Fin n) : Fin n :=
  ⟨((univ : Finset (Fin n)).filter (fun j => v j < v i)).card, rank_card_lt v i⟩

/-- Rank is strictly monotone in the value. -/
theorem rankFun_lt_of_lt {v : Fin n → ℕ} {i j : Fin n} (h : v i < v j) :
    (rankFun v i : ℕ) < rankFun v j := by
  have hsub : (univ : Finset (Fin n)).filter (fun a => v a < v i)
      ⊆ (univ : Finset (Fin n)).filter (fun a => v a < v j) := by
    intro a ha
    simp only [mem_filter, mem_univ, true_and] at ha ⊢
    exact lt_trans ha h
  have hmem : i ∈ (univ : Finset (Fin n)).filter (fun a => v a < v j) := by
    simp [h]
  have hnot : i ∉ (univ : Finset (Fin n)).filter (fun a => v a < v i) := by simp
  exact Finset.card_lt_card ((Finset.ssubset_iff_of_subset hsub).2 ⟨i, hmem, hnot⟩)

theorem rankFun_injective {v : Fin n → ℕ} (hv : Function.Injective v) :
    Function.Injective (rankFun v) := by
  intro i j hij
  by_contra hne
  have hvne : v i ≠ v j := fun h => hne (hv h)
  rcases lt_or_gt_of_ne hvne with h | h
  · exact absurd (congrArg Fin.val hij) (Nat.ne_of_lt (rankFun_lt_of_lt h))
  · exact absurd (congrArg Fin.val hij.symm) (Nat.ne_of_lt (rankFun_lt_of_lt h))

/-- The rank vector is equivariant: permuting the tuple permutes the ranks. -/
theorem rankFun_permAct (σ : Equiv.Perm (Fin n)) (v : Fin n → ℕ) (i : Fin n) :
    rankFun (permAct σ v) i = rankFun v (σ⁻¹ i) := by
  apply Fin.ext
  show ((univ : Finset (Fin n)).filter (fun j => permAct σ v j < permAct σ v i)).card
      = ((univ : Finset (Fin n)).filter (fun j => v j < v (σ⁻¹ i))).card
  refine Finset.card_bij' (fun j _ => σ⁻¹ j) (fun j _ => σ j) ?_ ?_ ?_ ?_
  · intro a ha
    simp only [mem_filter, mem_univ, true_and, permAct] at ha ⊢
    exact ha
  · intro a ha
    simp only [mem_filter, mem_univ, true_and, permAct] at ha ⊢
    simpa using ha
  · intro a _
    simp
  · intro a _
    simp

open Classical in
/-- The **ordering pattern** of a tuple: the permutation sending each coordinate to its rank
(junk value `1` on tuples with repeated entries). -/
noncomputable def rankPerm (v : Fin n → ℕ) : Equiv.Perm (Fin n) :=
  if h : Function.Injective v then
    Equiv.ofBijective (rankFun v) (Finite.injective_iff_bijective.mp (rankFun_injective h))
  else 1

theorem rankPerm_apply {v : Fin n → ℕ} (hv : Function.Injective v) (i : Fin n) :
    rankPerm v i = rankFun v i := by
  simp [rankPerm, hv]

/-- Equivariance of the ordering pattern: `rankPerm (σ · v) = rankPerm v * σ⁻¹`. -/
theorem rankPerm_permAct {v : Fin n → ℕ} (hv : Function.Injective v) (σ : Equiv.Perm (Fin n)) :
    rankPerm (permAct σ v) = rankPerm v * σ⁻¹ := by
  apply Equiv.ext
  intro i
  rw [rankPerm_apply (permAct_injective hv σ), rankFun_permAct, ← rankPerm_apply hv]
  rfl

/-- **The ordering pattern is an `Sₙ`-torsor coordinate.**  For each target pattern there is
exactly one permutation of the tuple realising it. -/
theorem rank_torsor {S : Finset (Fin n → ℕ)} (hinj : ∀ v ∈ S, Function.Injective v) :
    ∀ v ∈ S, ∀ l : Equiv.Perm (Fin n), ∃! σ : Equiv.Perm (Fin n), rankPerm (permAct σ v) = l := by
  intro v hv l
  refine ⟨l⁻¹ * rankPerm v, ?_, ?_⟩
  · show rankPerm (permAct (l⁻¹ * rankPerm v) v) = l
    rw [rankPerm_permAct (hinj v hv), mul_inv_rev, inv_inv, ← mul_assoc, mul_inv_cancel, one_mul]
  · intro σ hσ
    rw [rankPerm_permAct (hinj v hv)] at hσ
    have hinvσ : σ⁻¹ = (rankPerm v)⁻¹ * l := by
      rw [← hσ, ← mul_assoc, inv_mul_cancel, one_mul]
    calc σ = (σ⁻¹)⁻¹ := (inv_inv σ).symm
      _ = ((rankPerm v)⁻¹ * l)⁻¹ := by rw [hinvσ]
      _ = l⁻¹ * rankPerm v := by rw [mul_inv_rev, inv_inv]

/-- **`Sₙ`-blindness.**  On any population of tuples of pairwise distinct factors that is closed
under coordinate permutations, a permutation-invariant readout carries *exactly zero* bits about
the ordering of the factors.  The two-factor wall is `n = 2`. -/
theorem symmetricGroup_rank_zero_leakage {K : Type*} [DecidableEq K] [Fintype K]
    {S : Finset (Fin n → ℕ)} {c : (Fin n → ℕ) → K}
    (hS : ∀ (σ : Equiv.Perm (Fin n)), ∀ v ∈ S, permAct σ v ∈ S)
    (hinj : ∀ v ∈ S, Function.Injective v)
    (hc : ∀ (σ : Equiv.Perm (Fin n)) (v : Fin n → ℕ), c (permAct σ v) = c v) :
    mutualInfo (orbitDist S c rankPerm) = 0 :=
  orbit_zero_leakage permAct_one permAct_mul hS hc (rank_torsor hinj)

end Rank

/-! ## The explicit three-factor battery -/

section Triple

/-- The three-factor seed `(3, 5, 7)`. -/
def triple357 : Fin 3 → ℕ := ![3, 5, 7]

/-- The population of all six orderings of `(3, 5, 7)`. -/
noncomputable def tripleOrbit : Finset (Fin 3 → ℕ) :=
  (univ : Finset (Equiv.Perm (Fin 3))).image (fun σ => permAct σ triple357)

/-- A CRT-style trace battery on triples: the sum mod `13` and the product mod `17`.  Both are
symmetric functions of the factors, so the readout is permutation invariant. -/
def tripleBattery (v : Fin 3 → ℕ) : ZMod 13 × ZMod 17 :=
  (∑ i, (v i : ZMod 13), ∏ i, (v i : ZMod 17))

theorem tripleBattery_invariant (σ : Equiv.Perm (Fin 3)) (v : Fin 3 → ℕ) :
    tripleBattery (permAct σ v) = tripleBattery v := by
  have hsum : ∑ i, ((permAct σ v i : ℕ) : ZMod 13) = ∑ i, ((v i : ℕ) : ZMod 13) :=
    Equiv.sum_comp σ⁻¹ (fun i => ((v i : ℕ) : ZMod 13))
  have hprod : ∏ i, ((permAct σ v i : ℕ) : ZMod 17) = ∏ i, ((v i : ℕ) : ZMod 17) :=
    Equiv.prod_comp σ⁻¹ (fun i => ((v i : ℕ) : ZMod 17))
  simp only [tripleBattery, hsum, hprod]

theorem triple357_injective : Function.Injective triple357 := by decide

theorem tripleOrbit_closed (σ : Equiv.Perm (Fin 3)) :
    ∀ v ∈ tripleOrbit, permAct σ v ∈ tripleOrbit := by
  intro v hv
  simp only [tripleOrbit, mem_image, mem_univ, true_and] at hv ⊢
  obtain ⟨τ, rfl⟩ := hv
  exact ⟨σ * τ, permAct_mul σ τ triple357⟩

theorem tripleOrbit_injective : ∀ v ∈ tripleOrbit, Function.Injective v := by
  intro v hv
  simp only [tripleOrbit, mem_image, mem_univ, true_and] at hv
  obtain ⟨τ, rfl⟩ := hv
  exact permAct_injective triple357_injective τ

/-- The population really does carry all six orderings. -/
theorem tripleOrbit_card : tripleOrbit.card = 6 := by decide

theorem tripleOrbit_nonempty : tripleOrbit.Nonempty := by
  refine ⟨permAct 1 triple357, ?_⟩
  simp only [tripleOrbit, mem_image, mem_univ, true_and]
  exact ⟨1, rfl⟩

/-- **The three-factor battery is ordering-blind.**  On the six orderings of `(3, 5, 7)` the
trace battery `(∑ vᵢ mod 13, ∏ vᵢ mod 17)` reads exactly `0` bits about which factor sits in
which position — the population carries all six orderings, so this is not vacuous. -/
theorem battery_triple_blind :
    tripleOrbit.card = 6 ∧ mutualInfo (orbitDist tripleOrbit tripleBattery rankPerm) = 0 :=
  ⟨tripleOrbit_card,
    symmetricGroup_rank_zero_leakage tripleOrbit_closed tripleOrbit_injective
      tripleBattery_invariant⟩

end Triple

end Computation.FactorBlindness