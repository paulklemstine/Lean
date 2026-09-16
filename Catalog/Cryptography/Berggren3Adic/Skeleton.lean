import Mathlib

/-!
# Berggren 3-adic skeleton of the N-node (BERGGREN-3ADIC, part I)

Let `N = p*q` be an odd semiprime and let `(m, n) = ((q+p)/2, (q-p)/2)` be its
*Fermat pair*, so that `N = m^2 - n^2`.  This pair is a node of the Berggren tree of
primitive Pythagorean triples (the exact embedding of paper 56).

This file formalises the **skeleton horn (H1)** of the experiment:

* `Berggren3Adic.skeleton` — for coprime `m n`, the 3-adic skeleton of the node is
  *exactly* the residue `N mod 3`:
  `N ≡ 1 ↔ 3 ∣ n`, `N ≡ 2 ↔ 3 ∣ m`, `N ≡ 0 ↔ 3 ∤ m ∧ 3 ∤ n`.
* `Berggren3Adic.skeleton_determined_by_residue` — the skeleton is a *function of
  `N mod 3` alone*: two coprime pairs with equal `N mod 3` have the same skeleton.
* `Berggren3Adic.residue_determined_by_skeleton` — and conversely.  Hence the channel
  `pair ↦ skeleton` carries *exactly* the information of `N mod 3`, no more.
* `Berggren3Adic.trace_restatement` — the trace form: for coprime `p q`,
  `N = p*q ≡ 1 [mod 3]` iff `p ≡ q [mod 3]` and `3 ∤ p`; and
  `3 ∣ n ↔ p ≡ q [mod 3]` (`skeleton_dvd_n_iff_trace`).  So the skeleton *restates*
  the trace and nothing else.

The metric layer (branch letters, depth) is treated in `ParentLaw.lean` and
`Blindness.lean`, where it is shown to be *invisible* at every modulus.
-/

namespace Berggren3Adic

/-- The odd number attached to a tree node `(m, n)`: `N = m² − n² = (m−n)(m+n)`. -/
def nOf (p : ℤ × ℤ) : ℤ := p.1 ^ 2 - p.2 ^ 2

/-- A **Fermat pair**: `0 < n < m`, coprime, of opposite parity.  These are exactly the
nodes of the Berggren tree of primitive Pythagorean triples, and the Fermat pair of an
odd semiprime `N = p q` with `1 < p < q` is one of them. -/
structure FermatPair (p : ℤ × ℤ) : Prop where
  pos : 0 < p.2
  lt : p.2 < p.1
  cop : IsCoprime p.1 p.2
  parity : (p.1 + p.2) % 2 = 1

theorem nOf_eq_mul (p : ℤ × ℤ) : nOf p = (p.1 - p.2) * (p.1 + p.2) := by
  simp only [nOf]; ring

/-! ## Auxiliary: coprimality forbids a common factor 3 -/

theorem not_three_dvd_both {m n : ℤ} (h : IsCoprime m n) :
    ¬ ((3 : ℤ) ∣ m ∧ (3 : ℤ) ∣ n) := by
  rintro ⟨hm, hn⟩
  have : IsUnit (3 : ℤ) := h.isUnit_of_dvd' hm hn
  rw [Int.isUnit_iff] at this
  omega

theorem cast_ne_zero_or {m n : ℤ} (h : IsCoprime m n) :
    ¬ (((m : ZMod 3) = 0) ∧ ((n : ZMod 3) = 0)) := by
  intro hc
  exact not_three_dvd_both h
    ⟨(ZMod.intCast_zmod_eq_zero_iff_dvd m 3).mp hc.1,
     (ZMod.intCast_zmod_eq_zero_iff_dvd n 3).mp hc.2⟩

/-! ## H1: the deterministic 3-adic skeleton -/

