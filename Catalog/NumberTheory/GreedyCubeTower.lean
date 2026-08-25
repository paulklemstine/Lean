import Catalog.NumberTheory.CubeDigitFamilies

/-!
# The greedy cube tower: sums of `s` positive cubes with exponent `1 - (2/3)^s`

`Catalog.NumberTheory.CubeDigitFamilies` builds a three-scale greedy family of
sums of three positive cubes and derives the counting exponent `19/27`.  Here
that construction is iterated to arbitrary length `s`, by induction.

The key mechanism is unchanged: if a partial sum `m` is smaller than the cube
gap `3z² + 3z + 1`, then `z³ + m` determines both `z` and `m`
(`CubeDigitFamilies.cube_block_unique`).  Adding one more cube to a family whose
values are `< B` therefore multiplies the number of representable integers by
roughly `√B`, while cubing the size of the values.  Running the induction with
the parameter substitution `t ↦ t²` at each step gives, for every `s`,

`# { n ≤ C_s t^(3^s) : n is a sum of s positive cubes } ≥ t^(3^s - 2^s)`,

i.e. an exponent `(3^s - 2^s)/3^s = 1 - (2/3)^s` in `N = C_s t^(3^s)`
(`tower_count`, `tower_exponent`).  For `s = 3` this is `19/27 ≈ 0.7037`, for
`s = 4` it is `65/81 ≈ 0.8025`, and `tower_exponent_tendsto_one` shows the
exponents converge to `1`.
-/

namespace GreedyCubeTower

open CubeDigitFamilies

/-! ## Sums of `s` positive cubes -/

/-- `IsSumOfPosCubes s n` says that `n` is a sum of exactly `s` positive cubes. -/
def IsSumOfPosCubes : ℕ → ℕ → Prop
  | 0, n => n = 0
  | (s + 1), n => ∃ z m, 0 < z ∧ IsSumOfPosCubes s m ∧ n = z ^ 3 + m

theorem isSumOfPosCubes_pos {s n : ℕ} (hs : 1 ≤ s) (h : IsSumOfPosCubes s n) : 0 < n := by
  cases s with
  | zero => omega
  | succ s =>
    obtain ⟨z, m, hz, -, rfl⟩ := h
    have : 0 < z ^ 3 := by positivity
    omega

/-- For `s = 3` this is the notion used in `CubeDigitFamilies`. -/
theorem sumOfThreePositiveCubes_of_isSumOfPosCubes {n : ℕ}
    (h : IsSumOfPosCubes 3 n) : SumOfThreePositiveCubes (n : ℤ) := by
  obtain ⟨z, m, hz, hm, rfl⟩ := h
  obtain ⟨y, m', hy, hm', rfl⟩ := hm
  obtain ⟨x, m'', hx, hm'', rfl⟩ := hm'
  have hzero : m'' = 0 := hm''
  subst hzero
  refine ⟨(x : ℤ), (y : ℤ), (z : ℤ), by exact_mod_cast hx, by exact_mod_cast hy,
    by exact_mod_cast hz, ?_⟩
  push_cast
  ring

/-! ## The constants of the tower -/

/-- The size constant of the `s`-th level of the tower. -/
def towerConst : ℕ → ℕ
  | 0 => 1
  | (s + 1) => 8 * (towerConst s) ^ 3 + towerConst s

theorem towerConst_pos (s : ℕ) : 1 ≤ towerConst s := by
  induction s with
  | zero => simp [towerConst]
  | succ s ih =>
    have : 1 ≤ (towerConst s) ^ 3 := Nat.one_le_pow _ _ ih
    simp only [towerConst]
    omega

/-! ## The inductive construction -/

