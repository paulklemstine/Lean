/-
# U065 — The divisibility-mixture baseline for `v = j² − N`

Setting (paper 232 / 241 mechanism probe).  In a Fermat/quadratic-sieve style scan one
tests the values `v = j² − N` for `B`-smoothness while `j` runs over a window and `N` is
*fixed*.  A naive baseline treats `v` as a random integer of its size, so a small prime
`p` divides `v` with density `1/p` and the smoothness probability is the Dickman value
`ρ(log v / log B)`.

The arithmetic truth is different: for an odd prime `p`,

  `p ∣ j² − N  ↔  j² ≡ N  (mod p)`,

so the density of hits is `#{x : ZMod p | x² = N} / p`, which is `2/p` when `N` is a
non-zero square mod `p`, `0` when it is a non-residue, and `1/p` when `p ∣ N`.  Averaged
over `N` this reproduces the naive `1/p`, but the *per-N* rate is a two-point mixture.
Because the smoothness functional is convex in the divisibility rates, the mixture
average strictly exceeds the value at the mean rate; this is the "divisibility-mixture
baseline" the experiment routes the observed hump to.

This file proves the exact algebra of that mixture:

* `rootCount_cast` — the root count is `χ_p(a) + 1`;
* `sum_rootCount` — mean root count `1` (the mixture matches the naive baseline in mean);
* `sum_sq_rootCount_sub_one` — the exact variance identity `∑ₐ (X(a) − 1)² = p − 1`;
* `sum_pow_rootCount` — the exact generating identity
  `∑ₐ c^X(a) = p·c + (p−1)(c−1)²/2`, i.e. the mixture exceeds the naive baseline `p·c`
  by a term *quadratic* in the deviation `c − 1`;
* `one_lt_excessRatio` — strict excess for every `c > 0`, `c ≠ 1`;
* `sum_prod_pow_rootCount` / `mixture_excess_multi` — the multi-prime (independent by CRT)
  product law and its strict excess.

The quadratic form of the excess is the formal counterpart of the empirical finding that
*no single binary covariate* carries the hump: the effect is a second-order (variance)
effect of the divisibility structure, not a first-order shift.  See
`U065NoSingleCarrier.lean` for the quantitative removal bound.
-/
import Mathlib

namespace U065

open Finset

/-- `rootCount p a` is the number of square roots of `a` in `ZMod p`; equivalently the
number of residues `j (mod p)` with `p ∣ j² − a`. -/
noncomputable def rootCount (p : ℕ) [Fact p.Prime] (a : ZMod p) : ℕ :=
  (Finset.univ.filter (fun x : ZMod p => x ^ 2 = a)).card

variable {p : ℕ} [Fact p.Prime]

lemma ringChar_ne_two (hp : p ≠ 2) : ringChar (ZMod p) ≠ 2 := by
  rw [ZMod.ringChar_zmod_n]; exact hp

/-- Odd primes are at least `3` (as a real bound, for the estimates below). -/
lemma three_le_cast (hp : p ≠ 2) : (3 : ℝ) ≤ p := by
  have h := (Fact.out (p := p.Prime)).two_le
  have h3 : 3 ≤ p := by omega
  exact_mod_cast h3

/-- The number of square roots of `a` mod `p` equals `χ_p(a) + 1`. -/
theorem rootCount_cast (hp : p ≠ 2) (a : ZMod p) :
    (rootCount p a : ℤ) = quadraticChar (ZMod p) a + 1 := by
  have := quadraticChar_card_sqrts (F := ZMod p) (ringChar_ne_two hp) a
  rw [← this]
  simp [rootCount, Set.toFinset_setOf]

/-- `rootCount p a` counts exactly the residues `j` with `p ∣ j² − a`. -/
theorem rootCount_eq_card_dvd (a : ZMod p) :
    rootCount p a = (Finset.univ.filter (fun x : ZMod p => x ^ 2 - a = 0)).card := by
  simp [rootCount, sub_eq_zero]

