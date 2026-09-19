import Mathlib

/-!
# The quadratic-sieve pool: exact first moment, maximal zero-lag variance, random pair correlation

Context (FACT round-26 #3, "SUBEXP-STRATUM", paper 90, finding 2).  The
experiment found that the smoothness of the sieve values `x^2 - N` is *not* the
smoothness of a random integer at toy scale: even against a correctly integrated
Dickman `ρ`, the empirical ratios scattered non-monotonically (`0.26`–`9.3`).
The suspected mechanism is the quadratic-character constraint on the prime
divisors of `x^2 - N`, whose `O(1)` corrections "stabilise only asymptotically".

The catalog already proves the *first-moment* half of this story
(`Shared.QSRelationPoolRandom`): averaged over the residue of `N` mod `p`, the
number of `x` per period with `p ∣ x^2 - N` is exactly `1`, the same as for a
random integer sequence.  That identity explains why the pool looks random *on
average* — and it is exactly why it cannot explain the observed scatter.

This file computes the next two invariants of the same hit pattern

`h_p(a) = #{x ∈ ZMod p | x^2 = a}` (the number of hits per period when `N ≡ a`),

and finds a sharp dichotomy:

* **zero lag**: `∑_a (h_p(a) - 1)^2 = p - 1`, i.e. the mean square deviation from
  the random model is `1 - 1/p`, which *does not decay* — it increases to `1`.
  The pool is maximally dispersed, at every prime, for ever.  This is the exact
  algebraic source of the non-monotone toy-scale ratios: an `O(1)` per-prime
  fluctuation that no amount of growth in `p` removes.
* **nonzero lag**: `∑_a h_p(a) · h_p(a + c) = p - 1` for every `c ≠ 0`, i.e. the
  pair correlation is *exactly* that of the random model (`p` terms averaging
  `1 · 1 = 1`, minus the single degree of freedom `1`).

So the deviation from randomness of the quadratic-sieve hit pattern is
concentrated entirely at lag `0`: `A(0) - A(c) = p` for all `c ≠ 0`.

## Main results

* `hitCount_eq_quadraticChar_add_one` — `h_p(a) = χ_p(a) + 1`.
* `sum_hitCount` — first moment: `∑_a h_p(a) = p`.
* `sum_sq_dev_hitCount` — **`∑_a (h_p(a) - 1)^2 = p - 1`**.
* `sum_sq_hitCount` — `∑_a h_p(a)^2 = 2p - 1`.
* `meanSquareDeviation_eq` — the normalised form `1 - 1/p`, in `ℚ`.
* `meanSquareDeviation_ge_half` — it never drops below `1/2`: no asymptotic
  stabilisation towards the random model in second moment.
* `pair_correlation` — **`∑_a h_p(a) h_p(a+c) = p - 1` for `c ≠ 0`**.
* `autocorrelation_dichotomy` — `∑_a h_p(a)^2 - ∑_a h_p(a) h_p(a+c) = p`.
-/

namespace SubexpStratumMoments

open Finset

variable (p : ℕ) [Fact p.Prime]

/-- `hitCount p a` = the number of `x` in one period mod `p` with `p ∣ x^2 - N`
when `N ≡ a`, i.e. the number of square roots of `a` in `ZMod p`. -/
def hitCount (a : ZMod p) : ℕ := #{x : ZMod p | x ^ 2 = a}

theorem hitCount_def (a : ZMod p) :
    hitCount p a = #(univ.filter (fun x : ZMod p => x ^ 2 = a)) := rfl

/-! ## First moment -/

/-- The total number of hits over a full period of residues is `p`: on average a
prime hits exactly once per period, exactly as for a random integer sequence. -/
theorem sum_hitCount : ∑ a : ZMod p, hitCount p a = p := by
  have h : #(univ : Finset (ZMod p))
      = ∑ a ∈ (univ : Finset (ZMod p)), #(univ.filter fun x : ZMod p => x ^ 2 = a) :=
    Finset.card_eq_sum_card_fiberwise (fun x _ => mem_univ (x ^ 2))
  simpa [hitCount_def, ZMod.card p] using h.symm

/-! ## The quadratic character, and the zero-lag second moment -/

/-- The hit count is `χ(a) + 1` for the quadratic character `χ` of `ZMod p`. -/
theorem hitCount_eq_quadraticChar_add_one (hp : p ≠ 2) (a : ZMod p) :
    (hitCount p a : ℤ) = quadraticChar (ZMod p) a + 1 := by
  have h := quadraticChar_card_sqrts (F := ZMod p)
    ((ZMod.ringChar_zmod_n p).substr hp) a
  simpa [hitCount, Set.toFinset_setOf] using h

/-- **The zero-lag variance identity.**  The total square deviation of the hit
pattern from the random model (constant `1`) is exactly `p - 1`. -/
theorem sum_sq_dev_hitCount (hp : p ≠ 2) :
    ∑ a : ZMod p, ((hitCount p a : ℤ) - 1) ^ 2 = (p : ℤ) - 1 := by
  have hchar : ringChar (ZMod p) ≠ 2 := (ZMod.ringChar_zmod_n p).substr hp
  have hterm : ∀ a : ZMod p, ((hitCount p a : ℤ) - 1) ^ 2
      = if a = 0 then (0 : ℤ) else 1 := by
    intro a
    rw [hitCount_eq_quadraticChar_add_one p hp a]
    by_cases ha : a = 0
    · simp [ha]
    · have h1 : quadraticChar (ZMod p) a ^ 2 = 1 := quadraticChar_sq_one ha
      simp only [ha, if_false]
      linear_combination h1
  rw [Finset.sum_congr rfl (fun a _ => hterm a)]
  have hsplit : ∀ a : ZMod p, (if a = 0 then (0 : ℤ) else 1)
      = 1 - (if a = 0 then (1 : ℤ) else 0) := by
    intro a; split <;> ring
  simp only [hsplit, Finset.sum_sub_distrib, Finset.sum_const,
    Finset.sum_ite_eq' univ (0 : ZMod p) (fun _ => (1 : ℤ)), mem_univ, if_true,
    Finset.card_univ, ZMod.card p]
  simp

/-- `∑_a h(a)^2 = 2p - 1`: combining the first and second moments. -/
theorem sum_sq_hitCount (hp : p ≠ 2) :
    ∑ a : ZMod p, ((hitCount p a : ℤ)) ^ 2 = 2 * (p : ℤ) - 1 := by
  have hdev := sum_sq_dev_hitCount p hp
  have hsum : ∑ a : ZMod p, ((hitCount p a : ℤ)) = (p : ℤ) := by
    exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) (sum_hitCount p)
  have hexp : ∑ a : ZMod p, ((hitCount p a : ℤ) - 1) ^ 2
      = (∑ a : ZMod p, ((hitCount p a : ℤ)) ^ 2)
        - 2 * (∑ a : ZMod p, ((hitCount p a : ℤ))) + (p : ℤ) := by
    have hterm : ∀ a : ZMod p, ((hitCount p a : ℤ) - 1) ^ 2
        = ((hitCount p a : ℤ) ^ 2 - 2 * (hitCount p a : ℤ)) + 1 := by
      intro a; ring
    simp only [hterm, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      Finset.sum_const, Finset.card_univ, ZMod.card p]
    simp
  rw [hexp, hsum] at hdev
  linarith

