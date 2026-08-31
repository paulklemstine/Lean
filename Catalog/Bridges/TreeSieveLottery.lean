import Mathlib

/-!
# The tree sieve is a lottery: three obstructions to Berggren-tree factoring

This file formalises the negative analysis of the "TREE-SIEVE" proposal
(round-72 experiment `exp556`): one collects leg pairs `(mᵢ, nᵢ)` from the
Berggren ternary tree of primitive Pythagorean triples, arranges that

  `∏ (mᵢ - nᵢ)(mᵢ + nᵢ) = Y²`

is a perfect square, and hopes that `gcd(X - Y, N)` splits a semiprime `N`.

Three independent obstructions are proved here.

## Obstruction 1 — an identity in `ℤ` carries no information mod `N`

`intSquareRelation_gcd_trivial`: if `X² = Y²` holds *in `ℤ`* with `X, Y ≥ 0`,
then `X = Y`, so `gcd (X - Y) N = N`: the returned "factor" is `N` itself.
A congruence of squares is only useful when it holds modulo `N` **and** the
two roots are inequivalent (`dixon_split_nontrivial` below).

## Obstruction 2 — `N`-independent tickets are a lottery

The candidate pairs produced by the tree do not depend on `N`, so the sieve
outputs a fixed integer `D` (`= X - Y`) and wins exactly when a prime factor of
`N` happens to divide `D`.  Since `D` has at most `log₂ D` prime factors, the
number of winning primes in any pool `S` of candidate primes is at most
`log₂ D` (`prime_hits_le_log`), and `k` tickets win on at most `∑ log₂ Dᵢ`
primes (`lottery_union_bound`) — tickets add linearly, exactly the behaviour
observed end-to-end (8/12000 versus 4/12000).  In probability form this is
`lottery_probability_bound`.

## Obstruction 3 — BFS starvation in the Berggren tree

Along every branch of the Berggren tree the hypotenuse grows by a factor of at
most `7`, so a node at depth `L` has hypotenuse at most `5 · 7 ^ L`
(`berg_hyp_le`).  Breadth-first search must expand at least `3 ^ L` nodes to
reach depth `L` (`three_pow_le_nodesUpTo`), and since `7 ≤ 9 = 3²` the number of
expanded nodes is at least the square root of the hypotenuse window:
`bfs_starvation` states `V ≤ 5 * (nodesUpTo L)²` whenever a node of depth `L`
has hypotenuse at least `V`.

Finally `dixon_split_nontrivial` shows that the *corrected* variant — forcing
`u ≡ v [ZMOD N]`-style congruences — is precisely the Dixon / quadratic-sieve
mechanism, which is where all corrected variants collapse.
-/

namespace TreeSieve

/-! ## Obstruction 1: integer identities are vacuous modulo `N` -/

/-- Two nonnegative integers with equal squares are equal. -/
theorem eq_of_sq_eq_sq_of_nonneg {X Y : ℤ} (hX : 0 ≤ X) (hY : 0 ≤ Y)
    (h : X ^ 2 = Y ^ 2) : X = Y := by
  nlinarith [sq_nonneg (X - Y), sq_nonneg (X + Y)]

/-- **Obstruction 1.**  A square identity that holds *in `ℤ`* produces the
difference `0`, so the gcd step returns `N` itself: no split. -/
theorem intSquareRelation_gcd_trivial {X Y : ℤ} (N : ℤ) (hX : 0 ≤ X) (hY : 0 ≤ Y)
    (h : X ^ 2 = Y ^ 2) : Int.gcd (X - Y) N = N.natAbs := by
  have : X - Y = 0 := by rw [eq_of_sq_eq_sq_of_nonneg hX hY h]; ring
  rw [this]
  simp [Int.gcd]

/-- The same statement in the form actually used by the sieve: an integer
identity forces `X ≡ Y` modulo *every* modulus, so no modulus is distinguished
and the candidate carries no information about `N`. -/
theorem intSquareRelation_no_information {X Y : ℤ} (hX : 0 ≤ X) (hY : 0 ≤ Y)
    (h : X ^ 2 = Y ^ 2) : ∀ N : ℤ, N ∣ (X - Y) := by
  intro N
  rw [eq_of_sq_eq_sq_of_nonneg hX hY h]
  simp

