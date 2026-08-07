import Novelty.DiophantineLatticeMultiplicity

/-!
# Cycle 8: the complete `2`-torsion gap spectrum of `ℤⁿ`

Cycle 6 computed the spectral gap of the standard lattice at two extreme `2`-torsion shifts:
`1/4` at a half shortest vector (`torsion_shift_isInhomMin_iff`) and `n/4` at the deep hole
(`deepHole_isInhomMin`).  This file computes the gap at **every** `2`-torsion shift and thereby
settles Conjecture D of `FUTURE_DIRECTIONS.md`.

Every `2`-torsion class of `(½ℤ/ℤ)ⁿ = 𝔽₂ⁿ` has a unique representative whose coordinates are
`0` or `1/2`; write `stepShift s` for the representative supported on `s : Finset (Fin n)`.

* `stepShift_isInhomMin` : the spectral gap at `stepShift s` is exactly `|s|/4`.
* `two_torsion_gap_eq_card` : for an arbitrary shift `t` with `2t = v ∈ ℤⁿ` the gap is
  `k/4` where `k` is the number of **odd** coordinates of `v` — i.e. the Hamming weight of the
  class of `t` in `𝔽₂ⁿ`.
* `gap_spectrum_eq` : the set of spectral gaps of `ℤⁿ` at `2`-torsion shifts is exactly
  `{k/4 : 1 ≤ k ≤ n}`; both inclusions are proved, the `⊇` one by exhibiting the shift
  supported on an explicit `k`-element set.

So the metric invariant `μ` on `2`-torsion shifts *is* the Hamming weight function on `𝔽₂ⁿ`,
divided by `4`: a dictionary between the covering theory of `ℤⁿ` and binary coding theory.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the gap at a `2`-torsion shift depends only on the class in `𝔽₂ⁿ`
and is a linear function of its Hamming weight.
Experiment (Experimenter): the standard form splits as a sum over coordinates, and each
coordinate contributes `≥ 1/4` if half-integral and `≥ 0` otherwise, with both bounds attained
at the *same* lattice point (`m = 0` after translating the class to its `0/½` representative),
so the minimum is additive — no interaction between coordinates.
Analysis (Analyst): additivity is exactly what fails for a general form `B`, where the
off-diagonal entries couple the coordinates; the theorem is therefore sharp in its hypothesis,
not in its proof, and the general statement should be the assertion that `μ` on `L/2L` is the
"weight enumerator" of the lattice.
Critique (Critic): `gap_spectrum_eq` is a genuine set equality, not an inclusion, and it is
non-vacuous for every `n ≥ 1`; `two_torsion_gap_eq_card` recovers `deepHole_isInhomMin`
(`v = (1,…,1)`, weight `n`) and the rank-one rigidity case (weight `1`).
Synthesis (PI): the `2`-torsion gap spectrum of `ℤⁿ` is `{k/4 : 1 ≤ k ≤ n}`, with the gap at a
class equal to a quarter of its Hamming weight.
-/

namespace DiophantineLattice

open Finset

variable {n : ℕ}

/-! ## The `0/½` representatives -/

/-- The `2`-torsion shift with coordinates `1/2` exactly on `s`. -/
def stepShift (s : Finset (Fin n)) : Fin n → ℚ := fun i => if i ∈ s then 1 / 2 else 0

@[simp] lemma stepShift_apply (s : Finset (Fin n)) (i : Fin n) :
    stepShift s i = if i ∈ s then 1 / 2 else 0 := rfl

lemma sum_indicator_quarter (s : Finset (Fin n)) :
    ∑ _i ∈ s, (1 : ℚ) / 4 = (s.card : ℚ) / 4 := by
  rw [Finset.sum_const, nsmul_eq_mul]
  ring

