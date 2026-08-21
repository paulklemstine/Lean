/-
# The matching upper bound for affine cubes in `δ`-dense subsets of `[n]`

`Bridges.DenseSumsetLower.Cube` proves the *existence* side of the multi-fold problem:
every `S ⊆ [0,n)` with `|S| ≥ δ n` contains an affine cube
`u + {0,a₁} + ⋯ + {0,a_d}` of dimension `d` as soon as `(4/δ)^{2^d} ≤ 2 n`, i.e. for every
`d ≤ log₂ (log (2n) / log (4/δ))`.

This file proves the opposite (first-moment) side: for `d` slightly *above* that range
there are `δ`-dense sets `S ⊆ [n]` containing **no** affine cube of dimension `d` with
`2^d` distinct elements.  A `d`-dimensional cube inside `[n]` is described by `d + 1`
parameters — the base point `u` and the generators `a₁, …, a_d` — so the union bound costs
`n^{d+1}` while each proper cube forces `2^d` points of `S`; the two balance at
`2^d ≈ (d+1)·log n / log (1/δ)`, i.e. at `d ≈ log₂ (log n / log (1/δ))`, the same order as
the existence threshold.

Contents:
* `DenseSumsetLower.funCube` — the affine cube `u + {0,a₁} + ⋯ + {0,a_d}` in `ℕ`, written
  as the set of subset sums of the generator family `f : Fin d → ℕ`;
* `DenseSumsetLower.exists_card_eq_no_cube` — the counting statement: if
  `n^{d+1}·m^L < n^L` then some `m`-element `S ⊆ [n]` contains no `d`-dimensional cube with
  at least `L` distinct elements;
* `DenseSumsetLower.cube_pow_cond` — the analytic form of `n^c·m^L < n^L` for
  `m = ⌈δ n⌉`, valid for **all** exponents `c` (unlike `DeltaDense.pow_cond`, which is
  restricted to `c ≤ 10`; here `c = d + 1` must be allowed to grow with `n`);
* `DenseSumsetLower.exists_dense_no_cube` and its asymptotic packaging
  `DenseSumsetLower.eventually_exists_dense_no_cube`;
* `DenseSumsetLower.cube_dimension_window` — the consistency of the two sides: for `n`
  large no dimension `d` satisfies both the existence condition `(4/δ)^{2^d} ≤ 2n` of
  `exists_cube_of_density_int` and the avoidance condition
  `(1+ε)(d+1)·log n ≤ 2^d·log (1/δ)` proved here, so the avoidance range of `d` begins
  strictly beyond the existence range.

Caveat on the shape of the two bounds: the avoidance statement is about *proper* cubes
(those with `2^d` distinct elements — equivalently, `L = 2^d` in the counting form, which
also covers every intermediate `L`), whereas the existence statement of `Cube.lean`
produces a cube with nonzero generators which need not be proper.  Upgrading the existence
side to proper cubes is exactly sub-conjecture 3 of `FUTURE_DIRECTIONS.md`.
-/
import Bridges.DenseSumsetLower.Cube
import Bridges.DeltaDenseSumsetAvoidance

namespace DenseSumsetLower

open Finset DeltaDense

/-! ## Affine cubes in `ℕ` as sets of subset sums -/

/-- `funCube u f` is the affine cube `u + {0, f 0} + ⋯ + {0, f (d-1)}`, realised as the set
of all subset sums `u + ∑_{i ∈ T} f i`, `T ⊆ {0, …, d-1}`. -/
def funCube {d : ℕ} (u : ℕ) (f : Fin d → ℕ) : Finset ℕ :=
  Finset.univ.image (fun T : Finset (Fin d) => u + ∑ i ∈ T, f i)

/-- A `d`-dimensional cube has at most `2^d` elements; it is *proper* when equality holds. -/
lemma card_funCube_le {d : ℕ} (u : ℕ) (f : Fin d → ℕ) : (funCube u f).card ≤ 2 ^ d := by
  refine le_trans Finset.card_image_le ?_
  simp [Finset.card_univ, Fintype.card_finset]

/-- The base point belongs to the cube (take `T = ∅`). -/
lemma self_mem_funCube {d : ℕ} (u : ℕ) (f : Fin d → ℕ) : u ∈ funCube u f :=
  Finset.mem_image.2 ⟨∅, Finset.mem_univ _, by simp⟩

