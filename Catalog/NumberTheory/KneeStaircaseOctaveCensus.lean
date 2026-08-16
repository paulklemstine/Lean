/-
# The octave census: the NET-47 knee set is exactly the grid-admissible staircase population

Cycle 2 of the NET-47 thread.  Cycle 1
(`Catalog/NumberTheory/KneeStaircaseArithmetic.lean`,
`Catalog/NumberTheory/KneeStaircaseDivisorSpectrum.lean`) showed that each measured knee is a
binary staircase number `stair b j = 2^b (2^j - 1)` and that `112` is the only staircase number
on the `16`-grid strictly between `96` and `128`.

This file proves the sharper, *census* statement.  Fix a dyadic octave `(2^(n-1), 2^n]` — the
product point `2^n = d·ctx/32` sits at its right end — and a sweep grid of step `2^g`.  Then:

* `KneeStaircase.mem_octave_census_iff` — a number in the octave is a staircase number divisible
  by `2^g` **iff** it is `2^n` itself or a rung `2^n - 2^(n-j)` with `2 ≤ j ≤ n - g`.
* `KneeStaircase.octave_census_card` — hence the number of grid-admissible knee candidates in an
  octave is exactly `n - g = log₂(product point / grid step)`.  Candidate knees are *logarithmically*
  scarce: refining the grid by one halving adds exactly one candidate.
* `KneeStaircase.net47_census` — at `(d = 4, ctx = 1024)`: `n = 7`, grid step `16 = 2^4`, so the
  census is `{96, 112, 128}` — **precisely the three-seed knee distribution measured in NET-47**.
  The observed spread is therefore not a sample of a continuum: it is the *entire* admissible
  population, and the round's three seeds exhausted it.
* `KneeStaircase.census_le_top` and `KneeStaircase.census_ge_three_quarters` — the **bracket**:
  every admissible knee lies in `[(3/4)·2^n, 2^n]`, so the product law is an upper bound and the
  spread can never exceed a factor `4/3`; `KneeStaircase.census_waste_ratio` shows that factor is
  attained exactly, independently of context and grid.
* `KneeStaircase.census_determines_params` — **identifiability**: a census determines the pair
  `(n, g)`, so a reported knee set carries its own measurement metadata.
* `KneeStaircase.census_scaling` — **renormalisation**: doubling both the product point and the
  grid step doubles the census pointwise, the census-level form of `k* ∝ d·ctx`.
* `KneeStaircase.seven_eighths_median_law` — the general law behind the round's "7/8 median":
  whenever the grid ratio is `n - g = 3`, the census has three points, they are in arithmetic
  progression, and the middle one is exactly `(7/8)·2^n`.  The 7/8 law is thus equivalent to the
  grid being one eighth of the product point, and it predicts the census at any other cell
  (e.g. `n = 8`, `g = 5`: `{192, 224, 256}` with median `224 = (7/8)·256`).
-/

import Mathlib
import NumberTheory.KneeStaircaseArithmetic

namespace KneeStaircase

open Finset

/-- A natural number is a *staircase number* if its binary expansion is a nonempty block of ones
followed by a block of zeros. -/
def IsStaircase (k : ℕ) : Prop := ∃ b j, 1 ≤ j ∧ k = stair b j

theorem isStaircase_stair {b j : ℕ} (hj : 1 ≤ j) : IsStaircase (stair b j) := ⟨b, j, hj, rfl⟩

theorem isStaircase_two_pow (n : ℕ) : IsStaircase (2 ^ n) :=
  ⟨n, 1, le_refl 1, by rw [stair_one]⟩

/-! ## 1.  Divisibility by a power of two -/