/-- **The skeleton lemma (H1)**.  For a coprime pair `(m, n)` the residue of
`N = m² − n²` modulo `3` determines, and is determined by, which coordinate is
divisible by `3`. -/
theorem skeleton {m n : ℤ} (h : IsCoprime m n) :
    (((nOf (m, n) : ℤ) : ZMod 3) = 1 ↔ (3 : ℤ) ∣ n) ∧
    (((nOf (m, n) : ℤ) : ZMod 3) = 2 ↔ (3 : ℤ) ∣ m) ∧
    (((nOf (m, n) : ℤ) : ZMod 3) = 0 ↔ (¬ (3 : ℤ) ∣ m ∧ ¬ (3 : ℤ) ∣ n)) := by
  have hm : ((3 : ℤ) ∣ m) ↔ ((m : ZMod 3) = 0) :=
    (ZMod.intCast_zmod_eq_zero_iff_dvd m 3).symm
  have hn : ((3 : ℤ) ∣ n) ↔ ((n : ZMod 3) = 0) :=
    (ZMod.intCast_zmod_eq_zero_iff_dvd n 3).symm
  have hnot := cast_ne_zero_or h
  rw [hm, hn]
  simp only [nOf]
  push_cast
  revert hnot
  generalize ((m : ZMod 3)) = a
  generalize ((n : ZMod 3)) = b
  revert a b
  decide

theorem skeleton_one {m n : ℤ} (h : IsCoprime m n) :
    (((nOf (m, n) : ℤ) : ZMod 3) = 1 ↔ (3 : ℤ) ∣ n) := (skeleton h).1

theorem skeleton_two {m n : ℤ} (h : IsCoprime m n) :
    (((nOf (m, n) : ℤ) : ZMod 3) = 2 ↔ (3 : ℤ) ∣ m) := (skeleton h).2.1

theorem skeleton_zero {m n : ℤ} (h : IsCoprime m n) :
    (((nOf (m, n) : ℤ) : ZMod 3) = 0 ↔ (¬ (3 : ℤ) ∣ m ∧ ¬ (3 : ℤ) ∣ n)) := (skeleton h).2.2

/-- The `ℤ`-flavoured version of the first branch of the skeleton lemma. -/
theorem skeleton_one_emod {m n : ℤ} (h : IsCoprime m n) :
    (nOf (m, n) % 3 = 1 ↔ (3 : ℤ) ∣ n) := by
  rw [← skeleton_one h]
  constructor
  · intro hmod
    have h1 : ((nOf (m, n) : ℤ) : ZMod 3) = (((1 : ℤ)) : ZMod 3) := by
      rw [ZMod.intCast_eq_intCast_iff]
      show nOf (m, n) % 3 = (1 : ℤ) % 3
      omega
    simpa using h1
  · intro hcast
    have h1 : ((nOf (m, n) : ℤ) : ZMod 3) = (((1 : ℤ)) : ZMod 3) := by simpa using hcast
    rw [ZMod.intCast_eq_intCast_iff] at h1
    have : nOf (m, n) % 3 = (1 : ℤ) % 3 := h1
    omega

/-! ## The skeleton carries *exactly* `N mod 3` -/

