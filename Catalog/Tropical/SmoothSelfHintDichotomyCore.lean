import Mathlib

/-!
# The asymmetric / symmetric divisibility dichotomy

Motivation (Paper 54, Experiment 389).  For a semiprime `N = p * q` and a small prime
`l`, one asks whether `N` "knows" something about the divisibility of `p - 1` by `l`
(the elementary building block of `p - 1`/ECM smoothness).  The experiment reports

* `I(N mod l ; l ∣ p-1) = 0` (asymmetric event: zero leak),
* `I(N mod l ; l ∣ p-1 ∨ l ∣ q-1) > 0` (symmetric event: strong leak, `0.313` bits at
  `l = 3`), with an exact mechanism at `l = 3`: `N ≡ 2 (mod 3)` *forces* one factor to
  be `≡ 1 (mod 3)`.

This file proves the structural reason, in complete generality, as a statement about
fibres of the multiplication map of a finite group `G` (for us `G = (ZMod l)ˣ`):

* `SmoothSelfHint.asym_fiber_card` : for **any** `A ⊆ G` and **any** `n`, the number of
  pairs `(a,b)` with `a * b = n` and `a ∈ A` equals `|A|` — independent of `n`.
  One–sided ("asymmetric") events are *exactly* independent of the product.
* `SmoothSelfHint.sym_fiber_card` : the two–sided ("symmetric") count is
  `|A ∪ n·A⁻¹|`, which genuinely depends on `n`.
* `SmoothSelfHint.sym_fiber_card_one` : for the singleton `A = {1}` the symmetric count
  is `1` if `n = 1` and `2` otherwise — the whole leak, in one line.
* `SmoothSelfHint.asym_condProb_constant` / `SmoothSelfHint.sym_condProb_not_constant`:
  the resulting conditional probabilities, `1/(l-1)` versus `(1 or 2)/(l-1)`.

The arithmetic half of the file turns this into statements about actual semiprimes:

* `SmoothSelfHint.symmetric_forced_mod_three` : the exact `l = 3` mechanism.
* `SmoothSelfHint.asym_not_residue_dial` : no function of `N mod 3` computes `3 ∣ p-1`,
  and indeed *both* residue classes carry both outcomes.
* `SmoothSelfHint.sym_not_forced_mod_five` : at `l = 5` even the symmetric event is not
  forced — the leak there is purely statistical (`0.036` bits), as measured.
-/

open Finset

namespace SmoothSelfHint

/-! ## Part 1 : fibres of multiplication in a finite group -/

section Group

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- The fibre of the multiplication map over `n`, intersected with a one–sided
("asymmetric") condition on the first coordinate. -/
def asymFiber (A : Finset G) (n : G) : Finset (G × G) :=
  (Finset.univ : Finset (G × G)).filter (fun ab => ab.1 * ab.2 = n ∧ ab.1 ∈ A)

/-- The fibre of the multiplication map over `n`, intersected with the two–sided
("symmetric") condition that *some* coordinate lies in `A`. -/
def symFiber (A : Finset G) (n : G) : Finset (G × G) :=
  (Finset.univ : Finset (G × G)).filter
    (fun ab => ab.1 * ab.2 = n ∧ (ab.1 ∈ A ∨ ab.2 ∈ A))

/-- **Asymmetric invisibility.**  The number of factorisations `n = a * b` with the
first factor in `A` is `|A|`, whatever `n` is.  Equivalently: the event `a ∈ A` is
statistically independent of the product `a * b`. -/
theorem asym_fiber_card (A : Finset G) (n : G) : (asymFiber A n).card = A.card := by
  apply Finset.card_bij (fun ab _ => ab.1)
  · intro ab hab
    simp only [asymFiber, Finset.mem_filter] at hab
    exact hab.2.2
  · intro a ha b hb hab
    simp only [asymFiber, Finset.mem_filter] at ha hb
    have h : a.1 * a.2 = b.1 * b.2 := by rw [ha.2.1, hb.2.1]
    rw [hab] at h
    exact Prod.ext hab (mul_left_cancel h)
  · intro a ha
    refine ⟨(a, a⁻¹ * n), ?_, rfl⟩
    simp [asymFiber, ha]

