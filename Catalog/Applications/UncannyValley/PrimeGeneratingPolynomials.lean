import Mathlib

/-!
# The Uncanny Valley of Prime-Generating Formulas

A recurring illusion in number theory is the *prime-generating polynomial*: a
simple algebraic expression that produces a long, unbroken run of primes and
therefore *looks* like a formula for the primes.  The most famous example is
Euler's polynomial `n² + n + 41`, which is prime for every one of the forty
inputs `n = 0, 1, …, 39`.  A formula this accurate is squarely in the *uncanny
valley*: it is almost, but not quite, a genuine prime formula.

This file explains *why* every such formula must eventually fail.  The central
result is a clean structural obstruction:

* `UncannyValley.no_prime_generating_polynomial` — **no nonconstant integer
  polynomial takes a prime value at every integer input.**

The proof turns on the divisibility identity `f(a) ∣ f(a + k·f(a))`, isolated as
`UncannyValley.eval_dvd_eval_shift`.  If `f(a) = p` is prime, then `p` divides
`f(a + k·p)` for *every* `k`; since each of those values is itself prime, they
are all forced into the two-element set `{p, -p}`.  An infinite family of inputs
mapping into a finite set of values would make `f` constant, a contradiction.

We then return to the motivating example and exhibit both faces of the uncanny
valley for Euler's polynomial:

* `UncannyValley.euler_prime_run` — it is prime for all `n = 0, …, 39`;
* `UncannyValley.euler_not_prime_at_40` — it fails at the very next input,
  where `40² + 40 + 41 = 41²`;
* `UncannyValley.euler_polynomial_not_prime_generating` — the general theorem,
  specialised to Euler's polynomial, guarantees a failure must exist.
-/

namespace UncannyValley

open Polynomial

/-- **The divisibility engine.**  For an integer polynomial `f` and any integers
`a, k`, the value `f(a)` divides `f(a + k · f(a))`.  This is the arithmetic
progression that dooms every prime-generating formula: starting from a value
`f(a)`, we can reach infinitely many inputs on which `f` is divisible by it. -/
lemma eval_dvd_eval_shift (f : ℤ[X]) (a k : ℤ) :
    f.eval a ∣ f.eval (a + k * f.eval a) := by
  have := Polynomial.sub_dvd_eval_sub ( a + k * eval a f ) a f; simp_all +decide ;
  simpa using dvd_of_mul_left_dvd this

/-- A prime dividing a prime, over `ℤ`, forces equality up to sign. -/
lemma prime_dvd_prime_eq (p q : ℤ) (hp : Prime p) (hq : Prime q) (h : p ∣ q) :
    q = p ∨ q = -p := by
  obtain ⟨ k, hk ⟩ := h;
  simp_all +decide [ Int.prime_iff_natAbs_prime, Int.natAbs_mul, Nat.prime_mul_iff ];
  rw [ Int.natAbs_eq_iff ] at hq ; aesop

/-- **Main theorem — no formula escapes the uncanny valley.**  There is no
nonconstant polynomial with integer coefficients whose value is prime at every
integer input.  Equivalently: any algebraic expression that appears to be a
"formula for the primes" must produce a composite (or unit) value somewhere. -/
theorem no_prime_generating_polynomial (f : ℤ[X])
    (hnonconst : ∀ c : ℤ, f ≠ C c)
    (hprime : ∀ n : ℤ, Prime (f.eval n)) : False := by
  obtain ⟨a, ha⟩ : ∃ a : ℤ, f.eval a ≠ 0 ∧ f.eval a ≠ 1 ∧ f.eval a ≠ -1 := by
    simp_all +decide [ Int.prime_iff_natAbs_prime ];
    exact ⟨ 0, by specialize hprime 0; aesop_cat, by specialize hprime 0; aesop_cat, by specialize hprime 0; aesop_cat ⟩;
  -- Consider the sequence $a + k \cdot f(a)$ for $k = 0, 1, 2, \ldots$
  have h_seq : ∀ k : ℤ, f.eval (a + k * f.eval a) = f.eval a ∨ f.eval (a + k * f.eval a) = -f.eval a := by
    intro k;
    exact prime_dvd_prime_eq _ _ ( hprime _ ) ( hprime _ ) ( eval_dvd_eval_shift _ _ _ );
  -- Since $f$ is nonconstant, the set $\{a + k \cdot f(a) \mid k \in \mathbb{Z}\}$ is infinite.
  have h_infinite : Set.Infinite {x : ℤ | f.eval x = f.eval a ∨ f.eval x = -f.eval a} := by
    exact Set.infinite_of_injective_forall_mem ( fun k => by aesop ) h_seq;
  -- Since $f$ is nonconstant, the polynomial $f - C(f(a))$ or $f + C(f(a))$ must be the zero polynomial.
  have h_zero_poly : f - Polynomial.C (f.eval a) = 0 ∨ f + Polynomial.C (f.eval a) = 0 := by
    exact Classical.or_iff_not_imp_left.2 fun h => Classical.not_not.1 fun h' => h_infinite <| Set.Finite.subset ( f - C ( eval a f ) |> Polynomial.roots |> Multiset.toFinset |> Finset.finite_toSet |> Set.Finite.union <| f + C ( eval a f ) |> Polynomial.roots |> Multiset.toFinset |> Finset.finite_toSet ) fun x hx => by simp_all +decide [ sub_eq_iff_eq_add, add_eq_zero_iff_eq_neg ] ;
  cases' h_zero_poly with h h <;> [ exact hnonconst ( f.eval a ) ( sub_eq_zero.mp h ) ; exact hnonconst ( -f.eval a ) ( by simpa using eq_neg_of_add_eq_zero_left h ) ]

