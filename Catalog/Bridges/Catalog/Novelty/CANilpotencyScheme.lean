import Mathlib

/-!
# Nilpotency of Additive Cellular Automata on Cyclic Lattices: Wolfram meets Grothendieck

This file proves a **cross-domain bridge** connecting three areas that, on their
face, look unrelated:

* **Cellular automata / discrete dynamics** — Wolfram's additive elementary
  cellular automata (the `Rule 60` / `Rule 90` family) on a *finite cyclic*
  lattice `ℤ/n`.
* **Commutative algebra & algebraic geometry** — the coordinate ring of the
  finite group scheme `μₙ` of `n`-th roots of unity over `𝔽₂`, realised as the
  quotient ring `𝔽₂[X]/(Xⁿ − 1)`, and the *nilpotency* of a distinguished ring
  element (equivalently, whether the scheme `μₙ` is infinitesimal / non-reduced).
* **Elementary number theory** — the arithmetic of powers of `2`.

## The dictionary

A spatially `n`-periodic binary configuration `s : ℤ/n → 𝔽₂` is encoded as an
element of the group algebra `𝔽₂[ℤ/n] ≅ 𝔽₂[X]/(Xⁿ − 1)` (send the cell at
position `i` to the monomial `Xⁱ`).  The *additive* nearest-neighbour rule
"`new cell = old cell + right neighbour`" (an `𝔽₂`-linear elementary CA) is then
exactly **multiplication by the ring element `1 + X`**.  Time-`t` evolution is
multiplication by `(1 + X)ᵗ`, so the whole space-time behaviour is governed by
the powers of one element `u = 1 + X` in the finite ring
`Rq n = 𝔽₂[X]/(Xⁿ − 1)`.

The automaton is **nilpotent** — every configuration dies to the all-zero state
in finitely many steps — **iff** the ring element `u` is nilpotent, i.e. `uᴺ = 0`
for some `N`.

## Main theorem

`caUnit_isNilpotent_iff` :  for `n > 0`,

  `IsNilpotent (caUnit n)  ↔  ∃ k, n = 2 ^ k`.

Equivalently (`ca_dies_iff_pow2`): *every* configuration reaches `0` under the
rule iff the lattice size is a power of two.

This is the "Wolfram meets Grothendieck" statement: the additive CA on `ℤ/n`
collapses to nothing precisely when the affine group scheme `μₙ = Spec 𝔽₂[X]/(Xⁿ−1)`
is a **fat point** (non-reduced, purely infinitesimal), which over `𝔽₂` happens
exactly when `n` is a power of the characteristic `2`.  The dynamical fact
(everything dies) is thus equivalent to a purely arithmetic fact (`n = 2ᵏ`).

## Proof architecture

* `caUnit_isNilpotent_iff_dvd` — nilpotency in the quotient ring is the
  divisibility statement `∃ N, (Xⁿ − 1) ∣ (X + 1)ᴺ`.
* `pow2_imp_eq` — if `n = 2ᵏ` then `Xⁿ − 1 = (X + 1)ⁿ` (the Frobenius /
  "freshman's dream" collapse `(X+1)^{2ᵏ} = X^{2ᵏ} + 1`).
* `dvd_imp_eq` — conversely, since `X + 1` is *prime* in `𝔽₂[X]`, any divisor of
  a power of `X + 1` is a power of `X + 1`; matching monic degrees forces
  `Xⁿ − 1 = (X + 1)ⁿ`.
* `eq_imp_pow2` — the arithmetic heart: `Xⁿ − 1 = (X + 1)ⁿ ⟹ n = 2ᵏ`, proved by
  strong induction using char-2 square-root injectivity (`sq_inj`) and a
  derivative/`eval 0` parity computation (`even_of_eq`).

All results live over `𝔽₂ = ZMod 2` with polynomials in `Polynomial (ZMod 2)`.
-/

open Polynomial

noncomputable section

namespace WolframGrothendieck

/-! ## Char-2 polynomial toolbox -/

/-- **Squaring is injective** in `𝔽₂[X]` (a domain of characteristic `2`):
`A² = B² → A = B`, because `(A+B)² = A² + B²` collapses. -/
theorem sq_inj (A B : (ZMod 2)[X]) (h : A ^ 2 = B ^ 2) : A = B := by
  have hz : (A + B) ^ 2 = 0 := by rw [add_pow_char, h]; exact CharTwo.add_self_eq_zero _
  have h2 : A + B = 0 := (pow_eq_zero_iff (by norm_num)).mp hz
  have : A = -B := by linear_combination h2
  rw [this, CharTwo.neg_eq]

