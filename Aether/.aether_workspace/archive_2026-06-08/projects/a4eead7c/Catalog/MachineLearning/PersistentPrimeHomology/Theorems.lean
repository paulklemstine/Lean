/-
# Persistent Homology of Prime Numbers: Core Theorems

This module proves fundamental theorems connecting prime number theory
to persistent homology via the Rips filtration.

1. **Monotonicity of connectivity**: Increasing ε can only merge components
2. **EpsAdj symmetry and scale monotonicity**: Basic graph-theoretic properties
3. **Chain transitivity and scale lifting**: ε-connectivity forms an equivalence relation
4. **Bertrand's postulate implies bounded connectivity scale**
5. **Cross-domain bridge**: Prime gaps ↔ graph structure (SimpleGraph)
-/

import Mathlib
import Speculative.AutoResearch.PersistentPrimeHomology.Defs

open Nat Finset

/-! ## EpsAdj Properties -/

/-- EpsAdj is symmetric -/
theorem epsAdj_symm {eps a b : ℕ} (h : EpsAdj eps a b) : EpsAdj eps b a :=
  ⟨Ne.symm h.1, natDist_symm a b ▸ h.2⟩

/-- EpsAdj is monotone in the scale parameter -/
theorem epsAdj_mono {eps₁ eps₂ : ℕ} (h : eps₁ ≤ eps₂) {a b : ℕ}
    (hadj : EpsAdj eps₁ a b) : EpsAdj eps₂ a b :=
  ⟨hadj.1, le_trans hadj.2 h⟩

/-! ## Chain Properties -/

/-- ε-chains are monotone in ε: the fundamental monotonicity of the Rips filtration -/
theorem epsChain_mono {S : Set ℕ} {eps₁ eps₂ : ℕ} (h : eps₁ ≤ eps₂) {a b : ℕ}
    (hchain : EpsChain S eps₁ a b) : EpsChain S eps₂ a b := by
  induction hchain with
  | refl a ha => exact EpsChain.refl a ha
  | step a b c ha hb hadj _ ih =>
    exact EpsChain.step a b c ha hb (epsAdj_mono h hadj) ih

/-- The start of an ε-chain belongs to S -/
theorem epsChain_start_mem {S : Set ℕ} {eps a b : ℕ}
    (h : EpsChain S eps a b) : a ∈ S := by
  cases h with
  | refl _ ha => exact ha
  | step _ _ _ ha _ _ _ => exact ha

/-- The end of an ε-chain belongs to S -/
theorem epsChain_end_mem {S : Set ℕ} {eps a b : ℕ}
    (h : EpsChain S eps a b) : b ∈ S := by
  induction h with
  | refl _ ha => exact ha
  | step _ _ _ _ _ _ _ ih => exact ih

/-- ε-chains can be concatenated (transitivity) -/
theorem epsChain_trans {S : Set ℕ} {eps : ℕ} {a b c : ℕ}
    (h1 : EpsChain S eps a b) (h2 : EpsChain S eps b c) : EpsChain S eps a c := by
  induction h1 with
  | refl _ _ => exact h2
  | step a' b' _ ha' hb' hadj _ ih =>
    exact EpsChain.step a' b' c ha' hb' hadj (ih h2)

