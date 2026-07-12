import Mathlib
import Catalog.Novelty.NeuralCoding

/-!
# Error-Correcting Neural Codes II: the Singleton Bound and Robust Capacity

This file extends the neural-coding theory of `Catalog/Novelty/NeuralCoding.lean`
(raw capacity `2 ^ N`, sparse counts, population precision) with a second,
*information-theoretic* ceiling on how many patterns a noise-tolerant population
can use.  Where `Catalog/Applications/NeuralErrorCorrection.lean` established the
geometric **sphere-packing (Hamming) bound** — each codeword owns a disjoint
Hamming ball — this file proves the complementary and logically independent
**Singleton bound**, which controls capacity through *projection* rather than
*packing*.

## Model

A **neural code** on `N` neurons is a binary activity pattern
`NeuralCode N = Fin N → Bool` (reusing the type from the capacity file).  The
**Hamming distance** between two patterns is the number of neurons on which they
disagree.  A **codebook** is a finite set `C` of patterns whose **minimum
distance** is `d` when any two distinct codewords disagree on at least `d`
neurons; such a codebook still separates its concepts after up to `d - 1`
adversarial neuron flips, and decodes them uniquely after up to `⌊(d-1)/2⌋`.

## Results (the chain)

1. `hamming_le_of_agree` — if two patterns agree on every neuron outside a set
   `S`, their Hamming distance is at most `|S|`.  This is the projection lemma
   underlying everything below.
2. `singleton_bound` — **the Singleton bound.**  A codebook on `N` neurons with
   minimum distance `d ≥ 1` uses at most `2 ^ (N + 1 - d)` patterns.  Proof:
   puncturing any `d - 1` neurons leaves an injective projection of the codebook
   into the remaining `N + 1 - d` neurons (uses 1).
3. `robust_capacity` — **capacity degrades geometrically with noise tolerance.**
   A `t`-error-correcting codebook (minimum distance `≥ 2t + 1`) uses at most
   `2 ^ (N - 2t)` of the `2 ^ N` patterns: each unit of correction guarantee
   costs two neurons of raw capacity (uses 2).
4. `singleton_message_bound` / `singleton_redundancy` — the classical `(N,k,d)`
   inequalities: a codebook carrying `k` message bits has `k ≤ N + 1 - d`, i.e.
   its redundancy `N - k` is at least `d - 1` (uses 2).
5. `full_code_attains_singleton` — the Singleton bound is **tight at `d = 1`**:
   the full pattern set achieves `2 ^ N = 2 ^ (N + 1 - 1)` (uses the capacity
   count `card_neuralCode`).
6. `repetition_attains_singleton` — the Singleton bound is **tight at `d = N`**:
   the two-word repetition code `{silent, all-firing}` has minimum distance `N`
   and `2 = 2 ^ (N + 1 - N)` codewords.  Together with 5 this exhibits tightness
   at both ends of the distance range, so the bound cannot be improved in `N`
   and `d` alone.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the sphere-packing ceiling of the companion file is
not the only obstruction to noise-tolerant capacity.  A code with large minimum
distance must "spread out" so much that projecting away a few neurons already
determines every codeword — a phenomenon of *coordinates*, not of *volume* —
giving a second, geometry-free capacity ceiling `2 ^ (N + 1 - d)`.

Experiment (Experimenter): we reused `NeuralCode N = Fin N → Bool` and Mathlib's
`hammingDist`.  The engine is `hamming_le_of_agree`: agreement off a set `S`
forces the disagreement set inside `S`, hence distance `≤ |S|`.  Puncturing an
arbitrary `(d-1)`-subset (`Finset.exists_subset_card_eq`) and mapping each
codeword to its restriction on the complement is injective on any minimum-distance
`d` codebook, so `|C|` is bounded by the `2 ^ (N + 1 - d)` restrictions
(`Finset.card_le_card_of_injOn`).

Analysis (Analyst): the Singleton and Hamming bounds are genuinely different
ceilings — Singleton is linear-algebraic (projection/rank flavour), Hamming is
metric (packing).  Both specialise to the raw capacity `2 ^ N` at zero noise
tolerance, and the repetition and full codes show Singleton is attained at the
extreme distances, so no bound depending only on `N` and `d` can beat it there.