/-- Char-2 "square = double frequency": `(Xᵐ − 1)² = X^{2m} − 1`. -/
theorem sq_Xpow_sub (m : ℕ) : (X ^ m - 1 : (ZMod 2)[X]) ^ 2 = X ^ (2 * m) - 1 := by
  have e1 : (X ^ m - 1 : (ZMod 2)[X]) = X ^ m + 1 := by rw [sub_eq_add_neg, CharTwo.neg_eq]
  have e2 : (X ^ (2 * m) - 1 : (ZMod 2)[X]) = X ^ (2 * m) + 1 := by
    rw [sub_eq_add_neg, CharTwo.neg_eq]
  rw [e1, e2, add_pow_char, one_pow, ← pow_mul, mul_comm m 2]

/-- `X + 1` is **prime** in `𝔽₂[X]` (it is `X − C 1`, and `−1 = 1` in char 2). -/
theorem Xadd1_prime : Prime (X + 1 : (ZMod 2)[X]) := by
  have h := prime_X_sub_C (1 : ZMod 2)
  have e : (X - C (1 : ZMod 2)) = (X + 1 : (ZMod 2)[X]) := by
    rw [C_1, sub_eq_add_neg, CharTwo.neg_eq, add_comm]
  rwa [e] at h

/-! ## The three key implications -/

/-- **Frobenius collapse.** If `n = 2ᵏ` then `Xⁿ − 1 = (X + 1)ⁿ`, since
`(X + 1)^{2ᵏ} = X^{2ᵏ} + 1` by the "freshman's dream" in characteristic `2`. -/
theorem pow2_imp_eq (k : ℕ) :
    (X ^ (2 ^ k) - 1 : (ZMod 2)[X]) = (X + 1) ^ (2 ^ k) := by
  rw [add_pow_char_pow, one_pow, sub_eq_add_neg, CharTwo.neg_eq]

/-- **Parity from the derivative.** If `Xⁿ − 1 = (X + 1)ⁿ` with `n ≥ 2`, then `n`
is even: differentiate and evaluate at `0`, giving `n · 0 = n · 1` in `𝔽₂`. -/
theorem even_of_eq (n : ℕ) (hn : 2 ≤ n)
    (h : (X ^ n - 1 : (ZMod 2)[X]) = (X + 1) ^ n) : (n : ZMod 2) = 0 := by
  have hd := congrArg derivative h
  simp only [derivative_sub, derivative_one, sub_zero,
    derivative_pow, derivative_add, derivative_X, add_zero, mul_one] at hd
  have he := congrArg (eval 0) hd
  rw [eval_mul, eval_mul, eval_pow, eval_pow, eval_X, eval_add, eval_X, eval_one] at he
  simp only [zero_add, one_pow, mul_one] at he
  rw [show (0 : ZMod 2) ^ (n - 1) = 0 by exact zero_pow (by omega)] at he
  rw [mul_zero, eq_comm] at he
  simpa using he

/-- **Arithmetic heart.** `Xⁿ − 1 = (X + 1)ⁿ ⟹ n = 2ᵏ`.  Strong induction: the
odd `n ≥ 2` case is killed by `even_of_eq`; the even case `n = 2m` is reduced to
`m` via char-2 square-root injectivity, since `(Xᵐ − 1)² = X^{2m} − 1` and
`((X+1)ᵐ)² = (X+1)^{2m}`. -/
theorem eq_imp_pow2 (n : ℕ) (hn : 0 < n)
    (heq : (X ^ n - 1 : (ZMod 2)[X]) = (X + 1) ^ n) : ∃ k, n = 2 ^ k := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases Nat.lt_or_ge n 2 with h1 | h2
    · interval_cases n
      · exact ⟨0, rfl⟩
    · have hev := even_of_eq n h2 heq
      have hdvd : 2 ∣ n := Fin.natCast_eq_zero.mp hev
      obtain ⟨m, rfl⟩ := hdvd
      have hm : 0 < m := by omega
      have hmlt : m < 2 * m := by omega
      have hred : (X ^ m - 1 : (ZMod 2)[X]) = (X + 1) ^ m := by
        apply sq_inj
        rw [sq_Xpow_sub, ← pow_mul, mul_comm m 2, heq]
      obtain ⟨k, hk⟩ := ih m hmlt hm hred
      exact ⟨k + 1, by rw [hk, pow_succ, mul_comm]⟩