/-- Each generator gives a point of the cube (take `T = {i}`). -/
lemma add_mem_funCube {d : ℕ} (u : ℕ) (f : Fin d → ℕ) (i : Fin d) :
    u + f i ∈ funCube u f :=
  Finset.mem_image.2 ⟨{i}, Finset.mem_univ _, by simp⟩

/-! ## The counting statement -/

/-- **Cube-free dense sets, counting form.**  If `m ≤ n`, `1 ≤ L` and
`n^{d+1}·m^L < n^L`, then some `m`-element set `S ⊆ [n]` contains no `d`-dimensional
affine cube with positive generators and at least `L` distinct elements.

There are at most `n^{d+1}` such cubes inside `[n]` — one for each base point and each
tuple of generators — and each of them forces `L` elements of `S`. -/
theorem exists_card_eq_no_cube {n m d L : ℕ} (hmn : m ≤ n) (hL : 1 ≤ L)
    (hcond : n ^ (d + 1) * m ^ L < n ^ L) :
    ∃ S ⊆ range n, S.card = m ∧
      ∀ (u : ℕ) (f : Fin d → ℕ), (∀ i, 0 < f i) → L ≤ (funCube u f).card →
        ¬ (funCube u f ⊆ S) := by
  classical
  set J : Finset (ℕ × (Fin d → ℕ)) :=
    (range n) ×ˢ (Fintype.piFinset fun _ : Fin d => Icc 1 n) with hJ
  set I : Finset (ℕ × (Fin d → ℕ)) := J.filter (fun p => L ≤ (funCube p.1 p.2).card) with hI
  have hJcard : J.card = n ^ (d + 1) := by
    rw [hJ, Finset.card_product, Fintype.card_piFinset, Finset.card_range]
    simp [Nat.card_Icc, pow_succ, mul_comm]
  have hIcard : I.card ≤ n ^ (d + 1) := by
    rw [← hJcard]
    exact Finset.card_le_card (Finset.filter_subset _ _)
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_card_eq_avoiding_family I (fun p => funCube p.1 p.2)
      (fun p hp => by
        rw [hI, Finset.mem_filter] at hp
        exact hp.2)
      hmn hL
      (lt_of_le_of_lt (Nat.mul_le_mul_right _ hIcard) hcond)
  refine ⟨S, hSsub, hScard, ?_⟩
  intro u f hf hcard hsub
  refine hSno (u, f) ?_ hsub
  rw [hI, Finset.mem_filter, hJ, Finset.mem_product, Fintype.mem_piFinset]
  refine ⟨⟨?_, ?_⟩, hcard⟩
  · simpa using hSsub (hsub (self_mem_funCube u f))
  · intro i
    have hmem : u + f i < n := by
      simpa using hSsub (hsub (add_mem_funCube u f i))
    show f i ∈ Icc 1 n
    exact Finset.mem_Icc.2 ⟨hf i, by omega⟩

/-! ## The analytic form of the counting condition -/

/-- **The counting condition, analytic form, with unbounded exponent.**  With
`m = ⌈δ n⌉` the inequality `n^c·m^L < n^L` holds as soon as
`c·log n < L·log (1/(δ + 1/n))`.

