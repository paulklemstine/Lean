/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Pythagorean.BrillNoether.Divisors

/-!
# Half-canonical divisors of large rank on regular graphs

This file advances the *uniform half-canonical existence* problem: for a simple
connected `k`-regular graph, does there exist a divisor of degree `g - 1` whose
Baker–Norine rank is at least `k - 1`?

The elementary ("diagonal") bound of `Divisors.lean` produces at degree `g - 1`
only a divisor of rank `⌊(g-1)/n⌋ = ⌊(k-2)/2⌋`, roughly half of the conjectured
value, and `no_uniform_halfCanonical_witness` below shows that *no* argument
based on pointwise domination can ever do better: at the half-canonical degree
a divisor cannot have `r` chips on every vertex once `2r > k - 2`.

The main result `rankAtLeast_add_of_forall_le` is a genuine chip-firing
improvement: on a graph of minimum degree `k`, a divisor with at least `m ≥ 1`
chips at every vertex has rank at least `m + t` for every `t ≤ min m k`.  The
firing move used is "all vertices except one fire", which repairs the unique
vertex that can go into debt.  This doubles the elementary bound and yields, with
no hypothesis whatsoever on the number of vertices:

* `exists_halfCanonical_rank_regular` — every simple `k`-regular graph carries a
  divisor of degree `g - 1` and rank at least `2⌊(k-2)/2⌋`;
* `exists_halfCanonical_rank_regular_even` — for even `k` this is `k - 2`, one
  unit short of the conjectured `k - 1`.

The last section records the exact Brill–Noether arithmetic of the conjecture:
`bnNumber_regular_pos_iff` characterises positivity of the Brill–Noether number
`ρ = g - (r+1)(g - d + r)` at `d = g - 1`, `r = k - 1` by the inequality
`2k² ≤ (k-2)n`, and `bnNumber_regular_pos_of_linear_threshold` shows that the
*linear* threshold `n ≥ 2k + 7` already suffices for `k ≥ 5`, far below the
quadratic scale `2k²`.

## Main results

* `rankAtLeast_add_of_forall_le` — chip-firing rank boost.
* `exists_halfCanonical_rank_regular`, `exists_halfCanonical_rank_regular_even`.
* `no_uniform_halfCanonical_witness` — obstruction for pointwise arguments.
* `bnNumber_regular_pos_iff`, `bnNumber_regular_pos_of_linear_threshold`.
-/

open Finset

namespace BrillNoetherHalfCanonical

open BrillNoetherDivisor

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-! ## The single-vertex receiving move -/

/-- The Laplacian image of the indicator of a single vertex `v`: the vertex `v`
gains `deg v` chips and each of its neighbours loses one.  Equivalently, this is
the move in which every vertex except `v` fires. -/
lemma lap_single (v u : V) :
    lap G (fun w => if w = v then (1 : ℤ) else 0) u
      = if u = v then (G.degree v : ℤ) else (if G.Adj u v then -1 else 0) := by
  classical
  rw [lap_apply]
  have hsum : ∑ w ∈ G.neighborFinset u, (if w = v then (1 : ℤ) else 0)
      = if v ∈ G.neighborFinset u then (1 : ℤ) else 0 := by
    simp
  rw [hsum]
  by_cases huv : u = v
  · subst huv
    simp
  · simp only [if_neg huv, mul_zero, zero_sub, SimpleGraph.mem_neighborFinset]
    split_ifs <;> ring

/-! ## The chip-firing rank boost -/

/-- **Chip-firing rank boost.**  Let `G` have minimum degree at least `k` and let
`D` be a divisor with at least `m` chips on every vertex, `m ≥ 1`.  Then for every
`t ≤ m` with `t ≤ k` the Baker–Norine rank of `D` is at least `m + t`.

