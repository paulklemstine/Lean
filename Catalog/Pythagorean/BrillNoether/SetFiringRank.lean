/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Catalog.Pythagorean.BrillNoether.Divisors
import Catalog.Pythagorean.BrillNoether.Reduced
import Catalog.Pythagorean.BrillNoether.HalfCanonicalRegular
import Catalog.Pythagorean.BrillNoether.ResidualDuality

/-!
# Set firing and the rank of uniformly positive divisors

`HalfCanonicalRegular.lean` shows that a divisor with `m ≥ 1` chips on every
vertex of a graph of minimum degree `k` has Baker–Norine rank at least `2m`; the
firing move used there is the single move "all vertices except one fire".

Here we analyse the general *one-shot set firing* move: given an effective divisor
`E`, let `S` be the set of vertices carrying at least `m` chips of `E` and let all
vertices outside `S` fire once.  Every vertex of `S` then receives one chip along
each edge leaving `S`, while a vertex outside `S` pays one chip for each of its
neighbours inside `S`.  Because the chips of `E` are limited, `S` has at most two
elements, and a careful count shows the resulting divisor is effective.

The outcome, `rankAtLeast_of_forall_le_three_mul`, is that a divisor with `m ≥ 2`
chips everywhere has rank at least `min (3m - 1) (k + m)`; this improves the
bound `2m` by roughly fifty percent and is sharp on several small complete and
circulant graphs.

Specialising to `k`-regular graphs at the half-canonical degree `g - 1` (where
`m = ⌊(k-2)/2⌋` chips per vertex are available) gives the main application:

* `exists_halfCanonical_rank_regular_strong` — a divisor of degree `g - 1` and
  rank at least `3⌊(k-2)/2⌋ - 1` exists on every simple `k`-regular graph with
  `k ≥ 6`;
* `exists_halfCanonical_rank_conjecture` — consequently, for every `k ≥ 6` with
  `k ≠ 7`, *every* simple `k`-regular graph — with no lower bound whatsoever on
  the number of vertices — has a divisor of degree `g - 1` and rank at least
  `k - 1`.  This settles the uniform half-canonical existence question for those
  `k` with the optimal threshold `N₀(k) = 1`.
-/

open Finset

namespace BrillNoetherSetFiring

open BrillNoetherDivisor BrillNoetherReduced BrillNoetherHalfCanonical BrillNoetherResidual

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## The effect of firing the complement of a set -/

