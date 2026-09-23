/-
# CONVERSE-COST-CURVE, part VI: every local gcd-statistic on the plane (cycle 3)

Part I computed the W1 witness `M₁ = ∑_{x<N} gcd(x, N)`.  Cycle 3 asks whether
a *different* summand could produce a cheaper or richer witness.  The answer is
a single closed form covering the whole class at once:

* `ConverseCost.gcdStat` — the general local gcd-statistic
  `S_f(N) = ∑_{x<N} f(gcd(x, N))`.
* `ConverseCost.gcdStat_semiprime` — for a semiprime,
  `S_f(pq) = f(pq) + (q-1) f(p) + (p-1) f(q) + (p-1)(q-1) f(1)`.
  Every member of the class is a *symmetric* function of `{p, q}` supported on
  the four-element divisor lattice: no choice of `f` can see anything else.
* `ConverseCost.gcdStat_const` — the class contains information-free members
  (`f ≡ 1` returns `N`), exactly like the W4 counter of part III.
* `ConverseCost.gcdStat_id_recovers_sum` — and it contains the W1 member, for
  which `s = p + q` is recovered by an `O(1)` arithmetic formula from `(N, S_f)`.

**Critic's note (recorded honestly).**  "Witness together with `N` determines
`{p, q}`" is by itself weak: unique factorisation already determines the pair
from `N`.  The content of the reach chain is *constructive*: the recovery of
`s` from `(N, M₁)` is an explicit affine formula (`sum_from_pillai`), and the
rigidity step `(N, s) ↦ {p, q}` is the symmetric-function argument
(`sum_rigidity`).  The theorems below are stated so that this constructive
content, not the trivial uniqueness, is what is being proved.
-/
import Mathlib
import Combinatorics.ConverseCostWitnessFamily

namespace ConverseCost

open Finset

/-- A local gcd-statistic: `S_f(N) = ∑_{x < N} f (gcd (x, N))`.  The W1 witness
is `f = id`; the "count the non-units" witness is `f = if · = 1 then 0 else 1`. -/
def gcdStat (f : ℕ → ℕ) (N : ℕ) : ℕ := ∑ x ∈ Finset.range N, f (Nat.gcd x N)

theorem gcdStat_id (N : ℕ) : gcdStat id N = pillai N := rfl

/-- Cardinality of the four cells of the gcd-partition of `range (p*q)`. -/
theorem card_cell_both {p q : ℕ} (hpq : Nat.Coprime p q) (hp : 0 < p) (hq : 0 < q) :
    (((Finset.range (p * q)).filter (fun x => p ∣ x)).filter (fun x => q ∣ x)).card = 1 := by
  rw [Finset.filter_filter]
  exact card_common_multiples hpq hp hq

theorem card_cell_p {p q : ℕ} (hpq : Nat.Coprime p q) (hp : 0 < p) (hq : 0 < q) :
    (((Finset.range (p * q)).filter (fun x => p ∣ x)).filter (fun x => ¬ q ∣ x)).card
      = q - 1 := by
  classical
  have htot := Finset.card_filter_add_card_filter_not
    (s := (Finset.range (p * q)).filter (fun x => p ∣ x)) (p := fun x => q ∣ x)
  rw [card_cell_both hpq hp hq, card_multiples_lt hp] at htot
  omega

theorem card_cell_q {p q : ℕ} (hpq : Nat.Coprime p q) (hp : 0 < p) (hq : 0 < q) :
    (((Finset.range (p * q)).filter (fun x => ¬ p ∣ x)).filter (fun x => q ∣ x)).card
      = p - 1 := by
  classical
  have hcomm : p * q = q * p := Nat.mul_comm _ _
  have hswap : ((Finset.range (p * q)).filter (fun x => ¬ p ∣ x)).filter (fun x => q ∣ x)
      = ((Finset.range (p * q)).filter (fun x => q ∣ x)).filter (fun x => ¬ p ∣ x) := by
    rw [Finset.filter_filter, Finset.filter_filter]
    exact Finset.filter_congr (fun x _ => by tauto)
  rw [hswap, hcomm]
  exact card_cell_p hpq.symm hq hp

