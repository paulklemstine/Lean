import Mathlib
import Combinatorics.MordellDenominatorTripling

/-!
# How many `N` are denominator-active?  Exact densities at layers 2 and 3

The two previous files fixed a residue `N mod ℓ` and counted the *`x`-classes* which force the
good prime `ℓ` into the denominator of `x(2P)` (roots of `T³ + N`) and of `x(3P)`
(roots of `ψ₃ = 3x⁴ + 12Nx`).  Here we turn the counting around and ask the dual question:

> for a fixed prime `ℓ`, for how many residues `c = N mod ℓ` is the layer *active at all*?

The answer is a clean arithmetic dichotomy.  At supersingular primes (`ℓ ≡ 2 mod 3`) **every**
residue is active already at layer 2.  At ordinary primes (`ℓ ≡ 1 mod 3`) exactly `(ℓ + 2)/3`
of the `ℓ` residues are active at layer 2 — a density of exactly `1/3 + 2/(3ℓ)` — while at
layer 3 **every** residue is active, for every prime.  Layer 3 is therefore uniformly
productive where layer 2 has a positive density of blind spots, and the mean number of
producing classes jumps from exactly `1` at layer 2 to exactly `2 - 1/ℓ` at layer 3.

## Main results

* `three_mul_card_activeResidues2_of_one_mod_three` : `3 · #active = ℓ + 2` at ordinary primes,
  i.e. exactly `(ℓ+2)/3` residues `N mod ℓ` admit a layer-2 denominator class.
* `activeResidues2_of_two_mod_three` : at supersingular primes every residue is active.
* `density_activeResidues2_of_one_mod_three` : the density is exactly `(ℓ+2)/(3ℓ)`.
* `exists_inactive_residue_of_one_mod_three` : ordinary primes really do have blind spots
  (a positive proportion of `N` for which `ℓ` never divides `den x(2P)`).
* `three_mul_card_blindResidues2_of_one_mod_three` : dually, exactly `2(ℓ-1)/3` residues are
  blind at layer 2, and `mem_blindResidues2_iff` identifies blindness with "`-N` is not a cube
  modulo `ℓ`".
* `V3_nonempty`, `activeResidues3_eq_univ` : layer 3 has **no** blind spots — the class `x ≡ 0`
  always works, for every prime and every `N`.
* `sum_card_V3` : `∑_{c} #V₃(c) = 2ℓ - 1`, so the average layer-3 class count is `2 - 1/ℓ`,
  exactly twice the layer-2 average `1` in the limit.
* `average_card_V3` : the rational form of the previous statement.
* `layer3_beats_layer2` : the sharp comparison, at ordinary primes, of the two layers.

-- !-- Lab Notes -- !--
Hypothesizer: layer `n` should be active for a proportion of residues tending to `1` as `n`
  grows, because `ψ_n` acquires more and more rational roots mod `ℓ`; the first prediction is
  that layer 3 is *already* everywhere active, since `ψ₃ = 3x(x³ + 4N)` has the free root
  `x = 0` independent of `N`.
Experimenter: proved (`activeResidues3_eq_univ`).  For layer 2 the exact count follows from
  the previously proved facts `∑_c #V₂(c) = ℓ`, `#V₂(0) = 1` and `#V₂(c) ∈ {0,3}` for `c ≠ 0`
  at ordinary primes: `ℓ = 1 + 3(A - 1)`, hence `A = (ℓ+2)/3`.
Analyst: the counting is a partition argument, not an analytic estimate: the map `x ↦ -x³` is
  `3`-to-`1` onto its image at ordinary primes and bijective at supersingular ones, and the
  two computations of `∑_c #V₂(c)` (by `c` and by `x`) are the two sides of the same partition.
  The layer-3 total `2ℓ - 1` is `ℓ` (the free root `x = 0`) plus `ℓ - 1` (the roots of
  `T³ + 4N`, one residue `c = 0` being lost to the free root).
Critic: `ℓ ≥ 5` is needed throughout layer 3 (`3` and `4` must be invertible), and `ℓ ∤ N` is
  needed for the `0 ∨ 3` dichotomy at layer 2 — that is why the residue `c = 0` is separated
  out by hand everywhere.  Both hypotheses are hypotheses of the imported theorems, not new
  assumptions.  No `sorry` below.