/-- **Prime-power divisors.** If `(Xⁿ − 1) ∣ (X + 1)ᴺ` (with `n > 0`), then
`Xⁿ − 1 = (X + 1)ⁿ`.  Uses that `X + 1` is prime: divisors of `(X+1)ᴺ` are
associates of powers `(X+1)ⁱ`; both sides are monic so the association is
equality, and comparing `natDegree` forces `i = n`. -/
theorem dvd_imp_eq (n : ℕ) (hn : 0 < n) (N : ℕ)
    (hdvd : (X ^ n - 1 : (ZMod 2)[X]) ∣ (X + 1) ^ N) :
    (X ^ n - 1 : (ZMod 2)[X]) = (X + 1) ^ n := by
  obtain ⟨i, _hile, hassoc⟩ := (dvd_prime_pow Xadd1_prime N).mp hdvd
  have hmon1 : (X ^ n - 1 : (ZMod 2)[X]).Monic := by
    simpa using monic_X_pow_sub_C (1 : ZMod 2) hn.ne'
  have hmon2 : ((X + 1 : (ZMod 2)[X]) ^ i).Monic := by
    apply Monic.pow
    have : (X + 1 : (ZMod 2)[X]) = X + C 1 := by rw [C_1]
    rw [this]; exact monic_X_add_C 1
  have heqi : (X ^ n - 1 : (ZMod 2)[X]) = (X + 1) ^ i :=
    eq_of_monic_of_associated hmon1 hmon2 hassoc
  have hdeg := congrArg natDegree heqi
  rw [show (X ^ n - 1 : (ZMod 2)[X]).natDegree = n by
        simpa using natDegree_X_pow_sub_C (n := n) (r := (1 : ZMod 2))] at hdeg
  rw [show ((X + 1 : (ZMod 2)[X]) ^ i).natDegree = i by
        have : (X + 1 : (ZMod 2)[X]) = X + C 1 := by rw [C_1]
        rw [this, natDegree_pow, natDegree_X_add_C, mul_one]] at hdeg
  rw [heqi, hdeg]

/-! ## The cellular automaton as an element of a finite ring -/

/-- The state space of the additive CA on the cyclic lattice `ℤ/n`: the finite
ring `𝔽₂[X]/(Xⁿ − 1) ≅ 𝔽₂[ℤ/n]`, i.e. the coordinate ring of the group scheme
`μₙ` over `𝔽₂`. -/
abbrev Rq (n : ℕ) := (ZMod 2)[X] ⧸ Ideal.span ({X ^ n - 1} : Set ((ZMod 2)[X]))

/-- The additive elementary CA operator "`new cell = old cell + right neighbour`"
is multiplication by `u = 1 + X`; here is the ring element `u ∈ Rq n`. -/
def caUnit (n : ℕ) : Rq n := Ideal.Quotient.mk _ (X + 1)

/-- One time step of the automaton: multiply the configuration by `u = 1 + X`. -/
def caStep (n : ℕ) (s : Rq n) : Rq n := caUnit n * s

/-- Iterating the step map `t` times is multiplication by `uᵗ`. -/
theorem caStep_iterate (n : ℕ) (t : ℕ) (s : Rq n) :
    (caStep n)^[t] s = (caUnit n) ^ t * s := by
  induction t generalizing s with
  | zero => simp
  | succ t ih =>
    rw [Function.iterate_succ_apply, ih, caStep, pow_succ, mul_assoc, mul_comm (caUnit n)]

/-- Nilpotency of the CA operator is the polynomial divisibility statement
`∃ N, (Xⁿ − 1) ∣ (X + 1)ᴺ`. -/
theorem caUnit_isNilpotent_iff_dvd (n : ℕ) :
    IsNilpotent (caUnit n) ↔ ∃ N, (X ^ n - 1 : (ZMod 2)[X]) ∣ (X + 1) ^ N := by
  unfold caUnit IsNilpotent
  constructor
  · rintro ⟨N, hN⟩
    refine ⟨N, ?_⟩
    rw [← map_pow,
      ← map_zero (Ideal.Quotient.mk (Ideal.span ({X ^ n - 1} : Set ((ZMod 2)[X]))))] at hN
    rw [Ideal.Quotient.eq, sub_zero] at hN
    rwa [Ideal.mem_span_singleton] at hN
  · rintro ⟨N, hN⟩
    refine ⟨N, ?_⟩
    rw [← map_pow, Ideal.Quotient.eq_zero_iff_mem, Ideal.mem_span_singleton]
    exact hN

