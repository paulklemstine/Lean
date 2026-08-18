import Probability.PRNGSeedRecovery

/-!
# LFSR fingerprinting, seed recovery, and the rarity of low linear complexity

This file instantiates the abstract seed-compressibility framework of
`Probability.PRNGSeedRecovery` at the most important PRNG family: the
**linear feedback shift register** of length `L` over a commutative ring `K`
(over `ZMod 2` this is the classical binary LFSR that Berlekamp–Massey attacks).

The state is a window `σ : Fin L → K`; the machine outputs `σ 0` and shifts,
refilling the last cell with the feedback `∑ j, c j * σ j`.

Main contents.

* `lfsrStep`, `lfsrPRNG` — the shift register as a `PRNG`.
* `lfsr_state_apply` — the **window lemma**: cell `i` of the state after `k`
  steps is the output at time `i + k`.  All later results rest on it.
* `lfsr_recurrence` — the generated stream satisfies the order-`L` linear
  recurrence: the *fingerprint* of the family.
* `lfsr_detect` — **detection is exact**: a stream is LFSR output for the tap
  vector `c` *iff* it satisfies the recurrence.  This is soundness *and*
  completeness of the fingerprint test.
* `lfsr_pref_eq_self`, `lfsr_pref_injective` — **seed recovery**: the first `L`
  output symbols literally *are* the seed, and the seed is unique.
* `lfsr_exact_reproduction` — the falsifiability gate: the recovered seed
  regenerates the whole stream, at every index, not just the observed window.
* `card_lfsrWords_le`, `exists_not_lfsrWord` — **rarity**: at most `|K|^(2L)` of
  the `|K|ⁿ` files have linear complexity `≤ L`, so for `n > 2L` most files are
  *not* seed-compressible by any LFSR of that order.
-/

namespace Catalog.Probability.SeedRec

variable {K : Type*} [CommRing K] {L : ℕ}

/-- One clock tick of a Fibonacci LFSR with tap vector `c`: shift left, and put
the feedback `∑ j, c j * σ j` into the vacated last cell. -/
def lfsrStep (c : Fin L → K) (σ : Fin L → K) : Fin L → K := fun i =>
  if h : (i : ℕ) + 1 < L then σ ⟨(i : ℕ) + 1, h⟩ else ∑ j : Fin L, c j * σ j

/-- The output tap of the register: the oldest cell (and `0` for the empty
register, so that the definition needs no positivity instance). -/
def lfsrOut (σ : Fin L → K) : K := if h : 0 < L then σ ⟨0, h⟩ else 0

/-- The LFSR with tap vector `c`, as a pseudorandom generator. -/
def lfsrPRNG (c : Fin L → K) : PRNG (Fin L → K) K :=
  ⟨lfsrStep c, lfsrOut⟩

variable [NeZero L]