/-! ## The corrected mechanism: Dixon's congruence of squares -/

/-- **Dixon split.**  A genuine congruence of squares modulo `N` — `N ∣ x² - y²`
with `x ≢ ± y` — yields a nontrivial factor of `N` through one gcd.  Every
"corrected" tree-sieve variant that reduces the relation modulo `N` lands here,
i.e. in the Dixon / quadratic-sieve class. -/
theorem dixon_split_nontrivial {N x y : ℤ} (hN : 1 < N) (hdvd : N ∣ (x - y) * (x + y))
    (h1 : ¬ N ∣ (x - y)) (h2 : ¬ N ∣ (x + y)) :
    1 < Int.gcd (x - y) N ∧ (Int.gcd (x - y) N : ℤ) < N := by
  have hgdvd : (Int.gcd (x - y) N : ℤ) ∣ N := Int.gcd_dvd_right _ _
  constructor
  · by_contra hle
    push_neg at hle
    interval_cases hg : Int.gcd (x - y) N
    · exact h1 ((Int.gcd_eq_zero_iff.mp hg).1 ▸ dvd_zero N)
    · have hcop : IsCoprime (x - y) N := Int.isCoprime_iff_gcd_eq_one.mpr hg
      exact h2 (hcop.symm.dvd_of_dvd_mul_left hdvd)
  · rcases lt_or_eq_of_le (Int.le_of_dvd (by omega) hgdvd) with h | h
    · exact h
    · exact absurd (h ▸ Int.gcd_dvd_left (a := x - y) (b := N)) h1

/-! ## Obstruction 2: the lottery bound for `N`-independent tickets -/

/-- An integer has at most `log₂` many distinct prime factors. -/
theorem card_primeFactors_le_log2 {D : ℕ} (hD : D ≠ 0) :
    D.primeFactors.card ≤ Nat.log 2 D := by
  have h1 : 2 ^ D.primeFactors.card ≤ ∏ p ∈ D.primeFactors, p :=
    Finset.pow_card_le_prod _ _ 2 fun p hp => (Nat.prime_of_mem_primeFactors hp).two_le
  have h2 : (∏ p ∈ D.primeFactors, p) ≤ D :=
    Nat.le_of_dvd (Nat.pos_of_ne_zero hD) (Nat.prod_primeFactors_dvd D)
  exact (Nat.le_log_iff_pow_le (by norm_num) hD).mpr (le_trans h1 h2)

/-- **One ticket.**  For a fixed, `N`-independent sieve output `D ≠ 0`, the set
of primes in a pool `S` on which the gcd step succeeds has at most `log₂ D`
elements. -/
theorem prime_hits_le_log {D : ℕ} (hD : D ≠ 0) (S : Finset ℕ)
    (hS : ∀ p ∈ S, p.Prime) :
    (S.filter (fun p => p ∣ D)).card ≤ Nat.log 2 D := by
  refine le_trans (Finset.card_le_card ?_) (card_primeFactors_le_log2 hD)
  intro p hp
  simp only [Finset.mem_filter] at hp
  exact Nat.mem_primeFactors.mpr ⟨hS p hp.1, hp.2, hD⟩

/-- **Many tickets add linearly.**  With `k` `N`-independent outputs `D 0, …`,
the winning primes number at most `∑ log₂ Dᵢ`: there is no amplification, which
is the formal content of the "consistent lottery" verdict. -/
theorem lottery_union_bound {k : ℕ} (D : Fin k → ℕ) (hD : ∀ i, D i ≠ 0)
    (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime) :
    (S.filter (fun p => ∃ i, p ∣ D i)).card ≤ ∑ i, Nat.log 2 (D i) := by
  classical
  have hsub : S.filter (fun p => ∃ i, p ∣ D i) ⊆
      Finset.univ.biUnion (fun i : Fin k => S.filter (fun p => p ∣ D i)) := by
    intro p hp
    simp only [Finset.mem_filter] at hp
    obtain ⟨i, hi⟩ := hp.2
    exact Finset.mem_biUnion.mpr ⟨i, Finset.mem_univ i, Finset.mem_filter.mpr ⟨hp.1, hi⟩⟩
  refine le_trans (Finset.card_le_card hsub) ?_
  refine le_trans (Finset.card_biUnion_le) ?_
  exact Finset.sum_le_sum fun i _ => prime_hits_le_log (hD i) S hS

