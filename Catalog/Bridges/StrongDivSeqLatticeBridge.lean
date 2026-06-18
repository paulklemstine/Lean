import Mathlib
import Bridges.StrongDivisibilitySequences

/-! # The lattice bridge for strong divisibility sequences

Domain: Bridges / Conceptual unification (number theory ↔ lattice theory).

A **strong divisibility sequence** (`StrongDivSeq`, see
`Catalog/Bridges/StrongDivisibilitySequences.lean`) is a sequence `a : ℕ → ℕ` with
`a 0 = 0` and `gcd (a m) (a n) = a (gcd m n)`.  The earlier file develops the
primitive-divisor / entry-point theory.  Here we develop the **order-theoretic**
side of the same axioms: a strong divisibility sequence is a *meet-preserving,
join-subhomomorphism* of the divisibility lattice `(ℕ, ∣, gcd, lcm)`.

Main generic results (all over `s : StrongDivSeq`):

* `StrongDivSeq.gcd_indices_coprime`  — coprime indices give `gcd (a m) (a n) = a 1`.
* `StrongDivSeq.coprime_of_coprime`   — if `a 1 = 1`, coprime indices give coprime values.
* `StrongDivSeq.lcm_dvd_index`        — `lcm (a m) (a n) ∣ a (lcm m n)` (join is preserved
  only up to divisibility — the map is *not* a full lattice homomorphism).
* `StrongDivSeq.pairwise_coprime`     — if `a 1 = 1`, pairwise-coprime indices give
  pairwise-coprime values.
* `StrongDivSeq.prod_dvd_index`       — if `a 1 = 1`, for pairwise-coprime indices
  `∏ a (g i) ∣ a (∏ g i)`.

Cross-domain corollaries (Fibonacci / Mersenne):

* `fib_coprime_of_coprime`   — `Coprime m n → Coprime (fib m) (fib n)` (new package).
* `fib_lcm_dvd`              — `lcm (fib m) (fib n) ∣ fib (lcm m n)`.
* `fib_prod_dvd`             — pairwise-coprime indices ⇒ `∏ fib (g i) ∣ fib (∏ g i)`.
* `mersenne_gcd_coprime`     — coprime indices ⇒ `gcd (b^m - 1) (b^n - 1) = b - 1`.

!-- Lab Notes -- !--
Hypothesis: the primitive-divisor file uses only the *meet* law `gcd (a m)(a n)=a(gcd m n)`.
The dual *join* law cannot hold on the nose (`a` need not be multiplicative), but the
divisibility inequality `lcm (a m)(a n) ∣ a (lcm m n)` should follow purely from monotonicity
`m ∣ n → a m ∣ a n` (`StrongDivSeq.dvd_of_dvd`).  Tested numerically on Fibonacci:
`lcm (fib 4)(fib 6) = 24 ∣ fib 12 = 144`; `lcm (fib 2)(fib 3) = 2 ∣ fib 6 = 8`. ✓
Result: confirmed; the meet law is an *equality*, the join law a *divisibility*, exhibiting
`StrongDivSeq` as a lattice meet-homomorphism / join-sub-homomorphism.
Insight: coprimality propagates through `a` exactly when `a 1 = 1` (the lattice top `1`
must map to the divisibility top `1`).  Fibonacci satisfies this (`fib 1 = 1`); Mersenne does
not (`b^1 - 1 = b - 1`), which is *why* `gcd (b^m-1)(b^n-1) = b-1` rather than `1` for coprime
`m, n` — the residual `b - 1` is exactly `a 1`.
Failure analysis: `IsCoprime` (ring-theoretic) is strictly stronger than `Nat.Coprime` on ℕ,
so the generic product lemma must route through `IsRelPrime` via `Nat.coprime_iff_isRelPrime`
and `Finset.prod_dvd_of_isRelPrime` (ℕ is a `DecompositionMonoid`).
!-- End Lab Notes -- !--
-/

namespace StrongDivSeq

variable (s : StrongDivSeq)

/-! ## §1. The meet law specialised to coprime indices -/

/-- For coprime indices, `gcd (a m) (a n) = a 1`: the meet collapses to the value at the
lattice top `1`. -/
theorem gcd_indices_coprime {m n : ℕ} (h : Nat.Coprime m n) :
    Nat.gcd (s.a m) (s.a n) = s.a 1 := by
  rw [s.gcd_eq]; rw [h]

