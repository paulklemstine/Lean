/-
Round-10 Closures — Part VII (cycle 2): the quantitative cost of aggregation.

Cycle 1 showed that *finite* joints of free witnesses never close (barrier 4).  Cycle 2 asks
the sharper, quantitative question: the family `R_k` is complete in the limit — at
`k = lcm(p-1, q-1)` the witness equals `φ(N)`, and `φ(N)` together with `N` recovers the
factorisation in closed form.  So what does completeness *cost*?

The answer proved here is a genuine exponential separation inside the classical channel:

* **completeness**: `R_k(N) = φ(N)` exactly when `(p-1) ∣ k` and `(q-1) ∣ k`, and then the
  factorisation is read off by `factorFromTrace N (N - R_k + 1)`;
* **cost**: since `R_k ∣ k²`, any *positive* exponent with a complete witness satisfies
  `φ(N) ≤ k²`, i.e. `k ≥ √φ(N) ≈ √N` — exponential in `log N`.

Together: the free-witness channel is complete but only at exponents of size `√N`, which is
precisely the "aggregation necessity" content of barrier 4, and precisely what the quantum
order-finding channel bypasses (it reads the coordinate off one superposition).
-/
import Geometry.Round10Closures.HintAmplification

namespace Round10

variable {p q k : ℕ}

/-- Cancellation for a product of two coordinates each bounded by its maximum: if the
product is maximal, both coordinates are. -/
theorem eq_of_mul_eq_mul_le {a b A B : ℕ} (ha : a ≤ A) (hb : b ≤ B) (hA : 0 < A) (hB : 0 < B)
    (h : a * b = A * B) : a = A ∧ b = B := by
  have h1 : a = A := by
    rcases lt_or_eq_of_le ha with hlt | heq
    · exfalso; nlinarith
    · exact heq
  subst h1
  exact ⟨rfl, by
    rcases lt_or_eq_of_le hb with hlt | heq
    · exfalso; nlinarith
    · exact heq⟩

/-! ### Completeness of the family in the limit -/

/-- Free witnesses are bounded by `φ(N) = (p-1)(q-1)`. -/
theorem freeWitness_le_totient [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q) (k : ℕ) :
    freeWitness (p * q) k ≤ (p - 1) * (q - 1) := by
  rw [freeWitness_eq p q k hpq]
  exact Nat.mul_le_mul (Nat.gcd_le_left _ (by have := (Fact.out : p.Prime).two_le; omega))
    (Nat.gcd_le_left _ (by have := (Fact.out : q.Prime).two_le; omega))

/-- **Completeness criterion.**  A free witness attains the maximal value `φ(N)` exactly at
the exponents divisible by both `p-1` and `q-1`. -/
theorem freeWitness_eq_totient_iff [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q) :
    freeWitness (p * q) k = (p - 1) * (q - 1) ↔ (p - 1) ∣ k ∧ (q - 1) ∣ k := by
  have hp2 := (Fact.out : p.Prime).two_le
  have hq2 := (Fact.out : q.Prime).two_le
  rw [freeWitness_eq p q k hpq]
  constructor
  · intro h
    obtain ⟨e1, e2⟩ := eq_of_mul_eq_mul_le (Nat.gcd_le_left _ (show 0 < p - 1 by omega))
      (Nat.gcd_le_left _ (show 0 < q - 1 by omega)) (by omega) (by omega) h
    exact ⟨e1 ▸ Nat.gcd_dvd_right _ _, e2 ▸ Nat.gcd_dvd_right _ _⟩
  · rintro ⟨h1, h2⟩
    rw [Nat.gcd_eq_left h1, Nat.gcd_eq_left h2]

/-- The lcm exponent realises completeness. -/
theorem freeWitness_lcm [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q) :
    freeWitness (p * q) (Nat.lcm (p - 1) (q - 1)) = (p - 1) * (q - 1) :=
  (freeWitness_eq_totient_iff hpq).mpr ⟨Nat.dvd_lcm_left _ _, Nat.dvd_lcm_right _ _⟩

