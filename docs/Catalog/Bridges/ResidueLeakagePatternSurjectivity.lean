/-
# Pattern surjectivity of the QR fingerprint, and the failure of individual pinning

Companion file to `Bridges.ResidueLeakageDirichletNoPruning`.

Where the no-pruning theorem shows that the cheap residue channel cannot *remove*
any candidate prime, this file shows the complementary, constructive fact: the
fingerprint map is **surjective onto all `2^K` sign patterns**, already on primes.
The proof is a genuine cross-domain bridge:

* Chinese remainder theorem (`existsCRT`) to build the residue class,
* quadratic reciprocity + the supplementary law at `2` (`jacobiSym.at_two`),
* existence of a quadratic nonresidue in a finite field
  (`FiniteField.exists_nonsquare`),
* Dirichlet's theorem (imported through `infinite_primes_jacobi_eq`).

Main results:

* `exists_prime_jacobi_pattern` — every prescribed sign pattern on a set of
  distinct odd probe primes, together with a prescribed value at `2`, is
  realised by infinitely many primes.
* `qrFingerprint_pattern_surjective` — the same for an arbitrary list of
  distinct probe primes (the prime `2` allowed): all `2^K` fingerprints occur.
* `no_individual_pinning` — for any observed `F_A(N₀)` and any probe prime `a₀`,
  there are consistent factorisations `p₁q₁` and `p₂q₂` of the *same*
  fingerprint with `(a₀|p₁) = 1` and `(a₀|p₂) = -1`: the data pins down no
  individual symbol of a factor, only the symmetric products.
-/

import Mathlib
import Bridges.ResidueLeakageDirichletNoPruning

namespace Bridges.ResidueLeakage

/-! ## A Chinese remainder theorem for lists of moduli -/

/-- Chinese remainder theorem for a list of pairwise coprime moduli:
prescribed residues `f x` mod `x` can be realised simultaneously. -/
theorem existsCRT : ∀ (L : List ℕ), L.Pairwise Nat.Coprime → ∀ f : ℕ → ℕ,
    ∃ m : ℕ, ∀ x ∈ L, m ≡ f x [MOD x] := by
  intro L
  induction L with
  | nil => intro _ f; exact ⟨0, by simp⟩
  | cons a t ih =>
      intro hcop f
      obtain ⟨mt, hmt⟩ := ih hcop.of_cons f
      have hat : Nat.Coprime a t.prod :=
        coprime_list_prod fun b hb => (List.pairwise_cons.1 hcop).1 b hb
      obtain ⟨k, hk1, hk2⟩ := Nat.chineseRemainder hat (f a) mt
      refine ⟨k, fun x hx => ?_⟩
      rcases List.mem_cons.1 hx with rfl | hx
      · exact hk1
      · exact (hk2.of_dvd (List.dvd_prod hx)).trans (hmt x hx)

/-! ## A quadratic nonresidue witness -/

open Classical in
/-- A natural number that is a quadratic nonresidue mod `p` (for `p` an odd
prime); junk value `0` otherwise. -/
noncomputable def nonresidueWitness (p : ℕ) : ℕ :=
  if h : ∃ r : ℕ, ¬ IsSquare ((r : ZMod p)) then h.choose else 0

theorem legendreSym_nonresidueWitness (p : ℕ) [Fact p.Prime] (h2 : p ≠ 2) :
    legendreSym p (nonresidueWitness p) = -1 := by
  have hex : ∃ r : ℕ, ¬ IsSquare ((r : ZMod p)) := by
    obtain ⟨x, hx⟩ := FiniteField.exists_nonsquare (F := ZMod p)
      (by simpa [ZMod.ringChar_zmod_n] using h2)
    exact ⟨x.val, by simpa using hx⟩
  have : nonresidueWitness p = hex.choose := by
    simp [nonresidueWitness, dif_pos hex]
  rw [this, legendreSym.eq_neg_one_iff]
  simpa using hex.choose_spec