@[simp] lemma rootCount_zero : rootCount p (0 : ZMod p) = 1 := by
  simp [rootCount, pow_eq_zero_iff, Finset.filter_eq']

/-- For `a ≠ 0` the root count is `0` (non-residue) or `2` (residue): the per-`N`
divisibility rate is a genuine two-point mixture. -/
theorem rootCount_eq_zero_or_two (hp : p ≠ 2) {a : ZMod p} (ha : a ≠ 0) :
    rootCount p a = 0 ∨ rootCount p a = 2 := by
  have h := rootCount_cast hp a
  rcases quadraticChar_dichotomy (F := ZMod p) ha with hq | hq <;> rw [hq] at h
  · right; omega
  · left; omega

/-- Total root count over all targets is `p`: the mixture has *mean rate* `1/p`,
matching the naive random-integer baseline exactly. -/
theorem sum_rootCount (hp : p ≠ 2) : ∑ a : ZMod p, rootCount p a = p := by
  have hcard : (Finset.univ : Finset (ZMod p)).card = p := ZMod.card p
  have h : ((∑ a : ZMod p, rootCount p a : ℕ) : ℤ) = (p : ℤ) := by
    push_cast
    simp only [rootCount_cast hp]
    rw [Finset.sum_add_distrib, quadraticChar_sum_zero (ringChar_ne_two hp)]
    simp [hcard]
  exact_mod_cast h

/-- **Exact variance identity.**  The squared deviation of the per-`N` root count from
the naive baseline `1` sums to `p − 1`: the mixture is maximally over-dispersed while
having the correct mean. -/
theorem sum_sq_rootCount_sub_one (hp : p ≠ 2) :
    ∑ a : ZMod p, ((rootCount p a : ℤ) - 1) ^ 2 = (p : ℤ) - 1 := by
  have hcard : (Finset.univ : Finset (ZMod p)).card = p := ZMod.card p
  have hstep : ∀ a : ZMod p, ((rootCount p a : ℤ) - 1) ^ 2
      = (quadraticChar (ZMod p) a) ^ 2 := by
    intro a; rw [rootCount_cast hp]; ring
  simp only [hstep]
  have h0 : ∀ a : ZMod p, (quadraticChar (ZMod p) a) ^ 2
      = 1 - (if a = 0 then (1 : ℤ) else 0) := by
    intro a
    by_cases ha : a = 0
    · simp [ha]
    · simp only [ha, if_false, sub_zero]
      rcases quadraticChar_dichotomy (F := ZMod p) ha with h | h <;> rw [h] <;> ring
  simp only [h0]
  rw [Finset.sum_sub_distrib, Finset.sum_ite_eq' Finset.univ (0 : ZMod p) (fun _ => (1 : ℤ))]
  simp [hcard]

/-- **Exact mixture identity for an arbitrary functional.**  For every `g : ℕ → ℝ`,

`∑_{N mod p} g(#{j mod p : p ∣ j² − N}) = g 1 + (p−1)·(g 2 + g 0)/2`.

The whole mixture collapses to the three values `g 0, g 1, g 2` weighted by the
quadratic-residue split: one target with a double root, `(p−1)/2` residues with two
roots and `(p−1)/2` non-residues with none. -/
theorem sum_apply_rootCount (hp : p ≠ 2) (g : ℕ → ℝ) :
    ∑ a : ZMod p, g (rootCount p a) = g 1 + ((p : ℝ) - 1) * (g 2 + g 0) / 2 := by
  classical
  have hcard : (Finset.univ : Finset (ZMod p)).card = p := ZMod.card p
  have hsplit : ∑ a : ZMod p, g (rootCount p a)
      = g (rootCount p (0 : ZMod p)) +
        ∑ a ∈ Finset.univ.erase (0 : ZMod p), g (rootCount p a) :=
    (Finset.add_sum_erase _ _ (Finset.mem_univ _)).symm
  -- On the punctured set the functional is *affine* in the quadratic character.
  have hpt : ∀ a ∈ Finset.univ.erase (0 : ZMod p),
      g (rootCount p a)
        = (g 2 + g 0) / 2 + ((quadraticChar (ZMod p) a : ℤ) : ℝ) * ((g 2 - g 0) / 2) := by
    intro a ha
    have ha0 : a ≠ 0 := (Finset.mem_erase.mp ha).1
    have h := rootCount_cast hp a
    rcases quadraticChar_dichotomy (F := ZMod p) ha0 with hq | hq <;> rw [hq] at h ⊢
    · have h2 : rootCount p a = 2 := by omega
      rw [h2]; push_cast; ring
    · have h2 : rootCount p a = 0 := by omega
      rw [h2]; push_cast; ring
  have hsumchi : ∑ a ∈ Finset.univ.erase (0 : ZMod p),
      ((quadraticChar (ZMod p) a : ℤ) : ℝ) = 0 := by
    have htot : ∑ a : ZMod p, ((quadraticChar (ZMod p) a : ℤ) : ℝ) = 0 := by
      have := quadraticChar_sum_zero (F := ZMod p) (ringChar_ne_two hp)
      exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) this
    have hs := (Finset.add_sum_erase (Finset.univ) (fun a : ZMod p =>
      ((quadraticChar (ZMod p) a : ℤ) : ℝ)) (Finset.mem_univ (0 : ZMod p))).symm
    rw [hs, quadraticChar_zero] at htot
    simpa using htot
  have hcarderase : (Finset.univ.erase (0 : ZMod p)).card = p - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ _), hcard]
  have hp1 : 1 ≤ p := (Fact.out (p := p.Prime)).one_lt.le.trans' (by norm_num)
  rw [hsplit, Finset.sum_congr rfl hpt, Finset.sum_add_distrib, ← Finset.sum_mul, hsumchi,
    rootCount_zero, Finset.sum_const, hcarderase, nsmul_eq_mul, Nat.cast_sub hp1]
  push_cast
  ring

/-- **Exact mixture generating identity.**  For every real `c`,

