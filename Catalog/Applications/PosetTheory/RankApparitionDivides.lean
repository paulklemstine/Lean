import Mathlib

/-! # The rank of apparition divides `p - 1` or `p + 1`

Domain: Number Theory / Applications (Bridges).

For a prime `p`, the **rank of apparition** (Fibonacci entry point) `α(p)` is the least
positive index `k` with `p ∣ F k` (`RankApparitionDivides.rank`).  The catalog's
apparition theory (`Catalog/Applications/RankOfApparition.lean`,
`Catalog/Applications/FibonacciLucasBridge.lean`, …) establishes the *spine*
`p ∣ F n ↔ α(p) ∣ n`, but it leaves the classical **localisation law** open:

> for every prime `p ≥ 7`, `α(p) ∣ p - 1` **or** `α(p) ∣ p + 1`.

This file proves that law (`rank_dvd_pred_or_succ`).  It is the fact that turns the rank of
apparition from an *a priori* unbounded search into an **explicit algorithm**: once we know
`α(p)` divides one of the two known numbers `p - 1`, `p + 1`, the rank can be computed by
testing the (few) divisors of `p ∓ 1` instead of scanning all indices `k = 1, 2, 3, …`.

## The algorithm for `α(p)`, `p ≥ 7`

```
compute α(p):
  for d in (sorted divisors of p-1) ∪ (sorted divisors of p+1):   -- finite, by the theorem
      if p ∣ F d : return d
```
`rank_dvd_pred_or_succ` certifies that this loop always returns: the true rank is **some**
divisor of `p - 1` or of `p + 1`, and the spine `dvd_fib_iff_rank_dvd` certifies that the
**first** such `d` found is exactly `α(p)` (any `d` with `p ∣ F d` is a multiple of `α(p)`, and
the least one over the divisor set is `α(p)` itself).  No unbounded search is needed.

## Resolving the circularity

A naive derivation of "`α(p) ∣ p - 1` or `α(p) ∣ p + 1`" tends to be *circular*: it wants to
reason about the multiplicative order of the golden ratio modulo `p`, which is itself defined
through the entry point one is trying to bound.  We break the circle by computing the only
Fibonacci value whose residue can be pinned **independently** of the rank, namely `F p` mod `p`:

* `pow_succ_of_golden` — the **binomial / Binet identity** in any commutative ring: if
  `a² = a + 1` then `aⁿ⁺¹ = F (n+1) · a + F n`.  Applied to the two roots `φ, ψ = 1 - φ` of
  `x² - x - 1` in `S = AdjoinRoot (X² - X - 1)` over `ZMod p`, it expresses `φᵖ - ψᵖ` through `F p`.
* The **Frobenius endomorphism** `x ↦ xᵖ` (the additive identity `(x+y)ᵖ = xᵖ + yᵖ`,
  `add_pow_char`) is the conceptual form of the *discrete-logarithm / Euler-criterion* content:
  it gives `φᵖ + ψᵖ = (φ+ψ)ᵖ = 1` and `φᵖ · ψᵖ = (φψ)ᵖ = -1`, hence `(φᵖ - ψᵖ)² = 5`.  This is
  exactly the statement `(1+√5)ᵖ ≡ 1 + (√5)ᵖ (mod p)` with `(√5)ᵖ = 5^{(p-1)/2}·√5`, i.e. the
  Legendre symbol `(5 ∣ p)` entering through Fermat's little theorem — **no reference to the rank**.
* `fib_sq_mod` — combining the two: `(F p)² · 5 = 5` in `S`, descended through the injective
  `algebraMap (ZMod p) S` to `(F p)² = 1` in `ZMod p` (using `p ∤ 5`).  So `F p ≡ ±1 (mod p)`.
* `cassini` — Cassini's identity `F(n+2)·F n + (-1)ⁿ = F(n+1)²` over `ℤ`.  At `n = p - 1`
  (even, since `p` is odd) it reads `F(p+1)·F(p-1) + 1 = (F p)²`, so mod `p` we get
  `F(p+1)·F(p-1) ≡ 0`, and primality gives `p ∣ F(p-1) ∨ p ∣ F(p+1)` (`p_dvd_fib_pred_or_succ`).