Critique (Critic): the statement is non-vacuous — the tightness witnesses supply
codebooks that meet it with equality, so it is not a hollow inequality; the
hypotheses `1 ≤ d` and `d ≤ N + 1` are exactly the range in which the exponent
`N + 1 - d` is meaningful, and both are load-bearing (used by `omega` in the
card computation and the projection argument).

Synthesis (PI): capacity under noise is squeezed from two sides — packing volume
(Hamming) and coordinate projection (Singleton) — and the exact exchange rate for
`t`-error correction, `2 ^ N ↦ 2 ^ (N - 2t)`, falls out of the Singleton side
directly.
-/

namespace NeuralCodeSingletonBound

open Finset NeuralCoding

/-- A **neural code** on `N` neurons, reusing the capacity file's type. -/
abbrev NeuralCode (N : ℕ) : Type := NeuralCoding.NeuralCode N

/-! ## 1. The projection lemma -/

/-- **Agreement off `S` bounds the distance.**  If two patterns agree on every
neuron outside a set `S`, they can disagree only inside `S`, so their Hamming
distance is at most `|S|`. -/
theorem hamming_le_of_agree {N : ℕ} (S : Finset (Fin N)) (x y : NeuralCode N)
    (h : ∀ i ∈ Sᶜ, x i = y i) : hammingDist x y ≤ S.card := by
  rw [hammingDist]
  apply Finset.card_le_card
  intro i hi
  simp only [mem_filter, mem_univ, true_and] at hi
  by_contra hiS
  exact hi (h i (by simp [mem_compl, hiS]))

/-! ## 2. The Singleton bound -/

/-- **The Singleton bound.**  A codebook `C` on `N` neurons whose distinct
codewords are pairwise at Hamming distance at least `d` (with `1 ≤ d ≤ N + 1`)
uses at most `2 ^ (N + 1 - d)` patterns.

