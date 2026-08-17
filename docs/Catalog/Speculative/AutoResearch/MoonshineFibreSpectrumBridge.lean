import Bridges.MoonshineBellTransitivityBridge

/-!
# Moonshine beyond the j-function VI: the fibre spectrum of the orbit–pattern map

Cycle 2 (`Catalog/Bridges/MoonshineBellTransitivityBridge.lean`) proved that the map sending an
orbit of `k`-tuples to its kernel pattern is *surjective* whenever `k ≤ |X|`, that the number of
patterns is the Bell number `B_k`, and that the action is `k`-transitive exactly when this map is
injective.  This file refines that picture by looking at the **fibres** of the map, closing the
first half of Conjecture E of `FUTURE_DIRECTIONS.md`.

For each pattern `P` write `m_P` (`patternMultiplicity`) for the number of orbits of `k`-tuples
whose kernel pattern is `P`.  The results are:

* `sum_patternMultiplicity` : `Σ_P m_P = #(X^k/G)` — the orbit count splits along patterns.
* `one_le_patternMultiplicity` : `m_P ≥ 1` for every pattern (`k ≤ |X|`), which re-proves the
  Bell floor `B_k ≤ #(X^k/G)` fibrewise.
* `patternMultiplicity_eq_one_iff` : the action is `k`-transitive **iff** every fibre is a
  singleton.
* `sum_fixedPoints_pow_eq_sum_patternMultiplicity` and `bell_defect_eq` : the `k`-th moment of the
  trace family is `|G| · Σ_P m_P`, so the *Bell defect*
  `D_k = Σ_g |X^g|^k − B_k·|G|` equals exactly `|G| · Σ_P (m_P − 1)`.  The defect therefore counts
  the excess orbits over patterns, with multiplicity — the exact combinatorial meaning that
  Conjecture F asks to exploit.

Everything is proved; there are no `sorry`s, no `native_decide`, and no new axioms.
-/

open Finset MulAction Function

namespace MoonshineFibre

open MoonshineBell

variable (k : ℕ) (G : Type*) [Group G] (X : Type*) [MulAction G X] [Finite X]

