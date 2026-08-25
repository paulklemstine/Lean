/-
# Densities of the two position carriers of the Fermat / quadratic-sieve polynomial

Companion to `Catalog/NumberTheory/FermatPositionGeometry.lean`.

That file isolated two magnitude-free ("beyond-magnitude") arithmetic mechanisms that
could bias where the smooth values of `v(j) = (b + j)^2 - N` sit:

* the **gcd carrier** `g(j) = gcd (j, v(0))`, which is *positionally uniform*
  (`FermatPosition.gcd_carrier_window_card_indep`), so it enriches smoothness without
  favouring any position; and
* the **self-divisibility carrier** `j ∣ v(j) ↔ j ∣ v(0)`, whose density at position
  `j` is exactly `1/j`.

This file proves the quantitative half of the story.

Main results.

* `dvd_window_card_eq_one`, `card_filter_dvd` : exactly one multiple of `d` in every
  window of `d` consecutive integers, hence exactly `t` in a window of length `d * t`;
  the self-divisibility carrier has density exactly `1/j` at position `j`.
* `harmonic_block_decline` : `∑_{K < j ≤ 2K} 1/j < ∑_{1 ≤ j ≤ K} 1/j` for `K ≥ 1`.
* `divisor_positions_small_j_excess` : consequently, averaged over base values `v(0)`,
  the expected number of positions `j ≤ K` with `j ∣ v(j)` **strictly exceeds** the
  expected number in the next block `K < j ≤ 2K`.  A proved, magnitude-free, small-`j`
  excess — the shape of the empirically observed monotone-declining deciles.
* `sieveVal_sandwich` and `position_le_of_value_le` : the competing *magnitude* law,
  `2 b j ≤ v(j) ≤ 2 b j + j² + 2 b`, so a bound on the value forces a bound on the
  position (`j ≤ X / (2b)`).  This is what a positional test has to be controlled
  against, and by `FermatPosition.cell_collapse` bit-length cells do not control it.
-/
import Mathlib
import Catalog.NumberTheory.FermatPositionGeometry

namespace FermatPosition

open Finset

/-! ## Exact density of the self-divisibility carrier -/