The point is that if `E` is effective of degree `m + t` and `D - E` is not
already effective, then exactly one vertex `v` is in debt (it carries at least
`m + 1` chips of `E`), the remaining chips of `E` number at most `t - 1 ≤ m - 1`,
and the single move "every vertex except `v` fires" repairs the debt without
creating a new one. -/
theorem rankAtLeast_add_of_forall_le {k m t : ℕ} (hk : ∀ v, k ≤ G.degree v)
    {D : Divisor V} (hD : ∀ v, (m : ℤ) ≤ D v) (htm : t ≤ m) (htk : t ≤ k) :
    RankAtLeast G D (m + t) := by
  classical
  intro E hE hdeg
  by_cases hcase : ∀ v, E v ≤ D v
  · refine ⟨0, fun v => ?_⟩
    have := hcase v
    simp only [Pi.add_apply, Pi.sub_apply, lap_zero, Pi.zero_apply]
    linarith
  · push_neg at hcase
    obtain ⟨v, hv⟩ := hcase
    -- `v` is the unique vertex carrying more than `m` chips of `E`
    have hEv : (m : ℤ) + 1 ≤ E v := by have := hD v; omega
    have hdegE : deg E = ((m : ℤ) + t) := by rw [hdeg]; push_cast; ring
    have hother : ∀ u, u ≠ v → E u ≤ (t : ℤ) - 1 := by
      intro u hu
      have hsplit : E u + E v ≤ deg E := by
        have : ({u, v} : Finset V) ⊆ univ := Finset.subset_univ _
        have hsum : ∑ w ∈ ({u, v} : Finset V), E w ≤ ∑ w ∈ univ, E w :=
          Finset.sum_le_sum_of_subset_of_nonneg this (fun w _ _ => hE w)
        rw [Finset.sum_pair hu] at hsum
        exact hsum
      rw [hdegE] at hsplit
      linarith
    have hEvle : E v ≤ (m : ℤ) + t := by
      have := le_deg_of_effective hE v
      rw [hdegE] at this; exact this
    refine ⟨fun w => if w = v then (1 : ℤ) else 0, fun u => ?_⟩
    rw [Pi.add_apply, Pi.sub_apply, lap_single G v u]
    have hdv : (k : ℤ) ≤ (G.degree v : ℤ) := by exact_mod_cast hk v
    have htk' : (t : ℤ) ≤ (k : ℤ) := by exact_mod_cast htk
    have htm' : (t : ℤ) ≤ (m : ℤ) := by exact_mod_cast htm
    have hDu := hD u
    have hDv := hD v
    split_ifs with h1 _
    · subst h1; linarith
    · have hEu := hother u h1; linarith
    · have hEu := hother u h1; linarith

/-! ## Divisors with a prescribed degree and a uniform lower bound -/

/-- On a nonempty graph, for any `m` and any degree `d ≥ m · n` there is a divisor
of degree `d` carrying at least `m` chips on every vertex. -/
theorem exists_deg_forall_ge [Nonempty V] (m : ℕ) (d : ℤ)
    (h : (m : ℤ) * (Fintype.card V : ℤ) ≤ d) :
    ∃ D : Divisor V, deg D = d ∧ ∀ v, (m : ℤ) ≤ D v := by
  classical
  obtain ⟨v₀⟩ := ‹Nonempty V›
  refine ⟨fun v => if v = v₀ then (m : ℤ) + (d - (m : ℤ) * (Fintype.card V : ℤ)) else (m : ℤ),
    ?_, ?_⟩
  · have hsplit : deg (fun v => if v = v₀ then (m : ℤ) + (d - (m : ℤ) * (Fintype.card V : ℤ))
        else (m : ℤ))
        = ∑ v : V, ((m : ℤ) + if v = v₀ then d - (m : ℤ) * (Fintype.card V : ℤ) else 0) :=
      Finset.sum_congr rfl fun v _ => by by_cases hv : v = v₀ <;> simp [hv]
    rw [hsplit, Finset.sum_add_distrib]
    simp only [Finset.sum_const, Finset.sum_ite_eq', Finset.mem_univ, if_true,
      Finset.card_univ, nsmul_eq_mul]
    ring
  · intro v
    by_cases hv : v = v₀
    · simp only [if_pos hv]; linarith
    · simp [hv]

/-! ## Regular graphs: the half-canonical degree -/

omit [DecidableEq V] in
/-- For a `k`-regular graph the canonical divisor is the constant `k - 2`. -/
lemma canonical_regular {k : ℕ} (hreg : G.IsRegularOfDegree k) :
    canonical G = fun _ => (k : ℤ) - 2 := by
  funext v
  simp [canonical, hreg v]

omit [DecidableEq V] in
/-- **The half-canonical degree of a `k`-regular graph.**  Twice the degree
`g - 1` equals `(k - 2) n`. -/
theorem two_mul_genus_sub_one_regular {k : ℕ} (hreg : G.IsRegularOfDegree k) :
    2 * (genus G - 1) = ((k : ℤ) - 2) * (Fintype.card V : ℤ) := by
  have h := deg_canonical G
  rw [canonical_regular G hreg] at h
  have hc : deg (fun _ : V => (k : ℤ) - 2) = ((k : ℤ) - 2) * (Fintype.card V : ℤ) := by
    unfold deg
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    ring
  rw [hc] at h
  linarith

