import Combinatorics.BellDefectBlockPatterns

/-!
# Group order versus the fibre spectrum: a strict Bell defect from a cardinality count

The two previous files of this thread produced

* the rank collapse `m_P = t_{rank P}` and the Stirling expansion
  `#(X^k/G) = Σ_{r ≤ k} S(k,r)·t_r` (`Catalog/Logic/FibreSpectrumRank.lean`),
* triangularity/inversion and the degeneration `n^k = Σ_r S(k,r)·n^{\underline r}`
  (`Catalog/Logic/FibreSpectrumStirling.lean`).

Here the spectrum is bounded from *outside* the combinatorics, by the order of the group:

* `descFactorial_le_card_of_kTransitive` : a `k`-transitive action forces
  `|X|·(|X|−1)···(|X|−k+1) ≤ |G|`, because all injective `k`-tuples are hit by a single orbit map
  `g ↦ g • u`.
* `two_le_injOrbits_of_card_lt` : if `|G|` is smaller than that falling factorial, the top
  spectral value satisfies `t_k ≥ 2` — the spectrum *must* be degenerate.
* `bell_lt_card_orbits_of_card_lt` and `bell_mul_card_lt_sum_fixedPoints_pow` : hence the Bell
  bound of the previous cycles is *strictly* violated, quantitatively:
  `#(X^k/G) ≥ B_k + 1` and `Σ_g |X^g|^k ≥ (B_k + 1)·|G|`.

So a purely arithmetic comparison between `|G|` and a falling factorial certifies a strict
inequality for a moment of the trace family.  No `sorry`s, no `native_decide`, no new axioms.
-/

open Finset MulAction Function

namespace FibreSpectrum

open MoonshineBell MoonshineFibre

section OrderBound

variable {k : ℕ} {G : Type*} [Group G] {X : Type*} [MulAction G X]

/-- Translating an injective tuple keeps it injective. -/
theorem injective_smul {f : Fin k → X} (hf : Injective f) (g : G) : Injective (g • f) := by
  intro a b hab
  have : g • f a = g • f b := hab
  exact hf (smul_left_cancel g this)

