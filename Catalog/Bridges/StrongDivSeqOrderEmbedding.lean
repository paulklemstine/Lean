import Mathlib
import Bridges.StrongDivisibilitySequences

/-! # Strong divisibility sequences as order embeddings of the divisibility lattice

Domain: Bridges / Conceptual unification (number theory ↔ order theory).

This file is the second instalment of the strong-divisibility-sequence (`StrongDivSeq`)
programme.  The first file (`StrongDivisibilitySequences.lean`) proved the *meet law*
`gcd (a m) (a n) = a (gcd m n)`; the lattice file (`StrongDivSeqLatticeBridge.lean`) proved
the *join sub-law* `lcm (a m) (a n) ∣ a (lcm m n)` and coprimality propagation.

Here we identify a clean sufficient condition — **strict monotonicity of the underlying
sequence** — under which a strong divisibility sequence becomes a genuine **order
embedding of the divisibility preorder `(ℕ, ∣)` into itself**:
`a m ∣ a n ↔ m ∣ n`.

Main results:

* `StrongDivSeq.dvd_iff_index_dvd_of_strictMono` — the order-embedding theorem.
* `StrongDivSeq.eq_iff_index_eq_of_strictMono`   — injectivity of indices through values.

Cross-domain corollary:

* `mersenne_dvd_iff` — for `2 ≤ b`, `(b^m - 1) ∣ (b^n - 1) ↔ m ∣ n`.

!-- Lab Notes -- !--
Hypothesis: the classical "`fib m ∣ fib n ↔ m ∣ n` for `3 ≤ m`" is not special to Fibonacci;
it follows from the strong-divisibility meet law together with *injectivity of `a` on the
relevant indices*.  The cleanest packaging uses `StrictMono a`, which both gives injectivity
and is satisfied by the Mersenne sequence `b^n - 1` (for `b ≥ 2`).
Argument: from `a m ∣ a n` we get `a m ∣ gcd (a m) (a n) = a (gcd m n)`; since
`gcd m n ∣ m` gives `a (gcd m n) ∣ a m`, antisymmetry forces `a m = a (gcd m n)`, and
injectivity forces `m = gcd m n`, i.e. `m ∣ n`.  The converse is plain monotonicity.
Result: confirmed and fully generic — no positivity side conditions are needed because the
`m = 0` boundary is handled uniformly by `a 0 = 0` and injectivity.
Insight: Fibonacci is *excluded* from the `StrictMono` hypothesis precisely because
`fib 1 = fib 2 = 1`; this is the structural reason the Fibonacci order-embedding needs the
threshold `3 ≤ m`, whereas Mersenne needs no threshold at all.
Failure analysis: an `InjOn`-on-a-threshold variant is tempting but snags on the `gcd m n = 1`
boundary (the meet can drop below the threshold); `StrictMono` sidesteps this entirely.
!-- End Lab Notes -- !--
-/

namespace StrongDivSeq

variable (s : StrongDivSeq)

/-- **Order-embedding theorem.** If the underlying sequence of a strong divisibility
sequence is strictly monotone, then `a m ∣ a n ↔ m ∣ n`: the sequence embeds the
divisibility preorder `(ℕ, ∣)` into itself. -/
theorem dvd_iff_index_dvd_of_strictMono (hmono : StrictMono s.a) (m n : ℕ) :
    s.a m ∣ s.a n ↔ m ∣ n := by
  constructor
  · intro h
    have h1 : s.a m ∣ s.a (Nat.gcd m n) := by
      rw [← s.gcd_eq]; exact Nat.dvd_gcd dvd_rfl h
    have h2 : s.a (Nat.gcd m n) ∣ s.a m := s.dvd_of_dvd (Nat.gcd_dvd_left m n)
    have heq : s.a m = s.a (Nat.gcd m n) := Nat.dvd_antisymm h1 h2
    have : m = Nat.gcd m n := hmono.injective heq
    rw [this]; exact Nat.gcd_dvd_right m n
  · exact fun h => s.dvd_of_dvd h

/-- Under strict monotonicity, equality of values is equivalent to equality of indices. -/
theorem eq_iff_index_eq_of_strictMono (hmono : StrictMono s.a) (m n : ℕ) :
    s.a m = s.a n ↔ m = n :=
  hmono.injective.eq_iff

end StrongDivSeq

/-! ## Mersenne corollary -/

/-- The Mersenne sequence `n ↦ b^n - 1` is strictly monotone for `2 ≤ b`. -/
theorem mersenneSDS_strictMono {b : ℕ} (hb : 2 ≤ b) : StrictMono (mersenneSDS b).a := by
  intro m n hmn
  have hpow : b ^ m < b ^ n := Nat.pow_lt_pow_right hb hmn
  have hone : 1 ≤ b ^ m := Nat.one_le_pow _ _ (by omega)
  show b ^ m - 1 < b ^ n - 1
  omega

/-- **Mersenne order-embedding** (new): for `2 ≤ b`, `(b^m - 1) ∣ (b^n - 1) ↔ m ∣ n`.
This is the Mersenne analogue of the classical Fibonacci divisibility criterion, obtained
from the generic order-embedding theorem. -/
theorem mersenne_dvd_iff {b : ℕ} (hb : 2 ≤ b) (m n : ℕ) :
    (b ^ m - 1) ∣ (b ^ n - 1) ↔ m ∣ n :=
  (mersenneSDS b).dvd_iff_index_dvd_of_strictMono (mersenneSDS_strictMono hb) m n