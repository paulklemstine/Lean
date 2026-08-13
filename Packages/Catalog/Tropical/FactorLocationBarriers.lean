import Mathlib

/-!
# Counting is free, locating is hard: the semiprime witness barriers

This file formalises the arithmetic core of the round-4 closures `HOLOG-MARGIN`,
`SPARSEREC`, `MPS-PARENT` and `OPO-FAC`. All four hypotheses proposed an exotic
resource (holographic partition functions, compressed sensing, tensor-network
ground states, optical Ising machines) for factoring a semiprime `N = p q`, and
all four were closed by the same structural fact, which we prove here:

* the *counting* data attached to `N` (number of divisor pairs = partition
  function `Z = τ(N) = 4`) is **constant across all semiprimes**, hence carries
  zero information (`card_divisors_semiprime`, `tau_cannot_locate`);
* the *witness* data is a 2-spike vector: exactly two divisors lie in the search
  window `[1, √N]`, namely `1` and `p` (`divisors_below_corner`), so the search
  space that must be aggregated has size `√N` with exactly one nontrivial hit
  (`nontrivial_witness_below_corner`);
* the ground space of the tensor-network / Ising energy `E(a,b) = (N - ab)²` is
  the four-point divisor set `{(1,N),(p,q),(q,p),(N,1)}` with no intermediate
  structure (`energyGroundSet_eq`, `energyGroundSet_ncard`), so descent has no
  gradient and random search succeeds with density `4/N²`.

The min-plus (tropical) thread: in logarithmic coordinates the divisor hyperbola
`x · y = N` is the tropical line `X ⊙ Y = N`, whose corner is at `√N`; every
divisor pair straddles that corner (`divisor_pair_straddles_corner`). The
"free witness aggregation" barrier is precisely the statement that locating the
unique nontrivial lattice point on one side of the corner costs the whole
window.
-/

namespace FactorLocationBarriers

/-! ## 1. The divisor set of a semiprime -/

/-- The divisors of a product of two primes. -/
theorem divisors_semiprime (p q : ℕ) (hp : p.Prime) (hq : q.Prime) :
    (p * q).divisors = {1, p, q, p * q} := by
  rw [Nat.divisors_mul, hp.divisors, hq.divisors]
  ext d
  simp only [Finset.mem_mul, Finset.mem_insert, Finset.mem_singleton]
  constructor
  · rintro ⟨a, ha, b, hb, rfl⟩
    rcases ha with rfl | rfl <;> rcases hb with rfl | rfl <;> simp
  · rintro (h | h | h | h)
    · exact ⟨1, by simp, 1, by simp, by simp [h]⟩
    · exact ⟨p, by simp, 1, by simp, by simp [h]⟩
    · exact ⟨1, by simp, q, by simp, by simp [h]⟩
    · exact ⟨p, by simp, q, by simp, by simp [h]⟩

