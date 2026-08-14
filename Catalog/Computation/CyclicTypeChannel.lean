import Mathlib

/-!
# The cyclic splitting-type channel

For a cyclotomic field `ℚ(ζ_f)` with `f` prime, the Galois group is the cyclic group
`(ℤ/f)ˣ ≅ C_n` with `n = f - 1`, and the *splitting type* of an unramified prime `p` is
the residue degree `T(p) = ord_f(p)`, i.e. the order of the Frobenius element in `C_n`.
This file studies the resulting information channel entirely inside the finite cyclic model:
`C_n` is realised additively as `Fin n`, the *type* of an element `x` is its additive order
`typ n x = n / gcd n x`, and the *semiprime* observable is the unordered pair
`{T(x), T(y)}` together with the "norm" `N = x + y`.

Main results.

* `CyclicType.typeCount_eq_totient` : the type distribution is `P(T = d) = φ(d)/n`
  for every divisor `d` of `n` (structural, all `n`).
* `CyclicType.HT_eq` : the closed form `H(T) = log₂ n - (1/n) Σ_{d ∣ n} φ(d) log₂ φ(d)`.
* `CyclicType.Ires_eq_HT` : the type is a *deterministic* function of the residue, hence
  the residue→type channel is exact: `I(x ; T) = H(T)` for all `n`.
* `CyclicType.typ_congr` : "thickening zero" — the type depends only on the residue mod `n`.
* Exact channel values for the semiprime type-pair channel `I_pair`:
  `Ipair 2 = 1` (the binary fork cap), `Ipair 4 = 5/4`, `Ipair 6 = log₂ 3 - 1/9`,
  `Ipair 8 = 21/16`, `Ipair 16 = 85/64`, together with the strict statements
  `1 < Ipair 4`, `1 < Ipair 6`, `1 < Ipair 8` (the cap is exceeded) and
  `Ipair 3 < 1`, `Ipair 5 < 1` (odd orders stay below the cap).
* `CyclicType.Ipair_coprime_additive_12`, `..._10`, `..._15` : instances of the exact
  CRT-additivity law `I(mn) = I(m) + I(n)` for coprime `m, n`.
* `CyclicType.Ipair_double_odd_6`, `..._10`, `..._14` : instances of the doubling law
  `I(2m) = I(m) + 1` for odd `m`.
* `CyclicType.Hnr_lt_HT_four`, `Hnr_lt_HT_six` : the root-count readout is strictly lossy.
-/

set_option maxRecDepth 40000
set_option maxHeartbeats 1000000

namespace CyclicType

open scoped BigOperators

/-! ## The finite model -/

/-- The splitting type of a residue: the additive order of `x` in `ℤ/n`. -/
def typ (n : ℕ) (x : Fin n) : ℕ := n / Nat.gcd n x.val

/-- Type of a natural number as a residue mod `n` (used for the "thickening" statement). -/
def typNat (n a : ℕ) : ℕ := n / Nat.gcd n a

/-- The unordered type pair of a pair of residues. -/
def keyOf (n : ℕ) (w : Fin n × Fin n) : ℕ × ℕ :=
  (min (typ n w.1) (typ n w.2), max (typ n w.1) (typ n w.2))

/-- All ordered pairs of residues. -/
def allPairs (n : ℕ) : List (Fin n × Fin n) :=
  (List.finRange n).flatMap (fun x => (List.finRange n).map (fun y => (x, y)))

/-- The list of distinct unordered type pairs occurring. -/
def keyList (n : ℕ) : List (ℕ × ℕ) := ((allPairs n).map (keyOf n)).dedup

/-- The list of distinct types occurring. -/
def typeList (n : ℕ) : List ℕ := ((List.finRange n).map (typ n)).dedup

/-- Occupation numbers of the type states. -/
def typeCounts (n : ℕ) : List ℕ :=
  (typeList n).map (fun d => ((List.finRange n).filter (fun x => typ n x = d)).length)

/-- Occupation numbers of the unordered type pairs. -/
def pairCounts (n : ℕ) : List ℕ :=
  (keyList n).map (fun k => ((allPairs n).filter (fun w => keyOf n w = k)).length)

/-- Occupation numbers of the unordered type pairs conditioned on the norm `x + y = c`. -/
def condCounts (n : ℕ) (c : Fin n) : List ℕ :=
  (keyList n).map
    (fun k => ((allPairs n).filter (fun w => w.1 + w.2 = c ∧ keyOf n w = k)).length)

/-- Occupation numbers of the binary root-count readout (`T = 1` or `T ≠ 1`). -/
def nrCounts (n : ℕ) : List ℕ :=
  [((List.finRange n).filter (fun x => typ n x = 1)).length,
   ((List.finRange n).filter (fun x => typ n x ≠ 1)).length]

