/-
# The extremal spectrum of a finite abelian group is its divisor set

Earlier files in this development proved

* `FourierFA.card_supp_isExtremal_iff` — the support sizes of extremal functions on `G` are
  exactly the *subgroup orders* of `G`;
* `FourierFA.zmod_card_supp_isExtremal_iff` — on the cyclic group `ℤ/n` these are exactly the
  divisors of `n`.

The cyclic restriction was an artefact of the available group theory: the missing ingredient is
that a *finite abelian* group has a subgroup of every order dividing its own (a statement that
is false for general finite groups — `A₅` has no subgroup of order `30`).  This file proves that
converse of Lagrange's theorem for abelian groups by induction (Cauchy's theorem plus the
subgroup correspondence for a quotient), and deduces:

* `FourierFA.exists_addSubgroup_card_eq_of_dvd` : converse of Lagrange for finite abelian groups.
* `FourierFA.card_supp_isExtremal_iff_dvd` : **the extremal spectrum theorem** — on *any* finite
  abelian group, `d` is the support size of some extremal function iff `d ∣ |G|`.
* `FourierFA.card_supp_dft_isExtremal_iff_dvd` : the same on the frequency side.
* `FourierFA.exists_isExtremal_card_pair_iff` : the realisable pairs `(|supp f|, |supp f̂|)` are
  exactly the factorisations `s · t = |G|`.
* `FourierFA.uncertainty_ceil` : the arithmetic sharpening of Donoho–Stark,
  `|supp f̂| ≥ ⌈|G| / |supp f|⌉`.
* `FourierFA.uncertainty_gap_mod` : consequently `|supp f|·|supp f̂| ≥ |G| + (s - |G| mod s)`
  whenever `s = |supp f|` does not divide `|G|`, strictly sharper than the previously proved
  gap of `1`.
* `FourierFA.card_prime_iff_extremal_sizes` : `|G|` is prime **iff** every extremal function has
  support of size `1` or `|G|` — primality is detected by the extremal class alone.
* `FourierFA.card_eq_of_extremal_spectrum_eq` : two finite abelian groups with the same extremal
  spectrum have the same order (a reconstruction statement).
* `FourierFA.exists_isPoissonPair_card_iff` : the sizes of the sets carrying a Poisson summation
  formula on `G` are exactly the divisors of `|G|`.
* `FourierFA.exists_isExtremal_supp_eq_iff`,
  `FourierFA.exists_isExtremal_supp_eq_iff_parallelogram` : the supports of extremal functions
  are exactly the cosets, equivalently the nonempty sets closed under `(x, y, z) ↦ x - y + z` —
  a decidable combinatorial criterion.
* `FourierFA.extremalSupports_separates_order_four` : the *sets* see more than the sizes — the
  two groups of order `4` share their extremal spectrum but have `2` and `6` extremal supports
  of size `2` respectively (a kernel-checked finite computation).
-/
import Mathlib
import Shared.FourierFiniteAbelian
import Shared.FourierSubgroupDuality
import Shared.FourierExtremals
import Probability.FourierRigidity
import Probability.FourierExtremalConverse
import Probability.FourierExtremalStructure

open Finset ComplexConjugate

namespace FourierFA

universe u

/-! ## Converse of Lagrange's theorem for finite abelian groups -/