-/

namespace MordellDensity

open Finset EllipticModCount MordellPointCount

variable {ℓ : ℕ}

/-! ## The two vanishing loci as functions of the residue `c = N mod ℓ` -/

/-- The layer-2 locus attached to a residue `c ∈ 𝔽_ℓ`: the roots of `T³ + c`. -/
def V2 (ℓ : ℕ) [Fact ℓ.Prime] (c : ZMod ℓ) : Finset (ZMod ℓ) :=
  univ.filter fun t => t ^ 3 + c = 0

/-- The layer-3 locus attached to a residue `c ∈ 𝔽_ℓ`: the roots of `ψ₃ = 3T⁴ + 12cT`. -/
def V3 (ℓ : ℕ) [Fact ℓ.Prime] (c : ZMod ℓ) : Finset (ZMod ℓ) :=
  univ.filter fun t => 3 * t ^ 4 + 12 * c * t = 0

lemma mem_V2 [Fact ℓ.Prime] {c t : ZMod ℓ} : t ∈ V2 ℓ c ↔ t ^ 3 + c = 0 := by simp [V2]

lemma mem_V3 [Fact ℓ.Prime] {c t : ZMod ℓ} : t ∈ V3 ℓ c ↔ 3 * t ^ 4 + 12 * c * t = 0 := by
  simp [V3]

lemma V2_eq_rootSet [Fact ℓ.Prime] (c : ZMod ℓ) : V2 ℓ c = rootSet (0 : ZMod ℓ) c := by
  ext t
  simp [V2, rootSet, wRHS]

lemma V2_eq_vanishingClasses [Fact ℓ.Prime] (N : ℤ) :
    V2 ℓ ((N : ZMod ℓ)) = vanishingClasses N ℓ := by
  ext t
  rw [mem_V2, mem_vanishingClasses_iff]

lemma V3_eq_vanishingClasses3 [Fact ℓ.Prime] (N : ℤ) :
    V3 ℓ ((N : ZMod ℓ)) = vanishingClasses3 N ℓ := by
  ext t
  rw [mem_V3, mem_vanishingClasses3_iff]

/-! ## Layer-2 counts -/

lemma sum_card_V2 [Fact ℓ.Prime] : ∑ c : ZMod ℓ, (V2 ℓ c).card = ℓ := by
  simpa [V2_eq_rootSet] using sum_card_vanishingClasses (ℓ := ℓ)

lemma card_V2_zero [Fact ℓ.Prime] : (V2 ℓ 0).card = 1 := by
  have : V2 ℓ 0 = {0} := by
    ext t
    simp only [mem_V2, add_zero, Finset.mem_singleton]
    constructor
    · exact fun h => pow_eq_zero_iff three_ne_zero |>.mp h
    · rintro rfl; ring
  rw [this, Finset.card_singleton]

/-- At an ordinary prime the layer-2 count of a nonzero residue is `0` or `3`. -/
lemma card_V2_cases_of_one_mod_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ℓ % 3 = 1)
    {c : ZMod ℓ} (hc : c ≠ 0) : (V2 ℓ c).card = 0 ∨ (V2 ℓ c).card = 3 := by
  have hcast : ((c.val : ℤ) : ZMod ℓ) = c := by push_cast [ZMod.natCast_val]; simp
  have hlN : ¬(ℓ : ℤ) ∣ (c.val : ℤ) := by
    rw [← ZMod.intCast_zmod_eq_zero_iff_dvd, hcast]
    exact hc
  have := card_vanishingClasses_of_one_mod_three (ℓ := ℓ) hl5 h3 hlN
  rwa [← V2_eq_vanishingClasses (ℓ := ℓ) (c.val : ℤ), hcast] at this

/-- The residues `c = N mod ℓ` for which the doubling layer produces at least one class. -/
def activeResidues2 (ℓ : ℕ) [Fact ℓ.Prime] : Finset (ZMod ℓ) :=
  univ.filter fun c => (V2 ℓ c).Nonempty

lemma mem_activeResidues2 [Fact ℓ.Prime] {c : ZMod ℓ} :
    c ∈ activeResidues2 ℓ ↔ (V2 ℓ c).Nonempty := by simp [activeResidues2]