/-! ## Main bridge theorem -/

/-- **Wolfram ⇄ Grothendieck.** The additive elementary cellular automaton
`new = old + right-neighbour` on the cyclic lattice `ℤ/n` is *nilpotent* (its
transition operator `u = 1 + X` in `Rq n = 𝔽₂[X]/(Xⁿ − 1)` satisfies `uᴺ = 0`)
**iff** the lattice size `n` is a power of `2`.

Geometrically: the affine group scheme `μₙ = Spec 𝔽₂[X]/(Xⁿ − 1)` is a fat
(non-reduced, infinitesimal) point exactly when `n` is a power of the
characteristic `2`, and this scheme-theoretic degeneracy is equivalent to the
dynamical collapse of the automaton. -/
theorem caUnit_isNilpotent_iff (n : ℕ) (hn : 0 < n) :
    IsNilpotent (caUnit n) ↔ ∃ k, n = 2 ^ k := by
  rw [caUnit_isNilpotent_iff_dvd]
  constructor
  · rintro ⟨N, hdvd⟩
    exact eq_imp_pow2 n hn (dvd_imp_eq n hn N hdvd)
  · rintro ⟨k, rfl⟩
    exact ⟨2 ^ k, by rw [pow2_imp_eq k]⟩

/-- Dynamical restatement: **every** configuration reaches the all-zero state in
finitely many steps iff `n` is a power of `2`. -/
theorem ca_dies_iff_pow2 (n : ℕ) (hn : 0 < n) :
    (∀ s : Rq n, ∃ t, (caStep n)^[t] s = 0) ↔ ∃ k, n = 2 ^ k := by
  rw [← caUnit_isNilpotent_iff n hn]
  constructor
  · intro h
    obtain ⟨t, ht⟩ := h 1
    rw [caStep_iterate, mul_one] at ht
    exact ⟨t, ht⟩
  · rintro ⟨N, hN⟩ s
    exact ⟨N, by rw [caStep_iterate, hN, zero_mul]⟩

/-! ## Concrete instances -/

/-- `n = 4 = 2²`: the CA on the 4-cycle is nilpotent — every configuration dies. -/
theorem nilpotent_four : IsNilpotent (caUnit 4) :=
  (caUnit_isNilpotent_iff 4 (by norm_num)).mpr ⟨2, by norm_num⟩

/-- `n = 8 = 2³`: nilpotent. -/
theorem nilpotent_eight : IsNilpotent (caUnit 8) :=
  (caUnit_isNilpotent_iff 8 (by norm_num)).mpr ⟨3, by norm_num⟩

/-- `n = 3` is not a power of two, so the CA on the 3-cycle is **not** nilpotent:
some configuration cycles forever. -/
theorem not_nilpotent_three : ¬ IsNilpotent (caUnit 3) := by
  rw [caUnit_isNilpotent_iff 3 (by norm_num)]
  rintro ⟨k, hk⟩
  rcases k with _ | _ | k
  · simp at hk
  · simp at hk
  · have : 2 ^ (k + 2) ≥ 4 := by
      calc 2 ^ (k + 2) ≥ 2 ^ 2 := Nat.pow_le_pow_right (by norm_num) (by omega)
        _ = 4 := by norm_num
    omega

/-- `n = 6` is not a power of two: the CA on the 6-cycle is not nilpotent. -/
theorem not_nilpotent_six : ¬ IsNilpotent (caUnit 6) := by
  rw [caUnit_isNilpotent_iff 6 (by norm_num)]
  rintro ⟨k, hk⟩
  rcases k with _ | _ | _ | k
  · simp at hk
  · simp at hk
  · simp at hk
  · have : 2 ^ (k + 3) ≥ 8 := by
      calc 2 ^ (k + 3) ≥ 2 ^ 3 := Nat.pow_le_pow_right (by norm_num) (by omega)
        _ = 8 := by norm_num
    omega

end WolframGrothendieck