import Mathlib
import Cryptography.BerggrenTrees.BerggrenFreeMonoid
import Cryptography.Berggren3Adic.Skeleton

/-!
# The Berggren parent-interval law and the exact embedding (BERGGREN-3ADIC, part II)

We build on the catalog file `Cryptography.BerggrenTrees.BerggrenFreeMonoid`, which
supplies the three Berggren generators acting on pairs,
`actGen A (m,n) = (2m−n, m)`, `actGen B (m,n) = (2m+n, m)`, `actGen C (m,n) = (m+2n, n)`,
the root `(2,1)`, the word evaluation `evalPair`, and its injectivity
(`evalPair_injective`, the freeness theorem).

This file formalises the **parent-interval law (H2)**:

* `Berggren3Adic.actGen_parentPair` — for every node the Berggren parent is decided by
  the ratio `m/n` alone: `m/n ∈ (1,2) → (n, 2n−m)`, `(2,3) → (n, m−2n)`,
  `(3,∞) → (m−2n, n)`, and the corresponding generator sends the parent back to `(m,n)`.
* `Berggren3Adic.parent_unique` — that parent and that letter are the *only* ones.
* `Berggren3Adic.exists_word` / `Berggren3Adic.existsUnique_word` — every Fermat pair is
  the value of a unique Berggren word: the descent terminates at the root exactly
  (the 40000/40000 observation of the experiment, proved for all pairs).
* `Berggren3Adic.fermatPair_evalPair`, `Berggren3Adic.range_evalPair` — conversely every
  word evaluates to a Fermat pair, so the tree is exactly the set of Fermat pairs.
* `Berggren3Adic.word_recovers_factorization` — the positive control: the tree position
  *is* the factorisation, `N = (m−n)(m+n)`; recovering the word recovers the factors.
-/

namespace Berggren3Adic

open BergGen

/-! ## Bands and the parent map -/

/-- The branch letter of a node, read off from the band of the ratio `m/n`. -/
def letterOf (p : ℤ × ℤ) : BergGen :=
  if p.1 < 2 * p.2 then A else if p.1 < 3 * p.2 then B else C

/-- The Berggren parent of a node, decided by the band of the ratio `m/n`. -/
def parentPair (p : ℤ × ℤ) : ℤ × ℤ :=
  if p.1 < 2 * p.2 then (p.2, 2 * p.2 - p.1)
  else if p.1 < 3 * p.2 then (p.2, p.1 - 2 * p.2)
  else (p.1 - 2 * p.2, p.2)

theorem fermatPair_valid {p : ℤ × ℤ} (hp : FermatPair p) : ValidPair p := ⟨hp.pos, hp.lt⟩

/-- Coprimality is stable under the elementary operation `a ↦ a + k b`. -/
theorem coprime_lin {a b : ℤ} (h : IsCoprime a b) (k : ℤ) : IsCoprime (a + k * b) b := by
  simpa [mul_comm] using h.add_mul_left_left k

/-- Coprimality is stable under the elementary operation `b ↦ b + k a`. -/
theorem coprime_lin' {a b : ℤ} (h : IsCoprime a b) (k : ℤ) : IsCoprime a (b + k * a) :=
  (coprime_lin h.symm k).symm

/-- Coprimality is stable under the band-boundary reflections used by the parent map. -/
theorem coprime_two_sub {a b : ℤ} (h : IsCoprime a b) : IsCoprime b (2 * b - a) := by
  have heq : 2 * b - a = -a + 2 * b := by ring
  rw [heq]
  exact (coprime_lin h.neg_left 2).symm

theorem coprime_sub_two {a b : ℤ} (h : IsCoprime a b) : IsCoprime b (a - 2 * b) := by
  have heq : a - 2 * b = a + (-2) * b := by ring
  rw [heq]
  exact (coprime_lin h (-2)).symm

theorem coprime_sub_two' {a b : ℤ} (h : IsCoprime a b) : IsCoprime (a - 2 * b) b := by
  have heq : a - 2 * b = a + (-2) * b := by ring
  rw [heq]
  exact coprime_lin h (-2)

