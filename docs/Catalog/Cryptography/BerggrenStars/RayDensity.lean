import Mathlib
import Cryptography.BerggrenStars.HypercycleStars

/-!
# How densely a single ray of the star is populated

`Cryptography.BerggrenStars.HypercycleStars` shows that the nodes with a fixed second Euclid
coordinate `n` all lie on one hypercycle (a Euclidean ray out of the boundary point `0`), and
that the hyperbolic steps along that ray tend to `0`. Here we count how many nodes of the ray
of index `n` lie inside the hyperbolic ball of radius `R` about `i`.

## Main results

* `dist_le_of_cast_le_cosh` : a very convenient membership test — *any* Euclid seed with
  `m ≤ cosh R` lies in the ball of radius `R`.
* `mem_rayNodes_iff` : the nodes of the ray of index `n` inside `B(R)` are exactly the seeds
  `(m, n)` with `m ≤ 2 cosh R` and `d ≤ R`; in particular there are finitely many.
* `card_rayNodes_le` : at most `2 cosh R` of them.
* `card_rayNodes_ge` : at least `(cosh R - (n+1))/(2n)` of them, obtained from the `B₃`-orbit of
  the left-spine seed `(n+1, n)`. So the linear density of nodes along the `n`-th ray decays
  like `1/(2n)`, while the total over all rays stays `Θ(e^{2R})`.
-/

namespace BerggrenHypercycleStars

open Real UpperHalfPlane

/-- **Ball membership test.** Every Euclid seed whose first coordinate is at most `cosh R` gives
a node inside the hyperbolic ball of radius `R` about `i`. -/
theorem dist_le_of_cast_le_cosh {m n : ℕ} (hseed : IsSeed m n) (R : ℝ) (hR : 0 ≤ R)
    (h : (m : ℝ) ≤ Real.cosh R) :
    dist (hpoint m n (lt_trans hseed.pos hseed.lt)) UpperHalfPlane.I ≤ R := by
  have hm : 0 < m := lt_trans hseed.pos hseed.lt
  have hMR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hnm : (n : ℝ) + 1 ≤ (m : ℝ) := by exact_mod_cast hseed.lt
  have hn0 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have hcosh : Real.cosh (dist (hpoint m n hm) UpperHalfPlane.I) ≤ Real.cosh R := by
    rw [cosh_dist_hpoint_I m n hm]
    refine le_trans ?_ h
    rw [div_le_iff₀ (by positivity)]
    nlinarith
  have := Real.cosh_le_cosh.1 hcosh
  rwa [abs_of_nonneg dist_nonneg, abs_of_nonneg hR] at this

/-- Conversely, a node inside `B(R)` has `m ≤ 2 cosh R`. -/
theorem cast_le_two_cosh_of_dist_le {m n : ℕ} (hm : 0 < m) (R : ℝ)
    (h : dist (hpoint m n hm) UpperHalfPlane.I ≤ R) :
    (m : ℝ) ≤ 2 * Real.cosh R := by
  have hMR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hR : 0 ≤ R := le_trans dist_nonneg h
  have hcosh : Real.cosh (dist (hpoint m n hm) UpperHalfPlane.I) ≤ Real.cosh R := by
    refine Real.cosh_le_cosh.2 ?_
    rwa [abs_of_nonneg dist_nonneg, abs_of_nonneg hR]
  rw [cosh_dist_hpoint_I m n hm] at hcosh
  have h1 : (m : ℝ) / 2 ≤ ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1) / (2 * m) := by
    rw [div_le_div_iff₀ (by norm_num) (by positivity)]
    nlinarith [sq_nonneg ((n : ℝ))]
  linarith

open Classical in
/-- The nodes of the ray of index `n` (the `n`-th hypercycle of the `0`-star) inside the
hyperbolic ball of radius `R`, recorded by their first Euclid coordinate. -/
noncomputable def rayNodes (n : ℕ) (R : ℝ) : Finset ℕ :=
  (Finset.Icc 1 ⌊2 * Real.cosh R⌋₊).filter
    (fun m => ∃ hm : 0 < m, IsSeed m n ∧ dist (hpoint m n hm) UpperHalfPlane.I ≤ R)

theorem mem_rayNodes_iff (n : ℕ) (R : ℝ) (m : ℕ) :
    m ∈ rayNodes n R ↔
      ∃ hm : 0 < m, IsSeed m n ∧ dist (hpoint m n hm) UpperHalfPlane.I ≤ R := by
  classical
  rw [rayNodes, Finset.mem_filter, Finset.mem_Icc]
  constructor
  · rintro ⟨-, h⟩; exact h
  · rintro ⟨hm, hseed, hd⟩
    refine ⟨⟨hm, ?_⟩, hm, hseed, hd⟩
    exact Nat.le_floor (cast_le_two_cosh_of_dist_le hm R hd)

