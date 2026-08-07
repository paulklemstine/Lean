/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.SchubertCalculus.FlagCount

/-!
# Schubert calculus XII: the Gaussian binomial as a ratio of `q`-factorials

The two point counts proved in this project —
`#Gr(k, V) = [n choose k]_q` (`SchubertCalculus.card_grassmannian_eq_poincare`) and
`#Fl(V) = [n]_q !` (`SchubertCalculus.card_completeFlag_eq_qFactorial`) — are related by the
fibration `Fl(V) → Gr(k, V)` sending a complete flag to its `k`-th member: the fibre over `W`
is `Fl(W) × Fl(V/W)`.  On point counts this predicts

`[n choose k]_q · [k]_q ! · [n-k]_q ! = [n]_q !`.

This file proves that identity as a *polynomial* identity over an arbitrary commutative
semiring, by induction from the `q`-Pascal recursion `SchubertCalculus.poincare_succ`, and then
deduces the geometric corollary over a finite field.  Together with
`SchubertCalculus.poincare_mul_gaussProd` (the closed product formula) this gives the two
classical closed forms of the Gaussian binomial coefficient.

Main results:

* `SchubertCalculus.qBracket_add` : `[n-k]_q + q^{n-k}·[k+1]_q = [n+1]_q`, the numerical shadow
  of `q`-Pascal;
* `SchubertCalculus.poincare_mul_qFact` : **the ratio formula**
  `[n choose k]_q · [k]_q ! · [n-k]_q ! = [n]_q !` over any commutative semiring;
* `SchubertCalculus.card_grassmannian_mul_card_flags` : the geometric form, a three-way
  point-count identity over a finite field.
-/

namespace SchubertCalculus

open Finset

/-! ### The `q`-factorial over an arbitrary commutative semiring -/

/-- The `q`-factorial `[N]_q ! = ∏_{j=1}^{N}(1 + q + ⋯ + q^{j-1})` over an arbitrary
commutative semiring.  Over `ℕ` this is `SchubertCalculus.qFactorial`. -/
def qFact (R : Type*) [CommSemiring R] (q : R) (N : ℕ) : R :=
  ∏ j ∈ range N, ∑ a ∈ range (j + 1), q ^ a

variable {R : Type*} [CommSemiring R] (q : R)

@[simp] lemma qFact_zero : qFact R q 0 = 1 := by simp [qFact]

lemma qFact_succ (N : ℕ) :
    qFact R q (N + 1) = qFact R q N * ∑ a ∈ range (N + 1), q ^ a := by
  simp [qFact, Finset.prod_range_succ]

lemma qFact_nat (q N : ℕ) : qFact ℕ q N = qFactorial q N := rfl

/-- The numerical shadow of the `q`-Pascal recursion: splitting `{0, …, n}` at `n-k` gives
`[n-k]_q + q^{n-k}·[k+1]_q = [n+1]_q`. -/
lemma qBracket_add {n k : ℕ} (hk : k ≤ n) :
    (∑ a ∈ range (n - k), q ^ a) + q ^ (n - k) * ∑ a ∈ range (k + 1), q ^ a
      = ∑ a ∈ range (n + 1), q ^ a := by
  have hsplit : n + 1 = (n - k) + (k + 1) := by omega
  conv_rhs => rw [hsplit, Finset.sum_range_add]
  congr 1
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by rw [← pow_add]

/-! ### The ratio formula -/

/-- **The Gaussian binomial coefficient is a ratio of `q`-factorials:**
`[n choose k]_q · [k]_q ! · [n-k]_q ! = [n]_q !` in every commutative semiring.