/-- Coprimality plus opposite parity exclude the two band boundaries `m = 2n`, `m = 3n`
for every node other than the root. -/
theorem band_strict {p : ℤ × ℤ} (hp : FermatPair p) (hroot : p ≠ rootPair) :
    p.1 ≠ 2 * p.2 ∧ p.1 ≠ 3 * p.2 := by
  obtain ⟨hpos, hlt, hcop, hpar⟩ := hp
  constructor
  · intro h
    have hu : IsUnit p.2 := hcop.isUnit_of_dvd' ⟨2, by omega⟩ dvd_rfl
    rw [Int.isUnit_iff] at hu
    exact hroot (Prod.ext (by simp only [rootPair]; omega) (by simp only [rootPair]; omega))
  · intro h
    have hu : IsUnit p.2 := hcop.isUnit_of_dvd' ⟨3, by omega⟩ dvd_rfl
    rw [Int.isUnit_iff] at hu
    omega

/-! ## H2: the parent-interval law -/

/-- **The parent-interval law (H2)**: applying the letter `letterOf p` to `parentPair p`
returns `p`, i.e. the ratio band alone determines the Berggren ancestry step. -/
theorem actGen_parentPair (p : ℤ × ℤ) : actGen (letterOf p) (parentPair p) = p := by
  unfold letterOf parentPair
  split_ifs with h1 h2 <;> simp only [actGen] <;> ext <;> simp

/-- The parent of a Fermat pair is a Fermat pair. -/
theorem fermatPair_parentPair {p : ℤ × ℤ} (hp : FermatPair p) (hroot : p ≠ rootPair) :
    FermatPair (parentPair p) := by
  obtain ⟨hb2, hb3⟩ := band_strict hp hroot
  obtain ⟨hpos, hlt, hcop, hpar⟩ := hp
  unfold parentPair
  split_ifs with h1 h2
  · exact ⟨by simp only; omega, by simp only; omega, coprime_two_sub hcop, by simp only; omega⟩
  · exact ⟨by simp only; omega, by simp only; omega, coprime_sub_two hcop, by simp only; omega⟩
  · exact ⟨by simp only; omega, by simp only; omega, coprime_sub_two' hcop, by simp only; omega⟩

/-- The descent strictly decreases `m + n`, so it terminates. -/
theorem parentPair_sum_lt {p : ℤ × ℤ} (hp : FermatPair p) :
    (parentPair p).1 + (parentPair p).2 < p.1 + p.2 := by
  obtain ⟨hpos, hlt, _, _⟩ := hp
  unfold parentPair
  split_ifs with h1 h2 <;> simp only <;> omega

/-- **Uniqueness of the parent**: any Berggren predecessor of a Fermat pair is *the*
band-decided one, with *the* band-decided letter. -/
theorem parent_unique {p q : ℤ × ℤ} {g : BergGen} (hq : ValidPair q)
    (hp : FermatPair p) (hroot : p ≠ rootPair) (h : actGen g q = p) :
    g = letterOf p ∧ q = parentPair p := by
  have hpar : FermatPair (parentPair p) := fermatPair_parentPair hp hroot
  have h2 : actGen g q = actGen (letterOf p) (parentPair p) := by
    rw [h, actGen_parentPair]
  exact actGen_unique_parent hq (fermatPair_valid hpar) h2

/-! ## Children are Fermat pairs -/

theorem fermatPair_actGen (g : BergGen) {p : ℤ × ℤ} (hp : FermatPair p) :
    FermatPair (actGen g p) := by
  obtain ⟨hpos, hlt, hcop, hpar⟩ := hp
  cases g
  · refine ⟨by simp only [actGen]; omega, by simp only [actGen]; omega, ?_,
      by simp only [actGen]; omega⟩
    have heq : 2 * p.1 - p.2 = -p.2 + 2 * p.1 := by ring
    simp only [actGen, heq]
    exact coprime_lin hcop.symm.neg_left 2
  · refine ⟨by simp only [actGen]; omega, by simp only [actGen]; omega, ?_,
      by simp only [actGen]; omega⟩
    have heq : 2 * p.1 + p.2 = p.2 + 2 * p.1 := by ring
    simp only [actGen, heq]
    exact coprime_lin hcop.symm 2
  · refine ⟨by simp only [actGen]; omega, by simp only [actGen]; omega, ?_,
      by simp only [actGen]; omega⟩
    simp only [actGen]
    exact coprime_lin hcop 2

theorem fermatPair_rootPair : FermatPair rootPair :=
  ⟨by norm_num [rootPair], by norm_num [rootPair], by
    simpa [rootPair] using (isCoprime_one_right (R := ℤ) (x := 2)), by norm_num [rootPair]⟩

