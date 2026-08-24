import Probability.PriceTwoAdicAllPositions

/-!
# Sealing is not a single conspiracy: infinitely many splitting pairs at every position

`Probability/PriceTwoAdicAllPositions.lean` seals every position `t ≥ 2` of a Price address
against every function of the odd leg by exhibiting, for each `t`, *one* pair of valid nodes
with a common odd leg that agree below `t` and disagree at `t`.  A classifier could still
hope to be correct "for all but finitely many odd legs".

This file removes that hope.  We isolate the mechanism as two reusable lemmas

* `split_of_valuation_gap` — if two valid nodes `p`, `q` satisfy `v₂(p.2) = t` exactly and
  `2^(t+1) ∣ q.2`, then their addresses are all-`A` below position `t` and split at `t`;
* `depth_gt_of_pow_dvd` — a valid node with `2^L ∣ n` and `n / 2^L ≥ 2` has depth `> L`,

and then feed them a **two-parameter** family.  For `t = s + 2` and `u = 2v + 3` put

```
K       = 2^(s+1)·(4v² + 12v + 5) + (2v + 3)          (odd, ≥ 13)
famX s v = (2^(s+2)·K + 1, 2^(s+2)·K)                  (the factorisation N = 1·N)
famY s v = (2^(s+2)·(2v+3) + 1, 2^(s+3))               (the factorisation N = (m−n)(m+n))
```

Both are valid Price nodes of depth `> t` with the *same* odd leg

```
N = famN s v = 2^(s+3)·K + 1 = (2^(s+2)(2v+3) + 1)² − (2^(s+3))² ,
```

the second Euclid parameter of `famX s v` has 2-adic valuation exactly `t = s+2` (because
`K` is odd) while that of `famY s v` has valuation exactly `t + 1`.  Hence the pair splits
at position `t`, and `famN s v` is strictly increasing in `v`.

Consequences, for every `t ≥ 2`:

* `pos_sealed_at_family` — a splitting pair for every `(s, v)`;
* `sealed_oddLegs_infinite` — the set of odd legs carrying a splitting pair is infinite;
* `no_eventual_oddLeg_classifier` — no function of the odd leg reads position `t` even if it
  is allowed to be wrong on all odd legs below an arbitrary threshold `B`;
* `no_eventual_residue_classifier` — the same for any 2-adic residue `N mod 2^k`.

So the two-click law is sharp in the strong sense: beyond `N mod 8` the Price address is
sealed *generically*, not merely at sporadic witnesses.

## Lab notes (round 71, exp 552, continuation)

The enumeration in `scripts/price_two_adic_check.py` finds 6 124 same-odd-leg splitting
pairs at `t = 2` already among nodes with `m < 400` (smallest odd leg `N = 33`), consistent
with a positive density of splitting odd legs; the family above is the sub-family
`s = t − 2`, `v = 0, 1, 2, …` of that set, with odd legs
`N = 2^(s+3)·K + 1` growing quadratically in `v`.
-/

namespace Price2Adic

/-! ## Two reusable lemmas: depth from a valuation, and splitting from a valuation gap -/

/-- **Depth from a valuation.**  A valid node whose second Euclid parameter is divisible by
`2^L` with quotient at least `2` has address length at least `L + 1`: the whole `A`-run
`0, …, L` consists of genuine letters. -/
theorem depth_gt_of_pow_dvd (m n L : ℕ) (hp : Valid (m, n)) (hdvd : 2 ^ L ∣ n)
    (hbig : 2 ≤ n / 2 ^ L) : L + 1 ≤ (address (m, n)).length := by
  obtain ⟨-, hlt, -, -⟩ := id hp
  refine length_address_ge (L + 1) (m, n) hp ?_
  intro u hu
  have hdu : (2 : ℕ) ^ u ∣ n := dvd_trans (pow_dvd_pow 2 (by omega)) hdvd
  rw [iterate_parent_even m n (le_of_lt hlt) u hdu]
  have hle : (2 : ℕ) ^ u ≤ 2 ^ L := Nat.pow_le_pow_right (by norm_num) (by omega)
  have hmono : n / 2 ^ L ≤ n / 2 ^ u :=
    Nat.div_le_div_left hle (pow_pos (by norm_num) u)
  simp only [root, ne_eq, Prod.mk.injEq, not_and]
  omega

