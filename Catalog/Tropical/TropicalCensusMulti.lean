import Tropical.TropicalTorsionCensus

/-!
# The torsion census of a squarefree modulus is a tropical polynomial of degree r

Second cycle of the round-4 research loop. `Tropical.TropicalTorsionCensus` proved
that for a semiprime `N = pq` the 2-Sylow torsion census is the tropical *quadratic*
`(X ⊕ a) ⊙ (X ⊕ b)` with `a = v₂(p-1)`, `b = v₂(q-1)`. Here we prove the general
statement for an arbitrary squarefree modulus `N = ∏_{p ∈ s} p`:

* `torsionCount_units_prod`: the `d`-torsion count of `(ℤ/Nℤ)ˣ` is `∏_{p∈s} gcd(p-1, d)`;
* `torsionCensus_prod`: the 2-Sylow census is `2 ^ (∑_{p∈s} min k v₂(p-1))`;
* `trop_censusExponentMulti`: that exponent is the value at `k` of the *degree-r*
  tropical polynomial `⨀_{p ∈ s} (X ⊕ v₂(p-1))`;
* `census_root_multiplicity` / `tropical_root_multiplicity`: the drop of the tropical
  slope at `k+1` equals the number of primes `p ∈ s` with `v₂(p-1) = k+1`, i.e. the
  *multiplicity of `k+1` as a tropical root* of the census polynomial. This is the
  exact generalisation of the two-root corner locus of the semiprime case;
* `census_level_one_constant`: at level `k = 1` the census of any squarefree odd `N`
  with `r` prime factors is `2 ^ r`, independent of the primes themselves — the
  level-1 census carries exactly zero information, matching the constancy of the
  divisor-count partition function in `Tropical.FactorLocationBarriers`.

A final section adds the structural duality: the census exponent is the discrete
integral of its root-counting function (`censusExponentMulti_eq_sum_levels`, the
Newton-polygon/layer-cake duality), it is concave (`censusExponentMulti_concave`), and
two moduli with equal censuses have equal root multiplicities at every level `≥ 1`
(`census_determines_root_multiplicities`) — level `0` being invisible, because a
tropical root at `0` contributes nothing.

Thus the information in the whole census is precisely the multiset of tropical roots
`{v₂(p-1)}` at positive levels, and nothing more.
-/

open Tropical

namespace TropicalTorsionCensus

/-! ## 1. CRT multiplicativity of torsion counting -/

/-- Torsion counting in `(ℤ/Nℤ)ˣ` is multiplicative over coprime factorisations of `N`. -/
theorem torsionCount_units_mul_coprime (m n : ℕ) (h : m.Coprime n) (d : ℕ) :
    torsionCount (ZMod (m * n))ˣ d = torsionCount (ZMod m)ˣ d * torsionCount (ZMod n)ˣ d := by
  have e : (ZMod (m * n))ˣ ≃* (ZMod m)ˣ × (ZMod n)ˣ :=
    (Units.mapEquiv (ZMod.chineseRemainder h).toMulEquiv).trans MulEquiv.prodUnits
  rw [torsionCount_congr e d, torsionCount_prod]

/-- The `d`-torsion count of `(ℤ/pℤ)ˣ` for a prime `p`. -/
theorem torsionCount_units_prime (p : ℕ) (hp : p.Prime) (d : ℕ) :
    torsionCount (ZMod p)ˣ d = (p - 1).gcd d := by
  haveI := Fact.mk hp
  rw [torsionCount_cyclic, Nat.card_eq_fintype_card, ZMod.card_units_eq_totient,
    Nat.totient_prime hp]

/-- The trivial group has a single torsion point. -/
lemma torsionCount_units_one (d : ℕ) : torsionCount (ZMod 1)ˣ d = 1 := by
  rw [torsionCount, Nat.card_eq_one_iff_unique]
  exact ⟨⟨fun a b => Subtype.ext (Subsingleton.elim _ _)⟩, ⟨⟨1, one_pow d⟩⟩⟩

