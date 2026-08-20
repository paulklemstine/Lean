/-
# A `q`-analogue of Lucas' theorem

Kummer's theorem (the valuation statement) and Lucas' theorem (the congruence statement) are the
two faces of the same base-`ℓ` combinatorics.  `Catalog/NumberTheory/QKummer/Valuation.lean`
established the `q`-Kummer side; this file establishes the `q`-Lucas side.

Fix `q ≥ 2` and a prime `ℓ ∤ q`, and let `d = ord_ℓ(q)` be the multiplicative order of `q`
modulo `ℓ`.  Write `n = d N + r` and `k = d A + s` with `0 ≤ r, s < d`.  Then

`binom(n,k)_q ≡ C(N,A) · binom(r,s)_q  (mod ℓ)`.

The Gaussian binomial coefficient therefore factors, modulo `ℓ`, into a **classical** binomial
coefficient in the "block" variables and a **`q`-binomial** coefficient in the residual digits:
the `q`-Pascal triangle is, mod `ℓ`, the tensor product of the classical Pascal triangle with a
single `d × d` block.  When `s > r` — a base-`d` carry — the residual factor `binom(r,s)_q`
vanishes identically, and the congruence records the fact that `ℓ` divides `binom(n,k)_q`,
in agreement with the `q`-Kummer valuation formula.

The engine is the exact three-factor splitting of the `q`-factorial
(`qFact_eq_qFactRed_mul_pow`)

`[n]_q! = Red_d(n) · [d]_q^{⌊n/d⌋} · [⌊n/d⌋]_{q^d}!`,

where `Red_d(n)` is the product of the `[m]_q` with `d ∤ m ≤ n`.  Feeding it into
`qFact_mul_qBinom` and cancelling the common factors produces the **exact** identities over `ℕ`

* `Red(k) · Red(n-k) · binom(n,k)_q = Red(n) · binom(N,A)_{q^d}` (no carry), and
* `Red(k) · Red(n-k) · binom(n,k)_q = Red(n) · [d]_q · [N]_{q^d} · binom(N-1,A)_{q^d}` (carry),

in which every factor apart from the binomial coefficients is a unit modulo `ℓ`.  Since
`q^d ≡ 1 (mod ℓ)`, the `q^d`-binomial coefficient degenerates to the classical one
(`qBinom_cast_of_q_eq_one`), while in the carry case the factor `[d]_q` is divisible by `ℓ`.

Two features are worth noting.  First, no oddness hypothesis on `ℓ` is needed: the argument only
uses that `ZMod ℓ` is a field.  Second, there is **no bound on `N`** — the naive cancellation
argument would need `N < ℓ`, but routing the block product through `binom(N,A)_{q^d}` removes the
restriction entirely.
-/
import Catalog.NumberTheory.QKummer.Periodicity
import Catalog.NumberTheory.QKummer.Corollaries

namespace QKummer

open Finset

/-- `IsQLucas q ℓ d` records the three facts about the period `d` that a `q`-Lucas congruence
needs: `ℓ` kills `[d]_q`, `q^d = 1` in `ZMod ℓ`, and no earlier `q`-integer is killed.  For
`d = ord_ℓ(q) > 1` all three hold (`isQLucas_orderOf`). -/
structure IsQLucas (q ℓ d : ℕ) : Prop where
  /-- The period is positive. -/
  pos : 0 < d
  /-- `ℓ` divides `[d]_q`. -/
  vanish : ((qNat q d : ℕ) : ZMod ℓ) = 0
  /-- `q^d = 1` modulo `ℓ`. -/
  powOne : ((q : ℕ) : ZMod ℓ) ^ d = 1
  /-- No smaller positive `q`-integer is divisible by `ℓ`. -/
  unit : ∀ i, 0 < i → i < d → ((qNat q i : ℕ) : ZMod ℓ) ≠ 0

section Degenerate

variable {q ℓ : ℕ}

/-- When `q ≡ 1 (mod ℓ)` the `q`-integers degenerate: `[m]_q ≡ m`. -/
theorem qNat_cast_of_q_eq_one (hq1 : ((q : ℕ) : ZMod ℓ) = 1) (m : ℕ) :
    ((qNat q m : ℕ) : ZMod ℓ) = (m : ZMod ℓ) := by
  induction m with
  | zero => simp [qNat]
  | succ m ih =>
      rw [qNat_succ, Nat.cast_add, ih, Nat.cast_pow, hq1, one_pow]
      push_cast
      ring

