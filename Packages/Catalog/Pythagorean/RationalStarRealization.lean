import Pythagorean.RationalStarPencil

/-!
# Which rays of a rational star carry nodes: the unimodular parametrisation

`Pythagorean.RationalStarPencil` shows that the seeds of a fixed charge `k` at a rational
ideal point `p/q` lie on a single radial line (a hypercycle at distance `arsinh (|k|/q)`
from the axis of the star), and that when `p` and `q` are both odd only *odd* charges can
occur. This file proves the converse — every non-obstructed ray really does carry
infinitely many nodes — and identifies the exact arithmetic of a ray.

## The mechanism

Choose `a b : ℤ` with `p b - q a = 1` (possible exactly because `p/q` is in lowest terms)
and set

  `starSeed p q k a b s = (k b + s q, k a + s p)`.

Then `starSeed` runs over *all* integral solutions of `p m - q n = k` as `s` runs over `ℤ`,
and — this is the key point — the substitution is **unimodular**, so it transports the
arithmetic of the pair `(m, n)` to the arithmetic of the pair `(k, s)`:

* `charge_starSeed` : the charge is `k`, identically in `s`;
* `isCoprime_starSeed` : `gcd(m,n) = 1` iff `gcd(k,s) = 1`;
* `sum_starSeed` : `m + n = k (a+b) + s (p+q)`, so the parity of the node is an explicit
  affine function of `s`.

## Main results

* `exists_seed_charge_gt` : **realisation theorem.** Let `0 < p < q` be coprime and let
  `k ≠ 0` be an integer which is odd in case `p + q` is even. Then for every bound `M`
  there is a Euclid seed `(m,n)` with `m > M` and charge `k` at `p/q`.
* `spoke_infinite` : consequently every admissible ray of every rational star carries
  infinitely many nodes of the Berggren tree. Combined with
  `RationalStarPencil.charge_odd_of_odd_odd` this determines the star at `p/q` completely:
  the set of realised charges is *all* of `ℤ` when `p + q` is odd, and exactly the odd
  integers when `p + q` is even.
* `realised_charges_eq` : the two statements packaged as one exact description of the fan.

Together with the visibility law of `RationalStarPencil` this is a complete explanation of
the radial lines seen at `0`, `1`, `1/2`, `1/3`, `1/5`, … in the half-plane plot: *every*
rational carries a full quantised fan of hypercycles, the fan is two-sided at an interior
rational, its spacing is `1/q`, and half its rays are switched off precisely when `p` and
`q` are both odd.
-/

namespace BerggrenRationalStar

open BerggrenHypercycleStars

/-! ## Part 1. The unimodular parametrisation of a ray -/

/-- The integral pair attached to the parameter `s` on the ray of charge `k` at `p/q`,
for a choice of `a, b` with `p b - q a = 1`. -/
def starSeed (p q k a b s : ℤ) : ℤ × ℤ := (k * b + s * q, k * a + s * p)

/-- The parametrisation has constant charge `k`. -/
theorem charge_starSeed {p q a b : ℤ} (hab : p * b - q * a = 1) (k s : ℤ) :
    chargeZ p q (starSeed p q k a b s).1 (starSeed p q k a b s).2 = k := by
  simp only [chargeZ, starSeed]
  have : p * (k * b + s * q) - q * (k * a + s * p) = k * (p * b - q * a) := by ring
  rw [this, hab, mul_one]

/-- The parameter `s` is recovered from the pair by the inverse unimodular form. -/
theorem param_starSeed {p q a b : ℤ} (hab : p * b - q * a = 1) (k s : ℤ) :
    b * (starSeed p q k a b s).2 - a * (starSeed p q k a b s).1 = s := by
  simp only [starSeed]
  have : b * (k * a + s * p) - a * (k * b + s * q) = s * (p * b - q * a) := by ring
  rw [this, hab, mul_one]

/-- The node parity along the ray is an affine function of the parameter. -/
theorem sum_starSeed (p q k a b s : ℤ) :
    (starSeed p q k a b s).1 + (starSeed p q k a b s).2 = k * (a + b) + s * (p + q) := by
  simp only [starSeed]; ring