/-- ε-chains are symmetric -/
theorem epsChain_symm {S : Set ℕ} {eps : ℕ} {a b : ℕ}
    (h : EpsChain S eps a b) : EpsChain S eps b a := by
  induction h with
  | refl a ha => exact EpsChain.refl a ha
  | step a' b' _ ha' hb' hadj _ ih =>
    exact epsChain_trans ih
      (EpsChain.step b' a' a' hb' ha' (epsAdj_symm hadj) (EpsChain.refl a' ha'))

/-! ## EpsConnected: an equivalence relation -/

theorem epsConnected_refl {S : Set ℕ} {eps : ℕ} {a : ℕ} (ha : a ∈ S) :
    EpsConnected S eps a a := EpsChain.refl a ha

theorem epsConnected_symm {S : Set ℕ} {eps : ℕ} {a b : ℕ}
    (h : EpsConnected S eps a b) : EpsConnected S eps b a := epsChain_symm h

theorem epsConnected_trans {S : Set ℕ} {eps : ℕ} {a b c : ℕ}
    (h1 : EpsConnected S eps a b) (h2 : EpsConnected S eps b c) :
    EpsConnected S eps a c := epsChain_trans h1 h2

theorem epsConnected_mono {S : Set ℕ} {eps₁ eps₂ : ℕ} (h : eps₁ ≤ eps₂) {a b : ℕ}
    (hconn : EpsConnected S eps₁ a b) : EpsConnected S eps₂ a b :=
  epsChain_mono h hconn

/-! ## Consecutive Primes and Gaps -/

/-- Two primes within distance ε are ε-connected in the set of all primes -/
theorem consecutive_primes_connected {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hlt : p < q) (eps : ℕ) (heps : q - p ≤ eps) :
    EpsConnected {n : ℕ | Nat.Prime n} eps p q := by
  apply EpsChain.step p q q
  · exact hp
  · exact hq
  · exact ⟨by omega, by simp [natDist]; split <;> omega⟩
  · exact EpsChain.refl q hq

/-- The gap between consecutive primes determines when they merge -/
theorem gap_determines_bar_death {p q : ℕ} (hlt : p < q) :
    ∀ eps, EpsAdj eps p q ↔ q - p ≤ eps := by
  intro eps
  constructor
  · intro ⟨_, hdist⟩
    simp [natDist] at hdist; split at hdist <;> omega
  · intro h
    exact ⟨by omega, by simp [natDist]; split <;> omega⟩

/-! ## Bertrand's Postulate and Persistent Homology -/

/-- Bertrand's postulate: there exists a prime between p and 2p -/
theorem bertrand_gap_bound (p : ℕ) (hp : p ≠ 0) :
    ∃ q, Nat.Prime q ∧ p < q ∧ q ≤ 2 * p :=
  Nat.exists_prime_lt_and_le_two_mul p hp

/-
Bertrand implies any two consecutive primes p, q satisfy q - p ≤ p.
    In persistent homology terms: no H₀ bar has death exceeding its birth prime.
-/
theorem bertrand_bar_length_bound {p q : ℕ} (hp : Nat.Prime p) (_hq : Nat.Prime q)
    (hpq : p < q) (hconsec : ∀ r, Nat.Prime r → p < r → r < q → False) :
    q - p ≤ p := by
  -- Apply Bertrand's postulate to obtain a prime $r$ such that $p < r \leq 2p$.
  obtain ⟨r, hr_prime, hr_range⟩ : ∃ r, Nat.Prime r ∧ p < r ∧ r ≤ 2 * p := by
    exact Nat.exists_prime_lt_and_le_two_mul p hp.ne_zero;
  grind +ring

/-! ## Cross-Domain: Number Theory ↔ Graph Theory -/

/-- The prime gap graph: a SimpleGraph on ℕ where primes below N are
    connected if their distance is ≤ ε. This bridges number theory
    (prime distribution) with graph theory (connectivity, coloring). -/
def PrimeGapGraph (N eps : ℕ) : SimpleGraph ℕ where
  Adj a b := a ∈ primeSetBelow N ∧ b ∈ primeSetBelow N ∧ EpsAdj eps a b
  symm a b := by
    intro ⟨ha, hb, hadj⟩
    exact ⟨hb, ha, epsAdj_symm hadj⟩
  loopless := ⟨fun a ⟨_, _, h, _⟩ => h rfl⟩

/-- Monotonicity: the prime gap graph gains edges as ε increases -/
theorem primeGapGraph_mono {N eps₁ eps₂ : ℕ} (h : eps₁ ≤ eps₂) :
    ∀ a b, (PrimeGapGraph N eps₁).Adj a b → (PrimeGapGraph N eps₂).Adj a b := by
  intro a b ⟨ha, hb, hadj⟩
  exact ⟨ha, hb, epsAdj_mono h hadj⟩

/-- At scale 0, the prime gap graph has no edges -/
theorem primeGapGraph_scale_zero_no_edges (N a b : ℕ) :
    ¬(PrimeGapGraph N 0).Adj a b := by
  intro ⟨_, _, _, hdist⟩
  simp [natDist] at hdist; split at hdist <;> omega

/-
Any two odd primes differ by at least 2, so they are NOT ε-adjacent at scale 1.
    This means 2 and its neighbor 3 form the only edge at scale 1 in the prime graph.
-/
theorem odd_primes_not_adj_at_scale_one {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hp2 : 2 < p) (hq2 : 2 < q) (_hne : p ≠ q) :
    ¬EpsAdj 1 p q := by
  unfold EpsAdj; intro h; cases h with | intro h1 h2 =>
  unfold natDist at h2; cases le_total p q <;> simp_all +decide [ Nat.sub_eq_zero_of_le ] ;
  · cases Nat.Prime.eq_two_or_odd hp <;> cases Nat.Prime.eq_two_or_odd hq <;> omega;
  · split_ifs at h2 <;> cases Nat.Prime.eq_two_or_odd hp <;> cases Nat.Prime.eq_two_or_odd hq <;> omega;;

/-! ## Structural Properties of the Filtration -/

/-- Adjacent primes from proximity -/
theorem prime_adj_from_nearby {p q eps : ℕ}
    (hlt : p < q) (hclose : q ≤ p + eps) :
    EpsAdj eps p q :=
  ⟨by omega, by simp [natDist]; split <;> omega⟩

/-- Monotonicity in the ambient set: enlarging S preserves ε-chains -/
theorem epsChain_subset_mono {S T : Set ℕ} {eps a b : ℕ} (hST : S ⊆ T)
    (hchain : EpsChain S eps a b) : EpsChain T eps a b := by
  induction hchain with
  | refl a ha => exact EpsChain.refl a (hST ha)
  | step a' b' c ha' hb' hadj _ ih =>
    exact EpsChain.step a' b' c (hST ha') (hST hb') hadj ih

/-- Components can only merge as ε increases (restated for clarity) -/
theorem components_decrease_with_scale {S : Set ℕ} {eps₁ eps₂ : ℕ} {a b : ℕ}
    (h : eps₁ ≤ eps₂) (hconn : EpsConnected S eps₁ a b) :
    EpsConnected S eps₂ a b :=
  epsConnected_mono h hconn

/-! ## Barcode Structure -/

@[simp] theorem listGaps_singleton (a : ℕ) : listGaps [a] = [] := rfl

/-
listGaps preserves length minus one
-/
theorem listGaps_length : ∀ (l : List ℕ), 2 ≤ l.length →
    (listGaps l).length = l.length - 1 := by
  intro l hl;
  -- Apply induction on the length of the list.
  induction' l with a l ih;
  · contradiction;
  · rcases l with ( _ | ⟨ b, l ⟩ ) <;> simp_all +arith +decide;
    cases l <;> simp_all +arith +decide [ listGaps ]

/-! ## Falsifiable Conjecture (Topological Twin Prime Signature)

The twin prime conjecture is equivalent to saying the H₀ barcode has
infinitely many bars of persistence exactly 2. -/

/-- The twin prime conjecture in barcode language -/
def TwinPrimeBarcode : Prop :=
  ∀ M : ℕ, ∃ p : ℕ, M < p ∧ Nat.Prime p ∧ Nat.Prime (p + 2)

/-- Testable prediction: for any N ≥ 10, there exists at least one
    twin prime pair below N. (True and provable for small N.) -/
theorem exists_twin_prime_below_10 :
    ∃ p, p < 10 ∧ Nat.Prime p ∧ Nat.Prime (p + 2) := by
  exact ⟨3, by omega, by norm_num, by norm_num⟩