/-- **Greedy cube tower.**  For every length `s` and every scale `t ≥ 1` there is
a set of at least `t^(3^s - 2^s)` integers below `towerConst s * t^(3^s)`, each a
sum of `s` positive cubes.  The proof is an induction on `s`: one greedy cube is
added on top of the previous family, at scale `t ↦ t²`. -/
theorem greedy_tower (s : ℕ) : ∀ t : ℕ, 1 ≤ t → ∃ S : Finset ℕ,
    t ^ (3 ^ s - 2 ^ s) ≤ S.card ∧
      ∀ n ∈ S, IsSumOfPosCubes s n ∧ n < towerConst s * t ^ (3 ^ s) := by
  classical
  induction s with
  | zero =>
    intro t ht
    refine ⟨{0}, ?_, ?_⟩
    · simp
    · intro n hn
      simp only [Finset.mem_singleton] at hn
      subst hn
      refine ⟨rfl, ?_⟩
      simpa [towerConst] using ht
  | succ s ih =>
    intro t ht
    have ht2 : 1 ≤ t ^ 2 := Nat.one_le_pow _ _ ht
    obtain ⟨S', hcard', hmem'⟩ := ih (t ^ 2) ht2
    set C : ℕ := towerConst s with hC
    have hCpos : 1 ≤ C := towerConst_pos s
    set Z : ℕ := C * t ^ (3 ^ s) with hZ
    have htpow : 1 ≤ t ^ (3 ^ s) := Nat.one_le_pow _ _ ht
    have hZpos : 1 ≤ Z := by
      rw [hZ]
      exact Nat.one_le_iff_ne_zero.mpr (by positivity)
    set B : ℕ := C * t ^ (2 * 3 ^ s) with hB
    -- every element of `S'` is smaller than `B`
    have hlt' : ∀ m ∈ S', m < B := by
      intro m hm
      have := (hmem' m hm).2
      have hpow : (t ^ 2) ^ (3 ^ s) = t ^ (2 * 3 ^ s) := by
        rw [← pow_mul]
      rw [hpow] at this
      exact this
    -- the cube gap above any admissible `z` dominates `B`
    have hgap : ∀ z, Z ≤ z → B < 3 * z ^ 2 + 3 * z + 1 := by
      intro z hz
      have h1 : Z ^ 2 ≤ z ^ 2 := Nat.pow_le_pow_left hz 2
      have h2 : Z ^ 2 = C ^ 2 * t ^ (2 * 3 ^ s) := by
        rw [hZ, mul_pow, ← pow_mul, mul_comm (3 ^ s) 2]
      have h3 : C ≤ C ^ 2 := Nat.le_self_pow (by norm_num) C
      have h4 : C * t ^ (2 * 3 ^ s) ≤ C ^ 2 * t ^ (2 * 3 ^ s) :=
        Nat.mul_le_mul_right _ h3
      have h5 : 0 ≤ z := Nat.zero_le _
      rw [hB]
      rw [h2] at h1
      linarith
    refine ⟨(Finset.Ico Z (2 * Z) ×ˢ S').image (fun p => p.1 ^ 3 + p.2), ?_, ?_⟩
    · -- cardinality: injectivity of the greedy step
      have hinj : Set.InjOn (fun p : ℕ × ℕ => p.1 ^ 3 + p.2)
          ↑(Finset.Ico Z (2 * Z) ×ˢ S') := by
        rintro ⟨z, m⟩ hp ⟨z', m'⟩ hq hEq
        have hp' : (z, m) ∈ Finset.Ico Z (2 * Z) ×ˢ S' := hp
        have hq' : (z', m') ∈ Finset.Ico Z (2 * Z) ×ˢ S' := hq
        rw [Finset.mem_product, Finset.mem_Ico] at hp' hq'
        have hm : m < 3 * z ^ 2 + 3 * z + 1 :=
          lt_trans (hlt' m hp'.2) (hgap z hp'.1.1)
        have hm' : m' < 3 * z' ^ 2 + 3 * z' + 1 :=
          lt_trans (hlt' m' hq'.2) (hgap z' hq'.1.1)
        have heq : z ^ 3 + m = z' ^ 3 + m' := hEq
        obtain ⟨h1, h2⟩ := cube_block_unique hm hm' heq
        simp [h1, h2]
      rw [Finset.card_image_of_injOn hinj, Finset.card_product, Nat.card_Ico]
      have hZcard : 2 * Z - Z = Z := by omega
      rw [hZcard]
      have hS' : (t ^ 2) ^ (3 ^ s - 2 ^ s) ≤ S'.card := hcard'
      have hexp : t ^ (3 ^ (s + 1) - 2 ^ (s + 1)) ≤
          t ^ (3 ^ s) * (t ^ 2) ^ (3 ^ s - 2 ^ s) := by
        have h23 : 2 ^ s ≤ 3 ^ s := Nat.pow_le_pow_left (by norm_num) s
        have hpow : t ^ (3 ^ s) * (t ^ 2) ^ (3 ^ s - 2 ^ s) =
            t ^ (3 ^ s + 2 * (3 ^ s - 2 ^ s)) := by
          rw [← pow_mul, ← pow_add]
        rw [hpow]
        have : 3 ^ (s + 1) - 2 ^ (s + 1) = 3 ^ s + 2 * (3 ^ s - 2 ^ s) := by
          have e3 : 3 ^ (s + 1) = 3 * 3 ^ s := by ring
          have e2 : 2 ^ (s + 1) = 2 * 2 ^ s := by ring
          omega
        rw [this]
      calc t ^ (3 ^ (s + 1) - 2 ^ (s + 1))
          ≤ t ^ (3 ^ s) * (t ^ 2) ^ (3 ^ s - 2 ^ s) := hexp
        _ ≤ Z * S'.card := by
            refine Nat.mul_le_mul ?_ hS'
            rw [hZ]
            exact Nat.le_mul_of_pos_left _ hCpos
    · -- membership: representation and size
      intro n hn
      rw [Finset.mem_image] at hn
      obtain ⟨⟨z, m⟩, hzm, rfl⟩ := hn
      rw [Finset.mem_product, Finset.mem_Ico] at hzm
      obtain ⟨⟨hz1, hz2⟩, hm⟩ := hzm
      have hzpos : 0 < z := by omega
      refine ⟨⟨z, m, hzpos, (hmem' m hm).1, rfl⟩, ?_⟩
      have hmB : m < B := hlt' m hm
      have hz3 : z ^ 3 < (2 * Z) ^ 3 := Nat.pow_lt_pow_left hz2 (by norm_num)
      have e1 : (2 * Z) ^ 3 = 8 * C ^ 3 * t ^ (3 ^ (s + 1)) := by
        rw [hZ, mul_pow, mul_pow, ← pow_mul]
        have : 3 ^ s * 3 = 3 ^ (s + 1) := by ring
        rw [this]
        ring
      have e2 : t ^ (2 * 3 ^ s) ≤ t ^ (3 ^ (s + 1)) := by
        refine Nat.pow_le_pow_right ht ?_
        have : 3 ^ (s + 1) = 3 * 3 ^ s := by ring
        omega
      have e3 : towerConst (s + 1) * t ^ (3 ^ (s + 1)) =
          8 * C ^ 3 * t ^ (3 ^ (s + 1)) + C * t ^ (3 ^ (s + 1)) := by
        simp only [towerConst, hC]
        ring
      have hBle : B ≤ C * t ^ (3 ^ (s + 1)) := by
        rw [hB]
        exact Nat.mul_le_mul_left _ e2
      rw [e1] at hz3
      rw [e3]
      linarith

/-! ## The counting theorem -/

/-- Positive integers `≤ N` which are sums of `s` positive cubes. -/
def cubeRepSet (s N : ℕ) : Set ℕ := {n | 0 < n ∧ n ≤ N ∧ IsSumOfPosCubes s n}

theorem cubeRepSet_finite (s N : ℕ) : (cubeRepSet s N).Finite :=
  (Set.finite_Icc 1 N).subset (by rintro n ⟨h1, h2, -⟩; exact ⟨h1, h2⟩)

theorem card_le_ncard_cubeRepSet {s N : ℕ} (T : Finset ℕ)
    (hT : ∀ n ∈ T, n ∈ cubeRepSet s N) : T.card ≤ (cubeRepSet s N).ncard := by
  have hsub : (↑T : Set ℕ) ⊆ cubeRepSet s N := fun n hn => hT n (by simpa using hn)
  have := Set.ncard_le_ncard hsub (cubeRepSet_finite s N)
  simpa [Set.ncard_coe_finset] using this

/-- **Main counting theorem for the tower.**  For `s ≥ 1` and `t ≥ 1` at least
`t^(3^s - 2^s)` positive integers below `towerConst s * t^(3^s)` are sums of `s`
positive cubes; no cube is zero, so nothing is padded. -/
theorem tower_count (s t : ℕ) (hs : 1 ≤ s) (ht : 1 ≤ t) :
    t ^ (3 ^ s - 2 ^ s) ≤ (cubeRepSet s (towerConst s * t ^ (3 ^ s))).ncard := by
  obtain ⟨S, hcard, hmem⟩ := greedy_tower s t ht
  refine le_trans hcard (card_le_ncard_cubeRepSet S ?_)
  intro n hn
  obtain ⟨hrep, hlt⟩ := hmem n hn
  exact ⟨isSumOfPosCubes_pos hs hrep, le_of_lt hlt, hrep⟩

/-- For `s = 3` the tower reproduces a bound of cube-digit type. -/
theorem tower_count_three (t : ℕ) (ht : 1 ≤ t) :
    t ^ 19 ≤ (cubeRepSet 3 (towerConst 3 * t ^ 27)).ncard := by
  have h := tower_count 3 t (by norm_num) ht
  norm_num at h
  exact h

/-- For `s = 4` the exponent is `65/81 ≈ 0.8025`. -/
theorem tower_count_four (t : ℕ) (ht : 1 ≤ t) :
    t ^ 65 ≤ (cubeRepSet 4 (towerConst 4 * t ^ 81)).ncard := by
  have h := tower_count 4 t (by norm_num) ht
  norm_num at h
  exact h

/-- For `s = 2` the exponent is `5/9`: sums of two positive cubes. -/
theorem tower_count_two (t : ℕ) (ht : 1 ≤ t) :
    t ^ 5 ≤ (cubeRepSet 2 (towerConst 2 * t ^ 9)).ncard := by
  have h := tower_count 2 t (by norm_num) ht
  norm_num at h
  exact h

theorem cubeRepSet_mono {s N M : ℕ} (h : N ≤ M) : cubeRepSet s N ⊆ cubeRepSet s M := by
  rintro n ⟨h1, h2, h3⟩
  exact ⟨h1, h2.trans h, h3⟩

theorem cubeRepSet_ncard_mono {s N M : ℕ} (h : N ≤ M) :
    (cubeRepSet s N).ncard ≤ (cubeRepSet s M).ncard :=
  Set.ncard_le_ncard (cubeRepSet_mono h) (cubeRepSet_finite s M)

/-! ## The exponent -/

/-- The counting exponent of the `s`-th tower, `(3^s - 2^s)/3^s = 1 - (2/3)^s`. -/
noncomputable def towerExponent (s : ℕ) : ℝ := ((3 ^ s - 2 ^ s : ℕ) : ℝ) / (3 ^ s : ℕ)

theorem tower_exponent (s : ℕ) : towerExponent s = 1 - (2 / 3 : ℝ) ^ s := by
  have h23 : (2 : ℕ) ^ s ≤ 3 ^ s := Nat.pow_le_pow_left (by norm_num) s
  have h3pos : (0 : ℝ) < (3 : ℝ) ^ s := by positivity
  unfold towerExponent
  rw [Nat.cast_sub h23]
  push_cast
  rw [div_pow]
  field_simp

/-- **The tower bound for every `N`.**  For `s ≥ 1` and every `N ≥ towerConst s`
the number of positive integers `≤ N` which are sums of `s` positive cubes is at
least `(N / (towerConst s · 2^(3^s)))^(1 - (2/3)^s)`. -/
theorem tower_count_rpow (s : ℕ) (hs : 1 ≤ s) (N : ℕ) (hN : towerConst s ≤ N) :
    ((N : ℝ) / (towerConst s * 2 ^ (3 ^ s))) ^ (towerExponent s) ≤
      ((cubeRepSet s N).ncard : ℝ) := by
  classical
  set C : ℕ := towerConst s with hC
  set p : ℕ := 3 ^ s with hp
  set q : ℕ := 3 ^ s - 2 ^ s with hq
  have hCpos : 1 ≤ C := towerConst_pos s
  have hCR : (0 : ℝ) < (C : ℝ) := by exact_mod_cast hCpos
  have hppos : 0 < p := by positivity
  have hpR : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hppos
  have hNC : (1 : ℝ) ≤ (N : ℝ) / (C : ℝ) := by
    rw [le_div_iff₀ hCR]
    have : ((C : ℝ)) ≤ (N : ℝ) := by exact_mod_cast hN
    linarith
  set t : ℕ := Nat.floor (((N : ℝ) / (C : ℝ)) ^ ((1 : ℝ) / (p : ℝ))) with htdef
  have hone : (1 : ℝ) ≤ ((N : ℝ) / (C : ℝ)) ^ ((1 : ℝ) / (p : ℝ)) :=
    Real.one_le_rpow hNC (by positivity)
  have ht1 : 1 ≤ t := Nat.le_floor (by exact_mod_cast hone)
  have hNCpos : (0 : ℝ) < (N : ℝ) / (C : ℝ) := by linarith
  have hroot : ((((N : ℝ) / (C : ℝ)) ^ ((1 : ℝ) / (p : ℝ))) ^ (p : ℕ)) =
      (N : ℝ) / (C : ℝ) := by
    rw [← Real.rpow_natCast (((N : ℝ) / (C : ℝ)) ^ ((1 : ℝ) / (p : ℝ))) p,
      ← Real.rpow_mul (le_of_lt hNCpos)]
    rw [one_div, inv_mul_cancel₀ (ne_of_gt hpR), Real.rpow_one]
  -- lower approximation
  have hfloor_le : (t : ℝ) ≤ ((N : ℝ) / (C : ℝ)) ^ ((1 : ℝ) / (p : ℝ)) :=
    Nat.floor_le (by positivity)
  have hpow_le : (t : ℝ) ^ p ≤ (N : ℝ) / (C : ℝ) := by
    calc (t : ℝ) ^ p ≤ (((N : ℝ) / (C : ℝ)) ^ ((1 : ℝ) / (p : ℝ))) ^ p :=
          pow_le_pow_left₀ (Nat.cast_nonneg t) hfloor_le p
      _ = (N : ℝ) / (C : ℝ) := hroot
  have hNbound : C * t ^ p ≤ N := by
    have : (C : ℝ) * (t : ℝ) ^ p ≤ (N : ℝ) := by
      rw [← le_div_iff₀' hCR]
      exact hpow_le
    exact_mod_cast this
  -- upper approximation
  have hfloor_lt : ((N : ℝ) / (C : ℝ)) ^ ((1 : ℝ) / (p : ℝ)) < (t : ℝ) + 1 :=
    Nat.lt_floor_add_one _
  have h2t : ((t : ℝ) + 1) ≤ 2 * (t : ℝ) := by
    have : (1 : ℝ) ≤ (t : ℝ) := by exact_mod_cast ht1
    linarith
  have hupper : (N : ℝ) / (C : ℝ) ≤ 2 ^ p * (t : ℝ) ^ p := by
    have h1 : (N : ℝ) / (C : ℝ) < ((t : ℝ) + 1) ^ p := by
      calc (N : ℝ) / (C : ℝ)
          = (((N : ℝ) / (C : ℝ)) ^ ((1 : ℝ) / (p : ℝ))) ^ p := hroot.symm
        _ < ((t : ℝ) + 1) ^ p :=
            pow_lt_pow_left₀ hfloor_lt (by positivity) (by omega)
    have h2 : ((t : ℝ) + 1) ^ p ≤ (2 * (t : ℝ)) ^ p :=
      pow_le_pow_left₀ (by positivity) h2t p
    have h3 : (2 * (t : ℝ)) ^ p = 2 ^ p * (t : ℝ) ^ p := by ring
    linarith
  have hN2 : (N : ℝ) / ((C : ℝ) * 2 ^ p) ≤ (t : ℝ) ^ p := by
    rw [div_le_iff₀ (by positivity)]
    have := (div_le_iff₀ hCR).mp hupper
    nlinarith [this]
  -- transfer the exponent
  have hexp : ((N : ℝ) / ((C : ℝ) * 2 ^ p)) ^ (towerExponent s) ≤ (t : ℝ) ^ q := by
    have hnn : (0 : ℝ) ≤ (N : ℝ) / ((C : ℝ) * 2 ^ p) := by positivity
    have hmono : ((N : ℝ) / ((C : ℝ) * 2 ^ p)) ^ (towerExponent s) ≤
        ((t : ℝ) ^ p) ^ (towerExponent s) := by
      refine Real.rpow_le_rpow hnn hN2 ?_
      rw [tower_exponent]
      have : (2 / 3 : ℝ) ^ s ≤ 1 := pow_le_one₀ (by norm_num) (by norm_num)
      linarith
    have hid : ((t : ℝ) ^ p) ^ (towerExponent s) = (t : ℝ) ^ q := by
      rw [← Real.rpow_natCast (t : ℝ) p, ← Real.rpow_mul (Nat.cast_nonneg t),
        towerExponent]
      rw [show (p : ℝ) * ((q : ℝ) / (p : ℝ)) = (q : ℝ) by field_simp,
        Real.rpow_natCast]
    linarith [hmono, hid.le, hid.ge]
  have hcount : ((t : ℝ) ^ q) ≤ ((cubeRepSet s N).ncard : ℝ) := by
    have h := (tower_count s t hs ht1).trans (cubeRepSet_ncard_mono hNbound)
    exact_mod_cast h
  linarith

/-- The tower exponents increase to `1`: sums of many positive cubes cover
almost all of a dyadic range, in the counting sense. -/
theorem tower_exponent_tendsto_one :
    Filter.Tendsto towerExponent Filter.atTop (nhds 1) := by
  have h : towerExponent = fun s : ℕ => 1 - (2 / 3 : ℝ) ^ s := funext tower_exponent
  have hpow : Filter.Tendsto (fun s : ℕ => (2 / 3 : ℝ) ^ s) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  have hlim := (tendsto_const_nhds (X := ℝ) (x := (1 : ℝ))
    (f := Filter.atTop (α := ℕ))).sub hpow
  rw [h]
  simpa using hlim

end GreedyCubeTower