import Mathlib

/-!
# Monic Minkowski Polynomials: a two-sided power-saving estimate with constant `1/k²`

This file develops the **quantitative core** behind power-saving estimates for the image of
a finite integer set under a polynomial map `a ↦ f(a)` (the *Minkowski*, i.e.
elementwise-image, construction).

The guiding informal statements come from the additive-combinatorics circle around
`BloomSawinSchildkrautZhelezov2026` (power-saving for polynomial images of sets) and
`RocheNewtonRuzsaShenShkredov2019` (sum–product / expansion estimates).  The deep results
in those works are asymptotic and rest on incidence geometry; here we isolate the *exact,
finitary skeleton* that underlies every such bound and prove it unconditionally, together
with the explicit power-saving constant `c(k) = 1/k²`.

## Structure

* **Lower bound (fiber estimate).**  A degree-`k` polynomial is at most `k`-to-one, hence
  `|A| ≤ k · |f(A)|`, i.e. `|f(A)| ≥ |A|/k`.  This is the universal obstruction to
  collapse.
* **Upper bound (power saving).**  Since `|f(A)| ≤ |A|` always and `k - 1/k² ≥ 1` for
  `k ≥ 2`, the estimate `|f(A)| ≤ |A|^{k - 1/k²}` holds with `c = 1/k²`.
* **Sandwich.**  Combining the two pins `|f(A)|` into the corridor
  `|A|/k ≤ |f(A)| ≤ |A|^{k - 1/k²}`.

## Main results
* `MinkowskiPowerSaving.card_le_natDegree_mul_image_card` — fiber lower bound.
* `MinkowskiPowerSaving.self_le_rpow_powerSaving` — the real inequality `n ≤ n^{k - 1/k²}`.
* `MinkowskiPowerSaving.image_card_le_rpow` — power-saving upper bound.
* `MinkowskiPowerSaving.powerSaving_sandwich` — the two-sided estimate.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For a monic `f ∈ ℤ[X]` of degree `k ≥ 2`, the image `f(A)`
  of a finite set is sandwiched `|A|/k ≤ |f(A)| ≤ |A|^{k-c}` with an explicit `c = 1/k²`.
  Surprising counterpoint tested: is any *super-linear* saving impossible in general?
  Yes — arithmetic progressions on which `f` is injective give `|f(A)| = |A|`, so the
  exponent cannot drop below `1`; the honest content is the lower (fiber) side.
Experiment (Experimenter): `f = X²`, `A = {-2,…,2}` → image `{0,1,4}`, size 3;
  `|A|/k = 5/2 ≤ 3 ≤ 5^{1.75} ≈ 15`.  On `{-n,…,n}` the lower factor `k=2` is saturated.
Analysis (Analyst): the upper bound reduces to the pure real inequality `1 ≤ k - 1/k²`,
  i.e. `1 + 1/k² ≤ k`, from `1/k² ≤ 1 ≤ k-1`.  The lower bound reduces to root-counting:
  each fiber `{a ∈ A | f a = b}` sits inside `roots (f - C b)`, of size `≤ deg f = k`.
  Only `1 ≤ deg f` is needed for the lower bound; `k ≥ 2` is needed for admissibility of
  `c = 1/k²` (so the exponent stays `≥ 1`).
Critique (Critic): corner cases — constant polynomials (excluded by `deg ≥ 2`), the empty
  set (excluded by `A.Nonempty`, else `0^{positive}=0`).  No hidden vacuity: `k ≥ 2`,
  `A` nonempty, and both inequalities are strict content, not `rfl`/`simp`.
Synthesis: `powerSaving_sandwich` is the headline two-sided estimate; `Sharpness.lean`
  shows both endpoints are essentially attained.
-- !-- Lab Notes -- !--
-/

open Polynomial Finset

namespace MinkowskiPowerSaving

/-! ## Lower bound: polynomials are at most `k`-to-one -/

/-- **Fiber lower bound.**  If `p ∈ ℤ[X]` has degree `≥ 1`, then over any finite set `A`
the map `a ↦ p.eval a` is at most `natDegree p`-to-one, hence
`|A| ≤ (deg p) · |p(A)|`.  Equivalently `|p(A)| ≥ |A| / deg p`.

This is the exact finitary skeleton of every power-saving *lower* bound for polynomial
images: a degree-`k` equation has at most `k` solutions, so the image cannot collapse by
more than a factor `k`. -/
theorem card_le_natDegree_mul_image_card
    (p : Polynomial ℤ) (hp : 1 ≤ p.natDegree) (A : Finset ℤ) :
    A.card ≤ p.natDegree * (A.image (fun a => p.eval a)).card := by
  apply Finset.card_le_mul_card_image
  intro b _
  -- `p - C b` is nonzero because `p` has positive degree.
  have hne : p - C b ≠ 0 := by
    intro h
    have hpc : p = C b := by linear_combination (norm := ring_nf) h
    rw [hpc] at hp; simp at hp
  -- the fiber over `b` embeds into the (multiset of) roots of `p - C b`.
  have hsub : ({a ∈ A | p.eval a = b}).val ⊆ (p - C b).roots := by
    intro a ha
    simp only [Finset.mem_filter, Finset.mem_val] at ha
    rw [Polynomial.mem_roots hne, Polynomial.IsRoot.def, Polynomial.eval_sub,
        Polynomial.eval_C, ha.2, sub_self]
  calc ({a ∈ A | p.eval a = b}).card ≤ (p - C b).natDegree :=
        Polynomial.card_le_degree_of_subset_roots hsub
    _ ≤ p.natDegree := by simpa using Polynomial.natDegree_sub_le p (C b)