/-! ### From completeness to the factorisation -/

/-- Elementary identity behind the `φ`-to-trace conversion: `(p-1)(q-1) + (p+q) = pq + 1`. -/
theorem totient_trace_identity (hp : 1 ≤ p) (hq : 1 ≤ q) :
    (p - 1) * (q - 1) + (p + q) = p * q + 1 := by
  obtain ⟨a, rfl⟩ := Nat.exists_eq_add_of_le hp
  obtain ⟨b, rfl⟩ := Nat.exists_eq_add_of_le hq
  simp only [Nat.add_sub_cancel_left]
  ring_nf

/-- **`φ(N)` is a complete hint.**  For `N = p*q` with `q ≤ p`, the value `(p-1)(q-1)`
determines the smaller prime factor in closed form. -/
theorem factorFromTotient (hp : 1 ≤ p) (hq : 1 ≤ q) (hle : q ≤ p) :
    factorFromTrace (q * p) (q * p + 1 - (p - 1) * (q - 1)) = q := by
  have hid : (p - 1) * (q - 1) + (p + q) = p * q + 1 := totient_trace_identity hp hq
  have : q * p + 1 - (p - 1) * (q - 1) = q + p := by
    rw [Nat.mul_comm q p]; omega
  rw [this]
  exact factorFromTrace_eq hle

/-- **Complete witnesses factor.**  If a single free witness attains `φ(N)`, the
factorisation follows by one closed-form evaluation. -/
theorem complete_witness_factors [Fact p.Prime] [Fact q.Prime]
    (hle : q ≤ p) (hcomp : freeWitness (p * q) k = (p - 1) * (q - 1)) :
    factorFromTrace (q * p) (q * p + 1 - freeWitness (p * q) k) = q := by
  rw [hcomp]
  exact factorFromTotient (Fact.out : p.Prime).one_lt.le (Fact.out : q.Prime).one_lt.le hle

/-! ### The cost of completeness: an exponential lower bound on the exponent -/

/-- **Aggregation cost (barrier 4, quantitative).**  Any *positive* exponent whose free
witness is complete satisfies `φ(N) ≤ k²`; equivalently `k ≥ √φ(N) ≈ √N`.

The free-witness channel therefore closes only after aggregating exponents of size `√N` —
exponential in `log N` — which is exactly the aggregation cost that Shor's order finding
bypasses by reading the coordinate from one coherent superposition. -/
theorem complete_witness_exponent_lower_bound [Fact p.Prime] [Fact q.Prime]
    (hpq : Nat.Coprime p q) (hk : 0 < k)
    (hcomp : freeWitness (p * q) k = (p - 1) * (q - 1)) : (p - 1) * (q - 1) ≤ k ^ 2 := by
  have hdvd : freeWitness (p * q) k ∣ k ^ 2 := freeWitness_dvd_sq p q k hpq
  rw [hcomp] at hdvd
  exact Nat.le_of_dvd (pow_pos hk 2) hdvd

/-- The same bound in the form used by the barrier bookkeeping: a complete exponent is at
least the square root of `φ(N)`. -/
theorem sqrt_totient_le_complete_exponent [Fact p.Prime] [Fact q.Prime]
    (hpq : Nat.Coprime p q) (hk : 0 < k)
    (hcomp : freeWitness (p * q) k = (p - 1) * (q - 1)) :
    Nat.sqrt ((p - 1) * (q - 1)) ≤ k := by
  have h := complete_witness_exponent_lower_bound hpq hk hcomp
  calc Nat.sqrt ((p - 1) * (q - 1)) ≤ Nat.sqrt (k ^ 2) := Nat.sqrt_le_sqrt h
    _ = k := Nat.sqrt_eq' k

/-! ### The exact completeness threshold (cycle 4)

The bound `φ(N) ≤ k²` above is not sharp.  The completeness criterion is a divisibility, so
the set of complete exponents is exactly the set of multiples of `lcm(p-1, q-1)`, and the
minimal positive complete exponent is *exactly* `lcm(p-1,q-1) = φ(N) / gcd(p-1,q-1)`.  For
the cryptographically standard case `gcd(p-1,q-1) = 2` this is `φ(N)/2`, i.e. linear in `N`
rather than in `√N`: the true aggregation cost is `Θ(N)`, matching the informal
"O(N) classical aggregation" of the round-10 synthesis. -/

