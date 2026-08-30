import Mathlib
import Bridges.TreeSieveLottery

/-!
# The hypotenuse face of the Berggren tree is blind to `3 mod 4` primes

The tree-sieve experiments measured a real but modest smoothness advantage of
Berggren-tree values over random integers (`7.31×`, against a naive `~44×`
prediction).  This file identifies the exact arithmetic reason — and shows that
the same structure is a *fatal* restriction for factoring.

Every node of the Berggren tree is a **primitive** Pythagorean triple
(`bergOf_prim`), and every prime divisor of the hypotenuse of a primitive triple
is `≡ 1 mod 4` (`prime_dvd_hyp_one_mod_four`).  So the hypotenuse values of the
tree are supported on the half of the primes congruent to `1 mod 4`: that is
where the observed smoothness boost comes from (the effective factor base is a
density-`1/2` subset of the primes, and hypotenuse values are never divisible by
`2, 3, 7, 11, 19, 23, …`).

The price is `hypotenuse_face_blind_to_three_mod_four`: for a modulus `N` all of
whose prime factors are `≡ 3 mod 4` — for example `N = p * q` with
`p ≡ q ≡ 3 mod 4` — the gcd of *any* tree hypotenuse with `N` is `1`.  The
lottery of `Catalog.Bridges.TreeSieveLottery` does not merely have a small
winning probability on this class of moduli: it has **no winning tickets at
all**, uniformly over the whole infinite tree.

Main results:

* `bergOf_prim` — every tree node is a primitive triple.
* `prime_dvd_hyp_one_mod_four` — prime divisors of hypotenuses of primitive
  triples are `1 mod 4`.
* `berg_hyp_prime_one_mod_four` — the same for every node of the tree.
* `hypotenuse_face_blind_to_three_mod_four` — zero success probability on
  `3 mod 4` moduli.
* `hypotenuse_face_blind_semiprime` — the concrete semiprime corollary.
-/

namespace TreeSieveHyp

open TreeSieve

/-! ## Primitivity is a tree invariant -/

/-- Primitivity: no prime divides both legs. -/
def Prim (t : Triple) : Prop := ∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ t.1 ∧ (r : ℤ) ∣ t.2.1)

theorem prim_root : Prim (3, 4, 5) := by
  rintro r hr ⟨h3, h4⟩
  have h1 : (r : ℤ) ∣ 1 := by simpa using dvd_sub h4 h3
  have h2 : r ∣ 1 := by exact_mod_cast h1
  have := Nat.le_of_dvd Nat.one_pos h2
  have := hr.two_le
  omega

/-- A prime dividing both legs of a Pythagorean triple divides the hypotenuse. -/
theorem prime_dvd_hyp_of_dvd_legs {a b c : ℤ} (hpy : a ^ 2 + b ^ 2 = c ^ 2) {r : ℕ}
    (hr : r.Prime) (ha : (r : ℤ) ∣ a) (hb : (r : ℤ) ∣ b) : (r : ℤ) ∣ c := by
  have hrp : Prime (r : ℤ) := Nat.prime_iff_prime_int.mp hr
  have : (r : ℤ) ∣ c ^ 2 := by
    rw [← hpy]
    exact dvd_add (Dvd.dvd.pow ha (by norm_num)) (Dvd.dvd.pow hb (by norm_num))
  exact hrp.dvd_of_dvd_pow this

/-- Each Berggren move preserves primitivity. -/
theorem prim_step (i : Fin 3) {t : Triple} (hpy : t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2)
    (h : Prim t) : Prim (step i t) := by
  obtain ⟨a, b, c⟩ := t
  intro r hr hdvd
  obtain ⟨ha', hb'⟩ := hdvd
  have hpy' := step_pyth i (a, b, c) hpy
  have hc' : (r : ℤ) ∣ (step i (a, b, c)).2.2 := prime_dvd_hyp_of_dvd_legs hpy' hr ha' hb'
  refine h r hr ⟨?_, ?_⟩ <;>
    fin_cases i <;> simp only [step] at ha' hb' hc' ⊢ <;>
    · obtain ⟨u, hu⟩ := ha'
      obtain ⟨v, hv⟩ := hb'
      obtain ⟨w, hw⟩ := hc'
      first
        | exact ⟨u + 2 * v - 2 * w, by linarith⟩
        | exact ⟨-2 * u - v + 2 * w, by linarith⟩
        | exact ⟨2 * u + v - 2 * w, by linarith⟩
        | exact ⟨-u - 2 * v + 2 * w, by linarith⟩

