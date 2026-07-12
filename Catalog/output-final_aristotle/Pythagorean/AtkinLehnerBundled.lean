import Mathlib
import Pythagorean.AtkinLehnerGroup

/-!
# The Atkin–Lehner group of divisors as a bundled group and isomorphism

This file completes the algebraic picture of the two companion files
`Pythagorean/AtkinLehnerGroup.lean` and `Pythagorean/AtkinLehnerEquiv.lean` by promoting
the *realization theorem* to a fully **bundled group isomorphism**.

For a squarefree integer `N`, the divisors of `N` — the indices of the Atkin–Lehner
involutions `w_d` — form a group under the Atkin–Lehner composition law
`d ⋆ e = d·e / gcd(d,e)²` (`AtkinLehner.alMul`). We equip the subtype of divisors with
this group structure and identify it with the abstract elementary abelian `2`-group
`ALG {p // p ∈ N.primeFactors}`.

We prove:

* `AtkinLehner.instAddCommGroupALDiv` : the divisors of a squarefree `N` form an
  `AddCommGroup` whose addition is *literally* the Atkin–Lehner law `⋆`
  (`AtkinLehner.ALDiv_add_val`), with identity the divisor `1` and every element its own
  inverse.
* `AtkinLehner.ALDiv_two_torsion` : the group is `2`-torsion, i.e. elementary abelian.
* `AtkinLehner.toAbstractALG` : the bundled `AddEquiv` from the divisor group onto the
  abstract model `ALG {p // p ∈ N.primeFactors}`, sending a divisor to its set of prime
  factors and the law `⋆` to symmetric difference.
-/

namespace AtkinLehner
open Nat Finset
open scoped Classical

/-- The Atkin–Lehner composition law `⋆` is closed on the divisors of a squarefree
`N`. -/
theorem alMul_dvd {N d e : ℕ} (hN : Squarefree N) (hd : d ∣ N) (he : e ∣ N) :
    alMul d e ∣ N := by
  have hdsf : Squarefree d := hN.squarefree_of_dvd hd
  have hesf : Squarefree e := hN.squarefree_of_dvd he
  have hdp : ∏ p ∈ d.primeFactors, p = d := Nat.prod_primeFactors_of_squarefree hdsf
  have hep : ∏ p ∈ e.primeFactors, p = e := Nat.prod_primeFactors_of_squarefree hesf
  have hAprime : ∀ p ∈ d.primeFactors, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hBprime : ∀ p ∈ e.primeFactors, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hrewrite : alMul d e = ∏ p ∈ symmDiff d.primeFactors e.primeFactors, p := by
    conv_lhs => rw [← hdp, ← hep]
    exact alMul_prod _ _ hAprime hBprime
  rw [hrewrite]
  have hsub : symmDiff d.primeFactors e.primeFactors ⊆ N.primeFactors := by
    intro p hp
    rcases (Finset.mem_symmDiff.mp hp) with ⟨hpd, _⟩ | ⟨hpe, _⟩
    · exact Nat.primeFactors_mono hd hN.ne_zero hpd
    · exact Nat.primeFactors_mono he hN.ne_zero hpe
  calc ∏ p ∈ symmDiff d.primeFactors e.primeFactors, p
        ∣ ∏ p ∈ N.primeFactors, p := Finset.prod_dvd_prod_of_subset _ _ _ hsub
    _ = N := Nat.prod_primeFactors_of_squarefree hN

/-- **The group-isomorphism content.** Under the divisor–subset bijection, the
Atkin–Lehner composition law `d ⋆ e` corresponds to the symmetric difference of the
prime supports of `d` and `e`. -/
theorem alMul_realizes_symmDiff {N d e : ℕ} (hN : Squarefree N)
    (hd : d ∣ N) (he : e ∣ N) :
    (alMul d e).primeFactors = symmDiff d.primeFactors e.primeFactors := by
  have hdsf : Squarefree d := hN.squarefree_of_dvd hd
  have hesf : Squarefree e := hN.squarefree_of_dvd he
  have hdp : ∏ p ∈ d.primeFactors, p = d := Nat.prod_primeFactors_of_squarefree hdsf
  have hep : ∏ p ∈ e.primeFactors, p = e := Nat.prod_primeFactors_of_squarefree hesf
  have hAprime : ∀ p ∈ d.primeFactors, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hBprime : ∀ p ∈ e.primeFactors, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors hp
  have hrewrite : alMul d e = ∏ p ∈ symmDiff d.primeFactors e.primeFactors, p := by
    conv_lhs => rw [← hdp, ← hep]
    exact alMul_prod _ _ hAprime hBprime
  rw [hrewrite]
  apply Nat.primeFactors_prod
  intro p hp
  rcases (Finset.mem_symmDiff.mp hp) with ⟨hpd, _⟩ | ⟨hpe, _⟩
  · exact hAprime p hpd
  · exact hBprime p hpe