/-- The total number of factorisations of `n` is `|G|`. -/
theorem fiber_card (n : G) :
    ((Finset.univ : Finset (G × G)).filter (fun ab => ab.1 * ab.2 = n)).card
      = Fintype.card G := by
  have h := asym_fiber_card (Finset.univ : Finset G) n
  simpa [asymFiber, Finset.card_univ] using h

/-- **Symmetric visibility, exact count.**  The number of factorisations `n = a * b`
with *some* factor in `A` is `|A ∪ n·A⁻¹|`, an honest function of `n`. -/
theorem sym_fiber_card (A : Finset G) (n : G) :
    (symFiber A n).card = (A ∪ A.image (fun b => n * b⁻¹)).card := by
  apply Finset.card_bij (fun ab _ => ab.1)
  · intro ab hab
    simp only [symFiber, Finset.mem_filter, Finset.mem_union, Finset.mem_image] at hab ⊢
    rcases hab.2.2 with h | h
    · exact Or.inl h
    · refine Or.inr ⟨ab.2, h, ?_⟩
      rw [← hab.2.1]; group
  · intro a ha b hb hab
    simp only [symFiber, Finset.mem_filter] at ha hb
    have h : a.1 * a.2 = b.1 * b.2 := by rw [ha.2.1, hb.2.1]
    rw [hab] at h
    exact Prod.ext hab (mul_left_cancel h)
  · intro a ha
    simp only [Finset.mem_union, Finset.mem_image] at ha
    refine ⟨(a, a⁻¹ * n), ?_, rfl⟩
    simp only [symFiber, Finset.mem_filter, Finset.mem_univ, true_and]
    refine ⟨by group, ?_⟩
    rcases ha with h | ⟨b, hb, hba⟩
    · exact Or.inl h
    · right
      have hab : a⁻¹ * n = b := by rw [← hba]; group
      rw [hab]; exact hb

/-- Inclusion–exclusion form of the symmetric count: `2|A| - |A ∩ n·A⁻¹|`.  The
correction term is an autocorrelation of `A`, and it is what makes the count vary. -/
theorem sym_fiber_card_incl_excl (A : Finset G) (n : G) :
    (symFiber A n).card
      = 2 * A.card - (A ∩ A.image (fun b => n * b⁻¹)).card := by
  have himg : (A.image (fun b => n * b⁻¹)).card = A.card := by
    apply Finset.card_image_of_injective
    intro x y hxy
    simpa using inv_injective (mul_left_cancel hxy)
  rw [sym_fiber_card, Finset.card_union]
  omega

/-- For the singleton `A = {1}` (the event "`l ∣ x - 1`") the asymmetric count is `1`
for every `n`. -/
theorem asym_fiber_card_one (n : G) : (asymFiber ({1} : Finset G) n).card = 1 := by
  simp [asym_fiber_card]

/-- For the singleton `A = {1}` the symmetric count is `1` at `n = 1` and `2`
elsewhere.  This single formula is the whole asymmetric/symmetric dichotomy. -/
theorem sym_fiber_card_one (n : G) :
    (symFiber ({1} : Finset G) n).card = if n = 1 then 1 else 2 := by
  rw [sym_fiber_card]
  by_cases h : n = 1 <;> simp [h, Finset.union_comm]

end Group

/-! ## Part 2 : the conditional probabilities for `G = (ZMod l)ˣ` -/

section ZMod

variable (l : ℕ) [Fact (Nat.Prime l)]

/-- The size of the relevant group: `|(ZMod l)ˣ| = l - 1`. -/
theorem card_units_zmod : Fintype.card (ZMod l)ˣ = l - 1 := by
  haveI : NeZero l := ⟨(Fact.out : Nat.Prime l).ne_zero⟩
  rw [ZMod.card_units_eq_totient, Nat.totient_prime (Fact.out : Nat.Prime l)]

/-- Rational form of the group order. -/
theorem card_units_zmod_cast :
    ((Fintype.card (ZMod l)ˣ : ℕ) : ℚ) = (l : ℚ) - 1 := by
  have hl : 1 ≤ l := (Fact.out : Nat.Prime l).one_lt.le.trans' (by norm_num)
  rw [card_units_zmod l, Nat.cast_sub hl, Nat.cast_one]

