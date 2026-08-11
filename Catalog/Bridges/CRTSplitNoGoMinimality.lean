import Bridges.CRTSplitNoGoBounds

/-!
# The CRT-Split No-Go, Part III: minimality of the reveal time and the multiplicative regime

Two deepenings of Parts I–II.

* **Minimality of the CTST reveal (regime (a), fully verified).**  For the demo
  `N = 341371 = 631·541`, `f(x) = x²+1`, seed `2`, *no* pair `s < t ≤ 35` reveals a factor
  (`crt_demo_first_reveal`).  Combined with `crt_demo_gcd` this pins the first reveal at
  `t = 36`, which is exactly the first mod-`631` cycle closure — and `√631 ≈ 25.1`, so the
  reveal time sits at the birthday scale `√p`, not at any polynomial in `log N ≈ 18.4`.

  The proof is *not* a brute-force gcd check: it goes through the structural theorem
  `no_reveal_before_closure`, so what is verified computationally is only the injectivity of
  the two reduced orbits — precisely the mechanism the theory predicts.

* **The multiplicative regime (bridge between regimes (b) and (c)).**  For `x ↦ a·x` the
  reveal time is bounded below by the smaller multiplicative order of `a`
  (`multiplicative_reveal_lower_bound`), the exact group-theoretic analogue of the
  arithmetic bound `min p q` for `x ↦ x+1`.

## Lab Notes (experiment CTST, replicated)

Pollard-rho map `x ↦ x²+1`, seed `2`, first revealing pair `(s,t)` for random balanced
semiprimes `N = p·q`; `r = t / √(min p q)`:

```
bits  p       q       (s,t)      factor   r      log₂ t
 9    509     257     (0,9)      509      0.56   3.17
10    1013    827     (14,31)    1013     1.08   4.95
11    1951    1627    (33,40)    1627     0.99   5.32
12    3923    3259    (37,63)    3923     1.10   5.98
13    7789    6073    (21,81)    6073     1.04   6.34
14    12437   15373   (84,113)   12437    1.01   6.82
15    30367   24517   (15,146)   30367    0.93   7.19
16    58943   62219   (173,218)  58943    0.90   7.77
17    97547   115067  (303,422)  97547    1.35   8.72
18    147011  177623  (223,364)  147011   0.95   8.51
19    325081  347587  (423,523)  325081   0.92   9.03
```

`r` stays `O(1)` (mean 0.66–1.59 over the whole range) while `log₂ t` grows linearly in the
bit size: the reveal time tracks `√p = N^{1/4}`, i.e. it is exponential in `log N`.  In every
run the revealed factor is exactly the prime whose reduced orbit closed first.
-/

namespace CRTSplitNoGo

open Polynomial

/-! ## The mod-`N` trace computes the reduced orbit -/

lemma rhoTrace_lt {m : ℕ} (hm : 2 < m) (n : ℕ) : rhoTrace m n < m := by
  cases n with
  | zero => simpa [rhoTrace] using hm
  | succ n => exact Nat.mod_lt _ (by omega)

/-- The `ℕ`-valued trace is the reduced orbit of `x² + 1` in `ZMod m`. -/
lemma rhoTrace_cast (m : ℕ) (n : ℕ) :
    ((rhoTrace m n : ℕ) : ZMod m) = modOrbit (X ^ 2 + 1) m 2 n := by
  rw [← polyOrbit_cast]
  have h := dvd_polyOrbit_sub_rhoTrace m n
  have := (intCast_sub_eq_zero_iff m (polyOrbit (X ^ 2 + 1) 2 n) (rhoTrace m n : ℤ)).mpr h
  rw [this]
  push_cast
  ring

/-- For `m > 2` a closure of the reduced orbit is an equality of trace values. -/
lemma modOrbit_eq_iff_rhoTrace {m : ℕ} (hm : 2 < m) (s t : ℕ) :
    modOrbit (X ^ 2 + 1) m 2 t = modOrbit (X ^ 2 + 1) m 2 s ↔ rhoTrace m t = rhoTrace m s := by
  rw [← rhoTrace_cast, ← rhoTrace_cast, ZMod.natCast_eq_natCast_iff',
    Nat.mod_eq_of_lt (rhoTrace_lt hm t), Nat.mod_eq_of_lt (rhoTrace_lt hm s)]

/-! ## Verified injectivity of the two reduced orbits up to time 35 -/

set_option maxRecDepth 40000 in
lemma rhoTrace_631_nodup : ((List.range 36).map (rhoTrace 631)).Nodup := by decide

set_option maxRecDepth 40000 in
lemma rhoTrace_541_nodup : ((List.range 36).map (rhoTrace 541)).Nodup := by decide

lemma rhoTrace_inj_of_nodup {m : ℕ} (h : ((List.range 36).map (rhoTrace m)).Nodup)
    {s t : ℕ} (hs : s < 36) (ht : t < 36) (hst : rhoTrace m t = rhoTrace m s) : t = s := by
  have hinj := (List.nodup_map_iff_inj_on (List.nodup_range)).mp h
  exact hinj t (List.mem_range.mpr ht) s (List.mem_range.mpr hs) hst

