import Mathlib
import Cryptography.McEliece.LinearCode

/-!
# McEliece: a bridge from Hamming geometry to game-based security

This file isolates three rigorous parts of the McEliece argument which do not
claim the presently unproved complexity-theoretic assertion that Goppa-code
distinguishing is NP-hard.

* Additive encryption is translation in a Hamming cube.  Translation invariance
  turns an error-weight bound into a decoding-radius bound, and Hamming-ball
  packing gives correctness.
* The triangle inequality on `ℝ` turns two game hops (Goppa key to random key,
  random-key decoding to an unbiased bit) into an IND-CPA advantage bound.
* A quadratic-search cost model turns the certified `2^256` error space of the
  catalog's Classic McEliece parameters into a `2^128` query lower bound.

Thus the connector is between metric geometry, probability/game hopping, and
post-quantum query complexity.
-/

namespace McElieceConnector

open Finset

section Correctness

variable {n t : ℕ} {K M : Type*} [Field K] [DecidableEq K]

/-- McEliece's algebraic encryption operation: encode, then translate by an error. -/
def encrypt (encode : M → Fin n → K) (m : M) (e : Fin n → K) : Fin n → K :=
  encode m + e

/-- Translation by the encoded word preserves the error's Hamming weight. -/
theorem encryption_distance_eq_error_weight (encode : M → Fin n → K)
    (m : M) (e : Fin n → K) :
    hammingDist (encrypt encode m e) (encode m) = hammingNorm e := by
  simp [encrypt, hammingDist, hammingNorm]

/--
The metric-geometric correctness theorem for McEliece encryption.  If encoded
messages are separated by at least `2t+1`, then a ciphertext formed with an
error of weight at most `t` cannot be within radius `t` of a different encoded
message.
-/
theorem message_unique_from_noisy_encoding (encode : M → Fin n → K)
    (hsep : ∀ m₁ m₂, encode m₁ ≠ encode m₂ →
      2 * t + 1 ≤ hammingDist (encode m₁) (encode m₂))
    (m m' : M) (e : Fin n → K) (he : hammingNorm e ≤ t)
    (hnear : hammingDist (encrypt encode m e) (encode m') ≤ t) :
    encode m' = encode m := by
  apply McEliece.unique_decoding (Set.range encode) t
  · rintro _ ⟨m₁, rfl⟩ _ ⟨m₂, rfl⟩ hne
    exact hsep m₁ m₂ hne
  · exact Set.mem_range_self m'
  · exact Set.mem_range_self m
  · exact hnear
  · simpa [encryption_distance_eq_error_weight] using he

/-- With an injective encoder, metric uniqueness recovers the message itself. -/
theorem message_recovery_from_noisy_encoding (encode : M → Fin n → K)
    (hinj : Function.Injective encode)
    (hsep : ∀ m₁ m₂, encode m₁ ≠ encode m₂ →
      2 * t + 1 ≤ hammingDist (encode m₁) (encode m₂))
    (m m' : M) (e : Fin n → K) (he : hammingNorm e ≤ t)
    (hnear : hammingDist (encrypt encode m e) (encode m') ≤ t) :
    m' = m := by
  apply hinj
  exact message_unique_from_noisy_encoding encode hsep m m' e he hnear

end Correctness

section SecurityGames

/-- IND advantage of a game whose success probability is `p`. -/
noncomputable def indAdvantage (p : ℝ) : ℝ := |p - (1 / 2 : ℝ)|

/--
**Two-hop McEliece IND-CPA reduction.**

`real` is the adversary's success probability with a disguised Goppa key,
`randomCode` is its success probability after replacing that key by a random
linear-code key, and `1/2` is the ideal game.  A Goppa-code distinguisher bounds
the first hop by `εKey`; decoding/message-hiding hardness bounds the second by
`εDecode`.  The real IND advantage is at most their sum.
-/
theorem ind_cpa_of_goppa_distinguishing_and_random_decoding
    (real randomCode εKey εDecode : ℝ)
    (hKey : |real - randomCode| ≤ εKey)
    (hDecode : |randomCode - (1 / 2 : ℝ)| ≤ εDecode) :
    indAdvantage real ≤ εKey + εDecode := by
  unfold indAdvantage
  calc
    |real - (1 / 2 : ℝ)| = |(real - randomCode) + (randomCode - (1 / 2 : ℝ))| := by ring_nf
    _ ≤ |real - randomCode| + |randomCode - (1 / 2 : ℝ)| := abs_add_le _ _
    _ ≤ εKey + εDecode := add_le_add hKey hDecode

/-- Perfect random-code hiding leaves only Goppa-key distinguishing advantage. -/
theorem ind_cpa_of_perfect_random_code_hiding
    (real randomCode εKey : ℝ)
    (hKey : |real - randomCode| ≤ εKey)
    (hIdeal : randomCode = (1 / 2 : ℝ)) :
    indAdvantage real ≤ εKey := by
  subst randomCode
  unfold indAdvantage
  simpa only [one_div] using hKey

end SecurityGames

section QuantumSearch

/-- A reusable exponential lower bound on a binomial search space. -/
theorem pow_le_choose (b : ℕ) : ∀ (t n : ℕ),
    (b + 1) * t ≤ n + 1 → b ^ t ≤ Nat.choose n t := by
  intro t n h
  induction' t with t ht generalizing n <;>
    simp_all +decide [Nat.pow_succ']
  have hc := Nat.choose_succ_right_eq n t
  nlinarith [ht n (by nlinarith), Nat.sub_add_cancel (by nlinarith : t ≤ n),
    Nat.mul_le_mul_left (b ^ t)
      (show b * (t + 1) ≤ n - t from
        le_tsub_of_add_le_left <| by nlinarith)]

/-- The weight-119 error space for the 6960-coordinate parameters exceeds `2^256`. -/
theorem mceliece6960119_error_space : 2 ^ 256 ≤ Nat.choose 6960 119 :=
  calc
    (2 : ℕ) ^ 256 ≤ 5 ^ 119 := by norm_num
    _ ≤ Nat.choose 6960 119 := pow_le_choose 5 119 6960 (by norm_num)

/--
In the quadratic-search model, fewer than `2^128` queries cannot cover a search
space of size at least `2^256`.  The hypothesis `q^2 < N` is the exact abstract
query lower-bound condition used here; no claim is made that every quantum
attack is an unstructured search.
-/
theorem quadratic_search_floor_128
    (N q : ℕ) (hspace : 2 ^ 256 ≤ N) (hq : q < 2 ^ 128) :
    q ^ 2 < N := by
  have hmul : q * q < (2 ^ 128 : ℕ) * (2 ^ 128 : ℕ) :=
    Nat.mul_self_lt_mul_self hq
  have hp : (2 ^ 128 : ℕ) * 2 ^ 128 = 2 ^ 256 := by norm_num [← pow_add]
  rw [pow_two]
  have : q * q < 2 ^ 256 := by simpa only [hp] using hmul
  exact this.trans_le hspace

/--
Concrete post-quantum corollary for `mceliece6960119`: its weight-119 error
space has a 128-bit floor in the quadratic-search model.
-/
theorem mceliece6960119_quantum_search_floor (q : ℕ) (hq : q < 2 ^ 128) :
    q ^ 2 < Nat.choose 6960 119 := by
  exact quadratic_search_floor_128 _ q mceliece6960119_error_space hq

end QuantumSearch

end McElieceConnector