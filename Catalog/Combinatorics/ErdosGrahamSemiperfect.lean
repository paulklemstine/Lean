import Mathlib
import Combinatorics.ErdosGrahamEgyptian
import Combinatorics.ErdosGrahamObstructions

/-!
# Erdős–Graham III: Egyptian coverings and pseudoperfect numbers

Third file of the Erdős–Graham development.  We build a *duality bridge* between the
combinatorics of exact Egyptian coverings and classical divisor-sum arithmetic:

> `pseudoperfect_iff_exists_egyptian_dvd` :  for `N > 0`,
> `N` is pseudoperfect  ↔  some Egyptian set consists of divisors of `N`.

The bijection is `d ↦ N / d`, exchanging "a set of distinct proper divisors summing to `N`"
with "a set of distinct divisors `≥ 2` whose reciprocals sum to `1`".

Consequences.

* Every perfect number carries an Egyptian covering by its divisors
  (`exists_egyptian_dvd_of_perfect`), e.g. `6` and `28`.
* **A second, global obstruction**: the divisors of a *deficient* number form an
  Egyptian-free set (`egyptianFree_divisors_of_deficient`).  This is independent of the
  local `p`-adic obstruction of `ErdosGrahamObstructions.lean`.
* **The local criterion is incomplete**: the divisors of `70` are *not* `p`-adically
  separated and `70` is *abundant*, yet the divisor set of `70` is Egyptian-free
  (`70` is a weird number).  So neither obstruction subsumes the other
  (`padicSeparated_not_necessary`).
* Any set of distinct proper divisors of `N` summing to `N` has at least three elements
  (`three_le_card_of_sum_properDivisors`), the divisor-sum shadow of
  `Egyptian.three_le_card`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Egyptian coverings inside the divisor lattice of `N` are the
same objects as pseudoperfect representations of `N`; hence classical divisor-sum
arithmetic gives *global* Egyptian-freeness criteria that the `p`-adic argument cannot see.

Experiment (Experimenter): Formalised the duality `d ↦ N/d` and pushed it in both
directions.  Deficiency gives Egyptian-freeness; the weird number `70` (abundant, not
pseudoperfect) gives an Egyptian-free divisor set that is *not* `p`-adically separated.

Analysis (Analyst): There are (at least) two independent mechanisms preventing exact
coverings: a local one (`p`-adic valuations, `egyptianFree_of_padicSeparated`) and a
global one (mass: `∑_{d | N, d < N} d < N`).  The weird numbers show that even together
they are not exhaustive: `70` is abundant, so it has enough mass, and it is not
`p`-adically separated — yet it admits no exact covering.

Critique (Critic): all statements are guarded by `0 < N`; the `70` example is taken from
Mathlib's verified `Nat.weird_seventy`, not asserted; the bridge is an honest `↔`, and
its two directions are used in both senses below, so it is not a vacuous restatement.
-- !-- Lab Notes -- !--
-/

namespace ErdosGraham

open Finset

section Bridge

/-- Divisor complementation `d ↦ N / d` is injective on any set of divisors of `N`. -/
private lemma divComplement_injOn {N : ℕ} (hN : 0 < N) {T : Finset ℕ}
    (hT : ∀ d ∈ T, d ∣ N) : Set.InjOn (fun d => N / d) ↑T := by
  intro a ha b hb hab
  simp only at hab
  have h1 : N / (N / a) = a := Nat.div_div_self (hT a (Finset.mem_coe.mp ha)) hN.ne'
  have h2 : N / (N / b) = b := Nat.div_div_self (hT b (Finset.mem_coe.mp hb)) hN.ne'
  rw [← h1, ← h2, hab]

/-- If `d` is a proper divisor of `N > 0`, the complementary divisor `N / d` is at least
`2`. -/
private lemma two_le_div_of_lt {N d : ℕ} (hN : 0 < N) (hdvd : d ∣ N) (hlt : d < N) :
    2 ≤ N / d := by
  obtain ⟨k, hk⟩ := hdvd
  have hd0 : 0 < d := by
    rcases Nat.eq_zero_or_pos d with rfl | hd
    · simp at hk; omega
    · exact hd
  have hkval : N / d = k := by rw [hk, Nat.mul_div_cancel_left k hd0]
  rw [hkval]
  by_contra hcon
  push_neg at hcon
  interval_cases k <;> simp at hk <;> omega