Geometrically this is the fibration of the complete flag variety over the Grassmannian, whose
fibre over a `k`-plane `W` is `Fl(W) × Fl(V/W)`.  The proof is an induction on `n` from the
`q`-Pascal recursion: the two terms of `q`-Pascal contribute `[n]_q !·[n-k]_q` and
`[n]_q !·q^{n-k}·[k+1]_q`, which add up to `[n]_q !·[n+1]_q = [n+1]_q !` by
`qBracket_add`. -/
theorem poincare_mul_qFact : ∀ (n k : ℕ), k ≤ n →
    poincare R k n q * (qFact R q k * qFact R q (n - k)) = qFact R q n := by
  intro n
  induction n with
  | zero =>
      intro k hk
      interval_cases k
      simp
  | succ n ih =>
      intro k hk
      match k with
      | 0 => simp
      | (j + 1) =>
        have hj : j ≤ n := by omega
        have hsub : n + 1 - (j + 1) = n - j := by omega
        -- the second `q`-Pascal term
        have hterm2 : q ^ (n - j) * poincare R j n q * (qFact R q (j + 1) * qFact R q (n - j))
            = qFact R q n * (q ^ (n - j) * ∑ a ∈ range (j + 1), q ^ a) := by
          have h := ih j hj
          rw [qFact_succ]
          calc q ^ (n - j) * poincare R j n q
                * (qFact R q j * (∑ a ∈ range (j + 1), q ^ a) * qFact R q (n - j))
              = (q ^ (n - j) * ∑ a ∈ range (j + 1), q ^ a)
                * (poincare R j n q * (qFact R q j * qFact R q (n - j))) := by ring
            _ = qFact R q n * (q ^ (n - j) * ∑ a ∈ range (j + 1), q ^ a) := by rw [h]; ring
        -- the first `q`-Pascal term
        have hterm1 : poincare R (j + 1) n q * (qFact R q (j + 1) * qFact R q (n - j))
            = qFact R q n * ∑ a ∈ range (n - j), q ^ a := by
          rcases Nat.lt_or_ge j n with hjn | hjn
          · have hsucc : n - j = (n - (j + 1)) + 1 := by omega
            have h := ih (j + 1) (by omega)
            rw [hsucc]
            nth_rewrite 2 [qFact_succ]
            calc poincare R (j + 1) n q
                  * (qFact R q (j + 1) * (qFact R q (n - (j + 1))
                    * ∑ a ∈ range (n - (j + 1) + 1), q ^ a))
                = (poincare R (j + 1) n q * (qFact R q (j + 1) * qFact R q (n - (j + 1))))
                    * ∑ a ∈ range (n - (j + 1) + 1), q ^ a := by ring
              _ = qFact R q n * ∑ a ∈ range (n - (j + 1) + 1), q ^ a := by rw [h]
          · rw [poincare_eq_zero q (by omega : n < j + 1),
              show n - j = 0 by omega]
            simp
        rw [hsub, poincare_succ, add_mul, hterm1, hterm2, ← mul_add, qBracket_add q hj,
          ← qFact_succ]

/-- The ratio formula over `ℕ`, in terms of `SchubertCalculus.qFactorial`. -/
theorem poincare_mul_qFactorial (q : ℕ) {n k : ℕ} (hk : k ≤ n) :
    poincare ℕ k n q * (qFactorial q k * qFactorial q (n - k)) = qFactorial q n :=
  poincare_mul_qFact q n k hk

/-! ### The geometric corollary -/

section Geometry

open Module

variable {K V : Type*} [Field K] [Fintype K] [AddCommGroup V] [Module K V]
  [FiniteDimensional K V]

/-- **Flag fibration count.**  Over a field with `q` elements, the number of `k`-planes of an
`n`-dimensional space, times the number of complete flags of a `k`-dimensional space, times
the number of complete flags of an `(n-k)`-dimensional space, is the number of complete flags
of the `n`-dimensional space.  This is the point-count shadow of the fibration
`Fl(V) → Gr(k, V)` with fibre `Fl(W) × Fl(V/W)`. -/
theorem card_grassmannian_mul_card_flags {n k : ℕ} (hn : n = finrank K V) (hk : k ≤ n) :
    Nat.card {W : Submodule K V // finrank K W = k}
        * (qFactorial (Fintype.card K) k * qFactorial (Fintype.card K) (n - k))
      = Nat.card (CompleteFlag K V n) := by
  subst hn
  rw [card_completeFlag_eq_qFactorial rfl, card_grassmannian_eq_poincare K V hk,
    poincare_mul_qFactorial _ hk]

end Geometry

/-! ### A worked case -/

/-- `Gr(2, 𝔽₂⁴)` has `35` points, `Fl(𝔽₂²)` has `3` and `Fl(𝔽₂⁴)` has `315 = 35 · 3 · 3`
points. -/
theorem qFactorial_four_two : qFactorial 2 4 = 315 := by decide

theorem poincare_mul_qFactorial_two_four :
    poincare ℕ 2 4 2 * (qFactorial 2 2 * qFactorial 2 2) = 315 := by
  rw [poincare_mul_qFactorial 2 (by norm_num : 2 ≤ 4)]
  exact qFactorial_four_two

end SchubertCalculus