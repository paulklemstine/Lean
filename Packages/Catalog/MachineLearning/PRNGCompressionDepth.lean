/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sharpening the PRNG Negative Result: Families, Averages and Tightness

Second research cycle on top of `MachineLearning.PRNGCompressionBound`.  Three
natural escape routes from the pigeonhole bound are closed here, and the bound
is shown to be *tight*, which pins down exactly what a PRNG can do.

## Escape routes closed

* **"Chain several generators."**  `prng_composition_no_gain`: composing
  generators keeps the seed-length bound; the shortest seed in the chain rules.
* **"Try many generators and keep the lucky one."**  `prng_family_no_gain`:
  a family of `2 ^ m` generators with `s`-bit seeds still needs `m + s ≥ n`
  bits — selecting a generator costs exactly the bits needed to name it.
* **"Beat it on average, not in the worst case."**  `sum_length_lower` and
  `sum_KC_lower`: the *average* codeword length over all `2 ^ n` strings is at
  least `(n - k) (1 - 2 ^ (-k))` for every `k`, so no code (PRNG-based or not)
  has average length below `n - O(log n)`.

## Tightness (what a PRNG *can* do)

* `natToBits` / `exists_code_of_small_set` — any set of at most `2 ^ k` strings
  admits an injective `k`-bit code.  Combined with `prng_range_card_le` this is
  the precise statement of the positive half: PRNG outputs (a set of size
  `≤ 2 ^ s`) compress to `s` bits, and nothing else does.
* `prng_range_compresses` — the concrete corollary for the range of a PRNG.

## Application Keywords

pigeonhole tightness, average code length, generator families, seed selection
cost, Kolmogorov complexity, compression lower bounds
-/

import MachineLearning.PRNGCompressionBound

open Finset

namespace PRNGCompression

/-! ## Chaining and selecting generators -/

/-- **Chaining generators does not help.**  If `G₂ ∘ G₁` reaches every `n`-bit
string from an `s`-bit seed, then `s ≥ n` — no matter how large the intermediate
state space is. -/
theorem prng_composition_no_gain {n s t : ℕ} (G₁ : Bits s → Bits t) (G₂ : Bits t → Bits n)
    (h : Function.Surjective (G₂ ∘ G₁)) : n ≤ s :=
  prng_seed_bits_lower_bound (G₂ ∘ G₁) h

/-- **A family of generators only buys the bits used to name it.**  If some
generator among `2 ^ m` of them, run on some `s`-bit seed, reaches every `n`-bit
string, then `m + s ≥ n`.  Searching over PRNGs is not free. -/
theorem prng_family_no_gain {n s m : ℕ} (F : Bits m → Bits s → Bits n)
    (hF : ∀ x : Bits n, ∃ i seed, F i seed = x) : n ≤ m + s := by
  have hsurj : Function.Surjective (fun p : Bits m × Bits s => F p.1 p.2) := by
    intro x
    obtain ⟨i, seed, h⟩ := hF x
    exact ⟨(i, seed), h⟩
  have hcard : Fintype.card (Bits n) ≤ Fintype.card (Bits m × Bits s) :=
    Fintype.card_le_of_surjective _ hsurj
  have hprod : Fintype.card (Bits m × Bits s) = 2 ^ (m + s) := by
    rw [Fintype.card_prod, card_bits, card_bits, pow_add]
  rw [card_bits, hprod] at hcard
  exact (Nat.pow_le_pow_iff_right (by norm_num)).mp hcard

/-! ## Average-case bounds -/

/-- **Average length bound.**  For every injective code and every `k < n`, the
total codeword length over all `2 ^ n` strings is at least
`(n - k) (2 ^ n - 2 ^ (n - k))`; dividing by `2 ^ n`, the average length is at
least `(n - k)(1 - 2 ^ (-k))`.  Taking `k ≈ log₂ n` gives average `≥ n - O(log n)`:
compression cannot even win *on average* against uniform data. -/
theorem sum_length_lower (n k : ℕ) (hk : k + 1 ≤ n) (c : Bits n → List Bool)
    (hc : Function.Injective c) :
    (n - k) * (2 ^ n - 2 ^ (n - k)) ≤ ∑ x, (c x).length := by
  classical
  set S := univ.filter (fun x : Bits n => n - k ≤ (c x).length) with hS
  set T := univ.filter (fun x : Bits n => (c x).length ≤ n - k - 1) with hT
  have hcards : S.card + T.card = 2 ^ n := by
    have h := Finset.card_filter_add_card_filter_not
      (s := (univ : Finset (Bits n))) (p := fun x => n - k ≤ (c x).length)
    have hTeq : (univ.filter (fun x : Bits n => ¬ (n - k ≤ (c x).length))) = T := by
      apply Finset.filter_congr
      intro x _
      constructor
      · intro h1; omega
      · intro h1; omega
    rw [hTeq] at h
    simpa [hS] using h
  have hT2 : T.card ≤ 2 ^ (n - k) - 1 := by
    have hcs := card_short_le c hc (n - k - 1)
    have he : n - k - 1 + 1 = n - k := by omega
    rw [he] at hcs
    exact hcs
  have hpos : 0 < 2 ^ (n - k) := Nat.two_pow_pos _
  have hScard : 2 ^ n - 2 ^ (n - k) ≤ S.card := by omega
  have h2 : (n - k) * S.card ≤ ∑ x ∈ S, (c x).length := by
    have := Finset.card_nsmul_le_sum S (fun x => (c x).length) (n - k)
      (by intro x hx; exact (Finset.mem_filter.mp hx).2)
    simpa [mul_comm, smul_eq_mul] using this
  have h1 : ∑ x ∈ S, (c x).length ≤ ∑ x, (c x).length :=
    Finset.sum_le_sum_of_subset (Finset.subset_univ S)
  calc (n - k) * (2 ^ n - 2 ^ (n - k)) ≤ (n - k) * S.card := Nat.mul_le_mul_left _ hScard
    _ ≤ ∑ x ∈ S, (c x).length := h2
    _ ≤ ∑ x, (c x).length := h1