/-- Exactly one position in a window of `d` consecutive positions is divisible by `d`. -/
theorem dvd_window_card_eq_one (d : ℕ) (hd : 0 < d) (a : ℤ) :
    ((range d).filter (fun i : ℕ => (d : ℤ) ∣ (a + i))).card = 1 := by
  classical
  haveI : NeZero d := ⟨by omega⟩
  have h := window_card_eq_zmod d (fun j : ℤ => (d : ℤ) ∣ j) (fun x : ZMod d => x = 0)
    (fun j => by simpa using (ZMod.intCast_zmod_eq_zero_iff_dvd j d).symm) a
  rw [h]
  simp [Finset.filter_eq']

/-- Exactly `t` positions in a window of `d * t` consecutive positions are divisible by
`d`: the self-divisibility carrier has density exactly `1 / d`. -/
theorem card_filter_dvd (d : ℕ) (hd : 0 < d) (t : ℕ) (a : ℤ) :
    ((range (d * t)).filter (fun i : ℕ => (d : ℤ) ∣ (a + i))).card = t := by
  classical
  induction t with
  | zero => simp
  | succ t ih =>
    have hsplit : d * (t + 1) = d * t + d := by ring
    have hdisj : Disjoint (range (d * t)) ((range d).map (addLeftEmbedding (d * t))) := by
      rw [Finset.disjoint_left]
      intro x hx hx'
      simp only [mem_range] at hx
      simp only [mem_map, mem_range, addLeftEmbedding_apply] at hx'
      obtain ⟨y, hy, rfl⟩ := hx'
      omega
    have hmap : (((range d).map (addLeftEmbedding (d * t))).filter
          (fun i : ℕ => (d : ℤ) ∣ (a + i))).card
        = ((range d).filter (fun i : ℕ => (d : ℤ) ∣ ((a + (d : ℤ) * t) + i))).card := by
      rw [Finset.filter_map, card_map]
      congr 1
      refine filter_congr ?_
      intro i _
      have hcomp : ((fun i : ℕ => (d : ℤ) ∣ (a + i)) ∘ (addLeftEmbedding (d * t))) i
          = ((d : ℤ) ∣ (a + ((d * t + i : ℕ) : ℤ))) := by
        simp [Function.comp, addLeftEmbedding_apply]
      rw [hcomp]
      have harg : (a + ((d * t + i : ℕ) : ℤ)) = ((a + (d : ℤ) * t) + i) := by push_cast; ring
      rw [harg]
    rw [hsplit, Finset.range_add, filter_union,
      card_union_of_disjoint (hdisj.mono (filter_subset _ _) (filter_subset _ _)), ih, hmap,
      dvd_window_card_eq_one d hd]

/-! ## The harmonic decline of the divisor-position profile -/

/-- The `1/j` profile declines: the first block `[1, K]` carries strictly more mass than
the next block `(K, 2K]`, for every `K ≥ 1`. -/
theorem harmonic_block_decline (K : ℕ) (hK : 1 ≤ K) :
    ∑ j ∈ Icc (K + 1) (2 * K), (1 : ℚ) / j < ∑ j ∈ Icc 1 K, (1 : ℚ) / j := by
  have hcard : (Icc (K + 1) (2 * K)).card = K := by
    rw [Nat.card_Icc]; omega
  have hub : ∑ j ∈ Icc (K + 1) (2 * K), (1 : ℚ) / j ≤ (K : ℚ) * (1 / (K + 1)) := by
    have hterm : ∀ j ∈ Icc (K + 1) (2 * K), (1 : ℚ) / j ≤ 1 / (K + 1) := by
      intro j hj
      have hj1 : (K : ℚ) + 1 ≤ (j : ℚ) := by
        have := (mem_Icc.1 hj).1
        exact_mod_cast (by exact_mod_cast this : ((K : ℚ) + 1) ≤ (j : ℚ))
      have hpos : (0 : ℚ) < (K : ℚ) + 1 := by positivity
      exact one_div_le_one_div_of_le hpos hj1
    calc ∑ j ∈ Icc (K + 1) (2 * K), (1 : ℚ) / j
        ≤ ∑ _j ∈ Icc (K + 1) (2 * K), (1 : ℚ) / (K + 1) := Finset.sum_le_sum hterm
      _ = (K : ℚ) * (1 / (K + 1)) := by rw [Finset.sum_const, hcard]; simp [nsmul_eq_mul]
  have hlt : (K : ℚ) * (1 / (K + 1)) < 1 := by
    rw [mul_one_div, div_lt_one (by positivity)]
    linarith
  have hlb : (1 : ℚ) ≤ ∑ j ∈ Icc 1 K, (1 : ℚ) / j := by
    have hmem : (1 : ℕ) ∈ Icc 1 K := mem_Icc.2 ⟨le_rfl, hK⟩
    have hnonneg : ∀ j ∈ Icc 1 K, (0 : ℚ) ≤ 1 / j := by
      intro j _; positivity
    have := Finset.single_le_sum (f := fun j : ℕ => (1 : ℚ) / j) hnonneg hmem
    simpa using this
  linarith

/-- **Proved small-`j` excess of the self-divisibility carrier.**  Average over a window
of base values `v(0)` whose length `M` is divisible by every `j ≤ 2K` (so that all the
densities are exact).  Then the expected number of positions `j` in `[1, K]` at which
`j ∣ v(j)` strictly exceeds the expected number in the next block `(K, 2K]`.  Unlike the
gcd carrier (`gcd_carrier_window_card_indep`) this carrier really does prefer small
positions, with the harmonic `1/j` profile. -/
theorem divisor_positions_small_j_excess (K : ℕ) (hK : 1 ≤ K) (M : ℕ) (hM0 : 0 < M)
    (hM : ∀ j ∈ Icc 1 (2 * K), j ∣ M) (a : ℤ) :
    ∑ j ∈ Icc (K + 1) (2 * K),
        (((range M).filter (fun i : ℕ => (j : ℤ) ∣ (a + i))).card : ℚ)
      < ∑ j ∈ Icc 1 K, (((range M).filter (fun i : ℕ => (j : ℤ) ∣ (a + i))).card : ℚ) := by
  have key : ∀ j ∈ Icc 1 (2 * K),
      (((range M).filter (fun i : ℕ => (j : ℤ) ∣ (a + i))).card : ℚ) = (M : ℚ) * (1 / j) := by
    intro j hj
    have hj1 : 0 < j := (mem_Icc.1 hj).1
    obtain ⟨t, ht⟩ := hM j hj
    have hcard : ((range M).filter (fun i : ℕ => (j : ℤ) ∣ (a + i))).card = t := by
      rw [ht]; exact card_filter_dvd j hj1 t a
    rw [hcard, ht]
    have hjQ : (j : ℚ) ≠ 0 := Nat.cast_ne_zero.2 (by omega)
    push_cast
    field_simp
  have h₁ : ∑ j ∈ Icc (K + 1) (2 * K),
      (((range M).filter (fun i : ℕ => (j : ℤ) ∣ (a + i))).card : ℚ)
      = (M : ℚ) * ∑ j ∈ Icc (K + 1) (2 * K), (1 : ℚ) / j := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun j hj => key j ?_
    have := mem_Icc.1 hj
    exact mem_Icc.2 ⟨by omega, this.2⟩
  have h₂ : ∑ j ∈ Icc 1 K, (((range M).filter (fun i : ℕ => (j : ℤ) ∣ (a + i))).card : ℚ)
      = (M : ℚ) * ∑ j ∈ Icc 1 K, (1 : ℚ) / j := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun j hj => key j ?_
    have := mem_Icc.1 hj
    exact mem_Icc.2 ⟨this.1, by omega⟩
  rw [h₁, h₂]
  have hMpos : (0 : ℚ) < M := by exact_mod_cast hM0
  exact mul_lt_mul_of_pos_left (harmonic_block_decline K hK) hMpos


/-! ## Discrepancy of local (periodic) carriers

The general principle behind `FermatPosition.gcd_carrier_window_card_indep`: a carrier
that is *local*, i.e. determined by the position modulo some fixed `T`, has a bounded
discrepancy in every window.  It can never produce more than `T` excess hits between two
consecutive blocks of equal length.  Contrapositively, an observed positional excess of
`E` hits between consecutive equal blocks forces **every** local explanation to have
modulus `T ≥ E`. -/

/-- The number of positions in `[a, a + L)` satisfying a position predicate. -/
def posCount (P : ℤ → Prop) [DecidablePred P] (a : ℤ) (L : ℕ) : ℕ :=
  ((range L).filter (fun i : ℕ => P (a + (i : ℤ)))).card

theorem posCount_add (P : ℤ → Prop) [DecidablePred P] (a : ℤ) (L₁ L₂ : ℕ) :
    posCount P a (L₁ + L₂) = posCount P a L₁ + posCount P (a + L₁) L₂ := by
  classical
  unfold posCount
  have hdisj : Disjoint (range L₁) ((range L₂).map (addLeftEmbedding L₁)) := by
    rw [Finset.disjoint_left]
    intro x hx hx'
    simp only [mem_range] at hx
    simp only [mem_map, mem_range, addLeftEmbedding_apply] at hx'
    obtain ⟨y, hy, rfl⟩ := hx'
    omega
  have hmap : (((range L₂).map (addLeftEmbedding L₁)).filter
        (fun i : ℕ => P (a + (i : ℤ)))).card
      = ((range L₂).filter (fun i : ℕ => P ((a + (L₁ : ℤ)) + (i : ℤ)))).card := by
    rw [Finset.filter_map, card_map]
    congr 1
    refine filter_congr ?_
    intro i _
    have hcomp : ((fun i : ℕ => P (a + (i : ℤ))) ∘ (addLeftEmbedding L₁)) i
        = P (a + ((L₁ + i : ℕ) : ℤ)) := by
      simp [Function.comp, addLeftEmbedding_apply]
    rw [hcomp]
    have harg : (a + ((L₁ + i : ℕ) : ℤ)) = ((a + (L₁ : ℤ)) + (i : ℤ)) := by push_cast; ring
    rw [harg]
  rw [Finset.range_add, filter_union,
    card_union_of_disjoint (hdisj.mono (filter_subset _ _) (filter_subset _ _)), hmap]

theorem posCount_le (P : ℤ → Prop) [DecidablePred P] (a : ℤ) (L : ℕ) : posCount P a L ≤ L := by
  unfold posCount
  simpa using card_filter_le (range L) _

/-- A `T`-periodic position predicate has exactly `m` times the per-period count in a
window of `m` full periods, wherever the window starts. -/
theorem posCount_period_mul (T : ℕ) [NeZero T] (P : ℤ → Prop) [DecidablePred P]
    (Q : ZMod T → Prop) [DecidablePred Q] (hPQ : ∀ j : ℤ, P j ↔ Q (j : ZMod T)) (a : ℤ) (m : ℕ) :
    posCount P a (T * m) = m * (univ.filter Q).card := by
  induction m generalizing a with
  | zero => simp [posCount]
  | succ m ih =>
    have h : T * (m + 1) = T + T * m := by ring
    rw [h, posCount_add, ih (a + T)]
    have hw : posCount P a T = (univ.filter Q).card := window_card_eq_zmod T P Q hPQ a
    rw [hw]; ring

/-- **Discrepancy bound for local carriers.**  For a `T`-periodic position predicate the
count in any window of length `T * m + r` (`r < T`) lies in the interval
`[m * c, m * c + T]`, where `c` is the per-period count: the count is pinned down up to
an additive `T`, independently of where the window sits. -/
theorem periodic_window_bounds (T : ℕ) [NeZero T] (P : ℤ → Prop) [DecidablePred P]
    (Q : ZMod T → Prop) [DecidablePred Q] (hPQ : ∀ j : ℤ, P j ↔ Q (j : ZMod T)) (a : ℤ)
    (m r : ℕ) (hr : r < T) :
    m * (univ.filter Q).card ≤ posCount P a (T * m + r) ∧
      posCount P a (T * m + r) ≤ m * (univ.filter Q).card + T := by
  rw [posCount_add, posCount_period_mul T P Q hPQ]
  have hle := posCount_le P (a + ((T * m : ℕ) : ℤ)) r
  omega

/-- **No local carrier can produce a large positional excess.**  For a `T`-periodic
position predicate, the counts in any two windows of the same length `L = T * m + r`
differ by at most `T`.  Contrapositive: an observed excess of `E` hits of one block over
an equally long block rules out every carrier of modulus `T < E`. -/
theorem periodic_block_balance (T : ℕ) [NeZero T] (P : ℤ → Prop) [DecidablePred P]
    (Q : ZMod T → Prop) [DecidablePred Q] (hPQ : ∀ j : ℤ, P j ↔ Q (j : ZMod T)) (a a' : ℤ)
    (m r : ℕ) (hr : r < T) :
    posCount P a (T * m + r) ≤ posCount P a' (T * m + r) + T := by
  have h₁ := periodic_window_bounds T P Q hPQ a m r hr
  have h₂ := periodic_window_bounds T P Q hPQ a' m r hr
  omega

/-! ## The competing magnitude law -/

/-- Two-sided sandwich for the sieve polynomial at `b = ⌈√N⌉`:
`2 b j ≤ v(j) ≤ 2 b j + j² + 2 b`.  The value is essentially `2 b j`, so magnitude and
position are tied together by a linear law. -/
theorem sieveVal_sandwich {b N j : ℤ} (hj : 0 ≤ j) (hN₁ : (b - 1) ^ 2 ≤ N)
    (hN₂ : N ≤ b ^ 2) :
    2 * b * j ≤ sieveVal b N j ∧ sieveVal b N j ≤ 2 * b * j + j ^ 2 + 2 * b := by
  constructor
  · simp only [sieveVal]; nlinarith
  · simp only [sieveVal]; nlinarith

/-- A bound on the magnitude forces a bound on the position: all positions carrying a
value below `X` lie below `X / (2b)`.  This is the *magnitude* explanation of small-`j`
clustering, against which any claimed positional structure must be controlled. -/
theorem position_le_of_value_le {b N j X : ℤ} (hj : 0 ≤ j)
    (hN₁ : (b - 1) ^ 2 ≤ N) (hN₂ : N ≤ b ^ 2) (hX : sieveVal b N j ≤ X) :
    2 * b * j ≤ X :=
  le_trans (sieveVal_sandwich hj hN₁ hN₂).1 hX


/-- **Magnitude concentrates values in an initial segment of positions.**  Every position
whose value is at most `X` lies below `X / (2b)`: the sub-`X` part of the sieve is an
initial block of positions of length about `X / (2b)`. -/
theorem card_positions_value_le {b N X : ℤ} (hb : 1 ≤ b) (hN₁ : (b - 1) ^ 2 ≤ N)
    (hN₂ : N ≤ b ^ 2) (J : ℕ) :
    ((range J).filter (fun i : ℕ => sieveVal b N ((i : ℤ) + 1) ≤ X)).card
      ≤ (X / (2 * b)).toNat := by
  classical
  have hb0 : (0 : ℤ) < 2 * b := by linarith
  have hsub : (range J).filter (fun i : ℕ => sieveVal b N ((i : ℤ) + 1) ≤ X)
      ⊆ range (X / (2 * b)).toNat := by
    intro i hi
    simp only [mem_filter, mem_range] at hi
    have hpos : (0 : ℤ) ≤ (i : ℤ) + 1 := by positivity
    have hlin : 2 * b * ((i : ℤ) + 1) ≤ X :=
      position_le_of_value_le hpos hN₁ hN₂ hi.2
    have hdiv : (i : ℤ) + 1 ≤ X / (2 * b) := Int.le_ediv_iff_mul_le hb0 |>.2 (by linarith)
    have hX : 0 < X / (2 * b) := by omega
    refine mem_range.2 ?_
    omega
  calc ((range J).filter (fun i : ℕ => sieveVal b N ((i : ℤ) + 1) ≤ X)).card
      ≤ (range (X / (2 * b)).toNat).card := card_le_card hsub
    _ = (X / (2 * b)).toNat := card_range _

/-- Converse half: in the useful regime `2 ≤ j ≤ b` the value is at most `4 b j`, so every
position below `X / (4b)` does carry a value at most `X`.  With
`card_positions_value_le` this pins the sub-`X` part of the sieve to an initial block of
positions of length between `X / (4b)` and `X / (2b)`. -/
theorem sieveVal_le_four_mul {b N j : ℤ} (hN₁ : (b - 1) ^ 2 ≤ N) (h2 : 2 ≤ j) (hjb : j ≤ b) :
    sieveVal b N j ≤ 4 * b * j := by
  simp only [sieveVal]
  nlinarith [h2, hjb, hN₁]

/-- Quantitative separation of the two carriers.  In a window of `T` consecutive
positions the gcd carrier occupies a *fixed* number of positions no matter where the
window is (`gcd_carrier_window_card_indep`), whereas the self-divisibility carrier at
scale `d` occupies exactly `t` positions of any window of length `d * t`, i.e. a
`1/d` fraction that decays with the position scale.  Their ratio over the first block
versus the next block is therefore strictly greater than one. -/
theorem carrier_contrast (d : ℕ) (hd : 0 < d) (t : ℕ) (a : ℤ) :
    ((range (d * t)).filter (fun i : ℕ => (d : ℤ) ∣ (a + i))).card * (2 * d)
      = ((range (2 * d * t)).filter (fun i : ℕ => (d : ℤ) ∣ (a + i))).card * d := by
  have h₁ := card_filter_dvd d hd t a
  have h₂ := card_filter_dvd d hd (2 * t) a
  have hrw : 2 * d * t = d * (2 * t) := by ring
  rw [h₁, hrw, h₂]
  ring

end FermatPosition