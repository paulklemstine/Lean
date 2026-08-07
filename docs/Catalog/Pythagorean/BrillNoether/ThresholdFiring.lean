/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.BrillNoether.Divisors
import Pythagorean.BrillNoether.Reduced
import Pythagorean.BrillNoether.HalfCanonicalRegular
import Pythagorean.BrillNoether.ResidualDuality
import Pythagorean.BrillNoether.SetFiringRank

/-!
# Threshold set firing: a quadratic lower bound for the rank

`SetFiringRank.lean` fires the complement of the set `S = {v : E v ≥ m}` of
vertices carrying at least `m` chips of the test divisor `E`, where `m` is the
uniform lower bound for the divisor `D`.  That choice forces `#S ≤ 2` and yields
the linear estimate `r(D) ≥ min (3m - 1) (k + m)`.

Here we fire the complement of the *threshold* set `S_t = {v : E v ≥ t}` for an
arbitrary threshold `1 ≤ t ≤ m`.  Lowering `t` makes `S_t` bigger — so the
vertices *outside* `S_t` pay more — but it also caps the chips they can carry by
`t - 1`, and this trade-off is genuinely better than the extreme `t = m`.

Writing `t = a + 1` and `m = a + b` (so `b ≥ 1` encodes `t ≤ m`), the outcome is

  `r(D) ≥ min (2 (a + b) + a b) ((a + b) + k)`

(`rankAtLeast_of_threshold_quadratic`).  At `a = m - 1`, `b = 1` this is exactly
the previous bound `min (3m - 1) (k + m)`, while at `a = b = m / 2` the first
term is `2m + ⌊m²/4⌋`: *quadratic* in `m` instead of linear.

## Main results

* `rankAtLeast_of_threshold_firing` — the general threshold-firing estimate, with
  the two families of numerical side conditions stated explicitly.
* `rankAtLeast_of_threshold_quadratic` — the closed form
  `r(D) ≥ min (2(a+b) + a b) ((a+b) + k)`.
* `rankAtLeast_of_forall_le_three_mul'` — the previous bound recovered as the
  special case `b = 1`.
* `exists_halfCanonical_rank_regular_threshold` — the half-canonical application:
  on any simple `k`-regular graph there is a divisor of degree `g - 1` and rank
  at least `min (2(a+b) + a b) ((a+b) + k)` whenever `2(a+b) + 2 ≤ k`.
* `exists_halfCanonical_rank_regular_superlinear` — the half-canonical
  application: for `4j + 2 ≤ k ≤ j² + 2j` with `j ≥ 3`, every simple `k`-regular
  graph carries a divisor of degree `g - 1` and rank at least `k + 2j`.  Taking
  `j ≈ k/4` this reaches the full cap `k + m` with `m = ⌊(k-2)/2⌋`, i.e. rank
  `≈ 3k/2`; the previous one-shot bound `min (3m - 1) (k + m)` was pinned at
  `3m - 1`, three units below the cap.

The *large* gain is for graphs with `k ≫ m`: there the old bound is the linear
`3m - 1` while the new one is the quadratic `2m + ⌊m²/4⌋`.
-/

open Finset

namespace BrillNoetherThreshold

open BrillNoetherDivisor BrillNoetherReduced BrillNoetherHalfCanonical BrillNoetherSetFiring
open BrillNoetherResidual

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- **Threshold set firing.**  Let `G` have minimum degree `k` and let `D` carry at
least `m` chips on every vertex.  Fix a threshold `1 ≤ t ≤ m`.  If for every
`j ≥ 0` with `j t + m + 1 ≤ d` the two numerical conditions

* `d + j ≤ m + k + j t`  (the `j + 1` vertices above the threshold can be repaired), and
* `t + j ≤ m` or `d + j ≤ 2 m + j t`  (the vertices below the threshold can pay),

