/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Catalog.Novelty.NeuralCoding

/-!
# Neural codes over a finite alphabet: capacity, energy classes and noisy decoding

`Catalog/Novelty/NeuralCoding.lean` models a neural code as a *binary* activity
pattern `Fin N → Bool`, with capacity `2 ^ N`.  Real neurons emit a graded
number of spikes in a window, so this file replaces the binary alphabet by an
arbitrary finite alphabet of size `q` (represented as `ZMod q`, which supplies
the group structure needed for translation arguments), `0` meaning *silent*.

## Results

1. `card_qCode` — **capacity `q ^ N`.**  There are exactly `q ^ N` patterns; and
   `qary_capacity_bound` turns this into a bound on the number of distinguishable
   concepts.
2. `card_supp_eq` — the number of patterns with a *prescribed* support `S` is
   `(q - 1) ^ |S|`.
3. `card_weight_eq` — the **type class** of energy exactly `k` has
   `N.choose k * (q - 1) ^ k` members, generalising the binary `N.choose k`.
4. `card_weight_le` — the **energy-constrained capacity**: at most `k` active
   neurons gives exactly `∑_{j ≤ k} N.choose j * (q - 1) ^ j` patterns.
5. `hammingDist_eq_weight_sub`, `card_ball` — Hamming balls have the same volume
   as the energy-`≤ r` class, by translation invariance.
6. `qary_unique_decoding` — **decoding guarantee.**  A codebook of minimum
   distance `≥ 2t + 1` decodes uniquely from any received pattern within `t`
   corrupted neurons.
7. `qary_hamming_bound` — **sphere packing.**  Such a codebook has at most
   `q ^ N / ∑_{j ≤ t} N.choose j (q-1)^j` codewords.
8. `binary_specialisation` — for `q = 2` the type-class count reduces to the
   binary count `N.choose k` of the original file.
-/

namespace Catalog.Probability.NeuralCoding.Qary

open Finset

/-- A **`q`-ary neural code** on `N` neurons: each neuron emits one of `q`
graded response levels, `0` meaning silent. -/
abbrev QCode (q N : ℕ) : Type := Fin N → ZMod q

variable {q N : ℕ} [NeZero q]

/-- The **support** of a `q`-ary pattern: the set of non-silent neurons. -/
def supp (c : QCode q N) : Finset (Fin N) := univ.filter (fun i => c i ≠ 0)

/-- The **weight** (metabolic energy) of a `q`-ary pattern. -/
def weight (c : QCode q N) : ℕ := (supp c).card

omit [NeZero q] in
theorem mem_supp {c : QCode q N} {i : Fin N} : i ∈ supp c ↔ c i ≠ 0 := by
  simp [supp]

/-- **Capacity of a `q`-ary population**: exactly `q ^ N` patterns. -/
theorem card_qCode (q N : ℕ) [NeZero q] : Fintype.card (QCode q N) = q ^ N := by
  simp [QCode, ZMod.card]

/-- **Capacity is an upper bound on concepts.**  Any injective encoding of a
finite set of concepts into `q`-ary patterns distinguishes at most `q ^ N`
concepts. -/
theorem qary_capacity_bound {α : Type*} [Fintype α] (enc : α → QCode q N)
    (hInj : Function.Injective enc) : Fintype.card α ≤ q ^ N := by
  have h := Fintype.card_le_of_injective enc hInj
  rwa [card_qCode] at h

/-- **Patterns with a prescribed support.**  Exactly `(q - 1) ^ |S|` patterns
have support `S`. -/
theorem card_supp_eq (S : Finset (Fin N)) :
    (univ.filter (fun c : QCode q N => supp c = S)).card = (q - 1) ^ S.card := by
  have hset : (univ.filter (fun c : QCode q N => supp c = S)) =
      Fintype.piFinset (fun i : Fin N => if i ∈ S then ({0}ᶜ : Finset (ZMod q)) else {0}) := by
    ext c
    simp only [mem_filter, mem_univ, true_and, Fintype.mem_piFinset]
    constructor
    · intro hc i
      by_cases hi : i ∈ S
      · simp only [hi, if_true, Finset.mem_compl, Finset.mem_singleton]
        rw [← hc] at hi
        exact mem_supp.mp hi
      · simp only [hi, if_false, Finset.mem_singleton]
        by_contra hne
        exact hi (hc ▸ mem_supp.mpr hne)
    · intro hc
      ext i
      rw [mem_supp]
      have := hc i
      by_cases hi : i ∈ S
      · simp only [hi, if_true, Finset.mem_compl, Finset.mem_singleton] at this
        simp [hi, this]
      · simp only [hi, if_false, Finset.mem_singleton] at this
        simp [hi, this]
  rw [hset, Fintype.card_piFinset]
  have hcard : ∀ i : Fin N,
      (if i ∈ S then ({0}ᶜ : Finset (ZMod q)) else {0}).card
        = if i ∈ S then q - 1 else 1 := by
    intro i
    by_cases hi : i ∈ S <;> simp [hi, Finset.card_compl, ZMod.card]
  rw [Finset.prod_congr rfl (fun i _ => hcard i), Finset.prod_ite_mem, Finset.prod_const]
  congr 1
  simp

