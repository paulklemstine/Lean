/-
# TRACEPROFILE IV — what the visible bit *is*, and why it is an arity-2 phenomenon

Phase A research file (Novelty domain), Paper 50 / Experiment 385, second research
cycle.

Cycle I (`Novelty.TraceProfileTraceSet`) proved that the trace `s = p + q` of a
semiprime is pinned modulo an odd prime `q` to a set of size `(q + χ_q(N))/2` — one
bit per prime.  This file answers the two questions that cycle raised.

**Q1.  Which bit is it?**  `two_mul_card_traceSet_eq_add_legendreSym`: the deviation
of the trace-set size from `q/2` is *exactly* the Legendre symbol `χ_q(N)`.  So the
"one visible bit per prime" is the quadratic character of the public modulus — a
quantity computable from `N` alone in polynomial time (quadratic reciprocity).  It
is therefore public data, not a leak about `(p, q)`; this is the information-level
form of the paper's verdict "the trace is the least hidden invariant, but its
visible bits never isolate `p` or `q`".

**Q2.  Is the constraint special to two factors?**  Yes.  For three factors the
sum set `{x + y + z : x y z = N}` is *everything* already at `q = 11`
(`tripleSumSet_full_eleven`), while the two-factor trace set is always a proper
subset (`traceSet_ne_univ`).  Small primes `q ≤ 7` are exceptional
(`tripleSumSet_not_full_five`).  The trace constraint is an arity-2 phenomenon: it
is the quadratic discriminant, and nothing else.

## Main results

* `mem_traceSet_iff_isSquare_discrim` — the structural description of the trace set:
  `s` is a possible trace iff the discriminant `s² - 4N` is a square.
* `two_mul_card_traceSet_eq_add_legendreSym` — `2|S_q(N)| = q + χ_q(N)`.
* `card_traceSet_eq_of_legendreSym_eq` — the trace-set size sees `N` only through
  `χ_q(N)`: the whole visible bit is the (public) quadratic character.
* `odd_list_sum_prod_mod_four` — **the `k`-factor low-bit law**: for any list of odd
  numbers, `e₁ + 1 ≡ N + k (mod 4)` where `N` is the product and `k` the length.
  For `k = 2` this is the exact `s₁ = 1 - N₁` theorem of `TraceProfileLowBits`.
* `card_traceSet_le_card_tripleSumSet` — arity monotonicity.
* `tripleSumSet_full_eleven`, `tripleSumSet_not_full_five`, `traceSet_ne_univ` — the
  arity-2/arity-3 dichotomy, with the small-prime exceptions.
* `traceSet_injective_thirteen` — the trace set determines `N` (finite verification).
-/

import Mathlib
import Novelty.TraceProfileTraceSet

namespace Novelty.TraceProfile

open Finset

/-! ## The structural description: the trace set is a discriminant condition -/

section Prime

variable {q : ℕ} [hq : Fact (Nat.Prime q)]

/-- **`s` is a possible trace iff the discriminant `s² - 4N` is a square.**
This is the source of every quantitative statement about the trace: the trace is
constrained by *one quadratic condition*, hence by exactly one bit. -/
theorem mem_traceSet_iff_isSquare_discrim (hq2 : q ≠ 2) (N s : ZMod q) :
    s ∈ traceSet N ↔ IsSquare (s ^ 2 - 4 * N) := by
  have h2 : (2 : ZMod q) ≠ 0 := two_ne_zero_zmod hq2
  rw [mem_traceSet]
  constructor
  · rintro ⟨x, y, hxy, rfl⟩
    exact ⟨x - y, by rw [← hxy]; ring⟩
  · rintro ⟨t, ht⟩
    refine ⟨(s + t) * (2 : ZMod q)⁻¹, (s - t) * (2 : ZMod q)⁻¹, ?_, ?_⟩
    · field_simp
      linear_combination ht
    · field_simp
      ring