/-- Under `k`-transitivity the injective `k`-tuples form a single orbit, that of any one of
them. -/
def orbitEquivInjectiveTuples {u : Fin k → X} (hu : Injective u) (htr : KTransitive k G X) :
    MulAction.orbit G u ≃ {f : Fin k → X // Injective f} where
  toFun f := ⟨f.1, by
    obtain ⟨g, hg⟩ := f.2
    have hgu : (g • u : Fin k → X) = f.1 := hg
    rw [← hgu]
    exact injective_smul hu g⟩
  invFun f := ⟨f.1, by
    obtain ⟨g, hg⟩ := htr u f.1 hu f.2
    exact ⟨g, hg⟩⟩
  left_inv _ := Subtype.ext rfl
  right_inv _ := Subtype.ext rfl

/-- **Orbit–stabiliser form of the order bound.**  For a `k`-transitive action the falling
factorial `|X|^{\underline k}` *divides* `|G|`: it is the length of the single orbit on injective
`k`-tuples. -/
theorem descFactorial_dvd_card_of_kTransitive [Finite X] [Finite G] (hk : k ≤ Nat.card X)
    (htr : KTransitive k G X) : (Nat.card X).descFactorial k ∣ Nat.card G := by
  obtain ⟨u, hu⟩ := exists_injective_tuple (X := X) hk
  have horb : Nat.card (MulAction.orbit G u) = (Nat.card X).descFactorial k := by
    rw [Nat.card_congr (orbitEquivInjectiveTuples hu htr), BellDefectGraded.card_injective_tuples X k]
  have hdvd := Subgroup.index_dvd_card (stabilizer G u)
  rwa [MulAction.index_stabilizer, ← Nat.card_coe_set_eq, horb] at hdvd

/-- **`k`-transitivity forces the group to be large.**  If the action is `k`-transitive then
`|G|` is at least the number `|X|^{\underline k}` of injective `k`-tuples, since `g ↦ g • u`
already exhausts them. -/
theorem descFactorial_le_card_of_kTransitive [Finite X] [Finite G] (hk : k ≤ Nat.card X)
    (htr : KTransitive k G X) : (Nat.card X).descFactorial k ≤ Nat.card G := by
  obtain ⟨u, hu⟩ := exists_injective_tuple (X := X) hk
  have hsurj : Surjective
      (fun g : G => (⟨g • u, injective_smul hu g⟩ : {f : Fin k → X // Injective f})) := by
    rintro ⟨f, hf⟩
    obtain ⟨g, hg⟩ := htr u f hu hf
    exact ⟨g, Subtype.ext hg⟩
  have h := Nat.card_le_card_of_surjective _ hsurj
  rwa [BellDefectGraded.card_injective_tuples X k] at h

/-- **Forced degeneracy of the spectrum.**  If the group is too small to be `k`-transitive, the
top spectral value is at least `2`. -/
theorem two_le_injOrbits_of_card_lt [Finite X] [Finite G] (hk : k ≤ Nat.card X)
    (hcard : Nat.card G < (Nat.card X).descFactorial k) : 2 ≤ injOrbits G X k := by
  have h1 : 1 ≤ injOrbits G X k := one_le_patternMultiplicity k G X hk (idPattern k)
  have hne : injOrbits G X k ≠ 1 := by
    intro h
    have := descFactorial_le_card_of_kTransitive hk ((injOrbits_eq_one_iff G X hk).1 h)
    omega
  omega

/-- **Strict Bell defect.**  A group of order below the falling factorial cannot achieve the Bell
floor: the orbit count on `k`-tuples strictly exceeds `B_k`. -/
theorem bell_lt_card_orbits_of_card_lt [Finite X] [Finite G] (hk : k ≤ Nat.card X)
    (hcard : Nat.card G < (Nat.card X).descFactorial k) :
    bell k < Nat.card (orbitRel.Quotient G (Fin k → X)) := by
  classical
  have htop : 2 ≤ injOrbits G X k := two_le_injOrbits_of_card_lt hk hcard
  have hlow : ∀ r ∈ Finset.range k, stirling k r ≤ stirling k r * injOrbits G X r := by
    intro r hr
    have hrk : r ≤ Nat.card X := le_trans (le_of_lt (Finset.mem_range.1 hr)) hk
    have h1 : 1 ≤ injOrbits G X r := one_le_patternMultiplicity r G X hrk (idPattern r)
    exact Nat.le_mul_of_pos_right _ h1
  have hsum : ∑ r ∈ Finset.range k, stirling k r
      ≤ ∑ r ∈ Finset.range k, stirling k r * injOrbits G X r :=
    Finset.sum_le_sum hlow
  have hbell : bell k = (∑ r ∈ Finset.range k, stirling k r) + 1 := by
    rw [bell_eq_sum_stirling k, Finset.sum_range_succ, BellDefectGraded.stirling_self k]
  have hcount : Nat.card (orbitRel.Quotient G (Fin k → X))
      = (∑ r ∈ Finset.range k, stirling k r * injOrbits G X r) + injOrbits G X k := by
    rw [card_orbits_eq_sum_stirling k G X, Finset.sum_range_succ,
      BellDefectGraded.stirling_self k, one_mul]
  omega

/-- The moment form of the strict defect: the `k`-th moment of the trace family exceeds
`B_k·|G|` by at least `|G|`. -/
theorem bell_mul_card_lt_sum_fixedPoints_pow [Finite X] [Fintype G] (hk : k ≤ Nat.card X)
    (hcard : Nat.card G < (Nat.card X).descFactorial k) :
    (bell k + 1) * Nat.card G ≤ ∑ g : G, Nat.card (fixedBy X g) ^ k := by
  have hstrict := bell_lt_card_orbits_of_card_lt (G := G) (X := X) hk hcard
  rw [sum_fixedPoints_pow_eq_orbits_mul_card G X k]
  exact Nat.mul_le_mul_right _ hstrict

end OrderBound

end FibreSpectrum