/-! ## Entropy -/

/-- Shannon entropy (in bits) of a distribution given by occupation numbers `cs`
out of a total of `tot`. This is the catalog's `shannonInfo` specialised to a
counting measure. -/
noncomputable def Hlist (tot : ℕ) (cs : List ℕ) : ℝ :=
  -((cs.map (fun c : ℕ => if c = 0 then 0 else (c : ℝ) / tot * Real.logb 2 ((c : ℝ) / tot))).sum)

/-- The table of conditional occupation numbers, one row per norm class. -/
def condTable (n : ℕ) : List (List ℕ) := (List.finRange n).map (condCounts n)

/-- Entropy of the splitting type. -/
noncomputable def HT (n : ℕ) : ℝ := Hlist n (typeCounts n)

/-- Entropy of the binary root-count readout. -/
noncomputable def Hnr (n : ℕ) : ℝ := Hlist n (nrCounts n)

/-- Entropy of the unordered semiprime type pair. -/
noncomputable def Hpair (n : ℕ) : ℝ := Hlist (n * n) (pairCounts n)

/-- Conditional entropy of the type pair given the norm class. -/
noncomputable def HpairGivenN (n : ℕ) : ℝ :=
  (1 / (n : ℝ)) * ((condTable n).map (Hlist n)).sum

/-- The semiprime type-pair channel capacity
`I_pair = H(Π) - (1/n) Σ_c H(Π_c)`. -/
noncomputable def Ipair (n : ℕ) : ℝ := Hpair n - HpairGivenN n

/-! ## The counting form of the entropy -/

private lemma sum_terms (tot : ℕ) (htot : 0 < tot) (cs : List ℕ) :
    (cs.map (fun c : ℕ => if c = 0 then 0 else (c : ℝ) / tot * Real.logb 2 ((c : ℝ) / tot))).sum
      = (1 / (tot : ℝ)) * (cs.map (fun c : ℕ => (c : ℝ) * Real.logb 2 c)).sum
        - ((cs.sum : ℕ) : ℝ) / tot * Real.logb 2 tot := by
  have htot0 : (0 : ℝ) < (tot : ℝ) := by exact_mod_cast htot
  induction cs with
  | nil => simp
  | cons c cs ih =>
      by_cases hc : c = 0
      · subst hc
        simp only [List.map_cons, List.sum_cons, ih, if_true, Nat.cast_zero, Real.logb_zero,
          mul_zero, zero_add]
      · have hc0 : (0 : ℝ) < (c : ℝ) := by exact_mod_cast Nat.pos_of_ne_zero hc
        have hdiv : Real.logb 2 ((c : ℝ) / tot) = Real.logb 2 c - Real.logb 2 tot :=
          Real.logb_div (ne_of_gt hc0) (ne_of_gt htot0)
        simp only [List.map_cons, List.sum_cons, ih, if_neg hc, hdiv, Nat.cast_add]
        field_simp
        ring

/-- Counting form: if the occupation numbers sum to the total, the entropy is
`log₂ tot - (1/tot) Σ c log₂ c`. -/
theorem Hlist_eq (tot : ℕ) (cs : List ℕ) (hsum : cs.sum = tot) (htot : 0 < tot) :
    Hlist tot cs
      = Real.logb 2 tot - (1 / (tot : ℝ)) * (cs.map (fun c : ℕ => (c : ℝ) * Real.logb 2 c)).sum := by
  have htot0 : (0 : ℝ) < (tot : ℝ) := by exact_mod_cast htot
  rw [Hlist, sum_terms tot htot cs, hsum]
  field_simp
  ring


/-! ## Structure of the type distribution

The type distribution is the Euler-φ law `P(T = d) = φ(d)/n` over the divisors of `n`.
-/

lemma typ_eq_typNat (n : ℕ) (x : Fin n) : typ n x = typNat n x.val := rfl

/-- "Thickening zero": the type only depends on the residue mod `n`, so refining the
observation from `p mod n` to `p mod n²` (or any finer modulus) adds no information. -/
theorem typ_congr {n a b : ℕ} (h : a ≡ b [MOD n]) : typNat n a = typNat n b := by
  unfold typNat
  congr 1
  rw [Nat.gcd_rec, Nat.gcd_rec n b, h]

/-- The type is a divisor of `n`. -/
theorem typNat_dvd (n a : ℕ) : typNat n a ∣ n :=
  Nat.div_dvd_of_dvd (Nat.gcd_dvd_left n a)

