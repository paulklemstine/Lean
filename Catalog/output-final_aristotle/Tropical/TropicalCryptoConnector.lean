/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# A Cross-Domain Bridge for Tropical Cryptography

This file establishes two theorems that connect three seemingly unrelated
mathematical areas around the *tropical* (min-plus) semiring, the algebraic
substrate proposed for "tropical Diffie–Hellman" key exchange.

The tropical semiring `Tropical (WithTop ℤ)` replaces ordinary `+` by `min`
and ordinary `*` by `+`.  Powers of tropical matrices `A ^ k` are the public
data of the *tropical discrete logarithm problem* (TDLP): given `A` and
`B = A ^ k`, recover `k`.

## The connector theorems

* `Matrix.pow_apply_eq_sum_path` — **Linear algebra ↔ combinatorial optimization.**
  For *any* semiring, the `(i,j)` entry of `A ^ k` is the sum, over all
  length-`k` walks `i = p₀, p₁, …, p_k = j` in the complete graph on the index
  set, of the product of the traversed matrix entries.  Specialised to the
  tropical semiring this is exactly the Bellman/Floyd shortest-walk identity:
  `A ^ k` records the minimum total weight of a `k`-step walk.  This is the
  bridge that the "shortest-path attack" on the TDLP exploits.

* `TropicalConnector.tropical_eigenvalue_additive` — **Spectral theory ↔
  additive arithmetic.**  A tropical eigenvector equation `A ⊗ v = λ ⊗ v`
  is preserved by taking matrix powers, and the eigenvalue of `A ^ k` is
  `k · λ`.  This additivity of tropical eigenvalues under powering is the
  precise reason the TDLP is *not* one-way: it turns the multiplicative
  discrete-log problem `B = A ^ k` into a linear equation `λ(B) = k · λ(A)`.

The general `mulVec` eigenvalue-power lemma
`TropicalConnector.mulVec_pow_eq_smul` is stated over an arbitrary commutative
semiring; the tropical statement is a specialisation.
-/

open Matrix Tropical

namespace TropicalConnector

/-- The tropical semiring over `ℤ ∪ {∞}` used for min-plus cryptography. -/
abbrev Trop := Tropical (WithTop ℤ)

/-! ## Spectral theory ↔ additive arithmetic -/

/-
**Eigenvalue–power lemma (general commutative semiring).**
If `v` is an eigenvector of `A` with scalar eigenvalue `lam`
(`A *ᵥ v = lam • v`), then `v` is an eigenvector of every power `A ^ k`
with eigenvalue `lam ^ k`.
-/
theorem mulVec_pow_eq_smul {V : Type*} [Fintype V] [DecidableEq V] {S : Type*}
    [CommSemiring S] (A : Matrix V V S) (v : V → S) (lam : S)
    (h : A *ᵥ v = lam • v) (k : ℕ) : (A ^ k) *ᵥ v = (lam ^ k) • v := by
  refine' Nat.recOn k _ _ <;> simp_all +decide [pow_succ']
  intro n hn; rw [← Matrix.mulVec_mulVec, hn]; simp +decide [Matrix.mulVec_smul]
  rw [h, smul_smul, mul_comm]

/-
**Tropical eigenvalues are additive under powering.**
If `v` is a tropical eigenvector of `A` with eigenvalue `lam`, then `v` is a
tropical eigenvector of `A ^ k` with eigenvalue `lam ^ k`, and the underlying
(min-plus) eigenvalue of `A ^ k` is `k` times that of `A`.  Hence recovering
`k` from `(A, A ^ k)` reduces to the linear equation `λ(A^k) = k · λ(A)`.
-/
theorem tropical_eigenvalue_additive {V : Type*} [Fintype V] [DecidableEq V]
    (A : Matrix V V Trop) (v : V → Trop) (lam : Trop)
    (h : A *ᵥ v = lam • v) (k : ℕ) :
    (A ^ k) *ᵥ v = (lam ^ k) • v ∧ untrop (lam ^ k) = k • untrop lam := by
  refine' ⟨_, _⟩
  · exact mulVec_pow_eq_smul A v lam h k
  · exact untrop_pow lam k

/-! ## Linear algebra ↔ combinatorial optimization (shortest walks) -/

/-
**Matrix-power / walk-sum bridge (general semiring).**
The `(i,j)` entry of the `k`-th matrix power is the sum over all length-`k`
walks `p₀ = i, …, p_k = j` of the product of the traversed entries.

Over the tropical semiring, the sum is a `min` and the product is a `+`, so
this says `A ^ k` records the minimum total weight of a `k`-step walk from `i`
to `j` — the shortest-path interpretation of tropical matrix powers.
-/
theorem _root_.Matrix.pow_apply_eq_sum_path {V : Type*} [Fintype V]
    [DecidableEq V] {S : Type*} [CommSemiring S] (A : Matrix V V S) (k : ℕ)
    (i j : V) :
    (A ^ k) i j =
      ∑ p : {p : Fin (k + 1) → V // p 0 = i ∧ p (Fin.last k) = j},
        ∏ t : Fin k, A (p.1 t.castSucc) (p.1 t.succ) := by
  induction' k with k ih generalizing i j <;> simp +decide [ *, pow_succ, Matrix.mul_apply ];
  · by_cases hij : i = j <;> simp +decide [ hij, Matrix.one_apply ];
    · rw [ Fintype.card_eq_one_iff.mpr ] ; aesop;
      exact ⟨ ⟨ fun _ => j, rfl ⟩, fun y => Subtype.ext <| funext fun x => by fin_cases x; aesop ⟩;
    · rw [ Fintype.card_eq_zero_iff.mpr ];
      · grind;
      · exact ⟨ fun p => hij <| p.2.1.symm.trans p.2.2 ⟩;
  · simp +decide only [Finset.sum_mul _ _ _];
    rw [ Finset.sum_sigma' ];
    refine' Finset.sum_bij ( fun p _ => ⟨ Fin.snoc p.2.1 j, by aesop ⟩ ) _ _ _ _ <;> simp +decide;
    · aesop;
    · intro a ha₁ ha₂; use Fin.init a; aesop;
    · rintro ⟨ w, p, hp ⟩ ; rw [ Fin.prod_univ_castSucc ] ; simp +decide [ hp, Fin.snoc ] ;
      congr! 2

end TropicalConnector