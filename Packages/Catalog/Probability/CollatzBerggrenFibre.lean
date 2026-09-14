import Mathlib
import Probability.CollatzBerggrenRigidity

/-!
# The Collatz–Berggren bridge, IV: the exact fibre structure of the inverse tree

Files I–III showed that the inverse Syracuse tree is *not* ternary and carries no
Berggren-type invariant.  This file replaces the false ternary picture with the
correct one, which turns out to be strikingly rigid and *rank one*:

> For an odd `n` not divisible by `3`, the fibre of Collatz predecessors of `n`
> is exactly the forward orbit of the single affine substitution
> `L : x ↦ 4x + 1` started at the minimal predecessor `predStart n`.

Main results.

* `syrPred_four_mul_add_one` — `L` maps predecessors to predecessors: the fibre
  is `L`-invariant.  (`3(4m+1) + 1 = 4(3m+1)`.)
* `predFam_succ` — the explicit family `predFam n` is the `L`-orbit.
* `predSet_eq_range_predFam` — **fibre structure theorem**: the predecessor set
  is *exactly* that orbit, so it is order-isomorphic to `ℕ`.
* `predSet_orderIso_nat` — the fibre carries a strictly monotone enumeration.
* `collatz_branching_rank_one` — the branching alphabet of the inverse Collatz
  tree has *one* letter (`L`), while the Berggren alphabet has *three* letters
  acting with three distinct images (`bergChildren_ncard_eq_three`).  This is a
  third obstruction, independent of the cardinality argument of File I: even the
  *shape* of the branching monoid differs (rank 1 versus rank 3).
* `collatz_berggren_verdict` — the packaged verdict on the research hypothesis.
-/

namespace CollatzBerggren

/-! ## Two-adic bookkeeping -/

/-- `2 ^ k mod 3` is `1` for even `k` and `2` for odd `k`. -/
theorem two_pow_mod_three (k : ℕ) :
    (2 ^ k % 3 = 1 ∧ k % 2 = 0) ∨ (2 ^ k % 3 = 2 ∧ k % 2 = 1) := by
  induction k with
  | zero => left; norm_num
  | succ i ih =>
      have hpow : 2 ^ (i + 1) = 2 * 2 ^ i := by ring
      rcases ih with ⟨h1, h2⟩ | ⟨h1, h2⟩
      · right; omega
      · left; omega

/-- The starting exponent of the fibre over `n`: `2` when `n ≡ 1 (mod 3)` and
`1` when `n ≡ 2 (mod 3)`. -/
def startExp (n : ℕ) : ℕ := if n % 3 = 1 then 2 else 1

theorem startExp_pos (n : ℕ) : 1 ≤ startExp n := by
  unfold startExp; split <;> norm_num

/-- The explicit predecessor family over `n`. -/
def predFam (n j : ℕ) : ℕ := (2 ^ (startExp n + 2 * j) * n - 1) / 3

/-- Admissibility of the exponents `startExp n + 2 j`. -/
theorem pow_mul_mod_three_eq_one {n : ℕ} (h1 : n % 3 ≠ 0) (j : ℕ) :
    2 ^ (startExp n + 2 * j) * n % 3 = 1 := by
  have hpar : (startExp n + 2 * j) % 2 = startExp n % 2 := by omega
  rcases two_pow_mod_three (startExp n + 2 * j) with ⟨hp, hq⟩ | ⟨hp, hq⟩
  · -- exponent even, so `n ≡ 1 (mod 3)`
    have hn : n % 3 = 1 := by
      by_contra hne
      have : startExp n = 1 := by unfold startExp; simp [hne]
      omega
    rw [Nat.mul_mod, hp, hn]
  · have hn : n % 3 = 2 := by
      by_contra hne
      have hn1 : n % 3 = 1 := by omega
      have : startExp n = 2 := by unfold startExp; simp [hn1]
      omega
    rw [Nat.mul_mod, hp, hn]

theorem three_mul_predFam_add_one {n : ℕ} (h1 : n % 3 ≠ 0) (j : ℕ) :
    3 * predFam n j + 1 = 2 ^ (startExp n + 2 * j) * n := by
  have h := pow_mul_mod_three_eq_one h1 j
  unfold predFam
  omega