/-- The normalised mean square deviation from the random model is `1 - 1/p`. -/
theorem meanSquareDeviation_eq (hp : p ≠ 2) :
    (1 / (p : ℚ)) * ∑ a : ZMod p, ((hitCount p a : ℚ) - 1) ^ 2 = 1 - 1 / (p : ℚ) := by
  have hppos : 0 < p := (Fact.out : p.Prime).pos
  have hpne : (p : ℚ) ≠ 0 := Nat.cast_ne_zero.2 hppos.ne'
  have hdev : ∑ a : ZMod p, ((hitCount p a : ℚ) - 1) ^ 2 = (p : ℚ) - 1 := by
    have := sum_sq_dev_hitCount p hp
    have := congrArg (fun z : ℤ => (z : ℚ)) this
    push_cast at this
    simpa using this
  rw [hdev]
  field_simp

/-- The per-prime dispersion of the sieve pool never falls below `1/2`: the
`O(1)` correction does **not** stabilise away. -/
theorem meanSquareDeviation_ge_half (hp : p ≠ 2) :
    (1 : ℚ) / 2 ≤ (1 / (p : ℚ)) * ∑ a : ZMod p, ((hitCount p a : ℚ) - 1) ^ 2 := by
  have hp2 : 2 ≤ p := (Fact.out : p.Prime).two_le
  have hp2' : (2 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp2
  rw [meanSquareDeviation_eq p hp]
  have : 1 / (p : ℚ) ≤ 1 / 2 := by
    apply one_div_le_one_div_of_le (by norm_num) hp2'
  linarith

/-! ## Pair correlation: exactly the random value at every nonzero lag -/

/-- The set of pairs `(x, y)` with `y^2 - x^2 = c`. -/
private def diffPairs (c : ZMod p) : Finset (ZMod p × ZMod p) :=
  univ.filter (fun z : ZMod p × ZMod p => z.2 ^ 2 - z.1 ^ 2 = c)

