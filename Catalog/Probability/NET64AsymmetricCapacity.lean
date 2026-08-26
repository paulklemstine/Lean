import Mathlib
import Probability.NET64SharpSweepCost
import Probability.NET64SweepRigidity
import Probability.NET64TwoSidedCapacity

/-!
# NET-64, cycle 6: the product law for sweep capacity

Cycle 3 computed the capacity of a *deployment-safe* sweep (the reported budget
may exceed the knee by a factor `r`, never fall below it): `geoSum r s`.  Cycle 5
computed the capacity of the *two-sided* sweep (a factor `r` on either side):
`geoSum (r²) s`.  The two answers differ by replacing `r` with `r²`, which
suggests that only one number governs a sweep.

This file proves that suggestion.  For tolerances `a` below and `b` above,

    AsymLocalises G a b N  ↔  ∀ c ∈ [1, N], ∃ g ∈ G, g ≤ b·c ∧ c ≤ a·g,

the exact `s`-point capacity is `geoSum (a·b) s`, attained by the unique grid
`{b·(geoSum (a·b) j + 1) : j < s}`:

* `asym_capacity_upper`, `asymGrid_localises`, `asym_capacity_exact` — the exact
  capacity;
* `asym_rigidity` — the optimal grid is unique;
* `asym_capacity_product_law` — **the punchline**: the capacity depends on the
  pair `(a, b)` only through the product `a·b`, so an asymmetric tolerance can be
  traded freely between the two sides;
* `localises_iff_asym`, `twoSided_iff_asym`, `sweep_capacity_exact_of_asym`,
  `twoSided_capacity_exact_of_asym` — cycles 3 and 5 are the instances
  `(a, b) = (1, r)` and `(a, b) = (r, r)`, and their extremal grids
  (`geoGrid r s`, `twoSidedGrid r s`) are the corresponding instances of
  `asymGrid`;
* `net64_asymmetric_trade` — the NET-64 instance of the trade: four sweep points
  allowed a factor `4` *upward only* localise exactly as much (`[1, 340]`) as
  four points allowed a factor `2` on either side, while four points allowed a
  factor `2` upward only localise `[1, 30]`.
-/

namespace Catalog.Probability.NET64AsymmetricCapacity

open Finset Catalog.Probability.NET64SharpSweepCost
  Catalog.Probability.NET64TwoSidedCapacity

/-! ## 1. Asymmetric localisation -/

/-- `AsymLocalises G a b N`: every budget `c ∈ [1, N]` has a sampled budget that
overshoots it by at most a factor `b` and undershoots it by at most a factor
`a`. -/
def AsymLocalises (G : Finset ℕ) (a b N : ℕ) : Prop :=
  ∀ c, 1 ≤ c → c ≤ N → ∃ g ∈ G, g ≤ b * c ∧ c ≤ a * g

/-- Cycle 3's deployment-safe sweep is the case `a = 1`. -/
theorem localises_iff_asym {G : Finset ℕ} {r N : ℕ} :
    Localises G r N ↔ AsymLocalises G 1 r N := by
  constructor
  · intro h c hc1 hc2
    obtain ⟨g, hg, h1, h2⟩ := h c hc1 hc2
    exact ⟨g, hg, h2, by simpa using h1⟩
  · intro h c hc1 hc2
    obtain ⟨g, hg, h1, h2⟩ := h c hc1 hc2
    exact ⟨g, hg, by simpa using h2, h1⟩

/-- Cycle 5's two-sided sweep is the case `a = b`. -/
theorem twoSided_iff_asym {G : Finset ℕ} {r N : ℕ} :
    TwoSided G r N ↔ AsymLocalises G r r N := Iff.rfl

/-! ## 2. The exact capacity -/