/-- **Torsion count of a squarefree modulus.** For a finite set `s` of primes and
`N = ∏_{p ∈ s} p`, the number of `d`-torsion units mod `N` is `∏_{p ∈ s} gcd(p-1, d)`. -/
theorem torsionCount_units_prod (s : Finset ℕ) (hs : ∀ p ∈ s, p.Prime) (d : ℕ) :
    torsionCount (ZMod (∏ p ∈ s, p))ˣ d = ∏ p ∈ s, (p - 1).gcd d := by
  classical
  induction s using Finset.induction with
  | empty => simpa using torsionCount_units_one d
  | @insert p t hpt ih =>
      have hp : p.Prime := hs p (Finset.mem_insert_self p t)
      have ht : ∀ q ∈ t, q.Prime := fun q hq => hs q (Finset.mem_insert_of_mem hq)
      have hcop : p.Coprime (∏ q ∈ t, q) := by
        refine Nat.Coprime.prod_right (fun q hq => ?_)
        have hqp : q.Prime := ht q hq
        have hne : p ≠ q := by rintro rfl; exact hpt hq
        exact (Nat.coprime_primes hp hqp).mpr hne
      rw [Finset.prod_insert hpt, torsionCount_units_mul_coprime _ _ hcop,
        torsionCount_units_prime p hp, ih ht, Finset.prod_insert hpt]

/-! ## 2. The census of a squarefree modulus as a tropical polynomial -/

/-- The census exponent of a squarefree modulus: `∑_{p ∈ s} min k v₂(p-1)`. -/
def censusExponentMulti (s : Finset ℕ) (k : ℕ) : ℕ := ∑ p ∈ s, min k (v2 (p - 1))

/-- **Exact census of a squarefree modulus.** -/
theorem torsionCensus_prod (s : Finset ℕ) (hs : ∀ p ∈ s, p.Prime) (k : ℕ) :
    torsionCensus (∏ p ∈ s, p) k = 2 ^ censusExponentMulti s k := by
  rw [torsionCensus, torsionCount_units_prod s hs, censusExponentMulti,
    ← Finset.prod_pow_eq_pow_sum]
  refine Finset.prod_congr rfl (fun p hp => ?_)
  have hp1 : p - 1 ≠ 0 := by have := (hs p hp).two_le; omega
  rw [gcd_two_pow_eq _ _ hp1, Nat.min_comm]

/-- **Tropicality in degree `r`.** The census exponent is the value at `k` of the
tropical polynomial `⨀_{p ∈ s} (X ⊕ v₂(p-1))`. -/
theorem trop_censusExponentMulti (s : Finset ℕ) (k : ℕ) :
    trop ((censusExponentMulti s k : ℕ) : WithTop ℕ)
      = ∏ p ∈ s, (trop ((k : ℕ) : WithTop ℕ) + trop ((v2 (p - 1) : ℕ) : WithTop ℕ)) := by
  classical
  induction s using Finset.induction with
  | empty => simp [censusExponentMulti]
  | @insert p t hpt ih =>
      rw [Finset.prod_insert hpt, ← ih, censusExponentMulti, Finset.sum_insert hpt,
        ← censusExponentMulti, ← trop_min, ← trop_add]
      norm_cast

/-! ## 3. Tropical root multiplicities: which primes the census can see -/