private theorem card_diffPairs (hp : p ≠ 2) {c : ZMod p} (hc : c ≠ 0) :
    #(diffPairs p c) = p - 1 := by
  have hprime : p.Prime := Fact.out
  have h2 : (2 : ZMod p) ≠ 0 := by
    have : ((2 : ℕ) : ZMod p) ≠ 0 := by
      rw [Ne, ZMod.natCast_eq_zero_iff]
      intro hdvd
      exact hp ((Nat.prime_dvd_prime_iff_eq hprime Nat.prime_two).1 hdvd)
    simpa using this
  classical
  have hbij : #(diffPairs p c) = #((univ : Finset (ZMod p)).erase 0) := by
    apply Finset.card_bij (fun z _ => z.2 - z.1)
    · intro z hz
      simp only [diffPairs, mem_filter, mem_univ, true_and] at hz
      refine Finset.mem_erase.2 ⟨?_, mem_univ _⟩
      intro h0
      apply hc
      have : z.2 = z.1 := by linear_combination h0
      rw [← hz, this]; ring
    · intro z hz w hw hzw
      simp only [diffPairs, mem_filter, mem_univ, true_and] at hz hw
      have hsum : z.2 + z.1 = w.2 + w.1 := by
        have hne : z.2 - z.1 ≠ 0 := by
          intro h0
          apply hc
          have : z.2 = z.1 := by linear_combination h0
          rw [← hz, this]; ring
        have hprod : (z.2 - z.1) * (z.2 + z.1) = (w.2 - w.1) * (w.2 + w.1) := by
          have : z.2 ^ 2 - z.1 ^ 2 = w.2 ^ 2 - w.1 ^ 2 := by rw [hz, hw]
          linear_combination this
        rw [hzw] at hprod hne
        exact mul_left_cancel₀ hne hprod
      have h1 : z.1 = w.1 := by
        have := sub_eq_zero.2 hzw
        have h := sub_eq_zero.2 hsum
        have h2' : (2 : ZMod p) * (z.1 - w.1) = 0 := by linear_combination h - this
        rcases mul_eq_zero.1 h2' with h | h
        · exact absurd h h2
        · linear_combination h
      have h2'' : z.2 = w.2 := by
        have := sub_eq_zero.2 hzw
        have h := sub_eq_zero.2 hsum
        have h3 : (2 : ZMod p) * (z.2 - w.2) = 0 := by linear_combination h + this
        rcases mul_eq_zero.1 h3 with h | h
        · exact absurd h h2
        · linear_combination h
      exact Prod.ext h1 h2''
    · intro u hu
      have hu0 : u ≠ 0 := (Finset.mem_erase.1 hu).1
      refine ⟨((c / u - u) / 2, (c / u + u) / 2), ?_, ?_⟩
      · simp only [diffPairs, mem_filter, mem_univ, true_and]
        field_simp
        ring
      · field_simp
        ring
  rw [hbij, Finset.card_erase_of_mem (mem_univ _), Finset.card_univ, ZMod.card p]

/-- **The pair-correlation identity.**  At every nonzero lag `c`, the hit pattern
of the sieve pool has exactly the correlation of the random model. -/
theorem pair_correlation (hp : p ≠ 2) {c : ZMod p} (hc : c ≠ 0) :
    ∑ a : ZMod p, hitCount p a * hitCount p (a + c) = p - 1 := by
  classical
  have hfib : #(diffPairs p c)
      = ∑ a ∈ (univ : Finset (ZMod p)),
          #((diffPairs p c).filter (fun z : ZMod p × ZMod p => z.1 ^ 2 = a)) :=
    Finset.card_eq_sum_card_fiberwise (fun z _ => mem_univ (z.1 ^ 2))
  have hfiber : ∀ a : ZMod p,
      #((diffPairs p c).filter (fun z : ZMod p × ZMod p => z.1 ^ 2 = a))
        = hitCount p a * hitCount p (a + c) := by
    intro a
    have hset : (diffPairs p c).filter (fun z : ZMod p × ZMod p => z.1 ^ 2 = a)
        = (univ.filter (fun x : ZMod p => x ^ 2 = a)) ×ˢ
          (univ.filter (fun y : ZMod p => y ^ 2 = a + c)) := by
      ext z
      simp only [diffPairs, mem_filter, mem_univ, true_and, Finset.mem_product]
      constructor
      · rintro ⟨hz, ha⟩
        exact ⟨ha, by rw [← ha, ← hz]; ring⟩
      · rintro ⟨h1, h2⟩
        exact ⟨by rw [h1, h2]; ring, h1⟩
    rw [hset, Finset.card_product, hitCount_def, hitCount_def]
  rw [← card_diffPairs p hp hc, hfib]
  exact Finset.sum_congr rfl (fun a _ => (hfiber a).symm)

/-- **The dichotomy.**  All of the pool's deviation from the random model sits at
lag `0`: the zero-lag autocorrelation exceeds every nonzero-lag one by exactly
`p`, i.e. by one full period. -/
theorem autocorrelation_dichotomy (hp : p ≠ 2) {c : ZMod p} (hc : c ≠ 0) :
    (∑ a : ZMod p, ((hitCount p a : ℤ)) ^ 2)
      - ∑ a : ZMod p, (hitCount p a : ℤ) * (hitCount p (a + c) : ℤ) = p := by
  have h1 := sum_sq_hitCount p hp
  have h2 : ∑ a : ZMod p, (hitCount p a : ℤ) * (hitCount p (a + c) : ℤ) = (p : ℤ) - 1 := by
    have h := pair_correlation p hp hc
    have hp1 : 1 ≤ p := (Fact.out : p.Prime).one_le
    have := congrArg (Nat.cast : ℕ → ℤ) h
    push_cast [Nat.cast_sub hp1] at this
    simpa using this
  rw [h1, h2]
  ring

end SubexpStratumMoments