/-- A staircase number is divisible by `2 ^ g` exactly when its zero block is long enough. -/
theorem two_pow_dvd_stair_iff {b j g : ℕ} (hj : 1 ≤ j) :
    2 ^ g ∣ stair b j ↔ g ≤ b := by
  constructor
  · intro h
    have hcop : Nat.Coprime (2 ^ g) (2 ^ j - 1) :=
      Nat.Coprime.pow_left _
        ((Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr (odd_two_pow_sub_one hj))
    have hdvd : 2 ^ g ∣ 2 ^ b := (Nat.Coprime.dvd_of_dvd_mul_right hcop) (by simpa [stair] using h)
    exact (Nat.pow_dvd_pow_iff_le_right (by norm_num)).mp hdvd
  · intro h
    exact Dvd.dvd.mul_right (pow_dvd_pow 2 h) _

/-! ## 2.  Which staircase numbers live in a dyadic octave -/

/-- **Octave classification.**  A staircase number in `(2^(n-1), 2^n]` is either the top point
`2^n` itself, or a rung of weight exactly `n` with at least two ones. -/
theorem staircase_in_octave {n b j : ℕ} (hn : 1 ≤ n) (hj : 1 ≤ j)
    (hlo : 2 ^ (n - 1) < stair b j) (hhi : stair b j ≤ 2 ^ n) :
    (j = 1 ∧ b = n) ∨ (2 ≤ j ∧ b + j = n) := by
  have hhalf := two_pow_le_two_mul_stair (b := b) (j := j) hj
  have hlt := stair_lt_two_pow b j
  -- upper bound on the weight
  have hup : b + j ≤ n + 1 := by
    by_contra hcon
    have h1 : (2:ℕ) ^ (n + 2) ≤ 2 ^ (b + j) := Nat.pow_le_pow_right (by norm_num) (by omega)
    have h2 : (2:ℕ) ^ (n + 2) = 4 * 2 ^ n := by ring
    omega
  -- lower bound on the weight
  have hlow : n ≤ b + j := by
    by_contra hcon
    have h1 : (2:ℕ) ^ (b + j) ≤ 2 ^ (n - 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
    omega
  rcases Nat.lt_or_ge (b + j) (n + 1) with hcase | hcase
  · -- weight exactly `n`
    have hw : b + j = n := by omega
    refine Or.inr ⟨?_, hw⟩
    by_contra hj2
    have hj1 : j = 1 := by omega
    have : stair b j = 2 ^ (n - 1) := by
      rw [hj1, stair_one]
      congr 1
      omega
    omega
  · -- weight `n + 1` forces the top point
    have hw : b + j = n + 1 := by omega
    have hb : n ≤ b := by
      have h1 := stair_add_two_pow b j
      rw [hw] at h1
      have h2 : (2:ℕ) ^ (n + 1) = 2 * 2 ^ n := by ring
      have h3 : (2:ℕ) ^ n ≤ 2 ^ b := by omega
      exact (Nat.pow_le_pow_iff_right (by norm_num)).mp h3
    exact Or.inl ⟨by omega, by omega⟩

/-! ## 3.  The census -/

open scoped Classical in
/-- The set of grid-admissible knee candidates in the octave `(2^(n-1), 2^n]`: staircase numbers
divisible by the grid step `2 ^ g`. -/
noncomputable def octaveCandidates (n g : ℕ) : Finset ℕ :=
  (Finset.Ioc (2 ^ (n - 1)) (2 ^ n)).filter (fun k => IsStaircase k ∧ 2 ^ g ∣ k)

/-- The explicit census: the top point together with the rungs `2^n - 2^(n-j)`,
`2 ≤ j ≤ n - g`. -/
noncomputable def octaveCensus (n g : ℕ) : Finset ℕ :=
  insert (2 ^ n) ((Finset.Icc 2 (n - g)).image (fun j => stair (n - j) j))

theorem stair_octave_mem {n j : ℕ} (hj1 : 2 ≤ j) (hjn : j ≤ n) :
    2 ^ (n - 1) < stair (n - j) j ∧ stair (n - j) j ≤ 2 ^ n := by
  have hw : n - j + j = n := by omega
  have hadd := stair_add_two_pow (n - j) j
  rw [hw] at hadd
  have hle : (2:ℕ) ^ (n - j) ≤ 2 ^ (n - 2) := Nat.pow_le_pow_right (by norm_num) (by omega)
  have hn2 : (2:ℕ) ^ (n - 1) = 2 * 2 ^ (n - 2) := by
    have : n - 1 = (n - 2) + 1 := by omega
    rw [this]; ring
  have hn1 : (2:ℕ) ^ n = 2 * 2 ^ (n - 1) := by
    have : n = (n - 1) + 1 := by omega
    calc (2:ℕ) ^ n = 2 ^ ((n - 1) + 1) := by rw [← this]
      _ = 2 * 2 ^ (n - 1) := by ring
  have hpos : 0 < (2:ℕ) ^ (n - j) := one_le_two_pow _
  omega

/-- **The census is exact.**  Membership in the grid-admissible population of the octave is
completely characterised. -/
theorem mem_octaveCandidates_iff {n g k : ℕ} (hn : 1 ≤ n) (hg : g < n) :
    k ∈ octaveCandidates n g ↔ k ∈ octaveCensus n g := by
  classical
  constructor
  · intro hk
    rw [octaveCandidates, Finset.mem_filter, Finset.mem_Ioc] at hk
    obtain ⟨⟨hlo, hhi⟩, ⟨b, j, hj, rfl⟩, hdvd⟩ := hk
    have hgb : g ≤ b := (two_pow_dvd_stair_iff hj).mp hdvd
    rcases staircase_in_octave hn hj hlo hhi with ⟨hj1, hb⟩ | ⟨hj2, hw⟩
    · subst hj1; subst hb
      simp [octaveCensus, stair_one]
    · have hjle : j ≤ n - g := by omega
      have hbj : b = n - j := by omega
      subst hbj
      refine Finset.mem_insert_of_mem ?_
      exact Finset.mem_image.mpr ⟨j, Finset.mem_Icc.mpr ⟨hj2, hjle⟩, rfl⟩
  · intro hk
    rw [octaveCensus, Finset.mem_insert] at hk
    rw [octaveCandidates, Finset.mem_filter, Finset.mem_Ioc]
    rcases hk with rfl | hk
    · refine ⟨⟨?_, le_refl _⟩, isStaircase_two_pow n, ?_⟩
      · exact Nat.pow_lt_pow_right (by norm_num) (by omega)
      · exact pow_dvd_pow 2 (by omega)
    · obtain ⟨j, hjmem, rfl⟩ := Finset.mem_image.mp hk
      rw [Finset.mem_Icc] at hjmem
      have hjn : j ≤ n := by omega
      obtain ⟨hlo, hhi⟩ := stair_octave_mem hjmem.1 hjn
      refine ⟨⟨hlo, hhi⟩, isStaircase_stair (by omega), ?_⟩
      exact (two_pow_dvd_stair_iff (by omega : 1 ≤ j)).mpr (by omega)

theorem octaveCandidates_eq_census {n g : ℕ} (hn : 1 ≤ n) (hg : g < n) :
    octaveCandidates n g = octaveCensus n g :=
  Finset.ext (fun _ => mem_octaveCandidates_iff hn hg)

/-- **Logarithmic scarcity of knee candidates.**  The octave `(2^(n-1), 2^n]` contains exactly
`n - g = log₂(top point / grid step)` grid-admissible staircase numbers.  Halving the grid step
adds exactly one candidate. -/
theorem octave_census_card {n g : ℕ} (hn : 1 ≤ n) (hg : g < n) :
    (octaveCandidates n g).card = n - g := by
  classical
  rw [octaveCandidates_eq_census hn hg, octaveCensus]
  have hinj : Set.InjOn (fun j => stair (n - j) j) (Finset.Icc 2 (n - g) : Finset ℕ) := by
    intro x hx y hy hxy
    rw [Finset.mem_coe, Finset.mem_Icc] at hx hy
    exact (stair_injective2 (by omega) (by omega) hxy).2
  have hnotmem : (2:ℕ) ^ n ∉ (Finset.Icc 2 (n - g)).image (fun j => stair (n - j) j) := by
    intro hmem
    obtain ⟨j, hjmem, hj⟩ := Finset.mem_image.mp hmem
    rw [Finset.mem_Icc] at hjmem
    have hw : n - j + j = n := by omega
    have := stair_lt_two_pow (n - j) j
    rw [hw, hj] at this
    exact lt_irrefl _ this
  rw [Finset.card_insert_of_notMem hnotmem, Finset.card_image_of_injOn hinj,
    Nat.card_Icc]
  omega


/-- Parametrisation of the census members: each admissible knee is either the top point
`2 ^ n = stair n 1` or a rung `stair (n - j) j` with `2 ≤ j ≤ n - g`. -/
theorem mem_census_param {n g k : ℕ} (hn : 1 ≤ n) (hg : g < n)
    (hk : k ∈ octaveCandidates n g) :
    k = stair n 1 ∨ ∃ j, 2 ≤ j ∧ j ≤ n - g ∧ k = stair (n - j) j := by
  rw [octaveCandidates_eq_census hn hg, octaveCensus, Finset.mem_insert] at hk
  rcases hk with rfl | hk
  · exact Or.inl (by rw [stair_one])
  · obtain ⟨j, hjmem, hj⟩ := Finset.mem_image.mp hk
    rw [Finset.mem_Icc] at hjmem
    exact Or.inr ⟨j, hjmem.1, hjmem.2, hj.symm⟩

/-! ## 5.  Deployment reading: the census bracket and its self-similarity -/

/-- Every admissible knee is at most the product point `2 ^ n` — the product law
`k* ≤ d·ctx/32`, here as a theorem about the census. -/
theorem census_le_top {n g k : ℕ} (hk : k ∈ octaveCandidates n g) : k ≤ 2 ^ n := by
  classical
  rw [octaveCandidates, Finset.mem_filter, Finset.mem_Ioc] at hk
  exact hk.1.2

/-- Every admissible knee is at least three quarters of the product point.  Together with
`census_le_top` this is the **bracket**: the whole seed distribution lies in
`[(3/4)·2^n, 2^n]`. -/
theorem census_ge_three_quarters {n g k : ℕ} (hn : 2 ≤ n) (hg : g < n)
    (hk : k ∈ octaveCandidates n g) : 3 * 2 ^ n ≤ 4 * k := by
  rcases mem_census_param (by omega) hg hk with rfl | ⟨j, hj2, hjn, rfl⟩
  · rw [stair_one]; omega
  · have hw : n - j + j = n := by omega
    have hadd := stair_add_two_pow (n - j) j
    rw [hw] at hadd
    have hle : (2:ℕ) ^ (n - j) ≤ 2 ^ (n - 2) := Nat.pow_le_pow_right (by norm_num) (by omega)
    have h4 : (4:ℕ) * 2 ^ (n - 2) = 2 ^ n := by
      have : n = (n - 2) + 2 := by omega
      calc (4:ℕ) * 2 ^ (n - 2) = 2 ^ ((n - 2) + 2) := by ring
        _ = 2 ^ n := by rw [← this]
    omega

/-- **The over-provisioning factor is exactly `4/3`.**  Deploying at the product point when the
true knee is the smallest admissible one wastes a factor `4/3` — independently of the context
`n` and of the grid `g`.  (`128` versus `96` at the NET-47 cell.) -/
theorem census_waste_ratio {n g : ℕ} (hn : 2 ≤ n) (hg : g + 2 ≤ n) :
    4 * stair (n - 2) 2 = 3 * 2 ^ n ∧ stair (n - 2) 2 ∈ octaveCandidates n g := by
  constructor
  · have h4 : (4:ℕ) * 2 ^ (n - 2) = 2 ^ n := by
      have hn2 : n = (n - 2) + 2 := by omega
      calc (4:ℕ) * 2 ^ (n - 2) = 2 ^ ((n - 2) + 2) := by ring
        _ = 2 ^ n := by rw [← hn2]
    rw [stair]
    norm_num
    omega
  · rw [octaveCandidates_eq_census (by omega) (by omega), octaveCensus]
    exact Finset.mem_insert_of_mem
      (Finset.mem_image.mpr ⟨2, Finset.mem_Icc.mpr ⟨le_refl 2, by omega⟩, rfl⟩)

/-- The product point is always admissible. -/
theorem top_mem_census {n g : ℕ} (hn : 1 ≤ n) (hg : g < n) :
    2 ^ n ∈ octaveCandidates n g := by
  rw [octaveCandidates_eq_census hn hg, octaveCensus]
  exact Finset.mem_insert_self _ _

/-- **Identifiability.**  A census determines the cell that produced it: the maximum recovers the
product point `2 ^ n` and the number of admissible knees recovers the grid ratio, hence `g`.  A
reported knee set carries its own measurement metadata. -/
theorem census_determines_params {n g n' g' : ℕ} (hn : 1 ≤ n) (hg : g < n) (hn' : 1 ≤ n')
    (hg' : g' < n') (h : octaveCandidates n g = octaveCandidates n' g') : n = n' ∧ g = g' := by
  have hmax : (2:ℕ) ^ n ≤ 2 ^ n' := census_le_top (h ▸ top_mem_census hn hg)
  have hmax' : (2:ℕ) ^ n' ≤ 2 ^ n := census_le_top (h ▸ top_mem_census hn' hg')
  have hnn : n = n' := by
    have h1 : n ≤ n' := (Nat.pow_le_pow_iff_right (by norm_num)).mp hmax
    have h2 : n' ≤ n := (Nat.pow_le_pow_iff_right (by norm_num)).mp hmax'
    omega
  refine ⟨hnn, ?_⟩
  have hc : n - g = n' - g' := by
    rw [← octave_census_card hn hg, ← octave_census_card hn' hg', h]
  omega

/-- **Renormalisation.**  Doubling the product point and the grid step doubles the whole census:
the knee population is exactly self-similar under `(n, g) ↦ (n+1, g+1)`.  This is the census-level
form of the product law's proportionality `k* ∝ d·ctx`. -/
theorem census_scaling {n g : ℕ} (hn : 1 ≤ n) (hg : g < n) :
    (octaveCandidates n g).image (fun k => 2 * k) = octaveCandidates (n + 1) (g + 1) := by
  classical
  rw [octaveCandidates_eq_census hn hg,
    octaveCandidates_eq_census (by omega) (by omega : g + 1 < n + 1), octaveCensus, octaveCensus]
  have hidx : n + 1 - (g + 1) = n - g := by omega
  rw [hidx, Finset.image_insert]
  congr 1
  · ring
  · rw [Finset.image_image]
    apply Finset.image_congr
    intro j hj
    rw [Finset.mem_coe, Finset.mem_Icc] at hj
    have hnj : n + 1 - j = (n - j) + 1 := by omega
    simp only [Function.comp_apply, hnj, stair, pow_succ]
    ring

/-! ## 6.  The NET-47 cell and the 7/8 median law -/

/-- **The measured knee distribution is the whole census.**  At `(d = 4, ctx = 1024)` the product
point is `2^7 = 128` and the sweep grid step is `16 = 2^4`; the grid-admissible staircase
population of the octave `(64, 128]` is exactly `{96, 112, 128}` — the three-seed distribution
reported by NET-37 / NET-44 / NET-47. -/
theorem net47_census : octaveCandidates 7 4 = ({96, 112, 128} : Finset ℕ) := by
  rw [octaveCandidates_eq_census (by norm_num) (by norm_num), octaveCensus]
  have hIcc : Finset.Icc 2 (7 - 4) = ({2, 3} : Finset ℕ) := by decide
  rw [hIcc]
  have h2 : stair (7 - 2) 2 = 96 := net47_ninetysix
  have h3 : stair (7 - 3) 3 = 112 := net47_onetwelve
  simp only [Finset.image_insert, Finset.image_singleton, h2, h3]
  decide

/-- Three seeds exhausted the population: there are exactly three admissible knees. -/
theorem net47_census_card : (octaveCandidates 7 4).card = 3 := by
  rw [octave_census_card (by norm_num) (by norm_num)]

/-- **The 7/8 median law.**  Whenever the sweep grid is one eighth of the product point
(`n - g = 3`) the census is a three-point arithmetic progression whose middle point is exactly
`(7/8)·2^n`.  The "7/8 median" of the round is therefore a statement about the *grid ratio*, not
about the network: it predicts, e.g., the census `{192, 224, 256}` with median `224` at `n = 8`,
`g = 5`. -/
theorem seven_eighths_median_law {n g : ℕ} (hn : 3 ≤ n) (hg : n - g = 3) :
    octaveCandidates n g =
        ({stair (n - 2) 2, stair (n - 3) 3, 2 ^ n} : Finset ℕ) ∧
      8 * stair (n - 3) 3 = 7 * 2 ^ n ∧
      2 * stair (n - 3) 3 = stair (n - 2) 2 + 2 ^ n := by
  have hg' : g < n := by omega
  refine ⟨?_, ?_, ?_⟩
  · rw [octaveCandidates_eq_census (by omega) hg', octaveCensus, hg]
    have hIcc : Finset.Icc 2 3 = ({2, 3} : Finset ℕ) := by decide
    rw [hIcc]
    simp only [Finset.image_insert, Finset.image_singleton]
    ext x
    simp only [Finset.mem_insert, Finset.mem_singleton]
    tauto
  · have h : n - 3 + 3 = n := by omega
    have := stair_fraction_of_top (n - 3) 2
    rw [show n - 3 + 2 + 1 = n by omega] at this
    simpa using this
  · have := two_mul_stair_succ (n - 3) 2
    rw [show n - 3 + 1 = n - 2 by omega, show n - 3 + 2 + 1 = n by omega] at this
    exact this

/-- The `ctx = 2048` prediction of the census law: at `n = 8` with grid step `32 = 2^5` the
admissible knees are `{192, 224, 256}`, median `224 = (7/8)·256`. -/
theorem census_prediction_2048 : octaveCandidates 8 5 = ({192, 224, 256} : Finset ℕ) := by
  obtain ⟨h, -, -⟩ := seven_eighths_median_law (n := 8) (g := 5) (by norm_num) (by norm_num)
  rw [h]
  norm_num [stair]

end KneeStaircase