/-- **Unconditional half-canonical existence with rank `2⌊(k-2)/2⌋`.**  Every
simple `k`-regular graph with `k ≥ 4` — with *no* hypothesis on the number of
vertices — carries a divisor of the half-canonical degree `g - 1` whose
Baker–Norine rank is at least `2⌊(k-2)/2⌋`. -/
theorem exists_halfCanonical_rank_regular [Nonempty V] {k : ℕ} (hreg : G.IsRegularOfDegree k)
    (hk : 4 ≤ k) :
    ∃ D : Divisor V, deg D = genus G - 1 ∧ RankAtLeast G D (2 * ((k - 2) / 2)) := by
  classical
  set m : ℕ := (k - 2) / 2 with hm
  have hmk : 2 * m ≤ k - 2 := by omega
  have hm1 : 1 ≤ m := by omega
  have hmk' : (2 * m : ℤ) ≤ (k : ℤ) - 2 := by
    have : (2 * m : ℕ) ≤ k - 2 := hmk
    have hcast : ((2 * m : ℕ) : ℤ) ≤ ((k - 2 : ℕ) : ℤ) := by exact_mod_cast this
    rw [Nat.cast_sub (by omega)] at hcast
    push_cast at hcast ⊢
    linarith
  have hn : (0 : ℤ) ≤ (Fintype.card V : ℤ) := by positivity
  have hle : (m : ℤ) * (Fintype.card V : ℤ) ≤ genus G - 1 := by
    have h2 := two_mul_genus_sub_one_regular G hreg
    nlinarith
  obtain ⟨D, hdeg, hDge⟩ := exists_deg_forall_ge (V := V) m (genus G - 1) hle
  refine ⟨D, hdeg, ?_⟩
  have hkdeg : ∀ v, k ≤ G.degree v := fun v => (hreg v).ge
  have hmk2 : m ≤ k := by omega
  have := rankAtLeast_add_of_forall_le G (k := k) (m := m) (t := m) hkdeg hDge le_rfl hmk2
  simpa [two_mul] using this

/-- **Half-canonical existence for even regular degree.**  If `k` is even and
`k ≥ 4`, every simple `k`-regular graph carries a divisor of degree `g - 1` with
Baker–Norine rank at least `k - 2`, one unit short of the conjectural `k - 1`,
and again with no hypothesis on the number of vertices. -/
theorem exists_halfCanonical_rank_regular_even [Nonempty V] {j : ℕ}
    (hreg : G.IsRegularOfDegree (2 * j)) (hj : 2 ≤ j) :
    ∃ D : Divisor V, deg D = genus G - 1 ∧ RankAtLeast G D (2 * j - 2) := by
  obtain ⟨D, hdeg, hrank⟩ := exists_halfCanonical_rank_regular G hreg (by omega)
  refine ⟨D, hdeg, ?_⟩
  have : 2 * ((2 * j - 2) / 2) = 2 * j - 2 := by omega
  rwa [this] at hrank

/-! ## The obstruction to pointwise arguments -/

omit [DecidableEq V] in
/-- **No uniform witness at the half-canonical degree.**  On a `k`-regular graph
a divisor of degree `g - 1` can never carry `r` chips on *every* vertex once
`k - 2 < 2r`.  In particular (taking `r = k - 1`, which satisfies this for every
`k`) the conjectural rank-`(k-1)` witnesses cannot be certified by pointwise
domination: any proof must genuinely move chips. -/
theorem no_uniform_halfCanonical_witness [Nonempty V] {k r : ℕ}
    (hreg : G.IsRegularOfDegree k) (h : (k : ℤ) - 2 < 2 * r) :
    ¬ ∃ D : Divisor V, deg D = genus G - 1 ∧ ∀ v, (r : ℤ) ≤ D v := by
  rintro ⟨D, hdeg, hD⟩
  have hn : (1 : ℤ) ≤ (Fintype.card V : ℤ) := by
    exact_mod_cast Nat.one_le_iff_ne_zero.mpr Fintype.card_ne_zero
  have hsum : (r : ℤ) * (Fintype.card V : ℤ) ≤ deg D := by
    have : ∑ _v : V, (r : ℤ) ≤ ∑ v : V, D v := Finset.sum_le_sum fun v _ => hD v
    simpa [deg, Finset.card_univ, mul_comm] using this
  have h2 := two_mul_genus_sub_one_regular G hreg
  rw [hdeg] at hsum
  nlinarith