/-- Auxiliary form of the converse of Lagrange's theorem, phrased so that strong induction on
the order of the group is available. -/
theorem exists_addSubgroup_card_eq_aux :
    ∀ (n : ℕ) (A : Type u) [AddCommGroup A] [Finite A], Nat.card A = n →
      ∀ d, d ∣ n → ∃ K : AddSubgroup A, Nat.card K = d := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro A _ _ hA d hd
    rcases eq_or_ne d 1 with rfl | hd1
    · exact ⟨⊥, by simp⟩
    have hn0 : n ≠ 0 := by
      rintro rfl
      have := Nat.card_pos (α := A)
      omega
    have hd0 : d ≠ 0 := by rintro rfl; exact hn0 (Nat.eq_zero_of_zero_dvd hd)
    obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd hd1
    haveI : Fact p.Prime := ⟨hp⟩
    have hpn : p ∣ n := hpd.trans hd
    haveI : Fintype A := Fintype.ofFinite A
    have hcardA : Fintype.card A = n := by rwa [← Nat.card_eq_fintype_card]
    -- Cauchy's theorem provides an element, hence a subgroup, of prime order `p`
    obtain ⟨x, hx⟩ := exists_prime_addOrderOf_dvd_card (G := A) p (by rw [hcardA]; exact hpn)
    set C := AddSubgroup.zmultiples x with hC
    have hcardC : Nat.card C = p := by rw [Nat.card_zmultiples, hx]
    have hquot : Nat.card (A ⧸ C) * Nat.card C = n := by
      rw [← AddSubgroup.card_eq_card_quotient_mul_card_addSubgroup, hA]
    rw [hcardC] at hquot
    obtain ⟨m, hm⟩ := hpd
    obtain ⟨k, hk⟩ := hd
    have hQlt : Nat.card (A ⧸ C) < n := by
      have hp1 : 1 < p := hp.one_lt
      nlinarith [Nat.pos_of_ne_zero (show Nat.card (A ⧸ C) ≠ 0 by
        rintro h; rw [h] at hquot; omega)]
    have hmdvd : m ∣ Nat.card (A ⧸ C) := by
      refine ⟨k, ?_⟩
      have h : Nat.card (A ⧸ C) * p = (p * m) * k := by rw [hquot, hk, hm]
      have hp0 : 0 < p := hp.pos
      nlinarith
    -- the induction hypothesis in the quotient, pulled back along `A → A ⧸ C`
    obtain ⟨K', hK'⟩ := ih _ hQlt (A ⧸ C) rfl m hmdvd
    refine ⟨AddSubgroup.comap (QuotientAddGroup.mk' C) K', ?_⟩
    have hidx : (AddSubgroup.comap (QuotientAddGroup.mk' C) K').index = K'.index :=
      AddSubgroup.index_comap_of_surjective _ (QuotientAddGroup.mk'_surjective C)
    have h1 : K'.index * Nat.card K' = Nat.card (A ⧸ C) := AddSubgroup.index_mul_card K'
    have h2 : (AddSubgroup.comap (QuotientAddGroup.mk' C) K').index *
        Nat.card (AddSubgroup.comap (QuotientAddGroup.mk' C) K') = Nat.card A :=
      AddSubgroup.index_mul_card _
    rw [hidx, hA] at h2
    rw [hK'] at h1
    have hipos : 0 < K'.index := by
      rcases Nat.eq_zero_or_pos K'.index with h | h
      · rw [h, zero_mul] at h1
        exact absurd h1.symm (Nat.card_pos (α := A ⧸ C)).ne'
      · exact h
    have hnn : K'.index * m * p = p * m * k := by rw [h1, hquot, hk, hm]
    refine Nat.eq_of_mul_eq_mul_left hipos ?_
    calc K'.index * Nat.card (AddSubgroup.comap (QuotientAddGroup.mk' C) K') = n := h2
      _ = p * m * k := by rw [hk, hm]
      _ = K'.index * m * p := hnn.symm
      _ = K'.index * d := by rw [hm]; ring

/-- **Converse of Lagrange's theorem for finite abelian groups.**  If `d` divides the order of a
finite abelian group `A`, then `A` has a subgroup of order exactly `d`.  (The commutativity
hypothesis is essential: the alternating group `A₅` has order `60` but no subgroup of order
`30`.) -/
theorem exists_addSubgroup_card_eq_of_dvd {A : Type u} [AddCommGroup A] [Finite A] {d : ℕ}
    (hd : d ∣ Nat.card A) : ∃ K : AddSubgroup A, Nat.card K = d :=
  exists_addSubgroup_card_eq_aux _ A rfl d hd

variable {G : Type*} [AddCommGroup G] [Fintype G] [DecidableEq G]

/-! ## The extremal spectrum -/

/-- **The extremal spectrum theorem.**  On an arbitrary finite abelian group `G`, a natural
number `d` occurs as the support size of a function attaining equality in the Donoho–Stark
uncertainty principle **iff** `d` divides `|G|`.  This removes the cyclicity hypothesis from
`zmod_card_supp_isExtremal_iff`: the extremal class sees exactly the divisor lattice of `|G|`,
never the finer structure of the subgroup lattice. -/
theorem card_supp_isExtremal_iff_dvd (d : ℕ) :
    (∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ (supp f).card = d) ↔ d ∣ Fintype.card G := by
  rw [card_supp_isExtremal_iff]
  constructor
  · rintro ⟨K, rfl⟩
    have h := AddSubgroup.card_addSubgroup_dvd_card K
    rwa [Nat.card_eq_fintype_card (α := G)] at h
  · intro hd
    exact exists_addSubgroup_card_eq_of_dvd (by rwa [Nat.card_eq_fintype_card (α := G)])

/-- The same statement on the frequency side: the *Fourier* support sizes of extremal functions
are again exactly the divisors of `|G|` (as they must be, being the complementary divisors). -/
theorem card_supp_dft_isExtremal_iff_dvd (d : ℕ) :
    (∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ (supp (dft f)).card = d) ↔ d ∣ Fintype.card G := by
  constructor
  · rintro ⟨f, hf, hext, rfl⟩
    exact card_supp_dft_dvd_card f hext
  · intro hd
    obtain ⟨e, he⟩ := hd
    have hcard : e ∣ Fintype.card G := ⟨d, by rw [he]; ring⟩
    obtain ⟨f, hf, hext, hcf⟩ := (card_supp_isExtremal_iff_dvd (G := G) e).2 hcard
    refine ⟨f, hf, hext, ?_⟩
    have hprod : (supp f).card * (supp (dft f)).card = Fintype.card G := hext
    rw [hcf, he] at hprod
    have hepos : 0 < e := by
      rcases Nat.eq_zero_or_pos e with rfl | h
      · rw [zero_mul] at hprod
        have := Fintype.card_pos (α := G)
        omega
      · exact h
    exact Nat.eq_of_mul_eq_mul_left hepos (by rw [hprod, mul_comm])

/-! ## Arithmetic sharpening of the uncertainty principle -/

omit [AddCommGroup G] [DecidableEq G] in
/-- The support of a nonzero function is nonempty, hence has positive cardinality. -/
lemma card_supp_pos {f : G → ℂ} (hf : f ≠ 0) : 0 < (supp f).card :=
  Finset.card_pos.2 (supp_nonempty_of_ne_zero hf)

/-- **Ceiling form of the uncertainty principle.**  Since `|supp f̂|` is an integer, the bound
`|supp f|·|supp f̂| ≥ |G|` can be rounded up: `|supp f̂| ≥ ⌈|G| / |supp f|⌉`. -/
theorem uncertainty_ceil (f : G → ℂ) (hf : f ≠ 0) :
    (Fintype.card G + (supp f).card - 1) / (supp f).card ≤ (supp (dft f)).card := by
  have hspos : 0 < (supp f).card := card_supp_pos hf
  have hbound : Fintype.card G ≤ (supp f).card * (supp (dft f)).card := uncertainty f hf
  generalize hS : (supp f).card = s at *
  generalize hT : (supp (dft f)).card = t at *
  rw [Nat.div_le_iff_le_mul_add_pred hspos]
  have hcomm : s * t = t * s := mul_comm s t
  omega

/-- **The gap is a full residue.**  If the support size `s = |supp f|` does not divide `|G|`,
the uncertainty product overshoots `|G|` by at least `s - (|G| mod s)`, which is at least `1` and
can be as large as `s - 1`.  This sharpens `uncertainty_gap_of_not_dvd`. -/
theorem uncertainty_gap_mod (f : G → ℂ) (hf : f ≠ 0)
    (hnd : ¬ (supp f).card ∣ Fintype.card G) :
    Fintype.card G + ((supp f).card - Fintype.card G % (supp f).card)
      ≤ (supp f).card * (supp (dft f)).card := by
  set s := (supp f).card with hs
  set t := (supp (dft f)).card with ht
  set n := Fintype.card G with hn
  have hspos : 0 < s := card_supp_pos hf
  have hbound : n ≤ s * t := uncertainty f hf
  have hr : n % s ≠ 0 := fun h => hnd (Nat.dvd_of_mod_eq_zero h)
  have hrlt : n % s < s := Nat.mod_lt _ hspos
  have hdiv : n = s * (n / s) + n % s := (Nat.div_add_mod n s).symm
  have hqt : n / s + 1 ≤ t := by
    by_contra hcon
    push_neg at hcon
    have : s * t ≤ s * (n / s) := Nat.mul_le_mul_left s (by omega)
    omega
  have hmul : s * (n / s + 1) ≤ s * t := Nat.mul_le_mul_left s hqt
  have hexp : s * (n / s + 1) = s * (n / s) + s := by ring
  omega

/-- **The extremal spectrum as a set of pairs.**  A pair `(s, t)` occurs as
`(|supp f|, |supp f̂|)` for some extremal `f` precisely when `s · t = |G|`: no further
constraint survives.  (Compare `card_supp_dft_eq_div`: the two sizes are complementary
divisors.) -/
theorem exists_isExtremal_card_pair_iff (s t : ℕ) :
    (∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ (supp f).card = s ∧ (supp (dft f)).card = t)
      ↔ s * t = Fintype.card G := by
  constructor
  · rintro ⟨f, hf, hext, rfl, rfl⟩
    exact hext
  · intro hst
    obtain ⟨f, hf, hext, hcf⟩ :=
      (card_supp_isExtremal_iff_dvd (G := G) s).2 ⟨t, hst.symm⟩
    refine ⟨f, hf, hext, hcf, ?_⟩
    have hprod : (supp f).card * (supp (dft f)).card = Fintype.card G := hext
    rw [hcf, ← hst] at hprod
    have hspos : 0 < s := by
      rcases Nat.eq_zero_or_pos s with rfl | h
      · rw [zero_mul] at hst
        have := Fintype.card_pos (α := G)
        omega
      · exact h
    exact Nat.eq_of_mul_eq_mul_left hspos hprod

/-- **The supports of extremal functions are exactly the cosets.**  A finset `S` arises as
`supp f` for some extremal `f` iff `S` is a coset of a subgroup of `G`.  With
`card_supp_isExtremal_iff_dvd` this refines the spectrum theorem from *sizes* to *sets*: the
number of extremal supports of size `d` is the number of cosets of subgroups of order `d`, an
invariant that does distinguish `ℤ/4` from `ℤ/2 × ℤ/2`. -/
theorem exists_isExtremal_supp_eq_iff (S : Finset G) :
    (∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ supp f = S)
      ↔ ∃ (K : AddSubgroup G) (a : G), ∀ x, x ∈ S ↔ x - a ∈ K := by
  classical
  constructor
  · rintro ⟨f, hf, hext, rfl⟩
    exact isExtremal_support_coset f hf hext
  · rintro ⟨K, a, hK⟩
    letI : DecidablePred (· ∈ K) := fun _ => Classical.dec _
    refine ⟨transl a (indic K), ?_, (isExtremal_indic K).transl a, ?_⟩
    · intro h
      have h0 : transl a (indic K) a = 0 := by rw [h]; rfl
      rw [transl, sub_self] at h0
      simp [indic, K.zero_mem] at h0
    · ext x
      rw [mem_supp, transl]
      constructor
      · intro hx
        refine (hK x).2 ?_
        have : x - a ∈ supp (indic K) := mem_supp.2 hx
        rwa [supp_indic, mem_subFinset] at this
      · intro hx
        have : x - a ∈ supp (indic K) := by
          rw [supp_indic, mem_subFinset]
          exact (hK x).1 hx
        exact mem_supp.1 this

omit [Fintype G] [DecidableEq G] in
/-- A nonempty finset is a coset of a subgroup exactly when it is closed under the
"parallelogram" operation `(x, y, z) ↦ x - y + z`.  This is the decidable, purely combinatorial
form of the coset condition. -/
theorem coset_iff_parallelogram_closed (S : Finset G) (hne : S.Nonempty) :
    (∃ (K : AddSubgroup G) (a : G), ∀ x, x ∈ S ↔ x - a ∈ K)
      ↔ ∀ x ∈ S, ∀ y ∈ S, ∀ z ∈ S, x - y + z ∈ S := by
  constructor
  · rintro ⟨K, a, hK⟩ x hx y hy z hz
    refine (hK _).2 ?_
    have hx' := (hK x).1 hx
    have hy' := (hK y).1 hy
    have hz' := (hK z).1 hz
    have hrw : x - y + z - a = (x - a) - (y - a) + (z - a) := by abel
    rw [hrw]
    exact K.add_mem (K.sub_mem hx' hy') hz'
  · intro hpar
    obtain ⟨a, ha⟩ := hne
    refine ⟨{ carrier := {t : G | a + t ∈ S}
              zero_mem' := by simpa using ha
              add_mem' := ?_
              neg_mem' := ?_ }, a, ?_⟩
    · intro t u ht hu
      have ht' : a + t ∈ S := ht
      have hu' : a + u ∈ S := hu
      have := hpar _ ht' _ ha _ hu'
      have hrw : a + t - a + (a + u) = a + (t + u) := by abel
      rwa [hrw] at this
    · intro t ht
      have ht' : a + t ∈ S := ht
      have := hpar _ ha _ ht' _ ha
      have hrw : a - (a + t) + a = a + -t := by abel
      rwa [hrw] at this
    · intro x
      show x ∈ S ↔ a + (x - a) ∈ S
      rw [show a + (x - a) = x by abel]

/-- **Extremal supports are the parallelogram-closed sets.**  Combining
`exists_isExtremal_supp_eq_iff` with `coset_iff_parallelogram_closed`: a nonempty finset is the
support of an extremal function precisely when it is closed under `(x, y, z) ↦ x - y + z`.  The
analytic extremality condition has become a decidable combinatorial one. -/
theorem exists_isExtremal_supp_eq_iff_parallelogram (S : Finset G) (hne : S.Nonempty) :
    (∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ supp f = S)
      ↔ ∀ x ∈ S, ∀ y ∈ S, ∀ z ∈ S, x - y + z ∈ S :=
  (exists_isExtremal_supp_eq_iff S).trans (coset_iff_parallelogram_closed S hne)

/-! ## Primality and reconstruction -/

/-- **Primality is visible in the extremal class.**  The order of `G` is prime exactly when the
only extremal functions are the "extreme" ones — Dirac-like (support of size `1`) or spread over
all of `G`.  One direction is Lagrange rigidity; the other needs the extremal spectrum theorem,
which realises *every* divisor. -/
theorem card_prime_iff_extremal_sizes :
    (Fintype.card G).Prime ↔
      (1 < Fintype.card G ∧ ∀ f : G → ℂ, f ≠ 0 → IsExtremal f →
        (supp f).card = 1 ∨ (supp f).card = Fintype.card G) := by
  constructor
  · intro hp
    refine ⟨hp.one_lt, fun f hf hext => ?_⟩
    exact (Nat.Prime.eq_one_or_self_of_dvd hp _ (card_supp_dvd_card f hf hext))
  · rintro ⟨h1, h2⟩
    refine Nat.prime_def.2 ⟨h1, fun d hd => ?_⟩
    obtain ⟨f, hf, hext, hcard⟩ := (card_supp_isExtremal_iff_dvd (G := G) d).2 hd
    rcases h2 f hf hext with h | h
    · exact Or.inl (by rw [← hcard, h])
    · exact Or.inr (by rw [← hcard, h])

/-- **Reconstruction of the order from the extremal spectrum.**  Two finite abelian groups whose
extremal functions realise the same set of support sizes have the same order.  (By
`card_supp_isExtremal_iff_dvd` the spectrum *is* the divisor set of the order, and a natural
number is determined by its divisors.) -/
theorem card_eq_of_extremal_spectrum_eq {G' : Type*} [AddCommGroup G'] [Fintype G']
    [DecidableEq G']
    (h : ∀ d : ℕ, (∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ (supp f).card = d) ↔
      (∃ g : G' → ℂ, g ≠ 0 ∧ IsExtremal g ∧ (supp g).card = d)) :
    Fintype.card G = Fintype.card G' := by
  have hGG' : Fintype.card G ∣ Fintype.card G' :=
    (card_supp_isExtremal_iff_dvd (G := G') _).1
      ((h _).1 ((card_supp_isExtremal_iff_dvd (G := G) _).2 dvd_rfl))
  have hG'G : Fintype.card G' ∣ Fintype.card G :=
    (card_supp_isExtremal_iff_dvd (G := G) _).1
      ((h _).2 ((card_supp_isExtremal_iff_dvd (G := G') _).2 dvd_rfl))
  exact Nat.dvd_antisymm hGG' hG'G

/-- The converse of `card_eq_of_extremal_spectrum_eq`: groups of the same order have the same
extremal spectrum.  Together the two results say that the extremal spectrum of a finite abelian
group carries *exactly* the information of its order — no finer invariant (exponent, number of
invariant factors, …) can be read off from the support sizes alone. -/
theorem extremal_spectrum_eq_of_card_eq {G' : Type*} [AddCommGroup G'] [Fintype G']
    [DecidableEq G'] (hcard : Fintype.card G = Fintype.card G') (d : ℕ) :
    (∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ (supp f).card = d) ↔
      (∃ g : G' → ℂ, g ≠ 0 ∧ IsExtremal g ∧ (supp g).card = d) := by
  rw [card_supp_isExtremal_iff_dvd, card_supp_isExtremal_iff_dvd, hcard]

/-! ## The Poisson spectrum -/

/-- **The Poisson spectrum theorem.**  A number `d` is the size of a (nonempty) set carrying a
Poisson summation formula on `G` precisely when `d ∣ |G|`.  Combined with `poisson_converse`
this says: the finite Poisson summation formulas on `G` are indexed by the subgroups, and their
sizes exhaust the divisors of `|G|`. -/
theorem exists_isPoissonPair_card_iff (d : ℕ) :
    (∃ (S : Finset G) (T : Finset (AddChar G ℂ)), IsPoissonPair S T ∧ S.Nonempty ∧ S.card = d)
      ↔ d ∣ Fintype.card G := by
  classical
  constructor
  · rintro ⟨S, T, hST, hS, rfl⟩
    exact poisson_card_dvd hST hS
  · intro hd
    obtain ⟨K, hK⟩ :=
      exists_addSubgroup_card_eq_of_dvd (A := G) (d := d)
        (by rwa [Nat.card_eq_fintype_card (α := G)])
    letI : DecidablePred (· ∈ K) := fun _ => Classical.dec _
    refine ⟨supp (indic K), supp (dft (indic K)), isPoissonPair_of_subgroup K, ?_, ?_⟩
    · exact ⟨0, by rw [supp_indic, mem_subFinset]; exact K.zero_mem⟩
    · rw [supp_indic, card_subFinset, hK]

/-! ## The extremal supports count separates groups of equal order

By `extremal_spectrum_eq_of_card_eq` the extremal *sizes* only see `|G|`.  The *sets* see more:
the number of extremal supports of a given size is the number of cosets of subgroups of that
order.  The two groups of order `4` are separated by this invariant, and
`exists_isExtremal_supp_eq_iff_parallelogram` makes the count a finite, kernel-checkable
computation. -/

/-- The family of `d`-element supports of extremal functions on `G`. -/
noncomputable def extremalSupports (G : Type*) [AddCommGroup G] [Fintype G] [DecidableEq G]
    (d : ℕ) : Finset (Finset G) :=
  @Finset.filter _ (fun S => (∃ f : G → ℂ, f ≠ 0 ∧ IsExtremal f ∧ supp f = S) ∧ S.card = d)
    (fun _ => Classical.dec _) Finset.univ

/-- The analytic count equals the combinatorial one: extremal supports of size `d ≥ 1` are the
parallelogram-closed sets of size `d`. -/
theorem card_extremalSupports_eq (d : ℕ) (hd : 1 ≤ d) :
    (extremalSupports G d).card =
      (Finset.univ.filter (fun S : Finset G =>
        (∀ x ∈ S, ∀ y ∈ S, ∀ z ∈ S, x - y + z ∈ S) ∧ S.card = d)).card := by
  congr 1
  ext S
  simp only [extremalSupports, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro ⟨hex, hcard⟩
    have hne : S.Nonempty := Finset.card_pos.1 (by omega)
    exact ⟨(exists_isExtremal_supp_eq_iff_parallelogram S hne).1 hex, hcard⟩
  · rintro ⟨hpar, hcard⟩
    have hne : S.Nonempty := Finset.card_pos.1 (by omega)
    exact ⟨(exists_isExtremal_supp_eq_iff_parallelogram S hne).2 hpar, hcard⟩

set_option maxRecDepth 10000 in
/-- On `ℤ/4` there are exactly `2` extremal supports of size `2` — the two cosets of the unique
subgroup of order `2`. -/
theorem card_extremalSupports_two_zmod4 : (extremalSupports (ZMod 4) 2).card = 2 := by
  rw [card_extremalSupports_eq 2 (by norm_num)]
  decide

set_option maxRecDepth 100000 in
/-- On the Klein group `ℤ/2 × ℤ/2` there are exactly `6` extremal supports of size `2` — two
cosets for each of the three subgroups of order `2`. -/
theorem card_extremalSupports_two_klein :
    (extremalSupports (ZMod 2 × ZMod 2) 2).card = 6 := by
  rw [card_extremalSupports_eq 2 (by norm_num)]
  decide

/-- **The extremal spectrum is not a complete invariant, but the extremal supports are finer.**
The two groups of order `4` have literally the same extremal spectrum, yet different numbers of
extremal supports of size `2`.  So no invariant computed from the support *sizes* can
distinguish finite abelian groups of equal order, while the family of extremal *supports*
already does. -/
theorem extremalSupports_separates_order_four :
    (∀ d : ℕ, (∃ f : ZMod 4 → ℂ, f ≠ 0 ∧ IsExtremal f ∧ (supp f).card = d) ↔
        (∃ g : ZMod 2 × ZMod 2 → ℂ, g ≠ 0 ∧ IsExtremal g ∧ (supp g).card = d)) ∧
      (extremalSupports (ZMod 4) 2).card ≠ (extremalSupports (ZMod 2 × ZMod 2) 2).card := by
  refine ⟨extremal_spectrum_eq_of_card_eq ?_, ?_⟩
  · simp [ZMod.card]
  · rw [card_extremalSupports_two_zmod4, card_extremalSupports_two_klein]
    norm_num

end FourierFA