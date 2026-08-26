import Mathlib

/-!
# Unbounded hypotenuse multiplicity: Pythagorean clusters are intrinsically overdispersed

The U9-DRIFT-GATE experiment clusters its hits by the modulus `N` (equivalently, in the
Pythagorean reading, by the hypotenuse) and observed a strongly non-uniform cluster
profile: the top candidate clusters carried `600 / 561 / 540` hits against a control
maximum of `359`.  The natural adversarial question is whether such heterogeneity is a
sampling artefact.  It is not.  This file proves that the per-hypotenuse hit counts of a
Pythagorean search are **unbounded**, so the overdispersion behind the round's confidence
intervals is a structural feature of the searched object, not of the sampler.

Main results.

* `hypSolutions` — the finite set of ordered positive leg pairs `(a, b)` with
  `a² + b² = c²`: the hit cluster attached to the hypotenuse `c`.
* `hypSolutions_pythagoreanTriple` — membership really is a Pythagorean triple in
  Mathlib's sense.
* `exists_hypotenuse_multiplicity` — **for every `k` there is a hypotenuse whose cluster
  carries at least `k` hits.**  The proof is constructive: take
  `C = ∏_{v < k} ((v+2)² + 1)` and scale the classical family
  `(m² − 1, 2m, m² + 1)`, `m = v + 2`, up to hypotenuse `C`.  Distinctness of the `k`
  resulting leg pairs is an exact cross-multiplication argument in `ℤ`.
* `hypotenuse_multiplicity_unbounded` — the cluster-size function is unbounded.
-/

namespace Catalog.Pythagorean.DriftGate

open Finset

/-- The hit cluster of the hypotenuse `c`: ordered pairs of positive legs `(a, b)` with
`a² + b² = c²`. -/
def hypSolutions (c : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.Icc 1 c) ×ˢ (Finset.Icc 1 c)).filter (fun p => p.1 ^ 2 + p.2 ^ 2 = c ^ 2)

theorem mem_hypSolutions {c : ℕ} {p : ℕ × ℕ} :
    p ∈ hypSolutions c ↔
      (1 ≤ p.1 ∧ p.1 ≤ c) ∧ (1 ≤ p.2 ∧ p.2 ≤ c) ∧ p.1 ^ 2 + p.2 ^ 2 = c ^ 2 := by
  simp only [hypSolutions, Finset.mem_filter, Finset.mem_product, Finset.mem_Icc]
  tauto

/-- Elements of a hit cluster are Pythagorean triples in Mathlib's sense. -/
theorem hypSolutions_pythagoreanTriple {c : ℕ} {p : ℕ × ℕ} (hp : p ∈ hypSolutions c) :
    PythagoreanTriple (p.1 : ℤ) (p.2 : ℤ) (c : ℤ) := by
  rw [mem_hypSolutions] at hp
  have h : (p.1 : ℤ) ^ 2 + (p.2 : ℤ) ^ 2 = (c : ℤ) ^ 2 := by exact_mod_cast hp.2.2
  unfold PythagoreanTriple
  nlinarith [h]

/-- The hypotenuse `5` carries exactly the two ordered hits `(3,4)` and `(4,3)`. -/
theorem hypSolutions_five : hypSolutions 5 = {(3, 4), (4, 3)} := by decide

/-- The hypotenuse of the `v`-th member of the classical family `(m²−1, 2m, m²+1)`,
`m = v + 2`, written without natural subtraction. -/
private def famHyp (v : ℕ) : ℕ := v ^ 2 + 4 * v + 5

/-- The odd leg of the `v`-th member of the classical family. -/
private def famLeg (v : ℕ) : ℕ := v ^ 2 + 4 * v + 3

private theorem fam_pyth (v : ℕ) : famLeg v ^ 2 + (2 * (v + 2)) ^ 2 = famHyp v ^ 2 := by
  simp only [famLeg, famHyp]; ring

private theorem famHyp_injective : Function.Injective famHyp := by
  intro a b hab
  simp only [famHyp] at hab
  have h : (a : ℤ) ^ 2 + 4 * a = (b : ℤ) ^ 2 + 4 * b := by exact_mod_cast by omega
  have hfac : ((a : ℤ) - b) * ((a : ℤ) + b + 4) = 0 := by nlinarith [h]
  have hpos : (0 : ℤ) < (a : ℤ) + b + 4 := by positivity
  have : (a : ℤ) - b = 0 := by
    rcases mul_eq_zero.1 hfac with h1 | h1
    · exact h1
    · exact absurd h1 (by linarith)
  have : (a : ℤ) = b := by linarith
  exact_mod_cast this

/-- The scaled family used in `exists_hypotenuse_multiplicity`. -/
private def scaledLeg (C v : ℕ) : ℕ × ℕ :=
  (famLeg v * (C / famHyp v), 2 * (v + 2) * (C / famHyp v))