* The spine `dvd_fib_iff_rank_dvd` then converts these into `α(p) ∣ p-1 ∨ α(p) ∣ p+1`.

Every input (`add_pow_char`, Cassini, the Binet recurrence) is proved without ever mentioning
`α(p)`, which is what removes the circularity.

## How modern computational tools support this

* **Interactive proof assistants (Lean 4 / Mathlib).**  The whole derivation is machine-checked
  here.  Mathlib supplies the reusable algebra — `AdjoinRoot`, `CharP`, the Frobenius lemma
  `add_pow_char`, `ZMod` field structure — so that the number-theoretic core (`fib_sq_mod`) is a
  short, auditable argument rather than a hand computation with `(1±√5)ᵖ`.
* **Decision procedures.**  `decide` / `compute_degree!` discharge the finite/structural side
  conditions (degree of `x²-x-1`, nontriviality of the ring), and `linear_combination` / `ring`
  reduce the ring identities to certified polynomial algebra.
* **Computer algebra & search.**  `α(p)` itself is computed by the bounded divisor loop above;
  the law proved here is precisely what makes that loop terminate quickly, so a CAS or a `#eval`
  in Lean can tabulate `α(p)` for large `p` and look for patterns.

## Open questions

* **Wall's conjecture (Wall–Sun–Sun primes).**  Whether `p² ∤ F (α(p))` for every prime `p`,
  equivalently `α(p²) = p · α(p)`.  No counterexample is known; the law proved here bounds
  `α(p)` but says nothing about the prime-power lift `α(pᵏ)`.
* **The exact value of `α(p)` within `{p-1, p+1}`.**  Whether `α(p) ∣ p-1` or `α(p) ∣ p+1` is
  governed by the Legendre symbol `(5 ∣ p)` (i.e. `p mod 5`); refining this file to output *which*
  of the two divisibilities holds, and the exact `α(p)`, is a natural next formalisation.
* **Distribution / density.**  The statistics of `α(p)` (e.g. how often `α(p) = p ∓ 1`, the
  density of primes with prescribed rank) remain conjectural and are only accessible
  computationally.
-/

namespace RankApparitionDivides

open Polynomial
open scoped Classical

/-! ## §0. The rank of apparition (self-contained restatement) -/

/-- `m` *has a rank of apparition*: it divides some positive-index Fibonacci number. -/
def HasRank (m : ℕ) : Prop := ∃ k, 0 < k ∧ m ∣ Nat.fib k

/-- The Fibonacci rank of apparition of `m`: least `k > 0` with `m ∣ F k` (else `0`). -/
noncomputable def rank (m : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ m ∣ Nat.fib k then Nat.find h else 0

/-- Existence of the rank (pigeonhole on the finite state `(F k, F (k+1)) mod m`). -/
theorem exists_pos_dvd_fib (m : ℕ) (hm : 0 < m) : HasRank m := by
  by_contra h_contra
  have h_pair_seq : ∃ i j, i < j ∧
      (Nat.fib i % m, Nat.fib (i + 1) % m) = (Nat.fib j % m, Nat.fib (j + 1) % m) := by
    by_contra h_contra
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm
        ( not_lt.1 fun hi => h_contra ⟨ j, i, hi, hij.symm ⟩ )
        ( not_lt.1 fun hj => h_contra ⟨ i, j, hj, hij ⟩ ) ) )
      ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ ( m, m ), by
          rintro a ⟨ i, rfl ⟩
          exact ⟨ Nat.le_of_lt <| Nat.mod_lt _ hm, Nat.le_of_lt <| Nat.mod_lt _ hm ⟩ ⟩ )
  obtain ⟨ i, j, hij, h ⟩ := h_pair_seq
  induction' i with i ih generalizing j
  · exact h_contra ⟨ j, hij, Nat.dvd_of_mod_eq_zero ( by simpa using congr_arg Prod.fst h.symm ) ⟩
  · rcases j <;> simp_all +decide [ Nat.fib_add_two ]
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ]
    grind