/-- Two coprime pairs with the same `N mod 3` have the same skeleton:
the branch data is a function of the residue alone. -/
theorem skeleton_determined_by_residue {m n m' n' : ℤ}
    (h : IsCoprime m n) (h' : IsCoprime m' n')
    (hN : ((nOf (m, n) : ℤ) : ZMod 3) = ((nOf (m', n') : ℤ) : ZMod 3)) :
    (((3 : ℤ) ∣ m) ↔ ((3 : ℤ) ∣ m')) ∧ (((3 : ℤ) ∣ n) ↔ ((3 : ℤ) ∣ n')) := by
  constructor
  · rw [← skeleton_two h, ← skeleton_two h', hN]
  · rw [← skeleton_one h, ← skeleton_one h', hN]

/-- Conversely the skeleton determines `N mod 3`: no information is lost either way,
so the skeleton channel has *exactly* the content of the trace set `{N mod 3}`. -/
theorem residue_determined_by_skeleton {m n m' n' : ℤ}
    (h : IsCoprime m n) (h' : IsCoprime m' n')
    (hm : ((3 : ℤ) ∣ m) ↔ ((3 : ℤ) ∣ m')) (hn : ((3 : ℤ) ∣ n) ↔ ((3 : ℤ) ∣ n')) :
    ((nOf (m, n) : ℤ) : ZMod 3) = ((nOf (m', n') : ℤ) : ZMod 3) := by
  by_cases hdn : (3 : ℤ) ∣ n
  · rw [(skeleton_one h).mpr hdn, (skeleton_one h').mpr (hn.mp hdn)]
  · by_cases hdm : (3 : ℤ) ∣ m
    · rw [(skeleton_two h).mpr hdm, (skeleton_two h').mpr (hm.mp hdm)]
    · rw [(skeleton_zero h).mpr ⟨hdm, hdn⟩,
        (skeleton_zero h').mpr ⟨fun hc => hdm (hm.mpr hc), fun hc => hdn (hn.mpr hc)⟩]

/-! ## The Fermat pair of a semiprime, and the trace restatement -/

/-- The Fermat pair of an odd `N = p q` with `1 < p < q` coprime is a tree node, and its
`nOf` value is `N`. -/
theorem fermatPair_of_odd_coprime {p q : ℤ} (hp : p % 2 = 1) (hq : q % 2 = 1)
    (hp1 : 1 < p) (hpq : p < q) (hco : IsCoprime p q) :
    FermatPair ((q + p) / 2, (q - p) / 2) ∧ nOf ((q + p) / 2, (q - p) / 2) = p * q := by
  obtain ⟨s, hs⟩ : ∃ s : ℤ, q + p = 2 * s := ⟨(q + p) / 2, by omega⟩
  obtain ⟨t, ht⟩ : ∃ t : ℤ, q - p = 2 * t := ⟨(q - p) / 2, by omega⟩
  have hsv : (q + p) / 2 = s := by omega
  have htv : (q - p) / 2 = t := by omega
  rw [hsv, htv]
  have hcop : IsCoprime s t := by
    obtain ⟨a, b, hab⟩ := hco
    have hps : p = s - t := by omega
    have hqs : q = s + t := by omega
    rw [hps, hqs] at hab
    exact ⟨a + b, b - a, by linear_combination hab⟩
  refine ⟨⟨by simpa using (by omega : (0 : ℤ) < t), by simpa using (by omega : t < s), hcop,
    by simpa using (by omega : (s + t) % 2 = 1)⟩, ?_⟩
  simp only [nOf]
  nlinarith [hs, ht]

/-- `3 ∣ n` for the Fermat pair of `N = p q` is *exactly* the trace condition
`p ≡ q [mod 3]`. -/
theorem skeleton_dvd_n_iff_trace {p q : ℤ} (hp : p % 2 = 1) (hq : q % 2 = 1) :
    ((3 : ℤ) ∣ (q - p) / 2) ↔ ((p : ZMod 3) = (q : ZMod 3)) := by
  obtain ⟨t, ht⟩ : ∃ t : ℤ, q - p = 2 * t := ⟨(q - p) / 2, by omega⟩
  have htv : (q - p) / 2 = t := by omega
  rw [htv, ZMod.intCast_eq_intCast_iff, Int.ModEq]
  constructor
  · rintro ⟨c, rfl⟩; omega
  · intro hmod
    have h3 : (3 : ℤ) ∣ (q - p) := by omega
    obtain ⟨c, hc⟩ := h3
    exact ⟨if (2 : ℤ) ∣ c then c / 2 else 0, by omega⟩

/-- **The trace restatement (H1, second half)**.  For coprime `p q`, `N = p q` is
`≡ 1 mod 3` exactly when `p ≡ q mod 3` and neither is divisible by `3`.  Combined with
`skeleton_dvd_n_iff_trace`, the skeleton is literally a restatement of the trace. -/
theorem trace_restatement {p q : ℤ} (hco : IsCoprime p q) :
    (((p * q : ℤ) : ZMod 3) = 1 ↔ ((p : ZMod 3) = (q : ZMod 3) ∧ (p : ZMod 3) ≠ 0)) := by
  have hnot := cast_ne_zero_or hco
  push_cast
  revert hnot
  generalize ((p : ZMod 3)) = a
  generalize ((q : ZMod 3)) = b
  revert a b
  decide

/-- Zero information beyond the trace: for the Fermat pair of a coprime odd pair `p < q`,
the first skeleton flag `3 ∣ n`, the trace condition `p ≡ q`, and the residue `N ≡ 1` all
coincide. -/
theorem skeleton_is_trace {p q : ℤ} (hp : p % 2 = 1) (hq : q % 2 = 1)
    (hp1 : 1 < p) (hpq : p < q) (hco : IsCoprime p q) :
    (((3 : ℤ) ∣ (q - p) / 2) ↔ ((p : ZMod 3) = (q : ZMod 3))) ∧
    ((((p * q : ℤ)) : ZMod 3) = 1 ↔ (3 : ℤ) ∣ (q - p) / 2) := by
  obtain ⟨hfp, hval⟩ := fermatPair_of_odd_coprime hp hq hp1 hpq hco
  refine ⟨skeleton_dvd_n_iff_trace hp hq, ?_⟩
  rw [← hval]
  exact skeleton_one hfp.cop

end Berggren3Adic