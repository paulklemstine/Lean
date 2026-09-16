import Mathlib
import Cryptography.Berggren3Adic.Balance

/-!
# Every letter position is sealed, given all shallower letters (BERGGREN-3ADIC, part V)

Third cycle.  Parts III–IV sealed the *first* branch letter against every modulus.  A
critic can object that a channel could live deeper: perhaps the letter at depth `t` is
readable from `N mod M` once the shallower letters are known.  It is not.

For a modulus `M ≥ 2`, a depth `t` and a parameter `k ≥ 1` put

`node M k t = (4tM + 2Mk + 1, 2M)`.

Its `N`-value is `≡ 1 (mod M)` for every `k`, its first `t` letters are all `C`, and its
letter at depth `t` is `A`, `B`, `C` for `k = 1, 2, 3` respectively.  Hence:

* `Berggren3Adic.all_letters_at_depth_in_one_residue_class` — at every depth `t` and every
  modulus `M ≥ 2`, all three letters occur at depth `t` inside one residue class of `N`,
  on nodes that agree in *all* shallower letters;
* `Berggren3Adic.no_depthwise_letter_function` — therefore no function of `N mod M`
  *together with* the whole prefix of shallower letters computes the letter at depth `t`.
  The seal is positionwise, not merely at the first letter.
-/

namespace Berggren3Adic

open BergGen

