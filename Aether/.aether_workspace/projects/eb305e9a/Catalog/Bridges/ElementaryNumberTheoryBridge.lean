import Mathlib

/-! # Elementary Number Theory Bridge

Proves fundamental GCD and coprimality properties:
1. GCD commutativity, associativity, and multiplication
2. Coprimality preservation: coprime(a,b) ⟹ coprime(a^n, b^n)
3. Divisibility: a|b ∧ a|c ⟹ a|(b+c)

GCD is the most important function in number theory: it encodes
the multiplicative structure of the integers.
-/

namespace ElementaryNumberTheoryBridge

/-! ## Section 1: GCD Properties -/

/-- GCD is commutative: gcd(m, n) = gcd(n, m). -/
theorem gcd_comm (m n : ℕ) :
    m.gcd n = n.gcd m :=
  Nat.gcd_comm m n

/-- GCD is associative: gcd(gcd(m, n), k) = gcd(m, gcd(n, k)). -/
theorem gcd_assoc (m n k : ℕ) :
    (m.gcd n).gcd k = m.gcd (n.gcd k) :=
  Nat.gcd_assoc m n k

/-- GCD distributes over multiplication (left): gcd(m*n, m*k) = m * gcd(n, k). -/
theorem gcd_mul_left (m n k : ℕ) :
    (m * n).gcd (m * k) = m * n.gcd k :=
  Nat.gcd_mul_left m n k

/-- GCD distributes over multiplication (right). -/
theorem gcd_mul_right (m n k : ℕ) :
    (m * n).gcd (k * n) = m.gcd k * n :=
  Nat.gcd_mul_right m n k

/-! ## Section 2: Coprimality -/

/-- Coprime powers: coprime(k, l) ⟹ coprime(k^m, l^n). -/
theorem coprime_pow {k l : ℕ} (m n : ℕ) (h : k.Coprime l) :
    (k ^ m).Coprime (l ^ n) :=
  Nat.Coprime.pow m n h

/-- Coprime multiplication: coprime(a*k, b*k) factors out the common factor. -/
theorem coprime_mul_left {m k n : ℕ}
    (hm : m.Coprime k) (hn : n.Coprime k) :
    (m * n).Coprime k :=
  Nat.Coprime.mul_left hm hn

/-! ## Section 3: Divisibility -/

/-- If a divides b and a divides c, then a divides b + c. -/
theorem dvd_add_imp {a b c : ℕ} (hab : a ∣ b) (hac : a ∣ c) :
    a ∣ b + c :=
  Nat.dvd_add hab hac

end ElementaryNumberTheoryBridge