/-- **Degeneration of the Gaussian binomial coefficient.**  If `q ≡ 1 (mod ℓ)` then
`binom(n,k)_q ≡ C(n,k) (mod ℓ)` for *all* `n, k`.  The proof is the observation that the
`q`-Pascal recursion collapses to the classical Pascal recursion modulo `ℓ`. -/
theorem qBinom_cast_of_q_eq_one (hq1 : ((q : ℕ) : ZMod ℓ) = 1) (n k : ℕ) :
    ((qBinom q n k : ℕ) : ZMod ℓ) = ((n.choose k : ℕ) : ZMod ℓ) := by
  induction n generalizing k with
  | zero =>
      cases k with
      | zero => simp
      | succ k => rw [qBinom_eq_zero_of_lt (by omega)]; simp
  | succ n ih =>
      cases k with
      | zero => simp [qBinom]
      | succ k =>
          rw [qBinom_succ_succ, Nat.choose_succ_succ, Nat.cast_add, Nat.cast_add, Nat.cast_mul,
            Nat.cast_pow, hq1, one_pow, one_mul, ih, ih]

end Degenerate

section Units

variable {q ℓ d : ℕ} [hp : Fact ℓ.Prime]

/-- Every `q`-factorial `[m]_q!` with `m < d` is a unit modulo `ℓ`. -/
theorem qFact_cast_ne_zero (h : IsQLucas q ℓ d) {m : ℕ} (hm : m < d) :
    ((qFact q m : ℕ) : ZMod ℓ) ≠ 0 := by
  induction m with
  | zero => simp
  | succ m ih =>
      rw [qFact_succ, Nat.cast_mul]
      exact mul_ne_zero (h.unit (m + 1) (Nat.succ_pos m) hm) (ih (by omega))

/-- Every Gaussian binomial coefficient inside a single base-`d` block is a unit modulo `ℓ`. -/
theorem qBinom_cast_ne_zero (h : IsQLucas q ℓ d) {r s : ℕ} (hs : s ≤ r) (hr : r < d) :
    ((qBinom q r s : ℕ) : ZMod ℓ) ≠ 0 := by
  intro hzero
  refine qFact_cast_ne_zero h hr ?_
  have hcast := congrArg (fun t : ℕ => (t : ZMod ℓ)) (qFact_mul_qBinom q r s hs)
  simp only [Nat.cast_mul] at hcast
  rw [hzero, mul_zero] at hcast
  exact hcast.symm

end Units

section Core

variable {q d : ℕ}

/-- The shift `S_j` is the `q^d`-integer `[j]_{q^d}`. -/
theorem qShift_eq_qNat_pow (q d j : ℕ) : qShift q d j = qNat (q ^ d) j := by
  simp [qShift, qNat, pow_mul]

/-- The product of the shifts is the `q^d`-factorial. -/
theorem qShiftProd_eq_qFact (q d M : ℕ) :
    (∏ j ∈ Icc 1 M, qShift q d j) = qFact (q ^ d) M := by
  induction M with
  | zero => simp [qFact]
  | succ M ih =>
      rw [Finset.prod_Icc_succ_top (by omega : 1 ≤ M + 1), ih, qFact_succ, qShift_eq_qNat_pow]
      ring

/-- **Three-factor splitting of the `q`-factorial**:
`[n]_q! = Red_d(n) · [d]_q^{⌊n/d⌋} · [⌊n/d⌋]_{q^d}!`.

The three factors are, respectively, the `d`-free part, the part responsible for the whole
`ℓ`-adic valuation, and a `q^d`-factorial of the block index. -/
theorem qFact_eq_qFactRed_mul_pow (q d n : ℕ) :
    qFact q n = qFactRed q d n * (qNat q d ^ (n / d) * qFact (q ^ d) (n / d)) := by
  rw [qFact_eq_qFactRed_mul_blocks q d n, qBlockProd_eq, qShiftProd_eq_qFact]

/-- **The exact `q`-Lucas identity over `ℕ`, carry-free case.**

