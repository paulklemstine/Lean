import Mathlib

/-!
# The two linear characters of the symmetric group `Sₙ`

For `n ≥ 2`, the symmetric group `Sₙ = Perm (Fin n)` has exactly two one-dimensional
(linear) complex characters: the **trivial** character `σ ↦ 1` and the **sign**
character `σ ↦ sgn σ`.  These are the first two rows of the character table of `Sₙ`.

This file proves, with explicit computations over `ℚ` (the sign is real, `±1`, so no
genuine complex conjugation is needed):

* `SnLinearCharacters.sum_sign_eq_zero` — `∑ σ : Perm (Fin n), sgn σ = 0` when `2 ≤ n`.
  Equivalently, `Sₙ` has equally many even and odd permutations.  This is the heart of
  the row-orthogonality of the trivial and sign characters.
* `SnLinearCharacters.charInner_triv_triv` / `charInner_sign_sign` — each linear
  character has norm one.
* `SnLinearCharacters.charInner_triv_sign` — the trivial and sign characters are
  orthogonal (for `2 ≤ n`).
* `SnLinearCharacters.trivChar_ne_signChar` — the two characters are genuinely
  distinct (for `2 ≤ n`).

These are exactly the orthonormality relations one verifies when *building* the
character table of `Sₙ`, restricted to its two linear rows.

This complements the conjugacy-class count in `ConjClassCount.lean`, which gives the
*number* of rows of the table, and the catalog file
`Catalog/Novelty/SymmetricGroupGeneration.lean`, which also exploits the index-two
sign obstruction.

-- !-- Lab Notes -- !--
* Hypothesis: `Sₙ` (`n ≥ 2`) has two linear characters, the trivial and the sign, and
  these form an orthonormal pair of rows in the character table.
* Experiment: define both as `ℚ`-valued class functions and the normalized inner
  product `⟨f,g⟩ = (1/n!) ∑_σ f σ · g σ`. Reduce all four orthonormality statements to
  one arithmetic fact: `∑_σ sgn σ = 0`.
* Analysis: `∑_σ sgn σ = 0` is the only non-formal input; it follows from the
  index-two sign homomorphism (multiply by a fixed transposition to flip the sign,
  forcing the sum to equal its own negative). `|Sₙ| = n!` is `Fintype.card_perm`.
* Critique: the `n ≥ 2` hypothesis is genuinely necessary: for `n ≤ 1` the sign is
  constantly `1`, the trivial and sign characters coincide, and `∑ sgn σ = 1 ≠ 0`.
  The distinctness theorem witnesses this with an explicit transposition.
* Synthesis: the four orthonormality relations below are the verified two-row block of
  the `Sₙ` character table.
-/

open Equiv Equiv.Perm Finset

namespace SnLinearCharacters

variable {n : ℕ}

/-- The trivial linear character of `Sₙ`: the constant function `1`. -/
def trivChar (n : ℕ) : Equiv.Perm (Fin n) → ℚ := fun _ => 1

/-- The sign linear character of `Sₙ`. -/
def signChar (n : ℕ) : Equiv.Perm (Fin n) → ℚ := fun σ => (Equiv.Perm.sign σ : ℚ)

/-- The (real) normalized inner product of two class functions on `Sₙ`,
`⟨f, g⟩ = (1/|Sₙ|) ∑_σ f(σ) g(σ)`. The normalizing factor is `|Sₙ| = n!`. -/
noncomputable def charInner (f g : Equiv.Perm (Fin n) → ℚ) : ℚ :=
  (∑ σ : Equiv.Perm (Fin n), f σ * g σ) / (n.factorial : ℚ)

/-- `|Sₙ| = n!` as a rational number is nonzero. -/
theorem card_perm_ne_zero : (n.factorial : ℚ) ≠ 0 := by
  exact_mod_cast Nat.factorial_ne_zero n

/-- The square of the sign of any permutation is `1` in `ℚ`. -/
theorem sign_sq (σ : Equiv.Perm (Fin n)) :
    (Equiv.Perm.sign σ : ℚ) * (Equiv.Perm.sign σ : ℚ) = 1 := by
  rcases Int.units_eq_one_or (Equiv.Perm.sign σ) with h | h <;> simp [h]

/-- **Sum of signs vanishes.** For `n ≥ 2` the sum of the signs of all permutations of
`Fin n` is zero; equivalently there are equally many even and odd permutations. -/
theorem sum_sign_eq_zero (hn : 2 ≤ n) :
    ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℚ) = 0 := by
  -- Let $t$ be the transposition that swaps $1$ and $2$.
  let t := Equiv.swap (⟨0, by linarith⟩ : Fin n) (⟨1, by linarith⟩ : Fin n);
  -- Consider the sum $\sum_{\sigma \in S_n} \operatorname{sign}(\sigma)$ and multiply each term by $-1$.
  have h_sum_neg : ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℚ) = ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign (t * σ) : ℚ) := by
    rw [ ← Equiv.sum_comp ( Equiv.mulLeft t ) ] ; aesop;
  simp +zetaDelta at *;
  linarith

/-- The trivial character has norm one. -/
theorem charInner_triv_triv : charInner (trivChar n) (trivChar n) = 1 := by
  unfold charInner trivChar
  simp only [mul_one, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  rw [Fintype.card_perm, Fintype.card_fin]
  exact div_self card_perm_ne_zero

/-- The sign character has norm one. -/
theorem charInner_sign_sign : charInner (signChar n) (signChar n) = 1 := by
  unfold charInner signChar
  simp only [sign_sq, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
  rw [Fintype.card_perm, Fintype.card_fin]
  exact div_self card_perm_ne_zero

/-- **Orthogonality of the two linear characters.** For `n ≥ 2`, the trivial and sign
characters of `Sₙ` are orthogonal. -/
theorem charInner_triv_sign (hn : 2 ≤ n) :
    charInner (trivChar n) (signChar n) = 0 := by
  unfold charInner trivChar signChar
  simp only [one_mul]
  rw [sum_sign_eq_zero hn, zero_div]

/-- **Distinctness.** For `n ≥ 2` the trivial and sign characters are different
functions: a transposition has sign `-1 ≠ 1`. -/
theorem trivChar_ne_signChar (hn : 2 ≤ n) : trivChar n ≠ signChar n := by
  intro h
  have h01 : (⟨0, by omega⟩ : Fin n) ≠ ⟨1, by omega⟩ := by
    simp [Fin.ext_iff]
  have := congrFun h (Equiv.swap (⟨0, by omega⟩ : Fin n) ⟨1, by omega⟩)
  unfold trivChar signChar at this
  rw [Equiv.Perm.sign_swap h01] at this
  norm_num at this

end SnLinearCharacters