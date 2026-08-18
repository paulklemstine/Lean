/-
# The Price of Universality IX: finite-state sources

Research thread *Compression Beyond the Pigeonhole Bound*, Phase A, Question 1.

The catalog covers memoryless sources (`MachineLearning.UniversalRedundancy.Types`)
and first-order Markov sources (`.Markov`).  The natural common generalisation —
and the model underlying the Lempel-Ziv theory — is the **finite-state source**:
a deterministic automaton `δ : S → A → S` reads the message, and the emission
law of the next letter depends only on the current state.  Order-`r` Markov
sources are the special case `S = Aʳ`.

This file constructs the finite-state class and bounds its price of
universality:

`Cₛ ≤ (n + 1) ^ (#S · #A)`,  i.e.  price `≤ #S · #A · log₂ (n + 1)` bits,

logarithmic in the message length with the *number of automaton parameters* as
the multiplier.  Since the class complexity `#S · #A` enters only as a
coefficient of `log₂ n`, even a large automaton is affordable for long messages:
the per-symbol price still vanishes.

## Main results

* `fsmProb`, `fsmStates` — recursive likelihood and state trajectory
* `fsmProb_sum_one` — the finite-state likelihood is a probability distribution
* `fsmProb_eq_prod` — likelihood as a product over positions of the emission
  probabilities along the state trajectory
* `fsmClass` — the finite-state source class
* `shtarkovSum_fsmClass_le` — `Cₛ ≤ (n+1) ^ (#S · #A)`
* `fsm_price_le_bits` — the bit-level bound
* `fsmClass_iid_of_unique` — with a single state the class *is* the memoryless
  class, so the bound specialises correctly

## Application keywords

finite-state sources, Lempel-Ziv, method of types, minimax redundancy, Shtarkov
sum, automaton complexity
-/

import Logic.PriceOfUniversality.TypeDimension

open Finset Real

namespace UniversalRedundancy

variable {A S : Type*} [Fintype A] [DecidableEq A] [Fintype S] [DecidableEq S]

