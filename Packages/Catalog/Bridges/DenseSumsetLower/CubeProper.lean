/-
# Proper affine cubes in dense sets

`Bridges.DenseSumsetLower.Cube` produces, inside every `δ`-dense set, an affine cube
`u + {0,a₁} + ⋯ + {0,a_d}` whose generators are nonzero — but possibly with fewer than
`2^d` distinct points (take `a₁ = a₂`: the cube collapses to a three-term progression).
`Bridges.DenseSumsetLower.CubeSharp` proves the matching first-moment bound for *proper*
cubes, i.e. those with all `2^d` subset sums distinct — and properness is essential there,
since a `δ`-dense set of `[n]` certainly does contain short progressions, hence degenerate
cubes of every dimension.

This file removes the mismatch: the greedy iteration of `Cube.lean` is rerun with the
forbidden-shift slot of `DenseSumsetLower.exists_good_shift` loaded with the difference set
`cubeF l - cubeF l` of the cube built so far.  A shift outside that set is automatically
nonzero *and* keeps the new cube proper, and the extra cost is only the requirement that
the excluded set — of size at most `4^d` — be small compared with the shift domain and with
the surviving set.  The analytic outcome is that

`(4/δ)^{2^d} · 4^d ≤ 2 n`

already forces a **proper** cube of dimension `d`, so the existence threshold moves by at
most the harmless factor `4^d` (which costs `2 d` in the exponent `2^d`, i.e. nothing on the
scale `2^d ≈ log n / log (1/δ)` of the problem).

Contents:
* `DenseSumsetLower.cubeDiffs` — the forbidden shifts, and `card_cubeF_cons_of_notMem_diffs`
  (a shift outside them doubles the cube);
* `DenseSumsetLower.exists_proper_cube_family` — the greedy iteration keeping properness;
* `DenseSumsetLower.exists_proper_cube_of_counting`, `exists_proper_cube_int_Ico`,
  `exists_proper_cube_of_density_int` — the abstract criterion and the interval instances;
* `DenseSumsetLower.proper_cube_dimension_window` — with `CubeSharp.lean`: the existence
  range and the avoidance range of the dimension `d` are now statements about the *same*
  object (proper cubes) and are disjoint for large `n`.
-/
import Bridges.DenseSumsetLower.CubeSharp

namespace DenseSumsetLower

open Finset Pointwise

variable {G : Type*} [AddCommGroup G] [DecidableEq G]

/-! ## Forbidden shifts: the difference set of the current cube -/

/-- The difference set `cubeF l - cubeF l`.  A shift taken outside it keeps the enlarged
cube `cubeF (a :: l)` proper. -/
def cubeDiffs (l : List G) : Finset G :=
  ((cubeF l) ×ˢ (cubeF l)).image (fun p => p.1 - p.2)

lemma card_cubeDiffs_le (l : List G) : (cubeDiffs l).card ≤ (cubeF l).card * (cubeF l).card := by
  refine le_trans Finset.card_image_le ?_
  rw [Finset.card_product]

lemma zero_mem_cubeDiffs (l : List G) : (0 : G) ∈ cubeDiffs l :=
  Finset.mem_image.2 ⟨(0, 0), by simp [Finset.mem_product, zero_mem_cubeF], by simp⟩

/-- A shift outside `cubeDiffs l` doubles the size of the cube. -/
lemma card_cubeF_cons_of_notMem_diffs {a : G} {l : List G} (ha : a ∉ cubeDiffs l) :
    (cubeF (a :: l)).card = 2 * (cubeF l).card := by
  classical
  have hset : cubeF (a :: l) = cubeF l ∪ (cubeF l).image (fun y => a + y) := by
    ext x
    simp only [cubeF_cons, Finset.mem_add, Finset.mem_insert, Finset.mem_singleton,
      Finset.mem_union, Finset.mem_image]
    constructor
    · rintro ⟨p, hp, y, hy, rfl⟩
      rcases hp with rfl | rfl
      · exact Or.inl (by simpa using hy)
      · exact Or.inr ⟨y, hy, rfl⟩
    · rintro (hx | ⟨y, hy, rfl⟩)
      · exact ⟨0, Or.inl rfl, x, hx, by simp⟩
      · exact ⟨a, Or.inr rfl, y, hy, rfl⟩
  have hdisj : Disjoint (cubeF l) ((cubeF l).image (fun y => a + y)) := by
    refine Finset.disjoint_left.2 ?_
    rintro x hx hx'
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hx'
    exact ha (Finset.mem_image.2 ⟨(a + y, y), by simp [Finset.mem_product, hx, hy], by simp⟩)
  have hinj : Function.Injective (fun y : G => a + y) := fun x y h => by simpa using h
  rw [hset, Finset.card_union_of_disjoint hdisj, Finset.card_image_of_injective _ hinj]
  ring