theorem card_cell_none {p q : ℕ} (hpq : Nat.Coprime p q) (hp : 0 < p) (hq : 0 < q) :
    (((Finset.range (p * q)).filter (fun x => ¬ p ∣ x)).filter (fun x => ¬ q ∣ x)).card
      = (p - 1) * (q - 1) := by
  classical
  have htot := Finset.card_filter_add_card_filter_not
    (s := (Finset.range (p * q)).filter (fun x => ¬ p ∣ x)) (p := fun x => q ∣ x)
  have hcompl := Finset.card_filter_add_card_filter_not
    (s := Finset.range (p * q)) (p := fun x => p ∣ x)
  rw [card_multiples_lt hp, Finset.card_range] at hcompl
  rw [card_cell_q hpq hp hq] at htot
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 1 := ⟨q - 1, by omega⟩
  have hexp : (a + 1) * (b + 1) = a * b + a + b + 1 := by ring
  simp only [Nat.add_sub_cancel]
  omega

/-- **The class-wide closed form.**  Every local gcd-statistic of a semiprime is
determined by the values of `f` on the four divisors, weighted by the sizes of
the four gcd-cells.  In particular every such witness is a symmetric function of
`{p, q}`: no summand `f` can extract anything finer than the unordered pair. -/
theorem gcdStat_semiprime (f : ℕ → ℕ) {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hne : p ≠ q) :
    gcdStat f (p * q)
      = f (p * q) + (q - 1) * f p + ((p - 1) * f q + (p - 1) * (q - 1) * f 1) := by
  classical
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  have hgcd : ∀ x, Nat.gcd x (p * q)
      = (if p ∣ x then p else 1) * (if q ∣ x then q else 1) := by
    intro x
    rw [Nat.Coprime.gcd_mul x hpq, gcd_prime_eq_ite hp, gcd_prime_eq_ite hq]
  -- split `range (p*q)` by divisibility by `p`, then by `q`
  rw [gcdStat, ← Finset.sum_filter_add_sum_filter_not (Finset.range (p * q))
    (fun x => p ∣ x)]
  rw [← Finset.sum_filter_add_sum_filter_not
    ((Finset.range (p * q)).filter (fun x => p ∣ x)) (fun x => q ∣ x)]
  rw [← Finset.sum_filter_add_sum_filter_not
    ((Finset.range (p * q)).filter (fun x => ¬ p ∣ x)) (fun x => q ∣ x)]
  have e1 : ∑ x ∈ ((Finset.range (p * q)).filter (fun x => p ∣ x)).filter (fun x => q ∣ x),
      f (Nat.gcd x (p * q)) = f (p * q) := by
    rw [Finset.sum_congr rfl (fun x hx => ?_), Finset.sum_const,
      card_cell_both hpq hp0 hq0, smul_eq_mul, Nat.one_mul]
    simp only [Finset.mem_filter] at hx
    rw [hgcd x, if_pos hx.1.2, if_pos hx.2]
  have e2 : ∑ x ∈ ((Finset.range (p * q)).filter (fun x => p ∣ x)).filter (fun x => ¬ q ∣ x),
      f (Nat.gcd x (p * q)) = (q - 1) * f p := by
    rw [Finset.sum_congr rfl (fun x hx => ?_), Finset.sum_const,
      card_cell_p hpq hp0 hq0, smul_eq_mul]
    simp only [Finset.mem_filter] at hx
    rw [hgcd x, if_pos hx.1.2, if_neg hx.2, Nat.mul_one]
  have e3 : ∑ x ∈ ((Finset.range (p * q)).filter (fun x => ¬ p ∣ x)).filter (fun x => q ∣ x),
      f (Nat.gcd x (p * q)) = (p - 1) * f q := by
    rw [Finset.sum_congr rfl (fun x hx => ?_), Finset.sum_const,
      card_cell_q hpq hp0 hq0, smul_eq_mul]
    simp only [Finset.mem_filter] at hx
    rw [hgcd x, if_neg hx.1.2, if_pos hx.2, Nat.one_mul]
  have e4 : ∑ x ∈ ((Finset.range (p * q)).filter (fun x => ¬ p ∣ x)).filter (fun x => ¬ q ∣ x),
      f (Nat.gcd x (p * q)) = (p - 1) * (q - 1) * f 1 := by
    rw [Finset.sum_congr rfl (fun x hx => ?_), Finset.sum_const,
      card_cell_none hpq hp0 hq0, smul_eq_mul]
    simp only [Finset.mem_filter] at hx
    rw [hgcd x, if_neg hx.1.2, if_neg hx.2, Nat.one_mul]
  rw [e1, e2, e3, e4, Nat.add_assoc]

