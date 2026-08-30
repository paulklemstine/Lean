import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness
import MachineLearning.CantorSubshiftDimension
import MachineLearning.GoldenMeanChaos

/-!
# Structural sub/supermultiplicativity of the golden-mean language, and capacity bounds

Sixth cycle of the research thread.  Cycles 1–3 computed the covering numbers of the
golden-mean subshift, `#(goldenWords n) = fib (n + 2)`, and deduced the box dimension
`log φ / log 2` from Fibonacci asymptotics.  Cycle 5 isolated the combinatorial engine behind
Devaney chaos: *gluing with one spacer* (`admissible_glue`).

Here we show that the very same gluing map, together with the fact that the language is closed
under taking factors, gives the two Fekete inequalities

* `card_goldenWords_mul_le` — `#L n * #L m ≤ #L (n + m + 1)` (supermultiplicativity, via the
  injection `(v, w) ↦ v ++ false :: w`);
* `card_goldenWords_add_le` — `#L (n + m) ≤ #L n * #L m` (submultiplicativity, via the
  injection `w ↦ (w.take n, w.drop n)`),

*without* using any Fibonacci identity.  Feeding `card_goldenWords` back in, they yield purely
combinatorial proofs of the two-variable Fibonacci inequalities
`fib (n+2) * fib (m+2) ≤ fib (n+m+3)` and `fib (n+m+2) ≤ fib (n+2) * fib (m+2)`, which is a
combinatorics-to-number-theory bridge.

We then quantify the information deficiency of the subshift: strictly fewer than `2 ⁿ`
admissible words (`card_goldenWords_lt_two_pow`), entropy strictly below `log 2`
(`goldenMean_entropy_lt_log_two`), and a sharp density bound `2 · #{trues} ≤ n + 1` on every
admissible word (`admissible_count_true`, sharp by `admissible_count_true_sharp`).

## Main results

* `card_goldenWords_mul_le`, `card_goldenWords_add_le` — the Fekete inequalities, proved by
  explicit injections between languages.
* `fib_mul_fib_le_fib`, `fib_le_fib_mul_fib` — the resulting Fibonacci inequalities.
* `card_goldenWords_lt_two_pow` — the language is exponentially sparse inside `2 ⁿ`.
* `goldenMean_entropy_lt_log_two` — strict entropy gap against the full shift.
* `admissible_count_true`, `goldenMean_prefix_count_true` — the `1/2` density bound on `true`s,
  shown sharp at every odd length by `admissible_count_true_sharp`.
-/

namespace FractalTruthCompactness

open FractalTruthMetric Metric Filter Topology

/-! ## The language is closed under factors -/

/-- Any prefix of an admissible word is admissible. -/
theorem Admissible.take {l : List Bool} (h : Admissible l) (n : ℕ) : Admissible (l.take n) :=
  List.IsChain.take h n

/-- Any suffix of an admissible word is admissible. -/
theorem Admissible.drop {l : List Bool} (h : Admissible l) (n : ℕ) : Admissible (l.drop n) :=
  List.IsChain.drop h n

/-! ## The two Fekete inequalities, proved by explicit injections -/

/-- **Supermultiplicativity of the golden-mean language.**  Gluing an admissible word of length
`n` to an admissible word of length `m` through a single buffer letter `false` is an injection
`L n × L m ↪ L (n + m + 1)`. -/
theorem card_goldenWords_mul_le (n m : ℕ) :
    (goldenWords n).card * (goldenWords m).card ≤ (goldenWords (n + m + 1)).card := by
  classical
  rw [← Finset.card_product]
  refine Finset.card_le_card_of_injOn (fun p => p.1 ++ false :: p.2) ?_ ?_
  · rintro ⟨v, w⟩ hp
    rw [Finset.mem_coe, Finset.mem_product] at hp
    obtain ⟨hv, hw⟩ := hp
    rw [mem_goldenWords] at hv hw
    rw [Finset.mem_coe, mem_goldenWords]
    refine ⟨?_, admissible_glue hv.2 hw.2⟩
    rw [List.length_append, List.length_cons, hv.1, hw.1]
    omega
  · rintro ⟨v, w⟩ hp ⟨v', w'⟩ hp' heq
    simp only [Finset.coe_product, Set.mem_prod, Finset.mem_coe, mem_goldenWords] at hp hp'
    have hlen : v.length = v'.length := by rw [hp.1.1, hp'.1.1]
    obtain ⟨h1, h2⟩ := List.append_inj heq hlen
    simp only [Prod.mk.injEq]
    exact ⟨h1, (List.cons_eq_cons.mp h2).2⟩

