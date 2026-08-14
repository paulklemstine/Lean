/-
# Higher power residues: the criterion, the tower, and the capacity of a symbol channel

Formal core for `39_PowerResidue_Circularity.md` (experiment KPOWER, #374).

The KPOWER experiment asks whether **cubic** (`Z[ω]`) or **quartic** (`Z[i]`)
power-residue symbols give a *residue dial* — a `poly(log N)`-computable,
periodic statistic of a secret prime `p` — that is strictly stronger than the
quadratic (Kronecker/Jacobi) channel already analysed in
`Combinatorics.DialThresholdNoAmplification`.

This file builds the algebraic core needed to answer that question:

* `PowerResidue.exists_pow_eq_iff_pow_card_div` — the **`k`-th power criterion**
  in an arbitrary finite cyclic group: for `k ∣ |G|`, `x` is a `k`-th power iff
  `x ^ (|G| / k) = 1`.  This is the structural heart; Euler's criterion
  (`k = 2`) and the cubic/quartic symbols are instances.
* `PowerResidue.zmod_exists_pow_eq_iff`, `PowerResidue.isPowerResidue_iff_pow` —
  its transfer to `(ZMod p)ˣ` for a prime `p`, i.e. the definition of the
  symbol `(a | p)_k = a ^ ((p-1)/k)` as a *residuacity test*.
* `PowerResidue.isPowerResidue_of_dvd` — the **residuacity tower**: `l`-th power
  residues are `k`-th power residues whenever `k ∣ l`.  Cubic data therefore
  *contains* no quadratic data and vice versa; the channels are nested only
  along divisibility.
* `PowerResidue.isPowerResidue_mul_moduli` — the **CRT factorisation** of
  residuacity at a composite modulus `N = m·n`: the `N`-computable predicate is
  exactly the *conjunction* of the two local predicates, hence a **symmetric**
  function of the factor pair.  This is barrier 2 in algebraic form: the only
  higher-power datum an attacker can compute from `N` alone is symmetric in
  `p` and `q`.
* `PowerResidue.card_image_le_pow`, `PowerResidue.card_le_two_pow_of_injOn`,
  `PowerResidue.log_le_of_separating` — the **capacity** of a `K`-symbol
  fingerprint.  Whatever the exponent `k`, a length-`K` residuacity fingerprint
  takes at most `2 ^ K` values and therefore separates at most `2 ^ K`
  candidates: `K ≥ log₂ C` symbols are needed to pin `C` candidates.  The bound
  does not depend on `k`, which is the formal content of the experiment's
  "leakage saturates like quadratic".

The circularity itself — computing `a ^ ((p-1)/k)` presupposes `p` — and the
failure of the cubic symbol to be periodic in `p` are proved in
`Combinatorics.PowerResidueCircularity`.
-/
import Mathlib

namespace PowerResidue

open Finset

/-! ## 1. The `k`-th power criterion in a finite cyclic group

Everything downstream is an instance of this single statement.  Note that no
primality, no field structure, and no root of unity is involved: it is pure
cyclic group theory, which is why it applies verbatim to the cubic and quartic
symbols. -/

/-- **The `k`-th power criterion.**  In a finite cyclic group `G`, if `k` divides
`|G|`, then `x` is a `k`-th power exactly when `x ^ (|G| / k) = 1`.

For `G = (ZMod p)ˣ` and `k = 2` this is Euler's criterion; for `k = 3` it is the
cubic residue symbol `(a | p)₃`, for `k = 4` the quartic symbol. -/
theorem exists_pow_eq_iff_pow_card_div {G : Type*} [CommGroup G] [Fintype G] [IsCyclic G]
    {k : ℕ} (hk : k ∣ Fintype.card G) (x : G) :
    (∃ y : G, y ^ k = x) ↔ x ^ (Fintype.card G / k) = 1 := by
  classical
  set n := Fintype.card G with hn
  have hnpos : 0 < n := Fintype.card_pos
  have hkpos : 0 < k := Nat.pos_of_ne_zero (by rintro rfl; simp at hk; omega)
  have hkn : k * (n / k) = n := Nat.mul_div_cancel' hk
  have hdpos : 0 < n / k := Nat.div_pos (Nat.le_of_dvd hnpos hk) hkpos
  constructor
  · rintro ⟨y, rfl⟩
    rw [← pow_mul, hkn]
    exact pow_card_eq_one
  · intro hx
    obtain ⟨g, hg⟩ := IsCyclic.exists_generator (α := G)
    have hord : orderOf g = n := by
      rw [hn, ← Nat.card_eq_fintype_card]
      exact orderOf_eq_card_of_forall_mem_zpowers hg
    obtain ⟨j, hj⟩ : ∃ j : ℕ, g ^ j = x := by
      have := hg x
      rwa [← mem_powers_iff_mem_zpowers, Submonoid.mem_powers_iff] at this
    subst hj
    rw [← pow_mul] at hx
    have hdvd : n ∣ j * (n / k) := by
      have := orderOf_dvd_of_pow_eq_one hx
      rwa [hord] at this
    have hdvd' : k * (n / k) ∣ j * (n / k) := by rw [hkn]; exact hdvd
    have hk' : k ∣ j := (Nat.mul_dvd_mul_iff_right hdpos).mp hdvd'
    obtain ⟨m, rfl⟩ := hk'
    exact ⟨g ^ m, by rw [← pow_mul, mul_comm]⟩

/-- The criterion transferred to the field `ZMod p`: for a prime `p`, an exponent
`k ∣ p - 1` and a nonzero residue `a`, the residue `a` is a `k`-th power exactly
when the **power symbol** `a ^ ((p-1)/k)` equals `1`. -/
theorem zmod_exists_pow_eq_iff {p k : ℕ} [hp : Fact p.Prime] (hk : k ∣ p - 1) {a : ZMod p}
    (ha : a ≠ 0) : (∃ b : ZMod p, b ^ k = a) ↔ a ^ ((p - 1) / k) = 1 := by
  have hp2 : 2 ≤ p := hp.out.two_le
  have hkpos : 0 < k := Nat.pos_of_ne_zero (by rintro rfl; simp at hk; omega)
  have hcard : Fintype.card (ZMod p)ˣ = p - 1 := ZMod.card_units p
  set u : (ZMod p)ˣ := Units.mk0 a ha with hu
  have key := exists_pow_eq_iff_pow_card_div (G := (ZMod p)ˣ) (k := k) (by rw [hcard]; exact hk) u
  rw [hcard] at key
  constructor
  · rintro ⟨b, hb⟩
    have hb0 : b ≠ 0 := by rintro rfl; rw [zero_pow hkpos.ne'] at hb; exact ha hb.symm
    have hmk : ((Units.mk0 b hb0) ^ k) = u := by apply Units.ext; simp [hu, hb]
    have h1 := key.mp ⟨_, hmk⟩
    have := congrArg (Units.val) h1
    simpa [hu] using this
  · intro h
    have hu1 : u ^ ((p - 1) / k) = 1 := by apply Units.ext; simp [hu, h]
    obtain ⟨v, hv⟩ := key.mpr hu1
    refine ⟨(v : ZMod p), ?_⟩
    have := congrArg (Units.val) hv
    simpa [hu] using this

/-! ## 2. Residuacity as a predicate on natural numbers -/

/-- `IsPowerResidue k N a`: the natural number `a` is a `k`-th power modulo `N`. -/
def IsPowerResidue (k N a : ℕ) : Prop := ∃ b : ZMod N, b ^ k = (a : ZMod N)

/-- At a concrete modulus the predicate is decidable, by brute force over `ZMod N`.
This is what makes the small witness computations of
`Combinatorics.PowerResidueCircularity` kernel-checkable. -/
instance decidableIsPowerResidue (k N a : ℕ) [NeZero N] : Decidable (IsPowerResidue k N a) :=
  inferInstanceAs (Decidable (∃ b : ZMod N, b ^ k = (a : ZMod N)))

theorem isPowerResidue_one (k N : ℕ) : IsPowerResidue k N 1 := ⟨1, by simp⟩

/-- The criterion, stated for the natural-number predicate: for `p` prime, an
exponent `k ∣ p - 1` and a base `a` prime to `p`, residuacity is decided by the
symbol `a ^ ((p-1)/k)`. -/
theorem isPowerResidue_iff_pow {p k a : ℕ} [Fact p.Prime] (hk : k ∣ p - 1) (ha : ¬ (p ∣ a)) :
    IsPowerResidue k p a ↔ ((a : ZMod p) ^ ((p - 1) / k) = 1) := by
  haveI : NeZero p := ⟨(Fact.out (p := p.Prime)).pos.ne'⟩
  exact zmod_exists_pow_eq_iff hk (fun h => ha ((ZMod.natCast_eq_zero_iff a p).mp h))

/-- **The residuacity tower.**  If `k ∣ l` then every `l`-th power residue is a
`k`-th power residue: the channels are nested along divisibility only.  In
particular quartic residues are quadratic residues, while cubic residuacity is
incomparable with quadratic residuacity. -/
theorem isPowerResidue_of_dvd {k l N a : ℕ} (hkl : k ∣ l) (h : IsPowerResidue l N a) :
    IsPowerResidue k N a := by
  obtain ⟨b, hb⟩ := h
  obtain ⟨c, rfl⟩ := hkl
  exact ⟨b ^ c, by rw [← pow_mul, mul_comm c k, hb]⟩

/-- Residuacity is closed under products. -/
theorem isPowerResidue_mul {k N a b : ℕ} (ha : IsPowerResidue k N a)
    (hb : IsPowerResidue k N b) : IsPowerResidue k N (a * b) := by
  obtain ⟨x, hx⟩ := ha
  obtain ⟨y, hy⟩ := hb
  exact ⟨x * y, by push_cast; rw [mul_pow, hx, hy]⟩

/-- Quadratic residuacity is the classical `IsSquare` predicate. -/
theorem isPowerResidue_two_iff {N a : ℕ} : IsPowerResidue 2 N a ↔ IsSquare ((a : ZMod N)) := by
  constructor
  · rintro ⟨b, hb⟩; exact ⟨b, by rw [← hb]; ring⟩
  · rintro ⟨b, hb⟩; exact ⟨b, by rw [hb]; ring⟩

/-! ## 3. Barrier 2 in algebraic form: `N`-computable residuacity is symmetric

For a composite modulus the residuacity predicate factors through the Chinese
Remainder Theorem into the *conjunction* of the local predicates.  Hence the
only higher-power information an attacker can extract from `N = p·q` without
factoring is a symmetric function of `p` and `q`: it cannot single out a
factor. -/

/-- **CRT factorisation of residuacity.**  For coprime moduli, being a `k`-th
power mod `m·n` is being a `k`-th power mod `m` *and* mod `n`. -/
theorem isPowerResidue_mul_moduli {k m n a : ℕ} (h : Nat.Coprime m n) :
    IsPowerResidue k (m * n) a ↔ IsPowerResidue k m a ∧ IsPowerResidue k n a := by
  classical
  have e := ZMod.chineseRemainder (m := m) (n := n) h
  constructor
  · rintro ⟨b, hb⟩
    refine ⟨⟨(ZMod.castHom (show m ∣ m * n from Dvd.intro n rfl) (ZMod m)) b, ?_⟩,
            ⟨(ZMod.castHom (show n ∣ m * n from Dvd.intro_left m rfl) (ZMod n)) b, ?_⟩⟩
    · rw [← map_pow, hb, map_natCast]
    · rw [← map_pow, hb, map_natCast]
  · rintro ⟨⟨x, hx⟩, ⟨y, hy⟩⟩
    refine ⟨e.symm (x, y), ?_⟩
    have hcast : e ((a : ZMod (m * n))) = ((a : ZMod m), (a : ZMod n)) := by
      rw [map_natCast]; rfl
    apply e.injective
    rw [map_pow, RingEquiv.apply_symm_apply, hcast]
    exact Prod.ext (by simpa using hx) (by simpa using hy)

/-- **Symmetry (barrier 2).**  The `N`-computable residuacity datum at `N = p*q`
is invariant under exchanging the two factors: it is a function of the
*unordered* pair, so no amount of higher-power symbol data computed from `N`
alone can distinguish `p` from `q`. -/
theorem isPowerResidue_swap {k p q a : ℕ} (h : Nat.Coprime p q) :
    (IsPowerResidue k (p * q) a ↔ IsPowerResidue k (q * p) a) := by
  rw [isPowerResidue_mul_moduli h, isPowerResidue_mul_moduli h.symm, and_comm]

/-! ## 4. Capacity of a `K`-symbol fingerprint: the same for every exponent `k`

The experiment reports that cubic and quadratic fingerprints separate candidate
primes at the *same* rate.  Here is the reason, in its sharpest form: a
residuacity fingerprint of length `K` is a vector of `K` bits, whatever the
exponent, so it takes at most `2 ^ K` values.  Raising `k` buys nothing. -/

variable {K : ℕ}

/-- A fingerprint with values in a fixed finite type takes at most
`(card β) ^ K` values on any candidate set. -/
theorem card_image_le_pow {α β : Type*} [DecidableEq β] [Fintype β] [DecidableEq α]
    (S : Finset α) (f : α → (Fin K → β)) :
    (S.image f).card ≤ (Fintype.card β) ^ K := by
  classical
  calc (S.image f).card ≤ (Finset.univ : Finset (Fin K → β)).card :=
        Finset.card_le_card (Finset.subset_univ _)
    _ = Fintype.card (Fin K → β) := rfl
    _ = (Fintype.card β) ^ K := by simp

open scoped Classical in
/-- The **residuacity fingerprint** of a candidate modulus `N`: for each of `K`
bases, the bit "is this base a `k`-th power residue mod `N`?".  This is the
`p`-independent read-out of the power symbol — the only part of the symbol that
lives in a fixed value set. -/
noncomputable def resVec (k : ℕ) (bases : Fin K → ℕ) (N : ℕ) : Fin K → Bool :=
  fun i => decide (IsPowerResidue k N (bases i))

open scoped Classical in
/-- Reading a `true` bit off the fingerprint. -/
theorem resVec_true {k : ℕ} {bases : Fin K → ℕ} {N : ℕ} {i : Fin K}
    (h : IsPowerResidue k N (bases i)) : resVec k bases N i = true := by simp [resVec, h]

open scoped Classical in
/-- Reading a `false` bit off the fingerprint. -/
theorem resVec_false {k : ℕ} {bases : Fin K → ℕ} {N : ℕ} {i : Fin K}
    (h : ¬ IsPowerResidue k N (bases i)) : resVec k bases N i = false := by simp [resVec, h]

open scoped Classical in
/-- **Capacity bound.**  For *every* exponent `k`, a length-`K` residuacity
fingerprint takes at most `2 ^ K` values on any candidate set.  The bound is
independent of `k`: cubic and quartic channels have exactly the capacity of the
quadratic one. -/
theorem card_image_resVec_le (k : ℕ) (bases : Fin K → ℕ) (S : Finset ℕ) :
    (S.image (resVec k bases)).card ≤ 2 ^ K := by
  simpa using card_image_le_pow (β := Bool) S (resVec k bases)

open scoped Classical in
/-- A fingerprint that separates the candidates pins at most `2 ^ K` of them. -/
theorem card_le_two_pow_of_injOn {k : ℕ} {bases : Fin K → ℕ} {S : Finset ℕ}
    (hinj : Set.InjOn (resVec k bases) S) : S.card ≤ 2 ^ K := by
  classical
  have h := card_image_resVec_le k bases S
  rwa [Finset.card_image_of_injOn hinj] at h

open scoped Classical in
/-- **`Ω(log C)` symbols are needed**, for every exponent `k`: separating `C`
candidates with `k`-th power residuacity bits forces `K ≥ log₂ C`.  Passing from
`k = 2` to `k = 3, 4, …` does not change this. -/
theorem log_le_of_separating {k : ℕ} {bases : Fin K → ℕ} {S : Finset ℕ}
    (hinj : Set.InjOn (resVec k bases) S) : Nat.log 2 S.card ≤ K := by
  have h := card_le_two_pow_of_injOn hinj
  calc Nat.log 2 S.card ≤ Nat.log 2 (2 ^ K) := Nat.log_mono_right h
    _ = K := Nat.log_pow (by norm_num) K

end PowerResidue