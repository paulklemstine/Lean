import Mathlib

/-!
# Majority-Vote Decoding for the Quantum Repetition Code

This file formalises the combinatorial core of the simplest NISQ error-mitigation
strategy: **majority voting over circuit repetitions**.  A logical bit `b : Bool`
is measured `n` times, producing a noisy readout `s : Fin n → Bool`.  The decoder
returns the majority value.  We prove the exact correctness threshold: the
decoder recovers `b` whenever fewer than half of the readouts are corrupted, and
that this `n/2` threshold is tight.

This is the "logic" half of the Phase-A bridge `Logic ↔ Algebraic Topology`:
here error patterns are measured by their *Hamming weight*; in the companion
file `PersistentH0.lean` they are measured by a *topological invariant*
(the zeroth persistent Betti number).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Majority voting over `n` repetitions corrects any
  error pattern of Hamming weight strictly below `n/2`, and this bound is sharp.
Experiment (Experimenter): Counted the readout vector against the true bit by
  splitting `Finset.univ` into the agreeing and disagreeing positions; `ones s`
  equals either `n - err` or `err` depending on the parity of the true bit `b`.
Analysis (Analyst): The proof reduces to a single `linarith`/`omega` once the two
  filter cardinalities are related by `Finset.card_add_card_compl`.  The `Bool`
  case split is essential: the relation between `ones` and `err` flips with `b`.
  The naive iff `majority = b ↔ 2*err < n` is FALSE for `b = false` at the tie
  `2*err = n` (the strict `>` tie-break favours `false`), so the iff is stated
  only for the `true` codeword.
Critique (Critic): Guard against vacuity — `majority_threshold_tight` exhibits an
  explicit even-length counterexample at weight exactly `n/2`, proving the
  threshold is sharp and the guarantee non-vacuous.
Synthesis (PI): A one-sided correctness guarantee, a clean iff for the `true`
  codeword, and a sharpness witness.
-/

namespace TopoErrorMitigation

open Finset

variable {n : ℕ}

/-- Number of `true` readouts. -/
def ones (s : Fin n → Bool) : ℕ := (univ.filter (fun i => s i = true)).card

/-- Number of corrupted readouts relative to the true bit `b`. -/
def errors (s : Fin n → Bool) (b : Bool) : ℕ := (univ.filter (fun i => s i ≠ b)).card

/-- The majority decoder: returns `true` when strictly more than half of the
readouts are `true`. -/
def majority (s : Fin n → Bool) : Bool := decide (2 * ones s > n)

/-- **Repetition-code correctness.** If strictly fewer than half of the readouts
are corrupted, majority voting recovers the true bit. -/
theorem majority_decode_correct (s : Fin n → Bool) (b : Bool)
    (h : 2 * errors s b < n) : majority s = b := by
  cases b <;> simp_all +decide [majority, errors]
  · exact le_of_lt h
  · unfold ones
    have := Finset.card_add_card_compl (Finset.filter (fun i => s i = false) Finset.univ)
    norm_num at *
    linarith

/-- **Exact threshold (iff form) for the `true` codeword.** Because the decoder
breaks ties with a strict `>` (favouring `false`), the clean biconditional holds
for the all-`true` logical bit: majority voting returns `true` iff strictly fewer
than half of the readouts are corrupted. (For `b = false` the implication
`2 * errors < n → majority = false` still holds by `majority_decode_correct`,
but its converse fails exactly at the tie `2 * errors = n`.) -/
theorem majority_decode_correct_iff (s : Fin n → Bool) :
    majority s = true ↔ 2 * errors s true < n := by
  unfold majority errors
  unfold ones
  simp +decide
  constructor <;> intro h <;>
    have := Finset.card_add_card_compl (Finset.filter (fun i => s i = true) Finset.univ) <;>
    norm_num at * <;> omega

/-- **Tightness of the `n/2` threshold.** For every positive `k`, on length
`n = 2*k` there is a readout with exactly `k` errors (half corrupted) on which
the decoder fails to return the true bit `true`. -/
theorem majority_threshold_tight (k : ℕ) (hk : 0 < k) :
    ∃ s : Fin (2 * k) → Bool, errors s true = k ∧ majority s ≠ true := by
  refine ⟨fun i ↦ if i.val < k then true else false, ?_, ?_⟩ <;>
    simp +decide [majority, errors, ones]
  · rw [Finset.card_eq_of_bijective]
    use fun i hi => ⟨i + k, by linarith⟩
    · simp +zetaDelta at *
      exact fun a ha => ⟨a - k, by rw [tsub_lt_iff_left ha]; linarith [Fin.is_lt a],
        by erw [Fin.ext_iff]; simp +decide [Nat.sub_add_cancel ha]⟩
    · grind
    · aesop
  · exact le_trans (Finset.card_le_card
      (show Finset.filter (fun x : Fin (2 * k) => (x : ℕ) < k) Finset.univ
          ⊆ Finset.Iio ⟨k, by linarith⟩ from
        fun x hx => Finset.mem_Iio.mpr <| Finset.mem_filter.mp hx |>.2))
      (by simp +decide)

end TopoErrorMitigation