import Mathlib
import Applications.ProofAutomation.FibonacciTactics

/-!
# Structural reductions around Beal's conjecture

The open assertion itself is not claimed here.  Instead, this chapter isolates the
algebraic reductions shared by approaches through primitive generalized Fermat
equations, Fermat--Catalan, and the abc conjecture.  The central fact is that, in
a positive-exponent equation `A^x + B^y = C^z`, a prime dividing any two bases
must divide the third.  Consequently, absence of a common prime is equivalent to
pairwise coprimality.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Seven testable statements were ranked by impact:
(1) Beal's assertion; (2) exclusion of all primitive generalized Fermat triples
of signature at most one; (3) an effective abc bound excluding all such triples;
(4) equivalence of Beal with its pairwise-coprime form; (5) equality of the prime
support of powered and unpowered products; (6) conversion of every primitive
Beal candidate into an abc triple; and (7) synchronization constraints when two
bases are Fibonacci numbers.  The first three are grand-challenge statements;
the remaining four are structural consequences suitable for unconditional test.

Experiment (Experimenter): An exhaustive search over bases at most 40 and
exponents from 3 through 6 found 23 ordered solutions and no primitive solution.
Every solution found had a nontrivial common divisor.  Representative signatures
included `2^3 + 2^3 = 2^4`, `7^3 + 7^4 = 14^3`, and
`3^6 + 18^3 = 9^4`.

Analysis (Analyst): The pair-to-triple divisibility lemma unifies all three
pairwise coprimality arguments.  Once primitive, the powered summands themselves
form a coprime additive triple, exactly the input shape used by abc.  Separately,
Fibonacci strong divisibility converts coprimality of Fibonacci bases into an
index-gcd restriction.

Critique (Critic): The exponent hypotheses are only needed to ensure powers have
positive exponents; the structural lemmas therefore use `0 < x`, `0 < y`, and
`0 < z`, while the Beal-facing statements retain the sharp `2 < x,y,z` boundary.
No theorem below assumes Beal, Fermat--Catalan, or abc silently.  The conditional
bridges name their conjectural premise explicitly.  The numerical search is
finite evidence, not a proof of the open assertion.

Synthesis (Principal Investigator): The resulting hierarchy separates the open
Diophantine exclusion from reusable, unconditional arithmetic: common-prime
localization, primitive reduction, the Fermat--Catalan signature map, the abc
triple map, and Fibonacci index synchronization.
-- !-- Lab Notes -- !--
-/

namespace BealResearch

/-- A positive generalized Fermat solution with all exponents strictly above two. -/
structure BealSolution where
  a : ℕ
  b : ℕ
  c : ℕ
  x : ℕ
  y : ℕ
  z : ℕ
  a_pos : 0 < a
  b_pos : 0 < b
  c_pos : 0 < c
  x_gt_two : 2 < x
  y_gt_two : 2 < y
  z_gt_two : 2 < z
  equation : a ^ x + b ^ y = c ^ z

/-- The three bases have a common prime divisor. -/
def HasCommonPrime (s : BealSolution) : Prop :=
  ∃ p : ℕ, Nat.Prime p ∧ p ∣ s.a ∧ p ∣ s.b ∧ p ∣ s.c

/-- The bases are pairwise coprime. -/
def IsPrimitive (s : BealSolution) : Prop :=
  Nat.Coprime s.a s.b ∧ Nat.Coprime s.a s.c ∧ Nat.Coprime s.b s.c

/-- Beal's conjecture, stated without building its truth into the data type. -/
def BealConjecture : Prop := ∀ s : BealSolution, HasCommonPrime s

/-- If a prime divides the first two bases, the equation forces it to divide the third. -/
theorem prime_dvd_AB_implies_dvd_C (s : BealSolution) {p : ℕ} (hp : Nat.Prime p)
    (hpA : p ∣ s.a) (hpB : p ∣ s.b) : p ∣ s.c := by
  apply hp.dvd_of_dvd_pow
  rw [← s.equation]
  exact dvd_add (dvd_pow hpA (ne_of_gt (lt_trans (by decide) s.x_gt_two))) (dvd_pow hpB (ne_of_gt (lt_trans (by decide) s.y_gt_two)))