theorem rank_pos (m : ℕ) (h : HasRank m) : 0 < rank m := by
  obtain ⟨ k, hk ⟩ := h; unfold rank; split_ifs <;> aesop

theorem dvd_fib_rank (m : ℕ) (h : HasRank m) : m ∣ Nat.fib (rank m) := by
  have h_rank : m ∣ Nat.fib (Nat.find h) := Nat.find_spec h |>.2
  unfold rank; aesop

/-- **The spine.** `m ∣ F k ↔ α(m) ∣ k`. -/
theorem dvd_fib_iff_rank_dvd (m k : ℕ) (h : HasRank m) :
    m ∣ Nat.fib k ↔ rank m ∣ k := by
  have h_rank_div : ∀ k, m ∣ Nat.fib k → rank m ∣ k := by
    intros k hk
    have h_gcd : m ∣ Nat.fib (Nat.gcd (rank m) k) := by
      convert Nat.dvd_gcd ( dvd_fib_rank m h ) hk using 1; exact Nat.fib_gcd (rank m) k
    have h_min : ∀ k, 0 < k → m ∣ Nat.fib k → rank m ≤ k := by unfold rank; aesop
    contrapose! h_min
    exact ⟨ Nat.gcd ( rank m ) k, Nat.gcd_pos_of_pos_left _ ( rank_pos m h ), h_gcd,
      lt_of_le_of_ne ( Nat.le_of_dvd ( rank_pos m h ) ( Nat.gcd_dvd_left _ _ ) )
        fun con => h_min <| con.symm ▸ Nat.gcd_dvd_right _ _ ⟩
  refine' ⟨ h_rank_div k, fun hk => _ ⟩
  exact dvd_trans ( dvd_fib_rank m h ) ( by obtain ⟨ c, rfl ⟩ := hk; simp [ Nat.fib_dvd ] )

/-! ## §1. The binomial / Binet identity in a golden-ratio ring -/

/-- **Binet recurrence.**  In any commutative ring, an element `a` with `a² = a + 1`
satisfies `aⁿ⁺¹ = F (n+1) · a + F n`.  This is the binomial identity underlying Binet's
formula, stated ring-theoretically so it applies verbatim modulo `p`. -/
lemma pow_succ_of_golden {R : Type*} [CommRing R] (a : R) (ha : a ^ 2 = a + 1) :
    ∀ n : ℕ, a ^ (n + 1) = (Nat.fib (n + 1) : R) * a + (Nat.fib n : R) := by
  intro n
  induction n with
  | zero => simp
  | succ k ih =>
    have hstep : a ^ (k + 2) = a * a ^ (k + 1) := by ring
    have hfib : Nat.fib (k + 2) = Nat.fib k + Nat.fib (k + 1) := Nat.fib_add_two
    rw [hstep, ih, hfib]; push_cast
    linear_combination (Nat.fib (k + 1) : R) * ha

/-- The golden polynomial `x² - x - 1` over `ZMod p`. -/
noncomputable abbrev goldenPoly (p : ℕ) : (ZMod p)[X] := X ^ 2 - X - 1

/-! ## §2. `F p ≡ ±1 (mod p)` via Frobenius -/