/-- The letter of the `t`-th ancestor of a node (`t = 0` is the node's own letter). -/
def letterAt (t : ℕ) (p : ℤ × ℤ) : BergGen := letterOf (parentPair^[t] p)

@[simp] theorem letterAt_zero (p : ℤ × ℤ) : letterAt 0 p = letterOf p := rfl

/-- The witness family: `node M k t = (4tM + 2Mk + 1, 2M)`. -/
def node (M k : ℤ) (t : ℕ) : ℤ × ℤ := (4 * (t : ℤ) * M + 2 * M * k + 1, 2 * M)

theorem node_fst (M k : ℤ) (t : ℕ) : (node M k t).1 = 4 * (t : ℤ) * M + 2 * M * k + 1 := rfl
theorem node_snd (M k : ℤ) (t : ℕ) : (node M k t).2 = 2 * M := rfl

/-- Every member of the family sits in the residue class `N ≡ 1 (mod M)`. -/
theorem dvd_nOf_node_sub_one (M k : ℤ) (t : ℕ) : M ∣ nOf (node M k t) - 1 := by
  refine ⟨16 * (t : ℤ) ^ 2 * M + 16 * (t : ℤ) * M * k + 8 * (t : ℤ) +
    4 * M * k ^ 2 + 4 * k - 4 * M, ?_⟩
  simp only [nOf, node]
  ring

/-- One descent step inside the family: while `m ≥ 6M` the parent stays in the family. -/
theorem parentPair_node {M k : ℤ} (hM : 1 ≤ M) (hk : 1 ≤ k) (t : ℕ) :
    parentPair (node M k (t + 1)) = node M k t := by
  have ht : (0 : ℤ) ≤ (t : ℤ) := Int.natCast_nonneg t
  have h1 : 6 * M ≤ 4 * ((t : ℤ) + 1) * M + 2 * M * k + 1 := by nlinarith
  simp only [node, parentPair, Nat.cast_add, Nat.cast_one]
  rw [if_neg (by push_neg; linarith), if_neg (by push_neg; linarith)]
  refine Prod.ext ?_ rfl
  simp only
  ring

/-- Iterating the descent `r` times lands on `node M k u` when starting from
`node M k (r + u)`. -/
theorem iterate_parentPair_node {M k : ℤ} (hM : 1 ≤ M) (hk : 1 ≤ k) (r u : ℕ) :
    parentPair^[r] (node M k (r + u)) = node M k u := by
  induction r with
  | zero => simp
  | succ q ih =>
    have hstep : parentPair (node M k (q + 1 + u)) = node M k (q + u) := by
      have h := parentPair_node hM hk (q + u)
      rwa [show q + u + 1 = q + 1 + u by omega] at h
    rw [Function.iterate_succ_apply, hstep, ih]

/-- All letters shallower than `t` are `C`: the ancestors are still deep in the third
band. -/
theorem letterAt_node_of_lt {M k : ℤ} (hM : 1 ≤ M) (hk : 1 ≤ k) {s t : ℕ} (hst : s < t) :
    letterAt s (node M k t) = C := by
  obtain ⟨j, rfl⟩ : ∃ j : ℕ, t = s + (j + 1) := ⟨t - s - 1, by omega⟩
  have h := iterate_parentPair_node hM hk s (j + 1)
  have hj : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg j
  have hb : 6 * M ≤ 4 * ((j : ℤ) + 1) * M + 2 * M * k + 1 := by nlinarith
  rw [letterAt, h]
  simp only [node, letterOf, Nat.cast_add, Nat.cast_one]
  rw [if_neg (by push_neg; linarith), if_neg (by push_neg; linarith)]

theorem fermatPair_node {M k : ℤ} (hM : 1 ≤ M) (hk : 1 ≤ k) (t : ℕ) :
    FermatPair (node M k t) := by
  have ht : (0 : ℤ) ≤ (t : ℤ) := Int.natCast_nonneg t
  have hmk : 2 * M ≤ 2 * M * k := by nlinarith
  have htM : 0 ≤ 4 * (t : ℤ) * M := by positivity
  refine ⟨by simp only [node]; linarith, by simp only [node]; linarith, ?_, ?_⟩
  · refine ⟨1, -(2 * (t : ℤ)) - k, ?_⟩
    simp only [node]
    ring
  · have hodd : Odd (4 * (t : ℤ) * M + 2 * M * k + 1 + 2 * M) :=
      ⟨2 * (t : ℤ) * M + M * k + M, by ring⟩
    simpa [node] using Int.odd_iff.mp hodd

/-- **All three letters at depth `t`, inside one residue class, with identical shallower
letters**, for every modulus `M ≥ 2` and every depth `t`. -/
theorem all_letters_at_depth_in_one_residue_class {M : ℤ} (hM : 2 ≤ M) (t : ℕ) :
    ∃ p₁ p₂ p₃ : ℤ × ℤ,
      FermatPair p₁ ∧ FermatPair p₂ ∧ FermatPair p₃ ∧
      M ∣ nOf p₁ - 1 ∧ M ∣ nOf p₂ - 1 ∧ M ∣ nOf p₃ - 1 ∧
      (∀ s < t, letterAt s p₁ = C ∧ letterAt s p₂ = C ∧ letterAt s p₃ = C) ∧
      letterAt t p₁ = A ∧ letterAt t p₂ = B ∧ letterAt t p₃ = C := by
  have hM1 : (1 : ℤ) ≤ M := by omega
  have hbot : ∀ k : ℤ, 1 ≤ k → parentPair^[t] (node M k t) = node M k 0 := by
    intro k hk
    have h := iterate_parentPair_node hM1 hk t 0
    rwa [Nat.add_zero] at h
  refine ⟨node M 1 t, node M 2 t, node M 3 t,
    fermatPair_node hM1 (by norm_num) t, fermatPair_node hM1 (by norm_num) t,
    fermatPair_node hM1 (by norm_num) t,
    dvd_nOf_node_sub_one M 1 t, dvd_nOf_node_sub_one M 2 t, dvd_nOf_node_sub_one M 3 t,
    fun s hs => ⟨letterAt_node_of_lt hM1 (by norm_num) hs,
      letterAt_node_of_lt hM1 (by norm_num) hs, letterAt_node_of_lt hM1 (by norm_num) hs⟩,
    ?_, ?_, ?_⟩
  · rw [letterAt, hbot 1 (by norm_num)]
    simp only [node, letterOf, Nat.cast_zero]
    rw [if_pos (by linarith)]
  · rw [letterAt, hbot 2 (by norm_num)]
    simp only [node, letterOf, Nat.cast_zero]
    rw [if_neg (by push_neg; linarith), if_pos (by linarith)]
  · rw [letterAt, hbot 3 (by norm_num)]
    simp only [node, letterOf, Nat.cast_zero]
    rw [if_neg (by push_neg; linarith), if_neg (by push_neg; linarith)]

/-- **Positionwise seal.**  No function of `N mod M` *together with the whole prefix of
shallower letters* computes the letter at depth `t`, at any modulus `M ≥ 2` and any
depth. -/
theorem no_depthwise_letter_function {M : ℤ} (hM : 2 ≤ M) (t : ℕ)
    (f : ℤ → (ℕ → BergGen) → BergGen)
    (hf : ∀ (a b : ℤ) (u v : ℕ → BergGen), M ∣ a - b → (∀ s < t, u s = v s) →
      f a u = f b v) :
    ∃ p : ℤ × ℤ, FermatPair p ∧ f (nOf p) (fun s => letterAt s p) ≠ letterAt t p := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨p₁, p₂, p₃, h1, h2, h3, d1, d2, d3, hpre, l1, l2, l3⟩ :=
    all_letters_at_depth_in_one_residue_class hM t
  have hdiff : M ∣ nOf p₁ - nOf p₂ := by
    obtain ⟨c₁, hc₁⟩ := d1
    obtain ⟨c₂, hc₂⟩ := d2
    exact ⟨c₁ - c₂, by linarith⟩
  have e12 : f (nOf p₁) (fun s => letterAt s p₁) = f (nOf p₂) (fun s => letterAt s p₂) :=
    hf _ _ _ _ hdiff (fun s hs => by rw [(hpre s hs).1, (hpre s hs).2.1])
  rw [hcon p₁ h1, hcon p₂ h2, l1, l2] at e12
  exact absurd e12 (by decide)

end Berggren3Adic