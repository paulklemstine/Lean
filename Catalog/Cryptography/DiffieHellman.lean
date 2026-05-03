import Mathlib
import Cryptography.BerggrenSL2.MatRed

/-!
# Berggren–Diffie–Hellman Correctness and DLP Reduction

We formalize the core algebraic facts underlying the SPB (Stern–Brocot / Pythagorean)
Diffie–Hellman protocol:

1. **DH correctness**: `(matRed p g ^ a) ^ b = (matRed p g) ^ (a * b)`, so
   Alice and Bob derive the same shared secret.

2. **DLP uniqueness**: In a finite group, if `m, n < orderOf g` then
   `g^m = g^n ↔ m = n`. This is the exact statement that recovering the
   secret exponent from a public key is the discrete logarithm problem.

3. **Normalized word bridge**: If a Berggren word `w` equals `g^n` over `ℤ`,
   then `matRed p w = (matRed p g)^n`, reducing the SPB public parameter
   to a standard cyclic-group DH instance.
-/

open Matrix

/-! ## Diffie–Hellman Correctness -/

/-- DH shared secret agreement: `(ĝ^a)^b = ĝ^(a*b)` and `(ĝ^b)^a = ĝ^(b*a)`.
This is the basic algebraic fact that makes Diffie–Hellman work. -/
theorem berggren_dh_shared
    {p : ℕ} [Fact p.Prime]
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (a b : ℕ) :
    ((matRed p g) ^ a) ^ b = (matRed p g) ^ (a * b) ∧
    ((matRed p g) ^ b) ^ a = (matRed p g) ^ (b * a) := by
  constructor <;> rw [← pow_mul]

/-- DH commutativity: `(ĝ^a)^b = (ĝ^b)^a`.
Alice and Bob compute the same shared secret. -/
theorem berggren_dh_correct
    {p : ℕ} [Fact p.Prime]
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (a b : ℕ) :
    ((matRed p g) ^ a) ^ b = ((matRed p g) ^ b) ^ a := by
  rw [← pow_mul, ← pow_mul, mul_comm]

/-! ## DLP Uniqueness -/

/-
In a finite monoid, elements below the order are uniquely determined
by their power. This is the mathematical content of saying that
exponent recovery is exactly the discrete logarithm problem.
-/
theorem dlp_uniqueness_mod_order
    {α : Type*} [Monoid α] [Finite α]
    (g : α) :
    ∀ {m n : ℕ}, m < orderOf g → n < orderOf g →
      (g ^ m = g ^ n ↔ m = n) := by
  exact fun { m n } hm hn => ⟨ fun h => pow_injOn_Iio_orderOf hm hn h, fun h => h ▸ rfl ⟩

/-
The exponent-recovery theorem: for any `n < q = orderOf(matRed p g)`,
there exists a unique `k < q` with `(matRed p g)^k = (matRed p g)^n`.
This is exactly the DLP search problem.
-/
theorem recoverExponent_eq_discreteLog
    {p : ℕ} [Fact p.Prime]
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (hdet : g.det = 1)
    (q : ℕ)
    (hq : q = orderOf (matRed p g)) :
    ∀ (n : ℕ), n < q →
      ∃! k : ℕ, k < q ∧ (matRed p g) ^ k = (matRed p g) ^ n := by
  intro n hn;
  refine' ⟨ n, ⟨ hn, rfl ⟩, fun k hk => _ ⟩;
  -- Apply the uniqueness theorem to conclude that $k = n$.
  have := dlp_uniqueness_mod_order (matRed p g) (by
  linarith [ hk.1 ] : k < orderOf (matRed p g)) (by
  linarith : n < orderOf (matRed p g))
  aesop

/-! ## Normalized Word Bridge -/

/-- If a Berggren word `w` is a power of `g` over `ℤ`, then after reduction
mod `p`, it becomes the corresponding power of the reduced generator.
This is the bridge from SPB public parameters to cyclic-group DH. -/
theorem normalized_word_to_dh
    {p : ℕ} [Fact p.Prime]
    (g w : Matrix (Fin 2) (Fin 2) ℤ)
    (hnorm : ∃ n : ℕ, w = g ^ n) :
    ∃ n : ℕ, matRed p w = (matRed p g) ^ n := by
  obtain ⟨n, rfl⟩ := hnorm
  exact ⟨n, matRed_pow g n⟩