/-- Complementing a set of distinct proper divisors summing to `N` produces an Egyptian
set. -/
private lemma egyptian_image_div {N : ℕ} (hN : 0 < N) {D : Finset ℕ}
    (hD : D ⊆ N.properDivisors) (hsum : ∑ d ∈ D, d = N) :
    Egyptian (D.image (fun d => N / d)) := by
  have hdvd : ∀ d ∈ D, d ∣ N := fun d hd => (Nat.mem_properDivisors.mp (hD hd)).1
  have hlt : ∀ d ∈ D, d < N := fun d hd => (Nat.mem_properDivisors.mp (hD hd)).2
  refine ⟨?_, ?_⟩
  · intro n hn
    obtain ⟨d, hd, rfl⟩ := Finset.mem_image.mp hn
    exact two_le_div_of_lt hN (hdvd d hd) (hlt d hd)
  · rw [Finset.sum_image (divComplement_injOn hN hdvd)]
    have hterm : ∀ d ∈ D, (1 : ℚ) / ((N / d : ℕ) : ℚ) = (d : ℚ) / N := by
      intro d hd
      have hd0 : d ≠ 0 := by
        rintro rfl
        exact absurd (Nat.eq_zero_of_zero_dvd (hdvd 0 hd)) (by omega)
      have hcast : ((N / d : ℕ) : ℚ) = (N : ℚ) / d :=
        Nat.cast_div (hdvd d hd) (by exact_mod_cast hd0)
      have hN0 : (N : ℚ) ≠ 0 := by exact_mod_cast hN.ne'
      rw [hcast]
      field_simp
    have hsumQ : ∑ d ∈ D, (d : ℚ) = (N : ℚ) := by rw [← Nat.cast_sum, hsum]
    have hN0 : (N : ℚ) ≠ 0 := by exact_mod_cast hN.ne'
    rw [Finset.sum_congr rfl hterm, ← Finset.sum_div, hsumQ]
    field_simp

/-- **Duality bridge.**  For `N > 0`, the number `N` is pseudoperfect (a sum of distinct
proper divisors of itself) exactly when some Egyptian set consists of divisors of `N`.
The bijection between the two descriptions is divisor complementation `d ↦ N / d`. -/
theorem pseudoperfect_iff_exists_egyptian_dvd {N : ℕ} (hN : 0 < N) :
    N.Pseudoperfect ↔ ∃ S : Finset ℕ, Egyptian S ∧ ∀ n ∈ S, n ∣ N := by
  constructor
  · rintro ⟨-, D, hD, hsum⟩
    have hdvd : ∀ d ∈ D, d ∣ N := fun d hd => (Nat.mem_properDivisors.mp (hD hd)).1
    refine ⟨D.image (fun d => N / d), egyptian_image_div hN hD hsum, ?_⟩
    intro n hn
    obtain ⟨d, hd, rfl⟩ := Finset.mem_image.mp hn
    exact Nat.div_dvd_of_dvd (hdvd d hd)
  · rintro ⟨S, hS, hdvd⟩
    have hinj := divComplement_injOn hN hdvd
    refine ⟨hN, S.image (fun n => N / n), ?_, ?_⟩
    · intro d hd
      obtain ⟨n, hn, rfl⟩ := Finset.mem_image.mp hd
      have hn2 : 2 ≤ n := hS.1 n hn
      exact Nat.mem_properDivisors.mpr
        ⟨Nat.div_dvd_of_dvd (hdvd n hn), Nat.div_lt_self hN (by omega)⟩
    · have hcast : ((∑ d ∈ S.image (fun n => N / n), d : ℕ) : ℚ) = (N : ℚ) := by
        rw [Nat.cast_sum, Finset.sum_image hinj]
        have hterm : ∀ n ∈ S, ((N / n : ℕ) : ℚ) = (N : ℚ) * ((1 : ℚ) / n) := by
          intro n hn
          have hn2 : 2 ≤ n := hS.1 n hn
          have hn0 : n ≠ 0 := by omega
          rw [Nat.cast_div (hdvd n hn) (by exact_mod_cast hn0)]
          field_simp
        rw [Finset.sum_congr rfl hterm, ← Finset.mul_sum, hS.2, mul_one]
      exact_mod_cast hcast

/-- The least common multiple of an Egyptian set is pseudoperfect. -/
theorem Egyptian.pseudoperfect_lcm {S : Finset ℕ} (h : Egyptian S) :
    (S.lcm id).Pseudoperfect := by
  have hpos : 0 < S.lcm id := by
    rcases Nat.eq_zero_or_pos (S.lcm id) with hz | hp
    · exfalso
      obtain ⟨x, hx, hx0⟩ := Finset.lcm_eq_zero_iff.mp hz
      have := h.1 x hx
      simp only [id] at hx0
      omega
    · exact hp
  exact (pseudoperfect_iff_exists_egyptian_dvd hpos).mpr
    ⟨S, h, fun n hn => Finset.dvd_lcm hn⟩

/-- Every perfect number is covered by an Egyptian set of its divisors. -/
theorem exists_egyptian_dvd_of_perfect {N : ℕ} (h : N.Perfect) :
    ∃ S : Finset ℕ, Egyptian S ∧ ∀ n ∈ S, n ∣ N :=
  (pseudoperfect_iff_exists_egyptian_dvd h.2).mp h.pseudoperfect

/-- A set of distinct proper divisors of `N` summing to `N` has at least three elements —
the divisor-sum shadow of `Egyptian.three_le_card`. -/
theorem three_le_card_of_sum_properDivisors {N : ℕ} (hN : 0 < N) {D : Finset ℕ}
    (hD : D ⊆ N.properDivisors) (hsum : ∑ d ∈ D, d = N) : 3 ≤ D.card := by
  have hdvd : ∀ d ∈ D, d ∣ N := fun d hd => (Nat.mem_properDivisors.mp (hD hd)).1
  have hcard : (D.image (fun d => N / d)).card = D.card :=
    Finset.card_image_of_injOn (divComplement_injOn hN hdvd)
  have := (egyptian_image_div hN hD hsum).three_le_card
  omega