/-! ## The greedy iteration, keeping properness -/

/-- **The proper cube iteration.**  As `DenseSumsetLower.exists_cube_family`, but the shift
chosen at each step is taken outside the difference set of the cube built so far, so that
all `2^j` subset sums stay distinct.  The price is the two extra hypotheses `4^d < |D|`
(the forbidden set must not exhaust the shift domain) and the strengthened counting
condition with the constant `2·4^d` (the surviving set must stay large compared with the
forbidden set). -/
theorem exists_proper_cube_family {S D : Finset G} (hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ D)
    {d : ℕ} (hDbig : 4 ^ d < D.card)
    (hgrow : ∀ j ≤ d, (2 * 4 ^ d) * (2 * D.card) ^ (2 ^ j - 1) ≤ S.card ^ (2 ^ j)) :
    ∀ j ≤ d, ∃ (U : Finset G) (l : List G), U ⊆ S ∧ l.length = j ∧
      (∀ a ∈ l, a ≠ 0) ∧ (cubeF l).card = 2 ^ j ∧
      (∀ u ∈ U, ∀ x ∈ cubeF l, u + x ∈ S) ∧
      S.card ^ (2 ^ j) ≤ (2 * D.card) ^ (2 ^ j - 1) * U.card := by
  intro j
  induction j with
  | zero =>
      intro _
      refine ⟨S, [], Finset.Subset.refl S, rfl, by simp, by simp, ?_, by simp⟩
      intro u hu x hx
      have : x = 0 := by simpa using hx
      simpa [this] using hu
  | succ j ih =>
      intro hj
      obtain ⟨U, l, hUS, hlen, hne, hproper, hcube, hbound⟩ := ih (Nat.le_of_succ_le hj)
      have hjd : j ≤ d := Nat.le_of_succ_le hj
      have hNpos : 0 < 2 * D.card := by
        have : 0 < D.card := lt_of_le_of_lt (Nat.zero_le _) hDbig
        omega
      have hpow : 0 < (2 * D.card) ^ (2 ^ j - 1) := Nat.pow_pos hNpos
      -- the forbidden set is small
      have hFcard : (cubeDiffs l).card ≤ 4 ^ d := by
        refine le_trans (card_cubeDiffs_le l) ?_
        rw [hproper, ← pow_add]
        calc (2 : ℕ) ^ (j + j) = 4 ^ j := by
              rw [show (4 : ℕ) = 2 ^ 2 by norm_num, ← pow_mul]
              congr 1
              ring
          _ ≤ 4 ^ d := Nat.pow_le_pow_right (by norm_num) hjd
      have hFD : (cubeDiffs l).card < D.card := lt_of_le_of_lt hFcard hDbig
      -- the surviving set is still much larger than the forbidden set
      have hUbig : 2 * 4 ^ d ≤ U.card := by
        have h1 := hgrow j hjd
        have h2 : (2 * 4 ^ d) * (2 * D.card) ^ (2 ^ j - 1)
            ≤ (2 * D.card) ^ (2 ^ j - 1) * U.card := le_trans h1 hbound
        have h3 : (2 * D.card) ^ (2 ^ j - 1) * (2 * 4 ^ d)
            ≤ (2 * D.card) ^ (2 ^ j - 1) * U.card := by
          rw [mul_comm ((2 * D.card) ^ (2 ^ j - 1)) (2 * 4 ^ d)]
          exact h2
        exact Nat.le_of_mul_le_mul_left h3 hpow
      have hU2 : 2 ≤ U.card := by
        have : 1 ≤ 4 ^ d := Nat.one_le_pow _ _ (by norm_num)
        omega
      -- one greedy step inside `U`, avoiding the forbidden shifts
      have hDU : ∀ u ∈ U, ∀ s ∈ U, s - u ∈ D := fun u hu s hs => hD u (hUS hu) s (hUS hs)
      obtain ⟨a, _, haF, hstep⟩ :=
        exists_good_shift (S := U) (D := D) (U := U) (F := cubeDiffs l)
          (Finset.Subset.refl U) hDU hFD
      have hane : a ≠ 0 := by
        intro h
        exact haF (h ▸ zero_mem_cubeDiffs l)
      set U' : Finset G := U.filter (fun u => u + a ∈ U) with hU'
      have hU'U : U' ⊆ U := Finset.filter_subset _ _
      -- the counting step: `2|D| |U'| ≥ |U|²`
      have hkey : U.card * U.card ≤ 2 * D.card * U'.card := by
        have h1 : U.card * U.card ≤ D.card * U'.card + (cubeDiffs l).card * U.card := by
          simpa [hU'] using hstep
        have h2 : (cubeDiffs l).card * U.card ≤ 4 ^ d * U.card :=
          Nat.mul_le_mul_right _ hFcard
        have h3 : 2 * (4 ^ d * U.card) ≤ U.card * U.card := by
          have := Nat.mul_le_mul_right U.card hUbig
          calc 2 * (4 ^ d * U.card) = (2 * 4 ^ d) * U.card := by ring
            _ ≤ U.card * U.card := this
        have h4 : U.card * U.card ≤ 2 * (D.card * U'.card) := by omega
        calc U.card * U.card ≤ 2 * (D.card * U'.card) := h4
          _ = 2 * D.card * U'.card := by ring
      refine ⟨U', a :: l, hU'U.trans hUS, by simp [hlen], ?_, ?_, ?_, ?_⟩
      · intro b hb
        rcases List.mem_cons.mp hb with rfl | hbl
        · exact hane
        · exact hne b hbl
      · rw [card_cubeF_cons_of_notMem_diffs haF, hproper, ← pow_succ']
      · intro u hu x hx
        rcases mem_cubeF_cons hx with ⟨y, hy, hxy⟩ | ⟨y, hy, hxy⟩
        · rw [hxy]
          exact hcube u (hU'U hu) y hy
        · have hua : u + a ∈ U := (Finset.mem_filter.mp hu).2
          have h2 := hcube (u + a) hua y hy
          rw [hxy, ← add_assoc]
          exact h2
      · have hexp1 : 2 ^ (j + 1) - 1 = (2 ^ j - 1) + (2 ^ j - 1) + 1 := by
          have h1 : 1 ≤ 2 ^ j := Nat.one_le_two_pow
          have h2 : 2 ^ (j + 1) = 2 ^ j + 2 ^ j := by ring
          omega
        have hsq : S.card ^ (2 ^ (j + 1)) = (S.card ^ (2 ^ j)) * (S.card ^ (2 ^ j)) := by
          rw [← pow_add]
          congr 1
          ring
        calc S.card ^ (2 ^ (j + 1))
            = (S.card ^ (2 ^ j)) * (S.card ^ (2 ^ j)) := hsq
          _ ≤ ((2 * D.card) ^ (2 ^ j - 1) * U.card) * ((2 * D.card) ^ (2 ^ j - 1) * U.card) :=
              Nat.mul_le_mul hbound hbound
          _ = (2 * D.card) ^ ((2 ^ j - 1) + (2 ^ j - 1)) * (U.card * U.card) := by
              rw [pow_add]; ring
          _ ≤ (2 * D.card) ^ ((2 ^ j - 1) + (2 ^ j - 1)) * (2 * D.card * U'.card) :=
              Nat.mul_le_mul_left _ hkey
          _ = (2 * D.card) ^ ((2 ^ j - 1) + (2 ^ j - 1) + 1) * U'.card := by
              rw [pow_succ]; ring
          _ = (2 * D.card) ^ (2 ^ (j + 1) - 1) * U'.card := by rw [hexp1]

/-- **Abstract proper-cube criterion.** -/
theorem exists_proper_cube_of_counting {S D : Finset G} (hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ D)
    {d : ℕ} (hDbig : 4 ^ d < D.card)
    (hgrow : ∀ j ≤ d, (2 * 4 ^ d) * (2 * D.card) ^ (2 ^ j - 1) ≤ S.card ^ (2 ^ j)) :
    ∃ (u : G) (l : List G), l.length = d ∧ (∀ a ∈ l, a ≠ 0) ∧ (cubeF l).card = 2 ^ d ∧
      u ∈ S ∧ ∀ x ∈ cubeF l, u + x ∈ S := by
  obtain ⟨U, l, hUS, hlen, hne, hproper, hcube, hbound⟩ :=
    exists_proper_cube_family hD hDbig hgrow d le_rfl
  have hDpos : 0 < D.card := lt_of_le_of_lt (Nat.zero_le _) hDbig
  have hpow : 0 < (2 * D.card) ^ (2 ^ d - 1) := Nat.pow_pos (by omega)
  have hUpos : 0 < U.card := by
    by_contra hcon
    push_neg at hcon
    have h1 : (2 * D.card) ^ (2 ^ d - 1) * U.card = 0 := by
      have : U.card = 0 := by omega
      simp [this]
    have h2 := hgrow d le_rfl
    have h3 : 1 ≤ 4 ^ d := Nat.one_le_pow _ _ (by norm_num)
    have h4 : 0 < (2 * 4 ^ d) * (2 * D.card) ^ (2 ^ d - 1) := by positivity
    omega
  obtain ⟨u, hu⟩ := Finset.card_pos.mp hUpos
  exact ⟨u, l, hlen, hne, hproper, hUS hu, hcube u hu⟩

/-! ## Scale reduction with a general constant -/

/-- `DenseSumsetLower.grow_of_top` with an arbitrary constant in place of `2`. -/
lemma grow_of_top_const {C N m d : ℕ} (hm : m ≤ 2 * N) (hN : 1 ≤ N)
    (htop : C * (2 * N) ^ (2 ^ d - 1) ≤ m ^ (2 ^ d)) :
    ∀ j ≤ d, C * (2 * N) ^ (2 ^ j - 1) ≤ m ^ (2 ^ j) := by
  intro j hj
  have hjd : (2 : ℕ) ^ j ≤ 2 ^ d := Nat.pow_le_pow_right (by norm_num) hj
  have h1j : 1 ≤ (2 : ℕ) ^ j := Nat.one_le_two_pow
  have hNpos : 0 < 2 * N := by omega
  have hpow : 0 < (2 * N) ^ (2 ^ d - 2 ^ j) := Nat.pow_pos hNpos
  have hstep : m ^ (2 ^ d) ≤ m ^ (2 ^ j) * (2 * N) ^ (2 ^ d - 2 ^ j) := by
    have hsplit : (2 : ℕ) ^ d = 2 ^ j + (2 ^ d - 2 ^ j) := by omega
    calc m ^ (2 ^ d) = m ^ (2 ^ j) * m ^ (2 ^ d - 2 ^ j) := by rw [← pow_add, ← hsplit]
      _ ≤ m ^ (2 ^ j) * (2 * N) ^ (2 ^ d - 2 ^ j) :=
          Nat.mul_le_mul_left _ (Nat.pow_le_pow_left hm _)
  have hexp : (2 : ℕ) ^ d - 1 = (2 ^ j - 1) + (2 ^ d - 2 ^ j) := by omega
  have hchain : C * (2 * N) ^ (2 ^ j - 1) * (2 * N) ^ (2 ^ d - 2 ^ j)
      ≤ m ^ (2 ^ j) * (2 * N) ^ (2 ^ d - 2 ^ j) := by
    calc C * (2 * N) ^ (2 ^ j - 1) * (2 * N) ^ (2 ^ d - 2 ^ j)
        = C * (2 * N) ^ (2 ^ d - 1) := by rw [hexp, pow_add]; ring
      _ ≤ m ^ (2 ^ d) := htop
      _ ≤ m ^ (2 ^ j) * (2 * N) ^ (2 ^ d - 2 ^ j) := hstep
  exact Nat.le_of_mul_le_mul_right hchain hpow

/-! ## The interval instance -/

/-- **Proper cubes in dense subsets of an interval.**  Every `S ⊆ [0,n) ⊆ ℤ` with
`2·4^d·(4n)^{2^d - 1} ≤ |S|^{2^d}` and `4^d < 2n - 1` contains a *proper* affine cube of
dimension `d`: `2^d` distinct points `u + ∑_{i ∈ I} a_i`, all inside `S`. -/
theorem exists_proper_cube_int_Ico {n : ℕ} {S : Finset ℤ} (hS : S ⊆ Finset.Ico (0 : ℤ) n)
    {d : ℕ} (hDbig : 4 ^ d < 2 * n - 1)
    (hcond : (2 * 4 ^ d) * (4 * n) ^ (2 ^ d - 1) ≤ S.card ^ (2 ^ d)) :
    ∃ (u : ℤ) (l : List ℤ), l.length = d ∧ (∀ a ∈ l, a ≠ 0) ∧ (cubeF l).card = 2 ^ d ∧
      u ∈ S ∧ ∀ x ∈ cubeF l, u + x ∈ S := by
  classical
  have h4d : 1 ≤ 4 ^ d := Nat.one_le_pow _ _ (by norm_num)
  have hn : 1 ≤ n := by omega
  set D : Finset ℤ := Finset.Ioo (-(n : ℤ)) n with hDdef
  have hDcard : D.card = 2 * n - 1 := by
    rw [hDdef, Int.card_Ioo]
    omega
  have hD : ∀ u ∈ S, ∀ s ∈ S, s - u ∈ D := by
    intro u hu s hs
    have hu' := Finset.mem_Ico.mp (hS hu)
    have hs' := Finset.mem_Ico.mp (hS hs)
    exact Finset.mem_Ioo.mpr ⟨by omega, by omega⟩
  have hSn : S.card ≤ n := by
    have := Finset.card_le_card hS
    rwa [Int.card_Ico, show ((n : ℤ) - 0).toNat = n by omega] at this
  have hDbig' : 4 ^ d < D.card := by rw [hDcard]; exact hDbig
  have htop : (2 * 4 ^ d) * (2 * D.card) ^ (2 ^ d - 1) ≤ S.card ^ (2 ^ d) := by
    refine le_trans (Nat.mul_le_mul_left _ (Nat.pow_le_pow_left ?_ _)) hcond
    omega
  refine exists_proper_cube_of_counting hD hDbig' ?_
  exact grow_of_top_const (C := 2 * 4 ^ d) (N := D.card) (m := S.card) (d := d)
    (by omega) (by omega) htop

/-- **The analytic form.**  If `S ⊆ [0,n)` has `|S| ≥ δ n` with `0 < δ ≤ 1` and

`(4/δ)^{2^d} · 4^d ≤ 2 n`,

then `S` contains a **proper** affine cube of dimension `d`.  Compared with
`DenseSumsetLower.exists_cube_of_density_int` the only change is the extra factor `4^d`,
which shifts the admissible range of `d` by `O(log d)` in the exponent `2^d`; so properness
is free on the scale `2^d ≈ log n / log (1/δ)` at which the threshold sits. -/
theorem exists_proper_cube_of_density_int {n : ℕ} {S : Finset ℤ} {δ : ℝ} (hn : 1 ≤ n)
    (h0 : 0 < δ) (h1 : δ ≤ 1) (hS : S ⊆ Finset.Ico (0 : ℤ) n)
    (hdense : δ * n ≤ S.card) {d : ℕ} (hd : ((4 : ℝ) / δ) ^ (2 ^ d) * 4 ^ d ≤ 2 * n) :
    ∃ (u : ℤ) (l : List ℤ), l.length = d ∧ (∀ a ∈ l, a ≠ 0) ∧ (cubeF l).card = 2 ^ d ∧
      u ∈ S ∧ ∀ x ∈ cubeF l, u + x ∈ S := by
  set K : ℕ := 2 ^ d with hK
  have hK1 : 1 ≤ K := Nat.one_le_two_pow
  have hnR : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hn0 : (0 : ℝ) < n := by linarith
  have hdK : (d : ℕ) + 1 ≤ K := by
    have := Nat.lt_two_pow_self (n := d)
    omega
  -- the shift domain is large enough: `4·4^d ≤ (4/δ)^K·4^d ≤ 2n`
  have h4pow : ((4 : ℝ)) ^ (d + 1) ≤ ((4 : ℝ) / δ) ^ K * 4 ^ d := by
    have hbase : (4 : ℝ) ≤ 4 / δ := by
      rw [le_div_iff₀ h0]
      nlinarith
    have h1' : (4 : ℝ) ^ K ≤ (4 / δ) ^ K := pow_le_pow_left₀ (by norm_num) hbase K
    have h2' : ((4 : ℝ)) ^ (d + 1) ≤ 4 ^ K := by
      refine pow_le_pow_right₀ (by norm_num) hdK
    have h3' : ((4 : ℝ)) ^ d ≥ 1 := one_le_pow₀ (by norm_num)
    nlinarith [pow_pos (show (0:ℝ) < 4 by norm_num) K]
  have hDbigR : ((4 : ℝ)) ^ (d + 1) ≤ 2 * n := le_trans h4pow hd
  have hDbig : 4 ^ d < 2 * n - 1 := by
    have hcast : ((4 ^ (d + 1) : ℕ) : ℝ) ≤ ((2 * n : ℕ) : ℝ) := by push_cast; exact hDbigR
    have hnat : 4 ^ (d + 1) ≤ 2 * n := by exact_mod_cast hcast
    have h4 : 4 * 4 ^ d = 4 ^ (d + 1) := by ring
    have h4d : 1 ≤ 4 ^ d := Nat.one_le_pow _ _ (by norm_num)
    omega
  refine exists_proper_cube_int_Ico hS hDbig ?_
  -- the counting condition, in real form
  have hreal : ((2 * 4 ^ d : ℕ) : ℝ) * (4 * n) ^ (K - 1) ≤ (S.card : ℝ) ^ K := by
    have hsplit : (δ * n) ^ K = (δ / 4) ^ K * (4 * n) ^ K := by
      rw [← mul_pow]; ring_nf
    have hKsplit : (4 * (n : ℝ)) ^ K = (4 * n) ^ (K - 1) * (4 * n) := by
      rw [← pow_succ]
      congr 1
      omega
    have hkey : ((2 * 4 ^ d : ℕ) : ℝ) ≤ (δ / 4) ^ K * (4 * n) := by
      have hinv : ((4 : ℝ) / δ) ^ K = 1 / (δ / 4) ^ K := by
        rw [one_div, ← inv_pow]
        congr 1
        rw [inv_div]
      have hp : (0 : ℝ) < (δ / 4) ^ K := by positivity
      rw [hinv] at hd
      have hd' : (4 : ℝ) ^ d ≤ 2 * n * (δ / 4) ^ K := by
        rw [div_mul_eq_mul_div, one_mul, div_le_iff₀ hp] at hd
        linarith
      have : ((2 * 4 ^ d : ℕ) : ℝ) = 2 * (4 : ℝ) ^ d := by push_cast; ring
      rw [this]
      nlinarith
    have hstep1 : ((2 * 4 ^ d : ℕ) : ℝ) * (4 * n) ^ (K - 1) ≤ (δ * n) ^ K := by
      have hpos : (0 : ℝ) < (4 * n) ^ (K - 1) := by positivity
      calc ((2 * 4 ^ d : ℕ) : ℝ) * (4 * n) ^ (K - 1)
          ≤ ((δ / 4) ^ K * (4 * n)) * (4 * n) ^ (K - 1) := by nlinarith
        _ = (δ / 4) ^ K * ((4 * n) ^ (K - 1) * (4 * n)) := by ring
        _ = (δ / 4) ^ K * (4 * n) ^ K := by rw [← hKsplit]
        _ = (δ * n) ^ K := hsplit.symm
    have hstep2 : ((δ * n) : ℝ) ^ K ≤ (S.card : ℝ) ^ K :=
      pow_le_pow_left₀ (by positivity) hdense K
    linarith
  have hcast : (((2 * 4 ^ d) * (4 * n) ^ (K - 1) : ℕ) : ℝ) ≤ ((S.card ^ K : ℕ) : ℝ) := by
    push_cast
    push_cast at hreal
    exact hreal
  exact_mod_cast hcast

/-- **Set form.**  A `δ`-dense `S ⊆ [0,n)` contains a translate of a `d`-dimensional cube
with `2^d` distinct points, as soon as `(4/δ)^{2^d}·4^d ≤ 2n`. -/
theorem exists_proper_cube_subset_int {n : ℕ} {S : Finset ℤ} {δ : ℝ} (hn : 1 ≤ n)
    (h0 : 0 < δ) (h1 : δ ≤ 1) (hS : S ⊆ Finset.Ico (0 : ℤ) n)
    (hdense : δ * n ≤ S.card) {d : ℕ} (hd : ((4 : ℝ) / δ) ^ (2 ^ d) * 4 ^ d ≤ 2 * n) :
    ∃ (u : ℤ) (l : List ℤ), l.length = d ∧ (∀ a ∈ l, a ≠ 0) ∧
      ((cubeF l).image (fun x => u + x)).card = 2 ^ d ∧
      (cubeF l).image (fun x => u + x) ⊆ S := by
  classical
  obtain ⟨u, l, hlen, hne, hproper, _, hcube⟩ :=
    exists_proper_cube_of_density_int hn h0 h1 hS hdense hd
  have hinj : Function.Injective (fun x : ℤ => u + x) := fun x y h => by simpa using h
  refine ⟨u, l, hlen, hne, ?_, ?_⟩
  · rw [Finset.card_image_of_injective _ hinj, hproper]
  · intro y hy
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hy
    exact hcube x hx

/-- **A fully checked instance.**  Every subset of `[0, 32768)` of size at least `16384`
(density `1/2`) contains a translate of a two-dimensional cube with four *distinct* points:
`u, u + a, u + b, u + a + b` with `a, b ≠ 0` and all four values different.
The numeric check is `2·4²·(4·32768)³ = 2⁵⁶ ≤ 16384⁴ = 2⁵⁶`. -/
theorem proper_cube_two_of_half_dense (S : Finset ℤ) (hS : S ⊆ Finset.Ico (0 : ℤ) 32768)
    (hcard : 16384 ≤ S.card) :
    ∃ (u : ℤ) (l : List ℤ), l.length = 2 ∧ (∀ a ∈ l, a ≠ 0) ∧
      (cubeF l).card = 4 ∧ u ∈ S ∧ ∀ x ∈ cubeF l, u + x ∈ S := by
  have hcond : (2 * 4 ^ 2) * (4 * 32768) ^ (2 ^ 2 - 1) ≤ S.card ^ (2 ^ 2) := by
    have h1 : (16384 : ℕ) ^ (2 ^ 2) ≤ S.card ^ (2 ^ 2) := Nat.pow_le_pow_left hcard _
    norm_num at h1 ⊢
    omega
  obtain ⟨u, l, hlen, hne, hproper, huS, hcube⟩ :=
    exists_proper_cube_int_Ico (n := 32768) hS (d := 2) (by norm_num) hcond
  exact ⟨u, l, hlen, hne, by rw [hproper]; norm_num, huS, hcube⟩

/-! ## The two sides now describe the same object -/

/-- **The proper-cube window.**  For fixed `0 < δ < 1` and `ε > 0` and all large `n`, no
dimension `d` satisfies both

* the *existence* condition `(4/δ)^{2^d}·4^d ≤ 2n` of `exists_proper_cube_of_density_int`,
  which forces a proper cube of dimension `d` inside every `δ`-dense `S ⊆ [0,n)`, and
* the *avoidance* condition `(1+ε)(d+1)·log n ≤ 2^d·log (1/δ)` of
  `eventually_exists_dense_no_cube`, which produces a `δ`-dense `S ⊆ [n]` with no proper
  cube of dimension `d`.

So the critical dimension for proper cubes is located between the two, and both bounds are
of the same shape `2^d ≍ log n / log (1/δ)`. -/
theorem proper_cube_dimension_window {δ ε : ℝ} (h0 : 0 < δ) (h1 : δ < 1) (hε : 0 < ε) :
    ∀ᶠ n : ℕ in Filter.atTop, ∀ d : ℕ,
      (1 + ε) * (((d : ℝ) + 1) * Real.log n) ≤ (2 ^ d : ℕ) * Real.log (1 / δ) →
      ¬ (((4 : ℝ) / δ) ^ (2 ^ d) * 4 ^ d ≤ 2 * (n : ℝ)) := by
  filter_upwards [cube_dimension_window h0 h1 hε] with n hn d hd hex
  refine hn d hd ?_
  have h4d : (1 : ℝ) ≤ 4 ^ d := one_le_pow₀ (by norm_num)
  have hpos : (0 : ℝ) < ((4 : ℝ) / δ) ^ (2 ^ d) := by positivity
  nlinarith

end DenseSumsetLower