/-- The parameter of a finite-state source: an emission law for each state. -/
def FSMParam (A S : Type*) [Fintype A] : Type _ :=
  {g : S → A → ℝ // ∀ s, (∀ a, 0 ≤ g s a) ∧ ∑ a, g s a = 1}

instance [Nonempty A] : Nonempty (FSMParam A S) := by
  have hcard : (Fintype.card A : ℝ) ≠ 0 := by
    have : 0 < Fintype.card A := Fintype.card_pos
    positivity
  exact ⟨⟨fun _ _ => (Fintype.card A : ℝ)⁻¹, fun _ => ⟨fun _ => by positivity, by
    rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    field_simp⟩⟩⟩

/-- The likelihood of a message under a finite-state source with transition
function `δ`, emission laws `g` and initial state `s`. -/
def fsmProb (δ : S → A → S) (g : S → A → ℝ) : (n : ℕ) → S → (Fin n → A) → ℝ
  | 0, _, _ => 1
  | (n + 1), s, x => g s (x 0) * fsmProb δ g n (δ s (x 0)) (Fin.tail x)

/-- The state trajectory of the automaton while reading a message. -/
def fsmStates (δ : S → A → S) : (n : ℕ) → S → (Fin n → A) → (Fin n → S)
  | 0, _, _ => fun i => i.elim0
  | (n + 1), s, x => Fin.cons s (fsmStates δ n (δ s (x 0)) (Fin.tail x))

omit [Fintype A] [DecidableEq A] [Fintype S] [DecidableEq S] in
lemma fsmProb_nonneg (δ : S → A → S) {g : S → A → ℝ} (hg : ∀ s a, 0 ≤ g s a) :
    ∀ (n : ℕ) (s : S) (x : Fin n → A), 0 ≤ fsmProb δ g n s x
  | 0, _, _ => by simp [fsmProb]
  | (n + 1), s, x => by
      rw [fsmProb]
      exact mul_nonneg (hg _ _) (fsmProb_nonneg δ hg n _ _)

omit [DecidableEq A] [Fintype S] [DecidableEq S] in
/-- **The finite-state likelihood is a probability distribution on messages.**
Proved by peeling off the first letter: summing over it uses stochasticity of
the emission law at the current state, and the rest is the inductive
hypothesis at the successor state. -/
lemma fsmProb_sum_one (δ : S → A → S) {g : S → A → ℝ} (hg : ∀ s, ∑ a, g s a = 1) :
    ∀ (n : ℕ) (s : S), ∑ x : Fin n → A, fsmProb δ g n s x = 1
  | 0, s => by simp [fsmProb]
  | (n + 1), s => by
      classical
      have hsplit : ∑ x : Fin (n + 1) → A, fsmProb δ g (n + 1) s x
          = ∑ a : A, ∑ y : Fin n → A, fsmProb δ g (n + 1) s (Fin.cons a y) := by
        rw [← Equiv.sum_comp (Fin.consEquiv (fun _ : Fin (n + 1) => A))
          (fsmProb δ g (n + 1) s), Fintype.sum_prod_type]
        rfl
      rw [hsplit]
      have hinner : ∀ a : A, ∑ y : Fin n → A, fsmProb δ g (n + 1) s (Fin.cons a y)
          = g s a := by
        intro a
        have hterm : ∀ y : Fin n → A, fsmProb δ g (n + 1) s (Fin.cons a y)
            = g s a * fsmProb δ g n (δ s a) y := by
          intro y
          rw [fsmProb]
          simp
        rw [Finset.sum_congr rfl fun y _ => hterm y, ← Finset.mul_sum,
          fsmProb_sum_one δ hg n (δ s a), mul_one]
      rw [Finset.sum_congr rfl fun a _ => hinner a]
      exact hg s

omit [Fintype A] [DecidableEq A] [Fintype S] [DecidableEq S] in
/-- The finite-state likelihood is the product, over positions, of the emission
probability of the letter at the state the automaton is in. -/
lemma fsmProb_eq_prod (δ : S → A → S) (g : S → A → ℝ) :
    ∀ (n : ℕ) (s : S) (x : Fin n → A),
      fsmProb δ g n s x = ∏ j, g (fsmStates δ n s x j) (x j)
  | 0, _, _ => by simp [fsmProb]
  | (n + 1), s, x => by
      rw [fsmProb, fsmProb_eq_prod δ g n (δ s (x 0)) (Fin.tail x), Fin.prod_univ_succ]
      simp [fsmStates, Fin.tail]

/-- The class of finite-state sources with automaton `δ` and initial state `s₀`
on messages of length `n`. -/
def fsmClass (δ : S → A → S) (s₀ : S) (n : ℕ) :
    SourceClass (Fin n → A) (FSMParam A S) where
  prob θ x := fsmProb δ θ.1 n s₀ x
  nonneg θ x := fsmProb_nonneg δ (fun s a => (θ.2 s).1 a) n s₀ x
  sum_one θ := fsmProb_sum_one δ (fun s => (θ.2 s).2) n s₀

/-- **The price of universality of a finite-state class.**  The Shtarkov sum is
at most `(n+1) ^ (#S · #A)`: the counts of (state, emitted letter) pairs are a
sufficient statistic, and there are at most `(n+1)` values for each of the
`#S · #A` counts. -/
theorem shtarkovSum_fsmClass_le [Nonempty A] (δ : S → A → S) (s₀ : S) (n : ℕ) :
    (fsmClass δ s₀ n).shtarkovSum
      ≤ ((n + 1 : ℕ) : ℝ) ^ (Fintype.card S * Fintype.card A) := by
  classical
  have h := (fsmClass δ s₀ n).shtarkovSum_le_of_product_form
    (B := S × A) (C := Unit) (m := n)
    (feat := fun x j => (fsmStates δ n s₀ x j, x j)) (init := fun _ => ())
    (g := fun θ p => θ.1 p.1 p.2) (h := fun _ _ => 1)
    (by
      intro θ x
      show fsmProb δ θ.1 n s₀ x = 1 * ∏ j, θ.1 (fsmStates δ n s₀ x j) (x j)
      rw [one_mul, fsmProb_eq_prod])
  rwa [Fintype.card_prod, Fintype.card_unit, Nat.cast_one, one_mul] at h

/-- **Bit form.**  One universal code is within `#S · #A · log₂ (n+1)` bits of
the code tailored to the true finite-state source, for every source in the class
and every message. -/
theorem fsm_price_le_bits [Nonempty A] (δ : S → A → S) (s₀ : S) (n : ℕ) :
    logb 2 (fsmClass δ s₀ n).shtarkovSum
      ≤ (Fintype.card S : ℝ) * (Fintype.card A : ℝ) * logb 2 ((n : ℝ) + 1) := by
  have hC := shtarkovSum_fsmClass_le δ s₀ n
  have hbase : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
  rw [hbase] at hC
  have hle : logb 2 (fsmClass δ s₀ n).shtarkovSum
      ≤ logb 2 (((n : ℝ) + 1) ^ (Fintype.card S * Fintype.card A)) :=
    Real.logb_le_logb_of_le (by norm_num) (fsmClass δ s₀ n).shtarkovSum_pos hC
  rw [Real.logb_pow] at hle
  push_cast at hle
  linarith

omit [DecidableEq A] [Fintype S] [DecidableEq S] in
/-- **Sanity check: one state means memoryless.**  With a single automaton state
the finite-state likelihood is the i.i.d. likelihood of the emission law, so the
bound above degenerates to the memoryless bound `(n+1) ^ #A`. -/
theorem fsmClass_prob_unique [Unique S] (δ : S → A → S) (s₀ : S) (n : ℕ)
    (θ : FSMParam A S) (x : Fin n → A) :
    (fsmClass δ s₀ n).prob θ x = ∏ j, θ.1 s₀ (x j) := by
  classical
  rw [show (fsmClass δ s₀ n).prob θ x = fsmProb δ θ.1 n s₀ x from rfl,
    fsmProb_eq_prod]
  exact Finset.prod_congr rfl fun j _ => by rw [Subsingleton.elim (fsmStates δ n s₀ x j) s₀]

end UniversalRedundancy