/-- **Splitting from a valuation gap.**  If `v₂(p.2) = t` exactly and `v₂(q.2) ≥ t + 1`,
then both addresses are all-`A` at every position below `t`, and at position `t` exactly one
of them is `A`.  This is the only mechanism used to seal positions. -/
theorem split_of_valuation_gap (p q : ℕ × ℕ) (t : ℕ) (hp : Valid p) (hq : Valid q)
    (hpd : 2 ^ t ∣ p.2) (hpnd : ¬ 2 ^ (t + 1) ∣ p.2) (hqd : 2 ^ (t + 1) ∣ q.2) :
    (∀ u < t, letterAt p u = .A ∧ letterAt q u = .A) ∧
      letterAt p t ≠ .A ∧ letterAt q t = .A := by
  obtain ⟨-, hplt, -, -⟩ := hp
  obtain ⟨-, hqlt, -, -⟩ := hq
  have hple : p.2 ≤ p.1 := le_of_lt hplt
  have hqle : q.2 ≤ q.1 := le_of_lt hqlt
  have hpair : ∀ r : ℕ × ℕ, (r.1, r.2) = r := fun r => rfl
  refine ⟨?_, ?_, ?_⟩
  · intro u hu
    have hpu : (2 : ℕ) ^ u ∣ p.2 := dvd_trans (pow_dvd_pow 2 (by omega)) hpd
    have hqu : (2 : ℕ) ^ u ∣ q.2 := dvd_trans (pow_dvd_pow 2 (by omega)) hqd
    have hP := letterAt_even_iff p.1 p.2 u hple hpu
    have hQ := letterAt_even_iff q.1 q.2 u hqle hqu
    rw [hpair p] at hP
    rw [hpair q] at hQ
    exact ⟨hP.mpr (dvd_trans (pow_dvd_pow 2 (by omega)) hpd),
      hQ.mpr (dvd_trans (pow_dvd_pow 2 (by omega)) hqd)⟩
  · have hP := letterAt_even_iff p.1 p.2 t hple hpd
    rw [hpair p] at hP
    exact fun hc => hpnd (hP.mp hc)
  · have hqt : (2 : ℕ) ^ t ∣ q.2 := dvd_trans (pow_dvd_pow 2 (by omega)) hqd
    have hQ := letterAt_even_iff q.1 q.2 t hqle hqt
    rw [hpair q] at hQ
    exact hQ.mpr hqd

/-! ## The two-parameter twin family -/

/-- The odd cofactor of the second Euclid parameter of `famX`. -/
def famK (s v : ℕ) : ℕ := 2 ^ (s + 1) * (4 * v ^ 2 + 12 * v + 5) + (2 * v + 3)

/-- The common odd leg of the twins `famX s v` and `famY s v`. -/
def famN (s v : ℕ) : ℕ := 2 ^ (s + 3) * famK s v + 1

/-- The twin coming from the trivial factorisation `N = 1 · N`: its second Euclid parameter
has 2-adic valuation exactly `s + 2`. -/
def famX (s v : ℕ) : ℕ × ℕ := (2 ^ (s + 2) * famK s v + 1, 2 ^ (s + 2) * famK s v)

/-- The twin coming from the factorisation `N = (m − n)(m + n)` with `n` a power of two: its
second Euclid parameter has 2-adic valuation exactly `s + 3`. -/
def famY (s v : ℕ) : ℕ × ℕ := (2 ^ (s + 2) * (2 * v + 3) + 1, 2 ^ (s + 3))

theorem famK_odd (s v : ℕ) : famK s v % 2 = 1 := by
  have h : (2 : ℕ) ∣ 2 ^ (s + 1) * (4 * v ^ 2 + 12 * v + 5) :=
    Dvd.dvd.mul_right (dvd_pow_self 2 (by omega)) _
  simp only [famK]
  omega