The proof punctures an arbitrary set `S` of `d - 1` neurons.  Two codewords that
agree on the remaining `N + 1 - d` neurons could differ only inside `S`, hence at
distance `≤ d - 1 < d`, forcing them equal.  So restriction to the unpunctured
neurons is injective on `C`, and there are only `2 ^ (N + 1 - d)` restrictions. -/
theorem singleton_bound {N d : ℕ} (hd : 1 ≤ d) (hdN : d ≤ N + 1)
    (C : Finset (NeuralCode N))
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → d ≤ hammingDist x y) :
    C.card ≤ 2 ^ (N + 1 - d) := by
  -- puncture an arbitrary `(d - 1)`-subset of neurons
  obtain ⟨S, hSsub, hScard⟩ := Finset.exists_subset_card_eq
    (show d - 1 ≤ (univ : Finset (Fin N)).card by rw [card_univ, Fintype.card_fin]; omega)
  -- restriction of a code to the unpunctured neurons `Sᶜ`
  set f : NeuralCode N → ({i // i ∈ Sᶜ} → Bool) := fun c j => c j.1 with hf
  have hinj : Set.InjOn f C := by
    intro x hx y hy hxy
    have hagree : ∀ i ∈ Sᶜ, x i = y i := by
      intro i hi
      have := congrFun hxy ⟨i, hi⟩
      simpa [hf] using this
    by_contra hne
    have h1 : d ≤ hammingDist x y := hmin x hx y hy hne
    have h2 : hammingDist x y ≤ S.card := hamming_le_of_agree S x y hagree
    omega
  have hcard : C.card ≤ (univ : Finset ({i // i ∈ Sᶜ} → Bool)).card :=
    Finset.card_le_card_of_injOn f (fun a _ => mem_univ _) hinj
  rw [card_univ] at hcard
  have hcard2 : Fintype.card ({i // i ∈ Sᶜ} → Bool) = 2 ^ (N + 1 - d) := by
    rw [Fintype.card_fun, Fintype.card_coe, Fintype.card_bool]
    congr 1
    rw [Finset.card_compl, Fintype.card_fin, hScard]
    omega
  rw [hcard2] at hcard
  exact hcard

/-! ## 3. Robust capacity: the price of noise tolerance -/

/-- **Robust capacity.**  A `t`-error-correcting codebook — one whose distinct
codewords are at Hamming distance at least `2t + 1`, so nearest-codeword decoding
survives up to `t` neuron flips — uses at most `2 ^ (N - 2t)` of the `2 ^ N`
patterns.  Each unit of correction guarantee costs two neurons of raw capacity. -/
theorem robust_capacity {N t : ℕ} (ht : 2 * t ≤ N) (C : Finset (NeuralCode N))
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    C.card ≤ 2 ^ (N - 2 * t) := by
  have h := singleton_bound (d := 2 * t + 1) (by omega) (by omega) C hmin
  have he : N + 1 - (2 * t + 1) = N - 2 * t := by omega
  rwa [he] at h

/-! ## 4. The classical `(N, k, d)` inequalities -/

/-- **Message-length bound.**  A codebook that carries `k` message bits (has
`2 ^ k` codewords) and minimum distance `d` satisfies `k ≤ N + 1 - d`. -/
theorem singleton_message_bound {N d k : ℕ} (hd : 1 ≤ d) (hdN : d ≤ N + 1)
    (C : Finset (NeuralCode N)) (hk : C.card = 2 ^ k)
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → d ≤ hammingDist x y) :
    k ≤ N + 1 - d := by
  have h := singleton_bound hd hdN C hmin
  rw [hk] at h
  exact (Nat.pow_le_pow_iff_right (by norm_num)).mp h

/-- **Redundancy bound.**  A codebook carrying `k` message bits over `N` neurons
with minimum distance `d` has redundancy at least `d - 1`: `d - 1 ≤ N - k`. -/
theorem singleton_redundancy {N d k : ℕ} (hd : 1 ≤ d) (hdN : d ≤ N + 1)
    (C : Finset (NeuralCode N)) (hk : C.card = 2 ^ k)
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → d ≤ hammingDist x y) :
    d - 1 ≤ N - k := by
  have h := singleton_message_bound hd hdN C hk hmin
  omega

/-! ## 5–6. Tightness of the Singleton bound -/

/-- **Tightness at `d = 1`.**  The full pattern set is a (trivial) minimum-distance
`1` code, and it meets the Singleton bound with equality: `2 ^ N = 2 ^ (N+1-1)`.
The capacity count `2 ^ N` is imported from `NeuralCoding.card_neuralCode`. -/
theorem full_code_attains_singleton (N : ℕ) :
    (∀ x ∈ (univ : Finset (NeuralCode N)), ∀ y ∈ (univ : Finset (NeuralCode N)),
        x ≠ y → 1 ≤ hammingDist x y) ∧
    (univ : Finset (NeuralCode N)).card = 2 ^ (N + 1 - 1) := by
  refine ⟨?_, ?_⟩
  · intro x _ y _ hxy
    have : hammingDist x y ≠ 0 := by simp [hammingDist_eq_zero, hxy]
    omega
  · rw [card_univ, card_neuralCode]
    congr 1

/-- The two-word **repetition code** on `N` neurons: everyone silent, or everyone
firing. -/
def repetitionCode (N : ℕ) : Finset (NeuralCode N) :=
  {(fun _ => false), (fun _ => true)}

/-- **Tightness at `d = N`.**  On `N ≥ 1` neurons the repetition code has minimum
distance `N` and exactly `2 = 2 ^ (N + 1 - N)` codewords, so it meets the
Singleton bound with equality.  With `full_code_attains_singleton` this shows the
bound is attained at both extremes of the distance range. -/
theorem repetition_attains_singleton (N : ℕ) (hN : 1 ≤ N) :
    (∀ x ∈ repetitionCode N, ∀ y ∈ repetitionCode N, x ≠ y → N ≤ hammingDist x y) ∧
    (repetitionCode N).card = 2 ^ (N + 1 - N) := by
  constructor
  · intro x hx y hy hxy
    -- the two codewords are the constant patterns; distinct ⇒ they differ everywhere
    simp only [repetitionCode, mem_insert, mem_singleton] at hx hy
    have key : hammingDist (fun _ => false : NeuralCode N) (fun _ => true) = N := by
      rw [hammingDist]; simp
    rcases hx with hx | hx <;> rcases hy with hy | hy <;> subst hx <;> subst hy
    · exact absurd rfl hxy
    · rw [key]
    · rw [hammingDist_comm, key]
    · exact absurd rfl hxy
  · have : N + 1 - N = 1 := by omega
    rw [this, pow_one, repetitionCode, Finset.card_insert_of_notMem, Finset.card_singleton]
    intro h
    simp only [Finset.mem_singleton] at h
    have := congrFun h ⟨0, by omega⟩
    simp at this

end NeuralCodeSingletonBound