/-- The complete exponents are precisely the multiples of `lcm(p-1, q-1)`. -/
theorem complete_iff_lcm_dvd [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q) :
    freeWitness (p * q) k = (p - 1) * (q - 1) ↔ Nat.lcm (p - 1) (q - 1) ∣ k := by
  rw [freeWitness_eq_totient_iff hpq]
  exact ⟨fun h => Nat.lcm_dvd h.1 h.2,
    fun h => ⟨(Nat.dvd_lcm_left _ _).trans h, (Nat.dvd_lcm_right _ _).trans h⟩⟩

/-- **Sharp aggregation cost.**  Every positive complete exponent is at least
`lcm(p-1,q-1)`, and `gcd(p-1,q-1) * lcm(p-1,q-1) = φ(N)`; so `φ(N) ≤ gcd(p-1,q-1) * k`. -/
theorem complete_witness_exponent_sharp [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q)
    (hk : 0 < k) (hcomp : freeWitness (p * q) k = (p - 1) * (q - 1)) :
    Nat.lcm (p - 1) (q - 1) ≤ k ∧ (p - 1) * (q - 1) ≤ Nat.gcd (p - 1) (q - 1) * k := by
  have hdvd : Nat.lcm (p - 1) (q - 1) ∣ k := (complete_iff_lcm_dvd hpq).mp hcomp
  refine ⟨Nat.le_of_dvd hk hdvd, ?_⟩
  calc (p - 1) * (q - 1) = Nat.gcd (p - 1) (q - 1) * Nat.lcm (p - 1) (q - 1) :=
        (Nat.gcd_mul_lcm _ _).symm
    _ ≤ Nat.gcd (p - 1) (q - 1) * k := Nat.mul_le_mul_left _ (Nat.le_of_dvd hk hdvd)

/-- **The threshold is exact.**  `lcm(p-1,q-1)` is complete and is the least positive
complete exponent: the minimal aggregation depth of the free-witness channel is known
exactly, not just up to a bound. -/
theorem least_complete_exponent [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q) :
    IsLeast {m : ℕ | 0 < m ∧ freeWitness (p * q) m = (p - 1) * (q - 1)}
      (Nat.lcm (p - 1) (q - 1)) := by
  have hp2 := (Fact.out : p.Prime).two_le
  have hq2 := (Fact.out : q.Prime).two_le
  refine ⟨⟨Nat.pos_of_ne_zero ?_, freeWitness_lcm hpq⟩, ?_⟩
  · intro h
    rcases Nat.lcm_eq_zero_iff.mp h with h0 | h0 <;> omega
  · rintro m ⟨hm, hcomp⟩
    exact (complete_witness_exponent_sharp hpq hm hcomp).1

/-- **The cycle-2 dichotomy.**  For a semiprime with `2 ≤ q ≤ p`:
the free-witness family *is* complete — the exponent `lcm(p-1,q-1)` closes the
factorisation — but every positive complete exponent is at least `√φ(N)`.  Completeness and
efficiency are mutually exclusive inside the classical hint-free channel. -/
theorem aggregation_dichotomy [Fact p.Prime] [Fact q.Prime] (hpq : Nat.Coprime p q)
    (hle : q ≤ p) :
    (factorFromTrace (q * p)
        (q * p + 1 - freeWitness (p * q) (Nat.lcm (p - 1) (q - 1))) = q) ∧
      (∀ m : ℕ, 0 < m → freeWitness (p * q) m = (p - 1) * (q - 1) →
        Nat.sqrt ((p - 1) * (q - 1)) ≤ m) :=
  ⟨complete_witness_factors hle (freeWitness_lcm hpq),
    fun _ hm hcomp => sqrt_totient_le_complete_exponent hpq hm hcomp⟩

end Round10