hold, then `D` has Baker–Norine rank at least `d`. -/
theorem rankAtLeast_of_threshold_firing {k m t d : ℕ} (hk : ∀ v, k ≤ G.degree v)
    {D : Divisor V} (hD : ∀ v, (m : ℤ) ≤ D v) (htm : t ≤ m)
    (hIN : ∀ j : ℕ, j * t + m + 1 ≤ d → d + j ≤ m + k + j * t)
    (hOUT : ∀ j : ℕ, j * t + m + 1 ≤ d → (t + j ≤ m ∨ d + j ≤ 2 * m + j * t)) :
    RankAtLeast G D d := by
  classical
  intro E hE hdegE
  by_cases hcase : ∀ v, E v ≤ D v
  · refine ⟨0, fun v => ?_⟩
    have := hcase v
    simp only [Pi.add_apply, Pi.sub_apply, lap_zero, Pi.zero_apply]
    linarith
  push_neg at hcase
  obtain ⟨v₀, hv₀⟩ := hcase
  -- the threshold set
  set S : Finset V := univ.filter (fun u => (t : ℤ) ≤ E u) with hS
  have hmemS : ∀ u, u ∈ S ↔ (t : ℤ) ≤ E u := by intro u; simp [hS]
  have hv₀big : (m : ℤ) + 1 ≤ E v₀ := by have := hD v₀; linarith
  have htm' : (t : ℤ) ≤ (m : ℤ) := by exact_mod_cast htm
  have hv₀S : v₀ ∈ S := by rw [hmemS]; linarith
  -- write `#S = j + 1`
  have hS1 : 1 ≤ #S := Finset.card_pos.mpr ⟨v₀, hv₀S⟩
  obtain ⟨j, hj⟩ : ∃ j : ℕ, #S = j + 1 := ⟨#S - 1, by omega⟩
  have hjcast : (#S : ℤ) = (j : ℤ) + 1 := by rw [hj]; push_cast; ring
  -- chips of `E` sitting inside `S`
  have hlowS : ∀ w ∈ S, (t : ℤ) ≤ E w := fun w hw => (hmemS w).mp hw
  have hsumS : (j : ℤ) * (t : ℤ) + ((m : ℤ) + 1) ≤ ∑ w ∈ S, E w := by
    have hsplit : ∑ w ∈ S, E w = E v₀ + ∑ w ∈ S.erase v₀, E w :=
      (Finset.add_sum_erase _ _ hv₀S).symm
    have hsum : (#(S.erase v₀) : ℤ) * (t : ℤ) ≤ ∑ w ∈ S.erase v₀, E w := by
      have := Finset.card_nsmul_le_sum (S.erase v₀) E (t : ℤ)
        (fun w hw => hlowS w (Finset.mem_of_mem_erase hw))
      simpa [nsmul_eq_mul, mul_comm] using this
    have hcard : (#(S.erase v₀) : ℤ) = (j : ℤ) := by
      rw [Finset.card_erase_of_mem hv₀S, hj]
      simp
    rw [hcard] at hsum
    rw [hsplit]
    linarith
  have hdegS : ∑ w ∈ S, E w ≤ (d : ℤ) := by
    have := sum_le_deg hE S
    rwa [hdegE] at this
  -- the range condition is met
  have hrange : j * t + m + 1 ≤ d := by
    have : (j : ℤ) * (t : ℤ) + (m : ℤ) + 1 ≤ (d : ℤ) := by linarith
    exact_mod_cast (by push_cast; linarith : ((j * t + m + 1 : ℕ) : ℤ) ≤ ((d : ℕ) : ℤ))
  have hIN' := hIN j hrange
  have hOUT' := hOUT j hrange
  have hIN'' : (d : ℤ) + (j : ℤ) ≤ (m : ℤ) + (k : ℤ) + (j : ℤ) * (t : ℤ) := by
    exact_mod_cast hIN'
  -- bound on the chips at a single vertex of `S`
  have hinS : ∀ v ∈ S, E v ≤ (d : ℤ) - (j : ℤ) * (t : ℤ) := by
    intro v hv
    have hsplit : ∑ w ∈ S, E w = E v + ∑ w ∈ S.erase v, E w :=
      (Finset.add_sum_erase _ _ hv).symm
    have hsum : (#(S.erase v) : ℤ) * (t : ℤ) ≤ ∑ w ∈ S.erase v, E w := by
      have := Finset.card_nsmul_le_sum (S.erase v) E (t : ℤ)
        (fun w hw => hlowS w (Finset.mem_of_mem_erase hw))
      simpa [nsmul_eq_mul, mul_comm] using this
    have hcard : (#(S.erase v) : ℤ) = (j : ℤ) := by
      rw [Finset.card_erase_of_mem hv, hj]
      simp
    rw [hcard] at hsum
    linarith [hdegS, hsplit ▸ hdegS]
  -- bound on the chips at a vertex outside `S`
  have houtlow : ∀ u, u ∉ S → E u ≤ (t : ℤ) - 1 := by
    intro u hu
    have : ¬ ((t : ℤ) ≤ E u) := by rwa [hmemS] at hu
    linarith
  have houthigh : ∀ u, u ∉ S → E u ≤ (d : ℤ) - ((j : ℤ) * (t : ℤ) + (m : ℤ) + 1) := by
    intro u hu
    have hsplit : ∑ w ∈ insert u S, E w = E u + ∑ w ∈ S, E w := Finset.sum_insert hu
    have hle := sum_le_deg hE (insert u S)
    rw [hdegE, hsplit] at hle
    linarith
  -- the vertices outside `S` can pay
  have hpay : ∀ u, u ∉ S → E u ≤ (m : ℤ) - ((j : ℤ) + 1) := by
    intro u hu
    rcases hOUT' with h | h
    · have h' : (t : ℤ) + (j : ℤ) ≤ (m : ℤ) := by exact_mod_cast h
      have := houtlow u hu
      linarith
    · have h' : (d : ℤ) + (j : ℤ) ≤ 2 * (m : ℤ) + (j : ℤ) * (t : ℤ) := by exact_mod_cast h
      have := houthigh u hu
      linarith
  -- fire the complement of `S`
  refine effective_of_fire_set G (S := S) (fun v hv => ?_) (fun u hu => ?_)
  · have hEv := hinS v hv
    have hout := outdeg_ge G hv
    have hdv : (k : ℤ) ≤ (G.degree v : ℤ) := by exact_mod_cast hk v
    have hDv := hD v
    rw [hjcast] at hout
    linarith
  · have hcost : (#(G.neighborFinset u ∩ S) : ℤ) ≤ (#S : ℤ) :=
      by exact_mod_cast Finset.card_le_card (Finset.inter_subset_right)
    rw [hjcast] at hcost
    have h1 := hpay u hu
    have hDu := hD u
    linarith

/-- **The closed-form threshold bound.**  With `t = a + 1` and `m = a + b`
(`b ≥ 1`), a divisor carrying at least `a + b` chips on every vertex of a graph of
minimum degree `k` has Baker–Norine rank at least
`min (2 (a + b) + a b) ((a + b) + k)`. -/
theorem rankAtLeast_of_threshold_quadratic {k a b d : ℕ} (hk : ∀ v, k ≤ G.degree v)
    {D : Divisor V} (hD : ∀ v, ((a + b : ℕ) : ℤ) ≤ D v) (hb : 1 ≤ b)
    (hd1 : d ≤ 2 * (a + b) + a * b) (hd2 : d ≤ (a + b) + k) :
    RankAtLeast G D d := by
  refine rankAtLeast_of_threshold_firing G (k := k) (m := a + b) (t := a + 1) hk hD
    (by omega) (fun j _ => ?_) (fun j _ => ?_)
  · -- `d + j ≤ m + k + j (a+1)` follows from `d ≤ m + k` since `j ≤ j (a+1)`
    have : j ≤ j * (a + 1) := Nat.le_mul_of_pos_right j (by omega)
    omega
  · -- either `j` is small, or `j ≥ b` and the quadratic bound applies
    rcases Nat.lt_or_ge j b with hj | hj
    · left; omega
    · right
      have hmul : a * b ≤ a * j := Nat.mul_le_mul_left a hj
      have hexp : j * (a + 1) = j * a + j := by ring
      have hja : a * j = j * a := Nat.mul_comm a j
      omega

/-- The previous set-firing bound `min (3m - 1) (k + m)` is the special case
`b = 1` of the threshold bound. -/
theorem rankAtLeast_of_forall_le_three_mul' {k m d : ℕ} (hk : ∀ v, k ≤ G.degree v)
    {D : Divisor V} (hD : ∀ v, (m : ℤ) ≤ D v) (hm : 1 ≤ m)
    (hd1 : d + 1 ≤ 3 * m) (hd2 : d ≤ k + m) :
    RankAtLeast G D d := by
  obtain ⟨a, rfl⟩ : ∃ a, m = a + 1 := ⟨m - 1, by omega⟩
  refine rankAtLeast_of_threshold_quadratic G (k := k) (a := a) (b := 1) hk ?_ le_rfl
    (by omega) (by omega)
  intro v; simpa using hD v

/-! ## Application to the half-canonical degree on regular graphs -/

/-- **Threshold firing at the half-canonical degree.**  On any simple `k`-regular
graph and for any `a, b` with `b ≥ 1` and `2 (a + b) + 2 ≤ k`, there is a divisor
of degree `g - 1` whose Baker–Norine rank is at least
`min (2 (a+b) + a b) ((a+b) + k)`. -/
theorem exists_halfCanonical_rank_regular_threshold [Nonempty V] {k a b : ℕ}
    (hreg : G.IsRegularOfDegree k) (hb : 1 ≤ b) (hk : 2 * (a + b) + 2 ≤ k) :
    ∃ D : Divisor V, deg D = genus G - 1 ∧
      RankAtLeast G D (min (2 * (a + b) + a * b) ((a + b) + k)) := by
  classical
  set m : ℕ := a + b with hm
  have hmk' : (2 * m : ℤ) ≤ (k : ℤ) - 2 := by
    have h1 : 2 * m + 2 ≤ k := hk
    have h2 : ((2 * m + 2 : ℕ) : ℤ) ≤ ((k : ℕ) : ℤ) := by exact_mod_cast h1
    push_cast at h2 ⊢
    linarith
  have hn : (0 : ℤ) ≤ (Fintype.card V : ℤ) := by positivity
  have hle : (m : ℤ) * (Fintype.card V : ℤ) ≤ genus G - 1 := by
    have h2 := two_mul_genus_sub_one_regular G hreg
    nlinarith
  obtain ⟨D, hdeg, hDge⟩ := exists_deg_forall_ge (V := V) m (genus G - 1) hle
  refine ⟨D, hdeg, ?_⟩
  exact rankAtLeast_of_threshold_quadratic G (k := k) (a := a) (b := b)
    (fun v => (hreg v).ge) hDge hb (min_le_left _ _) (min_le_right _ _)

/-- **A superlinear half-canonical bound.**  For `j ≥ 3` and any degree `k` with
`4 j + 2 ≤ k ≤ j² + 2 j`, every simple `k`-regular graph carries a divisor of the
half-canonical degree `g - 1` whose Baker–Norine rank is at least `k + 2 j`.
Taking `j` of order `k / 4` gives rank of order `3k/2`: the full `k + m` cap of
the firing estimate, which firing at the extreme threshold `t = m` never
reaches. -/
theorem exists_halfCanonical_rank_regular_superlinear [Nonempty V] {k j : ℕ}
    (hreg : G.IsRegularOfDegree k) (hj : 3 ≤ j) (hk1 : 4 * j + 2 ≤ k)
    (hk2 : k ≤ j * j + 2 * j) :
    ∃ D : Divisor V, deg D = genus G - 1 ∧ RankAtLeast G D (k + 2 * j) := by
  obtain ⟨D, hdeg, hrank⟩ :=
    exists_halfCanonical_rank_regular_threshold G (a := j) (b := j) hreg (by omega) (by omega)
  refine ⟨D, hdeg, ?_⟩
  have hmin : k + 2 * j ≤ min (2 * (j + j) + j * j) ((j + j) + k) := by
    refine le_min ?_ (by omega)
    omega
  exact rankAtLeast_antitone G hmin hrank

/-- **A concrete improvement.**  Every simple `30`-regular graph carries a divisor
of degree `g - 1` and Baker–Norine rank at least `44`.  The one-shot bound of
`SetFiringRank.lean` gives only `min (3m - 1) (k + m) = 41` here (with `m = 14`),
and the previously known uniform statement gives only `k - 1 = 29`. -/
theorem exists_halfCanonical_rank_regular_deg_thirty [Nonempty V]
    (hreg : G.IsRegularOfDegree 30) :
    ∃ D : Divisor V, deg D = genus G - 1 ∧ RankAtLeast G D 44 := by
  obtain ⟨D, hdeg, hrank⟩ :=
    exists_halfCanonical_rank_regular_threshold G (a := 7) (b := 7) hreg (by omega) (by omega)
  exact ⟨D, hdeg, rankAtLeast_antitone G (by norm_num) hrank⟩

/-- **Threshold firing at a theta characteristic.**  On a `2j`-regular graph the
constant divisor `j - 1` is a fixed class of the residual involution `D ↦ K - D`
of degree `g - 1`; its Baker–Norine rank is at least
`min (2(a+b) + a b) ((a+b) + 2j)` for every splitting `j - 1 = a + b` with
`b ≥ 1`.  This upgrades `SetFiringRank.exists_thetaChar_rank_regular_even`, which
is the case `b = 1`. -/
theorem exists_thetaChar_rank_regular_even_threshold [Nonempty V] {j a b : ℕ}
    (hreg : G.IsRegularOfDegree (2 * j)) (hb : 1 ≤ b) (hab : a + b + 1 = j) :
    ∃ D : Divisor V, IsThetaChar G D ∧ deg D = genus G - 1 ∧
      LinEquiv G D (residual G D) ∧
      RankAtLeast G D (min (2 * (a + b) + a * b) ((a + b) + 2 * j)) := by
  classical
  have hth : IsThetaChar G (fun _ => (j : ℤ) - 1) := by
    refine ⟨0, ?_⟩
    funext v
    simp only [canonical, Pi.add_apply, Pi.zero_apply, lap_zero, hreg v]
    push_cast
    ring
  refine ⟨fun _ => (j : ℤ) - 1, hth, deg_of_thetaChar G hth,
    (linEquiv_residual_iff_thetaChar G _).mpr hth, ?_⟩
  have hD : ∀ _v : V, ((a + b : ℕ) : ℤ) ≤ (j : ℤ) - 1 := by
    intro _
    have : ((a + b : ℕ) : ℤ) + 1 = (j : ℤ) := by exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) hab
    linarith
  exact rankAtLeast_of_threshold_quadratic G (k := 2 * j) (a := a) (b := b)
    (fun v => (hreg v).ge) hD hb (min_le_left _ _) (min_le_right _ _)

end BrillNoetherThreshold