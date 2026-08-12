import Probability.LowerBounds

/-!
# A sharper unconditional lower bound: `repCount N ≫ N^{19/27}`

`Probability.ThreeCubes.LowerBounds` counts the values `k³ + m³` of a *two*-parameter family
and obtains `repCount N ≫ N^{5/9} = N^{15/27}`.  The bottleneck there is that the third cube is
never used: the small cube `m³` must stay below the gap `(k+1)³ - k³ ≍ k^{2/3·3}`, so
`m ≍ k^{2/3}` and one gets `k · k^{2/3} = k^{5/3}` values below `k³`.

Here we iterate the gap trick once more.  Take

* `x ∈ [8K⁹, 16K⁹)`,
* `y ∈ [2K⁶, 4K⁶)`,
* `z ∈ [K⁴, 2K⁴)`,

so that `y³ + z³` is below the cube gap at `x` **and** `z³` is below the cube gap at `y`.  Then
the value `n = x³ + y³ + z³` determines `x = ⌊n^{1/3}⌋`, then `y = ⌊(n - x³)^{1/3}⌋`, then `z`:
the parametrisation is injective (`ThreeCubes.cube_triple_inj`).  Counting,

`16 K¹⁹` distinct sums of three cubes lie in `[0, 4168 K²⁷]`,

which is the power saving `N^{19/27} = N^{0.7037…}`, a genuine improvement on `N^{5/9}` and
now quite close to the *upper* density `7/9` of `ThreeCubes.card_isSumOfThreeCubes_le`.

The exponents produced by nesting the gap trick over `r` cubes are
`1 - (2/3)^r`: the boxes have sizes `A`, `A^{2/3}`, `A^{4/9}`, …, `A^{(2/3)^{r-1}}`, so they
contain `A^{3(1-(2/3)^r)}` triples with values up to `A³`.  For `r = 2` this is `5/9`
(the bound of `LowerBounds`) and for `r = 3` it is `19/27` — and `r = 3` is the end of the
line for *three* cubes, so `19/27` is exactly the limit of the elementary gap method here.
Going beyond it requires bounding the multiplicity of representations rather than merely
constructing injective boxes.

Main results.

* `ThreeCubes.cube_gap_decode` — the decoding step: if a remainder is below the cube gap then
  the leading cube is determined.
* `ThreeCubes.cube_triple_inj` — injectivity of `(x, y, z) ↦ x³ + y³ + z³` on the boxes above.
* `ThreeCubes.repCount_ge_nineteen` — `16 K¹⁹ ≤ repCount (4168 K²⁷)`.
* `ThreeCubes.repCount_rpow_ge` — the same in real-exponent form:
  `N^{19/27} ≤ 23 · repCount N` for `N = 4168 K²⁷`.
-/

namespace ThreeCubes

open Finset

/-! ### The decoding step -/