/-- The same average-case bound stated for description complexity relative to an
arbitrary (possibly PRNG-driven) decompressor. -/
theorem sum_KC_lower (n k : ℕ) (hk : k + 1 ≤ n) (D : List Bool → Bits n)
    (hD : Function.Surjective D) :
    (n - k) * (2 ^ n - 2 ^ (n - k)) ≤ ∑ x, KC D x := by
  obtain ⟨c, hinj, hspec⟩ := exists_shortest_code D hD
  have hsum : ∑ x, (c x).length = ∑ x, KC D x :=
    Finset.sum_congr rfl (fun x _ => (hspec x).1)
  rw [← hsum]
  exact sum_length_lower n k hk c hinj

/-! ## Tightness: low-entropy sets really do compress -/

/-- The `k`-bit binary expansion of `v`, as a bit string. -/
def natToBits (k v : ℕ) : List Bool := List.ofFn (fun i : Fin k => v.testBit i)

@[simp] lemma natToBits_length (k v : ℕ) : (natToBits k v).length = k := by
  simp [natToBits]

lemma natToBits_inj_of_lt {k v w : ℕ} (hv : v < 2 ^ k) (hw : w < 2 ^ k)
    (h : natToBits k v = natToBits k w) : v = w := by
  have hbit : ∀ i : Fin k, v.testBit i = w.testBit i := by
    intro i
    exact congrFun (List.ofFn_inj.mp h) i
  apply Nat.eq_of_testBit_eq
  intro i
  by_cases hi : i < k
  · exact hbit ⟨i, hi⟩
  · push_neg at hi
    have h1 : v < 2 ^ i := lt_of_lt_of_le hv (Nat.pow_le_pow_right (by norm_num) hi)
    have h2 : w < 2 ^ i := lt_of_lt_of_le hw (Nat.pow_le_pow_right (by norm_num) hi)
    rw [Nat.testBit_lt_two_pow h1, Nat.testBit_lt_two_pow h2]

/-- **Converse of the pigeonhole bound.**  Any set of at most `2 ^ k` strings
carries an injective code of length exactly `k`.  Together with
`exists_long_codeword` this shows the bound is sharp: `k` code bits describe
`2 ^ k` objects, no more and no fewer. -/
theorem exists_code_of_small_set (n k : ℕ) (A : Finset (Bits n)) (hA : A.card ≤ 2 ^ k) :
    ∃ c : Bits n → List Bool, (∀ x ∈ A, (c x).length = k) ∧ Set.InjOn c A := by
  classical
  let e := A.equivFin
  refine ⟨fun x => if h : x ∈ A then natToBits k (e ⟨x, h⟩ : Fin A.card) else [], ?_, ?_⟩
  · intro x hx
    simp only [dif_pos hx, natToBits_length]
  · intro x hx y hy hxy
    simp only [Finset.mem_coe] at hx hy
    simp only [dif_pos hx, dif_pos hy] at hxy
    have hvx : ((e ⟨x, hx⟩ : Fin A.card) : ℕ) < 2 ^ k := lt_of_lt_of_le (e ⟨x, hx⟩).isLt hA
    have hvy : ((e ⟨y, hy⟩ : Fin A.card) : ℕ) < 2 ^ k := lt_of_lt_of_le (e ⟨y, hy⟩).isLt hA
    have hnum := natToBits_inj_of_lt hvx hvy hxy
    exact congrArg Subtype.val (e.injective (Fin.ext hnum))

/-- **What a PRNG really buys.**  The output set of an `s`-bit-seed generator
admits an `s`-bit injective code — exactly the "compress to the seed" trick —
and by `prng_no_free_lunch` nothing outside that set is helped. -/
theorem prng_range_compresses {n s : ℕ} (G : Bits s → Bits n) :
    ∃ c : Bits n → List Bool,
      (∀ x ∈ univ.image G, (c x).length = s) ∧ Set.InjOn c (univ.image G) :=
  exists_code_of_small_set n s (univ.image G) (prng_range_card_le G)

/-- **Dichotomy.**  For `s + 1 < n`: the PRNG range compresses to `s` bits, yet
some string still needs `n` bits under the best PRNG-powered compressor, and no
seed produces it.  This is the complete answer to "can a PRNG help?": it helps
exactly on the `2 ^ s` strings it already generates. -/
theorem prng_dichotomy {n s : ℕ} (hs : s + 1 < n) (G : Bits s → Bits n) :
    (∃ c : Bits n → List Bool,
        (∀ x ∈ univ.image G, (c x).length = s) ∧ Set.InjOn c (univ.image G)) ∧
      ∃ x : Bits n, n ≤ KC (hybridDecoder G) x ∧ ∀ seed, G seed ≠ x :=
  ⟨prng_range_compresses G, prng_no_free_lunch hs G⟩

end PRNGCompression