/-- **Energy type classes.**  Exactly `N.choose k * (q - 1) ^ k` patterns have
weight (energy) exactly `k`. -/
theorem card_weight_eq (k : ℕ) :
    (univ.filter (fun c : QCode q N => weight c = k)).card
      = N.choose k * (q - 1) ^ k := by
  classical
  have hmaps : Set.MapsTo (fun c : QCode q N => supp c)
      ↑(univ.filter (fun c : QCode q N => weight c = k))
      ↑((univ : Finset (Fin N)).powersetCard k) := by
    intro c hc
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hc
    simp only [Finset.mem_coe, Finset.mem_powersetCard]
    exact ⟨Finset.subset_univ _, hc⟩
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  have hfib : ∀ S ∈ (univ : Finset (Fin N)).powersetCard k,
      ({c ∈ univ.filter (fun c : QCode q N => weight c = k) | supp c = S}).card
        = (q - 1) ^ k := by
    intro S hS
    rw [Finset.mem_powersetCard] at hS
    have hEq : ({c ∈ univ.filter (fun c : QCode q N => weight c = k) | supp c = S})
        = univ.filter (fun c : QCode q N => supp c = S) := by
      ext c
      simp only [mem_filter, mem_univ, true_and]
      constructor
      · rintro ⟨_, h⟩; exact h
      · intro h
        exact ⟨by rw [weight, h, hS.2], h⟩
    rw [hEq, card_supp_eq, hS.2]
  rw [Finset.sum_congr rfl hfib, Finset.sum_const, Finset.card_powersetCard]
  simp

/-- **Energy-constrained capacity.**  Exactly `∑_{j ≤ k} N.choose j * (q-1)^j`
patterns use at most `k` spikes. -/
theorem card_weight_le (k : ℕ) :
    (univ.filter (fun c : QCode q N => weight c ≤ k)).card
      = ∑ j ∈ range (k + 1), N.choose j * (q - 1) ^ j := by
  classical
  have hmaps : Set.MapsTo (fun c : QCode q N => weight c)
      ↑(univ.filter (fun c : QCode q N => weight c ≤ k)) ↑(range (k + 1)) := by
    intro c hc
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hc
    simp only [Finset.mem_coe, mem_range]
    omega
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  refine Finset.sum_congr rfl ?_
  intro j hj
  have hjk : j ≤ k := by simpa [Nat.lt_succ_iff] using mem_range.mp hj
  have hEq : ({c ∈ univ.filter (fun c : QCode q N => weight c ≤ k) | weight c = j})
      = univ.filter (fun c : QCode q N => weight c = j) := by
    ext c
    simp only [mem_filter, mem_univ, true_and]
    constructor
    · rintro ⟨_, h⟩; exact h
    · intro h; exact ⟨by omega, h⟩
  rw [hEq, card_weight_eq]

omit [NeZero q] in
/-- Hamming distance is the weight of the difference: translation invariance of
the `q`-ary code space. -/
theorem hammingDist_eq_weight_sub (x y : QCode q N) :
    hammingDist x y = weight (x - y) := by
  simp only [hammingDist, weight, supp]
  congr 1
  apply Finset.filter_congr
  intro i _
  simp [sub_eq_zero]

/-- The **Hamming ball** of radius `r` around a pattern: all patterns reachable
by corrupting at most `r` neurons. -/
def ball (c : QCode q N) (r : ℕ) : Finset (QCode q N) :=
  univ.filter (fun x => hammingDist x c ≤ r)