/-- Conditional probability of the *asymmetric* event `a = 1` given `a * b = n`. -/
def asymCondProb (n : (ZMod l)ˣ) : ℚ :=
  ((asymFiber ({1} : Finset (ZMod l)ˣ) n).card : ℚ) / (Fintype.card (ZMod l)ˣ : ℚ)

/-- Conditional probability of the *symmetric* event `a = 1 ∨ b = 1` given `a * b = n`. -/
def symCondProb (n : (ZMod l)ˣ) : ℚ :=
  ((symFiber ({1} : Finset (ZMod l)ˣ) n).card : ℚ) / (Fintype.card (ZMod l)ˣ : ℚ)

/-- **Zero asymmetric leak.**  The conditional probability of `l ∣ p - 1` given the
residue of `N = p q` is `1/(l-1)` — the unconditional rate — for *every* residue. -/
theorem asym_condProb_constant (n : (ZMod l)ˣ) :
    asymCondProb l n = 1 / ((l : ℚ) - 1) := by
  rw [asymCondProb, asym_fiber_card_one, card_units_zmod_cast]
  norm_num

/-- **Strong symmetric leak.**  The conditional probability of `l ∣ p-1 ∨ l ∣ q-1`
given the residue of `N` is `1/(l-1)` at `N ≡ 1` and `2/(l-1)` otherwise: twice the
base rate.  In particular at `l = 3` it is `1` — a forced event. -/
theorem sym_condProb_value (n : (ZMod l)ˣ) :
    symCondProb l n = (if n = 1 then 1 else 2) / ((l : ℚ) - 1) := by
  rw [symCondProb, sym_fiber_card_one, card_units_zmod_cast]
  by_cases h : n = 1 <;> simp [h]

/-- The dichotomy, packaged: for every odd prime `l` the asymmetric conditional
probability is constant in the residue class of `N`, while the symmetric one is not. -/
theorem asym_sym_dichotomy (hl : 2 < l) :
    (∀ n m : (ZMod l)ˣ, asymCondProb l n = asymCondProb l m) ∧
      (∃ n m : (ZMod l)ˣ, symCondProb l n ≠ symCondProb l m) := by
  haveI : Fact (2 < l) := ⟨hl⟩
  haveI : NeZero l := ⟨(Fact.out : Nat.Prime l).ne_zero⟩
  refine ⟨fun n m => by rw [asym_condProb_constant, asym_condProb_constant], ?_⟩
  have hne : (-1 : (ZMod l)ˣ) ≠ 1 := by
    intro h
    exact ZMod.neg_one_ne_one (n := l) (congrArg Units.val h)
  refine ⟨1, -1, ?_⟩
  rw [sym_condProb_value, sym_condProb_value]
  have hlq : (l : ℚ) - 1 ≠ 0 := by
    have : (2 : ℚ) < (l : ℚ) := by exact_mod_cast hl
    intro h; linarith [h]
  simp only [if_neg hne, if_pos]
  intro h
  field_simp at h
  norm_num at h

end ZMod

/-! ## Part 3 : arithmetic incarnation for genuine semiprimes -/

/-- **The exact `l = 3` mechanism.**  If `N = p q` with `p, q` primes different from `3`
and `N ≡ 2 (mod 3)`, then one of the two factors is `≡ 1 (mod 3)`: the symmetric
divisibility event is *forced* by the residue of `N`.  (Experimentally `P(OR) = 1.000`.) -/
theorem symmetric_forced_mod_three {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hp3 : p ≠ 3) (hq3 : q ≠ 3) (h : (p * q) % 3 = 2) :
    3 ∣ p - 1 ∨ 3 ∣ q - 1 := by
  have hpm : p % 3 ≠ 0 := by
    intro hc
    have := hp.eq_one_or_self_of_dvd 3 (Nat.dvd_of_mod_eq_zero hc)
    omega
  have hqm : q % 3 ≠ 0 := by
    intro hc
    have := hq.eq_one_or_self_of_dvd 3 (Nat.dvd_of_mod_eq_zero hc)
    omega
  have hp1 : 2 ≤ p := hp.two_le
  have hq1 : 2 ≤ q := hq.two_le
  have hmul : (p * q) % 3 = ((p % 3) * (q % 3)) % 3 := Nat.mul_mod p q 3
  have hpr : p % 3 = 1 ∨ p % 3 = 2 := by omega
  have hqr : q % 3 = 1 ∨ q % 3 = 2 := by omega
  rcases hpr with h1 | h1 <;> rcases hqr with h2 | h2 <;> rw [h1, h2] at hmul <;>
    simp at hmul <;> omega