/-- **The gap at a `0/½` representative.**  The spectral gap of the standard form at
`stepShift s` is exactly `|s|/4`. -/
theorem stepShift_isInhomMin (s : Finset (Fin n)) :
    IsInhomMin (1 : Matrix (Fin n) (Fin n) ℚ) (stepShift s) ((s.card : ℚ) / 4) := by
  classical
  constructor
  · refine ⟨0, ?_⟩
    rw [form_one]
    have h : ∀ i : Fin n, (stepShift s i - emb (0 : Fin n → ℤ) i) ^ 2
        = if i ∈ s then (1 : ℚ) / 4 else 0 := by
      intro i
      simp only [stepShift_apply, emb_apply]
      split_ifs <;> norm_num
    rw [Finset.sum_congr rfl fun i _ => h i, Finset.sum_ite_mem, Finset.univ_inter,
      sum_indicator_quarter]
  · intro m
    rw [form_one]
    have hterm : ∀ i ∈ (Finset.univ : Finset (Fin n)),
        (if i ∈ s then (1 : ℚ) / 4 else 0) ≤ (stepShift s i - emb m i) ^ 2 := by
      intro i _
      simp only [stepShift_apply, emb_apply]
      split_ifs with hi
      · exact deepHole_term_ge (m i)
      · exact sq_nonneg _
    have := Finset.sum_le_sum hterm
    rwa [Finset.sum_ite_mem, Finset.univ_inter, sum_indicator_quarter] at this

/-! ## Arbitrary `2`-torsion shifts -/

/-- Every `2`-torsion shift is congruent modulo the lattice to a `0/½` representative, namely
the one supported on the odd coordinates of `2t`. -/
lemma eq_stepShift_add {t : Fin n → ℚ} {v : Fin n → ℤ} (hv : ∀ i, (2 : ℚ) * t i = (v i : ℚ)) :
    t = fun i => stepShift (Finset.univ.filter fun i => v i % 2 ≠ 0) i
      + emb (fun i => v i / 2) i := by
  classical
  funext i
  have hdiv : 2 * (v i / 2) + v i % 2 = v i := Int.mul_ediv_add_emod (v i) 2
  have hti : t i = (v i : ℚ) / 2 := by linarith [hv i]
  rcases (by omega : v i % 2 = 0 ∨ v i % 2 = 1) with h0 | h1
  · have hveven : v i = 2 * (v i / 2) := by omega
    simp only [stepShift_apply, emb_apply, Finset.mem_filter, Finset.mem_univ, true_and, h0]
    rw [hti]
    have : ((v i : ℚ)) = 2 * ((v i / 2 : ℤ) : ℚ) := by exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hveven
    rw [this]
    norm_num
  · have hvodd : v i = 2 * (v i / 2) + 1 := by omega
    simp only [stepShift_apply, emb_apply, Finset.mem_filter, Finset.mem_univ, true_and, h1]
    rw [hti]
    have : ((v i : ℚ)) = 2 * ((v i / 2 : ℤ) : ℚ) + 1 := by
      exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hvodd
    rw [this]
    norm_num
    ring

/-- **The gap of an arbitrary `2`-torsion shift is a quarter of its Hamming weight.**  If
`2t = v` is a lattice vector then the spectral gap of the standard form at `t` equals `k/4`,
where `k` is the number of odd coordinates of `v`. -/
theorem two_torsion_gap_eq_card {t : Fin n → ℚ} {v : Fin n → ℤ}
    (hv : ∀ i, (2 : ℚ) * t i = (v i : ℚ)) :
    IsInhomMin (1 : Matrix (Fin n) (Fin n) ℚ) t
      ((((Finset.univ.filter fun i => v i % 2 ≠ 0) : Finset (Fin n)).card : ℚ) / 4) := by
  classical
  have hbase := stepShift_isInhomMin (n := n) (Finset.univ.filter fun i => v i % 2 ≠ 0)
  have := isInhomMin_translate (1 : Matrix (Fin n) (Fin n) ℚ) _ (fun i => v i / 2) hbase
  rwa [← eq_stepShift_add hv] at this

/-- The deep hole is the weight-`n` case. -/
theorem deepHole_eq_stepShift_univ :
    deepHole n = stepShift (Finset.univ : Finset (Fin n)) := by
  funext i
  simp [deepHole, stepShift]

/-- Consistency with cycle 3: the deep hole is the case `s = univ`, so its gap is `n/4`. -/
theorem deepHole_isInhomMin_reproved :
    IsInhomMin (1 : Matrix (Fin n) (Fin n) ℚ) (deepHole n) ((n : ℚ) / 4) := by
  have h := stepShift_isInhomMin (Finset.univ : Finset (Fin n))
  rw [← deepHole_eq_stepShift_univ] at h
  simpa using h