Unlike `DeltaDense.pow_cond` this puts no ceiling on `c`; the price is that the rounding
loss is carried explicitly by the shifted density `δ + 1/n` instead of being absorbed into
a numerical slack. -/
theorem cube_pow_cond {δ : ℝ} (h0 : 0 < δ) {n c L : ℕ} (hn : 0 < n)
    (hcond : (c : ℝ) * Real.log n < L * Real.log (1 / (δ + 1 / n))) :
    n ^ c * (⌈δ * (n : ℝ)⌉₊) ^ L < n ^ L := by
  have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
  have hepos : 0 < δ + 1 / (n : ℝ) := by positivity
  -- `m ≤ (δ + 1/n) * n`
  have hm : (⌈δ * (n : ℝ)⌉₊ : ℝ) ≤ (δ + 1 / (n : ℝ)) * n := by
    have h1 : δ * (n : ℝ) + 1 = (δ + 1 / (n : ℝ)) * n := by
      field_simp
    refine le_trans (le_of_lt (Nat.ceil_lt_add_one (by positivity))) (le_of_eq h1)
  -- the real inequality `n^c * ((δ + 1/n) n)^L < n^L` after taking logarithms
  have hlog : (c : ℝ) * Real.log n + L * Real.log (δ + 1 / (n : ℝ)) < 0 := by
    have hinv : Real.log (1 / (δ + 1 / (n : ℝ))) = -Real.log (δ + 1 / (n : ℝ)) := by
      rw [one_div, Real.log_inv]
    rw [hinv] at hcond
    linarith
  have hkey : (n : ℝ) ^ c * (δ + 1 / (n : ℝ)) ^ L < 1 := by
    have hpos : (0 : ℝ) < (n : ℝ) ^ c * (δ + 1 / (n : ℝ)) ^ L := by positivity
    have hlt : Real.log ((n : ℝ) ^ c * (δ + 1 / (n : ℝ)) ^ L) < Real.log 1 := by
      rw [Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow,
        Real.log_one]
      exact hlog
    exact (Real.log_lt_log_iff hpos (by norm_num)).1 (by simpa using hlt)
  have hfinal : ((n : ℝ)) ^ c * (⌈δ * (n : ℝ)⌉₊ : ℝ) ^ L < (n : ℝ) ^ L := by
    have h1 : (⌈δ * (n : ℝ)⌉₊ : ℝ) ^ L ≤ ((δ + 1 / (n : ℝ)) * n) ^ L :=
      pow_le_pow_left₀ (by positivity) hm L
    calc ((n : ℝ)) ^ c * (⌈δ * (n : ℝ)⌉₊ : ℝ) ^ L
        ≤ (n : ℝ) ^ c * ((δ + 1 / (n : ℝ)) * n) ^ L := by
          exact mul_le_mul_of_nonneg_left h1 (by positivity)
      _ = ((n : ℝ) ^ c * (δ + 1 / (n : ℝ)) ^ L) * (n : ℝ) ^ L := by rw [mul_pow]; ring
      _ < 1 * (n : ℝ) ^ L := by
          exact mul_lt_mul_of_pos_right hkey (by positivity)
      _ = (n : ℝ) ^ L := one_mul _
  exact_mod_cast hfinal

/-! ## Dense sets with no proper cube of a given dimension -/

/-- **Cube-free dense sets.**  Let `0 < δ` and let `n ≥ 2`.  If the dimension `d`
satisfies `(d + 1)·log n < 2^d·log (1/(δ + 1/n))` then there is a set `S ⊆ [n]` with
`|S| ≥ δ n` containing no `d`-dimensional affine cube with positive generators and `2^d`
distinct elements. -/
theorem exists_dense_no_cube {δ : ℝ} (h0 : 0 < δ) {n d : ℕ} (hn2 : 2 ≤ n)
    (hδn : δ * n ≤ n)
    (hcond : ((d : ℝ) + 1) * Real.log n < (2 ^ d : ℕ) * Real.log (1 / (δ + 1 / n))) :
    ∃ S ⊆ range n, δ * n ≤ S.card ∧
      ∀ (u : ℕ) (f : Fin d → ℕ), (∀ i, 0 < f i) → (funCube u f).card = 2 ^ d →
        ¬ (funCube u f ⊆ S) := by
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hmn : ⌈δ * (n : ℝ)⌉₊ ≤ n := Nat.ceil_le.2 hδn
  have hcast : ((d + 1 : ℕ) : ℝ) = (d : ℝ) + 1 := by push_cast; ring
  have hcond' : n ^ (d + 1) * (⌈δ * (n : ℝ)⌉₊) ^ (2 ^ d) < n ^ (2 ^ d) := by
    refine cube_pow_cond h0 (by omega) ?_
    rw [hcast]
    exact_mod_cast hcond
  obtain ⟨S, hSsub, hScard, hSno⟩ :=
    exists_card_eq_no_cube hmn (Nat.one_le_two_pow) hcond'
  refine ⟨S, hSsub, by rw [hScard]; exact Nat.le_ceil _, ?_⟩
  intro u f hf hcard
  exact hSno u f hf (le_of_eq hcard.symm)

