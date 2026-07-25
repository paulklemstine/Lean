import Bridges.VampireDigitInvariant

/-!
# Prime Fangs on the Vampire Residue Curve

The decimal digit-permutation condition places vampire fangs on the affine
curve `(x - 1)(y - 1) = 1` modulo nine.  This file intersects that curve with
prime arithmetic.  The six residue pairs allowed for unrestricted fangs collapse
to three for prime fangs, and every resulting product is congruent to four
modulo nine.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Seven falsifiable directions were considered: the
advertised square-root density law; existence in every two-even-digit decade;
zero density for ghosts; infinitude of prime-fang digit permutations; a unit
curve law modulo `b-1`; exclusion of residues divisible by three for prime
fangs; and concentration of every prime-fang product in one residue modulo nine.
The density, interval, and infinitude questions remain grand challenges.  The
last three form a tractable algebra--combinatorics bridge.

Experiment (Experimenter): The catalog's exact six-point residue sieve gives
`(0,0), (2,2), (3,6), (5,8), (6,3), (8,5)`.  A prime cannot have residue zero or
six modulo nine.  Residue three forces the prime to equal three, but its partner
would then have residue six and could not be prime.  The surviving pairs are
therefore `(2,2), (5,8), (8,5)`; all three have product residue four.

Analysis (Analyst): Primality supplies the bridge from modular divisibility to
exact equality: if three divides a prime, that prime is three.  Combining this
with the previously established digit-permutation residue curve produces a
strictly stronger sieve than either ingredient alone.

Critique (Critic): The result is universally quantified, not a finite
enumeration.  It does not assume decimal length conventions, so it applies to
the common combinatorial core of vampire-style factorizations.  It proves a
necessary condition, not existence or density.  The mission's description of
"zombie" numbers is internally inconsistent: "both prime" conflicts with its
prime--composite examples; here the literal both-prime definition is used.

Synthesis (Principal Investigator): Prime fangs can occupy only three points of
the decimal vampire residue curve, forcing their product into the single class
four modulo nine.
-- !-- end Lab Notes -- !--
-/

namespace VampirePrimeFangSieve

open VampireDigitInvariant

/-- A prime divisible by three is exactly three. -/
lemma prime_eq_three_of_three_dvd {p : ℕ} (hp : p.Prime) (h3 : 3 ∣ p) : p = 3 := by
  rw [ hp.dvd_iff_eq ] at h3 <;> aesop

/-- A prime cannot be congruent to zero modulo nine. -/
lemma prime_mod_nine_ne_zero {p : ℕ} (hp : p.Prime) : p % 9 ≠ 0 := by
  exact fun h => by have := Nat.dvd_of_mod_eq_zero h; rw [ hp.dvd_iff_eq ] at this <;> norm_num [ this ] at *;

/-- A prime cannot be congruent to six modulo nine. -/
lemma prime_mod_nine_ne_six {p : ℕ} (hp : p.Prime) : p % 9 ≠ 6 := by
  exact fun had ↦ absurd ( Nat.dvd_of_mod_eq_zero ( show p % 3 = 0 from by omega ) ) ( by rw [ hp.dvd_iff_eq ] <;> omega )

/-- **Prime-fang residue sieve.**  If a decimal digit-permutation factorization
has two prime fangs, only three of the six unrestricted residue pairs survive. -/
theorem prime_fang_residue_sieve {v x y : ℕ}
    (h : VampireWitness v x y) (hx : x.Prime) (hy : y.Prime) :
    (x % 9, y % 9) = (2, 2) ∨
    (x % 9, y % 9) = (5, 8) ∨
    (x % 9, y % 9) = (8, 5) := by
  rcases vampire_fangs_residue_sieve h with h | h | h | h | h | h <;> simp_all +decide;
  · have := Nat.dvd_of_mod_eq_zero h.1; have := Nat.dvd_of_mod_eq_zero h.2; simp_all +decide [ Nat.Prime.dvd_iff_eq ] ;
  · exact absurd ( Nat.dvd_of_mod_eq_zero ( show y % 3 = 0 by norm_num [ ← Nat.mod_mod_of_dvd y ( by decide : 3 ∣ 9 ), h ] ) ) ( by rw [ hy.dvd_iff_eq ] <;> aesop_cat );
  · exact absurd ( Nat.dvd_of_mod_eq_zero ( show x % 3 = 0 by norm_num [ ← Nat.mod_mod_of_dvd x ( by decide : 3 ∣ 9 ), h ] ) ) ( by rw [ hx.dvd_iff_eq ] <;> aesop_cat )

/-- **Prime-fang concentration law.**  Every product with a decimal
vampire witness and two prime fangs is congruent to four modulo nine. -/
theorem prime_fang_product_mod_nine {v x y : ℕ}
    (h : VampireWitness v x y) (hx : x.Prime) (hy : y.Prime) :
    v % 9 = 4 := by
  rcases h with ⟨ rfl, h ⟩;
  have := prime_fang_residue_sieve ⟨ rfl, h ⟩ hx hy; rcases this with ( h | h | h ) <;> simp_all +decide [ Nat.mul_mod ] ;

/-- In particular, a prime-fang vampire witness is never divisible by three. -/
theorem three_not_dvd_prime_fang_product {v x y : ℕ}
    (h : VampireWitness v x y) (hx : x.Prime) (hy : y.Prime) :
    ¬ 3 ∣ v := by
  exact fun h' => by have := prime_fang_product_mod_nine h hx hy; omega;

end VampirePrimeFangSieve