/-- **The discrete-log core.** `(F p)² ≡ 1 (mod p)` for every prime `p ≥ 7`.
Proved in `S = AdjoinRoot (x²-x-1)` over `ZMod p`: with `φ` a root and `ψ = 1 - φ`, the
Frobenius identities `φᵖ + ψᵖ = 1`, `φᵖ·ψᵖ = -1` give `(φᵖ - ψᵖ)² = 5`, while the Binet
recurrence gives `φᵖ - ψᵖ = F p · (φ - ψ)` with `(φ - ψ)² = 5`, hence `(F p)²·5 = 5`. -/
theorem fib_sq_mod (p : ℕ) (hp : Nat.Prime p) (hp7 : 7 ≤ p) :
    (Nat.fib p : ZMod p) ^ 2 = 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨by omega⟩
  set S := AdjoinRoot (goldenPoly p) with hS
  haveI hnt : Nontrivial S := by
    apply AdjoinRoot.nontrivial
    rw [show (goldenPoly p).degree = 2 by unfold goldenPoly; compute_degree!]; decide
  haveI hchar : CharP S p := charP_of_injective_algebraMap (algebraMap (ZMod p) S).injective p
  set φ : S := AdjoinRoot.root (goldenPoly p) with hφ
  have hφsq : φ ^ 2 = φ + 1 := by
    have key : (goldenPoly p).eval₂ (algebraMap (ZMod p) S) φ = 0 :=
      AdjoinRoot.eval₂_root (goldenPoly p)
    simp only [goldenPoly, eval₂_sub, eval₂_pow, eval₂_X, eval₂_one] at key
    linear_combination key
  set ψ : S := 1 - φ with hψ
  have hψsq : ψ ^ 2 = ψ + 1 := by rw [hψ]; linear_combination hφsq
  have hsum : φ + ψ = 1 := by rw [hψ]; ring
  have hprod : φ * ψ = -1 := by rw [hψ]; linear_combination -hφsq
  have hp1 : (p - 1) + 1 = p := by omega
  have hφp : φ ^ p = (Nat.fib p : S) * φ + (Nat.fib (p - 1) : S) := by
    have := pow_succ_of_golden φ hφsq (p - 1); rwa [hp1] at this
  have hψp : ψ ^ p = (Nat.fib p : S) * ψ + (Nat.fib (p - 1) : S) := by
    have := pow_succ_of_golden ψ hψsq (p - 1); rwa [hp1] at this
  have hdiff : φ ^ p - ψ ^ p = (Nat.fib p : S) * (φ - ψ) := by rw [hφp, hψp]; ring
  have hfrob_sum : φ ^ p + ψ ^ p = 1 := by rw [← add_pow_char φ ψ p, hsum, one_pow]
  have hodd : Odd p := hp.odd_of_ne_two (by omega)
  have hfrob_prod : φ ^ p * ψ ^ p = -1 := by rw [← mul_pow, hprod, hodd.neg_one_pow]
  have hsq5 : (φ ^ p - ψ ^ p) ^ 2 = 5 := by
    have e : (φ ^ p - ψ ^ p) ^ 2 = (φ ^ p + ψ ^ p) ^ 2 - 4 * (φ ^ p * ψ ^ p) := by ring
    rw [e, hfrob_sum, hfrob_prod]; ring
  have hdsq5 : (φ - ψ) ^ 2 = 5 := by rw [hψ]; linear_combination (4 : S) * hφsq
  have hcomb : (Nat.fib p : S) ^ 2 * 5 = 5 := by
    rw [hdiff] at hsq5
    linear_combination hsq5 - (Nat.fib p : S) ^ 2 * hdsq5
  have hdesc : (Nat.fib p : ZMod p) ^ 2 * 5 = 5 := by
    apply (algebraMap (ZMod p) S).injective
    simp only [map_mul, map_pow, map_natCast, map_ofNat]
    exact hcomb
  have h5ne : (5 : ZMod p) ≠ 0 := by
    have hdvd : ¬ (p ∣ 5) := by intro h; have := Nat.le_of_dvd (by norm_num) h; omega
    have h0 : ((5 : ℕ) : ZMod p) ≠ 0 := by rw [Ne, ZMod.natCast_eq_zero_iff]; exact hdvd
    simpa using h0
  have hfin : (Nat.fib p : ZMod p) ^ 2 * 5 = 1 * 5 := by rw [one_mul]; exact hdesc
  exact mul_right_cancel₀ h5ne hfin

/-! ## §3. Cassini's identity and the divisibility dichotomy -/

