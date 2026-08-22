/-
# The subfield splitting-type channel

The catalog file `Shared.CyclicTypeChannel` develops the splitting-type channel of
the *full* cyclotomic field `Q(ζ_f)`: for a prime conductor `f` the Galois group is
cyclic of order `n = f - 1`, an unramified prime `p` is `g ^ a` for a fixed
generator `g`, and its residue degree is `ordType n a = n / gcd (a, n)`.

This file adds the missing *subfield* layer.  Every divisor `m ∣ n` names a unique
subfield `K_m ⊆ Q(ζ_f)` with `Gal(K_m / Q) ≅ C m`, obtained by quotienting the
Galois group by its subgroup of index `m`.  On exponents the quotient map is
`a ↦ a mod m`, so the splitting type of `p` in `K_m` is `ordType m (a mod m)`.

The results proved here are:

* `uEnt_transfer_of_modPeriodic` — the **periodic transfer law**: any read-out that
  factors through `a mod m` has exactly the same entropy computed over the *big*
  exponent range `range n` as over the *small* range `range m`.  The proof is a
  fibre-splitting bijection `range (m * k) ≃ range k × range m`.
* `subfield_typeEntropy` — consequently `H(T_{K_m}) = typeEntropy m` for every
  `m ∣ n`: the subfield channel of any conductor equals the intrinsic `C m`
  channel.  Subfield entropies are *conductor-independent*.
* `subfield_full_pinning` and `subfield_thickening_zero` — the residue `p mod f`
  (and any refinement of it) determines the subfield type, so the mutual
  information is exactly `H(T)`; the channel is fully pinned.
* `subfield_two_types_iff_prime` — the subfield channel has exactly **two**
  splitting types iff `m` is prime.
* `typeEntropy_prime_formula` — the closed form `H(T) = log₂ q - ((q-1)/q) log₂ (q-1)`
  for prime degree `q`.
* `pairing_defect_prime` — the exact **semiprime pairing defect**
  `H(T) - I({T(p),T(q)} ; N mod f) = ((q-1)/q²) ((q-1) log₂(q-1) - (q-2) log₂(q-2))`
  for every prime degree `q`, obtained by subtracting the catalog's closed form
  `Ipair_prime` from the single-prime entropy.
-/
import Shared.CyclicTypeChannel
import Shared.CyclicTypeChannelPrime

namespace CyclicSubfield

open Finset CyclicTypeChannel

/-! ## 1. Periodic read-outs and the fibre-splitting bijection -/

variable {β : Type*} [DecidableEq β]

/-- A read-out is `m`-periodic when it only depends on the residue mod `m`.
The splitting type in the degree-`m` subfield is the basic example. -/
def ModPeriodic (m : ℕ) (h : ℕ → β) : Prop := ∀ a, h (a % m) = h a

/-- The splitting type in the degree-`m` subfield is `m`-periodic. -/
theorem modPeriodic_ordType (m : ℕ) : ModPeriodic m (ordType m) := fun a => ordType_mod m a

/-- **Fibre splitting.** For an `m`-periodic read-out the fibre over `v` inside
`range (m * k)` is `k` disjoint translates of the fibre inside `range m`. -/
theorem card_fiber_of_modPeriodic {m k : ℕ} (hm : 0 < m) {h : ℕ → β}
    (hper : ModPeriodic m h) (v : β) :
    #{x ∈ range (m * k) | h x = v} = k * #{x ∈ range m | h x = v} := by
  classical
  have hbij : #{x ∈ range (m * k) | h x = v}
      = #((range k) ×ˢ {x ∈ range m | h x = v}) := by
    refine Finset.card_bij' (fun x _ => (x / m, x % m)) (fun p _ => p.1 * m + p.2) ?_ ?_ ?_ ?_
    · intro x hx
      simp only [mem_filter, mem_range] at hx
      have hxm : x / m < k := by
        rcases Nat.eq_zero_or_pos k with rfl | hk
        · simp at hx
        · exact Nat.div_lt_of_lt_mul (by omega)
      simp only [Finset.mem_product, mem_filter, mem_range]
      exact ⟨hxm, Nat.mod_lt _ hm, by rw [hper, hx.2]⟩
    · intro p hp
      simp only [Finset.mem_product, mem_filter, mem_range] at hp
      obtain ⟨hk, hr, hv⟩ := hp
      have hlt : p.1 * m + p.2 < m * k := by
        have hle : (p.1 + 1) * m ≤ k * m := Nat.mul_le_mul_right m (by omega)
        have he : (p.1 + 1) * m = p.1 * m + m := by ring
        have hkm : k * m = m * k := Nat.mul_comm _ _
        omega
      simp only [mem_filter, mem_range]
      refine ⟨hlt, ?_⟩
      have : (p.1 * m + p.2) % m = p.2 % m := by
        simp [Nat.add_comm]
      rw [← hper, this, Nat.mod_eq_of_lt hr, hv]
    · intro x hx
      exact Nat.div_add_mod' x m
    · intro p hp
      simp only [Finset.mem_product, mem_filter, mem_range] at hp
      have h1 : (p.1 * m + p.2) / m = p.1 := by
        have hcomm : p.1 * m + p.2 = p.2 + m * p.1 := by ring
        rw [hcomm, Nat.add_mul_div_left _ _ hm, Nat.div_eq_of_lt hp.2.1, Nat.zero_add]
      have h2 : (p.1 * m + p.2) % m = p.2 := by
        have : (p.1 * m + p.2) % m = p.2 % m := by
          simp [Nat.add_comm]
        rw [this, Nat.mod_eq_of_lt hp.2.1]
      exact Prod.ext h1 h2
  rw [hbij, Finset.card_product, card_range]

