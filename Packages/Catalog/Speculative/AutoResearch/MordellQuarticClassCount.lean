import Mathlib
import NumberTheory.MordellDenominatorQuartic
import Speculative.AutoResearch.MordellDenominatorDensity

/-!
# Layer-4 class counts: the quadratic character of `3` breaks the linear-in-`ℓ` law

Cycle 2 of this thread computed, for a fixed prime `ℓ`, the total number of
denominator-producing residue pairs `(N mod ℓ, x mod ℓ)`:

* layer 2 (`ψ₂`, criterion `ℓ ∣ x³ + N`) : the total is exactly `ℓ`;
* layer 3 (`ψ₃ = 3x(x³ + 4N)`)          : the total is exactly `2ℓ - 1`.

Conjecture **D1** of the previous cycle extrapolated: the layer-`n` total should be
`k·ℓ + O(1)` with `k` the number of `ℚ(N)`-irreducible factors of `ψ_n`, uniformly in `ℓ`.
Since the layer-4 locus is `Ψ₄ = (x³ + N)·S(x)` with `S = x⁶ + 20Nx³ - 8N²` irreducible over
`ℚ(N)`, D1 predicts `2ℓ + O(1)`.

**This is false.**  The layer-4 total is

`∑_{c mod ℓ} #{x mod ℓ : ℓ ∣ Ψ₄}  =  3ℓ - 2`  if `3` is a square mod `ℓ`  (`ℓ ≡ ±1 mod 12`),
`                              =  ℓ`         if `3` is not a square mod `ℓ`  (`ℓ ≡ ±5 mod 12`).

The reason is that `S` is *not* of Kummer type: completing the square gives
`(4c - 5x³)² = 27x⁶`, so the fibre over each `x ≠ 0` has `2` or `0` points according to the
quadratic character of `27 = 3³`, i.e. of `3`.  The layer-4 count is therefore governed by the
splitting of `ℓ` in `ℚ(√3) ⊂ ℚ(ζ₁₂)` — a genuinely *Chebotarev* phenomenon, in the spirit of
conjecture C2, and not by a factor count.  Averaged over `ℓ` the two values `3ℓ - 2` and `ℓ`
do give D1's prediction `2ℓ` in the mean, which is exactly why the naive extrapolation looked
plausible.

## Main results

* `sum_card_W4_of_isSquare_three`, `sum_card_W4_of_not_isSquare_three` : the new (sextic) locus
  contributes `2ℓ - 1` or `1` points according to the quadratic character of `3`.
* `sum_card_V4_of_isSquare_three` : `∑_c #V₄(c) = 3ℓ - 2` when `3` is a square mod `ℓ`.
* `sum_card_V4_of_not_isSquare_three` : `∑_c #V₄(c) = ℓ` when it is not.
* `isSquare_three_of_one_mod_twelve`, `not_isSquare_three_of_five_mod_twelve` : the quadratic
  reciprocity input identifying the two regimes.
* `layer4_total_not_linear` : **the refutation of D1** — there is no pair `(k, C)` with
  `|∑_c #V₄(c) - k·ℓ| ≤ C` for all primes `ℓ ≥ 5`.  Proved with Dirichlet's theorem on the
  progressions `1, 5 mod 12`.
* `layer4_totals_7_13_19` : the falsifiable form requested by D1, checked by decision
  procedure: the totals at `ℓ = 7, 13, 19` are `7`, `37`, `19` — not `2ℓ + O(1)`.
* `mem_V4_iff_dvd_Psi4` : the counted set really is the denominator locus of layer 4.
* `V4_nonempty_iff_V2_nonempty` : **layer 4 activates no new residue of `N`** — unconditionally,
  for every prime `ℓ ≥ 5`.  Although the layer-4 locus can be three times as large, it lives
  over exactly the residues `c` with `-c` a cube, because of the cube factorisation
  `-(5 + 3√3)/4 = ((-1-√3)/2)³` in `ℚ(√3)`.  Consequently
  `not_dvd_den_quadruple_of_blind_general`: a residue blind at layer 2 is blind at layer 4.
  This is the sharp boundary of conjecture D2: layer 3 (the free root `x ≡ 0`) is the only one
  of the first four layers that is active for every `N`.

-- !-- Lab Notes -- !--
Hypothesizer (D1, previous cycle): layer-`n` total `= #{irreducible factors of ψ_n}·ℓ + O(1)`.
Experimenter: computed `∑_c #V₄(c)` for `ℓ = 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43`
  (see `ComputationalEvidence.md`), obtaining `5, 7, 31, 37, 17, 19, 67, 85→29, …`; the value is
  `3ℓ - 2` exactly for `ℓ = 11, 13, 23, 37` and `ℓ` for `ℓ = 5, 7, 17, 19, 29, 31, 41, 43`.  The
  split is precisely `ℓ ≡ ±1 (mod 12)` versus `ℓ ≡ ±5 (mod 12)`, i.e. the quadratic character
  of `3`.  Both formulas are proved below, so D1 is false as stated.