/-- Firing the complement of `S` costs a vertex outside `S` one chip for each of
its neighbours inside `S`. -/
lemma lap_ind_notMem {S : Finset V} {u : V} (hu : u ∉ S) :
    lap G (ind S) u = -(#(G.neighborFinset u ∩ S) : ℤ) := by
  rw [lap_apply, sum_ind_neighbors]
  have h1 : ind S u = 0 := by simp [ind, hu]
  rw [h1]
  ring

/-- A vertex of `S` has at least `deg v - (#S - 1)` edges leaving `S`. -/
lemma outdeg_ge {S : Finset V} {v : V} (hv : v ∈ S) :
    (G.degree v : ℤ) - ((#S : ℤ) - 1) ≤ (outdeg G S v : ℤ) := by
  classical
  have hsub : G.neighborFinset v ∩ S ⊆ S.erase v := by
    intro u hu
    rw [Finset.mem_inter] at hu
    refine Finset.mem_erase.mpr ⟨?_, hu.2⟩
    rintro rfl
    simpa using hu.1
  have hcard : #(G.neighborFinset v ∩ S) ≤ #S - 1 := by
    have := Finset.card_le_card hsub
    rwa [Finset.card_erase_of_mem hv] at this
  have hsum : #(G.neighborFinset v \ S) + #(G.neighborFinset v ∩ S) = G.degree v := by
    rw [Finset.card_sdiff_add_card_inter]
    exact G.card_neighborFinset_eq_degree v
  have hS1 : 1 ≤ #S := Finset.card_pos.mpr ⟨v, hv⟩
  unfold outdeg
  omega

/-- **One-shot set firing criterion.**  If every vertex of `S` is in debt by no
more than the number of its edges leaving `S`, and every vertex outside `S` can
afford one chip for each of its neighbours in `S`, then `D - E` is linearly
equivalent to an effective divisor. -/
lemma effective_of_fire_set {S : Finset V} {D E : Divisor V}
    (h1 : ∀ v ∈ S, E v - D v ≤ (outdeg G S v : ℤ))
    (h2 : ∀ u ∉ S, (#(G.neighborFinset u ∩ S) : ℤ) ≤ D u - E u) :
    ∃ f : V → ℤ, Effective (D - E + lap G f) := by
  refine ⟨ind S, fun u => ?_⟩
  simp only [Pi.add_apply, Pi.sub_apply]
  by_cases hu : u ∈ S
  · rw [lap_ind_mem G hu]
    have := h1 u hu
    linarith
  · rw [lap_ind_notMem G hu]
    have := h2 u hu
    linarith

/-! ## The rank bound -/

omit [DecidableEq V] in
/-- The chips of an effective divisor sitting on a set of vertices are bounded by
its degree. -/
lemma sum_le_deg {E : Divisor V} (hE : Effective E) (T : Finset V) :
    ∑ u ∈ T, E u ≤ deg E :=
  Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ T) fun u _ _ => hE u

/-- **Rank of a uniformly positive divisor via set firing.**  On a graph of
minimum degree `k`, a divisor carrying at least `m ≥ 2` chips on every vertex has
Baker–Norine rank at least `d` whenever `d + 1 ≤ 3m` and `d ≤ k + m`.

In other words the rank is at least `min (3m - 1) (k + m)`, improving the bound
`2m` of `BrillNoetherHalfCanonical.rankAtLeast_add_of_forall_le`. -/
theorem rankAtLeast_of_forall_le_three_mul {k m d : ℕ} (hk : ∀ v, k ≤ G.degree v)
    {D : Divisor V} (hD : ∀ v, (m : ℤ) ≤ D v) (hm : 2 ≤ m) (hmk : m ≤ k)
    (hd1 : d + 1 ≤ 3 * m) (hd2 : d ≤ k + m) :
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
  -- integer versions of the numeric hypotheses
  have hm' : (2 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm
  have hmk' : (m : ℤ) ≤ (k : ℤ) := by exact_mod_cast hmk
  have hd1' : (d : ℤ) + 1 ≤ 3 * (m : ℤ) := by exact_mod_cast hd1
  have hd2' : (d : ℤ) ≤ (k : ℤ) + (m : ℤ) := by exact_mod_cast hd2
  -- the set of vertices carrying at least `m` chips of `E`
  set S : Finset V := univ.filter (fun u => (m : ℤ) ≤ E u) with hS
  have hmemS : ∀ u, u ∈ S ↔ (m : ℤ) ≤ E u := by intro u; simp [hS]
  have hv₀S : v₀ ∈ S := by
    rw [hmemS]
    have := hD v₀
    linarith
  have hv₀big : (m : ℤ) + 1 ≤ E v₀ := by have := hD v₀; linarith
  -- the chips of `E` inside `S`
  have hSsum : (#S : ℤ) * (m : ℤ) + 1 ≤ ∑ w ∈ S, E w := by
    have hsplit : ∑ w ∈ S, E w = E v₀ + ∑ w ∈ S.erase v₀, E w :=
      (Finset.add_sum_erase _ _ hv₀S).symm
    have hlow : ∀ w ∈ S.erase v₀, (m : ℤ) ≤ E w := fun w hw =>
      (hmemS w).mp (Finset.mem_of_mem_erase hw)
    have hsum : (#(S.erase v₀) : ℤ) * (m : ℤ) ≤ ∑ w ∈ S.erase v₀, E w := by
      have := Finset.card_nsmul_le_sum (S.erase v₀) E (m : ℤ) hlow
      simpa [nsmul_eq_mul, mul_comm] using this
    have hcard : (#S : ℤ) = (#(S.erase v₀) : ℤ) + 1 := by
      have h' : #(S.erase v₀) + 1 = #S := by
        rw [Finset.card_erase_of_mem hv₀S]
        have : 1 ≤ #S := Finset.card_pos.mpr ⟨v₀, hv₀S⟩
        omega
      exact_mod_cast h'.symm
    have hexp : ((#(S.erase v₀) : ℤ) + 1) * (m : ℤ)
        = (#(S.erase v₀) : ℤ) * (m : ℤ) + (m : ℤ) := by ring
    rw [hsplit, hcard, hexp]
    linarith
  have hcardS : (#S : ℤ) * (m : ℤ) + 1 ≤ (d : ℤ) := by
    have hle := sum_le_deg hE S
    rw [hdegE] at hle
    linarith
  have hS1 : 1 ≤ #S := Finset.card_pos.mpr ⟨v₀, hv₀S⟩
  have hS2 : #S ≤ 2 := by
    by_contra hcon
    push_neg at hcon
    have h3 : (3 : ℤ) ≤ (#S : ℤ) := by exact_mod_cast hcon
    nlinarith
  -- outside `S` the chips of `E` are few
  have houtside : ∀ u, u ∉ S → E u ≤ (m : ℤ) - 1 := by
    intro u hu
    have : ¬ ((m : ℤ) ≤ E u) := by rwa [hmemS] at hu
    linarith
  have houtside2 : ∀ u, u ∉ S → E u + ((#S : ℤ) * (m : ℤ) + 1) ≤ (d : ℤ) := by
    intro u hu
    have hsplit : ∑ w ∈ insert u S, E w = E u + ∑ w ∈ S, E w := Finset.sum_insert hu
    have hle := sum_le_deg hE (insert u S)
    rw [hdegE, hsplit] at hle
    linarith
  -- now fire the complement of `S`
  refine effective_of_fire_set G (S := S) (fun v hv => ?_) (fun u hu => ?_)
  · -- vertices of `S` receive enough chips
    have hEv : E v ≤ (d : ℤ) - ((#S : ℤ) - 1) * (m : ℤ) := by
      have hsplit : ∑ w ∈ S, E w = E v + ∑ w ∈ S.erase v, E w :=
        (Finset.add_sum_erase _ _ hv).symm
      have hlow : ∀ w ∈ S.erase v, (m : ℤ) ≤ E w := fun w hw =>
        (hmemS w).mp (Finset.mem_of_mem_erase hw)
      have hsum : (#(S.erase v) : ℤ) * (m : ℤ) ≤ ∑ w ∈ S.erase v, E w := by
        have := Finset.card_nsmul_le_sum (S.erase v) E (m : ℤ) hlow
        simpa [nsmul_eq_mul, mul_comm] using this
      have hcard : (#(S.erase v) : ℤ) = (#S : ℤ) - 1 := by
        have : #(S.erase v) + 1 = #S := by
          rw [Finset.card_erase_of_mem hv]
          have : 1 ≤ #S := Finset.card_pos.mpr ⟨v, hv⟩
          omega
        have h' : ((#(S.erase v) + 1 : ℕ) : ℤ) = (#S : ℤ) := by exact_mod_cast this
        push_cast at h'
        linarith
      have hle := sum_le_deg hE S
      rw [hdegE, hsplit] at hle
      rw [hcard] at hsum
      linarith
    have hout := outdeg_ge G hv
    have hdv : (k : ℤ) ≤ (G.degree v : ℤ) := by exact_mod_cast hk v
    have hDv := hD v
    interval_cases h : (#S)
    · push_cast at hEv hout ⊢
      linarith
    · push_cast at hEv hout ⊢
      linarith
  · -- vertices outside `S` can afford the cost
    have hcost : (#(G.neighborFinset u ∩ S) : ℤ) ≤ (#S : ℤ) := by
      exact_mod_cast Finset.card_le_card (Finset.inter_subset_right)
    have h1 := houtside u hu
    have h2 := houtside2 u hu
    have hDu := hD u
    interval_cases h : (#S)
    · push_cast at hcost ⊢
      linarith
    · push_cast at hcost h2 ⊢
      linarith

/-! ## Application: half-canonical divisors on regular graphs -/

/-- **Improved half-canonical existence on regular graphs.**  Every simple
`k`-regular graph with `k ≥ 6` — with no hypothesis on the number of vertices —
carries a divisor of the half-canonical degree `g - 1` whose Baker–Norine rank is
at least `3⌊(k-2)/2⌋ - 1`. -/
theorem exists_halfCanonical_rank_regular_strong [Nonempty V] {k : ℕ}
    (hreg : G.IsRegularOfDegree k) (hk : 6 ≤ k) :
    ∃ D : Divisor V, deg D = genus G - 1 ∧ RankAtLeast G D (3 * ((k - 2) / 2) - 1) := by
  classical
  set m : ℕ := (k - 2) / 2 with hm
  have hm2 : 2 ≤ m := by omega
  have hmk : m ≤ k := by omega
  have hmk' : (2 * m : ℤ) ≤ (k : ℤ) - 2 := by
    have h1 : 2 * m ≤ k - 2 := by omega
    have h2 : ((2 * m : ℕ) : ℤ) ≤ ((k - 2 : ℕ) : ℤ) := by exact_mod_cast h1
    rw [Nat.cast_sub (by omega)] at h2
    push_cast at h2 ⊢
    linarith
  have hn : (0 : ℤ) ≤ (Fintype.card V : ℤ) := by positivity
  have hle : (m : ℤ) * (Fintype.card V : ℤ) ≤ genus G - 1 := by
    have h2 := two_mul_genus_sub_one_regular G hreg
    nlinarith
  obtain ⟨D, hdeg, hDge⟩ := exists_deg_forall_ge (V := V) m (genus G - 1) hle
  refine ⟨D, hdeg, ?_⟩
  exact rankAtLeast_of_forall_le_three_mul G (k := k) (m := m) (d := 3 * m - 1)
    (fun v => (hreg v).ge) hDge hm2 hmk (by omega) (by omega)

/-- **Uniform half-canonical existence, unconditionally, for `k ≥ 6`, `k ≠ 7`.**
Every simple `k`-regular graph, on any number of vertices, has a divisor of degree
`g - 1` and Baker–Norine rank at least `k - 1`.  Thus for these `k` the threshold
`N₀(k)` of the uniform half-canonical existence problem may be taken to be `1`. -/
theorem exists_halfCanonical_rank_conjecture [Nonempty V] {k : ℕ}
    (hreg : G.IsRegularOfDegree k) (hk : 6 ≤ k) (hk7 : k ≠ 7) :
    ∃ D : Divisor V, deg D = genus G - 1 ∧ RankAtLeast G D (k - 1) := by
  obtain ⟨D, hdeg, hrank⟩ := exists_halfCanonical_rank_regular_strong G hreg hk
  refine ⟨D, hdeg, ?_⟩
  exact rankAtLeast_antitone G (by omega) hrank

/-- **A theta characteristic of near-maximal rank.**  On a `2j`-regular graph with
`j ≥ 3` the constant divisor with `j - 1` chips per vertex is a fixed class of the
residual involution `D ↦ K - D`, of degree `g - 1`, and its Baker–Norine rank is
at least `3j - 4 ≥ k - 1`.  Thus for even `k ≥ 6` the conjectural half-canonical
witness can be taken to be a theta characteristic. -/
theorem exists_thetaChar_rank_regular_even [Nonempty V] {j : ℕ}
    (hreg : G.IsRegularOfDegree (2 * j)) (hj : 3 ≤ j) :
    ∃ D : Divisor V, IsThetaChar G D ∧ deg D = genus G - 1 ∧
      LinEquiv G D (residual G D) ∧ RankAtLeast G D (3 * j - 4) := by
  classical
  have hth : IsThetaChar G (fun _ => (j : ℤ) - 1) := by
    refine ⟨0, ?_⟩
    funext v
    simp only [canonical, Pi.add_apply, Pi.zero_apply, lap_zero, hreg v]
    push_cast
    ring
  refine ⟨fun _ => (j : ℤ) - 1, hth, deg_of_thetaChar G hth,
    (linEquiv_residual_iff_thetaChar G _).mpr hth, ?_⟩
  have hD : ∀ _v : V, ((j - 1 : ℕ) : ℤ) ≤ ((j : ℤ) - 1) := fun _ => by omega
  exact rankAtLeast_of_forall_le_three_mul G (k := 2 * j) (m := j - 1) (d := 3 * j - 4)
    (fun v => (hreg v).ge) hD (by omega) (by omega) (by omega) (by omega)

end BrillNoetherSetFiring