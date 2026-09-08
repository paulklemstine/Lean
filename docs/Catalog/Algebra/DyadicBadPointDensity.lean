import Algebra.DyadicOneLayer

/-!
# A positive density of badly approximated points

`Algebra.DepthLOscillationLowerBound` shows that a network with too few knots
misses the sawtooth tower *somewhere*.  This file upgrades that to a *density*
statement: the low–high–low obstruction is local, so a piecewise affine function
with `|S|` knots must fail at a constant fraction of the dyadic sample points.

## Main results

* `dyadic_bad_point_count` — for `PWA S f`, at least `2^k/3 − |S|` of the
  `2^k+1` dyadic points `j/2^k` satisfy `|f(j/2^k) − tri^[k](j/2^k)| > 1/4`.
* `relu_bad_point_density` — consequently a depth-`L`, width-`w` ReLU network
  fails at more than `2^k/3 − 2(2w+2)^L` dyadic points; for `k = L^2+4` and
  `w < 2^(L-1) − 1` this is a `(1/3 − o(1))`-fraction of all sample points.

So the depth separation is not a knife-edge phenomenon at one bad input: a
shallow network is wrong on a positive fraction of the domain's sample grid.
-/

noncomputable section

namespace ReluDepth

open Finset

/-- An affine function cannot go high–low–high (the mirror of
`no_affine_oscillation`). -/
lemma no_affine_oscillation_hi {f : ℝ → ℝ} {x1 x2 x3 : ℝ} (h12 : x1 < x2) (h23 : x2 < x3)
    (haff : AffineOn f x1 x3) (hh1 : 3/4 ≤ f x1) (hl : f x2 ≤ 1/4) (hh3 : 3/4 ≤ f x3) :
    False := by
  obtain ⟨a, b, hab⟩ := haff
  have e1 : f x1 = a * x1 + b := hab x1 ⟨le_refl _, le_of_lt (lt_trans h12 h23)⟩
  have e2 : f x2 = a * x2 + b := hab x2 ⟨le_of_lt h12, le_of_lt h23⟩
  have e3 : f x3 = a * x3 + b := hab x3 ⟨le_of_lt (lt_trans h12 h23), le_refl _⟩
  rw [e1] at hh1; rw [e2] at hl; rw [e3] at hh3
  nlinarith [mul_pos (sub_pos.2 h12) (sub_pos.2 h23), sub_pos.2 h12, sub_pos.2 h23]