`Red(k) · Red(n-k) · binom(n,k)_q = Red(n) · binom(⌊n/d⌋, ⌊k/d⌋)_{q^d}`.

This is an identity of natural numbers, no congruence involved: the carry-free half of the
`q`-Lucas theorem is its reduction modulo `ℓ`. -/
theorem qFactRed_mul_qBinom_pow (hd : 0 < d) {n k : ℕ} (hk : k ≤ n)
    (hN : n / d = k / d + (n - k) / d) :
    qFactRed q d k * qFactRed q d (n - k) * qBinom q n k
      = qFactRed q d n * qBinom (q ^ d) (n / d) (k / d) := by
  have hA : k / d ≤ n / d := Nat.div_le_div_right hk
  have hB : n / d - k / d = (n - k) / d := by rw [hN]; simp
  have h1 := qFact_mul_qBinom q n k hk
  rw [qFact_eq_qFactRed_mul_pow q d k, qFact_eq_qFactRed_mul_pow q d (n - k),
    qFact_eq_qFactRed_mul_pow q d n] at h1
  have h2 := qFact_mul_qBinom (q ^ d) (n / d) (k / d) hA
  rw [hB] at h2
  have hpos : 0 < qNat q d ^ (n / d) * (qFact (q ^ d) (k / d) * qFact (q ^ d) ((n - k) / d)) :=
    Nat.mul_pos (pow_pos (qNat_pos q hd) _)
      (Nat.mul_pos (qFact_pos _ _) (qFact_pos _ _))
  refine Nat.eq_of_mul_eq_mul_left hpos ?_
  calc qNat q d ^ (n / d) * (qFact (q ^ d) (k / d) * qFact (q ^ d) ((n - k) / d))
        * (qFactRed q d k * qFactRed q d (n - k) * qBinom q n k)
      = qFactRed q d k * (qNat q d ^ (k / d) * qFact (q ^ d) (k / d))
          * (qFactRed q d (n - k) *
              (qNat q d ^ ((n - k) / d) * qFact (q ^ d) ((n - k) / d)))
          * qBinom q n k := by rw [hN, pow_add]; ring
    _ = qFactRed q d n * (qNat q d ^ (n / d) * qFact (q ^ d) (n / d)) := h1
    _ = qFactRed q d n * (qNat q d ^ (n / d) *
          (qFact (q ^ d) (k / d) * qFact (q ^ d) ((n - k) / d)
            * qBinom (q ^ d) (n / d) (k / d))) := by rw [h2]
    _ = qNat q d ^ (n / d) * (qFact (q ^ d) (k / d) * qFact (q ^ d) ((n - k) / d))
          * (qFactRed q d n * qBinom (q ^ d) (n / d) (k / d)) := by ring

/-- **The exact `q`-Lucas identity over `ℕ`, carry case.**  When the base-`d` digits of `k` and
`n - k` overflow, one extra factor `[d]_q` survives on the right:

`Red(k) · Red(n-k) · binom(n,k)_q = Red(n) · [d]_q · [⌊n/d⌋]_{q^d} · binom(⌊n/d⌋-1, ⌊k/d⌋)_{q^d}`.