/-- The **multiplicity of a pattern**: the number of orbits of `k`-tuples whose kernel pattern is
`P`.  These numbers refine the orbit count `#(X^k/G)` along the `B_k` patterns. -/
noncomputable def patternMultiplicity (P : Pattern k) : ℕ :=
  Nat.card {o : orbitRel.Quotient G (Fin k → X) // orbitPattern o = P}

/-- The orbit count on `k`-tuples splits as the sum of the pattern multiplicities. -/
theorem sum_patternMultiplicity :
    ∑ P : Pattern k, patternMultiplicity k G X P
      = Nat.card (orbitRel.Quotient G (Fin k → X)) := by
  classical
  letI : Fintype (orbitRel.Quotient G (Fin k → X)) := Fintype.ofFinite _
  rw [Nat.card_eq_fintype_card, ← Finset.card_univ,
    Finset.card_eq_sum_card_fiberwise
      (f := (orbitPattern (k := k) (G := G) (X := X)))
      (t := (Finset.univ : Finset (Pattern k))) (fun a _ => Finset.mem_univ _)]
  refine Finset.sum_congr rfl fun P _ => ?_
  rw [patternMultiplicity, Nat.card_eq_fintype_card, Fintype.card_subtype]

/-- Every pattern is realized, so every fibre is nonempty. -/
theorem one_le_patternMultiplicity (hk : k ≤ Nat.card X) (P : Pattern k) :
    1 ≤ patternMultiplicity k G X P := by
  obtain ⟨o, ho⟩ := orbitPattern_surjective (k := k) (G := G) (X := X) hk P
  have : Nonempty {o' : orbitRel.Quotient G (Fin k → X) // orbitPattern o' = P} := ⟨⟨o, ho⟩⟩
  exact Nat.card_pos

/-- **Fibrewise criterion for `k`-transitivity.**  The action is `k`-transitive exactly when every
pattern is realized by a *single* orbit. -/
theorem patternMultiplicity_eq_one_iff (hk : k ≤ Nat.card X) :
    (∀ P, patternMultiplicity k G X P = 1) ↔ KTransitive k G X := by
  rw [← orbitPattern_injective_iff (k := k) (G := G) (X := X) hk]
  constructor
  · intro hall o₁ o₂ h12
    have hsub : Subsingleton {o : orbitRel.Quotient G (Fin k → X)
        // orbitPattern o = orbitPattern o₁} :=
      (Nat.card_eq_one_iff_unique.1 (hall (orbitPattern o₁))).1
    have hEq := hsub.elim (⟨o₁, rfl⟩ : {o // orbitPattern o = orbitPattern o₁}) ⟨o₂, h12.symm⟩
    exact congrArg Subtype.val hEq
  · intro hinj P
    have hne : Nonempty {o : orbitRel.Quotient G (Fin k → X) // orbitPattern o = P} := by
      obtain ⟨o, ho⟩ := orbitPattern_surjective (k := k) (G := G) (X := X) hk P
      exact ⟨⟨o, ho⟩⟩
    have hsub : Subsingleton {o : orbitRel.Quotient G (Fin k → X) // orbitPattern o = P} :=
      ⟨fun a b => Subtype.ext (hinj (a.2.trans b.2.symm))⟩
    exact Nat.card_eq_one_iff_unique.2 ⟨hsub, hne⟩

variable [Fintype G]

/-- The `k`-th moment of the trace family, refined along patterns. -/
theorem sum_fixedPoints_pow_eq_sum_patternMultiplicity :
    ∑ g : G, Nat.card (fixedBy X g) ^ k
      = (∑ P : Pattern k, patternMultiplicity k G X P) * Nat.card G := by
  rw [sum_patternMultiplicity, sum_fixedPoints_pow_eq_orbits_mul_card G X k]

/-- **The Bell defect, counted exactly.**  The `k`-th moment of the trace family exceeds the Bell
value `B_k·|G|` by exactly `|G|` times the total excess `Σ_P (m_P − 1)` of orbits over patterns.
In particular the defect vanishes precisely when every fibre is a singleton, i.e. for
`k`-transitive actions. -/
theorem bell_defect_eq (hk : k ≤ Nat.card X) :
    ∑ g : G, Nat.card (fixedBy X g) ^ k
      = (bell k + ∑ P : Pattern k, (patternMultiplicity k G X P - 1)) * Nat.card G := by
  rw [sum_fixedPoints_pow_eq_sum_patternMultiplicity]
  congr 1
  have hsplit : ∑ P : Pattern k, patternMultiplicity k G X P
      = ∑ P : Pattern k, (1 + (patternMultiplicity k G X P - 1)) :=
    Finset.sum_congr rfl fun P _ =>
      (Nat.add_sub_cancel' (one_le_patternMultiplicity k G X hk P)).symm
  rw [hsplit, Finset.sum_add_distrib]
  congr 1
  simp [bell]

omit [Fintype G] in
/-- The defect is zero exactly for `k`-transitive actions, now with the fibrewise reason: the sum
`Σ_P (m_P − 1)` vanishes iff every `m_P` equals `1`. -/
theorem sum_patternMultiplicity_sub_one_eq_zero_iff (hk : k ≤ Nat.card X) :
    (∑ P : Pattern k, (patternMultiplicity k G X P - 1)) = 0 ↔ KTransitive k G X := by
  rw [← patternMultiplicity_eq_one_iff k G X hk, Finset.sum_eq_zero_iff]
  constructor
  · intro h P
    have h1 := h P (Finset.mem_univ P)
    have h2 := one_le_patternMultiplicity k G X hk P
    omega
  · intro h P _
    simp [h P]


end MoonshineFibre