/-- If a prime divides the first and third bases, the equation forces it to divide the second. -/
theorem prime_dvd_AC_implies_dvd_B (s : BealSolution) {p : ℕ} (hp : Nat.Prime p)
    (hpA : p ∣ s.a) (hpC : p ∣ s.c) : p ∣ s.b := by
  apply hp.dvd_of_dvd_pow
  have hsum : p ∣ s.a ^ s.x + s.b ^ s.y :=
    s.equation ▸ dvd_pow hpC (ne_of_gt (lt_trans (by decide) s.z_gt_two))
  exact (Nat.dvd_add_iff_right (dvd_pow hpA (ne_of_gt (lt_trans (by decide) s.x_gt_two)))).mpr hsum

/-- If a prime divides the second and third bases, the equation forces it to divide the first. -/
theorem prime_dvd_BC_implies_dvd_A (s : BealSolution) {p : ℕ} (hp : Nat.Prime p)
    (hpB : p ∣ s.b) (hpC : p ∣ s.c) : p ∣ s.a := by
  apply hp.dvd_of_dvd_pow
  have hsum : p ∣ s.a ^ s.x + s.b ^ s.y :=
    s.equation ▸ dvd_pow hpC (ne_of_gt (lt_trans (by decide) s.z_gt_two))
  exact (Nat.dvd_add_iff_left (dvd_pow hpB (ne_of_gt (lt_trans (by decide) s.y_gt_two)))).mpr hsum

/-- In a generalized Fermat equation, absence of a common prime is exactly pairwise
coprimality of the three bases. -/
theorem primitive_iff_no_common_prime (s : BealSolution) :
    IsPrimitive s ↔ ¬ HasCommonPrime s := by
  constructor
  · rintro ⟨hab, _, _⟩ ⟨p, hp, hpA, hpB, _⟩
    exact hp.not_dvd_one (hab.gcd_eq_one ▸ Nat.dvd_gcd hpA hpB)
  · intro h
    have hab : Nat.Coprime s.a s.b := by
      rw [Nat.coprime_iff_gcd_eq_one]
      by_contra hg
      obtain ⟨p, hp, hpg⟩ := Nat.exists_prime_and_dvd hg
      exact h ⟨p, hp,
        Nat.dvd_trans hpg (Nat.gcd_dvd_left s.a s.b),
        Nat.dvd_trans hpg (Nat.gcd_dvd_right s.a s.b),
        prime_dvd_AB_implies_dvd_C s hp
          (Nat.dvd_trans hpg (Nat.gcd_dvd_left s.a s.b))
          (Nat.dvd_trans hpg (Nat.gcd_dvd_right s.a s.b))⟩
    have hac : Nat.Coprime s.a s.c := by
      rw [Nat.coprime_iff_gcd_eq_one]
      by_contra hg
      obtain ⟨p, hp, hpg⟩ := Nat.exists_prime_and_dvd hg
      have hpA := Nat.dvd_trans hpg (Nat.gcd_dvd_left s.a s.c)
      have hpC := Nat.dvd_trans hpg (Nat.gcd_dvd_right s.a s.c)
      exact h ⟨p, hp, hpA, prime_dvd_AC_implies_dvd_B s hp hpA hpC, hpC⟩
    have hbc : Nat.Coprime s.b s.c := by
      rw [Nat.coprime_iff_gcd_eq_one]
      by_contra hg
      obtain ⟨p, hp, hpg⟩ := Nat.exists_prime_and_dvd hg
      have hpB := Nat.dvd_trans hpg (Nat.gcd_dvd_left s.b s.c)
      have hpC := Nat.dvd_trans hpg (Nat.gcd_dvd_right s.b s.c)
      exact h ⟨p, hp, prime_dvd_BC_implies_dvd_A s hp hpB hpC, hpB, hpC⟩
    exact ⟨hab, hac, hbc⟩

/-- Beal's conjecture is equivalent to nonexistence of a primitive solution. -/
theorem beal_iff_no_primitive_solution :
    BealConjecture ↔ ¬ ∃ s : BealSolution, IsPrimitive s := by
  constructor
  · intro h ⟨s, hs⟩
    exact (primitive_iff_no_common_prime s).1 hs (h s)
  · intro h s
    by_contra hs
    exact h ⟨s, (primitive_iff_no_common_prime s).2 hs⟩

