import Mathlib
import Bridges.BerggrenTrees.BerggrenPythagoreanCore

/-!
# The Collatz–Berggren bridge, I: branching obstruction

The research hypothesis under test is that the *inverse Collatz tree* (the tree of
predecessors of an odd number under the Syracuse map) and the *Berggren tree* of
primitive Pythagorean triples are two realisations of one and the same ternary
dynamics, so that the Berggren Lorentz invariant `a² + b² − c²` could be
transported to the Collatz tree.

This file falsifies the hypothesis at its very first premise, and does so
sharply.  The inverse Collatz tree is **not** a ternary tree:

* `predSet_eq_empty_of_three_dvd` — a node divisible by `3` has **no** predecessor;
* `predSet_infinite` — every other odd node has **infinitely many** predecessors;
* `predSet_ncard_eq_zero` — consequently the predecessor set of an odd node is
  never a finite nonempty set (its `ncard` is `0` in both cases);

while the Berggren tree is exactly ternary,

* `bergChildren_ncard_eq_three` — every triple in the positive cone with `a ≠ b`
  has exactly three distinct Berggren children.

Combining the two gives the main obstruction theorem `no_branching_transfer`:
there is **no** map from Pythagorean triples to odd numbers carrying the Berggren
children of a node bijectively onto the Collatz predecessors of its image.  In
particular no "transfer of the Lorentz invariant" along a branching isomorphism
can exist.

A second, independent obstruction is recorded in `no_collatz_into_berggren`: the
Collatz predecessor graph has a **self-loop** at `1` (`syrPred_one_one`), whereas
the Berggren graph strictly increases the hypotenuse (`cone` lemmas below), hence
is loop-free.
-/

namespace CollatzBerggren

/-! ## The inverse Syracuse (odd-to-odd Collatz) tree -/

/-- `SyrPred m n` says that the odd number `m` is an immediate predecessor of the
odd number `n` in the inverse Syracuse tree: `3 * m + 1 = 2 ^ k * n` for some
`k ≥ 1`.  Because `n` is odd, `k` is forced to be the `2`-adic valuation of
`3 * m + 1`, so this is exactly the inverse of the odd-to-odd Collatz map. -/
def SyrPred (m n : ℕ) : Prop := Odd n ∧ ∃ k : ℕ, 1 ≤ k ∧ 3 * m + 1 = 2 ^ k * n

/-- The set of Collatz predecessors of `n`: the children of `n` in the inverse tree. -/
def predSet (n : ℕ) : Set ℕ := {m | SyrPred m n}

/-- A predecessor is automatically odd: `3 * m + 1` is even. -/
theorem SyrPred.odd_left {m n : ℕ} (h : SyrPred m n) : Odd m := by
  obtain ⟨-, k, hk, hmn⟩ := h
  obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
  have h2 : 2 ∣ 3 * m + 1 := by
    refine hmn ▸ ⟨2 ^ j * n, by ring⟩
  rcases Nat.even_or_odd m with he | ho
  · exact absurd h2 (by obtain ⟨t, rfl⟩ := he; omega)
  · exact ho

