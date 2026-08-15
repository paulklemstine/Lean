import Cryptography.SingularModuli.GcdCriterion

/-!
# Singular Moduli Factoring, Step 2: exactly how many evaluation points work

Fix a monic `H ∈ ℤ[X]` (think: the Hilbert class polynomial `H_D`, which is
monic of degree the class number `h(D)`) and a semiprime `N = p q`.  By the
criterion of `GcdCriterion.lean`, an evaluation point `j₀` succeeds iff `j₀` is a
root of `H` mod exactly one of `p`, `q`.  Since that condition only depends on
`j₀ mod p` and `j₀ mod q`, the Chinese remainder theorem turns the count of
successful `j₀ ∈ [0, N)` into a product count.

Main results:

* `card_filter_xor_prod`   — the pure product-counting identity;
* `card_range_filter_crt`  — CRT transfer from `[0, pq)` to `ZMod p × ZMod q`;
* `successCount_eq`        — **the exact success count**
  `S = r_p (q - r_q) + (p - r_p) r_q`, where `r_m` is the number of roots of
  `H` mod `m`;
* `rootCount_le_natDegree` — `r_m ≤ deg H` (`= h` for a Hilbert class polynomial);
* `successCount_le`        — hence `S ≤ h (p + q)`: only an `O(h(p+q))`-sized
  subset of the `pq` residues is useful.

The last bound is the combinatorial source of the `√N` barrier proved in
`SqrtBarrier.lean`.
-/

namespace SingularModuli

open Polynomial Finset FactoringBarriers

/-- The reduction of the integer polynomial `H` modulo `m`. -/
noncomputable def redMod (H : Polynomial ℤ) (m : ℕ) : Polynomial (ZMod m) :=
  H.map (Int.castRingHom (ZMod m))

/-- The set of roots of `H` modulo `m`. -/
noncomputable def rootFinset (H : Polynomial ℤ) (m : ℕ) [NeZero m] : Finset (ZMod m) :=
  Finset.univ.filter (fun x => (redMod H m).eval x = 0)

/-- The number of roots of `H` modulo `m`.  For a Hilbert class polynomial `H_D`
and a prime `p` for which `D` is a square mod `p`, this is the class number `h`. -/
noncomputable def rootCount (H : Polynomial ℤ) (m : ℕ) [NeZero m] : ℕ :=
  (rootFinset H m).card

/-- Being a root mod `m` is exactly divisibility of the integer value by `m`. -/
theorem mem_rootFinset_iff_dvd {m : ℕ} [NeZero m] (H : Polynomial ℤ) (j : ℤ) :
    ((j : ZMod m) ∈ rootFinset H m) ↔ (m : ℤ) ∣ H.eval j := by
  have hev : (redMod H m).eval ((j : ZMod m)) = ((H.eval j : ℤ) : ZMod m) := by
    rw [redMod, Polynomial.eval_map]
    simp
  rw [rootFinset, Finset.mem_filter]
  simp only [Finset.mem_univ, true_and, hev]
  exact ZMod.intCast_zmod_eq_zero_iff_dvd _ _

/-- A monic polynomial has at most `deg H` roots modulo a prime. -/
theorem rootCount_le_natDegree (H : Polynomial ℤ) {m : ℕ} (hm : m.Prime) (hH : H.Monic) :
    haveI : NeZero m := ⟨hm.pos.ne'⟩
    rootCount H m ≤ H.natDegree := by
  haveI : NeZero m := ⟨hm.pos.ne'⟩
  haveI : Fact m.Prime := ⟨hm⟩
  have hmonic : (redMod H m).Monic := hH.map _
  have hne : (redMod H m) ≠ 0 := hmonic.ne_zero
  have hsub : rootFinset H m ⊆ (redMod H m).roots.toFinset := by
    intro x hx
    rw [rootFinset, Finset.mem_filter] at hx
    simp only [Multiset.mem_toFinset, Polynomial.mem_roots hne, Polynomial.IsRoot.def]
    exact hx.2
  calc rootCount H m ≤ (redMod H m).roots.toFinset.card := Finset.card_le_card hsub
    _ ≤ Multiset.card (redMod H m).roots := (redMod H m).roots.toFinset_card_le
    _ ≤ (redMod H m).natDegree := (redMod H m).card_roots'
    _ = H.natDegree := hH.natDegree_map _

/-! ## The product count -/

