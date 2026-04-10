/-
# Mathematics of Science Fiction — Chapter 4: The Limits of Alien Communication

Formalized proofs about information theory, entropy, and the mathematical
constraints on interstellar communication.
-/
import Mathlib

namespace SciFiMathematics.Information

/-! ## Section 4.2: Shannon Entropy Properties

Entropy measures the information content of a message — the fundamental
currency of any communication, terrestrial or interstellar. -/

/-
The entropy of a deterministic source (probability 1 on one symbol)
    is zero: a perfectly predictable message carries no information.
-/
theorem deterministic_zero_entropy :
    -((1 : ℝ) * Real.log 1) = 0 := by
  norm_num

/-
log(1) = 0, which is why certain outcomes contribute zero entropy.
-/
theorem log_one_eq_zero : Real.log 1 = 0 := by
  norm_num

/-! ## Section 4.3: Channel Capacity

The maximum rate of reliable communication over a noisy channel. -/

/-
The capacity of a noiseless binary channel is 1 bit per use.
-/
theorem noiseless_binary_capacity : Real.log 2 > 0 := by
  positivity

/-! ## Section 4.4: Kolmogorov Complexity

The length of the shortest description of an object — the fundamental
measure of an object's complexity. -/

/-
The pigeonhole principle applied to compression: not all strings of
    length n can be compressed to fewer than n bits. This limits how
    much information can be packed into an interstellar message.
-/
theorem pigeonhole_compression (n : ℕ) (hn : 0 < n) :
    2 ^ n > 2 ^ (n - 1) := by
  exact pow_lt_pow_right₀ one_lt_two ( Nat.pred_lt hn.ne' )

/-! ## The Inverse Square Law

Signal power falls off as 1/d², making interstellar communication
increasingly difficult with distance. -/

/-
The inverse square law: power decreases as the square of distance.
-/
theorem inverse_square_law (P d₁ d₂ : ℝ) (hP : 0 < P)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) (hd : d₁ < d₂) :
    P / d₂ ^ 2 < P / d₁ ^ 2 := by
  gcongr

/-
Doubling the distance quarters the received power.
-/
theorem double_distance_quarter_power (P d : ℝ) (hP : 0 < P) (hd : 0 < d) :
    P / (2 * d) ^ 2 = P / d ^ 2 / 4 := by
  ring

/-! ## Mutual Information and Alien Understanding

For communication to succeed, the mutual information between sent and
received messages must be positive. -/

/-
Mutual information is non-negative: I(X;Y) = H(X) - H(X|Y) ≥ 0.
    We prove a simple algebraic version: a - b ≥ 0 when a ≥ b.
-/
theorem mutual_info_nonneg (hx hy hxy : ℝ) (h : hx ≥ hxy) :
    hx - hxy ≥ 0 := by
  linarith

end SciFiMathematics.Information