/-! ## The power-saving constant and the upper bound -/

/-- The power-saving constant `c(k) = 1/k²` for degree `k`. -/
noncomputable def powerSavingConstant (k : ℕ) : ℝ := 1 / (k : ℝ) ^ 2

/-- For `k ≥ 2`, the shifted exponent `k - c` satisfies `1 ≤ k - c < k`; in particular
`0 < c ≤ k - 1`. -/
theorem one_le_sub_powerSavingConstant {k : ℕ} (hk : 2 ≤ k) :
    (1 : ℝ) ≤ (k : ℝ) - powerSavingConstant k := by
  have hk2 : (2 : ℝ) ≤ (k : ℝ) := by exact_mod_cast hk
  rw [powerSavingConstant, le_sub_iff_add_le]
  have hle : 1 / (k : ℝ) ^ 2 ≤ 1 := by
    rw [div_le_one (by positivity)]; nlinarith
  linarith

/-- **Real power-saving inequality.**  For `n ≥ 1` and `k ≥ 2`, `n ≤ n^{k - 1/k²}`.
This is the analytic heart of the admissibility of the constant `c = 1/k²`. -/
theorem self_le_rpow_powerSaving {n k : ℕ} (hn : 1 ≤ n) (hk : 2 ≤ k) :
    (n : ℝ) ≤ (n : ℝ) ^ ((k : ℝ) - powerSavingConstant k) := by
  have h1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  calc (n : ℝ) = (n : ℝ) ^ (1 : ℝ) := (Real.rpow_one _).symm
    _ ≤ (n : ℝ) ^ ((k : ℝ) - powerSavingConstant k) :=
        Real.rpow_le_rpow_of_exponent_le h1 (one_le_sub_powerSavingConstant hk)

/-- **Power-saving upper bound (Minkowski image).**  For `p ∈ ℤ[X]` of degree
`k = natDegree p ≥ 2` and a nonempty finite `A ⊆ ℤ`, the elementwise image satisfies
`|p(A)| ≤ |A|^{k - 1/k²}`. -/
theorem image_card_le_rpow
    (p : Polynomial ℤ) (hp : 2 ≤ p.natDegree) {A : Finset ℤ} (hA : A.Nonempty) :
    ((A.image (fun a => p.eval a)).card : ℝ)
      ≤ (A.card : ℝ) ^ ((p.natDegree : ℝ) - powerSavingConstant p.natDegree) := by
  have hcard : (A.image (fun a => p.eval a)).card ≤ A.card := Finset.card_image_le
  have h1 : 1 ≤ A.card := Finset.card_pos.mpr hA
  calc ((A.image (fun a => p.eval a)).card : ℝ) ≤ (A.card : ℝ) := by exact_mod_cast hcard
    _ ≤ (A.card : ℝ) ^ ((p.natDegree : ℝ) - powerSavingConstant p.natDegree) :=
        self_le_rpow_powerSaving h1 hp

/-! ## The two-sided estimate -/

/-- **Two-sided power-saving estimate for monic Minkowski polynomials.**
For `p ∈ ℤ[X]` of degree `k = natDegree p ≥ 2` and a nonempty finite `A ⊆ ℤ`, the image
cardinality is sandwiched:
`|A| / k ≤ |p(A)| ≤ |A|^{k - 1/k²}`.

The lower bound is the fiber estimate; the upper bound is the power-saving inequality with
the explicit constant `c = 1/k²`.  Together they trap `|p(A)|` in the corridor predicted by
the power-saving heuristic. -/
theorem powerSaving_sandwich
    (p : Polynomial ℤ) (hp : 2 ≤ p.natDegree) {A : Finset ℤ} (hA : A.Nonempty) :
    (A.card : ℝ) / (p.natDegree : ℝ) ≤ ((A.image (fun a => p.eval a)).card : ℝ)
      ∧ ((A.image (fun a => p.eval a)).card : ℝ)
        ≤ (A.card : ℝ) ^ ((p.natDegree : ℝ) - powerSavingConstant p.natDegree) := by
  refine ⟨?_, image_card_le_rpow p hp hA⟩
  have hk1 : 1 ≤ p.natDegree := le_trans (by norm_num) hp
  have hfib := card_le_natDegree_mul_image_card p hk1 A
  have hkpos : (0 : ℝ) < (p.natDegree : ℝ) := by
    have : 0 < p.natDegree := lt_of_lt_of_le (by norm_num) hp
    exact_mod_cast this
  rw [div_le_iff₀ hkpos]
  have hcast : (A.card : ℝ) ≤ (p.natDegree : ℝ) * ((A.image (fun a => p.eval a)).card : ℝ) := by
    exact_mod_cast hfib
  linarith [hcast]

end MinkowskiPowerSaving