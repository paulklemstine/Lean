import Probability.ThreeCubes.Density
import Probability.ThreeCubes.Rational

/-!
# Unconditional lower bounds for sums of three cubes

`Probability.ThreeCubes.Density` gives the *upper* bound: at most `7/9` of all integers are
sums of three cubes (`ThreeCubes.card_isSumOfThreeCubes_le`), and
`ThreeCubes.densitySevenNinths_iff_hasse` shows that the matching lower bound — i.e. density
exactly `7/9` — is *equivalent* to the Hasse principle for the affine cubic surface, hence
completely out of reach at present.

This file proves the strongest lower bound that is unconditional, namely a power-saving one.
Counting the values `k³ + m³` with `K³ ≤ k < 2K³` and `0 ≤ m ≤ K²`, the "small" cube `m³` is
always smaller than the gap `(k+1)³ - k³ = 3k² + 3k + 1`, so `k` is recoverable from the value
as `⌊n^{1/3}⌋` and the parametrisation is *injective*
(`ThreeCubes.cube_pair_inj`).  This produces `K³(K²+1)` distinct representable integers below
`9K⁹`, i.e.

* `ThreeCubes.repCount_ge` : `K⁵ ≤ repCount (9K⁹)`, an `≫ N^{5/9}` lower bound for the
  counting function `repCount N = #{n ≤ N : n is a sum of three cubes}`.

The exponent `5/9` is exactly the classical elementary bound: `3/9` comes from the cubes
themselves and the extra `2/9` from the `k^{2/3}`-many admissible small cubes.  Any improvement
beyond the trivial multiplicativity of this construction requires genuine control of the
representation multiplicity, which is the content of Conjecture 3 of `FUTURE_DIRECTIONS.md`.

The last section records the sharp contrast with the *rational* problem: four rational cubes
always suffice, by a one-line identity (`ThreeCubes.isSumOfFourRationalCubes`), whereas over
`ℤ` the analogous statement for four cubes is open.
-/

namespace ThreeCubes

open Finset

/-! ### An injective two-parameter family of sums of two cubes -/

/-- If `k ≥ K³` and `m ≤ K²` then the "small" cube `m³` is smaller than the gap between two
consecutive cubes at `k`.  This is the engine of the injectivity below. -/
theorem small_cube_lt_gap {K k m : ℕ} (hk : K ^ 3 ≤ k) (hm : m ≤ K ^ 2) :
    m ^ 3 < 3 * k ^ 2 + 3 * k + 1 := by
  have h1 : m ^ 3 ≤ (K ^ 2) ^ 3 := Nat.pow_le_pow_left hm 3
  have h2 : (K ^ 3) ^ 2 ≤ k ^ 2 := Nat.pow_le_pow_left hk 2
  have h3 : (K ^ 2) ^ 3 = (K ^ 3) ^ 2 := by ring
  omega

/-- **Injectivity of the parametrisation `(k, m) ↦ k³ + m³`** on the range
`K³ ≤ k < 2K³`, `m ≤ K²`.  Indeed the value determines `k` (it lies in `[k³, (k+1)³)`) and
then `m`. -/
theorem cube_pair_inj {K k m k' m' : ℕ} (hk : K ^ 3 ≤ k) (hm : m ≤ K ^ 2)
    (hk' : K ^ 3 ≤ k') (hm' : m' ≤ K ^ 2) (h : k ^ 3 + m ^ 3 = k' ^ 3 + m' ^ 3) :
    k = k' ∧ m = m' := by
  have key : ∀ a b c d : ℕ, K ^ 3 ≤ a → b ≤ K ^ 2 → a < c →
      a ^ 3 + b ^ 3 < c ^ 3 + d ^ 3 := by
    intro a b c d ha hb hac
    have hgap : b ^ 3 < 3 * a ^ 2 + 3 * a + 1 := small_cube_lt_gap ha hb
    have hmono : (a + 1) ^ 3 ≤ c ^ 3 := Nat.pow_le_pow_left hac 3
    have hexp : (a + 1) ^ 3 = a ^ 3 + (3 * a ^ 2 + 3 * a + 1) := by ring
    omega
  have hkk : k = k' := by
    rcases lt_trichotomy k k' with hlt | heq | hgt
    · exact absurd h (Nat.ne_of_lt (key k m k' m' hk hm hlt))
    · exact heq
    · exact absurd h.symm (Nat.ne_of_lt (key k' m' k m hk' hm' hgt))
  subst hkk
  have hm3 : m ^ 3 = m' ^ 3 := by omega
  exact ⟨rfl, Nat.pow_left_injective (by norm_num) hm3⟩