/-- The signature condition in the Fermat--Catalan problem. -/
def FermatCatalanSignature (x y z : ℕ) : Prop :=
  (1 / (x : ℚ)) + 1 / (y : ℚ) + 1 / (z : ℚ) ≤ 1

/-- Every Beal exponent triple lies on or below the Fermat--Catalan signature boundary. -/
theorem beal_signature_is_fermat_catalan (s : BealSolution) :
    FermatCatalanSignature s.x s.y s.z := by
  have hxq : (3 : ℚ) ≤ s.x := by exact_mod_cast s.x_gt_two
  have hyq : (3 : ℚ) ≤ s.y := by exact_mod_cast s.y_gt_two
  have hzq : (3 : ℚ) ≤ s.z := by exact_mod_cast s.z_gt_two
  have hxi : (1 / (s.x : ℚ)) ≤ 1 / 3 :=
    one_div_le_one_div_of_le (by norm_num) hxq
  have hyi : (1 / (s.y : ℚ)) ≤ 1 / 3 :=
    one_div_le_one_div_of_le (by norm_num) hyq
  have hzi : (1 / (s.z : ℚ)) ≤ 1 / 3 :=
    one_div_le_one_div_of_le (by norm_num) hzq
  unfold FermatCatalanSignature
  linarith

/-- A strong primitive Fermat--Catalan exclusion implies Beal's conjecture.
The premise is deliberately explicit: proving it is at least as difficult as the
corresponding open Diophantine problem. -/
theorem fermat_catalan_exclusion_implies_beal
    (hFC : ∀ s : BealSolution, FermatCatalanSignature s.x s.y s.z → ¬ IsPrimitive s) :
    BealConjecture := by
  intro s
  by_contra hs
  exact hFC s (beal_signature_is_fermat_catalan s) ((primitive_iff_no_common_prime s).2 hs)

/-- An additive coprime triple, the arithmetic input shape of the abc conjecture. -/
structure ABCTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  a_pos : 0 < a
  b_pos : 0 < b
  c_pos : 0 < c
  coprime : Nat.Coprime a b
  equation : a + b = c

/-- A primitive Beal candidate canonically determines an abc triple of powered terms. -/
def BealSolution.toABCTriple (s : BealSolution) (hs : IsPrimitive s) : ABCTriple where
  a := s.a ^ s.x
  b := s.b ^ s.y
  c := s.c ^ s.z
  a_pos := pow_pos s.a_pos _
  b_pos := pow_pos s.b_pos _
  c_pos := pow_pos s.c_pos _
  coprime := hs.1.pow _ _
  equation := s.equation

/-- The abc bridge preserves the equation and records all three powered terms. -/
theorem toABCTriple_coordinates (s : BealSolution) (hs : IsPrimitive s) :
    let t := s.toABCTriple hs
    t.a = s.a ^ s.x ∧ t.b = s.b ^ s.y ∧ t.c = s.c ^ s.z ∧ t.a + t.b = t.c := by
  refine ⟨rfl, rfl, rfl, ?_⟩
  exact s.equation

/-- A formulation of the abc consequence actually needed for Beal: no powered abc
triple arising from exponents above two can have pairwise-coprime bases. -/
def ABCPoweredExclusion : Prop :=
  ∀ s : BealSolution, IsPrimitive s → False

/-- The powered-triple consequence of abc would imply Beal. -/
theorem abc_powered_exclusion_implies_beal (hABC : ABCPoweredExclusion) :
    BealConjecture := by
  intro s
  by_contra h
  exact hABC s ((primitive_iff_no_common_prime s).2 h)

/-- If two bases are Fibonacci numbers in a primitive Beal candidate, strong
divisibility forces the Fibonacci number at the gcd of their indices to be one. -/
theorem fibonacci_base_index_gcd_constraint (s : BealSolution) (hs : IsPrimitive s)
    (m n : ℕ) (hA : s.a = Nat.fib m) (hB : s.b = Nat.fib n) :
    Nat.fib (Nat.gcd m n) = 1 := by
  have hcop : Nat.Coprime (Nat.fib m) (Nat.fib n) := by simpa [← hA, ← hB] using hs.1
  rw [← Catalog.ProofAutomation.Fibonacci.Fib_gcd_identity]
  exact hcop.gcd_eq_one

end BealResearch