/-- **Product counting.** In `ZMod p × ZMod q`, the pairs satisfying exactly one
of "first coordinate in `A`", "second coordinate in `B`" number
`|A|(q - |B|) + (p - |A|)|B|`. -/
theorem card_filter_xor_prod {p q : ℕ} [NeZero p] [NeZero q]
    (A : Finset (ZMod p)) (B : Finset (ZMod q)) :
    (Finset.univ.filter (fun z : ZMod p × ZMod q => Xor' (z.1 ∈ A) (z.2 ∈ B))).card
      = A.card * (q - B.card) + (p - A.card) * B.card := by
  classical
  have hset : (Finset.univ.filter (fun z : ZMod p × ZMod q => Xor' (z.1 ∈ A) (z.2 ∈ B)))
      = (A ×ˢ Bᶜ) ∪ (Aᶜ ×ˢ B) := by
    ext z
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_union,
      Finset.mem_product, Finset.mem_compl, Xor']
    tauto
  have hdisj : Disjoint (A ×ˢ Bᶜ) (Aᶜ ×ˢ B) := by
    rw [Finset.disjoint_left]
    intro z hz hz'
    simp only [Finset.mem_product, Finset.mem_compl] at hz hz'
    exact hz'.1 hz.1
  rw [hset, Finset.card_union_of_disjoint hdisj, Finset.card_product, Finset.card_product,
    Finset.card_compl, Finset.card_compl, ZMod.card, ZMod.card]

/-! ## Chinese remainder transfer -/

/-- **CRT transfer.** Counting `j ∈ [0, pq)` by the pair of its residues is the
same as counting in `ZMod p × ZMod q`. -/
theorem card_range_filter_crt {p q : ℕ} [NeZero p] [NeZero q] (hcop : Nat.Coprime p q)
    (R : ZMod p → ZMod q → Prop) [∀ a b, Decidable (R a b)] :
    ((Finset.range (p * q)).filter (fun j : ℕ => R (j : ZMod p) (j : ZMod q))).card
      = (Finset.univ.filter (fun z : ZMod p × ZMod q => R z.1 z.2)).card := by
  have hp0 : 0 < p := Nat.pos_of_ne_zero (NeZero.ne p)
  have hq0 : 0 < q := Nat.pos_of_ne_zero (NeZero.ne q)
  refine Finset.card_nbij (fun j : ℕ => ((j : ZMod p), (j : ZMod q))) ?_ ?_ ?_
  · intro j hj
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at hj
    simp [hj.2]
  · intro j₁ h₁ j₂ h₂ heq
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range] at h₁ h₂
    have hp : (j₁ : ZMod p) = (j₂ : ZMod p) := congrArg Prod.fst heq
    have hq : (j₁ : ZMod q) = (j₂ : ZMod q) := congrArg Prod.snd heq
    have hmp : j₁ ≡ j₂ [MOD p] := (ZMod.natCast_eq_natCast_iff _ _ _).mp hp
    have hmq : j₁ ≡ j₂ [MOD q] := (ZMod.natCast_eq_natCast_iff _ _ _).mp hq
    have hmn : j₁ ≡ j₂ [MOD p * q] :=
      (Nat.modEq_and_modEq_iff_modEq_mul hcop).mp ⟨hmp, hmq⟩
    have := hmn
    rwa [Nat.ModEq, Nat.mod_eq_of_lt h₁.1, Nat.mod_eq_of_lt h₂.1] at this
  · intro z hz
    simp only [Finset.coe_filter, Finset.mem_univ, true_and, Set.mem_setOf_eq] at hz
    obtain ⟨k, hk1, hk2⟩ := Nat.chineseRemainder hcop z.1.val z.2.val
    refine ⟨k % (p * q), ?_, ?_⟩
    · have hpos : 0 < p * q := Nat.mul_pos hp0 hq0
      have hlt : k % (p * q) < p * q := Nat.mod_lt _ hpos
      have hmod : k % (p * q) ≡ k [MOD p * q] := Nat.mod_modEq _ _
      have hcp : ((k % (p * q) : ℕ) : ZMod p) = z.1 := by
        have : k % (p * q) ≡ k [MOD p] :=
          ((Nat.modEq_and_modEq_iff_modEq_mul hcop).mpr hmod).1
        have h1 : ((k % (p * q) : ℕ) : ZMod p) = (k : ZMod p) :=
          (ZMod.natCast_eq_natCast_iff _ _ _).mpr this
        rw [h1, (ZMod.natCast_eq_natCast_iff _ _ _).mpr hk1, ZMod.natCast_val,
          ZMod.cast_id]
      have hcq : ((k % (p * q) : ℕ) : ZMod q) = z.2 := by
        have : k % (p * q) ≡ k [MOD q] :=
          ((Nat.modEq_and_modEq_iff_modEq_mul hcop).mpr hmod).2
        have h1 : ((k % (p * q) : ℕ) : ZMod q) = (k : ZMod q) :=
          (ZMod.natCast_eq_natCast_iff _ _ _).mpr this
        rw [h1, (ZMod.natCast_eq_natCast_iff _ _ _).mpr hk2, ZMod.natCast_val,
          ZMod.cast_id]
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_range]
      exact ⟨hlt, by rw [hcp, hcq]; exact hz⟩
    · have hcp : ((k % (p * q) : ℕ) : ZMod p) = z.1 := by
        have hmod : k % (p * q) ≡ k [MOD p * q] := Nat.mod_modEq _ _
        have : k % (p * q) ≡ k [MOD p] :=
          ((Nat.modEq_and_modEq_iff_modEq_mul hcop).mpr hmod).1
        have h1 : ((k % (p * q) : ℕ) : ZMod p) = (k : ZMod p) :=
          (ZMod.natCast_eq_natCast_iff _ _ _).mpr this
        rw [h1, (ZMod.natCast_eq_natCast_iff _ _ _).mpr hk1, ZMod.natCast_val,
          ZMod.cast_id]
      have hcq : ((k % (p * q) : ℕ) : ZMod q) = z.2 := by
        have hmod : k % (p * q) ≡ k [MOD p * q] := Nat.mod_modEq _ _
        have : k % (p * q) ≡ k [MOD q] :=
          ((Nat.modEq_and_modEq_iff_modEq_mul hcop).mpr hmod).2
        have h1 : ((k % (p * q) : ℕ) : ZMod q) = (k : ZMod q) :=
          (ZMod.natCast_eq_natCast_iff _ _ _).mpr this
        rw [h1, (ZMod.natCast_eq_natCast_iff _ _ _).mpr hk2, ZMod.natCast_val,
          ZMod.cast_id]
      exact Prod.ext hcp hcq

/-! ## The exact success count -/

open scoped Classical in
/-- The set of evaluation points in `[0, N)` at which the gcd step succeeds. -/
noncomputable def successSet (H : Polynomial ℤ) (N : ℕ) : Finset ℕ :=
  (Finset.range N).filter (fun j => NontrivialDivisor N (evalGcd H (j : ℤ) N))

open scoped Classical in
/-- The number of useful evaluation points modulo `N`. -/
noncomputable def successCount (H : Polynomial ℤ) (N : ℕ) : ℕ := (successSet H N).card

/-- **The exact success count.** For a semiprime `N = pq` with distinct primes and
any integer polynomial `H`, the number of residues `j ∈ [0, N)` at which
`gcd (H(j), N)` is a nontrivial factor equals `r_p (q - r_q) + (p - r_p) r_q`,
where `r_m` is the number of roots of `H` modulo `m`. -/
theorem successCount_eq {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (H : Polynomial ℤ) :
    haveI : NeZero p := ⟨hp.pos.ne'⟩
    haveI : NeZero q := ⟨hq.pos.ne'⟩
    successCount H (p * q)
      = rootCount H p * (q - rootCount H q) + (p - rootCount H p) * rootCount H q := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  classical
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hne
  have hpred : ∀ j : ℕ, NontrivialDivisor (p * q) (evalGcd H (j : ℤ) (p * q)) ↔
      Xor' (((j : ℤ) : ZMod p) ∈ rootFinset H p) (((j : ℤ) : ZMod q) ∈ rootFinset H q) := by
    intro j
    rw [evalGcd_nontrivialDivisor_iff hp hq hne, mem_rootFinset_iff_dvd,
      mem_rootFinset_iff_dvd]
  have hcast : ∀ j : ℕ, ((j : ℤ) : ZMod p) = (j : ZMod p) := by
    intro j; push_cast; rfl
  have hcast' : ∀ j : ℕ, ((j : ℤ) : ZMod q) = (j : ZMod q) := by
    intro j; push_cast; rfl
  have hfilter : successSet H (p * q)
      = (Finset.range (p * q)).filter
          (fun j : ℕ => Xor' ((j : ZMod p) ∈ rootFinset H p) ((j : ZMod q) ∈ rootFinset H q)) := by
    rw [successSet]
    apply Finset.filter_congr
    intro j _
    rw [hpred j, hcast j, hcast' j]
  rw [successCount, hfilter,
    card_range_filter_crt hcop
      (fun a b => Xor' (a ∈ rootFinset H p) (b ∈ rootFinset H q)),
    card_filter_xor_prod]
  rfl

/-- **The useful set is tiny.** For monic `H` of degree `h`, at most `h (p + q)`
of the `pq` residues are useful evaluation points. -/
theorem successCount_le {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    {H : Polynomial ℤ} (hH : H.Monic) :
    successCount H (p * q) ≤ H.natDegree * (p + q) := by
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  haveI : NeZero q := ⟨hq.pos.ne'⟩
  have hrp : rootCount H p ≤ H.natDegree := rootCount_le_natDegree H hp hH
  have hrq : rootCount H q ≤ H.natDegree := rootCount_le_natDegree H hq hH
  rw [successCount_eq hp hq hne H]
  calc rootCount H p * (q - rootCount H q) + (p - rootCount H p) * rootCount H q
      ≤ rootCount H p * q + p * rootCount H q := by
        gcongr <;> [exact Nat.sub_le _ _; exact Nat.sub_le _ _]
    _ ≤ H.natDegree * q + p * H.natDegree := by gcongr
    _ = H.natDegree * (p + q) := by ring

end SingularModuli