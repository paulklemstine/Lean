import Mathlib

/-!
# Counterfactual Number Theory: a Hilbert-type prime universe

What survives if the primes of arithmetic are replaced by the *irreducible*
elements of a different multiplicative world?  We study the classical
**Hilbert monoid**

  `H = { n : ℕ | n ≡ 1 (mod 4) } = {1, 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, …}`,

a multiplicatively closed subset of the naturals.  Its "primes" are the
`H`-irreducible elements — members of `H` that admit no nontrivial factorization
*inside* `H`.  This is a faithful toy model of a counterfactual number theory:
the ambient arithmetic is unchanged, but the notion of *which numbers are prime*
is deformed by only remembering the residue class `1 (mod 4)`.

The file separates the phenomena that **survive** this deformation from the one
that **collapses**:

* **Multiplicative structure survives** (`inH_one`, `inH_mul`): `H` is a submonoid
  of `(ℕ, ·)`.
* **Dirichlet-type infinitude survives** (`infinite_Hirr`): there are infinitely
  many `H`-irreducibles, obtained from the rational primes `p ≡ 1 (mod 4)`.
* **Unique factorization collapses** (`factorization_not_unique`): the number
  `441` has two genuinely different factorizations into `H`-irreducibles,
  `441 = 9 · 49 = 21 · 21`, with `9, 21, 49` all `H`-irreducible.

The collapse is the point: infinitude of primes and the multiplicative skeleton
are robust features that do not depend on the fine structure of the primes, while
unique factorization is fragile and depends essentially on it.

-- !-- Lab Notes -- !--
-- Hypothesis: replacing the primes by the irreducibles of the arithmetic
--   progression `1 (mod 4)` should preserve "coarse" multiplicative statements
--   (closure, infinitude of primes) while destroying "fine" ones
--   (unique factorization).
-- Experiment: formalize `H = {n ≡ 1 mod 4}`, its irreducibles `Hirr`, and test
--   each statement.  `9, 21, 49` are H-irreducible because their only proper
--   rational factors (`3, 7`) fall in the class `3 (mod 4)` and leave `H`.
--   `441 = 9·49 = 21·21` then exhibits two distinct irreducible factorizations.
-- Analysis: closure is a one-line residue computation; infinitude of
--   H-irreducibles reduces to Dirichlet's theorem for the progression
--   `1 (mod 4)` (the primes there are automatically H-irreducible); the failure
--   of unique factorization is a genuine structural obstruction, not an artifact
--   of small numbers.
-- Critique: `Hirr` must quantify over factorizations *inside* `H` (not over all
--   of `ℕ`), otherwise every composite would look reducible and the model would
--   be vacuous.  The multiset inequality `{9,49} ≠ {21,21}` certifies the two
--   factorizations are genuinely different, not a reordering.
-- Synthesis: "which primes" is a fragile datum; unique factorization is the first
--   casualty of deforming it, while Dirichlet infinitude and multiplicative
--   closure are robust.
-- !-- End Lab Notes -- !--
-/

namespace CounterfactualPrimes

/-- The **Hilbert monoid**: natural numbers congruent to `1` modulo `4`.
These are the "numbers" of our counterfactual arithmetic. -/
def inH (n : ℕ) : Prop := n % 4 = 1

instance : DecidablePred inH := fun n => by unfold inH; infer_instance

/-- An element is **`H`-irreducible** (a counterfactual prime) when it is a
non-unit member of `H` whose only factorizations *within `H`* are trivial. -/
def Hirr (n : ℕ) : Prop :=
  2 ≤ n ∧ inH n ∧ ∀ a b : ℕ, inH a → inH b → a * b = n → a = 1 ∨ b = 1

/-- The unit `1` lies in the Hilbert monoid. -/
theorem inH_one : inH 1 := rfl

/-- **Multiplicative structure survives**: `H` is closed under multiplication,
so it forms a submonoid of `(ℕ, ·)`. -/
theorem inH_mul {a b : ℕ} (ha : inH a) (hb : inH b) : inH (a * b) := by
  unfold inH at *
  simp [Nat.mul_mod, ha, hb]

/-- `9` is a counterfactual prime: its only nontrivial rational factor `3`
lies outside `H`. -/
theorem Hirr_9 : Hirr 9 := by
  refine ⟨by norm_num, rfl, ?_⟩
  intro a b ha hb hab
  unfold inH at ha hb
  have hle : a ≤ 9 := Nat.le_of_dvd (by norm_num) ⟨b, hab.symm⟩
  interval_cases a <;> omega

/-- `21 = 3 · 7` is a counterfactual prime: both rational factors `3` and `7`
lie outside `H`, so `21` cannot be split inside `H`. -/
theorem Hirr_21 : Hirr 21 := by
  refine ⟨by norm_num, rfl, ?_⟩
  intro a b ha hb hab
  unfold inH at ha hb
  have hle : a ≤ 21 := Nat.le_of_dvd (by norm_num) ⟨b, hab.symm⟩
  interval_cases a <;> omega

/-- `49 = 7 · 7` is a counterfactual prime for the same reason. -/
theorem Hirr_49 : Hirr 49 := by
  refine ⟨by norm_num, rfl, ?_⟩
  intro a b ha hb hab
  unfold inH at ha hb
  have hle : a ≤ 49 := Nat.le_of_dvd (by norm_num) ⟨b, hab.symm⟩
  interval_cases a <;> omega

/-- **Unique factorization collapses.** The number `441` factors into
counterfactual primes in two essentially different ways,
`441 = 9 · 49 = 21 · 21`, and the multiset `{9, 49}` differs from `{21, 21}`.
Thus the Fundamental Theorem of Arithmetic fails in this universe. -/
theorem factorization_not_unique :
    Hirr 9 ∧ Hirr 21 ∧ Hirr 49 ∧
      9 * 49 = 441 ∧ 21 * 21 = 441 ∧
      ({9, 49} : Multiset ℕ) ≠ ({21, 21} : Multiset ℕ) :=
  ⟨Hirr_9, Hirr_21, Hirr_49, by norm_num, by norm_num, by decide⟩

/-- Every rational prime `p ≡ 1 (mod 4)` is a counterfactual prime.  Since a
prime has no nontrivial factorization even in `ℕ`, it certainly has none in `H`,
and `p ≡ 1 (mod 4)` places it in `H`. -/
theorem Hirr_of_prime_mod_four {p : ℕ} (hp : p.Prime) (hpm : p % 4 = 1) :
    Hirr p := by
  refine ⟨hp.two_le, hpm, ?_⟩
  intro a b _ _ hab
  have hdvd : a ∣ p := ⟨b, hab.symm⟩
  rcases hp.eq_one_or_self_of_dvd a hdvd with h1 | hpp
  · exact Or.inl h1
  · right; subst hpp; nlinarith [hab, hp.pos]

/-- **Dirichlet-type infinitude survives.** There are infinitely many
counterfactual primes, produced by the rational primes `p ≡ 1 (mod 4)`. -/
theorem infinite_Hirr : {n : ℕ | Hirr n}.Infinite := by
  have h := Nat.frequently_atTop_modEq_one (k := 4) (by norm_num)
  rw [Nat.frequently_atTop_iff_infinite] at h
  apply h.mono
  intro p hp
  simp only [Set.mem_setOf_eq] at hp ⊢
  exact Hirr_of_prime_mod_four hp.1 (by have := hp.2; unfold Nat.ModEq at this; omega)

end CounterfactualPrimes