/-- **Submultiplicativity of the golden-mean language.**  Cutting an admissible word of length
`n + m` at position `n` is an injection `L (n + m) ↪ L n × L m`. -/
theorem card_goldenWords_add_le (n m : ℕ) :
    (goldenWords (n + m)).card ≤ (goldenWords n).card * (goldenWords m).card := by
  classical
  rw [← Finset.card_product]
  refine Finset.card_le_card_of_injOn (fun l => (l.take n, l.drop n)) ?_ ?_
  · intro l hl
    rw [Finset.mem_coe, mem_goldenWords] at hl
    rw [Finset.mem_coe, Finset.mem_product, mem_goldenWords, mem_goldenWords]
    refine ⟨⟨?_, hl.2.take n⟩, ⟨?_, hl.2.drop n⟩⟩
    · rw [List.length_take, hl.1]; omega
    · rw [List.length_drop, hl.1]; omega
  · intro a _ b _ heq
    have h1 : a.take n = b.take n := congrArg Prod.fst heq
    have h2 : a.drop n = b.drop n := congrArg Prod.snd heq
    rw [← List.take_append_drop n a, ← List.take_append_drop n b, h1, h2]

/-! ## Fibonacci inequalities obtained from word combinatorics -/

/-- Combinatorial proof of a two-variable Fibonacci inequality: it is exactly the statement
that admissible words glue. -/
theorem fib_mul_fib_le_fib (n m : ℕ) :
    Nat.fib (n + 2) * Nat.fib (m + 2) ≤ Nat.fib (n + m + 3) := by
  have h := card_goldenWords_mul_le n m
  rw [card_goldenWords, card_goldenWords, card_goldenWords] at h
  have he : n + m + 1 + 2 = n + m + 3 := by omega
  rwa [he] at h

/-- Combinatorial proof of the reverse two-variable Fibonacci inequality: it is exactly the
statement that admissible words can be cut. -/
theorem fib_le_fib_mul_fib (n m : ℕ) :
    Nat.fib (n + m + 2) ≤ Nat.fib (n + 2) * Nat.fib (m + 2) := by
  have h := card_goldenWords_add_le n m
  rw [card_goldenWords, card_goldenWords, card_goldenWords] at h
  exact h

/-! ## Exponential sparseness and the entropy gap -/

/-- `fib (n + 4) < 2 ^ (n + 2)`: the Fibonacci numbers fall strictly behind the powers of two
from index `4` on. -/
theorem fib_lt_two_pow : ∀ n : ℕ, Nat.fib (n + 4) < 2 ^ (n + 2)
  | 0 => by decide
  | 1 => by decide
  | (n + 2) => by
      have h1 := fib_lt_two_pow (n + 1)
      have h2 := fib_lt_two_pow n
      have hfib : Nat.fib (n + 2 + 4) = Nat.fib (n + 4) + Nat.fib (n + 5) := by
        have := Nat.fib_add_two (n := n + 4)
        simpa [Nat.add_assoc] using this
      have e1 : (2 : ℕ) ^ (n + 1 + 2) = 2 * 2 ^ (n + 2) := by ring
      have e2 : (2 : ℕ) ^ (n + 2 + 2) = 4 * 2 ^ (n + 2) := by ring
      have h1' : Nat.fib (n + 5) < 2 * 2 ^ (n + 2) := by
        have : n + 1 + 4 = n + 5 := by omega
        rw [← e1, ← this]; exact h1
      omega

/-- **Exponential sparseness.**  There are strictly fewer admissible words of length `n + 2`
than binary words of that length, so the subshift is a proper closed subset with positive
information deficiency at every scale. -/
theorem card_goldenWords_lt_two_pow (n : ℕ) :
    (goldenWords (n + 2)).card < 2 ^ (n + 2) := by
  rw [card_goldenWords]
  have h := fib_lt_two_pow n
  have he : n + 2 + 2 = n + 4 := by omega
  rwa [he]

