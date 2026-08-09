import Mathlib
import Cryptography.BerggrenStars.HypercycleStars

/-!
# Star coordinates: the Berggren tree seen from the two boundary stars

`Cryptography.BerggrenStars.HypercycleStars` shows that a Berggren node `z(m,n) = (n+i)/m`
sits at distance `arsinh n` from the geodesic over the boundary point `0` and at distance
`arsinh (m-n)` from the geodesic over the boundary point `1`. So the pair

  `(u, v) = (n, m - n)`

is exactly the pair of *star indices* of the node — one index per radiating star. This file
develops the tree entirely in these coordinates, and the result is markedly cleaner than in
Euclid coordinates.

## Main results

* `starPoint_charges` : `(u, v)` really is the pair of hyperbolic star charges,
  `sinh d₀ = u` and `sinh d₁ = v`.
* `node_eq_of_charges` : **the two star charges determine the node**; the star picture is a
  faithful coordinate system on the tree.
* `isSeed_iff_isStarPair` : the Euclid-seed conditions `0 < n < m`, `gcd(m,n) = 1`, `m + n` odd
  become the conditions `0 < u`, `0 < v`, `gcd(u,v) = 1`, `v` odd.
* `isStarPair_starL/M/R` : the three Berggren moves act as
  `(u,v) ↦ (u+v, v)`, `(u,v) ↦ (u+v, 2u+v)`, `(u,v) ↦ (u, 2u+v)` and preserve star pairs.
* `exists_depth_of_isStarPair` : **completeness** — every star pair is reached from the root
  `(1,1)`, by a descent whose trichotomy is `u > v`, `u < v < 2u`, `v > 2u`.
* `starReaches_unique_depth` : **it is a tree** — the depth at which a star pair is reached is
  unique, so the depth function is well defined.
* `cosh_dist_starPoint` : the radial coordinate in star coordinates,
  `cosh d = ((u+v)² + u² + 1)/(2(u+v))`.
-/

namespace BerggrenHypercycleStars

open Real UpperHalfPlane

/-! ## Part 1. Star coordinates and their charges -/

/-- The half-plane node attached to the star-coordinate pair `(u, v)`: it is the Euclid seed
`(m, n) = (u + v, u)`. -/
noncomputable def starPoint (u v : ℕ) (h : 0 < u + v) : ℍ := hpoint (u + v) u h

/-- **The star charges.** The two coordinates are precisely the hyperbolic sines of the
distances to the two boundary geodesics, at `0` and at `1`. -/
theorem starPoint_charges (u v : ℕ) (h : 0 < u + v) :
    Real.sinh (distVLine (starPoint u v h) 0) = u ∧
      Real.sinh (distVLine (starPoint u v h) 1) = v := by
  constructor
  · rw [starPoint, spoke_dist, Real.sinh_arsinh]
  · rw [starPoint, costar_dist _ _ _ (by omega), Real.sinh_arsinh]
    push_cast
    ring