/-- **The visible bit is the Legendre symbol.**  The deviation of the trace-set size
from half the modulus is exactly `χ_q(N)`.  Since `χ_q(N)` is computable from `N`
alone (quadratic reciprocity), the single bit the trace reveals modulo `q` is public
data and gives no access to `p` or `q`. -/
theorem two_mul_card_traceSet_eq_add_legendreSym (hq2 : q ≠ 2) (a : ℤ)
    (ha : ((a : ZMod q)) ≠ 0) :
    (2 * (traceSet ((a : ZMod q))).card : ℤ) = q + legendreSym q a := by
  have hcard := card_traceSet_prime hq2 ((a : ZMod q)) ha
  have hq3 : 3 ≤ q := by
    have h2 := hq.out.two_le
    omega
  by_cases hs : IsSquare ((a : ZMod q))
  · rw [if_pos hs] at hcard
    rw [(legendreSym.eq_one_iff q ha).2 hs]
    exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) hcard
  · rw [if_neg hs] at hcard
    rw [(legendreSym.eq_neg_one_iff q).2 hs]
    have hq1 : (1 : ℕ) ≤ q := by omega
    have hcast : ((q - 1 : ℕ) : ℤ) = (q : ℤ) - 1 := by
      rw [Nat.cast_sub hq1]; norm_num
    calc (2 * (traceSet ((a : ZMod q))).card : ℤ)
        = ((q - 1 : ℕ) : ℤ) := by exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) hcard
      _ = (q : ℤ) + -1 := by rw [hcast]; ring

/-- The trace-set size depends on `N` only through the quadratic character: two
moduli with the same Legendre symbol are indistinguishable by the trace constraint.
This is the exact sense in which the visible bit carries no further information. -/
theorem card_traceSet_eq_of_legendreSym_eq (hq2 : q ≠ 2) (a b : ℤ)
    (ha : ((a : ZMod q)) ≠ 0) (hb : ((b : ZMod q)) ≠ 0)
    (h : legendreSym q a = legendreSym q b) :
    (traceSet ((a : ZMod q))).card = (traceSet ((b : ZMod q))).card := by
  have ha' := two_mul_card_traceSet_eq_add_legendreSym hq2 a ha
  have hb' := two_mul_card_traceSet_eq_add_legendreSym hq2 b hb
  rw [h] at ha'
  have : (2 * (traceSet ((a : ZMod q))).card : ℤ) = (2 * (traceSet ((b : ZMod q))).card : ℤ) := by
    rw [ha', hb']
  exact_mod_cast Int.eq_of_mul_eq_mul_left (by norm_num) this

/-- The trace set is never everything (for odd `q` and invertible `N`). -/
theorem traceSet_ne_univ (hq2 : q ≠ 2) (N : ZMod q) (hN : N ≠ 0) :
    traceSet N ≠ univ := by
  intro h
  have hlt := card_traceSet_lt_prime hq2 N hN
  rw [h, Finset.card_univ, ZMod.card] at hlt
  exact lt_irrefl _ hlt

end Prime

/-! ## The `k`-factor low-bit law -/

/-- A product of odd numbers is odd. -/
theorem odd_list_prod : ∀ (L : List ℕ), (∀ a ∈ L, Odd a) → Odd L.prod := by
  intro L
  induction L with
  | nil => intro _; simp
  | cons a t ih =>
      intro h
      rw [List.prod_cons]
      exact (h a (by simp)).mul (ih (fun b hb => h b (by simp [hb])))

/-- **The `k`-factor low-bit law.**  For any list `L` of odd numbers, with product
`N = ∏ L`, first symmetric function `e₁ = ∑ L` and length `k`,
`e₁ + 1 ≡ N + k (mod 4)`.
For `k = 2` this is the exact semiprime relation `s₁ = 1 - N₁`; the law shows that
the exactly-visible low bit of the first symmetric function is a function of `N` and
the *number* of factors alone. -/
theorem odd_list_sum_prod_mod_four : ∀ (L : List ℕ), (∀ a ∈ L, Odd a) →
    (L.sum + 1) % 4 = (L.prod + L.length) % 4 := by
  intro L
  induction L with
  | nil => intro _; simp
  | cons a t ih =>
      intro h
      have ha : Odd a := h a (by simp)
      have ht : ∀ b ∈ t, Odd b := fun b hb => h b (by simp [hb])
      have hP : Odd t.prod := odd_list_prod t ht
      obtain ⟨x, hx⟩ := ha
      obtain ⟨y, hy⟩ := hP
      have hih := ih ht
      have hmul : a * t.prod = 4 * (x * y) + 2 * x + 2 * y + 1 := by
        rw [hx, hy]; ring
      rw [List.sum_cons, List.prod_cons, List.length_cons, hmul, hx, hy] at *
      omega

