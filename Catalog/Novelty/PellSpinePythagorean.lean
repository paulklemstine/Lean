/-
# Near-isosceles Pythagorean triples are exactly the odd Pell spine

`Bridges.BerggrenTrees.BerggrenPythagoreanCore` studies the Berggren tree of *all*
primitive Pythagorean triples.  This file isolates the thinnest possible branch of that
tree — the triples whose two legs are **consecutive integers**,

`(0,1,1), (3,4,5), (20,21,29), (119,120,169), (696,697,985), …`

— and proves that this branch is *exactly* the odd part of the Pell spine of
`Novelty.PellSpineCore`:

* `negPell_iff` (**classification**) — `x² + 1 = 2y²` holds in `ℕ` **iff** `(x,y) = (Q (2k+1), P (2k+1))`
  for some `k`.  The hard direction is a Vieta descent through the inverse silver unit
  `(3 - 2√2)`, run as a strong induction on `y`;
* `nearIsosceles_iff` — `a² + (a+1)² = c²` **iff** `2a+1 = Q (2k+1)` and `c = P (2k+1)`;
* `nearIsosceles_isPythag` — the triples really are Pythagorean, in the catalog's own
  `IsPythag` predicate;
* `nearIsosceles_hyp_mod_four` — every near-isosceles hypotenuse is `≡ 1 (mod 4)`;
* `not_nearIsosceles_hyp_prime` (**refutation**) — the hypotenuse need not be prime:
  `(119, 120, 169)` with `169 = 13²`.  A geometric statement destroyed by an arithmetic
  accident on the Pell spine.

Every step is a genuine deduction: the descent needs the inequality `2y² ≥ 9`, the
congruence needs the three-term recursion `P (n+4) + P n = 6 P (n+2)`, and the refutation
needs the explicit triple.
-/
import Novelty.PellSpineCore
import Bridges.BerggrenTrees.BerggrenPythagoreanCore

namespace Catalog.Novelty.PellSpine

/-! ## The negative Pell equation on the spine -/

/-- Odd-index spine points solve the *negative* Pell equation `x² + 1 = 2y²`. -/
theorem negPell_of_odd_index (k : ℕ) :
    pellQ (2 * k + 1) ^ 2 + 1 = 2 * pellP (2 * k + 1) ^ 2 := by
  have h := pell_equation (2 * k + 1)
  have hodd : ((-1 : ℤ)) ^ (2 * k + 1) = -1 := by
    rw [pow_succ, pow_mul]
    norm_num
  rw [hodd] at h
  have : ((pellQ (2 * k + 1) ^ 2 + 1 : ℕ) : ℤ) = ((2 * pellP (2 * k + 1) ^ 2 : ℕ) : ℤ) := by
    push_cast
    linarith
  exact_mod_cast this

