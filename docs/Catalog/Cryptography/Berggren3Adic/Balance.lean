import Mathlib
import Cryptography.Berggren3Adic.Blindness

/-!
# The branch letter is the balance band of the factorisation (BERGGREN-3ADIC, part IV)

Second cycle.  Part III sealed the branch letter against every *odd* modulus using the
witnesses `(M+1, M)`, `(3M−1, M)`, `(3M+1, M)`; the `A`-witness there has `m − n = 1`,
i.e. it encodes the trivial factorisation `N = 1 · N`.  Here both weaknesses are removed.

* `Berggren3Adic.letter_of_factorization` — **the letter is the balance band**: for
  `N = p q` with `0 < p < q` odd, the first Berggren letter of the `N`-node is
  `A ↔ 3p < q`, `B ↔ 2p < q ≤ 3p`, `C ↔ q ≤ 2p`.  So the letter is a coarse measurement
  of how balanced the factorisation is — which is exactly why reading it would help a
  factoring attack, and exactly what the next theorem forbids.
* `Berggren3Adic.all_letters_in_one_residue_class_proper` — for **every** modulus
  `M ≥ 2`, odd or even, one residue class of `N` contains nodes of all three letters,
  each encoding a *nontrivial* factorisation (`m − n ≥ 2M − 1 ≥ 3`).
* `Berggren3Adic.no_letter_function_proper`,
  `Berggren3Adic.balance_band_not_computable` — hence no function of `N mod M` computes
  the letter, nor the balance band of the factorisation, even when restricted to nodes
  with nontrivial factors.
-/

namespace Berggren3Adic

open BergGen

/-! ## The letter reads the balance of the factorisation -/

/-- **The branch letter is the balance band of the factorisation.**
For `N = p q` with `0 < p < q` both odd, the Berggren letter of the `N`-node is
`A` iff `q > 3p`, `B` iff `2p < q ≤ 3p`, and `C` iff `q ≤ 2p`. -/
theorem letter_of_factorization {p q : ℤ} (hp : p % 2 = 1) (hq : q % 2 = 1)
    (hpq : p < q) :
    (letterOf ((q + p) / 2, (q - p) / 2) = A ↔ 3 * p < q) ∧
    (letterOf ((q + p) / 2, (q - p) / 2) = B ↔ (2 * p < q ∧ q ≤ 3 * p)) ∧
    (letterOf ((q + p) / 2, (q - p) / 2) = C ↔ q ≤ 2 * p) := by
  obtain ⟨s, hs⟩ : ∃ s : ℤ, q + p = 2 * s := ⟨(q + p) / 2, by omega⟩
  obtain ⟨t, ht⟩ : ∃ t : ℤ, q - p = 2 * t := ⟨(q - p) / 2, by omega⟩
  have hsv : (q + p) / 2 = s := by omega
  have htv : (q - p) / 2 = t := by omega
  rw [hsv, htv]
  refine ⟨?_, ?_, ?_⟩
  · rw [letter_eq_A_iff]
    constructor <;> intro h <;> simp only at * <;> omega
  · rw [letter_eq_B_iff]
    constructor <;> intro h <;> simp only at * <;> omega
  · rw [letter_eq_C_iff (by simp only; omega)]
    constructor <;> intro h <;> simp only at * <;> omega

/-! ## Proper witnesses: nontrivial factorisations, every modulus -/

/-- Proper `A`-witness `(4M−1, 2M)`: factorisation `N = (2M−1)(6M−1)`. -/
def pwitA (M : ℤ) : ℤ × ℤ := (4 * M - 1, 2 * M)
/-- Proper `B`-witness `(4M+1, 2M)`: factorisation `N = (2M+1)(6M+1)`. -/
def pwitB (M : ℤ) : ℤ × ℤ := (4 * M + 1, 2 * M)
/-- Proper `C`-witness `(6M+1, 2M)`: factorisation `N = (4M+1)(8M+1)`. -/
def pwitC (M : ℤ) : ℤ × ℤ := (6 * M + 1, 2 * M)

theorem fermatPair_pwitA {M : ℤ} (hM : 1 ≤ M) : FermatPair (pwitA M) :=
  ⟨by simp only [pwitA]; omega, by simp only [pwitA]; omega,
    ⟨-1, 2, by simp only [pwitA]; ring⟩, by simp only [pwitA]; omega⟩

theorem fermatPair_pwitB {M : ℤ} (hM : 1 ≤ M) : FermatPair (pwitB M) :=
  ⟨by simp only [pwitB]; omega, by simp only [pwitB]; omega,
    ⟨1, -2, by simp only [pwitB]; ring⟩, by simp only [pwitB]; omega⟩

theorem fermatPair_pwitC {M : ℤ} (hM : 1 ≤ M) : FermatPair (pwitC M) :=
  ⟨by simp only [pwitC]; omega, by simp only [pwitC]; omega,
    ⟨1, -3, by simp only [pwitC]; ring⟩, by simp only [pwitC]; omega⟩

theorem letterOf_pwitA (M : ℤ) : letterOf (pwitA M) = A := by
  simp only [letterOf, pwitA]
  rw [if_pos (by omega)]

theorem letterOf_pwitB {M : ℤ} (hM : 1 ≤ M) : letterOf (pwitB M) = B := by
  simp only [letterOf, pwitB]
  rw [if_neg (by omega), if_pos (by omega)]

theorem letterOf_pwitC {M : ℤ} (hM : 1 ≤ M) : letterOf (pwitC M) = C := by
  simp only [letterOf, pwitC]
  rw [if_neg (by omega), if_neg (by omega)]