/-- Reformulation of "the type equals `d`" as a gcd condition. -/
theorem typNat_eq_iff {n d a : ℕ} (hn : 0 < n) (hd : d ∣ n) :
    typNat n a = d ↔ Nat.gcd n a = n / d := by
  have hg : Nat.gcd n a ∣ n := Nat.gcd_dvd_left n a
  constructor
  · intro h
    rw [← h, typNat, Nat.div_div_self hg hn.ne']
  · intro h
    rw [typNat, h, Nat.div_div_self hd hn.ne']

/-- **The Euler-φ type law.** For every divisor `d` of `n`, exactly `φ(d)` of the `n`
residues have splitting type `d`; equivalently `P(T = d) = φ(d)/n`. -/
theorem typeCount_eq_totient {n d : ℕ} (hn : 0 < n) (hd : d ∣ n) :
    ((Finset.range n).filter (fun k => typNat n k = d)).card = Nat.totient d := by
  have hdvd : n / d ∣ n := Nat.div_dvd_of_dvd hd
  have hdd : n / (n / d) = d := Nat.div_div_self hd hn.ne'
  have key := (Nat.totient_div_of_dvd hdvd).symm
  rw [hdd] at key
  rw [← key]
  exact congrArg Finset.card
    (Finset.filter_congr (fun k _ => by rw [typNat_eq_iff hn hd]))


/-! ## Evaluation machinery

Every entropy in this file is a finite sum of terms `c log₂ c`; `Ipair_eval` reduces the
channel capacity of a concrete cyclic order to arithmetic in `log₂ 2, log₂ 3, log₂ 5`.
-/

/-- The weighted log-sum `Σ c log₂ c` of a list of occupation numbers. -/
noncomputable def SL (cs : List ℕ) : ℝ := (cs.map (fun c : ℕ => (c : ℝ) * Real.logb 2 c)).sum

theorem Hlist_eq_SL (tot : ℕ) (cs : List ℕ) (hsum : cs.sum = tot) (htot : 0 < tot) :
    Hlist tot cs = Real.logb 2 tot - (1 / (tot : ℝ)) * SL cs := Hlist_eq tot cs hsum htot

/-- Reduction of the semiprime type-pair channel to explicit log-sums. -/
theorem Ipair_eval {n : ℕ} (hn : 0 < n) (P : List ℕ) (C : List (List ℕ))
    (hP : pairCounts n = P) (hC : condTable n = C)
    (hPs : P.sum = n * n) (hCs : ∀ r ∈ C, r.sum = n) :
    Ipair n = (Real.logb 2 ((n * n : ℕ) : ℝ) - (1 / ((n * n : ℕ) : ℝ)) * SL P)
      - (1 / (n : ℝ)) * (C.map (fun r => Real.logb 2 (n : ℝ) - (1 / (n : ℝ)) * SL r)).sum := by
  have hnn : 0 < n * n := Nat.mul_pos hn hn
  rw [Ipair, Hpair, HpairGivenN, hP, hC, Hlist_eq_SL (n * n) P hPs hnn,
    List.map_congr_left (fun r hr => Hlist_eq_SL n r (hCs r hr) hn)]

/-! ### Base-2 logarithms of the small integers that occur -/

lemma lb_2 : Real.logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num)

lemma lb_4 : Real.logb 2 (4 : ℝ) = 2 := by
  rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.logb_pow, lb_2]; ring

lemma lb_8 : Real.logb 2 (8 : ℝ) = 3 := by
  rw [show (8 : ℝ) = 2 ^ 3 by norm_num, Real.logb_pow, lb_2]; ring

lemma lb_16 : Real.logb 2 (16 : ℝ) = 4 := by
  rw [show (16 : ℝ) = 2 ^ 4 by norm_num, Real.logb_pow, lb_2]; ring

lemma lb_32 : Real.logb 2 (32 : ℝ) = 5 := by
  rw [show (32 : ℝ) = 2 ^ 5 by norm_num, Real.logb_pow, lb_2]; ring

lemma lb_64 : Real.logb 2 (64 : ℝ) = 6 := by
  rw [show (64 : ℝ) = 2 ^ 6 by norm_num, Real.logb_pow, lb_2]; ring

lemma lb_256 : Real.logb 2 (256 : ℝ) = 8 := by
  rw [show (256 : ℝ) = 2 ^ 8 by norm_num, Real.logb_pow, lb_2]; ring

lemma lb_6 : Real.logb 2 (6 : ℝ) = 1 + Real.logb 2 3 := by
  rw [show (6 : ℝ) = 2 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_2]

lemma lb_9 : Real.logb 2 (9 : ℝ) = 2 * Real.logb 2 3 := by
  rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.logb_pow]; ring

lemma lb_12 : Real.logb 2 (12 : ℝ) = 2 + Real.logb 2 3 := by
  rw [show (12 : ℝ) = 4 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_4]