/-- **Unimodularity.** If `k` and `s` are coprime then so are the two coordinates of the
parametrised pair: the arithmetic of the node is exactly the arithmetic of `(k, s)`. -/
theorem isCoprime_starSeed {p q a b : ℤ} (hab : p * b - q * a = 1) {k s : ℤ}
    (h : IsCoprime k s) :
    IsCoprime (starSeed p q k a b s).1 (starSeed p q k a b s).2 := by
  obtain ⟨u, v, huv⟩ := h
  refine ⟨u * p - v * a, v * b - u * q, ?_⟩
  have h1 : chargeZ p q (starSeed p q k a b s).1 (starSeed p q k a b s).2 = k :=
    charge_starSeed hab k s
  have h2 : b * (starSeed p q k a b s).2 - a * (starSeed p q k a b s).1 = s :=
    param_starSeed hab k s
  simp only [chargeZ] at h1
  set m := (starSeed p q k a b s).1
  set n := (starSeed p q k a b s).2
  calc (u * p - v * a) * m + (v * b - u * q) * n
      = u * (p * m - q * n) + v * (b * n - a * m) := by ring
    _ = u * k + v * s := by rw [h1, h2]
    _ = 1 := huv

/-! ## Part 2. Choosing a good parameter -/

/-- **Parameter selection.** For every `K ≥ 1`, every target parity class `ε` compatible
with `K` (if `K` is even the class must be odd, since a parameter coprime to an even `K`
is odd), and every bound `B`, there is an arbitrarily large `s ≡ 1 (mod K)` in the class
`ε`. -/
theorem exists_param (K : ℕ) (hK : 0 < K) (ε : ℤ) (hcompat : K % 2 = 0 → ε % 2 = 1)
    (B : ℤ) : ∃ s : ℤ, B ≤ s ∧ (∃ t : ℤ, s = 1 + (K : ℤ) * t) ∧ s % 2 = ε % 2 := by
  have hK1 : (1 : ℤ) ≤ (K : ℤ) := by exact_mod_cast hK
  -- the shift `c` fixes the parity when `K` is odd; when `K` is even the parity is forced
  set c : ℤ := if K % 2 = 1 then (ε - 1) % 2 else 0 with hc
  have hc0 : 0 ≤ c := by
    rw [hc]; split
    · exact Int.emod_nonneg _ (by norm_num)
    · exact le_refl 0
  set j : ℤ := |B| + 1 with hj
  have hj0 : (0 : ℤ) ≤ j := by positivity
  refine ⟨1 + (K : ℤ) * (c + 2 * j), ?_, ⟨c + 2 * j, rfl⟩, ?_⟩
  · have h1 : (K : ℤ) * (c + 2 * j) ≥ 1 * (2 * j) := by
      have : (0 : ℤ) ≤ c + 2 * j := by linarith
      nlinarith [hK1, hc0, hj0]
    have : |B| ≥ B := le_abs_self B
    linarith
  · -- parity
    rcases Nat.even_or_odd K with hKe | hKo
    · -- `K` even: `s` is odd and `ε` is odd by compatibility
      have hKe' : K % 2 = 0 := Nat.even_iff.mp hKe
      have hcz : c = 0 := by rw [hc]; simp [hKe']
      have hKZ : (K : ℤ) % 2 = 0 := by omega
      obtain ⟨K', hK'⟩ : ∃ K' : ℤ, (K : ℤ) = 2 * K' := ⟨(K : ℤ) / 2, by omega⟩
      have : (1 + (K : ℤ) * (c + 2 * j)) = 1 + 2 * (K' * (c + 2 * j)) := by
        rw [hK']; ring
      rw [this, hcompat hKe']
      omega
    · -- `K` odd: the shift `c` was chosen to fix the parity
      have hKo' : K % 2 = 1 := Nat.odd_iff.mp hKo
      have hcz : c = (ε - 1) % 2 := by rw [hc]; simp [hKo']
      obtain ⟨K', hK'⟩ : ∃ K' : ℤ, (K : ℤ) = 2 * K' + 1 := ⟨(K : ℤ) / 2, by omega⟩
      have hexp : (1 + (K : ℤ) * (c + 2 * j))
          = 1 + c + 2 * (K' * (c + 2 * j) + j) := by rw [hK']; ring
      rw [hexp, hcz]
      omega

/-! ## Part 3. The realisation theorem -/

/-- Transfer of a nonnegative integral pair to a Euclid seed. -/
theorem isSeed_toNat {M N : ℤ} (hN : 0 < N) (hNM : N < M) (hg : IsCoprime M N)
    (hpar : (M + N) % 2 = 1) : IsSeed M.toNat N.toNat := by
  have hM : 0 < M := lt_trans hN hNM
  refine ⟨by omega, by omega, ?_, by omega⟩
  have hgcd : Int.gcd M N = 1 := Int.isCoprime_iff_gcd_eq_one.mp hg
  have h1 : M.toNat = M.natAbs := by omega
  have h2 : N.toNat = N.natAbs := by omega
  rw [h1, h2]
  exact hgcd

/-- **Realisation theorem.** Let `p/q` be an interior rational in lowest terms and let
`k ≠ 0` be an integer, odd if `p + q` is even. Then the ray of charge `k` at `p/q` carries
Euclid seeds of arbitrarily large size: the corresponding radial line of the picture really
is populated by nodes of the Berggren tree, all the way out to the ideal point. -/
theorem exists_seed_charge_gt {p q : ℕ} (hp : 0 < p) (hpq : p < q) (hcop : Nat.Coprime p q)
    {k : ℤ} (hk : k ≠ 0) (hpar : (p + q) % 2 = 0 → Odd k) (M : ℕ) :
    ∃ m n : ℕ, IsSeed m n ∧ M < m ∧ charge (p : ℤ) q m n = k := by
  -- Bézout data for the ideal point
  obtain ⟨u, v, huv⟩ : IsCoprime (p : ℤ) (q : ℤ) := Int.isCoprime_iff_gcd_eq_one.mpr hcop
  set a : ℤ := -v with ha
  set b : ℤ := u with hb
  have hab : (p : ℤ) * b - (q : ℤ) * a = 1 := by rw [ha, hb]; linarith [huv]
  set K : ℕ := k.natAbs with hKdef
  have hK : 0 < K := Int.natAbs_pos.mpr hk
  have hKk : (K : ℤ) = k ∨ (K : ℤ) = -k := by
    rcases Int.natAbs_eq k with h | h
    · exact Or.inl h.symm
    · exact Or.inr (by omega)
  -- the parity class the parameter must lie in
  set ε : ℤ := 1 - k * (a + b) with hε
  have hcompat : K % 2 = 0 → ε % 2 = 1 := by
    intro hKe
    have hkeven : k % 2 = 0 := by omega
    obtain ⟨k', hk'⟩ : ∃ k' : ℤ, k = 2 * k' := ⟨k / 2, by omega⟩
    rw [hε, hk']
    have : 1 - 2 * k' * (a + b) = 1 + 2 * (-(k' * (a + b))) := by ring
    rw [this]; omega
  -- a large admissible parameter
  set B : ℤ := (k * a).natAbs + (k * b).natAbs + (k * (b - a)).natAbs + M + 1 with hB
  obtain ⟨s, hsB, ⟨t, hst⟩, hspar⟩ := exists_param K hK ε hcompat B
  -- the parametrised node
  set m : ℤ := k * b + s * (q : ℤ) with hm
  set n : ℤ := k * a + s * (p : ℤ) with hn
  have hstar1 : (starSeed (p : ℤ) (q : ℤ) k a b s).1 = m := rfl
  have hstar2 : (starSeed (p : ℤ) (q : ℤ) k a b s).2 = n := rfl
  -- size estimates
  have hp1 : (1 : ℤ) ≤ (p : ℤ) := by exact_mod_cast hp
  have hqp : (p : ℤ) + 1 ≤ (q : ℤ) := by exact_mod_cast hpq
  have habs1 : -((k * a).natAbs : ℤ) ≤ k * a := by
    rcases Int.natAbs_eq (k * a) with h | h <;> omega
  have habs2 : -((k * b).natAbs : ℤ) ≤ k * b := by
    rcases Int.natAbs_eq (k * b) with h | h <;> omega
  have habs3 : -((k * (b - a)).natAbs : ℤ) ≤ k * (b - a) := by
    rcases Int.natAbs_eq (k * (b - a)) with h | h <;> omega
  have hs0 : (0 : ℤ) ≤ s := by
    have : (0 : ℤ) ≤ B := by positivity
    linarith
  have hsM : ((M : ℤ) + 1) ≤ s - ((k * a).natAbs : ℤ) - ((k * b).natAbs : ℤ)
      - ((k * (b - a)).natAbs : ℤ) := by
    rw [hB] at hsB; linarith
  have hnpos : 0 < n := by
    have hsp : s ≤ s * (p : ℤ) := by nlinarith
    rw [hn]; linarith [habs1, hsM]
  have hnm : n < m := by
    have hdiff : m - n = k * (b - a) + s * ((q : ℤ) - p) := by rw [hm, hn]; ring
    have hsq : s ≤ s * ((q : ℤ) - (p : ℤ)) := by nlinarith
    linarith [habs3, hsM, hdiff]
  have hmM : (M : ℤ) < m := by
    have hsq : s ≤ s * (q : ℤ) := by nlinarith
    rw [hm]; linarith [habs2, hsM]
  -- coprimality via unimodularity
  have hcopks : IsCoprime k s := by
    rcases hKk with h | h
    · have hs1 : s = 1 + k * t := by rw [hst, h]
      exact ⟨-t, 1, by rw [hs1]; ring⟩
    · have hs1 : s = 1 - k * t := by rw [hst, h]; ring
      exact ⟨t, 1, by rw [hs1]; ring⟩
  have hcopmn : IsCoprime m n := by
    have := isCoprime_starSeed (p := (p : ℤ)) (q := (q : ℤ)) hab hcopks
    rwa [hstar1, hstar2] at this
  -- parity of the node
  have hsum : m + n = k * (a + b) + s * ((p : ℤ) + q) := by rw [hm, hn]; ring
  have hparity : (m + n) % 2 = 1 := by
    rcases Nat.even_or_odd (p + q) with hpqe | hpqo
    · -- `p + q` even: `k` is odd and `a + b` is odd, so `k(a+b)` is odd
      have hpqe' : (p + q) % 2 = 0 := Nat.even_iff.mp hpqe
      obtain ⟨k', hk'⟩ := hpar hpqe'
      -- `p` and `q` are both odd
      have hpodd : p % 2 = 1 := by
        rcases Nat.even_or_odd p with h | h
        · exfalso
          have hp2 : 2 ∣ p := h.two_dvd
          have hq2 : 2 ∣ q := by omega
          have := Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left hp2 hcop) hq2
          omega
        · exact Nat.odd_iff.mp h
      have hqodd : q % 2 = 1 := by omega
      obtain ⟨p', hp'⟩ : ∃ p' : ℤ, (p : ℤ) = 2 * p' + 1 := ⟨(p : ℤ) / 2, by omega⟩
      obtain ⟨q', hq'⟩ : ∃ q' : ℤ, (q : ℤ) = 2 * q' + 1 := ⟨(q : ℤ) / 2, by omega⟩
      have habodd : (a + b) % 2 = 1 := by
        have hexp : (p : ℤ) * b - (q : ℤ) * a = 2 * (p' * b - q' * a) + (b - a) := by
          rw [hp', hq']; ring
        rw [hexp] at hab
        omega
      obtain ⟨w, hw⟩ : ∃ w : ℤ, a + b = 2 * w + 1 := ⟨(a + b) / 2, by omega⟩
      have hexp2 : m + n = 2 * ((2 * k' + 1) * w + k' + (p' + q' + 1) * s) + 1 := by
        rw [hsum, hk', hw, hp', hq']; ring
      omega
    · -- `p + q` odd: the parameter was chosen in the right parity class
      have hpqo' : (p + q) % 2 = 1 := Nat.odd_iff.mp hpqo
      obtain ⟨r, hr⟩ : ∃ r : ℤ, (p : ℤ) + (q : ℤ) = 2 * r + 1 := by
        refine ⟨((p : ℤ) + q) / 2, ?_⟩
        have : ((p : ℕ) + q) % 2 = 1 := hpqo'
        omega
      have hexp : m + n = k * (a + b) + 2 * (s * r) + s := by rw [hsum, hr]; ring
      have hεs : s % 2 = (1 - k * (a + b)) % 2 := by rw [hspar, hε]
      omega
  -- assemble
  refine ⟨m.toNat, n.toNat, isSeed_toNat hnpos hnm hcopmn hparity, by omega, ?_⟩
  have h1 : (m.toNat : ℤ) = m := Int.toNat_of_nonneg (by omega)
  have h2 : (n.toNat : ℤ) = n := Int.toNat_of_nonneg (by omega)
  simp only [charge, chargeZ, h1, h2]
  have := charge_starSeed (p := (p : ℤ)) (q := (q : ℤ)) hab k s
  simpa [chargeZ, hstar1, hstar2] using this

/-! ## Part 4. Every admissible ray is infinite, and the exact fan -/

/-- **Every admissible ray of every rational star is infinite.** -/
theorem spoke_infinite {p q : ℕ} (hp : 0 < p) (hpq : p < q) (hcop : Nat.Coprime p q)
    {k : ℤ} (hk : k ≠ 0) (hpar : (p + q) % 2 = 0 → Odd k) :
    {x : ℕ × ℕ | IsSeed x.1 x.2 ∧ charge (p : ℤ) q x.1 x.2 = k}.Infinite := by
  intro hfin
  obtain ⟨M, hM⟩ := (hfin.image Prod.fst).bddAbove
  obtain ⟨m, n, hs, hmM, hc⟩ := exists_seed_charge_gt hp hpq hcop hk hpar M
  have : m ∈ Prod.fst '' {x : ℕ × ℕ | IsSeed x.1 x.2 ∧ charge (p : ℤ) q x.1 x.2 = k} :=
    ⟨(m, n), ⟨hs, hc⟩, rfl⟩
  exact absurd (hM this) (by omega)

/-- **The exact fan at an interior rational.** For coprime `0 < p < q`, the set of charges
realised by Euclid seeds at `p/q` is: all of `ℤ` if `p + q` is odd, and exactly the odd
integers if `p + q` is even. (Charge `0` is realised by the single node `(q,p)` in the first
case, by `axis_node_iff_parity`.) -/
theorem realised_charges_eq {p q : ℕ} (hp : 0 < p) (hpq : p < q) (hcop : Nat.Coprime p q) :
    {k : ℤ | ∃ m n : ℕ, IsSeed m n ∧ charge (p : ℤ) q m n = k}
      = if (p + q) % 2 = 1 then Set.univ else {k : ℤ | Odd k} := by
  have hq : 0 < q := lt_trans hp hpq
  by_cases hparity : (p + q) % 2 = 1
  · simp only [hparity, if_pos]
    ext k
    simp only [Set.mem_setOf_eq, Set.mem_univ, iff_true]
    by_cases hk : k = 0
    · subst hk
      exact (axis_node_iff_parity hp hpq hcop).mpr hparity
    · obtain ⟨m, n, hs, _, hc⟩ :=
        exists_seed_charge_gt hp hpq hcop hk (by omega) 0
      exact ⟨m, n, hs, hc⟩
  · simp only [hparity, if_false]
    have hpq0 : (p + q) % 2 = 0 := by omega
    -- both `p` and `q` are odd
    have hpodd : p % 2 = 1 := by
      rcases Nat.even_or_odd p with h | h
      · exfalso
        have hp2 : 2 ∣ p := h.two_dvd
        have hq2 : 2 ∣ q := by omega
        have := Nat.Coprime.eq_one_of_dvd (Nat.Coprime.coprime_dvd_left hp2 hcop) hq2
        omega
      · exact Nat.odd_iff.mp h
    have hqodd : q % 2 = 1 := by omega
    ext k
    simp only [Set.mem_setOf_eq]
    constructor
    · rintro ⟨m, n, hs, rfl⟩
      exact charge_odd_of_odd_odd (Int.odd_iff.mpr (by omega)) (Nat.odd_iff.mpr hqodd) hs
    · intro hkodd
      have hk : k ≠ 0 := by
        rintro rfl
        exact (Int.not_odd_iff_even.mpr ⟨0, by ring⟩) hkodd
      obtain ⟨m, n, hs, _, hc⟩ := exists_seed_charge_gt hp hpq hcop hk (fun _ => hkodd) 0
      exact ⟨m, n, hs, hc⟩

end BerggrenRationalStar