/-- **Lottery in probability form.**  Drawing the hidden prime uniformly from a
pool `S`, the success probability of `k` `N`-independent tickets is at most
`(∑ log₂ Dᵢ) / |S|`; with `|S| ≍ √N / log N` this is the generic
`O(N^{-1/2+o(1)})` gcd luck. -/
theorem lottery_probability_bound {k : ℕ} (D : Fin k → ℕ) (hD : ∀ i, D i ≠ 0)
    (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime) (hne : S.Nonempty) :
    ((S.filter (fun p => ∃ i, p ∣ D i)).card : ℚ) / S.card
      ≤ (∑ i, Nat.log 2 (D i) : ℚ) / S.card := by
  have hpos : (0 : ℚ) < S.card := by exact_mod_cast Finset.card_pos.mpr hne
  have hle : ((S.filter (fun p => ∃ i, p ∣ D i)).card : ℚ) ≤ (∑ i, Nat.log 2 (D i) : ℚ) := by
    exact_mod_cast lottery_union_bound D hD S hS
  gcongr

/-! ## Obstruction 3: BFS starvation in the Berggren tree -/

/-- A Pythagorean triple, as a triple of integers. -/
abbrev Triple := ℤ × ℤ × ℤ

/-- The three Berggren transformations, indexed by `Fin 3`. -/
def step : Fin 3 → Triple → Triple
  | 0, (a, b, c) => (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)
  | 1, (a, b, c) => (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)
  | _, (a, b, c) => (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)

/-- Following a word of moves from a given triple. -/
def bergFrom (t : Triple) : List (Fin 3) → Triple
  | [] => t
  | i :: w => bergFrom (step i t) w

/-- The node of the Berggren tree addressed by a word, rooted at `(3, 4, 5)`. -/
def bergOf (w : List (Fin 3)) : Triple := bergFrom (3, 4, 5) w

/-- The structural invariant of the tree: legs are positive and smaller than the
hypotenuse. -/
def Adm (t : Triple) : Prop := 0 < t.1 ∧ 0 < t.2.1 ∧ t.1 < t.2.2 ∧ t.2.1 < t.2.2

theorem adm_root : Adm (3, 4, 5) := by refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

theorem adm_step (i : Fin 3) {t : Triple} (h : Adm t) : Adm (step i t) := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨h1, h2, h3, h4⟩ := h
  simp only [Adm] at *
  fin_cases i <;> simp only [step] <;> refine ⟨by omega, by omega, by omega, by omega⟩

/-- Every Berggren move preserves the Pythagorean relation. -/
theorem step_pyth (i : Fin 3) (t : Triple) (h : t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2) :
    (step i t).1 ^ 2 + (step i t).2.1 ^ 2 = (step i t).2.2 ^ 2 := by
  obtain ⟨a, b, c⟩ := t
  simp only at h
  fin_cases i <;> simp only [step] <;> nlinarith [h]

theorem bergFrom_pyth (w : List (Fin 3)) {t : Triple}
    (h : t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2) :
    (bergFrom t w).1 ^ 2 + (bergFrom t w).2.1 ^ 2 = (bergFrom t w).2.2 ^ 2 := by
  induction w generalizing t with
  | nil => simpa [bergFrom] using h
  | cons i w ih => exact ih (step_pyth i t h)

/-- Every node of the Berggren tree is a Pythagorean triple. -/
theorem bergOf_pyth (w : List (Fin 3)) :
    (bergOf w).1 ^ 2 + (bergOf w).2.1 ^ 2 = (bergOf w).2.2 ^ 2 :=
  bergFrom_pyth w (by norm_num)

