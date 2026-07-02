/-
# The singleton incoherence spectrum is exactly the divisor lattice

A direct sequel to `OrderSpectrum.lean`, which it **imports and reuses**.  There we
proved the order formula `incoherenceIndex ({a}) = addOrderOf a` and that every
divisor of `n` is realized by a singleton frame.  Here we close the loop with the
converse (Lagrange) and read off the exact spectrum of singleton frames:

* `singleton_index_dvd` — every singleton incoherence index divides `n`
  (`addOrderOf a ∣ |ZMod n| = n`).
* `singleton_spectrum_eq_divisors` — the set of incoherence indices achievable by
  *singleton* frames on `ZMod n` is **exactly** the set of divisors of `n`.
* `order_formula_defeats_fragment` — a clean re-derivation of the catalog's
  non-finite-axiomatization separator straight from the order formula: for every
  bound `B`, the maximal frame `{1} ⊆ ZMod (B+1)` has index `B+1 > B`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  Conjecture: singleton frames cannot realize arbitrary
indices — they are pinned to the divisor lattice of `n` by Lagrange — whereas the
realization direction (`OrderSpectrum.divisor_index_realized`) shows every divisor
*is* hit.  Hence the singleton spectrum is precisely `{d : d ∣ n}`.

EXPERIMENT (Experimenter).  Combine `incoherenceIndex_singleton` with
`addOrderOf_dvd_card` and `ZMod.card` for the `⊆` inclusion; feed
`divisor_index_realized` for `⊇`.  Set-extensionality then yields the equality.
The fragment separator reuses `incoherenceIndex_singleton_one'` directly.

ANALYSIS (Analyst).  True and provable.  Structural pattern: the divisor lattice is
the complete invariant of singleton frames, sharply complementing
`OrderSpectrum.incoherenceIndex_oneTwo_zmod5`, where a *two-atom* frame realizes the
non-divisor index `3` on `ZMod 5`.  So enriching the atom set is exactly what breaks
out of the divisor lattice.

CRITIQUE (Critic).  Guards: `singleton_spectrum_eq_divisors` is proved by genuine
`Set.ext` with both inclusions discharged by real lemmas (no `decide`); the
imported results are used non-trivially; `order_formula_defeats_fragment` exhibits a
concrete maximal witness with a computed, strictly-separating index.

SYNTHESIS (PI).  Together with `OrderSpectrum`, the incoherence spectrum is fully
classified at the singleton level (= divisors of `n`) and shown to be strictly
enlarged by multi-atom frames — the structural completion of the saturation
contrast and the engine of non-finite-axiomatization.  See `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--
-/
import Applications.SocialChoice.OrderSpectrum

namespace SocialChoice

open scoped BigOperators

/-
**Lagrange bound.** Every singleton incoherence index divides `n`: by the order
formula it equals `addOrderOf a`, which divides the group order `|ZMod n| = n`.
-/
theorem singleton_index_dvd {n : ℕ} [NeZero n] (a : ZMod n) :
    incoherenceIndex ({a} : Frame n) ∣ n := by
  convert Nat.dvd_of_mod_eq_zero _;
  rw [ incoherenceIndex_singleton, Nat.mod_eq_zero_of_dvd ];
  rw [ addOrderOf_dvd_iff_nsmul_eq_zero ];
  simp +decide [ nsmul_eq_mul ]

/-
**Singleton spectrum.** The incoherence indices realized by singleton frames on
`ZMod n` are exactly the divisors of `n`.  (`⊆` is Lagrange, `⊇` is the divisor
realization from `OrderSpectrum`.)
-/
theorem singleton_spectrum_eq_divisors {n : ℕ} [NeZero n] :
    {d : ℕ | ∃ a : ZMod n, incoherenceIndex ({a} : Frame n) = d} = {d : ℕ | d ∣ n} := by
  ext d;
  constructor;
  · rintro ⟨ a, rfl ⟩ ; exact singleton_index_dvd a;
  · intro hd;
    use n / d;
    rw [ incoherenceIndex_singleton ];
    convert ZMod.addOrderOf_coe ( n / d ) ( NeZero.ne n ) using 1;
    rw [ Nat.gcd_eq_right ( Nat.div_dvd_of_dvd hd ), Nat.div_div_self hd ( NeZero.ne n ) ]

/-
**Order-formula non-finite-axiomatization.** For every finite bound `B`, the
maximal frame `{1} ⊆ ZMod (B+1)` has incoherence index `B+1`, strictly exceeding
`B`.  Hence no width-`B` fragment can certify coherence — a one-line consequence of
the order formula.
-/
theorem order_formula_defeats_fragment (B : ℕ) :
    ∃ (n : ℕ) (F : Frame n), IsMaximal F ∧ B < incoherenceIndex F := by
  -- Use `n = B+1` and `F = {1}`. It is maximal by `isMaximal_singleton_one (B+1)` (with `NeZero (B+1)`). Its incoherence index is `B+1` by version `incoherenceIndex_singleton_one' (B+1)`, and `B < B+1`.
  use B + 1, {1}
  constructor
  · exact isMaximal_singleton_one (B + 1)
  · exact by
      rw [incoherenceIndex_singleton_one' (B + 1)]
      omega

end SocialChoice