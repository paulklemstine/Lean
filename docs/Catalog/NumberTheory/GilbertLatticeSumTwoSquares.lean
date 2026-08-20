import Catalog.Shared.GilbertLatticeBasic

/-!
# A bridge: the conditioned Gilbert model and the two-square theorem

This file connects two areas that look unrelated at first sight:

* **continuum percolation on the square lattice** — Gilbert's disc model conditioned on
  `ℤ²`, where one point is placed in each cell of the grid and two points are joined
  when they are at distance `< R` (the model of `GilbertLatticeBasic.lean`), and
* **the arithmetic of sums of two squares** — Fermat's two-square theorem, the
  Brahmagupta–Fibonacci identity and the classification of the integers represented by
  the norm form `x² + y²` of the Gaussian integers.

The link is the family of *aligned* configurations, in which every point receives the
same offset `(s,t)` inside its cell: the point set is then a translate of `ℤ²`, so the
squared length of every edge of the Gilbert graph is an integer of the form `a² + b²`,
and conversely every such integer is realised.

## Main results

* `GilbertLattice.latticeSpectrum_eq_sums_of_two_squares` — the *spectrum* of the model
  (the set of squared edge lengths available to an aligned configuration) is exactly the
  set of positive sums of two squares;
* `GilbertLattice.prime_mem_latticeSpectrum_iff` — a prime `p` occurs as a squared edge
  length iff `p % 4 ≠ 3` (**Fermat's two-square theorem** read geometrically);
* `GilbertLattice.latticeSpectrum_iff_factorization` — the full arithmetic description:
  `n` occurs iff `n > 0` and every prime `q ≡ 3 [MOD 4]` divides `n` to an even power;
* `GilbertLattice.latticeSpectrum_mul` — the spectrum is closed under multiplication
  (Brahmagupta–Fibonacci: the geometry of the model is a *multiplicative monoid*);
* `GilbertLattice.exists_edge_of_length_sqrt_prime` — geometric form of the two-square
  theorem: for a prime `p` with `p % 4 ≠ 3` and any radius `R > √p`, the Gilbert graph
  of an aligned configuration contains an edge of length exactly `√p`, whereas for
  `p % 4 = 3` no edge of any aligned configuration has length `√p`;
* `GilbertLattice.alignedConfig_connected_iff` — an aligned configuration percolates (in
  fact is connected) exactly when `R > 1`, so `1` is the critical radius of the aligned
  subfamily, to be compared with `R_min ∈ [1/3, 1/2]` and `R_full = √5`;
* `GilbertLattice.neighborSet_alignedConfig` — for `1 < R ≤ √2` the neighbours of a cell
  are its four grid neighbours, the first instance of the Gauss circle problem.
-/

namespace GilbertLattice

/-! ## Aligned configurations -/

/-- The *aligned* configuration with offset `(s,t)`: every point is placed at the same
position inside its cell, so the point set is the translated lattice `ℤ² + (s,t)`. -/
noncomputable def alignedConfig {s t : ℝ} (hs0 : 0 ≤ s) (hs1 : s ≤ 1) (ht0 : 0 ≤ t)
    (ht1 : t ≤ 1) : Config where
  off := fun _ => (s, t)
  off_nonneg_fst := fun _ => hs0
  off_nonneg_snd := fun _ => ht0
  off_le_one_fst := fun _ => hs1
  off_le_one_snd := fun _ => ht1

variable {s t : ℝ} {hs0 : 0 ≤ s} {hs1 : s ≤ 1} {ht0 : 0 ≤ t} {ht1 : t ≤ 1}

/-- In an aligned configuration the squared distance between two points is the squared
distance of the two cells: an integer of the form `a² + b²`. -/
lemma sqdist_alignedConfig (c c' : ℤ × ℤ) :
    sqdist (alignedConfig hs0 hs1 ht0 ht1) c c'
      = (((c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 : ℤ) : ℝ) := by
  unfold sqdist px py alignedConfig
  push_cast
  ring

/-- Adjacency in an aligned configuration is a purely arithmetic condition. -/
theorem adj_alignedConfig_iff {R : ℝ} (hR : 0 < R) (c c' : ℤ × ℤ) :
    (gilbert R (alignedConfig hs0 hs1 ht0 ht1)).Adj c c' ↔
      c ≠ c' ∧ (((c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 : ℤ) : ℝ) < R ^ 2 := by
  constructor
  · rintro ⟨hne, hlt⟩
    refine ⟨hne, ?_⟩
    rw [← sqdist_alignedConfig (hs0 := hs0) (hs1 := hs1) (ht0 := ht0) (ht1 := ht1)]
    have h0 := sqdist_nonneg (alignedConfig hs0 hs1 ht0 ht1) c c'
    have := Real.sq_sqrt h0
    rw [pdist] at hlt
    nlinarith [Real.sqrt_nonneg (sqdist (alignedConfig hs0 hs1 ht0 ht1) c c')]
  · rintro ⟨hne, hlt⟩
    refine adj_of_sqdist_lt hR hne ?_
    rwa [sqdist_alignedConfig]

/-- Two distinct cells are at squared distance at least `1`. -/
lemma one_le_cell_sqdist {c c' : ℤ × ℤ} (h : c ≠ c') :
    1 ≤ (c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 := by
  have hne : c.1 ≠ c'.1 ∨ c.2 ≠ c'.2 := by
    by_contra hcon
    push_neg at hcon
    exact h (Prod.ext hcon.1 hcon.2)
  rcases hne with h1 | h1
  · have : 1 ≤ (c.1 - c'.1) ^ 2 := by
      have : c.1 - c'.1 ≠ 0 := sub_ne_zero_of_ne h1
      nlinarith [sq_nonneg (c.1 - c'.1), Int.one_le_abs (z := c.1 - c'.1) this,
        sq_abs (c.1 - c'.1)]
    nlinarith [sq_nonneg (c.2 - c'.2)]
  · have : 1 ≤ (c.2 - c'.2) ^ 2 := by
      have : c.2 - c'.2 ≠ 0 := sub_ne_zero_of_ne h1
      nlinarith [sq_nonneg (c.2 - c'.2), Int.one_le_abs (z := c.2 - c'.2) this,
        sq_abs (c.2 - c'.2)]
    nlinarith [sq_nonneg (c.1 - c'.1)]

/-! ## The spectrum of squared edge lengths -/

/-- The **spectrum** of the aligned family: the set of integers that occur as the squared
distance between the points of two distinct cells of an aligned configuration. -/
def latticeSpectrum : Set ℕ :=
  {n : ℕ | ∃ c c' : ℤ × ℤ, c ≠ c' ∧ (c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 = (n : ℤ)}

/-- Membership in the spectrum, in terms of integer solutions of `a² + b² = n`. -/
theorem mem_latticeSpectrum_iff {n : ℕ} :
    n ∈ latticeSpectrum ↔ 0 < n ∧ ∃ a b : ℤ, a ^ 2 + b ^ 2 = (n : ℤ) := by
  constructor
  · rintro ⟨c, c', hne, heq⟩
    have hpos : 0 < (n : ℤ) := lt_of_lt_of_le (by norm_num) (heq ▸ one_le_cell_sqdist hne)
    exact ⟨by exact_mod_cast hpos, c.1 - c'.1, c.2 - c'.2, heq⟩
  · rintro ⟨hpos, a, b, hab⟩
    refine ⟨(a, b), (0, 0), ?_, by simpa using hab⟩
    intro hc
    rw [Prod.ext_iff] at hc
    simp only at hc
    rw [hc.1, hc.2] at hab
    norm_num at hab
    omega

/-- **The spectrum is exactly the set of positive sums of two squares.** -/
theorem latticeSpectrum_eq_sums_of_two_squares :
    latticeSpectrum = {n : ℕ | 0 < n ∧ ∃ x y : ℕ, n = x ^ 2 + y ^ 2} := by
  ext n
  rw [mem_latticeSpectrum_iff]
  constructor
  · rintro ⟨hpos, a, b, hab⟩
    refine ⟨hpos, a.natAbs, b.natAbs, ?_⟩
    have h1 : ((a.natAbs : ℤ)) ^ 2 = a ^ 2 := Int.natAbs_pow_two a
    have h2 : ((b.natAbs : ℤ)) ^ 2 = b ^ 2 := Int.natAbs_pow_two b
    have : ((n : ℤ)) = ((a.natAbs : ℤ)) ^ 2 + ((b.natAbs : ℤ)) ^ 2 := by rw [h1, h2, hab]
    exact_mod_cast this
  · rintro ⟨hpos, x, y, hxy⟩
    exact ⟨hpos, (x : ℤ), (y : ℤ), by exact_mod_cast hxy.symm⟩

/-- A sum of two squares is never `≡ 3 [MOD 4]`. -/
lemma sq_add_sq_mod_four_ne_three (x y : ℕ) : (x ^ 2 + y ^ 2) % 4 ≠ 3 := by
  have hx : x ^ 2 % 4 = (x % 4) ^ 2 % 4 := by rw [Nat.pow_mod]
  have hy : y ^ 2 % 4 = (y % 4) ^ 2 % 4 := by rw [Nat.pow_mod]
  have hadd : (x ^ 2 + y ^ 2) % 4 = (x ^ 2 % 4 + y ^ 2 % 4) % 4 := Nat.add_mod _ _ _
  have hx4 : x % 4 < 4 := Nat.mod_lt _ (by norm_num)
  have hy4 : y % 4 < 4 := Nat.mod_lt _ (by norm_num)
  interval_cases h : (x % 4) <;> interval_cases h2 : (y % 4) <;> omega

/-- **Fermat's two-square theorem, geometrically.**  A prime `p` is the squared length of
an edge of an aligned configuration if and only if `p % 4 ≠ 3`. -/
theorem prime_mem_latticeSpectrum_iff {p : ℕ} (hp : p.Prime) :
    p ∈ latticeSpectrum ↔ p % 4 ≠ 3 := by
  rw [latticeSpectrum_eq_sums_of_two_squares]
  constructor
  · rintro ⟨-, x, y, hxy⟩ h3
    exact sq_add_sq_mod_four_ne_three x y (hxy ▸ h3)
  · intro h3
    haveI : Fact p.Prime := ⟨hp⟩
    obtain ⟨a, b, hab⟩ := Nat.Prime.sq_add_sq h3
    exact ⟨hp.pos, a, b, hab.symm⟩

/-- **The arithmetic description of the spectrum.**  An integer occurs as a squared edge
length of an aligned configuration exactly when it is positive and every prime factor
congruent to `3` mod `4` occurs in it with an even exponent. -/
theorem latticeSpectrum_iff_factorization {n : ℕ} :
    n ∈ latticeSpectrum ↔
      0 < n ∧ ∀ q ∈ n.primeFactors, q % 4 = 3 → Even (padicValNat q n) := by
  rw [latticeSpectrum_eq_sums_of_two_squares]
  constructor
  · rintro ⟨hpos, x, y, hxy⟩
    exact ⟨hpos, Nat.eq_sq_add_sq_iff.1 ⟨x, y, hxy⟩⟩
  · rintro ⟨hpos, h⟩
    obtain ⟨x, y, hxy⟩ := Nat.eq_sq_add_sq_iff.2 h
    exact ⟨hpos, x, y, hxy⟩

/-- **The spectrum is a multiplicative monoid** (Brahmagupta–Fibonacci identity): if the
squared lengths `m` and `n` are realised by the model, so is `m * n`. -/
theorem latticeSpectrum_mul {m n : ℕ} (hm : m ∈ latticeSpectrum) (hn : n ∈ latticeSpectrum) :
    m * n ∈ latticeSpectrum := by
  rw [mem_latticeSpectrum_iff] at hm hn ⊢
  obtain ⟨hmp, a, b, hab⟩ := hm
  obtain ⟨hnp, c, d, hcd⟩ := hn
  refine ⟨Nat.mul_pos hmp hnp, a * c - b * d, a * d + b * c, ?_⟩
  have : (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 = (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) := by
    ring
  rw [this, hab, hcd]
  push_cast
  ring

/-- The spectrum, as a multiplicative submonoid of `ℕ`: the squared edge lengths of the
aligned family form a monoid isomorphic to the monoid of norms of nonzero Gaussian
integers. -/
def latticeSpectrumSubmonoid : Submonoid ℕ where
  carrier := latticeSpectrum
  one_mem' := by
    refine mem_latticeSpectrum_iff.2 ⟨Nat.one_pos, 1, 0, by norm_num⟩
  mul_mem' := latticeSpectrum_mul

/-- **The spectrum is the set of norms of nonzero Gaussian integers.**  The squared edge
lengths of the conditioned Gilbert model along aligned configurations are exactly the
values of the norm form of the ring `ℤ[i]` at its nonzero elements. -/
theorem latticeSpectrum_eq_gaussianInt_norms :
    latticeSpectrum = {n : ℕ | ∃ z : GaussianInt, z ≠ 0 ∧ Zsqrtd.norm z = (n : ℤ)} := by
  ext n
  rw [mem_latticeSpectrum_iff]
  constructor
  · rintro ⟨hpos, a, b, hab⟩
    refine ⟨⟨a, b⟩, ?_, ?_⟩
    · intro hz
      rw [Zsqrtd.ext_iff] at hz
      simp only [Zsqrtd.re_zero, Zsqrtd.im_zero] at hz
      rw [hz.1, hz.2] at hab
      norm_num at hab
      omega
    · rw [Zsqrtd.norm_def]
      simp only
      linarith [hab, sq_nonneg a]
  · rintro ⟨z, hz, hnorm⟩
    have hzz : z.re ^ 2 + z.im ^ 2 = (n : ℤ) := by
      rw [Zsqrtd.norm_def] at hnorm
      nlinarith [hnorm]
    refine ⟨?_, z.re, z.im, hzz⟩
    have hne : z.re ≠ 0 ∨ z.im ≠ 0 := by
      by_contra hcon
      push_neg at hcon
      exact hz (Zsqrtd.ext_iff.2 ⟨by simpa using hcon.1, by simpa using hcon.2⟩)
    have hposz : 0 < z.re ^ 2 + z.im ^ 2 := by
      rcases hne with h | h
      · have : 0 < z.re ^ 2 := by positivity
        nlinarith [sq_nonneg z.im]
      · have : 0 < z.im ^ 2 := by positivity
        nlinarith [sq_nonneg z.re]
    have : (0 : ℤ) < (n : ℤ) := hzz ▸ hposz
    exact_mod_cast this

/-! ## Geometric consequences -/

/-- The distance between the points of two cells in an aligned configuration. -/
lemma pdist_alignedConfig (c c' : ℤ × ℤ) :
    pdist (alignedConfig hs0 hs1 ht0 ht1) c c'
      = Real.sqrt (((c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 : ℤ) : ℝ) := by
  rw [pdist, sqdist_alignedConfig]

/-- **Geometric form of the two-square theorem, positive part.**  If `p` is a prime with
`p % 4 ≠ 3` then, for every radius `R > √p`, the Gilbert graph of an aligned
configuration contains an edge of length exactly `√p`. -/
theorem exists_edge_of_length_sqrt_prime {p : ℕ} (hp : p.Prime) (h3 : p % 4 ≠ 3) {R : ℝ}
    (hR : Real.sqrt p < R) :
    ∃ c c' : ℤ × ℤ, (gilbert R (alignedConfig hs0 hs1 ht0 ht1)).Adj c c' ∧
      pdist (alignedConfig hs0 hs1 ht0 ht1) c c' = Real.sqrt p := by
  obtain ⟨c, c', hne, heq⟩ := (prime_mem_latticeSpectrum_iff hp).2 h3
  have hd : pdist (alignedConfig hs0 hs1 ht0 ht1) c c' = Real.sqrt p := by
    rw [pdist_alignedConfig, heq]
    norm_num
  exact ⟨c, c', ⟨hne, by rw [hd]; exact hR⟩, hd⟩

/-- **Geometric form of the two-square theorem, negative part.**  If `p % 4 = 3` then no
pair of points of an aligned configuration is ever at distance `√p`. -/
theorem no_edge_of_length_sqrt_prime_three_mod_four {p : ℕ} (hp : p.Prime) (h3 : p % 4 = 3)
    (c c' : ℤ × ℤ) (hne : c ≠ c') :
    pdist (alignedConfig hs0 hs1 ht0 ht1) c c' ≠ Real.sqrt p := by
  intro hcon
  rw [pdist_alignedConfig] at hcon
  have hnn : (0 : ℝ) ≤ (((c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 : ℤ) : ℝ) := by
    have : (0 : ℤ) ≤ (c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 := by positivity
    exact_mod_cast this
  have hpn : (0 : ℝ) ≤ (p : ℝ) := by positivity
  have heq : (((c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 : ℤ) : ℝ) = (p : ℝ) := by
    have h2 := congrArg (fun z : ℝ => z ^ 2) hcon
    simp only at h2
    rwa [Real.sq_sqrt hnn, Real.sq_sqrt hpn] at h2
  have hz : (c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 = (p : ℤ) := by exact_mod_cast heq
  exact (prime_mem_latticeSpectrum_iff hp).1 ⟨c, c', hne, hz⟩ h3

/-! ## The critical radius of the aligned subfamily -/

/-- Below radius `1` an aligned configuration has no edge at all. -/
lemma not_adj_alignedConfig_of_le_one {R : ℝ} (hR : R ≤ 1) (c c' : ℤ × ℤ) :
    ¬ (gilbert R (alignedConfig hs0 hs1 ht0 ht1)).Adj c c' := by
  rintro ⟨hne, hlt⟩
  have h1 : (1 : ℤ) ≤ (c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 := one_le_cell_sqdist hne
  have h1' : (1 : ℝ) ≤ sqdist (alignedConfig hs0 hs1 ht0 ht1) c c' := by
    rw [sqdist_alignedConfig]; exact_mod_cast h1
  have : (1 : ℝ) ≤ pdist (alignedConfig hs0 hs1 ht0 ht1) c c' := by
    rw [pdist, show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt h1'
  linarith

/-- **The aligned subfamily has critical radius exactly `1`.**  An aligned configuration
gives a connected Gilbert graph iff `R > 1`; for `R ≤ 1` the graph has no edge at all,
so every component is a single point. -/
theorem alignedConfig_connected_iff {R : ℝ} :
    (gilbert R (alignedConfig hs0 hs1 ht0 ht1)).Connected ↔ 1 < R := by
  constructor
  · intro hconn
    by_contra hcon
    push_neg at hcon
    obtain ⟨w⟩ := hconn.preconnected (0, 0) (1, 0)
    cases w with
    | cons hadj w' => exact not_adj_alignedConfig_of_le_one hcon _ _ hadj
  · intro hR
    have hR0 : (0 : ℝ) < R := by linarith
    refine connected_of_grid_adj (fun i j => ?_) (fun i j => ?_)
    · refine (adj_alignedConfig_iff hR0 _ _).2 ⟨by intro h; rw [Prod.ext_iff] at h; omega, ?_⟩
      have : ((i : ℤ) - (i + 1)) ^ 2 + ((j : ℤ) - j) ^ 2 = 1 := by ring
      simp only [this]
      push_cast
      nlinarith
    · refine (adj_alignedConfig_iff hR0 _ _).2 ⟨by intro h; rw [Prod.ext_iff] at h; omega, ?_⟩
      have : ((i : ℤ) - i) ^ 2 + ((j : ℤ) - (j + 1)) ^ 2 = 1 := by ring
      simp only [this]
      push_cast
      nlinarith

/-- **First instance of the Gauss circle problem.**  For `1 < R ≤ √2` the neighbours of a
cell in an aligned configuration are exactly its four grid neighbours: the punctured disc
of radius `R` contains exactly the four lattice vectors of norm `1`. -/
theorem neighborSet_alignedConfig {R : ℝ} (hR : 1 < R) (hR2 : R ≤ Real.sqrt 2) (c : ℤ × ℤ) :
    (gilbert R (alignedConfig hs0 hs1 ht0 ht1)).neighborSet c
      = {(c.1 + 1, c.2), (c.1 - 1, c.2), (c.1, c.2 + 1), (c.1, c.2 - 1)} := by
  have hR0 : (0 : ℝ) < R := by linarith
  have hRsq : R ^ 2 ≤ 2 := by
    have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
    nlinarith [Real.sqrt_nonneg 2]
  ext c'
  simp only [SimpleGraph.mem_neighborSet, Set.mem_insert_iff, Set.mem_singleton_iff]
  rw [adj_alignedConfig_iff hR0]
  constructor
  · rintro ⟨hne, hlt⟩
    have h1 : (1 : ℤ) ≤ (c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 := one_le_cell_sqdist hne
    have h2 : (((c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 : ℤ) : ℝ) < 2 := lt_of_lt_of_le hlt hRsq
    have h2' : (c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 < 2 := by exact_mod_cast h2
    have heq : (c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 = 1 := by omega
    have hx : (c.1 - c'.1) ^ 2 ≤ 1 := by nlinarith [sq_nonneg (c.2 - c'.2)]
    have hy : (c.2 - c'.2) ^ 2 ≤ 1 := by nlinarith [sq_nonneg (c.1 - c'.1)]
    have hxb : -1 ≤ c.1 - c'.1 ∧ c.1 - c'.1 ≤ 1 := by constructor <;> nlinarith
    have hyb : -1 ≤ c.2 - c'.2 ∧ c.2 - c'.2 ≤ 1 := by constructor <;> nlinarith
    have hx1 : c.1 - c'.1 = -1 ∨ c.1 - c'.1 = 0 ∨ c.1 - c'.1 = 1 := by omega
    have hy1 : c.2 - c'.2 = -1 ∨ c.2 - c'.2 = 0 ∨ c.2 - c'.2 = 1 := by omega
    rcases hx1 with h | h | h <;> rcases hy1 with h' | h' | h' <;>
      rw [h, h'] at heq <;> norm_num at heq <;> simp only [Prod.ext_iff] <;> omega
  · intro h
    have hxy : (c.1 - c'.1) ^ 2 + (c.2 - c'.2) ^ 2 = 1 := by
      rcases h with h | h | h | h <;> rw [h] <;> simp
    refine ⟨?_, ?_⟩
    · intro hc
      rw [hc] at hxy
      simp at hxy
    · rw [hxy]
      push_cast
      nlinarith

end GilbertLattice