/-
**Strengthening — the valley has infinite width.**  A nonconstant integer
polynomial is not merely doomed to fail somewhere: it takes a non-prime value at
*infinitely many* integer inputs.  No matter how the formula is tuned, the set of
inputs on which the prime illusion breaks is infinite.
-/
theorem infinitely_many_non_prime (f : ℤ[X]) (hnonconst : ∀ c : ℤ, f ≠ C c) :
    {n : ℤ | ¬ Prime (f.eval n)}.Infinite := by
  contrapose! hnonconst;
  -- Let $p := f.eval a$; then $p ≠ 0$.
  obtain ⟨a, ha⟩ : ∃ a : ℤ, Prime (f.eval a) ∧ f.eval a ≠ 0 := by
    exact Exists.elim ( Set.Infinite.nonempty ( Set.Infinite.diff ( Set.Ioi_infinite 0 ) hnonconst ) ) fun x hx => ⟨ x, by aesop, by aesop ⟩;
  -- Then there are infinitely many integers $n$ such that $f(n) = p$ or $f(n) = -p$.
  have h_inf : {n : ℤ | f.eval n = f.eval a ∨ f.eval n = -f.eval a}.Infinite := by
    have h_inf : Set.Infinite {n : ℤ | ∃ k : ℤ, n = a + k * f.eval a ∧ Prime (f.eval n)} := by
      have h_inf : Set.Infinite {n : ℤ | ∃ k : ℤ, n = a + k * f.eval a} := by
        exact Set.infinite_of_injective_forall_mem ( fun x y hxy => by aesop ) fun x => ⟨ x, rfl ⟩;
      exact Set.Infinite.mono ( by aesop_cat ) ( h_inf.diff hnonconst );
    refine h_inf.mono ?_;
    simp +zetaDelta at *;
    exact fun n hn => prime_dvd_prime_eq _ _ ha.1 hn ( eval_dvd_eval_shift f a n );
  -- Since $f$ is a polynomial with integer coefficients, if $f(n) = p$ or $f(n) = -p$ for infinitely many $n$, then $f$ must be constant.
  have h_const : f = Polynomial.C (f.eval a) ∨ f = Polynomial.C (-f.eval a) := by
    exact Classical.or_iff_not_imp_left.2 fun h => Classical.not_not.1 fun h' => h_inf <| Set.Finite.subset ( f - Polynomial.C ( eval a f ) |> Polynomial.roots |> Multiset.toFinset |> Finset.finite_toSet |> Set.Finite.union <| f + Polynomial.C ( eval a f ) |> Polynomial.roots |> Multiset.toFinset |> Finset.finite_toSet ) fun x hx => by simp_all +decide [ sub_eq_iff_eq_add, add_eq_zero_iff_eq_neg ] ;
  exact h_const.elim ( fun h => ⟨ _, h ⟩ ) fun h => ⟨ _, h ⟩

/-! ### Euler's polynomial `n² + n + 41` — a tour of the uncanny valley -/

/-- Euler's celebrated prime-generating polynomial, as an integer polynomial. -/
noncomputable def eulerPoly : ℤ[X] := X ^ 2 + X + C 41

@[simp] lemma eulerPoly_eval (n : ℤ) : eulerPoly.eval n = n ^ 2 + n + 41 := by
  simp only [eulerPoly, eval_add, eval_pow, eval_X, eval_C]

/-- Euler's polynomial has degree `2`, hence is nonconstant. -/
lemma eulerPoly_not_const (c : ℤ) : eulerPoly ≠ C c := by
  unfold eulerPoly;
  exact ne_of_apply_ne ( fun p => p.coeff 2 ) ( by norm_num [ Polynomial.coeff_eq_zero_of_natDegree_lt ] )

/-- **The illusion.**  Euler's polynomial is prime for every one of the forty
inputs `n = 0, 1, …, 39` — an astonishing run that makes it *look* like a prime
formula. -/
lemma euler_prime_run (n : ℕ) (hn : n < 40) : Nat.Prime (n ^ 2 + n + 41) := by
  interval_cases n <;> norm_num

/-- **The reveal.**  At the very next input the illusion collapses:
`40² + 40 + 41 = 41²` is composite. -/
lemma euler_not_prime_at_40 : ¬ Nat.Prime (40 ^ 2 + 40 + 41) := by
  norm_num

/-- The general obstruction, specialised: Euler's polynomial cannot be prime at
every integer input.  (The concrete witness is `n = 40`.) -/
theorem euler_polynomial_not_prime_generating :
    ¬ (∀ n : ℤ, Prime (eulerPoly.eval n)) := by
  intro h
  exact no_prime_generating_polynomial eulerPoly eulerPoly_not_const h

end UncannyValley