/-- The type of divisors of `N`, to be endowed with the Atkin–Lehner group structure. -/
abbrev ALDiv (N : ℕ) := {d // d ∈ N.divisors}

variable {N : ℕ} [hN : Fact (Squarefree N)]

instance : Zero (ALDiv N) := ⟨⟨1, Nat.one_mem_divisors.mpr hN.out.ne_zero⟩⟩

instance : Add (ALDiv N) :=
  ⟨fun d e => ⟨alMul d.1 e.1,
    Nat.mem_divisors.mpr
      ⟨alMul_dvd hN.out (Nat.dvd_of_mem_divisors d.2) (Nat.dvd_of_mem_divisors e.2),
        hN.out.ne_zero⟩⟩⟩

instance : Neg (ALDiv N) := ⟨id⟩
instance : Sub (ALDiv N) := ⟨fun d e => d + e⟩
instance : SMul ℕ (ALDiv N) := ⟨nsmulRec⟩
instance : SMul ℤ (ALDiv N) := ⟨zsmulRec⟩

@[simp] lemma ALDiv_zero_val : (0 : ALDiv N).1 = 1 := rfl
@[simp] lemma ALDiv_add_val (d e : ALDiv N) : (d + e).1 = alMul d.1 e.1 := rfl
omit hN in
@[simp] lemma ALDiv_neg_val (d : ALDiv N) : (-d).1 = d.1 := rfl

/-- The map sending a divisor to its set of prime factors, valued in the abstract model
`ALG ℕ`. Used to transport the group structure. -/
def toALGnat : ALDiv N → ALG ℕ := fun d => ALG.ofF d.1.primeFactors

lemma toALGnat_injective : Function.Injective (toALGnat (N := N)) := by
  intro d e h
  have hd : Squarefree d.1 := hN.out.squarefree_of_dvd (Nat.dvd_of_mem_divisors d.2)
  have he : Squarefree e.1 := hN.out.squarefree_of_dvd (Nat.dvd_of_mem_divisors e.2)
  apply Subtype.ext
  have hpf : d.1.primeFactors = e.1.primeFactors := ALG.toF_injective h
  rw [← Nat.prod_primeFactors_of_squarefree hd, ← Nat.prod_primeFactors_of_squarefree he, hpf]

lemma toALGnat_zero : toALGnat (0 : ALDiv N) = 0 := by
  change ALG.ofF (Nat.primeFactors 1) = 0
  rw [Nat.primeFactors_one]; rfl

lemma toALGnat_add (d e : ALDiv N) :
    toALGnat (d + e) = toALGnat d + toALGnat e := by
  have hd : d.1 ∣ N := Nat.dvd_of_mem_divisors d.2
  have he : e.1 ∣ N := Nat.dvd_of_mem_divisors e.2
  apply ALG.toF_injective
  ext p
  rw [ALG.toF_add]
  show p ∈ (alMul d.1 e.1).primeFactors ↔ _
  rw [alMul_realizes_symmDiff hN.out hd he]
  simp only [Finset.mem_symmDiff]
  rfl

omit hN in
lemma toALGnat_neg (d : ALDiv N) : toALGnat (-d) = -toALGnat d := rfl

lemma toALGnat_sub (d e : ALDiv N) :
    toALGnat (d - e) = toALGnat d - toALGnat e := by
  show toALGnat (d + e) = toALGnat d - toALGnat e
  rw [toALGnat_add, sub_eq_add_neg]; rfl

lemma toALGnat_nsmul (d : ALDiv N) (n : ℕ) :
    toALGnat (n • d) = n • toALGnat d := by
  induction n with
  | zero => show toALGnat (nsmulRec 0 d) = _; rw [nsmulRec, zero_smul]; exact toALGnat_zero
  | succ k ih =>
      show toALGnat (nsmulRec (k + 1) d) = _
      rw [nsmulRec, toALGnat_add,
        show toALGnat (nsmulRec k d) = toALGnat (k • d) from rfl, ih, succ_nsmul]

lemma toALGnat_zsmul (d : ALDiv N) (n : ℤ) :
    toALGnat (n • d) = n • toALGnat d := by
  cases n with
  | ofNat k => exact toALGnat_nsmul d k
  | negSucc k =>
      show toALGnat (-(nsmulRec (k + 1) d)) = _
      rw [toALGnat_neg,
        show toALGnat (nsmulRec (k + 1) d) = toALGnat ((k + 1) • d) from rfl,
        toALGnat_nsmul]
      rfl

/-- The divisors of a squarefree `N` form an `AddCommGroup` under the Atkin–Lehner
composition law `⋆`. -/
instance instAddCommGroupALDiv : AddCommGroup (ALDiv N) :=
  Function.Injective.addCommGroup toALGnat toALGnat_injective
    toALGnat_zero toALGnat_add toALGnat_neg toALGnat_sub toALGnat_nsmul toALGnat_zsmul

/-- The Atkin–Lehner group of divisors is `2`-torsion: every involution `w_d` squares to
the identity. -/
theorem ALDiv_two_torsion (d : ALDiv N) : d + d = 0 := by
  apply toALGnat_injective
  rw [toALGnat_add, toALGnat_zero]
  exact ALG.two_torsion _

/-- Taking `Finset.subtype` commutes with symmetric difference. -/
lemma subtype_symmDiff (s t : Finset ℕ) (P : ℕ → Prop) [DecidablePred P] :
    (symmDiff s t).subtype P = symmDiff (s.subtype P) (t.subtype P) := by
  ext x; simp only [Finset.mem_subtype, Finset.mem_symmDiff]

/-- The underlying function of the bundled isomorphism: a divisor maps to the finset of
its prime factors, viewed inside the primes dividing `N`. -/
def toAbsFun : ALDiv N → ALG {p : ℕ // p ∈ N.primeFactors} :=
  fun d => ALG.ofF ((d.1.primeFactors).subtype (· ∈ N.primeFactors))

lemma toAbsFun_zero : toAbsFun (0 : ALDiv N) = 0 := by
  apply ALG.toF_injective
  show ((1 : ℕ).primeFactors).subtype _ = (0 : ALG _).toF
  rw [Nat.primeFactors_one]; rfl

lemma toAbsFun_add (d e : ALDiv N) :
    toAbsFun (d + e) = toAbsFun d + toAbsFun e := by
  have hd : d.1 ∣ N := Nat.dvd_of_mem_divisors d.2
  have he : e.1 ∣ N := Nat.dvd_of_mem_divisors e.2
  apply ALG.toF_injective
  ext p
  rw [ALG.toF_add]
  show p ∈ ((alMul d.1 e.1).primeFactors).subtype _ ↔ _
  rw [alMul_realizes_symmDiff hN.out hd he, subtype_symmDiff]
  simp only [Finset.mem_symmDiff]; rfl

lemma toAbsFun_inj : Function.Injective (toAbsFun (N := N)) := by
  intro d e h
  have hd : Squarefree d.1 := hN.out.squarefree_of_dvd (Nat.dvd_of_mem_divisors d.2)
  have he : Squarefree e.1 := hN.out.squarefree_of_dvd (Nat.dvd_of_mem_divisors e.2)
  have hdsub : d.1.primeFactors ⊆ N.primeFactors :=
    Nat.primeFactors_mono (Nat.dvd_of_mem_divisors d.2) hN.out.ne_zero
  have hesub : e.1.primeFactors ⊆ N.primeFactors :=
    Nat.primeFactors_mono (Nat.dvd_of_mem_divisors e.2) hN.out.ne_zero
  have hsub : (d.1.primeFactors).subtype (· ∈ N.primeFactors)
      = (e.1.primeFactors).subtype (· ∈ N.primeFactors) := ALG.toF_injective h
  have hmapd := Finset.subtype_map_of_mem (fun x hx => hdsub hx) (s := d.1.primeFactors)
  have hmape := Finset.subtype_map_of_mem (fun x hx => hesub hx) (s := e.1.primeFactors)
  have hpf : d.1.primeFactors = e.1.primeFactors := by rw [← hmapd, ← hmape, hsub]
  apply Subtype.ext
  rw [← Nat.prod_primeFactors_of_squarefree hd, ← Nat.prod_primeFactors_of_squarefree he, hpf]

lemma toAbsFun_surj : Function.Surjective (toAbsFun (N := N)) := by
  intro s
  set A : Finset ℕ := (ALG.toF s).map (Function.Embedding.subtype _) with hA
  have hAsub : A ⊆ N.primeFactors := by
    intro x hx; rw [hA, Finset.mem_map] at hx; obtain ⟨y, _, rfl⟩ := hx; exact y.2
  have hAprime : ∀ p ∈ A, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors (hAsub hp)
  refine ⟨⟨∏ p ∈ A, p, ?_⟩, ?_⟩
  · rw [Nat.mem_divisors]
    refine ⟨?_, hN.out.ne_zero⟩
    calc ∏ p ∈ A, p ∣ ∏ p ∈ N.primeFactors, p := Finset.prod_dvd_prod_of_subset _ _ _ hAsub
      _ = N := Nat.prod_primeFactors_of_squarefree hN.out
  · apply ALG.toF_injective
    show ((∏ p ∈ A, p).primeFactors).subtype _ = ALG.toF s
    rw [Nat.primeFactors_prod hAprime]
    ext x
    simp only [Finset.mem_subtype, hA, Finset.mem_map, Function.Embedding.coe_subtype]
    constructor
    · rintro ⟨y, hy, hyx⟩; rw [← Subtype.ext hyx]; exact hy
    · intro hx; exact ⟨x, hx, rfl⟩

/-- The bundled group isomorphism from the divisors of a squarefree `N` (under the
Atkin–Lehner law `⋆`) onto the abstract elementary abelian `2`-group
`ALG {p // p ∈ N.primeFactors}`, sending a divisor to its set of prime factors. -/
noncomputable def toAbstractALG : ALDiv N ≃+ ALG {p : ℕ // p ∈ N.primeFactors} :=
  AddEquiv.ofBijective
    ({ toFun := toAbsFun, map_zero' := toAbsFun_zero, map_add' := toAbsFun_add } :
      ALDiv N →+ ALG {p : ℕ // p ∈ N.primeFactors})
    ⟨toAbsFun_inj, toAbsFun_surj⟩

end AtkinLehner