/-- **Asymptotic packaging.**  For every `0 < δ < 1` and every `ε > 0`, for all
sufficiently large `n` and *every* dimension `d` with

`(1 + ε)·(d + 1)·log n ≤ 2^d·log (1/δ)`,

there is a `δ`-dense set `S ⊆ [n]` containing no proper `d`-dimensional affine cube.
Since the hypothesis holds as soon as `2^d ≥ (1+ε)(d+1)·log n / log (1/δ)`, i.e. for
`d ≥ log₂ (log n / log (1/δ)) + log₂ (d+1) + O(1)`, this is the matching first-moment
counterpart of `DenseSumsetLower.exists_cube_of_density_int`. -/
theorem eventually_exists_dense_no_cube {δ ε : ℝ} (h0 : 0 < δ) (h1 : δ < 1) (hε : 0 < ε) :
    ∀ᶠ n : ℕ in Filter.atTop, ∀ d : ℕ,
      (1 + ε) * (((d : ℝ) + 1) * Real.log n) ≤ (2 ^ d : ℕ) * Real.log (1 / δ) →
      ∃ S ⊆ range n, δ * n ≤ S.card ∧
        ∀ (u : ℕ) (f : Fin d → ℕ), (∀ i, 0 < f i) → (funCube u f).card = 2 ^ d →
          ¬ (funCube u f ⊆ S) := by
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  -- the shifted density `δ + 1/n` eventually loses at most a factor `1 + ε` in the log
  have hshift : ∀ᶠ n : ℕ in Filter.atTop,
      Real.log (1 / δ) / (1 + ε) < Real.log (1 / (δ + 1 / (n : ℝ))) := by
    have hlim : Filter.Tendsto (fun n : ℕ => Real.log (1 / (δ + 1 / (n : ℝ))))
        Filter.atTop (nhds (Real.log (1 / δ))) := by
      have h1n : Filter.Tendsto (fun n : ℕ => δ + 1 / (n : ℝ)) Filter.atTop (nhds (δ + 0)) :=
        Filter.Tendsto.const_add δ tendsto_one_div_atTop_nhds_zero_nat
      rw [add_zero] at h1n
      have h2 : Filter.Tendsto (fun n : ℕ => 1 / (δ + 1 / (n : ℝ))) Filter.atTop
          (nhds (1 / δ)) := tendsto_const_nhds.div h1n (ne_of_gt h0)
      exact (Real.continuousAt_log (by positivity)).tendsto.comp h2
    have hlt : Real.log (1 / δ) / (1 + ε) < Real.log (1 / δ) := by
      rw [div_lt_iff₀ (by linarith)]
      nlinarith
    exact hlim.eventually (eventually_gt_nhds hlt)
  filter_upwards [hshift, Filter.eventually_ge_atTop 2] with n hn hn2
  intro d hd
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hlogn : 0 < Real.log n := Real.log_pos (by exact_mod_cast hn2)
  have hδn : δ * n ≤ n := by nlinarith
  refine exists_dense_no_cube h0 hn2 hδn ?_
  -- `(d+1) log n ≤ 2^d log(1/δ)/(1+ε) < 2^d log(1/(δ+1/n))`
  have hpow : (0 : ℝ) < ((2 ^ d : ℕ) : ℝ) := by positivity
  have hstep : ((d : ℝ) + 1) * Real.log n ≤ (2 ^ d : ℕ) * (Real.log (1 / δ) / (1 + ε)) := by
    rw [mul_div_assoc'] at *
    rw [le_div_iff₀ (by linarith)]
    linarith [hd]
  calc ((d : ℝ) + 1) * Real.log n
      ≤ (2 ^ d : ℕ) * (Real.log (1 / δ) / (1 + ε)) := hstep
    _ < (2 ^ d : ℕ) * Real.log (1 / (δ + 1 / (n : ℝ))) := by
        exact mul_lt_mul_of_pos_left hn hpow

/-- **The cube-dimension window.**  For fixed `0 < δ < 1` and `ε > 0` and all large `n`:

* (existence, `exists_cube_of_density_int`) every `δ`-dense `S ⊆ [0,n)` contains an affine
  cube of every dimension `d` with `(4/δ)^{2^d} ≤ 2n`;
* (avoidance, this file) some `δ`-dense `S ⊆ [n]` contains no *proper* cube of dimension
  `d` once `(1+ε)(d+1)·log n ≤ 2^d·log (1/δ)`.

The statement below records that the two ranges of `d` are disjoint, i.e. the avoidance
range really begins beyond the existence range: for all sufficiently large `n` no
dimension `d` satisfies both conditions. -/
theorem cube_dimension_window {δ ε : ℝ} (h0 : 0 < δ) (h1 : δ < 1) (hε : 0 < ε) :
    ∀ᶠ n : ℕ in Filter.atTop, ∀ d : ℕ,
      (1 + ε) * (((d : ℝ) + 1) * Real.log n) ≤ (2 ^ d : ℕ) * Real.log (1 / δ) →
      ¬ ((4 / δ) ^ (2 ^ d) ≤ 2 * (n : ℝ)) := by
  have hlarge : ∀ᶠ n : ℕ in Filter.atTop, Real.log 2 / ε < Real.log n := by
    have hlog : Filter.Tendsto (fun n : ℕ => Real.log n) Filter.atTop Filter.atTop :=
      Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop
    exact hlog.eventually_gt_atTop _
  filter_upwards [Filter.eventually_ge_atTop 2, hlarge] with n hn2 hnbig
  intro d hd hex
  have hn0 : (0 : ℝ) < n := by
    have : (2 : ℝ) ≤ n := by exact_mod_cast hn2
    linarith
  have hlogn : 0 < Real.log n := Real.log_pos (by exact_mod_cast hn2)
  have hlpos : 0 < Real.log (1 / δ) := by
    simp only [one_div]
    exact Real.log_pos (by rw [lt_inv_comm₀ (by norm_num) h0]; simpa using h1)
  -- the existence condition gives `2^d log(4/δ) ≤ log 2 + log n`, hence
  -- `2^d log(1/δ) ≤ log 2 + log n`, since `log (4/δ) ≥ log (1/δ)`
  have hlog4 : Real.log (1 / δ) ≤ Real.log (4 / δ) := by
    refine Real.log_le_log (by positivity) ?_
    rw [div_le_div_iff_of_pos_right h0]
    norm_num
  have hkey : ((2 ^ d : ℕ) : ℝ) * Real.log (4 / δ) ≤ Real.log 2 + Real.log n := by
    have h2 : Real.log ((4 / δ) ^ (2 ^ d)) ≤ Real.log (2 * n) :=
      Real.log_le_log (by positivity) hex
    rw [Real.log_pow, Real.log_mul (by norm_num) (by positivity)] at h2
    exact_mod_cast h2
  have hpow1 : (1 : ℝ) ≤ ((2 ^ d : ℕ) : ℝ) := by
    exact_mod_cast Nat.one_le_two_pow
  have hbound : ((2 ^ d : ℕ) : ℝ) * Real.log (1 / δ) ≤ Real.log 2 + Real.log n := by
    refine le_trans (mul_le_mul_of_nonneg_left hlog4 (by positivity)) hkey
  -- but the avoidance condition forces `2^d log(1/δ) ≥ (1+ε) log n > log 2 + log n`
  -- once `n` is large; we only need `d ≥ 0`, `log 2 ≤ log n` fails for small `n`, so we
  -- argue with the parameter factor `(d+1) ≥ 1` instead.
  have hlow : (1 + ε) * Real.log n ≤ ((2 ^ d : ℕ) : ℝ) * Real.log (1 / δ) := by
    refine le_trans ?_ hd
    have hd1 : (1 : ℝ) ≤ (d : ℝ) + 1 := by
      have : (0 : ℝ) ≤ (d : ℝ) := Nat.cast_nonneg d
      linarith
    have hstep : Real.log n ≤ ((d : ℝ) + 1) * Real.log n :=
      le_mul_of_one_le_left hlogn.le hd1
    exact mul_le_mul_of_nonneg_left hstep (by linarith)
  -- combining: `(1+ε) log n ≤ log 2 + log n`, i.e. `ε log n ≤ log 2`
  have hcomb : ε * Real.log n ≤ Real.log 2 := by linarith
  rw [div_lt_iff₀ hε] at hnbig
  nlinarith

end DenseSumsetLower