lemma zero_mem_activeResidues2 [Fact ℓ.Prime] : (0 : ZMod ℓ) ∈ activeResidues2 ℓ := by
  rw [mem_activeResidues2, ← Finset.card_pos, card_V2_zero]
  norm_num

/-- **Supersingular primes have no blind spots at layer 2.** -/
theorem activeResidues2_of_two_mod_three [Fact ℓ.Prime] (h3 : ℓ % 3 = 2) :
    activeResidues2 ℓ = univ := by
  ext c
  simp only [mem_activeResidues2, Finset.mem_univ, iff_true]
  have hcast : ((c.val : ℤ) : ZMod ℓ) = c := by push_cast [ZMod.natCast_val]; simp
  have h := card_vanishingClasses_of_two_mod_three (ℓ := ℓ) h3 (c.val : ℤ)
  rw [← V2_eq_vanishingClasses (ℓ := ℓ) (c.val : ℤ), hcast] at h
  rw [← Finset.card_pos, h]
  norm_num

/-- **The exact layer-2 activity count at an ordinary prime**: `3 · #active = ℓ + 2`, i.e.
exactly `(ℓ + 2)/3` of the `ℓ` residues of `N` admit a denominator-producing class. -/
theorem three_mul_card_activeResidues2_of_one_mod_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (h3 : ℓ % 3 = 1) : 3 * (activeResidues2 ℓ).card = ℓ + 2 := by
  classical
  -- the total is concentrated on the active residues
  have hsupp : ∑ c : ZMod ℓ, (V2 ℓ c).card = ∑ c ∈ activeResidues2 ℓ, (V2 ℓ c).card := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro c _ hc
    rw [mem_activeResidues2, Finset.not_nonempty_iff_eq_empty] at hc
    rw [hc, Finset.card_empty]
  -- split off the residue `0`
  have h0 : (0 : ZMod ℓ) ∈ activeResidues2 ℓ := zero_mem_activeResidues2
  have hsplit : ∑ c ∈ activeResidues2 ℓ, (V2 ℓ c).card
      = (V2 ℓ 0).card + ∑ c ∈ (activeResidues2 ℓ).erase 0, (V2 ℓ c).card :=
    (Finset.add_sum_erase _ _ h0).symm
  -- every remaining term is `3`
  have hconst : ∀ c ∈ (activeResidues2 ℓ).erase 0, (V2 ℓ c).card = 3 := by
    intro c hc
    obtain ⟨hc0, hcA⟩ := Finset.mem_erase.mp hc
    rcases card_V2_cases_of_one_mod_three hl5 h3 hc0 with h | h
    · exact absurd (Finset.card_pos.mpr (mem_activeResidues2.mp hcA)) (by omega)
    · exact h
  have htot := sum_card_V2 (ℓ := ℓ)
  rw [hsupp, hsplit, Finset.sum_congr rfl hconst, Finset.sum_const, card_V2_zero,
    smul_eq_mul] at htot
  have hcard : (activeResidues2 ℓ).card = ((activeResidues2 ℓ).erase 0).card + 1 := by
    rw [Finset.card_erase_of_mem h0]
    have : 0 < (activeResidues2 ℓ).card := Finset.card_pos.mpr ⟨0, h0⟩
    omega
  omega

/-- The density form: at an ordinary prime exactly a fraction `(ℓ+2)/(3ℓ)` of the residues of
`N` are layer-2 active — asymptotically one third, never all of them. -/
theorem density_activeResidues2_of_one_mod_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (h3 : ℓ % 3 = 1) :
    (((activeResidues2 ℓ).card : ℚ)) / (ℓ : ℚ) = ((ℓ : ℚ) + 2) / (3 * (ℓ : ℚ)) := by
  have hne : (ℓ : ℚ) ≠ 0 := by
    have : (0 : ℕ) < ℓ := by omega
    exact_mod_cast Nat.cast_ne_zero.mpr this.ne'
  have h := three_mul_card_activeResidues2_of_one_mod_three (ℓ := ℓ) hl5 h3
  have hq : 3 * (((activeResidues2 ℓ).card : ℚ)) = (ℓ : ℚ) + 2 := by exact_mod_cast h
  field_simp
  linarith [hq]