/-- **Cassini's identity** over `ℤ`: `F(n+2)·F n + (-1)ⁿ = F(n+1)²`. -/
theorem cassini (n : ℕ) :
    (Nat.fib (n + 2) : ℤ) * (Nat.fib n) + (-1) ^ n = (Nat.fib (n + 1)) ^ 2 := by
  induction n with
  | zero => simp
  | succ k ih =>
    have e2 : (Nat.fib (k + 3) : ℤ) = Nat.fib (k + 1) + Nat.fib (k + 2) := by
      have : Nat.fib (k + 3) = Nat.fib (k + 1) + Nat.fib (k + 2) := Nat.fib_add_two
      exact_mod_cast this
    have e1 : (Nat.fib (k + 2) : ℤ) = Nat.fib k + Nat.fib (k + 1) := by
      have : Nat.fib (k + 2) = Nat.fib k + Nat.fib (k + 1) := Nat.fib_add_two
      exact_mod_cast this
    have hpow : ((-1 : ℤ)) ^ (k + 1) = -(-1) ^ k := by ring
    rw [hpow]
    linear_combination -ih + (Nat.fib (k + 1) : ℤ) * e2 - (Nat.fib (k + 2) : ℤ) * e1

/-- For a prime `p ≥ 7`, `p ∣ F(p-1)` or `p ∣ F(p+1)`.
Cassini at `n = p-1` reads `F(p+1)·F(p-1) + 1 = (F p)²`, which is `0` mod `p` by `fib_sq_mod`. -/
theorem p_dvd_fib_pred_or_succ (p : ℕ) (hp : Nat.Prime p) (hp7 : 7 ≤ p) :
    p ∣ Nat.fib (p - 1) ∨ p ∣ Nat.fib (p + 1) := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨by omega⟩
  have hc := cassini (p - 1)
  have e1 : (p - 1) + 1 = p := by omega
  have e2 : (p - 1) + 2 = p + 1 := by omega
  rw [e1, e2] at hc
  have hpar : ((-1 : ℤ)) ^ (p - 1) = 1 := by
    have : Even (p - 1) := by
      rcases (hp.odd_of_ne_two (by omega)) with ⟨t, ht⟩
      exact ⟨t, by omega⟩
    exact this.neg_one_pow
  rw [hpar] at hc
  have hmod : (Nat.fib (p + 1) : ZMod p) * (Nat.fib (p - 1) : ZMod p) = 0 := by
    have hcast : ((Nat.fib (p + 1) : ℤ) * (Nat.fib (p - 1)) + 1 : ZMod p)
        = ((Nat.fib p : ℤ) ^ 2 : ZMod p) := by
      exact_mod_cast congrArg (Int.cast : ℤ → ZMod p) hc
    push_cast at hcast
    have hsq := fib_sq_mod p hp hp7
    rw [hsq] at hcast
    linear_combination hcast
  rcases mul_eq_zero.mp hmod with h | h
  · right; rw [ZMod.natCast_eq_zero_iff] at h; exact h
  · left; rw [ZMod.natCast_eq_zero_iff] at h; exact h

/-! ## §4. The localisation law: `α(p) ∣ p-1` or `α(p) ∣ p+1` -/

/-- **Main theorem.** For every prime `p ≥ 7`, the rank of apparition `α(p)` divides
`p - 1` or `p + 1`.  This is the localisation law that makes computing `α(p)` a bounded
divisor search rather than an unbounded scan. -/
theorem rank_dvd_pred_or_succ (p : ℕ) (hp : Nat.Prime p) (hp7 : 7 ≤ p) :
    rank p ∣ (p - 1) ∨ rank p ∣ (p + 1) := by
  have hHR : HasRank p := exists_pos_dvd_fib p (by omega)
  rcases p_dvd_fib_pred_or_succ p hp hp7 with h | h
  · exact Or.inl ((dvd_fib_iff_rank_dvd p (p - 1) hHR).1 h)
  · exact Or.inr ((dvd_fib_iff_rank_dvd p (p + 1) hHR).1 h)

end RankApparitionDivides