`∑_{N mod p} c ^ #{j mod p : p ∣ j² − N} = p·c + (p−1)(c−1)²/2`.

The first term is the naive (Dickman-style) baseline, obtained by giving every `N` the
mean rate; the second is the mixture excess, *quadratic* in the deviation `c − 1`. -/
theorem sum_pow_rootCount (hp : p ≠ 2) (c : ℝ) :
    ∑ a : ZMod p, c ^ (rootCount p a) = (p : ℝ) * c + ((p : ℝ) - 1) * (c - 1) ^ 2 / 2 := by
  have h := sum_apply_rootCount hp (fun n => c ^ n)
  rw [h]
  ring

/-- The mixture excess factor at parameter `c`: the mixture average divided by the naive
baseline average `p·c`. -/
noncomputable def excessRatio (p : ℕ) [Fact p.Prime] (c : ℝ) : ℝ :=
  (∑ a : ZMod p, c ^ (rootCount p a)) / ((p : ℝ) * c)

/-- Closed form of the excess factor: `1 + (1 − 1/p)(c−1)²/(2c)`. -/
theorem excessRatio_eq (hp : p ≠ 2) {c : ℝ} (hc : 0 < c) :
    excessRatio p c = 1 + ((p : ℝ) - 1) * (c - 1) ^ 2 / (2 * p * c) := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast (Fact.out (p := p.Prime)).pos
  rw [excessRatio, sum_pow_rootCount hp c]
  field_simp

/-- **Strict mixture excess (one prime).**  For every `c > 0` with `c ≠ 1` the
divisibility mixture strictly beats the naive baseline. -/
theorem one_lt_excessRatio (hp : p ≠ 2) {c : ℝ} (hc : 0 < c) (hc1 : c ≠ 1) :
    1 < excessRatio p c := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast (Fact.out (p := p.Prime)).pos
  have hp3 := three_le_cast hp
  rw [excessRatio_eq hp hc]
  have hsq : (0 : ℝ) < (c - 1) ^ 2 := pow_two_pos_of_ne_zero (sub_ne_zero.mpr hc1)
  have hnum : 0 < ((p : ℝ) - 1) * (c - 1) ^ 2 := by nlinarith
  have hden : (0 : ℝ) < 2 * p * c := by positivity
  have := div_pos hnum hden
  linarith

/-- Positivity of the mixture average (used for the multi-prime product). -/
theorem sum_pow_rootCount_pos (hp : p ≠ 2) {c : ℝ} (hc : 0 < c) :
    0 < ∑ a : ZMod p, c ^ (rootCount p a) := by
  have hp3 := three_le_cast hp
  rw [sum_pow_rootCount hp c]
  nlinarith [sq_nonneg (c - 1)]

section MultiPrime

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- **Independence law.**  Over the product of residue systems — isomorphic to
`ZMod (∏ qᵢ)` by the Chinese remainder theorem — the multiplicative smoothness proxy
factorises over the primes. -/
theorem sum_prod_pow_rootCount (q : ι → ℕ) [∀ i, Fact (q i).Prime] (c : ι → ℝ) :
    ∑ N ∈ Fintype.piFinset (fun i => (Finset.univ : Finset (ZMod (q i)))),
        ∏ i, (c i) ^ (rootCount (q i) (N i))
      = ∏ i, ∑ a : ZMod (q i), (c i) ^ (rootCount (q i) a) := by
  rw [Finset.prod_univ_sum]

/-- **Strict multi-prime excess.**  With odd primes and any non-trivial weights the
divisibility mixture strictly exceeds the naive baseline `∏ qᵢ·cᵢ`. -/
theorem mixture_excess_multi (q : ι → ℕ) [∀ i, Fact (q i).Prime]
    (hq : ∀ i, q i ≠ 2) (c : ι → ℝ) (hc : ∀ i, 0 < c i) (hc1 : ∀ i, c i ≠ 1)
    [Nonempty ι] :
    (∏ i, ((q i : ℝ) * c i))
      < ∑ N ∈ Fintype.piFinset (fun i => (Finset.univ : Finset (ZMod (q i)))),
          ∏ i, (c i) ^ (rootCount (q i) (N i)) := by
  rw [sum_prod_pow_rootCount]
  refine Finset.prod_lt_prod_of_nonempty (fun i _ => ?_) (fun i _ => ?_) Finset.univ_nonempty
  · have hq0 : (0 : ℝ) < q i := by exact_mod_cast (Fact.out (p := (q i).Prime)).pos
    exact mul_pos hq0 (hc i)
  · have h := one_lt_excessRatio (p := q i) (hq i) (hc i) (hc1 i)
    have hq0 : (0 : ℝ) < q i := by exact_mod_cast (Fact.out (p := (q i).Prime)).pos
    have hpos : (0 : ℝ) < (q i : ℝ) * c i := mul_pos hq0 (hc i)
    rw [excessRatio, lt_div_iff₀ hpos] at h
    linarith

end MultiPrime

end U065