/-- The census exponent increases by the number of primes whose 2-adic level still
exceeds `k`: this is the tropical slope of the census polynomial on `[k, k+1]`. -/
theorem censusExponentMulti_succ (s : Finset ℕ) (k : ℕ) :
    censusExponentMulti s (k + 1)
      = censusExponentMulti s k + (s.filter (fun p => k < v2 (p - 1))).card := by
  classical
  rw [censusExponentMulti, censusExponentMulti, Finset.card_filter, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl (fun p _ => ?_)
  split_ifs with h <;> omega

/-- **Tropical root multiplicity, combinatorial form.** The slope drop between the
intervals `[k, k+1]` and `[k+1, k+2]` counts the primes with `v₂(p-1) = k+1`. -/
theorem census_root_multiplicity (s : Finset ℕ) (k : ℕ) :
    (s.filter (fun p => k < v2 (p - 1))).card
      = (s.filter (fun p => v2 (p - 1) = k + 1)).card
        + (s.filter (fun p => k + 1 < v2 (p - 1))).card := by
  classical
  rw [Finset.card_filter, Finset.card_filter, Finset.card_filter, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl (fun p _ => ?_)
  split_ifs <;> omega

/-- **Tropical root multiplicity.** The second difference of the census exponent at
`k+1` is exactly the number of primes `p | N` with `v₂(p-1) = k+1`: the census
polynomial has `k+1` as a tropical root of that multiplicity. -/
theorem tropical_root_multiplicity (s : Finset ℕ) (k : ℕ) :
    (censusExponentMulti s (k + 1) - censusExponentMulti s k)
        - (censusExponentMulti s (k + 2) - censusExponentMulti s (k + 1))
      = (s.filter (fun p => v2 (p - 1) = k + 1)).card := by
  have h1 := censusExponentMulti_succ s k
  have h2 := censusExponentMulti_succ s (k + 1)
  have h3 := census_root_multiplicity s k
  rw [show k + 1 + 1 = k + 2 from rfl] at h2
  omega

/-! ## 4. Level one of the census is information-free -/

/-- For an odd prime `p`, the 2-adic level `v₂(p-1)` is at least `1`. -/
lemma one_le_v2_sub_one (p : ℕ) (hp : p.Prime) (hodd : p ≠ 2) : 1 ≤ v2 (p - 1) := by
  have h2 := hp.two_le
  have hp1 : p - 1 ≠ 0 := by omega
  have hdvd : 2 ∣ p - 1 := by
    rcases Nat.Prime.eq_two_or_odd hp with h | h
    · exact absurd h hodd
    · omega
  exact (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hp1).mp (by rwa [pow_one])

/-- **The level-one census is constant.** For a squarefree odd modulus with `r` prime
factors the census at `k = 1` equals `2 ^ r`: it depends only on the *number* of prime
factors, not on the primes. Counting is free; locating is not. -/
theorem census_level_one_constant (s : Finset ℕ) (hs : ∀ p ∈ s, p.Prime)
    (hodd : ∀ p ∈ s, p ≠ 2) :
    torsionCensus (∏ p ∈ s, p) 1 = 2 ^ s.card := by
  rw [torsionCensus_prod s hs]
  congr 1
  rw [censusExponentMulti, Finset.card_eq_sum_ones]
  refine Finset.sum_congr rfl (fun p hp => ?_)
  have := one_le_v2_sub_one p (hs p hp) (hodd p hp)
  omega

/-! ## 5. Newton-polygon duality, concavity, and what the census determines -/

/-- **Layer-cake / Newton-polygon duality.** The census exponent at `k` is the sum over
the levels `j < k` of the number of primes whose 2-adic level exceeds `j`: the tropical
polynomial is the discrete integral of its root-counting function. -/
theorem censusExponentMulti_eq_sum_levels (s : Finset ℕ) (k : ℕ) :
    censusExponentMulti s k
      = ∑ j ∈ Finset.range k, (s.filter (fun p => j < v2 (p - 1))).card := by
  classical
  induction k with
  | zero => simp [censusExponentMulti]
  | succ k ih => rw [censusExponentMulti_succ, ih, Finset.sum_range_succ]

/-- The tropical slope is antitone: fewer primes remain above each successive level. -/
theorem census_slope_antitone (s : Finset ℕ) (k : ℕ) :
    (s.filter (fun p => (k + 1) < v2 (p - 1))).card
      ≤ (s.filter (fun p => k < v2 (p - 1))).card := by
  classical
  refine Finset.card_le_card (fun p hp => ?_)
  rw [Finset.mem_filter] at hp ⊢
  exact ⟨hp.1, by omega⟩

/-- **The census exponent is concave.** A one-variable tropical polynomial is a concave
piecewise-linear function; here that is the midpoint inequality for the census. -/
theorem censusExponentMulti_concave (s : Finset ℕ) (k : ℕ) :
    censusExponentMulti s (k + 2) + censusExponentMulti s k
      ≤ 2 * censusExponentMulti s (k + 1) := by
  have h1 := censusExponentMulti_succ s k
  have h2 := censusExponentMulti_succ s (k + 1)
  have h3 := census_slope_antitone s k
  rw [show k + 1 + 1 = k + 2 from rfl] at h2
  omega

/-- **What the census determines.** Two squarefree moduli with the same census exponent
function have the same number of prime factors at every 2-adic level `≥ 1`. Levels are
recovered exactly; note that level `0` (i.e. the prime `2`, with `v₂(2-1) = 0`) is
invisible to the census, since a tropical root at `0` contributes nothing. -/
theorem census_determines_root_multiplicities (s t : Finset ℕ)
    (h : ∀ k, censusExponentMulti s k = censusExponentMulti t k) (k : ℕ) :
    (s.filter (fun p => v2 (p - 1) = k + 1)).card
      = (t.filter (fun p => v2 (p - 1) = k + 1)).card := by
  rw [← tropical_root_multiplicity s k, ← tropical_root_multiplicity t k,
    h k, h (k + 1), h (k + 2)]

end TropicalTorsionCensus