/-- **Asymmetric sweep capacity, upper bound.**  An `s`-point grid with
tolerances `a` below and `b` above localises at most `geoSum (a·b) s` budgets.
Peeling the largest point `M`: it serves only budgets `c ≥ ⌈M/b⌉`, and it reaches
only up to `a·M`; the two factors enter multiplicatively. -/
theorem asym_capacity_upper :
    ∀ (n : ℕ) (G : Finset ℕ) (a b N : ℕ), G.card = n → 1 ≤ a → 1 ≤ b →
      AsymLocalises G a b N → N ≤ geoSum (a * b) n := by
  intro n
  induction n with
  | zero =>
      intro G a b N hcard _ _ hloc
      by_contra hN
      push_neg at hN
      obtain ⟨g, hg, -, -⟩ := hloc 1 le_rfl (by omega)
      rw [Finset.card_eq_zero] at hcard
      simp [hcard] at hg
  | succ n ih =>
      intro G a b N hcard ha hb hloc
      rcases Nat.eq_zero_or_pos N with hN0 | hN1
      · simp [hN0]
      have hGne : G.Nonempty := Finset.card_pos.mp (by omega)
      set M := G.max' hGne with hM
      obtain ⟨g, hg, -, hgN⟩ := hloc N hN1 le_rfl
      have hNaM : N ≤ a * M := le_trans hgN (Nat.mul_le_mul_left a (Finset.le_max' G g hg))
      have hM1 : 1 ≤ M := by
        rcases Nat.eq_zero_or_pos M with h0 | h
        · rw [h0] at hNaM; omega
        · exact h
      set N' := (M - 1) / b with hN'
      have hcard' : (G.erase M).card = n := by
        rw [Finset.card_erase_of_mem (Finset.max'_mem G hGne), hcard]
        omega
      have hmodlt : (M - 1) % b < b := Nat.mod_lt _ (by omega)
      have hbN' : b * N' ≤ M - 1 := Nat.mul_div_le _ _
      have hsplit : b * N' + (M - 1) % b = M - 1 := by
        have := Nat.div_add_mod (M - 1) b
        omega
      have hloc' : AsymLocalises (G.erase M) a b (min N N') := by
        intro c hc1 hc2
        obtain ⟨g', hg', h1, h2⟩ := hloc c hc1 (le_trans hc2 (min_le_left _ _))
        have hcN' : c ≤ N' := le_trans hc2 (min_le_right _ _)
        have hlt : g' < M := by
          have h3 : b * c ≤ b * N' := Nat.mul_le_mul_left b hcN'
          omega
        exact ⟨g', Finset.mem_erase.mpr ⟨Nat.ne_of_lt hlt, hg'⟩, h1, h2⟩
      have hmin := ih (G.erase M) a b (min N N') hcard' ha hb hloc'
      have hstep : geoSum (a * b) (n + 1) = a * b * geoSum (a * b) n + a * b :=
        geoSum_succ' (a * b) n
      by_cases hcase : N ≤ N'
      · rw [min_eq_left hcase] at hmin
        exact le_trans hmin (geoSum_mono _ (Nat.le_succ n))
      · rw [min_eq_right (Nat.le_of_lt (Nat.lt_of_not_le hcase))] at hmin
        have hMle : M ≤ b * N' + b := by omega
        have h1 : N ≤ a * (b * N' + b) := le_trans hNaM (Nat.mul_le_mul_left a hMle)
        have h2 : a * (b * N' + b) = a * b * N' + a * b := by ring
        have h3 : a * b * N' ≤ a * b * geoSum (a * b) n := Nat.mul_le_mul_left _ hmin
        omega

/-- The extremal asymmetric grid. -/
def asymGrid (a b s : ℕ) : Finset ℕ :=
  (range s).image fun j => b * (geoSum (a * b) j + 1)

theorem asymGrid_card {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) (s : ℕ) :
    (asymGrid a b s).card = s := by
  have hab : 1 ≤ a * b := Nat.one_le_iff_ne_zero.mpr (by positivity)
  rw [asymGrid, Finset.card_image_of_injOn, Finset.card_range]
  intro x _ y _ hxy
  have h : geoSum (a * b) x + 1 = geoSum (a * b) y + 1 :=
    Nat.eq_of_mul_eq_mul_left (by omega) hxy
  exact (geoSum_strictMono hab).injective (by omega)

/-- **Attainment.**  The asymmetric grid covers `[1, geoSum (a·b) s]`. -/
theorem asymGrid_localises (a b s : ℕ) :
    AsymLocalises (asymGrid a b s) a b (geoSum (a * b) s) := by
  classical
  intro c hc1 hc2
  have hex : ∃ j, c ≤ geoSum (a * b) j := ⟨s, hc2⟩
  set j := Nat.find hex with hj
  have hjc : c ≤ geoSum (a * b) j := Nat.find_spec hex
  have hjpos : 0 < j := by
    rcases Nat.eq_zero_or_pos j with h0 | h
    · rw [h0, geoSum_zero] at hjc; omega
    · exact h
  have hjs : j ≤ s := Nat.find_le hc2
  have hprev : ¬ c ≤ geoSum (a * b) (j - 1) := Nat.find_min hex (by omega)
  push_neg at hprev
  refine ⟨b * (geoSum (a * b) (j - 1) + 1), ?_, ?_, ?_⟩
  · rw [asymGrid, Finset.mem_image]
    exact ⟨j - 1, Finset.mem_range.mpr (by omega), rfl⟩
  · exact Nat.mul_le_mul_left b (by omega)
  · have hj1 : j - 1 + 1 = j := Nat.succ_pred_eq_of_pos hjpos
    have hrec : geoSum (a * b) j = a * b * geoSum (a * b) (j - 1) + a * b := by
      conv_lhs => rw [← hj1]
      exact geoSum_succ' (a * b) (j - 1)
    have hexp : a * (b * (geoSum (a * b) (j - 1) + 1))
        = a * b * geoSum (a * b) (j - 1) + a * b := by ring
    omega

/-- **Exact asymmetric capacity.** -/
theorem asym_capacity_exact {a b : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b) (s : ℕ) :
    IsGreatest {N | ∃ G : Finset ℕ, G.card = s ∧ AsymLocalises G a b N}
      (geoSum (a * b) s) := by
  constructor
  · exact ⟨asymGrid a b s, asymGrid_card ha hb s, asymGrid_localises a b s⟩
  · rintro N ⟨G, hcard, hloc⟩
    exact asym_capacity_upper s G a b N hcard ha hb hloc

/-! ## 3. Rigidity in the asymmetric setting -/

theorem asymGrid_succ (a b s : ℕ) :
    asymGrid a b (s + 1) = insert (b * (geoSum (a * b) s + 1)) (asymGrid a b s) := by
  simp [asymGrid, Finset.range_add_one, Finset.image_insert]

/-- **Rigidity.**  At capacity the optimal asymmetric grid is unique. -/
theorem asym_rigidity :
    ∀ (s : ℕ) (G : Finset ℕ) (a b : ℕ), 1 ≤ a → 1 ≤ b → G.card = s →
      AsymLocalises G a b (geoSum (a * b) s) → G = asymGrid a b s := by
  intro s
  induction s with
  | zero =>
      intro G a b _ _ hcard _
      rw [Finset.card_eq_zero] at hcard
      simp [hcard, asymGrid]
  | succ n ih =>
      intro G a b ha hb hcard hloc
      have hab : 1 ≤ a * b := Nat.one_le_iff_ne_zero.mpr (by positivity)
      have hNrec : geoSum (a * b) (n + 1) = a * b * geoSum (a * b) n + a * b :=
        geoSum_succ' (a * b) n
      have hN1 : 1 ≤ geoSum (a * b) (n + 1) := by omega
      have hGne : G.Nonempty := Finset.card_pos.mp (by omega)
      set M := G.max' hGne with hM
      have hMmem : M ∈ G := Finset.max'_mem G hGne
      obtain ⟨g, hg, -, hgN⟩ := hloc _ hN1 le_rfl
      have hNaM : geoSum (a * b) (n + 1) ≤ a * M :=
        le_trans hgN (Nat.mul_le_mul_left a (Finset.le_max' G g hg))
      have hM1 : 1 ≤ M := by
        rcases Nat.eq_zero_or_pos M with h0 | h
        · rw [h0] at hNaM; omega
        · exact h
      set N' := (M - 1) / b with hN'
      have hcard' : (G.erase M).card = n := by
        rw [Finset.card_erase_of_mem hMmem, hcard]
        omega
      have hmodlt : (M - 1) % b < b := Nat.mod_lt _ (by omega)
      have hbN' : b * N' ≤ M - 1 := Nat.mul_div_le _ _
      have hsplit : b * N' + (M - 1) % b = M - 1 := by
        have := Nat.div_add_mod (M - 1) b
        omega
      have hloc' : AsymLocalises (G.erase M) a b (min (geoSum (a * b) (n + 1)) N') := by
        intro c hc1 hc2
        obtain ⟨g', hg', h1, h2⟩ := hloc c hc1 (le_trans hc2 (min_le_left _ _))
        have hcN' : c ≤ N' := le_trans hc2 (min_le_right _ _)
        have hlt : g' < M := by
          have h3 : b * c ≤ b * N' := Nat.mul_le_mul_left b hcN'
          omega
        exact ⟨g', Finset.mem_erase.mpr ⟨Nat.ne_of_lt hlt, hg'⟩, h1, h2⟩
      have hmin := asym_capacity_upper n (G.erase M) a b _ hcard' ha hb hloc'
      have hmono : geoSum (a * b) n < geoSum (a * b) (n + 1) :=
        geoSum_strictMono hab (Nat.lt_succ_self n)
      have hcase : ¬ geoSum (a * b) (n + 1) ≤ N' := by
        intro hle
        rw [min_eq_left hle] at hmin
        omega
      have hminEq : min (geoSum (a * b) (n + 1)) N' = N' :=
        min_eq_right (Nat.le_of_lt (Nat.lt_of_not_le hcase))
      rw [hminEq] at hmin hloc'
      have hMle : M ≤ b * N' + b := by omega
      have hstep : a * (b * N' + b) = a * b * N' + a * b := by ring
      have hle2 : a * b * N' ≤ a * b * geoSum (a * b) n := Nat.mul_le_mul_left _ hmin
      have haM : a * M ≤ a * (b * N' + b) := Nat.mul_le_mul_left a hMle
      have hN'eq : N' = geoSum (a * b) n := by
        have hge : a * b * geoSum (a * b) n ≤ a * b * N' := by omega
        have := Nat.le_antisymm hmin (Nat.le_of_mul_le_mul_left hge (by omega))
        omega
      have hMeq : M = b * (geoSum (a * b) n + 1) := by
        have hsubst : a * b * N' = a * b * geoSum (a * b) n := by rw [hN'eq]
        have hMlow : a * (b * N' + b) ≤ a * M := by omega
        have hge : b * N' + b ≤ M := Nat.le_of_mul_le_mul_left hMlow (by omega)
        have hexp : b * (geoSum (a * b) n + 1) = b * N' + b := by rw [hN'eq]; ring
        omega
      have hlocsub : AsymLocalises (G.erase M) a b (geoSum (a * b) n) := by
        rw [← hN'eq]; exact hloc'
      have hsub := ih (G.erase M) a b ha hb hcard' hlocsub
      calc G = insert M (G.erase M) := (Finset.insert_erase hMmem).symm
        _ = insert (b * (geoSum (a * b) n + 1)) (asymGrid a b n) := by rw [hsub, hMeq]
        _ = asymGrid a b (n + 1) := (asymGrid_succ a b n).symm

/-! ## 4. The product law, and cycles 3 and 5 as instances -/

/-- **The product law.**  The capacity of a sweep depends on its two tolerance
factors only through their product: a sweep allowed to overshoot by `b` and
undershoot by `a` is exactly as powerful as one with any other pair of the same
product.  Tolerance can be traded freely between the two sides. -/
theorem asym_capacity_product_law {a b a' b' : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b)
    (ha' : 1 ≤ a') (hb' : 1 ≤ b') (hprod : a * b = a' * b') (s : ℕ) :
    {N | ∃ G : Finset ℕ, G.card = s ∧ AsymLocalises G a b N} =
      {N | ∃ G : Finset ℕ, G.card = s ∧ AsymLocalises G a' b' N} := by
  have hcap : geoSum (a * b) s = geoSum (a' * b') s := by rw [hprod]
  ext N
  constructor
  · rintro ⟨G, hcard, hloc⟩
    refine ⟨asymGrid a' b' s, asymGrid_card ha' hb' s, ?_⟩
    have hN : N ≤ geoSum (a' * b') s := by
      rw [← hcap]; exact asym_capacity_upper s G a b N hcard ha hb hloc
    exact fun c hc1 hc2 => asymGrid_localises a' b' s c hc1 (le_trans hc2 hN)
  · rintro ⟨G, hcard, hloc⟩
    refine ⟨asymGrid a b s, asymGrid_card ha hb s, ?_⟩
    have hN : N ≤ geoSum (a * b) s := by
      rw [hcap]; exact asym_capacity_upper s G a' b' N hcard ha' hb' hloc
    exact fun c hc1 hc2 => asymGrid_localises a b s c hc1 (le_trans hc2 hN)

/-- Cycle 3's extremal grid is the instance `a = 1` of `asymGrid`. -/
theorem asymGrid_one (r s : ℕ) : asymGrid 1 r s = geoGrid r s := by
  rw [asymGrid, geoGrid]
  refine Finset.image_congr fun j _ => ?_
  rw [one_mul, geoSum_succ' r j]
  ring

/-- Cycle 5's extremal grid is the instance `a = b` of `asymGrid`. -/
theorem asymGrid_diag (r s : ℕ) : asymGrid r r s = twoSidedGrid r s := by
  rw [asymGrid, twoSidedGrid]
  refine Finset.image_congr fun j _ => ?_
  rw [show r * r = r ^ 2 by ring]

/-- Cycle 3's capacity theorem, recovered from the product law. -/
theorem sweep_capacity_exact_of_asym {r : ℕ} (hr : 1 ≤ r) (s : ℕ) :
    IsGreatest {N | ∃ G : Finset ℕ, G.card = s ∧ Localises G r N} (geoSum r s) := by
  have h := asym_capacity_exact (a := 1) (b := r) le_rfl hr s
  rw [one_mul] at h
  simpa only [localises_iff_asym] using h

/-- Cycle 5's capacity theorem, recovered from the product law. -/
theorem twoSided_capacity_exact_of_asym {r : ℕ} (hr : 1 ≤ r) (s : ℕ) :
    IsGreatest {N | ∃ G : Finset ℕ, G.card = s ∧ TwoSided G r N} (geoSum (r ^ 2) s) := by
  have h := asym_capacity_exact (a := r) (b := r) hr hr s
  rw [show r * r = r ^ 2 by ring] at h
  simpa only [twoSided_iff_asym] using h

/-! ## 5. The NET-64 instance of the trade -/

/-- **The NET-64 tolerance trade.**  With four sweep points: a factor `2` upward
only buys `[1, 30]`; a factor `2` on *either* side buys `[1, 340]`; and a factor
`4` upward only buys exactly the same `[1, 340]`.  Doubling the one-sided
tolerance is worth precisely as much as symmetrising it — the product `a·b = 4`
is all that matters. -/
theorem net64_asymmetric_trade :
    IsGreatest {N | ∃ G : Finset ℕ, G.card = 4 ∧ AsymLocalises G 1 2 N} 30 ∧
      IsGreatest {N | ∃ G : Finset ℕ, G.card = 4 ∧ AsymLocalises G 2 2 N} 340 ∧
      IsGreatest {N | ∃ G : Finset ℕ, G.card = 4 ∧ AsymLocalises G 1 4 N} 340 := by
  refine ⟨?_, ?_, ?_⟩
  · have h := asym_capacity_exact (a := 1) (b := 2) le_rfl (by norm_num) 4
    rwa [show geoSum (1 * 2) 4 = 30 by decide] at h
  · have h := asym_capacity_exact (a := 2) (b := 2) (by norm_num) (by norm_num) 4
    rwa [show geoSum (2 * 2) 4 = 340 by decide] at h
  · have h := asym_capacity_exact (a := 1) (b := 4) le_rfl (by norm_num) 4
    rwa [show geoSum (1 * 4) 4 = 340 by decide] at h

end Catalog.Probability.NET64AsymmetricCapacity