/-- **Cube-gap decoding.**  If `b` and `b'` are below the respective cube gaps
`(a+1)³ - a³ = 3a² + 3a + 1`, then `a³ + b = a'³ + b'` forces `a = a'` and `b = b'`:
the leading cube is recoverable as `⌊n^{1/3}⌋`. -/
theorem cube_gap_decode {a b a' b' : ℕ} (hb : b < 3 * a ^ 2 + 3 * a + 1)
    (hb' : b' < 3 * a' ^ 2 + 3 * a' + 1) (h : a ^ 3 + b = a' ^ 3 + b') : a = a' ∧ b = b' := by
  have key : ∀ c d c' d' : ℕ, d < 3 * c ^ 2 + 3 * c + 1 → c < c' → c ^ 3 + d < c' ^ 3 + d' := by
    intro c d c' d' hd hcc
    have hmono : (c + 1) ^ 3 ≤ c' ^ 3 := Nat.pow_le_pow_left hcc 3
    have hexp : (c + 1) ^ 3 = c ^ 3 + (3 * c ^ 2 + 3 * c + 1) := by ring
    omega
  have haa : a = a' := by
    rcases lt_trichotomy a a' with hlt | heq | hgt
    · exact absurd h (Nat.ne_of_lt (key a b a' b' hb hlt))
    · exact heq
    · exact absurd h.symm (Nat.ne_of_lt (key a' b' a b hb' hgt))
  subst haa
  exact ⟨rfl, by omega⟩

/-! ### The three boxes and their gap inequalities -/

/-- On the box `y < 4K⁶`, `z < 2K⁴`, `8K⁹ ≤ x`, the pair `y³ + z³` is below the cube gap
at `x`. -/
theorem gap_bound_outer {K x y z : ℕ} (hx : 8 * K ^ 9 ≤ x) (hy : y < 4 * K ^ 6)
    (hz : z < 2 * K ^ 4) : y ^ 3 + z ^ 3 < 3 * x ^ 2 + 3 * x + 1 := by
  rcases Nat.eq_zero_or_pos K with rfl | hK
  · norm_num at hy
  have hy3 : y ^ 3 ≤ (4 * K ^ 6) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have hz3 : z ^ 3 ≤ (2 * K ^ 4) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have hx2 : (8 * K ^ 9) ^ 2 ≤ x ^ 2 := Nat.pow_le_pow_left hx 2
  have e1 : (4 * K ^ 6) ^ 3 = 64 * K ^ 18 := by ring
  have e2 : (2 * K ^ 4) ^ 3 = 8 * K ^ 12 := by ring
  have e3 : (8 * K ^ 9) ^ 2 = 64 * K ^ 18 := by ring
  have e4 : K ^ 12 ≤ K ^ 18 := Nat.pow_le_pow_right hK (by norm_num)
  omega

/-- On the box `2K⁶ ≤ y`, `z < 2K⁴`, the cube `z³` is below the cube gap at `y`. -/
theorem gap_bound_inner {K y z : ℕ} (hy : 2 * K ^ 6 ≤ y) (hz : z < 2 * K ^ 4) :
    z ^ 3 < 3 * y ^ 2 + 3 * y + 1 := by
  have hz3 : z ^ 3 ≤ (2 * K ^ 4) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have hy2 : (2 * K ^ 6) ^ 2 ≤ y ^ 2 := Nat.pow_le_pow_left hy 2
  have e1 : (2 * K ^ 4) ^ 3 = 8 * K ^ 12 := by ring
  have e2 : (2 * K ^ 6) ^ 2 = 4 * K ^ 12 := by ring
  omega

/-- **Injectivity of the three-parameter family.**  On the boxes `8K⁹ ≤ x < 16K⁹`,
`2K⁶ ≤ y < 4K⁶`, `K⁴ ≤ z < 2K⁴` the map `(x, y, z) ↦ x³ + y³ + z³` is injective. -/
theorem cube_triple_inj {K x y z x' y' z' : ℕ}
    (hx : 8 * K ^ 9 ≤ x) (hy : 2 * K ^ 6 ≤ y) (hy2 : y < 4 * K ^ 6) (hz : z < 2 * K ^ 4)
    (hx' : 8 * K ^ 9 ≤ x') (hy' : 2 * K ^ 6 ≤ y') (hy2' : y' < 4 * K ^ 6)
    (hz' : z' < 2 * K ^ 4)
    (h : x ^ 3 + y ^ 3 + z ^ 3 = x' ^ 3 + y' ^ 3 + z' ^ 3) : x = x' ∧ y = y' ∧ z = z' := by
  obtain ⟨hxx, hrest⟩ := cube_gap_decode (gap_bound_outer hx hy2 hz)
    (gap_bound_outer hx' hy2' hz') (by omega)
  obtain ⟨hyy, hzz⟩ := cube_gap_decode (gap_bound_inner hy hz) (gap_bound_inner hy' hz') hrest
  exact ⟨hxx, hyy, Nat.pow_left_injective (by norm_num) hzz⟩

/-! ### The counting -/

/-- The set of values `x³ + y³ + z³` for `x, y, z` in the three boxes. -/
def cubeTripleValues (K : ℕ) : Finset ℕ :=
  ((Finset.Ico (8 * K ^ 9) (16 * K ^ 9)) ×ˢ (Finset.Ico (2 * K ^ 6) (4 * K ^ 6)) ×ˢ
      (Finset.Ico (K ^ 4) (2 * K ^ 4))).image (fun p => p.1 ^ 3 + p.2.1 ^ 3 + p.2.2 ^ 3)

/-- By injectivity, `cubeTripleValues K` has exactly `16 K¹⁹` elements. -/
theorem card_cubeTripleValues (K : ℕ) : (cubeTripleValues K).card = 16 * K ^ 19 := by
  rw [cubeTripleValues, Finset.card_image_of_injOn]
  · rw [Finset.card_product, Finset.card_product, Nat.card_Ico, Nat.card_Ico, Nat.card_Ico]
    have h1 : 16 * K ^ 9 - 8 * K ^ 9 = 8 * K ^ 9 := by omega
    have h2 : 4 * K ^ 6 - 2 * K ^ 6 = 2 * K ^ 6 := by omega
    have h3 : 2 * K ^ 4 - K ^ 4 = K ^ 4 := by omega
    rw [h1, h2, h3]
    ring
  · rintro ⟨x, y, z⟩ hp ⟨x', y', z'⟩ hq h
    simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_Ico] at hp hq
    obtain ⟨⟨hx1, -⟩, ⟨hy1, hy2⟩, -, hz2⟩ := hp
    obtain ⟨⟨hx1', -⟩, ⟨hy1', hy2'⟩, -, hz2'⟩ := hq
    have h' : x ^ 3 + y ^ 3 + z ^ 3 = x' ^ 3 + y' ^ 3 + z' ^ 3 := h
    obtain ⟨e1, e2, e3⟩ := cube_triple_inj hx1 hy1 hy2 hz2 hx1' hy1' hy2' hz2' h'
    simp [e1, e2, e3]

/-- Every element of `cubeTripleValues K` is a sum of three cubes. -/
theorem isSumOfThreeCubes_of_mem_cubeTripleValues {K n : ℕ} (h : n ∈ cubeTripleValues K) :
    IsSumOfThreeCubes (n : ℤ) := by
  rw [cubeTripleValues, Finset.mem_image] at h
  obtain ⟨⟨x, y, z⟩, -, rfl⟩ := h
  exact ⟨(x : ℤ), (y : ℤ), (z : ℤ), by push_cast; ring⟩

/-- Every element of `cubeTripleValues K` is at most `4168 K²⁷`. -/
theorem le_of_mem_cubeTripleValues {K n : ℕ} (h : n ∈ cubeTripleValues K) :
    n ≤ 4168 * K ^ 27 := by
  rw [cubeTripleValues, Finset.mem_image] at h
  obtain ⟨⟨x, y, z⟩, hp, rfl⟩ := h
  simp only [Finset.mem_product, Finset.mem_Ico] at hp
  obtain ⟨⟨-, hx2⟩, ⟨-, hy2⟩, -, hz2⟩ := hp
  have hx3 : x ^ 3 ≤ (16 * K ^ 9) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have hy3 : y ^ 3 ≤ (4 * K ^ 6) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have hz3 : z ^ 3 ≤ (2 * K ^ 4) ^ 3 := Nat.pow_le_pow_left (by omega) 3
  have e1 : (16 * K ^ 9) ^ 3 = 4096 * K ^ 27 := by ring
  have e2 : (4 * K ^ 6) ^ 3 = 64 * K ^ 18 := by ring
  have e3 : (2 * K ^ 4) ^ 3 = 8 * K ^ 12 := by ring
  rcases Nat.eq_zero_or_pos K with rfl | hK
  · norm_num at hx2
  have e4 : K ^ 18 ≤ K ^ 27 := Nat.pow_le_pow_right hK (by norm_num)
  have e5 : K ^ 12 ≤ K ^ 27 := Nat.pow_le_pow_right hK (by norm_num)
  show x ^ 3 + y ^ 3 + z ^ 3 ≤ 4168 * K ^ 27
  omega

open scoped Classical in
/-- **The sharper power-saving lower bound.**  At least `16 K¹⁹` of the integers in
`[0, 4168 K²⁷]` are sums of three cubes; equivalently `repCount N ≫ N^{19/27}`.  This improves
the exponent `5/9 = 15/27` of `ThreeCubes.repCount_ge`, and is to be compared with the upper
bound `7N/9` of `ThreeCubes.card_isSumOfThreeCubes_le`. -/
theorem repCount_ge_nineteen (K : ℕ) : 16 * K ^ 19 ≤ repCount (4168 * K ^ 27) := by
  have hsub : cubeTripleValues K ⊆
      Finset.filter (fun i : ℕ => IsSumOfThreeCubes (i : ℤ))
        (Finset.range (4168 * K ^ 27 + 1)) := by
    intro n hn
    simp only [Finset.mem_filter, Finset.mem_range]
    exact ⟨by have := le_of_mem_cubeTripleValues hn; omega,
      isSumOfThreeCubes_of_mem_cubeTripleValues hn⟩
  have hcard := Finset.card_le_card hsub
  rw [card_cubeTripleValues] at hcard
  exact hcard

open scoped Classical in
/-- The bound in the form `19/27`-power saving: for every `K` and every `N ≥ 4168 K²⁷` at
least `16 K¹⁹` integers below `N` are sums of three cubes. -/
theorem repCount_ge_nineteen_of_le {K N : ℕ} (h : 4168 * K ^ 27 ≤ N) :
    16 * K ^ 19 ≤ repCount N :=
  le_trans (repCount_ge_nineteen K) (repCount_mono h)

open scoped Classical in
/-- **Real-exponent form.**  With `N = 4168 K²⁷` one has `N^{19/27} ≤ 23 · repCount N`; the
constant comes from `4168¹⁹ ≤ 368²⁷`. -/
theorem repCount_rpow_ge (K : ℕ) :
    ((4168 * K ^ 27 : ℕ) : ℝ) ^ ((19 : ℝ) / 27) ≤ 23 * repCount (4168 * K ^ 27) := by
  have hK0 : (0 : ℝ) ≤ (K : ℝ) := Nat.cast_nonneg K
  have hcast : ((4168 * K ^ 27 : ℕ) : ℝ) = 4168 * (K : ℝ) ^ (27 : ℕ) := by push_cast; ring
  have hsplit : (4168 * (K : ℝ) ^ (27 : ℕ)) ^ ((19 : ℝ) / 27)
      = (4168 : ℝ) ^ ((19 : ℝ) / 27) * (K : ℝ) ^ (19 : ℕ) := by
    rw [Real.mul_rpow (by norm_num) (by positivity), ← Real.rpow_natCast (K : ℝ) 27,
      ← Real.rpow_natCast (K : ℝ) 19, ← Real.rpow_mul hK0]
    norm_num
  have hnn : (0 : ℝ) ≤ (4168 : ℝ) ^ ((19 : ℝ) / 27) := Real.rpow_nonneg (by norm_num) _
  have h27 : ((4168 : ℝ) ^ ((19 : ℝ) / 27)) ^ (27 : ℕ) = (4168 : ℝ) ^ (19 : ℕ) := by
    rw [← Real.rpow_natCast ((4168 : ℝ) ^ ((19 : ℝ) / 27)) 27, ← Real.rpow_mul (by norm_num),
      ← Real.rpow_natCast (4168 : ℝ) 19]
    norm_num
  have hpow : ((4168 : ℝ) ^ ((19 : ℝ) / 27)) ^ (27 : ℕ) ≤ (368 : ℝ) ^ (27 : ℕ) := by
    rw [h27]
    have : (4168 : ℕ) ^ 19 ≤ (368 : ℕ) ^ 27 := by norm_num
    exact_mod_cast this
  have hconst : (4168 : ℝ) ^ ((19 : ℝ) / 27) ≤ 368 :=
    (pow_le_pow_iff_left₀ hnn (by norm_num) (by norm_num)).mp hpow
  have hcount : (16 : ℝ) * (K : ℝ) ^ (19 : ℕ) ≤ (repCount (4168 * K ^ 27) : ℝ) := by
    have := repCount_ge_nineteen K
    exact_mod_cast this
  have hKpow : (0 : ℝ) ≤ (K : ℝ) ^ (19 : ℕ) := by positivity
  rw [hcast, hsplit]
  nlinarith [hconst, hcount, hKpow, hnn]

end ThreeCubes