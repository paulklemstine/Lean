import Probability.PriceTwoAdicSealingDensity

/-!
# Depth-augmented sealing at every position: the depth is not the missing bit

`Probability/PriceTwoAdicSealingDensity.lean` proves that no function of the odd leg `N`
reads the Price letter at any position `t ≥ 2`, and that even the strictly stronger
classifier which also reads the **depth** of the node (a statistic that is *not* a function
of `N`) fails at the positions `t = 2, 3, 4, 5`, via ad-hoc equal-depth witnesses.  Whether
this persists at every position was left open (direction 3 of `FUTURE_DIRECTIONS.md`).

This file closes it.  The construction is a family of pairs of nodes given by their
**addresses**, which makes the depths equal by fiat and reduces the whole problem to one
odd-leg identity.  For `t = s + 3` put

```
dsWordX s = Aˢ⁺²  B  Aˢ⁺³                      (length 2s + 6 = 2t)
dsWordY s = C  Aˢ  C  Aˢ⁺⁴                     (length 2s + 6 = 2t)
```

Evaluating them (`eval_dsWordX`, `eval_dsWordY`) gives the two nodes

```
dsX s = (2^(s+4) + 1, 2^(s+3))
dsY s = (dsM s + 1, dsM s),      dsM s = 2^(s+4)·(3·2^(s+1) + 1)
```

which have the *same* odd leg `dsN s = 3·2^(2s+6) + 2^(s+5) + 1` — the two coprime
factorisations `N = (2^(s+4) − 2^(s+3))·(2^(s+4) + 2^(s+3) + …)` versus `N = 1 · N` — while
their second Euclid parameters have 2-adic valuations exactly `t = s+3` and exactly `t + 1`.
By `split_of_valuation_gap` the two addresses are all-`A` below `t` and split at `t`.

Main results:

* `dsX_dsY_split_equal_depth` — for every `s`, an equal-odd-leg, **equal-depth** splitting
  pair at position `s + 3`;
* `equal_depth_split_pair` — the same for every position `t ≥ 2` (position `2` is supplied
  by the witness `(13,8)`, `(53,52)` of the previous file);
* `no_oddLeg_depth_classifier` — **no function of the pair (odd leg, depth) computes the
  `A`-ness of the Price letter at any position `t ≥ 2`**, which strictly strengthens
  `no_oddLeg_classifier_pos` and removes the bound `t ≤ 5` of
  `no_oddLeg_depth_classifier_le_five`;
* `no_residue_depth_classifier` — in particular no `(N mod 2^k, depth)` classifier works.

## Lab notes (round 71, exp 552, continuation cycle 2)

An exhaustive scan of all odd `N < 10^5` and all their coprime factorisations records, for
each `t`, the smallest odd leg carrying an equal-depth splitting pair at position `t`:

| `t` | odd leg | nodes                    | common depth |
|-----|---------|--------------------------|--------------|
| `2` | `57`    | `(29,28)`, `(11,8)`      | `4`          |
| `3` | `105`   | `(13,8)`, `(19,16)`      | `5`          |
| `4` | `833`   | `(33,16)`, `(417,416)`   | `8`          |
| `5` | `2697`  | `(61,32)`, `(451,448)`   | `9`          |
| `6` | `12545` | `(129,64)`, `(6273,6272)`| `12`         |
| `7` | `47625` | `(253,128)`, `(7939,7936)`| `13`        |

The rows `t = 4, 6` are exactly `(dsX s, dsY s)` for `s = 1, 3`; the family below is that
pattern continued, and its two addresses were read off directly (`Aᵗ⁻¹BAᵗ` and
`CAᵗ⁻³CAᵗ⁺¹`) and then verified symbolically for `t = 3, …, 21` before being proved here.
-/

namespace Price2Adic

/-! ## Evaluating a run of `A`s -/