/-- **Information-free members exist.**  The constant summand returns the
modulus itself: a `Θ(N)` scan whose output is `N`, which the algorithm already
had.  This is the W4 phenomenon (a constant counter) inside the sum class. -/
theorem gcdStat_const {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    gcdStat (fun _ => 1) (p * q) = p * q := by
  have hp0 : 0 < p := hp.pos
  have hq0 : 0 < q := hq.pos
  rw [gcdStat_semiprime _ hp hq hne]
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 1 := ⟨q - 1, by omega⟩
  simp only [Nat.add_sub_cancel, Nat.mul_one]
  ring

/-- **The informative member.**  For `f = id` the closed form is the W1 formula,
and `s = p + q` is recovered from `(N, S_f)` by one subtraction and one halving:
the reach chain is *constructive*, not merely an existence statement. -/
theorem gcdStat_id_recovers_sum {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    gcdStat id (p * q) + 2 * (p + q) = 4 * (p * q) + 1 ∧
      p + q = (4 * (p * q) + 1 - gcdStat id (p * q)) / 2 := by
  have h : gcdStat id (p * q) = pillai (p * q) := gcdStat_id _
  rw [h]
  exact ⟨pillai_semiprime hp hq hne, sum_from_pillai hp hq hne⟩

/-- **Bridge to Euler's totient.**  The W1 witness and `φ` are affinely
equivalent on semiprimes: `M₁(N) + 1 = 2 φ(N) + 2 N`.  Reading `M₁` is therefore
exactly as informative — and, by the classical equivalence between computing
`φ(N)` and factoring a semiprime, exactly as hard — as reading `φ`. -/
theorem pillai_eq_two_totient {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q) :
    pillai (p * q) + 1 = 2 * Nat.totient (p * q) + 2 * (p * q) := by
  have hpq : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  have htot : Nat.totient (p * q) = (p - 1) * (q - 1) := by
    rw [Nat.totient_mul hpq, Nat.totient_prime hp, Nat.totient_prime hq]
  have hmain := pillai_semiprime hp hq hne
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  obtain ⟨a, rfl⟩ : ∃ a, p = a + 1 := ⟨p - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, q = b + 1 := ⟨q - 1, by omega⟩
  simp only [Nat.add_sub_cancel] at htot
  have hexp : (a + 1) * (b + 1) = a * b + a + b + 1 := by ring
  omega

/-! ## Lab notes -/

-- `N = 35 = 5·7`: `∑ gcd² = 35² + 25·6 + 49·4 + 24 = 1595`, checked by evaluation.
set_option maxRecDepth 40000 in
example : gcdStat (fun d => d * d) 35 = 1595 := by decide

-- the information-free member on `N = 143`, via the closed form
example : gcdStat (fun _ => 1) (11 * 13) = 11 * 13 :=
  gcdStat_const (by norm_num) (by norm_num) (by norm_num : (11 : ℕ) ≠ 13)

end ConverseCost