/-- **Ball volume.**  Every Hamming ball of radius `r` contains exactly
`∑_{j ≤ r} N.choose j * (q-1)^j` patterns. -/
theorem card_ball (c : QCode q N) (r : ℕ) :
    (ball c r).card = ∑ j ∈ range (r + 1), N.choose j * (q - 1) ^ j := by
  classical
  rw [← card_weight_le (q := q) (N := N) r]
  refine Finset.card_nbij' (fun x => x - c) (fun y => y + c) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [ball, Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and]
    rwa [← hammingDist_eq_weight_sub]
  · intro y hy
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hy
    simp only [ball, Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and]
    rw [hammingDist_eq_weight_sub]
    simpa using hy
  · intro x _; simp
  · intro y _; simp

omit [NeZero q] in
/-- **Unique decoding.**  If two codewords are at distance at least `2t + 1`
whenever distinct, then a received pattern within `t` corruptions of a codeword
determines that codeword. -/
theorem qary_unique_decoding {t : ℕ} {C : Finset (QCode q N)}
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y)
    {x c₁ c₂ : QCode q N} (h₁ : c₁ ∈ C) (h₂ : c₂ ∈ C)
    (hd₁ : hammingDist x c₁ ≤ t) (hd₂ : hammingDist x c₂ ≤ t) : c₁ = c₂ := by
  by_contra hne
  have htri : hammingDist c₁ c₂ ≤ hammingDist c₁ x + hammingDist x c₂ :=
    hammingDist_triangle c₁ x c₂
  have h1 : hammingDist c₁ x = hammingDist x c₁ := hammingDist_comm c₁ x
  have := hmin c₁ h₁ c₂ h₂ hne
  omega

/-- Balls of radius `t` around the codewords of a code with minimum distance
`≥ 2t + 1` are pairwise disjoint. -/
theorem balls_pairwiseDisjoint {t : ℕ} {C : Finset (QCode q N)}
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    (C : Set (QCode q N)).PairwiseDisjoint (fun c => ball c t) := by
  intro c₁ h₁ c₂ h₂ hne
  simp only [Function.onFun, Finset.disjoint_left]
  intro x hx₁ hx₂
  simp only [ball, mem_filter, mem_univ, true_and] at hx₁ hx₂
  exact hne (qary_unique_decoding hmin h₁ h₂ hx₁ hx₂)

/-- **Sphere-packing (Hamming) bound for `q`-ary neural codes.**  A codebook that
corrects `t` corrupted neurons obeys
`|C| * ∑_{j ≤ t} N.choose j (q-1)^j ≤ q ^ N`. -/
theorem qary_hamming_bound {t : ℕ} (C : Finset (QCode q N))
    (hmin : ∀ x ∈ C, ∀ y ∈ C, x ≠ y → 2 * t + 1 ≤ hammingDist x y) :
    C.card * (∑ j ∈ range (t + 1), N.choose j * (q - 1) ^ j) ≤ q ^ N := by
  classical
  have hdisj := balls_pairwiseDisjoint hmin
  have hunion : (C.biUnion (fun c => ball c t)).card = ∑ c ∈ C, (ball c t).card :=
    Finset.card_biUnion (fun x hx y hy hxy => hdisj hx hy hxy)
  have hsum : ∑ c ∈ C, (ball c t).card
      = C.card * (∑ j ∈ range (t + 1), N.choose j * (q - 1) ^ j) := by
    rw [Finset.sum_congr rfl (fun c _ => card_ball c t), Finset.sum_const,
      smul_eq_mul]
  have hle : (C.biUnion (fun c => ball c t)).card ≤ Fintype.card (QCode q N) :=
    Finset.card_le_univ _
  rw [card_qCode] at hle
  rw [← hsum, ← hunion]
  exact hle

/-- **Binary specialisation.**  For `q = 2` the energy type class of weight `k`
has `N.choose k` members, recovering the binary count of
`Catalog/Novelty/NeuralCoding.lean`. -/
theorem binary_specialisation (N k : ℕ) :
    (univ.filter (fun c : QCode 2 N => weight c = k)).card = N.choose k := by
  rw [card_weight_eq]
  simp

/-- **Alphabet size strictly increases capacity.**  Going from `q` to `q + 1`
response levels multiplies capacity by `((q+1)/q)^N`; in particular the capacity
is strictly monotone in the alphabet size for `N ≥ 1`. -/
theorem capacity_strictMono_alphabet {q₁ q₂ N : ℕ} [NeZero q₁] [NeZero q₂]
    (hq : q₁ < q₂) (hN : 1 ≤ N) :
    Fintype.card (QCode q₁ N) < Fintype.card (QCode q₂ N) := by
  rw [card_qCode, card_qCode]
  exact Nat.pow_lt_pow_left hq (by omega)

end Catalog.Probability.NeuralCoding.Qary