theorem nOf_pwitA (M : ℤ) : nOf (pwitA M) = (2 * M - 1) * (6 * M - 1) := by
  simp only [nOf, pwitA]; ring

theorem nOf_pwitB (M : ℤ) : nOf (pwitB M) = (2 * M + 1) * (6 * M + 1) := by
  simp only [nOf, pwitB]; ring

theorem nOf_pwitC (M : ℤ) : nOf (pwitC M) = (4 * M + 1) * (8 * M + 1) := by
  simp only [nOf, pwitC]; ring

/-- **All three letters in one residue class, with nontrivial factorisations, at every
modulus `M ≥ 2`** (no parity restriction on `M`).  This strengthens
`all_letters_in_one_residue_class` in two directions at once. -/
theorem all_letters_in_one_residue_class_proper {M : ℤ} (hM : 2 ≤ M) :
    ∃ p₁ p₂ p₃ : ℤ × ℤ,
      FermatPair p₁ ∧ FermatPair p₂ ∧ FermatPair p₃ ∧
      M ∣ nOf p₁ - 1 ∧ M ∣ nOf p₂ - 1 ∧ M ∣ nOf p₃ - 1 ∧
      3 ≤ p₁.1 - p₁.2 ∧ 3 ≤ p₂.1 - p₂.2 ∧ 3 ≤ p₃.1 - p₃.2 ∧
      letterOf p₁ = A ∧ letterOf p₂ = B ∧ letterOf p₃ = C := by
  have hM1 : (1 : ℤ) ≤ M := by omega
  refine ⟨pwitA M, pwitB M, pwitC M, fermatPair_pwitA hM1, fermatPair_pwitB hM1,
    fermatPair_pwitC hM1, ⟨12 * M - 8, by rw [nOf_pwitA]; ring⟩,
    ⟨12 * M + 8, by rw [nOf_pwitB]; ring⟩, ⟨32 * M + 12, by rw [nOf_pwitC]; ring⟩,
    by simp only [pwitA]; omega, by simp only [pwitB]; omega, by simp only [pwitC]; omega,
    letterOf_pwitA M, letterOf_pwitB hM1, letterOf_pwitC hM1⟩

/-- **No `N`-computable projection of the branch letter, at any modulus `M ≥ 2`, even on
nodes with nontrivial factorisation.** -/
theorem no_letter_function_proper {M : ℤ} (hM : 2 ≤ M) (f : ℤ → BergGen)
    (hf : ∀ a b : ℤ, M ∣ a - b → f a = f b) :
    ∃ p : ℤ × ℤ, FermatPair p ∧ 3 ≤ p.1 - p.2 ∧ f (nOf p) ≠ letterOf p := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨p₁, p₂, p₃, h1, h2, h3, d1, d2, d3, n1, n2, n3, l1, l2, l3⟩ :=
    all_letters_in_one_residue_class_proper hM
  have e12 : f (nOf p₁) = f (nOf p₂) := by
    refine hf _ _ ?_
    obtain ⟨c₁, hc₁⟩ := d1
    obtain ⟨c₂, hc₂⟩ := d2
    exact ⟨c₁ - c₂, by linarith⟩
  rw [hcon p₁ h1 n1, hcon p₂ h2 n2, l1, l2] at e12
  exact absurd e12 (by decide)

/-- **The balance band of the factorisation is not readable from `N mod M`.**
For every modulus `M ≥ 2` there are two nodes with `N` in the same class mod `M`, both
with nontrivial factorisations `N = (m−n)(m+n)`, one *unbalanced* (`3(m−n) < m+n`, letter
`A`) and one *balanced* (`m+n ≤ 2(m−n)`, letter `C`).  No function of `N mod M` can
separate them. -/
theorem balance_band_not_computable {M : ℤ} (hM : 2 ≤ M) :
    ∃ p₁ p₂ : ℤ × ℤ, FermatPair p₁ ∧ FermatPair p₂ ∧
      M ∣ nOf p₁ - nOf p₂ ∧
      3 * (p₁.1 - p₁.2) < p₁.1 + p₁.2 ∧ p₂.1 + p₂.2 ≤ 2 * (p₂.1 - p₂.2) := by
  have hM1 : (1 : ℤ) ≤ M := by omega
  refine ⟨pwitA M, pwitC M, fermatPair_pwitA hM1, fermatPair_pwitC hM1, ?_, ?_, ?_⟩
  · refine ⟨-20 * M - 20, ?_⟩
    rw [nOf_pwitA, nOf_pwitC]
    ring
  · simp only [pwitA]; omega
  · simp only [pwitC]; omega

/-- The 3-adic form of the strengthened seal: at every level `3^k`, `k ≥ 1`, the branch
letter of a node with nontrivial factorisation is not a function of `N mod 3^k`. -/
theorem letter_sealed_three_adically_proper (k : ℕ) (hk : 1 ≤ k) (f : ℤ → BergGen)
    (hf : ∀ a b : ℤ, (3 : ℤ) ^ k ∣ a - b → f a = f b) :
    ∃ p : ℤ × ℤ, FermatPair p ∧ 3 ≤ p.1 - p.2 ∧ f (nOf p) ≠ letterOf p := by
  refine no_letter_function_proper (M := (3 : ℤ) ^ k) ?_ f hf
  calc (2 : ℤ) ≤ 3 ^ 1 := by norm_num
    _ ≤ 3 ^ k := pow_le_pow_right₀ (by norm_num) hk

end Berggren3Adic