/-- Iterating the move `A : (m,n) ↦ (m+n, 2n)`. -/
theorem iterate_stepA (k m n : ℕ) :
    (step PriceLetter.A)^[k] (m, n) = (m + (2 ^ k - 1) * n, 2 ^ k * n) := by
  induction k generalizing m n with
  | zero => simp
  | succ k ih =>
      rw [Function.iterate_succ_apply, show step PriceLetter.A (m, n) = (m + n, 2 * n) from rfl,
        ih]
      have h1 : 1 ≤ (2 : ℕ) ^ k := Nat.one_le_two_pow
      obtain ⟨r, hr⟩ : ∃ r, (2 : ℕ) ^ k = r + 1 := ⟨2 ^ k - 1, by omega⟩
      have e1 : (2 : ℕ) ^ k - 1 = r := by omega
      have e2 : (2 : ℕ) ^ (k + 1) - 1 = 2 * r + 1 := by rw [pow_succ, hr]; omega
      have e3 : (2 : ℕ) ^ (k + 1) = 2 * (r + 1) := by rw [pow_succ, hr]; ring
      rw [e2, e1, e3, hr]
      simp only [Prod.mk.injEq]
      constructor <;> ring

/-- Appending a run of `A`s to a word iterates the move `A` on its value. -/
theorem eval_append_replicate_A (w : PriceWord) (k : ℕ) :
    eval (w ++ List.replicate k PriceLetter.A) = (step PriceLetter.A)^[k] (eval w) := by
  induction k with
  | zero => simp
  | succ k ih =>
      rw [List.replicate_succ' , ← List.append_assoc, eval_append_one, ih,
        Function.iterate_succ_apply']

/-! ## The two words and the two nodes -/

/-- The address `Aˢ⁺² B Aˢ⁺³` (length `2s + 6`). -/
def dsWordX (s : ℕ) : PriceWord :=
  (List.replicate (s + 2) PriceLetter.A ++ [PriceLetter.B]) ++
    List.replicate (s + 3) PriceLetter.A

/-- The address `C Aˢ C Aˢ⁺⁴` (length `2s + 6`). -/
def dsWordY (s : ℕ) : PriceWord :=
  (([PriceLetter.C] ++ List.replicate s PriceLetter.A) ++ [PriceLetter.C]) ++
    List.replicate (s + 4) PriceLetter.A

/-- The second Euclid parameter of the deep twin: `2^(s+4)·(3·2^(s+1) + 1)`, of 2-adic
valuation exactly `s + 4`. -/
def dsM (s : ℕ) : ℕ := 2 ^ (s + 4) * (3 * 2 ^ (s + 1) + 1)

/-- The shallow-valuation twin `(2^(s+4) + 1, 2^(s+3))`: valuation exactly `s + 3`. -/
def dsX (s : ℕ) : ℕ × ℕ := (2 ^ (s + 4) + 1, 2 ^ (s + 3))

/-- The deep-valuation twin `(dsM s + 1, dsM s)`: valuation exactly `s + 4`. -/
def dsY (s : ℕ) : ℕ × ℕ := (dsM s + 1, dsM s)

/-- The common odd leg of the two twins. -/
def dsN (s : ℕ) : ℕ := 2 * dsM s + 1

theorem dsWordX_length (s : ℕ) : (dsWordX s).length = 2 * s + 6 := by
  simp [dsWordX]; omega

theorem dsWordY_length (s : ℕ) : (dsWordY s).length = 2 * s + 6 := by
  simp [dsWordY]; omega

theorem eval_dsWordX (s : ℕ) : eval (dsWordX s) = dsX s := by
  have h0 : eval (List.replicate (s + 2) PriceLetter.A) = (2 ^ (s + 2) + 1, 2 ^ (s + 2)) := by
    have h := eval_append_replicate_A [] (s + 2)
    simp only [List.nil_append, eval_nil] at h
    rw [h, show root = (2, 1) from rfl, iterate_stepA]
    have h1 : 1 ≤ (2 : ℕ) ^ (s + 2) := Nat.one_le_two_pow
    simp only [Prod.mk.injEq]
    omega
  have h1 : eval (List.replicate (s + 2) PriceLetter.A ++ [PriceLetter.B])
      = (2 ^ (s + 3) + 2, 1) := by
    rw [eval_append_one, h0]
    show ((2 : ℕ) * (2 ^ (s + 2) + 1), 2 ^ (s + 2) + 1 - 2 ^ (s + 2)) = _
    have h3 : (2 : ℕ) ^ (s + 3) = 2 * 2 ^ (s + 2) := by rw [pow_succ]; ring
    simp only [Prod.mk.injEq]
    omega
  rw [dsWordX, eval_append_replicate_A, h1, iterate_stepA]
  have h1 : 1 ≤ (2 : ℕ) ^ (s + 3) := Nat.one_le_two_pow
  have h4 : (2 : ℕ) ^ (s + 4) = 2 * 2 ^ (s + 3) := by rw [pow_succ]; ring
  simp only [dsX, Prod.mk.injEq]
  omega

theorem eval_dsWordY (s : ℕ) : eval (dsWordY s) = dsY s := by
  have h0 : eval ([PriceLetter.C] ++ List.replicate s PriceLetter.A)
      = (3 * 2 ^ s + 1, 3 * 2 ^ s) := by
    rw [eval_append_replicate_A, show eval [PriceLetter.C] = (4, 3) from by decide,
      iterate_stepA]
    have h1 : 1 ≤ (2 : ℕ) ^ s := Nat.one_le_two_pow
    have h2 : (2 ^ s - 1) * 3 = 3 * 2 ^ s - 3 := by omega
    simp only [Prod.mk.injEq]
    omega
  have h1 : eval (([PriceLetter.C] ++ List.replicate s PriceLetter.A) ++ [PriceLetter.C])
      = (3 * 2 ^ (s + 1) + 2, 3 * 2 ^ (s + 1) + 1) := by
    rw [eval_append_one, h0]
    show ((2 : ℕ) * (3 * 2 ^ s + 1), (3 * 2 ^ s + 1) + 3 * 2 ^ s) = _
    have h2 : (3 : ℕ) * 2 ^ (s + 1) = 6 * 2 ^ s := by rw [pow_succ]; ring
    simp only [Prod.mk.injEq]
    omega
  rw [dsWordY, eval_append_replicate_A, h1, iterate_stepA]
  have h1 : 1 ≤ (2 : ℕ) ^ (s + 4) := Nat.one_le_two_pow
  obtain ⟨r, hr⟩ : ∃ r, (2 : ℕ) ^ (s + 4) = r + 1 := ⟨2 ^ (s + 4) - 1, by omega⟩
  rw [hr]
  simp only [dsY, dsM, hr, Prod.mk.injEq, Nat.add_sub_cancel]
  refine ⟨by ring, trivial⟩

/-! ## Validity, addresses and depths -/

theorem dsX_valid (s : ℕ) : Valid (dsX s) := by
  rw [← eval_dsWordX]; exact Valid_eval _

theorem dsY_valid (s : ℕ) : Valid (dsY s) := by
  rw [← eval_dsWordY]; exact Valid_eval _

theorem address_dsX (s : ℕ) : address (dsX s) = dsWordX s := by
  rw [← eval_dsWordX, address_eval]

theorem address_dsY (s : ℕ) : address (dsY s) = dsWordY s := by
  rw [← eval_dsWordY, address_eval]

/-- **Equal depth**: the two twins sit at the same level `2s + 6 = 2t` of the Price tree. -/
theorem address_dsX_length_eq_dsY (s : ℕ) :
    (address (dsX s)).length = (address (dsY s)).length := by
  rw [address_dsX, address_dsY, dsWordX_length, dsWordY_length]

theorem address_dsX_length (s : ℕ) : (address (dsX s)).length = 2 * s + 6 := by
  rw [address_dsX, dsWordX_length]

/-! ## The common odd leg -/

theorem oddLeg_dsX (s : ℕ) : oddLeg (dsX s) = dsN s := by
  have h4 : (2 : ℕ) ^ (s + 4) = 2 * 2 ^ (s + 3) := by rw [pow_succ]; ring
  have hsq : (2 ^ (s + 4) + 1) ^ 2
      = (2 ^ (s + 3)) ^ 2 + (2 * dsM s + 1) := by
    simp only [dsM]
    rw [show (2 : ℕ) ^ (s + 4) = 16 * 2 ^ s from by rw [pow_add]; ring,
      show (2 : ℕ) ^ (s + 3) = 8 * 2 ^ s from by rw [pow_add]; ring,
      show (2 : ℕ) ^ (s + 1) = 2 * 2 ^ s from by rw [pow_add]; ring]
    ring
  simp only [dsX, dsN, oddLeg]
  rw [hsq, Nat.add_sub_cancel_left]

theorem oddLeg_dsY (s : ℕ) : oddLeg (dsY s) = dsN s := by
  have hsq : (dsM s + 1) ^ 2 = (dsM s) ^ 2 + (2 * dsM s + 1) := by ring
  simp only [dsY, dsN, oddLeg]
  rw [hsq, Nat.add_sub_cancel_left]

/-- The twins share their odd leg. -/
theorem oddLeg_dsX_eq_dsY (s : ℕ) : oddLeg (dsX s) = oddLeg (dsY s) := by
  rw [oddLeg_dsX, oddLeg_dsY]

/-! ## The valuation gap -/

theorem pow_dvd_dsX (s : ℕ) : 2 ^ (s + 3) ∣ (dsX s).2 := dvd_rfl

theorem not_pow_dvd_dsX (s : ℕ) : ¬ 2 ^ (s + 4) ∣ (dsX s).2 := by
  intro h
  have hle : (2 : ℕ) ^ (s + 4) ≤ 2 ^ (s + 3) :=
    Nat.le_of_dvd (pow_pos (by norm_num) _) h
  have hlt : (2 : ℕ) ^ (s + 3) < 2 ^ (s + 4) :=
    Nat.pow_lt_pow_right (by norm_num) (by omega)
  omega

theorem pow_dvd_dsY (s : ℕ) : 2 ^ (s + 4) ∣ (dsY s).2 := ⟨3 * 2 ^ (s + 1) + 1, rfl⟩

/-! ## The splitting pair of equal depth -/

/-- **An equal-odd-leg, equal-depth splitting pair at position `s + 3`.**  Two valid Price
nodes with the same odd leg `dsN s` *and* the same depth `2s + 6`, all-`A` at every position
below `s + 3`, and disagreeing at position `s + 3`. -/
theorem dsX_dsY_split_equal_depth (s : ℕ) :
    Valid (dsX s) ∧ Valid (dsY s) ∧ oddLeg (dsX s) = oddLeg (dsY s) ∧
      (address (dsX s)).length = (address (dsY s)).length ∧
      s + 3 < (address (dsX s)).length ∧
      (∀ u < s + 3, (letterAt (dsX s) u = .A ↔ letterAt (dsY s) u = .A)) ∧
      ¬ (letterAt (dsX s) (s + 3) = .A ↔ letterAt (dsY s) (s + 3) = .A) := by
  obtain ⟨hagree, hXsplit, hYsplit⟩ :=
    split_of_valuation_gap (dsX s) (dsY s) (s + 3) (dsX_valid s) (dsY_valid s)
      (pow_dvd_dsX s) (not_pow_dvd_dsX s) (pow_dvd_dsY s)
  refine ⟨dsX_valid s, dsY_valid s, oddLeg_dsX_eq_dsY s, address_dsX_length_eq_dsY s,
    by rw [address_dsX_length]; omega, ?_, ?_⟩
  · intro u hu
    obtain ⟨h1, h2⟩ := hagree u hu
    rw [h1, h2]
  · exact fun hc => hXsplit (hc.mpr hYsplit)

/-- **Equal-depth splitting pairs at every position `t ≥ 2`.**  Position `2` is covered by
the witness `(13,8)`, `(53,52)` of `Probability/PriceTwoAdicSealingDensity.lean`, and every
position `t ≥ 3` by the family `(dsX, dsY)`. -/
theorem equal_depth_split_pair (t : ℕ) (ht : 2 ≤ t) :
    ∃ p q : ℕ × ℕ, Valid p ∧ Valid q ∧ oddLeg p = oddLeg q ∧
      (address p).length = (address q).length ∧ t < (address p).length ∧
      (∀ u < t, (letterAt p u = .A ↔ letterAt q u = .A)) ∧
      ¬ (letterAt p t = .A ↔ letterAt q t = .A) := by
  rcases Nat.lt_or_ge t 3 with h | h
  · obtain rfl : t = 2 := by omega
    obtain ⟨p, q, hp, hq, hleg, hlen, hdp, h0, h1, hsplit⟩ := pos2_split_equal_depth
    refine ⟨p, q, hp, hq, hleg, hlen, hdp, ?_, hsplit⟩
    intro u hu
    interval_cases u
    · exact h0
    · exact h1
  · obtain ⟨s, rfl⟩ : ∃ s, t = s + 3 := ⟨t - 3, by omega⟩
    exact ⟨dsX s, dsY s, dsX_dsY_split_equal_depth s⟩

/-- **The depth is not the missing bit, at any position.**  No function of the pair
(odd leg, depth) computes the `A`-ness of the Price letter at any position `t ≥ 2`.  This
closes the depth-augmented sealing conjecture: the Price address is sealed against the whole
cheap-data package `(N, depth)` from position `2` onwards. -/
theorem no_oddLeg_depth_classifier (t : ℕ) (ht : 2 ≤ t) (f : ℕ → ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → t < (address p).length →
        (letterAt p t = .A ↔ f (oddLeg p) (address p).length = true) := by
  obtain ⟨p, q, hp, hq, hleg, hlen, hdp, -, hsplit⟩ := equal_depth_split_pair t ht
  exact no_depth_classifier_of_pair hp hq hleg hlen hdp hsplit f

/-- **No `(N mod 2^k, depth)` classifier either.**  The 2-adic residue dial together with
the depth still misses every position `t ≥ 2`. -/
theorem no_residue_depth_classifier (t : ℕ) (ht : 2 ≤ t) (k : ℕ) (f : ℕ → ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → t < (address p).length →
        (letterAt p t = .A ↔ f (oddLeg p % 2 ^ k) (address p).length = true) :=
  no_oddLeg_depth_classifier t ht (fun N d => f (N % 2 ^ k) d)

/-! ## Infinitely many equal-depth splitting pairs at position `2`

The family above gives exactly one equal-depth pair per position, because the two word
shapes force their parameters.  At position `2` a second word family has a genuinely free
parameter: with `c j = 3·2^(j+1) + 1` (odd),

```
edWordX j = C A^j C A^2       ↦  edX j = (4·c j + 1, 4·c j)
edWordY j = B A^(j+3)         ↦  edY j = (2^(j+3) + 3, 2^(j+3))
```

both of length `j + 4`, with the common odd leg `edN j = 3·2^(j+4) + 9`, valuations exactly
`2` and `j + 3`.  Since `edN` is strictly increasing, position `2` is sealed against
`(odd leg, depth)` classifiers *eventually* as well: infinitely many odd legs carry an
equal-depth splitting pair.
-/

/-- The odd cofactor `3·2^(j+1) + 1` of the second Euclid parameter of `edX j`. -/
def edC (j : ℕ) : ℕ := 3 * 2 ^ (j + 1) + 1

/-- The address `C A^j C A^2` (length `j + 4`). -/
def edWordX (j : ℕ) : PriceWord :=
  (([PriceLetter.C] ++ List.replicate j PriceLetter.A) ++ [PriceLetter.C]) ++
    List.replicate 2 PriceLetter.A

/-- The address `B A^(j+3)` (length `j + 4`). -/
def edWordY (j : ℕ) : PriceWord :=
  [PriceLetter.B] ++ List.replicate (j + 3) PriceLetter.A

/-- The valuation-`2` member of the position-`2` family. -/
def edX (j : ℕ) : ℕ × ℕ := (4 * edC j + 1, 4 * edC j)

/-- The deep-valuation member of the position-`2` family. -/
def edY (j : ℕ) : ℕ × ℕ := (2 ^ (j + 3) + 3, 2 ^ (j + 3))

/-- The common odd leg of the position-`2` family. -/
def edN (j : ℕ) : ℕ := 3 * 2 ^ (j + 4) + 9

theorem edC_odd (j : ℕ) : edC j % 2 = 1 := by
  have h : (2 : ℕ) ∣ 3 * 2 ^ (j + 1) := Dvd.dvd.mul_left (dvd_pow_self 2 (by omega)) 3
  simp only [edC]
  omega

theorem edWordX_length (j : ℕ) : (edWordX j).length = j + 4 := by
  simp [edWordX]

theorem edWordY_length (j : ℕ) : (edWordY j).length = j + 4 := by
  simp [edWordY]

theorem eval_edWordX (j : ℕ) : eval (edWordX j) = edX j := by
  have h0 : eval ([PriceLetter.C] ++ List.replicate j PriceLetter.A)
      = (3 * 2 ^ j + 1, 3 * 2 ^ j) := by
    rw [eval_append_replicate_A, show eval [PriceLetter.C] = (4, 3) from by decide,
      iterate_stepA]
    have h1 : 1 ≤ (2 : ℕ) ^ j := Nat.one_le_two_pow
    have h2 : (2 ^ j - 1) * 3 = 3 * 2 ^ j - 3 := by omega
    simp only [Prod.mk.injEq]
    omega
  have h1 : eval (([PriceLetter.C] ++ List.replicate j PriceLetter.A) ++ [PriceLetter.C])
      = (3 * 2 ^ (j + 1) + 2, 3 * 2 ^ (j + 1) + 1) := by
    rw [eval_append_one, h0]
    show ((2 : ℕ) * (3 * 2 ^ j + 1), (3 * 2 ^ j + 1) + 3 * 2 ^ j) = _
    have h2 : (3 : ℕ) * 2 ^ (j + 1) = 6 * 2 ^ j := by rw [pow_succ]; ring
    simp only [Prod.mk.injEq]
    omega
  rw [edWordX, eval_append_replicate_A, h1, iterate_stepA]
  simp only [edX, edC, Prod.mk.injEq]
  norm_num
  omega

theorem eval_edWordY (j : ℕ) : eval (edWordY j) = edY j := by
  rw [edWordY, eval_append_replicate_A, show eval [PriceLetter.B] = (4, 1) from by decide,
    iterate_stepA]
  have h1 : 1 ≤ (2 : ℕ) ^ (j + 3) := Nat.one_le_two_pow
  simp only [edY, Prod.mk.injEq]
  omega

theorem edX_valid (j : ℕ) : Valid (edX j) := by
  rw [← eval_edWordX]; exact Valid_eval _

theorem edY_valid (j : ℕ) : Valid (edY j) := by
  rw [← eval_edWordY]; exact Valid_eval _

theorem address_edX_length (j : ℕ) : (address (edX j)).length = j + 4 := by
  rw [← eval_edWordX, address_eval, edWordX_length]

theorem address_edY_length (j : ℕ) : (address (edY j)).length = j + 4 := by
  rw [← eval_edWordY, address_eval, edWordY_length]

theorem oddLeg_edX (j : ℕ) : oddLeg (edX j) = edN j := by
  have hsq : (4 * edC j + 1) ^ 2 = (4 * edC j) ^ 2 + (8 * edC j + 1) := by ring
  have h : 8 * edC j + 1 = edN j := by
    simp only [edC, edN]
    rw [show (2 : ℕ) ^ (j + 4) = 8 * 2 ^ (j + 1) from by rw [pow_add, pow_add]; ring]
    ring
  simp only [oddLeg, edX]
  rw [hsq, Nat.add_sub_cancel_left, h]

theorem oddLeg_edY (j : ℕ) : oddLeg (edY j) = edN j := by
  have hsq : ((2 : ℕ) ^ (j + 3) + 3) ^ 2 = (2 ^ (j + 3)) ^ 2 + (3 * 2 ^ (j + 4) + 9) := by
    rw [show (2 : ℕ) ^ (j + 4) = 2 * 2 ^ (j + 3) from by rw [pow_succ]; ring]
    ring
  simp only [oddLeg, edY, edN]
  rw [hsq, Nat.add_sub_cancel_left]

theorem pow_dvd_edX (j : ℕ) : 2 ^ 2 ∣ (edX j).2 := ⟨edC j, by simp [edX]⟩

theorem not_pow_dvd_edX (j : ℕ) : ¬ 2 ^ 3 ∣ (edX j).2 := by
  rintro ⟨c, hc⟩
  have hodd := edC_odd j
  have h : 4 * edC j = 4 * (2 * c) := by simp only [edX] at hc; omega
  omega

theorem pow_dvd_edY (j : ℕ) : 2 ^ 3 ∣ (edY j).2 :=
  dvd_trans (pow_dvd_pow 2 (by omega)) (dvd_refl (2 ^ (j + 3)))

theorem edN_strictMono {i j : ℕ} (h : i < j) : edN i < edN j := by
  have : (2 : ℕ) ^ (i + 4) < 2 ^ (j + 4) := Nat.pow_lt_pow_right (by norm_num) (by omega)
  simp only [edN]
  omega

theorem edN_gt (j : ℕ) : j < edN j := by
  have h : j + 1 ≤ 2 ^ (j + 4) := le_trans (by omega) (Nat.lt_two_pow_self.le)
  simp only [edN]
  omega

/-- **An equal-depth splitting pair at position `2`, for every `j`.** -/
theorem edX_edY_split_equal_depth (j : ℕ) :
    Valid (edX j) ∧ Valid (edY j) ∧ oddLeg (edX j) = edN j ∧ oddLeg (edY j) = edN j ∧
      (address (edX j)).length = (address (edY j)).length ∧
      2 < (address (edX j)).length ∧
      (∀ u < 2, (letterAt (edX j) u = .A ↔ letterAt (edY j) u = .A)) ∧
      ¬ (letterAt (edX j) 2 = .A ↔ letterAt (edY j) 2 = .A) := by
  obtain ⟨hagree, hXsplit, hYsplit⟩ :=
    split_of_valuation_gap (edX j) (edY j) 2 (edX_valid j) (edY_valid j)
      (pow_dvd_edX j) (not_pow_dvd_edX j) (pow_dvd_edY j)
  refine ⟨edX_valid j, edY_valid j, oddLeg_edX j, oddLeg_edY j,
    by rw [address_edX_length, address_edY_length], by rw [address_edX_length]; omega, ?_, ?_⟩
  · intro u hu
    obtain ⟨h1, h2⟩ := hagree u hu
    rw [h1, h2]
  · exact fun hc => hXsplit (hc.mpr hYsplit)

/-- **Infinitely many equal-depth splitting pairs at position `2`.**  The set of odd legs
carrying two valid Price nodes of *equal depth* that agree at positions `0` and `1` and
split at position `2` is infinite. -/
theorem equal_depth_sealed_oddLegs_pos2_infinite :
    {N : ℕ | ∃ p q : ℕ × ℕ, Valid p ∧ Valid q ∧ oddLeg p = N ∧ oddLeg q = N ∧
      (address p).length = (address q).length ∧ 2 < (address p).length ∧
      (∀ u < 2, (letterAt p u = .A ↔ letterAt q u = .A)) ∧
      ¬ (letterAt p 2 = .A ↔ letterAt q 2 = .A)}.Infinite := by
  refine Set.infinite_of_injective_forall_mem (f := edN) ?_ ?_
  · intro i j h
    rcases lt_trichotomy i j with hlt | heq | hgt
    · exact absurd h (Nat.ne_of_lt (edN_strictMono hlt))
    · exact heq
    · exact absurd h.symm (Nat.ne_of_lt (edN_strictMono hgt))
  · intro j
    obtain ⟨h1, h2, h3, h4, h5, h6, h7, h8⟩ := edX_edY_split_equal_depth j
    exact ⟨edX j, edY j, h1, h2, h3, h4, h5, h6, h7, h8⟩

/-- **No eventually-correct `(odd leg, depth)` classifier at position `2`.**  Even a
classifier allowed to be wrong on all odd legs below an arbitrary threshold `B` fails, so
position `2` is sealed against `(N, depth)` generically, not only at sporadic witnesses. -/
theorem no_eventual_oddLeg_depth_classifier_pos2 (B : ℕ) (f : ℕ → ℕ → Bool) :
    ¬ ∀ p : ℕ × ℕ, Valid p → B < oddLeg p → 2 < (address p).length →
        (letterAt p 2 = .A ↔ f (oddLeg p) (address p).length = true) := by
  intro hf
  obtain ⟨hX, hY, hNX, hNY, hlen, hdX, -, hsplit⟩ := edX_edY_split_equal_depth B
  have hbig : B < edN B := edN_gt B
  refine hsplit ?_
  rw [hf (edX B) hX (by rw [hNX]; exact hbig) hdX,
    hf (edY B) hY (by rw [hNY]; exact hbig) (by omega), hNX, hNY, hlen]

end Price2Adic