import Mathlib
import Shared.QSFactorBaseDimension

/-!
# Round 42, open problem: large primes decouple yield from the column space

Round 42 closed with: *given a fixed `B`, can the yield collapse be evaded without
shrinking the column space?*  The first candidate channel listed is the
large-prime (partial-relation) variant.  This file proves the algebraic core of
that channel: partial relations sharing a large prime can be paired so that the
large prime cancels, and the resulting combined relations live in the **same**
`𝔽₂^Q` column space as the full relations.

Setting: `A` is the column set (the admissible primes, `|A| = Q`).
* `a` *full* relations `F j`, each nonzero with prime support in `A`;
* `b` *partial* relations `P i = s i * ℓ i` with `s i` nonzero, `A`-supported and
  `ℓ i` an arbitrary (large) prime;
* `D` = the number of **distinct** large primes among the partials.

Results:
* `lpRep` — for each partial, the canonical representative (least index) sharing
  its large prime; `lpRep_large` / `lpRep_idem`.
* `card_nonrep_ge` — at least `b - D` partials are not their own representative.
* `large_prime_congruence` — **if `Q < a + (b - D)`, some nonempty collection of
  full relations and paired partials `P i · P (lpRep i)` multiplies to a perfect
  square.**  The column count is still `Q`; the relation count grew from `a` to
  `a + b - D`.
* `combined_value_eq` — each pair is `s i · s (lpRep i) · ℓ i ²`: the large prime
  appears to an even power and so contributes no column.

So with partials the threshold for a guaranteed dependence is
`#full + #partials - #distinct large primes > Q`, with the column space untouched:
this is the precise sense in which the large-prime channel evades the yield
collapse "without shrinking the column space".  Whether it is *cheaper* is a
question about how fast `b - D` grows (a birthday-type collision count), not
about linear algebra.
-/

namespace QSLargePrime

open Finset

variable {b : ℕ}

/-- The canonical representative of the large-prime class of `i`: the least
index whose large prime coincides with that of `i`. -/
def lpRep (ℓ : Fin b → ℕ) (i : Fin b) : Fin b :=
  (Finset.univ.filter (fun j => ℓ j = ℓ i)).min' ⟨i, by simp⟩

theorem lpRep_large (ℓ : Fin b → ℕ) (i : Fin b) : ℓ (lpRep ℓ i) = ℓ i := by
  have := Finset.min'_mem (Finset.univ.filter (fun j => ℓ j = ℓ i)) ⟨i, by simp⟩
  simpa [lpRep] using this

/-- The representative depends only on the large prime. -/
theorem lpRep_congr (ℓ : Fin b → ℕ) {i j : Fin b} (h : ℓ i = ℓ j) :
    lpRep ℓ i = lpRep ℓ j := by
  unfold lpRep
  congr 1
  ext k; simp [h]

theorem lpRep_idem (ℓ : Fin b → ℕ) (i : Fin b) : lpRep ℓ (lpRep ℓ i) = lpRep ℓ i :=
  lpRep_congr ℓ (lpRep_large ℓ i)

/-- The fixed points of `lpRep` inject into the set of distinct large primes. -/
theorem card_rep_le (ℓ : Fin b → ℕ) :
    (Finset.univ.filter (fun i => lpRep ℓ i = i)).card ≤ (Finset.univ.image ℓ).card := by
  apply Finset.card_le_card_of_injOn ℓ
  · intro i _; simp
  · intro i hi j hj hij
    simp only [Finset.coe_filter, Finset.mem_univ, true_and, Set.mem_setOf_eq] at hi hj
    rw [← hi, ← hj]
    exact lpRep_congr ℓ hij

/-- At least `b - D` partials are *paired* (not their own representative). -/
theorem card_nonrep_ge (ℓ : Fin b → ℕ) :
    b - (Finset.univ.image ℓ).card ≤ (Finset.univ.filter (fun i => lpRep ℓ i ≠ i)).card := by
  have h1 := card_rep_le ℓ
  have h2 := Finset.card_filter_add_card_filter_not (s := (Finset.univ : Finset (Fin b)))
    (fun i => lpRep ℓ i = i)
  simp only [Finset.card_univ, Fintype.card_fin] at h2
  simp only [ne_eq]
  omega

/-- A paired partial relation is `s i · s (lpRep i) · (ℓ i)²`. -/
theorem combined_value_eq (s ℓ : Fin b → ℕ) (i : Fin b) :
    (s i * ℓ i) * (s (lpRep ℓ i) * ℓ (lpRep ℓ i)) = (s i * s (lpRep ℓ i)) * ℓ i ^ 2 := by
  rw [lpRep_large ℓ i]; ring