Since `ℓ ∣ [d]_q`, this is exactly why a carry forces `ℓ ∣ binom(n,k)_q`. -/
theorem qFactRed_mul_qBinom_carry (hd : 0 < d) {n k : ℕ} (hk : k ≤ n)
    (hN : n / d = k / d + (n - k) / d + 1) :
    qFactRed q d k * qFactRed q d (n - k) * qBinom q n k
      = qFactRed q d n * (qNat q d * (qNat (q ^ d) (n / d)
          * qBinom (q ^ d) (k / d + (n - k) / d) (k / d))) := by
  have hA : k / d ≤ k / d + (n - k) / d := Nat.le_add_right _ _
  have h1 := qFact_mul_qBinom q n k hk
  rw [qFact_eq_qFactRed_mul_pow q d k, qFact_eq_qFactRed_mul_pow q d (n - k),
    qFact_eq_qFactRed_mul_pow q d n] at h1
  have h2 := qFact_mul_qBinom (q ^ d) (k / d + (n - k) / d) (k / d) hA
  rw [Nat.add_sub_cancel_left] at h2
  have h3 : qFact (q ^ d) (n / d)
      = qNat (q ^ d) (n / d) * qFact (q ^ d) (k / d + (n - k) / d) := by
    conv_lhs => rw [hN]
    rw [qFact_succ, ← hN]
  have hpos : 0 < qNat q d ^ (k / d + (n - k) / d)
      * (qFact (q ^ d) (k / d) * qFact (q ^ d) ((n - k) / d)) :=
    Nat.mul_pos (pow_pos (qNat_pos q hd) _)
      (Nat.mul_pos (qFact_pos _ _) (qFact_pos _ _))
  refine Nat.eq_of_mul_eq_mul_left hpos ?_
  calc qNat q d ^ (k / d + (n - k) / d)
        * (qFact (q ^ d) (k / d) * qFact (q ^ d) ((n - k) / d))
        * (qFactRed q d k * qFactRed q d (n - k) * qBinom q n k)
      = qFactRed q d k * (qNat q d ^ (k / d) * qFact (q ^ d) (k / d))
          * (qFactRed q d (n - k) *
              (qNat q d ^ ((n - k) / d) * qFact (q ^ d) ((n - k) / d)))
          * qBinom q n k := by rw [pow_add]; ring
    _ = qFactRed q d n * (qNat q d ^ (n / d) * qFact (q ^ d) (n / d)) := h1
    _ = qFactRed q d n * (qNat q d ^ (n / d) * (qNat (q ^ d) (n / d) *
          (qFact (q ^ d) (k / d) * qFact (q ^ d) ((n - k) / d)
            * qBinom (q ^ d) (k / d + (n - k) / d) (k / d)))) := by rw [h3, ← h2]
    _ = qNat q d ^ (k / d + (n - k) / d)
          * (qFact (q ^ d) (k / d) * qFact (q ^ d) ((n - k) / d))
          * (qFactRed q d n * (qNat q d * (qNat (q ^ d) (n / d)
              * qBinom (q ^ d) (k / d + (n - k) / d) (k / d)))) := by
        rw [hN, pow_succ]; ring

end Core

section Main

variable {q ℓ d : ℕ} [hp : Fact ℓ.Prime]

/-- **The `q`-analogue of Lucas' theorem, digit form (carry-free).**

If `d` is a `q`-Lucas period for `ℓ`, and `n = dN + r`, `k = dA + s` with `A ≤ N` and
`0 ≤ s ≤ r < d`, then modulo `ℓ`

`binom(dN + r, dA + s)_q ≡ C(N, A) · binom(r, s)_q`.