Analyst: the failure is structural.  Layers 2 and 3 are Kummer (`T³ + N`, `T³ + 4N`, plus the
  free root `0`) and for those the fibre `{c : ℓ ∣ f(x, c)}` over each `x` is a *single* point,
  giving exactly `ℓ` per factor.  At layer 4 the fibre is cut out by a *quadratic* in `c`, so
  the fibre size is `1 + χ(27)` — the first genuinely non-Kummer layer.  The correct general
  statement replaces "number of factors" by "average fibre size", i.e. by a Chebotarev density
  in the `n`-division field; layer 4 is its first non-trivial instance.
Critic: `ℓ ≥ 5` is required (2, 3 invertible), and the `ℓ ≡ ±1 mod 12` description of the
  regimes is only used to produce the two infinite families in `layer4_total_not_linear`; the
  counting theorems themselves are stated with the intrinsic hypothesis `IsSquare (3 : ZMod ℓ)`
  and so are free of reciprocity.  No `sorry` below.
-/

namespace MordellQuarticCount

open Finset MordellQuartic MordellDensity

variable {ℓ : ℕ}

/-! ## The layer-4 loci -/

/-- The layer-4 locus attached to a residue `c = N mod ℓ`: the roots of
`Ψ₄ = (T³ + c)(T⁶ + 20cT³ - 8c²)`. -/
def V4 (ℓ : ℕ) [Fact ℓ.Prime] (c : ZMod ℓ) : Finset (ZMod ℓ) :=
  univ.filter fun t => (t ^ 3 + c) * (t ^ 6 + 20 * c * t ^ 3 - 8 * c ^ 2) = 0

/-- The *new* part of the layer-4 locus: the roots of the sextic `S = T⁶ + 20cT³ - 8c²`. -/
def W4 (ℓ : ℕ) [Fact ℓ.Prime] (c : ZMod ℓ) : Finset (ZMod ℓ) :=
  univ.filter fun t => t ^ 6 + 20 * c * t ^ 3 - 8 * c ^ 2 = 0

/-- The transposed fibre: for a fixed `x = t`, the residues `c = N mod ℓ` with `S(t, c) = 0`. -/
def Wfib (ℓ : ℕ) [Fact ℓ.Prime] (t : ZMod ℓ) : Finset (ZMod ℓ) :=
  univ.filter fun c => t ^ 6 + 20 * c * t ^ 3 - 8 * c ^ 2 = 0

lemma mem_V4 [Fact ℓ.Prime] {c t : ZMod ℓ} :
    t ∈ V4 ℓ c ↔ (t ^ 3 + c) * (t ^ 6 + 20 * c * t ^ 3 - 8 * c ^ 2) = 0 := by simp [V4]

lemma mem_W4 [Fact ℓ.Prime] {c t : ZMod ℓ} :
    t ∈ W4 ℓ c ↔ t ^ 6 + 20 * c * t ^ 3 - 8 * c ^ 2 = 0 := by simp [W4]

lemma mem_Wfib [Fact ℓ.Prime] {c t : ZMod ℓ} :
    c ∈ Wfib ℓ t ↔ t ^ 6 + 20 * c * t ^ 3 - 8 * c ^ 2 = 0 := by simp [Wfib]

/-- **The counted set is the denominator locus.**  For an integral point with `x`-coordinate
`x` on `E_N`, membership of the reduction of `x` in `V₄` is exactly the layer-4 divisibility
criterion `ℓ ∣ Ψ₄(x)` of `MordellQuartic.dvd_den_quadruple_point_iff`. -/
theorem mem_V4_iff_dvd_Psi4 [Fact ℓ.Prime] (N x : ℤ) :
    ((x : ZMod ℓ)) ∈ V4 ℓ ((N : ZMod ℓ)) ↔ (ℓ : ℤ) ∣ Psi4 N x := by
  rw [mem_V4, ← ZMod.intCast_zmod_eq_zero_iff_dvd, Psi4, sextic]
  push_cast
  constructor <;> intro h <;> linear_combination h

/-- The layer-4 locus is the union of the layer-2 locus and the new sextic locus. -/
lemma V4_eq_union [Fact ℓ.Prime] (c : ZMod ℓ) : V4 ℓ c = V2 ℓ c ∪ W4 ℓ c := by
  ext t
  simp only [mem_V4, Finset.mem_union, mem_V2, mem_W4, mul_eq_zero]

/-! ## The fibres of the sextic locus -/

lemma card_Wfib_zero [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) : (Wfib ℓ 0).card = 1 := by
  have h2 : ((2 : ZMod ℓ)) ≠ 0 := MordellPointCount.two_ne_zero_zmod hl5
  have h8 : ((8 : ZMod ℓ)) ≠ 0 := by
    have h : (8 : ZMod ℓ) = 2 ^ 3 := by norm_num
    rw [h]; exact pow_ne_zero _ h2
  have hset : Wfib ℓ 0 = {0} := by
    ext c
    simp only [mem_Wfib, Finset.mem_singleton]
    constructor
    · intro h
      have hz : (8 : ZMod ℓ) * c ^ 2 = 0 := by linear_combination -h
      rcases mul_eq_zero.mp hz with h' | h'
      · exact absurd h' h8
      · exact pow_eq_zero_iff two_ne_zero |>.mp h'
    · rintro rfl; ring
  rw [hset, Finset.card_singleton]