end Bridge

section GlobalObstruction

/-- **Global (mass) obstruction.**  The divisors of a *deficient* number form an
Egyptian-free set: there is simply not enough reciprocal mass among the divisors.
This obstruction is independent of the local `p`-adic one. -/
theorem egyptianFree_divisors_of_deficient {N : ℕ} (hN : 0 < N) (hdef : N.Deficient) :
    EgyptianFree {n : ℕ | n ∣ N ∧ 2 ≤ n} := by
  intro S hSA hS
  have hdvd : ∀ n ∈ S, n ∣ N := fun n hn => (hSA hn).1
  obtain ⟨-, D, hD, hsum⟩ := (pseudoperfect_iff_exists_egyptian_dvd hN).mpr ⟨S, hS, hdvd⟩
  have hle : ∑ d ∈ D, d ≤ ∑ d ∈ N.properDivisors, d :=
    Finset.sum_le_sum_of_subset hD
  rw [hsum] at hle
  exact absurd hdef (by simpa [Nat.Deficient] using hle)

/-- Prime powers are deficient, hence their divisor sets are Egyptian-free — a second
proof of a special case of `egyptianFree_primePowers`, now by mass rather than by
`p`-adic separation. -/
theorem egyptianFree_divisors_prime_pow {p k : ℕ} (hp : p.Prime) :
    EgyptianFree {n : ℕ | n ∣ p ^ k ∧ 2 ≤ n} :=
  egyptianFree_divisors_of_deficient (pow_pos hp.pos k) (Nat.Prime.deficient_pow hp)

end GlobalObstruction

section Incompleteness

/-- The divisors of `70` are **not** `p`-adically separated: `2` and `10` both have
`2`-adic valuation `1`. -/
theorem not_padicSeparated_divisors_seventy :
    ¬ PadicSeparated {n : ℕ | n ∣ 70 ∧ 2 ≤ n} := by
  intro h
  have h2 : (2 : ℕ) ∈ {n : ℕ | n ∣ 70 ∧ 2 ≤ n} := ⟨by norm_num, by norm_num⟩
  have h10 : (10 : ℕ) ∈ {n : ℕ | n ∣ 70 ∧ 2 ≤ n} := ⟨by norm_num, by norm_num⟩
  have e2 : padicValNat 2 2 = 1 := by simp
  have e10 : padicValNat 2 10 = 1 := by
    have h10' : (10 : ℕ) = 2 * 5 := by norm_num
    rw [h10', padicValNat.mul (by norm_num) (by norm_num)]
    simp [padicValNat.eq_zero_of_not_dvd]
  have := h 2 (by norm_num) 2 h2 10 h10 (by norm_num) (by rw [e2, e10])
  rw [e2] at this
  omega

/-- Yet the divisors of `70` are Egyptian-free, because `70` is a *weird* number
(abundant but not pseudoperfect, `Nat.weird_seventy`). -/
theorem egyptianFree_divisors_seventy : EgyptianFree {n : ℕ | n ∣ 70 ∧ 2 ≤ n} := by
  intro S hSA hS
  have hdvd : ∀ n ∈ S, n ∣ 70 := fun n hn => (hSA hn).1
  have hps : (70 : ℕ).Pseudoperfect :=
    (pseudoperfect_iff_exists_egyptian_dvd (by norm_num)).mpr ⟨S, hS, hdvd⟩
  exact Nat.weird_seventy.2 hps

/-- **The local criterion is not necessary.**  There is an Egyptian-free set of integers
`≥ 2` that is not `p`-adically separated, so `egyptianFree_of_padicSeparated` does not
characterise Egyptian-freeness: a genuinely global obstruction is also needed. -/
theorem padicSeparated_not_necessary :
    ∃ A : Set ℕ, (∀ n ∈ A, 2 ≤ n) ∧ EgyptianFree A ∧ ¬ PadicSeparated A :=
  ⟨{n : ℕ | n ∣ 70 ∧ 2 ≤ n}, fun _ hn => hn.2, egyptianFree_divisors_seventy,
    not_padicSeparated_divisors_seventy⟩

/-- **Colouring interface.**  If one colour class contains every divisor `≥ 2` of some
pseudoperfect number `N`, that colouring has a monochromatic exact Egyptian covering. -/
theorem erdosGraham_of_pseudoperfect_class {r N : ℕ} (c : ℕ → Fin r) (i : Fin r)
    (hN : N.Pseudoperfect) (hc : ∀ n, n ∣ N → 2 ≤ n → c n = i) :
    ∃ (S : Finset ℕ) (j : Fin r), Egyptian S ∧ ∀ n ∈ S, c n = j := by
  obtain ⟨S, hS, hdvd⟩ := (pseudoperfect_iff_exists_egyptian_dvd hN.1).mp hN
  exact ⟨S, i, hS, fun n hn => hc n (hdvd n hn) (hS.1 n hn)⟩

end Incompleteness

end ErdosGraham