/-- If `a 1 = 1`, coprime indices yield coprime values. -/
theorem coprime_of_coprime (h1 : s.a 1 = 1) {m n : ℕ} (h : Nat.Coprime m n) :
    Nat.Coprime (s.a m) (s.a n) := by
  unfold Nat.Coprime
  rw [s.gcd_indices_coprime h, h1]

/-! ## §2. The join law (divisibility only) -/

/-- The join law: `lcm (a m) (a n) ∣ a (lcm m n)`.  Unlike the meet law this is a strict
divisibility, witnessing that `a` is only a *join-sub-homomorphism*. -/
theorem lcm_dvd_index (m n : ℕ) :
    Nat.lcm (s.a m) (s.a n) ∣ s.a (Nat.lcm m n) :=
  Nat.lcm_dvd (s.dvd_of_dvd (Nat.dvd_lcm_left m n))
    (s.dvd_of_dvd (Nat.dvd_lcm_right m n))

/-! ## §3. Pairwise coprimality and products -/

/-- If `a 1 = 1`, pairwise-coprime indices yield pairwise-coprime values. -/
theorem pairwise_coprime (h1 : s.a 1 = 1) {ι : Type*} (t : Finset ι) (g : ι → ℕ)
    (hg : (t : Set ι).Pairwise (Function.onFun Nat.Coprime g)) :
    (t : Set ι).Pairwise (Function.onFun Nat.Coprime (fun i => s.a (g i))) := by
  intro i hi j hj hij
  exact s.coprime_of_coprime h1 (hg hi hj hij)

/-- If `a 1 = 1`, then for pairwise-coprime indices the product of values divides the value
at the product of indices: `∏ a (g i) ∣ a (∏ g i)`. -/
theorem prod_dvd_index (h1 : s.a 1 = 1) {ι : Type*} (t : Finset ι) (g : ι → ℕ)
    (hg : (t : Set ι).Pairwise (Function.onFun Nat.Coprime g)) :
    (∏ i ∈ t, s.a (g i)) ∣ s.a (∏ i ∈ t, g i) := by
  apply Finset.prod_dvd_of_isRelPrime
  · intro i hi j hj hij
    exact Nat.coprime_iff_isRelPrime.mp (s.coprime_of_coprime h1 (hg hi hj hij))
  · intro i hi
    exact s.dvd_of_dvd (Finset.dvd_prod_of_mem g hi)

end StrongDivSeq

/-! ## §4. Fibonacci corollaries (`fib 1 = 1`) -/

/-- **Coprime Fibonacci indices give coprime Fibonacci numbers.** -/
theorem fib_coprime_of_coprime {m n : ℕ} (h : Nat.Coprime m n) :
    Nat.Coprime (Nat.fib m) (Nat.fib n) :=
  fibSDS.coprime_of_coprime Nat.fib_one h

/-- **Fibonacci join law**: `lcm (fib m) (fib n) ∣ fib (lcm m n)`. -/
theorem fib_lcm_dvd (m n : ℕ) :
    Nat.lcm (Nat.fib m) (Nat.fib n) ∣ Nat.fib (Nat.lcm m n) :=
  fibSDS.lcm_dvd_index m n

/-- **Fibonacci product law**: for pairwise-coprime indices,
`∏ fib (g i) ∣ fib (∏ g i)`. -/
theorem fib_prod_dvd {ι : Type*} (t : Finset ι) (g : ι → ℕ)
    (hg : (t : Set ι).Pairwise (Function.onFun Nat.Coprime g)) :
    (∏ i ∈ t, Nat.fib (g i)) ∣ Nat.fib (∏ i ∈ t, g i) :=
  fibSDS.prod_dvd_index Nat.fib_one t g hg

/-! ## §5. Mersenne corollary (`a 1 = b - 1 ≠ 1`) -/

/-- **Mersenne gcd law**: for coprime indices `m, n`, `gcd (b^m - 1) (b^n - 1) = b - 1`.
The residual `b - 1` is exactly the value `(mersenneSDS b).a 1`, the reason coprimality
does *not* propagate for Mersenne numbers. -/
theorem mersenne_gcd_coprime (b : ℕ) {m n : ℕ} (h : Nat.Coprime m n) :
    Nat.gcd (b ^ m - 1) (b ^ n - 1) = b - 1 := by
  rw [Nat.pow_sub_one_gcd_pow_sub_one b m n, h, pow_one]