/-- The spectral gap is unique when it exists. -/
lemma isInhomMin_unique {B : Matrix (Fin n) (Fin n) ℚ} {t : Fin n → ℚ} {mu mu' : ℚ}
    (h : IsInhomMin B t mu) (h' : IsInhomMin B t mu') : mu = mu' := by
  obtain ⟨m, hm⟩ := h.1
  obtain ⟨m', hm'⟩ := h'.1
  have h1 := h.2 m'
  have h2 := h'.2 m
  rw [hm'] at h1
  rw [hm] at h2
  linarith

/-! ## The spectrum -/

/-- **Conjecture D, settled.**  The set of spectral gaps of the standard form on `ℤⁿ` at
`2`-torsion shifts (shifts `t ∉ ℤⁿ` with `2t ∈ ℤⁿ`) is exactly `{k/4 : 1 ≤ k ≤ n}`. -/
theorem gap_spectrum_eq :
    {mu : ℚ | ∃ t : Fin n → ℚ, IsTorsionShift t 2 ∧
        IsInhomMin (1 : Matrix (Fin n) (Fin n) ℚ) t mu}
      = {mu : ℚ | ∃ k : ℕ, 1 ≤ k ∧ k ≤ n ∧ mu = (k : ℚ) / 4} := by
  classical
  ext mu
  simp only [Set.mem_setOf_eq]
  constructor
  · rintro ⟨t, ⟨⟨v, hv⟩, hnl⟩, hmu⟩
    set s : Finset (Fin n) := Finset.univ.filter fun i => v i % 2 ≠ 0 with hs
    have hgap := two_torsion_gap_eq_card hv
    have hmueq : mu = (s.card : ℚ) / 4 := isInhomMin_unique hmu hgap
    refine ⟨s.card, ?_, ?_, hmueq⟩
    · rcases Nat.eq_zero_or_pos s.card with h0 | hpos
      · exfalso
        have hall : ∀ i, v i % 2 = 0 := by
          intro i
          by_contra hi
          have himem : i ∈ s := Finset.mem_filter.mpr ⟨Finset.mem_univ i, hi⟩
          have : s.Nonempty := ⟨i, himem⟩
          rw [← Finset.card_pos] at this
          omega
        refine hnl (fun i => v i / 2) ?_
        funext i
        have hdiv : 2 * (v i / 2) + v i % 2 = v i := Int.mul_ediv_add_emod (v i) 2
        have hveven : v i = 2 * (v i / 2) := by have := hall i; omega
        have hcast : ((v i : ℚ)) = 2 * ((v i / 2 : ℤ) : ℚ) := by
          exact_mod_cast congrArg (fun z : ℤ => (z : ℚ)) hveven
        have := hv i
        rw [hcast] at this
        show t i = ((v i / 2 : ℤ) : ℚ)
        linarith
      · exact hpos
    · exact le_trans (Finset.card_le_card (Finset.filter_subset _ _))
        (le_of_eq (by simp))
  · rintro ⟨k, hk1, hkn, rfl⟩
    obtain ⟨s, hs⟩ : ∃ s : Finset (Fin n), s.card = k := by
      have : k ≤ (Finset.univ : Finset (Fin n)).card := by simpa using hkn
      exact Finset.exists_subset_card_eq this |>.imp fun s hs => hs.2
    refine ⟨stepShift s, ⟨⟨fun i => if i ∈ s then 1 else 0, ?_⟩, ?_⟩, ?_⟩
    · intro i
      simp only [stepShift_apply]
      split_ifs <;> norm_num
    · intro m hm
      have hsne : s.Nonempty := Finset.card_pos.mp (by omega)
      obtain ⟨i, hi⟩ := hsne
      have hci := congrFun hm i
      simp only [stepShift_apply, emb_apply, if_pos hi] at hci
      have h2 : ((2 * m i : ℤ) : ℚ) = ((1 : ℤ) : ℚ) := by push_cast; linarith
      have : 2 * m i = 1 := by exact_mod_cast h2
      omega
    · rw [← hs]; exact stepShift_isInhomMin s

end DiophantineLattice