/-- Completing the square: `S(t, c) = 0` iff `(4c - 5t³)² = 27 t⁶`. -/
lemma mem_Wfib_iff_sq [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) {t c : ZMod ℓ} :
    c ∈ Wfib ℓ t ↔ (4 * c - 5 * t ^ 3) ^ 2 = 27 * (t ^ 3) ^ 2 := by
  have h2 : ((2 : ZMod ℓ)) ≠ 0 := MordellPointCount.two_ne_zero_zmod hl5
  rw [mem_Wfib]
  constructor
  · intro h; linear_combination -2 * h
  · intro h
    have hz : (-2 : ZMod ℓ) * (t ^ 6 + 20 * c * t ^ 3 - 8 * c ^ 2) = 0 := by
      linear_combination h
    rcases mul_eq_zero.mp hz with h' | h'
    · exact absurd (by linear_combination -h' : (2 : ZMod ℓ) = 0) h2
    · exact h'

/-- If `3` is a square mod `ℓ` then so is `27`. -/
lemma exists_sq_eq_27 [Fact ℓ.Prime] (h3 : IsSquare (3 : ZMod ℓ)) :
    ∃ s : ZMod ℓ, s ^ 2 = 27 := by
  obtain ⟨r, hr⟩ := h3
  exact ⟨3 * r, by rw [show (3 * r) ^ 2 = 9 * (r * r) by ring, ← hr]; norm_num⟩

/-- **Two points in the fibre** over each `x ≠ 0` when `3` is a square modulo `ℓ`. -/
lemma card_Wfib_of_isSquare [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : IsSquare (3 : ZMod ℓ))
    {t : ZMod ℓ} (ht : t ≠ 0) : (Wfib ℓ t).card = 2 := by
  obtain ⟨s, hs⟩ := exists_sq_eq_27 h3
  have h2 : ((2 : ZMod ℓ)) ≠ 0 := MordellPointCount.two_ne_zero_zmod hl5
  have h4 : ((4 : ZMod ℓ)) ≠ 0 := by
    have h : (4 : ZMod ℓ) = 2 ^ 2 := by norm_num
    rw [h]; exact pow_ne_zero _ h2
  have h27 : ((27 : ZMod ℓ)) ≠ 0 := by
    have hthree : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
    have h : (27 : ZMod ℓ) = 3 ^ 3 := by norm_num
    rw [h]; exact pow_ne_zero _ hthree
  have hsne : s ≠ 0 := by
    intro hc
    apply h27
    rw [← hs, hc]; ring
  set c₁ : ZMod ℓ := (5 * t ^ 3 + s * t ^ 3) / 4 with hc₁
  set c₂ : ZMod ℓ := (5 * t ^ 3 - s * t ^ 3) / 4 with hc₂
  have h4c₁ : 4 * c₁ = 5 * t ^ 3 + s * t ^ 3 := by
    rw [hc₁, mul_div_cancel₀ _ h4]
  have h4c₂ : 4 * c₂ = 5 * t ^ 3 - s * t ^ 3 := by
    rw [hc₂, mul_div_cancel₀ _ h4]
  have hset : Wfib ℓ t = {c₁, c₂} := by
    ext c
    rw [mem_Wfib_iff_sq hl5]
    simp only [Finset.mem_insert, Finset.mem_singleton]
    constructor
    · intro h
      have hfac : (4 * c - (5 * t ^ 3 + s * t ^ 3)) * (4 * c - (5 * t ^ 3 - s * t ^ 3)) = 0 := by
        linear_combination h - (t ^ 3) ^ 2 * hs
      rcases mul_eq_zero.mp hfac with h' | h'
      · left
        have : 4 * c = 4 * c₁ := by rw [h4c₁]; linear_combination h'
        exact mul_left_cancel₀ h4 this
      · right
        have : 4 * c = 4 * c₂ := by rw [h4c₂]; linear_combination h'
        exact mul_left_cancel₀ h4 this
    · rintro (rfl | rfl)
      · linear_combination (4 * c₁ - 5 * t ^ 3 + s * t ^ 3) * h4c₁ + (t ^ 3) ^ 2 * hs
      · linear_combination (4 * c₂ - 5 * t ^ 3 - s * t ^ 3) * h4c₂ + (t ^ 3) ^ 2 * hs
  have hne : c₁ ≠ c₂ := by
    intro hc
    have h4eq : 4 * c₁ = 4 * c₂ := by rw [hc]
    rw [h4c₁, h4c₂] at h4eq
    have hz : (2 : ZMod ℓ) * (s * t ^ 3) = 0 := by linear_combination h4eq
    rcases mul_eq_zero.mp hz with h | h
    · exact h2 h
    · rcases mul_eq_zero.mp h with h' | h'
      · exact hsne h'
      · exact ht (pow_eq_zero_iff three_ne_zero |>.mp h')
  rw [hset, Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]

/-- **Empty fibre** over each `x ≠ 0` when `3` is not a square modulo `ℓ`. -/
lemma card_Wfib_of_not_isSquare [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ¬ IsSquare (3 : ZMod ℓ))
    {t : ZMod ℓ} (ht : t ≠ 0) : (Wfib ℓ t).card = 0 := by
  rw [Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
  intro c hc
  rw [mem_Wfib_iff_sq hl5] at hc
  apply h3
  have hthree : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  have ht3 : t ^ 3 ≠ 0 := pow_ne_zero _ ht
  have hd : (3 : ZMod ℓ) * t ^ 3 ≠ 0 := mul_ne_zero hthree ht3
  have key : (3 : ZMod ℓ) * (3 * t ^ 3) ^ 2 = (4 * c - 5 * t ^ 3) ^ 2 := by
    linear_combination -hc
  refine ⟨(4 * c - 5 * t ^ 3) / (3 * t ^ 3), ?_⟩
  rw [div_mul_div_comm, eq_div_iff (mul_ne_zero hd hd)]
  linear_combination key

/-! ## The layer-4 totals -/

lemma sum_card_W4_eq_sum_card_Wfib [Fact ℓ.Prime] :
    ∑ c : ZMod ℓ, (W4 ℓ c).card = ∑ t : ZMod ℓ, (Wfib ℓ t).card := by
  simp_rw [W4, Wfib, Finset.card_filter]
  rw [Finset.sum_comm]

/-- **The sextic locus over a prime where `3` is a square**: `2ℓ - 1` points in total. -/
theorem sum_card_W4_of_isSquare_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (h3 : IsSquare (3 : ZMod ℓ)) : ∑ c : ZMod ℓ, (W4 ℓ c).card = 2 * ℓ - 1 := by
  classical
  rw [sum_card_W4_eq_sum_card_Wfib]
  have h0 : (0 : ZMod ℓ) ∈ (univ : Finset (ZMod ℓ)) := Finset.mem_univ _
  have hsplit : ∑ t : ZMod ℓ, (Wfib ℓ t).card
      = (Wfib ℓ 0).card + ∑ t ∈ univ.erase (0 : ZMod ℓ), (Wfib ℓ t).card :=
    (Finset.add_sum_erase _ _ h0).symm
  have hterm : ∀ t ∈ univ.erase (0 : ZMod ℓ), (Wfib ℓ t).card = 2 := fun t ht =>
    card_Wfib_of_isSquare hl5 h3 (Finset.mem_erase.mp ht).1
  have hcard : (univ.erase (0 : ZMod ℓ)).card = ℓ - 1 := by
    rw [Finset.card_erase_of_mem h0, Finset.card_univ, ZMod.card]
  rw [hsplit, Finset.sum_congr rfl hterm, Finset.sum_const, smul_eq_mul, hcard,
    card_Wfib_zero hl5]
  omega

/-- **The sextic locus over a prime where `3` is not a square**: a single point in total. -/
theorem sum_card_W4_of_not_isSquare_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (h3 : ¬ IsSquare (3 : ZMod ℓ)) : ∑ c : ZMod ℓ, (W4 ℓ c).card = 1 := by
  classical
  rw [sum_card_W4_eq_sum_card_Wfib]
  have h0 : (0 : ZMod ℓ) ∈ (univ : Finset (ZMod ℓ)) := Finset.mem_univ _
  have hsplit : ∑ t : ZMod ℓ, (Wfib ℓ t).card
      = (Wfib ℓ 0).card + ∑ t ∈ univ.erase (0 : ZMod ℓ), (Wfib ℓ t).card :=
    (Finset.add_sum_erase _ _ h0).symm
  have hterm : ∀ t ∈ univ.erase (0 : ZMod ℓ), (Wfib ℓ t).card = 0 := fun t ht =>
    card_Wfib_of_not_isSquare hl5 h3 (Finset.mem_erase.mp ht).1
  rw [hsplit, Finset.sum_congr rfl hterm, Finset.sum_const, smul_eq_mul, mul_zero,
    card_Wfib_zero hl5]
  omega

/-- The two layers meet only over `c = 0`, and there in the single class `x ≡ 0`. -/
lemma sum_card_inter [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) :
    ∑ c : ZMod ℓ, (V2 ℓ c ∩ W4 ℓ c).card = 1 := by
  classical
  have h0 : (0 : ZMod ℓ) ∈ (univ : Finset (ZMod ℓ)) := Finset.mem_univ _
  have hzero : (V2 ℓ 0 ∩ W4 ℓ 0).card = 1 := by
    have hset : V2 ℓ 0 ∩ W4 ℓ 0 = {0} := by
      ext t
      simp only [Finset.mem_inter, mem_V2, mem_W4, Finset.mem_singleton, add_zero]
      constructor
      · rintro ⟨h, -⟩
        exact pow_eq_zero_iff three_ne_zero |>.mp h
      · rintro rfl
        constructor <;> ring
    rw [hset, Finset.card_singleton]
  have hterm : ∀ c ∈ univ.erase (0 : ZMod ℓ), (V2 ℓ c ∩ W4 ℓ c).card = 0 := by
    intro c hc
    have hc0 : c ≠ 0 := (Finset.mem_erase.mp hc).1
    rw [Finset.card_eq_zero, Finset.eq_empty_iff_forall_notMem]
    intro t ht
    rw [Finset.mem_inter, mem_V2, mem_W4] at ht
    obtain ⟨h1, h2⟩ := ht
    have h27ne : ((27 : ZMod ℓ)) ≠ 0 := by
      have hthree : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
      have h : (27 : ZMod ℓ) = 3 ^ 3 := by norm_num
      rw [h]; exact pow_ne_zero _ hthree
    have ht3 : t ^ 3 = -c := by linear_combination h1
    have h6 : t ^ 6 = c ^ 2 := by
      calc t ^ 6 = (t ^ 3) ^ 2 := by ring
        _ = (-c) ^ 2 := by rw [ht3]
        _ = c ^ 2 := by ring
    rw [h6, ht3] at h2
    have hz : (27 : ZMod ℓ) * c ^ 2 = 0 := by linear_combination -h2
    rcases mul_eq_zero.mp hz with h | h
    · exact h27ne h
    · exact hc0 (pow_eq_zero_iff two_ne_zero |>.mp h)
  rw [← Finset.add_sum_erase _ _ h0, hzero, Finset.sum_congr rfl hterm]
  simp

lemma sum_card_V4_add_inter [Fact ℓ.Prime] :
    (∑ c : ZMod ℓ, (V4 ℓ c).card) + ∑ c : ZMod ℓ, (V2 ℓ c ∩ W4 ℓ c).card
      = (∑ c : ZMod ℓ, (V2 ℓ c).card) + ∑ c : ZMod ℓ, (W4 ℓ c).card := by
  rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [V4_eq_union]
  exact Finset.card_union_add_card_inter _ _

/-- **The layer-4 total at a prime where `3` is a square** (`ℓ ≡ ±1 mod 12`): `3ℓ - 2`. -/
theorem sum_card_V4_of_isSquare_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (h3 : IsSquare (3 : ZMod ℓ)) : ∑ c : ZMod ℓ, (V4 ℓ c).card = 3 * ℓ - 2 := by
  have h := sum_card_V4_add_inter (ℓ := ℓ)
  rw [sum_card_inter hl5, sum_card_V2, sum_card_W4_of_isSquare_three hl5 h3] at h
  omega

/-- **The layer-4 total at a prime where `3` is not a square** (`ℓ ≡ ±5 mod 12`): `ℓ`. -/
theorem sum_card_V4_of_not_isSquare_three [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ)
    (h3 : ¬ IsSquare (3 : ZMod ℓ)) : ∑ c : ZMod ℓ, (V4 ℓ c).card = ℓ := by
  have h := sum_card_V4_add_inter (ℓ := ℓ)
  rw [sum_card_inter hl5, sum_card_V2, sum_card_W4_of_not_isSquare_three hl5 h3] at h
  omega

/-! ## The two regimes, by quadratic reciprocity -/

/-- `2` is not a square modulo `3`. -/
lemma not_isSquare_two_zmod_three : ¬ IsSquare (2 : ZMod 3) := by decide

/-- For `ℓ ≡ 1 (mod 12)` the residue `3` is a square modulo `ℓ`. -/
theorem isSquare_three_of_one_mod_twelve {ℓ : ℕ} [Fact ℓ.Prime] (h : ℓ % 12 = 1) :
    IsSquare (3 : ZMod ℓ) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have h4 : ℓ % 4 = 1 := by omega
  have hcast : ((3 : ℕ) : ZMod ℓ) = (3 : ZMod ℓ) := by norm_num
  have hmain := ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_one (p := ℓ) (q := 3) h4 (by norm_num)
  rw [hcast] at hmain
  refine hmain.mpr ?_
  have h3 : ((ℓ : ℕ) : ZMod 3) = ((ℓ % 3 : ℕ) : ZMod 3) := (ZMod.natCast_mod ℓ 3).symm
  have : ℓ % 3 = 1 := by omega
  rw [h3, this]
  exact ⟨1, by norm_num⟩

/-- For `ℓ ≡ 5 (mod 12)` the residue `3` is not a square modulo `ℓ`. -/
theorem not_isSquare_three_of_five_mod_twelve {ℓ : ℕ} [Fact ℓ.Prime] (h : ℓ % 12 = 5) :
    ¬ IsSquare (3 : ZMod ℓ) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have h4 : ℓ % 4 = 1 := by omega
  have hcast : ((3 : ℕ) : ZMod ℓ) = (3 : ZMod ℓ) := by norm_num
  have hmain := ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_one (p := ℓ) (q := 3) h4 (by norm_num)
  rw [hcast] at hmain
  intro hsq
  have h3 : ((ℓ : ℕ) : ZMod 3) = ((ℓ % 3 : ℕ) : ZMod 3) := (ZMod.natCast_mod ℓ 3).symm
  have hmod : ℓ % 3 = 2 := by omega
  have hIS := hmain.mp hsq
  have hcast2 : ((2 : ℕ) : ZMod 3) = 2 := by norm_num
  rw [h3, hmod, hcast2] at hIS
  exact absurd hIS not_isSquare_two_zmod_three


/-- For `ℓ ≡ 7 (mod 12)` the residue `3` is not a square modulo `ℓ` (the reciprocity case
`ℓ ≡ 3 mod 4`). -/
theorem not_isSquare_three_of_seven_mod_twelve {ℓ : ℕ} [Fact ℓ.Prime] (h : ℓ % 12 = 7) :
    ¬ IsSquare (3 : ZMod ℓ) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  have h4 : ℓ % 4 = 3 := by omega
  have hne : ℓ ≠ 3 := by omega
  have hcast : ((3 : ℕ) : ZMod ℓ) = (3 : ZMod ℓ) := by norm_num
  have hmain := ZMod.exists_sq_eq_prime_iff_of_mod_four_eq_three (p := ℓ) (q := 3) h4
    (by norm_num) hne
  rw [hcast] at hmain
  intro hsq
  refine hmain.mp hsq ?_
  have h3 : ((ℓ : ℕ) : ZMod 3) = ((ℓ % 3 : ℕ) : ZMod 3) := (ZMod.natCast_mod ℓ 3).symm
  have hmod : ℓ % 3 = 1 := by omega
  rw [h3, hmod]
  exact ⟨1, by norm_num⟩

/-! ## Layer 4 sees exactly the layer-2 locus at the non-residue primes -/

/-- When `3` is not a square modulo `ℓ`, the new (sextic) part of the layer-4 locus is empty
over every nonzero residue. -/
lemma W4_eq_empty_of_not_isSquare [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ¬ IsSquare (3 : ZMod ℓ))
    {c : ZMod ℓ} (hc : c ≠ 0) : W4 ℓ c = ∅ := by
  rw [Finset.eq_empty_iff_forall_notMem]
  intro t ht
  rw [mem_W4] at ht
  have h2 : ((2 : ZMod ℓ)) ≠ 0 := MordellPointCount.two_ne_zero_zmod hl5
  have h8 : ((8 : ZMod ℓ)) ≠ 0 := by
    have h : (8 : ZMod ℓ) = 2 ^ 3 := by norm_num
    rw [h]; exact pow_ne_zero _ h2
  have htne : t ≠ 0 := by
    intro hc0
    rw [hc0] at ht
    have hz : (8 : ZMod ℓ) * c ^ 2 = 0 := by linear_combination -ht
    rcases mul_eq_zero.mp hz with h | h
    · exact h8 h
    · exact hc (pow_eq_zero_iff two_ne_zero |>.mp h)
  have hmem : c ∈ Wfib ℓ t := by rw [mem_Wfib]; exact ht
  have := card_Wfib_of_not_isSquare hl5 h3 htne
  rw [Finset.card_eq_zero] at this
  rw [this] at hmem
  exact absurd hmem (Finset.notMem_empty c)

/-- **Layer 4 sees exactly what layer 2 sees, over the primes with `3` a non-residue.**
For such `ℓ` the layer-4 locus coincides with the layer-2 locus over every nonzero residue of
`N`; in particular the blind residues of the doubling layer stay blind at the quadrupling
layer.  Compare `MordellDensity.activeResidues3_eq_univ`: layer 3 *is* everywhere active, so
activity is not monotone along the tower. -/
theorem V4_eq_V2_of_not_isSquare [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (h3 : ¬ IsSquare (3 : ZMod ℓ))
    {c : ZMod ℓ} (hc : c ≠ 0) : V4 ℓ c = V2 ℓ c := by
  rw [V4_eq_union, W4_eq_empty_of_not_isSquare hl5 h3 hc, Finset.union_empty]

/-! ## Layer 4 produces no new active residues -/

/-- **The hidden cube.**  If the *new* layer-4 locus is nonempty over a residue `c`, then the
layer-2 locus over `c` is already nonempty.  The mechanism is the factorisation
`-(5 + 3√3)/4 = ((-1 - √3)/2)³` in `ℚ(√3)`: writing `s = (4c - 5t³)/t³` (so `s² = 27`) and
`g = s/3` (so `g² = 3`), a root `t` of the sextic gives the cube root
`-c = (((-1 - g)/2)·t)³` of `-c`. -/
theorem V2_nonempty_of_W4_nonempty [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) {c : ZMod ℓ}
    (h : (W4 ℓ c).Nonempty) : (V2 ℓ c).Nonempty := by
  obtain ⟨t, ht⟩ := h
  rw [mem_W4] at ht
  have h2 : ((2 : ZMod ℓ)) ≠ 0 := MordellPointCount.two_ne_zero_zmod hl5
  have h3 : ((3 : ZMod ℓ)) ≠ 0 := EllipticModCount.three_ne_zero_zmod (by omega)
  by_cases htz : t = 0
  · -- then `c = 0` and the layer-2 locus contains `0`
    have h8 : ((8 : ZMod ℓ)) ≠ 0 := by
      have h : (8 : ZMod ℓ) = 2 ^ 3 := by norm_num
      rw [h]; exact pow_ne_zero _ h2
    rw [htz] at ht
    have hz : (8 : ZMod ℓ) * c ^ 2 = 0 := by linear_combination -ht
    have hc0 : c = 0 := by
      rcases mul_eq_zero.mp hz with h | h
      · exact absurd h h8
      · exact pow_eq_zero_iff two_ne_zero |>.mp h
    exact ⟨0, by rw [mem_V2, hc0]; ring⟩
  · have ht3 : t ^ 3 ≠ 0 := pow_ne_zero _ htz
    have h3t : (3 : ZMod ℓ) * t ^ 3 ≠ 0 := mul_ne_zero h3 ht3
    obtain ⟨g, hgval⟩ : ∃ g : ZMod ℓ, g * (3 * t ^ 3) = 4 * c - 5 * t ^ 3 :=
      ⟨(4 * c - 5 * t ^ 3) / (3 * t ^ 3), div_mul_cancel₀ _ h3t⟩
    have hgsq : g ^ 2 = 3 := by
      have hsq : (g * (3 * t ^ 3)) ^ 2 = (4 * c - 5 * t ^ 3) ^ 2 := by rw [hgval]
      have hexp : g ^ 2 * (9 * (t ^ 3) ^ 2) = 27 * (t ^ 3) ^ 2 := by
        rw [show g ^ 2 * (9 * (t ^ 3) ^ 2) = (g * (3 * t ^ 3)) ^ 2 by ring, hsq]
        linear_combination -2 * ht
      have h9 : (9 : ZMod ℓ) * (t ^ 3) ^ 2 ≠ 0 := by
        refine mul_ne_zero ?_ (pow_ne_zero _ ht3)
        have h : (9 : ZMod ℓ) = 3 ^ 2 := by norm_num
        rw [h]; exact pow_ne_zero _ h3
      have := mul_right_cancel₀ h9 (by linear_combination hexp :
        g ^ 2 * (9 * (t ^ 3) ^ 2) = 3 * (9 * (t ^ 3) ^ 2))
      exact this
    refine ⟨((-1 - g) / 2) * t, ?_⟩
    rw [mem_V2]
    have h4 : ((4 : ZMod ℓ)) ≠ 0 := by
      have h : (4 : ZMod ℓ) = 2 ^ 2 := by norm_num
      rw [h]; exact pow_ne_zero _ h2
    have hhalf : ((-1 - g) / 2) * 2 = -1 - g := div_mul_cancel₀ _ h2
    have hcube : (((-1 - g) / 2) * t) ^ 3 * 8 = -(5 + 3 * g) * t ^ 3 * 2 := by
      have hexp : (((-1 - g) / 2) * t) ^ 3 * 8 = (((-1 - g) / 2) * 2) ^ 3 * t ^ 3 := by ring
      rw [hexp, hhalf]
      linear_combination (-3 * t ^ 3 - g * t ^ 3) * hgsq
    have hc4 : 4 * c = 5 * t ^ 3 + 3 * g * t ^ 3 := by linear_combination -hgval
    have h8ne : ((8 : ZMod ℓ)) ≠ 0 := by
      have h : (8 : ZMod ℓ) = 2 ^ 3 := by norm_num
      rw [h]; exact pow_ne_zero _ h2
    refine mul_right_cancel₀ h8ne ?_
    rw [add_mul, zero_mul, hcube]
    linear_combination 2 * hc4

/-- **Layer 4 is active exactly where layer 2 is.**  For every prime `ℓ ≥ 5` and every residue
`c = N mod ℓ`, the quadrupling layer produces a denominator class iff the doubling layer does.
So although layer 4 has up to three times as many producing pairs `(c, x)` as layer 2
(`sum_card_V4_of_isSquare_three`), it is active on exactly the same set of residues `N`, of
density `(ℓ+2)/(3ℓ)` at ordinary primes.  Layer 3 is the only one of the first four layers with
a `N`-free root (`MordellDensity.activeResidues3_eq_univ`). -/
theorem V4_nonempty_iff_V2_nonempty [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) (c : ZMod ℓ) :
    (V4 ℓ c).Nonempty ↔ (V2 ℓ c).Nonempty := by
  constructor
  · intro h
    obtain ⟨t, ht⟩ := h
    rw [V4_eq_union, Finset.mem_union] at ht
    rcases ht with h' | h'
    · exact ⟨t, h'⟩
    · exact V2_nonempty_of_W4_nonempty hl5 ⟨t, h'⟩
  · rintro ⟨t, ht⟩
    exact ⟨t, by rw [V4_eq_union, Finset.mem_union]; exact Or.inl ht⟩

/-- **Blind residues stay blind at layer 4** (unconditionally).  If `ℓ ≥ 5` and the residue
`N mod ℓ` is blind at the doubling layer — i.e. `-N` is not a cube modulo `ℓ`, which happens
for exactly `2(ℓ-1)/3` residues when `ℓ ≡ 1 (mod 3)` — then `ℓ` divides no denominator
`den x(4P)` either, for any integral point of `E_N` which is not `4`-torsion. -/
theorem not_dvd_den_quadruple_of_blind_general [Fact ℓ.Prime] (hl5 : 5 ≤ ℓ) {N x : ℤ}
    (hblind : ((N : ZMod ℓ)) ∈ blindResidues2 ℓ) (hlN : ¬(ℓ : ℤ) ∣ N)
    (hb : x ^ 3 + N ≠ 0) (hS : sextic N x ≠ 0) :
    ¬ ℓ ∣ (((phi4 N x : ℤ) : ℚ) / ((den4 N x : ℤ) : ℚ)).den := by
  have hprime : ℓ.Prime := Fact.out
  rw [dvd_den_quadruple_iff hb hS hprime hl5 hlN, ← mem_V4_iff_dvd_Psi4]
  intro hmem
  have hV2 := (V4_nonempty_iff_V2_nonempty hl5 ((N : ZMod ℓ))).mp ⟨_, hmem⟩
  have hempty : V2 ℓ ((N : ZMod ℓ)) = ∅ := by simpa [blindResidues2] using hblind
  rw [hempty] at hV2
  exact absurd hV2 (by simp)

/-! ## The refutation of conjecture D1 -/

/-- The layer-4 total, as a function of the prime. -/
def layer4Total (ℓ : ℕ) [Fact ℓ.Prime] : ℕ := ∑ c : ZMod ℓ, (V4 ℓ c).card

/-- **Refutation of conjecture D1.**  There is no slope `k` and no bounded error `C` with
`|layer4Total ℓ - k·ℓ| ≤ C` for all primes `ℓ ≥ 5`: the total is `ℓ` on the primes
`ℓ ≡ 5 (mod 12)` and `3ℓ - 2` on the primes `ℓ ≡ 1 (mod 12)`, and both progressions contain
arbitrarily large primes.  In particular the layer-4 count is *not* `(#factors of ψ₄)·ℓ + O(1)`;
it is governed by the quadratic character of `3`, i.e. by the splitting of `ℓ` in `ℚ(√3)`. -/
theorem layer4_total_not_linear :
    ¬ ∃ k C : ℕ, ∀ (ℓ : ℕ) [Fact ℓ.Prime], 5 ≤ ℓ →
      layer4Total ℓ ≤ k * ℓ + C ∧ k * ℓ ≤ layer4Total ℓ + C := by
  rintro ⟨k, C, hkC⟩
  -- a large prime `ℓ₂ ≡ 5 (mod 12)` forces `k = 1`
  obtain ⟨ℓ₂, hgt₂, hp₂, hmod₂⟩ :=
    Nat.forall_exists_prime_gt_and_modEq (C + 10) (q := 12) (a := 5) (by norm_num) (by decide)
  haveI : Fact ℓ₂.Prime := ⟨hp₂⟩
  have h₂ : ℓ₂ % 12 = 5 := hmod₂
  have htot₂ : layer4Total ℓ₂ = ℓ₂ :=
    sum_card_V4_of_not_isSquare_three (by omega) (not_isSquare_three_of_five_mod_twelve h₂)
  obtain ⟨hb₂a, hb₂b⟩ := hkC ℓ₂ (by omega)
  rw [htot₂] at hb₂a hb₂b
  have hk1 : k = 1 := by
    rcases Nat.lt_or_ge k 2 with hk | hk
    · interval_cases k
      · omega
      · rfl
    · have hmul : 2 * ℓ₂ ≤ k * ℓ₂ := Nat.mul_le_mul_right _ hk
      omega
  subst hk1
  -- a large prime `ℓ₁ ≡ 1 (mod 12)` then contradicts the bound
  obtain ⟨ℓ₁, hgt₁, hp₁, hmod₁⟩ :=
    Nat.forall_exists_prime_gt_and_modEq (C + 10) (q := 12) (a := 1) (by norm_num) (by decide)
  haveI : Fact ℓ₁.Prime := ⟨hp₁⟩
  have h₁ : ℓ₁ % 12 = 1 := hmod₁
  have htot₁ : layer4Total ℓ₁ = 3 * ℓ₁ - 2 :=
    sum_card_V4_of_isSquare_three (by omega) (isSquare_three_of_one_mod_twelve h₁)
  obtain ⟨hb₁a, -⟩ := hkC ℓ₁ (by omega)
  rw [htot₁] at hb₁a
  omega

/-! ## The falsifiable form of D1, checked -/

/-- **The computation D1 asked for.**  The layer-4 totals at `ℓ = 7, 13, 19` are `7`, `37`
and `19`.  D1 predicted a single slope `k` (the number of `ℚ(N)`-irreducible factors of `ψ₄`,
namely `2`) with a bounded error; the data show two different slopes, `1` and `3`, exactly
according to `ℓ ≡ ±1` or `±5 (mod 12)`. -/
private instance fact_prime_nineteen : Fact (Nat.Prime 19) := ⟨by norm_num⟩

theorem layer4_totals_7_13_19 :
    (∑ c : ZMod 7, (V4 7 c).card) = 7 ∧ (∑ c : ZMod 13, (V4 13 c).card) = 37 ∧
      (∑ c : ZMod 19, (V4 19 c).card) = 19 :=
  ⟨by decide, by decide, by decide⟩

end MordellQuarticCount