/-- **Vieta descent**: every solution of `x² + 1 = 2y²` sits on the odd Pell spine.
Strong induction on `y`; the descent step is multiplication by the inverse silver unit
`3 - 2√2`, i.e. `(x,y) ↦ (3x - 4y, 3y - 2x)`. -/
theorem negPell_descent : ∀ y x : ℕ, x ^ 2 + 1 = 2 * y ^ 2 →
    ∃ k, x = pellQ (2 * k + 1) ∧ y = pellP (2 * k + 1) := by
  intro y
  induction y using Nat.strong_induction_on with
  | _ y ih =>
    intro x hxy
    match y, hxy with
    | 0, hxy => simp at hxy
    | 1, hxy =>
        have hx : x ≤ 1 := by nlinarith
        interval_cases x
        · simp at hxy
        · exact ⟨0, by norm_num, by norm_num⟩
    | 2, hxy =>
        have hx : x ≤ 2 := by nlinarith
        interval_cases x <;> omega
    | (y + 3), hxy =>
        set Y := y + 3 with hY
        have hy3 : 3 ≤ Y := by omega
        -- `x` is strictly bigger than `Y`
        have hxgt : Y < x := by nlinarith
        -- the two descent inequalities
        have h4 : 4 * Y ≤ 3 * x := by nlinarith
        have h2 : 2 * x ≤ 3 * Y := by nlinarith
        obtain ⟨x', hx'⟩ : ∃ x', 3 * x = 4 * Y + x' := ⟨3 * x - 4 * Y, by omega⟩
        obtain ⟨y', hy'⟩ : ∃ y', 3 * Y = 2 * x + y' := ⟨3 * Y - 2 * x, by omega⟩
        -- the descended pair solves the same equation
        have hZ : (x' : ℤ) ^ 2 + 1 = 2 * (y' : ℤ) ^ 2 := by
          have e1' : (3 : ℤ) * (x : ℤ) = 4 * (Y : ℤ) + (x' : ℤ) := by exact_mod_cast hx'
          have e2' : (3 : ℤ) * (Y : ℤ) = 2 * (x : ℤ) + (y' : ℤ) := by exact_mod_cast hy'
          have e3 : (x : ℤ) ^ 2 + 1 = 2 * (Y : ℤ) ^ 2 := by exact_mod_cast hxy
          have e1 : (x' : ℤ) = 3 * (x : ℤ) - 4 * (Y : ℤ) := by linarith
          have e2 : (y' : ℤ) = 3 * (Y : ℤ) - 2 * (x : ℤ) := by linarith
          rw [e1, e2]; linear_combination e3
        have hN : x' ^ 2 + 1 = 2 * y' ^ 2 := by exact_mod_cast hZ
        have hlt : y' < Y := by omega
        obtain ⟨k, hk1, hk2⟩ := ih y' hlt x' hN
        refine ⟨k + 1, ?_, ?_⟩
        · have hq : pellQ (2 * (k + 1) + 1) = 3 * pellQ (2 * k + 1) + 4 * pellP (2 * k + 1) := by
            have : 2 * (k + 1) + 1 = (2 * k + 1) + 2 := by ring
            rw [this, pellQ_add_two']
          rw [hq, ← hk1, ← hk2]
          omega
        · have hp : pellP (2 * (k + 1) + 1) = 2 * pellQ (2 * k + 1) + 3 * pellP (2 * k + 1) := by
            have : 2 * (k + 1) + 1 = (2 * k + 1) + 2 := by ring
            rw [this, pellP_add_two']
          rw [hp, ← hk1, ← hk2]
          omega

/-- **Classification of the negative Pell equation over `ℕ`.** -/
theorem negPell_iff (x y : ℕ) :
    x ^ 2 + 1 = 2 * y ^ 2 ↔ ∃ k, x = pellQ (2 * k + 1) ∧ y = pellP (2 * k + 1) := by
  refine ⟨negPell_descent y x, ?_⟩
  rintro ⟨k, rfl, rfl⟩
  exact negPell_of_odd_index k

/-! ## Near-isosceles Pythagorean triples -/

/-- **Classification of near-isosceles Pythagorean triples.**  A triple with legs
`a, a+1` and hypotenuse `c` exists exactly at the odd points of the Pell spine. -/
theorem nearIsosceles_iff (a c : ℕ) :
    a ^ 2 + (a + 1) ^ 2 = c ^ 2 ↔
      ∃ k, 2 * a + 1 = pellQ (2 * k + 1) ∧ c = pellP (2 * k + 1) := by
  constructor
  · intro h
    have h' : (2 * a + 1) ^ 2 + 1 = 2 * c ^ 2 := by ring_nf; ring_nf at h; omega
    exact negPell_descent c (2 * a + 1) h'
  · rintro ⟨k, hq, rfl⟩
    have h := negPell_of_odd_index k
    rw [← hq] at h
    nlinarith [h]

/-- The classified triples are Pythagorean in the catalog's `IsPythag` sense. -/
theorem nearIsosceles_isPythag (k a : ℕ) (ha : 2 * a + 1 = pellQ (2 * k + 1)) :
    IsPythag (a : ℤ) ((a : ℤ) + 1) ((pellP (2 * k + 1) : ℕ) : ℤ) := by
  have h : a ^ 2 + (a + 1) ^ 2 = pellP (2 * k + 1) ^ 2 :=
    (nearIsosceles_iff a (pellP (2 * k + 1))).mpr ⟨k, ha, rfl⟩
  have : ((a ^ 2 + (a + 1) ^ 2 : ℕ) : ℤ) = ((pellP (2 * k + 1) ^ 2 : ℕ) : ℤ) := by
    exact_mod_cast h
  unfold IsPythag
  push_cast at this ⊢
  linarith

/-- Every leg pair really occurs: the odd companion terms are odd. -/
theorem exists_nearIsosceles (k : ℕ) :
    ∃ a : ℕ, 2 * a + 1 = pellQ (2 * k + 1) ∧ a ^ 2 + (a + 1) ^ 2 = pellP (2 * k + 1) ^ 2 := by
  have h := negPell_of_odd_index k
  have hodd : pellQ (2 * k + 1) % 2 = 1 := by
    obtain ⟨A, hA⟩ : ∃ A, pellQ (2 * k + 1) ^ 2 = A := ⟨_, rfl⟩
    obtain ⟨B, hB⟩ : ∃ B, pellP (2 * k + 1) ^ 2 = B := ⟨_, rfl⟩
    rw [hA, hB] at h
    rcases Nat.even_or_odd (pellQ (2 * k + 1)) with he | ho
    · obtain ⟨t, ht⟩ := he
      have hAeven : A = 2 * (2 * t * t) := by rw [← hA, ht]; ring
      omega
    · exact Nat.odd_iff.mp ho
  refine ⟨pellQ (2 * k + 1) / 2, by omega, ?_⟩
  exact (nearIsosceles_iff _ _).mpr ⟨k, by omega, rfl⟩

/-! ## An arithmetic constraint on the hypotenuse -/

/-- Three-term recursion for the Pell spine: `P (n+4) + P n = 6 * P (n+2)`. -/
theorem pellP_six_step (n : ℕ) : pellP (n + 4) + pellP n = 6 * pellP (n + 2) := by
  have h1 : pellP (n + 4) = 2 * pellP (n + 3) + pellP (n + 2) := pellP_add_two (n + 2)
  have h2 : pellP (n + 3) = 2 * pellP (n + 2) + pellP (n + 1) := pellP_add_two (n + 1)
  have h3 : pellP (n + 2) = 2 * pellP (n + 1) + pellP n := pellP_add_two n
  omega

/-- Every near-isosceles hypotenuse is `≡ 1 (mod 4)` — a congruence obstruction that the
even part of the spine does not satisfy (`P 2 = 2`, `P 4 = 12`). -/
theorem nearIsosceles_hyp_mod_four (k : ℕ) : pellP (2 * k + 1) % 4 = 1 := by
  induction k using Nat.twoStepInduction with
  | zero => decide
  | one => decide
  | more k ih1 ih2 =>
      have hstep : pellP (2 * k + 1 + 4) + pellP (2 * k + 1) = 6 * pellP (2 * k + 1 + 2) :=
        pellP_six_step (2 * k + 1)
      have e1 : 2 * (k + 2) + 1 = 2 * k + 1 + 4 := by ring
      have e2 : 2 * (k + 1) + 1 = 2 * k + 1 + 2 := by ring
      rw [e2] at ih2
      rw [e1]
      omega

/-! ## Refutation: the hypotenuse need not be prime -/

theorem pellP_seven' : pellP 7 = 169 := by decide

/-- **Refutation.**  "The hypotenuse of a near-isosceles Pythagorean triple is prime" is
false: `119² + 120² = 169²` and `169 = 13²`.  The failure is exactly the failure of
squarefreeness on the Pell spine (`Novelty.PellSpineDivisibility.not_pellP_squarefree`). -/
theorem not_nearIsosceles_hyp_prime :
    ¬ ∀ a c : ℕ, 0 < a → a ^ 2 + (a + 1) ^ 2 = c ^ 2 → Nat.Prime c := by
  intro h
  have := h 119 169 (by norm_num) (by norm_num)
  norm_num at this

/-- The witnessing triple lives on the spine at index `7`. -/
theorem witness_on_spine :
    2 * 119 + 1 = pellQ 7 ∧ (169 : ℕ) = pellP 7 := by
  constructor <;> decide

end Catalog.Novelty.PellSpine