/-- **Ordinary primes have blind spots.**  If `ℓ ≡ 1 (mod 3)` there is a residue class of `N`
modulo `ℓ` for which `ℓ` never divides the denominator of `x(2P)`, whatever the point. -/
theorem exists_inactive_residue_of_one_mod_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (h3 : ℓ % 3 = 1) : ∃ c : ZMod ℓ, V2 ℓ c = ∅ := by
  by_contra hcon
  push_neg at hcon
  have huniv : activeResidues2 ℓ = univ := by
    ext c
    simp only [mem_activeResidues2, Finset.mem_univ, iff_true]
    exact hcon c
  have hcard : (activeResidues2 ℓ).card = ℓ := by
    rw [huniv, Finset.card_univ, ZMod.card]
  have h := three_mul_card_activeResidues2_of_one_mod_three (ℓ := ℓ) hl5 h3
  rw [hcard] at h
  omega

/-- The blind residues of the doubling layer: those `c = N mod ℓ` with no producing class. -/
def blindResidues2 (ℓ : ℕ) [Fact ℓ.Prime] : Finset (ZMod ℓ) :=
  univ.filter fun c => V2 ℓ c = ∅

/-- Blindness is exactly the failure of `-c` to be a cube modulo `ℓ`. -/
lemma mem_blindResidues2_iff [Fact ℓ.Prime] {c : ZMod ℓ} :
    c ∈ blindResidues2 ℓ ↔ ∀ t : ZMod ℓ, t ^ 3 ≠ -c := by
  simp only [blindResidues2, Finset.mem_filter, Finset.mem_univ, true_and,
    ← Finset.not_nonempty_iff_eq_empty, Finset.Nonempty, not_exists, mem_V2]
  constructor
  · intro h t ht
    exact h t (by linear_combination ht)
  · intro h t ht
    exact h t (by linear_combination ht)

/-- **The exact size of the blind set.**  At an ordinary prime exactly `2(ℓ-1)/3` of the `ℓ`
residues of `N` are blind at the doubling layer — the non-cubes, a set of density `→ 2/3`. -/
theorem three_mul_card_blindResidues2_of_one_mod_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (h3 : ℓ % 3 = 1) : 3 * (blindResidues2 ℓ).card = 2 * (ℓ - 1) := by
  classical
  have hsdiff : blindResidues2 ℓ = univ \ activeResidues2 ℓ := by
    ext c
    simp [blindResidues2, activeResidues2, Finset.not_nonempty_iff_eq_empty]
  have hsub : activeResidues2 ℓ ⊆ (univ : Finset (ZMod ℓ)) := Finset.subset_univ _
  have hcard : (blindResidues2 ℓ).card = ℓ - (activeResidues2 ℓ).card := by
    rw [hsdiff, Finset.card_sdiff_of_subset hsub, Finset.card_univ, ZMod.card]
  have hact := three_mul_card_activeResidues2_of_one_mod_three (ℓ := ℓ) hl5 h3
  have hle : (activeResidues2 ℓ).card ≤ ℓ := by
    have h := Finset.card_le_card hsub
    rwa [Finset.card_univ, ZMod.card] at h
  omega

/-! ## Layer 3 : no blind spots at all -/

/-- The free root `x ≡ 0` of `ψ₃ = 3x(x³ + 4N)`: layer 3 is active for every residue. -/
theorem V3_nonempty [Fact ℓ.Prime] (c : ZMod ℓ) : (V3 ℓ c).Nonempty := by
  refine ⟨0, ?_⟩
  rw [mem_V3]
  ring

/-- The residues for which the tripling layer produces a class: all of them. -/
def activeResidues3 (ℓ : ℕ) [Fact ℓ.Prime] : Finset (ZMod ℓ) :=
  univ.filter fun c => (V3 ℓ c).Nonempty

theorem activeResidues3_eq_univ [Fact ℓ.Prime] : activeResidues3 ℓ = univ := by
  ext c
  simp [activeResidues3, V3_nonempty c]

