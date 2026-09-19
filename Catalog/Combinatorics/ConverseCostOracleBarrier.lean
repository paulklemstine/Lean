/-
# CONVERSE-COST-CURVE, part V: the black-box converse (cycle 2)

Parts I–IV bound the cost of the *definition routes* of the witness family.
The programme's open target is a converse that no algorithm at all can do
better.  That is out of reach unconditionally, but it becomes a theorem in the
**black-box zero-divisor model**, where the modulus is hidden and is accessed
only through gcd probes `x ↦ gcd(x, N)`.  This file proves the black-box
converse in full:

* `ConverseCost.Strategy` — an adaptive probe strategy: the next probe is any
  function of the answers received so far.
* `ConverseCost.transcript` — the answer transcript of a strategy on a modulus.
* `ConverseCost.transcript_blind` — if every probe of the *null run* misses,
  the real transcript is the null transcript `[1, 1, …, 1]`.
* `ConverseCost.exists_blind_semiprimes` — for any strategy and any query budget
  `T`, there are **two** semiprimes with different factorisations on which the
  strategy sees the very same all-ones transcript.
* `ConverseCost.no_oracle_algorithm` — hence no `T`-query black-box algorithm,
  with any output rule whatsoever, returns the factor pair for every semiprime:
  the information barrier is absolute, not merely a cost barrier.

This is the "no-pinning" half of the converse, made adversarial and adaptive.
-/
import Mathlib
import Combinatorics.ConverseCostScanBarrier

namespace ConverseCost

open Finset

/-- An adaptive black-box strategy: given the list of gcd answers received so
far, it chooses the next residue to probe. -/
def Strategy : Type := List ℕ → ℕ

/-- The answer transcript produced by a strategy after `n` probes of the hidden
modulus `N`. -/
def transcript (S : Strategy) (N : ℕ) : ℕ → List ℕ
  | 0 => []
  | (n + 1) => (transcript S N n).concat (Nat.gcd (S (transcript S N n)) N)

/-- The *null run*: the probes the strategy would make if every answer were `1`. -/
def nullProbe (S : Strategy) (n : ℕ) : ℕ := S (List.replicate n 1)