/-! ## Building a modulus with a prescribed symbol pattern -/

/-- The residue prescription used in the construction: `1` for a `+1` target,
a quadratic nonresidue for a `-1` target; at the modulus `8` we use
`1` (giving `(2|m) = 1`) or `5` (giving `(2|m) = -1`). -/
noncomputable def patternResidue (e₂ : ℤ) (ε : ℕ → ℤ) (x : ℕ) : ℕ :=
  if x = 8 then (if e₂ = 1 then 1 else 5)
  else if ε x = 1 then 1 else nonresidueWitness x

/-- **Existence of a modulus with any prescribed pattern.** -/
theorem exists_modulus_jacobi_pattern {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (h2 : ∀ a ∈ A, a ≠ 2) (hnd : A.Nodup) {e₂ : ℤ} (he₂ : e₂ = 1 ∨ e₂ = -1)
    {ε : ℕ → ℤ} (hε : ∀ a ∈ A, ε a = 1 ∨ ε a = -1) :
    ∃ m : ℕ, Odd m ∧ Nat.Coprime m 2 ∧ (∀ a ∈ A, Nat.Coprime m a) ∧
      jacobiSym 2 m = e₂ ∧ ∀ a ∈ A, jacobiSym (a : ℤ) m = ε a := by
  classical
  set f := patternResidue e₂ ε with hf
  -- the list of moduli `8 :: A` is pairwise coprime
  have hApw : A.Pairwise Nat.Coprime :=
    hnd.imp_of_mem fun {a b} ha hb hne => (Nat.coprime_primes (hA a ha) (hA b hb)).2 hne
  have hcop8 : ∀ a ∈ A, Nat.Coprime 8 a := by
    intro a ha
    have hodd : Odd a := (hA a ha).odd_of_ne_two (h2 a ha)
    have : Nat.Coprime a 2 := Nat.coprime_two_right.2 hodd
    have h2a : Nat.Coprime 2 a := this.symm
    have := (h2a.pow_left 3)
    norm_num at this
    exact this
  have hpw : (8 :: A).Pairwise Nat.Coprime := List.pairwise_cons.2 ⟨hcop8, hApw⟩
  obtain ⟨m, hm⟩ := existsCRT (8 :: A) hpw f
  have hm8 : m ≡ f 8 [MOD 8] := hm 8 (by simp)
  have hf8 : f 8 = if e₂ = 1 then 1 else 5 := by simp [hf, patternResidue]
  -- `m % 8 ∈ {1, 5}`, according to the prescribed sign at `2`
  have hm8' : m % 8 = f 8 % 8 := hm8
  have hcase : (e₂ = 1 ∧ m % 8 = 1) ∨ (e₂ = -1 ∧ m % 8 = 5) := by
    rcases he₂ with h | h
    · refine Or.inl ⟨h, ?_⟩
      have hfe : f 8 = 1 := by rw [hf8, if_pos h]
      rw [hm8', hfe]
    · refine Or.inr ⟨h, ?_⟩
      have hfe : f 8 = 5 := by rw [hf8, if_neg (by rw [h]; norm_num)]
      rw [hm8', hfe]
  have hmod8 : m % 8 = 1 ∨ m % 8 = 5 := by
    rcases hcase with ⟨-, h⟩ | ⟨-, h⟩
    · exact Or.inl h
    · exact Or.inr h
  have hmodd : Odd m := by rw [Nat.odd_iff]; omega
  have hm4 : m % 4 = 1 := by omega
  -- the value at 2
  have hat2 : jacobiSym 2 m = e₂ := by
    rw [jacobiSym.at_two hmodd, ZMod.χ₈_nat_eq_if_mod_eight]
    have hm2 : m % 2 = 1 := Nat.odd_iff.1 hmodd
    rcases hcase with ⟨he, h8⟩ | ⟨he, h8⟩
    · rw [he]; simp [hm2, h8]
    · rw [he]; simp [hm2, h8]
  -- the values at the odd probe primes
  have hatodd : ∀ a ∈ A, jacobiSym (a : ℤ) m = ε a := by
    intro a ha
    haveI : Fact a.Prime := ⟨hA a ha⟩
    have hodd : Odd a := (hA a ha).odd_of_ne_two (h2 a ha)
    have hrec : jacobiSym (m : ℤ) a = jacobiSym (a : ℤ) m :=
      jacobiSym.quadratic_reciprocity_one_mod_four hm4 hodd
    have hleg : jacobiSym (a : ℤ) m = legendreSym a (m : ℤ) := by
      rw [← hrec, jacobiSym.legendreSym.to_jacobiSym]
    have hcong : m ≡ f a [MOD a] := hm a (by simp [ha])
    have hint : (m : ℤ) % (a : ℤ) = ((f a : ℕ) : ℤ) % (a : ℤ) := by
      have := hcong
      unfold Nat.ModEq at this
      exact_mod_cast congrArg (fun n : ℕ => (n : ℤ)) this
    have hmodeq : legendreSym a (m : ℤ) = legendreSym a ((f a : ℕ) : ℤ) := by
      rw [legendreSym.mod a (m : ℤ), legendreSym.mod a ((f a : ℕ) : ℤ), hint]
    have ha8 : a ≠ 8 := by
      intro h
      have h8 : Nat.Prime 8 := h ▸ hA a ha
      norm_num at h8
    rcases hε a ha with hεa | hεa
    · have hfa : f a = 1 := by simp [hf, patternResidue, ha8, hεa]
      rw [hleg, hmodeq, hfa, hεa]
      simp
    · have hfa : f a = nonresidueWitness a := by
        simp [hf, patternResidue, ha8, hεa]
      rw [hleg, hmodeq, hfa, hεa]
      exact legendreSym_nonresidueWitness a (h2 a ha)
  -- coprimality follows from the symbols being nonzero
  have hm0 : m ≠ 0 := by intro h; rw [h] at hmod8; simp at hmod8
  have : NeZero m := ⟨hm0⟩
  have hcopA : ∀ a ∈ A, Nat.Coprime m a := by
    intro a ha
    have hne : jacobiSym (a : ℤ) m ≠ 0 := by
      rw [hatodd a ha]; rcases hε a ha with h | h <;> rw [h] <;> norm_num
    have := (jacobiSym.eq_zero_iff_not_coprime (a := (a : ℤ)) (b := m)).not.1 hne
    rw [not_not] at this
    have hgcd : Nat.gcd a m = 1 := by simpa [Int.gcd_natCast_natCast] using this
    exact (Nat.coprime_iff_gcd_eq_one.2 hgcd).symm
  exact ⟨m, hmodd, Nat.coprime_two_right.2 hmodd, hcopA, hat2, hatodd⟩

/-! ## Pattern surjectivity on primes -/

/-- **All sign patterns are realised by primes.**  For distinct odd probe primes
`A`, any prescribed signs `ε a ∈ {±1}` and any prescribed value `e₂ ∈ {±1}` at
the prime `2`, infinitely many primes `q` have exactly those Jacobi symbols. -/
theorem exists_prime_jacobi_pattern {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (h2 : ∀ a ∈ A, a ≠ 2) (hnd : A.Nodup) {e₂ : ℤ} (he₂ : e₂ = 1 ∨ e₂ = -1)
    {ε : ℕ → ℤ} (hε : ∀ a ∈ A, ε a = 1 ∨ ε a = -1) :
    {q : ℕ | q.Prime ∧ Odd q ∧ jacobiSym 2 q = e₂ ∧
      ∀ a ∈ A, jacobiSym (a : ℤ) q = ε a}.Infinite := by
  obtain ⟨m, hmodd, hm2, hmA, hme₂, hmε⟩ :=
    exists_modulus_jacobi_pattern hA h2 hnd he₂ hε
  have hA' : ∀ a ∈ (2 :: A), a.Prime := by
    intro a ha
    rcases List.mem_cons.1 ha with rfl | ha
    · exact Nat.prime_two
    · exact hA a ha
  have hcop' : ∀ a ∈ (2 :: A), Nat.Coprime m a := by
    intro a ha
    rcases List.mem_cons.1 ha with rfl | ha
    · exact hm2
    · exact hmA a ha
  refine (infinite_primes_jacobi_eq hA' hmodd hcop').mono ?_
  rintro q ⟨hq, hqodd, hsym⟩
  refine ⟨hq, hqodd, ?_, ?_⟩
  · have := hsym 2 (by simp)
    simpa [hme₂] using this
  · intro a ha
    have := hsym a (by simp [ha])
    rw [this, hmε a ha]

/-- **Fingerprint surjectivity.**  For any list `A` of distinct primes (the
prime `2` allowed) and any `±1`-pattern, infinitely many primes realise that
fingerprint.  With `A` the first `K` primes this gives all `2^K` patterns. -/
theorem qrFingerprint_pattern_surjective {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (hnd : A.Nodup) {ε : ℕ → ℤ} (hε : ∀ a ∈ A, ε a = 1 ∨ ε a = -1) :
    {q : ℕ | q.Prime ∧ Odd q ∧ qrFingerprint A q = A.map ε}.Infinite := by
  classical
  set B := A.filter (fun a => decide (a ≠ 2)) with hB
  have hBsub : ∀ a ∈ B, a ∈ A := fun a ha => List.mem_of_mem_filter ha
  have hBprime : ∀ a ∈ B, a.Prime := fun a ha => hA a (hBsub a ha)
  have hB2 : ∀ a ∈ B, a ≠ 2 := by
    intro a ha
    have := List.of_mem_filter ha
    simpa using this
  have hBnd : B.Nodup := hnd.filter _
  have hBε : ∀ a ∈ B, ε a = 1 ∨ ε a = -1 := fun a ha => hε a (hBsub a ha)
  -- prescribe the value at `2`
  set e₂ : ℤ := if 2 ∈ A then ε 2 else 1 with he₂def
  have he₂ : e₂ = 1 ∨ e₂ = -1 := by
    by_cases h : 2 ∈ A
    · simp only [he₂def, if_pos h]; exact hε 2 h
    · left; simp [he₂def, h]
  refine (exists_prime_jacobi_pattern hBprime hB2 hBnd he₂ hBε).mono ?_
  rintro q ⟨hq, hqodd, hq2, hqB⟩
  refine ⟨hq, hqodd, ?_⟩
  simp only [qrFingerprint]
  refine List.map_congr_left fun a ha => ?_
  by_cases ha2 : a = 2
  · subst ha2
    have : e₂ = ε 2 := by simp [he₂def, ha]
    rw [show ((2 : ℕ) : ℤ) = (2 : ℤ) by norm_num, hq2, this]
  · have haB : a ∈ B := List.mem_filter.2 ⟨ha, by simpa using ha2⟩
    exact hqB a haB

/-! ## No individual pinning -/

/-- **No individual pinning.**  Fix probe primes `A`, an observed fingerprint
`F_A(N₀)`, and a probe prime `a₀ ∈ A`.  Then there are two semiprimes
`p₁ * q₁` and `p₂ * q₂` with *the same* fingerprint as `N₀` whose first factors
have opposite symbols at `a₀`.  Hence the residue data determines no individual
symbol `(a₀ | p)` of a factor — only the symmetric products `(a₀|p)(a₀|q)`,
which are already read off from `N₀` itself. -/
theorem no_individual_pinning {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (hnd : A.Nodup) {N₀ : ℕ} (hN₀ : Odd N₀) (hNA : ∀ a ∈ A, Nat.Coprime N₀ a)
    {a₀ : ℕ} (ha₀ : a₀ ∈ A) :
    ∃ p₁ q₁ p₂ q₂ : ℕ,
      p₁.Prime ∧ q₁.Prime ∧ p₂.Prime ∧ q₂.Prime ∧
      qrFingerprint A (p₁ * q₁) = qrFingerprint A N₀ ∧
      qrFingerprint A (p₂ * q₂) = qrFingerprint A N₀ ∧
      jacobiSym (a₀ : ℤ) p₁ = 1 ∧ jacobiSym (a₀ : ℤ) p₂ = -1 := by
  classical
  -- a prime with all symbols `+1`
  have hplus : ∀ ε : ℕ → ℤ, (∀ a ∈ A, ε a = 1 ∨ ε a = -1) →
      ∃ p : ℕ, p.Prime ∧ Odd p ∧ (∀ a ∈ A, a ≠ p) ∧
        ∀ a ∈ A, jacobiSym (a : ℤ) p = ε a := by
    intro ε hε
    obtain ⟨p, hp, hpodd, hpf⟩ :=
      (qrFingerprint_pattern_surjective hA hnd hε).nonempty
    have hsym : ∀ a ∈ A, jacobiSym (a : ℤ) p = ε a := fun a ha =>
      List.map_inj_left.1 hpf a ha
    refine ⟨p, hp, hpodd, ?_, hsym⟩
    intro a ha hap
    have h0 : jacobiSym (a : ℤ) p = 0 := by
      subst hap
      haveI : NeZero a := ⟨(hA a ha).ne_zero⟩
      rw [jacobiSym.eq_zero_iff_not_coprime]
      simp [(hA a ha).one_lt.ne']
    rcases hε a ha with h | h <;> rw [hsym a ha, h] at h0 <;> norm_num at h0
  obtain ⟨p₁, hp₁, hp₁odd, hp₁ne, hp₁sym⟩ := hplus (fun _ => 1) (by intro a _; left; rfl)
  obtain ⟨p₂, hp₂, hp₂odd, hp₂ne, hp₂sym⟩ :=
    hplus (fun a => if a = a₀ then -1 else 1) (by
      intro a _; by_cases h : a = a₀ <;> simp [h])
  obtain ⟨q₁, hq₁, hq₁f⟩ :=
    exists_compensating_prime hA hN₀ hp₁ hp₁odd hNA hp₁ne
  obtain ⟨q₂, hq₂, hq₂f⟩ :=
    exists_compensating_prime hA hN₀ hp₂ hp₂odd hNA hp₂ne
  refine ⟨p₁, q₁, p₂, q₂, hp₁, hq₁, hp₂, hq₂, hq₁f, hq₂f, ?_, ?_⟩
  · simpa using hp₁sym a₀ ha₀
  · simpa using hp₂sym a₀ ha₀

/-! ## The exact range of the fingerprint -/

/-- On a duplicate-free list any target list of the right length is the image of
some function. -/
theorem exists_map_eq_of_nodup : ∀ (A : List ℕ), A.Nodup → ∀ v : List ℤ,
    v.length = A.length → ∃ ε : ℕ → ℤ, A.map ε = v := by
  classical
  intro A
  induction A with
  | nil => intro _ v hv; exact ⟨fun _ => 0, by simpa using (List.length_eq_zero_iff.1 hv).symm⟩
  | cons a t ih =>
      intro hnd v hv
      obtain ⟨x, w, rfl⟩ : ∃ x w, v = x :: w := by
        cases v with
        | nil => simp at hv
        | cons x w => exact ⟨x, w, rfl⟩
      have hant : a ∉ t := (List.nodup_cons.1 hnd).1
      obtain ⟨ε', hε'⟩ := ih (List.nodup_cons.1 hnd).2 w (by simpa using hv)
      refine ⟨fun y => if y = a then x else ε' y, ?_⟩
      have ht : t.map (fun y => if y = a then x else ε' y) = t.map ε' :=
        List.map_congr_left fun b hb => by
          have : b ≠ a := fun h => hant (h ▸ hb)
          simp [this]
      simp [ht, hε']

/-- **The range of the QR fingerprint on primes is everything.**  For distinct
probe primes `A`, the fingerprints of the primes `q ∉ A` are exactly the
`±1`-vectors of length `|A|`; there are `2^|A|` of them and each occurs. -/
theorem qrFingerprint_range_eq {A : List ℕ} (hA : ∀ a ∈ A, a.Prime)
    (hnd : A.Nodup) :
    {v : List ℤ | ∃ q : ℕ, q.Prime ∧ q ∉ A ∧ qrFingerprint A q = v}
      = {v : List ℤ | v.length = A.length ∧ ∀ x ∈ v, x = 1 ∨ x = -1} := by
  ext v
  constructor
  · rintro ⟨q, hq, hqA, rfl⟩
    refine ⟨by simp, ?_⟩
    intro x hx
    simp only [qrFingerprint, List.mem_map] at hx
    obtain ⟨a, ha, rfl⟩ := hx
    have hne : a ≠ q := fun h => hqA (h ▸ ha)
    have hcop : Int.gcd (a : ℤ) (q : ℕ) = 1 := by
      simpa [Int.gcd_natCast_natCast] using (Nat.coprime_primes (hA a ha) hq).2 hne
    exact jacobiSym.eq_one_or_neg_one hcop
  · rintro ⟨hlen, hv⟩
    obtain ⟨ε, hε⟩ := exists_map_eq_of_nodup A hnd v hlen
    have hεA : ∀ a ∈ A, ε a = 1 ∨ ε a = -1 := by
      intro a ha
      exact hv (ε a) (hε ▸ List.mem_map_of_mem ha)
    obtain ⟨q, hq, -, hqf⟩ :=
      (qrFingerprint_pattern_surjective hA hnd hεA).nonempty
    refine ⟨q, hq, ?_, by rw [hqf, hε]⟩
    intro hqA
    have h0 : jacobiSym (q : ℤ) q = 0 := by
      haveI : NeZero q := ⟨hq.ne_zero⟩
      rw [jacobiSym.eq_zero_iff_not_coprime]
      simp [hq.one_lt.ne']
    have hval : jacobiSym (q : ℤ) q = ε q := List.map_inj_left.1 hqf q hqA
    rcases hεA q hqA with h | h <;> rw [hval, h] at h0 <;> norm_num at h0

/-! ## Specialisation to the first `K` primes -/

theorem primeBasis_nodup (K : ℕ) : (primeBasis K).Nodup :=
  (List.nodup_range).map (Nat.nth_injective Nat.infinite_setOf_prime)

/-- All `2^K` sign patterns of the first `K` primes are fingerprints of
infinitely many primes. -/
theorem primeBasis_pattern_surjective (K : ℕ) {ε : ℕ → ℤ}
    (hε : ∀ a ∈ primeBasis K, ε a = 1 ∨ ε a = -1) :
    {q : ℕ | q.Prime ∧ Odd q ∧
      qrFingerprint (primeBasis K) q = (primeBasis K).map ε}.Infinite :=
  qrFingerprint_pattern_surjective (fun _ ha => primeBasis_prime ha)
    (primeBasis_nodup K) hε

/-- The fingerprint over the first `K` primes realises exactly the `2^K`
`±1`-vectors of length `K`. -/
theorem primeBasis_range_eq (K : ℕ) :
    {v : List ℤ | ∃ q : ℕ, q.Prime ∧ q ∉ primeBasis K ∧
        qrFingerprint (primeBasis K) q = v}
      = {v : List ℤ | v.length = K ∧ ∀ x ∈ v, x = 1 ∨ x = -1} := by
  rw [qrFingerprint_range_eq (fun _ ha => primeBasis_prime ha) (primeBasis_nodup K)]
  simp

end Bridges.ResidueLeakage