lemma lb_36 : Real.logb 2 (36 : ℝ) = 2 + 2 * Real.logb 2 3 := by
  rw [show (36 : ℝ) = 6 ^ 2 by norm_num, Real.logb_pow, lb_6]; ring

lemma lb_72 : Real.logb 2 (72 : ℝ) = 3 + 2 * Real.logb 2 3 := by
  rw [show (72 : ℝ) = 2 * 36 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_2,
    lb_36]; ring

lemma lb_144 : Real.logb 2 (144 : ℝ) = 4 + 2 * Real.logb 2 3 := by
  rw [show (144 : ℝ) = 12 ^ 2 by norm_num, Real.logb_pow, lb_12]; ring

lemma lb_10 : Real.logb 2 (10 : ℝ) = 1 + Real.logb 2 5 := by
  rw [show (10 : ℝ) = 2 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_2]

lemma lb_25 : Real.logb 2 (25 : ℝ) = 2 * Real.logb 2 5 := by
  rw [show (25 : ℝ) = 5 ^ 2 by norm_num, Real.logb_pow]; ring

lemma lb_100 : Real.logb 2 (100 : ℝ) = 2 + 2 * Real.logb 2 5 := by
  rw [show (100 : ℝ) = 10 ^ 2 by norm_num, Real.logb_pow, lb_10]; ring

lemma lb_15 : Real.logb 2 (15 : ℝ) = Real.logb 2 3 + Real.logb 2 5 := by
  rw [show (15 : ℝ) = 3 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num)]

lemma lb_225 : Real.logb 2 (225 : ℝ) = 2 * Real.logb 2 3 + 2 * Real.logb 2 5 := by
  rw [show (225 : ℝ) = 15 ^ 2 by norm_num, Real.logb_pow, lb_15]; ring

lemma lb_14 : Real.logb 2 (14 : ℝ) = 1 + Real.logb 2 7 := by
  rw [show (14 : ℝ) = 2 * 7 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_2]

lemma lb_121 : Real.logb 2 (121 : ℝ) = 2 * Real.logb 2 11 := by
  rw [show (121 : ℝ) = 11 ^ 2 by norm_num, Real.logb_pow]; ring

lemma lb_169 : Real.logb 2 (169 : ℝ) = 2 * Real.logb 2 13 := by
  rw [show (169 : ℝ) = 13 ^ 2 by norm_num, Real.logb_pow]; ring

lemma lb_20 : Real.logb 2 (20 : ℝ) = 2 + Real.logb 2 5 := by
  rw [show (20 : ℝ) = 4 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_4]

lemma lb_18 : Real.logb 2 (18 : ℝ) = 1 + 2 * Real.logb 2 3 := by
  rw [show (18 : ℝ) = 2 * 9 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_2, lb_9]

lemma lb_24 : Real.logb 2 (24 : ℝ) = 3 + Real.logb 2 3 := by
  rw [show (24 : ℝ) = 8 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_8]

lemma lb_81 : Real.logb 2 (81 : ℝ) = 4 * Real.logb 2 3 := by
  rw [show (81 : ℝ) = 3 ^ 4 by norm_num, Real.logb_pow]; ring

lemma lb_324 : Real.logb 2 (324 : ℝ) = 2 + 4 * Real.logb 2 3 := by
  rw [show (324 : ℝ) = 4 * 81 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_4, lb_81]

lemma lb_400 : Real.logb 2 (400 : ℝ) = 4 + 2 * Real.logb 2 5 := by
  rw [show (400 : ℝ) = 16 * 25 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_16, lb_25]

lemma lb_49 : Real.logb 2 (49 : ℝ) = 2 * Real.logb 2 7 := by
  rw [show (49 : ℝ) = 7 ^ 2 by norm_num, Real.logb_pow]; ring

lemma lb_196 : Real.logb 2 (196 : ℝ) = 2 + 2 * Real.logb 2 7 := by
  rw [show (196 : ℝ) = 14 ^ 2 by norm_num, Real.logb_pow, lb_14]; ring

/-! ### Reduction lemmas for the single-prime channels -/

theorem HT_eval {n : ℕ} (hn : 0 < n) (TC : List ℕ) (hTC : typeCounts n = TC) (hs : TC.sum = n) :
    HT n = Real.logb 2 (n : ℝ) - (1 / (n : ℝ)) * SL TC := by
  rw [HT, hTC, Hlist_eq_SL n TC hs hn]

theorem Hnr_eval {n : ℕ} (hn : 0 < n) (NR : List ℕ) (hNR : nrCounts n = NR) (hs : NR.sum = n) :
    Hnr n = Real.logb 2 (n : ℝ) - (1 / (n : ℝ)) * SL NR := by
  rw [Hnr, hNR, Hlist_eq_SL n NR hs hn]

end CyclicType