/-- **The star coordinates are faithful.** A Berggren node is determined by its pair of
distances to the two boundary geodesics: the star picture loses no information. -/
theorem node_eq_of_charges {m n m' n' : ℕ} (hm : 0 < m) (hm' : 0 < m')
    (hnm : n ≤ m) (hnm' : n' ≤ m')
    (h0 : distVLine (hpoint m n hm) 0 = distVLine (hpoint m' n' hm') 0)
    (h1 : distVLine (hpoint m n hm) 1 = distVLine (hpoint m' n' hm') 1) :
    m = m' ∧ n = n' := by
  rw [spoke_dist, spoke_dist] at h0
  rw [costar_dist _ _ _ hnm, costar_dist _ _ _ hnm'] at h1
  have hn : (n : ℝ) = n' := Real.arsinh_injective h0
  have hmn : (m : ℝ) - n = (m' : ℝ) - n' := Real.arsinh_injective h1
  have hn' : n = n' := by exact_mod_cast hn
  have : (m : ℝ) = m' := by rw [hn] at hmn; linarith
  exact ⟨by exact_mod_cast this, hn'⟩

/-- A **star pair**: the star-coordinate description of a Euclid seed. -/
structure IsStarPair (u v : ℕ) : Prop where
  posu : 0 < u
  posv : 0 < v
  cop : Nat.Coprime u v
  odd : v % 2 = 1

/-- Descent tool: if `u` and `v` are non-negative integer combinations of `a` and `b`, then
coprimality of `u, v` forces coprimality of `a, b`. -/
theorem coprime_of_comb (a b u v c₁ c₂ d₁ d₂ : ℕ) (hu : u = c₁ * a + c₂ * b)
    (hv : v = d₁ * a + d₂ * b) (h : Nat.Coprime u v) : Nat.Coprime a b := by
  have h1 : Nat.gcd a b ∣ u := by
    rw [hu]
    exact Nat.dvd_add ((Nat.gcd_dvd_left a b).mul_left c₁) ((Nat.gcd_dvd_right a b).mul_left c₂)
  have h2 : Nat.gcd a b ∣ v := by
    rw [hv]
    exact Nat.dvd_add ((Nat.gcd_dvd_left a b).mul_left d₁) ((Nat.gcd_dvd_right a b).mul_left d₂)
  have hdvd : Nat.gcd a b ∣ Nat.gcd u v := Nat.dvd_gcd h1 h2
  rw [h] at hdvd
  exact Nat.dvd_one.mp hdvd

/-- **Star coordinates linearize the seed conditions.** The three Euclid-seed constraints
`0 < n < m`, `gcd(m,n) = 1`, `m + n` odd are equivalent, after the substitution
`(m, n) = (u + v, u)`, to: `u, v > 0`, `gcd(u,v) = 1`, and `v` odd. -/
theorem isSeed_iff_isStarPair (u v : ℕ) : IsSeed (u + v) u ↔ IsStarPair u v := by
  constructor
  · rintro ⟨hpos, hlt, hcop, hpar⟩
    refine ⟨hpos, by omega, ?_, by omega⟩
    exact coprime_of_comb u v (u + v) u 1 1 1 0 (by omega) (by omega) hcop
  · rintro ⟨hu, hv, hcop, hodd⟩
    refine ⟨hu, by omega, ?_, by omega⟩
    rw [Nat.add_comm]
    exact Nat.coprime_add_self_left.mpr (Nat.coprime_comm.mp hcop)

/-- Every Euclid seed is a star pair, in the coordinates `(u, v) = (n, m - n)`. -/
theorem isStarPair_of_isSeed {m n : ℕ} (h : IsSeed m n) : IsStarPair n (m - n) := by
  have hlt := h.lt
  have hs : IsSeed (n + (m - n)) n := by
    have hmm : n + (m - n) = m := by omega
    rwa [hmm]
  exact (isSeed_iff_isStarPair n (m - n)).1 hs

/-! ## Part 2. The three Berggren moves in star coordinates -/

/-- `B₁` in star coordinates. -/
def starL (p : ℕ × ℕ) : ℕ × ℕ := (p.1 + p.2, p.2)

/-- `B₂` in star coordinates. -/
def starM (p : ℕ × ℕ) : ℕ × ℕ := (p.1 + p.2, 2 * p.1 + p.2)

/-- `B₃` in star coordinates. -/
def starR (p : ℕ × ℕ) : ℕ × ℕ := (p.1, 2 * p.1 + p.2)

theorem isStarPair_starL {u v : ℕ} (h : IsStarPair u v) : IsStarPair (u + v) v := by
  obtain ⟨hu, hv, hcop, hodd⟩ := h
  exact ⟨by omega, hv, Nat.coprime_add_self_left.mpr hcop, hodd⟩

theorem isStarPair_starM {u v : ℕ} (h : IsStarPair u v) : IsStarPair (u + v) (2 * u + v) := by
  obtain ⟨hu, hv, hcop, hodd⟩ := h
  refine ⟨by omega, by omega, ?_, by omega⟩
  have h2 : Nat.Coprime (u + v) u := by
    rw [Nat.add_comm]
    exact Nat.coprime_add_self_left.mpr (Nat.coprime_comm.mp hcop)
  have h3 : 2 * u + v = (u + v) + u := by ring
  rw [h3]
  exact Nat.coprime_self_add_right.mpr h2

theorem isStarPair_starR {u v : ℕ} (h : IsStarPair u v) : IsStarPair u (2 * u + v) := by
  obtain ⟨hu, hv, hcop, hodd⟩ := h
  exact ⟨hu, by omega, (Nat.coprime_mul_right_add_right u v 2).mpr hcop, by omega⟩

/-! ## Part 3. Reachability: completeness and uniqueness of depth -/

/-- `StarReaches p k` : the star pair `p` is obtained from the root `(1,1)` (the seed `(2,1)`,
i.e. the triple `(3,4,5)`) by exactly `k` Berggren moves. -/
inductive StarReaches : ℕ × ℕ → ℕ → Prop
  | root : StarReaches (1, 1) 0
  | l {p k} : StarReaches p k → StarReaches (starL p) (k + 1)
  | m {p k} : StarReaches p k → StarReaches (starM p) (k + 1)
  | r {p k} : StarReaches p k → StarReaches (starR p) (k + 1)

/-- **Soundness.** Everything reachable is a star pair. -/
theorem isStarPair_of_starReaches {p : ℕ × ℕ} {k : ℕ} (h : StarReaches p k) :
    IsStarPair p.1 p.2 := by
  induction h with
  | root => exact ⟨one_pos, one_pos, Nat.coprime_one_left 1, rfl⟩
  | l _ ih => exact isStarPair_starL ih
  | m _ ih => exact isStarPair_starM ih
  | r _ ih => exact isStarPair_starR ih

/-- **Completeness.** Every star pair — equivalently, every primitive Pythagorean triple — is
reached from the root. The descent is governed by the trichotomy `u > v`, `u < v < 2u`,
`v > 2u`; the excluded boundaries `u = v` and `v = 2u` are settled arithmetically, by
coprimality and by the oddness of `v` respectively. -/
theorem starReaches_of_isStarPair : ∀ s u v : ℕ, u + v ≤ s → IsStarPair u v →
    ∃ k, StarReaches (u, v) k := by
  intro s
  induction s with
  | zero => intro u v hs h; exact absurd hs (by have := h.posu; omega)
  | succ s ih =>
    intro u v hs h
    obtain ⟨hu, hv, hcop, hodd⟩ := h
    rcases lt_trichotomy u v with hlt | heq | hgt
    · rcases lt_trichotomy v (2 * u) with h2 | h2 | h2
      · -- parent via `starM` : `(v - u, 2u - v)`
        have hp : IsStarPair (v - u) (2 * u - v) :=
          ⟨by omega, by omega,
            coprime_of_comb _ _ u v 1 1 2 1 (by omega) (by omega) hcop, by omega⟩
        obtain ⟨k, hk⟩ := ih (v - u) (2 * u - v) (by omega) hp
        refine ⟨k + 1, ?_⟩
        have he : starM (v - u, 2 * u - v) = (u, v) := by
          simp only [starM, Prod.mk.injEq]
          omega
        rw [← he]
        exact StarReaches.m hk
      · exact absurd hodd (by omega)
      · -- parent via `starR` : `(u, v - 2u)`
        have hp : IsStarPair u (v - 2 * u) :=
          ⟨hu, by omega, coprime_of_comb _ _ u v 1 0 2 1 (by omega) (by omega) hcop, by omega⟩
        obtain ⟨k, hk⟩ := ih u (v - 2 * u) (by omega) hp
        refine ⟨k + 1, ?_⟩
        have he : starR (u, v - 2 * u) = (u, v) := by
          simp only [starR, Prod.mk.injEq, true_and]
          omega
        rw [← he]
        exact StarReaches.r hk
    · -- `u = v` forces `u = v = 1` by coprimality: the root
      have hu1 : u = 1 := by
        have hg : Nat.gcd u v = 1 := hcop
        rw [← heq, Nat.gcd_self] at hg
        omega
      have he : (u, v) = (1, 1) := by
        simp only [Prod.mk.injEq]
        exact ⟨hu1, by omega⟩
      exact ⟨0, he ▸ StarReaches.root⟩
    · -- parent via `starL` : `(u - v, v)`
      have hp : IsStarPair (u - v) v :=
        ⟨by omega, hv, coprime_of_comb _ _ u v 1 1 0 1 (by omega) (by omega) hcop, hodd⟩
      obtain ⟨k, hk⟩ := ih (u - v) v (by omega) hp
      refine ⟨k + 1, ?_⟩
      have he : starL (u - v, v) = (u, v) := by
        simp only [starL, Prod.mk.injEq, and_true]
        omega
      rw [← he]
      exact StarReaches.l hk

/-- Every star pair is reached from the root at some depth. -/
theorem exists_depth_of_isStarPair {u v : ℕ} (h : IsStarPair u v) :
    ∃ k, StarReaches (u, v) k :=
  starReaches_of_isStarPair (u + v) u v le_rfl h

/-- Every primitive Pythagorean triple, in Euclid coordinates, is a Berggren node. -/
theorem exists_depth_of_isSeed {m n : ℕ} (h : IsSeed m n) :
    ∃ k, StarReaches (n, m - n) k :=
  exists_depth_of_isStarPair (isStarPair_of_isSeed h)

theorem starReaches_zero {p : ℕ × ℕ} (h : StarReaches p 0) : p = (1, 1) := by
  cases h with
  | root => rfl

/-- Inversion: a node at depth `k+1` is the image of a node at depth `k` under one of the three
moves. -/
theorem starReaches_succ {p : ℕ × ℕ} {k : ℕ} (h : StarReaches p (k + 1)) :
    ∃ q, StarReaches q k ∧ (p = starL q ∨ p = starM q ∨ p = starR q) := by
  cases h with
  | l hq => exact ⟨_, hq, Or.inl rfl⟩
  | m hq => exact ⟨_, hq, Or.inr (Or.inl rfl)⟩
  | r hq => exact ⟨_, hq, Or.inr (Or.inr rfl)⟩

/-- **The Berggren tree really is a tree, in star coordinates.** A star pair is reached at
exactly one depth, so the depth function is well defined on primitive Pythagorean triples.
The proof is the disjointness of the three move-images, which is precisely the trichotomy
`u > v` / `u < v < 2u` / `v > 2u` of the descent. -/
theorem starReaches_unique_depth : ∀ s : ℕ, ∀ p : ℕ × ℕ, p.1 + p.2 ≤ s → ∀ j k : ℕ,
    StarReaches p j → StarReaches p k → j = k := by
  intro s
  induction s with
  | zero =>
    intro p hp j k hj _
    exact absurd hp (by have := (isStarPair_of_starReaches hj).posu; omega)
  | succ s ih =>
    intro p hp j k hj hk
    match j, k with
    | 0, 0 => rfl
    | 0, (k + 1) =>
      exfalso
      have hp1 : p = (1, 1) := starReaches_zero hj
      obtain ⟨q, hq, hcase⟩ := starReaches_succ hk
      have hqs := isStarPair_of_starReaches hq
      have h1 := hqs.posu
      have h2 := hqs.posv
      rcases hcase with hc | hc | hc <;>
        · rw [hp1] at hc
          simp only [starL, starM, starR, Prod.mk.injEq] at hc
          omega
    | (j + 1), 0 =>
      exfalso
      have hp1 : p = (1, 1) := starReaches_zero hk
      obtain ⟨q, hq, hcase⟩ := starReaches_succ hj
      have hqs := isStarPair_of_starReaches hq
      have h1 := hqs.posu
      have h2 := hqs.posv
      rcases hcase with hc | hc | hc <;>
        · rw [hp1] at hc
          simp only [starL, starM, starR, Prod.mk.injEq] at hc
          omega
    | (j + 1), (k + 1) =>
      obtain ⟨q, hq, hcq⟩ := starReaches_succ hj
      obtain ⟨q', hq', hcq'⟩ := starReaches_succ hk
      have hqs := isStarPair_of_starReaches hq
      have hqs' := isStarPair_of_starReaches hq'
      have h1 := hqs.posu
      have h2 := hqs.posv
      have h3 := hqs'.posu
      have h4 := hqs'.posv
      have h5 := hqs.odd
      have h6 := hqs'.odd
      have hqq : q = q' := by
        rcases hcq with hc | hc | hc <;> rcases hcq' with hc' | hc' | hc' <;>
          · rw [hc'] at hc
            simp only [starL, starM, starR, Prod.mk.injEq] at hc
            rw [Prod.ext_iff]
            omega
      subst hqq
      have hsum : q.1 + q.2 ≤ s := by
        rcases hcq with hc | hc | hc <;>
          · rw [hc] at hp
            simp only [starL, starM, starR] at hp
            omega
      have := ih q hsum j k hq hq'
      omega

/-! ## Part 4. The radial coordinate in star coordinates -/

/-- The radial coordinate of a node in star coordinates:
`cosh d = ((u+v)² + u² + 1)/(2(u+v))`. The hypotenuse of the associated Pythagorean triple is
`u² + (u+v)²`, so the pair of star charges determines the whole geometry. -/
theorem cosh_dist_starPoint (u v : ℕ) (h : 0 < u + v) :
    Real.cosh (dist (starPoint u v h) UpperHalfPlane.I)
      = (((u : ℝ) + v) ^ 2 + (u : ℝ) ^ 2 + 1) / (2 * ((u : ℝ) + v)) := by
  rw [starPoint, cosh_dist_hpoint_I]
  push_cast
  ring_nf

/-- Each move strictly increases `u + v`; this is why the descent in
`starReaches_of_isStarPair` terminates. -/
theorem star_sum_lt_of_moves {u v : ℕ} (h : IsStarPair u v) :
    u + v < (starL (u, v)).1 + (starL (u, v)).2 ∧
      u + v < (starM (u, v)).1 + (starM (u, v)).2 ∧
      u + v < (starR (u, v)).1 + (starR (u, v)).2 := by
  have h1 := h.posu
  have h2 := h.posv
  refine ⟨?_, ?_, ?_⟩ <;> simp only [starL, starM, starR] <;> omega

end BerggrenHypercycleStars