/-- The `k = 2` specialisation: the semiprime low-bit law, recovered from the list
form. -/
theorem odd_pair_sum_prod_mod_four {p r : ℕ} (hp : Odd p) (hr : Odd r) :
    (p + r + 1) % 4 = (p * r + 2) % 4 := by
  have h := odd_list_sum_prod_mod_four [p, r] (by
    intro a ha
    simp only [List.mem_cons, List.not_mem_nil, or_false] at ha
    rcases ha with rfl | rfl
    · exact hp
    · exact hr)
  simpa [List.sum_cons, List.prod_cons] using h

/-! ## Arity: the constraint is a two-factor phenomenon -/

variable {R : Type*} [CommRing R] [Fintype R] [DecidableEq R]

/-- The sum set of the *three*-factor factorisations of `N`. -/
def tripleSumSet (N : R) : Finset R :=
  ((univ : Finset (R × R × R)).filter (fun z => z.1 * z.2.1 * z.2.2 = N)).image
    (fun z => z.1 + z.2.1 + z.2.2)

@[simp] theorem mem_tripleSumSet {N s : R} :
    s ∈ tripleSumSet N ↔ ∃ x y z : R, x * y * z = N ∧ x + y + z = s := by
  simp [tripleSumSet, Prod.exists]

/-- Arity monotonicity: every trace, shifted by `1`, is a three-factor sum, so the
three-factor sum set is at least as large as the trace set. -/
theorem card_traceSet_le_card_tripleSumSet (N : R) :
    (traceSet N).card ≤ (tripleSumSet N).card := by
  classical
  have hsub : (traceSet N).image (fun s => s + 1) ⊆ tripleSumSet N := by
    intro t ht
    simp only [mem_image, mem_traceSet] at ht
    obtain ⟨s, ⟨x, y, hxy, rfl⟩, rfl⟩ := ht
    exact mem_tripleSumSet.2 ⟨x, y, 1, by rw [mul_one]; exact hxy, rfl⟩
  calc (traceSet N).card
      = ((traceSet N).image (fun s => s + 1)).card :=
        (Finset.card_image_of_injective _ (add_left_injective 1)).symm
    _ ≤ (tripleSumSet N).card := Finset.card_le_card hsub

set_option maxRecDepth 40000 in
/-- **The arity-3 collapse.**  Modulo `11` every residue is the sum of a
three-factor factorisation of every invertible `N`: the three-factor sum carries
*zero* bits, in contrast to the one bit of the two-factor trace. -/
theorem tripleSumSet_full_eleven : ∀ N : ZMod 11, N ≠ 0 → tripleSumSet N = univ := by
  decide

/-- **Small primes are exceptional.**  At `q = 5` the three-factor sum set still
misses one residue (for `N = 1` it misses `2`), so the collapse has a threshold —
the arity-3 analogue of the trace constraint survives only below `q = 11`. -/
theorem tripleSumSet_not_full_five : tripleSumSet (1 : ZMod 5) ≠ univ := by
  decide

set_option maxRecDepth 100000 in
/-- **The trace set is a complete invariant of `N` (verified at `q = 13`).**  Distinct
invertible moduli have distinct trace sets: the one visible bit is a bit *about the
character*, but the whole set `S_q(N)` still remembers `N` exactly.  (Conjecturally
true for every odd prime; see `FUTURE_DIRECTIONS.md`.) -/
theorem traceSet_injective_thirteen :
    ∀ N N' : ZMod 13, N ≠ 0 → N' ≠ 0 → traceSet N = traceSet N' → N = N' := by
  decide

/-- **The dichotomy at `q = 11`.**  The two-factor trace set is a proper subset while
the three-factor sum set is everything: the congruence visibility of the trace is a
strictly arity-2 phenomenon. -/
theorem arity_dichotomy_eleven (N : ZMod 11) (hN : N ≠ 0) :
    traceSet N ≠ univ ∧ tripleSumSet N = univ := by
  haveI : Fact (Nat.Prime 11) := ⟨by norm_num⟩
  exact ⟨traceSet_ne_univ (by norm_num) N hN, tripleSumSet_full_eleven N hN⟩

end Novelty.TraceProfile