/-- **Strict entropy gap.**  The exponential growth rate `log φ` of the golden-mean language is
strictly smaller than the growth rate `log 2` of the full shift. -/
theorem goldenMean_entropy_lt_log_two : Real.log Real.goldenRatio < Real.log 2 :=
  Real.log_lt_log Real.goldenRatio_pos Real.goldenRatio_lt_two

/-- Fekete's upper bound in explicit form: every finite stage already witnesses the entropy
from below, `log (#L n) / (n + 1) ≤ log φ`. -/
theorem log_card_goldenWords_div_le (n : ℕ) :
    Real.log ((goldenWords n).card) / ((n : ℝ) + 1) ≤ Real.log Real.goldenRatio := by
  have hpos : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  rw [div_le_iff₀ hpos]
  have h := log_coveringNumber_upper n
  rw [coveringNumber] at h
  linarith [h]

/-! ## Density of `true`s: a sharp capacity bound -/

/-- **Density bound.**  An admissible word of length `n` carries at most `(n + 1) / 2` letters
`true`: forbidding `11` halves the achievable density. -/
theorem admissible_count_true : ∀ {l : List Bool}, Admissible l →
    2 * l.count true ≤ l.length + 1
  | [], _ => by simp
  | [a], _ => by cases a <;> simp
  | a :: b :: t, h => by
      have h' := List.isChain_cons_cons.mp h
      cases a with
      | false =>
          have ih := admissible_count_true h'.2
          simp at ih ⊢
          omega
      | true =>
          have hb : b = false := by
            cases b with
            | false => rfl
            | true => exact absurd ⟨rfl, rfl⟩ h'.1
          subst hb
          have ih := admissible_count_true (List.IsChain.tail h'.2)
          simp at ih ⊢
          omega

/-- The alternating word `1010…1` of odd length `2n + 1`. -/
def altWord : ℕ → List Bool
  | 0 => [true]
  | (n + 1) => true :: false :: altWord n

theorem admissible_altWord : ∀ n : ℕ, Admissible (altWord n)
  | 0 => admissible_singleton true
  | (n + 1) => admissible_true_false_cons (admissible_altWord n)

theorem length_altWord : ∀ n : ℕ, (altWord n).length = 2 * n + 1
  | 0 => rfl
  | (n + 1) => by
      simp only [altWord, List.length_cons, length_altWord n]
      omega

theorem count_altWord : ∀ n : ℕ, (altWord n).count true = n + 1
  | 0 => rfl
  | (n + 1) => by
      simp only [altWord, List.count_cons, count_altWord n]
      simp

/-- **The density bound is sharp**: the alternating word attains equality at every odd
length. -/
theorem admissible_count_true_sharp (n : ℕ) :
    2 * (altWord n).count true = (altWord n).length + 1 := by
  rw [count_altWord, length_altWord]
  omega

/-- The density bound transported to the subshift: in any window of length `n` of any
golden-mean stream, at most `(n + 1) / 2` answers are `true`. -/
theorem goldenMean_prefix_count_true {x : Cantor} (hx : x ∈ GoldenMean) (n : ℕ) :
    2 * (prefixOf n x).count true ≤ n + 1 := by
  have hadm : Admissible (prefixOf n x) :=
    ((mem_goldenWords n _).mp (prefixOf_mem_goldenWords n hx)).2
  have h := admissible_count_true hadm
  rwa [length_prefixOf] at h

/-- **Capacity summary for the golden-mean subshift.**  The language is simultaneously
super- and submultiplicative, exponentially sparse, and of bounded `true`-density; the three
facts are the combinatorial, information-theoretic and dynamical faces of the single
constraint "no `11`". -/
theorem goldenMean_capacity_summary :
    (∀ n m : ℕ, (goldenWords n).card * (goldenWords m).card ≤ (goldenWords (n + m + 1)).card) ∧
    (∀ n m : ℕ, (goldenWords (n + m)).card ≤ (goldenWords n).card * (goldenWords m).card) ∧
    (∀ n : ℕ, (goldenWords (n + 2)).card < 2 ^ (n + 2)) ∧
    (∀ l : List Bool, Admissible l → 2 * l.count true ≤ l.length + 1) :=
  ⟨card_goldenWords_mul_le, card_goldenWords_add_le, card_goldenWords_lt_two_pow,
    fun _ h => admissible_count_true h⟩

end FractalTruthCompactness