/-- The combined relation set: full relations, plus paired partials. -/
abbrev CombIdx (a : ℕ) (ℓ : Fin b → ℕ) :=
  Fin a ⊕ {i : Fin b // lpRep ℓ i ≠ i}

/-- The value of a combined relation. -/
def combValue {a : ℕ} (F : Fin a → ℕ) (s ℓ : Fin b → ℕ) : CombIdx a ℓ → ℕ
  | Sum.inl j => F j
  | Sum.inr i => (s i.1 * ℓ i.1) * (s (lpRep ℓ i.1) * ℓ (lpRep ℓ i.1))

/-- Its `A`-part, with the squared large prime removed. -/
def combCore {a : ℕ} (F : Fin a → ℕ) (s ℓ : Fin b → ℕ) : CombIdx a ℓ → ℕ
  | Sum.inl j => F j
  | Sum.inr i => s i.1 * s (lpRep ℓ i.1)

/-- **Large-prime congruence of squares.**  If the number of full relations plus
the number of paired partials exceeds the column count `Q = |A|`, some nonempty
collection of combined relations multiplies to a perfect square.  The column
space is the same `𝔽₂^A` as for full relations alone. -/
theorem large_prime_congruence {a : ℕ} (A : Finset ℕ)
    (F : Fin a → ℕ) (hF0 : ∀ j, F j ≠ 0) (hFA : ∀ j, (F j).primeFactors ⊆ A)
    (s ℓ : Fin b → ℕ) (hs0 : ∀ i, s i ≠ 0) (hsA : ∀ i, (s i).primeFactors ⊆ A)
    (hQ : A.card < a + (b - (Finset.univ.image ℓ).card)) :
    ∃ T : Finset (CombIdx a ℓ), T.Nonempty ∧ IsSquare (∏ t ∈ T, combValue F s ℓ t) := by
  classical
  have hcore0 : ∀ t, combCore F s ℓ t ≠ 0 := by
    rintro (j | i)
    · exact hF0 j
    · exact Nat.mul_ne_zero (hs0 _) (hs0 _)
  have hcoreA : ∀ t, ∀ p, (combCore F s ℓ t).factorization p ≠ 0 → p ∈ A := by
    intro t p hp
    have hmem : p ∈ (combCore F s ℓ t).primeFactors := by
      rw [← Nat.support_factorization]; exact Finsupp.mem_support_iff.2 hp
    rcases t with j | i
    · exact hFA j hmem
    · simp only [combCore] at hmem
      rw [Nat.primeFactors_mul (hs0 _) (hs0 _)] at hmem
      rcases Finset.mem_union.1 hmem with h | h
      · exact hsA _ h
      · exact hsA _ h
  have hcard : A.card < Fintype.card (CombIdx a ℓ) := by
    rw [Fintype.card_sum, Fintype.card_fin, Fintype.card_subtype]
    have := card_nonrep_ge ℓ
    simp only [ne_eq] at this ⊢
    omega
  obtain ⟨T, hTne, hsq⟩ :=
    QSDimension.exists_nonempty_subset_prod_isSquare A (combCore F s ℓ) hcore0 hcoreA hcard
  refine ⟨T, hTne, ?_⟩
  have hsplit : ∀ t, combValue F s ℓ t = combCore F s ℓ t *
      (match t with | Sum.inl _ => 1 | Sum.inr i => ℓ i.1) ^ 2 := by
    rintro (j | i)
    · simp [combValue, combCore]
    · simp only [combValue, combCore]; exact combined_value_eq s ℓ i.1
  rw [Finset.prod_congr rfl (fun t _ => hsplit t), Finset.prod_mul_distrib,
    Finset.prod_pow]
  obtain ⟨r, hr⟩ := hsq
  exact ⟨r * ∏ t ∈ T, (match t with | Sum.inl _ => 1 | Sum.inr i => ℓ i.1), by rw [hr]; ring⟩

/-! ## Lab notes

`A = {2, 3}` (`Q = 2`), one full relation `F₀ = 6`, and three partials sharing
the large prime `101`: `P = 2·101, 3·101, 6·101` (`a = 1`, `b = 3`, `D = 1`).
The threshold `Q = 2 < a + (b - D) = 3` holds.  Pairing with the representative
(index `0`) gives `P₁P₀ = 6·101²` and `P₂P₀ = 12·101²`; the full relation and the
first pair already multiply to a square, `6 · (3·101)(2·101) = (6·101)²`.  Without
the partials (`a = 1 ≤ Q`) no dependence is guaranteed. -/

example : (6 : ℕ) * ((3 * 101) * (2 * 101)) = (6 * 101) * (6 * 101) := by norm_num

end QSLargePrime