There is no restriction whatsoever on the size of `N`. -/
theorem qBinom_cast_lucas_digits (h : IsQLucas q ℓ d) {N A r s : ℕ}
    (hA : A ≤ N) (hs : s ≤ r) (hr : r < d) :
    ((qBinom q (d * N + r) (d * A + s) : ℕ) : ZMod ℓ)
      = ((N.choose A : ℕ) : ZMod ℓ) * ((qBinom q r s : ℕ) : ZMod ℓ) := by
  have hd := h.pos
  set B := N - A with hBdef
  have hNB : N = A + B := (Nat.add_sub_cancel' hA).symm
  have hslt : s < d := lt_of_le_of_lt hs hr
  have hrs : r - s < d := lt_of_le_of_lt (Nat.sub_le r s) hr
  set n := d * N + r with hndef
  set k := d * A + s with hkdef
  have hkn : k ≤ n := Nat.add_le_add (Nat.mul_le_mul_left d hA) hs
  have hndiv : n / d = N := by
    rw [hndef, Nat.mul_add_div hd, Nat.div_eq_of_lt hr, Nat.add_zero]
  have hnmod : n % d = r := by rw [hndef, Nat.mul_add_mod, Nat.mod_eq_of_lt hr]
  have hkdiv : k / d = A := by
    rw [hkdef, Nat.mul_add_div hd, Nat.div_eq_of_lt hslt, Nat.add_zero]
  have hkmod : k % d = s := by rw [hkdef, Nat.mul_add_mod, Nat.mod_eq_of_lt hslt]
  have hmulsplit : d * N = d * A + d * B := by rw [hBdef, ← Nat.mul_add, Nat.add_sub_cancel' hA]
  have hsub : n - k = d * B + (r - s) := by omega
  have hBdiv : (n - k) / d = B := by
    rw [hsub, Nat.mul_add_div hd, Nat.div_eq_of_lt hrs, Nat.add_zero]
  have hBmod : (n - k) % d = r - s := by rw [hsub, Nat.mul_add_mod, Nat.mod_eq_of_lt hrs]
  -- the exact identity of `qFactRed_mul_qBinom_pow`, cast into `ZMod ℓ`
  have keyc := congrArg (fun t : ℕ => (t : ZMod ℓ))
    (qFactRed_mul_qBinom_pow (q := q) hd hkn (by rw [hndiv, hkdiv, hBdiv]; omega))
  simp only [Nat.cast_mul] at keyc
  rw [qFactRed_cast hd h.vanish h.powOne k, qFactRed_cast hd h.vanish h.powOne (n - k),
    qFactRed_cast hd h.vanish h.powOne n, hndiv, hnmod, hkdiv, hkmod, hBdiv, hBmod] at keyc
  -- the `q^d`-binomial coefficient degenerates to the classical one
  have hQ1 : ((q ^ d : ℕ) : ZMod ℓ) = 1 := by push_cast; exact h.powOne
  rw [qBinom_cast_of_q_eq_one hQ1] at keyc
  set F := ((qFact q (d - 1) : ℕ) : ZMod ℓ) with hFdef
  set QS := ((qFact q s : ℕ) : ZMod ℓ) with hQSdef
  set QT := ((qFact q (r - s) : ℕ) : ZMod ℓ) with hQTdef
  set X := ((qBinom q n k : ℕ) : ZMod ℓ) with hXdef
  set Y := ((qBinom q r s : ℕ) : ZMod ℓ) with hYdef
  have hQR : ((qFact q r : ℕ) : ZMod ℓ) = QS * QT * Y := by
    rw [hQSdef, hQTdef, hYdef, ← Nat.cast_mul, ← Nat.cast_mul, qFact_mul_qBinom q r s hs]
  have hFN : F ^ N = F ^ A * F ^ B := by rw [hNB, pow_add]
  -- cancel the units
  have hFne : F ≠ 0 := qFact_cast_ne_zero h (by omega)
  have hne : F ^ N * QS * QT ≠ 0 :=
    mul_ne_zero (mul_ne_zero (pow_ne_zero _ hFne) (qFact_cast_ne_zero h hslt))
      (qFact_cast_ne_zero h hrs)
  refine mul_left_cancel₀ hne ?_
  calc F ^ N * QS * QT * X
      = F ^ A * QS * (F ^ B * QT) * X := by rw [hFN]; ring
    _ = F ^ N * ((qFact q r : ℕ) : ZMod ℓ) * ((N.choose A : ℕ) : ZMod ℓ) := keyc
    _ = F ^ N * QS * QT * (((N.choose A : ℕ) : ZMod ℓ) * Y) := by rw [hQR]; ring

/-- The carry-free `q`-Lucas congruence in `⌊·/d⌋`, `· % d` form. -/
theorem qBinom_cast_lucas_of_no_carry (h : IsQLucas q ℓ d) {n k : ℕ} (hk : k ≤ n)
    (hs : k % d ≤ n % d) :
    ((qBinom q n k : ℕ) : ZMod ℓ)
      = (((n / d).choose (k / d) : ℕ) : ZMod ℓ) * ((qBinom q (n % d) (k % d) : ℕ) : ZMod ℓ) := by
  have hd := h.pos
  have hA : k / d ≤ n / d := Nat.div_le_div_right hk
  have key := qBinom_cast_lucas_digits h hA hs (Nat.mod_lt _ hd)
  rwa [Nat.div_add_mod, Nat.div_add_mod] at key

/-- **A base-`d` carry forces divisibility.**  If the base-`d` digit of `k` exceeds that of `n`,
then `ℓ` divides `binom(n,k)_q`.  This is the congruence-theoretic shadow of the `q`-Kummer
valuation formula, and it is what makes the `q`-Lucas congruence unconditional. -/
theorem qBinom_cast_eq_zero_of_carry (h : IsQLucas q ℓ d) {n k : ℕ} (hk : k ≤ n)
    (hs : n % d < k % d) : ((qBinom q n k : ℕ) : ZMod ℓ) = 0 := by
  have hd := h.pos
  have hkn : k + (n - k) = n := Nat.add_sub_cancel' hk
  have hsum : (k % d + (n - k) % d) % d = n % d := by rw [← Nat.add_mod, hkn]
  have hcarry : d ≤ k % d + (n - k) % d := by
    by_contra hcon
    push_neg at hcon
    rw [Nat.mod_eq_of_lt hcon] at hsum
    omega
  have hN : n / d = k / d + (n - k) / d + 1 := by
    have hdiv := div_add_div_add_carry hd k (n - k)
    rw [hkn, if_pos hcarry] at hdiv
    exact hdiv
  have keyc := congrArg (fun t : ℕ => (t : ZMod ℓ))
    (qFactRed_mul_qBinom_carry (q := q) hd hk hN)
  simp only [Nat.cast_mul] at keyc
  rw [qFactRed_cast hd h.vanish h.powOne k, qFactRed_cast hd h.vanish h.powOne (n - k),
    h.vanish] at keyc
  set F := ((qFact q (d - 1) : ℕ) : ZMod ℓ) with hFdef
  have hFne : F ≠ 0 := qFact_cast_ne_zero h (by omega)
  have hne : F ^ (k / d) * ((qFact q (k % d) : ℕ) : ZMod ℓ)
      * (F ^ ((n - k) / d) * ((qFact q ((n - k) % d) : ℕ) : ZMod ℓ)) ≠ 0 :=
    mul_ne_zero
      (mul_ne_zero (pow_ne_zero _ hFne) (qFact_cast_ne_zero h (Nat.mod_lt _ hd)))
      (mul_ne_zero (pow_ne_zero _ hFne) (qFact_cast_ne_zero h (Nat.mod_lt _ hd)))
  have hzero : F ^ (k / d) * ((qFact q (k % d) : ℕ) : ZMod ℓ)
      * (F ^ ((n - k) / d) * ((qFact q ((n - k) % d) : ℕ) : ZMod ℓ))
      * ((qBinom q n k : ℕ) : ZMod ℓ) = 0 := by rw [keyc]; ring
  rcases mul_eq_zero.mp hzero with h1 | h2
  · exact absurd h1 hne
  · exact h2

/-- **The `q`-analogue of Lucas' theorem.**

Let `d` be a `q`-Lucas period for `ℓ` (e.g. the multiplicative order of `q` mod `ℓ`).  Then for
*all* `k ≤ n`, modulo `ℓ`,

`binom(n,k)_q ≡ C(⌊n/d⌋, ⌊k/d⌋) · binom(n % d, k % d)_q`.

No carry hypothesis and no bound on `n` are needed: when the base-`d` digits carry, both sides
vanish modulo `ℓ`. -/
theorem qBinom_cast_lucas (h : IsQLucas q ℓ d) {n k : ℕ} (hk : k ≤ n) :
    ((qBinom q n k : ℕ) : ZMod ℓ)
      = (((n / d).choose (k / d) : ℕ) : ZMod ℓ) * ((qBinom q (n % d) (k % d) : ℕ) : ZMod ℓ) := by
  rcases Nat.lt_or_ge (n % d) (k % d) with hs | hs
  · rw [qBinom_cast_eq_zero_of_carry h hk hs, qBinom_eq_zero_of_lt hs]
    simp
  · exact qBinom_cast_lucas_of_no_carry h hk hs

/-- **Carry-free divisibility.**  In the absence of a base-`d` carry, `ℓ` divides the Gaussian
binomial coefficient exactly when it divides the classical binomial coefficient of the block
indices — the residual `d × d` block contributes only units.  This is the congruence-theoretic
counterpart of the `q`-Kummer valuation formula. -/
theorem dvd_qBinom_lucas (h : IsQLucas q ℓ d) {n k : ℕ} (hk : k ≤ n) (hs : k % d ≤ n % d) :
    ℓ ∣ qBinom q n k ↔ ℓ ∣ (n / d).choose (k / d) := by
  have hd := h.pos
  have hY : ((qBinom q (n % d) (k % d) : ℕ) : ZMod ℓ) ≠ 0 :=
    qBinom_cast_ne_zero h hs (Nat.mod_lt _ hd)
  rw [← ZMod.natCast_eq_zero_iff (qBinom q n k) ℓ,
    ← ZMod.natCast_eq_zero_iff ((n / d).choose (k / d)) ℓ,
    qBinom_cast_lucas_of_no_carry h hk hs, mul_eq_zero]
  simp [hY]

end Main

section OrderOf

variable {q ℓ : ℕ} [hp : Fact ℓ.Prime]

/-- The multiplicative order of `q` modulo a prime `ℓ ∤ q` is positive. -/
theorem orderOf_pos_of_not_dvd (hnd : ¬ ℓ ∣ q) : 0 < orderOf ((q : ℕ) : ZMod ℓ) := by
  have hq0 : ((q : ℕ) : ZMod ℓ) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]
    exact hnd
  rw [orderOf_pos_iff]
  exact isOfFinOrder_iff_pow_eq_one.mpr
    ⟨ℓ - 1, by have := hp.out.two_le; omega, ZMod.pow_card_sub_one_eq_one hq0⟩

/-- The multiplicative order of `q` modulo `ℓ` is a `q`-Lucas period, provided it exceeds `1`. -/
theorem isQLucas_orderOf (hq : 2 ≤ q) (hd1 : 1 < orderOf ((q : ℕ) : ZMod ℓ)) :
    IsQLucas q ℓ (orderOf ((q : ℕ) : ZMod ℓ)) := by
  set d := orderOf ((q : ℕ) : ZMod ℓ) with hddef
  refine ⟨by omega, ?_, pow_orderOf_eq_one _, ?_⟩
  · rw [ZMod.natCast_eq_zero_iff]
    exact (dvd_iff_one_le_padicValNat (qNat_pos q (by omega)).ne').mpr
      (one_le_padicValNat_qNat_orderOf hq hd1)
  · intro i hi hid
    rw [Ne, ZMod.natCast_eq_zero_iff]
    intro hdvd
    have h1 : ℓ ∣ q ^ i - 1 := by
      rw [← sub_one_mul_qNat (by omega : 1 ≤ q) i]
      exact hdvd.mul_left _
    have h2 : d ∣ i := (orderOf_dvd_iff_dvd_pow_sub_one hq i).mpr h1
    have := Nat.le_of_dvd hi h2
    omega

/-- **`q`-Lucas theorem, order form.**  For `q ≥ 2` and any prime `ℓ ∤ q` (no parity hypothesis),
with `d = ord_ℓ(q)` and any `k ≤ n`,

`binom(n,k)_q ≡ C(⌊n/d⌋, ⌊k/d⌋) · binom(n % d, k % d)_q  (mod ℓ)`. -/
theorem qBinom_cast_lucas_orderOf (hq : 2 ≤ q) (hnd : ¬ ℓ ∣ q) {n k : ℕ} (hk : k ≤ n) :
    ((qBinom q n k : ℕ) : ZMod ℓ)
      = (((n / orderOf ((q : ℕ) : ZMod ℓ)).choose
            (k / orderOf ((q : ℕ) : ZMod ℓ)) : ℕ) : ZMod ℓ)
        * ((qBinom q (n % orderOf ((q : ℕ) : ZMod ℓ))
              (k % orderOf ((q : ℕ) : ZMod ℓ)) : ℕ) : ZMod ℓ) := by
  set d := orderOf ((q : ℕ) : ZMod ℓ) with hddef
  have hdpos : 0 < d := orderOf_pos_of_not_dvd hnd
  rcases Nat.lt_or_ge 1 d with hd1 | hd1
  · exact qBinom_cast_lucas (isQLucas_orderOf hq (hddef ▸ hd1)) hk
  · have hd : d = 1 := by omega
    have hq1 : ((q : ℕ) : ZMod ℓ) = 1 := by
      have := pow_orderOf_eq_one ((q : ℕ) : ZMod ℓ)
      rwa [← hddef, hd, pow_one] at this
    rw [hd]
    simp only [Nat.div_one, Nat.mod_one, qBinom_self, Nat.cast_one, mul_one]
    exact qBinom_cast_of_q_eq_one hq1 n k

end OrderOf

end QKummer