/-
Round-10 Closures — umbrella module.

The formal content of the round-10 batch synthesis, in seven parts:

* `TraceLemma`       — `R_k(N) = gcd(k,p-1)·gcd(k,q-1)` for semiprimes (the trace lemma);
* `JointClosure`     — joints of free witnesses never close (barrier 4), via Dirichlet;
* `RainbowWalk`      — the smooth-step walk emits no gcd signal (barrier 8/5);
* `QuantumBypass`    — the residue/order coordinate does factor, constructively;
* `HintAmplification`— an external trace hint amplifies to the factorisation in closed form;
* `AggregationCost`  — completeness of the family costs exponents of size `√φ(N)`;
* `SquarefreeTrace`  — the trace lemma for all squarefree moduli, `2^ω(N)` square roots;
* `CarmichaelThreshold` — for every odd modulus the aggregation depth is exactly `λ(N)`.

`Synthesis` assembles the four round-10 verdicts into one capstone theorem; the final
theorem below adds the two later cycles to it.
-/
import Geometry.Round10Closures.Synthesis
import Geometry.Round10Closures.AggregationCost
import Geometry.Round10Closures.SquarefreeTrace
import Geometry.Round10Closures.CarmichaelThreshold

namespace Round10

/-- **Exhaustion of the classical uniform hint-free surface (formal core).**
For a semiprime `N = q * p` with distinct odd primes `q < p`:

1. no aggregator of the joint free-witness profile over a finite exponent set returns a
   prime factor;
2. the family nevertheless *is* complete — the exponent `lcm(p-1,q-1)` closes the
   factorisation — but every positive complete exponent is at least `√φ(N)`;
3. one residue/order coordinate (a nontrivial square root of unity) closes it immediately.

(1) and (2) are the two halves of barrier 4 — impossibility below the threshold,
possibility only at exponential exponent size — and (3) is the coordinate the quantum
channel reads in one shot.  The barrier is aggregation, not the trace lemma. -/
theorem round10_exhaustion {p q : ℕ} [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q)
    (hp2 : p ≠ 2) (hq2 : q ≠ 2) (hqp : q < p) (S : Finset ℕ) (hS : ∀ k ∈ S, 0 < k) :
    (¬ ∃ F : (ℕ → ℕ) → ℕ, ∀ r : ℕ, r.Prime → q < r → F (profile S (r * q)) = r) ∧
    (factorFromTrace (q * p)
        (q * p + 1 - freeWitness (p * q) (Nat.lcm (p - 1) (q - 1))) = q ∧
      ∀ m : ℕ, 0 < m → freeWitness (p * q) m = (p - 1) * (q - 1) →
        Nat.sqrt ((p - 1) * (q - 1)) ≤ m) ∧
    (∃ a : ℤ, ((p * q : ℕ) : ℤ) ∣ a ^ 2 - 1 ∧
      ¬ ((p * q : ℕ) : ℤ) ∣ (a - 1) ∧ ¬ ((p * q : ℕ) : ℤ) ∣ (a + 1) ∧
      (Int.gcd (a - 1) ((p * q : ℕ) : ℤ) = p ∨ Int.gcd (a - 1) ((p * q : ℕ) : ℤ) = q)) :=
  ⟨no_profile_extractor S hS Fact.out,
    aggregation_dichotomy hpq hqp.le,
    residue_witness_factors hpq hp2 hq2⟩

end Round10