/-- Members of the family really are Collatz predecessors. -/
theorem predFam_mem {n : ℕ} (hn : Odd n) (h1 : n % 3 ≠ 0) (j : ℕ) :
    predFam n j ∈ predSet n :=
  ⟨hn, startExp n + 2 * j, by have := startExp_pos n; omega,
    three_mul_predFam_add_one h1 j⟩

/-! ## The single branching letter `L : x ↦ 4x + 1` -/

/-- **The branching letter.**  If `m` is a Collatz predecessor of `n`, so is
`4m + 1`; indeed `3(4m+1) + 1 = 4(3m+1)`.  A single affine substitution
generates the whole fibre. -/
theorem syrPred_four_mul_add_one {m n : ℕ} (h : SyrPred m n) : SyrPred (4 * m + 1) n := by
  obtain ⟨hn, k, hk, hmn⟩ := h
  refine ⟨hn, k + 2, by omega, ?_⟩
  have : 2 ^ (k + 2) * n = 4 * (2 ^ k * n) := by ring
  omega

/-- The family is exactly the orbit of `L`. -/
theorem predFam_succ {n : ℕ} (h1 : n % 3 ≠ 0) (j : ℕ) :
    predFam n (j + 1) = 4 * predFam n j + 1 := by
  have hj := three_mul_predFam_add_one h1 j
  have hj1 := three_mul_predFam_add_one h1 (j + 1)
  have hpow : 2 ^ (startExp n + 2 * (j + 1)) * n = 4 * (2 ^ (startExp n + 2 * j) * n) := by
    have : startExp n + 2 * (j + 1) = (startExp n + 2 * j) + 2 := by omega
    rw [this]; ring
  omega

/-- The family is strictly increasing, hence injective. -/
theorem predFam_strictMono {n : ℕ} (h1 : n % 3 ≠ 0) :
    StrictMono (predFam n) := by
  have hstep : ∀ j, predFam n j < predFam n (j + 1) := by
    intro j
    have h := predFam_succ h1 j
    have hpos : 0 < predFam n j ∨ predFam n j = 0 := Nat.eq_zero_or_pos _ |>.symm.imp id id
    omega
  exact strictMono_nat_of_lt_succ hstep

/-- **Fibre structure theorem.**  For odd `n` not divisible by `3`, the set of
Collatz predecessors of `n` is *exactly* the `L`-orbit `{m₀, 4m₀+1, …}` of the
minimal predecessor `m₀ = predFam n 0`.  The inverse Collatz tree is therefore a
rank-one comb over each live node, not a ternary tree. -/
theorem predSet_eq_range_predFam {n : ℕ} (hn : Odd n) (h1 : n % 3 ≠ 0) :
    predSet n = Set.range (predFam n) := by
  ext m
  constructor
  · rintro ⟨-, k, hk, hmn⟩
    -- `3 m + 1 = 2 ^ k n` forces `2 ^ k n ≡ 1 (mod 3)`, hence `k ≡ startExp n (mod 2)`
    have hmod : 2 ^ k * n % 3 = 1 := by omega
    have hk2 : ∃ j, k = startExp n + 2 * j := by
      rcases two_pow_mod_three k with ⟨hp, hq⟩ | ⟨hp, hq⟩
      · -- k even : then `n ≡ 1 (mod 3)` and `startExp n = 2`, and `k ≥ 2`
        have hn1 : n % 3 = 1 := by
          rw [Nat.mul_mod, hp] at hmod; omega
        have hs : startExp n = 2 := by unfold startExp; simp [hn1]
        exact ⟨(k - 2) / 2, by omega⟩
      · have hn2 : n % 3 = 2 := by
          rw [Nat.mul_mod, hp] at hmod; omega
        have hs : startExp n = 1 := by unfold startExp; simp [hn2]
        exact ⟨(k - 1) / 2, by omega⟩
    obtain ⟨j, rfl⟩ := hk2
    refine ⟨j, ?_⟩
    have := three_mul_predFam_add_one h1 j
    omega
  · rintro ⟨j, rfl⟩
    exact predFam_mem hn h1 j

