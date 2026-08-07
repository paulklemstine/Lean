import Computation.BerggrenPellClassification

/-!
# Census of the exact straight lines of the Berggren picture

Third research cycle.  Cycle 1 built the metric/arithmetic dictionary, cycle 2 classified the
integral points of each Pell-like conic.  What is still missing is a *census*: for which `k` does
the `k`-th exact geodesic through the centre actually carry infinitely many **Euclid seeds**
(the points that are drawn)?  `pellSeeds_infinite` settled the even case; the odd case fails at
every third orbit point, and this file proves the exact periodic pattern.

## Main results

* `radial_eq_iff_onConic` — the level sets of the radial invariant `ϱ` are exactly the conics:
  `ϱ(m,n) = k ↔ m² - k m n - n² = 1`.  So the exact lines through the centre are indexed by the
  value of `ϱ`, and integrality of `ϱ` is what makes a line arithmetically visible.
* `pellOrbit_parity_odd` — for odd `k` the parity vector of the orbit is periodic with period
  three: `(odd, even) → (even, odd) → (odd, odd) → (odd, even)`.
* `pellOrbit_isSeed_odd` — hence for odd `k` exactly the orbit points with index `≢ 2 mod 3`
  are Euclid seeds.
* `seeds_on_geodesic_infinite` — **census theorem**: for *every* `k ≥ 1` the `k`-th geodesic
  through the centre carries infinitely many Euclid seeds.  Combined with
  `dist_pellOrbit` this exhibits, for each `k`, an infinite family of drawn nodes that is an
  isometric copy of an arithmetic progression of step `2 log λ_k`.

## Lab notes

Seed pattern along the orbit, computed for `k = 1,…,5` (T = seed, F = not):
`k = 1 : T F T T F T`, `k = 2 : T T T T T T`, `k = 3 : T F T T F T`, `k = 4 : T T T T T T`,
`k = 5 : T F T T F T` — period three for odd `k`, constant for even `k`, exactly as proved below.
-/

noncomputable section

open UpperHalfPlane Real

namespace BerggrenHyperbolic

/-- The level sets of the radial invariant are exactly the Pell-like conics. -/
theorem radial_eq_iff_onConic (k m n : ℝ) (hm : 0 < m) (hn : 0 < n) :
    radial m n = k ↔ m ^ 2 - k * m * n - n ^ 2 = 1 := by
  rw [radial, div_eq_iff (by positivity)]
  constructor <;> intro h <;> nlinarith [h]

/-- For odd `k` the parity vector of the Pell orbit is periodic of period three, starting from
`(odd, even)` at indices divisible by three. -/
theorem pellOrbit_parity_odd {k : ℤ} (hk : Odd k) (j : ℕ) :
    (∃ a b : ℤ, (pellOrbit k (3 * j)).1 = 2 * a + 1 ∧ (pellOrbit k (3 * j)).2 = 2 * b) := by
  obtain ⟨s, hs⟩ := hk
  induction j with
  | zero => exact ⟨0, 0, by simp [pellOrbit], by simp [pellOrbit]⟩
  | succ j ih =>
      obtain ⟨a, b, ha, hb⟩ := ih
      have h1 : (pellOrbit k (3 * j + 1)).1 = (k ^ 2 + 1) * (2 * a + 1) + k * (2 * b) := by
        simp only [pellOrbit, pellStep, ha, hb]
      have h2 : (pellOrbit k (3 * j + 1)).2 = k * (2 * a + 1) + 2 * b := by
        simp only [pellOrbit, pellStep, ha, hb]
      have h3 : (pellOrbit k (3 * j + 2)).1
          = (k ^ 2 + 1) * ((pellOrbit k (3 * j + 1)).1) + k * ((pellOrbit k (3 * j + 1)).2) := by
        simp only [pellOrbit, pellStep]
      have h4 : (pellOrbit k (3 * j + 2)).2
          = k * ((pellOrbit k (3 * j + 1)).1) + ((pellOrbit k (3 * j + 1)).2) := by
        simp only [pellOrbit, pellStep]
      have h5 : (pellOrbit k (3 * (j + 1))).1
          = (k ^ 2 + 1) * ((pellOrbit k (3 * j + 2)).1) + k * ((pellOrbit k (3 * j + 2)).2) := by
        have : 3 * (j + 1) = (3 * j + 2) + 1 := by omega
        rw [this]
        simp only [pellOrbit, pellStep]
      have h6 : (pellOrbit k (3 * (j + 1))).2
          = k * ((pellOrbit k (3 * j + 2)).1) + ((pellOrbit k (3 * j + 2)).2) := by
        have : 3 * (j + 1) = (3 * j + 2) + 1 := by omega
        rw [this]
        simp only [pellOrbit, pellStep]
      subst hs
      rw [h3, h4, h1, h2] at h5 h6
      -- one full period of parities: (odd, even) → (even, odd) → (odd, odd) → (odd, even);
      -- after `ring_nf` every monomial of the new coordinates carries an even coefficient
      refine ⟨((pellOrbit (2 * s + 1) (3 * (j + 1))).1 - 1) / 2,
        (pellOrbit (2 * s + 1) (3 * (j + 1))).2 / 2, ?_, ?_⟩
      · rw [h5]; ring_nf; omega
      · rw [h6]; ring_nf; omega