/-- For `c ≠ 0` the layer-3 locus is the disjoint union of the free root `0` and the roots of
`T³ + 4c`, hence has one more element than the layer-2 locus of `4c`. -/
lemma card_V3_of_ne_zero [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) {c : ZMod ℓ} (hc : c ≠ 0) :
    (V3 ℓ c).card = (V2 ℓ (4 * c)).card + 1 := by
  have h3ne : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  have hsplit : V3 ℓ c = insert 0 (V2 ℓ (4 * c)) := by
    ext t
    simp only [mem_V3, Finset.mem_insert, mem_V2]
    constructor
    · intro h
      have hfac : (3 : ZMod ℓ) * (t * (t ^ 3 + 4 * c)) = 0 := by linear_combination h
      rcases mul_eq_zero.mp hfac with h' | h'
      · exact absurd h' h3ne
      · rcases mul_eq_zero.mp h' with h'' | h''
        · exact Or.inl h''
        · exact Or.inr (by linear_combination h'')
    · rintro (rfl | h)
      · ring
      · linear_combination 3 * t * h
  have hnot : (0 : ZMod ℓ) ∉ V2 ℓ (4 * c) := by
    rw [mem_V2]
    intro h
    have h4 : (4 : ZMod ℓ) ≠ 0 := by
      have h2 : ((2 : ZMod ℓ)) ≠ 0 := MordellPointCount.two_ne_zero_zmod hl5
      have : (4 : ZMod ℓ) = 2 ^ 2 := by norm_num
      rw [this]; exact pow_ne_zero _ h2
    have : (4 : ZMod ℓ) * c = 0 := by linear_combination h
    rcases mul_eq_zero.mp this with h' | h'
    · exact h4 h'
    · exact hc h'
  rw [hsplit, Finset.card_insert_of_notMem hnot, add_comm]

lemma card_V3_zero [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) : (V3 ℓ 0).card = 1 := by
  have h3ne : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  have : V3 ℓ 0 = {0} := by
    ext t
    simp only [mem_V3, Finset.mem_singleton, mul_zero, zero_mul, add_zero]
    constructor
    · intro h
      have hfac : (3 : ZMod ℓ) * t ^ 4 = 0 := by linear_combination h
      rcases mul_eq_zero.mp hfac with h' | h'
      · exact absurd h' h3ne
      · exact pow_eq_zero_iff (by norm_num) |>.mp h'
    · rintro rfl; ring
  rw [this, Finset.card_singleton]

/-- **The layer-3 total.**  Summed over all residues of `N` modulo `ℓ`, the number of
denominator-producing classes at layer 3 is exactly `2ℓ - 1`: the `ℓ` free roots `x ≡ 0`, plus
the `ℓ - 1` roots of `T³ + 4N` for `N ≢ 0`.  The layer-2 total is `ℓ`
(`sum_card_V2`), so tripling is very nearly twice as productive as doubling. -/
theorem sum_card_V3 [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) :
    ∑ c : ZMod ℓ, (V3 ℓ c).card = 2 * ℓ - 1 := by
  classical
  have h4 : (4 : ZMod ℓ) ≠ 0 := by
    have h2 : ((2 : ZMod ℓ)) ≠ 0 := MordellPointCount.two_ne_zero_zmod hl5
    have : (4 : ZMod ℓ) = 2 ^ 2 := by norm_num
    rw [this]; exact pow_ne_zero _ h2
  -- reindexed layer-2 total
  have hreindex : ∑ c : ZMod ℓ, (V2 ℓ (4 * c)).card = ℓ := by
    have hb := Fintype.sum_bijective (fun c : ZMod ℓ => 4 * c) (mulLeft_bijective₀ 4 h4)
      (fun c => (V2 ℓ (4 * c)).card) (fun c => (V2 ℓ c).card) (fun _ => rfl)
    rw [hb, sum_card_V2]
  have h0 : (0 : ZMod ℓ) ∈ (univ : Finset (ZMod ℓ)) := Finset.mem_univ _
  have hsplit3 : ∑ c : ZMod ℓ, (V3 ℓ c).card
      = (V3 ℓ 0).card + ∑ c ∈ univ.erase (0 : ZMod ℓ), (V3 ℓ c).card :=
    (Finset.add_sum_erase _ _ h0).symm
  have hsplit2 : ∑ c : ZMod ℓ, (V2 ℓ (4 * c)).card
      = (V2 ℓ (4 * 0)).card + ∑ c ∈ univ.erase (0 : ZMod ℓ), (V2 ℓ (4 * c)).card :=
    (Finset.add_sum_erase _ _ h0).symm
  have hterm : ∀ c ∈ univ.erase (0 : ZMod ℓ),
      (V3 ℓ c).card = (V2 ℓ (4 * c)).card + 1 := by
    intro c hc
    exact card_V3_of_ne_zero hl5 (Finset.mem_erase.mp hc).1
  have hcarderase : (univ.erase (0 : ZMod ℓ)).card = ℓ - 1 := by
    rw [Finset.card_erase_of_mem h0, Finset.card_univ, ZMod.card]
  rw [hsplit3, Finset.sum_congr rfl hterm, Finset.sum_add_distrib, Finset.sum_const,
    smul_eq_mul, mul_one, hcarderase, card_V3_zero hl5]
  rw [mul_zero, card_V2_zero] at hsplit2
  have hlpos : 1 ≤ ℓ := by omega
  omega