omit [DecidableEq V] in
/-- The rank obtained in `exists_halfCanonical_rank_regular` is exactly twice the
best rank obtainable from pointwise domination alone: no divisor of degree `g - 1`
has more than `⌊(k-2)/2⌋` chips on every vertex. -/
theorem no_uniform_halfCanonical_witness_succ [Nonempty V] {k : ℕ}
    (hreg : G.IsRegularOfDegree k) :
    ¬ ∃ D : Divisor V, deg D = genus G - 1 ∧ ∀ v, (((k - 2) / 2 + 1 : ℕ) : ℤ) ≤ D v := by
  refine no_uniform_halfCanonical_witness G hreg ?_
  omega

/-! ## The Brill–Noether number at the half-canonical degree -/

/-- The Brill–Noether number `ρ = g - (r+1)(g - d + r)` of a linear system of
degree `d` and rank `r` on a curve (or graph) of genus `g`. -/
def bnNumber (g d r : ℤ) : ℤ := g - (r + 1) * (g - d + r)

/-- At the half-canonical degree `d = g - 1` the Brill–Noether number collapses to
`g - (r+1)²`. -/
theorem bnNumber_halfCanonical (g r : ℤ) : bnNumber g (g - 1) r = g - (r + 1) ^ 2 := by
  unfold bnNumber; ring

omit [DecidableEq V] in
/-- **Exact positivity criterion for the Brill–Noether number of a regular graph**
at degree `g - 1` and rank `k - 1`: the number is at least one exactly when
`2k² ≤ (k-2)n`. -/
theorem bnNumber_regular_pos_iff {k : ℕ} (hreg : G.IsRegularOfDegree k) :
    1 ≤ bnNumber (genus G) (genus G - 1) ((k : ℤ) - 1) ↔
      2 * (k : ℤ) ^ 2 ≤ ((k : ℤ) - 2) * (Fintype.card V : ℤ) := by
  rw [bnNumber_halfCanonical]
  have h2 := two_mul_genus_sub_one_regular G hreg
  constructor <;> intro h <;> nlinarith

omit [DecidableEq V] in
/-- **The quadratic threshold is numerically sufficient.**  For `k ≥ 3`, a
`k`-regular graph on at least `2k²` vertices has a positive Brill–Noether number
at degree `g - 1` and rank `k - 1`. -/
theorem bnNumber_regular_pos_of_quadratic_threshold {k : ℕ} (hreg : G.IsRegularOfDegree k)
    (hk : 3 ≤ k) (hn : 2 * k ^ 2 ≤ Fintype.card V) :
    1 ≤ bnNumber (genus G) (genus G - 1) ((k : ℤ) - 1) := by
  rw [bnNumber_regular_pos_iff G hreg]
  have hk' : (3 : ℤ) ≤ (k : ℤ) := by exact_mod_cast hk
  have hn' : 2 * (k : ℤ) ^ 2 ≤ (Fintype.card V : ℤ) := by exact_mod_cast hn
  nlinarith

omit [DecidableEq V] in
/-- **A linear threshold already removes the numerical obstruction.**  For `k ≥ 5`
a `k`-regular graph on at least `2k + 7` vertices has a positive Brill–Noether
number at degree `g - 1` and rank `k - 1`.  Since `2k + 7 ≤ 2k²` for `k ≥ 3`, the
quadratic scale of the conjectured threshold is not forced by the numerics. -/
theorem bnNumber_regular_pos_of_linear_threshold {k : ℕ} (hreg : G.IsRegularOfDegree k)
    (hk : 5 ≤ k) (hn : 2 * k + 7 ≤ Fintype.card V) :
    1 ≤ bnNumber (genus G) (genus G - 1) ((k : ℤ) - 1) := by
  rw [bnNumber_regular_pos_iff G hreg]
  have hk' : (5 : ℤ) ≤ (k : ℤ) := by exact_mod_cast hk
  have hn' : 2 * (k : ℤ) + 7 ≤ (Fintype.card V : ℤ) := by exact_mod_cast hn
  nlinarith

/-- The linear threshold `2k + 7` is below the quadratic threshold `2k²` for
every `k ≥ 3`. -/
theorem linear_threshold_le_quadratic {k : ℕ} (hk : 3 ≤ k) : 2 * k + 7 ≤ 2 * k ^ 2 := by
  nlinarith

end BrillNoetherHalfCanonical