theorem famK_ge (s v : ℕ) : 13 ≤ famK s v := by
  have h1 : (2 : ℕ) ≤ 2 ^ (s + 1) := by
    calc (2 : ℕ) = 2 ^ 1 := by norm_num
    _ ≤ 2 ^ (s + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  have h2 : 5 ≤ 4 * v ^ 2 + 12 * v + 5 := by omega
  have := Nat.mul_le_mul h1 h2
  simp only [famK]
  omega

/-! ### Validity -/

theorem famX_valid (s v : ℕ) : Valid (famX s v) := by
  have hK := famK_ge s v
  have h1 : (1 : ℕ) ≤ 2 ^ (s + 2) := Nat.one_le_two_pow
  have hpos : 0 < 2 ^ (s + 2) * famK s v := Nat.mul_pos (by omega) (by omega)
  show Valid (2 ^ (s + 2) * famK s v + 1, 2 ^ (s + 2) * famK s v)
  refine ⟨hpos, by omega, ?_, by omega⟩
  show Nat.gcd (2 ^ (s + 2) * famK s v + 1) (2 ^ (s + 2) * famK s v) = 1
  have h : Nat.gcd (2 ^ (s + 2) * famK s v + 1) (2 ^ (s + 2) * famK s v) ∣
      (2 ^ (s + 2) * famK s v + 1) - (2 ^ (s + 2) * famK s v) :=
    Nat.dvd_sub (Nat.gcd_dvd_left _ _) (Nat.gcd_dvd_right _ _)
  rw [show (2 ^ (s + 2) * famK s v + 1) - (2 ^ (s + 2) * famK s v) = 1 from by omega] at h
  exact Nat.dvd_one.mp h

theorem famY_valid (s v : ℕ) : Valid (famY s v) := by
  have h2 : (2 : ℕ) ^ (s + 2) = 4 * 2 ^ s := by rw [pow_add]; ring
  have h3 : (2 : ℕ) ^ (s + 3) = 8 * 2 ^ s := by rw [pow_add]; ring
  have h1 : (1 : ℕ) ≤ 2 ^ s := Nat.one_le_two_pow
  have hodd : (2 ^ (s + 2) * (2 * v + 3) + 1) % 2 = 1 := by
    have : (2 : ℕ) ∣ 2 ^ (s + 2) * (2 * v + 3) :=
      Dvd.dvd.mul_right (dvd_pow_self 2 (by omega)) _
    omega
  show Valid (2 ^ (s + 2) * (2 * v + 3) + 1, 2 ^ (s + 3))
  refine ⟨by positivity, by nlinarith, ?_, by omega⟩
  show Nat.gcd (2 ^ (s + 2) * (2 * v + 3) + 1) (2 ^ (s + 3)) = 1
  have hcop : Nat.Coprime 2 (2 ^ (s + 2) * (2 * v + 3) + 1) :=
    (Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr (by omega)
  exact (hcop.pow_left (s + 3)).symm

/-! ### The common odd leg -/

theorem oddLeg_famX (s v : ℕ) : oddLeg (famX s v) = famN s v := by
  have h3 : (2 : ℕ) ^ (s + 3) = 2 * 2 ^ (s + 2) := by rw [pow_succ]; ring
  have hsq : (2 ^ (s + 2) * famK s v + 1) ^ 2
      = (2 ^ (s + 2) * famK s v) ^ 2 + (2 ^ (s + 3) * famK s v + 1) := by
    rw [h3]; ring
  simp only [famX, famN, oddLeg]
  rw [hsq, Nat.add_sub_cancel_left]

theorem oddLeg_famY (s v : ℕ) : oddLeg (famY s v) = famN s v := by
  have h1 : (2 : ℕ) ^ (s + 1) = 2 * 2 ^ s := by rw [pow_succ]; ring
  have h2 : (2 : ℕ) ^ (s + 2) = 4 * 2 ^ s := by rw [pow_add]; ring
  have h3 : (2 : ℕ) ^ (s + 3) = 8 * 2 ^ s := by rw [pow_add]; ring
  have hsq : (2 ^ (s + 2) * (2 * v + 3) + 1) ^ 2
      = (2 ^ (s + 3)) ^ 2 + (2 ^ (s + 3) * famK s v + 1) := by
    simp only [famK]
    rw [h1, h2, h3]
    ring
  simp only [famY, famN, oddLeg]
  rw [hsq, Nat.add_sub_cancel_left]

/-- The twins share their odd leg: two coprime factorisations of the same odd number. -/
theorem oddLeg_famX_eq_famY (s v : ℕ) : oddLeg (famX s v) = oddLeg (famY s v) := by
  rw [oddLeg_famX, oddLeg_famY]

/-! ### The valuation gap -/

theorem pow_dvd_famX (s v : ℕ) : 2 ^ (s + 2) ∣ (famX s v).2 := ⟨famK s v, rfl⟩

theorem not_pow_dvd_famX (s v : ℕ) : ¬ 2 ^ (s + 3) ∣ (famX s v).2 := by
  rintro ⟨c, hc⟩
  have hodd := famK_odd s v
  have hpos : 0 < (2 : ℕ) ^ (s + 2) := pow_pos (by norm_num) _
  have h : 2 ^ (s + 2) * famK s v = 2 ^ (s + 2) * (2 * c) := by
    simp only [famX] at hc
    rw [hc, pow_succ]
    ring
  have := Nat.eq_of_mul_eq_mul_left hpos h
  omega

theorem pow_dvd_famY (s v : ℕ) : 2 ^ (s + 3) ∣ (famY s v).2 := dvd_rfl

/-! ### Depth -/

theorem famX_depth (s v : ℕ) : s + 3 ≤ (address (famX s v)).length := by
  have hK := famK_ge s v
  have hdiv : 2 ^ (s + 2) * famK s v / 2 ^ (s + 2) = famK s v :=
    Nat.mul_div_cancel_left _ (pow_pos (by norm_num) _)
  exact depth_gt_of_pow_dvd _ _ (s + 2) (famX_valid s v) ⟨famK s v, rfl⟩ (by omega)

theorem famY_depth (s v : ℕ) : s + 3 ≤ (address (famY s v)).length := by
  have hdiv : (2 : ℕ) ^ (s + 3) / 2 ^ (s + 2) = 2 := by
    rw [show (2 : ℕ) ^ (s + 3) = 2 ^ (s + 2) * 2 from by rw [pow_succ]]
    exact Nat.mul_div_cancel_left _ (pow_pos (by norm_num) _)
  refine depth_gt_of_pow_dvd _ _ (s + 2) (famY_valid s v) ?_ (by omega)
  exact dvd_trans (pow_dvd_pow 2 (by omega)) (dvd_refl (2 ^ (s + 3)))

/-! ## Sealing at position `t = s + 2`, for every member of the family -/

/-- **A splitting pair for every `(s, v)`.**  Two valid Price nodes of depth `> s + 2` with
identical odd legs `famN s v`, agreeing (all `A`) at every position below `s + 2` and
disagreeing at position `s + 2`. -/
theorem pos_sealed_at_family (s v : ℕ) :
    Valid (famX s v) ∧ Valid (famY s v) ∧
      oddLeg (famX s v) = famN s v ∧ oddLeg (famY s v) = famN s v ∧
      s + 2 < (address (famX s v)).length ∧ s + 2 < (address (famY s v)).length ∧
      (∀ u < s + 2, (letterAt (famX s v) u = .A ↔ letterAt (famY s v) u = .A)) ∧
      ¬ (letterAt (famX s v) (s + 2) = .A ↔ letterAt (famY s v) (s + 2) = .A) := by
  obtain ⟨hagree, hXsplit, hYsplit⟩ :=
    split_of_valuation_gap (famX s v) (famY s v) (s + 2) (famX_valid s v) (famY_valid s v)
      (pow_dvd_famX s v) (not_pow_dvd_famX s v) (pow_dvd_famY s v)
  refine ⟨famX_valid s v, famY_valid s v, oddLeg_famX s v, oddLeg_famY s v,
    by have := famX_depth s v; omega, by have := famY_depth s v; omega, ?_, ?_⟩
  · intro u hu
    obtain ⟨h1, h2⟩ := hagree u hu
    rw [h1, h2]
  · exact fun hc => hXsplit (hc.mpr hYsplit)

/-! ## Growth: infinitely many sealed odd legs at every position -/

theorem famK_strictMono (s : ℕ) {v w : ℕ} (h : v < w) : famK s v < famK s w := by
  have hp : 0 < (2 : ℕ) ^ (s + 1) := pow_pos (by norm_num) _
  have hq : 4 * v ^ 2 + 12 * v + 5 < 4 * w ^ 2 + 12 * w + 5 := by nlinarith
  have := Nat.mul_lt_mul_of_pos_left hq hp
  simp only [famK]
  omega

theorem famN_strictMono (s : ℕ) {v w : ℕ} (h : v < w) : famN s v < famN s w := by
  have hp : 0 < (2 : ℕ) ^ (s + 3) := pow_pos (by norm_num) _
  have := Nat.mul_lt_mul_of_pos_left (famK_strictMono s h) hp
  simp only [famN]
  omega

theorem famN_ge (s v : ℕ) : v < famN s v := by
  have h1 : (1 : ℕ) ≤ 2 ^ (s + 3) := Nat.one_le_two_pow
  have hK : 2 * v + 3 ≤ famK s v := by
    have : 0 ≤ 2 ^ (s + 1) * (4 * v ^ 2 + 12 * v + 5) := Nat.zero_le _
    simp only [famK]; omega
  have : famK s v ≤ 2 ^ (s + 3) * famK s v := Nat.le_mul_of_pos_left _ (by omega)
  simp only [famN]
  omega

/-- The odd legs of the family are pairwise distinct. -/
theorem famN_injective (s : ℕ) : Function.Injective (famN s) := by
  intro v w h
  rcases lt_trichotomy v w with hlt | heq | hgt
  · exact absurd h (Nat.ne_of_lt (famN_strictMono s hlt))
  · exact heq
  · exact absurd h.symm (Nat.ne_of_lt (famN_strictMono s hgt))

/-- **Sealing is generic, not sporadic.**  For every position `t ≥ 2` the set of odd legs
that carry two valid Price nodes agreeing below `t` and splitting at `t` is infinite. -/
theorem sealed_oddLegs_infinite (t : ℕ) (ht : 2 ≤ t) :
    {N : ℕ | ∃ p q : ℕ × ℕ, Valid p ∧ Valid q ∧ oddLeg p = N ∧ oddLeg q = N ∧
      t < (address p).length ∧ t < (address q).length ∧
      (∀ u < t, (letterAt p u = .A ↔ letterAt q u = .A)) ∧
      ¬ (letterAt p t = .A ↔ letterAt q t = .A)}.Infinite := by
  obtain ⟨s, rfl⟩ : ∃ s, t = s + 2 := ⟨t - 2, by omega⟩
  refine Set.infinite_of_injective_forall_mem (f := famN s) (famN_injective s) ?_
  intro v
  obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8⟩ := pos_sealed_at_family s v
  exact ⟨famX s v, famY s v, h1, h2, h3, h4, h5, h6, h7, h8⟩

/-! ## No eventually-correct classifier -/

/-- **No function of the odd leg reads position `t ≥ 2`, even eventually.**  Allowing the
classifier `f` to be arbitrarily wrong on all odd legs `≤ B` does not help: there are
splitting pairs with arbitrarily large odd legs. -/
theorem no_eventual_oddLeg_classifier (t : ℕ) (ht : 2 ≤ t) (B : ℕ) (f : ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → B < oddLeg p → t < (address p).length →
        (letterAt p t = .A ↔ f (oddLeg p) = true) := by
  intro hf
  obtain ⟨s, rfl⟩ : ∃ s, t = s + 2 := ⟨t - 2, by omega⟩
  obtain ⟨hX, hY, hNX, hNY, hdX, hdY, -, hsplit⟩ := pos_sealed_at_family s B
  have hbig : B < famN s B := famN_ge s B
  refine hsplit ?_
  rw [hf (famX s B) hX (by rw [hNX]; exact hbig) hdX,
    hf (famY s B) hY (by rw [hNY]; exact hbig) hdY, hNX, hNY]

/-- **No 2-adic residue reads position `t ≥ 2`, even eventually.**  Together with
`two_clicks_visible` this is the sharp form of the two-click law: the residue dial `N mod 8`
is exactly the whole of the 2-adic information in a Price address, and no threshold on the
size of `N` recovers anything more. -/
theorem no_eventual_residue_classifier (t : ℕ) (ht : 2 ≤ t) (B k : ℕ) (f : ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → B < oddLeg p → t < (address p).length →
        (letterAt p t = .A ↔ f (oddLeg p % 2 ^ k) = true) :=
  no_eventual_oddLeg_classifier t ht B (fun N => f (N % 2 ^ k))

/-! ## One extra piece of side information: the depth

The depth of a node is *not* a function of its odd leg, so a classifier that reads the pair
`(N, depth)` is strictly stronger than one reading `N` alone.  It still fails at position
`2`: the two nodes

```
(13, 8)  = eval [A, B, A, A, A]      (13² − 8²  = 105)
(53, 52) = eval [C, A, C, A, A]      (53² − 52² = 105)
```

have the same odd leg `105` *and* the same depth `5`, the same `A`-nesses at positions `0`
and `1` (both `A`, as forced by `105 ≡ 1 mod 8`), and split at position `2`
(`A` versus `C`).
-/

theorem address_of_13_8 : address (13, 8) = [.A, .B, .A, .A, .A] := by
  have h : eval [PriceLetter.A, .B, .A, .A, .A] = (13, 8) := by decide
  rw [← h, address_eval]

theorem address_of_53_52 : address (53, 52) = [.C, .A, .C, .A, .A] := by
  have h : eval [PriceLetter.C, .A, .C, .A, .A] = (53, 52) := by decide
  rw [← h, address_eval]

/-- **A splitting pair of equal depth.**  Two valid Price nodes with the same odd leg
`N = 105` *and* the same address length `5`, agreeing at positions `0` and `1` and
disagreeing at position `2`. -/
theorem pos2_split_equal_depth :
    ∃ p q : ℕ × ℕ, Valid p ∧ Valid q ∧ oddLeg p = oddLeg q ∧
      (address p).length = (address q).length ∧ 2 < (address p).length ∧
      (letterAt p 0 = .A ↔ letterAt q 0 = .A) ∧
      (letterAt p 1 = .A ↔ letterAt q 1 = .A) ∧
      ¬ (letterAt p 2 = .A ↔ letterAt q 2 = .A) := by
  refine ⟨(13, 8), (53, 52), by decide, by decide, by decide, ?_, ?_, by decide, by decide,
    by decide⟩
  · rw [address_of_13_8, address_of_53_52]; rfl
  · rw [address_of_13_8]; decide

/-- The abstract step: an equal-odd-leg, equal-depth splitting pair at position `t` defeats
every classifier reading the pair (odd leg, depth). -/
theorem no_depth_classifier_of_pair {t : ℕ} {p q : ℕ × ℕ} (hp : Valid p) (hq : Valid q)
    (hleg : oddLeg p = oddLeg q) (hlen : (address p).length = (address q).length)
    (hdp : t < (address p).length)
    (hsplit : ¬ (letterAt p t = .A ↔ letterAt q t = .A)) (f : ℕ → ℕ → Bool) :
    ¬ ∀ r : ℕ × ℕ, Valid r → t < (address r).length →
        (letterAt r t = .A ↔ f (oddLeg r) (address r).length = true) := by
  intro hf
  exact hsplit (by rw [hf p hp hdp, hf q hq (by omega), hleg, hlen])

/-- **The depth is not the missing bit.**  No function of the pair (odd leg, depth) computes
the `A`-ness of the letter at position `2`.  Since the depth is not determined by the odd
leg, this strictly strengthens `no_oddLeg_classifier_pos` at `t = 2`. -/
theorem no_oddLeg_depth_classifier_pos2 (f : ℕ → ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → 2 < (address p).length →
        (letterAt p 2 = .A ↔ f (oddLeg p) (address p).length = true) := by
  obtain ⟨p, q, hp, hq, hleg, hlen, hdp, -, -, hsplit⟩ := pos2_split_equal_depth
  exact no_depth_classifier_of_pair hp hq hleg hlen hdp hsplit f

/-! ### Equal-depth witnesses at positions `3`, `4`, `5`

| `t` | odd leg | nodes                | addresses            | depth |
|-----|---------|----------------------|----------------------|-------|
| `3` | `105`   | `(13,8)`, `(19,16)`  | `ABAAA`, `BAAAA`     | `5`   |
| `4` | `315`   | `(22,13)`, `(26,19)` | `AABAC`, `BABAC`     | `5`   |
| `5` | `1485`  | `(41,14)`, `(73,62)` | `ABBABA`, `BBBACA`   | `6`   |
-/

theorem address_of_19_16 : address (19, 16) = [.B, .A, .A, .A, .A] := by
  have h : eval [PriceLetter.B, .A, .A, .A, .A] = (19, 16) := by decide
  rw [← h, address_eval]

theorem address_of_22_13 : address (22, 13) = [.A, .A, .B, .A, .C] := by
  have h : eval [PriceLetter.A, .A, .B, .A, .C] = (22, 13) := by decide
  rw [← h, address_eval]

theorem address_of_26_19 : address (26, 19) = [.B, .A, .B, .A, .C] := by
  have h : eval [PriceLetter.B, .A, .B, .A, .C] = (26, 19) := by decide
  rw [← h, address_eval]

theorem address_of_41_14 : address (41, 14) = [.A, .B, .B, .A, .B, .A] := by
  have h : eval [PriceLetter.A, .B, .B, .A, .B, .A] = (41, 14) := by decide
  rw [← h, address_eval]

theorem address_of_73_62 : address (73, 62) = [.B, .B, .B, .A, .C, .A] := by
  have h : eval [PriceLetter.B, .B, .B, .A, .C, .A] = (73, 62) := by decide
  rw [← h, address_eval]

/-- **The depth does not unlock positions `3`, `4`, `5` either.**  For each `t` with
`2 ≤ t ≤ 5` there is an equal-odd-leg, equal-depth splitting pair at position `t`, so no
function of (odd leg, depth) computes the `A`-ness at position `t`.  Whether this persists
for all `t ≥ 2` is the open depth-augmented sealing conjecture. -/
theorem no_oddLeg_depth_classifier_le_five (t : ℕ) (h2 : 2 ≤ t) (h5 : t ≤ 5)
    (f : ℕ → ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → t < (address p).length →
        (letterAt p t = .A ↔ f (oddLeg p) (address p).length = true) := by
  interval_cases t
  · exact no_oddLeg_depth_classifier_pos2 f
  · refine no_depth_classifier_of_pair (t := 3) (p := (13, 8)) (q := (19, 16))
      (by decide) (by decide) (by decide) ?_ ?_ (by decide) f
    · rw [address_of_13_8, address_of_19_16]; rfl
    · rw [address_of_13_8]; decide
  · refine no_depth_classifier_of_pair (t := 4) (p := (22, 13)) (q := (26, 19))
      (by decide) (by decide) (by decide) ?_ ?_ (by decide) f
    · rw [address_of_22_13, address_of_26_19]; rfl
    · rw [address_of_22_13]; decide
  · refine no_depth_classifier_of_pair (t := 5) (p := (41, 14)) (q := (73, 62))
      (by decide) (by decide) (by decide) ?_ ?_ (by decide) f
    · rw [address_of_41_14, address_of_73_62]; rfl
    · rw [address_of_41_14]; decide

end Price2Adic