theorem bergFrom_prim (w : List (Fin 3)) {t : Triple}
    (hpy : t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2) (h : Prim t) : Prim (bergFrom t w) := by
  induction w generalizing t with
  | nil => simpa [bergFrom] using h
  | cons i w ih => exact ih (step_pyth i t hpy) (prim_step i hpy h)

/-- Every node of the Berggren tree is a primitive Pythagorean triple. -/
theorem bergOf_prim (w : List (Fin 3)) : Prim (bergOf w) :=
  bergFrom_prim w (by norm_num) prim_root

/-! ## Prime divisors of a primitive hypotenuse are `1 mod 4` -/

/-- The hypotenuse of a primitive Pythagorean triple is odd. -/
theorem hyp_odd {a b c : ℤ} (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (hprim : ¬ ((2 : ℤ) ∣ a ∧ (2 : ℤ) ∣ b)) : ¬ (2 : ℤ) ∣ c := by
  rintro ⟨m, rfl⟩
  rcases Int.even_or_odd a with ⟨k, rfl⟩ | ⟨k, rfl⟩ <;>
    rcases Int.even_or_odd b with ⟨l, rfl⟩ | ⟨l, rfl⟩
  · exact hprim ⟨⟨k, by ring⟩, ⟨l, by ring⟩⟩
  · have h4 : (4 : ℤ) * (m * m - k * k - l * l - l) = 1 := by linear_combination -hpy
    omega
  · have h4 : (4 : ℤ) * (m * m - k * k - k - l * l) = 1 := by linear_combination -hpy
    omega
  · have h4 : (4 : ℤ) * (m * m - k * k - k - l * l - l) = 2 := by linear_combination -hpy
    omega

/-- **Structure of the hypotenuse face.**  Every prime divisor of the hypotenuse
of a primitive Pythagorean triple is congruent to `1` modulo `4`. -/
theorem prime_dvd_hyp_one_mod_four {a b c : ℤ} (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (hprim : ∀ r : ℕ, r.Prime → ¬ ((r : ℤ) ∣ a ∧ (r : ℤ) ∣ b))
    {p : ℕ} (hp : p.Prime) (hdvd : (p : ℤ) ∣ c) : p % 4 = 1 := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hp2 : p ≠ 2 := by
    rintro rfl
    exact hyp_odd hpy (fun h => hprim 2 Nat.prime_two (by exact_mod_cast h)) (by exact_mod_cast hdvd)
  have hab : (p : ℤ) ∣ a ^ 2 + b ^ 2 := by
    rw [hpy]; exact Dvd.dvd.pow hdvd (by norm_num)
  have hbne : ¬ (p : ℤ) ∣ b := by
    intro hb
    have hb2 : (p : ℤ) ∣ b ^ 2 := Dvd.dvd.pow hb (by norm_num)
    have hpa : (p : ℤ) ∣ a ^ 2 := by
      have hrw : a ^ 2 = (a ^ 2 + b ^ 2) - b ^ 2 := by ring
      rw [hrw]; exact dvd_sub hab hb2
    have hrp : Prime (p : ℤ) := Nat.prime_iff_prime_int.mp hp
    exact hprim p hp ⟨hrp.dvd_of_dvd_pow hpa, hb⟩
  have h0 : ((a : ZMod p)) ^ 2 + ((b : ZMod p)) ^ 2 = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (a ^ 2 + b ^ 2) p).mpr hab
    push_cast at this
    exact this
  have hbz : (b : ZMod p) ≠ 0 := fun h =>
    hbne ((ZMod.intCast_zmod_eq_zero_iff_dvd b p).mp h)
  have hsq : IsSquare (-1 : ZMod p) := by
    refine ⟨(a : ZMod p) * (b : ZMod p)⁻¹, ?_⟩
    field_simp
    linear_combination -h0
  have h3 := ZMod.exists_sq_eq_neg_one_iff.mp hsq
  have := Nat.odd_iff.mp (hp.odd_of_ne_two hp2)
  omega

/-- Every prime divisor of a Berggren-tree hypotenuse is `1 mod 4`. -/
theorem berg_hyp_prime_one_mod_four (w : List (Fin 3)) {p : ℕ} (hp : p.Prime)
    (hdvd : (p : ℤ) ∣ (bergOf w).2.2) : p % 4 = 1 :=
  prime_dvd_hyp_one_mod_four (bergOf_pyth w) (bergOf_prim w) hp hdvd

/-! ## Consequence: zero winning tickets on `3 mod 4` moduli -/

/-- **The hypotenuse face is blind.**  If every prime factor of `N` is
`≡ 3 mod 4`, then the gcd of any Berggren-tree hypotenuse with `N` is `1`:
uniformly over the entire infinite tree, the sieve can never split `N`. -/
theorem hypotenuse_face_blind_to_three_mod_four (w : List (Fin 3)) (N : ℕ)
    (h3 : ∀ p : ℕ, p.Prime → p ∣ N → p % 4 = 3) :
    Int.gcd (bergOf w).2.2 (N : ℤ) = 1 := by
  by_contra hg
  obtain ⟨r, hr, hrg⟩ := Nat.exists_prime_and_dvd hg
  have hrc : (r : ℤ) ∣ (bergOf w).2.2 :=
    dvd_trans (Int.natCast_dvd_natCast.mpr hrg) (Int.gcd_dvd_left _ _)
  have hrN : r ∣ N := by
    have : (r : ℤ) ∣ (N : ℤ) :=
      dvd_trans (Int.natCast_dvd_natCast.mpr hrg) (Int.gcd_dvd_right _ _)
    exact_mod_cast this
  have h1 := berg_hyp_prime_one_mod_four w hr hrc
  have h2 := h3 r hr hrN
  omega

/-- **The effective factor base is halved.**  The prime factors of any tree
hypotenuse lie in the `1 mod 4` half of the primes; in particular no tree
hypotenuse is divisible by `2`, `3`, `7`, `11`, `19`, `23`, …  This is the exact
source of the measured smoothness advantage of tree values over random ones. -/
theorem berg_hyp_primeFactors_subset (w : List (Fin 3)) :
    ((bergOf w).2.2.natAbs).primeFactors ⊆
      ((bergOf w).2.2.natAbs).primeFactors.filter (fun p => p % 4 = 1) := by
  intro p hp
  refine Finset.mem_filter.mpr ⟨hp, ?_⟩
  refine berg_hyp_prime_one_mod_four w (Nat.prime_of_mem_primeFactors hp) ?_
  have hdvd : (p : ℤ) ∣ ((bergOf w).2.2.natAbs : ℤ) := by
    exact_mod_cast Int.natCast_dvd_natCast.mpr (Nat.dvd_of_mem_primeFactors hp)
  exact Int.dvd_natAbs.mp hdvd

/-- No Berggren-tree hypotenuse is even, and none is divisible by `3`. -/
theorem berg_hyp_not_dvd_two_three (w : List (Fin 3)) :
    ¬ (2 : ℤ) ∣ (bergOf w).2.2 ∧ ¬ (3 : ℤ) ∣ (bergOf w).2.2 := by
  constructor
  · intro h
    have := berg_hyp_prime_one_mod_four w Nat.prime_two (by exact_mod_cast h)
    omega
  · intro h
    have := berg_hyp_prime_one_mod_four w Nat.prime_three (by exact_mod_cast h)
    omega

/-- Concrete semiprime form: for `N = p * q` with `p ≡ q ≡ 3 mod 4` (both
prime), no hypotenuse of the Berggren tree shares a factor with `N`. -/
theorem hypotenuse_face_blind_semiprime (w : List (Fin 3)) {p q : ℕ}
    (hp : p.Prime) (hq : q.Prime) (hp3 : p % 4 = 3) (hq3 : q % 4 = 3) :
    Int.gcd (bergOf w).2.2 ((p * q : ℕ) : ℤ) = 1 := by
  refine hypotenuse_face_blind_to_three_mod_four w (p * q) ?_
  intro r hr hrdvd
  rcases (Nat.Prime.dvd_mul hr).mp hrdvd with h | h
  · rw [(Nat.prime_dvd_prime_iff_eq hr hp).mp h]; exact hp3
  · rw [(Nat.prime_dvd_prime_iff_eq hr hq).mp h]; exact hq3

/-! ## Sharpness: the obstruction is specific to the hypotenuse face -/

/-- The blindness is *not* a property of the whole tree: the odd leg of the
depth-one node `(21, 20, 29)` is divisible by `3` and by `7`, both `3 mod 4`.
So a sieve reading the legs escapes the congruence obstruction — but it is then
governed by the generic lottery bound of `TreeSieve.lottery_union_bound`. -/
theorem leg_face_not_blind :
    (3 : ℤ) ∣ (bergOf [1]).1 ∧ (7 : ℤ) ∣ (bergOf [1]).1 := by
  refine ⟨⟨7, ?_⟩, ⟨3, ?_⟩⟩ <;> norm_num [bergOf, bergFrom, step]

/-- Concretely, the leg face does split some moduli: `gcd(21, 33) = 3`. -/
theorem leg_face_splits_example : Int.gcd (bergOf [1]).1 33 = 3 := by
  norm_num [bergOf, bergFrom, step, Int.gcd]

end TreeSieveHyp