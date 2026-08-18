import Probability.PRNGLFSRDetection

/-!
# Linear congruential generators are order-two LFSRs

The second most common real-world PRNG family after the LFSR is the **linear
congruential generator** `x ↦ a*x + b` (`rand()`, `java.util.Random`, countless
game engines).  Superficially it is an affine map on a ring, not a shift
register over a field, so a fingerprinting pipeline would seem to need a
separate detector and a separate inversion routine.

The main theorem of this file says otherwise: *the full-output LCG stream
satisfies the order-two linear recurrence*
`x_{t+2} = (a+1) x_{t+1} - a x_t`,
so the **same** Berlekamp–Massey style detector that catches LFSRs catches
LCGs, and the seed `(x₀, a x₀ + b)` is recovered from two observed symbols.

Main contents.

* `lcgPRNG`, `lcg_stream_succ` — the LCG as a `PRNG` and its defining recursion.
* `lcg_satisfiesLFSR` — the fingerprint: the LCG stream obeys the order-`2`
  recurrence with taps `![-a, a+1]`.
* `lcg_seed_recovery` — the explicit order-`2` LFSR seed `![x₀, a x₀ + b]`
  reproduces the LCG stream **exactly** at every index.
* `lcg_detected` — an LCG stream always passes the order-`2` fingerprint test.
* `card_lcgWords_le`, `exists_not_lcgWord` — the LCG family covers at most
  `|K|³` files of each length, so almost no file is LCG-compressible.
-/

namespace Catalog.Probability.SeedRec

variable {K : Type*} [CommRing K]

/-- The linear congruential generator `x ↦ a*x + b`, outputting its full state. -/
def lcgPRNG (a b : K) : PRNG K K := ⟨fun x => a * x + b, id⟩

@[simp] theorem lcg_stream_zero (a b x0 : K) : (lcgPRNG a b).stream x0 0 = x0 := rfl

theorem lcg_stream_succ (a b x0 : K) (t : ℕ) :
    (lcgPRNG a b).stream x0 (t + 1) = a * (lcgPRNG a b).stream x0 t + b := by
  simp [PRNG.stream, lcgPRNG, Function.iterate_succ_apply']

/-- **Cross-family fingerprint.** The LCG stream satisfies the order-two linear
recurrence `x_{t+2} = (a+1) x_{t+1} - a x_t`; equivalently it is an LFSR stream
for the tap vector `![-a, a+1]`. -/
theorem lcg_satisfiesLFSR (a b x0 : K) :
    SatisfiesLFSR ![-a, a + 1] ((lcgPRNG a b).stream x0) := by
  intro t
  have h1 := lcg_stream_succ a b x0 t
  have h2 := lcg_stream_succ a b x0 (t + 1)
  have ht : t + 2 = t + 1 + 1 := by omega
  simp only [Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one,
    Fin.val_zero, Fin.val_one, Nat.add_zero, ht]
  rw [h2, h1]
  ring

/-- An LCG stream passes the order-two fingerprint test: it is genuinely an
order-two LFSR stream. -/
theorem lcg_detected (a b x0 : K) :
    ∃ σ : Fin 2 → K, ∀ t, (lfsrPRNG ![-a, a + 1]).stream σ t = (lcgPRNG a b).stream x0 t :=
  (lfsr_detect _ _).1 (lcg_satisfiesLFSR a b x0)

/-- **Seed recovery for LCGs, with exact reproduction.** Two observed symbols
determine the equivalent LFSR seed `![x₀, a x₀ + b]`, and that seed regenerates
the LCG stream at *every* index — the falsifiability gate for the LCG family. -/
theorem lcg_seed_recovery (a b x0 : K) :
    ∀ t, (lfsrPRNG ![-a, a + 1]).stream ![x0, a * x0 + b] t = (lcgPRNG a b).stream x0 t := by
  have key := lfsr_exact_reproduction ![-a, a + 1] ((lcgPRNG a b).stream x0)
    (lcg_satisfiesLFSR a b x0)
  have hseed : (fun i : Fin 2 => (lcgPRNG a b).stream x0 i.val) = ![x0, a * x0 + b] := by
    funext i
    fin_cases i
    · simp [lcgPRNG]
    · simpa using lcg_stream_succ a b x0 0
  rwa [hseed] at key

section Counting

variable (K) [Fintype K] [DecidableEq K]

/-- The length-`n` files producible by *some* LCG over `K` from *some* seed. -/
def lcgWords (n : ℕ) : Finset (Fin n → K) :=
  Finset.univ.image fun p : K × K × K => (lcgPRNG p.1 p.2.1).pref n p.2.2

theorem mem_lcgWords {n : ℕ} {x : Fin n → K} :
    x ∈ lcgWords K n ↔ ∃ a b x0 : K, (lcgPRNG a b).pref n x0 = x := by
  simp [lcgWords, Prod.exists]

/-- The whole LCG family over `K` produces at most `|K|³` files of any given
length: multiplier, increment and seed are all it knows. -/
theorem card_lcgWords_le (n : ℕ) : (lcgWords K n).card ≤ Fintype.card K ^ 3 := by
  refine Finset.card_image_le.trans ?_
  simp [Finset.card_univ, pow_succ, mul_comm]

/-- For `n ≥ 4` and `|K| ≥ 2`, some file of length `n` is produced by no LCG at
all: LCG-based seed compression covers a vanishing fraction of files. -/
theorem exists_not_lcgWord (n : ℕ) (hK : 2 ≤ Fintype.card K) (hn : 3 < n) :
    ∃ x : Fin n → K, x ∉ lcgWords K n := by
  have hlt : Fintype.card K ^ 3 < Fintype.card K ^ n := Nat.pow_lt_pow_right (by omega) hn
  by_contra hc
  push_neg at hc
  have hsub : (Finset.univ : Finset (Fin n → K)) ⊆ lcgWords K n := fun x _ => hc x
  have hcard := Finset.card_le_card hsub
  rw [Finset.card_univ, Fintype.card_fun, Fintype.card_fin] at hcard
  exact absurd (hcard.trans (card_lcgWords_le K n)) (by omega)

end Counting

end Catalog.Probability.SeedRec