/-- An `m`-periodic read-out takes the same set of values on `range (m * k)`
(`k > 0`) as on `range m`. -/
theorem image_of_modPeriodic {m k : ℕ} (hm : 0 < m) (hk : 0 < k) {h : ℕ → β}
    (hper : ModPeriodic m h) :
    (range (m * k)).image h = (range m).image h := by
  classical
  apply Finset.Subset.antisymm
  · intro v hv
    simp only [mem_image, mem_range] at hv ⊢
    obtain ⟨x, _, rfl⟩ := hv
    exact ⟨x % m, Nat.mod_lt _ hm, hper x⟩
  · intro v hv
    simp only [mem_image, mem_range] at hv ⊢
    obtain ⟨x, hx, rfl⟩ := hv
    exact ⟨x, lt_of_lt_of_le hx (Nat.le_mul_of_pos_right m hk), rfl⟩

/-- **The periodic transfer law.** The entropy of an `m`-periodic read-out does not
see the size of the ambient exponent range: computing it over `range (m * k)` gives
the same number as computing it over `range m`.

Arithmetically: the splitting-type entropy of a subfield does not depend on the
conductor it is cut out of. -/
theorem uEnt_transfer_of_modPeriodic {m k : ℕ} (hm : 0 < m) (hk : 0 < k) {h : ℕ → β}
    (hper : ModPeriodic m h) :
    uEnt (range (m * k)) h = uEnt (range m) h := by
  classical
  have hbig : (range (m * k)).Nonempty := ⟨0, mem_range.2 (by positivity)⟩
  have hsmall : (range m).Nonempty := ⟨0, mem_range.2 hm⟩
  rw [uEnt_eq_shannon hbig, uEnt_eq_shannon hsmall, image_of_modPeriodic hm hk hper]
  refine Finset.sum_congr rfl fun v _ => ?_
  have hcard := card_fiber_of_modPeriodic (k := k) hm hper v
  have hk' : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hm' : (m : ℝ) ≠ 0 := by positivity
  have hprob : (#{x ∈ range (m * k) | h x = v} : ℝ) / (#(range (m * k)) : ℝ)
      = (#{x ∈ range m | h x = v} : ℝ) / (#(range m) : ℝ) := by
    rw [card_range, card_range, hcard]
    push_cast
    rw [mul_comm (m : ℝ) (k : ℝ), mul_div_mul_left _ _ (ne_of_gt hk')]
  rw [hprob]

/-! ## 2. The subfield type channel -/

/-- **Subfield entropy is conductor-independent.**  If the cyclic Galois group has
order `n = m * k` then the splitting-type entropy of the degree-`m` subfield,
computed over all `n` Frobenius exponents, is exactly the intrinsic `C m` value. -/
theorem subfield_typeEntropy {m k : ℕ} (hm : 0 < m) (hk : 0 < k) :
    uEnt (range (m * k)) (ordType m) = typeEntropy m :=
  uEnt_transfer_of_modPeriodic hm hk (modPeriodic_ordType m)

/-- The divisor form of the previous statement: for `m ∣ n` the degree-`m` subfield
channel of a cyclic extension of degree `n` has entropy `typeEntropy m`. -/
theorem subfield_typeEntropy_of_dvd {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (hmn : m ∣ n) :
    uEnt (range n) (ordType m) = typeEntropy m := by
  obtain ⟨k, rfl⟩ := hmn
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · simp at hn
    · exact hk
  exact subfield_typeEntropy hm hk

/-- **Full pinning for subfields.** The Frobenius residue determines the splitting
type in every subfield, so the mutual information is the whole entropy. -/
theorem subfield_full_pinning {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (hmn : m ∣ n) :
    mutInfo (range n) (ordType m) id = typeEntropy m := by
  rw [mutInfo, condEnt_eq_zero_of_injOn _ (Set.injOn_id _), sub_zero,
    subfield_typeEntropy_of_dvd hm hn hmn]

/-- **Thickening is free for subfields.**  Refining the residue `p mod f` to any
strictly finer invariant `w` (for example `p mod f²`, or the pair
`(p mod f, p mod f')`) cannot add information: the subfield channel is already
saturated at `H(T)`. -/
theorem subfield_thickening_zero {γ : Type*} [DecidableEq γ] {m n : ℕ} (hm : 0 < m)
    (hn : 0 < n) (hmn : m ∣ n) (w : ℕ → γ) (hw : Set.InjOn w (range n)) :
    mutInfo (range n) (ordType m) w = typeEntropy m := by
  rw [mutInfo, condEnt_eq_zero_of_injOn _ hw, sub_zero, subfield_typeEntropy_of_dvd hm hn hmn]

/-- The splitting types occurring in the degree-`m` subfield channel of a degree-`n`
cyclic extension are exactly the divisors of `m`. -/
theorem subfield_image_ordType {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (hmn : m ∣ n) :
    (range n).image (ordType m) = m.divisors := by
  obtain ⟨k, rfl⟩ := hmn
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · simp at hn
    · exact hk
  rw [image_of_modPeriodic hm hk (modPeriodic_ordType m), image_ordType m hm]

/-- **Two types exactly at prime degree.**  The degree-`m` subfield channel is
binary — only "splits completely" and "inert" occur — precisely when `m` is
prime. -/
theorem subfield_two_types_iff_prime {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (hmn : m ∣ n) :
    ((range n).image (ordType m)).card = 2 ↔ m.Prime := by
  rw [subfield_image_ordType hm hn hmn]
  constructor
  · intro h
    have hm1 : m ≠ 1 := by rintro rfl; simp at h
    have hpair : ({1, m} : Finset ℕ) ⊆ m.divisors := by
      intro d hd
      simp only [Finset.mem_insert, Finset.mem_singleton] at hd
      rcases hd with rfl | rfl
      · exact Nat.one_mem_divisors.2 hm.ne'
      · exact Nat.mem_divisors_self _ hm.ne'
    have hcard : (({1, m} : Finset ℕ)).card = 2 := Finset.card_pair (by omega)
    have heq : ({1, m} : Finset ℕ) = m.divisors :=
      Finset.eq_of_subset_of_card_le hpair (by rw [h, hcard])
    refine Nat.prime_def.2 ⟨by omega, fun d hd => ?_⟩
    have hd0 : d ∈ m.divisors := Nat.mem_divisors.2 ⟨hd, hm.ne'⟩
    rw [← heq] at hd0
    simpa using hd0
  · intro hp
    rw [hp.divisors, Finset.card_pair (by exact hp.one_lt.ne)]

/-! ## 3. The prime-degree closed forms -/

/-- **The closed form of the type entropy at prime degree.**
`H(T) = log₂ q - ((q-1)/q) · log₂ (q-1)`: one exponent out of `q` splits
completely, the other `q - 1` are inert. -/
theorem typeEntropy_prime_formula {q : ℕ} (hq : q.Prime) :
    typeEntropy q = Real.logb 2 q - (((q : ℝ) - 1) / q) * Real.logb 2 ((q : ℝ) - 1) := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  have hq1 : (1 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq.one_lt.le
  have hq1' : (0 : ℝ) < (q : ℝ) - 1 := by
    have : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq.two_le
    linarith
  rw [typeEntropy_formula q hq.pos, hq.divisors,
    Finset.sum_pair (by exact hq.one_lt.ne)]
  have hphi1 : (Nat.totient 1 : ℝ) = 1 := by simp
  have hphiq : (Nat.totient q : ℝ) = (q : ℝ) - 1 := by
    rw [Nat.totient_prime hq, Nat.cast_sub hq.one_lt.le, Nat.cast_one]
  rw [hphi1, hphiq]
  rw [Real.logb_div (ne_of_gt hq0) (ne_of_gt hq1'), div_one]
  field_simp
  ring

/-- The type entropy of the cyclic cubic channel: `H(T) = log₂ 3 - 2/3`. -/
theorem typeEntropy_three : typeEntropy 3 = Real.logb 2 3 - 2 / 3 := by
  have h := typeEntropy_prime_formula (q := 3) (by norm_num)
  norm_num at h
  linarith [h]

/-- **The semiprime pairing defect at prime degree.**  Comparing the fully pinned
single-prime channel `H(T)` with the catalog's semiprime type-pair channel
`Ipair q = I({T(p),T(q')} ; N mod f)` gives the exact loss

`H(T) - Ipair q = ((q-1)/q²) · ((q-1) log₂(q-1) - (q-2) log₂(q-2))`.

Merging two primes into their product destroys exactly this much of the pinned
information. -/
theorem pairing_defect_prime {q : ℕ} (hq : q.Prime) :
    typeEntropy q - Ipair q
      = (((q : ℝ) - 1) / (q : ℝ) ^ 2) *
          (((q : ℝ) - 1) * Real.logb 2 ((q : ℝ) - 1)
            - ((q : ℝ) - 2) * Real.logb 2 ((q : ℝ) - 2)) := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq.pos
  rw [typeEntropy_prime_formula hq, Ipair_prime hq]
  field_simp
  ring

/-- **The cubic pairing defect is the rational number `4/9`.**  Both `H(T)` and
`Ipair 3` involve `log₂ 3`, but the difference is exactly `4/9` bits: at prime
degree `3` the transcendental parts cancel. -/
theorem pairing_defect_three : typeEntropy 3 - Ipair 3 = 4 / 9 := by
  have h := pairing_defect_prime (q := 3) (by norm_num)
  norm_num at h
  linarith [h]

end CyclicSubfield