/-- If every null probe misses (`gcd = 1`), the real transcript is the null
transcript: the strategy cannot tell which modulus it is talking to. -/
theorem transcript_blind (S : Strategy) (N T : ℕ)
    (h : ∀ n < T, Nat.gcd (nullProbe S n) N = 1) :
    transcript S N T = List.replicate T 1 := by
  induction T with
  | zero => simp [transcript]
  | succ n ih =>
      have ihn : transcript S N n = List.replicate n 1 :=
        ih (fun m hm => h m (by omega))
      have hprobe : Nat.gcd (S (List.replicate n 1)) N = 1 := h n (by omega)
      rw [transcript, ihn, hprobe, List.concat_eq_append, ← List.replicate_succ']

/-- Every positive residue below both primes is a unit modulo `N = p q`. -/
theorem gcd_eq_one_of_lt_primes {p q x : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hx0 : 0 < x) (hxp : x < p) (hxq : x < q) : Nat.gcd x (p * q) = 1 := by
  by_contra hne
  have hgt : 1 < Nat.gcd x (p * q) := by
    have : 0 < Nat.gcd x (p * q) :=
      Nat.gcd_pos_of_pos_right x (Nat.mul_pos hp.pos hq.pos)
    omega
  rcases (hit_iff_dvd hp hq).mp hgt with h | h
  · exact absurd (Nat.le_of_dvd hx0 h) (not_le.mpr hxp)
  · exact absurd (Nat.le_of_dvd hx0 h) (not_le.mpr hxq)

/-- Four distinct primes, all larger than a prescribed bound. -/
theorem exists_four_large_primes (B : ℕ) :
    ∃ p₁ q₁ p₂ q₂ : ℕ, p₁.Prime ∧ q₁.Prime ∧ p₂.Prime ∧ q₂.Prime ∧
      B < p₁ ∧ p₁ < q₁ ∧ q₁ < p₂ ∧ p₂ < q₂ := by
  obtain ⟨p₁, hp₁ge, hp₁⟩ := Nat.exists_infinite_primes (B + 1)
  obtain ⟨q₁, hq₁ge, hq₁⟩ := Nat.exists_infinite_primes (p₁ + 1)
  obtain ⟨p₂, hp₂ge, hp₂⟩ := Nat.exists_infinite_primes (q₁ + 1)
  obtain ⟨q₂, hq₂ge, hq₂⟩ := Nat.exists_infinite_primes (p₂ + 1)
  exact ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, by omega, by omega, by omega, by omega⟩

/-- **The black-box converse, existence half.**  For any adaptive strategy whose
probes are positive and any query budget `T`, there are two semiprimes with
*disjoint* factorisations on which the strategy receives the identical all-ones
transcript. -/
theorem exists_blind_semiprimes (S : Strategy) (T : ℕ)
    (hpos : ∀ l, 0 < S l) :
    ∃ p₁ q₁ p₂ q₂ : ℕ, p₁.Prime ∧ q₁.Prime ∧ p₂.Prime ∧ q₂.Prime ∧
      p₁ < q₁ ∧ p₂ < q₂ ∧ p₁ < p₂ ∧
      transcript S (p₁ * q₁) T = List.replicate T 1 ∧
      transcript S (p₂ * q₂) T = List.replicate T 1 := by
  classical
  -- a bound on all probes of the null run
  set B : ℕ := (Finset.range T).sup (fun n => nullProbe S n) with hB
  obtain ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, hBp₁, h12, h23, h34⟩ :=
    exists_four_large_primes B
  have hbound : ∀ n < T, nullProbe S n ≤ B := by
    intro n hn
    exact Finset.le_sup (f := fun n => nullProbe S n) (Finset.mem_range.mpr hn)
  have hmiss : ∀ (p q : ℕ), p.Prime → q.Prime → B < p → B < q →
      ∀ n < T, Nat.gcd (nullProbe S n) (p * q) = 1 := by
    intro p q hp hq hBp hBq n hn
    exact gcd_eq_one_of_lt_primes hp hq (hpos _)
      (lt_of_le_of_lt (hbound n hn) hBp) (lt_of_le_of_lt (hbound n hn) hBq)
  refine ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, h12, h34, by omega, ?_, ?_⟩
  · exact transcript_blind S _ T (hmiss p₁ q₁ hp₁ hq₁ hBp₁ (by omega))
  · exact transcript_blind S _ T (hmiss p₂ q₂ hp₂ hq₂ (by omega) (by omega))

/-- **No black-box algorithm factors.**  Fix any adaptive strategy with positive
probes, any query budget `T`, and any output rule `f` reading only the
transcript.  Then some semiprime is answered incorrectly: the pair
`(min p q, max p q)` is not recoverable from `T` gcd probes of a hidden modulus.

Together with parts I–IV this is the converse-cost statement in its sharp form:
in the black-box model the whole witness family is not merely expensive, it is
*blind* — a `T`-query algorithm cannot separate two semiprimes with different
factors. -/
theorem no_oracle_algorithm (S : Strategy) (T : ℕ) (hpos : ∀ l, 0 < S l)
    (f : List ℕ → ℕ × ℕ) :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p < q ∧
      f (transcript S (p * q) T) ≠ (p, q) := by
  obtain ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, h12, h34, hlt, ht₁, ht₂⟩ :=
    exists_blind_semiprimes S T hpos
  by_cases hf : f (transcript S (p₁ * q₁) T) = (p₁, q₁)
  · refine ⟨p₂, q₂, hp₂, hq₂, h34, ?_⟩
    rw [ht₂, ← ht₁, hf]
    intro hcon
    exact absurd (congrArg Prod.fst hcon) (by omega)
  · exact ⟨p₁, q₁, hp₁, hq₁, h12, hf⟩

/-! ## Lab notes -/

/-- The naive increasing scan `x = 1, 2, 3, …` is a strategy: its `n`-th probe
is `n + 1`, independent of the answers. -/
def naiveScan : Strategy := fun l => l.length + 1

example : nullProbe naiveScan 5 = 6 := by decide

/-- On `N = 143` the naive scan is blind for its first `10` probes. -/
example : transcript naiveScan 143 10 = List.replicate 10 1 := by decide

end ConverseCost