/-- **Dead nodes.** A multiple of `3` has no Collatz predecessor at all: the
inverse tree has branching number `0` there. -/
theorem predSet_eq_empty_of_three_dvd {n : ℕ} (h3 : 3 ∣ n) : predSet n = ∅ := by
  ext m
  simp only [predSet, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
  rintro ⟨-, k, -, hmn⟩
  have : (3 : ℕ) ∣ 3 * m + 1 := hmn ▸ Dvd.dvd.mul_left h3 _
  omega

/-- `4 ^ j ≡ 1 (mod 3)`, in the form needed below. -/
theorem two_pow_two_mul_mod_three (j : ℕ) : 2 ^ (2 * j) % 3 = 1 := by
  induction j with
  | zero => rfl
  | succ i ih =>
      have h : 2 ^ (2 * (i + 1)) = 4 * 2 ^ (2 * i) := by ring
      omega

/-- Every admissible exponent produces an honest predecessor. -/
theorem syrPred_of_mod {n k : ℕ} (hn : Odd n) (hk : 1 ≤ k)
    (hmod : 2 ^ k * n % 3 = 1) : SyrPred ((2 ^ k * n - 1) / 3) n := by
  refine ⟨hn, k, hk, ?_⟩
  omega

/-- **Infinite branching.** If `n` is odd and not divisible by `3` then `n` has
infinitely many Collatz predecessors. -/
theorem predSet_infinite {n : ℕ} (hn : Odd n) (h3 : ¬ (3 ∣ n)) :
    (predSet n).Infinite := by
  -- choose a starting exponent `k₀ ∈ {1, 2}` with `2 ^ k₀ * n ≡ 1 (mod 3)`
  obtain ⟨k₀, hk₀, hmod₀⟩ : ∃ k₀ : ℕ, 1 ≤ k₀ ∧ 2 ^ k₀ * n % 3 = 1 := by
    have hcases : n % 3 = 1 ∨ n % 3 = 2 := by omega
    have h4 : (2 : ℕ) ^ 2 = 4 := by norm_num
    have h2 : (2 : ℕ) ^ 1 = 2 := by norm_num
    rcases hcases with h | h
    · exact ⟨2, by norm_num, by omega⟩
    · exact ⟨1, le_refl 1, by omega⟩
  have hnpos : 0 < n := hn.pos
  set f : ℕ → ℕ := fun j => (2 ^ (k₀ + 2 * j) * n - 1) / 3 with hf
  have hval : ∀ j, 3 * f j + 1 = 2 ^ (k₀ + 2 * j) * n := by
    intro j
    have hp : 2 ^ (k₀ + 2 * j) = 2 ^ k₀ * 2 ^ (2 * j) := by rw [pow_add]
    have h1 : 2 ^ (2 * j) % 3 = 1 := two_pow_two_mul_mod_three j
    have hmod : 2 ^ (k₀ + 2 * j) * n % 3 = 1 := by
      obtain ⟨s, hs⟩ : ∃ s, 2 ^ (2 * j) = 3 * s + 1 := ⟨2 ^ (2 * j) / 3, by omega⟩
      have : 2 ^ (k₀ + 2 * j) * n = 3 * (s * (2 ^ k₀ * n)) + 2 ^ k₀ * n := by
        rw [hp, hs]; ring
      omega
    simp only [hf]
    omega
  have hmem : ∀ j, f j ∈ predSet n := by
    intro j
    exact ⟨hn, k₀ + 2 * j, by omega, hval j⟩
  have hmono : StrictMono f := by
    intro i j hij
    have hpow : 2 ^ (k₀ + 2 * i) < 2 ^ (k₀ + 2 * j) :=
      Nat.pow_lt_pow_right (by norm_num) (by omega)
    have := hval i
    have := hval j
    have : 2 ^ (k₀ + 2 * i) * n < 2 ^ (k₀ + 2 * j) * n :=
      Nat.mul_lt_mul_of_lt_of_le hpow (le_refl n) hnpos
    omega
  exact Set.infinite_of_injective_forall_mem hmono.injective hmem

/-- **Branching dichotomy.**  The predecessor set of an odd node is either empty
or infinite; it is *never* a finite set of size three.  (`Set.ncard` of an
infinite set is `0`, so the uniform statement is that the count is `0`.) -/
theorem predSet_ncard_eq_zero (n : ℕ) : (predSet n).ncard = 0 := by
  rcases Nat.even_or_odd n with he | ho
  · have : predSet n = ∅ := by
      ext m
      simp only [predSet, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
      rintro ⟨ho, -⟩
      exact (Nat.not_odd_iff_even.2 he) ho
    simp [this]
  · by_cases h3 : 3 ∣ n
    · simp [predSet_eq_empty_of_three_dvd h3]
    · exact (predSet_infinite ho h3).ncard

/-- Sharper restatement: the predecessor set is empty or infinite. -/
theorem predSet_empty_or_infinite (n : ℕ) :
    predSet n = ∅ ∨ (predSet n).Infinite := by
  rcases Nat.even_or_odd n with he | ho
  · left
    ext m
    simp only [predSet, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
    rintro ⟨ho, -⟩
    exact (Nat.not_odd_iff_even.2 he) ho
  · by_cases h3 : 3 ∣ n
    · exact Or.inl (predSet_eq_empty_of_three_dvd h3)
    · exact Or.inr (predSet_infinite ho h3)

/-! ## The Berggren tree is exactly ternary -/

open scoped Classical

/-- The set of the three Berggren children of a triple. -/
def bergChildren (t : ℤ × ℤ × ℤ) : Set (ℤ × ℤ × ℤ) :=
  {applyStep .A t, applyStep .B t, applyStep .C t}

/-- The positive Pythagorean cone: strictly positive legs, each smaller than the
hypotenuse. -/
def InCone (t : ℤ × ℤ × ℤ) : Prop :=
  0 < t.1 ∧ 0 < t.2.1 ∧ t.1 < t.2.2 ∧ t.2.1 < t.2.2

theorem inCone_root : InCone (3, 4, 5) := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- Every Berggren step maps the positive cone into itself. -/
theorem inCone_applyStep {t : ℤ × ℤ × ℤ} (h : InCone t) (s : BerggrenStep) :
    InCone (applyStep s t) := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨ha, hb, hac, hbc⟩ := h
  cases s <;>
    refine ⟨by simp [applyStep, bergA, bergB, bergC] at *; omega,
            by simp [applyStep, bergA, bergB, bergC] at *; omega,
            by simp [applyStep, bergA, bergB, bergC] at *; omega,
            by simp [applyStep, bergA, bergB, bergC] at *; omega⟩

/-- Every Berggren step strictly increases the hypotenuse on the positive cone. -/
theorem hyp_lt_applyStep {t : ℤ × ℤ × ℤ} (h : InCone t) (s : BerggrenStep) :
    t.2.2 < (applyStep s t).2.2 := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨ha, hb, hac, hbc⟩ := h
  cases s <;> simp [applyStep, bergA, bergB, bergC] at * <;> omega

/-- **Exact ternary branching.** A cone triple with distinct legs has exactly
three Berggren children. -/
theorem bergChildren_ncard_eq_three {a b c : ℤ} (ha : 0 < a) (hb : 0 < b)
    (hab : a ≠ b) : (bergChildren (a, b, c)).ncard = 3 := by
  refine Set.ncard_eq_three.2 ⟨bergA a b c, bergB a b c, bergC a b c, ?_, ?_, ?_, rfl⟩
  · intro h
    have : 2 * a - 2 * b + 3 * c = 2 * a + 2 * b + 3 * c := congrArg (fun p => p.2.2) h
    omega
  · intro h
    have : 2 * a - 2 * b + 3 * c = -2 * a + 2 * b + 3 * c := congrArg (fun p => p.2.2) h
    omega
  · intro h
    have : 2 * a + 2 * b + 3 * c = -2 * a + 2 * b + 3 * c := congrArg (fun p => p.2.2) h
    omega

/-! ## The obstruction theorems -/

/-- **Main obstruction (Berggren → Collatz).**  There is no map `Φ` from
Pythagorean triples to odd numbers which sends, for every cone triple with
distinct legs, the three Berggren children bijectively onto the Collatz
predecessors of the image.  Hence the Berggren ternary branching cannot be
transported onto the inverse Collatz tree, and with it neither can the Lorentz
invariant: the two trees are not isomorphic as branching structures. -/
theorem no_branching_transfer (Φ : ℤ × ℤ × ℤ → ℕ)
    (hbij : ∀ a b c : ℤ, 0 < a → 0 < b → a ≠ b →
      Set.BijOn Φ (bergChildren (a, b, c)) (predSet (Φ (a, b, c)))) : False := by
  have h := hbij 3 4 5 (by norm_num) (by norm_num) (by norm_num)
  have himg : Φ '' (bergChildren (3, 4, 5)) = predSet (Φ (3, 4, 5)) := h.image_eq
  have hcard : (Φ '' (bergChildren (3, 4, 5))).ncard = 3 := by
    rw [Set.InjOn.ncard_image h.injOn]
    exact bergChildren_ncard_eq_three (by norm_num) (by norm_num) (by norm_num)
  rw [himg, predSet_ncard_eq_zero] at hcard
  exact absurd hcard (by norm_num)

/-- The Collatz predecessor graph has a **self-loop**: `1` is its own
predecessor, since `3 * 1 + 1 = 2 ^ 2 * 1`. -/
theorem syrPred_one_one : SyrPred 1 1 := ⟨odd_one, 2, by norm_num, by norm_num⟩

/-- **Second obstruction (Collatz → Berggren).**  No embedding of the inverse
Collatz tree into the Berggren tree can carry predecessor edges to child edges:
the Collatz graph has a self-loop at `1` while the Berggren graph strictly
increases the hypotenuse, hence has none. -/
theorem no_collatz_into_berggren (Ψ : ℕ → ℤ × ℤ × ℤ)
    (hcone : ∀ n, InCone (Ψ n))
    (hedge : ∀ m n, SyrPred m n → Ψ m ∈ bergChildren (Ψ n)) : False := by
  have h := hedge 1 1 syrPred_one_one
  have hlt : ∀ s : BerggrenStep, (Ψ 1).2.2 < (applyStep s (Ψ 1)).2.2 := fun s =>
    hyp_lt_applyStep (hcone 1) s
  rcases h with h | h | h
  · exact absurd (congrArg (fun p => p.2.2) h.symm) (by simpa using (hlt .A).ne')
  · exact absurd (congrArg (fun p => p.2.2) h.symm) (by simpa using (hlt .B).ne')
  · exact absurd (congrArg (fun p => p.2.2) h.symm) (by simpa using (hlt .C).ne')

end CollatzBerggren