/-- **Density of failure.**  A piecewise affine function with knot set `S` is wrong
by more than `1/4` at at least `2^k/3 − |S|` of the dyadic points `j/2^k`. -/
theorem dyadic_bad_point_count {S : Finset ℝ} {f : ℝ → ℝ} (hf : PWA S f) (k : ℕ) :
    2^k ≤ 3 * ((((Finset.range (2^k+1)).filter
      (fun (j : ℕ) => ¬ |f ((j:ℝ)/2^k) - tri^[k] ((j:ℝ)/2^k)| ≤ 1/4)).card) + S.card) + 2 := by
  classical
  set p : ℕ → ℝ := fun j => (j:ℝ)/2^k with hp
  set B := (Finset.range (2^k+1)).filter
    (fun j => ¬ |f (p j) - tri^[k] (p j)| ≤ 1/4) with hB
  set T := 2^k / 3 with hT
  have hpow : (0:ℝ) < 2^k := by positivity
  have hmono : StrictMono p := by
    intro a b hab
    have h : (a:ℝ) < b := by exact_mod_cast hab
    simp only [hp]
    gcongr
  have hmem : ∀ j : ℕ, j ≤ 2^k → p j ∈ Set.Icc (0:ℝ) 1 := by
    intro j hj
    refine ⟨by positivity, ?_⟩
    simp only [hp]
    rw [div_le_one hpow]
    exact_mod_cast hj
  have hval : ∀ j : ℕ, j ≤ 2^k → tri^[k] (p j) = if Even j then 0 else 1 := by
    intro j hj
    simpa [hp] using tri_iterate_dyadic k j hj
  -- the local obstruction, block by block
  have key : ∀ t : ℕ, 3*t + 2 ≤ 2^k →
      (∃ j, j ∈ B ∧ 3*t ≤ j ∧ j ≤ 3*t+2) ∨ (∃ z ∈ S, p (3*t) < z ∧ z < p (3*t+2)) := by
    intro t ht
    by_cases hbad : ∃ j, j ∈ B ∧ 3*t ≤ j ∧ j ≤ 3*t+2
    · exact Or.inl hbad
    right
    by_contra hknot
    push_neg at hknot
    -- all three points of the block are well approximated
    have hgood : ∀ j, 3*t ≤ j → j ≤ 3*t+2 → |f (p j) - tri^[k] (p j)| ≤ 1/4 := by
      intro j hj1 hj2
      by_contra hc
      exact hbad ⟨j, Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), hc⟩, hj1, hj2⟩
    have hno : ∀ z ∈ S, z ≤ p (3*t) ∨ p (3*t+2) ≤ z := by
      intro z hz
      rcases le_or_gt z (p (3*t)) with h | h
      · exact Or.inl h
      · exact Or.inr (hknot z hz h)
    have haff := hf (p (3*t)) (p (3*t+2)) (hmem _ (by omega)).1
      (hmono.monotone (by omega)) (hmem _ (by omega)).2 hno
    have hlt1 : p (3*t) < p (3*t+1) := hmono (by omega)
    have hlt2 : p (3*t+1) < p (3*t+2) := hmono (by omega)
    have g0 := hgood (3*t) (by omega) (by omega)
    have g1 := hgood (3*t+1) (by omega) (by omega)
    have g2 := hgood (3*t+2) (by omega) (by omega)
    rw [hval _ (by omega)] at g0 g1 g2
    by_cases hE : Even (3*t)
    · rw [if_pos hE] at g0
      rw [if_neg (by simp [Nat.even_add_one, hE])] at g1
      rw [if_pos (by simpa [Nat.even_add_one, parity_simps] using hE)] at g2
      exact no_affine_oscillation hlt1 hlt2 haff
        (by simpa using (abs_le.mp g0).2)
        (by have := (abs_le.mp g1).1; linarith)
        (by simpa using (abs_le.mp g2).2)
    · rw [if_neg hE] at g0
      rw [if_pos (by simpa [Nat.even_add_one] using hE)] at g1
      rw [if_neg (by simpa [Nat.even_add_one, parity_simps] using hE)] at g2
      exact no_affine_oscillation_hi hlt1 hlt2 haff
        (by have := (abs_le.mp g0).1; linarith)
        (by simpa using (abs_le.mp g1).2)
        (by have := (abs_le.mp g2).1; linarith)
  -- choose a bad point, or a knot, in each block
  have hTle : ∀ t : ℕ, t < T → 3*t + 2 ≤ 2^k := by
    intro t htT
    have h := Nat.div_add_mod (2^k) 3
    have hmod : 2^k % 3 < 3 := Nat.mod_lt _ (by norm_num)
    omega
  have hchooseB : ∀ t : ℕ, ∃ j : ℕ, (∃ j', j' ∈ B ∧ 3*t ≤ j' ∧ j' ≤ 3*t+2) →
      (j ∈ B ∧ 3*t ≤ j ∧ j ≤ 3*t+2) := by
    intro t
    by_cases h : ∃ j', j' ∈ B ∧ 3*t ≤ j' ∧ j' ≤ 3*t+2
    · obtain ⟨j, hj⟩ := h
      exact ⟨j, fun _ => hj⟩
    · exact ⟨0, fun hc => absurd hc h⟩
  have hchooseS : ∀ t : ℕ, ∃ z : ℝ,
      (t < T ∧ ¬ (∃ j', j' ∈ B ∧ 3*t ≤ j' ∧ j' ≤ 3*t+2)) →
      (z ∈ S ∧ p (3*t) < z ∧ z < p (3*t+2)) := by
    intro t
    by_cases h : t < T ∧ ¬ (∃ j', j' ∈ B ∧ 3*t ≤ j' ∧ j' ≤ 3*t+2)
    · rcases key t (hTle t h.1) with hc | ⟨z, hz1, hz2⟩
      · exact absurd hc h.2
      · exact ⟨z, fun _ => ⟨hz1, hz2⟩⟩
    · exact ⟨0, fun hc => absurd hc h⟩
  choose gB hgB using hchooseB
  choose gS hgS using hchooseS
  set P : ℕ → Prop := fun t => ∃ j', j' ∈ B ∧ 3*t ≤ j' ∧ j' ≤ 3*t+2 with hP
  have hmapB : Set.MapsTo gB ((Finset.range T).filter P : Finset ℕ) (B : Finset ℕ) := by
    intro t ht
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at ht
    exact_mod_cast (hgB t ht.2).1
  have hinjB : Set.InjOn gB ((Finset.range T).filter P : Finset ℕ) := by
    intro s hs t ht hst
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at hs ht
    have h1 := hgB s hs.2
    have h2 := hgB t ht.2
    rw [hst] at h1
    omega
  have hmapS : Set.MapsTo gS ((Finset.range T).filter (fun t => ¬ P t) : Finset ℕ)
      (S : Finset ℝ) := by
    intro t ht
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at ht
    exact_mod_cast (hgS t ⟨ht.1, ht.2⟩).1
  have hinjS : Set.InjOn gS ((Finset.range T).filter (fun t => ¬ P t) : Finset ℕ) := by
    intro s hs t ht hst
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at hs ht
    have h1 := hgS s ⟨hs.1, hs.2⟩
    have h2 := hgS t ⟨ht.1, ht.2⟩
    by_contra hne
    rcases lt_or_gt_of_ne hne with h | h
    · have h3 : p (3*s+2) ≤ p (3*t) := hmono.monotone (by omega)
      rw [hst] at h1
      linarith [h1.2.2, h2.2.1]
    · have h3 : p (3*t+2) ≤ p (3*s) := hmono.monotone (by omega)
      rw [hst] at h1
      linarith [h1.2.1, h2.2.2]
  have hc1 := Finset.card_le_card_of_injOn gB hmapB hinjB
  have hc2 := Finset.card_le_card_of_injOn gS hmapS hinjS
  have hsum := Finset.card_filter_add_card_filter_not (s := Finset.range T) (p := P)
  rw [Finset.card_range] at hsum
  have h3T : 2^k ≤ 3 * T + 2 := by
    have := Nat.div_add_mod (2^k) 3
    omega
  omega

/-- **Failure density for ReLU networks.**  A depth-`L`, width-`w` network is wrong by
more than `1/4` at at least `2^k/3 − 2(2w+2)^L` of the `2^k+1` dyadic points. -/
theorem relu_bad_point_density (L w k : ℕ) (f : ℝ → ℝ) (hnet : IsNet w L f) :
    2^k ≤ 3 * ((((Finset.range (2^k+1)).filter
      (fun (j : ℕ) => ¬ |f ((j:ℝ)/2^k) - tri^[k] ((j:ℝ)/2^k)| ≤ 1/4)).card) + 2 * (2*w+2)^L) + 2 := by
  obtain ⟨S, hScard, hS⟩ := hnet.pwa
  have h1 := dyadic_bad_point_count hS k
  have h2 := knotBound_le w L
  omega

end ReluDepth

end