/-- **Upper bound on the population of one ray.** -/
theorem card_rayNodes_le (n : ℕ) (R : ℝ) :
    ((rayNodes n R).card : ℝ) ≤ 2 * Real.cosh R := by
  classical
  have h1 : (rayNodes n R).card ≤ (Finset.Icc 1 ⌊2 * Real.cosh R⌋₊).card :=
    Finset.card_le_card (Finset.filter_subset _ _)
  have h2 : (Finset.Icc 1 ⌊2 * Real.cosh R⌋₊).card = ⌊2 * Real.cosh R⌋₊ := by simp
  have h3 : ((⌊2 * Real.cosh R⌋₊ : ℕ) : ℝ) ≤ 2 * Real.cosh R :=
    Nat.floor_le (by nlinarith [Real.one_le_cosh R])
  have h4 : ((rayNodes n R).card : ℝ) ≤ ((⌊2 * Real.cosh R⌋₊ : ℕ) : ℝ) := by
    exact_mod_cast h2 ▸ h1
  linarith

/-- The `B₃`-orbit of the left-spine seed `(n+1, n)` consists of Euclid seeds on the ray `n`. -/
theorem isSeed_ray_orbit (n k : ℕ) (hn : 0 < n) : IsSeed (n + 1 + 2 * k * n) n := by
  refine ⟨hn, by omega, ?_, ?_⟩
  · have h : n + 1 + 2 * k * n = (n + 1) + (2 * k) * n := by ring
    rw [h, Nat.coprime_add_mul_right_left]
    simp [Nat.Coprime]
  · have h : n + 1 + 2 * k * n + n = 2 * (n + k * n) + 1 := by ring
    omega

/-- **Lower bound on the population of one ray.** The ray of index `n` carries at least
`(cosh R - (n+1)) / (2n)` nodes inside the ball of radius `R`: the linear density along the
`n`-th ray decays like `1/(2n)`. -/
theorem card_rayNodes_ge (n : ℕ) (hn : 0 < n) (R : ℝ) (hR : 0 ≤ R)
    (hcosh : (n : ℝ) + 1 ≤ Real.cosh R) :
    (Real.cosh R - ((n : ℝ) + 1)) / (2 * n) ≤ (rayNodes n R).card := by
  classical
  have hnR : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  set x : ℝ := (Real.cosh R - ((n : ℝ) + 1)) / (2 * n) with hx
  have hx0 : 0 ≤ x := by
    rw [hx]
    apply div_nonneg (by linarith) (by positivity)
  set K : ℕ := ⌊x⌋₊ + 1 with hK
  -- every `k < K` gives a node of the ray inside the ball
  have hmem : ∀ k ∈ Finset.range K, (n + 1 + 2 * k * n) ∈ rayNodes n R := by
    intro k hk
    rw [Finset.mem_range, hK] at hk
    have hkx : (k : ℝ) ≤ x := le_trans (by exact_mod_cast Nat.lt_succ_iff.1 hk) (Nat.floor_le hx0)
    have hle : ((n + 1 + 2 * k * n : ℕ) : ℝ) ≤ Real.cosh R := by
      have hkey : ((n : ℝ) + 1) + 2 * (k : ℝ) * n ≤ Real.cosh R := by
        rw [hx, le_div_iff₀ (by positivity)] at hkx
        linarith
      push_cast
      linarith
    have hseed : IsSeed (n + 1 + 2 * k * n) n := isSeed_ray_orbit n k hn
    rw [mem_rayNodes_iff]
    exact ⟨lt_trans hseed.pos hseed.lt, hseed, dist_le_of_cast_le_cosh hseed R hR hle⟩
  have hinj : Set.InjOn (fun k => n + 1 + 2 * k * n) (Finset.range K) := by
    intro a _ b _ hab
    simp only at hab
    have h1 : 2 * a * n = 2 * b * n := Nat.add_left_cancel hab
    have h2 : 2 * a = 2 * b := Nat.eq_of_mul_eq_mul_right hn h1
    omega
  have hcard : K ≤ (rayNodes n R).card := by
    have := Finset.card_le_card_of_injOn (s := Finset.range K) (t := rayNodes n R)
      (fun k => n + 1 + 2 * k * n) (fun k hk => hmem k (by simpa using hk)) hinj
    simpa using this
  have hKR : x < (K : ℝ) := by
    rw [hK]
    push_cast
    linarith [Nat.lt_floor_add_one x]
  have : ((K : ℕ) : ℝ) ≤ (rayNodes n R).card := by exact_mod_cast hcard
  linarith

end BerggrenHypercycleStars