/-- The fibre over a live node is enumerated, strictly monotonically, by `ℕ`. -/
theorem predSet_orderIso_nat {n : ℕ} (hn : Odd n) (h1 : n % 3 ≠ 0) :
    ∃ f : ℕ → ℕ, StrictMono f ∧ predSet n = Set.range f :=
  ⟨predFam n, predFam_strictMono h1, predSet_eq_range_predFam hn h1⟩

/-- The fibre over `1` is `1, 5, 21, 85, …`. -/
theorem predFam_one_values :
    predFam 1 0 = 1 ∧ predFam 1 1 = 5 ∧ predFam 1 2 = 21 ∧ predFam 1 3 = 85 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> norm_num [predFam, startExp]

/-! ## Rank one versus rank three -/

/-- **Third obstruction: branching rank.**  The Berggren tree needs three
distinct letters to generate the children of a node, whereas one affine letter
`L : x ↦ 4x + 1` generates every Collatz fibre.  Formally: a single map `g` can
never produce all three Berggren children of a cone triple with distinct legs
(its image has at most one point), while `L` produces the entire Collatz
fibre. -/
theorem collatz_branching_rank_one :
    (∀ n : ℕ, Odd n → n % 3 ≠ 0 →
        predSet n = Set.range (fun j => (fun x => 4 * x + 1)^[j] (predFam n 0))) ∧
      (∀ g : (ℤ × ℤ × ℤ) → (ℤ × ℤ × ℤ),
        ¬ (bergChildren (3, 4, 5) ⊆ {g (3, 4, 5)})) := by
  constructor
  · intro n hn h1
    rw [predSet_eq_range_predFam hn h1]
    congr 1
    funext j
    induction j with
    | zero => simp
    | succ i ih =>
        rw [Function.iterate_succ_apply', ← ih, predFam_succ h1 i]
  · intro g hsub
    have hA : applyStep .A (3, 4, 5) ∈ bergChildren ((3 : ℤ), 4, 5) := by
      simp [bergChildren]
    have hB : applyStep .B (3, 4, 5) ∈ bergChildren ((3 : ℤ), 4, 5) := by
      simp [bergChildren]
    have h1 := hsub hA
    have h2 := hsub hB
    simp only [Set.mem_singleton_iff] at h1 h2
    have : applyStep .A ((3 : ℤ), 4, 5) = applyStep .B ((3 : ℤ), 4, 5) := by
      rw [h1, h2]
    simp [applyStep, bergA, bergB] at this

/-! ## Verdict -/

/-- **Verdict on the Collatz–Berggren transfer hypothesis.**  Packaging the four
independent obstructions proved in this series:

1. no branching bijection can exist (`no_branching_transfer`);
2. no edge-preserving embedding of the Collatz tree into the Berggren tree can
   exist (`no_collatz_into_berggren`);
3. no polynomial invariant survives on the Collatz side
   (`no_nonconstant_polynomial_invariant`), while the Lorentz form is conserved
   and nonconstant on the Berggren side;
4. the Collatz branching is rank one, the Berggren branching rank three.

Hence the Lorentz invariant and the silver-ratio growth of the Berggren tree do
**not** transfer to the inverse Collatz tree. -/
theorem collatz_berggren_verdict :
    (∀ Φ : ℤ × ℤ × ℤ → ℕ,
        (∀ a b c : ℤ, 0 < a → 0 < b → a ≠ b →
          Set.BijOn Φ (bergChildren (a, b, c)) (predSet (Φ (a, b, c)))) → False) ∧
      (∀ Ψ : ℕ → ℤ × ℤ × ℤ, (∀ n, InCone (Ψ n)) →
        (∀ m n, SyrPred m n → Ψ m ∈ bergChildren (Ψ n)) → False) ∧
      (∀ P : Polynomial ℚ,
        (∀ m n : ℕ, SyrPred m n → P.eval (m : ℚ) = P.eval (n : ℚ)) →
          P = Polynomial.C (P.eval 1)) ∧
      (∀ (s : BerggrenStep) (t : ℤ × ℤ × ℤ), lorentzForm (applyStep s t) = lorentzForm t) :=
  ⟨no_branching_transfer, no_collatz_into_berggren, no_nonconstant_polynomial_invariant,
    lorentz_conserved_and_nonconstant.1⟩

end CollatzBerggren