/-- Conversely the symmetric event is *not* forced in the other residue class:
`55 = 5 · 11 ≡ 1 (mod 3)` has neither factor `≡ 1 (mod 3)`, while
`91 = 7 · 13 ≡ 1 (mod 3)` has both. -/
theorem sym_ambiguous_mod_three :
    ((5 * 11) % 3 = 1 ∧ ¬(3 ∣ 5 - 1 ∨ 3 ∣ 11 - 1)) ∧
      ((7 * 13) % 3 = 1 ∧ (3 ∣ 7 - 1 ∨ 3 ∣ 13 - 1)) := by
  refine ⟨⟨by norm_num, ?_⟩, ⟨by norm_num, ?_⟩⟩ <;> decide

/-- **Zero asymmetric leak, arithmetically.**  There is no function of `N mod 3`
deciding whether the smaller prime factor `p` satisfies `3 ∣ p - 1`:
`77 = 7 · 11` and `65 = 5 · 13` are both `≡ 2 (mod 3)` but disagree. -/
theorem asym_not_residue_dial :
    ¬ ∃ f : ℕ → Bool, ∀ p q : ℕ, p.Prime → q.Prime → p < q → p ≠ 3 → q ≠ 3 →
      ((3 ∣ p - 1) ↔ f ((p * q) % 3) = true) := by
  rintro ⟨f, hf⟩
  have h1 := hf 7 11 (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h2 := hf 5 13 (by norm_num) (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  norm_num at h1 h2
  rw [h1] at h2
  exact absurd h2 (by simp)

/-- Both residue classes mod `3` carry both outcomes of the asymmetric event, so the
leak is zero in the strong (per-class) sense, not merely on average. -/
theorem asym_ambiguous_each_class :
    ((7 * 11) % 3 = 2 ∧ 3 ∣ 7 - 1) ∧ ((5 * 13) % 3 = 2 ∧ ¬ 3 ∣ 5 - 1) ∧
      ((7 * 13) % 3 = 1 ∧ 3 ∣ 7 - 1) ∧ ((5 * 11) % 3 = 1 ∧ ¬ 3 ∣ 5 - 1) := by
  refine ⟨⟨by norm_num, by decide⟩, ⟨by norm_num, by decide⟩, ⟨by norm_num, by decide⟩,
    ⟨by norm_num, by decide⟩⟩

/-- At `l = 5` the symmetric event is *not* forced by **any** residue class: each of the
four classes mod `5` contains a semiprime with neither factor `≡ 1 (mod 5)`
(`91 = 7·13 ≡ 1`, `247 = 13·19 ≡ 2`, `133 = 7·19 ≡ 3`, `119 = 7·17 ≡ 4`).  This matches
the much smaller measured leak (`0.036` bits): the `l = 3` forcing is special to the
group of order two, where the two-element fibre is exhausted by the symmetric event. -/
theorem sym_not_forced_mod_five :
    ((7 * 13) % 5 = 1 ∧ ¬(5 ∣ 7 - 1 ∨ 5 ∣ 13 - 1)) ∧
      ((13 * 19) % 5 = 2 ∧ ¬(5 ∣ 13 - 1 ∨ 5 ∣ 19 - 1)) ∧
      ((7 * 19) % 5 = 3 ∧ ¬(5 ∣ 7 - 1 ∨ 5 ∣ 19 - 1)) ∧
      ((7 * 17) % 5 = 4 ∧ ¬(5 ∣ 7 - 1 ∨ 5 ∣ 17 - 1)) := by
  refine ⟨⟨by norm_num, ?_⟩, ⟨by norm_num, ?_⟩, ⟨by norm_num, ?_⟩, ⟨by norm_num, ?_⟩⟩ <;> decide

end SmoothSelfHint