/-- **Minimality of the CTST reveal.**  No pair of times `s < t ≤ 35` reveals a factor of
`341371 = 631 · 541` along the orbit of `x ↦ x² + 1` from the seed `2`.  Together with
`crt_demo_gcd` (a reveal at `(23,36)`) this identifies `t = 36` as the exact first reveal
time, i.e. as the first mod-`631` cycle closure. -/
theorem crt_demo_first_reveal (s t : ℕ) (hst : s < t) (ht : t ≤ 35) :
    ¬ RevealsFactor (631 * 541) (polyOrbit (X ^ 2 + 1) 2 t - polyOrbit (X ^ 2 + 1) 2 s) := by
  have hp : Nat.Prime 631 := by norm_num
  have hq : Nat.Prime 541 := by norm_num
  refine no_reveal_before_closure hp hq (by norm_num) (X ^ 2 + 1) 2 35 ?_ ?_ s t hst ht
  · intro s' t' hst' ht' hclos
    rw [modOrbit_eq_iff_rhoTrace (by norm_num)] at hclos
    have := rhoTrace_inj_of_nodup rhoTrace_631_nodup (by omega) (by omega) hclos
    omega
  · intro s' t' hst' ht' hclos
    rw [modOrbit_eq_iff_rhoTrace (by norm_num)] at hclos
    have := rhoTrace_inj_of_nodup rhoTrace_541_nodup (by omega) (by omega) hclos
    omega

/-! ## The multiplicative regime `x ↦ a · x` -/

lemma polyOrbit_mul (a x0 : ℤ) (n : ℕ) : polyOrbit (C a * X) x0 n = a ^ n * x0 := by
  induction n with
  | zero => simp
  | succ n ih => rw [polyOrbit_succ, ih]; simp; ring

/-- If a prime `p` divides `a^t x₀ - a^s x₀` while dividing neither `a` nor `x₀`, then the
multiplicative order of `a` mod `p` divides the time gap. -/
lemma orderOf_dvd_of_dvd_orbit_sub {p : ℕ} (hp : p.Prime) {a x0 : ℤ} (ha : ¬ (p : ℤ) ∣ a)
    (hx : ¬ (p : ℤ) ∣ x0) {s t : ℕ} (hst : s ≤ t)
    (h : (p : ℤ) ∣ a ^ t * x0 - a ^ s * x0) : orderOf ((a : ZMod p)) ∣ t - s := by
  have hpI : Prime ((p : ℕ) : ℤ) := Nat.prime_iff_prime_int.mp hp
  obtain ⟨d, rfl⟩ : ∃ d, t = s + d := ⟨t - s, by omega⟩
  have hd : s + d - s = d := by omega
  rw [hd]
  have hfac : a ^ (s + d) * x0 - a ^ s * x0 = a ^ s * ((a ^ d - 1) * x0) := by
    rw [pow_add]; ring
  rw [hfac] at h
  have h1 : (p : ℤ) ∣ (a ^ d - 1) * x0 := by
    rcases (hpI.dvd_mul.mp h) with h' | h'
    · exact absurd (hpI.dvd_of_dvd_pow h') ha
    · exact h'
  have h2 : (p : ℤ) ∣ a ^ d - 1 := by
    rcases (hpI.dvd_mul.mp h1) with h' | h'
    · exact h'
    · exact absurd h' hx
  rw [orderOf_dvd_iff_pow_eq_one]
  have h3 : (((a ^ d - 1 : ℤ)) : ZMod p) = 0 := (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mpr h2
  push_cast at h3
  exact sub_eq_zero.mp h3

/-- **Multiplicative regime lower bound.**  For the `N`-explicit map `x ↦ a · x` a reveal at
times `s < t` forces the gap `t - s` to be at least the smaller of the two multiplicative
orders of `a`.  This is the group-theoretic form of the barrier: the cost is an order, a
quantity determined by `p` and `q` and invisible from `N`. -/
theorem multiplicative_reveal_lower_bound {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    {a x0 : ℤ} (hpa : ¬ (p : ℤ) ∣ a) (hpx : ¬ (p : ℤ) ∣ x0)
    (hqa : ¬ (q : ℤ) ∣ a) (hqx : ¬ (q : ℤ) ∣ x0) {s t : ℕ} (hst : s < t)
    (hrev : RevealsFactor (p * q) (polyOrbit (C a * X) x0 t - polyOrbit (C a * X) x0 s)) :
    min (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) ≤ t - s := by
  rw [polyOrbit_mul, polyOrbit_mul, crt_reveal_iff hp hq hne] at hrev
  have hgap : 0 < t - s := by omega
  rcases hrev with ⟨h, -⟩ | ⟨h, -⟩
  · exact le_trans (min_le_left _ _)
      (Nat.le_of_dvd hgap (orderOf_dvd_of_dvd_orbit_sub hp hpa hpx (le_of_lt hst) h))
  · exact le_trans (min_le_right _ _)
      (Nat.le_of_dvd hgap (orderOf_dvd_of_dvd_orbit_sub hq hqa hqx (le_of_lt hst) h))

end CRTSplitNoGo