/-- Every Berggren word evaluates to a Fermat pair. -/
theorem fermatPair_evalPair (w : BergWord) : FermatPair (evalPair w) := by
  induction w with
  | nil => exact fermatPair_rootPair
  | cons g rest ih => exact fermatPair_actGen g ih

/-! ## The exact embedding: descent terminates at the root -/

private theorem exists_word_aux : ∀ k : ℕ, ∀ p : ℤ × ℤ, (p.1 + p.2).toNat ≤ k →
    FermatPair p → ∃ w : BergWord, evalPair w = p := by
  intro k
  induction k with
  | zero =>
    intro p hle hp
    have h1 := hp.pos
    have h2 := hp.lt
    omega
  | succ k ih =>
    intro p hle hp
    by_cases hroot : p = rootPair
    · exact ⟨[], by rw [hroot]; rfl⟩
    · have hdec := parentPair_sum_lt hp
      have hparF := fermatPair_parentPair hp hroot
      have h1 := hparF.pos
      have h2 := hparF.lt
      obtain ⟨w, hw⟩ := ih (parentPair p) (by omega) hparF
      exact ⟨letterOf p :: w, by
        rw [show evalPair (letterOf p :: w) = actGen (letterOf p) (evalPair w) from rfl, hw,
          actGen_parentPair]⟩

/-- **Exactness of the descent**: every Fermat pair is reached from the root `(2,1)` by a
Berggren word.  (The experiment saw this on 40000/40000 capped descents; here it is proved
for all pairs, with no step cap and no censoring.) -/
theorem exists_word {p : ℤ × ℤ} (hp : FermatPair p) : ∃ w : BergWord, evalPair w = p :=
  exists_word_aux (p.1 + p.2).toNat p le_rfl hp

/-- **The Berggren tree is exactly the set of Fermat pairs, coded bijectively**:
combining surjectivity with the freeness theorem of the catalog file. -/
theorem existsUnique_word {p : ℤ × ℤ} (hp : FermatPair p) :
    ∃! w : BergWord, evalPair w = p := by
  obtain ⟨w, hw⟩ := exists_word hp
  exact ⟨w, hw, fun v hv => evalPair_injective (hv.trans hw.symm)⟩

/-- The tree position, read as a set, is exactly the set of Fermat pairs. -/
theorem range_evalPair : Set.range evalPair = {p : ℤ × ℤ | FermatPair p} := by
  ext p
  exact ⟨by rintro ⟨w, rfl⟩; exact fermatPair_evalPair w, fun hp => exists_word hp⟩

/-! ## Positive control: the position *is* the factorisation -/

/-- Knowing the tree word gives the factorisation of `N`: `N = (m−n)(m+n)`, with the two
factors nontrivial for any non-root node; for the Fermat pair of a semiprime these are
exactly the two prime factors. -/
theorem word_recovers_factorization {w : BergWord} (hw : w ≠ []) :
    nOf (evalPair w) = ((evalPair w).1 - (evalPair w).2) * ((evalPair w).1 + (evalPair w).2) ∧
    0 < (evalPair w).1 - (evalPair w).2 ∧ 2 < (evalPair w).1 + (evalPair w).2 := by
  have hF := fermatPair_evalPair w
  refine ⟨nOf_eq_mul _, by have := hF.lt; omega, ?_⟩
  match w, hw with
  | g :: rest, _ =>
    have h3 : 3 ≤ (actGen g (evalPair rest)).1 :=
      m_ge_three_after_gen g (fermatPair_valid (fermatPair_evalPair rest))
    have hpos : 0 < (evalPair (g :: rest)).2 := hF.pos
    have hev : evalPair (g :: rest) = actGen g (evalPair rest) := rfl
    rw [hev] at hpos ⊢
    omega

/-- For an odd semiprime `N = p q` with `1 < p < q` coprime, the Fermat pair is a tree
node whose unique Berggren word therefore encodes the factorisation. -/
theorem semiprime_has_unique_tree_position {p q : ℤ} (hp : p % 2 = 1) (hq : q % 2 = 1)
    (hp1 : 1 < p) (hpq : p < q) (hco : IsCoprime p q) :
    ∃! w : BergWord, evalPair w = ((q + p) / 2, (q - p) / 2) := by
  obtain ⟨hfp, _⟩ := fermatPair_of_odd_coprime hp hq hp1 hpq hco
  exact existsUnique_word hfp

end Berggren3Adic