/-- The average number of layer-3 classes is exactly `2 - 1/ℓ`, against exactly `1` at
layer 2 (`average_card_vanishingClasses`). -/
theorem average_card_V3 [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) :
    (∑ c : ZMod ℓ, ((V3 ℓ c).card : ℚ)) / (ℓ : ℚ) = 2 - 1 / (ℓ : ℚ) := by
  have hlpos : 0 < ℓ := by omega
  have hne : (ℓ : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hlpos.ne'
  have h := sum_card_V3 (ℓ := ℓ) hl5
  have hq : (∑ c : ZMod ℓ, ((V3 ℓ c).card : ℚ)) = 2 * (ℓ : ℚ) - 1 := by
    have hcast : ((∑ c : ZMod ℓ, (V3 ℓ c).card : ℕ) : ℚ) = ((2 * ℓ - 1 : ℕ) : ℚ) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℚ)) h
    push_cast at hcast
    rw [Nat.cast_sub (by omega)] at hcast
    push_cast at hcast
    exact_mod_cast hcast
  rw [hq]
  field_simp

/-- **Layer 3 strictly dominates layer 2 at ordinary primes.**  For `ℓ ≡ 1 (mod 3)`, `ℓ ≥ 5`:
every residue of `N` is layer-3 active, a strictly smaller (density `≈ 1/3`) set of residues is
layer-2 active, and the layer-3 total of producing classes exceeds the layer-2 total. -/
theorem layer3_beats_layer2 [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ℓ % 3 = 1) :
    activeResidues3 ℓ = univ ∧ activeResidues2 ℓ ≠ univ ∧
      3 * (activeResidues2 ℓ).card = ℓ + 2 ∧
      (∑ c : ZMod ℓ, (V2 ℓ c).card) < ∑ c : ZMod ℓ, (V3 ℓ c).card := by
  refine ⟨activeResidues3_eq_univ, ?_, three_mul_card_activeResidues2_of_one_mod_three hl5 h3, ?_⟩
  · intro hcon
    obtain ⟨c, hc⟩ := exists_inactive_residue_of_one_mod_three (ℓ := ℓ) hl5 h3
    have : c ∈ activeResidues2 ℓ := hcon ▸ Finset.mem_univ c
    rw [mem_activeResidues2, hc] at this
    exact absurd this (by simp)
  · rw [sum_card_V2 (ℓ := ℓ), sum_card_V3 (ℓ := ℓ) hl5]
    omega

/-! ## Numerical consistency check -/

/-- The general counts, checked against exhaustive enumeration at the two ordinary primes
`7` and `13`: `#active₂ = (ℓ+2)/3` (`3` and `5`) and `∑_c #V₃(c) = 2ℓ - 1` (`13` and `25`). -/
theorem counts_at_7_and_13 :
    (activeResidues2 7).card = 3 ∧ ∑ c : ZMod 7, (V3 7 c).card = 13 ∧
      (activeResidues2 13).card = 5 ∧ ∑ c : ZMod 13, (V3 13 c).card = 25 :=
  ⟨by decide, by decide, by decide, by decide⟩

end MordellDensity