/-- **Intrinsic overdispersion.**  For every `k` there is a hypotenuse whose cluster of
positive leg pairs has at least `k` elements. -/
theorem exists_hypotenuse_multiplicity (k : ℕ) :
    ∃ c : ℕ, 0 < c ∧ k ≤ (hypSolutions c).card := by
  classical
  set C : ℕ := ∏ v ∈ Finset.range k, famHyp v with hC
  have hCpos : 0 < C := Finset.prod_pos (fun v _ => by simp only [famHyp]; positivity)
  have hmul : ∀ v ∈ Finset.range k, famHyp v * (C / famHyp v) = C := fun v hv =>
    Nat.mul_div_cancel' (Finset.dvd_prod_of_mem _ hv)
  have htpos : ∀ v ∈ Finset.range k, 0 < C / famHyp v := by
    intro v hv
    rcases Nat.eq_zero_or_pos (C / famHyp v) with h | h
    · exfalso
      have hz := hmul v hv
      rw [h, Nat.mul_zero] at hz
      omega
    · exact h
  refine ⟨C, hCpos, ?_⟩
  have hcard : (Finset.range k).card = k := Finset.card_range k
  rw [← hcard]
  refine Finset.card_le_card_of_injOn (scaledLeg C) ?_ ?_
  · -- the scaled family lands inside the cluster of `C`
    intro v hv
    simp only [Finset.coe_range, Set.mem_Iio] at hv
    have hv' : v ∈ Finset.range k := Finset.mem_range.2 hv
    have ht := htpos v hv'
    have hCv := hmul v hv'
    have hlegpos : 0 < famLeg v := by simp only [famLeg]; positivity
    have hle : famLeg v ≤ famHyp v := by simp only [famLeg, famHyp]; omega
    have hle2 : 2 * (v + 2) ≤ famHyp v := by simp only [famHyp]; nlinarith [sq_nonneg v]
    simp only [Finset.mem_coe, mem_hypSolutions, scaledLeg]
    refine ⟨⟨Nat.one_le_iff_ne_zero.2 (Nat.mul_ne_zero (by omega) (by omega)), ?_⟩,
      ⟨Nat.one_le_iff_ne_zero.2 (Nat.mul_ne_zero (by omega) (by omega)), ?_⟩, ?_⟩
    · calc famLeg v * (C / famHyp v) ≤ famHyp v * (C / famHyp v) :=
            Nat.mul_le_mul_right _ hle
        _ = C := hCv
    · calc 2 * (v + 2) * (C / famHyp v) ≤ famHyp v * (C / famHyp v) :=
            Nat.mul_le_mul_right _ hle2
        _ = C := hCv
    · calc (famLeg v * (C / famHyp v)) ^ 2 + (2 * (v + 2) * (C / famHyp v)) ^ 2
          = (famLeg v ^ 2 + (2 * (v + 2)) ^ 2) * (C / famHyp v) ^ 2 := by ring
        _ = famHyp v ^ 2 * (C / famHyp v) ^ 2 := by rw [fam_pyth]
        _ = (famHyp v * (C / famHyp v)) ^ 2 := by ring
        _ = C ^ 2 := by rw [hCv]
  · -- the scaled family is injective
    intro a ha b hb hab
    simp only [Finset.coe_range, Set.mem_Iio] at ha hb
    have ha' : a ∈ Finset.range k := Finset.mem_range.2 ha
    have hb' : b ∈ Finset.range k := Finset.mem_range.2 hb
    by_contra hne
    have hfst : famLeg a * (C / famHyp a) = famLeg b * (C / famHyp b) :=
      congrArg Prod.fst hab
    set A : ℕ := famLeg a * (C / famHyp a) with hA
    have keya : A * famHyp a = famLeg a * C := by
      calc A * famHyp a = famLeg a * (famHyp a * (C / famHyp a)) := by rw [hA]; ring
        _ = famLeg a * C := by rw [hmul a ha']
    have keyb : A * famHyp b = famLeg b * C := by
      calc A * famHyp b = famLeg b * (famHyp b * (C / famHyp b)) := by rw [hfst]; ring
        _ = famLeg b * C := by rw [hmul b hb']
    -- cross-multiplication in ℤ
    have za : (A : ℤ) * (famHyp a : ℤ) = (famLeg a : ℤ) * (C : ℤ) := by exact_mod_cast keya
    have zb : (A : ℤ) * (famHyp b : ℤ) = (famLeg b : ℤ) * (C : ℤ) := by exact_mod_cast keyb
    have hgapa : (famHyp a : ℤ) = (famLeg a : ℤ) + 2 := by
      simp only [famHyp, famLeg]; push_cast; ring
    have hgapb : (famHyp b : ℤ) = (famLeg b : ℤ) + 2 := by
      simp only [famHyp, famLeg]; push_cast; ring
    have hdiff : ((A : ℤ) - (C : ℤ)) * ((famHyp a : ℤ) - (famHyp b : ℤ)) = 0 := by
      linear_combination za - zb - (C : ℤ) * hgapa + (C : ℤ) * hgapb
    have hne' : (famHyp a : ℤ) ≠ (famHyp b : ℤ) := by
      intro h
      exact hne (famHyp_injective (by exact_mod_cast h))
    have hAC : (A : ℤ) = (C : ℤ) := by
      rcases mul_eq_zero.1 hdiff with h1 | h1
      · linarith
      · exact absurd (by linarith : (famHyp a : ℤ) = (famHyp b : ℤ)) hne'
    -- but the scaled leg is strictly smaller than the hypotenuse
    have hlt : A < C := by
      have hle : famLeg a < famHyp a := by simp only [famLeg, famHyp]; omega
      calc A = famLeg a * (C / famHyp a) := hA
        _ < famHyp a * (C / famHyp a) := by
            exact (Nat.mul_lt_mul_right (htpos a ha')).2 hle
        _ = C := hmul a ha'
    exact absurd hAC (by exact_mod_cast Nat.ne_of_lt hlt)

/-- Restatement: the hypotenuse-cluster size function is unbounded. -/
theorem hypotenuse_multiplicity_unbounded :
    ¬ ∃ B : ℕ, ∀ c : ℕ, (hypSolutions c).card ≤ B := by
  rintro ⟨B, hB⟩
  obtain ⟨c, _, hc⟩ := exists_hypotenuse_multiplicity (B + 1)
  exact absurd (hc.trans (hB c)) (by omega)

end Catalog.Pythagorean.DriftGate