/-- The set of values `k³ + m³` for `K³ ≤ k < 2K³` and `0 ≤ m ≤ K²`. -/
def cubeValues (K : ℕ) : Finset ℕ :=
  ((Finset.Ico (K ^ 3) (2 * K ^ 3)) ×ˢ (Finset.range (K ^ 2 + 1))).image
    (fun p => p.1 ^ 3 + p.2 ^ 3)

/-- The family is injective, so it has exactly `K³(K²+1)` elements. -/
theorem card_cubeValues (K : ℕ) : (cubeValues K).card = K ^ 3 * (K ^ 2 + 1) := by
  rw [cubeValues, Finset.card_image_of_injOn, Finset.card_product, Finset.card_range,
    Nat.card_Ico]
  · congr 1
    omega
  · rintro ⟨k, m⟩ hp ⟨k', m'⟩ hq h
    simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe,
      Finset.mem_Ico, Finset.mem_range] at hp hq
    have h' : k ^ 3 + m ^ 3 = k' ^ 3 + m' ^ 3 := h
    obtain ⟨hk, hm⟩ := cube_pair_inj hp.1.1 (by omega) hq.1.1 (by omega) h'
    simp [hk, hm]

/-- Every element of `cubeValues K` is a sum of three cubes (the third one being `0`). -/
theorem isSumOfThreeCubes_of_mem_cubeValues {K n : ℕ} (h : n ∈ cubeValues K) :
    IsSumOfThreeCubes (n : ℤ) := by
  rw [cubeValues, Finset.mem_image] at h
  obtain ⟨⟨k, m⟩, -, rfl⟩ := h
  exact ⟨(k : ℤ), (m : ℤ), 0, by push_cast; ring⟩

/-- Every element of `cubeValues K` is at most `9K⁹`. -/
theorem le_of_mem_cubeValues {K n : ℕ} (h : n ∈ cubeValues K) : n ≤ 9 * K ^ 9 := by
  rw [cubeValues, Finset.mem_image] at h
  obtain ⟨⟨k, m⟩, hp, rfl⟩ := h
  simp only [Finset.mem_product, Finset.mem_Ico, Finset.mem_range] at hp
  obtain ⟨⟨hk1, hk2⟩, hm⟩ := hp
  have hK : 1 ≤ K := by
    rcases Nat.eq_zero_or_pos K with rfl | hK
    · exfalso
      have hz : (2 : ℕ) * 0 ^ 3 = 0 := by norm_num
      rw [hz] at hk2
      omega
    · exact hK
  have h1 : k ^ 3 ≤ (2 * K ^ 3) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have h2 : m ^ 3 ≤ (K ^ 2) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have h3 : (2 * K ^ 3) ^ 3 = 8 * K ^ 9 := by ring
  have h4 : (K ^ 2) ^ 3 = K ^ 6 := by ring
  have h5 : K ^ 6 ≤ K ^ 9 := Nat.pow_le_pow_right hK (by norm_num)
  show k ^ 3 + m ^ 3 ≤ 9 * K ^ 9
  omega