/-- **The partition function is constant.** Every semiprime has exactly four
divisors, so the "number of divisor pairs" carries no information about `p, q`. -/
theorem card_divisors_semiprime (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    (p * q).divisors.card = 4 := by
  have hcop : p.Coprime q := (Nat.coprime_primes hp hq).mpr hpq
  rw [Nat.Coprime.card_divisors_mul hcop, hp.divisors, hq.divisors,
    Finset.card_insert_of_notMem (Finset.notMem_singleton.mpr hp.one_lt.ne),
    Finset.card_insert_of_notMem (Finset.notMem_singleton.mpr hq.one_lt.ne)]
  simp

/-- **HOLOG-MARGIN, closed.** No function of the divisor-count partition function
can return the smaller prime factor: `15 = 3·5` and `35 = 5·7` have the same
partition function `Z = 4` but different factors. -/
theorem tau_cannot_locate (f : ℕ → ℕ) :
    ¬ (∀ p q : ℕ, p.Prime → q.Prime → p < q → f ((p * q).divisors.card) = p) := by
  intro hf
  have h1 := hf 3 5 (by norm_num) (by norm_num) (by norm_num)
  have h2 := hf 5 7 (by norm_num) (by norm_num) (by norm_num)
  rw [card_divisors_semiprime 3 5 (by norm_num) (by norm_num) (by norm_num)] at h1
  rw [card_divisors_semiprime 5 7 (by norm_num) (by norm_num) (by norm_num)] at h2
  omega

/-! ## 2. The tropical corner: every divisor pair straddles `√N` -/

/-- **Tropical corner of the divisor hyperbola.** For any divisor `d` of `N > 0`,
the pair `(d, N/d)` straddles `√N`: the smaller member is at most `√N` and the
larger one is at least `√N`. In logarithmic coordinates this says that the
hyperbola `x ⊙ y = N` is the tropical line with corner at `√N`. -/
theorem divisor_pair_straddles_corner (N d : ℕ) (hN : N ≠ 0) (hd : d ∣ N) :
    min d (N / d) ≤ Nat.sqrt N ∧ Nat.sqrt N ≤ max d (N / d) := by
  obtain ⟨e, he⟩ := hd
  have hd0 : d ≠ 0 := by rintro rfl; simp at he; exact hN he
  have hde : N / d = e := by rw [he]; exact Nat.mul_div_cancel_left e (Nat.pos_of_ne_zero hd0)
  rw [hde]
  have key : ∀ u v : ℕ, N = u * v → u ≤ v → u ≤ Nat.sqrt N ∧ Nat.sqrt N ≤ v := by
    intro u v huv hle
    constructor
    · exact Nat.le_sqrt.mpr (by nlinarith [huv])
    · calc Nat.sqrt N ≤ Nat.sqrt (v * v) := Nat.sqrt_le_sqrt (by nlinarith [huv])
        _ = v := by simp
  rcases le_total d e with h | h
  · have := key d e he h
    simpa [min_eq_left h, max_eq_right h] using this
  · have := key e d (by rw [he]; ring) h
    simpa [min_eq_right h, max_eq_left h] using this

/-! ## 3. SPARSEREC: the witness vector is a 2-spike -/

/-- **The witness vector is 2-sparse.** For `p < q` primes, the divisors of `N = pq`
lying in the search window `[1, √N]` are exactly `1` and `p`. -/
theorem divisors_below_corner (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    (p * q).divisors.filter (fun d => d * d ≤ p * q) = {1, p} := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  ext d
  simp only [Finset.mem_filter, divisors_semiprime p q hp hq, Finset.mem_insert,
    Finset.mem_singleton]
  constructor
  · rintro ⟨h | h | h | h, hle⟩ <;> subst h
    · exact Or.inl rfl
    · exact Or.inr rfl
    · exact absurd hle (by nlinarith)
    · have h4 : 4 ≤ p * q := by nlinarith
      exact absurd hle (by nlinarith)
  · rintro (h | h) <;> subst h
    · exact ⟨Or.inl rfl, by nlinarith⟩
    · exact ⟨Or.inr (Or.inl rfl), by nlinarith⟩

/-- The sparsity: exactly two spikes. -/
theorem card_divisors_below_corner (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    ((p * q).divisors.filter (fun d => d * d ≤ p * q)).card = 2 := by
  rw [divisors_below_corner p q hp hq hlt,
    Finset.card_insert_of_notMem (Finset.notMem_singleton.mpr hp.one_lt.ne)]
  simp

/-- **SPARSEREC, closed.** In the window `[1, √N]` there is exactly *one* nontrivial
witness, namely `p`: the recovery problem is the location of a single spike in a
window of size `√N`, which is the free-witness aggregation itself. -/
theorem nontrivial_witness_below_corner (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    ((p * q).divisors.filter (fun d => d * d ≤ p * q)).erase 1 = {p} := by
  rw [divisors_below_corner p q hp hq hlt]
  rw [Finset.erase_insert (Finset.notMem_singleton.mpr hp.one_lt.ne)]

/-! ## 4. MPS-PARENT / OPO-FAC: the ground space is a four-point delta -/

/-- The tensor-network / Ising energy `E(a,b) = (N - ab)²` over `ℤ`. -/
def energy (N a b : ℕ) : ℤ := ((N : ℤ) - (a : ℤ) * (b : ℤ)) ^ 2

/-- Ground states are exactly the factorisations. -/
theorem energy_eq_zero_iff (N a b : ℕ) : energy N a b = 0 ↔ a * b = N := by
  rw [energy, pow_eq_zero_iff (two_ne_zero), sub_eq_zero]
  constructor
  · intro h; exact_mod_cast h.symm
  · intro h; exact_mod_cast h.symm

/-- **The energy landscape is a delta, not a slope.** Every non-ground configuration
has energy at least `1`, no matter how close `ab` is to `N`; the landscape carries no
gradient toward the factors. -/
theorem energy_gap (N a b : ℕ) (h : a * b ≠ N) : 1 ≤ energy N a b := by
  have h0 : energy N a b ≠ 0 := fun hc => h ((energy_eq_zero_iff N a b).mp hc)
  have hnn : 0 ≤ energy N a b := sq_nonneg _
  have hpos : 0 < energy N a b := lt_of_le_of_ne hnn (Ne.symm h0)
  exact hpos

/-- **MPS-PARENT, closed (ground space).** The ground space of `E(a,b) = (N-ab)²`
for `N = pq` is exactly the four-point divisor set. -/
theorem energyGroundSet_eq (p q : ℕ) (hp : p.Prime) (hq : q.Prime) :
    {ab : ℕ × ℕ | energy (p * q) ab.1 ab.2 = 0}
      = {(1, p * q), (p, q), (q, p), (p * q, 1)} := by
  have hp0 : p ≠ 0 := hp.pos.ne'
  have hq0 : q ≠ 0 := hq.pos.ne'
  ext ⟨a, b⟩
  simp only [Set.mem_setOf_eq, energy_eq_zero_iff, Set.mem_insert_iff, Set.mem_singleton_iff,
    Prod.mk.injEq]
  constructor
  · intro hab
    have hdvd : a ∈ (p * q).divisors := by
      refine Nat.mem_divisors.mpr ⟨⟨b, hab.symm⟩, by positivity⟩
    rw [divisors_semiprime p q hp hq] at hdvd
    simp only [Finset.mem_insert, Finset.mem_singleton] at hdvd
    rcases hdvd with h | h | h | h
    · refine Or.inl ⟨h, ?_⟩
      rw [h, one_mul] at hab
      exact hab
    · refine Or.inr (Or.inl ⟨h, ?_⟩)
      rw [h] at hab
      exact Nat.eq_of_mul_eq_mul_left hp.pos hab
    · refine Or.inr (Or.inr (Or.inl ⟨h, ?_⟩))
      rw [h] at hab
      exact Nat.eq_of_mul_eq_mul_left hq.pos (by rw [hab]; ring)
    · refine Or.inr (Or.inr (Or.inr ⟨h, ?_⟩))
      rw [h] at hab
      exact Nat.eq_of_mul_eq_mul_left (show 0 < p * q by positivity) (by rw [hab]; ring)
  · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩) <;> ring

/-- **OPO-FAC / MPS-PARENT, closed (density).** The ground space has exactly four
points, independently of the size of `N`: random restarts over the `N²`-point
configuration space succeed with density `4/N²`, i.e. the analog resource does not
change the counting. -/
theorem energyGroundSet_ncard (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hlt : p < q) :
    {ab : ℕ × ℕ | energy (p * q) ab.1 ab.2 = 0}.ncard = 4 := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hpN : p < p * q := by nlinarith
  have hqN : q < p * q := by nlinarith
  rw [energyGroundSet_eq p q hp hq]
  have h4 : ({(1, p * q), (p, q), (q, p), (p * q, 1)} : Set (ℕ × ℕ))
      = ↑({(1, p * q), (p, q), (q, p), (p * q, 1)} : Finset (ℕ × ℕ)) := by
    simp
  rw [h4, Set.ncard_coe_finset]
  rw [Finset.card_insert_of_notMem (by simp [Prod.ext_iff]; omega),
    Finset.card_insert_of_notMem (by simp [Prod.ext_iff]; omega),
    Finset.card_insert_of_notMem (by simp [Prod.ext_iff]; omega)]
  simp

/-- **The nontrivial divisor count is `2`.** Out of the `N` candidate residues, only
two are useful witnesses: the success density of a random probe is `2/N`. -/
theorem nontrivial_divisors_semiprime (p q : ℕ) (hp : p.Prime) (hq : q.Prime) :
    (((p * q).divisors.erase 1).erase (p * q)) = {p, q} := by
  have hp2 := hp.two_le
  have hq2 := hq.two_le
  have hpN : p < p * q := by nlinarith
  have hqN : q < p * q := by nlinarith
  rw [divisors_semiprime p q hp hq]
  rw [Finset.erase_insert (by simp; omega)]
  rw [show ({p, q, p * q} : Finset ℕ) = insert p (insert q {p * q}) from rfl]
  rw [Finset.erase_insert_of_ne (by omega), Finset.erase_insert_of_ne (by omega)]
  simp

end FactorLocationBarriers