/-- For odd `k`, the orbit points whose index is not `≡ 2 mod 3` are Euclid seeds. -/
theorem pellOrbit_isSeed_odd {k : ℤ} (hk : 0 < k) (hko : Odd k) (j : ℕ) :
    0 < (pellOrbit k (3 * j + 1)).2 ∧
      (pellOrbit k (3 * j + 1)).2 < (pellOrbit k (3 * j + 1)).1 ∧
      Odd ((pellOrbit k (3 * j + 1)).1 + (pellOrbit k (3 * j + 1)).2) := by
  obtain ⟨a, b, ha, hb⟩ := pellOrbit_parity_odd hko j
  obtain ⟨hm, hn⟩ := pellOrbit_pos k hk (3 * j)
  rw [ha] at hm
  rw [hb] at hn
  have h1 : (pellOrbit k (3 * j + 1)).1 = (k ^ 2 + 1) * (2 * a + 1) + k * (2 * b) := by
    simp only [pellOrbit, pellStep, ha, hb]
  have h2 : (pellOrbit k (3 * j + 1)).2 = k * (2 * a + 1) + 2 * b := by
    simp only [pellOrbit, pellStep, ha, hb]
  obtain ⟨s, hs⟩ := hko
  subst hs
  have ha0 : 0 ≤ a := by omega
  have hb0 : 0 ≤ b := by omega
  have hs0 : 0 ≤ s := by omega
  have hpos : 0 < (pellOrbit (2 * s + 1) (3 * j + 1)).2 := by rw [h2]; nlinarith
  have hlt : (pellOrbit (2 * s + 1) (3 * j + 1)).2 < (pellOrbit (2 * s + 1) (3 * j + 1)).1 := by
    rw [h1, h2]
    nlinarith [mul_nonneg hs0 hb0, mul_nonneg hs0 ha0, mul_nonneg (mul_nonneg hs0 hs0) ha0]
  refine ⟨hpos, hlt, ?_⟩
  rw [h1, h2]
  exact ⟨4 * s ^ 2 * a + 6 * s * a + 3 * a + 2 * s ^ 2 + 3 * s + 1 + 2 * s * b + 2 * b, by ring⟩

/-- **Census theorem.**  For every `k ≥ 1` the `k`-th exact geodesic through the centre of the
Poincaré-disk picture carries infinitely many genuine Euclid seeds. -/
theorem seeds_on_geodesic_infinite (k : ℤ) (hk : 0 < k) :
    {p : ℤ × ℤ | OnConic k p ∧ 0 < p.2 ∧ p.2 < p.1 ∧ Odd (p.1 + p.2)}.Infinite := by
  rcases Int.even_or_odd k with hke | hko
  · exact pellSeeds_infinite k hk hke
  · have hmono : StrictMono fun j : ℕ => (pellOrbit k (3 * j + 1)).1 := by
      apply strictMono_nat_of_lt_succ
      intro j
      have e1 : 3 * j + 1 + 1 = 3 * j + 2 := by omega
      have e2 : 3 * j + 2 + 1 = 3 * j + 3 := by omega
      have e3 : 3 * (j + 1) + 1 = 3 * j + 3 + 1 := by omega
      have h1 := pellOrbit_strictMono k hk (3 * j + 1)
      have h2 := pellOrbit_strictMono k hk (3 * j + 2)
      have h3 := pellOrbit_strictMono k hk (3 * j + 3)
      rw [e1] at h1
      rw [e2] at h2
      rw [e3]
      omega
    refine Set.infinite_of_injective_forall_mem
      (f := fun j : ℕ => pellOrbit k (3 * j + 1)) (fun a b hab => ?_) (fun j => ?_)
    · have := hmono.injective (congrArg Prod.fst hab)
      exact this
    · exact ⟨onConic_pellOrbit k (3 * j + 1), pellOrbit_isSeed_odd hk hko j⟩

end BerggrenHyperbolic