theorem bergFrom_adm (w : List (Fin 3)) {t : Triple} (h : Adm t) : Adm (bergFrom t w) := by
  induction w generalizing t with
  | nil => simpa [bergFrom] using h
  | cons i w ih => exact ih (adm_step i h)

/-- One Berggren move multiplies the hypotenuse by at most `7`. -/
theorem step_hyp_le (i : Fin 3) {t : Triple} (h : Adm t) :
    (step i t).2.2 ≤ 7 * t.2.2 := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨h1, h2, h3, h4⟩ := h
  simp only at *
  fin_cases i <;> simp only [step] <;> omega

/-- **Geometric ceiling.**  A node at depth `L` has hypotenuse at most
`5 · 7 ^ L`. -/
theorem bergFrom_hyp_le (w : List (Fin 3)) {t : Triple} (h : Adm t) :
    (bergFrom t w).2.2 ≤ 7 ^ w.length * t.2.2 := by
  induction w generalizing t with
  | nil => simp [bergFrom]
  | cons i w ih =>
      have hstep := ih (adm_step i h)
      have h7 := step_hyp_le i h
      have hpos : (0:ℤ) < 7 ^ w.length := by positivity
      calc (bergFrom t (i :: w)).2.2 = (bergFrom (step i t) w).2.2 := rfl
        _ ≤ 7 ^ w.length * (step i t).2.2 := hstep
        _ ≤ 7 ^ w.length * (7 * t.2.2) := by
              exact mul_le_mul_of_nonneg_left h7 (le_of_lt hpos)
        _ = 7 ^ (i :: w).length * t.2.2 := by simp [List.length_cons, pow_succ]; ring

theorem berg_hyp_le (w : List (Fin 3)) : (bergOf w).2.2 ≤ 5 * 7 ^ w.length := by
  have := bergFrom_hyp_le w (t := ((3 : ℤ), (4 : ℤ), (5 : ℤ))) adm_root
  simpa [bergOf, mul_comm] using this

/-- Number of nodes of depth at most `L` in a ternary tree. -/
def nodesUpTo (L : ℕ) : ℕ := ∑ i ∈ Finset.range (L + 1), 3 ^ i

theorem three_pow_le_nodesUpTo (L : ℕ) : 3 ^ L ≤ nodesUpTo L := by
  unfold nodesUpTo
  refine Finset.single_le_sum (f := fun i => 3 ^ i) (fun i _ => Nat.zero_le _) ?_
  simp

/-- **Obstruction 3 (BFS starvation).**  If breadth-first search reaches a node
whose hypotenuse is at least `V`, then the number of nodes it has expanded, `n`,
satisfies `V ≤ 5 n²`: the tree must be explored to depth `√(V/5)`-many nodes
before the analysis window `V` is even entered.  (Concretely: with `n = 5·10⁴`
expanded nodes, no node of hypotenuse beyond `1.25·10^10` is ever seen.) -/
theorem bfs_starvation (w : List (Fin 3)) (V : ℤ) (hV : V ≤ (bergOf w).2.2) :
    V ≤ 5 * ((nodesUpTo w.length : ℤ)) ^ 2 := by
  have h1 : (bergOf w).2.2 ≤ 5 * 7 ^ w.length := berg_hyp_le w
  have h2 : (7 : ℤ) ^ w.length ≤ (3 ^ w.length) ^ 2 := by
    rw [← pow_mul, pow_mul']
    gcongr; norm_num
  have h3 : ((3 : ℤ) ^ w.length) ≤ (nodesUpTo w.length : ℤ) := by
    exact_mod_cast three_pow_le_nodesUpTo w.length
  have h4 : ((3:ℤ) ^ w.length) ^ 2 ≤ ((nodesUpTo w.length : ℤ)) ^ 2 := by
    have : (0:ℤ) ≤ 3 ^ w.length := by positivity
    gcongr
  linarith

end TreeSieve