open scoped Classical in
/-- The counting function of the sums of three cubes: the number of `n` with `0 ≤ n ≤ N`
that are sums of three integer cubes. -/
noncomputable def repCount (N : ℕ) : ℕ :=
  (Finset.filter (fun i : ℕ => IsSumOfThreeCubes (i : ℤ)) (Finset.range (N + 1))).card

open scoped Classical in
/-- **Power-saving lower bound.**  At least `K⁵` of the integers in `[0, 9K⁹]` are sums of
three cubes; equivalently `repCount N ≫ N^{5/9}`.  Contrast with
`ThreeCubes.card_isSumOfThreeCubes_le`, which gives the upper bound `7N/9`. -/
theorem repCount_ge (K : ℕ) : K ^ 5 ≤ repCount (9 * K ^ 9) := by
  have hsub : cubeValues K ⊆
      Finset.filter (fun i : ℕ => IsSumOfThreeCubes (i : ℤ)) (Finset.range (9 * K ^ 9 + 1)) := by
    intro n hn
    simp only [Finset.mem_filter, Finset.mem_range]
    exact ⟨by have := le_of_mem_cubeValues hn; omega,
      isSumOfThreeCubes_of_mem_cubeValues hn⟩
  have hcard := Finset.card_le_card hsub
  rw [card_cubeValues] at hcard
  rw [repCount]
  have h5 : K ^ 5 ≤ K ^ 3 * (K ^ 2 + 1) := by
    have : K ^ 3 * (K ^ 2 + 1) = K ^ 5 + K ^ 3 := by ring
    omega
  exact le_trans h5 hcard

open scoped Classical in
/-- `repCount` is monotone, so the lower bound propagates to every `N ≥ 9K⁹`. -/
theorem repCount_mono {M N : ℕ} (h : M ≤ N) : repCount M ≤ repCount N := by
  rw [repCount, repCount]
  apply Finset.card_le_card
  intro x hx
  simp only [Finset.mem_filter, Finset.mem_range] at hx ⊢
  exact ⟨by omega, hx.2⟩

open scoped Classical in
/-- The lower bound in the form usually quoted: for every `N ≥ 9K⁹` at least `K⁵` of the
integers below `N` are sums of three cubes. -/
theorem repCount_ge_of_le {K N : ℕ} (h : 9 * K ^ 9 ≤ N) : K ^ 5 ≤ repCount N :=
  le_trans (repCount_ge K) (repCount_mono h)

/-- In particular there are infinitely many sums of three cubes: the counting function is
unbounded. -/
theorem repCount_unbounded (M : ℕ) : ∃ N : ℕ, M ≤ repCount N :=
  ⟨9 * M ^ 9, le_trans (Nat.le_self_pow (by norm_num) M) (repCount_ge M)⟩

/-! ### Four rational cubes always suffice -/

/-- **Every rational number is a sum of four rational cubes**, by the identity
`6k = (k+1)³ + (k-1)³ + (-k)³ + (-k)³` applied to `k = q/6`.  Over `ℤ` the corresponding
statement is only known for multiples of `6` (`ThreeCubes.isSumOfFourCubes_of_six_dvd`), and
five integer cubes are needed in general (`ThreeCubes.isSumOfFiveCubes`); over `ℚ` the
divisibility obstruction evaporates. -/
theorem isSumOfFourRationalCubes (q : ℚ) :
    ∃ a b c d : ℚ, a ^ 3 + b ^ 3 + c ^ 3 + d ^ 3 = q :=
  ⟨q / 6 + 1, q / 6 - 1, -(q / 6), -(q / 6), by ring⟩

/-- The four rational cubes of `isSumOfFourRationalCubes` can moreover be taken to be a
*shifted pair* `(k+1, k-1)` together with a repeated cube `-k`, `k = q/6`. -/
theorem sum_four_rational_cubes_identity (k : ℚ) :
    (k + 1) ^ 3 + (k - 1) ^ 3 + (-k) ^ 3 + (-k) ^ 3 = 6 * k := by ring

end ThreeCubes