omit [NeZero L] in
/-- **Window lemma.** After `k` clock ticks, cell `i` of the register holds the
symbol that will be output at time `i + k`. -/
theorem lfsr_state_apply (c : Fin L → K) (σ : Fin L → K) :
    ∀ (i : ℕ) (h : i < L) (k : ℕ),
      ((lfsrStep c)^[k] σ) ⟨i, h⟩ = (lfsrPRNG c).stream σ (i + k) := by
  intro i
  induction i with
  | zero =>
      intro h k
      simp only [PRNG.stream, lfsrPRNG, lfsrOut, Nat.zero_add, dif_pos h]
  | succ i ih =>
      intro h k
      have h1 : i < L := by omega
      have hstep : ((lfsrStep c)^[k] σ) ⟨i + 1, h⟩ = ((lfsrStep c)^[k + 1] σ) ⟨i, h1⟩ := by
        rw [Function.iterate_succ_apply']
        show _ = lfsrStep c ((lfsrStep c)^[k] σ) ⟨i, h1⟩
        simp only [lfsrStep]
        rw [dif_pos (show (⟨i, h1⟩ : Fin L).val + 1 < L from h)]
      rw [hstep, ih h1 (k + 1), show i + (k + 1) = i + 1 + k from by omega]

omit [NeZero L] in
/-- The seed is read off the first `L` outputs: output `k < L` is cell `k` of the seed. -/
theorem lfsr_stream_lt (c : Fin L → K) (σ : Fin L → K) (k : ℕ) (h : k < L) :
    (lfsrPRNG c).stream σ k = σ ⟨k, h⟩ := by
  simpa using (lfsr_state_apply c σ k h 0).symm

/-- **Fingerprint.** Every LFSR stream satisfies its order-`L` linear recurrence. -/
theorem lfsr_recurrence (c : Fin L → K) (σ : Fin L → K) (t : ℕ) :
    (lfsrPRNG c).stream σ (t + L)
      = ∑ j : Fin L, c j * (lfsrPRNG c).stream σ (t + (j : ℕ)) := by
  obtain ⟨m, hm⟩ : ∃ m, L = m + 1 := ⟨L - 1, by have := NeZero.ne L; omega⟩
  have hmL : m < L := by omega
  have h1 : ((lfsrStep c)^[t + 1] σ) ⟨m, hmL⟩ = (lfsrPRNG c).stream σ (t + L) := by
    rw [lfsr_state_apply c σ m hmL (t + 1), show m + (t + 1) = t + L from by omega]
  have h2 : ((lfsrStep c)^[t + 1] σ) ⟨m, hmL⟩
      = ∑ j : Fin L, c j * ((lfsrStep c)^[t] σ) j := by
    rw [Function.iterate_succ_apply']
    show lfsrStep c ((lfsrStep c)^[t] σ) ⟨m, hmL⟩ = _
    simp only [lfsrStep]
    rw [dif_neg (show ¬ ((⟨m, hmL⟩ : Fin L).val + 1 < L) from by simp; omega)]
  rw [← h1, h2]
  refine Finset.sum_congr rfl ?_
  intro j _
  rw [lfsr_state_apply c σ (j : ℕ) j.isLt t, show (j : ℕ) + t = t + (j : ℕ) from by omega]

/-- The predicate a fingerprinting detector tests: `y` obeys the order-`L`
linear recurrence with taps `c`. -/
def SatisfiesLFSR (c : Fin L → K) (y : ℕ → K) : Prop :=
  ∀ t, y (t + L) = ∑ j : Fin L, c j * y (t + (j : ℕ))

theorem satisfiesLFSR_stream (c : Fin L → K) (σ : Fin L → K) :
    SatisfiesLFSR c ((lfsrPRNG c).stream σ) := fun t => lfsr_recurrence c σ t

/-- **Detection is exact (soundness and completeness of the fingerprint).**
A stream is produced by the LFSR with taps `c` if and only if it satisfies the
associated linear recurrence; and in that case the seed is the observed window
`fun i => y i`. -/
theorem lfsr_detect (c : Fin L → K) (y : ℕ → K) :
    SatisfiesLFSR c y ↔ ∃ σ : Fin L → K, ∀ t, (lfsrPRNG c).stream σ t = y t := by
  constructor
  · intro hy
    refine ⟨fun i => y (i : ℕ), ?_⟩
    intro t
    induction t using Nat.strong_induction_on with
    | _ t ih =>
        by_cases ht : t < L
        · rw [lfsr_stream_lt c _ t ht]
        · obtain ⟨t', rfl⟩ : ∃ t', t = t' + L := ⟨t - L, by omega⟩
          rw [lfsr_recurrence c _ t', hy t']
          refine Finset.sum_congr rfl ?_
          intro j _
          rw [ih (t' + (j : ℕ)) (by have := j.isLt; omega)]
  · rintro ⟨σ, hσ⟩ t
    have h := lfsr_recurrence c σ t
    simp only [hσ] at h
    exact h

omit [NeZero L] in
/-- **Seed recovery.** The length-`L` prefix of the output *is* the seed. -/
theorem lfsr_pref_eq_self (c : Fin L → K) (σ : Fin L → K) :
    (lfsrPRNG c).pref L σ = σ := by
  funext i
  simpa using lfsr_stream_lt c σ (i : ℕ) i.isLt

omit [NeZero L] in
/-- The recovered seed is unique: distinct seeds give distinct length-`L` windows. -/
theorem lfsr_pref_injective (c : Fin L → K) :
    Function.Injective ((lfsrPRNG c).pref L) := by
  intro σ τ h
  rwa [lfsr_pref_eq_self, lfsr_pref_eq_self] at h

/-- **Falsifiability gate.** If a stream passes the order-`L` fingerprint test,
the seed read off its first `L` symbols regenerates it *exactly*, at every index. -/
theorem lfsr_exact_reproduction (c : Fin L → K) (y : ℕ → K) (hy : SatisfiesLFSR c y) :
    ∀ t, (lfsrPRNG c).stream (fun i : Fin L => y i.val) t = y t := by
  obtain ⟨σ, hσ⟩ := (lfsr_detect c y).1 hy
  have hs : σ = fun i : Fin L => y i.val := by
    funext i
    rw [← hσ i.val, lfsr_stream_lt c σ i.val i.isLt]
  intro t
  rw [← hs]
  exact hσ t

omit [NeZero L] in
/-- Every length-`L` window is realised by a seed: the fingerprint test never
rejects on account of the initial data. -/
theorem lfsr_surjective_pref (c : Fin L → K) (x : Fin L → K) :
    SeedCompressible (lfsrPRNG c) L x :=
  ⟨x, lfsr_pref_eq_self c x⟩

section Counting

variable (K L)
variable [Fintype K] [DecidableEq K]

/-- The set of length-`n` files of linear complexity `≤ L`: those generated by
*some* order-`L` LFSR from *some* seed. -/
def lfsrWords (n : ℕ) : Finset (Fin n → K) :=
  Finset.univ.image fun p : (Fin L → K) × (Fin L → K) => (lfsrPRNG p.1).pref n p.2

omit [NeZero L] in
theorem mem_lfsrWords {n : ℕ} {x : Fin n → K} :
    x ∈ lfsrWords K L n ↔ ∃ c σ : Fin L → K, (lfsrPRNG c).pref n σ = x := by
  simp [lfsrWords, Prod.exists]

omit [NeZero L] in
/-- **Rarity of low linear complexity.** At most `|K|^(2L)` files of length `n`
are LFSR-generated at order `L`: `L` taps plus `L` seed symbols is all the
information such a file carries. -/
theorem card_lfsrWords_le (n : ℕ) :
    (lfsrWords K L n).card ≤ Fintype.card K ^ (2 * L) := by
  classical
  refine (Finset.card_image_le).trans ?_
  simp [Finset.card_univ, two_mul, pow_add]

omit [NeZero L] in
/-- Consequently, once `n > 2L` (and `|K| ≥ 2`) some file is **not**
seed-compressible by any order-`L` LFSR: the pigeonhole bound is not beaten. -/
theorem exists_not_lfsrWord (n : ℕ) (hK : 2 ≤ Fintype.card K) (hn : 2 * L < n) :
    ∃ x : Fin n → K, x ∉ lfsrWords K L n := by
  classical
  have hlt : Fintype.card K ^ (2 * L) < Fintype.card K ^ n :=
    Nat.pow_lt_pow_right (by omega) hn
  by_contra hc
  push_neg at hc
  have hsub : (Finset.univ : Finset (Fin n → K)) ⊆ lfsrWords K L n := fun x _ => hc x
  have := Finset.card_le_card hsub
  rw [Finset.card_univ, Fintype.card_fun, Fintype.card_fin] at this
  exact absurd (this.trans (card_lfsrWords_le K L n)) (by omega)

omit [NeZero L] in
/-- Density form: the fraction of length-`n` files that any order-`L` LFSR can
produce is at most `|K|^(2L)/|K|^n`, an exponentially small false-positive rate
for the fingerprint classifier on uniformly random data. -/
theorem lfsrWords_density_le (n : ℕ) (hK : 0 < Fintype.card K) :
    ((lfsrWords K L n).card : ℚ) / (Fintype.card K : ℚ) ^ n
      ≤ (Fintype.card K : ℚ) ^ (2 * L) / (Fintype.card K : ℚ) ^ n := by
  have hcard : (0 : ℚ) < (Fintype.card K : ℚ) := by exact_mod_cast hK
  have hpos : (0 : ℚ) < (Fintype.card K : ℚ) ^ n := by positivity
  gcongr
  exact_mod_cast card_lfsrWords_le K L n

end Counting

end Catalog.Probability.SeedRec